# Checklist

- url: https://www.tradingview.com/script/U4C84fIR-Checklist/
- type: indicator
- pine_id: PUB;7903cbb9359f48f0a3c430523b0e226f
- version: 2.0

## Description

Features:

One text box for everything — no clicking through 10 separate fields
Choose position: top right, top left, bottom right, bottom left, or middle right
Adjustable text size
Custom title
Persists with your chart layout

## Source Code

````pine
//@version=5
indicator("Datrena Notes", overlay=true)

i_title = input.string("NOTES", "Title", group="Display")
i_pos   = input.string("top_right", "Position", options=["top_right","top_left","bottom_right","bottom_left","middle_right"], group="Display")
i_size  = input.string("normal", "Text Size", options=["tiny","small","normal","large","huge"], group="Display")
i_color = input.color(color.white, "Text Color", group="Display")

i_text = input.text_area(
   "HTF bias confirmed\nKey level: 5825\nDelta confirms direction\nRisk = 1R defined\nNews checked",
   "Notes (one line per row)",
   group="Notes")

f_pos(s) =>
    s == "top_right"    ? position.top_right    :
     s == "top_left"     ? position.top_left     :
     s == "bottom_right" ? position.bottom_right :
     s == "bottom_left"  ? position.bottom_left  :
     position.middle_right

f_size(s) =>
    s == "tiny"  ? size.tiny  :
     s == "small" ? size.small :
     s == "large" ? size.large :
     s == "huge"  ? size.huge  :
     size.normal

var table tbl = na

if barstate.islast
    table.delete(tbl)
    lines = str.split(i_text, "\n")
    n = array.size(lines)
    rows = n + 1

    tbl := table.new(f_pos(i_pos), 1, rows, bgcolor=color.new(color.black, 100), border_width=0)

    table.cell(tbl, 0, 0, i_title, text_color=i_color, text_size=f_size(i_size), bgcolor=color.new(color.black, 100), text_halign=text.align_left)

    for i = 0 to n - 1
        raw = array.get(lines, i)
        trimmed = str.trim(raw)
        if str.length(trimmed) > 0
            table.cell(tbl, 0, i + 1, trimmed, text_color=i_color, text_size=f_size(i_size), bgcolor=color.new(color.black, 100), text_halign=text.align_left)
````
