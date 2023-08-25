#!/usr/bin/bash

# Parameters

  cd artix || exit
  BEGINNER_DIR=$(pwd) 
  MODE="$1"
  GPU=$(lspci | grep VGA)
  if ! doas grep -qF "permit nopass fabse" /etc/doas.conf; then
    cat << EOF | doas tee -a /etc/doas.conf > /dev/null
permit nopass $(whoami)
EOF
  fi

#----------------------------------------------------------------------------------------------------------------------------------

# Package-installation
  if [[ -z "$(pacman -Qs chaotic-keyring)" ]]; then
    doas pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
    doas pacman-key --lsign-key 3056513887B78AEB
    doas pacman --noconfirm -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
    doas cp configs/pacman_with_chaotic.conf /etc/pacman.conf; fi
    
  doas pacman --noconfirm -Syu
  yes | doas pacman -S --needed mesa-tkg-git paru hdf5-openmpi
  doas pacman --noconfirm --needed -S alacritty libreoffice-fresh pavucontrol playerctl lutris-git steam elinks sweet-gtk-theme-dark protonup-qt bluez-utils man-db \
                                      bitwarden easyeffects librewolf zathura-pdf-mupdf swappy candy-icons-git lolcat modprobed-db inetutils moc mpv fwupd sway npm cheese \
                                      kmahjongg handlr i3status-rust swayidle swaybg clipman ttf-font-awesome lib32-gamemode figlet lib32-vkbasalt calf helix qt5ct ttf-dejavu-nerd \
                                      bemenu-wayland qt6-wayland kvantum-qt5 phonon-qt5-gstreamer pipewire-alsa mangohud libselinux android-udev lsp-plugins pass kdeconnect \
                                      pipewire-pulse zsh-theme-powerlevel10k zsh-autosuggestions protontricks-git docbook-xsl xmlto octave discord_arch_electron swww \
                                      zsh-syntax-highlighting shellcheck brightnessctl aisleriot vimiv-qt tela-icon-theme-git mako wofi cura-bin rpi-imager font-manager \
                                      bsd-games jq gvfs-mtp wallutils tumbler xarchiver sway-launcher-desktop gamemode smartmontools swaylock-effects python-pyclip wine-gecko \
                                      bottom ld-lsb xdg-desktop-portal-wlr wireplumber nemo-fileroller gendesk schedtool samba qt6ct dkms foot sshfs upscayl-bin wine-staging \
                                      python-pywal ethtool lib32-ocl-icd bcachefs-tools-git dupeguru dosbox reshade-shaders-git fzf blueman android-tools bat rclone wine-mono \
                                      unrar ttf-opensans libxcrypt-compat noto-fonts-emoji ttf-iosevka-nerd ventoy-bin llvm lsd wget patchutils mypaint s-tui nemo nnn \
                                      ttf-iosevka-nerd yambar-git bibata-rainbow-cursor-theme lib32-libva lib32-gtk3 lib32-gst-plugins-base-libs heroic-games-launcher-bin \
                                      ttf-meslo-nerd-font-powerlevel10k lib32-giflib lib32-mpg123 lib32-openal lib32-v4l-utils lib32-libxslt lzip libva-utils swtpm \
                                      tlp-dinit lm_sensors-dinit thermald-dinit openssh-dinit openvpn-dinit

  if ! [[ "$MODE" == "MINIMAL" ]]; then
   # doas pacman --needed -S plasma plasma-wayland-session # 1,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,31,32,33,34,35,36,37,38,39,40,41,42,43,48,46,47
    doas pacman --noconfirm --needed -S virt-manager qemu bridge-utils dnsmasq nss-mdns gimp sagemath arduino-cli arduino-avr-core geogebra freecad-git java-runtime-common \
                                        qutebrowser betterbird elogind boost obs-studio vbam-wx blender kdenlive foliate gnuplot meson kicad-library motrix-bin \
                                        kicad-library-3d artools-base artools-pkg texlive polkit-kde-agent kicad-git syncthing inkscape waydroid podman-compose \
                                        podman-compose podman python-pipx cups-pdf cups-dinit avahi-dinit libvirt-dinit; fi

  if grep -q Intel "/proc/cpuinfo"; then doas pacman --noconfirm --needed -S intel-undervolt-dinit; # Poor soul :(
  elif grep -q AMD "/proc/cpuinfo"; then doas pacman --noconfirm --needed -S zenpower3-dkms ryzenadj-git; fi
  if [[ "$GPU" == *"Intel"* ]]; then doas pacman --noconfirm --needed -S intel-media-driver intel-gpu-tools;
  elif [[ "$GPU" == *"AMD"* ]]; then paru --needed --noconfirm --useask -S amdgpu_top-bin; fi

