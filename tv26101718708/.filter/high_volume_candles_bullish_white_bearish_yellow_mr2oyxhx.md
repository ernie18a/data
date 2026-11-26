# High Volume Candles - Bullish White Bearish Yellow

- url: https://www.tradingview.com/script/Mr2oYxHx-High-Volume-Candles-Bullish-White-Bearish-Yellow/
- type: indicator
- pine_id: PUB;46a05f2f040b4fa395d2330cfe3b8670
- version: 1.0

## Description

This indicator highlights candles where volume is above the 50-period volume moving average, making it easier to identify periods of increased market activity. Bullish high-volume candles are coloured white, while bearish high-volume candles are coloured yellow, allowing traders to quickly spot significant buying or selling pressure on the chart. The purpose of this indicator is to simplify the process of drawing algo lines by making key high-volume candles more visible, helping traders identify important price areas, potential reaction zones, and levels where algorithmic activity may be present.

## Source Code

````pine
//@version=6
indicator("High Volume Candles - Bullish White Bearish Yellow", overlay=true)

// Calculate 50-period moving average of volume
volMA = ta.sma(volume, 50)

// Check if current candle volume is above the 50 volume moving average
highVolume = volume > volMA

// Check if candle is bullish or bearish
bullishCandle = close > open
bearishCandle = close < open

// Choose candle colour
candleColour = highVolume and bullishCandle ? color.white : highVolume and bearishCandle ? color.yellow : na

// Apply candle colour
barcolor(candleColour)
````
