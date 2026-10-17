# AMD Session Tracker

- url: https://www.tradingview.com/script/zkDONb7m-AMD-Session-Tracker/
- type: indicator
- pine_id: PUB;ca2bdaac36bb49ffb8e3d8501efa2925
- version: 1.0

## Description

AMD Session Tracker plots the three major forex sessions (Asia, London, New York) as live-growing colored boxes with high/low extension lines, then layers AMD framework analysis on top. Detects in real time when London sweeps the Asian range and when NY sweeps the London range — the core mechanics of the Accumulation / Manipulation / Distribution model.

WHAT IS AMD

AMD stands for Accumulation, Manipulation, Distribution — a market structure framework popularized by ICT and SMC traders. The Asian session typically accumulates in a tight range, London manipulates by sweeping that range to grab liquidity above or below it, and New York distributes in the resulting direction. This indicator tracks all three sessions and detects the sweep relationships between them as price action develops.

FEATURES

Live-growing session boxes for Asia (7PM–3AM), London (3AM–8AM), and New York (8AM–12PM) — all times America/New York with automatic DST adjustment
Asian range high/low extension lines projected into London and NY for liquidity targeting
Sweep tracking: detects when London sweeps Asian high or low (manipulation phase) and when NY sweeps London high or low (distribution phase)
Dashboard shows current AMD phase, session high/low/range, and sweep status — sweep cells highlight amber the moment a sweep occurs
Auto-detects pip size for JPY pairs, other forex, metals, indices, and crypto — no manual configuration
Optional 50% midline marker for each session
Six dashboard position options for indicator layout flexibility
Built-in alerts for session opens AND first-time sweeps of prior session highs and lows

HOW TO USE

Watch for London to sweep the Asian range during the manipulation phase — this is the highest-probability AMD setup signal. After the sweep, look for displacement back into the Asian range and a fair value gap to enter on the retracement. NY then often continues in the post-sweep direction (distribution).

Set alerts on "Asia High Swept" and "Asia Low Swept" to get notified the moment manipulation occurs, even if you're away from the chart.

Pairs cleanly with Fair Value Gaps (FVG) and Key Swing Levels (KSL) from the same author — three indicators designed to coexist on the same chart with non-overlapping dashboards by default (AMD top-right, KSL also top-right but movable, FVG bottom-left).

Open-source. Feedback and forks welcome.

## Source Code

````pine
//@version=5
// =============================================================================
// AMD Session Tracker — v2.0
// -----------------------------------------------------------------------------
// Tracks the three major forex sessions (Asia, London, New York) as live-growing
// price boxes with high/low extension lines, then layers AMD framework analysis
// on top: detects when London sweeps the Asian range (manipulation phase) and
// when NY sweeps the London range (distribution phase). Dashboard displays
// session H/L/range plus real-time sweep status.
//
// Auto-detects pip size for JPY pairs, other forex, metals, indices, and
// crypto — works correctly across EURUSD, USDJPY, XAUUSD, indices, and crypto
// without any manual configuration.
//
// Session times are based on America/New_York (EST/EDT, auto-adjusts for DST):
//   Asia:    7:00 PM – 3:00 AM
//   London:  3:00 AM – 8:00 AM
//   NY:      8:00 AM – 12:00 PM
//
// Author: [your handle]
// Version: 2.0
// =============================================================================

indicator("AMD Session Tracker", shorttitle="AMD", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=200)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
g_asia    = "Asian Session (7PM–3AM EST)"
g_london  = "London Session (3AM–8AM EST)"
g_ny      = "NY Session (8AM–12PM EST)"
g_display = "Display"

