# Structure & Stoch Oscillator

- url: https://www.tradingview.com/script/6CHATUxF-Structure-Stoch-Oscillator/
- type: indicator
- pine_id: PUB;2c59f1274522413296c8152dfa41b81b
- version: 4.0

## Description

## Structure & Stoch Oscillator

The Structure & Stoch Oscillator is designed to combine market structure signals with stochastic oscillator momentum conditions to help traders identify cleaner continuation, reversal, and exhaustion areas directly on the chart.

This indicator uses structure logic such as BOS, MSS, and CHoCH together with stochastic oscillator readings to provide better context around price movement. The goal is to help traders see when structure and momentum are starting to align, instead of relying on structure breaks or oscillator signals alone.

## Main Features

* Detects bullish and bearish market structure events
* Displays BOS, MSS, and CHoCH conditions on the chart
* Uses stochastic oscillator logic for momentum confirmation
* Helps identify possible continuation setups
* Helps identify possible reversal or exhaustion conditions
* Highlights bullish and bearish structure/momentum alignment
* Provides cleaner visual confirmation without excessive chart clutter
* Includes adjustable settings for different markets and timeframes

## Structure Logic

The structure portion of the indicator helps identify important shifts in price action.

**BOS – Break of Structure**
A structure break that may suggest continuation in the current direction.

**MSS – Market Structure Shift**
A possible early sign that price is shifting direction after a previous move.

**CHoCH – Change of Character**
A warning that price behavior may be changing and momentum may be weakening or reversing.

These structure signals can help traders better understand whether price is continuing, shifting, or preparing for a possible reversal.

## Stochastic Oscillator Logic

The stochastic oscillator portion adds momentum context to the structure signals.

It can help show when price may be:

* Overbought or oversold
* Losing momentum
* Starting a reversal
* Pulling back during continuation
* Reacting near midpoint areas
* Moving into extreme conditions

This helps traders avoid taking every structure break blindly and gives an additional layer of confirmation.

## How to Use

Use this indicator as a confirmation and filtering tool.

A simple workflow:

1. Watch for BOS, MSS, or CHoCH structure behavior.
2. Check whether the stochastic oscillator supports the move.
3. Look for alignment between structure direction and oscillator momentum.
4. Use additional context such as session highs/lows, VWAP, liquidity sweeps, trend direction, or your preferred entry model.
5. Avoid taking every signal automatically.
6. Manage entries, stops, targets, and risk using your own trading plan.

This indicator is not designed to be a standalone buy or sell system. It is best used as a decision-support tool for traders who already use structure and momentum analysis.

## Best For

* Intraday futures trading
* Market structure analysis
* BOS continuation setups
* MSS reversal confirmation
* CHoCH shift awareness
* Stochastic momentum filtering
* Reversal and exhaustion awareness
* Continuation trade confirmation
* Cleaner chart-based decision making

This tool can be used across futures, indices, forex, crypto, and other markets. Traders should test and adjust settings based on their preferred symbol, timeframe, and trading style.

## Notes

The Structure & Stoch Oscillator is designed to support analysis, not replace it. Market structure and oscillator momentum can provide helpful context, but no indicator can guarantee future price movement.

Always use proper risk management and combine this tool with your own tested trading plan.

## Source Code

