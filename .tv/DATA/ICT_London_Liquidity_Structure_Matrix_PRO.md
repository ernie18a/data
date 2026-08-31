<!-- tradingview-pine-id: PUB;7500b46777f547fdb87420ef8f56151c -->
<!-- tradingviewscripts-format: 1 -->
# ICT London Liquidity & Structure Matrix PRO

Source: https://www.tradingview.com/script/nGOIicck-ICT-London-Liquidity-Structure-Matrix-PRO/

## Description

ICT London Liquidity & Structure Matrix PRO

ICT London Liquidity & Structure Matrix PRO is an ultra clean, professional charting tool built for traders practicing Smart Money Concepts and ICT methodologies. It isolates macro pivot points with clean blank badges, tracks Asian liquidity boundaries, highlights London Killzone sessions, and projects auto disappearing daily key levels.

Key Features Overview

1. Major High and Low Blank Badges
Marks key structural pivot extremes using clean, minimal solid badges without distracting text overlays. Major highs are marked with solid red badges, and major lows are marked with solid green badges for instant market direction identification.

2. Auto Mitigating Previous Day High and Low
Projects active daily boundaries across your chart. Previous Day High and Previous Day Low levels automatically clean up and vanish the moment price touches or mitigates them.

3. Clean Asian Session High and Low Boundaries
Tracks Asian range consolidation levels with subtle dashed lines and right aligned text labels, providing clear session liquidity targets.

4. Exclusive London Killzone Highlight
Keeps chart aesthetics clean by displaying a single, light background overlay strictly for the high volatility London Session window.

5. Dynamic Auto Mitigating Fair Value Gaps
Automatically identifies bullish and bearish price imbalances across all timeframes. Unmitigated imbalance boxes vanish as soon as price fills the gap.

How to Use

Step 1: Locate Structural Pivots
Identify major highs with red badges and major lows with green badges to assess macro trend bias and key liquidity pools.

Step 2: Monitor Asian Boundaries
Observe Asian High and Low lines created prior to the European open to anticipate potential liquidity sweeps.

Step 3: Execute During London Session
Focus on trade opportunities forming inside the highlighted London Killzone window upon retaps into active Fair Value Gaps.

Settings Overview

Pivot Badge Settings
- Show Major High / Low Blank Labels: Toggle visibility of pivot badges.
- Major Pivot Sensitivity Length: Adjust the pivot lookback period.

Previous Day High and Low Settings
- Show Active PDH / PDL: Toggle display of daily levels.
- Line Width and Style: Customize thickness and choosing between solid, dotted, or dashed lines.

Asian Session Settings
- Show Asian High & Low Levels: Toggle visibility of Asian boundary lines.

Session Highlight Settings
- Show London Killzone Highlight Only: Toggle background highlight for London trading hours.

Disclaimer
This script is built strictly for educational, analytical, and charting enhancement purposes. It does not provide financial advice, trade recommendations, or guaranteed results. Always apply proper risk management principles.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ACE_Chart_Logic

//@version=6
// ==============================================================================================
//  I C T   L O N D O N   L I Q U I D I T Y   &   S T R U C T U R E   M A T R I X   P R O
// ==============================================================================================

indicator("ICT London Liquidity & Structure Matrix PRO", "London Matrix PRO", overlay = true, max_lines_count = 500, max_boxes_count = 100, max_labels_count = 500)

