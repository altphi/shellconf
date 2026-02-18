#!/usr/bin/env bash

file="$HOME/.bdays"

[[ ! -f "$file" ]] && { echo "Error: $file not found"; exit 1; }

now=$(date +%s)                 # current time in seconds since epoch
cy=$(date +%Y)                  # current year

while IFS=' ' read -r name birthday; do
    [[ -z "$name" || -z "$birthday" ]] && continue

    # Validate/skip if date conversion fails
    birth_date=$(date -d "$birthday" +%s 2>/dev/null) || { echo "$name: invalid date"; continue; }

    # Extract birth year, month, day
    IFS='-' read -r by bm bd <<< "$birthday"

    # Construct the birthday date *in the current year*
    # If Feb 29 and current year isn't leap → date -d will fail, so we handle gracefully
    this_year_bday_str="${cy}-${bm}-${bd}"
    this_year_birthday=$(date -d "$this_year_bday_str" +%s 2>/dev/null)

    if [[ $? -eq 0 && -n "$this_year_birthday" ]]; then
        # We have a valid birthday this year
        if (( this_year_birthday <= now )); then
            age=$(( cy - by ))
        else
            age=$(( cy - by - 1 ))
        fi
    else
        # Edge case: Feb 29 in a non-leap current year → fall back to last year
        # This is conservative and correct in almost all cases
        age=$(( cy - by - 1 ))
    fi

    echo "$name: $age"

done < "$file"
