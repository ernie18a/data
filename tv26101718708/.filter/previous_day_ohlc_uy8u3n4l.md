#  Previous Day OHLC 

- url: https://www.tradingview.com/script/uy8u3n4l/
- type: indicator
- pine_id: PUB;e94484c1e80e4fad924f154200dca8fb
- version: 1.0

## Description

Title: Previous Day OHLC Levels

This indicator plots the Open, High, Low, and Close of the previous trading day as horizontal lines extended to the right. It works on all intraday timeframes (1min, 5min, 15min, 1H, 4H, etc.).

Features:
- Only shows levels for the current day — no clutter on past bars
- Four clearly labeled horizontal lines: PDO, PDH, PDL, PDC
- Price value displayed on each label
- Customizable colors, line style and line weight
- Info table with all four levels and prices

Levels:
- PDO — Previous Day Open (Blue)
- PDH — Previous Day High (Green)
- PDL — Previous Day Low (Red)
- PDC — Previous Day Close (Orange)

Best used on intraday charts for day trading and scalping setups.

PC

## Source Code

````pine
//@version=5
indicator(title="OHLC Día Anterior", shorttitle="PDH/PDL/PDO/PDC", overlay=true)

// ══════════════════════════════════════════════
//   CONFIGURACIÓN / INPUTS
// ══════════════════════════════════════════════
grp_colors = "Colores de las líneas"
col_open    = input.color(color.new(color.blue,   0),  "Color Open",    group=grp_colors)
col_close   = input.color(color.new(color.orange, 0),  "Color Close",   group=grp_colors)
col_high    = input.color(color.new(color.green,  0),  "Color High",    group=grp_colors)
col_low     = input.color(color.new(color.red,    0),  "Color Low",     group=grp_colors)

grp_lines = "Estilo de las líneas"
lw          = input.int(1, "Grosor de línea", minval=1, maxval=4, group=grp_lines)
ls          = input.string("─────", "Estilo de línea",
             options=["─────","- - -","·····"], group=grp_lines)

grp_labels = "Etiquetas"
show_labels = input.bool(true,  "Mostrar etiquetas", group=grp_labels)
label_size  = input.string("Normal", "Tamaño de etiqueta",
             options=["Pequeño","Normal","Grande"], group=grp_labels)

// ══════════════════════════════════════════════
//   HELPERS
// ══════════════════════════════════════════════
f_style() =>
    ls == "- - -" ? line.style_dashed :
     ls == "·····" ? line.style_dotted :
     line.style_solid

f_lsize() =>
    label_size == "Pequeño" ? size.small :
     label_size == "Grande"  ? size.large :
     size.normal

// ══════════════════════════════════════════════
//   OBTENER VALORES OHLC DEL DÍA ANTERIOR
//   Usamos request.security con timeframe "D"
//   y barmerge.lookahead_on para obtener la vela
//   diaria cerrada anterior.
// ══════════════════════════════════════════════
prev_open  = request.security(syminfo.tickerid, "D", open [1], lookahead=barmerge.lookahead_on)
prev_high  = request.security(syminfo.tickerid, "D", high [1], lookahead=barmerge.lookahead_on)
prev_low   = request.security(syminfo.tickerid, "D", low  [1], lookahead=barmerge.lookahead_on)
prev_close = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)

// ══════════════════════════════════════════════
//   DETECCIÓN: primera barra del día actual
// ══════════════════════════════════════════════
is_new_day = timeframe.isintraday ?
     dayofweek != dayofweek[1] or
     (hour == 0 and minute == 0) or
     time("D") != time("D")[1] :
     true

// ══════════════════════════════════════════════
//   VARIABLES PERSISTENTES (solo se actualizan
//   en la primera barra del día)
// ══════════════════════════════════════════════
var float val_open  = na
var float val_high  = na
var float val_low   = na
var float val_close = na

if is_new_day
    val_open  := prev_open
    val_high  := prev_high
    val_low   := prev_low
    val_close := prev_close

// ══════════════════════════════════════════════
//   DIBUJO DE LÍNEAS Y ETIQUETAS
//   Se recrean en cada nueva barra del día para
//   extenderlas hacia la derecha con el tiempo.
// ══════════════════════════════════════════════
var line  ln_o  = na
var line  ln_h  = na
var line  ln_l  = na
var line  ln_c  = na
var label lb_o  = na
var label lb_h  = na
var label lb_l  = na
var label lb_c  = na

// Función auxiliar: borra y recrea una línea
f_line(float price, color col) =>
    l = line.new(
         x1    = bar_index,
         y1    = price,
         x2    = bar_index + 1,
         y2    = price,
         color = col,
         width = lw,
         style = f_style(),
         extend= extend.right)
    l

// Función auxiliar: borra y recrea una etiqueta
f_label(float price, string txt, color col) =>
    lb = label.new(
         x        = bar_index,
         y        = price,
         text     = txt,
         color    = color.new(col, 85),
         textcolor= col,
         style    = label.style_label_right,
         size     = f_lsize())
    lb

if is_new_day and not na(val_open)
    // Elimina líneas y etiquetas anteriores
    line.delete(ln_o)
    line.delete(ln_h)
    line.delete(ln_l)
    line.delete(ln_c)
    label.delete(lb_o)
    label.delete(lb_h)
    label.delete(lb_l)
    label.delete(lb_c)

    // Crea nuevas líneas
    ln_o := f_line(val_open,  col_open)
    ln_h := f_line(val_high,  col_high)
    ln_l := f_line(val_low,   col_low)
    ln_c := f_line(val_close, col_close)

    // Crea etiquetas si están activadas
    if show_labels
        lb_o := f_label(val_open,  "PDO " + str.tostring(val_open,  format.mintick), col_open)
        lb_h := f_label(val_high,  "PDH " + str.tostring(val_high,  format.mintick), col_high)
        lb_l := f_label(val_low,   "PDL " + str.tostring(val_low,   format.mintick), col_low)
        lb_c := f_label(val_close, "PDC " + str.tostring(val_close, format.mintick), col_close)

// ══════════════════════════════════════════════
//   TABLA INFORMATIVA (esquina superior derecha)
// ══════════════════════════════════════════════
var table info = table.new(
     position = position.top_right,
     columns  = 2,
     rows     = 5,
     border_width = 1,
     border_color = color.new(color.gray, 60),
     bgcolor  = color.new(color.black, 75))

if barstate.islast and not na(val_open)
    table.cell(info, 0, 0, "Nivel",  text_color=color.white,  text_size=size.small, bgcolor=color.new(color.gray, 60))
    table.cell(info, 1, 0, "Precio", text_color=color.white,  text_size=size.small, bgcolor=color.new(color.gray, 60))
    table.cell(info, 0, 1, "PDO",    text_color=col_open,     text_size=size.small)
    table.cell(info, 1, 1, str.tostring(val_open,  format.mintick), text_color=col_open,  text_size=size.small)
    table.cell(info, 0, 2, "PDH",    text_color=col_high,     text_size=size.small)
    table.cell(info, 1, 2, str.tostring(val_high,  format.mintick), text_color=col_high,  text_size=size.small)
    table.cell(info, 0, 3, "PDL",    text_color=col_low,      text_size=size.small)
    table.cell(info, 1, 3, str.tostring(val_low,   format.mintick), text_color=col_low,   text_size=size.small)
    table.cell(info, 0, 4, "PDC",    text_color=col_close,    text_size=size.small)
    table.cell(info, 1, 4, str.tostring(val_close, format.mintick), text_color=col_close, text_size=size.small)
````
