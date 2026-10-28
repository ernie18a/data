# Pymander's EZ Breakout Finder

- url: https://www.tradingview.com/script/Eu1oDYqt-Pymander-s-EZ-Breakout-Finder/
- type: indicator
- pine_id: PUB;a46e0cf2fe65423a9f348f4d88f89daf
- version: 1.0

## Description

The Momentum Breakout Highlighter is a versatile price-action tool designed to identify high-conviction breakout candles. Unlike standard breakout indicators that trigger on any breach of a high or low, this script uses a multi-layered filtering system to ensure that signals represent genuine market commitment rather than "noise" or low-volume fakeouts.
How It Works
The script monitors a user-defined lookback period to establish local resistance (highs) and support (lows). A signal is generated only when three distinct conditions are met:
The Breakout: Price must breach the highest high or lowest low of the lookback period. Users can choose whether this requires a Wick breach or a full Close beyond the level.
The Momentum Filter: The candle’s body size (Open to Close) is compared against the average body size of the lookback period. A signal only triggers if the candle shows "effort"—meaning its body is significantly larger than the recent average.
The Trend Context: Signals are filtered via a Volume Weighted Moving Average (VWMA). By default, it follows the trend (Longs above VWMA, Shorts below), but it also includes a Mean Reversion Mode for contrarian traders.
Key Features
Momentum Verification: Uses an adjustable multiplier to ensure breakout candles have the necessary "thrust" to sustain a move.
Mean Reversion Mode: A unique toggle that flips the trend logic, allowing you to find high-momentum exhaustion moves back toward the VWMA.
Advanced Signal Management:
Cooldown Timer: Prevents "signal clustering" by requiring a set number of bars to pass before a new signal can trigger.
Opposite Direction Filter: An optional mode that forces signals to alternate between Bullish and Bearish, perfect for swing traders looking for "one-way" entries.
Visual Clarity: Features bar highlighting, triangular plotshapes (arrows), and optional reference lines for the previous high/low levels.
What Makes It Stand Out?
Most breakout indicators fail during choppy markets because they lack a volatility component. This script solves that by integrating Body-to-Average momentum logic. By requiring the "breakout" candle to be larger than its predecessors, it filters out "exhaustion wicks" and low-liquidity drifts.
Furthermore, the inclusion of VWMA Trend Bias ensures you are always trading with volume-weighted support, and the Cooldown/Directional filters make it an excellent tool for automating alerts without being overwhelmed by repetitive signals during high-volatility spikes.
How to Use
For Trend Following: Use the default settings to catch high-momentum entries in the direction of the trend.
For Mean Reversion: Enable "Mean Reversion Mode" to catch "Blow-off tops" or "Panic bottoms" that break local ranges against the primary trend.
For Scalping: Lower the lookback period and cooldown for faster signals on lower timeframes.
Good luck and enjoy!

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("EZ Breakout Finder", overlay = true)


// --- Inputs ---
lookbackInput       = input.int(20, "Lookback Period", minval = 1, tooltip = "Number of previous candles to check for highs and lows.")
momentumMultInput   = input.float(1.5, "Momentum Multiplier", minval = 0.1, step = 0.1, tooltip = "Multiplier for the average body size to define momentum.")
useTrendInput       = input.bool(true, "Use VWMA Trend Bias", tooltip = "If enabled, only shows bullish breaks above the VWMA and bearish breaks below it.")
breakoutSourceInput = input.string("Wick", "Breakout Source", options = ["Wick", "Close"], tooltip = "Choose whether the high/low (Wick) or the Close of the candle must break the level.")
vwmaLengthInput     = input.int(10, "VWMA Length", minval = 1)
useCooldownInput    = input.bool(true, "Use Signal Cooldown", tooltip = "If enabled, prevents new signals from appearing within a certain number of bars after a signal.")
cooldownLenInput    = input.int(5, "Cooldown Bars", minval = 1)
oneWayInput         = input.bool(false, "Toggle Opposite Direction Only", tooltip = "If enabled, signals must alternate between bullish and bearish.")
meanReversionMode   = input.bool(false, "Mean Reversion Mode", tooltip = "If enabled, bullish signals only show below the VWMA and bearish signals only show above it.")

bullColor = input.color(#089981, "Bullish Break Color", inline = "Colors")
bearColor = input.color(#f23645, "Bearish Break Color", inline = "Colors")
vwmaColor = input.color(color.new(#5b9cf6, 50), "VWMA Color")

// --- Calculations ---
// Previous High/Low
prevHigh = ta.highest(high[1], lookbackInput)
prevLow  = ta.lowest(low[1], lookbackInput)

// Momentum Logic
bodySize = math.abs(close - open)
avgBody  = ta.sma(bodySize, lookbackInput)
hasMomentum = bodySize > avgBody * momentumMultInput

// Trend Logic
vwmaValue = ta.vwma(close, vwmaLengthInput)
isBullishTrend = not useTrendInput or (meanReversionMode ? close < vwmaValue : close > vwmaValue)
isBearishTrend = not useTrendInput or (meanReversionMode ? close > vwmaValue : close < vwmaValue)

// Breakout Conditions
breakSourceHigh = breakoutSourceInput == "Wick" ? high : close
breakSourceLow  = breakoutSourceInput == "Wick" ? low : close

rawBullish = breakSourceHigh > prevHigh and hasMomentum and isBullishTrend
rawBearish = breakSourceLow < prevLow and hasMomentum and isBearishTrend

// Filter Logic
var int lastSignalBar = 0
var int lastDirection = 0 // 1 for bull, -1 for bear

canSignalCooldown = not useCooldownInput or (bar_index - lastSignalBar >= cooldownLenInput)
canSignalBull     = not oneWayInput or lastDirection != 1
canSignalBear     = not oneWayInput or lastDirection != -1

bullishBreak = rawBullish and canSignalCooldown and canSignalBull
bearishBreak = rawBearish and canSignalCooldown and canSignalBear

if bullishBreak
    lastSignalBar := bar_index
    lastDirection := 1
else if bearishBreak
    lastSignalBar := bar_index
    lastDirection := -1

// Highlight bars
barcolor(bullishBreak ? bullColor : bearishBreak ? bearColor : na)

// Plot Shapes
plotshape(bullishBreak, "Bullish Break Arrow", style = shape.triangleup,   location = location.belowbar, color = bullColor, size = size.small)
plotshape(bearishBreak, "Bearish Break Arrow", style = shape.triangledown, location = location.abovebar, color = bearColor, size = size.small)

// Plot VWMA
plot(useTrendInput ? vwmaValue : na, "VWMA Trend Bias", color = vwmaColor, linewidth = 2)

// Plot High/Low Levels (Optional reference)
plot(prevHigh, "Previous High", color = color.new(bullColor, 80), style = plot.style_linebr)
plot(prevLow, "Previous Low", color = color.new(bearColor, 80), style = plot.style_linebr)

// --- Alerts ---
alertcondition(bullishBreak, "Bullish Momentum Breakout", "Price broke the previous high with momentum!")
alertcondition(bearishBreak, "Bearish Momentum Breakout", "Price broke the previous low with momentum!")
````
