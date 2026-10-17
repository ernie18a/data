# OYO v1

- url: https://www.tradingview.com/script/1ur6iTpw-OYO-v1/
- type: indicator
- pine_id: PUB;eae7e5be3ee0440da5fdaba6ae12d1fb
- version: 1.0

## Description

free all chart pattern showing you possible chart directions

## Source Code

````pine
//@version=6
indicator("Yousef All Chart Patterns Detector v1", overlay=true, max_labels_count=500, max_lines_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pivotLen      = input.int(5, "Pivot Strength", minval=2, maxval=20)
tolerancePct  = input.float(0.7, "Pattern Tolerance %", minval=0.1, maxval=5.0, step=0.1)
minBarsGap    = input.int(8, "Minimum Bars Between Same Pattern", minval=1)
showTriangles = input.bool(true, "Show Triangles / Wedges")
showDoubles   = input.bool(true, "Show Double Tops / Bottoms")
showHS        = input.bool(true, "Show Head & Shoulders")
showFlags     = input.bool(true, "Show Bull / Bear Flags")

bullColor = color.lime
bearColor = color.red
warnColor = color.orange
infoColor = color.aqua

tol = tolerancePct / 100.0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Pivot storage
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float[] highs = array.new_float()
var int[]   highBars = array.new_int()

var float[] lows = array.new_float()
var int[]   lowBars = array.new_int()

if not na(ph)
    array.push(highs, ph)
    array.push(highBars, bar_index - pivotLen)
    if array.size(highs) > 10
        array.shift(highs)
        array.shift(highBars)

if not na(pl)
    array.push(lows, pl)
    array.push(lowBars, bar_index - pivotLen)
    if array.size(lows) > 10
        array.shift(lows)
        array.shift(lowBars)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Helper functions
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_high(back) =>
    array.get(highs, array.size(highs) - 1 - back)

f_highBar(back) =>
    array.get(highBars, array.size(highBars) - 1 - back)

f_low(back) =>
    array.get(lows, array.size(lows) - 1 - back)

f_lowBar(back) =>
    array.get(lowBars, array.size(lowBars) - 1 - back)

f_near(a, b, tolerance) =>
    math.abs(a - b) / b <= tolerance

f_slope(v1, b1, v2, b2) =>
    b2 == b1 ? 0.0 : (v2 - v1) / (b2 - b1)

f_label(txt, y, isBull) =>
    label.new(
         bar_index - pivotLen,
         y,
         txt,
         style = isBull ? label.style_label_up : label.style_label_down,
         textcolor = color.white,
         color = isBull ? bullColor : bearColor,
         size = size.small
     )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Cooldowns
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var int lastDoubleTop = na
var int lastDoubleBottom = na
var int lastHS = na
var int lastInvHS = na
var int lastAscTri = na
var int lastDescTri = na
var int lastSymTri = na
var int lastRiseWedge = na
var int lastFallWedge = na
var int lastBullFlag = na
var int lastBearFlag = na

canTrigger(lastBar) =>
    na(lastBar) or bar_index - lastBar > minBarsGap

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Pattern booleans
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
doubleTop = false
doubleBottom = false
headShoulders = false
invHeadShoulders = false
ascendingTriangle = false
descendingTriangle = false
symTriangle = false
risingWedge = false
fallingWedge = false
bullFlag = false
bearFlag = false

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Double Top
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if showDoubles and not na(ph) and array.size(highs) >= 2
    h0 = f_high(0)
    h1 = f_high(1)

    if f_near(h0, h1, tol) and canTrigger(lastDoubleTop)
        doubleTop := true
        lastDoubleTop := bar_index
        f_label("Double Top\nPossible Bearish Reversal", h0, false)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Double Bottom
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if showDoubles and not na(pl) and array.size(lows) >= 2
    l0 = f_low(0)
    l1 = f_low(1)

    if f_near(l0, l1, tol) and canTrigger(lastDoubleBottom)
        doubleBottom := true
        lastDoubleBottom := bar_index
        f_label("Double Bottom\nPossible Bullish Reversal", l0, true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Head & Shoulders
// Need last 3 pivot highs:
// left shoulder, head, right shoulder
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if showHS and not na(ph) and array.size(highs) >= 3
    rightShoulder = f_high(0)
    head = f_high(1)
    leftShoulder = f_high(2)

    shouldersNear = f_near(leftShoulder, rightShoulder, tol * 1.5)
    headHigher = head > leftShoulder and head > rightShoulder

    if shouldersNear and headHigher and canTrigger(lastHS)
        headShoulders := true
        lastHS := bar_index
        f_label("Head & Shoulders\nBearish Pattern", rightShoulder, false)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inverse Head & Shoulders
// Need last 3 pivot lows:
// left shoulder, head, right shoulder
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if showHS and not na(pl) and array.size(lows) >= 3
    rightShoulderLow = f_low(0)
    headLow = f_low(1)
    leftShoulderLow = f_low(2)

    shouldersNearLow = f_near(leftShoulderLow, rightShoulderLow, tol * 1.5)
    headLower = headLow < leftShoulderLow and headLow < rightShoulderLow

    if shouldersNearLow and headLower and canTrigger(lastInvHS)
        invHeadShoulders := true
        lastInvHS := bar_index
        f_label("Inverse H&S\nBullish Pattern", rightShoulderLow, true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Triangles and Wedges
// Uses last two highs + last two lows
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if showTriangles and array.size(highs) >= 2 and array.size(lows) >= 2
    hNow = f_high(0)
    hPrev = f_high(1)
    hbNow = f_highBar(0)
    hbPrev = f_highBar(1)

    lNow = f_low(0)
    lPrev = f_low(1)
    lbNow = f_lowBar(0)
    lbPrev = f_lowBar(1)

    highSlope = f_slope(hPrev, hbPrev, hNow, hbNow)
    lowSlope = f_slope(lPrev, lbPrev, lNow, lbNow)

    highsFlat = f_near(hNow, hPrev, tol)
    lowsFlat = f_near(lNow, lPrev, tol)

    highsFalling = hNow < hPrev
    highsRising = hNow > hPrev
    lowsRising = lNow > lPrev
    lowsFalling = lNow < lPrev

    priceY = close

    if highsFlat and lowsRising and canTrigger(lastAscTri)
        ascendingTriangle := true
        lastAscTri := bar_index
        label.new(bar_index, priceY, "Ascending Triangle\nBullish Bias", style=label.style_label_up, color=infoColor, textcolor=color.white, size=size.small)

    if lowsFlat and highsFalling and canTrigger(lastDescTri)
        descendingTriangle := true
        lastDescTri := bar_index
        label.new(bar_index, priceY, "Descending Triangle\nBearish Bias", style=label.style_label_down, color=warnColor, textcolor=color.white, size=size.small)

    if highsFalling and lowsRising and canTrigger(lastSymTri)
        symTriangle := true
        lastSymTri := bar_index
        label.new(bar_index, priceY, "Symmetrical Triangle\nBreakout Soon", style=label.style_label_left, color=color.gray, textcolor=color.white, size=size.small)

    if highsRising and lowsRising and lowSlope > highSlope and canTrigger(lastRiseWedge)
        risingWedge := true
        lastRiseWedge := bar_index
        label.new(bar_index, priceY, "Rising Wedge\nBearish Warning", style=label.style_label_down, color=bearColor, textcolor=color.white, size=size.small)

    if highsFalling and lowsFalling and highSlope < lowSlope and canTrigger(lastFallWedge)
        fallingWedge := true
        lastFallWedge := bar_index
        label.new(bar_index, priceY, "Falling Wedge\nBullish Warning", style=label.style_label_up, color=bullColor, textcolor=color.white, size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Simple Bull Flag / Bear Flag Detection
// Strong impulse + small pullback/consolidation
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ema20 = ta.ema(close, 20)
atr = ta.atr(14)

impulseBull = close > close[10] + atr * 2
impulseBear = close < close[10] - atr * 2

smallPullbackBull = close < ta.highest(close, 5) and close > ema20
smallPullbackBear = close > ta.lowest(close, 5) and close < ema20

if showFlags and impulseBull and smallPullbackBull and canTrigger(lastBullFlag)
    bullFlag := true
    lastBullFlag := bar_index
    label.new(bar_index, low, "Bull Flag\nContinuation Setup", style=label.style_label_up, color=bullColor, textcolor=color.white, size=size.small)

if showFlags and impulseBear and smallPullbackBear and canTrigger(lastBearFlag)
    bearFlag := true
    lastBearFlag := bar_index
    label.new(bar_index, high, "Bear Flag\nContinuation Setup", style=label.style_label_down, color=bearColor, textcolor=color.white, size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Optional EMA guide
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(ema20, "EMA 20", color=color.yellow)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alerts
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
anyPattern = doubleTop or doubleBottom or headShoulders or invHeadShoulders or ascendingTriangle or descendingTriangle or symTriangle or risingWedge or fallingWedge or bullFlag or bearFlag

alertcondition(anyPattern, "Chart Pattern Detected", "A chart pattern was detected on {{ticker}} at {{interval}}.")
alertcondition(doubleTop, "Double Top", "Double Top detected on {{ticker}}.")
alertcondition(doubleBottom, "Double Bottom", "Double Bottom detected on {{ticker}}.")
alertcondition(headShoulders, "Head & Shoulders", "Head & Shoulders detected on {{ticker}}.")
alertcondition(invHeadShoulders, "Inverse Head & Shoulders", "Inverse Head & Shoulders detected on {{ticker}}.")
alertcondition(ascendingTriangle, "Ascending Triangle", "Ascending Triangle detected on {{ticker}}.")
alertcondition(descendingTriangle, "Descending Triangle", "Descending Triangle detected on {{ticker}}.")
alertcondition(symTriangle, "Symmetrical Triangle", "Symmetrical Triangle detected on {{ticker}}.")
alertcondition(risingWedge, "Rising Wedge", "Rising Wedge detected on {{ticker}}.")
alertcondition(fallingWedge, "Falling Wedge", "Falling Wedge detected on {{ticker}}.")
alertcondition(bullFlag, "Bull Flag", "Bull Flag detected on {{ticker}}.")
alertcondition(bearFlag, "Bear Flag", "Bear Flag detected on {{ticker}}.")
````
