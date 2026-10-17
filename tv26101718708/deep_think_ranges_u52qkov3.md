# Deep Think Ranges

- url: https://www.tradingview.com/script/u52qKOV3-Deep-Think-Ranges/
- type: indicator
- pine_id: PUB;2362662543c4467290dafe6fa1572a55
- version: 1.0

## Description

Deep Think Ranges
Deep Think Ranges is an, multi-timeframe indicator that mathematically identifies macro-consolidations.

The engine runs price action through two mathematical algorithms:

Fractal Dispersion (Choppiness Index): Proves the market is trapped in a dense, sideways structure.
Pearson Correlation (R²): Guarantees momentum is completely dead and price is moving in pure sideways chaos.
Features:

Multi-Timeframe Scanning: Actively monitor up to 3 higher timeframes (e.g. 4H, Daily) natively on your execution chart.

Alerts: Send push notifications the exact moment a macro range locks in.

## Source Code

````pine
//@version=6
indicator("Deep Think Ranges", overlay=true, max_boxes_count=500, max_lines_count=500)

max_bars_back(time, 4500)
max_bars_back(close, 4500)
max_bars_back(open, 4500)

// --- Global Alerts ---
group_alerts = "Global Alerts"
tt_alerts = "Sends a push notification or webhook alert the exact moment a new Macro Consolidation locks in.\n\nExample Output:\nRange Detected\nBTCUSDT\n4 Hour\n\nHow to Setup Server-Side Push Notifications:\n1. Apply this indicator to your chart.\n2. Open TradingView's 'Create Alert' menu (Alt + A).\n3. Set the Condition to 'Deep Think Ranges' -> 'Any alert() function call'.\n4. Under the Notifications tab, enable 'Send Email', 'Push Notifications', or paste your custom Webhook URL.\n\nBecause TradingView handles this entirely server-side in the cloud, you can safely close your browser and turn off your PC. The alerts will continue running 24/7!"
use_alerts = input.bool(true, "Enable Push Notifications", group=group_alerts, tooltip=tt_alerts)

// --- Tooltip Strings ---
tt_res = "Defines the specific timeframe on which the mathematical engine looks for structural macro-ranges. By scanning a higher timeframe, the algorithm effortlessly filters out the intraday noise of your current execution chart."
tt_len = "The number of periods to look back when executing the mathematical formulas (Fractal Dispersion and Pearson Correlation). A value of 20 means it analyzes the most recent 20 bars on the specified Range Timeframe."
tt_use_chop = "Enables or disables the Choppiness Index (Fractal Dispersion) test. When enabled, the range must mathematically prove it is moving in a dense, sideways, fractal pattern."
tt_chop_thresh = "The mathematical hurdle the Choppiness Index must clear. A value of 61.8 (Fibonacci) is the standard for proving severe non-trending behavior. Anything above this value means the market is entirely directionless.\n\nHow the Formula Works:\nIt calculates the sum of the Average True Range (ATR) over the Lookback window, and divides it by the total price range (Highest High - Lowest Low).\n\nMath:\n100 * LOG10(Sum(ATR) / (HH - LL)) / LOG10(Lookback)"
tt_use_r2 = "Enables or disables the Pearson Correlation (R²) linearity test. This acts as the ultimate filter by checking how closely the price path resembles a straight line."
tt_r2_res = "Allows you to calculate the Pearson Correlation on an entirely different timeframe if you want extreme granularity."
tt_r2_thresh = "The threshold for the R² linearity test. The formula squares the standard Pearson Correlation Coefficient (r) between closing prices and time to output a value between 0.0 and 1.0.\n\nWhat it means:\n0.0 = Pure Sideways Chaos (Perfect Range)\n1.0 = Perfect Straight Line (Pure Trend)\n\nA strict threshold of 0.15 mathematically guarantees that the price path has absolutely zero momentum."
tt_lbl = "If enabled, a beautiful, non-transparent text label will be rendered perfectly in the dead center of the box to instantly identify which timeframe the consolidation belongs to."
tt_eq = "Draws a horizontal line perfectly through the 50% mark of the entire range. In structural market theory, this is the 'Equilibrium' or 'Fair Value' level where buyers and sellers are perfectly balanced. Price oscillating tightly around this line is a mathematical signature of a true consolidation."

