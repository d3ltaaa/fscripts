icon_vpn=""
tooltip_text=""
if [[ $(systemctl is-enabled wg-quick-wg0.service) == "enabled" ]]; then
  if [[ $(systemctl is-active wg-quick-wg0.service) == "active" ]]; then
    icon_vpn="󰌘 "
    tooltip_text="VPN connected"
  else
    icon_vpn="󰌙 "
    tooltip_text="VPN disconnected"
  fi
  echo "{\"text\": \"$icon_vpn\", \"tooltip\": \"$tooltip_text\" }"
fi
