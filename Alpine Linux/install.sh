#!/usr/bin/bash

# Preparations

  read -rp "Is the script executed as bash -i /script/path? Is permit nopass fabsepi added to /etc/doas.conf? " hello
  read -rp "Type yes to use docker, no to use podman: " docker

#----------------------------------------------------------------------------------------------------------------------------------

# Edit repositories

  doas rm -f /etc/apk/repositories
  doas touch /etc/apk/repositories
  cat << EOF | doas tee -a /etc/apk/repositories > /dev/null
http://mirrors.dotsrc.org/alpine/edge/community/
http://mirrors.dotsrc.org/alpine/edge/testing/
http://mirrors.dotsrc.org/alpine/edge/main/
EOF

#----------------------------------------------------------------------------------------------------------------------------------

# All packages to install

  doas apk update
  doas apk upgrade
  if [ "$docker" == "yes" ]; then
    PACKAGES="apk add docker docker-cli-compose"
  elif [ "$docker" == "no" ]; then
    PACKAGES="apk add podman podman-docker py3-podman podman-remote fuse-overlayfs shadow slirp4netns"
  fi
  doas apk add $PACKAGES afetch cgroups bottom musl-locales openssh google-authenticator rsnapshot openssh-server-pam lang libressl udisks2 sed man-pages ttf-dejavu cups cups-libs sshguard cups-pdf cups-client cups-filters git py3-pip swaybg pcmanfm bc mako lz4 cbonsai nerd-fonts haveged gcc make build-base kbd-bkeymaps curl wget i2c-tools lm_sensors perl lsblk e2fsprogs-extra networkmanager nftables tzdata mysql-client firefox mysql pipewire ttf-opensans pipewire-pulse libuser libreoffice pavucontrol i3status-rust fzf rclone syncthing rsync alacritty terminator fcron unrar unzip zsh zsh-autosuggestions zsh-syntax-highlighting neovim btrfs-progs mousepad xarchiver nnn mpv swappy gotop wayfire nodejs-current npm lsof zathura zathura-pdf-mupdf eudev sway swaylock-effects swayidle figlet mesa-dri-gallium xdg-desktop-portal-wlr xdg-desktop-portal-kde gammastep wf-config clipman gnome-calculator polkit-gnome pipewire-media-session grim dialog grep font-awesome swaylockd

#----------------------------------------------------------------------------------------------------------------------------------

# Services + openssh enhanements

  if [ "$docker" == "yes" ]; then
    doas rc-update add docker default
  elif [ "$docker" == "no" ]; then
    doas rc-update add podman default
    doas rc-service podman start
    doas modprobe tun
    doas usermod --add-subuids 100000-165535 fabsepi
    doas usermod --add-subgids 100000-165535 fabsepi
    podman system migrate
  fi
  doas rc-update add swap boot
  doas rc-update add haveged boot
  for service in fcron syncthing dbus sshguard sshd cgroups cupsd mariadb fuse nftables networkmanager; do
    doas rc-update add $service default
  done
  doas /etc/init.d/sshd start
  cat << EOF | doas tee -a /etc/ssh/sshd.config > /dev/null

AuthenticationMethods publickey,keyboard-interactive
ChallengeResponseAuthentication yes
PermitRootLogin yes
KbdInteractiveAuthentication yes

EOF
  doas sed -i -e "/PasswordAuthentication no/s/^#//" /etc/ssh/sshd.config
  doas sed -i -e "/Port 22/s/^#//" /etc/ssh/sshd.config
  doas sed -i 's/Port 22/Port 1111/' /etc/ssh/sshd.config
  cat << EOF | doas tee -a /etc/issue.net > /dev/null

###############################################################
#                                                      Welcome to Fabse Inc.                                                           # 
#                                   All connections are monitored and recorded                                         #
#                          Disconnect IMMEDIATELY if you are not an authorized user!                    #
###############################################################

EOF
  doas sed -i -e "/Banner \/some\/path/s/^#//" /etc/ssh/sshd.config
  doas sed -i 's/Banner \/some\/path/Banner \/etc\/issue.net/' /etc/ssh/sshd.config
  doas touch /etc/sshguard.conf
  cat << EOF | doas tee -a /etc/sshguard.conf > /dev/null

