# Daily Swing Probability Ladder with Provisional Reversal

- url: https://www.tradingview.com/script/KrP9sXk3-Daily-Swing-Probability-Ladder-with-Provisional-Reversal/
- type: indicator
- pine_id: PUB;977d5baca92a437f9f517041d1ae3b2c
- version: 4.0

## Description

Full TradingView Description:

Daily Swing Probability Ladder with Provisional Reversal is a structure-based swing analysis indicator designed primarily for daily charts. It combines confirmed swing pivot detection, volatility-adjusted support and resistance zones, historical swing statistics and a real-time provisional reversal engine.

The goal of the script is to answer a practical trading question:

Where is price statistically likely to move next based on prior completed swings from similar structural conditions?

Unlike static Fibonacci levels or fixed-percentage targets, this indicator builds a probability ladder from the instrument’s own historical swing behavior. Each displayed level shows a projected price and the empirical hit rate associated with that level.

Example output:

$7.02 | 89.7%
$6.72 | 75.9%
$6.43 | 58.6%
$6.18 | 51.7%

These are not theoretical probabilities. They are empirical hit rates derived from the selected rolling sample of prior completed swings.

Core Components

1. Confirmed Pivot Structure

The script uses confirmed swing highs and swing lows to establish the underlying market structure. Once a pivot is confirmed, the script records the completed swing magnitude and duration.

Confirmed pivot zones are used to create structural support and resistance areas.

2. Probability Ladder

The probability ladder projects forward price levels using the historical distribution of prior same-direction swings.

When the current structural direction is upward, the script references prior low-to-high swings. When the current structural direction is downward, it references prior high-to-low swings.

Each ladder level includes:

Projected price
Historical hit rate
Reached or pending status
Current move percentile
Current active swing state

3. Provisional Reversal Engine

Confirmed pivots are reliable, but they are naturally delayed. To make the indicator more useful in real time, the script includes a provisional reversal mode.

This allows the forecast to flip before a formal pivot confirms when price shows early reversal behavior such as:

Consecutive bullish or bearish candles
Close beyond a recent high or low
Minimum reversal magnitude based on Average True Range (ATR) or percentage movement
Optional Exponential Moving Average (EMA) filter

This helps the indicator respond when a pullback has likely ended and a new swing attempt is developing.

4. Volatility-Adjusted Zones

Support and resistance zones are built from confirmed pivots and scaled using ATR. This allows zones to expand or contract based on the instrument’s volatility profile.

High-volatility names can use wider zones. Broad-market exchange-traded funds (ETFs) can usually use tighter zones.

5. Summary Table

The table displays the current forecast state, regime, sample size, anchor price, active move, current percentile, next level and probability ladder in a dark-mode optimized format.

Table Fields

Forecast: Current directional forecast, such as Swing High, Swing Low, Provisional Swing High or Provisional Swing Low.

Regime: Trend context based on the 50-day and 200-day simple moving averages.

Sample: Number of historical completed swings used for the current probability calculation.

Anchor: The price from which the active swing projection is measured.

Active Move: Current percentage move from the active anchor.

Current Percentile: Where the current move ranks versus prior completed swings.

Hit Rate: Historical percentage of prior swings that reached or exceeded the current move.

Next Level: The next pending probability level.

Provisional: Shows whether the script is using confirmed structure or live provisional reversal logic.

Suggested Use

This indicator is best used as a structural and probabilistic swing analysis tool, not as a standalone buy or sell signal.

Higher-quality setups usually occur when the probability ladder aligns with:

Broader trend regime
Support or resistance zones
Volume confirmation
Relative strength
Moving average structure
Market index direction
Suggested Settings

For broad ETFs such as SPY, QQQ and IWM:

Confirmed Pivot Length: 6 to 8
ATR Length: 50
Zone Width: 0.50 to 0.75 ATR
Reversal Count: 2 candles
Reversal ATR Trigger: 0.50
Reversal Percent Trigger: 1.0% to 2.0%

For high-beta stocks:

Confirmed Pivot Length: 8 to 12
ATR Length: 50
Zone Width: 0.75 to 1.00 ATR
Reversal Count: 2 candles
Reversal ATR Trigger: 0.50 to 0.75
Reversal Percent Trigger: 2.0% to 4.0%
Important Notes

Confirmed pivot zones do not appear until the required confirmation bars have passed. This is intentional and helps preserve structural integrity.

Provisional reversal mode is more responsive, but it is a live condition. It can change as price action develops, especially before the current candle closes.

The probability levels are based on historical swing behavior. They do not guarantee that future price will reach any projected level.

This script is intended for technical analysis, trade planning and market structure assessment. It should be used with disciplined risk management and independent confirmation.

## Source Code

````pine
//@version=6
indicator("Daily Swing Probability Ladder with Continuation Extension", overlay = true, max_boxes_count = 150, max_lines_count = 300, max_labels_count = 300)

//====================================================
// Inputs
//====================================================

groupCore      = "Core Settings"
groupLevels    = "Probability Ladder"
groupExtension = "Continuation Extension"
groupReversal  = "Provisional Reversal"
groupRecovery  = "Recovery Flip"
groupVolume    = "Volume Confirmation"
groupVisual    = "Visual Settings"

pivotLen        = input.int(8, "Confirmed Pivot Length", minval = 2, maxval = 50, group = groupCore)
atrLen          = input.int(50, "ATR Length", minval = 5, maxval = 250, group = groupCore)
zoneAtrMult     = input.float(0.75, "Zone Width, ATR Multiple", minval = 0.05, maxval = 5.0, step = 0.05, group = groupCore)
sampleMax       = input.int(75, "Completed Swing Sample Size", minval = 10, maxval = 250, group = groupCore)
minSample       = input.int(20, "Minimum Sample For Probability", minval = 5, maxval = 100, group = groupCore)
maxActiveZones  = input.int(12, "Maximum Active Zones", minval = 2, maxval = 50, group = groupCore)

prob1 = input.float(90.0, "Level 1 Desired Hit Rate %", minval = 1.0, maxval = 99.0, step = 1.0, group = groupLevels)
prob2 = input.float(75.0, "Level 2 Desired Hit Rate %", minval = 1.0, maxval = 99.0, step = 1.0, group = groupLevels)
prob3 = input.float(60.0, "Level 3 Desired Hit Rate %", minval = 1.0, maxval = 99.0, step = 1.0, group = groupLevels)
prob4 = input.float(50.0, "Level 4 Desired Hit Rate %", minval = 1.0, maxval = 99.0, step = 1.0, group = groupLevels)
prob5 = input.float(40.0, "Level 5 Desired Hit Rate %", minval = 1.0, maxval = 99.0, step = 1.0, group = groupLevels)
prob6 = input.float(25.0, "Level 6 Desired Hit Rate %", minval = 1.0, maxval = 99.0, step = 1.0, group = groupLevels)

