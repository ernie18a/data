# XAUUSD  Support and Resistance 5m

- url: https://www.tradingview.com/script/lFsIYyyg/
- type: indicator
- pine_id: PUB;230216523a814b82af5f8265333dea87
- version: 1.0

## Description

Use this indicator only with XAUUSD in 5m timeframe

## Source Code

````pine
// ============================================================
//  XAUUSD · Support & Resistance (5m)
//  Pine Script v6
//
//  Capas de S/R (de mayor a menor importancia):
//
//  1. NIVELES PSICOLOGICOS  — múltiplos de 100 y 50 USD/oz
//  2. PIVOT POINTS diarios  — PP, R1-R3, S1-S3 (sesión anterior)
//  3. SWING HIGHS / LOWS    — pivotes confirmados en 5m
//  4. EQUAL HIGHS / LOWS    — dobles techos/suelos (pools de stops)
// ============================================================

//@version=6
indicator(
     title           = "XAUUSD · Support & Resistance (5m)",
     shorttitle      = "XAU·SR",
     overlay         = true,
     max_lines_count  = 500,
     max_labels_count = 200
     )

// ════════════════════════════════════════
//  INPUTS
// ════════════════════════════════════════
grp1 = "Niveles Psicologicos"
show_psych  = input.bool(true,  "Mostrar niveles psicologicos",  group = grp1)
show_p100   = input.bool(true,  "Niveles x100 USD (clave)",      group = grp1)
show_p50    = input.bool(true,  "Niveles x50  USD (mayores)",    group = grp1)
show_p10    = input.bool(false, "Niveles x10  USD (menores)",    group = grp1)

grp2 = "Pivot Points Diarios"
show_pivot  = input.bool(true, "Mostrar Pivot Points",           group = grp2)

grp3 = "Swing Highs / Lows"
show_swing  = input.bool(true,  "Mostrar Swing H/L",             group = grp3)
swing_len   = input.int(8, "Longitud swing (barras)",
     minval = 3, maxval = 20, group = grp3,
     tooltip = "Barras a cada lado para confirmar un swing.")
eq_tol      = input.float(0.3, "Tolerancia Equal H/L (USD)",
     minval = 0.1, maxval = 2.0, step = 0.1, group = grp3,
     tooltip = "Diferencia maxima para considerar dos swings 'iguales'.")

