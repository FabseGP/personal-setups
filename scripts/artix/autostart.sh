#!/bin/sh

  if [[ "$1" == "river" ]]; then
    command="riverctl spawn"
  elif [[ "$1" == "sway" ]]; then
    command="exec"
  fi
  for service in yambar i3status-rust foot pipewire pipewire-pulse wireplumber mako syncthing wl-paste; do
    if ! [[ $(pidof $service) ]]; then
      if [[ "$service" == "foot" ]]; then
        $command "foot --server"
      elif [[ "$service" == "wl-paste" ]]; then
        $command "wl-paste -t text --watch clipman store"
      elif [[ "$service" == "wlsunset" ]]; then
        $command "wlsunset -l 55.27023 -L 9.90081"
      elif [[ "$service" == "yambar" ]]; then
        if [[ "$1" == "river" ]]; then
          $command $service
        fi
      elif [[ "$service" == "i3status-rust" ]]; then
        if [[ "$1" == "sway" ]]; then
          $command $service
        fi
      elif [[ "$service" == "syncthing" ]]; then
        syncthing_start="syncthing serve --no-browser"
        $command $syncthing_start
      else
        $command $service
      fi
    elif [[ $(pidof foot) ]] && [[ "$1" == "sway" ]]; then
      set $term footclient
    fi
  done
