#!/bin/bash

  if [[ "$1" == "sway" ]]; then
    rm -rf /home/fabse/.config/sway/exec
    touch /home/fabse/.config/sway/exec
  fi
  for service in yambar foot pipewire mako syncthing wl-paste; do
    if [[ "$1" == "sway" ]]; then
      if ! [[ $(pidof $service) ]]; then
        if [[ "$service" == "foot" ]]; then
          cat << EOF | tee -a /home/fabse/.config/sway/exec > /dev/null
exec foot --server
EOF
        elif [[ "$service" == "wl-paste" ]]; then
          cat << EOF | tee -a /home/fabse/.config/sway/exec > /dev/null
exec wl-paste -t text --watch clipman store
EOF
        elif [[ "$service" == "syncthing" ]]; then
          cat << EOF | tee -a /home/fabse/.config/sway/exec > /dev/null
exec syncthing serve --no-browser
EOF
        elif [[ "$service" == "yambar" ]]; then
          :
        else
          cat << EOF | tee -a /home/fabse/.config/sway/exec > /dev/null
exec $service
EOF
        fi
      elif [[ $(pidof $service) ]]; then
        :
      fi
    elif [[ "$1" == "river" ]]; then
      if ! [[ $(pidof $service) ]]; then
        if [[ "$service" == "foot" ]]; then
          riverctl spawn "foot --server"
        elif [[ "$service" == "wl-paste" ]]; then
          riverctl spawn "wl-paste -t text --watch clipman store"
        elif [[ "$service" == "syncthing" ]]; then
          riverctl spawn "syncthing serve --no-browser"
        else
          riverctl spawn $service
        fi
      elif [[ $(pidof $service) ]]; then
        :
      fi
    fi
  done
