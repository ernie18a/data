<!-- tradingview-pine-id: PUB;1cbcc1a830a248b0b5cd916e1290829d -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# The Deceit Signature

Source: https://www.tradingview.com/script/SOszrCYT/

## Description

The Deceit Signature

WHAT IT IS

The Deceit Signature is a pattern-recognition tool built around a recurring market behavior: a tight range breaks sharply in one direction, only to reverse just as sharply moments later, sweeping the liquidity resting near a prior swing point before the market shows its real direction. This is the same mechanic behind concepts like the ICT "Judas Swing" or Wyckoff's spring/upthrust: a false move designed to trap traders on the wrong side before the actual move develops.

This indicator automates the detection of that sequence and marks it directly on the chart, so it can be studied and monitored without having to spot it manually candle by candle.

WHAT IT DOES

On every closed bar, the indicator looks for the following sequence:

- A range: price consolidates within a band narrow enough relative to the ATR to qualify as a tight range.
- A first sharp break: a strong candle (measured against the ATR) closes beyond one edge of the range. This is the fakeout, the move designed to trap traders positioning in that direction.
- A second sharp break, in the opposite direction, within a configurable number of bars. This is the move that confirms the first one was a trap, and it is the move that goes looking for liquidity.
- A liquidity box: once the second break is confirmed, the script looks back for the two most recent swing pivots on the side opposite to the first break (below the range for a bullish fakeout, above it for a bearish one) and draws a box between them. This is the zone where price is expected to sweep resting liquidity before reversing back in the direction of the original fakeout.
- A touch marker: once price trades back into that liquidity box, a small triangle marks the candle that touched it, and the box is automatically removed a configurable number of bars later, keeping the chart clean while still leaving the range and both breaks visible for reference.

Breaks caused by a price gap (no overlap with the previous candle) are ignored. The pattern only counts when the move happens through actual trading, not through a jump in price with nothing traded in between.

HOW TO USE IT

Add the indicator to any chart, on any timeframe. When the full sequence is detected, it draws the range box, labels both breaks ("Break 1 (fakeout)" and "Break 2 (liquidity grab)"), and plots the liquidity box for that setup. An alert condition is available to notify you as soon as a first break occurs, so you can start watching for the confirming second break, and a general alert fires when the full pattern is confirmed.

This is a visual and analytical tool for identifying the pattern, not an automated entry system. What you do once the liquidity box is drawn, and once price reacts inside it, is a separate decision that requires its own judgment and risk management.

HOW TO CONFIGURE IT

Range group: "Bars to measure the range" sets how many bars are checked for tightness, and "Maximum range width (x ATR)" sets how narrow that range must be relative to the ATR to qualify as a valid consolidation.

Sharp Breaks group: "ATR period" sets the ATR length used throughout the script. "Minimum strength of the breakout candle (x ATR)" sets how large a candle's range must be, relative to the ATR, to count as a sharp break. "Max bars between 1st and 2nd break" sets the window in which the second break must appear for the pattern to be confirmed; if it doesn't arrive in time, the setup is discarded.

Pivots / Liquidity Box group: "Left bars" and "Right bars for pivot" control the swing pivot detection used to build the liquidity box. "Minimum distance from pivot to range edge (x ATR)" filters out minor pivots sitting too close to the range itself, forcing the script to look further back for a pivot that represents an actual separate swing.

Visual group: toggles for the range box and the liquidity box, colors for bullish and bearish setups, and how many bars to wait after the liquidity box is touched before it gets deleted from the chart.

A NOTE ON THE ATR STRENGTH SETTING

"Minimum strength of the breakout candle (x ATR)" is the single most important setting to calibrate for each asset and timeframe. Set it too low and the script will treat ordinary, unremarkable candles as "sharp" breaks, which produces false detections: the pattern will appear far more often than the actual deception behavior occurs, and most of those detections will be noise rather than the real setup. Start around 1.2-1.6x ATR, watch how it performs on the specific instrument and timeframe you trade, and raise it if you see the indicator firing on candles that don't visually stand out from the surrounding price action. There is no universal value: a setting that works well on a 1-hour crypto chart will not necessarily work on a daily stock chart or a weekly bond chart.

DISCLAIMER

