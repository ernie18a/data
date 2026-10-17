# Gap Closure Stats

- url: https://www.tradingview.com/script/cvLg0iuA-Gap-Closure-Stats/
- type: indicator
- pine_id: PUB;3352e46189554d1d8c250cbf0e82e827
- version: 2.0

## Description

# Gap Closure Stats — Publication Description

---

## What This Indicator Does

**Gap Closure Stats** tracks the gap between each session's **4:15pm ET close** (the anchor price) and up to three configurable **opening prices** — by default the midnight open (00:00 ET), the London/European open (03:00 ET), and the RTH open (09:30 ET). For each of those levels it draws a coloured box on the chart spanning from the anchor price to the opening price, and records statistics on how often price subsequently fills that gap during the regular trading session.

Every percentage in the stats table is computed **live, from the history on your own chart**. There are no hard-coded numbers. The statistics describe exactly the instrument and timeframe you are looking at, and they update automatically as new sessions complete.

The indicator answers a core structural question about daily price behaviour:

- Given a gap of a certain size between yesterday's 4:15pm close and today's open, how often does price retrace back to that 4:15pm level (a full gap fill)?
- How often does price retrace at least a defined partial amount of the gap?
- Do these tendencies differ depending on whether the gap is up or down?
- Do they change when the gap is unusually large or small relative to recent history?

It is an analytical and contextual tool. It does not issue buy or sell signals.

---

## Core Concepts and Definitions

### The Anchor Price (4:15pm ET Close)

The reference price for each trading day is the **close of the 4:15pm ET bar** from the prior session. This is captured during a narrow one-minute anchor session (default 16:15–16:16 ET). The anchor represents where the market last traded before overnight activity begins, and it is the level that a "gap fill" requires price to return to.

### The Gap

A gap exists when the opening price at one of the three configurable levels differs from the anchor. If the opening price is **above** the anchor, the gap is **up** — price has gapped higher overnight and a fill means price would need to fall back to the anchor. If the opening price is **below** the anchor, the gap is **down** — price would need to rally back to fill it.

The **gap size** in points is the absolute difference between the anchor and the opening price.

### Gap Size Buckets (Quartiles vs. History)

Each day's gap size is classified into one of four buckets based on where it falls in the **historical distribution of all prior gaps** on your chart:

- **Q1 (0–25th percentile)** — the smallest gaps relative to history
- **Q2 (25–50th percentile)** — below-median gaps
- **Q3 (50–75th percentile)** — above-median gaps
- **Q4 (75–100th percentile)** — the largest gaps relative to history

This classification requires at least 4 prior sessions of data before it becomes meaningful. On very fresh charts, all gaps are assigned to Q2 until enough history accumulates. The bucket thresholds update as each new session completes.

### Full Gap Fill (Hit%)

A **full gap fill** (labelled **FULL%** in the table) is recorded when price trades at or through the anchor price at any point during the RTH session (09:30–16:00 ET). It does not matter whether price opens, then reverses immediately, or whether it fills the gap hours later — any intraday touch of the anchor counts.

### Partial Gap Fill (≥X%)

The **partial fill level** is user-configurable (default 50%). A partial fill is recorded when price retraces at least that percentage of the gap back toward the anchor from the opening price. For example, with a 50% setting: if the gap up is 10 points (open is 10 points above the 4:15pm close), a partial fill is recorded when price falls to within 5 points of the open (i.e. 5 points back toward the anchor). A 100% setting makes this equivalent to FULL% — a complete gap fill.

### The Three Gap Levels

The indicator captures three independent opening prices, each at a configurable time:

- **Level 1** — defaults to the **RTH open at 09:30 ET**. This is the most widely watched gap — the difference between the prior day's 4:15pm close and the next day's regular-session open.
- **Level 2** — defaults to the **03:00 ET open** (broadly the London/European futures open). This captures the gap that existed when European trading began.
- **Level 3** — defaults to the **midnight (00:00 ET) open**. This captures the initial overnight gap that formed at the start of the new calendar day.

Each level builds its own independent statistics, so you can compare how gap-fill behaviour differs across these three time windows.

### Level Quartile (LQ)

For the current session, the **level quartile** describes where the opening price of each level sits **within the gap box** — i.e. how far into the gap that level's open was relative to the full anchor-to-RTH-open range. LQ1 means the level opened very close to the RTH open (near the far edge of the gap), LQ4 means it opened very close to the anchor (near full-fill territory already).

---

## What You See on the Chart

### Gap Boxes

For each active level, a shaded box is drawn spanning from the **anchor price** to the **opening price** at that level's time. The box extends rightward through the session, stopping at 4:15pm ET. The box colour matches the level's configured colour (default: purple for Level 1, blue for Level 2, teal for Level 3). Boxes are shown only when there is a genuine gap — if the opening price equals the anchor, no box is drawn.

### Quartile Lines Inside Boxes

When enabled, three dashed/solid lines are drawn inside each gap box, dividing it into four equal price quartiles:

- **Q1 line (dashed)** — 25% of the way from the opening price toward the anchor
- **Q2 line (solid)** — the midpoint of the gap (50%)
- **Q3 line (dashed)** — 75% of the way toward the anchor

These help you gauge how far price has retraced into the gap at a glance, and they correspond to the Level Quartile (LQ) measure in the stats table.

### Opening Price Lines

A dotted line is drawn at each level's opening price for the session and extends rightward to 4:15pm, giving a persistent visual reference for where each gap began.

### Session History

The indicator keeps and displays the last N sessions (configurable, default 10). Older boxes and lines are automatically removed as new sessions are added, keeping the chart uncluttered.

---

## The Stats Table, Explained Column by Column

