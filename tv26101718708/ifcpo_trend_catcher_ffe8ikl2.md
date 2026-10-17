# iFCPO Trend Catcher

- url: https://www.tradingview.com/script/ffe8ikL2-iFCPO-Trend-Catcher/
- type: indicator
- pine_id: PUB;0a7c410caa024efdba2200635f9af061
- version: 1.0

## Description

iFCPO Trend Catcher PM — Supertrend hard-gated to 14:30-16:30 PM with palm-tuned ATR.

Classic Supertrend with FCPO-tuned defaults: ATR(10, 0.7x). Signals (flip up/down) disabled outside 14:30-16:30 MYT — only fires during the W18 Edge Zone window.

Green/red Supertrend line + flip arrows on chart. PM window highlighted with green tint.

MEMBER tier indicator from iFCPO — Malaysia palm-oil futures trading platform.

## Source Code

````pine
//@version=6
// iFCPO Trend Catcher PM — Supertrend hard-gated to 14:30-16:30 with palm-tuned ATR
// Tier: MEMBER | Category: Trend
indicator("iFCPO Trend Catcher", "iFCPO TrCt", overlay = true)

atr_period = input.int(10,  "ATR period",  minval = 3, group = "Supertrend")
atr_mult   = input.float(0.7, "ATR multiplier (palm-tuned)", minval = 0.3, maxval = 4.0, step = 0.1, group = "Supertrend")
gate_pm    = input.bool(true, "Disable signals outside 14:30-16:30 PM", group = "Filters")

[st_line, st_dir] = ta.supertrend(atr_mult, atr_period)

TZ = "Asia/Kuala_Lumpur"
in_pm_window = not na(time(timeframe.period, "1430-1630:23456", TZ))
pm_ok = not gate_pm or in_pm_window

flip_up = ta.crossover(close, st_line)  and pm_ok
flip_dn = ta.crossunder(close, st_line) and pm_ok

st_color = st_dir < 0 ? color.new(#1FC77E, 0) : color.new(#FF3B5C, 0)
plot(st_line, "Supertrend", color = st_color, linewidth = 2)

plotshape(flip_up, "Flip up", style = shape.triangleup,   location = location.belowbar, color = color.new(#1FC77E, 0), size = size.small, text = "Up")
plotshape(flip_dn, "Flip dn", style = shape.triangledown, location = location.abovebar, color = color.new(#FF3B5C, 0), size = size.small, text = "Dn")

bgcolor(in_pm_window ? color.new(#1FC77E, 96) : na, title = "PM window")

plot(st_line, "st_line", display = display.data_window)
plot(st_dir,  "st_dir",  display = display.data_window)
plot(flip_up ? 1 : 0, "flip_up", display = display.data_window)
plot(flip_dn ? 1 : 0, "flip_dn", display = display.data_window)
````
