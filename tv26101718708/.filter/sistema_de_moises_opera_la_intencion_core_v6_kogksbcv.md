# Sistema de Moises - Opera la Intencion CORE v6

- url: https://www.tradingview.com/script/KOGksBCV/
- type: indicator
- pine_id: PUB;ccc702d1b0b74f8bb304c98f8f437e90
- version: 1.0

## Description

basicamente es un filtro de contexto donde le permite al trader entender donde esta el mercado actualmente

## Source Code

````pine
//@version=6
indicator("Sistema de Moises - Opera la Intencion CORE v6", overlay=true, max_lines_count=20, max_labels_count=20, max_boxes_count=5)

// Opera la Intención CORE v6 — lectura simple de contexto, liquidez, desplazamiento y sesgo.
// No genera entradas. Ayuda a leer qué es más probable encontrar: compras o ventas.

// ─────────────────────────────────────────────────────────
// PALETA
// ─────────────────────────────────────────────────────────
C_BG     = color.rgb(7, 10, 18)
C_PANEL  = color.rgb(13, 18, 30)
C_ROW    = color.rgb(18, 24, 38)
C_DIV    = color.rgb(38, 48, 65)
C_TEXT   = color.rgb(232, 236, 245)
C_MUTED  = color.rgb(145, 153, 166)
C_GREEN  = color.rgb(0, 190, 115)
C_RED    = color.rgb(220, 60, 70)
C_AMBER  = color.rgb(255, 176, 0)
C_CYAN   = color.rgb(0, 190, 220)

// ─────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────
G0 = "00 — Visual"
i_pos     = input.string("Top Right", "Posición panel", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=G0)
i_size    = input.string("Grande", "Tamaño", options=["Normal", "Grande", "XL"], group=G0)
i_showEMA = input.bool(false, "Mostrar EMA local", group=G0)
i_showPD  = input.bool(false, "Mostrar PDH/PDL", group=G0)

G1 = "01 — Contexto"
i_tfHTF    = input.timeframe("60", "HTF principal", group=G1)
i_tfMacro  = input.timeframe("240", "HTF macro", group=G1)
i_emaFast  = input.int(50, "EMA rápida", minval=1, group=G1)
i_emaSlow  = input.int(200, "EMA lenta", minval=1, group=G1)
i_rangeLen = input.int(120, "Rango premium/descuento", minval=40, group=G1)

G2 = "02 — Liquidez"
i_pivotLen = input.int(5, "Sensibilidad swings", minval=2, maxval=20, group=G2)
i_sweepMem = input.int(30, "Memoria sweep", minval=3, maxval=100, group=G2)
i_nearATR  = input.float(0.85, "Cercanía liquidez en ATR", minval=0.1, step=0.05, group=G2)

G3 = "03 — Desplazamiento"
i_atrLen   = input.int(14, "ATR", minval=1, group=G3)
i_impATR   = input.float(1.05, "Impulso mínimo × ATR", minval=0.3, step=0.05, group=G3)
i_bodyPct  = input.float(0.55, "Cuerpo mínimo", minval=0.1, maxval=0.95, step=0.05, group=G3)
i_dispMem  = input.int(18, "Memoria intención", minval=3, maxval=80, group=G3)

G4 = "04 — Sesiones"
i_london = input.session("0300-0600", "London KZ", group=G4)
i_ny     = input.session("0800-1100", "New York KZ", group=G4)
i_asia   = input.session("2000-2300", "Asia", group=G4)
i_nypm   = input.session("1300-1500", "NY Cierre", group=G4)

// ─────────────────────────────────────────────────────────
// FUNCIONES
// ─────────────────────────────────────────────────────────
f_pos(_p) =>
    _p == "Top Left" ? position.top_left :
     _p == "Bottom Right" ? position.bottom_right :
     _p == "Bottom Left" ? position.bottom_left :
     position.top_right

f_txt() =>
    i_size == "XL" ? size.normal : i_size == "Grande" ? size.small : size.tiny

f_head() =>
    i_size == "XL" ? size.large : i_size == "Grande" ? size.normal : size.small

f_bars(_cond) =>
    _bs = ta.barssince(_cond)
    na(_bs) ? 100000 : _bs

f_recent(_cond, _bars) =>
    f_bars(_cond) <= _bars

f_cell(_t, _c, _r, _txt, _tc, _bg, _align) =>
    table.cell(_t, _c, _r, _txt, text_color=_tc, bgcolor=_bg, text_size=f_txt(), text_halign=_align)

