#!/usr/bin/env bash
#
# ghostty +list-fonts → commented font-family lines (base / main family names only)
# Uses indentation: only non-indented lines are kept as root families
# Now with an editable BLACKLIST at the top
#

if ! command -v ghostty >/dev/null 2>&1; then
    echo "Error: ghostty not found" >&2
    exit 1
fi

# ──────────────────────────────────────────────────────────────────────────────
#          EDITABLE BLACKLIST — add patterns to exclude families
# ──────────────────────────────────────────────────────────────────────────────
# Each line is an extended regex pattern (grep -E syntax)
# Lines that match *any* of these are completely skipped
BLACKLIST=(
    "Propo$"
    "^TeX Gyre"
    "Unifont"
    "Noto Color Emoji"
    ".*Emoji"
    ".*Variable$"
    "^FreeMono$"
    "^FreeSans$"
    "^FreeSerif$"
)

if [ ${#BLACKLIST[@]} -gt 0 ]; then
    BLACKLIST_PATTERN=$(printf "%s|" "${BLACKLIST[@]}")
    BLACKLIST_PATTERN=${BLACKLIST_PATTERN%|}  # remove trailing |
else
    BLACKLIST_PATTERN='^$'  # impossible match → effectively no blacklist
fi

ghostty +list-fonts 2>/dev/null | \
awk '
    NF == 0 { next }
    !/^[[:space:]]/ {
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0)
        if (length($0) < 3) next

        name = $0
        gsub(/"/, "\\\"", name)

        print name
    }
' | \
grep -v -E "$BLACKLIST_PATTERN" | \
sort -u -f | \
sed 's/^/# font-family = "/; s/$/"/'

