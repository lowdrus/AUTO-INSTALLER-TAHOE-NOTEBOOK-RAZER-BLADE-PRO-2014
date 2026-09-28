#!/bin/bash
set -euo pipefail

# Roll back only the LOWDRUS Windows-like input changes.
AGENT="$HOME/Library/LaunchAgents/com.lowdrus.windows-keyboard.plist"
PROFILE_DIR="$HOME/Library/Application Support/LOWDRUS-INSTALLER/input"

/bin/launchctl bootout "gui/$(id -u)" "$AGENT" >/dev/null 2>&1 || true
rm -f "$AGENT"
rm -rf "$PROFILE_DIR"

# Clear temporary hidutil modifier mapping; native mapping returns immediately.
/usr/bin/hidutil property --set '{"UserKeyMapping":[]}' >/dev/null

# Restore Apple's default natural scrolling.
/usr/bin/defaults delete -g com.apple.swipescrolldirection >/dev/null 2>&1 || true
/usr/bin/killall cfprefsd >/dev/null 2>&1 || true

printf '%s\n' '[LOWDRUS] Native macOS keyboard modifiers and scrolling restored.'
