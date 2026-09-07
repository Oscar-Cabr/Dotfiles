hl.window_rule({
    name  = "windowrule-1",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    name  = "windowrule-2",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

hl.window_rule({
    name   = "windowrule-3",
    match  = { class = "^(qalculate-gtk)$" },

    float  = true,
    center = true,
    size   = "800 600",
})

hl.window_rule({
    name   = "windowrule-4",
    match  = { class = "^(blueman-manager)$" },

    float  = true,
    center = true,
    size   = "1000 800",
})

hl.window_rule({
    name   = "windowrule-5",
    match  = { class = "^(nemo)$" },

    float  = true,
    center = true,
    size   = "1200 800",
})

hl.window_rule({
    name   = "windowrule-6",
    match  = { class = "^(feathernotes)$" },

    float  = true,
    center = true,
    size   = "1200 800",
})

hl.workspace_rule({ workspace = "1",  persistent = true }) -- Terminal
hl.workspace_rule({ workspace = "8",  persistent = true }) -- Browser
hl.workspace_rule({ workspace = "9",  persistent = true }) -- WhatsApp
hl.workspace_rule({ workspace = "10", persistent = true }) -- Spotify
