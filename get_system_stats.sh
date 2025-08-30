# Initialize variables
power_stat_factor="1.075"
total_power_draw=0
total_remaining_capacity=0
total_capacity=0
battery_count=0
charging=false
desktop=true
governor_path="/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"

# Define battery icons
CHARGING_ICONS=("󰢜" "󰂆" "󰂇" "󰂈" "󰢝" "󰂉" "󰢞" "󰂊" "󰂋" "󰂅")
DEFAULT_ICONS=("󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹")

format_string() {
  local content="$1"
  local width="$2"
  local length="${#content}"
  if [ $length -lt $width ]; then
    printf "%*s%s" $((width - length)) "" "$content"
  else
    printf "%s" "$content"
  fi
}

if [[ "$(cat $governor_path)" == "performance" ]]; then
  governor_string="󰓅";
elif [[ "$(cat $governor_path)" == "powersave" ]]; then
  governor_string="󰾆";
else
  governor_string="?";
fi

# Loop through possible battery files (BAT0, BAT1, etc.)
for battery in /sys/class/power_supply/BAT*; do
  # Check if the battery exists and is readable
  desktop=false

  if [ -f "$battery/power_now" ]; then
    power_now=$(cat "$battery/power_now")
    total_power_draw=$((total_power_draw + power_now))
  elif [ -f "$battery/current_now" ] && [ -f "$battery/voltage_now" ]; then
    current_now=$(cat "$battery/current_now")
    voltage_now=$(cat "$battery/voltage_now")
    power_now=$(echo "scale=0; ($current_now * $voltage_now) / 1000000" | bc)
    total_power_draw=$((total_power_draw + power_now))
  fi

  if [ -f "$battery/energy_full" ] && [ -f "$battery/energy_now" ] && [ -f "$battery/status" ]; then
    if [[ "$(cat $battery/status)" == "Charging" ]]; then
      charging=true
    fi
    full_capacity=$(cat "$battery/energy_full")
    remaining_capacity=$(cat "$battery/energy_now")

    total_capacity=$((total_capacity + full_capacity))
    total_remaining_capacity=$((total_remaining_capacity + remaining_capacity))

    # Update battery count
  elif [ -f "$battery/charge_full" ] && [ -f "$battery/charge_now" ] && [ -f "$battery/status" ]; then
    if [[ "$(cat $battery/status)" == "Charging" ]]; then
      charging=true
    fi
    charge_now=$(cat $battery/charge_now)
    charge_full=$(cat $battery/charge_full)
    voltage_now=$(cat $battery/voltage_now)

    # Convert to microwatt-hours
    full_capacity=$(echo "scale=0; ($charge_full * $voltage_now) / 1000000" | bc)
    remaining_capacity=$(echo "scale=0; ($charge_now * $voltage_now) / 1000000" | bc)

    total_capacity=$((total_capacity + full_capacity))
    total_remaining_capacity=$((total_remaining_capacity + remaining_capacity))

  fi
  battery_count=$((battery_count + 1))
done

# If we found at least one battery, calculate and print the results
if [ "$battery_count" -gt 0 ]; then

  # Calculate total power draw in watts (from microwatts to watts)
  power_draw_watts=$(echo "scale=1; $total_power_draw * $power_stat_factor/1000000" | bc)

  # Calculate combined time remaining in seconds (total remaining capacity divided by total power draw)
  if [ "$total_power_draw" -gt 0 ]; then
    # Remaining time in seconds
    if $charging; then
      remaining_time_seconds=$(echo "scale=1; ($total_capacity - $total_remaining_capacity)/($total_power_draw * $power_stat_factor)" | bc)
    else
      remaining_time_seconds=$(echo "scale=1; $total_remaining_capacity/($total_power_draw * $power_stat_factor)" | bc)
    fi
  else
    remaining_time_seconds=0
  fi

  # Print the output
  fixed_power_draw_watts=$(format_string "$power_draw_watts" 4)
  fixed_remaining_time_seconds=$(format_string "$remaining_time_seconds" 4)
  power_string="${fixed_power_draw_watts}W $governor_string    ${remaining_time_seconds}H "

  battery_percentage=$((100 * $total_remaining_capacity / $total_capacity))
  # Determine icon index (0-9 scale)
  icon_index=$((battery_percentage / 10))
  if [[ $icon_index -gt 9 ]]; then
    icon_index=9
  fi

  # Choose the appropriate icon
  if [[ "$charging" == "true" ]]; then
    icon=${CHARGING_ICONS[$icon_index]}
  else
    icon=${DEFAULT_ICONS[$icon_index]}
  fi
  fixed_battery_string=$(format_string "$fixed_battery_string" 3)
  battery_string="$battery_percentage% $icon"
fi

# echo $total_remaining_capacity / $total_capacity = $battery_percentage

# Get CPU usage
# CPU_USAGE=$(mpstat 1 1 | awk '/Average/ {print 100 - $NF"%"}')

# Get RAM usage
RAM_USED=$(free -h | awk '/Mem:/ {print $3}' | sed 's/i//')
RAM_TOTAL=$(free -h | awk '/Mem:/ {print $2}' | sed 's/i//')
ram_string="$RAM_USED/$RAM_TOTAL  "

# Cpu temp

# Check if the temperature file exists
temp_file="/sys/class/thermal/thermal_zone0/temp"

if [ -f "$temp_file" ]; then
  # Read the temperature (it is in millidegrees Celsius)
  cpu_temp_millidegrees=$(cat "$temp_file")

  # Convert to degrees Celsius
  cpu_temp=$((cpu_temp_millidegrees / 1000))

  # Print the temperature
  cpu_string="$cpu_temp°C  "
fi

# Output JSON for Waybar
# echo "{\"text\": \"󰘚 CPU: $CPU_USAGE |  RAM: $RAM_USED/$RAM_TOTAL | 🌡️ Temp: $TEMP | 🔋 Power: $POWER\"}"
# echo "{\"text\": \" \", \"tooltip\": \"$ram_string\n$cpu_string\n$power_string\"}"

if $desktop; then
  echo "{\"text\": \"$ram_string    $cpu_string\", \"tooltip\": \"Brightness: $(get_brightness.sh)%\"}"
else
  echo "{\"text\": \"$power_string    $battery_string\", \"tooltip\": \"$ram_string\n\n$cpu_string\nBrightness: $(get_brightness.sh)%\" }"
fi

