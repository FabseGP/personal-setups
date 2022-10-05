#!/usr/bin/bash

  mv /home/$(whoami)/.config/electron-flags.conf /home/$(whoami)/.config/temp.conf
  rm -rf /home/$(whoami)/.config/electron*
  mv /home/$(whoami)/.config/temp.conf /home/$(whoami)/.config/electron-flags.conf
  pacman -Q > hejsa.txt && grep -F "electron" hejsa.txt > hejhej.txt && hej=${s%% *}
  while read -r line; do
    hej=${line%% *} && cp /home/$(whoami)/.config/electron-flags.conf /home/$(whoami)/.config/$hej-flags.conf
  done < hejhej.txt
  rm -rf /home/$(whoami)/{hejsa.txt,hejhej.txt}
