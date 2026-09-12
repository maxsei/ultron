#!/usr/bin/env bash
# Hyprland keybind cheatsheet — display-only rofi popup

CHEAT=$(cat << 'KEYS'
 SUPER + Return       → Terminal (kitty)
 SUPER + /            → App launcher (rofi)
 SUPER + ?            → This help screen
 SUPER + Q            → Close window
 SUPER + F            → Fullscreen
 SUPER + Space        → Toggle floating
 SUPER + SHIFT + Q    → Lock screen

 ── Focus ──────────────────────────────
 SUPER + H / ←        → Focus left
 SUPER + L / →        → Focus right
 SUPER + K / ↑        → Focus up
 SUPER + J / ↓        → Focus down

 ── Move Windows ───────────────────────
 SUPER + SHIFT + H / ←  → Move left
 SUPER + SHIFT + L / →  → Move right
 SUPER + SHIFT + K / ↑  → Move up
 SUPER + SHIFT + J / ↓  → Move down

 ── Workspaces ─────────────────────────
 SUPER + 1-9          → Switch workspace
 SUPER + SHIFT + 1-9  → Move window to workspace
 SUPER + scroll       → Cycle workspaces

 ── Utilities ──────────────────────────
 SUPER + V            → Clipboard history
 SUPER + P            → Screenshot (select area)
 SUPER + SHIFT + P    → Screenshot (full screen)
 SUPER + mouse drag   → Move window
 SUPER + right-drag   → Resize window
KEYS
)

echo "$CHEAT" | rofi \
  -dmenu \
  -i \
  -p "Keybinds" \
  -no-custom \
  -theme-str 'window { width: 600px; } listview { lines: 30; } entry { placeholder: "Filter..."; }' \
  > /dev/null 2>&1
