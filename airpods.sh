#!/usr/bin/env bash
#
# Requires: bluetoothctl (bluez), wpctl (wireplumber), pw-cli (pipewire)
# Environment: AIRPODS_MACADDR must be set to the device MAC address

if [[ "$1" == "--completions" ]]; then
  echo "on off mic nomic status"
  exit 0
fi

get_wireplumber_device_id() {
  wpctl status | grep -m1 'AirPods.*\[bluez5\]' | grep -o '[0-9]\+\.' | tr -d '.'
}

find_profile_index() {
  local dev_id="$1" pattern="$2"
  local idx=""
  while IFS= read -r line; do
    if [[ "$line" == *"Profile:index"* ]]; then
      IFS= read -r line
      idx="${line##*Int }"
      idx="${idx// /}"
    elif [[ "$line" == *"Profile:name"* ]]; then
      IFS= read -r line
      if [[ "$line" == *"$pattern"* ]]; then
        echo "$idx"
        return
      fi
    fi
  done < <(pw-cli enum-params "$dev_id" EnumProfile 2>/dev/null)
}

current_profile_name() {
  local dev_id="$1"
  while IFS= read -r line; do
    if [[ "$line" == *"Profile:name"* ]]; then
      IFS= read -r line
      line="${line#*\"}"
      line="${line%\"*}"
      echo "$line"
      return
    fi
  done < <(pw-cli enum-params "$dev_id" Profile 2>/dev/null)
}

connect_and_wait_for_device_load() {
  bluetoothctl disconnect "$AIRPODS_MACADDR" &>/dev/null
  sleep 2
  bluetoothctl trust "$AIRPODS_MACADDR" &>/dev/null
  bluetoothctl connect "$AIRPODS_MACADDR" &>/dev/null
  local attempts=0
  while [[ -z "$(get_wireplumber_device_id)" && $attempts -lt 10 ]]; do
    sleep 1
    ((attempts++))
  done
  attempts=0
  while ! wpctl status 2>/dev/null | sed -n '/Sinks:/,/Sources:/p' | grep -q 'AirPods'; do
    sleep 1
    ((attempts++))
    if [[ $attempts -ge 15 ]]; then break; fi
  done
  sleep 3
  get_wireplumber_device_id
}

wait_for_profile_load() {
  local dev_id="$1" pattern="$2"
  local attempts=0
  while [[ $attempts -lt 15 ]]; do
    dev_id=$(get_wireplumber_device_id)
    if [[ -n "$dev_id" ]]; then
      local idx
      idx=$(find_profile_index "$dev_id" "$pattern")
      if [[ -n "$idx" ]]; then
        echo "$idx"
        return
      fi
    fi
    sleep 1
    ((attempts++))
  done
}

set_profile() {
  local pattern="$1" already_msg="$2" switch_msg="$3"
  local dev_id profile_idx current fresh_connect=false

  dev_id=$(get_wireplumber_device_id)
  if [[ -z "$dev_id" ]]; then
    echo "Connecting AirPods..."
    dev_id=$(connect_and_wait_for_device_load)
    if [[ -z "$dev_id" ]]; then
      echo "Failed to connect AirPods" >&2; exit 1
    fi
    fresh_connect=true
  fi

  if [[ "$fresh_connect" == false ]]; then
    current=$(current_profile_name "$dev_id")
    if [[ "$current" == *"$pattern"* ]]; then
      echo "$already_msg"
      exit 0
    fi
  fi

  echo "Waiting for profile..."
  profile_idx=$(wait_for_profile_load "$dev_id" "$pattern")
  if [[ -z "$profile_idx" ]]; then
    echo "Profile not available, reconnecting to renegotiate..."
    dev_id=$(connect_and_wait_for_device_load)
    if [[ -z "$dev_id" ]]; then
      echo "Failed to reconnect AirPods" >&2; exit 1
    fi
    profile_idx=$(wait_for_profile_load "$dev_id" "$pattern")
  fi
  if [[ -z "$profile_idx" ]]; then
    echo "Profile still not available, full reset of bluetooth stack..."
    bluetoothctl disconnect "$AIRPODS_MACADDR" &>/dev/null
    # Untrust to prevent auto-reconnect during restart
    bluetoothctl untrust "$AIRPODS_MACADDR" &>/dev/null
    sleep 1
    sudo systemctl restart bluetooth
    sleep 2
    systemctl --user restart pipewire wireplumber
    # Wait for wireplumber to register A2DP endpoints with bluez
    sleep 3
    # Now trust and connect — A2DP endpoints are already registered
    bluetoothctl trust "$AIRPODS_MACADDR" &>/dev/null
    dev_id=$(connect_and_wait_for_device_load)
    if [[ -z "$dev_id" ]]; then
      echo "Failed to reconnect AirPods after full restart" >&2; exit 1
    fi
    profile_idx=$(wait_for_profile_load "$dev_id" "$pattern")
    if [[ -z "$profile_idx" ]]; then
      echo "Profile still not available after full restart" >&2; exit 1
    fi
  fi

  wpctl set-profile "$dev_id" "$profile_idx"
  echo "$switch_msg"
}

show_status() {
  local connected dev_id profile volume
  connected=$(bluetoothctl info "$AIRPODS_MACADDR" 2>/dev/null | grep -m1 "Connected:" | awk '{print $2}')
  if [[ "$connected" != "yes" ]]; then
    echo "AirPods: disconnected"
    return
  fi
  echo "AirPods: connected"
  dev_id=$(get_wireplumber_device_id)
  if [[ -z "$dev_id" ]]; then
    echo "Profile: (device not yet available in PipeWire)"
    return
  fi
  profile=$(current_profile_name "$dev_id")
  local codec mode
  case "$profile" in
    headset-head-unit-*)  mode="headset (mic enabled, lower quality)"; codec="${profile#headset-head-unit-}" ;;
    headset-head-unit)    mode="headset (mic enabled, lower quality)"; codec="mSBC" ;;
    a2dp-sink-*)          mode="A2DP hi-fi (no mic)"; codec="${profile#a2dp-sink-}" ;;
    a2dp-sink)            mode="A2DP hi-fi (no mic)"; codec="AAC" ;;
    *)                    mode="$profile"; codec="unknown" ;;
  esac
  echo "Mode: $mode"
  echo "Codec: ${codec^^}"
  volume=$(wpctl get-volume "$(wpctl status | grep -A50 'Sinks:' | grep -m1 'AirPods' | grep -o '[0-9]\+\.' | tr -d '.')" 2>/dev/null)
  if [[ -n "$volume" ]]; then
    echo "Volume: ${volume#Volume: }"
  fi
}

case "${1:-on}" in
  on)
    bluetoothctl trust "$AIRPODS_MACADDR" &>/dev/null
    bluetoothctl connect "$AIRPODS_MACADDR"
    ;;
  off)
    bluetoothctl disconnect "$AIRPODS_MACADDR"
    ;;
  mic)
    set_profile "headset-head-unit" \
      "Already in headset mode (mic enabled)" \
      "Switched to headset mode (mic enabled, lower quality)"
    ;;
  nomic)
    set_profile "a2dp-sink" \
      "Already in A2DP mode (no mic, high quality)" \
      "Switched to A2DP mode (no mic, high quality)"
    ;;
  status|info)
    show_status
    ;;
  *)
    echo "Usage: airpods.sh [on|off|mic|nomic|status]"
    echo "  on     - connect (default)"
    echo "  off    - disconnect"
    echo "  mic    - enable microphone (lower audio quality)"
    echo "  nomic  - disable mic (best audio quality)"
    echo "  status - show current connection and profile info"
    ;;
esac
