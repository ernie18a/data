# SITREP EMA's 13/48/200

- url: https://www.tradingview.com/script/Ru3IVxmC-SITREP-EMA-s-13-48-200/
- type: indicator
- pine_id: PUB;175a2046883e4cb3a03f54daee052e58
- version: 1.0

## Description

3 ema's 13/48/200. Yellow is 13 , purple is 48 and red is 200. EMA's

## Source Code

````pine
//@version=6
indicator("SITREP EMA's 13/48/200", shorttitle="SITREP·EMA", overlay=true)

ema13  = ta.ema(close, 13)
ema48  = ta.ema(close, 48)
ema200 = ta.ema(close, 200)

plot(ema13,  "EMA 13",  color=color.yellow, linewidth=2)
plot(ema48,  "EMA 48",  color=color.purple, linewidth=2)
plot(ema200, "EMA 200", color=color.red,    linewidth=2)
````
