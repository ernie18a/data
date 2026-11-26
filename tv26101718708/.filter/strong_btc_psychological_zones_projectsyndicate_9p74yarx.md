# Strong BTC Psychological Zones | ProjectSyndicate

- url: https://www.tradingview.com/script/9P74YARx-Strong-BTC-Psychological-Zones-ProjectSyndicate/
- type: indicator
- pine_id: PUB;ac6101e202e74241bad764d9c7372d6e
- version: 1.0

## Description

▪️Strong BTC Psychological Zones maps the prices every Bitcoin trader already watches, the round numbers, and tells you how each one has actually behaved. Round numbers like 84,000, 84,500 and 84,250 attract orders, stops and attention, but "psychological level" on its own is a guess. Some round numbers hold price again and again. Others get sliced through as if they weren't there. This indicator stops treating them as equal. It measures every test of every level and gives each zone its own track record before price arrives.

▪️Every 250 USD becomes a shaded zone that runs across the whole chart. When price reaches a zone, the engine opens a test, follows it to a confirmed close, and logs the outcome: REVERSAL, BREAKOUT or STALLED. Those outcomes become each zone's reversal and breakout probability, its hold rate as support and as resistance, its fakeout rate and its reaction size. The zone's color comes from its own record: cyan where reversals dominate, orange where breakouts dominate, slate where the record is split or too thin to judge.

▪️Most round-number tools draw a grid and stop there. This one counts, on a timeframe you choose and lock, every time price came to each level, what happened next, and whether the result is a real edge or just noise. All of it is written inside the zone and laid out in a structured dashboard.

🎯 The Test Engine (the core). A test starts the moment price enters a zone from outside. The side it comes from decides the question: from above is a support test, from below is a resistance test. The test resolves on a confirmed close only.

REVERSAL: a bar closes far enough back toward the side price came from. By default that is the larger of 60% of the grid step or 0.5 ATR.
BREAKOUT: a bar closes beyond the far edge of the zone plus an ATR buffer.
STALLED: the test neither reverses nor breaks within the timeout. Stalled tests are counted and shown, but left out of the reversal/breakout split so they can't distort it.

Wicks don't count as outcomes. Only closes decide.

🔒 Locked Statistics (same numbers on every chart timeframe). All counting runs on one fixed stats timeframe, 5m by default and adjustable, over a fixed calendar window (30 days by default, anchored at 00:00 UTC). The engine runs inside that timeframe's own data, not your chart's. Switch between 1m, 15m, 1H and 4H and every probability stays identical. The dashboard footer confirms the lock: stats timeframe, window, bar count and start date. If your data plan can't supply the full window, the footer turns orange and reads PARTIAL WINDOW with the real start date, so you always know what the numbers are built on.

📊 Probabilities That Show Their Uncertainty. Every zone reports its Reversal Probability and Breakout Probability with a 95% range. A 60/40 split from 8 tests and the same split from 80 tests are not the same claim, and the range makes the difference visible. The record is also split by side (Held as Support and Held as Resistance), because many levels behave differently depending on direction. The Next Test row shows the hold rate for the side price will actually test from, based on where price is now. Edge vs Tier Average compares each zone with the average for its tier (Major, Mid or Minor), in points, and marks the edge significant only when it clears a standard statistical test (|z| ≥ 1.96).

⭐ Strength Score (0–10, based on the conservative estimate). The strength score is 10 × the low end of the 95% range for the zone's dominant outcome. A zone can't score high on a few lucky tests: 3 for 3 scores below 30 for 40. Zones with fewer than 4 resolved tests are tagged FORMING and drawn neutral. A zone becomes a Reversal Zone or Breakout Zone only when one outcome reaches the bias threshold (55% by default). Otherwise it is Contested.

🧪 Behavior Behind the Numbers. After every outcome the engine keeps watching for a set number of bars.

Fakeouts: a breakout that closes back through the zone inside the watch window is logged as a fakeout. You see how often each level's breakouts fail.
Sweep Reversals: a wick that pierced the far edge without a confirming close, followed by a reversal. That is a liquidity grab, counted per zone.
Support / Resistance Flips: a level broken in one direction that later holds from the other side.
Average Reaction and Breakout Follow-Through: how far price typically travels after each outcome, in ATR.
Time to Resolve: how long a typical test lasts, in real time.
Last Event: the most recent outcome and how long ago it happened.

🏛️ Level Hierarchy. Not all round numbers are equal, so the grid is tiered. The 1,000s are MAJOR (solid gold line), the 500s are MID (dashed) and the 250s are MINOR (dotted). Each tier keeps its own average, so a zone is compared with others of its own tier, not with the whole grid.

🎨 Shaded Zones with In-Zone Labels. Each level is a ±30 USD band with a denser core stripe along the level itself.

The band gets more opaque as the strength score rises.
The core stripe gets denser the more often the level has been tested.
A zone under a live test gets a dashed border.
Inside every zone, on a solid backing so lines never run through the text, sits one plain-English line: level · zone type · Reversal % · Breakout %. No abbreviations and no hover-only text.

📋 The Dashboard (six levels at a glance). The top-right panel shows the 3 levels above and the 3 below price, with a PRICE column dividing them. It is laid out in separated sections:

Level, Tier, Zone Type, Strength
Reversal Probability, Breakout Probability, Reversal 95% Range
Tests, Reversals, Breakouts, Stalled
Held as Support, Held as Resistance, Next Test
Fakeouts, Sweep Reversals, Support / Resistance Flips, Average Reaction, Breakout Follow-Through, Time to Resolve
Edge vs Tier Average, Last Event, Distance from Price

Level columns keep their zone colors. A Core mode trims the panel to the decision rows. Position and text size are adjustable.

🧼 Clean-Chart Discipline. By default the chart shows zones, level lines, in-zone labels and one dashboard. Nothing else. Historical R / B / F event markers exist for anyone who wants them, but they're off by default.

🔒 Honest Statistics. This is a measurement tool, not a signal service and not a promise that any level will react. Every test is counted: none are dropped for turning out badly, stalls are shown rather than hidden, and weak samples are labelled FORMING instead of being dressed up. Probabilities are the historical frequencies of each level inside the locked window. They describe how a level has behaved, not how it must behave next. Outcomes are recorded only on confirmed stats-timeframe closes and don't repaint afterwards. A live test in progress can still change until its bar closes.

