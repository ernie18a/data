<!-- tradingview-pine-id: PUB;139825e3a36f4b859eba646d6ac3922d -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# Trend Template Radar (Free)

Source: https://www.tradingview.com/script/IlPWFfCB/

## Description

What it does

This indicator checks a stock against 7 classic momentum/trend criteria, popularized by Mark Minervini's Trend Template and shared by the CANSLIM methodology. Each criterion is either passed or failed, and the total score (0–7) tells you at a glance whether a stock is in Stage 2 (healthy uptrend) territory.

The 7 criteria

1. Price above both the 150-day and 200-day moving average
2. 150-day MA above the 200-day MA
3. 200-day MA trending up for at least a month
4. 50-day MA above both the 150-day and 200-day MA
5. Price above the 50-day MA
6. Price at least 30% above its 52-week low
7. Price within 25% of its 52-week high

How to use it

On the chart: a color-coded table shows the live score and which criteria pass/fail — green (7/7), yellow (4–6), red (below 4).
In the Pine Screener: every criterion is published as a separate series, so you can filter an entire watchlist down to only the stocks that pass all 7 conditions.
Alerts are included for when a stock reaches a full 7/7 score.

Settings

MA lengths, MA type (SMA/EMA), and 52-week range thresholds are all configurable.

Disclaimer

This script is for educational and informational purposes only. It is not, and should not be construed as, investment advice or a recommendation to buy or sell any security. Past performance and technical patterns do not guarantee future results. Always do your own research and consult a licensed financial advisor before making investment decisions.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © momentum-edge

//@version=6
indicator("Trend Template Radar (Free)", overlay = true, max_labels_count = 500)

// ─────────────────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────────────────
grp_ma       = "Moving Averages"
grp_hilo     = "52-Week Range"
grp_display  = "Display"

len50  = input.int(50,  "Short MA length",  group = grp_ma)
len150 = input.int(150, "Medium MA length", group = grp_ma)
len200 = input.int(200, "Long MA length",   group = grp_ma)
maType = input.string("SMA", "MA type", options = ["SMA", "EMA"], group = grp_ma)
uptrendLookback = input.int(21, "MA200 uptrend lookback (bars, ~1 month)", group = grp_ma)

hiLoLookbackWeeks = input.int(52, "52-week range lookback (weeks)", group = grp_hilo)
minAboveLowPct    = input.float(30, "Min % above 52w low", group = grp_hilo)
maxBelowHighPct   = input.float(25, "Max % below 52w high", group = grp_hilo)

showTable   = input.bool(true, "Show score table", group = grp_display)
tablePos    = input.string("bottom_right", "Table position",
     options = ["top_left", "top_right", "bottom_left", "bottom_right"], group = grp_display)
headerTextColor = input.color(color.white, "Header text color", group = grp_display)
passTextColor   = input.color(color.new(color.green, 0), "Pass (✓) text color", group = grp_display)
failTextColor   = input.color(color.new(color.red, 0), "Fail (✗) text color", group = grp_display)
labelTextColor  = input.color(color.new(color.gray, 0), "Criterion label text color", group = grp_display)

// ─────────────────────────────────────────────────────────────────────────
// Moving averages
// ─────────────────────────────────────────────────────────────────────────
ma(src, len) => maType == "SMA" ? ta.sma(src, len) : ta.ema(src, len)

ma50  = ma(close, len50)
ma150 = ma(close, len150)
ma200 = ma(close, len200)

// ─────────────────────────────────────────────────────────────────────────
// 52-week high / low
// ─────────────────────────────────────────────────────────────────────────
barsInWeek  = timeframe.isdaily ? 5 : (timeframe.isweekly ? 1 : 5)
hiLoBars    = hiLoLookbackWeeks * barsInWeek

high52  = ta.highest(high, hiLoBars)
low52   = ta.lowest(low, hiLoBars)

// ─────────────────────────────────────────────────────────────────────────
// Trend Template criteria (1 = pass, 0 = fail)
// No request.security() calls on purpose — keeps this script Pine Screener
// compatible (the screener does not support multi-symbol data requests).
// ─────────────────────────────────────────────────────────────────────────
c1 = close > ma150 and close > ma200
c2 = ma150 > ma200
c3 = ma200 > ma200[uptrendLookback]
c4 = ma50 > ma150 and ma50 > ma200
c5 = close > ma50
c6 = close >= low52 * (1 + minAboveLowPct / 100)
c7 = close >= high52 * (1 - maxBelowHighPct / 100)

score = (c1 ? 1 : 0) + (c2 ? 1 : 0) + (c3 ? 1 : 0) + (c4 ? 1 : 0) +
         (c5 ? 1 : 0) + (c6 ? 1 : 0) + (c7 ? 1 : 0)

