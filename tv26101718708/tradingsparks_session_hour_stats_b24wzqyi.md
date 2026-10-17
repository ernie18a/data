# Trading-Sparks - Session Hour Stats

- url: https://www.tradingview.com/script/b24wzQYI-Trading-Sparks-Session-Hour-Stats/
- type: indicator
- pine_id: PUB;c699766e587a405886a0576001aedeff
- version: 1.0

## Description

Session Hour Stats splits the bars on your intraday chart by hour of the day and reports, for each hour, how the average bar in that hour has behaved over the loaded history.

What it shows
For every hour between the first and last hour you choose, one row with:
- Bars: how many bars fell in that hour.
- Avg move: the mean open-to-close change of those bars, as a percent of the open.
- t: the average move divided by its standard error, mean / (stdev / sqrt(n)).
- Avg range: the mean high-to-low range, as a percent of the open.
- Up %: the share of bars in that hour that closed above their open.
The hour with the largest average range is highlighted.

How it works
Each confirmed bar is assigned to an hour using the timezone you set, and its move, squared move, range and direction are added to that hour's totals. Nothing is counted until a bar closes, so the table does not change for past bars and the live bar is excluded until it completes.

Why the t column
An hourly average such as +0.03% looks like a bias until you compare it with how noisy individual bars are in that hour. The t value does that comparison. As a rough guide, when the absolute value of t is below 2 the average cannot be distinguished from zero on this sample, and the Avg move and t cells are dimmed. This is what separates the table from a plain average-by-hour display: it tells you which hourly differences are large enough to take seriously and which are likely noise.

How to use it
- Use it on an intraday chart between 1 minute and 1 hour. On daily and above it shows a note instead.
- Set the timezone to the exchange's: Asia/Kolkata for NSE and MCX, America/New_York for US equities, Etc/UTC for most crypto.
- Load as much history as your account allows; the Bars column tells you how much evidence each row rests on.
- Typical questions it answers: does the range concentrate in the first hour? Is there a consistent drift in the last hour? Is an apparent lunchtime bias real or noise?

Limitations
- It describes the bars currently loaded, which is a sample of the past, not a forecast.
- The t value assumes bars are independent, which intraday bars are not entirely; treat it as a screening guide, not a formal test.
- It produces no signals and should not be used as one on its own.

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// RakeshPoluri - © Trading-Sparks — trading-sparks.com

//@version=6
indicator("Trading-Sparks - Session Hour Stats", shorttitle = "Hour Stats", overlay = true)

// -----------------------------------------------------------------------------
// WHAT THIS SHOWS
//   For each hour of the trading day, over all bars loaded on the chart:
//     Bars       how many bars fell in that hour
//     Avg move   mean open-to-close change, % of open        (direction)
//     t          Avg move divided by its standard error      (is it noise?)
//     Avg range  mean high-to-low range, % of open           (opportunity)
//     Up %       share of bars that closed above their open  (bias)
//   The hour with the largest average range is highlighted.
//
// WHY THE t COLUMN
//   An hourly average of +0.03% looks like a bias until you ask how noisy the
//   individual bars are. t = mean / (stdev / sqrt(n)). Roughly, |t| below 2
//   means the average cannot be told apart from zero on this sample; the cell
//   is dimmed. It is a sample statistic, not a forecast.
//
// WHAT IT DOES NOT DO
//   No entries, exits or signals. It describes the bars loaded on the chart,
//   which depends on the account's history limit.
//
// REPAINTING
//   None. Each bar is counted once, when it is confirmed. The live bar is not
//   counted until it closes.
// -----------------------------------------------------------------------------

// Inputs
tz        = input.string("Asia/Kolkata", "Timezone for the hour buckets", tooltip = "Exchange time. Asia/Kolkata for NSE and MCX, America/New_York for US equities, Etc/UTC for crypto.")
firstHour = input.int(9,  "First hour to show", minval = 0, maxval = 23)
lastHour  = input.int(15, "Last hour to show",  minval = 0, maxval = 23)
showTable = input.bool(true, "Show table")
tblPos    = input.string("Top right", "Table position", options = ["Top right", "Top left", "Bottom right", "Bottom left"])

// Accumulators, one slot per hour of the day
var int[]   count   = array.new_int(24, 0)
var float[] sumMove = array.new_float(24, 0.0)
var float[] sumSq   = array.new_float(24, 0.0)
var float[] sumRng  = array.new_float(24, 0.0)
var int[]   upCount = array.new_int(24, 0)

