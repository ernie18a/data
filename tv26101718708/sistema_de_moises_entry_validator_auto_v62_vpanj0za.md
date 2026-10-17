# Sistema de Moises - Entry Validator AUTO v6.2

- url: https://www.tradingview.com/script/VpAnj0ZA/
- type: indicator
- pine_id: PUB;ab847bdd62464d30ad2e12901e10310f
- version: 1.0

## Description

validador de entradas en base a la posicion del mercado en low timeframes

## Source Code

````pine
//@version=6
indicator("Sistema de Moises - Entry Validator AUTO v6.2", overlay=true, max_lines_count=20, max_labels_count=20, max_boxes_count=5)

// Entry Validator AUTO v6.2 — independiente, objetivo y bidireccional.
// No depende del CORE. Evalúa si el punto actual favorece compra, venta o espera.
// Sistema de Moisés — No operes el dibujo. Opera la intención.

// ─────────────────────────────────────────────────────────
// PALETA
// ─────────────────────────────────────────────────────────
C_BG      = color.rgb(7, 10, 18)
C_PANEL   = color.rgb(13, 18, 30)
C_ROW     = color.rgb(18, 24, 38)
C_DIV     = color.rgb(38, 48, 65)
C_TEXT    = color.rgb(232, 236, 245)
C_MUTED   = color.rgb(145, 153, 166)
C_GREEN   = color.rgb(0, 190, 115)
C_RED     = color.rgb(220, 60, 70)
C_AMBER   = color.rgb(255, 176, 0)
C_CYAN    = color.rgb(0, 190, 220)

// ─────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────
G0 = "00 — Visual"
i_pos      = input.string("Top Right", "Posición panel", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=G0)
i_size     = input.string("Grande", "Tamaño panel", options=["Normal", "Grande", "XL"], group=G0)
i_showEMA  = input.bool(false, "Mostrar EMA", group=G0)
i_marks    = input.bool(false, "Mostrar marca mínima", group=G0)

G1 = "01 — Motor autónomo"
i_mode     = input.string("Balanceada", "Modo de entrada", options=["Agresiva", "Balanceada", "Conservadora"], group=G1)
i_edge     = input.int(2, "Ventaja mínima compra/venta", minval=0, maxval=10, group=G1)
i_minScore = input.int(7, "Score mínimo para validar", minval=4, maxval=14, group=G1)

G2 = "02 — Estructura"
i_emaFast  = input.int(50, "EMA rápida", minval=1, group=G2)
i_emaSlow  = input.int(200, "EMA lenta", minval=1, group=G2)
i_pivotLen = input.int(5, "Sensibilidad pivots", minval=2, maxval=20, group=G2)
i_rangeLen = input.int(120, "Rango premium/descuento", minval=40, group=G2)

G3 = "03 — Confirmación LTF"
i_atrLen   = input.int(14, "ATR", minval=1, group=G3)
i_impATR   = input.float(1.05, "Impulso mínimo × ATR", minval=0.3, step=0.05, group=G3)
i_bodyPct  = input.float(0.55, "Cuerpo mínimo", minval=0.1, maxval=0.95, step=0.05, group=G3)
i_mem      = input.int(12, "Memoria confirmación", minval=3, maxval=80, group=G3)

G4 = "04 — Riesgo"
i_rrMin       = input.float(2.0, "RR mínimo", minval=0.5, step=0.25, group=G4)
i_targetMode  = input.string("Swing", "Objetivo", options=["Swing", "ATR"], group=G4)
i_targetATR   = input.float(2.0, "Objetivo ATR", minval=0.5, step=0.25, group=G4)
i_slBufferATR = input.float(0.15, "Buffer SL × ATR", minval=0.0, step=0.05, group=G4)

// ─────────────────────────────────────────────────────────
// FUNCIONES
// ─────────────────────────────────────────────────────────
f_pos(_p) =>
    _p == "Top Left" ? position.top_left : _p == "Bottom Right" ? position.bottom_right : _p == "Bottom Left" ? position.bottom_left : position.top_right

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

f_grade(_s) =>
    _s >= 11 ? "A+" : _s >= 9 ? "A" : _s >= 7 ? "B" : _s >= 5 ? "C" : "DESCARTAR"

