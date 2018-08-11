#!/usr/bin/env sh
# leaves a backup of all changes in git stash, creates a patch ignoring whitespace changes, clears changes, applies patch

cd "$(git rev-parse --show-toplevel)"
git stash && git stash apply && git diff -w > changes.patch && git checkout . && git apply --whitespace=fix changes.patch && rm changes.patch
