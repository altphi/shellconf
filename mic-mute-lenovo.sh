#!/usr/bin/env bash
INPUT_DEVICE="Capture"
if amixer sget "$INPUT_DEVICE",0 | grep '\[on\]'; then
  amixer sset "$INPUT_DEVICE",0 toggle
  echo 1 | tee /sys/class/leds/platform::micmute/brightness
else
  amixer sset "$INPUT_DEVICE",0 toggle
  echo 0 | tee /sys/class/leds/platform::micmute/brightness
fi
