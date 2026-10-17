# Markov Level Validity Engine [PhenLabs]

- url: https://www.tradingview.com/script/TVMPhUNg-Markov-Level-Validity-Engine-PhenLabs/
- type: indicator
- pine_id: PUB;f0b54fc84aab4e208b91eb95b789c37b
- version: 1.0

## Description

📊 Markov Level Validity Engine [PhenLabs]

Version: PineScript™ v6

📌 Description
Every support and resistance tool draws levels. Few tell you whether a level is still worth trusting the next time price comes back to it. The Markov Level Validity Engine answers that question with your chart’s own history. Each time price tests a swing level, the test is resolved as a HOLD (price reacts away), a BREAK (price closes through) or a STALL (nothing decisive happens). The engine records every outcome and learns how levels on this symbol and timeframe usually behave.

The key insight is that a level’s next test depends on what happened at its last test. A fresh level, a level that just held, and a broken level that flipped roles (support turned resistance) behave differently. So does a level approached slowly versus one hit with speed. MLVE keeps a separate tally for each of these situations. When a new test starts, it reads the matching tally and shows you the empirical chance of a hold, a break or a stall, together with the sample size behind it.

Signals fire only when the reaction you actually see on the candle agrees with what the history says is likely, and only when that history beats the chart’s own average. The result is a level tool that tells you when to fade, when to trade the break, and when to skip. No manual anchors, no setup, works on every plan.

🚀 Points of Innovation
[list]
[*]Level tests are modelled as a Markov chain: the next outcome is conditioned on the level’s previous outcome, stored in a Pine matrix of transition counts.
[*]Approach speed is a second conditioning dimension, so a fast push into a level is never pooled with a slow drift into it.
[*]Probabilities come from the current chart only, with Laplace smoothing and a visible sample size. No fixed scores, no curve-fit weights.
[*]Signals require two agreements: the candle’s reaction (rejection close or break close) and a historical probability that clears both your threshold and the chart-wide base rate.
[*]Role reversal is first-class: a broken level flips side and its next test is read from the dedicated “after break” rows.
[*]Theme-adaptive dashboard that reads cleanly on dark and light charts, laid out to stay legible if you move it into the new bottom panel.
[/list]

🔧 Core Components
[list]
[*]Level Registry: confirmed swing highs and lows become resistance and support, capped per side so the chart stays clean. The oldest level on a side is retired when a new one forms, and levels retire after six resolved tests.
[*]Test Lifecycle: a test starts when price approaches a level from its origin side and touches it. It resolves as BREAK (close beyond the level plus a buffer), HOLD (move away of at least the reaction size in ATR) or STALL (the test window runs out).
[*]Transition Matrix: a 6 × 3 matrix counts outcomes for every combination of previous outcome (first test / after hold / after break) and approach speed (slow / fast).
[*]Signal Gate: compares the live reaction with the matching row’s probability, the minimum probability, the minimum sample size and the chart’s base rate.
[*]Plan Projection: the target is the nearest active opposing level. Invalidation sits one break buffer beyond the signal level.
[/list]

🔥 Key Features
[list]
[*]HOLD and BREAK signals in both directions, each firing at most once per test.
[*]Per-level tags at the right edge showing side, hold probability for its next test and sample size, for example “S · H 64% · n 37”.
[*]Ray opacity scales with hold probability, so the strongest levels stand out at a glance.
[*]LEARNING state until a row has enough samples. The script tells you when it does not know yet instead of guessing.
[*]Optional fragile-test markers when a test starts on a level whose history favours a break.
[*]Signal Types selector: Hold + Break, Hold only, or Break only.
[*]Three alert conditions (bull, bear, any) and three Pine Screener columns.
[/list]

