hyprlock &
systemctl --user start hyprpolkitagent &
swww-daemon &
swww img ~/.config/wall/paper &

hyprpm reload -n
waybar &
