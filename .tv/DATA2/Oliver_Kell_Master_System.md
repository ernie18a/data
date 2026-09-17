<!-- tradingview-pine-id: PUB;60738340cd0a43219377f947829b0952 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Oliver Kell - Master System

Source: https://www.tradingview.com/script/SmNMRIra-Oliver-Kell-Master-System/

## Description

When tracking thematic sector performance and hunting for the next big cycle, keeping your charts clean is critical. Price action translates the language of stocks into clear market principles, and the goal is to read it without unnecessary clutter. Influenced by the approach of Oliver Kell, this indicator is built to visualize the core structural elements of the Cycle of Price Action.  

This script handles the main price chart and adapts automatically based on the timeframe you are viewing to help identify bases, flat bases, and structural breakouts.

Key Features

Macro Trend Tracking (Daily / Weekly / Monthly): Plots the core group of moving averages (5, 10, 20 EMA, and 20, 50, 200 SMA) to help gauge the health of a trend and identify phases like Reversal Extensions, Wedge Pops, and Wedge Drops.  

Intraday Execution (65m / 30m / 5m): Automatically pulls in the true daily moving averages via background requests, alongside the local timeframe's 20 EMA, VWAP, and standard daily Pivot Points (P, R1, S1, R2, S2) for tactical precision.  

Aesthetic Toggle: Features a built-in theme toggle to match the light layout of Victory in Stock Trading or the dark layout of The Swing Report.

Whether you are positioning for a long-term swing or looking for an intraday Technical Buy Area, this tool provides the structural framework. Remember, only price pays. Let the price action dictate your decisions.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © chardogg74

