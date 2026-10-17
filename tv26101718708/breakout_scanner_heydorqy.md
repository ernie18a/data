# Breakout Scanner

- url: https://www.tradingview.com/script/hEyDoRqY-Breakout-Scanner/
- type: indicator
- pine_id: PUB;52894ef54b4449ff87836e4aa53f5382
- version: 1.0

## Description

a scanner that indicates where it is best to buy in a trend (it is best to look in the higher TF and place an entry in a lower TF) (always use a stop loss)

## Source Code

````pine
//@version=6
indicator("Breakout Scanner", overlay=true)

// EMA's
ema50 = ta.ema(close, 50)
ema200 = ta.ema(close, 200)

// Plot EMA's
plot(ema50, color=color.blue)
plot(ema200, color=color.red)

// Levels
lookback = 10
highestLevel = ta.highest(high, lookback)
lowestLevel = ta.lowest(low, lookback)

// Breakouts
breakUp = close > highestLevel[1]
breakDown = close < lowestLevel[1]

// Signals
plotshape(series=breakUp, title="BUY", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)

plotshape(series=breakDown, title="SELL", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)

// Labels
if breakUp
    label.new(bar_index, low, "BUY", style=label.style_label_up, color=color.green, textcolor=color.white)

    if breakDown
        label.new(bar_index, high, "SELL", style=label.style_label_down, color=color.red, textcolor=color.white)
````
