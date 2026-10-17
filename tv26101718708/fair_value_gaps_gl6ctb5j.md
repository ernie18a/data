# Fair Value Gaps

- url: https://www.tradingview.com/script/Gl6CtB5J-Fair-Value-Gaps/
- type: indicator
- pine_id: PUB;d71b94bd2159436c9b7eccc5e6573ec0
- version: 1.0

## Description

Fair Value Gaps (FVG) auto-detects bullish (+FVG) and bearish (-FVG) three-candle imbalances on any chart, any timeframe. Tracks each gap's state through its lifecycle and shows a real-time dashboard with active gap counts, nearest gap distance, and exact zone prices.

WHAT IS A FAIR VALUE GAP

An FVG is a three-candle pattern where the middle candle moves so aggressively that it leaves a gap between the wick of the prior candle and the wick of the following candle. Price often returns to fill these gaps before continuing — making them useful as targets, entry zones, or invalidation levels.

A bullish (+FVG) forms when the low of the current candle is above the high of two candles ago, with a bullish middle candle. A bearish (-FVG) is the inverse.

FEATURES

Auto-detects pip size for JPY pairs, other forex, metals, indices, and crypto — no manual configuration needed
Tracks up to 10 active FVGs per side with configurable minimum size filter to ignore noise
Auto-removes filled FVGs OR keeps them on chart greyed out (your choice)
Optional midline marker (50% mitigation level)
Configurable label limit so only your most recent active gaps are annotated — prevents chart clutter
Dashboard shows active count, distance to nearest gap, and exact zone prices
Cells highlight amber when price is currently inside a gap (mid-mitigation)
Movable dashboard position (six options) so it coexists with other indicators
Built-in alerts for new bullish and bearish FVG formations

HOW TO USE

Use FVGs as targets when price has left an unfilled gap behind — markets often return to fill them. Use them as entry zones when price retraces into a gap in the direction of the higher-timeframe trend. Use them as invalidation when price closes through a gap that should have held as support or resistance.

Particularly useful for SMC and ICT traders watching for liquidity sweeps followed by displacement into a fair value gap, then a retracement entry.

Pairs cleanly with the Key Swing Levels (KSL) indicator from the same author — KSL's dashboard defaults to top-right, FVG's to bottom-left, no overlap.

Open-source. Feedback and forks welcome.

## Source Code

````pine
//@version=5
// =============================================================================
// Fair Value Gaps (FVG) — v2.0
// -----------------------------------------------------------------------------
// Auto-detects bullish (+FVG) and bearish (-FVG) Fair Value Gaps on any chart,
// any timeframe. Tracks gap state (active / filled), removes or greys out
// filled gaps, and shows a dashboard with active count and nearest gap zone.
//
// Auto-detects pip size for JPY pairs, other forex, metals, indices, and
// crypto — works correctly across EURUSD, USDJPY, XAUUSD, indices, and
// crypto without any manual configuration.
//
// Author: [your handle]
// Version: 2.0
// =============================================================================

indicator("Fair Value Gaps", shorttitle="FVG", overlay=true, max_boxes_count=200, max_lines_count=200, max_labels_count=200)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
g_bull    = "Bullish FVG"
g_bear    = "Bearish FVG"
g_filter  = "Detection Filters"
g_display = "Display"

