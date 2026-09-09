#!/usr/bin/env bash
# ~/.config/sh-scripts/input-lang.sh
#
# Input language state, for the custom/language Waybar module.
#
# The xkb layout group IS the state -- there is no separate bookkeeping:
#
#   group 0  us     -> "US"
#   group 1  latam  -> "LATAM"
#   group 2  cn     -> "中文", and fcitx5 is switched on to pinyin
#
# Shift + Alt cycles the group through xkb's own grp:alt_shift_toggle (see
# kb_options in ~/.config/hypr/hyprland.lua). Hyprland never sees the gesture,
# which is deliberate: release-binds on a bare modifier key do not fire here.
#
# us and latam are real xkb layouts, so Spanish accents work in every app,
# including XWayland windows and games that never talk to fcitx5. The cn group
# is plain QWERTY (xkb defines it as include "us(basic)") and exists purely as
# a recognisable name; fcitx5 is what actually produces hanzi.

set -u

WAYBAR_SIGNAL=9   # SIGRTMIN+9

# --- state ------------------------------------------------------------------

# Read the group from EVERY physical keyboard, not from one chosen device.
#
# Do not use Hyprland's .main flag here: fcitx5 registers a virtual keyboard
# (hl-virtual-keyboard-fcitx5) and Hyprland can mark THAT as main, so keying
# off .main reads a device the user never types on. Excluding virtual devices
# and then taking the first entry is just as wrong -- the first entry is
# something like acer-wireless-radio-control, whose group never changes, which
# pinned the indicator to US no matter what the real keyboard was doing.
#
# xkb groups are per device, so pressing Shift + Alt only moves the keyboard
# you pressed it on. Taking the highest state any real keyboard reports means
# the switch is picked up whichever keyboard you use, and it stays right while
# input-lang-watch.sh brings the others into line.
current() {
    local layouts
    layouts=$(hyprctl -j devices 2>/dev/null \
        | jq -r '.keyboards[]
                 | select(.name | test("^hl-virtual-keyboard") | not)
                 | .active_keymap' 2>/dev/null)

    case "$layouts" in
        *Chinese*) echo zh    ;;
        *Latin*)   echo latam ;;
        *)         echo us    ;;
    esac
}

# Bring fcitx5 in line with the layout. Idempotent on purpose: it is called
# both from the event watcher and from every Waybar refresh, so a missed
# event repairs itself on the next poll.
reconcile() {
    local want="$1" state im
    state=$(fcitx5-remote 2>/dev/null)
    im=$(fcitx5-remote -n 2>/dev/null)

    if [ "$want" = zh ]; then
        if [ "$state" != "2" ] || [ "$im" != "pinyin" ]; then
            fcitx5-remote -s pinyin >/dev/null 2>&1
            fcitx5-remote -o       >/dev/null 2>&1
        fi
    elif [ "$state" = "2" ]; then
        fcitx5-remote -c >/dev/null 2>&1
    fi
}

# --- commands ---------------------------------------------------------------

case "${1:-status}" in
    sync)
        # Called by input-lang-watch.sh on every layout change.
        reconcile "$(current)"
        pkill -RTMIN+"$WAYBAR_SIGNAL" waybar 2>/dev/null
        ;;
    status)
        # Called by Waybar. Must not signal Waybar, or it would loop.
        state=$(current)
        reconcile "$state"
        case "$state" in
            latam) text="LATAM"; tip="Spanish (Latin American)" ;;
            zh)    text="中文";  tip="Chinese pinyin - fcitx5"   ;;
            *)     text="US";    tip="English (US)"              ;;
        esac
        printf '{"text":"%s","alt":"%s","class":"%s","tooltip":"%s\\nShift + Alt to cycle"}\n' \
            "$text" "$state" "$state" "$tip"
        ;;
    cycle)
        # Waybar click. Goes through the same xkb group switch Shift + Alt uses,
        # so both entry points share one code path.
        hyprctl switchxkblayout all next >/dev/null 2>&1
        ;;
    *)
        echo "usage: ${0##*/} [status|cycle|sync]" >&2
        exit 2
        ;;
esac
