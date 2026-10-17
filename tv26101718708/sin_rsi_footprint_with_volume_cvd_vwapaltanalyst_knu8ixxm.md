# Sin RSI Footprint (with Volume, CVD & VWAP)[ALT_analyst]

- url: https://www.tradingview.com/script/Knu8iXxM/
- type: indicator
- pine_id: PUB;10c3f9f2d92b4596bb1831a0f0435284
- version: 2.0

## Description

[b]█ Overview
The Sin RSI Footprint [ALT_analyst] [/b]brings the concept of professional order flow and footprint charting directly into momentum oscillators.

Instead of mapping traditional trading volume at raw price levels, this script peers inside the current higher-timeframe candle to map the internal momentum distribution and structural shifts using Lower Timeframe (LTF) RSI Crossovers, Volume, and Cumulative Volume Delta (CVD) data.

By visualizing exactly where and how momentum transitions occurred within a single bar, traders can identify hidden exhaustion, hidden accumulation/distribution, and intra-bar divergences that are completely invisible on standard candlestick charts.

[image]https://www.tradingview.com/x/z9DHFH36/[/image]

[b]█ Why is this one unique[/b]
This is not a normal RSI indicator. It is an intra-bar market structure mapping engine.

Most indicators treat every price level within a single candlestick as equal. This script uses a Fast/Slow RSI Cross Trigger mechanism to filter out ambient market noise, isolating the exact coordinates where momentum definitively shifts. It transforms these structural shifts into a multi-dimensional footprint matrix, combining them with localized transaction metrics.

[b]⚪ What it does[/b]
At a high level:
• Retrieves LTF Crossover Data: Uses request.security_lower_tf to fetch an array of LTF Fast/Slow RSI crosses, Close prices, Volume, and CVD for the duration of the current chart's bar.

• Bins the data: Groups the validated LTF momentum nodes into precise price levels or vertical stacks.

• Calculates localized momentum: Identifies exactly where the definitive momentum shifts occurred inside the wick or body.

• Applies VWAP Trend Discipline: Dynamically filters out counter-trend noise based on a multi-band session VWAP.

[image]https://www.tradingview.com/x/NH9CDY7X/[/image]

[b]█ Core Engines & How It Works[/b]

[b]⚪ 1. The Matrix Engine (Traditional Price Level)[/b]
This mode acts like a traditional volume profile or footprint chart, but optimized for RSI crossover nodes and localized liquidity.

[image]https://www.tradingview.com/x/jhb55N6x/[/image]

The script divides the high-to-low range of the current candle into user-defined bins (e.g., 10 rows). It calculates the step size dynamically:

[pine]float _st = _bh > _bl ? (_bh - _bl) / _i21 : syminfo.mintick[/pine]

For each LTF crossover point, it determines the correct row and calculates the localized average RSI, accumulated Volume, and CVD.
Why this matters: It maps definitive momentum shifts to specific price levels. You can instantly see if buyers were exhausting their momentum at the absolute highs or absorbing pressure in the middle of the candle.

[b]⚪ 2. The Stack Engine (Vertical Momentum)[/b]
This mode stacks validated LTF RSI crossover prints vertically above or below the candle based on a baseline threshold.

If the triggered LTF RSI is > 50, it is categorized as bullish and stacked above the candle's high. If <= 50, it is stacked below the candle's low. The height of each box is calculated dynamically using the Average True Range (ATR):

[pine]float _bhg = _ba * _i22[/pine]

Why this matters: Separating crossover prints above and below the candle isolates bullish vs. bearish momentum bursts. Using ATR for box height ensures the boxes remain visually proportionate across different assets and timeframes regardless of absolute price volatility.

[b]⚪ 3. The Adaptive VWAP Filter Engine & Multi-Bands[/b]
To enforce strict trading discipline ("No position is the third position"), the script includes an adaptive VWAP transparency filter and a dynamic multi-band system.

If a localized footprint box generates a "Sell" signal (overbought RSI) but the price level is ABOVE the session VWAP (bullish regime), the script automatically increases the transparency of that box, fading it into the background. It does the same for "Buy" signals below VWAP.

This ensures you are only presented with high-probability exhaustion or continuation signals that align with the true intraday value.

[b]█ Key Features[/b]
• Micro Momentum Analysis: Displays localized RSI, Volume (K), and CVD directly inside the footprint boxes only when a momentum shift is confirmed.

• VWAP Trend Gate & Gradient Bands: Counter-trend signals are visually faded to prevent fighting the primary trend, visualized alongside 3 dynamic standard deviation bands.

• Noise Filter (Hide Range): Clean up the chart by hiding neutral RSI values (e.g., hiding everything between 30 and 70).

• Responsive Text Scaling: Box text size automatically adapts based on box height and user-defined scaling adjustments.

• Custom Color Themes: Choose from heavily optimized palettes including Neon Cyber, Monochrome Dark, Oceanic Deep, Toxic Alert, and Classic TV.

[b]█ Settings[/b]
• Mode: Select the rendering engine (Stack or Matrix).

• Fast/Slow RSI Length (Cross Trigger): Defines the sensitivity of the LTF momentum shift detection.

• Matrix Rows: Specifies how many segments the candle is divided into.

• Lower Timeframe (LTF): Specifies the lower timeframe for data collection. Shorter LTFs provide higher precision but increase historical loading requirements.

• Counter-Trend Signal Transparency Filter: Toggles the adaptive VWAP filter.

• Hide Range Min / Max: Filters out neutral momentum values to isolate true extreme nodes.

[b]█ How to Use[/b]

[b]⚪ Spotting Reversals (Matrix Mode)[/b]
Look for deep red (overbought) RSI footprints concentrated at the very top of a bullish candle's wick. If the next candle fails to break that high, combined with a negative CVD print in the box, it highly suggests momentum exhaustion and trapped buyers at resistance.

