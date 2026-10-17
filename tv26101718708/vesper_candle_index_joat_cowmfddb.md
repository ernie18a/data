# Vesper Candle Index [JOAT]

- url: https://www.tradingview.com/script/cOwmfdDB-Vesper-Candle-Index-JOAT/
- type: indicator
- pine_id: PUB;c9598f35a7554e218987c2081006b904
- version: 1.0

## Description

[b]Vesper Candle Index [JOAT][/b]

[b]Introduction[/b]

Vesper Candle Index is an open-source candlestick classification engine. Instead of marking every common candle pattern equally, it scores candle patterns using body quality, wick structure, trend location, volatility, and nearby structure context.

The indicator is designed to reduce pattern noise by ranking candle events and displaying only those that meet a configurable quality threshold.

[image]https://www.tradingview.com/x/wtrAVFbs/[/image]

[b]Core Concepts[/b]

[b]1. Candle Pattern Library[/b]

The script evaluates multiple candlestick states, including engulfing candles, hammers, stars, harami, inside breaks, marubozu, tweezers, rail patterns, and reclaim/reject conditions.

[b]2. Quality Scoring[/b]

Each candidate pattern receives a score based on candle body, wick placement, trend context, volatility, and structure alignment.

[b]3. Structure Context[/b]

Confirmed pivot levels are used to detect CHoCH-style breaks and candle reactions near recent structure.

[b]4. Trade Projection Labels[/b]

When a candle state qualifies, the script can display compact educational entry, stop, TP1, and TP2 information.

[b]5. Dashboard[/b]

The dashboard shows the current candle state, quality bucket, trend, structure, and recent signal context.

[b]Features[/b]

[list]
[*][b]Ranked candle states:[/b] Patterns are scored rather than treated equally
[*][b]Structure-aware candles:[/b] Uses pivots and CHoCH context
[*][b]Volatility-adjusted logic:[/b] ATR helps normalize wick and body requirements
[*][b]Cooldown control:[/b] Reduces repeated pattern labels
[*][b]Compact dashboard:[/b] Summarizes the highest-ranked current candle state
[*][b]Confirmed patterns:[/b] Pattern events use confirmed bars
[/list]

[b]Input Parameters[/b]

[list]
[*]Pattern sensitivity controls the quality threshold
[*]Pivot length controls structure confirmation
[*]ATR settings control wick/body normalization
[*]Rail projection settings control optional visual projection length
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Focus on high-quality states[/b]

Use the quality score to separate strong candle states from weaker pattern appearances.

[b]Step 2: Check structure alignment[/b]

Candle events near relevant structure are often more meaningful than isolated patterns.

[b]Step 3: Avoid treating patterns as certainty[/b]

Candlestick patterns describe current bar behavior. They do not predict continuation or reversal.

[b]Indicator Limitations[/b]

[list]
[*]Candle patterns can fail in strong trend or news conditions
[*]Pivot-based structure is delayed by the selected pivot length
[*]The script classifies candles; it does not forecast future direction
[/list]

[b]Originality Statement[/b]

Vesper Candle Index adds scoring, structure context, volatility normalization, cooldown behavior, and a dashboard to candlestick analysis. Its value is in ranking candle quality rather than simply labeling every pattern.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Candlestick patterns can be misleading when used alone.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Vesper Candle Index [JOAT]", shorttitle="VCI [JOAT]", overlay=true, max_labels_count=300, max_lines_count=220, max_boxes_count=120)

// Vesper Candle Index is a ranked candlestick engine. It does not fire on
// every candle pattern. It waits for confirmed bars, scores the best pattern
// against trend, regression location, momentum, volume, wick rejection, and
// structure context, then renders only clean entry-state objects.

//--------------------------------------------------------------------------
// Institutional palette
//--------------------------------------------------------------------------
bullColor       = color.rgb(48, 214, 189)
bearColor       = color.rgb(236, 92, 140)
controlColor    = color.rgb(82, 185, 255)
volColor        = color.rgb(92, 126, 255)
strongBullColor = color.rgb(114, 255, 188)
strongBearColor = color.rgb(255, 96, 180)
neutralColor    = color.rgb(143, 152, 171)
darkPanel       = color.rgb(10, 14, 20)
darkCell        = color.rgb(24, 28, 36)
hudBg           = color.new(darkPanel, 12)
hudBorder       = color.new(color.rgb(56, 64, 82), 38)

