# Climax Volume Reversal Radar

- url: https://www.tradingview.com/script/CaMMEfwd-Climax-Volume-Reversal-Radar/
- type: indicator
- pine_id: PUB;009afc62a96442708d89b9f43ebf138f
- version: 1.0

## Description

[image]https://www.tradingview.com/x/kIqFToi1/[/image]

Detecting abnormal volume spikes that may signal exhaustion, capitulation, or reversal pressure.

Climax Volume Reversal Radar is a volume-based exhaustion indicator designed to highlight abnormal volume spikes that may occur near potential short-term reversal zones.

The indicator compares current volume against a recent average volume baseline and marks bars when volume expands above a user-defined risk multiplier.

It focuses on two types of potential climax events:

Bullish Climax Condition:
Detected when price is trading below its previous reference close, the candle closes bearish, and current volume is significantly above average. This may represent aggressive selling pressure, possible capitulation, or a potential bullish reversal watch zone.

Bearish Climax Condition:
Detected when price is trading above its previous reference close, the candle closes bullish, and current volume is significantly above average. This may represent aggressive buying pressure, possible exhaustion, or a potential bearish reversal watch zone.

The indicator also includes an optional volume moving average to help traders compare current activity against normal participation levels.

This tool can be useful for identifying:

- Volume climaxes
- Potential exhaustion points
- Possible capitulation zones
- Abnormal market participation
- Short-term reversal watch areas
- High-volume emotional candles

Best used with support and resistance, VWAP, trend structure, liquidity zones, or price action confirmation. This indicator does not predict reversals automatically and should not be used as a standalone trading system.

How it works:

The indicator calculates an average volume baseline using recent bars and compares the current volume against that baseline.

When current volume exceeds the average by the selected multiplier, the script checks whether price is moving aggressively upward or downward.

A high-volume bearish candle may suggest selling climax or capitulation.
A high-volume bullish candle may suggest buying climax or exhaustion.

These events do not guarantee a reversal. They are best interpreted as warning zones where emotional market participation may be increasing.

Inputs:

Show MA:
Enables or disables the volume moving average.

Length MA:
Controls the length of the volume moving average.

Taking Close:
Defines how many bars back the script uses as the reference close for directional comparison.

Risk Factor:
Controls how much current volume must exceed average volume before a climax condition is detected. Higher values create fewer but stronger signals.

Limitations:

- A climax volume bar does not guarantee a reversal.
- Strong trends can continue after a volume spike.
- Signals may appear late if the exhaustion move is already extended.
- The indicator does not include trend filters, stops, targets, or confirmation logic.
- Volume data may vary across assets, brokers, and markets.

## Source Code

````pine
//@version=6
//By @Ty_yanse
indicator("Climax Volume Reversal Radar", shorttitle="Climax Vol Radar", overlay=false)

// Inputs
showMA      = input.bool(true, title="Show Volume MA")
lengthMA    = input.int(10, minval=1, title="Volume MA Length")
takingClose = input.int(5, minval=1, title="Reference Close Bars Back")
riskFactor  = input.float(1.618, minval=0.1, step=0.001, title="Risk Factor")

// Volume average
avgVolume = ta.sma(volume, 10)
currentVolume = volume

// Climax conditions
bullishClimax = close < close[takingClose] and close < open and currentVolume > avgVolume * riskFactor
bearishClimax = close > close[takingClose] and close > open and currentVolume > avgVolume * riskFactor

// Bar colors
volumeColor = bullishClimax ? color.green : bearishClimax ? color.red : color.gray

// Plot volume columns
plot(currentVolume, title="Volume", style=plot.style_columns, color=volumeColor)

// Optional volume moving average
plot(showMA ? ta.sma(currentVolume, lengthMA) : na, title="Volume MA", color=color.black, linewidth=2)

// Alerts
alertcondition(bullishClimax, title="Bullish Climax Watch", message="Bullish climax volume detected: possible capitulation or reversal watch zone.")
alertcondition(bearishClimax, title="Bearish Climax Watch", message="Bearish climax volume detected: possible buying exhaustion or reversal watch zone.")
````