// Count each bar exactly once, on confirmation.
if timeframe.isintraday and barstate.isconfirmed and open > 0
    h    = hour(time, tz)
    move = 100.0 * (close - open) / open
    array.set(count,   h, array.get(count, h) + 1)
    array.set(sumMove, h, array.get(sumMove, h) + move)
    array.set(sumSq,   h, array.get(sumSq, h) + move * move)
    array.set(sumRng,  h, array.get(sumRng, h) + 100.0 * (high - low) / open)
    if close > open
        array.set(upCount, h, array.get(upCount, h) + 1)

// Table
pos = switch tblPos
    "Top left"     => position.top_left
    "Bottom right" => position.bottom_right
    "Bottom left"  => position.bottom_left
    => position.top_right

rowsWanted = math.max(lastHour - firstHour + 1, 1)
var tbl = table.new(pos, 6, rowsWanted + 2, border_width = 1, border_color = color.new(#8B94A1, 80))

colHead = #8B94A1
colText = #ECEAE3
colUp   = #3FB07A
colDn   = #E0563B
colBg   = color.new(#151B23, 10)

if showTable and barstate.islast
    if not timeframe.isintraday
        table.cell(tbl, 0, 0, "Hour Stats: use on an intraday chart (1 minute to 1 hour).", text_color = colText, bgcolor = colBg)
    else
        table.cell(tbl, 0, 0, "Hour",      text_color = colHead, bgcolor = colBg, text_size = size.small)
        table.cell(tbl, 1, 0, "Bars",      text_color = colHead, bgcolor = colBg, text_size = size.small)
        table.cell(tbl, 2, 0, "Avg move",  text_color = colHead, bgcolor = colBg, text_size = size.small, tooltip = "Mean open to close, % of open")
        table.cell(tbl, 3, 0, "t",         text_color = colHead, bgcolor = colBg, text_size = size.small, tooltip = "Avg move / standard error. |t| < 2: indistinguishable from zero on this sample")
        table.cell(tbl, 4, 0, "Avg range", text_color = colHead, bgcolor = colBg, text_size = size.small, tooltip = "Mean high to low, % of open")
        table.cell(tbl, 5, 0, "Up %",      text_color = colHead, bgcolor = colBg, text_size = size.small, tooltip = "Share of bars that closed above their open")

        // hour with the largest average range, highlighted
        int   bestH   = -1
        float bestRng = 0.0
        for h = firstHour to lastHour
            n = array.get(count, h)
            if n > 0
                r = array.get(sumRng, h) / n
                if r > bestRng
                    bestRng := r
                    bestH   := h

        row = 1
        for h = firstHour to lastHour
            n  = array.get(count, h)
            hl = h == bestH ? color.new(#6C2CC9, 70) : colBg
            table.cell(tbl, 0, row, str.tostring(h, "00") + ":00", text_color = n > 0 ? colText : colHead, bgcolor = hl, text_size = size.small)
            if n > 1
                avgMove = array.get(sumMove, h) / n
                varMove = (array.get(sumSq, h) - n * avgMove * avgMove) / (n - 1)
                se      = math.sqrt(math.max(varMove, 0.0) / n)
                tStat   = se > 0 ? avgMove / se : 0.0
                avgRng  = array.get(sumRng, h) / n
                upPct   = 100.0 * array.get(upCount, h) / n
                strong  = math.abs(tStat) >= 2
                table.cell(tbl, 1, row, str.tostring(n), text_color = colText, bgcolor = hl, text_size = size.small)
                table.cell(tbl, 2, row, (avgMove >= 0 ? "+" : "") + str.tostring(avgMove, "#.###") + "%", text_color = strong ? (avgMove >= 0 ? colUp : colDn) : colHead, bgcolor = hl, text_size = size.small)
                table.cell(tbl, 3, row, str.tostring(tStat, "#.#"), text_color = strong ? colText : colHead, bgcolor = hl, text_size = size.small)
                table.cell(tbl, 4, row, str.tostring(avgRng, "#.##") + "%", text_color = colText, bgcolor = hl, text_size = size.small)
                table.cell(tbl, 5, row, str.tostring(upPct, "#.#") + "%", text_color = colText, bgcolor = hl, text_size = size.small)
            else
                for c = 1 to 5
                    table.cell(tbl, c, row, "-", text_color = colHead, bgcolor = hl, text_size = size.small)
            row += 1

        table.cell(tbl, 0, row, "Loaded bars only. Dimmed = |t| < 2. Not a signal.", text_color = colHead, bgcolor = colBg, text_size = size.tiny)
        table.merge_cells(tbl, 0, row, 5, row)
````
