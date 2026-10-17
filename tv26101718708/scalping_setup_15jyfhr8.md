# Scalping Setup

- url: https://www.tradingview.com/script/15JyFHR8-Scalping-Setup/
- type: indicator
- pine_id: PUB;349512a8d6fc4027a535e29ab6ea957a
- version: 1.0

## Description

test for SMA cross over, take buy trade when the green line and take sell trade when the red line

## Source Code

````pine
//@version=5
indicator("SMA Cross Scalping Setup", overlay=true)

// ======================
// INPUTS
// ======================
showLines      = input.bool(true, title="Show Buy/Sell Lines")
maxCandleSize  = input.float(5.0, title="Maximum Signal Candle Size", step=0.1)

stopLossPts    = input.float(3.0, title="Stop Loss Points", step=0.1)
targetPts      = input.float(3.0, title="Target Points", step=0.1)

// ======================
// SMA CALCULATIONS
// ======================
sma3  = ta.sma(close, 3)
sma10 = ta.sma(close, 10)

// ======================
// CANDLE SIZE FILTER
// ======================
candleSize = high - low

// ======================
// CROSS CONDITIONS
// ======================
bullishCrossRaw = ta.crossover(sma3, sma10)
bearishCrossRaw = ta.crossunder(sma3, sma10)

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
var line buyEntryLine  = na
var line buySLLine     = na
var line buyTPLine     = na

var line sellEntryLine = na
var line sellSLLine    = na
var line sellTPLine    = na

// ======================
// BUY SETUP
// ======================
if bullishCross and showLines

    // Delete old buy lines
    if buyEntryLine != na
        line.delete(buyEntryLine)

    if buySLLine != na
        line.delete(buySLLine)

    if buyTPLine != na
        line.delete(buyTPLine)

    // Prices
    buyEntry = high
    buySL    = buyEntry - stopLossPts
    buyTP    = buyEntry + targetPts

    // Entry Line
    buyEntryLine := line.new(
         bar_index,
         buyEntry,
         bar_index + 100,
         buyEntry,
         extend=extend.right,
         color=color.green,
         width=2)

    // SL Line
    buySLLine := line.new(
         bar_index,
         buySL,
         bar_index + 100,
         buySL,
         extend=extend.right,
         color=color.red,
         style=line.style_dashed)

    // TP Line
    buyTPLine := line.new(
         bar_index,
         buyTP,
         bar_index + 100,
         buyTP,
         extend=extend.right,
         color=color.blue,
         style=line.style_dashed)

// ======================
// SELL SETUP
// ======================
if bearishCross and showLines

    // Delete old sell lines
    if sellEntryLine != na
        line.delete(sellEntryLine)

    if sellSLLine != na
        line.delete(sellSLLine)

    if sellTPLine != na
        line.delete(sellTPLine)

    // Prices
    sellEntry = low
    sellSL    = sellEntry + stopLossPts
    sellTP    = sellEntry - targetPts

    // Entry Line
    sellEntryLine := line.new(
         bar_index,
         sellEntry,
         bar_index + 100,
         sellEntry,
         extend=extend.right,
         color=color.red,
         width=2)

    // SL Line
    sellSLLine := line.new(
         bar_index,
         sellSL,
         bar_index + 100,
         sellSL,
         extend=extend.right,
         color=color.red,
         style=line.style_dashed)

    // TP Line
    sellTPLine := line.new(
         bar_index,
         sellTP,
         bar_index + 100,
         sellTP,
         extend=extend.right,
         color=color.blue,
         style=line.style_dashed)
````
