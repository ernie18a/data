# Smooths IB Map

- url: https://www.tradingview.com/script/R0XeM5sL-Smooths-IB-Map/
- type: indicator
- pine_id: PUB;35ddf094f4fb4aec9551f9d90e78307d
- version: 1.0

## Description

[b]Smooths IB Map — Initial Balance Probability Engine[/b]

[i]Overview[/i]

Smooths IB Map is an Initial Balance indicator built around a statistical probability engine rather than simple level plotting. The Initial Balance (IB) is the price range established during the first hour of the regular trading session (9:30–10:30 ET by default). This range has long been used by institutional and retail traders as a reference for the day's expected price behavior — price frequently sweeps one or both IB extremes before reversing or continuing. This indicator quantifies that tendency and makes it actionable.

[i]What makes this different
[/i]
1 — Timeframe-independent data collection. Most IB indicators compute statistics directly from chart bars. This means the sample size — and therefore the probabilities — change depending on which timeframe the chart is set to. A 1-minute chart may only hold 16 days of history while a 15-minute chart holds 240, producing completely different numbers from the same lookback setting. This indicator solves that problem by anchoring all data collection inside request.security("5") — a fixed 5-minute reference feed. Probabilities are identical on any chart timeframe.

2 — Exponential decay weighted probability. A raw historical average gives equal weight to a sweep that happened 200 days ago and one that happened last week. This indicator applies exponential decay (factor 0.85 per day of age) so that recent sessions contribute proportionally more to the probability estimate. When market regime shifts, the indicator adapts faster than a simple percentage would.

3 — Range-conditional probability. Every historical IB day is classified as SMALL (<70% of the historical average range), NORMAL (70–130%), or LARGE (>130%). The indicator then computes the IBH and IBL sweep rate specifically for days that match today's size bucket. If today's IB is unusually tight, the conditional column in the table shows the sweep rate from similar tight-range days only — a more relevant reference than the overall average.

4 — First-break direction tracking. The table shows what percentage of historical days saw the IBH break first vs the IBL break first vs both sweeping on the same bar. Over a large enough sample this can reveal directional tendencies for specific instruments and sessions.

5 — Failed retest signal. After a level is swept, price often pulls back to retest it from the other side. If the retesting candle closes back on the swept side (confirming rejection), the level has flipped from resistance to support or vice versa. The indicator detects this condition and plots a colored circle directly on the wick of the confirming bar — one signal per level per day, first confirmed retest only.

[i]How to use it
[/i]
Add the indicator to any intraday chart (1m through 60m). Set your IB Open and IB Close times to match your instrument's session. Set the Data Cutoff to the time after which you do not want sweeps counted — for US equities, 16:00 ET is appropriate. Increase the Lookback Days to the maximum your plan supports (the tooltip explains approximate limits by plan). The probability labels display inside the IB box as a percentage — green indicates a historically high sweep rate (≥65%), red indicates low (≤35%), and white is neutral. The third column of the data table shows the conditional probability for today's IB size bucket. A teal circle on a bar's low signals a bullish failed retest of the IBH. A red circle on a bar's high signals a bearish failed retest of the IBL. All four alert conditions (IB formed, IBH swept, IBL swept, failed retest) are available for notification.

[i]Notes[/i]

Designed and built for MNQ/NQ futures but compatible with any intraday instrument. A minimum of 5 completed historical sessions is required before probability values are shown. Statistics are always computed from completed days only — the current in-progress session is excluded. The failed retest signal requires the sweep to have been established on at least one prior bar before it can trigger, preventing false fires on the original sweep candle itself.

## Source Code

````pine
//@version=5
indicator("Smooths IB Map", shorttitle="Smooths IB Map", overlay=true, max_boxes_count=200, max_lines_count=500, max_labels_count=300)

// ══════════════════════════════════════════════════════════════════════════════
// ⏰  SESSION  — Eastern Time
// ══════════════════════════════════════════════════════════════════════════════
g1 = "⏰ Session"
i_ib_open  = input.string("09:30", "IB Open",     group=g1, tooltip="ET — H:MM or HH:MM")
i_ib_close = input.string("10:30", "IB Close",    group=g1, tooltip="ET — H:MM or HH:MM")
i_ext_end  = input.string("16:00", "Data Cutoff", group=g1, tooltip="Sweeps after this time are excluded from probability calculations")

