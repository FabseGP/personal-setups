#!/usr/bin/bash

# Parameters

  cd artix || exit
  BEGINNER_DIR=$(pwd) && MODE="$1"
  if ! doas grep -qF "permit nopass fabse" /etc/doas.conf; then
    cat << EOF | doas tee -a /etc/doas.conf > /dev/null
permit nopass $(whoami)
EOF
  fi

#----------------------------------------------------------------------------------------------------------------------------------

# Package-installation
  if [[ -z "$(pacman -Qs chaotic-keyring)" ]]; then
    doas pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com && doas pacman-key --lsign-key FBA220DFC880C036
    doas pacman --noconfirm -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
    doas cp configs/pacman_with_chaotic.conf /etc/pacman.conf
  fi
  doas pacman --noconfirm -Syu
  cd packages || exit
  doas pacman --noconfirm --needed -S nemo alacritty libreoffice-fresh pavucontrol playerctl wayland lutris-git zsh bat steam helix elinks \
                                      bitwarden easyeffects librewolf zathura zathura-pdf-mupdf swappy candy-icons-git brave-bin lolcat \
                                      gnome-mahjongg galculator foot mpv handlr sway i3status-rust swayidle swaybg clipman ttf-font-awesome \
                                      bemenu-wayland qt6-wayland kvantum-qt5 phonon-qt5-gstreamer pipewire-alsa fzf mangohud libselinux \
                                      pipewire-pulse pipewire-jack zsh-theme-powerlevel10k zsh-autosuggestions mako jq wlsunset nano moc \
                                      zsh-syntax-highlighting shellcheck brightnessctl aisleriot vulkan-intel vimiv-qt-git tela-icon-theme-git \
                                      bsd-games mypaint gvfs-mtp wallutils tumbler xarchiver figlet sway-launcher-desktop gamemode samba \
                                      bashtop nnn alsa-utlis bottom ld-lsb xdg-desktop-portal-wlr wofi pipewire rclone nemo-fileroller npm \
                                      python-pywal xmlto man-db ethtool lsd lib32-opencl-icd-loader bcachefs-tools-git dupeguru dosbox wget \
                                      unrar libva-intel-driver ttf-opensans libxcrypt-compat noto-fonts-emoji ttf-iosevka-nerd ventoy-bin \
                                      ttf-nerd-fonts-symbols-2048-em revolt-desktop-git yambar-git bibata-rainbow-cursor-theme mousepad dbus-broker \
                                      ttf-meslo-nerd-font-powerlevel10k lib32-giflib lib32-mpg123 lib32-openal lib32-v4l-utils lib32-libxslt \
                                      lib32-libva lib32-gtk3 lib32-gst-plugins-base-libs tlp-dinit lm_sensors-dinit thermald-dinit openssh-dinit
  if ! [[ "$MODE" == "MINIMAL" ]]; then
    doas pacman --noconfirm --needed -S virt-manager qemu bridge-utils dnsmasq nss-mdns gimp fuse2 avogadrolibs sagemath arduino-cli arduino-avr-core \
                                        geogebra geany-plugins qutebrowser betterbird elogind boost obs-studio blender kdenlive foliate gnuplot meson \
                                        kicad-library-3d artools wine-wl-git texlive-most polkit-gnome kicad syncthing android-platform kicad-library \
                                        linux-tkg-cfs linux-tkg-cfs-headers xorg-xwayland cups-pdf cups-dinit avahi-dinit libvirt-dinit
  fi
  if grep -q Intel "/proc/cpuinfo"; then # Poor soul :(
    doas pacman --noconfirm --needed -S intel-undervolt-dinit
  elif grep -q AMD "/proc/cpuinfo"; then :; fi

 # linux-libre linux-libre-headers

#----------------------------------------------------------------------------------------------------------------------------------

# Installation of packages from AUR

  cd $BEGINNER_DIR || exit
  doas cp etc/pacman.d/hooks/dinit-userservd.hook /etc/pacman.d/hooks
  doas cp configs/dinit-userservd /.secret
  wget https://aur.archlinux.org/packages/dot-bin
  if ! grep -q "Flagged out-of-date" dot-bin; then AUR="dot-bin"; fi
  cd packages || exit
  paru --noconfirm -Syu
  PIPES_1="$(ls -- *bash-pipes-*)" && CBONSAI="$(ls -- *cbonsai-*)" && NUDOKU="$(ls -- *nudoku-*)" && PIPES_2="$(ls -- *pipes.sh-*)" && POKEMON="$(ls -- *pokemon-*)" && SUNWAIT="$(ls -- *sunwait-*)" && SWEET_GTK="$(ls -- *sweet-gtk-*)" && SWEET_QT="$(ls -- *sweet-kde-*)" && DINIT="$(ls -- *dinit-*)"
  doas pacman --noconfirm --needed -U $PIPES_1 $BASTET $CBONSAI $NUDOKU $PIPES_2 $POKEMON $SUNWAIT $SWEET_GTK \
                                      $SWEET_QT $DINIT
  cd $BEGINNER_DIR || exit
  paru --cleanafter --removemake --noconfirm --useask -S nuclear-player-bin sworkstyle otf-openmoji swaylock-effects-git \
                                                         macchina-bin river-noxwayland-git wayshot-bin rtl8812au-dkms-git \
                                                         rivercarro-git youtube-music-bin bastet protonvpn-cli-community ydotool \
                                                         freerouting-zh-cn-git $AUR                                                                             
  if ! [[ "$MODE" == "MINIMAL" ]]; then paru --cleanafter --removemake --noconfirm --useask -S stm32cubemx; fi
  paru -Scd --noconfirm
  doas archlinux-java set java-18-openjdk

