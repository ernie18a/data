# IB Break Statistics

- url: https://www.tradingview.com/script/LEEIYKzk-IB-Break-Statistics/
- type: indicator
- pine_id: PUB;c81d29589614438783c8ce4b3b4d423b
- version: 1.0

## Description

IB Break Statistics

  Tracks the behavior of the Initial Balance (IB) — the price range formed in the first hour of
  the session — across the last N trading days.

  Sections:

  Break Type — how often the session ends with no break, a single-sided break (high or low only),
  or a double break (both sides).

  Day of Week — break frequency broken down by weekday, to identify which days tend to trend vs.
  range.

  Extension after break — of the days that broke, how far price traveled beyond the IB level,
  expressed as a multiple of the IB range (e.g. 0.5× IB). Useful for calibrating take-profit
  targets.

  Retrace after break — on single-break days, how far price pulled back toward the IB after the
  break. Bucketed as shallow (≤10%), entry zone (11–25%), deep (26–50%), or back inside IB (>50%).
  Useful for calibrating retrace entries and stop placement.

  IB Size — the daily IB range expressed as a percentage of the session's mid-price. Bucketed as
  narrow (<0.3%), normal (0.3–0.7%), wide (0.7–1.0%), and very wide (>1.0%). Useful for
  understanding the typical volatility regime and filtering setups by IB size.

  Settings: configure IB window (default 9:30–10:30 NY), lookback period, and tracking end time.

## Source Code

````pine
// =============================================================================
// IB Break Statistics — Pine Script v6
// Tracks IB break types, day-of-week probabilities, post-break extension,
// and post-break retracement — to calibrate SL, TP, and retrace entry %.
// =============================================================================
//@version=6
indicator("IB Break Statistics", overlay=true, max_labels_count=50)

// =============================================================================
// INPUTS
// =============================================================================
var g_ib = "Initial Balance Window"
ib_start_hour   = input.int(9,  "IB Start Hour",   group=g_ib, minval=0, maxval=23)
ib_start_minute = input.int(30, "IB Start Minute", group=g_ib, minval=0, maxval=59)
ib_end_hour     = input.int(10, "IB End Hour",     group=g_ib, minval=0, maxval=23)
ib_end_minute   = input.int(30, "IB End Minute",   group=g_ib, minval=0, maxval=59)

var g_stats = "Statistics"
lookback_days      = input.int(100, "Lookback Days",      group=g_stats, minval=10, maxval=500)
track_until_hour   = input.int(15,  "Track Until Hour",   group=g_stats, minval=0,  maxval=23)
track_until_minute = input.int(30,  "Track Until Minute", group=g_stats, minval=0,  maxval=59)

// =============================================================================
// TIME HELPERS — America/New_York
// =============================================================================
ny_time = hour(time, "America/New_York") * 60 + minute(time, "America/New_York")

ib_start_mins   = ib_start_hour   * 60 + ib_start_minute
ib_end_mins     = ib_end_hour     * 60 + ib_end_minute
track_end_mins  = track_until_hour * 60 + track_until_minute

at_ib_start     = ny_time == ib_start_mins
in_ib_window    = ny_time >= ib_start_mins and ny_time < ib_end_mins
ib_just_closed  = ny_time == ib_end_mins
in_track_window = ny_time >= ib_end_mins and ny_time < track_end_mins

// =============================================================================
// DAILY STATE
// =============================================================================
var float ib_high   = na
var float ib_low    = na
var float ib_range  = na
var bool  ib_locked = false
var int   ib_dow    = 0

// Break flags
var bool  bk_high   = false
var bool  bk_low    = false

// Extension: how far price went BEYOND the broken IB level (× IB range)
var float ex_high   = 0.0
var float ex_low    = 0.0