// ══════════════════════════════════════════════════════════════════════════════
// 📊  HISTORY
// ══════════════════════════════════════════════════════════════════════════════
g2 = "📊 History"
i_bt = input.bool(true, "Show Historical Days", group=g2)
i_lb = input.int(200,   "Lookback Days",        group=g2, minval=5, maxval=500, tooltip="At 5m resolution: ~64 days (Free) · ~128 (Pro) · ~256 (Pro+/Premium). Set high — the indicator pulls whatever your plan allows.")

// ══════════════════════════════════════════════════════════════════════════════
// ⚙️  DISPLAY
// ══════════════════════════════════════════════════════════════════════════════
g3 = "⚙️ Display"
i_show_mid = input.bool(true,       "Show Midpoint Line",  group=g3)
i_ls       = input.string("Dashed", "Line Style",          group=g3, options=["Solid","Dashed","Dotted"])
i_lw       = input.int(1,           "Line Width",           group=g3, minval=1, maxval=4)
i_lbl_sz   = input.string("Small",  "Label Size",           group=g3, options=["Tiny","Small","Normal","Large"])
i_show_tbl = input.bool(true,       "Show Data Table",      group=g3)
i_tbl_pos  = input.string("Top Right","Table Position",     group=g3, options=["Top Right","Top Left","Bottom Right","Bottom Left"])

// ══════════════════════════════════════════════════════════════════════════════
// 🎨  COLORS
// ══════════════════════════════════════════════════════════════════════════════
g4 = "🎨 Colors"
i_c_box   = input.color(color.new(color.blue, 85),  "IB Box",          group=g4)
i_c_hi    = input.color(color.teal,                  "IBH Line",        group=g4)
i_c_lo    = input.color(color.red,                   "IBL Line",        group=g4)
i_c_mid   = input.color(color.new(color.gray, 50),  "Midline",         group=g4)
i_c_swept = input.color(color.yellow,                "Swept Color",     group=g4)
i_c_hp    = input.color(color.teal,                  "High Prob ≥65%",  group=g4)
i_c_lp    = input.color(color.red,                   "Low Prob  ≤35%",  group=g4)
i_c_mp    = input.color(color.white,                 "Neutral Prob",    group=g4)

// ══════════════════════════════════════════════════════════════════════════════
// 🎯  FAILED RETEST SIGNALS
// ══════════════════════════════════════════════════════════════════════════════
g5 = "🎯 Failed Retest Signals"
i_show_fr   = input.bool(true, "Show Failed Retest Signals", group=g5, tooltip="After a level is swept, if price returns to it and a bar CLOSES on the other side (confirming rejection), a signal fires — continuation in the sweep direction.")
i_fr_sz     = input.string("Small", "Signal Size", group=g5, options=["Tiny","Small","Normal","Large"])
i_c_bull_fr = input.color(color.new(color.teal, 0), "Bullish Signal Color", group=g5)
i_c_bear_fr = input.color(color.new(color.red,  0), "Bearish Signal Color", group=g5)

// ══════════════════════════════════════════════════════════════════════════════
// 🔧  UTILITIES
// ══════════════════════════════════════════════════════════════════════════════
TZ = "America/New_York"

f_parse_hm(string t) =>
    string[] p = str.split(t, ":")
    int(str.tonumber(array.get(p, 0))) * 60 + int(str.tonumber(array.get(p, 1)))

f_day_ts(int ref_t, int hm_total) =>
    timestamp(TZ, year(ref_t, TZ), month(ref_t, TZ), dayofmonth(ref_t, TZ), hm_total / 60, hm_total % 60, 0)

f_ls() =>
    i_ls == "Dashed" ? line.style_dashed : i_ls == "Dotted" ? line.style_dotted : line.style_solid

f_lbl_sz() =>
    i_lbl_sz == "Tiny" ? size.tiny : i_lbl_sz == "Normal" ? size.normal : i_lbl_sz == "Large" ? size.large : size.small

f_fr_sz() =>
    i_fr_sz == "Tiny" ? size.tiny : i_fr_sz == "Normal" ? size.normal : i_fr_sz == "Large" ? size.large : size.small

