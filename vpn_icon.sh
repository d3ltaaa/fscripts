icon_vpn=""
if [[ $(systemctl is-enabled wg-quick-wg0.service) == "enabled" ]]; then
  if [[ $(systemctl is-active wg-quick-wg0.service) == "active" ]]; then
    icon_vpn="󰌘 "
  else
    icon_vpn="󰌙 "
  fi
  echo "{\"text\": \"$icon_vpn\" }"
fi
