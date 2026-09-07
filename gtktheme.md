# Tema GTK reconstruido: registro del arreglo

> Registro cerrado. Escrito el 2026-09-07. Sustituye al documento de traspaso
> anterior, que contenía un diagnóstico de causa raíz **incorrecto** (ver
> "Corrección del diagnóstico anterior"). El arreglo ya está aplicado y
> commiteado: commit `275253c` en la rama `main`, **sin push**.

## Contexto de la máquina

Arch Linux rolling, kernel `6.18.49-2-lts`, Hyprland 0.56.2 sobre Wayland,
hostname `arch-racso`, usuario `racso`.
gtk3 `1:3.24.52-1`, gtk4 `1:4.22.4-1`, libadwaita `1:1.9.3-1`.

El disco duro viejo falló y el sistema se reconstruyó desde cero en un NVMe
nuevo el **2026-09-06**: paquetes reinstalados a mano y dotfiles recuperados
desde el repo bare en `~/.dotfiles` (-> `github.com/Oscar-Cabr/Dotfiles`).
Casi todo lo raro que aparece en esta máquina viene de ese restore -- este
bug incluido.

## Síntoma (resuelto)

En navegadores basados en Chromium (Brave, Chromium, Edge) **al seleccionar
texto el resaltado no se veía**: fondo y texto quedaban del mismo color.
Nemo salía sin estilar. El usuario lo notó justo después de instalar fcitx5
para escribir en chino, pero fcitx5 no era la causa (ver "Falsa pista").

## Causa raíz (corregida)

`gsettings` declaraba como tema global del escritorio `Leonardita-Sunset`,
pero el directorio `~/.themes/Leonardita-Sunset/` sólo contenía la hoja de
estilos de `qalculate-gtk`: 1091 líneas acotadas por completo a los IDs de
widget de esa app (`#main_window`, `#historyview`, `#stackview`,
`#expressiontext`, ...). El archivo había sido escrito para vivir en
`~/.config/gtk-3.0/gtk.css` -- lo dice su propia cabecera -- y estaba mal
archivado dentro de `~/.themes/<nombre>/gtk-3.0/gtk.css` y registrado como
tema del sistema.

GTK3 carga el `gtk.css` de un tema con nombre **EN LUGAR DE** Adwaita, no
encima. Así que toda app que no fuera qalculate caía al CSS interno mínimo
de GTK y calculaba un fondo transparente. De ahí la selección invisible en
Chromium/Brave/Edge y el Nemo sin estilar.

### Corrección del diagnóstico anterior

El documento anterior afirmaba con seguridad que la causa era que el tema
"define cero `@define-color`" y que por eso no publicaba
`theme_selected_bg_color`. **Eso es falso.** Sólo estaba midiendo el
`gtk.css` propio del tema, mientras que la paleta llegaba por un `@import`.
Comprobado con una sonda `GtkTextView` offscreen bajo
`GTK_THEME=Leonardita-Sunset:dark`:

    @theme_selected_bg_color RESUELVE correctamente a #f9a03f
    pero el fondo COMPUTADO del widget era #000000 a=0.00 (transparente),
    tanto en estado NORMAL como SELECTED

La paleta siempre estuvo bien; **nada la consumía**, porque el tema no
tenía ninguna regla general de widget. Chromium lee el color *computado*
del widget, no el color con nombre, así que pintaba un resaltado invisible.
Que un futuro lector no vuelva a derivar la conclusión equivocada: el
problema no eran los `@define-color` ausentes, sino la ausencia de reglas.

### Segundo hallazgo (descubierto durante la implementación)

El Adwaita que trae GTK 3.24 (`gtk-contained-dark.css`) es SASS compilado:
sus reglas usan hex hard-codeado y **no referencian ningún nombre
`@theme_*`**. Su bloque `@define-color` es una API de sólo lectura para las
apps, no una entrada a sus propias reglas. Redefinir colores con nombre por
tanto **no retiñe Adwaita** -- sólo publica una paleta correcta a las apps
que leen los nombres directamente (Chromium/Brave, GIMP, Firefox). El
retinte visual hubo que hacerlo con reglas explícitas.

**Esto es lo más importante para el yo-futuro:** hace que la capa a medida
grande (miles de líneas en el `gtk.css` de GTK3) parezca redundante cuando
NO lo es. No "simplificarla" borrándola.

## Qué se hizo -- commit `275253c`, rama `main`, SIN push