[b]⚪ Confirming Breakouts (Stack Mode)[/b]
When price breaks a key level, look at the Stack Mode. A large stack of green/blue boxes above the candle, supported by high relative volume, confirms sustained LTF bullish momentum shifting in your favor.

[b]⚪ Filtering Noise[/b]
Set the "Hide Range" to 30-70 and enable the "VWAP Filter". The indicator will now only display footprint boxes when the LTF momentum shift reaches true extremes in the direction of the daily trend.

[b]█ Developer's Note & Timeframe Guidelines[/b]

As a fundamental characteristic of market structure, momentum patterns observed on higher timeframes tend to carry greater reliability due to the natural reduction of market noise. To achieve optimal performance and prevent technical limitations (TradingView limits), follow these recommended timeframe ratios:

• For Stack Mode (Recommended Ratio: 1:5 to 1:12)
Best paired as 1m LTF on 5m/10m chart, or 5m LTF on 30m/1H chart.

• For Matrix Mode (Recommended Ratio: 1:12 to 1:60)
Best paired as 1m LTF on 15m/1H chart.

[b]Disclaimer[/b]

The content provided in my scripts, indicators, ideas, algorithms, and systems is for educational and informational purposes only. It does not constitute financial advice, investment recommendations, or a solicitation to buy or sell any financial instruments. I will not accept liability for any loss or damage, including without limitation any loss of profit, which may arise directly or indirectly from the use of or reliance on such information. All investments involve risk, and the past performance of a security, industry, sector, market, financial product, trading strategy, backtest, or individual's trading does not guarantee future results or returns. Investors are fully responsible for any investment decisions they make.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Sin RSI Footprint (with Volume, CVD & VWAP)[ALT_analyst]", "SRF[ALT_analyst]", overlay = true, max_boxes_count = 500, max_bars_back = 5000)

// ~~ Constants {
const string GRP_1 = "▼ 1. Main Settings (Main Flow)"
const string TITLE_MODE = "➔ [1] Mode"
const string OPT_STACK = "Stack (Vertical Momentum)"
const string OPT_MATRIX = "Matrix (Traditional Price Level)"
const string TITLE_LTF = "➔ [2] Lower Timeframe (LTF)"
const string TITLE_RSI_SRC = " ↳ RSI Source"
const string TITLE_RSI_LEN = " ↳ RSI Length"
const string TITLE_ATR_LEN = " ↳ ATR Length"
const string TITLE_FAST_LEN = " ↳ Fast RSI Length (Cross Trigger)"
const string TITLE_SLOW_LEN = " ↳ Slow RSI Length (Cross Trigger)"

const string GRP_2 = "▼ 2. Filters"
const string TITLE_BASELINE = "➔ RSI Baseline"
const string TITLE_HIDE_MIN = "➔ Hide Range Min"
const string TITLE_HIDE_MAX = " ↳ Max"

const string GRP_3 = "▼ 3. VWAP Settings (VWAP Logic)"
const string TITLE_VWAP_CTR = "➔ Show VWAP Center"
const string TITLE_ANCHOR = "➔ Anchor Period"
const string OPT_SESS = "Session"
const string OPT_WEEK = "Week"
const string OPT_MNTH = "Month"
const string OPT_QTR = "Quarter"
const string OPT_YEAR = "Year"
const string OPT_DEC = "Decade"
const string OPT_CENT = "Century"
const string OPT_EARN = "Earnings"
const string OPT_DIV = "Dividends"
const string OPT_SPLIT = "Splits"
const string TITLE_BAND_CALC = "➔ Bands Calculation Mode"
const string OPT_STDEV = "Standard Deviation"
const string OPT_PERC = "Percentage"
const string TT_BAND_CALC = "Percentage mode: a multiplier of 1 means 1%."
const string TITLE_SHOW_B1 = "➔ Show Band 1"
const string TITLE_MULT_B1 = "Multiplier"
const string TITLE_SHOW_B2 = "➔ Show Band 2"
const string TITLE_MULT_B2 = "Multiplier"
const string TITLE_SHOW_B3 = "➔ Show Band 3"
const string TITLE_MULT_B3 = "Multiplier"
const string TITLE_FILT_CTR = "➔ Counter-Trend Signal Transparency Filter"

const string GRP_4 = "▼ 4. Box Size & Layout"
const string TITLE_MAT_ROWS = "➔ Matrix Rows (Matrix Mode)"
const string TITLE_BOX_H_MULT = "➔ Box Height Multiplier"
const string TITLE_HL_W = "➔ Highlight Box Width"
const string TITLE_HL_H = " ↳ Height"
const string TITLE_MAX_BOX = "➔ Max Display Boxes"

const string GRP_5 = "▼ 5. Theme & Style Integration"
const string TITLE_THEME = "➔ Color Theme Preset"
const string OPT_NEON = "Neon Cyber"
const string OPT_MONO = "Monochrome Dark"
const string OPT_OCEAN = "Oceanic Deep"
const string OPT_TOXIC = "Toxic Alert"
const string OPT_CLASSIC = "Classic TV"
const string TT_THEME = "Automatically configures Box, Band, and Text colors to maintain optimal contrast."
const string TITLE_TXT_SCL = "➔ Text Scale Adjustment"
const string TITLE_SHOW_NRSI = "➔ [Normal RSI] Show Text"
const string TITLE_OB_LVL = "➔ [Overbought/Sold] Sell (Upper)"
const string TITLE_OS_LVL = "Buy (Lower)"
const string TITLE_SHOW_HL = " ↳ Show Highlight Text"
const string TITLE_VOL_M_THR = "➔ [Mid Volume] Threshold (%)"
const string TITLE_VOL_M_SHW = "Show"
const string TITLE_VOL_M_COL = "Color"
const string TITLE_VOL_H_THR = "➔ [High Volume] Threshold (%)"
const string TITLE_VOL_H_SHW = "Show"
const string TITLE_VOL_H_COL = "Color"

