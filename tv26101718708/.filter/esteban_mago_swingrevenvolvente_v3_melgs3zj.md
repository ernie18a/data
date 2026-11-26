# Esteban Mago SwingRevEnvolvente v3

- url: https://www.tradingview.com/script/meLgS3ZJ/
- type: indicator
- pine_id: PUB;968f03bc66ec4930b45389fa7332c79c
- version: 1.0

## Description

Swing, envolvente, patron de 3 velas, absorcion distribucion.

## Source Code

````pine
//@version=6
indicator("Esteban Mago SwingRevEnvolvente v3", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// ===================================================
// INPUTS GENERALES
// ===================================================
useEquals   = input.bool(true,  "Solo senalizar en Equal Highs/Lows",  group="Equal Levels")
eqTolerance = input.float(0.2,  "Tolerancia Equal H/L (%)", minval=0.1, maxval=0.3, step=0.05, group="Equal Levels")
eqLookback  = input.int(50,     "Lookback busqueda de equals (velas)", group="Equal Levels")

wickPct  = input.float(0.6, "Mecha minima (% del rango total)", minval=0.4, maxval=0.9, step=0.05, group="Mechazo")
volMulti = input.float(1.5, "Volumen minimo vs promedio (x)",   minval=1.0, step=0.1,              group="Mechazo")
volLen   = input.int(20,    "Periodo promedio de volumen",                                          group="Mechazo")

engulfFactor = input.float(1.0, "Factor envolvente (cuerpo actual > anterior x N)", minval=0.8, step=0.1, group="Envolvente")

showDiv     = input.bool(true,  "Mostrar senales Dist/Acc",                         group="Divergencia CVD")
extLookback = input.int(20,     "Lookback nuevo extremo de precio (velas)", minval=3, maxval=50, group="Divergencia CVD")
cvdVolLen   = input.int(20,     "Periodo promedio volumen CVD",                     group="Divergencia CVD")
cvdVolMulti = input.float(1.5,  "Multiplicador volumen CVD (x)", minval=1.0, maxval=5.0, step=0.1, group="Divergencia CVD")

filterTrend = input.bool(true,  "Filtrar Dist/Acc por contexto de tendencia EMA", group="Filtros")
filterRTH   = input.bool(true,  "Solo senalizar en RTH (9:30-16:00 NY)",          group="Filtros")
filterLDN   = input.bool(false, "Incluir sesion Londres (3:00-9:30 NY)",           group="Filtros")

showZone         = input.bool(true,  "Mostrar Zonas Institucionales",                          group="Zona Institucional")
zoneExtend       = input.int(15,     "Extension zona (velas a la derecha)", minval=5, maxval=100, step=1, group="Zona Institucional")
zoneWickPct      = input.float(0.55, "Mecha significativa vela 1 (% rango)", minval=0.3, maxval=0.9, step=0.05, group="Zona Institucional")
zoneEngulfFactor = input.float(1.0,  "Factor envolvente zona", minval=0.8, step=0.1, group="Zona Institucional")
zoneConfirmBars  = input.int(3,      "Velas de confirmacion (3 o 4)", minval=3, maxval=4, group="Zona Institucional")
zoneTrendBars    = input.int(3,      "Velas previas en tendencia requeridas", minval=2, maxval=8, group="Zona Institucional")
zoneVolFilter    = input.bool(true,  "Exigir volumen elevado en vela 1 o vela 2", group="Zona Institucional")
zoneVolMult      = input.float(1.3,  "Multiplicador volumen zona", minval=1.0, maxval=3.0, step=0.1, group="Zona Institucional")
zoneVolLen       = input.int(20,     "Periodo promedio volumen zona", group="Zona Institucional")
zoneMinRange     = input.float(0.3,  "Rango minimo vela 1 como % del ATR", minval=0.1, maxval=2.0, step=0.1, group="Zona Institucional")
zoneProximity    = input.float(0.5,  "Distancia minima entre zonas (% del precio)", minval=0.1, maxval=2.0, step=0.1, group="Zona Institucional")

showEngulfSignal = input.bool(true,  "Mostrar senal E (envolvente vela 2)",          group="Senales E y Circulo")
engulfMinBody    = input.float(1.0,  "Envolvente: cuerpo v2 >= v1 x N", minval=1.0, maxval=3.0, step=0.1, group="Senales E y Circulo")
showWickSignal   = input.bool(true,  "Mostrar senal circulo (mecha vela 1)",         group="Senales E y Circulo")
wickSignalPct    = input.float(0.65, "Mecha circulo: % minimo del rango", minval=0.4, maxval=0.95, step=0.05, group="Senales E y Circulo")

showTBR    = input.bool(true,    "Mostrar Three Bar Reversal",                       group="Three Bar Reversal")
tbrType    = input.string("All", "Tipo de patron", options=["Normal","Enhanced","All"], group="Three Bar Reversal")
tbrSR      = input.string("Zone","Zona S/R derivada", options=["Level","Zone","None"], group="Three Bar Reversal")
tbrBullCol = input.color(#2962ff, "Color Bullish TBR", group="Three Bar Reversal")
tbrBearCol = input.color(#ff9800, "Color Bearish TBR", group="Three Bar Reversal")

showSwing = input.bool(true, "Mostrar Swing Highs/Lows",  group="Swing Structure")
swingLen  = input.int(21,    "Longitud pivot swing", minval=3, maxval=50, group="Swing Structure")
swingHCol = input.color(color.new(#ff1744, 0), "Color Swing High", group="Swing Structure")
swingLCol = input.color(color.new(#00e676, 0), "Color Swing Low",  group="Swing Structure")

colBull = input.color(color.new(#00e5ff, 0),  "Senal Alcista",       group="Colores")
colBear = input.color(color.new(#ff1744, 0),  "Senal Bajista",       group="Colores")
colEQ   = input.color(color.new(#ffeb3b, 20), "Equal Levels",        group="Colores")
colDist = input.color(color.new(#ff6d00, 0),  "Distribucion (Dist)", group="Colores")
colAcc  = input.color(color.new(#76ff03, 0),  "Acumulacion (Acc)",   group="Colores")

// ===================================================
// BLOQUE 0 - SESION
// ===================================================
inRTH = not na(time(timeframe.period, "0930-1600", "America/New_York"))
inLDN = not na(time(timeframe.period, "0300-0930", "America/New_York"))

sessionOK = switch
    filterRTH and filterLDN => inRTH or inLDN
    filterRTH               => inRTH
    filterLDN               => inLDN
    =>                         true

// ===================================================
// BLOQUE 1 - EQUAL HIGHS / LOWS
// ===================================================
tolAbs    = close * (eqTolerance / 100)
swingHigh = ta.pivothigh(high, 5, 5)
swingLow  = ta.pivotlow(low,  5, 5)

var bool isEqualHigh = false
var bool isEqualLow  = false

isEqualHigh := false
isEqualLow  := false

for i = 1 to eqLookback
    if not na(swingHigh) and not na(swingHigh[i])
        if math.abs(swingHigh - swingHigh[i]) <= tolAbs
            isEqualHigh := true
    if not na(swingLow) and not na(swingLow[i])
        if math.abs(swingLow - swingLow[i]) <= tolAbs
            isEqualLow := true

if isEqualHigh and not na(swingHigh)
    line.new(bar_index - 5, swingHigh, bar_index, swingHigh, color=color.new(colEQ, 20), width=1, style=line.style_dashed)
if isEqualLow and not na(swingLow)
    line.new(bar_index - 5, swingLow, bar_index, swingLow, color=color.new(colEQ, 20), width=1, style=line.style_dashed)

// ===================================================
// BLOQUE 2 - MECHAZO CON ABSORCION
// ===================================================
volAvg     = ta.sma(volume, volLen)
highVol    = volume > volAvg * volMulti
totalRange = high - low
upperWick  = high - math.max(close, open)
lowerWick  = math.min(close, open) - low

upperWickDom = totalRange > 0 and (upperWick / totalRange) >= wickPct
lowerWickDom = totalRange > 0 and (lowerWick / totalRange) >= wickPct
closesLow    = close < (high + low) / 2
closesHigh   = close > (high + low) / 2

sweepBear = upperWickDom and closesLow  and highVol
sweepBull = lowerWickDom and closesHigh and highVol

// ===================================================
// BLOQUE 3 - VELA ENVOLVENTE
// ===================================================
prevBody = math.abs(close[1] - open[1])
currBody = math.abs(close - open)

engulfBull = close > open and open < close[1] and close > open[1] and currBody >= prevBody * engulfFactor
engulfBear = close < open and open > close[1] and close < open[1] and currBody >= prevBody * engulfFactor

// ===================================================
// BLOQUE 4 - SENAL FINAL MECHAZO + ENVOLVENTE
// ===================================================
signalBull_EQ  = useEquals     and isEqualLow[1]  and sweepBull[1] and engulfBull and sessionOK
signalBear_EQ  = useEquals     and isEqualHigh[1] and sweepBear[1] and engulfBear and sessionOK
signalBull_ANY = not useEquals and sweepBull[1]   and engulfBull                  and sessionOK
signalBear_ANY = not useEquals and sweepBear[1]   and engulfBear                  and sessionOK

signalBull = signalBull_EQ or signalBull_ANY
signalBear = signalBear_EQ or signalBear_ANY

// ===================================================
// BLOQUE 5 - VISUALIZACION MECHAZO + ENVOLVENTE
// ===================================================
atr14 = ta.atr(14)

plotshape(series=sweepBull and (not useEquals or isEqualLow) and sessionOK, title="Mechazo Alcista", style=shape.diamond, location=location.belowbar, color=color.new(colBull, 40), size=size.tiny)
plotshape(series=sweepBear and (not useEquals or isEqualHigh) and sessionOK, title="Mechazo Bajista", style=shape.diamond, location=location.abovebar, color=color.new(colBear, 40), size=size.tiny)
plotshape(series=signalBull, title="ENTRADA LARGA",  style=shape.triangleup,   location=location.belowbar, color=colBull, size=size.normal, text="L")
plotshape(series=signalBear, title="ENTRADA CORTA",  style=shape.triangledown, location=location.abovebar, color=colBear, size=size.normal, text="S")

plot(signalBull ? low  - atr14 * 0.3 : na, color=color.new(colBull, 85), linewidth=6, style=plot.style_circles)
plot(signalBear ? high + atr14 * 0.3 : na, color=color.new(colBear, 85), linewidth=6, style=plot.style_circles)

// ===================================================
// BLOQUE 6 - ALERTAS MECHAZO + ENVOLVENTE
// ===================================================
alertcondition(signalBull, "Reversal Alcista Confirmado", "Sweep + Engulf ALCISTA detectado")
alertcondition(signalBear, "Reversal Bajista Confirmado", "Sweep + Engulf BAJISTA detectado")
alertcondition(sweepBull,  "Mechazo Alcista", "Stop hunt alcista - esperar confirmacion")
alertcondition(sweepBear,  "Mechazo Bajista", "Stop hunt bajista - esperar confirmacion")

// ===================================================
// BLOQUE 7 - DIVERGENCIA CVD EN EXTREMO
// ===================================================
velaDelta      = close > open ? volume : close < open ? -volume : 0.0
cvdAvg         = ta.sma(math.abs(velaDelta), cvdVolLen)
cvdBullVela    = velaDelta > 0
cvdBearVela    = velaDelta < 0
newHigh        = high >= ta.highest(high, extLookback)
newLow         = low  <= ta.lowest(low,  extLookback)
closeUpperHalf = close > (high + low) / 2
cvdHighVol     = math.abs(velaDelta) > cvdAvg * cvdVolMulti

ema9_f  = ta.ema(close, 9)
ema20_f = ta.ema(close, 20)

noDowntrend   = not filterTrend or not (ema9_f < ema20_f and close < ema9_f)
noUptrend     = not filterTrend or not (ema9_f > ema20_f and close > ema9_f)
notStrongBull = currBody == 0 or ((close - open) / totalRange) < 0.6

distSignal = showDiv and sessionOK and newHigh and cvdBearVela and notStrongBull and cvdHighVol and noDowntrend
accSignal  = showDiv and sessionOK and newLow  and cvdBullVela and closeUpperHalf and cvdHighVol and noUptrend

plotshape(series=distSignal, title="Distribucion", style=shape.xcross, location=location.abovebar, color=colDist, size=size.small, text="Dist")
plotshape(series=accSignal,  title="Acumulacion",  style=shape.xcross, location=location.belowbar, color=colAcc,  size=size.small, text="Acc")

plot(distSignal ? high + atr14 * 0.5 : na, color=color.new(colDist, 80), linewidth=8, style=plot.style_circles)
plot(accSignal  ? low  - atr14 * 0.5 : na, color=color.new(colAcc,  80), linewidth=8, style=plot.style_circles)

alertcondition(distSignal, "Distribucion en Maximo", "CVD bajista en nuevo high - posible reversal")
alertcondition(accSignal,  "Acumulacion en Minimo",  "CVD alcista en nuevo low - posible reversal")

// ===================================================
// BLOQUE 8 - ZONA INSTITUCIONAL
// ===================================================
zoneBullCol3 = color.new(#00e676, 80)
zoneBullCol4 = color.new(#00e676, 60)
zoneBearCol3 = color.new(#ff1744, 80)
zoneBearCol4 = color.new(#ff1744, 60)
zoneBullBrd3 = color.new(#00e676, 20)
zoneBullBrd4 = color.new(#00e676, 0)
zoneBearBrd3 = color.new(#ff1744, 20)
zoneBearBrd4 = color.new(#ff1744, 0)

zoneVolAvg        = ta.sma(volume, zoneVolLen)
zoneHighVol_v1_c3 = volume[2] > zoneVolAvg * zoneVolMult
zoneHighVol_v2_c3 = volume[1] > zoneVolAvg * zoneVolMult
zoneHighVol_v1_c4 = volume[3] > zoneVolAvg * zoneVolMult
zoneHighVol_v2_c4 = volume[2] > zoneVolAvg * zoneVolMult
zoneVolOK_conf3   = not zoneVolFilter or (zoneHighVol_v1_c3 or zoneHighVol_v2_c3)
zoneVolOK_conf4   = not zoneVolFilter or (zoneHighVol_v1_c4 or zoneHighVol_v2_c4)

bearCount_conf3 = (close[3]  < open[3]  ? 1 : 0) + (close[4]  < open[4]  ? 1 : 0) + (close[5]  < open[5]  ? 1 : 0) + (close[6]  < open[6]  ? 1 : 0) + (close[7]  < open[7]  ? 1 : 0) + (close[8]  < open[8]  ? 1 : 0) + (close[9]  < open[9]  ? 1 : 0) + (close[10] < open[10] ? 1 : 0)
bullCount_conf3 = (close[3]  > open[3]  ? 1 : 0) + (close[4]  > open[4]  ? 1 : 0) + (close[5]  > open[5]  ? 1 : 0) + (close[6]  > open[6]  ? 1 : 0) + (close[7]  > open[7]  ? 1 : 0) + (close[8]  > open[8]  ? 1 : 0) + (close[9]  > open[9]  ? 1 : 0) + (close[10] > open[10] ? 1 : 0)
bearCount_conf4 = (close[4]  < open[4]  ? 1 : 0) + (close[5]  < open[5]  ? 1 : 0) + (close[6]  < open[6]  ? 1 : 0) + (close[7]  < open[7]  ? 1 : 0) + (close[8]  < open[8]  ? 1 : 0) + (close[9]  < open[9]  ? 1 : 0) + (close[10] < open[10] ? 1 : 0) + (close[11] < open[11] ? 1 : 0)
bullCount_conf4 = (close[4]  > open[4]  ? 1 : 0) + (close[5]  > open[5]  ? 1 : 0) + (close[6]  > open[6]  ? 1 : 0) + (close[7]  > open[7]  ? 1 : 0) + (close[8]  > open[8]  ? 1 : 0) + (close[9]  > open[9]  ? 1 : 0) + (close[10] > open[10] ? 1 : 0) + (close[11] > open[11] ? 1 : 0)

zoneTrendOK_bull_c3 = bearCount_conf3 >= zoneTrendBars
zoneTrendOK_bear_c3 = bullCount_conf3 >= zoneTrendBars
zoneTrendOK_bull_c4 = bearCount_conf4 >= zoneTrendBars
zoneTrendOK_bear_c4 = bullCount_conf4 >= zoneTrendBars

zoneAtr        = ta.atr(14)
zoneRangeOK_c3 = (high[2] - low[2]) >= zoneAtr * zoneMinRange
zoneRangeOK_c4 = (high[3] - low[3]) >= zoneAtr * zoneMinRange

proxTol = close * (zoneProximity / 100)
var float lastBullZonePrice = na
var float lastBearZonePrice = na
proxOK_bull = na(lastBullZonePrice) or math.abs(close - lastBullZonePrice) > proxTol
proxOK_bear = na(lastBearZonePrice) or math.abs(close - lastBearZonePrice) > proxTol

zBull_confirm3 = showZone and zoneConfirmBars == 3 and close[2] < open[2] and close[1] > open[1] and close > open and zoneTrendOK_bull_c3 and zoneVolOK_conf3 and zoneRangeOK_c3 and proxOK_bull
zBull_confirm4 = showZone and zoneConfirmBars == 4 and close[3] < open[3] and close[2] > open[2] and close[1] > open[1] and close > open and zoneTrendOK_bull_c4 and zoneVolOK_conf4 and zoneRangeOK_c4 and proxOK_bull
zBear_confirm3 = showZone and zoneConfirmBars == 3 and close[2] > open[2] and close[1] < open[1] and close < open and zoneTrendOK_bear_c3 and zoneVolOK_conf3 and zoneRangeOK_c3 and proxOK_bear
zBear_confirm4 = showZone and zoneConfirmBars == 4 and close[3] > open[3] and close[2] < open[2] and close[1] < open[1] and close < open and zoneTrendOK_bear_c4 and zoneVolOK_conf4 and zoneRangeOK_c4 and proxOK_bear

if zBull_confirm3 or zBull_confirm4
    lastBullZonePrice := close
if zBear_confirm3 or zBear_confirm4
    lastBearZonePrice := close

zBull3_top   = open[2]
zBull3_bot   = low[2]
zBull3_start = bar_index - 2
zBear3_top   = high[2]
zBear3_bot   = open[2]
zBear3_start = bar_index - 2
zBull4_top   = open[3]
zBull4_bot   = low[3]
zBull4_start = bar_index - 3
zBear4_top   = high[3]
zBear4_bot   = open[3]
zBear4_start = bar_index - 3

if zBull_confirm3
    box.new(left=zBull3_start, top=zBull3_top, right=bar_index + zoneExtend, bottom=zBull3_bot, border_color=zoneBullBrd3, border_width=1, bgcolor=zoneBullCol3)
if zBull_confirm4
    box.new(left=zBull4_start, top=zBull4_top, right=bar_index + zoneExtend, bottom=zBull4_bot, border_color=zoneBullBrd4, border_width=1, bgcolor=zoneBullCol4)
if zBear_confirm3
    box.new(left=zBear3_start, top=zBear3_top, right=bar_index + zoneExtend, bottom=zBear3_bot, border_color=zoneBearBrd3, border_width=1, bgcolor=zoneBearCol3)
if zBear_confirm4
    box.new(left=zBear4_start, top=zBear4_top, right=bar_index + zoneExtend, bottom=zBear4_bot, border_color=zoneBearBrd4, border_width=1, bgcolor=zoneBearCol4)

zBull3_v1rng   = high[2] - low[2]
zBull3_v1lwick = math.min(open[2], close[2]) - low[2]
zBull3_sigWick = zBull3_v1rng > 0 and (zBull3_v1lwick / zBull3_v1rng) >= wickSignalPct and zBull3_v1rng >= zoneAtr * zoneMinRange
zBull4_v1rng   = high[3] - low[3]
zBull4_v1lwick = math.min(open[3], close[3]) - low[3]
zBull4_sigWick = zBull4_v1rng > 0 and (zBull4_v1lwick / zBull4_v1rng) >= wickSignalPct and zBull4_v1rng >= zoneAtr * zoneMinRange
zBear3_v1rng   = high[2] - low[2]
zBear3_v1uwick = high[2] - math.max(open[2], close[2])
zBear3_sigWick = zBear3_v1rng > 0 and (zBear3_v1uwick / zBear3_v1rng) >= wickSignalPct and zBear3_v1rng >= zoneAtr * zoneMinRange
zBear4_v1rng   = high[3] - low[3]
zBear4_v1uwick = high[3] - math.max(open[3], close[3])
zBear4_sigWick = zBear4_v1rng > 0 and (zBear4_v1uwick / zBear4_v1rng) >= wickSignalPct and zBear4_v1rng >= zoneAtr * zoneMinRange

plotshape(series=showWickSignal and ((zBull_confirm3 and zBull3_sigWick) or (zBull_confirm4 and zBull4_sigWick)), title="Zona Bullish Mecha V1", style=shape.circle, location=location.belowbar, color=color.new(#00e676, 0), size=size.small, offset=-2)
plotshape(series=showWickSignal and ((zBear_confirm3 and zBear3_sigWick) or (zBear_confirm4 and zBear4_sigWick)), title="Zona Bearish Mecha V1", style=shape.circle, location=location.abovebar, color=color.new(#ff1744, 0), size=size.small, offset=-2)

zBull3_v2eng = zBull_confirm3 and close[1] > open[1] and open[1] <= close[2] and close[1] >= open[2] and math.abs(close[1] - open[1]) >= math.abs(open[2] - close[2]) * engulfMinBody
zBull4_v2eng = zBull_confirm4 and close[2] > open[2] and open[2] <= close[3] and close[2] >= open[3] and math.abs(close[2] - open[2]) >= math.abs(open[3] - close[3]) * engulfMinBody
zBear3_v2eng = zBear_confirm3 and close[1] < open[1] and open[1] >= close[2] and close[1] <= open[2] and math.abs(open[1] - close[1]) >= math.abs(close[2] - open[2]) * engulfMinBody
zBear4_v2eng = zBear_confirm4 and close[2] < open[2] and open[2] >= close[3] and close[2] <= open[3] and math.abs(open[2] - close[2]) >= math.abs(close[3] - open[3]) * engulfMinBody

plotshape(series=showEngulfSignal and (zBull3_v2eng or zBull4_v2eng), title="Zona Bullish Envolvente V2", style=shape.diamond, location=location.belowbar, color=color.new(#00e676, 0), size=size.small, offset=-1, text="E")
plotshape(series=showEngulfSignal and (zBear3_v2eng or zBear4_v2eng), title="Zona Bearish Envolvente V2", style=shape.diamond, location=location.abovebar, color=color.new(#ff1744, 0), size=size.small, offset=-1, text="E")

alertcondition(zBull_confirm3 or zBull_confirm4, "Zona Institucional Bullish", "Zona alcista confirmada")
alertcondition(zBear_confirm3 or zBear_confirm4, "Zona Institucional Bearish", "Zona bajista confirmada")
alertcondition((zBull_confirm3 or zBull_confirm4) and (zBull3_sigWick or zBull4_sigWick or zBull3_v2eng or zBull4_v2eng), "Zona Bullish Alta Calidad", "Zona bullish con mecha sig. o envolvente")
alertcondition((zBear_confirm3 or zBear_confirm4) and (zBear3_sigWick or zBear4_sigWick or zBear3_v2eng or zBear4_v2eng), "Zona Bearish Alta Calidad", "Zona bearish con mecha sig. o envolvente")

// ===================================================
// BLOQUE 9 - THREE BAR REVERSAL
// ===================================================
bullTBR_cond = close[2] < open[2] and low[1] < low[2] and high[1] < high[2] and close[1] < open[1] and close > open and high > high[2]
bearTBR_cond = close[2] > open[2] and high[1] > high[2] and low[1] > low[2] and close[1] > open[1] and close < open and low < low[2]

bullTBR = showTBR and bullTBR_cond and (tbrType == "All" or (tbrType == "Enhanced" and close > high[2]) or (tbrType == "Normal" and close <= high[2]))
bearTBR = showTBR and bearTBR_cond and (tbrType == "All" or (tbrType == "Enhanced" and close < low[2])  or (tbrType == "Normal" and close >= low[2]))

var line  tbrLnAT = na
var line  tbrLnAB = na
var box   tbrBxA  = na
var bool  tbrBullProcess = false
var float tbrBullHigh    = na

var line  tbrLnST = na
var line  tbrLnSB = na
var box   tbrBxS  = na
var bool  tbrBearProcess = false
var float tbrBearLow     = na

if bullTBR
    tbrBullProcess := true
    label.new(bar_index, low, "TBR", color=color(na), textcolor=color.new(tbrBullCol, 10), style=label.style_label_up, size=size.small)
    tbrLnAT := line.new(bar_index[2], high[2], bar_index, high[2], color=color.new(tbrBullCol, 53))
    tbrLnAB := line.new(bar_index[1], math.min(low[1], low), bar_index, math.min(low[1], low), color=color.new(tbrBullCol, 53))
    tbrBullHigh := tbrSR == "Zone" ? math.max(low[1], low) : math.min(low[1], low)

if tbrBullProcess and not na(tbrLnAT) and not na(tbrLnAB)
    if close[1] > tbrLnAT.get_price(bar_index)
        tbrBxA := box.new(left=bar_index, top=tbrBullHigh, right=bar_index, bottom=tbrLnAB.get_price(bar_index), border_color=color.new(tbrBullCol, tbrSR == "Zone" ? 73 : 53), bgcolor=color.new(tbrBullCol, 73))
        tbrBullProcess := false
    if close[1] < tbrLnAB.get_price(bar_index) or bearTBR
        tbrBullProcess := false
    tbrLnAT.set_x2(tbrBullProcess ? bar_index : bar_index - 1)
    tbrLnAB.set_x2(tbrBullProcess ? bar_index : bar_index - 1)

if not na(tbrBxA) and tbrSR != "None"
    tbrBxA.set_right(bar_index)

if bearTBR
    tbrBearProcess := true
    label.new(bar_index, high, "TBR", color=color(na), textcolor=color.new(tbrBearCol, 10), style=label.style_label_down, size=size.small)
    tbrLnST := line.new(bar_index[1], math.max(high[1], high), bar_index, math.max(high[1], high), color=color.new(tbrBearCol, 53))
    tbrLnSB := line.new(bar_index[2], low[2], bar_index, low[2], color=color.new(tbrBearCol, 53))
    tbrBearLow := tbrSR == "Zone" ? math.min(high[1], high) : math.max(high[1], high)

if tbrBearProcess and not na(tbrLnST) and not na(tbrLnSB)
    if close[1] < tbrLnSB.get_price(bar_index)
        tbrBxS := box.new(left=bar_index, top=tbrLnST.get_price(bar_index), right=bar_index, bottom=tbrBearLow, border_color=color.new(tbrBearCol, tbrSR == "Zone" ? 73 : 53), bgcolor=color.new(tbrBearCol, 73))
        tbrBearProcess := false
    if close[1] > tbrLnST.get_price(bar_index) or bullTBR
        tbrBearProcess := false
    tbrLnST.set_x2(tbrBearProcess ? bar_index : bar_index - 1)
    tbrLnSB.set_x2(tbrBearProcess ? bar_index : bar_index - 1)

if not na(tbrBxS) and tbrSR != "None"
    tbrBxS.set_right(bar_index)

alertcondition(bullTBR, "Three Bar Reversal Bullish", "TBR alcista detectado")
alertcondition(bearTBR, "Three Bar Reversal Bearish", "TBR bajista detectado")

// ===================================================
// BLOQUE 10 - SWING HIGHS/LOWS + PATRONES DE VELA
// ===================================================
swPh = ta.pivothigh(swingLen, swingLen)
swPl = ta.pivotlow(swingLen, swingLen)

var float swPhy = na
var float swPly = na

swO = open[swingLen]
swH = high[swingLen]
swL = low[swingLen]
swC = close[swingLen]
swD = math.abs(swC - swO)

swHammer   = not na(swPl) and math.min(swO, swC) - swL > swD and swH - math.max(swC, swO) < swD
swIHammer  = not na(swPl) and swH - math.max(swC, swO) > swD and math.min(swC, swO) - swL < swD
swBullEng  = swC > swO and swC[1] < swO[1] and swC > swO[1] and swO < swC[1]
swHanging  = not na(swPh) and math.min(swC, swO) - swL > swD and swH - math.max(swO, swC) < swD
swShooting = not na(swPh) and swH - math.max(swO, swC) > swD and math.min(swC, swO) - swL < swD
swBearEng  = swC < swO and swC[1] > swO[1] and swC < swO[1] and swO > swC[1]

swPatternName = swHammer ? "Hammer" : swIHammer ? "Inv.Hmr" : swBullEng ? "BullEng" : swHanging ? "Hanging" : swShooting ? "Shooting" : swBearEng ? "BearEng" : ""

if showSwing and not na(swPh)
    swLabelH = swPh > swPhy ? "HH" : "LH"
    label.new(bar_index[swingLen], swPh, swLabelH + (swPatternName != "" ? "\n" + swPatternName : ""), color=color(na), style=label.style_label_down, textcolor=swingHCol, size=size.small)
    swPhy := swPh

if showSwing and not na(swPl)
    swLabelL = swPl < swPly ? "LL" : "HL"
    label.new(bar_index[swingLen], swPl, swLabelL + (swPatternName != "" ? "\n" + swPatternName : ""), color=color(na), style=label.style_label_up, textcolor=swingLCol, size=size.small)
    swPly := swPl
````
