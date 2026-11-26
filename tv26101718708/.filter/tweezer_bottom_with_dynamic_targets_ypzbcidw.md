# Tweezer Bottom with Dynamic Targets

- url: https://www.tradingview.com/script/ypZBcidw-Tweezer-Bottom-with-Dynamic-Targets/
- type: indicator
- pine_id: PUB;605fbcd00d5349cd888586ee1b2da883
- version: 1.0

## Description

[b]Core Purpose[/b]. The script tracks momentum changes by looking for a bullish reversal directly on a specific options contract chart, rather than using the underlying Nifty index spot chart.
[b]Script Architecture[/b]. The Rules: It looks for two back-to-back candles where the first candle is bearish, the second is bullish, and their bottom wicks hit an identical price floor (configured with a tight 5% noise tolerance).The Visual: It automatically flags valid trade setups by plotting a green triangle directly underneath the candle on your workspace chart.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jay_Maan

//@version=6
plot(close)//@version=5
indicator("Tweezer Bottom with Dynamic Targets", overlay=true)

// --- User Inputs ---
wMaxPerc  = input.float(0.1, title="Max Low Diff (%)", minval=0.01, step=0.01, tooltip="Maximum percentage difference allowed between the two lows.")
lookback   = input.int(5, title="Trend Lookback Bars", minval=1, tooltip="Number of bars to check for a preceding downtrend.")
volPeriod  = input.int(20, title="Volume MA Period", minval=1, tooltip="Period to calculate average volume confirmation.")

// --- Trend and Structure Conditions ---
// 1. Check for a short-term lower trend leading into the pattern
isDowntrend = ta.highest(high, lookback) > high

// 2. Identify candle types (Candle 1 is bearish/indecisive, Candle 2 is bullish)
isBearishC1 = close[1] <= open[1]
isBullishC2 = close > open

// 3. Mathematical check for matching lows (Tweezer condition)
lowDiffPerc = math.abs(low[1] - low) / low * 100
matchingLows = lowDiffPerc <= wMaxPerc

// 4. Volume Confirmation Rule (Current volume must be higher than the 20-period moving average)
avgVolume = ta.sma(volume, volPeriod)
volumeConfirmed = volume > avgVolume

// --- Final Tweezer Bottom Pattern Validation ---
tweezerBottom = isDowntrend and matchingLows and isBullishC2 and volumeConfirmed

// --- Visualizing Pattern on Chart ---
plotshape(tweezerBottom, title="Tweezer Bottom Signal", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.normal)

// --- Dynamic Line Drawing Logic (Stop-Loss and Targets) ---
var line slLine = na
var line t1Line = na
var line t2Line = na

var label slLabel = na
var label t1Label = na
var label t2Label = na

if tweezerBottom
    // Clean up previous lines to keep the chart clean
    line.delete(slLine)
    line.delete(t1Line)
    line.delete(t2Line)
    label.delete(slLabel)
    label.delete(t1Label)
    label.delete(t2Label)

    // Calculate structural metrics
    patternLow = math.min(low[1], low)
    patternHigh = math.max(high[1], high)
    patternSize = patternHigh - patternLow

    // Calculate Levels based on Nifty structure (Risk vs Reward metrics)
    slValue = patternLow - (patternSize * 0.1) // Giving room below the wicks
    t1Value = patternHigh + (patternSize * 1.0) // 1:1 Risk Reward Target
    t2Value = patternHigh + (patternSize * 2.0) // 1:2 Risk Reward Target

    // Draw the Lines extending 10 bars into the future
    slLine := line.new(x1=bar_index, y1=slValue, x2=bar_index + 10, y2=slValue, color=color.red, width=2, style=line.style_dashed)
    t1Line := line.new(x1=bar_index, y1=t1Value, x2=bar_index + 10, y2=t1Value, color=color.orange, width=2, style=line.style_solid)
    t2Line := line.new(x1=bar_index, y1=t2Value, x2=bar_index + 10, y2=t2Value, color=color.green, width=2, style=line.style_solid)

    // Add Labels for clarity
    slLabel := label.new(x=bar_index + 10, y=slValue, text="SL: " + str.tostring(math.round(slValue)), style=label.style_label_left, color=color.red, textcolor=color.white, size=size.small)
    t1Label := label.new(x=bar_index + 10, y=t1Value, text="Target 1: " + str.tostring(math.round(t1Value)), style=label.style_label_left, color=color.orange, textcolor=color.white, size=size.small)
    t2Label := label.new(x=bar_index + 10, y=t2Value, text="Target 2: " + str.tostring(math.round(t2Value)), style=label.style_label_left, color=color.green, textcolor=color.white, size=size.small)

// --- Automated Alerts Settings ---
alertcondition(tweezerBottom, title="Volume Confirmed Tweezer Alert", message="Bullish Tweezer Bottom confirmed with high volume! Check targets on chart.")
````
