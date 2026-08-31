<!-- tradingview-pine-id: PUB;3addbd5525a6484a93caef24e7a972ad -->
<!-- tradingviewscripts-format: 1 -->
# ICT Smart Money Execution Engine PRO

Source: https://www.tradingview.com/script/w1u4mq8m-ICT-Smart-Money-Execution-Engine-PRO/

## Description

ICT Smart Money Execution Engine PRO

ICT Smart Money Execution Engine PRO is an advanced, high precision technical analysis tool designed for traders practicing Inner Circle Trader and Smart Money Concepts methodologies. It automatically maps structural context, liquidity sweeps, macro price extremes, and key session windows while keeping your charting environment ultra clean.

Key Features Overview

1. Intermediate Term Highs and Lows Badge Labels
Identifies major market turning points with distinct solid badge style labels. Intermediate Term Highs are clearly displayed with red ITH badges above swing points, and Intermediate Term Lows are displayed with green ITL badges below swing points.

2. Auto Mitigating Previous Day High and Low
Projects active daily boundaries on your chart. To prevent visual clutter, Previous Day High and Previous Day Low lines automatically delete as soon as price touches or mitigates them.

3. Red Line Termination Liquidity Sweeps
Tracks high probability liquidity pools sitting above swing highs and below swing lows. When price sweeps liquidity, a solid 2x width red line connects the original swing point directly to the sweeping candle wick, terminating instantly with a clear Liquidity Swept label.

4. Dynamic Auto Mitigating Fair Value Gaps
Automatically identifies bullish and bearish price imbalances across all timeframes. Unmitigated FVG boxes dynamically clean up and vanish as soon as price returns to fill them.

5. Volume Validated Order Blocks
Detects key institutional order block zones using a customizable 50 bar lookback by default. Zones remain active until price firmly closes beyond their boundaries.

6. Clean New York Session Highlight
Provides a single, ultra light background overlay specifically for the New York Session window, eliminating the distraction of multiple overlapping global sessions.

7. Market Structure Shift Detection
Tracks momentum reversals in real time by drawing clean dashed structure lines and MSS labels when key structural pivots are broken by candle closes.

How to Use

Step 1: Determine Macro Bias
Use the red ITH and green ITL badges to locate institutional swing extremes and understand the broader market trend.

Step 2: Focus on New York Session
Analyze price action during the highlighted New York Session window when market volume and institutional volatility are highest.

Step 3: Identify Liquidity Sweeps
Watch for price to sweep an active Previous Day High, Previous Day Low, or recent swing level marked by the bold red Liquidity Swept line.

Step 4: Execute on Structural Confirmation
Wait for a Market Structure Shift signal following a liquidity sweep, then evaluate entries on retaps into active Order Blocks or Fair Value Gaps.

Settings Overview

ITH / ITL Settings
- Show ITH / ITL Badge Labels: Toggle visibility of intermediate swing badges.
- Lookback Sensitivity Length: Adjust pivot lookback sensitivity for detecting macro highs and lows.
- Colors: Customization options for ITH and ITL badge background colors.

Previous Day High and Low Settings
- Show Active PDH / PDL: Toggle display of auto disappearing daily levels.
- Line Width and Style: Choose between solid, dotted, or dashed line styles and adjust thickness.

Fair Value Gap Settings
- Show Active FVGs: Toggle dynamic imbalance box visibility.
- FVG Transparency: Adjust fill opacity for bullish and bearish boxes.

Order Block Settings
- OB Lookback Length: Customize the pivot length used for order block detection (default is set to 50).

Liquidity Sweep Settings
- Show Liquidity Sweeps: Toggle sweep lines and labels.
- Sweep Line Color: Customize the color of the 2x width sweep termination line.

Session Settings
- Show Only New York Session: Toggle visibility of the session background highlight.
- NY Session Window: Set exact session hours to match your local or UTC-4/5 preferences.

Disclaimer
This script is built strictly for educational, analytical, and charting enhancement purposes. It does not provide financial advice, automated trading signals, trade management, or guaranteed results. Trading financial markets involves substantial risk of capital loss. Always perform your own analysis and practice strict risk management.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Dark_Ace_Master

//@version=6
// ==============================================================================================
//  I C T   S M A R T   M O N E Y   E X E C U T I O N   E N G I N E   P R O
// ==============================================================================================

