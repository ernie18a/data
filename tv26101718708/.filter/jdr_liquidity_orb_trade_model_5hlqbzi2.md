# JDR Liquidity ORB Trade Model

- url: https://www.tradingview.com/script/5HLQBZi2-JDR-Liquidity-ORB-Trade-Model/
- type: indicator
- pine_id: PUB;217f29aa5ec74c44a03ef55d2c005bf1
- version: 2.0

## Description

Outlining Sweeps based on previous day high and low, previous day 15min high and low, and current 15min ORB

## Source Code

````pine
//@version=6
indicator("JDR Liquidity ORB Trade Model PRO", overlay=true, max_labels_count=500, max_lines_count=500)

//====================================================
// INPUTS
//====================================================
sessionInput = input.session("0930-1600", "Regular Trading Session")
overnightSession = input.session("1800-0929", "Overnight Session")
tz = input.string("America/New_York", "Timezone")

showLevels = input.bool(true, "Show Levels")
showSignals = input.bool(true, "Show Signals")
showDashboard = input.bool(true, "Show Dashboard")
showTradeBoxes = input.bool(true, "Show Trade Lines")

confirmationBars = input.int(5, "Confirmation Window", minval=1, maxval=20)
cooldownBars = input.int(10, "Cooldown Bars", minval=1, maxval=100)
maxSignalsPerDay = input.int(3, "Max Signals Per Day", minval=1, maxval=10)

useDisplacement = input.bool(true, "Require Displacement")
useTrendFilter = input.bool(false, "Use EMA Trend Filter")
useFVGFilter = input.bool(false, "Require FVG")

riskReward = input.float(3.0, "Risk Reward", step=0.5)
contracts = input.int(1, "MNQ Contracts", minval=1)

atrLength = input.int(14, "ATR Length")
minBodyAtr = input.float(0.35, "Body vs ATR", step=0.05)
minBodyPercent = input.float(0.50, "Body % of Candle", step=0.05)

emaFastLen = input.int(20, "Fast EMA")
emaSlowLen = input.int(50, "Slow EMA")

mnqPointValue = 2.0

//====================================================
// PREVIOUS DAY HIGH / LOW
//====================================================
pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_off)
pdl = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_off)

//====================================================
// OVERNIGHT LEVELS
//====================================================
inOvernight = not na(time(timeframe.period, overnightSession, tz))
newOvernight = inOvernight and not inOvernight[1]

var float overnightHigh = na
var float overnightLow = na

if newOvernight
    overnightHigh := high
    overnightLow := low

if inOvernight
    overnightHigh := math.max(overnightHigh, high)
    overnightLow := math.min(overnightLow, low)

//====================================================
// SESSION + CURRENT 15M RANGE
//====================================================
inSession = not na(time(timeframe.period, sessionInput, tz))
newSession = inSession and not inSession[1]

var float curr15High = na
var float curr15Low = na
var float prev15High = na
var float prev15Low = na
var float last15High = na
var float last15Low = na
var int sessionStart = na
var bool rangeLocked = false
var int signalsToday = 0
var int lastSignalBar = na

if newSession
    prev15High := last15High
    prev15Low := last15Low
    curr15High := high
    curr15Low := low
    sessionStart := time
    rangeLocked := false
    signalsToday := 0

first15Active = inSession and not rangeLocked and not na(sessionStart) and time < sessionStart + 15 * 60 * 1000

if first15Active
    curr15High := math.max(curr15High, high)
    curr15Low := math.min(curr15Low, low)

if inSession and not rangeLocked and not na(sessionStart) and time >= sessionStart + 15 * 60 * 1000
    rangeLocked := true
    last15High := curr15High
    last15Low := curr15Low

//====================================================
// LEVEL PLOTS
//====================================================
plot(showLevels ? pdh : na, "PDH", color=color.red, linewidth=2, style=plot.style_stepline)
plot(showLevels ? pdl : na, "PDL", color=color.green, linewidth=2, style=plot.style_stepline)

plot(showLevels ? overnightHigh : na, "ON High", color=color.yellow, linewidth=2, style=plot.style_stepline)
plot(showLevels ? overnightLow : na, "ON Low", color=color.aqua, linewidth=2, style=plot.style_stepline)

plot(showLevels and rangeLocked ? curr15High : na, "Current 15m High", color=color.orange, linewidth=2, style=plot.style_stepline)
plot(showLevels and rangeLocked ? curr15Low : na, "Current 15m Low", color=color.blue, linewidth=2, style=plot.style_stepline)

