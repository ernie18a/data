# Golden Cross Timing Analysis

- url: https://www.tradingview.com/script/XKxQo1vp-Golden-Cross-Timing-Analysis/
- type: indicator
- pine_id: PUB;dca9d02ee171434c9cdcbd73770df0c9
- version: 1.0

## Description

This [b]Golden Cross Timing Analysis[/b] indicator goes beyond identifying SMA crossovers by examining their timing in relation to price movement. Alongside tracking performance after the latest Golden Cross, it measures how much the price had already changed before the signal appeared.

The indicator brings these measurements together with the subsequent price high and current moving-average alignment, allowing traders to study the crossover in context rather than as an isolated event.

[b]How it works?[/b]

The indicator uses two simple moving averages (50 and 200 periods by default) to identify confirmed Golden Cross and Death Cross events.

It highlights:

[list]
[*]Golden Cross: The faster SMA crosses above the slower SMA.
[*]Death Cross: The faster SMA crosses below the slower SMA.
[*]Pre-cross performance: Price change over a configurable period before the latest Golden Cross (30 bars by default).
[*]Since Golden Cross: Price change from the latest crossover's closing price to the current price.
[*]Post-GC High: The highest intraday price recorded on confirmed bars after the latest Golden Cross, measured relative to the crossover's closing price.
[*]Current trend status: The relationship between price, the faster SMA, and the slower SMA.
[/list]

A compact summary table and chart annotations make it easier to see the pre-cross movement alongside the subsequent price change and historical high. The performance calculations focus on the most recent Golden Cross, while historical crossover markers remain visible on the chart.

[b]How to use it?[/b]

Apply the indicator to any supported asset. For the traditional 50-day/200-day Golden Cross, use the 1D timeframe.

Moving average lengths, the pre-cross observation period, and individual visual elements can be adjusted in the settings.

The indicator is not tied to any particular cryptocurrency, price level, or historical date.

[b]Limitations[/b]

The post-cross high is calculated retrospectively and does not represent a return traders could have predicted or necessarily captured. As Golden Cross is a lagging signal, historical results should not be treated as forecasts of future price movements.

[i]This indicator is intended for technical analysis and educational purposes, not automated trading or backtesting. It does not constitute financial advice and should be tested before use in live trading.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
 // © Crypto_Andy_

 //@version=6
 // Golden Cross Timing Analysis
 // Historical technical analysis of moving average crossovers.
 // Works with different assets and chart timeframes.
 // No automated trading orders or price forecasts.

indicator("Golden Cross Timing Analysis", shorttitle="GC Timing", overlay=true, max_labels_count=100, max_lines_count=10)

// INPUTS
string groupMA = "Moving Averages"
int fastLen = input.int(50, "Fast SMA", minval=2, group=groupMA)
int slowLen = input.int(200, "Slow SMA", minval=3, group=groupMA)

string groupStudy = "Research"
int lookback = input.int(30, "Pre-cross period (bars)", minval=1, maxval=500, group=groupStudy)

string groupVisual = "Appearance"
bool showMA = input.bool(true, "Show SMA lines", group=groupVisual)
bool showCrosses = input.bool(true, "Show cross labels", group=groupVisual)
bool showPeak = input.bool(true, "Show post-GC peak", group=groupVisual)
bool showGuide = input.bool(true, "Show GC reference line", group=groupVisual)
bool showPanel = input.bool(true, "Show summary panel", group=groupVisual)

// MOVING AVERAGES
float fast = ta.sma(close, fastLen)
float slow = ta.sma(close, slowLen)

plot(showMA ? fast : na, "Fast SMA", color=color.teal, linewidth=2)
plot(showMA ? slow : na, "Slow SMA", color=color.purple, linewidth=2)

bool gc = ta.crossover(fast, slow) and barstate.isconfirmed
bool dc = ta.crossunder(fast, slow) and barstate.isconfirmed

float crossLevel = (fast + slow) / 2.0

// FORMATTING
fmtPct(float value) =>
    na(value) ? "N/A" : (value > 0 ? "+" : "") + str.tostring(value, "#.##") + "%"

fmtPrice(float value) =>
    na(value) ? "N/A" : str.tostring(value, format.mintick)

// HISTORICAL VARIABLES
var int gcCount = 0
var int dcCount = 0

var int lastGcBar = na
var float lastGcPrice = na
var float preChange = na

var float peakPrice = na
var int peakBar = na

var line guideLine = na
var label guideLabel = na
var label peakLabel = na

var array<label> crossLabels = array.new<label>()

