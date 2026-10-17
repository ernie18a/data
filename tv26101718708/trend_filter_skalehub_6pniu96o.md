# Trend Filter [SkaleHub]

- url: https://www.tradingview.com/script/6PnIU96O-Trend-Filter-SkaleHub/
- type: indicator
- pine_id: PUB;daef01d5642349d6ba936b6e45d3e38d
- version: 1.0

## Description

Trend Filter [SkaleHub]
Overview
The flagship tool of the SkaleHub free tier. This indicator automatically paints your chart's candles green or red based on the dominant market trend by merging a baseline moving average with a price-action structure filter.

The Edge
It strips away emotional noise and enforces the golden rule of trading: only trade in the direction of the trend. By clearly defining the trend visually, it mentally and systematically forbids you from looking for setups against the market bias.

Key Features:

Visual Directional Bias: Instantly paints candles Green (Bullish) or Red (Bearish) so you never have to guess the macro trend.

Built-in Structure Logic: Combines moving average momentum with automated higher-high/lower-low structural validation to filter out false signals.

Systemized Discipline: Keeps developing traders hyper-focused by removing chart clutter and the confusion of managing multiple competing indicators at once.

How to Use

Apply the indicator to your chart.

Wait for a definitive candle color shift (Green for Bullish, Red for Bearish).

Only look for long entry setups while candles remain Green.

Only look for short entry setups while candles remain Red.

Author's Note
This indicator is part of the SkaleHub Free Starter Library. It is designed to be paired with the SkaleHub Training System to help newer traders build mechanical discipline and systemize their trading process.

## Source Code

````pine
//@version=5
indicator("Trend Filter [SkaleHub]", overlay=true, max_labels_count=500)

// =========================================================================
// 1. INPUT PARAMETERS (Customizable in the TradingView settings menu)
// =========================================================================
emaLength   = input.int(50, title="EMA Baseline Length", group="Trend Settings", tooltip="Length for the primary trend moving average.")
pivotLength = input.int(5, title="Structure Pivot Length", group="Structure Settings", tooltip="Number of bars used to confirm swing highs and lows.")
colorBull   = input.color(color.new(#00e800, 0), title="Bullish Trend Color", group="Visuals")
colorBear   = input.color(color.new(#f80000, 32), title="Bearish Trend Color", group="Visuals")

// =========================================================================
// 2. BASELINE MOVING AVERAGE (The Macro Trend)
// =========================================================================
// Calculates the smoothed Exponential Moving Average (EMA)
emaBaseline = ta.ema(close, emaLength)

// Determines basic relation to the EMA
priceAboveEma = close > emaBaseline
priceBelowEma = close < emaBaseline

// =========================================================================
// 3. PRICE ACTION STRUCTURE (Higher-Highs / Lower-Lows)
// =========================================================================
// Identifies swing highs and swing lows based on the pivot length
swingHigh = ta.pivothigh(high, pivotLength, pivotLength)
swingLow  = ta.pivothigh(low, pivotLength, pivotLength) // Using pivothigh for lows requires adjusting logic, correcting to pivotlow:
realSwingLow = ta.pivotlow(low, pivotLength, pivotLength)

// Variables to permanently store the most recent validated pivot points
var float lastSwingHigh = na
var float lastSwingLow  = na

if not na(swingHigh)
    lastSwingHigh := swingHigh
if not na(realSwingLow)
    lastSwingLow := realSwingLow

// Structure Bias Logic:
// Bullish structure = current close hasn't broken below the last major swing low
// Bearish structure = current close hasn't broken above the last major swing high
structBullish = close > lastSwingLow
structBearish = close < lastSwingHigh

// =========================================================================
// 4. THE SKALEHUB CONFLUENCE ENGINE
// =========================================================================
// Both the EMA and the Market Structure must agree to signal a trend shift
confluenceBullish = priceAboveEma and structBullish
confluenceBearish = priceBelowEma and structBearish

// State tracker to hold the trend color until a definitive shift occurs
var bool isTrendUp = true

if confluenceBullish
    isTrendUp := true
else if confluenceBearish
    isTrendUp := false

// =========================================================================
// 5. VISUAL OUTPUT & SYSTEMIZATION
// =========================================================================
// Define the final color based on the confluence state
candleColor = isTrendUp ? colorBull : colorBear

// Paint the candles to enforce the golden rule (only trade with the color)
barcolor(candleColor)

// Plot the baseline EMA for additional visual guidance
plot(emaBaseline, title="Trend Baseline", color=candleColor, linewidth=3)

// Optional: Plot tiny markers to show the user where the structure points are
plotshape(not na(swingHigh) ? swingHigh : na, title="Swing High", style=shape.triangledown, location=location.absolute, color=colorBear, size=size.tiny, offset=-pivotLength, display=display.none)
plotshape(not na(realSwingLow) ? realSwingLow : na, title="Swing Low", style=shape.triangleup, location=location.absolute, color=colorBull, size=size.tiny, offset=-pivotLength, display=display.none)
````
