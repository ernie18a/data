# LTF Imbalance V2

- url: https://www.tradingview.com/script/8oQB5BnU-LTF-Imbalance-V2/
- type: indicator
- pine_id: PUB;40143fa838e14ff78a40f57137fa7a15
- version: 1.0

## Description

LTF Imbalances
A multi-timeframe Fair Value Gap (FVG) indicator that lets you view lower timeframe imbalances from any higher timeframe chart. Designed for SMC and ICT traders who need precision entry confluences without switching charts.
What it does
Scans five lower timeframes simultaneously — 1s, 5s, 15s, 30s, and 1m — and plots unmitigated imbalance zones directly on your chart. Each timeframe has its own colour and can be toggled independently, so you can layer up exactly the confluences you want without visual noise.
Key Features

Multi-TF FVG Detection — Identifies bullish and bearish imbalances across all five timeframes in real time using request.security_lower_tf()
Three Mitigation Modes — Choose how a zone is considered filled: close inside the gap, wick into the gap, or wick fully through. Mitigated boxes are automatically deleted to keep the chart clean
Minimum Gap Size Filter — Set a pip/point threshold to eliminate micro noise. Works across forex, indices, and commodities (recommended: 1.0 for forex, 5–20 for indices)
Pivot Proximity Filter — Optionally restrict displayed zones to only those forming near structural pivot highs and lows, helping focus attention on the highest-probability imbalances
Legend Table — An on-chart table showing each timeframe's status (ON/OFF) with a live colour swatch, fully configurable in position and size
Clean Labelling — Each zone is labelled with its timeframe and direction (▲ bullish / ▼ bearish) for instant identification at a glance

How to use it
Load the indicator on any timeframe higher than 1s. Toggle the timeframes you want to monitor, set your minimum gap size for the instrument you're trading, and optionally enable the pivot proximity filter for confluence-only zones. Use alongside your preferred market structure or order block indicator for high-probability SMC entries.
Notes

Requires a TradingView plan that supports request.security_lower_tf() (Essential or higher)
1s data is only available on supported symbols and brokers
Best used on the 1m–15m chart during active sessions such as London Open or New York Open

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © kevTheTrader42618

// ============================================================
// LTF Imbalances — Kevin
// View 1s / 5s / 15s / 30s / 1m imbalances from any HTF
// Features: Mitigation (delete only) + Pivot proximity filter
// ============================================================
//@version=6
indicator("LTF Imbalance V2", overlay=true, max_boxes_count=500, max_labels_count=500, dynamic_requests=true)

