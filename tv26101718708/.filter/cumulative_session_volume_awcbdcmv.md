# Cumulative Session Volume

- url: https://www.tradingview.com/script/aWcbdcmV-Cumulative-Session-Volume/
- type: indicator
- pine_id: PUB;55a09332f4504cdfad010a2bc289290b
- version: 1.0

## Description

Cumulative volume for intraday session. Displays histogram of cumulative volume of all timeframe sessions intraday.

## Source Code

````pine
//@version=5
indicator("Cumulative Session Volume", overlay=false)

// Detect a new session (resets the accumulator)
newSession = ta.change(time("D")) != 0

// Running cumulative volume, reset at each new session
var float cumVol = 0.0
cumVol := newSession ? volume : cumVol + volume

// Color bars to match candle direction
barColor = close >= open ? color.new(color.green, 30) : color.new(color.red, 30)

plot(cumVol, style=plot.style_columns, color=barColor, title="Cumulative Volume")
````
