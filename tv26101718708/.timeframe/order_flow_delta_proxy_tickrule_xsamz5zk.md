# Order Flow Delta Proxy (Tick-Rule)

- url: https://www.tradingview.com/script/XsAmZ5zk-Order-Flow-Delta-Proxy-Tick-Rule/
- type: indicator
- pine_id: PUB;36247f606d8c4fc4beebea5907b140fe
- version: 1.0

## Description

This indicator approximates buy-side versus sell-side trading pressure, commonly referred to as order flow delta or cumulative volume delta, using a tick-rule method applied to lower-timeframe price data. True bid and ask tick data is not available for most index and cash market symbols on this platform, so this script provides a volume-based directional approximation instead.

How it works:
For each bar on the chart, the script pulls a configurable lower-timeframe series of closes and volumes using request.security_lower_tf(). Each lower-timeframe close is compared to the prior lower-timeframe close: if price ticked up, that portion of volume is classified as buy-side; if price ticked down, it is classified as sell-side; unchanged ticks are split evenly, following standard tick-rule convention. These classified volumes are summed per chart bar to produce a per-bar delta value, plotted as a histogram, alongside a running cumulative delta line. If lower-timeframe data is unavailable, the script falls back to a close-position-within-range volume split as an approximation.

Notes and limitations:
This is a volume-based directional proxy, not real bid or ask order flow data. The currently forming bar's values can update intrabar as new lower-timeframe data arrives, which is expected behavior for any real-time order-flow style tool; once a bar closes, its value is fixed. This script does not generate trade signals and does not guarantee profitability. It is intended as a supplementary analytical tool and should be used alongside sound risk management. Past patterns in delta do not guarantee future price behavior.

## Source Code

````pine
//@version=6
indicator("Order Flow Delta Proxy (Tick-Rule)", overlay=false)

// ============================================================
// INPUTS
// ============================================================
grpCore = "Tick-Rule Settings"
lowerTF = input.timeframe("1", "Lower Timeframe for Tick Approximation", group=grpCore, tooltip="Smaller timeframe used to approximate up-tick/down-tick volume within each chart bar. '1' (1 minute) works for most intraday charts. True tick data isn't available on index/cash data, so this is a volume-weighted directional proxy.")

grpVis = "Visuals"
showCumulative = input.bool(true, "Show Cumulative Delta Line", group=grpVis)
showDeltaHist  = input.bool(true, "Show Per-Bar Delta Histogram", group=grpVis)
buyColor  = input.color(color.new(color.teal, 0), "Buy Pressure Color", group=grpVis)
sellColor = input.color(color.new(color.red, 0), "Sell Pressure Color", group=grpVis)
cumColor  = input.color(color.new(color.yellow, 0), "Cumulative Delta Color", group=grpVis)

// ============================================================
// PULL LOWER-TIMEFRAME CLOSE + VOLUME (non-repainting on closed bars;
// the currently forming bar updates intrabar as expected for order-flow tools)
// ============================================================
[ltfClose, ltfVolume] = request.security_lower_tf(syminfo.tickerid, lowerTF, [close, volume])

var float lastTickClose = na

buyVol  = 0.0
sellVol = 0.0

if array.size(ltfClose) > 0
    for i = 0 to array.size(ltfClose) - 1
        c = array.get(ltfClose, i)
        v = array.get(ltfVolume, i)
        if na(lastTickClose)
            buyVol  += v / 2
            sellVol += v / 2
        else if c > lastTickClose
            buyVol  += v
        else if c < lastTickClose
            sellVol += v
        else
            buyVol  += v / 2
            sellVol += v / 2
        lastTickClose := c
else
    // fallback if no lower-tf data returned (e.g. chart already at minimum resolution):
    // approximate using close position within the bar's range
    range_ = high - low
    if range_ > 0
        buyVol  := volume * (close - low) / range_
        sellVol := volume * (high - close) / range_
    else
        buyVol  := volume / 2
        sellVol := volume / 2

delta = buyVol - sellVol

var float cumDelta = 0.0
cumDelta := cumDelta + delta

// ============================================================
// PLOTS
// ============================================================
plot(showDeltaHist ? delta : na, title="Bar Delta", style=plot.style_columns, color=delta >= 0 ? buyColor : sellColor)
plot(showCumulative ? cumDelta : na, title="Cumulative Delta", color=cumColor, linewidth=2)
hline(0, "Zero Line", color=color.new(color.gray, 50))

// ============================================================
// DASHBOARD
// ============================================================
var table dash = table.new(position.top_right, 2, 4, bgcolor=color.new(color.black, 80), border_width=1)

if barstate.islast
    totalVol = buyVol + sellVol
    buyPct = totalVol > 0 ? (buyVol / totalVol) * 100 : 50
    table.cell(dash, 0, 0, "Bar Delta", text_color=color.white, bgcolor=color.new(color.gray, 60))
    table.cell(dash, 1, 0, str.tostring(delta, format.volume), text_color=delta >= 0 ? buyColor : sellColor, bgcolor=color.new(color.gray, 60))
    table.cell(dash, 0, 1, "Cumulative", text_color=color.white)
    table.cell(dash, 1, 1, str.tostring(cumDelta, format.volume), text_color=cumColor)
    table.cell(dash, 0, 2, "Buy %", text_color=color.white)
    table.cell(dash, 1, 2, str.tostring(buyPct, "#.#") + "%", text_color=buyColor)
    table.cell(dash, 0, 3, "Lower TF", text_color=color.white)
    table.cell(dash, 1, 3, lowerTF, text_color=color.white)
````
