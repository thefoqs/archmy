#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Please run with sudo or as the root user." 1>&2
   exit 1
fi

# Set PATH
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin

# Dialog dimensions
HEIGHT=20
WIDTH=90
CHOICE_HEIGHT=10

# Titles and messages
BACKTITLE="Archmy v1.0.1 - A Arch Post Install Setup Util for KDE Plasma Enviroment - By thefoqs"
TITLE="Please Make a Selection"
MENU="Please Choose one of the following options:"

# Other variables
OH_MY_ZSH_URL="https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
LOG_FILE="setup_log.txt"

# Log function
log_action() {
    local message=$1
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" | tee -a "$LOG_FILE"
}

# Check for dialog installation
if ! pacman -Q dialog &>/dev/null; then
    sudo pacman -S --noconfirm dialog || { log_action "Failed to install dialog. Exiting."; exit 1; }
    log_action "Installed dialog."
fi

# Options for the menu
OPTIONS=(
    1 "Enable Chaotic-AUR - Enables Chaotic-AUR Repository"
    2 "Update Firmware - For systems that support firmware delivery"
    3 "Speed up Pacman - Sets max parallel downloads to 10"
    4 "Enable Flathub - Enables FlatHub & installs packages located in flatpak-packages.txt"
    5 "Install Software - Installs software located in pacman-packages.txt"
    6 "Install Oh-My-ZSH - Installs Oh-My-ZSH & Starship Prompt"
    7 "Install Timeshift - Installs Timeshift with grub snapshots menu support"
    8 "Install Nvidia Drivers - Install Nvidia Open Drivers (Turing+ only)"
    9 "Install Lazyvim - Neovim framework for lazy people"
    10 "Customise - Configures system settings"
    11 "Quit"
)

# Function to display notifications
notify() {
    local title=$1
    local message=$2
    local expire_time=${2:-10}
    if command -v kdialog &>/dev/null; then
        kdialog --title "$title" --message "$message"
    fi
    log_action "$message"
}