f_col(_txt) =>
    _txt == "A+" or _txt == "A" ? C_GREEN : _txt == "B" ? C_AMBER : C_RED

f_round2(_v) =>
    na(_v) ? "N/A" : str.tostring(math.round(_v * 100.0) / 100.0)

// ─────────────────────────────────────────────────────────
// BASE
// ─────────────────────────────────────────────────────────
emaFast = ta.ema(close, i_emaFast)
emaSlow = ta.ema(close, i_emaSlow)
atr     = ta.atr(i_atrLen)

plot(i_showEMA ? emaFast : na, "EMA rápida", color=color.new(C_CYAN, 0), linewidth=1)
plot(i_showEMA ? emaSlow : na, "EMA lenta", color=color.new(C_MUTED, 25), linewidth=1)

// ─────────────────────────────────────────────────────────
// PIVOTS / LIQUIDEZ
// ─────────────────────────────────────────────────────────
ph = ta.pivothigh(high, i_pivotLen, i_pivotLen)
pl = ta.pivotlow(low, i_pivotLen, i_pivotLen)

var float lastPH = na
var float lastPL = na
var float prevPH = na
var float prevPL = na

if not na(ph)
    prevPH := lastPH
    lastPH := ph
if not na(pl)
    prevPL := lastPL
    lastPL := pl

sweepHigh = not na(lastPH) and high > lastPH and close < lastPH
sweepLow  = not na(lastPL) and low < lastPL and close > lastPL
recentSweepHigh = f_recent(sweepHigh, i_mem)
recentSweepLow  = f_recent(sweepLow, i_mem)

upperTarget = not na(lastPH) and lastPH > close
lowerTarget = not na(lastPL) and lastPL < close

// ─────────────────────────────────────────────────────────
// UBICACIÓN OBJETIVA
// ─────────────────────────────────────────────────────────
rHigh = ta.highest(high, i_rangeLen)
rLow  = ta.lowest(low, i_rangeLen)
span  = math.max(rHigh - rLow, syminfo.mintick)
posPct = (close - rLow) / span * 100

inDiscount    = posPct <= 45
deepDiscount  = posPct <= 30
inPremium     = posPct >= 55
deepPremium   = posPct >= 70
inMid         = not inDiscount and not inPremium

// FVG simple con memoria
bullFVG = low > high[2] and (low - high[2]) > atr * 0.10
bearFVG = high < low[2] and (low[2] - high) > atr * 0.10
recentBullFVG = f_recent(bullFVG, i_mem)
recentBearFVG = f_recent(bearFVG, i_mem)

// Impulso / cuerpo
rng = math.max(high - low, syminfo.mintick)
body = math.abs(close - open)
bodyRatio = body / rng
bodyOk = bodyRatio >= i_bodyPct

bullImpulse = close > open and bodyOk and rng >= atr * i_impATR and close > high[1]
bearImpulse = close < open and bodyOk and rng >= atr * i_impATR and close < low[1]
recentBullImpulse = f_recent(bullImpulse, i_mem)
recentBearImpulse = f_recent(bearImpulse, i_mem)

// OB simple: última vela contraria previa a impulso
var float bullOBHigh = na
var float bullOBLow = na
var float bearOBHigh = na
var float bearOBLow = na

if bullImpulse and close[1] < open[1]
    bullOBHigh := high[1]
    bullOBLow := low[1]
if bearImpulse and close[1] > open[1]
    bearOBHigh := high[1]
    bearOBLow := low[1]

inBullOB = not na(bullOBLow) and close > bullOBLow and low <= bullOBHigh
inBearOB = not na(bearOBHigh) and close < bearOBHigh and high >= bearOBLow

// ─────────────────────────────────────────────────────────
// CARÁCTER LTF: ALCISTA / BAJISTA
// ─────────────────────────────────────────────────────────
bosBull = not na(lastPH) and close > lastPH
bosBear = not na(lastPL) and close < lastPL
recentBosBull = f_recent(bosBull, i_mem)
recentBosBear = f_recent(bosBear, i_mem)

emaBull = close > emaFast and emaFast > emaSlow
emaBear = close < emaFast and emaFast < emaSlow