grp4 = "Colores"
col_p100    = input.color(color.new(#FF4560, 0),  "Color x100 (clave)",    group = grp4)
col_p50     = input.color(color.new(#F4A300, 0),  "Color x50  (mayor)",    group = grp4)
col_p10     = input.color(color.new(#8B949E, 50), "Color x10  (menor)",    group = grp4)
col_pp      = input.color(color.new(#A78BFA, 0),  "Color Pivot PP",        group = grp4)
col_r       = input.color(color.new(#FF4560, 0),  "Color Resistencias R",  group = grp4)
col_s       = input.color(color.new(#00E5A0, 0),  "Color Soportes S",      group = grp4)
col_sh      = input.color(color.new(#F4A300, 0),  "Color Swing High",      group = grp4)
col_sl      = input.color(color.new(#5D8AA8, 0),  "Color Swing Low",       group = grp4)
col_eq      = input.color(color.new(#E879F9, 0),  "Color Equal H/L",       group = grp4)

// ════════════════════════════════════════
//  1. NIVELES PSICOLOGICOS
// ════════════════════════════════════════
if show_psych and barstate.islast

    // x100 — niveles clave absolutos
    if show_p100
        base100 = math.floor(close / 100) * 100
        for i = -3 to 3
            lvl = base100 + i * 100
            line.new(bar_index - 300, lvl, bar_index + 30, lvl,
                 color = col_p100, style = line.style_solid, width = 2)
            label.new(bar_index + 30, lvl,
                 text      = str.tostring(lvl, "#") + " KEY",
                 color     = color.new(col_p100, 80),
                 textcolor = col_p100,
                 style     = label.style_label_left,
                 size      = size.small)

    // x50 — niveles mayores intermedios
    if show_p50
        base50 = math.floor(close / 50) * 50
        for i = -5 to 5
            lvl = base50 + i * 50
            is100 = lvl % 100 == 0
            if not is100
                line.new(bar_index - 200, lvl, bar_index + 30, lvl,
                     color = col_p50, style = line.style_dashed, width = 1)
                label.new(bar_index + 30, lvl,
                     text      = str.tostring(lvl, "#"),
                     color     = color.new(col_p50, 85),
                     textcolor = col_p50,
                     style     = label.style_label_left,
                     size      = size.tiny)

    // x10 — niveles menores de ruido filtrado
    if show_p10
        base10 = math.floor(close / 10) * 10
        for i = -8 to 8
            lvl = base10 + i * 10
            is50 = lvl % 50 == 0
            if not is50
                line.new(bar_index - 80, lvl, bar_index + 30, lvl,
                     color = col_p10, style = line.style_dotted, width = 1)

// ════════════════════════════════════════
//  2. PIVOT POINTS DIARIOS
//  Se calculan sobre la sesión anterior (OHLC del día previo)
// ════════════════════════════════════════
// Detectar cambio de día
is_new_day = ta.change(time("D")) != 0

// Capturar OHLC del día anterior cuando empieza el nuevo día
var float prev_high  = na
var float prev_low   = na
var float prev_close = na
var float day_high   = na
var float day_low    = na
var float day_open   = na

// Acumular max/min durante el día actual
day_high := na(day_high[1]) or is_new_day ? high : math.max(day_high[1], high)
day_low  := na(day_low[1])  or is_new_day ? low  : math.min(day_low[1],  low)

if is_new_day
    prev_high  := day_high[1]
    prev_low   := day_low[1]
    prev_close := close[1]

// Calcular Pivots clásicos
pp = (prev_high + prev_low + prev_close) / 3
r1 = 2 * pp - prev_low
r2 = pp + (prev_high - prev_low)
r3 = prev_high + 2 * (pp - prev_low)
s1 = 2 * pp - prev_high
s2 = pp - (prev_high - prev_low)
s3 = prev_low - 2 * (prev_high - pp)

// Dibujar Pivots en la última barra
if show_pivot and barstate.islast and not na(pp)
    // PP
    line.new(bar_index - 200, pp, bar_index + 30, pp,
         color = col_pp, style = line.style_solid, width = 1)
    label.new(bar_index + 30, pp,
         text = "PP  " + str.tostring(pp, "#.0"),
         color = color.new(col_pp, 80), textcolor = col_pp,
         style = label.style_label_left, size = size.tiny)

    // Resistencias
    line.new(bar_index - 200, r1, bar_index + 30, r1,
         color = col_r, style = line.style_dashed, width = 1)
    label.new(bar_index + 30, r1,
         text = "R1  " + str.tostring(r1, "#.0"),
         color = color.new(col_r, 80), textcolor = col_r,
         style = label.style_label_left, size = size.tiny)

    line.new(bar_index - 200, r2, bar_index + 30, r2,
         color = col_r, style = line.style_dashed, width = 1)
    label.new(bar_index + 30, r2,
         text = "R2  " + str.tostring(r2, "#.0"),
         color = color.new(col_r, 80), textcolor = col_r,
         style = label.style_label_left, size = size.tiny)

    line.new(bar_index - 200, r3, bar_index + 30, r3,
         color = col_r, style = line.style_dashed, width = 1)
    label.new(bar_index + 30, r3,
         text = "R3  " + str.tostring(r3, "#.0"),
         color = color.new(col_r, 80), textcolor = col_r,
         style = label.style_label_left, size = size.tiny)

    // Soportes
    line.new(bar_index - 200, s1, bar_index + 30, s1,
         color = col_s, style = line.style_dashed, width = 1)
    label.new(bar_index + 30, s1,
         text = "S1  " + str.tostring(s1, "#.0"),
         color = color.new(col_s, 80), textcolor = col_s,
         style = label.style_label_left, size = size.tiny)

    line.new(bar_index - 200, s2, bar_index + 30, s2,
         color = col_s, style = line.style_dashed, width = 1)
    label.new(bar_index + 30, s2,
         text = "S2  " + str.tostring(s2, "#.0"),
         color = color.new(col_s, 80), textcolor = col_s,
         style = label.style_label_left, size = size.tiny)

    line.new(bar_index - 200, s3, bar_index + 30, s3,
         color = col_s, style = line.style_dashed, width = 1)
    label.new(bar_index + 30, s3,
         text = "S3  " + str.tostring(s3, "#.0"),
         color = color.new(col_s, 80), textcolor = col_s,
         style = label.style_label_left, size = size.tiny)

// ════════════════════════════════════════
//  3. SWING HIGHS / LOWS
// ════════════════════════════════════════
swing_high = ta.pivothigh(high, swing_len, swing_len)
swing_low  = ta.pivotlow (low,  swing_len, swing_len)

// Guardar los últimos 2 swings para detectar Equals
var float sh1 = na
var float sh2 = na
var float sl1 = na
var float sl2 = na
var int   bsh1 = na
var int   bsl1 = na

if not na(swing_high)
    sh2 := sh1
    sh1 := swing_high
    bsh1 := bar_index - swing_len

if not na(swing_low)
    sl2 := sl1
    sl1 := swing_low
    bsl1 := bar_index - swing_len

if show_swing
    if not na(swing_high)
        line.new(
             bar_index - swing_len, swing_high,
             bar_index + 8,         swing_high,
             color = col_sh, style = line.style_solid, width = 1)
        label.new(
             bar_index - swing_len, swing_high,
             text      = "SH " + str.tostring(swing_high, "#.0"),
             color     = color.new(col_sh, 80),
             textcolor = col_sh,
             style     = label.style_label_down,
             size      = size.tiny)

    if not na(swing_low)
        line.new(
             bar_index - swing_len, swing_low,
             bar_index + 8,         swing_low,
             color = col_sl, style = line.style_solid, width = 1)
        label.new(
             bar_index - swing_len, swing_low,
             text      = "SL " + str.tostring(swing_low, "#.0"),
             color     = color.new(col_sl, 80),
             textcolor = col_sl,
             style     = label.style_label_up,
             size      = size.tiny)

// ════════════════════════════════════════
//  4. EQUAL HIGHS / LOWS (dobles techos/suelos)
// ════════════════════════════════════════
eq_high = not na(sh1) and not na(sh2) and math.abs(sh1 - sh2) <= eq_tol
eq_low  = not na(sl1) and not na(sl2) and math.abs(sl1 - sl2) <= eq_tol

eq_h_lvl = eq_high ? math.max(sh1, sh2) : na
eq_l_lvl = eq_low  ? math.min(sl1, sl2) : na

if show_swing and eq_high and not na(eq_h_lvl)
    line.new(bar_index - 60, eq_h_lvl, bar_index + 12, eq_h_lvl,
         color = col_eq, style = line.style_solid, width = 2)
    label.new(bar_index + 12, eq_h_lvl,
         text      = "EQH " + str.tostring(eq_h_lvl, "#.0"),
         color     = color.new(col_eq, 75),
         textcolor = col_eq,
         style     = label.style_label_left,
         size      = size.small)

if show_swing and eq_low and not na(eq_l_lvl)
    line.new(bar_index - 60, eq_l_lvl, bar_index + 12, eq_l_lvl,
         color = col_eq, style = line.style_solid, width = 2)
    label.new(bar_index + 12, eq_l_lvl,
         text      = "EQL " + str.tostring(eq_l_lvl, "#.0"),
         color     = color.new(col_eq, 75),
         textcolor = col_eq,
         style     = label.style_label_left,
         size      = size.small)

// ════════════════════════════════════════
//  TABLA DE NIVELES CERCANOS
// ════════════════════════════════════════
base50   = math.floor(close / 50) * 50
prox_s   = base50
prox_r   = base50 + 50
dist_s   = math.round((close - prox_s) * 100) / 100
dist_r   = math.round((prox_r - close) * 100) / 100

pp_txt   = not na(pp)  ? str.tostring(pp,  "#.0") : "—"
r1_txt   = not na(r1)  ? str.tostring(r1,  "#.0") : "—"
s1_txt   = not na(s1)  ? str.tostring(s1,  "#.0") : "—"
sh1_txt  = not na(sh1) ? str.tostring(sh1, "#.0") : "—"
sl1_txt  = not na(sl1) ? str.tostring(sl1, "#.0") : "—"
eqh_txt  = eq_high and not na(eq_h_lvl) ? str.tostring(eq_h_lvl, "#.0") + " EQH" : "—"
eql_txt  = eq_low  and not na(eq_l_lvl) ? str.tostring(eq_l_lvl, "#.0") + " EQL" : "—"

if barstate.islast
    var table tb = table.new(
         position     = position.top_right,
         columns      = 2,
         rows         = 11,
         bgcolor      = color.new(#0D1117, 5),
         border_color = color.new(#30363D, 0),
         border_width = 1,
         frame_color  = color.new(#30363D, 0),
         frame_width  = 1)

    // Header
    table.cell(tb, 0, 0, "XAUUSD  S&R",
         text_color = color.new(#F0C040, 0), text_size = size.small,
         bgcolor = color.new(#161B22, 0), text_halign = text.align_center)
    table.cell(tb, 1, 0, "5m",
         text_color = color.new(#F0C040, 0), text_size = size.small,
         bgcolor = color.new(#161B22, 0), text_halign = text.align_center)

    // Precio
    table.cell(tb, 0, 1, "Precio actual",
         text_color = color.new(#8B949E, 0), text_size = size.tiny, text_halign = text.align_left)
    table.cell(tb, 1, 1, str.tostring(close, "#.00") + " $",
         text_color = color.new(#E6EDF3, 0), text_size = size.tiny, text_halign = text.align_right)

    // Psicologo mas cercano
    table.cell(tb, 0, 2, "Soporte x50",
         text_color = color.new(#8B949E, 0), text_size = size.tiny, text_halign = text.align_left)
    table.cell(tb, 1, 2, str.tostring(prox_s, "#") + "  (-" + str.tostring(dist_s, "#.0") + ")",
         text_color = col_s, text_size = size.tiny, text_halign = text.align_right)

    table.cell(tb, 0, 3, "Resistencia x50",
         text_color = color.new(#8B949E, 0), text_size = size.tiny, text_halign = text.align_left)
    table.cell(tb, 1, 3, str.tostring(prox_r, "#") + "  (+" + str.tostring(dist_r, "#.0") + ")",
         text_color = col_r, text_size = size.tiny, text_halign = text.align_right)

    // Pivots
    table.cell(tb, 0, 4, "Pivot PP",
         text_color = color.new(#8B949E, 0), text_size = size.tiny, text_halign = text.align_left)
    table.cell(tb, 1, 4, pp_txt,
         text_color = col_pp, text_size = size.tiny, text_halign = text.align_right)

    table.cell(tb, 0, 5, "Pivot R1",
         text_color = color.new(#8B949E, 0), text_size = size.tiny, text_halign = text.align_left)
    table.cell(tb, 1, 5, r1_txt,
         text_color = col_r, text_size = size.tiny, text_halign = text.align_right)

    table.cell(tb, 0, 6, "Pivot S1",
         text_color = color.new(#8B949E, 0), text_size = size.tiny, text_halign = text.align_left)
    table.cell(tb, 1, 6, s1_txt,
         text_color = col_s, text_size = size.tiny, text_halign = text.align_right)

    // Swings
    table.cell(tb, 0, 7, "Swing High",
         text_color = color.new(#8B949E, 0), text_size = size.tiny, text_halign = text.align_left)
    table.cell(tb, 1, 7, sh1_txt,
         text_color = col_sh, text_size = size.tiny, text_halign = text.align_right)

    table.cell(tb, 0, 8, "Swing Low",
         text_color = color.new(#8B949E, 0), text_size = size.tiny, text_halign = text.align_left)
    table.cell(tb, 1, 8, sl1_txt,
         text_color = col_sl, text_size = size.tiny, text_halign = text.align_right)

    // Equal H/L
    table.cell(tb, 0, 9, "Equal High/Low",
         text_color = color.new(#8B949E, 0), text_size = size.tiny, text_halign = text.align_left)
    eq_combined = eqh_txt != "—" ? eqh_txt : eql_txt != "—" ? eql_txt : "—"
    table.cell(tb, 1, 9, eq_combined,
         text_color = col_eq, text_size = size.tiny, text_halign = text.align_right)

    // Footer
    table.cell(tb, 0, 10, "XAU·SR v6",
         text_color = color.new(#30363D, 0), text_size = size.tiny, text_halign = text.align_left)
    table.cell(tb, 1, 10, "Pine v6",
         text_color = color.new(#30363D, 0), text_size = size.tiny, text_halign = text.align_right)
````
