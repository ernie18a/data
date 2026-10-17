# Reversal Signals with Profit Target and Continuation

- url: https://www.tradingview.com/script/4Oe7tJIs-Reversal-Signals-with-Profit-Target-and-Continuation/
- type: indicator
- pine_id: PUB;16d34932273c44c280f02ad75198c046
- version: 1.0

## Description

- This script now effectively signals not only potential buy and sell opportunities but also indicates when take profit levels have been reached.
- The visual cues help in making trading decisions based on price movement relative to the established take profit targets.

## Source Code

````pine
//@version=6
indicator('Reversal Signals with Profit Target and Continuation', overlay = true)

// Input parameters
maLength = input.int(14, title = 'Moving Average Length')
rsiLength = input.int(14, title = 'RSI Length')
rsiOverbought = input.int(70, title = 'RSI Overbought Level')
rsiOversold = input.int(30, title = 'RSI Oversold Level')
takeProfitRatio = input.float(3.0, title = 'Take Profit Ratio (1:3)')

// Calculate moving average and RSI
ma = ta.sma(close, maLength)
rsi = ta.rsi(close, rsiLength)

// Buy signal: RSI crosses below oversold level and price is above the moving average
buySignal = ta.crossover(rsi, rsiOversold) and close > ma
// Sell signal: RSI crosses above overbought level and price is below the moving average
sellSignal = ta.crossunder(rsi, rsiOverbought) and close < ma

// Plot buy/sell signals on chart
plotshape(buySignal, style = shape.labelup, location = location.belowbar, color = color.green, size = size.small, text = 'BUY')
plotshape(sellSignal, style = shape.labeldown, location = location.abovebar, color = color.red, size = size.small, text = 'SELL')

// Define take profit levels
var float takeProfitLong = na
var float takeProfitShort = na
var float entryPriceLong = na
var float entryPriceShort = na
var bool longActive = false
var bool shortActive = false

if buySignal
    entryPriceLong := close
    takeProfitLong := close + (close - low) * takeProfitRatio
    longActive := true

if sellSignal
    entryPriceShort := close
    takeProfitShort := close - (high - close) * takeProfitRatio
    shortActive := true

// Continuation Conditions (Only check if the trade hasn't already hit TP)
bool continueLong = false
bool continueShort = false

if longActive and not na(takeProfitLong)
    if close >= takeProfitLong
        continueLong := true
        longActive := false // Turn off tracking so it only fires once

if shortActive and not na(takeProfitShort)
    if close <= takeProfitShort
        continueShort := true
        shortActive := false // Turn off tracking so it only fires once

// Reset take profit when the signal is triggered or MA is crossed
if close < ma
    takeProfitLong := na
    entryPriceLong := na
    longActive := false

if close > ma
    takeProfitShort := na
    entryPriceShort := na
    shortActive := false

// Plot take profit levels
plot(takeProfitLong, color = color.green, title = 'Take Profit Long', style = plot.style_stepline)
plot(takeProfitShort, color = color.red, title = 'Take Profit Short', style = plot.style_stepline)

// Plot continuation signals
plotshape(continueLong, style = shape.triangledown, location = location.abovebar, color = color.blue, size = size.small, text = 'TP HIT')
plotshape(continueShort, style = shape.triangleup, location = location.belowbar, color = color.orange, size = size.small, text = 'TP HIT')
````
