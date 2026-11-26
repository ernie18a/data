# ORANIU Levels Structure Master

- url: https://www.tradingview.com/script/2yqVM4aM/
- type: indicator
- pine_id: PUB;7b06b13457bb4201a76d2ba79cd5cdec
- version: 1.0

## Description

A clean zone-based indicator for identifying supply/demand areas, order blocks, and potential price reaction points using market structure, liquidity, and price action.

## Source Code

````pine
//@version=6
indicator("ORANIU Levels + Structure Master Trend v4", shorttitle="ORANIU Structure Trend", overlay=true, max_lines_count=300, max_labels_count=300)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 00. HORARIO / ZONAS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupSession = "00. Horario / zonas"

tradeSession = input.session("0700-1100", "Horario real de operar", group=groupSession)
londonSession = input.session("0000-0400", "Sesión Londres visual", group=groupSession)

timezoneMode = input.string(
     "America/Chicago",
     "Zona horaria",
     options=["America/Chicago", "America/New_York", "Exchange", "Manual"],
     group=groupSession)

manualTZ = input.string("America/Chicago", "Zona horaria manual", group=groupSession)

activeTZ =
     timezoneMode == "America/Chicago" ? "America/Chicago" :
     timezoneMode == "America/New_York" ? "America/New_York" :
     timezoneMode == "Exchange" ? syminfo.timezone :
     manualTZ

showTradeBg = input.bool(true, "Mostrar fondo horario 7-11", group=groupSession)
showLondonBg = input.bool(true, "Mostrar fondo Londres", group=groupSession)
showDayLine = input.bool(true, "Línea separadora 00:00", group=groupSession)

tradeBgColor = input.color(color.new(color.rgb(120, 120, 140), 88), "Color horario 7-11", group=groupSession)
londonBgColor = input.color(color.new(color.rgb(70, 95, 78), 82), "Color Londres", group=groupSession)
dayLineColor = input.color(color.rgb(5, 45, 25), "Color línea 00:00", group=groupSession)
dayLineWidth = input.int(2, "Grosor línea 00:00", minval=1, maxval=5, group=groupSession)

inTradeSession = not na(time(timeframe.period, tradeSession, activeTZ))
inLondon = not na(time(timeframe.period, londonSession, activeTZ))

bgcolor(showLondonBg and inLondon ? londonBgColor : na, title="Zona Londres")
bgcolor(showTradeBg and inTradeSession ? tradeBgColor : na, title="Horario 7-11")

dayKey = year(time, activeTZ) * 10000 + month(time, activeTZ) * 100 + dayofmonth(time, activeTZ)
newDayAtTZ = barstate.isfirst or dayKey != dayKey[1]

var line[] dayLines = array.new_line()
atrDayLine = ta.atr(14)

if showDayLine and newDayAtTZ
    dl = line.new(
         bar_index,
         low - atrDayLine * 40.0,
         bar_index,
         high + atrDayLine * 40.0,
         xloc=xloc.bar_index,
         extend=extend.both,
         color=dayLineColor,
         width=dayLineWidth)

    array.push(dayLines, dl)

    while array.size(dayLines) > 40
        line.delete(array.shift(dayLines))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 01. NIVELES - NO TOCAR LÓGICA BASE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupLevels = "01. Niveles originales"

showKeyLevels = input.bool(true, "Mostrar niveles morados", group=groupLevels)
swingLen = input.int(10, "SwingLen niveles originales", minval=2, maxval=30, group=groupLevels)
maxLevels = input.int(5, "Máximo niveles visibles", minval=3, maxval=20, group=groupLevels)
levelLabelOffset = input.int(5, "Distancia label precio", minval=1, maxval=30, group=groupLevels)

purple = input.color(color.rgb(123, 71, 255), "Color nivel", group=groupLevels)
levelWidth = input.int(2, "Grosor nivel", minval=1, maxval=5, group=groupLevels)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 02. PANEL STRUCTURE MASTER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupTrend = "02. Panel Structure Master"

trendMode = input.string(
     "AUTO 1m=45m / 5m=1h45m",
     "Temporalidad maestra",
     options=["AUTO 1m=45m / 5m=1h45m", "Manual"],
     group=groupTrend)

