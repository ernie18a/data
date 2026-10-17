# Cogory 

- url: https://www.tradingview.com/script/FrTDITS1-Cogory/
- type: indicator
- pine_id: PUB;1d971eb1cf464b6cae42d14080baa86c
- version: 3.0

## Description

this is cogory Zones. this is cogory Zones.  this is cogory Zones. this is cogory Zones.

## Source Code

````pine
//@version=6
indicator("Purple Zones", overlay=true, max_boxes_count=500, max_lines_count=500)

var color FILL_COLOR   = color.new(color.purple, 80)
var color BORDER_COLOR = color.black
var color MID_COLOR    = color.new(color.purple, 30)

draw_zone(enabled, top, bot) =>
    if enabled and top != 0.0 and bot != 0.0 and barstate.isfirst
        mid = (top + bot) / 2
        box.new(bar_index, top, bar_index, bot,
             border_color = BORDER_COLOR, border_width = 1,
             border_style = line.style_solid,
             bgcolor = FILL_COLOR, extend = extend.both)
        line.new(bar_index, mid, bar_index + 1, mid,
             color = MID_COLOR, width = 1,
             style = line.style_dashed, extend = extend.both)

// --- ZONE DATA ---
draw_zone(true, 30347.00, 30343.25)
````