#----------------------------------------------------------------------------------------------------------------------------------

# Installation of packages from AUR

  cd $BEGINNER_DIR || exit
  paru --needed --noconfirm --useask -S sworkstyle otf-openmoji macchina-bin pipes.sh sunwait-git ydotool-git miru-bin tachidesk-sorayomi-bin \
                                        wayshot wl-gammarelay-rs rivercarro cbonsai bash-pipes bastet rtl8812au-dkms-git nuclear-player-bin \
                                        nudoku deezer-enhanced-bin river-noxwayland sweet-kde-git deemix cmst 8bitdo-ultimate-controller-udev \
                                        catppuccin-frappe-grub-theme-git grub-theme-tela-color-2k-git stremio-beta
                                        
  if ! [[ "$MODE" == "MINIMAL" ]]; then paru --needed --noconfirm --useask -S pcbdraw qucs-s; fi
  paru --noconfirm --useask -Syu
  paru -Scd --noconfirm

#---------------------------------------------------------------------------------------------------------------

# Dinit-service s

  for service in lm_sensors tlp iwd; do doas ln -s /etc/dinit.d/$service /etc/dinit.d/boot.d; done
  if ! [[ "$MODE" == "MINIMAL" ]]; then doas usermod -a -G libvirt,games $(whoami); doas sed -i -e '/unix_sock_group = "libvirt"/s/^#//' /etc/libvirt/libvirtd.conf; doas sed -i -e '/unix_sock_rw_perms = "0770"/s/^#//' /etc/libvirt/libvirtd.conf; fi   
  if grep -q Intel "/proc/cpuinfo"; then doas ln -s /etc/dinit.d/intel-undervolt /etc/dinit.d/boot.d; doas ln -s /etc/dinit.d/intel-undervolt-loop /etc/dinit.d/boot.d; doas ln -s /etc/dinit.d/thermald /etc/dinit.d/boot.d; fi
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

  doas sed -i '/GRUB_THEME/c\GRUB_THEME=\/usr\/share\/grub\/themes\/catppuccin-frappe\/theme.txt' /etc/default/grub
  doas grub-mkconfig -o /boot/grub/grub.cfg

#----------------------------------------------------------------------------------------------------------------------------------

# Installing dotfiles

  cp -r {wallpapers,.config,.local} /home/$(whoami)
  mkdir -p /home/$(whoami)/{scripts,Skærmbilleder,.local/{share/dinit,bin},.config/dinit.d/boot.d}
  chmod u+x /home/$(whoami)/{scripts/*,.config/{river/init,yambar/{cpu.sh,weather.sh,playerctl/*},sway/scripts/*}}
  fc-cache -f -v 
  doas cp -r etc/* /etc
  doas chmod u+x /etc/dinit.d/user/scripts/*
  doas ln -sf /home/$(whoami)/.config/zsh/.zshenv /etc/environment
  if grep -q Intel "/proc/cpuinfo"; then doas intel-undervolt apply; fi
  cd $BEGINNER_DIR || return
  if ! [[ -d "/etc/pipewire" ]]; then doas mkdir /etc/pipewire; fi
  doas cp /usr/share/pipewire/pipewire.conf /etc/pipewire
  doas sed -i 's/#{ path = "\/usr\/bin\/pipewire" args = "-c pipewire-pulse.conf" }/{ path = "\/usr\/bin\/pipewire" args = "-c pipewire-pulse.conf" }/' /etc/pipewire/pipewire.conf
  doas sed -i '/{ path = "\/usr\/bin\/pipewire" args = "-c pipewire-pulse.conf" }/a { path = "wireplumber"  args = "" }' /etc/pipewire/pipewire.conf

#----------------------------------------------------------------------------------------------------------------------------------

# Miscellaneous

  cat << EOF | doas tee -a /etc/security/limits.conf > /dev/null

fabse hard nofile 524288
EOF
  cat << EOF | doas tee -a /etc/issue > /dev/null
This object that you, sir, are using is property of Fabse Inc. - expect therefore puns! 

EOF
  doas cp configs/misc /etc/cron.daily
  doas pacman --noconfirm -Syu
  doas sed -i "/permit nopass $(whoami)/d" /etc/doas.conf
  zsh