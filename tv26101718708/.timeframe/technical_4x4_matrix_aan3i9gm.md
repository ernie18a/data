# Technical 4x4 Matrix

- url: https://www.tradingview.com/script/aAN3i9gm/
- type: indicator
- pine_id: PUB;ab2a9c8aa44c4b89bf56577af0ae4c2a
- version: 4.0

## Description

[b]Technical 4x4 Matrix: [/b]
Can Rethinking Common Sense Bring New Insights?

[b]Description:[/b]
Does reviewing existing common sense bring new insights? The "Technical 4x4 Matrix" challenges the traditional way we view technical analysis. Instead of stacking endless line charts or reading boring data tables, this indicator reimagines 16 classic technical indicators (RSI, MACD, Bollinger Bands, etc.) by projecting them onto a unified, 4x4 analog meter interface directly on your chart.

By standardizing completely different mathematical models into a single visual language, we can uncover hidden confluences and macro alignments that isolated indicators often miss.

[b][ Core Calculations & Expected Outputs ][/b]
To make this matrix function, the script performs heavy data normalization and correlation calculations behind the scenes. Here is why these calculations are used and what they actually output:

[b]1. Data Normalization Engine (The Analog Meters)[/b]
Why it's used: You cannot simply average an RSI (measured 0 to 100) with a MACD (absolute price differences). To create a unified "Average Flow," every indicator must be converted to a uniform scale.

The Calculation: The script uses a custom normalization formula:
Normalized Value = (Current Value - Min Value) / (Max Value - Min Value)
Actual Output Value: Regardless of the indicator's native scale, the output value for every single meter is strictly constrained between 0.0 (Absolute Cold/Oversold) and 1.0 (Absolute Hot/Overbought). For example, a neutral RSI of 50 outputs exactly 0.5.
2. Master HUD Crosshair (Macro Correlation)
Why it's used: To determine if the current micro price action is actually aligned with the macro trend, rather than just reacting to short-term noise.
The Calculation:

First, it creates a ratio: Macro Ratio = SMA(Close, 250) / SMA(Close, 1)
Next, it calculates the correlation between the closing price and this ratio over 20 periods, scaling it for the HUD's Y-Axis:
Y-Axis Ratio = (Correlation + 1.0) / 2.0
Actual Output Value: The raw correlation ranges from -1.0 to 1.0. After scaling, the final Y-Axis output is a coordinate between 0.0 and 1.0. The X-Axis is the simple average of all active 0.0 to 1.0 normalized indicators. If the crosshair intersects at (0.8, 0.8), it outputs a mathematically backed signal of strong macro and micro bullish alignment.


16 togglable indicators rendered as square analog meters with dynamic needle tracking and LED status lights.
Garbage Collection: Efficient array clearing prevents memory leaks and visual ghosting.
Master Crosshair: A central HUD that tracks the aggregated flow of all 16 indicators (X-axis) against macro-trend correlation (Y-axis).

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ALT_analyst

//@version=6
indicator("Technical 4x4 Matrix", overlay=false, max_lines_count=500, max_labels_count=500)
import TradingView/ta/14

// ~~ Constants {
const string GRP_UI = "Matrix UI Settings"
const string TITLE_POS = "HUD Position"
const string OPT_POS_L = "Left (Past Bars)"
const string OPT_POS_R = "Right (Future Blank Space)"
const string TITLE_RAD_X = "Meter Width"
const string TITLE_RAD_Y = "Meter Height"
const string TITLE_SPC_X = "X Spacing"
const string TITLE_SPC_Y = "Y Spacing"

const string GRP_TXT = "Text Settings"
const string TITLE_NAME_SZ = "Name Size"
const string TITLE_LCD_SZ = "LCD Size"
const string OPT_TINY = "Tiny"
const string OPT_SMALL = "Small"
const string OPT_NORM = "Normal"

const string GRP_COL = "Color Settings"
const string TITLE_C_LCD = "LCD Background"
const string TITLE_C_BEZ = "Square Bezel"
const string TITLE_C_COLD = "Zone 1 (Cold)"
const string TITLE_C_NORM = "Zone 2 (Neutral)"
const string TITLE_C_HOT = "Zone 3 (Hot)"
const string TITLE_C_OFF = "Disabled (Gray)"
const string TITLE_C_MAST = "Master Laser (Purple)"

