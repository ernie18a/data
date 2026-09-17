<!-- tradingview-pine-id: PUB;72e803568e5f47b2abda64502ecb6c59 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# DISTANCE % PH-PL MTF Dashboard 

Source: https://www.tradingview.com/script/Rmc1P15l-DISTANCE-PH-PL-MTF-Dashboard/

## Description

This is a very comprehensive Pine Script indicator for TradingView that creates a multi-timeframe (MTF) dashboard showing price distance from period highs (PH) and lows (PL), along with retracement levels and trade suggestions.

Here's a detailed breakdown of what this indicator does and how to use it:

Core Functionality
1. Multi-Timeframe Dashboard
Displays data for up to 10 customizable timeframes (1min, 3min, 5min, 15min, 60min, 120min, 240min, Daily, Weekly, Monthly)

Shows the percentage distance from Period High and Period Low for each timeframe

Visual color coding (green for bullish, red for bearish, gray for neutral)

Customizable location (8 positions), size, colors, and transparency

2. Key Metrics Displayed
% PL (Distance from Period Low): How far current price is above the period low

% PH (Distance from Period High): How far current price is below the period high

Retracement Ratio: Position within the PH-PL range (0 = at PL, 1 = at PH)

Trade Suggestions: Generated based on PL%, PH%, and retracement values

3. Dynamic Length Settings
Each timeframe can have its own lookback period (length)

Toggle between dynamic (per timeframe) or common length

Default lengths: 200 bars for most timeframes, 104 for Weekly, 60 for Monthly

4. Alert System
PL% Extreme alerts (near period lows - oversold)

PH% Extreme alerts (near period highs - overbought)

New Period High/Low alerts

Retracement level alerts (customizable levels)

MTF Confluence alerts (when 3+ timeframes show same extreme)

Breakout alerts (price moves away from extreme levels)

Visual Elements
Dashboard Table
text
| Symbol | 1   | 3   | 5   | 15  | 60  | 120 | 240 | D   | W   | M   |
| % PL   | 2.5%| 1.8%| 3.2%| 0.5%| 4.1%| 6.2%| 8.1%| 2.3%| 5.7%| 9.4%|
| % PH   | 5.2%| 6.8%| 4.3%| 7.1%| 3.9%| 2.5%| 1.8%| 6.5%| 4.2%| 1.9%|
| Retr   | 0.32| 0.21| 0.43| 0.07| 0.51| 0.71| 0.82| 0.26| 0.58| 0.83|
| Signal | BUY | BUY | WATCH|BUY | NEUT|SELL |SELL |BUY | SELL |SELL |
Chart Plots
Distance from PH (red line)

Distance from PL (green line)

Retracement (white line, displayed as 0-100%)

Horizontal reference lines at 25%, 50%, 75%, 0%

Trade Suggestion Logic
Condition	Signal
PL > 70% AND Ret < 0.33	STRONG BUY
PL > 70%	BUY
Ret < 0.25	BUY ZONE
PH > 70% AND Ret > 0.66	STRONG SELL
PH > 70%	SELL
Ret > 0.75	SELL ZONE
Ret 0.45-0.55	NEUTRAL
Ret > 0.55	WATCH TOP
Ret < 0.45	WATCH BOTTOM
Key Input Settings
Timeframes
Customize each of the 10 timeframes using standard TradingView format (1, 3, 5, 15, 60, 120, 240, D, W, M)

Length Settings
Toggle dynamic length per timeframe

Set individual lengths for each timeframe

Default common length: 200 bars

Dashboard Display
Location: 8 positions

Size: Tiny, Small, Normal, Large

Customizable colors for bullish/bearish/neutral cells

Show/hide PH and PL prices

Show/hide retracement and trade suggestions

Alert Settings
Adjustable thresholds for PL% and PH% alerts (default: 50%)

Toggle specific alert types on/off

Customizable retracement levels (comma-separated)

MTF confluence threshold (default: 30%)

