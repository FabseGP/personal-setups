#!/bin/sh

  for service in yambar foot pipewire pipewire-pulse wireplumber mako wl-paste sunpaper sworkstyle; do
    if [[ $(pidof $service) ]]; then
      killall $service
    fi
  done
  if [[ "$1" == "sway" ]]; then
    swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session and make everyone sad.' -b '*Sigh* Roger roger' 'swaymsg exit'
  elif [[ "$1" == "river" ]]; then
    riverctl exit
  fi
