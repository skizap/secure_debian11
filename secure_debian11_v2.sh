#!/usr/bin/env bash 
#
# secure_debian11.sh
#
# A Bash script to secure a fresh Debian 11 installation on a VPS.
# Features:
# - Enhanced terminal visuals with colors and ASCII art.
# - Robust error handling with detailed error logs.
# - Detects previous runs and skips unnecessary steps.
# - Interactive GUI for firewall configuration with multiple selection options.
#

# Exit on any error and treat unset variables as errors
set -euo pipefail

# Error log file
ERROR_LOG="/root/secure_debian11_error.log"
RUN_LOG="/var/log/secure_debian11_run.log"

# Function to handle errors and log them
error_handler() {
    local line_number=$1
    local error_message=$2
    echo -e "\e[31m[ERROR] An error occurred at line $line_number: $error_message\e[0m" | tee -a "$ERROR_LOG"
    echo "Check $ERROR_LOG for details." | tee -a "$ERROR_LOG"
    exit 1
}

trap 'error_handler ${LINENO} "$BASH_COMMAND"' ERR

# Function to check if a command is already run
already_run() {
    grep -qxF "$1" "$RUN_LOG" 2>/dev/null
}

# Log completed steps
log_step() {
    echo "$1" >> "$RUN_LOG"
}

# Colors for the script
GREEN="\e[32m"
BLUE="\e[34m"
CYAN="\e[36m"
RED="\e[31m"
YELLOW="\e[33m"
MAGENTA="\e[35m"
RESET="\e[0m"
RAINBOW=("\e[31m" "\e[33m" "\e[32m" "\e[36m" "\e[34m" "\e[35m")

# ---------------------------------------------------------------------------------
# 1) Fixed ASCII Art Banner for Debian 11
# ---------------------------------------------------------------------------------
show_debian_banner() {
cat << "EOF"
 ██████╗ ███████╗██████╗ ██╗ █████╗ ███╗   ██╗ ██╗ ██╗
 ██╔══██╗██╔════╝██╔══██╗██║██╔══██╗████╗  ██║███║███║
 ██║  ██║█████╗  ██████╔╝██║███████║██╔██╗ ██║╚██║╚██║
 ██║  ██║██╔══╝  ██╔══██╗██║██╔══██║██║╚██╗██║ ██║ ██║
 ██████╔╝███████╗██████╔╝██║██║  ██║██║ ╚████║ ██║ ██║
 ╚═════╝ ╚══════╝╚═════╝ ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═╝ ╚═╝
   Welcome to the Secure Debian 11 Hardening Script
EOF
}

# ---------------------------------------------------------------------------------
# 2) Matrix-Style Progress (Replaces Normal apt Output)
# ---------------------------------------------------------------------------------
matrix_progress() {
    local cmd="$*"
    
    # Run the actual command in the background, hide all normal output
    $cmd > /dev/null 2>&1 &
    local pid=$!
    
    # Print random digits while the above command is running
    # Adjust width / speed / character set to taste
    while kill -0 "$pid" 2>/dev/null; do
        # Print one line of random 0/1
        for i in {1..60}; do
            printf "%d" $((RANDOM % 2))
        done
        printf "\n"
        # Sleep briefly so it doesn't scroll instantly
        sleep 0.05
    done
    
    # Optional: print a finishing line
    echo -e "\e[32m[✓] Done!\e[0m"
}

# ---------------------------------------------------------------------------------
# Welcome + Banner
# ---------------------------------------------------------------------------------
clear
echo -e "${GREEN}═════════════════════════════════════════════════════════${RESET}"
show_debian_banner
echo -e "${GREEN}═════════════════════════════════════════════════════════${RESET}"
echo -e "${BLUE}Welcome to the Secure Debian 11 Hardening Script!${RESET}\n"

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Please run this script as root (sudo su).${RESET}"
    exit 1
fi

# Initialize run log if it doesn't exist
touch "$RUN_LOG" 2>/dev/null || true

