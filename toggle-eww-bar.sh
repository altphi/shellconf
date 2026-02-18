#!/usr/bin/env bash

if [[ -n $(eww active-windows | grep bar) ]]; then
  eww close bar
else
  eww open bar
fi
