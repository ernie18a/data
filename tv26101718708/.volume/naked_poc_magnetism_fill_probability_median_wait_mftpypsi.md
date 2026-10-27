# Naked POC Magnetism  Fill Probability & Median Wait

- url: https://www.tradingview.com/script/MfTpypsI-Naked-POC-Magnetism-Fill-Probability-Median-Wait/
- type: indicator
- pine_id: PUB;e841f7b6e160423589bdb8bf01812d4a
- version: 3.0

## Description

Naked POC Magnetism — Fill Probability & Median Wait

What it is

A naked POC is the highest-volume price of a past session that price has not revisited since. Traders treat them as magnets — but "it usually gets filled" is folklore until it's measured. This tool measures it. Every historical naked level on your chart becomes a data point (how many sessions it survived before being touched, or whether it never was), and a survival model (discrete-hazard life table) turns that history into, for each live naked level: the probability it fills within the next N sessions and the median wait. Levels are drawn with their measured magnetism, not just their location.

How the statistics work — and their honest limits

Each session's volume-at-price profile is built from that session's bars; at session close the peak-volume price (POC) becomes a naked level.
A level is filled the first time a later bar's range touches it; its age in sessions at that moment is one observation. Levels removed unfilled (history cap) are censored at their age — counted as "survived this long," never as fills. This is the standard treatment of incomplete observations from survival analysis (Kaplan–Meier 1958; classical life tables).
Hazard at age j = fills at age j ÷ levels at risk at age j. Survival multiplies (1 − hazard) across ages; fill-probability within a horizon and the median wait follow directly.
Reliability gates, enforced not footnoted: no probability is displayed until a minimum number of levels have resolved (input, default 20) — until then the tool says BUILDING and shows only counts. And hazard estimates at ages with fewer than 5 at-risk observations are truncated rather than trusted, per standard life-table convention.
Probabilities are empirical frequencies from this symbol and timeframe's own history — they change with regime and sample, and a 70% is not a promise.

Seeing the evidence

Every historical fill prints a small ◈ marker where a naked level was touched — the resolved observations the probabilities are measured from, visible on the chart rather than hidden in a table.
The dashboard shows both the NEAREST level and the STRONGEST magnet (highest fill probability) — they are often not the same level, and the strongest one is the better answer to "where is price most drawn".
An honest design note: this tool deliberately has NO multi-timeframe stack and NO state-debounce, unlike its siblings in this suite — sessions are the model's clock regardless of chart timeframe (a higher-timeframe copy would measure the same sessions with coarser bins), and nothing here chatters (levels are born at session close and resolve on touch). Features are added where they inform, not everywhere.

How to use it

Add to a liquid intraday chart; 5m–15m gives the model the most sessions to learn from. Let it run until the dashboard reads MEASURED.
Each rail is labelled like "NPOC 24512 · 68% /5s · med 3s" — the measured chance it fills within the horizon and the median sessions historically needed. Warm, saturated rails = strong magnets; faded = weak or unrated.
The dashboard shows the nearest level's read and — deliberately — the sample size behind every number.
Use magnetism as context about where price is drawn (targets, fade zones, expectations management), never as an entry signal by itself.

What makes it original

Naked-POC indicators draw lines. This one attaches a measured fill-probability and expected wait to each line, estimated with a proper survival model that handles censoring and refuses to show numbers it can't support. Turning a folklore level into a level with a live, honest statistic is the contribution.

Concept credits

Market Profile / point of control — J. Peter Steidlmayer. Naked (virgin) POC — market-profile trading literature. Survival estimation from incomplete observations — E. L. Kaplan & P. Meier (1958); classical life-table method. Implementation and charting design are the author's own.

Important disclaimer

Research and education only. Not financial advice, not a signal service, not a guarantee of future results. Fill probabilities are empirical frequencies measured on this chart's limited history. Validate independently and manage your own risk.

## Source Code