🔔 Native Alerts.

Zone Reversal Confirmed: a test resolves as a reversal.
Zone Breakout Up / Down: a level is closed through.
Fakeout Detected: a recent breakout closes back through its zone.
High-Probability Zone Test: a new test starts at a zone whose hold rate for that side is 65% or higher, with enough resolved tests behind it.
A dynamic alert message names the level and the event. All alerts come from the locked stats timeframe, so they behave the same on any chart.

🎯 Why this is different. A round-number grid treats every level the same. This one grades each level by its own history, keeps support and resistance apart, shows how uncertain every percentage is, flags whether an edge is statistically meaningful, and locks all of it to one timeframe so the numbers don't shift when you switch charts.

🚀 Built for BTCUSD. The grid step and zone width are inputs, so it adapts to ETH, Gold (XAUUSD), indices and other markets that trade around round numbers.

💡 Cleanest setup: stats locked on 5m over 30 days, chart on 5m–1H, Core rows if you want a smaller panel. On 4H and above, raise the grid step to 500 or 1,000 so single candles don't swallow several levels. If the footer says PARTIAL WINDOW, shorten the window until it reads LOCKED.

🎯 How To Trade It: Two Approaches

Everything comes down to one question: when price reaches this round number from this side, what has it historically done, and is that record strong enough to lean on?

🧱 1) Fade the Reversal Zone: a reaction at a level that holds

Use this when price approaches a cyan Reversal Zone.

▪️Read the record. You want a high Next Test hold rate for the side price is coming from, a strength of ★★★ or more, a significant edge against the tier average, and ideally a high Sweep Reversals count, which means the level has a habit of trapping breakout traders before turning.

▪️Trigger: a rejection at the zone, or the confirmed REVERSAL close.
Target: the next zone in the reversal direction, with Average Reaction (ATR) as a guide to typical travel.
Stop: beyond the far edge of the zone.
Invalidation: a BREAKOUT close through the zone. The level gave way, so step aside or switch to approach 2.

⚡ 2) Trade the Breakout Zone: continuation through a level that rarely holds

Use this when price approaches an orange Breakout Zone.

▪️Read the record. You want a high breakout probability for the side being tested, a low fakeout rate, and a solid Breakout Follow-Through in ATR.

▪️Trigger: the confirmed BREAKOUT close beyond the zone.
Target: the next one or two zones beyond, with Breakout Follow-Through as a guide to typical travel.
Stop: back inside the zone.
Watch: the fakeout window. A close back through the zone means the break failed, and the level's fakeout history tells you how often that happens.

✋ Stand down: when the dashboard says wait

CONTESTED zones: the record is split, so neither side has an edge.
FORMING or UNTESTED zones: too few tests to judge.
A wide 95% range or an edge marked not significant: the percentage may just be noise.
A PARTIAL WINDOW footer: the stats are not built on the full window.
Price between zones with no test in progress: wait for contact and let the alert bring you in.

Rule of thumb: 🧱 Cyan zone + high hold rate for the side being tested + significant edge → fade the first test, stop beyond the zone. ⚡ Orange zone + low fakeout rate + strong follow-through → trade the confirmed close toward the next level. ❄️ Contested, forming, not significant or partial window → stand down until a level has earned its record.

## Source Code

````pine
//@version=6
indicator("Strong BTC Psychological Zones", "BTC Psych Zones", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)


// ─────────────────────────────── INPUTS ────────────────────────────────────
const string G_GRID = "═══ Psychological Grid ═══"
gridStep    = input.float(250.0, "Grid Step (USD)", minval = 1.0, step = 50.0, group = G_GRID, tooltip = "Distance between psychological levels. 250 = quarter-thousands on BTCUSD. Every 4th level is MAJOR (1,000s), every 2nd is MID (500s), the rest MINOR.")
halfW       = input.float(30.0, "Zone Half-Width (USD)", minval = 1.0, step = 5.0, group = G_GRID, tooltip = "Zone = level ± this amount. Price entering this band starts a TEST of the level.")
levelsUp    = input.int(10, "Zones Above Price", minval = 1, maxval = 30, group = G_GRID)
levelsDn    = input.int(10, "Zones Below Price", minval = 1, maxval = 30, group = G_GRID)
anchorMode  = input.string("Visible Chart Edge", "Zone Left Edge", options = ["Visible Chart Edge", "Fixed Bars Back"], group = G_GRID, tooltip = "Visible Chart Edge: every zone starts at the leftmost bar currently visible on the chart and runs to the current bar (the chart redraws when you scroll or zoom). Fixed Bars Back: zones start a fixed number of bars back.")
zoneHist    = input.int(300, "Fixed Bars Back", minval = 20, maxval = 5000, group = G_GRID, tooltip = "Used only when Zone Left Edge = Fixed Bars Back.")
labGap      = input.int(3, "Label Gap From Zone (bars)", minval = 0, maxval = 50, group = G_GRID, tooltip = "Empty space between the zone's right edge (current bar) and its label.")

const string G_LOCK = "═══ Stats Lock ═══"
calcTF      = input.timeframe("5", "Stats Timeframe", group = G_LOCK, tooltip = "Every test, reversal and breakout is measured on this timeframe only. Changing the chart timeframe does NOT change the statistics.")
statsDays   = input.int(30, "Stats Window (days)", minval = 1, maxval = 365, group = G_LOCK, tooltip = "Calendar window, anchored to 00:00 UTC. Identical on every chart timeframe. If your plan's history for the stats timeframe is shorter, the dashboard footer flags the window as PARTIAL.")

