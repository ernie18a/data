<!-- tradingview-pine-id: PUB;5c770e5ae80f4106b549a4a47a6bb70d -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Bias Detector Terminal [The Quant Science]

Source: https://www.tradingview.com/script/ZW5kc0FI-Bias-Detector-Terminal-The-Quant-Science/

## Description

Bias Detector Terminal is a quantitative analysis tool designed to identify day-of-week statistical bias and seasonality. By calculating the historical frequency of bullish closes for each trading day, the terminal provides a clear picture of directional market probabilities.
[image]https://www.tradingview.com/x/XrnSOBRV/[/image]
[image]https://www.tradingview.com/x/qi7euFuu/[/image]

🔷 What it does
The indicator analyzes daily price history to calculate:

[*]Bullish Ratio: The number of bullish sessions (close > open) relative to total historical bars for each day of the week (Monday to Sunday).
[*]Session Win Rate: The exact percentage of positive closes for every trading day.
[*]Smart Bias Signals: Categorizes each session based on statistical thresholds:

[*]🟢 [ BULLISH ]: Win Rate >= 55%
[*]🔴 [ BEARISH ]: Win Rate <= 45%
[*]⚪ [ NEUTRAL ]: Win Rate between 45% and 55%

[*]Visual Flow Profile: An inline progress bar for instant visual assessment of buy/sell pressure.
[*]Composite Metrics: A summary row showing the cumulative baseline for all historical data analyzed.

🔷 How to use it

[*]Chart Application: Add the script to the chart of your chosen asset (Stocks, Crypto, Forex, Indices).
[*]Timeframe Setting: Make sure the chart is set to the Daily (1D/Daily) timeframe. The script includes a built-in check that will trigger an error if applied to lower timeframes.
[image]https://www.tradingview.com/x/koIbnKF8/[/image]

🔷 Interface Customization 
Through the indicator settings you can:

[*]Change the console position on screen (Top Right, Top Left, Bottom Right, Bottom Left, Center).
[*]Modify the terminal font size (Small, Normal, Large).

[image]https://www.tradingview.com/x/ZBcOegtb/[/image]

🔷 Use Cases

[*]Weekly Operational Planning: Identify in advance which days of the week historically favor buyers or sellers from a statistical standpoint.
[*]Confluence Filter: Avoid opening short positions on days with a historically high bullish win rate (and vice versa), raising the overall quality of your trade setups.
[*]Seasonality Analysis: Determine if a specific asset exhibits recurring statistical patterns (e.g., Turnaround Tuesday or Friday weakness).

🔷 Target Audience

[*]Quant & Systematic Traders: For those who base their decisions on statistical data rather than gut feeling.
[*]Day Traders & Swing Traders: Useful for aligning intraday operations with the statistical trend of the current day.
[*]Market Analysts: For those who want to integrate high-level visual reporting and quantitative metrics into their TradingView analysis.

---

## Source Code

````pine
//@version=6
indicator("Bias Detector Terminal [The Quant Science]", overlay=true)

if not timeframe.isdaily
    runtime.error("🔴 [BIAS TERMINAL ERROR]: Requires DAILY (D) chart context.")

table_pos_input = input.string("Top Right", "Console Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Center"])
text_size_input = input.string("Normal", "Terminal Font Size", options=["Small", "Normal", "Large"])

var string table_pos = switch table_pos_input
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    "Center"       => position.middle_center
    => position.top_right

var string t_size = switch text_size_input
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    => size.normal
           
var array<int> bull_days_count  = array.new_int(7, 0)
var array<int> total_days_count = array.new_int(7, 0)

day_idx = (dayofweek + 5) % 7
is_bullish = close > open

array.set(total_days_count, day_idx, array.get(total_days_count, day_idx) + 1)
if is_bullish
    array.set(bull_days_count, day_idx, array.get(bull_days_count, day_idx) + 1)

getQuantProfileBar(float pct) =>
    int blocks = math.round(pct / 10.0)
    blocks := math.max(0, math.min(10, blocks))
    string active_block = "█"
    string fill = str.repeat(active_block, blocks)
    string void = str.repeat("░", 10 - blocks)
    
    string dir = pct >= 55.0 ? "▲ " : (pct <= 45.0 ? "▼ " : "► ")
    dir + fill + void