const string GRP_I = "Indicator Toggles & Lengths"
const string INL_01 = "i01"
const string INL_02 = "i02"
const string INL_03 = "i03"
const string INL_04 = "i04"
const string INL_05 = "i05"
const string INL_06 = "i06"
const string INL_07 = "i07"
const string INL_08 = "i08"
const string INL_09 = "i09"
const string INL_10 = "i10"
const string INL_11 = "i11"
const string INL_12 = "i12"
const string INL_13 = "i13"
const string INL_14 = "i14"
const string INL_15 = "i15"
const string INL_16 = "i16"

const string GRP_MAST = "Master Customization"
const string TITLE_SHOW_M = "Show Master Crosshair"
const string TITLE_M_Y_LEN = "Macro Trend SMA Length"
const string TITLE_M_C_LEN = "Macro Correlation Length"
//~~~~~}

// ~~ Inputs {
string hud_pos = input.string(OPT_POS_R, TITLE_POS, options=[OPT_POS_L, OPT_POS_R], group=GRP_UI)
float radius_x = input.float(15.0, TITLE_RAD_X, group=GRP_UI)
float radius_y = input.float(20.0, TITLE_RAD_Y, group=GRP_UI)
int spacing_x = input.int(30, TITLE_SPC_X, group=GRP_UI)
int spacing_y = input.int(40, TITLE_SPC_Y, group=GRP_UI)

string ticker_size_str = input.string(OPT_TINY, TITLE_NAME_SZ, options=[OPT_TINY, OPT_SMALL, OPT_NORM], group=GRP_TXT)
string lcd_size_str = input.string(OPT_TINY, TITLE_LCD_SZ, options=[OPT_TINY, OPT_SMALL, OPT_NORM], group=GRP_TXT)

