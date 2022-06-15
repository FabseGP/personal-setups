#!/usr/bin/bash

# Static variables

  BEGINNER_DIR=$(pwd)
  alpine_url="https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/aarch64/" # Change if you experience slow download speed
  check_sudo="$(pacman -Qs --color always "sudo" | grep "local" | grep "sudo ")"
  if [[ "$(pacman -Qs opendoas)" ]]; then
    COMMAND="doas"
  elif ! [[ "$(pacman -Qs opendoas)" ]] && [[ "$(check_sudo)" ]]; then
    COMMAND="sudo"
  fi

#----------------------------------------------------------------------------------------------------------------------------------

# Downloading ISO

  mkdir alpine_rpi4
  cd alpine_rpi4
  list="alpine.html"
  if [[ ! -f "$list" ]]; then
    wget -O alpine.html "$alpine_url" -q
  fi 
  target=$(grep -o 'alpine-rpi-[^"]*.tar.gz' alpine.html | sort -u | head -1)
  link=""$alpine_url""$target""
  if ! [[ -f "$target" ]]; then 
    wget -c --tries=0 --read-timeout=5 "$link" -q --show-progress --progress=bar:force 2>&1 
  fi
  cd $BEGINNER_DIR

#----------------------------------------------------------------------------------------------------------------------------------

# Formatting drives

  until [[ "$CHOICE" == "YES" ]]; then
    echo
    echo "--------------------------------------------------------------------------------------------------"
    echo "---PLEASE INSERT THE DRIVE WHICH SHOULD BE FLASHED WITH THE ISO! PRESSING ANY KEY WILL CONFIRM!---"
    echo "--------------------------------------------------------------------------------------------------"
    echo
    read -r
    echo
    OUTPUT=$(lsblk -do name)
    lsblk
    echo
    echo "--------------------------------------------------------------------------------------------------"
    echo "-------------WHICH DRIVE IS TO BE FLASHED? PLEASE ONLY ENTER THE PART AFTER \"/dev/\"--------------"
    echo "--------------------------------------------------------------------------------------------------"
    echo
    read -r DRIVE
    read -rp "YOU HAVE CHOSEN \"$DRIVE\"; ENTER \"YES\" TO CONFIRM OR \"NO\" TO CHANGE DRIVE: " CHOICE
    echo
  fi

  $COMMMAND parted /dev/$DRIVE --script -- mklabel msdos
  $COMMMAND parted /dev/$DRIVE --script -- mkpart primary fat32 1 256M
  $COMMMAND parted /dev/$DRIVE --script -- mkpart primary ext4 256M 100%
  $COMMMAND parted /dev/$DRIVE --script -- set 1 boot on
  $COMMMAND parted /dev/$DRIVE --script -- set 1 lba on

  $COMMMAND mkfs.fat -F32 -I /dev/"$DRIVE"1
  $COMMMAND mkfs.ext4 -F /dev/"$DRIVE"2

#----------------------------------------------------------------------------------------------------------------------------------

# Extracts ISO + applies config-files / SSH

  $COMMMAND mount /dev/"$DRIVE"1 /mnt
  $COMMMAND tar xf /home/fabse/Downloads/$target -C /mnt --no-same-owner

  $COMMMAND cp configs/* /mnt 

  if [[ -f "answerfile" ]]; then 
    $COMMMAND cp answerfile /mnt 
  fi

  $COMMMAND curl -L -o /mnt/headless.apkovl.tar.gz https://github.com/davidmytton/alpine-linux-headless-raspberrypi/releases/download/2021.06.23/headless.apkovl.tar.gz
  $COMMMAND umount /dev/"$DRIVE"1

#----------------------------------------------------------------------------------------------------------------------------------

# Connecting to SSH of said device

  echo
  echo "---------------------------------------------------------------------"
  echo "---IF FABSEPI IS CONNECTED TO THE NETWORK: WHAT IS THE IP-ADDRESS?---"
  echo "---------------------------------------------------------------------"
  echo
  read -r IP_ADDRESS
  echo

  chmod u+x scripts/*
  ssh root@"$IP_ADDRESS" "$(< scripts/ssh.sh)"
