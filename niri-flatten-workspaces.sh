#!/usr/bin/env bash
# Move every window on the focused output onto a single workspace.
# Destination defaults to the active workspace on that output.
# Usage: niri-flatten-rows.sh [<workspace-idx>]
set -euo pipefail

output=$(niri msg -j focused-output | jq -r .name)

workspaces=$(niri msg -j workspaces)

if [[ $# -ge 1 ]]; then
    dest_idx="$1"
    dest_id=$(jq -r --arg o "$output" --argjson i "$dest_idx" \
        '.[] | select(.output==$o and .idx==$i) | .id' <<<"$workspaces")
    if [[ -z "$dest_id" ]]; then
        echo "no workspace with idx $dest_idx on output $output" >&2
        exit 1
    fi
else
    dest_id=$(jq -r --arg o "$output" \
        '.[] | select(.output==$o and .is_active) | .id' <<<"$workspaces")
fi

dest_idx=$(jq -r --argjson id "$dest_id" '.[] | select(.id==$id) | .idx' <<<"$workspaces")

# All workspace ids on this output other than the destination.
mapfile -t src_ids < <(jq -r --arg o "$output" --argjson d "$dest_id" \
    '.[] | select(.output==$o and .id!=$d) | .id' <<<"$workspaces")

# Window ids to move: anything on a non-destination workspace on this output.
mapfile -t win_ids < <(niri msg -j windows | jq -r \
    --argjson srcs "$(printf '%s\n' "${src_ids[@]}" | jq -Rcs 'split("\n")|map(select(length>0)|tonumber)')" \
    '.[] | select(.workspace_id as $w | $srcs | index($w)) | .id')

for wid in "${win_ids[@]}"; do
    niri msg action move-window-to-workspace --window-id "$wid" --focus false "$dest_idx" >/dev/null
done

echo "moved ${#win_ids[@]} window(s) to workspace idx $dest_idx on $output"