#!/bin/bash
BACKEND='/usr/libexec/sshg-fw-nft-sets'
FILES='/var/log/messages'

# How many problematic attempts trigger a block
THRESHOLD=20
# Blocks last at least 180 seconds
BLOCK_TIME=180
# The attackers are remembered for up to 3600 seconds
DETECTION_TIME=3600

# Blacklist threshold and file name
BLACKLIST_FILE=100:/var/db/sshguard/blacklist.db

# IPv6 subnet size to block. Defaults to a single address, CIDR notation. (optional, default to 128)
IPV6_SUBNET=64
# IPv4 subnet size to block. Defaults to a single address, CIDR notation. (optional, default to 32)
IPV4_SUBNET=24

EOF
  doas touch /etc/pam.d/sshd.pam
  cat << EOF | doas tee -a /etc/pam.d/sshd.pam > /dev/null

account		include				base-account

auth		required			pam_env.so
auth		required			pam_nologin.so	successok
auth		include				google-authenticator

EOF
  doas google-authenticator

#----------------------------------------------------------------------------------------------------------------------------------

# Powerlevel10k-theme

  mkdir -p /home/fabsepi/.local/share/fonts
  doas lchsh fabsepi
  doas lchsh
  touch /home/fabsepi/.zshrc
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /home/fabsepi/powerlevel10k
  touch /home/fabsepi/.config/zsh/.zshenv
  touch /home/fabsepi/.config/zsh/.zshrc
  cat << EOF | tee -a /home/fabsepi/.zshenv > /dev/null

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
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export HISTFILE="home/fabse/.zhistory"    # History filepath
export HISTSIZE=10000                   # Maximum events for internal history
export SAVEHIST=10000                   # Maximum events in history file

EOF
  cat << EOF | tee -a /home/fabsepi/.zshrc > /dev/null

autoload -U compinit; compinit
zstyle ':completion::complete:*' gain-privileges 1

exit_zsh() { exit }
zle -N exit_zsh
bindkey '^D' exit_zsh

_comp_options+=(globdots) # With hidden files

cbonsai -p

bindkey -v
export KEYTIMEOUT=1

source ~/powerlevel10k/powerlevel10k.zsh-theme

alias rm="rm -i"
alias sway="dbus-run-session sway"

EOF

#----------------------------------------------------------------------------------------------------------------------------------

# User and groups

  for GRP in spi i2c gpio; do
    doas addgroup --system $GRP
  done
  for GRP in adm dialout cdrom audio users video games wheel input tty gpio spi i2c plugdev netdev; do
    doas adduser fabsepi $GRP 
  done
  if [ "$docker" == "yes" ]; then
    doas adduser fabsepi docker
  elif [ "$docker" == "no" ]; then
    doas groupadd docker
    doas adduser fabsepi docker
  fi
  doas groupadd sftpusers
  doas adduser sftpfabse
  doas adduser sftpfabse sftpusers

#----------------------------------------------------------------------------------------------------------------------------------

