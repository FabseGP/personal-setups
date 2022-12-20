#!/bin/bash

mkdir -p ~/.config/wireplumber/bluetooth.lua.d
cp /usr/share/wireplumber/bluetooth.lua.d/50-bluez-config.lua ~/.config/wireplumber/bluetooth.lua.d/
line_number=$(grep -wn with-logind ~/.config/wireplumber/bluetooth.lua.d/50-bluez-config.lua | cut -d: -f1)
sed -i ''$line_number's/.*/["with-logind"] = false/' ~/.config/wireplumber/bluetooth.lua.d/50-bluez-config.lua