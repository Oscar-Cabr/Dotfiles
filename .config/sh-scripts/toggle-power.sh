# ~/.config/sh-scripts/toggle-power.sh

if eww active-windows | grep -q poweroff-window; then
  eww close poweroff-window
else
  eww open poweroff-window
  sleep 0.1
  hyprctl dispatch focuswindow title:poweroff-window
fi

