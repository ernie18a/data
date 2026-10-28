# INSTITUTIONAL ALGO PRO X - FIXED

- url: https://www.tradingview.com/script/7CvYXNZc-INSTITUTIONAL-ALGO-PRO-X-FIXED/
- type: indicator
- pine_id: PUB;b2232fbf6dc045a7b4ab2fb358fb79fb
- version: 2.0

## Description

Multi-asset institutional trading indicator using EMA trend, ORB, BOS/CHoCH, Supply/Demand, VWAP, RSI and Delta/CVD proxy. Includes visual TP1/TP2/TP3 trade simulator, BE after TP1 and live dashboard for XAUUSD, BTCUSD and NASDAQ.

## Source Code

````pine
//@version=6
indicator(
     "INSTITUTIONAL ALGO PRO X - CLEAN VISUAL",
     overlay = true,
     max_labels_count = 300,
     max_lines_count = 300,
     max_boxes_count = 200
)

//====================================================
// INPUTS
//====================================================

gTrend = "Trend Engine"
fastEMA    = input.int(20, "Fast EMA", group=gTrend)
midEMA     = input.int(50, "Mid EMA", group=gTrend)
slowEMA    = input.int(200, "Institutional EMA", group=gTrend)
showRibbon = input.bool(true, "Show EMA Ribbon", group=gTrend)

gSMC = "Smart Money Concepts"
swingLen          = input.int(8, "Swing Length", minval=2, maxval=30, group=gSMC)
showBOSLines      = input.bool(true, "Show BOS Lines", group=gSMC)
showCHoCHLines    = input.bool(true, "Show CHoCH Lines", group=gSMC)
showStructureText = input.bool(true, "Show BOS/CHoCH Text", group=gSMC)
structureLineLen  = input.int(40, "Structure Line Length", minval=10, maxval=200, group=gSMC)
maxStructureMarks = input.int(80, "Max Structure Lines", minval=10, maxval=200, group=gSMC)

showSupplyDemand = input.bool(true, "Show Supply / Demand", group=gSMC)
showOBBuy        = input.bool(true, "Show OB Buy", group=gSMC)
showOBSell       = input.bool(true, "Show OB Sell", group=gSMC)
showOBText       = input.bool(true, "Show OB Text", group=gSMC)
obLookback       = input.int(20, "OB Candle Lookback", minval=3, maxval=80, group=gSMC)
maxZones         = input.int(20, "Max Active OB Zones", minval=1, maxval=50, group=gSMC)

gORB = "ORB Settings"
assetSelect = input.string("NASDAQ", "Asset", options=["XAUUSD", "BTCUSD", "NASDAQ", "CUSTOM"], group=gORB)
customORB   = input.session("0930-0945", "Custom ORB Session", group=gORB)
orbTZ       = input.string("Europe/Brussels", "ORB Timezone", group=gORB)
showORB     = input.bool(true, "Show ORB", group=gORB)

orbSession = assetSelect == "CUSTOM" ? customORB :
     assetSelect == "XAUUSD" ? "0800-0815" :
     assetSelect == "BTCUSD" ? "0930-0945" :
     "0930-0945"

gVWAP = "VWAP & FLOW"
showVWAP      = input.bool(true, "Show VWAP", group=gVWAP)
useVWAPFilter = input.bool(true, "Use VWAP Filter", group=gVWAP)

gRSI = "Momentum Confirmation"
rsiLen  = input.int(14, "RSI Length", group=gRSI)
rsiBull = input.float(55.0, "Bullish RSI", group=gRSI)
rsiBear = input.float(45.0, "Bearish RSI", group=gRSI)

gFlow = "Order Flow"
deltaLen = input.int(8, "Delta EMA", group=gFlow)
minDelta = input.float(0.0, "Minimum Delta", group=gFlow)

gHTF = "Higher Timeframe Trend"
useHTFfilter = input.bool(false, "Use HTF Trend Filter", group=gHTF)
htfRes       = input.timeframe("D", "HTF Resolution", group=gHTF)
htfSlowLen   = input.int(200, "HTF EMA Length", group=gHTF)

