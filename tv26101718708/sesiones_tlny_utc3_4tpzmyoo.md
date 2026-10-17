# sesiones (T/L/NY) utc-3

- url: https://www.tradingview.com/script/4tpzMyOo/
- type: indicator
- pine_id: PUB;f23bc1fe30cf4862bb9ec3b0ed50a606
- version: 1.0

## Description

sesiones. utc-3. londres, tokyo, nueva york. etiquetas y franjas.

## Source Code

````pine
//@version=5
indicator("Mis Killzones CRT con Etiquetas (UTC-3)", overlay=true, max_labels_count=500)

// --- CONFIGURACIÓN DE HORARIOS (UTC-3) ---
zona_tokio   = input.session("2100-0600", "Tokio (A)", group="Horarios")
zona_londres = input.session("0400-0700", "Londres (L)", group="Horarios")
zona_ny      = input.session("0900-1200", "NY (NY)", group="Horarios")

// --- CONFIGURACIÓN DE COLORES ---
color_tk  = input.color(color.new(#313339, 85), "Color Asia/Tokio", group="Estilo")
color_lon = input.color(color.new(#45818e, 85), "Color Londres", group="Estilo")
color_ny  = input.color(color.new(#00bcd4, 75), "Color NY (Resaltado)", group="Estilo")

// --- LÓGICA DE SESIÓN ---
in_session(sess) => 
    not na(time(timeframe.period, sess, "GMT-3"))

// Detectar el primer bar de la sesión
is_first(sess) =>
    in_session(sess) and not in_session(sess)[1]

// Función para crear etiquetas
f_label(_txt, _color) =>
    label.new(bar_index, high, _txt, 
         yloc=yloc.abovebar, 
         color=_color, 
         style=label.style_label_down, 
         textcolor=color.white, 
         size=size.small)

// --- DIBUJAR FONDOS Y ETIQUETAS ---
// Tokio
bgcolor(in_session(zona_tokio) ? color_tk : na, title="Fondo Tokio")
if is_first(zona_tokio)
    f_label("A", color.new(color_tk, 0))

// Londres
bgcolor(in_session(zona_londres) ? color_lon : na, title="Fondo Londres")
if is_first(zona_londres)
    f_label("L", color.new(color_lon, 0))

// NY
bgcolor(in_session(zona_ny) ? color_ny : na, title="Fondo NY")
if is_first(zona_ny)
    f_label("NY", color.new(color_ny, 0))
````