// Retrace: after the break, how far did price pull back TOWARD the IB (× IB range)
// For high break: retrace = (ib_high - min_low_after_break) / ib_range
// For low  break: retrace = (max_high_after_break - ib_low)  / ib_range
var float rx_high         = 0.0
var float rx_low          = 0.0
var float min_after_bk_h  = na   // running min low  after high break
var float max_after_bk_l  = na   // running max high after low  break

// =============================================================================
// STORAGE ARRAYS (completed days only)
// =============================================================================
var array<bool>  a_bk_h  = array.new<bool>()
var array<bool>  a_bk_l  = array.new<bool>()
var array<float> a_ex_h  = array.new<float>()
var array<float> a_ex_l  = array.new<float>()
var array<float> a_rx_h  = array.new<float>()
var array<float> a_rx_l  = array.new<float>()
var array<int>   a_dow   = array.new<int>()
var array<float> a_ib_pct = array.new<float>()

// =============================================================================
// SESSION LOGIC
// =============================================================================

if at_ib_start
    if ib_locked
        ib_mid_prev = (ib_high + ib_low) / 2.0
        ib_pct_prev = ib_mid_prev > 0 ? ib_range / ib_mid_prev * 100.0 : 0.0
        array.push(a_bk_h,   bk_high)
        array.push(a_bk_l,   bk_low)
        array.push(a_ex_h,   ex_high)
        array.push(a_ex_l,   ex_low)
        array.push(a_rx_h,   rx_high)
        array.push(a_rx_l,   rx_low)
        array.push(a_dow,    ib_dow)
        array.push(a_ib_pct, ib_pct_prev)
        while array.size(a_bk_h) > lookback_days
            array.shift(a_bk_h)
            array.shift(a_bk_l)
            array.shift(a_ex_h)
            array.shift(a_ex_l)
            array.shift(a_rx_h)
            array.shift(a_rx_l)
            array.shift(a_dow)
            array.shift(a_ib_pct)

    ib_high         := high
    ib_low          := low
    ib_locked       := false
    bk_high         := false
    bk_low          := false
    ex_high         := 0.0
    ex_low          := 0.0
    rx_high         := 0.0
    rx_low          := 0.0
    min_after_bk_h  := na
    max_after_bk_l  := na
    ib_dow          := dayofweek(time, "America/New_York")

if in_ib_window and not ib_locked
    ib_high := math.max(ib_high, high)
    ib_low  := math.min(ib_low,  low)

if ib_just_closed and not ib_locked and not na(ib_high)
    ib_locked := true
    ib_range  := ib_high - ib_low

if ib_locked and in_track_window and ib_range > 0
    // Extension
    if high > ib_high
        bk_high := true
        ex_high := math.max(ex_high, (high - ib_high) / ib_range)
    if low < ib_low
        bk_low  := true
        ex_low  := math.max(ex_low, (ib_low - low) / ib_range)

    // Retrace after high break: track how far price pulled back below ib_high
    if bk_high
        min_after_bk_h := na(min_after_bk_h) ? low : math.min(min_after_bk_h, low)
        pullback = (ib_high - min_after_bk_h) / ib_range
        rx_high  := pullback > 0.0 ? pullback : 0.0

    // Retrace after low break: track how far price bounced back above ib_low
    if bk_low
        max_after_bk_l := na(max_after_bk_l) ? high : math.max(max_after_bk_l, high)
        pullback = (max_after_bk_l - ib_low) / ib_range
        rx_low   := pullback > 0.0 ? pullback : 0.0

// =============================================================================
// STATISTICS TABLE
// =============================================================================
// Layout (3 cols × 29 rows):
//   Row  0      — Title
//   Row  1      — Break Type sub-header
//   Rows 2–4    — No Break / Single / Double
//   Row  5      — Day of Week sub-header
//   Rows 6–10   — Mon / Tue / Wed / Thu / Fri
//   Row  11     — Extension sub-header
//   Rows 12–15  — ≥0.1× / ≥0.2× / ≥0.3× / ≥0.5× IB
//   Row  16     — Retrace sub-header
//   Rows 17–20  — ≤10% / 11–25% / 26–50% / >50% of IB
//   Row  21     — avg retrace
//   Row  22     — IB Size sub-header
//   Row  23     — avg IB size %
//   Row  24     — < 0.3% (narrow)
//   Row  25     — 0.3–0.7% (normal)
//   Row  26     — 0.7–1.0% (wide)
//   Row  27     — > 1.0% (very wide)
//   Row  28     — min / max IB size %
// =============================================================================
var table t = table.new(position.top_right, 3, 29,
     border_color=color.new(color.gray, 50), border_width=1,
     bgcolor=color.new(color.black, 70))

