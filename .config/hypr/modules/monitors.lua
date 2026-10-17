local vars = require("variables")

hl.monitor({
    output   = vars.screen,
    mode     = "1920x1080@60",
    position = "0x0",
    scale    = 1,
})

-- Mirror any connected external screen (HDMI, DP, etc.) to the laptop display
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
    mirror   = vars.screen,
})

-- Old: monitor = $screen, addreserved, 0, 0, 52, 0
-- New equivalent (kept commented, as it was):
-- hl.monitor({
--     output   = vars.screen,
--     reserved = { top = 0, right = 0, bottom = 52, left = 0 },
-- })