// --- TIMEFRAME 1 SETTINGS ---
group_tf1 = "Timeframe 1 (Primary)"
use_tf1 = input.bool(true, "Enable Timeframe 1", group=group_tf1)
htf_res_1 = input.timeframe("240", "Range Timeframe", group=group_tf1, tooltip=tt_res)
htf_len_1 = input.int(20, "Lookback", group=group_tf1, tooltip=tt_len)
use_chop_1 = input.bool(true, "Use Fractal Dispersion (Choppiness)", group=group_tf1, tooltip=tt_use_chop)
chop_threshold_1 = input.float(61.8, "Fractal Dispersion Threshold", group=group_tf1, tooltip=tt_chop_thresh)
use_r2_1 = input.bool(true, "Use Pearson Correlation (R²)", group=group_tf1, tooltip=tt_use_r2)
r2_res_1 = input.timeframe("240", "Pearson Correlation (R²) Timeframe", group=group_tf1, tooltip=tt_r2_res)
r2_threshold_1 = input.float(0.15, "Pearson Correlation (R²) Threshold", group=group_tf1, tooltip=tt_r2_thresh)

box_bg_color_1 = input.color(color.new(color.gray, 85), "Background Color", group=group_tf1)
box_border_color_1 = input.color(color.new(color.gray, 25), "Border Color", group=group_tf1)
box_border_width_1 = input.int(1, "Border Width", group=group_tf1)
box_border_style_1 = input.string(line.style_solid, "Border Style", options=[line.style_solid, line.style_dashed, line.style_dotted], group=group_tf1)
show_lbl_1 = input.bool(false, "Show Timeframe Label", group=group_tf1, tooltip=tt_lbl)

show_midline_1 = input.bool(true, "Show Equilibrium", group=group_tf1, tooltip=tt_eq)
midline_color_1 = input.color(color.new(color.gray, 50), "Equilibrium Color", group=group_tf1)
midline_style_1 = input.string(line.style_dashed, "Equilibrium Style", options=[line.style_solid, line.style_dashed, line.style_dotted], group=group_tf1)

// --- TIMEFRAME 2 SETTINGS ---
group_tf2 = "Timeframe 2"
use_tf2 = input.bool(false, "Enable Timeframe 2", group=group_tf2)
htf_res_2 = input.timeframe("480", "Range Timeframe", group=group_tf2, tooltip=tt_res)
htf_len_2 = input.int(20, "Lookback", group=group_tf2, tooltip=tt_len)
use_chop_2 = input.bool(true, "Use Fractal Dispersion (Choppiness)", group=group_tf2, tooltip=tt_use_chop)
chop_threshold_2 = input.float(61.8, "Fractal Dispersion Threshold", group=group_tf2, tooltip=tt_chop_thresh)
use_r2_2 = input.bool(true, "Use Pearson Correlation (R²)", group=group_tf2, tooltip=tt_use_r2)
r2_res_2 = input.timeframe("D", "Pearson Correlation (R²) Timeframe", group=group_tf2, tooltip=tt_r2_res)
r2_threshold_2 = input.float(0.15, "Pearson Correlation (R²) Threshold", group=group_tf2, tooltip=tt_r2_thresh)

box_bg_color_2 = input.color(color.new(color.gray, 85), "Background Color", group=group_tf2)
box_border_color_2 = input.color(color.new(color.gray, 25), "Border Color", group=group_tf2)
box_border_width_2 = input.int(1, "Border Width", group=group_tf2)
box_border_style_2 = input.string(line.style_solid, "Border Style", options=[line.style_solid, line.style_dashed, line.style_dotted], group=group_tf2)
show_lbl_2 = input.bool(false, "Show Timeframe Label", group=group_tf2, tooltip=tt_lbl)