color color_lcd_bg    = input.color(color.new(#0D0B1A, 20), TITLE_C_LCD, group=GRP_COL)
color color_bezel_out = input.color(color.new(#636363, 0), TITLE_C_BEZ, group=GRP_COL)
color color_cold      = input.color(#00E5FF, TITLE_C_COLD, group=GRP_COL)
color color_norm      = input.color(#00FF00, TITLE_C_NORM, group=GRP_COL)
color color_hot       = input.color(#FF0055, TITLE_C_HOT, group=GRP_COL)
color color_off       = input.color(color.new(color.gray, 70), TITLE_C_OFF, group=GRP_COL)
color color_master    = input.color(#B026FF, TITLE_C_MAST, group=GRP_COL)

bool i01_on = input.bool(true, "RSI", inline=INL_01, group=GRP_I)
int i01_len = input.int(14, "", inline=INL_01, group=GRP_I)
bool i02_on = input.bool(true, "STOCH", inline=INL_02, group=GRP_I)
int i02_len = input.int(14, "", inline=INL_02, group=GRP_I)
bool i03_on = input.bool(true, "MFI", inline=INL_03, group=GRP_I)
int i03_len = input.int(14, "", inline=INL_03, group=GRP_I)
bool i04_on = input.bool(true, "CCI", inline=INL_04, group=GRP_I)
int i04_len = input.int(20, "", inline=INL_04, group=GRP_I)
bool i05_on = input.bool(true, "WPR", inline=INL_05, group=GRP_I)
int i05_len = input.int(14, "", inline=INL_05, group=GRP_I)
bool i06_on = input.bool(true, "CMO", inline=INL_06, group=GRP_I)
int i06_len = input.int(14, "", inline=INL_06, group=GRP_I)
bool i07_on = input.bool(true, "TSI", inline=INL_07, group=GRP_I)
int i07_len = input.int(13, "", inline=INL_07, group=GRP_I)
bool i08_on = input.bool(true, "UO", inline=INL_08, group=GRP_I)
int i08_len = input.int(14, "", inline=INL_08, group=GRP_I)
bool i09_on = input.bool(true, "DMI", inline=INL_09, group=GRP_I)
int i09_len = input.int(14, "", inline=INL_09, group=GRP_I)
bool i10_on = input.bool(true, "ADX", inline=INL_10, group=GRP_I)
int i10_len = input.int(14, "", inline=INL_10, group=GRP_I)
bool i11_on = input.bool(true, "ROC", inline=INL_11, group=GRP_I)
int i11_len = input.int(14, "", inline=INL_11, group=GRP_I)
bool i12_on = input.bool(true, "MACD", inline=INL_12, group=GRP_I)
int i12_len = input.int(12, "", inline=INL_12, group=GRP_I)
bool i13_on = input.bool(true, "VOL SMA", inline=INL_13, group=GRP_I)
int i13_len = input.int(20, "", inline=INL_13, group=GRP_I)
bool i14_on = input.bool(true, "BB%B", inline=INL_14, group=GRP_I)
int i14_len = input.int(20, "", inline=INL_14, group=GRP_I)
bool i15_on = input.bool(true, "KC%K", inline=INL_15, group=GRP_I)
int i15_len = input.int(20, "", inline=INL_15, group=GRP_I)
bool i16_on = input.bool(true, "MOM%", inline=INL_16, group=GRP_I)
int i16_len = input.int(10, "", inline=INL_16, group=GRP_I)

bool master_show = input.bool(true, TITLE_SHOW_M, group=GRP_MAST)
int master_y_len = input.int(250, TITLE_M_Y_LEN, group=GRP_MAST)
int master_corr_len = input.int(20, TITLE_M_C_LEN, group=GRP_MAST)
//~~~~~}

// ~~ Helpers {
f_string_to_size(string s) => 
    s == OPT_TINY ? size.tiny : s == OPT_SMALL ? size.small : size.normal

f_norm(v, min_v, max_v) => 
    math.max(math.min((v - min_v) / (max_v - min_v), 1.0), 0.0)

var line[] drawn_lines = array.new_line()
var label[] drawn_labels = array.new_label()
//~~~~~}

// ~~ Calculation & Drawing {
string sz_ticker = f_string_to_size(ticker_size_str)
string sz_lcd = f_string_to_size(lcd_size_str)

float y_ma = request.security(syminfo.tickerid, "D", ta.sma(close, master_y_len))
float d_ma = request.security(syminfo.tickerid, "D", close)
float safe_d_ma = d_ma == 0 ? 1.0 : d_ma
float macro_ratio = y_ma / safe_d_ma
float macro_corr = ta.correlation(close, macro_ratio, master_corr_len)
float macro_corr_val = nz(macro_corr, 0.0)
float master_y_ratio = (math.max(math.min(macro_corr_val, 1.0), -1.0) + 1.0) / 2.0

float v01 = i01_on ? nz(ta.rsi(close, i01_len)) : 0.0
float r01 = f_norm(v01, 0, 100)
float v02 = i02_on ? nz(ta.stoch(close, high, low, i02_len)) : 0.0
float r02 = f_norm(v02, 0, 100)
float v03 = i03_on ? nz(ta.mfi(close, i03_len)) : 0.0
float r03 = f_norm(v03, 0, 100)
float v04 = i04_on ? nz(ta.cci(close, i04_len)) : 0.0
float r04 = f_norm(v04, -200, 200)
float v05 = i05_on ? nz(ta.wpr(i05_len)) : 0.0
float r05 = f_norm(v05, -100, 0)
float v06 = i06_on ? nz(ta.cmo(close, i06_len)) : 0.0
float r06 = f_norm(v06, -100, 100)
float v07 = i07_on ? nz(ta.tsi(close, i07_len, 25)) : 0.0
float r07 = f_norm(v07, -50, 50)
float v08 = i08_on ? nz(ta.uo(7, i08_len, 28)) : 0.0
float r08 = f_norm(v08, 0, 100)
[dp, dm, adx] = ta.dmi(i09_len, i09_len)
float v09 = i09_on ? nz(dp - dm) : 0.0
float r09 = f_norm(v09, -50, 50)
float v10 = i10_on ? nz(adx) : 0.0
float r10 = f_norm(v10, 0, 100)
float v11 = i11_on ? nz(ta.roc(close, i11_len)) : 0.0
float r11 = f_norm(v11, -10, 10)
[macdLine, signalLine, hist] = ta.macd(close, i12_len, 26, 9)
float v12 = i12_on ? nz(macdLine) : 0.0
float r12 = f_norm(v12, -ta.atr(14)*0.5, ta.atr(14)*0.5)
float v13 = i13_on ? nz(ta.sma(volume, 5)/ta.sma(volume, i13_len)*100) : 0.0
float r13 = f_norm(v13, 50, 150)
[bb_m, bb_u, bb_l] = ta.bb(close, i14_len, 2.0)
float v14 = i14_on ? nz((close - bb_l) / (bb_u - bb_l == 0 ? 0.001 : bb_u - bb_l) * 100) : 0.0
float r14 = f_norm(v14, 0, 100)
[kc_m, kc_u, kc_l] = ta.kc(close, i15_len, 2)
float v15 = i15_on ? nz((close - kc_l) / (kc_u - kc_l == 0 ? 0.001 : kc_u - kc_l) * 100) : 0.0
float r15 = f_norm(v15, 0, 100)
float v16 = i16_on ? nz(ta.change(close, i16_len)/(close[i16_len] == 0 ? 0.001 : close[i16_len])*100) : 0.0
float r16 = f_norm(v16, -5, 5)

var bool[] on_arr = array.new_bool()
var float[] ratio_arr = array.new_float()
var string[] name_arr = array.new_string()
var string[] text_arr = array.new_string()

if barstate.islast
    while array.size(drawn_lines) > 0
        line.delete(array.shift(drawn_lines))
    while array.size(drawn_labels) > 0
        label.delete(array.shift(drawn_labels))

    array.clear(on_arr)
    array.clear(ratio_arr)
    array.clear(name_arr)
    array.clear(text_arr)
    
    array.push(on_arr, i01_on), array.push(name_arr, "RSI"), array.push(ratio_arr, r01), array.push(text_arr, i01_on ? str.tostring(v01, "#.1") : "OFF")
    array.push(on_arr, i02_on), array.push(name_arr, "STOCH"), array.push(ratio_arr, r02), array.push(text_arr, i02_on ? str.tostring(v02, "#.1") : "OFF")
    array.push(on_arr, i03_on), array.push(name_arr, "MFI"), array.push(ratio_arr, r03), array.push(text_arr, i03_on ? str.tostring(v03, "#.1") : "OFF")
    array.push(on_arr, i04_on), array.push(name_arr, "CCI"), array.push(ratio_arr, r04), array.push(text_arr, i04_on ? str.tostring(v04, "#.1") : "OFF")
    array.push(on_arr, i05_on), array.push(name_arr, "WPR"), array.push(ratio_arr, r05), array.push(text_arr, i05_on ? str.tostring(v05, "#.1") : "OFF")
    array.push(on_arr, i06_on), array.push(name_arr, "CMO"), array.push(ratio_arr, r06), array.push(text_arr, i06_on ? str.tostring(v06, "#.1") : "OFF")
    array.push(on_arr, i07_on), array.push(name_arr, "TSI"), array.push(ratio_arr, r07), array.push(text_arr, i07_on ? str.tostring(v07, "#.1") : "OFF")
    array.push(on_arr, i08_on), array.push(name_arr, "UO"), array.push(ratio_arr, r08), array.push(text_arr, i08_on ? str.tostring(v08, "#.1") : "OFF")
    array.push(on_arr, i09_on), array.push(name_arr, "DI-DIF"), array.push(ratio_arr, r09), array.push(text_arr, i09_on ? str.tostring(v09, "#.1") : "OFF")
    array.push(on_arr, i10_on), array.push(name_arr, "ADX"), array.push(ratio_arr, r10), array.push(text_arr, i10_on ? str.tostring(v10, "#.1") : "OFF")
    array.push(on_arr, i11_on), array.push(name_arr, "ROC"), array.push(ratio_arr, r11), array.push(text_arr, i11_on ? str.tostring(v11, "#.2") : "OFF")
    array.push(on_arr, i12_on), array.push(name_arr, "MACD"), array.push(ratio_arr, r12), array.push(text_arr, i12_on ? str.tostring(v12, "#.2") : "OFF")
    array.push(on_arr, i13_on), array.push(name_arr, "VOL%"), array.push(ratio_arr, r13), array.push(text_arr, i13_on ? str.tostring(v13, "#.0") : "OFF")
    array.push(on_arr, i14_on), array.push(name_arr, "BB%B"), array.push(ratio_arr, r14), array.push(text_arr, i14_on ? str.tostring(v14, "#.0") : "OFF")
    array.push(on_arr, i15_on), array.push(name_arr, "KC%K"), array.push(ratio_arr, r15), array.push(text_arr, i15_on ? str.tostring(v15, "#.0") : "OFF")
    array.push(on_arr, i16_on), array.push(name_arr, "MOM%"), array.push(ratio_arr, r16), array.push(text_arr, i16_on ? str.tostring(v16, "#.2") : "OFF")

    int cols = 4
    int total_width = (cols - 1) * spacing_x
    int base_x = hud_pos == OPT_POS_R ? bar_index + 15 : bar_index - total_width - 15
    float base_y = 120.0

    int master_left = base_x - int(radius_x)
    int master_right = base_x + ((cols - 1) * spacing_x) + int(radius_x)
    float master_top = base_y + radius_y
    float master_bot = base_y - (3 * spacing_y) - radius_y

    float sum_pct = 0.0
    int active_cnt = 0

    for i = 0 to 15
        int col = i % cols
        int row = int(math.floor(i / cols))
        
        int cx = base_x + (col * spacing_x)
        float cy = base_y - (row * spacing_y)
        
        int left_x = cx - int(radius_x)
        int right_x = cx + int(radius_x)
        float top_y = cy + radius_y
        float bot_y = cy - radius_y

        bool is_on = array.get(on_arr, i)
        float pct = is_on ? array.get(ratio_arr, i) : 0.5
        
        if is_on
            sum_pct += pct
            active_cnt += 1

        array.push(drawn_lines, line.new(left_x, bot_y, right_x, bot_y, color=color_bezel_out, width=2))
        array.push(drawn_lines, line.new(left_x, top_y, right_x, top_y, color=color_bezel_out, width=2))
        array.push(drawn_lines, line.new(left_x, bot_y, left_x, top_y, color=color_bezel_out, width=2))
        array.push(drawn_lines, line.new(right_x, bot_y, right_x, top_y, color=color_bezel_out, width=2))

        array.push(drawn_labels, label.new(x=left_x + 1, y=top_y - 1, text="+", color=color.new(color.black,100), textcolor=color.new(color.silver, 30), style=label.style_none, size=size.tiny))
        array.push(drawn_labels, label.new(x=right_x - 1, y=top_y - 1, text="+", color=color.new(color.black,100), textcolor=color.new(color.silver, 30), style=label.style_none, size=size.tiny))
        array.push(drawn_labels, label.new(x=left_x + 1, y=bot_y + 1, text="+", color=color.new(color.black,100), textcolor=color.new(color.silver, 30), style=label.style_none, size=size.tiny))
        array.push(drawn_labels, label.new(x=right_x - 1, y=bot_y + 1, text="+", color=color.new(color.black,100), textcolor=color.new(color.silver, 30), style=label.style_none, size=size.tiny))

        for k = 0 to 12
            float tick_angle = (5.0 * math.pi / 4.0) - (k * (1.5 * math.pi / 12.0))
            bool is_main = (k % 2 == 0)
            float inner_r = is_main ? 0.65 : 0.78
            int tick_w = is_main ? 2 : 1
            
            int tx1 = cx + int(math.round(radius_x * inner_r * math.cos(tick_angle)))
            float ty1 = cy + (radius_y * inner_r * math.sin(tick_angle))
            int tx2 = cx + int(math.round(radius_x * 0.90 * math.cos(tick_angle)))
            float ty2 = cy + (radius_y * 0.90 * math.sin(tick_angle))
            
            color t_col = not is_on ? color_off : (k >= 9 ? color_hot : (k >= 4 ? color_norm : color_cold))
            array.push(drawn_lines, line.new(tx1, ty1, tx2, ty2, color=is_main ? t_col : color.new(color.white, 70), width=tick_w))

        float needle_rad = (5.0 * math.pi / 4.0) - (pct * 1.5 * math.pi)
        color needle_col = not is_on ? color_off : (pct >= 0.75 ? color_hot : (pct <= 0.25 ? color_cold : color_norm))
        
        int nx = cx + int(math.round(radius_x * 0.85 * math.cos(needle_rad)))
        float ny = cy + (radius_y * 0.85 * math.sin(needle_rad))
        
        array.push(drawn_lines, line.new(cx + 1, cy - 0.5, nx + 1, ny - 0.5, color=color.new(color.black, 40), width=2))
        array.push(drawn_lines, line.new(cx, cy, nx, ny, color=needle_col, width=2))

        array.push(drawn_labels, label.new(x=cx, y=cy, text="", color=color.new(color.black, 20), style=label.style_circle, size=size.tiny))
        array.push(drawn_labels, label.new(x=cx, y=cy, text="・", color=color.new(color.black, 100), textcolor=color.silver, style=label.style_none, size=size.tiny))
        
        color led_col = not is_on ? color_off : (pct >= 0.75 ? color_hot : (pct <= 0.25 ? color_cold : color.new(color_norm, 70)))
        array.push(drawn_labels, label.new(x=cx + int(math.round(radius_x * 0.5)), y=cy - (radius_y * 0.3), text="", color=led_col, style=label.style_circle, size=size.tiny))

        string lcd_txt = array.get(text_arr, i)
        array.push(drawn_labels, label.new(x=cx, y=cy - (radius_y * 0.40), text=lcd_txt, color=color_lcd_bg, textcolor=needle_col, style=label.style_label_center, size=sz_lcd))
        array.push(drawn_labels, label.new(x=cx, y=cy + (radius_y * 0.45), text=array.get(name_arr, i), color=color.new(color.black, 100), textcolor=color.white, style=label.style_none, size=sz_ticker))

    if master_show
        float master_x_ratio = active_cnt > 0 ? sum_pct / active_cnt : 0.5
        int master_px = master_left + int(math.round(master_x_ratio * (master_right - master_left)))
        float master_py = master_bot + (master_y_ratio * (master_top - master_bot))

        array.push(drawn_lines, line.new(master_left, master_bot, master_right, master_bot, color=color.new(color_master, 70), width=1, style=line.style_dotted))
        array.push(drawn_lines, line.new(master_left, master_bot, master_left, master_top, color=color.new(color_master, 70), width=1, style=line.style_dotted))
        array.push(drawn_lines, line.new(master_px, master_bot, master_px, master_top, color=color.new(color_master, 30), width=3))
        array.push(drawn_lines, line.new(master_left, master_py, master_right, master_py, color=color.new(color_master, 30), width=3))

        array.push(drawn_labels, label.new(x=master_px, y=master_bot - 4, text="▲\nAVG FLOW", color=color.new(color.black, 100), textcolor=color_master, style=label.style_label_up, size=size.small))
        array.push(drawn_labels, label.new(x=master_px, y=master_top + 4, text="▼", color=color.new(color.black, 100), textcolor=color_master, style=label.style_label_down, size=size.small))
        array.push(drawn_labels, label.new(x=master_left - 3, y=master_py, text="MACRO\n▶", color=color.new(color.black, 100), textcolor=color_master, style=label.style_label_right, size=size.small))
        array.push(drawn_labels, label.new(x=master_right + 3, y=master_py, text="◀", color=color.new(color.black, 100), textcolor=color_master, style=label.style_label_left, size=size.small))
        array.push(drawn_labels, label.new(x=master_px, y=master_py, text="✛", color=color.new(color.black, 100), textcolor=color.white, style=label.style_label_center, size=size.large))
//~~~~~}
````
