# Aftershocks Fault

- url: https://www.tradingview.com/script/aGsmLnYd-Aftershocks-Fault/
- type: indicator
- pine_id: PUB;74451bebe0af4b869c600922fd506161
- version: 1.0

## Description

[b]Every aftershock starts as a coil.[/b]
[b]Fault is where the coin held still.[/b]

Three words to know.
[b]Coil[/b] is how quiet a coin has been.
Its range, measured against its own last five days.
100% is as still as it gets.
[b]Break[/b] is the first hour the price closes outside that quiet range.
[b]Weather[/b] is everything around the coin while you wait.

This script is the Fault.
It paints the quiet onto the candles, then adds it up by price.
The code is open. Anyone can read how the Coil is measured.
It measures. It does not predict.

[b]WHAT YOU SEE[/b]

Every candle takes a colour from its Coil.
Hot violet when the coin is loud. Cool teal when it is still.
Quiet stretches glow.
Candles keeping their usual colours? Hover the Fault name, open its menu, Visual order, Bring to front.

Bars on the right edge, under the title "quiet hours".
Each bar is a price row.
Its length is how many hours the coin closed at that price while it was quiet.
Bright bars are this day's stillness. Faint ones are last week's.

One dashed line, labelled "most quiet hours" with its price.
The row where this coin held still the longest.
A count of past hours. Not a level to trade.

[b]HOW TO READ IT[/b]

Set the chart to 1h. Put Fault on it. Drag the chart left a little so the bars have room.

Look at the candles first.
A run of teal is a coil building.
Violet is the coin moving.

Then look at the bars.
One wide bar: the coin spent its calm hours at one price.
Several small bars: the calm was spread out.
Bright bars: the quiet is recent. Faint bars: it is old.

Then open Coil and Break on the same chart.
Coil shows the number. Break shows where the quiet ended.
Fault shows where it lived.

[b]THE FULL SET[/b]

Fault is the open one. Its code is published.
Coil, Break and Weather are the protected set, each its own script.
Fault needs none of them. The chart above shows Fault alone.

[b]HOW IT WORKS[/b]

Hourly candles. 20 closes. 2 standard deviations. Ranked against the last 120 hours.
The Coil function is the Coil script's, copied unchanged.
One request for hourly data, read one candle behind. Nothing repaints.
The tint runs violet at 0%, slate at 50%, teal at 100%.
The bars count the last 120 hourly closes with a Coil of 90% or more, split into 40 price rows.
A bar fades by the age of its newest quiet hour.
The line sits in the fullest row. On a tie, the lower row.

Settings: the three tint colours, hours counted (120), quiet threshold (90%), rows (40), bar width.
The Coil itself has no settings. It cannot drift from the method.

[b]GOOD TO KNOW[/b]

Runs on 1-hour charts and below. Above 1 hour it halts and tells you so.
The Coil needs 139 hourly candles. Before that, no tint and no count.
The chart's own exchange feeds it, so another exchange gives different hours.
No alerts. No markers. No words on the candles.
The bars count hours, not volume.
Not a prediction. Not a trade signal. It counts where the quiet was.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PlayPlayTrade

//@version=6
// Aftershocks Fault: where a coin held still. Open source.
// Two things on the price chart, both from the Coil's own measurement (pine/aftershocks_coil.pine, docs/coil-spec.md):
//   1. every candle tinted by the Coil of the newest closed hourly candle, grey at 0% and teal at 100%;
//   2. a profile at the right edge: of the last N hourly closes, how many closed in each price row while
//      the Coil read the quiet threshold or more. The fullest row is drawn as a dashed line.
// A count of past hours. Not a forecast, and not a price to trade.
//
// The Coil, on 1-hour closes (hourlyCoil() below is aftershocks_coil.pine's, byte for byte):
//   bandwidth = (upper - lower) / middle, from 20-candle Bollinger bands at 2.0 population standard deviations
//   coil %    = 100 x (1 - below / 119), where below counts the last 120 bandwidths (newest included)
//               that are strictly narrower than the newest. 100 = the narrowest of the 120.
// request.security calls: 1. tests/test_fault_pine.py asserts the count and the copied function.
indicator("Aftershocks Fault", shorttitle = "Fault", overlay = true, max_bars_back = 200, max_boxes_count = 100, max_lines_count = 1, max_labels_count = 2)