````pine
//@version=6 
indicator("Structure & Stoch Oscillator [LuxAlgo]", overlay = false, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

// --- Groups & Tooltips ---
var G_STRUC = "Market Structure & Pullback"
var G_STOCH = "Stoch RSI Settings"
var G_MID   = "Midpoint Continuation Logic"
var G_FILT  = "Trend & Filters"
var G_OSC   = "Oscillator Visuals"

// --- Inputs ---
// Structure
int pivotLen        = input.int(5, "Pivot Length", group = G_STRUC)
int pullbackWindow  = input.int(10, "Pullback Window (Bars)", group = G_STRUC)
int cooldown        = input.int(5, "Signal Cooldown", group = G_STRUC)

// Stoch RSI
bool useStoch       = input.bool(true, "Require Stoch Confirmation", group = G_STOCH)
int rsiLen          = input.int(14, "RSI Length", group = G_STOCH)
int stochLen        = input.int(14, "Stoch Length", group = G_STOCH)
int kSmooth         = input.int(3, "K Smooth", group = G_STOCH)
int dSmooth         = input.int(3, "D Smooth", group = G_STOCH)
int midLine         = input.int(50, "Midline Value", group = G_STOCH)

bool reqStochSlope  = input.bool(true, "Require Oscillator Slope Agreement", group = G_STOCH)
int slopeLookback   = input.int(2, "Oscillator Slope Lookback", group = G_STOCH)

bool avoidExtreme   = input.bool(true, "Avoid Extreme Stoch Entries", group = G_STOCH)
float maxBuyStoch   = input.float(90, "No Buy Above Stoch", group = G_STOCH)
float minSellStoch  = input.float(10, "No Sell Below Stoch", group = G_STOCH)

float obLevel       = input.float(80, "Overbought Level", group = G_STOCH)
float osLevel       = input.float(20, "Oversold Level", group = G_STOCH)

// Deep floor / ceiling logic
float deepBullFloor = input.float(2.0, "Deep Bull Floor Touch Level", group = G_STOCH)
float deepBearCeiling = input.float(98.0, "Deep Bear Ceiling Touch Level", group = G_STOCH)
int deepExtremeLookback = input.int(5, "Deep Floor/Ceiling Touch Lookback", group = G_STOCH)
bool requireFloorCross = input.bool(true, "Floor Bull Requires K/D Crossover", group = G_STOCH)
bool requireCeilingCross = input.bool(true, "Ceiling Bear Requires K/D Crossover", group = G_STOCH)

// Caution reset logic
bool showResetSignals = input.bool(true, "Show Caution Reset Signals", group = G_STOCH)
float resetBullLow    = input.float(20.0, "Reset Bull Zone Low", group = G_STOCH)
float resetBullHigh   = input.float(25.0, "Reset Bull Zone High", group = G_STOCH)
float resetBearLow    = input.float(75.0, "Reset Bear Zone Low", group = G_STOCH)
float resetBearHigh   = input.float(80.0, "Reset Bear Zone High", group = G_STOCH)
int resetLookback     = input.int(5, "Reset Zone Touch Lookback", group = G_STOCH)
color resetTextColor  = input.color(color.orange, "Reset Caution Text Color", group = G_STOCH)

bool capExtremeGrades = input.bool(true, "Cap Grades Near Opposite Extreme", group = G_STOCH)
float bullGradeCapAbove = input.float(70, "Cap Bull Grade Above Stoch", group = G_STOCH)
float bearGradeCapBelow = input.float(30, "Cap Bear Grade Below Stoch", group = G_STOCH)

// Midpoint Continuation
bool useMidCont     = input.bool(true, "Use Midpoint Continuation Logic", group = G_MID)
float midContLevel  = input.float(50.0, "Midpoint Level", group = G_MID)
float midContTol    = input.float(5.0, "Midpoint Tolerance", group = G_MID)
bool reqKAboveD     = input.bool(true, "Require K Above D For Bullish Continuation", group = G_MID)
bool reqKBelowD     = input.bool(true, "Require K Below D For Bearish Continuation", group = G_MID)
bool reqContSlope   = input.bool(true, "Require Oscillator Slope Agreement", group = G_MID)
int midLookback     = input.int(5, "Midpoint Lookback Bars", group = G_MID)
bool reqMidCont     = input.bool(false, "Require Midpoint Continuation For Continuation Signals", group = G_MID)

bool requireCurrentMidZone = input.bool(true, "Require Current Stoch Near 50 For 50 Labels", group = G_MID)
float midScoreMaxStochBull = input.float(60.0, "Max Bull Stoch For 50 Bull", group = G_MID)
float midScoreMinStochBear = input.float(40.0, "Min Bear Stoch For 50 Bear", group = G_MID)

// Trend Filter
bool useEma         = input.bool(true, "Use EMA Trend Filter", group = G_FILT)
int emaLen          = input.int(50, "EMA Length", group = G_FILT)
bool reqEmaSlope    = input.bool(true, "Require EMA Slope Agreement", group = G_FILT)

// Visuals
color kColor        = input.color(#2962FF, "K Line Color", group = G_OSC)
color dColor        = input.color(#FF6D00, "D Line Color", group = G_OSC)
bool showMomBg      = input.bool(false, "Show Red/Green Background", group = G_OSC)

// --- Calculations ---
// Pivots
float ph = ta.pivothigh(high, pivotLen, pivotLen)
float pl = ta.pivotlow(low, pivotLen, pivotLen)

var float lastPh = na
var float lastPl = na

if not na(ph)
    lastPh := ph
if not na(pl)
    lastPl := pl

// Structure Flip
var bool bullFlip = false
var bool bearFlip = false
var float protectedLow = na
var float protectedHigh = na
var int flipBar = na

bool closeAbovePh = close > lastPh and not na(lastPh)
bool closeBelowPl = close < lastPl and not na(lastPl)

if closeAbovePh and (na(flipBar) or bar_index - flipBar > cooldown)
    bullFlip := true
    bearFlip := false
    protectedLow := lastPl
    flipBar := bar_index
else if closeBelowPl and (na(flipBar) or bar_index - flipBar > cooldown)
    bearFlip := true
    bullFlip := false
    protectedHigh := lastPh
    flipBar := bar_index

// Stoch RSI
float rsiVal = ta.rsi(close, rsiLen)
float stochK = ta.sma(ta.stoch(rsiVal, rsiVal, rsiVal, stochLen), kSmooth)
float stochD = ta.sma(stochK, dSmooth)

bool kRising = stochK > stochK[slopeLookback]
bool kFalling = stochK < stochK[slopeLookback]

bool stochBullAgrees = (stochK > stochD) and (stochK > midLine) and (not reqStochSlope or kRising) and (not avoidExtreme or stochK <= maxBuyStoch)
bool stochBearAgrees = (stochK < stochD) and (stochK < midLine) and (not reqStochSlope or kFalling) and (not avoidExtreme or stochK >= minSellStoch)

// EMA
float emaVal = ta.ema(close, emaLen)
bool emaRising = emaVal > emaVal[1]
bool emaFalling = emaVal < emaVal[1]

bool emaBullAgrees = not useEma or ((close > emaVal) and (not reqEmaSlope or emaRising))
bool emaBearAgrees = not useEma or ((close < emaVal) and (not reqEmaSlope or emaFalling))

// Signals & Confluence
var int lastSigBar = 0

bool validPullbackBull = not na(flipBar) and bar_index - flipBar <= pullbackWindow and (na(protectedLow) or low >= protectedLow)
bool validPullbackBear = not na(flipBar) and bar_index - flipBar <= pullbackWindow and (na(protectedHigh) or high <= protectedHigh)

bool structureBull = bullFlip and validPullbackBull
bool structureBear = bearFlip and validPullbackBear

// Overbought/Oversold Reversals
bool stochKCrossOverD = ta.crossover(stochK, stochD)
bool stochKCrossUnderD = ta.crossunder(stochK, stochD)

float lowestStochRecent = ta.lowest(stochK, 5)
float highestStochRecent = ta.highest(stochK, 5)

float lowestDeepFloorRecent = ta.lowest(stochK, deepExtremeLookback)
float highestDeepCeilingRecent = ta.highest(stochK, deepExtremeLookback)

bool touchedResetBullZone = false
bool touchedResetBearZone = false
for i = 0 to resetLookback - 1
    if stochK[i] >= resetBullLow and stochK[i] <= resetBullHigh
        touchedResetBullZone := true
    if stochK[i] >= resetBearLow and stochK[i] <= resetBearHigh
        touchedResetBearZone := true

bool touchedDeepBullFloor = lowestDeepFloorRecent <= deepBullFloor
bool touchedDeepBearCeiling = highestDeepCeilingRecent >= deepBearCeiling

// Floor Bull requires the actual K/D bullish crossover.
bool bullDeepFloorReversal = touchedDeepBullFloor and stochKCrossOverD

// Ceiling Bear requires the actual K/D bearish crossover.
bool bearDeepCeilingReversal = touchedDeepBearCeiling and stochKCrossUnderD

// Normal OB/OS reversals require actual K/D crossover.
bool normalBullOsReversal = (stochK[1] < osLevel or stochK[2] < osLevel or lowestStochRecent < osLevel) and stochKCrossOverD
bool normalBearObReversal = (stochK[1] > obLevel or stochK[2] > obLevel or highestStochRecent > obLevel) and stochKCrossUnderD

// Caution reset signals: oscillator touched the reset zone, then K/D crossed back in trend direction.
bool bullResetSignal = showResetSignals and touchedResetBullZone and stochKCrossOverD
bool bearResetSignal = showResetSignals and touchedResetBearZone and stochKCrossUnderD

bool bullObOsReversal = normalBullOsReversal or bullDeepFloorReversal
bool bearObOsReversal = normalBearObReversal or bearDeepCeilingReversal

// If deep floor/ceiling was touched recently, block early signals until K/D confirms.
bool floorBullGateOk = not requireFloorCross or not touchedDeepBullFloor or stochK > stochD
bool ceilingBearGateOk = not requireCeilingCross or not touchedDeepBearCeiling or stochK < stochD

// Midpoint Continuation
bool bullCrossMid = ta.crossover(stochK, midContLevel)
bool bearCrossMid = ta.crossunder(stochK, midContLevel)

bool kInMidZoneNow = stochK >= midContLevel - midContTol and stochK <= midContLevel + midContTol

bool kTouchedMidZoneRecent = false
for i = 0 to midLookback - 1
    if stochK[i] >= midContLevel - midContTol and stochK[i] <= midContLevel + midContTol
        kTouchedMidZoneRecent := true

bool bullCrossRecent = math.sum(bullCrossMid ? 1 : 0, midLookback) > 0
bool bearCrossRecent = math.sum(bearCrossMid ? 1 : 0, midLookback) > 0

bool bullMidLocationOk = requireCurrentMidZone ? kInMidZoneNow : stochK <= midScoreMaxStochBull
bool bearMidLocationOk = requireCurrentMidZone ? kInMidZoneNow : stochK >= midScoreMinStochBear

bool bullMidCont = useMidCont and bullMidLocationOk and (bullCrossRecent or kTouchedMidZoneRecent) and (not reqKAboveD or stochK > stochD) and (not reqContSlope or kRising)
bool bearMidCont = useMidCont and bearMidLocationOk and (bearCrossRecent or kTouchedMidZoneRecent) and (not reqKBelowD or stochK < stochD) and (not reqContSlope or kFalling)

// Extreme Grade Caps
bool bullTooExtended = capExtremeGrades and stochK >= bullGradeCapAbove
bool bearTooExtended = capExtremeGrades and stochK <= bearGradeCapBelow

// Grades
int bullScore = 0
if structureBull
    if bullObOsReversal and not bullTooExtended
        bullScore := 5
    else if bullResetSignal
        bullScore := 3
    else if bullMidCont and emaBullAgrees
        bullScore := 4
    else if bullMidCont
        bullScore := 3
    else if kRising
        bullScore := bullTooExtended ? 2 : 3
    else
        bullScore := 2

int bearScore = 0
if structureBear
    if bearObOsReversal and not bearTooExtended
        bearScore := 5
    else if bearResetSignal
        bearScore := 3
    else if bearMidCont and emaBearAgrees
        bearScore := 4
    else if bearMidCont
        bearScore := 3
    else if kFalling
        bearScore := bearTooExtended ? 2 : 3
    else
        bearScore := 2

getGrade(int score) =>
    string res = "C"
    if score >= 5
        res := "A+"
    else if score == 4
        res := "A"
    else if score == 3
        res := "B+"
    else if score == 2
        res := "B"
    res

bool bullCond = structureBull and bullScore >= 2 and floorBullGateOk and (bar_index - lastSigBar > cooldown) and (not useStoch or stochBullAgrees or bullObOsReversal or bullMidCont or bullResetSignal) and (not reqMidCont or bullObOsReversal or bullMidCont or bullResetSignal)
bool bearCond = structureBear and bearScore >= 2 and ceilingBearGateOk and (bar_index - lastSigBar > cooldown) and (not useStoch or stochBearAgrees or bearObOsReversal or bearMidCont or bearResetSignal) and (not reqMidCont or bearObOsReversal or bearMidCont or bearResetSignal)

bool isBullSetup = bullCond
bool isBearSetup = bearCond

if isBullSetup or isBearSetup
    lastSigBar := bar_index

// --- Oscillator Plots ---
hline(100, "Top Boundary", color.new(color.gray, 100))
hline(80, "Overbought", color.gray, hline.style_dashed)
hline(50, "Midline", color.gray, hline.style_dotted)
hline(20, "Oversold", color.gray, hline.style_dashed)
hline(0, "Bottom Boundary", color.new(color.gray, 100))

plot(stochK, "Stoch K", color = kColor)
plot(stochD, "Stoch D", color = dColor)

plot(100, "Scale Anchor 100", display = display.none)
plot(0, "Scale Anchor 0", display = display.none)

bgcolor(showMomBg ? (stochK > stochD ? color.new(#089981, 90) : color.new(#f23645, 90)) : na)

// Markers
plotshape(isBullSetup ? stochK : na, "Bull Marker", shape.triangleup, location.absolute, color.new(#089981, 0), size = size.tiny)
plotshape(isBearSetup ? stochK : na, "Bear Marker", shape.triangledown, location.absolute, color.new(#f23645, 0), size = size.tiny)

if isBullSetup
    string txt = getGrade(bullScore)
    bool bullResetLabel = bullResetSignal and not bullObOsReversal
    if bullDeepFloorReversal
        txt += "\nFloor Bull"
    else if bullResetLabel
        txt += "\nReset Bull"
    else if bullMidCont and not bullObOsReversal
        txt += "\n50 Bull"
    else if bullTooExtended
        txt += "\nExt Bull"
    color bullTxtColor = bullResetLabel ? resetTextColor : #089981
    label.new(bar_index, stochK, txt, color = color.new(color.white, 100), textcolor = bullTxtColor, style = label.style_label_up, size = size.small)

if isBearSetup
    string txt = getGrade(bearScore)
    bool bearResetLabel = bearResetSignal and not bearObOsReversal
    if bearDeepCeilingReversal
        txt += "\nCeiling Bear"
    else if bearResetLabel
        txt += "\nReset Bear"
    else if bearMidCont and not bearObOsReversal
        txt += "\n50 Bear"
    else if bearTooExtended
        txt += "\nExt Bear"
    color bearTxtColor = bearResetLabel ? resetTextColor : #f23645
    label.new(bar_index, stochK, txt, color = color.new(color.white, 100), textcolor = bearTxtColor, style = label.style_label_down, size = size.small)
````