# Steps array for tracking progress
declare -A STEPS=(
    ["system_updates"]="System Updates"
    ["create_user"]="Create New User"
    ["configure_firewall"]="Configure Firewall"
    ["install_fail2ban"]="Install Fail2Ban"
    ["enable_swap"]="Enable Swap"
    ["install_clamav"]="Install ClamAV"
    ["final_setup"]="Final Setup"
)

# Function to execute a step with proper checks
execute_step() {
    local step_name="$1"
    local step_function="$2"
    
    if already_run "$step_name"; then
        echo -e "${BLUE}Step '$step_name' already completed. Skipping...${RESET}"
        return 0
    fi
    
    echo -e "${CYAN}==> Executing: ${STEPS[$step_name]}${RESET}"
    # Here you can do a tiny matrix spin if you want, or just let the step run.
    if $step_function; then
        log_step "$step_name"
        echo -e "${GREEN}✓ ${STEPS[$step_name]} completed successfully${RESET}"
    else
        error_handler "$LINENO" "Failed to execute ${STEPS[$step_name]}"
    fi
}

# ---------------------------------------------------------------------------------
# (A) System Updates Function — now wrapped in matrix_progress
# ---------------------------------------------------------------------------------
system_updates() {
    matrix_progress "apt update -y"
    matrix_progress "apt upgrade -y"
    matrix_progress "apt dist-upgrade -y"
    matrix_progress "apt install -y unattended-upgrades apt-listchanges"

    # This line prints a bunch of debug text normally; hide it behind matrix too
    matrix_progress "unattended-upgrades --dry-run --debug"

    # Enable auto-upgrades
    cat <<EOF >/etc/apt/apt.conf.d/20auto-upgrades
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Autoremove "7";
EOF
    return 0
}

# ---------------------------------------------------------------------------------
# (B) Create New User
# ---------------------------------------------------------------------------------
create_user() {
    local NEW_USER="USERNAMEHERE"
    read -s -p "Enter a strong password for the new user: " NEW_USER_PASS
    echo
    
    if ! id -u "$NEW_USER" >/dev/null 2>&1; then
        # The adduser command is quick enough that a matrix effect might be overkill,
        # but you can wrap it if you really want. For example:
        matrix_progress "adduser --quiet --disabled-password --gecos \"\" $NEW_USER"
        echo "${NEW_USER}:${NEW_USER_PASS}" | chpasswd
        echo "User: $NEW_USER\nPassword: $NEW_USER_PASS" > /root/${NEW_USER}_credentials.txt
        chmod 600 /root/${NEW_USER}_credentials.txt
        usermod -aG sudo "$NEW_USER"
    fi
    return 0
}

# ---------------------------------------------------------------------------------
# (C) Interactive Firewall Configuration
# ---------------------------------------------------------------------------------
configure_firewall() {
    matrix_progress "apt install -y ufw"
    
    # Terminal GUI for port selection
    echo -e "${CYAN}What is the purpose of this server?${RESET}"
    echo -e "${GREEN}1)${RESET} General-purpose (SSH, HTTP, HTTPS)"
    echo -e "${GREEN}2)${RESET} Web server only (HTTP, HTTPS)"
    echo -e "${GREEN}3)${RESET} Game server"
    echo -e "${GREEN}4)${RESET} Custom configuration"
    
    read -p "Enter your choice [1-4]: " PURPOSE
    
    case "$PURPOSE" in
        1)
            PORTS=(22 80 443)
            ;;
        2)
            PORTS=(80 443)
            ;;
        3)
            echo -e "\n${CYAN}Common game server ports:${RESET}"
            echo -e "${GREEN}1)${RESET} Minecraft (25565)"
            echo -e "${GREEN}2)${RESET} Counter-Strike (27015)"
            echo -e "${GREEN}3)${RESET} Valheim (2456-2458)"
            echo -e "${GREEN}4)${RESET} Custom ports"
            
            read -p "Enter your choice [1-4]: " GAME_CHOICE
            case "$GAME_CHOICE" in
                1) PORTS=(25565) ;;
                2) PORTS=(27015) ;;
                3) PORTS=(2456 2457 2458) ;;
                4)
                    read -p "Enter custom ports (comma-separated): " CUSTOM_PORTS
                    IFS=',' read -ra PORTS <<< "$CUSTOM_PORTS"
                    ;;
            esac
            ;;
        4)
            read -p "Enter custom ports (comma-separated): " CUSTOM_PORTS
            IFS=',' read -ra PORTS <<< "$CUSTOM_PORTS"
            ;;
        *)
            echo -e "${RED}Invalid choice. Defaulting to general-purpose.${RESET}"
            PORTS=(22 80 443)
            ;;
    esac
    
    ufw default deny incoming
    ufw default allow outgoing
    for PORT in "${PORTS[@]}"; do
        ufw allow ${PORT}/tcp
    done
    
    ufw --force enable
    ufw status verbose
    return 0
}