const string G_ENG = "═══ Event Engine (confirmed bars) ═══"
revMode     = input.string("Max of Both", "Reversal Distance Mode", options = ["Grid %", "ATR", "Max of Both"], group = G_ENG, tooltip = "A test becomes a REVERSAL when a bar CLOSES this far from the level on the side price came from.")
revStepPct  = input.float(60.0, "Reversal Distance (% of Grid Step)", minval = 10.0, maxval = 400.0, step = 5.0, group = G_ENG)
revAtrMult  = input.float(0.50, "Reversal Distance (ATR ×)", minval = 0.05, maxval = 5.0, step = 0.05, group = G_ENG)
brkBufAtr   = input.float(0.10, "Breakout Close Buffer (ATR ×)", minval = 0.0, maxval = 2.0, step = 0.05, group = G_ENG, tooltip = "A test becomes a BREAKOUT when a bar CLOSES beyond the far zone edge by this buffer.")
maxTestBars = input.int(120, "Test Timeout (stats-TF bars)", minval = 5, maxval = 2000, group = G_ENG, tooltip = "Tests that neither reverse nor break within this many bars are logged as STALLED (counted, shown, excluded from the reversal/breakout split).")
watchBars   = input.int(20, "Post-Event Watch (stats-TF bars)", minval = 3, maxval = 300, group = G_ENG, tooltip = "After a reversal or breakout, follow-through is measured for this many bars. A breakout that closes back through the opposite zone edge inside this window is a FAKEOUT.")
atrLen      = input.int(14, "ATR Length", minval = 1, maxval = 500, group = G_ENG)

