local colors = require("hypr-colors")

hl.config({
    general = {
        gaps_in     = 5,
        gaps_out    = 10,
        border_size = 2,

        col = {
            active_border = {
                colors = { colors.active_border1, colors.active_border2 },
                angle  = 40,
            },
            inactive_border = colors.inactive_border,
        },

        resize_on_border = true,
        allow_tearing    = true,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 15,
        rounding_power = 2,

        -- NOTE: active_opacity was 2.0 in the old config. Valid range is 0.0-1.0,
        -- so Hyprland clamps this to 1.0 (fully opaque). Carried over verbatim.
        active_opacity   = 2.0,
        inactive_opacity = 0.5,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = colors.shadow_border_color,
        },

        blur = {
            enabled  = true,
            size     = 5,
            passes   = 1,
            vibrancy = 0.5,
        },
    },
})
