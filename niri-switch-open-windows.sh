#!/usr/bin/env bash

niri msg -j windows | jq -r '.[] | "\(.app_id),\(.id)"' | fuzzel --dmenu | cut -d, -f2 | xargs niri msg action focus-window --id
