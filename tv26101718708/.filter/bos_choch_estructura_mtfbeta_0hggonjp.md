# BOS & CHoCH - Estructura MTF-BETA

- url: https://www.tradingview.com/script/0hgGoNjp/
- type: indicator
- pine_id: PUB;3c8675e445b946f8870e01d744122f32
- version: 1.0

## Description

TEST 1,esta es la version beta de el indicaro lo que significa que no esta al 100%

## Source Code

````pine
//@version=6
indicator("BOS & CHoCH - Estructura MTF", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=200)

// ═══════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════
swing_len  = input.int(10, "Longitud Swing (barras)", minval=3, maxval=50)
tf1        = input.timeframe("60",  "TF 1")
tf2        = input.timeframe("240", "TF 2")
tf3        = input.timeframe("D",   "TF 3")

show_bos   = input.bool(true, "Mostrar BOS")
show_choch = input.bool(true, "Mostrar CHoCH")
show_lines = input.bool(true, "Mostrar líneas de nivel")

// ═══════════════════════════════════════════════
// COLORES
// ═══════════════════════════════════════════════
C_BULL   = #00E676
C_BEAR   = #FF1744
C_CHOCH  = #FFD600
C_NEUT   = #9E9E9E

// ═══════════════════════════════════════════════
// LÓGICA PRINCIPAL (en timeframe actual del gráfico)
// Detecta swings, BOS y CHoCH con validación de CUERPO
// ═══════════════════════════════════════════════

// — Swing High y Swing Low usando pivots —
swingHigh = ta.pivothigh(high, swing_len, swing_len)
swingLow  = ta.pivotlow(low,  swing_len, swing_len)

// Guardar últimos 2 swings altos y bajos
var float lastHH  = na
var float prevHH  = na
var float lastLL  = na
var float prevLL  = na
var int   lastHH_bar = na
var int   lastLL_bar = na

if not na(swingHigh)
    prevHH     := lastHH
    lastHH     := swingHigh
    lastHH_bar := bar_index[swing_len]

if not na(swingLow)
    prevLL     := lastLL
    lastLL     := swingLow
    lastLL_bar := bar_index[swing_len]

// — Validación con CUERPO de vela (no mecha) —
body_close = close  // El cierre es el cuerpo que importa

// BOS Alcista: cierre supera el último swing high con cuerpo
bos_bull = not na(lastHH) and ta.crossover(body_close, lastHH)

// BOS Bajista: cierre rompe el último swing low con cuerpo
bos_bear = not na(lastLL) and ta.crossunder(body_close, lastLL)

// CHoCH: necesitamos saber la tendencia previa
var int trend = 0  // 1=alcista, -1=bajista, 0=indefinido

// CHoCH Bajista (venía subiendo y rompe mínimo): primer quiebre contrario
choch_bear = trend == 1  and bos_bear
// CHoCH Alcista (venía bajando y rompe máximo): primer quiebre contrario
choch_bull = trend == -1 and bos_bull

// Actualizar tendencia
if bos_bull and not choch_bull
    trend := 1
if bos_bear and not choch_bear
    trend := -1
if choch_bull
    trend := 1
if choch_bear
    trend := -1

// ═══════════════════════════════════════════════
// ETIQUETAS EN EL GRÁFICO
// ═══════════════════════════════════════════════
if show_bos and bos_bull and not choch_bull
    label.new(bar_index, high, "BOS", 
         style=label.style_label_up, 
         color=color.new(C_BULL, 10), 
         textcolor=color.white, 
         size=size.small)

if show_bos and bos_bear and not choch_bear
    label.new(bar_index, low, "BOS", 
         style=label.style_label_down, 
         color=color.new(C_BEAR, 10), 
         textcolor=color.white, 
         size=size.small)

if show_choch and choch_bear
    label.new(bar_index, low, "CHoCH", 
         style=label.style_label_down, 
         color=color.new(C_CHOCH, 10), 
         textcolor=color.black, 
         size=size.small)

if show_choch and choch_bull
    label.new(bar_index, high, "CHoCH", 
         style=label.style_label_up, 
         color=color.new(C_CHOCH, 10), 
         textcolor=color.black, 
         size=size.small)

// ═══════════════════════════════════════════════
// LÍNEAS DE NIVEL (último swing high y low)
// ═══════════════════════════════════════════════
var line line_hh = na
var line line_ll = na

if show_lines
    if not na(lastHH)
        line.delete(line_hh)
        line_hh := line.new(lastHH_bar, lastHH, bar_index, lastHH,
             color=color.new(C_BULL, 40), width=1, style=line.style_dashed)
    if not na(lastLL)
        line.delete(line_ll)
        line_ll := line.new(lastLL_bar, lastLL, bar_index, lastLL,
             color=color.new(C_BEAR, 40), width=1, style=line.style_dashed)

