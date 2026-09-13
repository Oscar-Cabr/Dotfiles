Hyprland palette
	Master palette:  ~/.config/theme/hypr-colors.lua
	Consumed by:     ~/.config/hypr/modules/decoration.lua  (require("hypr-colors"))
	Edit hypr-colors.lua; borders and shadows update on reload.
	NOTE: this replaced hypr-colors.conf when the Hyprland config was
	      migrated to Lua (hyprlang is deprecated since Hyprland 0.55).


GTK3 theme (affects all GTK3 apps: nemo, qalculate-gtk, file choosers, ...)
	Theme dir:       ~/.themes/Leonardita-Sunset/
	Stylesheet:      ~/.themes/Leonardita-Sunset/gtk-3.0/gtk.css
	Previous sheet:  ~/.themes/.Leonardita-Sunset.gtk3.css.bak  (pre-rewrite backup,
	                 moved outside the theme dir so it is not tracked with the theme)
	Theme metadata:  ~/.themes/Leonardita-Sunset/index.theme
	Settings file:   ~/.config/gtk-3.0/settings.ini
	Active theme:    set via GSettings, which OVERRIDES settings.ini while a
	                 settings portal is running (it is, under Hyprland):
	                    gsettings set org.gnome.desktop.interface gtk-theme Leonardita-Sunset
	                    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
	                    gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark
	                 Keep settings.ini in sync for apps that bypass the portal.
	GTK3 reads the theme on app start.
	Reopen any GTK3 app to see the change.

GTK3 stylesheet layout (~/.themes/Leonardita-Sunset/gtk-3.0/gtk.css)
	1. imports GTK's built-in Adwaita dark from the gresource:
	     resource:///org/gtk/libgtk/theme/Adwaita/gtk-contained-dark.css
	   GTK3 loads a named theme INSTEAD OF Adwaita, not on top of it, so
	   without this import every unstyled widget goes transparent.
	2. imports the palette: ~/.config/theme/colors-gtk.css
	3. bespoke widget layer (sections 2-16) + a Nemo section (17)
	4. the old qalculate-only sheet (section 18). Structure preserved,
	   but its 86 background tokens are relinked to lsu_qalc_* so
	   qalculate can sit lighter than the global ramp -- see section
	   2b of colors-gtk.css. No selector or property was changed.
	GTK 3.24's Adwaita is compiled SASS with hard-coded hex and does NOT
	read @theme_* names, so redefining colours alone changes nothing --
	the bespoke layer has to restate each rule. Do not "simplify" it away.

GTK4 / libadwaita
	Stylesheet:      ~/.themes/Leonardita-Sunset/gtk-4.0/gtk.css
	Entry point:     ~/.config/gtk-4.0/gtk.css   (one @import of the above)
	Settings file:   ~/.config/gtk-4.0/settings.ini
	libadwaita apps ignore gtk-theme-name; ~/.config/gtk-4.0/gtk.css is the
	only hook they honour, which is why the indirection exists.
	This is a named-colour recolor only - no bespoke GTK4 widget rules.
	GTK4 properties ONLY in the GTK4 files (no -gtk-icon-effect, max-width,
	wrap-mode, ...); a GTK3-ism there silently truncates the stylesheet.
	Reopen the app to see the change.