show_midline_2 = input.bool(true, "Show Equilibrium", group=group_tf2, tooltip=tt_eq)
midline_color_2 = input.color(color.new(color.gray, 50), "Equilibrium Color", group=group_tf2)
midline_style_2 = input.string(line.style_dashed, "Equilibrium Style", options=[line.style_solid, line.style_dashed, line.style_dotted], group=group_tf2)

// --- TIMEFRAME 3 SETTINGS ---
group_tf3 = "Timeframe 3"
use_tf3 = input.bool(false, "Enable Timeframe 3", group=group_tf3)
htf_res_3 = input.timeframe("30", "Range Timeframe", group=group_tf3, tooltip=tt_res)
htf_len_3 = input.int(20, "Lookback", group=group_tf3, tooltip=tt_len)
use_chop_3 = input.bool(true, "Use Fractal Dispersion (Choppiness)", group=group_tf3, tooltip=tt_use_chop)
chop_threshold_3 = input.float(61.8, "Fractal Dispersion Threshold", group=group_tf3, tooltip=tt_chop_thresh)
use_r2_3 = input.bool(true, "Use Pearson Correlation (R²)", group=group_tf3, tooltip=tt_use_r2)
r2_res_3 = input.timeframe("W", "Pearson Correlation (R²) Timeframe", group=group_tf3, tooltip=tt_r2_res)
r2_threshold_3 = input.float(0.15, "Pearson Correlation (R²) Threshold", group=group_tf3, tooltip=tt_r2_thresh)

box_bg_color_3 = input.color(color.new(color.gray, 85), "Background Color", group=group_tf3)
box_border_color_3 = input.color(color.new(color.gray, 25), "Border Color", group=group_tf3)
box_border_width_3 = input.int(1, "Border Width", group=group_tf3)
box_border_style_3 = input.string(line.style_solid, "Border Style", options=[line.style_solid, line.style_dashed, line.style_dotted], group=group_tf3)
show_lbl_3 = input.bool(false, "Show Timeframe Label", group=group_tf3, tooltip=tt_lbl)

show_midline_3 = input.bool(true, "Show Equilibrium", group=group_tf3, tooltip=tt_eq)
midline_color_3 = input.color(color.new(color.gray, 50), "Equilibrium Color", group=group_tf3)
midline_style_3 = input.string(line.style_dashed, "Equilibrium Style", options=[line.style_solid, line.style_dashed, line.style_dotted], group=group_tf3)

// --- Math Functions ---
f_chop_structure(len, chop_thresh, use_chop_flt) =>
    atr_sum = math.sum(ta.atr(1), len)
    hh = ta.highest(high, len)
    ll = ta.lowest(low, len)
    chop = (hh - ll) != 0 ? 100 * math.log10(atr_sum / (hh - ll)) / math.log10(len) : 0
    chop_pass = use_chop_flt ? (na(chop) ? false : chop >= chop_thresh) : true
    start_time = time[len]
    [chop_pass[1], hh[1], ll[1], start_time[1]]

f_r2_structure(len, r2_thresh, use_r2_flt) =>
    r = ta.correlation(close, bar_index, len)
    r2 = math.pow(nz(r, 0), 2)
    r2_pass = use_r2_flt ? (na(r2) ? false : r2 <= r2_thresh) : true
    r2_pass[1]

// --- Multi-Timeframe Data Fetching ---
// TF1
[h_chop_pass_1, h_hh_1, h_ll_1, h_start_time_1] = request.security(syminfo.tickerid, htf_res_1, f_chop_structure(htf_len_1, chop_threshold_1, use_chop_1), barmerge.gaps_off, barmerge.lookahead_off)
h_r2_pass_1 = request.security(syminfo.tickerid, r2_res_1, f_r2_structure(htf_len_1, r2_threshold_1, use_r2_1), barmerge.gaps_off, barmerge.lookahead_off)
h_ranging_1 = use_tf1 ? (h_chop_pass_1 and h_r2_pass_1) : false
new_macro_range_1 = na(h_start_time_1) ? false : (h_ranging_1 and not h_ranging_1[1])

