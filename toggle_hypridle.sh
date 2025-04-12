if [[ $(systemctl --user is-active hypridle.service) == "active" ]]; then
  systemctl --user stop hypridle.service
else
  systemctl --user start hypridle.service
fi
pkill -RTMIN+6 waybar