plot(showLevels ? prev15High : na, "Prev 15m High", color=color.purple, linewidth=1, style=plot.style_stepline)
plot(showLevels ? prev15Low : na, "Prev 15m Low", color=color.purple, linewidth=1, style=plot.style_stepline)

//====================================================
// FILTERS
//====================================================
atr = ta.atr(atrLength)

body = math.abs(close - open)
candleRange = math.max(high - low, syminfo.mintick)
bodyPercent = body / candleRange

bullDisplacement = close > open and body >= atr * minBodyAtr and bodyPercent >= minBodyPercent and close > high[1]
bearDisplacement = close < open and body >= atr * minBodyAtr and bodyPercent >= minBodyPercent and close < low[1]

bullFVG = low > high[2]
bearFVG = high < low[2]

emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

longTrendOk = not useTrendFilter or emaFast > emaSlow
shortTrendOk = not useTrendFilter or emaFast < emaSlow

longDispOk = not useDisplacement or bullDisplacement
shortDispOk = not useDisplacement or bearDisplacement

longFvgOk = not useFVGFilter or bullFVG
shortFvgOk = not useFVGFilter or bearFVG

plot(useTrendFilter ? emaFast : na, "Fast EMA", color=color.white)
plot(useTrendFilter ? emaSlow : na, "Slow EMA", color=color.gray)

//====================================================
// SWEEP DETECTION
//====================================================
sweptPDL = low < pdl
sweptPDH = high > pdh

sweptONLow = not na(overnightLow) and low < overnightLow
sweptONHigh = not na(overnightHigh) and high > overnightHigh

sweptCurr15Low = rangeLocked and low < curr15Low
sweptCurr15High = rangeLocked and high > curr15High

sweptPrev15Low = not na(prev15Low) and low < prev15Low
sweptPrev15High = not na(prev15High) and high > prev15High

longSweep = inSession and (sweptPDL or sweptONLow or sweptCurr15Low or sweptPrev15Low)
shortSweep = inSession and (sweptPDH or sweptONHigh or sweptCurr15High or sweptPrev15High)

//====================================================
// ARM SETUPS
//====================================================
var bool longArmed = false
var bool shortArmed = false

var float longLevel = na
var float shortLevel = na

var int longSweepBar = na
var int shortSweepBar = na

var string longName = ""
var string shortName = ""

if longSweep
    longArmed := true
    longSweepBar := bar_index

    if sweptPDL
        longLevel := pdl
        longName := "PDL"

    if sweptONLow
        longLevel := overnightLow
        longName := "ON LOW"

    if sweptCurr15Low
        longLevel := curr15Low
        longName := "CURR 15 LOW"

    if sweptPrev15Low
        longLevel := prev15Low
        longName := "PREV 15 LOW"

if shortSweep
    shortArmed := true
    shortSweepBar := bar_index

    if sweptPDH
        shortLevel := pdh
        shortName := "PDH"

    if sweptONHigh
        shortLevel := overnightHigh
        shortName := "ON HIGH"

    if sweptCurr15High
        shortLevel := curr15High
        shortName := "CURR 15 HIGH"

    if sweptPrev15High
        shortLevel := prev15High
        shortName := "PREV 15 HIGH"

//====================================================
// CONFIRMATION
//====================================================
longValid = longArmed and not na(longSweepBar) and bar_index - longSweepBar <= confirmationBars
shortValid = shortArmed and not na(shortSweepBar) and bar_index - shortSweepBar <= confirmationBars

longReclaim = longValid and close > longLevel
shortReject = shortValid and close < shortLevel

cooldownOk = na(lastSignalBar) or bar_index - lastSignalBar >= cooldownBars
dailyLimitOk = signalsToday < maxSignalsPerDay

longSignal = showSignals and barstate.isconfirmed and longReclaim and longTrendOk and longDispOk and longFvgOk and cooldownOk and dailyLimitOk
shortSignal = showSignals and barstate.isconfirmed and shortReject and shortTrendOk and shortDispOk and shortFvgOk and cooldownOk and dailyLimitOk

if longArmed and not longValid
    longArmed := false

if shortArmed and not shortValid
    shortArmed := false

//====================================================
// TRADE TRACKING
//====================================================
var bool inTrade = false
var bool longTrade = false

var float entry = na
var float stop = na
var float target = na

var line stopLine = na
var line targetLine = na
var line entryLine = na

