# IB / ORB Live Stats

- url: https://www.tradingview.com/script/4NCjPLzS-IB-ORB-Live-Stats/
- type: indicator
- pine_id: PUB;95a6e51b53b44445b82aec59c4498cb9
- version: 1.0

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
indicator("IB / ORB Live Stats", "IB/ORB Live", overlay=true,
     max_boxes_count=20, max_lines_count=50, max_labels_count=20, max_bars_back=5000)

// ============================================================ INPUTS
g_S = "═══ Sessions ═══"
ib_session  = input.session("0930-1030", "IB Period (ET)", group=g_S)
orb_minutes = input.int(15, "ORB Period (minutes from 09:30)", minval=1, maxval=120, group=g_S)
rth_session = input.session("0930-1600", "RTH (ET)", group=g_S)
ltf_res     = input.timeframe("1", "Intrabar resolution", group=g_S,
     tooltip="For first-touch detection. Must be <= chart TF. Run on a 1-min (best) or 5-min chart.")
string tz = "America/New_York"

g_T = "═══ IB/ORB Type ═══"
cat_method = input.string("Z-Score", "Size method", options=["Z-Score","Percentile"], group=g_T)
z_band     = input.float(0.5, "Z band (Narrow<=-z, Wide>=+z)", minval=0.1, step=0.1, group=g_T)
narrow_pct = input.int(33, "Narrow <= percentile", minval=1, maxval=49, group=g_T)
wide_pct   = input.int(67, "Wide >= percentile",   minval=51, maxval=99, group=g_T)

g_V = "═══ Display ═══"
show_ib      = input.bool(true,  "Show IB (box)",  group=g_V)
show_orb     = input.bool(true,  "Show ORB (box)", group=g_V)
show_ny_line = input.bool(true,  "Show NY Open Line", group=g_V)
box_transp   = input.int(88, "Box Transparency", minval=50, maxval=95, group=g_V)
col_ib   = input.color(color.rgb( 33,150,243), "IB",      group=g_V)
col_orb  = input.color(color.rgb(  0,200,100), "ORB",     group=g_V)
col_ny   = input.color(color.rgb(255,255,255), "NY Line", group=g_V)

g_TB = "═══ Tables ═══"
show_ib_table  = input.bool(true, "Show IB Table", group=g_TB)
ib_tbl_pos     = input.string("Top Right", "IB Position",
     options=["Bottom Center","Bottom Left","Bottom Right","Middle Center","Middle Left",
              "Middle Right","Top Center","Top Left","Top Right"], group=g_TB)
ib_tbl_size    = input.string("Tiny", "IB Text Size",
     options=["Tiny","Small","Normal","Large"], group=g_TB)

show_orb_table = input.bool(true, "Show ORB Table", group=g_TB)
orb_tbl_pos    = input.string("Top Left", "ORB Position",
     options=["Bottom Center","Bottom Left","Bottom Right","Middle Center","Middle Left",
              "Middle Right","Top Center","Top Left","Top Right"], group=g_TB)
orb_tbl_size   = input.string("Tiny", "ORB Text Size",
     options=["Tiny","Small","Normal","Large"], group=g_TB)

min_sample = input.int(30, "Min sample (dim below)", minval=5, maxval=200, group=g_TB,
     tooltip="Percentages from fewer than this many completed days are greyed out.")

// ============================================================ HELPERS
inSession(s) => not na(time(timeframe.period, s, tz))

f_pad2(x) => (x < 10 ? "0" : "") + str.tostring(x)

_orb_end = 570 + orb_minutes          // 09:30 = 570 min from midnight
_orb_hh  = int(_orb_end / 60)         // int() truncates the float division
_orb_mm  = _orb_end % 60
orb_session = "0930-" + f_pad2(_orb_hh) + f_pad2(_orb_mm)

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

f_pct(part, whole) => whole > 0 ? 100.0 * part / whole : float(na)
f_pstr(x)          => na(x) ? "—" : str.tostring(x, "#.#") + "%"

f_pctRank(val, arr) =>
    int n = array.size(arr)
    float r = na
    if n > 0 and not na(val)
        int c = 0
        for i = 0 to n - 1
            if array.get(arr, i) < val
                c += 1
        r := 100.0 * c / n
    r

