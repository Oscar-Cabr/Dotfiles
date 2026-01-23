# ~/.config/sh-scripts/toggle-bluetooth.sh

if eww active-windows | grep -q bluetooth-window; then
  eww close bluetooth-window
else
  eww open bluetooth-window
  sleep 0.1
  hyprctl dispatch focuswindow title:bluetooth-window
fi

