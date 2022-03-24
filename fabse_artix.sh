#!/usr/bin/bash

# Parameters

  BEGINNER_DIR=$(pwd)

#----------------------------------------------------------------------------------------------------------------------------------

# Package-installation
  
  cd packages || exit
  POLKIT="$(ls -- *polkit-*)"
  doas pacman --noconfirm -U $POLKIT
  doas pacman --noconfirm --needed -Syyu virt-manager qemu edk2-ovmf dnsmasq vde2 bridge-utils openbsd-netcat dnsmasq nss-mdns pcmanfm-gtk3 \
                                         iso-profiles avogadrolibs sagemath arduino-cli arduino-avr-core geogebra kalzium geany-plugins geany \
                                         step libreoffice-fresh qutebrowser thunderbird obs-studio freecad mousepad openshot links playerctl \
                                         bitwarden pacman-contrib foliate easyeffects gimp gnuplot librewolf zathura zathura-pdf-mupdf wayland \
                                         gnome-mahjongg gnome-calculator foot moc mpv artools handlr sway i3status-rust swayidle swappy kicad \
                                         bemenu-wayland qt5-wayland qt6-wayland kvantum-qt5 phonon-qt5-gstreamer pipewire-alsa kicad-library-3d \
                                         pipewire-pulse wireplumber libpipewire02 wine-staging zsh zsh-theme-powerlevel10k zsh-autosuggestions \
                                         zsh-syntax-highlighting texlive-most shellcheck brightnessctl mako libnotify vimiv aisleriot ripgrep \
                                         bsd-games mypaint android-tools ffmpegthumbs man-db gvfs gvfs-mtp wallutils tumbler xarchiver fzf go \
                                         bashtop nnn dialog alsa-utils bottom ld-lsb imv xdg-desktop-portal-kde xdg-desktop-portal-wlr lsd \
                                         tar xz python-sphinx python-sphinx_rtd_theme python-pywal graphviz imagemagick xmlto pahole figlet \
                                         cpio perl unrar unzip rsync wget jdk-openjdk meson clang nodejs python python-pip rclone rust pipewire \
                                         linux-lts linux-lts-headers vulkan-intel libva-intel-driver lib32-vulkan-intel ttf-opensans kicad-library \
                                         ttf-font-awesome noto-fonts-emoji ttf-iosevka-nerd ttf-nerd-fonts-symbols cups-pdf cups-dinit tlp-dinit \
                                         syncthing-dinit lm_sensors-dinit avahi-dinit intel-undervolt-dinit thermald-dinit cpupower-dinit libvirt-dinit
  cd $BEGINNER_DIR || exit
                                      
#----------------------------------------------------------------------------------------------------------------------------------

# Installation of packages from AUR

  wget https://aur.archlinux.org/packages/dot-bin
  if ! grep -q "Flagged out-of-date" dot-bin; then
    AUR="dot-bin"
  fi
  paru --cleanafter --removemake --noconfirm --useask -S stm32cubemx nuclear-player-bin sworkstyle kvantum-theme-sweet-mars-git nodejs-reveal-md \
                                                         avogadroapp bibata-rainbow-cursor-theme candy-icons-git tela-icon-theme wlsunset bastet \
                                                         sweet-gtk-theme-dark otf-openmoji sunwait-git sway-launcher-desktop waylock-git nudoku \
                                                         freshfetch-bin cbonsai osp-tracker macchina revolt-desktop lutris-git river-noxwayland-git \
                                                         wayshot-bin rivercarro-git ventoy-bin rofi-lbonn-wayland clipman yambar $AUR                    
  paru -Scd --noconfirm
  doas archlinux-java set java-17-openjdk

#----------------------------------------------------------------------------------------------------------------------------------

# Dinit-services

  for service in cups syncthing lm_sensors cpupower intel-undervolt tlp thermald avahi-daemon libvirtd virtlogd; do
    doas ln -s /etc/dinit.d/$service /etc/dinit.d/boot.d
  done
  doas sensors-detect --auto
  doas usermod -a -G libvirt,games fabse
  doas sed -i -e '/unix_sock_group = "libvirt"/s/^#//' /etc/libvirt/libvirtd.conf
  doas sed -i -e '/unix_sock_rw_perms = "0770"/s/^#//' /etc/libvirt/libvirtd.conf
  doas sed -i "s/#user = "root"/user = "fabse"/" /etc/libvirt/qemu.conf	
  doas sed -i "s/#group = "root"/group = "fabse"/" /etc/libvirt/qemu.conf	

#----------------------------------------------------------------------------------------------------------------------------------

# Default apps

  handlr add .pdf org.pwmt.zathura.desktop
  handlr add .png vimiv.desktop
  handlr add .jpeg vimiv.desktop

#----------------------------------------------------------------------------------------------------------------------------------

# Default shell

  doas chsh -s /usr/bin/zsh fabse
  doas chsh -s /usr/bin/zsh root

#----------------------------------------------------------------------------------------------------------------------------------

# Grub-theme

  git clone https://github.com/vinceliuice/grub2-themes.git
  cd grub2-themes || return
  doas ./install.sh -b
  cd $BEGINNER_DIR || return
  rm -rf grub2-themes

#----------------------------------------------------------------------------------------------------------------------------------

# Installing dotfiles

  git clone https://gitlab.com/FabseGP02/personal-setups.git
  cd personal-setups
  cp -r .config/* /home/fabse/.config/
  rm -rf /home/fabse/.config/zsh
  cp -r {librewolf,scripts,wallpapers} /home/fabse
  chmod u+x /home/fabse/scripts/*
  cp -r .local /home/fabse
  mkdir -p /home/fabse/.local/{bin,share/fonts}
  cp .* /home/fabse  
  curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
  cp -r .config/zsh/.zim/* /home/fabse/.config/zsh/.zim
  cp -r .config/zsh/{.zlogin,.zlogout,.zshrc,.zshenv} /home/fabse/.config/zsh
  doas cp -r etc/* /etc
  doas intel-undervolt apply
  cd $BEGINNER_DIR || return

#----------------------------------------------------------------------------------------------------------------------------------

# Miscellaneous

  doas sed -i 's/Exec="\/opt\/nuclear\/nuclear" %U/Exec="\/opt\/nuclear\/nuclear" %U --enable-features=UseOzonePlatform --ozone-platform=wayland/' /usr/share/applications/nuclear.desktop
  curl -fsSL https://raw.githubusercontent.com/JackHack96/PulseEffects-Presets/master/install.sh > install.sh
  chmod u+x install.sh
  echo "1" | ./install.sh
  cat << EOF | doas tee -a /etc/issue > /dev/null
This object that you, sir, are using is property of Fabse Inc. - expect therefore puns! 

EOF
