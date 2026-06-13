#!/usr/bin/env bash

FILE="$HOME/.config/niri/config.kdl"
ALWAYS_ON_TEXT="center-focused-column \"always\""
NEVER_ON_TEXT="center-focused-column \"never\""

if grep -qe "$ALWAYS_ON_TEXT" "$FILE" ; then
  sed -ie "s/$ALWAYS_ON_TEXT/$NEVER_ON_TEXT/g" "$FILE";
else
  sed -ie "s/$NEVER_ON_TEXT/$ALWAYS_ON_TEXT/g" "$FILE";
fi

