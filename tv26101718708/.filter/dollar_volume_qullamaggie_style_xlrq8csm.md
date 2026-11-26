# Dollar Volume (Qullamaggie Style)

- url: https://www.tradingview.com/script/xLrq8Csm-Dollar-Volume-Qullamaggie-Style/
- type: indicator
- pine_id: PUB;b067fd6fff5e415cb58a4f2662b17e0a
- version: 1.0

## Description

This indicator calculates the Dollar Volume (Close × Volume) instead of the standard lot volume, replicating the exact methodology used by momentum trader Kristjan Qullamaggie in TC2000 (C * V).

Standard volume only shows the number of shares traded, which treats a $2 penny stock and a $400 tech stock the same. Dollar Volume measures the actual liquidity and institutional cash flow flowing into the stock, making it an essential filter for detecting true Episodic Pivots (EP) and high-momentum breakouts.

Features:

Dollar Volume Bars: Shows the exact USD value traded per bar.

50-Period SMA: Replicates Qullamaggie's baseline (AVGCV50) to identify abnormal institutional volume spikes.

Clean Data Window UI: Automatically formats large numbers into easily readable Millions (M) or Billions (B) on your screen.

Fully Customizable: Easily change bar colors, transparency, and MA lines via the settings menu.

## Source Code

````pine
//@version=6
indicator("Dollar Volume (Qullamaggie Style)", overlay=false, format=format.volume)

// ==========================================
// USER SETTINGS (INPUTS)
// ==========================================
volColor     = input.color(#1f77b4, title="Volume Bar Color", group="Color Settings")
volTrans     = input.int(30, title="Opacity (0-100)", minval=0, maxval=100, group="Color Settings")
maColor      = input.color(color.orange, title="50 MA Line Color", group="Color Settings")
textColor    = input.color(color.white, title="Text Color", group="Color Settings")

// ==========================================
// CALCULATIONS
// ==========================================
dollarVolume = close * volume
avgDollarVolume = ta.sma(dollarVolume, 50)

// Combine color and opacity
finalVolColor = color.new(volColor, volTrans)

// ==========================================
// CHART DRAWS
// ==========================================
plot(dollarVolume, color=finalVolColor, style=plot.style_columns, title="Dollar Volume")
plot(avgDollarVolume, color=maColor, linewidth=2, title="50 MA")

// ==========================================
// FORMAT AND INFO TABLE
// ==========================================
formatLabel(val) =>
    if val >= 1000000000
        str.tostring(val / 1000000000, "#.##") + "B"
    else if val >= 1000000
        str.tostring(val / 1000000, "#.##") + "M"
    else
        str.tostring(val, "#")

// Print clean formatted data to top left panel using a table
var table infoTable = table.new(position.top_left, 1, 1)
if barstate.islast
    table.cell(infoTable, 0, 0, "Current $ Vol: " + formatLabel(dollarVolume), text_color=textColor, text_size=size.small)
````
