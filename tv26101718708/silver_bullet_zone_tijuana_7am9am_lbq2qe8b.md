# Silver Bullet Zone - Tijuana (7AM-9AM)

- url: https://www.tradingview.com/script/Lbq2Qe8b/
- type: indicator
- pine_id: PUB;3947adf6b76046d98d94d62472a121fa
- version: 1.0

## Description

The indicator visually highlights the 7:00 AM to 9:00 AM (Tijuana time) time slot—equivalent to 10:00 AM–12:00 PM ET—directly on the TradingView chart.

* Semi-transparent yellow background during those two hours.
* Vertical dashed lines marking the exact start and end of the session.
* Text labels at the beginning of each zone for easy identification.
* Fully customizable via inputs: change colors, start times, and end times.

In practice, it provides a visual alert for when you are within the NY ICT Silver Bullet window for the US30.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Abiezerk

//@version=6
indicator("Silver Bullet Zone - Tijuana (7AM-9AM)", overlay = true)

// ─────────────────────────────────────────────
// CONFIGURACIÓN
// ─────────────────────────────────────────────
color_zone   = input.color(color.new(color.yellow, 80), "Color de la franja")
color_border = input.color(color.new(color.yellow, 20), "Color del borde")
show_label   = input.bool(true, "Mostrar etiqueta")

start_hour = input.int(10, "Hora inicio (ET)", minval = 0, maxval = 23)
start_min  = input.int(0,  "Minuto inicio",    minval = 0, maxval = 59)
end_hour   = input.int(12, "Hora fin (ET)",    minval = 0, maxval = 23)
end_min    = input.int(0,  "Minuto fin",       minval = 0, maxval = 59)

// ─────────────────────────────────────────────
// LÓGICA DE TIEMPO
// ─────────────────────────────────────────────
hour_et   = hour(time,   "America/New_York")
minute_et = minute(time, "America/New_York")

time_in_minutes  = hour_et    * 60 + minute_et
start_in_minutes = start_hour * 60 + start_min
end_in_minutes   = end_hour   * 60 + end_min

in_zone    = time_in_minutes >= start_in_minutes and time_in_minutes < end_in_minutes
zone_start = in_zone and not in_zone[1]
zone_end   = not in_zone and in_zone[1]

// ─────────────────────────────────────────────
// FONDO DE LA FRANJA
// ─────────────────────────────────────────────
bgcolor(in_zone ? color_zone : na, title = "Franja Silver Bullet")

// ─────────────────────────────────────────────
// LÍNEAS VERTICALES
// ─────────────────────────────────────────────
if zone_start
    line.new(bar_index, low, bar_index, high,
             color = color_border,
             width = 2,
             style = line.style_dashed,
             extend = extend.both)

if zone_end
    line.new(bar_index, low, bar_index, high,
             color = color_border,
             width = 2,
             style = line.style_dashed,
             extend = extend.both)

// ─────────────────────────────────────────────
// ETIQUETA
// ─────────────────────────────────────────────
if zone_start and show_label
    label.new(bar_index, high,
              "Silver Bullet\n7AM-9AM Tijuana",
              color      = color.new(color.yellow, 10),
              textcolor  = color.black,
              style      = label.style_label_down,
              size       = size.small)
````
