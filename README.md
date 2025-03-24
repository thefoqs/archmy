<h1 align="center">
  Archmy - a post install helper script for the Arch based distros.
	
</h1>
<p align="center">
  <img width="300" height="300" src="./images/logo.png">
</p>

<h3 align="center">
  This scripts was adapted for Arch Linux from <a href="https://github.com/smittix/fedorable.git">Fedorable</a> By <a href="https://github.com/smittix">Smittix</a>
</h3>

# Introduction
The Archmy script is a powerful post-install setup utility for Arch-based systems. It automates several system configuration tasks, from enabling Chaotic-AUR repository, Firmware Update, Speed Up Pacman, Enable Flatpak Support, Install Some Softwares, Oh-My-Zsh with Starship Prompt, Install Timeshift with Grub Support & Install Nvidia Open Drivers, ensuring your system is optimized and ready to use.
This guide will help you understand the various features of the script and how to use them effectively.

# Contents of the Script
The Archmy script contains the following key functionalities:

1. **Enable Chaotic-AUR**: Adds the Chaotic-AUR repositories to your system, which provides pre-compiled AUR packages.
2. **Update Firmware**: Utilizes fwupdmgr to check for and install any available firmware updates.
3. **Speed Up PACMAN**: Optimizes PACMAN, Arch's package manager, by increasing the number of parallel downloads.
4. **Enable FlatHub**: Enables FlatHub support and installs any applications listed in a predefined flatpak-packages.txt file.
5. **Install Software**: Installs software packages listed in the pacman-packages.txt file using PACMAN. (You must have Chaotic-AUR Enabled)
6. **Install Oh-My-Zsh & Starship Prompt**: Installs the Oh-My-Zsh shell and Starship prompt for an enhanced command-line experience.
7. **Install Timeshift**: Installs the Timeshift with grub menu support.
8. **Install Nvidia Open Drivers**: Installs the Nvidia Open Drivers if you have an Nvidia GPU. (Turing+ only)
9. **Install Lazyvim**: Installs Lazyvim, a Neovim framework for lazy people.
10. **Customisation Menu**: Allows some system configurations.
11. **Quit**: Exits the script

# How to Use the Script

## Prerequisites
1. Ensure you have root/sudo privileges on your system, as many of the tasks require elevated permissions.
2. You need to have Arch installed with the KDE-Plasma enviroment.

## Steps to Run the Script

1. Download or Clone the Script: Download the script or clone the repository to your local machine.
```
git clone https://github.com/thefoqs/archmy.git
cd archmy
```
2. Make the Script Executable: Ensure the script has executable permissions:
```
chmod +x archmy.sh
```
3. Run the Script: Run the script with superuser privileges to perform administrative tasks:
```
sudo ./archmy.sh
```

# Menu Navigation
Once the script starts, you will be presented with a menu of options:

1. **Enable Chaotic-AUR**:

- Select this option to enable Chaotic-AUR repository.
- It will also refresh your PACMAN cache and perform a system upgrade.

2. **Update Firmware**:

- This will check your system for any available firmware updates and apply them.

3. **Speed Up PACMAN**:

- This option modifies your PACMAN configuration to allow up to 10 simultaneous downloads, speeding up package installations and upgrades.

4. **Enable FlatHub**:

- Enables the FlatHub repo on your system.
- If a ```flatpak-packages.txt``` file is available, it will automatically install the listed Flatpak applications.

5. **Install Software**:

- Installs packages listed in ```pacman-packages.txt```. Ensure this file exists and contains the software packages you wish to install.
(Ensure that chaotic-aur is already configured)

6. **Install Oh-My-Zsh & Starship Prompt**:

- Installs the Zsh shell and Oh-My-Zsh framework, along with the Starship prompt for an enhanced shell experience.

7. **Install Nvidia Drivers**:

- This installs the Nvidia open drivers if your system uses an Nvidia graphics card. (Turing+ only)

8. **Install Timeshift**

- This installs Timeshift with grub menu support & grub customizer. (Btrfs filesystem only)

9. **Install Lazyvim**

- This installs Neovim and it's framework Lazyvim.

10. **Customise**:

- This opens a sub-menu where you can change hostname & setup mullvad-dns resolver:	
	
	1. **Set Hostname**:
  2. **Setup Mullvad-DNS**:

# Customisation Options Breakdown
In the Customise menu, the following actions can be performed:
- **Set Hostname**: Change your machine's hostname to a new value. This requires sudo permissions to apply.
- **Setup Mullvad-DNS**: Change system default DNS resolver to Mullvad-DNS over HTTPS.
***You can also edit any part of this to your own preference***

# Logging and Error Handling
- **Logging**: The script keeps a log of all actions in a file called ```setup_log.txt```. You can refer to this file to track what the script has done or troubleshoot if something goes wrong.

- **Error Handling**: 
If the script encounters an error, it logs the error and notifies you via the terminal and GNOME notifications (if notify-send is available). Ensure to check the log file for more details.

# Notes and Tips
- For custom installations, you can modify the ```pacman-packages.txt``` and ```flatpak-packages.txt``` files to suit your preferences before running the script.
- If you encounter any issues, check the log file (setup_log.txt) for details about what might have gone wrong.
