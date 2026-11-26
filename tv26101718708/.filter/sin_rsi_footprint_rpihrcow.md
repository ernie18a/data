# Sin RSI Footprint

- url: https://www.tradingview.com/script/RPIHrcow/
- type: indicator
- pine_id: PUB;3c74c524e7b44df88ebe7b888d84d39c
- version: 3.0

## Description

[b]■ Overview[/b]
[b]The Sin RSI Footprint【ALT_analyst】[/b] indicator brings the concept of footprint charting to momentum oscillators. 

Instead of mapping trading volume at price levels, this script peers inside the current higher-timeframe candle to map the internal momentum using Lower Timeframe (LTF) RSI data. 

By visualizing exactly where and how momentum was distributed within a single bar, traders can identify hidden exhaustion, hidden accumulation/distribution, and intra-bar divergences that are invisible on standard charts.

[image]https://www.tradingview.com/x/IXQG3I8P/[/image]


[b]■ Core Modes & How It Works[/b]
The script utilizes [pine]request.security_lower_tf[/pine] to fetch an array of LTF RSI and Close prices for the duration of the current chart's bar. It then processes this data in one of two distinct visualization modes:

[b]1. Matrix Mode (Traditional Price Level)[/b]
This mode acts like a traditional footprint or volume profile, but for RSI.

[image]https://www.tradingview.com/x/vKz3Lpj9/[/image]


[b]■ The Calculation[/b]
The script divides the high-to-low range of the current candle into user-defined bins (e.g., 10 rows). It calculates the step size:
[pine]step = (high - low) / Matrix Rows[/pine]
For each LTF data point, it determines the correct row using:
[pine]math.floor((close - low) / step)[/pine]

[b]Why this calculation is used[/b]
To map momentum to specific price levels, allowing you to see if buyers or sellers were exhibiting strong momentum at the extremes or the middle of the candle.

[b]Actual Output Values[/b]
The script outputs an averaged RSI value (ranging from 0.00 to 100.00) for each specific price row. The boxes are colored based on this average (0-9 for extreme oversold, 90-100 for extreme overbought).


[b]2. Stack Mode (Vertical Momentum)[/b]
This mode stacks LTF RSI prints vertically above or below the candle based on a baseline threshold.

[image]https://www.tradingview.com/x/tE0ODDRH/[/image]


[b]■ The Calculation[/b]
By default, if the LTF RSI is > 50, it is categorized as bullish and stacked above the candle's high. If <= 50, it is stacked below the candle's low. The height of each box is calculated dynamically using:
[pine]box_height = ATR * Box Height Multiplier[/pine]

[b]Why this calculation is used[/b]
Separating prints above and below the candle isolates bullish vs. bearish momentum bursts. Using ATR for box height ensures the boxes remain visually proportionate across different assets and timeframes regardless of absolute price volatility.

[b]Actual Output Values[/b]
The output generates box coordinates (Top, Bottom, Left, Right) relative to the chart's price scale. The text inside represents the exact LTF RSI value at that sequence point (e.g., 72, 34).


[b]■ Key Features[/b]
Noise Filter (Hide Range): Clean up the chart by hiding neutral RSI values (e.g., hiding everything between 40 and 60). This leaves only the significant momentum extremes visible.

Highlight & Enlarge: Automatically expand the width and height of boxes that contain extreme RSI readings (e.g., > 80 or < 20) to instantly draw your eye to critical exhaustion points.

Compression Logic: Consecutive LTF RSI prints that fall into the same color tier and threshold are grouped into a single, taller block to prevent chart clutter.

Custom Color Themes: Choose from Normal, Aurora, Rainbow, or Monochrome to suit your chart background.

Rendering Modes: Includes a Real-time mode for live trading and an "Ultra-Light" Historical Camera Track mode to efficiently review past data without exceeding Pine Script's drawing limits.


[b]■ How to Use[/b]
1. Spotting Reversals (Matrix Mode)
Look for deep red (overbought) RSI footprints concentrated at the very top of a bullish candle. If the next candle fails to break that high, it suggests momentum exhaustion at resistance.

2. Confirming Breakouts (Stack Mode)
When price breaks a key level, look at the Stack Mode. A large stack of green/blue boxes above the candle confirms sustained LTF bullish momentum driving the move, rather than a single anomalous tick.