if longSignal and not inTrade
    inTrade := true
    longTrade := true

    entry := close
    stop := low
    risk = entry - stop
    target := entry + risk * riskReward

    signalsToday += 1
    lastSignalBar := bar_index
    longArmed := false
    shortArmed := false

    label.new(bar_index, low, "LONG\nSweep: " + longName + "\nEntry: " + str.tostring(entry) + "\nSL: " + str.tostring(stop) + "\nTP: " + str.tostring(target), style=label.style_label_up, color=color.green, textcolor=color.white)

    if showTradeBoxes
        entryLine := line.new(bar_index, entry, bar_index + 20, entry, color=color.white, width=1)
        stopLine := line.new(bar_index, stop, bar_index + 20, stop, color=color.red, width=1)
        targetLine := line.new(bar_index, target, bar_index + 20, target, color=color.green, width=1)

if shortSignal and not inTrade
    inTrade := true
    longTrade := false

    entry := close
    stop := high
    risk = stop - entry
    target := entry - risk * riskReward

    signalsToday += 1
    lastSignalBar := bar_index
    longArmed := false
    shortArmed := false

    label.new(bar_index, high, "SHORT\nSweep: " + shortName + "\nEntry: " + str.tostring(entry) + "\nSL: " + str.tostring(stop) + "\nTP: " + str.tostring(target), style=label.style_label_down, color=color.red, textcolor=color.white)

    if showTradeBoxes
        entryLine := line.new(bar_index, entry, bar_index + 20, entry, color=color.white, width=1)
        stopLine := line.new(bar_index, stop, bar_index + 20, stop, color=color.red, width=1)
        targetLine := line.new(bar_index, target, bar_index + 20, target, color=color.green, width=1)

//====================================================
// TRADE RESULTS
//====================================================
longTP = inTrade and longTrade and high >= target
longSL = inTrade and longTrade and low <= stop

shortTP = inTrade and not longTrade and low <= target
shortSL = inTrade and not longTrade and high >= stop

if longTP
    pnl = (target - entry) * mnqPointValue * contracts
    label.new(bar_index, target, "LONG TP\n+$" + str.tostring(pnl, "#.##"), style=label.style_label_down, color=color.green, textcolor=color.white)
    inTrade := false

if longSL
    pnl = (entry - stop) * mnqPointValue * contracts
    label.new(bar_index, stop, "LONG SL\n-$" + str.tostring(pnl, "#.##"), style=label.style_label_up, color=color.red, textcolor=color.white)
    inTrade := false

if shortTP
    pnl = (entry - target) * mnqPointValue * contracts
    label.new(bar_index, target, "SHORT TP\n+$" + str.tostring(pnl, "#.##"), style=label.style_label_up, color=color.green, textcolor=color.white)
    inTrade := false

if shortSL
    pnl = (stop - entry) * mnqPointValue * contracts
    label.new(bar_index, stop, "SHORT SL\n-$" + str.tostring(pnl, "#.##"), style=label.style_label_down, color=color.red, textcolor=color.white)
    inTrade := false

//====================================================
// SIGNAL PLOTS
//====================================================
plotshape(showSignals and longSignal, title="LONG", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, text="LONG")
plotshape(showSignals and shortSignal, title="SHORT", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="SHORT")

//====================================================
// ALERTS
//====================================================
alertcondition(longSignal, title="LONG SETUP", message="JDR LONG setup confirmed.")
alertcondition(shortSignal, title="SHORT SETUP", message="JDR SHORT setup confirmed.")

if longSignal
    alert("JDR LONG confirmed | Sweep: " + longName + " | Entry: " + str.tostring(close), alert.freq_once_per_bar_close)

if shortSignal
    alert("JDR SHORT confirmed | Sweep: " + shortName + " | Entry: " + str.tostring(close), alert.freq_once_per_bar_close)

//====================================================
// DASHBOARD
//====================================================
var table dash = table.new(position.top_right, 2, 6, border_width=1)

bias = emaFast > emaSlow ? "BULLISH" : emaFast < emaSlow ? "BEARISH" : "NEUTRAL"

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "JDR MODEL", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 0, "ACTIVE", text_color=color.white, bgcolor=color.black)

    table.cell(dash, 0, 1, "BIAS")
    table.cell(dash, 1, 1, bias)

    table.cell(dash, 0, 2, "SIGNALS")
    table.cell(dash, 1, 2, str.tostring(signalsToday))

    table.cell(dash, 0, 3, "IN TRADE")
    table.cell(dash, 1, 3, inTrade ? "YES" : "NO")

    table.cell(dash, 0, 4, "RR")
    table.cell(dash, 1, 4, str.tostring(riskReward) + "R")

    table.cell(dash, 0, 5, "CONTRACTS")
    table.cell(dash, 1, 5, str.tostring(contracts))
````
