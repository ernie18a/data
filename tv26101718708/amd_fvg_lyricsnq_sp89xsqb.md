# AMD + FVG LyricsNQ

- url: https://www.tradingview.com/script/Sp89xSqb-AMD-FVG-LyricsNQ/
- type: indicator
- pine_id: PUB;df67ff1ebd584fe2b9420ecb1049963e
- version: 1.0

## Description

accumulation, manipulation, fvg and distribution. 

The strategy breaks market movements into three stages:Accumulation: Price consolidates in a tight range as "smart money" quietly builds their positions. Liquidity rests just above highs and below lows.Manipulation: Price sharply breaks out of the range to sweep liquidity, trapping retail traders in the wrong direction.Distribution: The market reverses violently, triggering the real directional move.

## Source Code

````pine
//@version=6
indicator("AMD + FVG LyricsNQ", overlay=true, max_boxes_count=50, max_labels_count=50)

// Tracking arrays for managing visual clutter
var array<box>   fvgBoxes    = array.new<box>()
var array<label> zoneLabels  = array.new<label>()
var array<label> manipLabels = array.new<label>()
var array<box>   manipBoxes  = array.new<box>()

// ============================================================
// PHASE 1: ACCUMULATION ZONE
// ============================================================
// Detect accumulation: price holding near lows, small range, low volatility
isAccumulation = ta.sma(ta.tr(true), 10) < ta.sma(ta.tr(true), 30) * 0.8 and close <= ta.sma(close, 20)

var box   accBox  = na
var label accLbl  = na
var float accLow  = na
var float accHigh = na

