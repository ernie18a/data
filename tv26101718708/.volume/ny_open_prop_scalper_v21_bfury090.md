# NY Open Prop Scalper V2.1

- url: https://www.tradingview.com/script/BFURy090-NY-Open-Prop-Scalper-V2-1/
- type: indicator
- pine_id: PUB;26fd14a1fc7541cebb9bc5ab46fb1147
- version: 1.0

## Description

John Bush is testing this for my team. This is merely a test and should not be used as a trade indicator yet.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mrbushllc

//@version=5
indicator("NY Open Prop Scalper V2.1", overlay=true, max_labels_count=500, max_lines_count=500)

// ======================================================
// 1. INPUTS
// ======================================================

// Session
groupSession = "Session Settings"
sessionInput = input.session("0930-1100", "Active Session", group=groupSession)
sessionTZ    = input.string("America/New_York", "Session Timezone", group=groupSession)

// EMA Settings
groupEMA = "EMA Settings"
emaFastLen = input.int(9,  "Fast EMA", minval=1, group=groupEMA)
emaMidLen  = input.int(20, "Mid EMA",  minval=1, group=groupEMA)
emaSlowLen = input.int(50, "Slow EMA", minval=1, group=groupEMA)

// Score Settings
groupScore = "Score Settings"
minScoreThreshold = input.int(7, "Minimum Score Threshold", minval=1, maxval=10, group=groupScore)
showCTrades       = input.bool(false, "Show C Trades", group=groupScore)

// Volatility Settings
groupVol = "Volatility Filter"
atrLen = input.int(14, "ATR Length", minval=1, group=groupVol)
atrMin = input.float(4.0, "Minimum ATR", step=0.1, group=groupVol)

// Chase Filter
groupChase = "Chase Filter"
candleAvgLen      = input.int(10, "Average Candle Length", minval=1, group=groupChase)
maxCandleMultiple = input.float(1.8, "Max Candle Expansion Multiplier", step=0.1, group=groupChase)

// Stop Filter
groupStop = "Stop Filter"
swingLookback = input.int(10, "Swing Lookback", minval=2, group=groupStop)
maxStopDist   = input.float(80.0, "Max Stop Distance (points)", step=0.1, group=groupStop)

// Trigger Logic
groupTrigger = "Trigger Logic"
requireTrendSlope  = input.bool(false, "Require EMA 9 Slope In Signal Direction", group=groupTrigger)
allowCrossTrigger  = input.bool(true, "Allow EMA 9 / VWAP Cross Trigger", group=groupTrigger)
allowPullbackEntry = input.bool(true, "Allow Pullback Resume Trigger", group=groupTrigger)

// Structure Logic
groupStructure = "Structure Logic"
pivotLeft     = input.int(2, "Pivot Left Bars", minval=1, group=groupStructure)
pivotRight    = input.int(2, "Pivot Right Bars", minval=1, group=groupStructure)
sweepLookback = input.int(5, "Sweep Confirmation Lookback", minval=2, group=groupStructure)
useSweepBonus = input.bool(true, "Use Sweep Confirmation In Structure", group=groupStructure)

// Signal Management
groupSignal = "Signal Management"
cooldownBars = input.int(1, "Cooldown Bars", minval=0, group=groupSignal)

// Visuals
groupVisual = "Visual Settings"
showLabels    = input.bool(true, "Show Trade Labels", group=groupVisual)
showScoreText = input.bool(true, "Show Score In Labels", group=groupVisual)
showInfoBox   = input.bool(true, "Show Info Box", group=groupVisual)
showGuideLine = input.bool(true, "Show 3-Bar Guide Line", group=groupVisual)
showSwings    = input.bool(false, "Show Swing Levels", group=groupVisual)

// ======================================================
// 2. SESSION FILTER
// ======================================================

inSession = not na(time(timeframe.period, sessionInput, sessionTZ))

// ======================================================
// 3. CORE CALCULATIONS
// ======================================================

emaFast   = ta.ema(close, emaFastLen)
emaMid    = ta.ema(close, emaMidLen)
emaSlow   = ta.ema(close, emaSlowLen)
vwapValue = ta.vwap(hlc3)
atrValue  = ta.atr(atrLen)

