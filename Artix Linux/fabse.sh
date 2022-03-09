#!/usr/bin/bash

#----------------------------------------------------------------------------------------------------------------------------------

# Correct start + passwordless + hdd-mount

  read -rp "Is the script executed as bash -i /script/path? Is alias yay=paru added to .bashrc? " hello
  echo
  lsblk
  echo
  echo "--------------------------------------------------------------------------------------------------"
  echo "-------------Which device is to be mounted? Please only enter the part after \"/dev/\"--------------"
  echo "--------------------------------------------------------------------------------------------------"
  echo
  read -r DRIVE
  echo 'permit nopass fabse' | doas tee -a /etc/doas.conf > /dev/null
  BACKUP_FOLDER="/mnt/Backups/Fabse-s_Lenovo_Yoga_720/Latest/*"
  doas mount /dev/"$DRIVE" /mnt
  doas cp -r "$BACKUP_FOLDER" /home/fabse
  doas umount /mnt
  doas chown -R fabse:wheel /home/fabse/{Baggrunde,Billeder,Diverse,Documents,Konfiguration,Musik,Pictures,Skærmbilleder,Syncthing-backups,Videoklip,Virtualbox_images}
  doas rm -rf /install_script
  
#-----------------------------------------------------------------------------------------------------------------+-----------------

# Package-installation; plasma = ^1 ^2 ^3 ^4 ^26 ^29 ^32 ^38 ^39 ^43 ^44 
  
  yes | doas pacman -S ebtables
  doas pacman --noconfirm -Syyu virt-manager qemu edk2-ovmf dnsmasq vde2 bridge-utils openbsd-netcat pcmanfm-gtk3 iso-profiles \
                                avogadrolibs sagemath jupyterlab arduino-cli arduino-avr-core geogebra kalzium geany geany-plugins \
                                step libreoffice-fresh qutebrowser thunderbird obs-studio freecad mousepad openshot terminator fzf \
                                bitwarden pacman-contrib foliate easyeffects gimp gnuplot lutris librewolf zathura zathura-pdf-mupdf \
                                gnome-mahjongg gnome-calculator foot moc mpv grim artools sway i3status-rust swayidle swappy wayland \
                                bemenu-wayland qt5-wayland qt6-wayland kvantum-qt5 phonon-qt5-gstreamer go pipewire pipewire-alsa \
                                pipewire-pulse wireplumber libpipewire02 wine-staging zsh zsh-theme-powerlevel10k zsh-autosuggestions \
                                zsh-syntax-highlighting texlive-most shellcheck brightnessctl dunst libnotify links gthumb aisleriot \
                                bsd-games mypaint android-tools figlet ffmpegthumbs man-db gvfs gvfs-mtp wallutils tumbler xarchiver\
                                bashtop nnn dialog alsa-utils bottom ld-lsb lsd imv xdg-desktop-portal-kde xdg-desktop-portal-wlr \
                                x86_energy_perf_policy tar xz asciinema python-sphinx python-sphinx_rtd_theme python-pywal graphviz \
                                imagemagick xmlto pahole cpio perl unrar unzip rsync curl wget jdk-openjdk meson clang nodejs python3 \
                                python-pip rclone rust linux-lts linux-lts-headers dnsmasq nss-mdns vulkan-intel libva-intel-driver \
                                lib32-vulkan-intel ttf-opensans otf-font-awesome noto-fonts-emoji ttf-iosevka-nerd cups-filters cups-pdf \
                                cups-dinit nftables-dinit syncthing-dinit lm_sensors-dinit tlp-dinit intel-undervolt-dinit \
                                avahi-dinit thermald-dinit cpupower-dinit libvirt-dinit 
  doas pacman --noconfirm -S kicad kicad-library kicad-library-3d xorg-xwayland xorg-xlsclients
  doas pacman --noconfirm -Rdd polkit elogind
 
#----------------------------------------------------------------------------------------------------------------------------------

