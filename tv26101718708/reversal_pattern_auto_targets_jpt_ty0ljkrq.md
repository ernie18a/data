# Reversal Pattern Auto Targets [JPT]

- url: https://www.tradingview.com/script/TY0LJkRq-Reversal-Pattern-Auto-Targets-JPT/
- type: indicator
- pine_id: PUB;71ee86d3025e4318aed100b26637df80
- version: 1.0

## Description

https://www.tradingview.com/x/4OGSr1in/
🔷 [b]OVERVIEW[/b]

R[b]eversal Pattern Auto Targets [JPT][/b] is an educational price action indicator that automatically detects potential Double Top, Double Bottom, Head & Shoulders, and Inverse Head & Shoulders reversal structures using confirmed swing points. When a valid reversal setup is confirmed, the indicator displays a complete trade framework including Entry, Stop Loss, TP1, TP2, and TP3 levels.

The indicator is designed to help traders visualize reversal structures and practice structured trade planning. It does not predict future price movement or guarantee profitable trades.

🔷 FEATURES
Automatic reversal pattern detection
Double Top & Double Bottom patterns
Head & Shoulders & Inverse Head & Shoulders
Bullish and bearish reversal signals
Entry, Stop Loss, TP1, TP2, and TP3 levels
ATR-based Stop Loss buffer
Risk/Reward-based target calculations
Optional EMA 50 & EMA 200 trend filter
Confirmed pivot-based structure
Optional pivot structure visualization
Extendable Entry, SL, and TP levels
Optional pattern labels
Alert conditions for reversal signals and TP1
Clean chart layout with minimal clutter

🔷 HOW IT WORKS

Detects confirmed swing highs and swing lows.
Compares confirmed pivot points to identify potential reversal structures.
Confirms Double Top and Double Bottom setups through neckline breaks.
Identifies potential Head & Shoulders and Inverse Head & Shoulders structures.
Applies the optional EMA trend filter when enabled.
Generates a bullish or bearish reversal signal after confirmation.
Calculates Entry, Stop Loss, and multiple Take Profit levels automatically.
Displays the trade framework directly on the chart.

🔷 HOW TO USE

Look for newly detected REV BUY or REV SELL signals.
Identify the displayed reversal pattern and review its structure.
Check the overall market trend before considering a setup.
Use the Entry, SL, TP1, TP2, and TP3 levels as a trade-planning reference.
Consider using the optional EMA 50/200 filter for additional trend context.
Combine the indicator with your own price-action confirmation and risk-management rules.

🔷 NOTES

Signals are based on confirmed pivot and price-action structures.
The indicator uses confirmed pivots and does not use lookahead logic.
Historical signals do not guarantee future performance.
Entry, SL, and TP levels are analytical references and should not be treated as guaranteed trade levels.
Market conditions can change quickly, so proper risk management is essential.
This indicator is intended for educational and analytical purposes only.
No indicator can guarantee successful trades, and this script should not be used as the sole basis for investment or trading decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator("Reversal Pattern Auto Targets [JPT]", shorttitle="RPAT [JPT]", overlay=true, max_lines_count=500, max_labels_count=500)

//====================================================
// Reversal Pattern Auto Targets [JPT]
// Educational price-action tool.
// Uses confirmed pivots and does not use lookahead.
//====================================================

//────────────────────────────────────────────────────
// INPUTS
//────────────────────────────────────────────────────
groupPattern = "Pattern Engine"
pivotLen     = input.int(5, "Pivot Strength", minval=2, maxval=20, group=groupPattern)
tolerancePct = input.float(1.0, "Pattern Tolerance (%)", minval=0.1, maxval=5.0, step=0.1, group=groupPattern)
minBars      = input.int(5, "Minimum Pattern Bars", minval=2, maxval=100, group=groupPattern)
maxBars      = input.int(80, "Maximum Pattern Bars", minval=10, maxval=300, group=groupPattern)

groupPattern2 = "Pattern Types"
showDouble    = input.bool(true, "Double Top / Bottom", group=groupPattern2)
showHS        = input.bool(true, "Head & Shoulders", group=groupPattern2)

groupTrend = "Trend Filter"
useEMA      = input.bool(false, "Use EMA Trend Filter", group=groupTrend)
emaFastLen  = input.int(50, "Fast EMA", minval=1, group=groupTrend)
emaSlowLen  = input.int(200, "Slow EMA", minval=1, group=groupTrend)

