<!-- tradingview-pine-id: PUB;155224689aff44dfb9dc25f3a4790976 -->
<!-- tradingviewscripts-format: 1 -->
# Auto Chart Pattern Mapper Pro v2

Source: https://www.tradingview.com/script/4zmUfwoy-ZipCed40-Chart-Pattern-Mapper-Pro-v3/

## Description

Overview

ZipCed40 - Chart Pattern Mapper Pro v3  is a technical analysis indicator that scans the most recent price history for recognizable chart patterns using confirmed swing pivots. When a qualifying pattern is detected, the script automatically draws the pattern geometry, projects potential breakout levels, and displays a structured trade plan consisting of a suggested entry, target, and stop.

The indicator is intended to assist with chart analysis by organizing market structure into a visual format. It does not predict future price movement with certainty and should be used alongside a trader's own analysis and risk management.

How the Indicator Works

The script analyzes up to 600 historical candles using confirmed pivot highs and pivot lows to identify price structure.

From these pivots, it compares the geometry against predefined pattern rules including:

Flags
Pennants
Triangles
Rectangles
Double Tops
Double Bottoms
Triple Tops
Triple Bottoms
Head and Shoulders
Inverse Head and Shoulders
Cup and Handle
Inverted Cup and Handle
Rising Wedges
Falling Wedges

When one of these structures meets the script's requirements, the indicator highlights the pattern directly on the chart.

Additional Confirmation

In addition to pattern recognition, the script evaluates several technical conditions that may provide additional context:

Higher-timeframe EMA trend alignment
Relative volume compared to a moving average
Basic market structure (higher highs/higher lows or lower highs/lower lows)
Break of market structure
Fair Value Gap (FVG) detection
Simple Order Block detection

These factors contribute to an internal setup score used to help organize qualifying patterns.

Chart Display

When a qualifying pattern is detected, the indicator can display:

Pattern boundaries
Swing geometry
Trendline projections
Pattern highlight zone
Fair Value Gap zones
Order Block zones
Entry level
Target level
Stop level

A dashboard summarizes the current analysis.

Dashboard

The dashboard displays:

Current pattern
Bullish or bearish bias
Overall setup score
Higher-timeframe trend
Relative volume
Market structure
Fair Value Gap status
Entry
Target
Stop
Estimated reward-to-risk ratio
Inputs

The indicator allows users to customize:

Analysis lookback period
Pivot sensitivity
Pattern tolerance
ATR filters
Higher-timeframe confirmation
Volume confirmation
Fair Value Gap confirmation
Order Block confirmation
Market structure confirmation
Entry buffer
Stop buffer
Target projection
Minimum setup score
Display options

These settings allow the indicator to be adjusted for different markets and timeframes.

Suggested Workflow
Apply the indicator to a chart.
Allow the script to identify a completed pattern.
Review the displayed pattern and dashboard.
Compare the suggested trade plan with your own market analysis.
Wait for price to confirm the breakout before considering any trading decision.
Manage risk according to your own trading plan.
Notes
Pattern recognition is based on confirmed historical pivots. As a result, patterns are identified after sufficient price confirmation rather than at the exact turning point.
The setup score is an internal ranking based on the script's rules and should not be interpreted as a probability of success.
Entry, target, and stop levels are calculated using the detected pattern geometry and user-defined ATR settings.
This indicator is designed as a chart analysis tool and does not provide financial or investment advice. Past market behavior does not guarantee future results.

---

## Source Code

````pine
//@version=6
indicator("Auto Chart Pattern Mapper Pro v2", overlay=true, max_bars_back=650,
     max_lines_count=300, max_labels_count=150, max_boxes_count=60)

//=============================================================================
// INPUTS
//=============================================================================
groupPattern = "Pattern Engine"
lookbackBars   = input.int(600, "Candles to analyze", minval=100, maxval=600, group=groupPattern)
pivotStrength  = input.int(6, "Pivot strength", minval=2, maxval=25, group=groupPattern)
priceTolerance = input.float(1.5, "Matching-level tolerance (%)", minval=0.2, maxval=6.0, step=0.1, group=groupPattern) / 100.0
minPatternATR  = input.float(2.0, "Minimum pattern height (ATR)", minval=0.5, maxval=10.0, step=0.25, group=groupPattern)
confirmedOnly  = input.bool(true, "Use confirmed bars only", group=groupPattern)

