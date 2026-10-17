# MTF Volume Footprint & RSI Dashboard

- url: https://www.tradingview.com/script/WJD2lUeu-MTF-Volume-Footprint-RSI-Dashboard/
- type: indicator
- pine_id: PUB;8b553d71fec341df96ff95874491d4fb
- version: 1.0

## Description

multi time frame delta volume and rsi, give analysis with sentiment

## Source Code

````pine
//@version=5
indicator("MTF Volume Footprint & RSI Dashboard", overlay=true)

// --- Inputs ---
tf1_input = input.timeframe("5", "Timeframe 1")
tf2_input = input.timeframe("30", "Timeframe 2")
tf3_input = input.timeframe("75", "Timeframe 3")
tf4_input = input.timeframe("288", "Timeframe 4")
tf5_input = input.timeframe("D", "Timeframe 5")
tf6_input = input.timeframe("W", "Timeframe 6")
tf7_input = input.timeframe("M", "Timeframe 7")

rsi_len = input.int(14, "RSI Length")

// Table UI Settings
table_pos = input.string("Top Right", "Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Top Center", "Bottom Center", "Middle Right", "Middle Left"])
table_size = input.string("Small", "Table Size", options=["Tiny", "Small", "Normal", "Large"])
table_orient = input.string("Vertical", "Orientation", options=["Horizontal", "Vertical"])

// --- Functions & Calculations ---
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

get_size(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

// Volume Footprint Calculation
calc_data(tf) =>
    request.security(syminfo.tickerid, tf, [volume, close, high, low, ta.rsi(close, rsi_len)])

[v1, c1, h1, l1, rsi1] = calc_data(tf1_input)
[v2, c2, h2, l2, rsi2] = calc_data(tf2_input)
[v3, c3, h3, l3, rsi3] = calc_data(tf3_input)
[v4, c4, h4, l4, rsi4] = calc_data(tf4_input)
[v5, c5, h5, l5, rsi5] = calc_data(tf5_input)
[v6, c6, h6, l6, rsi6] = calc_data(tf6_input)
[v7, c7, h7, l7, rsi7] = calc_data(tf7_input)

// Formatter for Millions/Billions
format_vol(val) =>
    if val >= 1000000000
        str.tostring(val / 1000000000, "#.##") + "B"
    else if val >= 1000000
        str.tostring(val / 1000000, "#.##") + "M"
    else
        str.tostring(val / 1000, "#.##") + "K"

// Processing each TF row
render_row(tbl, row, tf_name, vol, close, high, low, rsi) =>
    buy_vol = vol * (close - low) / (high - low)
    sell_vol = vol - buy_vol
    net_order = buy_vol - sell_vol
    sentiment = net_order > 0 ? "Bullish" : "Bearish"
    sent_color = net_order > 0 ? color.green : color.red
    
    col = 0
    if table_orient == "Vertical"
        table.cell(tbl, 0, row, tf_name, bgcolor=color.gray)
        table.cell(tbl, 1, row, format_vol(buy_vol), text_color=color.green)
        table.cell(tbl, 2, row, format_vol(sell_vol), text_color=color.red)
        table.cell(tbl, 3, row, format_vol(net_order), text_color=sent_color)
        table.cell(tbl, 4, row, sentiment, bgcolor=sent_color, text_color=color.white)
        table.cell(tbl, 5, row, str.tostring(rsi, "#.##"))
    else
        table.cell(tbl, row, 0, tf_name, bgcolor=color.gray)
        table.cell(tbl, row, 1, "B:" + format_vol(buy_vol), text_color=color.green)
        table.cell(tbl, row, 2, "S:" + format_vol(sell_vol), text_color=color.red)
        table.cell(tbl, row, 3, "Net:" + format_vol(net_order))
        table.cell(tbl, row, 4, sentiment, bgcolor=sent_color, text_color=color.white)
        table.cell(tbl, row, 5, "RSI:" + str.tostring(rsi, "#.##"))

// --- Table Setup ---
var main_table = table.new(get_pos(table_pos), 8, 8, border_width=1, frame_width=1)
if barstate.islast
    // Header setup
    if table_orient == "Vertical"
        table.cell(main_table, 0, 0, "Timeframe", bgcolor=color.black, text_color=color.white)
        table.cell(main_table, 1, 0, "Buy Vol", bgcolor=color.black, text_color=color.white)
        table.cell(main_table, 2, 0, "Sell Vol", bgcolor=color.black, text_color=color.white)
        table.cell(main_table, 3, 0, "Net Order", bgcolor=color.black, text_color=color.white)
        table.cell(main_table, 4, 0, "Sentiment", bgcolor=color.black, text_color=color.white)
        table.cell(main_table, 5, 0, "RSI", bgcolor=color.black, text_color=color.white)
    
    render_row(main_table, 1, tf1_input, v1, c1, h1, l1, rsi1)
    render_row(main_table, 2, tf2_input, v2, c2, h2, l2, rsi2)
    render_row(main_table, 3, tf3_input, v3, c3, h3, l3, rsi3)
    render_row(main_table, 4, tf4_input, v4, c4, h4, l4, rsi4)
    render_row(main_table, 5, tf5_input, v5, c5, h5, l5, rsi5)
    render_row(main_table, 6, tf6_input, v6, c6, h6, l6, rsi6)
    render_row(main_table, 7, tf7_input, v7, c7, h7, l7, rsi7)
````