var table bias_table = table.new(table_pos, 5, 11, bgcolor=#030712, border_width=2, border_color=#00f2fe)

if barstate.islast

    table.cell(bias_table, 0, 0, "🎲 BIAS_DETECTOR_TERMINAL // DAY_OF_WEEK_ALPHA", bgcolor=#050b14, text_color=#00f2fe, text_size=t_size)
    table.merge_cells(bias_table, 0, 0, 4, 0)

    string sys_status = "● DETECTOR_ACTIVE | TF: 1D | ENGINE: PINE_v6 | SAMPLE_BARS: " + str.tostring(bar_index + 1)
    table.cell(bias_table, 0, 1, sys_status, bgcolor=#030712, text_color=#00f2fe , text_size=size.small)
    table.merge_cells(bias_table, 0, 1, 4, 1)

    table.cell(bias_table, 0, 2, "[DAY_SESSION]", bgcolor=#0d1527, text_color=#00f2fe, text_size=t_size)
    table.cell(bias_table, 1, 2, "[BULL / TOT]", bgcolor=#0d1527, text_color=#00f2fe, text_size=t_size)
    table.cell(bias_table, 2, 2, "[WIN_RATE]", bgcolor=#0d1527, text_color=#00f2fe, text_size=t_size)
    table.cell(bias_table, 3, 2, "[SIGNAL_BIAS]", bgcolor=#0d1527, text_color=#00f2fe, text_size=t_size)
    table.cell(bias_table, 4, 2, "[FLOW_PROFILE]", bgcolor=#0d1527, text_color=#00f2fe, text_size=t_size)

    array<string> day_names = array.new_string(7)
    array.set(day_names, 0, "MON_SESSION")
    array.set(day_names, 1, "TUE_SESSION")
    array.set(day_names, 2, "WED_SESSION")
    array.set(day_names, 3, "THU_SESSION")
    array.set(day_names, 4, "FRI_SESSION")
    array.set(day_names, 5, "SAT_SESSION")
    array.set(day_names, 6, "SUN_SESSION")

    int grand_total_bull = 0
    int grand_total_bars = 0

    for i = 0 to 6
        int bull = array.get(bull_days_count, i)
        int total = array.get(total_days_count, i)
        
        grand_total_bull += bull
        grand_total_bars += total

        if total > 0
            float pct = (bull / float(total)) * 100.0
            
            color txt_color = pct >= 55.0 ? #00ff87 : (pct <= 45.0 ? #ff0055 : #f8fafc)
            color cell_bg = pct >= 55.0 ? color.new(#00ff87, 88) : (pct <= 45.0 ? color.new(#ff0055, 88) : #090d16)
            
            string bias_str = pct >= 55.0 ? "[ BULLISH ]" : (pct <= 45.0 ? "[ BEARISH ]" : "[ NEUTRAL ]")
            
            int row = i + 3
            string progress_visual = getQuantProfileBar(pct)
            string ratio_str = str.tostring(bull) + " / " + str.tostring(total)

            table.cell(bias_table, 0, row, array.get(day_names, i), bgcolor=#090d16, text_color=#f8fafc, text_size=t_size)
            table.cell(bias_table, 1, row, ratio_str, bgcolor=cell_bg, text_color=#f8fafc, text_size=t_size)
            table.cell(bias_table, 2, row, str.tostring(pct, "#") + "%", bgcolor=cell_bg, text_color=txt_color, text_size=t_size)
            table.cell(bias_table, 3, row, bias_str, bgcolor=cell_bg, text_color=txt_color, text_size=t_size)
            table.cell(bias_table, 4, row, progress_visual, bgcolor=cell_bg, text_color=txt_color, text_size=t_size)

    if grand_total_bars > 0
        float avg_pct = (grand_total_bull / float(grand_total_bars)) * 100.0
        string total_bar_visual = getQuantProfileBar(avg_pct)
        string total_ratio = str.tostring(grand_total_bull) + " / " + str.tostring(grand_total_bars)
        
        table.cell(bias_table, 0, 10, "[ TOTAL ]", bgcolor=#0d1527, text_color=#00f2fe, text_size=t_size)
        table.cell(bias_table, 1, 10, total_ratio, bgcolor=#0d1527, text_color=#f8fafc, text_size=t_size)
        table.cell(bias_table, 2, 10, str.tostring(avg_pct, "#") + "%", bgcolor=#0d1527, text_color=#00f2fe, text_size=t_size)
        table.cell(bias_table, 3, 10, "[ COMPOSITE ]", bgcolor=#0d1527, text_color=#00f2fe, text_size=t_size)
        table.cell(bias_table, 4, 10, total_bar_visual, bgcolor=#0d1527, text_color=#00f2fe, text_size=t_size)
````