3. Filtering Noise
Set the "Hide Range" to 35-65. The indicator will now only display footprint boxes when the LTF RSI reaches true overbought/oversold extremes, making it highly effective for identifying turning points.

[image]https://www.tradingview.com/x/VBpo8YLK/[/image]

[b]■ Developer's Note[/b]
As a fundamental characteristic of the RSI, momentum patterns observed on higher timeframes tend to carry greater reliability due to the natural reduction of market noise. To capture the purest momentum shifts, it is recommended to begin your analysis on larger timeframes.

Disclaimer: This script maps mathematical momentum and does not guarantee future price movements. It is best used in conjunction with price action and broader market context.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator('Sin RSI Footprint', overlay = true, max_boxes_count = 500, max_bars_back = 5000)

// ~~ Constants {
const string GRP_BASE = "Base Settings"
const string TITLE_MODE = "Footprint Mode"
const string OPT_STACK = "Stack (Vertical Momentum)"
const string OPT_MAT = "Matrix (Traditional Price Level)"
const string TITLE_MAT_ROW = "Matrix Rows (For Price Mode)"
const string TT_MAT_ROW = "Specifies the number of divisions for the candlestick to measure RSI when Price Range mode is selected"
const string TITLE_LTF = "LTF Timeframe"
const string TITLE_RSI_LEN = "RSI Length"
const string TITLE_ATR_LEN = "ATR Length for Box Height"

const string GRP_POS = "Position Settings (For Stack Mode)"
const string TITLE_RSI_THR = "RSI Above/Below Threshold"
const string TT_RSI_THR = "RSIs > Threshold go ABOVE the bar. RSIs <= Threshold go BELOW the bar."

const string GRP_OPT = "Subtraction & Compression"
const string TITLE_MAX_BOX = "Max Visible Boxes"

const string GRP_HIDE = "Hide / Filter Settings"
const string TITLE_HIDE_MIN = "Hide Range Min (Noise Filter)"
const string TT_HIDE_MIN = "Hides the box when RSI is between this value and Max (ideal for removing mid-range noise)"
const string TITLE_HIDE_MAX = "Hide Range Max (Noise Filter)"

const string GRP_STYLE = "Display & Style Settings"
const string TITLE_THEME = "Color Theme"
const string OPT_NORM = "Normal"
const string OPT_AURORA = "Aurora"
const string OPT_RAINBOW = "Rainbow"
const string OPT_MONO = "Monochrome"
const string TITLE_BOX_H = "Box Height Multiplier (For Stack Mode)"
const string TITLE_TXT_SZ = "Text Size"

const string GRP_HL = "Highlight & Enlarge Settings"
const string TITLE_HL_W = "Enlarged Box Width (Bars)"
const string TITLE_HL_H = "Enlarged Box Height Ratio (For Stack Mode)"
const string TITLE_HL_ABOVE = "Enlarge RSI Above"
const string TT_HL_ABOVE = "Enlarges the box when RSI is greater than or equal to this value, or less than or equal to the Below threshold"
const string TITLE_HL_BELOW = "Enlarge RSI Below"

const string GRP_PERF = "Rendering & Performance Mode"
const string TITLE_RNDR = "Rendering Mode"
const string OPT_RT = "Real-time / Replay (Ultra-Light)"
const string OPT_HIST = "Historical / Backtest (Camera Track)"
const string TITLE_HIST_LKBK = "Historical Lookback Limit"
const string TITLE_SHOW_TXT = "Show RSI values in boxes"
const string TITLE_CALC_TICK = "Update on every tick"
//~~~~~}

// ~~ Inputs {
string fp_mode = input.string(OPT_MAT, TITLE_MODE, options=[OPT_STACK, OPT_MAT], group=GRP_BASE)
int matrix_rows = input.int(10, TITLE_MAT_ROW, group=GRP_BASE, minval=5, maxval=50, tooltip=TT_MAT_ROW)
string ltf = input.timeframe('1', TITLE_LTF, group=GRP_BASE)
int rsi_len = input.int(14, TITLE_RSI_LEN, group=GRP_BASE)
int atr_len = input.int(14, TITLE_ATR_LEN, group=GRP_BASE)

float rsi_threshold = input.float(50.0, TITLE_RSI_THR, group=GRP_POS, tooltip=TT_RSI_THR)

