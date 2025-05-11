# menu="dmenu -i"
menu="rofi -dmenu -i"
# take screenshot and open
grim -g "$(slurp)" "$(echo $(echo $XDG_SCREENSHOT_DIR))/temp.png" &&
  feh --scale-down --auto-zoom "$(echo $XDG_SCREENSHOT_DIR)/temp.png" &&
  selected=$(printf 'yes\nno' | $menu -p "Save?:")
case $selected in
"yes")
  # give name
  NAME="$($menu -p "Name:")"
  FILE_NAME="$(echo $XDG_SCREENSHOT_DIR)/$NAME.png"
  mv "$(echo $XDG_SCREENSHOT_DIR)/temp.png" "$FILE_NAME"
  exit 0
  ;;

"*") ;;
esac
# delete if not yes (also if menu is cancelled)
rm "$(echo $XDG_SCREENSHOT_DIR)/temp.png"
