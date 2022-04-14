#!/usr/bin/bash

# Parameters

  BEGINNER_DIR=$(pwd)
  echo "permit nopass $(whoami)" | doas tee -a /etc/doas.conf > /dev/null

#----------------------------------------------------------------------------------------------------------------------------------

# Edit repositories

  doas rm -f /etc/apk/repositories
  doas touch /etc/apk/repositories
  cat << EOF | doas tee -a /etc/apk/repositories > /dev/null
https://mirrors.dotsrc.org/alpine/edge/community/
https://mirrors.dotsrc.org/alpine/edge/testing/
https://mirrors.dotsrc.org/alpine/edge/main/
EOF

#----------------------------------------------------------------------------------------------------------------------------------

# All packages to install

  doas apk update
  doas apk upgrade
  doas apk add podman-docker py3-podman podman-remote fuse-overlayfs shadow slirp4netns \
  podman-zsh-completion podman-compose macchina bottom musl-locales ttf-font-awesome vimiv \
  lang libressl udisks2 sed man-pages ttf-dejavu cups-pdf git py3-pip pcmanfm i2c-tools \
  mako zstd lz4 cbonsai nerd-fonts gcc make wget build-base kbd-bkeymaps curl fzf iwd wofi \
  lm_sensors perl lsblk nftables tzdata mysql-client firefox mysql pipewire libreoffice \
  ttf-opensans pipewire-pulse pipewire-alsa pipewire-jack libuser rclone pavucontrol npm \
  zsh syncthing rsync foot unrar unzip zsh-autosuggestions zsh-syntax-highlighting mpv nnn \
  helix btrfs-progs xarchiver swappy river nodejs-current zathura zsh-theme-powerlevel10k \
  zathura-pdf-mupdf swaylock-effects mesa-dri-gallium xdg-desktop-portal-wlr font-meslo-nerd \
  wlsunset yambar clipman wireplumper eudev grep font-awesome openssh wayshot lsof handlr \
  podman cgroups cups connman cronie haveged sshguard rsnapshot

#----------------------------------------------------------------------------------------------------------------------------------

# Services + openssh enhanements

  doas rc-update add swap boot
  doas rc-update add haveged boot
  for service in rsnapshot podman cronie syncthing dbus sshguard sshd cgroups cupsd mariadb fuse nftables connmand; do
    doas rc-update add $service default
  done
  doas rc-service mariadb start
  doas rc-service syncthing start
  doas rc-service fcron start
  doas rc-service podman start
  doas modprobe tun
  doas echo tun >> /etc/modules
  doas usermod --add-subuids 100000-165535 $(whoami)
  doas usermod --add-subgids 100000-165535 $(whoami)
  podman system migrate
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
#                                                      Welcome to fabsepi Inc.                                                           # 
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

#----------------------------------------------------------------------------------------------------------------------------------

# Default apps

  handlr add .pdf org.pwmt.zathura.desktop
  handlr add .png vimiv.desktop
  handlr add .jpeg vimiv.desktop

#----------------------------------------------------------------------------------------------------------------------------------