The stats table has one block of four rows per level. Each block breaks down the statistics for that level across the four gap-size quartile buckets.

### Row structure

Each row corresponds to one **gap size bucket** (Q1 through Q4). The row currently matching today's session is highlighted in grey.

### Columns

**LEVEL** — identifies which opening level the block belongs to (shown as the configured session string, e.g. `0930-0931`). The label is coloured to match the level's chart colour.

**GAP SIZE BUCKET (vs history)** — the quartile label for that row:
- `0–25%ile (smallest gaps)` — Q1
- `25–50%ile` — Q2
- `50–75%ile` — Q3
- `75–100%ile (largest gaps)` — Q4

**GAP UP — N** — the number of completed sessions where the gap was **up** (open above anchor) and fell in this size bucket.

**GAP UP — FULL%** — of those sessions, the percentage where price returned to the anchor at any point during RTH. This is the full gap fill rate for up-gaps of this size.

**GAP UP — ≥X%** — of those sessions, the percentage where price retraced at least the configured partial fill percentage back toward the anchor. At the default 50% setting, this is how often the market covered at least half the gap.

**GAP UP — AVG GAP** — the average gap size in points for up-gap sessions in this bucket.

**GAP DOWN — N / FULL% / ≥X% / AVG GAP** — the same four columns as above, but for sessions where the gap was **down** (open below anchor).

**CURRENT SESSION — GAP-Q / LVL-Q** — visible only on the row matching today's gap size bucket, and only when a level has fired today. Shows two numbers:
- **GQ** — the gap size quartile for today (GQ1 = smallest, GQ4 = largest)
- **LQ** — the level quartile, indicating where that level's open sits within today's overall gap box (LQ1 = close to the RTH open, LQ4 = close to the anchor)

---

## How To Configure the Indicator

### Anchor Settings

**Anchor Session (4:15pm)** — the one-minute session window used to capture the previous session's closing price. The default `1615-1616` captures the 4:15pm ET bar close. Only change this if your instrument's reference close is at a different time.

### Gap Times

These three groups configure the three independent opening levels. Each has the same three inputs:

**Level X Open Time** — a TradingView session string defining the one-minute window at which the opening price is captured. The default sessions are:
- Level 1: `0930-0931` (RTH open)
- Level 2: `0300-0301` (European open)
- Level 3: `0000-0001` (Midnight ET)

You can change any of these to any time of day. Common alternatives include the 08:30 ET futures open (`0830-0831`) or the London open (`0800-0801`). The level fires once per calendar day at the first bar inside that window, and only if the anchor has already been set.

**Level X Color** — the colour used for that level's box, lines, and table label.

**Show Level X** — master toggle. When off, the level's boxes and lines are hidden and its rows are omitted from the stats table.

### Gap Fill Stat

**Partial Fill Level (%)** — controls what counts as a partial fill, from 1% to 100%. At 50% (default), the ≥X% column in the table tracks how often price retraced at least halfway back to the anchor. Set this to 100% to track only complete fills, or to a lower value such as 25% to track more modest retracements. The column header in the table updates to reflect your chosen value (e.g. `≥50.0%`).

### Visuals

**Show Gap Boxes (per level)** — toggles the shaded gap boxes on or off for all levels. The opening-price dotted lines are still drawn when this is off.

**Show Quartile Lines Inside Boxes** — toggles the three internal Q1/Q2/Q3 division lines inside each gap box.

**Keep Last N Sessions** — how many sessions of boxes and lines to retain on the chart. Higher values give more context but can clutter the chart. Default is 10.

### Stats Table

**Position** — one of nine positions on the chart for the stats table (top/middle/bottom × left/center/right). Default is `bottom_right`.

**Text Size** — `tiny`, `small`, `normal`, or `large`. Default is `small`. Use `tiny` on smaller screens or when all three levels are shown simultaneously.

---

## Practical Tips for Interpreting the Statistics

**Focus on N first.** A FULL% or ≥X% figure is only meaningful with an adequate sample size. Rows with small N values (especially Q4, which by definition can only contain 25% of all sessions) should be read cautiously. As a general guide, treat any figure based on fewer than 20–30 sessions as directionally interesting but not statistically reliable.

**Compare up vs. down gaps.** Many instruments show different fill rates for up-gaps versus down-gaps. A market that fills up-gaps 80% of the time but down-gaps only 50% of the time has a structural asymmetry worth knowing about.

**Use the size buckets to understand context.** The quartile split reveals whether gap-fill behaviour is consistent across all gap sizes or whether it changes materially. For example, small gaps (Q1) may fill at very high rates while large gaps (Q4) fill much less often — or vice versa. Today's highlighted row tells you which regime today's gap falls into.

**The partial fill column adds nuance.** Even when FULL% is modest, the ≥50% column may be high, suggesting price often makes a meaningful but incomplete move back toward the anchor. This can be useful context for targets and stops.

**The current session column (GAP-Q / LVL-Q)** tells you at a glance where today sits historically. GQ4 / LQ2 would mean today has a historically large gap, and Level 2 opened roughly in the middle of that gap — already halfway to a fill before the RTH session began.

**Compare levels against each other.** If Level 3 (midnight open) shows a higher fill rate than Level 1 (RTH open), it may indicate that much of the gap-filling happens during the overnight and pre-market session before RTH begins. If Level 1 shows a higher fill rate, the RTH session is where fills predominantly occur.

---

## Important Limitations and Considerations

1. **Levels must fire after midnight ET.** Because the indicator resets its session state once per calendar day in Eastern Time, a level's open time must fall on or after 00:00 ET for it to be captured correctly for that calendar day. If you configure a level earlier than midnight ET (which would be the prior afternoon), it will not associate correctly with the next day's anchor. The three defaults (00:00, 03:00, 09:30) all respect this constraint.

