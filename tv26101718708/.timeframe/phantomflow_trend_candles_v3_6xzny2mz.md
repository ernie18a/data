# PhantomFlow Trend Candles V3

- url: https://www.tradingview.com/script/6xZny2Mz-PhantomFlow-Trend-Candles-V3/
- type: indicator
- pine_id: PUB;63bf77a3048a4f3ab907c0731f19e08c
- version: 1.0

## Description

What V3 adds
Trend score
This gives you a 0–100 strength read based on:
EMA spread
EMA slope
structure confirmation
structure break
HTF alignment
session alignment
momentum condition
A higher number means the trend state is more convincing.
Dashboard
Top-right panel shows:
current bias
trend score
HTF direction
current state
session status
live trailing stop value
Trailing stop
The trail is ATR-based:
bullish trend → trail below price
bearish trend → trail above price
This is not an order manager, but it gives a very clean visual “stay in / get cautious” line.
Better state reading
Now the candle colors and dashboard work together:
Lime = fresh buy trigger
Fuchsia = fresh sell trigger
Green = bullish hold
Red = bearish hold
Orange = bullish exhaustion
Yellow = bearish exhaustion
Gray = neutral / wait
Best use on Gold
For XAUUSD intraday, I’d start with this:
chart: 5m
HTF: 1H
session filter: ON
session: London + New York
fast EMA: 21
slow EMA: 50
swing confirmation: 3
trail ATR: 1.5
exhaust ATR: 1.8
That is a strong baseline.

## Source Code

````pine
//@version=5
indicator("PhantomFlow Trend Candles V3", shorttitle="PF V3", overlay=true, max_labels_count=500, max_lines_count=500)

//══════════════════════════════════════════════════════════════════════
// INPUTS
//══════════════════════════════════════════════════════════════════════
groupTrend = "Trend"
fastLen        = input.int(21, "Fast EMA", minval=1, group=groupTrend)
slowLen        = input.int(50, "Slow EMA", minval=1, group=groupTrend)
swingLen       = input.int(3, "Swing Confirmation", minval=1, group=groupTrend)
atrLen         = input.int(14, "ATR Length", minval=1, group=groupTrend)
breakAtrBuff   = input.float(0.20, "Structure Break Buffer (ATR)", minval=0.0, step=0.05, group=groupTrend)
pullbackAtr    = input.float(0.60, "Pullback Zone Size (ATR)", minval=0.1, step=0.1, group=groupTrend)

groupEntry = "Entry"
bodyStrength    = input.float(0.55, "Min Body % of Candle Range", minval=0.1, maxval=0.95, step=0.05, group=groupEntry)
firstEntryOnly  = input.bool(true, "First Entry Only Per Trend Leg", group=groupEntry)
showSignals     = input.bool(true, "Show Entry Labels", group=groupEntry)

groupHTF = "Higher Timeframe"
useHTF         = input.bool(true, "Enable HTF Bias Filter", group=groupHTF)
htfTf          = input.timeframe("60", "HTF", group=groupHTF)
htfFastLen     = input.int(21, "HTF Fast EMA", minval=1, group=groupHTF)
htfSlowLen     = input.int(50, "HTF Slow EMA", minval=1, group=groupHTF)

groupSession = "Session Filter"
useSessionFilter = input.bool(false, "Enable Session Filter", group=groupSession)
sessionMode      = input.string("London + New York", "Session Preset", options=["London", "New York", "London + New York", "Custom"], group=groupSession)
customSession    = input.session("0300-1700", "Custom Session", group=groupSession)

groupRisk = "Risk / Trailing Stop"
showTrail       = input.bool(true, "Show Trailing Stop", group=groupRisk)
trailAtrMult    = input.float(1.5, "Trail ATR Multiplier", minval=0.1, step=0.1, group=groupRisk)
trailSource     = input.string("Close", "Trail Source", options=["Close", "HL2"], group=groupRisk)

groupExhaust = "Exhaustion"
showExhaustion  = input.bool(true, "Show Exhaustion Candles", group=groupExhaust)
exhaustAtrMult  = input.float(1.8, "Exhaust Distance From Fast EMA (ATR)", minval=0.5, step=0.1, group=groupExhaust)

groupScore = "Trend Score"
showScoreLabel  = input.bool(false, "Show Score Label On Bars", group=groupScore)
showDashboard   = input.bool(true, "Show Dashboard", group=groupScore)

groupVisual = "Visual"
colorBars      = input.bool(true, "Color Candles", group=groupVisual)
showRibbon     = input.bool(true, "Show EMA Ribbon", group=groupVisual)
showSwingLines = input.bool(false, "Show Swing Levels", group=groupVisual)
showBgTrend    = input.bool(false, "Show Trend Background", group=groupVisual)

