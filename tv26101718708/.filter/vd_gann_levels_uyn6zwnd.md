# VD Gann Levels

- url: https://www.tradingview.com/script/uYn6ZWnd-VD-Gann-Levels/
- type: indicator
- pine_id: PUB;8c270300132b4beb9dd2a36296428cea
- version: 1.0

## Description

VD Gann Levels — by Vinith Dcosta & | Financepedia

A time-based Gann level indicator that automates what would otherwise be a manual charting process.

What it does

On the daily timeframe, the indicator identifies a significant unbroken swing high or low within a 6–12 month window and uses that pivot as an anchor. From the anchor date, it projects a series of Gann solar-degree intervals (90, 120, 144, 180, 216, 240, 270, 360) forward in time, converting each degree into a calendar date using mean solar motion (1° ≈ 1.0146 days). For every projected date that has already occurred, the indicator marks that day's high and low as horizontal levels.
Levels are calculated on the daily timeframe but render on all timeframes, so you can move down to intraday and see where price sits relative to each level.

The table

A summary table lists every degree, its classification (Major/Minor), the projected date, and the high/low of that date's candle. Dates that haven't occurred yet still show their projected date, with the high/low marked as "unplotted" until the candle forms. Each row carries an accuracy note: Minor degrees resolve to an exact date, while Major (cardinal) degrees may differ by up to one day due to seasonal variation in solar motion.
Inputs

Anchor: Auto-detect (default) selects the most extreme unbroken swing in the window, or switch to Manual to choose any anchor date from the calendar.
Pivot Lookback: Adjusts swing-detection sensitivity in auto mode.
Visual settings: Colors for the anchor and degree lines, line width, and a right-extension toggle.

How to use it

The plotted levels are intended as potential points of interest for confluence with your own analysis. The anchor and its degree projections give you a time-and-price map derived from a single significant swing. Use it alongside your existing method rather than in isolation.
Notes

Designed for the daily timeframe as the calculation base; displays across all timeframes.
The solar-degree dates approximate the classical Gann time method; cardinal degrees carry a ±1 day tolerance as noted in the table.

This script is for educational and informational purposes only. It does not produce buy or sell signals and is not financial advice. Trading decisions and their outcomes are solely your own responsibility. Always apply independent analysis and sound risk management.

[i]Built by The Liquidity Architect"[/i]

## Source Code

````pine
//@version=6
indicator("VD Gann Levels", overlay=true, max_lines_count=50, max_labels_count=20)

// ═══════════════════════════════════════════════════════════════
// BLISS GANN LEVELS — by Nexora
// All heavy computation runs in the DAILY context (few bars) and
// returns only scalar results, so it's memory-safe on ANY timeframe.
// Anchor (auto or manual) → project Gann solar degrees → plot levels.
// ═══════════════════════════════════════════════════════════════

// ── INPUTS ──────────────────────────────────────────────────────
var g_anchor = "Anchor Settings"
use_manual   = input.bool(false, "Use Manual Anchor Date", group=g_anchor,
               tooltip="Enable to pin the anchor to a specific date instead of auto-detect")
manual_input = input.time(timestamp("2025-10-28 00:00 +0000"), "Anchor Date", group=g_anchor,
               tooltip="Pick the anchor date from the calendar. The time-of-day field is ignored — only the date is used.")

var g_swing  = "Auto-Detect Settings"
swing_len    = input.int(10, "Pivot Lookback (daily bars)", minval=3, maxval=20, group=g_swing,
               tooltip="Only used when Manual Anchor is off")

var g_style  = "Visual Settings"
anchor_color = input.color(color.new(color.yellow, 0),  "Anchor Color",                        group=g_style)
major_color  = input.color(color.new(color.orange, 0),  "Major Degree Color (90/180/270/360)", group=g_style)
minor_color  = input.color(color.new(color.teal, 0),    "Minor Degree Color (120/144/216/240)",group=g_style)
line_width   = input.int(1, "Line Width", minval=1, maxval=4,                                  group=g_style)
extend_right = input.bool(true, "Extend Lines Right",                                          group=g_style)

// ── CONSTANTS ───────────────────────────────────────────────────
MS_PER_DAY = 86400000
LOOKBACK   = 400  // daily bars of history to scan (covers 12mo window + buffer)

// Gann solar degrees. 0° is the anchor; 360° is the one-year anniversary.
DEGREES  = array.from(90, 120, 144, 180, 216, 240, 270, 360)
IS_MAJOR = array.from(true, false, false, true, false, false, true, true)

