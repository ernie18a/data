# Same Direction FVG Highlighter

- url: https://www.tradingview.com/script/aKE7g6SH-Same-Direction-FVG-Highlighter/
- type: indicator
- pine_id: PUB;1acbe317ae8b411f9b2d51d5d6007999
- version: 1.0

## Description

This indicator highlights bullish and bearish Fair Value Gaps when all 3 candles move in the same direction. A bullish FVG appears when all 3 candles are bullish, and a bearish FVG appears when all 3 candles are bearish. You can choose how far the highlighted zone extends to the left and right of the gap.

## Source Code

````pine
//@version=5
indicator("Same Candle FVG Highlighter", overlay=true, max_boxes_count=500)

// === Inputs ===
showBullishFVG = input.bool(true, "Show Bullish FVG")
showBearishFVG = input.bool(true, "Show Bearish FVG")

bullishColor = input.color(color.new(color.green, 80), "Bullish FVG Color")
bearishColor = input.color(color.new(color.red, 80), "Bearish FVG Color")

extendBackBars = input.int(0, "Extend Highlight Back Bars", minval=0, maxval=500)
extendFrontBars = input.int(20, "Extend Highlight Front Bars", minval=1, maxval=500)

// === Candle Direction ===
candle1Bullish = close[2] > open[2]
candle2Bullish = close[1] > open[1]
candle3Bullish = close > open

candle1Bearish = close[2] < open[2]
candle2Bearish = close[1] < open[1]
candle3Bearish = close < open

threeBullishCandles = candle1Bullish and candle2Bullish and candle3Bullish
threeBearishCandles = candle1Bearish and candle2Bearish and candle3Bearish

// === FVG Logic ===
// Bullish FVG: candle 3 low is above candle 1 high
bullishFVG = threeBullishCandles and low > high[2]

// Bearish FVG: candle 3 high is below candle 1 low
bearishFVG = threeBearishCandles and high < low[2]

// === Box Positions ===
boxLeft = bar_index[2] - extendBackBars
boxRight = bar_index + extendFrontBars

// === Draw Bullish FVG ===
if bullishFVG and showBullishFVG
    box.new(
         left=boxLeft,
         right=boxRight,
         top=low,
         bottom=high[2],
         bgcolor=bullishColor,
         border_color=color.new(color.green, 30)
     )

// === Draw Bearish FVG ===
if bearishFVG and showBearishFVG
    box.new(
         left=boxLeft,
         right=boxRight,
         top=low[2],
         bottom=high,
         bgcolor=bearishColor,
         border_color=color.new(color.red, 30)
     )

// === Alerts ===
alertcondition(bullishFVG, title="Bullish FVG", message="Bullish FVG detected with 3 bullish candles")
alertcondition(bearishFVG, title="Bearish FVG", message="Bearish FVG detected with 3 bearish candles")
````
