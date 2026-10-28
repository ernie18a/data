# Volume Footprint

- url: https://www.tradingview.com/script/7oJyrrJO/
- type: indicator
- pine_id: PUB;a14f82b4cf0c4cb7a265649103403352
- version: 3.0

## Description

Volume Footprint

First and foremost, a special thanks to @bassnavy for the direct request and inspiration to build this tool. I truly appreciate your comment!

Disclaimer: This is essentially a simplified script inspired by premium footprint tools (lol). I pay my utmost respect to TradingView and its amazing community!

This indicator is an "Advanced Precision Footprint Visualizer" built strictly on Pine Script v6. Standard footprint charts often struggle with TradingView's rendering limits (max 500 boxes). To overcome this, I engineered a dynamic tick-grouping algorithm that visualizes exact Bid/Ask deltas, volume densities, and Point of Control (POC) with extreme precision, without breaking the platform's constraints.

This tool is designed for highly disciplined traders who rely on verified entry setups. It filters out market noise and visually isolates true liquidity nodes.

Core Mechanics & Calculation Logic:
Tick Grouping (Step Calculation): step = syminfo.mintick * active_ticks
Why: Processing every single minimum tick would instantly exceed the 500-box drawing limit. By grouping ticks based on ATR (Auto Tiers) or a manual input, we compress the data while maintaining visual fidelity.

Output Example: If syminfo.mintick is 0.01 and active_ticks is set to 1, the step size becomes 0.01. If the bar's high is 16.59 and low is 16.26, the engine calculates exactly 34 rows for rendering.
Row Delta Determination: row_delta = Ask Volume - Bid Volume
Why: To accurately gauge whether buyers or sellers absorbed the liquidity at a specific price tier.
Output Example: If Ask volume is 2.5K and Bid volume is 1.0K at a specific row, the row_delta is +1.5K. The text dynamically changes to the "Plus Delta" color (Green).
3-Step Volume Gradient: half_max = max_r_v * 0.5
Why: To create a seamless 3-step color gradient (Low -> Mid -> High). By calculating the 50% threshold of the maximum volume (POC) inside the bar, it intuitively separates high-interest zones from market noise.
Premium Plan TF Downgrade Logic: actual_ltf = (not is_premium and is_sec_tf) ? "1" : ltf_res_input
Why: TradingView restricts seconds-based timeframes (like 1S or 15S) to Premium users and above. Requesting this data on lower plans causes script crashes. This logic automatically downgrades the timeframe to 1 (1-minute) if the Premium toggle is disabled, ensuring stability for all users.
Output Example: If the user inputs 15S and the Premium toggle is false, is_sec_tf evaluates to true. The condition not is_premium is met, so actual_ltf outputs "1" (1-minute). If the toggle is true, it outputs "15S".

Warning: This script operates at the absolute edge of TradingView's rendering capabilities. If you encounter rendering errors, please reduce the "Lookback Bars" or increase the "Lower Timeframe (LTF)" resolution.

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (C) ALT_analyst

//@version=6
indicator("Volume Footprint", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500, max_bars_back=500)

// ~~ Constants {
const string GRP_CORE = " [ SYSTEM ] CORE HIGH-PRECISION SCAN"
const string TITLE_PREM = "Premium Plan or Higher (Allow Seconds TF)"
const string TT_PREM = "If OFF and a seconds timeframe is specified, it will be forcefully downgraded to a 1-minute (1) minimum timeframe to prevent errors."
const string TITLE_LB = "Lookback Bars"
const string TT_LB = "Number of historical bars to calculate and display the footprint profile."
const string TITLE_LTF = "Lower Timeframe (LTF)"
const string TT_LTF = "Timeframe used for internal footprint calculation. Must be lower than the chart timeframe."

const string GRP_DISP = " [ DISPLAY ] CANDLES & FOOTPRINT"
const string TITLE_WIDTH = "Profile Width Multiplier"
const string TT_WIDTH = "Adjusts the maximum width of the footprint profile boxes relative to the bar spacing."
const string TITLE_ROW = "Row Size Mode"
const string TT_ROW = "Selects how the row height (price steps) is calculated: automatically based on ATR, or manually via Ticks."
const string TITLE_TICKS = "Ticks per Row (Manual Mode Only)"
const string TT_TICKS = "Defines the height of each profile row in ticks. Only applies when Row Size Mode is set to Manual."
const string TITLE_BORDER = "Show Borders on All Boxes"
const string TT_BORDER = "Toggles the visibility of the borders around each footprint box."
const string TITLE_COL_B = "Border Color"
const string TT_COL_B = "Sets the color of the footprint box borders."