groupTargets = "Auto Targets"
atrLen       = input.int(14, "ATR Length", minval=1, group=groupTargets)
atrSL        = input.float(0.5, "ATR Stop Buffer", minval=0.0, step=0.1, group=groupTargets)
target1RR    = input.float(1.0, "TP1 Risk/Reward", minval=0.25, step=0.25, group=groupTargets)
target2RR    = input.float(2.0, "TP2 Risk/Reward", minval=0.5, step=0.25, group=groupTargets)
target3RR    = input.float(3.0, "TP3 Risk/Reward", minval=1.0, step=0.25, group=groupTargets)

groupDisplay = "Display"
showEMA      = input.bool(false, "Show EMA", group=groupDisplay)
showLevels   = input.bool(true, "Show Entry / SL / TP", group=groupDisplay)
showLabels   = input.bool(true, "Show Pattern Labels", group=groupDisplay)
showStructure = input.bool(false, "Show Pivot Structure", group=groupDisplay)
extendLevels = input.bool(true, "Extend Target Levels", group=groupDisplay)

//────────────────────────────────────────────────────
// EMA ENGINE
//────────────────────────────────────────────────────
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

bullTrend = emaFast > emaSlow
bearTrend = emaFast < emaSlow

plot(showEMA ? emaFast : na, "EMA Fast", color=color.new(color.teal, 0), linewidth=1)
plot(showEMA ? emaSlow : na, "EMA Slow", color=color.new(color.orange, 0), linewidth=1)

//────────────────────────────────────────────────────
// CONFIRMED PIVOT ENGINE
//────────────────────────────────────────────────────
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float lastHigh = na
var float prevHigh = na
var int lastHighBar = na
var int prevHighBar = na

var float lastLow = na
var float prevLow = na
var int lastLowBar = na
var int prevLowBar = na

if not na(ph)
    prevHigh := lastHigh
    prevHighBar := lastHighBar
    lastHigh := ph
    lastHighBar := bar_index - pivotLen

if not na(pl)
    prevLow := lastLow
    prevLowBar := lastLowBar
    lastLow := pl
    lastLowBar := bar_index - pivotLen

// Optional pivot visualization
plotshape(showStructure and not na(ph), title="Pivot High", style=shape.triangledown,
     location=location.abovebar, offset=-pivotLen, size=size.tiny, color=color.new(color.red, 20))

plotshape(showStructure and not na(pl), title="Pivot Low", style=shape.triangleup,
     location=location.belowbar, offset=-pivotLen, size=size.tiny, color=color.new(color.lime, 20))

//────────────────────────────────────────────────────
// UTILITY
//────────────────────────────────────────────────────
tol = tolerancePct / 100.0
atr = ta.atr(atrLen)

isClose(a, b) =>
    not na(a) and not na(b) and math.abs(a - b) <= math.max(math.abs(a), math.abs(b)) * tol

validBars(startBar, endBar) =>
    not na(startBar) and not na(endBar) and
     endBar - startBar >= minBars and
     endBar - startBar <= maxBars

//────────────────────────────────────────────────────
// DOUBLE TOP
//────────────────────────────────────────────────────
//────────────────────────────────────────────────────
// DOUBLE TOP
//────────────────────────────────────────────────────

bool doubleTop = false
float doubleTopLevel = na

if showDouble and not na(prevHigh) and not na(lastHigh)
    bool sameHigh = isClose(prevHigh, lastHigh)
    bool structureOK = validBars(prevHighBar, lastHighBar)
    float neckline = lastLow

    bool necklineValid = not na(neckline) and
         not na(lastLowBar) and
         lastLowBar > prevHighBar and
         lastLowBar < lastHighBar

    doubleTop := sameHigh and structureOK and necklineValid and close < neckline
    doubleTopLevel := neckline

//────────────────────────────────────────────────────
// DOUBLE BOTTOM
//────────────────────────────────────────────────────

bool doubleBottom = false
float doubleBottomLevel = na

if showDouble and not na(prevLow) and not na(lastLow)
    bool sameLow = isClose(prevLow, lastLow)
    bool structureOK = validBars(prevLowBar, lastLowBar)
    float neckline = lastHigh

    bool necklineValid = not na(neckline) and
         not na(lastHighBar) and
         lastHighBar > prevLowBar and
         lastHighBar < lastLowBar

    doubleBottom := sameLow and structureOK and necklineValid and close > neckline
    doubleBottomLevel := neckline