f_categorise(z, pr) =>
    string out = "—"
    if cat_method == "Z-Score"
        if not na(z)
            out := z <= -z_band ? "Narrow" : z >= z_band ? "Wide" : "Normal"
    else
        if not na(pr)
            out := pr <= narrow_pct ? "Narrow" : pr >= wide_pct ? "Wide" : "Normal"
    out

f_catIdx(c) => c == "Narrow" ? 0 : c == "Normal" ? 1 : c == "Wide" ? 2 : -1
f_dirIdx(d) => d == "Bullish" ? 0 : d == "Bearish" ? 1 : d == "Neutral" ? 2 : -1

// LTF intrabar data (declared before methods so methods can read it)
[h1m, l1m] = request.security_lower_tf(ticker.standard(syminfo.tickerid), ltf_res, [high, low])

// ============================================================ TYPES
type Inst
    string name
    color  col
    bool   show
    float  hi  = na
    float  lo  = na
    float  mid = na
    float  cl  = na
    int    left_bar = na
    bool   formed   = false
    array<float> ltfH
    array<float> ltfL
    string formed_first = "none"
    string broke_first  = "none"
    bool   recorded = false
    string dir = "—"
    float  rng = na
    float  z   = na
    float  pr  = na
    string cat = "—"
    array<float> hist
    int hf_hb = 0
    int hf_lb = 0
    int hf_nb = 0
    int lf_hb = 0
    int lf_lb = 0
    int lf_nb = 0
    array<int> ct_tot
    array<int> ct_brk
    array<int> ct_cont
    box  bx = na
    line ml = na

type Cont
    array<int> m   // 9 cells: orbDir*3 + ibDir   (0 Bull, 1 Bear, 2 Neut)

// ============================================================ METHODS
method reset(Inst s, bool isStart) =>
    if isStart
        s.hi := high
        s.lo := low
        s.cl := na
        s.left_bar := bar_index
        s.formed := false
        s.formed_first := "none"
        s.broke_first  := "none"
        s.recorded := false
        s.rng := na
        s.z   := na
        s.pr  := na
        s.cat := "—"
        s.dir := "—"
        array.clear(s.ltfH)
        array.clear(s.ltfL)
    int _void = 0

method feed(Inst s, bool inSess) =>
    if inSess
        s.hi := math.max(s.hi, high)
        s.lo := math.min(s.lo, low)
        s.cl := close
        if not na(h1m) and array.size(h1m) > 0
            for i = 0 to array.size(h1m) - 1
                array.push(s.ltfH, array.get(h1m, i))
                array.push(s.ltfL, array.get(l1m, i))
    int _void = 0

method seal(Inst s) =>
    s.mid := (s.hi + s.lo) / 2.0
    s.formed := true
    int hi_idx = -1
    int lo_idx = -1
    int n = array.size(s.ltfH)
    if n > 0
        for i = 0 to n - 1
            if hi_idx == -1 and array.get(s.ltfH, i) >= s.hi
                hi_idx := i
            if lo_idx == -1 and array.get(s.ltfL, i) <= s.lo
                lo_idx := i
            if hi_idx != -1 and lo_idx != -1
                break
    s.formed_first := hi_idx == -1 and lo_idx == -1 ? "none" :
                      hi_idx == -1 ? "low" : lo_idx == -1 ? "high" :
                      (hi_idx <= lo_idx ? "high" : "low")
    // categorise vs PRIOR sessions (compute before pushing today's range)
    s.rng := s.hi - s.lo
    float sd = array.size(s.hist) >= 2 ? array.stdev(s.hist) : na
    s.z  := not na(sd) and sd > 0 ? (s.rng - array.avg(s.hist)) / sd : na
    s.pr := f_pctRank(s.rng, s.hist)
    s.cat := f_categorise(s.z, s.pr)
    array.push(s.hist, s.rng)
    // composite direction (same definition for IB and ORB)
    s.dir := s.formed_first == "low"  and s.cl >= s.mid ? "Bullish" :
             s.formed_first == "high" and s.cl <  s.mid ? "Bearish" : "Neutral"
    if s.show
        box.delete(s.bx)
        line.delete(s.ml)
        s.bx := box.new(s.left_bar, s.hi, bar_index, s.lo, border_color=s.col,
                 bgcolor=color.new(s.col, box_transp), border_width=1)
        s.ml := line.new(s.left_bar, s.mid, bar_index, s.mid,
                 color=color.new(s.col, 40), style=line.style_dashed)
    int _void = 0

