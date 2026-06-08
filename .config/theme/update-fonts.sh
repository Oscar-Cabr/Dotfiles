#!/usr/bin/env bash
# ~/.config/theme/update-fonts.sh
#
# Substitutes __MAIN_FONT__, __FALLBACK_FONT__ and __TERMINAL_FONT__ placeholders
# in all CSS/config files with values from ~/.config/theme/font.
#
# ─── USAGE ────────────────────────────────────────────────────────────────
#
#   1. Edit ~/.config/theme/font and set:
#        MAIN_FONT="Your Font Name"
#        FALLBACK_FONT="Some Fallback Font"
#        TERMINAL_FONT="Terminal Font Name"
#
#   2. Run this script:
#        ~/.config/theme/update-fonts.sh
#      or:
#        bash ~/.config/theme/update-fonts.sh
#
#   3. Reload the affected apps to see the change:
#        pkill -USR1 swaync          # reload swaync
#        pkill waybar; waybar &      # reload waybar
#        eww reload                  # reload eww (if using)
#        # kitty: open a new terminal window (each is a new process)
#
# ─── OPTIONS ──────────────────────────────────────────────────────────────
#
#   -h, --help    Show this help message and exit.
#   -n, --dry-run Print what would change without modifying files.
#
# ─── HOW IT WORKS ─────────────────────────────────────────────────────────
#
#   Reads MAIN_FONT, FALLBACK_FONT and TERMINAL_FONT from font (sourced as bash
#   vars), then uses sed to replace every occurrence of:
#       __MAIN_FONT__      →  "CodeNewRoman Nerd Font"
#       __FALLBACK_FONT__  →  "JetBrainsMono Nerd Font"
#       __TERMINAL_FONT__     →  "CaskaydiaCove Nerd Font Mono"
#   in the following files:
#       ~/.config/waybar/style.css
#       ~/.config/eww/widgets/_poweroff.scss
#       ~/.config/swaync/style.css
#       ~/.config/fuzzel/fuzzel.ini
#       ~/.config/wofi/style.css
#       ~/.config/kitty/kitty.conf
#
# ─── REQUIREMENTS ─────────────────────────────────────────────────────────
#
#   - bash, sed (standard on every Linux distro)
#   - font must exist at ~/.config/theme/font
#   - MAIN_FONT, FALLBACK_FONT and TERMINAL_FONT must be defined and non-empty
# ──────────────────────────────────────────────────────────────────────────

set -e

usage() {
    sed -n '2,/^# ─── REQUIREMENTS/p' "$0" | sed 's/^# \{0,1\}//' | head -n -1
}

CONF="$HOME/.config/theme/font"
DRY_RUN=0

for arg in "$@"; do
    case "$arg" in
        -h|--help)
            usage
            exit 0
            ;;
        -n|--dry-run)
            DRY_RUN=1
            ;;
        *)
            echo "Unknown option: $arg" >&2
            usage >&2
            exit 1
            ;;
    esac
done

if [[ ! -f "$CONF" ]]; then
    echo "Error: $CONF not found" >&2
    echo "Create it with MAIN_FONT and FALLBACK_FONT variables." >&2
    exit 1
fi

# shellcheck source=/dev/null
source "$CONF"

if [[ -z "$MAIN_FONT" || -z "$FALLBACK_FONT" || -z "$TERMINAL_FONT" ]]; then
    echo "Error: MAIN_FONT, FALLBACK_FONT or TERMINAL_FONT not set in $CONF" >&2
    exit 1
fi

TARGETS=(
    "$HOME/.config/waybar/style.css"
    "$HOME/.config/eww/widgets/_poweroff.scss"
    "$HOME/.config/swaync/style.css"
    "$HOME/.config/fuzzel/fuzzel.ini"
    "$HOME/.config/wofi/style.css"
    "$HOME/.config/kitty/kitty.conf"
)

for f in "${TARGETS[@]}"; do
    if [[ ! -f "$f" ]]; then
        echo "Skip (missing): $f"
        continue
    fi
    if [[ "$DRY_RUN" -eq 1 ]]; then
        echo "Would update: $f"
        grep -nE "__MAIN_FONT__|__FALLBACK_FONT__|__TERMINAL_FONT__" "$f" || true
    else
        sed -i \
            -e "s|__MAIN_FONT__|$MAIN_FONT|g" \
            -e "s|__FALLBACK_FONT__|$FALLBACK_FONT|g" \
            -e "s|__TERMINAL_FONT__|$TERMINAL_FONT|g" \
            "$f"
        echo "Updated: $f"
    fi
done

if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "Dry run complete. No files were modified."
else
    echo
    echo "Done. Reload the apps to see the change:"
    echo "  pkill -USR1 swaync           # reload swaync"
    echo "  pkill waybar; waybar &       # reload waybar"
    echo "  eww reload                   # reload eww"
fi