// Fixed to the measured method: these are not inputs, so the reading cannot drift from the card's.
BB_PERIOD = 20
BB_STD_MULTIPLIER = 2.0
LOOKBACK = 120
// Ties must stay ties. The bot's statistics.fmean / pstdev are exact, so two windows holding the same
// closes in a different order give bit-identical bandwidths; Pine's float sums depend on the order and
// can leave one a few 1e-14 below the other, which would count it as lower. Measured on the ten card
// coins' last 3000 hourly candles: float error at most 3.8e-14 (relative), smallest real gap between
// distinct bandwidths 9.9e-8. 1e-10 sits between the two.
TIE_TOLERANCE = 1e-10

// The coil, width and open time of the previous (closed) hourly candle. Runs in the 1-hour context, so every series below is hourly.
hourlyCoil() =>
    middle = ta.sma(close, BB_PERIOD)
    sd = ta.stdev(close, BB_PERIOD, true)            // biased = true: population, divides by N
    upper = middle + BB_STD_MULTIPLIER * sd
    lower = middle - BB_STD_MULTIPLIER * sd
    bw = (upper - lower) / middle
    float coil = na
    if not na(bw[LOOKBACK - 1])
        current = bw
        int below = 0
        bool complete = true
        for j = 0 to LOOKBACK - 1
            v = bw[j]
            if na(v)
                complete := false
                break
            if v < current * (1.0 - TIE_TOLERANCE)   // strictly lower; a tie is not lower
                below += 1
        if complete
            coil := 100.0 * (1.0 - below / (LOOKBACK - 1.0))
    widthPct = close != 0 ? 100.0 * (upper - lower) / close : 0.0
    [coil[1], widthPct[1], time[1]]

// The newest closed hourly candle's Coil, close and open time. Runs in the 1-hour context.
quietReading() =>
    [hourCoil, hourWidth, hourTime] = hourlyCoil()
    [hourCoil, close[1], hourTime]

// One request. The [1] inside hourlyCoil() with lookahead_on is the non-repainting form used by
// aftershocks_coil.pine: every chart bar shows the reading of the newest hourly candle that had CLOSED
// when that bar opened, on history and live alike, and the same reading on chart timeframes up to 1h.
[coil, hourClose, hourOpen] = request.security(syminfo.tickerid, "60", quietReading(), lookahead = barmerge.lookahead_on)