candleRange    = high - low
avgCandleRange = ta.sma(candleRange, candleAvgLen)
chaseBlocked   = candleRange > (avgCandleRange * maxCandleMultiple)

emaFastSlopeUp   = emaFast > emaFast[1]
emaFastSlopeDown = emaFast < emaFast[1]

// ======================================================
// 4. TREND STRUCTURE
// ======================================================

bullStack = emaFast > emaMid and emaMid > emaSlow
bearStack = emaFast < emaMid and emaMid < emaSlow

aboveVWAP = close > vwapValue
belowVWAP = close < vwapValue

// ======================================================
// 5. HIGHER TIMEFRAME REQUESTS
// ======================================================

emaFast15 = request.security(syminfo.tickerid, "15", ta.ema(close, emaFastLen))
emaMid15  = request.security(syminfo.tickerid, "15", ta.ema(close, emaMidLen))
emaSlow15 = request.security(syminfo.tickerid, "15", ta.ema(close, emaSlowLen))
close15   = request.security(syminfo.tickerid, "15", close)

bullBias15 = emaFast15 > emaMid15 and emaMid15 > emaSlow15 and close15 > emaMid15
bearBias15 = emaFast15 < emaMid15 and emaMid15 < emaSlow15 and close15 < emaMid15

emaFast5 = request.security(syminfo.tickerid, "5", ta.ema(close, emaFastLen))
emaMid5  = request.security(syminfo.tickerid, "5", ta.ema(close, emaMidLen))
emaSlow5 = request.security(syminfo.tickerid, "5", ta.ema(close, emaSlowLen))
close5   = request.security(syminfo.tickerid, "5", close)
vwap5    = request.security(syminfo.tickerid, "5", ta.vwap(hlc3))

bullAlign5 = emaFast5 > emaMid5 and emaMid5 > emaSlow5 and close5 > vwap5
bearAlign5 = emaFast5 < emaMid5 and emaMid5 < emaSlow5 and close5 < vwap5

bullAlign1 = bullStack and aboveVWAP
bearAlign1 = bearStack and belowVWAP

multiTFBull = bullAlign5 and bullAlign1
multiTFBear = bearAlign5 and bearAlign1

// ======================================================
// 6. TRIGGER LOGIC - RELAXED
// ======================================================

// Trigger A: EMA 9 crossing VWAP
bullVWAPCross = allowCrossTrigger and ta.crossover(emaFast, vwapValue)
bearVWAPCross = allowCrossTrigger and ta.crossunder(emaFast, vwapValue)

// Trigger B: simple pullback resume
bullPullbackResume =
     allowPullbackEntry and
     bullStack and
     aboveVWAP and
     low <= emaFast and
     close > open

bearPullbackResume =
     allowPullbackEntry and
     bearStack and
     belowVWAP and
     high >= emaFast and
     close < open

bullTriggerRaw = bullVWAPCross or bullPullbackResume
bearTriggerRaw = bearVWAPCross or bearPullbackResume

bullTrigger = requireTrendSlope ? (bullTriggerRaw and emaFastSlopeUp) : bullTriggerRaw
bearTrigger = requireTrendSlope ? (bearTriggerRaw and emaFastSlopeDown) : bearTriggerRaw

// ======================================================
// 7. STRUCTURE LOGIC - SCORES ONLY
// ======================================================

recentHigh = ta.highest(high[1], swingLookback)
recentLow  = ta.lowest(low[1], swingLookback)

bullBreakBase = high > recentHigh
bearBreakBase = low < recentLow

pivotHigh = ta.pivothigh(high, pivotLeft, pivotRight)
pivotLow  = ta.pivotlow(low, pivotLeft, pivotRight)

var float lastSwingHigh = na
var float lastSwingLow  = na

if not na(pivotHigh)
    lastSwingHigh := pivotHigh

if not na(pivotLow)
    lastSwingLow := pivotLow

bullBreakSwing = not na(lastSwingHigh) and close > lastSwingHigh
bearBreakSwing = not na(lastSwingLow) and close < lastSwingLow

sweptLowThenClosedUp =
     low < ta.lowest(low[1], sweepLookback) and close > open