//--------------------------------------------------------------------------
// Inputs
//--------------------------------------------------------------------------
groupCore = "Core"
fastLen = input.int(21, "Fast EMA", minval=2, group=groupCore)
slowLen = input.int(55, "Slow EMA", minval=3, group=groupCore)
regLen = input.int(90, "Regression context length", minval=20, maxval=240, group=groupCore)
rsiLen = input.int(14, "RSI length", minval=2, group=groupCore)
atrLen = input.int(14, "ATR length", minval=2, group=groupCore)

groupStructure = "Structure"
pivotLeft = input.int(4, "Pivot left", minval=1, group=groupStructure)
pivotRight = input.int(4, "Pivot right", minval=1, group=groupStructure)
structureWeight = input.float(1.0, "Structure score weight", minval=0.25, maxval=2.0, step=0.05, group=groupStructure)

groupSignals = "Signals"
minScore = input.int(82, "Minimum accepted score", minval=35, maxval=98, group=groupSignals)
cooldownBars = input.int(16, "Signal cooldown bars", minval=0, maxval=80, group=groupSignals)
showSignalLabels = input.bool(true, "Show signal labels", group=groupSignals)
showZones = input.bool(true, "Show signal zones", group=groupSignals)
showRails = input.bool(true, "Show entry/exit rails", group=groupSignals)

groupRisk = "Risk"
stopAtrBuffer = input.float(0.55, "Stop ATR buffer", minval=0.05, step=0.05, group=groupRisk)
tpOneR = input.float(1.0, "TP1 R multiple", minval=0.25, step=0.25, group=groupRisk)
tpTwoR = input.float(1.45, "TP2 R multiple", minval=0.5, step=0.25, group=groupRisk)
tpThreeR = input.float(2.5, "TP3 R multiple", minval=0.75, step=0.25, group=groupRisk)
railBars = input.int(20, "Rail projection bars", minval=6, maxval=100, group=groupRisk)

groupVisual = "Visuals"
showTint = input.bool(true, "Tint accepted candles", group=groupVisual)
showContextChannel = input.bool(false, "Show regression field", group=groupVisual)
showEmaCloud = input.bool(true, "Show EMA cloud", group=groupVisual)
showStructureLevels = input.bool(false, "Show structure levels", group=groupVisual)

groupHud = "Dashboard"
showHud = input.bool(true, "Show Architect HUD", group=groupHud)
hudSizeInput = input.string("Small", "HUD size", options=["Tiny", "Small", "Normal"], group=groupHud)

groupPerf = "Performance"
maxLabels = input.int(28, "Maximum labels", minval=20, maxval=250, group=groupPerf)
maxBoxes = input.int(24, "Maximum boxes", minval=10, maxval=100, group=groupPerf)
maxLines = input.int(48, "Maximum lines", minval=20, maxval=220, group=groupPerf)

//--------------------------------------------------------------------------
// Utility functions
//--------------------------------------------------------------------------
f_clamp(float value, float lo, float hi) =>
    math.min(math.max(value, lo), hi)

f_size(string choice) =>
    choice == "Tiny" ? size.tiny : choice == "Normal" ? size.normal : size.small

f_context_text(int context) =>
    context == 1 ? "BULL CONTEXT" : context == -1 ? "BEAR CONTEXT" : "MIXED CONTEXT"

f_bucket(float score) =>
    score >= 90 ? "S5" : score >= 82 ? "S4" : score >= 74 ? "S3" : score >= minScore ? "S2" : "S1"

f_bucket_color(int direction, float score) =>
    blend = f_clamp((score - 45.0) / 55.0, 0.0, 1.0)
    direction == 1 ? color.from_gradient(blend, 0.0, 1.0, bullColor, strongBullColor) :
     direction == -1 ? color.from_gradient(blend, 0.0, 1.0, bearColor, strongBearColor) :
     neutralColor

