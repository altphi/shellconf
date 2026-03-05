#!/usr/bin/env bash
# This script makes the webcam go blinky to remind user to close the shutter.
# Run it under a scheduler (e.g. cron) at iteration time of choice.

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