//@version=6
indicator("Oliver Kell - Master System", shorttitle="OK_Master", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// =====================================================================
// 1. INPUTS & THEME CONFIGURATION
// =====================================================================
grp_theme    = "Theme & Aesthetics"
theme_mode   = input.string("Victory Book (Light)", "Color Theme", options=["Victory Book (Light)", "Swing Report (Dark)"], group=grp_theme)
grid_interval= input.int(10, "Vertical Grid Interval (Bars) [Dark Mode]", minval=1, group=grp_theme, tooltip="Creates perfectly evenly spaced background lines.")
show_legend  = input.bool(true, "Show Chart Key / Legend", group=grp_theme)
leg_pos      = input.string("Bottom Right", "Legend Position", options=["Top Right", "Bottom Right", "Bottom Left", "Top Left"], group=grp_theme)

bool is_dark = theme_mode == "Swing Report (Dark)"
color green_ink = is_dark ? color.rgb(0, 230, 118) : color.rgb(0, 130, 60)
color red_ink   = is_dark ? color.rgb(255, 23, 68)  : color.rgb(200, 30, 30)

color body_fill = close >= open ? (is_dark ? color.new(green_ink, 100) : green_ink) : red_ink
color candle_border = close >= open ? green_ink : red_ink
color candle_wick   = candle_border

bgcolor(is_dark ? color.rgb(19, 23, 34) : color.rgb(255, 255, 255), title="Chart Background")
plotcandle(open, high, low, close, title="Candlesticks", color=body_fill, wickcolor=candle_wick, bordercolor=candle_border)

color col_ema5   = is_dark ? color.rgb(0, 229, 255)   : color.rgb(0, 180, 200)
color col_ema10  = is_dark ? color.rgb(255, 23, 68)    : color.rgb(200, 0, 0)
color col_ema20  = is_dark ? color.rgb(41, 98, 255)    : color.rgb(0, 0, 200)
color col_sma50  = is_dark ? color.rgb(0, 230, 118)    : color.rgb(0, 150, 0)
color txt_color  = is_dark ? color.rgb(240, 240, 240)  : color.rgb(0, 0, 0)
color base_col   = is_dark ? color.rgb(255, 255, 255)  : color.rgb(0, 0, 0)

grp_ma     = "Moving Averages"
ma_wid     = input.int(1, "MA Line Width", minval=1, maxval=4, group=grp_ma)
show_ema5  = input.bool(false, "5 EMA (Teal)", group=grp_ma)
show_ema10 = input.bool(true, "10 EMA (Red)", group=grp_ma)
show_ema20 = input.bool(true, "20 EMA (Blue)", group=grp_ma)
show_sma50 = input.bool(true, "50 SMA (Green)", group=grp_ma)

grp_ext      = "MA Extensions (ATR Based)"
show_ext     = input.bool(true, "Show Extension Signals (E, R)", group=grp_ext)
ext_src      = input.string("10 EMA", "Extension Baseline", options=["10 EMA", "20 EMA", "50 SMA"], group=grp_ext)
ext_atr_mult = input.float(1.0, "ATR Multiplier Threshold", step=0.5, group=grp_ext)

grp_intraday  = "Intraday & Dark Mode Settings (Swing Report)"
show_pivots   = input.bool(true, "Show Daily Pivot Levels (R1/S1)", group=grp_intraday)
show_htf_emas = input.bool(true, "Show True Daily 10/20 EMAs on Intraday", group=grp_intraday)
show_vwap     = input.bool(true, "Show VWAP", group=grp_intraday)

grp_tl      = "Trendlines & Breakouts"
show_tls    = input.bool(true, "Draw Clean Swing Trendlines", group=grp_tl)

grp_base          = "Structure & Base Recognition"
show_bases        = input.bool(true, "Display Pattern Lines", group=grp_base)
base_wid          = input.int(1, "Pattern Line Width", minval=1, maxval=3, group=grp_base)
b_style_in        = input.string("Solid", "Pattern Line Style", options=["Solid", "Dotted", "Dashed"], group=grp_base)

max_base_depth    = input.float(65.0, "Max Consolidation Depth (%)", step=1.0, group=grp_base)
min_base_length   = input.int(10, "Min Consolidation Length (Bars)", minval=5, group=grp_base)
prior_trend_min   = input.float(10.0, "Prior Trend Expansion Requirement (%)", step=1.0, group=grp_base)

grp_gaps             = "Unfilled Gaps"
show_gaps            = input.bool(true, "Show Unfilled Gaps", group=grp_gaps)
minGapSize           = input.float(0.5, "Minimum Gap Size ($)", minval=0.01, group=grp_gaps)
showPartiallyFilled  = input.bool(true, "Show Partially Filled Gaps", group=grp_gaps)

color gapColor       = is_dark ? color.new(color.rgb(210, 210, 210), 92) : color.new(color.rgb(160, 160, 160), 92)
color transparent_brd = color.new(color.white, 100)

grp_toggles = "Signal Toggles"
show_cpa    = input.bool(true, "Show CPA Wedge Pops/Drops (P, D)", group=grp_toggles)
show_tricks = input.bool(true, "Show Little Tricks (I, K, O, 2)", group=grp_toggles)
show_swing  = input.bool(true, "Show Swing Report Signals (V, H, U)", group=grp_toggles)

// =====================================================================
// 2. INTERNAL CONVERSIONS & ROOT CALCULATIONS
// =====================================================================
var string b_style = b_style_in == "Solid" ? line.style_solid : b_style_in == "Dotted" ? line.style_dotted : line.style_dashed

e5  = ta.ema(close, 5)
e10 = ta.ema(close, 10)
e20 = ta.ema(close, 20)
s50 = ta.sma(close, 50)

prev_open  = open[1]
prev_high  = high[1]
prev_low   = low[1]
prev_close = close[1]

bar_range  = high - low
prev_range = prev_high - prev_low
body_size  = math.abs(close - open)
atr        = ta.atr(10)
atr_14     = ta.atr(14)
vol_sma    = ta.sma(volume, 20)
close_pos  = bar_range > 0 ? (close - low) / bar_range : 0.5
lowest_10_prev = ta.lowest(low, 10)[1]

// =====================================================================
// 3. CYCLE OF PRICE ACTION (CPA) & EXTENSIONS (ATR + MTF FILTERS)
// =====================================================================
float active_ext_ma = ext_src == "10 EMA" ? e10 : ext_src == "20 EMA" ? e20 : s50
float ext_threshold = atr_14 * ext_atr_mult
float w_ema10       = request.security(syminfo.tickerid, "W", ta.ema(close, 10))

bool has_air        = low > active_ext_ma
bool rev_has_air    = high < active_ext_ma
bool high_vol       = volume > vol_sma
bool mtf_up         = close > w_ema10
bool mtf_down       = close < w_ema10

// Filtered Exhaustion & Reversal Logic
bool is_exh = show_ext and (close > active_ext_ma) and ((close - active_ext_ma) >= ext_threshold) and (close_pos <= 0.40) and has_air and high_vol and mtf_up
bool is_rev = show_ext and (close < active_ext_ma) and ((active_ext_ma - close) >= ext_threshold) and (close_pos >= 0.60) and rev_has_air and high_vol and mtf_down

int bars_below_10 = 0
for i = 1 to 4
    if close[i] < e10[i]
        bars_below_10 += 1

bool came_from_pullback = bars_below_10 >= 2
bool crosses_above_mas  = (close > e10) and (close > e20) and (close[1] <= e10[1] or close[1] <= e20[1])

bool is_wedge_pop  = show_cpa and came_from_pullback and crosses_above_mas and (close > open)

bool was_above_mas = (close[1] >= e10[1]) or (close[1] >= e20[1])
bool crosses_below = (close < e10) and (close < e20)
bool is_wedge_drop = show_cpa and was_above_mas and crosses_below and (close < open)

// =====================================================================
// 4. LITTLE TRICKS & SWING REPORT ADDITIONS
// =====================================================================
is_inside = (high < prev_high) and (low > prev_low)

prev_upper_wick = prev_high - math.max(prev_open, prev_close)
had_large_wick  = prev_upper_wick > (prev_range * 0.40)
is_wick_play    = had_large_wick and (open > math.max(prev_open, prev_close)) and (open < prev_high) and (close > open)

is_out_rev = (low < prev_low) and (close > prev_high) and (close > open)
is_2b      = (low < lowest_10_prev) and (close > lowest_10_prev) and (close > open)

is_ignite   = (body_size >= atr * 1.5) and (close_pos >= 0.75) and (volume > vol_sma * 1.2)
is_hvc      = (volume >= vol_sma * 2.0) and (close_pos >= 0.80)
is_undercut = (low < lowest_10_prev) and (close > lowest_10_prev) and (close > open)

// =====================================================================
// 5. UNFILLED GAP ENGINE
// =====================================================================
type Gap
    box b
    float topLevel
    float bottomLevel
    bool isBullish
    bool isFilled
    bool isPartiallyFilled

var array<Gap> gaps = array.new<Gap>()

if show_gaps
    float gapLogicClose = close[1]
    float gapLogicOpen = open
    float gapSize = math.abs(gapLogicOpen - gapLogicClose)

    if gapSize >= minGapSize
        bool isBullishGap = gapLogicOpen > gapLogicClose
        float topL = math.max(gapLogicOpen, gapLogicClose)
        float botL = math.min(gapLogicOpen, gapLogicClose)
        box b = box.new(left=bar_index - 1, top=topL, right=bar_index, bottom=botL, bgcolor=gapColor, border_color=transparent_brd)
        array.push(gaps, Gap.new(b, topL, botL, isBullishGap, false, false))

    if array.size(gaps) > 0
        for i = array.size(gaps) - 1 to 0
            Gap g = array.get(gaps, i)
            if g.isFilled
                continue

            box.set_right(g.b, bar_index)
            
            if g.isBullish
                if low < g.topLevel and low > g.bottomLevel
                    g.isPartiallyFilled := true
                    g.topLevel := low
                    box.set_top(g.b, g.topLevel)
                if low <= g.bottomLevel
                    g.isFilled := true
                    box.delete(g.b)
            else
                if high > g.bottomLevel and high < g.topLevel
                    g.isPartiallyFilled := true
                    g.bottomLevel := high
                    box.set_bottom(g.b, g.bottomLevel)
                if high >= g.topLevel
                    g.isFilled := true
                    box.delete(g.b)

            if not g.isFilled
                if not showPartiallyFilled and g.isPartiallyFilled
                    color hidden_col = color.new(red_ink, 100)
                    box.set_bgcolor(g.b, hidden_col)
                    box.set_border_color(g.b, hidden_col)
                else
                    box.set_bgcolor(g.b, gapColor)
                    box.set_border_color(g.b, transparent_brd)

// =====================================================================
// 6. BASE CONSOLIDATION ENGINE
// =====================================================================
var float c_high          = na
var float c_low           = na
var int   c_start         = na

bool is_base = false
bool is_flat = false
bool is_htf  = false
bool is_w    = false
bool is_c    = false

int ph_left  = timeframe.isweekly or timeframe.ismonthly ? 3 : 5
int ph_right = 3
float pivot_h = ta.pivothigh(high, ph_left, ph_right)
float prior_low_series = ta.lowest(low, 30)

if not na(pivot_h)
    int candidate_start = bar_index - ph_right
    if na(c_high) or (pivot_h > c_high)
        float run_low = prior_low_series[ph_right]
        float prior_gain = run_low > 0 ? ((pivot_h - run_low) / run_low) * 100 : 0
        if prior_gain >= prior_trend_min or na(c_high)
            c_high  := pivot_h
            c_start := candidate_start
            
            float min_l = low[0]
            for i = 1 to ph_right
                if low[i] < min_l
                    min_l := low[i]
            c_low   := min_l

if not na(c_high)
    if low < c_low
        c_low := low

    float current_depth = ((c_high - c_low) / c_high) * 100
    int   current_dur   = bar_index - c_start

    if high > c_high and current_dur < min_base_length
        c_high  := high
        c_start := bar_index
        c_low   := low

    if current_depth > max_base_depth or current_dur > 250
        c_high := na

if not na(c_high)
    int base_dur = bar_index - c_start
    if base_dur >= min_base_length
        bool breakout = close > c_high and close[1] <= c_high
        
        if breakout
            float base_depth = ((c_high - c_low) / c_high) * 100
            
            int h_dur = math.max(4, math.floor(base_dur * 0.25))
            float handle_zone_low = low[1]
            for i = 1 to h_dur
                if low[i] < handle_zone_low
                    handle_zone_low := low[i]
            bool has_handle = handle_zone_low >= (c_low + (c_high - c_low) * 0.50)

            int mid_bar_offset = math.floor(base_dur / 2)
            float left_low = low[base_dur]
            int left_low_idx = base_dur
            for i = mid_bar_offset to base_dur
                if low[i] < left_low
                    left_low := low[i]
                    left_low_idx := i
                    
            float right_low = low[1]
            int right_low_idx = 1
            for i = 1 to mid_bar_offset - 1
                if low[i] < right_low
                    right_low := low[i]
                    right_low_idx := i
                    
            float mid_peak = high[right_low_idx]
            for i = right_low_idx to left_low_idx
                if high[i] > mid_peak
                    mid_peak := high[i]
                    
            bool has_w_structure = mid_peak >= (c_low + (c_high - c_low) * 0.25) 

            if base_dur <= 25 and base_depth <= 12
                is_htf := true
            else if has_handle and base_depth >= 15
                is_c := true
            else if has_w_structure and base_depth >= 15
                is_w := true
            else if base_dur <= 30 and base_depth <= 15
                is_flat := true
            else
                is_base := true

            if show_bases and not timeframe.isintraday
                line.new(c_start, c_high, bar_index, c_high, color=base_col, width=base_wid, style=b_style)
                line.new(c_start, c_low, bar_index, c_low, color=base_col, width=base_wid, style=b_style)
                
                if is_dark
                    label.new(c_start, c_high, text="Hi: " + str.tostring(math.round(c_high, 2)), color=color.white, textcolor=color.black, style=label.style_label_down, size=size.small)

            c_high := na

// =====================================================================
// 7. CLEAN SWING TRENDLINES (NON-OVERLAPPING)
// =====================================================================
type TL
    line obj
    float slope
    int start_x
    float start_y
    bool is_res
    bool active

var array<TL> active_tls = array.new<TL>()

int tl_len = 5
float tl_ph = ta.pivothigh(high, tl_len, tl_len)
float tl_pl = ta.pivotlow(low, tl_len, tl_len)

var float last_ph_y = na
var int   last_ph_x = na
var float last_pl_y = na
var int   last_pl_x = na

if show_tls
    bool has_active_res = false
    bool has_active_sup = false
    if array.size(active_tls) > 0
        for i = 0 to array.size(active_tls) - 1
            TL t = array.get(active_tls, i)
            if t.active
                if t.is_res
                    has_active_res := true
                else
                    has_active_sup := true

    if not na(tl_ph)
        if not na(last_ph_y) and tl_ph < last_ph_y and not has_active_res
            int anchor_x = bar_index[tl_len]
            float m = (tl_ph - last_ph_y) / (anchor_x - last_ph_x)
            line l = line.new(last_ph_x, last_ph_y, anchor_x, tl_ph, color=base_col, width=1, style=line.style_solid, extend=extend.right)
            array.push(active_tls, TL.new(l, m, last_ph_x, last_ph_y, true, true))
        last_ph_y := tl_ph
        last_ph_x := bar_index[tl_len]

    if not na(tl_pl)
        if not na(last_pl_y) and tl_pl > last_pl_y and not has_active_sup
            int anchor_x = bar_index[tl_len]
            float m = (tl_pl - last_pl_y) / (anchor_x - last_pl_x)
            line l = line.new(last_pl_x, last_pl_y, anchor_x, tl_pl, color=base_col, width=1, style=line.style_solid, extend=extend.right)
            array.push(active_tls, TL.new(l, m, last_pl_x, last_pl_y, false, true))
        last_pl_y := tl_pl
        last_pl_x := bar_index[tl_len]

    if array.size(active_tls) > 0
        for i = array.size(active_tls) - 1 to 0
            TL t = array.get(active_tls, i)
            if t.active
                float expected_y = t.start_y + t.slope * (bar_index - t.start_x)
                bool is_broken = (t.is_res and close > expected_y) or (not t.is_res and close < expected_y)
                if is_broken
                    t.active := false
                    line.set_extend(t.obj, extend.none)
                    line.set_xy2(t.obj, bar_index, expected_y)

// =====================================================================
// 8. PIVOT POINTS, VWAP, HTF EMAS & EVENT LINES
// =====================================================================
[d_h, d_l, d_c] = request.security(syminfo.tickerid, "D", [high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)

float pp = (d_h + d_l + d_c) / 3
float r1 = (pp * 2) - d_l
float s1 = (pp * 2) - d_h
float r2 = pp + (d_h - d_l)
float s2 = pp - (d_h - d_l)

// HTF Daily EMAs for Intraday Overlay
d_e10 = request.security(syminfo.tickerid, "D", ta.ema(close, 10))
d_e20 = request.security(syminfo.tickerid, "D", ta.ema(close, 20))

// VWAP Calculation
float vwap_val = ta.vwap(close)

// Visibility Toggles (Strictly Dark Mode + Intraday)
bool is_intraday_dark = timeframe.isintraday and is_dark
bool show_p   = show_pivots and is_intraday_dark
bool show_htf = show_htf_emas and is_intraday_dark
bool show_v   = show_vwap and is_intraday_dark

color col_pp = color.new(color.purple, 30)
color col_r  = color.new(color.red, 30)
color col_s  = color.new(color.green, 30)
color col_v  = color.new(color.white, 50)

if is_dark and (bar_index % grid_interval == 0)
    line.new(bar_index, low, bar_index, high, extend=extend.both, color=color.new(color.gray, 85), style=line.style_dashed, width=1)

float eps = request.earnings(syminfo.tickerid, earnings.actual, ignore_invalid_symbol=true)
bool is_earnings = ta.change(eps) != 0

if not timeframe.isintraday and is_earnings and is_dark
    line.new(bar_index, low, bar_index, high, extend=extend.both, color=color.new(color.red, 50), style=line.style_dashed, width=1)

// =====================================================================
// 9. COMBINED STRING BUILDER 
// =====================================================================
string above_str = ""
if is_exh
    above_str := above_str + (above_str == "" ? "E" : ",E")
if show_swing and is_hvc
    above_str := above_str + (above_str == "" ? "HVC" : ",HVC")
if show_tricks and is_inside
    above_str := above_str + (above_str == "" ? "I" : ",I")

string below_str = ""
if is_wedge_pop
    below_str := below_str + (below_str == "" ? "P" : ",P")
if is_wedge_drop
    below_str := below_str + (below_str == "" ? "D" : ",D")
if is_rev
    below_str := below_str + (below_str == "" ? "R" : ",R")

if is_base
    below_str := below_str + (below_str == "" ? "B" : ",B")
if is_flat
    below_str := below_str + (below_str == "" ? "F" : ",F")
if is_htf
    below_str := below_str + (below_str == "" ? "H" : ",H")
if is_w
    below_str := below_str + (below_str == "" ? "W" : ",W")
if is_c
    below_str := below_str + (below_str == "" ? "C" : ",C")

if show_tricks and is_wick_play
    below_str := below_str + (below_str == "" ? "K" : ",K")
if show_tricks and is_out_rev
    below_str := below_str + (below_str == "" ? "O" : ",O")
if show_tricks and is_2b
    below_str := below_str + (below_str == "" ? "2" : ",2")

if show_swing and is_ignite
    below_str := below_str + (below_str == "" ? "V" : ",V")
if show_swing and is_undercut
    below_str := below_str + (below_str == "" ? "U" : ",U")

// =====================================================================
// 10. PLOTS & BOOK AESTHETICS
// =====================================================================
plot(show_ema5  ? e5  : na, "5 EMA",  col_ema5,  ma_wid)
plot(show_ema10 ? e10 : na, "10 EMA", col_ema10, ma_wid)
plot(show_ema20 ? e20 : na, "20 EMA", col_ema20, ma_wid)
plot(show_sma50 ? s50 : na, "50 SMA", col_sma50, ma_wid)

plot(show_p ? pp : na, "Pivot (P)", col_pp, 1, plot.style_circles)
plot(show_p ? r1 : na, "R1", col_r, 1, plot.style_circles)
plot(show_p ? s1 : na, "S1", col_s, 1, plot.style_circles)
plot(show_p ? r2 : na, "R2", col_r, 1, plot.style_circles)
plot(show_p ? s2 : na, "S2", col_s, 1, plot.style_circles)

plot(show_v ? vwap_val : na, "VWAP", col_v, 1, plot.style_cross)
plot(show_htf ? d_e10 : na, "HTF Daily 10 EMA", color.new(col_ema10, 60), 2, plot.style_stepline)
plot(show_htf ? d_e20 : na, "HTF Daily 20 EMA", color.new(col_ema20, 60), 2, plot.style_stepline)

if above_str != "" and not timeframe.isintraday
    label.new(bar_index, high, text=above_str, color=color.new(color.white, 100), textcolor=txt_color, style=label.style_label_down, size=size.tiny)

if below_str != "" and not timeframe.isintraday
    label.new(bar_index, low, text=below_str, color=color.new(color.white, 100), textcolor=txt_color, style=label.style_label_up, size=size.tiny)

// =====================================================================
// 11. CHART KEY / LEGEND (Table Dynamic Palette)
// =====================================================================
var string t_pos = leg_pos == "Top Right" ? position.top_right : leg_pos == "Bottom Right" ? position.bottom_right : leg_pos == "Bottom Left" ? position.bottom_left : position.top_left

color tbl_bg   = is_dark ? color.new(color.rgb(20, 25, 35), 20) : color.new(color.white, 15)
color tbl_hdr  = is_dark ? color.new(color.rgb(40, 50, 70), 30) : color.new(color.gray, 80)
color tbl_brd  = is_dark ? color.new(color.gray, 70)             : color.new(color.gray, 50)

var table legend = table.new(t_pos, 2, 18, bgcolor=tbl_bg, border_width=1, border_color=tbl_brd)

if barstate.isfirst and show_legend
    table.cell(legend, 0, 0, "Key", text_color=txt_color, text_size=size.small, text_halign=text.align_center, bgcolor=tbl_hdr)
    table.cell(legend, 1, 0, "Pattern / Signal", text_color=txt_color, text_size=size.small, text_halign=text.align_center, bgcolor=tbl_hdr)
    
    table.cell(legend, 0, 1, "P", text_color=txt_color, text_size=size.small, text_halign=text.align_center)
    table.cell(legend, 1, 1, "Wedge Pop", text_color=txt_color, text_size=size.small, text_halign=text.align_left)
    table.cell(legend, 0, 2, "D", text_color=txt_color, text_size=size.small, text_halign=text.align_center)
    table.cell(legend, 1, 2, "Wedge Drop", text_color=txt_color, text_size=size.small, text_halign=text.align_left)
    table.cell(legend, 0, 3, "E", text_color=txt_color, text_size=size.small, text_halign=text.align_center)
    table.cell(legend, 1, 3, "Exhaustive Ext", text_color=txt_color, text_size=size.small, text_halign=text.align_left)
    table.cell(legend, 0, 4, "R", text_color=txt_color, text_size=size.small, text_halign=text.align_center)
    table.cell(legend, 1, 4, "Reversal Ext", text_color=txt_color, text_size=size.small, text_halign=text.align_left)
    
    table.cell(legend, 0, 5, "B", text_color=txt_color, text_size=size.small, text_halign=text.align_center)
    table.cell(legend, 1, 5, "Base n' Break", text_color=txt_color, text_size=size.small, text_halign=text.align_left)
    table.cell(legend, 0, 6, "F", text_color=txt_color, text_size=size.small, text_halign=text.align_center)
    table.cell(legend, 1, 6, "Flat Base", text_color=txt_color, text_size=size.small, text_halign=text.align_left)
    table.cell(legend, 0, 7, "H", text_color=txt_color, text_size=size.small, text_halign=text.align_center)
    table.cell(legend, 1, 7, "High Tight Flag", text_color=txt_color, text_size=size.small, text_halign=text.align_left)
    table.cell(legend, 0, 8, "W", text_color=txt_color, text_size=size.small, text_halign=text.align_center)
    table.cell(legend, 1, 8, "Double Bottom", text_color=txt_color, text_size=size.small, text_halign=text.align_left)
    table.cell(legend, 0, 9, "C", text_color=txt_color, text_size=size.small, text_halign=text.align_center)
    table.cell(legend, 1, 9, "Cup with Handle", text_color=txt_color, text_size=size.small, text_halign=text.align_left)
    
    table.cell(legend, 0, 10, "I", text_color=txt_color, text_size=size.small, text_halign=text.align_center)
    table.cell(legend, 1, 10, "Inside Bar", text_color=txt_color, text_size=size.small, text_halign=text.align_left)
    table.cell(legend, 0, 11, "K", text_color=txt_color, text_size=size.small, text_halign=text.align_center)
    table.cell(legend, 1, 11, "Wick Play", text_color=txt_color, text_size=size.small, text_halign=text.align_left)
    table.cell(legend, 0, 12, "O", text_color=txt_color, text_size=size.small, text_halign=text.align_center)
    table.cell(legend, 1, 12, "Outside Rev", text_color=txt_color, text_size=size.small, text_halign=text.align_left)
    table.cell(legend, 0, 13, "2", text_color=txt_color, text_size=size.small, text_halign=text.align_center)
    table.cell(legend, 1, 13, "2B Reversal", text_color=txt_color, text_size=size.small, text_halign=text.align_left)

    table.cell(legend, 0, 14, "V", text_color=txt_color, text_size=size.small, text_halign=text.align_center)
    table.cell(legend, 1, 14, "Ignite Bar", text_color=txt_color, text_size=size.small, text_halign=text.align_left)
    table.cell(legend, 0, 15, "HVC", text_color=txt_color, text_size=size.small, text_halign=text.align_center)
    table.cell(legend, 1, 15, "High Volume Close", text_color=txt_color, text_size=size.small, text_halign=text.align_left)
    table.cell(legend, 0, 16, "U", text_color=txt_color, text_size=size.small, text_halign=text.align_center)
    table.cell(legend, 1, 16, "Undercut & Rally", text_color=txt_color, text_size=size.small, text_halign=text.align_left)
````
