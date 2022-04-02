#!/usr/bin/bash

# Parameters

  BEGINNER_DIR=$(pwd)

#----------------------------------------------------------------------------------------------------------------------------------

# Package-installation
  
  cd packages || exit
  WIREPLUMBER="$(ls -- *wireplumber-*)"
  doas pacman --noconfirm --needed -U $WIREPLUMBER
  doas pacman --noconfirm --needed -Syu virt-manager qemu edk2-ovmf dnsmasq vde2 bridge-utils dnsmasq nss-mdns pcmanfm-gtk3 geany bat \
                                        iso-profiles avogadrolibs sagemath arduino-cli arduino-avr-core geogebra geany-plugins alacritty \
                                        libreoffice-fresh qutebrowser thunderbird obs-studio freecad mousepad openshot elinks pavucontrol \
                                        bitwarden foliate easyeffects gimp gnuplot librewolf zathura zathura-pdf-mupdf kicad-library-3d \
                                        gnome-mahjongg gnome-calculator foot moc mpv artools handlr sway i3status-rust swayidle swappy \
                                        bemenu-wayland qt5-wayland qt6-wayland kvantum-qt5 phonon-qt5-gstreamer pipewire-alsa wayland zsh \
                                        pipewire-pulse pipewire-jack wine-staging zsh-theme-powerlevel10k zsh-autosuggestions mako jq wget \
                                        zsh-syntax-highlighting texlive-most shellcheck brightnessctl libnotify aisleriot kicad syncthing \
                                        bsd-games mypaint android-tools man-db gvfs gvfs-mtp wallutils tumbler xarchiver fzf go figlet \
                                        bashtop nnn alsa-utils bottom ld-lsb xdg-desktop-portal-wlr lsd wofi pipewire kicad-library rust \
                                        tar xz python-sphinx python-sphinx_rtd_theme python-pywal graphviz imagemagick xmlto pahole neovim \
                                        cpio perl unrar unzip rsync jdk-openjdk meson clang nodejs boost python python-pip rclone zenity \
                                        linux-lts linux-lts-headers vulkan-intel libva-intel-driver lib32-vulkan-intel ttf-opensans playerctl \
                                        ttf-font-awesome noto-fonts-emoji ttf-iosevka-nerd ttf-nerd-fonts-symbols cups-pdf cups-dinit tlp-dinit \
                                        lm_sensors-dinit avahi-dinit intel-undervolt-dinit thermald-dinit libvirt-dinit
                                      
#----------------------------------------------------------------------------------------------------------------------------------

# Installation of packages from AUR

  wget https://aur.archlinux.org/packages/dot-bin
  if ! grep -q "Flagged out-of-date" dot-bin; then
    AUR="dot-bin"
  fi
  paru --noconfirm -Syu
  PIPES_1="$(ls -- *bash-pipes-*)"
  BASTET="$(ls -- *bastet-*)"
  BIBATA="$(ls -- *bibata-*)"
  CANDY="$(ls -- *candy-*)"
  CBONSAI="$(ls -- *cbonsai-*)"
  NUDOKU="$(ls -- *nudoku-*)"
  PIPES_2="$(ls -- *pipes.sh-*)"
  POKEMON="$(ls -- *pokemon-*)"
  SUNWAIT="$(ls -- *sunwait-*)"
  SWEET_GTK="$(ls -- *sweet-gtk-*)"
  SWEET_QT="$(ls -- *sweet-kde-*)"
  TELA="$(ls -- *tela-*)"
  TOKYONIGHT="$(ls -- *neovim-*)"
  TTF_POWER="$(ls -- *ttf-*)"
  doas pacman --noconfirm --needed -U $PIPES_1 $BASTET $BIBATA $CANDY $CBONSAI $NUDOKU $PIPES_2 \
                                      $POKEMON $SUNWAIT $SWEET_GTK $SWEET_QT $TELA $TOKYONIGHT $TTF_POWER
  cd $BEGINNER_DIR || exit
  paru --cleanafter --removemake --noconfirm --useask -S stm32cubemx nuclear-player-bin sworkstyle nodejs-reveal-md wlsunset clipman \
                                                         otf-openmoji sunwait-git sway-launcher-desktop swaylock-effects-git macchina \
                                                         revolt-desktop lutris-git river-noxwayland-git vimiv-qt-git avogadroapp yambar \
                                                         wayshot-bin rivercarro-git ventoy-bin $AUR                    
  paru -Scd --noconfirm
  doas archlinux-java set java-17-openjdk

