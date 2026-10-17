# 5 EMA | 10 EMA | 15 SMA | 200 EMA

- url: https://www.tradingview.com/script/2iZP3h6p/
- type: indicator
- pine_id: PUB;dd59c58b94404bff86902e323ce25cf1
- version: 1.0

## Description

Exponential Moving Averages that smooth price data by giving more weight to recent prices, used to track market momentum and trend direction.

## Source Code

````pine
//@version=6
indicator(title="5 EMA | 10 EMA | 15 SMA | 200 EMA", shorttitle="MA Ribbon 5,10,15,200", overlay=true)

// ─── Inputs ───────────────────────────────────────────────────────────────────
src = input.source(close, title="Source")

show5ema   = input.bool(true,  title="Show 5 EMA")
show10ema  = input.bool(true,  title="Show 20 EMA")
show15sma  = input.bool(true,  title="Show 50 SMA")
show200ema = input.bool(true,  title="Show 200 EMA")

col5ema   = input.color(color.new(#00E5FF, 0),  title="5 EMA Color")
col10ema  = input.color(color.new(#8fce00, 0),  title="20 EMA Color")
col15sma  = input.color(color.new(#f6c73b, 0),  title="50 SMA Color")
col200ema = input.color(color.new(#F44336, 0),  title="200 EMA Color")

width5ema   = input.int(1, title="5 EMA Width",   minval=1, maxval=5)
width10ema  = input.int(1, title="20 EMA Width",  minval=1, maxval=5)
width15sma  = input.int(2, title="50 SMA Width",  minval=1, maxval=5)
width200ema = input.int(2, title="200 EMA Width", minval=1, maxval=5)

// ─── Calculations ─────────────────────────────────────────────────────────────
ema5   = ta.ema(src, 5)
ema10  = ta.ema(src, 20)
sma15  = ta.sma(src, 50)
ema200 = ta.ema(src, 200)

// ─── Plots ────────────────────────────────────────────────────────────────────
plot(show5ema   ? ema5   : na, title="5 EMA",   color=col5ema,   linewidth=width5ema)
plot(show10ema  ? ema10  : na, title="10 EMA",  color=col10ema,  linewidth=width10ema)
plot(show15sma  ? sma15  : na, title="15 SMA",  color=col15sma,  linewidth=width15sma)
plot(show200ema ? ema200 : na, title="200 EMA", color=col200ema, linewidth=width200ema)

// ─── Alerts ───────────────────────────────────────────────────────────────────
alertcondition(ta.crossover(src, ema200),  title="Price Crossed Above 200 EMA", message="Price crossed ABOVE 200 EMA")
alertcondition(ta.crossunder(src, ema200), title="Price Crossed Below 200 EMA", message="Price crossed BELOW 200 EMA")
alertcondition(ta.crossover(ema5, ema10),  title="5 EMA Crossed Above 20 EMA",  message="5 EMA crossed ABOVE 20 EMA — Bullish")
alertcondition(ta.crossunder(ema5, ema10), title="5 EMA Crossed Below 20 EMA",  message="5 EMA crossed BELOW 20 EMA — Bearish")
````
