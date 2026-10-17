# STX Intraday - War Room v2

- url: https://www.tradingview.com/script/XVW5dRJa/
- type: indicator
- pine_id: PUB;20187771bae1443c8fc301493d5240d6
- version: 1.0

## Description

STX Intraday — War Room

  El panel de la sala de mercados STX Desk, en tu gráfico de XAUUSD.

  War Room es la herramienta de análisis intradía que usa el equipo STX Desk para leer el oro en tiempo real. Reúne en un solo panel
  todo el contexto de una operación —bias, estructura, zonas y gatillo de entrada— para que veas cómo se construye una decisión, paso
  a paso, igual que en la sala.

  ¿Qué muestra?

  - Bias multi-temporal. Lee la dirección en H4, H1 y M15 a la vez y resume el sesgo dominante del día.
  - Zonas OTE + Fibonacci. Marca la zona de entrada óptima (0.618–0.786) y proyecta los objetivos por extensión (1.618 / 2.0 / 2.618)
  con buffer de broker.
  - Detección de estructura. Pivotes, doble techo / doble suelo y barridos de liquidez (ICT) sobre el rango reciente.
  - Order Block M15. Identifica el bloque de origen tras un desplazamiento con cuerpo dominante.
  - Sniper M5 / M1. Afina el gatillo de entrada con confirmaciones y mecha de rechazo mínimas.
  - Panel «MARKET STATE». Un tablero que resume el estado del mercado y los niveles activos (PDH, PDL, Asian High, entrada OTE).
  - Plan de operación completo. Cada lectura se expresa con entrada, invalidación (SL por ATR) y TP1/TP2/TP3 — un plan, no una flecha
  suelta.

  Para quién

  Para el trader que ya domina las bases y quiere operar el oro con el mismo marco que la sala STX Desk. Es el corazón del programa
  Pro.

  ▎ Herramienta de apoyo a la decisión y estudio; no constituye recomendación de inversión ni garantiza resultados. El trading
  ▎ implica riesgo de pérdida de capital.

## Source Code

````pine
//@version=6
indicator("STX Intraday - War Room v2", overlay = true, max_boxes_count = 80, max_lines_count = 220, max_labels_count = 120)

grpTF = "Multi-TF Bias"
lenFast = input.int(21, "Fast EMA", group = grpTF)
lenSlow = input.int(55, "Slow EMA", group = grpTF)
grpFib = "Fibonacci / TP"
oteLow = input.float(0.618, "OTE Low", group = grpFib, step = 0.001)
oteHigh = input.float(0.786, "OTE High", group = grpFib, step = 0.001)
ext1 = input.float(1.618, "Ext TP1", group = grpFib, step = 0.001)
ext2 = input.float(2.0, "Ext TP2", group = grpFib, step = 0.001)
ext3 = input.float(2.618, "Ext TP3", group = grpFib, step = 0.001)
legMin = input.float(8.0, "Min leg clamp $", group = grpFib)
legMax = input.float(18.0, "Max leg clamp $", group = grpFib)
buffer = input.float(2.0, "Broker buffer $", group = grpFib)
lotSize = input.float(0.10, "Alert lot", group = grpFib, minval = 0.01, step = 0.01)
grpStr = "Structure / Detection"
pivLen = input.int(8, "Pivots", group = grpStr)
dtTol = input.float(2.0, "Double top/bottom tolerance $", group = grpStr)
msSweepTol = input.float(1.0, "ICT sweep tolerance $", group = grpStr, minval = 0.0, step = 0.1)
msLookback = input.int(40, "ICT liquidity lookback", group = grpStr, minval = 5, maxval = 300)
grpOB = "Order Block M15"
showOB = input.bool(true, "Show OB", group = grpOB)
obDispRatio = input.float(0.60, "Displacement body/range", group = grpOB, minval = 0.40, maxval = 0.90, step = 0.05)
grpSniper = "Sniper M5/M1"
sniperMin = input.int(2, "Min confirmations", group = grpSniper, minval = 1, maxval = 4)
rejectRatio = input.float(0.45, "Min rejection wick", group = grpSniper, minval = 0.10, maxval = 0.90, step = 0.05)
grpUI = "Display"
showTbl = input.bool(true, "MARKET STATE Panel", group = grpUI)
showOTE = input.bool(true, "OTE Zone", group = grpUI)
showTP = input.bool(true, "TP Levels", group = grpUI)
macroOn = input.bool(false, "MACRO active -> blocked", group = grpUI)

