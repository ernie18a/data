# Intraday RVOL Overlay: Time-of-Day Relative Volume

- url: https://www.tradingview.com/script/fCgl6lLO-Intraday-RVOL-Overlay-Time-of-Day-Relative-Volume/
- type: indicator
- pine_id: PUB;2ce9eaab08a7403eafa2ec1cf4a4022f
- version: 1.0

## Description

https://www.tradingview.com/x/w5dPcMAD/
## Intraday RVOL Overlay — Time-of-Day Relative Volume

This indicator plots intraday relative volume directly on the price chart.

It is designed to answer a specific question:

[b]Is today’s volume running above or below normal for this exact point in the trading session?[/b]

A standard volume moving average compares recent candles with other recent candles. That can be useful, but it does not account for the natural shape of intraday volume. Volume is usually heavier near the market open, often quieter around midday, and may increase again near the close.

This script takes a different approach. It compares today’s cumulative intraday volume with the average cumulative volume at the same time of day over previous trading sessions.

For example, if the chart is at 14:45, the script compares:

[list]
[*]
[/list] today’s cumulative volume from the start of the session up to 14:45

with

[list]
[*]
[/list] the average cumulative volume from the start of the session up to 14:45 over the selected lookback period

The result is shown as an RVOL multiple.

[b]How RVOL is calculated[/b]

The script calculates:

RVOL = today’s cumulative intraday volume so far / average cumulative intraday volume by the same time of day

Example:

Today cumulative volume: 4.05M
Average cumulative volume by this time: 6.30M

RVOL = 4.05M / 6.30M = 0.64x

This means the symbol is trading at around 64% of its normal cumulative volume for that point in the session.

[b]
What makes this script different[/b]

This is not a basic volume moving average and it is not a standard RSI or moving-average crossover setup.

The original purpose of this script is to provide a time-of-day adjusted intraday volume comparison while keeping the information visible on the main price chart.

The script combines three ideas:

1. Cumulative intraday volume tracking
2. Historical same-time-of-day volume comparison
3. Price-chart overlay scaling

Instead of asking whether the current candle has high volume compared with the last few candles, it asks whether today’s total traded volume so far is high or low compared with what is normally expected at this stage of the session.

[b]How to read the lines[/b]

The main RVOL line shows today’s cumulative intraday relative volume.

[list]
[*]
[/list] RVOL below 1.0x = volume is running below normal
[list]
[*]
[/list] RVOL around 1.0x = volume is running around normal
[list]
[*]
[/list] RVOL above 1.5x = volume is meaningfully above average
[list]
[*]
[/list]RVOL above 2.0x = volume is unusually strong

The script also plots reference lines:

[list]
[*]
[/list] 1.0x average volume line
[list]
[*]
[/list] 1.5x high-volume threshold line

If the RVOL line is below the 1.0x line, today’s cumulative volume is below average for this point in the session.

If the RVOL line is above the 1.5x line, today’s cumulative volume is meaningfully above average for this point in the session.

[b]Important note about price scaling[/b]

RVOL is a ratio, not a price.

Because this script is plotted as an overlay on the main price chart, the RVOL values are visually mapped into a small band inside the recent price range.

This means the price-axis values shown beside the RVOL plots are only visual placement values. They are not support levels, resistance levels, targets, or actual price signals.

The overlay is price-scaled only so the RVOL information can be viewed directly alongside price action without requiring a separate indicator pane.

[b]Inputs[/b]

Average over previous trading days
Controls how many prior trading sessions are used to calculate the average cumulative volume baseline.

Price scaling lookback bars
Controls the recent price range used to place the RVOL overlay band on the chart.

RVOL value plotted at top of band
Controls the visual cap for the overlay. For example, with a cap of 3.0, RVOL values of 3.0x or higher are plotted at the top of the visual band.

Overlay band position
Allows the RVOL band to be placed near the top or bottom of the price chart.

Overlay band height
Controls how much vertical space the RVOL overlay uses inside the price chart.

Fallback search minutes
Allows the script to look backwards for nearby historical volume slots when exact same-minute data is missing.

[b]Suggested use[/b]

This indicator is intended for intraday charts.

Recommended chart timeframes:

[list]
[*] 5-minute
[*]15-minute
[*]1-hour
[/list]

Supported chart timeframes:

[list]
[*]
[/list]Intraday charts from 1 minute upward

Not supported:

[list]
[*] Seconds charts
[*] Daily charts
[*] Weekly charts
[*] Monthly charts
[/list]

[b]Practical interpretation[/b]

This script can help give volume context to intraday price movement.

For example:

[list]
[*] A price move with RVOL below 1.0x may be happening on weaker-than-normal participation.
[*] A price move with RVOL above 1.5x may have stronger-than-normal participation.
[*] A breakout attempt with RVOL above 2.0x may be occurring during unusually active trading.
[/list]

This does not mean the move will continue. It only shows whether volume participation is above or below normal for that time of day.

[b]Limitations[/b]

This script works best on liquid symbols with regular intraday trading activity.

Results may be affected by:

[list]
[*] extended-hours data
[*] half trading days
[*] market holidays
[*] trading halts
[*] low-liquidity symbols
[*] missing historical bars
[*] unusual trading sessions
[*] symbols with irregular volume patterns
[/list]

The script does not generate buy or sell signals. It should be used as a volume context tool alongside price action, trend, liquidity, volatility, and risk management.

[b]Disclaimer[/b]

This script is provided for educational and research purposes only. It is not financial advice. It does not predict price direction and should not be used as the sole basis for trading decisions.

## Source Code

````pine
//@version=6

