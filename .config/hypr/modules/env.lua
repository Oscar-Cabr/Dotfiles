hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE",    "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

hl.env("GDK_BACKEND",     "wayland,x11,*")
hl.env("QT_QPA_PLATFORM",  "wayland;xcb")
hl.env("SDL_VIDEODRIVER",  "wayland")

hl.env("TERMINAL", "kitty")
hl.env("BROWSER",  "microsoft-edge-wayland")

hl.env("XCURSOR_SIZE",   "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-- fcitx5 input method
-- GTK_IM_MODULE is deliberately NOT set: on Wayland, GTK3/GTK4 talk to fcitx5
-- through the text-input-v3 protocol. Setting it forces the legacy immodule
-- path (which needs fcitx5-gtk) and makes fcitx5 warn on every login.
-- See https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland
hl.env("QT_IM_MODULE",  "fcitx")   -- Qt apps, via fcitx5-qt
hl.env("XMODIFIERS",    "@im=fcitx") -- XWayland apps
hl.env("SDL_IM_MODULE", "fcitx")
hl.env("INPUT_METHOD",  "fcitx")