# ---------------------------------------------------------------------------------
# (D) Install Fail2Ban
# ---------------------------------------------------------------------------------
install_fail2ban() {
    matrix_progress "apt install -y fail2ban"
    cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
    sed -i 's/^bantime  = 10m/bantime  = 1h/' /etc/fail2ban/jail.local
    sed -i 's/^maxretry = 5/maxretry = 3/' /etc/fail2ban/jail.local
    
    systemctl enable fail2ban
    systemctl restart fail2ban
    return 0
}

# ---------------------------------------------------------------------------------
# (E) Enable Swap
# ---------------------------------------------------------------------------------
enable_swap() {
    if [ ! -f /swapfile ]; then
        if ! fallocate -l 6G /swapfile; then
            # fallback if fallocate not available
            matrix_progress "dd if=/dev/zero of=/swapfile bs=1G count=6"
        fi
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile
        echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
    fi
    
    sysctl vm.swappiness=10
    if ! grep -q "vm.swappiness" /etc/sysctl.conf; then
        echo "vm.swappiness=10" >> /etc/sysctl.conf
    fi
    return 0
}

# ---------------------------------------------------------------------------------
# (F) Install ClamAV
# ---------------------------------------------------------------------------------
install_clamav() {
    matrix_progress "apt install -y clamav clamav-daemon"
    
    if ! id -u clamav &>/dev/null; then
        groupadd --system clamav
        useradd --system --shell /bin/false --no-create-home -g clamav -c "Clam AntiVirus" clamav
    fi
    
    systemctl stop clamav-freshclam || true
    systemctl stop clamav-daemon || true
    
    mkdir -p /var/log/clamav /var/lib/clamav
    chown -R clamav:clamav /var/log/clamav /var/lib/clamav
    chmod 755 /var/log/clamav /var/lib/clamav
    
    matrix_progress "freshclam"
    
    systemctl enable clamav-freshclam
    systemctl start clamav-freshclam
    systemctl enable clamav-daemon
    systemctl start clamav-daemon
    return 0
}

# ---------------------------------------------------------------------------------
# (G) Final Setup
# ---------------------------------------------------------------------------------
final_setup() {
    echo -e "${GREEN}╔════════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}║      System Hardening Complete!        ║${RESET}"
    echo -e "${GREEN}╠════════════════════════════════════════╣${RESET}"
    echo -e "${GREEN}║ ✓ New user created                     ║${RESET}"
    echo -e "${GREEN}║ ✓ Firewall configured                  ║${RESET}"
    echo -e "${GREEN}║ ✓ Fail2Ban installed                   ║${RESET}"
    echo -e "${GREEN}║ ✓ 6GB swap enabled                     ║${RESET}"
    echo -e "${GREEN}║ ✓ ClamAV installed                     ║${RESET}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${RESET}"
    return 0
}

# ---------------------------------------------------------------------------------
# Execute All Steps
# ---------------------------------------------------------------------------------
execute_step "system_updates" system_updates
execute_step "create_user" create_user
execute_step "configure_firewall" configure_firewall
execute_step "install_fail2ban" install_fail2ban
execute_step "enable_swap" enable_swap
execute_step "install_clamav" install_clamav
execute_step "final_setup" final_setup

