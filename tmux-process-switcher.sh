#!/usr/bin/env bash
# switch tmux panes by process name with fuzzel, create new session if none found

selection=$(tmux list-panes -a -F '#S:#I.#P #{pane_current_command}' | fuzzel --dmenu)

[ -z "$selection" ] && exit 0

target=$(echo "$selection" | awk '{print $1}')

if tmux list-panes -a -F '#S:#I.#P' | grep -qF "$target"; then
    tmux switch-client -t "$target"
else
    session="$selection"
    start_dir="$HOME"
    [ -d "$HOME/code/$session" ] && start_dir="$HOME/code/$session"
    tmux new-session -d -s "$session" -c "$start_dir" && tmux switch-client -t "=$session"
fi
