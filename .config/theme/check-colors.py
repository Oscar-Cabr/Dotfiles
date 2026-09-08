#!/usr/bin/env python3
"""Leonardita-Sunset palette inspector.

Edit ~/.config/theme/colors-qalculate.css, then run this before reopening
any app. It (1) catches CSS parse errors -- GTK silently drops the rest of
a stylesheet after one, so a typo can truncate the whole theme -- and
(2) reports every key surface as GTK actually computes it, with contrast
and colour geometry.

Rules of thumb:
  contrast   4.5:1 minimum for body text, 7:1 = WCAG AAA,
             above ~11:1 starts to feel harsh on large surfaces.
  saturation keep backgrounds within a few points of each other or the
             odd one out reads as a different colour family.

A surface marked * paints no background of its own and inherits the opaque
parent behind it; "transparent" on those rows is correct, not a fault.
"""
import sys, gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, Gdk, GLib

SHEETS = ["/home/racso/.themes/Leonardita-Sunset/gtk-3.0/gtk.css",
          "/home/racso/.config/theme/colors-gtk.css",
          "/home/racso/.config/theme/colors-qalculate.css",
          "/home/racso/.themes/Leonardita-Sunset/gtk-4.0/gtk.css"]

errs = []
for f in SHEETS:
    p = Gtk.CssProvider()
    p.connect("parsing-error",
              lambda pr, sec, e, f=f: errs.append(f"{f}:{sec.get_start_line()+1}: {e.message}"))
    try:
        p.load_from_path(f)
    except GLib.Error as e:
        errs.append(f"{f}: FATAL {e.message}")
if errs:
    print("CSS PARSE ERRORS -- theme is truncated, fix before reopening apps:")
    for e in errs:
        print("  " + e)
    sys.exit(1)
print("parse: clean\n")

def _lin(c):
    c /= 255.0
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
def lum(c):
    return 0.2126*_lin(c.red*255) + 0.7152*_lin(c.green*255) + 0.0722*_lin(c.blue*255)
def ratio(a, b):
    la, lb = lum(a), lum(b)
    if la < lb: la, lb = lb, la
    return (la + 0.05) / (lb + 0.05)
def hx(c):
    return "#%02x%02x%02x" % (int(c.red*255+.5), int(c.green*255+.5), int(c.blue*255+.5))
def hsl(c):
    r, g, b = c.red, c.green, c.blue
    mx, mn = max(r, g, b), min(r, g, b)
    l, d = (mx+mn)/2, mx-mn
    if d == 0: return 0.0, 0.0, l*100
    s = d/(2-mx-mn) if l > 0.5 else d/(mx+mn)
    h = ((g-b)/d) % 6 if mx == r else (b-r)/d+2 if mx == g else (r-g)/d+4
    return h*60, s*100, l*100

def ctx(nodes):
    path = Gtk.WidgetPath()
    for name, classes, wname in nodes:
        i = path.append_type(Gtk.Widget)
        path.iter_set_object_name(i, name)
        for c in classes: path.iter_add_class(i, c)
        if wname: path.iter_set_name(i, wname)
    c = Gtk.StyleContext()
    c.set_path(path); c.set_screen(Gdk.Screen.get_default())
    return c

N, SEL = Gtk.StateFlags.NORMAL, Gtk.StateFlags.SELECTED
W = ("window", ("background",), None)
SURFACES = [
    ("desktop window",     [W], False),
    ("desktop text well",  [W, ("text", ("view",), None)], True),
    ("button",             [W, ("button", (), None)], False),
    # menuitem/row paint no background of their own -- they inherit the
    # opaque parent (menu, list). Transparent here is CORRECT, not a bug.
    ("menu item*",         [W, ("menu", (), None), ("menuitem", (), None)], True),
    ("NEMO file list",     [W, ("box", ("nemo-window",), None), ("treeview", ("view",), None)], True),
    ("NEMO sidebar",       [W, ("treeview", ("view", "nemo-places-sidebar"), None)], True),
    ("QALC window",        [("window", ("background",), "main_window")], False),
    ("QALC keypad key",    [("window", ("background",), "main_window"),
                            ("box", (), "grid_buttons"), ("button", (), None)], False),
]
print("%-20s %-9s %-9s %9s   %s" % ("surface", "bg", "fg", "contrast", "bg geometry"))
print("-" * 78)
for label, nodes, show_sel in SURFACES:
    c = ctx(nodes)
    bg, fg = c.get_property("background-color", N), c.get_color(N)
    h, s, l = hsl(bg)
    warn = ""
    r = ratio(fg, bg)
    inherits = label.endswith("*")
    if bg.alpha < 0.9:
        warn = "  (inherits parent bg - normal)" if inherits else "  <-- TRANSPARENT"
    elif r < 4.5:        warn = "  <-- unreadable (<4.5:1)"
    elif r > 11.5:       warn = "  <-- harsh on large surfaces (>11.5:1)"
    print("%-20s %-9s %-9s %7.2f:1   hue=%5.1f sat=%4.1f%% L=%4.1f%%%s"
          % (label, hx(bg), hx(fg), r, h, s, l, warn))
    if show_sel:
        sb, sf = c.get_property("background-color", SEL), c.get_color(SEL)
        print("%-20s %-9s %-9s %7.2f:1" % ("  ^ selected", hx(sb), hx(sf), ratio(sf, sb)))

print("\npalette tokens as GTK resolves them:")
c = ctx([W])
for n in ["lsu_bg", "lsu_bg_dark", "lsu_bg_light", "lsu_text", "lsu_accent", "lsu_border",
          "lsu_qalc_bg", "lsu_nemo_view", "lsu_nemo_text", "lsu_nemo_sel"]:
    ok, col = c.lookup_color(n)
    if ok:
        h, s, l = hsl(col)
        print("  %-18s %-9s  hue=%5.1f sat=%4.1f%% L=%4.1f%%" % (n, hx(col), h, s, l))
    else:
        print("  %-18s UNRESOLVED" % n)