const string GRP_6 = "▼ 6. Render Data Settings"
const string TITLE_RNDR_MODE = "➔ Render Mode"
const string OPT_RNDR_RT = "Real-time / Replay (Ultra-Light)"
const string OPT_RNDR_HIST = "Historical / Backtest (Camera Track)"
const string TITLE_HIST_LIM = " ↳ History Limit"
const string TITLE_DATA_LAY = "➔ Data Display Layout"
const string OPT_LAY_ALL = "1. Multi-Line (All Separated)"
const string OPT_LAY_PV = "2. Single-Line (Price + Vol)"
const string OPT_LAY_PC = "3. Single-Line (Price + CVD)"
const string OPT_LAY_PVC = "4. Single-Line (Price + Vol + CVD)"
const string OPT_LAY_RSI = "5. RSI Only"
const string TITLE_LIVE_UPD = "➔ Update on Every Tick"
//~~~~~}

// ~~ Inputs {
string in_mode = input.string(OPT_STACK, TITLE_MODE, options=[OPT_STACK, OPT_MATRIX], group=GRP_1)
string in_ltf = input.timeframe('3', TITLE_LTF, group=GRP_1)
float in_rsi_src = input.source(close, TITLE_RSI_SRC, group=GRP_1, inline="len")
int in_rsi_len = input.int(14, TITLE_RSI_LEN, group=GRP_1, inline="len")
int in_atr_len = input.int(14, TITLE_ATR_LEN, group=GRP_1, inline="len")
int in_fast_len = input.int(7, TITLE_FAST_LEN, group=GRP_1, inline="len2")
int in_slow_len = input.int(14, TITLE_SLOW_LEN, group=GRP_1, inline="len2")

float in_rsi_base = input.float(50.0, TITLE_BASELINE, group=GRP_2)
float in_hide_min = input.float(30.0, TITLE_HIDE_MIN, group=GRP_2, inline="hide")
float in_hide_max = input.float(70.0, TITLE_HIDE_MAX, group=GRP_2, inline="hide")

bool in_show_vwap = input.bool(true, TITLE_VWAP_CTR, group=GRP_3)
string in_anchor = input.string(OPT_SESS, TITLE_ANCHOR, options=[OPT_SESS, OPT_WEEK, OPT_MNTH, OPT_QTR, OPT_YEAR, OPT_DEC, OPT_CENT, OPT_EARN, OPT_DIV, OPT_SPLIT], group=GRP_3)
string in_band_mode = input.string(OPT_STDEV, TITLE_BAND_CALC, options=[OPT_STDEV, OPT_PERC], group=GRP_3, tooltip=TT_BAND_CALC)
bool in_show_b1 = input.bool(true, TITLE_SHOW_B1, group=GRP_3, inline="b1")
float in_mult_b1 = input.float(1.0, TITLE_MULT_B1, group=GRP_3, minval=0.1, step=0.5, inline="b1")
bool in_show_b2 = input.bool(true, TITLE_SHOW_B2, group=GRP_3, inline="b2")
float in_mult_b2 = input.float(2.0, TITLE_MULT_B2, group=GRP_3, minval=0.1, step=0.5, inline="b2")
bool in_show_b3 = input.bool(true, TITLE_SHOW_B3, group=GRP_3, inline="b3")
float in_mult_b3 = input.float(3.0, TITLE_MULT_B3, group=GRP_3, minval=0.1, step=0.5, inline="b3")
bool in_ct_filter = input.bool(true, TITLE_FILT_CTR, group=GRP_3)

int in_mat_rows = input.int(10, TITLE_MAT_ROWS, group=GRP_4, minval=1, maxval=100)
float in_box_h_mult = input.float(0.1, TITLE_BOX_H_MULT, group=GRP_4, minval=0.01, maxval=10, step=0.01)
int in_hl_w = input.int(15, TITLE_HL_W, group=GRP_4, minval=2, maxval=100, inline="hl_box")
float in_hl_h = input.float(15.0, TITLE_HL_H, group=GRP_4, minval=1.0, maxval=50, step=0.5, inline="hl_box")
int in_max_boxes = input.int(250, TITLE_MAX_BOX, group=GRP_4, minval=50, maxval=500)

string in_theme = input.string(OPT_NEON, TITLE_THEME, options=[OPT_NEON, OPT_MONO, OPT_OCEAN, OPT_TOXIC, OPT_CLASSIC], group=GRP_5, tooltip=TT_THEME)
float in_txt_scl = input.float(0.1, TITLE_TXT_SCL, group=GRP_5, minval=-2.0, maxval=5.0, step=0.1)
bool in_show_nrsi = input.bool(false, TITLE_SHOW_NRSI, group=GRP_5)
float in_ob_lvl = input.float(80.0, TITLE_OB_LVL, group=GRP_5, inline="txt_hl_thresh")
float in_os_lvl = input.float(20.0, TITLE_OS_LVL, group=GRP_5, inline="txt_hl_thresh")
bool in_show_hl = input.bool(true, TITLE_SHOW_HL, group=GRP_5)
float in_vol_m_thr = input.float(20.0, TITLE_VOL_M_THR, group=GRP_5, inline="vol_m")
bool in_vol_m_shw = input.bool(true, TITLE_VOL_M_SHW, group=GRP_5, inline="vol_m")
color in_vol_m_col = input.color(color.orange, TITLE_VOL_M_COL, group=GRP_5, inline="vol_m")
float in_vol_h_thr = input.float(40.0, TITLE_VOL_H_THR, group=GRP_5, inline="vol_h")
bool in_vol_h_shw = input.bool(true, TITLE_VOL_H_SHW, group=GRP_5, inline="vol_h")
color in_vol_h_col = input.color(#ff0000, TITLE_VOL_H_COL, group=GRP_5, inline="vol_h")

string in_rndr_mode = input.string(OPT_RNDR_HIST, TITLE_RNDR_MODE, options=[OPT_RNDR_RT, OPT_RNDR_HIST], group=GRP_6)
int in_hist_lim = input.int(3000, TITLE_HIST_LIM, group=GRP_6, minval=100, maxval=4900)
string in_layout = input.string(OPT_LAY_ALL, TITLE_DATA_LAY, options=[OPT_LAY_ALL, OPT_LAY_PV, OPT_LAY_PC, OPT_LAY_PVC, OPT_LAY_RSI], group=GRP_6)
bool in_live_upd = input.bool(true, TITLE_LIVE_UPD, group=GRP_6)
//~~~~~}

// ~~ Helpers {
f_calc_rsi(float src, int len) =>
    float change = ta.change(src)
    float up = ta.rma(math.max(change, 0), len)
    float down = ta.rma(-math.min(change, 0), len)
    down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))

