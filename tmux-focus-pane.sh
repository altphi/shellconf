#!/usr/bin/env bash
# Focus a tmux ghostty window via niri, then switch to the first pane matching an argument.
# Usage: tmux-focus-pane.sh <pattern> [tmux-instance-name]
#   pattern: grep pattern matched against "#S:#I.#P #{pane_current_command}"
#   tmux-instance-name: optional, defaults to "main" (maps to com.tmux.<name>)

set -euo pipefail
set -x

if [[ "$#" -lt 1 ]]; then
  echo "Usage: $0 <pattern> [tmux-instance-name]"
  exit 1
fi

PATTERN="$1"
INSTANCE="${2:-main}"
APP_ID="com.tmux.${INSTANCE}"

# Focus the ghostty tmux window via niri
WINDOW_JSON=$(niri msg -j windows | jq -r '.[] | select(.app_id == "'"${APP_ID}"'")')
WINDOW_ID=$(echo "$WINDOW_JSON" | jq -r '.id' | head -n 1)

if [[ -z "$WINDOW_ID" ]]; then
  exec "$(dirname "$0")/niri-focus-or-open-tmux.sh" "$INSTANCE"
fi

niri msg action focus-window --id "$WINDOW_ID"

# Find the tmux client inside this ghostty by tracing PIDs
WINDOW_PID=$(echo "$WINDOW_JSON" | jq -r '.pid' | head -n 1)
CLIENT_TTY=""
while IFS=' ' read -r cpid ctty; do
  pid=$cpid
  while [[ $pid -gt 1 ]]; do
    [[ $pid -eq $WINDOW_PID ]] && CLIENT_TTY=$ctty && break 2
    pid=$(awk '/^PPid:/{print $2}' /proc/$pid/status 2>/dev/null) || break
  done
done < <(tmux list-clients -F '#{client_pid} #{client_tty}')

# Find the first tmux pane matching the pattern and switch to it
TARGET=$(tmux list-panes -a -F '#S:#I.#P #{pane_current_command}' | grep -i "$PATTERN" | head -n 1 | awk '{print $1}' || true)

if [[ -z "$TARGET" ]]; then
  # No pane or session matched; create a new session with that name
  tmux new-session -d -s "$PATTERN"
  TARGET="$PATTERN"
fi

if [[ -n "$CLIENT_TTY" ]]; then
  tmux switch-client -c "$CLIENT_TTY" -t "$TARGET"
else
  tmux switch-client -t "$TARGET"
fi