f_dirExpr() => math.sign(ta.ema(close, lenFast) - ta.ema(close, lenSlow))
f_txt(v) => v > 0 ? "UP" : v < 0 ? "DOWN" : "--"
f_col(v) => v > 0 ? color.new(color.green, 0) : v < 0 ? color.new(color.red, 0) : color.new(color.gray, 0)
f_bodyRatio(o, h, l, c) => h > l ? math.abs(c - o) / (h - l) : 0.0
f_json(id, direction, entry, sl, a, b, c, lot) => "{\"id\":\"" + id + "\",\"ts\":" + str.tostring(time) + ",\"symbol\":\"XAUUSD\",\"direction\":\"" + direction + "\",\"entry\":" + str.tostring(entry, format.mintick) + ",\"sl\":" + str.tostring(sl, format.mintick) + ",\"tp1\":" + str.tostring(a, format.mintick) + ",\"tp2\":" + str.tostring(b, format.mintick) + ",\"tp3\":" + str.tostring(c, format.mintick) + ",\"lot\":" + str.tostring(lot) + "}"

dir4H = request.security(syminfo.tickerid, "240", f_dirExpr(), lookahead = barmerge.lookahead_off)
dir1H = request.security(syminfo.tickerid, "60", f_dirExpr(), lookahead = barmerge.lookahead_off)
dir15 = request.security(syminfo.tickerid, "15", f_dirExpr(), lookahead = barmerge.lookahead_off)
dir5 = request.security(syminfo.tickerid, "5", f_dirExpr(), lookahead = barmerge.lookahead_off)
htfSum = dir4H + dir1H + dir15
regime = htfSum > 0 ? 1 : htfSum < 0 ? -1 : 0
biasFull = (dir4H == dir1H and dir1H == dir15 and dir4H != 0) ? dir4H : 0
dxyRaw = request.security("TVC:DXY", "240", f_dirExpr(), lookahead = barmerge.lookahead_off)
dxyDir = na(dxyRaw) ? 0 : -dxyRaw

ph = ta.pivothigh(high, pivLen, pivLen)
pl = ta.pivotlow(low, pivLen, pivLen)
var float lastPH = na
var float prevPH = na
var float lastPL = na
var float prevPL = na
if not na(ph)
    prevPH := lastPH
    lastPH := ph
if not na(pl)
    prevPL := lastPL
    lastPL := pl
hh = not na(lastPH) and not na(prevPH) and lastPH > prevPH
hl = not na(lastPL) and not na(prevPL) and lastPL > prevPL
lh = not na(lastPH) and not na(prevPH) and lastPH < prevPH
ll = not na(lastPL) and not na(prevPL) and lastPL < prevPL
var int structDir = 0
structDir := (hh and hl) ? 1 : (lh and ll) ? -1 : structDir
[_dip, _dim, adxv] = ta.dmi(14, 14)
rangeOn = adxv < 20
doubleTop = not na(lastPH) and not na(prevPH) and math.abs(lastPH - prevPH) <= dtTol
doubleBot = not na(lastPL) and not na(prevPL) and math.abs(lastPL - prevPL) <= dtTol

var int msTrend = 0
var float msProtHigh = na
var float msProtLow = na
var string msLastEventTxt = "--"
var int msLastEventDir = 0
var label msLbl = na
var line msSweepLine = na
var label msSweepLbl = na
var int msLastSweepDir = 0
var int msLastSweepBar = na

if msTrend == 0
    if hh and hl
        msTrend := 1
        msProtLow := lastPL
        msProtHigh := lastPH
    if lh and ll
        msTrend := -1
        msProtHigh := lastPH
        msProtLow := lastPL
if not na(pl) and msTrend >= 0
    msProtLow := pl
