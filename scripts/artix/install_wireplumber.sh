#!/bin/bash

  cd /home/$(whoami)
  WIREPLUMBER="$(ls -- *wireplumber-*)"
  doas pacman --noconfirm -U $WIREPLUMBER
  rm -rf $WIREPLUMBER
