<!-- tradingview-pine-id: PUB;144377200f3f4e5085e181d56c95ed87 -->
<!-- tradingviewscripts-format: 1 -->
# EMAs (9-15-30-65-200) + ATR + PDH/PDL/PWH/PWL + Pivots D/W/M

Source: https://www.tradingview.com/script/hxEuQKNZ/

## Description

EMAs (9-15-30-65-200) + ATR + PDH/PDL/PWH/PWL + Pivots D/W/M

---

## Source Code

````pine
//@version=6
indicator("EMAs (9-15-30-65-200) + ATR + PDH/PDL/PWH/PWL + Pivots D/W/M", shorttitle="EMA-ATR-PIVOTS", overlay=true, max_lines_count=500, max_labels_count=500)

// =========================================================================
// EMAs
// =========================================================================
gEMA = "EMAs"
showEMAs  = input.bool(true, "Mostrar EMAs", group=gEMA)
ema1Len   = input.int(9,   "EMA 1", group=gEMA, inline="e1")
ema1Col   = input.color(color.yellow, "Color", group=gEMA, inline="e1")
ema2Len   = input.int(15,  "EMA 2", group=gEMA, inline="e2")
ema2Col   = input.color(color.green,  "Color", group=gEMA, inline="e2")
ema3Len   = input.int(30,  "EMA 3", group=gEMA, inline="e3")
ema3Col   = input.color(color.aqua,   "Color", group=gEMA, inline="e3")
ema4Len   = input.int(65,  "EMA 4", group=gEMA, inline="e4")
ema4Col   = input.color(color.purple, "Color", group=gEMA, inline="e4")
ema5Len   = input.int(200, "EMA 5", group=gEMA, inline="e5")
ema5Col   = input.color(color.red,    "Color", group=gEMA, inline="e5")

ema1 = ta.ema(close, ema1Len)
ema2 = ta.ema(close, ema2Len)
ema3 = ta.ema(close, ema3Len)
ema4 = ta.ema(close, ema4Len)
ema5 = ta.ema(close, ema5Len)

plot(showEMAs ? ema1 : na, title="EMA 9",   color=ema1Col, linewidth=1)
plot(showEMAs ? ema2 : na, title="EMA 15",  color=ema2Col, linewidth=1)
plot(showEMAs ? ema3 : na, title="EMA 30",  color=ema3Col, linewidth=1)
plot(showEMAs ? ema4 : na, title="EMA 65",  color=ema4Col, linewidth=2)
plot(showEMAs ? ema5 : na, title="EMA 200", color=ema5Col, linewidth=2)

// =========================================================================
// ATR / Stop Loss
// =========================================================================
gATR = "ATR / Stop Loss"
showATRPanel   = input.bool(true,  "Mostrar panel con valor de ATR", group=gATR)
atrLen         = input.int(14,     "Longitud ATR", group=gATR)
atrMult        = input.float(1.5,  "Multiplicador ATR (para SL)", step=0.1, group=gATR)
showATRStops   = input.bool(true,  "Mostrar niveles de SL sugeridos (Close +/- ATR*mult)", group=gATR)
atrLongColor   = input.color(color.gray, "Color SL Long",  group=gATR)
atrShortColor  = input.color(color.gray, "Color SL Short", group=gATR)

atrVal    = ta.atr(atrLen)
longStop  = close - atrVal * atrMult
shortStop = close + atrVal * atrMult

plot(showATRStops ? longStop  : na, title="SL Long (ATR)",  color=atrLongColor,  style=plot.style_circles)
plot(showATRStops ? shortStop : na, title="SL Short (ATR)", color=atrShortColor, style=plot.style_circles)

var table atrTable = table.new(position.top_right, 2, 2, border_width=1, border_color=color.new(color.gray, 0))
if showATRPanel and barstate.islast
    table.cell(atrTable, 0, 0, "ATR(" + str.tostring(atrLen) + ")", text_color=color.white, bgcolor=color.new(color.blue, 0))
    table.cell(atrTable, 1, 0, str.tostring(atrVal, format.mintick), text_color=color.white, bgcolor=color.new(color.gray, 60))
    table.cell(atrTable, 0, 1, "SL dist (x" + str.tostring(atrMult) + ")", text_color=color.white, bgcolor=color.new(color.blue, 0))
    table.cell(atrTable, 1, 1, str.tostring(atrVal * atrMult, format.mintick), text_color=color.white, bgcolor=color.new(color.gray, 60))