// Asia
show_asia     = input.bool(true, "Show Asian Session", group=g_asia)
col_asia_bg   = input.color(color.new(#7B1FA2, 88), "Asia Fill",   group=g_asia, inline="a1")
col_asia_brd  = input.color(color.new(#CE93D8, 40), "Asia Border", group=g_asia, inline="a1")
show_asia_ext = input.bool(true, "Extend Asia H/L into London + NY", group=g_asia)

// London
show_london    = input.bool(true, "Show London Session", group=g_london)
col_london_bg  = input.color(color.new(#00838F, 88), "London Fill",   group=g_london, inline="l1")
col_london_brd = input.color(color.new(#80DEEA, 40), "London Border", group=g_london, inline="l1")

// NY
show_ny    = input.bool(true, "Show NY Session", group=g_ny)
col_ny_bg  = input.color(color.new(#E65100, 88), "NY Fill",   group=g_ny, inline="n1")
col_ny_brd = input.color(color.new(#FFCC80, 40), "NY Border", group=g_ny, inline="n1")

// Display
show_midline   = input.bool(true,  "Show Session Midline",        group=g_display)
show_labels    = input.bool(true,  "Show Session Labels",         group=g_display)
show_dash      = input.bool(true,  "Show Dashboard",              group=g_display)
show_sweeps    = input.bool(true,  "Show Sweep Column in Dash",   group=g_display, tooltip="Tracks whether London swept Asia H/L (manipulation) and whether NY swept London H/L (distribution).")
days_back      = input.int(3,      "Days of History to Show",     group=g_display, minval=1, maxval=5)
dash_position  = input.string("Top Left", "Dashboard Position", group=g_display, options=["Top Left", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Right"])

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────

// Auto-detect pip size for any instrument (matches KSL/FVG)
get_pip_size() =>
    is_jpy = str.contains(syminfo.ticker, "JPY")
    if syminfo.type == "forex"
        is_jpy ? 0.01 : 0.0001
    else
        syminfo.mintick * 10

pip_size = get_pip_size()

f_range(h, l) =>
    not na(h) and not na(l) ? str.tostring(math.round((h - l) / pip_size, 0)) + "p" : "—"

f_price(p) =>
    not na(p) ? str.tostring(p, format.mintick) : "—"

f_dash_pos() =>
    switch dash_position
        "Top Left"      => position.top_left
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Right"  => position.bottom_right
        =>                position.top_left

// ─────────────────────────────────────────────
// SESSION TIME DETECTION
// ─────────────────────────────────────────────

ny_hr      = hour(time,    "America/New_York")
prev_ny_hr = hour(time[1], "America/New_York")

in_asia   = ny_hr >= 19 or ny_hr < 3
in_london = ny_hr >= 3  and ny_hr < 8
in_ny     = ny_hr >= 8  and ny_hr < 12

prev_asia   = prev_ny_hr >= 19 or prev_ny_hr < 3
prev_london = prev_ny_hr >= 3  and prev_ny_hr < 8
prev_ny_s   = prev_ny_hr >= 8  and prev_ny_hr < 12

asia_open   = in_asia   and not prev_asia
london_open = in_london and not prev_london
ny_open     = in_ny     and not prev_ny_s

within_range = time >= timenow - days_back * 86400000

f_phase() =>
    in_asia   ? "● ASIA (Accumulate)" :
     in_london ? "● LONDON (Manipulation)" :
     in_ny     ? "● NEW YORK (Distribution)" : "● Off Session"

f_phase_col() =>
    in_asia   ? color.new(#7B1FA2, 60) :
     in_london ? color.new(#00838F, 60) :
     in_ny     ? color.new(#E65100, 60) : color.new(#1a1a2e, 80)

// ─────────────────────────────────────────────
// PERSISTENT VARIABLES
// ─────────────────────────────────────────────

var box   asia_box     = na
var float asia_hi      = na
var float asia_lo      = na
var line  asia_mid     = na
var label asia_lbl     = na
var line  asia_hi_ext  = na
var line  asia_lo_ext  = na

var box   lon_box = na
var float lon_hi  = na
var float lon_lo  = na
var line  lon_mid = na
var label lon_lbl = na

var box   ny_box = na
var float ny_hi  = na
var float ny_lo  = na
var line  ny_mid = na
var label ny_lbl = na

// Sweep tracking (resets on each session's open)
var bool london_swept_asia_hi = false
var bool london_swept_asia_lo = false
var bool ny_swept_london_hi   = false
var bool ny_swept_london_lo   = false

// ─────────────────────────────────────────────
// ASIAN SESSION
// ─────────────────────────────────────────────

if asia_open and show_asia and within_range
    asia_hi  := high
    asia_lo  := low
    asia_box := box.new(bar_index, high, bar_index + 1, low, border_color=col_asia_brd, bgcolor=col_asia_bg, border_width=1, extend=extend.none)
    if show_midline
        mid = (high + low) / 2
        asia_mid := line.new(bar_index, mid, bar_index + 1, mid, color=color.new(#CE93D8, 30), width=1, style=line.style_dashed)
    if show_labels
        asia_lbl := label.new(bar_index + 1, high, "  ASIA", color=color.new(#7B1FA2, 50), textcolor=color.white, style=label.style_label_right, size=size.small)

if in_asia and not na(asia_box) and show_asia
    asia_hi := math.max(asia_hi, high)
    asia_lo := math.min(asia_lo, low)
    box.set_top(asia_box, asia_hi)
    box.set_bottom(asia_box, asia_lo)
    box.set_right(asia_box, bar_index + 1)
    if show_midline and not na(asia_mid)
        mid = (asia_hi + asia_lo) / 2
        line.set_y1(asia_mid, mid)
        line.set_y2(asia_mid, mid)
        line.set_x2(asia_mid, bar_index + 1)
    if show_labels and not na(asia_lbl)
        label.set_x(asia_lbl, bar_index + 1)
        label.set_y(asia_lbl, asia_hi)

if london_open and not na(asia_hi) and show_asia_ext
    asia_hi_ext := line.new(bar_index, asia_hi, bar_index + 1, asia_hi, color=color.new(#CE93D8, 20), width=1, style=line.style_dotted, extend=extend.right)
    asia_lo_ext := line.new(bar_index, asia_lo, bar_index + 1, asia_lo, color=color.new(#CE93D8, 20), width=1, style=line.style_dotted, extend=extend.right)

if not in_asia and not in_london and not in_ny and not na(asia_hi_ext)
    line.set_extend(asia_hi_ext, extend.none)
    line.set_extend(asia_lo_ext, extend.none)

// ─────────────────────────────────────────────
// LONDON SESSION
// ─────────────────────────────────────────────

if london_open and show_london and within_range
    lon_hi  := high
    lon_lo  := low
    lon_box := box.new(bar_index, high, bar_index + 1, low, border_color=col_london_brd, bgcolor=col_london_bg, border_width=1, extend=extend.none)
    if show_midline
        mid = (high + low) / 2
        lon_mid := line.new(bar_index, mid, bar_index + 1, mid, color=color.new(#80DEEA, 30), width=1, style=line.style_dashed)
    if show_labels
        lon_lbl := label.new(bar_index + 1, high, "  LONDON", color=color.new(#00838F, 50), textcolor=color.white, style=label.style_label_right, size=size.small)
    // Reset sweep flags for new London session
    london_swept_asia_hi := false
    london_swept_asia_lo := false

if in_london and not na(lon_box) and show_london
    lon_hi := math.max(lon_hi, high)
    lon_lo := math.min(lon_lo, low)
    box.set_top(lon_box, lon_hi)
    box.set_bottom(lon_box, lon_lo)
    box.set_right(lon_box, bar_index + 1)
    if show_midline and not na(lon_mid)
        mid = (lon_hi + lon_lo) / 2
        line.set_y1(lon_mid, mid)
        line.set_y2(lon_mid, mid)
        line.set_x2(lon_mid, bar_index + 1)
    if show_labels and not na(lon_lbl)
        label.set_x(lon_lbl, bar_index + 1)
        label.set_y(lon_lbl, lon_hi)

// London sweep detection
if in_london and not na(asia_hi) and not na(asia_lo)
    if high > asia_hi
        london_swept_asia_hi := true
    if low < asia_lo
        london_swept_asia_lo := true

// ─────────────────────────────────────────────
// NY SESSION
// ─────────────────────────────────────────────

if ny_open and show_ny and within_range
    ny_hi  := high
    ny_lo  := low
    ny_box := box.new(bar_index, high, bar_index + 1, low, border_color=col_ny_brd, bgcolor=col_ny_bg, border_width=1, extend=extend.none)
    if show_midline
        mid = (high + low) / 2
        ny_mid := line.new(bar_index, mid, bar_index + 1, mid, color=color.new(#FFCC80, 30), width=1, style=line.style_dashed)
    if show_labels
        ny_lbl := label.new(bar_index + 1, high, "  NEW YORK", color=color.new(#E65100, 50), textcolor=color.white, style=label.style_label_right, size=size.small)
    // Reset sweep flags for new NY session
    ny_swept_london_hi := false
    ny_swept_london_lo := false

if in_ny and not na(ny_box) and show_ny
    ny_hi := math.max(ny_hi, high)
    ny_lo := math.min(ny_lo, low)
    box.set_top(ny_box, ny_hi)
    box.set_bottom(ny_box, ny_lo)
    box.set_right(ny_box, bar_index + 1)
    if show_midline and not na(ny_mid)
        mid = (ny_hi + ny_lo) / 2
        line.set_y1(ny_mid, mid)
        line.set_y2(ny_mid, mid)
        line.set_x2(ny_mid, bar_index + 1)
    if show_labels and not na(ny_lbl)
        label.set_x(ny_lbl, bar_index + 1)
        label.set_y(ny_lbl, ny_hi)

// NY sweep detection
if in_ny and not na(lon_hi) and not na(lon_lo)
    if high > lon_hi
        ny_swept_london_hi := true
    if low < lon_lo
        ny_swept_london_lo := true

// ─────────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────────

table_cols = show_sweeps ? 5 : 4

var table dash = table.new(f_dash_pos(), 5, 5, border_width=1, border_color=color.new(color.gray, 60), frame_width=2, frame_color=color.new(#1F4E79, 0))

if barstate.islast and show_dash
    c_hdr  = color.new(#1F4E79, 0)
    c_txt  = color.white
    c_asia = color.new(#7B1FA2, 60)
    c_lon  = color.new(#00838F, 60)
    c_ny   = color.new(#E65100, 60)
    c_row  = color.new(#1a1a2e, 80)
    c_swp  = color.new(#FFA000, 30)  // amber when sweep occurred

    // Sweep status strings
    lon_sweep_str = london_swept_asia_hi and london_swept_asia_lo ? "Both" :
                     london_swept_asia_hi ? "Asia H" :
                     london_swept_asia_lo ? "Asia L" : "—"
    ny_sweep_str  = ny_swept_london_hi and ny_swept_london_lo ? "Both" :
                     ny_swept_london_hi ? "London H" :
                     ny_swept_london_lo ? "London L" : "—"

    lon_sweep_bg = (london_swept_asia_hi or london_swept_asia_lo) ? c_swp : c_row
    ny_sweep_bg  = (ny_swept_london_hi or ny_swept_london_lo) ? c_swp : c_row

    last_col = show_sweeps ? 4 : 3

    // Phase header (full width)
    table.cell(dash, 0, 0, f_phase(), text_color=c_txt, bgcolor=f_phase_col(), text_size=size.small)
    table.merge_cells(dash, 0, 0, last_col, 0)

    // Column headers
    table.cell(dash, 0, 1, "SESSION", text_color=c_txt, bgcolor=c_hdr, text_size=size.small)
    table.cell(dash, 1, 1, "HIGH",    text_color=c_txt, bgcolor=c_hdr, text_size=size.small)
    table.cell(dash, 2, 1, "LOW",     text_color=c_txt, bgcolor=c_hdr, text_size=size.small)
    table.cell(dash, 3, 1, "RANGE",   text_color=c_txt, bgcolor=c_hdr, text_size=size.small)
    if show_sweeps
        table.cell(dash, 4, 1, "SWEEP", text_color=c_txt, bgcolor=c_hdr, text_size=size.small)

    // Asia row
    table.cell(dash, 0, 2, "Asia",                   text_color=c_txt, bgcolor=c_asia, text_size=size.small)
    table.cell(dash, 1, 2, f_price(asia_hi),         text_color=c_txt, bgcolor=c_row,  text_size=size.small)
    table.cell(dash, 2, 2, f_price(asia_lo),         text_color=c_txt, bgcolor=c_row,  text_size=size.small)
    table.cell(dash, 3, 2, f_range(asia_hi, asia_lo),text_color=c_txt, bgcolor=c_row,  text_size=size.small)
    if show_sweeps
        table.cell(dash, 4, 2, "—", text_color=c_txt, bgcolor=c_row, text_size=size.small)

    // London row
    table.cell(dash, 0, 3, "London",                 text_color=c_txt, bgcolor=c_lon, text_size=size.small)
    table.cell(dash, 1, 3, f_price(lon_hi),          text_color=c_txt, bgcolor=c_row, text_size=size.small)
    table.cell(dash, 2, 3, f_price(lon_lo),          text_color=c_txt, bgcolor=c_row, text_size=size.small)
    table.cell(dash, 3, 3, f_range(lon_hi, lon_lo),  text_color=c_txt, bgcolor=c_row, text_size=size.small)
    if show_sweeps
        table.cell(dash, 4, 3, lon_sweep_str, text_color=c_txt, bgcolor=lon_sweep_bg, text_size=size.small)

    // NY row
    table.cell(dash, 0, 4, "New York",               text_color=c_txt, bgcolor=c_ny,  text_size=size.small)
    table.cell(dash, 1, 4, f_price(ny_hi),           text_color=c_txt, bgcolor=c_row, text_size=size.small)
    table.cell(dash, 2, 4, f_price(ny_lo),           text_color=c_txt, bgcolor=c_row, text_size=size.small)
    table.cell(dash, 3, 4, f_range(ny_hi, ny_lo),    text_color=c_txt, bgcolor=c_row, text_size=size.small)
    if show_sweeps
        table.cell(dash, 4, 4, ny_sweep_str, text_color=c_txt, bgcolor=ny_sweep_bg, text_size=size.small)

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────

// Session opens
alertcondition(asia_open,   title="Asia Session Open",   message="AMD: Asian session opened on {{ticker}}")
alertcondition(london_open, title="London Session Open", message="AMD: London session opened on {{ticker}} — manipulation phase begins")
alertcondition(ny_open,     title="NY Session Open",     message="AMD: NY session opened on {{ticker}} — distribution phase begins")

// Asia range sweeps (first occurrence in the London session)
asia_hi_first_sweep = in_london and not na(asia_hi) and high > asia_hi and not london_swept_asia_hi[1]
asia_lo_first_sweep = in_london and not na(asia_lo) and low < asia_lo and not london_swept_asia_lo[1]

alertcondition(asia_hi_first_sweep, title="Asia High Swept", message="AMD: London swept Asian high on {{ticker}} — manipulation signal")
alertcondition(asia_lo_first_sweep, title="Asia Low Swept",  message="AMD: London swept Asian low on {{ticker}} — manipulation signal")

// London range sweeps (first occurrence in the NY session)
lon_hi_first_sweep = in_ny and not na(lon_hi) and high > lon_hi and not ny_swept_london_hi[1]
lon_lo_first_sweep = in_ny and not na(lon_lo) and low < lon_lo and not ny_swept_london_lo[1]

alertcondition(lon_hi_first_sweep, title="London High Swept", message="AMD: NY swept London high on {{ticker}}")
alertcondition(lon_lo_first_sweep, title="London Low Swept",  message="AMD: NY swept London low on {{ticker}}")
````