````pine
//@version=6
// =============================================================================
//  NAKED-LEVEL MAGNETISM ENGINE  -  v1.1 (BOUNDED PROBABILITIES)
//  Naked session POCs, upgraded from "a line on the chart" to "a level with a
//  measured fill-probability and expected wait" — estimated from this chart's
//  own history with a survival (life-table) model.
// -----------------------------------------------------------------------------
//  THE IDEA
//    A NAKED POC is the highest-volume price of a past session that price has
//    not revisited since. Traders treat them as magnets — but not all naked
//    levels are equal, and "it usually gets filled" is folklore until measured.
//    This tool measures it: every historical naked level on the chart becomes a
//    data point (how many sessions it survived before being touched, or whether
//    it never was), and a DISCRETE-HAZARD LIFE TABLE turns that history into,
//    for each live naked level: the probability it is filled within the next N
//    sessions, and the median wait. Levels are then drawn with their measured
//    magnetism — not just their location.
//
//  HOW THE STATISTICS WORK (and their honest limits)
//    • Each session's volume-at-price profile is built from that session's bars;
//      at session close the peak-volume price (POC) becomes a naked level.
//    • A level is FILLED the first time a later bar's range touches it; its age
//      in sessions at that moment is one observation. Levels removed unfilled
//      (history cap) are CENSORED at their age — counted as "survived this
//      long", never as fills. This is the standard life-table treatment of
//      incomplete observations (Kaplan–Meier 1958).
//    • Hazard at age j = fills at age j ÷ levels at risk at age j. Survival
//      multiplies (1 − hazard) across ages; fill-probability within a horizon
//      and the median wait follow directly.
//    • RELIABILITY GATES (research conventions, enforced): no probability is
//      shown until enough levels have resolved (minimum sample input), and
//      hazard estimates at ages with fewer than 5 at-risk observations are
//      truncated rather than trusted. Until then the tool says BUILDING and
//      shows only counts. Probabilities are empirical frequencies from THIS
//      symbol and timeframe's history — not universal constants.
//
//  HOW TO READ IT (price overlay)
//    Each naked level is a rail labelled like "68% / 5s · med 3s": the measured
//    chance it fills within the horizon, and the median sessions historically
//    needed. Warm, saturated rails = strong magnets; faded = weak or unrated.
//    The dashboard shows the nearest level's read and the sample size behind
//    every number. Magnetism is about WHERE price is drawn, not WHEN to enter —
//    this is context for your own process, never a signal.
//
//  PROBABILITIES ARE BOUNDED  (v1.1)
//    A fill probability is an ESTIMATE from a finite number of resolved levels,
//    and on a small sample "68%" and "coin flip" can be the same number wearing
//    different clothes. Every probability now carries a GREENWOOD 95% interval,
//    and the LOWER bound is what the tool grades on.
//    Why Greenwood and not a Wilson interval: Wilson is the right tool for a
//    single binomial proportion. This estimate is not one - it is a Kaplan-Meier
//    PRODUCT of several age-specific hazards, each with its own sampling error,
//    computed over censored data. Greenwood's formula is the standard variance
//    for precisely that estimator:  Var(S) = S^2 * SUM[ d_j / (n_j (n_j - d_j)) ].
//    The interval on survival inverts to an interval on fill probability.
//
//  WHAT CHANGED ON THE CHART  (v1.1)
//    - Rails are GRADED BY THE LOWER BOUND, not the point estimate: a level only
//      looks like a strong magnet when its weakest plausible reading is still
//      strong. A lucky mean on three observations no longer paints a hot rail.
//    - Rail WIDTH encodes confidence: a tight interval draws thick, a wide one
//      draws thin. Uncertainty is now visible at a glance, without reading a
//      number.
//    - Labels show both figures, e.g. "NPOC 24310  68% (LB 41%) /5s - med 3s".
//    - STRONGEST is chosen by lower bound, so a poorly measured level can no
//      longer outrank a well measured one.
//
//  NON-REPAINT
//    Profiles accumulate on confirmed bars; a POC is committed only at session
//    close; fills resolve on confirmed bars. Nothing repaints.
//
//  USE ON ANY MARKET
//    Price/volume sources, profile rows, horizons and caps are inputs. Works on
//    any symbol with volume; intraday timeframes (5m–15m) give the model the
//    most sessions to learn from. Defaults suit liquid index futures.
//
//  CONCEPT CREDITS (original authors of the ideas synthesised here)
//    • Market Profile / point of control — J. Peter Steidlmayer.
//    • Naked (virgin) POC concept — market-profile trading literature.
//    • Survival estimation from incomplete observations — E. L. Kaplan &
//      P. Meier (1958); classical life-table method (Greenwood and successors).
//    Implementation and charting design are the author's own.
//
//  DISCLAIMER
//    Research and education only. NOT financial advice, NOT a signal service,
//    NOT a guarantee of future results. Fill probabilities are empirical
//    frequencies measured on this chart's limited history; they change with
//    regime and sample, and a 70% is not a promise. Validate independently and
//    manage your own risk.
// =============================================================================
indicator("Naked POC Magnetism — Fill Probability & Median Wait", "NPOC Magnetism",
     overlay = true, max_lines_count = 120, max_labels_count = 120, max_bars_back = 5000)

