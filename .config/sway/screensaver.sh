#!/bin/bash
  mv /home/fabse/.config/swaylock/config /home/fabse/.config/swaylock/tmp
  term='alacritty -t Screensaver -e'
  saver=cmatrix
  locker='swaylock -c 00000000'
  ($term $saver) &
  sleep .2
  ($locker && kill $!)
  mv /home/fabse/.config/swaylock/tmp /home/fabse/.config/swaylock/config