//────────────────────────────────────────────────────
// HEAD & SHOULDERS
// Uses last two highs + intermediate low structure.
// Confirmation happens only after neckline break.
//────────────────────────────────────────────────────
bool hs = false
float hsNeckline = na

if showHS and not na(prevHigh) and not na(lastHigh) and not na(lastLow)
    leftShoulder = prevHigh
    rightShoulder = lastHigh
    head = lastLow

    // The latest high must be lower than the previous high
    // while the intervening low creates the neckline structure.
    shouldersOK = rightShoulder < leftShoulder
    structureOK = validBars(prevHighBar, lastHighBar)

    if shouldersOK and structureOK and not na(head)
        neckline = head
        hs := close < neckline
        hsNeckline := neckline

//────────────────────────────────────────────────────
// INVERSE HEAD & SHOULDERS
//────────────────────────────────────────────────────
bool ihs = false
float ihsNeckline = na

if showHS and not na(prevLow) and not na(lastLow) and not na(lastHigh)
    leftShoulder = prevLow
    rightShoulder = lastLow
    head = lastHigh

    shouldersOK = rightShoulder > leftShoulder
    structureOK = validBars(prevLowBar, lastLowBar)

    if shouldersOK and structureOK and not na(head)
        neckline = head
        ihs := close > neckline
        ihsNeckline := neckline

//────────────────────────────────────────────────────
// SIGNAL FILTER
//────────────────────────────────────────────────────
bullFilter = not useEMA or bullTrend
bearFilter = not useEMA or bearTrend

rawLong = doubleBottom or ihs
rawShort = doubleTop or hs

longSignal = rawLong and bullFilter
shortSignal = rawShort and bearFilter

// Prevent continuous signals
newLongSignal = longSignal and not longSignal[1]
newShortSignal = shortSignal and not shortSignal[1]

//────────────────────────────────────────────────────
// TRADE STATE
//────────────────────────────────────────────────────
var bool tradeActive = false
var bool tradeLong = false

var float entryPrice = na
var float stopPrice = na
var float tp1Price = na
var float tp2Price = na
var float tp3Price = na

var int tradeStartBar = na

//────────────────────────────────────────────────────
// OBJECT STORAGE
//────────────────────────────────────────────────────
var line entryLine = na
var line stopLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na

var label entryLabel = na
var label stopLabel = na
var label tp1Label = na
var label tp2Label = na
var label tp3Label = na

//────────────────────────────────────────────────────
// CLEAR OLD OBJECTS
//────────────────────────────────────────────────────
clearObjects() =>
    if not na(entryLine)
        line.delete(entryLine)
    if not na(stopLine)
        line.delete(stopLine)
    if not na(tp1Line)
        line.delete(tp1Line)
    if not na(tp2Line)
        line.delete(tp2Line)
    if not na(tp3Line)
        line.delete(tp3Line)

    if not na(entryLabel)
        label.delete(entryLabel)
    if not na(stopLabel)
        label.delete(stopLabel)
    if not na(tp1Label)
        label.delete(tp1Label)
    if not na(tp2Label)
        label.delete(tp2Label)
    if not na(tp3Label)
        label.delete(tp3Label)

//────────────────────────────────────────────────────
// LONG TRADE
//────────────────────────────────────────────────────
if newLongSignal
    clearObjects()

    tradeActive := true
    tradeLong := true
    tradeStartBar := bar_index

    entryPrice := close

    patternLow = not na(lastLow) ? lastLow : low
    stopPrice := patternLow - atr * atrSL

    risk = math.max(entryPrice - stopPrice, syminfo.mintick)

    tp1Price := entryPrice + risk * target1RR
    tp2Price := entryPrice + risk * target2RR
    tp3Price := entryPrice + risk * target3RR

//────────────────────────────────────────────────────
// SHORT TRADE
//────────────────────────────────────────────────────
if newShortSignal
    clearObjects()

    tradeActive := true
    tradeLong := false
    tradeStartBar := bar_index

    entryPrice := close

    patternHigh = not na(lastHigh) ? lastHigh : high
    stopPrice := patternHigh + atr * atrSL

    risk = math.max(stopPrice - entryPrice, syminfo.mintick)

    tp1Price := entryPrice - risk * target1RR
    tp2Price := entryPrice - risk * target2RR
    tp3Price := entryPrice - risk * target3RR

