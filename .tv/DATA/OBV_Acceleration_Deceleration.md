<!-- tradingview-pine-id: PUB;03450615dfbc42caa6b04d2f0fc66e18 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# OBV Acceleration / Deceleration

Source: https://www.tradingview.com/script/OqKI6Jgy-OBV-Acceleration-Deceleration/

## Description

Description:

Introduction
Classic On-Balance Volume (OBV) is a powerful tool for tracking smart money and volume flow. However, standard OBV relies on raw closing prices to determine whether volume was "bullish" or "bearish" for the day. This makes it highly susceptible to market noise, wicks, and fake-outs.
This open-source script, OBV Acceleration / Deceleration, rebuilds the OBV formula from the ground up. It filters price noise using a Fibonacci-weighted Master Average and introduces a Volume Kinetics engine to detect exactly when volume is accelerating (spiking) or decelerating (drying up)

How It Works: Core Logic & Features
This indicator is built on three core mechanical features. Here is the exact logic behind how they work:

1. The Fibonacci Master Average (Noise Filtering)
Instead of looking at the raw close price to decide if volume should be added or subtracted, this script calculates six separate Simple Moving Averages (SMAs) based on the first six numbers of the Fibonacci sequence (1, 1, 2, 3, 5, 8).
*The Logic: The script averages these six SMAs together to create a "Master Average."
*The Result: If the Master Average is pointing up, the volume is added to the OBV. If it points down, it is subtracted. This ensures that a single erratic price wick does not falsely flip the volume flow.

2. Volume Kinetics (Acceleration & Deceleration)
Standard OBV only tells you direction, not intensity. This script measures the "velocity" of the volume by tracking the absolute change in the OBV step bar-by-bar, and compares it to a 40-period historical average.
*Acceleration (Volume Spikes): If the current volume is greater than our customizable Expansion Factor (default 2.0x the average), it flags an Acceleration state. This indicates high momentum, institutional participation, or a heavy breakout.
*Deceleration (Volume Dry-Up): If the current volume drops below our Compression Factor (default 0.5x the average), it flags a Deceleration state. This mathematically highlights market exhaustion, tight consolidation, or a lack of interest.

3. OBV Moving Average & Cloud Fill
To help determine the broader momentum context, a 20-period SMA is applied directly to the custom OBV line.
*The Logic: A dynamic cloud fills the space between the OBV line and its SMA.
*The Result: When OBV is above its SMA, the cloud is Teal (Bullish momentum). When OBV is below its SMA, the cloud is Maroon (Bearish momentum).

Visual Guide (Reading the Dots)
The indicator plots color-coded dots directly on the OBV line to give you instant visual feedback on volume kinetics:
🟢 Bright Green Dot: Bullish Acceleration (High-volume buying spike).
🔴 Bright Red Dot: Bearish Acceleration (High-volume selling spike).
🟡 Yellow Dot: Deceleration / Exhaustion (Volume has severely dried up).
🔵 Teal Dot: Standard bullish volume flow.
🟤 Maroon Dot: Standard bearish volume flow.

Practical Trading Applications
Confirming Breakouts: If price breaks through a key resistance level and the indicator prints a Bright Green Dot, it confirms the breakout is supported by anomalous volume and is more likely to succeed.
Spotting Reversals (Exhaustion): When price approaches a major support or resistance level and prints a cluster of Yellow Dots, it means the volume pushing the trend has dried up. This often precedes a reversal or a deep pullback.
Trend Riding: Stay in trades as long as the OBV line remains on the correct side of its SMA (represented by the Teal or Maroon cloud fill), ignoring minor price pullbacks.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © biokon70

//@version=6
indicator('OBV Acceleration / Deceleration', shorttitle = 'OBV Accel/Decel', overlay = false, format = format.volume)

// ==========================================
// 1. INPUTS & CUSTOMIZATION
// ==========================================
grp_fib = '1. Fibonacci SMA Smoothing'
len1 = input.int(1, title = 'SMA 1', group = grp_fib, inline = 'sma1')
len2 = input.int(1, title = 'SMA 2', group = grp_fib, inline = 'sma1')
len3 = input.int(2, title = 'SMA 3', group = grp_fib, inline = 'sma2')
len4 = input.int(3, title = 'SMA 4', group = grp_fib, inline = 'sma2')
len5 = input.int(5, title = 'SMA 5', group = grp_fib, inline = 'sma3')
len6 = input.int(8, title = 'SMA 6', group = grp_fib, inline = 'sma3')

grp_kinetics = '2. Volume Velocity & Spikes'
lookback = input.int(40, title = 'Avg Volume Lookback', group = grp_kinetics, tooltip = 'Days to measure average volume speed.')
compressionFactor = input.float(0.5, title = 'Deceleration (Dry-Up) Multiplier', step = 0.1, group = grp_kinetics, tooltip = 'Flags exhaustion (Yellow). Triggers when current volume is less than this multiplier of the average.')
expansionFactor = input.float(2.0, title = 'Acceleration (Spike) Multiplier', step = 0.1, group = grp_kinetics, tooltip = 'Flags heavy momentum (Bright Green/Red). Triggers when current volume is greater than this multiplier of the average.')

