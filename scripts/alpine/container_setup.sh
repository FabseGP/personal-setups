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
    cd /home/fabsepi/Dockers/Watchtower || exit
    sed -i 's/var\/run\/podman\/podman.sock/var\/run\/docker.sock/g' docker compose.yml
    cd /home/fabsepi/Dockers/Yacht || exit
    sed -i 's/var\/run\/podman\/podman.sock/var\/run\/docker.sock/g' docker compose.yml
  fi

#----------------------------------------------------------------------------------------------------------------------------------

# Dependencies

  pip3 install pipenv
  pip3 install wheel
  sudo ln -sf /home/fabsepi/.local/bin/* /usr/bin

#----------------------------------------------------------------------------------------------------------------------------------

# ArchiveBox

  cd /home/fabsepi/Dockers/ArchiveBox || exit
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Crowdsec

  cd /home/fabsepi/Dockers/Crowdsec || exit
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Cryptofolio

  cd /home/fabsepi/Dockers/Cryptofolio || exit
  mkdir data
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Dashy

  cd /home/fabsepi/Dockers/Dashy || exit
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Docspell

  cd /home/fabsepi/Dockers/Docspell || exit
  mkdir docs
  mkdir docspell-postgres_data
  mkdir docspell-solr_data
  export DOCSPELL_HEADER_VALUE=7hd737sghs7afsus7sgsj
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Exatorrent

  cd /home/fabsepi/Dockers/Exotorrent || exit
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Filebrowser

  cd /home/fabsepi/Dockers/Filebrowser || exit
  mkdir config
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Firefly

  cd /home/fabsepi/Dockers/Firefly || exit
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Grafana

  cd /home/fabsepi/Dockers/Grafana || exit
  docker volume create grafana-storage
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Hedgedoc

  cd /home/fabsepi/Dockers/Hedgedoc || exit
  mkdir data
  mkdir config
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Navidrome

  cd /home/fabsepi/Dockers/Navidrome || exit
  mkdir data
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Netdata

  cd /home/fabsepi/Dockers/Netdata || exit
  mkdir netdatalib
  mkdir netdatacache
  mkdir -p netdataconfig/netdata
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Nginx-proxy-manager

  cd /home/fabsepi/Dockers/Nginx-proxy-manager || exit
  mkdir -p data/nginx
  mkdir letsencrypt
  mkdir -p data/mariadb
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# OpenHAB

  cd /home/fabsepi/Dockers/OpenHAB || exit
  mkdir openhab_addons
  mkdir openhab_conf
  mkdir openhab_userdata
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Photoprism

  cd /home/fabsepi/Dockers/Photoprism || exit
  mkdir data
  mkdir database
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Prometheus

  cd /home/fabsepi/Dockers/Prometheus || exit
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Sharry

  cd /home/fabsepi/Dockers/Sharry || exit
  mkdir postgres_data
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Uptime_kuma

  cd /home/fabsepi/Dockers/Uptime_kuma || exit
  mkdir uptime-kuma
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Vikunja

  cd /home/fabsepi/Dockers/Vikunja || exit
  mkdir files
  mkdir db
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Watchtower

  cd /home/fabsepi/Dockers/Watchtower || exit
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Wiki_js

  cd /home/fabsepi/Dockers/Wiki.js || exit
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Yacht

  cd /home/fabsepi/Dockers/Yacht || exit
  mkdir yacht
  identity_command

#----------------------------------------------------------------------------------------------------------------------------------

# Etherpad (npm)

  cd /home/fabsepi || exit
  git clone --branch develop https://github.com/ether/etherpad-lite.git
  mv Dockers/Etherpad/settings.json /home/fabsepi
  rm Dockers/Etherpad/*
  mv etherpad-lite Dockers/Etherpad
  mv /home/fabsepi/settings.json Dockers/Etherpad/etherpad-lite
  cd Dockers/Etherpad/etherpad-lite || exit
  chmod u+x src/bin/run.sh
  ./src/bin/run.sh
  export NODE_ENV=production
  npm install ep_align ep_font_size ep_font_color ep_comments_page ep_headings2 ep_table_of_contents ep_set_title_on_pad ep_who_did_what ep_what_have_i_missed ep_offline_edit ep_image_upload
  npm audit fix
  npm update -g

#----------------------------------------------------------------------------------------------------------------------------------

# Leon-AI (npm)

  cd /home/fabsepi || exit
  mv Dockers/Leon-AI/.env /home/fabsepi
  rm Dockers/Leon-AI/*
  git clone https://github.com/leon-ai/leon.git leon
  mv leon Dockers/Leon-AI
  mv .env Dockers/Leon-AI/leon
  cd Dockers/Leon-AI/leon || exit
  npm install --save-dev @babel/node
  npm install -g node-gyp
  npm install
  npm run build
  npm audit fix
  
