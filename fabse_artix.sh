#!/usr/bin/bash

# Parameters

  BEGINNER_DIR=$(pwd)

#----------------------------------------------------------------------------------------------------------------------------------

# Package-installation
  
  doas pacman --noconfirm --needed -Syyu virt-manager qemu edk2-ovmf dnsmasq vde2 bridge-utils openbsd-netcat dnsmasq nss-mdns pcmanfm-gtk3 \
                                         iso-profiles avogadrolibs sagemath arduino-cli arduino-avr-core geogebra kalzium geany geany-plugins \
                                         step libreoffice-fresh qutebrowser thunderbird obs-studio freecad mousepad openshot terminator fzf pipewire \
                                         bitwarden pacman-contrib foliate easyeffects gimp gnuplot librewolf zathura zathura-pdf-mupdf wayland \
                                         gnome-mahjongg gnome-calculator foot moc mpv artools handlr sway i3status-rust swayidle swappy kicad \
                                         bemenu-wayland qt5-wayland qt6-wayland kvantum-qt5 phonon-qt5-gstreamer pipewire-alsa kicad-library-3d \
                                         pipewire-pulse wireplumber libpipewire02 wine-staging zsh zsh-theme-powerlevel10k zsh-autosuggestions \
                                         zsh-syntax-highlighting texlive-most shellcheck brightnessctl dunst libnotify links vimiv aisleriot \
                                         bsd-games mypaint android-tools figlet ffmpegthumbs man-db gvfs gvfs-mtp wallutils tumbler xarchiver\
                                         bashtop nnn dialog alsa-utils bottom ld-lsb lsd imv xdg-desktop-portal-kde xdg-desktop-portal-wlr go \
                                         tar xz asciinema python-sphinx python-sphinx_rtd_theme python-pywal graphviz imagemagick xmlto pahole \
                                         cpio perl unrar unzip rsync wget jdk-openjdk meson clang nodejs python python-pip rclone rust kicad-library \
                                         linux-lts linux-lts-headers vulkan-intel libva-intel-driver lib32-vulkan-intel ttf-opensans $PACKAGES \
                                         otf-font-awesome noto-fonts-emoji ttf-iosevka-nerd ttf-nerd-fonts-symbols cups-pdf cups-dinit \
                                         syncthing-dinit lm_sensors-dinit tlp-dinit avahi-dinit intel-undervolt-dinit thermald-dinit \
                                         cpupower-dinit libvirt-dinit
  doas pacman --noconfirm -Rdd polkit elogind
 
#----------------------------------------------------------------------------------------------------------------------------------

# Installation of packages from AUR

  wget https://aur.archlinux.org/packages/dot-bin
  if ! grep -q "Flagged out-of-date" dot-bin; then
    AUR="dot-bin"
  fi
  rm -rf dot-bin
  paru --cleanafter --noconfirm --useask -S stm32cubemx nuclear-player-bin sworkstyle kvantum-theme-sweet-mars-git nodejs-reveal-md \
                                            avogadroapp bibata-rainbow-cursor-theme candy-icons-git tela-icon-theme wl-gammarelay \
                                            sweet-gtk-theme-dark otf-openmoji sunwait-git sway-launcher-desktop swaylock-fancy-git \
                                            bastet freshfetch-bin cbonsai nudoku clipman osp-tracker macchina revolt-desktop toilet \
                                            river-noxwayland-git wayshot-bin lutris-git $AUR                    
  paru -Scd --noconfirm
  doas archlinux-java set java-17-openjdk

#----------------------------------------------------------------------------------------------------------------------------------

# Dinit-services

  doas dinitctl enable cupsd
  doas dinitctl enable syncthing
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
  doas cp configs/intel-undervolt.conf /etc/intel-undervolt.conf
  doas intel-undervolt apply
  doas usermod -a -G libvirt,games $(whoami)
  doas sed -i -e '/unix_sock_group = "libvirt"/s/^#//' /etc/libvirt/libvirtd.conf
  doas sed -i -e '/unix_sock_rw_perms = "0770"/s/^#//' /etc/libvirt/libvirtd.conf
  doas sed -i "s/#user = "root"/user = "$(whoami)"/" /etc/libvirt/qemu.conf	
  doas sed -i "s/#group = "root"/group = "$(whoami)"/" /etc/libvirt/qemu.conf	

#----------------------------------------------------------------------------------------------------------------------------------

# Default apps

  handlr add .pdf org.pwmt.zathura.desktop
  handlr add .png vimiv.desktop
  handlr add .jpeg vimiv.desktop

#----------------------------------------------------------------------------------------------------------------------------------

# Default shell

  doas chsh -s /usr/bin/zsh $(whoami)
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



#----------------------------------------------------------------------------------------------------------------------------------

# Miscellaneous

  doas sed -i 's/Exec="\/opt\/nuclear\/nuclear" %U/Exec="\/opt\/nuclear\/nuclear" %U --enable-features=UseOzonePlatform --ozone-platform=wayland/' /usr/share/applications/nuclear.desktop
  curl -fsSL https://raw.githubusercontent.com/JackHack96/PulseEffects-Presets/master/install.sh > install.sh
  chmod u+x install.sh
  echo "1" | ./install.sh
  cat << EOF | doas tee -a /etc/issue > /dev/null
This object that you, sir, are using is property of Fabse Inc. - expect therefore puns! 

EOF