// TF2
[h_chop_pass_2, h_hh_2, h_ll_2, h_start_time_2] = request.security(syminfo.tickerid, htf_res_2, f_chop_structure(htf_len_2, chop_threshold_2, use_chop_2), barmerge.gaps_off, barmerge.lookahead_off)
h_r2_pass_2 = request.security(syminfo.tickerid, r2_res_2, f_r2_structure(htf_len_2, r2_threshold_2, use_r2_2), barmerge.gaps_off, barmerge.lookahead_off)
h_ranging_2 = use_tf2 ? (h_chop_pass_2 and h_r2_pass_2) : false
new_macro_range_2 = na(h_start_time_2) ? false : (h_ranging_2 and not h_ranging_2[1])

// TF3
[h_chop_pass_3, h_hh_3, h_ll_3, h_start_time_3] = request.security(syminfo.tickerid, htf_res_3, f_chop_structure(htf_len_3, chop_threshold_3, use_chop_3), barmerge.gaps_off, barmerge.lookahead_off)
h_r2_pass_3 = request.security(syminfo.tickerid, r2_res_3, f_r2_structure(htf_len_3, r2_threshold_3, use_r2_3), barmerge.gaps_off, barmerge.lookahead_off)
h_ranging_3 = use_tf3 ? (h_chop_pass_3 and h_r2_pass_3) : false
new_macro_range_3 = na(h_start_time_3) ? false : (h_ranging_3 and not h_ranging_3[1])

format_tf(string tf) =>
    tf == "1" ? "1 Minute" : tf == "3" ? "3 Minute" : tf == "5" ? "5 Minute" : tf == "15" ? "15 Minute" : tf == "30" ? "30 Minute" : tf == "45" ? "45 Minute" : tf == "60" ? "1 Hour" : tf == "120" ? "2 Hour" : tf == "240" ? "4 Hour" : tf == "480" ? "8 Hour" : tf == "D" or tf == "1D" ? "Daily" : tf == "W" or tf == "1W" ? "Weekly" : tf == "M" or tf == "1M" ? "Monthly" : tf + "m"

// --- Pine v6 UDT State Machine ---
type RangeState
    bool in_range = false
    float range_high = na
    float range_low = na
    int anchor_time = na
    box current_box = na
    line midline = na

method update_range(RangeState state, bool use_tf, bool new_macro, float h_hh, float h_ll, int h_start_time, int htf_len, string htf_res, color bg, color brd, int bw, string bs, bool show_lbl, string lbl_txt, bool show_mid, color mid_col, string mid_style) =>
    if use_tf
        if new_macro and not state.in_range
            state.in_range := true
            state.range_high := h_hh
            state.range_low := h_ll
            state.anchor_time := h_start_time
            
            if na(state.anchor_time)
                state.anchor_time := time - (htf_len * timeframe.in_seconds(htf_res) * 1000)
                
            state.current_box := box.new(left=state.anchor_time, top=state.range_high, right=time, bottom=state.range_low, xloc=xloc.bar_time, border_color=brd, border_width=bw, border_style=bs, bgcolor=bg, text=show_lbl ? lbl_txt : "", text_color=color.new(brd, 0), text_halign=text.align_center, text_valign=text.align_center, text_size=size.normal)
            
            if show_mid
                float mid_price = (state.range_high + state.range_low) / 2
                state.midline := line.new(state.anchor_time, mid_price, time, mid_price, xloc.bar_time, color=mid_col, style=mid_style, width=1)

            if use_alerts
                alert("Range Detected\n" + syminfo.ticker + "\n" + format_tf(htf_res), alert.freq_once_per_bar_close)

        if state.in_range
            is_breakout = (na(state.range_high) ? false : close > state.range_high) or (na(state.range_low) ? false : close < state.range_low)
            if is_breakout
                state.in_range := false
            else
                box.set_right(state.current_box, time)
                
                if show_mid and not na(state.midline)
                    line.set_x2(state.midline, time)
                
                if show_lbl
                    box.set_text(state.current_box, lbl_txt)
                    box.set_text_color(state.current_box, color.new(brd, 0))
                else
                    box.set_text(state.current_box, "")

    else
        // If disabled, kill active range
        if state.in_range
            state.in_range := false
            
    // Prevent return type mismatch errors from inner blocks
    true

