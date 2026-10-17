# NASDAQ Risk Reference

- url: https://www.tradingview.com/script/jxONn9p9/
- type: indicator
- pine_id: PUB;eb3fcf8c9a8e401ca5796d59a1622d30
- version: 8.0

## Description

NASDAQ Position Sizing & Risk Reference Matrix

This script provides a visual reference matrix for risk management when trading NASDAQ futures (NQ / MNQ). It helps traders quickly determine appropriate contract sizes or stop-loss distances based on a predefined dollar risk.

The tool avoids complex chart indicators and focuses entirely on delivering a clean matrix directly within the chart window to streamline order execution.

Features & Calculation Basis
The script calculates values based on the official contract specifications for the NASDAQ-100 Future:
- E-mini (NQ): 1 Point = $20 | 1 Tick = $5
- Micro E-mini (MNQ): 1 Point = $2 | 1 Tick = $0.50

Display Modes (Layouts)
Three distinct table layouts are available and can be selected via the settings menu:

1. By Contracts: Displays the maximum allowed stop-loss distance in points or ticks for a sequential number of contracts (quantity 1 to n) to strictly maintain the selected dollar risk.
2. By SL Distance: Displays the maximum number of contracts (rounded down to whole numbers) that can be traded for specific stop-loss distances, using a customizable start value and step increment.
3. Both (Combined View): Displays both tables side-by-side with a clean visual separator for an optimal layout.

Input Parameters
- Risk (USD): The maximum risk per trade in US Dollars (e.g., $200).
- Unit: Switchable between Ticks and Points for all distance metrics.
- Table Rows: Determines the length of the table (number of contract levels or SL steps).
- SL Start & Step: Defines the mathematical grid for the "By SL Distance" mode.
- Table Design: Fully adjustable positioning (e.g., top-right, bottom-left), background transparency, text color, and text size.

Technical Note
The table calculates exclusively on the historical data of the latest available bar (barstate.islast) to optimize chart performance. Contract sizes in distance mode are rounded down using math.floor, as fractional contracts cannot be executed in live trading.

## Source Code

````pine
//@version=6
// © 2026 kp_eu_de
// Released under the MIT License
indicator("NASDAQ Risk Reference v3", overlay=true, max_labels_count=500)

// ==============================================================================
// === [BLOCK 1] SETTINGS & INPUTS ==============================================
// ==============================================================================
grp_risk    = "--- Risk & Display ---"
risk_usd    = input.float(300, "Risk (USD)", inline="r1", group=grp_risk, tooltip="EN: Maximum risk per trade in USD.\nDE: Maximales Risiko pro Trade in USD.")
unit_mode   = input.string("Points", "Unit", options=["Ticks", "Points"], inline="r1", group=grp_risk)
max_rows    = input.int(10, "Rows (Max)", minval=1, maxval=50, inline="r2", group=grp_risk, tooltip="EN: Maximum number of table rows.\nDE: Maximale Anzahl an Tabellenzeilen.")
tbl_mode    = input.string("Both", "Layout", options=["By Contracts", "By SL Distance", "Both"], inline="r2", group=grp_risk)
sl_start    = input.float(10.0, "SL Start", minval=0.25, inline="r3", group=grp_risk)
sl_step     = input.float(10.0, "SL Step", minval=0.25, inline="r3", group=grp_risk)
auto_scale  = input.bool(true, "Auto-Scale Table", inline="r3", group=grp_risk, tooltip="EN: Automatically adjusts SL steps based on current market data.\nDE: Passt die SL-Schritte automatisch an die aktuellen Marktdaten an.")
show_candle = input.bool(true, "Show Candle Stats", inline="cdl", group=grp_risk)
candle_len  = input.int(20, "Length", inline="cdl", group=grp_risk)

grp_rec     = "--- Hist. Swing SL & Swings ---"
show_rec    = input.bool(true, "Show Hist. Swing SL", inline="hs1", group=grp_rec)
swing_pct   = input.float(100.0, "Pct (%)", step=5.0, inline="hs1", group=grp_rec)
swing_left  = input.int(6, "Left", inline="hs2", group=grp_rec, tooltip="EN: Bars left to define a structural swing.\nDE: Kerzen links zur Definition eines strukturellen Swings.")
swing_right = input.int(3, "Right", inline="hs2", group=grp_rec, tooltip="EN: Bars right to confirm the swing quickly.\nDE: Kerzen rechts zur schnellen Bestätigung des Swings.")
swing_count = input.int(5, "Swings to Avg", minval=1, inline="hs2", group=grp_rec)
show_swings = input.bool(true, "Show Swing Distances", inline="hs3", group=grp_rec)
swing_col   = input.color(color.new(color.yellow, 40), "Text Color", inline="hs3", group=grp_rec)

