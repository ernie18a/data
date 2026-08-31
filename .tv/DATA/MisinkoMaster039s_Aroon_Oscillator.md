<!-- tradingview-pine-id: PUB;03bfb08bc06f4c8080f699e28843298a -->
<!-- tradingviewscripts-format: 1 -->
# MisinkoMaster&#039;s Aroon Oscillator

Source: https://www.tradingview.com/script/4GV71xtj-MisinkoMaster-s-Aroon-Oscillator/

## Description

Special Aroon Oscillator by MisinkoMaster

The Special Aroon Oscillator is a modified implementation of the traditional Aroon Oscillator designed to capture momentum shifts with reduced noise and lag.

Traditional Aroon calculations rely strictly on raw High and Low price extremes over a fixed period. This script incorporates a double-exponential smoothing mechanism on your chosen input source prior to measuring bar distance, providing cleaner zero-line crossovers and smoother trend transitions.

Key Features

    Custom Smoothing Pre-Filter: Applies a smoothing calculation to the source series to filter out market noise before calculating high/low bar distances.

    Dynamic Visual Cues: Renders an oscillator bounded between +100 and -100 with color-coded trend indicators, zero-line bounds, and background fills.

    On-Chart Bar Coloring: Dynamically colors price candles directly on your chart to match the oscillator's prevailing directional bias.

    Built-in Alert Conditions: Includes ready-to-use alerts for zero-line crossovers to notify you of bullish and bearish regime shifts.

How It Works

    Calculations: The indicator smooths the chosen input source using the Smooth length. It then identifies the number of bars since the highest and lowest values of this smoothed series over the user-defined Length lookback.

    Oscillator Formula: Oscillator = Aroon Up - Aroon Down

        Above 0 (Green): Bullish trend state.

        Below 0 (Red): Bearish trend state.

    Bar Coloring: Price candles on the chart match the current oscillator state—green during bullish momentum and red during bearish momentum.

Inputs & Settings

    Source (Default: Close): The price series used for calculation.

    Length (Default: 28): The lookback window in bars used to identify recent highs and lows.

    Smooth (Default: 14): The lookback length for the pre-smoothing filter.

How to Use

    Zero Crossovers: Watch for the oscillator crossing above zero for potential bullish setups, or below zero for bearish setups.

    Extremes (+100 / -100): Values near +100 indicate persistent buying pressure, while values near -100 indicate strong selling pressure.

Built-in Alerts

    Bullish Zero Cross: Triggers when the oscillator crosses above 0.

    Bearish Zero Cross: Triggers when the oscillator crosses below 0.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MisinkoMaster

//@version=6
indicator("MisinkoMaster's Aroon Oscillator", "Special Aroon Oscillator", overlay = false)
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Import Libraries
import TradingView/ta/14
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Get User Defined Inputs
src = input.source(close, "Source")
length = input.int(28, "Length", step = 1, minval = 2)
smooth = input.int(14, "Smooth", step = 1, minval = 2)
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Calculations
source = ta.ema(src, smooth) * (1 - 2 / (1 + smooth)) + src * 2 / (1 + smooth)

up = 100 * (ta.highestbars(source, length + 1) + length)/length

down = 100 * (ta.lowestbars(source, length + 1) + length)/length

mao = up - down
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Trend Logic
var trend = 0

L = mao > 0
S = mao < 0

if L
    trend := 1
if S
    trend := -1
////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Alert Conditions
bullish_cross = ta.crossover(mao, 0)
bearish_cross = ta.crossunder(mao, 0)

alertcondition(bullish_cross, title = "Bullish Zero Cross", message = "Special Aroon Oscillator crossed ABOVE zero (Bullish Shift)")
alertcondition(bearish_cross, title = "Bearish Zero Cross", message = "Special Aroon Oscillator crossed BELOW zero (Bearish Shift)")

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Plotting
col = color.rgb(68, 75, 64)
if trend == 1
    col := color.rgb(18, 112, 5)
if trend == -1
    col := color.rgb(163, 4, 4)
if mao == 0
    col := color.rgb(68, 75, 64)

o = plot(mao, "MisinkoMaster's Special Aroon Oscillator", col, 3, histbase = 0, format = format.percent)
plot(mao, "MisinkoMaster's Special Aroon Oscillator Dots", col, 3, histbase = 0, format = format.percent, style = plot.style_circles)

p = plot(100, "Max Value", color.rgb(18, 112, 5, 25), 2, display = display.pane)
plot(100, "Max Value Glow", color.rgb(18, 112, 5, 50), 4, display = display.pane)

n = plot(-100, "Min Value", color.rgb(163, 4, 4, 25), 2, display = display.pane)
plot(-100, "Min Value Glow", color.rgb(163, 4, 4, 50), 4, display = display.pane)

m = plot(0, "Neutral Value", color.rgb(68, 75, 64, 25), 2, display = display.pane)
plot(0, "Neutral Value Glow", color.rgb(68, 75, 64, 50), 4, display = display.pane)

pbc = color.rgb(4, 243, 112, 80)
nbc = color.rgb(241, 20, 20, 80)

fill(p, m, pbc)
fill(n, m, nbc)

fill = trend == 1 ? color.rgb(4, 243, 112, 95) : trend == -1 ? color.rgb(241, 20, 20, 95) : na
fill(o, m, fill)

plotcandle(open, high, low, close, color = col, wickcolor = col, bordercolor = col, force_overlay = true, display = display.pane)
````
