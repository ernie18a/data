<!-- tradingview-pine-id: PUB;898bdfae5be84cdabcc319c67a28135a -->
<!-- tradingviewscripts-format: 1 -->
# Institutional Order Flow Imbalance Matrix PRO

Source: https://www.tradingview.com/script/iUCZjVck-Institutional-Order-Flow-Imbalance-Matrix-PRO/

## Description

Institutional Order Flow Imbalance Matrix PRO

Institutional Order Flow Imbalance Matrix PRO is a clean, multi timeframe technical analysis tool engineered to track institutional order flow, volume backed inefficiencies, and higher timeframe liquidity context without cluttering the charting interface.

Key Features Overview

1. Higher Timeframe Liquidity Matrix
Projects dynamic higher timeframe high and low liquidity levels directly onto lower timeframe charts. To maintain visual clarity, HTF lines automatically clean up and vanish as soon as price touches or breaks them.

2. Volume Validated Imbalance Engine
Identifies high probability price gaps supported by institutional volume surges. Unmitigated imbalance boxes automatically delete from your chart once price completely fills and mitigates the gap area.

3. Institutional Dynamic ATR Trend Ribbon
Plots a clean, non intrusive dynamic trend ribbon based on smoothed Volatility ATR trailing logic. This helps traders easily identify the overall institutional flow direction and dynamic support or resistance areas.

How to Use

Step 1: Check Institutional Trend Direction
Observe the smooth Trend Ribbon color background to determine whether institutional order flow is currently bullish or bearish.

Step 2: Monitor Higher Timeframe Context
Track how price action interacts with active HTF High and HTF Low lines to spot potential target levels or sweep points.

Step 3: Execute on Imbalance Retests
Identify active volume backed Imbalance zones forming in alignment with the broader ribbon trend, and look for entry setups upon price retesting these dynamic zones.

Settings Overview

HTF Matrix Settings
- Show HTF Structural Levels: Toggle display of higher timeframe boundary lines.
- Higher Timeframe Resolution: Choose your desired HTF lookback (default set to 240 minutes / 4 Hour).
- Colors: Customize line styling and colors for HTF boundaries.

Volume Imbalance Settings
- Show Volume Imbalance Zones: Toggle visibility of active inefficiency boxes.
- Volume Spike Factor: Adjust volume sensitivity for validating dynamic gaps.
- Zone Transparency: Customize color fill opacity for imbalance boxes.

Institutional Trend Ribbon Settings
- Show Dynamic Trend Ribbon: Toggle display of the smooth trailing ATR ribbon.
- ATR Period Length and Multiplier: Adjust the volatility parameters to match your trading timeframe.

Disclaimer
This indicator is created strictly for educational and analytical purposes. It does not provide financial advice, trade recommendations, or guaranteed results. Always apply proper risk management principles.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Dark_Ace_Master

//@version=6
// ==============================================================================================
//  I N S T I T U T I O N A L   O R D E R   F L O W   I M B A L A N C E   M A T R I X   P R O
// ==============================================================================================

indicator("Institutional Order Flow Imbalance Matrix PRO", "OrderFlow Matrix PRO", overlay = true, max_lines_count = 500, max_boxes_count = 100, max_labels_count = 500)

