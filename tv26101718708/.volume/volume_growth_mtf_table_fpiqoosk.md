# Volume Growth MTF Table

- url: https://www.tradingview.com/script/FPiQooSk-Volume-Growth-MTF-Table/
- type: indicator
- pine_id: PUB;18da8734a8114dc4893760e5d8dd8b41
- version: 1.0

## Description

volume performance 
daily 
4h
1h 
Why Volume Performance Matters
Tracking volume performance allows you to analyze and verify multiple aspects of the cryptocurrency market:
Liquidity and Stability: Higher daily volume means tighter bid-ask spreads and the ability to execute large trades without causing drastic price slippage.
Trend Confirmation: A price rally backed by increasing volume shows genuine market support. If prices are rising but volume is dwindling, it often flags an unsustainable rally.
Spotting Breakouts: Genuine breakouts above resistance levels are typically accompanied by massive volume spikes. Breakouts with low volume are often treated as false signals or "fakeouts

## Source Code

````pine
//@version=5
indicator("Volume Growth MTF Table", overlay=true)

// --- Inputs: Toggles & Customization ---
show_1h     = input.bool(true, "Show 1H Row?")
show_4h     = input.bool(true, "Show 4H Row?")
show_1d     = input.bool(true, "Show 1D Row?")

table_pos   = input.string("top_right", "Location", options=["top_right", "bottom_right", "top_left", "bottom_left", "middle_right"])
text_size   = input.string("small", "Text Size", options=["tiny", "small", "normal", "large", "huge"])

color_up    = input.color(color.new(#00ffbb, 30), "Growth Color (Positive)")
color_down  = input.color(color.new(#ff5252, 30), "Decline Color (Negative)")
color_bg    = input.color(color.new(#2a2e39, 20), "Cell Background")
color_head  = input.color(color.new(#5d606b, 0), "Header Background")
color_text  = input.color(color.white, "Text Color")

// --- Data Fetching ---
f_get_vols(tf) =>
    [request.security(syminfo.tickerid, tf, volume * close), 
     request.security(syminfo.tickerid, tf, volume[1] * close[1])]

[v1h, v1h_p] = f_get_vols("60")
[v4h, v4h_p] = f_get_vols("240")
[v1d, v1d_p] = f_get_vols("D")

// --- Calculations ---
// Your formula: (Current / Previous) * 100
calc_growth(curr, prev) => (curr / prev) * 100

format_vol(val) => 
    val >= 1000000 ? str.format("{0,number,#}M", val / 1000000) : 
     val >= 1000 ? str.format("{0,number,#}K", val / 1000) : str.format("{0,number,#}", val)

// --- Table Construction ---
var main_table = table.new(table_pos, 4, 4, border_width=1, border_color=color.gray)

if barstate.islast
    table.clear(main_table, 0, 0, 3, 3)
    
    // Headers (Matching your drawing)
    table.cell(main_table, 0, 0, "TF", bgcolor=color_head, text_color=color_text, text_size=text_size)
    table.cell(main_table, 1, 0, "prev", bgcolor=color_head, text_color=color_text, text_size=text_size)
    table.cell(main_table, 2, 0, "vol", bgcolor=color_head, text_color=color_text, text_size=text_size)
    table.cell(main_table, 3, 0, "%chg", bgcolor=color_head, text_color=color_text, text_size=text_size)

    int row_ptr = 1

    // 1H Row
    if show_1h
        g1h = calc_growth(v1h, v1h_p)
        table.cell(main_table, 0, row_ptr, "1h", bgcolor=color_bg, text_color=color_text, text_size=text_size)
        table.cell(main_table, 1, row_ptr, format_vol(v1h_p), bgcolor=color_bg, text_color=color_text, text_size=text_size)
        table.cell(main_table, 2, row_ptr, format_vol(v1h), bgcolor=color_bg, text_color=color_text, text_size=text_size)
        table.cell(main_table, 3, row_ptr, str.format("{0,number,#}%", g1h), bgcolor=g1h >= 100 ? color_up : color_down, text_color=color_text, text_size=text_size)
        row_ptr += 1

    // 4H Row
    if show_4h
        g4h = calc_growth(v4h, v4h_p)
        table.cell(main_table, 0, row_ptr, "4h", bgcolor=color_bg, text_color=color_text, text_size=text_size)
        table.cell(main_table, 1, row_ptr, format_vol(v4h_p), bgcolor=color_bg, text_color=color_text, text_size=text_size)
        table.cell(main_table, 2, row_ptr, format_vol(v4h), bgcolor=color_bg, text_color=color_text, text_size=text_size)
        table.cell(main_table, 3, row_ptr, str.format("{0,number,#}%", g4h), bgcolor=g4h >= 100 ? color_up : color_down, text_color=color_text, text_size=text_size)
        row_ptr += 1

    // 1D Row
    if show_1d
        g1d = calc_growth(v1d, v1d_p)
        table.cell(main_table, 0, row_ptr, "1d", bgcolor=color_bg, text_color=color_text, text_size=text_size)
        table.cell(main_table, 1, row_ptr, format_vol(v1d_p), bgcolor=color_bg, text_color=color_text, text_size=text_size)
        table.cell(main_table, 2, row_ptr, format_vol(v1d), bgcolor=color_bg, text_color=color_text, text_size=text_size)
        table.cell(main_table, 3, row_ptr, str.format("{0,number,#}%", g1d), bgcolor=g1d >= 100 ? color_up : color_down, text_color=color_text, text_size=text_size)
````