if not na(ph) and msTrend <= 0
    msProtHigh := ph

msBosBuy = msTrend == 1 and not na(lastPH) and close > lastPH and close[1] <= lastPH
msBosSell = msTrend == -1 and not na(lastPL) and close < lastPL and close[1] >= lastPL
msChochSell = msTrend == 1 and not na(msProtLow) and close < msProtLow and close[1] >= msProtLow
msChochBuy = msTrend == -1 and not na(msProtHigh) and close > msProtHigh and close[1] <= msProtHigh
msHasEvent = false
float msBreakLevel = na
int msEventDir = 0
string msEventKind = ""
if msChochSell
    msHasEvent := true
    msBreakLevel := msProtLow
    msEventDir := -1
    msEventKind := "CHoCH"
    msTrend := -1
    msProtHigh := lastPH
    msProtLow := lastPL
else if msChochBuy
    msHasEvent := true
    msBreakLevel := msProtHigh
    msEventDir := 1
    msEventKind := "CHoCH"
    msTrend := 1
    msProtLow := lastPL
    msProtHigh := lastPH
else if msBosBuy
    msHasEvent := true
    msBreakLevel := lastPH
    msEventDir := 1
    msEventKind := "BOS"
    msProtLow := lastPL
else if msBosSell
    msHasEvent := true
    msBreakLevel := lastPL
    msEventDir := -1
    msEventKind := "BOS"
    msProtHigh := lastPH

if msHasEvent and barstate.isconfirmed
    msEventSide = msEventDir > 0 ? " BUY" : " SELL"
    msLastEventTxt := msEventKind + msEventSide
    msLastEventDir := msEventDir
    msLblStyle = msEventDir > 0 ? label.style_label_up : label.style_label_down
    msLblColor = msEventKind == "CHoCH" ? color.new(color.orange, 0) : color.new(color.blue, 10)
    msLblText = msEventKind + msEventSide
    msLbl := label.new(bar_index, msBreakLevel, msLblText, style = msLblStyle, color = msLblColor, textcolor = color.white, size = size.small)

msEqHighLevel = ta.highest(high[1], msLookback)
msEqLowLevel = ta.lowest(low[1], msLookback)
int msEqHighCount = 0
int msEqLowCount = 0
for msI = 1 to msLookback
    if not na(high[msI]) and not na(msEqHighLevel) and math.abs(high[msI] - msEqHighLevel) <= msSweepTol
        msEqHighCount += 1
    if not na(low[msI]) and not na(msEqLowLevel) and math.abs(low[msI] - msEqLowLevel) <= msSweepTol
        msEqLowCount += 1
msHasEqHigh = msEqHighCount >= 2
msHasEqLow = msEqLowCount >= 2
msBslSweep = msHasEqHigh and not na(msEqHighLevel) and high > msEqHighLevel and close < msEqHighLevel
msSslSweep = msHasEqLow and not na(msEqLowLevel) and low < msEqLowLevel and close > msEqLowLevel
msSweepHit = msBslSweep or msSslSweep
float msSweepLevel = na
int msSweepDir = 0
if msBslSweep
    msSweepLevel := msEqHighLevel
    msSweepDir := -1
else if msSslSweep
    msSweepLevel := msEqLowLevel
    msSweepDir := 1
if msSweepHit and barstate.isconfirmed
    msLastSweepDir := msSweepDir
    msLastSweepBar := bar_index
    msSweepText = msSweepDir > 0 ? "SWEEP SSL BUY" : "SWEEP BSL SELL"
    msSweepStyle = msSweepDir > 0 ? label.style_label_up : label.style_label_down
    msSweepColor = msSweepDir > 0 ? color.new(color.green, 0) : color.new(color.red, 0)
    msSweepX1 = bar_index - 1
    msSweepX2 = bar_index + 8
    msSweepLine := line.new(msSweepX1, msSweepLevel, msSweepX2, msSweepLevel, color = msSweepColor, width = 1)
    msSweepLbl := label.new(bar_index, msSweepLevel, msSweepText, style = msSweepStyle, color = msSweepColor, textcolor = color.white, size = size.tiny)

