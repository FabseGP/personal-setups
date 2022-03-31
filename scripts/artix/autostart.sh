#!/bin/sh

  if [[ "$1" == "sway" ]]; then
    rm -rf /home/fabse/.config/sway/{exec,terminal}
    touch /home/fabse/.config/sway/{exec,terminal}
  fi
  for service in yambar foot pipewire pipewire-pulse wireplumber mako syncthing wl-paste; do
    if [[ "$1" == "sway" ]]; then
      if ! [[ $(pidof $service) ]]; then
        if [[ "$service" == "foot" ]]; then
          cat << EOF | tee -a /home/fabse/.config/sway/exec > /dev/null
exec_always foot --server
EOF
          cat << EOF | tee -a /home/fabse/.config/sway/terminal > /dev/null
set \$term footclient
EOF
        elif [[ "$service" == "wl-paste" ]]; then
          cat << EOF | tee -a /home/fabse/.config/sway/exec > /dev/null
exec_always wl-paste -t text --watch clipman store
EOF
        elif [[ "$service" == "syncthing" ]]; then
          cat << EOF | tee -a /home/fabse/.config/sway/exec > /dev/null
exec_always syncthing serve --no-browser
EOF
        elif [[ "$service" == "yambar" ]]; then
          :
        else
          cat << EOF | tee -a /home/fabse/.config/sway/exec > /dev/null
exec_always $service
EOF
        fi
      elif [[ $(pidof foot) ]]; then
        cat << EOF | tee -a /home/fabse/.config/sway/terminal > /dev/null
set \$term foot
EOF
      fi
      chmod u+x /home/fabse/.config/sway/exec
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
      fi
    fi
  done