int max_pool_input = input.int(250, TITLE_MAX_BOX, group=GRP_OPT, minval=50, maxval=500)

float hide_min = input.float(40.0, TITLE_HIDE_MIN, group=GRP_HIDE, tooltip=TT_HIDE_MIN)
float hide_max = input.float(60.0, TITLE_HIDE_MAX, group=GRP_HIDE)

string theme_input = input.string(OPT_NORM, TITLE_THEME, options=[OPT_NORM, OPT_AURORA, OPT_RAINBOW, OPT_MONO], group=GRP_STYLE)
float box_height_mult = input.float(0.15, TITLE_BOX_H, group=GRP_STYLE, minval=0.01, maxval=1.0, step=0.01)
string txt_size_input = input.string(size.auto, TITLE_TXT_SZ, options=[size.auto, size.tiny, size.small, size.normal, size.large, size.huge], group=GRP_STYLE)

int hl_width = input.int(3, TITLE_HL_W, group=GRP_HL, minval=2, maxval=10)
float hl_height = input.float(3.0, TITLE_HL_H, group=GRP_HL, minval=1.0, maxval=5.0, step=0.5)
float hl_above = input.float(80.0, TITLE_HL_ABOVE, group=GRP_HL, tooltip=TT_HL_ABOVE)
float hl_below = input.float(20.0, TITLE_HL_BELOW, group=GRP_HL)

string render_mode = input.string(OPT_RT, TITLE_RNDR, options=[OPT_RT, OPT_HIST], group=GRP_PERF)
int hist_lookback = input.int(1000, TITLE_HIST_LKBK, group=GRP_PERF, minval=100, maxval=4900)
bool show_text = input.bool(true, TITLE_SHOW_TXT, group=GRP_PERF)
bool calc_on_tick = input.bool(false, TITLE_CALC_TICK, group=GRP_PERF)
//~~~~~}

// ~~ Helpers {
f_render_stack(float[] rsi_arr, float b_high, float b_low, int b_idx, float b_atr, color[] theme_colors, float local_hide_min, float local_hide_max, float local_hl_above, float local_hl_below, float local_rsi_threshold, bool local_show_text, float local_box_height_mult, float local_hl_height, int local_hl_width, string local_txt_size_input) =>
    box[] new_boxes = array.new_box()
    
    if not na(rsi_arr) and array.size(rsi_arr) > 0
        float base_height = b_atr * local_box_height_mult
        float top_stack_y = b_high + base_height
        float bottom_stack_y = b_low - base_height

        color current_c = na
        bool current_is_above = false
        bool current_hl = false
        int block_size = 0
        string block_text = ""

        for i = 0 to array.size(rsi_arr) - 1
            float rsi_val = array.get(rsi_arr, i)
            int lvl_idx = math.max(0, math.min(9, int(math.floor(rsi_val / 10.0))))
            
            bool is_hidden = rsi_val >= local_hide_min and rsi_val <= local_hide_max
            bool is_hl = rsi_val >= local_hl_above or rsi_val <= local_hl_below
            
            color c = is_hidden ? na : array.get(theme_colors, lvl_idx)
            bool is_above = rsi_val > local_rsi_threshold
            string txt = str.tostring(math.round(rsi_val))

            if i == 0
                current_c := c
                current_is_above := is_above
                current_hl := is_hl
                block_size := 1
                if not na(c) and local_show_text
                    block_text := txt
            else
                if (na(c) and na(current_c)) or (c == current_c and is_above == current_is_above)
                    block_size += 1
                    if not na(c) and local_show_text
                        block_text += "\n" + txt
                else
                    if not na(current_c)
                        float actual_h = current_hl ? (base_height * local_hl_height) : base_height
                        float total_h = block_size * actual_h
                        float b_top = na, float b_bottom = na

                        if current_is_above
                            b_bottom := top_stack_y
                            b_top := top_stack_y + total_h
                            top_stack_y := b_top
                        else
                            b_top := bottom_stack_y
                            b_bottom := bottom_stack_y - total_h
                            bottom_stack_y := b_bottom

                        int b_left = current_hl ? b_idx - local_hl_width : b_idx - 1
                        array.push(new_boxes, box.new(left=b_left, top=b_top, right=b_idx, bottom=b_bottom, border_color=color.new(current_c, 20), bgcolor=color.new(current_c, 60), text=block_text, text_color=color.white, text_valign=text.align_center, text_halign=text.align_center, text_size=current_hl ? size.auto : local_txt_size_input))

                    current_c := c
                    current_is_above := is_above
                    current_hl := is_hl
                    block_size := 1
                    block_text := (not na(c) and local_show_text) ? txt : ""

        if not na(current_c) and block_size > 0
            float actual_h = current_hl ? (base_height * local_hl_height) : base_height
            float total_h = block_size * actual_h
            float b_top = na, float b_bottom = na

            if current_is_above
                b_bottom := top_stack_y
                b_top := top_stack_y + total_h
                top_stack_y := b_top
            else
                b_top := bottom_stack_y
                b_bottom := bottom_stack_y - total_h
                bottom_stack_y := b_bottom

            int b_left = current_hl ? b_idx - local_hl_width : b_idx - 1
            array.push(new_boxes, box.new(left=b_left, top=b_top, right=b_idx, bottom=b_bottom, border_color=color.new(current_c, 20), bgcolor=color.new(current_c, 60), text=block_text, text_color=color.white, text_valign=text.align_center, text_halign=text.align_center, text_size=current_hl ? size.auto : local_txt_size_input))

    new_boxes

