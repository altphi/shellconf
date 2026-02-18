#!/usr/bin/env bash
## tmux list-sessions -F "#S" | sort | fuzzel --dmenu | xargs -r tmux switch -t

session=$(tmux list-sessions -F "#{session_last_attached} #S" | sort -rn | cut -d' ' -f2- | fuzzel --dmenu)

[ -z "$session" ] && exit 0

if tmux has-session -t "=$session" 2>/dev/null; then
    tmux switch-client -t "=$session"
else
    tmux new-session -d -s "$session" && tmux switch-client -t "=$session"
fi

