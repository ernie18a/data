# IB/ORB Statistical Mapper (hardcoded)

- url: https://www.tradingview.com/script/WPtTm8fg-IB-ORB-Statistical-Mapper-hardcoded/
- type: indicator
- pine_id: PUB;281732a482e7482facf11c3f9b09194f
- version: 2.0

## Description

# IB / ORB Live Stats — Publication Description

---

## What This Indicator Does

The **IB / ORB Live Stats** indicator studies the relationship between the **Initial Balance (IB)** and a user-defined **Opening Range Breakout (ORB)** window, and builds its probability statistics **live, from the history on your own chart** — there are no pre-supplied or hard-coded numbers anywhere in this script. Every percentage you see is computed from the completed sessions visible on the current symbol and timeframe, so the statistics describe exactly the instrument you are looking at.

Rather than issuing buy/sell signals, the indicator answers structural questions about how each session tends to behave:

- When the IB **high** forms before the IB **low**, which side tends to **break first** afterward — and vice versa?
- Does the side that formed first also tend to break first (a continuation tendency), or reverse?
- Do these tendencies change when the range is unusually **wide** or **narrow**?
- When the ORB closes bullish or bearish, how often does the IB end up bullish or bearish?

It draws a box and midpoint for both the IB and the ORB, and presents two independent, separately-configurable statistics tables — one for the IB, one for the ORB.

---

## Core Concepts and Definitions

Before the statistics make sense, it helps to define each term precisely as the script uses it.

### Initial Balance (IB)
The price range established during the IB window (default **09:30–10:30 ET**). The IB high is the highest traded price and the IB low the lowest traded price during that hour. The IB midpoint is the average of the two.

### Opening Range Breakout (ORB)
A shorter range measured from the open. You set its length in **minutes** (default **15**), and the script builds the corresponding session window automatically. The ORB high, low and midpoint are defined the same way as the IB's.

### Formed First (the order of the extremes)
For each window, "formed first" identifies whether the session **high** or the session **low** was reached **earlier in time**. This is the single most important measurement in the script, and it is deliberately **not** judged from chart bars. A single chart candle frequently contains both the session high and the session low, which makes any bar-by-bar guess unreliable. Instead, the script requests **1-minute intrabar data** and walks those sub-bars in chronological order: the first 1-minute bar whose high reaches the final session high, versus the first whose low reaches the final session low — whichever comes earlier is the extreme that "formed first."

### Broke First (the order of the breakouts)
Once a window's formation period closes, the script watches for price to trade **beyond** that window's high or low. "Broke first" records which side was exceeded **first** during the rest of the regular session. Like formed-first, this uses the 1-minute intrabar feed so a large chart candle cannot hide the true sequence. If neither side is exceeded before the regular session ends, broke-first is recorded as **"none" (Neither)**.

### Direction (Bullish / Bearish / Neutral)
A single composite read of the window, combining where it formed first with where it closed:

- **Bullish** — the **low** formed first **and** the window closed in its **upper** half.
- **Bearish** — the **high** formed first **and** the window closed in its **lower** half.
- **Neutral** — every other combination (mixed signals).

The same definition is applied to both the IB and the ORB so the two can be compared like-for-like.

### Range Size: Narrow / Normal / Wide
Each window's range (high minus low) is classified **relative to its own prior history on the chart**. The classification is computed **before** the current session is added to the history, so "Wide" genuinely means wide relative to the past, not relative to a sample that already includes today. Two methods are available:

- **Z-Score** — today's range is expressed as a number of standard deviations from the historical mean. A range at or below `−Z band` is **Narrow**; at or above `+Z band` is **Wide**; in between is **Normal**.
- **Percentile** — today's range is ranked against history. At or below the Narrow percentile cutoff it is **Narrow**; at or above the Wide cutoff it is **Wide**; in between is **Normal**.

---

## The Statistics Tables, Explained Line by Line

There are two tables — **IB LIVE STATS** and **ORB LIVE STATS** — each with the same structure. The ORB table adds one extra section (the ORB-to-IB contingency) at the bottom.

### Top block — today's live readout

- **Formed first** — for the current session: `HIGH`, `LOW`, `pending` (window not yet complete), or `—` (could not be resolved, e.g. no intrabar data).
- **Broke first** — `HIGH`, `LOW`, `pending` (window not complete), `watching…` (window complete, no break yet this session), or `none` (session ended with no break).
- **Range** — today's range value, followed where available by its z-score (`z=`) and its percentile rank (`%`) against history.
- **Type** — the Narrow / Normal / Wide classification of today's range.
- **Direction** — today's Bullish / Bearish / Neutral composite.