Usage Tips
For Swing Trading: Focus on higher timeframes (D, W, M) for trend identification

For Day Trading: Use lower timeframes (1-15min) for entry/exit signals

For Overbought/Oversold: Watch PL% > 70% (oversold) and PH% > 70% (overbought)

For Trend Reversals: Look for retracement moving from extremes (>0.66 or <0.33) back towards 0.5

FOR EDUCATIONAL PURPOSES ONLY\BOT A FINANCIAL ADVICE

---

## Source Code

````pine
//@version=6
indicator("DISTANCE % PH-PL MTF Dashboard ", overlay=true)


// ========== Timeframes ==========
TF1  = input.timeframe("1",   "TF1")
TF2  = input.timeframe("3",   "TF2")
TF3  = input.timeframe("5",   "TF3")
TF4  = input.timeframe("15",  "TF4")
TF5  = input.timeframe("60",  "TF5")
TF6  = input.timeframe("120", "TF6")
TF7  = input.timeframe("240", "TF7")
TF8  = input.timeframe("D",   "TF8")
TF9  = input.timeframe("W",   "TF9")
TF10 = input.timeframe("M",   "TF10")

// ========== Dashboard Style ==========
dash_loc          = input.string("Bottom Left", "Dashboard Location", options=["Top Right","Top Center","Top Left","Bottom Left","Bottom Center","Bottom Right","Middle Left","Middle Center","Middle Right"])
text_size         = input.string("Small", "Dashboard Size", options=["Tiny","Small","Normal","Large"])
cell_up           = input.color(#4caf50, "Bullish Cell Color")
cell_dn           = input.color(#FF5252, "Bearish Cell Color")
cell_neutral      = input.color(color.gray, "Neutral Cell Color")
txt_col           = input.color(color.white, "Text/Frame Color")
cell_transp       = input.int(25, "Cell Transparency", minval=0, maxval=100)

// ========== Length Settings ==========
use_dynamic_length = input.bool(true, "Use dynamic length per timeframe?", group="Length Settings")
common_length = input.int(200, "Common Length (if dynamic OFF)", minval=10, group="Length Settings")

// Individual lengths for each timeframe
length_1  = input.int(200, "Length for 1min", minval=10, group="Length Settings")
length_3  = input.int(200, "Length for 3min", minval=10, group="Length Settings")
length_5  = input.int(200, "Length for 5min", minval=10, group="Length Settings")
length_15 = input.int(200, "Length for 15min", minval=10, group="Length Settings")
length_60 = input.int(200, "Length for 60min", minval=10, group="Length Settings")
length_120 = input.int(200, "Length for 120min", minval=10, group="Length Settings")
length_240 = input.int(200, "Length for 240min", minval=10, group="Length Settings")
length_D = input.int(200, "Length for Daily", minval=10, group="Length Settings")
length_W = input.int(104, "Length for Weekly", minval=10, group="Length Settings")
length_M = input.int(60, "Length for Monthly", minval=10, group="Length Settings")

// ========== Other Inputs ==========
src = input.string(defval = 'High/Low', options = ['Close', 'High/Low'], group = 'High/Low')
show_table = input.bool(defval = true, title = 'Show table?')
show_retracement = input.bool(defval = false, title = 'Show Retracement Ratio?', group = 'Retracement')
reverse_retracement = input.bool(defval = false, title = 'Reverse Retracement?', group = 'Retracement')
show_retracement_in_dashboard = input.bool(defval = true, title = 'Show Retracement in Dashboard?', group = 'Dashboard')
show_suggestions = input.bool(defval = true, title = 'Show Trade Suggestions?', group = 'Dashboard')
show_pl_price = input.bool(defval = true, title = 'Show PL Price in %PL cell?', group = "Dashboard")
show_ph_price = input.bool(defval = true, title = 'Show PH Price in %PH cell?', group = "Dashboard")

// Price formatting
price_decimals = input.int(5, "Price Decimal Places", minval=0, maxval=8, group="Dashboard")

// Suggestion thresholds
suggestion_buy_threshold = input.int(70, "Buy Signal when PL% >", minval=30, maxval=90, group = "Suggestion Settings")
suggestion_sell_threshold = input.int(70, "Sell Signal when PH% >", minval=30, maxval=90, group = "Suggestion Settings")

// Source selection
hi_source = src == 'High/Low' ? high : close
lo_source = src == 'High/Low' ? low : close

// ========== Function to get length for a timeframe ==========
f_get_length(tf_string) =>
    if not use_dynamic_length
        common_length
    else
        switch tf_string
            "1"   => length_1
            "3"   => length_3
            "5"   => length_5
            "15"  => length_15
            "60"  => length_60
            "120" => length_120
            "240" => length_240
            "D"   => length_D
            "W"   => length_W
            "M"   => length_M
            => common_length

// ========== Function to calculate values for a specific length ==========
f_calculate_values(len) =>
    float highest_high = ta.highest(high, len)
    float lowest_low = ta.lowest(low, len)
    float pl_dist = math.round(100 * ((hi_source / lowest_low) - 1), 2)
    float ph_dist =- math.round(100 * (1 - (lo_source / highest_high)), 2)
    float ret = 0.0
    if highest_high != lowest_low
        ret := 1 - math.round((close - lowest_low) / (highest_high - lowest_low), 2)
        if reverse_retracement
            ret := math.round((close - lowest_low) / (highest_high - lowest_low), 2)
    [pl_dist, ph_dist, ret, highest_high, lowest_low]

// ========== Current Chart Values ==========
current_length = f_get_length("D")
[Distance_from_PL, Distance_from_PH, Retracement, current_PH, current_PL] = f_calculate_values(current_length)

// ========== MTF Values with Dynamic Lengths ==========
f_get_mtf(tf_string) =>
    len = f_get_length(tf_string)
    [mtf_pl, mtf_ph, mtf_ret, mtf_ph_price, mtf_pl_price] = request.security(syminfo.tickerid, tf_string, f_calculate_values(len), lookahead = barmerge.lookahead_off)
    [mtf_pl, mtf_ph, mtf_ret, mtf_ph_price, mtf_pl_price]

[l1, s1, r1, ph1, pl1] = f_get_mtf(TF1)
[l2, s2, r2, ph2, pl2] = f_get_mtf(TF2)
[l3, s3, r3, ph3, pl3] = f_get_mtf(TF3)
[l4, s4, r4, ph4, pl4] = f_get_mtf(TF4)
[l5, s5, r5, ph5, pl5] = f_get_mtf(TF5)
[l6, s6, r6, ph6, pl6] = f_get_mtf(TF6)
[l7, s7, r7, ph7, pl7] = f_get_mtf(TF7)
[l8, s8, r8, ph8, pl8] = f_get_mtf(TF8)
[l9, s9, r9, ph9, pl9] = f_get_mtf(TF9)
[l10,s10, r10, ph10, pl10] = f_get_mtf(TF10)

// ========== Function to format PL cell text ==========
f_format_pl_cell(pl_percent, pl_price, show_price, decimals) =>
    string price_str = show_price ? " $ " + str.tostring(pl_price, format.mintick) : ""
    str.tostring(pl_percent, "#.##") + "%" + price_str

// ========== Function to format PH cell text ==========
f_format_ph_cell(ph_percent, ph_price, show_price, decimals) =>
    string price_str = show_price ? " $" + str.tostring(ph_price, format.mintick) : ""
    str.tostring(ph_percent, "#.##") + "%" + price_str

// ========== Function to get cell color based on value ==========
f_cell_color(val) =>
    val > 0 ? color.new(cell_up, cell_transp) : val < 0 ? color.new(cell_dn, cell_transp) : color.new(cell_neutral, cell_transp)

// ========== Function to generate trade suggestion ==========
f_get_suggestion(pl, ph, ret, buy_thresh, sell_thresh) =>
    string suggestion = ""
    color sugg_color = color.new(color.gray, 0)
    
    // Buy conditions
    if pl > buy_thresh and ret < 0.33
        suggestion := "STRONG BUY"
        sugg_color := color.new(#00ff00, 0)
    else if pl > buy_thresh
        suggestion := "BUY"
        sugg_color := color.new(#4caf50, 0)
    else if ret < 0.25
        suggestion := "BUY ZONE"
        sugg_color := color.new(#66bb6a, 0)
    
    // Sell conditions
    else if ph > sell_thresh and ret > 0.66
        suggestion := "STRONG SELL"
        sugg_color := color.new(#ff0000, 0)
    else if ph > sell_thresh
        suggestion := "SELL"
        sugg_color := color.new(#FF5252, 0)
    else if ret > 0.75
        suggestion := "SELL ZONE"
        sugg_color := color.new(#ff7043, 0)
    
    // Neutral conditions
    else if ret >= 0.45 and ret <= 0.55
        suggestion := "NEUTRAL"
        sugg_color := color.new(color.gray, 0)
    else if ret > 0.55
        suggestion := "WATCH TOP"
        sugg_color := color.new(#ffa726, 0)
    else if ret < 0.45
        suggestion := "WATCH BOTTOM"
        sugg_color := color.new(#42a5f5, 0)
    else
        suggestion := "WAIT"
        sugg_color := color.new(color.gray, 0)
    
    [suggestion, sugg_color]

// Generate suggestions for each timeframe
[sugg1, col1] = f_get_suggestion(l1, s1, r1, suggestion_buy_threshold, suggestion_sell_threshold)
[sugg2, col2] = f_get_suggestion(l2, s2, r2, suggestion_buy_threshold, suggestion_sell_threshold)
[sugg3, col3] = f_get_suggestion(l3, s3, r3, suggestion_buy_threshold, suggestion_sell_threshold)
[sugg4, col4] = f_get_suggestion(l4, s4, r4, suggestion_buy_threshold, suggestion_sell_threshold)
[sugg5, col5] = f_get_suggestion(l5, s5, r5, suggestion_buy_threshold, suggestion_sell_threshold)
[sugg6, col6] = f_get_suggestion(l6, s6, r6, suggestion_buy_threshold, suggestion_sell_threshold)
[sugg7, col7] = f_get_suggestion(l7, s7, r7, suggestion_buy_threshold, suggestion_sell_threshold)
[sugg8, col8] = f_get_suggestion(l8, s8, r8, suggestion_buy_threshold, suggestion_sell_threshold)
[sugg9, col9] = f_get_suggestion(l9, s9, r9, suggestion_buy_threshold, suggestion_sell_threshold)
[sugg10, col10] = f_get_suggestion(l10, s10, r10, suggestion_buy_threshold, suggestion_sell_threshold)

// ========== Function for retracement cell color ==========
f_ret_color(val) =>
    val > 0.66 ? color.new(color.green, cell_transp) : val < 0.33 ? color.new(color.red, cell_transp) : color.new(color.orange, cell_transp)

// ========== Plots for current chart ==========
plot(Distance_from_PH, 'Distance from PH (%)', color=color.new(color.red, 0), linewidth=1)
plot(Distance_from_PL, 'Distance from PL (%)', color=color.new(color.green, 0), linewidth=1)
plot(Retracement * 100, 'Retracement', color=color.new(color.white, 0), linewidth=1)

// Horizontal lines
hline(75, '0.75', color=color.new(color.white, 60), linewidth=1)
hline(50, '0.50', color=color.new(color.white, 60), linewidth=1)
hline(25, '0.25', color=color.new(color.white, 60), linewidth=1)
hline(0, '0% line', color=color.new(color.white, 80))

// ========== Dashboard Table ==========
f_table_position(pos) =>
    switch pos
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        => position.bottom_left

f_table_size(sz) =>
    switch sz
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

// Determine number of rows
int num_rows = 3  // Header, %PL, %PH
if show_retracement_in_dashboard
    num_rows := num_rows + 1
if show_suggestions
    num_rows := num_rows + 1

var table dashboard = table.new(f_table_position(dash_loc), 11, num_rows, frame_color=txt_col, frame_width=1, border_color=txt_col, border_width=1)

if barstate.islast
    sz = f_table_size(text_size)
    int current_row = 0
    
    // HEADER ROW - Timeframes
    table.cell(dashboard, 0, current_row, syminfo.tickerid, text_color=txt_col, text_size=sz, bgcolor=color.black)
    table.cell(dashboard, 1, current_row, TF1,  text_color=txt_col, text_size=sz, bgcolor=color.black)
    table.cell(dashboard, 2, current_row, TF2,  text_color=txt_col, text_size=sz, bgcolor=color.black)
    table.cell(dashboard, 3, current_row, TF3,  text_color=txt_col, text_size=sz, bgcolor=color.black)
    table.cell(dashboard, 4, current_row, TF4,  text_color=txt_col, text_size=sz, bgcolor=color.black)
    table.cell(dashboard, 5, current_row, TF5,  text_color=txt_col, text_size=sz, bgcolor=color.black)
    table.cell(dashboard, 6, current_row, TF6,  text_color=txt_col, text_size=sz, bgcolor=color.black)
    table.cell(dashboard, 7, current_row, TF7,  text_color=txt_col, text_size=sz, bgcolor=color.black)
    table.cell(dashboard, 8, current_row, TF8,  text_color=txt_col, text_size=sz, bgcolor=color.black)
    table.cell(dashboard, 9, current_row, TF9,  text_color=txt_col, text_size=sz, bgcolor=color.black)
    table.cell(dashboard,10, current_row, TF10, text_color=txt_col, text_size=sz, bgcolor=color.black)
    current_row := current_row + 1
    
    // ROW: % PL (with PL Price)
    table.cell(dashboard, 0, current_row, "% PL", text_color=color.green, text_size=sz, bgcolor=color.black)
    table.cell(dashboard, 1, current_row, f_format_pl_cell(l1, pl1, show_pl_price, price_decimals), text_color=txt_col, text_size=sz, bgcolor=f_cell_color(l1))
    table.cell(dashboard, 2, current_row, f_format_pl_cell(l2, pl2, show_pl_price, price_decimals), text_color=txt_col, text_size=sz, bgcolor=f_cell_color(l2))
    table.cell(dashboard, 3, current_row, f_format_pl_cell(l3, pl3, show_pl_price, price_decimals), text_color=txt_col, text_size=sz, bgcolor=f_cell_color(l3))
    table.cell(dashboard, 4, current_row, f_format_pl_cell(l4, pl4, show_pl_price, price_decimals), text_color=txt_col, text_size=sz, bgcolor=f_cell_color(l4))
    table.cell(dashboard, 5, current_row, f_format_pl_cell(l5, pl5, show_pl_price, price_decimals), text_color=txt_col, text_size=sz, bgcolor=f_cell_color(l5))
    table.cell(dashboard, 6, current_row, f_format_pl_cell(l6, pl6, show_pl_price, price_decimals), text_color=txt_col, text_size=sz, bgcolor=f_cell_color(l6))
    table.cell(dashboard, 7, current_row, f_format_pl_cell(l7, pl7, show_pl_price, price_decimals), text_color=txt_col, text_size=sz, bgcolor=f_cell_color(l7))
    table.cell(dashboard, 8, current_row, f_format_pl_cell(l8, pl8, show_pl_price, price_decimals), text_color=txt_col, text_size=sz, bgcolor=f_cell_color(l8))
    table.cell(dashboard, 9, current_row, f_format_pl_cell(l9, pl9, show_pl_price, price_decimals), text_color=txt_col, text_size=sz, bgcolor=f_cell_color(l9))
    table.cell(dashboard,10, current_row, f_format_pl_cell(l10, pl10, show_pl_price, price_decimals), text_color=txt_col, text_size=sz, bgcolor=f_cell_color(l10))
    current_row := current_row + 1
    
    // ROW: % PH (with PH Price)
    table.cell(dashboard, 0, current_row, "% PH", text_color=color.red, text_size=sz, bgcolor=color.black)
    table.cell(dashboard, 1, current_row, f_format_ph_cell(s1, ph1, show_ph_price, price_decimals), text_color=txt_col, text_size=sz, bgcolor=f_cell_color(s1))
    table.cell(dashboard, 2, current_row, f_format_ph_cell(s2, ph2, show_ph_price, price_decimals), text_color=txt_col, text_size=sz, bgcolor=f_cell_color(s2))
    table.cell(dashboard, 3, current_row, f_format_ph_cell(s3, ph3, show_ph_price, price_decimals), text_color=txt_col, text_size=sz, bgcolor=f_cell_color(s3))
    table.cell(dashboard, 4, current_row, f_format_ph_cell(s4, ph4, show_ph_price, price_decimals), text_color=txt_col, text_size=sz, bgcolor=f_cell_color(s4))
    table.cell(dashboard, 5, current_row, f_format_ph_cell(s5, ph5, show_ph_price, price_decimals), text_color=txt_col, text_size=sz, bgcolor=f_cell_color(s5))
    table.cell(dashboard, 6, current_row, f_format_ph_cell(s6, ph6, show_ph_price, price_decimals), text_color=txt_col, text_size=sz, bgcolor=f_cell_color(s6))
    table.cell(dashboard, 7, current_row, f_format_ph_cell(s7, ph7, show_ph_price, price_decimals), text_color=txt_col, text_size=sz, bgcolor=f_cell_color(s7))
    table.cell(dashboard, 8, current_row, f_format_ph_cell(s8, ph8, show_ph_price, price_decimals), text_color=txt_col, text_size=sz, bgcolor=f_cell_color(s8))
    table.cell(dashboard, 9, current_row, f_format_ph_cell(s9, ph9, show_ph_price, price_decimals), text_color=txt_col, text_size=sz, bgcolor=f_cell_color(s9))
    table.cell(dashboard,10, current_row, f_format_ph_cell(s10, ph10, show_ph_price, price_decimals), text_color=txt_col, text_size=sz, bgcolor=f_cell_color(s10))
    current_row := current_row + 1
    
    // ROW: Retracement (optional)
    if show_retracement_in_dashboard
        table.cell(dashboard, 0, current_row, "Retr", text_color=color.white, text_size=sz, bgcolor=color.black)
        table.cell(dashboard, 1, current_row, str.tostring(r1, "#.##"), text_color=txt_col, text_size=sz, bgcolor=f_ret_color(r1))
        table.cell(dashboard, 2, current_row, str.tostring(r2, "#.##"), text_color=txt_col, text_size=sz, bgcolor=f_ret_color(r2))
        table.cell(dashboard, 3, current_row, str.tostring(r3, "#.##"), text_color=txt_col, text_size=sz, bgcolor=f_ret_color(r3))
        table.cell(dashboard, 4, current_row, str.tostring(r4, "#.##"), text_color=txt_col, text_size=sz, bgcolor=f_ret_color(r4))
        table.cell(dashboard, 5, current_row, str.tostring(r5, "#.##"), text_color=txt_col, text_size=sz, bgcolor=f_ret_color(r5))
        table.cell(dashboard, 6, current_row, str.tostring(r6, "#.##"), text_color=txt_col, text_size=sz, bgcolor=f_ret_color(r6))
        table.cell(dashboard, 7, current_row, str.tostring(r7, "#.##"), text_color=txt_col, text_size=sz, bgcolor=f_ret_color(r7))
        table.cell(dashboard, 8, current_row, str.tostring(r8, "#.##"), text_color=txt_col, text_size=sz, bgcolor=f_ret_color(r8))
        table.cell(dashboard, 9, current_row, str.tostring(r9, "#.##"), text_color=txt_col, text_size=sz, bgcolor=f_ret_color(r9))
        table.cell(dashboard,10, current_row, str.tostring(r10,"#.##"), text_color=txt_col, text_size=sz, bgcolor=f_ret_color(r10))
        current_row := current_row + 1
    
    // ROW: Trade Suggestions (optional)
    if show_suggestions
        table.cell(dashboard, 0, current_row, "Signal", text_color=color.yellow, text_size=sz, bgcolor=color.black)
        table.cell(dashboard, 1, current_row, sugg1, text_color=txt_col, text_size=sz, bgcolor=col1)
        table.cell(dashboard, 2, current_row, sugg2, text_color=txt_col, text_size=sz, bgcolor=col2)
        table.cell(dashboard, 3, current_row, sugg3, text_color=txt_col, text_size=sz, bgcolor=col3)
        table.cell(dashboard, 4, current_row, sugg4, text_color=txt_col, text_size=sz, bgcolor=col4)
        table.cell(dashboard, 5, current_row, sugg5, text_color=txt_col, text_size=sz, bgcolor=col5)
        table.cell(dashboard, 6, current_row, sugg6, text_color=txt_col, text_size=sz, bgcolor=col6)
        table.cell(dashboard, 7, current_row, sugg7, text_color=txt_col, text_size=sz, bgcolor=col7)
        table.cell(dashboard, 8, current_row, sugg8, text_color=txt_col, text_size=sz, bgcolor=col8)
        table.cell(dashboard, 9, current_row, sugg9, text_color=txt_col, text_size=sz, bgcolor=col9)
        table.cell(dashboard,10, current_row, sugg10, text_color=txt_col, text_size=sz, bgcolor=col10)


// ========== ALERTS ==========
// Alert 1: Distance from Period Low (PL) extremes
alert_pl_high = input.bool(true, "Alert when PL% > threshold?", group="Alerts")
alert_pl_threshold = input.int(50, "PL% Alert Threshold", minval=1, maxval=100, group="Alerts")
alert_pl_cross = input.bool(true, "Alert on PL% cross above threshold?", group="Alerts")

// Alert 2: Distance from Period High (PH) extremes  
alert_ph_high = input.bool(true, "Alert when PH% > threshold?", group="Alerts")
alert_ph_threshold = input.int(50, "PH% Alert Threshold", minval=1, maxval=100, group="Alerts")
alert_ph_cross = input.bool(true, "Alert on PH% cross above threshold?", group="Alerts")

// Alert 3: New highs/lows (PH/PL renewal)
alert_new_ph = input.bool(true, "Alert on new Period High?", group="Alerts")
alert_new_pl = input.bool(true, "Alert on new Period Low?", group="Alerts")

// Alert 4: Retracement levels
alert_retracement = input.bool(false, "Alert on retracement levels?", group="Alerts")
alert_retracement_levels = input.string("50,75", "Retracement alert levels (comma-separated)", group="Alerts")

// Alert 5: MTF confluence
alert_mtf_confluence = input.bool(false, "Alert on MTF confluence (3+ TFs showing same extreme)?", group="Alerts")
alert_mtf_threshold = input.int(30, "MTF Extreme Threshold %", minval=10, maxval=50, group="Alerts")

// ========== DECLARE PH_reached and PL_reached ==========
bool PH_reached = Distance_from_PH == 0
bool PL_reached = Distance_from_PL == 0

// ========== ALERT LOGIC ==========

// Alert 1: PL% Extreme (oversold conditions - price near period low)
bool pl_alert_trigger = false
if alert_pl_high
    if alert_pl_cross
        pl_alert_trigger = ta.cross(Distance_from_PL, alert_pl_threshold) or (Distance_from_PL > alert_pl_threshold and Distance_from_PL[1] <= alert_pl_threshold)
    else
        pl_alert_trigger = Distance_from_PL > alert_pl_threshold

// Alert 2: PH% Extreme (overbought conditions - price near period high)  
bool ph_alert_trigger = false
if alert_ph_high
    if alert_ph_cross
        ph_alert_trigger = ta.cross(Distance_from_PH, alert_ph_threshold) or (Distance_from_PH > alert_ph_threshold and Distance_from_PH[1] <= alert_ph_threshold)
    else
        ph_alert_trigger = Distance_from_PH > alert_ph_threshold

// Alert 3: New highs/lows
bool new_high_alert = alert_new_ph and PH_reached
bool new_low_alert = alert_new_pl and PL_reached

// Alert 4: Retracement levels
bool retracement_alert = false
if alert_retracement
    float retrace_pct = Retracement * 100
    string[] levels = str.split(alert_retracement_levels, ",")
    for i = 0 to array.size(levels) - 1
        float level = str.tonumber(array.get(levels, i))
        if not na(level)
            if ta.cross(retrace_pct, level)
                retracement_alert := true

// Alert 5: MTF Confluence
bool mtf_confluence_alert = false
int extreme_count = 0

if alert_mtf_confluence
    // Count extreme TFs (PL% > threshold)
    extreme_count := (l1 > alert_mtf_threshold ? 1 : 0) + (l2 > alert_mtf_threshold ? 1 : 0) + 
                     (l3 > alert_mtf_threshold ? 1 : 0) + (l4 > alert_mtf_threshold ? 1 : 0) +
                     (l5 > alert_mtf_threshold ? 1 : 0) + (l6 > alert_mtf_threshold ? 1 : 0) +
                     (l7 > alert_mtf_threshold ? 1 : 0) + (l8 > alert_mtf_threshold ? 1 : 0) +
                     (l9 > alert_mtf_threshold ? 1 : 0) + (l10 > alert_mtf_threshold ? 1 : 0)
    
    mtf_confluence_alert := extreme_count >= 3

// Alert 6: Breakout from range (PL% crosses below threshold after being high)
bool breakout_alert = false
if alert_pl_high
    bool was_extreme_pl = Distance_from_PL[1] > alert_pl_threshold
    bool now_normal_pl = Distance_from_PL <= alert_pl_threshold
    breakout_alert = was_extreme_pl and now_normal_pl

// ========== TRIGGER ALERTS ==========
// PL% Alert
if pl_alert_trigger
    alert("🔵 PL% ALERT: " + syminfo.tickerid + " is " + str.tostring(Distance_from_PL, "#.##") + "% above Period Low (Threshold: " + str.tostring(alert_pl_threshold) + "%)")

// PH% Alert
if ph_alert_trigger  
    alert("🔴 PH% ALERT: " + syminfo.tickerid + " is " + str.tostring(Distance_from_PH, "#.##") + "% below Period High (Threshold: " + str.tostring(alert_ph_threshold) + "%)")

// New Period High Alert
if new_high_alert
    alert("📈 NEW PERIOD HIGH: " + syminfo.tickerid + " reached new " + str.tostring(current_length) + "-bar high at " + str.tostring(high, format.mintick))

// New Period Low Alert
if new_low_alert
    alert("📉 NEW PERIOD LOW: " + syminfo.tickerid + " reached new " + str.tostring(current_length) + "-bar low at " + str.tostring(low, format.mintick))

// Retracement Alert
if retracement_alert
    alert("🔄 RETRACEMENT: " + syminfo.tickerid + " at " + str.tostring(Retracement * 100, "#.##") + "% retracement level")

// MTF Confluence Alert
if mtf_confluence_alert
    alert("🎯 MTF CONFLUENCE: " + str.tostring(extreme_count) + " timeframes show PL% > " + str.tostring(alert_mtf_threshold) + "% on " )

// Breakout Alert
if breakout_alert
    alert("🚀 BREAKOUT: " + syminfo.tickerid + " broke above " + str.tostring(alert_pl_threshold) + "% PL level!")
````
