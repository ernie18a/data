<!-- tradingview-pine-id: PUB;a2fb90f96c6243cfb9b4076ccfa9ab3d -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# $$$ GAP DIGGA $$$ ver1.0

Source: https://www.tradingview.com/script/dJfrwY2W-GAP-DIGGA/

## Description

$$$ GAP DIGGA $$$ v1.0

A fair value gap indicator that tells you which gaps have actually worked on your chart — and which ones you should stop waiting for.

Every FVG tool draws every gap the same way. A gap that fills and disappears looks exactly like a gap that holds and starts a move. You find out which one you had after it is over. GAP DIGGA keeps track. It watches every gap it draws, remembers what happened to it, and uses that memory to rate the next one. No opinions, no hand-picked weights, just what your chart has done.

What it does

For every gap, it asks two questions and answers them with numbers from your chart's own history:

Will it fill? How often gaps like this one got filled within a set number of bars.

Will it hold? How often a trade taken from gaps like this one worked: a limit order halfway into the gap, a stop just past the move that created it, and a target at one, two or three times the risk. You see all three, and the label tells you which target has paid best from gaps like this.

"Gaps like this one" means two things: how big the gap is, and how it was made. That second one matters more than you would think, and we will get to it.

Reading the label

Hold 48% · Fill 85% · best 1R

Gaps like this one held 48% of the time, filled 85% of the time, and the target that paid best from them was 1R. A "?" at the end means there are not many similar gaps yet, so take it lightly. The box itself is shaded by the Hold number — solid when gaps like it have held well, faint when they have not — so you can see the best gap on the chart without reading anything. When the chart has almost no history, the label says "warming up" in grey. It will not guess.

Math made easy

Statistics are only useful if you can read them at a glance, so the panel speaks in four symbols and nothing else:

▲ or ▼ — this kind of gap does clearly better, or clearly worse, than the average gap on this chart.
▲▲ or ▼▼ — much better, or much worse.
nothing — it is the average with a different name. Ignore the row.
? — fewer than 50 gaps behind this number. Wait for more before you believe it.

Every number is a plain percentage of what happened. No decimals, no counts, no ranges. If you want those, there is a Detailed view in the settings, explained at the end.

Reading the stats panel

One table, read top to bottom.

The title says the symbol, the timeframe and how many gaps it has counted so far.

Four columns: Fill, Hold 1R, Hold 2R, Hold 3R. Fill is "did price come back and cover the gap". The three Hold columns are the same trade with three different targets — one, two and three times the risk.

All gaps is the plain average. Everything below it is compared to this row.

Small, Medium, Large gaps split them by height relative to recent volatility.

Opening gaps, Mixed, Candle gaps split them by how they were made. An opening gap appeared between two candles — overnight, over the weekend — with no candle actually making the move. A candle gap was made by one candle's move, the whole gap sits inside it. Mixed is in between. This is the row that changes everything on higher timeframes.

Best target (all gaps) says which target has paid best for the average gap — every gap on the chart, the bad ones included — and whether it made money, broke even or lost.

Does the score work? is the one line that tells you how much to believe the rest. Every gap is scored the moment it appears, from gaps that had already played out; when it plays out too, the tool compares what it said with what happened. "Yes" means the scores have been right. "No" means they are just the average — trade that instead and ignore the shading. "Overconfident" means the scores have promised more than they delivered.

The ranking panel, a second toggle, lists the open gaps from best to worst, with how far each is from the current price. For when there are six boxes on the chart and you want to know which one to wait for.

What it found, and where it helps

We ran it on gold, GBPNZD, AUDUSD and NAS100 before publishing. The same picture came back everywhere, and it changes how you should use gaps.

On lower timeframes (5m to 1h), gaps are all the same. Big or small, in trend or against it, roughly half of them hold and the rest do not. On gold 15m, 3,200 gaps: 85% filled, 48% held at 1R, and no type of gap did better than any other. The tool's own skill check reads zero. This is the honest answer most FVG tools will not give you: intraday, there is no such thing as a "high quality" gap. Use GAP DIGGA here as a filter for your expectations, not as a signal — if you trade intraday gaps, know that the gap itself is a coin flip and your edge has to come from somewhere else.

On higher timeframes (4h, daily), it gets interesting. Most daily gaps are not made by a candle at all. They are made overnight or over the weekend — price simply opens somewhere else. On daily gold, that is 73% of all gaps. Those opening gaps fill 82% of the time and hold only 22%. They are targets, not support. The gaps that a real candle made — the ones where the middle bar covers the whole gap — hold 48% at 1R and 27% at 3R, more than double. GAP DIGGA tells the two apart with a "made by" tag, and on daily gold its skill check reads +7%, with its predictions landing within a point of what happened across 5,000 gaps.

So: on the daily, use it to know which gaps to expect price to run through and which ones might actually hold. On the 15m, use it to stop hoping.

How to use it

