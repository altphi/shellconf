#!/usr/bin/env bash
#
# niri-center-external: print niri KDL positioning the external monitor
# centered directly above the laptop output.
#
# Usage: niri-center-external [LAPTOP [EXTERNAL]]
#   LAPTOP   defaults to the first eDP-* output
#   EXTERNAL defaults to the first other active output
#
# Requires: niri, jq

set -euo pipefail

IFS=$'\t' read -r LAPTOP lw lh EXTERNAL EXTERNAL_NAME ew eh < <(
    niri msg --json outputs | jq -r --arg l "${1:-}" --arg e "${2:-}" '
        def longname: "\(.make // "Unknown") \(.model // "Unknown") \(.serial // "Unknown")";
        [to_entries[] | select(.value.logical != null)] as $o
        | (if $l != "" then $l
           else ($o | map(select(.key | ascii_downcase | startswith("edp-"))) | .[0].key // "")
           end) as $laptop
        | (if $e != "" then $e
           else ($o | map(select(.key != $laptop)) | .[0].key // "")
           end) as $external
        | ($o[] | select(.key == $laptop)   | .value) as $L
        | ($o[] | select(.key == $external) | .value) as $E
        | [$laptop, $L.logical.width, $L.logical.height,
           $external, ($E | longname), $E.logical.width, $E.logical.height] | @tsv
    '
)

[[ -n "$LAPTOP"   ]] || { echo "could not detect laptop output (no eDP-*); pass it as arg 1" >&2; exit 1; }
[[ -n "$EXTERNAL" ]] || { echo "could not find an external output distinct from $LAPTOP" >&2; exit 1; }

ex=$(( (lw - ew) / 2 ))
ey=$(( -eh ))

cat <<EOF
# Detected:
#   $LAPTOP                    ${lw}x${lh} -> x=0 y=0
#   $EXTERNAL ($EXTERNAL_NAME) ${ew}x${eh} -> x=${ex} y=${ey}

output "$LAPTOP" {
    position x=0 y=0
}

output "$EXTERNAL_NAME" {
    position x=${ex} y=${ey}
}
EOF
