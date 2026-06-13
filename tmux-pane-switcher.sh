#!/usr/bin/env bash
set -euo pipefail

all_sessions=0

case "${1:-}" in
  "")
    ;;
  --all)
    all_sessions=1
    ;;
  *)
    printf 'Usage: %s [--all]\n' "${0##*/}" >&2
    exit 2
    ;;
esac

pane_scope=-s
#pane_label='#{window_index}.#{pane_index}'

if ((all_sessions)); then
  pane_scope=-a
#  pane_label='#S:#{window_index}.#{pane_index}'
fi

selected="$(
  tmux list-panes "$pane_scope" -F '#{?#{@pane_mru},#{@pane_mru},0} #{pane_id} #{window_id}  #{session_name}  #{pane_current_command}  #{pane_current_path}' |
    sort -k1,1rn |
    awk '{$1 = ""; sub(/^  */, ""); print}' |
    fzf \
      -e \
      --with-nth 3.. \
      --no-sort \
      --reverse \
      --cycle \
      --bind='tab:down,btab:up' \
      --preview='tmux capture-pane -p -t {1}' \
      --preview-window='right:70%,wrap,follow'
)" || exit 0

pane_id="$(awk '{print $1}' <<< "$selected")"
window_id="$(awk '{print $2}' <<< "$selected")"

if ((all_sessions)); then
  tmux switch-client -t "$pane_id"
else
  tmux select-window -t "$window_id"
  tmux select-pane -t "$pane_id"
fi
