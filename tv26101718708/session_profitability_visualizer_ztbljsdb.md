# Session Profitability Visualizer

- url: https://www.tradingview.com/script/ZtbLJsdB-Session-Profitability-Visualizer/
- type: indicator
- pine_id: PUB;af820f3e77c24b1dbf701a52421edeea
- version: 1.0

## Description

[b]What it shows[/b]

Session Profitability Visualizer breaks the trading day into its 24 hours and shows, for each hour, how price has historically behaved on your chart. It answers a simple statistical question: "When this market trades at 09:00 vs. 14:00 vs. 20:00, how have bars in that hour tended to move?"

For every hour with enough data it displays a table with:

- Hour — the hour-of-day bucket (00:00–23:00) in the symbol's exchange timezone
- Cum move — the cumulative close-minus-open of all completed bars in that hour (in points, or in % if you select the percent metric)
- Bars — how many completed bars contributed to that bucket (the sample size)
- % Pos — the share of those bars that closed above their open

Rows are tinted green or red by the sign of the cumulative move, with color intensity scaled by magnitude relative to the strongest hour, so the "heavier" hours stand out at a glance. An optional (off by default) background shading tints the chart by the historical statistics of the hour the current bar belongs to.

[b]How it works[/b]

On every completed intraday bar inside the lookback window, the script:

1. Determines the bar's hour of day using the symbol's exchange timezone (syminfo.timezone).
2. Computes the bar's move — either close − open in points, or (close − open) / open × 100 in percent, depending on the Metric input.
3. Adds that move to the hour's running sum, increments the hour's bar count, and increments a positive-bar counter when the move is positive.

The per-hour sums, counts, and positive counts are held in three 24-element arrays. The table is rendered once on the last bar from those arrays. There is no request.security() call, no reference to future data, and only confirmed bars are counted — the statistics do not repaint on historical data (the live, still-forming bar is excluded until it closes).
[b]
Inputs[/b]

- Lookback (bars) — how many recent bars feed the statistics (default 5000). Larger windows are more stable; smaller windows react faster to regime changes.
- Metric — Points (close − open) or Percent (bar return %). Percent is more comparable across price levels and long histories.
- Min samples per hour — hours with fewer completed bars than this are hidden (default 30), so thin buckets don't masquerade as meaningful.
- Table position — where the table sits on the chart.
- Shade background — optional tint of the current bar's hour by its historical stats (off by default).

[b]How to use it[/b]

Apply it to any intraday chart (15m or 1h are good starting points — on a 15m chart each hour bucket gets four bars per session). Look for hours where the cumulative move and the % positive rate agree and the sample count is healthy; those are the hours where the market has shown a persistent directional lean on your symbol. Compare the same symbol on different lookbacks to see whether the pattern is stable or an artifact of one period.

[b]Limitations — please read[/b]

- Hour buckets use the symbol's exchange timezone, not your chart's display timezone. A "09:00" row on NASDAQ symbols means 09:00 America/New_York regardless of your local clock.
- Bar close-minus-open is a directional proxy, not trade P&L. It ignores spreads, slippage, position sizing, and intrabar path.
- The statistics are a historical observation, not a prediction. An hour that has drifted up for 5000 bars can stop doing so at any time; sample sizes shrink quickly on higher intraday timeframes.
- The script is intraday-only by design; on daily and above it shows an explanatory message instead of statistics.

This is a statistical visualization tool. It does not generate signals or recommendations of any kind.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
//
// Session Profitability Visualizer
// A statistical visualization of how price has historically moved during each
// hour of the trading day. This is a descriptive study of past bar behavior —
// it produces no signals and makes no recommendations of any kind.

//@version=6
indicator("Session Profitability Visualizer", shorttitle = "Hour Stats", overlay = true)

// ─────────────────────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────────────────────
lookbackBars = input.int(5000, "Lookback (bars)", minval = 100, maxval = 20000,
     tooltip = "Only the most recent N bars are included in the hourly statistics.")
metricChoice = input.string("Points (close - open)", "Metric",
     options = ["Points (close - open)", "Percent (bar return %)"],
     tooltip = "Points: raw close-minus-open per bar. Percent: (close - open) / open * 100.")
minSamples   = input.int(30, "Min samples per hour", minval = 1,
     tooltip = "Hours with fewer completed bars than this are hidden from the table.")
tablePosStr  = input.string("Top right", "Table position",
     options = ["Top right", "Top left", "Bottom right", "Bottom left", "Middle right", "Middle left"])
shadeBg      = input.bool(false, "Shade background by current hour's history",
     tooltip = "Tints the chart background green/red based on the historical cumulative move of the hour the current bar belongs to. Off by default.")

usePercent = metricChoice == "Percent (bar return %)"

// Map the position input to a table position constant (resolved once, simple string)
tablePos = tablePosStr == "Top right"     ? position.top_right    :
           tablePosStr == "Top left"      ? position.top_left     :
           tablePosStr == "Bottom right"  ? position.bottom_right :
           tablePosStr == "Bottom left"   ? position.bottom_left  :
           tablePosStr == "Middle right"  ? position.middle_right :
           position.middle_left

// ─────────────────────────────────────────────────────────────────────────────
// Per-hour accumulators (index 0..23 = hour of day in the symbol's timezone)
// ─────────────────────────────────────────────────────────────────────────────
var float[] sumMove = array.new_float(24, 0.0)  // cumulative move per hour
var int[]   cntBars = array.new_int(24, 0)      // completed-bar count per hour
var int[]   cntPos  = array.new_int(24, 0)      // count of positive bars per hour