f_trim_labels(array<label> store, int maxCount) =>
    while array.size(store) > maxCount
        label oldLabel = array.shift(store)
        label.delete(oldLabel)

f_trim_boxes(array<box> store, int maxCount) =>
    while array.size(store) > maxCount
        box oldBox = array.shift(store)
        box.delete(oldBox)

f_trim_lines(array<line> store, int maxCount) =>
    while array.size(store) > maxCount
        line oldLine = array.shift(store)
        line.delete(oldLine)

f_new_rail(array<line> store, int startBar, float price, int endBar, color railColor, string railStyle, int railWidth) =>
    line rail = line.new(startBar, price, endBar, price, xloc=xloc.bar_index, extend=extend.none, color=railColor, style=railStyle, width=railWidth)
    array.push(store, rail)

f_rank(int direction, float baseScore, int trendState, bool locationMatch, bool structureMatch, bool momentumMatch, bool volumeMatch, bool wickMatch, float slopePower) =>
    score = baseScore
    score += trendState == direction ? 13.0 : trendState == 0 ? 5.0 : -11.0
    score += locationMatch ? 13.0 : 0.0
    score += structureMatch ? 17.0 * structureWeight : 0.0
    score += momentumMatch ? 8.0 : -2.0
    score += volumeMatch ? 7.0 : 0.0
    score += wickMatch ? 7.0 : 0.0
    score += f_clamp(slopePower, 0.0, 9.0)
    score

//--------------------------------------------------------------------------
// Context engine
//--------------------------------------------------------------------------
fastEma = ta.ema(close, fastLen)
slowEma = ta.ema(close, slowLen)
atr = ta.atr(atrLen)
rsiValue = ta.rsi(close, rsiLen)
regBase = ta.linreg(close, regLen, 0)
regSlope = regBase - regBase[1]
regDev = ta.stdev(close - regBase, regLen)
regUpper = regBase + regDev * 1.35
regLower = regBase - regDev * 1.35
regMidUpper = regBase + regDev * 0.45
regMidLower = regBase - regDev * 0.45

trendState = fastEma > slowEma and regSlope >= 0 ? 1 : fastEma < slowEma and regSlope <= 0 ? -1 : 0
trendColor = trendState == 1 ? bullColor : trendState == -1 ? bearColor : neutralColor
nearLowerField = close <= regMidLower or low <= regLower
nearUpperField = close >= regMidUpper or high >= regUpper
slopePower = atr > 0.0 ? math.abs(regSlope) / atr * 100.0 : 0.0

ph = ta.pivothigh(high, pivotLeft, pivotRight)
pl = ta.pivotlow(low, pivotLeft, pivotRight)
var float lastHigh = na
var float lastLow = na

if not na(ph)
    lastHigh := ph

if not na(pl)
    lastLow := pl

chochUp = barstate.isconfirmed and not na(lastHigh) and close > lastHigh and close[1] <= lastHigh
chochDn = barstate.isconfirmed and not na(lastLow) and close < lastLow and close[1] >= lastLow

volAvg = ta.sma(volume, 30)
volRatio = volAvg > 0.0 ? volume / volAvg : 1.0
volumeExpansion = volRatio >= 1.25

//--------------------------------------------------------------------------
// Candle anatomy and pattern library
//--------------------------------------------------------------------------
barRange = math.max(high - low, syminfo.mintick)
body = math.abs(close - open)
bodyPct = body / barRange
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
closePos = (close - low) / barRange
bullBody = close > open
bearBody = close < open
strongBody = bodyPct >= 0.55
thinBody = bodyPct <= 0.24
wickBull = lowerWick >= body * 1.45 and closePos >= 0.58
wickBear = upperWick >= body * 1.45 and closePos <= 0.42
momentumBull = rsiValue > 50 and rsiValue > rsiValue[1]
momentumBear = rsiValue < 50 and rsiValue < rsiValue[1]
locationBull = nearLowerField or trendState == 1 and close > fastEma
locationBear = nearUpperField or trendState == -1 and close < fastEma
structureBull = chochUp or not na(lastHigh) and close > lastHigh
structureBear = chochDn or not na(lastLow) and close < lastLow

