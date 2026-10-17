# EMA Volatility-Normalized Angle Filter v6

- url: https://www.tradingview.com/script/BV4fq8VR-EMA-Volatility-Normalized-Angle-Filter-v6/
- type: indicator
- pine_id: PUB;dce20180a59a40eda94bb3eed52aab88
- version: 1.0

## Description

This script calculates a trend filter by calculating the slope of a 200 EMA, utilizing an ATR normalization technique to ensure the angle calculation remains robust and scale-invariant across all assets and zoom levels.

## Source Code

````pine
//@version=6
indicator("EMA Volatility-Normalized Angle Filter v6", overlay=true)

// ==========================================
// 1. Inputs & Parameters
// ==========================================
emaLength      = input.int(200, minval=1, title="EMA Length")
angleThreshold = input.float(15.0, minval=0.0, title="Angle Threshold (Normalized)")
lookback       = input.int(5, minval=1, title="Lookback Bars for Angle")
atrLength      = input.int(14, minval=1, title="ATR Length for Normalization")

// ==========================================
// 2. Calculations
// ==========================================
emaVal = ta.ema(close, emaLength)
atrVal = ta.atr(atrLength)

// Calculate raw price change of the EMA
priceChange = emaVal - emaVal[lookback]

// Normalize the price change by ATR to eliminate asset price scale issues
// Prevents the angle from changing when zooming the chart layout
normalizedChange = atrVal > 0 ? (priceChange / atrVal) : 0.0

// Calculate the slope angle using the normalized value
angle = math.atan(normalizedChange / lookback) * 180 / math.pi

// ==========================================
// 3. Rendering & Visuals
// ==========================================
// Assign dynamic colors based on normalized threshold limits
color emaColor = angle > angleThreshold ? color.green : angle < -angleThreshold ? color.red : color.gray
plot(emaVal, "EMA Angle Line", color=emaColor, linewidth=3)

// Optional: Visual Dashboard Summary Table
var table dash = table.new(position.top_right, 2, 1, bgcolor=color.new(color.black, 20), border_width=1)
if barstate.islast
    string angleText = "EMA Angle: " + str.tostring(angle, "#.##") + "°"
    color txtColor   = angle > angleThreshold ? color.green : angle < -angleThreshold ? color.red : color.white
    table.cell(dash, 0, 0, angleText, text_color=txtColor)
````
