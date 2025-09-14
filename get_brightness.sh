#!/run/current-system/sw/bin/bash

if [ $MONITOR_TYPE == "external" ]; then
  # system uses ddcutil
  brightness=$(ddcutil getvcp --display 1 10 | grep -oP 'current value =\s*\K[0-9]+')
  if [ -n "$brightness" ]; then
    echo "$brightness"
  fi
elif [ $MONITOR_TYPE == "internal" ]; then
  # system uses brightnessctl
  brightness=$(brightnessctl get)
  max_brightness=$(brightnessctl max)
  if [ -n "$brightness" ] && [ -n "$max_brightness" ]; then
    brightness_percent=$(( (brightness * 100) / max_brightness ))
    echo "$brightness_percent"
  fi
fi