//══════════════════════════════════════════════════════════════════════
// CORE CALCULATIONS
//══════════════════════════════════════════════════════════════════════
fastEMA = ta.ema(close, fastLen)
slowEMA = ta.ema(close, slowLen)
atrVal  = ta.atr(atrLen)
srcTrail = trailSource == "HL2" ? hl2 : close

ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

var float lastSwingHigh = na
var float prevSwingHigh = na
var float lastSwingLow  = na
var float prevSwingLow  = na

if not na(ph)
    prevSwingHigh := lastSwingHigh
    lastSwingHigh := ph

if not na(pl)
    prevSwingLow := lastSwingLow
    lastSwingLow := pl

hasHighs = not na(lastSwingHigh) and not na(prevSwingHigh)
hasLows  = not na(lastSwingLow) and not na(prevSwingLow)

higherHigh = hasHighs and lastSwingHigh > prevSwingHigh
lowerHigh  = hasHighs and lastSwingHigh < prevSwingHigh
higherLow  = hasLows and lastSwingLow > prevSwingLow
lowerLow   = hasLows and lastSwingLow < prevSwingLow

bullStructure = higherHigh and higherLow
bearStructure = lowerHigh and lowerLow

bullBreak = hasHighs and close > lastSwingHigh + atrVal * breakAtrBuff
bearBreak = hasLows and close < lastSwingLow - atrVal * breakAtrBuff

emaBull = fastEMA > slowEMA and fastEMA > fastEMA[1] and slowEMA > slowEMA[1]
emaBear = fastEMA < slowEMA and fastEMA < fastEMA[1] and slowEMA < slowEMA[1]

baseTrendUp = (emaBull and bullStructure) or bullBreak
baseTrendDn = (emaBear and bearStructure) or bearBreak

//══════════════════════════════════════════════════════════════════════
// HTF FILTER
//══════════════════════════════════════════════════════════════════════
htfFast = request.security(syminfo.tickerid, htfTf, ta.ema(close, htfFastLen), barmerge.gaps_off, barmerge.lookahead_off)
htfSlow = request.security(syminfo.tickerid, htfTf, ta.ema(close, htfSlowLen), barmerge.gaps_off, barmerge.lookahead_off)

htfBull = htfFast > htfSlow
htfBear = htfFast < htfSlow

//══════════════════════════════════════════════════════════════════════
// SESSION FILTER
//══════════════════════════════════════════════════════════════════════
sessionStr =
     sessionMode == "London" ? "0300-1100" :
     sessionMode == "New York" ? "0800-1700" :
     sessionMode == "London + New York" ? "0300-1700" :
     customSession

inSession = not na(time(timeframe.period, sessionStr))
sessionOk = not useSessionFilter or inSession

//══════════════════════════════════════════════════════════════════════
// FINAL BIAS
//══════════════════════════════════════════════════════════════════════
trendUp = baseTrendUp and (not useHTF or htfBull)
trendDn = baseTrendDn and (not useHTF or htfBear)

//══════════════════════════════════════════════════════════════════════
// ENTRY LOGIC
//══════════════════════════════════════════════════════════════════════
bullValueZoneTop = math.max(fastEMA, slowEMA) + atrVal * pullbackAtr
bearValueZoneBot = math.min(fastEMA, slowEMA) - atrVal * pullbackAtr

inBullValue = trendUp and low <= bullValueZoneTop and close >= slowEMA
inBearValue = trendDn and high >= bearValueZoneBot and close <= slowEMA

barRange   = math.max(high - low, syminfo.mintick)
bullBodyOk = close > open and (close - open) / barRange >= bodyStrength
bearBodyOk = open > close and (open - close) / barRange >= bodyStrength

bullMomentum = close > fastEMA and close > high[1] and bullBodyOk
bearMomentum = close < fastEMA and close < low[1] and bearBodyOk

rawLongEntry  = inBullValue[1] and bullMomentum and sessionOk
rawShortEntry = inBearValue[1] and bearMomentum and sessionOk

//══════════════════════════════════════════════════════════════════════
// TREND LEG / FIRST ENTRY CONTROL
//══════════════════════════════════════════════════════════════════════
var int trendState = 0
var bool longArmed = false
var bool shortArmed = false

newBullTrend = trendUp and trendState != 1
newBearTrend = trendDn and trendState != -1
lostTrend    = not trendUp and not trendDn

if newBullTrend
    trendState := 1
    longArmed := true
    shortArmed := false
