#!/usr/bin/bash

# setup
setup-keymap dk dk-winkeys
setup-hostname fabsemanpi
setup-interfaces
setup-timezone -z Europe/Copenhagen
setup-ntp -c chrony
setup-apkrepos
passwd
setup-sshd -c openssh

# confidential

RPI4_SUPERHELT_110802
fabsepi_54321_AWESOME_67890


# ssh

(...)
Port 22
(...)
PermitRootLogin yes
(...)
PubkeyAuthentication yes
(...)
PasswordAuthentication yes
PermitEmptyPasswords no
(...)


# btrbk

mangler 


# Parameters

  echo "permit persist setenv { XAUTHORITY LANG LC_ALL } :wheel" | tee -a /etc/doas.conf > /dev/null

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
  doas apk add git lang libressl udisks2 sed man-pages zstd nftables tzdata kbd-bkeymaps syncthing rsync rclone \
               eudev grep lsof openssh wget libuser mysql mysql-client helix libcgroup podman podman-docker util-linux \
               musl-locales cronie fuse haveged python3 py3-pip unzip tar mesa-dri-gallium btrbk podman-compose lm_sensors

#----------------------------------------------------------------------------------------------------------------------------------

# Services + openssh enhanements

  doas rc-update add swap boot
  doas rc-update add haveged boot
  for service in podman cronie dbus sshd cgroups mariadb fuse nftables; do
    doas rc-update add $service default
  done
  doas rc-service mariadb start
  doas modprobe tun
  echo "tun" | doas tee -a /etc/modules > /dev/null
  echo 'fabsepi:100000:65536' | doas tee -a /etc/subuid > /dev/null
  echo 'fabsepi:100000:65536' | doas tee -a /etc/subgid > /dev/null
  podman system migrate
  doas sed -i 's/driver = "overlay"/driver = "btrfs"/' /etc/containers/storage.conf
  doas /etc/init.d/sshd start
  cat << EOF | doas tee -a /etc/issue.net > /dev/null

###############################################################
#                                                      Welcome to fabsepi Inc.                                                           # 
#                                   All connections are monitored and recorded                                         #
#                          Disconnect IMMEDIATELY if you are not an authorized user!                    #
###############################################################

EOF
  doas sed -i -e "/Banner \/some\/path/s/^#//" /etc/ssh/sshd_config
  doas sed -i 's/Banner \/some\/path/Banner \/etc\/issue.net/' /etc/ssh/sshd_config

#----------------------------------------------------------------------------------------------------------------------------------

# Installing dotfiles

  cp -r {wallpapers,.config,.local} /home/fabsepi
  sed -i 's/rivercarro/rivertile/g' /home/fabsepi/.config/river/init
  rm -rf /home/fabsepi/{.config/{easyeffects,i3status-rust,sway}
  mkdir -p /home/fabsepi/{scripts,Skærmbilleder,.local/bin}
  cp -r scripts/alpine/* /home/fabse/scripts
  chmod u+x /home/fabsepi/{scripts/*,.config/{river/init,yambar/{cpu.sh,weather.sh,playerctl/*}}
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
  for GRP in disk wheel video audio input lp netdev users gpio spi i2c docker; do
    doas adduser fabsepi $GRP 
  done
  doas adduser sftpfabsepi
  doas adduser sftpfabsepi sftpusers

#----------------------------------------------------------------------------------------------------------------------------------

# Extra's

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
  cat << EOF | doas tee -a /boot/config.txt > /dev/null

# Custom
dtoverlay=vc4-fkms-v3d
arm_freq=2250
gpu_freq=750
over_voltage=8
EOF

#----------------------------------------------------------------------------------------------------------------------------------

# Add fcron jobs

  eval "$(crontab -l; echo "@reboot /home/fabsepi/scripts/syncthing.sh"|awk '!x[$0]++'|crontab -)"
  eval "$(crontab -l; echo "@reboot /home/fabsepi/scripts/leon.sh"|awk '!x[$0]++'|crontab -)"
  eval "$(crontab -l; echo "@reboot /home/fabsepi/scripts/etherpad.sh"|awk '!x[$0]++'|crontab -)"
  echo "@reboot /home/fabsepi/scripts/seagate.sh" | doas tee -a /etc/crontab > /dev/null
  doas ln -s /home/fabsepi/.config/rsnapshot/rsnapshot.conf /etc/rsnapshot.conf
  doas ln -s /home/fabsepi/scripts/rsnapshot_daily.sh /etc/periodic/daily
  doas ln -s /home/fabsepi/scripts/rsnapshot_weekly.sh /etc/periodic/weekly
  doas ln -s /home/fabsepi/scripts/rsnapshot_monthly.sh /etc/periodic/monthly
  doas chmod +x /etc/periodic/*/rsnapshot

#----------------------------------------------------------------------------------------------------------------------------------

# Mariadb (etherpad)

  doas /etc/init.d/mariadb setup
  doas rc-service mariadb restart
  doas mysql_secure_installation
  mysql -u root --password=Alpine54321DB67890Maria -e "CREATE database etherpad_lite_db"
  mysql -u root --password=Alpine54321DB67890Maria -e "CREATE USER etherpad_fabsepi@localhost identified by 'Ether54321Pad67890fabsePI'"
  mysql -u root --password=Alpine54321DB67890Maria -e "grant CREATE,ALTER,SELECT,INSERT,UPDATE,DELETE on etherpad_lite_db.* to etherpad_fabsepi@localhost"   
  doas rc-service mariadb restart

#----------------------------------------------------------------------------------------------------------------------------------

# /etc/fstab

  doas mkdir /media/SEAGATE
fstab: noatime,compress-force=zstd,discard=async,autodefrag

#----------------------------------------------------------------------------------------------------------------------------------

# cmdline.txt

/boot/cmdline.txt: 
modules=sd-mod,usb-storage,btrfs,iptables,fuse,tun quiet rootfstype=btrfs fsck.repair cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory swapaccount=1

#----------------------------------------------------------------------------------------------------------------------------------

# Goodbye

  echo
  echo "And you're welcome :))"
  echo
