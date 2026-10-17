# Alpha Hunter Integrated MACD & Oscillator [wjdtks255]

- url: https://www.tradingview.com/script/N5XP2BRL/
- type: indicator
- pine_id: PUB;79f815ce7c0a44998dc271c9314aaadc
- version: 2.0

## Description

Indicator Title: Alpha Hunter Integrated MACD & Oscillator Pro
Short Description
A high-precision hybrid oscillator that integrates MACD dynamics with a secondary-smoothed histogram to eliminate market noise and capture trend reversals with minimal lag.

Detailed Description
Overview
The Alpha Hunter Integrated MACD & Oscillator is designed to overcome the inherent lag of standard MACD indicators. By applying an exponential moving average (EMA) filter to the histogram itself and incorporating a momentum direction check, this tool identifies high-probability entry points while filtering out "whipsaws" commonly found in choppy markets.

Key Technical Pillars
Dual-Smoothed Histogram: Unlike standard oscillators, this script smooths the raw histogram values using a secondary filtering period. This reveals the true underlying momentum before price action fully shifts.

Momentum Directional Filter: Entry signals are only triggered when the MACD line’s slope aligns with the crossover, ensuring you don't enter against a stalling trend.

Dynamic Trend Clouds: The visual fill between the MACD and Signal lines acts as a "Trend Cloud," providing immediate visual feedback on the strength and duration of the current trend.

The Winning Trading Strategy (How to Use)
To maximize win rates, it is highly recommended to use this indicator as a Confirmation Oscillator alongside a Long-term Trend Filter (like a 200 EMA) on your main chart.

1. Long Setup (Buy)
Context: Price must be trading above the 200 EMA on the main chart.

Signal: A green "BUY" triangle and label appear on the oscillator.

Confirmation: The Histogram should be green and rising.

Exit: Exit at a pre-defined Take Profit (TP) box or when a bearish MACD crossunder occurs.

2. Short Setup (Sell)
Context: Price must be trading below the 200 EMA on the main chart.

Signal: A red "SELL" triangle and label appear on the oscillator.

Confirmation: The Histogram should be red and falling.

Exit: Exit at the designated Stop Loss (SL) or when a bullish MACD crossover occurs.

Input Parameters & Optimization
Fast/Slow/Signal: Default 12, 26, 9. (Standard for most markets).

Signal Smoothing: Set to 5 for a balance of speed and reliability. Increase to 8+ for swing trading on higher timeframes.

Recommended Timeframes: 15m, 1h, and 4h for the best signal-to-noise ratio.

Author's Note
This indicator is a "No-Repaint" script. Signals are confirmed at the close of the candle to ensure reliability during live trading. Always use proper risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © wjdtks255

//@version=5
indicator("Sani Momentum Target System [wjdtks255]", overlay=true, max_lines_count=100, max_labels_count=100)
// update logic and description
// === Inputs ===
lenSmooth = input.int(8, "Smoothing Length")
lenFast = input.int(20, "Fast MA Length")
lenSlow = input.int(50, "Slow MA Length")
atrPeriod = input.int(80, "ATR Period")
targetGap = input.float(1.0, "Target Multiplier (ATR x)", step=0.1)
extendBars = input.int(50, "Extend Lines Bars Count")

// === Glide-like smoother function ===
f_smooth(src, len) =>
    alpha = 2.0 / (len + 1)
    var float val = na
    val := na(val[1]) ? src : alpha * src + (1 - alpha) * val[1]

// === Core calculation ===
glide = f_smooth(close, lenSmooth)
fast = ta.ema(glide, lenFast)
slow = ta.ema(glide, lenSlow)
osc = fast - slow
sig = ta.sma(osc, lenSmooth)
atrV = ta.atr(atrPeriod)

// === Trend detection ===
trendChangeUp = ta.crossover(osc, sig)
trendChangeDown = ta.crossunder(osc, sig)

// === Object storage ===
var line lineSL = na
var line lineEntry = na
var line lineT1 = na
var line lineT2 = na
var line lineT3 = na

var label labelSL = na
var label labelEntry = na
var label labelT1 = na
var label labelT2 = na
var label labelT3 = na

// === Fixed prices for stable labels and lines ===
var float fixedSL = na
var float fixedEntry = na
var float fixedT1 = na
var float fixedT2 = na
var float fixedT3 = na