f_p(n, d) =>
    d > 0 ? str.tostring(math.round(float(n) / float(d) * 1000.0) / 10.0) + "%" : "—"

if barstate.islast
    n     = array.size(a_bk_h)
    total = n + (ib_locked ? 1 : 0)

    cnt_none   = 0
    cnt_single = 0
    cnt_double = 0

    dow_tot = array.new<int>(7, 0)
    dow_brk = array.new<int>(7, 0)

    brk_days  = 0
    cnt_01    = 0
    cnt_02    = 0
    cnt_03    = 0
    cnt_05    = 0
    sum_ext   = 0.0

    // Retrace buckets (% of IB range, measured against break direction)
    rx_days   = 0    // single-break days with valid retrace
    rx_le10   = 0    // retrace ≤ 10%
    rx_11_25  = 0    // retrace 11–25%
    rx_26_50  = 0    // retrace 26–50%
    rx_gt50   = 0    // retrace > 50%
    sum_rx    = 0.0

    for i = 0 to n - 1
        bh  = array.get(a_bk_h, i)
        bl  = array.get(a_bk_l, i)
        eh  = array.get(a_ex_h, i)
        el  = array.get(a_ex_l, i)
        rh  = array.get(a_rx_h, i)
        rl  = array.get(a_rx_l, i)
        dw  = array.get(a_dow,  i)

        if not bh and not bl
            cnt_none += 1
        else if bh and bl
            cnt_double += 1
        else
            cnt_single += 1

        if dw >= 1 and dw <= 7
            di = dw - 1
            array.set(dow_tot, di, array.get(dow_tot, di) + 1)
            if bh or bl
                array.set(dow_brk, di, array.get(dow_brk, di) + 1)

        if bh or bl
            brk_days += 1
            mx = math.max(eh, el)
            sum_ext += mx
            if mx >= 0.1
                cnt_01 += 1
            if mx >= 0.2
                cnt_02 += 1
            if mx >= 0.3
                cnt_03 += 1
            if mx >= 0.5
                cnt_05 += 1

        // Retrace: only for single-break days (cleaner signal)
        if (bh and not bl) or (bl and not bh)
            rx = bh ? rh : rl
            rx_pct = rx * 100.0
            rx_days  += 1
            sum_rx   += rx_pct
            if rx_pct <= 10.0
                rx_le10 += 1
            else if rx_pct <= 25.0
                rx_11_25 += 1
            else if rx_pct <= 50.0
                rx_26_50 += 1
            else
                rx_gt50 += 1

    // Today (partial)
    if ib_locked
        if not bk_high and not bk_low
            cnt_none += 1
        else if bk_high and bk_low
            cnt_double += 1
        else
            cnt_single += 1

        if ib_dow >= 1 and ib_dow <= 7
            di = ib_dow - 1
            array.set(dow_tot, di, array.get(dow_tot, di) + 1)
            if bk_high or bk_low
                array.set(dow_brk, di, array.get(dow_brk, di) + 1)

        if bk_high or bk_low
            brk_days += 1
            mx_t = math.max(ex_high, ex_low)
            sum_ext += mx_t
            if mx_t >= 0.1
                cnt_01 += 1
            if mx_t >= 0.2
                cnt_02 += 1
            if mx_t >= 0.3
                cnt_03 += 1
            if mx_t >= 0.5
                cnt_05 += 1

        if (bk_high and not bk_low) or (bk_low and not bk_high)
            rx_t     = bk_high ? rx_high : rx_low
            rx_pct_t = rx_t * 100.0
            rx_days  += 1
            sum_rx   += rx_pct_t
            if rx_pct_t <= 10.0
                rx_le10 += 1
            else if rx_pct_t <= 25.0
                rx_11_25 += 1
            else if rx_pct_t <= 50.0
                rx_26_50 += 1
            else
                rx_gt50 += 1

    avg_ext = brk_days > 0 ? math.round(sum_ext / brk_days * 100.0) / 100.0 : 0.0
    avg_rx  = rx_days  > 0 ? math.round(sum_rx  / rx_days  * 10.0)  / 10.0  : 0.0

    // IB size % statistics
    ib_pct_days  = 0
    sum_ib_pct   = 0.0
    float min_ib_pct = na
    float max_ib_pct = na
    ib_narrow    = 0   // < 0.3%
    ib_normal    = 0   // 0.3–0.7%
    ib_wide      = 0   // 0.7–1.0%
    ib_vwide     = 0   // > 1.0%

    for i = 0 to n - 1
        pct_i = array.get(a_ib_pct, i)
        if pct_i > 0
            ib_pct_days += 1
            sum_ib_pct  += pct_i
            min_ib_pct   := na(min_ib_pct) ? pct_i : math.min(min_ib_pct, pct_i)
            max_ib_pct   := na(max_ib_pct) ? pct_i : math.max(max_ib_pct, pct_i)
            if pct_i < 0.3
                ib_narrow += 1
            else if pct_i < 0.7
                ib_normal += 1
            else if pct_i < 1.0
                ib_wide += 1
            else
                ib_vwide += 1

    if ib_locked and ib_range > 0
        ib_mid_now  = (ib_high + ib_low) / 2.0
        ib_pct_now  = ib_mid_now > 0 ? ib_range / ib_mid_now * 100.0 : 0.0
        if ib_pct_now > 0
            ib_pct_days += 1
            sum_ib_pct  += ib_pct_now
            min_ib_pct   := na(min_ib_pct) ? ib_pct_now : math.min(min_ib_pct, ib_pct_now)
            max_ib_pct   := na(max_ib_pct) ? ib_pct_now : math.max(max_ib_pct, ib_pct_now)
            if ib_pct_now < 0.3
                ib_narrow += 1
            else if ib_pct_now < 0.7
                ib_normal += 1
            else if ib_pct_now < 1.0
                ib_wide += 1
            else
                ib_vwide += 1

    avg_ib_pct   = ib_pct_days > 0 ? math.round(sum_ib_pct / ib_pct_days * 100.0) / 100.0 : 0.0
    min_ib_str   = na(min_ib_pct) ? "—" : str.tostring(math.round(min_ib_pct * 100.0) / 100.0) + "%"
    max_ib_str   = na(max_ib_pct) ? "—" : str.tostring(math.round(max_ib_pct * 100.0) / 100.0) + "%"

    hd_bg  = color.new(color.navy,  40)
    sub_bg = color.new(color.black, 60)

    // ── Row 0: Title ──
    table.cell(t, 0, 0, "IB BREAK STATS  (" + str.tostring(total) + " days)",
               text_color=color.yellow, bgcolor=hd_bg, text_halign=text.align_left, text_size=size.small)
    table.cell(t, 1, 0, "N",  text_color=color.yellow, bgcolor=hd_bg, text_halign=text.align_right, text_size=size.small)
    table.cell(t, 2, 0, "%",  text_color=color.yellow, bgcolor=hd_bg, text_halign=text.align_right, text_size=size.small)

    // ── Row 1: Break Type ──
    table.cell(t, 0, 1, "Break Type", text_color=color.gray, bgcolor=sub_bg, text_halign=text.align_left,  text_size=size.small)
    table.cell(t, 1, 1, "",           text_color=color.gray, bgcolor=sub_bg, text_halign=text.align_right, text_size=size.small)
    table.cell(t, 2, 1, "",           text_color=color.gray, bgcolor=sub_bg, text_halign=text.align_right, text_size=size.small)

    table.cell(t, 0, 2, "No Break",             text_color=color.white,  text_halign=text.align_left,  text_size=size.small)
    table.cell(t, 1, 2, str.tostring(cnt_none), text_color=color.white,  text_halign=text.align_right, text_size=size.small)
    table.cell(t, 2, 2, f_p(cnt_none, total),   text_color=color.orange, text_halign=text.align_right, text_size=size.small)

    table.cell(t, 0, 3, "Single Break",           text_color=color.white, text_halign=text.align_left,  text_size=size.small)
    table.cell(t, 1, 3, str.tostring(cnt_single), text_color=color.white, text_halign=text.align_right, text_size=size.small)
    table.cell(t, 2, 3, f_p(cnt_single, total),   text_color=color.lime,  text_halign=text.align_right, text_size=size.small)

    table.cell(t, 0, 4, "Double Break",           text_color=color.white, text_halign=text.align_left,  text_size=size.small)
    table.cell(t, 1, 4, str.tostring(cnt_double), text_color=color.white, text_halign=text.align_right, text_size=size.small)
    table.cell(t, 2, 4, f_p(cnt_double, total),   text_color=color.red,   text_halign=text.align_right, text_size=size.small)

    // ── Row 5: Day of Week ──
    table.cell(t, 0, 5, "Day of Week", text_color=color.gray, bgcolor=sub_bg, text_halign=text.align_left,  text_size=size.small)
    table.cell(t, 1, 5, "days",        text_color=color.gray, bgcolor=sub_bg, text_halign=text.align_right, text_size=size.small)
    table.cell(t, 2, 5, "break %",     text_color=color.gray, bgcolor=sub_bg, text_halign=text.align_right, text_size=size.small)

    // dayofweek: Sun=1, Mon=2 … Fri=6 → array index = dw-1; Mon-Fri = indices 1-5
    dow_names = array.from("Mon", "Tue", "Wed", "Thu", "Fri")
    for di = 0 to 4
        dt      = array.get(dow_tot, di + 1)
        db      = array.get(dow_brk, di + 1)
        pct_val = dt > 0 ? float(db) / float(dt) * 100.0 : 0.0
        clr     = pct_val >= 70.0 ? color.lime : pct_val >= 50.0 ? color.yellow : color.red
        row     = 6 + di
        table.cell(t, 0, row, array.get(dow_names, di), text_color=color.white, text_halign=text.align_left,  text_size=size.small)
        table.cell(t, 1, row, str.tostring(dt),          text_color=color.white, text_halign=text.align_right, text_size=size.small)
        table.cell(t, 2, row, f_p(db, dt),               text_color=clr,         text_halign=text.align_right, text_size=size.small)

    // ── Row 11: Extension ──
    table.cell(t, 0, 11, "Extension after break  (avg " + str.tostring(avg_ext) + "× IB)",
               text_color=color.gray, bgcolor=sub_bg, text_halign=text.align_left,  text_size=size.small)
    table.cell(t, 1, 11, str.tostring(brk_days) + " days",
               text_color=color.gray, bgcolor=sub_bg, text_halign=text.align_right, text_size=size.small)
    table.cell(t, 2, 11, "% of breaks",
               text_color=color.gray, bgcolor=sub_bg, text_halign=text.align_right, text_size=size.small)

    table.cell(t, 0, 12, "≥ 0.1× IB",          text_color=color.white,                 text_halign=text.align_left,  text_size=size.small)
    table.cell(t, 1, 12, str.tostring(cnt_01),   text_color=color.white,                 text_halign=text.align_right, text_size=size.small)
    table.cell(t, 2, 12, f_p(cnt_01, brk_days),  text_color=color.new(color.teal,  0),  text_halign=text.align_right, text_size=size.small)

    table.cell(t, 0, 13, "≥ 0.2× IB",          text_color=color.white,                 text_halign=text.align_left,  text_size=size.small)
    table.cell(t, 1, 13, str.tostring(cnt_02),   text_color=color.white,                 text_halign=text.align_right, text_size=size.small)
    table.cell(t, 2, 13, f_p(cnt_02, brk_days),  text_color=color.new(color.teal, 20),  text_halign=text.align_right, text_size=size.small)

    table.cell(t, 0, 14, "≥ 0.3× IB",          text_color=color.white,                 text_halign=text.align_left,  text_size=size.small)
    table.cell(t, 1, 14, str.tostring(cnt_03),   text_color=color.white,                 text_halign=text.align_right, text_size=size.small)
    table.cell(t, 2, 14, f_p(cnt_03, brk_days),  text_color=color.new(color.teal, 40),  text_halign=text.align_right, text_size=size.small)

    table.cell(t, 0, 15, "≥ 0.5× IB",          text_color=color.white,                 text_halign=text.align_left,  text_size=size.small)
    table.cell(t, 1, 15, str.tostring(cnt_05),   text_color=color.white,                 text_halign=text.align_right, text_size=size.small)
    table.cell(t, 2, 15, f_p(cnt_05, brk_days),  text_color=color.new(color.teal, 60),  text_halign=text.align_right, text_size=size.small)

    // ── Row 16: Retrace sub-header ──
    // Retrace = após o break, quanto o preço voltou em direção ao IB (% do IB range).
    // Calculado apenas em dias de Single Break para sinal mais limpo.
    table.cell(t, 0, 16, "Retrace after break  (avg " + str.tostring(avg_rx) + "% of IB)",
               text_color=color.gray, bgcolor=sub_bg, text_halign=text.align_left,  text_size=size.small)
    table.cell(t, 1, 16, str.tostring(rx_days) + " days",
               text_color=color.gray, bgcolor=sub_bg, text_halign=text.align_right, text_size=size.small)
    table.cell(t, 2, 16, "% of singles",
               text_color=color.gray, bgcolor=sub_bg, text_halign=text.align_right, text_size=size.small)

    // ── Rows 17–20: Retrace buckets ──
    table.cell(t, 0, 17, "≤ 10%  (shallow)",    text_color=color.white,                  text_halign=text.align_left,  text_size=size.small)
    table.cell(t, 1, 17, str.tostring(rx_le10),  text_color=color.white,                  text_halign=text.align_right, text_size=size.small)
    table.cell(t, 2, 17, f_p(rx_le10,  rx_days), text_color=color.new(color.green,  0),  text_halign=text.align_right, text_size=size.small)

    table.cell(t, 0, 18, "11–25%  (entry zone)", text_color=color.white,                  text_halign=text.align_left,  text_size=size.small)
    table.cell(t, 1, 18, str.tostring(rx_11_25), text_color=color.white,                  text_halign=text.align_right, text_size=size.small)
    table.cell(t, 2, 18, f_p(rx_11_25, rx_days), text_color=color.new(color.green, 20),  text_halign=text.align_right, text_size=size.small)

    table.cell(t, 0, 19, "26–50%  (deep)",       text_color=color.white,                  text_halign=text.align_left,  text_size=size.small)
    table.cell(t, 1, 19, str.tostring(rx_26_50), text_color=color.white,                  text_halign=text.align_right, text_size=size.small)
    table.cell(t, 2, 19, f_p(rx_26_50, rx_days), text_color=color.yellow,                 text_halign=text.align_right, text_size=size.small)

    table.cell(t, 0, 20, "> 50%  (back in IB)",  text_color=color.white,                  text_halign=text.align_left,  text_size=size.small)
    table.cell(t, 1, 20, str.tostring(rx_gt50),  text_color=color.white,                  text_halign=text.align_right, text_size=size.small)
    table.cell(t, 2, 20, f_p(rx_gt50,  rx_days), text_color=color.red,                    text_halign=text.align_right, text_size=size.small)

    // ── Row 21: avg retrace (formatted for quick read) ──
    table.cell(t, 0, 21, "Avg Retrace",
               text_color=color.silver, text_halign=text.align_left,  text_size=size.small)
    table.cell(t, 1, 21, "",
               text_color=color.silver, text_halign=text.align_right, text_size=size.small)
    table.cell(t, 2, 21, str.tostring(avg_rx) + "% of IB",
               text_color=color.silver, text_halign=text.align_right, text_size=size.small)

    // ── Row 22: IB Size sub-header ──
    table.cell(t, 0, 22, "IB Size  (avg " + str.tostring(avg_ib_pct) + "% of price)",
               text_color=color.gray, bgcolor=sub_bg, text_halign=text.align_left,  text_size=size.small)
    table.cell(t, 1, 22, str.tostring(ib_pct_days) + " days",
               text_color=color.gray, bgcolor=sub_bg, text_halign=text.align_right, text_size=size.small)
    table.cell(t, 2, 22, "% of days",
               text_color=color.gray, bgcolor=sub_bg, text_halign=text.align_right, text_size=size.small)

    // ── Rows 23–26: IB size buckets ──
    table.cell(t, 0, 23, "< 0.3%  (narrow)",      text_color=color.white,                  text_halign=text.align_left,  text_size=size.small)
    table.cell(t, 1, 23, str.tostring(ib_narrow),  text_color=color.white,                  text_halign=text.align_right, text_size=size.small)
    table.cell(t, 2, 23, f_p(ib_narrow, ib_pct_days), text_color=color.new(color.blue, 0), text_halign=text.align_right, text_size=size.small)

    table.cell(t, 0, 24, "0.3–0.7%  (normal)",    text_color=color.white,                  text_halign=text.align_left,  text_size=size.small)
    table.cell(t, 1, 24, str.tostring(ib_normal),  text_color=color.white,                  text_halign=text.align_right, text_size=size.small)
    table.cell(t, 2, 24, f_p(ib_normal, ib_pct_days), text_color=color.lime,               text_halign=text.align_right, text_size=size.small)

    table.cell(t, 0, 25, "0.7–1.0%  (wide)",      text_color=color.white,                  text_halign=text.align_left,  text_size=size.small)
    table.cell(t, 1, 25, str.tostring(ib_wide),    text_color=color.white,                  text_halign=text.align_right, text_size=size.small)
    table.cell(t, 2, 25, f_p(ib_wide, ib_pct_days),   text_color=color.yellow,             text_halign=text.align_right, text_size=size.small)

    table.cell(t, 0, 26, "> 1.0%  (very wide)",   text_color=color.white,                  text_halign=text.align_left,  text_size=size.small)
    table.cell(t, 1, 26, str.tostring(ib_vwide),   text_color=color.white,                  text_halign=text.align_right, text_size=size.small)
    table.cell(t, 2, 26, f_p(ib_vwide, ib_pct_days),  text_color=color.red,                text_halign=text.align_right, text_size=size.small)

    // ── Row 27–28: min / max ──
    table.cell(t, 0, 27, "Min IB size",
               text_color=color.silver, text_halign=text.align_left,  text_size=size.small)
    table.cell(t, 1, 27, "",
               text_color=color.silver, text_halign=text.align_right, text_size=size.small)
    table.cell(t, 2, 27, min_ib_str,
               text_color=color.silver, text_halign=text.align_right, text_size=size.small)

    table.cell(t, 0, 28, "Max IB size",
               text_color=color.silver, text_halign=text.align_left,  text_size=size.small)
    table.cell(t, 1, 28, "",
               text_color=color.silver, text_halign=text.align_right, text_size=size.small)
    table.cell(t, 2, 28, max_ib_str,
               text_color=color.silver, text_halign=text.align_right, text_size=size.small)
````
