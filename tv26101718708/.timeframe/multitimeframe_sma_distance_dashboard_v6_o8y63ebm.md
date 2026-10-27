# Multi-Timeframe SMA Distance Dashboard v6

- url: https://www.tradingview.com/script/o8Y63eBM-Multi-Timeframe-SMA-Distance-Dashboard-v6/
- type: indicator
- pine_id: PUB;730c8df73ee3482885ae61a31855b3c9
- version: 1.0

## Description

This is supposed to show at a glance distances from various moving averages at various intervals

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © jbrad4313

//@version=6
indicator("Multi-Timeframe SMA Distance Dashboard v6", overlay=true)

// ==========================================
// STYLE & POSITION INPUTS
// ==========================================
string g_table     = "Dashboard Settings"
string table_pos   = input.string("top_right", "Dashboard Position", options=["top_right", "bottom_right", "top_left", "bottom_left"], group=g_table)
string text_size   = input.string("small", "Text Size", options=["tiny", "small", "normal", "large"], group=g_table)
color text_color   = input.color(color.white, "Text Color", group=g_table)
color bg_header    = input.color(color.blue, "Header Background", group=g_table)
color bg_positive  = input.color(color.new(color.green, 30), "Positive (Above) Background", group=g_table)
color bg_negative  = input.color(color.new(color.red, 30), "Negative (Below) Background", group=g_table)

// ==========================================
// SECURITY CALLS (Limited to 10 for performance)
// ==========================================
// Fetching historical close arrays directly to minimize request.security calls
get_close(string tf) =>
    request.security(syminfo.tickerid, tf, close, barmerge.gaps_off, barmerge.lookahead_off)

c_5m   = get_close("5")
c_15m  = get_close("15")
c_30m  = get_close("30")
c_1h   = get_close("60")
c_2h   = get_close("120")
c_3h   = get_close("180")
c_4h   = get_close("240")
c_1d   = get_close("D")
c_1w   = get_close("W")
c_1mn  = get_close("M")

// ==========================================
// SMA DISTANCE CALCULATION FUNCTION
// ==========================================
get_distances(float tf_close) =>
    sma9   = ta.sma(tf_close, 9)
    sma20  = ta.sma(tf_close, 20)
    sma50  = ta.sma(tf_close, 50)
    sma100 = ta.sma(tf_close, 100)
    sma200 = ta.sma(tf_close, 200)
    
    // Calculate % distance: ((Price - SMA) / SMA) * 100
    dist9   = ((tf_close - sma9) / sma9) * 100
    dist20  = ((tf_close - sma20) / sma20) * 100
    dist50  = ((tf_close - sma50) / sma50) * 100
    dist100 = ((tf_close - sma100) / sma100) * 100
    dist200 = ((tf_close - sma200) / sma200) * 100
    
    [dist9, dist20, dist50, dist100, dist200]

// Process distances for all timeframes locally
[m5_9, m5_20, m5_50, m5_100, m5_200]     = get_distances(c_5m)
[m15_9, m15_20, m15_50, m15_100, m15_200] = get_distances(c_15m)
[m30_9, m30_20, m30_50, m30_100, m30_200] = get_distances(c_30m)
[h1_9, h1_20, h1_50, h1_100, h1_200]     = get_distances(c_1h)
[h2_9, h2_20, h2_50, h2_100, h2_200]     = get_distances(c_2h)
[h3_9, h3_20, h3_50, h3_100, h3_200]     = get_distances(c_3h)
[h4_9, h4_20, h4_50, h4_100, h4_200]     = get_distances(c_4h)
[d1_9, d1_20, d1_50, d1_100, d1_200]     = get_distances(c_1d)
[w1_9, w1_20, w1_50, w1_100, w1_200]     = get_distances(c_1w)
[mn1_9, mn1_20, mn1_50, mn1_100, mn1_200] = get_distances(c_1mn)

// ==========================================
// DASHBOARD GENERATION
// ==========================================
var table dashboard = table.new(position=table_pos, columns=11, rows=6, border_width=1, border_color=color.gray)

// Helper function to format cell content and color
fill_cell(table tbl, int col, int row, float val) =>
    string txt = str.tostring(val, "#.##") + "%"
    color bg   = val >= 0 ? bg_positive : bg_negative
    table.cell(tbl, col, row, txt, text_color=text_color, bgcolor=bg, text_size=text_size)

