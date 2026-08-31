<!-- tradingview-pine-id: PUB;83add2adb64642c3806c0bf621805e36 -->
<!-- tradingviewscripts-format: 1 -->
# ICT Dynamic Entry Model & Structure Matrix PRO

Source: https://www.tradingview.com/script/PS3eDAz4-ICT-Dynamic-Entry-Model-Structure-Matrix-PRO/

## Description

ICT Dynamic Entry Model & Structure Matrix PRO

ICT Dynamic Entry Model & Structure Matrix PRO is a clean, professional institutional charting script designed for traders following ICT mentorship principles and Smart Money Concepts. It delivers precise swing anchored market structure lines, dynamic trend candle themes, auto disappearing key levels, and gold highlighted expansion candles.

Key Features Overview

1. Precision Anchored BOS and CHoCH Structure
Market structure lines start exactly from the precise swing high or swing low origin price point. Text labels are positioned cleanly in the middle center of structure lines to avoid overlap with candlesticks.

2. Smart Trend Candle Engine
Driven by Intermediate Term High and Low levels. Once a red ITH prints, subsequent price candles dynamically adopt a solid bearish color scheme. When a green ITL prints, candles automatically convert to a bullish color scheme.

3. Gold Glowing FVG Expansion Candle Highlight
Identifies high momentum Fair Value Gap expansion candles, coloring the specific impulse candle in a distinct glowing gold yellow shade for instant institutional displacement detection.

4. Major ITH and ITL Level Badges
Features solid red Intermediate Term High badges and solid green Intermediate Term Low badges strictly at macro structural extremes.

5. Auto Disappearing Previous Day Boundaries
Tracks active Previous Day High and Previous Day Low boundaries. Daily lines automatically clean up and vanish as soon as price breaks or mitigates the level.

How to Use

Step 1: Identify Macro Shift
Look for green ITL badges for bullish bias or red ITH badges for bearish bias, which automatically adapts your overall candle colors.

Step 2: Monitor Centered Structure Signals
Observe precise dashed Break of Structure lines and solid Change of Character lines anchored directly from swing points with center aligned text.

Step 3: Spot Institutional Displacement
Identify gold glowing expansion candles that signal high volume displacement creating active Fair Value Gaps.

Settings Overview

Moving Average Settings
- Show Dual Moving Averages: Toggle visibility of EMAs.
- Period and Thickness Settings: Customize fast/slow periods and line width.

Market Structure Settings
- Show Precision BOS & CHoCH: Toggle centered structural lines.
- Sensitivity Period: Adjust pivot lookback calculations.

Smart Candle Settings
- Enable Smart Trend & Gold FVG Candles: Toggle dynamic trend colors and gold FVG expansion highlights.

Previous Day High and Low Settings
- Show Active PDH / PDL: Toggle display of auto disappearing daily key levels.

Entry Zone Settings
- Show Active Entry Zones: Toggle entry model rectangles and customize zone display text, text color, and fill opacity.

Disclaimer
This script is created strictly for educational, analytical, and charting enhancement purposes. It does not provide financial advice, trade recommendations, or guaranteed results. Always practice proper risk management.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Dark_Ace_Master

//@version=6
// ==============================================================================================
//  I C T   D Y N A M I C   E N T R Y   M O D E L   &   S T R U C T U R E   M A T R I X   P R O
// ==============================================================================================

indicator("ICT Dynamic Entry Model & Structure Matrix PRO", "ICT Engine Ultimate PRO", overlay = true, max_lines_count = 500, max_boxes_count = 100, max_labels_count = 500)

// 1. INPUTS & CONFIGURATION PANEL

