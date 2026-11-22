# IFVG + SMT Pro [ICT]

- url: https://www.tradingview.com/script/yEjG21Ib-IFVG-SMT-Pro-ICT/
- type: indicator
- pine_id: PUB;4bac1c751d05474e979ca26ff396a427
- version: 1.0

## Description

assssssssssssssdd+
sszzzzzzzzzz
daaaasss
wwwwwwwww
dawwww
dssssssssaaaaaçww

## Source Code

````pine
//@version=5
indicator("IFVG + SMT Pro [ICT]", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// ══════════════════════════════════════════════════════════
//  CONFIGURACION GENERAL
// ══════════════════════════════════════════════════════════
grp1 = "=== IFVG ==="
showIFVG      = input.bool(true,  "Mostrar IFVG",                 group=grp1)
showOnlyHP    = input.bool(false, "Solo IFVG Alta Probabilidad",  group=grp1)
colBullIFVG   = input.color(color.new(#00e676, 0),  "Color IFVG Compra",  group=grp1)
colBearIFVG   = input.color(color.new(#ff1744, 0),  "Color IFVG Venta",   group=grp1)

grp2 = "=== Order Blocks ==="
showOB        = input.bool(true, "Mostrar Order Blocks",            group=grp2)
obLookback    = input.int(10,    "Lookback OB",     minval=3, maxval=50, group=grp2)
colBullOB     = input.color(color.new(#00e676, 85), "Color OB Alcista",    group=grp2)
colBearOB     = input.color(color.new(#ff1744, 85), "Color OB Bajista",    group=grp2)
extendOB      = input.int(30,    "Extender OB (barras)", minval=5, group=grp2)

grp3 = "=== SMT Divergencia ==="
showSMT       = input.bool(true,        "Mostrar SMT",               group=grp3)
smtSymbol     = input.symbol("SP:SPX", "Indice para SMT",           group=grp3)
smtLength     = input.int(5, "Swing Length SMT", minval=2, maxval=20, group=grp3)
colBullSMT    = input.color(color.new(#29b6f6, 0),  "Color SMT Alcista",   group=grp3)
colBearSMT    = input.color(color.new(#ff9800, 0),  "Color SMT Bajista",   group=grp3)

// ══════════════════════════════════════════════════════════
//  DATOS DEL INDICE (SMT)
// ══════════════════════════════════════════════════════════
[idxHigh, idxLow] = request.security(smtSymbol, timeframe.period, [high, low], lookahead=barmerge.lookahead_off)

// ══════════════════════════════════════════════════════════
//  DETECCION DE FVG
// ══════════════════════════════════════════════════════════
isBullFVG = low > high[2]
isBearFVG = high < low[2]

bullFVG_top = low 
bullFVG_bot = high[2]
bearFVG_top = low[2]
bearFVG_bot = high

var float[] bFVG_tops = array.new_float()
var float[] bFVG_bots = array.new_float()
var int[]   bFVG_bar  = array.new_int()

var float[] rFVG_tops = array.new_float()
var float[] rFVG_bots = array.new_float()
var int[]   rFVG_bar  = array.new_int()

MAX_FVG = 60

if isBullFVG
    array.push(bFVG_tops, bullFVG_top)
    array.push(bFVG_bots, bullFVG_bot)
    array.push(bFVG_bar,  bar_index - 1)
    if array.size(bFVG_tops) > MAX_FVG
        array.shift(bFVG_tops)
        array.shift(bFVG_bots)
        array.shift(bFVG_bar)

if isBearFVG
    array.push(rFVG_tops, bearFVG_top)
    array.push(rFVG_bots, bearFVG_bot)
    array.push(rFVG_bar,  bar_index - 1)
    if array.size(rFVG_tops) > MAX_FVG
        array.shift(rFVG_tops)
        array.shift(rFVG_bots)
        array.shift(rFVG_bar)

// ══════════════════════════════════════════════════════════
//  DETECCION DE INVERSE FVG (IFVG) CON VALIDACION DE ARRAYS
// ══════════════════════════════════════════════════════════
isIFVG_Bull = false
isIFVG_Bear = false

// Buscar IFVG alcista (dentro de FVG bajista previo)
if isBullFVG and array.size(rFVG_tops) > 0
    for i = 0 to array.size(rFVG_tops) - 1
        zTop = array.get(rFVG_tops, i)
        zBot = array.get(rFVG_bots, i)
        oldBar = array.get(rFVG_bar, i)
        if bullFVG_bot >= zBot and bullFVG_bot <= zTop and oldBar < bar_index - 2
            isIFVG_Bull := true
            break

// Buscar IFVG bajista (dentro de FVG alcista previo)
if isBearFVG and array.size(bFVG_tops) > 0
    for i = 0 to array.size(bFVG_tops) - 1
        zTop = array.get(bFVG_tops, i)
        zBot = array.get(bFVG_bots, i)
        oldBar = array.get(bFVG_bar, i)
        if bearFVG_top >= zBot and bearFVG_top <= zTop and oldBar < bar_index - 2
            isIFVG_Bear := true
            break

// ══════════════════════════════════════════════════════════
//  DETECCION DE ORDER BLOCKS (OB)
// ══════════════════════════════════════════════════════════
ph = ta.pivothigh(high, obLookback, obLookback)
pl = ta.pivotlow(low,   obLookback, obLookback)

var float obBull_H = na
var float obBull_L = na
var int   obBull_B = na
var float obBear_H = na
var float obBear_L = na
var int   obBear_B = na

if not na(pl)
    for k = 1 to obLookback
        if close[obLookback + k] < open[obLookback + k]
            obBull_H := high[obLookback + k]
            obBull_L := low[obLookback + k]
            obBull_B := bar_index - obLookback - k
            break

if not na(ph)
    for k = 1 to obLookback
        if close[obLookback + k] > open[obLookback + k]
            obBear_H := high[obLookback + k]
            obBear_L := low[obLookback + k]
            obBear_B := bar_index - obLookback - k
            break

if showOB and not na(pl) and not na(obBull_H)
    box.new(obBull_B, obBull_H, bar_index + extendOB, obBull_L, border_color=color.new(#00e676, 20), bgcolor=colBullOB, text="OB Compra", text_size=size.tiny)

if showOB and not na(ph) and not na(obBear_H)
    box.new(obBear_B, obBear_H, bar_index + extendOB, obBear_L, border_color=color.new(#ff1744, 20), bgcolor=colBearOB, text="OB Venta", text_size=size.tiny)

// ══════════════════════════════════════════════════════════
//  ALTA PROBABILIDAD Y ETIQUETAS
// ══════════════════════════════════════════════════════════
priceInBullOB = not na(obBull_H) and low <= obBull_H and high >= obBull_L
priceInBearOB = not na(obBear_H) and high >= obBear_L and low <= obBear_H

highProbBull = isIFVG_Bull and priceInBullOB
highProbBear = isIFVG_Bear and priceInBearOB

if showIFVG
    if isIFVG_Bull
        mostrar = showOnlyHP ? highProbBull : true
        if mostrar
            label.new(bar_index, low[1], highProbBull ? "IFVG Compra [HP]" : "IFVG Compra", style=label.style_label_up, color=colBullIFVG, textcolor=color.white)

    if isIFVG_Bear
        mostrar = showOnlyHP ? highProbBear : true
        if mostrar
            label.new(bar_index, high[1], highProbBear ? "IFVG Venta [HP]" : "IFVG Venta", style=label.style_label_down, color=colBearIFVG, textcolor=color.white)

// ══════════════════════════════════════════════════════════
//  SMT DIVERGENCIA (SIMPLE)
// ══════════════════════════════════════════════════════════
ph_I = ta.pivothigh(idxHigh, smtLength, smtLength)
pl_I = ta.pivotlow(idxLow,   smtLength, smtLength)

if showSMT and not na(ph_I)
    label.new(bar_index - smtLength, idxHigh[smtLength], "SMT " + smtSymbol, color=colBearSMT, textcolor=color.white, style=label.style_label_down)

if showSMT and not na(pl_I)
    label.new(bar_index - smtLength, idxLow[smtLength], "SMT " + smtSymbol, color=colBullSMT, textcolor=color.white, style=label.style_label_up)

// ══════════════════════════════════════════════════════════
//  ALERTAS
// ══════════════════════════════════════════════════════════
alertcondition(isIFVG_Bull, "IFVG Compra", "IFVG Alcista Detectado")
alertcondition(isIFVG_Bear, "IFVG Venta", "IFVG Bajista Detectado")
````