enableExtensionMode      = input.bool(true, "Enable Extension Mode After Base Ladder Reached", group = groupExtension)
extensionMode            = input.string("Historical Tail Then ATR Roll", "Extension Method", options = ["Historical Tail Then ATR Roll", "Historical Tail Only", "ATR Roll Only"], group = groupExtension)
extProb1                 = input.float(15.0, "Extension 1 Desired Hit Rate %", minval = 0.5, maxval = 99.0, step = 0.5, group = groupExtension)
extProb2                 = input.float(10.0, "Extension 2 Desired Hit Rate %", minval = 0.5, maxval = 99.0, step = 0.5, group = groupExtension)
extProb3                 = input.float(5.0, "Extension 3 Desired Hit Rate %", minval = 0.5, maxval = 99.0, step = 0.5, group = groupExtension)
extProb4                 = input.float(2.0, "Extension 4 Desired Hit Rate %", minval = 0.5, maxval = 99.0, step = 0.5, group = groupExtension)
extensionAtrStep         = input.float(0.75, "ATR Roll Step", minval = 0.10, maxval = 5.0, step = 0.05, group = groupExtension)
showExtensionOnChart     = input.bool(true, "Show Extension Levels On Chart", group = groupExtension)
showBaseWhenExtended     = input.bool(false, "Show Reached Base Levels During Extension", group = groupExtension)

enableReversalMode = input.bool(true, "Enable Provisional Reversal Mode", group = groupReversal)
reversalBars       = input.int(2, "Consecutive Candle Reversal Count", minval = 1, maxval = 5, group = groupReversal)
useBreakoutFilter  = input.bool(true, "Require Close Beyond Recent High or Low", group = groupReversal)
breakoutLookback   = input.int(2, "Breakout Lookback Bars", minval = 1, maxval = 10, group = groupReversal)
reversalAtrTrigger = input.float(0.50, "Minimum Reversal, ATR Multiple", minval = 0.10, maxval = 5.0, step = 0.05, group = groupReversal)
reversalPctTrigger = input.float(2.0, "Minimum Reversal, Percent", minval = 0.10, maxval = 30.0, step = 0.10, group = groupReversal)
reversalLogic      = input.string("ATR or Percent", "Reversal Trigger Logic", options = ["ATR or Percent", "ATR and Percent"], group = groupReversal)
useEmaFilter       = input.bool(true, "Use EMA Reversal Filter", group = groupReversal)
fastEmaLen         = input.int(8, "Fast EMA Length", minval = 2, maxval = 50, group = groupReversal)
slowEmaLen         = input.int(21, "Slow EMA Length", minval = 5, maxval = 100, group = groupReversal)

enableRecoveryFlip        = input.bool(true, "Enable Recovery Flip", group = groupRecovery)
recoveryScoreThreshold    = input.int(3, "Recovery Score Needed", minval = 1, maxval = 6, group = groupRecovery)
recoveryLookback          = input.int(4, "Recovery Momentum Lookback", minval = 1, maxval = 10, group = groupRecovery)
recoveryBreakoutLookback  = input.int(2, "Recovery Breakout Lookback", minval = 1, maxval = 10, group = groupRecovery)
recoveryAtrTrigger        = input.float(0.50, "Minimum Recovery, ATR Multiple", minval = 0.10, maxval = 5.0, step = 0.05, group = groupRecovery)
recoveryPctTrigger        = input.float(2.0, "Minimum Recovery, Percent", minval = 0.10, maxval = 30.0, step = 0.10, group = groupRecovery)
recoveryLogic             = input.string("ATR or Percent", "Recovery Magnitude Logic", options = ["ATR or Percent", "ATR and Percent"], group = groupRecovery)
requireVolumeForRecovery  = input.bool(false, "Require Volume Confirmation For Recovery Flip", group = groupRecovery)
showRecoveryScoreInTable  = input.bool(true, "Show Recovery Score In Table", group = groupRecovery)

enableVolumeLayer        = input.bool(true, "Enable Volume Confirmation Layer", group = groupVolume)
requireVolumeForReversal = input.bool(false, "Require Volume Confirmation For Reversal", group = groupVolume)
volumeMaLen              = input.int(20, "Volume Average Length", minval = 5, maxval = 100, group = groupVolume)
rvolConfirm              = input.float(1.25, "RVOL Confirmation Threshold", minval = 0.50, maxval = 10.0, step = 0.05, group = groupVolume)
volumeThrustMult         = input.float(1.50, "Volume Thrust Threshold", minval = 0.50, maxval = 10.0, step = 0.05, group = groupVolume)
obvLookback              = input.int(10, "OBV Trend Lookback", minval = 2, maxval = 50, group = groupVolume)
volumeScoreMin           = input.int(2, "Minimum Volume Score", minval = 0, maxval = 4, group = groupVolume)
volumeScoreStrong        = input.int(3, "Strong Volume Score", minval = 1, maxval = 4, group = groupVolume)

showZones          = input.bool(true, "Show Confirmed Zones", group = groupVisual)
showLadder         = input.bool(true, "Show Probability Ladder", group = groupVisual)
showTable          = input.bool(true, "Show Summary Table", group = groupVisual)
showRegime         = input.bool(true, "Show 50D and 200D Simple Moving Averages", group = groupVisual)
showEmaFilter      = input.bool(false, "Show Reversal EMAs", group = groupVisual)
showVolumeInLabels = input.bool(true, "Show Volume Score In Labels", group = groupVisual)
ladderBarsFwd      = input.int(18, "Probability Ladder Forward Bars", minval = 3, maxval = 100, group = groupVisual)
labelOffsetBars    = input.int(2, "Label Offset Bars", minval = 1, maxval = 20, group = groupVisual)

tableHeaderBg = input.color(color.rgb(15, 23, 42), "Table Header Background", group = groupVisual)
tableRowBg1   = input.color(color.rgb(17, 24, 39), "Table Row Background 1", group = groupVisual)
tableRowBg2   = input.color(color.rgb(30, 41, 59), "Table Row Background 2", group = groupVisual)
tableTextCol  = input.color(color.white, "Table Text Color", group = groupVisual)
tableHeadCol  = input.color(color.rgb(125, 211, 252), "Table Header Text Color", group = groupVisual)

//====================================================
// Core calculations
//====================================================

atr     = ta.atr(atrLen)
sma50   = ta.sma(close, 50)
sma200  = ta.sma(close, 200)
emaFast = ta.ema(close, fastEmaLen)
emaSlow = ta.ema(close, slowEmaLen)

volMa = ta.sma(volume, volumeMaLen)
rvol = not na(volMa) and volMa > 0 ? volume / volMa : na
obv = ta.cum(close > close[1] ? volume : close < close[1] ? -volume : 0.0)

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

pivotIndex = bar_index - pivotLen
pivotAtr   = atr[pivotLen]

priorRangeHigh = ta.highest(high, breakoutLookback)[1]
priorRangeLow  = ta.lowest(low, breakoutLookback)[1]

recoveryRangeHigh = ta.highest(high, recoveryBreakoutLookback)[1]
recoveryRangeLow  = ta.lowest(low, recoveryBreakoutLookback)[1]

//====================================================
// Persistent state
//====================================================

