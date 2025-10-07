terminal="foot -e"
if [[ $(systemctl is-active wg-quick-wg0.service) == "active" ]]; then
  hyprctl dispatch exec "[float;size 800 500] $terminal sudo systemctl stop wg-quick-wg0.service"
else
  hyprctl dispatch exec "[float;size 800 500] $terminal sudo systemctl start wg-quick-wg0.service"
fi
pkill -RTMIN+7 waybar
