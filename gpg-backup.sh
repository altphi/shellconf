#!/usr/bin/env bash

key="you@example.com"
dir="gnupg-backup-$(date +%Y-%m-%d)"
mkdir "$dir"
gpg --armor --export "$key" >"$dir/public.asc"
gpg --armor --export-secret-keys "$key" >"$dir/secret.asc"
gpg --export-ownertrust >"$dir/ownertrust.txt"
cp -a ~/.gnupg/openpgp-revocs.d "$dir/" 2>/dev/null || true
tar -czf "$dir.tgz" "$dir"
gpg -c --cipher-algo AES256 "$dir.tgz"
rm -r "$dir" "$dir.tgz"