// ═══════════════════════════════════════════════
// TENDENCIA POR TEMPORALIDAD (para la tabla)
// ═══════════════════════════════════════════════
get_trend(tf) =>
    // Traemos el valor de "trend" calculado en esa temporalidad
    t = request.security(syminfo.tickerid, tf, trend, lookahead=barmerge.lookahead_off)
    t

t1 = get_trend(tf1)
t2 = get_trend(tf2)
t3 = get_trend(tf3)

// Tendencia global por votos
votos  = (na(t1) ? 0 : t1) + (na(t2) ? 0 : t2) + (na(t3) ? 0 : t3)
global = votos >= 2 ? 1 : votos <= -2 ? -1 : 0

// ═══════════════════════════════════════════════
// HELPERS TABLA
// ═══════════════════════════════════════════════
f_txt(v) =>
    v == 1 ? "▲  ALCISTA" : v == -1 ? "▼  BAJISTA" : "●  NEUTRAL"

f_col(v) =>
    v == 1 ? color.new(C_BULL, 0) : v == -1 ? color.new(C_BEAR, 0) : color.new(C_NEUT, 0)

f_bg(v) =>
    v == 1 ? color.new(C_BULL, 80) : v == -1 ? color.new(C_BEAR, 80) : color.new(#1A1A1A, 0)

// ═══════════════════════════════════════════════
// TABLA — ESQUINA SUPERIOR DERECHA
// ═══════════════════════════════════════════════
var table T = table.new(position.top_right, 2, 5,
     bgcolor      = color.new(#0A0A0A, 5),
     border_color = color.new(#2A2A2A, 0),
     border_width = 1,
     frame_color  = color.new(#444444, 0),
     frame_width  = 1)

// Header
table.cell(T, 0, 0, "TF",          text_color=color.new(#BDBDBD,0), text_size=size.small, bgcolor=color.new(#1C1C1C,0), text_halign=text.align_center)
table.cell(T, 1, 0, "ESTRUCTURA",  text_color=color.new(#BDBDBD,0), text_size=size.small, bgcolor=color.new(#1C1C1C,0), text_halign=text.align_center)

// 1H
table.cell(T, 0, 1, " 1H ", text_color=color.white, text_size=size.small, bgcolor=color.new(#111111,0), text_halign=text.align_center)
table.cell(T, 1, 1, f_txt(t1), text_color=f_col(t1), text_size=size.small, bgcolor=f_bg(t1), text_halign=text.align_center)

// 4H
table.cell(T, 0, 2, " 4H ", text_color=color.white, text_size=size.small, bgcolor=color.new(#111111,0), text_halign=text.align_center)
table.cell(T, 1, 2, f_txt(t2), text_color=f_col(t2), text_size=size.small, bgcolor=f_bg(t2), text_halign=text.align_center)

// D
table.cell(T, 0, 3, "  D  ", text_color=color.white, text_size=size.small, bgcolor=color.new(#111111,0), text_halign=text.align_center)
table.cell(T, 1, 3, f_txt(t3), text_color=f_col(t3), text_size=size.small, bgcolor=f_bg(t3), text_halign=text.align_center)

// Global
g_txt = global == 1 ? "⬆  ALCISTA" : global == -1 ? "⬇  BAJISTA" : "◆  MIXTO"
table.cell(T, 0, 4, "GLOBAL", text_color=color.new(#FFD600,0), text_size=size.small, bgcolor=color.new(#1C1C1C,0), text_halign=text.align_center)
table.cell(T, 1, 4, g_txt,    text_color=f_col(global),        text_size=size.normal, bgcolor=f_bg(global),        text_halign=text.align_center)

// ═══════════════════════════════════════════════
// ALERTAS
// ═══════════════════════════════════════════════
alertcondition(bos_bull  and not choch_bull, "BOS Alcista",  "Rompimiento alcista confirmado con cuerpo")
alertcondition(bos_bear  and not choch_bear, "BOS Bajista",  "Rompimiento bajista confirmado con cuerpo")
alertcondition(choch_bull,                   "CHoCH Alcista","Cambio de carácter: giro al alza")
alertcondition(choch_bear,                   "CHoCH Bajista","Cambio de carácter: giro a la baja")
alertcondition(global == 1,  "✅ Tendencia ALCISTA MTF", "2 o más TF alineados al alza")
alertcondition(global == -1, "🔴 Tendencia BAJISTA MTF", "2 o más TF alineados a la baja")
````
