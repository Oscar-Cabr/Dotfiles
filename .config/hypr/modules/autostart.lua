-- ~/.config/hypr/modules/autostart.lua
--
-- Old form: exec-once = <cmd>
--           exec-once = [workspace N] <cmd>
-- New form: everything runs on the "hyprland.start" event; the old
--           [workspace N] prefix becomes the rules table on hl.exec_cmd.

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

    -- Input method
    hl.exec_cmd("fcitx5 -d")
end)
