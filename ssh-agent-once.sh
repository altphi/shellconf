#!/usr/bin/env bash

ssh-add -l > /dev/null 2>&1
ret_code=$?
if [[ $ret_code -eq 2 ]]; then
    echo "Starting SSH Agent..."
    ssh-agent -s > ~/.ssh-agent-environment
fi