msSweepRecent = not na(msLastSweepBar) and bar_index - msLastSweepBar <= msLookback
msRevBuy = msChochBuy and msSweepRecent and msLastSweepDir == 1
msRevSell = msChochSell and msSweepRecent and msLastSweepDir == -1

swingHigh = lastPH
swingLow = lastPL
hasSwing = not na(swingHigh) and not na(swingLow) and swingHigh > swingLow
amplitude = hasSwing ? swingHigh - swingLow : na
leg = hasSwing ? math.min(math.max(amplitude, legMin), legMax) : na
setupDir = biasFull
oteA = hasSwing ? swingHigh - amplitude * oteLow : na
oteB = hasSwing ? swingHigh - amplitude * oteHigh : na
oteTop = hasSwing ? math.max(oteA, oteB) : na
oteBot = hasSwing ? math.min(oteA, oteB) : na
entryPx = hasSwing ? (oteA + oteB) / 2.0 : na
float tp1 = na
float tp2 = na
float tp3 = na
if hasSwing and setupDir != 0
    if setupDir > 0
        tp1 := entryPx + leg * ext1 - buffer
        tp2 := entryPx + leg * ext2 - buffer
        tp3 := entryPx + leg * ext3 - buffer
    else
        tp1 := entryPx - leg * ext1 + buffer
        tp2 := entryPx - leg * ext2 + buffer
        tp3 := entryPx - leg * ext3 + buffer
inOTE = hasSwing and low <= oteTop and high >= oteBot
baseLong = setupDir > 0 and inOTE and structDir >= 0 and not macroOn and not rangeOn
baseShort = setupDir < 0 and inOTE and structDir <= 0 and not macroOn and not rangeOn

f_m15OB() =>
    var float bullTop = na
    var float bullBot = na
    var int bullTime = na
    var float bearTop = na
    var float bearBot = na
    var int bearTime = na
    r = high > low ? math.abs(close - open) / (high - low) : 0.0
    bullDisp = close > open and r >= obDispRatio and close > high[1]
    bearDisp = close < open and r >= obDispRatio and close < low[1]
    if bullDisp and close[1] < open[1]
        bullTop := high[1]
        bullBot := low[1]
        bullTime := time[1]
    if bearDisp and close[1] > open[1]
        bearTop := high[1]
        bearBot := low[1]
        bearTime := time[1]
    [bullTop, bullBot, bullTime, bearTop, bearBot, bearTime]
[obBullTop, obBullBot, obBullTime, obBearTop, obBearBot, obBearTime] = request.security(syminfo.tickerid, "15", f_m15OB(), lookahead = barmerge.lookahead_off)

var bool bullArmed = false
var bool bearArmed = false
var int bullArmedTime = na
var int bearArmedTime = na
newBullOB = not na(obBullTime) and obBullTime != obBullTime[1]
newBearOB = not na(obBearTime) and obBearTime != obBearTime[1]
if newBullOB
    bullArmed := false
if newBearOB
    bearArmed := false
if not na(obBullTop) and close > obBullTop
    bullArmed := true
    bullArmedTime := time
if not na(obBearBot) and close < obBearBot
    bearArmed := true
    bearArmedTime := time
bullTouch = bullArmed and not na(obBullTop) and low <= obBullTop and high >= obBullBot
bearTouch = bearArmed and not na(obBearTop) and high >= obBearBot and low <= obBearTop
bullReject = bullTouch and close > open and low <= obBullTop and (math.min(open, close) - low) >= (high - low) * rejectRatio
bearReject = bearTouch and close < open and high >= obBearBot and (high - math.max(open, close)) >= (high - low) * rejectRatio

