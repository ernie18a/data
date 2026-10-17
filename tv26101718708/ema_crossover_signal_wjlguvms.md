# EMA Crossover Signal

- url: https://www.tradingview.com/script/wJlgUvmS-EMA-Crossover-Signal/
- type: indicator
- pine_id: PUB;029cd7934015429daf251e46878109c8
- version: 1.0

## Description

this is the best ema crossover signal.I know what I'm doing and this is a good script I use this daily.

## Source Code

````pine
//@version=5
indicator("EMA Crossover Signal", overlay=true)

// --- Inputs ---
fastLen = input.int(9, title="Fast EMA Length")
slowLen = input.int(21, title="Slow EMA Length")

// --- Calculations ---
fastEMA = ta.ema(close, fastLen)
slowEMA = ta.ema(close, slowLen)

// --- Crossover Logic ---
longCondition  = ta.crossover(fastEMA, slowEMA)
shortCondition = ta.crossunder(fastEMA, slowEMA)

// --- Plotting ---
plot(fastEMA, color=color.blue, title="Fast EMA")
plot(slowEMA, color=color.orange, title="Slow EMA")

plotshape(series=longCondition, title="Long Signal", location=location.belowbar, color=color.green, style=shape.labelup, text="BUY")
plotshape(series=shortCondition, title="Short Signal", location=location.abovebar, color=color.red, style=shape.labeldown, text="SELL")

// --- Alerts ---
alertcondition(longCondition, title="Long Alert", message="EMA Crossover BUY")
alertcondition(shortCondition, title="Short Alert", message="EMA Crossunder SELL")
````