bullCharacter = recentBosBull or recentBullImpulse or emaBull
bearCharacter = recentBosBear or recentBearImpulse or emaBear

characterText = bullCharacter and not bearCharacter ? "ALCISTA" : bearCharacter and not bullCharacter ? "BAJISTA" : bullCharacter and bearCharacter ? "MIXTO" : "NEUTRO"
characterColor = characterText == "ALCISTA" ? C_GREEN : characterText == "BAJISTA" ? C_RED : C_AMBER

// ─────────────────────────────────────────────────────────
// SL / TP / RR PARA AMBOS LADOS
// ─────────────────────────────────────────────────────────
slLong = not na(lastPL) ? lastPL - atr * i_slBufferATR : low - atr * i_slBufferATR
slShort = not na(lastPH) ? lastPH + atr * i_slBufferATR : high + atr * i_slBufferATR

riskLong = close - slLong
riskShort = slShort - close

targetLongSwing = not na(lastPH) and lastPH > close ? lastPH : close + atr * i_targetATR
targetShortSwing = not na(lastPL) and lastPL < close ? lastPL : close - atr * i_targetATR

tpLong = i_targetMode == "Swing" ? targetLongSwing : close + atr * i_targetATR
tpShort = i_targetMode == "Swing" ? targetShortSwing : close - atr * i_targetATR

rewardLong = tpLong - close
rewardShort = close - tpShort

rrLong = riskLong > syminfo.mintick ? rewardLong / riskLong : na
rrShort = riskShort > syminfo.mintick ? rewardShort / riskShort : na
rrLongPass = not na(rrLong) and rrLong >= i_rrMin
rrShortPass = not na(rrShort) and rrShort >= i_rrMin

// ─────────────────────────────────────────────────────────
// SCORE OBJETIVO DE PUNTO DE ENTRADA — COMPRA / VENTA
// ─────────────────────────────────────────────────────────
longLocationPts = deepDiscount ? 3 : inDiscount ? 2 : inMid and emaBull ? 1 : 0
longPoiPts = inBullOB ? 2 : recentBullFVG ? 1 : 0
longSweepPts = recentSweepLow ? 2 : 0
longCharPts = recentBosBull ? 2 : recentBullImpulse ? 1 : emaBull ? 1 : 0
longRRPts = rrLongPass ? 2 : not na(rrLong) and rrLong >= 1.5 ? 1 : 0
longTargetPts = upperTarget ? 1 : 0
longScore = longLocationPts + longPoiPts + longSweepPts + longCharPts + longRRPts + longTargetPts

shortLocationPts = deepPremium ? 3 : inPremium ? 2 : inMid and emaBear ? 1 : 0
shortPoiPts = inBearOB ? 2 : recentBearFVG ? 1 : 0
shortSweepPts = recentSweepHigh ? 2 : 0
shortCharPts = recentBosBear ? 2 : recentBearImpulse ? 1 : emaBear ? 1 : 0
shortRRPts = rrShortPass ? 2 : not na(rrShort) and rrShort >= 1.5 ? 1 : 0
shortTargetPts = lowerTarget ? 1 : 0
shortScore = shortLocationPts + shortPoiPts + shortSweepPts + shortCharPts + shortRRPts + shortTargetPts

scoreDiff = math.abs(longScore - shortScore)
canChooseSide = scoreDiff >= i_edge
preferLong = longScore > shortScore and canChooseSide
preferShort = shortScore > longScore and canChooseSide
sideText = preferLong ? "COMPRA" : preferShort ? "VENTA" : "ESPERAR"
sideColor = preferLong ? C_GREEN : preferShort ? C_RED : C_AMBER

bestScore = preferLong ? longScore : preferShort ? shortScore : math.max(longScore, shortScore)
bestRR = preferLong ? rrLong : preferShort ? rrShort : na
bestSL = preferLong ? slLong : preferShort ? slShort : na
bestTP = preferLong ? tpLong : preferShort ? tpShort : na
bestRisk = preferLong ? riskLong : preferShort ? riskShort : na

