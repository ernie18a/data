# Support Resistance AI [PickMyTrade]

- url: https://www.tradingview.com/script/P3E2MgtI-Support-Resistance-AI-PickMyTrade/
- type: indicator
- pine_id: PUB;4d51b92aba6343759fafd6a59b138b56
- version: 2.0

## Description

Every support/resistance tool answers "where are the levels." None answer the question a trader actually has when price arrives at one: does THIS test look like the ones that held, or like the ones that broke?

――――――――――――――――――――――――――――――――――――――
https://www.tradingview.com/x/SqcJOgYA/

🔷 WHAT IT MEASURES
🔸 Confirmed swing pivots, clustered into zones and merged as new evidence accumulates
🔸 Eight properties of every ARRIVAL at a zone — approach speed, relative volume, prior test count, zone age, trend pressure, zone width, pivot count, and cumulative touches
🔸 A broken level isn't discarded — it flips role once (broken support becomes candidate resistance) and only a second failure retires it
🔸 A live Previous Day/Week High/Low reference map, shown only when price is within range

――――――――――――――――――――――――――――――――――――――

🔷 THE CLASSIFIER
🔸 An online Gaussian Naive Bayes model, trained continuously as tests resolve — no repainting, no lookahead
🔸 Nothing about a level's price is used as a feature — only how price approached it
🔸 The classic claim that "a level tested repeatedly grows weaker" is measured on each chart's own history here, rather than assumed
🔸 Below a configurable warmup sample count, the script shows the chart's running hold rate instead and reads LEARNING — it never guesses early

――――――――――――――――――――――――――――――――――――――

🔷 SIGNALS AND DISPLAY
🔸 Zone boxes colored by role (support/resistance) and shaded by live conviction, with worded verdicts ("similar arrivals held X%") instead of a bare number
🔸 Rank-based visibility — only the nearest zones to current price are drawn, so old or distant levels never stretch the chart's scale
🔸 Test history ticks stamped inside each zone at the bar where its own tests resolved
🔸 An info table with Nearest Support/Resistance, model accuracy, and sample counts
🔸 3 alertconditions, worded as observations of what the classifier's reading — never as trade instructions

――――――――――――――――――――――――――――――――――――――

🔷 INPUTS
[b]Pivot Left/Right Bars[/b] — swing detection window. Default 10/10.
[b]Zone Width / Merge Distance[/b] — band thickness and clustering tolerance, in ATR. Default 0.5 / 0.75.
[b]Break Buffer / Rejection Distance[/b] — how far price must close beyond or travel back from a zone to resolve a test. Default 0.25 / 0.75 ATR.
[b]Post-Flip Cooldown[/b] — bars a flipped zone must survive before a break can retire it. Default 5.
[b]Warmup Samples[/b] — resolved tests required before the classifier is trusted. Default 25.
[b]Conviction Threshold[/b] — probability at which a zone is shown at full conviction. Default 0.62.
[b]Max Live Zones / Show Distance[/b] — how many nearby zones are drawn and how far (in ATR) before one is hidden.
[b]Show Trend EMA, Zen Mode[/b] — display toggles; Zen Mode hides labels and the table for clean screenshots.

――――――――――――――――――――――――――――――――――――――

🔷 REQUIREMENTS AND LIMITATIONS
🔸 Pivots confirm only after the right-side lookback bars close — a level appears on the chart later than the swing that created it, by design
🔸 One thing does refine retroactively: when a later pivot merges into an existing zone, its band re-centers toward the weighted average — a zone with an open test is never re-centered, so no in-progress outcome is affected
🔸 Early on a fresh chart, or for a zone with only one or two tests, its own read is thin — the model's overall sample count travels with every verdict so that's never hidden
🔸 This script reports how historical arrivals resolved. It does not predict, and it is not a trading system on its own.

――――――――――――――――――――――――――――――――――――――

[i]Built in Pine Script v6. Open source — Mozilla Public License 2.0.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
//
// Support Resistance AI [PickMyTrade]
//
// THE QUESTION
// Every support/resistance tool answers "where are the levels." None answer the
// question a trader actually has when price arrives at one: does THIS test look
// like the ones that held, or like the ones that broke?
//
// Classic technical doctrine claims a level tested repeatedly grows weaker. That
// claim is universally repeated and almost never measured. Here it is measured —
// prior test count is fed to the classifier as a feature, so each chart's own
// resolved history decides whether repetition helped or hurt, rather than the
// script asserting it.
//
// THE METHOD
// Confirmed swing pivots are clustered into zones. Each time price enters a zone,
// eight properties of the ARRIVAL are frozen before the outcome is known — speed,
// participation, prior tests, age, trend pressure, zone width, pivot count and
// cumulative touches. When the test resolves as a hold or a break, that frozen
// signature trains an online Gaussian Naive Bayes classifier. Nothing about where
// the level sits is used; only how price came at it.
//
// A broken level is not discarded. It flips role once — broken support becomes
// candidate resistance — and only a second failure retires it.
//
// Beneath the learned zones sits a fixed higher-timeframe map: the previous
// completed day, week and month highs and lows. The zones report how tests of
// a level have been resolving on this chart; the map marks the reference
// prices the wider market watches regardless of any model. Together they are
// what lets one script read the same way from a 5-minute chart to a daily one.
//
// ATTRIBUTION
// Horizontal S/R channels built from clustered pivots are long-established public
// technical analysis, implemented independently here. The pivot-cluster idea is a
// tool serving the question above; the classifier and its per-test signature are
// the original contribution. No code from any existing script is reused.
//
// NON-REPAINTING, AND THE ONE THING THAT DOES REFINE
// Pivots confirm i_piv_right bars after they form. Zone state advances only on
// confirmed bar closes (barstate.isconfirmed). No future data is referenced and
// no security() call is made — the higher-timeframe levels are tracked by hand
// from completed periods only, so a previous-day or previous-week line can
// never show a range still forming.
//
// One thing does refine retroactively, stated here rather than left in a
// tooltip: when a later confirmed pivot merges into an existing zone, the band
// re-centres on the weighted average of its pivots, and because each box is
// drawn from its birth bar to the present, an older zone can sit at a slightly
// different price and width than when it first appeared. No test outcome is
// affected — a zone with an open test is never re-centred — so a level should be
// read as a refining estimate rather than a fixed line.