// ─────────────────────────────────────────────────────────
// BASE
// ─────────────────────────────────────────────────────────
emaFast = ta.ema(close, i_emaFast)
emaSlow = ta.ema(close, i_emaSlow)
atr     = ta.atr(i_atrLen)

plot(i_showEMA ? emaFast : na, "EMA rápida", color=color.new(C_CYAN, 0))
plot(i_showEMA ? emaSlow : na, "EMA lenta", color=color.new(C_MUTED, 25))

// ─────────────────────────────────────────────────────────
// 1. CONTEXTO
// ─────────────────────────────────────────────────────────
[htfClose, htfFast, htfSlow, htfFastPrev, htfAtr] = request.security(syminfo.tickerid, i_tfHTF, [close, ta.ema(close, i_emaFast), ta.ema(close, i_emaSlow), ta.ema(close, i_emaFast)[5], ta.atr(i_atrLen)])
[macroClose, macroFast, macroSlow] = request.security(syminfo.tickerid, i_tfMacro, [close, ta.ema(close, i_emaFast), ta.ema(close, i_emaSlow)])

htfBull   = htfClose > htfFast and htfFast > htfSlow
htfBear   = htfClose < htfFast and htfFast < htfSlow
macroBull = macroClose > macroFast and macroFast > macroSlow
macroBear = macroClose < macroFast and macroFast < macroSlow
htfSlope  = (htfFast - htfFastPrev) / math.max(htfAtr, syminfo.mintick)
htfRange  = math.abs(htfSlope) < 0.18

contextText = htfBull and macroBull ? "ALCISTA HTF/MACRO" : htfBear and macroBear ? "BAJISTA HTF/MACRO" : htfBull ? "ALCISTA HTF" : htfBear ? "BAJISTA HTF" : htfRange ? "RANGO / EQUILIBRIO" : "MIXTO"
contextColor = htfBull ? C_GREEN : htfBear ? C_RED : C_AMBER

// ─────────────────────────────────────────────────────────
// 2. LIQUIDEZ
// ─────────────────────────────────────────────────────────
ph = ta.pivothigh(high, i_pivotLen, i_pivotLen)
pl = ta.pivotlow(low, i_pivotLen, i_pivotLen)

var float lastPH = na
var float lastPL = na
if not na(ph)
    lastPH := ph
if not na(pl)
    lastPL := pl

[pdh, pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]])
[pwh, pwl] = request.security(syminfo.tickerid, "W", [high[1], low[1]])

plot(i_showPD ? pdh : na, "PDH", color=color.new(C_RED, 75), style=plot.style_linebr)
plot(i_showPD ? pdl : na, "PDL", color=color.new(C_GREEN, 75), style=plot.style_linebr)

sweepHighPivot = not na(lastPH) and high > lastPH and close < lastPH
sweepLowPivot  = not na(lastPL) and low < lastPL and close > lastPL
sweepHighPD    = high > pdh and close < pdh
sweepLowPD     = low < pdl and close > pdl
sweepHighPW    = high > pwh and close < pwh
sweepLowPW     = low < pwl and close > pwl

sweepHigh = sweepHighPivot or sweepHighPD or sweepHighPW
sweepLow  = sweepLowPivot or sweepLowPD or sweepLowPW
recentSweepHigh = f_recent(sweepHigh, i_sweepMem)
recentSweepLow  = f_recent(sweepLow, i_sweepMem)

upperTarget = (not na(lastPH) and close < lastPH) or close < pdh or close < pwh
lowerTarget = (not na(lastPL) and close > lastPL) or close > pdl or close > pwl
nearUpper   = (not na(lastPH) and math.abs(close - lastPH) <= atr * i_nearATR) or math.abs(close - pdh) <= atr * i_nearATR or math.abs(close - pwh) <= atr * i_nearATR
nearLower   = (not na(lastPL) and math.abs(close - lastPL) <= atr * i_nearATR) or math.abs(close - pdl) <= atr * i_nearATR or math.abs(close - pwl) <= atr * i_nearATR

liqTakenText = recentSweepLow ? "SWEEP LOW reciente" : recentSweepHigh ? "SWEEP HIGH reciente" : "Sin sweep reciente"
liqTargetText = upperTarget and not lowerTarget ? "Liquidez superior" : lowerTarget and not upperTarget ? "Liquidez inferior" : upperTarget and lowerTarget ? "Ambos lados vivos" : "Sin objetivo claro"
liqColor = recentSweepLow ? C_GREEN : recentSweepHigh ? C_RED : C_AMBER

