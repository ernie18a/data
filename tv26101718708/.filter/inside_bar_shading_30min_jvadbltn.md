# Inside Bar Shading (30-Min)

- url: https://www.tradingview.com/script/JvadBltn-Inside-Bar-Shading-30-Min/
- type: indicator
- pine_id: PUB;1fb508411f8a49d880b32819dbb47339
- version: 1.0

## Description

Shades a box around closed 30 min inside candles either green for bullish or red for bearish.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BTrades3

//@version=6
indicator("Inside Bar Shading (30-Min)", overlay=true)

show_bullish = input.bool(true, "Show Bullish Inside Bar (Green)", group="Visibility")
show_bearish = input.bool(true, "Show Bearish Inside Bar (Red)",   group="Visibility")
bull_color   = input.color(color.new(color.green, 85), "Bullish Color", group="Colors")
bear_color   = input.color(color.new(color.red,   85), "Bearish Color", group="Colors")

h30  = request.security(syminfo.tickerid, "30", high)
l30  = request.security(syminfo.tickerid, "30", low)
o30  = request.security(syminfo.tickerid, "30", open)
c30  = request.security(syminfo.tickerid, "30", close)
ph30 = request.security(syminfo.tickerid, "30", high[1])
pl30 = request.security(syminfo.tickerid, "30", low[1])

bar_start = request.security(syminfo.tickerid, "30", time)
bar_end   = request.security(syminfo.tickerid, "30", time_close)

is_inside      = h30 < ph30 and l30 > pl30
is_bull_inside = is_inside and c30 > o30
is_bear_inside = is_inside and c30 < o30
is_new_bar     = ta.change(time("30")) != 0

if is_new_bar and is_bull_inside and show_bullish
    b = box.new(bar_start, h30, bar_end, l30, color.new(color.green, 80), 1, line.style_solid, extend.none, xloc.bar_time, bull_color)

if is_new_bar and is_bear_inside and show_bearish
    b = box.new(bar_start, h30, bar_end, l30, color.new(color.red, 80), 1, line.style_solid, extend.none, xloc.bar_time, bear_color)
````
