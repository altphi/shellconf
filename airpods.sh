#!/usr/bin/env bash
#
# Requires: bluetoothctl (bluez), wpctl (wireplumber), pw-cli (pipewire)
# Environment: AIRPODS_MACADDR must be set to the device MAC address

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
    local idx
    idx=$(find_profile_index "$dev_id" "$pattern")
    if [[ -n "$idx" ]]; then
      echo "$idx"
      return
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
    if [[ -z "$profile_idx" ]]; then
      echo "Profile still not available after reconnect" >&2; exit 1
    fi
  fi

  wpctl set-profile "$dev_id" "$profile_idx"
  echo "$switch_msg"
}

case "${1:-on}" in
  on)
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
  *)
    echo "Usage: airpods.sh [on|off|mic|nomic]"
    echo "  on    - connect (default)"
    echo "  off   - disconnect"
    echo "  mic   - enable microphone (lower audio quality)"
    echo "  nomic - disable mic (best audio quality)"
    ;;
esac