f_tbl_pos() =>
    switch i_tbl_pos
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        =>               position.top_right

f_p_clr(int p) =>
    na(p) ? color.gray : p >= 65 ? i_c_hp : p <= 35 ? i_c_lp : i_c_mp

// ══════════════════════════════════════════════════════════════════════════════
// 📡  5-MINUTE REFERENCE ENGINE
// ══════════════════════════════════════════════════════════════════════════════
// WHY THIS EXISTS:
// On a 1m chart, Pine's bar limit holds ~16 trading days.
// On a 5m chart, ~80 days. On 15m, ~240 days.
// That means the same lookback=50 setting gives completely different sample sizes
// and therefore different probabilities on every timeframe — useless.
//
// The fix: run ALL IB detection and sweep tracking inside request.security("5").
// This anchors the data collection to the 5-minute timeframe regardless of
// what chart the user has open. Probabilities are now identical on 1m, 5m, 15m, daily.

f_ref_ib() =>
    // Parse session boundaries locally so they're available in security context
    int r_sh = f_parse_hm(i_ib_open)
    int r_eh = f_parse_hm(i_ib_close)
    int r_xh = f_parse_hm(i_ext_end)

    var float _hi   = na
    var float _lo   = na
    var bool  _ok   = false
    var bool  _hs   = false
    var bool  _ls   = false
    var int   _st   = na
    var int   _fs   = 0      // first sweep: 0=none 1=H 2=L 3=both same bar
    var bool  _fset = false

    int  r_hm = hour(time, TZ) * 60 + minute(time, TZ)
    bool r_wd  = dayofweek(time, TZ) >= dayofweek.monday and dayofweek(time, TZ) <= dayofweek.friday

    // ── Reset + begin building at IB open ─────────────────────────────────
    if r_wd and r_hm == r_sh
        _hi   := high
        _lo   := low
        _ok   := false
        _hs   := false
        _ls   := false
        _st   := time
        _fs   := 0
        _fset := false

    // ── Expand range during IB window ─────────────────────────────────────
    if r_wd and r_hm > r_sh and r_hm < r_eh and not na(_hi)
        _hi := math.max(_hi, high)
        _lo := math.min(_lo, low)

    // ── Finalize at IB close ──────────────────────────────────────────────
    if r_wd and r_hm == r_eh and not na(_hi) and not _ok
        _hi := math.max(_hi, high)
        _lo := math.min(_lo, low)
        _ok := true

    // ── Sweep detection (cutoff enforced) ─────────────────────────────────
    if _ok and r_hm > r_eh and r_hm <= r_xh
        bool n_hs = not _hs and high > _hi
        bool n_ls = not _ls and low  < _lo
        if n_hs and n_ls
            _hs := true
            _ls := true
            if not _fset
                _fs   := 3
                _fset := true
        else if n_hs
            _hs := true
            if not _fset
                _fs   := 1
                _fset := true
        else if n_ls
            _ls := true
            if not _fset
                _fs   := 2
                _fset := true

    [_hi, _lo, _ok, _hs, _ls, _st, _fs]

[r_hi, r_lo, r_ok, r_hs, r_ls, r_st, r_fs] = request.security(syminfo.tickerid, "5", f_ref_ib())

// ══════════════════════════════════════════════════════════════════════════════
// 📦  HISTORY ARRAYS  (built from 5m reference transitions)
// ══════════════════════════════════════════════════════════════════════════════
var float[] a_hi = array.new_float()
var float[] a_lo = array.new_float()
var bool[]  a_hs = array.new_bool()
var bool[]  a_ls = array.new_bool()
var int[]   a_fs = array.new_int()
var int[]   a_st = array.new_int()

// IB formed: push a new session record (sweeps start at false, updated below)
bool ib_new = r_ok and not r_ok[1]
if ib_new
    array.push(a_hi, r_hi)
    array.push(a_lo, r_lo)
    array.push(a_hs, false)
    array.push(a_ls, false)
    array.push(a_fs, 0)
    array.push(a_st, r_st)
    while array.size(a_hi) > i_lb + 1
        array.shift(a_hi)
        array.shift(a_lo)
        array.shift(a_hs)
        array.shift(a_ls)
        array.shift(a_fs)
        array.shift(a_st)