// SPDX-License-Identifier: MIT
// Copyright (c) 2026 BuildsByDT
//
// Intraday RVOL Overlay - Price Scaled
//
// This indicator compares today's cumulative intraday volume with the
// average cumulative volume at the same time of day over a configurable
// lookback period.
//
// RVOL = today's cumulative volume so far / average cumulative volume
// by this same time of day.
//
// The RVOL line is visually scaled into a band on the price chart.
// The plotted price-axis values are not support/resistance levels.
//
// Educational tool only. Not financial advice.


indicator('Intraday RVOL Overlay - Price Scaled', shorttitle = 'RVOL Overlay', overlay = true, scale = scale.none, precision = 2, max_labels_count = 50)

// === Inputs ===
lookbackDays = input.int(20, 'Average over previous trading days', minval = 1, maxval = 60)
priceLookback = input.int(200, 'Price scaling lookback bars', minval = 50, maxval = 1000)
rvolCap = input.float(3.0, 'RVOL value plotted at top of band', minval = 1.0, step = 0.25)
bandPosition = input.string('Bottom', 'Overlay band position', options = ['Bottom', 'Top'])
bandHeightPct = input.float(18.0, 'Overlay band height % of price range', minval = 5.0, maxval = 50.0)
searchBackMins = input.int(30, 'Fallback search minutes for missing bars', minval = 0, maxval = 120)

showOneLine = input.bool(true, 'Show 1.0x average line')
showHighLine = input.bool(true, 'Show 1.5x high volume line')
showLabel = input.bool(true, 'Show live RVOL label')

// === Safety check ===
if not timeframe.isintraday or timeframe.isseconds
    runtime.error('Use this on an intraday chart: 1m, 5m, 15m, 1h, etc. Not seconds or daily.')

// === Time-of-day slot in exchange timezone ===
slotsPerDay = 1440
slot = hour(time, syminfo.timezone) * 60 + minute(time, syminfo.timezone)

// === Store cumulative volume by minute-of-day for each day ===
var float dayCumVol = na
newDay = ta.change(time('D')) != 0

dayCumVol := newDay or na(dayCumVol[1]) ? volume : dayCumVol[1] + volume

var rvolStore = array.new_float(slotsPerDay * (lookbackDays + 1), na)

// Shift stored days forward when a new trading day starts
if newDay
    for i = 0 to slotsPerDay - 1 by 1
        array.shift(rvolStore)
        array.push(rvolStore, na)

// Store today's cumulative volume at the current minute slot
todayOffset = lookbackDays * slotsPerDay
array.set(rvolStore, todayOffset + slot, dayCumVol)

// === Function: get nearest available cumulative volume for prior day/time ===
getPriorCumVol(dayIndex, targetSlot, searchBack) =>
    float result = na
    base = dayIndex * slotsPerDay
    for back = 0 to searchBack by 1
        testSlot = targetSlot - back
        if testSlot >= 0 and na(result)
            v = array.get(rvolStore, base + testSlot)
            if not na(v) and v > 0
                result := v
    result

// === Average cumulative volume for same time of day over prior days ===
float sumPrior = 0.0
int countPrior = 0

for d = 0 to lookbackDays - 1 by 1
    priorVol = getPriorCumVol(d, slot, searchBackMins)
    if not na(priorVol) and priorVol > 0
        sumPrior := sumPrior + priorVol
        countPrior := countPrior + 1
        

avgCumVol = countPrior > 0 ? sumPrior / countPrior : na
rvol = not na(avgCumVol) and avgCumVol > 0 ? dayCumVol / avgCumVol : na

// === Scale RVOL into a visual band inside the price chart ===
priceHigh = ta.highest(high, priceLookback)
priceLow = ta.lowest(low, priceLookback)
priceRange = math.max(priceHigh - priceLow, syminfo.mintick)

bandHeight = priceRange * bandHeightPct / 100.0
bandPadding = priceRange * 0.03

bandLow = bandPosition == 'Bottom' ? priceLow + bandPadding : priceHigh - bandPadding - bandHeight
bandHigh = bandLow + bandHeight

scaleRVOL(x) =>
    capped = math.min(math.max(x, 0), rvolCap)
    bandLow + capped / rvolCap * (bandHigh - bandLow)

rvolScaled = not na(rvol) ? scaleRVOL(rvol) : na
avgScaled = scaleRVOL(1.0)
highScaled = scaleRVOL(1.5)

// === Colours ===
rvolColour = rvol >= 2.0 ? color.lime : rvol >= 1.5 ? color.green : rvol >= 1.0 ? color.orange : color.red

// === Plots ===
plot(rvolScaled, title = 'Intraday cumulative RVOL', color = rvolColour, linewidth = 2)
plot(showOneLine ? avgScaled : na, title = '1.0x average volume', color = color.gray, linewidth = 1)
plot(showHighLine ? highScaled : na, title = '1.5x high volume', color = color.new(color.green, 20), linewidth = 1)

// === Live label ===
var label liveLabel = na

if barstate.islast and showLabel and not na(rvol)
    label.delete(liveLabel)

    labelText = 'RVOL: ' + str.tostring(rvol, '#.##') + 'x' + '\nToday cum vol: ' + str.tostring(dayCumVol, format.volume) + '\nAvg cum vol: ' + str.tostring(avgCumVol, format.volume)

    liveLabel := label.new(bar_index, rvolScaled, labelText, style = label.style_label_left, textcolor = color.white, color = rvol >= 1.0 ? color.green : color.red)

// === Alerts ===
alertcondition(rvol >= 1.5, title = 'RVOL above 1.5x', message = 'Intraday RVOL is above 1.5x average.')
alertcondition(rvol >= 2.0, title = 'RVOL above 2.0x', message = 'Intraday RVOL is above 2.0x average.')
````