groupConfluence = "Confluence Filters"
useHTF          = input.bool(true, "Use higher-timeframe trend", group=groupConfluence)
htfTimeframe    = input.timeframe("60", "Higher timeframe", group=groupConfluence)
htfFastLength   = input.int(20, "HTF fast EMA", minval=2, group=groupConfluence)
htfSlowLength   = input.int(50, "HTF slow EMA", minval=3, group=groupConfluence)
useVolume       = input.bool(true, "Use volume confirmation", group=groupConfluence)
volumeLength    = input.int(20, "Average volume length", minval=5, group=groupConfluence)
volumeMultiplier= input.float(1.20, "Volume confirmation multiplier", minval=0.5, maxval=5.0, step=0.05, group=groupConfluence)
useFVG          = input.bool(true, "Use Fair Value Gap confluence", group=groupConfluence)
useOrderBlock   = input.bool(true, "Use order-block confluence", group=groupConfluence)
useStructure    = input.bool(true, "Use market-structure confirmation", group=groupConfluence)

groupRisk = "Trade Plan"
atrLength      = input.int(14, "ATR length", minval=5, maxval=100, group=groupRisk)
entryBufferATR = input.float(0.10, "Entry breakout buffer (ATR)", minval=0.0, maxval=1.0, step=0.05, group=groupRisk)
stopBufferATR  = input.float(0.25, "Stop buffer (ATR)", minval=0.0, maxval=2.0, step=0.05, group=groupRisk)
targetMultiple = input.float(1.0, "Measured-move target multiple", minval=0.25, maxval=3.0, step=0.25, group=groupRisk)
minScore       = input.int(55, "Minimum setup score", minval=0, maxval=100, group=groupRisk)
projectionBars = input.int(40, "Projection bars", minval=5, maxval=200, group=groupRisk)

groupDisplay = "Display"
showPivotPath = input.bool(true, "Show pivot geometry", group=groupDisplay)
showZone      = input.bool(true, "Highlight pattern area", group=groupDisplay)
showTradePlan = input.bool(true, "Show entry, target and stop", group=groupDisplay)
showFVG       = input.bool(true, "Show latest FVG", group=groupDisplay)
showOB        = input.bool(true, "Show latest order block", group=groupDisplay)
showDashboard = input.bool(true, "Show dashboard", group=groupDisplay)

//=============================================================================
// CORE SERIES
//=============================================================================
atrValue = ta.atr(atrLength)
readyToRun = not confirmedOnly or barstate.isconfirmed

avgVolume = ta.sma(volume, volumeLength)
volumeRatio = avgVolume > 0 ? volume / avgVolume : 0.0
volumeConfirmed = volumeRatio >= volumeMultiplier

htfClose = request.security(syminfo.tickerid, htfTimeframe, close, barmerge.gaps_off, barmerge.lookahead_off)
htfFastEMA = request.security(syminfo.tickerid, htfTimeframe, ta.ema(close, htfFastLength), barmerge.gaps_off, barmerge.lookahead_off)
htfSlowEMA = request.security(syminfo.tickerid, htfTimeframe, ta.ema(close, htfSlowLength), barmerge.gaps_off, barmerge.lookahead_off)
htfBull = htfClose > htfFastEMA and htfFastEMA > htfSlowEMA
htfBear = htfClose < htfFastEMA and htfFastEMA < htfSlowEMA

//=============================================================================
// HELPERS
//=============================================================================
f_near(float a, float b, float tolerance) =>
    float baseValue = math.max(math.abs(a), math.abs(b))
    baseValue > 0 and math.abs(a - b) <= baseValue * tolerance

f_slope(int x1, float y1, int x2, float y2) =>
    x2 == x1 ? 0.0 : (y2 - y1) / float(x2 - x1)

f_line_value(int x1, float y1, int x2, float y2, int x) =>
    y1 + f_slope(x1, y1, x2, y2) * float(x - x1)

f_max3(float a, float b, float c) =>
    math.max(a, math.max(b, c))

f_min3(float a, float b, float c) =>
    math.min(a, math.min(b, c))

f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

//=============================================================================
// PIVOT STORAGE
//=============================================================================
var pivotX = array.new_int()
var pivotY = array.new_float()
var pivotType = array.new_int()

pivotHigh = ta.pivothigh(high, pivotStrength, pivotStrength)
pivotLow = ta.pivotlow(low, pivotStrength, pivotStrength)

