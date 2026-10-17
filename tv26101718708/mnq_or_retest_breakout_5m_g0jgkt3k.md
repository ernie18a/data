# MNQ OR Retest Breakout 5m

- url: https://www.tradingview.com/script/g0jGKt3K-MNQ-OR-Retest-Breakout-5m/
- type: indicator
- pine_id: PUB;4c8b70ce8aa84fc2bdd6d500be71aa75
- version: 3.0

## Description

For my boys in the chat. We got this TYJ!

Looking at first 15 minutes of the NY and Asia sessions. Wait for breakout and retest and enter on the candle back in either the long or short direction (Direction of initial breakout)

## Source Code

````pine
//@version=5
indicator("MNQ OR Retest Breakout 5m - Final", overlay=true, max_labels_count=500, max_lines_count=500)

//====================================================
// INPUTS
//====================================================
tz = input.string("America/New_York", "Timezone")

useVWAPFilter   = input.bool(false, "Use VWAP Trend Filter")
useVolumeFilter = input.bool(false, "Use Volume Filter")
volLen          = input.int(20, "Volume SMA Length", minval=1)

retestBufferPts = input.float(4.0, "Retest Touch Buffer (points)", step=0.25)
stopBufferPts   = input.float(8.0, "Stop Buffer (points)", step=0.25)
tpRR            = input.float(2.0, "TP R Multiple", step=0.25)

oneTradePerSession = input.bool(true, "One Trade Per Session")
manualSkipDay      = input.bool(false, "Skip Trades Today (manual news filter)")
maxRangeTicks      = input.int(1000, "Max OR Size In Ticks", minval=1)

showVWAP           = input.bool(true, "Show VWAP")
showRetestMarkers  = input.bool(true, "Show Retest Markers")
showEntryMarkers   = input.bool(true, "Show Buy/Sell Labels")
showTargets        = input.bool(true, "Show Entry / SL / TP")
showReadyCountdown = input.bool(true, "Show Ready Countdown")
showRangeWarning   = input.bool(true, "Show Oversized Range Warning")
showTFWarning      = input.bool(true, "Warn If Not On 5m")

minBreakoutTicks   = input.int(20, "Min Breakout Distance (Ticks)", minval=1)

//====================================================
// TIMEFRAME LOCK
//====================================================
isFiveMin = timeframe.isminutes and timeframe.multiplier == 5

//====================================================
// TIME LOGIC
//====================================================
hh = hour(time, tz)
mm = minute(time, tz)

// NY session on 5m
nyBuild1      = (hh == 9 and mm == 30)
nyBuild2      = (hh == 9 and mm == 35)
nyBuild3      = (hh == 9 and mm == 40)
nyFinalizeBar = (hh == 9 and mm >= 45)
inNYBuild     = nyBuild1 or nyBuild2 or nyBuild3
inNYTrade     = (hh == 9 and mm >= 45) or (hh == 10)

// Asia session on 5m
asiaBuild1      = (hh == 18 and mm == 0)
asiaBuild2      = (hh == 18 and mm == 5)
asiaBuild3      = (hh == 18 and mm == 10)
asiaFinalizeBar = (hh == 18 and mm >= 15)
inAsiaBuild     = asiaBuild1 or asiaBuild2 or asiaBuild3
inAsiaTrade     = (hh == 18 and mm >= 15) or (hh == 19)

// OR line active windows
// NY lines: 9:45 to 10:59 (stop at 11:00)
// Asia lines: 18:15 to 19:59 (stop at 20:00)
nyLineActive =
     (hh == 9 and mm >= 45) or
     (hh == 10)

asiaLineActive =
     (hh == 18 and mm >= 15) or
     (hh == 19)

sessionActive = inNYTrade or inAsiaTrade
newSession    = nyBuild1 or asiaBuild1

//====================================================
// OPENING RANGE STORAGE
//====================================================
var float nyORBuildHigh   = na
var float nyORBuildLow    = na
var float asiaORBuildHigh = na
var float asiaORBuildLow  = na

var float nyORHigh   = na
var float nyORLow    = na
var float asiaORHigh = na
var float asiaORLow  = na

//====================================================
// OR LINE OBJECTS
//====================================================
var line nyHighLine   = na
var line nyLowLine    = na
var line asiaHighLine = na
var line asiaLowLine  = na

