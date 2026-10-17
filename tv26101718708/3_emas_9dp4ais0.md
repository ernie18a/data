# 3 EMAs

- url: https://www.tradingview.com/script/9DP4AIs0/
- type: indicator
- pine_id: PUB;20ea0cdd5eab471bb0843885ac9279c2
- version: 1.0

## Description

[b]Title[/b]: 3 EMAs in One Indicator

[b]Description[/b]:
This indicator plots three Exponential Moving Averages (EMAs) on the same chart using a single script — ideal for TradingView plans with a limited number of indicators per chart.
Each EMA is fully customizable directly from the settings panel:

[list]
[*] Length — set any period for each EMA independently
[*] Color — choose any color for each line
[*] Line width — adjust thickness from 1 to 5
[*] Show/Hide toggle — enable or disable each EMA without removing the indicator
[*] Source — select the price source (close, open, hl2, hlc3, etc.) applied to all three EMAs
[/list]


Default values are set to 9 / 21 / 50, a commonly used combination for trend and momentum analysis, but all parameters are freely adjustable to fit any trading style or timeframe.

[b]Use case[/b]: Replace three separate EMA indicators with a single one, freeing up indicator slots on your chart.

## Source Code

````pine
//@version=6
indicator("3 EMAs", overlay=true)

// ─── EMA 1 ───
ema1_len   = input.int(9,    "EMA 1 · Longitud", minval=1, group="EMA 1")
ema1_color = input.color(color.new(#2196F3, 0), "Color",   group="EMA 1")
ema1_width = input.int(1,    "Grosor",           minval=1, maxval=5, group="EMA 1")
ema1_show  = input.bool(true, "Mostrar",                   group="EMA 1")

// ─── EMA 2 ───
ema2_len   = input.int(21,   "EMA 2 · Longitud", minval=1, group="EMA 2")
ema2_color = input.color(color.new(#FF9800, 0), "Color",   group="EMA 2")
ema2_width = input.int(1,    "Grosor",           minval=1, maxval=5, group="EMA 2")
ema2_show  = input.bool(true, "Mostrar",                   group="EMA 2")

// ─── EMA 3 ───
ema3_len   = input.int(50,   "EMA 3 · Longitud", minval=1, group="EMA 3")
ema3_color = input.color(color.new(#E91E63, 0), "Color",   group="EMA 3")
ema3_width = input.int(1,    "Grosor",           minval=1, maxval=5, group="EMA 3")
ema3_show  = input.bool(true, "Mostrar",                              group="EMA 3")

// ─── Fuente ───
src = input.source(close, "Fuente", group="General")

// ─── Cálculo ───
ema1 = ta.ema(src, ema1_len)
ema2 = ta.ema(src, ema2_len)
ema3 = ta.ema(src, ema3_len)

// ─── Plot ───
plot(ema1_show ? ema1 : na, title="EMA 1", color=ema1_color, linewidth=ema1_width)
plot(ema2_show ? ema2 : na, title="EMA 2", color=ema2_color, linewidth=ema2_width)
plot(ema3_show ? ema3 : na, title="EMA 3", color=ema3_color, linewidth=ema3_width)
````
