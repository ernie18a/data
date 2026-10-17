# IADSS Mean Reversion Tool - NS

- url: https://www.tradingview.com/script/PF3xEl1p-IADSS-Mean-Reversion-Tool-NS/
- type: indicator
- pine_id: PUB;59410b7e5f744ec7a2b2a9bd744e34b5
- version: 1.0

## Description

Mean reversion tool up to 2 standard deviations away from the mean with buy and sell entries

## Source Code

````pine
//@version=6
indicator("Approximated IADSS Mean Reversion Tool", shorttitle="IADSS MR Approx", overlay=false)

// Inputs
length = input.int(30, title="Noise Suppression (Length)", minval=1, tooltip="Higher = fewer signals, smoother oscillator. Default 30.")
style = input.string("Neutral", title="Trading Style", options=["Very Conservative", "Conservative", "Neutral", "Aggressive", "Very Aggressive"], tooltip="Affects signal thresholds.")
showDivergences = input.bool(true, title="Show Divergences")

// Map style to std dev multiplier
multiplier = switch style
    "Very Conservative" => 3.0
    "Conservative" => 2.5
    "Neutral" => 2.0
    "Aggressive" => 1.5
    "Very Aggressive" => 1.0

// Calculate z-score oscillator
ma = ta.sma(close, length)
std = ta.stdev(close, length)
osc = std != 0 and not na(ma) and not na(std) ? (close - ma) / std : 0.0

// Define bands
upperBand = multiplier
lowerBand = -multiplier

// Plot oscillator as columns to avoid histogram bug
oscPositive = osc > 0 ? osc : na
oscNegative = osc <= 0 ? osc : na
plot(oscPositive, "Oscillator Positive", color=color.new(color.red, 0), style=plot.style_columns)
plot(oscNegative, "Oscillator Negative", color=color.new(color.green, 0), style=plot.style_columns)

// Plot mean and bands
hline(0, "Mean Line", color=color.new(color.black, 0), linestyle=hline.style_solid)
plot(upperBand, "Upper Band", color=color.new(color.orange, 50), style=plot.style_line)
plot(lowerBand, "Lower Band", color=color.new(color.green, 50), style=plot.style_line)

// Detect buy/sell signals
buySignal = (osc[1] < osc[2] and osc[1] < osc[0]) and (osc[1] < lowerBand) and not na(osc[1])
sellSignal = (osc[1] > osc[2] and osc[1] > osc[0]) and (osc[1] > upperBand) and not na(osc[1])

// Plot signals
plotshape(buySignal ? osc[1] : na, "Buy Signal", style=shape.circle, location=location.absolute, color=color.new(color.green, 0), size=size.tiny)
plotshape(sellSignal ? osc[1] : na, "Sell Signal", style=shape.circle, location=location.absolute, color=color.new(color.red, 0), size=size.tiny)

// Divergence detection
bullDiv = showDivergences and low < low[1] and osc > osc[1] and osc < 0 and not na(osc) and not na(low)
bearDiv = showDivergences and high > high[1] and osc < osc[1] and osc > 0 and not na(osc) and not na(high)

// Plot divergences
plotshape(bullDiv ? osc : na, "Bullish Divergence", style=shape.triangleup, location=location.absolute, color=color.new(color.lime, 0), size=size.tiny)
plotshape(bearDiv ? osc : na, "Bearish Divergence", style=shape.triangledown, location=location.absolute, color=color.new(color.orange, 0), size=size.tiny)

// Alerts
alertcondition(buySignal, title="Buy Signal", message="IADSS MR Approx: Buy Signal - Oversold Reversion")
alertcondition(sellSignal, title="Sell Signal", message="IADSS MR Approx: Sell Signal - Overbought Reversion")
````