// ─────────────────────────────────────────
// INPUTS — Timeframe Toggles
// ─────────────────────────────────────────
grp_tf = "Timeframe Toggles"
show_1s  = input.bool(true, "1 Second",  group=grp_tf, inline="1s")
col_1s   = input.color(color.new(#00e5ff, 70), "", group=grp_tf, inline="1s")
show_5s  = input.bool(true, "5 Second",  group=grp_tf, inline="5s")
col_5s   = input.color(color.new(#00bcd4, 70), "", group=grp_tf, inline="5s")
show_15s = input.bool(true, "15 Second", group=grp_tf, inline="15s")
col_15s  = input.color(color.new(#9c27b0, 70), "", group=grp_tf, inline="15s")
show_30s = input.bool(true, "30 Second", group=grp_tf, inline="30s")
col_30s  = input.color(color.new(#ff9800, 70), "", group=grp_tf, inline="30s")
show_1m  = input.bool(true, "1 Minute",  group=grp_tf, inline="1m")
col_1m   = input.color(color.new(#f44336, 70), "", group=grp_tf, inline="1m")

// ─────────────────────────────────────────
// INPUTS — Mitigation
// ─────────────────────────────────────────
grp_mit = "Mitigation"
use_mitigation = input.bool(true, "Delete mitigated boxes", group=grp_mit)
mit_mode = input.string("Wick into gap", "Mitigated when price...", options=["Close inside gap", "Wick into gap", "Wick fully through"], group=grp_mit,
     tooltip="Close inside gap: close must be inside the zone.\nWick into gap: any wick entering the zone triggers mitigation.\nWick fully through: price must pass completely through the zone.")

// ─────────────────────────────────────────
// INPUTS — FVG Size Filter
// ─────────────────────────────────────────
grp_flt = "FVG Filter"
min_gap_pips = input.float(1.0, "Minimum gap size (pips / points)", minval=0.0, step=0.1, group=grp_flt,
     tooltip="Filters noise. Forex: 1.0 = 1 pip. Indices: try 5-20.")

// ─────────────────────────────────────────
// INPUTS — Pivot Proximity Filter
// ─────────────────────────────────────────
grp_piv = "Pivot Proximity Filter"
use_pivot_filter = input.bool(false, "Only show imbalances near pivots", group=grp_piv)
pivot_left       = input.int(10, "Pivot lookback left",  minval=2, maxval=50, group=grp_piv)
pivot_right      = input.int(5,  "Pivot lookback right", minval=1, maxval=20, group=grp_piv)
pivot_prox_pct   = input.float(0.3, "Proximity %", minval=0.01, maxval=5.0, step=0.05, group=grp_piv)
show_pivots      = input.bool(true, "Show pivot lines", group=grp_piv)

// ─────────────────────────────────────────
// INPUTS — Display
// ─────────────────────────────────────────
grp_disp = "Display"
extend_right = input.bool(true, "Extend boxes right", group=grp_disp)
show_labels  = input.bool(true, "Show TF labels",     group=grp_disp)
box_width    = input.int(40, "Box width (bars, if not extended)", minval=5, maxval=500, group=grp_disp)
ext          = extend_right ? extend.right : extend.none

// ─────────────────────────────────────────
// INPUTS — Legend Table
// ─────────────────────────────────────────
grp_tbl = "Legend Table"
show_table    = input.bool(true, "Show legend table", group=grp_tbl)
tbl_position  = input.string("Top Right", "Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Top Center", "Bottom Center"], group=grp_tbl)
tbl_text_size = input.string("Small", "Text size", options=["Tiny", "Small", "Normal"], group=grp_tbl)

// ─────────────────────────────────────────
// PIVOT DETECTION
// ─────────────────────────────────────────
ph = ta.pivothigh(high, pivot_left, pivot_right)
pl = ta.pivotlow(low,   pivot_left, pivot_right)

var float[] pivot_levels = array.new_float(0)

if not na(ph)
    array.unshift(pivot_levels, ph)
    if array.size(pivot_levels) > 50
        array.pop(pivot_levels)

if not na(pl)
    array.unshift(pivot_levels, pl)
    if array.size(pivot_levels) > 50
        array.pop(pivot_levels)

if show_pivots and use_pivot_filter
    if not na(ph)
        line.new(bar_index - pivot_right, ph, bar_index, ph,
             color=color.new(color.yellow, 40), width=1, style=line.style_dotted, extend=extend.right)
    if not na(pl)
        line.new(bar_index - pivot_right, pl, bar_index, pl,
             color=color.new(color.yellow, 40), width=1, style=line.style_dotted, extend=extend.right)

// ─────────────────────────────────────────
// FUNCTION: Near pivot check
// ─────────────────────────────────────────
f_near_pivot(price) =>
    bool near = false
    if array.size(pivot_levels) > 0
        for i = 0 to array.size(pivot_levels) - 1
            piv = array.get(pivot_levels, i)
            if math.abs(price - piv) / piv * 100 <= pivot_prox_pct
                near := true
                break
    near

// ─────────────────────────────────────────
// BOX STORAGE
// ─────────────────────────────────────────
var box[]   active_boxes = array.new<box>(0)
var float[] box_tops     = array.new_float(0)
var float[] box_bottoms  = array.new_float(0)
var bool[]  box_is_bull  = array.new_bool(0)

// ─────────────────────────────────────────
// FUNCTION: Add a box if it passes filters
// ─────────────────────────────────────────
f_add_box(top, bottom, col, tf_label, is_bull) =>
    gap_size = (top - bottom) / syminfo.mintick
    if gap_size >= min_gap_pips
        midpoint = (top + bottom) / 2.0
        draw = use_pivot_filter ? f_near_pivot(midpoint) : true
        if draw
            b = box.new(bar_index, top, bar_index + box_width, bottom,
                 border_color=col, bgcolor=col, border_width=1, extend=ext)
            if show_labels
                lbl_style = is_bull ? label.style_label_down : label.style_label_up
                lbl_y     = is_bull ? top : bottom
                label.new(bar_index, lbl_y, tf_label + (is_bull ? " ▲" : " ▼"),
                     color=color.new(color.black, 100), textcolor=col,
                     style=lbl_style, size=size.tiny)
            array.push(active_boxes, b)
            array.push(box_tops,     top)
            array.push(box_bottoms,  bottom)
            array.push(box_is_bull,  is_bull)

// ─────────────────────────────────────────
// MITIGATION CHECK
// ─────────────────────────────────────────
if use_mitigation and array.size(active_boxes) > 0
    i = array.size(active_boxes) - 1
    while i >= 0
        top     = array.get(box_tops,    i)
        bottom  = array.get(box_bottoms, i)
        is_bull = array.get(box_is_bull, i)

        mitigated = false

        if mit_mode == "Close inside gap"
            mitigated := close <= top and close >= bottom

        else if mit_mode == "Wick into gap"
            if is_bull
                mitigated := low <= top and high >= bottom
            else
                mitigated := high >= bottom and low <= top

        else // "Wick fully through"
            if is_bull
                mitigated := low < bottom
            else
                mitigated := high > top

        if mitigated
            box.delete(array.get(active_boxes, i))
            array.remove(active_boxes, i)
            array.remove(box_tops,     i)
            array.remove(box_bottoms,  i)
            array.remove(box_is_bull,  i)

        i -= 1

// ─────────────────────────────────────────
// FUNCTION: Process LTF arrays and draw FVGs
// ─────────────────────────────────────────
f_process(ltf_high, ltf_low, show, col, tf_label) =>
    if show and array.size(ltf_high) >= 3 and array.size(ltf_low) >= 3
        h0 = array.get(ltf_high, 0)
        l0 = array.get(ltf_low,  0)
        h2 = array.get(ltf_high, 2)
        l2 = array.get(ltf_low,  2)
        if l0 > h2
            f_add_box(l0, h2, col, tf_label, true)
        if h0 < l2
            f_add_box(l2, h0, col, tf_label, false)

// ─────────────────────────────────────────
// SECURITY CALLS
// ─────────────────────────────────────────
ltf_high_1s  = timeframe.in_seconds() > 1  ? request.security_lower_tf(syminfo.tickerid, "1S",  high) : array.new_float(0)
ltf_low_1s   = timeframe.in_seconds() > 1  ? request.security_lower_tf(syminfo.tickerid, "1S",  low)  : array.new_float(0)

ltf_high_5s  = timeframe.in_seconds() > 5  ? request.security_lower_tf(syminfo.tickerid, "5S",  high) : array.new_float(0)
ltf_low_5s   = timeframe.in_seconds() > 5  ? request.security_lower_tf(syminfo.tickerid, "5S",  low)  : array.new_float(0)

ltf_high_15s = timeframe.in_seconds() > 15 ? request.security_lower_tf(syminfo.tickerid, "15S", high) : array.new_float(0)
ltf_low_15s  = timeframe.in_seconds() > 15 ? request.security_lower_tf(syminfo.tickerid, "15S", low)  : array.new_float(0)

ltf_high_30s = timeframe.in_seconds() > 30 ? request.security_lower_tf(syminfo.tickerid, "30S", high) : array.new_float(0)
ltf_low_30s  = timeframe.in_seconds() > 30 ? request.security_lower_tf(syminfo.tickerid, "30S", low)  : array.new_float(0)

ltf_high_1m  = timeframe.in_seconds() > 60 ? request.security_lower_tf(syminfo.tickerid, "1",   high) : array.new_float(0)
ltf_low_1m   = timeframe.in_seconds() > 60 ? request.security_lower_tf(syminfo.tickerid, "1",   low)  : array.new_float(0)

// ─────────────────────────────────────────
// DRAW FVGs
// ─────────────────────────────────────────
f_process(ltf_high_1s,  ltf_low_1s,  show_1s,  col_1s,  "1s")
f_process(ltf_high_5s,  ltf_low_5s,  show_5s,  col_5s,  "5s")
f_process(ltf_high_15s, ltf_low_15s, show_15s, col_15s, "15s")
f_process(ltf_high_30s, ltf_low_30s, show_30s, col_30s, "30s")
f_process(ltf_high_1m,  ltf_low_1m,  show_1m,  col_1m,  "1m")

// ─────────────────────────────────────────
// LEGEND TABLE
// ─────────────────────────────────────────
if show_table and barstate.islast
    // Resolve position
    var pos = position.top_right
    if tbl_position == "Top Right"
        pos := position.top_right
    else if tbl_position == "Top Left"
        pos := position.top_left
    else if tbl_position == "Bottom Right"
        pos := position.bottom_right
    else if tbl_position == "Bottom Left"
        pos := position.bottom_left
    else if tbl_position == "Top Center"
        pos := position.top_center
    else if tbl_position == "Bottom Center"
        pos := position.bottom_center

    // Resolve text size
    var sz = size.small
    if tbl_text_size == "Tiny"
        sz := size.tiny
    else if tbl_text_size == "Small"
        sz := size.small
    else if tbl_text_size == "Normal"
        sz := size.normal

    // Build table: header + 5 TF rows = 6 rows, 3 cols (Swatch | TF | Status)
    tbl = table.new(pos, 3, 6,
         bgcolor        = color.new(color.black, 70),
         border_color   = color.new(color.white, 60),
         border_width   = 1,
         frame_color    = color.new(color.white, 40),
         frame_width    = 1)

    // Header row
    table.cell(tbl, 0, 0, "●",          text_color=color.white, text_size=sz, bgcolor=color.new(color.black, 90))
    table.cell(tbl, 1, 0, "TF",         text_color=color.white, text_size=sz, bgcolor=color.new(color.black, 90))
    table.cell(tbl, 2, 0, "Status",     text_color=color.white, text_size=sz, bgcolor=color.new(color.black, 90))

    // Helper: solid version of the user colour for the swatch cell
    col_1s_solid  = color.new(col_1s,  0)
    col_5s_solid  = color.new(col_5s,  0)
    col_15s_solid = color.new(col_15s, 0)
    col_30s_solid = color.new(col_30s, 0)
    col_1m_solid  = color.new(col_1m,  0)

    // 1s row
    table.cell(tbl, 0, 1, " ", bgcolor=show_1s ? col_1s_solid : color.new(color.gray, 60), text_size=sz)
    table.cell(tbl, 1, 1, "1s",  text_color=show_1s ? col_1s_solid : color.new(color.gray, 40), text_size=sz, bgcolor=color.new(color.black, 80))
    table.cell(tbl, 2, 1, show_1s ? "ON" : "OFF", text_color=show_1s ? color.new(color.green, 0) : color.new(color.red, 0), text_size=sz, bgcolor=color.new(color.black, 80))

    // 5s row
    table.cell(tbl, 0, 2, " ", bgcolor=show_5s ? col_5s_solid : color.new(color.gray, 60), text_size=sz)
    table.cell(tbl, 1, 2, "5s",  text_color=show_5s ? col_5s_solid : color.new(color.gray, 40), text_size=sz, bgcolor=color.new(color.black, 80))
    table.cell(tbl, 2, 2, show_5s ? "ON" : "OFF", text_color=show_5s ? color.new(color.green, 0) : color.new(color.red, 0), text_size=sz, bgcolor=color.new(color.black, 80))

    // 15s row
    table.cell(tbl, 0, 3, " ", bgcolor=show_15s ? col_15s_solid : color.new(color.gray, 60), text_size=sz)
    table.cell(tbl, 1, 3, "15s", text_color=show_15s ? col_15s_solid : color.new(color.gray, 40), text_size=sz, bgcolor=color.new(color.black, 80))
    table.cell(tbl, 2, 3, show_15s ? "ON" : "OFF", text_color=show_15s ? color.new(color.green, 0) : color.new(color.red, 0), text_size=sz, bgcolor=color.new(color.black, 80))

    // 30s row
    table.cell(tbl, 0, 4, " ", bgcolor=show_30s ? col_30s_solid : color.new(color.gray, 60), text_size=sz)
    table.cell(tbl, 1, 4, "30s", text_color=show_30s ? col_30s_solid : color.new(color.gray, 40), text_size=sz, bgcolor=color.new(color.black, 80))
    table.cell(tbl, 2, 4, show_30s ? "ON" : "OFF", text_color=show_30s ? color.new(color.green, 0) : color.new(color.red, 0), text_size=sz, bgcolor=color.new(color.black, 80))

    // 1m row
    table.cell(tbl, 0, 5, " ", bgcolor=show_1m ? col_1m_solid : color.new(color.gray, 60), text_size=sz)
    table.cell(tbl, 1, 5, "1m",  text_color=show_1m ? col_1m_solid : color.new(color.gray, 40), text_size=sz, bgcolor=color.new(color.black, 80))
    table.cell(tbl, 2, 5, show_1m ? "ON" : "OFF", text_color=show_1m ? color.new(color.green, 0) : color.new(color.red, 0), text_size=sz, bgcolor=color.new(color.black, 80))
````
