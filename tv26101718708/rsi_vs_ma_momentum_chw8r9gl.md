# RSI vs MA Momentum

- url: https://www.tradingview.com/script/CHw8R9GL-RSI-vs-MA-Momentum/
- type: indicator
- pine_id: PUB;c7310526b3ef41dd883f2f357c48207d
- version: 1.0

## Description

Rsi vs MA momentum tracking the Relative strength index tryout

## Source Code

````pine
//@version=6
indicator("RSI vs MA Momentum", overlay=false)

rsiLen = input.int(15, "RSI Length")
maLen  = input.int(5, "MA Length")

rsi = ta.rsi(close, rsiLen)
ma  = ta.sma(rsi, maLen)

diff = rsi - ma

histColor = diff >= 0 ? color.lime : color.red

plot(diff,
     style=plot.style_area,
     color=histColor,
     linewidth=2)

plot(0, color=color.white, linewidth=2)
plot(ta.sma(diff, 3), color=color.black, linewidth=2)
````