### Cross-tabulation block — the formed-first by broke-first matrix

This is the heart of the tool. It answers: *given which extreme formed first, which side then broke first?* The columns are **BrkH** (broke high first), **BrkL** (broke low first) and **Neither**. There are two rows:

- **HIGH (n)** — all completed sessions where the **high** formed first. The three percentages show how often, within those sessions, the high broke first, the low broke first, or neither side broke. `n` is the number of such sessions.
- **LOW (n)** — the same, for sessions where the **low** formed first.

Each row sums to 100% across its three columns. Reading across the HIGH row tells you, when the high formed first, whether the market tends to continue up (BrkH) or reverse down (BrkL).

- **Same side broke 1st** — a single summary figure: across **all** completed sessions, how often the side that formed first was also the side that broke first. This is the overall **continuation tendency**; a high value means formed-first tends to predict broke-first, a low value means the market tends to reverse the early extreme.

### BY SIZE block — does range size change behavior?

This block splits every completed session into its size bucket and reports, per bucket:

- **Size** — Narrow, Normal or Wide. The bucket matching **today's** session is highlighted.
- **n** — number of completed sessions in that bucket.
- **Brk%** — of those sessions, how often **any** side broke (i.e. the session was not a "Neither" day).
- **Cont%** — of those sessions, how often the side that formed first also broke first (the continuation tendency, but isolated to that size bucket).

This is where the size classification earns its place: you can see directly whether, say, Wide ranges break and continue more often than Narrow ones.

### ORB-to-IB contingency block (ORB table only)

This answers how the early ORB read relates to the later IB outcome. It is a small matrix with the columns **IB Bull**, **IB Bear** and **IB Neut**, and two rows:

- **Bullish (n)** — all completed days where the **ORB** direction was Bullish. The three percentages show how the **IB** direction turned out on those days. `n` is the count.
- **Bearish (n)** — the same, for days where the ORB direction was Bearish.

Each row sums to 100%. The Bullish row directly answers "when the ORB is bullish, how often is the IB also bullish, bearish, or neutral?"

### The "Min sample" dimming rule

Any percentage drawn from fewer completed days than the **Min sample** input is shown in grey rather than its normal colour. This is a guard against over-reading thin data — a 100% figure from 2 sessions is meaningless, and the dimming makes that visually obvious while still letting the count build.

---

## How To Use This Indicator

### Recommended setup
Run it on a **1-minute chart** for the most accurate formed-first and broke-first detection. A 5-minute chart is the practical maximum; on higher timeframes the 1-minute intrabar window loses resolution and the ordering of extremes becomes less reliable. Make sure your chart has enough history loaded — the statistics only accumulate from sessions actually present on the chart, so a fresh chart starts empty and fills in over days of scrolled-back or elapsed history.

### A typical workflow
1. **Let it build.** The longer the history on the chart, the larger every `n`. Figures stay greyed out until they pass the Min sample threshold.
2. **Read the cross-tab.** In the IB table, look at the HIGH and LOW rows to see whether the first extreme tends to lead to continuation or reversal on your instrument.
3. **Check the size split.** In the BY SIZE block, compare Brk% and Cont% across Narrow / Normal / Wide to see whether range size meaningfully changes behavior. Today's bucket is highlighted for quick reference.
4. **Use the ORB-to-IB contingency** to gauge whether the early ORB direction is informative about how the IB resolves.
5. **Combine with your own analysis.** These figures are descriptive context, not signals.

---

## Inputs and Configuration

Every input is listed below with its default and its effect.

### Sessions group
- **IB Period (ET)** — the Initial Balance window. Default `0930-1030`.
- **ORB Period (minutes from 09:30)** — the ORB length in minutes. Default `15`, range `1–120`. The script builds the actual session window from this (e.g. 15 → 09:30–09:45) so you never edit a session string for the ORB.
- **RTH (ET)** — the regular trading hours window during which breaks are tracked and after which each day's outcome is recorded. Default `0930-1600`.
- **Intrabar resolution** — the lower timeframe used for first-touch detection. Default `1` (one minute). This must be at or below your chart timeframe; one minute is strongly recommended.

