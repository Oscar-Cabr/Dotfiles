#!/usr/bin/env bash
# ~/.config/sh-scripts/input-lang-watch.sh
#
# Follows Hyprland's activelayout events and keeps the whole system in step
# with the xkb group. Started from ~/.config/hypr/modules/autostart.lua.
#
# Shift + Alt is handled inside xkb (grp:alt_shift_toggle), so neither Hyprland
# nor Waybar is told about it -- this watcher is how the rest of the system
# finds out. On each real change it:
#
#   1. mirrors the new group onto every keyboard, because xkb groups are per
#      device and the gesture only moves the keyboard you pressed it on;
#   2. switches fcitx5 on for pinyin when the group is cn, off otherwise;
#   3. signals Waybar so the label updates immediately.
#
# Waybar also re-runs input-lang.sh every couple of seconds, so a missed event
# repairs itself; this watcher is what makes the switch feel instant.

set -u

SELF_DIR=$(cd "$(dirname "$0")" && pwd)

socket_path() {
    if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] &&
       [ -S "${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock" ]; then
        echo "${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"
        return
    fi
    set -- "${XDG_RUNTIME_DIR}"/hypr/*/.socket2.sock
    echo "$1"
}

SOCK=$(socket_path)
[ -S "$SOCK" ] || { echo "no Hyprland event socket at $SOCK" >&2; exit 1; }

# The reader runs as a background job and is waited on, rather than being the
# script's foreground command. bash defers traps until the current foreground
# command returns, and the reader blocks forever -- so as a foreground pipeline
# this script would ignore SIGTERM and could only be killed with -9.
trap 'pkill -P $$ 2>/dev/null; exit 0' TERM INT

# Hyprland's event socket speaks newline-delimited "event>>data".
python3 -u -c '
import socket, sys
s = socket.socket(socket.AF_UNIX)
s.connect(sys.argv[1])
buf = b""
while True:
    chunk = s.recv(4096)
    if not chunk:
        break
    buf += chunk
    while b"\n" in buf:
        line, buf = buf.split(b"\n", 1)
        sys.stdout.write(line.decode(errors="replace") + "\n")
' "$SOCK" | {
    seen=""
    while IFS= read -r line; do
        case "$line" in
            activelayout*) ;;
            *) continue ;;
        esac

        data=${line#activelayout>>}
        device=${data%%,*}
        layout=${data#*,}

        # fcitx5's own virtual keyboard reports a layout too; reacting to it
        # would just be chasing our own tail.
        case "$device" in
            hl-virtual-keyboard*) continue ;;
        esac

        # Group order comes from kb_layout in ~/.config/hypr/hyprland.lua.
        case "$layout" in
            *Chinese*) state=zh;    index=2 ;;
            *Latin*)   state=latam; index=1 ;;
            *)         state=us;    index=0 ;;
        esac

        # Act only on a real change. Mirroring the group onto every keyboard
        # below fires another burst of activelayout events; without this guard
        # they would be echoed straight back and spin forever.
        [ "$state" = "$seen" ] && continue
        seen=$state

        hyprctl switchxkblayout all "$index" >/dev/null 2>&1
        "$SELF_DIR/input-lang.sh" sync
    done
} &

wait $!
