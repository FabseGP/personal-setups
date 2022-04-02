#!/bin/bash

  world=$(pacman -Ss wireplumber | head -n 1)
  local=$(pacman -Qs wireplumber | head -n 1)
  cut=${world%" [installed]"*}
  world_wireplumber=${cut#*/}
  local_wireplumber=${local#*/}

  make_wireplumber() {
    cd /home/fabse
    rm -rf wireplumber_make
    mkdir wireplumber_make
    cd wireplumber_make
    wget -q –output-document PKGBUILD https://gitea.artixlinux.org/packagesW/wireplumber/raw/branch/master/x86_64/extra/PKGBUILD
    sed -i '/    -D systemd=disabled/a    -D elogind=disabled' PKGBUILD
    sed -i 's/pkgname=(wireplumber wireplumber-docs)/pkgname=(wireplumber)/' PKGBUILD
    sed -i 's/options=(debug)/options=()/' PKGBUILD
    sed -i '/^package_wireplumber-docs() {$/,/^}$/d' PKGBUILD
    makepkg -s
    cd /home/fabse
    cp wireplumber_make/wireplumber-* /home/fabse
    rm -rf wireplumber_make
}

  if [[ "$world_wireplumber" != "$local_wireplumber" ]]; then
    make_wireplumber
  else
    :
  fi