// =========================================================================
// VWAP
// =========================================================================
gVWAP          = "VWAP"
showVWAP       = input.bool(true, "Mostrar VWAP", group=gVWAP)
vwapAnchor     = input.string("Session", "Anclaje", options=["Session", "Week", "Month"], group=gVWAP)
vwapColor      = input.color(color.white, "Color VWAP", group=gVWAP)
showVWAPBands  = input.bool(false, "Mostrar bandas de desvio estandar", group=gVWAP)
vwapBandColor  = input.color(color.white, "Color bandas", group=gVWAP)
vwapBandMult1  = input.float(1.0, "Multiplicador Banda 1", step=0.1, group=gVWAP)
vwapBandMult2  = input.float(2.0, "Multiplicador Banda 2", step=0.1, group=gVWAP)

// Nota: el VWAP tiene sentido sobre todo en graficos intradiarios.
// En "Session" se resetea cada dia, en "Week" cada semana y en "Month" cada mes.
// (En Pine v6 los numeros ya no se castean automaticamente a bool, por eso se usa
// una comparacion "!=" que devuelve un booleano real en vez de ta.change() directo)
curDayStart   = time("D")
curWeekStart  = time("W")
curMonthStart = time("M")
isNewVwapPeriod = vwapAnchor == "Session" ? curDayStart != curDayStart[1] : vwapAnchor == "Week" ? curWeekStart != curWeekStart[1] : curMonthStart != curMonthStart[1]

var float vwapSumSrcVol    = na
var float vwapSumVol       = na
var float vwapSumSrcSrcVol = na

vwapSrc = hlc3

if isNewVwapPeriod or na(vwapSumVol)
    vwapSumSrcVol    := 0.0
    vwapSumVol       := 0.0
    vwapSumSrcSrcVol := 0.0

vwapSumSrcVol    := vwapSumSrcVol + vwapSrc * volume
vwapSumVol       := vwapSumVol + volume
vwapSumSrcSrcVol := vwapSumSrcSrcVol + vwapSrc * vwapSrc * volume

vwapValue = vwapSumSrcVol / vwapSumVol
vwapVarianceRaw = vwapSumSrcSrcVol / vwapSumVol - vwapValue * vwapValue
vwapStdev = math.sqrt(math.max(vwapVarianceRaw, 0))

vwapUpper1 = vwapValue + vwapStdev * vwapBandMult1
vwapLower1 = vwapValue - vwapStdev * vwapBandMult1
vwapUpper2 = vwapValue + vwapStdev * vwapBandMult2
vwapLower2 = vwapValue - vwapStdev * vwapBandMult2

plot(showVWAP ? vwapValue : na, title="VWAP", color=vwapColor, linewidth=2)
plot(showVWAP and showVWAPBands ? vwapUpper1 : na, title="VWAP +1 SD", color=color.new(vwapBandColor, 55))
plot(showVWAP and showVWAPBands ? vwapLower1 : na, title="VWAP -1 SD", color=color.new(vwapBandColor, 55))
plot(showVWAP and showVWAPBands ? vwapUpper2 : na, title="VWAP +2 SD", color=color.new(vwapBandColor, 75))
plot(showVWAP and showVWAPBands ? vwapLower2 : na, title="VWAP -2 SD", color=color.new(vwapBandColor, 75))