// Accumulate only completed bars inside the lookback window.
// No request.security(), no future references — everything uses the bar's own
// confirmed open/close, so there is no lookahead.
inWindow = bar_index >= last_bar_index - lookbackBars

if timeframe.isintraday and barstate.isconfirmed and inWindow and open != 0
    int   h  = hour(time, syminfo.timezone)
    float mv = usePercent ? (close - open) / open * 100.0 : close - open
    array.set(sumMove, h, array.get(sumMove, h) + mv)
    array.set(cntBars, h, array.get(cntBars, h) + 1)
    if mv > 0
        array.set(cntPos, h, array.get(cntPos, h) + 1)

// Largest absolute cumulative move among displayable hours (for color intensity)
float maxAbs = 0.0
for h = 0 to 23
    if array.get(cntBars, h) >= minSamples
        maxAbs := math.max(maxAbs, math.abs(array.get(sumMove, h)))

// ─────────────────────────────────────────────────────────────────────────────
// Optional background shading of the current bar's hour
// ─────────────────────────────────────────────────────────────────────────────
int   curHour = timeframe.isintraday ? hour(time, syminfo.timezone) : 0
float curSum  = array.get(sumMove, curHour)
int   curCnt  = array.get(cntBars, curHour)

float bgIntensity = maxAbs > 0.0 ? math.abs(curSum) / maxAbs : 0.0
int   bgTransp    = int(math.round(97.0 - 12.0 * bgIntensity))  // 85 (strong) .. 97 (faint)

color bgTint = shadeBg and timeframe.isintraday and curCnt >= minSamples ?
     (curSum > 0 ? color.new(color.green, bgTransp) :
      curSum < 0 ? color.new(color.red,   bgTransp) : na) : na

bgcolor(bgTint)

// ─────────────────────────────────────────────────────────────────────────────
// Statistics table (header + up to 24 hour rows + fallback message row)
// ─────────────────────────────────────────────────────────────────────────────
color HEADER_BG  = color.new(#0f172a, 0)
color HEADER_TXT = color.new(#e2e8f0, 0)
// White text reads on both dark and light chart themes (cells carry a
// green/red tint that darkens with the chart behind it when transparent)
color CELL_TXT   = color.new(color.white, 0)

var table tbl = table.new(tablePos, 4, 26,
     frame_color  = color.new(#0f172a, 40), frame_width  = 1,
     border_color = color.new(color.gray, 75), border_width = 1)

if barstate.islast
    table.clear(tbl, 0, 0, 3, 25)

    if not timeframe.isintraday
        table.cell(tbl, 0, 0,
             "Session Profitability Visualizer\nworks on intraday timeframes only.\nSwitch to an intraday chart (e.g. 15m or 1h).",
             text_color = HEADER_TXT, bgcolor = HEADER_BG, text_size = size.small)
    else
        // Header row
        table.cell(tbl, 0, 0, "Hour",  text_color = HEADER_TXT, bgcolor = HEADER_BG, text_size = size.small)
        table.cell(tbl, 1, 0, usePercent ? "Cum %" : "Cum move", text_color = HEADER_TXT, bgcolor = HEADER_BG, text_size = size.small)
        table.cell(tbl, 2, 0, "Bars",  text_color = HEADER_TXT, bgcolor = HEADER_BG, text_size = size.small)
        table.cell(tbl, 3, 0, "% Pos", text_color = HEADER_TXT, bgcolor = HEADER_BG, text_size = size.small)

        int row = 1
        for h = 0 to 23
            int n = array.get(cntBars, h)
            if n >= minSamples
                float s      = array.get(sumMove, h)
                float pctPos = 100.0 * array.get(cntPos, h) / n

                // Row color: fully OPAQUE cells (transparency over a dark chart
                // collapses to near-black). Intensity is encoded as a gradient
                // from a muted tone to TradingView's bright green/red.
                float intensity = maxAbs > 0.0 ? math.abs(s) / maxAbs : 0.0
                color rowColor  = s > 0 ? color.from_gradient(intensity, 0.0, 1.0, #1b5e50, #089981) :
                                  s < 0 ? color.from_gradient(intensity, 0.0, 1.0, #6e2a33, #f23645) :
                                          color.new(#434651, 0)

                string hrLabel = str.tostring(h, "00") + ":00"
                string moveTxt = usePercent ? str.tostring(s, "#.##") + "%" : str.tostring(s, "#.####")

                table.cell(tbl, 0, row, hrLabel, text_color = CELL_TXT, bgcolor = rowColor, text_size = size.small)
                table.cell(tbl, 1, row, moveTxt, text_color = CELL_TXT, bgcolor = rowColor, text_size = size.small)
                table.cell(tbl, 2, row, str.tostring(n), text_color = CELL_TXT, bgcolor = rowColor, text_size = size.small)
                table.cell(tbl, 3, row, str.tostring(pctPos, "#.#") + "%", text_color = CELL_TXT, bgcolor = rowColor, text_size = size.small)
                row += 1

        if row == 1
            table.cell(tbl, 0, 1,
                 "Not enough data yet.\nLower 'Min samples per hour'\nor load more history.",
                 text_color = HEADER_TXT, bgcolor = HEADER_BG, text_size = size.small)
````
