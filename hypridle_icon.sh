icon_idle=""
tooltip_text=""
if [[ $(systemctl --user is-active hypridle.service) == "active" ]]; then
  icon_idle=" "
  tooltip_text="hypridle active"
else
  icon_idle="󱣴 "
  tooltip_text="hypridle inactive"
fi
echo "{\"text\": \"$icon_idle\", \"tooltip\": \"$tooltip_text\" }"