f_add_pivot(int xValue, float yValue, int pivotKind) =>
    int count = array.size(pivotX)
    if count == 0
        array.push(pivotX, xValue)
        array.push(pivotY, yValue)
        array.push(pivotType, pivotKind)
    else
        int lastKind = array.get(pivotType, count - 1)
        float lastValue = array.get(pivotY, count - 1)
        if pivotKind == lastKind
            bool replacePivot = (pivotKind == 1 and yValue >= lastValue) or (pivotKind == -1 and yValue <= lastValue)
            if replacePivot
                array.set(pivotX, count - 1, xValue)
                array.set(pivotY, count - 1, yValue)
        else
            array.push(pivotX, xValue)
            array.push(pivotY, yValue)
            array.push(pivotType, pivotKind)

    while array.size(pivotX) > 0 and array.get(pivotX, 0) < bar_index - lookbackBars
        array.shift(pivotX)
        array.shift(pivotY)
        array.shift(pivotType)

    while array.size(pivotX) > 50
        array.shift(pivotX)
        array.shift(pivotY)
        array.shift(pivotType)

if readyToRun and not na(pivotHigh)
    f_add_pivot(bar_index - pivotStrength, pivotHigh, 1)

if readyToRun and not na(pivotLow)
    f_add_pivot(bar_index - pivotStrength, pivotLow, -1)

//=============================================================================
// FAIR VALUE GAPS
//=============================================================================
bullFVG = low > high[2]
bearFVG = high < low[2]

var float latestBullFVGTop = na
var float latestBullFVGBottom = na
var int latestBullFVGX = na
var float latestBearFVGTop = na
var float latestBearFVGBottom = na
var int latestBearFVGX = na

if bullFVG
    latestBullFVGTop := low
    latestBullFVGBottom := high[2]
    latestBullFVGX := bar_index - 2

if bearFVG
    latestBearFVGTop := low[2]
    latestBearFVGBottom := high
    latestBearFVGX := bar_index - 2

bullFVGActive = not na(latestBullFVGTop) and close >= latestBullFVGBottom
bearFVGActive = not na(latestBearFVGBottom) and close <= latestBearFVGTop

//=============================================================================
// SIMPLE ORDER BLOCKS
// Last opposite candle before a displacement candle.
//=============================================================================
bullDisplacement = close > open and (close - open) > atrValue * 0.75 and close > high[1]
bearDisplacement = close < open and (open - close) > atrValue * 0.75 and close < low[1]

var float bullOBTop = na
var float bullOBBottom = na
var int bullOBX = na
var float bearOBTop = na
var float bearOBBottom = na
var int bearOBX = na

if bullDisplacement and close[1] < open[1]
    bullOBTop := open[1]
    bullOBBottom := low[1]
    bullOBX := bar_index - 1

if bearDisplacement and close[1] > open[1]
    bearOBTop := high[1]
    bearOBBottom := open[1]
    bearOBX := bar_index - 1

bullOBActive = not na(bullOBTop) and close >= bullOBBottom
bearOBActive = not na(bearOBBottom) and close <= bearOBTop

//=============================================================================
// MARKET STRUCTURE
//=============================================================================
var float lastSwingHigh = na
var float priorSwingHigh = na
var float lastSwingLow = na
var float priorSwingLow = na

if readyToRun and not na(pivotHigh)
    priorSwingHigh := lastSwingHigh
    lastSwingHigh := pivotHigh

if readyToRun and not na(pivotLow)
    priorSwingLow := lastSwingLow
    lastSwingLow := pivotLow

bullStructure = not na(lastSwingHigh) and not na(priorSwingHigh) and not na(lastSwingLow) and not na(priorSwingLow) and lastSwingHigh > priorSwingHigh and lastSwingLow > priorSwingLow
bearStructure = not na(lastSwingHigh) and not na(priorSwingHigh) and not na(lastSwingLow) and not na(priorSwingLow) and lastSwingHigh < priorSwingHigh and lastSwingLow < priorSwingLow

bullBOS = not na(lastSwingHigh) and close > lastSwingHigh
bearBOS = not na(lastSwingLow) and close < lastSwingLow

//=============================================================================
// DRAWING STORAGE
//=============================================================================
var drawingLines = array.new_line()
var drawingLabels = array.new_label()
var drawingBoxes = array.new_box()

f_clear_drawings() =>
    while array.size(drawingLines) > 0
        line.delete(array.pop(drawingLines))
    while array.size(drawingLabels) > 0
        label.delete(array.pop(drawingLabels))
    while array.size(drawingBoxes) > 0
        box.delete(array.pop(drawingBoxes))

f_draw_line(int x1, float y1, int x2, float y2, color lineColor, int lineWidth, lineStyle) =>
    line newLine = line.new(x1, y1, x2, y2, xloc=xloc.bar_index, extend=extend.none, color=lineColor, width=lineWidth, style=lineStyle)
    array.push(drawingLines, newLine)
    newLine

