# Crypto Trend Tool Pro

- url: https://www.tradingview.com/script/PrPNoojv/
- type: indicator
- pine_id: PUB;1c3721239fa84af6af11f3ab46ff2f7f
- version: 1.0

## Description

LuxAlgo SB Trend Indikator mit Long und Short Signalen

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("Crypto Trend Tool Pro", shorttitle="CTT Pro", overlay = true)

// --- Group Definitions ---
var string G_TREND   = "Trend & Momentum"
var string G_VOLA    = "Volatility Bands"
var string G_FILTER  = "Signal Filters"
var string G_DASH    = "Dashboard Settings"
var string G_STYLE   = "Style Settings"

// --- Inputs ---
// Trend & Momentum
emaLen      = input.int(50, "EMA Length", minval = 1, group = G_TREND, tooltip = "The length of the Exponential Moving Average for trend determination.")
rsiLen      = input.int(14, "RSI Length", minval = 1, group = G_TREND)
rsiOB       = input.int(70, "RSI Overbought", minval = 50, maxval = 100, group = G_TREND)
rsiOS       = input.int(30, "RSI Oversold", minval = 0, maxval = 50, group = G_TREND)

// Volatility
atrLen      = input.int(14, "ATR Length", minval = 1, group = G_VOLA)
atrMult     = input.float(2.0, "ATR Multiplier", minval = 0.1, step = 0.1, group = G_VOLA)

// Filters
useRsiFilter = input.bool(true, "Use RSI Filter", group = G_FILTER, tooltip = "Long signals are only generated if RSI is not overbought.")
useVolFilter = input.bool(true, "Use Volume Filter", group = G_FILTER, tooltip = "Signals are only generated if volume is above average.")
volMaLen     = input.int(20, "Volume MA Length", minval = 1, group = G_FILTER)

// Dashboard
showDash     = input.bool(true, "Show Dashboard", group = G_DASH)
dashPos      = input.string("Top Right", "Position", options = ["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group = G_DASH)

// Colors
bullColor    = input.color(#089981, "Bullish Color", group = G_STYLE)
bearColor    = input.color(#f23645, "Bearish Color", group = G_STYLE)
neutColor    = input.color(#5b9cf6, "Neutral Color", group = G_STYLE)

// --- Calculations ---
// Base Indicators
baseEMA   = ta.ema(close, emaLen)
rsiVal    = ta.rsi(close, rsiLen)
atrVal    = ta.atr(atrLen)
volMA     = ta.sma(volume, volMaLen)

// Bands
upperBand = baseEMA + atrVal * atrMult
lowerBand = baseEMA - atrVal * atrMult

// Filter Logic
volConfirm = not useVolFilter or volume > volMA
rsiBullOk  = not useRsiFilter or rsiVal < rsiOB
rsiBearOk  = not useRsiFilter or rsiVal > rsiOS

// Trend & Signals
isBullish     = close > baseEMA
bullishSignal = ta.crossover(close, baseEMA) and volConfirm and rsiBullOk
bearishSignal = ta.crossunder(close, baseEMA) and volConfirm and rsiBearOk

// --- Visualization ---
// Plots
pUpper = plot(upperBand, "Upper Band", color = color.new(bullColor, 60), style = plot.style_linebr)
pEMA   = plot(baseEMA, "Basis EMA", color = isBullish ? bullColor : bearColor, linewidth = 2)
pLower = plot(lowerBand, "Lower Band", color = color.new(bearColor, 60), style = plot.style_linebr)

// Gradient Fills
fill(pEMA, pUpper, upperBand, baseEMA, color.new(bullColor, 80), color.new(bullColor, 100), title = "Bullish Zone")
fill(pEMA, pLower, baseEMA, lowerBand, color.new(bearColor, 100), color.new(bearColor, 80), title = "Bearish Zone")

// Signals
plotshape(bullishSignal, "Long Signal", shape.triangleup, location.belowbar, bullColor, size = size.small, text = "LONG", textcolor = bullColor)
plotshape(bearishSignal, "Short Signal", shape.triangledown, location.abovebar, bearColor, size = size.small, text = "SHORT", textcolor = bearColor)

// --- Dashboard Table ---
var table dashTable = na
if showDash and barstate.islast
    tPos = dashPos == "Top Right" ? position.top_right : dashPos == "Bottom Right" ? position.bottom_right : dashPos == "Top Left" ? position.top_left : position.bottom_left
    dashTable := table.new(tPos, 2, 4, bgcolor = color.new(chart.bg_color, 10), border_color = chart.fg_color, border_width = 1)
    
    // Header
    table.cell(dashTable, 0, 0, "Metric", text_color = chart.fg_color, text_size = size.small)
    table.cell(dashTable, 1, 0, "Value", text_color = chart.fg_color, text_size = size.small)
    
    // Trend
    table.cell(dashTable, 0, 1, "Trend", text_color = chart.fg_color, text_halign = text.align_left)
    table.cell(dashTable, 1, 1, isBullish ? "BULLISH" : "BEARISH", bgcolor = isBullish ? color.new(bullColor, 70) : color.new(bearColor, 70), text_color = chart.fg_color)
    
    // RSI
    table.cell(dashTable, 0, 2, "RSI (" + str.tostring(rsiLen) + ")", text_color = chart.fg_color, text_halign = text.align_left)
    table.cell(dashTable, 1, 2, str.tostring(rsiVal, "#.##"), bgcolor = rsiVal > rsiOB ? color.new(bearColor, 70) : rsiVal < rsiOS ? color.new(bullColor, 70) : color.new(neutColor, 70), text_color = chart.fg_color)
    
    // Volume
    volStatus = volume > volMA ? "HIGH" : "LOW"
    table.cell(dashTable, 0, 3, "Volume", text_color = chart.fg_color, text_halign = text.align_left)
    table.cell(dashTable, 1, 3, volStatus, bgcolor = volume > volMA ? color.new(bullColor, 70) : color.new(neutColor, 70), text_color = chart.fg_color)

// --- Alerts ---
alertcondition(bullishSignal, "Bullish Signal (Filtered)", "New long signal with volume & RSI confirmation.")
alertcondition(bearishSignal, "Bearish Signal (Filtered)", "New short signal with volume & RSI confirmation.")
````
