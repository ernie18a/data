# D/W/M EMA (Auto Bar-Count Period)

- url: https://www.tradingview.com/script/sYICHKLx-D-W-M-EMA-Auto-Bar-Count-Period/
- type: indicator
- pine_id: PUB;e86109a3704e4d7fad832a8f50278aea
- version: 1.0

## Description

D/W/M EMA (Auto Bar-Count Period)

This indicator plots three EMAs — Daily, Weekly, and Monthly — directly on your current chart timeframe, without using higher-timeframe security() calls.

How it works:
Instead of pulling daily/weekly/monthly candles from a higher timeframe, the script counts how many bars of your current chart timeframe make up one full trading day, one full week, and one full month. It then uses that bar count as the EMA length, calculated natively on your chart's own resolution.

For example, on a 5-minute chart, if a trading session contains 78 five-minute bars, the "Daily EMA" becomes a 78-period EMA computed on the 5-minute chart itself — effectively approximating a daily EMA's behavior while staying perfectly in sync with your intraday price action, with no repainting or timeframe-alignment issues.

The bar count auto-adjusts to whatever timeframe you're viewing, so switching charts (1m, 5m, 1H, etc.) automatically recalculates the correct EMA length for each period.

Features:

Three independent EMAs: Daily, Weekly, Monthly — each with its own color and on/off toggle
Adjustable EMA source (close, open, hl2, etc.)
Adjustable line width
Right-side labels showing each EMA's value and its current calculated period length (e.g., "D ema (78)")
Runs entirely on the chart's native timeframe — no higher-timeframe data requests

Notes:

The very first day/week/month on the chart uses a fallback starting length until one full period has completed and a real bar count is established.
This is a technical analysis tool and does not constitute financial advice. Past performance and indicator signals do not guarantee future results — always use proper risk management.

## Source Code

````pine
//@version=6
indicator('D/W/M EMA (Auto Bar-Count Period)', shorttitle = 'DWM EMA', overlay = true, max_labels_count = 50)

// ─────────────────────────────
// INPUTS
// ─────────────────────────────
srcInput = input.source(close, 'Source')
lineWidth = input.int(2, 'Line Width', minval = 1)
labelOffset = input.int(15, 'Label Offset (bars to the right)', minval = 1)

showD = input.bool(true, 'Show', group = 'Daily EMA', inline = 'd')
colD = input.color(color.new(#2962ff, 55), 'Color', group = 'Daily EMA', inline = 'd')

showW = input.bool(true, 'Show', group = 'Weekly EMA', inline = 'w')
colW = input.color(color.new(#ff6f00, 53), 'Color', group = 'Weekly EMA', inline = 'w')

showM = input.bool(true, 'Show', group = 'Monthly EMA', inline = 'm')
colM = input.color(color.new(#aa00ff, 61), 'Color', group = 'Monthly EMA', inline = 'm')

// ─────────────────────────────
// COUNT HOW MANY CURRENT-TIMEFRAME BARS MAKE UP
// ONE TRADING DAY / WEEK / MONTH
// (counter resets when the higher period rolls over,
//  the length used for the EMA is the count from the
//  PREVIOUS completed period, kept live thereafter)
// ─────────────────────────────

// --- Daily ---
var int dayBarCount = 0
var int barsInDay = 20 // fallback until the first full day completes
newDay = ta.change(time('D')) != 0
if newDay
    if dayBarCount > 0
        barsInDay := dayBarCount
        barsInDay
    dayBarCount := 1
    dayBarCount
else
    dayBarCount := dayBarCount + 1
    dayBarCount

// --- Weekly ---
var int weekBarCount = 0
var int barsInWeek = 100 // fallback until the first full week completes
newWeek = ta.change(time('W')) != 0
if newWeek
    if weekBarCount > 0
        barsInWeek := weekBarCount
        barsInWeek
    weekBarCount := 1
    weekBarCount
else
    weekBarCount := weekBarCount + 1
    weekBarCount

// --- Monthly ---
var int monthBarCount = 0
var int barsInMonth = 400 // fallback until the first full month completes
newMonth = ta.change(time('M')) != 0
if newMonth
    if monthBarCount > 0
        barsInMonth := monthBarCount
        barsInMonth
    monthBarCount := 1
    monthBarCount
else
    monthBarCount := monthBarCount + 1
    monthBarCount

lenD = math.max(barsInDay, 1)
lenW = math.max(barsInWeek, 1)
lenM = math.max(barsInMonth, 1)

// ─────────────────────────────
// EMAs (calculated on the CURRENT chart timeframe,
// using the bar-count period derived above — no HTF/security calls)
//
// ta.ema() only accepts a fixed ("simple int") length, but our length
// changes at runtime ("series int"), so the EMA is implemented manually
// via its recursive formula, which has no such restriction.
// Each call site below keeps its own independent persistent state.
// ─────────────────────────────
f_dynamicEma(src, len) =>
    var float emaVal = na
    alpha = 2.0 / (len + 1)
    emaVal := na(emaVal) ? src : alpha * src + (1 - alpha) * emaVal
    emaVal

emaD = f_dynamicEma(srcInput, lenD)
emaW = f_dynamicEma(srcInput, lenW)
emaM = f_dynamicEma(srcInput, lenM)

plot(showD ? emaD : na, title = 'Daily EMA', color = colD, linewidth = math.max(1, lineWidth))
plot(showW ? emaW : na, title = 'Weekly EMA', color = colW, linewidth = math.max(1, lineWidth))
plot(showM ? emaM : na, title = 'Monthly EMA', color = colM, linewidth = math.max(1, lineWidth))

// ─────────────────────────────
// LABELS — offset to the right of the last bar
// ─────────────────────────────
var label lblD = na
var label lblW = na
var label lblM = na

if barstate.islast
    label.delete(lblD)
    label.delete(lblW)
    label.delete(lblM)

    if showD
        lblD := label.new(bar_index + labelOffset, emaD, 'D ema (' + str.tostring(lenD) + ')', style = label.style_label_left, color = color.new(colD, 0), textcolor = color.white, size = size.small)
        lblD
    if showW
        lblW := label.new(bar_index + labelOffset, emaW, 'W ema (' + str.tostring(lenW) + ')', style = label.style_label_left, color = color.new(colW, 0), textcolor = color.white, size = size.small)
        lblW
    if showM
        lblM := label.new(bar_index + labelOffset, emaM, 'M ema (' + str.tostring(lenM) + ')', style = label.style_label_left, color = color.new(colM, 0), textcolor = color.white, size = size.small)
        lblM
````
