if [[ $(systemctl is-active wg-quick-wg0.service) == "active" ]]; then
  foot -e systemctl stop wg-quick-wg0.service
else
  foot -e systemctl start wg-quick-wg0.service
fi
pkill -RTMIN+7 waybar