//====================================================
// BUILD / FINALIZE NY OR
//====================================================
if nyBuild1
    nyORBuildHigh := high
    nyORBuildLow  := low
    nyORHigh      := na
    nyORLow       := na
else if nyBuild2 or nyBuild3
    nyORBuildHigh := math.max(nyORBuildHigh, high)
    nyORBuildLow  := math.min(nyORBuildLow, low)

if nyFinalizeBar and na(nyORHigh) and not na(nyORBuildHigh) and not na(nyORBuildLow)
    nyORHigh := nyORBuildHigh
    nyORLow  := nyORBuildLow

    line.delete(nyHighLine)
    line.delete(nyLowLine)

    nyHighLine := line.new(bar_index, nyORHigh, bar_index, nyORHigh, extend=extend.none, color=color.white, width=2)
    nyLowLine  := line.new(bar_index, nyORLow,  bar_index, nyORLow,  extend=extend.none, color=color.white, width=2)

// Extend NY OR lines only during allowed NY window
if not na(nyHighLine) and nyLineActive
    line.set_x2(nyHighLine, bar_index)
if not na(nyLowLine) and nyLineActive
    line.set_x2(nyLowLine, bar_index)

//====================================================
// BUILD / FINALIZE ASIA OR
//====================================================
if asiaBuild1
    asiaORBuildHigh := high
    asiaORBuildLow  := low
    asiaORHigh      := na
    asiaORLow       := na
else if asiaBuild2 or asiaBuild3
    asiaORBuildHigh := math.max(asiaORBuildHigh, high)
    asiaORBuildLow  := math.min(asiaORBuildLow, low)

if asiaFinalizeBar and na(asiaORHigh) and not na(asiaORBuildHigh) and not na(asiaORBuildLow)
    asiaORHigh := asiaORBuildHigh
    asiaORLow  := asiaORBuildLow

    line.delete(asiaHighLine)
    line.delete(asiaLowLine)

    asiaHighLine := line.new(bar_index, asiaORHigh, bar_index, asiaORHigh, extend=extend.none, color=color.white, width=2)
    asiaLowLine  := line.new(bar_index, asiaORLow,  bar_index, asiaORLow,  extend=extend.none, color=color.white, width=2)

// Extend Asia OR lines only during allowed Asia window
if not na(asiaHighLine) and asiaLineActive
    line.set_x2(asiaHighLine, bar_index)
if not na(asiaLowLine) and asiaLineActive
    line.set_x2(asiaLowLine, bar_index)

//====================================================
// ACTIVE OR
//====================================================
activeORHigh = inNYTrade ? nyORHigh : inAsiaTrade ? asiaORHigh : na
activeORLow  = inNYTrade ? nyORLow  : inAsiaTrade ? asiaORLow  : na

//====================================================
// OR SIZE FILTER
//====================================================
orSizePoints = not na(activeORHigh) and not na(activeORLow) ? (activeORHigh - activeORLow) : na
orSizeTicks  = not na(orSizePoints) ? math.round(orSizePoints / syminfo.mintick) : na
rangeTooBig  = not na(orSizeTicks) and orSizeTicks >= maxRangeTicks

//====================================================
// OPTIONAL FILTERS
//====================================================
vwapVal = ta.vwap(hlc3)
volMA   = ta.sma(volume, volLen)

longTrendOk  = not useVWAPFilter or close > vwapVal
shortTrendOk = not useVWAPFilter or close < vwapVal
volOk        = not useVolumeFilter or volume > volMA

plot(showVWAP and useVWAPFilter ? vwapVal : na, "VWAP", color=color.white, linewidth=2)

//====================================================
// FVG DETECTION
//====================================================
var float bullFVGTop = na
var float bullFVGBot = na
var float bearFVGTop = na
var float bearFVGBot = na

if newSession
    bullFVGTop := na
    bullFVGBot := na
    bearFVGTop := na
    bearFVGBot := na

bullFVG = bar_index >= 2 and low > high[2]
bearFVG = bar_index >= 2 and high < low[2]

if bullFVG
    bullFVGTop := low
    bullFVGBot := high[2]

if bearFVG
    bearFVGTop := low[2]
    bearFVGBot := high

//====================================================
// SESSION STATE
//====================================================
var bool longBreakoutSeen      = false
var bool shortBreakoutSeen     = false
var bool longRetestArmed       = false
var bool shortRetestArmed      = false
var bool tradeTakenThisSession = false

