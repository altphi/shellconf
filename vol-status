#!/usr/bin/env bash

out=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
if [[ "$out" == *MUTED* ]]; then
  echo "🔇"
else
  echo "🔊 ${out#Volume: }"
fi
