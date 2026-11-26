# EMAs + VWAP

- url: https://www.tradingview.com/script/lQenC2RE-EMAs-VWAP/
- type: indicator
- pine_id: PUB;02a4244a950a4bbfbf707d80ee50e5dc
- version: 1.0

## Description

This indicator will add the 9, 20, 50, and 200 EMA, as well as VWAP, to your chart.

The EMAs can be adjusted to any number and color. 

I grew tired of adding 4 different EMAs and VWAP to my charts, so I added them all to 1 indicator.

## Source Code

````pine
//@version=6
indicator(title="EMAs + VWAP", shorttitle="EMA/VWAP", overlay=true)

// ── EMAs ──────────────────────────────────────────────────────────────────────
ema9   = ta.ema(close, 9)
ema20  = ta.ema(close, 20)
ema50  = ta.ema(close, 50)
ema200 = ta.ema(close, 200)

plot(ema9,   title="9 EMA",   color=color.blue,  linewidth=1)
plot(ema20,  title="20 EMA",  color=color.green,  linewidth=1)
plot(ema50,  title="50 EMA",  color=color.black,  linewidth=1)
plot(ema200, title="200 EMA", color=color.red,    linewidth=2)

// ── VWAP ──────────────────────────────────────────────────────────────────────
plot(ta.vwap, title="VWAP", color=color.orange, linewidth=2)
````