// 1. INPUTS & CONFIGURATION
g_htf            = "===== HTF INSTITUTIONAL LEVEL MATRIX ====="
show_htf         = input.bool(true, "Show HTF Structural Levels", group=g_htf)
htf_tf           = input.timeframe("240", "Higher Timeframe Resolution", group=g_htf)
c_htf_h          = input.color(#00e5ff, "HTF High Line Color", group=g_htf)
c_htf_l          = input.color(#ffea00, "HTF Low Line Color", group=g_htf)

g_imb            = "===== VOLUME VALIDATED IMBALANCE ZONES ====="
show_imb         = input.bool(true, "Show Volume Imbalance Zones", group=g_imb)
imb_threshold    = input.float(1.2, "Volume Spike Factor (Multiplier)", minval=1.0, group=g_imb)
imb_opacity      = input.int(85, "Zone Transparency (0-100)", minval=0, maxval=100, group=g_imb)
c_bull_imb       = input.color(#00e676, "Bullish Imbalance Color", group=g_imb)
c_bear_imb       = input.color(#ff1744, "Bearish Imbalance Color", group=g_imb)

g_ribbon         = "===== INSTITUTIONAL MOMENTUM RIBBON ====="
show_ribbon      = input.bool(true, "Show Smooth Dynamic Trend Ribbon", group=g_ribbon)
atr_len          = input.int(14, "ATR Period Length", minval=1, group=g_ribbon)
atr_mult         = input.float(2.0, "ATR Multiplier Sensitivity", minval=0.5, group=g_ribbon)
c_up_ribbon      = input.color(color.new(#29b6f6, 85), "Bullish Ribbon Color", group=g_ribbon)
c_dn_ribbon      = input.color(color.new(#ab47bc, 85), "Bearish Ribbon Color", group=g_ribbon)

// 2. HTF HIGH & LOW LEVELS (AUTO-DISAPPEAR ON BREAK)
[htf_h, htf_l] = request.security(syminfo.tickerid, htf_tf, [high[1], low[1]], lookahead=barmerge.lookahead_on)

var line line_htf_h = na
var line line_htf_l = na
var label lbl_htf_h  = na
var label lbl_htf_l  = na
var bool is_htf_h_broken = false
var bool is_htf_l_broken = false

if ta.change(time(htf_tf)) != 0
    is_htf_h_broken := false
    is_htf_l_broken := false
    line.delete(line_htf_h)
    line.delete(line_htf_l)
    label.delete(lbl_htf_h)
    label.delete(lbl_htf_l)

if show_htf and not is_htf_h_broken and not na(htf_h)
    if high >= htf_h
        is_htf_h_broken := true
        line.delete(line_htf_h)
        label.delete(lbl_htf_h)
    else
        line.delete(line_htf_h)
        label.delete(lbl_htf_h)
        line_htf_h := line.new(bar_index - 10, htf_h, bar_index + 12, htf_h, color=c_htf_h, style=line.style_dashed, width=2)
        lbl_htf_h  := label.new(bar_index + 12, htf_h, "HTF High", color=color.new(#000000, 100), textcolor=c_htf_h, style=label.style_label_left, size=size.small)

if show_htf and not is_htf_l_broken and not na(htf_l)
    if low <= htf_l
        is_htf_l_broken := true
        line.delete(line_htf_l)
        label.delete(lbl_htf_l)
    else
        line.delete(line_htf_l)
        label.delete(lbl_htf_l)
        line_htf_l := line.new(bar_index - 10, htf_l, bar_index + 12, htf_l, color=c_htf_l, style=line.style_dashed, width=2)
        lbl_htf_l  := label.new(bar_index + 12, htf_l, "HTF Low", color=color.new(#000000, 100), textcolor=c_htf_l, style=label.style_label_left, size=size.small)

// 3. VOLUME VALIDATED IMBALANCE ENGINE
avg_vol = ta.sma(volume, 20)
bool vol_spike = volume > (avg_vol * imb_threshold)

bool is_bull_imb = (low[0] > high[2]) and vol_spike
bool is_bear_imb = (high[0] < low[2]) and vol_spike

var box[] bull_imbs = array.new_box()
var box[] bear_imbs = array.new_box()

if show_imb and is_bull_imb
    box b_imb = box.new(left=bar_index - 2, top=low[0], right=bar_index + 10, bottom=high[2], border_color=c_bull_imb, bgcolor=color.new(c_bull_imb, imb_opacity), text="Imbalance", text_color=color.white, text_size=size.tiny, text_halign=text.align_right)
    array.push(bull_imbs, b_imb)

if show_imb and is_bear_imb
    box r_imb = box.new(left=bar_index - 2, top=low[2], right=bar_index + 10, bottom=high[0], border_color=c_bear_imb, bgcolor=color.new(c_bear_imb, imb_opacity), text="Imbalance", text_color=color.white, text_size=size.tiny, text_halign=text.align_right)
    array.push(bear_imbs, r_imb)

if show_imb and array.size(bull_imbs) > 0
    for i = array.size(bull_imbs) - 1 to 0
        box b = array.get(bull_imbs, i)
        if low < box.get_bottom(b)
            box.delete(b)
            array.remove(bull_imbs, i)
        else
            box.set_right(b, bar_index + 10)

if show_imb and array.size(bear_imbs) > 0
    for i = array.size(bear_imbs) - 1 to 0
        box b = array.get(bear_imbs, i)
        if high > box.get_top(b)
            box.delete(b)
            array.remove(bear_imbs, i)
        else
            box.set_right(b, bar_index + 10)

// 4. INSTITUTIONAL DYNAMIC ATR TREND RIBBON
atr_val = ta.atr(atr_len)
var float trend_stop = na
var int trend_dir = 1

float src_close = close
float upper_stop = src_close - (atr_val * atr_mult)
float lower_stop = src_close + (atr_val * atr_mult)

if na(trend_stop)
    trend_stop := upper_stop

if trend_dir == 1
    if src_close < trend_stop
        trend_dir := -1
        trend_stop := lower_stop
    else
        trend_stop := math.max(trend_stop, upper_stop)
else
    if src_close > trend_stop
        trend_dir := 1
        trend_stop := upper_stop
    else
        trend_stop := math.min(trend_stop, lower_stop)

p_src = plot(show_ribbon ? src_close : na, "Price Source", color=color.new(color.white, 100), display=display.none)
p_stop = plot(show_ribbon ? trend_stop : na, "Order Flow Ribbon Bound", color=trend_dir == 1 ? #00e676 : #ff1744, linewidth=1)
fill(p_src, p_stop, color=show_ribbon ? (trend_dir == 1 ? c_up_ribbon : c_dn_ribbon) : na, title="Order Flow Dynamic Fill")
````