manualTrendTF = input.timeframe("60", "Temporalidad manual", group=groupTrend)

chartTfSecRaw = timeframe.in_seconds(timeframe.period)
chartTfSec = na(chartTfSecRaw) ? 60 : chartTfSecRaw

autoTrendTF =
     chartTfSec <= 60 ? "45" :
     chartTfSec <= 300 ? "105" :
     manualTrendTF

activeTrendTF = trendMode == "AUTO 1m=45m / 5m=1h45m" ? autoTrendTF : manualTrendTF

trendTfText =
     activeTrendTF == "45" ? "45m" :
     activeTrendTF == "105" ? "1h45m" :
     activeTrendTF

htfPivotLen = input.int(2, "Pivots estructura HTF", minval=1, maxval=10, group=groupTrend)
localPivotLen = input.int(5, "Pivots estructura local", minval=2, maxval=20, group=groupTrend)

atrLen = input.int(14, "ATR estructura", minval=5, maxval=100, group=groupTrend)
swingBufferATR = input.float(0.05, "Filtro HH/HL/LH/LL ATR", step=0.01, group=groupTrend)
bosBufferATR = input.float(0.03, "Filtro ruptura BOS ATR", step=0.01, group=groupTrend)

dailyContextOn = input.bool(true, "Usar día anterior / 4D como contexto", group=groupTrend)
londonContextOn = input.bool(true, "Usar Londres anterior como contexto", group=groupTrend)

showPanel = input.bool(true, "Mostrar panel", group=groupTrend)
panelPosition = input.string("Arriba derecha", "Posición panel", options=["Arriba derecha", "Arriba izquierda", "Abajo derecha", "Abajo izquierda"], group=groupTrend)

bullColor = input.color(color.rgb(0, 130, 255), "Color SOLO BUY", group=groupTrend)
bearColor = input.color(color.rgb(255, 170, 0), "Color SOLO SELL", group=groupTrend)
neutralColor = input.color(color.rgb(35, 38, 50), "Color NO TRADE", group=groupTrend)
warningColor = input.color(color.rgb(170, 80, 20), "Color cambio posible", group=groupTrend)
offColor = input.color(color.rgb(80, 80, 90), "Color fuera de horario", group=groupTrend)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 03. RANGO DE LONDRES ANTERIOR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
wasInLondon = inLondon[1] == true
londonStart = inLondon and not wasInLondon
londonEnd = not inLondon and wasInLondon

var float currLondonHigh = na
var float currLondonLow = na
var float prevLondonHigh = na
var float prevLondonLow = na
var float prevLondonMid = na

if londonStart
    currLondonHigh := high
    currLondonLow := low

if inLondon
    currLondonHigh := na(currLondonHigh) ? high : math.max(currLondonHigh, high)
    currLondonLow := na(currLondonLow) ? low : math.min(currLondonLow, low)

if londonEnd
    prevLondonHigh := currLondonHigh
    prevLondonLow := currLondonLow
    prevLondonMid := (prevLondonHigh + prevLondonLow) / 2.0

londonDir =
     not londonContextOn ? 0 :
     not na(prevLondonHigh) and close > prevLondonHigh ? 1 :
     not na(prevLondonLow) and close < prevLondonLow ? -1 :
     not na(prevLondonMid) and close > prevLondonMid ? 1 :
     not na(prevLondonMid) and close < prevLondonMid ? -1 :
     0