f_render_matrix(float[] rsi_arr, float[] c_arr, float b_high, float b_low, int b_idx, int local_matrix_rows, color[] theme_colors, float local_hide_min, float local_hide_max, float local_hl_above, float local_hl_below, bool local_show_text, int local_hl_width, string local_txt_size_input) =>
    box[] new_boxes = array.new_box()
    
    if not na(rsi_arr) and array.size(rsi_arr) > 0
        float step = b_high > b_low ? (b_high - b_low) / local_matrix_rows : syminfo.mintick
        
        float[] bin_rsi_acc = array.new_float(local_matrix_rows, 0.0)
        int[]   bin_count   = array.new_int(local_matrix_rows, 0)

        for i = 0 to array.size(rsi_arr) - 1
            float r = array.get(rsi_arr, i)
            float c = array.get(c_arr, i)
            
            int row = math.floor((c - b_low) / step)
            row := math.max(0, math.min(local_matrix_rows - 1, row))
            
            array.set(bin_rsi_acc, row, array.get(bin_rsi_acc, row) + r)
            array.set(bin_count, row, array.get(bin_count, row) + 1)

        for r = 0 to local_matrix_rows - 1
            int cnt = array.get(bin_count, r)
            if cnt > 0
                float avg_rsi = array.get(bin_rsi_acc, r) / cnt
                int lvl_idx = math.max(0, math.min(9, int(math.floor(avg_rsi / 10.0))))
                
                bool is_hidden = avg_rsi >= local_hide_min and avg_rsi <= local_hide_max
                bool is_hl = avg_rsi >= local_hl_above or avg_rsi <= local_hl_below
                color col = is_hidden ? na : array.get(theme_colors, lvl_idx)

                if not na(col)
                    float box_top = b_low + ((r + 1) * step)
                    float box_bot = b_low + (r * step)
                    
                    int box_left  = b_idx
                    int box_right = is_hl ? b_idx + local_hl_width : b_idx + 1

                    string txt = local_show_text ? str.tostring(math.round(avg_rsi)) : ""
                    array.push(new_boxes, box.new(left=box_left, top=box_top, right=box_right, bottom=box_bot, border_color=color.new(col, 20), bgcolor=color.new(col, 60), text=txt, text_color=color.white, text_valign=text.align_center, text_halign=text.align_center, text_size=is_hl ? size.auto : local_txt_size_input))
                    
    new_boxes
//~~~~~}

// ~~ Calculation & Drawing {
[ltf_rsi_array, ltf_c_array] = request.security_lower_tf(syminfo.tickerid, ltf, [ta.rsi(close, rsi_len), close])
float atr_series = ta.atr(atr_len)

var color[] theme_colors = array.new<color>(10)

