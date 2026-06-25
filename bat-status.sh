#!/usr/bin/env bash

UPOWER_OUTPUT=${ upower -i /org/freedesktop/UPower/devices/battery_BAT0; }
PERCENT_CHARGED=${ printf "%s\n" "$UPOWER_OUTPUT" | grep percentage | sed -e 's/%//g' | awk '{print $2}'; }
IS_DISCHARGING=${ printf "%s\n" "$UPOWER_OUTPUT" | grep -qe 'state.*discharging'; echo $?; };

if [[ IS_DISCHARGING -eq 0 ]]; then
  if [[ PERCENT_CHARGED -gt 35 ]]; then
    ICON="🔋";
  else
    ICON="🪫";
  fi
else
  ICON="⚡";
fi

echo "${ICON}${PERCENT_CHARGED}%";

