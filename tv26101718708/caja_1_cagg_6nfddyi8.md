# CAJA 1 cagg

- url: https://www.tradingview.com/script/6NfDdyI8/
- type: indicator
- pine_id: PUB;96ecd4817ca544ce8cd81d0539bd4ff0
- version: 1.0

## Description

Caja operativa a hora configurada. Coloca la caja en la vela que quieras y la temporalidad deseada.

## Source Code

````pine
//@version=6
indicator("Session Boxes", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ─────────────────────────────────────────────
//  CONFIGURACIÓN GENERAL
// ─────────────────────────────────────────────

i_extend = input.int(5, "Extensión de la caja (velas)", minval=1, maxval=10, group="General")

// Timezone: escribe directamente el nombre IANA, ej: Europe/London, America/New_York, UTC
i_tz     = input.string("Europe/London", "Timezone (ej: Europe/London)", group="General")

// ─────────────────────────────────────────────
//  SESIÓN 1
// ─────────────────────────────────────────────
i_s1on    = input.bool(true, "Activar Sesión 1",          group="Sesión 1")
i_s1h     = input.int(0,     "Hora apertura",  minval=0, maxval=23, group="Sesión 1")
i_s1m     = input.int(0,     "Minuto apertura",minval=0, maxval=59, group="Sesión 1")
i_s1color = input.color(color.new(color.yellow, 60), "Color caja", group="Sesión 1")
i_s1label = input.string("Asia", "Etiqueta", group="Sesión 1")

// ─────────────────────────────────────────────
//  SESIÓN 2
// ─────────────────────────────────────────────
i_s2on    = input.bool(true, "Activar Sesión 2",          group="Sesión 2")
i_s2h     = input.int(8,     "Hora apertura",  minval=0, maxval=23, group="Sesión 2")
i_s2m     = input.int(0,     "Minuto apertura",minval=0, maxval=59, group="Sesión 2")
i_s2color = input.color(color.new(color.yellow, 60), "Color caja", group="Sesión 2")
i_s2label = input.string("Londres", "Etiqueta", group="Sesión 2")

// ─────────────────────────────────────────────
//  SESIÓN 3
// ─────────────────────────────────────────────
i_s3on    = input.bool(true, "Activar Sesión 3",          group="Sesión 3")
i_s3h     = input.int(13,    "Hora apertura",  minval=0, maxval=23, group="Sesión 3")
i_s3m     = input.int(0,     "Minuto apertura",minval=0, maxval=59, group="Sesión 3")
i_s3color = input.color(color.new(color.yellow, 60), "Color caja", group="Sesión 3")
i_s3label = input.string("NY", "Etiqueta", group="Sesión 3")

// ─────────────────────────────────────────────
//  FUNCIÓN: ¿Es la primera vela de esta sesión?
// ─────────────────────────────────────────────
isFirstCandle(sessH, sessM) =>
    curH  = hour(time,    i_tz)
    curM  = minute(time,  i_tz)
    prevH = hour(time[1], i_tz)
    prevM = minute(time[1], i_tz)
    cur   = curH  * 60 + curM
    prev  = prevH * 60 + prevM
    sess  = sessH * 60 + sessM
    barMins = math.round(timeframe.in_seconds() / 60)
    cur <= sess and cur + barMins > sess and prev < sess

// ─────────────────────────────────────────────
//  DIBUJO DE CAJAS
// ─────────────────────────────────────────────
drawBox(active, sessH, sessM, col, lbl) =>
    if active and isFirstCandle(sessH, sessM)
        mid = (high + low) / 2
        box.new(
             left         = bar_index,
             top          = high,
             right        = bar_index + i_extend,
             bottom       = low,
             border_color = color.new(color.yellow, 20),
             border_width = 1,
             bgcolor      = col)
        line.new(
             x1    = bar_index,
             y1    = mid,
             x2    = bar_index + i_extend,
             y2    = mid,
             color = color.black,
             width = 1,
             style = line.style_dashed)
        label.new(
             x         = bar_index + i_extend,
             y         = high,
             text      = lbl,
             style     = label.style_label_left,
             color     = color.new(color.yellow, 80),
             textcolor = chart.fg_color,
             size      = size.small)

drawBox(i_s1on, i_s1h, i_s1m, i_s1color, i_s1label)
drawBox(i_s2on, i_s2h, i_s2m, i_s2color, i_s2label)
drawBox(i_s3on, i_s3h, i_s3m, i_s3color, i_s3label)
````
