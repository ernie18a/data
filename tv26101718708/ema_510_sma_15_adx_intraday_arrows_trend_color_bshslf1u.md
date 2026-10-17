# EMA 5-10 | SMA 15 | ADX Intraday + Arrows + Trend Color

- url: https://www.tradingview.com/script/bshslF1U/
- type: indicator
- pine_id: PUB;97a3ad3120924eb9a45ccc62a8611cb8
- version: 1.0

## Description

alculates EMA 5, EMA 10, SMA 15 and ADX (DI length 14, smoothing 14). Trend conditions are validated only when ADX exceeds 25. Bullish and bearish arrows are plotted on confirmed crossovers, and optional candle coloring enhances trend visualization.

## Source Code

````pine
//@version=6
indicator(title="EMA 5-10 | SMA 15 | ADX Intraday + Arrows + Trend Color", shorttitle="EMA-ADX TrendColor", overlay=true)

// ─── Inputs ────────────────────────────────────────────────────────────────
src = input.source(close, "Source")

show5ema   = input.bool(true,  "Show 5 EMA")
show10ema  = input.bool(true,  "Show 10 EMA")
show15sma  = input.bool(true,  "Show 15 SMA")
showADX    = input.bool(true,  "Show ADX")
showArrows = input.bool(true,  "Show Arrows")
showTrend  = input.bool(true,  "Color Trend")

col5ema   = input.color(color.new(#00E5FF, 0), "5 EMA Color")
col10ema  = input.color(color.new(#8fce00, 0), "10 EMA Color")
col15sma  = input.color(color.new(#f6c73b, 0), "15 SMA Color")
colADX    = input.color(color.new(#ff00ff, 0), "ADX Color")

width5ema  = input.int(1, "5 EMA Width",  minval=1, maxval=5)
width10ema = input.int(1, "10 EMA Width", minval=1, maxval=5)
width15sma = input.int(2, "15 SMA Width", minval=1, maxval=5)

// ─── Calculations ───────────────────────────────────────────────────────────
ema5  = ta.ema(src, 5)
ema10 = ta.ema(src, 10)
sma15 = ta.sma(src, 15)

// ADX CORRETTO: ta.dmi restituisce 3 valori → uso destrutturazione
[plusDI, minusDI, adx] = ta.dmi(14, 14)

// ─── Trend Logic ───────────────────────────────────────────────────────────
bullish = ema5 > sma15 and adx > 25
bearish = ema5 < sma15 and adx > 25

// ─── Plots ─────────────────────────────────────────────────────────────────
plot(show5ema  ? ema5  : na, title="5 EMA",  color=col5ema,  linewidth=width5ema)
plot(show10ema ? ema10 : na, title="10 EMA", color=col10ema, linewidth=width10ema)
plot(show15sma ? sma15 : na, title="15 SMA", color=col15sma, linewidth=width15sma)
plot(showADX   ? adx   : na, title="ADX",    color=colADX,   linewidth=2)

// ─── Trend Color on Price ──────────────────────────────────────────────────
barcolor(showTrend ? (bullish ? color.green : bearish ? color.red : na) : na)

// ─── Arrows ────────────────────────────────────────────────────────────────
plotshape(
     showArrows and ta.crossover(ema5, sma15) and adx > 25,
     title="Bullish Arrow",
     style=shape.labelup,
     color=color.green,
     size=size.small,
     text="▲"
)

plotshape(
     showArrows and ta.crossunder(ema5, sma15) and adx > 25,
     title="Bearish Arrow",
     style=shape.labeldown,
     color=color.red,
     size=size.small,
     text="▼"
)

// ─── Alerts ────────────────────────────────────────────────────────────────
alertcondition(
     ta.crossover(ema5, sma15) and adx > 25,
     title="BULLISH — EMA 5 Above SMA 15 + ADX > 25",
     message="Bullish momentum: EMA 5 crossed ABOVE SMA 15 with ADX > 25"
)

alertcondition(
     ta.crossunder(ema5, sma15) and adx > 25,
     title="BEARISH — EMA 5 Below SMA 15 + ADX > 25",
     message="Bearish momentum: EMA 5 crossed BELOW SMA 15 with ADX > 25"
)
````
