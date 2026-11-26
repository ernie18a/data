# IPDA Data Ranges - 20 40 60

- url: https://www.tradingview.com/script/3NGEaB4C-IPDA-Data-Ranges-20-40-60/
- type: indicator
- pine_id: PUB;aaaa291d636449e09db08ffe9a57f489
- version: 1.0

## Description

1. Daily Lookback Ranges
At the core of the IPDA theory, institutions look back over specific windows of time (usually 20, 40, and 60 days) to identify "Old Highs" and "Old Lows", which act as liquidity pools.

The script automatically calculates the highest high and lowest low of the last 20, 40, and 50 days (customizable in settings).
It uses a special function (request.security with the "D" resolution) to strictly pull this data from the Daily timeframe. This means even if you drop down to a 5-minute or 1-hour chart, the boxes will always accurately represent the daily ranges, rather than just 20 or 40 "intraday candles."

2. Box Visualization
Instead of cluttering your chart with lines, the script draws three overlapping transparent rectangle boxes representing these dealing ranges.

The X-axis (Time): The left side of each box starts at the exact opening time of the day the lookback period began, and the right side extends to the current live candle.
The Y-axis (Price): The top of the box rests exactly on the highest price within that window, and the bottom rests on the lowest price.

3. Dynamic Rendering & Performance
To keep TradingView running smoothly and prevent memory bloat, the script uses a barstate.islast check.

Rather than drawing hundreds of historical boxes over past price action, the script only draws three dynamic boxes on your chart.
On every new live tick, it simply updates the borders and boundaries of these 3 existing boxes in real-time, anchoring them perfectly to the right side of the chart.

4. Customization Engine
You have full control over the script’s display through the settings:

Lookback Periods: You can change the 20/40/50 day windows to any number of days.
Labels: You can customize the text labels (e.g., typing "Short Term IPDA" instead of "20 Day IPDA").

Text Alignment: You can use dropdown menus to snap the labels to any corner or center of the box (Left, Center, Right, Top, Bottom) so they don't cover your candles.
Aesthetics: You can tweak the background fill color and the solid border color for each box to match your chart theme.

## Source Code

````pine
//@version=6
indicator("IPDA Data Ranges", overlay=true)

// =====================================================================
// IPDA (Interbank Price Delivery Algorithm) Concept
// Objectives: Seek Liquidity & Rebalance Inefficiencies
// This script visualizes the IPDA lookback data ranges as customizable boxes.
// Adjusted to strictly use the Daily timeframe regardless of chart resolution.
// =====================================================================

// --- Inputs ---
grp_ranges = "IPDA Lookback Ranges (Days)"
lookback1 = input.int(20, title="Data Range 1", group=grp_ranges)
lookback2 = input.int(40, title="Data Range 2", group=grp_ranges)
lookback3 = input.int(50, title="Data Range 3", group=grp_ranges)

grp_labels = "Box Labels & Alignment"
txt1 = input.string("20 Day IPDA", title="Range 1 Label", group=grp_labels)
txt2 = input.string("40 Day IPDA", title="Range 2 Label", group=grp_labels)
txt3 = input.string("50 Day IPDA", title="Range 3 Label", group=grp_labels)

halign_str = input.string("Left", title="Horizontal Alignment", options=["Left", "Center", "Right"], group=grp_labels)
valign_str = input.string("Bottom", title="Vertical Alignment", options=["Top", "Center", "Bottom"], group=grp_labels)

grp_colors = "Box Customization"
col1 = input.color(color.new(color.blue, 90), title="Range 1 Background", group=grp_colors)
border1 = input.color(color.new(color.blue, 30), title="Range 1 Border", group=grp_colors)

col2 = input.color(color.new(color.orange, 90), title="Range 2 Background", group=grp_colors)
border2 = input.color(color.new(color.orange, 30), title="Range 2 Border", group=grp_colors)

col3 = input.color(color.new(color.red, 90), title="Range 3 Background", group=grp_colors)
border3 = input.color(color.new(color.red, 30), title="Range 3 Border", group=grp_colors)

// Fetch highest high, lowest low, and the starting time from the Daily timeframe
[h1, l1, t1] = request.security(syminfo.tickerid, "D", [ta.highest(high, lookback1), ta.lowest(low, lookback1), time[lookback1 > 0 ? lookback1 - 1 : 0]])
[h2, l2, t2] = request.security(syminfo.tickerid, "D", [ta.highest(high, lookback2), ta.lowest(low, lookback2), time[lookback2 > 0 ? lookback2 - 1 : 0]])
[h3, l3, t3] = request.security(syminfo.tickerid, "D", [ta.highest(high, lookback3), ta.lowest(low, lookback3), time[lookback3 > 0 ? lookback3 - 1 : 0]])

// Parse Alignments
box_halign = halign_str == "Center" ? text.align_center : halign_str == "Right" ? text.align_right : text.align_left
box_valign = valign_str == "Center" ? text.align_center : valign_str == "Top" ? text.align_top : text.align_bottom

// Draw boxes only on the last historical bar (or live updating)
var box box1 = na
var box box2 = na
var box box3 = na

if barstate.islast
    // Range 3 Box (Drawn first so it's in the background)
    if na(box3)
        box3 := box.new(left=t3, top=h3, right=time_close, bottom=l3, bgcolor=col3, border_color=border3, border_width=2, xloc=xloc.bar_time, text=txt3, text_color=color.new(border3, 0), text_halign=box_halign, text_valign=box_valign, text_size=size.small)
    else
        box.set_left(box3, t3)
        box.set_right(box3, time_close)
        box.set_top(box3, h3)
        box.set_bottom(box3, l3)
        box.set_bgcolor(box3, col3)
        box.set_border_color(box3, border3)
        box.set_text(box3, txt3)
        box.set_text_color(box3, color.new(border3, 0))
        box.set_text_halign(box3, box_halign)
        box.set_text_valign(box3, box_valign)

    // Range 2 Box
    if na(box2)
        box2 := box.new(left=t2, top=h2, right=time_close, bottom=l2, bgcolor=col2, border_color=border2, border_width=2, xloc=xloc.bar_time, text=txt2, text_color=color.new(border2, 0), text_halign=box_halign, text_valign=box_valign, text_size=size.small)
    else
        box.set_left(box2, t2)
        box.set_right(box2, time_close)
        box.set_top(box2, h2)
        box.set_bottom(box2, l2)
        box.set_bgcolor(box2, col2)
        box.set_border_color(box2, border2)
        box.set_text(box2, txt2)
        box.set_text_color(box2, color.new(border2, 0))
        box.set_text_halign(box2, box_halign)
        box.set_text_valign(box2, box_valign)

    // Range 1 Box (Drawn last so it's in the foreground)
    if na(box1)
        box1 := box.new(left=t1, top=h1, right=time_close, bottom=l1, bgcolor=col1, border_color=border1, border_width=2, xloc=xloc.bar_time, text=txt1, text_color=color.new(border1, 0), text_halign=box_halign, text_valign=box_valign, text_size=size.small)
    else
        box.set_left(box1, t1)
        box.set_right(box1, time_close)
        box.set_top(box1, h1)
        box.set_bottom(box1, l1)
        box.set_bgcolor(box1, col1)
        box.set_border_color(box1, border1)
        box.set_text(box1, txt1)
        box.set_text_color(box1, color.new(border1, 0))
        box.set_text_halign(box1, box_halign)
        box.set_text_valign(box1, box_valign)
````