// GOLDEN CROSS
if gc
    gcCount += 1
    lastGcBar := bar_index
    lastGcPrice := close

    preChange := not na(close[lookback]) and close[lookback] > 0 ? 100.0 * (close / close[lookback] - 1.0) : na

    peakPrice := close
    peakBar := bar_index

    if showCrosses
        label mark = label.new(
             bar_index, crossLevel,
             "✦\nGOLDEN CROSS",
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_up,
             color=color.new(color.teal, 5),
             textcolor=color.white,
             size=size.small,
             tooltip="Confirmed SMA crossover. Close: " + fmtPrice(close))
        array.push(crossLabels, mark)

// DEATH CROSS
if dc
    dcCount += 1

    if showCrosses
        label mark = label.new(
             bar_index, crossLevel,
             "✕\nDEATH CROSS",
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_down,
             color=color.new(color.red, 5),
             textcolor=color.white,
             size=size.small,
             tooltip="Confirmed SMA crossunder. Close: " + fmtPrice(close))
        array.push(crossLabels, mark)

// LIMIT HISTORICAL LABELS
if array.size(crossLabels) > 35
    label.delete(array.shift(crossLabels))

// POST-GOLDEN CROSS HIGH
if barstate.isconfirmed and not na(lastGcBar) and bar_index > lastGcBar
    if na(peakPrice) or high > peakPrice
        peakPrice := high
        peakBar := bar_index

// DRAW LATEST EVENT
if barstate.islast
    if not na(guideLine)
        line.delete(guideLine)
        guideLine := na

    if not na(guideLabel)
        label.delete(guideLabel)
        guideLabel := na

    if not na(peakLabel)
        label.delete(peakLabel)
        peakLabel := na

    if not na(lastGcBar) and lastGcPrice > 0
        float sinceGc = 100.0 * (close / lastGcPrice - 1.0)
        float peakGain = 100.0 * (peakPrice / lastGcPrice - 1.0)

        if showGuide
            guideLine := line.new(
                 lastGcBar, lastGcPrice,
                 bar_index, lastGcPrice,
                 xloc=xloc.bar_index,
                 extend=extend.none,
                 color=color.new(color.teal, 40),
                 style=line.style_dashed,
                 width=1)

            guideLabel := label.new(
                 bar_index, lastGcPrice,
                 "SINCE GC  " + fmtPct(sinceGc),
                 style=label.style_label_left,
                 color=sinceGc >= 0 ? color.teal : color.red,
                 textcolor=color.white,
                 size=size.small)

        if showPeak and not na(peakBar)
            peakLabel := label.new(
                 peakBar, peakPrice,
                 "POST-GC HIGH\n" + fmtPct(peakGain),
                 xloc=xloc.bar_index,
                 yloc=yloc.price,
                 style=label.style_label_down,
                 color=color.new(color.teal, 15),
                 textcolor=color.white,
                 size=size.small,
                 tooltip="Highest confirmed high observed after the latest Golden Cross. This result was not known at the crossover.")

// CURRENT TREND STATUS
string trendState = na(fast) or na(slow) ? "Not enough history" :
     fast <= slow ? "Bearish MA alignment" :
     close < fast ? "Below SMA50 / GC intact" :
     "Above SMA50 / GC intact"

// SUMMARY TABLE
var table panel = table.new(
     position.bottom_left, 2, 7,
     bgcolor=color.new(color.black, 12),
     frame_color=color.new(color.gray, 65),
     frame_width=1)

makeRow(int row, string key, string value, color valueColor) =>
    table.cell(panel, 0, row, key,
         text_color=color.white,
         text_size=size.small,
         text_halign=text.align_left)
    table.cell(panel, 1, row, value,
         text_color=valueColor,
         text_size=size.small,
         text_halign=text.align_right)

if barstate.islast
    if showPanel
        float currentGain = not na(lastGcPrice) and lastGcPrice > 0 ? 100.0 * (close / lastGcPrice - 1.0) : na
        float bestGain = not na(lastGcPrice) and lastGcPrice > 0 ? 100.0 * (peakPrice / lastGcPrice - 1.0) : na

        makeRow(0, "GOLDEN CROSS STUDY", syminfo.ticker, color.aqua)
        makeRow(1, "GC / DC events", str.tostring(gcCount) + " / " + str.tostring(dcCount), color.white)
        makeRow(2, "Last GC close", fmtPrice(lastGcPrice), color.white)
        makeRow(3, "Pre-" + str.tostring(lookback) + " bars", fmtPct(preChange), color.orange)
        makeRow(4, "Since GC", fmtPct(currentGain), currentGain >= 0 ? color.teal : color.red)
        makeRow(5, "Post-GC high", fmtPct(bestGain), color.teal)
        makeRow(6, "Current status", trendState, color.orange)
    else
        table.clear(panel, 0, 0, 1, 6)

// ALERTS
alertcondition(gc, "Golden Cross", "{{ticker}}: confirmed Golden Cross on {{interval}}")
alertcondition(dc, "Death Cross", "{{ticker}}: confirmed Death Cross on {{interval}}")
````
