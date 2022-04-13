#!/usr/bin/bash

  mv /home/fabse/.config/electron-flags.conf /home/fabse/.config/temp.conf
  rm -rf /home/fabse/.config/electron*
  mv /home/fabse/.config/temp.conf /home/fabse/.config/electron-flags.conf
  pacman -Q > hejsa.txt
  grep -F "electron" hejsa.txt > hejhej.txt
  hej=${s%% *}
  while read line; do
    hej=${line%% *}
    cp /home/fabse/.config/electron-flags.conf /home/fabse/.config/$hej-flags.conf
  done < hejhej.txt
  rm -rf /home/fabse/{hejsa.txt,hejhej.txt}