// =========================================================================
// PDH / PDL / PWH / PWL  (High/Low del dia y semana anterior)
// =========================================================================
gHL = "PDH / PDL / PWH / PWL"
showPD    = input.bool(true, "Mostrar PDH / PDL (dia anterior)",   group=gHL)
showPW    = input.bool(true, "Mostrar PWH / PWL (semana anterior)", group=gHL)
hlLineW   = input.int(1, "Grosor de linea", minval=1, group=gHL)
pdhColor  = input.color(color.green, "Color PDH", group=gHL)
pdlColor  = input.color(color.red,   "Color PDL", group=gHL)
pwhColor  = input.color(color.green, "Color PWH", group=gHL)
pwlColor  = input.color(color.red,   "Color PWL", group=gHL)

// Datos del dia anterior (se reutilizan tambien para los pivots diarios)
dH = request.security(syminfo.tickerid, "D", high[1],  lookahead=barmerge.lookahead_on)
dL = request.security(syminfo.tickerid, "D", low[1],   lookahead=barmerge.lookahead_on)
dC = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)

// Datos de la semana anterior (se reutilizan tambien para los pivots semanales)
wH = request.security(syminfo.tickerid, "W", high[1],  lookahead=barmerge.lookahead_on)
wL = request.security(syminfo.tickerid, "W", low[1],   lookahead=barmerge.lookahead_on)
wC = request.security(syminfo.tickerid, "W", close[1], lookahead=barmerge.lookahead_on)

plot(showPD ? dH : na, title="PDH", color=pdhColor, style=plot.style_stepline, linewidth=hlLineW)
plot(showPD ? dL : na, title="PDL", color=pdlColor, style=plot.style_stepline, linewidth=hlLineW)
plot(showPW ? wH : na, title="PWH", color=pwhColor, style=plot.style_stepline, linewidth=hlLineW)
plot(showPW ? wL : na, title="PWL", color=pwlColor, style=plot.style_stepline, linewidth=hlLineW)

// =========================================================================
// Pivots tradicionales (Diario / Semanal / Mensual)
// =========================================================================
gPiv = "Pivotes Tradicionales"
showDailyPivots      = input.bool(true,  "Mostrar Pivots Diarios",    group=gPiv)
showWeeklyPivots     = input.bool(true,  "Mostrar Pivots Semanales",  group=gPiv)
showMonthlyPivots    = input.bool(true,  "Mostrar Pivots Mensuales",  group=gPiv)
showExtLevels        = input.bool(false, "Mostrar tambien R2/S2 y R3/S3", group=gPiv)
showHistoricalPivots = input.bool(false, "Mostrar historico completo de pivots (si esta apagado, solo se ve la sesion actual)", group=gPiv)
showPivotLabels      = input.bool(true,  "Mostrar etiquetas en los niveles", group=gPiv)
pivotLineW           = input.int(1,      "Grosor de linea (pivots)", minval=1, group=gPiv)

