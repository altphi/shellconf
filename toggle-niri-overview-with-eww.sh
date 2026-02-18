#!/usr/bin/env bash

if [[ -n $(eww active-windows | grep bar) ]]; then
  eww close bar
  niri msg action close-overview
else
  eww open bar
  niri msg action open-overview
fi

