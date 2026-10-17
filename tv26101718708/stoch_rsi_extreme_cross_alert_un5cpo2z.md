# Stoch RSI Extreme Cross Alert

- url: https://www.tradingview.com/script/UN5cPO2Z-Stoch-RSI-Extreme-Cross-Alert/
- type: indicator
- pine_id: PUB;c6e029248a8a40b7b056db57a725a633
- version: 1.0

## Description

The purpose of this indicator is to detect 2 conditions;
1. When signal K and D are in overbought or oversold areas
2. When signal K and D are crossing

## Source Code

````pine
//@version=5
indicator("Stoch RSI Extreme Cross Alert", overlay=false)

// --- Inputs ---
smoothK = input.int(3, "K", minval=1)
smoothD = input.int(3, "D", minval=1)
lengthRSI = input.int(14, "RSI Length", minval=1)
lengthStoch = input.int(14, "Stochastic Length", minval=1)
src = input(close, title="Source")

upperThreshold = input.float(80, "Upper Threshold")
lowerThreshold = input.float(20, "Lower Threshold")

// --- Calculations ---
rsi1 = ta.rsi(src, lengthRSI)
k = ta.sma(ta.stoch(rsi1, rsi1, rsi1, lengthStoch), smoothK)
d = ta.sma(k, smoothD)

// --- Conditions ---
// 1. Both lines above 80 or below 20
inExtremeZone = (k > upperThreshold and d > upperThreshold) or (k < lowerThreshold and d < lowerThreshold)

// 2. Crossing between K and D
kCrossD = ta.cross(k, d)

// Combine conditions
alertCondition = inExtremeZone and kCrossD

// --- Visualization ---
plot(k, "K", color=color.blue)
plot(d, "D", color=color.orange)
hline(upperThreshold, "Upper Band", color=color.gray, linestyle=hline.style_dashed)
hline(lowerThreshold, "Lower Band", color=color.gray, linestyle=hline.style_dashed)

// Highlight background when condition is met
bgcolor(alertCondition ? color.new(color.purple, 70) : na)

// Plot shapes for visual confirmation
plotshape(alertCondition, title="Cross Alert", style=shape.triangleup, location=location.bottom, color=color.purple, size=size.small)

// --- Alerts ---
if alertCondition
    alert("Stoch RSI Extreme Cross detected! K: " + str.tostring(k) + " D: " + str.tostring(d), alert.freq_once_per_bar_close)
````