Añadido a git (7 archivos eran nuevos en el repo; nada bajo `.themes/` ni
`.config/gtk-*/` había estado nunca trackeado):

    .themes/Leonardita-Sunset/gtk-3.0/gtk.css   3526 líneas (antes 1091)
    .themes/Leonardita-Sunset/gtk-4.0/gtk.css    135 líneas  NUEVO
    .themes/Leonardita-Sunset/index.theme          9 líneas  Type=Application -> Type=X-GNOME-Metatheme
    .config/theme/colors-gtk.css                  99 líneas  NUEVO
    .config/theme/colors-qalculate.css            52 líneas  contenido SIN CAMBIOS, recién trackeado
    .config/gtk-3.0/settings.ini                  12 líneas
    .config/gtk-4.0/settings.ini                  13 líneas
    .config/gtk-4.0/gtk.css                       12 líneas
    .config/theme/RELOAD.txt                      modificado

### Ensamblado del tema GTK3

`~/.themes/Leonardita-Sunset/gtk-3.0/gtk.css` se arma en cuatro capas:

1. `@import` de Adwaita desde el gresource
   (`resource:///org/gtk/libgtk/theme/Adwaita/gtk-contained-dark.css`),
   como red de seguridad estructural: métricas, bordes, iconos y un fallback
   legible para lo que no se estile abajo.
2. La paleta, vía `@import` de `~/.config/theme/colors-gtk.css`, que a su vez
   importa el maestro `~/.config/theme/colors-qalculate.css` y añade el juego
   completo de colores con nombre de GTK3 (`theme_unfocused_*`, `wm_*`,
   `borders`, `content_view_bg`, `link_color`, ...) más derivadas `lsu_*`.
3. Una capa de widgets a medida (secciones 2-16) más una sección Nemo
   (sección 17), que restata cada regla con color explícito.
4. La hoja original de qalculate, preservada **byte a byte** como las últimas
   1067 líneas (sección 18); su acotado a `#main_window` sigue ganando sobre
   la capa general.

### Ensamblado del tema GTK4

`~/.themes/Leonardita-Sunset/gtk-4.0/gtk.css` (135 líneas) es sólo un recolor
de colores con nombre, sin capa de widgets a medida. Importa
`colors-qalculate.css` **directamente** (asimetría con GTK3, que va por
`colors-gtk.css`), redefine los nombres de libadwaita 1.9.3, los nombres de
compat de GTK4 puro, y restata la selección de texto (`selection`,
`:selected`) para el caso de una app GTK4 sin libadwaita. libadwaita SÍ
recomputa sus sombras desde estos nombres, así que aquí los nombres bastan.
Contiene además 7 valores hex literales, todos `alpha(#000000, <a>)` para
sombras -- deliberadamente negras, no siguen la paleta.

Punto de entrada GTK4: `~/.config/gtk-4.0/gtk.css` (un solo `@import` del
anterior). Es el único hook que respetan las apps libadwaita, que ignoran
`gtk-theme-name`.

### `index.theme`

Pasó de `Type=Application` a `Type=X-GNOME-Metatheme` (9 líneas;
`GtkTheme=Leonardita-Sunset`, `IconTheme=Papirus-Dark`).

### Ajustes aplicados en vivo con `gsettings` (`org.gnome.desktop.interface`)

    gtk-theme      = 'Leonardita-Sunset'
    color-scheme   : 'default'  -> 'prefer-dark'
    icon-theme     : 'Adwaita'  -> 'Papirus-Dark'

`~/.config/gtk-3.0/settings.ini` (12 líneas) y `~/.config/gtk-4.0/settings.ini`
(13 líneas) reflejan lo mismo (`gtk-theme-name=Leonardita-Sunset`,
`gtk-icon-theme-name=Papirus-Dark`, `gtk-font-name=Noto Sans 10`,
`gtk-application-prefer-dark-theme=1`) para las apps que ignoran el portal.

Nota: los valores de `gsettings` no viven en ningún archivo del repo y no se
pueden re-verificar leyendo el disco; quedan registrados aquí a partir del
trabajo de la sesión.

### Retirado

`~/.themes/Nemo/` (una hoja "WarmNemo" suelta, en otra paleta marrón, que no
referenciaba nada) movida a `~/.themes/.Nemo.bak/`. Nunca estuvo trackeada.
Su intención (barra lateral distinta, botones y scrollbar de acento, regla de
toolbar naranja) la cubre ahora la sección Nemo del `gtk.css` de GTK3.

El backup pre-rewrite de la hoja GTK3 está en
`~/.themes/.Leonardita-Sunset.gtk3.css.bak`, fuera del directorio del tema
para que no se trackee como parte del tema.

## Qué se verificó

- Sonda `GtkTextView` offscreen: antes del arreglo, fondo computado
  `#000000 a=0.00`; `@theme_selected_bg_color` resolvía a `#f9a03f` pero
  nadie lo consumía.