var int breakoutBarIndexLong   = na
var int breakoutBarIndexShort  = na
var int retestBarIndexLong     = na
var int retestBarIndexShort    = na

var float breakoutLongBodyTop  = na
var float breakoutShortBodyBot = na

var float retestLongLow        = na
var float retestShortHigh      = na

if newSession
    longBreakoutSeen      := false
    shortBreakoutSeen     := false
    longRetestArmed       := false
    shortRetestArmed      := false
    tradeTakenThisSession := false

    breakoutBarIndexLong  := na
    breakoutBarIndexShort := na
    retestBarIndexLong    := na
    retestBarIndexShort   := na

    breakoutLongBodyTop   := na
    breakoutShortBodyBot  := na
    retestLongLow         := na
    retestShortHigh       := na

validToTrade        = isFiveMin and sessionActive and not manualSkipDay and not na(activeORHigh) and not na(activeORLow) and not rangeTooBig
canTradeThisSession = not oneTradePerSession or not tradeTakenThisSession
breakoutOffset      = minBreakoutTicks * syminfo.mintick

//====================================================
// BREAKOUT CANDLE
//====================================================
longBreakout =
     validToTrade and
     canTradeThisSession and
     not longBreakoutSeen and
     close > open and
     math.max(open, close) > (activeORHigh + breakoutOffset)

shortBreakout =
     validToTrade and
     canTradeThisSession and
     not shortBreakoutSeen and
     close < open and
     math.min(open, close) < (activeORLow - breakoutOffset)

if longBreakout
    longBreakoutSeen      := true
    shortBreakoutSeen     := false
    shortRetestArmed      := false
    breakoutBarIndexLong  := bar_index
    breakoutBarIndexShort := na
    retestBarIndexLong    := na
    breakoutLongBodyTop   := math.max(open, close)

if shortBreakout
    shortBreakoutSeen     := true
    longBreakoutSeen      := false
    longRetestArmed       := false
    breakoutBarIndexShort := bar_index
    breakoutBarIndexLong  := na
    retestBarIndexShort   := na
    breakoutShortBodyBot  := math.min(open, close)

//====================================================
// RETEST
//====================================================
touchORLong       = longBreakoutSeen and low <= activeORHigh
touchBelowORLong  = longBreakoutSeen and low < activeORHigh
touchORShort      = shortBreakoutSeen and high >= activeORLow
touchAboveORShort = shortBreakoutSeen and high > activeORLow

touchBullFVG = longBreakoutSeen and not na(bullFVGTop) and not na(bullFVGBot) and low <= bullFVGTop and high >= bullFVGBot
touchBearFVG = shortBreakoutSeen and not na(bearFVGTop) and not na(bearFVGBot) and high >= bearFVGBot and low <= bearFVGTop

longRetestTouch  = touchBelowORLong or touchORLong or touchBullFVG
shortRetestTouch = touchAboveORShort or touchORShort or touchBearFVG

longRetestFound =
     validToTrade and
     canTradeThisSession and
     longBreakoutSeen and
     not longRetestArmed and
     not na(breakoutBarIndexLong) and
     bar_index > breakoutBarIndexLong and
     longRetestTouch

shortRetestFound =
     validToTrade and
     canTradeThisSession and
     shortBreakoutSeen and
     not shortRetestArmed and
     not na(breakoutBarIndexShort) and
     bar_index > breakoutBarIndexShort and
     shortRetestTouch

if longRetestFound
    longRetestArmed    := true
    retestBarIndexLong := bar_index
    retestLongLow      := low

if shortRetestFound
    shortRetestArmed    := true
    retestBarIndexShort := bar_index
    retestShortHigh     := high

//====================================================
// ENTRY TRIGGER
//====================================================
longSignal =
     validToTrade and
     canTradeThisSession and
     longRetestArmed and
     not na(retestBarIndexLong) and
     not na(breakoutLongBodyTop) and
     not na(retestLongLow) and
     bar_index > retestBarIndexLong and
     barstate.isconfirmed and
     close > open and
     close > breakoutLongBodyTop and
     longTrendOk and
     volOk

shortSignal =
     validToTrade and
     canTradeThisSession and
     shortRetestArmed and
     not na(retestBarIndexShort) and
     not na(breakoutShortBodyBot) and
     not na(retestShortHigh) and
     bar_index > retestBarIndexShort and
     barstate.isconfirmed and
     close < open and
     close < breakoutShortBodyBot and
     shortTrendOk and
     volOk