// Mean solar motion: 1° = 365.2422/360 = 1.014562 calendar days.
// (Reverse-engineered from Gannalyst across two anchors. Minors land
// exact; cardinals 90/180/270/360 within ±1 day from seasonal sun drift.)
SOLAR_DAYS_PER_DEG = 365.2422 / 360.0

// ── CORE: compute everything in the DAILY context ───────────────
// Returns 27 scalars: anchor h/l/ts/isHigh + for each of 8 degrees its
// projected ts, matched high, matched low. Heavy array work stays here
// where the series has only a few hundred bars (memory-safe).
calc_gann() =>
    // manual target (midnight UTC of picked date), used only in manual mode
    my = year(manual_input, "UTC")
    mm = month(manual_input, "UTC")
    md = dayofmonth(manual_input, "UTC")
    manual_ts = timestamp("UTC", my, mm, md, 0, 0, 0)

    // window: anchor must be 6–12 months old
    min_ts = time - int(365 * MS_PER_DAY)  // 12 months ago
    max_ts = time - int(182 * MS_PER_DAY)  // 6 months ago

    a_idx     = -1     // bars-back index of chosen anchor
    a_is_high = false

    if use_manual
        // find the daily bar closest to the manual date (within ±3 days, not future)
        best = int(MS_PER_DAY * 3)
        for i = 0 to LOOKBACK
            if i > bar_index
                break
            bt = time[i]
            if na(bt)
                break
            d = math.abs(bt - manual_ts)
            if d < best
                best  := d
                a_idx := i
        if a_idx >= 0
            hh = high[a_idx]
            lh = a_idx + 1 <= bar_index ? high[a_idx + 1] : hh
            rh = a_idx - 1 >= 0         ? high[a_idx - 1] : hh
            a_is_high := hh >= lh and hh >= rh
    else
        // window price midpoint
        win_hi = float(na)
        win_lo = float(na)
        for i = 0 to LOOKBACK
            if i > bar_index
                break
            bt = time[i]
            if na(bt)
                break
            if bt >= min_ts and bt <= max_ts
                if na(win_hi) or high[i] > win_hi
                    win_hi := high[i]
                if na(win_lo) or low[i] < win_lo
                    win_lo := low[i]
        win_mid = na(win_hi) or na(win_lo) ? float(na) : (win_hi + win_lo) / 2.0

        best_dev = float(na)
        for i = 0 to LOOKBACK
            if i > bar_index
                break
            bt = time[i]
            if na(bt) or na(win_mid)
                break
            if bt < min_ts or bt > max_ts
                continue

            bh = high[i]
            bl = low[i]

            // pivot tests over swing_len neighbours
            is_ph = true
            is_pl = true
            for j = 1 to swing_len
                if i + j <= bar_index
                    if high[i + j] >= bh
                        is_ph := false
                    if low[i + j] <= bl
                        is_pl := false
                if i - j >= 0
                    if high[i - j] >= bh
                        is_ph := false
                    if low[i - j] <= bl
                        is_pl := false

            // unbroken high: no more recent bar exceeds it
            if is_ph
                broken = false
                for k = 0 to i - 1
                    if high[k] > bh
                        broken := true
                        break
                if not broken
                    dev = math.abs(bh - win_mid)
                    if na(best_dev) or dev > best_dev
                        best_dev  := dev
                        a_idx     := i
                        a_is_high := true

            // unbroken low: no more recent bar below it
            if is_pl
                broken = false
                for k = 0 to i - 1
                    if low[k] < bl
                        broken := true
                        break
                if not broken
                    dev = math.abs(bl - win_mid)
                    if na(best_dev) or dev > best_dev
                        best_dev  := dev
                        a_idx     := i
                        a_is_high := false

    // anchor scalars
    a_h  = a_idx >= 0 ? high[a_idx] : na
    a_l  = a_idx >= 0 ? low[a_idx]  : na
    a_ts = a_idx >= 0 ? time[a_idx] : na

    // project each degree; return projected ts + matched high/low as SCALARS
    // (no arrays cross the security boundary — keeps chart-TF memory minimal)
    var array<int>   p_ts = array.new_int(8, na)
    var array<float> p_hi = array.new_float(8, na)
    var array<float> p_lo = array.new_float(8, na)

    if a_idx >= 0
        last_ts = time
        for d = 0 to 7
            deg = array.get(DEGREES, d)
            off = math.round(deg * SOLAR_DAYS_PER_DEG)
            pts = a_ts + int(off * MS_PER_DAY)
            array.set(p_ts, d, pts)
            array.set(p_hi, d, na)
            array.set(p_lo, d, na)
            if pts <= last_ts + int(MS_PER_DAY)
                best = int(MS_PER_DAY * 3)
                mi = -1
                for i = 0 to LOOKBACK
                    if i > bar_index
                        break
                    bt = time[i]
                    if na(bt)
                        break
                    dd = math.abs(bt - pts)
                    if dd < best
                        best := dd
                        mi   := i
                if mi >= 0
                    array.set(p_hi, d, high[mi])
                    array.set(p_lo, d, low[mi])

    // unpack to scalars for return
    [a_h, a_l, a_ts, a_is_high,
     array.get(p_ts,0), array.get(p_hi,0), array.get(p_lo,0),
     array.get(p_ts,1), array.get(p_hi,1), array.get(p_lo,1),
     array.get(p_ts,2), array.get(p_hi,2), array.get(p_lo,2),
     array.get(p_ts,3), array.get(p_hi,3), array.get(p_lo,3),
     array.get(p_ts,4), array.get(p_hi,4), array.get(p_lo,4),
     array.get(p_ts,5), array.get(p_hi,5), array.get(p_lo,5),
     array.get(p_ts,6), array.get(p_hi,6), array.get(p_lo,6),
     array.get(p_ts,7), array.get(p_hi,7), array.get(p_lo,7)]

