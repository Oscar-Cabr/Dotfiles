#!/usr/bin/env bash
# Launch Waybar behind the Hyprland IPC shim.
#
# Under a hyprland.lua config Hyprland reads socket1 `dispatch` payloads as Lua,
# but Waybar still sends the old dispatcher syntax, so workspace clicks are
# rejected. hypr-ipc-shim.py translates them; this points Waybar at it and
# leaves every other Hyprland client on the real socket.
set -u

SCRIPTS="$HOME/.config/sh-scripts"
SHIM="$SCRIPTS/hypr-ipc-shim.py"
RUNTIME="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
STATE="$RUNTIME/hypr-waybar-shim.his"

pkill -x waybar 2>/dev/null
pkill -f "$SHIM" 2>/dev/null
rm -f "$STATE"

# HYPR_SHIM_REAL_HIS survives being re-invoked from Waybar's own environment,
# where HYPRLAND_INSTANCE_SIGNATURE already points at the shim.
REAL_HIS="${HYPR_SHIM_REAL_HIS:-${HYPRLAND_INSTANCE_SIGNATURE:-}}"
if [ -z "$REAL_HIS" ]; then
    echo "waybar-launch: Hyprland signature missing, starting Waybar unshimmed" >&2
    exec waybar
fi
export HYPR_SHIM_REAL_HIS="$REAL_HIS"

"$SHIM" >/dev/null &

# Wait for the proxy to publish its signature and bind, before Waybar's first
# IPC call. Two seconds is generous; the shim binds in milliseconds.
shim_his=""
for _ in $(seq 1 40); do
    if [ -s "$STATE" ]; then
        shim_his="$(cat "$STATE")"
        [ -S "$RUNTIME/hypr/$shim_his/.socket.sock" ] && break
        shim_his=""
    fi
    sleep 0.05
done

if [ -n "$shim_his" ]; then
    exec env HYPRLAND_INSTANCE_SIGNATURE="$shim_his" waybar
fi

echo "waybar-launch: shim never came up, starting Waybar unshimmed" >&2
exec waybar