var float lastPivotPrice = na
var int   lastPivotIndex = na
var int   lastPivotType  = 0

var float structuralExtremePrice = na
var int   structuralExtremeIndex = na

var int   provisionalMode = 0
var int   provisionalDirection = 0
var bool  provisionalRecovery = false
var float provisionalAnchorPrice = na
var int   provisionalAnchorIndex = na
var float provisionalExtremePrice = na
var int   provisionalExtremeIndex = na

var array<float> upSwingPct   = array.new_float()
var array<float> upSwingDur   = array.new_float()
var array<float> downSwingPct = array.new_float()
var array<float> downSwingDur = array.new_float()

var array<box> zoneBoxes = array.new_box()
var array<int> zoneTypes = array.new_int()

var array<line> ladderLines   = array.new_line()
var array<label> ladderLabels = array.new_label()

//====================================================
// Utility functions
//====================================================

f_addSample(array<float> pctArray, array<float> durArray, float swingPct, float swingDur, int maxSize) =>
    array.push(pctArray, swingPct)
    array.push(durArray, swingDur)
    if array.size(pctArray) > maxSize
        array.shift(pctArray)
        array.shift(durArray)

f_percentile(array<float> src, float percentile) =>
    int n = array.size(src)
    float result = na
    if n > 0
        array<float> temp = array.copy(src)
        array.sort(temp, order.ascending)
        float rank = (percentile / 100.0) * (n - 1)
        int lo = int(math.floor(rank))
        int hi = int(math.ceil(rank))
        float loVal = array.get(temp, lo)
        float hiVal = array.get(temp, hi)
        result := loVal + (hiVal - loVal) * (rank - lo)
    result

f_probabilityAtLeast(array<float> src, float threshold) =>
    int n = array.size(src)
    float result = na
    if n > 0 and not na(threshold)
        int count = 0
        for i = 0 to n - 1
            if array.get(src, i) >= threshold
                count += 1
        result := 100.0 * count / n
    result

f_percentileRank(array<float> src, float value) =>
    int n = array.size(src)
    float result = na
    if n > 0 and not na(value)
        int count = 0
        for i = 0 to n - 1
            if array.get(src, i) <= value
                count += 1
        result := 100.0 * count / n
    result

f_priceFromPct(float anchor, float pct, int direction) =>
    direction == 1 ? anchor * (1.0 + pct / 100.0) : anchor * (1.0 - pct / 100.0)

f_sampleQuality(int n, int minRequired) =>
    string quality = "Low"
    if n >= minRequired and n < 35
        quality := "Moderate"
    if n >= 35
        quality := "Higher"
    quality

f_stateFromPercentile(float rank) =>
    string state = "No Forecast"
    if not na(rank)
        if rank < 25
            state := "Early"
        else if rank < 50
            state := "Normal"
        else if rank < 75
            state := "Extended"
        else if rank < 90
            state := "Stretch"
        else
            state := "Exhaustion"
    state

f_consecutiveBull(int bars) =>
    bool ok = true
    for i = 0 to bars - 1
        ok := ok and close[i] > open[i]
    ok

f_consecutiveBear(int bars) =>
    bool ok = true
    for i = 0 to bars - 1
        ok := ok and close[i] < open[i]
    ok

f_higherCloseCount(int bars) =>
    int count = 0
    for i = 0 to bars - 1
        if not na(close[i + 1]) and close[i] > close[i + 1]
            count += 1
    count

f_lowerCloseCount(int bars) =>
    int count = 0
    for i = 0 to bars - 1
        if not na(close[i + 1]) and close[i] < close[i + 1]
            count += 1
    count

f_higherRangeCount(int bars) =>
    int count = 0
    for i = 0 to bars - 1
        if not na(high[i + 1]) and not na(low[i + 1]) and high[i] > high[i + 1] and low[i] >= low[i + 1]
            count += 1
    count

f_lowerRangeCount(int bars) =>
    int count = 0
    for i = 0 to bars - 1
        if not na(high[i + 1]) and not na(low[i + 1]) and high[i] <= high[i + 1] and low[i] < low[i + 1]
            count += 1
    count

f_volumeScore(int dir) =>
    int score = 0

    bool rvolOk = enableVolumeLayer and not na(rvol) and rvol >= rvolConfirm
    bool thrustOk = enableVolumeLayer and not na(volMa) and volMa > 0 and volume >= volMa * volumeThrustMult
    bool obvOk = false
    bool candleOk = false

    if dir == 1
        obvOk := enableVolumeLayer and not na(obv[obvLookback]) and obv > obv[obvLookback]
        candleOk := enableVolumeLayer and close > open
    else if dir == -1
        obvOk := enableVolumeLayer and not na(obv[obvLookback]) and obv < obv[obvLookback]
        candleOk := enableVolumeLayer and close < open

    score := score + (rvolOk ? 1 : 0)
    score := score + (thrustOk ? 1 : 0)
    score := score + (obvOk ? 1 : 0)
    score := score + (candleOk ? 1 : 0)

    enableVolumeLayer ? score : 0

f_volumeQuality(int score) =>
    string quality = "Off"
    if enableVolumeLayer
        if score >= volumeScoreStrong
            quality := "Strong"
        else if score >= volumeScoreMin
            quality := "Confirming"
        else
            quality := "Weak"
    quality

f_volumeBias(int dir) =>
    string bias = "n/a"
    if enableVolumeLayer
        if dir == 1
            bias := not na(obv[obvLookback]) and obv > obv[obvLookback] ? "OBV Up" : "OBV Weak"
        else if dir == -1
            bias := not na(obv[obvLookback]) and obv < obv[obvLookback] ? "OBV Down" : "OBV Weak"
    bias

f_clearLineArray(array<line> arr) =>
    int i = array.size(arr) - 1
    while i >= 0
        line ln = array.get(arr, i)
        line.delete(ln)
        array.remove(arr, i)
        i -= 1

f_clearLabelArray(array<label> arr) =>
    int i = array.size(arr) - 1
    while i >= 0
        label lb = array.get(arr, i)
        label.delete(lb)
        array.remove(arr, i)
        i -= 1

f_addZone(float price, float atrValue, int zoneType, int xIndex) =>
    if showZones and not na(atrValue)
        float width  = atrValue * zoneAtrMult
        float top    = price + width
        float bottom = price - width

        color zoneColor   = zoneType == -1 ? color.new(color.green, 84) : color.new(color.red, 84)
        color borderColor = zoneType == -1 ? color.new(color.green, 45) : color.new(color.red, 45)

        box bx = box.new(left = xIndex, top = top, right = bar_index + 1, bottom = bottom, bgcolor = zoneColor, border_color = borderColor)
        array.push(zoneBoxes, bx)
        array.push(zoneTypes, zoneType)

        if array.size(zoneBoxes) > maxActiveZones
            box oldBox = array.shift(zoneBoxes)
            array.shift(zoneTypes)
            box.delete(oldBox)

f_reachedCount(array<bool> src) =>
    int n = array.size(src)
    int count = 0
    if n > 0
        for i = 0 to n - 1
            count += array.get(src, i) ? 1 : 0
    count