// === Clear previous objects ===
f_clear_objects() =>
    if not na(lineSL)
        line.delete(lineSL)
    if not na(lineEntry)
        line.delete(lineEntry)
    if not na(lineT1)
        line.delete(lineT1)
    if not na(lineT2)
        line.delete(lineT2)
    if not na(lineT3)
        line.delete(lineT3)
    if not na(labelSL)
        label.delete(labelSL)
    if not na(labelEntry)
        label.delete(labelEntry)
    if not na(labelT1)
        label.delete(labelT1)
    if not na(labelT2)
        label.delete(labelT2)
    if not na(labelT3)
        label.delete(labelT3)

// === Create new lines, labels and fix Y positions on signal ===
if (trendChangeUp or trendChangeDown)
    f_clear_objects()
    dir = trendChangeUp ? 1 : -1
    base = close
    fixedSL := base - dir * atrV * 2
    fixedEntry := base
    fixedT1 := base + dir * atrV * (2 * targetGap)
    fixedT2 := base + dir * atrV * (4 * targetGap)
    fixedT3 := base + dir * atrV * (6 * targetGap)

    // Create horizontal lines extended to right
    lineSL := line.new(bar_index, fixedSL, bar_index + extendBars, fixedSL, color=color.new(color.red, 0))
    lineEntry := line.new(bar_index, fixedEntry, bar_index + extendBars, fixedEntry, color=color.new(color.green, 0))
    lineT1 := line.new(bar_index, fixedT1, bar_index + extendBars, fixedT1, color=color.new(color.blue, 0))
    lineT2 := line.new(bar_index, fixedT2, bar_index + extendBars, fixedT2, color=color.new(color.blue, 0))
    lineT3 := line.new(bar_index, fixedT3, bar_index + extendBars, fixedT3, color=color.new(color.blue, 0))

    // Create labels at right end with fixed Y
    labelSL := label.new(bar_index + extendBars, fixedSL, "SL: " + str.tostring(fixedSL, format.mintick), color=color.new(color.red, 0), style=label.style_label_left, textcolor=color.white)
    labelEntry := label.new(bar_index + extendBars, fixedEntry, "ENTRY: " + str.tostring(fixedEntry, format.mintick), color=color.new(color.green, 0), style=label.style_label_left, textcolor=color.white)
    labelT1 := label.new(bar_index + extendBars, fixedT1, "T1: " + str.tostring(fixedT1, format.mintick), color=color.new(color.blue, 0), style=label.style_label_left, textcolor=color.white)
    labelT2 := label.new(bar_index + extendBars, fixedT2, "T2: " + str.tostring(fixedT2, format.mintick), color=color.new(color.blue, 0), style=label.style_label_left, textcolor=color.white)
    labelT3 := label.new(bar_index + extendBars, fixedT3, "T3: " + str.tostring(fixedT3, format.mintick), color=color.new(color.blue, 0), style=label.style_label_left, textcolor=color.white)

// === Update X positions dynamically (Y fixed) ===
if not na(lineSL)
    line.set_x1(lineSL, bar_index)
    line.set_x2(lineSL, bar_index + extendBars)
if not na(lineEntry)
    line.set_x1(lineEntry, bar_index)
    line.set_x2(lineEntry, bar_index + extendBars)
if not na(lineT1)
    line.set_x1(lineT1, bar_index)
    line.set_x2(lineT1, bar_index + extendBars)
if not na(lineT2)
    line.set_x1(lineT2, bar_index)
    line.set_x2(lineT2, bar_index + extendBars)
if not na(lineT3)
    line.set_x1(lineT3, bar_index)
    line.set_x2(lineT3, bar_index + extendBars)

if not na(labelSL)
    label.set_x(labelSL, bar_index + extendBars)
if not na(labelEntry)
    label.set_x(labelEntry, bar_index + extendBars)
if not na(labelT1)
    label.set_x(labelT1, bar_index + extendBars)
if not na(labelT2)
    label.set_x(labelT2, bar_index + extendBars)
if not na(labelT3)
    label.set_x(labelT3, bar_index + extendBars)

// === Candle color by trend ===
barcolor(osc > sig ? color.new(color.teal, 0) : osc < sig ? color.new(color.orange, 0) : na)

// === Signal markers ===
plotshape(trendChangeUp, title="Buy Signal", style=shape.triangleup, location=location.belowbar, color=color.new(color.teal, 0), size=size.small)
plotshape(trendChangeDown, title="Sell Signal", style=shape.triangledown, location=location.abovebar, color=color.new(color.orange, 0), size=size.small)
````