// Confirmed pattern definitions. These are original combinations using classic
// candle ideas plus institutional context filters.
bullEngulf = barstate.isconfirmed and bullBody and bearBody[1] and open <= close[1] and close >= open[1] and body >= body[1] * 0.75
bearEngulf = barstate.isconfirmed and bearBody and bullBody[1] and open >= close[1] and close <= open[1] and body >= body[1] * 0.75
hammer = barstate.isconfirmed and bullBody and lowerWick >= body * 1.8 and upperWick <= barRange * 0.22 and closePos >= 0.60
invertedHammer = barstate.isconfirmed and bullBody and upperWick >= body * 1.65 and closePos >= 0.48 and nearLowerField
shootingStar = barstate.isconfirmed and bearBody and upperWick >= body * 1.8 and lowerWick <= barRange * 0.22 and closePos <= 0.40
hangingMan = barstate.isconfirmed and bearBody and lowerWick >= body * 1.65 and nearUpperField and closePos <= 0.55
morningStar = barstate.isconfirmed and bearBody[2] and math.abs(close[1] - open[1]) / math.max(high[1] - low[1], syminfo.mintick) <= 0.38 and bullBody and close > (open[2] + close[2]) * 0.5
eveningStar = barstate.isconfirmed and bullBody[2] and math.abs(close[1] - open[1]) / math.max(high[1] - low[1], syminfo.mintick) <= 0.38 and bearBody and close < (open[2] + close[2]) * 0.5
piercing = barstate.isconfirmed and bearBody[1] and bullBody and open < close[1] and close > (open[1] + close[1]) * 0.5 and close < open[1]
darkCloud = barstate.isconfirmed and bullBody[1] and bearBody and open > close[1] and close < (open[1] + close[1]) * 0.5 and close > open[1]
haramiBull = barstate.isconfirmed and bearBody[1] and bullBody and high <= high[1] and low >= low[1] and close > open[1]
haramiBear = barstate.isconfirmed and bullBody[1] and bearBody and high <= high[1] and low >= low[1] and close < open[1]
insideBreakUp = barstate.isconfirmed and high[1] < high[2] and low[1] > low[2] and close > high[1]
insideBreakDn = barstate.isconfirmed and high[1] < high[2] and low[1] > low[2] and close < low[1]
marubozuBull = barstate.isconfirmed and bullBody and bodyPct >= 0.78 and closePos >= 0.82 and lowerWick <= barRange * 0.12
marubozuBear = barstate.isconfirmed and bearBody and bodyPct >= 0.78 and closePos <= 0.18 and upperWick <= barRange * 0.12
threeSoldiers = barstate.isconfirmed and bullBody and bullBody[1] and bullBody[2] and close > close[1] and close[1] > close[2] and bodyPct >= 0.45
threeCrows = barstate.isconfirmed and bearBody and bearBody[1] and bearBody[2] and close < close[1] and close[1] < close[2] and bodyPct >= 0.45
tweezerLow = barstate.isconfirmed and math.abs(low - low[1]) <= atr * 0.12 and bearBody[1] and bullBody and closePos >= 0.62
tweezerHigh = barstate.isconfirmed and math.abs(high - high[1]) <= atr * 0.12 and bullBody[1] and bearBody and closePos <= 0.38
railBull = barstate.isconfirmed and bearBody[1] and bullBody and bodyPct >= 0.5 and math.abs(body - body[1]) <= atr * 0.28 and close > high[1]
railBear = barstate.isconfirmed and bullBody[1] and bearBody and bodyPct >= 0.5 and math.abs(body - body[1]) <= atr * 0.28 and close < low[1]
reclaimBull = barstate.isconfirmed and low < lastLow and close > lastLow and wickBull and not na(lastLow)
rejectBear = barstate.isconfirmed and high > lastHigh and close < lastHigh and wickBear and not na(lastHigh)

//--------------------------------------------------------------------------
// Pattern ranking
//--------------------------------------------------------------------------
var float bestScore = 0.0
var int bestDir = 0
var string bestName = ""
var string bestClass = ""