🎨 Visualization
[list]
[*]Level rays: short dashed rays from the pivot to a few bars past price. Teal for support, coral for resistance. They turn solid after a role reversal, and stronger levels are more opaque.
[*]Right-edge tags: side, hold probability for the next test and sample count.
[*]Signal labels: placed off the candle (below for bullish, above for bearish) reading HOLD or BREAK with the probability. Hover for level, target and invalidation.
[*]Plan lines: one dotted target line and one dashed invalidation line for the latest signal, 15 bars long.
[*]Dashboard: nearest support and resistance with their prior outcome, Hold / Break / Stall percentages with n, a verdict (VALID, FRAGILE, UNDECIDED or LEARNING), last signal with target and invalidation, total tests with base hold rate, and the data mode.
[/list]

📖 Usage Guidelines
Levels
[list]
[*][b]Pivot Length[/b] — Default: 5 — Range: 2-30 — Bars on each side that confirm a swing. Higher values give fewer, more significant levels that appear later.
[*][b]Levels per Side[/b] — Default: 3 — Range: 1-5 — Live levels kept for support and for resistance.
[/list]
Test Model
[list]
[*][b]Test Window (bars)[/b] — Default: 12 — Range: 3-100 — Bars a test has to resolve before it counts as a STALL.
[*][b]Hold Reaction (ATR)[/b] — Default: 1.0 — Range: 0.2-5.0 — Move away from the level needed to count a HOLD. Raise it for stricter holds.
[*][b]Break Buffer (ATR)[/b] — Default: 0.25 — Range: 0.05-2.0 — How far beyond the level a candle must close to count a BREAK. Also sets the invalidation distance.
[*][b]Min Probability[/b] — Default: 0.55 — Range: 0.34-0.95 — Minimum historical probability for a signal. The row must also beat the chart’s base rate.
[*][b]Min Samples per Row[/b] — Default: 20 — Range: 5-500 — Resolved tests a row needs before it can signal.
[/list]
Signals
[list]
[*][b]Signal Types[/b] — Default: Hold + Break — Choose fades, breakouts or both.
[*][b]Show Target / Invalidation[/b] — Default: on — Draws the latest signal’s plan.
[*][b]Show Fragile-Test Markers[/b] — Default: off — Small x when a test begins on a level that historically tends to break.
[/list]
Display
[list]
[*][b]Show Dashboard[/b] — Default: on.
[*][b]Table Size[/b] — Default: Normal — Small, Normal or Large. Only shown when the dashboard is on.
[*][b]Bull / Support and Bear / Resistance colors[/b] — Default: teal and coral.
[/list]

✅ Best Use Cases
[list]
[*]Deciding whether to fade a test of a support or resistance level or wait for the break.
[*]Trading role reversals: broken levels retested from the other side, read from their own history.
[*]Skipping trades at levels whose history is undecided or still learning.
[*]Screening a watchlist for symbols sitting on a level with a high hold probability.
[*]Works on crypto, forex, indices, futures and stocks, on any timeframe with enough history.
[/list]

⚠️ Limitations
[list]
[*]Swing levels are confirmed Pivot Length bars after the swing, which is the price of not repainting.
[*]Probabilities describe what has happened on the loaded history of this chart. They are not guarantees, and they change as new tests resolve.
[*]A row needs Min Samples resolved tests before it can signal, so short histories and very high timeframes stay in LEARNING longer.
[*]A BREAK signal says a break was the historically likely outcome. It does not measure how far the break will travel. Use the target and invalidation for that.
[*]Gaps and very low-liquidity symbols produce fewer clean tests.
[/list]

💡 What Makes This Unique
[list]
[*]Measured, not scored: the dashboard shows empirical frequencies and their sample size instead of a hand-weighted 0-100 rating.
[*]Memory per level: each level carries its last outcome, so a retest after a break is read differently from a first test.
[*]Honest uncertainty: LEARNING, UNDECIDED and n are always visible.
[/list]

