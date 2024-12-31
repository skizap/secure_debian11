
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
Important Note
Make sure to replace the placeholder USERNAMEHERE on line 167 with the actual username you want to create, and it should be in lowercase.

If you have any specific questions about the script or need further details on any part, feel free to ask!
