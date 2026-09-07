-- ~/.config/hypr/modules/env.lua
--
-- Old form: env = KEY,VALUE   (hyprlang split on the first comma)
-- New form: hl.env("KEY", "VALUE")

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
hl.env("GTK_IM_MODULE", "fcitx")
hl.env("QT_IM_MODULE",  "fcitx")
hl.env("XMODIFIERS",    "@im=fcitx")
hl.env("SDL_IM_MODULE", "fcitx")
hl.env("INPUT_METHOD",  "fcitx")
