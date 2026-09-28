#!/bin/bash
set -euo pipefail

# LOWDRUS INSTALLER — Windows-like input profile for macOS Tahoe
# User-level, reversible configuration. Intended to be called by the LOWDRUS
# post-install engine/GUI; no Terminal interaction is required in the final flow.

PROFILE_DIR="$HOME/Library/Application Support/LOWDRUS-INSTALLER/input"
LAUNCH_AGENTS="$HOME/Library/LaunchAgents"
AGENT="$LAUNCH_AGENTS/com.lowdrus.windows-keyboard.plist"
MAPPING="$PROFILE_DIR/windows-keyboard.json"

mkdir -p "$PROFILE_DIR" "$LAUNCH_AGENTS"

# Mouse wheel: Windows-style direction (wheel down => page down).
/usr/bin/defaults write -g com.apple.swipescrolldirection -bool false

# PC keyboard modifier layout:
# physical Ctrl -> macOS Command (so Ctrl+C/V/X/Z/A/S/F/T/W behave as expected)
# physical Windows key -> macOS Control
# physical Alt remains macOS Option.
cat > "$MAPPING" <<'JSON'
{"UserKeyMapping":[
 {"HIDKeyboardModifierMappingSrc":30064771296,"HIDKeyboardModifierMappingDst":30064771299},
 {"HIDKeyboardModifierMappingSrc":30064771299,"HIDKeyboardModifierMappingDst":30064771296},
 {"HIDKeyboardModifierMappingSrc":30064771300,"HIDKeyboardModifierMappingDst":30064771303},
 {"HIDKeyboardModifierMappingSrc":30064771303,"HIDKeyboardModifierMappingDst":30064771300}
]}
JSON

/usr/bin/hidutil property --set "$(cat "$MAPPING")" >/dev/null

# Persist modifier mapping after login/reboot.
cat > "$AGENT" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>com.lowdrus.windows-keyboard</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/bin/hidutil</string>
    <string>property</string>
    <string>--set</string>
    <string>{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":30064771296,"HIDKeyboardModifierMappingDst":30064771299},{"HIDKeyboardModifierMappingSrc":30064771299,"HIDKeyboardModifierMappingDst":30064771296},{"HIDKeyboardModifierMappingSrc":30064771300,"HIDKeyboardModifierMappingDst":30064771303},{"HIDKeyboardModifierMappingSrc":30064771303,"HIDKeyboardModifierMappingDst":30064771300}]}</string>
  </array>
  <key>RunAtLoad</key><true/>
</dict>
</plist>
PLIST

/usr/bin/plutil -lint "$AGENT" >/dev/null
/bin/launchctl bootout "gui/$(id -u)" "$AGENT" >/dev/null 2>&1 || true
/bin/launchctl bootstrap "gui/$(id -u)" "$AGENT" >/dev/null 2>&1 || true

# Refresh preference consumers where possible. Finder/Dock restart is harmless;
# logout is not forced by this script.
/usr/bin/killall cfprefsd >/dev/null 2>&1 || true

printf '%s\n' '[LOWDRUS] Windows-like input profile applied.'
printf '%s\n' '[LOWDRUS] Ctrl acts as Command; Windows key acts as Control; Alt remains Option.'
printf '%s\n' '[LOWDRUS] Mouse wheel uses Windows-style direction.'
