#!/usr/bin/env bash

# Get the WirePlumber device ID for AirPods
get_device_id() {
  wpctl status | grep -m1 'AirPods.*\[bluez5\]' | grep -o '[0-9]\+\.' | tr -d '.'
}

case "${1:-on}" in
  on)
    bluetoothctl connect "$AIRPODS_MACADDR"
    ;;
  off)
    bluetoothctl disconnect "$AIRPODS_MACADDR"
    ;;
  mic)
    # HSP/HFP mSBC — enables mic, but mono low-quality audio
    dev_id=$(get_device_id)
    wpctl set-profile "$dev_id" 196865
    echo "Switched to headset mode (mic enabled, lower quality)"
    ;;
  nomic)
    # A2DP AAC — no mic, best stereo audio quality
    dev_id=$(get_device_id)
    wpctl set-profile "$dev_id" 131076
    echo "Switched to A2DP mode (no mic, high quality)"
    ;;
  *)
    echo "Usage: airpods.sh [on|off|mic|nomic]"
    echo "  on    - connect (default)"
    echo "  off   - disconnect"
    echo "  mic   - enable microphone (lower audio quality)"
    echo "  nomic - disable mic (best audio quality)"
    ;;
esac

