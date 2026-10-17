# goldsiggy-murk

- url: https://www.tradingview.com/script/Ni6R0VfQ-goldsiggy-murk/
- type: indicator
- pine_id: PUB;e2c82c5a81c34940ab6032acd1899fee
- version: 1.0

## Description

use 40-50 pip stop loss 
do not take signals when the market is not trending 
my tel: itmurk

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mehranazizi219

//@version=6
indicator("Buy-Sell", overlay=true)

// =======================
// EMAs
// =======================
ema8  = ta.ema(close, 8)
ema50 = ta.ema(close, 50)

// =======================
// Cross
// =======================
bullCross = ta.crossover(ema8, ema50)
bearCross = ta.crossunder(ema8, ema50)

// =======================
// State
// =======================
var int trend = 0
var int crossBar = na

var bool signalGiven = false

if bullCross
    trend := 1
    crossBar := bar_index
    signalGiven := false

if bearCross
    trend := -1
    crossBar := bar_index
    signalGiven := false

// =======================
// Only after cross
// =======================
valid = not na(crossBar) and bar_index > crossBar

// =======================
// Rejection Candle Logic (IMPORTANT)
// =======================
// bullish rejection = wick below EMA and close strong up
bullRejection8  = low <= ema8  and close > open
bullRejection50 = low <= ema50 and close > open

// bearish rejection = wick above EMA and close strong down
bearRejection8  = high >= ema8  and close < open
bearRejection50 = high >= ema50 and close < open

// =======================
// Signals (ONLY ONE PER CROSS)
// =======================
buySignal  = trend == 1 and valid and not signalGiven and (bullRejection8 or bullRejection50)
sellSignal = trend == -1 and valid and not signalGiven and (bearRejection8 or bearRejection50)

if buySignal or sellSignal
    signalGiven := true

// =======================
// Plot ONLY BUY/SELL
// =======================
plotshape(buySignal, title="BUY", location=location.belowbar,
     color=color.green, style=shape.labelup, text="BUY")

plotshape(sellSignal, title="SELL", location=location.abovebar,
     color=color.red, style=shape.labeldown, text="SELL")

// =======================
// Alerts
// =======================
alertcondition(buySignal, title="BUY Signal", message="BUY Signal (EMA Pullback PRO)")
alertcondition(sellSignal, title="SELL Signal", message="SELL Signal (EMA Pullback PRO)")
````
