#!/usr/bin/env bash

if [[ -z "$1" ]] || [[ "$1" == "on" ]]; then
  bluetoothctl connect "$AIRPODS_MACADDR"
elif [[ "$1" == "off" ]]; then
  bluetoothctl disconnect "$AIRPODS_MACADDR"
fi

