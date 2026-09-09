# Input language toggle (US / LATAM / Chinese pinyin)

One gesture, one indicator: `Shift + Alt` cycles US -> LATAM -> 中文 -> US.
Waybar's `custom/language` module shows the current one live and cycles it
on click. There is exactly one keybind and one indicator — do not add a
second one, see Gotchas below.

## The gesture lives in xkb, not Hyprland

`/home/racso/.config/hypr/hyprland.lua:115-119` sets:

```lua
kb_layout  = "us,latam,cn",
kb_options = "grp:alt_shift_toggle",
```

Three xkb groups, cycled by xkb itself. `alt_shift_toggle` maps to xkb's
`ISO_Next_Group`, which walks all groups in `kb_layout`, so `Shift + Alt`
cycles all three, not just two.

The `cn` group is the trick. `/usr/share/X11/xkb/symbols/cn:4-9`:

```
default partial alphanumeric_keys
xkb_symbols "basic" {
    include "us(basic)"
    name[Group1]= "Chinese";
};
```

It's plain QWERTY (correct for typing pinyin) under a layout name
("Chinese") that the rest of the system can detect. `us` and `latam` are
real xkb layouts, so Spanish accents work in every app, including
XWayland windows and games that never talk to fcitx5. Only the Chinese
group needs fcitx5, because hanzi need a candidate-selection window that
no keyboard layout can provide.

`hyprland.lua` and `binds.lua` both carry a comment instead of a bind:
`/home/racso/.config/hypr/modules/binds.lua:28-30` explicitly documents
that there is **no** Hyprland keybind for this — see Gotcha 2.

## How a keypress becomes hanzi (or doesn't)

1. `Shift + Alt` on some physical keyboard: xkb advances that keyboard's
   group. Hyprland doesn't see the gesture at all.
2. `/home/racso/.config/sh-scripts/input-lang-watch.sh` sits on
   Hyprland's event socket
   (`$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock`,
   resolved by `socket_path()`) and reads `activelayout>>DEVICE,LAYOUT`
   lines. It ignores events from `hl-virtual-keyboard*` (fcitx5's own
   virtual device) and maps the layout name to `us` / `latam` / `zh`
   (script lines 74-79).
3. On an actual state change (guarded — see Gotcha 4) it:
   - mirrors the new group onto every keyboard:
     `hyprctl switchxkblayout all <index>` (0 us, 1 latam, 2 cn);
   - runs `input-lang.sh sync`.
4. `input-lang.sh sync` calls `reconcile()`, which turns fcitx5's pinyin
   IM on when the target state is `zh` (`fcitx5-remote -s pinyin` then
   `-o`) and closes it (`fcitx5-remote -c`) otherwise, then signals
   Waybar with `pkill -RTMIN+9 waybar`
   (`/home/racso/.config/sh-scripts/input-lang.sh:23,62-69,78`).
5. Waybar's `custom/language` module
   (`/home/racso/.config/waybar/modules.jsonc:168-175`) runs
   `input-lang.sh status` on that signal (`"signal": 9`) for an instant
   update, and also on a plain 2-second `interval` as a self-healing
   fallback if the watcher isn't running.
6. Clicking the module (`"on-click": "input-lang.sh cycle"`) runs
   `hyprctl switchxkblayout all next` — the same group switch the
   keyboard gesture uses, so both entry points share one path.

`input-lang.sh status` and `sync` both call a shared `current()`, which
reads every **non-virtual** keyboard's layout via
`hyprctl -j devices | jq ...active_keymap` and picks Chinese if any
keyboard reports it, else Latin, else US (script lines 40-52) — see
Gotcha 3 for why it's written this way.

## Files involved

| File | Role |
| --- | --- |
| `/home/racso/.config/hypr/hyprland.lua` | `input.kb_layout` / `kb_options` — owns the xkb groups and the gesture |
| `/home/racso/.config/hypr/modules/env.lua` | Input-method env vars (`QT_IM_MODULE`, `XMODIFIERS`, `SDL_IM_MODULE`, `INPUT_METHOD`); deliberately does **not** set `GTK_IM_MODULE` |
| `/home/racso/.config/hypr/modules/autostart.lua` | Starts `fcitx5 -d --disable=notificationitem` and `input-lang-watch.sh` |
| `/home/racso/.config/hypr/modules/binds.lua` | Comment only — records that Shift+Alt has no Hyprland bind, on purpose |
| `/home/racso/.config/sh-scripts/input-lang.sh` | `status` (Waybar exec), `cycle` (Waybar click), `sync` (called by the watcher) |
| `/home/racso/.config/sh-scripts/input-lang-watch.sh` | Hyprland event-socket watcher |
| `/home/racso/.config/waybar/config` | `custom/language` listed in `modules-right` |
| `/home/racso/.config/waybar/modules.jsonc` | The `custom/language` module definition |
| `/home/racso/.config/waybar/style.css` | `#custom-language`, `.latam`, `.zh` rules |
| `/home/racso/.config/theme/colors-waybar.css` | `@border-language`, `@text-language`, `@language-latam`, `@language-zh` |
| `/home/racso/.config/fcitx5/config` | `[Hotkey/TriggerKeys]` / `[Hotkey/AltTriggerKeys]` emptied, `ShareInputState=All` |
| `/home/racso/.config/fcitx5/profile` | `Default Layout=us`, `DefaultIM=pinyin` |

