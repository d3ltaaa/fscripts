hyprlock &
systemctl --user start hyprpolkitagent &
swww-daemon &
swww restore &

hyprpm reload -n
waybar &