gRisk = "Risk / TP SL"
atrLen      = input.int(14, "ATR Length", group=gRisk)
slATR       = input.float(1.8, "SL ATR Multiplier", group=gRisk)
tp1RR       = input.float(1.0, "TP1 RR", group=gRisk)
tp2RR       = input.float(2.0, "TP2 RR", group=gRisk)
tp3RR       = input.float(3.5, "TP3 RR", group=gRisk)
moveBEtp1   = input.bool(true, "Move SL to BE after TP1", group=gRisk)
beBufferATR = input.float(0.0, "BE Buffer ATR", step=0.05, group=gRisk)
showTP      = input.bool(true, "Show TP / SL", group=gRisk)

gVisual = "Visual"
showDashboard = input.bool(true, "Show Dashboard", group=gVisual)
showSignals   = input.bool(true, "Show BUY/SELL Signals", group=gVisual)

//====================================================
// CORE
//====================================================

emaFast = ta.ema(close, fastEMA)
emaMid  = ta.ema(close, midEMA)
emaSlow = ta.ema(close, slowEMA)

bullTrend = emaFast > emaMid and emaMid > emaSlow
bearTrend = emaFast < emaMid and emaMid < emaSlow

vwapValue = ta.vwap(hlc3)
rsi = ta.rsi(close, rsiLen)
atr = ta.atr(atrLen)

htfEmaSlow = request.security(syminfo.tickerid, htfRes, ta.ema(close, htfSlowLen))
htfTrendBull = close > htfEmaSlow
htfTrendBear = close < htfEmaSlow

//====================================================
// DELTA / CVD PROXY
//====================================================

sign(x) =>
    x > 0 ? 1.0 : x < 0 ? -1.0 : 0.0

rawDelta = volume * sign(close - open)
smartDelta = ta.ema(rawDelta, deltaLen)

newDay = ta.change(time("D")) != 0

var float cvd = 0.0
if newDay
    cvd := rawDelta
else
    cvd += rawDelta

cvdBull = cvd > cvd[1]
cvdBear = cvd < cvd[1]

//====================================================
// ORB
//====================================================

inORB = not na(time(timeframe.period, orbSession, orbTZ))

var float orbHigh = na
var float orbLow = na
var bool orbLocked = false

if newDay
    orbHigh := na
    orbLow := na
    orbLocked := false

if inORB
    orbHigh := na(orbHigh) ? high : math.max(orbHigh, high)
    orbLow := na(orbLow) ? low : math.min(orbLow, low)

if not inORB and not na(orbHigh) and not na(orbLow)
    orbLocked := true

orbLong = orbLocked and ta.crossover(close, orbHigh)
orbShort = orbLocked and ta.crossunder(close, orbLow)

//====================================================
// STRUCTURE BOS / CHOCH
//====================================================

pivotHigh = high[swingLen] == ta.highest(high, swingLen * 2 + 1)
pivotLow  = low[swingLen] == ta.lowest(low, swingLen * 2 + 1)

var float lastSwingHigh = na
var float lastSwingLow = na
var int lastHighBar = na
var int lastLowBar = na

if pivotHigh
    lastSwingHigh := high[swingLen]
    lastHighBar := bar_index[swingLen]

if pivotLow
    lastSwingLow := low[swingLen]
    lastLowBar := bar_index[swingLen]

rawBullBreak = not na(lastSwingHigh) and ta.crossover(close, lastSwingHigh)
rawBearBreak = not na(lastSwingLow) and ta.crossunder(close, lastSwingLow)

var float brokenHighLevel = na
var float brokenLowLevel = na

bullBreak = rawBullBreak and (na(brokenHighLevel) or lastSwingHigh != brokenHighLevel)
bearBreak = rawBearBreak and (na(brokenLowLevel) or lastSwingLow != brokenLowLevel)

if bullBreak
    brokenHighLevel := lastSwingHigh

if bearBreak
    brokenLowLevel := lastSwingLow

var int structureDir = 0

bullCHoCH = bullBreak and structureDir == -1
bearCHoCH = bearBreak and structureDir == 1

bullBOS = bullBreak and not bullCHoCH
bearBOS = bearBreak and not bearCHoCH

if bullBreak
    structureDir := 1

if bearBreak
    structureDir := -1

//====================================================
// CLEAN STRUCTURE LINES + DISCREET TEXT
//====================================================