f_format_vol(float v) =>
    str.tostring(v / 1000, "#.#") + "K"

f_get_text_size(float h_mult, float s_adj) =>
    float cs = (h_mult * 10) + s_adj
    string ds = size.auto 
    if cs < 1.0
        ds := size.tiny
    else if cs >= 1.0 and cs < 2.0
        ds := size.small
    else if cs >= 2.0 and cs < 3.0
        ds := size.normal
    else if cs >= 3.0 and cs < 4.0
        ds := size.large
    else
        ds := size.huge
    ds

f_render_stack(float[] ltf_rsi, int[] ltf_cross, float[] ltf_close, float[] ltf_vol, float[] ltf_cvd, float bar_h, float bar_l, int b_idx, float bar_atr, float bar_vol, float vwap_val, color[] tc, color c4, color c5, color c6, color c7) =>
    box[] new_boxes = array.new_box()
    if not na(ltf_rsi) and array.size(ltf_rsi) > 0
        float base_h = bar_atr * in_box_h_mult
        float l_mult = in_layout == OPT_LAY_ALL ? 2.5 : (in_layout == OPT_LAY_RSI ? 1.0 : 1.5)
        float t_y = bar_h + (base_h * l_mult)
        float b_y = bar_l - (base_h * l_mult)
        
        color curr_c = na
        bool curr_ia = false, bool curr_is = false, bool curr_ib = false
        int b_size = 0
        float b_rsi_sum = 0.0, float b_price_sum = 0.0, float b_vol_sum = 0.0, float b_cvd_sum = 0.0
        bool is_first = true
        
        for i = 0 to array.size(ltf_rsi) - 1
            if array.get(ltf_cross, i) == 0
                continue 
                
            float rv = array.get(ltf_rsi, i), float cv = array.get(ltf_close, i)
            float vv = na(ltf_vol) ? 0.0 : array.get(ltf_vol, i)
            float dv = na(ltf_cvd) ? 0.0 : array.get(ltf_cvd, i)
            
            int li = math.max(0, math.min(9, int(math.floor(rv / 10.0))))
            bool is_hidden = rv >= in_hide_min and rv <= in_hide_max
            bool is_sell = rv >= in_ob_lvl, bool is_buy = rv <= in_os_lvl
            color c_col = is_hidden ? na : array.get(tc, li)
            bool is_above = rv > in_rsi_base
            
            if is_first
                curr_c := c_col, curr_ia := is_above, curr_is := is_sell, curr_ib := is_buy
                b_size := 1, b_rsi_sum := rv, b_price_sum := cv, b_vol_sum := vv, b_cvd_sum := dv
                is_first := false
            else
                if (na(c_col) and na(curr_c)) or (c_col == curr_c and is_above == curr_ia)
                    b_size += 1, b_rsi_sum += rv, b_price_sum += cv, b_vol_sum += vv, b_cvd_sum += dv
                else
                    if not na(curr_c)
                        bool is_hl = curr_is or curr_ib
                        float adj_h = is_hl ? (base_h * l_mult * in_hl_h) : (base_h * l_mult)
                        float tot_h = b_size * adj_h
                        float box_t = na, float box_b = na
                        if curr_ia
                            box_b := t_y, box_t := t_y + tot_h, t_y := box_t
                        else
                            box_t := b_y, box_b := b_y - tot_h, b_y := box_b
                            
                        float v_ratio = bar_vol > 0 ? (b_vol_sum / bar_vol) * 100 : 0
                        bool is_high_v = v_ratio >= in_vol_h_thr
                        bool is_mid_v = v_ratio >= in_vol_m_thr and not is_high_v
                        bool draw_str = is_high_v ? in_vol_h_shw : (is_mid_v ? in_vol_m_shw : (is_hl ? in_show_hl : in_show_nrsi))
                        string fsz = f_get_text_size(in_box_h_mult, in_txt_scl)
                        
                        color box_bc = curr_c
                        int transp = 75 
                        if is_hl
                            box_bc := curr_is ? c5 : c4, transp := 15 
                        float avg_p = b_price_sum / b_size
                        
                        if in_ct_filter
                            if (avg_p > vwap_val and curr_is) or (avg_p < vwap_val and curr_ib)
                                transp := 90
                                
                        color font_c = is_high_v ? in_vol_h_col : (is_mid_v ? in_vol_m_col : (is_hl ? c7 : c6))
                        string box_txt = ""
                        
                        if draw_str
                            box_txt := "RSI:" + str.tostring(math.round(b_rsi_sum / b_size))
                            string p_str = "P:" + str.tostring(avg_p, format.mintick)
                            string v_str = "V:" + f_format_vol(b_vol_sum)
                            string d_str = "C:" + f_format_vol(b_cvd_sum)
                            
                            if in_layout == OPT_LAY_ALL
                                box_txt += "\n" + p_str + "\n" + v_str + "\n" + d_str
                            else if in_layout == OPT_LAY_PV
                                box_txt += "\n" + p_str + " [" + v_str + "]"
                            else if in_layout == OPT_LAY_PC
                                box_txt += "\n" + p_str + " [" + d_str + "]"
                            else if in_layout == OPT_LAY_PVC
                                box_txt += "\n" + p_str + " [" + v_str + " | " + d_str + "]"
                                
                        int b_left = is_hl ? b_idx - in_hl_w : b_idx - 1
                        array.push(new_boxes, box.new(left=b_left, top=box_t, right=b_idx, bottom=box_b, border_color=color.new(box_bc, transp == 90 ? 70 : 10), bgcolor=color.new(box_bc, transp), text=box_txt, text_color=transp == 90 ? color.new(font_c, 70) : font_c, text_size=fsz, text_halign=text.align_center, text_valign=text.align_center))
                        
                    curr_c := c_col, curr_ia := is_above, curr_is := is_sell, curr_ib := is_buy
                    b_size := 1, b_rsi_sum := rv, b_price_sum := cv, b_vol_sum := vv, b_cvd_sum := dv
                    
        if not na(curr_c) and b_size > 0
            bool is_hl = curr_is or curr_ib
            float adj_h = is_hl ? (base_h * l_mult * in_hl_h) : (base_h * l_mult)
            float tot_h = b_size * adj_h
            float box_t = na, float box_b = na
            if curr_ia
                box_b := t_y, box_t := t_y + tot_h, t_y := box_t
            else
                box_t := b_y, box_b := b_y - tot_h, b_y := box_b
                
            float v_ratio = bar_vol > 0 ? (b_vol_sum / bar_vol) * 100 : 0
            bool is_high_v = v_ratio >= in_vol_h_thr
            bool is_mid_v = v_ratio >= in_vol_m_thr and not is_high_v
            bool draw_str = is_high_v ? in_vol_h_shw : (is_mid_v ? in_vol_m_shw : (is_hl ? in_show_hl : in_show_nrsi))
            string fsz = f_get_text_size(in_box_h_mult, in_txt_scl)
            
            color box_bc = curr_c
            int transp = 75
            if is_hl
                box_bc := curr_is ? c5 : c4, transp := 15
            float avg_p = b_price_sum / b_size
            
            if in_ct_filter
                if (avg_p > vwap_val and curr_is) or (avg_p < vwap_val and curr_ib)
                    transp := 90
                    
            color font_c = is_high_v ? in_vol_h_col : (is_mid_v ? in_vol_m_col : (is_hl ? c7 : c6))
            string box_txt = ""
            
            if draw_str
                box_txt := "RSI:" + str.tostring(math.round(b_rsi_sum / b_size))
                string p_str = "P:" + str.tostring(avg_p, format.mintick)
                string v_str = "V:" + f_format_vol(b_vol_sum)
                string d_str = "C:" + f_format_vol(b_cvd_sum)
                
                if in_layout == OPT_LAY_ALL
                    box_txt += "\n" + p_str + "\n" + v_str + "\n" + d_str
                else if in_layout == OPT_LAY_PV
                    box_txt += "\n" + p_str + " [" + v_str + "]"
                else if in_layout == OPT_LAY_PC
                    box_txt += "\n" + p_str + " [" + d_str + "]"
                else if in_layout == OPT_LAY_PVC
                    box_txt += "\n" + p_str + " [" + v_str + " | " + d_str + "]"
                    
            int b_left = is_hl ? b_idx - in_hl_w : b_idx - 1
            array.push(new_boxes, box.new(left=b_left, top=box_t, right=b_idx, bottom=box_b, border_color=color.new(box_bc, transp == 90 ? 70 : 10), bgcolor=color.new(box_bc, transp), text=box_txt, text_color=transp == 90 ? color.new(font_c, 70) : font_c, text_size=fsz, text_halign=text.align_center, text_valign=text.align_center))
    new_boxes

