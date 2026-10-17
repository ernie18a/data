# iFCPO SMC Map

- url: https://www.tradingview.com/script/R5XF9M75-iFCPO-SMC-Map/
- type: indicator
- pine_id: PUB;dfef1557571041ed94d48d80f665c586
- version: 1.0

## Description

iFCPO Smart Money Map — BOS / CHoCH / OB / FVG with FCPO lunch-suppression.

Detects:
- BOS (Break of Structure): high breaks last swing high (BULL) or low breaks last swing low (BEAR)
- FVG (Fair Value Gap): 3-bar imbalance regions
- OB (Order Blocks): preceded swing candles before BOS

FCPO twist: lunch (12:30-14:30) signals auto-suppressed since the market is closed.

FREE indicator from iFCPO — Malaysia palm-oil futures trading platform.

## Source Code

````pine
//@version=6
// iFCPO Smart Money Map — BOS / CHoCH / OB / FVG (lunch-suppressed for FCPO)
// Tier: FREE | Category: Smart Money Concepts
indicator("iFCPO SMC Map", "iFCPO SMC", overlay = true)

swing_len = input.int(10, "Swing detection length", minval = 3, maxval = 50, group = "Structure")
show_bos  = input.bool(true,  "Show BOS / CHoCH labels", group = "Display")
show_fvg  = input.bool(true,  "Show fair value gaps",    group = "Display")
show_ob   = input.bool(true,  "Show order blocks",       group = "Display")
suppress_lunch = input.bool(true, "Suppress lunch (12:30-14:30) signals", group = "FCPO twist")

TZ = "Asia/Kuala_Lumpur"
in_lunch = not na(time(timeframe.period, "1230-1430:23456", TZ))
lunch_ok = not (suppress_lunch and in_lunch)

ph = ta.pivothigh(high, swing_len, swing_len)
pl = ta.pivotlow(low, swing_len, swing_len)

var float last_ph = na
var float last_pl = na
if not na(ph)
    last_ph := ph
if not na(pl)
    last_pl := pl

bos_up   = not na(last_ph) and high > last_ph and high[1] <= last_ph and lunch_ok
bos_down = not na(last_pl) and low  < last_pl and low[1]  >= last_pl and lunch_ok

if show_bos and bos_up
    label.new(bar_index, high, "BOS up", color = color.new(#1FC77E, 30), textcolor = color.white, style = label.style_label_up, size = size.tiny)
if show_bos and bos_down
    label.new(bar_index, low, "BOS down", color = color.new(#FF3B5C, 30), textcolor = color.white, style = label.style_label_down, size = size.tiny)

fvg_up   = show_fvg and low > high[2] and lunch_ok
fvg_down = show_fvg and high < low[2] and lunch_ok
if fvg_up
    box.new(bar_index - 2, high[2], bar_index, low, border_color = color.new(#1FC77E, 50), bgcolor = color.new(#1FC77E, 88))
if fvg_down
    box.new(bar_index - 2, low[2], bar_index, high, border_color = color.new(#FF3B5C, 50), bgcolor = color.new(#FF3B5C, 88))

ob_bull = show_ob and bos_up and close[swing_len] < open[swing_len]
ob_bear = show_ob and bos_down and close[swing_len] > open[swing_len]
if ob_bull
    box.new(bar_index - swing_len - 1, high[swing_len], bar_index - swing_len + 5, low[swing_len], border_color = color.new(#1FC77E, 50), bgcolor = color.new(#1FC77E, 92))
if ob_bear
    box.new(bar_index - swing_len - 1, high[swing_len], bar_index - swing_len + 5, low[swing_len], border_color = color.new(#FF3B5C, 50), bgcolor = color.new(#FF3B5C, 92))

plot(bos_up   ? 1 : 0, "bos_up",   display = display.data_window)
plot(bos_down ? 1 : 0, "bos_down", display = display.data_window)
plot(fvg_up   ? 1 : 0, "fvg_up",   display = display.data_window)
plot(fvg_down ? 1 : 0, "fvg_down", display = display.data_window)
````