// ─────────────────────────────────────────────────────────
// GRADOS POR BLOQUE
// ─────────────────────────────────────────────────────────
locGradeLong = (longLocationPts + longPoiPts + longSweepPts) >= 5 ? "EXCELENTE" : (longLocationPts + longPoiPts + longSweepPts) >= 3 ? "CORRECTA" : "DÉBIL"
locGradeShort = (shortLocationPts + shortPoiPts + shortSweepPts) >= 5 ? "EXCELENTE" : (shortLocationPts + shortPoiPts + shortSweepPts) >= 3 ? "CORRECTA" : "DÉBIL"
locationGrade = preferLong ? locGradeLong : preferShort ? locGradeShort : "NEUTRAL"
locationColor = locationGrade == "EXCELENTE" ? C_GREEN : locationGrade == "CORRECTA" ? C_AMBER : C_RED

confirmGradeLong = recentBosBull and recentBullImpulse ? "FUERTE" : recentBosBull or recentBullImpulse ? "PRESENTE" : "AUSENTE"
confirmGradeShort = recentBosBear and recentBearImpulse ? "FUERTE" : recentBosBear or recentBearImpulse ? "PRESENTE" : "AUSENTE"
confirmGrade = preferLong ? confirmGradeLong : preferShort ? confirmGradeShort : "AUSENTE"
confirmColor = confirmGrade == "FUERTE" ? C_GREEN : confirmGrade == "PRESENTE" ? C_AMBER : C_RED

rrText = f_round2(bestRR)
slText = na(bestSL) ? "N/A" : str.tostring(math.round(bestSL * 1000.0) / 1000.0)
tpText = na(bestTP) ? "N/A" : str.tostring(math.round(bestTP * 1000.0) / 1000.0)
rrPass = not na(bestRR) and bestRR >= i_rrMin and bestRisk > syminfo.mintick
rrColor = rrPass ? C_GREEN : C_RED

// Reglas por modo
hasLocation = preferLong ? (locGradeLong != "DÉBIL") : preferShort ? (locGradeShort != "DÉBIL") : false
hasChar = preferLong ? bullCharacter : preferShort ? bearCharacter : false
hasConfirm = preferLong ? (confirmGradeLong != "AUSENTE") : preferShort ? (confirmGradeShort != "AUSENTE") : false
hasStrongConfirm = preferLong ? (confirmGradeLong == "FUERTE") : preferShort ? (confirmGradeShort == "FUERTE") : false

modePass = i_mode == "Agresiva" ? (hasLocation and hasChar) : i_mode == "Balanceada" ? (hasLocation and hasConfirm) : (hasLocation and hasStrongConfirm and rrPass)
validEntry = (preferLong or preferShort) and bestScore >= i_minScore and modePass and rrPass

qualityText = not (preferLong or preferShort) ? "DESCARTAR" : validEntry ? f_grade(bestScore) : bestScore >= i_minScore ? "B" : "DESCARTAR"
qualityColor = f_col(qualityText)
decisionText = validEntry ? "RIESGO PERMITIDO" : sideText == "ESPERAR" ? "ESPERAR" : "NO EJECUTAR"
decisionColor = validEntry ? C_GREEN : C_RED

whyText = preferLong ? (recentSweepLow ? "Sweep low + punto comprador" : inDiscount ? "Descuento comprador" : inBullOB ? "OB comprador" : "Carácter comprador") : preferShort ? (recentSweepHigh ? "Sweep high + punto vendedor" : inPremium ? "Premium vendedor" : inBearOB ? "OB vendedor" : "Carácter vendedor") : "Sin ventaja direccional suficiente"

locNote = preferLong ? (deepDiscount ? "Descuento profundo" : inDiscount ? "Descuento" : inBullOB ? "Dentro OB alcista" : recentBullFVG ? "FVG alcista activo" : inMid ? "Equilibrio" : "Premium") : preferShort ? (deepPremium ? "Premium profundo" : inPremium ? "Premium" : inBearOB ? "Dentro OB bajista" : recentBearFVG ? "FVG bajista activo" : inMid ? "Equilibrio" : "Descuento") : "No definido"

// ─────────────────────────────────────────────────────────
// PANEL
// ─────────────────────────────────────────────────────────
var table dash = table.new(f_pos(i_pos), 2, 15, frame_width=1, frame_color=C_DIV, border_width=1, border_color=C_DIV)

