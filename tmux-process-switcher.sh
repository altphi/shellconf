#!/usr/bin/env bash
# switch tmux panes by process name with fuzzel

tmux list-panes -a -F '#S:#I.#P #{pane_current_command}' \
  | fuzzel --dmenu \
  | awk '{print $1}' \
  | xargs -r tmux switch-client -t
