local vars    = require("variables")
local mainMod = vars.mainMod

local restartBars = [[pkill waybar && waybar & disown && pkill eww && eww open left-bar && notify-send "──────  Waybar and Eww restarted ───────"]]

local edgeNoProfile = [[microsoft-edge-stable --ozone-platform=wayland --enable-features=UseOzonePlatform --force-device-scale-factor=1]]

---------------------------
---- GENERAL KEYBINDS -----
---------------------------

hl.bind(mainMod .. " + RETURN",    hl.dsp.exec_cmd(vars.terminal))              -- Win + Enter
hl.bind(mainMod .. " + BACKSPACE", hl.dsp.exit())                               -- Kills hyprland active session
hl.bind(mainMod .. " + A",         hl.dsp.exec_cmd(vars.menu))                  -- Apps
hl.bind(mainMod .. " + C",         hl.dsp.window.close())                       -- Kills active window
hl.bind(mainMod .. " + F",         hl.dsp.window.float({ action = "toggle" }))  -- Float

hl.bind("PRINT",         hl.dsp.exec_cmd("hyprshot -m window -o ~/Images/Screenshots")) -- Full-window screenshot
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd("hyprshot -m region -o ~/Images/Screenshots")) -- Cropped screenshot

hl.bind(mainMod .. " + Q", hl.dsp.layout("togglesplit")) -- dwindle
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())       -- dwindle

hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("cliphist list | fuzzel --dmenu | cliphist decode | wl-copy")) -- Opens clipboard
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(edgeNoProfile))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(restartBars))

-- Shift + Alt alternates between us and latam keyboard (see input.kb_options in hyprland.lua).

-----------------------------
---- FOCUS MOVEMENT --------
-----------------------------

-- Move focus with arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Move focus with Vim keys
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))

-----------------------------
---- WORKSPACES ------------
-----------------------------

-- Switch workspaces with mainMod + [0-9], and move the active window with
-- mainMod + SHIFT + [0-9]. This loop replaces 20 hand-written binds.
for i = 1, 10 do
    local key = i % 10 -- workspace 10 sits on key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with the mouse wheel
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Cycle workspaces with horizontal arrow keys
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.focus({ workspace = "e+1" }))

-- Cycle workspaces with horizontal Vim keys
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.focus({ workspace = "e+1" }))

-----------------------------
---- MOUSE -----------------
-----------------------------

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-----------------------------
---- MEDIA / HARDWARE ------
-----------------------------

-- Laptop multimedia keys for volume and LCD brightness (old bindel)
local el = { locked = true, repeating = true }

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), el)
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      el)
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     el)
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   el)

-- NOTE: these two are carried over exactly as they were: in the old config
-- BrightnessUp ran "1%-" and BrightnessDown ran "1%+" (inverted).
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 1%-"), el)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 1%+"), el)

hl.bind("Scroll_Lock", hl.dsp.exec_cmd("hyprlock"), el)

-- Requires playerctl (old bindl)
local l = { locked = true }

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       l)
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), l)
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), l)
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   l)