sweptHighThenClosedDown =
     high > ta.highest(high[1], sweepLookback) and close < open

bullSweepConfirm = useSweepBonus ? sweptLowThenClosedUp : false
bearSweepConfirm = useSweepBonus ? sweptHighThenClosedDown : false

bullStructureBreak = bullBreakBase or bullBreakSwing or bullSweepConfirm
bearStructureBreak = bearBreakBase or bearBreakSwing or bearSweepConfirm

// ======================================================
// 8. SAFETY FILTERS
// ======================================================

volatilityPass = atrValue >= atrMin

bullStop = ta.lowest(low, swingLookback)
bearStop = ta.highest(high, swingLookback)

bullStopDist = close - bullStop
bearStopDist = bearStop - close

bullStopPass = bullStopDist <= maxStopDist and bullStopDist > 0
bearStopPass = bearStopDist <= maxStopDist and bearStopDist > 0

// ======================================================
// 9. SCORE ENGINE
// ======================================================

longScoreBias      = bullBias15         ? 2 : 0
longScoreEMA       = bullStack          ? 2 : 0
longScoreVWAP      = aboveVWAP          ? 2 : 0
longScoreTrigger   = bullTrigger        ? 2 : 0
longScoreStructure = bullStructureBreak ? 1 : 0
longScoreMTF       = multiTFBull        ? 1 : 0
longScore = longScoreBias + longScoreEMA + longScoreVWAP + longScoreTrigger + longScoreStructure + longScoreMTF

shortScoreBias      = bearBias15         ? 2 : 0
shortScoreEMA       = bearStack          ? 2 : 0
shortScoreVWAP      = belowVWAP          ? 2 : 0
shortScoreTrigger   = bearTrigger        ? 2 : 0
shortScoreStructure = bearStructureBreak ? 1 : 0
shortScoreMTF       = multiTFBear        ? 1 : 0
shortScore = shortScoreBias + shortScoreEMA + shortScoreVWAP + shortScoreTrigger + shortScoreStructure + shortScoreMTF

// ======================================================
// 10. GRADE LOGIC
// ======================================================

f_grade(_score) =>
    _score >= 9 ? "A" : _score >= 7 ? "B" : "C"

longGrade  = f_grade(longScore)
shortGrade = f_grade(shortScore)

// ======================================================
// 11. FINAL SIGNAL CONDITIONS - RELAXED
// ======================================================

var int lastLongSignalBar  = na
var int lastShortSignalBar = na

longCooldownPass  = na(lastLongSignalBar) or (bar_index - lastLongSignalBar > cooldownBars)
shortCooldownPass = na(lastShortSignalBar) or (bar_index - lastShortSignalBar > cooldownBars)

longScorePass  = longScore >= minScoreThreshold
shortScorePass = shortScore >= minScoreThreshold

showLongC  = showCTrades and longGrade == "C"
showShortC = showCTrades and shortGrade == "C"

longGradeVisible  = longScorePass or showLongC
shortGradeVisible = shortScorePass or showShortC

longSignal =
     inSession and
     longGradeVisible and
     volatilityPass and
     not chaseBlocked and
     bullStopPass and
     bullTrigger and
     longCooldownPass

shortSignal =
     inSession and
     shortGradeVisible and
     volatilityPass and
     not chaseBlocked and
     bearStopPass and
     bearTrigger and
     shortCooldownPass

if longSignal
    lastLongSignalBar := bar_index

if shortSignal
    lastShortSignalBar := bar_index

// ======================================================
// 12. PLOTTING CORE INDICATORS
// ======================================================

plot(emaFast, "EMA 9", linewidth=2, color=color.aqua)
plot(emaMid,  "EMA 20", linewidth=2, color=color.orange)
plot(emaSlow, "EMA 50", linewidth=2, color=color.red)
plot(vwapValue, "VWAP", linewidth=2, color=color.purple)