if isAccumulation
    if na(accLow)
        accLow  := low
        accHigh := high
        if not na(accBox)
            box.delete(accBox)
        if not na(accLbl)
            label.delete(accLbl)
        // Wide box: start 30 bars before first detection, extend forward as accumulation continues
        accBox := box.new(bar_index - 30, high, bar_index, low,
         bgcolor=color.new(#00BFFF, 90), border_color=#00BFFF)
        accLbl := label.new(bar_index, high, "ACCUMULATION",
         color=color.new(#00BFFF, 40), style=label.style_label_down, textcolor=color.white, size=size.large)
    else
        accLow  := math.min(accLow,  low)
        accHigh := math.max(accHigh, high)
        // Expand right edge as accumulation continues
        box.set_right(accBox, bar_index)
        box.set_top(accBox, accHigh)
        box.set_bottom(accBox, accLow)
        label.set_xy(accLbl, bar_index, accHigh)
        label.set_text(accLbl, "ACCUMULATION")
else
    accLow  := na
    accHigh := na

// ============================================================
// PHASE 2: MANIPULATION (Stop Hunt / Liquidity Grab)
// ============================================================
// Bearish manipulation: wick below recent range + bounce back (stop hunt of longs)
atr14 = ta.atr(14)
manipPeriod = 10
lowestLow  = ta.lowest(low, manipPeriod)[1]
highestHigh = ta.highest(high, manipPeriod)[1]

// Bearish manip: price briefly breaches below prior range, then closes back inside
manipLow  = low < lowestLow and close > low and close[1] <= lowestLow
// Bullish manip: price briefly spikes above prior range, then closes back inside
manipHigh = high > highestHigh and close < high and close[1] >= highestHigh

if manipLow
    if array.size(manipLabels) >= 5
        label.delete(array.shift(manipLabels))
    if array.size(manipBoxes) >= 5
        box.delete(array.shift(manipBoxes))
    // Zone box: 4 bars before to 4 bars after, covering wick low to close
    zoneBox = box.new(bar_index - 4, close, bar_index + 4, low,
     bgcolor=color.new(#FF4500, 85), border_color=#FF4500, border_style=line.style_solid)
    array.push(manipBoxes, zoneBox)
    lbl = label.new(bar_index, close, "MANIPULATION",
     color=color.new(#FF4500, 60), style=label.style_label_up, textcolor=color.white, size=size.large,
     textalign=text.align_center)
    array.push(manipLabels, lbl)

if manipHigh
    if array.size(manipLabels) >= 5
        label.delete(array.shift(manipLabels))
    if array.size(manipBoxes) >= 5
        box.delete(array.shift(manipBoxes))
    // Zone box: 4 bars before to 4 bars after, covering close to wick high
    zoneBox = box.new(bar_index - 4, high, bar_index + 4, close,
     bgcolor=color.new(#FF4500, 85), border_color=#FF4500, border_style=line.style_solid)
    array.push(manipBoxes, zoneBox)
    lbl = label.new(bar_index, high, "MANIPULATION",
     color=color.new(#FF4500, 60), style=label.style_label_down, textcolor=color.white, size=size.large,
     textalign=text.align_center)
    array.push(manipLabels, lbl)

// ============================================================
// PHASE 3: FAIR VALUE GAP (FVG) — MAIN SIGNAL
// ============================================================
// Bullish FVG: low[1] > high   — gap between candle 2 high and candle 1 low? Wait let me redefine:
// Bullish FVG: gap in price where Candle 2's high < Candle's low (the middle candle is the gap)
// Actually, the standard FVG: candle 2 high < candle low means there's a gap between candle 2's high and candle's low
// So: low > high[2] means current low is above the high 2 bars ago → bullish gap

fvgBullish = low > high[2]        // gap between high[2] and current low
fvgBearish = high < low[2]        // gap between low[2] and current high

if fvgBullish
    fvgTopLocal    = low
    fvgBottomLocal = high[2]
    // Manage FVG box limit: keep only last 5
    if array.size(fvgBoxes) >= 5
        box.delete(array.shift(fvgBoxes))
    b = box.new(bar_index[2], fvgTopLocal, bar_index, fvgBottomLocal,
     bgcolor=color.new(color.green, 90), border_color=color.lime,
     border_style=line.style_solid)
    array.push(fvgBoxes, b)

if fvgBearish
    fvgTopLocalB    = low[2]
    fvgBottomLocalB = high
    if array.size(fvgBoxes) >= 5
        box.delete(array.shift(fvgBoxes))
    b = box.new(bar_index[2], fvgTopLocalB, bar_index, fvgBottomLocalB,
     bgcolor=color.new(color.red, 90), border_color=color.maroon,
     border_style=line.style_solid)
    array.push(fvgBoxes, b)

// ============================================================
// PHASE 4: DISTRIBUTION
// ============================================================
// Detect distribution: price stalling near highs, wide range, high volatility, sellers appearing
isDistribution = ta.sma(ta.tr(true), 10) > ta.sma(ta.tr(true), 30) * 1.2 and close >= ta.sma(close, 20)

var box   distBox  = na
var label distLbl  = na
var float distLow  = na
var float distHigh = na

if isDistribution
    if na(distLow)
        distLow  := low
        distHigh := high
        if not na(distBox)
            box.delete(distBox)
        if not na(distLbl)
            label.delete(distLbl)
        // Wide box: start 15 bars before first detection, extend forward as distribution continues
        distBox := box.new(bar_index - 15, high, bar_index, low,
         bgcolor=color.new(#FF8C00, 90), border_color=#FF8C00)
        distLbl := label.new(bar_index, high, "DISTRIBUTION",
         color=color.new(#FF8C00, 40), style=label.style_label_down, textcolor=color.white, size=size.large)
    else
        distLow  := math.min(distLow,  low)
        distHigh := math.max(distHigh, high)
        // Expand right edge as distribution continues
        box.set_right(distBox, bar_index)
        box.set_top(distBox, distHigh)
        box.set_bottom(distBox, distLow)
        label.set_xy(distLbl, bar_index, distHigh)
        label.set_text(distLbl, "DISTRIBUTION")
else
    distLow  := na
    distHigh := na

// Cleanup is managed via tracked arrays — FVGs capped at 5, MANIP labels at 5.
// Zone boxes are single and reused per phase.
````
