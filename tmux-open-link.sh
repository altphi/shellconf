#!/usr/bin/env bash
set -euo pipefail

pane_width="$(tmux display-message -p '#{pane_width}')"
raw="$(tmux capture-pane -S -10000 -p)"

urls="$(
  printf '%s\n' "$raw" \
  | sed 's/[[:space:]]*$//' \
  | awk -v w="$pane_width" '
    {
        if (full) {
            prev = prev $0
        } else {
            if (NR > 1 && prev != "") print prev
            prev = $0
        }
        full = (length($0) == w)
    }
    END { if (prev != "") print prev }
  ' \
  | grep -Eo '(https?|file)://[^[:space:]]+' \
  | sed -E 's/[.,;:!?]+$//' \
  | perl -pe '1 while s/\)$// && (tr/\(// < tr/\)//)' \
  | sort -u
)" || true

[ -z "${urls}" ] && exit 0

choice="$(printf '%s\n' "$urls" | fuzzel --dmenu --width 180 --prompt 'open> ')"

[ -z "${choice}" ] && exit 0

xdg-open "$choice" >/dev/null 2>&1 &

