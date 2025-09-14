#!/run/current-system/sw/bin/bash

if [ $MONITOR_TYPE == "external" ]; then
  # system uses ddcutil
  # brightness=$(ddcutil getvcp 10 2>/dev/null | grep -oP 'current value =\s*\K[0-9]+')
  if [ -n "$brightness" ]; then
    echo "idk$brightness"
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


