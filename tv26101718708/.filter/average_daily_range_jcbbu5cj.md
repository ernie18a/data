# Average Daily Range

- url: https://www.tradingview.com/script/JCbBu5CJ-Average-Daily-Range/
- type: indicator
- pine_id: PUB;b68e8617867547fd933dd6176c780aa5
- version: 1.0

## Description

Shows ADR as a single line of text regardless of the timeframe

## Source Code

````pine
//@version=5
indicator("Average Daily Range", shorttitle="Average Daily Range", overlay=true)

// === ADR Settings ===
adr_length = input.int(14, title="ADR Period (Days)", minval=1, group="ADR Settings")

// === Label Position ===
h_pos = input.string("Right", title="Horizontal Position", options=["Left", "Center", "Right"], group="Label Position")
v_pos = input.string("Top", title="Vertical Position", options=["Top", "Middle", "Bottom"], group="Label Position")

// === Label Style ===
bg_color  = input.color(color.navy, title="Background Color", group="Label Style")
txt_color = input.color(color.white, title="Text Color", group="Label Style")
txt_size  = input.string("Normal", title="Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Label Style")

// === Calculate ADR ===
f_adr() =>
    daily_range = high - low
    ta.sma(daily_range, adr_length)

adr = request.security(syminfo.tickerid, "D", f_adr())
adr_display = str.tostring(math.round(adr, 2))

// === Map size ===
mapped_size = txt_size == "Tiny" ? size.tiny : txt_size == "Small" ? size.small : txt_size == "Large" ? size.large : txt_size == "Huge" ? size.huge : size.normal

// === Map position ===
table_pos = h_pos == "Left" and v_pos == "Top" ? position.top_left : h_pos == "Left" and v_pos == "Middle" ? position.middle_left : h_pos == "Left" and v_pos == "Bottom" ? position.bottom_left : h_pos == "Center" and v_pos == "Top" ? position.top_center : h_pos == "Center" and v_pos == "Middle" ? position.middle_center : h_pos == "Center" and v_pos == "Bottom" ? position.bottom_center : h_pos == "Right" and v_pos == "Top" ? position.top_right : h_pos == "Right" and v_pos == "Middle" ? position.middle_right : position.bottom_right

// === Draw screen-anchored table ===
var table adr_table = na
adr_table := table.new(table_pos, 1, 1, bgcolor=bg_color, border_width=1, border_color=bg_color, frame_width=1, frame_color=bg_color)
table.cell(adr_table, 0, 0, "ADR(" + str.tostring(adr_length) + "): " + adr_display, text_color=txt_color, text_size=mapped_size, bgcolor=bg_color)
````
