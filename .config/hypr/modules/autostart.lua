local vars = require("variables")

hl.on("hyprland.start", function()
    -- Desktop shell
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("waybar")
    hl.exec_cmd("eww daemon")
    hl.exec_cmd("eww open left-bar")

    -- Clipboard history
    hl.exec_cmd("cliphist wipe")
    hl.exec_cmd("cliphist store")
    hl.exec_cmd("/home/racso/.config/sh-scripts/cliphist-notify.sh")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("wl-paste --watch --primary cliphist store")

    -- Apps pinned to their workspaces
    hl.exec_cmd(vars.terminal,   { workspace = 1 })
    hl.exec_cmd(vars.webBrowser, { workspace = 8 })
    hl.exec_cmd(vars.whatsApp,   { workspace = 9 })
    hl.exec_cmd(vars.music,      { workspace = 10 })

    -- Input method. --disable=notificationitem drops fcitx5's own tray icon
    -- (the little keyboard glyph): the custom/language Waybar module already
    -- shows the language and cycles it on click. The flag has to live here --
    -- setting Enabled=False in an addon .conf does not disable it.
    hl.exec_cmd("fcitx5 -d --disable=notificationitem")

    -- Watches Hyprland's activelayout events and switches fcitx5 on when the
    -- xkb group reaches cn. Shift + Alt is handled inside xkb, so without this
    -- nothing would ever tell fcitx5 or Waybar that the language changed.
    hl.exec_cmd("~/.config/sh-scripts/input-lang-watch.sh")
end)
