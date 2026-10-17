# 5 EMA | 10 EMA | 15 SMA | 200 EMA

- url: https://www.tradingview.com/script/ioOZy6TG/
- type: indicator
- pine_id: PUB;579c6fe4e4c24073806261d9054552ee
- version: 1.0

## Description

EMA 5‑10‑15‑200 = Exponential Moving Averages that smooth price data by giving more weight to recent prices, used to track market momentum and trend direction.

## Source Code

````pine
//@version=6
indicator(title="5 EMA | 10 EMA | 15 SMA | 200 EMA", shorttitle="MA Ribbon 5,10,15,200", overlay=true)

// ─── Inputs ───────────────────────────────────────────────────────────────────
src = input.source(close, title="Source")

show5ema   = input.bool(true,  title="Show 5 EMA")
show10ema  = input.bool(true,  title="Show 10 EMA")
show15sma  = input.bool(true,  title="Show 15 SMA")
show200ema = input.bool(true,  title="Show 200 EMA")

col5ema   = input.color(color.new(#00E5FF, 0),  title="5 EMA Color")
col10ema  = input.color(color.new(#8fce00, 0),  title="10 EMA Color")
col15sma  = input.color(color.new(#f6c73b, 0),  title="15 EMA Color")
col200ema = input.color(color.new(#F44336, 0),  title="200 EMA Color")

width5ema   = input.int(1, title="5 EMA Width",   minval=1, maxval=5)
width10ema  = input.int(1, title="10 EMA Width",  minval=1, maxval=5)
width15sma  = input.int(2, title="15 SMA Width",  minval=1, maxval=5)
width200ema = input.int(2, title="200 EMA Width", minval=1, maxval=5)

// ─── Calculations ─────────────────────────────────────────────────────────────
ema5   = ta.ema(src, 5)
ema10  = ta.ema(src, 10)
sma15  = ta.sma(src, 15)
ema200 = ta.ema(src, 200)

// ─── Plots ────────────────────────────────────────────────────────────────────
plot(show5ema   ? ema5   : na, title="5 EMA",   color=col5ema,   linewidth=width5ema)
plot(show10ema  ? ema10  : na, title="10 EMA",  color=col10ema,  linewidth=width10ema)
plot(show15sma  ? sma15  : na, title="15 SMA",  color=col15sma,  linewidth=width15sma)
plot(show200ema ? ema200 : na, title="200 EMA", color=col200ema, linewidth=width200ema)

// ─── Alerts ───────────────────────────────────────────────────────────────────

// BULLISH — EMA 5 crosses above SMA 15
alertcondition(
     ta.crossover(ema5, sma15),
     title="Bullish Signal — EMA 5 Above SMA 15",
     message="EMA 5 crossed ABOVE SMA 15 — Bullish momentum shift"
)

// BEARISH — EMA 5 crosses below SMA 15
alertcondition(
     ta.crossunder(ema5, sma15),
     title="Bearish Signal — EMA 5 Below SMA 15",
     message="EMA 5 crossed BELOW SMA 15 — Bearish momentum shift"
)
````