### IB/ORB Type group
- **Size method** — `Z-Score` or `Percentile`, selecting how Narrow / Normal / Wide is decided. Default `Z-Score`.
- **Z band (Narrow<=-z, Wide>=+z)** — the z-score threshold used by the Z-Score method. Default `0.5`. A range at or below −0.5 SD is Narrow, at or above +0.5 SD is Wide.
- **Narrow <= percentile** — the percentile cutoff for Narrow when using the Percentile method. Default `33`.
- **Wide >= percentile** — the percentile cutoff for Wide when using the Percentile method. Default `67`.

### Display group
- **Show IB (box)** — draw the IB box and midpoint. Default on.
- **Show ORB (box)** — draw the ORB box and midpoint. Default on.
- **Show NY Open Line** — draw a vertical line at the regular-session open. Default on.
- **Box Transparency** — transparency of the box fills, `50–95`. Default `88` (higher is more transparent).
- **IB / ORB / NY Line colours** — colour pickers for each element.

### Tables group
- **Show IB Table** — master toggle for the IB statistics table. Default on.
- **IB Position** — one of nine on-chart positions for the IB table. Default Top Right.
- **IB Text Size** — Tiny / Small / Normal / Large. Default Tiny.
- **Show ORB Table** — master toggle for the ORB statistics table. Default on.
- **ORB Position** — nine-position selector for the ORB table. Default Top Left.
- **ORB Text Size** — Tiny / Small / Normal / Large. Default Tiny.
- **Min sample (dim below)** — the minimum number of completed days a percentage must be based on before it is shown in full colour rather than grey. Default `30`, range `5–200`.

---

## How the Calculations Work (methodology)

All statistics are computed on-chart, in real time, with no external data:

1. **During each window**, the script accumulates the running high and low and collects every 1-minute sub-bar's high and low.
2. **At window close (seal)**, it walks the collected 1-minute bars in order to determine which extreme was reached first, classifies the range size against prior history, computes the composite direction, and freezes the box and midpoint at the closing bar.
3. **After the window, through the regular session (watch)**, it scans the 1-minute feed for the first break of either side and records broke-first.
4. **At the regular-session close (tally)**, it increments the cumulative counters — the formed-first by broke-first cross-tab, the size buckets, and (for the ORB) the ORB-to-IB direction contingency — so each completed day is counted exactly once.

The boxes and midpoints are **frozen** at each window's close; they do not extend across the day.

---

## Important Limitations and Considerations

1. **History-dependent.** All statistics come only from sessions present on your chart. A fresh chart has no sample; figures grow over time and stay greyed until they pass the Min sample threshold. The depth of history TradingView loads depends on your plan and the chart timeframe.
2. **Intrabar accuracy.** Formed-first and broke-first rely on the 1-minute feed and are most accurate at or below 5-minute chart resolution. On higher timeframes the ordering can be wrong.
3. **Same-sub-bar ties.** If a single 1-minute bar contains both a new extreme and a break of the opposite side simultaneously, the tie is resolved in favour of the high. This is rare but worth knowing.
4. **Descriptive, not predictive.** The indicator reports what has happened on your data. It does not forecast, and it issues no signals. Past frequency does not guarantee future behavior — a 70% tendency still failed 30% of the time.
5. **Not financial advice.** Use these statistics as objective context alongside your own strategy and risk management, never as a substitute for judgement.

---

*This is an analytical and educational tool. It does not provide buy or sell signals and makes no claim about future price direction.*

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © lucymatos

//@version=6
indicator("IB/ORB Statistical Mapper (hardcoded)", "IB/ORB", overlay=true,
     max_boxes_count=20, max_lines_count=50, max_labels_count=20, max_bars_back=5000)

// ============================================================
// HARDCODED STATISTICS  ── single source of truth, edit here ──
// Each entry: [predicted direction, probability %, sample size]
// All calibrated to 09:30 NY open, IB 09:30-10:30, ORB 5/15 min.
// If you change the session windows below, these no longer apply.
// ============================================================

// ── ORB-5 close-half  →  which IB extreme forms FIRST (known 09:35)
//    Upper close → Low forms first ;  Lower close → High forms first
ORB5_U_DIR = "Low",  ORB5_U_PCT = 58.5, ORB5_U_N = 1294
ORB5_L_DIR = "High", ORB5_L_PCT = 61.2, ORB5_L_N = 1185

// ── ORB-15 close-half  →  which IB extreme forms FIRST (known 09:45)
ORB15_U_DIR = "Low",  ORB15_U_PCT = 65.8, ORB15_U_N = 1306
ORB15_L_DIR = "High", ORB15_L_PCT = 69.5, ORB15_L_N = 1173

