<!-- tradingview-pine-id: PUB;0237bddd93e7445f9ccb2dca475f9097 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Hourly Alpha Profile Terminal [The Quant Science]

Source: https://www.tradingview.com/script/qRYFrOJy-Hourly-Alpha-Profile-Terminal-The-Quant-Science/

## Description

Hourly Alpha Profile Terminal is an advanced quantitative analysis tool developed for the TradingView platform, designed for traders operating on intraday timeframes up to 60 minutes. Its main goal is to unveil the hidden structure of price volatility and directionality on an hourly basis, focusing on a specific day of the week chosen by the user. Instead of relying on traditional momentum indicators, this script historically maps market behavior hour by hour, calculating win rates and risk intensity for all 24 hours of the day.
[image]https://www.tradingview.com/x/V1wBxzDl/[/image]

🔷 What It Does
The script performs real-time statistical and visual analysis directly on the chart through two dedicated quantitative terminals. 

The Win Rate Profile Terminal divides the entire day into 24 hourly slots from 00:00 to 23:59, analyzes how many hourly cycles closed bullish compared to the total for the selected day of the week, and returns a success percentage win rate and an explicit directional bias of bullish, bearish, or neutral, accompanied by a visual progress bar. 
[image]https://www.tradingview.com/x/98GFB8TU/[/image]

The Volatility Profile Terminal calculates the logarithmically normalized standard deviation of hourly returns for each time slot, generating a volatility index and risk-based intensity bars to identify precisely which hour of the day experiences the most violent price movements as the peak risk slot.
[image]https://www.tradingview.com/x/Y5gjfNAG/[/image]

🔷 How to Use It
To obtain correct data, the indicator requires an intraday timeframe less than or equal to 60 minutes, such as 1m, 5m, 15m, or 60m. If applied to daily, weekly, or higher charts, the terminal blocks execution and displays an error warning. 
[image]https://www.tradingview.com/x/sDZt2HlF/[/image]

Add the script to your intraday chart on TradingView, open the indicator settings to select the day of the week you want to analyze, and observe the overlapping tables on the chart to identify hours with high win rates above 55% for trend opportunities or hours with extreme volatility for risk management.

🔷 What It Is Used For

[*]Hourly Seasonality Analysis for discovering during which times of day a given asset historically shows a strong directional tendency. 
[*]Entry Timing Optimization for avoiding false breakouts during low-directionality or erratic risk hours and focusing on statistical high-probability slots. 
[*]Risk Management and Volatility Mapping for understanding when the market becomes more volatile to prevent excessive slippage or correctly position stop losses based on peak risk hours.

🔷 Who Uses It

[*]Day Traders and Scalpers who need a statistical edge based on recurring market behaviors during trading sessions like the London or New York opens. 
[*]Quantitative and Systematic Traders looking to filter operational setups by integrating hourly probability matrices. 
[*]Market Analysts seeking an objective and visual reading of market microstructure without cluttering the chart with classic oscillators.

🔷 User Interface Management

[*]Settings: Day to Analyze allows you to choose the day of the week to analyze from Monday to Sunday. 
[*]Win Rate Terminal Position allows you to position the probability table in your preferred corner of the screen using options like Top Right, Top Left, Bottom Right, Bottom Left, or Center. 
[*]Win Rate Terminal Size lets you adjust the text size inside the table to Small, Normal, or Large. 
[*]Volatility Terminal Position manages the screen position of the volatility table. 
[*]Volatility Terminal Size modifies the text size of the volatility table to fit any screen resolution.

[image]https://www.tradingview.com/x/pr4vXMvY/[/image]

🔷  To be used in combination with the Bias Detector Terminal
This script completes a suite consisting of two scripts: 

🔹 Bias Detector Terminal used to find a day with a bias. For example, by analyzing Bitcoin on a Daily timeframe, we find a bias for Saturday.
[image]https://www.tradingview.com/x/seEYxZi8/[/image]
👉 Bias Detector Terminal: [https://www.tradingview.com/script/ZW5kc0FI-Bias-Detector-Terminal-The-Quant-Science/](https://www.tradingview.com/script/ZW5kc0FI-Bias-Detector-Terminal-The-Quant-Science/)

🔹 Hourly Alpha Profile Terminal let us dive deeper into the market and analyze the Saturday intraday session.
[image]https://www.tradingview.com/x/ZUa2MaDj/[/image]

---

## Source Code

````pine
//@version=6
indicator("Hourly Alpha Profile Terminal [The Quant Science]", overlay=true)

if timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly or (timeframe.isintraday and timeframe.multiplier > 60)
    runtime.error("🔴 [TERMINAL ERROR]: works only on intraday time frames ≤ 60 minutes (e.g., 1, 5, 15, 60).")

selected_day_input = input.string("Monday", "Day to Analyze", options=["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"], group="Settings")

win_rate_pos_input = input.string("Bottom Right", "Win Rate Terminal Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Center"], group="Win Rate Terminal")
win_rate_size_input = input.string("Small", "Win Rate Terminal Size", options=["Small", "Normal", "Large"], group="Win Rate Terminal")

