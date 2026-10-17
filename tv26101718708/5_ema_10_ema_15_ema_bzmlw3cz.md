# 5 EMA | 10 EMA | 15 EMA

- url: https://www.tradingview.com/script/bzMlw3cz/
- type: indicator
- pine_id: PUB;d1774783948e4cab8f057b83ac94bb4d
- version: 3.0

## Description

EMA 5‑10‑15 provide a fast multi‑layer view of short‑term trend strength and momentum shifts, ideal for intraday trading

## Source Code

````pine
//@version=6
indicator(title="5 EMA | 10 EMA | 15 SMA", shorttitle="MA Ribbon 5,10,15", overlay=true)

// ─── Inputs ───────────────────────────────────────────────────────────────────
src = input.source(close, title="Source")

show5ema   = input.bool(true,  title="Show 5 EMA")
show10ema  = input.bool(true,  title="Show 10 EMA")
show15sma  = input.bool(true,  title="Show 15 SMA")

col5ema   = input.color(color.new(#00E5FF, 0),  title="5 EMA Color")
col10ema  = input.color(color.new(#8fce00, 0),  title="10 EMA Color")
col15sma  = input.color(color.new(#f6c73b, 0),  title="15 SMA Color")

width5ema   = input.int(1, title="5 EMA Width",   minval=1, maxval=5)
width10ema  = input.int(1, title="10 EMA Width",  minval=1, maxval=5)
width15sma  = input.int(2, title="15 SMA Width",  minval=1, maxval=5)

// ─── Calculations ─────────────────────────────────────────────────────────────
ema5   = ta.ema(src, 5)
ema10  = ta.ema(src, 10)
sma15  = ta.sma(src, 15)

// ─── Plots (DISEGNI) ─────────────────────────────────────────────────────────
plot(show5ema   ? ema5   : na, title="5 EMA",   color=col5ema,   linewidth=width5ema)
plot(show10ema  ? ema10  : na, title="10 EMA",  color=col10ema,  linewidth=width10ema)
plot(show15sma  ? sma15  : na, title="15 SMA",  color=col15sma,  linewidth=width15sma)

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