londonText =
     not londonContextOn ? "OFF" :
     na(prevLondonHigh) ? "SIN LONDRES" :
     close > prevLondonHigh ? "SOBRE HIGH LON" :
     close < prevLondonLow ? "BAJO LOW LON" :
     close > prevLondonMid ? "ARRIBA MID LON" :
     close < prevLondonMid ? "ABAJO MID LON" :
     "DENTRO LON"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 04. FUNCIÓN DE ESTRUCTURA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_structureTrend(int pivLen) =>
    atr = ta.atr(atrLen)

    ph = ta.pivothigh(high, pivLen, pivLen)
    pl = ta.pivotlow(low, pivLen, pivLen)

    lastHigh = ta.valuewhen(not na(ph), ph, 0)
    prevHigh = ta.valuewhen(not na(ph), ph, 1)

    lastLow = ta.valuewhen(not na(pl), pl, 0)
    prevLow = ta.valuewhen(not na(pl), pl, 1)

    hasHighs = not na(lastHigh) and not na(prevHigh)
    hasLows = not na(lastLow) and not na(prevLow)

    hh = hasHighs and lastHigh > prevHigh + atr * swingBufferATR
    lh = hasHighs and lastHigh < prevHigh - atr * swingBufferATR

    hl = hasLows and lastLow > prevLow + atr * swingBufferATR
    ll = hasLows and lastLow < prevLow - atr * swingBufferATR

    bosUp = not na(lastHigh) and close[1] > lastHigh + atr * bosBufferATR
    bosDown = not na(lastLow) and close[1] < lastLow - atr * bosBufferATR

    bullScore = 0
    bearScore = 0

    bullScore += hl ? 3 : 0
    bearScore += lh ? 3 : 0

    bullScore += hh ? 2 : 0
    bearScore += ll ? 2 : 0

    bullScore += bosUp ? 3 : 0
    bearScore += bosDown ? 3 : 0

    midStruct = not na(lastHigh) and not na(lastLow) ? (lastHigh + lastLow) / 2.0 : na

    bullScore += not na(midStruct) and close[1] > midStruct ? 1 : 0
    bearScore += not na(midStruct) and close[1] < midStruct ? 1 : 0

    dir =
         bullScore >= 5 and bullScore >= bearScore + 2 ? 1 :
         bearScore >= 5 and bearScore >= bullScore + 2 ? -1 :
         0

    possibleUp = hl and not bosUp
    possibleDown = lh and not bosDown

    confirmedUp = hl and bosUp
    confirmedDown = lh and bosDown

    [dir, bullScore, bearScore, hh, hl, lh, ll, bosUp, bosDown, possibleUp, possibleDown, confirmedUp, confirmedDown, lastHigh, lastLow]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 05. CONTEXTO DIARIO / 4D
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_dailyContext() =>
    c1 = close[1]
    o1 = open[1]
    h1 = high[1]
    l1 = low[1]
    mid1 = (h1 + l1) / 2.0

    c4 = close[5]
    emaD = ta.ema(close, 5)[1]

    bullScore = 0
    bearScore = 0

    bullScore += c1 > o1 ? 1 : 0
    bearScore += c1 < o1 ? 1 : 0

    bullScore += c1 > mid1 ? 1 : 0
    bearScore += c1 < mid1 ? 1 : 0

    bullScore += c1 > c4 ? 1 : 0
    bearScore += c1 < c4 ? 1 : 0

    bullScore += c1 > emaD ? 1 : 0
    bearScore += c1 < emaD ? 1 : 0

    dir =
         bullScore >= 3 and bullScore > bearScore ? 1 :
         bearScore >= 3 and bearScore > bullScore ? -1 :
         0

    [dir, bullScore, bearScore, h1, l1, mid1]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 06. PEDIR ESTRUCTURA HTF + CALCULAR LOCAL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[htfDir, htfBull, htfBear, htfHH, htfHL, htfLH, htfLL, htfBosUp, htfBosDown, htfPossibleUp, htfPossibleDown, htfConfirmedUp, htfConfirmedDown, htfLastHigh, htfLastLow] =
     request.security(
         syminfo.tickerid,
         activeTrendTF,
         f_structureTrend(htfPivotLen),
         barmerge.gaps_off,
         barmerge.lookahead_off)

[localDir, localBull, localBear, localHH, localHL, localLH, localLL, localBosUp, localBosDown, localPossibleUp, localPossibleDown, localConfirmedUp, localConfirmedDown, localLastHigh, localLastLow] =
     f_structureTrend(localPivotLen)

[dailyDirRaw, dailyBull, dailyBear, prevDayHigh, prevDayLow, prevDayMid] =
     request.security(
         syminfo.tickerid,
         "D",
         f_dailyContext(),
         barmerge.gaps_off,
         barmerge.lookahead_off)

dailyDir = dailyContextOn ? dailyDirRaw : 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 07. MOTOR MAESTRO DE DECISIÓN
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
masterBull = 0
masterBear = 0