method watch(Inst s, bool active) =>
    if active and s.formed and s.broke_first == "none"
        string found = "none"
        if not na(h1m) and array.size(h1m) > 0
            for i = 0 to array.size(h1m) - 1
                bool hb = array.get(h1m, i) >= s.hi
                bool lb = array.get(l1m, i) <= s.lo
                if hb or lb
                    found := hb ? "high" : "low"   // same sub-bar tie -> high
                    break
        else
            bool hb = high >= s.hi
            bool lb = low  <= s.lo
            if hb or lb
                found := hb ? "high" : "low"
        if found != "none"
            s.broke_first := found
    int _void = 0

method tally(Inst s) =>
    if s.formed_first == "high"
        if s.broke_first == "high"
            s.hf_hb += 1
        else if s.broke_first == "low"
            s.hf_lb += 1
        else
            s.hf_nb += 1
    else if s.formed_first == "low"
        if s.broke_first == "high"
            s.lf_hb += 1
        else if s.broke_first == "low"
            s.lf_lb += 1
        else
            s.lf_nb += 1
    int ci = f_catIdx(s.cat)
    if ci >= 0
        array.set(s.ct_tot, ci, array.get(s.ct_tot, ci) + 1)
        if s.broke_first != "none"
            array.set(s.ct_brk, ci, array.get(s.ct_brk, ci) + 1)
            if s.broke_first == s.formed_first
                array.set(s.ct_cont, ci, array.get(s.ct_cont, ci) + 1)
    s.recorded := true
    int _void = 0

f_newInst(string name, color col, bool show) =>
    Inst.new(name=name, col=col, show=show, ltfH=array.new<float>(), ltfL=array.new<float>(),
         hist=array.new<float>(), ct_tot=array.from(0,0,0), ct_brk=array.from(0,0,0),
         ct_cont=array.from(0,0,0))

f_newCont() => Cont.new(m=array.from(0,0,0,0,0,0,0,0,0))

f_recCont(Cont c, string orbDir, string ibDir) =>
    int oi = f_dirIdx(orbDir)
    int ii = f_dirIdx(ibDir)
    if oi >= 0 and ii >= 0
        int k = oi * 3 + ii
        array.set(c.m, k, array.get(c.m, k) + 1)

// ============================================================ STATE + SESSIONS
var ib   = f_newInst("IB", col_ib, show_ib)
var orb  = f_newInst("ORB-" + str.tostring(orb_minutes), col_orb, show_orb)
var cont = f_newCont()        // ORB direction -> IB direction

is_ib  = inSession(ib_session)
is_orb = inSession(orb_session)
in_rth = inSession(rth_session)

// ============================================================ MAIN PROCESSING
ib.reset(is_ib   and not is_ib[1])
orb.reset(is_orb and not is_orb[1])

ib.feed(is_ib)
orb.feed(is_orb)

if is_ib[1]  and not is_ib
    ib.seal()
if is_orb[1] and not is_orb
    orb.seal()

ib.watch(in_rth  and not is_ib)
orb.watch(in_rth and not is_orb)

if in_rth[1] and not in_rth
    if ib.formed  and not ib.recorded
        ib.tally()
    if orb.formed and not orb.recorded
        orb.tally()
    f_recCont(cont, orb.dir, ib.dir)

// NY open vertical line
var line ny_line = na
if show_ny_line and in_rth and not in_rth[1]
    line.delete(ny_line)
    ny_line := line.new(bar_index, low, bar_index, high, color=color.new(col_ny, 40),
         style=line.style_dotted, extend=extend.both, width=1)