// Sweep events: update the last (current day) element as they happen
if r_ok and r_hs and not r_hs[1] and array.size(a_hs) > 0
    array.set(a_hs, array.size(a_hs) - 1, true)

if r_ok and r_ls and not r_ls[1] and array.size(a_ls) > 0
    array.set(a_ls, array.size(a_ls) - 1, true)

if r_ok and r_fs != 0 and r_fs[1] == 0 and array.size(a_fs) > 0
    array.set(a_fs, array.size(a_fs) - 1, r_fs)

// ══════════════════════════════════════════════════════════════════════════════
// 🖥  REAL-TIME CHART TRACKING  (current day display only — no security delay)
// ══════════════════════════════════════════════════════════════════════════════
hm    = hour(time, TZ) * 60 + minute(time, TZ)
is_wd = dayofweek(time, TZ) >= dayofweek.monday and dayofweek(time, TZ) <= dayofweek.friday

sh_hm = f_parse_hm(i_ib_open)
eh_hm = f_parse_hm(i_ib_close)
xh_hm = f_parse_hm(i_ext_end)

var float rt_hi = na
var float rt_lo = na
var bool  rt_ok = false
var bool  rt_hs = false
var bool  rt_ls = false
var int   rt_st = na

// Failed retest state — resets each session, fires once per level per day
var int   fr_hi_t       = na     // timestamp of IBH failed retest bar
var float fr_hi_bar_low = na     // that bar's low — label anchors here (below the wick)
var bool  fr_hi_done    = false
var int   fr_lo_t       = na
var float fr_lo_bar_high = na    // that bar's high — label anchors here (above the wick)
var bool  fr_lo_done    = false

if is_wd and hm == sh_hm
    rt_hi      := high
    rt_lo      := low
    rt_ok      := false
    rt_hs      := false
    rt_ls      := false
    rt_st      := time
    fr_hi_t        := na
    fr_hi_bar_low  := na
    fr_hi_done     := false
    fr_lo_t        := na
    fr_lo_bar_high := na
    fr_lo_done     := false

if is_wd and hm > sh_hm and hm < eh_hm and not na(rt_hi)
    rt_hi := math.max(rt_hi, high)
    rt_lo := math.min(rt_lo, low)

if is_wd and hm == eh_hm and not na(rt_hi) and not rt_ok
    rt_hi := math.max(rt_hi, high)
    rt_lo := math.min(rt_lo, low)
    rt_ok := true

if rt_ok
    if not rt_hs and high > rt_hi
        rt_hs := true
    if not rt_ls and low < rt_lo
        rt_ls := true

// ══════════════════════════════════════════════════════════════════════════════
// 🎯  FAILED RETEST DETECTION
// ══════════════════════════════════════════════════════════════════════════════
// Logic: after a level is swept, price often pulls back to retest it.
// If the retesting candle CLOSES on the swept side (can't break back through),
// the level is confirmed as flipped S/R — continue in the sweep direction.
//
// IBH swept upward → price retests IBH from above → closes ABOVE IBH = bullish
// IBL swept downward → price retests IBL from below → closes BELOW IBL = bearish
//
// Only fires during the active session (after IB close, before data cutoff).
// One signal per level per day — first confirmed retest only.

if rt_ok and hm > eh_hm and hm <= xh_hm
    // IBH Failed Retest — Bullish continuation
    // rt_hs[1] ensures we're past the original sweep bar (not firing on it)
    // Candle wicks down to IBH (low ≤ IBH) but closes above it (close > IBH)
    if rt_hs and rt_hs[1] and not fr_hi_done and low <= rt_hi and close > rt_hi
        fr_hi_t       := time
        fr_hi_bar_low := low    // anchor label below this bar's wick
        fr_hi_done    := true
    // IBL Failed Retest — Bearish continuation
    // rt_ls[1] ensures we're past the original sweep bar
    // Candle wicks up to IBL (high ≥ IBL) but closes below it (close < IBL)
    if rt_ls and rt_ls[1] and not fr_lo_done and high >= rt_lo and close < rt_lo
        fr_lo_t        := time
        fr_lo_bar_high := high  // anchor label above this bar's wick
        fr_lo_done     := true