// ─────────────────────────────────────────────────────────
// 3. DESPLAZAMIENTO
// ─────────────────────────────────────────────────────────
rng = math.max(high - low, syminfo.mintick)
body = math.abs(close - open)
bodyRatio = body / rng
bodyOk = bodyRatio >= i_bodyPct

bullImpulse = close > open and bodyOk and rng >= atr * i_impATR and close > high[1]
bearImpulse = close < open and bodyOk and rng >= atr * i_impATR and close < low[1]
bosBull = not na(lastPH) and close > lastPH
bosBear = not na(lastPL) and close < lastPL

bullIntent = bullImpulse or bosBull
bearIntent = bearImpulse or bosBear
recentBullIntent = f_recent(bullIntent, i_dispMem)
recentBearIntent = f_recent(bearIntent, i_dispMem)

bullAfterSweep = recentSweepLow and recentBullIntent and f_bars(bullIntent) < f_bars(sweepLow)
bearAfterSweep = recentSweepHigh and recentBearIntent and f_bars(bearIntent) < f_bars(sweepHigh)

dispText = bullAfterSweep ? "ALCISTA post-sweep" : bearAfterSweep ? "BAJISTA post-sweep" : recentBullIntent and not recentBearIntent ? "ALCISTA" : recentBearIntent and not recentBullIntent ? "BAJISTA" : recentBullIntent and recentBearIntent ? "MIXTO" : "Sin intención clara"
dispColor = str.contains(dispText, "ALCISTA") ? C_GREEN : str.contains(dispText, "BAJISTA") ? C_RED : C_AMBER

// ─────────────────────────────────────────────────────────
// 4. UBICACIÓN
// ─────────────────────────────────────────────────────────
rHigh = ta.highest(high, i_rangeLen)
rLow = ta.lowest(low, i_rangeLen)
rangeSpan = math.max(rHigh - rLow, syminfo.mintick)
posPct = (close - rLow) / rangeSpan * 100
inDiscount = posPct <= 45
inPremium = posPct >= 55
inMid = not inDiscount and not inPremium
locText = inDiscount ? "DESCUENTO" : inPremium ? "PREMIUM" : "EQUILIBRIO"
locColor = inDiscount ? C_GREEN : inPremium ? C_RED : C_AMBER

// ─────────────────────────────────────────────────────────
// 5. SESIÓN
// ─────────────────────────────────────────────────────────
inAsia = not na(time(timeframe.period, i_asia))
inLondon = not na(time(timeframe.period, i_london))
inNY = not na(time(timeframe.period, i_ny))
inNYpm = not na(time(timeframe.period, i_nypm))
sessionText = inNY ? "NEW YORK" : inLondon ? "LONDON" : inAsia ? "ASIA" : inNYpm ? "NY CIERRE" : "FUERA KZ"
sessionColor = (inNY or inLondon) ? C_GREEN : (inAsia or inNYpm) ? C_CYAN : C_MUTED

// ─────────────────────────────────────────────────────────
// 6. SESGO PROBABLE SIMPLE
// ─────────────────────────────────────────────────────────
longScore = 0
shortScore = 0

longScore += htfBull ? 2 : 0
longScore += macroBull ? 1 : 0
longScore += recentSweepLow ? 3 : 0
longScore += upperTarget ? 2 : 0
longScore += bullAfterSweep ? 3 : recentBullIntent ? 2 : 0
longScore += inDiscount ? 2 : inMid and htfBull ? 1 : 0
longScore += nearLower ? 1 : 0

shortScore += htfBear ? 2 : 0
shortScore += macroBear ? 1 : 0
shortScore += recentSweepHigh ? 3 : 0
shortScore += lowerTarget ? 2 : 0
shortScore += bearAfterSweep ? 3 : recentBearIntent ? 2 : 0
shortScore += inPremium ? 2 : inMid and htfBear ? 1 : 0
shortScore += nearUpper ? 1 : 0

preferLong = longScore > shortScore
scoreDiff = math.abs(longScore - shortScore)
biasText = scoreDiff <= 1 ? "MIXTO" : preferLong ? "COMPRAS" : "VENTAS"
biasColor = biasText == "COMPRAS" ? C_GREEN : biasText == "VENTAS" ? C_RED : C_AMBER
confidenceText = scoreDiff >= 5 ? "ALTA" : scoreDiff >= 3 ? "MEDIA" : "BAJA"
confidenceColor = confidenceText == "ALTA" ? C_GREEN : confidenceText == "MEDIA" ? C_AMBER : C_MUTED

