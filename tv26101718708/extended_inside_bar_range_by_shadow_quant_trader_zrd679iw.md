# Extended Inside Bar Range (by Shadow Quant Trader)

- url: https://www.tradingview.com/script/ZRD679iW-Extended-Inside-Bar-Range-by-Shadow-Quant-Trader/
- type: indicator
- pine_id: PUB;06643bfdd73b4b21afd6a8ad44a06879
- version: 1.0

## Description

This indicator identifies and highlights extended inside bar structures based on a single mother candle.

Unlike traditional inside bar indicators that only mark the immediate inside candle, this script tracks the entire consolidation range defined by the mother candle and highlights all subsequent candles that remain within its high–low range.

🔶 Key Features:

Detects the initial mother candle
Highlights all candles inside the mother candle range
Continues marking candles until a breakout occurs
Ignores nested inside bars and maintains the original range
Helps visualize price compression and breakout zones

🔶 How it works:

When an inside bar is detected, the previous candle becomes the mother candle
All following candles are marked as long as they remain within that range
The sequence ends only when price breaks above or below the mother candle

🔶 Use Cases:

Identify consolidation before breakouts
Spot volatility contraction setups
Improve price action analysis
Credits:

Developed by Shadow Quant Trader

## Source Code

````pine
//@version=5
indicator("Extended Inside Bar Range", overlay=true)

// Variables to track mother candle
var float motherHigh = na
var float motherLow = na
var bool inRange = false

// Step 1: Detect new mother candle
isInside = high <= high[1] and low >= low[1]

// If NOT currently tracking a range
if not inRange
    if isInside
        motherHigh := high[1]
        motherLow := low[1]
        inRange := true

// Step 2: Continue tracking range
else
    // Check if still inside mother candle
    if high <= motherHigh and low >= motherLow
        inRange := true
    else
        // Breakout → reset
        inRange := false
        motherHigh := na
        motherLow := na

// Step 3: Color candles
barcolor(inRange ? color.orange : na)
````