plot(showSwings ? lastSwingHigh : na, "Last Swing High", color=color.new(#01795b, 21), style=plot.style_linebr)
plot(showSwings ? lastSwingLow  : na, "Last Swing Low",  color=color.new(#c74205, 25), style=plot.style_linebr)

// ======================================================
// 13. LABELS
// ======================================================

f_labelText(_grade, _dir, _score) =>
    showScoreText ? (_grade + " " + _dir + " | " + str.tostring(_score)) : (_grade + " " + _dir)

if showLabels and longSignal
    label.new(
         bar_index, low,
         f_labelText(longGrade, "LONG", longScore),
         style=label.style_label_up,
         textcolor=color.white,
         color=longGrade == "A" ? color.rgb(11, 255, 19) : longGrade == "B" ? color.teal : color.gray,
         size=size.small
     )

if showLabels and shortSignal
    label.new(
         bar_index, high,
         f_labelText(shortGrade, "SHORT", shortScore),
         style=label.style_label_down,
         textcolor=color.white,
         color=shortGrade == "A" ? color.rgb(255, 0, 0) : shortGrade == "B" ? color.orange : color.gray,
         size=size.small
     )

// ======================================================
// 14. GUIDE LINES
// ======================================================

if showGuideLine and longSignal
    line.new(bar_index, close, bar_index + 3, close, extend=extend.none, style=line.style_dotted, width=1, color=color.new(color.green, 0))

if showGuideLine and shortSignal
    line.new(bar_index, close, bar_index + 3, close, extend=extend.none, style=line.style_dotted, width=1, color=color.new(color.red, 0))

// ======================================================
// 15. INFO PANEL
// ======================================================

var table infoTbl = table.new(position.top_right, 2, 12, border_width=1)

biasText =
     bullBias15 ? "Bullish" :
     bearBias15 ? "Bearish" : "Neutral"

vwapText =
     aboveVWAP ? "Above" :
     belowVWAP ? "Below" : "At VWAP"

sessionText = inSession ? "Yes" : "No"
atrText     = volatilityPass ? "Pass" : "Fail"
chaseText   = chaseBlocked ? "Blocked" : "Pass"
triggerText =
     bullTrigger ? "Bull" :
     bearTrigger ? "Bear" : "None"

structureText =
     bullStructureBreak ? "Bull" :
     bearStructureBreak ? "Bear" : "None"

if showInfoBox and barstate.islast
    table.cell(infoTbl, 0, 0, "15m Bias")
    table.cell(infoTbl, 1, 0, biasText)

    table.cell(infoTbl, 0, 1, "Long Score")
    table.cell(infoTbl, 1, 1, str.tostring(longScore))

    table.cell(infoTbl, 0, 2, "Short Score")
    table.cell(infoTbl, 1, 2, str.tostring(shortScore))

    table.cell(infoTbl, 0, 3, "Long Grade")
    table.cell(infoTbl, 1, 3, longGrade)

    table.cell(infoTbl, 0, 4, "Short Grade")
    table.cell(infoTbl, 1, 4, shortGrade)

    table.cell(infoTbl, 0, 5, "VWAP Side")
    table.cell(infoTbl, 1, 5, vwapText)

    table.cell(infoTbl, 0, 6, "Session Active")
    table.cell(infoTbl, 1, 6, sessionText)

    table.cell(infoTbl, 0, 7, "ATR Filter")
    table.cell(infoTbl, 1, 7, atrText)

    table.cell(infoTbl, 0, 8, "Chase Filter")
    table.cell(infoTbl, 1, 8, chaseText)

    table.cell(infoTbl, 0, 9, "5m + 1m Align")
    table.cell(infoTbl, 1, 9, multiTFBull ? "Bull" : multiTFBear ? "Bear" : "No")

    table.cell(infoTbl, 0, 10, "Trigger")
    table.cell(infoTbl, 1, 10, triggerText)

    table.cell(infoTbl, 0, 11, "Structure")
    table.cell(infoTbl, 1, 11, structureText)

// ======================================================
// 16. ALERT CONDITIONS
// ======================================================

alertcondition(longSignal and longGrade == "A", "A LONG", "NY Open Prop Scalper: A LONG")
alertcondition(longSignal and longGrade == "B", "B LONG", "NY Open Prop Scalper: B LONG")
alertcondition(shortSignal and shortGrade == "A", "A SHORT", "NY Open Prop Scalper: A SHORT")
alertcondition(shortSignal and shortGrade == "B", "B SHORT", "NY Open Prop Scalper: B SHORT")
````