whyText = biasText == "COMPRAS" ? (recentSweepLow ? "Tomó lows; buscar confirmación alcista" : upperTarget ? "Liquidez arriba pendiente" : "Contexto favorece compras") : biasText == "VENTAS" ? (recentSweepHigh ? "Tomó highs; buscar confirmación bajista" : lowerTarget ? "Liquidez abajo pendiente" : "Contexto favorece ventas") : "Esperar que el mercado revele intención"
lookForText = biasText == "COMPRAS" ? "Confirmación alcista M1/M5" : biasText == "VENTAS" ? "Confirmación bajista M1/M5" : "No forzar tesis"
objectiveText = biasText == "COMPRAS" ? "Objetivo: liquidez superior" : biasText == "VENTAS" ? "Objetivo: liquidez inferior" : "Objetivo: indefinido"

// ─────────────────────────────────────────────────────────
// PANEL
// ─────────────────────────────────────────────────────────
var table dash = table.new(f_pos(i_pos), 2, 14, frame_width=1, frame_color=C_DIV, border_width=1, border_color=C_DIV)

if barstate.islast
    table.cell(dash, 0, 0, "  SISTEMA DE MOISÉS", text_color=C_CYAN, bgcolor=C_BG, text_size=f_head(), text_halign=text.align_left)
    table.cell(dash, 1, 0, "CORE v6  ", text_color=C_MUTED, bgcolor=C_BG, text_size=f_txt(), text_halign=text.align_right)

    table.cell(dash, 0, 1, "  SESGO PROBABLE", text_color=C_TEXT, bgcolor=C_PANEL, text_size=f_head(), text_halign=text.align_left)
    table.cell(dash, 1, 1, biasText + "  ", text_color=biasColor, bgcolor=C_PANEL, text_size=f_head(), text_halign=text.align_right)

    f_cell(dash, 0, 2, "  Confianza", C_MUTED, C_ROW, text.align_left)
    f_cell(dash, 1, 2, confidenceText + "  ", confidenceColor, C_ROW, text.align_right)

    table.cell(dash, 0, 3, "  ─────────────────", text_color=C_DIV, bgcolor=C_BG, text_size=f_txt(), text_halign=text.align_left)
    table.cell(dash, 1, 3, "", bgcolor=C_BG)

    f_cell(dash, 0, 4, "  1. Contexto", C_TEXT, C_ROW, text.align_left)
    f_cell(dash, 1, 4, contextText + "  ", contextColor, C_ROW, text.align_right)

    f_cell(dash, 0, 5, "  2. Liquidez tomada", C_TEXT, C_PANEL, text.align_left)
    f_cell(dash, 1, 5, liqTakenText + "  ", liqColor, C_PANEL, text.align_right)

    f_cell(dash, 0, 6, "  3. Liquidez probable", C_TEXT, C_ROW, text.align_left)
    f_cell(dash, 1, 6, liqTargetText + "  ", C_AMBER, C_ROW, text.align_right)

    f_cell(dash, 0, 7, "  4. Desplazamiento", C_TEXT, C_PANEL, text.align_left)
    f_cell(dash, 1, 7, dispText + "  ", dispColor, C_PANEL, text.align_right)

    f_cell(dash, 0, 8, "  5. Ubicación", C_TEXT, C_ROW, text.align_left)
    f_cell(dash, 1, 8, locText + " " + str.tostring(math.round(posPct)) + "%  ", locColor, C_ROW, text.align_right)

    f_cell(dash, 0, 9, "  Sesión", C_MUTED, C_PANEL, text.align_left)
    f_cell(dash, 1, 9, sessionText + "  ", sessionColor, C_PANEL, text.align_right)

    table.cell(dash, 0, 10, "  ─────────────────", text_color=C_DIV, bgcolor=C_BG, text_size=f_txt(), text_halign=text.align_left)
    table.cell(dash, 1, 10, "", bgcolor=C_BG)

    f_cell(dash, 0, 11, "  Lectura", C_TEXT, C_ROW, text.align_left)
    f_cell(dash, 1, 11, whyText + "  ", C_TEXT, C_ROW, text.align_right)

    f_cell(dash, 0, 12, "  Qué buscar", C_TEXT, C_PANEL, text.align_left)
    f_cell(dash, 1, 12, lookForText + "  ", C_AMBER, C_PANEL, text.align_right)

    f_cell(dash, 0, 13, "  Regla", C_AMBER, C_BG, text.align_left)
    f_cell(dash, 1, 13, "No operes el dibujo. Opera la intención.  ", C_AMBER, C_BG, text.align_right)
````
