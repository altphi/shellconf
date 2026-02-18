#!/usr/bin/env bash

duration_to_seconds() {
    date -d "$@ " +%s -d "1970-01-01 UTC"   # trailing space helps parsing
}
