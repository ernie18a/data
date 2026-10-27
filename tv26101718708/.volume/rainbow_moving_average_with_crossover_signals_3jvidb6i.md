# Rainbow Moving Average with Crossover Signals

- url: https://www.tradingview.com/script/3JVIdB6i/
- type: indicator
- pine_id: PUB;fc32fad460b443a8a6cd820eda7cde8a
- version: 2.0

## Description

Rainbow Moving Average is a trend-following indicator designed to visualize market structure, momentum shifts, and moving average alignment through a layered MA system.

This version combines multiple moving averages into a dynamic “rainbow” structure while adding automatic crossover signal detection for improved trend confirmation and timing.

## Features

* 7 configurable Moving Averages
* Supports multiple MA types:

  * EMA
  * SMA
  * HMA
  * RMA (SMMA)
  * WMA
  * VWMA
* Colored rainbow visualization for trend clarity
* Bullish crossover detection
* Bearish crossover detection
* Visual signal dots directly on the chart:

  * Green dot = bullish crossover
  * Red dot = bearish crossover
* Built-in TradingView alert conditions

## How It Works

The indicator monitors the crossover between the fast moving average (MA1) and the slower moving average (MA2).

* When MA1 crosses above MA2:

  * A green dot appears below the candle
  * Indicates potential bullish momentum

* When MA1 crosses below MA2:

  * A red dot appears above the candle
  * Indicates potential bearish momentum

The rainbow structure helps traders quickly identify:

* Trend direction
* Momentum acceleration
* Compression and expansion phases
* Potential reversals

## Best Use Cases

This indicator can be used for:

* Trend following
* Intraday trading
* Swing trading
* Momentum analysis
* Market structure confirmation

Works effectively on:

* Forex
* Indices
* Crypto
* Stocks
* Futures

## Alerts

TradingView alert conditions are included for both bullish and bearish crossover events, allowing full automation compatibility.

## Disclaimer

This indicator is intended for educational and analytical purposes only. Always use proper risk management and combine signals with additional confirmation tools before making trading decisions.

## Source Code

````pine
//@version=6
indicator(title='Rainbow Moving Average', shorttitle='Rainbow', overlay=true)

//======================================================
// COLORS
//======================================================

tColor = 50

red    = color.rgb(255, 0, 0, tColor)
orange = color.rgb(255, 127, 0, tColor)
yellow = color.rgb(255, 238, 88, tColor)
green  = color.rgb(56, 142, 60, tColor)
blue   = color.rgb(32, 32, 255, tColor)
indigo = color.rgb(127, 32, 127, tColor)
violet = color.rgb(255, 0, 255, tColor)

//======================================================
// SOURCE
//======================================================

src = input.source(close, title="Source")

//======================================================
// LENGTHS
//======================================================

ma1Len = input.int(6, minval=1, title='MA 1 Length')
ma2Len = input.int(12, minval=1, title='MA 2 Length')
ma3Len = input.int(24, minval=1, title='MA 3 Length')
ma4Len = input.int(48, minval=1, title='MA 4 Length')
ma5Len = input.int(96, minval=1, title='MA 5 Length')
ma6Len = input.int(144, minval=1, title='MA 6 Length')
ma7Len = input.int(192, minval=1, title='MA 7 Length')

//======================================================
// MA TYPE
//======================================================

maTypeInput = input.string(
     "EMA",
     title="MA Type",
     options=["SMA", "EMA", "HMA", "SMMA (RMA)", "WMA", "VWMA"],
     group="MA Settings"
)

ma(source, length, type) =>
    switch type
        "SMA" => ta.sma(source, length)
        "EMA" => ta.ema(source, length)
        "HMA" => ta.hma(source, length)
        "SMMA (RMA)" => ta.rma(source, length)
        "WMA" => ta.wma(source, length)
        "VWMA" => ta.vwma(source, length)

//======================================================
// MOVING AVERAGES
//======================================================