1. Add it to any chart. It works on any symbol.
2. Scroll left once so the chart loads its history. The more history, the better the numbers.
3. Read the box shading for a quick look, the label for the numbers.
4. Turn on the stats panel once per chart and look at the skill number at the bottom. That tells you how much to believe the rest.
5. Set the two alerts if you like: a new gap with a good score, and price touching one.

A few honest notes

The numbers come from your chart's loaded history, so a chart with a year of data gives a better picture than one with a month. Gaps that happen close together are not really separate events, so the ranges shown are a little narrower than the truth. The trade math ignores spread and commission. And a score is what has happened, not what will — a gap that held 48% of the time in the past is a gap with no edge, and the tool will tell you exactly that.

For the detailed view

Switch the panel to Detailed in the settings and the same table shows its working. Each cell becomes "22% ×0.77 n=3728": the percentage, how many times the average it is, and how many gaps it came from. The All gaps row adds a range, "48% [47-50]": the true number is somewhere in there, and the range narrows as the count grows. A Calibration block replaces the one-line verdict: gaps grouped by the score they were given, with the average score ("pred") next to what actually happened ("obs"), and a skill number at the bottom — above zero the scores help, around zero they are the average, below zero raise k in the settings. The label gains the trade's expected result per unit of risk and the smallest count behind it.

Important

This tool is a technical assistant, not a financial advisor. It is designed for traders who understand technical analysis. A score is a measured frequency in past data, not a forecast. Comprehensive market knowledge and independent validation are required before making any trading decision. PINE DIGGA Indicators shall not be held liable for any trading losses or financial damages.

© PINEDIGGA - 2026

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PINEDIGGA

//@version=6
//@$$$ GAP DIGGA $$$ (September 2026 - ver1.0)
// Scores every fair-value gap from the chart's own outcome history.
//   • Fill  — did price cover the gap within H bars?
//   • Hold  — did a limit at the gap's midpoint reach R× risk before the stop past the origin?
//             Tracked at three R levels at once, so the best target shows with its expectancy.
//   • Each gap is described by its size and by how it was made — inside the middle bar or
//     between sessions (three buckets each). The score is naive Bayes in log-odds over the
//     per-bucket outcome rates, after Bayesian shrinkage towards the chart's base rate. Base
//     rates carry a Wilson interval; every label carries the smallest sample size behind it.
//   • It grades itself: every gap's score at birth uses only gaps resolved before it, so the
//     (score, outcome) pairs are out-of-sample. The panel shows them binned, with a Brier
//     skill score against the base rate. Nothing here is a hand weight.
//   • Reference implementation and tests: scripts/gap_digga_ref.py in the PINE DIGGA repo.
indicator("$$$ GAP DIGGA $$$ ver1.0", overlay = true, max_boxes_count = 500, max_labels_count = 500)

// ══════════════════════════════════════════════════════════════════════
// 📐 GAP
// ══════════════════════════════════════════════════════════════════════
grpGap     = "📐 Gap"
atrLen     = input.int(14, "ATR length", minval = 1, group = grpGap, display = display.none)
minSize    = input.float(0.10, "Min gap size (ATR)", minval = 0, step = 0.05, group = grpGap,
     tooltip = "Gaps smaller than this many ATR are ignored.", display = display.none)
sizeLo     = input.float(0.35, "Size S/M", minval = 0, step = 0.05, group = grpGap, inline = "sz", display = display.none)
sizeHi     = input.float(0.75, "M/L", minval = 0, step = 0.05, group = grpGap, inline = "sz",
     tooltip = "Gap height in ATR: below S/M is Small, at or above M/L is Large.", display = display.none)
madeLo     = input.float(0.5, "Made-by: session below (coverage)", minval = 0, maxval = 1, step = 0.05, group = grpGap,
     tooltip = "Share of the gap inside the middle bar's range. Below this it is a session gap (made between bars); 100% is a bar gap (made inside the bar); in between, mixed.", display = display.none)

// ══════════════════════════════════════════════════════════════════════
// 🎯 OUTCOMES
// ══════════════════════════════════════════════════════════════════════
grpOut  = "🎯 Outcomes"
horizon = input.int(96, "Fill horizon H (bars)", minval = 5, maxval = 2000, group = grpOut,
     tooltip = "A gap not filled within H bars of birth counts as unfilled. A trade still open at H is not counted.", display = display.none)
stopAt  = input.string("origin", "Stop at", options = ["origin", "far edge"], group = grpOut,
     tooltip = "Hold: entry at the gap's 50%, stop past the origin (the extreme of the pattern's first bar) or at the gap's far edge. Risk = entry − stop.", display = display.none)
r1      = input.float(1.0, "R₁", minval = 0.1, step = 0.5, group = grpOut, inline = "r", display = display.none)
r2      = input.float(2.0, "R₂", minval = 0.1, step = 0.5, group = grpOut, inline = "r", display = display.none)
r3      = input.float(3.0, "R₃", minval = 0.1, step = 0.5, group = grpOut, inline = "r",
     tooltip = "Target = entry + R × risk. Three levels are tracked at once.", display = display.none)

