#!/usr/bin/env bash

PERCENT_CHARGED=`upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage | sed -e 's/%//g' | awk '{print $2}'`

if [[ PERCENT_CHARGED -gt 35 ]]; then
  ICON="🔋";
else
  ICON="🪫";
fi

echo "${ICON}${PERCENT_CHARGED}%";

