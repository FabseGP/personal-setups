#!/usr/bin/bash

# Parameters

  cd artix || exit
  BEGINNER_DIR=$(pwd) 
  MODE="$1"
  if ! doas grep -qF "permit nopass fabse" /etc/doas.conf; then
    cat << EOF | doas tee -a /etc/doas.conf > /dev/null
permit nopass $(whoami)
EOF
  fi

#----------------------------------------------------------------------------------------------------------------------------------

# Package-installation
  if [[ -z "$(pacman -Qs chaotic-keyring)" ]]; then
    doas pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com 
    doas pacman-key --lsign-key FBA220DFC880C036
    doas pacman --noconfirm -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
    doas cp configs/pacman_with_chaotic.conf /etc/pacman.conf
  fi
  doas pacman --noconfirm -Syu
  doas pacman --noconfirm --needed -S nemo alacritty libreoffice-fresh pavucontrol playerctl wayland lutris-git steam helix elinks sweet-gtk-theme-dark docbook-xsl \
                                      bitwarden easyeffects librewolf zathura zathura-pdf-mupdf swappy candy-icons-git brave-bin lolcat modprobed-db inetutils nano \
                                      gnome-mahjongg galculator handlr i3status-rust swayidle swaybg clipman ttf-font-awesome lib32-gamemode figlet lib32-vkbasalt \
                                      bemenu-wayland qt6-wayland kvantum-qt5 phonon-qt5-gstreamer pipewire-alsa mangohud libselinux samba wlsunset android-udev moc \
                                      pipewire-pulse pipewire-jack zsh-theme-powerlevel10k zsh-autosuggestions protontricks-git youtube-music-bin reshade-shaders-git \
                                      zsh-syntax-highlighting shellcheck brightnessctl aisleriot mesa-tkg-git vimiv-qt-git tela-icon-theme-git mako wofi cura xmlto dkms \
                                      bsd-games jq gvfs-mtp wallutils tumbler xarchiver sway-launcher-desktop gamemode smartmontools swaylock-effects rpi-imager fzf \
                                      bashtop alsa-utlis bottom ld-lsb xdg-desktop-portal-wlr pipewire rclone nemo-fileroller tlp-rdw vkd3d-proton-tkg-git fwupd sway \
                                      python-pywal man-db ethtool lib32-opencl-icd-loader bcachefs-tools-git dupeguru dosbox reshade-shaders-git mypaint docbook-xml nnn \
                                      unrar intel-media-driver ttf-opensans libxcrypt-compat noto-fonts-emoji ttf-iosevka-nerd ventoy-bin llvm lsd wget patchutils foot \
                                      ttf-nerd-fonts-symbols-2048-em revolt-desktop-git yambar-git bibata-rainbow-cursor-theme mousepad dbus-broker zsh s-tui bat npm \
                                      ttf-meslo-nerd-font-powerlevel10k lib32-giflib lib32-mpg123 lib32-openal lib32-v4l-utils lib32-libxslt mpv freecad protonup-qt \
                                      lib32-libva lib32-gtk3 lib32-gst-plugins-base-libs tlp-dinit lm_sensors-dinit thermald-dinit openssh-dinit earlyoom-dinit
  if ! [[ "$MODE" == "MINIMAL" ]]; then
    doas pacman --noconfirm --needed -S virt-manager qemu bridge-utils dnsmasq nss-mdns gimp fuse2 avogadrolibs sagemath arduino-cli arduino-avr-core \
                                        geogebra geany-plugins qutebrowser betterbird elogind boost obs-studio blender kdenlive foliate gnuplot meson \
                                        kicad-library-3d artools wine-wl-git texlive-most polkit-gnome kicad syncthing android-platform kicad-library \
                                        inkscape xorg-xwayland cups-pdf cups-dinit avahi-dinit libvirt-dinit
  fi
  if grep -q Intel "/proc/cpuinfo"; then # Poor soul :(
    doas pacman --noconfirm --needed -S intel-undervolt-dinit
  elif grep -q AMD "/proc/cpuinfo"; then :; fi

 # linux-libre linux-libre-headers

#----------------------------------------------------------------------------------------------------------------------------------

# Installation of packages from AUR

  cd $BEGINNER_DIR || exit
  paru --noconfirm --useask -S nuclear-player-bin sworkstyle otf-openmoji macchina-bin pipes.sh sunwait-git \
                               wayshot-bin freerouting rivercarro-git cbonsai bash-pipes pokemon-cursor bastet \
                               nudoku-git protonvpn-cli-community ydotool rtl8812au-dkms-git sweet-kde-git
# river-noxwayland-git 
  paru --noconfirm --useask -Syu
  paru -Scd --noconfirm
  doas archlinux-java set java-19-openjdk

#----------------------------------------------------------------------------------------------------------------------------------

# Dinit-services

  for service in lm_sensors tlp thermald earlyoom; do doas ln -s /etc/dinit.d/$service /etc/dinit.d/boot.d; done
  if ! [[ "$MODE" == "MINIMAL" ]]; then doas usermod -a -G libvirt,games $(whoami); doas sed -i -e '/unix_sock_group = "libvirt"/s/^#//' /etc/libvirt/libvirtd.conf; doas sed -i -e '/unix_sock_rw_perms = "0770"/s/^#//' /etc/libvirt/libvirtd.conf; fi   
  if grep -q Intel "/proc/cpuinfo"; then doas ln -s /etc/dinit.d/intel-undervolt /etc/dinit.d/boot.d; doas ln -s /etc/dinit.d/intel-undervolt-loop /etc/dinit.d/boot.d;
  elif grep -q AMD "/proc/cpuinfo"; then paru --cleanafter --removemake --noconfirm --useask -S ryzen-controller-bin; fi
  doas sensors-detect --auto	
  eval $(ssh-agent -s)

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

  cp -r {wallpapers,.config,.local} /home/$(whoami)
  rm -rf /${home/$(whoami)/.config/rsnapshot:?}
  mkdir -p /home/$(whoami)/{scripts,Skærmbilleder,.local/{share/dinit,bin},.config/dinit.d/boot.d,wallpapers/sunpaper}
  cp -r scripts/artix/* /home/$(whoami)/scripts
  chmod u+x /home/$(whoami)/{scripts/*,.config/{river/init,yambar/{cpu.sh,weather.sh,playerctl/*},sway/scripts/*}}
  ln -sf /home/$(whoami)/.config/dinit.d/{dbus.user,pipewire.user,foot.user,mako.user,syncthing.user,wl_paste.user} /home/$(whoami)/.config/dinit.d/boot.d
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
  pacman -Q > hejsa.txt 
  grep -F "electron" hejsa.txt > hejhej.txt
  hej=${s%% *}
  while read -r line; do
    hej=${line%% *} 
    cp /home/$(whoami)/.config/electron-flags.conf /home/$(whoami)/.config/$hej-flags.conf
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
  cat << EOF | doas tee -a /etc/dinit.d/config/rc.local

powertop --auto-tune
sh /home/fabse/local/autosuspend.sh
EOF
  doas cp configs/misc /etc/cron.daily
  doas pacman --noconfirm -Syu
  doas sed -i "/permit nopass $(whoami)/d" /etc/doas.conf
  zsh