// Bullish
show_bull    = input.bool(true, "Show Bullish FVGs", group=g_bull)
col_bull_bg  = input.color(color.new(#00C853, 85), "Bull Fill",    group=g_bull, inline="b1")
col_bull_brd = input.color(color.new(#00C853, 30), "Bull Border",  group=g_bull, inline="b1")
col_bull_mid = input.color(color.new(#00C853, 40), "Bull Midline", group=g_bull)

// Bearish
show_bear    = input.bool(true, "Show Bearish FVGs", group=g_bear)
col_bear_bg  = input.color(color.new(#FF1744, 85), "Bear Fill",    group=g_bear, inline="s1")
col_bear_brd = input.color(color.new(#FF1744, 30), "Bear Border",  group=g_bear, inline="s1")
col_bear_mid = input.color(color.new(#FF1744, 40), "Bear Midline", group=g_bear)

// Detection Filters
min_size_pips = input.float(2.0, "Minimum FVG Size (pips)", group=g_filter, step=0.5, tooltip="Filter out tiny FVGs below this size")
max_fvgs      = input.int(5, "Max FVGs to Track per Side", group=g_filter, minval=1, maxval=10)
auto_remove   = input.bool(true, "Remove FVG When Filled", group=g_filter, tooltip="When ON, filled FVGs are deleted. When OFF, they stay on chart greyed out.")

// Display
show_midline      = input.bool(true,  "Show FVG Midline",                   group=g_display)
show_labels       = input.bool(true,  "Show FVG Size Labels",               group=g_display)
max_labels_shown  = input.int(3,      "Max Labels Shown per Side",          group=g_display, minval=1, maxval=10, tooltip="Only the N most recent active FVGs get labels. Reduces chart clutter.")
label_offset_bars = input.int(2,      "Label Offset (bars right of FVG)",   group=g_display, minval=0, maxval=20)
extend_right      = input.bool(true,  "Extend FVG Boxes Right",             group=g_display)
show_dash         = input.bool(true,  "Show Dashboard",                     group=g_display)
dash_position     = input.string("Bottom Left", "Dashboard Position",       group=g_display, options=["Top Left", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Right"])

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────

// Auto-detect pip size for any instrument (matches KSL helper)
get_pip_size() =>
    is_jpy = str.contains(syminfo.ticker, "JPY")
    if syminfo.type == "forex"
        is_jpy ? 0.01 : 0.0001
    else
        syminfo.mintick * 10

pip_size = get_pip_size()

f_pips(val) =>
    math.round(val / pip_size, 1)

f_price(p) =>
    not na(p) ? str.tostring(p, format.mintick) : "—"

f_ext() =>
    extend_right ? extend.right : extend.none

f_dash_pos() =>
    switch dash_position
        "Top Left"      => position.top_left
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Right"  => position.bottom_right
        =>                position.bottom_left

// ─────────────────────────────────────────────
// FVG DETECTION
// ─────────────────────────────────────────────
// Bullish FVG: gap between high[2] (bottom) and low[0] (top), middle candle bullish
// Bearish FVG: gap between low[2] (top) and high[0] (bottom), middle candle bearish

bull_fvg_top    = low
bull_fvg_bottom = high[2]
bull_fvg_size   = bull_fvg_top - bull_fvg_bottom
bull_fvg_valid  = bull_fvg_size > min_size_pips * pip_size and low > high[2] and close[1] > open[1]

bear_fvg_top    = low[2]
bear_fvg_bottom = high
bear_fvg_size   = bear_fvg_top - bear_fvg_bottom
bear_fvg_valid  = bear_fvg_size > min_size_pips * pip_size and high < low[2] and close[1] < open[1]

// ─────────────────────────────────────────────
// PERSISTENT STORAGE
// ─────────────────────────────────────────────

var bull_boxes  = array.new_box(0)
var bull_mids   = array.new_line(0)
var bull_labels = array.new_label(0)
var bull_tops   = array.new_float(0)
var bull_bots   = array.new_float(0)
var bull_filled = array.new_bool(0)

var bear_boxes  = array.new_box(0)
var bear_mids   = array.new_line(0)
var bear_labels = array.new_label(0)
var bear_tops   = array.new_float(0)
var bear_bots   = array.new_float(0)
var bear_filled = array.new_bool(0)

// ─────────────────────────────────────────────
// ADD NEW BULLISH FVG
// ─────────────────────────────────────────────

if bull_fvg_valid and show_bull
    if array.size(bull_boxes) >= max_fvgs
        box.delete(array.shift(bull_boxes))
        line.delete(array.shift(bull_mids))
        label.delete(array.shift(bull_labels))
        array.shift(bull_tops)
        array.shift(bull_bots)
        array.shift(bull_filled)

    new_box = box.new(bar_index - 2, bull_fvg_top, bar_index, bull_fvg_bottom, border_color=col_bull_brd, bgcolor=col_bull_bg, border_width=1, extend=f_ext())
    array.push(bull_boxes,  new_box)
    array.push(bull_tops,   bull_fvg_top)
    array.push(bull_bots,   bull_fvg_bottom)
    array.push(bull_filled, false)

    mid_val = (bull_fvg_top + bull_fvg_bottom) / 2
    new_mid = show_midline ? line.new(bar_index - 2, mid_val, bar_index, mid_val, color=col_bull_mid, width=1, style=line.style_dashed, extend=f_ext()) : na
    array.push(bull_mids, new_mid)

    new_lbl = show_labels ? label.new(bar_index + label_offset_bars, bull_fvg_top, "  +FVG " + str.tostring(f_pips(bull_fvg_size)) + "p", color=color.new(#00C853, 60), textcolor=color.white, style=label.style_label_left, size=size.tiny) : na
    array.push(bull_labels, new_lbl)

// ─────────────────────────────────────────────
// ADD NEW BEARISH FVG
// ─────────────────────────────────────────────

if bear_fvg_valid and show_bear
    if array.size(bear_boxes) >= max_fvgs
        box.delete(array.shift(bear_boxes))
        line.delete(array.shift(bear_mids))
        label.delete(array.shift(bear_labels))
        array.shift(bear_tops)
        array.shift(bear_bots)
        array.shift(bear_filled)

    new_box = box.new(bar_index - 2, bear_fvg_top, bar_index, bear_fvg_bottom, border_color=col_bear_brd, bgcolor=col_bear_bg, border_width=1, extend=f_ext())
    array.push(bear_boxes,  new_box)
    array.push(bear_tops,   bear_fvg_top)
    array.push(bear_bots,   bear_fvg_bottom)
    array.push(bear_filled, false)

    mid_val = (bear_fvg_top + bear_fvg_bottom) / 2
    new_mid = show_midline ? line.new(bar_index - 2, mid_val, bar_index, mid_val, color=col_bear_mid, width=1, style=line.style_dashed, extend=f_ext()) : na
    array.push(bear_mids, new_mid)

    new_lbl = show_labels ? label.new(bar_index + label_offset_bars, bear_fvg_bottom, "  -FVG " + str.tostring(f_pips(bear_fvg_size)) + "p", color=color.new(#FF1744, 60), textcolor=color.white, style=label.style_label_left, size=size.tiny) : na
    array.push(bear_labels, new_lbl)

// ─────────────────────────────────────────────
// FILL CHECK (ascending loop — fixes v1 descending bug)
// ─────────────────────────────────────────────

if array.size(bull_boxes) > 0
    for i = 0 to array.size(bull_boxes) - 1
        if not array.get(bull_filled, i)
            bot = array.get(bull_bots, i)
            if low <= bot
                array.set(bull_filled, i, true)
                if auto_remove
                    box.delete(array.get(bull_boxes, i))
                    if not na(array.get(bull_mids, i))
                        line.delete(array.get(bull_mids, i))
                    if not na(array.get(bull_labels, i))
                        label.delete(array.get(bull_labels, i))
                else
                    box.set_bgcolor(array.get(bull_boxes, i), color.new(color.gray, 90))
                    box.set_border_color(array.get(bull_boxes, i), color.new(color.gray, 70))

if array.size(bear_boxes) > 0
    for i = 0 to array.size(bear_boxes) - 1
        if not array.get(bear_filled, i)
            top = array.get(bear_tops, i)
            if high >= top
                array.set(bear_filled, i, true)
                if auto_remove
                    box.delete(array.get(bear_boxes, i))
                    if not na(array.get(bear_mids, i))
                        line.delete(array.get(bear_mids, i))
                    if not na(array.get(bear_labels, i))
                        label.delete(array.get(bear_labels, i))
                else
                    box.set_bgcolor(array.get(bear_boxes, i), color.new(color.gray, 90))
                    box.set_border_color(array.get(bear_boxes, i), color.new(color.gray, 70))

// ─────────────────────────────────────────────
// LIMIT VISIBLE LABELS (only most recent N active)
// ─────────────────────────────────────────────

if show_labels and barstate.islast
    // Bull labels: hide all except most recent N active
    if array.size(bull_labels) > 0
        active_seen = 0
        for i = 0 to array.size(bull_labels) - 1
            // Iterate from newest (end) to oldest (start)
            idx = array.size(bull_labels) - 1 - i
            lbl = array.get(bull_labels, idx)
            if not na(lbl)
                if not array.get(bull_filled, idx) and active_seen < max_labels_shown
                    label.set_textcolor(lbl, color.white)
                    active_seen += 1
                else
                    label.set_textcolor(lbl, color.new(color.white, 100))
                    label.set_color(lbl, color.new(color.gray, 100))

    if array.size(bear_labels) > 0
        active_seen = 0
        for i = 0 to array.size(bear_labels) - 1
            idx = array.size(bear_labels) - 1 - i
            lbl = array.get(bear_labels, idx)
            if not na(lbl)
                if not array.get(bear_filled, idx) and active_seen < max_labels_shown
                    label.set_textcolor(lbl, color.white)
                    active_seen += 1
                else
                    label.set_textcolor(lbl, color.new(color.white, 100))
                    label.set_color(lbl, color.new(color.gray, 100))

// ─────────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────────

var table dash = table.new(f_dash_pos(), 3, 6, border_width=1, border_color=color.new(color.gray, 60), frame_width=2, frame_color=color.new(#1F4E79, 0))

if barstate.islast and show_dash
    c_hdr  = color.new(#1F4E79, 0)
    c_txt  = color.white
    c_bull = color.new(#00C853, 60)
    c_bear = color.new(#FF1744, 60)
    c_row  = color.new(#1a1a2e, 80)

    // Count active FVGs (ascending loop)
    bull_active = 0
    if array.size(bull_filled) > 0
        for i = 0 to array.size(bull_filled) - 1
            if not array.get(bull_filled, i)
                bull_active += 1

    bear_active = 0
    if array.size(bear_filled) > 0
        for i = 0 to array.size(bear_filled) - 1
            if not array.get(bear_filled, i)
                bear_active += 1

    // Find nearest active bull FVG (ascending loop)
    nearest_bull_top = float(na)
    nearest_bull_bot = float(na)
    nearest_bull_dist = float(na)
    if array.size(bull_tops) > 0
        for i = 0 to array.size(bull_tops) - 1
            if not array.get(bull_filled, i)
                t = array.get(bull_tops, i)
                b = array.get(bull_bots, i)
                d = math.abs(close - (t + b) / 2)
                if na(nearest_bull_dist) or d < nearest_bull_dist
                    nearest_bull_dist := d
                    nearest_bull_top  := t
                    nearest_bull_bot  := b

    // Find nearest active bear FVG (ascending loop)
    nearest_bear_top = float(na)
    nearest_bear_bot = float(na)
    nearest_bear_dist = float(na)
    if array.size(bear_tops) > 0
        for i = 0 to array.size(bear_tops) - 1
            if not array.get(bear_filled, i)
                t = array.get(bear_tops, i)
                b = array.get(bear_bots, i)
                d = math.abs(close - (t + b) / 2)
                if na(nearest_bear_dist) or d < nearest_bear_dist
                    nearest_bear_dist := d
                    nearest_bear_top  := t
                    nearest_bear_bot  := b

    // Header
    table.cell(dash, 0, 0, "FAIR VALUE GAPS", text_color=c_txt, bgcolor=c_hdr, text_size=size.small)
    table.merge_cells(dash, 0, 0, 2, 0)

    // Column headers
    table.cell(dash, 0, 1, "TYPE",    text_color=c_txt, bgcolor=c_hdr, text_size=size.small)
    table.cell(dash, 1, 1, "ACTIVE",  text_color=c_txt, bgcolor=c_hdr, text_size=size.small)
    table.cell(dash, 2, 1, "NEAREST", text_color=c_txt, bgcolor=c_hdr, text_size=size.small)

    // Bull row
    bull_near_str = not na(nearest_bull_top) ? str.tostring(math.round(nearest_bull_dist / pip_size, 0)) + "p away" : "None"
    table.cell(dash, 0, 2, "+FVG (Bull)", text_color=c_txt, bgcolor=c_bull, text_size=size.small)
    table.cell(dash, 1, 2, str.tostring(bull_active), text_color=c_txt, bgcolor=c_row, text_size=size.small)
    table.cell(dash, 2, 2, bull_near_str, text_color=c_txt, bgcolor=c_row, text_size=size.small)

    // Bear row
    bear_near_str = not na(nearest_bear_top) ? str.tostring(math.round(nearest_bear_dist / pip_size, 0)) + "p away" : "None"
    table.cell(dash, 0, 3, "-FVG (Bear)", text_color=c_txt, bgcolor=c_bear, text_size=size.small)
    table.cell(dash, 1, 3, str.tostring(bear_active), text_color=c_txt, bgcolor=c_row, text_size=size.small)
    table.cell(dash, 2, 3, bear_near_str, text_color=c_txt, bgcolor=c_row, text_size=size.small)

    // Nearest Bull FVG zone
    bull_zone_str = not na(nearest_bull_top) ? f_price(nearest_bull_bot) + " — " + f_price(nearest_bull_top) : "No active +FVG"
    table.cell(dash, 0, 4, "Nearest +FVG", text_color=c_txt, bgcolor=c_row, text_size=size.small)
    table.cell(dash, 1, 4, bull_zone_str, text_color=c_txt, bgcolor=c_row, text_size=size.small)
    table.merge_cells(dash, 1, 4, 2, 4)

    // Nearest Bear FVG zone
    bear_zone_str = not na(nearest_bear_top) ? f_price(nearest_bear_bot) + " — " + f_price(nearest_bear_top) : "No active -FVG"
    table.cell(dash, 0, 5, "Nearest -FVG", text_color=c_txt, bgcolor=c_row, text_size=size.small)
    table.cell(dash, 1, 5, bear_zone_str, text_color=c_txt, bgcolor=c_row, text_size=size.small)
    table.merge_cells(dash, 1, 5, 2, 5)

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────

alertcondition(bull_fvg_valid and show_bull, title="New Bullish FVG", message="FVG: New +FVG detected on {{ticker}} {{interval}}")
alertcondition(bear_fvg_valid and show_bear, title="New Bearish FVG", message="FVG: New -FVG detected on {{ticker}} {{interval}}")
````
