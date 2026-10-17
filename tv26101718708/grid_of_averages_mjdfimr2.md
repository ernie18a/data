# Grid of averages

- url: https://www.tradingview.com/script/MjDfimr2-grid-of-averages/
- type: indicator
- pine_id: PUB;96bd084728f64637b207b88cfc694273
- version: 5.0

## Description

"Grid of Averages" - Smart DCA Levels & Take Profit Calculator

This indicator visualizes a dollar-cost averaging (DCA) strategy with up to 4 averaging levels. It automatically calculates entry prices, position volumes, and take-profit targets based on your balance and risk parameters. The tool displays a clear table with all key metrics and draws horizontal levels directly on the chart, helping you plan your grid trading strategy effortlessly.

Perfect for traders who want to predefine their averaging zones and exit points before entering a position.

## Source Code

````pine
//@version=6
indicator("Grid of averages", overlay=true, max_labels_count=500)

// ============================================
// 1. STRATEGY SETTINGS
// ============================================
position_type = input.string("Buy", "Position", group="Strategy Settings", options=["Buy", "Sell"])
balance_input = input.float(1000.0, "Balance ($)", group="Strategy Settings", step=1, minval=0)
price_input = input.float(100.0, "Entry Price", group="Strategy Settings", step=0.01)
volume_percent = input.float(10.0, "Entry Volume (%)", group="Strategy Settings", step=0.1, minval=0, maxval=100)
take_profit_percent = input.float(5.0, "Take Profit (%)", group="Strategy Settings", step=0.1, minval=0)

// ============================================
// 2. AVERAGING LEVELS
// ============================================
avg1_type = input.string("Percent", "1 Average", group="Averaging Levels", options=["Percent", "Price"], inline="avg1")
avg1_value = input.float(10.0, "", group="Averaging Levels", step=0.1, minval=0, inline="avg1")

avg2_type = input.string("Percent", "2 Average", group="Averaging Levels", options=["Percent", "Price"], inline="avg2")
avg2_value = input.float(15.0, "", group="Averaging Levels", step=0.1, minval=0, inline="avg2")

avg3_type = input.string("Percent", "3 Average", group="Averaging Levels", options=["Percent", "Price"], inline="avg3")
avg3_value = input.float(20.0, "", group="Averaging Levels", step=0.1, minval=0, inline="avg3")

avg4_type = input.string("Percent", "4 Average", group="Averaging Levels", options=["Percent", "Price"], inline="avg4")
avg4_value = input.float(25.0, "", group="Averaging Levels", step=0.1, minval=0, inline="avg4")

// ============================================
// 3. VISUAL SETTINGS
// ============================================
entry_volume_display = input.string("Dollar", "Volume (open)", group="Visual Settings", options=["Dollar", "Coin"])
exit_volume_display = input.string("Coin", "Volume (close)", group="Visual Settings", options=["Dollar", "Coin"])
price_decimals = input.int(2, "Price decimals", group="Visual Settings", minval=0, maxval=8, step=1)
coin_decimals = input.int(2, "Coin decimals", group="Visual Settings", minval=0, maxval=8, step=1)
show_lines = input.bool(true, "Show levels on chart", group="Visual Settings")

// ============================================
// HELPER FUNCTIONS
// ============================================
round_coins(float usd, float price) =>
    float lot_step = syminfo.mincontract
    math.floor((usd / price) / lot_step) * lot_step

round_price(float value) =>
    float multiplier = math.pow(10, price_decimals)
    math.round(value * multiplier) / multiplier

// ============================================
// CALCULATIONS
// ============================================
dir_multiplier = position_type == "Buy" ? 1 : -1

entry = round_price(price_input)
vol_entry = balance_input * (volume_percent / 100)
contracts_entry = round_coins(vol_entry, entry)
spent_entry = contracts_entry * entry