// ============================================================ TABLE STYLE
c_hdr  = color.rgb(40,40,40)
c_htxt = color.white
c_sub  = color.rgb(90,90,90)
c_cell = color.white
c_txt  = color.rgb(40,40,40)
c_dim  = color.rgb(150,150,150)
c_bull = color.rgb(0,150,60)
c_bear = color.rgb(200,30,30)
c_neut = color.rgb(130,130,130)
c_grn  = color.green
c_red  = color.red
c_hl   = color.rgb(255,244,200)
c_cont = color.rgb(46,125,50)
mono   = font.family_monospace

f_instSection(table t, int r0, Inst s, string ts) =>
    int r = r0
    table.cell(t, 0, r, "── " + s.name + " ──", bgcolor=c_sub, text_color=c_htxt, text_size=ts, text_font_family=mono)
    table.merge_cells(t, 0, r, 3, r)
    r += 1

    ff  = s.formed_first=="high"?"HIGH":s.formed_first=="low"?"LOW":(s.formed?"—":"pending")
    bf  = s.broke_first=="high"?"HIGH":s.broke_first=="low"?"LOW":(not s.formed?"pending":(in_rth?"watching…":"none"))
    rngtxt = na(s.rng)?"—":str.tostring(s.rng,"#.##") + (na(s.z)?"":"  z="+str.tostring(s.z,"#.#")) + (na(s.pr)?"":"  "+str.tostring(s.pr,"#")+"%")
    catcol = s.cat=="Wide"?c_bear:s.cat=="Narrow"?color.blue:c_txt
    dircol = s.dir=="Bullish"?c_bull:s.dir=="Bearish"?c_bear:c_neut

    table.cell(t,0,r,"Formed first",bgcolor=c_cell,text_color=c_txt,text_size=ts,text_font_family=mono)
    table.cell(t,1,r,ff,bgcolor=c_cell,text_color=c_txt,text_size=ts,text_font_family=mono)
    table.merge_cells(t,1,r,3,r)
    r+=1
    table.cell(t,0,r,"Broke first",bgcolor=c_cell,text_color=c_txt,text_size=ts,text_font_family=mono)
    table.cell(t,1,r,bf,bgcolor=c_cell,text_color=c_txt,text_size=ts,text_font_family=mono)
    table.merge_cells(t,1,r,3,r)
    r+=1
    table.cell(t,0,r,"Range",bgcolor=c_cell,text_color=c_txt,text_size=ts,text_font_family=mono)
    table.cell(t,1,r,rngtxt,bgcolor=c_cell,text_color=c_txt,text_size=ts,text_font_family=mono)
    table.merge_cells(t,1,r,3,r)
    r+=1
    table.cell(t,0,r,"Type",bgcolor=c_cell,text_color=c_txt,text_size=ts,text_font_family=mono)
    table.cell(t,1,r,s.cat,bgcolor=c_cell,text_color=catcol,text_size=ts,text_font_family=mono)
    table.merge_cells(t,1,r,3,r)
    r+=1
    table.cell(t,0,r,"Direction",bgcolor=c_cell,text_color=c_txt,text_size=ts,text_font_family=mono)
    table.cell(t,1,r,s.dir,bgcolor=c_cell,text_color=dircol,text_size=ts,text_font_family=mono)
    table.merge_cells(t,1,r,3,r)
    r+=1

    int hf = s.hf_hb+s.hf_lb+s.hf_nb
    int lf = s.lf_hb+s.lf_lb+s.lf_nb
    int allt = hf+lf
    float cont = f_pct(s.hf_hb+s.lf_lb, allt)
    table.cell(t,0,r,"Formed1st",bgcolor=c_hdr,text_color=c_htxt,text_size=ts,text_font_family=mono)
    table.cell(t,1,r,"BrkH",bgcolor=c_hdr,text_color=c_htxt,text_size=ts,text_font_family=mono)
    table.cell(t,2,r,"BrkL",bgcolor=c_hdr,text_color=c_htxt,text_size=ts,text_font_family=mono)
    table.cell(t,3,r,"Neither",bgcolor=c_hdr,text_color=c_htxt,text_size=ts,text_font_family=mono)
    r+=1
    hg = hf<min_sample?c_dim:c_grn
    hr = hf<min_sample?c_dim:c_red
    table.cell(t,0,r,"HIGH("+str.tostring(hf)+")",bgcolor=c_cell,text_color=c_txt,text_size=ts,text_font_family=mono)
    table.cell(t,1,r,f_pstr(f_pct(s.hf_hb,hf)),bgcolor=c_cell,text_color=hg,text_size=ts,text_font_family=mono)
    table.cell(t,2,r,f_pstr(f_pct(s.hf_lb,hf)),bgcolor=c_cell,text_color=hr,text_size=ts,text_font_family=mono)
    table.cell(t,3,r,f_pstr(f_pct(s.hf_nb,hf)),bgcolor=c_cell,text_color=c_txt,text_size=ts,text_font_family=mono)
    r+=1
    lg = lf<min_sample?c_dim:c_grn
    lr = lf<min_sample?c_dim:c_red
    table.cell(t,0,r,"LOW("+str.tostring(lf)+")",bgcolor=c_cell,text_color=c_txt,text_size=ts,text_font_family=mono)
    table.cell(t,1,r,f_pstr(f_pct(s.lf_hb,lf)),bgcolor=c_cell,text_color=lg,text_size=ts,text_font_family=mono)
    table.cell(t,2,r,f_pstr(f_pct(s.lf_lb,lf)),bgcolor=c_cell,text_color=lr,text_size=ts,text_font_family=mono)
    table.cell(t,3,r,f_pstr(f_pct(s.lf_nb,lf)),bgcolor=c_cell,text_color=c_txt,text_size=ts,text_font_family=mono)
    r+=1
    table.cell(t,0,r,"Same side broke 1st",bgcolor=c_cont,text_color=color.white,text_size=ts,text_font_family=mono)
    table.cell(t,1,r,f_pstr(cont),bgcolor=c_cont,text_color=color.white,text_size=ts,text_font_family=mono)
    table.merge_cells(t,1,r,3,r)
    r+=1

    table.cell(t,0,r,"── BY SIZE ──",bgcolor=c_sub,text_color=c_htxt,text_size=ts,text_font_family=mono)
    table.merge_cells(t,0,r,3,r)
    r+=1
    table.cell(t,0,r,"Size",bgcolor=c_hdr,text_color=c_htxt,text_size=ts,text_font_family=mono)
    table.cell(t,1,r,"n",bgcolor=c_hdr,text_color=c_htxt,text_size=ts,text_font_family=mono)
    table.cell(t,2,r,"Brk%",bgcolor=c_hdr,text_color=c_htxt,text_size=ts,text_font_family=mono)
    table.cell(t,3,r,"Cont%",bgcolor=c_hdr,text_color=c_htxt,text_size=ts,text_font_family=mono)
    r+=1
    names = array.from("Narrow","Normal","Wide")
    for ci = 0 to 2
        int tot = array.get(s.ct_tot,ci)
        bp = f_pct(array.get(s.ct_brk,ci),tot)
        cp = f_pct(array.get(s.ct_cont,ci),tot)
        hl   = s.cat==array.get(names,ci)?c_hl:c_cell
        tcol = tot<min_sample?c_dim:c_txt
        table.cell(t,0,r,array.get(names,ci),bgcolor=hl,text_color=tcol,text_size=ts,text_font_family=mono)
        table.cell(t,1,r,str.tostring(tot),bgcolor=hl,text_color=tcol,text_size=ts,text_font_family=mono)
        table.cell(t,2,r,f_pstr(bp),bgcolor=hl,text_color=tcol,text_size=ts,text_font_family=mono)
        table.cell(t,3,r,f_pstr(cp),bgcolor=hl,text_color=tcol,text_size=ts,text_font_family=mono)
        r+=1
    r

