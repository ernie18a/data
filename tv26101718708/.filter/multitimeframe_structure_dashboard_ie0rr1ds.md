# Multi-Timeframe Structure Dashboard

- url: https://www.tradingview.com/script/ie0rR1DS-Multi-Timeframe-Structure-Dashboard/
- type: indicator
- pine_id: PUB;a6fd344e5b6347ee876e6c7fbfbb19a4
- version: 1.0

## Description

bias identification on multi time frame for easy identification.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © devnanthshaji97

//@version=6
indicator("Multi-Timeframe Structure Dashboard", overlay=true)

// --- Inputs ---
group_dash = "Dashboard Settings"
dash_pos   = input.string("top_right", title="Dashboard Position", options=["top_right", "top_left", "bottom_right", "bottom_left"], group=group_dash)
txt_color  = input.color(color.white, title="Text Color", group=group_dash)

// --- Helper function to calculate structure logic natively ---
f_calc_bias() =>
    lookback = 10
    highest_high = ta.highest(high, lookback)[1]
    lowest_low   = ta.lowest(low, lookback)[1]
    
    int bias = 0
    bias := close > highest_high ? 1 : (close < lowest_low ? -1 : nz(bias[1]))
    bias

// --- Fetch Data safely using Tuple to save performance ---
[bias_1m]  = request.security(syminfo.tickerid, "1", [f_calc_bias()])
[bias_5m]  = request.security(syminfo.tickerid, "5", [f_calc_bias()])
[bias_15m] = request.security(syminfo.tickerid, "15", [f_calc_bias()])
[bias_4h]  = request.security(syminfo.tickerid, "240", [f_calc_bias()])

// --- Map Position String to TradingView Position Constants ---
pos_val = dash_pos == "top_right" ? position.top_right :
          dash_pos == "top_left"   ? position.top_left :
          dash_pos == "bottom_right" ? position.bottom_right : position.bottom_left

// --- Create and Populate Table ---
var table dash = table.new(position=pos_val, columns=2, rows=5, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.gray)

// Helper function for row rendering (Must be declared in the global scope, not inside 'if')
f_set_row(table_id, row_idx, tf_text, bias_val, t_color) =>
    bg_col = bias_val == 1 ? color.green : (bias_val == -1 ? color.red : color.gray)
    txt_val = bias_val == 1 ? "BULLISH ▲" : (bias_val == -1 ? "BEARISH ▼" : "CHOPPY ▬")
    table.cell(table_id, 0, row_idx, tf_text, text_color=t_color, text_size=size.small)
    table.cell(table_id, 1, row_idx, txt_val, bgcolor=bg_col, text_color=t_color, text_size=size.small)

if barstate.islast
    // Table Headers
    table.cell(dash, 0, 0, "Timeframe", bgcolor=color.gray, text_color=txt_color, text_size=size.small)
    table.cell(dash, 1, 0, "Bias / Structure", bgcolor=color.gray, text_color=txt_color, text_size=size.small)
    
    // Populate Rows globally passed values
    f_set_row(dash, 1, "1M (Bias)", bias_1m, txt_color)
    f_set_row(dash, 2, "5M (Structure)", bias_5m, txt_color)
    f_set_row(dash, 3, "15M (Structure)", bias_15m, txt_color)
    f_set_row(dash, 4, "4H (Structure)", bias_4h, txt_color)
````