// Run the core ONCE in the daily context. Only plain scalars cross over.
[anchor_h, anchor_l, anchor_ts, anchor_is_high,
 pt0, ph0, pl0, pt1, ph1, pl1, pt2, ph2, pl2, pt3, ph3, pl3,
 pt4, ph4, pl4, pt5, ph5, pl5, pt6, ph6, pl6, pt7, ph7, pl7] =
     request.security(syminfo.tickerid, "D", calc_gann(), lookahead=barmerge.lookahead_off)

anchor_found = not na(anchor_ts)

// Rebuild small chart-side arrays from the returned scalars (8 elems each, cheap)
deg_proj  = array.from(pt0, pt1, pt2, pt3, pt4, pt5, pt6, pt7)
deg_highs = array.from(ph0, ph1, ph2, ph3, ph4, ph5, ph6, ph7)
deg_lows  = array.from(pl0, pl1, pl2, pl3, pl4, pl5, pl6, pl7)

// ── DRAW LINES (only on last bar) ───────────────────────────────
var line[]  drawn_lines  = array.new_line()
var label[] drawn_labels = array.new_label()

if barstate.islast
    for l in drawn_lines
        line.delete(l)
    for lb in drawn_labels
        label.delete(lb)
    array.clear(drawn_lines)
    array.clear(drawn_labels)

    ext      = extend_right ? extend.right : extend.none
    now_time = time

    if anchor_found and not na(anchor_h)
        array.push(drawn_lines, line.new(anchor_ts, anchor_h, now_time, anchor_h,
             xloc=xloc.bar_time, color=anchor_color, width=line_width, extend=ext, style=line.style_solid))
        array.push(drawn_lines, line.new(anchor_ts, anchor_l, now_time, anchor_l,
             xloc=xloc.bar_time, color=anchor_color, width=line_width, extend=ext, style=line.style_solid))

        anchor_lbl = "Anchor (" + (anchor_is_high ? "Swing High" : "Swing Low") + ")  " +
             str.format_time(anchor_ts, "MMM dd yy", "UTC+5:30")
        array.push(drawn_labels, label.new(now_time, anchor_h, anchor_lbl,
             xloc=xloc.bar_time, color=color.new(anchor_color, 85), textcolor=anchor_color,
             style=label.style_label_left, size=size.small))

        for d = 0 to 7
            t_high = array.get(deg_highs, d)
            t_low  = array.get(deg_lows,  d)
            t_ts   = array.get(deg_proj,  d)
            deg    = array.get(DEGREES,   d)
            is_maj = array.get(IS_MAJOR,  d)
            col    = is_maj ? major_color : minor_color
            lstyle = is_maj ? line.style_solid : line.style_dashed

            // draw only if the candle exists (not a future date)
            if not na(t_high) and not na(t_ts)
                array.push(drawn_lines, line.new(t_ts, t_high, now_time, t_high,
                     xloc=xloc.bar_time, color=col, width=line_width, extend=ext, style=lstyle))
                array.push(drawn_lines, line.new(t_ts, t_low, now_time, t_low,
                     xloc=xloc.bar_time, color=col, width=line_width, extend=ext, style=lstyle))
                array.push(drawn_labels, label.new(now_time, t_high, str.tostring(deg) + "°",
                     xloc=xloc.bar_time, color=color.new(col, 85), textcolor=col,
                     style=label.style_label_left, size=size.tiny))