const string GRP_BG = " [ BACKGROUND ] SYMBOL -> BACKGROUND (3-Step Gradient)"
const string TITLE_BG_H = "Volume High (Max)"
const string TT_BG_H = "Background color for the highest volume nodes (Max Volume)."
const string TITLE_BG_M = "Volume Mid (50%)"
const string TT_BG_M = "Background color for medium volume nodes (50% Volume)."
const string TITLE_BG_L = "Volume Low (Min)"
const string TT_BG_L = "Background color for the lowest volume nodes (Min Volume)."

const string GRP_LBL = " [ LABEL ] SYMBOL -> LABEL"
const string TITLE_POC_BG = "POC Box Color"
const string TT_POC_BG = "Background color specifically highlighting the Point of Control (POC - highest volume node)."
const string TITLE_POC_TXT = "POC Text Color"
const string TT_POC_TXT = "Text color for the volume value inside the Point of Control (POC) box."

const string GRP_TXT = " [ TEXT ] FOOTPRINT DATA"
const string TITLE_TXT_SZ = "Text Size"
const string TT_TXT_SZ = "Size of the volume text displayed inside the footprint boxes."
const string TITLE_TXT_N = "Text Color (Neutral)"
const string TT_TXT_N = "Text color for nodes where buying and selling volumes are exactly equal (Neutral delta)."
const string TITLE_TXT_P = "Text Color (Plus Delta)"
const string TT_TXT_P = "Text color for nodes where buying volume exceeds selling volume (Positive delta)."
const string TITLE_TXT_M = "Text Color (Minus Delta)"
const string TT_TXT_M = "Text color for nodes where selling volume exceeds buying volume (Negative delta)."

const string GRP_TBL = " [ TABLE ] SUMMARY SETTINGS"
const string TITLE_TBL_SZ = "Table Text Size"
const string TT_TBL_SZ = "Specifies the text size within the summary table. This functions completely independently of the footprint text size in the [TEXT] group. Adjust according to screen resolution and data volume."
const string TITLE_TBL_BG = "Table Background Color"
const string TT_TBL_BG = "Specifies the background color of the entire table. Contrasting this with your chart's theme ensures visibility of the data text."
const string TITLE_TBL_POS = "Table Position"
const string TT_TBL_POS = "Specifies the table's position on the chart. If you set a long Lookback period, choose a position that prevents the table from overlapping with the profile boxes."
//~~~~~}

// ~~ Inputs {
bool is_premium = input.bool(false, TITLE_PREM, group=GRP_CORE, tooltip=TT_PREM)
int lookback_bars = input.int(5, TITLE_LB, minval=1, maxval=10, group=GRP_CORE, tooltip=TT_LB)
string ltf_res_input = input.timeframe("1S", TITLE_LTF, group=GRP_CORE, tooltip=TT_LTF)

float width_mult = input.float(1.5, TITLE_WIDTH, minval=0.1, step=0.5, group=GRP_DISP, tooltip=TT_WIDTH)
string row_size_mode = input.string("Auto (20 Tiers)", TITLE_ROW, options=["Manual", "Auto (20 Tiers)"], group=GRP_DISP, tooltip=TT_ROW)
int ticks_per_row = input.int(1, TITLE_TICKS, minval=1, group=GRP_DISP, tooltip=TT_TICKS)
bool show_border = input.bool(true, TITLE_BORDER, group=GRP_DISP, tooltip=TT_BORDER)
color col_border = input.color(color.new(color.gray, 60), TITLE_COL_B, group=GRP_DISP, tooltip=TT_COL_B)

