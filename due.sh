#!/usr/bin/env bash
# due.sh — minimal reminders with snooze for mako + notify-send + fuzzel

# Snooze options: "label:seconds"
snoozes=(
  "30s:30"
  "5m:300"
  "10m:600"
  "30m:1800"
)

msg="${*:-Take a break}"

nid=$(notify-send -p -a due "$msg")

menu=$(printf "%s\n" "${snoozes[@]%%:*}" "Done")
choice=$(echo "$menu" | fuzzel -d -p "Reminder: ")

for s in "${snoozes[@]}"; do
  if [[ "${s%%:*}" == "$choice" ]]; then
    (sleep "${s##*:}"; exec "$0" "$msg") &
    exit
  fi
done

makoctl dismiss -n "$nid" 2>/dev/null
