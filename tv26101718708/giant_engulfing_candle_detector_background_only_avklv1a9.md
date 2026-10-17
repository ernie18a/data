# Giant Engulfing Candle Detector (Background Only)

- url: https://www.tradingview.com/script/avKlv1A9-Giant-Engulfing-Candle-Detector-Background-Only/
- type: indicator
- pine_id: PUB;6caba33073e84ed2afc7e24fde7e4907
- version: 1.0

## Description

This script allows finding quick scalps but this isn't recommended for buying in or selling. This indicator just provides the information of strong buying vs strong selling.

## Source Code

````pine
//@version=6
indicator("Giant Engulfing Candle Detector (Background Only)", overlay=true)

// === Inputs ===
length = input.int(20, "Average Candle Length")
multiplier = input.float(1.5, "Size Multiplier", step=0.1)

// === Candle calculations ===
body = math.abs(close - open)
avgBody = ta.sma(body, length)

// Previous candle values
prevOpen = open[1]
prevClose = close[1]

// === Bullish Engulfing ===
bullishEngulf = (
    close > open and
    prevClose < prevOpen and
    close > prevOpen and
    open < prevClose and
    body > avgBody * multiplier
)

// === Bearish Engulfing ===
bearishEngulf = (
    close < open and
    prevClose > prevOpen and
    open > prevClose and
    close < prevOpen and
    body > avgBody * multiplier
)

// === Background highlight ONLY ===
bgcolor(bullishEngulf ? color.new(color.green, 85) : na)
bgcolor(bearishEngulf ? color.new(color.red, 85) : na)
````