bestScore := 0.0
bestDir := 0
bestName := ""
bestClass := ""

engBullScore = bullEngulf ? f_rank(1, 52.0, trendState, locationBull, structureBull, momentumBull, volumeExpansion, wickBull, slopePower) : 0.0
engBearScore = bearEngulf ? f_rank(-1, 52.0, trendState, locationBear, structureBear, momentumBear, volumeExpansion, wickBear, slopePower) : 0.0
hammerScore = hammer ? f_rank(1, 48.0, trendState, locationBull, structureBull, momentumBull, volumeExpansion, true, slopePower) : 0.0
invHammerScore = invertedHammer ? f_rank(1, 43.0, trendState, locationBull, structureBull, momentumBull, volumeExpansion, true, slopePower) : 0.0
starBearScore = shootingStar ? f_rank(-1, 48.0, trendState, locationBear, structureBear, momentumBear, volumeExpansion, true, slopePower) : 0.0
hangingScore = hangingMan ? f_rank(-1, 43.0, trendState, locationBear, structureBear, momentumBear, volumeExpansion, true, slopePower) : 0.0
morningScore = morningStar ? f_rank(1, 57.0, trendState, locationBull, structureBull, momentumBull, volumeExpansion, wickBull, slopePower) : 0.0
eveningScore = eveningStar ? f_rank(-1, 57.0, trendState, locationBear, structureBear, momentumBear, volumeExpansion, wickBear, slopePower) : 0.0
piercingScore = piercing ? f_rank(1, 50.0, trendState, locationBull, structureBull, momentumBull, volumeExpansion, wickBull, slopePower) : 0.0
darkCloudScore = darkCloud ? f_rank(-1, 50.0, trendState, locationBear, structureBear, momentumBear, volumeExpansion, wickBear, slopePower) : 0.0
haramiBullScore = haramiBull ? f_rank(1, 42.0, trendState, locationBull, structureBull, momentumBull, volumeExpansion, wickBull, slopePower) : 0.0
haramiBearScore = haramiBear ? f_rank(-1, 42.0, trendState, locationBear, structureBear, momentumBear, volumeExpansion, wickBear, slopePower) : 0.0
insideUpScore = insideBreakUp ? f_rank(1, 49.0, trendState, close > fastEma, structureBull, momentumBull, volumeExpansion, strongBody, slopePower) : 0.0
insideDnScore = insideBreakDn ? f_rank(-1, 49.0, trendState, close < fastEma, structureBear, momentumBear, volumeExpansion, strongBody, slopePower) : 0.0
maruBullScore = marubozuBull ? f_rank(1, 47.0, trendState, close > fastEma, structureBull, momentumBull, volumeExpansion, strongBody, slopePower) : 0.0
maruBearScore = marubozuBear ? f_rank(-1, 47.0, trendState, close < fastEma, structureBear, momentumBear, volumeExpansion, strongBody, slopePower) : 0.0
soldierScore = threeSoldiers ? f_rank(1, 55.0, trendState, close > fastEma, structureBull, momentumBull, volumeExpansion, strongBody, slopePower) : 0.0
crowScore = threeCrows ? f_rank(-1, 55.0, trendState, close < fastEma, structureBear, momentumBear, volumeExpansion, strongBody, slopePower) : 0.0
tweezerBullScore = tweezerLow ? f_rank(1, 45.0, trendState, locationBull, structureBull, momentumBull, volumeExpansion, wickBull, slopePower) : 0.0
tweezerBearScore = tweezerHigh ? f_rank(-1, 45.0, trendState, locationBear, structureBear, momentumBear, volumeExpansion, wickBear, slopePower) : 0.0
railBullScore = railBull ? f_rank(1, 51.0, trendState, close > fastEma, structureBull, momentumBull, volumeExpansion, strongBody, slopePower) : 0.0
railBearScore = railBear ? f_rank(-1, 51.0, trendState, close < fastEma, structureBear, momentumBear, volumeExpansion, strongBody, slopePower) : 0.0
reclaimScore = reclaimBull ? f_rank(1, 58.0, trendState, true, true, momentumBull, volumeExpansion, true, slopePower) : 0.0
rejectScore = rejectBear ? f_rank(-1, 58.0, trendState, true, true, momentumBear, volumeExpansion, true, slopePower) : 0.0

