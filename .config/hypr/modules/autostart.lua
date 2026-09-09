local vars = require("variables")

hl.on("hyprland.start", function()
    -- Desktop shell
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hypridle")
    -- Waybar goes through waybar-launch.sh, which starts the Hyprland IPC
    -- shim first: Waybar still speaks the pre-Lua dispatcher syntax, so its
    -- workspace clicks need translating (see hypr-ipc-shim.py).
    hl.exec_cmd("~/.config/sh-scripts/waybar-launch.sh")
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
    hl.exec_cmd(vars.whatsApp)
    hl.exec_cmd(vars.music)

    hl.exec_cmd("fcitx5 -d --disable=notificationitem")

    -- Input language toggling
    hl.exec_cmd("~/.config/sh-scripts/input-lang-watch.sh")
end)
