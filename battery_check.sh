#!/usr/bin/env bash
# Polled by eww. Echoes battery percentage AND fires desktop
# notifications when crossing low-battery thresholds while discharging.

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/battery_alerts"
mkdir -p "$STATE_DIR"

info=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0)
pct=$(echo "$info" | awk '/percentage/ {gsub("%",""); print $2}')
state=$(echo "$info" | awk '/state:/ {print $2}')

# Output for eww (preserves the "%" suffix the previous command produced)
echo "${pct}%"

# Only alert when actually discharging; clear markers otherwise so we
# get warned again on the next discharge cycle.
if [ "$state" != "discharging" ]; then
    rm -f "$STATE_DIR"/alerted_*
    exit 0
fi

alert() {
    local threshold=$1 urgency=$2 msg=$3
    local marker="$STATE_DIR/alerted_${threshold}"
    if [ "$pct" -le "$threshold" ] && [ ! -f "$marker" ]; then
        notify-send -u "$urgency" "Battery low" "$msg (${pct}%)"
        touch "$marker"
    elif [ "$pct" -gt "$threshold" ]; then
        rm -f "$marker"
    fi
}

alert 30 normal   "Plug in soon"
alert 20 normal   "Plug in soooon"
alert 10 critical "Battery critical"
alert 5  critical "Plug in NOW"