## Gotchas — do not redo this work

1. **Never set `GTK_IM_MODULE` on Wayland.** It forces GTK onto the
   legacy immodule path (needs `fcitx5-gtk`, not installed) and fcitx5
   shows a "Wayland Diagnose" warning on every login. GTK3/GTK4 reach
   fcitx5 over `text-input-v3` with the variable unset — see the comment
   at `/home/racso/.config/hypr/modules/env.lua:18-21`. `QT_IM_MODULE`
   and `XMODIFIERS` stay set on purpose (Qt apps via `fcitx5-qt`, and
   XWayland apps).

2. **Hyprland does not fire release-binds on a bare modifier key.**
   Binding `Shift + Alt` with `hl.bind(..., { release = true })`
   registers fine (shows up in `hyprctl binds`) but never triggers, for
   every modmask combination tried. That's why the gesture is left to
   xkb's `grp:alt_shift_toggle`. Do not "fix" this by adding a Hyprland
   keybind — see `/home/racso/.config/hypr/modules/binds.lua:28-30`.

3. **Never identify the keyboard with Hyprland's `.main` flag.** fcitx5
   registers a virtual keyboard, `hl-virtual-keyboard-fcitx5`, and
   Hyprland can mark *that* as `.main`. Excluding virtual devices and
   taking the first remaining entry is equally wrong — the first entry
   can be something like `acer-wireless-radio-control`, whose group
   never changes. `input-lang.sh`'s `current()` instead reads every
   non-virtual keyboard's layout and takes the highest state present
   (Chinese > Latin > US) — see `input-lang.sh:27-39`.

4. **xkb groups are per device.** `Shift + Alt` only moves the keyboard
   it was pressed on, so the watcher mirrors the new group onto every
   keyboard with `hyprctl switchxkblayout all <index>`. That mirroring
   emits another burst of `activelayout` events, so the watcher only
   acts when the state actually changed (`[ "$state" = "$seen" ] &&
   continue`, `input-lang-watch.sh:84-85`) — without that guard it
   echoes forever.

5. **fcitx5's own tray icon (the `notificationitem` addon) can only be
   disabled with `--disable=notificationitem`** on the command line, in
   `/home/racso/.config/hypr/modules/autostart.lua:28`. Setting
   `Enabled=False` in an addon `.conf` and setting `DisabledAddons=` in
   `/home/racso/.config/fcitx5/config` are both no-ops — verified, both
   were tried (comment at `fcitx5/config:77-80`).

6. **`ShareInputState` defaults to `No`, which keeps input state per
   window.** That makes the language appear to reset when changing
   workspace — it's really resetting per focused window. It's set to
   `All` in `/home/racso/.config/fcitx5/config:57`.

7. **fcitx5's own switching hotkeys are deliberately emptied** in
   `/home/racso/.config/fcitx5/config`: `[Hotkey/TriggerKeys]` (was
   `Control+space`) and `[Hotkey/AltTriggerKeys]` (was `Shift_L`, an
   undocumented bare-Shift toggle). There must be exactly one switching
   gesture.

8. **The socket reader in `input-lang-watch.sh` runs as a background job
   (`| { ... } &`) followed by `wait $!`**, not as the script's
   foreground pipeline. bash defers traps until the foreground command
   returns, and the reader blocks forever — as a plain foreground
   pipeline the script ignored `SIGTERM` and needed `kill -9`. See the
   comment at `input-lang-watch.sh:36-39`.

## Verification / troubleshooting

Check current fcitx5 state (`0` closed, `1` inactive, `2` active — this
is the convention `input-lang.sh` itself relies on, see
`input-lang.sh:63,67`) and current input method:

```sh
fcitx5-remote      # 0 / 1 / 2
fcitx5-remote -n   # name of the active input method, e.g. "pinyin"
```

Check the xkb group of every keyboard:

```sh
hyprctl -j devices | jq -r '.keyboards[] | "\(.name) \(.active_keymap)"'
```

Force a group directly (0 us, 1 latam, 2 cn):

```sh
hyprctl switchxkblayout all 0
hyprctl switchxkblayout all 1
hyprctl switchxkblayout all 2
```

What Waybar renders right now (also reconciles fcitx5 as a side effect):

```sh
/home/racso/.config/sh-scripts/input-lang.sh status
```

Is the watcher alive:

```sh
ps -eo pid,args | grep input-lang-watch
```

If the indicator is stuck: confirm the watcher is running (above), then
`hyprctl switchxkblayout all 0` to force a known group and retest. If
fcitx5 never activates on the `cn` group, check `fcitx5-remote -n` — it
should report `pinyin` (`Default Layout=us`, `DefaultIM=pinyin` in
`/home/racso/.config/fcitx5/profile:5,7`).

## Requirements

Must stay installed for this to keep working:

- `fcitx5` — the input method framework
- `fcitx5-chinese-addons` — pinyin dictionary/engine
- `fcitx5-qt` — lets Qt apps reach fcitx5 via `QT_IM_MODULE=fcitx`
- `noto-fonts-cjk` — hanzi rendering
- `jq` — used by `input-lang.sh` to parse `hyprctl -j devices`
  (`input-lang-watch.sh` parses the event lines in pure bash)