[o1, h1, lowL, c1] = request.security_lower_tf(syminfo.tickerid, "1", [open, high, low, close], ignore_invalid_timeframe = true)
int m1Count = array.size(c1)
bool confDisp = false
bool confFvg = false
bool confRetest = false
bool confShift = false
bool oppDisp = false
if setupDir != 0 and m1Count >= 3
    float priorHigh = array.get(h1, 0)
    float priorLow = array.get(lowL, 0)
    for i = 0 to m1Count - 1
        float o = array.get(o1, i)
        float h = array.get(h1, i)
        float l = array.get(lowL, i)
        float c = array.get(c1, i)
        float ratio = f_bodyRatio(o, h, l, c)
        bool upDisp = c > o and ratio > 0.60
        bool dnDisp = c < o and ratio > 0.60
        bool bullFvg = i >= 2 and l > array.get(h1, i - 2)
        bool bearFvg = i >= 2 and h < array.get(lowL, i - 2)
        bool retestZone = setupDir > 0 ? bullTouch : bearTouch
        bool bullShift = c > priorHigh
        bool bearShift = c < priorLow
        confDisp := confDisp or (setupDir > 0 and upDisp) or (setupDir < 0 and dnDisp)
        confFvg := confFvg or (setupDir > 0 and bullFvg) or (setupDir < 0 and bearFvg)
        confRetest := confRetest or retestZone
        confShift := confShift or (setupDir > 0 and bullShift) or (setupDir < 0 and bearShift)
        oppDisp := oppDisp or (setupDir > 0 and dnDisp) or (setupDir < 0 and upDisp)
        priorHigh := math.max(priorHigh, h)
        priorLow := math.min(priorLow, l)
rawConf = (confDisp ? 1 : 0) + (confFvg ? 1 : 0) + (confRetest ? 1 : 0) + (confShift ? 1 : 0)
sniperScore = math.max(rawConf - (oppDisp ? 1 : 0), 0)
sniperConfirm = setupDir != 0 and dir5 == setupDir and sniperScore >= sniperMin
sniperText = sniperConfirm ? "CONFIRM " + str.tostring(sniperScore) + "/4" : "WAIT " + str.tostring(sniperScore) + "/4"
sniperBg = sniperConfirm ? color.new(color.green, 0) : color.new(color.orange, 0)

longSig = baseLong and bullReject and sniperConfirm
shortSig = baseShort and bearReject and sniperConfirm

var int openDir = 0
var float openEntry = na
var float openTp1 = na
var float openTp2 = na
var float openTp3 = na
var float openSlInit = na
var bool beActive = false
var int tradesToday = 0
var float dailyPnL = 0.0
var int winsCount = 0
var int lossesCount = 0

statsNewDay = ta.change(time("D")) != 0
if statsNewDay
    tradesToday := 0
    dailyPnL := 0.0
    winsCount := 0
    lossesCount := 0

if openDir == 0 and longSig
    openDir := 1
    openEntry := close
    openTp1 := tp1
    openTp2 := tp2
    openTp3 := tp3
    openSlInit := oteBot - 2
    beActive := false
    tradesToday += 1
if openDir == 0 and shortSig
    openDir := -1
    openEntry := close
    openTp1 := tp1
    openTp2 := tp2
    openTp3 := tp3
    openSlInit := oteTop + 2
    beActive := false
    tradesToday += 1

statsTp1Dist = openDir != 0 and not na(openTp1) and not na(openEntry) ? math.abs(openTp1 - openEntry) : na
statsBeLevel = openDir != 0 and not na(statsTp1Dist) ? openEntry + openDir * statsTp1Dist * 0.70 : na
statsBeHit = openDir > 0 and not na(statsBeLevel) ? high >= statsBeLevel : openDir < 0 and not na(statsBeLevel) ? low <= statsBeLevel : false
if openDir != 0 and statsBeHit
    beActive := true
statsSlEff = openDir != 0 ? (beActive ? openEntry : openSlInit) : na
statsTp3Hit = openDir > 0 and not na(openTp3) ? high >= openTp3 : openDir < 0 and not na(openTp3) ? low <= openTp3 : false
statsSlHit = openDir > 0 and not na(statsSlEff) ? low <= statsSlEff : openDir < 0 and not na(statsSlEff) ? high >= statsSlEff : false
statsExitPx = statsSlHit ? statsSlEff : statsTp3Hit ? openTp3 : na
if openDir != 0 and (statsTp3Hit or statsSlHit)
    statsRealized = (statsExitPx - openEntry) * openDir * 100 * lotSize
    dailyPnL += statsRealized
    if statsRealized >= 0
        winsCount += 1
    else
        lossesCount += 1
    openDir := 0
    beActive := false