//────────────────────────────────────────────────────
// EXIT MANAGEMENT
//────────────────────────────────────────────────────
if tradeActive
    stopHit = tradeLong ? low <= stopPrice : high >= stopPrice
    tp3Hit = tradeLong ? high >= tp3Price : low <= tp3Price

    if stopHit or tp3Hit
        tradeActive := false

//────────────────────────────────────────────────────
// LEVEL DRAWING
//────────────────────────────────────────────────────
if showLevels and tradeActive
    endBar = extendLevels ? bar_index + 1 : bar_index + 10

    if na(entryLine)
        entryLine := line.new(tradeStartBar, entryPrice, endBar, entryPrice,
             extend=extendLevels ? extend.right : extend.none,
             color=color.new(color.blue, 0), width=2)

        stopLine := line.new(tradeStartBar, stopPrice, endBar, stopPrice,
             extend=extendLevels ? extend.right : extend.none,
             color=color.new(color.red, 0), width=2)

        tp1Line := line.new(tradeStartBar, tp1Price, endBar, tp1Price,
             extend=extendLevels ? extend.right : extend.none,
             color=color.new(color.green, 0), width=1)

        tp2Line := line.new(tradeStartBar, tp2Price, endBar, tp2Price,
             extend=extendLevels ? extend.right : extend.none,
             color=color.new(color.green, 0), width=1)

        tp3Line := line.new(tradeStartBar, tp3Price, endBar, tp3Price,
             extend=extendLevels ? extend.right : extend.none,
             color=color.new(color.green, 0), width=2)

        if showLabels
            entryLabel := label.new(bar_index, entryPrice, "ENTRY",
                 style=label.style_label_left, textcolor=color.white,
                 color=color.new(color.blue, 0))

            stopLabel := label.new(bar_index, stopPrice, "SL",
                 style=label.style_label_left, textcolor=color.white,
                 color=color.new(color.red, 0))

            tp1Label := label.new(bar_index, tp1Price, "TP1",
                 style=label.style_label_left, textcolor=color.white,
                 color=color.new(color.green, 0))

            tp2Label := label.new(bar_index, tp2Price, "TP2",
                 style=label.style_label_left, textcolor=color.white,
                 color=color.new(color.green, 0))

            tp3Label := label.new(bar_index, tp3Price, "TP3",
                 style=label.style_label_left, textcolor=color.white,
                 color=color.new(color.green, 0))

//────────────────────────────────────────────────────
// SIGNAL MARKERS
//────────────────────────────────────────────────────
plotshape(newLongSignal, title="Bullish Reversal",
     style=shape.labelup, location=location.belowbar,
     color=color.new(color.green, 0), textcolor=color.white,
     text="REV BUY", size=size.small)

plotshape(newShortSignal, title="Bearish Reversal",
     style=shape.labeldown, location=location.abovebar,
     color=color.new(color.red, 0), textcolor=color.white,
     text="REV SELL", size=size.small)

//────────────────────────────────────────────────────
// PATTERN NAMES
//────────────────────────────────────────────────────
if showLabels and newLongSignal
    patternName = doubleBottom ? "Double Bottom" : "Inverse H&S"

    label.new(
         bar_index,
         low,
         patternName,
         style=label.style_label_up,
         color=color.new(color.green, 10),
         textcolor=color.white)

if showLabels and newShortSignal
    patternName = doubleTop ? "Double Top" : "Head & Shoulders"

    label.new(
         bar_index,
         high,
         patternName,
         style=label.style_label_down,
         color=color.new(color.red, 10),
         textcolor=color.white)

//────────────────────────────────────────────────────
// ALERTS
//────────────────────────────────────────────────────
alertcondition(newLongSignal,
     title="Bullish Reversal",
     message="Bullish reversal pattern confirmed on {{ticker}} {{interval}}")

alertcondition(newShortSignal,
     title="Bearish Reversal",
     message="Bearish reversal pattern confirmed on {{ticker}} {{interval}}")

alertcondition(tradeActive and tradeLong and high >= tp1Price,
     title="Long TP1",
     message="Long TP1 reached on {{ticker}} {{interval}}")

alertcondition(tradeActive and not tradeLong and low <= tp1Price,
     title="Short TP1",
     message="Short TP1 reached on {{ticker}} {{interval}}")
````