avg1_price = avg1_type == "Percent" ? round_price(entry * (1 - dir_multiplier * avg1_value / 100)) : round_price(avg1_value)
vol_avg1_order = vol_entry * 2 
contracts_avg1 = round_coins(vol_avg1_order, avg1_price)

total_contracts_1 = contracts_entry + contracts_avg1
total_spent_1 = spent_entry + (contracts_avg1 * avg1_price)

avg1_avg_price = round_price(total_spent_1 / total_contracts_1)
avg1_take = round_price(avg1_avg_price * (1 + dir_multiplier * take_profit_percent / 100))

avg2_price = avg2_type == "Percent" ? round_price(avg1_avg_price * (1 - dir_multiplier * avg2_value / 100)) : round_price(avg2_value)
vol_avg2_order = total_spent_1 * 2
contracts_avg2 = round_coins(vol_avg2_order, avg2_price)

total_contracts_2 = total_contracts_1 + contracts_avg2
total_spent_2 = total_spent_1 + (contracts_avg2 * avg2_price)

avg2_avg_price = round_price(total_spent_2 / total_contracts_2)
avg2_take = round_price(avg2_avg_price * (1 + dir_multiplier * take_profit_percent / 100))

avg3_price = avg3_type == "Percent" ? round_price(avg2_avg_price * (1 - dir_multiplier * avg3_value / 100)) : round_price(avg3_value)
vol_avg3_order = vol_avg2_order * 2
contracts_avg3 = round_coins(vol_avg3_order, avg3_price)

total_contracts_3 = total_contracts_2 + contracts_avg3
total_spent_3 = total_spent_2 + (contracts_avg3 * avg3_price)

avg3_avg_price = round_price(total_spent_3 / total_contracts_3)
avg3_take = round_price(avg3_avg_price * (1 + dir_multiplier * take_profit_percent / 100))

avg4_price = avg4_type == "Percent" ? round_price(avg3_avg_price * (1 - dir_multiplier * avg4_value / 100)) : round_price(avg4_value)
vol_avg4_order = vol_avg3_order * 2
contracts_avg4 = round_coins(vol_avg4_order, avg4_price)

total_contracts_4 = total_contracts_3 + contracts_avg4
total_spent_4 = total_spent_3 + (contracts_avg4 * avg4_price)

avg4_avg_price = round_price(total_spent_4 / total_contracts_4)
avg4_take = round_price(avg4_avg_price * (1 + dir_multiplier * take_profit_percent / 100))

take_entry = round_price(entry * (1 + dir_multiplier * take_profit_percent / 100))

// ============================================
// DRAW LINES
// ============================================
if show_lines and barstate.islast
    line.new(bar_index[1], entry, bar_index, entry, color=color.green, width=1, style=line.style_solid, extend=extend.right)
    line.new(bar_index[1], take_entry, bar_index, take_entry, color=color.lime, width=1, style=line.style_dashed, extend=extend.right)
    
    line.new(bar_index[1], avg1_price, bar_index, avg1_price, color=color.blue, width=1, style=line.style_solid, extend=extend.right)
    line.new(bar_index[1], avg1_take, bar_index, avg1_take, color=color.aqua, width=1, style=line.style_dashed, extend=extend.right)
    
    line.new(bar_index[1], avg2_price, bar_index, avg2_price, color=color.orange, width=1, style=line.style_solid, extend=extend.right)
    line.new(bar_index[1], avg2_take, bar_index, avg2_take, color=color.yellow, width=1, style=line.style_dashed, extend=extend.right)
    
    line.new(bar_index[1], avg3_price, bar_index, avg3_price, color=color.purple, width=1, style=line.style_solid, extend=extend.right)
    line.new(bar_index[1], avg3_take, bar_index, avg3_take, color=color.fuchsia, width=1, style=line.style_dashed, extend=extend.right)
    
    line.new(bar_index[1], avg4_price, bar_index, avg4_price, color=color.maroon, width=1, style=line.style_solid, extend=extend.right)
    line.new(bar_index[1], avg4_take, bar_index, avg4_take, color=color.red, width=1, style=line.style_dashed, extend=extend.right)

