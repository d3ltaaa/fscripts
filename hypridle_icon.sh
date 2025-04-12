icon_idle=""
if [[ $(systemctl --user is-active hypridle.service) == "active" ]]; then
  icon_idle=" "
else
  icon_idle="󱣴 "
fi
echo "{\"text\": \"$icon_idle\" }"
