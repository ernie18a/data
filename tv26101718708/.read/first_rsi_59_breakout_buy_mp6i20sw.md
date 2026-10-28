# First RSI 59 Breakout Buy

- url: https://www.tradingview.com/script/Mp6I20SW-First-RSI-59-Breakout-Buy/
- type: indicator
- pine_id: PUB;33eb63bada0d42558e87c55bcc636ce3
- version: 3.0

## Description

Strategy that Deterimine that stock now comes in momentum

## Source Code

````pine
//@version=6
indicator("First RSI 59 Breakout Buy", overlay = true)

// Inputs
rsiLength = input.int(14, "RSI Length")
rsiLevel  = input.float(59.0, "RSI Level")
entryPct  = input.float(0.4, "Entry % Above High", step = 0.1)

// RSI
rsi = ta.rsi(close, rsiLength)

// Variables
var bool setupFound      = false
var bool buyTriggered    = false
var bool inTrade = false

var float breakoutHigh    = na
var float breakoutHighExtend  = na
var float buyLevel        = na
var float stopLoss        = na

var line entryLine       = na
var line buyLine         = na

// Reset at start of a new day
newDay = ta.change(time("D")) != 0

if newDay
    setupFound   := false
    buyTriggered := false

    breakoutHigh := na
    breakoutHighExtend := na
    buyLevel     := na
    stopLoss    :=na

    if not na(entryLine)
        line.delete(entryLine)
        entryLine := na

    if not na(buyLine)
        line.delete(buyLine)
        buyLine := na


// First RSI cross above 59 of the day
// firstCross = ta.crossover(rsi, rsiLevel) and not setupFound
firstCross = rsi > rsiLevel and not setupFound

if firstCross
    setupFound := true
    breakoutHigh := high
    breakoutHighExtend := breakoutHigh * (1 + entryPct / 100)

    // Draw entry level line
    // if not na(entryLine)
    //     line.delete(entryLine)


// Buy condition:
// Any future candle closes above entry level
buySignal = setupFound and not buyTriggered and close > breakoutHighExtend

if buySignal
    buyTriggered := true
    buyLevel := high
    stopLoss := low - 0.5
    inTrade := true
    // if not na(buyLine)
    //     line.delete(buyLine)

// if buyTriggered and rsi < 60
//     stopLoss := low - 1


// Mark first RSI candle
plot(
    buyLevel,
    title = "Buy Level",
    color = color.green,
    linewidth = 1,
    style = plot.style_linebr
)

plot(
    stopLoss,
    title = "Stopl Level",
    color = color.red,
    linewidth = 1,
    style = plot.style_linebr
)

plotshape(
     firstCross,
     title = "RSI Setup",
     style = shape.triangleup,
     location = location.belowbar,
     color = color.orange,
     size = size.tiny,
     text = ''
)

if firstCross
    label.new(
         bar_index,
         high,
         text = str.tostring(breakoutHighExtend, format.mintick),
         style = label.style_none,
         textcolor = color.black,
         size = size.small
    )

if buySignal
    buyTriggered := true
    buyLevel := high
    stopLoss := low - 0.5

    label.new(
         bar_index,
         buyLevel,
         text = str.tostring(buyLevel, format.mintick),
         style = label.style_none,
         textcolor = color.black,
         size = size.small
    )

// // Alerts
// alertcondition(
//      firstCross,
//      title = "RSI Setup Created",
//      message = "First RSI(14) cross above 59 detected."
// )

// alertcondition(
//      buySignal,
//      title = "BUY Triggered",
//      message = "Price closed above the entry level."
// )
````
