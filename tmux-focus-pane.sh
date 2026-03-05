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
WINDOW_ID=$(niri msg -j windows | jq -r '.[] | select(.app_id == "'"${APP_ID}"'") | .id' | head -n 1)

if [[ -z "$WINDOW_ID" ]]; then
  exec "$(dirname "$0")/niri-focus-or-open-tmux.sh" "$INSTANCE"
fi

niri msg action focus-window --id "$WINDOW_ID"

# Find the first tmux pane matching the pattern and switch to it
TARGET=$(tmux list-panes -a -F '#S:#I.#P #{pane_current_command}' | grep -i "$PATTERN" | head -n 1 | awk '{print $1}' || true)

if [[ -z "$TARGET" ]]; then
  exec "$(dirname "$0")/tmux-session-switcher.sh"
fi

tmux switch-client -t "$TARGET"