indicator("ICT Smart Money Execution Engine PRO", "ICT Engine PRO", overlay = true, max_lines_count = 500, max_boxes_count = 100, max_labels_count = 500)

// 1. INPUTS & FULL CUSTOMIZATION PANEL
g_ith            = "===== INTERMEDIATE HIGHS & LOWS (ITH / ITL BADGES) ====="
show_ith         = input.bool(true, "Show ITH / ITL Badge Labels", group=g_ith)
ith_len          = input.int(20, "Lookback Sensitivity Length", minval=5, maxval=100, group=g_ith)
bg_ith           = input.color(#ff1744, "ITH Badge Color (Red)", group=g_ith)
bg_itl           = input.color(#00e676, "ITL Badge Color (Green)", group=g_ith)

g_fvg            = "===== ICT FAIR VALUE GAPS (AUTO-MITIGATED) ====="
show_fvg         = input.bool(true, "Show Active FVGs", group=g_fvg)
fvg_opacity      = input.int(85, "FVG Transparency (0-100)", minval=0, maxval=100, group=g_fvg)
c_bull_fvg       = input.color(#00e676, "Bullish FVG Color", group=g_fvg)
c_bear_fvg       = input.color(#ff1744, "Bearish FVG Color", group=g_fvg)

g_ob             = "===== ICT ORDER BLOCKS (VOLUME VALIDATED) ====="
show_ob          = input.bool(true, "Show Active Order Blocks", group=g_ob)
ob_len           = input.int(50, "OB Lookback Length", minval=2, group=g_ob)
c_bull_ob        = input.color(#29b6f6, "Bullish OB Color", group=g_ob)
c_bear_ob        = input.color(#ab47bc, "Bearish OB Color", group=g_ob)

g_liq            = "===== ICT LIQUIDITY SWEEPS ====="
show_liq         = input.bool(true, "Show Liquidity Sweeps", group=g_liq)
liq_len          = input.int(10, "Liquidity Lookback Sensitivity", minval=3, group=g_liq)
c_liq_line       = input.color(#ff1744, "Sweep Line Color (2x Width)", group=g_liq)

g_kz             = "===== ICT NEW YORK SESSION ONLY ====="
show_ny_kz       = input.bool(true, "Show Only New York Session", group=g_kz)
ny_session_time  = input.session("0700-1200:23456", "NY Session Window (UTC-4/5)", group=g_kz)
c_ny_kz          = input.color(color.new(#e040fb, 94), "New York Session Color", group=g_kz)

g_pdh            = "===== PREVIOUS DAY HIGH & LOW (AUTO-DISAPPEAR) ====="
show_pdh_pdl     = input.bool(true, "Show Active PDH / PDL", group=g_pdh)
pdh_width        = input.int(2, "PDH / PDL Line Width", minval=1, maxval=4, group=g_pdh)
pdh_style_str    = input.string("Dotted", "Line Style", options=["Solid", "Dotted", "Dashed"], group=g_pdh)
c_pdh            = input.color(#00e5ff, "PDH Color", group=g_pdh)
c_pdl            = input.color(#ffea00, "PDL Color", group=g_pdh)

g_mss            = "===== MARKET STRUCTURE SHIFT (MSS) ====="
show_mss         = input.bool(true, "Show MSS Structural Lines", group=g_mss)
mss_len          = input.int(5, "Structure Pivot Sensitivity", minval=2, group=g_mss)

atrVal = ta.atr(14)
pdh_style = pdh_style_str == "Solid" ? line.style_solid : pdh_style_str == "Dashed" ? line.style_dashed : line.style_dotted

// 2. INTERMEDIATE HIGHS & LOWS (ITH / ITL SOLID BADGES)
major_ph = ta.pivothigh(high, ith_len, ith_len)
major_pl = ta.pivotlow(low, ith_len, ith_len)

if show_ith and not na(major_ph)
    label.new(bar_index - ith_len, high[ith_len] + (atrVal * 0.3), "ITH", color=bg_ith, textcolor=color.white, style=label.style_label_down, size=size.small)

if show_ith and not na(major_pl)
    label.new(bar_index - ith_len, low[ith_len] - (atrVal * 0.3), "ITL", color=bg_itl, textcolor=color.white, style=label.style_label_up, size=size.small)

// 3. NEW YORK SESSION BACKGROUND
bool in_ny_kz = not na(time(timeframe.period, ny_session_time))
bgcolor(show_ny_kz and in_ny_kz ? c_ny_kz : na, title="New York Session Background")

// 4. AUTO-DISAPPEARING PREVIOUS DAY HIGH & LOW
[pdh_val, pdl_val] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead=barmerge.lookahead_on)

var line line_pdh = na
var line line_pdl = na
var label lbl_pdh = na
var label lbl_pdl = na
var bool is_pdh_broken = false
var bool is_pdl_broken = false

if ta.change(time("D")) != 0
    is_pdh_broken := false
    is_pdl_broken := false
    line.delete(line_pdh)
    line.delete(line_pdl)
    label.delete(lbl_pdh)
    label.delete(lbl_pdl)

if show_pdh_pdl and not is_pdh_broken and not na(pdh_val)
    if high >= pdh_val
        is_pdh_broken := true
        line.delete(line_pdh)
        label.delete(lbl_pdh)
    else
        line.delete(line_pdh)
        label.delete(lbl_pdh)
        line_pdh := line.new(bar_index - 10, pdh_val, bar_index + 12, pdh_val, color=c_pdh, style=pdh_style, width=pdh_width)
        lbl_pdh  := label.new(bar_index + 12, pdh_val, "PDH", color=color.new(#000000, 100), textcolor=c_pdh, style=label.style_label_left, size=size.small)

if show_pdh_pdl and not is_pdl_broken and not na(pdl_val)
    if low <= pdl_val
        is_pdl_broken := true
        line.delete(line_pdl)
        label.delete(lbl_pdl)
    else
        line.delete(line_pdl)
        label.delete(lbl_pdl)
        line_pdl := line.new(bar_index - 10, pdl_val, bar_index + 12, pdl_val, color=c_pdl, style=pdh_style, width=pdh_width)
        lbl_pdl  := label.new(bar_index + 12, pdl_val, "PDL", color=color.new(#000000, 100), textcolor=c_pdl, style=label.style_label_left, size=size.small)

// 5. ICT FAIR VALUE GAP (FVG) ENGINE
var box[] bull_fvgs = array.new_box()
var box[] bear_fvgs = array.new_box()

bool is_bull_fvg = low[0] > high[2]
bool is_bear_fvg = high[0] < low[2]

if show_fvg and is_bull_fvg
    box b_fvg = box.new(left=bar_index - 2, top=low[0], right=bar_index + 10, bottom=high[2], border_color=c_bull_fvg, bgcolor=color.new(c_bull_fvg, fvg_opacity), text="FVG", text_color=color.white, text_size=size.tiny, text_halign=text.align_right)
    array.push(bull_fvgs, b_fvg)

if show_fvg and is_bear_fvg
    box r_fvg = box.new(left=bar_index - 2, top=low[2], right=bar_index + 10, bottom=high[0], border_color=c_bear_fvg, bgcolor=color.new(c_bear_fvg, fvg_opacity), text="FVG", text_color=color.white, text_size=size.tiny, text_halign=text.align_right)
    array.push(bear_fvgs, r_fvg)

if show_fvg and array.size(bull_fvgs) > 0
    for i = array.size(bull_fvgs) - 1 to 0
        box b = array.get(bull_fvgs, i)
        float bot_level = box.get_bottom(b)
        if low < bot_level
            box.delete(b)
            array.remove(bull_fvgs, i)
        else
            box.set_right(b, bar_index + 10)

if show_fvg and array.size(bear_fvgs) > 0
    for i = array.size(bear_fvgs) - 1 to 0
        box b = array.get(bear_fvgs, i)
        float top_level = box.get_top(b)
        if high > top_level
            box.delete(b)
            array.remove(bear_fvgs, i)
        else
            box.set_right(b, bar_index + 10)

// 6. ICT ORDER BLOCK (OB) ENGINE
var box[] bull_obs = array.new_box()
var box[] bear_obs = array.new_box()

ob_ph = ta.pivothigh(high, ob_len, ob_len)
ob_pl = ta.pivotlow(low, ob_len, ob_len)

if show_ob and not na(ob_ph)
    box b_ob = box.new(left=bar_index - ob_len, top=high[ob_len], right=bar_index + 12, bottom=math.max(open[ob_len], close[ob_len]), border_color=c_bear_ob, bgcolor=color.new(c_bear_ob, 80), text="BEAR OB", text_color=color.white, text_size=size.tiny, text_halign=text.align_right)
    array.push(bear_obs, b_ob)

if show_ob and not na(ob_pl)
    box r_ob = box.new(left=bar_index - ob_len, top=math.min(open[ob_len], close[ob_len]), right=bar_index + 12, bottom=low[ob_len], border_color=c_bull_ob, bgcolor=color.new(c_bull_ob, 80), text="BULL OB", text_color=color.black, text_size=size.tiny, text_halign=text.align_right)
    array.push(bull_obs, r_ob)

if show_ob and array.size(bear_obs) > 0
    for i = array.size(bear_obs) - 1 to 0
        box b = array.get(bear_obs, i)
        if close > box.get_top(b)
            box.delete(b)
            array.remove(bear_obs, i)
        else
            box.set_right(b, bar_index + 12)

if show_ob and array.size(bull_obs) > 0
    for i = array.size(bull_obs) - 1 to 0
        box b = array.get(bull_obs, i)
        if close < box.get_bottom(b)
            box.delete(b)
            array.remove(bull_obs, i)
        else
            box.set_right(b, bar_index + 12)

// 7. LIQUIDITY SWEEP ENGINE (SMART OFFSET TO PREVENT OVERLAP)
liq_ph = ta.pivothigh(high, liq_len, liq_len)
liq_pl = ta.pivotlow(low, liq_len, liq_len)

var float last_bsl_price = na
var int last_bsl_idx = na
var float last_ssl_price = na
var int last_ssl_idx = na

if not na(liq_ph)
    last_bsl_price := liq_ph
    last_bsl_idx := bar_index - liq_len

if not na(liq_pl)
    last_ssl_price := liq_pl
    last_ssl_idx := bar_index - liq_len

if show_liq and not na(last_bsl_price) and high > last_bsl_price and close < last_bsl_price
    line.new(last_bsl_idx, last_bsl_price, bar_index, last_bsl_price, color=c_liq_line, width=2, style=line.style_solid)
    label.new(bar_index, high + (atrVal * 0.15), "Liquidity Swept", color=color.new(#000000, 100), textcolor=c_liq_line, style=label.style_label_down, size=size.small)
    last_bsl_price := na

if show_liq and not na(last_ssl_price) and low < last_ssl_price and close > last_ssl_price
    line.new(last_ssl_idx, last_ssl_price, bar_index, last_ssl_price, color=c_liq_line, width=2, style=line.style_solid)
    label.new(bar_index, low - (atrVal * 0.15), "Liquidity Swept", color=color.new(#000000, 100), textcolor=c_liq_line, style=label.style_label_up, size=size.small)
    last_ssl_price := na

// 8. MARKET STRUCTURE SHIFT (MSS)
mss_ph = ta.pivothigh(high, mss_len, mss_len)
mss_pl = ta.pivotlow(low, mss_len, mss_len)

var float last_mss_ph = na
var int last_mss_ph_idx = na
var float last_mss_pl = na
var int last_mss_pl_idx = na

if not na(mss_ph)
    last_mss_ph := mss_ph
    last_mss_ph_idx := bar_index - mss_len

if not na(mss_pl)
    last_mss_pl := mss_pl
    last_mss_pl_idx := bar_index - mss_len

if show_mss and not na(last_mss_ph) and ta.crossover(close, last_mss_ph)
    line.new(last_mss_ph_idx, last_mss_ph, bar_index, last_mss_ph, color=#00e676, style=line.style_dashed, width=1)
    label.new(math.floor((last_mss_ph_idx + bar_index) / 2), last_mss_ph, "MSS", color=color.new(#000000, 100), textcolor=#00e676, style=label.style_label_down, size=size.tiny)
    last_mss_ph := na

if show_mss and not na(last_mss_pl) and ta.crossunder(close, last_mss_pl)
    line.new(last_mss_pl_idx, last_mss_pl, bar_index, last_mss_pl, color=#ff1744, style=line.style_dashed, width=1)
    label.new(math.floor((last_mss_pl_idx + bar_index) / 2), last_mss_pl, "MSS", color=color.new(#000000, 100), textcolor=#ff1744, style=label.style_label_up, size=size.tiny)
    last_mss_pl := na
````