if engBullScore > bestScore
    bestScore := engBullScore
    bestDir := 1
    bestName := "Engulf"
    bestClass := "Reversal"
if engBearScore > bestScore
    bestScore := engBearScore
    bestDir := -1
    bestName := "Engulf"
    bestClass := "Reversal"
if hammerScore > bestScore
    bestScore := hammerScore
    bestDir := 1
    bestName := "Hammer"
    bestClass := "Rejection"
if invHammerScore > bestScore
    bestScore := invHammerScore
    bestDir := 1
    bestName := "Inverted"
    bestClass := "Rejection"
if starBearScore > bestScore
    bestScore := starBearScore
    bestDir := -1
    bestName := "Star"
    bestClass := "Rejection"
if hangingScore > bestScore
    bestScore := hangingScore
    bestDir := -1
    bestName := "Hanging"
    bestClass := "Rejection"
if morningScore > bestScore
    bestScore := morningScore
    bestDir := 1
    bestName := "Morning"
    bestClass := "Sequence"
if eveningScore > bestScore
    bestScore := eveningScore
    bestDir := -1
    bestName := "Evening"
    bestClass := "Sequence"
if piercingScore > bestScore
    bestScore := piercingScore
    bestDir := 1
    bestName := "Pierce"
    bestClass := "Reclaim"
if darkCloudScore > bestScore
    bestScore := darkCloudScore
    bestDir := -1
    bestName := "Cloud"
    bestClass := "Reject"
if haramiBullScore > bestScore
    bestScore := haramiBullScore
    bestDir := 1
    bestName := "Harami"
    bestClass := "Compression"
if haramiBearScore > bestScore
    bestScore := haramiBearScore
    bestDir := -1
    bestName := "Harami"
    bestClass := "Compression"
if insideUpScore > bestScore
    bestScore := insideUpScore
    bestDir := 1
    bestName := "Inside"
    bestClass := "Break"
if insideDnScore > bestScore
    bestScore := insideDnScore
    bestDir := -1
    bestName := "Inside"
    bestClass := "Break"
if maruBullScore > bestScore
    bestScore := maruBullScore
    bestDir := 1
    bestName := "Drive"
    bestClass := "Expansion"
if maruBearScore > bestScore
    bestScore := maruBearScore
    bestDir := -1
    bestName := "Drive"
    bestClass := "Expansion"
if soldierScore > bestScore
    bestScore := soldierScore
    bestDir := 1
    bestName := "Advance"
    bestClass := "Sequence"
if crowScore > bestScore
    bestScore := crowScore
    bestDir := -1
    bestName := "Decline"
    bestClass := "Sequence"
if tweezerBullScore > bestScore
    bestScore := tweezerBullScore
    bestDir := 1
    bestName := "Tweezer"
    bestClass := "Reversal"
if tweezerBearScore > bestScore
    bestScore := tweezerBearScore
    bestDir := -1
    bestName := "Tweezer"
    bestClass := "Reversal"
if railBullScore > bestScore
    bestScore := railBullScore
    bestDir := 1
    bestName := "Rail"
    bestClass := "Shift"
if railBearScore > bestScore
    bestScore := railBearScore
    bestDir := -1
    bestName := "Rail"
    bestClass := "Shift"
if reclaimScore > bestScore
    bestScore := reclaimScore
    bestDir := 1
    bestName := "Reclaim"
    bestClass := "Sweep"
if rejectScore > bestScore
    bestScore := rejectScore
    bestDir := -1
    bestName := "Reject"
    bestClass := "Sweep"

var int lastSignalBar = na
cooldownReady = na(lastSignalBar) or bar_index - lastSignalBar > cooldownBars
acceptedSignal = barstate.isconfirmed and cooldownReady and bestScore >= minScore and bestDir != 0
if acceptedSignal
    lastSignalBar := bar_index