// Render on the last historical bar to optimize calculations
if barstate.islast
    // Headers: Timeframes
    table.cell(dashboard, 0, 0, "SMA / TF", text_color=text_color, bgcolor=bg_header, text_size=text_size)
    table.cell(dashboard, 1, 0, "5m",       text_color=text_color, bgcolor=bg_header, text_size=text_size)
    table.cell(dashboard, 2, 0, "15m",      text_color=text_color, bgcolor=bg_header, text_size=text_size)
    table.cell(dashboard, 3, 0, "30m",      text_color=text_color, bgcolor=bg_header, text_size=text_size)
    table.cell(dashboard, 4, 0, "1h",       text_color=text_color, bgcolor=bg_header, text_size=text_size)
    table.cell(dashboard, 5, 0, "2h",       text_color=text_color, bgcolor=bg_header, text_size=text_size)
    table.cell(dashboard, 6, 0, "3h",       text_color=text_color, bgcolor=bg_header, text_size=text_size)
    table.cell(dashboard, 7, 0, "4h",       text_color=text_color, bgcolor=bg_header, text_size=text_size)
    table.cell(dashboard, 8, 0, "1D",       text_color=text_color, bgcolor=bg_header, text_size=text_size)
    table.cell(dashboard, 9, 0, "1W",       text_color=text_color, bgcolor=bg_header, text_size=text_size)
    table.cell(dashboard, 10, 0, "1M",      text_color=text_color, bgcolor=bg_header, text_size=text_size)

    // Row Headers: SMAs
    table.cell(dashboard, 0, 1, "SMA 9",   text_color=text_color, bgcolor=bg_header, text_size=text_size)
    table.cell(dashboard, 0, 2, "SMA 20",  text_color=text_color, bgcolor=bg_header, text_size=text_size)
    table.cell(dashboard, 0, 3, "SMA 50",  text_color=text_color, bgcolor=bg_header, text_size=text_size)
    table.cell(dashboard, 0, 4, "SMA 100", text_color=text_color, bgcolor=bg_header, text_size=text_size)
    table.cell(dashboard, 0, 5, "SMA 200", text_color=text_color, bgcolor=bg_header, text_size=text_size)

    // Populate Row 1: SMA 9
    fill_cell(dashboard, 1, 1, m5_9), fill_cell(dashboard, 2, 1, m15_9), fill_cell(dashboard, 3, 1, m30_9)
    fill_cell(dashboard, 4, 1, h1_9), fill_cell(dashboard, 5, 1, h2_9),  fill_cell(dashboard, 6, 1, h3_9)
    fill_cell(dashboard, 7, 1, h4_9), fill_cell(dashboard, 8, 1, d1_9),  fill_cell(dashboard, 9, 1, w1_9), fill_cell(dashboard, 10, 1, mn1_9)

    // Populate Row 2: SMA 20
    fill_cell(dashboard, 1, 2, m5_20), fill_cell(dashboard, 2, 2, m15_20), fill_cell(dashboard, 3, 2, m30_20)
    fill_cell(dashboard, 4, 2, h1_20), fill_cell(dashboard, 5, 2, h2_20),  fill_cell(dashboard, 6, 2, h3_20)
    fill_cell(dashboard, 7, 2, h4_20), fill_cell(dashboard, 8, 2, d1_20),  fill_cell(dashboard, 9, 2, w1_20), fill_cell(dashboard, 10, 2, mn1_20)

    // Populate Row 3: SMA 50
    fill_cell(dashboard, 1, 3, m5_50), fill_cell(dashboard, 2, 3, m15_50), fill_cell(dashboard, 3, 3, m30_50)
    fill_cell(dashboard, 4, 3, h1_50), fill_cell(dashboard, 5, 3, h2_50),  fill_cell(dashboard, 6, 3, h3_50)
    fill_cell(dashboard, 7, 3, h4_50), fill_cell(dashboard, 8, 3, d1_50),  fill_cell(dashboard, 9, 3, w1_50), fill_cell(dashboard, 10, 3, mn1_50)

    // Populate Row 4: SMA 100
    fill_cell(dashboard, 1, 4, m5_100), fill_cell(dashboard, 2, 4, m15_100), fill_cell(dashboard, 3, 4, m30_100)
    fill_cell(dashboard, 4, 4, h1_100), fill_cell(dashboard, 5, 4, h2_100),  fill_cell(dashboard, 6, 4, h3_100)
    fill_cell(dashboard, 7, 4, h4_100), fill_cell(dashboard, 8, 4, d1_100),  fill_cell(dashboard, 9, 4, w1_100), fill_cell(dashboard, 10, 4, mn1_100)

    // Populate Row 5: SMA 200
    fill_cell(dashboard, 1, 5, m5_200), fill_cell(dashboard, 2, 5, m15_200), fill_cell(dashboard, 3, 5, m30_200)
    fill_cell(dashboard, 4, 5, h1_200), fill_cell(dashboard, 5, 5, h2_200),  fill_cell(dashboard, 6, 5, h3_200)
    fill_cell(dashboard, 7, 5, h4_200), fill_cell(dashboard, 8, 5, d1_200),  fill_cell(dashboard, 9, 5, w1_200), fill_cell(dashboard, 10, 5, mn1_200)
````