// ══════════════════════════════════════════════════════════════════════
// 📊 STATISTICS
// ══════════════════════════════════════════════════════════════════════
grpStat = "📊 Statistics"
kShrink = input.float(10, "Shrinkage k (pseudo-samples)", minval = 0, step = 1, group = grpStat,
     tooltip = "Each bucket rate is pulled towards the base rate by k pseudo-samples (Beta prior).", display = display.none)
warmMin = input.int(8, "Warm-up: min samples per bucket", minval = 1, group = grpStat,
     tooltip = "Below this in any of the gap's buckets the label shows the base rate, grey.", display = display.none)
zStr    = input.string("1.96 (95%)", "Wilson z", options = ["1.64 (90%)", "1.96 (95%)", "2.58 (99%)"], group = grpStat, display = display.none)
zVal    = zStr == "1.64 (90%)" ? 1.64 : zStr == "2.58 (99%)" ? 2.58 : 1.96

// ══════════════════════════════════════════════════════════════════════
// 🎨 DISPLAY
// ══════════════════════════════════════════════════════════════════════
grpDisp      = "🎨 Display"
showLabels   = input.bool(true, "Score labels", group = grpDisp, inline = "lb", display = display.none)
fontStr      = input.string("small", "", options = ["tiny", "small", "normal"], group = grpDisp, inline = "lb", display = display.none)
bullCol      = input.color(#26a69a, "Bull", group = grpDisp, inline = "col", display = display.none)
bearCol      = input.color(#ef5350, "Bear", group = grpDisp, inline = "col", display = display.none)
maxOpen      = input.int(60, "Max open gaps", minval = 1, maxval = 500, group = grpDisp, display = display.none)
keepResolved = input.bool(false, "Keep filled boxes (last 200)", group = grpDisp, display = display.none)
showStats    = input.bool(false, "Stats panel", group = grpDisp, inline = "st", display = display.none)
statsPos     = input.string("top_right", "", options = ["top_left", "top_right", "bottom_left", "bottom_right"], group = grpDisp, inline = "st", display = display.none)
panelMode    = input.string("Simple", "", options = ["Simple", "Detailed"], group = grpDisp, inline = "st",
     tooltip = "Simple: percentages with ▲ ▼ for clearly better / worse than average and ? for thin data. Detailed: counts, ranges, lifts and the calibration bins.", display = display.none)
showRank     = input.bool(false, "Ranking panel", group = grpDisp, inline = "rk", display = display.none)
rankPos      = input.string("bottom_right", "", options = ["top_left", "top_right", "bottom_left", "bottom_right"], group = grpDisp, inline = "rk", display = display.none)
alertThr     = input.float(60, "Alert when Hold₁ ≥ (%)", minval = 0, maxval = 100, group = grpDisp, display = display.none)

fontSize = fontStr == "tiny" ? size.tiny : fontStr == "normal" ? size.normal : size.small
f_pos(string s) => s == "top_left" ? position.top_left : s == "top_right" ? position.top_right : s == "bottom_left" ? position.bottom_left : position.bottom_right

// ══════════════════════════════════════════════════════════════════════
// DETECTION — pure, no state
// ══════════════════════════════════════════════════════════════════════
atr = ta.atr(atrLen)

// 0 = S, 1 = M, 2 = L
f_bucket3(float x, float lo, float hi) => x < lo ? 0 : x < hi ? 1 : 2
// 0 = session (the gap sits mostly between bars), 1 = mixed, 2 = bar (the middle bar covers all of it)
f_madeBy(float top, float bot) => f_bucket3(math.max(0.0, math.min(high[1], top) - math.max(low[1], bot)) / (top - bot), madeLo, 1.0)

// ══════════════════════════════════════════════════════════════════════
// REGISTRY — the open gaps and their state machine
// ══════════════════════════════════════════════════════════════════════
type Gap
    int   dir
    float top
    float bottom
    float stop
    int   birth
    int   b1        // size bucket
    int   b2        // made-by bucket
    bool  touched  = false
    bool  entered  = false
    int   entryBar = -1
    bool  fillDone = false
    bool  filled   = false
    bool  holdDone = false
    bool  hit1     = false
    bool  hit2     = false
    bool  hit3     = false
    bool  stopped  = false
    int   touchAge = -1
    float scoreFill = na     // scores at birth, from history resolved before this gap
    float scoreHold = na
    float baseFill  = na
    float baseHold  = na
    box   bx       = na
    label lb       = na

var gaps = array.new<Gap>()

// counters: index = outcome*7 + cell; outcome 0 Fill, 1 Hold₁, 2 Hold₂, 3 Hold₃;
// cell 0 base, 1-3 size S/M/L, 4-6 made-by session/mixed/bar
O_FILL = 0
O_H1   = 1
O_H2   = 2
O_H3   = 3
var nArr = array.new_int(28, 0)
var sArr = array.new_int(28, 0)

f_bumpCell(int idx, bool success) =>
    array.set(nArr, idx, array.get(nArr, idx) + 1)
    if success
        array.set(sArr, idx, array.get(sArr, idx) + 1)

// one outcome for one gap lands in three cells: base, size, made-by
f_count(int o, Gap g, bool success) =>
    f_bumpCell(o * 7, success)
    f_bumpCell(o * 7 + 1 + g.b1, success)
    f_bumpCell(o * 7 + 4 + g.b2, success)

// walk-forward calibration: slot 0 Fill, slot 1 Hold₁; five bins of 20 %; index = slot*5 + bin
CAL_FILL = 0
CAL_HOLD = 1
var calN    = array.new_int(10, 0)
var calS    = array.new_int(10, 0)
var calSum  = array.new_float(10, 0.0)
var brierS  = array.new_float(2, 0.0)   // Σ (score − y)²
var brierB  = array.new_float(2, 0.0)   // Σ (base − y)²
var brierN  = array.new_int(2, 0)

f_calibrate(int slot, float score, float base, bool y) =>
    if not na(score)
        b   = slot * 5 + math.min(4, math.floor(score * 5))
        yv  = y ? 1.0 : 0.0
        array.set(calN, b, array.get(calN, b) + 1)
        if y
            array.set(calS, b, array.get(calS, b) + 1)
        array.set(calSum, b, array.get(calSum, b) + score)
        array.set(brierS, slot, array.get(brierS, slot) + math.pow(score - yv, 2))
        array.set(brierB, slot, array.get(brierB, slot) + math.pow(base - yv, 2))
        array.set(brierN, slot, array.get(brierN, slot) + 1)

f_mid(Gap g)  => (g.top + g.bottom) / 2
f_risk(Gap g) => math.abs(f_mid(g) - g.stop)
// price came back to `level` (towards the gap)
f_reach(Gap g, float level)  => g.dir == 1 ? low <= level : high >= level
// price went away from the gap past `level`
f_beyond(Gap g, float level) => g.dir == 1 ? high >= level : low <= level

// Run the current bar through one gap. True when Fill and Hold are both decided.
f_advance(Gap g) =>
    age  = bar_index - g.birth
    near = g.dir == 1 ? g.top : g.bottom
    far  = g.dir == 1 ? g.bottom : g.top
    mid  = f_mid(g)
    risk = f_risk(g)
    if not g.touched and f_reach(g, near)
        g.touched  := true
        g.touchAge := age
    if not g.entered and f_reach(g, mid)
        g.entered  := true
        g.entryBar := bar_index
    if g.entered and not g.holdDone
        if f_reach(g, g.stop)
            // stop: every level not yet reached is a failure (same bar as a target → stop)
            if not g.hit1
                f_count(O_H1, g, false)
                f_calibrate(CAL_HOLD, g.scoreHold, g.baseHold, false)
            if not g.hit2
                f_count(O_H2, g, false)
            if not g.hit3
                f_count(O_H3, g, false)
            g.stopped  := true
            g.holdDone := true
        else if bar_index > g.entryBar
            // targets are only checked from the bar after the entry
            if not g.hit1 and f_beyond(g, mid + g.dir * r1 * risk)
                g.hit1 := true
                f_count(O_H1, g, true)
                f_calibrate(CAL_HOLD, g.scoreHold, g.baseHold, true)
            if not g.hit2 and f_beyond(g, mid + g.dir * r2 * risk)
                g.hit2 := true
                f_count(O_H2, g, true)
            if not g.hit3 and f_beyond(g, mid + g.dir * r3 * risk)
                g.hit3 := true
                f_count(O_H3, g, true)
            if g.hit1 and g.hit2 and g.hit3
                g.holdDone := true
    if not g.fillDone and f_reach(g, far)
        g.filled   := true
        g.fillDone := true
        f_count(O_FILL, g, true)
        f_calibrate(CAL_FILL, g.scoreFill, g.baseFill, true)
    if age >= horizon
        if not g.fillDone
            g.fillDone := true
            f_count(O_FILL, g, false)
            f_calibrate(CAL_FILL, g.scoreFill, g.baseFill, false)
        g.holdDone := true      // an open trade at expiry is not counted either way
    g.fillDone and g.holdDone

// ══════════════════════════════════════════════════════════════════════
// STATISTICS — pure functions over the counters
// ══════════════════════════════════════════════════════════════════════
f_p0(int o) =>
    n = array.get(nArr, o * 7)
    n == 0 ? na : array.get(sArr, o * 7) / float(n)     // int / int is integer division in Pine

// posterior mean under a Beta(k·p0, k·(1−p0)) prior
f_shrunk(int idx, float p0) => (array.get(sArr, idx) + kShrink * p0) / (array.get(nArr, idx) + kShrink)

f_logit(float p) =>
    pc = math.max(0.001, math.min(0.999, p))
    math.log(pc / (1 - pc))

// naive Bayes in log-odds: base logit plus each feature's deviation from it
f_score(int o, Gap g) =>
    p0 = f_p0(o)
    float out = na
    if not na(p0)
        l0 = f_logit(p0)
        l  = l0
        l += f_logit(f_shrunk(o * 7 + 1 + g.b1, p0)) - l0
        l += f_logit(f_shrunk(o * 7 + 4 + g.b2, p0)) - l0
        out := 1 / (1 + math.exp(-l))
    out

// the smaller sample size of the gap's two buckets
f_nmin(int o, Gap g) => math.min(array.get(nArr, o * 7 + 1 + g.b1), array.get(nArr, o * 7 + 4 + g.b2))

// Wilson score interval; n = 0 → [0, 1]
f_wilson(int s, int n) =>
    float lo = 0.0
    float hi = 1.0
    if n > 0
        p  = s / float(n)
        z2 = zVal * zVal
        denom  = 1 + z2 / n
        centre = (p + z2 / (2 * n)) / denom
        half   = zVal * math.sqrt(p * (1 - p) / n + z2 / (4 * n * n)) / denom
        lo := centre - half
        hi := centre + half
    [lo, hi]

// expectancy in R and the best of the three levels
f_expect(float p, float r) => p * r - (1 - p)
f_best(Gap g) =>
    p1 = f_score(O_H1, g)
    p2 = f_score(O_H2, g)
    p3 = f_score(O_H3, g)
    e1 = f_expect(p1, r1)
    e2 = f_expect(p2, r2)
    e3 = f_expect(p3, r3)
    float bestE = e1
    float bestR = r1
    if e2 > bestE
        bestE := e2
        bestR := r2
    if e3 > bestE
        bestE := e3
        bestR := r3
    [p1, bestR, bestE]

// ══════════════════════════════════════════════════════════════════════
// PER-BAR: advance the open gaps, then look for a new one
// ══════════════════════════════════════════════════════════════════════
var keptBoxes = array.new<box>()
var float newGapScore = na     // Hold₁ score of a gap born this bar, for the alert
var float touchScore  = na     // best Hold₁ score of a gap first touched this bar

// the box leaves the chart when the gap fills; the gap itself stays until Hold is decided
f_retire(Gap g) =>
    label.delete(g.lb)
    g.lb := na
    if not na(g.bx)
        if keepResolved
            box.set_extend(g.bx, extend.none)
            box.set_right(g.bx, bar_index)
            array.push(keptBoxes, g.bx)
            if array.size(keptBoxes) > 200
                box.delete(array.shift(keptBoxes))
        else
            box.delete(g.bx)
        g.bx := na

if barstate.isconfirmed
    newGapScore := na
    touchScore  := na
    i = 0
    while i < array.size(gaps)
        g = array.get(gaps, i)
        wasTouched = g.touched
        done = f_advance(g)
        if not wasTouched and g.touched
            sc = f_score(O_H1, g)
            touchScore := na(touchScore) ? sc : math.max(touchScore, sc)
        if g.fillDone
            f_retire(g)
        if done
            array.remove(gaps, i)
        else
            i += 1

    bull = low > high[2]
    bear = high < low[2]
    if (bull or bear) and not na(atr) and array.size(gaps) < maxOpen
        top = bull ? low : low[2]
        bot = bull ? high[2] : high
        h   = top - bot
        if h >= minSize * atr
            dir    = bull ? 1 : -1
            origin = bull ? low[2] : high[2]
            stopPx = stopAt == "origin" ? origin : (bull ? bot : top)
            g = Gap.new(dir, top, bot, stopPx, bar_index, f_bucket3(h / atr, sizeLo, sizeHi), f_madeBy(top, bot))
            // scored before it is added: only gaps resolved so far can inform it
            g.baseFill  := f_p0(O_FILL)
            g.scoreFill := f_score(O_FILL, g)
            g.baseHold  := f_p0(O_H1)
            g.scoreHold := f_score(O_H1, g)
            g.bx := box.new(bar_index - 2, top, bar_index, bot, border_color = color.new(dir == 1 ? bullCol : bearCol, 60), bgcolor = color.new(dir == 1 ? bullCol : bearCol, 90), extend = extend.right)
            if showLabels
                g.lb := label.new(bar_index, f_mid(g), "", style = label.style_label_left, textcolor = color.gray, color = color.new(color.black, 100), size = fontSize)
            array.push(gaps, g)
            newGapScore := g.scoreHold

// ══════════════════════════════════════════════════════════════════════
// DRAWING — labels and box shading on the last bar, the two panels, alerts
// ══════════════════════════════════════════════════════════════════════
f_pct(float p) => str.tostring(p * 100, "#") + "%"
f_signed(float e) => (e >= 0 ? "+" : "") + str.tostring(e, "0.00")
f_signed0(float e) => (e >= 0 ? "+" : "") + str.tostring(e, "#")

// Brier skill = 1 − Σ(score−y)² / Σ(base−y)²; "—" until a scored gap has resolved
f_skill(int slot) =>
    bb = array.get(brierB, slot)
    array.get(brierN, slot) == 0 or bb == 0 ? "—" : f_signed(100 * (1 - array.get(brierS, slot) / bb)) + "% (n=" + str.tostring(array.get(brierN, slot)) + ")"

// ── math made easy: the simple view's four symbols ──────────────────────
THIN = 50   // fewer gaps than this behind a number → "?"

// ▲▲ / ▲ clearly better than average, ▼ / ▼▼ clearly worse, nothing = the average
f_arrows(float lift) => lift >= 1.5 ? "▲▲" : lift >= 1.15 ? "▲" : lift <= 0.67 ? "▼▼" : lift <= 0.85 ? "▼" : ""

// one word for the skill number
f_verdict(int slot) =>
    bb = array.get(brierB, slot)
    if array.get(brierN, slot) == 0 or bb == 0
        "not yet"
    else
        sk = math.round(100 * (1 - array.get(brierS, slot) / bb))   // judged on the number shown
        (sk >= 5 ? "yes" : sk >= 2 ? "a little" : sk >= -2 ? "no" : "overconfident") + " (" + f_signed0(sk) + "%)"

// box transparency bound to Hold₁
f_transp(float h1, bool warm) => warm or na(h1) or h1 < 0.5 ? 90 : h1 < 0.6 ? 75 : 60

if barstate.islast
    for g in gaps
        if na(g.bx)
            continue
        [p1, bestR, bestE] = f_best(g)
        pf   = f_score(O_FILL, g)
        nmin = f_nmin(O_H1, g)
        warm = na(p1) or nmin < warmMin
        col  = g.dir == 1 ? bullCol : bearCol
        box.set_bgcolor(g.bx, color.new(col, f_transp(p1, warm)))
        if showLabels and not na(g.lb)
            label.set_x(g.lb, bar_index)
            label.set_y(g.lb, f_mid(g))
            if warm
                p0 = f_p0(O_H1)
                label.set_text(g.lb, (na(p0) ? "no history yet" : "p₀ " + f_pct(p0)) + " · warming up (n≥" + str.tostring(nmin) + ")")
                label.set_textcolor(g.lb, color.gray)
            else
                simpleTxt   = "Hold " + f_pct(p1) + " · Fill " + f_pct(pf) + " · best " + str.tostring(bestR, "#.#") + "R" + (nmin < THIN ? " ?" : "")
                detailedTxt = "H " + f_pct(p1) + " · F " + f_pct(pf) + " · " + str.tostring(bestR, "#.#") + "R " + f_signed(bestE) + " · n≥" + str.tostring(nmin)
                label.set_text(g.lb, panelMode == "Simple" ? simpleTxt : detailedTxt)
                label.set_textcolor(g.lb, col)

// ── stats panel ────────────────────────────────────────────────────────
var table st = na
if showStats and barstate.islast and panelMode == "Simple"
    if na(st)
        st := table.new(f_pos(statsPos), 5, 11, bgcolor = color.new(color.black, 20), border_width = 1, border_color = color.new(color.white, 85))
    txt  = color.white
    dim  = color.new(color.white, 40)
    hdr  = color.new(color.white, 0)
    table.cell(st, 0, 0, "GAP DIGGA · " + syminfo.ticker + " " + timeframe.period + " · " + str.tostring(array.get(nArr, O_FILL * 7), "#,##0") + " gaps", text_color = hdr, text_size = fontSize, text_halign = text.align_left)
    table.merge_cells(st, 0, 0, 4, 0)
    names = array.from("", "Fill", "Hold " + str.tostring(r1, "#.#") + "R", "Hold " + str.tostring(r2, "#.#") + "R", "Hold " + str.tostring(r3, "#.#") + "R")
    for c = 0 to 4
        table.cell(st, c, 1, array.get(names, c), text_color = dim, text_size = fontSize)
    rowNames = array.from("All gaps", "Small gaps", "Medium gaps", "Large gaps", "Opening gaps", "Mixed", "Candle gaps")
    for ci = 0 to 6
        table.cell(st, 0, ci + 2, array.get(rowNames, ci), text_color = txt, text_size = fontSize, text_halign = text.align_left)
        for o = 0 to 3
            p0 = f_p0(o)
            n  = array.get(nArr, o * 7 + ci)
            string cellTxt = "—"
            color  cellCol = txt
            if not na(p0)
                if ci == 0
                    cellTxt := f_pct(p0)
                else if n == 0
                    cellTxt := "—"     // no gaps of this kind on the chart
                else
                    ps   = f_shrunk(o * 7 + ci, p0)
                    lift = p0 > 0 ? ps / p0 : 1.0
                    arr  = f_arrows(lift)
                    cellTxt := f_pct(ps) + (arr == "" ? "" : " " + arr) + (n < THIN ? " ?" : "")
                    cellCol := lift >= 1.15 ? bullCol : lift <= 0.85 ? bearCol : txt
            table.cell(st, o + 1, ci + 2, cellTxt, text_color = cellCol, text_size = fontSize)
    // best target for the average gap, in words
    float bestE = na
    float bestR = na
    for o = 1 to 3
        p0 = f_p0(o)
        if not na(p0)
            r = o == 1 ? r1 : o == 2 ? r2 : r3
            e = f_expect(p0, r)
            if na(bestE) or e > bestE
                bestE := e
                bestR := r
    verdictE = na(bestE) ? "not yet" : str.tostring(bestR, "#.#") + "R · " + (math.abs(bestE) < 0.05 ? "about break-even" : bestE > 0 ? "pays " + f_signed(bestE) + "R per trade" : "loses " + str.tostring(-bestE, "0.00") + "R per trade")
    table.cell(st, 0, 9, "Best target (all gaps)", text_color = hdr, text_size = fontSize, text_halign = text.align_left)
    table.cell(st, 1, 9, verdictE, text_color = hdr, text_size = fontSize, text_halign = text.align_left)
    table.merge_cells(st, 1, 9, 4, 9)
    table.cell(st, 0, 10, "Does the score work?", text_color = hdr, text_size = fontSize, text_halign = text.align_left)
    table.cell(st, 1, 10, "Fill: " + f_verdict(CAL_FILL), text_color = hdr, text_size = fontSize, text_halign = text.align_left)
    table.cell(st, 2, 10, "Hold: " + f_verdict(CAL_HOLD), text_color = hdr, text_size = fontSize, text_halign = text.align_left)
    table.merge_cells(st, 2, 10, 4, 10)
else if showStats and barstate.islast
    if na(st)
        st := table.new(f_pos(statsPos), 5, 17, bgcolor = color.new(color.black, 20), border_width = 1, border_color = color.new(color.white, 85))
    txt  = color.white
    dim  = color.new(color.white, 40)
    hdr  = color.new(color.white, 0)
    nTot = array.get(nArr, O_FILL * 7)
    table.cell(st, 0, 0, "GAP DIGGA · " + syminfo.ticker + " " + timeframe.period + " · " + str.tostring(nTot) + " gaps · H = " + str.tostring(horizon) + " · stop " + stopAt + " · k = " + str.tostring(kShrink, "#"), text_color = hdr, text_size = fontSize, text_halign = text.align_left)
    table.merge_cells(st, 0, 0, 4, 0)
    names = array.from("", "Fill", "Hold " + str.tostring(r1, "#.#") + "R", "Hold " + str.tostring(r2, "#.#") + "R", "Hold " + str.tostring(r3, "#.#") + "R")
    for c = 0 to 4
        table.cell(st, c, 1, array.get(names, c), text_color = dim, text_size = fontSize)
    table.cell(st, 0, 2, "Base", text_color = txt, text_size = fontSize, text_halign = text.align_left)
    for o = 0 to 3
        n = array.get(nArr, o * 7)
        s = array.get(sArr, o * 7)
        [lo, hi] = f_wilson(s, n)
        table.cell(st, o + 1, 2, n == 0 ? "—" : f_pct(s / float(n)) + " [" + str.tostring(lo * 100, "#") + "-" + str.tostring(hi * 100, "#") + "]  n=" + str.tostring(n), text_color = txt, text_size = fontSize)
    rowNames = array.from("Size S", "Size M", "Size L", "Made session", "Made mixed", "Made bar")
    for ci = 1 to 6
        table.cell(st, 0, ci + 2, array.get(rowNames, ci - 1), text_color = txt, text_size = fontSize, text_halign = text.align_left)
        for o = 0 to 3
            p0 = f_p0(o)
            string cellTxt = "—"
            color  cellCol = txt
            if not na(p0)
                ps   = f_shrunk(o * 7 + ci, p0)
                lift = p0 > 0 ? ps / p0 : 1.0
                cellTxt := f_pct(ps) + "  ×" + str.tostring(lift, "0.00") + "  n=" + str.tostring(array.get(nArr, o * 7 + ci))
                cellCol := lift >= 1.15 ? bullCol : lift <= 0.85 ? bearCol : txt
            table.cell(st, o + 1, ci + 2, cellTxt, text_color = cellCol, text_size = fontSize)
    // best R on the base rates
    float bestE = na
    float bestR = na
    for o = 1 to 3
        p0 = f_p0(o)
        if not na(p0)
            r = o == 1 ? r1 : o == 2 ? r2 : r3
            e = f_expect(p0, r)
            if na(bestE) or e > bestE
                bestE := e
                bestR := r
    table.cell(st, 0, 9, na(bestE) ? "Best R: —" : "Best R: " + str.tostring(bestR, "#.#") + "R · E = " + f_signed(bestE) + " R", text_color = hdr, text_size = fontSize, text_halign = text.align_left)
    table.merge_cells(st, 0, 9, 4, 9)
    // ── walk-forward calibration: what the scores said at birth vs what happened
    table.cell(st, 0, 10, "Calibration (walk-forward)", text_color = dim, text_size = fontSize, text_halign = text.align_left)
    table.cell(st, 1, 10, "Fill", text_color = dim, text_size = fontSize)
    table.cell(st, 2, 10, "Hold " + str.tostring(r1, "#.#") + "R", text_color = dim, text_size = fontSize)
    table.merge_cells(st, 2, 10, 4, 10)
    // bins are written in sequence so empty ones leave no blank row
    table.clear(st, 0, 11, 4, 15)
    row = 11
    for b = 0 to 4
        nF = array.get(calN, CAL_FILL * 5 + b)
        nH = array.get(calN, CAL_HOLD * 5 + b)
        if nF + nH > 0
            table.cell(st, 0, row, "scored " + str.tostring(b * 20) + "–" + str.tostring(b * 20 + 20) + "%", text_color = txt, text_size = fontSize, text_halign = text.align_left)
            table.cell(st, 1, row, nF == 0 ? "—" : "pred " + str.tostring(100 * array.get(calSum, CAL_FILL * 5 + b) / nF, "#") + " · obs " + str.tostring(100 * array.get(calS, CAL_FILL * 5 + b) / float(nF), "#") + " (n=" + str.tostring(nF) + ")", text_color = txt, text_size = fontSize)
            table.cell(st, 2, row, nH == 0 ? "—" : "pred " + str.tostring(100 * array.get(calSum, CAL_HOLD * 5 + b) / nH, "#") + " · obs " + str.tostring(100 * array.get(calS, CAL_HOLD * 5 + b) / float(nH), "#") + " (n=" + str.tostring(nH) + ")", text_color = txt, text_size = fontSize)
            table.merge_cells(st, 2, row, 4, row)
            row += 1
    table.cell(st, 0, 16, "Brier skill vs base", text_color = hdr, text_size = fontSize, text_halign = text.align_left)
    table.cell(st, 1, 16, f_skill(CAL_FILL), text_color = hdr, text_size = fontSize)
    table.cell(st, 2, 16, f_skill(CAL_HOLD), text_color = hdr, text_size = fontSize)
    table.merge_cells(st, 2, 16, 4, 16)
else if not showStats and not na(st)
    table.delete(st)
    st := na

// ── ranking panel ──────────────────────────────────────────────────────
var table rk = na
if showRank and barstate.islast
    if na(rk)
        rk := table.new(f_pos(rankPos), 7, 11, bgcolor = color.new(color.black, 20), border_width = 1, border_color = color.new(color.white, 85))
    table.clear(rk, 0, 0, 6, 10)
    dim = color.new(color.white, 40)
    heads = array.from("#", "Dir", "Top / Bottom", "Dist", "H" + str.tostring(r1, "#.#") + "R", "F", "E best")
    for c = 0 to 6
        table.cell(rk, c, 0, array.get(heads, c), text_color = dim, text_size = fontSize)
    // only gaps still on the chart (unfilled) are ranked
    es   = array.new_float()
    idxs = array.new_int()
    j = 0
    for g in gaps
        if not na(g.bx)
            [p1, bestR, bestE] = f_best(g)
            array.push(es, na(bestE) ? -9 : bestE)
            array.push(idxs, j)
        j += 1
    ordr  = array.sort_indices(es, order.descending)
    rows  = math.min(10, array.size(ordr))
    if rows > 0
        for r = 0 to rows - 1
            g = array.get(gaps, array.get(idxs, array.get(ordr, r)))
            [p1, bestR, bestE] = f_best(g)
            pf   = f_score(O_FILL, g)
            near = g.dir == 1 ? g.top : g.bottom
            dist = (near - close) / close * 100
            col  = g.dir == 1 ? bullCol : bearCol
            table.cell(rk, 0, r + 1, str.tostring(r + 1), text_color = color.white, text_size = fontSize)
            table.cell(rk, 1, r + 1, g.dir == 1 ? "▲" : "▼", text_color = col, text_size = fontSize)
            table.cell(rk, 2, r + 1, str.tostring(g.top, format.mintick) + " / " + str.tostring(g.bottom, format.mintick), text_color = color.white, text_size = fontSize)
            table.cell(rk, 3, r + 1, f_signed(dist) + "%", text_color = color.white, text_size = fontSize)
            table.cell(rk, 4, r + 1, na(p1) ? "—" : f_pct(p1), text_color = col, text_size = fontSize)
            table.cell(rk, 5, r + 1, na(pf) ? "—" : f_pct(pf), text_color = color.white, text_size = fontSize)
            table.cell(rk, 6, r + 1, na(bestE) ? "—" : f_signed(bestE) + " (" + str.tostring(bestR, "#.#") + "R)", text_color = col, text_size = fontSize)
else if not showRank and not na(rk)
    table.delete(rk)
    rk := na

// ── alerts ─────────────────────────────────────────────────────────────
if barstate.isconfirmed
    if not na(newGapScore) and newGapScore * 100 >= alertThr
        alert("GAP DIGGA: new gap on " + syminfo.ticker + " " + timeframe.period + " with Hold " + f_pct(newGapScore), alert.freq_once_per_bar)
    if not na(touchScore) and touchScore * 100 >= alertThr
        alert("GAP DIGGA: price touched a gap on " + syminfo.ticker + " " + timeframe.period + " with Hold " + f_pct(touchScore), alert.freq_once_per_bar)
````
