# RH MAs

- url: https://www.tradingview.com/script/iFB5jRW1-RH-MAs/
- type: indicator
- pine_id: PUB;c5871e8a5303473094125a9b25a2a47e
- version: 1.0

## Description

moving averages public.  this is for my trade analysis dashboard

## Source Code

````pine
//@version=5
indicator("RH MAs", overlay=true)
plot(ta.ema(close, 21), color=color.blue, linewidth=1, title="21 EMA")
plot(ta.sma(close, 50), color=color.orange, linewidth=2, title="50 MA")
plot(ta.sma(close, 200), color=color.red, linewidth=2, title="200 MA")
````
