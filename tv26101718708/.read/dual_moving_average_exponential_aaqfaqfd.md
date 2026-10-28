# Dual Moving Average Exponential

- url: https://www.tradingview.com/script/aaQfaqfd-Dual-Moving-Average-Exponential/
- type: indicator
- pine_id: PUB;6ed1c25d6502483fb4dca7ded93a6a1a
- version: 1.0

## Description

Overview
This script is a clean, optimized extension of TradingView's official, built-in Moving Average Exponential (EMA) indicator. Instead of cluttering your chart by loading multiple single indicators, this script allows you to plot two independent EMAs simultaneously within a single indicator slot, saving you valuable layout space.

It retains the full functionality of the original script, including the advanced Moving Average Smoothing and Bollinger Band features, applying them directly to the primary EMA.

Key Features
Dual EMA Plotting: Set independent lengths, sources, and offsets for two separate exponential moving averages (e.g., a fast EMA and a slow EMA for trend crossovers).

UI Customization: Color pickers have been added directly to the inputs menu, allowing you to change the line colors on the fly without entering the script settings style tab or editing the code.

Organized Input Groups: Settings are cleanly separated into "EMA 1", "EMA 2", and "Smoothing" sections for easy navigation.

Original Smoothing Matrix: Includes the native script's ability to smooth EMA 1 using SMA, EMA, SMMA, WMA, VWMA, or to generate EMA-based Bollinger Bands.

How to Use
Trend Identification: Use a fast EMA (e.g., 9 or 21) alongside a slow EMA (e.g., 50 or 200) to quickly identify trend direction and potential crossover signals.

Support & Resistance: Utilize the dual lines to identify dynamic support and resistance zones (the "space" between the two EMAs) rather than relying on a single price point.

Advanced Filtering: Turn on the "Smoothing" options in the settings menu to apply secondary filters or Bollinger Bands to your primary EMA for volatility and momentum analysis.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CaptainSidney

//@version=6
indicator(title="Dual Moving Average Exponential", shorttitle="Dual EMA", overlay=true, timeframe="", timeframe_gaps=true)

// --- EMA 1 Configuration ---
GRP1 = "EMA 1"
len1 = input.int(9, minval=1, title="Length", group=GRP1)
src1 = input(close, title="Source", group=GRP1)
offset1 = input.int(title="Offset", defval=0, minval=-500, maxval=500, display=display.none, group=GRP1)
color1 = input.color(color.blue, title="Color", group=GRP1)

out1 = ta.ema(src1, len1)
plot(out1, title="EMA 1", color=color1, offset=offset1)

// --- EMA 2 Configuration ---
GRP2 = "EMA 2"
len2 = input.int(21, minval=1, title="Length", group=GRP2)
src2 = input(close, title="Source", group=GRP2)
offset2 = input.int(title="Offset", defval=0, minval=-500, maxval=500, display=display.none, group=GRP2)
color2 = input.color(color.red, title="Color", group=GRP2)

out2 = ta.ema(src2, len2)
plot(out2, title="EMA 2", color=color2, offset=offset2)

// --- Smoothing MA inputs (Applies to EMA 1 Only) ---
GRP_SMOOTH = "Smoothing (EMA 1 Only)"
TT_BB = "Only applies when 'SMA + Bollinger Bands' is selected. Determines the distance between the SMA and the bands."
maTypeInput = input.string("None", "Type", options = ["None", "SMA", "SMA + Bollinger Bands", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group = GRP_SMOOTH, display = display.none)
var isBB = maTypeInput == "SMA + Bollinger Bands"
maLengthInput = input.int(14, "Length", group = GRP_SMOOTH, display = display.none, active = maTypeInput != "None")
bbMultInput = input.float(2.0, "BB StdDev", minval = 0.001, maxval = 50, step = 0.5, tooltip = TT_BB, group = GRP_SMOOTH, display = display.none, active = isBB)
var enableMA = maTypeInput != "None"

// Smoothing MA Calculation
ma(source, length, MAtype) =>
    switch MAtype
        "SMA"                   => ta.sma(source, length)
        "SMA + Bollinger Bands" => ta.sma(source, length)
        "EMA"                   => ta.ema(source, length)
        "SMMA (RMA)"            => ta.rma(source, length)
        "WMA"                   => ta.wma(source, length)
        "VWMA"                  => ta.vwma(source, length)

// Smoothing MA plots
smoothingMA = enableMA ? ma(out1, maLengthInput, maTypeInput) : na
smoothingStDev = isBB ? ta.stdev(out1, maLengthInput) * bbMultInput : na
plot(smoothingMA, "EMA 1-based MA", color=color.yellow, display = enableMA ? display.all : display.none, editable = enableMA)
bbUpperBand = plot(smoothingMA + smoothingStDev, title = "Upper Bollinger Band", color=color.green, display = isBB ? display.all : display.none, editable = isBB)
bbLowerBand = plot(smoothingMA - smoothingStDev, title = "Lower Bollinger Band", color=color.green, display = isBB ? display.all : display.none, editable = isBB)
fill(bbUpperBand, bbLowerBand, color= isBB ? color.new(color.green, 90) : na, title="Bollinger Bands Background Fill", display = isBB ? display.all : display.none, editable = isBB)
````