f_probText(float prob) =>
    string txt = "n/a"
    if not na(prob)
        txt := prob <= 0 ? "<1%" : str.tostring(prob, "#.0") + "%"
    txt

f_pickExtensionMove(float histMove, float rollMove, float currentMove) =>
    float target = na

    if extensionMode == "Historical Tail Only"
        target := histMove
    else if extensionMode == "ATR Roll Only"
        target := rollMove
    else
        if not na(histMove) and not na(currentMove) and histMove > currentMove
            target := histMove
        else
            target := rollMove

    target

//====================================================
// Confirmed pivot processing
//====================================================

bool newHighPivot = not na(ph)
bool newLowPivot  = not na(pl)

bool confirmedPivotEvent = false

if newHighPivot
    float newPrice = ph
    int newType    = 1
    int newIndex   = pivotIndex

    if lastPivotType == 0
        lastPivotPrice := newPrice
        lastPivotIndex := newIndex
        lastPivotType  := newType
        structuralExtremePrice := newPrice
        structuralExtremeIndex := newIndex
        confirmedPivotEvent := true
        f_addZone(newPrice, pivotAtr, newType, newIndex)
    else if lastPivotType == newType
        if newPrice > lastPivotPrice
            lastPivotPrice := newPrice
            lastPivotIndex := newIndex
            structuralExtremePrice := newPrice
            structuralExtremeIndex := newIndex
            confirmedPivotEvent := true
    else
        float swingPct = math.abs(newPrice - lastPivotPrice) / lastPivotPrice * 100.0
        float swingDur = math.max(1.0, newIndex - lastPivotIndex)
        f_addSample(upSwingPct, upSwingDur, swingPct, swingDur, sampleMax)

        lastPivotPrice := newPrice
        lastPivotIndex := newIndex
        lastPivotType  := newType
        structuralExtremePrice := newPrice
        structuralExtremeIndex := newIndex
        confirmedPivotEvent := true
        f_addZone(newPrice, pivotAtr, newType, newIndex)

if newLowPivot
    float newPrice = pl
    int newType    = -1
    int newIndex   = pivotIndex

    if lastPivotType == 0
        lastPivotPrice := newPrice
        lastPivotIndex := newIndex
        lastPivotType  := newType
        structuralExtremePrice := newPrice
        structuralExtremeIndex := newIndex
        confirmedPivotEvent := true
        f_addZone(newPrice, pivotAtr, newType, newIndex)
    else if lastPivotType == newType
        if newPrice < lastPivotPrice
            lastPivotPrice := newPrice
            lastPivotIndex := newIndex
            structuralExtremePrice := newPrice
            structuralExtremeIndex := newIndex
            confirmedPivotEvent := true
    else
        float swingPct = math.abs(newPrice - lastPivotPrice) / lastPivotPrice * 100.0
        float swingDur = math.max(1.0, newIndex - lastPivotIndex)
        f_addSample(downSwingPct, downSwingDur, swingPct, swingDur, sampleMax)

        lastPivotPrice := newPrice
        lastPivotIndex := newIndex
        lastPivotType  := newType
        structuralExtremePrice := newPrice
        structuralExtremeIndex := newIndex
        confirmedPivotEvent := true
        f_addZone(newPrice, pivotAtr, newType, newIndex)

if confirmedPivotEvent
    provisionalMode := 0
    provisionalDirection := 0
    provisionalRecovery := false
    provisionalAnchorPrice := na
    provisionalAnchorIndex := na
    provisionalExtremePrice := na
    provisionalExtremeIndex := na

//====================================================
// Active zone management
//====================================================

int z = array.size(zoneBoxes) - 1

while z >= 0
    box bx        = array.get(zoneBoxes, z)
    int zoneType  = array.get(zoneTypes, z)
    float zoneTop = box.get_top(bx)
    float zoneBot = box.get_bottom(bx)

    box.set_right(bx, bar_index + 1)

    bool brokenSupport    = zoneType == -1 and close < zoneBot
    bool brokenResistance = zoneType == 1 and close > zoneTop

    if brokenSupport or brokenResistance
        box.delete(bx)
        array.remove(zoneBoxes, z)
        array.remove(zoneTypes, z)

    z -= 1

//====================================================
// Structural direction and live extreme
//====================================================

int structuralDirection = lastPivotType == -1 ? 1 : lastPivotType == 1 ? -1 : 0

if structuralDirection == 1
    if na(structuralExtremePrice) or high > structuralExtremePrice
        structuralExtremePrice := high
        structuralExtremeIndex := bar_index

if structuralDirection == -1
    if na(structuralExtremePrice) or low < structuralExtremePrice
        structuralExtremePrice := low
        structuralExtremeIndex := bar_index

//====================================================
// Provisional reversal detection
//====================================================

bool bullBars = f_consecutiveBull(reversalBars)
bool bearBars = f_consecutiveBear(reversalBars)

bool bullBreakout = not useBreakoutFilter or close > priorRangeHigh
bool bearBreakout = not useBreakoutFilter or close < priorRangeLow

bool bullEmaOk = not useEmaFilter or close > emaFast
bool bearEmaOk = not useEmaFilter or close < emaFast

float bullReversalPct = structuralDirection == -1 and not na(structuralExtremePrice) ? (close - structuralExtremePrice) / structuralExtremePrice * 100.0 : na
float bearReversalPct = structuralDirection == 1 and not na(structuralExtremePrice) ? (structuralExtremePrice - close) / structuralExtremePrice * 100.0 : na

float bullReversalAtr = structuralDirection == -1 and not na(structuralExtremePrice) and not na(atr) and atr > 0 ? (close - structuralExtremePrice) / atr : na
float bearReversalAtr = structuralDirection == 1 and not na(structuralExtremePrice) and not na(atr) and atr > 0 ? (structuralExtremePrice - close) / atr : na

bool bullAtrHit = not na(bullReversalAtr) ? bullReversalAtr >= reversalAtrTrigger : false
bool bullPctHit = not na(bullReversalPct) ? bullReversalPct >= reversalPctTrigger : false

bool bearAtrHit = not na(bearReversalAtr) ? bearReversalAtr >= reversalAtrTrigger : false
bool bearPctHit = not na(bearReversalPct) ? bearReversalPct >= reversalPctTrigger : false

bool bullMagnitudeOk = reversalLogic == "ATR or Percent" ? (bullAtrHit or bullPctHit) : (bullAtrHit and bullPctHit)
bool bearMagnitudeOk = reversalLogic == "ATR or Percent" ? (bearAtrHit or bearPctHit) : (bearAtrHit and bearPctHit)

int bullVolumeScore = f_volumeScore(1)
int bearVolumeScore = f_volumeScore(-1)

bool bullVolumeOk = not enableVolumeLayer or not requireVolumeForReversal or bullVolumeScore >= volumeScoreMin
bool bearVolumeOk = not enableVolumeLayer or not requireVolumeForReversal or bearVolumeScore >= volumeScoreMin

