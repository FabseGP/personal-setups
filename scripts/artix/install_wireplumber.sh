#!/bin/bash

  cd /home/fabse
  WIREPLUMBER="$(ls -- *wireplumber-*)"
  doas pacman --noconfirm -U $WIREPLUMBER
  rm -rf $WIREPLUMBER