ma1 = ma(src, ma1Len, maTypeInput)
ma2 = ma(src, ma2Len, maTypeInput)
ma3 = ma(src, ma3Len, maTypeInput)
ma4 = ma(src, ma4Len, maTypeInput)
ma5 = ma(src, ma5Len, maTypeInput)
ma6 = ma(src, ma6Len, maTypeInput)
ma7 = ma(src, ma7Len, maTypeInput)

//======================================================
// FILLS
//======================================================

tFill = 90

redFill    = color.new(red, tFill)
orangeFill = color.new(orange, tFill)
yellowFill = color.new(yellow, tFill)
greenFill  = color.new(green, tFill)
blueFill   = color.new(blue, tFill)
indigoFill = color.new(indigo, tFill)
violetFill = color.new(violet, tFill)

//======================================================
// PLOTS
//======================================================

p1 = plot(ma1, color=violet, linewidth=1, title='MA 1')
p2 = plot(ma2, color=indigo, linewidth=1, title='MA 2')
p3 = plot(ma3, color=blue, linewidth=2, title='MA 3')
p4 = plot(ma4, color=green, linewidth=2, title='MA 4')
p5 = plot(ma5, color=yellow, linewidth=2, title='MA 5')
p6 = plot(ma6, color=orange, linewidth=2, title='MA 6')
p7 = plot(ma7, color=red, linewidth=2, title='MA 7')

//======================================================
// FILLS
//======================================================

fill(p1, p2, indigoFill, title='Fill 1/2')
fill(p2, p3, blueFill, title='Fill 2/3')
fill(p3, p4, greenFill, title='Fill 3/4')
fill(p4, p5, yellowFill, title='Fill 4/5')
fill(p5, p6, orangeFill, title='Fill 5/6')
fill(p6, p7, redFill, title='Fill 6/7')

//======================================================
// CROSS SETTINGS
//======================================================

crossMA1 = input.string(
     "MA 1",
     title="Fast MA",
     options=["MA 1","MA 2","MA 3","MA 4","MA 5","MA 6","MA 7"],
     group="Cross Signals"
)

crossMA2 = input.string(
     "MA 2",
     title="Slow MA",
     options=["MA 1","MA 2","MA 3","MA 4","MA 5","MA 6","MA 7"],
     group="Cross Signals"
)

showBull = input.bool(true, "Show Bullish Crosses", group="Cross Signals")
showBear = input.bool(true, "Show Bearish Crosses", group="Cross Signals")

//======================================================
// SELECTED MA
//======================================================

getMA(maName) =>
    switch maName
        "MA 1" => ma1
        "MA 2" => ma2
        "MA 3" => ma3
        "MA 4" => ma4
        "MA 5" => ma5
        "MA 6" => ma6
        "MA 7" => ma7

selectedMA1 = getMA(crossMA1)
selectedMA2 = getMA(crossMA2)

//======================================================
// CROSS DETECTION
//======================================================

bullCross = ta.crossover(selectedMA1, selectedMA2)
bearCross = ta.crossunder(selectedMA1, selectedMA2)

crossLevel = (selectedMA1 + selectedMA2) / 2

//======================================================
// SIGNAL PLOTS
//======================================================

plotshape(
     showBull and bullCross ? crossLevel : na,
     title="Bullish Cross",
     style=shape.circle,
     location=location.absolute,
     color=color.lime,
     size=size.tiny
)

plotshape(
     showBear and bearCross ? crossLevel : na,
     title="Bearish Cross",
     style=shape.circle,
     location=location.absolute,
     color=color.red,
     size=size.tiny
)

//======================================================
// ALERTS
//======================================================

alertcondition(
     bullCross,
     title="Bullish MA Cross",
     message="Bullish crossover detected between selected moving averages"
)

alertcondition(
     bearCross,
     title="Bearish MA Cross",
     message="Bearish crossover detected between selected moving averages"
)
````