//====================================================
// READY STATE
// Mirrors entry logic exactly, except current bar is not confirmed yet
// If current candle would qualify if it closed now, show countdown
//====================================================
readyLong =
     validToTrade and
     canTradeThisSession and
     longRetestArmed and
     not na(retestBarIndexLong) and
     not na(breakoutLongBodyTop) and
     not na(retestLongLow) and
     bar_index > retestBarIndexLong and
     not barstate.isconfirmed and
     close > open and
     close > breakoutLongBodyTop and
     longTrendOk and
     volOk

readyShort =
     validToTrade and
     canTradeThisSession and
     shortRetestArmed and
     not na(retestBarIndexShort) and
     not na(breakoutShortBodyBot) and
     not na(retestShortHigh) and
     bar_index > retestBarIndexShort and
     not barstate.isconfirmed and
     close < open and
     close < breakoutShortBodyBot and
     shortTrendOk and
     volOk

//====================================================
// CAPTURE LEVELS
//====================================================
longEntry  = longSignal  ? close : na
longSL     = longSignal  ? (retestLongLow - stopBufferPts) : na
longRisk   = longSignal  ? (longEntry - longSL) : na
longTP     = longSignal and longRisk > 0 ? (longEntry + longRisk * tpRR) : na

shortEntry = shortSignal ? close : na
shortSL    = shortSignal ? (retestShortHigh + stopBufferPts) : na
shortRisk  = shortSignal ? (shortSL - shortEntry) : na
shortTP    = shortSignal and shortRisk > 0 ? (shortEntry - shortRisk * tpRR) : na

readyLongEntryEst  = readyLong  ? close : na
readyLongSLEst     = readyLong  ? (retestLongLow - stopBufferPts) : na
readyLongRiskEst   = readyLong  ? (readyLongEntryEst - readyLongSLEst) : na
readyLongTPEst     = readyLong and readyLongRiskEst > 0 ? (readyLongEntryEst + readyLongRiskEst * tpRR) : na

readyShortEntryEst = readyShort ? close : na
readyShortSLEst    = readyShort ? (retestShortHigh + stopBufferPts) : na
readyShortRiskEst  = readyShort ? (readyShortSLEst - readyShortEntryEst) : na
readyShortTPEst    = readyShort and readyShortRiskEst > 0 ? (readyShortEntryEst - readyShortRiskEst * tpRR) : na

//====================================================
// RESET AFTER CAPTURE
//====================================================
if longSignal
    tradeTakenThisSession := true
    longRetestArmed       := false
    longBreakoutSeen      := false
    breakoutBarIndexLong  := na
    retestBarIndexLong    := na
    breakoutLongBodyTop   := na
    retestLongLow         := na

if shortSignal
    tradeTakenThisSession := true
    shortRetestArmed      := false
    shortBreakoutSeen     := false
    breakoutBarIndexShort := na
    retestBarIndexShort   := na
    breakoutShortBodyBot  := na
    retestShortHigh       := na

//====================================================
// LIVE COUNTDOWN BOX
//====================================================
var label countdownLabel = na
secsLeft = barstate.isrealtime ? math.max(0, int((time_close - timenow) / 1000)) : na

if barstate.islast and showReadyCountdown
    label.delete(countdownLabel)

    if readyLong
        countdownText = "READY LONG\n" +
             "Est Entry: " + str.tostring(readyLongEntryEst, format.mintick) + "\n" +
             "SL: " + str.tostring(readyLongSLEst, format.mintick) + "\n" +
             "TP: " + str.tostring(readyLongTPEst, format.mintick) + "\n" +
             "Enter in: " + str.tostring(secsLeft) + "s"

        countdownLabel := label.new(
             bar_index, high, countdownText,
             style=label.style_label_down,
             color=color.new(color.green, 0),
             textcolor=color.white,
             size=size.small)

    else if readyShort
        countdownText = "READY SHORT\n" +
             "Est Entry: " + str.tostring(readyShortEntryEst, format.mintick) + "\n" +
             "SL: " + str.tostring(readyShortSLEst, format.mintick) + "\n" +
             "TP: " + str.tostring(readyShortTPEst, format.mintick) + "\n" +
             "Enter in: " + str.tostring(secsLeft) + "s"

        countdownLabel := label.new(
             bar_index, low, countdownText,
             style=label.style_label_up,
             color=color.new(color.red, 0),
             textcolor=color.white,
             size=size.small)