# Installation of packages from AUR

  doas cp configs/makepkg.conf /etc/makepkg.conf
  mkdir -p /home/fabse/Downloads
  paru --cleanafter --useask -S stm32cubemx nuclear-player-bin sworkstyle kvantum-theme-sweet-mars-git nodejs-reveal-md \
                                avogadroapp bibata-rainbow-cursor-theme candy-icons-git tela-icon-theme wl-gammarelay \
                                sweet-gtk-theme-dark otf-openmoji sunwait-git sway-launcher-desktop swaylock-fancy-git \
                                bastet freshfetch-bin cbonsai nudoku clipman osp-tracker macchina revolt-desktop toilet \
                                handlr-bin river                         
  yay -Scd
  doas archlinux-java set java-17-openjdk

#----------------------------------------------------------------------------------------------------------------------------------

# Dinit + intel-undervolt + hostname resolution + snapper + virtual machine + tty login prompt + firecfg + git-lfs

  doas dinitctl enable cupsd
  doas dinitctl enable syncthing
  doas dinitctl enable nftables
  doas dinitctl enable lm_sensors
  doas dinitctl enable cpupower
  doas dinitctl enable intel-undervolt
  doas dinitctl enable tlp
  doas dinitctl enable thermald
  doas dinitctl enable avahi-daemon
  doas dinitctl enable libvirtd
  doas dinitctl enable virtlogd
  doas sensors-detect --auto
  doas dinitctl start intel-undervolt
  doas dinitctl start avahi-daemon
  doas cp configs/intel-undervolt.conf /etc/intel-undervolt.conf
  doas intel-undervolt apply
  doas usermod -a -G libvirt fabse
  doas usermod -a -G games fabse
  doas sed -i -e '/unix_sock_group = "libvirt"/s/^#//' /etc/libvirt/libvirtd.conf
  doas sed -i -e '/unix_sock_rw_perms = "0770"/s/^#//' /etc/libvirt/libvirtd.conf
  doas sed -i 's/#user = "root"/user = "fabse"/' /etc/libvirt/qemu.conf	
  doas sed -i 's/#group = "root"/group = "fabse"/' /etc/libvirt/qemu.conf	
  cat << EOF | doas tee -a /etc/issue > /dev/null
This object that you, sir, are using is property of Fabse Inc. - expect therefore puns! 

EOF

#----------------------------------------------------------------------------------------------------------------------------------

# Default apps + config + extra

  handlr add .pdf org.pwmt.zathura.desktop
  handlr add .png imv.desktop
  handlr add .jpeg imv.desktop
  mkdir -p /home/fabse/.config/zathura
  touch /home/fabse/.config/zathura/zathurarc
  cat << EOF | doas tee -a /home/fabse/.config/zathura/zathurarc > /dev/null
# Copy to clipboard
  set selection-clipboard clipboard
  
EOF
  mkdir /home/fabse/.config/artools

#----------------------------------------------------------------------------------------------------------------------------------

# ZSH-theme + fonts + ZSH-config (wayland-related) + more wayland-stuff

  doas chsh -s /usr/bin/zsh fabse
  doas chsh -s /usr/bin/zsh root
  touch /home/fabse/.zshenv
  touch /home/fabse/.zshrc
  touch /home/fabse/.zhistory
  touch /home/fabse/.gtk-bookmarks
  cat << EOF | tee -a /home/fabse/.zshenv > /dev/null
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:/usr/local/bin"
fi

export MOZ_ENABLE_WAYLAND=1
export SDL_VIDEODRIVER=wayland
export _JAVA_AWT_WM_NONREPARENTING=1
export EDITOR="nvim"
export VISUAL="nvim"
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=sway
export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORMTHEME=qt5ct
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export HISTFILE="home/fabse/.zhistory"    # History filepath
export HISTSIZE=10000                   # Maximum events for internal history
export SAVEHIST=10000                   # Maximum events in history file

EOF
  cat << EOF | tee -a /home/fabse/.zshrc > /dev/null
autoload -U compinit; compinit
zstyle ':completion::complete:*' gain-privileges 1

exit_zsh() { exit }
zle -N exit_zsh
bindkey '^D' exit_zsh

_comp_options+=(globdots) # With hidden files

cbonsai -p

bindkey -v
export KEYTIMEOUT=1

source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

alias fabse="macchina"
alias rm="rm -i"
alias "rm -r"="rm -i"
alias "rm -f"="rm -i"
alias "rm -rf"="rm -i"
alias yay="paru"
alias sway="dbus-run-session sway"

