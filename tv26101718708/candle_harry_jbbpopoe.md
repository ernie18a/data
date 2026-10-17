# Candle Harry

- url: https://www.tradingview.com/script/jBBpoPoE-Candle-Harry/
- type: indicator
- pine_id: PUB;1b6f2b6e38d34529a9f98a6621e55711
- version: 4.0

## Description

Candle Harry detects strong candlestick reversal and continuation patterns with trend context, strength scoring, multi-timeframe scanner, and alerts.

This version includes a Support/Resistance filter, so bullish patterns appear near support zones and bearish patterns appear near resistance zones. It helps reduce middle-zone noise and focuses only on stronger top/bottom market areas.

Features:

* Strong candlestick pattern detection
* Bullish and bearish pattern labels
* Pattern strength score from 0–10
* Support/Resistance zone filter
* Multi-timeframe scanner
* Pattern zone highlighting
* Alert support

Best for:
Crypto, Forex, Stocks, and Index charts.

Note:
This is an indicator, not a strategy. It does not execute trades or calculate profit/loss. Always use risk management and confirm signals with your own analysis.

## Source Code

````pine
//@version=6
indicator("Candle Harry - Pattern Context Scanner", shorttitle="Candle Harry", overlay=true, max_labels_count=300, max_boxes_count=300, max_lines_count=100)

// This is a clean rewrite based on standard candlestick pattern definitions.
// It adds trend context, pivot-zone filtering, strength scoring, alerts, and a compact scanner.
// Inputs
gDetect = "Pattern Detection"
dojiPct = input.float(8.0, "Doji max body (% range)", minval=1.0, maxval=25.0, step=0.5, group=gDetect)
smallBodyPct = input.float(38.0, "Small body max (% range)", minval=10.0, maxval=70.0, step=1.0, group=gDetect)
longShadowMult = input.float(2.0, "Long shadow minimum (x body)", minval=1.0, maxval=6.0, step=0.1, group=gDetect)
maruPct = input.float(85.0, "Marubozu body minimum (% range)", minval=65.0, maxval=99.0, step=1.0, group=gDetect)
minAtrRange = input.float(0.35, "Minimum candle size (x ATR)", minval=0.0, maxval=3.0, step=0.05, group=gDetect)
minBarsBetween = input.int(2, "Minimum bars between signals", minval=0, maxval=50, group=gDetect)

gContext = "Trend And Zones"
useTrend = input.bool(true, "Require trend context", group=gContext)
emaLen = input.int(50, "Trend EMA length", minval=5, maxval=400, group=gContext)
trendLookback = input.int(8, "Prior trend lookback", minval=2, maxval=80, group=gContext)
useZones = input.bool(true, "Require support/resistance zone", group=gContext)
pivotLeft = input.int(10, "Pivot left bars", minval=2, maxval=50, group=gContext)
pivotRight = input.int(5, "Pivot right bars", minval=1, maxval=25, group=gContext)
zoneAtr = input.float(1.5, "Zone distance (x ATR)", minval=0.1, maxval=5.0, step=0.1, group=gContext)
showLevels = input.bool(false, "Show latest pivot levels", group=gContext)

gFilter = "Signal Filter"
strongOnly = input.bool(true, "Show strong signals only", group=gFilter)
strongMin = input.float(7.5, "Strong score minimum", minval=0.0, maxval=10.0, step=0.5, group=gFilter)
directionFilter = input.string("Both", "Direction", options=["Both", "Bullish only", "Bearish only"], group=gFilter)

gDisplay = "Display"
showLabels = input.bool(true, "Show labels", group=gDisplay)
showZones = input.bool(true, "Highlight pattern range", group=gDisplay)
maxSignals = input.int(120, "Maximum drawn signals", minval=25, maxval=300, group=gDisplay)
labelSizeInput = input.string("Small", "Label size", options=["Tiny", "Small", "Normal"], group=gDisplay)
showTable = input.bool(true, "Show scanner table", group=gDisplay)
tablePosInput = input.string("Top right", "Table position", options=["Top right", "Top center", "Bottom right"], group=gDisplay)

