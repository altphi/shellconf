#!/usr/bin/env bash

# run with sudo and without?

defaults write -g ApplePressAndHoldEnabled -bool false
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
defaults write com.microsoft.VSCodeInsiders ApplePressAndHoldEnabled -bool false


defaults write com.apple.dt.Xcode ShowBuildOperationDuration -bool YES
