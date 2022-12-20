#!/usr/bin/bash

  git clone https://github.com/badabing2005/PixelFlasher.git
  cd PixelFlasher || exit
  pip3 install virtualenv wheel
  python3 -m venv venv
  . venv/bin/activate
  pip3 install -r requirements.txt
  ./build.sh