var line[] structLines = array.new_line()
var label[] structTexts = array.new_label()

addStructureMark(_x1, _x2, _y, _txt, _col) =>
    ln = line.new(
         x1 = _x1,
         y1 = _y,
         x2 = _x2,
         y2 = _y,
         color = color.new(_col, 10),
         width = 1,
         style = line.style_solid
    )

    lb = label.new(
         x = math.round((_x1 + _x2) / 2),
         y = _y + atr * 0.12,
         text = _txt,
         style = label.style_none,
         textcolor = color.new(_col, 0),
         size = size.tiny
    )

    array.push(structLines, ln)
    array.push(structTexts, lb)

    if array.size(structLines) > maxStructureMarks
        oldLine = array.shift(structLines)
        line.delete(oldLine)

    if array.size(structTexts) > maxStructureMarks
        oldLabel = array.shift(structTexts)
        label.delete(oldLabel)

if bullBOS and showBOSLines
    addStructureMark(bar_index, bar_index + structureLineLen, lastSwingHigh, showStructureText ? "Bull BOS" : "", color.lime)

if bearBOS and showBOSLines
    addStructureMark(bar_index, bar_index + structureLineLen, lastSwingLow, showStructureText ? "Bear BOS" : "", color.red)

if bullCHoCH and showCHoCHLines
    addStructureMark(bar_index, bar_index + structureLineLen, lastSwingHigh, showStructureText ? "Bull CHoCH" : "", color.aqua)

if bearCHoCH and showCHoCHLines
    addStructureMark(bar_index, bar_index + structureLineLen, lastSwingLow, showStructureText ? "Bear CHoCH" : "", color.orange)

//====================================================
// FILTERS
//====================================================

vwapBull = close > vwapValue
vwapBear = close < vwapValue

momentumBull = rsi > rsiBull
momentumBear = rsi < rsiBear

flowBull = smartDelta > minDelta and cvdBull
flowBear = smartDelta < -minDelta and cvdBear

htfLongOk = not useHTFfilter or htfTrendBull
htfShortOk = not useHTFfilter or htfTrendBear

longFilter = bullTrend and momentumBull and flowBull and (not useVWAPFilter or vwapBull) and htfLongOk
shortFilter = bearTrend and momentumBear and flowBear and (not useVWAPFilter or vwapBear) and htfShortOk

institutionalLong = (orbLong or bullBreak) and longFilter
institutionalShort = (orbShort or bearBreak) and shortFilter

//====================================================
// SUPPLY / DEMAND OB BOXES
//====================================================

var box[] demandBoxes = array.new_box()
var box[] supplyBoxes = array.new_box()

if showSupplyDemand and showOBBuy and bullBreak
    float obTop = na
    float obBot = na
    int obBar = na

    for i = 1 to obLookback
        if na(obTop) and close[i] < open[i]
            obTop := high[i]
            obBot := low[i]
            obBar := bar_index[i]

    if not na(obTop)
        bx = box.new(
             left = obBar,
             top = obTop,
             right = bar_index + 300,
             bottom = obBot,
             bgcolor = color.new(color.lime, 88),
             border_color = color.new(color.lime, 35),
             text = showOBText ? "OB Buy" : "",
             text_color = color.new(color.lime, 0),
             text_size = size.tiny,
             text_halign = text.align_left,
             text_valign = text.align_center
        )
        array.push(demandBoxes, bx)

        if array.size(demandBoxes) > maxZones
            oldBox = array.shift(demandBoxes)
            box.delete(oldBox)

if showSupplyDemand and showOBSell and bearBreak
    float obTop = na
    float obBot = na
    int obBar = na

    for i = 1 to obLookback
        if na(obTop) and close[i] > open[i]
            obTop := high[i]
            obBot := low[i]
            obBar := bar_index[i]

    if not na(obTop)
        bx = box.new(
             left = obBar,
             top = obTop,
             right = bar_index + 300,
             bottom = obBot,
             bgcolor = color.new(color.red, 88),
             border_color = color.new(color.red, 35),
             text = showOBText ? "OB Sell" : "",
             text_color = color.new(color.red, 0),
             text_size = size.tiny,
             text_halign = text.align_left,
             text_valign = text.align_center
        )
        array.push(supplyBoxes, bx)

        if array.size(supplyBoxes) > maxZones
            oldBox = array.shift(supplyBoxes)
            box.delete(oldBox)