// ── Both ORBs combined  →  which IB extreme forms FIRST (known 09:45)
BOTH_UU_DIR = "Low",  BOTH_UU_PCT = 69.7, BOTH_UU_N = 857   // 5↑ 15↑
BOTH_LL_DIR = "High", BOTH_LL_PCT = 73.1, BOTH_LL_N = 736   // 5↓ 15↓
BOTH_UL_DIR = "High", BOTH_UL_PCT = 63.4, BOTH_UL_N = 437   // 5↑ 15↓
BOTH_LU_DIR = "Low",  BOTH_LU_PCT = 58.4, BOTH_LU_N = 449   // 5↓ 15↑

// ── Trade type  →  which IB level BREAKS first after 10:30 (known 10:30)
EXTL_DIR = "High", EXTL_PCT = 81.8, EXTL_N = 1293   // Extension Long
EXTS_DIR = "Low",  EXTS_PCT = 79.1, EXTS_N = 1094   // Extension Short
FADL_DIR = "High", FADL_PCT = 69.0, FADL_N = 365    // Fade Long
FADS_DIR = "Low",  FADS_PCT = 65.8, FADS_N = 234    // Fade Short

// ============================================================
// INPUTS
// ============================================================

var g_S = "═══ Sessions ═══"
orb5_session  = input.session("0930-0935", "ORB-5 (ET)",  group=g_S)
orb15_session = input.session("0930-0945", "ORB-15 (ET)", group=g_S)
ib_session    = input.session("0930-1030", "IB (ET)",     group=g_S)
ny_session    = input.session("0930-1600", "NY / RTH (ET)", group=g_S,
     tooltip="Hardcoded probabilities are calibrated to the default windows. Changing these invalidates them.")
ltf_res = input.timeframe("1", "Intrabar resolution", group=g_S,
     tooltip="For first-touch detection. Must be <= chart TF. Run on a 1-min (best) or 5-min chart.")
string tz = "America/New_York"

var g_V = "═══ Display ═══"
show_ib    = input.bool(true,  "Show IB box",     group=g_V)
show_orb5  = input.bool(true,  "Show ORB-5 box",  group=g_V)
show_orb15 = input.bool(true,  "Show ORB-15 box", group=g_V)
show_mids  = input.bool(true,  "Show midpoints",  group=g_V)
show_ny    = input.bool(true,  "Show NY Open line", group=g_V)
box_transp = input.int(85, "Box Transparency", minval=50, maxval=95, group=g_V)
col_ib    = input.color(color.rgb( 33,150,243), "IB",      group=g_V)
col_orb5  = input.color(color.rgb(  0,200,100), "ORB-5",   group=g_V)
col_orb15 = input.color(color.rgb(195,  0,255), "ORB-15",  group=g_V)
col_ny    = input.color(color.rgb(255,255,255), "NY Line", group=g_V)

var g_T = "═══ Table ═══"
show_table = input.bool(true, "Show Prediction Table", group=g_T)
show_valid = input.bool(true, "Show ✓/✗ Validation",   group=g_T)
tbl_pos    = input.string("Top Right", "Position",
     options=["Bottom Center","Bottom Left","Bottom Right","Middle Center","Middle Left",
              "Middle Right","Top Center","Top Left","Top Right"], group=g_T)
tbl_size   = input.string("Small", "Text Size",
     options=["Tiny","Small","Normal","Large"], group=g_T)

// ============================================================
// HELPERS
// ============================================================

f_tbl_pos(p) =>
    switch p
        "Bottom Center" => position.bottom_center
        "Bottom Left"   => position.bottom_left
        "Bottom Right"  => position.bottom_right
        "Middle Center" => position.middle_center
        "Middle Left"   => position.middle_left
        "Middle Right"  => position.middle_right
        "Top Center"    => position.top_center
        "Top Left"      => position.top_left
        => position.top_right

f_tbl_sz(s) =>
    switch s
        "Tiny"   => size.tiny
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

f_session_box(is_sess, css, show_box) =>
    var float s_high  = na
    var float s_low   = na
    var float s_open  = na
    var box   s_box   = na
    var int   s_start = na
    if is_sess and not is_sess[1]
        s_high  := high
        s_low   := low
        s_open  := open
        s_start := bar_index
        box.delete(s_box)
        s_box := show_box ? box.new(bar_index, high, bar_index + 1, low,
             bgcolor=color.new(css, box_transp), border_color=css, border_width=1) : na
    if is_sess and is_sess[1]
        s_high := math.max(high, s_high)
        s_low  := math.min(low,  s_low)
        if show_box and not na(s_box)
            box.set_top(s_box, s_high)
            box.set_rightbottom(s_box, bar_index, s_low)
    ch = not is_sess and is_sess[1] ? s_high : float(na)
    cl = not is_sess and is_sess[1] ? s_low  : float(na)
    co = not is_sess and is_sess[1] ? s_open : float(na)
    [ch, cl, co, s_start]