// La estructura HTF manda.
masterBull += htfDir == 1 ? 5 : 0
masterBear += htfDir == -1 ? 5 : 0

// La estructura local sirve para detectar reversa temprano.
masterBull += localDir == 1 ? 3 : 0
masterBear += localDir == -1 ? 3 : 0

// Día/4D como contexto, no como gatillo principal.
masterBull += dailyDir == 1 ? 2 : 0
masterBear += dailyDir == -1 ? 2 : 0

// Londres como filtro de zona.
masterBull += londonDir == 1 ? 1 : 0
masterBear += londonDir == -1 ? 1 : 0

baseDir =
     masterBull >= 6 and masterBull >= masterBear + 2 ? 1 :
     masterBear >= 6 and masterBear >= masterBull + 2 ? -1 :
     0

// Reversa temprana.
// Si veníamos buscando SELL y aparece HL local, cuidado.
// Si veníamos buscando BUY y aparece LH local, cuidado.
possibleBullReversal =
     htfDir == -1 and
     (
         localPossibleUp or
         localConfirmedUp or
         localDir == 1 or
         (not na(prevLondonHigh) and close > prevLondonHigh)
     )

possibleBearReversal =
     htfDir == 1 and
     (
         localPossibleDown or
         localConfirmedDown or
         localDir == -1 or
         (not na(prevLondonLow) and close < prevLondonLow)
     )

confirmedBullFlip =
     htfDir == -1 and
     localConfirmedUp and
     (
         close > htfLastHigh or
         close > prevLondonHigh or
         dailyDir != -1
     )

confirmedBearFlip =
     htfDir == 1 and
     localConfirmedDown and
     (
         close < htfLastLow or
         close < prevLondonLow or
         dailyDir != 1
     )

warningReversal =
     (possibleBullReversal and not confirmedBullFlip) or
     (possibleBearReversal and not confirmedBearFlip)

finalDir =
     confirmedBullFlip ? 1 :
     confirmedBearFlip ? -1 :
     warningReversal ? 0 :
     baseDir

// Fuera de horario no cambia la lectura, solo cambia la acción.
actionText =
     not inTradeSession ? "FUERA HORARIO" :
     warningReversal ? "NO TRADE" :
     finalDir == 1 ? "SOLO BUY" :
     finalDir == -1 ? "SOLO SELL" :
     "NO TRADE"

biasText =
     finalDir == 1 ? "ALCISTA" :
     finalDir == -1 ? "BAJISTA" :
     warningReversal ? "CAMBIO POSIBLE" :
     "NEUTRAL"

stateText =
     confirmedBullFlip ? "REVERSA BUY CONFIRMADA" :
     confirmedBearFlip ? "REVERSA SELL CONFIRMADA" :
     possibleBullReversal ? "POSIBLE REVERSA BUY" :
     possibleBearReversal ? "POSIBLE REVERSA SELL" :
     finalDir == 1 ? "BUY PERMITIDO" :
     finalDir == -1 ? "SELL PERMITIDO" :
     "ESPERAR"

panelColor =
     not inTradeSession ? offColor :
     warningReversal ? warningColor :
     finalDir == 1 ? bullColor :
     finalDir == -1 ? bearColor :
     neutralColor

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 08. NIVELES ORIGINALES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
phLevel = ta.pivothigh(high, swingLen, swingLen)
plLevel = ta.pivotlow(low, swingLen, swingLen)

var float[] keyPrices = array.new_float()
var line[] keyLines = array.new_line()
var label[] keyLabels = array.new_label()

f_addKeyLevel(float price) =>
    if showKeyLevels
        ln = line.new(
             bar_index - swingLen,
             price,
             bar_index + 1,
             price,
             xloc=xloc.bar_index,
             extend=extend.right,
             color=purple,
             width=levelWidth)

        lb = label.new(
             bar_index + levelLabelOffset,
             price,
             str.tostring(price, format.mintick),
             xloc=xloc.bar_index,
             style=label.style_label_left,
             color=purple,
             textcolor=color.white,
             size=size.tiny)

        array.push(keyPrices, price)
        array.push(keyLines, ln)
        array.push(keyLabels, lb)

        while array.size(keyLines) > maxLevels
            line.delete(array.shift(keyLines))
            label.delete(array.shift(keyLabels))
            array.shift(keyPrices)