const string G_LAB = "═══ Zone Labels ═══"
showZoneLab = input.bool(true, "Show Zone Labels", group = G_LAB, tooltip = "Written inside each shaded zone: level, zone type, reversal and breakout probability.")
labSizeS    = input.string("Normal", "Zone Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_LAB)
labBgCol    = input.color(color.new(#0B1220, 0), "Zone Label Backing", group = G_LAB, tooltip = "Solid plate behind the zone text so the level line and core stripe never run through the letters.")
minN        = input.int(4, "Min Resolved Tests for a Bias", minval = 1, maxval = 50, group = G_LAB, tooltip = "Below this many resolved tests a zone is tagged Forming and drawn neutral.")
biasThr     = input.float(55.0, "Bias Threshold (%)", minval = 50.0, maxval = 90.0, step = 1.0, group = G_LAB)

const string G_DASH = "═══ Stats Dashboard ═══"
showDash    = input.bool(true, "Show Dashboards", group = G_DASH, tooltip = "Two panels: the 4 levels ABOVE price in the upper panel, the 4 levels BELOW price in the lower panel.")
dashSide    = input.string("Right", "Panel Side", options = ["Right", "Left"], group = G_DASH)
dashLowPos  = input.string("Bottom", "Below-Price Panel", options = ["Bottom", "Middle"], group = G_DASH, tooltip = "Vertical position of the lower panel. Bottom keeps it clear of the upper panel on most screens.")
dashRows    = input.string("Full", "Rows", options = ["Full", "Core"], group = G_DASH, tooltip = "Core keeps probabilities, tests, hold rates, next test and distance.")
dashSizeS   = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal"], group = G_DASH)
dashNameW   = input.float(10.0, "Name Column Width (% of chart)", minval = 4.0, maxval = 25.0, step = 0.5, group = G_DASH, tooltip = "Fixed widths keep both panels aligned column-for-column. Widen if text clips on a small screen.")
dashLevelW  = input.float(8.5, "Level Column Width (% of chart)", minval = 3.0, maxval = 20.0, step = 0.5, group = G_DASH)

const string G_COL = "═══ Style ═══"
revCol      = input.color(#22D3EE, "Reversal-Dominant", inline = "c1", group = G_COL)
brkCol      = input.color(#FB923C, "Breakout-Dominant", inline = "c1", group = G_COL)
neuCol      = input.color(#64748B, "Contested / Forming", inline = "c2", group = G_COL)
majCol      = input.color(#EAB308, "MAJOR Level Line", inline = "c2", group = G_COL)
txtCol      = input.color(#F1F5F9, "Label Text", group = G_COL)
gradFill    = input.bool(true, "Gradient (double-shaded) Fill", group = G_COL)
fillTransp  = input.int(84, "Zone Transparency", minval = 50, maxval = 96, group = G_COL)
showBord    = input.bool(true, "Show Zone Borders", group = G_COL)
bordTransp  = input.int(35, "Border Transparency", minval = 0, maxval = 100, group = G_COL)
showEvents  = input.bool(false, "Show Historical Event Markers (R / B / F)", group = G_COL, tooltip = "Off by default. Marks every past reversal (R), breakout (B) and fakeout (F) bar.")

const string G_AL = "═══ Alerts ═══"
alertProb   = input.float(65.0, "High-Probability Test Alert (hold %)", minval = 50.0, maxval = 100.0, step = 1.0, group = G_AL, tooltip = "Fires when a new test starts at a zone whose side-specific hold rate is at least this, with at least 'Min Resolved Tests' samples.")

const color NEU_TXT   = #D5DCE6
const color DASH_BG   = #0B1220
const color DASH_NAME = #CBD5E1
const int MAX_SCAN = 150

// ─────────────────────────────── TYPES ─────────────────────────────────────
type Lvl
    int   state     = 0
    int   side      = 0
    int   startBar  = 0
    bool  swept     = false
    int   tests     = 0
    int   revSup    = 0
    int   revRes    = 0
    int   brkUp     = 0
    int   brkDn     = 0
    int   stalls    = 0
    int   sweepRev  = 0
    int   flips     = 0
    int   fakes     = 0
    int   brkDone   = 0
    int   revDone   = 0
    float reactSum  = 0.0
    float followSum = 0.0
    int   decideSum = 0
    int   lastType  = 0
    int   lastDir   = 0
    int   lastTime  = 0
    int   wType     = 0
    int   wDir      = 0
    int   wUntil    = -1
    float wMax      = 0.0
    float wAtr      = 0.0

// Close the post-event watch and bank its follow-through (in ATR units).
method finWatch(Lvl this, bool failed) =>
    float excAtr = this.wAtr > 0 ? math.max(this.wMax, 0.0) / this.wAtr : 0.0
    if this.wType == 1
        this.revDone  := this.revDone + 1
        this.reactSum := this.reactSum + excAtr
    else if this.wType == 2
        this.brkDone   := this.brkDone + 1
        this.followSum := this.followSum + excAtr
        if failed
            this.fakes := this.fakes + 1
    this.wType := 0
    this.wMax  := 0.0
    true

method startWatch(Lvl this, int wtype, int dir, int untilBar, float atrNow) =>
    if this.wType != 0
        this.finWatch(false)
    this.wType  := wtype
    this.wDir   := dir
    this.wUntil := untilBar
    this.wMax   := 0.0
    this.wAtr   := atrNow
    true

// Whole stats book. Collections travel through request.security inside object fields.
type Book
    map<int, Lvl> lv
    array<int>    active
    array<int>    tierRev
    array<int>    tierBrk
    int           firstTime = 0
    int           nBars     = 0

// ─────────────────────────────── HELPERS ───────────────────────────────────
f_size(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

f_tierIdx(int k) =>
    int a = math.abs(k)
    a % 4 == 0 ? 0 : a % 2 == 0 ? 1 : 2

f_tierName(int t) => t == 0 ? "Major" : t == 1 ? "Mid" : "Minor"

f_frac(int a, int b) => b > 0 ? str.tostring(a) + " / " + str.tostring(b) + "  (" + str.tostring(math.round(float(a) / float(b) * 100.0)) + "%)" : "—"
f_dur(float ms) =>
    float m = math.max(ms, 0.0) / 60000.0
    string o = ""
    if m < 60.0
        o := str.tostring(math.round(m)) + "m"
    else if m < 1440.0
        float h = math.floor(m / 60.0)
        o := str.tostring(h, "0") + "h " + str.tostring(math.round(m - h * 60.0)) + "m"
    else
        float d = math.floor(m / 1440.0)
        o := str.tostring(d, "0") + "d " + str.tostring(math.floor((m - d * 1440.0) / 60.0), "0") + "h"
    o

f_tfLabel(string tf) => str.match(tf, "^[0-9]+$") != "" ? tf + "m" : tf

f_cutoff() =>
    int dayMs = 86400000
    int(math.floor(timenow / dayMs)) * dayMs - statsDays * dayMs

f_ratio(int a, int b) =>
    float r = na
    if b > 0
        r := float(a) / float(b)
    r

f_inv(float p) =>
    float r = na
    if not na(p)
        r := 1.0 - p
    r

f_pct(float p) => na(p) ? "—" : str.tostring(math.round(p * 100.0)) + "%"
f_num(float x) => na(x) ? "—" : str.tostring(x, "0.0")

f_stars(float sc) => sc >= 7.0 ? "★★★★" : sc >= 5.5 ? "★★★" : sc >= 4.0 ? "★★" : sc >= 2.5 ? "★" : "·"

// 95% Wilson score interval for s successes in n trials.
f_wilson(int s, int n) =>
    float lo = na
    float hi = na
    if n > 0
        float zz  = 1.96
        float nn  = float(n)
        float p   = float(s) / nn
        float den = 1.0 + zz * zz / nn
        float ctr = (p + zz * zz / (2.0 * nn)) / den
        float hw  = zz * math.sqrt(p * (1.0 - p) / nn + zz * zz / (4.0 * nn * nn)) / den
        lo := math.max(0.0, ctr - hw)
        hi := math.min(1.0, ctr + hw)
    [lo, hi]

// Bias colour, zone type, 0–10 score (10 × Wilson lower bound of the dominant outcome), bias code.
f_bias(Lvl z) =>
    color  c    = neuCol
    string tag  = "Untested"
    float  sc   = 0.0
    int    bias = 0
    if not na(z)
        int R = z.revSup + z.revRes
        int B = z.brkUp + z.brkDn
        int n = R + B
        if n == 0
            tag := z.tests > 0 ? "Forming" : "Untested"
        else
            [loR, hiR] = f_wilson(R, n)
            [loB, hiB] = f_wilson(B, n)
            float pR = float(R) / float(n)
            if n < minN
                tag := "Forming"
                sc  := 10.0 * math.max(loR, loB)
            else if pR * 100.0 >= biasThr
                c    := revCol
                tag  := "Reversal Zone"
                sc   := 10.0 * loR
                bias := 1
            else if (1.0 - pR) * 100.0 >= biasThr
                c    := brkCol
                tag  := "Breakout Zone"
                sc   := 10.0 * loB
                bias := 2
            else
                tag := "Contested"
                sc  := 10.0 * math.max(loR, loB)
    [c, tag, sc, bias]

// In-zone label: level · zone type · reversal / breakout probability (full words).
f_zoneText(Lvl z, float L, string tag) =>
    string s = str.tostring(L, "#,###") + "  ·  " + tag
    int nRev = 0
    int nBrk = 0
    if not na(z)
        nRev := z.revSup + z.revRes
        nBrk := z.brkUp + z.brkDn
    int n = nRev + nBrk
    if n > 0
        s := s + "  ·  Reversal " + f_pct(f_ratio(nRev, n)) + "  ·  Breakout " + f_pct(f_ratio(nBrk, n))
    s

// Dashboard values for one level, one entry per dashboard row (see DASH_NAMES).
f_vals(Lvl z, int k, float L, string tag, float sc, array<int> tierRev, array<int> tierBrk) =>
    array<string> v = array.new_string(28, "—")
    int   t    = f_tierIdx(k)
    float dist = close - L
    v.set(0, str.tostring(L, "#,###"))
    v.set(1, f_tierName(t))
    v.set(2, tag)
    v.set(27, (dist >= 0 ? "+" : "−") + str.tostring(math.abs(dist), "#,###") + "  (" + str.tostring(math.abs(dist) / close * 100.0, "0.00") + "%)")
    bool has = false
    if not na(z)
        has := z.tests > 0
    if has
        int   R    = z.revSup + z.revRes
        int   B    = z.brkUp + z.brkDn
        int   n    = R + B
        float pR   = f_ratio(R, n)
        float pB   = f_ratio(B, n)
        [lo, hi]   = f_wilson(R, n)
        float pSup = f_ratio(z.revSup, z.revSup + z.brkDn)
        float pRes = f_ratio(z.revRes, z.revRes + z.brkUp)
        v.set(3, f_stars(sc) + "  " + str.tostring(sc, "0.0") + " / 10")
        v.set(5, f_pct(pR))
        v.set(6, f_pct(pB))
        v.set(7, na(lo) ? "—" : f_pct(lo) + " – " + f_pct(hi))
        v.set(9, str.tostring(z.tests))
        v.set(10, str.tostring(R))
        v.set(11, str.tostring(B))
        v.set(12, str.tostring(z.stalls))
        v.set(14, f_frac(z.revSup, z.revSup + z.brkDn))
        v.set(15, f_frac(z.revRes, z.revRes + z.brkUp))
        if z.state == 1
            v.set(16, "LIVE as " + (z.side > 0 ? "Support" : "Resistance") + " · Hold " + f_pct(z.side > 0 ? pSup : pRes))
        else if close > L
            v.set(16, "Support · Hold " + f_pct(pSup))
        else
            v.set(16, "Resistance · Hold " + f_pct(pRes))
        v.set(18, f_frac(z.fakes, z.brkDone))
        v.set(19, str.tostring(z.sweepRev))
        v.set(20, str.tostring(z.flips))
        if z.revDone > 0
            v.set(21, str.tostring(z.reactSum / float(z.revDone), "0.0") + " ATR")
        if z.brkDone > 0
            v.set(22, str.tostring(z.followSum / float(z.brkDone), "0.0") + " ATR")
        if n > 0
            v.set(23, f_dur(float(z.decideSum) / float(n) * timeframe.in_seconds(calcTF) * 1000.0))
        int   tR   = tierRev.get(t)
        int   tB   = tierBrk.get(t)
        float base = f_ratio(tR, tR + tB)
        if not na(base) and not na(pR)
            float zsc = base > 0.0 and base < 1.0 ? (pR - base) / math.sqrt(base * (1.0 - base) / float(n)) : 0.0
            float pp  = (pR - base) * 100.0
            v.set(25, (pp >= 0 ? "+" : "−") + str.tostring(math.abs(pp), "0") + " pts · " + (math.abs(zsc) >= 1.96 ? "significant" : "not significant"))
        if z.lastType == 1
            v.set(26, "Reversal " + (z.lastDir > 0 ? "↑" : "↓") + " · " + f_dur(timenow - z.lastTime))
        else if z.lastType == 2
            v.set(26, "Breakout " + (z.lastDir > 0 ? "↑" : "↓") + " · " + f_dur(timenow - z.lastTime))
        else if z.lastType == 3
            v.set(26, "Stalled · " + f_dur(timenow - z.lastTime))
    v

f_isCore(int i) => i <= 9 or (i >= 13 and i <= 17) or i == 24 or i == 27

// ─────────────────────────────── EVENT ENGINE ──────────────────────────────
// Runs ONLY inside request.security on the Stats Timeframe. All state is local
// (var) to that context, so the chart timeframe never touches the counting.
f_engine() =>
    var Book sb  = Book.new(map.new<int, Lvl>(), array.new_int(), array.new_int(3, 0), array.new_int(3, 0))
    var int  cRU = 0
    var int  cRD = 0
    var int  cBU = 0
    var int  cBD = 0
    var int  cF  = 0
    var int  cH  = 0
    var int  seq = 0
    var string lastMsg = ""
    float  atrV     = ta.atr(atrLen)
    float  c1       = nz(close[1], open)
    int    cutoff   = f_cutoff()
    float  revStepD = gridStep * revStepPct / 100.0
    bool   evRevUp  = false
    bool   evRevDn  = false
    bool   evBrkUp  = false
    bool   evBrkDn  = false
    bool   evFake   = false
    bool   evHiProb = false
    string alertMsg = ""
    if barstate.isconfirmed and time >= cutoff and not na(atrV) and atrV > 0
        if sb.nBars == 0
            sb.firstTime := time
        sb.nBars := sb.nBars + 1
        float revDist = revMode == "Grid %" ? revStepD : revMode == "ATR" ? atrV * revAtrMult : math.max(revStepD, atrV * revAtrMult)
        revDist := math.max(revDist, halfW + syminfo.mintick)
        float buf = atrV * brkBufAtr
        float hiX = math.max(high, c1)
        float loX = math.min(low, c1)
        int   kLo = int(math.ceil((loX - halfW) / gridStep))
        int   kHi = int(math.floor((hiX + halfW) / gridStep))
        kHi := math.min(kHi, kLo + MAX_SCAN)

        array<int> proc = array.new_int()
        if kHi >= kLo
            for k = kLo to kHi
                proc.push(k)
        for ka in sb.active
            if ka < kLo or ka > kHi
                proc.push(ka)

        array<int> nxt = array.new_int()
        for k in proc
            Lvl z = sb.lv.get(k)
            if na(z)
                z := Lvl.new()
                sb.lv.put(k, z)
            float  L    = k * gridStep
            float  zT   = L + halfW
            float  zB   = L - halfW
            int    ti   = f_tierIdx(k)
            string lvlS = str.tostring(L, "#,###")

            // 1) Post-event watch: follow-through + fakeout detection
            if z.wType != 0
                float exc = z.wDir > 0 ? high - L : L - low
                z.wMax := math.max(z.wMax, exc)
                bool failed = z.wType == 2 and (z.wDir > 0 ? close < zB : close > zT)
                if failed or bar_index >= z.wUntil
                    if failed
                        evFake   := true
                        alertMsg := alertMsg + "FAKEOUT " + lvlS + " — breakout closed back through the zone. "
                    z.finWatch(failed)

            // 2) New test: price reaches the zone from outside
            bool touch = hiX >= zB and loX <= zT
            if z.state == 0 and touch
                int s0 = c1 > zT ? 1 : c1 < zB ? -1 : 0
                if s0 != 0
                    z.state    := 1
                    z.side     := s0
                    z.startBar := bar_index
                    z.swept    := false
                    z.tests    := z.tests + 1
                    int hold = s0 > 0 ? z.revSup : z.revRes
                    int fail = s0 > 0 ? z.brkDn : z.brkUp
                    int ns   = hold + fail
                    if ns >= minN and float(hold) / float(ns) * 100.0 >= alertProb
                        evHiProb := true
                        alertMsg := alertMsg + "HIGH-PROB TEST " + lvlS + " as " + (s0 > 0 ? "SUPPORT" : "RESISTANCE") + " — hold " + f_pct(float(hold) / float(ns)) + " (n=" + str.tostring(ns) + "). "

            // 3) Resolve active test
            if z.state == 1
                int  s   = z.side
                bool brk = s > 0 ? close < zB - buf : close > zT + buf
                bool rev = s > 0 ? close >= L + revDist : close <= L - revDist
                if not brk and (s > 0 ? low < zB : high > zT)
                    z.swept := true
                if brk
                    int d = -s
                    if d > 0
                        z.brkUp := z.brkUp + 1
                        evBrkUp := true
                    else
                        z.brkDn := z.brkDn + 1
                        evBrkDn := true
                    sb.tierBrk.set(ti, sb.tierBrk.get(ti) + 1)
                    z.decideSum := z.decideSum + (bar_index - z.startBar)
                    z.lastType  := 2
                    z.lastDir   := d
                    z.lastTime  := time_close
                    z.state     := 0
                    z.startWatch(2, d, bar_index + watchBars, atrV)
                    z.wMax := d > 0 ? high - L : L - low
                    alertMsg := alertMsg + "BREAKOUT " + (d > 0 ? "▲ " : "▼ ") + lvlS + ". "
                else if rev
                    if s > 0
                        z.revSup := z.revSup + 1
                        evRevUp  := true
                    else
                        z.revRes := z.revRes + 1
                        evRevDn  := true
                    if z.swept
                        z.sweepRev := z.sweepRev + 1
                    if z.lastType == 2 and z.lastDir == s
                        z.flips := z.flips + 1
                    sb.tierRev.set(ti, sb.tierRev.get(ti) + 1)
                    z.decideSum := z.decideSum + (bar_index - z.startBar)
                    z.lastType  := 1
                    z.lastDir   := s
                    z.lastTime  := time_close
                    z.state     := 0
                    z.startWatch(1, s, bar_index + watchBars, atrV)
                    z.wMax := s > 0 ? high - L : L - low
                    alertMsg := alertMsg + "REVERSAL " + (s > 0 ? "▲ " : "▼ ") + lvlS + ". "
                else if bar_index - z.startBar >= maxTestBars
                    z.stalls   := z.stalls + 1
                    z.lastType := 3
                    z.lastDir  := 0
                    z.lastTime := time_close
                    z.state    := 0

            if z.state == 1 or z.wType != 0
                nxt.push(k)
        sb.active.clear()
        for ka in nxt
            sb.active.push(ka)
    if evRevUp
        cRU += 1
    if evRevDn
        cRD += 1
    if evBrkUp
        cBU += 1
    if evBrkDn
        cBD += 1
    if evFake
        cF += 1
    if evHiProb
        cH += 1
    if alertMsg != ""
        lastMsg := alertMsg
        seq += 1
    // Hand the (large) book to the chart only near the live edge; counters every bar.
    Book out = na
    if barstate.islast or timenow - time <= 3 * timeframe.in_seconds(calcTF) * 1000
        out := sb
    [out, cRU, cRD, cBU, cBD, cF, cH, lastMsg, seq]

// ─────────────────────────────── STATS REQUEST (LOCKED) ────────────────────
int calcBarsReq = int(math.min(statsDays * 86400 / math.max(timeframe.in_seconds(calcTF), 1) + 500, 100000))
[bRet, nRU, nRD, nBU, nBD, nF, nH, aMsg, aSeq] = request.security(syminfo.tickerid, calcTF, f_engine(), calc_bars_count = calcBarsReq)

var Book bk = na
if not na(bRet)
    bk := bRet

bool evRevUp  = nz(nRU) > nz(nRU[1])
bool evRevDn  = nz(nRD) > nz(nRD[1])
bool evBrkUp  = nz(nBU) > nz(nBU[1])
bool evBrkDn  = nz(nBD) > nz(nBD[1])
bool evFake   = nz(nF)  > nz(nF[1])
bool evHiProb = nz(nH)  > nz(nH[1])

// One alert per new stats-TF event, on any chart timeframe (varip survives realtime ticks).
varip int alertedSeq = 0
if barstate.ishistory
    alertedSeq := nz(aSeq)
else if nz(aSeq) > alertedSeq
    alert("BTC Psych Zones [" + f_tfLabel(calcTF) + " stats]: " + aMsg, alert.freq_all)
    alertedSeq := nz(aSeq)

// ─────────────────────────────── ZONES ─────────────────────────────────────
// Rendering follows the Strong Contrarian Zones lifecycle (one object per level, genesis when the
// level enters the display window, extended every bar, deleted when it leaves), with one change
// for the published-script preview: x-coordinates are TIME values and the left edge is anchored to
// the leftmost VISIBLE bar (chart.left_visible_bar_time), so every zone starts on a bar that is
// loaded wherever the script runs. Right edge = the current bar's time. No extend.*, no future time.
type pzone
    int   k        = 0
    int   tier     = 2
    float level    = na
    float top      = na
    float bot      = na
    float mid      = na
    int   bornTime = na
    box   bxOut    = na
    box   bxMid    = na
    box   bxCore   = na
    line  ln       = na
    label tag      = na
    bool  dead     = false

var map<int, pzone> zones = map.new<int, pzone>()
int nb   = bar_index
int tfMs = timeframe.in_seconds() * 1000

method killZone(pzone self) =>
    box.delete(self.bxOut)
    box.delete(self.bxMid)
    box.delete(self.bxCore)
    line.delete(self.ln)
    label.delete(self.tag)
    self.dead := true

// Left edge = later of (birth bar, anchor); anchor = leftmost visible bar or a fixed count back.
f_leftEdge(int bornT) =>
    int anchor = anchorMode == "Visible Chart Edge" ? chart.left_visible_bar_time : time - zoneHist * tfMs
    math.min(math.max(bornT, anchor), time)

method refreshGeo(pzone self) =>
    int left = f_leftEdge(self.bornTime)
    box.set_left(self.bxOut, left)
    box.set_left(self.bxMid, left)
    box.set_left(self.bxCore, left)
    line.set_x1(self.ln, left)
    box.set_right(self.bxOut, time)
    box.set_right(self.bxMid, time)
    box.set_right(self.bxCore, time)
    line.set_x2(self.ln, time)

method recolor(pzone self, color tone, float sc, bool faint, bool live) =>
    int sInt  = int(math.round(sc))
    int opOut = gradFill ? math.max(fillTransp - 2, 62) : fillTransp
    int opMid = gradFill ? math.max(fillTransp - 12 - sInt, 50) : fillTransp
    int opCor = gradFill ? math.max(fillTransp - 24 - sInt * 2, 36) : fillTransp
    box.set_bgcolor(self.bxOut,  color.new(tone, faint ? math.min(opOut + 8, 96) : opOut))
    box.set_bgcolor(self.bxMid,  gradFill and not faint ? color.new(tone, opMid) : color(na))
    box.set_bgcolor(self.bxCore, gradFill and not faint ? color.new(tone, opCor) : color(na))
    box.set_border_color(self.bxOut, live ? color.new(tone, 0) : showBord ? color.new(tone, bordTransp) : color(na))
    box.set_border_style(self.bxOut, live ? line.style_dashed : line.style_solid)
    line.set_color(self.ln, self.tier == 0 ? color.new(majCol, 15) : color.new(tone, self.tier == 1 ? 25 : 45))
    line.set_width(self.ln, self.tier == 0 ? 2 : 1)
    line.set_style(self.ln, self.tier == 0 ? line.style_solid : self.tier == 1 ? line.style_dashed : line.style_dotted)

method refreshTag(pzone self, string txt, color txtColor) =>
    if showZoneLab
        if na(self.tag)
            self.tag := label.new(nb + labGap, self.mid, txt, style = label.style_label_left, color = labBgCol, textcolor = txtColor, size = f_size(labSizeS))
        else
            label.set_text(self.tag, txt)
            label.set_xy(self.tag, nb + labGap, self.mid)
        label.set_style(self.tag, label.style_label_left)
        label.set_color(self.tag, labBgCol)
        label.set_textcolor(self.tag, txtColor)
        label.set_size(self.tag, f_size(labSizeS))
    else if not na(self.tag)
        label.set_text(self.tag, "")
        label.set_color(self.tag, color(na))

// ── window of levels around price ──
int kBase = int(math.floor(close / gridStep))
int kFrom = kBase - levelsDn + 1
int kTo   = kBase + levelsUp

// ── retire levels that left the window ──
array<int> liveKeys = zones.keys()
for kk in liveKeys
    if kk < kFrom or kk > kTo
        zones.get(kk).killZone()
        zones.remove(kk)

// ── genesis: a level entered the window ──
for k = kFrom to kTo
    if not zones.contains(k)
        float L   = k * gridStep
        float top = L + halfW
        float bot = L - halfW
        int   t0  = f_leftEdge(time - tfMs)
        pzone z   = pzone.new()
        z.k        := k
        z.tier     := f_tierIdx(k)
        z.level    := L
        z.top      := top
        z.bot      := bot
        z.mid      := L
        z.bornTime := time - tfMs
        z.bxOut    := box.new(t0, top, time, bot, xloc = xloc.bar_time, border_width = 1)
        z.bxMid    := box.new(t0, L + halfW * 0.5, time, L - halfW * 0.5, xloc = xloc.bar_time, border_color = color(na), border_width = 0)
        z.bxCore   := box.new(t0, L + halfW * 0.22, time, L - halfW * 0.22, xloc = xloc.bar_time, border_color = color(na), border_width = 0)
        z.ln       := line.new(t0, L, time, L, xloc = xloc.bar_time, width = 1)
        z.recolor(neuCol, 0.0, true, false)
        z.refreshTag(" " + str.tostring(L, "#,###") + "  ·  Untested ", NEU_TXT)
        zones.put(k, z)

// ── lifecycle: extend every live zone to the current bar, recolor, relabel ──
for kk in zones.keys()
    pzone z = zones.get(kk)
    z.refreshGeo()
    if not na(bk)
        Lvl s = bk.lv.get(kk)
        [bc, tag, sc, bias] = f_bias(s)
        int  nTests = 0
        bool live   = false
        if not na(s)
            nTests := s.tests
            live   := s.state == 1
        z.recolor(bc, sc, nTests == 0, live)
        z.refreshTag(" " + f_zoneText(s, z.level, tag) + " ", bias == 0 ? NEU_TXT : bc)
    else if not na(z.tag)
        label.set_xy(z.tag, nb + labGap, z.mid)

// ─────────────────────────────── DASHBOARDS ────────────────────────────────
// Two panels. Upper: the 4 levels ABOVE price (highest → nearest). Lower: the 4 levels BELOW price
// (nearest → lowest). Layout per panel: [metric names] | sep | level | sep | level | sep | level | sep | level.
// Invisible spacer cells (fixed width / height, no colour) separate every column and section.
const int DCOLS = 9
const int DROWS = 32

f_posUp() => dashSide == "Left" ? position.top_left : position.top_right
f_posDn() => dashLowPos == "Middle" ? (dashSide == "Left" ? position.middle_left : position.middle_right) : (dashSide == "Left" ? position.bottom_left : position.bottom_right)

var table dashUp = table.new(f_posUp(), DCOLS, DROWS, bgcolor = color(na), frame_width = 0, border_width = 0)
var table dashDn = table.new(f_posDn(), DCOLS, DROWS, bgcolor = color(na), frame_width = 0, border_width = 0)

// Fixed column widths (identical in both panels): names | spacer | level | spacer | level ...
f_colW(int c) => c == 0 ? dashNameW : c % 2 == 0 ? dashLevelW : 0.4

// Rows removed for a compact panel: Tier (1), Reversal 95% Range (7), Stalled (12).
f_hiddenRow(int i) => i == 1 or i == 7 or i == 12

// Render one panel: `ks` are the level indices, left → right.
f_panel(table t, string title, array<int> ks, array<string> names, array<int> rowOf, int nRows, string tsz, string foot, color footCol) =>
    table.clear(t, 0, 0, DCOLS - 1, DROWS - 1)
    // 1) spacer grid
    for c = 0 to DCOLS - 1
        for r = 0 to nRows - 1
            table.cell(t, c, r, "", width = f_colW(c), height = 0.6, bgcolor = color(na))
    // 2) metric names
    for i = 0 to 27
        int r = rowOf.get(i)
        if r >= 0 and names.get(i) != ""
            bool head = i == 0
            table.cell(t, 0, r, head ? title : names.get(i), width = dashNameW, bgcolor = color.new(DASH_BG, 10), text_color = head ? majCol : DASH_NAME, text_size = tsz, text_halign = text.align_left, text_font_family = font.family_monospace)
    // 3) level columns
    int col = 2
    for k in ks
        Lvl   z = bk.lv.get(k)
        float L = k * gridStep
        [bc, tag, sc, bias] = f_bias(z)
        array<string> v = f_vals(z, k, L, tag, sc, bk.tierRev, bk.tierBrk)
        for i = 0 to 27
            int r = rowOf.get(i)
            if r >= 0 and names.get(i) != ""
                int tr = i == 0 ? 70 : i <= 3 ? 80 : 90
                table.cell(t, col, r, v.get(i), width = dashLevelW, bgcolor = color.new(bc, tr), text_color = txtCol, text_size = tsz, text_font_family = font.family_monospace)
        col += 2
    // 4) optional footer spanning the panel
    if foot != ""
        table.cell(t, 0, nRows, "", width = dashNameW, height = 0.6, bgcolor = color(na))
        table.cell(t, 0, nRows + 1, foot, bgcolor = color.new(DASH_BG, 10), text_color = footCol, text_size = tsz, text_halign = text.align_left, text_font_family = font.family_monospace)
        table.merge_cells(t, 0, nRows + 1, DCOLS - 1, nRows + 1)
    true

if barstate.islast and showDash and na(bk)
    table.clear(dashUp, 0, 0, DCOLS - 1, DROWS - 1)
    table.clear(dashDn, 0, 0, DCOLS - 1, DROWS - 1)
    table.cell(dashUp, 0, 0, "Loading " + f_tfLabel(calcTF) + " stats…", bgcolor = color.new(DASH_BG, 10), text_color = DASH_NAME, text_size = f_size(dashSizeS))

if barstate.islast and showDash and not na(bk)
    string tsz = f_size(dashSizeS)
    array<string> names = array.from("Level", "Tier", "Zone Type", "Strength", "", "Reversal Probability", "Breakout Probability", "Reversal 95% Range", "", "Tests", "Reversals", "Breakouts", "Stalled", "", "Held as Support", "Held as Resistance", "Next Test", "", "Fakeouts", "Sweep Reversals", "Support / Resistance Flips", "Average Reaction", "Breakout Follow-Through", "Time to Resolve", "", "Edge vs Tier Average", "Last Event", "Distance from Price")

    // Row map (hidden rows dropped, non-core rows dropped in Core mode, never two separators in a row)
    bool       fullD   = dashRows == "Full"
    array<int> rowOf   = array.new_int(28, -1)
    int        nRows   = 0
    bool       lastSep = true
    for i = 0 to 27
        bool isSep = names.get(i) == ""
        if (fullD or f_isCore(i)) and not f_hiddenRow(i)
            if isSep
                if not lastSep
                    rowOf.set(i, nRows)
                    nRows   += 1
                    lastSep := true
            else
                rowOf.set(i, nRows)
                nRows   += 1
                lastSep := false

    // Level sets: 4 above (highest → nearest), 4 below (nearest → lowest)
    int kA1 = int(math.floor(close / gridStep)) + 1
    int kB1 = kA1 - 1
    array<int> ksUp = array.from(kA1 + 3, kA1 + 2, kA1 + 1, kA1)
    array<int> ksDn = array.from(kB1, kB1 - 1, kB1 - 2, kB1 - 3)

    // Footer: lock status + coverage check (lower panel only)
    int    cutC    = f_cutoff()
    bool   partial = bk.nBars == 0 or bk.firstTime > cutC + 2 * timeframe.in_seconds(calcTF) * 1000
    string foot    = "STATS LOCKED · " + f_tfLabel(calcTF) + " bars · " + str.tostring(statsDays) + "-day window · " + str.tostring(bk.nBars, "#,###") + " bars · since " + str.format_time(bk.firstTime, "dd MMM yyyy HH:mm", "UTC") + " UTC"
    if partial
        foot := "⚠ PARTIAL WINDOW · " + f_tfLabel(calcTF) + " history starts " + str.format_time(bk.firstTime, "dd MMM yyyy", "UTC") + " (asked " + str.tostring(statsDays) + " days) · lower the window for a full lock"

    f_panel(dashUp, "▲ ABOVE PRICE  " + str.tostring(close, "#,###"), ksUp, names, rowOf, nRows, tsz, "", majCol)
    f_panel(dashDn, "▼ BELOW PRICE  " + str.tostring(close, "#,###"), ksDn, names, rowOf, nRows, tsz, foot, partial ? brkCol : majCol)

// ─────────────────────────────── MARKERS & ALERTS ──────────────────────────
plotshape(showEvents and evRevUp, "Support Reversal", shape.triangleup, location.belowbar, revCol, size = size.tiny, text = "R", textcolor = revCol)
plotshape(showEvents and evRevDn, "Resistance Reversal", shape.triangledown, location.abovebar, revCol, size = size.tiny, text = "R", textcolor = revCol)
plotshape(showEvents and evBrkUp, "Breakout Up", shape.diamond, location.belowbar, brkCol, size = size.tiny, text = "B", textcolor = brkCol)
plotshape(showEvents and evBrkDn, "Breakout Down", shape.diamond, location.abovebar, brkCol, size = size.tiny, text = "B", textcolor = brkCol)
plotshape(showEvents and evFake, "Fakeout", shape.xcross, location.abovebar, neuCol, size = size.tiny, text = "F", textcolor = neuCol)

alertcondition(evRevUp or evRevDn, "Zone Reversal Confirmed", "BTC Psych Zones: reversal confirmed at a psychological level")
alertcondition(evBrkUp, "Zone Breakout Up", "BTC Psych Zones: breakout UP through a psychological level")
alertcondition(evBrkDn, "Zone Breakout Down", "BTC Psych Zones: breakout DOWN through a psychological level")
alertcondition(evFake, "Fakeout Detected", "BTC Psych Zones: breakout failed back through the zone")
alertcondition(evHiProb, "High-Probability Zone Test", "BTC Psych Zones: test started at a zone with a high historical hold rate")
````
