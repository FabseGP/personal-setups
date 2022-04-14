#!/bin/bash

# Parameters

  identity=""
  identity_command=""

#----------------------------------------------------------------------------------------------------------------------------------

# Doas or sudo

  read -rp "Are you, sir, using either \"podman\" or \"docker\"? " identity
  if [ "$identity" == podman ]; then
    identity_command="DOCKER_HOST=unix:///run/podman/podman.sock docker compose up -d"
    podman network create pacman
  elif [ "$identity" == docker ]; then
    identity_command="docker compose up -d"
    docker network create pacman
    cd /home/fabsepi/dockers/Watchtower || exit
    sed -i 's/var\/run\/podman\/podman.sock/var\/run\/docker.sock/g' docker compose.yml
    cd /home/fabsepi/dockers/Yacht || exit
    sed -i 's/var\/run\/podman\/podman.sock/var\/run\/docker.sock/g' docker compose.yml
  fi

#----------------------------------------------------------------------------------------------------------------------------------

# Dependencies

  pip3 install pipenv
  pip3 install wheel
  sudo ln -sf /home/fabsepi/.local/bin/* /usr/bin

#----------------------------------------------------------------------------------------------------------------------------------

# ArchiveBox

  cd /home/fabsepi/dockers/ArchiveBox || exit
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Crowdsec

  cd /home/fabsepi/dockers/Crowdsec || exit
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Cryptofolio

  cd /home/fabsepi/dockers/Cryptofolio || exit
  mkdir data
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Dashy

  cd /home/fabsepi/dockers/Dashy || exit
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Docspell

  cd /home/fabsepi/dockers/Docspell || exit
  mkdir docs
  mkdir docspell-postgres_data
  mkdir docspell-solr_data
  export DOCSPELL_HEADER_VALUE=7hd737sghs7afsus7sgsj
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Exatorrent

  cd /home/fabsepi/dockers/Exotorrent || exit
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Filebrowser

  cd /home/fabsepi/dockers/Filebrowser || exit
  mkdir config
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Firefly

  cd /home/fabsepi/dockers/Firefly || exit
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Grafana

  cd /home/fabsepi/dockers/Grafana || exit
  docker volume create grafana-storage
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Hedgedoc

  cd /home/fabsepi/dockers/Hedgedoc || exit
  mkdir data
  mkdir config
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Navidrome

  cd /home/fabsepi/dockers/Navidrome || exit
  mkdir data
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Netdata

  cd /home/fabsepi/dockers/Netdata || exit
  mkdir netdatalib
  mkdir netdatacache
  mkdir -p netdataconfig/netdata
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Nginx-proxy-manager

  cd /home/fabsepi/dockers/Nginx-proxy-manager || exit
  mkdir -p data/nginx
  mkdir letsencrypt
  mkdir -p data/mariadb
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# OpenHAB

  cd /home/fabsepi/dockers/OpenHAB || exit
  mkdir openhab_addons
  mkdir openhab_conf
  mkdir openhab_userdata
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Photoprism

  cd /home/fabsepi/dockers/Photoprism || exit
  mkdir data
  mkdir database
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Prometheus

  cd /home/fabsepi/dockers/Prometheus || exit
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Sharry

  cd /home/fabsepi/dockers/Sharry || exit
  mkdir postgres_data
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Uptime_kuma

  cd /home/fabsepi/dockers/Uptime_kuma || exit
  mkdir uptime-kuma
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Vikunja

  cd /home/fabsepi/dockers/Vikunja || exit
  mkdir files
  mkdir db
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Watchtower

  cd /home/fabsepi/dockers/Watchtower || exit
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Wiki_js

  cd /home/fabsepi/dockers/Wiki.js || exit
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Yacht

  cd /home/fabsepi/dockers/Yacht || exit
  mkdir yacht
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Etherpad (npm)

  cd /home/fabsepi || exit
  git clone --branch develop https://github.com/ether/etherpad-lite.git
  mv dockers/Etherpad/settings.json /home/fabsepi
  rm dockers/Etherpad/*
  mv etherpad-lite dockers/Etherpad
  mv /home/fabsepi/settings.json dockers/Etherpad/etherpad-lite
  cd dockers/Etherpad/etherpad-lite || exit
  chmod u+x src/bin/run.sh
  ./src/bin/run.sh
  export NODE_ENV=production
  npm install ep_align ep_font_size ep_font_color ep_comments_page ep_headings2 ep_table_of_contents ep_set_title_on_pad ep_who_did_what ep_what_have_i_missed ep_offline_edit ep_image_upload
  npm audit fix
  npm update -g

#----------------------------------------------------------------------------------------------------------------------------------

# Leon-AI (npm)

  cd /home/fabsepi || exit
  mv dockers/Leon-AI/.env /home/fabsepi
  rm dockers/Leon-AI/*
  git clone https://github.com/leon-ai/leon.git leon
  mv leon dockers/Leon-AI
  mv .env dockers/Leon-AI/leon
  cd dockers/Leon-AI/leon || exit
  npm install --save-dev @babel/node
  npm install -g node-gyp
  npm install
  npm run build
  npm audit fix
  