grp_obv_sma = '3. OBV Moving Average & Fill'
showSma = input.bool(true, title = 'Show OBV SMA', group = grp_obv_sma)
obvSmaLen = input.int(20, title = 'OBV SMA Length', group = grp_obv_sma, tooltip = 'Moving average length applied directly to the custom OBV line.')
fillCloud = input.bool(true, title = 'Fill Area Between OBV & SMA', group = grp_obv_sma, tooltip = 'Fills the space between the OBV line and its SMA to show momentum direction.')

// ==========================================
// 2. CORE MATH & FIBONACCI AVERAGE
// ==========================================
// Calculate multiple SMAs to filter out price noise
sma1 = ta.sma(close, len1)
sma2 = ta.sma(close, len2)
sma3 = ta.sma(close, len3)
sma4 = ta.sma(close, len4)
sma5 = ta.sma(close, len5)
sma6 = ta.sma(close, len6)

// Mean of Means - The Master Trend Line
masterAvg = (sma1 + sma2 + sma3 + sma4 + sma5 + sma6) / 6

// ==========================================
// 3. CUSTOM OBV CALCULATION
// ==========================================
// Directional logic: Use the smoothed Master Average instead of raw closing price
float obv_step = 0.0
if masterAvg > masterAvg[1]
    obv_step := volume
    obv_step
else if masterAvg < masterAvg[1]
    obv_step := -volume
    obv_step
else
    obv_step := 0.0
    obv_step


// Cumulative sum to build the OBV line
float customOBV = ta.cum(obv_step)

// Calculate the SMA for the OBV Line
float obvSmaLine = ta.sma(customOBV, obvSmaLen)

// ==========================================
// 4. VELOCITY & DECELERATION CALCULATIONS
// ==========================================
// The absolute change in OBV is equal to the current bar's volume
obvVelocity = math.abs(customOBV - customOBV[1])

// Find the historical average of volume over the lookback period
avgObvVelocity = ta.sma(obvVelocity, lookback)

// Detect Volume Anomalies
isDecelerating = obvVelocity <= avgObvVelocity * compressionFactor
isAccelerating = obvVelocity >= avgObvVelocity * expansionFactor

// Determine directional trend of the OBV line
isBullishOBV = customOBV > customOBV[1]

// ==========================================
// 5. VISUAL OUTPUT & COLOR LOGIC
// ==========================================
// Dynamic Dot Colors:
// Bright Green = Acceleration (Bullish Volume Spike)
// Bright Red   = Acceleration (Bearish Volume Spike)
// Yellow       = Deceleration (Volume Dry-Up / Exhaustion)
// Teal         = Standard Bullish Volume
// Maroon       = Standard Bearish Volume
color dotColor = color.gray
if isDecelerating
    dotColor := color.new(color.yellow, 0)
    dotColor
else if isAccelerating and isBullishOBV
    dotColor := color.new(#00ff0a, 0) // Bright Green
    dotColor
else if isAccelerating and not isBullishOBV
    dotColor := color.new(#ff0000, 0) // Bright Red
    dotColor
else if isBullishOBV
    dotColor := color.new(color.teal, 0)
    dotColor
else
    dotColor := color.new(color.maroon, 0)
    dotColor

// Plots
plot_obv = plot(customOBV, title = 'OBV Line', color = color.new(color.gray, 30), linewidth = 1)
plot_sma = plot(showSma ? obvSmaLine : na, title = 'OBV SMA', color = color.new(color.orange, 0), linewidth = 1)

// Plot the Dots on top of the OBV line
plot(customOBV, title = 'Velocity Dots', color = dotColor, style = plot.style_circles, linewidth = 2)

// Cloud Fill Logic
fillColor = customOBV > obvSmaLine ? color.new(color.teal, 80) : color.new(color.maroon, 80)
fill(plot_obv, plot_sma, title = 'OBV vs SMA Fill', color = fillCloud ? fillColor : na)

// ==========================================
// 6. ALERTS
// ==========================================
alertcondition(ta.crossover(customOBV, obvSmaLine), title = 'OBV Bullish Cross', message = 'OBV crossed ABOVE its SMA. Bullish volume momentum.')
alertcondition(ta.crossunder(customOBV, obvSmaLine), title = 'OBV Bearish Cross', message = 'OBV crossed BELOW its SMA. Bearish volume momentum.')
alertcondition(isDecelerating, title = 'Volume Dry-Up', message = 'Volume has significantly decelerated (Exhaustion).')
alertcondition(isAccelerating, title = 'Volume Spike', message = 'High volume acceleration detected.')
````
