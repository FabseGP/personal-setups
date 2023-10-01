#!/bin/bash

  if [[ "$1" == "sway" ]]; then
    rm -rf /home/$(whoami)/.config/sway/exec
    touch /home/$(whoami)/.config/sway/exec
  fi
  for service in yambar foot mako wl-paste; do
    if [[ "$1" == "sway" ]]; then
      if ! [[ $(pidof $service) ]]; then
        if [[ "$service" == "foot" ]]; then
          cat << EOF | tee -a /home/$(whoami)/.config/sway/exec > /dev/null
exec_always foot --server
EOF
        elif [[ "$service" == "wl-paste" ]]; then
          cat << EOF | tee -a /home/$(whoami)/.config/sway/exec > /dev/null
exec_always wl-paste -t text --watch clipman store
EOF
        elif [[ "$service" == "yambar" ]]; then
          :
        else
          cat << EOF | tee -a /home/$(whoami)/.config/sway/exec > /dev/null
exec_always $service
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
        else
          riverctl spawn $service
        fi
      elif [[ $(pidof $service) ]]; then
        :
      fi
    fi
  done