volatility_pos_input = input.string("Bottom Left", "Volatility Terminal Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Center"], group="Volatility Terminal")
volatility_size_input = input.string("Small", "Volatility Terminal Size", options=["Small", "Normal", "Large"], group="Volatility Terminal")

target_day_idx = switch selected_day_input
    "Monday"    => 0
    "Tuesday"   => 1
    "Wednesday" => 2
    "Thursday"  => 3
    "Friday"    => 4
    "Saturday"  => 5
    "Sunday"    => 6
    => 0

get_table_pos(string pos_str) =>
    switch pos_str
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Center"       => position.middle_center
        => position.top_right

get_text_size(string size_str) =>
    switch size_str
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.normal

var string wr_table_pos  = get_table_pos(win_rate_pos_input)
var string wr_text_size  = get_text_size(win_rate_size_input)

var string vol_table_pos = get_table_pos(volatility_pos_input)
var string vol_text_size = get_text_size(volatility_size_input)

var array<int> bull_hours_count  = array.new_int(24, 0)
var array<int> total_hours_count = array.new_int(24, 0)

var matrix<float> h_returns = matrix.new<float>(0, 24)

current_hour = hour(time, syminfo.timezone)
current_day  = (dayofweek(time, syminfo.timezone) + 5) % 7 

var float h_open = na
var int   h_hour = na
var int   h_day  = na

bool hour_changed = ta.change(current_hour) != 0

if hour_changed or barstate.isfirst
    if not barstate.isfirst and not na(h_open) and (h_day == target_day_idx)
        bool is_bull = close[1] > h_open
        array.set(total_hours_count, h_hour, array.get(total_hours_count, h_hour) + 1)
        if is_bull
            array.set(bull_hours_count, h_hour, array.get(bull_hours_count, h_hour) + 1)

        float log_return = math.log(close[1] / h_open)
        matrix.add_row(h_returns)
        int last_row = matrix.rows(h_returns) - 1
        matrix.set(h_returns, last_row, h_hour, log_return)

    h_open := open
    h_hour := current_hour
    h_day  := current_day

if barstate.islast and not na(h_open) and (h_day == target_day_idx)
    float current_log_return = math.log(close / h_open)
    matrix.add_row(h_returns)
    int last_row = matrix.rows(h_returns) - 1
    matrix.set(h_returns, last_row, h_hour, current_log_return)

get_hour_array(int h) =>
    array<float> result = array.new_float(0)
    int rows_count = matrix.rows(h_returns)
    if rows_count > 0
        for r = 0 to rows_count - 1
            float val = matrix.get(h_returns, r, h)
            if not na(val)
                array.push(result, val)
    result

get_quant_profile_bar(float pct) =>
    int blocks = math.round(pct / 10.0)
    blocks := math.max(0, math.min(10, blocks))
    string active_block = "█"
    string fill = str.repeat(active_block, blocks)
    string void = str.repeat("░", 10 - blocks)
    string dir = pct >= 55.0 ? "▲ " : (pct <= 45.0 ? "▼ " : "► ")
    dir + fill + void

get_quant_gauge(float val, float max_val, int resolution = 8) =>
    if max_val == 0 or val == 0
        "[" + str.repeat("·", resolution) + "]"
    else
        float ratio = val / max_val
        int active_count = math.round(ratio * resolution)
        active_count := math.max(0, math.min(resolution, active_count))
        "[" + str.repeat("█", active_count) + str.repeat("░", resolution - active_count) + "]"

