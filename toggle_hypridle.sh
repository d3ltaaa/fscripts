icon_idle=""
if [[ $(systemctl --user is-active hypridle.service) == "active" ]]; then
  systemctl --user stop hypridle.service
  icon_idle="󱣴"
else
  systemctl --user start hypridle.service
  icon_idle=""
fi
echo "{\"text\": \" $icon_idle \" }"