statsFloatPnL = openDir != 0 ? (close - openEntry) * openDir * 100 * lotSize : 0.0
statsOpenTradeTxt = openDir > 0 ? "BUY @" + str.tostring(openEntry, format.mintick) : openDir < 0 ? "SELL @" + str.tostring(openEntry, format.mintick) : "--"
statsFloatTxt = str.tostring(statsFloatPnL, "#.##") + " USD"
statsTp1Txt = openDir != 0 ? str.tostring(openTp1, format.mintick) : "--"
statsTp2Txt = openDir != 0 ? str.tostring(openTp2, format.mintick) : "--"
statsTp3Txt = openDir != 0 ? str.tostring(openTp3, format.mintick) : "--"
statsSlTxt = openDir != 0 ? str.tostring(statsSlEff, format.mintick) : "--"
statsBeTxt = beActive ? "ACTIVE" : "OFF"
statsTradesTxt = str.tostring(tradesToday)
statsDailyTxt = str.tostring(dailyPnL, "#.##") + " USD"
statsWinLossTxt = str.tostring(winsCount) + " / " + str.tostring(lossesCount)
statsFloatBg = statsFloatPnL > 0 ? color.new(color.green, 0) : statsFloatPnL < 0 ? color.new(color.red, 0) : color.new(color.gray, 0)
statsDailyBg = dailyPnL > 0 ? color.new(color.green, 0) : dailyPnL < 0 ? color.new(color.red, 0) : color.new(color.gray, 0)
statsBeBg = beActive ? color.new(color.green, 0) : color.new(color.gray, 0)
plotshape(msRevBuy, title = "ICT REV BUY", style = shape.diamond, location = location.belowbar, color = color.new(color.orange, 0), size = size.tiny, text = "REV")
plotshape(msRevSell, title = "ICT REV SELL", style = shape.diamond, location = location.abovebar, color = color.new(color.orange, 0), size = size.tiny, text = "REV")
plotshape(longSig, title = "BUY OB RETEST", style = shape.triangleup, location = location.belowbar, color = color.new(color.lime, 0), size = size.small, text = "OB BUY")
plotshape(shortSig, title = "SELL OB RETEST", style = shape.triangledown, location = location.abovebar, color = color.new(color.red, 0), size = size.small, text = "OB SELL")
if sniperConfirm and barstate.isconfirmed
    labelY = setupDir > 0 ? low : high
    labelStyle = setupDir > 0 ? label.style_label_up : label.style_label_down
    labelCol = setupDir > 0 ? color.new(color.green, 0) : color.new(color.red, 0)
    labelTxt = "SNIPER CONFIRM " + str.tostring(sniperScore) + "/4"
    label.new(bar_index, labelY, labelTxt, style = labelStyle, color = labelCol, textcolor = color.white, size = size.small)

var box bullOBBox = na
var box bearOBBox = na
if barstate.islast and showOB
    box.delete(bullOBBox)
    box.delete(bearOBBox)
    if not na(obBullTop) and not na(obBullBot) and not na(obBullTime)
        bullOBBox := box.new(left = obBullTime, top = obBullTop, right = time, bottom = obBullBot, xloc = xloc.bar_time, extend = extend.right, border_color = color.new(color.green, 15), bgcolor = color.new(color.green, 88))
    if not na(obBearTop) and not na(obBearBot) and not na(obBearTime)
        bearOBBox := box.new(left = obBearTime, top = obBearTop, right = time, bottom = obBearBot, xloc = xloc.bar_time, extend = extend.right, border_color = color.new(color.red, 15), bgcolor = color.new(color.red, 88))

var box oteBox = na
var line l1 = na
var line l2 = na
var line l3 = na
var label lbE = na
if barstate.islast and showOTE and hasSwing
    box.delete(oteBox)
    oteBox := box.new(left = bar_index - 20, top = oteTop, right = bar_index + 8, bottom = oteBot, border_color = color.new(color.orange, 0), bgcolor = color.new(color.orange, 85))