gColor = "Colors"
bullColor = input.color(#2196f3, "Bullish", group=gColor)
bearColor = input.color(#ff5722, "Bearish", group=gColor)
neutralColor = input.color(#9e9e9e, "Neutral", group=gColor)

gAlert = "Alerts"
enableAlerts = input.bool(true, "Enable alert calls", group=gAlert)
alertStrongOnly = input.bool(false, "Alert strong signals only", group=gAlert)

// Core candle values
atr = ta.atr(14)
emaTrend = ta.ema(close, emaLen)
rng = math.max(high - low, syminfo.mintick)
bodyHigh = math.max(open, close)
bodyLow = math.min(open, close)
body = math.max(bodyHigh - bodyLow, syminfo.mintick)
upper = high - bodyHigh
lower = bodyLow - low
bodyPct = body / rng * 100.0
isBull = close > open
isBear = close < open

o1 = open[1]
c1 = close[1]
h1 = high[1]
l1 = low[1]
body1 = math.max(math.abs(c1 - o1), syminfo.mintick)
range1 = math.max(h1 - l1, syminfo.mintick)
bull1 = c1 > o1
bear1 = c1 < o1

o2 = open[2]
c2 = close[2]
h2 = high[2]
l2 = low[2]
body2 = math.max(math.abs(c2 - o2), syminfo.mintick)
range2 = math.max(h2 - l2, syminfo.mintick)
bull2 = c2 > o2
bear2 = c2 < o2

// Trend context
enoughBars = bar_index > trendLookback + 5
priorMove = enoughBars ? close[1] - close[trendLookback + 1] : 0.0
priorUp = enoughBars and priorMove > atr * 0.30 and close[1] > emaTrend[1]
priorDown = enoughBars and priorMove < -atr * 0.30 and close[1] < emaTrend[1]
bullReversalContext = not useTrend or priorDown
bearReversalContext = not useTrend or priorUp
bullContinuationContext = not useTrend or priorUp
bearContinuationContext = not useTrend or priorDown

// Support/resistance context
ph = ta.pivothigh(high, pivotLeft, pivotRight)
pl = ta.pivotlow(low, pivotLeft, pivotRight)
var float lastResistance = na
var float lastSupport = na
if not na(ph)
    lastResistance := ph
if not na(pl)
    lastSupport := pl

nearSupport = not useZones or (not na(lastSupport) and math.abs(low - lastSupport) <= atr * zoneAtr)
nearResistance = not useZones or (not na(lastResistance) and math.abs(high - lastResistance) <= atr * zoneAtr)

// Quality helpers
sizeScore = math.min(1.0, rng / math.max(atr * 1.25, syminfo.mintick))
trendScoreBull = math.min(1.0, math.abs(priorMove) / math.max(atr * trendLookback * 0.25, syminfo.mintick))
trendScoreBear = trendScoreBull

score(float shapeScore, float contextScore) =>
    raw = 10.0 * (shapeScore * 0.55 + sizeScore * 0.25 + contextScore * 0.20)
    math.round(math.min(10.0, math.max(0.0, raw)) * 10.0) / 10.0

isLargeEnough = minAtrRange <= 0.0 or rng >= atr * minAtrRange
isSmallBody = bodyPct <= smallBodyPct
isDoji = bodyPct <= dojiPct

// Pattern definitions
hammer = isSmallBody and not isDoji and lower >= body * longShadowMult and upper <= body * 0.75
invertedHammer = isSmallBody and not isDoji and upper >= body * longShadowMult and lower <= body * 0.75
dragonflyDoji = isDoji and lower >= rng * 0.55 and upper <= rng * 0.15
gravestoneDoji = isDoji and upper >= rng * 0.55 and lower <= rng * 0.15
longLeggedDoji = isDoji and upper >= rng * 0.25 and lower >= rng * 0.25
marubozuBull = isBull and bodyPct >= maruPct
marubozuBear = isBear and bodyPct >= maruPct

prevBodyHigh = math.max(o1, c1)
prevBodyLow = math.min(o1, c1)
currBodyHigh = math.max(open, close)
currBodyLow = math.min(open, close)
bullEngulf = bear1 and isBull and currBodyHigh >= prevBodyHigh and currBodyLow <= prevBodyLow and body >= body1
bearEngulf = bull1 and isBear and currBodyHigh >= prevBodyHigh and currBodyLow <= prevBodyLow and body >= body1
bullHarami = bear1 and isBull and currBodyHigh <= prevBodyHigh and currBodyLow >= prevBodyLow and body1 > body * 1.25
bearHarami = bull1 and isBear and currBodyHigh <= prevBodyHigh and currBodyLow >= prevBodyLow and body1 > body * 1.25

prevMid = (o1 + c1) / 2.0
piercing = bear1 and isBull and open < low[1] and close > prevMid and close < open[1]
darkCloud = bull1 and isBear and open > high[1] and close < prevMid and close > open[1]
tweezerTol = atr * 0.10
tweezerBottom = bear1 and isBull and math.abs(low - low[1]) <= tweezerTol
tweezerTop = bull1 and isBear and math.abs(high - high[1]) <= tweezerTol

smallMiddle = body1 <= ((body2 + body) / 2.0) * 0.55
morningStar = bear2 and smallMiddle and isBull and close > (o2 + c2) / 2.0
eveningStar = bull2 and smallMiddle and isBear and close < (o2 + c2) / 2.0
threeSoldiers = isBull and bull1 and bull2 and close > close[1] and close[1] > close[2] and bodyPct > 45 and body1 / range1 > 0.45 and body2 / range2 > 0.45
threeCrows = isBear and bear1 and bear2 and close < close[1] and close[1] < close[2] and bodyPct > 45 and body1 / range1 > 0.45 and body2 / range2 > 0.45

// Best-pattern selection
var string bestName = ""
var int bestDir = 0
var float bestScore = 0.0
var int bestSpan = 1

bestName := ""
bestDir := 0
bestScore := 0.0
bestSpan := 1

shapeHammer = math.min(1.0, lower / math.max(body * longShadowMult * 1.25, syminfo.mintick))
shapeInv = math.min(1.0, upper / math.max(body * longShadowMult * 1.25, syminfo.mintick))
shapeStrongBody = math.min(1.0, bodyPct / maruPct)
shapeBodyPair = math.min(1.0, body / math.max(body1, syminfo.mintick))

float candidate = 0.0

candidate := hammer and bullReversalContext and nearSupport and isLargeEnough ? score(shapeHammer, trendScoreBull) : 0.0
if candidate > bestScore
    bestName := "Hammer"

    bestDir := 1

    bestScore := candidate

    bestSpan := 1
candidate := hammer and bearReversalContext and nearResistance and isLargeEnough ? score(shapeHammer, trendScoreBear) : 0.0
if candidate > bestScore
    bestName := "Hanging Man"

    bestDir := -1

    bestScore := candidate

    bestSpan := 1
candidate := invertedHammer and bullReversalContext and nearSupport and isLargeEnough ? score(shapeInv, trendScoreBull) : 0.0
if candidate > bestScore
    bestName := "Inverted Hammer"

    bestDir := 1

    bestScore := candidate

    bestSpan := 1
candidate := invertedHammer and bearReversalContext and nearResistance and isLargeEnough ? score(shapeInv, trendScoreBear) : 0.0
if candidate > bestScore
    bestName := "Shooting Star"

    bestDir := -1

    bestScore := candidate

    bestSpan := 1
candidate := dragonflyDoji and bullReversalContext and nearSupport and isLargeEnough ? score(0.85, trendScoreBull) : 0.0
if candidate > bestScore
    bestName := "Dragonfly Doji"

    bestDir := 1

    bestScore := candidate

    bestSpan := 1
candidate := gravestoneDoji and bearReversalContext and nearResistance and isLargeEnough ? score(0.85, trendScoreBear) : 0.0
if candidate > bestScore
    bestName := "Gravestone Doji"

    bestDir := -1

    bestScore := candidate

    bestSpan := 1
candidate := longLeggedDoji and (nearSupport or nearResistance) and isLargeEnough ? score(0.70, trendScoreBull) : 0.0
if candidate > bestScore
    bestName := "Long-Legged Doji"

    bestDir := 0

    bestScore := candidate

    bestSpan := 1
candidate := marubozuBull and bullContinuationContext and nearSupport and isLargeEnough ? score(shapeStrongBody, trendScoreBull) : 0.0
if candidate > bestScore
    bestName := "Bullish Marubozu"

    bestDir := 1

    bestScore := candidate

    bestSpan := 1
candidate := marubozuBear and bearContinuationContext and nearResistance and isLargeEnough ? score(shapeStrongBody, trendScoreBear) : 0.0
if candidate > bestScore
    bestName := "Bearish Marubozu"

    bestDir := -1

    bestScore := candidate

    bestSpan := 1
candidate := bullEngulf and bullReversalContext and nearSupport and isLargeEnough ? score(shapeBodyPair, trendScoreBull) : 0.0
if candidate > bestScore
    bestName := "Bullish Engulfing"

    bestDir := 1

    bestScore := candidate

    bestSpan := 2
candidate := bearEngulf and bearReversalContext and nearResistance and isLargeEnough ? score(shapeBodyPair, trendScoreBear) : 0.0
if candidate > bestScore
    bestName := "Bearish Engulfing"

    bestDir := -1

    bestScore := candidate

    bestSpan := 2
candidate := bullHarami and bullReversalContext and nearSupport and isLargeEnough ? score(0.75, trendScoreBull) : 0.0
if candidate > bestScore
    bestName := "Bullish Harami"

    bestDir := 1

    bestScore := candidate

    bestSpan := 2
candidate := bearHarami and bearReversalContext and nearResistance and isLargeEnough ? score(0.75, trendScoreBear) : 0.0
if candidate > bestScore
    bestName := "Bearish Harami"

    bestDir := -1

    bestScore := candidate

    bestSpan := 2
candidate := piercing and bullReversalContext and nearSupport and isLargeEnough ? score(0.80, trendScoreBull) : 0.0
if candidate > bestScore
    bestName := "Piercing Line"

    bestDir := 1

    bestScore := candidate

    bestSpan := 2
candidate := darkCloud and bearReversalContext and nearResistance and isLargeEnough ? score(0.80, trendScoreBear) : 0.0
if candidate > bestScore
    bestName := "Dark Cloud Cover"

    bestDir := -1

    bestScore := candidate

    bestSpan := 2
candidate := tweezerBottom and bullReversalContext and nearSupport and isLargeEnough ? score(0.75, trendScoreBull) : 0.0
if candidate > bestScore
    bestName := "Tweezer Bottom"

    bestDir := 1

    bestScore := candidate

    bestSpan := 2
candidate := tweezerTop and bearReversalContext and nearResistance and isLargeEnough ? score(0.75, trendScoreBear) : 0.0
if candidate > bestScore
    bestName := "Tweezer Top"

    bestDir := -1

    bestScore := candidate

    bestSpan := 2
candidate := morningStar and nearSupport and isLargeEnough ? score(0.85, trendScoreBull) : 0.0
if candidate > bestScore
    bestName := "Morning Star"

    bestDir := 1

    bestScore := candidate

    bestSpan := 3
candidate := eveningStar and nearResistance and isLargeEnough ? score(0.85, trendScoreBear) : 0.0
if candidate > bestScore
    bestName := "Evening Star"

    bestDir := -1

    bestScore := candidate

    bestSpan := 3
candidate := threeSoldiers and nearSupport and isLargeEnough ? score(0.90, trendScoreBull) : 0.0
if candidate > bestScore
    bestName := "Three White Soldiers"

    bestDir := 1

    bestScore := candidate

    bestSpan := 3
candidate := threeCrows and nearResistance and isLargeEnough ? score(0.90, trendScoreBear) : 0.0
if candidate > bestScore
    bestName := "Three Black Crows"

    bestDir := -1

    bestScore := candidate

    bestSpan := 3

dirAllowed = directionFilter == "Both" or (directionFilter == "Bullish only" and bestDir == 1) or (directionFilter == "Bearish only" and bestDir == -1)
scoreAllowed = not strongOnly or bestScore >= strongMin
var int lastSignalBar = -100000
spacingAllowed = bar_index - lastSignalBar >= minBarsBetween
signal = bestName != "" and dirAllowed and scoreAllowed and spacingAllowed and barstate.isconfirmed
if signal
    lastSignalBar := bar_index

// Drawing
labelSize = labelSizeInput == "Tiny" ? size.tiny : labelSizeInput == "Small" ? size.small : size.normal
signalColor = bestDir == 1 ? bullColor : bestDir == -1 ? bearColor : neutralColor
var array<label> labels = array.new<label>()
var array<box> boxes = array.new<box>()

stars(float value) =>
    filled = int(math.round(value / 2.0))
    filled := math.max(0, math.min(5, filled))
    result = ""
    for i = 0 to 4
        result := result + (i < filled ? "*" : "-")
    result

trim() =>
    while array.size(labels) > maxSignals
        label.delete(array.shift(labels))
    while array.size(boxes) > maxSignals
        box.delete(array.shift(boxes))

if signal
    top = high
    bottom = low
    for i = 0 to bestSpan - 1
        top := math.max(top, high[i])
        bottom := math.min(bottom, low[i])
    pad = atr * 0.08
    top := top + pad
    bottom := bottom - pad
    startBar = bar_index - bestSpan + 1
    if showZones
        bx = box.new(startBar, top, bar_index, bottom, border_color=color.new(signalColor, 35), bgcolor=color.new(signalColor, 82))
        array.push(boxes, bx)
    if showLabels
        above = bestDir == -1
        txt = bestName + "\n" + str.tostring(bestScore, "#.#") + "/10 " + stars(bestScore)
        lb = label.new(bar_index, above ? top : bottom, txt, style=above ? label.style_label_down : label.style_label_up, color=color.new(signalColor, 10), textcolor=color.white, size=labelSize)
        array.push(labels, lb)
    trim()

plotshape(signal and bestDir == 1, title="Bullish Pattern", style=shape.triangleup, location=location.belowbar, color=color.new(bullColor, 0), size=size.tiny)
plotshape(signal and bestDir == -1, title="Bearish Pattern", style=shape.triangledown, location=location.abovebar, color=color.new(bearColor, 0), size=size.tiny)
plot(showLevels ? lastResistance : na, "Resistance", color=color.new(bearColor, 55), style=plot.style_stepline)
plot(showLevels ? lastSupport : na, "Support", color=color.new(bullColor, 55), style=plot.style_stepline)

// Compact scanner table
pos = tablePosInput == "Top center" ? position.top_center : tablePosInput == "Bottom right" ? position.bottom_right : position.top_right
var table scan = table.new(position.top_right, 2, 4, frame_color=color.new(color.gray, 70), frame_width=1, border_width=1)
if showTable and barstate.islast
    table.set_position(scan, pos)
    table.cell(scan, 0, 0, "Candle Harry", text_color=color.white, bgcolor=color.new(#2962ff, 20))
    table.cell(scan, 1, 0, syminfo.ticker, text_color=color.white, bgcolor=color.new(#2962ff, 20))
    table.cell(scan, 0, 1, "Trend", text_color=color.new(color.white, 20), bgcolor=color.new(#1c2030, 0))
    table.cell(scan, 1, 1, priorUp ? "Up" : priorDown ? "Down" : "Flat", text_color=priorUp ? bullColor : priorDown ? bearColor : neutralColor, bgcolor=color.new(#1c2030, 0))
    table.cell(scan, 0, 2, "Latest", text_color=color.new(color.white, 20), bgcolor=color.new(#1c2030, 0))
    table.cell(scan, 1, 2, bestName == "" ? "None" : bestName, text_color=bestName == "" ? neutralColor : signalColor, bgcolor=color.new(#1c2030, 0))
    table.cell(scan, 0, 3, "Score", text_color=color.new(color.white, 20), bgcolor=color.new(#1c2030, 0))
    table.cell(scan, 1, 3, bestName == "" ? "-" : str.tostring(bestScore, "#.#") + "/10", text_color=bestName == "" ? neutralColor : signalColor, bgcolor=color.new(#1c2030, 0))

// Alerts
alertPass = signal and (not alertStrongOnly or bestScore >= strongMin)
if enableAlerts and alertPass
    alert((bestDir == 1 ? "Bullish " : bestDir == -1 ? "Bearish " : "Neutral ") + bestName + " on " + syminfo.tickerid + " " + timeframe.period + " score " + str.tostring(bestScore, "#.#") + "/10", alert.freq_once_per_bar_close)

alertcondition(signal and bestDir == 1, "Bullish Candlestick Pattern", "Bullish candlestick pattern detected")
alertcondition(signal and bestDir == -1, "Bearish Candlestick Pattern", "Bearish candlestick pattern detected")
alertcondition(signal and bestScore >= strongMin, "Strong Candlestick Pattern", "Strong candlestick pattern detected")
````