// Update demand boxes
int d = array.size(demandBoxes) - 1
while d >= 0
    bx = array.get(demandBoxes, d)
    box.set_right(bx, bar_index + 300)

    if close < box.get_bottom(bx)
        box.delete(bx)
        array.remove(demandBoxes, d)

    d -= 1

// Update supply boxes
int s = array.size(supplyBoxes) - 1
while s >= 0
    bx = array.get(supplyBoxes, s)
    box.set_right(bx, bar_index + 300)

    if close > box.get_top(bx)
        box.delete(bx)
        array.remove(supplyBoxes, s)

    s -= 1

//====================================================
// TRADE SIMULATOR
//====================================================

var bool tradeActive = false
var int tradeDir = 0
var float entryPrice = na
var float stopLoss = na
var float tp1 = na
var float tp2 = na
var float tp3 = na
var bool tp1Hit = false
var bool tp2Hit = false
var bool tp3Hit = false
var string tradeName = "NONE"
var float tradePnl = na

var float lastTradeResult = na
var string lastTradeText = "NONE"

var line entryLine = na
var line slLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na

var label entryLabel = na

deleteLines() =>
    if not na(entryLine)
        line.delete(entryLine)
    if not na(slLine)
        line.delete(slLine)
    if not na(tp1Line)
        line.delete(tp1Line)
    if not na(tp2Line)
        line.delete(tp2Line)
    if not na(tp3Line)
        line.delete(tp3Line)
    if not na(entryLabel)
        label.delete(entryLabel)

newLongSignal = institutionalLong and not tradeActive
newShortSignal = institutionalShort and not tradeActive

if newLongSignal
    tradeActive := true
    tradeDir := 1
    entryPrice := close
    stopLoss := close - atr * slATR

    risk = entryPrice - stopLoss
    tp1 := entryPrice + risk * tp1RR
    tp2 := entryPrice + risk * tp2RR
    tp3 := entryPrice + risk * tp3RR

    tp1Hit := false
    tp2Hit := false
    tp3Hit := false
    tradeName := "LONG"
    tradePnl := 0.0

    if showTP
        deleteLines()
        entryLine := line.new(bar_index, entryPrice, bar_index + 80, entryPrice, color=color.white, width=1)
        slLine := line.new(bar_index, stopLoss, bar_index + 80, stopLoss, color=color.red, width=2)
        tp1Line := line.new(bar_index, tp1, bar_index + 80, tp1, color=color.lime, width=1)
        tp2Line := line.new(bar_index, tp2, bar_index + 80, tp2, color=color.lime, width=2)
        tp3Line := line.new(bar_index, tp3, bar_index + 80, tp3, color=color.green, width=3)
        entryLabel := label.new(bar_index, entryPrice, "BUY", style=label.style_label_up, color=color.lime, textcolor=color.black)

if newShortSignal
    tradeActive := true
    tradeDir := -1
    entryPrice := close
    stopLoss := close + atr * slATR

    risk = stopLoss - entryPrice
    tp1 := entryPrice - risk * tp1RR
    tp2 := entryPrice - risk * tp2RR
    tp3 := entryPrice - risk * tp3RR

    tp1Hit := false
    tp2Hit := false
    tp3Hit := false
    tradeName := "SHORT"
    tradePnl := 0.0

    if showTP
        deleteLines()
        entryLine := line.new(bar_index, entryPrice, bar_index + 80, entryPrice, color=color.white, width=1)
        slLine := line.new(bar_index, stopLoss, bar_index + 80, stopLoss, color=color.red, width=2)
        tp1Line := line.new(bar_index, tp1, bar_index + 80, tp1, color=color.lime, width=1)
        tp2Line := line.new(bar_index, tp2, bar_index + 80, tp2, color=color.lime, width=2)
        tp3Line := line.new(bar_index, tp3, bar_index + 80, tp3, color=color.green, width=3)
        entryLabel := label.new(bar_index, entryPrice, "SELL", style=label.style_label_down, color=color.red, textcolor=color.white)