var state1 = RangeState.new()
var state2 = RangeState.new()
var state3 = RangeState.new()

state1.update_range(use_tf1, new_macro_range_1, h_hh_1, h_ll_1, h_start_time_1, htf_len_1, htf_res_1, box_bg_color_1, box_border_color_1, box_border_width_1, box_border_style_1, show_lbl_1, format_tf(htf_res_1) + " Range", show_midline_1, midline_color_1, midline_style_1)
state2.update_range(use_tf2, new_macro_range_2, h_hh_2, h_ll_2, h_start_time_2, htf_len_2, htf_res_2, box_bg_color_2, box_border_color_2, box_border_width_2, box_border_style_2, show_lbl_2, format_tf(htf_res_2) + " Range", show_midline_2, midline_color_2, midline_style_2)
state3.update_range(use_tf3, new_macro_range_3, h_hh_3, h_ll_3, h_start_time_3, htf_len_3, htf_res_3, box_bg_color_3, box_border_color_3, box_border_width_3, box_border_style_3, show_lbl_3, format_tf(htf_res_3) + " Range", show_midline_3, midline_color_3, midline_style_3)

// --- Alert Table ---
group_table = "Alert Table Settings"
show_alert_table = input.bool(true, "Show Error Message", group=group_table, tooltip="Displays a warning on the chart if your chart timeframe is higher than any of your active indicator timeframes.")
table_position = input.string("Top Center", "Table Position", options=["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group=group_table)

get_position(pos_str) =>
    if pos_str == "Top Right"
        position.top_right
    else if pos_str == "Top Center"
        position.top_center
    else if pos_str == "Top Left"
        position.top_left
    else if pos_str == "Middle Right"
        position.middle_right
    else if pos_str == "Middle Center"
        position.middle_center
    else if pos_str == "Middle Left"
        position.middle_left
    else if pos_str == "Bottom Right"
        position.bottom_right
    else if pos_str == "Bottom Center"
        position.bottom_center
    else
        position.bottom_left

var table alert_table = na

if barstate.islast and show_alert_table
    int chart_sec = timeframe.in_seconds(timeframe.period)
    
    bool is_htf1_err = use_tf1 and (chart_sec > timeframe.in_seconds(htf_res_1) or chart_sec > timeframe.in_seconds(r2_res_1))
    bool is_htf2_err = use_tf2 and (chart_sec > timeframe.in_seconds(htf_res_2) or chart_sec > timeframe.in_seconds(r2_res_2))
    bool is_htf3_err = use_tf3 and (chart_sec > timeframe.in_seconds(htf_res_3) or chart_sec > timeframe.in_seconds(r2_res_3))
    
    if is_htf1_err or is_htf2_err or is_htf3_err
        if na(alert_table)
            alert_table := table.new(get_position(table_position), 1, 1)
            
        string error_msg = "🚨 CRITICAL TIMEFRAME MISMATCH 🚨\n\n" +
                           "TradingView cannot calculate lower timeframe indicator data on a higher timeframe chart.\n" +
                           "This forces the engine to skip massive amounts of data, destroying the mathematical accuracy of:\n" +
                           "  • Fractal Dispersion (Choppiness)\n" +
                           "  • Pearson Correlation (R²)\n\n" +
                           "✅ HOW TO FIX:\n" +
                           "Switch your chart to a timeframe equal to or lower than your Range Timeframe.\n\n" +
                           "(Note: You can turn this error message off in the indicator settings menu)"
                           
        table.cell(alert_table, 0, 0, error_msg, text_halign=text.align_left, bgcolor=color.new(color.red, 65), text_color=color.white, text_size=size.large)
    else
        if not na(alert_table)
            table.cell(alert_table, 0, 0, "", bgcolor=na)
````
