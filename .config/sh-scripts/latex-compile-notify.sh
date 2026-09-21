#!/usr/bin/env bash
# ~/.config/sh-scripts/latex-compile-notify.sh
#
# Summarises a LaTeX compilation: counts errors, warnings and boxes in the .log,
# writes a human-readable report next to the .pdf, and notifies swaync.
#
# Usage: latex-compile-notify.sh <path/to/main.log> <path/to/compile-report.txt>

set -u

# ${#var} must count codepoints, not bytes: the title is exactly 40 wide.
export LC_ALL=C.utf8

# --- Glyphs (Nerd Font) -----------------------------------------------------
# Note: \u takes 4 hex digits, \U takes 8. The md- glyphs live above U+FFFF,
# so they need \U with leading zeros.
ICON_TEX=$''          # nf-dev-tex                          U+E8BE
ICON_DOC_OK=$'\U000f1517'   # nf-md-file_document_multiple        U+F1517
ICON_DOC_ERR=$'\U000f1aa0'  # nf-md-file_document_remove_outline  U+F1AA0
ICON_WARN=$''         # nf-cod-warning                      U+EA6C
ICON_ERR=$''          # nf-cod-error                        U+EA87
ICON_BOX=$''          # nf-fa-box_open                      U+ED95

TITLE_WIDTH=40              # one character more overflows the notification box
SUMMARY_WIDTH=44            # one extra space in each of the two gaps, so the
                            # counts line deliberately overhangs the title by 4
FILLER=$'─'            # ─
MAX_BODY_LINES=6            # how many messages the notification shows

# --- Time on screen (ms) ----------------------------------------------------
# swaync ships timeout-critical=0 by default, i.e. critical ones never expire.
# That is why we pass -t explicitly. If it still sticks, set URGENCY_ERR=normal.
EXPIRE_OK=8000      # clean build
EXPIRE_WARN=12000   # compiled, but with warnings: lingers a bit longer
EXPIRE_ERR=15000    # did not compile
URGENCY_ERR=critical

# --- Arguments --------------------------------------------------------------
LOG=${1:-}
REPORT=${2:-}

if [ -z "$LOG" ] || [ -z "$REPORT" ]; then
    printf 'usage: %s <main.log> <compile-report.txt>\n' "$(basename "$0")" >&2
    exit 2
fi

# --- Patterns ---------------------------------------------------------------
# With -file-line-error, pdflatex emits "./main.tex:42: message"; without it, "! message".
ERR_RE='^(! |[^[:space:]]+:[0-9]+: )'
WARN_RE='^(LaTeX Warning:|LaTeX Font Warning:|Package [^ ]+ Warning:|Class [^ ]+ Warning:|pdfTeX warning)'
OVER_RE='^Overfull \\[hv]box'
UNDER_RE='^Underfull \\[hv]box'

count() { grep -c -E "$1" -- "$LOG" 2>/dev/null || true; }

