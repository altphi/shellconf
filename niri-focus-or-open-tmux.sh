#!/usr/bin/env bash
set -x

if [[ "$#" -eq 1 ]]; then
  NAME="com.tmux.${1}"
else
  NAME="com.tmux.main"
fi

WINDOW_ENTRY=`niri msg -j windows | jq -r '.[] | "\(.app_id),\(.id)"' | grep "${NAME}"`

if [[ ! -z "$WINDOW_ENTRY" ]]; then
  echo "$WINDOW_ENTRY" | head -n 1 | cut -d, -f2 | xargs niri msg action focus-window --id
else
  # exec footclient --app-id ${NAME} zsh
  exec ghostty --class=${NAME} -e zsh
fi
