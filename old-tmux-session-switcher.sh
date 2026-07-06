#!/usr/bin/env bash
# switch tmux panes by session name with fuzzel, create new if none found

session=$(tmux list-sessions -F "#{session_last_attached} #S" | sort -rn | cut -d' ' -f2- | fuzzel --dmenu)

[ -z "$session" ] && exit 0

if tmux has-session -t "=$session" 2>/dev/null; then
    tmux switch-client -t "=$session"
else
    start_dir="$HOME"
    [ -d "$HOME/code/$session" ] && start_dir="$HOME/code/$session"
    tmux new-session -d -s "$session" -c "$start_dir" && tmux switch-client -t "=$session"
fi