bool bullReversalSignal = enableReversalMode and structuralDirection == -1 and provisionalMode == 0 and bullBars and bullBreakout and bullEmaOk and bullMagnitudeOk and bullVolumeOk
bool bearReversalSignal = enableReversalMode and structuralDirection == 1 and provisionalMode == 0 and bearBars and bearBreakout and bearEmaOk and bearMagnitudeOk and bearVolumeOk

if bullReversalSignal
    provisionalMode := 1
    provisionalDirection := 1
    provisionalRecovery := false
    provisionalAnchorPrice := structuralExtremePrice
    provisionalAnchorIndex := structuralExtremeIndex
    provisionalExtremePrice := high
    provisionalExtremeIndex := bar_index

if bearReversalSignal
    provisionalMode := 1
    provisionalDirection := -1
    provisionalRecovery := false
    provisionalAnchorPrice := structuralExtremePrice
    provisionalAnchorIndex := structuralExtremeIndex
    provisionalExtremePrice := low
    provisionalExtremeIndex := bar_index

//====================================================
// Provisional extreme tracking
//====================================================

if provisionalMode == 1 and provisionalDirection == 1
    if na(provisionalExtremePrice) or high > provisionalExtremePrice
        provisionalExtremePrice := high
        provisionalExtremeIndex := bar_index

if provisionalMode == 1 and provisionalDirection == -1
    if na(provisionalExtremePrice) or low < provisionalExtremePrice
        provisionalExtremePrice := low
        provisionalExtremeIndex := bar_index

//====================================================
// Score-based recovery flip
//====================================================

int requiredDirectionalCount = recoveryLookback <= 1 ? 1 : recoveryLookback - 1

float bullRecoveryPct = provisionalMode == 1 and provisionalDirection == -1 and not na(provisionalExtremePrice) ? (close - provisionalExtremePrice) / provisionalExtremePrice * 100.0 : na
float bearRecoveryPct = provisionalMode == 1 and provisionalDirection == 1 and not na(provisionalExtremePrice) ? (provisionalExtremePrice - close) / provisionalExtremePrice * 100.0 : na

float bullRecoveryAtr = provisionalMode == 1 and provisionalDirection == -1 and not na(provisionalExtremePrice) and not na(atr) and atr > 0 ? (close - provisionalExtremePrice) / atr : na
float bearRecoveryAtr = provisionalMode == 1 and provisionalDirection == 1 and not na(provisionalExtremePrice) and not na(atr) and atr > 0 ? (provisionalExtremePrice - close) / atr : na

bool bullRecoveryAtrHit = not na(bullRecoveryAtr) ? bullRecoveryAtr >= recoveryAtrTrigger : false
bool bullRecoveryPctHit = not na(bullRecoveryPct) ? bullRecoveryPct >= recoveryPctTrigger : false

bool bearRecoveryAtrHit = not na(bearRecoveryAtr) ? bearRecoveryAtr >= recoveryAtrTrigger : false
bool bearRecoveryPctHit = not na(bearRecoveryPct) ? bearRecoveryPct >= recoveryPctTrigger : false

bool bullRecoveryMagnitudeOk = recoveryLogic == "ATR or Percent" ? (bullRecoveryAtrHit or bullRecoveryPctHit) : (bullRecoveryAtrHit and bullRecoveryPctHit)
bool bearRecoveryMagnitudeOk = recoveryLogic == "ATR or Percent" ? (bearRecoveryAtrHit or bearRecoveryPctHit) : (bearRecoveryAtrHit and bearRecoveryPctHit)

bool bullRecoveryEmaOk = close > emaFast
bool bearRecoveryEmaOk = close < emaFast

bool bullRecoveryCloseMomentum = f_higherCloseCount(recoveryLookback) >= requiredDirectionalCount
bool bearRecoveryCloseMomentum = f_lowerCloseCount(recoveryLookback) >= requiredDirectionalCount

bool bullRecoveryRangeMomentum = f_higherRangeCount(recoveryLookback) >= requiredDirectionalCount
bool bearRecoveryRangeMomentum = f_lowerRangeCount(recoveryLookback) >= requiredDirectionalCount

bool bullRecoveryBreakout = close > recoveryRangeHigh or high > recoveryRangeHigh
bool bearRecoveryBreakout = close < recoveryRangeLow or low < recoveryRangeLow

bool bullRecoveryVolumeOk = not enableVolumeLayer or not requireVolumeForRecovery or bullVolumeScore >= volumeScoreMin
bool bearRecoveryVolumeOk = not enableVolumeLayer or not requireVolumeForRecovery or bearVolumeScore >= volumeScoreMin

int bullRecoveryScore = 0
bullRecoveryScore += bullRecoveryMagnitudeOk ? 1 : 0
bullRecoveryScore += bullRecoveryEmaOk ? 1 : 0
bullRecoveryScore += bullRecoveryCloseMomentum ? 1 : 0
bullRecoveryScore += bullRecoveryRangeMomentum ? 1 : 0
bullRecoveryScore += bullRecoveryBreakout ? 1 : 0
bullRecoveryScore += bullVolumeScore >= volumeScoreMin ? 1 : 0

int bearRecoveryScore = 0
bearRecoveryScore += bearRecoveryMagnitudeOk ? 1 : 0
bearRecoveryScore += bearRecoveryEmaOk ? 1 : 0
bearRecoveryScore += bearRecoveryCloseMomentum ? 1 : 0
bearRecoveryScore += bearRecoveryRangeMomentum ? 1 : 0
bearRecoveryScore += bearRecoveryBreakout ? 1 : 0
bearRecoveryScore += bearVolumeScore >= volumeScoreMin ? 1 : 0

bool bullRecoveryFlipSignal = enableRecoveryFlip and provisionalMode == 1 and provisionalDirection == -1 and bullRecoveryVolumeOk and bullRecoveryScore >= recoveryScoreThreshold
bool bearRecoveryFlipSignal = enableRecoveryFlip and provisionalMode == 1 and provisionalDirection == 1 and bearRecoveryVolumeOk and bearRecoveryScore >= recoveryScoreThreshold

if bullRecoveryFlipSignal
    provisionalMode := 1
    provisionalDirection := 1
    provisionalRecovery := true
    provisionalAnchorPrice := provisionalExtremePrice
    provisionalAnchorIndex := provisionalExtremeIndex
    provisionalExtremePrice := high
    provisionalExtremeIndex := bar_index

if bearRecoveryFlipSignal
    provisionalMode := 1
    provisionalDirection := -1
    provisionalRecovery := true
    provisionalAnchorPrice := provisionalExtremePrice
    provisionalAnchorIndex := provisionalExtremeIndex
    provisionalExtremePrice := low
    provisionalExtremeIndex := bar_index

//====================================================
// Full anchor invalidation fallback
//====================================================