# Extra's

  mv /home/fabsepi/Setup_and_configs/RPI4/Scripts /home/fabsepi
  mv /home/fabsepi/Setup_and_configs/RPI4/Dockers /home/fabsepi
  mv /home/fabsepi/Setup_and_configs/RPI4/container_setup.sh /home/fabsepi
  chmod u+x /home/fabsepi/container_setup.sh
  mkdir /home/fabsepi/Pro-Fox
  git clone https://github.com/xmansyx/Pro-Fox.git /home/fabsepi/Pro-Fox
  doas mkdir /media/SEAGATE
  doas rm -rf /etc/motd
  doas touch /etc/motd
  doas mkdir /etc/pipewire
  chmod u+x /home/fabsepi/Scripts/*
  doas cp /usr/share/pipewire/pipewire.conf /etc/pipewire/
  doas sed -i -e "/{ path = "\/usr\/bin\/pipewire-media-session" args = ""}/s/^#//" /etc/pipewire/pipewire.conf
  doas sed -i s/#unicode="NO"\n\n#/#unicode="NO"\n\nunicode="YES"\n\n#/ /etc/rc.conf
  cat << EOF | doas tee -a /etc/motd > /dev/null
  
Welcome to Alpine Linux - delivered to you by Fabse Inc.!

Proceed with caution, as puns is looming around :D

EOF
  doas rc-service syncthing start
  syncthing
  sed -i 's/127.0.0.1/192.168.0.108/g' /home/fabsepi/.config/syncthing/config.xml

#----------------------------------------------------------------------------------------------------------------------------------

# Swapfile

  cd /
  doas truncate -s 0 ./swapfile
  doas chattr +C ./swapfile
  doas btrfs property set ./swapfile compression none
  doas dd if=/dev/zero of=/swapfile bs=1M count=8192
  doas chmod 600 /swapfile
  doas mkswap /swapfile
  doas swapon /swapfile
  echo '/swapfile   none    swap    sw    0   0' | doas tee -a /etc/fstab > /dev/null

#----------------------------------------------------------------------------------------------------------------------------------

# usercfg.txt

  doas touch /boot/usercfg.txt
  cat << EOF | doas tee -a /boot/usercfg.txt > /dev/null
dtparam=audio=on
dtparam=i2c_arm=on
dtoverlay=vc4-fkms-v3d
gpu_mem=256
enable_uart=1
EOF

#----------------------------------------------------------------------------------------------------------------------------------

# Add fcron jobs

  doas rc-service fcron start
  eval "$(crontab -l; echo "@reboot /home/fabsepi/Scripts/syncthing.sh"|awk '!x[$0]++'|crontab -)"
  eval "$(crontab -l; echo "@reboot /home/fabsepi/Scripts/leon.sh"|awk '!x[$0]++'|crontab -)"
  eval "$(crontab -l; echo "@reboot /home/fabsepi/Scripts/etherpad.sh"|awk '!x[$0]++'|crontab -)"
  echo "@reboot /home/fabsepi/Scripts/seagate.sh" | doas tee -a /etc/crontab > /dev/null
  eval "$(crontab -l; echo "@reboot /home/fabsepi/Scripts/pipewire.sh"|awk '!x[$0]++'|crontab -)"
  doas mv /home/fabsepi/Setup_and_configs/RPI4/rsnapshot.conf /etc/rsnapshot.conf
  doas mv /home/fabsepi/Setup_and_configs/RPI4/Scripts/rsnapshot_daily.sh /etc/periodic/daily
  doas mv /home/fabsepi/Setup_and_configs/RPI4/Scripts/rsnapshot_weekly.sh /etc/periodic/weekly
  doas mv /home/fabsepi/Setup_and_configs/RPI4/Scripts/rsnapshot_monthly.sh /etc/periodic/monthly
  doas chmod +x /etc/periodic/*/rsnapshot

#----------------------------------------------------------------------------------------------------------------------------------

# Mariadb (etherpad)

  doas /etc/init.d/mariadb setup
  doas rc-service mariadb start
  doas mysql_secure_installation
  mysql -u root --password=Alpine54321DB67890Maria -e "CREATE database etherpad_lite_db"
  mysql -u root --password=Alpine54321DB67890Maria -e "CREATE USER etherpad_fabsepi@localhost identified by 'Ether54321Pad67890FABsePI'"
  mysql -u root --password=Alpine54321DB67890Maria -e "grant CREATE,ALTER,SELECT,INSERT,UPDATE,DELETE on etherpad_lite_db.* to etherpad_fabsepi@localhost"   
  doas rc-service mariadb restart

#----------------------------------------------------------------------------------------------------------------------------------

# /etc/fstab

  echo 'UUID=523872dd-991a-44a7-a1d4-7050b7646236       /media/SEAGATE  btrfs   defaults,noatime,autodefrag,barrier,datacow        0       3' | doas tee -a /etc/fstab > /dev/null

#----------------------------------------------------------------------------------------------------------------------------------

# cmdline.txt

  doas sed -i 's/modules=sd-mod,usb-storage,btrfs quiet rootfstype=btrfs/modules=modules=sd-mod,usb-storage,btrfs,iptables,i2c-dev,fuse,tun,snd_seq quiet rootfstype=btrfs fsck.repair cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory swapaccount=1/' /boot/cmdline.txt

#----------------------------------------------------------------------------------------------------------------------------------

# Goodbye

  rm -rf Setup_and_configs
  doas sed -i '/permit nopass fabsepi/d' /etc/doas.conf
  echo
  echo "And you're welcome :))"
  echo