f_draw_label(int xValue, float yValue, string labelText, color backgroundColor, labelStyle) =>
    label newLabel = label.new(xValue, yValue, labelText, xloc=xloc.bar_index, yloc=yloc.price, color=backgroundColor, textcolor=color.white, style=labelStyle, size=size.small)
    array.push(drawingLabels, newLabel)
    newLabel

f_draw_box(int leftX, float topY, int rightX, float bottomY, color borderColor, color fillColor) =>
    box newBox = box.new(leftX, topY, rightX, bottomY, xloc=xloc.bar_index, border_color=borderColor, bgcolor=fillColor)
    array.push(drawingBoxes, newBox)
    newBox

//=============================================================================
// PATTERN STATE
//=============================================================================
var string detectedPattern = "No qualified pattern"
var string detectedBias = "Neutral"
var float basePatternScore = 0.0
var float totalScore = 0.0
var float entryPrice = na
var float targetPrice = na
var float stopPrice = na
var float patternTop = na
var float patternBottom = na
var int patternStartX = na
var int patternEndX = na
var float upperNow = na
var float lowerNow = na
var bool newPatternEvent = false
var string priorSignature = ""

//=============================================================================
// PATTERN CLASSIFICATION
//=============================================================================
if barstate.islast and readyToRun
    f_clear_drawings()

    detectedPattern := "No qualified pattern"
    detectedBias := "Neutral"
    basePatternScore := 0.0
    totalScore := 0.0
    entryPrice := na
    targetPrice := na
    stopPrice := na
    patternTop := na
    patternBottom := na
    patternStartX := na
    patternEndX := na
    upperNow := na
    lowerNow := na
    newPatternEvent := false

    int n = array.size(pivotX)

    if n >= 4
        int x2 = array.get(pivotX, n - 4)
        float y2 = array.get(pivotY, n - 4)
        int t2 = array.get(pivotType, n - 4)

        int x3 = array.get(pivotX, n - 3)
        float y3 = array.get(pivotY, n - 3)
        int t3 = array.get(pivotType, n - 3)

        int x4 = array.get(pivotX, n - 2)
        float y4 = array.get(pivotY, n - 2)
        int t4 = array.get(pivotType, n - 2)

        int x5 = array.get(pivotX, n - 1)
        float y5 = array.get(pivotY, n - 1)
        int t5 = array.get(pivotType, n - 1)

        int x1 = n >= 5 ? array.get(pivotX, n - 5) : x2
        float y1 = n >= 5 ? array.get(pivotY, n - 5) : y2
        int t1 = n >= 5 ? array.get(pivotType, n - 5) : t2

        int x0 = n >= 6 ? array.get(pivotX, n - 6) : x1
        float y0 = n >= 6 ? array.get(pivotY, n - 6) : y1

        bool seqHLHL = t2 == 1 and t3 == -1 and t4 == 1 and t5 == -1
        bool seqLHLH = t2 == -1 and t3 == 1 and t4 == -1 and t5 == 1

        float highA = seqHLHL ? y2 : seqLHLH ? y3 : na
        float highB = seqHLHL ? y4 : seqLHLH ? y5 : na
        int highAX = seqHLHL ? x2 : seqLHLH ? x3 : na
        int highBX = seqHLHL ? x4 : seqLHLH ? x5 : na

        float lowA = seqHLHL ? y3 : seqLHLH ? y2 : na
        float lowB = seqHLHL ? y5 : seqLHLH ? y4 : na
        int lowAX = seqHLHL ? x3 : seqLHLH ? x2 : na
        int lowBX = seqHLHL ? x5 : seqLHLH ? x4 : na

        float upperSlope = not na(highA) ? f_slope(highAX, highA, highBX, highB) : na
        float lowerSlope = not na(lowA) ? f_slope(lowAX, lowA, lowBX, lowB) : na
        float slopeFloor = atrValue * 0.002

        bool highsFlat = not na(highA) and f_near(highA, highB, priceTolerance)
        bool lowsFlat = not na(lowA) and f_near(lowA, lowB, priceTolerance)
        bool highsRising = not na(highA) and highB > highA and upperSlope > slopeFloor
        bool highsFalling = not na(highA) and highB < highA and upperSlope < -slopeFloor
        bool lowsRising = not na(lowA) and lowB > lowA and lowerSlope > slopeFloor
        bool lowsFalling = not na(lowA) and lowB < lowA and lowerSlope < -slopeFloor

        bool fiveHLHLH = n >= 5 and t1 == 1 and t2 == -1 and t3 == 1 and t4 == -1 and t5 == 1
        bool fiveLHLHL = n >= 5 and t1 == -1 and t2 == 1 and t3 == -1 and t4 == 1 and t5 == -1

        float recentTop = f_max3(y3, y4, y5)
        float recentBottom = f_min3(y3, y4, y5)
        float recentHeight = recentTop - recentBottom
        bool enoughHeight = recentHeight >= atrValue * minPatternATR

        bool haveSix = n >= 6
        float impulse = haveSix ? y2 - y0 : 0.0
        bool strongUpImpulse = haveSix and impulse >= atrValue * 4.0
        bool strongDownImpulse = haveSix and impulse <= -atrValue * 4.0

        bool cupHandle = fiveHLHLH and f_near(y1, y3, priceTolerance * 1.5) and y2 < math.min(y1, y3) - atrValue * minPatternATR and y4 > y2 + (math.min(y1, y3) - y2) * 0.35 and y4 < math.min(y1, y3) and y5 >= y3 - atrValue * 0.75
        bool invertedCupHandle = fiveLHLHL and f_near(y1, y3, priceTolerance * 1.5) and y2 > math.max(y1, y3) + atrValue * minPatternATR and y4 < y2 - (y2 - math.max(y1, y3)) * 0.35 and y4 > math.max(y1, y3) and y5 <= y3 + atrValue * 0.75

        bool headShoulders = fiveHLHLH and y3 > y1 + atrValue * 0.50 and y3 > y5 + atrValue * 0.50 and f_near(y1, y5, priceTolerance * 2.0) and f_near(y2, y4, priceTolerance * 2.0)
        bool inverseHeadShoulders = fiveLHLHL and y3 < y1 - atrValue * 0.50 and y3 < y5 - atrValue * 0.50 and f_near(y1, y5, priceTolerance * 2.0) and f_near(y2, y4, priceTolerance * 2.0)

        bool tripleTop = fiveHLHLH and f_near(y1, y3, priceTolerance) and f_near(y3, y5, priceTolerance)
        bool tripleBottom = fiveLHLHL and f_near(y1, y3, priceTolerance) and f_near(y3, y5, priceTolerance)

        bool doubleTop = t3 == 1 and t4 == -1 and t5 == 1 and f_near(y3, y5, priceTolerance) and y4 <= math.min(y3, y5) - atrValue * minPatternATR
        bool doubleBottom = t3 == -1 and t4 == 1 and t5 == -1 and f_near(y3, y5, priceTolerance) and y4 >= math.max(y3, y5) + atrValue * minPatternATR

        bool rectangle = (seqHLHL or seqLHLH) and highsFlat and lowsFlat and enoughHeight
        bool ascendingTriangle = (seqHLHL or seqLHLH) and highsFlat and lowsRising and enoughHeight
        bool descendingTriangle = (seqHLHL or seqLHLH) and highsFalling and lowsFlat and enoughHeight
        bool symmetricalTriangle = (seqHLHL or seqLHLH) and highsFalling and lowsRising and enoughHeight

        bool risingWedge = (seqHLHL or seqLHLH) and highsRising and lowsRising and lowerSlope > upperSlope and enoughHeight
        bool fallingWedge = (seqHLHL or seqLHLH) and highsFalling and lowsFalling and upperSlope < lowerSlope and enoughHeight

        bool bullFlag = strongUpImpulse and (seqHLHL or seqLHLH) and highsFalling and lowsFalling and math.abs(upperSlope - lowerSlope) <= atrValue * 0.03
        bool bearFlag = strongDownImpulse and (seqHLHL or seqLHLH) and highsRising and lowsRising and math.abs(upperSlope - lowerSlope) <= atrValue * 0.03
        bool bullPennant = strongUpImpulse and symmetricalTriangle
        bool bearPennant = strongDownImpulse and symmetricalTriangle

        patternStartX := x2
        patternEndX := x5
        patternTop := recentTop
        patternBottom := recentBottom

        if cupHandle
            detectedPattern := "Cup and Handle"
            detectedBias := "Bullish"
            basePatternScore := 72
            patternTop := math.max(y1, y3)
            patternBottom := y2
        else if invertedCupHandle
            detectedPattern := "Inverted Cup and Handle"
            detectedBias := "Bearish"
            basePatternScore := 72
            patternTop := y2
            patternBottom := math.min(y1, y3)
        else if headShoulders
            detectedPattern := "Head and Shoulders"
            detectedBias := "Bearish"
            basePatternScore := 70
            patternTop := y3
            patternBottom := math.min(y2, y4)
        else if inverseHeadShoulders
            detectedPattern := "Inverse Head and Shoulders"
            detectedBias := "Bullish"
            basePatternScore := 70
            patternTop := math.max(y2, y4)
            patternBottom := y3
        else if tripleTop
            detectedPattern := "Triple Top"
            detectedBias := "Bearish"
            basePatternScore := 68
            patternTop := f_max3(y1, y3, y5)
            patternBottom := math.min(y2, y4)
        else if tripleBottom
            detectedPattern := "Triple Bottom"
            detectedBias := "Bullish"
            basePatternScore := 68
            patternTop := math.max(y2, y4)
            patternBottom := f_min3(y1, y3, y5)
        else if doubleTop
            detectedPattern := "Double Top"
            detectedBias := "Bearish"
            basePatternScore := 64
            patternTop := math.max(y3, y5)
            patternBottom := y4
        else if doubleBottom
            detectedPattern := "Double Bottom"
            detectedBias := "Bullish"
            basePatternScore := 64
            patternTop := y4
            patternBottom := math.min(y3, y5)
        else if bullPennant
            detectedPattern := "Bullish Pennant"
            detectedBias := "Bullish"
            basePatternScore := 62
        else if bearPennant
            detectedPattern := "Bearish Pennant"
            detectedBias := "Bearish"
            basePatternScore := 62
        else if bullFlag
            detectedPattern := "Bullish Flag"
            detectedBias := "Bullish"
            basePatternScore := 60
        else if bearFlag
            detectedPattern := "Bearish Flag"
            detectedBias := "Bearish"
            basePatternScore := 60
        else if risingWedge
            detectedPattern := "Rising Wedge"
            detectedBias := "Bearish"
            basePatternScore := 58
        else if fallingWedge
            detectedPattern := "Falling Wedge"
            detectedBias := "Bullish"
            basePatternScore := 58
        else if ascendingTriangle
            detectedPattern := "Ascending Triangle"
            detectedBias := "Bullish"
            basePatternScore := 56
        else if descendingTriangle
            detectedPattern := "Descending Triangle"
            detectedBias := "Bearish"
            basePatternScore := 56
        else if symmetricalTriangle
            detectedPattern := "Symmetrical Triangle"
            detectedBias := close >= (highB + lowB) * 0.5 ? "Bullish" : "Bearish"
            basePatternScore := 52
        else if rectangle
            detectedPattern := "Rectangle"
            detectedBias := close >= (highB + lowB) * 0.5 ? "Bullish" : "Bearish"
            basePatternScore := 50

        bool hasPattern = detectedPattern != "No qualified pattern"

        if hasPattern
            upperNow := not na(highA) ? f_line_value(highAX, highA, highBX, highB, bar_index) : patternTop
            lowerNow := not na(lowA) ? f_line_value(lowAX, lowA, lowBX, lowB, bar_index) : patternBottom

            bool bullishSetup = detectedBias == "Bullish"
            bool htfAligned = bullishSetup ? htfBull : htfBear
            bool structureAligned = bullishSetup ? (bullStructure or bullBOS) : (bearStructure or bearBOS)
            bool fvgAligned = bullishSetup ? bullFVGActive : bearFVGActive
            bool obAligned = bullishSetup ? bullOBActive : bearOBActive

            float scoreValue = basePatternScore
            scoreValue += useHTF ? (htfAligned ? 10 : -8) : 0
            scoreValue += useVolume ? (volumeConfirmed ? 8 : -4) : 0
            scoreValue += useStructure ? (structureAligned ? 8 : -5) : 0
            scoreValue += useFVG ? (fvgAligned ? 5 : 0) : 0
            scoreValue += useOrderBlock ? (obAligned ? 5 : 0) : 0

            totalScore := f_clamp(scoreValue, 0, 100)

            float measuredHeight = math.max(patternTop - patternBottom, atrValue)
            float entryBuffer = atrValue * entryBufferATR
            float stopBuffer = atrValue * stopBufferATR

            if bullishSetup
                entryPrice := upperNow + entryBuffer
                targetPrice := entryPrice + measuredHeight * targetMultiple
                stopPrice := lowerNow - stopBuffer
                if stopPrice >= entryPrice
                    stopPrice := entryPrice - atrValue
            else
                entryPrice := lowerNow - entryBuffer
                targetPrice := entryPrice - measuredHeight * targetMultiple
                stopPrice := upperNow + stopBuffer
                if stopPrice <= entryPrice
                    stopPrice := entryPrice + atrValue

            color biasColor = bullishSetup ? color.lime : color.red
            bool qualified = totalScore >= minScore
            color qualifiedColor = qualified ? biasColor : color.orange

            if showZone
                f_draw_box(patternStartX, patternTop, bar_index, patternBottom, color.new(qualifiedColor, 35), color.new(qualifiedColor, 90))

            if showPivotPath
                int firstDraw = math.max(0, n - 6)
                int lastDraw = n - 1
                if lastDraw > firstDraw
                    for i = firstDraw to lastDraw - 1
                        int xa = array.get(pivotX, i)
                        float ya = array.get(pivotY, i)
                        int xb = array.get(pivotX, i + 1)
                        float yb = array.get(pivotY, i + 1)
                        f_draw_line(xa, ya, xb, yb, qualifiedColor, 2, line.style_solid)

            if not na(highA)
                float upperFuture = f_line_value(highAX, highA, highBX, highB, bar_index + projectionBars)
                f_draw_line(highAX, highA, bar_index + projectionBars, upperFuture, qualifiedColor, 2, line.style_dashed)

            if not na(lowA)
                float lowerFuture = f_line_value(lowAX, lowA, lowBX, lowB, bar_index + projectionBars)
                f_draw_line(lowAX, lowA, bar_index + projectionBars, lowerFuture, qualifiedColor, 2, line.style_dashed)

            string statusText = qualified ? "QUALIFIED" : "LOW SCORE"
            f_draw_label(bar_index, bullishSetup ? patternBottom : patternTop, detectedPattern + "\n" + detectedBias + " • " + str.tostring(totalScore, "#") + "/100\n" + statusText, color.new(qualifiedColor, 10), bullishSetup ? label.style_label_up : label.style_label_down)

            if showTradePlan
                int futureX = bar_index + projectionBars
                f_draw_line(bar_index, entryPrice, futureX, entryPrice, color.yellow, 2, line.style_solid)
                f_draw_line(bar_index, targetPrice, futureX, targetPrice, color.lime, 2, line.style_solid)
                f_draw_line(bar_index, stopPrice, futureX, stopPrice, color.red, 2, line.style_solid)

                f_draw_label(futureX, entryPrice, "ENTRY\n" + str.tostring(entryPrice, format.mintick), color.new(color.yellow, 15), label.style_label_left)
                f_draw_label(futureX, targetPrice, "TARGET\n" + str.tostring(targetPrice, format.mintick), color.new(color.lime, 15), label.style_label_left)
                f_draw_label(futureX, stopPrice, "STOP\n" + str.tostring(stopPrice, format.mintick), color.new(color.red, 15), label.style_label_left)

            if showFVG
                if bullishSetup and bullFVGActive and not na(latestBullFVGX)
                    f_draw_box(latestBullFVGX, latestBullFVGTop, bar_index + projectionBars, latestBullFVGBottom, color.new(color.aqua, 35), color.new(color.aqua, 88))
                if not bullishSetup and bearFVGActive and not na(latestBearFVGX)
                    f_draw_box(latestBearFVGX, latestBearFVGTop, bar_index + projectionBars, latestBearFVGBottom, color.new(color.fuchsia, 35), color.new(color.fuchsia, 88))

            if showOB
                if bullishSetup and bullOBActive and not na(bullOBX)
                    f_draw_box(bullOBX, bullOBTop, bar_index + projectionBars, bullOBBottom, color.new(color.green, 45), color.new(color.green, 90))
                if not bullishSetup and bearOBActive and not na(bearOBX)
                    f_draw_box(bearOBX, bearOBTop, bar_index + projectionBars, bearOBBottom, color.new(color.red, 45), color.new(color.red, 90))

            string currentSignature = detectedPattern + "|" + detectedBias + "|" + str.tostring(patternStartX) + "|" + str.tostring(patternEndX)
            newPatternEvent := qualified and currentSignature != priorSignature
            if newPatternEvent
                priorSignature := currentSignature