if barstate.islast and showTP and hasSwing and setupDir != 0
    line.delete(l1)
    line.delete(l2)
    line.delete(l3)
    label.delete(lbE)
    l1 := line.new(bar_index, tp1, bar_index + 8, tp1, color = color.new(color.teal, 0), width = 1)
    l2 := line.new(bar_index, tp2, bar_index + 8, tp2, color = color.new(color.teal, 0), width = 1)
    l3 := line.new(bar_index, tp3, bar_index + 8, tp3, color = color.new(color.green, 0), width = 2)
    lbE := label.new(bar_index + 8, entryPx, "Entry " + str.tostring(entryPx, format.mintick), style = label.style_label_left, color = color.new(color.gray, 20), textcolor = color.white, size = size.small)

// Pre-calcul des ternaires (Pine v6 n'accepte pas un ternaire directement en argument)
regimeTxt = regime > 0 ? "BULLISH" : regime < 0 ? "BEARISH" : "NEUTRAL"
biasTxt   = biasFull > 0 ? "BUY" : biasFull < 0 ? "SELL" : "MIXED"
structTxt = structDir > 0 ? "UP" : structDir < 0 ? "DOWN" : "--"
rangeTxt  = rangeOn ? "YES" : "NO"
rangeBg   = rangeOn ? color.new(color.orange, 0) : color.new(color.green, 0)
dxyTxt    = na(dxyRaw) ? "--" : f_txt(dxyDir)
doubleTxt = doubleTop ? "TOP (SELL)" : doubleBot ? "BOTTOM (BUY)" : "--"
doubleBg  = doubleTop ? color.new(color.red, 0) : doubleBot ? color.new(color.green, 0) : color.new(color.gray, 0)
macroTxt  = macroOn ? "OFF (blocked)" : "ON"
macroBg   = macroOn ? color.new(color.red, 0) : color.new(color.green, 0)
msEventBg = msLastEventDir > 0 ? color.new(color.green, 0) : msLastEventDir < 0 ? color.new(color.red, 0) : color.new(color.gray, 0)
hdrBg     = color.new(color.black, 0)
rowBg     = color.new(color.black, 20)

if showTbl and barstate.islast
    var table t = table.new(position.top_right, 2, 13, border_width = 1, frame_color = color.new(color.gray, 40), frame_width = 1)
    table.cell(t, 0, 0, "MARKET STATE", text_color = color.white, bgcolor = hdrBg)
    table.cell(t, 1, 0, "LIVE", text_color = color.white, bgcolor = hdrBg)
    table.cell(t, 0, 1, "REGIME", text_color = color.white, bgcolor = rowBg)
    table.cell(t, 1, 1, regimeTxt, text_color = color.white, bgcolor = f_col(regime))
    table.cell(t, 0, 2, "BIAS", text_color = color.white, bgcolor = rowBg)
    table.cell(t, 1, 2, biasTxt, text_color = color.white, bgcolor = f_col(biasFull))
    table.cell(t, 0, 3, "4H", text_color = color.white, bgcolor = rowBg)
    table.cell(t, 1, 3, f_txt(dir4H), text_color = color.white, bgcolor = f_col(dir4H))
    table.cell(t, 0, 4, "1H", text_color = color.white, bgcolor = rowBg)
    table.cell(t, 1, 4, f_txt(dir1H), text_color = color.white, bgcolor = f_col(dir1H))
    table.cell(t, 0, 5, "15m", text_color = color.white, bgcolor = rowBg)
    table.cell(t, 1, 5, f_txt(dir15), text_color = color.white, bgcolor = f_col(dir15))
    table.cell(t, 0, 6, "STRUCTURE", text_color = color.white, bgcolor = rowBg)
    table.cell(t, 1, 6, structTxt, text_color = color.white, bgcolor = f_col(structDir))
    table.cell(t, 0, 7, "RANGE", text_color = color.white, bgcolor = rowBg)
    table.cell(t, 1, 7, rangeTxt, text_color = color.white, bgcolor = rangeBg)
    table.cell(t, 0, 8, "DXY", text_color = color.white, bgcolor = rowBg)
    table.cell(t, 1, 8, dxyTxt, text_color = color.white, bgcolor = f_col(dxyDir))
    table.cell(t, 0, 9, "DOUBLE", text_color = color.white, bgcolor = rowBg)
    table.cell(t, 1, 9, doubleTxt, text_color = color.white, bgcolor = doubleBg)
    table.cell(t, 0, 10, "SNIPER", text_color = color.white, bgcolor = rowBg)
    table.cell(t, 1, 10, sniperText, text_color = color.white, bgcolor = sniperBg)
    table.cell(t, 0, 11, "EVENT", text_color = color.white, bgcolor = rowBg)
    table.cell(t, 1, 11, msLastEventTxt, text_color = color.white, bgcolor = msEventBg)
    table.cell(t, 0, 12, "MACRO", text_color = color.white, bgcolor = rowBg)
    table.cell(t, 1, 12, macroTxt, text_color = color.white, bgcolor = macroBg)