Palettes
	Master palette:  ~/.config/theme/colors-qalculate.css
	                 SINGLE SOURCE OF TRUTH. Edit colours here.
	                 Also imported by ~/.config/qalculate/qalculate-gtk-background.css,
	                 so keep its @define-color names stable.
	Desktop map:     ~/.config/theme/colors-gtk.css
	                 imports the master palette and adds the full GTK3
	                 named-colour set (theme_unfocused_*, wm_*, borders,
	                 content_view_bg, link_color, ...) plus lsu_* derivatives.
	Picker colors:   ~/.config/qalculate/qalculate-gtk-colors.conf
	                 flat key=value, must be updated by hand.
	Edit colors-qalculate.css; GTK3 and GTK4 both update automatically,
	with two caveats.
	NOTE: the import paths are asymmetric. The GTK4 sheet
	      (~/.themes/Leonardita-Sunset/gtk-4.0/gtk.css) imports
	      colors-qalculate.css DIRECTLY. The GTK3 sheet
	      (~/.themes/Leonardita-Sunset/gtk-3.0/gtk.css) reaches the same
	      palette INDIRECTLY through colors-gtk.css, which imports
	      colors-qalculate.css and then adds the full GTK3 named-color set.
	NOTE: the GTK4 sheet still carries 7 literal hex values, all of the
	      form alpha(#000000, <a>) -- shadow / shade / overlay colors on
	      lines 53, 54, 61, 67, 72, 79 and 82. They are deliberately pure
	      black (a shadow has no palette hue) and do NOT follow a palette
	      edit. Every other color in that sheet is an @lsu_* reference and
	      does follow the edit (55 references on 54 lines).
	NOTE: two apps deliberately sit OFF the global ramp, through the
	      lsu_qalc_* and lsu_nemo_* tokens in section 2b of
	      colors-gtk.css. qalculate is lifted (it is all large flat
	      panels, so it read darker than the rest of the desktop);
	      Nemo is softened (it ran at 13.6:1 text-on-view, now ~7.8:1).
	      Both still derive from the master palette, so a retheme is
	      still just the 13 lsu_* lines in colors-qalculate.css.
	      Lift with mix(), NEVER shade(): shade() multiplies HSL
	      lightness and drags saturation up with it on dark colours
	      (measured 63% against the ramp's 43-45%, which read as
	      vivid blood red instead of a lighter red).

Checking a GTK stylesheet after editing
	Easiest: run the inspector after any palette edit --
	   python3 ~/.config/theme/check-colors.py
	It catches parse errors AND prints every key surface as GTK actually
	computes it, with contrast ratio and hue/saturation/lightness, so you
	can see the effect of an edit without reopening a single app.
	It exits 1 on a parse error.

	By hand, a CSS parse error makes GTK silently DROP THE REST OF THE
	FILE, so validate explicitly. GTK3:
	   python3 -c "import gi;gi.require_version('Gtk','3.0');\
	     from gi.repository import Gtk;Gtk.init([]);p=Gtk.CssProvider();\
	     p.connect('parsing-error',lambda a,s,e:print('ERR line',s.get_start_line()+1,e.message));\
	     p.load_from_path('$HOME/.themes/Leonardita-Sunset/gtk-3.0/gtk.css')"
	GTK4: same with gi.require_version('Gtk','4.0') and load_from_file().
	No output means the file parsed cleanly.

Nemo folder icons (per-folder, main view)
	Source of truth:  ~/.config/theme/folder-icons.sh   (edit the TAGS table)
	Apply / replay:   ~/.config/theme/folder-icons.sh   then F5 in Nemo
	The tags are stored by gvfs in ~/.local/share/gvfs-metadata/ -- a binary,
	machine-local database that is NOT in the dotfiles. After a rebuild the
	icons are gone until the script is run again. Never `gio set` by hand;
	add the line to the script so the record survives.
	Sidebar icons cannot be changed this way: Nemo 6.6 hard-codes them in
	nemo_file_get_control_icon_name() -- home, the 8 XDG dirs, and
	xsi-folder-symbolic for everything else. The tag is never read there.

Nemo sidebar places
	Bookmarks file:   ~/.config/gtk-3.0/bookmarks   (URI, space, label)
	Nemo watches it and updates live. Editable from the GUI too:
	Bookmarks > Edit Bookmarks, or drag a folder into the sidebar.
	The XDG folders (Documents, Downloads, Images, Movies) get their special
	icons from ~/.config/user-dirs.dirs, hand-maintained (see its header);
	it was written by hand because the es_US locale would make the generator
	create a second, Spanish-named set of folders. Restart Nemo after editing
	it; GLib caches it at start.

Icon theme
	Active theme:     Leonardita-Sunset  (~/.local/share/icons/Leonardita-Sunset/)
	It is an overlay: Inherits=Papirus-Dark, and only holds icons that differ.
	Currently holds three *-symbolic.svg that nothing requests (see the Nemo
	sidebar note above); kept as the scaffold for future overrides.
	Symbolic rule: GTK repaints *-symbolic.svg with the widget foreground and
	DROPS STROKES, forcing a fill on every path -- draw filled shapes only.
	Tracked in the dotfiles: ~/.dotfiles_ignore excludes .local/share/* but
	negates .local/share/icons/, so new icons show in `dotfiles status`.

Folder colour (Papirus carmine / orange / ...)
	Source of truth:  ~/.config/theme/folder-color.sh <colour>
	                  --list for the 25 colours Papirus ships, --reset for blue
	It generates a SECOND icon theme, Leonardita-Sunset-folders, made of
	~490 symlinks into Papirus's own folder-<colour>-*.svg files, one per
	variant per size. The hand-made theme lists it first in Inherits, so
	the chain is  Leonardita-Sunset -> Leonardita-Sunset-folders -> Papirus-Dark.
	The generated theme is IGNORED by the dotfiles on purpose (a colour
	switch would otherwise be a 490-file diff); after a restore, run the
	script once. Nothing under /usr/share is touched, so a Papirus update
	cannot undo it. Sidebar unaffected -- that is Nemo's own xsi-* set.
	Current colour: carmine.

Dotfiles tracking
	These files are now tracked in the bare dotfiles repo
	(git --git-dir=~/.dotfiles --work-tree=~). Before this rebuild NOTHING
	under ~/.themes/ or ~/.config/gtk-3.0 / ~/.config/gtk-4.0 was tracked.
	The repo runs with status.showUntrackedFiles=no, so `dotfiles status`
	does NOT list new files. Any NEW theme file must be added BY NAME:
	   dotfiles add ~/.themes/Leonardita-Sunset/gtk-3.0/gtk.css
	A file that is never added stays invisible to `dotfiles status` --
	that is exactly how the original theme sheet went missing.

Retired
	~/.themes/.Nemo.bak/   was a stray "WarmNemo" sheet in a different brown
	                       palette, referenced by nothing. Its intent (distinct
	                       sidebar, accent buttons, accent scrollbar, orange
	                       toolbar rule) is now covered by the Nemo section of
	                       the Leonardita-Sunset GTK3 sheet.