// ============================================================
// SESSION DETECTION + BOXES
// ============================================================

is_orb5  = not na(time(timeframe.period, orb5_session,  tz))
is_orb15 = not na(time(timeframe.period, orb15_session, tz))
is_ib    = not na(time(timeframe.period, ib_session,    tz))
is_ny    = not na(time(timeframe.period, ny_session,    tz))

// intrabar (lower-timeframe) high/low for first-touch detection
[h1m, l1m] = request.security_lower_tf(ticker.standard(syminfo.tickerid), ltf_res, [high, low])

[orb5_h,  orb5_l,  orb5_o,  orb5_start]  = f_session_box(is_orb5,  col_orb5,  show_orb5)
[orb15_h, orb15_l, orb15_o, orb15_start] = f_session_box(is_orb15, col_orb15, show_orb15)
[ib_h,    ib_l,    ib_o,    ib_start]    = f_session_box(is_ib,    col_ib,    show_ib)

// midpoints (frozen at session close, like the live indicator)
var line ib_mid    = na
var line orb5_mid  = na
var line orb15_mid = na
if show_mids and not na(ib_h)
    line.delete(ib_mid)
    ib_mid := line.new(ib_start, (ib_h+ib_l)/2, bar_index, (ib_h+ib_l)/2, color=color.new(col_ib,40), style=line.style_dashed)
if show_mids and not na(orb5_h)
    line.delete(orb5_mid)
    orb5_mid := line.new(orb5_start, (orb5_h+orb5_l)/2, bar_index, (orb5_h+orb5_l)/2, color=color.new(col_orb5,40), style=line.style_dashed)
if show_mids and not na(orb15_h)
    line.delete(orb15_mid)
    orb15_mid := line.new(orb15_start, (orb15_h+orb15_l)/2, bar_index, (orb15_h+orb15_l)/2, color=color.new(col_orb15,40), style=line.style_dashed)

var line ny_line = na
if show_ny and is_ny and not is_ny[1]
    line.delete(ny_line)
    ny_line := line.new(bar_index, low, bar_index, high, color=color.new(col_ny,40), style=line.style_solid, extend=extend.both)

// ============================================================
// LATCHED DAILY STATE
// ============================================================

var float f_orb5_h=na, var float f_orb5_l=na, var float f_orb5_close=na
var float f_orb15_h=na, var float f_orb15_l=na, var float f_orb15_close=na
var float f_ib_h=na, var float f_ib_l=na, var float f_ib_open=na, var float f_ib_close=na

if is_ny and not is_ny[1]
    f_orb5_h := na, f_orb5_l := na, f_orb5_close := na
    f_orb15_h := na, f_orb15_l := na, f_orb15_close := na
    f_ib_h := na, f_ib_l := na, f_ib_open := na, f_ib_close := na

if not na(orb5_h)
    f_orb5_h := orb5_h, f_orb5_l := orb5_l, f_orb5_close := close
if not na(orb15_h)
    f_orb15_h := orb15_h, f_orb15_l := orb15_l, f_orb15_close := close
if not na(ib_h)
    f_ib_h := ib_h, f_ib_l := ib_l, f_ib_open := ib_o, f_ib_close := close

// ── IB extreme-first  (intrabar first-touch; matches the IB/ORB Live indicator)
//    Collect LTF (1-min) highs/lows through the IB window, then at the IB close
//    decide which *final* IB extreme was reached first chronologically. The old
//    bar-by-bar version seeded the running extreme with the opening bar and could
//    report the wrong side when an extreme printed inside the first chart bar.
var array<float> ib_ltfH = array.new<float>()
var array<float> ib_ltfL = array.new<float>()
var string ib_extreme = "–"

if is_ib and not is_ib[1]
    array.clear(ib_ltfH)
    array.clear(ib_ltfL)
    ib_extreme := "–"

if is_ib and not na(h1m) and array.size(h1m) > 0
    for i = 0 to array.size(h1m) - 1
        array.push(ib_ltfH, array.get(h1m, i))
        array.push(ib_ltfL, array.get(l1m, i))