// ============================================
// TABLE
// ============================================
var table tbl = table.new(position.bottom_right, 5, 7, border_width=1, border_color=color.white, bgcolor=color.gray, frame_color=color.white, frame_width=1)

if barstate.islast
    price_format = "#." + str.repeat("#", price_decimals)
    coin_format = "#." + str.repeat("#", coin_decimals)
    volume_format = "#.00"
    
    color headerBg = color.new(#11182b, 0)
    
    table.cell(tbl, 0, 0, "Open Position", text_color=color.white, bgcolor=headerBg, text_size=size.small)
    table.cell(tbl, 1, 0, "", text_color=color.white, bgcolor=headerBg, text_size=size.small)
    table.cell(tbl, 2, 0, "", text_color=color.white, bgcolor=headerBg, text_size=size.small)
    table.cell(tbl, 3, 0, "Close Position", text_color=color.white, bgcolor=headerBg, text_size=size.small)
    table.cell(tbl, 4, 0, "", text_color=color.white, bgcolor=headerBg, text_size=size.small)
    
    table.merge_cells(tbl, 0, 0, 2, 0)
    table.merge_cells(tbl, 3, 0, 4, 0)
    
    table.cell(tbl, 0, 1, "Action", text_color=color.white, bgcolor=headerBg, text_size=size.small)
    table.cell(tbl, 1, 1, "Price", text_color=color.white, bgcolor=headerBg, text_size=size.small)
    table.cell(tbl, 2, 1, "Volume", text_color=color.white, bgcolor=headerBg, text_size=size.small)
    table.cell(tbl, 3, 1, "Price", text_color=color.white, bgcolor=headerBg, text_size=size.small)
    table.cell(tbl, 4, 1, "Volume", text_color=color.white, bgcolor=headerBg, text_size=size.small)

    exit_value_entry = contracts_entry * take_entry
    exit_value_1 = total_contracts_1 * avg1_take
    exit_value_2 = total_contracts_2 * avg2_take
    exit_value_3 = total_contracts_3 * avg3_take
    exit_value_4 = total_contracts_4 * avg4_take

    vol_entry_text = entry_volume_display == "Dollar" ? "$" + str.tostring(math.round(vol_entry * 100) / 100, volume_format) : str.tostring(contracts_entry, coin_format)
    vol_avg1_text = entry_volume_display == "Dollar" ? "$" + str.tostring(math.round(vol_avg1_order * 100) / 100, volume_format) : str.tostring(contracts_avg1, coin_format)
    vol_avg2_text = entry_volume_display == "Dollar" ? "$" + str.tostring(math.round(vol_avg2_order * 100) / 100, volume_format) : str.tostring(contracts_avg2, coin_format)
    vol_avg3_text = entry_volume_display == "Dollar" ? "$" + str.tostring(math.round(vol_avg3_order * 100) / 100, volume_format) : str.tostring(contracts_avg3, coin_format)
    vol_avg4_text = entry_volume_display == "Dollar" ? "$" + str.tostring(math.round(vol_avg4_order * 100) / 100, volume_format) : str.tostring(contracts_avg4, coin_format)

    exit_value_entry_text = exit_volume_display == "Dollar" ? "$" + str.tostring(math.round(exit_value_entry * 100) / 100, volume_format) : str.tostring(contracts_entry, coin_format)
    exit_value_1_text = exit_volume_display == "Dollar" ? "$" + str.tostring(math.round(exit_value_1 * 100) / 100, volume_format) : str.tostring(total_contracts_1, coin_format)
    exit_value_2_text = exit_volume_display == "Dollar" ? "$" + str.tostring(math.round(exit_value_2 * 100) / 100, volume_format) : str.tostring(total_contracts_2, coin_format)
    exit_value_3_text = exit_volume_display == "Dollar" ? "$" + str.tostring(math.round(exit_value_3 * 100) / 100, volume_format) : str.tostring(total_contracts_3, coin_format)
    exit_value_4_text = exit_volume_display == "Dollar" ? "$" + str.tostring(math.round(exit_value_4 * 100) / 100, volume_format) : str.tostring(total_contracts_4, coin_format)

    table.cell(tbl, 0, 2, "Entry", text_color=color.white, bgcolor=color.green, text_size=size.small)
    table.cell(tbl, 1, 2, str.tostring(entry, price_format), text_color=color.white, bgcolor=color.green, text_size=size.small)
    table.cell(tbl, 2, 2, vol_entry_text, text_color=color.white, bgcolor=color.green, text_size=size.small)
    table.cell(tbl, 3, 2, str.tostring(take_entry, price_format), text_color=color.white, bgcolor=color.green, text_size=size.small)
    table.cell(tbl, 4, 2, exit_value_entry_text, text_color=color.white, bgcolor=color.green, text_size=size.small)

    table.cell(tbl, 0, 3, "1 Avg", text_color=color.white, bgcolor=color.blue, text_size=size.small)
    table.cell(tbl, 1, 3, str.tostring(avg1_price, price_format), text_color=color.white, bgcolor=color.blue, text_size=size.small)
    table.cell(tbl, 2, 3, vol_avg1_text, text_color=color.white, bgcolor=color.blue, text_size=size.small)
    table.cell(tbl, 3, 3, str.tostring(avg1_take, price_format), text_color=color.white, bgcolor=color.blue, text_size=size.small)
    table.cell(tbl, 4, 3, exit_value_1_text, text_color=color.white, bgcolor=color.blue, text_size=size.small)

    table.cell(tbl, 0, 4, "2 Avg", text_color=color.white, bgcolor=color.orange, text_size=size.small)
    table.cell(tbl, 1, 4, str.tostring(avg2_price, price_format), text_color=color.white, bgcolor=color.orange, text_size=size.small)
    table.cell(tbl, 2, 4, vol_avg2_text, text_color=color.white, bgcolor=color.orange, text_size=size.small)
    table.cell(tbl, 3, 4, str.tostring(avg2_take, price_format), text_color=color.white, bgcolor=color.orange, text_size=size.small)
    table.cell(tbl, 4, 4, exit_value_2_text, text_color=color.white, bgcolor=color.orange, text_size=size.small)

    table.cell(tbl, 0, 5, "3 Avg", text_color=color.white, bgcolor=color.purple, text_size=size.small)
    table.cell(tbl, 1, 5, str.tostring(avg3_price, price_format), text_color=color.white, bgcolor=color.purple, text_size=size.small)
    table.cell(tbl, 2, 5, vol_avg3_text, text_color=color.white, bgcolor=color.purple, text_size=size.small)
    table.cell(tbl, 3, 5, str.tostring(avg3_take, price_format), text_color=color.white, bgcolor=color.purple, text_size=size.small)
    table.cell(tbl, 4, 5, exit_value_3_text, text_color=color.white, bgcolor=color.purple, text_size=size.small)

    table.cell(tbl, 0, 6, "4 Avg", text_color=color.white, bgcolor=color.maroon, text_size=size.small)
    table.cell(tbl, 1, 6, str.tostring(avg4_price, price_format), text_color=color.white, bgcolor=color.maroon, text_size=size.small)
    table.cell(tbl, 2, 6, vol_avg4_text, text_color=color.white, bgcolor=color.maroon, text_size=size.small)
    table.cell(tbl, 3, 6, str.tostring(avg4_take, price_format), text_color=color.white, bgcolor=color.maroon, text_size=size.small)
    table.cell(tbl, 4, 6, exit_value_4_text, text_color=color.white, bgcolor=color.maroon, text_size=size.small)
````
