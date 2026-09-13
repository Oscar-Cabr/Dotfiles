#!/usr/bin/env bash
# ~/.config/theme/folder-icons.sh
#
# Per-folder icons for Nemo's main view (icon / list view). Nemo reads the
# icon name from gvfs metadata (metadata::custom-icon-name), which lives in
# the BINARY store at ~/.local/share/gvfs-metadata/ -- unreadable, machine-
# local, and not in the dotfiles. This file is the plain-text source of
# truth; the gvfs store is just a cache rebuilt by running it.
#
# ─── USAGE ────────────────────────────────────────────────────────────────
#
#   Add or change a line in the TAGS table below, then run:
#        ~/.config/theme/folder-icons.sh
#   Press F5 in Nemo. Run it again after a rebuild / restore to replay all.
#
#   To see what a folder is tagged with:
#        gio info -a metadata::custom-icon-name ~/Projects
#   To remove a tag by hand:
#        gio set -t unset ~/Projects metadata::custom-icon-name
#
# ─── WHAT THIS DOES AND DOES NOT AFFECT ───────────────────────────────────
#
#   Main view (big icons)  YES. Any icon name the active theme resolves.
#                          Papirus ships ~50 folder variants that all follow
#                          the folder colour set: folder-code, -git, -books,
#                          -notes, -linux, -games, -github, -docker, ...
#                          ls /usr/share/icons/Papirus/48x48/places/ | grep ^folder-blue-
#
#   Sidebar (bookmarks)    NO. Nemo 6.6 hard-codes the sidebar icon in
#                          nemo_file_get_control_icon_name(): home, the 8
#                          XDG dirs from ~/.config/user-dirs.dirs, and
#                          everything else gets xsi-folder-symbolic. The
#                          tag is never consulted there. Verified against
#                          libnemo-private/nemo-file.c at 6.6.4.
#
#   A name the theme does NOT have falls through to the plain folder icon,
#   silently. folder-cpcfi below is one of those; it is kept as a placeholder
#   so the intent is recorded.

set -e

# folder (relative to $HOME)              icon name
TAGS='
Books                                     folder-books
CompetitiveProgramming                    folder-code
Projects                                  folder-git
CPCFI                                     folder-cpcfi
Documents/Notas                           folder-notes
Documents/linux_initial_config            folder-linux
'

applied=0; skipped=0
while read -r dir icon; do
    [ -z "$dir" ] && continue
    path="$HOME/$dir"
    if [ ! -d "$path" ]; then
        printf '  skip   %-36s (directory does not exist)\n' "~/$dir"
        skipped=$((skipped+1)); continue
    fi
    gio set "$path" metadata::custom-icon-name "$icon"
    printf '  tagged %-36s %s\n' "~/$dir" "$icon"
    applied=$((applied+1))
done <<< "$TAGS"

echo "done: $applied tagged, $skipped skipped. Press F5 in Nemo."