if provisionalMode == 1 and provisionalDirection == 1 and not na(provisionalAnchorPrice)
    if low < provisionalAnchorPrice and not bullRecoveryFlipSignal
        provisionalMode := 1
        provisionalDirection := -1
        provisionalRecovery := true
        provisionalAnchorPrice := provisionalExtremePrice
        provisionalAnchorIndex := provisionalExtremeIndex
        provisionalExtremePrice := low
        provisionalExtremeIndex := bar_index
        bearRecoveryFlipSignal := true

if provisionalMode == 1 and provisionalDirection == -1 and not na(provisionalAnchorPrice)
    if high > provisionalAnchorPrice and not bearRecoveryFlipSignal
        provisionalMode := 1
        provisionalDirection := 1
        provisionalRecovery := true
        provisionalAnchorPrice := provisionalExtremePrice
        provisionalAnchorIndex := provisionalExtremeIndex
        provisionalExtremePrice := high
        provisionalExtremeIndex := bar_index
        bullRecoveryFlipSignal := true

//====================================================
// Display engine
//====================================================

bool usingProvisional = provisionalMode == 1

int displayDirection = usingProvisional ? provisionalDirection : structuralDirection

float displayAnchorPrice = usingProvisional ? provisionalAnchorPrice : lastPivotPrice
int displayAnchorIndex = usingProvisional ? provisionalAnchorIndex : lastPivotIndex

float displayExtremePrice = usingProvisional ? provisionalExtremePrice : structuralExtremePrice
int displayExtremeIndex = usingProvisional ? provisionalExtremeIndex : structuralExtremeIndex

array<float> activePctArray = displayDirection == 1 ? upSwingPct : downSwingPct
array<float> activeDurArray = displayDirection == 1 ? upSwingDur : downSwingDur

int activeSample = array.size(activePctArray)

float extremeMovePct = na
float liveMovePct = na

if displayDirection == 1 and not na(displayAnchorPrice) and not na(displayExtremePrice)
    extremeMovePct := (displayExtremePrice - displayAnchorPrice) / displayAnchorPrice * 100.0

if displayDirection == -1 and not na(displayAnchorPrice) and not na(displayExtremePrice)
    extremeMovePct := (displayAnchorPrice - displayExtremePrice) / displayAnchorPrice * 100.0

if displayDirection == 1 and not na(displayAnchorPrice)
    liveMovePct := (close - displayAnchorPrice) / displayAnchorPrice * 100.0

if displayDirection == -1 and not na(displayAnchorPrice)
    liveMovePct := (displayAnchorPrice - close) / displayAnchorPrice * 100.0

float currentPercentile = f_percentileRank(activePctArray, extremeMovePct)
float hitRateAtCurrent  = f_probabilityAtLeast(activePctArray, extremeMovePct)
float medianDuration    = f_percentile(activeDurArray, 50.0)

int activeVolumeScore = f_volumeScore(displayDirection)
string activeVolumeQuality = f_volumeQuality(activeVolumeScore)
string activeVolumeBias = f_volumeBias(displayDirection)

string baseState = f_stateFromPercentile(currentPercentile)
string stateText = baseState

if usingProvisional
    if provisionalRecovery
        stateText := displayDirection == 1 ? "Recovery Upswing" : "Recovery Downswing"
    else
        stateText := displayDirection == 1 ? "Provisional Upswing" : "Provisional Downswing"

string sampleQuality = f_sampleQuality(activeSample, minSample)

string regimeText = close > sma50 and close > sma200 ? "Bullish" : close < sma50 and close < sma200 ? "Bearish" : "Mixed"

string directionText = "None"

if displayDirection == 1
    directionText := usingProvisional ? (provisionalRecovery ? "Recovery Swing High" : "Provisional Swing High") : "Swing High"

if displayDirection == -1
    directionText := usingProvisional ? (provisionalRecovery ? "Recovery Swing Low" : "Provisional Swing Low") : "Swing Low"

string modeText = usingProvisional ? (provisionalRecovery ? "Recovery" : "Provisional") : "Structural"

int displayedRecoveryScore = displayDirection == 1 ? bullRecoveryScore : bearRecoveryScore

//====================================================
// Base probability ladder calculations
//====================================================

array<float> desiredProbArray = array.from(prob1, prob2, prob3, prob4, prob5, prob6)

array<float> ladderMoveArray  = array.new_float()
array<float> ladderPriceArray = array.new_float()
array<float> ladderHitArray   = array.new_float()
array<bool>  ladderDoneArray  = array.new_bool()

for i = 0 to array.size(desiredProbArray) - 1
    float desiredHit = array.get(desiredProbArray, i)
    float levelMove  = f_percentile(activePctArray, 100.0 - desiredHit)
    float levelPrice = not na(levelMove) and not na(displayAnchorPrice) ? f_priceFromPct(displayAnchorPrice, levelMove, displayDirection) : na
    float actualHit  = f_probabilityAtLeast(activePctArray, levelMove)
    bool reachedNow  = not na(extremeMovePct) and not na(levelMove) ? extremeMovePct >= levelMove : false

    array.push(ladderMoveArray, levelMove)
    array.push(ladderPriceArray, levelPrice)
    array.push(ladderHitArray, actualHit)
    array.push(ladderDoneArray, reachedNow)

int baseReachedCount = f_reachedCount(ladderDoneArray)
bool baseAllReached = array.size(ladderDoneArray) > 0 and baseReachedCount == array.size(ladderDoneArray) and activeSample >= 3

//====================================================
// Continuation extension ladder calculations
//====================================================

array<float> extensionProbArray = array.from(extProb1, extProb2, extProb3, extProb4)

array<float> extensionMoveArray  = array.new_float()
array<float> extensionPriceArray = array.new_float()
array<float> extensionHitArray   = array.new_float()
array<bool>  extensionDoneArray  = array.new_bool()

float atrStepPct = not na(atr) and not na(displayAnchorPrice) and displayAnchorPrice != 0 ? atr * extensionAtrStep / displayAnchorPrice * 100.0 : na
bool extensionModeActive = enableExtensionMode and baseAllReached and displayDirection != 0 and activeSample >= 3 and not na(extremeMovePct) and not na(displayAnchorPrice)

for i = 0 to array.size(extensionProbArray) - 1
    float desiredHit = array.get(extensionProbArray, i)
    float histMove   = f_percentile(activePctArray, 100.0 - desiredHit)
    float rollMove   = extensionModeActive and not na(atrStepPct) ? extremeMovePct + atrStepPct * (i + 1) : na
    float levelMove  = extensionModeActive ? f_pickExtensionMove(histMove, rollMove, extremeMovePct) : na
    float levelPrice = not na(levelMove) and not na(displayAnchorPrice) ? f_priceFromPct(displayAnchorPrice, levelMove, displayDirection) : na
    float actualHit  = f_probabilityAtLeast(activePctArray, levelMove)
    bool reachedNow  = not na(extremeMovePct) and not na(levelMove) ? extremeMovePct >= levelMove : false

    array.push(extensionMoveArray, levelMove)
    array.push(extensionPriceArray, levelPrice)
    array.push(extensionHitArray, actualHit)
    array.push(extensionDoneArray, reachedNow)