f_contSection(table t, int r0, string title, Cont c, string ts) =>
    int r = r0
    table.cell(t,0,r,title,bgcolor=c_sub,text_color=c_htxt,text_size=ts,text_font_family=mono)
    table.merge_cells(t,0,r,3,r)
    r+=1
    table.cell(t,0,r,"Given",bgcolor=c_hdr,text_color=c_htxt,text_size=ts,text_font_family=mono)
    table.cell(t,1,r,"IB Bull",bgcolor=c_hdr,text_color=c_htxt,text_size=ts,text_font_family=mono)
    table.cell(t,2,r,"IB Bear",bgcolor=c_hdr,text_color=c_htxt,text_size=ts,text_font_family=mono)
    table.cell(t,3,r,"IB Neut",bgcolor=c_hdr,text_color=c_htxt,text_size=ts,text_font_family=mono)
    r+=1
    int bt = array.get(c.m,0)+array.get(c.m,1)+array.get(c.m,2)
    btc = bt<min_sample?c_dim:c_txt
    table.cell(t,0,r,"Bullish("+str.tostring(bt)+")",bgcolor=c_cell,text_color=btc,text_size=ts,text_font_family=mono)
    table.cell(t,1,r,f_pstr(f_pct(array.get(c.m,0),bt)),bgcolor=c_cell,text_color=bt<min_sample?c_dim:c_bull,text_size=ts,text_font_family=mono)
    table.cell(t,2,r,f_pstr(f_pct(array.get(c.m,1),bt)),bgcolor=c_cell,text_color=bt<min_sample?c_dim:c_bear,text_size=ts,text_font_family=mono)
    table.cell(t,3,r,f_pstr(f_pct(array.get(c.m,2),bt)),bgcolor=c_cell,text_color=btc,text_size=ts,text_font_family=mono)
    r+=1
    int et = array.get(c.m,3)+array.get(c.m,4)+array.get(c.m,5)
    etc = et<min_sample?c_dim:c_txt
    table.cell(t,0,r,"Bearish("+str.tostring(et)+")",bgcolor=c_cell,text_color=etc,text_size=ts,text_font_family=mono)
    table.cell(t,1,r,f_pstr(f_pct(array.get(c.m,3),et)),bgcolor=c_cell,text_color=et<min_sample?c_dim:c_bull,text_size=ts,text_font_family=mono)
    table.cell(t,2,r,f_pstr(f_pct(array.get(c.m,4),et)),bgcolor=c_cell,text_color=et<min_sample?c_dim:c_bear,text_size=ts,text_font_family=mono)
    table.cell(t,3,r,f_pstr(f_pct(array.get(c.m,5),et)),bgcolor=c_cell,text_color=etc,text_size=ts,text_font_family=mono)
    r+=1
    r

