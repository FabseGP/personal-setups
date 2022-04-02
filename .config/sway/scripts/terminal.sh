#!/bin/bash

  rm -rf /home/fabse/.config/sway/terminal
  touch /home/fabse/.config/sway/terminal
  if ! [[ $(pidof foot) ]]; then
    cat << EOF | tee -a /home/fabse/.config/sway/terminal > /dev/null
set \$term footclient
EOF
  elif [[ $(pidof foot) ]]; then
    if ! [[ $(pidof river) ]]; then
      cat << EOF | tee -a /home/fabse/.config/sway/terminal > /dev/null
set \$term footclient
EOF
    else
      cat << EOF | tee -a /home/fabse/.config/sway/terminal > /dev/null
set \$term foot
EOF
    fi
  fi
