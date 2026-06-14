#!/bin/bash
notify-send '────────  Quitting Hyprland... ─────────' 'Killing active Hyprland session. This will take 5 seconds.'
eww close poweroff-window
(sleep 5 pkill Hyprland)
