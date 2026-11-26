# MTF Volume Footprint Dashboard - Visual Fix

- url: https://www.tradingview.com/script/hwvgrAqF-MTF-Volume-Footprint-Dashboard-Visual-Fix/
- type: indicator
- pine_id: PUB;0dc835aae2b246e991f54ce6258a681f
- version: 1.0

## Description

this is a multi time frame data table giving , buy and sell delta , along with cum delta .

## Source Code

````pine
//@version=5
indicator("MTF Volume Footprint Dashboard - Visual Fix", overlay=true)

// --- Inputs: Timeframes ---
tf1_in = input.timeframe("5", "TF 1")
tf2_in = input.timeframe("30", "TF 2")
tf3_in = input.timeframe("75", "TF 3")
tf4_in = input.timeframe("288", "TF 4")
tf5_in = input.timeframe("D", "TF 5")
tf6_in = input.timeframe("W", "TF 6")
tf7_in = input.timeframe("M", "TF 7")

// --- Toggles ---
show_tot  = input.bool(true, "Show Total Orders", group="Column Toggles")
show_buy  = input.bool(true, "Show Buy Volume", group="Column Toggles")
show_sel  = input.bool(true, "Show Sell Volume", group="Column Toggles")
show_net  = input.bool(true, "Show Net Delta", group="Column Toggles")
show_cum  = input.bool(true, "Show Cum Delta", group="Column Toggles")
show_sent = input.bool(true, "Show Sentiment", group="Column Toggles")
show_rsi  = input.bool(true, "Show RSI", group="Column Toggles")

// --- Inputs ---
vol_format = input.string("Formatted (M/B)", "Volume Display Unit", options=["Raw Numbers", "Formatted (M/B)"])
rsi_len = input.int(14, "RSI Length")

// --- Position ---
get_pos(p) => 
    switch p
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Top Center"    => position.top_center
        "Bottom Center" => position.bottom_center
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        => position.top_right

// --- Format ---
format_val(val) =>
    abs_val = math.abs(val)
    sign = val >= 0 ? "" : "-"
    if abs_val >= 1000000000 
        sign + str.tostring(abs_val / 1000000000, "#.##") + "B"
    else if abs_val >= 1000000 
        sign + str.tostring(abs_val / 1000000, "#.##") + "M"
    else if abs_val >= 1000 
        sign + str.tostring(abs_val / 1000, "#.##") + "K"
    else 
        sign + str.tostring(abs_val, "#")

// --- Delta ---
var float cumDelta = 0.0
cur_buy = volume * (close - low) / math.max(high - low, 0.000001)
cur_sel = volume - cur_buy
cur_d   = cur_buy - cur_sel
cumDelta := ta.change(time("D")) ? cur_d : cumDelta + cur_d

// --- Data ---
calc_data(tf) => request.security(syminfo.tickerid, tf, [volume, close, high, low, ta.rsi(close, rsi_len), cumDelta])

[v1,c1,h1,l1,r1,cd1] = calc_data(tf1_in)
[v2,c2,h2,l2,r2,cd2] = calc_data(tf2_in)
[v3,c3,h3,l3,r3,cd3] = calc_data(tf3_in)
[v4,c4,h4,l4,r4,cd4] = calc_data(tf4_in)
[v5,c5,h5,l5,r5,cd5] = calc_data(tf5_in)
[v6,c6,h6,l6,r6,cd6] = calc_data(tf6_in)
[v7,c7,h7,l7,r7,cd7] = calc_data(tf7_in)

// --- Colors ---
bull = color.rgb(0,255,150)
bear = color.rgb(255,80,80)
neutral = color.rgb(255,200,0)
dark_bg = color.rgb(25,25,30)

// --- Table ---
var tbl = table.new(get_pos("Top Right"), 10, 10, border_width=1)

// --- Row ---
render_row(row, tf, vol, close, high, low, rsi, cumD) =>
    b = vol * (close - low) / math.max(high - low, 0.000001)
    s = vol - b
    d = b - s
    
    col = 0
    table.cell(tbl, col, row, tf, bgcolor=dark_bg, text_color=color.white), col+=1

    if show_tot
        table.cell(tbl, col, row, format_val(vol), bgcolor=dark_bg, text_color=color.white), col+=1

    if show_buy
        table.cell(tbl, col, row, format_val(b), text_color=bull), col+=1

    if show_sel
        table.cell(tbl, col, row, format_val(s), text_color=bear), col+=1

    if show_net
        table.cell(tbl, col, row, format_val(d), text_color=d>0?bull:bear), col+=1

    if show_cum
        table.cell(tbl, col, row, format_val(cumD), bgcolor=color.new(d>0?bull:bear, 30), text_color=color.white), col+=1

    if show_sent
        table.cell(tbl, col, row, d>0?"Bullish":"Bearish", bgcolor=d>0?bull:bear, text_color=color.black), col+=1

    if show_rsi
        r_col = rsi > 60 ? bull : rsi < 40 ? bear : neutral
        table.cell(tbl, col, row, str.tostring(rsi, "#.#"), text_color=r_col), col+=1

// --- Header ---
if barstate.islast
    col = 0
    table.cell(tbl, col, 0, "TF", bgcolor=color.black, text_color=color.white), col+=1
    if show_tot
        table.cell(tbl, col, 0, "Total", bgcolor=color.black, text_color=color.white), col+=1
    if show_buy
        table.cell(tbl, col, 0, "Buy", bgcolor=color.black, text_color=bull), col+=1
    if show_sel
        table.cell(tbl, col, 0, "Sell", bgcolor=color.black, text_color=bear), col+=1
    if show_net
        table.cell(tbl, col, 0, "Net Delta", bgcolor=color.black, text_color=color.white), col+=1
    if show_cum
        table.cell(tbl, col, 0, "Cum Delta", bgcolor=color.black, text_color=color.white), col+=1
    if show_sent
        table.cell(tbl, col, 0, "Sentiment", bgcolor=color.black, text_color=color.white), col+=1
    if show_rsi
        table.cell(tbl, col, 0, "RSI", bgcolor=color.black, text_color=color.white), col+=1

    render_row(1, tf1_in, v1,c1,h1,l1,r1,cd1)
    render_row(2, tf2_in, v2,c2,h2,l2,r2,cd2)
    render_row(3, tf3_in, v3,c3,h3,l3,r3,cd3)
    render_row(4, tf4_in, v4,c4,h4,l4,r4,cd4)
    render_row(5, tf5_in, v5,c5,h5,l5,r5,cd5)
    render_row(6, tf6_in, v6,c6,h6,l6,r6,cd6)
    render_row(7, tf7_in, v7,c7,h7,l7,r7,cd7)
````
