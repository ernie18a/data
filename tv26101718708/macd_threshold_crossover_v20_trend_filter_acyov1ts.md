# MACD Threshold Crossover v2.0 Trend Filter

- url: https://www.tradingview.com/script/acYOV1tS-MACD-Threshold-Crossover-v2-0-Trend-Filter/
- type: indicator
- pine_id: PUB;be2d8ae3047b4f8fa409e0ba7e02037e
- version: 2.0

## Description

This is a script to bring 'Buy' and 'Sell' signals, which can also be used for alerts, for when the MACD fast and slow lines cross.

A 'Buy' signal prints when the fast MACD crosses above the slow MACD (a distance of at least 0.00003), whilst being below the MACD 0 level (w/ 0.00015 margin).

A 'Sell' signal prints when the fast MACD crosses below the slow MACD (a distance of at least -0.00003) whilst being above the MACD 0 level (w/ 0.00015 margin).

Furthermore Buy signals are only valid if candle closes above the 200EMA. Likewise Sell signals are only valid if candle closes below the 200 EMA, and all other conditions are met.

## Source Code

````pine
//@version=6
indicator("MACD Threshold Crossover v2.1 Trend Filter - No Delayed Signals", overlay=true, precision=5)

// --- Inputs ---
fastLenInput = input.int(12, "Fast length", minval=1)
slowLenInput = input.int(26, "Slow length", minval=1)
sigLenInput  = input.int(9, "Signal length", minval=1)

// Threshold Inputs
buyMaxLevel  = input.float(0.00015, "Buy Max MACD Level")
sellMinLevel = input.float(-0.00015, "Sell Min MACD Level")
minDistance  = input.float(0.00003, "Min Cross Distance Threshold")

// --- Hardcoded Internal Variables ---
roundStep = 0.00001
eps       = 0.0000000001

// --- MACD & EMA Calculations ---
fastMA = ta.ema(close, fastLenInput)
slowMA = ta.ema(close, slowLenInput)

macdLine   = fastMA - slowMA
signalLine = ta.ema(macdLine, sigLenInput)

// Calculate the 200 Exponential Moving Average
ema200 = ta.ema(close, 200)

// --- Helper ---
roundToStep(x, step) =>
    step > 0 ? math.round(x / step) * step : x

// Round the values the same way you are visually reading them
macdRounded   = roundToStep(macdLine, roundStep)
signalRounded = roundToStep(signalLine, roundStep)

diff = macdRounded - signalRounded

// --- Cycle Arming Logic ---
var bool sellArmed = false
var bool buyArmed  = false

if barstate.isconfirmed
    if diff >= 0
        sellArmed := true

    if diff <= 0
        buyArmed := true

// --- Trend Filter Conditions ---
priceAboveEma200 = close > ema200
priceBelowEma200 = close < ema200

// --- MACD Threshold Trigger Logic ---
// These are the actual one-time MACD trigger events.
// They happen whether or not the EMA filter allows the signal.
sellThresholdHit = barstate.isconfirmed and sellArmed and diff <= -minDistance + eps
buyThresholdHit  = barstate.isconfirmed and buyArmed and diff >= minDistance - eps

// --- Final Signal Logic ---
// Signal only prints if the threshold trigger happens on the correct side of the 200 EMA.
sellSignal = sellThresholdHit and macdRounded >= sellMinLevel and priceBelowEma200
buySignal  = buyThresholdHit and macdRounded <= buyMaxLevel and priceAboveEma200

// Disarm after the threshold trigger happens, not after the signal prints.
// This prevents delayed EMA-filtered signals.
if sellThresholdHit
    sellArmed := false

if buyThresholdHit
    buyArmed := false

// --- Plotting Technical Lines ---
plot(ema200, title="200 EMA", color=color.blue, linewidth=2)

// --- Plotting Labels ---
plotshape(
     buySignal,
     title="Buy",
     text="Buy",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     textcolor=color.white,
     size=size.tiny
 )

plotshape(
     sellSignal,
     title="Sell",
     text="Sell",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     textcolor=color.white,
     size=size.tiny
 )

// Debug values in the Data Window
plot(diff, title="Rounded MACD - Signal Distance", display=display.data_window)
plot(math.abs(macdLine - signalLine), title="Raw Distance", display=display.data_window)

// --- Alerts ---
alertcondition(buySignal, "Buy Signal", "Confirmed MACD Bullish Threshold Cross")
alertcondition(sellSignal, "Sell Signal", "Confirmed MACD Bearish Threshold Cross")
````