if not na(phLevel)
    f_addKeyLevel(phLevel)

if not na(plLevel)
    f_addKeyLevel(plLevel)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 09. ACTUALIZAR LABELS DE NIVELES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if array.size(keyLabels) > 0
    for i = 0 to array.size(keyLabels) - 1
        p = array.get(keyPrices, i)
        lb = array.get(keyLabels, i)
        ln = array.get(keyLines, i)

        label.set_x(lb, bar_index + levelLabelOffset)
        label.set_y(lb, p)
        label.set_text(lb, str.tostring(p, format.mintick))
        label.set_color(lb, purple)

        line.set_color(ln, purple)
        line.set_width(ln, levelWidth)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 10. PANEL SIMPLE Y CERTERO
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
panelPos =
     panelPosition == "Arriba derecha" ? position.top_right :
     panelPosition == "Arriba izquierda" ? position.top_left :
     panelPosition == "Abajo derecha" ? position.bottom_right :
     position.bottom_left

var table panel = table.new(panelPos, 2, 8, border_width=1, border_color=color.new(purple, 30))

if showPanel and barstate.islast
    bg = color.new(color.rgb(10, 12, 20), 5)
    bg2 = color.new(color.rgb(25, 28, 42), 5)

    htfText =
         htfDir == 1 ? "BUY" :
         htfDir == -1 ? "SELL" :
         "NEUTRAL"

    localText =
         localDir == 1 ? "BUY" :
         localDir == -1 ? "SELL" :
         "NEUTRAL"

    dailyText =
         not dailyContextOn ? "OFF" :
         dailyDir == 1 ? "BUY" :
         dailyDir == -1 ? "SELL" :
         "NEUTRAL"

    table.cell(panel, 0, 0, "ORANIU", text_color=color.white, bgcolor=bg, text_size=size.small)
    table.cell(panel, 1, 0, "STRUCTURE MASTER", text_color=color.rgb(0, 220, 255), bgcolor=bg, text_size=size.small)

    table.cell(panel, 0, 1, "Acción", text_color=color.silver, bgcolor=bg2, text_size=size.tiny)
    table.cell(panel, 1, 1, actionText, text_color=color.white, bgcolor=panelColor, text_size=size.small)

    table.cell(panel, 0, 2, "Bias", text_color=color.silver, bgcolor=bg2, text_size=size.tiny)
    table.cell(panel, 1, 2, biasText, text_color=color.white, bgcolor=panelColor, text_size=size.tiny)

    table.cell(panel, 0, 3, "Estado", text_color=color.silver, bgcolor=bg2, text_size=size.tiny)
    table.cell(panel, 1, 3, stateText, text_color=color.white, bgcolor=panelColor, text_size=size.tiny)

    table.cell(panel, 0, 4, "HTF " + trendTfText, text_color=color.silver, bgcolor=bg2, text_size=size.tiny)
    table.cell(panel, 1, 4, htfText + " " + str.tostring(htfBull) + "/" + str.tostring(htfBear), text_color=color.white, bgcolor=bg2, text_size=size.tiny)

    table.cell(panel, 0, 5, "Local", text_color=color.silver, bgcolor=bg2, text_size=size.tiny)
    table.cell(panel, 1, 5, localText + " " + str.tostring(localBull) + "/" + str.tostring(localBear), text_color=color.white, bgcolor=bg2, text_size=size.tiny)

    table.cell(panel, 0, 6, "Día/Londres", text_color=color.silver, bgcolor=bg2, text_size=size.tiny)
    table.cell(panel, 1, 6, dailyText + " | " + londonText, text_color=color.white, bgcolor=bg2, text_size=size.tiny)

    table.cell(panel, 0, 7, "Master", text_color=color.silver, bgcolor=bg2, text_size=size.tiny)
    table.cell(panel, 1, 7, str.tostring(masterBull) + " / " + str.tostring(masterBear), text_color=color.white, bgcolor=bg2, text_size=size.tiny)
````