// 1. INPUTS & CONFIGURATION PANEL
g_london         = "===== LONDON KILLZONE (ONLY SESSION BG) ====="
show_london      = input.bool(true, "Show London Killzone Highlight Only", group=g_london)
london_time      = input.session("0200-0500:23456", "London Session Window (UTC-4/5)", group=g_london)
c_london_bg      = input.color(color.new(#e040fb, 95), "London Killzone Color", group=g_london)

g_pivots         = "===== MAJOR SWING HIGH / LOW BLANK BADGES ====="
show_pivots      = input.bool(true, "Show Major High / Low Blank Labels", group=g_pivots)
pivot_len        = input.int(15, "Major Pivot Sensitivity Length", minval=5, maxval=50, group=g_pivots)
c_high_badge     = input.color(#ff1744, "Major High Label Color (Red)", group=g_pivots)
c_low_badge      = input.color(#00e676, "Major Low Label Color (Green)", group=g_pivots)

g_asia           = "===== ASIAN SESSION RANGE ====="
show_asia        = input.bool(true, "Show Asian High & Low Levels", group=g_asia)
asia_time        = input.session("1900-0000:23456", "Asian Range Hours", group=g_asia)
c_asia_h         = input.color(#00e5ff, "Asian High Line Color", group=g_asia)
c_asia_l         = input.color(#ffea00, "Asian Low Line Color", group=g_asia)

g_pdh            = "===== PREVIOUS DAY HIGH & LOW (AUTO-DISAPPEAR) ====="
show_pdh_pdl     = input.bool(true, "Show Active PDH / PDL", group=g_pdh)
pdh_width        = input.int(2, "Line Width", minval=1, maxval=4, group=g_pdh)
pdh_style_str    = input.string("Dotted", "Line Style", options=["Solid", "Dotted", "Dashed"], group=g_pdh)
c_pdh            = input.color(#00e5ff, "PDH Color", group=g_pdh)
c_pdl            = input.color(#ffea00, "PDL Color", group=g_pdh)

g_fvg            = "===== ICT FAIR VALUE GAPS (AUTO-MITIGATED) ====="
show_fvg         = input.bool(true, "Show Active Imbalance FVGs", group=g_fvg)
fvg_opacity      = input.int(88, "FVG Fill Transparency (0-100)", minval=0, maxval=100, group=g_fvg)
c_bull_fvg       = input.color(#00e676, "Bullish FVG Color", group=g_fvg)
c_bear_fvg       = input.color(#ff1744, "Bearish FVG Color", group=g_fvg)

atrVal = ta.atr(14)
pdh_style = pdh_style_str == "Solid" ? line.style_solid : pdh_style_str == "Dashed" ? line.style_dashed : line.style_dotted

// 2. LONDON KILLZONE HIGHLIGHT ONLY
bool in_london = not na(time(timeframe.period, london_time))
bgcolor(show_london and in_london ? c_london_bg : na, title="London Killzone Background")

// 3. MAJOR HIGH & LOW BLANK BADGE LABELS (NO TEXT, CLEAN)
major_ph = ta.pivothigh(high, pivot_len, pivot_len)
major_pl = ta.pivotlow(low, pivot_len, pivot_len)

if show_pivots and not na(major_ph)
    label.new(bar_index - pivot_len, high[pivot_len] + (atrVal * 0.25), " ", color=c_high_badge, style=label.style_label_down, size=size.tiny)

if show_pivots and not na(major_pl)
    label.new(bar_index - pivot_len, low[pivot_len] - (atrVal * 0.25), " ", color=c_low_badge, style=label.style_label_up, size=size.tiny)

// 4. ASIAN SESSION HIGH & LOW RANGE
bool in_asia = not na(time(timeframe.period, asia_time))

var float asia_h = na
var float asia_l = na
var int asia_start_bar = na

var line line_asia_h = na
var line line_asia_l = na
var label lbl_asia_h = na
var label lbl_asia_l = na

if in_asia and not in_asia[1]
    asia_h := high
    asia_l := low
    asia_start_bar := bar_index
    line.delete(line_asia_h)
    line.delete(line_asia_l)
    label.delete(lbl_asia_h)
    label.delete(lbl_asia_l)

if in_asia
    asia_h := math.max(asia_h, high)
    asia_l := math.min(asia_l, low)

if not in_asia and in_asia[1] and show_asia
    line_asia_h := line.new(asia_start_bar, asia_h, bar_index + 12, asia_h, color=c_asia_h, style=line.style_dashed, width=1)
    line_asia_l := line.new(asia_start_bar, asia_l, bar_index + 12, asia_l, color=c_asia_l, style=line.style_dashed, width=1)
    lbl_asia_h  := label.new(bar_index + 12, asia_h, "Asian High", color=color.new(#000000, 100), textcolor=c_asia_h, style=label.style_label_left, size=size.small)
    lbl_asia_l  := label.new(bar_index + 12, asia_l, "Asian Low", color=color.new(#000000, 100), textcolor=c_asia_l, style=label.style_label_left, size=size.small)

// 5. AUTO-DISAPPEARING PREVIOUS DAY HIGH & LOW
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

// 6. DYNAMIC AUTO-MITIGATED FAIR VALUE GAPS (FVG)
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
        if low < box.get_bottom(b)
            box.delete(b)
            array.remove(bull_fvgs, i)
        else
            box.set_right(b, bar_index + 10)

if show_fvg and array.size(bear_fvgs) > 0
    for i = array.size(bear_fvgs) - 1 to 0
        box b = array.get(bear_fvgs, i)
        if high > box.get_top(b)
            box.delete(b)
            array.remove(bear_fvgs, i)
        else
            box.set_right(b, bar_index + 10)
````