⚙️ Under the Hood
[list]
[*][b]Matrix transition counts[/b]: a persistent 6 × 3 Pine matrix stores HOLD, BREAK and STALL counts for each previous-outcome × approach-speed state. Reading a row gives a conditional probability no static level grade can provide.
[*][b]Laplace-smoothed probabilities[/b]: P = (count + 1) / (row total + 3), so small rows are pulled toward one-third instead of jumping to 0% or 100%.
[*][b]Out-of-sample by construction[/b]: a test’s probability is read before that test is counted, and all state changes run on confirmed bars only. No lookahead, no request.* calls, no repainting.
[*][b]User-defined level type[/b]: each level stores price, side, previous outcome, test count, pending-test state and its drawing handles, so rays and tags update in place and are deleted with the level.
[*][b]Theme-adaptive colors[/b]: dashboard text and frames use chart.fg_color and chart.bg_color, so the table reads correctly on dark and light themes.
[*][b]Data mode / plan note[/b]: OHLC only. Every TradingView plan, including free, gets the full engine. The dashboard’s Data row shows “OHLC · ALL PLANS · closed bars”.
[*][b]Screener & alerts[/b]: Pine Screener columns “Support P(hold) %”, “Resistance P(hold) %” and “Signal code” (+2 bull break, +1 bull hold, -1 bear hold, -2 bear break, 0 none). Alert conditions: MLVE Bull signal, MLVE Bear signal, MLVE Any signal.
[/list]

🔬 How It Works
[list]
[*]Levels: confirmed pivot highs become resistance and pivot lows become support, up to the per-side cap.
[*]Test start: when price approaches a level from its origin side and touches it, a test begins. The engine records which row it belongs to: previous outcome × slow or fast approach (5-bar move of at least 1 ATR toward the level).
[*]Read the model: the row’s HOLD, BREAK and STALL probabilities come from previously resolved tests only.
[*]Signal: a HOLD signal fires on a rejection close when P(hold) clears Min Probability and the base hold rate. A BREAK signal fires on a close beyond the buffer when P(break) clears Min Probability and the base break rate. Opposite signals on the same bar cancel each other.
[*]Resolve: the test is counted as BREAK, HOLD or STALL, in that priority. A break flips the level’s role, and its next test is read from the after-break rows.
[*]Plan: the latest signal projects a target at the nearest opposing level and an invalidation one buffer beyond the signal level.
[/list]

[quote]💡 Note:
Load as much history as your plan allows and wait for the Model row to show a healthy test count before relying on signals. The verdict row is the quickest read: VALID means the level’s next test historically holds more often than your threshold, FRAGILE means it tends to break, and UNDECIDED or LEARNING means stand aside. Pair signals with your own risk management and market context. This tool is an analytical aid, not financial advice.[/quote]

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PhenLabs
//@version=6
indicator("Markov Level Validity Engine [PhenLabs]", "MLVE", overlay = true, max_lines_count = 60, max_labels_count = 80)

// ─────────────────────────────────────────────────────────────────────────────
// Concept
// Pivot support/resistance levels. Every test of a level resolves into
// HOLD, BREAK or STALL. A matrix<int> counts those outcomes by the level's
// previous outcome (first test / after a hold / after a break = role reversal)
// and the approach speed (slow / fast). On a new test, the empirical
// probability of the matching row gates HOLD and BREAK signals.
// All state changes happen on confirmed bars only; no request.* calls.
// ─────────────────────────────────────────────────────────────────────────────

enum SigMode
    both = "Hold + Break"
    hold = "Hold only"
    brk  = "Break only"

enum TSize
    small  = "Small"
    normal = "Normal"
    large  = "Large"

const string GL = "Levels"
const string GM = "Test Model"
const string GS = "Signals"
const string GD = "Display"

