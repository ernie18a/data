# ATR Structure Trend

- url: https://www.tradingview.com/script/HueL0Ix0-ATR-Structure-Trend/
- type: indicator
- pine_id: PUB;b7ba021892794a4b83bd0d1a75276bb0
- version: 3.0

## Description

[b]ATR Structure Trend[/b]
ATR Structure Trend is a trend-following indicator that identifies the dominant market direction using price structure levels combined with an ATR-based breakout filter and a configurable confirmation mechanism — reducing false signals and improving signal quality compared to traditional highest/lowest approaches.

The result is a dynamic line that moves with the market — sitting above price in a bullish trend and below price in a bearish trend.

[b]How It Works[/b]
When price breaks above the highest value of the lookback period beyond a defined ATR buffer, a bullish trend is confirmed and the upper line activates. When price breaks below the lowest value beyond the same buffer, a bearish trend is confirmed and the lower line activates. The ATR filter ensures that only genuine breakouts beyond the normal noise range trigger a signal — minor fluctuations around the boundary are ignored.

Additionally, a confirmation mechanism requires the breakout condition to hold for a defined number of bars before the trend state changes — separately configurable for bullish and bearish signals. Once a trend is confirmed it stays active until the opposite condition is met, keeping the indicator stable and avoiding unnecessary signal noise.

[b]Settings[/b]
[list]
[*]H — Lookback period for bullish structure detection (default: 61)
[*]L — Lookback period for bearish structure detection (default: 33)
[*]Highest Source — Price source for bullish structure calculation (default: hlcc4)
[*]Lowest Source — Price source for bearish structure calculation (default: high)
[*]Long Confirmation Bars — Number of bars the bullish breakout must hold before confirming (default: 1)
[*]Short Confirmation Bars — Number of bars the bearish breakout must hold before confirming (default: 1)
[*]ATR Length — Lookback period for ATR calculation (default: 20)
[*]ATR Multiplier — Controls the size of the breakout buffer. Set to 0 to disable the ATR filter entirely (default: 0.15)[/list]

[b]Recommended Usage[/b]
[list]
[*]Best used on the 1D timeframe for clean and reliable trend identification
[*]Best used alongside other indicators — this tool identifies the trend, but should not be used alone for trade entries
[*]The two lookback periods are intentionally different — bullish and bearish trends often develop at different speeds, so treating them separately improves accuracy
[*]Higher ATR Multiplier values reduce signals but increase breakout quality — lower values make the indicator more reactive
[*]Higher Confirmation Bar values filter out fake breakouts at the cost of slightly later entries[/list]

All signals are confirmed on bar close.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Unknownhodler
//@version=6
indicator("ATRStructureTrend", overlay = true)
//------------------------------------------------------------INPUTS------------------------------------------------------------
h        = input.int(61, "Highest Length")
l        = input.int(33, "Lowest Length")
src_h    = input.source(hlcc4, "Highest Source")
src_l    = input.source(high,  "Lowest Source")
conf_l   = input.int(1,   "Long Confirmation Bars",  minval = 1,   group = "Confirmation")
conf_s   = input.int(1,   "Short Confirmation Bars", minval = 1,   group = "Confirmation")
atr_len  = input.int(20,  "ATR Length",              minval = 1,   group = "ATR Filter")
atr_mult = input.float(0.15, "ATR Multiplier",        step = 0.01, minval = 0.0, group = "ATR Filter")
bar      = input.bool(true, group = "Bar Color Settings")
//---------------------------------------------------------CALCULATIONS---------------------------------------------------------
highest = ta.highest(src_h, h)
lowest  = ta.lowest(src_l, l)
atr     = ta.atr(atr_len)

long  = high > highest + atr * atr_mult
short = low  < lowest  - atr * atr_mult

long_conf  = math.sum(long  ? 1 : 0, conf_l) >= conf_l
short_conf = math.sum(short ? 1 : 0, conf_s) >= conf_s

var hodl = 0
if long_conf and not short_conf
    hodl := 1
if short_conf
    hodl := -1
//------------------------------------------------------------PLOTS-------------------------------------------------------------
barcolor(color = hodl ==  1 and bar ? color.rgb(0, 200, 255) : na)
barcolor(color = hodl == -1 and bar ? color.rgb(255, 0, 0)   : na)
p_h     = plot(highest, color = hodl ==  1 ? color.rgb(0, 200, 255) : na, linewidth = 3)
p_l     = plot(lowest,  color = hodl == -1 ? color.rgb(255, 0, 0)   : na, linewidth = 3)
p_close = plot(close,   color = na, editable = false)
fill(p_h, p_close, color = hodl ==  1 ? color.rgb(0, 200, 255, 80) : na)
fill(p_l, p_close, color = hodl == -1 ? color.rgb(255, 0, 0, 80)   : na)
````
