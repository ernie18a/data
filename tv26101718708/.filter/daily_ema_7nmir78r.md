# Daily EMA 

- url: https://www.tradingview.com/script/7nMIR78R-Daily-EMA/
- type: indicator
- pine_id: PUB;426a2f0cb20043aaa2404a6888456167
- version: 1.0

## Description

Custom EMA Ribbon (3x Daily)

This indicator plots three Exponential Moving Averages (EMAs) that are always calculated on the daily timeframe — no matter what chart timeframe you're viewing. Whether you're on the 1-minute, 5-minute, or 4-hour chart, the EMAs will always reflect daily values, giving you a clear view of the higher timeframe trend while you trade on lower timeframes.
Default EMAs: 9 / 21 / 50 (fully customizable via settings)

## Source Code

````pine
//@version=6
indicator("Custom EMA Ribbon (3x Daily)", overlay=true)

// ─── TIMEFRAME ────────────────────────────────────────
tf = input.timeframe("D", "Source Timeframe")

// ─── EMA LENGTHS ──────────────────────────────────────
ema1_len = input.int(9,  "EMA 1 - Length", minval=1)
ema2_len = input.int(21, "EMA 2 - Length", minval=1)
ema3_len = input.int(50, "EMA 3 - Length", minval=1)

// ─── COLORS ───────────────────────────────────────────
ema1_color = input.color(color.new(#00bcd4, 0), "EMA 1 - Color")   // Cyan
ema2_color = input.color(color.new(#ff9800, 0), "EMA 2 - Color")   // Orange
ema3_color = input.color(color.new(#e91e63, 0), "EMA 3 - Color")   // Pink

// ─── LINE WIDTH ───────────────────────────────────────
ema1_width = input.int(2, "EMA 1 - Line Width", minval=1, maxval=5)
ema2_width = input.int(2, "EMA 2 - Line Width", minval=1, maxval=5)
ema3_width = input.int(2, "EMA 3 - Line Width", minval=1, maxval=5)

// ─── CALCULATIONS (always on selected timeframe) ─────
ema1 = request.security(syminfo.tickerid, tf, ta.ema(close, ema1_len), barmerge.gaps_off, barmerge.lookahead_off)
ema2 = request.security(syminfo.tickerid, tf, ta.ema(close, ema2_len), barmerge.gaps_off, barmerge.lookahead_off)
ema3 = request.security(syminfo.tickerid, tf, ta.ema(close, ema3_len), barmerge.gaps_off, barmerge.lookahead_off)

// ─── PLOT ─────────────────────────────────────────────
plot(ema1, "EMA 1 (9)",  color=ema1_color, linewidth=ema1_width)
plot(ema2, "EMA 2 (21)", color=ema2_color, linewidth=ema2_width)
plot(ema3, "EMA 3 (50)", color=ema3_color, linewidth=ema3_width)

// ─── RIBBON FILL BETWEEN EMA 1 AND EMA 2 ─────────────
fill_enabled = input.bool(true, "Ribbon fill between EMA 1 & 2")

p1 = plot(ema1, "Fill EMA 1", color=color.new(color.white, 100), display=display.none)
p2 = plot(ema2, "Fill EMA 2", color=color.new(color.white, 100), display=display.none)

bull_fill = input.color(color.new(#00bcd4, 85), "Ribbon color - Bullish")
bear_fill = input.color(color.new(#e91e63, 85), "Ribbon color - Bearish")

fill(p1, p2, color=fill_enabled ? (ema1 > ema2 ? bull_fill : bear_fill) : color.new(color.white, 100))

// ─── CROSS ALERTS (EMA 1 x EMA 2) ────────────────────
bullish_cross = ta.crossover(ema1, ema2)
bearish_cross = ta.crossunder(ema1, ema2)

plotshape(bullish_cross, "Bullish Cross", shape.triangleup,   location.belowbar, color.new(#00bcd4, 0), size=size.small)
plotshape(bearish_cross, "Bearish Cross", shape.triangledown, location.abovebar, color.new(#e91e63, 0), size=size.small)

alertcondition(bullish_cross, "EMA Bullish Cross", "EMA 1 crossed above EMA 2")
alertcondition(bearish_cross, "EMA Bearish Cross", "EMA 1 crossed below EMA 2")
````