// Settings. None of them reaches hourlyCoil(): the Coil itself is fixed.
tintLoud = input.color(#e040fb, "Coil 0%", group = "Candle tint")
tintMid = input.color(#6f7990, "Coil 50%", group = "Candle tint")
tintQuiet = input.color(#0fa394, "Coil 100%", group = "Candle tint")
hoursCounted = input.int(120, "Hours counted", minval = 24, maxval = 2000, group = "Profile")
quietThreshold = input.float(90.0, "Quiet threshold", minval = 0.0, maxval = 100.0, step = 1.0, group = "Profile")
rowCount = input.int(40, "Rows", minval = 2, maxval = 100, group = "Profile")
profileWidth = input.int(30, "Profile width (bars)", minval = 5, maxval = 200, group = "Profile", display = display.none)

PROFILE_GAP = 3                    // bars between the last candle and the profile
// One palette: the three tint inputs. tintQuiet also draws the bars, the dashed line and both labels.
// Each default reads at 3:1 or better on both TradingView themes (#131722 and #FFFFFF), and none is
// white, red or green (tests/test_pine_parity.py, PinePaletteTest).

aboveHourly = timeframe.in_seconds() > 3600
if aboveHourly
    runtime.error("Aftershocks Fault requires a chart timeframe of 1h or lower.")

// Part 1. Every candle tinted by its Coil on three points: hot violet at 0 (loud), slate at 50, teal at 100 (still).
// Drawn as a candle over the chart's own, so the body, wick and border all take the tint. No reading yet, no
// candle: the chart's own shows.
tint = na(coil) ? color(na) : coil <= 50 ? color.from_gradient(coil, 0, 50, tintLoud, tintMid) : color.from_gradient(coil, 50, 100, tintMid, tintQuiet)
plotcandle(open, high, low, close, title = "Coil tint", color = tint, wickcolor = tint, bordercolor = tint)

// Part 2. The last hoursCounted hourly closes and their Coil, one entry per hour, taken on the first
// chart bar of each hour (so a 5-minute chart adds one hour, not twelve).
var hourCloses = array.new<float>()
var hourCoils = array.new<float>()
firstBarOfHour = na(hourOpen[1]) or hourOpen != hourOpen[1]
if firstBarOfHour and not na(hourClose)
    array.push(hourCloses, hourClose)
    array.push(hourCoils, coil)
    while array.size(hourCloses) > hoursCounted
        array.shift(hourCloses)
        array.shift(hourCoils)

// Drawn on the last bar only: the old bars, line and label deleted, new ones made. At most 100 boxes.
var profileBoxes = array.new<box>()
var line fullestLine = na
var label fullestLabel = na
var label profileTitle = na
if barstate.islast
    for bx in profileBoxes
        box.delete(bx)
    array.clear(profileBoxes)
    line.delete(fullestLine)
    label.delete(fullestLabel)
    label.delete(profileTitle)
    counted = array.size(hourCloses)
    if counted > 0
        // Equal rows between the lowest and highest close of the window; each quiet close adds one to its row,
        // and the row remembers the newest hour (its index in the window) that added one.
        windowLow = array.min(hourCloses)
        windowHigh = array.max(hourCloses)
        rowHeight = (windowHigh - windowLow) / rowCount
        rowCounts = array.new<int>(rowCount, 0)
        rowNewest = array.new<int>(rowCount, -1)
        int quietTotal = 0
        for k = 0 to counted - 1
            hc = array.get(hourCoils, k)
            if not na(hc) and hc >= quietThreshold
                row = rowHeight > 0 ? math.min(rowCount - 1, int((array.get(hourCloses, k) - windowLow) / rowHeight)) : 0
                array.set(rowCounts, row, array.get(rowCounts, row) + 1)
                array.set(rowNewest, row, k)
                quietTotal += 1
        fullest = array.max(rowCounts)
        if fullest > 0
            left = bar_index + PROFILE_GAP
            int topRow = 0
            for r = 0 to rowCount - 1
                rowHits = array.get(rowCounts, r)
                if rowHits > 0
                    topRow := r
                    share = float(rowHits) / fullest
                    widthBars = math.max(1, math.round(profileWidth * share))
                    rowBottom = windowLow + r * rowHeight
                    // Age, not count, sets the strength: quiet 0 hours ago is 10% transparent, hoursCounted ago 75%.
                    hoursAgo = counted - 1 - array.get(rowNewest, r)
                    fade = math.min(75.0, 10.0 + 65.0 * hoursAgo / hoursCounted)
                    array.push(profileBoxes, box.new(left, rowBottom + rowHeight, left + widthBars, rowBottom, border_color = color(na), border_width = 0, bgcolor = color.new(tintQuiet, fade)))
            // One row above the highest bar drawn, with the same one-row gap the window's high used to get.
            profileTitle := label.new(left, windowLow + (topRow + 2) * rowHeight, "quiet hours", style = label.style_label_down, color = color(na), textcolor = tintQuiet, size = size.small)
            // The fullest row's middle. On a tie the lower row is drawn. The label sits just LEFT of the profile, so
            // it stays on screen however little right margin the chart has.
            fullestRow = array.indexof(rowCounts, fullest)
            price = windowLow + (fullestRow + 0.5) * rowHeight
            fullestLine := line.new(bar_index - 1, price, bar_index, price, extend = extend.both, color = tintQuiet, style = line.style_dashed, width = 1)
            note = str.tostring(fullest) + " of " + str.tostring(quietTotal) + " hours with a Coil of " + str.tostring(quietThreshold, "0.#") + "% or more closed in this row, out of the last " + str.tostring(counted) + " hourly closes."
            fullestLabel := label.new(left - 1, price, "most quiet hours  " + str.tostring(price, format.mintick), style = label.style_label_right, color = color(na), textcolor = tintQuiet, size = size.small, tooltip = note)
````
