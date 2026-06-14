#!/bin/bash
notify-send '───────────── 󰐥 Rebooting... ────────────' 'This will take 5 seconds.'
eww close poweroff-window
(sleep 5 && shutdown -r now)
