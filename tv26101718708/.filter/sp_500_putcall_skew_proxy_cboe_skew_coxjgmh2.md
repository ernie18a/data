# S&P 500 Put/Call Skew Proxy (CBOE SKEW)

- url: https://www.tradingview.com/script/COXJgMH2-S-P-500-Put-Call-Skew-Proxy-CBOE-SKEW/
- type: indicator
- pine_id: PUB;6550f0ec2708494bb0eb22cb41086458
- version: 1.0

## Description

S&P 500 Put/Call Skew Proxy (CBOE SKEW)

A proxy for the average single-stock put/call skew across S&P 500 constituents, built on the CBOE SKEW Index. Inspired by Goldman Sachs research charting the 3-month normalized put/call skew for individual S&P 500 stocks, which requires constituent-level options surface data unavailable on TradingView.

What is the CBOE SKEW Index?

The CBOE SKEW Index measures the perceived tail risk in S&P 500 index options. It quantifies the price of insuring against outsized downside moves by comparing the implied volatility of out-of-the-money puts to at-the-money options. Higher values indicate greater demand for tail-risk protection; lower values signal complacency or reduced hedging activity.

While the GS metric averages skew across individual stock options surfaces, the CBOE SKEW captures a related signal at the index level: how aggressively the market is pricing left-tail risk. Both compress toward historical lows during periods of broad complacency and spike during stress events.

How This Indicator Works

Pulls CBOE:SKEW and applies a 63-bar simple moving average (approximately 3 months of trading days) as the primary signal, matching the smoothing window of the GS chart.
Optionally displays the raw (unsmoothed) SKEW as a dimmed background line for context.
Computes full-history summary statistics: high, low, mean, last, and standard deviation of the smoothed series.
Plots the historical mean and ±1 standard deviation bands to identify extremes.
Displays a summary statistics table (High, Low, Avg, Last, StdDev, N) in the style of the original GS chart.


Interpretation

Readings near or above the upper standard deviation band suggest unusually high demand for downside protection, historically associated with market stress, fear of tail-risk events, or elevated hedging activity.
Readings near or below the lower band indicate reduced demand for crash insurance, historically associated with complacency or euphoria.
Sustained compression toward the lower bound has preceded several notable market corrections, though the signal is not directionally predictive on its own.


Limitations

This is a proxy, not a replication. The CBOE SKEW measures index-level tail-risk pricing, not the average of individual stock option skews. The two are correlated but not identical.
Structural changes in options markets (growth of 0DTE, systematic call-overwriting strategies, dealer hedging flows) may compress skew for reasons unrelated to sentiment.
Best used as a supporting input within a broader market breadth or sentiment framework, not as a standalone signal.


Settings

Smoothing Length: default 63 (3 months). Adjustable for shorter or longer signal windows.
Show Raw SKEW: toggle the unsmoothed series on/off.
Show Mean ± StdDev Bands: toggle statistical reference lines.
Show Summary Statistics Table: toggle the stats table and select its position.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © YourTradingViewUsername

//@version=6
indicator("S&P 500 Put/Call Skew Proxy (CBOE SKEW)", overlay=false, format=format.price, precision=2)

// ─── Inputs ───
smoothLen   = input.int(63,   "Smoothing Length (3m)",  minval=1, tooltip="63 trading days ≈ 3 months. Matches the Goldman Sachs chart's 3-month normalization window.")
showRaw     = input.bool(true, "Show Raw SKEW",         tooltip="Display the unsmoothed CBOE SKEW as a dimmed background line.")
showBands   = input.bool(true, "Show Mean ± StdDev Bands")
showTable   = input.bool(true, "Show Summary Statistics Table")
tablePos    = input.string(position.bottom_right, "Table Position", options=[position.top_left, position.top_center, position.top_right, position.bottom_left, position.bottom_center, position.bottom_right])

// ─── Data ───
rawSkew = request.security("CBOE:SKEW", timeframe.period, close)

// ─── Smoothing ───
smoothSkew = ta.sma(rawSkew, smoothLen)

// ─── Full-History Statistics ───
var float sumX   = 0.0
var float sumX2  = 0.0
var int   count  = 0
var float hiVal  = na
var float loVal  = na

if not na(smoothSkew)
    count := count + 1
    sumX  := sumX  + smoothSkew
    sumX2 := sumX2 + smoothSkew * smoothSkew
    hiVal := na(hiVal) ? smoothSkew : math.max(hiVal, smoothSkew)
    loVal := na(loVal) ? smoothSkew : math.min(loVal, smoothSkew)

avgVal  = count > 0 ? sumX / count : na
stdVal  = count > 1 ? math.sqrt((sumX2 - sumX * sumX / count) / (count - 1)) : na
lastVal = smoothSkew

// ─── Plots ───
rawColor    = color.new(color.gray, 75)
smoothColor = color.white
avgColor    = color.new(color.yellow, 40)
bandColor   = color.new(color.yellow, 85)

plot(showRaw ? rawSkew : na,    "Raw SKEW",      color=rawColor,    linewidth=1)
plot(smoothSkew,                "Smoothed SKEW",  color=smoothColor, linewidth=2)

avgLine  = plot(showBands ? avgVal : na,             "Mean",       color=avgColor,  linewidth=1, style=plot.style_line)
hiBank   = plot(showBands ? avgVal + stdVal : na,    "+1 StdDev",  color=bandColor, linewidth=1, style=plot.style_line)
loBank   = plot(showBands ? avgVal - stdVal : na,    "-1 StdDev",  color=bandColor, linewidth=1, style=plot.style_line)
fill(hiBank, loBank, color=color.new(color.yellow, 92), title="StdDev Band Fill")

// ─── Summary Statistics Table ───
if showTable and barstate.islast
    var table statsTable = table.new(tablePos, 6, 2, border_width=1)

    headerBg = color.new(color.gray, 60)
    cellBg   = color.new(color.gray, 85)
    txtColor = color.white

    table.cell(statsTable, 0, 0, "High",   text_color=txtColor, bgcolor=headerBg, text_size=size.small)
    table.cell(statsTable, 1, 0, "Low",    text_color=txtColor, bgcolor=headerBg, text_size=size.small)
    table.cell(statsTable, 2, 0, "Avg",    text_color=txtColor, bgcolor=headerBg, text_size=size.small)
    table.cell(statsTable, 3, 0, "Last",   text_color=txtColor, bgcolor=headerBg, text_size=size.small)
    table.cell(statsTable, 4, 0, "StdDev", text_color=txtColor, bgcolor=headerBg, text_size=size.small)
    table.cell(statsTable, 5, 0, "N",      text_color=txtColor, bgcolor=headerBg, text_size=size.small)

    table.cell(statsTable, 0, 1, str.tostring(hiVal,  "#.##"), text_color=txtColor, bgcolor=cellBg, text_size=size.small)
    table.cell(statsTable, 1, 1, str.tostring(loVal,  "#.##"), text_color=txtColor, bgcolor=cellBg, text_size=size.small)
    table.cell(statsTable, 2, 1, str.tostring(avgVal, "#.##"), text_color=txtColor, bgcolor=cellBg, text_size=size.small)
    table.cell(statsTable, 3, 1, str.tostring(lastVal,"#.##"), text_color=txtColor, bgcolor=cellBg, text_size=size.small)
    table.cell(statsTable, 4, 1, str.tostring(stdVal, "#.##"), text_color=txtColor, bgcolor=cellBg, text_size=size.small)
    table.cell(statsTable, 5, 1, str.tostring(count),          text_color=txtColor, bgcolor=cellBg, text_size=size.small)
````