if tradeActive
    if showTP
        if not na(entryLine)
            line.set_x2(entryLine, bar_index + 80)
        if not na(slLine)
            line.set_x2(slLine, bar_index + 80)
            line.set_y1(slLine, stopLoss)
            line.set_y2(slLine, stopLoss)
        if not na(tp1Line)
            line.set_x2(tp1Line, bar_index + 80)
        if not na(tp2Line)
            line.set_x2(tp2Line, bar_index + 80)
        if not na(tp3Line)
            line.set_x2(tp3Line, bar_index + 80)

    if tradeDir == 1
        tradePnl := close - entryPrice

        if not tp1Hit and high >= tp1
            tp1Hit := true
            if moveBEtp1
                stopLoss := entryPrice + atr * beBufferATR

        if not tp2Hit and high >= tp2
            tp2Hit := true

        if not tp3Hit and high >= tp3
            tp3Hit := true
            tradeActive := false
            tradePnl := tp3 - entryPrice
            lastTradeResult := tradePnl
            lastTradeText := "LONG TP3"
            tradeName := "LONG TP3"

        if tradeActive and low <= stopLoss
            tradeActive := false
            tradePnl := stopLoss - entryPrice
            lastTradeResult := tradePnl
            lastTradeText := tp1Hit ? "LONG BE/SL" : "LONG SL"
            tradeName := lastTradeText

    if tradeDir == -1
        tradePnl := entryPrice - close

        if not tp1Hit and low <= tp1
            tp1Hit := true
            if moveBEtp1
                stopLoss := entryPrice - atr * beBufferATR

        if not tp2Hit and low <= tp2
            tp2Hit := true

        if not tp3Hit and low <= tp3
            tp3Hit := true
            tradeActive := false
            tradePnl := entryPrice - tp3
            lastTradeResult := tradePnl
            lastTradeText := "SHORT TP3"
            tradeName := "SHORT TP3"

        if tradeActive and high >= stopLoss
            tradeActive := false
            tradePnl := entryPrice - stopLoss
            lastTradeResult := tradePnl
            lastTradeText := tp1Hit ? "SHORT BE/SL" : "SHORT SL"
            tradeName := lastTradeText

//====================================================
// VISUAL SIGNALS
//====================================================

if showSignals and newLongSignal
    label.new(bar_index, low, "BUY", style=label.style_label_up, color=color.lime, textcolor=color.black, size=size.small)

if showSignals and newShortSignal
    label.new(bar_index, high, "SELL", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)

//====================================================
// PLOTS
//====================================================

plot(showRibbon ? emaFast : na, "Fast EMA", color=color.aqua, linewidth=2)
plot(showRibbon ? emaMid : na, "Mid EMA", color=color.orange, linewidth=2)
plot(showRibbon ? emaSlow : na, "Slow EMA", color=color.purple, linewidth=3)

plot(showVWAP ? vwapValue : na, "VWAP", color=color.yellow, linewidth=2)

plot(showORB and orbLocked ? orbHigh : na, "ORB HIGH", color=color.lime, linewidth=2)
plot(showORB and orbLocked ? orbLow : na, "ORB LOW", color=color.red, linewidth=2)

//====================================================
// ALERTS
//====================================================

alertcondition(institutionalLong, title="Institutional Long", message="Institutional BUY signal confirmed")
alertcondition(institutionalShort, title="Institutional Short", message="Institutional SELL signal confirmed")
alertcondition(bullBOS, title="Bullish BOS", message="Bullish BOS confirmed")
alertcondition(bearBOS, title="Bearish BOS", message="Bearish BOS confirmed")
alertcondition(bullCHoCH, title="Bullish CHoCH", message="Bullish CHoCH confirmed")
alertcondition(bearCHoCH, title="Bearish CHoCH", message="Bearish CHoCH confirmed")

//====================================================
// DASHBOARD
//====================================================

var table dashboard = table.new(position.top_right, 2, 14, border_width=1)