//--------------------------------------------------------------------------
// Risk levels and signal objects
//--------------------------------------------------------------------------
longStop = math.min(low, low[1]) - atr * stopAtrBuffer
shortStop = math.max(high, high[1]) + atr * stopAtrBuffer
longRisk = math.max(close - longStop, syminfo.mintick)
shortRisk = math.max(shortStop - close, syminfo.mintick)
longTp1 = close + longRisk * tpOneR
longTp2 = close + longRisk * tpTwoR
longTp3 = close + longRisk * tpThreeR
shortTp1 = close - shortRisk * tpOneR
shortTp2 = close - shortRisk * tpTwoR
shortTp3 = close - shortRisk * tpThreeR

var array<label> signalLabels = array.new<label>()
var array<box> signalBoxes = array.new<box>()
var array<line> signalRails = array.new<line>()

if acceptedSignal and showZones
    riskColor = strongBearColor
    rewardColor = strongBullColor
    entryPrice = close
    stopPrice = bestDir == 1 ? longStop : shortStop
    tpTwoPrice = bestDir == 1 ? longTp2 : shortTp2
    rewardTop = math.max(entryPrice, tpTwoPrice)
    rewardBottom = math.min(entryPrice, tpTwoPrice)
    riskTop = math.max(entryPrice, stopPrice)
    riskBottom = math.min(entryPrice, stopPrice)
    array.push(signalBoxes, box.new(bar_index, rewardTop, bar_index + railBars, rewardBottom, xloc=xloc.bar_index, border_color=color.new(rewardColor, 18), bgcolor=color.new(rewardColor, 88)))
    array.push(signalBoxes, box.new(bar_index, riskTop, bar_index + railBars, riskBottom, xloc=xloc.bar_index, border_color=color.new(riskColor, 18), bgcolor=color.new(riskColor, 88)))

if acceptedSignal and showRails
    railEnd = bar_index + railBars
    railColor = bestDir == 1 ? bullColor : bearColor
    f_new_rail(signalRails, bar_index, close, railEnd, color.new(color.white, 2), line.style_solid, 2)
    f_new_rail(signalRails, bar_index, bestDir == 1 ? longStop : shortStop, railEnd, color.new(bestDir == 1 ? bearColor : bullColor, 5), line.style_solid, 2)
    f_new_rail(signalRails, bar_index, bestDir == 1 ? longTp1 : shortTp1, railEnd, color.new(railColor, 22), line.style_solid, 1)
    f_new_rail(signalRails, bar_index, bestDir == 1 ? longTp2 : shortTp2, railEnd, color.new(railColor, 8), line.style_solid, 2)

if acceptedSignal and showSignalLabels
    railEnd = bar_index + railBars
    stopPrice = bestDir == 1 ? longStop : shortStop
    tpOnePrice = bestDir == 1 ? longTp1 : shortTp1
    tpTwoPrice = bestDir == 1 ? longTp2 : shortTp2
    labelText = (bestDir == 1 ? "BUY CANDLE" : "SELL CANDLE") + "\n" + bestName + " " + f_bucket(bestScore) + "\nQ " + str.tostring(math.round(bestScore)) + "\nEntry " + str.tostring(close, format.mintick) + "\nStop " + str.tostring(stopPrice, format.mintick) + "\nTP1 " + str.tostring(tpOnePrice, format.mintick) + "\nTP2 " + str.tostring(tpTwoPrice, format.mintick)
    label sigLabel = label.new(railEnd, close, labelText, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(f_bucket_color(bestDir, bestScore), 7), textcolor=color.white, size=size.small)
    array.push(signalLabels, sigLabel)

f_trim_labels(signalLabels, maxLabels)
f_trim_boxes(signalBoxes, maxBoxes)
f_trim_lines(signalRails, maxLines)

//--------------------------------------------------------------------------
// Visual rendering
//--------------------------------------------------------------------------
signalTint = acceptedSignal ? f_bucket_color(bestDir, bestScore) : trendColor
neutralTint = thinBody ? color.new(controlColor, 15) : color.new(neutralColor, 40)
barcolor(showTint ? acceptedSignal ? color.new(signalTint, 0) : color.new(trendState == 0 ? neutralTint : trendColor, 45) : na)

