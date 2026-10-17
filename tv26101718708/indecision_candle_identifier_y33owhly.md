# Indecision Candle Identifier

- url: https://www.tradingview.com/script/y33oWhlY-Indecision-Candle-Identifier/
- type: indicator
- pine_id: PUB;PsmCJNWWjEYc0GHYpwWGNrWdO2b6sdji
- version: 1.0

## Description

This script helps identify indecision candles on for better entries into trade reversals. Note that I don't believe this signal/indicator should be used as a sole basis for entering/exiting a trade. This is simply to help you have an edge in terms of your chart/candle analysis when your brain fails to keep up with your trades.

## Source Code

````pine
// Created by MichaelLe 
// Updated 05052017
// Indecision Arrows
study(title = "Indecision Candle", overlay = true)

bear=(close[1] > open[1] and open > close and open <= close[1] and open[1] <= close and open - close < close[1] - open[1] )
plotshape(bear, title= "Bearish Harami",  color=red, style=shape.triangledown)

bull=(open[1] > close[1] and close > open and close <= open[1] and close[1] <= open and close - open < open[1] - close[1] )
plotshape(bull,  title= "Bullish Harami", location=location.belowbar, color=green, style=shape.triangleup)
````