# Function to handle Chaotic-AUR setup
enable_chaotic_aur() {
    echo "Enabling Chaotic-AUR"
    sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
    sudo pacman-key --lsign-key 3056513887B78AEB

    sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
    sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

    cat <<EOF >>/etc/pacman.conf

# includes chaotic-aur repository
[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF

    sudo pacman -Syu
    notify "Chaotic-AUR" "Chaotic-AUR Enabled"
}

# Function to update firmware
update_firmware() {
    echo "Updating System Firmware"
    sudo pacman -S --noconfirm --needed fwupd
    sudo fwupdmgr get-devices
    sudo fwupdmgr refresh --force
    sudo fwupdmgr get-updates
    sudo fwupdmgr update
    notify "Firmware" "System Firmware Updated"
}

# Function to speed up Pacman
speed_up_pacman() {
    echo "Speeding Up Pacman"
    sed 's/ParallelDownloads = 5/ParallelDownloads = 10/' /etc/pacman.conf
    notify "Pacman" "Your Pacman config has now been amended"
}

# Function to enable Flatpak
enable_flatpak() {
    echo "Enabling Flatpak"
    sudo pacman -S --noconfirm --needed flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak update
    if [ -f ./assets/flatpak-install.sh ]; then
        source ./assets/flatpak-install.sh
    else
        log_action "flatpak-install.sh not found"
    fi
    notify "Flatpak" "Flatpak has now been enabled"
}

# Function to install software
install_software() {
    echo "Installing Software"
    if [ -f ./assets/pacman-packages.txt ]; then
        sudo pacman -S --noconfirm --needed - <./assets/pacman-packages.txt
        notify "Software" "Software has been installed"
    else
        log_action "pacman-packages.txt not found"
    fi
}

# Function to install Oh-My-Zsh and Starship
install_oh_my_zsh() {
    echo "Installing Oh-My-Zsh with Starship"
    sudo pacman -S --noconfirm --needed  zsh curl starship
    sudo -u "$SUDO_USER" sh -c "$(curl -fsSL $OH_MY_ZSH_URL)" "" --unattended
    sudo -u "$SUDO_USER" chsh -s "$(which zsh)"
    sudo -u "$SUDO_USER" echo 'eval "$(starship init zsh)"' >> ~/.zshrc
    notify "Oh-My-Zsh" "Oh-My-Zsh is ready to rock n roll"
}

# Funtion to enable timeshift with grub menu support 
install_timeshift() {
    sudo pacman -S --noconfirm --needed timeshift grub-btrfs grub-customizer
    systemctl enable --now grub-btrfsd.service
    systemctl daemon-reload
    notify "Timeshift Install" "Timeshift with grub support was sucessfully installed"
}

# Function to install Nvidia drivers
install_nvidia() {
    echo "Installing Nvidia Open Drivers"
    sudo pacman -S --noconfirm nvidia-open-dkms nvidia-settings
    notify "Nvidia Drivers" "The driver was sucessfully installed"
}

# Function to install Lazyvim
install_lazyvim() {
    if [ -d "$HOME/.config/nvim/" ]; then
      mv ~/.config/nvim{,.bak}
    fi

    if [ -d "$HOME/.local/share/nvim" ]; then 
        mv ~/.local/share/nvim{,.bak}
    fi

    if [-d "$HOME/.local/state/nvim" ]; then
        mv $HOME/.local/state/nvim{,.bak}
    fi
    
    if [ -d "$HOME/.cache/nvim" ]; then
        mv ~/.cache/nvim{,.bak}
    fi
    
    sudo pacman -S --noconfirm --needed - <./assets/lazyvim_packages.txt
    git clone https://github.com/LazyVim/starter $HOME/.config/nvim
    rm -rf $HOME/.config/nvim/.git
}

# Customization Functions
# Function to set the hostname
set_hostname() {
    hostname=$(dialog --inputbox "Enter new hostname:" 10 50 3>&1 1>&2 2>&3 3>&-)
    if [ ! -z "$hostname" ]; then
        sudo hostnamectl set-hostname "$hostname"
        dialog --msgbox "Hostname set to $hostname" 10 50
    else
        dialog --msgbox "Hostname not set. Input was empty." 10 50
    fi
}

# Function to setup Mullvad-DNS over HTTPS
setup_mullvad_dns() {
    systemctl enable systemd-resolved

    cat <<EOF >>/etc/systemd/resolved.conf

[Resolve]

#DNS=194.242.2.2#dns.mullvad.net
#DNS=194.242.2.3#adblock.dns.mullvad.net
DNS=194.242.2.4#base.dns.mullvad.net
#DNS=194.242.2.5#extended.dns.mullvad.net
#DNS=194.242.2.6#family.dns.mullvad.net
#DNS=194.242.2.9#all.dns.mullvad.net
FallbackDNS=194.242.2.2#dns.mullvad.net
DNSSEC=no
DNSOverTLS=yes
Domains=~.
EOF

    ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
    systemctl restart systemd-resolved
    systemctl restart NetworkManager
    sleep 5
    resolvectl status
}

# Main loop
check_permissions  # Ensure the script is run with appropriate permissions
while true; do
    CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --nocancel \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

    clear
    case $CHOICE in
        1) enable_chaotic_aur ;;
        2) update_firmware ;;
        3) speed_up_pacman ;;
        4) enable_flatpak ;;
        5) install_software ;;
        6) install_oh_my_zsh ;;
        7) install_timeshift ;;
        8) install_nvidia ;;
        9) install_lazyvim ;;
        10)
            # Customization menu
            while true; do
                CUSTOM_CHOICE=$(dialog --clear --backtitle "Arch System Configuration" \
                    --title "Customization Menu" \
                    --menu "Choose an option:" 15 50 8 \
                    1 "Set Hostname" \
                    2 "Setup Mullvad-DNS" \
                    3 "Exit" \
                    3>&1 1>&2 2>&3)
                
                case $CUSTOM_CHOICE in
                    1) set_hostname ;;
                    2) setup_mullvad_dns ;;
                    3) break ;;
                    *) dialog --msgbox "Invalid option. Please try again." 10 50 ;;
                esac
            done
            ;;
        11) log_action "User chose to quit the script."; exit 0 ;;
        *) log_action "Invalid option selected: $CHOICE";;
    esac
done

