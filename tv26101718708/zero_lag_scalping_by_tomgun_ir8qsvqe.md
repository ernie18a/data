# Zero Lag Scalping by Tomgun

- url: https://www.tradingview.com/script/iR8qsvQE/
- type: indicator
- pine_id: PUB;fee60a3d48e349f29c568c2e2b11ae31
- version: 2.0

## Description

A simple Zero Lag Scalper with alert functions.
In addition to standard filtering, an EMA and ATR can be utilized to ensure that not every crossover generates an immediate signal. It is recommended to observe support and resistance zones, use volume profiles, and employ a second indicator for confirmation.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Zero Lag Scalping by Tomgun", "Zero_Lag_Scalping_by Tomgun", overlay = true)

// --- Constants ---
var string G_MA   = "Moving Average Settings"
var string G_FLT  = "Signal Filters"
var string G_ADX  = "ADX Filter"
var string G_VIS  = "Visualization"
var color C_UP    = #089981
var color C_DN    = #f23645
var color C_BLUE  = #5b9cf6

// --- Inputs ---
fastLen   = input.int(10, "Fast ZLEMA Length", minval = 1, group = G_MA, tooltip = "Period for the fast responsive average")
slowLen   = input.int(30, "Slow ZLEMA Length", minval = 1, group = G_MA, tooltip = "Period for the slower trend average")
src       = input.source(close, "Source", group = G_MA)

// Trend & Volatility Filter Inputs
useTrendFilter = input.bool(true,  "Use Trend Filter (EMA)",      group = G_FLT, tooltip = "Only buy above and sell below the trend EMA")
trendLen       = input.int(200,    "Trend Filter Length",          group = G_FLT, minval = 1)
useVolFilter   = input.bool(true,  "Use Volatility Filter (ATR)",  group = G_FLT, tooltip = "Filters signals when market volatility is below its average")
atrLen         = input.int(14,     "ATR Length",                   group = G_FLT, minval = 1)

// ADX Filter Inputs
useAdxFilter   = input.bool(true,  "Use ADX Filter",               group = G_ADX, tooltip = "Filters signals when the trend is too weak (ADX below threshold)")
adxLen         = input.int(14,     "ADX Length",                   group = G_ADX, minval = 1,  tooltip = "Lookback period for the ADX / DI calculation")
adxSmooth      = input.int(14,     "ADX Smoothing",                group = G_ADX, minval = 1,  tooltip = "Smoothing period applied to the raw ADX value")
adxThreshold   = input.int(20,     "Min. ADX Threshold",           group = G_ADX, minval = 1,  maxval = 100, tooltip = "Signal is blocked when ADX is below this value (weak / sideways market). Common values: 20–25")
showAdx        = input.bool(false, "Show ADX Value in Data Window", group = G_ADX, tooltip = "Plots the ADX value in the Data Window for reference")

// Visualization Inputs
showSignals = input.bool(true,  "Show Scalp Signals",  group = G_VIS)
showRibbon  = input.bool(true,  "Show Trend Ribbon",   group = G_VIS)
showTrend   = input.bool(false, "Show Trend Filter MA", group = G_VIS)

// --- Calculations ---

// Zero Lag EMA Function
calc_zlema(source, length) =>
    int   lag  = math.floor((length - 1) / 2)
    float data = source + (source - nz(source[lag]))
    ta.ema(data, length)

fastZ = calc_zlema(src, fastLen)
slowZ = calc_zlema(src, slowLen)

// Trend Filter
trendMA      = ta.ema(src, trendLen)
isAboveTrend = close > trendMA
isBelowTrend = close < trendMA

// Volatility Filter (ATR)
atr        = ta.atr(atrLen)
atrAvg     = ta.sma(atr, atrLen * 2)
isVolatile = atr > atrAvg

// ADX Filter
// ta.dmi returns [diPlus, diMinus, adx]
[diPlus, diMinus, adxRaw] = ta.dmi(adxLen, adxSmooth)
adxValue   = nz(adxRaw, 0.0)          // protect against na on early bars
isTrending = adxValue > adxThreshold

// Signal Logic
crossBull = ta.crossover(fastZ, slowZ)
crossBear = ta.crossunder(fastZ, slowZ)

adxOk   = not useAdxFilter or isTrending
trendOk = not useTrendFilter
volOk   = not useVolFilter or isVolatile

bullish = crossBull and (trendOk or isAboveTrend) and volOk and adxOk
bearish = crossBear and (trendOk or isBelowTrend) and volOk and adxOk

// --- Visuals ---

// Trend Filter MA
plot(showTrend ? trendMA : na, "Trend Filter MA", color.new(chart.fg_color, 70), 1, plot.style_linebr)

// ZLEMA Ribbon
fastPlot  = plot(fastZ, "Fast ZLEMA", color = fastZ > slowZ ? C_UP : C_DN, linewidth = 2)
slowPlot  = plot(slowZ, "Slow ZLEMA", color = chart.fg_color, linewidth = 1, display = display.none)
fillColor = showRibbon ? (fastZ > slowZ ? color.new(C_UP, 80) : color.new(C_DN, 80)) : na
fill(fastPlot, slowPlot, fillColor, "Trend Ribbon")

// ADX in Data Window (optional)
plot(showAdx ? adxValue     : na, "ADX",          color = C_BLUE,              display = display.data_window)
plot(showAdx ? diPlus       : na, "DI+",           color = color.new(C_UP, 30), display = display.data_window)
plot(showAdx ? diMinus      : na, "DI-",           color = color.new(C_DN, 30), display = display.data_window)
plot(showAdx ? adxThreshold : na, "ADX Threshold", color = color.new(C_BLUE, 60), display = display.data_window)

// Scalp Labels
if showSignals and bullish
    label.new(bar_index, low,  text = "BUY",  color = C_UP, textcolor = color.white, style = label.style_label_up,   yloc = yloc.belowbar, size = size.small)

if showSignals and bearish
    label.new(bar_index, high, text = "SELL", color = C_DN, textcolor = color.white, style = label.style_label_down, yloc = yloc.abovebar, size = size.small)

// --- Alerts ---
alertcondition(bullish, "Bullish Scalp", "Zero Lag Filtered Bullish Signal")
alertcondition(bearish, "Bearish Scalp", "Zero Lag Filtered Bearish Signal")
````