// ══════════════════════════════════════════════════════════════════════════════
// 📐  PROBABILITY ENGINE
// ══════════════════════════════════════════════════════════════════════════════
// hist_n = completed historical days (always excludes current in-progress day)
hist_n = math.max(0, array.size(a_hi) - 1)

// ── Average historical IB range ───────────────────────────────────────────────
f_avg_rng() =>
    int n = hist_n
    if n < 1
        float(na)
    else
        float t = 0.0
        for i = 0 to n - 1
            t += array.get(a_hi, i) - array.get(a_lo, i)
        t / n

float avg_rng = f_avg_rng()

// ── Exponential-decay weighted probability ────────────────────────────────────
// Older days carry less weight (decay = 0.85 per day).
// Adapts faster to recent market regime shifts than a raw average.
f_wpct(bool[] arr) =>
    int n = hist_n
    if n < 5
        int(na)
    else
        float D  = 0.85
        float sw = 0.0
        float ss = 0.0
        for i = 0 to n - 1
            float w = math.pow(D, float(n - 1 - i))
            sw += w
            if array.get(arr, i)
                ss += w
        math.round(ss / sw * 100)

// ── Range-conditional probability ─────────────────────────────────────────────
// "On days where the IB was the same SIZE as today, what was the sweep rate?"
// Buckets: SMALL (< 70% of avg), NORMAL (70-130%), LARGE (> 130%)
// Requires ≥ 3 days matching the bucket to display.
f_cond(bool[] arr, string buck) =>
    int n = hist_n
    if n < 5 or buck == "" or na(avg_rng) or avg_rng <= 0
        int(na)
    else
        int hits   = 0
        int sweeps = 0
        for i = 0 to n - 1
            float r = (array.get(a_hi, i) - array.get(a_lo, i)) / avg_rng
            string b = r < 0.70 ? "SML" : r > 1.30 ? "LRG" : "NRM"
            if b == buck
                hits += 1
                if array.get(arr, i)
                    sweeps += 1
        hits < 3 ? int(na) : math.round(sweeps * 100.0 / hits)

// ── First-break direction ──────────────────────────────────────────────────────
// target: 1=H first  2=L first  3=both same bar  0=neither swept
f_first_pct(int target) =>
    int n = hist_n
    if n < 5
        int(na)
    else
        int c = 0
        for i = 0 to n - 1
            if array.get(a_fs, i) == target
                c += 1
        math.round(c * 100.0 / n)

// ── Both swept ────────────────────────────────────────────────────────────────
f_both_pct() =>
    int n = hist_n
    if n < 5
        int(na)
    else
        int c = 0
        for i = 0 to n - 1
            if array.get(a_hs, i) and array.get(a_ls, i)
                c += 1
        math.round(c * 100.0 / n)

// ── Compute all stats ─────────────────────────────────────────────────────────
float today_rng  = rt_ok ? rt_hi - rt_lo : float(na)
string today_buck = na(today_rng) or na(avg_rng) or avg_rng <= 0 ? "" : today_rng / avg_rng < 0.70 ? "SML" : today_rng / avg_rng > 1.30 ? "LRG" : "NRM"

int wpct_hi  = f_wpct(a_hs)
int wpct_lo  = f_wpct(a_ls)
int cond_hi  = f_cond(a_hs, today_buck)
int cond_lo  = f_cond(a_ls, today_buck)
int pct_h1st = f_first_pct(1)
int pct_l1st = f_first_pct(2)
int pct_both = f_both_pct()

// ── Today first-break label ───────────────────────────────────────────────────
// Use real-time fs from the 5m reference (r_fs)
string today_1st = not rt_ok ? "—" : r_fs == 1 ? "H broke first" : r_fs == 2 ? "L broke first" : r_fs == 3 ? "both same bar" : "none yet"

// ══════════════════════════════════════════════════════════════════════════════
// 🎨  DRAWING ENGINE
// ══════════════════════════════════════════════════════════════════════════════
var line[]  all_lines  = array.new<line>()
var box[]   all_boxes  = array.new<box>()
var label[] all_labels = array.new<label>()