// A. Moving Averages Inputs
g_ma             = "===== DUAL MOVING AVERAGE CROSSOVER ====="
show_ma          = input.bool(true, "Show Dual Moving Averages", group=g_ma)
fast_ma_len      = input.int(9, "Fast EMA Period", minval=1, group=g_ma)
slow_ma_len      = input.int(21, "Slow EMA Period", minval=1, group=g_ma)
c_fast_ma        = input.color(#00b0ff, "Fast EMA Color", group=g_ma)
c_slow_ma        = input.color(#ff1744, "Slow EMA Color", group=g_ma)
ma_width         = input.int(2, "MA Line Thickness", minval=1, maxval=4, group=g_ma)

// B. Market Structure Inputs (Centered Text & Precise Anchor)
g_struct         = "===== MARKET STRUCTURE (PRECISION BOS / CHoCH) ====="
show_struct      = input.bool(true, "Show Precision BOS & CHoCH", group=g_struct)
struct_len       = input.int(10, "Structure Sensitivity Period", minval=3, maxval=50, group=g_struct)
c_bos            = input.color(#00e5ff, "BOS Line Color", group=g_struct)
c_choch          = input.color(#ff6d00, "CHoCH Line Color", group=g_struct)

// C. Major ITH & ITL Inputs
g_ith_itl        = "===== MAJOR ITH / ITL LEVEL BADGES ====="
show_ith_itl     = input.bool(true, "Show Major ITH / ITL Badges", group=g_ith_itl)
ith_itl_sens     = input.int(20, "Major Pivot Sensitivity (Lookback)", minval=5, maxval=50, group=g_ith_itl)
c_ith            = input.color(#d50000, "ITH Badge Color (Red)", group=g_ith_itl)
c_itl            = input.color(#00c853, "ITL Badge Color (Green)", group=g_ith_itl)

// D. Smart Trend & Gold FVG Expansion Candles
g_candle         = "===== SMART DYNAMIC CANDLE COLORING ====="
show_smart_c     = input.bool(true, "Enable Smart Trend & Gold FVG Candles", group=g_candle)
c_bull_trend     = input.color(#00e676, "ITL Bullish Trend Candle Color", group=g_candle)
c_bear_trend     = input.color(#ff1744, "ITH Bearish Trend Candle Color", group=g_candle)
c_fvg_gold       = input.color(#ffd700, "Gold Glowing FVG Expansion Candle Color", group=g_candle)

// E. Auto-Disappearing PDH & PDL Inputs
g_pdh            = "===== PREVIOUS DAY HIGH & LOW (AUTO-DISAPPEAR) ====="
show_pdh_pdl     = input.bool(true, "Show Active PDH / PDL", group=g_pdh)
pdh_width        = input.int(1, "PDH / PDL Line Thickness", minval=1, maxval=4, group=g_pdh)
c_pdh            = input.color(#00e5ff, "PDH Line Color", group=g_pdh)
c_pdl            = input.color(#ffea00, "PDL Line Color", group=g_pdh)

// F. Dynamic Entry Model Zone Settings
g_zone           = "===== INSTITUTIONAL ENTRY ZONES & TEXT SETTINGS ====="
show_zones       = input.bool(true, "Show Active Entry Zones", group=g_zone)
zone_opacity     = input.int(88, "Zone Fill Transparency (0-100)", minval=0, maxval=100, group=g_zone)
c_bull_zone      = input.color(#00e676, "Bullish Zone Color", group=g_zone)
c_bear_zone      = input.color(#ff1744, "Bearish Zone Color", group=g_zone)
c_zone_border    = input.color(color.new(#000000, 100), "Zone Border Color", group=g_zone)

zone_text        = input.string("Order Block", "Zone Display Text", group=g_zone)
c_zone_text      = input.color(#ffffff, "Zone Text Color", group=g_zone)
zone_txt_size    = input.string("tiny", "Zone Text Size", options=["tiny", "small", "normal"], group=g_zone)

atrVal = ta.atr(14)
txt_size_enum = zone_txt_size == "tiny" ? size.tiny : zone_txt_size == "small" ? size.small : size.normal

// 2. DUAL MOVING AVERAGE CROSSOVER
float fast_ema = ta.ema(close, fast_ma_len)
float slow_ema = ta.ema(close, slow_ma_len)

plot(show_ma ? fast_ema : na, "Fast EMA", color=c_fast_ma, linewidth=ma_width)
plot(show_ma ? slow_ema : na, "Slow EMA", color=c_slow_ma, linewidth=ma_width)

// 3. MAJOR ITH & ITL LEVEL BADGES & TREND SWITCHING
ph_m = ta.pivothigh(high, ith_itl_sens, ith_itl_sens)
pl_m = ta.pivotlow(low, ith_itl_sens, ith_itl_sens)

var int trend_state = 0 // 1 = Bullish (ITL Active), -1 = Bearish (ITH Active)

if not na(ph_m)
    trend_state := -1
if not na(pl_m)
    trend_state := 1

if show_ith_itl and not na(ph_m)
    int idx = bar_index - ith_itl_sens
    label.new(idx, high[ith_itl_sens] + (atrVal * 0.25), "ITH", color=c_ith, textcolor=color.white, style=label.style_label_down, size=size.small)

if show_ith_itl and not na(pl_m)
    int idx = bar_index - ith_itl_sens
    label.new(idx, low[ith_itl_sens] - (atrVal * 0.25), "ITL", color=c_itl, textcolor=color.white, style=label.style_label_up, size=size.small)

// 4. FVG EXPANSION CANDLE DETECTION
bool is_bull_fvg_candle = (low[0] > high[2]) and (close > open)
bool is_bear_fvg_candle = (high[0] < low[2]) and (close < open)
bool is_fvg_expansion = is_bull_fvg_candle or is_bear_fvg_candle

// 5. DYNAMIC SMART CANDLE COLORING
color candle_col = is_fvg_expansion ? c_fvg_gold : (trend_state == 1 ? c_bull_trend : (trend_state == -1 ? c_bear_trend : (close >= open ? c_bull_trend : c_bear_trend)))

plotcandle(show_smart_c ? open : na, show_smart_c ? high : na, show_smart_c ? low : na, show_smart_c ? close : na, title="Smart Trend Candles", color=candle_col, wickcolor=candle_col, bordercolor=candle_col)

// 6. PRECISION MARKET STRUCTURE (SWING ANCHORED & CENTERED TEXT)
ph_s = ta.pivothigh(high, struct_len, struct_len)
pl_s = ta.pivotlow(low, struct_len, struct_len)

var float last_ph_s = na
var int last_ph_idx = na
var float last_pl_s = na
var int last_pl_idx = na

if not na(ph_s)
    last_ph_s := ph_s
    last_ph_idx := bar_index - struct_len

if not na(pl_s)
    last_pl_s := pl_s
    last_pl_idx := bar_index - struct_len

if show_struct and not na(last_ph_s) and ta.crossover(close, last_ph_s)
    line.new(last_ph_idx, last_ph_s, bar_index, last_ph_s, color=c_bos, style=line.style_dashed, width=1)
    int mid_idx = math.floor((last_ph_idx + bar_index) / 2)
    label.new(mid_idx, last_ph_s, "BOS", color=color.new(#000000, 100), textcolor=c_bos, style=label.style_label_center, size=size.tiny)
    last_ph_s := na

if show_struct and not na(last_pl_s) and ta.crossunder(close, last_pl_s)
    line.new(last_pl_idx, last_pl_s, bar_index, last_pl_s, color=c_choch, style=line.style_solid, width=1)
    int mid_idx = math.floor((last_pl_idx + bar_index) / 2)
    label.new(mid_idx, last_pl_s, "CHoCH", color=color.new(#000000, 100), textcolor=c_choch, style=label.style_label_center, size=size.tiny)
    last_pl_s := na

// 7. AUTO-DISAPPEARING PREVIOUS DAY HIGH & LOW
[pdh_val, pdl_val] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead=barmerge.lookahead_on)

var line line_pdh = na
var line line_pdl = na
var label lbl_pdh = na
var label lbl_pdl = na
var bool pdh_broken = false
var bool pdl_broken = false

if ta.change(time("D")) != 0
    pdh_broken := false
    pdl_broken := false
    line.delete(line_pdh)
    line.delete(line_pdl)
    label.delete(lbl_pdh)
    label.delete(lbl_pdl)

if show_pdh_pdl and not pdh_broken and not na(pdh_val)
    if high >= pdh_val
        pdh_broken := true
        line.delete(line_pdh)
        label.delete(lbl_pdh)
    else
        line.delete(line_pdh)
        label.delete(lbl_pdh)
        line_pdh := line.new(bar_index - 8, pdh_val, bar_index + 10, pdh_val, color=c_pdh, style=line.style_dashed, width=pdh_width)
        lbl_pdh  := label.new(bar_index + 10, pdh_val, "PDH", color=color.new(#000000, 100), textcolor=c_pdh, style=label.style_label_left, size=size.tiny)

if show_pdh_pdl and not pdl_broken and not na(pdl_val)
    if low <= pdl_val
        pdl_broken := true
        line.delete(line_pdl)
        label.delete(lbl_pdl)
    else
        line.delete(line_pdl)
        label.delete(lbl_pdl)
        line_pdl := line.new(bar_index - 8, pdl_val, bar_index + 10, pdl_val, color=c_pdl, style=line.style_dashed, width=pdh_width)
        lbl_pdl  := label.new(bar_index + 10, pdl_val, "PDL", color=color.new(#000000, 100), textcolor=c_pdl, style=label.style_label_left, size=size.tiny)

// 8. DYNAMIC INSTITUTIONAL ENTRY ZONES
var box[] bull_boxes = array.new_box()
var box[] bear_boxes = array.new_box()

if show_zones and is_bull_fvg_candle
    if array.size(bull_boxes) >= 3
        box.delete(array.shift(bull_boxes))
    box b = box.new(left=bar_index - 2, top=low[0], right=bar_index + 10, bottom=high[2], border_color=c_zone_border, bgcolor=color.new(c_bull_zone, zone_opacity), text=zone_text, text_color=c_zone_text, text_size=txt_size_enum, text_halign=text.align_right)
    array.push(bull_boxes, b)

if show_zones and is_bear_fvg_candle
    if array.size(bear_boxes) >= 3
        box.delete(array.shift(bear_boxes))
    box b = box.new(left=bar_index - 2, top=low[2], right=bar_index + 10, bottom=high[0], border_color=c_zone_border, bgcolor=color.new(c_bear_zone, zone_opacity), text=zone_text, text_color=c_zone_text, text_size=txt_size_enum, text_halign=text.align_right)
    array.push(bear_boxes, b)

if show_zones and array.size(bull_boxes) > 0
    for i = array.size(bull_boxes) - 1 to 0
        box b = array.get(bull_boxes, i)
        if low < box.get_bottom(b)
            box.delete(b)
            array.remove(bull_boxes, i)
        else
            box.set_right(b, bar_index + 8)

if show_zones and array.size(bear_boxes) > 0
    for i = array.size(bear_boxes) - 1 to 0
        box b = array.get(bear_boxes, i)
        if high > box.get_top(b)
            box.delete(b)
            array.remove(bear_boxes, i)
        else
            box.set_right(b, bar_index + 8)
````