This script is provided for educational and analytical purposes only. It identifies a recurring price pattern; it does not predict future price movement, and past instances of the pattern are not a guarantee that price will react the same way again. This is not financial advice, and any trading decision based on what this indicator shows remains the sole responsibility of the person making it.

---

## Source Code

````pine
// =====================================================================================
// The Deceit Signature
// -------------------------------------------------------------------------------------
// Detects and marks the sequence:
//   1) Range (tight consolidation)
//   2) First sharp break (the fakeout)
//   3) Second sharp break in the opposite direction, within a bar window
//   4) Liquidity box formed by the first and second pivots prior to the range,
//      on the side opposite to the first break
//
// IMPORTANT:
// - "Sharp" is subjective. The parameters below are a reasonable starting point,
//   but they need to be calibrated per asset and timeframe (context such as the
//   New York session open or scheduled news still matters: the indicator only
//   knows about candles, not context).
// - No repainting: all detection logic runs only on closed bars
//   (barstate.isconfirmed), but pivots use the standard confirmation lag of
//   ta.pivotlow/ta.pivothigh ("pivotRight" bars), as usual.
// - This is a visual pattern-identification tool, not an entry system or a
//   trading recommendation.
// =====================================================================================

//@version=6
indicator("The Deceit Signature", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ---------------------------- INPUTS ----------------------------
rangeGroup = "Range"
rangeBars      = input.int(10, "Bars to measure the range", minval=3, group=rangeGroup)
rangeAtrMult   = input.float(1.5, "Maximum range width (x ATR)", minval=0.1, step=0.1, group=rangeGroup)

breakoutGroup = "Sharp Breaks"
atrLen           = input.int(14, "ATR period", minval=1, group=breakoutGroup)
breakoutAtrMult  = input.float(1.2, "Minimum strength of the breakout candle (x ATR)", minval=0.1, step=0.1, group=breakoutGroup)
maxBarsBetween   = input.int(8, "Max bars between 1st and 2nd break", minval=1, group=breakoutGroup)

pivotGroup = "Pivots / Liquidity Box"
pivotLeft         = input.int(3, "Left bars for pivot", minval=1, group=pivotGroup)
pivotRight        = input.int(3, "Right bars for pivot (confirmation)", minval=1, group=pivotGroup)
minGapAtrMult     = input.float(1.0, "Minimum distance from pivot to range edge (x ATR)", minval=0.0, step=0.1, group=pivotGroup,
     tooltip="Filters out 'noise' pivots stuck to the range. Increase it if the liquidity box comes out too close to or overlapping the range.")

visualGroup = "Visual"
showRangeBox = input.bool(true, "Show range box", group=visualGroup)
showZoneBox  = input.bool(true, "Show liquidity box", group=visualGroup)
colUp   = input.color(color.new(color.teal, 0), "Bullish fakeout color (upward bounce expected)", group=visualGroup)
colDown = input.color(color.new(color.red, 0), "Bearish fakeout color (downward bounce expected)", group=visualGroup)
barsAfterTouch = input.int(50, "Bars to wait after the box is touched before deleting it", minval=1, group=visualGroup)

// ---------------------------- ATR ----------------------------
atrVal = ta.atr(atrLen)

// ---------------------------- RANGE DETECTION ----------------------------
rHigh = ta.highest(high, rangeBars)[1]
rLow  = ta.lowest(low, rangeBars)[1]
isRangeNow = (rHigh - rLow) <= rangeAtrMult * atrVal

// ---------------------------- SHARP BREAKOUT CANDLES ----------------------------
// A break must happen through actual price action (the candle's range overlaps the
// previous candle's range). A break caused by a gap (no overlap with the previous
// candle, e.g. weekend/session gaps) does NOT count, it's discarded as if it never
// happened.
candleRange = high - low
isStrongCandle = candleRange >= breakoutAtrMult * atrVal
hasGap = low > high[1] or high < low[1]
breaksUp   = isStrongCandle and close > rHigh and close > open and not hasGap
breaksDown = isStrongCandle and close < rLow  and close < open and not hasGap

// ---------------------------- PIVOT TRACKING ----------------------------
var array<int>   pivLowBar    = array.new_int()
var array<float> pivLowPrice  = array.new_float()
var array<int>   pivHighBar   = array.new_int()
var array<float> pivHighPrice = array.new_float()

float pl = ta.pivotlow(pivotLeft, pivotRight)
float ph = ta.pivothigh(pivotLeft, pivotRight)

if not na(pl)
    array.push(pivLowBar, bar_index - pivotRight)
    array.push(pivLowPrice, pl)
    if array.size(pivLowBar) > 300
        array.shift(pivLowBar)
        array.shift(pivLowPrice)

if not na(ph)
    array.push(pivHighBar, bar_index - pivotRight)
    array.push(pivHighPrice, ph)
    if array.size(pivHighBar) > 300
        array.shift(pivHighBar)
        array.shift(pivHighPrice)

// Finds the two most recent pivots before "beforeBar", requiring them to be
// separated at least "minGap" from the reference level (the range edge), to
// discard noise pivots stuck to the range itself.
// wantBelow = true  -> the pivot must be BELOW refLevel (bullish fakeout case)
// wantBelow = false -> the pivot must be ABOVE refLevel (bearish fakeout case)
f_findTwoPivots(arrBar, arrPrice, beforeBar, refLevel, minGap, wantBelow) =>
    int bar2 = na
    float price2 = na
    int bar1 = na
    float price1 = na
    if array.size(arrBar) > 0
        for i = array.size(arrBar) - 1 to 0
            b = array.get(arrBar, i)
            p = array.get(arrPrice, i)
            distOk = wantBelow ? (refLevel - p) >= minGap : (p - refLevel) >= minGap
            if b < beforeBar and distOk
                if na(bar2)
                    bar2 := b
                    price2 := p
                else
                    bar1 := b
                    price1 := p
                    break
    [bar1, price1, bar2, price2]

// ---------------------------- STATE MACHINE ----------------------------
var int    state          = 0   // 0 = searching, 1 = 1st break done, waiting for the 2nd
var float  sRangeHigh     = na
var float  sRangeLow      = na
var int    sRangeStartBar = na
var int    sFirstBreakBar = na
var string sDir           = na  // "up" (bullish fakeout) / "down" (bearish fakeout)
var int    barsSince      = 0
var float  sAtr           = na  // ATR at the moment of the 1st break, used for the pivot filter

// Active liquidity boxes: tracked so they can be deleted "barsAfterTouch" bars
// after being touched for the first time, leaving only the range, the breaks
// and a triangle marking the candle that touched it.
var array<box>    zoneBoxIds    = array.new<box>()
var array<float>  zoneTopArr    = array.new_float()
var array<float>  zoneBottomArr = array.new_float()
var array<bool>   zoneTouchedArr = array.new_bool()
var array<int>    zoneTouchBarArr = array.new_int()
var array<string> zoneDirArr    = array.new_string()

if barstate.isconfirmed
    if state == 0 and isRangeNow
        if breaksUp
            state          := 1
            sRangeHigh     := rHigh
            sRangeLow      := rLow
            sRangeStartBar := bar_index - rangeBars
            sFirstBreakBar := bar_index
            sDir           := "up"
            barsSince      := 0
            sAtr           := atrVal
        else if breaksDown
            state          := 1
            sRangeHigh     := rHigh
            sRangeLow      := rLow
            sRangeStartBar := bar_index - rangeBars
            sFirstBreakBar := bar_index
            sDir           := "down"
            barsSince      := 0
            sAtr           := atrVal

    else if state == 1
        barsSince += 1
        bool confirmed = false
        if sDir == "up" and isStrongCandle and close < sRangeLow and close < open and not hasGap
            confirmed := true
        else if sDir == "down" and isStrongCandle and close > sRangeHigh and close > open and not hasGap
            confirmed := true

        if confirmed
            if showRangeBox
                box.new(left=sRangeStartBar, top=sRangeHigh, right=sFirstBreakBar, bottom=sRangeLow,
                         border_color=color.gray, bgcolor=color.new(color.gray, 85),
                         text="Range", text_color=color.gray, text_size=size.small)

            label.new(x=sFirstBreakBar, y=sDir == "up" ? sRangeHigh : sRangeLow,
                       text="Break 1\n(fakeout)",
                       style=sDir == "up" ? label.style_label_down : label.style_label_up,
                       color=color.new(color.orange, 20), textcolor=color.white, size=size.small)

            label.new(x=bar_index, y=sDir == "up" ? low : high,
                       text="Break 2\n(liquidity grab)",
                       style=sDir == "up" ? label.style_label_up : label.style_label_down,
                       color=color.new(sDir == "up" ? colUp : colDown, 20), textcolor=color.white, size=size.small)

            if sDir == "up"
                [b1, p1, b2, p2] = f_findTwoPivots(pivLowBar, pivLowPrice, sRangeStartBar, sRangeLow, minGapAtrMult * sAtr, true)
                if not na(b1) and not na(b2) and showZoneBox
                    top = math.max(p1, p2)
                    bot = math.min(p1, p2)
                    zoneId = box.new(left=b1, top=top, right=bar_index, bottom=bot, extend=extend.right,
                             border_color=colUp, bgcolor=color.new(colUp, 85),
                             text="Liquidity Box", text_color=colUp, text_size=size.small)
                    array.push(zoneBoxIds, zoneId)
                    array.push(zoneTopArr, top)
                    array.push(zoneBottomArr, bot)
                    array.push(zoneTouchedArr, false)
                    array.push(zoneTouchBarArr, na)
                    array.push(zoneDirArr, "up")
            else
                [b1, p1, b2, p2] = f_findTwoPivots(pivHighBar, pivHighPrice, sRangeStartBar, sRangeHigh, minGapAtrMult * sAtr, false)
                if not na(b1) and not na(b2) and showZoneBox
                    top = math.max(p1, p2)
                    bot = math.min(p1, p2)
                    zoneId = box.new(left=b1, top=top, right=bar_index, bottom=bot, extend=extend.right,
                             border_color=colDown, bgcolor=color.new(colDown, 85),
                             text="Liquidity Box", text_color=colDown, text_size=size.small)
                    array.push(zoneBoxIds, zoneId)
                    array.push(zoneTopArr, top)
                    array.push(zoneBottomArr, bot)
                    array.push(zoneTouchedArr, false)
                    array.push(zoneTouchBarArr, na)
                    array.push(zoneDirArr, "down")

            alert("The Deceit Signature detected (" + sDir + ")", alert.freq_once_per_bar_close)
            state := 0

        else if barsSince > maxBarsBetween
            state := 0  // the second break did not arrive in time, pattern invalidated

// ---------------------------- ACTIVE LIQUIDITY BOX MANAGEMENT ----------------------------
// Every bar: if a box has not been touched yet, check whether the current candle's
// range enters it (mark it with a triangle). If it was already touched
// "barsAfterTouch" bars ago or more, delete it, leaving only the range, the
// break labels and the triangle.
if barstate.isconfirmed and array.size(zoneBoxIds) > 0
    for i = array.size(zoneBoxIds) - 1 to 0
        touched = array.get(zoneTouchedArr, i)
        topI = array.get(zoneTopArr, i)
        botI = array.get(zoneBottomArr, i)
        if not touched
            if low <= topI and high >= botI
                array.set(zoneTouchedArr, i, true)
                array.set(zoneTouchBarArr, i, bar_index)
                dirI = array.get(zoneDirArr, i)
                if dirI == "up"
                    label.new(x=bar_index, y=low, text="", style=label.style_triangleup, color=colUp, size=size.small)
                else
                    label.new(x=bar_index, y=high, text="", style=label.style_triangledown, color=colDown, size=size.small)
        else
            touchBarI = array.get(zoneTouchBarArr, i)
            if bar_index - touchBarI >= barsAfterTouch
                box.delete(array.get(zoneBoxIds, i))
                array.remove(zoneBoxIds, i)
                array.remove(zoneTopArr, i)
                array.remove(zoneBottomArr, i)
                array.remove(zoneTouchedArr, i)
                array.remove(zoneTouchBarArr, i)
                array.remove(zoneDirArr, i)

// ---------------------------- ALERTS ----------------------------
alertcondition(state == 1 and barsSince == 1, title="Possible fakeout (1st break)",
     message="First sharp break after a range detected. Watch for the second break in the opposite direction.")
````
