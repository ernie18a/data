<!-- tradingview-pine-id: PUB;54a92ba2545641aeb44f0251cf4786c9 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Volume Effort vs Result Scanner

Source: https://www.tradingview.com/script/xphSQNQL-Volume-Effort-vs-Result-Scanner/

## Description

Volume Effort vs. Result Scanner (Equilibrium Tracker)

 This indicator is designed for price action and Volume Spread Analysis (VSA) traders seeking to identify key inflection points in the market. It specifically scans for the "Effort vs. Result" anomaly, looking for instances where massive trading volume (High Effort) fails to move the price significantly, resulting in a tightly contained candlestick range (Small Result).

When these two parameters align, it indicates a strong point of market equilibrium or hidden absorption, often signaling institutional accumulation, distribution, or an imminent volatility breakout.

How It Works

The script evaluates the market using two entirely customizable lookback periods, defaulting to standard institutional baselines:High Relative Volume (Effort): Compares the volume of the current bar against a 50-period Simple Moving Average (SMA). By default, it looks for bars with at least 2.0x (200%) the average volume.

Small Candlestick Range (Result): Compares the total high-to-low range of the candle against a 50-period Average True Range (ATR). By default, it limits the signal to candles that are 1.0x (100%) or less of the average historical volatility. 

Tuning the Scanner to Your Strategy

This indicator is fully customizable so you can dial in your exact personal favorite setup depending on the market environment or asset class:

To Find Massive Institutional Absorption (Rare, High-Quality): Keep the Min Relative Volume Ratio high (e.g., 2.0x to 2.5x) and tighten the Max Candle Size Ratio downward (e.g., 0.6x to 0.8x). This isolates rare, ultra-tight "Doji" or pin bars that have massive volume injected into them.

---

## Source Code

````pine
//@version=6
indicator("Volume Effort vs Result Scanner", overlay=true)

// ==========================================
// 1. INPUTS / VARIABLES YOU CAN ADJUST
// ==========================================
var_g_vol   = "1. High Relative Volume Settings"
volPeriod   = input.int(50, title="Volume MA Period", minval=1, group=var_g_vol, tooltip="Number of bars to calculate average volume")
volThresh   = input.float(2.0, title="Min Relative Volume Ratio", minval=0.1, step=0.1, group=var_g_vol, tooltip="Multiplier vs average")

var_g_candle = "2. Small Candlestick Settings"
atrPeriod   = input.int(50, title="ATR Period", minval=1, group=var_g_candle, tooltip="Number of bars to calculate average true range")
atrMaxThresh = input.float(1.0, title="Max Candle Size Ratio", minval=0.1, step=0.1, group=var_g_candle, tooltip="Maximum size multiplier vs ATR")

// ==========================================
// 2. CALCULATIONS
// ==========================================
// Volume Condition
avgVol = ta.sma(volume, volPeriod)
relVol = volume / avgVol
volCondition = relVol >= volThresh

// Candlestick Size Condition
candleSize = high - low
currentAtr = ta.atr(atrPeriod)
relCandle = candleSize / currentAtr
candleCondition = relCandle <= atrMaxThresh

// Combined Setup Match (High Volume + Small Candle)
setupMatch = volCondition and candleCondition

// ==========================================
// 3. VISUAL SIGNALS (SMALL DEEP BLUE TRIANGLE)
// ==========================================
// Define a rich, premium deep royal blue color
deepBlue = color.new(#0044ff, 0)

// Places a perfectly scaled deep blue triangle pointing down at the matched candle
plotshape(setupMatch, title="Equilibrium Setup Match", style=shape.triangledown, location=location.abovebar, color=deepBlue, size=size.small)
````
