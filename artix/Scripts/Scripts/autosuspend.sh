#!/usr/bin/bash

  for f in /sys/bus/usb/devices/*; do
    if [[ -f $f/power/autosuspend_delay_ms ]]; then
      echo 30000 > $f/power/autosuspend_delay_ms
    fi
  done