if barstate.islast and showDashboard
    table.cell(dashboard, 0, 0, "ASSET", bgcolor=color.black, text_color=color.white)
    table.cell(dashboard, 1, 0, syminfo.ticker, text_color=color.yellow)

    table.cell(dashboard, 0, 1, "TREND", bgcolor=color.black, text_color=color.white)
    table.cell(dashboard, 1, 1, bullTrend ? "BULLISH" : bearTrend ? "BEARISH" : "RANGE", text_color=bullTrend ? color.lime : bearTrend ? color.red : color.orange)

    table.cell(dashboard, 0, 2, "VWAP", bgcolor=color.black, text_color=color.white)
    table.cell(dashboard, 1, 2, vwapBull ? "ABOVE" : "BELOW", text_color=vwapBull ? color.lime : color.red)

    table.cell(dashboard, 0, 3, "RSI", bgcolor=color.black, text_color=color.white)
    table.cell(dashboard, 1, 3, str.tostring(rsi, "#.0"), text_color=momentumBull ? color.lime : momentumBear ? color.red : color.orange)

    table.cell(dashboard, 0, 4, "DELTA", bgcolor=color.black, text_color=color.white)
    table.cell(dashboard, 1, 4, str.tostring(smartDelta, "#.0"), text_color=flowBull ? color.lime : flowBear ? color.red : color.orange)

    table.cell(dashboard, 0, 5, "CVD", bgcolor=color.black, text_color=color.white)
    table.cell(dashboard, 1, 5, cvdBull ? "RISING" : "FALLING", text_color=cvdBull ? color.lime : color.red)

    table.cell(dashboard, 0, 6, "ORB", bgcolor=color.black, text_color=color.white)
    table.cell(dashboard, 1, 6, orbLocked ? "ACTIVE" : "WAIT", text_color=orbLocked ? color.lime : color.orange)

    table.cell(dashboard, 0, 7, "STRUCTURE", bgcolor=color.black, text_color=color.white)
    structText = bullCHoCH ? "BULL CHoCH" : bearCHoCH ? "BEAR CHoCH" : bullBOS ? "BULL BOS" : bearBOS ? "BEAR BOS" : structureDir == 1 ? "BULL" : structureDir == -1 ? "BEAR" : "NEUTRAL"
    table.cell(dashboard, 1, 7, structText, text_color=structureDir == 1 ? color.lime : structureDir == -1 ? color.red : color.orange)

    table.cell(dashboard, 0, 8, "SIGNAL", bgcolor=color.black, text_color=color.white)
    table.cell(dashboard, 1, 8, institutionalLong ? "BUY" : institutionalShort ? "SELL" : "WAIT", text_color=institutionalLong ? color.lime : institutionalShort ? color.red : color.orange)

    table.cell(dashboard, 0, 9, "TRADE", bgcolor=color.black, text_color=color.white)
    table.cell(dashboard, 1, 9, tradeActive ? tradeName : "NO ACTIVE", text_color=tradeActive ? color.yellow : color.gray)

    table.cell(dashboard, 0, 10, "TP STATUS", bgcolor=color.black, text_color=color.white)
    tpStatus = "TP1 " + (tp1Hit ? "OK" : "-") + " | TP2 " + (tp2Hit ? "OK" : "-") + " | TP3 " + (tp3Hit ? "OK" : "-")
    table.cell(dashboard, 1, 10, tradeActive ? tpStatus : "NONE", text_color=tp1Hit ? color.lime : color.gray)

    table.cell(dashboard, 0, 11, "ACTIVE PNL", bgcolor=color.black, text_color=color.white)
    table.cell(dashboard, 1, 11, tradeActive ? str.tostring(tradePnl, "#.##") : "0", text_color=tradePnl > 0 ? color.lime : tradePnl < 0 ? color.red : color.gray)

    table.cell(dashboard, 0, 12, "LAST TRADE", bgcolor=color.black, text_color=color.white)
    table.cell(dashboard, 1, 12, lastTradeText, text_color=lastTradeResult > 0 ? color.lime : lastTradeResult < 0 ? color.red : color.gray)

    table.cell(dashboard, 0, 13, "LAST RESULT", bgcolor=color.black, text_color=color.white)
    table.cell(dashboard, 1, 13, na(lastTradeResult) ? "NONE" : str.tostring(lastTradeResult, "#.##"), text_color=lastTradeResult > 0 ? color.lime : lastTradeResult < 0 ? color.red : color.gray)
````
