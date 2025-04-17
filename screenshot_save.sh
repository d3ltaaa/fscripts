# menu="dmenu -i"
menu="rofi -dmenu -i"
XDG_SCREENSHOT_DIR="/home/falk/Pictures/Screenshots"
# take screenshot and open
grim -g "$(slurp)" "$XDG_SCREENSHOT_DIR/temp.png" &&
  feh --scale-down --auto-zoom "$XDG_SCREENSHOT_DIR/temp.png" &&
  selected=$(printf 'yes\nno' | $menu -p "Save?:")
case $selected in
"yes")
  # give name
  NAME="$($menu -p "Name:")"
  FILE_NAME="$XDG_SCREENSHOT_DIR/$NAME.png"
  mv "$XDG_SCREENSHOT_DIR/temp.png" "$FILE_NAME"
  exit 0
  ;;

"*") ;;
esac
# delete if not yes (also if menu is cancelled)
rm "$XDG_SCREENSHOT_DIR/temp.png"