if barstate.islast
    table.cell(dash, 0, 0, "  SISTEMA DE MOISÉS", text_color=C_CYAN, bgcolor=C_BG, text_size=f_head(), text_halign=text.align_left)
    table.cell(dash, 1, 0, "ENTRY AUTO v6.2  ", text_color=C_MUTED, bgcolor=C_BG, text_size=f_txt(), text_halign=text.align_right)

    table.cell(dash, 0, 1, "  PUNTO ACTUAL", text_color=C_TEXT, bgcolor=C_PANEL, text_size=f_head(), text_halign=text.align_left)
    table.cell(dash, 1, 1, sideText + "  ", text_color=sideColor, bgcolor=C_PANEL, text_size=f_head(), text_halign=text.align_right)

    f_cell(dash, 0, 2, "  Calidad", C_TEXT, C_ROW, text.align_left)
    f_cell(dash, 1, 2, qualityText + "  ", qualityColor, C_ROW, text.align_right)

    f_cell(dash, 0, 3, "  Decisión", C_TEXT, C_PANEL, text.align_left)
    f_cell(dash, 1, 3, decisionText + "  ", decisionColor, C_PANEL, text.align_right)

    table.cell(dash, 0, 4, "  ─────────────────", text_color=C_DIV, bgcolor=C_BG, text_size=f_txt(), text_halign=text.align_left)
    table.cell(dash, 1, 4, "", bgcolor=C_BG)

    f_cell(dash, 0, 5, "  1. Ubicación", C_TEXT, C_ROW, text.align_left)
    f_cell(dash, 1, 5, locationGrade + " | " + locNote + "  ", locationColor, C_ROW, text.align_right)

    f_cell(dash, 0, 6, "  2. Carácter LTF", C_TEXT, C_PANEL, text.align_left)
    f_cell(dash, 1, 6, characterText + "  ", characterColor, C_PANEL, text.align_right)

    f_cell(dash, 0, 7, "  3. Confirmación", C_TEXT, C_ROW, text.align_left)
    f_cell(dash, 1, 7, confirmGrade + "  ", confirmColor, C_ROW, text.align_right)

    f_cell(dash, 0, 8, "  4. RR", C_TEXT, C_PANEL, text.align_left)
    f_cell(dash, 1, 8, rrText + "  ", rrColor, C_PANEL, text.align_right)

    table.cell(dash, 0, 9, "  ─────────────────", text_color=C_DIV, bgcolor=C_BG, text_size=f_txt(), text_halign=text.align_left)
    table.cell(dash, 1, 9, "", bgcolor=C_BG)

    f_cell(dash, 0, 10, "  SL lógico", C_MUTED, C_ROW, text.align_left)
    f_cell(dash, 1, 10, slText + "  ", C_MUTED, C_ROW, text.align_right)

    f_cell(dash, 0, 11, "  TP estimado", C_MUTED, C_PANEL, text.align_left)
    f_cell(dash, 1, 11, tpText + "  ", C_MUTED, C_PANEL, text.align_right)

    f_cell(dash, 0, 12, "  Lectura", C_TEXT, C_ROW, text.align_left)
    f_cell(dash, 1, 12, whyText + "  ", C_TEXT, C_ROW, text.align_right)

    f_cell(dash, 0, 13, "  Score C/V", C_MUTED, C_PANEL, text.align_left)
    f_cell(dash, 1, 13, str.tostring(longScore) + " / " + str.tostring(shortScore) + "  ", C_MUTED, C_PANEL, text.align_right)

    f_cell(dash, 0, 14, "  Regla", C_AMBER, C_BG, text.align_left)
    f_cell(dash, 1, 14, "No operes el dibujo. Opera la intención.  ", C_AMBER, C_BG, text.align_right)

// ─────────────────────────────────────────────────────────
// VISUAL MÍNIMO
// ─────────────────────────────────────────────────────────
plotshape(i_marks and validEntry and preferLong, title="Entrada válida compra", style=shape.triangleup, location=location.belowbar, size=size.tiny, color=color.new(C_GREEN, 0), text="")
plotshape(i_marks and validEntry and preferShort, title="Entrada válida venta", style=shape.triangledown, location=location.abovebar, size=size.tiny, color=color.new(C_RED, 0), text="")
````