// seal on the first bar after IB ends (ib_h is non-na only on that bar)
if not na(ib_h)
    int hi_idx = -1
    int lo_idx = -1
    int n_ib = array.size(ib_ltfH)
    if n_ib > 0
        for i = 0 to n_ib - 1
            if hi_idx == -1 and array.get(ib_ltfH, i) >= ib_h
                hi_idx := i
            if lo_idx == -1 and array.get(ib_ltfL, i) <= ib_l
                lo_idx := i
            if hi_idx != -1 and lo_idx != -1
                break
    // fallback for charts with no intrabar data: undecidable -> "–"
    ib_extreme := hi_idx == -1 and lo_idx == -1 ? "–" :
                  hi_idx == -1 ? "Low" : lo_idx == -1 ? "High" :
                  (hi_idx <= lo_idx ? "High" : "Low")

// ── first IB break after 10:30  (intrabar first-touch; matches Live indicator)
var string first_break = "–"
if is_ib and not is_ib[1]
    first_break := "–"
if not is_ib and is_ny and not na(f_ib_h) and first_break == "–"
    string fnd = "–"
    if not na(h1m) and array.size(h1m) > 0
        for i = 0 to array.size(h1m) - 1
            bool hb = array.get(h1m, i) >= f_ib_h
            bool lb = array.get(l1m, i) <= f_ib_l
            if hb or lb
                fnd := hb ? "High" : "Low"   // same sub-bar tie -> high
                break
    else
        if high >= f_ib_h
            fnd := "High"
        else if low <= f_ib_l
            fnd := "Low"
    if fnd != "–"
        first_break := fnd

// ============================================================
// DERIVED CONDITIONS
// ============================================================

orb5_half  = na(f_orb5_h)  ? "–" : f_orb5_close  >= (f_orb5_h +f_orb5_l )/2 ? "Upper" : "Lower"
orb15_half = na(f_orb15_h) ? "–" : f_orb15_close >= (f_orb15_h+f_orb15_l)/2 ? "Upper" : "Lower"
ib_half    = na(f_ib_h)    ? "–" : f_ib_close    >= (f_ib_h   +f_ib_l   )/2 ? "Upper" : "Lower"

trade_type = ib_extreme == "–" or ib_half == "–" ? "–" :
     ib_extreme == "Low"  and ib_half == "Upper" ? "Extension Long"  :
     ib_extreme == "High" and ib_half == "Lower" ? "Extension Short" :
     ib_extreme == "High" and ib_half == "Upper" ? "Fade Long" : "Fade Short"

// ============================================================
// MAP CONDITIONS → HARDCODED PREDICTIONS  → [dir, pct, n]
// ============================================================

f_orb5_pred() =>
    if orb5_half == "Upper"
        [ORB5_U_DIR, ORB5_U_PCT, ORB5_U_N]
    else if orb5_half == "Lower"
        [ORB5_L_DIR, ORB5_L_PCT, ORB5_L_N]
    else
        ["–", float(na), 0]

f_orb15_pred() =>
    if orb15_half == "Upper"
        [ORB15_U_DIR, ORB15_U_PCT, ORB15_U_N]
    else if orb15_half == "Lower"
        [ORB15_L_DIR, ORB15_L_PCT, ORB15_L_N]
    else
        ["–", float(na), 0]

f_both_pred() =>
    if na(f_orb5_h) or na(f_orb15_h)
        ["–", float(na), 0]
    else if orb5_half == "Upper" and orb15_half == "Upper"
        [BOTH_UU_DIR, BOTH_UU_PCT, BOTH_UU_N]
    else if orb5_half == "Lower" and orb15_half == "Lower"
        [BOTH_LL_DIR, BOTH_LL_PCT, BOTH_LL_N]
    else if orb5_half == "Upper" and orb15_half == "Lower"
        [BOTH_UL_DIR, BOTH_UL_PCT, BOTH_UL_N]
    else if orb5_half == "Lower" and orb15_half == "Upper"
        [BOTH_LU_DIR, BOTH_LU_PCT, BOTH_LU_N]
    else
        ["–", float(na), 0]

f_break_pred() =>
    if trade_type == "Extension Long"
        [EXTL_DIR, EXTL_PCT, EXTL_N]
    else if trade_type == "Extension Short"
        [EXTS_DIR, EXTS_PCT, EXTS_N]
    else if trade_type == "Fade Long"
        [FADL_DIR, FADL_PCT, FADL_N]
    else if trade_type == "Fade Short"
        [FADS_DIR, FADS_PCT, FADS_N]
    else
        ["–", float(na), 0]

