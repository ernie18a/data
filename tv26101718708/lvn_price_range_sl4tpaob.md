# LVN price range

- url: https://www.tradingview.com/script/Sl4TPAoB-LVN-price-range/
- type: indicator
- pine_id: PUB;d8c194e0fb764aa0bbd1c63c61b778b2
- version: 2.0

## Description

low vol node rectangle that displays price even unselected.

## Source Code

````pine
//@version=5
indicator("Price Range Box", overlay=true, max_boxes_count=50, max_labels_count=100, max_lines_count=10)

// ── INPUTS ────────────────────────────────────────────────────────────────────
price_high = input.float(0.0, title="Zone High Price")
price_low  = input.float(0.0, title="Zone Low Price")
box_color  = input.color(color.new(color.blue, 80),  title="Fill Color")
border_col = input.color(color.new(color.blue, 20),  title="Border Color")
lbl_color  = input.color(color.blue,                 title="Label Color")
show_range = input.bool(true,  title="Show range size")
show_mid   = input.bool(false, title="Show midpoint line")
mid_color  = input.color(color.new(color.blue, 40),  title="Midpoint Line Color")

// ── ONLY DRAW WHEN VALID PRICES ARE SET ──────────────────────────────────────
_high = math.max(price_high, price_low)
_low  = math.min(price_high, price_low)
_mid  = (_high + _low) / 2
_range = _high - _low

valid = price_high != 0.0 and price_low != 0.0 and price_high != price_low

// ── PERSISTENT HORIZONTAL LINES (never disappear, no selection dependency) ───
var line line_high = na
var line line_low  = na
var line line_mid  = na

// ── PERSISTENT LABELS ─────────────────────────────────────────────────────────
var label lbl_high  = na
var label lbl_low   = na
var label lbl_range = na

if valid
    // Delete and redraw each bar so they always sit at the current right edge
    line.delete(line_high)
    line.delete(line_low)
    line.delete(line_mid)
    label.delete(lbl_high)
    label.delete(lbl_low)
    label.delete(lbl_range)

    // Solid horizontal lines across the full chart for each boundary
    line_high := line.new(
         x1=bar_index - 1, y1=_high,
         x2=bar_index,     y2=_high,
         extend=extend.both,
         color=border_col,
         width=1
         )

    line_low := line.new(
         x1=bar_index - 1, y1=_low,
         x2=bar_index,     y2=_low,
         extend=extend.both,
         color=border_col,
         width=1
         )

    if show_mid
        line_mid := line.new(
             x1=bar_index - 1, y1=_mid,
             x2=bar_index,     y2=_mid,
             extend=extend.both,
             color=mid_color,
             style=line.style_dashed,
             width=1
             )

    // Labels pinned to right edge, always redrawn at current bar
    lbl_high := label.new(
         x=bar_index, y=_high,
         text=" " + str.tostring(_high, format.mintick),
         style=label.style_label_left,
         color=color.new(color.white, 100),
         textcolor=lbl_color,
         size=size.small
         )

    lbl_low := label.new(
         x=bar_index, y=_low,
         text=" " + str.tostring(_low, format.mintick),
         style=label.style_label_left,
         color=color.new(color.white, 100),
         textcolor=lbl_color,
         size=size.small
         )

    if show_range
        lbl_range := label.new(
             x=bar_index, y=_mid,
             text=" range: " + str.tostring(_range, format.mintick),
             style=label.style_label_left,
             color=color.new(color.white, 100),
             textcolor=color.new(lbl_color, 40),
             size=size.tiny
             )
````
