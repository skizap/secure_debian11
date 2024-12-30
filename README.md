# secure_debian11

secure_debian11.sh - Overview
This script, secure_debian11.sh, is designed to secure a fresh Debian 11 installation on a VPS. Below is an overview of its functionality and features:

Purpose
Automates the hardening process for a Debian 11 system, ensuring security and performance optimizations.

Key Features
System Updates: Automates updates and enables unattended upgrades.
User Management: Creates a new sudo user with limited privileges.
Firewall Configuration: Sets up ufw based on user-defined server purpose.
Brute-force Protection: Installs and configures fail2ban to protect against attacks.
Swap Configuration: Creates a 6GB swap file to enhance memory management.
Malware Scanning: Installs and configures ClamAV to detect and prevent malware.
Error Handling: Logs errors in /root/secure_debian11_error.log and ensures safe execution with set -euo pipefail.
Script Highlights
Interactive Design: Prompts the user to customize configurations (e.g., firewall ports).
Re-run Protection: Prevents redundant actions using /var/log/secure_debian11_run.log.
Enhanced Terminal Visuals: Uses colors and ASCII art for improved readability.
Script Logic Breakdown
1. System Updates
Updates the system using apt and installs unattended-upgrades for auto-updates.
Configures auto-update behavior via /etc/apt/apt.conf.d/20auto-upgrades.
2. User Management
Creates a new user (gamemaster) with sudo privileges and stores credentials securely in /root/gamemaster_credentials.txt.
3. Firewall Configuration
Installs and configures ufw.
Opens ports based on user-defined server purpose:
General-purpose: Ports 22, 80, 443.
Web server: Ports 80, 443.
Game server or custom: User-specified ports.
4. Fail2Ban Setup
Configures fail2ban to block IPs after 3 failed login attempts for 1 hour.
Updates jail.local with stricter security parameters.
5. Swap Configuration
Creates and enables a 6GB swap file if not already present.
Configures swap persistence in /etc/fstab and optimizes performance with vm.swappiness=10.
6. Malware Scanner Installation
Installs and configures ClamAV and its daemon for malware scanning.
Ensures proper permissions and updates virus definitions using freshclam.
7. Final Notes
Displays a summary of actions and provides the location of stored credentials.
Strengths
Comprehensive Hardening: Covers essential areas like updates, user management, and security.
Error Handling: Provides detailed error logs for troubleshooting.
Customizable: Allows user input to adapt the configuration.
Suggestions for Improvement
Use encryption tools like gpg for storing user credentials securely.
Modularize the script for easier maintenance and extensibility.
Include compatibility checks to ensure the script runs only on Debian 11.