//====================================================
// ENTRY / SL / TP LINES
//====================================================
var line longEntryLine  = na
var line longSLLine     = na
var line longTPLine     = na
var line shortEntryLine = na
var line shortSLLine    = na
var line shortTPLine    = na

if longSignal and showTargets
    line.delete(longEntryLine)
    line.delete(longSLLine)
    line.delete(longTPLine)

    longEntryLine := line.new(bar_index, longEntry, bar_index + 20, longEntry, extend=extend.none, color=color.white, width=2)
    longSLLine    := line.new(bar_index, longSL,    bar_index + 20, longSL,    extend=extend.none, color=color.red, width=2)
    longTPLine    := line.new(bar_index, longTP,    bar_index + 20, longTP,    extend=extend.none, color=color.lime, width=2)

if shortSignal and showTargets
    line.delete(shortEntryLine)
    line.delete(shortSLLine)
    line.delete(shortTPLine)

    shortEntryLine := line.new(bar_index, shortEntry, bar_index + 20, shortEntry, extend=extend.none, color=color.white, width=2)
    shortSLLine    := line.new(bar_index, shortSL,    bar_index + 20, shortSL,    extend=extend.none, color=color.red, width=2)
    shortTPLine    := line.new(bar_index, shortTP,    bar_index + 20, shortTP,    extend=extend.none, color=color.lime, width=2)

//====================================================
// LABELS / MARKS
//====================================================
plotshape(showEntryMarkers and longSignal,  title="BUY",  style=shape.labelup,   location=location.belowbar, color=color.green, text="BUY",  textcolor=color.white, size=size.small)
plotshape(showEntryMarkers and shortSignal, title="SELL", style=shape.labeldown, location=location.abovebar, color=color.red,   text="SELL", textcolor=color.white, size=size.small)

plotshape(showRetestMarkers and longRetestFound,  title="Long Retest",  style=shape.circle, location=location.belowbar, color=color.new(color.green, 0), size=size.tiny)
plotshape(showRetestMarkers and shortRetestFound, title="Short Retest", style=shape.circle, location=location.abovebar, color=color.new(color.red, 0), size=size.tiny)

plotshape(showRangeWarning and rangeTooBig and sessionActive, title="Range Too Big", style=shape.xcross, location=location.top, color=color.fuchsia, size=size.tiny, text="NO TRADE")

if longSignal and showTargets
    label.new(
         bar_index, low,
         "BUY\n" +
         "Entry: " + str.tostring(longEntry, format.mintick) + "\n" +
         "SL: " + str.tostring(longSL, format.mintick) + "\n" +
         "TP: " + str.tostring(longTP, format.mintick),
         style=label.style_label_up, color=color.green, textcolor=color.white, size=size.small)

if shortSignal and showTargets
    label.new(
         bar_index, high,
         "SELL\n" +
         "Entry: " + str.tostring(shortEntry, format.mintick) + "\n" +
         "SL: " + str.tostring(shortSL, format.mintick) + "\n" +
         "TP: " + str.tostring(shortTP, format.mintick),
         style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)

//====================================================
// 5M WARNING LABEL
//====================================================
var label tfWarnLabel = na

if barstate.islast and showTFWarning
    label.delete(tfWarnLabel)
    if not isFiveMin
        tfWarnLabel := label.new(bar_index, high, "USE ON 5-MINUTE CHART", style=label.style_label_down, color=color.orange, textcolor=color.white, size=size.small)

//====================================================
// ALERTS
//====================================================
alertcondition(longSignal,  title="BUY ALERT",         message="MNQ BUY setup confirmed")
alertcondition(shortSignal, title="SELL ALERT",        message="MNQ SELL setup confirmed")
alertcondition(readyLong,   title="READY LONG ALERT",  message="MNQ possible LONG if current bar closes above stored breakout body top")
alertcondition(readyShort,  title="READY SHORT ALERT", message="MNQ possible SHORT if current bar closes below stored breakout body bottom")
alertcondition(rangeTooBig and sessionActive, title="NO TRADE - RANGE TOO BIG", message="Opening range is too large. No trade allowed.")
````
