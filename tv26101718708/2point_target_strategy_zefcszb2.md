# 2Point Target Strategy

- url: https://www.tradingview.com/script/ZEFCszb2-2Point-Target-Strategy/
- type: indicator
- pine_id: PUB;960e2aa0c15148069e2bc523b95ca902
- version: 1.0

## Description

Buy and Sell Signals will show based on the candle size which will be taking from settings
Recent Buy & Sell lines can be enabled from Settings

## Source Code

````pine
//@version=5
indicator("2Point Target Strategy", overlay=true)

// ======================
// INPUTS
// ======================
showLines      = input.bool(true, title="Show Buy/Sell Lines")
maxCandleSize  = input.float(5.0, title="Maximum Signal Candle Size", step=0.1)

// ======================
// SMA CALCULATIONS
// ======================
sma3  = ta.sma(close, 3)
sma10 = ta.sma(close, 10)

// ======================
// CANDLE SIZE
// ======================
candleSize = high - low

// ======================
// CROSS CONDITIONS
// ======================
bullishCrossRaw = ta.crossover(sma3, sma10)
bearishCrossRaw = ta.crossunder(sma3, sma10)

// Apply candle size filter
bullishCross = bullishCrossRaw and candleSize <= maxCandleSize
bearishCross = bearishCrossRaw and candleSize <= maxCandleSize

// ======================
// SIGNAL ARROWS
// ======================
plotshape(
     bullishCross,
     location=location.belowbar,
     style=shape.arrowup,
     color=color.green,
     size=size.small)

plotshape(
     bearishCross,
     location=location.abovebar,
     style=shape.arrowdown,
     color=color.red,
     size=size.small)

// ======================
// LINE VARIABLES
// ======================
var line buyLine = na
var line sellLine = na

// ======================
// BUY SIGNAL LINE
// ======================
if bullishCross and showLines

    // Delete previous buy line
    if buyLine != na
        line.delete(buyLine)

    // Draw new buy line
    buyLine := line.new(
         bar_index,
         high,
         bar_index + 100,
         high,
         extend=extend.right,
         color=color.green,
         width=2)

// ======================
// SELL SIGNAL LINE
// ======================
if bearishCross and showLines

    // Delete previous sell line
    if sellLine != na
        line.delete(sellLine)

    // Draw new sell line
    sellLine := line.new(
         bar_index,
         low,
         bar_index + 100,
         low,
         extend=extend.right,
         color=color.red,
         width=2)
````