fastPlot = plot(showEmaCloud ? fastEma : na, "Fast context EMA", color=color.new(trendColor, 10), linewidth=1)
slowPlot = plot(showEmaCloud ? slowEma : na, "Slow context EMA", color=color.new(neutralColor, 35), linewidth=1)
fill(fastPlot, slowPlot, color=showEmaCloud ? color.new(trendColor, 90) : na, title="EMA context cloud")

regPlot = plot(showContextChannel ? regBase : na, "Regression spine", color=color.new(controlColor, 10), linewidth=2)
regUpPlot = plot(showContextChannel ? regUpper : na, "Regression upper", color=color.new(bullColor, 42), linewidth=1)
regDnPlot = plot(showContextChannel ? regLower : na, "Regression lower", color=color.new(bearColor, 42), linewidth=1)
fill(regUpPlot, regDnPlot, color=showContextChannel ? color.new(volColor, 92) : na, title="Architect regression field")

plot(showStructureLevels ? lastHigh : na, "Last structure high", color=color.new(bearColor, 78), linewidth=1, style=plot.style_linebr)
plot(showStructureLevels ? lastLow : na, "Last structure low", color=color.new(bullColor, 78), linewidth=1, style=plot.style_linebr)

//--------------------------------------------------------------------------
// HUD
//--------------------------------------------------------------------------
var table architectHud = table.new(position.top_right, 2, 8, frame_color=hudBorder, border_color=hudBorder, bgcolor=hudBg)

if barstate.islast and showHud
    table.cell(architectHud, 0, 0, "VESPER CANDLE", text_color=color.white, bgcolor=color.new(controlColor, 60), text_size=f_size(hudSizeInput))
    table.cell(architectHud, 1, 0, "JOAT", text_color=color.white, bgcolor=color.new(volColor, 70), text_size=f_size(hudSizeInput))
    table.cell(architectHud, 0, 1, "Context", text_color=color.white, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(architectHud, 1, 1, f_context_text(trendState), text_color=trendColor, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(architectHud, 0, 2, "Best candle", text_color=color.white, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(architectHud, 1, 2, bestName == "" ? "NONE" : bestName, text_color=bestDir == 1 ? bullColor : bestDir == -1 ? bearColor : neutralColor, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(architectHud, 0, 3, "Class", text_color=color.white, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(architectHud, 1, 3, bestClass == "" ? "WAIT" : bestClass, text_color=bestScore >= minScore ? controlColor : neutralColor, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(architectHud, 0, 4, "Score", text_color=color.white, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(architectHud, 1, 4, str.tostring(math.round(bestScore)) + " / " + f_bucket(bestScore), text_color=bestScore >= minScore ? f_bucket_color(bestDir, bestScore) : neutralColor, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(architectHud, 0, 5, "RSI / Vol", text_color=color.white, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(architectHud, 1, 5, str.tostring(rsiValue, format.mintick) + " / " + str.tostring(volRatio, format.mintick), text_color=volumeExpansion ? controlColor : neutralColor, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(architectHud, 0, 6, "Structure", text_color=color.white, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(architectHud, 1, 6, chochUp ? "BULL CHoCH" : chochDn ? "BEAR CHoCH" : "STABLE", text_color=chochUp ? bullColor : chochDn ? bearColor : neutralColor, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(architectHud, 0, 7, "Cooldown", text_color=color.white, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(architectHud, 1, 7, cooldownReady ? "READY" : "LOCKED", text_color=cooldownReady ? bullColor : neutralColor, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))

//--------------------------------------------------------------------------
// Alerts
//--------------------------------------------------------------------------
alertcondition(acceptedSignal and bestDir == 1, "VCI long candle", "Vesper Candle Index [JOAT] confirmed a bullish candle state.")
alertcondition(acceptedSignal and bestDir == -1, "VCI short candle", "Vesper Candle Index [JOAT] confirmed a bearish candle state.")
alertcondition(chochUp, "VCI bullish CHoCH", "Vesper Candle Index [JOAT] confirmed bullish structure change.")
alertcondition(chochDn, "VCI bearish CHoCH", "Vesper Candle Index [JOAT] confirmed bearish structure change.")
````
