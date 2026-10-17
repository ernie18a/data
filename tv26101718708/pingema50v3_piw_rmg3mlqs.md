# PingEMA50V.3 Piw

- url: https://www.tradingview.com/script/rmG3Mlqs-PingEMA50V-3-Piw/
- type: strategy
- pine_id: PUB;2ZgKepESFkIRRJAu5jyWIXeHQtVPVLQs
- version: 1.0

## Description

ema

## Source Code

````pine
//@version=3
strategy(title="PingEMA50V.3 Piw", shorttitle="EMA50 Piw", overlay=true)

// input
src = input(title="Data Array",type=source,defval=close)
ema_period = input(title="EMA period", type=integer,defval=50)
percent = input(title="Band %", type=float,defval=0.003)

// ema
ema50 = ema(src, ema_period)
plot(ema50, color=green)

// upper lower
upper = ema50 + (ema50*percent)
lower = ema50 - (ema50*percent)
plot(upper, color=blue)
plot(lower, color=blue)

// signal
buy = src > upper
sell = src < lower

// bar color
bcolor = buy ? lime : red
barcolor(color=bcolor)

// trade
if (buy)
    strategy.entry("long", strategy.long)
if (sell)
    strategy.close("long")
````
