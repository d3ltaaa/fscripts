icon_vpn=""
tooltip_text=""
if [[ $(systemctl is-enabled wg-quick-wg0.service) == "enabled" ]]; then
  ping -c 1 "1.1.1.1" > /dev/null 2>&1
  internet_status=$?

  if [[ $(systemctl is-active wg-quick-wg0.service) == "active" ]]; then
    icon_vpn="󰌘 "
    tooltip_text="VPN connected"
  else
    icon_vpn="󰌙 "
    tooltip_text="VPN disconnected"
  fi

  if [ $internet_status -eq 0 ]; then
    internet_text=""
  else
    internet_text=""
  fi

  echo "{\"text\": \"$icon_vpn - $internet_text\", \"tooltip\": \"$tooltip_text\" }"
fi
