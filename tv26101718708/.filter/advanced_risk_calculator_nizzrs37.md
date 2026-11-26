# Advanced Risk Calculator

- url: https://www.tradingview.com/script/NiZzRS37-Advanced-Risk-Calculator/
- type: indicator
- pine_id: PUB;5d1d3ff7afef4a59af99c6324118d049
- version: 2.0

## Description

Risk calculator for swing trading.
Calculates the distance between the current price and the low of the day and bases risk amount on that.

## Source Code

````pine
//@version=6
indicator("📊 Advanced Risk Calculator ", overlay=true)

// === INPUTS ===
account_size   = input.float(4000.0, title="💰 Account Size ($)", step=100.0)
use_live_entry = input.bool(true, title="Use Current Price as Entry?")
entry_manual   = input.float(100.0, title="Manual Entry Price ($)")
use_lod_stop   = input.bool(true, title="Use Low of Day as Stop?")
stop_manual    = input.float(90.0, title="Manual Stop Price ($)")
show_decimals  = input.int(2, "Decimals in table", minval=0, maxval=6)
show_table     = input.bool(true, "Show Table")
custom_risk_pct = input.float(0.0, "Custom Risk % (optional)", minval=0.0, step=0.01)

// === TABLE POSITION ===
table_pos_input = input.string("Bottom Right", "Table Position",
     options=["Top Right","Top Left","Bottom Left","Bottom Right"])

// veilige if/else voor table position
table_pos = position.top_right  // default
if table_pos_input == "Top Right"
    table_pos := position.top_right
else if table_pos_input == "Top Left"
    table_pos := position.top_left
else if table_pos_input == "Bottom Left"
    table_pos := position.bottom_left
else
    table_pos := position.bottom_right

// === SESSION-AWARE LOW OF THE DAY (auto via chart timezone) ===
var float low_of_day = na
is_new_day = ta.change(time("D")) != 0  // detecteer nieuwe dag
if is_new_day
    low_of_day := na

// update live LOD
if na(low_of_day)
    low_of_day := low
else
    low_of_day := math.min(low_of_day, low)

// === ENTRY / STOP CHOICE ===
stop_price = use_lod_stop ? low_of_day : stop_manual
entry_price = use_live_entry ? close : entry_manual

// === CALCULATIONS ===
risk_per_share = entry_price - stop_price

// basisrisico's
risk_levels = array.from(1.0, 0.5, 0.25)
// check voor custom risk
if custom_risk_pct > 0
    array.push(risk_levels, custom_risk_pct)

// === TABLE SETUP ===
headers = array.from("Risk %", "Risk ($)", "Shares", "Position ($)", "% Account", "Entry ($)", "Stop ($)")
cols = array.size(headers)
needed_rows = 1 + array.size(risk_levels)   // header + data
buffer_rows = 3                             // safety
rows = needed_rows + buffer_rows

var table riskTable = na
if na(riskTable)
    riskTable := table.new(table_pos, cols, rows, border_color=color.new(color.white, 80))

// === FORMAT HELPER ===
fmt_num(v) =>
    if na(v)
        "-"
    else
        d = show_decimals
        if d == 0
            str.tostring(v, "#")
        else if d == 1
            str.tostring(v, "#.#")
        else if d == 2
            str.tostring(v, "#.##")
        else if d == 3
            str.tostring(v, "#.###")
        else if d == 4
            str.tostring(v, "#.####")
        else if d == 5
            str.tostring(v, "#.#####")
        else
            str.tostring(v, "#.######")

// === DRAW / UPDATE TABLE ===
if show_table
    // header row
    for ci = 0 to cols - 1
        table.cell(riskTable, 0, ci, array.get(headers, ci), text_color=color.white, bgcolor=color.new(color.blue, 75), text_size=size.small)

    // data rows
    for ri = 0 to array.size(risk_levels) - 1
        row_index = ri + 1
        if row_index < rows
            risk_pct = array.get(risk_levels, ri)
            risk_amount = account_size * (risk_pct / 100.0)
            shares = (risk_per_share > 0) ? math.floor(risk_amount / risk_per_share) : na
            position_value = (not na(shares)) ? (shares * entry_price) : na
            percent_account = (not na(position_value)) ? (position_value / account_size * 100.0) : na

            s_risk_pct = str.tostring(risk_pct, "#.##") + "%"
            s_risk_amount = na(risk_amount) ? "-" : "$" + fmt_num(risk_amount)
            s_shares = na(shares) ? "-" : str.tostring(shares)
            s_position = na(position_value) ? "-" : "$" + fmt_num(position_value)
            s_percent_account = na(percent_account) ? "-" : str.tostring(percent_account, "#.##") + "%"
            s_entry = na(entry_price) ? "-" : "$" + fmt_num(entry_price)
            s_stop = na(stop_price) ? "-" : "$" + fmt_num(stop_price)

            // achtergrondkleur: standaard blauw, custom risk groen
            bgcolor_cell = color.new(#31658f, 82)
            if ri == array.size(risk_levels) - 1 and custom_risk_pct > 0
                bgcolor_cell := color.new(color.green, 75)

            table.cell(riskTable, row_index, 0, s_risk_pct, text_color=color.white, bgcolor=bgcolor_cell)
            table.cell(riskTable, row_index, 1, s_risk_amount, text_color=color.white, bgcolor=bgcolor_cell)
            table.cell(riskTable, row_index, 2, s_shares, text_color=color.white, bgcolor=bgcolor_cell)
            table.cell(riskTable, row_index, 3, s_position, text_color=color.white, bgcolor=bgcolor_cell)
            table.cell(riskTable, row_index, 4, s_percent_account, text_color=color.white, bgcolor=bgcolor_cell)
            table.cell(riskTable, row_index, 5, s_entry, text_color=color.white, bgcolor=bgcolor_cell)
            table.cell(riskTable, row_index, 6, s_stop, text_color=color.white, bgcolor=bgcolor_cell)

// === Top summary label
var label titleLabel = na
title_txt = "Entry: " + (na(entry_price) ? "na" : "$" + fmt_num(entry_price)) + " | Stop: " + (na(stop_price) ? "na" : "$" + fmt_num(stop_price))
if barstate.islast
    if not na(titleLabel)
        label.delete(titleLabel)
    titleLabel := label.new(bar_index, high, title_txt, style=label.style_label_left, textcolor=color.white, color=color.new(#1b66b1, 85), size=size.small)
````