// ============================================================ BUILD TABLES
var table t_ib  = na
var table t_orb = na

if barstate.islast
    // ── IB table ──
    if show_ib_table
        table.delete(t_ib)
        t_ib := table.new(f_tbl_pos(ib_tbl_pos), 4, 16, border_width=1,
             border_color=color.rgb(180,180,180), bgcolor=c_cell)
        ts_ib = f_tbl_sz(ib_tbl_size)
        int r = 0
        table.cell(t_ib, 0, r, "IB LIVE STATS", bgcolor=c_hdr, text_color=c_htxt,
             text_size=ts_ib, text_font_family=mono)
        table.merge_cells(t_ib, 0, r, 3, r)
        r += 1
        r := f_instSection(t_ib, r, ib, ts_ib)

    // ── ORB table (single ORB block + ORB→IB contingency) ──
    if show_orb_table
        table.delete(t_orb)
        t_orb := table.new(f_tbl_pos(orb_tbl_pos), 4, 20, border_width=1,
             border_color=color.rgb(180,180,180), bgcolor=c_cell)
        ts_orb = f_tbl_sz(orb_tbl_size)
        int r2 = 0
        table.cell(t_orb, 0, r2, "ORB LIVE STATS", bgcolor=c_hdr, text_color=c_htxt,
             text_size=ts_orb, text_font_family=mono)
        table.merge_cells(t_orb, 0, r2, 3, r2)
        r2 += 1
        r2 := f_instSection(t_orb, r2, orb, ts_orb)
        r2 := f_contSection(t_orb, r2, "ORB-" + str.tostring(orb_minutes) + " → IB (dir)", cont, ts_orb)
````
