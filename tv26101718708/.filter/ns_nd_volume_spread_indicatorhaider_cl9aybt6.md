# NS / ND Volume Spread Indicator-Haider

- url: https://www.tradingview.com/script/cL9AyBt6-NS-ND-Volume-Spread-Indicator-Haider/
- type: indicator
- pine_id: PUB;05829bdab97345a1abe353782e684dd7
- version: 1.0

## Description

This indicator analyzes candle color and compares current candle volume with the previous 3 candles.

It marks candles with:

+3 → current volume is greater than previous 3 candles
-3 → current volume is lower than previous 3 candles

Rules:

Green Candle (Bullish)
Green candle + volume higher than last 3 candles
→ Shows green +3 below candle
Green candle + volume lower than last 3 candles
→ Shows green -3 below candle
Red Candle (Bearish)
Red candle + volume higher than last 3 candles
→ Shows red +3 above candle
Red candle + volume lower than last 3 candles
→ Shows red -3 above candle

How volume comparison works:

Current candle volume is compared individually with:
previous candle volume
2nd previous candle volume
3rd previous candle volume

Example:

Current volume = 1000
Previous 3 volumes = 700, 800, 900

Since 1000 is greater than all 3 → +3

If current volume = 500
and previous 3 are 700, 800, 900
→ -3

Visual behavior:

Labels stay attached to candles
No background boxes
Only colored text is displayed
Green text for bullish candles
Red text for bearish candles

This is useful for:

spotting volume expansion
detecting weak candles
identifying possible accumulation/distribution
quick VSA-style volume reading on chart

## Source Code

````pine
//@version=5
indicator("NS / ND Volume Spread Indicator", overlay=true)

// Candle direction
isGreen = close > open
isRed   = close < open

// Calculations
volHigh3 = volume > volume[1] and volume > volume[2] and volume > volume[3]
volLow3  = volume < volume[1] and volume < volume[2] and volume < volume[3]

// Conditions
nsCondition = isRed and volHigh3
ndCondition = isGreen and volHigh3

nsConditionLow = isRed and volLow3
ndConditionLow = isGreen and volLow3

// PERFECT GLUED SHAPES
// TEXT ONLY — NO BACKGROUND

plotshape(
     series = nsCondition,
     title = "Red +3",
     text = "+3",
     style = shape.labeldown,
     location = location.abovebar,
     color = color.new(color.red, 100),
     textcolor = color.red,
     size = size.tiny)

plotshape(
     series = nsConditionLow,
     title = "Red -3",
     text = "-3",
     style = shape.labeldown,
     location = location.abovebar,
     color = color.new(color.red, 100),
     textcolor = color.red,
     size = size.tiny)

plotshape(
     series = ndCondition,
     title = "Green +3",
     text = "+3",
     style = shape.labelup,
     location = location.belowbar,
     color = color.new(color.green, 100),
     textcolor = color.green,
     size = size.tiny)

plotshape(
     series = ndConditionLow,
     title = "Green -3",
     text = "-3",
     style = shape.labelup,
     location = location.belowbar,
     color = color.new(color.green, 100),
     textcolor = color.green,
     size = size.tiny)
````
