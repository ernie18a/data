# Silver Bullet Zone

- url: https://www.tradingview.com/script/TPDuXnbH/
- type: indicator
- pine_id: PUB;1994516c67664e4a9e72b66c53238f4b
- version: 1.0

## Description

Delimita la zona operativa de la Silver Bullet, donde el Precio te genera un FVG el cual puede ofrecerte un movimiento a favor de tu posición en busca de Sellside o Buyside.

## Source Code

````pine
//@version=6
indicator("Silver Bullet Zone", overlay = true)

// ─────────────────────────────────────────────
// CONFIGURACIÓN
// ─────────────────────────────────────────────
color_zone   = input.color(color.new(color.gray, 90), "Color de la franja")
color_border = input.color(color.rgb(154, 156, 161), "Color de las líneas")

start_hour = input.int(10, "Hora inicio (ET)", minval = 0, maxval = 23)
start_min  = input.int(0,  "Minuto inicio",    minval = 0, maxval = 59)
end_hour   = input.int(11, "Hora fin (ET)",    minval = 0, maxval = 23)
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
// FONDO
// ─────────────────────────────────────────────
bgcolor(in_zone ? color_zone : na)

// ─────────────────────────────────────────────
// LÍNEAS + TEXTO INTEGRADO
// ─────────────────────────────────────────────
if zone_start
    line.new(bar_index, low, bar_index, high,
         color = color_border,
         width = 2,
         style = line.style_solid,
         extend = extend.both)

    label.new(bar_index, high,
         "SILVER BULLET",
         color = color.new(color.gray, 90),   // fondo casi invisible
         textcolor = color_border,
         style = label.style_label_down,
         size = size.small)

if zone_end
    line.new(bar_index, low, bar_index, high,
         color = color_border,
         width = 2,
         style = line.style_solid,
         extend = extend.both)

    label.new(bar_index, high,
         "SILVER BULLET",
         color = color.new(color.gray, 90),
         textcolor = color_border,
         style = label.style_label_down,
         size = size.small)
````
