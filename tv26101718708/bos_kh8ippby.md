# BOS

- url: https://www.tradingview.com/script/kH8iPPBY-BOS/
- type: indicator
- pine_id: PUB;b4910d45b53e4ad1a34643eb1e9dfad5
- version: 1.0

## Description

puts up lines to show BOS and potential CISD but more for confrimations of breakign of the stucutre

## Source Code

````pine
//@version=6
indicator("BOS", overlay=true, max_lines_count=200)

// ═══════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════

grp1 = "Structure"
pivotLen       = input.int(3,    "Swing Length",              minval=1, maxval=20, group=grp1)
useCloseBreak  = input.bool(true,"Use close for break",       group=grp1)
extendBars     = input.int(40,   "Level extension bars",      minval=5, maxval=500, group=grp1)

grp2 = "Displacement"
dispATRMult    = input.float(1.5,"Displacement Min (ATR x)",  minval=0.5, step=0.25, group=grp2)
dispFVGCheck   = input.bool(true,"Require FVG behind BOS",    group=grp2,
                   tooltip="If ON, a displaced BOS must also leave an FVG behind it to qualify as strong")

grp3 = "Visuals"
showSwingLevels = input.bool(true, "Show active swing levels", group=grp3)
bullColorStrong = input.color(color.new(#26A69A, 0),  "Strong Bullish BOS",  group=grp3)
bearColorStrong = input.color(color.new(#EF5350, 0),  "Strong Bearish BOS",  group=grp3)
bullColorWeak   = input.color(color.new(#26A69A, 60), "Weak Bullish BOS",    group=grp3)
bearColorWeak   = input.color(color.new(#EF5350, 60), "Weak Bearish BOS",    group=grp3)
levelColorHigh  = input.color(color.new(#787B86, 35), "Swing high color",    group=grp3)
levelColorLow   = input.color(color.new(#787B86, 35), "Swing low color",     group=grp3)
strongWidth     = input.int(3, "Strong BOS line width",      minval=1, maxval=4, group=grp3)
weakWidth       = input.int(1, "Weak BOS line width",        minval=1, maxval=4, group=grp3)

// ═══════════════════════════════════════════════════════════════
// TIMEFRAME FILTER — 1m and 5m only
// ═══════════════════════════════════════════════════════════════

is1m = timeframe.period == "1"
is5m = timeframe.period == "5"
allowedTf = is1m or is5m

// ═══════════════════════════════════════════════════════════════
// ATR FOR DISPLACEMENT
// ═══════════════════════════════════════════════════════════════

atr = ta.atr(14)
dispMin = dispATRMult * nz(atr, 1.0)

// ═══════════════════════════════════════════════════════════════
// SWING DETECTION
// ═══════════════════════════════════════════════════════════════

ph = allowedTf ? ta.pivothigh(high, pivotLen, pivotLen) : na
pl = allowedTf ? ta.pivotlow(low, pivotLen, pivotLen) : na

var float lastSwingHigh    = na
var float lastSwingLow     = na
var int   lastSwingHighBar = na
var int   lastSwingLowBar  = na

if allowedTf and not na(ph)
    lastSwingHigh    := ph
    lastSwingHighBar := bar_index - pivotLen

if allowedTf and not na(pl)
    lastSwingLow     := pl
    lastSwingLowBar  := bar_index - pivotLen

// ═══════════════════════════════════════════════════════════════
// ACTIVE SWING LEVEL LINES
// ═══════════════════════════════════════════════════════════════

var line highLine = na
var line lowLine  = na

if allowedTf and showSwingLevels
    if not na(ph)
        if not na(highLine)
            line.delete(highLine)
        highLine := line.new(
             lastSwingHighBar, lastSwingHigh,
             lastSwingHighBar + extendBars, lastSwingHigh,
             color=levelColorHigh, style=line.style_solid, width=1)

    if not na(pl)
        if not na(lowLine)
            line.delete(lowLine)
        lowLine := line.new(
             lastSwingLowBar, lastSwingLow,
             lastSwingLowBar + extendBars, lastSwingLow,
             color=levelColorLow, style=line.style_solid, width=1)

// ═══════════════════════════════════════════════════════════════
// BOS DETECTION
// ═══════════════════════════════════════════════════════════════

var bool highBroken = false
var bool lowBroken  = false

if allowedTf and not na(ph)
    highBroken := false
if allowedTf and not na(pl)
    lowBroken := false

bullBreak = allowedTf and not na(lastSwingHigh) and
             (useCloseBreak ? close > lastSwingHigh : high > lastSwingHigh)
bearBreak = allowedTf and not na(lastSwingLow) and
             (useCloseBreak ? close < lastSwingLow : low < lastSwingLow)

bullBOS = bullBreak and not highBroken
bearBOS = bearBreak and not lowBroken

// ═══════════════════════════════════════════════════════════════
// DISPLACEMENT CHECK
//
// A "displaced" BOS has:
//   1. The BOS candle body is larger than dispATRMult x ATR
//   2. (Optional) The BOS candle leaves an FVG behind it
//
// Strong displacement = high conviction entry
// Weak/no displacement = lower conviction, needs better R:R
// ═══════════════════════════════════════════════════════════════

// Candle body size
bodySize = math.abs(close - open)

// FVG left behind by this candle
// Bullish FVG: current low > high[2] (gap up)
bullFVGBehind = bar_index >= 2 and low > high[2]
// Bearish FVG: current high < low[2] (gap down)
bearFVGBehind = bar_index >= 2 and high < low[2]

// Displacement qualification
bool bullDisplaced = bodySize >= dispMin
bool bearDisplaced = bodySize >= dispMin

if dispFVGCheck
    bullDisplaced := bullDisplaced and bullFVGBehind
    bearDisplaced := bearDisplaced and bearFVGBehind

// ═══════════════════════════════════════════════════════════════
// DRAW BOS LINES
// ═══════════════════════════════════════════════════════════════

if bullBOS
    highBroken := true

    bool isStrong = bullDisplaced
    color lineCol = isStrong ? bullColorStrong : bullColorWeak
    int   lineW   = isStrong ? strongWidth : weakWidth

    line.new(
         lastSwingHighBar, lastSwingHigh,
         bar_index, lastSwingHigh,
         color=lineCol, width=lineW, style=line.style_solid)

if bearBOS
    lowBroken := true

    bool isStrong = bearDisplaced
    color lineCol = isStrong ? bearColorStrong : bearColorWeak
    int   lineW   = isStrong ? strongWidth : weakWidth

    line.new(
         lastSwingLowBar, lastSwingLow,
         bar_index, lastSwingLow,
         color=lineCol, width=lineW, style=line.style_solid)

// ═══════════════════════════════════════════════════════════════
// HIDE ON NON-ALLOWED TIMEFRAMES
// ═══════════════════════════════════════════════════════════════

if not allowedTf
    if not na(highLine)
        line.delete(highLine)
        highLine := na
    if not na(lowLine)
        line.delete(lowLine)
        lowLine := na

// ═══════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════

alertcondition(bullBOS and bullDisplaced, "Strong BOS UP",   "Displaced BOS UP — high conviction long entry")
alertcondition(bearBOS and bearDisplaced, "Strong BOS DOWN", "Displaced BOS DOWN — high conviction short entry")
alertcondition(bullBOS and not bullDisplaced, "Weak BOS UP",   "Weak BOS UP — lower conviction, needs better R:R")
alertcondition(bearBOS and not bearDisplaced, "Weak BOS DOWN", "Weak BOS DOWN — lower conviction, needs better R:R")
````