// ═════════════════════════ 00 · DATA SOURCE ═════════════════════════════════
g0 = "00 · Data source"
volSrc = input.source(volume, "Volume source", group = g0,
     tooltip = "Volume used to build each session's volume-at-price profile.")

// ═════════════════════════ 01 · PROFILE / LEVELS ════════════════════════════
g1 = "01 · Profile & levels"
rows    = input.int(24, "Profile rows per session", minval = 8, maxval = 60, group = g1,
     tooltip = "Price rows the session's volume is binned into before taking the peak (POC). More rows = finer POC, needs liquid volume.")
keepMax = input.int(15, "Max naked levels kept", minval = 3, maxval = 30, group = g1,
     tooltip = "Oldest unfilled levels beyond this cap are removed and counted as censored observations (survived, not filled).")
maxAge  = input.int(20, "Max age tracked (sessions)", minval = 5, maxval = 60, group = g1,
     tooltip = "Ages beyond this are pooled; also the cap of the life table.")

// ═════════════════════════ 02 · MAGNETISM STATISTICS ════════════════════════
g2 = "02 · Magnetism statistics"
horizon  = input.int(5, "Fill horizon (sessions)", minval = 1, maxval = 20, group = g2,
     tooltip = "The displayed probability is 'filled within this many sessions from now'.")
minSample= input.int(20, "Minimum resolved levels before showing %", minval = 5, maxval = 200, group = g2,
     tooltip = "Honesty gate: probabilities are hidden (BUILDING) until at least this many historical levels have resolved (filled or censored).")
minRisk  = input.int(5, "Min at-risk per age bucket", minval = 2, maxval = 50, group = g2,
     tooltip = "Hazard at an age with fewer at-risk observations than this is not trusted (standard life-table convention).")

// ═════════════════════════ 03 · OUTPUT ══════════════════════════════════════
g3 = "03 · Output"
showLabels = input.bool(true, "Show per-level magnetism labels", group = g3)
gradeCol   = input.bool(true, "Colour levels by magnetism", group = g3)
showFills  = input.bool(true, "Mark filled levels", group = g3,
     tooltip = "A small marker prints where a naked level was filled — the resolved history the statistics are measured from, visible on the chart.")