// ── TABLE ────────────────────────────────────────────────────────
// Brand palette: pure black table, gold accents, silver for secondary text.
GOLD        = #D4AF37   // primary brand gold
GOLD_BRIGHT = #FFD700   // brighter gold for the watermark
SILVER      = #C0C0C0   // minor / secondary rows
CREAM       = #FFF8E7   // anchor row (stands apart from gold)
TBL_BLACK   = color.new(#000000, 0)
HDR_BLACK   = color.new(#0d0d0d, 0)

var table tbl = table.new(position.top_right, 6, 11,
     bgcolor=TBL_BLACK, border_color=color.new(GOLD, 70), border_width=1)

if barstate.islast
    // ── Brand watermark row (spans all columns) ──
    table.cell(tbl, 0, 0, "✦ VINITH DCOSTA  •  FINANCEPEDIA ✦",
               text_color=GOLD_BRIGHT, text_size=size.normal, bgcolor=TBL_BLACK,
               text_halign=text.align_center)
    table.merge_cells(tbl, 0, 0, 5, 0)

    table.cell(tbl, 0, 1, "Degree", text_color=GOLD, text_size=size.small, bgcolor=HDR_BLACK)
    table.cell(tbl, 1, 1, "Type",   text_color=GOLD, text_size=size.small, bgcolor=HDR_BLACK)
    table.cell(tbl, 2, 1, "Date",   text_color=GOLD, text_size=size.small, bgcolor=HDR_BLACK)
    table.cell(tbl, 3, 1, "High",   text_color=GOLD, text_size=size.small, bgcolor=HDR_BLACK)
    table.cell(tbl, 4, 1, "Low",    text_color=GOLD, text_size=size.small, bgcolor=HDR_BLACK)
    table.cell(tbl, 5, 1, "Acc.",   text_color=GOLD, text_size=size.small, bgcolor=HDR_BLACK)

    anchor_type_lbl = anchor_found ? (anchor_is_high ? "Swing High" : "Swing Low") : "—"
    table.cell(tbl, 0, 2, "Anchor",        text_color=CREAM, text_size=size.small)
    table.cell(tbl, 1, 2, anchor_type_lbl, text_color=CREAM, text_size=size.small)
    table.cell(tbl, 2, 2, anchor_found ? str.format_time(anchor_ts, "MMM dd yyyy", "UTC+5:30") : "—",
               text_color=CREAM, text_size=size.small)
    table.cell(tbl, 3, 2, not na(anchor_h) ? str.tostring(anchor_h, "#.##") : "—",
               text_color=CREAM, text_size=size.small)
    table.cell(tbl, 4, 2, not na(anchor_l) ? str.tostring(anchor_l, "#.##") : "—",
               text_color=CREAM, text_size=size.small)
    table.cell(tbl, 5, 2, "Exact", text_color=CREAM, text_size=size.small)

    for d = 0 to 7
        row    = d + 3
        deg    = array.get(DEGREES,   d)
        is_maj = array.get(IS_MAJOR,  d)
        t_high = array.get(deg_highs, d)
        t_low  = array.get(deg_lows,  d)
        t_proj = array.get(deg_proj,  d)
        // Table text: gold for majors, silver for minors (on-brand, independent
        // of the chart line colors the user may customize)
        tcol   = is_maj ? GOLD : SILVER
        future = na(t_high)  // candle not formed yet

        table.cell(tbl, 0, row, str.tostring(deg) + "°", text_color=tcol, text_size=size.small)
        table.cell(tbl, 1, row, is_maj ? "Major" : "Minor", text_color=tcol, text_size=size.small)
        table.cell(tbl, 2, row, na(t_proj) ? "—" : str.format_time(t_proj, "MMM dd yyyy", "UTC+5:30"),
                   text_color=tcol, text_size=size.small)
        table.cell(tbl, 3, row, future ? "unplotted" : str.tostring(t_high, "#.##"),
                   text_color=tcol, text_size=size.small)
        table.cell(tbl, 4, row, future ? "unplotted" : str.tostring(t_low, "#.##"),
                   text_color=tcol, text_size=size.small)
        acc = is_maj ? "±1 day" : "Exact"
        table.cell(tbl, 5, row, acc, text_color=tcol, text_size=size.small)
````