f_clear() =>
    for x in all_lines
        line.delete(x)
    for x in all_boxes
        box.delete(x)
    for x in all_labels
        label.delete(x)
    array.clear(all_lines)
    array.clear(all_boxes)
    array.clear(all_labels)

f_mk_line(int x1, float y1, int x2, float y2, color clr, int w, string sty) =>
    array.push(all_lines, line.new(x1, y1, x2, y2, xloc=xloc.bar_time, color=clr, width=w, style=sty))

f_mk_box(int x1, float y1, int x2, float y2, color bc, color fc) =>
    array.push(all_boxes, box.new(x1, y1, x2, y2, xloc=xloc.bar_time, border_color=bc, bgcolor=fc, border_width=1))

f_mk_lbl(int x, float y, string txt, color tc, string sty = label.style_none, string sz = size.small) =>
    array.push(all_labels, label.new(x, y, txt, xloc=xloc.bar_time, color=#00000000, textcolor=tc, style=sty, size=sz))

// Draw one complete session
f_draw_session(int st, float hi, float lo, bool hs, bool ls, bool is_cur) =>
    float mid  = (hi + lo) / 2.0
    int   bx_r = f_day_ts(st, eh_hm)
    int   ext_e = f_day_ts(st, xh_hm)

    // Box
    f_mk_box(st, hi, bx_r, lo, color.new(color.gray, 70), is_cur ? i_c_box : color.new(color.gray, 93))

    // Extension lines — color flips to swept color when taken out
    f_mk_line(bx_r, hi, ext_e, hi, hs ? i_c_swept : i_c_hi, i_lw, f_ls())
    f_mk_line(bx_r, lo, ext_e, lo, ls ? i_c_swept : i_c_lo, i_lw, f_ls())

    // Midpoint
    if i_show_mid
        f_mk_line(st, mid, ext_e, mid, i_c_mid, 1, line.style_dotted)

    if is_cur
        // Probability labels — float inside the IB box near each level
        // IBH: label_down = body below anchor (sits under the high line, inside box)
        // IBL: label_up   = body above anchor (sits above the low line, inside box)
        int mid_t  = math.round(st + (bx_r - st) / 2)
        string hi_s = not na(wpct_hi) ? str.tostring(wpct_hi) + "%" : hist_n < 5 ? "< 5 days" : "—"
        string lo_s = not na(wpct_lo) ? str.tostring(wpct_lo) + "%" : hist_n < 5 ? "< 5 days" : "—"
        f_mk_lbl(mid_t, hi, hi_s, f_p_clr(wpct_hi), label.style_label_down, f_lbl_sz())
        f_mk_lbl(mid_t, lo, lo_s, f_p_clr(wpct_lo), label.style_label_up, f_lbl_sz())
    else
        // Historical ✓/○ markers at end of extension lines
        f_mk_lbl(ext_e, hi, hs ? " ✓" : " ○", hs ? color.teal : color.new(color.gray, 50))
        f_mk_lbl(ext_e, lo, ls ? " ✓" : " ○", ls ? color.teal : color.new(color.gray, 50))

// ══════════════════════════════════════════════════════════════════════════════
// 🖥  MAIN REDRAW  — fires every tick on the last bar
// ══════════════════════════════════════════════════════════════════════════════
if barstate.islast
    f_clear()
    int n = array.size(a_hi)

    // Determine how many history slots to draw.
    // If today's IB is already in the array (r_ok = true AND we're past IB open),
    // exclude the last element so we don't draw it twice.
    int hist_end = r_ok and hm > sh_hm ? n - 2 : n - 1

    if i_bt and hist_end >= 0
        int from_i = math.max(0, hist_end + 1 - i_lb)
        for i = from_i to hist_end
            f_draw_session(array.get(a_st, i), array.get(a_hi, i), array.get(a_lo, i), array.get(a_hs, i), array.get(a_ls, i), false)

    // Current day — use real-time chart values (no security delay)
    if rt_ok
        f_draw_session(rt_st, rt_hi, rt_lo, rt_hs, rt_ls, true)
    else if not na(rt_hi)
        // IB building — live expanding box
        f_mk_box(rt_st, rt_hi, time, rt_lo, color.new(color.gray, 70), i_c_box)
        f_mk_lbl(time, rt_hi, "  Building IB...", color.gray, label.style_label_right, size.small)

    // ── Failed Retest Signal Markers ──────────────────────────────────────
    // Solid-background labels so they're immediately visible on the chart.
    // Bullish: label below the candle pointing up (price held IBH as support)
    // Bearish: label above the candle pointing down (price held IBL as resistance)
    if i_show_fr and rt_ok
        if not na(fr_hi_t)
            array.push(all_labels, label.new(fr_hi_t, fr_hi_bar_low, "", xloc=xloc.bar_time, color=i_c_bull_fr, textcolor=color.black, style=label.style_circle, size=f_fr_sz()))
        if not na(fr_lo_t)
            array.push(all_labels, label.new(fr_lo_t, fr_lo_bar_high, "", xloc=xloc.bar_time, color=i_c_bear_fr, textcolor=color.white, style=label.style_circle, size=f_fr_sz()))

// ══════════════════════════════════════════════════════════════════════════════
// 📋  DATA TABLE
// ══════════════════════════════════════════════════════════════════════════════
var table tbl = na

if barstate.islast and i_show_tbl
    if not na(tbl)
        table.delete(tbl)

    bool has = hist_n >= 5
    string na_s = "need 5+ days"
    color lc    = color.rgb(180, 180, 180)   // metric label — solid light silver
    color wc    = color.white                  // value text
    color bg0   = color.new(color.black, 20)  // header bg
    color bg1   = color.new(color.rgb(20, 22, 30), 10)   // odd row bg
    color bg2   = color.new(color.rgb(12, 14, 20), 5)    // even row bg

    tbl := table.new(f_tbl_pos(), 3, 8, bgcolor=color.new(color.black, 10), border_color=color.new(color.gray, 40), border_width=1, frame_color=color.new(color.gray, 30), frame_width=1)

    // ── Header ────────────────────────────────────────────────────────────
    table.cell(tbl, 0, 0, "SMOOTHS IB MAP", text_color=color.white, text_size=size.small, bgcolor=color.new(color.blue, 30), text_halign=text.align_left)
    table.cell(tbl, 1, 0, str.tostring(hist_n) + " days", text_color=color.new(color.gray, 10), text_size=size.tiny, bgcolor=color.new(color.blue, 30), text_halign=text.align_center)
    table.cell(tbl, 2, 0, "decay-wtd", text_color=color.new(color.gray, 30), text_size=size.tiny, bgcolor=color.new(color.blue, 30), text_halign=text.align_center)

    // ── IBH Sweep % ───────────────────────────────────────────────────────
    string hi_v = has ? str.tostring(wpct_hi) + "%" : na_s
    string hi_ctx = not na(cond_hi) and today_buck != "" ? today_buck + ": " + str.tostring(cond_hi) + "%" : ""
    table.cell(tbl, 0, 1, "IBH Sweep", text_color=lc, text_size=size.small, bgcolor=bg1)
    table.cell(tbl, 1, 1, hi_v, text_color=f_p_clr(wpct_hi), text_size=size.small, bgcolor=bg1)
    table.cell(tbl, 2, 1, hi_ctx, text_color=f_p_clr(cond_hi), text_size=size.tiny, bgcolor=bg1)

    // ── IBL Sweep % ───────────────────────────────────────────────────────
    string lo_v = has ? str.tostring(wpct_lo) + "%" : na_s
    string lo_ctx = not na(cond_lo) and today_buck != "" ? today_buck + ": " + str.tostring(cond_lo) + "%" : ""
    table.cell(tbl, 0, 2, "IBL Sweep", text_color=lc, text_size=size.small, bgcolor=bg2)
    table.cell(tbl, 1, 2, lo_v, text_color=f_p_clr(wpct_lo), text_size=size.small, bgcolor=bg2)
    table.cell(tbl, 2, 2, lo_ctx, text_color=f_p_clr(cond_lo), text_size=size.tiny, bgcolor=bg2)

    // ── Both Swept ────────────────────────────────────────────────────────
    table.cell(tbl, 0, 3, "Both Swept", text_color=lc, text_size=size.small, bgcolor=bg1)
    table.cell(tbl, 1, 3, has ? str.tostring(pct_both) + "%" : "—", text_color=wc, text_size=size.small, bgcolor=bg1)
    table.cell(tbl, 2, 3, "", text_color=wc, text_size=size.tiny, bgcolor=bg1)

    // ── H Breaks First ────────────────────────────────────────────────────
    table.cell(tbl, 0, 4, "H Breaks 1st", text_color=lc, text_size=size.small, bgcolor=bg2)
    table.cell(tbl, 1, 4, has ? str.tostring(pct_h1st) + "%" : "—", text_color=f_p_clr(pct_h1st), text_size=size.small, bgcolor=bg2)
    table.cell(tbl, 2, 4, "", text_color=wc, text_size=size.tiny, bgcolor=bg2)

    // ── L Breaks First ────────────────────────────────────────────────────
    table.cell(tbl, 0, 5, "L Breaks 1st", text_color=lc, text_size=size.small, bgcolor=bg1)
    table.cell(tbl, 1, 5, has ? str.tostring(pct_l1st) + "%" : "—", text_color=f_p_clr(pct_l1st), text_size=size.small, bgcolor=bg1)
    table.cell(tbl, 2, 5, "", text_color=wc, text_size=size.tiny, bgcolor=bg1)

    // ── Today Status ──────────────────────────────────────────────────────
    string stat_s = not rt_ok ? "—" : rt_hs and rt_ls ? "H ✓  L ✓" : rt_hs ? "H ✓  L ○" : rt_ls ? "H ○  L ✓" : "H ○  L ○"
    color  stat_c = not rt_ok ? color.gray : rt_hs and rt_ls ? color.teal : rt_hs or rt_ls ? color.orange : color.white
    string size_s = today_buck == "SML" ? "SMALL" : today_buck == "LRG" ? "LARGE" : today_buck == "NRM" ? "NORMAL" : "—"
    color  size_c = today_buck == "SML" ? color.new(color.blue, 10) : today_buck == "LRG" ? color.orange : lc
    table.cell(tbl, 0, 6, "Today", text_color=lc, text_size=size.small, bgcolor=bg2)
    table.cell(tbl, 1, 6, stat_s, text_color=stat_c, text_size=size.small, bgcolor=bg2)
    table.cell(tbl, 2, 6, size_s, text_color=size_c, text_size=size.tiny, bgcolor=bg2)

    // ── 1st Break So Far Today ────────────────────────────────────────────
    table.cell(tbl, 0, 7, "1st Break", text_color=lc, text_size=size.small, bgcolor=bg1)
    table.cell(tbl, 1, 7, today_1st, text_color=wc, text_size=size.small, bgcolor=bg1)
    table.cell(tbl, 2, 7, "", text_color=wc, text_size=size.tiny, bgcolor=bg1)

// ══════════════════════════════════════════════════════════════════════════════
// 🔔  ALERTS
// ══════════════════════════════════════════════════════════════════════════════
alertcondition(rt_ok and not rt_ok[1], "IB Formed", "Smooths IB Map ▸ Initial Balance formed on {{ticker}}")
alertcondition(rt_ok and rt_hs and not rt_hs[1], "IBH Swept", "Smooths IB Map ▸ IBH swept on {{ticker}} — {{close}}")
alertcondition(rt_ok and rt_ls and not rt_ls[1], "IBL Swept", "Smooths IB Map ▸ IBL swept on {{ticker}} — {{close}}")
alertcondition(rt_ok and ((rt_hs and not rt_hs[1]) or (rt_ls and not rt_ls[1])), "Any Level Swept", "Smooths IB Map ▸ Level swept on {{ticker}} — {{close}}")
alertcondition(fr_hi_done and not fr_hi_done[1], "IBH Failed Retest — Bullish", "Smooths IB Map ▸ IBH held as support on {{ticker}} — bullish continuation — {{close}}")
alertcondition(fr_lo_done and not fr_lo_done[1], "IBL Failed Retest — Bearish", "Smooths IB Map ▸ IBL held as resistance on {{ticker}} — bearish continuation — {{close}}")

// ══════════════════════════════════════════════════════════════════════════════
// 📡  REFERENCE PLOTS
// ══════════════════════════════════════════════════════════════════════════════
plot(rt_ok ? rt_hi : na, "IB High", display=display.none)
plot(rt_ok ? rt_lo : na, "IB Low",  display=display.none)
````