grp_vol     = "--- Volatility Safety Buffer ---"
use_vol_buf = input.bool(true, "Use Vol Buffer", inline="vol1", group=grp_vol, tooltip="EN: Adapts SL dynamically if recent volatility spikes above the baseline.\nDE: Passt den SL dynamisch an, wenn die aktuelle Volatilität den Basiswert übersteigt.")
base_swings = input.int(15, "Base Swings", minval=5, inline="vol1", group=grp_vol)
vol_thresh  = input.float(1.5, "Spike Thresh", inline="vol1", group=grp_vol)

grp_rec2          = "--- Last Swing SL ---"
show_last_swing   = input.bool(true, "Show Last Swing SL", inline="ls1", group=grp_rec2)
swing_tbl_mode    = input.string("Auto (iFVG Trend)", "Mode", options=["Auto (Pivot Trend)", "Auto (iFVG Trend)", "Show Both"], inline="ls1", group=grp_rec2, tooltip="EN: Determines how the Swing SL direction is chosen.\nDE: Legt fest, wie die Richtung des Swing SL ausgewählt wird.")
last_swing_offset = input.float(0.0, "Offset", inline="ls2", group=grp_rec2)
show_swing_line   = input.bool(true, "Draw SL Line", inline="ls3", group=grp_rec2)
swing_line_col    = input.color(color.orange, "", inline="ls3", group=grp_rec2)
swing_line_style  = input.string("Dashed", "", options=["Solid", "Dashed", "Dotted"], inline="ls3", group=grp_rec2)
swing_line_width  = input.int(1, "Width", minval=1, maxval=5, inline="ls3", group=grp_rec2)

grp_rec3    = "--- iFVG SL ---"
show_ifvg   = input.bool(true, "Show Confirmed iFVG", inline="if1", group=grp_rec3)
wait_close  = input.bool(true, "Wait for Close", inline="if1", group=grp_rec3, tooltip="EN: Waits for the candle to close before confirming the iFVG break.\nDE: Wartet auf den Kerzenschluss, bevor der iFVG-Ausbruch bestätigt wird.")
min_ifvg_pts= input.float(0.0, "Min Size", inline="if2", group=grp_rec3, tooltip="EN: Minimum required size for a valid FVG.\nDE: Mindestgröße für eine gültige FVG.")
ifvg_offset = input.float(0.0, "Offset", inline="if2", group=grp_rec3)
show_ifvg_line   = input.bool(true, "Draw Confirmed Line", inline="if4", group=grp_rec3)
ifvg_line_col    = input.color(color.blue, "", inline="if4", group=grp_rec3)
ifvg_line_style  = input.string("Dashed", "", options=["Solid", "Dashed", "Dotted"], inline="if4", group=grp_rec3)
ifvg_line_width  = input.int(1, "Width", minval=1, maxval=5, inline="if4", group=grp_rec3)

show_live_ifvg_line  = input.bool(true, "Draw Unconfirmed Line", inline="if5", group=grp_rec3, tooltip="EN: Shows the developing iFVG live before candle close.\nDE: Zeigt die sich anbahnende iFVG live vor Kerzenschluss.")
live_ifvg_line_col   = input.color(color.new(color.blue, 50), "", inline="if5", group=grp_rec3)
live_ifvg_line_style = input.string("Dotted", "", options=["Solid", "Dashed", "Dotted"], inline="if5", group=grp_rec3)

grp_line    = "--- Line Labels & Formatting ---"
label_mode  = input.string("Long", "Text Mode", options=["Compact", "Long"], inline="ll1", group=grp_line)
separator   = input.string("/", "Separator", options=["/", "|", "-", ".", ";", ":"], inline="ll1", group=grp_line)
show_qty    = input.bool(true, "Show Qty", inline="ll2", group=grp_line)
show_pts    = input.bool(true, "Show Pts", inline="ll2", group=grp_line)

grp_flt     = "--- Table Filtering & Layout ---"
filter_tbl  = input.bool(true, "Filter to Optimal SL", inline="flt1", group=grp_flt, tooltip="EN: Compresses the table to show only the best matching contract quantities.\nDE: Komprimiert die Tabelle auf die am besten passenden Kontraktgrößen.")
show_adj    = input.bool(false, "Show Adj Rows", inline="flt1", group=grp_flt)
hl_best     = input.bool(true, "Highlight Best", inline="hl1", group=grp_flt)
hl_col      = input.color(color.new(color.yellow, 40), "Color", inline="hl1", group=grp_flt)
tbl_pos     = input.string(position.bottom_left, "Pos", options=[position.top_right, position.bottom_right, position.top_left, position.bottom_left], inline="td1", group=grp_flt)
sort_sl_asc = input.bool(false, "Sort ASC", inline="td1", group=grp_flt)
tbl_bg      = input.color(color.new(color.black, 100), "BG", inline="td2", group=grp_flt)
tbl_txt     = input.color(color.white, "Text", inline="td2", group=grp_flt)
tbl_txt_sze = input.string(size.small, "Size", options=[size.tiny, size.small, size.normal, size.large], inline="td2", group=grp_flt)

