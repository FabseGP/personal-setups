#!/usr/bin/bash

# Parameters

  BEGINNER_DIR=$(pwd)
  MODE="$1"
  if ! grep -qF "permit nopass $(whoami)" /etc/doas.conf; then
    cat << EOF | doas tee -a /etc/doas.conf > /dev/null
      permit nopass $(whoami)
EOF
  fi

#----------------------------------------------------------------------------------------------------------------------------------

# Package-installation
  
  cd packages || exit
  WIREPLUMBER="$(ls -- *wireplumber-*)"
  doas pacman --noconfirm --needed -U $WIREPLUMBER
  doas pacman --noconfirm --needed -Syu pcmanfm-gtk3 bat alacritty libreoffice-fresh pavucontrol playerctl zsh wayland \
                                        bitwarden easyeffects librewolf zathura zathura-pdf-mupdf elinks pahole swappy \
                                        gnome-mahjongg galculator foot moc mpv handlr sway i3status-rust swayidle wget \
                                        bemenu-wayland qt5-wayland qt6-wayland kvantum-qt5 phonon-qt5-gstreamer pipewire-alsa \
                                        pipewire-pulse pipewire-jack zsh-theme-powerlevel10k zsh-autosuggestions mako jq \
                                        zsh-syntax-highlighting shellcheck brightnessctl libnotify aisleriot helix vulkan-intel \
                                        bsd-games mypaint man-db gvfs gvfs-mtp wallutils tumbler xarchiver fzf figlet zenity \
                                        bashtop nnn alsa-utils bottom ld-lsb xdg-desktop-portal-wlr lsd wofi pipewire rclone \
                                        tar xz python-sphinx python-sphinx_rtd_theme python-pywal graphviz imagemagick xmlto \
                                        cpio perl unrar unzip rsync jdk-openjdk python python-pip libva-intel-driver ttf-opensans \
                                        lib32-vulkan-intel ttf-font-awesome noto-fonts-emoji ttf-iosevka-nerd ttf-nerd-fonts-symbols \
                                        tlp-dinit lm_sensors-dinit thermald-dinit openssh-dinit
  if ! [[ "$MODE" == "MINIMAL" ]]; then
    doas pacman --noconfirm --needed -S virt-manager qemu edk2-ovmf dnsmasq vde2 bridge-utils dnsmasq nss-mdns geany iso-profiles gimp rust \
                                        avogadrolibs sagemath arduino-cli arduino-avr-core geogebra geany-plugins qutebrowser thunderbird \
                                        obs-studio freecad openshot foliate gnuplot kicad-library-3d artools wine-staging texlive-most go \
                                        kicad syncthing android-tools kicad-library linux-lts linux-lts-headers meson clang nodejs boost \
                                        cups-pdf cups-dinit avahi-dinit libvirt-dinit
  fi
  if grep -q Intel "/proc/cpuinfo"; then # Poor soul :(
    doas pacman --noconfirm --needed -S intel-undervolt-dinit
  elif grep -q AMD "/proc/cpuinfo"; then
    :
  fi
                                      
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
  paru --cleanafter --removemake --noconfirm --useask -S nuclear-player-bin sworkstyle wlsunset clipman otf-openmoji sunwait-git \
                                                         sway-launcher-desktop swaylock-effects-git macchina-bin revolt-desktop yambar \
                                                         lutris-git river-noxwayland-git vimiv-qt-git wayshot-bin rivercarro-git $AUR                                                                             
  if ! [[ "$MODE" == "MINIMAL" ]]; then
    paru --cleanafter --removemake --noconfirm --useask -S stm32cubemx nodejs-reveal-md avogadroapp ventoy-bin logseq-desktop-bin
  fi
  paru -Scd --noconfirm
  doas archlinux-java set java-17-openjdk

#----------------------------------------------------------------------------------------------------------------------------------

# Dinit-services

  for service in lm_sensors tlp thermald sshd; do
    doas ln -s /etc/dinit.d/$service /etc/dinit.d/boot.d
  done
  if ! [[ "$MODE" == "MINIMAL" ]]; then
    for service in cupsd intel-undervolt avahi-daemon libvirtd virtlogd; do
      doas ln -s /etc/dinit.d/$service /etc/dinit.d/boot.d
    done
    doas usermod -a -G libvirt,games $(whoami)
    doas sed -i -e '/unix_sock_group = "libvirt"/s/^#//' /etc/libvirt/libvirtd.conf
    doas sed -i -e '/unix_sock_rw_perms = "0770"/s/^#//' /etc/libvirt/libvirtd.conf
  fi   
  if grep -q Intel "/proc/cpuinfo"; then # Poor soul :(
    doas ln -s /etc/dinit.d/intel-undervolt /etc/dinit.d/boot.d
  elif grep -q AMD "/proc/cpuinfo"; then
    paru --cleanafter --removemake --noconfirm --useask -S ryzen-controller-bin
  fi
  doas sensors-detect --auto	
  eval `ssh-agent -s`

#----------------------------------------------------------------------------------------------------------------------------------

# Default apps

  handlr add .pdf org.pwmt.zathura.desktop
  handlr add .png vimiv.desktop
  handlr add .jpeg vimiv.desktop

#----------------------------------------------------------------------------------------------------------------------------------

# Default shell

  doas usermod --shell /usr/bin/zsh $(whoami)
  doas usermod --shell /usr/bin/zsh root

#----------------------------------------------------------------------------------------------------------------------------------

# Grub-theme

  git clone https://github.com/vinceliuice/grub2-themes.git
  cd grub2-themes || return
  doas ./install.sh -b
  cd $BEGINNER_DIR || return

#----------------------------------------------------------------------------------------------------------------------------------

# Installing dotfiles

  cp -r {wallpapers,.config,.local,programs} /home/$(whoami)/
  rm -rf /home/$(whoami)/.config/rsnapshot
  mkdir -p /home/$(whoami)/{scripts,Skærmbilleder,.local/bin,wallpapers/sunpaper}
  cp -r scripts/artix/* /home/$(whoami)/scripts
  chmod u+x /home/$(whoami)/{scripts/*,.config/{river/init,yambar/{cpu.sh,weather.sh,playerctl/*},sway/scripts/*}}
  fc-cache -f -v 
  doas cp -r etc/* /etc
  doas ln -s /home/$(whoami)/.config/zsh/.zshenv /etc/environment
  if grep -q Intel "/proc/cpuinfo"; then # Poor soul :(
    doas intel-undervolt apply
  fi
  git clone https://github.com/hexive/sunpaper.git
  cp -r sunpaper/images/* /home/$(whoami)/wallpapers/sunpaper
  if [[ -d "/home/$(whoami)/.librewolf" ]]; then
    rm -rf /home/$(whoami)/.librewolf
  fi
  cd librewolf || exit
  tar -xvf librewolf-browser-profile.tar.bz2 -C /home/$(whoami)
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
    cp /home/$(whoami)/.config/electron-flags.conf /home/$(whoami)/.config/$hej-flags.conf
  done < hejhej.txt

#----------------------------------------------------------------------------------------------------------------------------------

# Miscellaneous

  cat << EOF | doas tee -a /etc/issue > /dev/null
This object that you, sir, are using is property of Fabse Inc. - expect therefore puns! 

EOF
  doas pacman --noconfirm -Syu
  zsh
