#!/bin/bash

# Enforce Root Privileges
if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run this script with root privileges (sudo)."
  exit 1
fi

# Check for dialog's existence (sonzai - existence)
if ! command -v dialog &> /dev/null; then
  echo "dialog is required for user interaction. Installing..."
  pacman -S --noconfirm dialog || { echo "Failed to install 'dialog'. Exiting."; exit 1; }
fi

# Variables
REPO_URL="https://github.com/archlinux/archinstall.git"
INSTALL_SCRIPT="archinstall/archinstall/scripts/Installer.py"

# Welcome Message
dialog --title "Welcome to MaiArch Installation" \
--msgbox "WARNING: THIS OS IS EARLY RELEASE AND UNSTABLE. USE WITH CAUTION!\nWelcome to the MaiArch Installer!" 5 40

# Confirmation Dialog
if ! dialog --title "MaiArch Installation Confirmation" \
   --yesno "By pressing 'yes', MaiArch will be installed. This includes:\n- Base OS installation\n- Additional packages: 'Cortex Penguin' and 'OmniPkg' (see https://github.com/devtracer)." 15 50; then
  dialog --msgbox "Installation canceled. You can restart anytime." 5 40
  exit 1
fi

# Install required packages
pacman -Sy --noconfirm git || { echo "Failed to update/install 'git'. Exiting."; exit 1; }

# Clone the archinstall repository
git clone "$REPO_URL" || { echo "Failed to clone repository. Exiting."; exit 1; }

# Move custom installer script
mv Installer.py "$INSTALL_SCRIPT" || { echo "Failed to move Installer.py. Exiting."; exit 1; }

# Run the custom installer
python "$INSTALL_SCRIPT" || { echo "Custom installer script failed. Exiting."; exit 1; }

# Message and additional package installations
dialog --msgbox "The base has been installed." 5 40

dialog --msgbox "Continuing with installing your side apps." 5 40

dialog --msgbox "Starting with TuxTalk, MaiArch's AI assistant..." 5 40

# Function to handle dialog error messages
show_error() {
    dialog --msgbox "$1" 7 50
}

# Install TuxTalk
if git clone https://github.com/devtracer/TuxTalk.git && cd TuxTalk && chmod +x ./Installer.sh && ./Installer.sh; then
    dialog --msgbox "TuxTalk has been installed successfully. Proceeding to install OmniPkg, MaiArch's default package manager..." 7 50
else
    show_error "TuxTalk installation failed. Please check the errors and try again. For assistance, visit: https://www.github.com/devtracer/TuxTalk.git."
    exit 1
fi

# Install OmniPkg
if git clone https://github.com/devtracer/OmniPkg.git && cd OmniPkg && chmod +x omnipkginstall.sh && ./omnipkginstall.sh; then
    dialog --msgbox "The installation is complete. The system will now restart..." 7 50
    reboot
else
    show_error "OmniPkg installation failed. Please check the errors and try again. For assistance, visit: https://www.github.com/devtracer/OmniPkg.git."
    exit 1
fi
