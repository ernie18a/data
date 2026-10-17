# Session Times (Sydney) by (pbloem)

- url: https://www.tradingview.com/script/97cHAyCy-Session-Times-Sydney-by-pbloem/
- type: indicator
- pine_id: PUB;5a2c27830d2743bfabe6df4c0ef73678
- version: 1.0

## Description

A clean, minimal indicator designed for Sydney-based traders showing the exact local open times for the London and New York sessions.

🔵 London Session — opens 5:00 PM Sydney time (AEST)
🟠 New York Session — opens 11:30 PM Sydney time (AEST)

Features:
- Dashed vertical lines marking the first candle of each session open
- Session reference table in the bottom right corner
- Customisable line colours for both sessions
- Adjustable table size (Small / Normal / Large)

Note: Times are based on AEST (UTC+10). During Australian daylight saving (AEDT, UTC+11) add 1 hour to both session times.

Built for ICT-style traders who trade London and New York killzones from Sydney.

## Source Code

````pine

//@version=6
indicator("Session Times (Sydney)", overlay=true)

london_sydney = "5:00 PM"
ny_sydney     = "11:30 PM"

london_col_input = input.color(color.new(#00BFFF, 35), "London Line Colour")
ny_col_input     = input.color(color.new(#FF9900, 35), "New York Line Colour")
size_input       = input.string("Small", "Table Size", options=["Small", "Normal", "Large"])

tbl_size = size_input == "Large" ? size.large : size_input == "Normal" ? size.normal : size.small

isLondonOpen = hour(time, "UTC") == 7  and minute(time, "UTC") == 0
isNYOpen     = hour(time, "UTC") == 13 and minute(time, "UTC") == 30

if isLondonOpen
    line.new(bar_index, high * 1.01, bar_index, low * 0.99,
      color=london_col_input, width=1, style=line.style_dashed, extend=extend.both)

if isNYOpen
    line.new(bar_index, high * 1.01, bar_index, low * 0.99,
      color=ny_col_input, width=1, style=line.style_dashed, extend=extend.both)

var table t = table.new(position.bottom_right, 2, 3, border_width=1, border_color=color.new(color.gray, 50))

if barstate.islast
    table.cell(t, 0, 0, "Session",     text_color=color.new(color.gray, 20), text_size=tbl_size, bgcolor=color.new(color.black, 30))
    table.cell(t, 1, 0, "Sydney Open", text_color=color.new(color.gray, 20), text_size=tbl_size, bgcolor=color.new(color.black, 30))
    table.cell(t, 0, 1, "London",      text_color=london_col_input,          text_size=tbl_size, bgcolor=color.new(color.black, 50))
    table.cell(t, 1, 1, london_sydney, text_color=london_col_input,          text_size=tbl_size, bgcolor=color.new(color.black, 50))
    table.cell(t, 0, 2, "New York",    text_color=ny_col_input,              text_size=tbl_size, bgcolor=color.new(color.black, 50))
    table.cell(t, 1, 2, ny_sydney,     text_color=ny_col_input,              text_size=tbl_size, bgcolor=color.new(color.black, 50))
````