# Installing dotfiles

  cp -r {wallpapers,.config,scripts,.local} /home/fabsepi
  sed -i 's/rivercarro/rivertile/g' /home/fabsepi/.config/river/init
  rm -rf /home/fabsepi/{scripts/artix,.config/{easyeffects,i3status-rust,sway}
  chmod u+x /home/fabsepi/{scripts/*,.config/{river/init,yambar/{cpu.sh,weather.sh,playerctl/*}}
  mkdir -p /home/fabsepi/{Skærmbilleder,.local/bin}
  fc-cache -f -v 
  doas cp -r etc/zsh /etc
  doas ln -s /home/fabsepi/.config/zsh/.zshenv /etc/environment
  cd $BEGINNER_DIR || return
  if ! [[ -d "/etc/pipewire" ]]; then
    doas mkdir /etc/pipewire
  fi
  doas cp /usr/share/pipewire/pipewire.conf /etc/pipewire
  doas sed -i 's/#{ path = "\/usr\/bin\/pipewire" args = "-c pipewire-pulse.conf" }/{ path = "\/usr\/bin\/pipewire" args = "-c pipewire-pulse.conf" }/' /etc/pipewire/pipewire.conf
  doas sed -i '/{ path = "\/usr\/bin\/pipewire" args = "-c pipewire-pulse.conf" }/a { path = "wireplumber"  args = "" }' /etc/pipewire/pipewire.conf

#----------------------------------------------------------------------------------------------------------------------------------

# User and groups

  for GRP in spi i2c gpio docker sftpusers; do
    doas addgroup --system $GRP
  done
  for GRP in disk wheel video audio input lp netdev plugdev users gpio spi i2c docker; do
    doas adduser $(whoami) $GRP 
  done
  doas adduser sftpfabsepi
  doas adduser sftpfabsepi sftpusers

#----------------------------------------------------------------------------------------------------------------------------------

# Extra's

  doas lchsh fabsepi
  doas lchsh
  doas sed -i s/#unicode="NO"\n\n#/#unicode="NO"\n\nunicode="YES"\n\n#/ /etc/rc.conf
  doas rm -rf /etc/motd
  doas touch /etc/motd
  cat << EOF | doas tee -a /etc/motd > /dev/null
  
Welcome to Alpine Linux - delivered to you by fabsepi Inc.!

Proceed with caution, as puns is looming around :D

EOF

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

  eval "$(crontab -l; echo "@reboot /home/$(whoami)/scripts/syncthing.sh"|awk '!x[$0]++'|crontab -)"
  eval "$(crontab -l; echo "@reboot /home/$(whoami)/scripts/leon.sh"|awk '!x[$0]++'|crontab -)"
  eval "$(crontab -l; echo "@reboot /home/$(whoami)/scripts/etherpad.sh"|awk '!x[$0]++'|crontab -)"
  echo "@reboot /home/$(whoami)/scripts/seagate.sh" | doas tee -a /etc/crontab > /dev/null
  eval "$(crontab -l; echo "@reboot /home/$(whoami)/scripts/pipewire.sh"|awk '!x[$0]++'|crontab -)"
  doas mv /home/fabsepipi/Setup_and_configs/RPI4/rsnapshot.conf /etc/rsnapshot.conf
  doas mv /home/fabsepipi/Setup_and_configs/RPI4/Scripts/rsnapshot_daily.sh /etc/periodic/daily
  doas mv /home/fabsepipi/Setup_and_configs/RPI4/Scripts/rsnapshot_weekly.sh /etc/periodic/weekly
  doas mv /home/fabsepipi/Setup_and_configs/RPI4/Scripts/rsnapshot_monthly.sh /etc/periodic/monthly
  doas chmod +x /etc/periodic/*/rsnapshot

#----------------------------------------------------------------------------------------------------------------------------------

# Mariadb (etherpad)

  doas /etc/init.d/mariadb setup
  doas rc-service mariadb restart
  doas mysql_secure_installation
  mysql -u root --password=Alpine54321DB67890Maria -e "CREATE database etherpad_lite_db"
  mysql -u root --password=Alpine54321DB67890Maria -e "CREATE USER etherpad_fabsepipi@localhost identified by 'Ether54321Pad67890fabsepiPI'"
  mysql -u root --password=Alpine54321DB67890Maria -e "grant CREATE,ALTER,SELECT,INSERT,UPDATE,DELETE on etherpad_lite_db.* to etherpad_fabsepipi@localhost"   
  doas rc-service mariadb restart

#----------------------------------------------------------------------------------------------------------------------------------

# /etc/fstab

  doas mkdir /media/SEAGATE
  echo 'UUID=523872dd-991a-44a7-a1d4-7050b7646236       /media/SEAGATE  btrfs   defaults,noatime,autodefrag,barrier,datacow        0       3' | doas tee -a /etc/fstab > /dev/null

#----------------------------------------------------------------------------------------------------------------------------------

# cmdline.txt

  doas sed -i 's/modules=sd-mod,usb-storage,btrfs quiet rootfstype=btrfs/modules=modules=sd-mod,usb-storage,btrfs,iptables,i2c-dev,fuse,tun,snd_seq quiet rootfstype=btrfs fsck.repair cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory swapaccount=1/' /boot/cmdline.txt

#----------------------------------------------------------------------------------------------------------------------------------

# Goodbye

  doas sed -i "/permit nopass $(whoami)/d" /etc/doas.conf
  echo
  echo "And you're welcome :))"
  echo
  zsh