f_render_matrix(float[] ltf_rsi, int[] ltf_cross, float[] ltf_close, float[] ltf_vol, float[] ltf_cvd, float bar_h, float bar_l, int b_idx, float bar_vol, float vwap_val, color[] tc, color c4, color c5, color c6, color c7) =>
    box[] new_boxes = array.new_box()
    if not na(ltf_rsi) and array.size(ltf_rsi) > 0
        float step = bar_h > bar_l ? (bar_h - bar_l) / in_mat_rows : syminfo.mintick
        float[] arr_rsi = array.new_float(in_mat_rows, 0.0)
        float[] arr_price = array.new_float(in_mat_rows, 0.0)
        float[] arr_vol = array.new_float(in_mat_rows, 0.0)
        float[] arr_cvd = array.new_float(in_mat_rows, 0.0)
        int[] arr_count = array.new_int(in_mat_rows, 0)
        
        for i = 0 to array.size(ltf_rsi) - 1
            if array.get(ltf_cross, i) == 0
                continue 
            float rv = array.get(ltf_rsi, i), float cv = array.get(ltf_close, i)
            float vv = na(ltf_vol) ? 0.0 : array.get(ltf_vol, i), float dv = na(ltf_cvd) ? 0.0 : array.get(ltf_cvd, i)
            int row = math.floor((cv - bar_l) / step)
            row := math.max(0, math.min(in_mat_rows - 1, row))
            array.set(arr_rsi, row, array.get(arr_rsi, row) + rv)
            array.set(arr_price, row, array.get(arr_price, row) + cv)
            array.set(arr_vol, row, array.get(arr_vol, row) + vv)
            array.set(arr_cvd, row, array.get(arr_cvd, row) + dv)
            array.set(arr_count, row, array.get(arr_count, row) + 1)
            
        for r = 0 to in_mat_rows - 1
            int cnt = array.get(arr_count, r)
            if cnt > 0
                float avg_r = array.get(arr_rsi, r) / cnt
                int li = math.max(0, math.min(9, int(math.floor(avg_r / 10.0))))
                bool is_hidden = avg_r >= in_hide_min and avg_r <= in_hide_max
                bool is_sell = avg_r >= in_ob_lvl, bool is_buy = avg_r <= in_os_lvl
                bool is_hl = is_sell or is_buy
                color c_col = is_hidden ? na : array.get(tc, li)
                
                if not na(c_col)
                    float box_t = bar_l + ((r + 1) * step), float box_b = bar_l + (r * step)
                    int b_left = b_idx, int b_right = is_hl ? b_idx + in_hl_w : b_idx + 1
                    float tot_v = array.get(arr_vol, r), float tot_d = array.get(arr_cvd, r)
                    float v_ratio = bar_vol > 0 ? (tot_v / bar_vol) * 100 : 0
                    
                    bool is_high_v = v_ratio >= in_vol_h_thr
                    bool is_mid_v = v_ratio >= in_vol_m_thr and not is_high_v
                    bool draw_str = is_high_v ? in_vol_h_shw : (is_mid_v ? in_vol_m_shw : (is_hl ? in_show_hl : in_show_nrsi))
                    string fsz = f_get_text_size(in_box_h_mult, in_txt_scl)
                    
                    color box_bc = c_col
                    int transp = 75
                    if is_hl
                        box_bc := is_sell ? c5 : c4, transp := 15
                    float avg_p = array.get(arr_price, r) / cnt
                    
                    if in_ct_filter
                        if (avg_p > vwap_val and is_sell) or (avg_p < vwap_val and is_buy)
                            transp := 90
                            
                    color font_c = is_high_v ? in_vol_h_col : (is_mid_v ? in_vol_m_col : (is_hl ? c7 : c6))
                    string box_txt = ""
                    
                    if draw_str
                        box_txt := "RSI:" + str.tostring(math.round(avg_r))
                        string p_str = "P:" + str.tostring(avg_p, format.mintick)
                        string v_str = "V:" + f_format_vol(tot_v)
                        string d_str = "C:" + f_format_vol(tot_d)
                        
                        if in_layout == OPT_LAY_ALL
                            box_txt += "\n" + p_str + "\n" + v_str + "\n" + d_str
                        else if in_layout == OPT_LAY_PV
                            box_txt += "\n" + p_str + " [" + v_str + "]"
                        else if in_layout == OPT_LAY_PC
                            box_txt += "\n" + p_str + " [" + d_str + "]"
                        else if in_layout == OPT_LAY_PVC
                            box_txt += "\n" + p_str + " [" + v_str + " | " + d_str + "]"
                            
                    array.push(new_boxes, box.new(left=b_left, top=box_t, right=b_right, bottom=box_b, border_color=color.new(box_bc, transp == 90 ? 70 : 10), bgcolor=color.new(box_bc, transp), text=box_txt, text_color=transp == 90 ? color.new(font_c, 70) : font_c, text_size=fsz, text_halign=text.align_center, text_valign=text.align_center))
    new_boxes
