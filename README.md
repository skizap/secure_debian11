secure_debian11
secure_debian11.sh - Overview This script, secure_debian11.sh, is designed to secure a fresh Debian 11 installation on a VPS. Below is an overview of its functionality and features:

Purpose Automates the hardening process for a Debian 11 system, ensuring security and performance optimizations.

Key Features System Updates: Automates updates and enables unattended upgrades. User Management: Creates a new sudo user with limited privileges. Firewall Configuration: Sets up ufw based on user-defined server purpose. Brute-force Protection: Installs and configures fail2ban to protect against attacks. Swap Configuration: Creates a 6GB swap file to enhance memory management. Malware Scanning: Installs and configures ClamAV to detect and prevent malware. Error Handling: Logs errors in /root/secure_debian11_error.log and ensures safe execution with set -euo pipefail. Script Highlights Interactive Design: Prompts the user to customize configurations (e.g., firewall ports). Re-run Protection: Prevents redundant actions using /var/log/secure_debian11_run.log. Enhanced Terminal Visuals: Uses colors and ASCII art for improved readability. Script Logic Breakdown

System Updates Updates the system using apt and installs unattended-upgrades for auto-updates. Configures auto-update behavior via /etc/apt/apt.conf.d/20auto-upgrades.
User Management Creates a new user (gamemaster) with sudo privileges and stores credentials securely in /root/gamemaster_credentials.txt.
Firewall Configuration Installs and configures ufw. Opens ports based on user-defined server purpose: General-purpose: Ports 22, 80, 443. Web server: Ports 80, 443. Game server or custom: User-specified ports.
Fail2Ban Setup Configures fail2ban to block IPs after 3 failed login attempts for 1 hour. Updates jail.local with stricter security parameters.
Swap Configuration Creates and enables a 6GB swap file if not already present. Configures swap persistence in /etc/fstab and optimizes performance with vm.swappiness=10.
Malware Scanner Installation Installs and configures ClamAV and its daemon for malware scanning. Ensures proper permissions and updates virus definitions using freshclam.
Final Notes Displays a summary of actions and provides the location of stored credentials. Strengths Comprehensive Hardening: Covers essential areas like updates, user management, and security. Error Handling: Provides detailed error logs for troubleshooting. Customizable: Allows user input to adapt the configuration.
Important Note Make sure to replace the placeholder USERNAMEHERE on line 167 with the actual username you want to create, and it should be in lowercase. If you have any specific questions about the script or need further details on any part, feel free to ask!

Detailed Script Description
The secure_debian11_v2.sh is a Bash script designed to secure a fresh Debian 11 installation on a VPS. It includes various features such as enhanced terminal visuals, robust error handling, and an interactive GUI for firewall configuration.

Features
Enhanced Terminal Visuals:

Uses colors and ASCII art to improve terminal output.
Robust Error Handling:

Logs errors to /root/secure_debian11_error.log.
Uses a trap to handle errors and log them with detailed messages.
Run Log:

Logs completed steps to /var/log/secure_debian11_run.log to avoid repeating steps.
Interactive GUI for Firewall Configuration:

Provides multiple selection options for configuring the firewall.
Detection of Previous Runs:

Skips unnecessary steps if they have already been completed.
Steps
System Updates:

Updates and upgrades the system packages.
Installs unattended-upgrades and configures auto-upgrades.
Create New User:

Prompts for a new user password.
Creates a new user and adds it to the sudo group.
Configure Firewall:

Installs ufw and sets up firewall rules based on user input.
Install Fail2Ban:

Installs fail2ban and configures basic settings.
Enable Swap:

Creates a 6GB swap file if it doesn't exist.
Configures swappiness.
Install ClamAV:

Installs clamav and clamav-daemon.
Updates virus definitions and starts services.
Final Setup:

Displays a completion message summarizing the setup.
Example of Running the Script
To run the script, you need to execute it as the root user. Here's an example command:

sudo bash secure_debian11_v2.sh