if barstate.isfirst
    if theme_input == OPT_NORM
        theme_colors := array.from(color.navy, color.teal, color.green, color.lime, color.olive, color.yellow, color.fuchsia, color.orange, color.red, color.maroon)
    else if theme_input == OPT_AURORA
        theme_colors := array.from(color.rgb(0, 131, 143), color.rgb(0, 172, 193), color.rgb(38, 198, 218), color.rgb(41, 182, 246), color.rgb(100, 181, 246), color.rgb(159, 168, 218), color.rgb(206, 147, 216), color.rgb(171, 71, 188), color.rgb(123, 31, 162), color.rgb(74, 20, 140))
    else if theme_input == OPT_RAINBOW
        theme_colors := array.from(color.rgb(138, 43, 226), color.rgb(0, 0, 255), color.rgb(0, 128, 255), color.rgb(0, 255, 255), color.rgb(0, 255, 0), color.rgb(173, 255, 47), color.rgb(255, 255, 0), color.rgb(255, 193, 7), color.rgb(255, 127, 0), color.rgb(255, 0, 0))
    else if theme_input == OPT_MONO
        theme_colors := array.from(color.rgb(255, 255, 255), color.rgb(240, 240, 240), color.rgb(220, 220, 220), color.rgb(200, 200, 200), color.rgb(180, 180, 180), color.rgb(150, 150, 150), color.rgb(120, 120, 120), color.rgb(90, 90, 90), color.rgb(60, 60, 60), color.rgb(30, 30, 30))

var box[] drawn_boxes = array.new_box()
var box[] live_boxes = array.new_box()

if render_mode == OPT_HIST
    bool do_calc_hist = barstate.islast ? (barstate.isrealtime ? (calc_on_tick ? true : barstate.isconfirmed) : true) : false

    if do_calc_hist
        while array.size(drawn_boxes) > 0
            box.delete(array.shift(drawn_boxes))
        
        int total_rendered = 0
        int left_time = chart.left_visible_bar_time
        int right_time = chart.right_visible_bar_time

        for offset = 0 to hist_lookback
            if total_rendered >= max_pool_input or time[offset] < left_time
                break
            if time[offset] > right_time
                continue
            
            box[] temp_boxes = array.new_box()
            if fp_mode == OPT_STACK
                temp_boxes := f_render_stack(ltf_rsi_array[offset], high[offset], low[offset], bar_index[offset], atr_series[offset], theme_colors, hide_min, hide_max, hl_above, hl_below, rsi_threshold, show_text, box_height_mult, hl_height, hl_width, txt_size_input)
            else
                temp_boxes := f_render_matrix(ltf_rsi_array[offset], ltf_c_array[offset], high[offset], low[offset], bar_index[offset], matrix_rows, theme_colors, hide_min, hide_max, hl_above, hl_below, show_text, hl_width, txt_size_input)
                
            for b in temp_boxes
                array.push(drawn_boxes, b)
                total_rendered += 1
                if total_rendered >= max_pool_input
                    break
else
    if barstate.isnew
        array.clear(live_boxes)

    bool do_calc_rt = calc_on_tick and barstate.isrealtime and not barstate.isconfirmed
    
    if do_calc_rt
        while array.size(live_boxes) > 0
            box.delete(array.shift(live_boxes))
            
        if fp_mode == OPT_STACK
            live_boxes := f_render_stack(ltf_rsi_array, high, low, bar_index, atr_series, theme_colors, hide_min, hide_max, hl_above, hl_below, rsi_threshold, show_text, box_height_mult, hl_height, hl_width, txt_size_input)
        else
            live_boxes := f_render_matrix(ltf_rsi_array, ltf_c_array, high, low, bar_index, matrix_rows, theme_colors, hide_min, hide_max, hl_above, hl_below, show_text, hl_width, txt_size_input)
            
    else if barstate.ishistory or barstate.isconfirmed
        box[] temp_boxes = array.new_box()
        if fp_mode == OPT_STACK
            temp_boxes := f_render_stack(ltf_rsi_array, high, low, bar_index, atr_series, theme_colors, hide_min, hide_max, hl_above, hl_below, rsi_threshold, show_text, box_height_mult, hl_height, hl_width, txt_size_input)
        else
            temp_boxes := f_render_matrix(ltf_rsi_array, ltf_c_array, high, low, bar_index, matrix_rows, theme_colors, hide_min, hide_max, hl_above, hl_below, show_text, hl_width, txt_size_input)
            
        for b in temp_boxes
            array.push(drawn_boxes, b)
            
        while array.size(drawn_boxes) > max_pool_input
            box.delete(array.shift(drawn_boxes))
//~~~~~}
````
