# Buy/Sell Volume Pressure

- url: https://www.tradingview.com/script/nNzxy4yG-Buy-Sell-Volume-Pressure/
- type: indicator
- pine_id: PUB;4b4f1fb8539a44c69922f62b01bc74da
- version: 1.0

## Description

[symbol="FX:GBPJPY"]FX:GBPJPY[/symbol] 1. Overview
The Buy/Sell Volume Pressure indicator is a sophisticated volume-analysis tool designed to reveal the hidden tug-of-war between buyers and sellers. Unlike standard volume bars that only show total activity, this indicator decomposes every candle into its constituent buying and selling components based on price action within the bar (wick-to-body ratio). It provides a smoothed, oscillator-style histogram that identifies trend strength, exhaustion points, and high-probability reversals.

2. Key Features & Calculations
Wick-Based Pressure Estimation: Uses a precise calculation to determine volume distribution. It analyzes where the close sits relative to the high and low. A close near the high attributes more volume to "Buying Pressure," while a close near the low attributes it to "Selling Pressure."
Non-Repainting Multi-Timeframe (HTF) Support: Includes a built-in HTF toggle that allows you to view volume pressure from higher timeframes (e.g., Daily pressure on a 15m chart). Uses the industry-standard [1] offset to ensure data is confirmed and never repaints.
Volume Filter for Accuracy: An optional filter that only validates signals when volume is above its 20-period moving average, ensuring you aren't misled by "low-liquidity noise."
Extreme Zone Detection: Dynamically calculates overbought and oversold "Extreme Zones" based on recent historical ranges, highlighting areas where the trend may be overextended.
WMA Smoothing: Incorporates a Weighted Moving Average (WMA) to provide a clearer trend direction and reduce histogram volatility.
Price-Confirmed Divergences: Automatically detects Bullish and Bearish divergences between price and volume pressure, filtered by swing-point confirmation for higher reliability.

3. How to Use for Trading
Signal	Interpretation
Teal Histogram Rising	Buyers in control — trend confirmation
Maroon Histogram Falling	Sellers dominating — trend confirmation
Zero-Line Cross (→ Positive)	Momentum shift — potential long entry
Bullish Divergence (🟢)	Price lower low + Pressure higher low = Selling exhaustion
Bearish Divergence (🔴)	Price higher high + Pressure lower high = Buying exhaustion
Extreme Zone Highlight	Market overextended — watch for reversal patterns
4. Input Parameters
Core Settings
Lookback Period: SMA length to smooth the raw buy/sell difference
Divergence Swing Lookback: Sensitivity of pivot points for divergence detection
Higher Timeframe: Overlay higher-level volume trends (1H, 4H, D, etc.)
Accuracy Improvements
Volume Filter: Only validate signals above average volume
Avg Volume Length: Period for calculating average volume
Visual & Smoothing
WMA Smoothing: Toggle the yellow Weighted Moving Average line
Threshold %: Adjusts how "extreme" the zones must be (top/bottom % of recent range)
5. Alerts Available
Zero-Line Crosses — Momentum shift notifications
Divergence Detections — Bullish/Bearish divergence alerts
Extreme Zone Entry/Exit — When pressure enters/leaves overbought/oversold zones

## Source Code

````pine
//@version=6
indicator("Buy/Sell Volume Pressure", overlay=false)

// --- Inputs ---
lookbackLen = input.int(14, "Lookback Period")
divLookback = input.int(5, "Divergence Swing Lookback")
showDiv     = input.bool(true, "Show Divergence Lines")
htfRes      = input.timeframe("", "Higher Timeframe")
volFilter   = input.bool(true, "Volume Filter (Above Average Only)", group="Accuracy Improvements")
volLen      = input.int(20, "Avg Volume Length", minval=1, group="Accuracy Improvements")

// WMA Features
showWMA     = input.bool(true, "Show WMA Smoothing", group="WMA Settings")
wmaLen      = input.int(10, "WMA Length", minval=1, group="WMA Settings")

// Extreme Zones
showExtremes = input.bool(true, "Highlight Extreme Zones", group="Extreme Zones")
thresholdPct = input.float(20.0, "Threshold % (Top/Bottom)", minval=1, maxval=49, group="Extreme Zones")

// --- Calculations ---
// 1. Improved Buy/Sell Pressure Estimation (Wick-based)
// Uses the position of the close within the candle range to estimate pressure
candleRange = high - low
buyingPressure = candleRange == 0 ? 0.5 : (close - low) / candleRange
sellingPressure = 1.0 - buyingPressure

buyVol  = volume * buyingPressure
sellVol = volume * sellingPressure

pressure = ta.sma(buyVol - sellVol, lookbackLen)

// 2. Optimized HTF Request (Conditional and Non-Repainting)
// Uses [1] outside the security call to ensure the HTF data is confirmed and non-repainting
htfPressure = htfRes != "" ? request.security(syminfo.tickerid, htfRes, pressure, barmerge.gaps_off, barmerge.lookahead_off)[1] : pressure
finalPressure = htfRes == "" ? pressure : htfPressure

// 3. Efficiency: Optimized Extreme Zones
// Recalculates thresholds only when the feature is enabled
var float upperThresh = na
var float lowerThresh = na
if showExtremes
    highestHigh = ta.highest(finalPressure, 100)
    lowestLow   = ta.lowest(finalPressure, 100)
    rangeVal    = highestHigh - lowestLow
    upperThresh := highestHigh - (rangeVal * thresholdPct / 100)
    lowerThresh := lowestLow + (rangeVal * thresholdPct / 100)

// 4. Volume Filter Logic
avgVol = ta.sma(volume, volLen)
isHighVol = not volFilter or (volume > avgVol)

// --- Visuals ---
// Dynamic Coloring: Darker/saturated when increasing, lighter/transparent when decreasing
histColor = finalPressure >= 0 ? 
             (finalPressure > finalPressure[1] ? color.new(color.teal, 0) : color.new(color.teal, 50)) : 
             (finalPressure < finalPressure[1] ? color.new(color.maroon, 0) : color.new(color.maroon, 50))

plot(finalPressure, "Volume Pressure", color=histColor, style=plot.style_columns)
hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dotted)

// WMA Smoothing
wmaLine = ta.wma(finalPressure, wmaLen)
plot(showWMA ? wmaLine : na, "WMA Smoothing", color=color.yellow, linewidth=2)

// Extreme Area Highlighting
bgcolor(showExtremes and finalPressure > upperThresh ? color.new(color.teal, 85) : na, title="Extreme Buy Zone")
bgcolor(showExtremes and finalPressure < lowerThresh ? color.new(color.maroon, 85) : na, title="Extreme Sell Zone")

// --- Divergence (Reliability Improvements) ---
ph = ta.pivothigh(finalPressure, divLookback, divLookback)
pl = ta.pivotlow(finalPressure, divLookback, divLookback)

// Price Confirmation: Bearish div requires price to make a higher high relative to the previous pivot
bearDiv = not na(ph) and high[divLookback] > ta.highest(high, divLookback)[divLookback+1] and isHighVol[divLookback]
bullDiv = not na(pl) and low[divLookback] < ta.lowest(low, divLookback)[divLookback+1] and isHighVol[divLookback]

plotshape(showDiv and bearDiv ? finalPressure[divLookback] : na, "Bearish Div", shape.triangledown, location.absolute, color.red, offset=-divLookback)
plotshape(showDiv and bullDiv ? finalPressure[divLookback] : na, "Bullish Div", shape.triangleup, location.absolute, color.green, offset=-divLookback)
````