if showTbl and barstate.islast
    var table t2 = table.new(position.bottom_right, 2, 11, border_width = 1, frame_color = color.new(color.gray, 40), frame_width = 1)
    table.cell(t2, 0, 0, "STATS", text_color = color.white, bgcolor = hdrBg)
    table.cell(t2, 1, 0, "TODAY", text_color = color.white, bgcolor = hdrBg)
    table.cell(t2, 0, 1, "OPEN TRADE", text_color = color.white, bgcolor = rowBg)
    table.cell(t2, 1, 1, statsOpenTradeTxt, text_color = color.white, bgcolor = rowBg)
    table.cell(t2, 0, 2, "FLOAT PNL", text_color = color.white, bgcolor = rowBg)
    table.cell(t2, 1, 2, statsFloatTxt, text_color = color.white, bgcolor = statsFloatBg)
    table.cell(t2, 0, 3, "TP1", text_color = color.white, bgcolor = rowBg)
    table.cell(t2, 1, 3, statsTp1Txt, text_color = color.white, bgcolor = rowBg)
    table.cell(t2, 0, 4, "TP2", text_color = color.white, bgcolor = rowBg)
    table.cell(t2, 1, 4, statsTp2Txt, text_color = color.white, bgcolor = rowBg)
    table.cell(t2, 0, 5, "TP3", text_color = color.white, bgcolor = rowBg)
    table.cell(t2, 1, 5, statsTp3Txt, text_color = color.white, bgcolor = rowBg)
    table.cell(t2, 0, 6, "SL", text_color = color.white, bgcolor = rowBg)
    table.cell(t2, 1, 6, statsSlTxt, text_color = color.white, bgcolor = rowBg)
    table.cell(t2, 0, 7, "BE", text_color = color.white, bgcolor = rowBg)
    table.cell(t2, 1, 7, statsBeTxt, text_color = color.white, bgcolor = statsBeBg)
    table.cell(t2, 0, 8, "TRADES TODAY", text_color = color.white, bgcolor = rowBg)
    table.cell(t2, 1, 8, statsTradesTxt, text_color = color.white, bgcolor = rowBg)
    table.cell(t2, 0, 9, "DAILY PNL", text_color = color.white, bgcolor = rowBg)
    table.cell(t2, 1, 9, statsDailyTxt, text_color = color.white, bgcolor = statsDailyBg)
    table.cell(t2, 0, 10, "WINS / LOSSES", text_color = color.white, bgcolor = rowBg)
    table.cell(t2, 1, 10, statsWinLossTxt, text_color = color.white, bgcolor = rowBg)

if longSig and barstate.isconfirmed
    alert(f_json(str.tostring(time) + "-BUY", "BUY", close, obBullBot, tp1, tp2, tp3, lotSize), alert.freq_once_per_bar_close)
if shortSig and barstate.isconfirmed
    alert(f_json(str.tostring(time) + "-SELL", "SELL", close, obBearTop, tp1, tp2, tp3, lotSize), alert.freq_once_per_bar_close)
alertcondition(longSig, "STX BUY", "STX Intraday v2 BUY OB break retest")
alertcondition(shortSig, "STX SELL", "STX Intraday v2 SELL OB break retest")
````