# --- Title: FILLER... glyphs  text FILLER..., exactly TITLE_WIDTH wide ------
build_title() {
    local icons=$1 text=$2
    local inner=" $icons  $text "
    local rest=$(( TITLE_WIDTH - ${#inner} ))
    local left right lpad='' rpad=''
    if [ "$rest" -lt 2 ]; then                        # does not fit: trim the text
        inner="${inner:0:$((TITLE_WIDTH - 2))}"
        rest=2
    fi
    left=$(( rest / 2 )); right=$(( rest - left ))    # the odd one goes right
    while [ "$left"  -gt 0 ]; do lpad="$lpad$FILLER"; left=$((left - 1));   done
    while [ "$right" -gt 0 ]; do rpad="$rpad$FILLER"; right=$((right - 1)); done
    printf '%s%s%s' "$lpad" "$inner" "$rpad"
}

# notify-send renders Pango markup in the body, and logs contain < and >.
escape() { sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'; }

# --- No log at all: the compilation never even started ----------------------
if [ ! -r "$LOG" ]; then
    notify-send -u "$URGENCY_ERR" -t "$EXPIRE_ERR" \
        -h string:x-canonical-private-synchronous:latex-compile \
        "$(build_title "$ICON_TEX $ICON_DOC_ERR" 'Compilation failed')" \
        "$ICON_ERR  No log file was generated: $(printf '%s' "$LOG" | escape)"
    exit 1
fi

n_err=$(count "$ERR_RE")
n_warn=$(count "$WARN_RE")
n_over=$(count "$OVER_RE")
n_under=$(count "$UNDER_RE")
n_box=$(( n_over + n_under ))

# --- Human-readable report next to the .pdf ---------------------------------
{
    printf 'LaTeX compilation report\n'
    printf 'Generated:  %s\n' "$(date '+%Y-%m-%d %H:%M:%S')"
    printf 'Log:        %s\n\n' "$LOG"
    printf 'Errors:     %s\n' "$n_err"
    printf 'Warnings:   %s\n' "$n_warn"
    printf 'Boxes:      %s  (%s overfull, %s underfull)\n\n' "$n_box" "$n_over" "$n_under"
    printf '%.0s=' $(seq 1 72); printf '\n\n'

    if command -v texlogsieve >/dev/null 2>&1; then
        texlogsieve --no-heartbeat --no-color "$LOG" 2>&1
    else
        printf 'texlogsieve is not installed; raw extraction from the log:\n\n'
        grep -n -E "$ERR_RE|$WARN_RE|$OVER_RE|$UNDER_RE" -- "$LOG" || printf '(no issues)\n'
    fi
} > "$REPORT"

# --- Notification -----------------------------------------------------------
plural() { [ "$1" -eq 1 ] && printf '%s' "$2" || printf '%s' "$3"; }

# The three groups are spread to fill SUMMARY_WIDTH.
build_summary() {
    local s1=$1 s2=$2 s3=$3 rest g1 g2 p1='' p2=''
    rest=$(( SUMMARY_WIDTH - ${#s1} - ${#s2} - ${#s3} ))
    [ "$rest" -lt 4 ] && rest=4          # never let the groups touch
    g1=$(( rest / 2 )); g2=$(( rest - g1 ))
    while [ "$g1" -gt 0 ]; do p1="$p1 "; g1=$((g1 - 1)); done
    while [ "$g2" -gt 0 ]; do p2="$p2 "; g2=$((g2 - 1)); done
    printf '%s%s%s%s%s' "$s1" "$p1" "$s2" "$p2" "$s3"
}

summary=$(build_summary \
    "$ICON_ERR  $n_err $(plural "$n_err"  error   errors)" \
    "$ICON_WARN  $n_warn $(plural "$n_warn" warning warnings)" \
    "$ICON_BOX  $n_box $(plural "$n_box"  box     boxes)")

# Errors first, warnings after: the .log interleaves them chronologically, so
# trimming by order of appearance can drop exactly the errors. Within each group
# the log order is preserved.
# sed '$!G' puts a blank line between logs so they can be told apart.
# Each group is numbered on its own: e1: e2: ... for errors, w1: w2: ... for
# warnings, so a gap in the w-series shows what the cap left out.
msgs=$( { grep -E "$ERR_RE"  -- "$LOG" | awk '{ printf "e%d: %s\n", NR, $0 }'
          grep -E "$WARN_RE" -- "$LOG" | awk '{ printf "w%d: %s\n", NR, $0 }'; } \
        | head -n "$MAX_BODY_LINES" | escape | sed '$!G')

hidden=$(( n_err + n_warn - MAX_BODY_LINES ))

body="$summary"
if [ -n "$msgs" ]; then
    body="$summary"$'\n\n'"$msgs"
    if [ "$hidden" -gt 0 ]; then
        body="$body"$'\n\n'"+ $hidden more $(plural "$hidden" message messages) in the report"
    fi
fi

if [ "$n_err" -gt 0 ]; then
    title=$(build_title "$ICON_TEX $ICON_DOC_ERR" 'Compilation failed')
    urgency=$URGENCY_ERR
    expire=$EXPIRE_ERR
elif [ "$n_warn" -gt 0 ]; then
    # Compiled, but with warnings: its own wording, its own glyph and longer on
    # screen, so it is not mistaken at a glance for a clean build.
    title=$(build_title "$ICON_TEX $ICON_WARN" 'Compiled with warnings')
    urgency=normal
    expire=$EXPIRE_WARN
else
    title=$(build_title "$ICON_TEX $ICON_DOC_OK" 'Compilation successful')
    urgency=normal
    expire=$EXPIRE_OK
fi

# x-canonical-private-synchronous replaces the previous notification instead of
# stacking them; drop it if you would rather they pile up.
notify-send -u "$urgency" -t "$expire" \
    -h string:x-canonical-private-synchronous:latex-compile \
    "$title" "$body"

# Same summary on the terminal, so the report need not be opened.
printf '%s\n' "$summary"
printf 'Report: %s\n' "$REPORT"

[ "$n_err" -eq 0 ]
