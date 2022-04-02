#!/bin/bash
  mv /home/fabse/.config/swaylock/config /home/fabse/.config/swaylock/tmp
  random=$(shuf -i 0-10 -n 1)
  term="footclient -T Screensaver"
  saver="pipes -t $random -R"
  locker="swaylock -c 00000000"
  ($term $saver ) &
  sleep .2
  ($locker && kill $!)
  mv /home/fabse/.config/swaylock/tmp /home/fabse/.config/swaylock/config