//~~~~~}

// ~~ Calculation & Drawing {
[ltf_rsi, ltf_cross, ltf_close, ltf_vol, ltf_cvd] = request.security_lower_tf(syminfo.tickerid, in_ltf, [f_calc_rsi(in_rsi_src, in_rsi_len), (f_calc_rsi(in_rsi_src, in_fast_len) > f_calc_rsi(in_rsi_src, in_slow_len) and f_calc_rsi(in_rsi_src, in_fast_len)[1] <= f_calc_rsi(in_rsi_src, in_slow_len)[1]) ? 1 : (f_calc_rsi(in_rsi_src, in_fast_len) < f_calc_rsi(in_rsi_src, in_slow_len) and f_calc_rsi(in_rsi_src, in_fast_len)[1] >= f_calc_rsi(in_rsi_src, in_slow_len)[1]) ? -1 : 0, close, volume, math.sign(close - open) * volume])
float bar_atr = ta.atr(in_atr_len)

var color[] theme_colors = array.new<color>(10)
var color c4 = na, var color c5 = na, var color c6 = na, var color c7 = na
var color vwap_c0 = na, var color vwap_c1 = na, var color vwap_c2 = na, var color vwap_c3 = na

if barstate.isfirst
    if in_theme == OPT_NEON
        theme_colors := array.from(color.rgb(0, 77, 64), color.rgb(0, 105, 92), color.rgb(0, 137, 123), color.rgb(38, 166, 154), color.rgb(77, 182, 172), color.rgb(128, 203, 196), color.rgb(38, 198, 218), color.rgb(0, 188, 212), color.rgb(0, 151, 167), color.rgb(0, 96, 100))
        c4 := #00E676, c5 := #FF1744, c6 := color.white, c7 := color.black
        vwap_c0 := #00e5ff, vwap_c1 := #00e5ff, vwap_c2 := #d500f9, vwap_c3 := #ff1744
    else if in_theme == OPT_MONO
        theme_colors := array.from(color.rgb(30, 30, 30), color.rgb(50, 50, 50), color.rgb(70, 70, 70), color.rgb(90, 90, 90), color.rgb(110, 110, 110), color.rgb(130, 130, 130), color.rgb(150, 150, 150), color.rgb(170, 170, 170), color.rgb(190, 190, 190), color.rgb(210, 210, 210))
        c4 := color.white, c5 := color.white, c6 := color.gray, c7 := color.black
        vwap_c0 := color.white, vwap_c1 := color.gray, vwap_c2 := color.gray, vwap_c3 := color.gray
    else if in_theme == OPT_OCEAN
        theme_colors := array.from(#0d47a1, #1565c0, #1976d2, #1e88e5, #2196f3, #42a5f5, #64b5f6, #90caf9, #bbdefb, #e3f2fd)
        c4 := #00bfa5, c5 := #ff5252, c6 := color.white, c7 := color.white
        vwap_c0 := #18ffff, vwap_c1 := #18ffff, vwap_c2 := #00e676, vwap_c3 := #ffeb3b
    else if in_theme == OPT_TOXIC
        theme_colors := array.from(#1b5e20, #2e7d32, #388e3c, #4caf50, #66bb6a, #81c784, #a5d6a7, #c8e6c9, #e8f5e9, #f1f8e9)
        c4 := #64dd17, c5 := #aa00ff, c6 := color.white, c7 := color.black
        vwap_c0 := #76ff03, vwap_c1 := #76ff03, vwap_c2 := #d500f9, vwap_c3 := #ff1744
    else if in_theme == OPT_CLASSIC
        theme_colors := array.from(color.navy, color.teal, color.green, color.lime, color.olive, color.yellow, color.fuchsia, color.orange, color.red, color.maroon)
        c4 := #00ff00, c5 := color.red, c6 := color.black, c7 := color.white
        vwap_c0 := color.blue, vwap_c1 := color.blue, vwap_c2 := color.orange, vwap_c3 := color.red

bool is_new_anchor = switch in_anchor
    OPT_EARN => not na(request.earnings(syminfo.tickerid, earnings.actual, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)) or not na(request.earnings(syminfo.tickerid, earnings.standardized, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true))
    OPT_DIV => not na(request.dividends(syminfo.tickerid, dividends.gross, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true))
    OPT_SPLIT => not na(request.splits(syminfo.tickerid, splits.denominator, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true))
    OPT_SESS => timeframe.change("D")
    OPT_WEEK => timeframe.change("W")
    OPT_MNTH => timeframe.change("M")
    OPT_QTR => timeframe.change("3M")
    OPT_YEAR => timeframe.change("12M")
    OPT_DEC => timeframe.change("12M") and year % 10 == 0
    OPT_CENT => timeframe.change("12M") and year % 100 == 0
    => false

bool is_special_anchor = in_anchor == OPT_EARN or in_anchor == OPT_DIV or in_anchor == OPT_SPLIT
if na(hlc3[1]) and not is_special_anchor
    is_new_anchor := true

[vwap_val, sum_vol, _] = ta.vwap(hlc3, is_new_anchor, 1)
float stdev_val = sum_vol - vwap_val
float band_base = in_band_mode == OPT_STDEV ? stdev_val : vwap_val * 0.01

float v1_u = vwap_val + band_base * in_mult_b1, float v1_l = vwap_val - band_base * in_mult_b1
float v2_u = vwap_val + band_base * in_mult_b2, float v2_l = vwap_val - band_base * in_mult_b2
float v3_u = vwap_val + band_base * in_mult_b3, float v3_l = vwap_val - band_base * in_mult_b3

plot_vwap = plot(in_show_vwap ? vwap_val : na, title="VWAP", color=vwap_c0, linewidth=2)

float du1 = v1_u - vwap_val
plot_u1_25 = plot(in_show_b1 ? vwap_val + du1 * 0.25 : na, display=display.none)
plot_u1_50 = plot(in_show_b1 ? vwap_val + du1 * 0.50 : na, display=display.none)
plot_u1_75 = plot(in_show_b1 ? vwap_val + du1 * 0.75 : na, display=display.none)
plot_u1_100 = plot(in_show_b1 ? v1_u : na, title="V1U", color=color.new(vwap_c1, 30), linewidth=1)

float dl1 = vwap_val - v1_l
plot_l1_25 = plot(in_show_b1 ? vwap_val - dl1 * 0.25 : na, display=display.none)
plot_l1_50 = plot(in_show_b1 ? vwap_val - dl1 * 0.50 : na, display=display.none)
plot_l1_75 = plot(in_show_b1 ? vwap_val - dl1 * 0.75 : na, display=display.none)
plot_l1_100 = plot(in_show_b1 ? v1_l : na, title="V1L", color=color.new(vwap_c1, 30), linewidth=1)

fill(plot_vwap, plot_u1_25, color=in_show_b1 ? color.new(vwap_c1, 95) : na)
fill(plot_u1_25, plot_u1_50, color=in_show_b1 ? color.new(vwap_c1, 90) : na)
fill(plot_u1_50, plot_u1_75, color=in_show_b1 ? color.new(vwap_c1, 85) : na)
fill(plot_u1_75, plot_u1_100, color=in_show_b1 ? color.new(vwap_c1, 75) : na)

fill(plot_vwap, plot_l1_25, color=in_show_b1 ? color.new(vwap_c1, 95) : na)
fill(plot_l1_25, plot_l1_50, color=in_show_b1 ? color.new(vwap_c1, 90) : na)
fill(plot_l1_50, plot_l1_75, color=in_show_b1 ? color.new(vwap_c1, 85) : na)
fill(plot_l1_75, plot_l1_100, color=in_show_b1 ? color.new(vwap_c1, 75) : na)

float du2 = v2_u - v1_u
plot_u2_25 = plot(in_show_b2 ? v1_u + du2 * 0.25 : na, display=display.none)
plot_u2_50 = plot(in_show_b2 ? v1_u + du2 * 0.50 : na, display=display.none)
plot_u2_75 = plot(in_show_b2 ? v1_u + du2 * 0.75 : na, display=display.none)
plot_u2_100 = plot(in_show_b2 ? v2_u : na, title="V2U", color=color.new(vwap_c2, 30), linewidth=1)

float dl2 = v1_l - v2_l
plot_l2_25 = plot(in_show_b2 ? v1_l - dl2 * 0.25 : na, display=display.none)
plot_l2_50 = plot(in_show_b2 ? v1_l - dl2 * 0.50 : na, display=display.none)
plot_l2_75 = plot(in_show_b2 ? v1_l - dl2 * 0.75 : na, display=display.none)
plot_l2_100 = plot(in_show_b2 ? v2_l : na, title="V2L", color=color.new(vwap_c2, 30), linewidth=1)

fill(plot_u1_100, plot_u2_25, color=in_show_b2 ? color.new(vwap_c2, 95) : na)
fill(plot_u2_25, plot_u2_50, color=in_show_b2 ? color.new(vwap_c2, 90) : na)
fill(plot_u2_50, plot_u2_75, color=in_show_b2 ? color.new(vwap_c2, 85) : na)
fill(plot_u2_75, plot_u2_100, color=in_show_b2 ? color.new(vwap_c2, 75) : na)

fill(plot_l1_100, plot_l2_25, color=in_show_b2 ? color.new(vwap_c2, 95) : na)
fill(plot_l2_25, plot_l2_50, color=in_show_b2 ? color.new(vwap_c2, 90) : na)
fill(plot_l2_50, plot_l2_75, color=in_show_b2 ? color.new(vwap_c2, 85) : na)
fill(plot_l2_75, plot_l2_100, color=in_show_b2 ? color.new(vwap_c2, 75) : na)

float du3 = v3_u - v2_u
plot_u3_25 = plot(in_show_b3 ? v2_u + du3 * 0.25 : na, display=display.none)
plot_u3_50 = plot(in_show_b3 ? v2_u + du3 * 0.50 : na, display=display.none)
plot_u3_75 = plot(in_show_b3 ? v2_u + du3 * 0.75 : na, display=display.none)
plot_u3_100 = plot(in_show_b3 ? v3_u : na, title="V3U", color=color.new(vwap_c3, 30), linewidth=1)

float dl3 = v2_l - v3_l
plot_l3_25 = plot(in_show_b3 ? v2_l - dl3 * 0.25 : na, display=display.none)
plot_l3_50 = plot(in_show_b3 ? v2_l - dl3 * 0.50 : na, display=display.none)
plot_l3_75 = plot(in_show_b3 ? v2_l - dl3 * 0.75 : na, display=display.none)
plot_l3_100 = plot(in_show_b3 ? v3_l : na, title="V3L", color=color.new(vwap_c3, 30), linewidth=1)

fill(plot_u2_100, plot_u3_25, color=in_show_b3 ? color.new(vwap_c3, 95) : na)
fill(plot_u3_25, plot_u3_50, color=in_show_b3 ? color.new(vwap_c3, 90) : na)
fill(plot_u3_50, plot_u3_75, color=in_show_b3 ? color.new(vwap_c3, 85) : na)
fill(plot_u3_75, plot_u3_100, color=in_show_b3 ? color.new(vwap_c3, 75) : na)

fill(plot_l2_100, plot_l3_25, color=in_show_b3 ? color.new(vwap_c3, 95) : na)
fill(plot_l3_25, plot_l3_50, color=in_show_b3 ? color.new(vwap_c3, 90) : na)
fill(plot_l3_50, plot_l3_75, color=in_show_b3 ? color.new(vwap_c3, 85) : na)
fill(plot_l3_75, plot_l3_100, color=in_show_b3 ? color.new(vwap_c3, 75) : na)


var box[] drawn_boxes = array.new_box()
var box[] live_boxes = array.new_box()

if in_rndr_mode == OPT_RNDR_HIST
    bool do_update = barstate.islast ? (barstate.isrealtime ? (in_live_upd ? true : barstate.isconfirmed) : true) : false
    if do_update
        while array.size(drawn_boxes) > 0
            box.delete(array.shift(drawn_boxes))
            
        int total_rendered = 0
        int left_t = chart.left_visible_bar_time
        int right_t = chart.right_visible_bar_time
        
        for offset = 0 to in_hist_lim
            if total_rendered >= in_max_boxes or time[offset] < left_t
                break
            if time[offset] > right_t
                continue
                
            box[] new_boxes = array.new_box()
            if in_mode == OPT_STACK
                new_boxes := f_render_stack(ltf_rsi[offset], ltf_cross[offset], ltf_close[offset], ltf_vol[offset], ltf_cvd[offset], high[offset], low[offset], bar_index[offset], bar_atr[offset], volume[offset], vwap_val[offset], theme_colors, c4, c5, c6, c7)
            else
                new_boxes := f_render_matrix(ltf_rsi[offset], ltf_cross[offset], ltf_close[offset], ltf_vol[offset], ltf_cvd[offset], high[offset], low[offset], bar_index[offset], volume[offset], vwap_val[offset], theme_colors, c4, c5, c6, c7)
                
            for b in new_boxes
                array.push(drawn_boxes, b)
                total_rendered += 1
                if total_rendered >= in_max_boxes
                    break
else
    if barstate.isnew
        array.clear(live_boxes)

    bool do_realtime = in_live_upd and barstate.isrealtime and not barstate.isconfirmed
    if do_realtime
        while array.size(live_boxes) > 0
            box.delete(array.shift(live_boxes))
            
        if in_mode == OPT_STACK
            live_boxes := f_render_stack(ltf_rsi, ltf_cross, ltf_close, ltf_vol, ltf_cvd, high, low, bar_index, bar_atr, volume, vwap_val, theme_colors, c4, c5, c6, c7)
        else
            live_boxes := f_render_matrix(ltf_rsi, ltf_cross, ltf_close, ltf_vol, ltf_cvd, high, low, bar_index, volume, vwap_val, theme_colors, c4, c5, c6, c7)
            
    else if barstate.ishistory or barstate.isconfirmed
        box[] new_boxes = array.new_box()
        if in_mode == OPT_STACK
            new_boxes := f_render_stack(ltf_rsi, ltf_cross, ltf_close, ltf_vol, ltf_cvd, high, low, bar_index, bar_atr, volume, vwap_val, theme_colors, c4, c5, c6, c7)
        else
            new_boxes := f_render_matrix(ltf_rsi, ltf_cross, ltf_close, ltf_vol, ltf_cvd, high, low, bar_index, volume, vwap_val, theme_colors, c4, c5, c6, c7)
            
        for b in new_boxes
            array.push(drawn_boxes, b)
            
        while array.size(drawn_boxes) > in_max_boxes
            box.delete(array.shift(drawn_boxes))
//~~~~~}
````