// ==============================================================================
// === [BLOCK 2] HELPERS & MULTIPLIERS ==========================================
// ==============================================================================
get_style(s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

is_points   = unit_mode == "Points"
nq_val      = is_points ? 20.0 : 5.0
mnq_val     = is_points ? 2.0  : 0.5
unit        = is_points ? " Pkt" : " Ticks"

get_best_match(target_sl, val_multiplier) =>
    int best_idx = 0
    if not na(target_sl)
        float min_diff = 10e6
        for i = 1 to 500
            float sl_c = risk_usd / (i * val_multiplier)
            if math.abs(sl_c - target_sl) < min_diff
                min_diff := math.abs(sl_c - target_sl)
                best_idx := i
        if target_sl > (risk_usd / val_multiplier) * 1.3
            best_idx := 0
    best_idx

format_label(name, dir_short, dir_long, m_val) =>
    int n_qty = get_best_match(m_val, nq_val)
    int mn_qty = get_best_match(m_val, mnq_val)
    
    string[] parts = array.new_string()
    array.push(parts, name)
    array.push(parts, label_mode == "Compact" ? dir_short : dir_long)
    
    if show_pts
        array.push(parts, str.tostring(m_val, "#") + unit)
        
    if show_qty
        if label_mode == "Compact"
            array.push(parts, str.tostring(n_qty) + " " + separator + " " + str.tostring(mn_qty)) 
        else
            array.push(parts, str.tostring(n_qty) + " Mini " + separator + " " + str.tostring(mn_qty) + " Micro")
            
    array.join(parts, " " + separator + " ")

// ==============================================================================
// === [BLOCK 3] SWING ANALYSIS =================================================
// ==============================================================================
var float last_pivot_high = na
var float last_pivot_low  = na
var int   pivot_1         = 0 
var int   pivot_2         = 0 
var int   pivot_3         = 0 
var int   global_trend    = 0 
var float[] all_diffs     = array.new_float()

ph = ta.pivothigh(high, swing_left, swing_right)
pl = ta.pivotlow(low, swing_left, swing_right)

if not na(ph)
    if not na(last_pivot_low) 
        diff = math.abs(ph - last_pivot_low)
        array.push(all_diffs, diff)
        if array.size(all_diffs) > base_swings
            array.shift(all_diffs)
        if show_swings
            label.new(bar_index[swing_right], ph, text=str.tostring(diff, "#"), color=color.new(color.white, 100), textcolor=swing_col, style=label.style_label_down, size=size.small)
    
    pivot_3 := pivot_2
    pivot_2 := pivot_1
    pivot_1 := bar_index[swing_right]
    last_pivot_high := ph
    global_trend := -1 

if not na(pl)
    if not na(last_pivot_high) 
        diff = math.abs(pl - last_pivot_high)
        array.push(all_diffs, diff)
        if array.size(all_diffs) > base_swings
            array.shift(all_diffs)
        if show_swings
            label.new(bar_index[swing_right], pl, text=str.tostring(diff, "#"), color=color.new(color.white, 100), textcolor=swing_col, style=label.style_label_up, size=size.small)
        
    pivot_3 := pivot_2
    pivot_2 := pivot_1
    pivot_1 := bar_index[swing_right]
    last_pivot_low := pl
    global_trend := 1 

// ==============================================================================
// === [BLOCK 4] iFVG DETECTION =================================================
// ==============================================================================
type FVG 
    float top
    float bot
    bool  is_bull 
    int   idx

var fvg_stack = array.new<FVG>()
var float active_ifvg_ref = na
var string active_ifvg_dir = ""
var int active_ifvg_idx = 0

float eval_close = (wait_close and barstate.isrealtime) ? close[1] : close

if not na(active_ifvg_ref)
    float offset_p = is_points ? ifvg_offset : ifvg_offset * syminfo.mintick
    float sl_price = active_ifvg_dir == "Long" ? active_ifvg_ref - offset_p : active_ifvg_ref + offset_p
    if (active_ifvg_dir == "Long" and eval_close < sl_price) or (active_ifvg_dir == "Short" and eval_close > sl_price)
        active_ifvg_ref := na
        active_ifvg_dir := ""
        active_ifvg_idx := 0

if active_ifvg_idx > 0 and active_ifvg_idx <= pivot_3
    active_ifvg_ref := na
    active_ifvg_dir := ""
    active_ifvg_idx := 0

float fvg_size_bull = math.abs(low[0] - high[2])
float fvg_size_bear = math.abs(low[2] - high[0])
float min_sz = is_points ? min_ifvg_pts : min_ifvg_pts * syminfo.mintick

if low[0] > high[2] and fvg_size_bull >= min_sz
    array.push(fvg_stack, FVG.new(low[0], high[2], true, bar_index))
if high[0] < low[2] and fvg_size_bear >= min_sz
    array.push(fvg_stack, FVG.new(low[2], high[0], false, bar_index))

float eval_live = close
float temp_live_ref = na
string temp_live_dir = ""

if array.size(fvg_stack) > 0
    int i = array.size(fvg_stack) - 1
    while i >= 0
        FVG f = array.get(fvg_stack, i)
        
        if f.idx <= pivot_3
            array.remove(fvg_stack, i)
        else
            if f.is_bull and eval_live < f.bot
                if temp_live_dir != "Short" or na(temp_live_ref) or f.top < temp_live_ref
                    temp_live_ref := f.top
                    temp_live_dir := "Short"
            else if not f.is_bull and eval_live > f.top
                if temp_live_dir != "Long" or na(temp_live_ref) or f.bot > temp_live_ref
                    temp_live_ref := f.bot
                    temp_live_dir := "Long"

            bool is_broken = false
            if f.is_bull and eval_close < f.bot
                if active_ifvg_dir != "Short" or na(active_ifvg_ref) or f.top < active_ifvg_ref
                    active_ifvg_ref := f.top
                    active_ifvg_dir := "Short"
                    active_ifvg_idx := f.idx
                is_broken := true
                
            else if not f.is_bull and eval_close > f.top
                if active_ifvg_dir != "Long" or na(active_ifvg_ref) or f.bot > active_ifvg_ref
                    active_ifvg_ref := f.bot
                    active_ifvg_dir := "Long"
                    active_ifvg_idx := f.idx
                is_broken := true
                
            if is_broken
                array.remove(fvg_stack, i)
        
        i := i - 1

float live_ifvg_ref = temp_live_ref
string live_ifvg_dir = temp_live_dir

if not na(live_ifvg_ref) and not na(active_ifvg_ref) and live_ifvg_ref == active_ifvg_ref
    live_ifvg_ref := na

// ==============================================================================
// === [BLOCK 5] SL CALCULATIONS ================================================
// ==============================================================================
float rec_sl_pts_hist = na
bool  is_spike        = false

if array.size(all_diffs) >= swing_count
    float sum_short = 0.0
    int start_idx = array.size(all_diffs) - swing_count
    for i = start_idx to array.size(all_diffs) - 1
        sum_short += array.get(all_diffs, i)
    float short_avg = sum_short / swing_count
    
    rec_sl_pts_hist := short_avg * (swing_pct / 100.0)

    if use_vol_buf and array.size(all_diffs) == base_swings
        float long_avg = array.sum(all_diffs) / base_swings
        if short_avg > long_avg * vol_thresh
            is_spike := true
            rec_sl_pts_hist := rec_sl_pts_hist * (short_avg / long_avg)
            
float rec_sl_val_hist = is_points ? rec_sl_pts_hist : rec_sl_pts_hist * 4 

float offset_val = is_points ? last_swing_offset : last_swing_offset * syminfo.mintick

float raw_long_price = not na(last_pivot_low) ? last_pivot_low - offset_val : na
float swing_long_price = (not na(raw_long_price) and close > raw_long_price) ? raw_long_price : na
float swing_long_dist  = not na(swing_long_price) ? math.abs(close - swing_long_price) : na
float rec_sl_swing_long = not na(swing_long_dist) ? (is_points ? swing_long_dist : swing_long_dist * 4) : na

float raw_short_price = not na(last_pivot_high) ? last_pivot_high + offset_val : na
float swing_short_price = (not na(raw_short_price) and close < raw_short_price) ? raw_short_price : na
float swing_short_dist  = not na(swing_short_price) ? math.abs(close - swing_short_price) : na
float rec_sl_swing_short = not na(swing_short_dist) ? (is_points ? swing_short_dist : swing_short_dist * 4) : na

float offset_ifvg_val = is_points ? ifvg_offset : ifvg_offset * syminfo.mintick
float ifvg_sl_price = na
float rec_sl_val_ifvg = na

if not na(active_ifvg_ref)
    ifvg_sl_price := active_ifvg_dir == "Long" ? active_ifvg_ref - offset_ifvg_val : active_ifvg_ref + offset_ifvg_val
    float dist = math.abs(close - ifvg_sl_price)
    rec_sl_val_ifvg := is_points ? dist : dist * 4

float live_ifvg_sl_price = na
float rec_sl_val_live = na

if not na(live_ifvg_ref)
    float raw_live_price = live_ifvg_dir == "Long" ? live_ifvg_ref - offset_ifvg_val : live_ifvg_ref + offset_ifvg_val
    if live_ifvg_dir == "Long" and close > raw_live_price
        live_ifvg_sl_price := raw_live_price
    else if live_ifvg_dir == "Short" and close < raw_live_price
        live_ifvg_sl_price := raw_live_price
    if not na(live_ifvg_sl_price)
        float dist = math.abs(close - live_ifvg_sl_price)
        rec_sl_val_live := is_points ? dist : dist * 4

// ==============================================================================
// === [BLOCK 6] LINE & LABEL DRAWING ===========================================
// ==============================================================================
var line sl_line_sw_l = na
var label sl_label_sw_l = na
var line sl_line_sw_s = na
var label sl_label_sw_s = na
var line sl_line_ifvg = na
var label sl_label_ifvg = na
var line sl_line_live = na
var label sl_label_live = na

if barstate.islast
    bool draw_long_swing = false
    bool draw_short_swing = false
    
    if show_swing_line and show_last_swing
        if swing_tbl_mode == "Show Both"
            draw_long_swing := true
            draw_short_swing := true
        else if swing_tbl_mode == "Auto (Pivot Trend)"
            if global_trend == 1
                draw_long_swing := true
            else
                draw_short_swing := true
        else if swing_tbl_mode == "Auto (iFVG Trend)"
            if active_ifvg_dir == "Long"
                draw_long_swing := true
            else if active_ifvg_dir == "Short"
                draw_short_swing := true
            else
                if global_trend == 1
                    draw_long_swing := true
                else
                    draw_short_swing := true

    if draw_long_swing and not na(swing_long_price)
        string lbl = format_label("Swing SL", "L", "Long", rec_sl_swing_long)
        if na(sl_line_sw_l)
            sl_line_sw_l := line.new(bar_index - 5, swing_long_price, bar_index + 5, swing_long_price, color=swing_line_col, style=get_style(swing_line_style), width=swing_line_width)
            sl_label_sw_l := label.new(bar_index + 5, swing_long_price, lbl, color=color.new(color.white,100), textcolor=swing_line_col, style=label.style_label_left, size=size.small)
        else
            line.set_xy1(sl_line_sw_l, bar_index - 5, swing_long_price)
            line.set_xy2(sl_line_sw_l, bar_index + 5, swing_long_price)
            label.set_xy(sl_label_sw_l, bar_index + 5, swing_long_price)
            label.set_text(sl_label_sw_l, lbl)
    else
        if not na(sl_line_sw_l)
            line.delete(sl_line_sw_l)
            label.delete(sl_label_sw_l)
            sl_line_sw_l := na
            sl_label_sw_l := na

    if draw_short_swing and not na(swing_short_price)
        string lbl = format_label("Swing SL", "S", "Short", rec_sl_swing_short)
        if na(sl_line_sw_s)
            sl_line_sw_s := line.new(bar_index - 5, swing_short_price, bar_index + 5, swing_short_price, color=swing_line_col, style=get_style(swing_line_style), width=swing_line_width)
            sl_label_sw_s := label.new(bar_index + 5, swing_short_price, lbl, color=color.new(color.white,100), textcolor=swing_line_col, style=label.style_label_left, size=size.small)
        else
            line.set_xy1(sl_line_sw_s, bar_index - 5, swing_short_price)
            line.set_xy2(sl_line_sw_s, bar_index + 5, swing_short_price)
            label.set_xy(sl_label_sw_s, bar_index + 5, swing_short_price)
            label.set_text(sl_label_sw_s, lbl)
    else
        if not na(sl_line_sw_s)
            line.delete(sl_line_sw_s)
            label.delete(sl_label_sw_s)
            sl_line_sw_s := na
            sl_label_sw_s := na

    if show_ifvg_line and show_ifvg and not na(ifvg_sl_price)
        string d_s = active_ifvg_dir == "Long" ? "L" : "S"
        string lbl = format_label("iFVG SL", d_s, active_ifvg_dir, rec_sl_val_ifvg)
        if na(sl_line_ifvg)
            sl_line_ifvg := line.new(bar_index - 5, ifvg_sl_price, bar_index + 5, ifvg_sl_price, color=ifvg_line_col, style=get_style(ifvg_line_style), width=ifvg_line_width)
            sl_label_ifvg := label.new(bar_index + 5, ifvg_sl_price, lbl, color=color.new(color.white,100), textcolor=ifvg_line_col, style=label.style_label_left, size=size.small)
        else
            line.set_xy1(sl_line_ifvg, bar_index - 5, ifvg_sl_price)
            line.set_xy2(sl_line_ifvg, bar_index + 5, ifvg_sl_price)
            label.set_xy(sl_label_ifvg, bar_index + 5, ifvg_sl_price)
            label.set_text(sl_label_ifvg, lbl)
    else
        if not na(sl_line_ifvg)
            line.delete(sl_line_ifvg)
            label.delete(sl_label_ifvg)
            sl_line_ifvg := na
            sl_label_ifvg := na

    if show_live_ifvg_line and not na(live_ifvg_sl_price)
        string d_s = live_ifvg_dir == "Long" ? "L" : "S"
        string lbl = format_label("Live iFVG", d_s, live_ifvg_dir, rec_sl_val_live)
        if na(sl_line_live)
            sl_line_live := line.new(bar_index - 5, live_ifvg_sl_price, bar_index + 5, live_ifvg_sl_price, color=live_ifvg_line_col, style=get_style(live_ifvg_line_style), width=1)
            sl_label_live := label.new(bar_index + 5, live_ifvg_sl_price, lbl, color=color.new(color.white,100), textcolor=live_ifvg_line_col, style=label.style_label_left, size=size.small)
        else
            line.set_xy1(sl_line_live, bar_index - 5, live_ifvg_sl_price)
            line.set_xy2(sl_line_live, bar_index + 5, live_ifvg_sl_price)
            label.set_xy(sl_label_live, bar_index + 5, live_ifvg_sl_price)
            label.set_text(sl_label_live, lbl)
    else
        if not na(sl_line_live)
            line.delete(sl_line_live)
            label.delete(sl_label_live)
            sl_line_live := na
            sl_label_live := na

// ==============================================================================
// === [BLOCK 7] TABLE PREPARATION & MATRIX =====================================
// ==============================================================================
if barstate.islast
    bool mod_hist = show_rec and not na(rec_sl_val_hist)
    
    bool mod_sw_l = false
    bool mod_sw_s = false
    
    if show_last_swing and not na(rec_sl_swing_long)
        if swing_tbl_mode == "Show Both"
            mod_sw_l := true
        else if swing_tbl_mode == "Auto (Pivot Trend)" and global_trend == 1
            mod_sw_l := true
        else if swing_tbl_mode == "Auto (iFVG Trend)" and (active_ifvg_dir == "Long" or (active_ifvg_dir == "" and global_trend == 1))
            mod_sw_l := true

    if show_last_swing and not na(rec_sl_swing_short)
        if swing_tbl_mode == "Show Both"
            mod_sw_s := true
        else if swing_tbl_mode == "Auto (Pivot Trend)" and global_trend == -1
            mod_sw_s := true
        else if swing_tbl_mode == "Auto (iFVG Trend)" and (active_ifvg_dir == "Short" or (active_ifvg_dir == "" and global_trend == -1))
            mod_sw_s := true

    bool mod_ifvg = show_ifvg and not na(rec_sl_val_ifvg)
    
    float actual_sl_start = sl_start
    float actual_sl_step  = sl_step
    
    if auto_scale
        float max_sl = 0.0
        if mod_hist
            max_sl := math.max(max_sl, rec_sl_val_hist)
        if mod_sw_l
            max_sl := math.max(max_sl, rec_sl_swing_long)
        if mod_sw_s
            max_sl := math.max(max_sl, rec_sl_swing_short)
        if mod_ifvg
            max_sl := math.max(max_sl, rec_sl_val_ifvg)
        
        if max_sl > 0
            if actual_sl_start >= max_sl
                actual_sl_start := math.max(1.0, math.floor(max_sl * 0.5))
            float calculated_step = (max_sl * 1.15 - actual_sl_start) / math.max(1, max_rows - 1)
            actual_sl_step := math.max(1.0, math.round(calculated_step))

    int active_mods = 0
    if mod_hist
        active_mods += 1
    if mod_sw_l
        active_mods += 1
    if mod_sw_s
        active_mods += 1
    if mod_ifvg
        active_mods += 1

    bool side_by_side = not filter_tbl
    int cols_per_mod = tbl_mode == "Both" ? 7 : 3

    int total_cols = math.max(1, side_by_side ? (active_mods * cols_per_mod) + math.max(0, active_mods - 1) : cols_per_mod)
    int total_rows = side_by_side ? (max_rows + 5) : (max_rows * 4 + 10)
    table riskTbl = table.new(tbl_pos, columns=total_cols, rows=total_rows, bgcolor=tbl_bg, border_width=0)

    table.merge_cells(riskTbl, 0, 0, total_cols - 1, 0)
    string risk_str = "$" + str.tostring(risk_usd, "#")
    if show_candle
        float m_sz = 0.0
        float t_sz = 0.0
        for i = 0 to candle_len - 1
            float sz = high[i] - low[i]
            t_sz += sz
            m_sz := math.max(m_sz, sz)
        risk_str += " | Cdl Ø (" + str.tostring(candle_len) + "): " + str.tostring(t_sz / candle_len, "#") + " | Max: " + str.tostring(m_sz, "#")
    
    table.cell(riskTbl, 0, 0, risk_str, text_color=tbl_txt, text_size=tbl_txt_sze, text_halign=text.align_left)

// ==============================================================================
// === [BLOCK 8] TABLE RENDERING LOOP ===========================================
// ==============================================================================
    int render_col = 0
    int current_row = 1
    int max_row_reached = 1
    int adj = show_adj ? 1 : 0

    if active_mods > 0
        for m = 1 to 4
            bool m_act = false
            float m_val = na
            string m_title = ""
            color m_title_col = color.new(tbl_txt, 20)

            if m == 1
                m_act := mod_hist
                m_val := rec_sl_val_hist
                m_title := (is_spike ? "⚠️ " : "") + "Hist. Swing (" + str.tostring(swing_pct, "#") + "%): " + str.tostring(m_val, "#") + unit
                m_title_col := is_spike ? color.orange : color.new(tbl_txt, 20)
            else if m == 2
                m_act := mod_sw_l
                m_val := rec_sl_swing_long
                m_title := "Swing SL (Long): " + str.tostring(m_val, "#") + unit
                m_title_col := color.green
            else if m == 3
                m_act := mod_sw_s
                m_val := rec_sl_swing_short
                m_title := "Swing SL (Short): " + str.tostring(m_val, "#") + unit
                m_title_col := color.red
            else if m == 4
                m_act := mod_ifvg
                m_val := rec_sl_val_ifvg
                m_title := "Last iFVG SL (" + active_ifvg_dir + "): " + str.tostring(m_val, "#") + unit
                m_title_col := active_ifvg_dir == "Long" ? color.green : color.red
                
            if not m_act
                continue

            int b_nq = get_best_match(m_val, nq_val)
            int b_mnq = get_best_match(m_val, mnq_val)
            
            int b_d = 0
            float min_d = 10e6
            for i = 1 to 500
                float sl_d = actual_sl_start + (i - 1) * actual_sl_step
                if math.abs(sl_d - m_val) < min_d
                    min_d := math.abs(sl_d - m_val)
                    b_d := i

            int c_s = side_by_side ? render_col : 0
            int r_s = side_by_side ? 1 : current_row

            table.merge_cells(riskTbl, c_s, r_s, c_s + cols_per_mod - 1, r_s)
            table.cell(riskTbl, c_s, r_s, m_title, text_color=m_title_col, text_size=tbl_txt_sze, text_halign=text.align_left)

            int h_r = r_s + 1
            
            int b_nq_qty_d = 0
            int b_mnq_qty_d = 0
            if b_d > 0
                float b_sl_d = actual_sl_start + (b_d - 1) * actual_sl_step
                b_nq_qty_d := math.floor(risk_usd / (b_sl_d * nq_val))
                b_mnq_qty_d := math.floor(risk_usd / (b_sl_d * mnq_val))
            
            color h_c_nq = (hl_best and b_nq > 0) ? hl_col : tbl_txt
            color h_c_mnq = (hl_best and b_mnq > 0) ? hl_col : tbl_txt
            color h_c_id = (hl_best and (b_nq > 0 or b_mnq > 0)) ? hl_col : tbl_txt
            color h_c_ds = (hl_best and b_d > 0) ? hl_col : tbl_txt
            color h_c_dnq = (hl_best and b_d > 0 and b_nq_qty_d > 0) ? hl_col : tbl_txt
            color h_c_dmnq = (hl_best and b_d > 0 and b_mnq_qty_d > 0) ? hl_col : tbl_txt

            if tbl_mode == "By Contracts" or tbl_mode == "Both"
                table.cell(riskTbl, c_s + 0, h_r, "#", text_color=h_c_id, text_size=tbl_txt_sze)
                table.cell(riskTbl, c_s + 1, h_r, "Mini", text_color=h_c_nq, text_size=tbl_txt_sze)
                table.cell(riskTbl, c_s + 2, h_r, "Micro", text_color=h_c_mnq, text_size=tbl_txt_sze)
            
            if tbl_mode == "Both"
                table.cell(riskTbl, c_s + 3, h_r, "   ", bgcolor=color.new(color.white, 100))
            
            if tbl_mode == "By SL Distance" or tbl_mode == "Both"
                int o = tbl_mode == "Both" ? 4 : 0
                table.cell(riskTbl, c_s + o + 0, h_r, "SL", text_color=h_c_ds, text_size=tbl_txt_sze)
                table.cell(riskTbl, c_s + o + 1, h_r, "Mini", text_color=h_c_dnq, text_size=tbl_txt_sze)
                table.cell(riskTbl, c_s + o + 2, h_r, "Micro", text_color=h_c_dmnq, text_size=tbl_txt_sze)

            int[] f_c = array.new_int()
            int[] f_d = array.new_int()
            
            if filter_tbl
                int[] d_c = array.new_int()
                int[] d_d = array.new_int()
                
                if b_nq > 0
                    array.push(d_c, b_nq)
                    if adj > 0
                        array.push(d_c, math.max(1, b_nq - 1))
                        array.push(d_c, b_nq + 1)
                        
                if b_mnq > 0
                    array.push(d_c, b_mnq)
                    if adj > 0
                        array.push(d_c, math.max(1, b_mnq - 1))
                        array.push(d_c, b_mnq + 1)
                        
                if b_d > 0
                    array.push(d_d, b_d)
                    if adj > 0
                        array.push(d_d, math.max(1, b_d - 1))
                        array.push(d_d, b_d + 1)
                
                if sort_sl_asc
                    array.sort(d_c, order.descending)
                    array.sort(d_d, order.ascending)
                else
                    array.sort(d_c, order.ascending)
                    array.sort(d_d, order.descending)
                    
                int l_c = -1
                if array.size(d_c) > 0
                    for x = 0 to array.size(d_c) - 1
                        int v_c = array.get(d_c, x)
                        if v_c != l_c
                            array.push(f_c, v_c)
                            l_c := v_c
                            
                int l_d = -1
                if array.size(d_d) > 0
                    for x = 0 to array.size(d_d) - 1
                        int v_d = array.get(d_d, x)
                        if v_d != l_d
                            array.push(f_d, v_d)
                            l_d := v_d

            int d_row = h_r + 1
            int loops = filter_tbl ? math.max(1, math.max(array.size(f_c), array.size(f_d))) : max_rows
            
            for i = 0 to math.max(0, loops - 1)
                int c_idx = na
                int d_idx = na
                
                if filter_tbl
                    if i < array.size(f_c)
                        c_idx := array.get(f_c, i)
                    if i < array.size(f_d)
                        d_idx := array.get(f_d, i)
                else
                    int r = i + 1
                    c_idx := sort_sl_asc ? (max_rows - r + 1) : r
                    d_idx := sort_sl_asc ? r : (max_rows - r + 1)
                    
                float n_sl = na
                float mn_sl = na
                float c_sl = na
                int n_qty = na
                int mn_qty = na
                
                if not na(c_idx)
                    n_sl := risk_usd / (c_idx * nq_val)
                    mn_sl := risk_usd / (c_idx * mnq_val)
                if not na(d_idx)
                    c_sl := actual_sl_start + (d_idx - 1) * actual_sl_step
                    n_qty := math.floor(risk_usd / (c_sl * nq_val))
                    mn_qty := math.floor(risk_usd / (c_sl * mnq_val))

                color c1 = (hl_best and not na(c_idx) and b_nq == c_idx) ? hl_col : tbl_txt
                color c2 = (hl_best and not na(c_idx) and b_mnq == c_idx) ? hl_col : tbl_txt
                color id_c = (hl_best and not na(c_idx) and (b_nq == c_idx or b_mnq == c_idx)) ? hl_col : tbl_txt
                color d_s = (hl_best and not na(d_idx) and b_d == d_idx) ? hl_col : tbl_txt
                color d_n = (hl_best and not na(d_idx) and b_d == d_idx and n_qty > 0) ? hl_col : tbl_txt
                color d_m = (hl_best and not na(d_idx) and b_d == d_idx and mn_qty > 0) ? hl_col : tbl_txt

                if tbl_mode == "By Contracts" or tbl_mode == "Both"
                    table.cell(riskTbl, c_s + 0, d_row, na(c_idx) ? "" : str.tostring(c_idx), text_color=id_c, text_size=tbl_txt_sze, text_halign=text.align_center)
                    table.cell(riskTbl, c_s + 1, d_row, na(n_sl) ? "" : str.tostring(n_sl, "#") + unit, text_color=c1, text_size=tbl_txt_sze, text_halign=text.align_center)
                    table.cell(riskTbl, c_s + 2, d_row, na(mn_sl) ? "" : str.tostring(mn_sl, "#") + unit, text_color=c2, text_size=tbl_txt_sze, text_halign=text.align_center)
                
                if tbl_mode == "Both"
                    table.cell(riskTbl, c_s + 3, d_row, "   ", bgcolor=color.new(color.white, 100))
                
                if tbl_mode == "By SL Distance" or tbl_mode == "Both"
                    int o = tbl_mode == "Both" ? 4 : 0
                    table.cell(riskTbl, c_s + o + 0, d_row, na(c_sl) ? "" : str.tostring(c_sl, "#") + unit, text_color=d_s, text_size=tbl_txt_sze, text_halign=text.align_center)
                    table.cell(riskTbl, c_s + o + 1, d_row, na(n_qty) ? "" : (n_qty > 0 ? str.tostring(n_qty) : "0"), text_color=d_n, text_size=tbl_txt_sze, text_halign=text.align_center)
                    table.cell(riskTbl, c_s + o + 2, d_row, na(mn_qty) ? "" : (mn_qty > 0 ? str.tostring(mn_qty) : "0"), text_color=d_m, text_size=tbl_txt_sze, text_halign=text.align_center)
                
                d_row += 1

            if side_by_side
                render_col += cols_per_mod + (render_col + cols_per_mod < total_cols ? 1 : 0)
                max_row_reached := math.max(max_row_reached, d_row)
            else
                current_row := d_row
                table.merge_cells(riskTbl, c_s, current_row, c_s + cols_per_mod - 1, current_row)
                table.cell(riskTbl, c_s, current_row, " ", text_size=size.tiny)
                current_row += 1
                max_row_reached := current_row

    table.merge_cells(riskTbl, 0, max_row_reached, total_cols - 1, max_row_reached)
    table.cell(riskTbl, 0, max_row_reached, "\n", text_size=size.small)
````