#----------------------------------------------------------------------------------------------------------------------------------

# Dinit-services

  for service in cupsd lm_sensors intel-undervolt tlp thermald avahi-daemon libvirtd virtlogd; do
    doas ln -s /etc/dinit.d/$service /etc/dinit.d/boot.d
  done
  doas sensors-detect --auto
  doas usermod -a -G libvirt,games fabse
  doas sed -i -e '/unix_sock_group = "libvirt"/s/^#//' /etc/libvirt/libvirtd.conf
  doas sed -i -e '/unix_sock_rw_perms = "0770"/s/^#//' /etc/libvirt/libvirtd.conf	

#----------------------------------------------------------------------------------------------------------------------------------

# Default apps

  handlr add .pdf org.pwmt.zathura.desktop
  handlr add .png vimiv.desktop
  handlr add .jpeg vimiv.desktop

#----------------------------------------------------------------------------------------------------------------------------------

# Default shell

  doas usermod --shell /usr/bin/zsh fabse
  doas usermod --shell /usr/bin/zsh root

#----------------------------------------------------------------------------------------------------------------------------------

# Grub-theme

  git clone https://github.com/vinceliuice/grub2-themes.git
  cd grub2-themes || return
  doas ./install.sh -b
  cd $BEGINNER_DIR || return

#----------------------------------------------------------------------------------------------------------------------------------

# Installing dotfiles

  cp -r .config/* /home/fabse/.config/
  mkdir /home/fabse/.config/zsh/.zim
  rm -rf /home/fabse/.config/rsnapshot
  cp -r {librewolf,wallpapers} /home/fabse
  cp -r scripts/artix /home/fabse/scripts
  chmod u+x /home/fabse/scripts/*
  chmod u+x /home/fabse/.config/{river/init,yambar/{cpu.sh,weather.sh,playerctl/*},sway/scripts/*}
  cp -r .local /home/fabse
  mkdir -p /home/fabse/{Skærmbilleder,.local/bin}
  fc-cache -f -v 
  doas cp -r etc/* /etc
  doas intel-undervolt apply
  git clone https://github.com/hexive/sunpaper.git
  mkdir /home/fabse/wallpapers/sunpaper
  cp -r sunpaper/images/* /home/fabse/wallpapers/sunpaper
  if [[ -d "/home/fabse/.librewolf" ]]; then
    rm -rf /home/fabse/.librewolf
  fi
  cd librewolf || exit
  tar -xvf librewolf-browser-profile.tar.bz2 -C /home/fabse
  cd $BEGINNER_DIR || return
  if ! [[ -d "/etc/pipewire" ]]; then
    doas mkdir /etc/pipewire
  fi
  doas cp /usr/share/pipewire/pipewire.conf /etc/pipewire
  doas sed -i 's/#{ path = "\/usr\/bin\/pipewire" args = "-c pipewire-pulse.conf" }/{ path = "\/usr\/bin\/pipewire" args = "-c pipewire-pulse.conf" }/' /etc/pipewire/pipewire.conf
  doas sed -i '/{ path = "\/usr\/bin\/pipewire" args = "-c pipewire-pulse.conf" }/a { path = "wireplumber"  args = "" }' /etc/pipewire/pipewire.conf
  pacman -Q > hejsa.txt
  grep -F "electron" hejsa.txt > hejhej.txt
  hej=${s%% *}
  while read line; do
    hej=${line%% *}
    cp /home/fabse/.config/electron-flags.conf /home/fabse/.config/$hej-flags.conf
  done < hejhej.txt

#----------------------------------------------------------------------------------------------------------------------------------

# Miscellaneous

  git clone https://github.com/niizam/vantage.git
  cd vantage || exit
  chmod u+x install.sh
  doas ./install.sh
  doas sed -i 's/Exec="\/opt\/nuclear\/nuclear" %U/Exec="\/opt\/nuclear\/nuclear" %U --enable-features=UseOzonePlatform --ozone-platform=wayland/' /usr/share/applications/nuclear.desktop
  curl -fsSL https://raw.githubusercontent.com/JackHack96/PulseEffects-Presets/master/install.sh > install.sh
  chmod u+x install.sh
  echo "1" | ./install.sh
  cat << EOF | doas tee -a /etc/issue > /dev/null
This object that you, sir, are using is property of Fabse Inc. - expect therefore puns! 

EOF
  doas pacman --noconfirm -Syu
