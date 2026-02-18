#!/usr/bin/env bash

probe() {
  ffprobe /dev/video0 > /dev/null 2>&1
  sleep 1;
}

if [[ -e /dev/video0 ]]; then
  probe
  probe
  probe
  probe
  probe
  probe
  probe
else
  notify-send "/dev/video0 not found."
fi