scoreColor = score == 7 ? color.new(color.green, 0) :
             score >= 4 ? color.new(color.yellow, 0) :
             color.new(color.red, 0)

// ─────────────────────────────────────────────────────────────────────────
// Plots (feed the Pine Screener)
// ─────────────────────────────────────────────────────────────────────────
plot(score, "Trend Template Score", color = scoreColor, linewidth = 2, display = display.data_window)
plot(c1 ? 1 : 0, "C1: Price > MA150 & MA200", display = display.data_window)
plot(c2 ? 1 : 0, "C2: MA150 > MA200", display = display.data_window)
plot(c3 ? 1 : 0, "C3: MA200 trending up", display = display.data_window)
plot(c4 ? 1 : 0, "C4: MA50 > MA150 & MA200", display = display.data_window)
plot(c5 ? 1 : 0, "C5: Price > MA50", display = display.data_window)
plot(c6 ? 1 : 0, "C6: 30%+ above 52w low", display = display.data_window)
plot(c7 ? 1 : 0, "C7: Within 25% of 52w high", display = display.data_window)

plot(ma50,  "MA50",  color = color.new(color.blue, 40))
plot(ma150, "MA150", color = color.new(color.orange, 40))
plot(ma200, "MA200", color = color.new(color.red, 40))

// ─────────────────────────────────────────────────────────────────────────
// Alerts
// ─────────────────────────────────────────────────────────────────────────
alertcondition(score == 7, "Full Trend Template pass (7/7)",
     "{{ticker}} now passes all 7 Trend Template criteria.")
alertcondition(score == 7 and score[1] < 7, "New Trend Template pass",
     "{{ticker}} just turned into a full 7/7 Trend Template match.")

// ─────────────────────────────────────────────────────────────────────────
// Score table
// ─────────────────────────────────────────────────────────────────────────
var table scoreTable = table.new(
     tablePos == "top_left" ? position.top_left :
     tablePos == "top_right" ? position.top_right :
     tablePos == "bottom_left" ? position.bottom_left : position.bottom_right,
     2, 9, border_width = 1)

labelText(ok) => ok ? "✓" : "✗"
labelColor(ok) => ok ? passTextColor : failTextColor

if barstate.islast and showTable
    table.cell(scoreTable, 0, 0, "Trend Template Radar", bgcolor = color.new(color.black, 0), text_color = headerTextColor, text_size = size.small)
    table.cell(scoreTable, 1, 0, "Free Scanner", bgcolor = color.new(color.black, 0), text_color = headerTextColor, text_size = size.small)

    table.cell(scoreTable, 0, 1, "Score", bgcolor = scoreColor, text_color = headerTextColor, text_size = size.small)
    table.cell(scoreTable, 1, 1, str.tostring(score) + "/7", bgcolor = scoreColor, text_color = headerTextColor, text_size = size.small)

    table.cell(scoreTable, 0, 2, "Price > MA150/200", text_color = labelTextColor, text_size = size.small)
    table.cell(scoreTable, 1, 2, labelText(c1), text_color = labelColor(c1), text_size = size.small)

    table.cell(scoreTable, 0, 3, "MA150 > MA200", text_color = labelTextColor, text_size = size.small)
    table.cell(scoreTable, 1, 3, labelText(c2), text_color = labelColor(c2), text_size = size.small)

    table.cell(scoreTable, 0, 4, "MA200 uptrend", text_color = labelTextColor, text_size = size.small)
    table.cell(scoreTable, 1, 4, labelText(c3), text_color = labelColor(c3), text_size = size.small)

    table.cell(scoreTable, 0, 5, "MA50 > MA150/200", text_color = labelTextColor, text_size = size.small)
    table.cell(scoreTable, 1, 5, labelText(c4), text_color = labelColor(c4), text_size = size.small)

    table.cell(scoreTable, 0, 6, "Price > MA50", text_color = labelTextColor, text_size = size.small)
    table.cell(scoreTable, 1, 6, labelText(c5), text_color = labelColor(c5), text_size = size.small)

    table.cell(scoreTable, 0, 7, "30%+ above 52w low", text_color = labelTextColor, text_size = size.small)
    table.cell(scoreTable, 1, 7, labelText(c6), text_color = labelColor(c6), text_size = size.small)

    table.cell(scoreTable, 0, 8, "Within 25% of 52w high", text_color = labelTextColor, text_size = size.small)
    table.cell(scoreTable, 1, 8, labelText(c7), text_color = labelColor(c7), text_size = size.small)
````