- `~/.themes/Leonardita-Sunset/gtk-3.0/gtk.css`: 3526 líneas; importa Adwaita
  + `colors-gtk.css`; la sección 18 es la hoja de qalculate preservada
  literal (últimas 1067 líneas).
- `~/.themes/Leonardita-Sunset/gtk-4.0/gtk.css`: 135 líneas; importa
  `colors-qalculate.css` directamente; 54 usos de `@lsu_*` y 7 hex literales
  `alpha(#000000, ...)` (sombras).
- `~/.config/gtk-4.0/gtk.css`: un `@import` del tema GTK4.
- `index.theme`: `Type=X-GNOME-Metatheme`.
- `colors-gtk.css` importa `colors-qalculate.css` y publica los nombres
  `theme_unfocused_*`, `wm_*`, `content_view_bg`, `link_color`, etc.
- `/var/log/pacman.log`: sin ningún rastro de `fcitx5-gtk` (nunca instalado);
  `/usr/lib/gtk-3.0/3.0.0/immodules/` no tiene módulo fcitx, pero sí
  `im-wayland.so` (frontend nativo de Wayland).

## Falsa pista: fcitx5 no es la causa

El usuario asoció el fallo con instalar fcitx5, pero es coincidencia
temporal: todo se instaló el mismo día del restore. Del `/var/log/pacman.log`:

    [2026-09-06T20:31:33] installed gtk4 (1:4.22.4-1)
    [2026-09-06T20:55:35] installed fcitx5 (5.1.21-1)
    [2026-09-06T20:55:44] installed fcitx5-qt (5.1.14-2)
    [2026-09-06T20:55:46] installed fcitx5-chinese-addons (5.1.13-2)
    [2026-09-06T20:55:54] installed fcitx5-configtool (5.1.14-1)
    [2026-09-06T20:57:02] installed papirus-icon-theme (20260801-1)

El CSS de qalculate mal archivado llevaba en su sitio desde mucho antes; el
tema estaba mal configurado antes de tocar fcitx5.

## Cabos sueltos -- NO abordados por este trabajo

Todos siguen abiertos. Este arreglo fue sólo del tema GTK.

- **`GTK_IM_MODULE=fcitx`** se exporta en `~/.config/hypr/modules/env.lua`
  **línea 18** (el documento anterior decía "línea 23"; en disco el bloque de
  input method es 18-22: `GTK_IM_MODULE`, `QT_IM_MODULE`, `XMODIFIERS`,
  `SDL_IM_MODULE`, `INPUT_METHOD`). `fcitx5-gtk` no está instalado, así que
  ese módulo GTK no existe; `im-wayland.so` ya da el frontend nativo en
  Wayland. `GTK_IM_MODULE` sobra y se puede borrar esa línea. No se tocó:
  está fuera de alcance y es un `.lua`.
- **`xdg-desktop-portal-gtk`** se cayó una vez el 2026-09-07 con
  `cannot open display:` y se recuperó solo a los ~9 s. Un portal GTK
  intentando hablar X11 en sesión Wayland. Sin investigar; puede ser benigno
  o un segundo bug.
- **`swaync`** emite tres errores de parseo de CSS en cada arranque:
  `style.css:43 -gtk-icon-effect`, `:64 max-width`, `:65 wrap-mode`
  (propiedades GTK3 en una hoja GTK4). Verificado en disco. Cosmético.
- **La fuente es inconsistente por tres lados** y se dejó a propósito:
  - `gsettings font-name` -> `'Adwaita Sans 11'` (gana bajo el portal; valor
    no verificable en disco, va según el trabajo de la sesión).
  - `~/.config/gtk-3.0/settings.ini` y `~/.config/gtk-4.0/settings.ini`:
    `gtk-font-name=Noto Sans 10`.
  - `~/.config/theme/font`: `MAIN_FONT="CodeNewRoman Nerd Font"`
    (más `FALLBACK_FONT="JetBrainsMono Nerd Font"`,
    `TERMINAL_FONT="RobotoMono Nerd Font"`).
  `~/.config/theme/update-fonts.sh` sólo sustituye placeholders
  `__MAIN_FONT__` / `__FALLBACK_FONT__` / `__TERMINAL_FONT__` en
  waybar/eww/swaync/fuzzel/wofi/kitty; **no toca** `settings.ini` ni
  `gsettings`, así que no reconcilia esta discrepancia.
- **No hay tema de cursor** configurado en ningún archivo del entorno
  (ni `env.lua` ni los `settings.ini`); sólo tamaño, `XCURSOR_SIZE=24` y
  `HYPRCURSOR_SIZE=24` en `env.lua:12-13`. Según el trabajo de la sesión,
  `gsettings cursor-theme` está en `'default'`.