else if newBearTrend
    trendState := -1
    shortArmed := true
    longArmed := false
else if lostTrend
    trendState := 0

longEntry = firstEntryOnly ? (rawLongEntry and longArmed) : rawLongEntry
shortEntry = firstEntryOnly ? (rawShortEntry and shortArmed) : rawShortEntry

if longEntry
    longArmed := false
if shortEntry
    shortArmed := false

//══════════════════════════════════════════════════════════════════════
// EXHAUSTION
//══════════════════════════════════════════════════════════════════════
bullExhausted = showExhaustion and trendUp and (close - fastEMA) > atrVal * exhaustAtrMult
bearExhausted = showExhaustion and trendDn and (fastEMA - close) > atrVal * exhaustAtrMult

//══════════════════════════════════════════════════════════════════════
// TREND SCORE
// 0 to 100, then directed into bull / bear interpretation
//══════════════════════════════════════════════════════════════════════
emaSpreadScoreRaw = math.abs(fastEMA - slowEMA) / atrVal * 25.0
emaSpreadScore = math.min(25.0, emaSpreadScoreRaw)

emaSlopeBull = fastEMA > fastEMA[1] and slowEMA > slowEMA[1]
emaSlopeBear = fastEMA < fastEMA[1] and slowEMA < slowEMA[1]
emaSlopeScore = (emaSlopeBull or emaSlopeBear) ? 20.0 : 0.0

structureScore =
     bullStructure or bearStructure ? 20.0 : 0.0

breakScore =
     bullBreak or bearBreak ? 20.0 : 0.0

htfScore =
     not useHTF ? 0.0 : ((trendUp and htfBull) or (trendDn and htfBear) ? 10.0 : 0.0)

sessionScore =
     sessionOk ? 5.0 : 0.0

momentumScore =
     bullMomentum or bearMomentum ? 10.0 : 0.0

rawScore = emaSpreadScore + emaSlopeScore + structureScore + breakScore + htfScore + sessionScore + momentumScore
trendScore = math.round(math.min(100.0, rawScore))

scoreDirection =
     trendUp ? trendScore :
     trendDn ? -trendScore :
     0

//══════════════════════════════════════════════════════════════════════
// TRAILING STOP
//══════════════════════════════════════════════════════════════════════
var float trailLong = na
var float trailShort = na

if trendUp
    baseLongTrail = srcTrail - atrVal * trailAtrMult
    trailLong := na(trailLong[1]) or newBullTrend ? baseLongTrail : math.max(trailLong[1], baseLongTrail)
else
    trailLong := na

if trendDn
    baseShortTrail = srcTrail + atrVal * trailAtrMult
    trailShort := na(trailShort[1]) or newBearTrend ? baseShortTrail : math.min(trailShort[1], baseShortTrail)
else
    trailShort := na

//══════════════════════════════════════════════════════════════════════
// CANDLE STATES
//══════════════════════════════════════════════════════════════════════
bullHold = trendUp and not longEntry
bearHold = trendDn and not shortEntry
weakBull = bullHold and close < fastEMA
weakBear = bearHold and close > fastEMA

barCol =
     longEntry      ? color.lime :
     shortEntry     ? color.fuchsia :
     bullExhausted  ? color.orange :
     bearExhausted  ? color.yellow :
     weakBull       ? color.new(color.green, 55) :
     weakBear       ? color.new(color.red, 55) :
     bullHold       ? color.new(color.green, 0) :
     bearHold       ? color.new(color.red, 0) :
                      color.new(color.gray, 55)

//══════════════════════════════════════════════════════════════════════
// VISUALS
//══════════════════════════════════════════════════════════════════════
fastPlot = plot(showRibbon ? fastEMA : na, "Fast EMA", color=color.new(color.aqua, 0), linewidth=1)
slowPlot = plot(showRibbon ? slowEMA : na, "Slow EMA", color=color.new(color.blue, 20), linewidth=2)

ribbonCol =
     trendUp ? color.new(color.green, 88) :
     trendDn ? color.new(color.red, 88) :
               color.new(color.gray, 92)

fill(fastPlot, slowPlot, showRibbon ? ribbonCol : na, title="Trend Ribbon")

plot(showSwingLines ? lastSwingHigh : na, "Last Swing High", color=color.new(color.red, 50), style=plot.style_linebr)
plot(showSwingLines ? lastSwingLow : na, "Last Swing Low", color=color.new(color.green, 50), style=plot.style_linebr)

