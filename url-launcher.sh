#!/usr/bin/env bash
declare -A searches=(
    ["a"]="https://www.amazon.com/s?k=" 
    ["g"]="https://www.google.com/search?q="
    ["bwb"]="https://www.betterworldbooks.com/search/results?q="
)

input=$(wofi --show dmenu --prompt "Enter search (e.g., 'a tshirt', 'g weather')")

[[ -z "$input" ]] && exit 1

shortcut="${input%% *}"
query="${input#* }"

if [[ -n "${searches[$shortcut]}" ]]; then
    encoded_query=$(echo "$query" | sed 's/ /+/g')
    url="${searches[$shortcut]}$encoded_query"
    xdg-open "$url" 2>/dev/null
elif [[ $input =~ http.* ]]; then
    xdg-open "$input" 2>/dev/null
else
    notify-send "Error" "Unknown shortcut: $shortcut"
    exit 1
fi