#----------------------------------------------------------------------------------------------------------------------------------

# Dinit-services

  for service in lm_sensors tlp thermald sshd dinit-userservd ; do doas ln -s /etc/dinit.d/$service /etc/dinit.d/boot.d; done
  if ! [[ "$MODE" == "MINIMAL" ]]; then doas usermod -a -G libvirt,games $(whoami); doas sed -i -e '/unix_sock_group = "libvirt"/s/^#//' /etc/libvirt/libvirtd.conf; doas sed -i -e '/unix_sock_rw_perms = "0770"/s/^#//' /etc/libvirt/libvirtd.conf; fi   
  if grep -q Intel "/proc/cpuinfo"; then doas ln -s /etc/dinit.d/intel-undervolt /etc/dinit.d/boot.d; doas ln -s /etc/dinit.d/intel-undervolt-loop /etc/dinit.d/boot.d;
  elif grep -q AMD "/proc/cpuinfo"; then paru --cleanafter --removemake --noconfirm --useask -S ryzen-controller-bin; fi
  doas sensors-detect --auto	
  eval $(ssh-agent -s)

#----------------------------------------------------------------------------------------------------------------------------------

# Default apps

  handlr add .pdf org.pwmt.zathura.desktop && handlr add .png vimiv.desktop && handlr add .jpeg vimiv.desktop

#----------------------------------------------------------------------------------------------------------------------------------

# Default shell

  doas usermod --shell /usr/bin/zsh $(whoami) && doas usermod --shell /usr/bin/zsh root

#----------------------------------------------------------------------------------------------------------------------------------

# Grub-theme

  git clone https://github.com/vinceliuice/grub2-themes.git && cd grub2-themes || return && doas ./install.sh -b
  cd $BEGINNER_DIR || return

#----------------------------------------------------------------------------------------------------------------------------------

# Installing dotfiles

  cp -r {wallpapers,.config,.local} /home/$(whoami)
  rm -rf /${home/$(whoami)/.config/rsnapshot:?}
  mkdir -p /home/$(whoami)/{scripts,Skærmbilleder,.local/{share/dinit,bin},.config/dinit.d/boot.d,wallpapers/sunpaper}
  cp -r scripts/artix/* /home/$(whoami)/scripts
  chmod u+x /home/$(whoami)/{scripts/*,.config/{river/init,yambar/{cpu.sh,weather.sh,playerctl/*},sway/scripts/*}}
  ln -sf /home/$(whoami)/.config/dinit.d/{dbus.user,pipewire.user,foot.user,mako.user,syncthing.user,wl_paste.user} /home/$(whoami)/.config/dinit.d/boot.d
  doas cp -f /.secret/dinit-userservd /etc/dinit.d
  fc-cache -f -v 
  doas cp -r etc/* /etc
  doas chmod u+x /etc/dinit.d/user/scripts/*
  doas ln -sf /home/$(whoami)/.config/zsh/.zshenv /etc/environment
  if grep -q Intel "/proc/cpuinfo"; then doas intel-undervolt apply; fi
  git clone https://github.com/hexive/sunpaper.git
  cp -r sunpaper/images/* /home/$(whoami)/wallpapers/sunpaper
  cd $BEGINNER_DIR || return
  if ! [[ -d "/etc/pipewire" ]]; then doas mkdir /etc/pipewire; fi
  doas cp /usr/share/pipewire/pipewire.conf /etc/pipewire
  doas sed -i 's/#{ path = "\/usr\/bin\/pipewire" args = "-c pipewire-pulse.conf" }/{ path = "\/usr\/bin\/pipewire" args = "-c pipewire-pulse.conf" }/' /etc/pipewire/pipewire.conf
  doas sed -i '/{ path = "\/usr\/bin\/pipewire" args = "-c pipewire-pulse.conf" }/a { path = "wireplumber"  args = "" }' /etc/pipewire/pipewire.conf
  pacman -Q > hejsa.txt && grep -F "electron" hejsa.txt > hejhej.txt
  hej=${s%% *}
  while read -r line; do
    hej=${line%% *} && cp /home/$(whoami)/.config/electron-flags.conf /home/$(whoami)/.config/$hej-flags.conf
  done < hejhej.txt

#----------------------------------------------------------------------------------------------------------------------------------

# Miscellaneous

  cat << EOF | doas tee -a /etc/security/limits.conf

fabse hard nofile 524288
EOF
  cat << EOF | doas tee -a /etc/pam.d/system-login

session optional pam_dinit_userservd.so
EOF
  cat << EOF | doas tee -a /etc/issue > /dev/null
This object that you, sir, are using is property of Fabse Inc. - expect therefore puns! 

EOF
  doas pacman --noconfirm -Syu
  doas sed -i "/permit nopass $(whoami)/d" /etc/doas.conf
  zsh