[o5p_dir,  o5p_pct,  o5p_n ] = f_orb5_pred()
[o15p_dir, o15p_pct, o15p_n] = f_orb15_pred()
[btp_dir,  btp_pct,  btp_n ] = f_both_pred()
[fbp_dir,  fbp_pct,  fbp_n ] = f_break_pred()

// ============================================================
// TABLE PALETTE + VALIDATION HELPERS  (global scope)
// ============================================================

c_hdr  = color.rgb(40,40,40)
c_htx  = color.white
c_sub  = color.rgb(110,110,110)
c_cell = color.white
c_dim  = color.rgb(60,60,60)
c_bull = color.rgb(0,150,60)
c_bear = color.rgb(200,30,30)
c_neut = color.rgb(130,130,130)
c_ok   = color.rgb(0,150,60)
c_no   = color.rgb(200,30,30)
mono   = font.family_monospace

f_valext(pred) =>
    not show_valid or ib_extreme=="–" or pred=="–" ? "" : pred==ib_extreme ? "  ✓" : "  ✗"
f_valext_col(pred, base) =>
    not show_valid or ib_extreme=="–" or pred=="–" ? base : pred==ib_extreme ? c_ok : c_no
f_valbrk(pred) =>
    not show_valid or first_break=="–" or pred=="–" ? "" : pred==first_break ? "  ✓" : "  ✗"
f_valbrk_col(pred, base) =>
    not show_valid or first_break=="–" or pred=="–" ? base : pred==first_break ? c_ok : c_no
f_predstr(dir, pct, n) =>
    na(pct) ? "–" : dir + " " + str.tostring(pct, "#.1") + "%  (n=" + str.tostring(n) + ")"
f_dircol(dir) =>
    dir=="Low" ? c_bull : dir=="High" ? c_bear : c_neut

// ============================================================
// TABLE
// ============================================================