int     pivLen     = input.int(5, "Pivot Length", minval = 2, maxval = 30, group = GL, tooltip = "Bars on each side that confirm a swing high/low. Levels appear this many bars after the swing (no repainting).")
int     maxPerSide = input.int(3, "Levels per Side", minval = 1, maxval = 5, group = GL, tooltip = "Maximum live support and resistance levels. The oldest level on a side is retired when a new one forms.")
int     win        = input.int(12, "Test Window (bars)", minval = 3, maxval = 100, group = GM, tooltip = "Bars a test has to resolve. If neither HOLD nor BREAK happens in time the test is a STALL.")
float   rejK       = input.float(1.0, "Hold Reaction (ATR)", minval = 0.2, maxval = 5.0, step = 0.1, group = GM, tooltip = "How far price must travel away from the level (in ATR) for the test to count as a HOLD.")
float   brkBuf     = input.float(0.25, "Break Buffer (ATR)", minval = 0.05, maxval = 2.0, step = 0.05, group = GM, tooltip = "How far beyond the level a candle must CLOSE (in ATR) for the test to count as a BREAK.")
float   pMin       = input.float(0.55, "Min Probability", minval = 0.34, maxval = 0.95, step = 0.01, group = GM, tooltip = "A signal fires only when the matching history row shows at least this probability for the outcome AND beats the chart-wide base rate for that outcome.")
int     nMin       = input.int(20, "Min Samples per Row", minval = 5, maxval = 500, group = GM, tooltip = "A row needs this many resolved tests before it can produce signals. Until then the dashboard shows LEARNING.")
SigMode sigMode    = input.enum(SigMode.both, "Signal Types", group = GS)
bool    showPlan   = input.bool(true, "Show Target / Invalidation", group = GS, tooltip = "Draws the latest signal's target (next opposing level, dotted) and invalidation (dashed).")
bool    showFrag   = input.bool(false, "Show Fragile-Test Markers", group = GS, tooltip = "Small x when a test starts on a level whose history favours a BREAK.")
bool    showDash   = input.bool(true, "Show Dashboard", group = GD)
TSize   tblSize    = input.enum(TSize.normal, "Table Size", group = GD, active = showDash)
color   bullCol    = input.color(#22D3B6, "Bull / Support", group = GD)
color   bearCol    = input.color(#FF5C8A, "Bear / Resistance", group = GD)

// ── Constants ────────────────────────────────────────────────────────────────
const int   MAX_TESTS = 6       // a level is retired after this many resolved tests
const float TOUCH_K   = 0.15    // ATR tolerance for a touch
const float CLOSE_K   = 0.10    // ATR distance for a rejection close
const float FAST_K    = 1.0     // ATR travelled over 5 bars toward the level = fast approach
const int   RAY_EXT   = 8       // bars a level ray extends past the current bar
const int   PLAN_LEN  = 15      // bars the plan lines extend
const int   MAX_SIGLB = 40      // signal labels kept on the chart

// ── Types and state ──────────────────────────────────────────────────────────
type Lvl
    float price
    int   dir            // +1 resistance (price below), -1 support (price above)
    int   prev  = 0      // 0 first test, 1 after HOLD, 2 after BREAK (role reversal)
    int   tests = 0
    int   t0    = na     // bar index of the pending test, na when idle
    int   row   = 0
    bool  holdFired = false
    bool  brkFired  = false
    int   created
    line  ray
    label tag

// rows: prev * 2 + fast (0..5); cols: 0 HOLD, 1 BREAK, 2 STALL
var matrix<int> trans  = matrix.new<int>(6, 3, 0)
var array<Lvl>  lvls   = array.new<Lvl>()
var array<label> sigLbs = array.new<label>()
var line  tgtLn   = na
var line  invLn   = na
var int   lastSig = 0
var float lastPr  = na
var float lastTgt = na
var float lastInv = na
var string lastTxt = "none yet"

// ── Pure helpers ─────────────────────────────────────────────────────────────
f_n(matrix<int> m, int r) =>
    m.get(r, 0) + m.get(r, 1) + m.get(r, 2)

f_p(matrix<int> m, int r, int c) =>
    (m.get(r, c) + 1.0) / (f_n(m, r) + 3.0)

// pooled over approach speed, used for the "next test" read on idle levels
f_nPrior(matrix<int> m, int p) =>
    f_n(m, p * 2) + f_n(m, p * 2 + 1)

f_pPrior(matrix<int> m, int p, int c) =>
    (m.get(p * 2, c) + m.get(p * 2 + 1, c) + 1.0) / (f_nPrior(m, p) + 3.0)

f_prevTxt(int p) =>
    p == 0 ? "first test" : p == 1 ? "after HOLD" : "after BREAK"

f_pct(float x) =>
    na(x) ? "–" : str.tostring(math.round(x * 100)) + "%"

f_verdict(matrix<int> m, int p) =>
    int   n  = f_nPrior(m, p)
    float pH = f_pPrior(m, p, 0)
    float pB = f_pPrior(m, p, 1)
    n < nMin ? "LEARNING" : pH >= pMin ? "VALID" : pB >= pMin ? "FRAGILE" : "UNDECIDED"

// ── Series inputs (computed on every bar for consistency) ───────────────────
float atr   = ta.atr(14)
float ph    = ta.pivothigh(pivLen, pivLen)
float pl    = ta.pivotlow(pivLen, pivLen)
float mvUp  = close[1] - close[6]
bool  ready = barstate.isconfirmed and not na(atr) and not na(mvUp)

bool  bullSig  = false
bool  bearSig  = false
int   sigCode  = 0
bool  fragSup  = false
bool  fragRes  = false

// per-bar candidates
float bullP = -1.0
float bullL = na
bool  bullIsBrk = false
float bearP = -1.0
float bearL = na
bool  bearIsBrk = false

if ready
    float tol = TOUCH_K * atr
    float buf = brkBuf * atr
    // chart-wide base rates: a row must beat its own chart's average to signal
    int   nAll  = 0
    int   hAll  = 0
    int   bAll  = 0
    for r = 0 to 5
        nAll += f_n(trans, r)
        hAll += trans.get(r, 0)
        bAll += trans.get(r, 1)
    float baseH = (hAll + 1.0) / (nAll + 3.0)
    float baseB = (bAll + 1.0) / (nAll + 3.0)

    // 1) new levels from confirmed pivots
    if not na(ph)
        lvls.push(Lvl.new(price = ph, dir = 1, created = bar_index, ray = line.new(bar_index - pivLen, ph, bar_index + RAY_EXT, ph, color = color.new(bearCol, 60), style = line.style_dashed, width = 1), tag = label.new(bar_index + RAY_EXT, ph, "", style = label.style_label_left, color = color.new(color.black, 100), textcolor = bearCol, size = size.tiny)))
    if not na(pl)
        lvls.push(Lvl.new(price = pl, dir = -1, created = bar_index, ray = line.new(bar_index - pivLen, pl, bar_index + RAY_EXT, pl, color = color.new(bullCol, 60), style = line.style_dashed, width = 1), tag = label.new(bar_index + RAY_EXT, pl, "", style = label.style_label_left, color = color.new(color.black, 100), textcolor = bullCol, size = size.tiny)))

    // 2) tests, signals, resolution
    if lvls.size() > 0
        for i = 0 to lvls.size() - 1
            Lvl lv = lvls.get(i)
            if lv.created < bar_index
                bool isRes = lv.dir == 1
                // a0) idle level already closed through without a qualifying test:
                //     flip its role (support <-> resistance) without counting an outcome
                bool silentFlip = na(lv.t0) and (isRes ? close > lv.price + buf and close[1] > lv.price : close < lv.price - buf and close[1] < lv.price)
                if silentFlip
                    lv.dir  := -lv.dir
                    lv.prev := 2
                    line.set_style(lv.ray, line.style_solid)
                    label.set_textcolor(lv.tag, lv.dir == 1 ? bearCol : bullCol)
                // a) test start: approach from the origin side and touch
                if na(lv.t0) and not silentFlip
                    bool touch = isRes ? close[1] < lv.price and high >= lv.price - tol : close[1] > lv.price and low <= lv.price + tol
                    if touch
                        bool fast = isRes ? mvUp >= FAST_K * atr : -mvUp >= FAST_K * atr
                        lv.t0        := bar_index
                        lv.row       := lv.prev * 2 + (fast ? 1 : 0)
                        lv.holdFired := false
                        lv.brkFired  := false
                        if f_n(trans, lv.row) >= nMin and f_p(trans, lv.row, 1) >= pMin
                            if isRes
                                fragRes := true
                            else
                                fragSup := true
                // b) signals from the model BEFORE this test is counted
                if not na(lv.t0)
                    int   r      = lv.row
                    bool  enough = f_n(trans, r) >= nMin
                    float pH     = f_p(trans, r, 0)
                    float pB     = f_p(trans, r, 1)
                    bool  holdBar = isRes ? high >= lv.price - tol and close <= lv.price - CLOSE_K * atr : low <= lv.price + tol and close >= lv.price + CLOSE_K * atr
                    bool  brkBar  = isRes ? close > lv.price + buf : close < lv.price - buf
                    if sigMode != SigMode.brk and holdBar and not lv.holdFired and enough and pH >= pMin and pH >= baseH
                        lv.holdFired := true
                        if isRes and pH > bearP
                            bearP     := pH
                            bearL     := lv.price
                            bearIsBrk := false
                        if not isRes and pH > bullP
                            bullP     := pH
                            bullL     := lv.price
                            bullIsBrk := false
                    if sigMode != SigMode.hold and brkBar and not lv.brkFired and enough and pB >= pMin and pB >= baseB
                        lv.brkFired := true
                        if isRes and pB > bullP
                            bullP     := pB
                            bullL     := lv.price
                            bullIsBrk := true
                        if not isRes and pB > bearP
                            bearP     := pB
                            bearL     := lv.price
                            bearIsBrk := true
                    // c) resolution: BREAK (close) > HOLD (excursion) > STALL (time)
                    bool holdNow  = isRes ? lv.price - low >= rejK * atr : high - lv.price >= rejK * atr
                    bool stallNow = bar_index - lv.t0 >= win
                    int  outc     = brkBar ? 1 : holdNow ? 0 : stallNow ? 2 : -1
                    if outc >= 0
                        trans.set(r, outc, trans.get(r, outc) + 1)
                        lv.tests += 1
                        lv.t0    := na
                        if outc == 0
                            lv.prev := 1
                        if outc == 1
                            lv.prev := 2
                            lv.dir  := -lv.dir
                            line.set_style(lv.ray, line.style_solid)
                            label.set_textcolor(lv.tag, lv.dir == 1 ? bearCol : bullCol)
            // d) keep the ray and tag current
            color sideCol = lv.dir == 1 ? bearCol : bullCol
            int   nP      = f_nPrior(trans, lv.prev)
            float pHP     = f_pPrior(trans, lv.prev, 0)
            float shade   = nP < nMin ? 0.0 : math.max(0.0, math.min(1.0, (pHP - 0.35) / 0.35))
            line.set_x2(lv.ray, bar_index + RAY_EXT)
            line.set_color(lv.ray, color.new(sideCol, 75 - 50 * shade))
            label.set_xy(lv.tag, bar_index + RAY_EXT, lv.price)
            label.set_text(lv.tag, (lv.dir == 1 ? "R" : "S") + " · H " + (nP < nMin ? "–" : f_pct(pHP)) + " · n " + str.tostring(nP))

    // 3) retire worn-out levels, then enforce the per-side cap (oldest first)
    int k = lvls.size() - 1
    while k >= 0
        Lvl lv = lvls.get(k)
        if lv.tests >= MAX_TESTS
            line.delete(lv.ray)
            label.delete(lv.tag)
            lvls.remove(k)
        k -= 1
    for side = -1 to 1 by 2
        int cnt = 0
        if lvls.size() > 0
            for lv in lvls
                if lv.dir == side
                    cnt += 1
        while cnt > maxPerSide
            int oldIdx = -1
            int oldBar = bar_index + 1
            for j = 0 to lvls.size() - 1
                Lvl c = lvls.get(j)
                if c.dir == side and c.created < oldBar
                    oldBar := c.created
                    oldIdx := j
            if oldIdx >= 0
                Lvl gone = lvls.remove(oldIdx)
                line.delete(gone.ray)
                label.delete(gone.tag)
            cnt -= 1

    // 4) finalize signals; opposite signals on the same bar cancel out
    bullSig := bullP > 0 and bearP <= 0
    bearSig := bearP > 0 and bullP <= 0
    if bullSig or bearSig
        float lvlP = bullSig ? bullL : bearL
        float prob = bullSig ? bullP : bearP
        bool  isBk = bullSig ? bullIsBrk : bearIsBrk
        float tgt  = na
        if lvls.size() > 0
            for lv in lvls
                if math.abs(lv.price - lvlP) > syminfo.mintick
                    if bullSig and lv.price > close and (na(tgt) or lv.price < tgt)
                        tgt := lv.price
                    if bearSig and lv.price < close and (na(tgt) or lv.price > tgt)
                        tgt := lv.price
        float inv = bullSig ? lvlP - buf : lvlP + buf
        sigCode := bullSig ? (isBk ? 2 : 1) : (isBk ? -2 : -1)
        lastSig := sigCode
        lastPr  := prob
        lastTgt := tgt
        lastInv := inv
        string kind = isBk ? "BREAK" : "HOLD"
        lastTxt := (bullSig ? "BULL " : "BEAR ") + kind + " " + f_pct(prob)
        color c = bullSig ? bullCol : bearCol
        label lb = label.new(bar_index, bullSig ? low - 0.6 * atr : high + 0.6 * atr, kind + " " + f_pct(prob), yloc = yloc.price, style = bullSig ? label.style_label_up : label.style_label_down, color = c, textcolor = #0B0E14, size = size.small, tooltip = kind + " at " + str.tostring(lvlP, format.mintick) + "\nP(" + kind + ") from history: " + f_pct(prob) + "\nTarget: " + (na(tgt) ? "open" : str.tostring(tgt, format.mintick)) + "\nInvalidation: " + str.tostring(inv, format.mintick))
        sigLbs.push(lb)
        if sigLbs.size() > MAX_SIGLB
            label.delete(sigLbs.shift())
        if showPlan
            line.delete(tgtLn)
            line.delete(invLn)
            tgtLn := na
            if not na(tgt)
                tgtLn := line.new(bar_index, tgt, bar_index + PLAN_LEN, tgt, color = c, style = line.style_dotted, width = 2)
            invLn := line.new(bar_index, inv, bar_index + PLAN_LEN, inv, color = color.new(chart.fg_color, 40), style = line.style_dashed, width = 1)

// ── Nearest levels (every bar, for Screener columns and the dashboard) ──────
float supPx = na
int   supPv = 0
float resPx = na
int   resPv = 0
if lvls.size() > 0
    for lv in lvls
        if lv.dir == -1 and lv.price <= close and (na(supPx) or lv.price > supPx)
            supPx := lv.price
            supPv := lv.prev
        if lv.dir == 1 and lv.price >= close and (na(resPx) or lv.price < resPx)
            resPx := lv.price
            resPv := lv.prev
float supPH = na(supPx) or f_nPrior(trans, supPv) < nMin ? na : f_pPrior(trans, supPv, 0)
float resPH = na(resPx) or f_nPrior(trans, resPv) < nMin ? na : f_pPrior(trans, resPv, 0)

// ── Pine Screener / Data Window columns (declared first among plots) ────────
plot(na(supPH) ? na : supPH * 100, "Support P(hold) %", display = display.data_window + display.pine_screener)
plot(na(resPH) ? na : resPH * 100, "Resistance P(hold) %", display = display.data_window + display.pine_screener)
plot(sigCode, "Signal code (+2 bull break, +1 bull hold, -1 bear hold, -2 bear break)", display = display.data_window + display.pine_screener)
// invisible price anchors keep the overlay on the symbol's scale
plot(high, "Scale anchor high", color = color.new(#000000, 100), display = display.pane, editable = false)
plot(low, "Scale anchor low", color = color.new(#000000, 100), display = display.pane, editable = false)

plotshape(fragSup and showFrag, "Fragile support test", shape.xcross, location.belowbar, color.new(bearCol, 30), size = size.tiny)
plotshape(fragRes and showFrag, "Fragile resistance test", shape.xcross, location.abovebar, color.new(bullCol, 30), size = size.tiny)

alertcondition(bullSig, "MLVE Bull signal", "MLVE: bullish HOLD at support or BREAK of resistance on {{ticker}} {{interval}}")
alertcondition(bearSig, "MLVE Bear signal", "MLVE: bearish HOLD at resistance or BREAK of support on {{ticker}} {{interval}}")
alertcondition(bullSig or bearSig, "MLVE Any signal", "MLVE signal on {{ticker}} {{interval}}")

// ── Dashboard (first table → reads cleanly if moved to the bottom panel) ────
string tSz = tblSize == TSize.small ? size.tiny : tblSize == TSize.large ? size.normal : size.small
string hSz = tblSize == TSize.small ? size.small : size.normal
var table dash = table.new(position.top_right, 2, 9, bgcolor = color.new(chart.bg_color, 8), border_color = color.new(chart.fg_color, 85), border_width = 1, frame_color = color.new(chart.fg_color, 70), frame_width = 1)

f_row(table t, int r, string a, string b, color bc, string sz) =>
    table.cell(t, 0, r, a, text_color = color.new(chart.fg_color, 30), text_halign = text.align_left, text_size = sz)
    table.cell(t, 1, r, b, text_color = bc, text_halign = text.align_right, text_size = sz)

f_lvlTxt(float px, int pv) =>
    na(px) ? "none" : str.tostring(px, format.mintick) + " · " + f_prevTxt(pv)

f_probTxt(float px, int pv) =>
    na(px) ? "–" : f_nPrior(trans, pv) < nMin ? "learning (n " + str.tostring(f_nPrior(trans, pv)) + "/" + str.tostring(nMin) + ")" : f_pct(f_pPrior(trans, pv, 0)) + " / " + f_pct(f_pPrior(trans, pv, 1)) + " / " + f_pct(f_pPrior(trans, pv, 2)) + "  n " + str.tostring(f_nPrior(trans, pv))

if barstate.islast and showDash
    int total = 0
    int holds = 0
    for r = 0 to 5
        total += f_n(trans, r)
        holds += trans.get(r, 0)
    string sV = na(supPx) ? "–" : f_verdict(trans, supPv)
    string rV = na(resPx) ? "–" : f_verdict(trans, resPv)
    color  fg = chart.fg_color
    table.cell(dash, 0, 0, "MLVE · Level Validity", text_color = fg, text_halign = text.align_left, text_size = hSz, text_formatting = text.format_bold)
    table.cell(dash, 1, 0, str.tostring(sigMode), text_color = color.new(fg, 40), text_halign = text.align_right, text_size = tSz)
    f_row(dash, 1, "Support", f_lvlTxt(supPx, supPv), bullCol, tSz)
    f_row(dash, 2, "  Hold / Break / Stall", f_probTxt(supPx, supPv), fg, tSz)
    f_row(dash, 3, "Resistance", f_lvlTxt(resPx, resPv), bearCol, tSz)
    f_row(dash, 4, "  Hold / Break / Stall", f_probTxt(resPx, resPv), fg, tSz)
    f_row(dash, 5, "Verdict", "S " + sV + " · R " + rV, fg, tSz)
    f_row(dash, 6, "Last signal", lastSig == 0 ? lastTxt : lastTxt + " → T " + (na(lastTgt) ? "open" : str.tostring(lastTgt, format.mintick)) + " · inv " + str.tostring(lastInv, format.mintick), lastSig > 0 ? bullCol : lastSig < 0 ? bearCol : fg, tSz)
    f_row(dash, 7, "Model", "tests " + str.tostring(total) + " · base hold " + (total > 0 ? f_pct(holds * 1.0 / total) : "–"), fg, tSz)
    f_row(dash, 8, "Data", "OHLC · ALL PLANS · closed bars", color.new(fg, 40), tSz)
````
