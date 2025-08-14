if [[ $(systemctl is-active wg-quick-wg0.service) == "active" ]]; then
  pkexec systemctl stop wg-quick-wg0.service
else
  pkexec systemctl start wg-quick-wg0.service
fi
pkill -RTMIN+7 waybar