var table hft_table = table.new(wr_table_pos, 5, 28, bgcolor=#030712, border_width=2, border_color=#00f2fe)

if barstate.islast
    var array<int> temp_total = array.new_int(24, 0)
    var array<int> temp_bull  = array.new_int(24, 0)
    
    temp_total := array.copy(total_hours_count)
    temp_bull  := array.copy(bull_hours_count)
    
    if not na(h_open) and (h_day == target_day_idx)
        bool is_bull_current = close > h_open
        array.set(temp_total, h_hour, array.get(temp_total, h_hour) + 1)
        if is_bull_current
            array.set(temp_bull, h_hour, array.get(temp_bull, h_hour) + 1)

    string title_text = " WIN_RATE_PROFILE [" + str.upper(selected_day_input) + "]"
    table.cell(hft_table, 0, 0, title_text, bgcolor=#050b14, text_color=#00f2fe, text_size=wr_text_size)
    table.merge_cells(hft_table, 0, 0, 4, 0)

    string sys_status = "● DETECTOR_ACTIVE | TF: " + timeframe.period + "m | TARGET: " + selected_day_input + " | SAMPLE_BARS: " + str.tostring(bar_index + 1)
    table.cell(hft_table, 0, 1, sys_status, bgcolor=#030712, text_color=#00ff87, text_size=size.small)
    table.merge_cells(hft_table, 0, 1, 4, 1)

    table.cell(hft_table, 0, 2, "[HOUR_SLOT]",   bgcolor=#0d1527, text_color=#00f2fe, text_size=wr_text_size)
    table.cell(hft_table, 1, 2, "[BULL / TOT]",   bgcolor=#0d1527, text_color=#00f2fe, text_size=wr_text_size)
    table.cell(hft_table, 2, 2, "[WIN_RATE]",    bgcolor=#0d1527, text_color=#00f2fe, text_size=wr_text_size)
    table.cell(hft_table, 3, 2, "[SIGNAL_BIAS]", bgcolor=#0d1527, text_color=#00f2fe, text_size=wr_text_size)
    table.cell(hft_table, 4, 2, "[QUANT_FLOW_PROFILE]", bgcolor=#0d1527, text_color=#00f2fe, text_size=wr_text_size)

    int grand_total_bull = 0
    int grand_total_bars = 0

    for h = 0 to 23
        int bull = array.get(temp_bull, h)
        int total = array.get(temp_total, h)
        
        grand_total_bull += bull
        grand_total_bars += total

        string hour_slot_str = str.format("{0,number,00}:00 - {1,number,00}:59", h, h)
        int row = h + 3

        if total > 0
            float pct = (bull / float(total)) * 100.0
            
            color txt_color = pct >= 55.0 ? #00ff87 : (pct <= 45.0 ? #ff0055 : #f8fafc)
            color cell_bg   = pct >= 55.0 ? color.new(#00ff87, 88) : (pct <= 45.0 ? color.new(#ff0055, 88) : #090d16)
            
            string bias_str = pct >= 55.0 ? "[ BULLISH ]" : (pct <= 45.0 ? "[ BEARISH ]" : "[ NEUTRAL ]")
            string progress_visual = get_quant_profile_bar(pct)
            string ratio_str = str.tostring(bull) + " / " + str.tostring(total)

            table.cell(hft_table, 0, row, hour_slot_str,    bgcolor=#090d16, text_color=#f8fafc, text_size=wr_text_size)
            table.cell(hft_table, 1, row, ratio_str,       bgcolor=cell_bg, text_color=#f8fafc, text_size=wr_text_size)
            table.cell(hft_table, 2, row, str.tostring(pct, "#") + "%", bgcolor=cell_bg, text_color=txt_color, text_size=wr_text_size)
            table.cell(hft_table, 3, row, bias_str,        bgcolor=cell_bg, text_color=txt_color, text_size=wr_text_size)
            table.cell(hft_table, 4, row, progress_visual, bgcolor=cell_bg, text_color=txt_color, text_size=wr_text_size)
        else
            table.cell(hft_table, 0, row, hour_slot_str, bgcolor=#090d16, text_color=#64748b, text_size=wr_text_size)
            table.cell(hft_table, 1, row, "0 / 0",     bgcolor=#090d16, text_color=#64748b, text_size=wr_text_size)
            table.cell(hft_table, 2, row, "N/A",       bgcolor=#090d16, text_color=#64748b, text_size=wr_text_size)
            table.cell(hft_table, 3, row, "[ NO_DATA ]",bgcolor=#090d16, text_color=#64748b, text_size=wr_text_size)
            table.cell(hft_table, 4, row, "░░░░░░░░░░", bgcolor=#090d16, text_color=#64748b, text_size=wr_text_size)

    if grand_total_bars > 0
        float avg_pct = (grand_total_bull / float(grand_total_bars)) * 100.0
        string total_bar_visual = get_quant_profile_bar(avg_pct)
        string total_ratio = str.tostring(grand_total_bull) + " / " + str.tostring(grand_total_bars)
        
        table.cell(hft_table, 0, 27, " DAY_TOTAL", bgcolor=#0d1527, text_color=#00f2fe, text_size=wr_text_size)
        table.cell(hft_table, 1, 27, total_ratio,      bgcolor=#0d1527, text_color=#f8fafc, text_size=wr_text_size)
        table.cell(hft_table, 2, 27, str.tostring(avg_pct, "#") + "%", bgcolor=#0d1527, text_color=#00f2fe, text_size=wr_text_size)
        table.cell(hft_table, 3, 27, "[ COMPOSITE ]", bgcolor=#0d1527, text_color=#00f2fe, text_size=wr_text_size)
        table.cell(hft_table, 4, 27, total_bar_visual,  bgcolor=#0d1527, text_color=#00f2fe, text_size=wr_text_size)

var table quant_hud = table.new(vol_table_pos, 4, 28, bgcolor=#020617, border_width=1, border_color=#00f0ff)

if barstate.islast
    table.cell(quant_hud, 0, 0, " VOLATILITY_PROFILE [" + str.upper(selected_day_input) + "]" , bgcolor=#030712, text_color=#00f0ff, text_size=vol_text_size)
    table.merge_cells(quant_hud, 0, 0, 3, 0)

    table.cell(quant_hud, 0, 1, "● RISK ENGINE | DAY: " + str.upper(selected_day_input) + " | TF: " + timeframe.period + "M", bgcolor=#020617, text_color=#00ff87, text_size=size.small)
    table.merge_cells(quant_hud, 0, 1, 3, 1)

    table.cell(quant_hud, 0, 2, "[HOUR]",          bgcolor=#0f172a, text_color=#00f0ff, text_size=vol_text_size)
    table.cell(quant_hud, 1, 2, "[STD DEV %]",     bgcolor=#0f172a, text_color=#00f0ff, text_size=vol_text_size)
    table.cell(quant_hud, 2, 2, "[VOL INDEX]",     bgcolor=#0f172a, text_color=#00f0ff, text_size=vol_text_size)
    table.cell(quant_hud, 3, 2, "[INTENSITY]",      bgcolor=#0f172a, text_color=#00f0ff, text_size=vol_text_size)

    var array<float> hourly_std_dev = array.new_float(24, 0.0)
    float max_std_dev = 0.0
    int peak_rng_hour = 0

    for h = 0 to 23
        array<float> current_arr = get_hour_array(h)
        float s_dev = array.stdev(current_arr) * 100.0
        
        array.set(hourly_std_dev, h, na(s_dev) ? 0.0 : s_dev)
        
        if not na(s_dev) and s_dev > max_std_dev
            max_std_dev := s_dev
            peak_rng_hour := h

    for h = 0 to 23
        float cur_std_dev = array.get(hourly_std_dev, h)
        
        float vol_index = max_std_dev > 0 ? (cur_std_dev / max_std_dev) * 100.0 : 0.0
        bool is_peak  = (h == peak_rng_hour) and (max_std_dev > 0)

        string hour_str  = (is_peak ? "▲ " : "  ") + (h < 10 ? "0" : "") + str.tostring(h) + ":00"
        color cell_color = is_peak ? #ffb703 : (cur_std_dev > max_std_dev * 0.7 ? #ff007f : #67e8f9)
        color cell_bg    = is_peak ? #4c0519 : #020617

        table.cell(quant_hud, 0, h + 3, hour_str, bgcolor=cell_bg, text_color=is_peak ? #ffb703 : #e0e7ff, text_size=vol_text_size)
        table.cell(quant_hud, 1, h + 3, str.tostring(cur_std_dev, "0.000") + "%", bgcolor=cell_bg, text_color=cell_color, text_size=vol_text_size)
        table.cell(quant_hud, 2, h + 3, str.tostring(vol_index, "0.0") + " idx", bgcolor=cell_bg, text_color=cell_color, text_size=vol_text_size)
        
        string gauge = get_quant_gauge(cur_std_dev, max_std_dev, 8)
        table.cell(quant_hud, 3, h + 3, gauge, bgcolor=cell_bg, text_color=cell_color, text_size=vol_text_size)

    table.cell(quant_hud, 0, 27, "PEAK RISK SLOT", bgcolor=#0f172a, text_color=#00f0ff, text_size=vol_text_size)
    string peak_info = "MAX STD DEV: " + str.tostring(max_std_dev, "0.000") + "% [" + (peak_rng_hour < 10 ? "0" : "") + str.tostring(peak_rng_hour) + ":00]"
    table.cell(quant_hud, 1, 27, peak_info, bgcolor=#0f172a, text_color=#ff007f, text_size=vol_text_size)
    table.merge_cells(quant_hud, 1, 27, 3, 27)
````
