# Engulfing Signal Berry Right 

- url: https://www.tradingview.com/script/HPkPcvT8-Engulfing-Signal-Berry-Right/
- type: indicator
- pine_id: PUB;264cd6dbf128437daaed2afe3daaa5ea
- version: 3.0

## Description

A simple Engulfing indicator with time signal function.

## Source Code

````pine
//@version=5
indicator("Engulfing 50% + Alerts", overlay=true)

// === INPUTS ===
startHour = input.int(8, "Start Hour", minval=0, maxval=23)
endHour   = input.int(18, "End Hour", minval=0, maxval=23)
useTime   = input.bool(true, "Use Time Filter EST")
minFactor = input.float(1.5, "Min Size Factor (1.5 = 50% groter)", step=0.1)

// === TIME FILTER ===
currentHour = hour(time)
inSession = useTime ? (currentHour >= startHour and currentHour <= endHour) : true

// === BODY SIZE ===
prevBody = math.abs(close[1] - open[1])
currBody = math.abs(close - open)

// === CANDLE TYPES ===
prevBull = close[1] > open[1]
prevBear = close[1] < open[1]
currBull = close > open
currBear = close < open

// === ENGULFING CONDITIONS ===
bullishEngulfing = prevBear and currBull and close > open[1] and open < close[1] and currBody >= prevBody * minFactor
bearishEngulfing = prevBull and currBear and close < open[1] and open > close[1] and currBody >= prevBody * minFactor

// === SIGNALS ===
bullSignal = bullishEngulfing and inSession
bearSignal = bearishEngulfing and inSession

// === PLOTS ===
plotshape(bullSignal, title="BUY", location=location.belowbar, color=color.green, style=shape.labelup, text="BUY")
plotshape(bearSignal, title="SELL", location=location.abovebar, color=color.red, style=shape.labeldown, text="SELL")

// === ALERTS ===
alertcondition(bullSignal, title="BUY Signal", message="Bullish Engulfing detected")
alertcondition(bearSignal, title="SELL Signal", message="Bearish Engulfing detected")
````