//@version=6
// V2 - user-requested update (published-script comments):
//  · VISIBILITY (birdm4484: "difficult to see labels ... make labels/lines
//    thicker/larger brighter/lighter"): Label Size, Zone Border Width and HTF
//    Line Width are now inputs. That is the whole of it — SIZE and THICKNESS.
//    NOT ONE COLOUR IN THIS SCRIPT DIFFERS FROM V1. A level that was blue is
//    the same blue, at the same transparency, on the same backing. Asking for
//    labels that are easier to see is not asking for a different palette, and
//    an existing chart is pixel-identical to V1 until a size control is moved.
//  · EVIDENCE GRADE (Shivamuktha: "need grading system and quality of S/R"):
//    each level carries an A–D grade measuring accumulated EVIDENCE — merged
//    pivots, touches, resolved tests, age. Deliberately separate from the
//    classifier's hold percentage: the grade says how much history stands
//    behind the LEVEL, the percentage says how similar ARRIVALS resolved.
indicator("Support Resistance AI [PickMyTrade]", "SR AI[PMT]",
         overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// ── Input Groups ──────────────────────────────────────────────────────────────
var string G_LEVEL = "Level Detection"
var string G_TEST  = "Test Resolution"
var string G_PROB  = "Probability Engine"
var string G_HTF   = "Higher-Timeframe Map"
var string G_VIS   = "Visual"
var string G_ZEN   = "Display"

// Level Detection
i_piv_left   = input.int  (10,   "Pivot Left Bars",   group=G_LEVEL, minval=2, maxval=50,
     tooltip="Bars to the left of a swing point. Larger values keep only the more significant turns.")
i_piv_right  = input.int  (10,   "Pivot Right Bars",  group=G_LEVEL, minval=2, maxval=50,
     tooltip="Bars to the right required to CONFIRM a swing. This is the detection delay — a level appears this many bars after the turn that created it, which is what keeps the levels non-repainting.")
i_zone_w     = input.float(0.50, "Zone Width (ATR x)", group=G_LEVEL, minval=0.1, maxval=3.0, step=0.05,
     tooltip="Thickness of each zone as a multiple of ATR. Price rarely turns at an exact price, so a level is treated as a band rather than a line.")
i_cluster    = input.float(0.75, "Merge Distance (ATR x)", group=G_LEVEL, minval=0.1, maxval=4.0, step=0.05,
     tooltip="New pivots landing within this distance of an existing zone merge into it, and the zone re-centres toward the weighted average of its pivots. Merging lets a level accumulate evidence instead of fragmenting into near-duplicates.")
i_atr_len    = input.int  (14,   "ATR Period",        group=G_LEVEL, minval=5, maxval=50,
     tooltip="Volatility yardstick. Every width, distance and threshold here is expressed in ATR so the script behaves the same across instruments.")

// Test Resolution
i_break_buf  = input.float(0.25, "Break Buffer (ATR x)", group=G_TEST, minval=0.0, maxval=2.0, step=0.05,
     tooltip="How far beyond the zone price must CLOSE to count as a decisive break. The buffer stops a single marginal close from retiring a level.")
i_reject     = input.float(0.75, "Rejection Distance (ATR x)", group=G_TEST, minval=0.2, maxval=4.0, step=0.05,
     tooltip="How far price must travel back away from the zone to count as a hold. Both outcomes require real movement; a test that merely stalls resolves on the timeout rule instead.")
i_test_bars  = input.int  (15,   "Test Timeout (bars)",  group=G_TEST, minval=3, maxval=100,
     tooltip="Bars a single test stays open. On timeout the sample is labelled by which side of the zone price finished on — but a timeout never retires or flips a level, since no decisive break occurred.")
i_flip_cool  = input.int  (5,    "Post-Flip Cooldown (bars)", group=G_TEST, minval=0, maxval=50,
     tooltip="Bars a level must survive in its NEW role after a flip before a decisive break can retire it. Without a cooldown the same two-bar whipsaw that flips a level can also break it in the opposite role immediately, retiring a level that took hundreds of bars to build.")

// Probability Engine
i_warmup     = input.int  (25,   "Warmup Samples",    group=G_PROB, minval=5, maxval=400,
     tooltip="Resolved tests required before the classifier is used. Below this the display shows the chart's running hold rate instead, and the info table reads LEARNING.")
i_thresh     = input.float(0.62, "Conviction Threshold", group=G_PROB, minval=0.50, maxval=0.95, step=0.01,
     tooltip="Probability at or above which a zone is shown at full conviction. The mirrored value below it marks the opposite case with equal strength.")
i_appr_len   = input.int  (5,    "Approach Window",   group=G_PROB, minval=2, maxval=30,
     tooltip="Bars used to measure how fast price travelled into the zone. A level struck by an impulse has historically behaved differently from one drifted into.")
i_vol_len    = input.int  (20,   "Volume Baseline",   group=G_PROB, minval=5, maxval=200,
     tooltip="Averaging window for relative volume. On symbols without volume data this feature flattens and is neutralised in the maths rather than distorting it.")
i_ema_len    = input.int  (50,   "Trend EMA Period",  group=G_PROB, minval=5, maxval=500,
     tooltip="Reference for the trend-pressure feature: how far, and which way, price is stretched from its mean on arrival at the zone.")

// Higher-Timeframe Map
show_htf     = input.bool (true,  "Show HTF Levels",  group=G_HTF,
     tooltip="Previous completed day / week / month highs and lows, drawn as dotted reference lines. These are the levels the wider market watches regardless of any model — the learned zones answer on the chart's own timeframe, these carry the context above it.")
show_pd      = input.bool (true,  "Previous Day High / Low",   group=G_HTF,
     tooltip="Intraday charts only — on a daily chart the previous day is simply the previous candle, so the pair is suppressed there automatically.")
show_pw      = input.bool (true,  "Previous Week High / Low",  group=G_HTF)
show_pm      = input.bool (false, "Previous Month High / Low", group=G_HTF,
     tooltip="Off by default for intraday work; worth enabling on 4-hour and daily charts.")

// Visual
sup_col      = input.color(color.new(#2962FF, 0), "Support Colour",    group=G_VIS)
res_col      = input.color(color.new(#FF6D00, 0), "Resistance Colour", group=G_VIS)
inzone_col   = input.color(color.new(#787B86, 0), "Price Inside Zone", group=G_VIS,
     tooltip="Neutral colour applied while price is trading inside a zone — at that moment the level is neither supporting nor resisting, and colouring it either way would overstate what is known.")
brk_col      = input.color(color.new(color.gray, 82), "Retired Zone",  group=G_VIS,
     tooltip="Colour a zone takes after its SECOND decisive break. The first break flips its role instead of retiring it.")
show_zones   = input.bool (true,  "Show Zones",       group=G_VIS)
show_lbl     = input.bool (true,  "Zone Labels",      group=G_VIS,
     tooltip="Prints the live hold probability and test count on each zone. The figure re-reads as the classifier keeps learning, so an older zone reflects current statistics.")
show_hist    = input.bool (true,  "Test History Ticks", group=G_VIS,
     tooltip="Draws a coloured tick inside the zone at every bar where one of its own tests resolved — blue for a hold, orange for a break. It renders each level's individual track record in place, so the probability figure can be read against the evidence behind it.")
i_max_zones  = input.int  (12,    "Max Live Zones",   group=G_VIS, minval=3, maxval=40,
     tooltip="Cap on LIVE zones. Retired zones do not consume slots. When the cap is reached the weakest zone is dropped — fewest pivots and touches — rather than simply the oldest.")
i_show_n     = input.int  (5,    "Zones Per Side",   group=G_VIS, minval=1, maxval=12,
     tooltip="How many of the NEAREST zones to draw above price, and below price. Rank-based rather than a fixed distance, so the chart is populated the same way on a 5-minute chart as on a daily one — a fixed ATR radius that fills one timeframe leaves another empty.")
i_show_dist  = input.float(30.0, "Show Zones Within (ATR x)", group=G_VIS, minval=2.0, maxval=100.0, step=0.5,
     tooltip="Safety ceiling on top of Zones Per Side: a zone farther than this from current price is never drawn, however few zones are nearby. Stops one extreme old level from stretching the chart's y-axis.")
show_all_lbl = input.bool (false, "Label Every Zone", group=G_VIS,
     tooltip="Off (default): worded labels render only on the nearest live support, the nearest live resistance, and any zone with an open test — the levels a trader is actually asking about right now. Every other zone speaks through its colour alone, which is what stops labels stacking into an unreadable pile. On: every drawn zone gets its label back.")
show_ema     = input.bool (false, "Show Trend EMA",   group=G_VIS)

// V2 visibility controls. Defaults reproduce V1's fixed values exactly.
i_lbl_size   = input.string("Small", "Label Size", group=G_VIS, options=["Tiny", "Small", "Normal", "Large", "Huge"],
     tooltip="Text size of the worded zone labels — the Support / Resistance lines with the grade and the hold percentage. Small matches V1.")
i_htf_size   = input.string("Tiny", "HTF Tag Size", group=G_VIS, options=["Tiny", "Small", "Normal", "Large"],
     tooltip="Text size of the previous-day / week / month price tags (PDH, PWL, ...). These are the smallest text on the chart and V1 fixed them at Tiny with no way to change it, which is what made them hard to read. Tiny matches V1.")
i_border_w   = input.int  (1, "Zone Border Width", group=G_VIS, minval=1, maxval=4,
     tooltip="Base border width for every zone. Zones built from 3 or more merged pivots always draw one step heavier than this, exactly as in V1. Test-history ticks scale with it too.")
i_htf_w      = input.int  (1, "HTF Line Width", group=G_VIS, minval=1, maxval=3,
     tooltip="Width of the dotted previous-day / previous-week / previous-month lines.")
i_show_grade = input.bool (true, "Level Evidence Grade (A–D)", group=G_VIS,
     tooltip="Stamps an A–D grade in each zone's corner and on its worded label. The grade measures accumulated EVIDENCE — merged pivots, touch count, resolved tests and age — never the classifier's probability, so the grade and the hold percentage remain two different statements: the grade is how much history stands behind the level, the percentage is how similar arrivals resolved. A role flip resets tests and age, so a flipped level regrades from its new role's own record. The grade re-reads as evidence accumulates.")

// Display
zen_mode     = input.bool (false, "Zen Mode",         group=G_ZEN,
     tooltip="Hides zone labels, HTF level tags and the info table. Zones, HTF lines and history ticks remain — for clean screenshots and live use.")
show_table   = input.bool (true,  "Show Info Table",  group=G_ZEN)

// ── V2 VISIBILITY MAPPINGS ──────────────────────────────────────
// Size only. V2 deliberately owns no colour: the request was to make the
// labels and lines easier to SEE, which is a size and thickness problem, not
// a palette problem. Every colour in this script is V1's, byte for byte.
string v2_lbl_size = i_lbl_size == "Tiny" ? size.tiny : i_lbl_size == "Normal" ? size.normal : i_lbl_size == "Large" ? size.large : i_lbl_size == "Huge" ? size.huge : size.small
string v2_htf_size = i_htf_size == "Small" ? size.small : i_htf_size == "Normal" ? size.normal : i_htf_size == "Large" ? size.large : size.tiny

// ── ZONE TYPE ─────────────────────────────────────────────────────────────────
// A zone carries the frozen signature of its most recent test, so its probability
// can be re-read live as the classifier keeps learning, plus its own running
// record of pivots, touches, tests, holds and role flips.
type SRZone
    float top
    float bot
    int   born
    int   born_time    // unix ms — box left edge uses this, never the bar index.
                        // Pine's bar-index box coordinates are rejected once they
                        // sit too many bars behind the current bar (RE10026); time
                        // coordinates have no such limit. born (bar index) is kept
                        // separately for the age feature and cooldown, which are
                        // genuinely bar-count math, not display.
    int   strength
    int   touches
    int   tests
    int   holds
    int   flips
    bool  broken
    bool  is_res
    bool  testing
    bool  armed
    int   t_bar
    int   t_bar_time   // same reasoning as born_time, for the retired-zone right edge
    float t_f0
    float t_f1
    float t_f2
    float t_f3
    float t_f4
    float t_f5
    float t_f6
    float t_f7
    float prob
    box   bx
    label lbl
    array<line> ticks

// ── NAIVE BAYES — Gaussian, Welford accumulators, log-space ──────────────────
// Slot layout: (class * 8) + feature   class 0 = HOLD   class 1 = BREAK
// Support and resistance share one model: every feature is written relative to
// the direction of the test, so a fast approach into support and a fast approach
// into resistance are the same event described the same way. Sharing doubles the
// effective sample count without mixing unlike distributions.
var array<float> nb_n   = array.new_float(16, 0.0)
var array<float> nb_sum = array.new_float(16, 0.0)
var array<float> nb_ss  = array.new_float(16, 0.0)
var array<int>   nb_cnt = array.new_int(2, 0)

// na guarded here, not only at the feature source: nb_sum/nb_ss are running
// totals that are never reset, so a single bad write would poison that slot for
// the rest of the chart. A value that would go na is skipped instead.
nb_upd(int slot, float v) =>
    if not na(v)
        array.set(nb_n,   slot, array.get(nb_n,   slot) + 1.0)
        array.set(nb_sum, slot, array.get(nb_sum, slot) + v)
        array.set(nb_ss,  slot, array.get(nb_ss,  slot) + v * v)

nb_train(int cls, float a0, float a1, float a2, float a3, float a4, float a5, float a6, float a7) =>
    int b = cls * 8
    nb_upd(b + 0, a0)
    nb_upd(b + 1, a1)
    nb_upd(b + 2, a2)
    nb_upd(b + 3, a3)
    nb_upd(b + 4, a4)
    nb_upd(b + 5, a5)
    nb_upd(b + 6, a6)
    nb_upd(b + 7, a7)
    array.set(nb_cnt, cls, array.get(nb_cnt, cls) + 1)

// Log Gaussian likelihood for one feature. The -0.5*log(2*pi) constant is dropped
// because it is identical for both classes and cancels in the ratio. Log space is
// required: eight multiplied densities underflow to zero in linear space, which
// silently collapses the posterior to a meaningless 0.5.
nb_ll(int slot, float v) =>
    float n  = array.get(nb_n,   slot)
    float s  = array.get(nb_sum, slot)
    float q  = array.get(nb_ss,  slot)
    float m  = n > 0.0 ? s / n : 0.0
    float vr = n > 1.0 ? math.max((q - n * m * m) / (n - 1.0), 1e-6) : 1.0
    float sd = math.sqrt(vr)
    float z  = (v - m) / sd
    -0.5 * z * z - math.log(sd)

// Running hold rate — the honest fallback while the classifier is thin.
base_rate() =>
    int c0 = array.get(nb_cnt, 0)
    int c1 = array.get(nb_cnt, 1)
    (c0 + c1) > 0 ? float(c0) / float(c0 + c1) : 0.5

model_ready() =>
    (array.get(nb_cnt, 0) + array.get(nb_cnt, 1)) >= i_warmup

// Always returns a usable number — never na. Full posterior once warm, the
// running hold rate while learning, 0.5 before any test has resolved.
nb_post(float a0, float a1, float a2, float a3, float a4, float a5, float a6, float a7) =>
    int   c0  = array.get(nb_cnt, 0)
    int   c1  = array.get(nb_cnt, 1)
    int   tot = c0 + c1
    float res = base_rate()
    if tot >= i_warmup
        float ll0 = math.log(math.max(float(c0), 0.5) / float(tot)) + nb_ll(0, a0) + nb_ll(1, a1) + nb_ll(2, a2) + nb_ll(3, a3) + nb_ll(4, a4) + nb_ll(5, a5) + nb_ll(6, a6) + nb_ll(7, a7)
        float ll1 = math.log(math.max(float(c1), 0.5) / float(tot)) + nb_ll(8, a0) + nb_ll(9, a1) + nb_ll(10, a2) + nb_ll(11, a3) + nb_ll(12, a4) + nb_ll(13, a5) + nb_ll(14, a6) + nb_ll(15, a7)
        float mx  = math.max(ll0, ll1)
        float e0  = math.exp(ll0 - mx)
        float e1  = math.exp(ll1 - mx)
        res := e0 / (e0 + e1)
    // Hard floor: an na here would propagate into every label and colour.
    na(res) ? base_rate() : res

// ── ZONE COLOURS ──────────────────────────────────────────────────────────────
// Fill stays translucent so candles read through the zone; the border stays crisp
// so the level itself is never ambiguous. While price is INSIDE a zone the level
// is neither holding nor breaking yet, so it renders neutral rather than implying
// a direction it has not earned.
sr_base(bool is_res) =>
    is_res ? res_col : sup_col

sr_fill(bool is_res, bool broken, bool inside, float p) =>
    broken ? brk_col : inside ? color.new(inzone_col, 86) : p >= i_thresh ? color.new(sr_base(is_res), 80) : p <= 1.0 - i_thresh ? color.new(sr_base(is_res), 90) : color.new(sr_base(is_res), 86)

sr_border(bool is_res, bool broken, bool inside, float p) =>
    broken ? color.new(color.gray, 62) : inside ? color.new(inzone_col, 25) : p >= i_thresh ? color.new(sr_base(is_res), 0) : p <= 1.0 - i_thresh ? color.new(sr_base(is_res), 55) : color.new(sr_base(is_res), 30)

// ── V2 EVIDENCE GRADE ─────────────────────────────────────────
// Measures accumulated evidence only — merged pivots, touch count, resolved
// tests and age. The classifier's probability is deliberately NOT an input:
// the grade and the hold percentage must remain two different statements.
// Full age credit accrues at ~300 bars (log(1+300) ≈ 5.71); log damping means
// the difference between 50 and 150 bars matters far more than between 500
// and 1000. A flipped level regrades from its new role's own record because
// born and tests reset at the flip, exactly as the label's test count does.
f_gradeScore(int strength, int touches, int tests, int born) =>
    float gPiv = math.min(strength / 4.0, 1.0)
    float gTou = math.min(touches / 8.0, 1.0)
    float gTst = math.min(tests / 4.0, 1.0)
    float gAge = math.min(math.log(1.0 + math.max(bar_index - born, 0)) / 5.71, 1.0)
    100.0 * (0.35 * gPiv + 0.25 * gTou + 0.20 * gTst + 0.20 * gAge)

f_gradeTag(float s) =>
    s >= 75 ? "A" : s >= 55 ? "B" : s >= 35 ? "C" : "D"

// ── BASE MEASURES ─────────────────────────────────────────────────────────────
float atr       = ta.atr(i_atr_len)
float ema_line  = ta.ema(close, i_ema_len)
bool  confirmed = barstate.isconfirmed
// Milliseconds per bar on this chart's timeframe — used only to nudge a box's
// time-based right edge a few bars into the future. An approximation is fine
// here (session gaps aren't accounted for); it only needs to land visually near
// "now", never to be exact.
var int bar_ms  = timeframe.in_seconds(timeframe.period) * 1000

float vol_ma = ta.sma(volume, i_vol_len)
float rvol   = (na(volume) or na(vol_ma) or vol_ma <= 0) ? 1.0 : math.min(4.0, volume / vol_ma)

// ── HIGHER-TIMEFRAME RANGES — tracked by hand, no security() call ────────────
// Only fully COMPLETED periods are ever referenced: the running period is
// accumulated but never shown, so these levels cannot repaint. Each call site
// of this function keeps its own var state, so one function serves day, week
// and month. strt records when the level BECAME "previous" — the line is drawn
// from there, spanning exactly the span it is the active reference for.
f_prev_range(simple string tf) =>
    var float cur_h = na
    var float cur_l = na
    var float prv_h = na
    var float prv_l = na
    var int   strt  = na
    var bool  full  = false
    if timeframe.change(tf)
        // The first tracked period almost always starts mid-day / mid-week /
        // mid-month at the chart's first bar. Promoting that partial range
        // would publish a wrong "previous" level for the whole next period —
        // it is skipped, so only fully observed periods are ever shown.
        if full
            prv_h := cur_h
            prv_l := cur_l
            strt  := time
        full  := true
        cur_h := high
        cur_l := low
    else
        cur_h := na(cur_h) ? high : math.max(cur_h, high)
        cur_l := na(cur_l) ? low  : math.min(cur_l, low)
    [prv_h, prv_l, strt]

[pdh, pdl, pd_t] = f_prev_range("D")
[pwh, pwl, pw_t] = f_prev_range("W")
[pmh, pml, pm_t] = f_prev_range("M")

// ── PIVOTS ────────────────────────────────────────────────────────────────────
float ph = ta.pivothigh(high, i_piv_left, i_piv_right)
float pl = ta.pivotlow (low,  i_piv_left, i_piv_right)

// ── ZONE STORE ────────────────────────────────────────────────────────────────
var array<SRZone> zones = array.new<SRZone>()

zone_free(SRZone z) =>
    box.delete(z.bx)
    label.delete(z.lbl)
    if not na(z.ticks)
        for k = 0 to math.max(0, array.size(z.ticks) - 1)
            if array.size(z.ticks) > 0
                line.delete(array.shift(z.ticks))

// Adds a pivot to the map. A pivot near an existing same-role zone merges into it
// and pulls the zone toward the weighted average of its pivots — so a level
// refines its price as evidence accumulates rather than fragmenting.
// A zone with an OPEN test is never merged into: moving its boundaries mid-test
// would change the very thresholds the pending outcome is about to be judged by.
add_level(float price, bool is_res) =>
    float half   = atr * i_zone_w * 0.5
    float tol    = atr * i_cluster
    bool  merged = false
    int   n      = array.size(zones)
    if n > 0
        for i = 0 to n - 1
            SRZone z = array.get(zones, i)
            if not merged and not z.broken and z.is_res == is_res and math.abs((z.top + z.bot) * 0.5 - price) <= tol
                // Boundaries re-centre only when no test is pending — moving them
                // mid-test would shift the very thresholds the pending outcome is
                // about to be judged against. The pivot still counts as evidence
                // either way, which is what stops a level forking into a
                // near-duplicate that would train the classifier twice on one
                // market event. t_f6 was frozen when the test opened, so the
                // pending sample's feature vector is unaffected.
                if not z.testing
                    float mid_new = ((z.top + z.bot) * 0.5 * z.strength + price) / (z.strength + 1)
                    z.top      := mid_new + half
                    z.bot      := mid_new - half
                z.strength := z.strength + 1
                merged     := true
    if not merged
        // 27 args, in field order: top, bot, born, born_time, strength, touches,
        // tests, holds, flips, broken, is_res, testing, armed, t_bar, t_bar_time,
        // t_f0..t_f7, prob, bx, lbl, ticks.
        array.push(zones, SRZone.new(price + half, price - half, bar_index, time, 1, 0, 0, 0, 0, false, is_res, false, true, 0, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, na, na, array.new<line>()))
    merged

// ── APPROACH FEATURES — describe HOW price arrives, not where the level is ───
// F0 Velocity  — ATR-normalised speed into the level, separating a level struck
//                by an impulse from one drifted into. Whether that distinction
//                separated holds from breaks is decided by this chart's own
//                history, not asserted here.
// F1 Volume    — participation on arrival, against the symbol's own baseline.
// F2 Tests     — prior tests of THIS zone. The classic "repeated tests weaken a
//                level" claim, measured on this chart instead of assumed.
// F3 Age       — bars since the zone formed (reset on a role flip), damped.
// F4 Pressure  — signed distance from the EMA in ATR units, oriented toward the
//                break direction.
// F5 Width     — zone thickness in ATR. Tight levels and broad areas are not
//                treated as the same object.
// F6 Pivots    — how many swing points merged into this zone.
// F7 Touches   — cumulative bars that have interacted with this zone, counted
//                incrementally. Distinct from F6: pivots record where the market
//                TURNED, touches record where it merely traded.
float velo_raw = (not na(atr) and atr > 0 and not na(close[i_appr_len])) ? (close - close[i_appr_len]) / (atr * math.sqrt(i_appr_len)) : 0.0
float stretch  = (not na(atr) and atr > 0 and not na(ema_line)) ? (close - ema_line) / atr : 0.0

// ── LIFECYCLE ─────────────────────────────────────────────────────────────────
// mark_bull / mark_bear drive ALERTS ONLY — there is deliberately no bar-anchored
// chart marker. A triangle below or above a bar is the universal grammar for
// "enter a trade"; this script reports how a level test resolved, which is a
// weaker and different claim. The zone's own colour and worded label carry it.
var bool mark_bull  = false
var bool mark_bear  = false
var bool mark_break = false
mark_bull  := false
mark_bear  := false
mark_break := false

if confirmed and not na(atr) and atr > 0
    // Pivots first, then lifecycle — a zone created this bar starts clean.
    if not na(ph)
        add_level(ph, true)
    if not na(pl)
        add_level(pl, false)

    float buf = atr * i_break_buf
    float rej = atr * i_reject

    if array.size(zones) > 0
        for i = array.size(zones) - 1 to 0
            SRZone z = array.get(zones, i)
            if not z.broken
                bool touching = low <= z.top and high >= z.bot
                // Gating `decisive` itself (not just the retirement branch) is
                // load-bearing: it blocks the training label, the no-test break
                // path and retirement together. A flip inverts the break test to
                // the opposite side of the same zone, so without a cooldown one
                // continuous excursion can both flip and retire a level.
                bool cooled   = z.flips == 0 or bar_index - z.born >= i_flip_cool
                bool decisive = (z.is_res ? close > z.top + buf : close < z.bot - buf) and cooled

                // Touch counter — incremental, one increment per interacting bar.
                if touching
                    z.touches := z.touches + 1

                // STEP 1 — open a test when price enters an armed zone. Done
                // before resolution so a bar that both enters and breaks the zone
                // still contributes its signature to the training set.
                if not z.testing and z.armed and touching
                    z.testing := true
                    z.armed   := false
                    z.t_bar      := bar_index
                    z.t_bar_time := time
                    z.t_f0 := math.max(-4.0, math.min(4.0, z.is_res ? velo_raw : -velo_raw))
                    z.t_f1 := rvol
                    z.t_f2 := math.min(6.0, float(z.tests))
                    z.t_f3 := math.min(5.0, math.log(1.0 + float(bar_index - z.born)))
                    z.t_f4 := math.max(-5.0, math.min(5.0, z.is_res ? stretch : -stretch))
                    z.t_f5 := math.min(4.0, (z.top - z.bot) / atr)
                    z.t_f6 := math.min(6.0, float(z.strength))
                    z.t_f7 := math.min(8.0, float(z.touches))
                    z.prob := nb_post(z.t_f0, z.t_f1, z.t_f2, z.t_f3, z.t_f4, z.t_f5, z.t_f6, z.t_f7)
                    // Alerts fire only once the classifier is actually in use —
                    // during warmup the figure is the chart's base rate, which
                    // says nothing about this individual test.
                    if model_ready()
                        if (not z.is_res and z.prob >= i_thresh) or (z.is_res and z.prob <= 1.0 - i_thresh)
                            mark_bull := true
                        else if (z.is_res and z.prob >= i_thresh) or (not z.is_res and z.prob <= 1.0 - i_thresh)
                            mark_bear := true

                // STEP 2 — resolve an open test.
                bool resolved_break = false
                if z.testing
                    bool hld  = z.is_res ? close < z.bot - rej : close > z.top + rej
                    bool aged = bar_index - z.t_bar >= i_test_bars
                    if decisive or hld or aged
                        // A decisive break settles it outright. On timeout the
                        // sample is labelled by which side price finished on —
                        // for TRAINING only. A timeout never flips or retires a
                        // level, because no decisive break occurred; that keeps
                        // the break buffer meaningful.
                        int cls = decisive ? 1 : hld ? 0 : ((z.is_res ? close > z.top : close < z.bot) ? 1 : 0)
                        nb_train(cls, z.t_f0, z.t_f1, z.t_f2, z.t_f3, z.t_f4, z.t_f5, z.t_f6, z.t_f7)
                        z.tests   := z.tests + 1
                        z.holds   := z.holds + (cls == 0 ? 1 : 0)
                        z.testing := false
                        resolved_break := decisive
                        // Stamp this test's outcome inside the zone so the level
                        // carries its own record in place.
                        if show_hist and show_zones and not na(z.ticks)
                            line tk = line.new(bar_index, z.bot, bar_index, z.top, color=color.new(cls == 0 ? sup_col : res_col, 45), width=i_border_w + 1)
                            array.push(z.ticks, tk)
                            while array.size(z.ticks) > 8
                                line.delete(array.shift(z.ticks))

                // STEP 3 — a decisive break counts even with no test open. Without
                // this, a break occurring while the zone was disarmed would go
                // unrecorded and the zone would later re-arm on the wrong side
                // with its roles inverted.
                if decisive and not z.testing and not resolved_break
                    resolved_break := true

                // STEP 4 — structural consequence of a decisive break.
                if resolved_break
                    mark_break := true
                    if z.flips == 0
                        // Role reversal: broken support becomes candidate
                        // resistance. Age, tests and holds reset because the
                        // question being asked of the level has changed.
                        z.is_res    := not z.is_res
                        z.flips     := 1
                        z.born      := bar_index
                        z.born_time := time
                        z.tests     := 0
                        z.holds     := 0
                        // Move the box's left edge to match — time-based, not
                        // bar-index, so this is safe regardless of how far back
                        // the zone's original birth bar was.
                        if not na(z.bx)
                            box.set_left(z.bx, z.born_time)
                        // The tick record graded the OLD role; under the new one
                        // it would sit left of the re-anchored box edge, floating
                        // in space, and contradict the reset test count printed
                        // on the label. The record restarts with the role.
                        if not na(z.ticks)
                            while array.size(z.ticks) > 0
                                line.delete(array.shift(z.ticks))
                        // Re-arm only if price has genuinely left the zone in its
                        // NEW role. Arming unconditionally here let the very next
                        // bar open a second test on the same continuous excursion
                        // — a free, degenerate sample taken while price was
                        // already accelerating away, which trained permanently.
                        z.armed  := z.is_res ? high < z.bot : low > z.top
                        z.prob   := base_rate()
                    else
                        z.broken := true
                        z.testing := false
                        // Anchor for the retired record's right edge: the break
                        // bar itself. A gap-break can retire a zone with no test
                        // ever opened in this role, leaving t_bar_time zero or
                        // stale — which would collapse the grey record to a
                        // one-bar sliver at its birth bar.
                        z.t_bar_time := time

                // STEP 5 — re-arm once price has fully left the zone, on the side
                // the zone is actually tested from: a resistance from below, a
                // support from above. A side-agnostic re-arm let a resistance be
                // re-armed while price sat ABOVE it and then "tested" from the
                // wrong side, with the velocity feature sign-flipped and a slice
                // straight down through the level recorded as a HOLD.
                // The disarm window itself stops a consolidation inside a zone
                // from opening a fresh test every few bars.
                else if not z.testing and not z.armed and (z.is_res ? high < z.bot : low > z.top)
                    z.armed := true

    // ── CAP — the live cap removes only LIVE zones, by weakest evidence
    // (pivots + touches). Dropping the oldest would discard exactly the levels
    // that have accumulated the most history, which is backwards. Retired zones
    // are excluded from this loop entirely: they are not counted in live_n, so
    // removing one could never satisfy the condition — it would just delete the
    // retirement record while the loop kept going.
    int live_n = 0
    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            SRZone z = array.get(zones, i)
            live_n := live_n + (z.broken ? 0 : 1)

    while live_n > i_max_zones and array.size(zones) > 0
        int   worst = -1
        float wscore = 1e18
        for i = 0 to array.size(zones) - 1
            SRZone z = array.get(zones, i)
            if not z.testing and not z.broken
                float sc = float(z.strength) * 2.0 + float(z.touches)
                if sc < wscore
                    wscore := sc
                    worst  := i
        if worst < 0
            break
        zone_free(array.get(zones, worst))
        array.remove(zones, worst)
        live_n := live_n - 1

    // Retired zones are kept for reference but capped separately so they cannot
    // grow without bound on a long chart.
    int retired_n = 0
    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            SRZone z = array.get(zones, i)
            retired_n := retired_n + (z.broken ? 1 : 0)
    while retired_n > 6 and array.size(zones) > 0
        int oldest = -1
        for i = 0 to array.size(zones) - 1
            SRZone z = array.get(zones, i)
            if z.broken and oldest < 0
                oldest := i
        if oldest < 0
            break
        zone_free(array.get(zones, oldest))
        array.remove(zones, oldest)
        retired_n := retired_n - 1

// ── DRAW ──────────────────────────────────────────────────────────────────────
// Every live zone's probability is re-read from its frozen signature against the
// CURRENT classifier each bar, so an older zone reflects everything learned since
// its own test resolved.
// lbl_ys collects the price of every zone that renders a worded label this bar;
// the higher-timeframe tags below consult it so a tag never prints on top of a
// zone's label at the same price.
var array<float> lbl_ys = array.new_float()
array.clear(lbl_ys)
if show_zones and array.size(zones) > 0
    for i = array.size(zones) - 1 to 0
        SRZone z = array.get(zones, i)
        float mid   = (z.top + z.bot) * 0.5
        float dist  = (not na(atr) and atr > 0) ? math.abs(mid - close) / atr : 0.0
        bool  above = mid > close
        // Which zones draw is decided by RANK, not by a fixed radius: the
        // nearest i_show_n zones on each side of price, under a generous ATR
        // ceiling. A fixed radius cannot serve every timeframe — an ATR
        // distance that fills a daily chart leaves a 5-minute chart empty —
        // while "the nearest few above and the nearest few below" asks the
        // same question at every resolution. A zone that loses its rank is
        // freed (z.bx/z.lbl return to na) and silently reappears via the
        // creation branch when price comes back; its state (tests, prob,
        // flips) keeps accumulating either way — only the drawing is gated.
        int rank      = 0
        int rank_live = 0
        for j = 0 to array.size(zones) - 1
            if j != i
                SRZone o = array.get(zones, j)
                float om = (o.top + o.bot) * 0.5
                if (om > close) == above and math.abs(om - close) < math.abs(mid - close)
                    rank      := rank + 1
                    rank_live := rank_live + (o.broken ? 0 : 1)
        // Live zones compete only with LIVE zones for the per-side slots —
        // otherwise a cluster of retired records near price could crowd every
        // live level off a side, which is backwards: the retirement record is
        // reference, the live level is the product. Retired zones rank against
        // everything, so they take leftover slots and never displace a level.
        if (z.broken ? rank : rank_live) >= i_show_n or dist > i_show_dist
            if not na(z.bx)
                box.delete(z.bx)
                z.bx := na
            if not na(z.lbl)
                label.delete(z.lbl)
                z.lbl := na
            // The tick record hides WITH its zone. Ticks are anchored at the
            // bars where this zone's tests resolved; with the box gone they
            // read as stray marks floating in empty space. The counts (tests,
            // holds) survive — only the decoration is dropped, and future
            // tests stamp fresh ticks once the zone is back in range.
            if not na(z.ticks)
                while array.size(z.ticks) > 0
                    line.delete(array.shift(z.ticks))
        else
            if na(z.bx)
                // xloc.bar_time throughout: a bar-index box coordinate is
                // rejected by Pine once it sits too many bars behind the current
                // bar (RE10026) — and that limit bites BOTH on creation (a zone
                // reappearing after being hidden by the visibility filter, born
                // long ago) and on repeated updates. A time coordinate has no
                // such limit, so this class of error cannot recur regardless of
                // how long the chart has run or how old a zone's birth bar is.
                z.bx  := box.new(z.born_time, z.top, time + 5 * bar_ms, z.bot, xloc=xloc.bar_time, border_width=i_border_w)
                z.lbl := label.new(bar_index + 5, (z.top + z.bot) * 0.5, "", style=label.style_label_left, size=v2_lbl_size, color=color.new(color.black, 80))
            if not z.broken and z.tests > 0 and not z.testing
                z.prob := nb_post(z.t_f0, z.t_f1, z.t_f2, z.t_f3, z.t_f4, z.t_f5, z.t_f6, z.t_f7)
            bool inside = close <= z.top and close >= z.bot
            // top only, not left — top is a price value with no coordinate
            // limit; left is time-based (see box.new above) and only needs to
            // move at zone birth and at a role flip, both handled where
            // z.born_time itself changes.
            box.set_top         (z.bx, z.top)
            // Border weight follows evidence: a level built from three or more
            // merged pivots reads heavier than a single-swing level, so the
            // eye lands on the levels with history first. V2: the base width
            // is now an input; the 3+-pivot step up is preserved on top of it.
            box.set_border_width(z.bx, z.strength >= 3 ? i_border_w + 1 : i_border_w)
            box.set_rightbottom (z.bx, z.broken ? math.max(z.born_time + bar_ms, z.t_bar_time + 5 * bar_ms) : time + 5 * bar_ms, z.bot)
            box.set_bgcolor     (z.bx, sr_fill  (z.is_res, z.broken, inside, z.prob))
            box.set_border_color(z.bx, sr_border(z.is_res, z.broken, inside, z.prob))
            // V2 evidence grade — a corner letter on the zone itself, so the
            // grade stays readable even on the zones whose worded labels are
            // suppressed by the nearest-only rule. Top corner for resistance,
            // bottom for support, so the letter sits on the side price
            // approaches from. Hidden in Zen Mode with the other text.
            string gTag = i_show_grade and not z.broken and not zen_mode ? f_gradeTag(f_gradeScore(z.strength, z.touches, z.tests, z.born)) : ""
            box.set_text        (z.bx, gTag)
            box.set_text_color  (z.bx, color.new(sr_base(z.is_res), 20))
            box.set_text_size   (z.bx, size.tiny)
            box.set_text_halign (z.bx, text.align_right)
            box.set_text_valign (z.bx, z.is_res ? text.align_top : text.align_bottom)
            if not na(z.lbl)
                // Overlap is solved structurally, not with a distance knob: the
                // worded label renders only on the zones a trader is actually
                // asking about — the nearest live support (rank_live == 0
                // below), the nearest live resistance (rank_live == 0 above),
                // and any zone with a test open right now. Every other zone
                // speaks through its colour alone. That caps the label count
                // at roughly three regardless of timeframe or zoom, which is
                // what stops the overlapping stacks of text near price.
                bool   lbl_on   = show_lbl and not zen_mode and not z.broken and (show_all_lbl or z.testing or rank_live == 0)
                if lbl_on
                    array.push(lbl_ys, (z.top + z.bot) * 0.5)
                // na(z.prob) is structurally impossible after the guards above,
                // but a percentage is the last place a defect should surface —
                // treat it as untested rather than let a comparison with na fall
                // through.
                bool   untested = (z.tests == 0 and not z.testing) or na(z.prob)
                string role     = z.is_res ? "Resistance" : "Support"
                // Past tense, and the classifier's sample size travels with the
                // figure. A bare "68% break risk" would read as a forward-looking
                // risk forecast about an unresolved event; what is actually being
                // reported is how comparable past arrivals on this chart resolved.
                // Suppressed entirely before the classifier is in use — during
                // warmup the number is only the chart's base rate and says
                // nothing about any individual level.
                int    nb_tot   = array.get(nb_cnt, 0) + array.get(nb_cnt, 1)
                string nstr     = "  (n=" + str.tostring(nb_tot) + ")"
                string verdict  = untested ? "untested" : inside ? "price inside" : not model_ready() ? "learning" + nstr : z.prob <= 1.0 - i_thresh ? "similar arrivals broke " + str.tostring(math.round((1.0 - z.prob) * 100)) + "%" + nstr : "similar arrivals held " + str.tostring(math.round(z.prob * 100)) + "%" + nstr
                string extras   = (z.tests > 0 ? "  ·  " + str.tostring(z.tests) + (z.tests == 1 ? " test" : " tests") : "") + (z.flips > 0 ? "  ·  flipped" : "")
                // Colour follows the direction the historical reading leans, and
                // is held neutral until the classifier is actually in use.
                color  dir_col  = untested or inside or not model_ready() ? color.new(color.gray, 20) : z.prob >= i_thresh ? color.new(sr_base(z.is_res), 0) : z.prob <= 1.0 - i_thresh ? color.new(sr_base(not z.is_res), 0) : color.new(color.gray, 20)
                // V2: the grade travels on the worded label too, ahead of the
                // verdict — evidence first, then how similar arrivals resolved.
                string gtxt = gTag != "" ? "grade " + gTag + "  ·  " : ""
                label.set_x        (z.lbl, bar_index + 5)
                label.set_y        (z.lbl, (z.top + z.bot) * 0.5)
                label.set_text     (z.lbl, lbl_on ? role + "  ·  " + gtxt + verdict + extras : "")
                label.set_textcolor(z.lbl, dir_col)
                label.set_size     (z.lbl, v2_lbl_size)
                label.set_color    (z.lbl, lbl_on ? color.new(color.black, 80) : color.new(color.black, 100))

// ── HIGHER-TIMEFRAME MAP — draw ──────────────────────────────────────────────
// One function, six call sites, each with its own var line/label state. Acting
// role follows position, not history: a previous-day high sitting above price
// is approached as resistance, the same line below price as support — so the
// tint follows which side of it price is on, softened to 45 transparency so
// the map sits behind the learned zones instead of competing with them.
// Called unconditionally every bar (required for per-call-site var state);
// the `on` flag handles hide/show.
f_htf_line(bool on, float lvl, int strt, string tag) =>
    var line  ln = na
    var label lb = na
    if not on or na(lvl) or na(strt)
        if not na(ln)
            line.delete(ln)
            ln := na
        if not na(lb)
            label.delete(lb)
            lb := na
    else
        color col = color.new(sr_base(lvl > close), 45)
        if na(ln)
            ln := line.new(strt, lvl, time + 5 * bar_ms, lvl, xloc=xloc.bar_time, color=col, style=line.style_dotted, width=i_htf_w)
            lb := label.new(bar_index + 12, lvl, "", style=label.style_label_left, size=v2_htf_size, color=color.new(color.black, 100), textcolor=col)
        line.set_xy1(ln, strt, lvl)
        line.set_xy2(ln, time + 5 * bar_ms, lvl)
        line.set_color(ln, col)
        line.set_width(ln, i_htf_w)
        label.set_x(lb, bar_index + 12)
        label.set_y(lb, lvl)
        label.set_text(lb, zen_mode or tag == "" ? "" : tag + "  " + str.tostring(lvl, format.mintick))
        label.set_textcolor(lb, col)
        label.set_size(lb, v2_htf_size)
    // Explicit terminal value. The if/else above ends one branch on a label
    // assignment and the other on a void set_* call; as a function's implicit
    // return that mix is rejected (CE10235). Ending on a plain literal makes
    // the return type unambiguous — callers ignore it.
    true

// Suppress a pair on any chart where it degenerates into "the previous candle".
bool pd_on = show_htf and show_pd and timeframe.isintraday
bool pw_on = show_htf and show_pw and not timeframe.isweekly and not timeframe.ismonthly
bool pm_on = show_htf and show_pm and not timeframe.ismonthly

// Each LINE is additionally gated by distance from price, exactly like the
// zones: a previous-week high 100 ATR overhead is real, but drawing it forces
// the y-axis to stretch until the tradeable candles are a sliver at the
// bottom. The line returns the moment price works back within range, and the
// info table reports the full map regardless of this gate.
htf_near(float lvl) =>
    not na(lvl) and not na(atr) and atr > 0 and math.abs(lvl - close) / atr <= i_show_dist

// Two label collisions are suppressed here, the LINE kept in both cases.
// (1) A period twin: when the previous week's high printed on its final day,
// PDH == PWH — drawing both stacks identical text at identical coordinates.
// The higher timeframe keeps the slot; the lower one yields entirely, since
// its line would also be pixel-identical.
// V2: V1 compared for EQUALITY (half a mintick), which caught only the exact
// period twin — PDH landing on PWH to the tick. Two levels a fraction of an
// ATR apart still stacked their tags into an unreadable smear, and enlarging
// the tags makes that worse, so the test is now "close enough that the two
// tags would collide" rather than "identical". Distance is in ATR so it means
// the same thing on every instrument and timeframe. The LINE is still drawn
// for both levels either way — only the redundant tag stands down, and the
// higher timeframe keeps the slot.
htf_eq(float a, float b) =>
    not na(a) and not na(b) and (math.abs(a - b) <= syminfo.mintick * 0.5 or (not na(atr) and atr > 0 and math.abs(a - b) / atr <= 0.30))

// (2) A tag landing on a zone's worded label at the same price — HTF levels
// and learned zones coincide by nature. The zone label already describes the
// level, so the tag stands down and the dotted line still marks the map.
htf_tag(float lvl, string tag) =>
    bool ok = true
    if array.size(lbl_ys) > 0 and not na(lvl) and not na(atr) and atr > 0
        for k = 0 to array.size(lbl_ys) - 1
            if math.abs(lvl - array.get(lbl_ys, k)) / atr < 1.0
                ok := false
    ok ? tag : ""

bool pdh_dup = (htf_eq(pdh, pwh) and pw_on) or (htf_eq(pdh, pmh) and pm_on)
bool pdl_dup = (htf_eq(pdl, pwl) and pw_on) or (htf_eq(pdl, pml) and pm_on)
bool pwh_dup = htf_eq(pwh, pmh) and pm_on
bool pwl_dup = htf_eq(pwl, pml) and pm_on

f_htf_line(pd_on and not pdh_dup and htf_near(pdh), pdh, pd_t, htf_tag(pdh, "PDH"))
f_htf_line(pd_on and not pdl_dup and htf_near(pdl), pdl, pd_t, htf_tag(pdl, "PDL"))
f_htf_line(pw_on and not pwh_dup and htf_near(pwh), pwh, pw_t, htf_tag(pwh, "PWH"))
f_htf_line(pw_on and not pwl_dup and htf_near(pwl), pwl, pw_t, htf_tag(pwl, "PWL"))
f_htf_line(pm_on and htf_near(pmh), pmh, pm_t, htf_tag(pmh, "PMH"))
f_htf_line(pm_on and htf_near(pml), pml, pm_t, htf_tag(pml, "PML"))

plot(show_ema ? ema_line : na, "EMA", color=color.new(color.gray, 60), linewidth=1)

// ── INFO TABLE ────────────────────────────────────────────────────────────────
// Nearest-side fold: keeps whichever of (best, lvl) sits nearer to price on
// the requested side, carrying a tag naming the source. Zones enter untagged;
// a higher-timeframe level that wins carries its name into the table row.
// Role follows position — a previous-day HIGH sitting below price is a
// support candidate, which is why both the high and the low of every period
// are offered to both sides.
f_nearer(float best, string btag, float lvl, string tag, bool on, bool sup) =>
    float  b = best
    string t = btag
    if on and not na(lvl) and (sup ? lvl <= close : lvl > close) and (na(b) or (sup ? lvl > b : lvl < b))
        b := lvl
        t := tag
    [b, t]

var table tbl = table.new(position.top_right, 2, 9,
     bgcolor      = color.new(color.black, 75),
     border_color = color.new(color.gray,  60),
     border_width = 1,
     frame_color  = color.new(color.gray,  50),
     frame_width  = 1)

if barstate.islast and show_table and not zen_mode
    int  h   = array.get(nb_cnt, 0)
    int  b   = array.get(nb_cnt, 1)
    bool rdy = model_ready()
    int   act = 0
    float ns  = na
    float nr  = na
    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            SRZone z = array.get(zones, i)
            if not z.broken
                act := act + 1
                float m = (z.top + z.bot) * 0.5
                if m <= close
                    ns := na(ns) ? m : math.max(ns, m)
                else
                    nr := na(nr) ? m : math.min(nr, m)
    // In a strong trend one side often has NO live zone left — every support
    // broke on the way down — which is exactly when a trader most wants the
    // next reference. The higher-timeframe map fills the row: nearest of zone
    // or HTF level wins, and an HTF winner is named (PDL, PWL, ...).
    [s1, st1] = f_nearer(ns, "",  pdh, "PDH", pd_on, true)
    [s2, st2] = f_nearer(s1, st1, pdl, "PDL", pd_on, true)
    [s3, st3] = f_nearer(s2, st2, pwh, "PWH", pw_on, true)
    [s4, st4] = f_nearer(s3, st3, pwl, "PWL", pw_on, true)
    [s5, st5] = f_nearer(s4, st4, pmh, "PMH", pm_on, true)
    [s6, st6] = f_nearer(s5, st5, pml, "PML", pm_on, true)
    [r1, rt1] = f_nearer(nr, "",  pdh, "PDH", pd_on, false)
    [r2, rt2] = f_nearer(r1, rt1, pdl, "PDL", pd_on, false)
    [r3, rt3] = f_nearer(r2, rt2, pwh, "PWH", pw_on, false)
    [r4, rt4] = f_nearer(r3, rt3, pwl, "PWL", pw_on, false)
    [r5, rt5] = f_nearer(r4, rt4, pmh, "PMH", pm_on, false)
    [r6, rt6] = f_nearer(r5, rt5, pml, "PML", pm_on, false)
    color txt_wht = color.new(color.white, 0)
    // Distance travels with the price so the row answers both questions a
    // trader has at a glance: where is it, and how far away is it.
    string ns_txt = na(s6) ? "—" : str.tostring(s6, format.mintick) + (st6 != "" ? "  ·  " + st6 : "") + (not na(atr) and atr > 0 ? "  ·  " + str.tostring(math.abs(close - s6) / atr, "#.#") + " ATR" : "")
    string nr_txt = na(r6) ? "—" : str.tostring(r6, format.mintick) + (rt6 != "" ? "  ·  " + rt6 : "") + (not na(atr) and atr > 0 ? "  ·  " + str.tostring(math.abs(close - r6) / atr, "#.#") + " ATR" : "")

    table.cell(tbl, 0, 0, "SR AI", text_color=color.new(color.gray, 0), text_size=size.small, bgcolor=color.new(color.black, 60))
    table.cell(tbl, 1, 0, rdy ? "● LIVE" : "● LEARNING", text_color=rdy ? color.new(color.lime, 0) : color.new(color.yellow, 0), text_size=size.small, bgcolor=color.new(color.black, 60))

    table.cell(tbl, 0, 1, "Levels On Chart", text_color=txt_wht, text_size=size.small)
    table.cell(tbl, 1, 1, str.tostring(act), text_color=txt_wht, text_size=size.small)

    table.cell(tbl, 0, 2, "Tests Graded", text_color=txt_wht, text_size=size.small)
    table.cell(tbl, 1, 2, str.tostring(h + b) + (rdy ? "" : " / " + str.tostring(i_warmup)), text_color=rdy ? color.new(color.lime, 0) : color.new(color.yellow, 0), text_size=size.small)

    table.cell(tbl, 0, 3, "Levels Held", text_color=txt_wht, text_size=size.small)
    table.cell(tbl, 1, 3, str.tostring(math.round(base_rate() * 100)) + "% of tests", text_color=txt_wht, text_size=size.small)

    table.cell(tbl, 0, 4, "Nearest Support", text_color=color.new(sup_col, 0), text_size=size.small)
    table.cell(tbl, 1, 4, ns_txt, text_color=color.new(sup_col, 0), text_size=size.small)

    table.cell(tbl, 0, 5, "Nearest Resistance", text_color=color.new(res_col, 0), text_size=size.small)
    table.cell(tbl, 1, 5, nr_txt, text_color=color.new(res_col, 0), text_size=size.small)

    table.cell(tbl, 0, 6, "─────", text_color=color.new(color.gray, 60), text_size=size.tiny)
    table.cell(tbl, 1, 6, "─────", text_color=color.new(color.gray, 60), text_size=size.tiny)

    table.cell(tbl, 0, 7, "Blue", text_color=color.new(sup_col, 0), text_size=size.tiny)
    table.cell(tbl, 1, 7, "support · held test", text_color=color.new(color.gray, 20), text_size=size.tiny)

    table.cell(tbl, 0, 8, "Orange", text_color=color.new(res_col, 0), text_size=size.tiny)
    table.cell(tbl, 1, 8, "resistance · broken test", text_color=color.new(color.gray, 20), text_size=size.tiny)

// ── ALERTS ────────────────────────────────────────────────────────────────────
// Worded as observations. This script reports how a level test resolved and what
// the historical record associates with that kind of arrival; it does not direct
// anyone to take a position.
alertcondition(mark_bull, "Bullish-leaning zone test", "Support Resistance AI [PickMyTrade]: a zone test opened with a bullish-leaning reading — a support historically associated with holding, or a resistance historically associated with breaking. Informational, not a trade instruction.")
alertcondition(mark_bear, "Bearish-leaning zone test", "Support Resistance AI [PickMyTrade]: a zone test opened with a bearish-leaning reading — a resistance historically associated with holding, or a support historically associated with breaking. Informational, not a trade instruction.")
alertcondition(mark_bull or mark_bear, "Any high-conviction zone test", "Support Resistance AI [PickMyTrade]: a zone test opened with the classifier's probability at or beyond the configured threshold.")
alertcondition(mark_break, "Level decisively broken", "Support Resistance AI [PickMyTrade]: price closed decisively beyond a level. A first break flips the level's role — broken support becomes candidate resistance — and a second break retires it. Informational, not a trade instruction.")
````