if show_table and is_ny
    var table t = na
    table.delete(t)
    ts  = f_tbl_sz(tbl_size)
    pos = f_tbl_pos(tbl_pos)

    orb5_ready  = not na(f_orb5_h)
    orb15_ready = not na(f_orb15_h)
    ib_ready    = not na(f_ib_h)

    nrows = 1
    nrows += orb5_ready  ? 3 : 1
    nrows += orb15_ready ? 5 : 0
    nrows += ib_ready    ? 7 : 0

    t := table.new(pos, 2, nrows, border_width=1, border_color=color.rgb(180,180,180), bgcolor=c_cell)
    r = 0
    table.cell(t,0,r,"IB/ORB PREDICTIONS",bgcolor=c_hdr,text_color=c_htx,text_size=ts,text_font_family=mono)
    table.merge_cells(t,0,r,1,r)
    r+=1

    // ── ORB-5 (09:35) ──
    if orb5_ready
        table.cell(t,0,r,"── 09:35 · ORB-5 ──",bgcolor=c_sub,text_color=c_htx,text_size=ts,text_font_family=mono)
        table.merge_cells(t,0,r,1,r)
        r+=1
        table.cell(t,0,r,"Close half",bgcolor=c_cell,text_color=c_dim,text_size=ts,text_font_family=mono)
        table.cell(t,1,r,orb5_half,bgcolor=c_cell,text_color=orb5_half=="Upper"?c_bull:c_bear,text_size=ts,text_font_family=mono)
        r+=1
        table.cell(t,0,r,"IB extreme 1st",bgcolor=c_cell,text_color=c_dim,text_size=ts,text_font_family=mono)
        table.cell(t,1,r,f_predstr(o5p_dir,o5p_pct,o5p_n)+f_valext(o5p_dir),bgcolor=c_cell,text_color=f_valext_col(o5p_dir,f_dircol(o5p_dir)),text_size=ts,text_font_family=mono)
        r+=1
    else
        table.cell(t,0,r,"Waiting for 09:35…",bgcolor=c_cell,text_color=c_neut,text_size=ts,text_font_family=mono)
        table.merge_cells(t,0,r,1,r)
        r+=1

    // ── ORB-15 + combined (09:45) ──
    if orb15_ready
        table.cell(t,0,r,"── 09:45 · ORB-15 ──",bgcolor=c_sub,text_color=c_htx,text_size=ts,text_font_family=mono)
        table.merge_cells(t,0,r,1,r)
        r+=1
        table.cell(t,0,r,"Close half",bgcolor=c_cell,text_color=c_dim,text_size=ts,text_font_family=mono)
        table.cell(t,1,r,orb15_half,bgcolor=c_cell,text_color=orb15_half=="Upper"?c_bull:c_bear,text_size=ts,text_font_family=mono)
        r+=1
        table.cell(t,0,r,"IB extreme 1st",bgcolor=c_cell,text_color=c_dim,text_size=ts,text_font_family=mono)
        table.cell(t,1,r,f_predstr(o15p_dir,o15p_pct,o15p_n)+f_valext(o15p_dir),bgcolor=c_cell,text_color=f_valext_col(o15p_dir,f_dircol(o15p_dir)),text_size=ts,text_font_family=mono)
        r+=1
        agree = orb5_half=="Upper" and orb15_half=="Upper" ? "Both Upper" :
             orb5_half=="Lower" and orb15_half=="Lower" ? "Both Lower" :
             orb5_half=="Upper" and orb15_half=="Lower" ? "5↑ 15↓" : "5↓ 15↑"
        table.cell(t,0,r,"ORB agreement",bgcolor=c_cell,text_color=c_dim,text_size=ts,text_font_family=mono)
        table.cell(t,1,r,agree,bgcolor=c_cell,text_color=(orb5_half==orb15_half)?(orb5_half=="Upper"?c_bull:c_bear):c_neut,text_size=ts,text_font_family=mono)
        r+=1
        table.cell(t,0,r,"Combined → IB 1st",bgcolor=c_cell,text_color=c_dim,text_size=ts,text_font_family=mono)
        table.cell(t,1,r,f_predstr(btp_dir,btp_pct,btp_n)+f_valext(btp_dir),bgcolor=c_cell,text_color=f_valext_col(btp_dir,f_dircol(btp_dir)),text_size=ts,text_font_family=mono)
        r+=1

    // ── IB (10:30) ──
    if ib_ready
        table.cell(t,0,r,"── 10:30 · INITIAL BALANCE ──",bgcolor=c_sub,text_color=c_htx,text_size=ts,text_font_family=mono)
        table.merge_cells(t,0,r,1,r)
        r+=1
        table.cell(t,0,r,"Extreme 1st (actual)",bgcolor=c_cell,text_color=c_dim,text_size=ts,text_font_family=mono)
        table.cell(t,1,r,ib_extreme,bgcolor=c_cell,text_color=ib_extreme=="Low"?c_bull:ib_extreme=="High"?c_bear:c_neut,text_size=ts,text_font_family=mono)
        r+=1
        table.cell(t,0,r,"Close half",bgcolor=c_cell,text_color=c_dim,text_size=ts,text_font_family=mono)
        table.cell(t,1,r,ib_half,bgcolor=c_cell,text_color=ib_half=="Upper"?c_bull:c_bear,text_size=ts,text_font_family=mono)
        r+=1
        table.cell(t,0,r,"Trade type",bgcolor=c_cell,text_color=c_dim,text_size=ts,text_font_family=mono)
        table.cell(t,1,r,trade_type,bgcolor=c_cell,text_color=str.contains(trade_type,"Long")?c_bull:str.contains(trade_type,"Short")?c_bear:c_neut,text_size=ts,text_font_family=mono)
        r+=1
        table.cell(t,0,r,"── FIRST BREAK > 10:30 ──",bgcolor=c_sub,text_color=c_htx,text_size=ts,text_font_family=mono)
        table.merge_cells(t,0,r,1,r)
        r+=1
        table.cell(t,0,r,"IB level breaks 1st",bgcolor=c_cell,text_color=c_dim,text_size=ts,text_font_family=mono)
        table.cell(t,1,r,na(fbp_pct)?"–":"IB "+fbp_dir+" "+str.tostring(fbp_pct,"#.1")+"%  (n="+str.tostring(fbp_n)+")"+f_valbrk(fbp_dir),bgcolor=c_cell,text_color=f_valbrk_col(fbp_dir,fbp_dir=="High"?c_bull:fbp_dir=="Low"?c_bear:c_neut),text_size=ts,text_font_family=mono)
        r+=1
        table.cell(t,0,r,"First break (actual)",bgcolor=c_cell,text_color=c_dim,text_size=ts,text_font_family=mono)
        table.cell(t,1,r,first_break=="–"?"pending":first_break+" ✓",bgcolor=c_cell,text_color=first_break=="High"?c_bull:first_break=="Low"?c_bear:c_neut,text_size=ts,text_font_family=mono)
        r+=1
````