if extensionModeActive
    stateText := displayDirection == 1 ? "Upside Extension" : "Downside Extension"

float nextPrice = na
float nextHit = na
string nextMode = "Base"

for i = 0 to array.size(ladderMoveArray) - 1
    float lvlMove  = array.get(ladderMoveArray, i)
    float lvlPrice = array.get(ladderPriceArray, i)
    float lvlHit   = array.get(ladderHitArray, i)

    if na(nextPrice) and not na(lvlMove) and not na(extremeMovePct) and extremeMovePct < lvlMove
        nextPrice := lvlPrice
        nextHit := lvlHit
        nextMode := "Base"

if na(nextPrice) and extensionModeActive
    for i = 0 to array.size(extensionMoveArray) - 1
        float lvlMove  = array.get(extensionMoveArray, i)
        float lvlPrice = array.get(extensionPriceArray, i)
        float lvlHit   = array.get(extensionHitArray, i)

        if na(nextPrice) and not na(lvlMove) and not na(extremeMovePct) and extremeMovePct < lvlMove
            nextPrice := lvlPrice
            nextHit := lvlHit
            nextMode := "Extension"

//====================================================
// Draw ladder lines and labels
//====================================================

if barstate.islast
    f_clearLineArray(ladderLines)
    f_clearLabelArray(ladderLabels)

bool ladderReady = barstate.islast and showLadder and displayDirection != 0 and activeSample >= 3 and not na(displayAnchorPrice)

if ladderReady
    color dirColor = displayDirection == 1 ? color.new(color.lime, 0) : color.new(color.red, 0)
    color extColor = color.new(color.yellow, 0)
    int lineEndBar = bar_index + ladderBarsFwd
    float pricePad = not na(atr) ? atr * 0.08 : close * 0.002

    bool drawBaseLevels = not extensionModeActive or showBaseWhenExtended

    if drawBaseLevels
        for i = 0 to array.size(ladderPriceArray) - 1
            float lvlPrice = array.get(ladderPriceArray, i)
            float lvlHit   = array.get(ladderHitArray, i)
            bool reached   = array.get(ladderDoneArray, i)

            if not na(lvlPrice) and not na(lvlHit)
                color lineCol = reached ? color.new(dirColor, 80) : color.new(dirColor, 20)
                color labCol  = reached ? color.new(dirColor, 70) : color.new(dirColor, 15)

                line ln = line.new(x1 = bar_index + 1, y1 = lvlPrice, x2 = lineEndBar, y2 = lvlPrice, color = lineCol, width = reached ? 1 : 2)
                array.push(ladderLines, ln)

                string txt = str.tostring(lvlPrice, format.mintick) + " | " + f_probText(lvlHit)
                txt := showVolumeInLabels and enableVolumeLayer ? txt + " | V" + str.tostring(activeVolumeScore) + "/4" : txt

                label lb = label.new(
                     x = lineEndBar + labelOffsetBars,
                     y = lvlPrice + pricePad * (i % 2 == 0 ? 1 : -1),
                     text = txt,
                     style = label.style_label_left,
                     color = labCol,
                     textcolor = color.white,
                     size = size.small
                )

                array.push(ladderLabels, lb)

    if extensionModeActive and showExtensionOnChart
        for i = 0 to array.size(extensionPriceArray) - 1
            float lvlPrice = array.get(extensionPriceArray, i)
            float lvlHit   = array.get(extensionHitArray, i)
            bool reached   = array.get(extensionDoneArray, i)

            if not na(lvlPrice) and not na(lvlHit)
                color lineCol = reached ? color.new(extColor, 80) : color.new(extColor, 10)
                color labCol  = reached ? color.new(extColor, 75) : color.new(extColor, 10)

                line ln = line.new(x1 = bar_index + 1, y1 = lvlPrice, x2 = lineEndBar, y2 = lvlPrice, color = lineCol, width = reached ? 1 : 2)
                array.push(ladderLines, ln)

                string txt = "EXT " + str.tostring(lvlPrice, format.mintick) + " | " + f_probText(lvlHit)
                txt := showVolumeInLabels and enableVolumeLayer ? txt + " | V" + str.tostring(activeVolumeScore) + "/4" : txt

                label lb = label.new(
                     x = lineEndBar + labelOffsetBars,
                     y = lvlPrice + pricePad * (i % 2 == 0 ? 1 : -1),
                     text = txt,
                     style = label.style_label_left,
                     color = labCol,
                     textcolor = color.black,
                     size = size.small
                )

                array.push(ladderLabels, lb)

//====================================================
// Moving averages
//====================================================

plot(showRegime ? sma50 : na, "50D Simple Moving Average", color = color.new(color.blue, 0), linewidth = 1)
plot(showRegime ? sma200 : na, "200D Simple Moving Average", color = color.new(color.orange, 0), linewidth = 1)

plot(showEmaFilter ? emaFast : na, "Fast EMA", color = color.new(color.aqua, 0), linewidth = 1)
plot(showEmaFilter ? emaSlow : na, "Slow EMA", color = color.new(color.purple, 0), linewidth = 1)

//====================================================
// Summary table
//====================================================

var table infoTable = table.new(position.top_right, 4, 19, border_width = 1)