2. **The indicator requires an anchor from the prior session.** On the very first bar of a chart's history (or after a gap in data), there is no prior 4:15pm close available and no gap is measured for that day. This is normal behaviour and those sessions are simply skipped.

3. **Gap size quartile buckets need history to calibrate.** Until at least 4 prior gaps have been recorded, all sessions are assigned to Q2. The quartile thresholds update as history grows, so the bucket assignments for earlier sessions may shift over time as more data accumulates. This is by design — the buckets are always relative to all available history, not a fixed absolute threshold.

4. **All times are Eastern Time (ET).** The indicator uses the `America/New_York` timezone for all session windows. If your chart's timezone is set differently, the session windows still fire at the correct ET times — but the visual bar positions will correspond to your chart's local timezone.

5. **The stats table only shows levels that are enabled.** If you turn off Level 2, its rows are removed from the table and its data is no longer accumulated. Stats accumulate only for sessions where a level is enabled, so disabling and re-enabling a level mid-history will cause a gap in its data.

6. **Descriptive, not predictive.** The indicator reports what has happened on your chart's history. Past fill rates do not guarantee future behaviour. A 75% full-fill rate means the gap did not fill 25% of the time. These statistics provide context, not certainty, and should be used alongside your own analysis and risk management.

7. **Not financial advice.** This is an analytical and educational tool. It does not provide buy or sell signals and makes no claim about future price direction.

---

*Gap Closure Stats computes everything from the sessions on your own chart — no external data, no hard-coded numbers. The statistics are only as reliable as the history available on your chart.*

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © notprofessorgreen

// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

