#!/usr/bin/env bash
THEME_DIR="/usr/share/foot/themes"
CONFIG_FILE="$HOME/.config/foot/foot.ini"
THEME=$(ls $THEME_DIR | fzf --prompt="Select foot theme: ")
if [ -n "$THEME" ]; then
    sed -i "/^include=/c\include=$THEME_DIR/$THEME" "$CONFIG_FILE"
    echo "Applied theme: $THEME"
fi