//=============================================================================
// DASHBOARD
//=============================================================================
var table dashboard = table.new(position.top_right, 2, 12, bgcolor=color.new(color.black, 15), border_color=color.new(color.gray, 55), border_width=1)

if barstate.islast
    if showDashboard
        color biasCell = detectedBias == "Bullish" ? color.new(color.green, 55) : detectedBias == "Bearish" ? color.new(color.red, 55) : color.new(color.gray, 65)
        bool dashboardQualified = totalScore >= minScore and detectedPattern != "No qualified pattern"

        table.cell(dashboard, 0, 0, "PATTERN PRO V2", text_color=color.white, bgcolor=color.new(color.blue, 55))
        table.cell(dashboard, 1, 0, syminfo.ticker + " • " + timeframe.period, text_color=color.white, bgcolor=color.new(color.blue, 55))

        table.cell(dashboard, 0, 1, "Pattern", text_color=color.silver)
        table.cell(dashboard, 1, 1, detectedPattern, text_color=color.white)

        table.cell(dashboard, 0, 2, "Bias", text_color=color.silver)
        table.cell(dashboard, 1, 2, detectedBias, text_color=color.white, bgcolor=biasCell)

        table.cell(dashboard, 0, 3, "Score", text_color=color.silver)
        table.cell(dashboard, 1, 3, str.tostring(totalScore, "#") + "/100", text_color=dashboardQualified ? color.lime : color.orange)

        table.cell(dashboard, 0, 4, "HTF trend", text_color=color.silver)
        table.cell(dashboard, 1, 4, htfBull ? "Bullish" : htfBear ? "Bearish" : "Mixed", text_color=htfBull ? color.lime : htfBear ? color.red : color.orange)

        table.cell(dashboard, 0, 5, "Volume", text_color=color.silver)
        table.cell(dashboard, 1, 5, str.tostring(volumeRatio, "#.##") + "x", text_color=volumeConfirmed ? color.lime : color.orange)

        table.cell(dashboard, 0, 6, "Structure", text_color=color.silver)
        table.cell(dashboard, 1, 6, bullStructure or bullBOS ? "Bullish" : bearStructure or bearBOS ? "Bearish" : "Neutral", text_color=bullStructure or bullBOS ? color.lime : bearStructure or bearBOS ? color.red : color.orange)

        table.cell(dashboard, 0, 7, "FVG", text_color=color.silver)
        table.cell(dashboard, 1, 7, bullFVGActive ? "Bullish active" : bearFVGActive ? "Bearish active" : "None", text_color=bullFVGActive ? color.aqua : bearFVGActive ? color.fuchsia : color.gray)

        table.cell(dashboard, 0, 8, "Entry", text_color=color.silver)
        table.cell(dashboard, 1, 8, na(entryPrice) ? "—" : str.tostring(entryPrice, format.mintick), text_color=color.yellow)

        table.cell(dashboard, 0, 9, "Target", text_color=color.silver)
        table.cell(dashboard, 1, 9, na(targetPrice) ? "—" : str.tostring(targetPrice, format.mintick), text_color=color.lime)

        table.cell(dashboard, 0, 10, "Stop", text_color=color.silver)
        table.cell(dashboard, 1, 10, na(stopPrice) ? "—" : str.tostring(stopPrice, format.mintick), text_color=color.red)

        float reward = not na(entryPrice) and not na(targetPrice) ? math.abs(targetPrice - entryPrice) : na
        float risk = not na(entryPrice) and not na(stopPrice) ? math.abs(entryPrice - stopPrice) : na
        float rr = not na(reward) and not na(risk) and risk > 0 ? reward / risk : na

        table.cell(dashboard, 0, 11, "Reward/Risk", text_color=color.silver)
        table.cell(dashboard, 1, 11, na(rr) ? "—" : str.tostring(rr, "#.##") + "R", text_color=color.white)
    else
        table.clear(dashboard, 0, 0, 1, 11)

//=============================================================================
// ALERTS
//=============================================================================
if newPatternEvent
    string alertMessage = '{"symbol":"' + syminfo.ticker + '","timeframe":"' + timeframe.period + '","pattern":"' + detectedPattern + '","bias":"' + detectedBias + '","score":' + str.tostring(totalScore, "#") + ',"entry":' + str.tostring(entryPrice, format.mintick) + ',"target":' + str.tostring(targetPrice, format.mintick) + ',"stop":' + str.tostring(stopPrice, format.mintick) + ',"volumeRatio":' + str.tostring(volumeRatio, "#.##") + ',"htfTrend":"' + (htfBull ? "Bullish" : htfBear ? "Bearish" : "Mixed") + '"}'
    alert(alertMessage, alert.freq_once_per_bar_close)

// Data Window outputs.
plot(entryPrice, "Pattern Entry", display=display.data_window)
plot(targetPrice, "Pattern Target", display=display.data_window)
plot(stopPrice, "Pattern Stop", display=display.data_window)
plot(totalScore, "Setup Score", display=display.data_window)
````
