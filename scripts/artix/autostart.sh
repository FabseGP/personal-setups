#!/bin/sh

  for service in yambar foot pipewire pipewire-pulse wireplumber mako syncthing wl-paste; do
    if [[ "$1" == "sway" ]]; then
      rm -rf /home/fabse/.config/sway/{exec,terminal}
      touch /home/fabse/.config/sway/{exec,terminal}
      if ! [[ $(pidof $service) ]]; then
        if [[ "$service" == "foot" ]]; then
          cat << EOF | tee -a /home/fabse/.config/sway/exec > /dev/null
exec foot --server
EOF
          cat << EOF | tee -a /home/fabse/.config/sway/terminal > /dev/null
set \$term footclient
EOF
        elif [[ "$service" == "wl-paste" ]]; then
          cat << EOF | tee -a /home/fabse/.config/sway/exec > /dev/null
exec wl-paste -t text --watch clipman store
EOF
        elif [[ "$service" == "wlsunset" ]]; then
          cat << EOF | tee -a /home/fabse/.config/sway/exec > /dev/null
exec wlsunset -l 55.27023 -L 9.90081
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
      elif [[ $(pidof foot) ]]; then
        cat << EOF | tee -a /home/fabse/.config/sway/terminal > /dev/null
set \$term foot
EOF
      fi
    elif [[ "$1" == "river" ]]; then
      if ! [[ $(pidof $service) ]]; then
        if [[ "$service" == "foot" ]]; then
          riverctl spawn "foot --server"
        elif [[ "$service" == "wl-paste" ]]; then
          riverctl spawn "wl-paste -t text --watch clipman store"
        elif [[ "$service" == "wlsunset" ]]; then
          riverctl spawn "wlsunset -l 55.27023 -L 9.90081"
        elif [[ "$service" == "syncthing" ]]; then
          riverctl spawn "syncthing serve --no-browser"
        else
          riverctl spawn $service
        fi
      fi
    fi
  done