//@version=6
indicator("Gap Closure Stats", "Gaps", true, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────

var g_ANC = "Anchor Settings"
anchor_session = input.session("1615-1616", "Anchor Session (4:15pm)", tooltip = "Session used to capture the 4:15pm close as the gap reference price", group = g_ANC)

var g_GAP = "Gap Times"
open_time_1 = input.session("0930-0931", "Level 1 Open Time", group = g_GAP)
col_1       = input.color(color.rgb(180, 0, 255), "Level 1 Color", group = g_GAP)
show_1      = input.bool(true, "Show Level 1", group = g_GAP)

open_time_2 = input.session("0300-0301", "Level 2 Open Time", group = g_GAP)
col_2       = input.color(color.rgb(0, 120, 255), "Level 2 Color", group = g_GAP)
show_2      = input.bool(true, "Show Level 2", group = g_GAP)

open_time_3 = input.session("0000-0001", "Level 3 Open Time", group = g_GAP)
col_3       = input.color(color.rgb(0, 200, 180), "Level 3 Color", group = g_GAP)
show_3      = input.bool(true, "Show Level 3", group = g_GAP)

var g_STAT = "Gap Fill Stat"
fill_pct = input.float(50.0, "Partial Fill Level (%)", minval = 1, maxval = 100, step = 5, tooltip = "Tracks how often price retraces this % of the gap from each level's own open back toward the 4:15 level (100% = full fill).", group = g_STAT)

var g_VIZ = "Visuals"
show_boxes   = input.bool(true, "Show Gap Boxes (per level)", group = g_VIZ)
show_qtiles  = input.bool(true, "Show Quartile Lines Inside Boxes", group = g_VIZ)
keep_last    = input.int(10, "Keep Last N Sessions", minval = 1, group = g_VIZ)

var g_TBL = "Stats Table"
tbl_pos      = input.string("bottom_right", "Position", options = ["top_left","top_center","top_right","middle_left","middle_center","middle_right","bottom_left","bottom_center","bottom_right"], group = g_TBL)
tbl_txt_size = input.string("small", "Text Size", options = ["tiny","small","normal","large"], group = g_TBL)


// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────

f_tbl_pos(string s) =>
    switch s
        "top_left"      => position.top_left
        "top_center"    => position.top_center
        "top_right"     => position.top_right
        "middle_left"   => position.middle_left
        "middle_center" => position.middle_center
        "middle_right"  => position.middle_right
        "bottom_left"   => position.bottom_left
        "bottom_center" => position.bottom_center
        => position.bottom_right

f_tbl_sz(string s) =>
    switch s
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        => size.large

f_quartile(float price, float gap_top, float gap_bot, bool gap_up) =>
    h = gap_top - gap_bot
    if h == 0
        0
    else
        norm = gap_up ? (price - gap_bot) / h : (gap_top - price) / h
        norm <= 0.25 ? 4 : norm <= 0.5 ? 3 : norm <= 0.75 ? 2 : 1

// ─────────────────────────────────────────────
// STATE TYPES
// ─────────────────────────────────────────────

// idx = dir*4 + gap_qbkt  (dir: 0=up, 1=dn; gap_qbkt: 0-3)
type LevelStats
    int[]   sessions
    int[]   hits
    float[] sum_gap
    int[]   pfills

f_new_stats() =>
    LevelStats.new(array.new_int(8, 0), array.new_int(8, 0), array.new_float(8, 0.0), array.new_int(8, 0))

// Each level now tracks its own gap (anchor vs. that level's own open), and its own
// touch / partial-fill outcome, instead of sharing the 9:30 (Level 1) gap for everything.
type SessionState
    float anchor
    float day_open        // true 9:30 RTH open — used only for the "current session" LVL-Q display
    bool  gap_ready        // true once the 9:30 RTH open has printed this session
    bool  l1_fired
    bool  l2_fired
    bool  l3_fired
    float l1_price
    float l2_price
    float l3_price
    float l1_gap_pts
    float l2_gap_pts
    float l3_gap_pts
    bool  l1_gap_up
    bool  l2_gap_up
    bool  l3_gap_up
    int   l1_bkt
    int   l2_bkt
    int   l3_bkt
    bool  l1_touched
    bool  l2_touched
    bool  l3_touched
    bool  l1_partial_filled
    bool  l2_partial_filled
    bool  l3_partial_filled

// ─────────────────────────────────────────────
// PERSISTENT STATE
// ─────────────────────────────────────────────

var float prev_anchor = na
var SessionState sess = SessionState.new(anchor = na, day_open = na, gap_ready = false, l1_fired = false, l2_fired = false, l3_fired = false, l1_price = na, l2_price = na, l3_price = na, l1_gap_pts = na, l2_gap_pts = na, l3_gap_pts = na, l1_gap_up = false, l2_gap_up = false, l3_gap_up = false, l1_bkt = 0, l2_bkt = 0, l3_bkt = 0, l1_touched = false, l2_touched = false, l3_touched = false, l1_partial_filled = false, l2_partial_filled = false, l3_partial_filled = false)
var LevelStats s1      = f_new_stats()
var LevelStats s2      = f_new_stats()
var LevelStats s3      = f_new_stats()

// Separate gap-size history per level, since each level's own gap can have a very
// different size distribution (overnight gap vs. pre-market gap vs. RTH gap).
var float[] all_gaps1  = array.new_float()
var float[] all_gaps2  = array.new_float()
var float[] all_gaps3  = array.new_float()

var line[] anc_lines = array.new_line()

var box[]  lv1_boxes = array.new_box()
var box[]  lv2_boxes = array.new_box()
var box[]  lv3_boxes = array.new_box()

var line[] lv1_lines = array.new_line()
var line[] lv2_lines = array.new_line()
var line[] lv3_lines = array.new_line()

var line[] lv1_qa = array.new_line()
var line[] lv1_qb = array.new_line()
var line[] lv1_qc = array.new_line()
var line[] lv2_qa = array.new_line()
var line[] lv2_qb = array.new_line()
var line[] lv2_qc = array.new_line()
var line[] lv3_qa = array.new_line()
var line[] lv3_qb = array.new_line()
var line[] lv3_qc = array.new_line()

// ─────────────────────────────────────────────
// TIME CHECKS
// ─────────────────────────────────────────────

t_anchor        = not na(time("", anchor_session, "America/New_York"))
t1              = not na(time("", open_time_1,    "America/New_York"))
t2              = not na(time("", open_time_2,    "America/New_York"))
t3              = not na(time("", open_time_3,    "America/New_York"))
regular_session = not na(time("", "0930-1600",    "America/New_York"))
rth_open        = regular_session and not regular_session[1]
end_of_session  = not regular_session and regular_session[1]

et_day     = dayofmonth(time, "America/New_York")
new_et_day = not na(et_day[1]) and et_day != et_day[1]

// Right-edge window: all boxes/lines always extend to 4:15pm
et_h = hour(time, "America/New_York")
et_m = minute(time, "America/New_York")
before_930    = et_h < 9  or (et_h == 9  and et_m <= 30)
before_415    = et_h < 16 or (et_h == 16 and et_m <= 15)

// ─────────────────────────────────────────────
// ANCHOR CAPTURE  (4:15pm close)
// ─────────────────────────────────────────────

if not t_anchor and t_anchor[1]
    prev_anchor := close[1]

if t_anchor and not t_anchor[1] and na(prev_anchor)
    prev_anchor := close

// ─────────────────────────────────────────────
// SESSION RESET  (start of each ET day) — state only
// ─────────────────────────────────────────────

if new_et_day and not na(prev_anchor)
    sess.anchor    := prev_anchor
    sess.day_open  := na
    sess.gap_ready := false
    sess.l1_fired  := false
    sess.l2_fired  := false
    sess.l3_fired  := false
    sess.l1_price  := na
    sess.l2_price  := na
    sess.l3_price  := na
    sess.l1_gap_pts := na
    sess.l2_gap_pts := na
    sess.l3_gap_pts := na
    sess.l1_gap_up := false
    sess.l2_gap_up := false
    sess.l3_gap_up := false
    sess.l1_bkt    := 0
    sess.l2_bkt    := 0
    sess.l3_bkt    := 0
    sess.l1_touched := false
    sess.l2_touched := false
    sess.l3_touched := false
    sess.l1_partial_filled := false
    sess.l2_partial_filled := false
    sess.l3_partial_filled := false

// ─────────────────────────────────────────────
// GAP SIZE QUARTILE BUCKET (vs that level's own history)
// ─────────────────────────────────────────────

f_gap_bucket(float[] hist, float gap_abs) =>
    n = hist.size()
    if n < 4
        1
    else
        sorted = hist.copy()
        sorted.sort()
        p25 = sorted.get(math.floor(n * 0.25))
        p50 = sorted.get(math.floor(n * 0.50))
        p75 = sorted.get(math.floor(n * 0.75))
        gap_abs <= p25 ? 0 : gap_abs <= p50 ? 1 : gap_abs <= p75 ? 2 : 3

// ─────────────────────────────────────────────
// TRUE 9:30 RTH OPEN  — only used as the reference frame for the "current session"
// LVL-Q display further down (where each level's own price sat inside today's actual gap).
// ─────────────────────────────────────────────

if rth_open and not na(sess.anchor)
    sess.day_open  := open
    sess.gap_ready := true

// ─────────────────────────────────────────────
// TOUCH / PARTIAL-FILL DETECTION  (RTH only — defines HIT% and the partial-fill %)
// Computed independently per level, against that level's OWN open price and gap,
// not the shared 9:30 gap.
// ─────────────────────────────────────────────

if regular_session and not na(sess.anchor)
    if sess.l1_fired and not sess.l1_touched
        if high >= sess.anchor and low <= sess.anchor
            sess.l1_touched := true
    if sess.l2_fired and not sess.l2_touched
        if high >= sess.anchor and low <= sess.anchor
            sess.l2_touched := true
    if sess.l3_fired and not sess.l3_touched
        if high >= sess.anchor and low <= sess.anchor
            sess.l3_touched := true

    if sess.l1_fired and not sess.l1_partial_filled and not na(sess.l1_gap_pts) and math.abs(sess.l1_gap_pts) > 0
        fill_level_1 = sess.l1_price + (fill_pct / 100.0) * sess.l1_gap_pts
        if (sess.l1_gap_up and low <= fill_level_1) or (not sess.l1_gap_up and high >= fill_level_1)
            sess.l1_partial_filled := true

    if sess.l2_fired and not sess.l2_partial_filled and not na(sess.l2_gap_pts) and math.abs(sess.l2_gap_pts) > 0
        fill_level_2 = sess.l2_price + (fill_pct / 100.0) * sess.l2_gap_pts
        if (sess.l2_gap_up and low <= fill_level_2) or (not sess.l2_gap_up and high >= fill_level_2)
            sess.l2_partial_filled := true

    if sess.l3_fired and not sess.l3_partial_filled and not na(sess.l3_gap_pts) and math.abs(sess.l3_gap_pts) > 0
        fill_level_3 = sess.l3_price + (fill_pct / 100.0) * sess.l3_gap_pts
        if (sess.l3_gap_up and low <= fill_level_3) or (not sess.l3_gap_up and high >= fill_level_3)
            sess.l3_partial_filled := true

// ─────────────────────────────────────────────
// LEVEL SNAPSHOTS  (each level captures its own gap vs. the anchor, and draws its
// own anchor↔price box + line)
// ─────────────────────────────────────────────

if t1 and not t1[1] and not sess.l1_fired and not na(sess.anchor)
    sess.l1_fired   := true
    sess.l1_price   := open
    sess.l1_gap_pts := sess.anchor - open
    sess.l1_gap_up  := open > sess.anchor
    sess.l1_bkt     := f_gap_bucket(all_gaps1, math.abs(sess.l1_gap_pts))
    if math.abs(sess.l1_gap_pts) > 0
        all_gaps1.push(math.abs(sess.l1_gap_pts))
    if show_1
        gtop = math.max(sess.anchor, open)
        gbot = math.min(sess.anchor, open)
        bc = color.new(col_1, 80)
        if show_boxes and gtop > gbot
            b = box.new(time, gtop, time, gbot, xloc = xloc.bar_time, bgcolor = bc, border_color = color.new(bc, 0), extend = extend.none, force_overlay = true)
            lv1_boxes.unshift(b)
            if lv1_boxes.size() > keep_last
                box.delete(lv1_boxes.pop())
            if show_qtiles
                qr = (gtop - gbot) / 4
                lc = color.new(bc, 30)
                lv1_qa.unshift(line.new(time, gtop - qr,     time, gtop - qr,     xloc = xloc.bar_time, color = lc, style = line.style_dashed, force_overlay = true))
                lv1_qb.unshift(line.new(time, gtop - qr * 2, time, gtop - qr * 2, xloc = xloc.bar_time, color = lc, style = line.style_solid,  force_overlay = true))
                lv1_qc.unshift(line.new(time, gtop - qr * 3, time, gtop - qr * 3, xloc = xloc.bar_time, color = lc, style = line.style_dashed, force_overlay = true))
                if lv1_qa.size() > keep_last
                    line.delete(lv1_qa.pop())
                    line.delete(lv1_qb.pop())
                    line.delete(lv1_qc.pop())
        ln = line.new(time, open, time, open, xloc = xloc.bar_time, color = col_1, style = line.style_dotted, width = 2, force_overlay = true)
        lv1_lines.unshift(ln)
        if lv1_lines.size() > keep_last
            line.delete(lv1_lines.pop())

if t2 and not t2[1] and not sess.l2_fired and not na(sess.anchor)
    sess.l2_fired   := true
    sess.l2_price   := open
    sess.l2_gap_pts := sess.anchor - open
    sess.l2_gap_up  := open > sess.anchor
    sess.l2_bkt     := f_gap_bucket(all_gaps2, math.abs(sess.l2_gap_pts))
    if math.abs(sess.l2_gap_pts) > 0
        all_gaps2.push(math.abs(sess.l2_gap_pts))
    if show_2
        gtop = math.max(sess.anchor, open)
        gbot = math.min(sess.anchor, open)
        bc = color.new(col_2, 80)
        if show_boxes and gtop > gbot
            b = box.new(time, gtop, time, gbot, xloc = xloc.bar_time, bgcolor = bc, border_color = color.new(bc, 0), extend = extend.none, force_overlay = true)
            lv2_boxes.unshift(b)
            if lv2_boxes.size() > keep_last
                box.delete(lv2_boxes.pop())
            if show_qtiles
                qr = (gtop - gbot) / 4
                lc = color.new(bc, 30)
                lv2_qa.unshift(line.new(time, gtop - qr,     time, gtop - qr,     xloc = xloc.bar_time, color = lc, style = line.style_dashed, force_overlay = true))
                lv2_qb.unshift(line.new(time, gtop - qr * 2, time, gtop - qr * 2, xloc = xloc.bar_time, color = lc, style = line.style_solid,  force_overlay = true))
                lv2_qc.unshift(line.new(time, gtop - qr * 3, time, gtop - qr * 3, xloc = xloc.bar_time, color = lc, style = line.style_dashed, force_overlay = true))
                if lv2_qa.size() > keep_last
                    line.delete(lv2_qa.pop())
                    line.delete(lv2_qb.pop())
                    line.delete(lv2_qc.pop())
        ln = line.new(time, open, time, open, xloc = xloc.bar_time, color = col_2, style = line.style_dotted, width = 2, force_overlay = true)
        lv2_lines.unshift(ln)
        if lv2_lines.size() > keep_last
            line.delete(lv2_lines.pop())

if t3 and not t3[1] and not sess.l3_fired and not na(sess.anchor)
    sess.l3_fired   := true
    sess.l3_price   := open
    sess.l3_gap_pts := sess.anchor - open
    sess.l3_gap_up  := open > sess.anchor
    sess.l3_bkt     := f_gap_bucket(all_gaps3, math.abs(sess.l3_gap_pts))
    if math.abs(sess.l3_gap_pts) > 0
        all_gaps3.push(math.abs(sess.l3_gap_pts))
    if show_3
        gtop = math.max(sess.anchor, open)
        gbot = math.min(sess.anchor, open)
        bc = color.new(col_3, 80)
        if show_boxes and gtop > gbot
            b = box.new(time, gtop, time, gbot, xloc = xloc.bar_time, bgcolor = bc, border_color = color.new(bc, 0), extend = extend.none, force_overlay = true)
            lv3_boxes.unshift(b)
            if lv3_boxes.size() > keep_last
                box.delete(lv3_boxes.pop())
            if show_qtiles
                qr = (gtop - gbot) / 4
                lc = color.new(bc, 30)
                lv3_qa.unshift(line.new(time, gtop - qr,     time, gtop - qr,     xloc = xloc.bar_time, color = lc, style = line.style_dashed, force_overlay = true))
                lv3_qb.unshift(line.new(time, gtop - qr * 2, time, gtop - qr * 2, xloc = xloc.bar_time, color = lc, style = line.style_solid,  force_overlay = true))
                lv3_qc.unshift(line.new(time, gtop - qr * 3, time, gtop - qr * 3, xloc = xloc.bar_time, color = lc, style = line.style_dashed, force_overlay = true))
                if lv3_qa.size() > keep_last
                    line.delete(lv3_qa.pop())
                    line.delete(lv3_qb.pop())
                    line.delete(lv3_qc.pop())
        ln = line.new(time, open, time, open, xloc = xloc.bar_time, color = col_3, style = line.style_dotted, width = 2, force_overlay = true)
        lv3_lines.unshift(ln)
        if lv3_lines.size() > keep_last
            line.delete(lv3_lines.pop())

// ─────────────────────────────────────────────
// EXTEND DRAWINGS EACH BAR (always to 4:15pm)
// ─────────────────────────────────────────────

// Anchor line: full-session reference (9:30 → 16:15)
if sess.gap_ready and before_415 and anc_lines.size() > 0
    anc_lines.get(0).set_x2(time)

// Level 1 — always extend to 4:15pm
if sess.l1_fired and before_415
    if lv1_boxes.size() > 0
        lv1_boxes.get(0).set_right(time)
    if lv1_lines.size() > 0
        lv1_lines.get(0).set_x2(time)
    if lv1_qa.size() > 0
        lv1_qa.get(0).set_x2(time)
        lv1_qb.get(0).set_x2(time)
        lv1_qc.get(0).set_x2(time)

// Level 2 — always extend to 4:15pm
if sess.l2_fired and before_415
    if lv2_boxes.size() > 0
        lv2_boxes.get(0).set_right(time)
    if lv2_lines.size() > 0
        lv2_lines.get(0).set_x2(time)
    if lv2_qa.size() > 0
        lv2_qa.get(0).set_x2(time)
        lv2_qb.get(0).set_x2(time)
        lv2_qc.get(0).set_x2(time)

// Level 3 — always extend to 4:15pm
if sess.l3_fired and before_415
    if lv3_boxes.size() > 0
        lv3_boxes.get(0).set_right(time)
    if lv3_lines.size() > 0
        lv3_lines.get(0).set_x2(time)
    if lv3_qa.size() > 0
        lv3_qa.get(0).set_x2(time)
        lv3_qb.get(0).set_x2(time)
        lv3_qc.get(0).set_x2(time)

// ─────────────────────────────────────────────
// END-OF-SESSION STATS COMMIT  (4:00pm) — each level commits against its own
// gap, direction, size bucket, touch flag and partial-fill flag.
// ─────────────────────────────────────────────

if end_of_session and not na(sess.anchor)
    if sess.l1_fired and not na(sess.l1_gap_pts) and math.abs(sess.l1_gap_pts) > 0
        dir1 = sess.l1_gap_up ? 0 : 1
        idx1 = dir1 * 4 + sess.l1_bkt
        s1.sessions.set(idx1, s1.sessions.get(idx1) + 1)
        if sess.l1_touched
            s1.hits.set(idx1, s1.hits.get(idx1) + 1)
        if sess.l1_partial_filled
            s1.pfills.set(idx1, s1.pfills.get(idx1) + 1)
        s1.sum_gap.set(idx1, s1.sum_gap.get(idx1) + math.abs(sess.l1_gap_pts))

    if sess.l2_fired and not na(sess.l2_gap_pts) and math.abs(sess.l2_gap_pts) > 0
        dir2 = sess.l2_gap_up ? 0 : 1
        idx2 = dir2 * 4 + sess.l2_bkt
        s2.sessions.set(idx2, s2.sessions.get(idx2) + 1)
        if sess.l2_touched
            s2.hits.set(idx2, s2.hits.get(idx2) + 1)
        if sess.l2_partial_filled
            s2.pfills.set(idx2, s2.pfills.get(idx2) + 1)
        s2.sum_gap.set(idx2, s2.sum_gap.get(idx2) + math.abs(sess.l2_gap_pts))

    if sess.l3_fired and not na(sess.l3_gap_pts) and math.abs(sess.l3_gap_pts) > 0
        dir3 = sess.l3_gap_up ? 0 : 1
        idx3 = dir3 * 4 + sess.l3_bkt
        s3.sessions.set(idx3, s3.sessions.get(idx3) + 1)
        if sess.l3_touched
            s3.hits.set(idx3, s3.hits.get(idx3) + 1)
        if sess.l3_partial_filled
            s3.pfills.set(idx3, s3.pfills.get(idx3) + 1)
        s3.sum_gap.set(idx3, s3.sum_gap.get(idx3) + math.abs(sess.l3_gap_pts))

// ─────────────────────────────────────────────
// STATS TABLE
// ─────────────────────────────────────────────

COL_HDR_BG   = color.black
COL_HDR_TXT  = color.white
COL_CELL_BG  = color.white
COL_CELL_TXT = color.black
COL_CURR_BG  = color.rgb(220, 220, 220)

f_pct(int hits, int n) =>
    // Force float math up front (100.0 * hits before dividing) so this can never
    // truncate to an integer 0/1 regardless of how the values are qualified.
    n > 0 ? str.format("{0,number,#.#}%", 100.0 * hits / n) : "-"

f_avg(float sum, int n) =>
    n > 0 ? str.format("{0,number,#.##}", sum / n) : "-"

f_n(int n) =>
    str.tostring(n)

if barstate.islast and (show_1 or show_2 or show_3)
    SZ  = f_tbl_sz(tbl_txt_size)
    POS = f_tbl_pos(tbl_pos)
    pf_hdr = "≥" + str.tostring(fill_pct, "#.#") + "%"

    shown  = (show_1 ? 1 : 0) + (show_2 ? 1 : 0) + (show_3 ? 1 : 0)
    n_rows = 2 + shown * 4
    tbl = table.new(POS, 11, n_rows, bgcolor = COL_CELL_BG, frame_color = color.black, frame_width = 2, border_color = color.black, border_width = 1, force_overlay = true)

    // Row 0 — top headers
    table.cell(tbl, 0, 0, "LEVEL", text_color = COL_HDR_TXT, bgcolor = COL_HDR_BG, text_size = SZ, text_font_family = font.family_monospace)
    table.cell(tbl, 1, 0, "GAP SIZE\nBUCKET\n(vs history)", text_color = COL_HDR_TXT, bgcolor = COL_HDR_BG, text_size = SZ, text_font_family = font.family_monospace)
    table.cell(tbl, 2, 0, "GAP UP  (open > 4:15pm)", text_color = COL_HDR_TXT, bgcolor = COL_HDR_BG, text_size = SZ, text_font_family = font.family_monospace)
    table.merge_cells(tbl, 2, 0, 5, 0)
    table.cell(tbl, 6, 0, "GAP DOWN  (open < 4:15pm)", text_color = COL_HDR_TXT, bgcolor = COL_HDR_BG, text_size = SZ, text_font_family = font.family_monospace)
    table.merge_cells(tbl, 6, 0, 9, 0)
    table.cell(tbl, 10, 0, "CURRENT\nSESSION", text_color = COL_HDR_TXT, bgcolor = COL_HDR_BG, text_size = SZ, text_font_family = font.family_monospace)

    // Row 1 — sub-headers
    table.cell(tbl, 0, 1, "", text_color = COL_HDR_TXT, bgcolor = COL_HDR_BG, text_size = SZ, text_font_family = font.family_monospace)
    table.cell(tbl, 1, 1, "", text_color = COL_HDR_TXT, bgcolor = COL_HDR_BG, text_size = SZ, text_font_family = font.family_monospace)
    table.cell(tbl, 2, 1, "N", text_color = COL_HDR_TXT, bgcolor = COL_HDR_BG, text_size = SZ, text_font_family = font.family_monospace)
    table.cell(tbl, 3, 1, "FULL%", text_color = COL_HDR_TXT, bgcolor = COL_HDR_BG, text_size = SZ, text_font_family = font.family_monospace)
    table.cell(tbl, 4, 1, pf_hdr, text_color = COL_HDR_TXT, bgcolor = COL_HDR_BG, text_size = SZ, text_font_family = font.family_monospace)
    table.cell(tbl, 5, 1, "AVG GAP", text_color = COL_HDR_TXT, bgcolor = COL_HDR_BG, text_size = SZ, text_font_family = font.family_monospace)
    table.cell(tbl, 6, 1, "N", text_color = COL_HDR_TXT, bgcolor = COL_HDR_BG, text_size = SZ, text_font_family = font.family_monospace)
    table.cell(tbl, 7, 1, "FULL%", text_color = COL_HDR_TXT, bgcolor = COL_HDR_BG, text_size = SZ, text_font_family = font.family_monospace)
    table.cell(tbl, 8, 1, pf_hdr, text_color = COL_HDR_TXT, bgcolor = COL_HDR_BG, text_size = SZ, text_font_family = font.family_monospace)
    table.cell(tbl, 9, 1, "AVG GAP", text_color = COL_HDR_TXT, bgcolor = COL_HDR_BG, text_size = SZ, text_font_family = font.family_monospace)
    table.cell(tbl, 10, 1, "GAP-Q /\nLVL-Q", text_color = COL_HDR_TXT, bgcolor = COL_HDR_BG, text_size = SZ, text_font_family = font.family_monospace)

    bkt_labels = array.from("0-25%ile\n(smallest gaps)", "25-50%ile", "50-75%ile", "75-100%ile\n(largest gaps)")
    lv_labels  = array.from(open_time_1, open_time_2, open_time_3)
    lv_colors  = array.from(col_1, col_2, col_3)
    lv_stats   = array.from(s1, s2, s3)
    lv_show    = array.from(show_1, show_2, show_3)

    gap_top_cur = math.max(sess.anchor, sess.day_open)
    gap_bot_cur = math.min(sess.anchor, sess.day_open)
    gap_up_cur  = sess.day_open > sess.anchor
    l1q = sess.gap_ready and not na(sess.l1_price) ? f_quartile(sess.l1_price, gap_top_cur, gap_bot_cur, gap_up_cur) : 0
    l2q = sess.gap_ready and not na(sess.l2_price) ? f_quartile(sess.l2_price, gap_top_cur, gap_bot_cur, gap_up_cur) : 0
    l3q = sess.gap_ready and not na(sess.l3_price) ? f_quartile(sess.l3_price, gap_top_cur, gap_bot_cur, gap_up_cur) : 0
    lv_q = array.from(l1q, l2q, l3q)

    // Each level highlights its OWN current gap-size bucket, since each level can
    // now land in a different historical bucket than the others.
    cur_bkt_1 = sess.l1_fired ? sess.l1_bkt : -1
    cur_bkt_2 = sess.l2_fired ? sess.l2_bkt : -1
    cur_bkt_3 = sess.l3_fired ? sess.l3_bkt : -1
    lv_cur_bkt = array.from(cur_bkt_1, cur_bkt_2, cur_bkt_3)

    disp = 0
    for li = 0 to 2
        if lv_show.get(li)
            LevelStats st = lv_stats.get(li)
            lc  = lv_colors.get(li)
            lbl = lv_labels.get(li)
            lq  = lv_q.get(li)
            cur_gap_qbkt  = lv_cur_bkt.get(li)
            has_highlight = cur_gap_qbkt >= 0 and cur_gap_qbkt <= 3 and lq > 0

            for bi = 0 to 3
                row    = 2 + disp * 4 + bi
                idx_up = bi
                idx_dn = 4 + bi
                n_up   = st.sessions.get(idx_up)
                h_up   = st.hits.get(idx_up)
                p_up   = st.pfills.get(idx_up)
                sg_up  = st.sum_gap.get(idx_up)
                n_dn   = st.sessions.get(idx_dn)
                h_dn   = st.hits.get(idx_dn)
                p_dn   = st.pfills.get(idx_dn)
                sg_dn  = st.sum_gap.get(idx_dn)

                is_cur  = bi == cur_gap_qbkt
                cell_bg = is_cur ? COL_CURR_BG : COL_CELL_BG

                if bi == 0
                    table.cell(tbl, 0, row, lbl, text_color = lc, bgcolor = COL_CELL_BG, text_size = SZ, text_font_family = font.family_monospace)
                    table.merge_cells(tbl, 0, row, 0, row + 3)

                table.cell(tbl, 1, row, bkt_labels.get(bi), text_color = COL_CELL_TXT, bgcolor = cell_bg, text_size = SZ, text_font_family = font.family_monospace)
                table.cell(tbl, 2, row, f_n(n_up),          text_color = COL_CELL_TXT, bgcolor = cell_bg, text_size = SZ, text_font_family = font.family_monospace)
                table.cell(tbl, 3, row, f_pct(h_up, n_up),  text_color = COL_CELL_TXT, bgcolor = cell_bg, text_size = SZ, text_font_family = font.family_monospace)
                table.cell(tbl, 4, row, f_pct(p_up, n_up),  text_color = COL_CELL_TXT, bgcolor = cell_bg, text_size = SZ, text_font_family = font.family_monospace)
                table.cell(tbl, 5, row, f_avg(sg_up, n_up), text_color = COL_CELL_TXT, bgcolor = cell_bg, text_size = SZ, text_font_family = font.family_monospace)
                table.cell(tbl, 6, row, f_n(n_dn),          text_color = COL_CELL_TXT, bgcolor = cell_bg, text_size = SZ, text_font_family = font.family_monospace)
                table.cell(tbl, 7, row, f_pct(h_dn, n_dn),  text_color = COL_CELL_TXT, bgcolor = cell_bg, text_size = SZ, text_font_family = font.family_monospace)
                table.cell(tbl, 8, row, f_pct(p_dn, n_dn),  text_color = COL_CELL_TXT, bgcolor = cell_bg, text_size = SZ, text_font_family = font.family_monospace)
                table.cell(tbl, 9, row, f_avg(sg_dn, n_dn), text_color = COL_CELL_TXT, bgcolor = cell_bg, text_size = SZ, text_font_family = font.family_monospace)

                // Column 10 is only ever merged across all 4 rows of a level block when
                // NONE of those rows need distinct text. If the current session's bucket
                // falls inside this level's block, every row (including bi==0) is written
                // individually instead, so we never merge_cells over a row we're about to
                // write to, and never table.cell into a row that a previous merge covered.
                if is_cur and has_highlight
                    cur_txt = "GQ" + str.tostring(bi + 1) + " / LQ" + str.tostring(lq)
                    table.cell(tbl, 10, row, cur_txt, text_color = lc, bgcolor = COL_CURR_BG, text_size = SZ, text_font_family = font.family_monospace)
                else if not has_highlight and bi == 0
                    table.cell(tbl, 10, row, "", text_color = COL_CELL_TXT, bgcolor = COL_CELL_BG, text_size = SZ, text_font_family = font.family_monospace)
                    table.merge_cells(tbl, 10, row, 10, row + 3)
                else if has_highlight
                    table.cell(tbl, 10, row, "", text_color = COL_CELL_TXT, bgcolor = COL_CELL_BG, text_size = SZ, text_font_family = font.family_monospace)
            disp := disp + 1
````