dPivotColor = input.color(color.white,  "Color Pivot (P) - Diario",   group=gPiv, inline="dcol")
dResColor   = input.color(color.green,  "Resistencias (R)",           group=gPiv, inline="dcol")
dSupColor   = input.color(color.red,    "Soportes (S)",               group=gPiv, inline="dcol")
wPivotColor = input.color(color.blue,   "Color Pivot (P) - Semanal",  group=gPiv, inline="wcol")
wResColor   = input.color(color.teal,   "Resistencias (R)",           group=gPiv, inline="wcol")
wSupColor   = input.color(color.maroon, "Soportes (S)",               group=gPiv, inline="wcol")
mPivotColor = input.color(color.purple, "Color Pivot (P) - Mensual",  group=gPiv, inline="mcol")
mResColor   = input.color(#8BC34A,      "Resistencias (R)",           group=gPiv, inline="mcol")
mSupColor   = input.color(#FF5252,      "Soportes (S)",               group=gPiv, inline="mcol")

f_pivots(h, l, c) =>
    p  = (h + l + c) / 3
    r1 = 2 * p - l
    s1 = 2 * p - h
    r2 = p + (h - l)
    s2 = p - (h - l)
    r3 = h + 2 * (p - l)
    s3 = l - 2 * (h - p)
    [p, r1, s1, r2, s2, r3, s3]

// Datos del mes anterior
mH = request.security(syminfo.tickerid, "M", high[1],  lookahead=barmerge.lookahead_on)
mL = request.security(syminfo.tickerid, "M", low[1],   lookahead=barmerge.lookahead_on)
mC = request.security(syminfo.tickerid, "M", close[1], lookahead=barmerge.lookahead_on)

[dP, dR1, dS1, dR2, dS2, dR3, dS3] = f_pivots(dH, dL, dC)
[wP, wR1, wS1, wR2, wS2, wR3, wS3] = f_pivots(wH, wL, wC)
[mP, mR1, mS1, mR2, mS2, mR3, mS3] = f_pivots(mH, mL, mC)

// Deteccion de inicio de cada periodo: se dispara cuando el VALOR del pivote
// (dP/wP/mP) efectivamente cambia, no cuando cambia la fecha. Usar el cambio de
// fecha (ta.change(time("D"))) puede disparar 1-2 velas ANTES de que el dato de
// request.security se actualice, lo que ancla la linea con un valor viejo y
// termina dibujando una diagonal en vez de una linea horizontal.
// (Se usa "!=" en vez de ta.change() porque en Pine v6 un numero ya no se castea
// automaticamente a bool: ta.change() devuelve float, "!=" devuelve bool real)
isNewDay   = dP != dP[1]
isNewWeek  = wP != wP[1]
isNewMonth = mP != mP[1]

// Arrays que guardan las lineas/etiquetas "vivas" de cada nivel (P,R1,S1,R2,S2,R3,S3)
var line[]  dLines  = array.new_line(7, na)
var line[]  wLines  = array.new_line(7, na)
var line[]  mLines  = array.new_line(7, na)
var label[] dLabels = array.new_label(7, na)
var label[] wLabels = array.new_label(7, na)
var label[] mLabels = array.new_label(7, na)

// Dibuja/actualiza un nivel: si keepHistory=false, borra el segmento anterior al
// empezar un periodo nuevo (solo se ve la sesion actual). Si keepHistory=true,
// deja el segmento anterior dibujado y arranca uno nuevo (se ve todo el historico).
f_updateLevel(lineArr, labelArr, idx, isNewPeriod, val, txt, col, lwidth, keepHistory, showLabel) =>
    if na(val)
        oldLine = array.get(lineArr, idx)
        if not na(oldLine)
            line.delete(oldLine)
            array.set(lineArr, idx, na)
        oldLabel = array.get(labelArr, idx)
        if not na(oldLabel)
            label.delete(oldLabel)
            array.set(labelArr, idx, na)
    else
        oldLine = array.get(lineArr, idx)
        if isNewPeriod or na(oldLine)
            if not keepHistory and not na(oldLine)
                line.delete(oldLine)
            oldLabel = array.get(labelArr, idx)
            if not na(oldLabel)
                label.delete(oldLabel)
            newLine = line.new(bar_index, val, bar_index, val, color=col, width=lwidth)
            array.set(lineArr, idx, newLine)
            if showLabel
                newLabel = label.new(bar_index, val, txt, style=label.style_label_left, color=color.new(col, 85), textcolor=col, size=size.small)
                array.set(labelArr, idx, newLabel)
        else
            line.set_xy2(oldLine, bar_index, val)
            lbl = array.get(labelArr, idx)
            if not na(lbl)
                label.set_xy(lbl, bar_index, val)

// --- Diarios ---
f_updateLevel(dLines, dLabels, 0, isNewDay, showDailyPivots ? dP : na, "D-P", dPivotColor, pivotLineW, showHistoricalPivots, showPivotLabels)
f_updateLevel(dLines, dLabels, 1, isNewDay, showDailyPivots ? dR1 : na, "D-R1", dResColor, pivotLineW, showHistoricalPivots, showPivotLabels)
f_updateLevel(dLines, dLabels, 2, isNewDay, showDailyPivots ? dS1 : na, "D-S1", dSupColor, pivotLineW, showHistoricalPivots, showPivotLabels)
f_updateLevel(dLines, dLabels, 3, isNewDay, (showDailyPivots and showExtLevels) ? dR2 : na, "D-R2", color.new(dResColor, 40), pivotLineW, showHistoricalPivots, showPivotLabels)
f_updateLevel(dLines, dLabels, 4, isNewDay, (showDailyPivots and showExtLevels) ? dS2 : na, "D-S2", color.new(dSupColor, 40), pivotLineW, showHistoricalPivots, showPivotLabels)
f_updateLevel(dLines, dLabels, 5, isNewDay, (showDailyPivots and showExtLevels) ? dR3 : na, "D-R3", color.new(dResColor, 65), pivotLineW, showHistoricalPivots, showPivotLabels)
f_updateLevel(dLines, dLabels, 6, isNewDay, (showDailyPivots and showExtLevels) ? dS3 : na, "D-S3", color.new(dSupColor, 65), pivotLineW, showHistoricalPivots, showPivotLabels)

// --- Semanales ---
f_updateLevel(wLines, wLabels, 0, isNewWeek, showWeeklyPivots ? wP : na, "W-P", wPivotColor, pivotLineW, showHistoricalPivots, showPivotLabels)
f_updateLevel(wLines, wLabels, 1, isNewWeek, showWeeklyPivots ? wR1 : na, "W-R1", wResColor, pivotLineW, showHistoricalPivots, showPivotLabels)
f_updateLevel(wLines, wLabels, 2, isNewWeek, showWeeklyPivots ? wS1 : na, "W-S1", wSupColor, pivotLineW, showHistoricalPivots, showPivotLabels)
f_updateLevel(wLines, wLabels, 3, isNewWeek, (showWeeklyPivots and showExtLevels) ? wR2 : na, "W-R2", color.new(wResColor, 40), pivotLineW, showHistoricalPivots, showPivotLabels)
f_updateLevel(wLines, wLabels, 4, isNewWeek, (showWeeklyPivots and showExtLevels) ? wS2 : na, "W-S2", color.new(wSupColor, 40), pivotLineW, showHistoricalPivots, showPivotLabels)
f_updateLevel(wLines, wLabels, 5, isNewWeek, (showWeeklyPivots and showExtLevels) ? wR3 : na, "W-R3", color.new(wResColor, 65), pivotLineW, showHistoricalPivots, showPivotLabels)
f_updateLevel(wLines, wLabels, 6, isNewWeek, (showWeeklyPivots and showExtLevels) ? wS3 : na, "W-S3", color.new(wSupColor, 65), pivotLineW, showHistoricalPivots, showPivotLabels)

// --- Mensuales ---
f_updateLevel(mLines, mLabels, 0, isNewMonth, showMonthlyPivots ? mP : na, "M-P", mPivotColor, pivotLineW, showHistoricalPivots, showPivotLabels)
f_updateLevel(mLines, mLabels, 1, isNewMonth, showMonthlyPivots ? mR1 : na, "M-R1", mResColor, pivotLineW, showHistoricalPivots, showPivotLabels)
f_updateLevel(mLines, mLabels, 2, isNewMonth, showMonthlyPivots ? mS1 : na, "M-S1", mSupColor, pivotLineW, showHistoricalPivots, showPivotLabels)
f_updateLevel(mLines, mLabels, 3, isNewMonth, (showMonthlyPivots and showExtLevels) ? mR2 : na, "M-R2", color.new(mResColor, 40), pivotLineW, showHistoricalPivots, showPivotLabels)
f_updateLevel(mLines, mLabels, 4, isNewMonth, (showMonthlyPivots and showExtLevels) ? mS2 : na, "M-S2", color.new(mSupColor, 40), pivotLineW, showHistoricalPivots, showPivotLabels)
f_updateLevel(mLines, mLabels, 5, isNewMonth, (showMonthlyPivots and showExtLevels) ? mR3 : na, "M-R3", color.new(mResColor, 65), pivotLineW, showHistoricalPivots, showPivotLabels)
f_updateLevel(mLines, mLabels, 6, isNewMonth, (showMonthlyPivots and showExtLevels) ? mS3 : na, "M-S3", color.new(mSupColor, 65), pivotLineW, showHistoricalPivots, showPivotLabels)
````
