# Combined SMA and EMA Indicator

- url: https://www.tradingview.com/script/36Iq7OAC-Combined-SMA-and-EMA-Indicator/
- type: indicator
- pine_id: PUB;8f11a4b3727842519afe89b27fe6f91a
- version: 1.0

## Description

Description
This lightweight, multi-purpose indicator combines traditional Simple Moving Averages (SMA) and Exponential Moving Averages (EMA) into a single script, eliminating the need for multiple indicator slots on your chart.

Beyond simply plotting the standard lines, this script includes a dynamic secondary smoothing layer that can track either your SMA or EMA baseline, complete with optional Bollinger Band volatility channels.

Key Features:
Dual Display Mode: Choose to display only the SMA, only the EMA, or both simultaneously to analyze trend crossovers.

Targeted Smoothing: Apply a secondary filter to either the SMA or EMA baseline. Smoothing options include SMA, EMA, SMMA (RMA), WMA, or VWMA.

Integrated Bollinger Bands: Enable volatility bands directly over your smoothed moving average line to identify overextended price action and potential reversals.

Fully Configurable: Hide, show, or adjust lengths and source inputs for all components directly from the settings menu.

How to Use:
Trend Direction: Use the primary SMA/EMA crossover to determine the macro trend.

Dynamic Support/Resistance: Use the secondary Smoothed MA (Yellow) as a trailing trigger line for entries.

Volatility Breaks: Use the integrated Bollinger Bands to gauge when the baseline moving average is experiencing extreme expansion or contraction.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CaptainSidney

//@version=6
indicator(title="Combined SMA and EMA Indicator", shorttitle="SMA/EMA Dual", overlay=true, timeframe="", timeframe_gaps=true)

// --- Base Settings ---
GRP_BASE = "Base Moving Average Settings"
mode      = input.string("Both", "Plot Mode", options = ["SMA", "EMA", "Both"], group=GRP_BASE)
len       = input.int(9, minval=1, title="Length", group=GRP_BASE)
src       = input(close, title="Source", group=GRP_BASE)
offset    = input.int(title="Offset", defval=0, minval=-500, maxval=500, display = display.none, group=GRP_BASE)

// Calculations
sma_out = ta.sma(src, len)
ema_out = ta.ema(src, len)

// Plots for Base MAs
plot_sma = (mode == "SMA" or mode == "Both")
plot_ema = (mode == "EMA" or mode == "Both")

plot(sma_out, title="SMA", color=color.orange, offset=offset, display = plot_sma ? display.all : display.none)
plot(ema_out, title="EMA", color=color.blue, offset=offset, display = plot_ema ? display.all : display.none)

// --- Smoothing MA Settings ---
GRP_SMOOTH = "Smoothing"
TT_BB = "Only applies when 'SMA + Bollinger Bands' is selected. Determines the distance between the SMA and the bands."

smooth_target = input.string("EMA", "Smooth Which Target?", options = ["SMA", "EMA"], group=GRP_SMOOTH, tooltip="Select which base MA the smoothing calculations should apply to.")
maTypeInput   = input.string("None", "Type", options = ["None", "SMA", "SMA + Bollinger Bands", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group = GRP_SMOOTH, display = display.none)
maLengthInput = input.int(14, "Length", group = GRP_SMOOTH, display = display.none, active = maTypeInput != "None")
bbMultInput   = input.float(2.0, "BB StdDev", minval = 0.001, maxval = 50, step = 0.5, tooltip = TT_BB, group = GRP_SMOOTH, display = display.none, active = maTypeInput == "SMA + Bollinger Bands")

// Conditions
var isBB     = maTypeInput == "SMA + Bollinger Bands"
var enableMA = maTypeInput != "None"

// Smoothing MA Function
ma(source, length, MAtype) =>
    switch MAtype
        "SMA"                   => ta.sma(source, length)
        "SMA + Bollinger Bands" => ta.sma(source, length)
        "EMA"                   => ta.ema(source, length)
        "SMMA (RMA)"            => ta.rma(source, length)
        "WMA"                   => ta.wma(source, length)
        "VWMA"                  => ta.vwma(source, length)

// Select the baseline for smoothing
base_target = smooth_target == "SMA" ? sma_out : ema_out

// Smoothing MA Calculations & Plots
smoothingMA    = enableMA ? ma(base_target, maLengthInput, maTypeInput) : na
smoothingStDev = isBB ? ta.stdev(base_target, maLengthInput) * bbMultInput : na

plot(smoothingMA, "Smoothed MA", color=color.yellow, display = enableMA ? display.all : display.none, editable = enableMA)
bbUpperBand = plot(smoothingMA + smoothingStDev, title = "Upper Bollinger Band", color=color.green, display = isBB ? display.all : display.none, editable = isBB)
bbLowerBand = plot(smoothingMA - smoothingStDev, title = "Lower Bollinger Band", color=color.green, display = isBB ? display.all : display.none, editable = isBB)
fill(bbUpperBand, bbLowerBand, color= isBB ? color.new(color.green, 90) : na, title="Bollinger Bands Background Fill", display = isBB ? display.all : display.none, editable = isBB)
````