EOF
  cat << EOF | tee -a /etc/environment > /dev/null
# By Fabse
export MOZ_ENABLE_WAYLAND=1
export SDL_VIDEODRIVER=wayland
export _JAVA_AWT_WM_NONREPARENTING=1
export EDITOR="nvim"
export VISUAL="nvim"
export XDG_SESSION_TYPE=wayland
export QT_QPA_PLATFORM=wayland
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export HISTFILE="home/fabse/.zhistory"    # History filepath
export HISTSIZE=10000                   # Maximum events for internal history
export SAVEHIST=10000                   # Maximum events in history file

EOF
  mkdir ~/.local/share/fonts
  touch /home/fabse/.config/electron-flags.conf
  cat << EOF | tee -a /home/fabse/.config/electron-flags.conf > /dev/null
# Wayland-support
--enable-features=UseOzonePlatform
--ozone-platform=wayland

EOF
  doas sed -i 's/Exec="\/opt\/nuclear\/nuclear" %U/Exec="\/opt\/nuclear\/nuclear" %U --enable-features=UseOzonePlatform --ozone-platform=wayland/' /usr/share/applications/nuclear.desktop

#----------------------------------------------------------------------------------------------------------------------------------

# Grub-theme

  git clone https://github.com/vinceliuice/grub2-themes.git
  cd grub2-themes || return
  doas ./install.sh -b
  cd /home/fabse/personal-setups/Artix\ Linux/ || return
  rm -rf grub2-themes

#----------------------------------------------------------------------------------------------------------------------------------

# Easyeffects-presets 
  
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/JackHack96/PulseEffects-Presets/master/install.sh)"

#----------------------------------------------------------------------------------------------------------------------------------

# Firefox-theme

  mkdir -p /home/fabse/firefox/chrome 
  mv firefox/chrome/user* /home/fabse/firefox/chrome

#----------------------------------------------------------------------------------------------------------------------------------

# Sway-related

  mkdir -p /home/fabse/.config/{river,sway,swappy,dunst,i3status-rust,foot,macchina/ascii}
  mkdir -p /home/fabse/.local/share/macchina/themes
  mkdir /home/fabse/Scripts
  cp -r sway/sway /home/fabse/.config/sway/config
  cp -r sway/river /home/fabse/.config/river/config
  cp -r sway/swappy /home/fabse/.config/swappy/config
  cp -r sway/dunst /home/fabse/.config/dunst/dunstrc
  cp -r sway/i3status /home/fabse/.config/i3status-rust/config.toml
  cp -r sway/macchina.toml /home/fabse/.config/macchina/macchina.toml
  cp -r sway/macchina.style /home/fabse/.local/share/macchina/themes/fabse.json
  cp -r sway/macchina.ascii /home/fabse/.config/macchina/ascii/fabse.ascii
  cp -r sway/foot /home/fabse/.config/foot/foot.ini
  git clone https://github.com/hexive/sunpaper.git
  mv -f sunpaper /home/fabse
  rm -rf /home/fabse/sunpaper/{extra,.git,README.md,screenshots}
  cp -r sway/sunpaper.sh /home/fabse/Scripts
  chmod u+x /home/fabse/Scripts/*
  mkdir -p /home/fabse/.config/{gtk-3.0,gtk-4.0}
  touch /home/fabse/.config/gtk-3.0/settings.ini
  touch /home/fabse/.config/gtk-4.0/settings.ini
  cat << EOF | tee -a /home/fabse/.config/gtk-3.0/settings.ini > /dev/null
[Settings]
gtk-application-prefer-dark-theme=true
gtk-enable-animations=true
gtk-enable-event-sounds=0
gtk-enable-input-feedback-sounds=0
EOF
  cat << EOF | tee -a /home/fabse/.config/gtk-4.0/settings.ini > /dev/null
[Settings]
gtk-application-prefer-dark-theme=true
gtk-enable-animations=true
gtk-enable-event-sounds=0
gtk-enable-input-feedback-sounds=0
EOF
  doas sed -i '/permit nopass fabse/d' /etc/doas.conf