color bg_col_high = input.color(color.new(#0D47A1, 0), TITLE_BG_H, group=GRP_BG, tooltip=TT_BG_H) 
color bg_col_mid = input.color(color.new(#1976D2, 20), TITLE_BG_M, group=GRP_BG, tooltip=TT_BG_M)
color bg_col_low = input.color(color.new(#64B5F6, 60), TITLE_BG_L, group=GRP_BG, tooltip=TT_BG_L)

color col_poc_bg = input.color(color.white, TITLE_POC_BG, group=GRP_LBL, tooltip=TT_POC_BG)
color col_poc_txt = input.color(color.black, TITLE_POC_TXT, group=GRP_LBL, tooltip=TT_POC_TXT)

string txt_sz_fp = input.string(size.auto, TITLE_TXT_SZ, options=[size.auto, size.tiny, size.small, size.normal, size.large], group=GRP_TXT, tooltip=TT_TXT_SZ)
color txt_col_fp = input.color(color.white, TITLE_TXT_N, group=GRP_TXT, tooltip=TT_TXT_N)
color txt_col_pos = input.color(color.new(#089981, 0), TITLE_TXT_P, group=GRP_TXT, tooltip=TT_TXT_P)
color txt_col_neg = input.color(color.new(#F23645, 0), TITLE_TXT_M, group=GRP_TXT, tooltip=TT_TXT_M)

string tbl_pos_input = input.string(position.bottom_right, TITLE_TBL_POS, options=[position.top_left, position.top_right, position.bottom_left, position.bottom_right], group=GRP_TBL, tooltip=TT_TBL_POS)
color tbl_bg_col = input.color(color.white, TITLE_TBL_BG, group=GRP_TBL, tooltip=TT_TBL_BG)
string tbl_txt_sz = input.string(size.normal, TITLE_TBL_SZ, options=[size.tiny, size.small, size.normal, size.large], group=GRP_TBL, tooltip=TT_TBL_SZ)
//~~~~~}

// ~~ Helpers {
f_format_k(float val) =>
    float abs_val = math.abs(val)
    string res = ""
    if abs_val >= 1000000
        res := str.tostring(val / 1000000, "#.##") + "M"
    else if abs_val >= 1000
        res := str.tostring(val / 1000, "#.##") + "K"
    else
        res := str.tostring(val, "#.#")
    res
//~~~~~}

// ~~ Calculation & Drawing {
bool is_sec_tf = str.contains(ltf_res_input, "S")
string actual_ltf = (not is_premium and is_sec_tf) ? "1" : ltf_res_input

[ltf_o, ltf_h, ltf_l, ltf_c, ltf_v] = request.security_lower_tf(syminfo.tickerid, actual_ltf, [open, high, low, close, volume])
float global_atr = ta.atr(14)

var box[] fp_boxes = array.new_box()
var label[] fp_labels = array.new_label()
var line[] fp_lines = array.new_line()
var table summary_table = table.new(tbl_pos_input, 11, 5, bgcolor=tbl_bg_col, border_width=1, border_color=color.gray)

if barstate.islast
    while array.size(fp_boxes) > 0
        box.delete(array.shift(fp_boxes))
    while array.size(fp_labels) > 0
        label.delete(array.shift(fp_labels))
    while array.size(fp_lines) > 0
        line.delete(array.shift(fp_lines))
    
    table.clear(summary_table, 0, 0, 10, 4)

    for b_offset = lookback_bars - 1 to 0
        if b_offset >= bar_index or array.size(ltf_v) == 0 or array.size(ltf_v) <= b_offset
            continue
            
        float[] ltf_o_arr = ltf_o[b_offset]
        float[] ltf_h_arr = ltf_h[b_offset]
        float[] ltf_l_arr = ltf_l[b_offset]
        float[] ltf_c_arr = ltf_c[b_offset]
        float[] ltf_v_arr = ltf_v[b_offset]
        
        int ltf_size = array.size(ltf_v_arr)
        
        float bar_l = low[b_offset]
        float bar_h = high[b_offset]
        
        float current_atr = global_atr[b_offset]
        if na(current_atr) or current_atr == 0
            current_atr := close[b_offset] * 0.005 
            
        int auto_ticks = math.max(1, math.round((current_atr / 20) / syminfo.mintick))
        int active_ticks = row_size_mode == "Auto (20 Tiers)" ? auto_ticks : ticks_per_row
        float step = syminfo.mintick * active_ticks
        
        int total_r = math.ceil((bar_h - bar_l) / step) + 1
        
        float[] ask_v_arr = array.new_float(total_r, 0.0)
        float[] bid_v_arr = array.new_float(total_r, 0.0)
        float[] tot_v_arr = array.new_float(total_r, 0.0)
        
        float total_v_bar = 0.0
        float bought_t = 0.0
        float sold_t = 0.0
        float max_r_v = 0.0
        
        if ltf_size > 0
            for i = 0 to ltf_size - 1
                float c_o = array.get(ltf_o_arr, i)
                float c_h = array.get(ltf_h_arr, i)
                float c_l = array.get(ltf_l_arr, i)
                float c_c = array.get(ltf_c_arr, i)
                float c_v = array.get(ltf_v_arr, i)
                    
                int ticks_1s = math.round((c_h - c_l) / syminfo.mintick) + 1
                float v_tick = c_v / ticks_1s
                
                int s_idx = math.round((c_l - bar_l) / step)
                int e_idx = math.round((c_h - bar_l) / step)
                
                for t_idx = s_idx to e_idx
                    if t_idx >= 0 and t_idx < total_r
                        if c_c > c_o
                            array.set(ask_v_arr, t_idx, array.get(ask_v_arr, t_idx) + v_tick)
                        else if c_c < c_o
                            array.set(bid_v_arr, t_idx, array.get(bid_v_arr, t_idx) + v_tick)
                        else
                            array.set(ask_v_arr, t_idx, array.get(ask_v_arr, t_idx) + (v_tick / 2))
                            array.set(bid_v_arr, t_idx, array.get(bid_v_arr, t_idx) + (v_tick / 2))

        for i = 0 to total_r - 1
            float a_v = array.get(ask_v_arr, i)
            float b_v = array.get(bid_v_arr, i)
            float total = a_v + b_v
            array.set(tot_v_arr, i, total)
            max_r_v := math.max(max_r_v, total)
            bought_t += a_v
            sold_t += b_v
            total_v_bar += total

        float delta = bought_t - sold_t
        
        int poc_idx = -1
        if max_r_v > 0
            for i = 0 to total_r - 1
                if array.get(tot_v_arr, i) == max_r_v
                    poc_idx := i
                    break
        
        int t_ctr = time[b_offset]
        int b_t_w = nz(time[b_offset] - time[b_offset + 1], time - time[1])
        int cell_w_t = math.round(b_t_w * 0.8 * width_mult) 
        
        color global_border_c = show_border ? col_border : na

        for i = 0 to total_r - 1
            float a_v = array.get(ask_v_arr, i)
            float b_v = array.get(bid_v_arr, i)
            float total = array.get(tot_v_arr, i)
            
            if total == 0
                continue
                
            float price_p = bar_l + (i * step)
            bool is_poc = (i == poc_idx)
            
            string fp_txt = f_format_k(total)
            
            int total_w = math.round(cell_w_t * (max_r_v > 0 ? total / max_r_v : 0))
            int b_left = t_ctr
            int b_right = t_ctr + total_w
            
            float row_delta = a_v - b_v
            color dynamic_txt_col = is_poc ? col_poc_txt : (row_delta > 0 ? txt_col_pos : (row_delta < 0 ? txt_col_neg : txt_col_fp))
            
            float half_max = max_r_v * 0.5
            color grad_col = total >= half_max ? color.from_gradient(total, half_max, max_r_v, bg_col_mid, bg_col_high) : color.from_gradient(total, 0, half_max, bg_col_low, bg_col_mid)
            color box_bg = is_poc ? col_poc_bg : grad_col
            
            array.push(fp_boxes, box.new(
                left = b_left, top = price_p + (step/2), right = b_right, bottom = price_p - (step/2),
                xloc = xloc.bar_time, border_color = global_border_c, bgcolor = box_bg,
                text = fp_txt, text_color = dynamic_txt_col, text_size = txt_sz_fp, 
                text_halign = text.align_left, text_valign = text.align_center
            ))
            
            if is_poc
                array.push(fp_lines, line.new(x1=b_left - (b_t_w * 2), y1=price_p, x2=b_right, y2=price_p, xloc=xloc.bar_time, color=color.black, style=line.style_dotted, width=1))

        if total_v_bar > 0
            if b_offset == lookback_bars - 1
                table.cell(summary_table, 0, 0, "Target Bar", text_color=color.black, bgcolor=color.new(color.gray, 90), text_size=tbl_txt_sz)
                table.cell(summary_table, 0, 1, "Delta", text_color=color.black, text_size=tbl_txt_sz, text_halign=text.align_left)
                table.cell(summary_table, 0, 2, "Total Vol", text_color=color.black, text_size=tbl_txt_sz, text_halign=text.align_left)
                table.cell(summary_table, 0, 3, "Total Buy", text_color=color.black, text_size=tbl_txt_sz, text_halign=text.align_left)
                table.cell(summary_table, 0, 4, "Total Sell", text_color=color.black, text_size=tbl_txt_sz, text_halign=text.align_left)

            int col_idx = lookback_bars - b_offset
            
            color delta_color = delta > 0 ? color.new(#089981, 0) : color.new(#F23645, 0)
            string d_txt = (delta > 0 ? "+" : "") + str.tostring(f_format_k(delta)) 
            string t_txt = str.tostring(f_format_k(total_v_bar))
            string b_txt = str.tostring(f_format_k(bought_t))
            string s_txt = str.tostring(f_format_k(sold_t))
            string bar_label = b_offset == 0 ? "Current" : str.tostring(b_offset) + " Bars Ago"
            
            table.cell(summary_table, col_idx, 0, bar_label, text_color=color.black, bgcolor=color.new(color.gray, 95), text_size=tbl_txt_sz)
            table.cell(summary_table, col_idx, 1, d_txt, text_color=delta_color, text_size=tbl_txt_sz, text_halign=text.align_right)
            table.cell(summary_table, col_idx, 2, t_txt, text_color=color.black, text_size=tbl_txt_sz, text_halign=text.align_right)
            table.cell(summary_table, col_idx, 3, b_txt, text_color=color.new(#089981, 0), text_size=tbl_txt_sz, text_halign=text.align_right)
            table.cell(summary_table, col_idx, 4, s_txt, text_color=color.new(#F23645, 0), text_size=tbl_txt_sz, text_halign=text.align_right)
//~~~~~}
````