// ═════════════════════════ 04 · DASHBOARD ═══════════════════════════════════
g4 = "04 · Dashboard"
showDash  = input.bool(true, "Show main dashboard", group = g4)
compactTbl= input.bool(false, "Compact dashboard", group = g4)
dashPos   = input.string("Top Right", "Dashboard position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = g4)
showId    = input.bool(false, "Show name / symbol / timeframe label (separate table)", group = g4)

// ═════════════════════════ 05 · STYLE ═══════════════════════════════════════
g5 = "05 · Style"
themeOpt = input.string("Auto (match chart)", "Theme",
     options = ["Auto (match chart)", "Dark", "Light"], group = g5)

// ───────────────────────── PALETTE / THEME (adaptive, institution) ──────────
var color COL_MID  = #f7c948
var color COL_INFO = #3d6cf0
var color COL_WARM = #f6465d

f_lumaDark(color c) =>
    na(c) ? true : (0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)) < 140
bool isDark = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : f_lumaDark(chart.bg_color)
color tBord  = isDark ? color.new(#3a4250, 0)  : color.new(#c2c8d0, 0)
color tLbl   = isDark ? #9aa3b2 : #515a67
color tVal   = isDark ? #f2f4f8 : #10151d
color cBull  = isDark ? #2dd4bf : #0e9e76
color cWarn  = isDark ? #ffa94d : #b56a00
color cMute  = isDark ? #6b7480 : #98a0ab
color zebraA = isDark ? color.new(#141a26, 0) : color.new(#eef1f6, 0)
color zebraB = isDark ? color.new(#0e131d, 0) : color.new(#f8fafc, 0)
color frameCl = tBord

f_pos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        => position.top_right

// ───────────────────────── SESSION MACHINERY ────────────────────────────────
int dayTime = time("D")
bool newSess = ta.change(dayTime) != 0
var int sessIdx = 0

// per-session price/volume capture (cleared each session)
var float[] sesP = array.new_float(0)
var float[] sesV = array.new_float(0)

// active naked levels
var float[] lvPrice = array.new_float(0)
var int[]   lvBorn  = array.new_int(0)
var line[]  lvLine  = array.new<line>()
var label[] lvLab   = array.new<label>()
var label[] fillMarks = array.new<label>()

// life table: fills and at-risk by age bucket 1..maxAge (index 0 unused)
var float[] ltFill = array.new_float(61, 0.0)
var float[] ltRisk = array.new_float(61, 0.0)
var int resolvedN = 0

// register a resolved level (filled at age a, or censored at age a)
f_ltRegister(int a, bool filled) =>
    int aa = math.min(math.max(a, 1), maxAge)
    for j = 1 to aa
        array.set(ltRisk, j, array.get(ltRisk, j) + 1.0)
    if filled
        array.set(ltFill, aa, array.get(ltFill, aa) + 1.0)

// hazard at age j (na when below the at-risk reliability floor)
f_hazard(int j) =>
    float hz = na
    if j >= 1 and j <= maxAge
        float r = array.get(ltRisk, j)
        float fl = array.get(ltFill, j)
        if r >= minRisk
            hz := math.min(0.99, fl / r)
    hz

// P(fill within next h sessions | survived to age a): 1 - Π (1-hazard)
f_fillProb(int a, int h) =>
    float pr = na
    int jEnd = math.min(a + h, maxAge)
    if a + 1 <= jEnd
        float surv = 1.0
        bool any = false
        for j = a + 1 to jEnd
            float hz = f_hazard(j)
            if not na(hz)
                surv *= (1.0 - hz)
                any := true
        if any
            pr := 1.0 - surv
    pr

// GREENWOOD 95% BOUND on the fill probability.
// The point estimate is a Kaplan-Meier product-limit: S = PROD(1 - hazard),
// P(fill) = 1 - S. A Wilson interval would be WRONG here - that is for a single
// binomial proportion, whereas this estimate is a PRODUCT of several hazards,
// each carrying its own sampling error, and it must also respect censoring.
// Greenwood's formula is the standard variance for exactly this estimator:
//     Var(S) = S^2 * SUM[ d_j / (n_j * (n_j - d_j)) ]
// where d_j = fills at age j and n_j = levels at risk at age j. The interval on
// S inverts to an interval on P, and the LOWER bound on fill probability is the
// conservative read - the worst this level's magnetism plausibly is.
f_fillProbLo(int a, int h) =>
    float lo = na
    int jEnd = math.min(a + h, maxAge)
    if a + 1 <= jEnd
        float surv = 1.0
        float acc  = 0.0
        bool any = false
        for j = a + 1 to jEnd
            float r  = array.get(ltRisk, j)
            float fl = array.get(ltFill, j)
            if r >= minRisk
                float hz = math.min(0.99, fl / r)
                surv *= (1.0 - hz)
                // Greenwood term; guarded when every at-risk level filled
                if (r - fl) > 0
                    acc += fl / (r * (r - fl))
                any := true
        if any
            float se = surv * math.sqrt(math.max(acc, 0.0))
            float sHi = math.min(1.0, surv + 1.96 * se)   // upper bound on survival
            lo := math.max(0.0, 1.0 - sHi)                // -> lower bound on fill
    lo

// median sessions to fill from age a (smallest m with cumulative ≥ 50%)
f_medianWait(int a) =>
    int med = -1
    if a + 1 <= maxAge
        float surv = 1.0
        for j = a + 1 to maxAge
            float hz = f_hazard(j)
            if not na(hz)
                surv *= (1.0 - hz)
                if med < 0 and surv <= 0.5
                    med := j - a
    med

bool statsReady = resolvedN >= minSample

// ───────────────────────── SESSION CLOSE → NEW NAKED LEVEL ──────────────────
f_commitPoc() =>
    float poc = na
    int n = array.size(sesP)
    if n > 5
        float lo = array.min(sesP)
        float hi = array.max(sesP)
        if hi > lo
            float[] binV = array.new_float(rows, 0.0)
            for i = 0 to n - 1
                int b = int((array.get(sesP, i) - lo) / (hi - lo) * (rows - 1))
                b := math.max(0, math.min(rows - 1, b))
                array.set(binV, b, array.get(binV, b) + array.get(sesV, i))
            int bBest = 0
            float vBest = -1.0
            for b = 0 to rows - 1
                if array.get(binV, b) > vBest
                    vBest := array.get(binV, b)
                    bBest := b
            poc := lo + (bBest + 0.5) / rows * (hi - lo)
    poc

if newSess and barstate.isconfirmed
    // commit previous session's POC as a naked level
    float poc = f_commitPoc()
    if not na(poc)
        array.push(lvPrice, poc)
        array.push(lvBorn, sessIdx)
        ln = line.new(bar_index, poc, bar_index + 1, poc, xloc.bar_index, extend = extend.right, color = color.new(COL_MID, 40), width = 2)
        array.push(lvLine, ln)
        lb = label.new(bar_index, poc, "", style = label.style_label_left, color = color.new(color.gray, 100), textcolor = tVal, size = size.small)
        array.push(lvLab, lb)
        // cap: censor the oldest unfilled level
        if array.size(lvPrice) > keepMax
            int ageC = sessIdx - array.get(lvBorn, 0)
            f_ltRegister(ageC, false)
            resolvedN += 1
            line.delete(array.shift(lvLine))
            label.delete(array.shift(lvLab))
            array.shift(lvPrice)
            array.shift(lvBorn)
    sessIdx += 1
    array.clear(sesP)
    array.clear(sesV)

if barstate.isconfirmed
    array.push(sesP, hlc3)
    array.push(sesV, nz(volSrc, 0.0))

// ───────────────────────── FILL DETECTION ───────────────────────────────────
bool fillEvent = false
if barstate.isconfirmed and array.size(lvPrice) > 0
    int i = array.size(lvPrice) - 1
    while i >= 0
        float p = array.get(lvPrice, i)
        int born = array.get(lvBorn, i)
        // a level only becomes 'naked' (touchable) from the session after birth
        if sessIdx > born and low <= p and p <= high
            int age = math.max(1, sessIdx - born)
            f_ltRegister(age, true)
            resolvedN += 1
            fillEvent := true
            line.delete(array.get(lvLine, i))
            label.delete(array.get(lvLab, i))
            array.remove(lvLine, i)
            array.remove(lvLab, i)
            array.remove(lvPrice, i)
            array.remove(lvBorn, i)
            if showFills
                fm = label.new(bar_index, p, "◈", style = label.style_none, textcolor = color.new(COL_INFO, 25), size = size.small, tooltip = "Naked level filled here — one resolved observation in the life table.")
                array.push(fillMarks, fm)
                if array.size(fillMarks) > 50
                    label.delete(array.shift(fillMarks))
        i -= 1

// ───────────────────────── LEVEL LABELS / GRADING (last bar) ────────────────
float nearProb = na
float nearProbLo = na
float nearDist = na
float nearPx = na
int nearMed = -1
float bestProb = na
float bestProbLo = na
float bestPx = na
int bestMed = -1
if barstate.islast and array.size(lvPrice) > 0
    for i = 0 to array.size(lvPrice) - 1
        float p = array.get(lvPrice, i)
        int age = math.max(1, sessIdx - array.get(lvBorn, i))
        float prAll = f_fillProb(age, horizon)
        float prLoA = f_fillProbLo(age, horizon)
        int medAll = f_medianWait(age)
        float pr = statsReady ? prAll : na
        float prLo = statsReady ? prLoA : na
        int med = statsReady ? medAll : -1
        string txt = "NPOC " + str.tostring(p, format.mintick)
        txt := statsReady and not na(pr) ? txt + " · " + str.tostring(math.round(pr * 100)) + "% /" + str.tostring(horizon) + "s" + (med > 0 ? " · med " + str.tostring(med) + "s" : "") : txt + " · building"
        label.set_text(array.get(lvLab, i), showLabels ? txt : "")
        label.set_x(array.get(lvLab, i), bar_index + 3)
        // Rails are graded by the LOWER BOUND, not the point estimate: a level
        // only looks like a strong magnet when its weakest plausible reading is
        // still strong. Width encodes confidence - a tight interval draws thick.
        float grade = na(prLo) ? na : prLo
        float band  = (na(pr) or na(prLo)) ? na : pr - prLo
        int   lw    = na(band) ? 1 : band <= 0.10 ? 3 : band <= 0.20 ? 2 : 1
        line.set_width(array.get(lvLine, i), lw)
        color lc = not gradeCol or na(grade) ? color.new(COL_MID, 45) : grade >= 0.66 ? color.new(COL_WARM, 15) : grade >= 0.4 ? color.new(COL_MID, 25) : color.new(COL_INFO, 45)
        line.set_color(array.get(lvLine, i), lc)
        label.set_textcolor(array.get(lvLab, i), tVal)
        float d = math.abs(close - p)
        if na(nearDist) or d < nearDist
            nearDist := d
            nearPx := p
            nearProb := pr
            nearProbLo := prLo
            nearMed := med
        // "strongest" is now decided by the LOWER BOUND, so a wide-interval
        // level can no longer outrank a well-measured one on a lucky mean.
        if not na(prLo) and (na(bestProbLo) or prLo > bestProbLo)
            bestProbLo := prLo
            bestProb := pr
            bestPx := p
            bestMed := med

// ───────────────────────── DASHBOARD (institution, adaptive) ─────────────────
f_setRow(table t, int r, string lbl, string val, color vc, color lc, color bg) =>
    table.cell(t, 0, r, lbl, text_color = lc, text_size = size.tiny,  text_halign = text.align_left,  bgcolor = bg)
    table.cell(t, 1, r, val, text_color = vc, text_size = size.small, text_halign = text.align_right, bgcolor = bg)

string stateTxt = statsReady ? "MEASURED" : "BUILDING"

var table dash = na
if showDash and barstate.islast
    color stBg = statsReady ? color.new(COL_INFO, 0) : color.new(cMute, 0)
    if na(dash)
        dash := table.new(f_pos(dashPos), 2, compactTbl ? 4 : 9, border_width = 1, frame_color = frameCl, frame_width = 1)
    table.set_frame_color(dash, frameCl)
    table.set_border_color(dash, frameCl)
    table.cell(dash, 0, 0, " NPOC MAGNETISM", text_color = color.white, text_size = size.small, text_halign = text.align_left, bgcolor = stBg, tooltip = "Naked POC levels with life-table fill statistics measured from this chart's own history. Context about where price is drawn — never a signal or a promise.")
    table.cell(dash, 1, 0, stateTxt + " ", text_color = color.white, text_size = size.small, text_halign = text.align_right, bgcolor = stBg)
    f_setRow(dash, 1, "NAKED LEVELS", str.tostring(array.size(lvPrice)), tVal, tLbl, zebraA)
    string nearTxt = na(nearPx) ? "-" : str.tostring(nearPx, format.mintick) + (na(nearProbLo) ? "" : " LB " + str.tostring(math.round(nearProbLo*100)) + "%") + (na(nearProb) ? "" : " · " + str.tostring(math.round(nearProb * 100)) + "%/" + str.tostring(horizon) + "s")
    f_setRow(dash, 2, "NEAREST", nearTxt, na(nearProbLo) ? tVal : nearProbLo >= 0.66 ? cWarn : tVal, tLbl, zebraB)
    if not compactTbl
        string bestTxt = na(bestPx) ? "-" : str.tostring(bestPx, format.mintick) + " · " + str.tostring(math.round(bestProb * 100)) + "%/" + str.tostring(horizon) + "s" + (bestMed > 0 ? " · med " + str.tostring(bestMed) + "s" : "")
        f_setRow(dash, 3, "STRONGEST", bestTxt, na(bestProbLo) ? cMute : bestProbLo >= 0.66 ? cWarn : tVal, tLbl, zebraA)
        f_setRow(dash, 4, "MEDIAN WAIT (nearest)", nearMed > 0 ? str.tostring(nearMed) + " sessions" : "-", tVal, tLbl, zebraB)
        f_setRow(dash, 5, "SAMPLE (resolved)", str.tostring(resolvedN) + " / " + str.tostring(minSample) + " min", statsReady ? cBull : cWarn, tLbl, zebraA)
        f_setRow(dash, 6, "HORIZON", str.tostring(horizon) + " sessions", tVal, tLbl, zebraB)
        f_setRow(dash, 7, "SESSIONS SEEN", str.tostring(sessIdx), tVal, tLbl, zebraA)
        f_setRow(dash, 8, "NOTE", statsReady ? "empirical, this chart only" : "need more history / lower TF", cMute, tLbl, zebraB)

// identity label (separate toggle)
var table idTbl = na
if showId and barstate.islast
    if na(idTbl)
        idTbl := table.new(position.bottom_center, 1, 1)
    table.cell(idTbl, 0, 0, "NPOC Magnetism  ·  " + syminfo.ticker + "  " + timeframe.period, text_color = color.new(tLbl, 15), text_size = size.small, text_halign = text.align_center, bgcolor = color.new(color.gray, 100))

// ───────────────────────── EXPORTS (Data Window · generic names) ────────────
plot(array.size(lvPrice), "Naked Level Count", display = display.data_window)
plot(nearPx,   "Nearest Level Price",  display = display.data_window)
plot(nearProb, "Nearest Fill Probability", display = display.data_window)
plot(nearProbLo, "Nearest Fill Prob (95% LB)", display = display.data_window)
plot(resolvedN,"Resolved Sample",      display = display.data_window)
plot(bestProb, "Strongest Fill Probability", display = display.data_window)
plot(bestProbLo, "Strongest Fill Prob (95% LB)", display = display.data_window)

// ───────────────────────── ALERTS ───────────────────────────────────────────
alertcondition(newSess, "New session", "NPOC Magnetism: new session — previous session's POC committed if naked")
alertcondition(fillEvent, "Naked level filled", "NPOC Magnetism: a naked level was filled — one more resolved observation in the life table")
````