if showTable and barstate.islast
    table.clear(infoTable, 0, 0, 3, 18)

    color volScoreColor = activeVolumeScore >= volumeScoreStrong ? color.lime : activeVolumeScore >= volumeScoreMin ? color.rgb(251, 191, 36) : color.red
    color modeColor = provisionalRecovery ? color.lime : usingProvisional ? color.rgb(251, 191, 36) : tableTextCol
    color extModeColor = extensionModeActive ? color.yellow : tableTextCol

    table.cell(infoTable, 0, 0, "Forecast", text_color = tableHeadCol, bgcolor = tableHeaderBg, text_size = size.normal)
    table.cell(infoTable, 1, 0, directionText, text_color = tableTextCol, bgcolor = tableHeaderBg, text_size = size.normal)
    table.cell(infoTable, 2, 0, "Regime", text_color = tableHeadCol, bgcolor = tableHeaderBg, text_size = size.normal)
    table.cell(infoTable, 3, 0, regimeText, text_color = tableTextCol, bgcolor = tableHeaderBg, text_size = size.normal)

    table.cell(infoTable, 0, 1, "Sample", text_color = tableHeadCol, bgcolor = tableRowBg1)
    table.cell(infoTable, 1, 1, str.tostring(activeSample) + " " + sampleQuality, text_color = tableTextCol, bgcolor = tableRowBg1)
    table.cell(infoTable, 2, 1, "Anchor", text_color = tableHeadCol, bgcolor = tableRowBg1)
    table.cell(infoTable, 3, 1, na(displayAnchorPrice) ? "n/a" : str.tostring(displayAnchorPrice, format.mintick), text_color = tableTextCol, bgcolor = tableRowBg1)

    table.cell(infoTable, 0, 2, "Extreme Move", text_color = tableHeadCol, bgcolor = tableRowBg2)
    table.cell(infoTable, 1, 2, na(extremeMovePct) ? "n/a" : str.tostring(extremeMovePct, "#.0") + "%", text_color = tableTextCol, bgcolor = tableRowBg2)
    table.cell(infoTable, 2, 2, "Live Move", text_color = tableHeadCol, bgcolor = tableRowBg2)
    table.cell(infoTable, 3, 2, na(liveMovePct) ? "n/a" : str.tostring(liveMovePct, "#.0") + "%", text_color = tableTextCol, bgcolor = tableRowBg2)

    table.cell(infoTable, 0, 3, "Current %ile", text_color = tableHeadCol, bgcolor = tableRowBg1)
    table.cell(infoTable, 1, 3, na(currentPercentile) ? "n/a" : str.tostring(currentPercentile, "#.0") + "%", text_color = tableTextCol, bgcolor = tableRowBg1)
    table.cell(infoTable, 2, 3, "State", text_color = tableHeadCol, bgcolor = tableRowBg1)
    table.cell(infoTable, 3, 3, stateText, text_color = extensionModeActive ? color.yellow : modeColor, bgcolor = tableRowBg1)

    table.cell(infoTable, 0, 4, "Next Level", text_color = tableHeadCol, bgcolor = tableRowBg2)
    table.cell(infoTable, 1, 4, na(nextPrice) ? "Stat Max" : str.tostring(nextPrice, format.mintick), text_color = tableTextCol, bgcolor = tableRowBg2)
    table.cell(infoTable, 2, 4, nextMode, text_color = tableHeadCol, bgcolor = tableRowBg2)
    table.cell(infoTable, 3, 4, f_probText(nextHit), text_color = extModeColor, bgcolor = tableRowBg2)

    table.cell(infoTable, 0, 5, "Volume Score", text_color = tableHeadCol, bgcolor = tableRowBg1)
    table.cell(infoTable, 1, 5, enableVolumeLayer ? str.tostring(activeVolumeScore) + "/4 " + activeVolumeQuality : "Off", text_color = volScoreColor, bgcolor = tableRowBg1)
    table.cell(infoTable, 2, 5, "RVOL", text_color = tableHeadCol, bgcolor = tableRowBg1)
    table.cell(infoTable, 3, 5, na(rvol) ? "n/a" : str.tostring(rvol, "#.00") + "x", text_color = tableTextCol, bgcolor = tableRowBg1)

    table.cell(infoTable, 0, 6, "Mode", text_color = tableHeadCol, bgcolor = tableRowBg2)
    table.cell(infoTable, 1, 6, showRecoveryScoreInTable ? modeText + " " + str.tostring(displayedRecoveryScore) + "/6" : modeText, text_color = modeColor, bgcolor = tableRowBg2)
    table.cell(infoTable, 2, 6, "Target Mode", text_color = tableHeadCol, bgcolor = tableRowBg2)
    table.cell(infoTable, 3, 6, extensionModeActive ? "Extension" : "Base", text_color = extModeColor, bgcolor = tableRowBg2)

    table.cell(infoTable, 0, 7, "Base Level", text_color = tableHeadCol, bgcolor = tableHeaderBg)
    table.cell(infoTable, 1, 7, "Price", text_color = tableHeadCol, bgcolor = tableHeaderBg)
    table.cell(infoTable, 2, 7, "Hit %", text_color = tableHeadCol, bgcolor = tableHeaderBg)
    table.cell(infoTable, 3, 7, "Status", text_color = tableHeadCol, bgcolor = tableHeaderBg)

    for i = 0 to array.size(ladderPriceArray) - 1
        int row = i + 8
        color rowBg = i % 2 == 0 ? tableRowBg1 : tableRowBg2

        float desiredHit = array.get(desiredProbArray, i)
        float lvlPrice   = array.get(ladderPriceArray, i)
        float lvlHit     = array.get(ladderHitArray, i)
        bool reached     = array.get(ladderDoneArray, i)

        table.cell(infoTable, 0, row, str.tostring(desiredHit, "#") + "%", text_color = tableTextCol, bgcolor = rowBg)
        table.cell(infoTable, 1, row, na(lvlPrice) ? "n/a" : str.tostring(lvlPrice, format.mintick), text_color = tableTextCol, bgcolor = rowBg)
        table.cell(infoTable, 2, row, f_probText(lvlHit), text_color = tableTextCol, bgcolor = rowBg)
        table.cell(infoTable, 3, row, reached ? "Reached" : "Pending", text_color = reached ? color.lime : color.rgb(251, 191, 36), bgcolor = rowBg)

    table.cell(infoTable, 0, 14, "Extension", text_color = tableHeadCol, bgcolor = tableHeaderBg)
    table.cell(infoTable, 1, 14, "Price", text_color = tableHeadCol, bgcolor = tableHeaderBg)
    table.cell(infoTable, 2, 14, "Hit %", text_color = tableHeadCol, bgcolor = tableHeaderBg)
    table.cell(infoTable, 3, 14, extensionModeActive ? "Active" : "Inactive", text_color = extensionModeActive ? color.yellow : tableTextCol, bgcolor = tableHeaderBg)

    for i = 0 to array.size(extensionPriceArray) - 1
        int row = i + 15
        color rowBg = i % 2 == 0 ? tableRowBg1 : tableRowBg2

        float desiredHit = array.get(extensionProbArray, i)
        float lvlPrice   = array.get(extensionPriceArray, i)
        float lvlHit     = array.get(extensionHitArray, i)
        bool reached     = array.get(extensionDoneArray, i)

        table.cell(infoTable, 0, row, "EXT " + str.tostring(desiredHit, "#.0") + "%", text_color = extensionModeActive ? color.yellow : tableTextCol, bgcolor = rowBg)
        table.cell(infoTable, 1, row, na(lvlPrice) ? "n/a" : str.tostring(lvlPrice, format.mintick), text_color = tableTextCol, bgcolor = rowBg)
        table.cell(infoTable, 2, row, f_probText(lvlHit), text_color = tableTextCol, bgcolor = rowBg)
        table.cell(infoTable, 3, row, reached ? "Reached" : extensionModeActive ? "Pending" : "Off", text_color = reached ? color.lime : extensionModeActive ? color.rgb(251, 191, 36) : tableTextCol, bgcolor = rowBg)

//====================================================
// Alerts
//====================================================

bool extensionModeStart = extensionModeActive and not extensionModeActive[1]

alertcondition(bullReversalSignal, "Bullish Provisional Reversal", "Bullish provisional reversal confirmed by structure and volume settings.")
alertcondition(bearReversalSignal, "Bearish Provisional Reversal", "Bearish provisional reversal confirmed by structure and volume settings.")
alertcondition(bullRecoveryFlipSignal, "Bullish Recovery Flip", "Bearish provisional swing flipped into bullish recovery mode.")
alertcondition(bearRecoveryFlipSignal, "Bearish Recovery Flip", "Bullish provisional swing flipped into bearish recovery mode.")
alertcondition(extensionModeStart, "Continuation Extension Mode Active", "The base probability ladder has been fully reached and continuation extension mode is now active.")
````