plot(showTrail and trendUp ? trailLong : na, "Bull Trail", color=color.new(color.lime, 0), linewidth=2, style=plot.style_linebr)
plot(showTrail and trendDn ? trailShort : na, "Bear Trail", color=color.new(color.fuchsia, 0), linewidth=2, style=plot.style_linebr)

bgcolor(showBgTrend ? (trendUp ? color.new(color.green, 94) : trendDn ? color.new(color.red, 94) : na) : na)

barcolor(colorBars ? barCol : na)

//══════════════════════════════════════════════════════════════════════
// LABELS
//══════════════════════════════════════════════════════════════════════
plotshape(showSignals and longEntry, title="BUY", style=shape.labelup, location=location.belowbar, color=color.lime, text="BUY", textcolor=color.black, size=size.tiny)
plotshape(showSignals and shortEntry, title="SELL", style=shape.labeldown, location=location.abovebar, color=color.fuchsia, text="SELL", textcolor=color.white, size=size.tiny)

plotshape(showSignals and bullExhausted and not longEntry, title="Bull Exhaustion", style=shape.circle, location=location.abovebar, color=color.orange, size=size.tiny)
plotshape(showSignals and bearExhausted and not shortEntry, title="Bear Exhaustion", style=shape.circle, location=location.belowbar, color=color.yellow, size=size.tiny)

if showScoreLabel and barstate.islast
    label.new(bar_index, high, "Score: " + str.tostring(trendScore), style=label.style_label_down, textcolor=color.white, color=color.new(color.black, 0))

//══════════════════════════════════════════════════════════════════════
// DASHBOARD
//══════════════════════════════════════════════════════════════════════
var table dash = table.new(position.top_right, 2, 6, border_width=1)

biasText =
     trendUp ? "BULLISH" :
     trendDn ? "BEARISH" :
               "NEUTRAL"

biasColor =
     trendUp ? color.new(color.green, 0) :
     trendDn ? color.new(color.red, 0) :
               color.new(color.gray, 20)

htfText =
     htfBull ? "HTF BULL" :
     htfBear ? "HTF BEAR" :
               "HTF FLAT"

entryText =
     longEntry ? "BUY TRIGGER" :
     shortEntry ? "SELL TRIGGER" :
     bullExhausted ? "BULL EXHAUST" :
     bearExhausted ? "BEAR EXHAUST" :
     bullHold ? "BULL HOLD" :
     bearHold ? "BEAR HOLD" :
     "WAIT"

entryColor =
     longEntry ? color.lime :
     shortEntry ? color.fuchsia :
     bullExhausted ? color.orange :
     bearExhausted ? color.yellow :
     bullHold ? color.new(color.green, 20) :
     bearHold ? color.new(color.red, 20) :
     color.new(color.gray, 30)

sessionText = sessionOk ? "SESSION OK" : "OUTSIDE SESSION"

scoreText = str.tostring(trendScore) + "/100"

trailText =
     trendUp and showTrail and not na(trailLong) ? str.tostring(trailLong, format.mintick) :
     trendDn and showTrail and not na(trailShort) ? str.tostring(trailShort, format.mintick) :
     "N/A"

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "Bias", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 0, biasText, text_color=color.white, bgcolor=biasColor)

    table.cell(dash, 0, 1, "Trend Score", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 1, scoreText, text_color=color.white, bgcolor=color.new(color.blue, 55))

    table.cell(dash, 0, 2, "HTF", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 2, htfText, text_color=color.white, bgcolor=color.new(color.purple, 55))

    table.cell(dash, 0, 3, "State", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 3, entryText, text_color=color.black, bgcolor=entryColor)

    table.cell(dash, 0, 4, "Session", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 4, sessionText, text_color=color.white, bgcolor=color.new(color.teal, 55))

    table.cell(dash, 0, 5, "Trail", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 5, trailText, text_color=color.white, bgcolor=color.new(color.orange, 65))

//══════════════════════════════════════════════════════════════════════
// ALERTS
//══════════════════════════════════════════════════════════════════════
alertcondition(longEntry, "BUY Entry", "PF V3 BUY on {{ticker}}")
alertcondition(shortEntry, "SELL Entry", "PF V3 SELL on {{ticker}}")
alertcondition(newBullTrend, "New Bull Trend", "PF V3 new bullish trend on {{ticker}}")
alertcondition(newBearTrend, "New Bear Trend", "PF V3 new bearish trend on {{ticker}}")
alertcondition(bullExhausted, "Bull Exhaustion", "PF V3 bullish exhaustion on {{ticker}}")
alertcondition(bearExhausted, "Bear Exhaustion", "PF V3 bearish exhaustion on {{ticker}}")
````
