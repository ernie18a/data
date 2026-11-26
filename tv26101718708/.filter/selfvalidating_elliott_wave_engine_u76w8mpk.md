# Self-Validating Elliott Wave Engine

- url: https://www.tradingview.com/script/U76W8mpk-Self-Validating-Elliott-Wave-Engine/
- type: indicator
- pine_id: PUB;b0789f173acc4b2b8b10be74382f4243
- version: 2.0

## Description

SELF-VALIDATING ELLIOTT WAVE ENGINE

A probabilistic Elliott Wave framework that does three things most wave tools do not: it weighs SEVERAL competing counts at once instead of asserting one, it CALIBRATES its own confidence against what actually happened on the instrument you are viewing, and it tells you honestly when no count is trustworthy. It is decision-support and context - not a signal generator, and never a claim of certainty.


WHY THESE PARTS BELONG TOGETHER (one engine, not a bundle)

Elliott Wave analysis is unavoidably ambiguous: the same swings can support an impulse, a zigzag, a flat or a triangle, and practitioners disagree constantly. A tool that draws one count and hides that ambiguity is misleading. This script is built as a single pipeline whose stages exist specifically to manage that ambiguity, and removing any one stage breaks it:

1. Structure - an alternating swing (ZigZag) series is built from confirmed pivots, and each pivot is tagged with momentum (RSI) and relative volume. This is the raw evidence every wave rule is tested against; without a clean swing series there is nothing to count.

2. Multi-count pattern engine - from that swing series the script forms several competing labelled hypotheses at once (impulse forming wave 3/4/5 or complete, zigzag, flat, contracting triangle). Because Elliott is ambiguous, evaluating alternatives is the whole point, not an add-on.

3. Scoring - each hypothesis is graded on Fibonacci fit, proportion and the alternation guideline (waves 2 and 4 should differ in form), and "wave energy" (does wave 3 thrust hardest, in trend direction, on rising volume?). These are combined deliberately: Fibonacci ratios alone mislabel corrections as impulses; momentum alone is directionless noise; only together do they discriminate real structure.

4. Regime context - a trend/range/compression read (from ADX and ATR) tilts the priors, because impulses are more likely in trends and corrections in ranges. It changes the odds, it does not override the structure.

5. Market-structure confirmation - an independent break-of-structure / change-of-character check raises or lowers the chosen count, so the wave read must agree with raw price action to score well.

6. Calibrated forecast - the forward zone is built from THIS chart's own distribution of historical retracement depths, not fixed ratios pulled from a textbook, so it reflects how the specific instrument actually behaves.

7. Outcome calibration - every forward call (target + invalidation + confidence) is logged and later checked: did price reach target before invalidation? Outcomes are bucketed by confidence, so the confidence number on screen can be mapped to a MEASURED hit-rate. This is the stage that makes the tool self-validating, and it is impossible without all the stages above feeding it.

So the components are not stacked for convenience - they form one loop: build competing hypotheses, score them on structure and momentum, tilt by regime, confirm against price structure, forecast from the instrument's own history, then grade that forecast against reality and report the measured reliability. That is why this is one indicator rather than seven separate overlays.


HOW IT WORKS ON THE CHART

- Wave labels and connecting lines draw the primary (highest-scoring) count's structure.
- A dashed projection line and a shaded forecast zone mark where the primary count expects price to go, with the zone width calibrated from the chart's own retrace history.
- A dashboard reports: the primary count with its probability share, its position and stage, the two best alternative counts, the raw confidence, the measured calibrated hit-rate once enough cases have resolved, the regime, the market-structure state (and whether it confirms or warns), the hard-rule pass/fail, wave energy, an opportunity read (confidence shaped by reward-to-risk and structure), and the target / invalidation levels.


HOW TO USE IT

- Read the ambiguity, not a single answer. The secondary and tertiary counts and their probabilities tell you how clear or murky the structure currently is.
- Trust "Calibrated" over "Confidence". Confidence is the raw structural score; the calibrated figure is the measured success rate for that confidence level on resolved cases - the honest number.
- Respect "stand aside". When confidence is below your threshold the panel says so instead of forcing a count. That is a feature.
- Use target and invalidation as context for your own plan. Invalidation is the level that would break the primary count; the forecast zone is where it expects to resolve. The script places no orders.
- Combine with your own method. The market-structure and regime rows are there so the wave read can be cross-checked against plain price action.


SETTINGS OVERVIEW

- Structure: swing sensitivity (pivot legs), max swings stored, and pivot source - wicks (high/low) or bodies (close), so it suits how you read a given market.
- Scoring weights: Fibonacci fit, proportion/look, wave-3 momentum.
- Context: ADX length and trend threshold.
- Forecast: inner/outer percentiles of the retrace distribution, minimum swings to calibrate, minimum resolved cases before the calibrated hit-rate is trusted.
- Display: minimum confidence for a "clean" count, label/zone/panel toggles, bull/bear colours.
- Alerts: new wave, count flip, invalidation breach, forecast-zone entry (via "Any alert() function call").

Pivot source is selectable and volume is used only when a symbol reports it, so the engine runs on futures, equities, forex, crypto and indices on any timeframe.


ORIGINALITY

Most Elliott tools draw a single count and stop. This one runs a bounded multi-count search, scores each hypothesis on structure plus momentum plus volume, tilts by regime and confirms against market structure, forecasts from the instrument's own retrace distribution, and - uniquely - measures its own realised hit-rate per confidence level so the number on screen is grounded in outcomes rather than asserted. It quantifies and reports its own reliability.


REPAINT NOTICE AND LIMITATIONS (honest)

- Swing detection uses confirmed pivots, which finalise a fixed number of bars after they form. The most recent leg is therefore always provisional and can change. This is inherent to Elliott structure detection and is disclosed deliberately, not hidden.
- Counts are probabilistic hypotheses, not predictions. Two analysts - and this engine on two settings - can read the same chart differently.
- Calibration is a long-run estimate over resolved cases on this chart; early on, and after a regime change, it needs samples before it means anything, and past hit-rate is not a future guarantee.
- This is context and decision-support. It is not a trading system and issues no orders.


DISCLAIMER

This script is for research and education only. It is not financial advice, not a recommendation, and not a solicitation to trade. It places no orders and guarantees no outcome. Markets carry risk; test any tool on your own data and timeframe and make your own decisions.

## Source Code

````pine
//@version=6
// ============================================================================
//  SELF-VALIDATING ELLIOTT WAVE ENGINE                                Pine v6
//  shorttitle: EW Engine
// ----------------------------------------------------------------------------
//  WHAT THIS IS
//    A probabilistic Elliott Wave framework that does three things most wave
//    tools do not: it considers SEVERAL competing counts at once and scores
//    them, it CALIBRATES its own confidence against what actually happened on
//    this instrument, and it tells you honestly when no count is trustworthy.
//    It is decision-support and context, NOT a signal generator. Every count
//    is a probabilistic hypothesis, never a certainty.
//
//  WHY THESE COMPONENTS ARE COMBINED  (mashup rationale)
//    These are not separate indicators stacked on one chart; each is one stage
//    of a single pipeline, and removing any one breaks the result:
//      * STRUCTURE builds an alternating swing (ZigZag) series from confirmed
//        pivots and tags each pivot with momentum (RSI) and relative volume —
//        the raw material every wave rule is tested against.
//      * PATTERN ENGINE forms competing labelled hypotheses (impulse 3/4/5/6,
//        zigzag, flat, triangle) from that swing series. Elliott is ambiguous,
//        so evaluating alternatives is mandatory, not optional.
//      * SCORING grades each hypothesis on Fibonacci fit, proportion and
//        alternation, and wave-3 momentum/volume ("wave energy"). Fibonacci
//        without momentum mislabels; momentum without structure is noise — they
//        are only meaningful together.
//      * CONTEXT (trend/range/compression regime) tilts the priors: impulses
//        are likelier in trends, corrections in ranges.
//      * STRUCTURE CONFIRMATION (break-of-structure / change-of-character) is
//        independent evidence that raises or lowers the chosen count.
//      * CALIBRATED FORECAST builds the forward zone from THIS chart's own
//        historical retracement depths, not fixed ratios.
//      * OUTCOME CALIBRATION logs every forward call and later checks whether
//        target was reached before invalidation, bucketed by confidence, so the
//        displayed confidence maps to a MEASURED hit-rate. This is the step that
//        makes the tool "self-validating" and is impossible without all the
//        stages above feeding it.
//    Together they form one loop: build hypotheses, score them, confirm with
//    structure, forecast, then grade the forecast against reality — which is why
//    this is one script, not seven overlays.
//
//  HOW TO USE IT  (plain language)
//    1. The panel shows the primary count, its position/stage, and the two best
//       alternatives with probabilities — so you see the ambiguity, not a single
//       false answer.
//    2. "Confidence" is the raw structural score; "Calibrated" is the measured
//       hit-rate for that confidence level once enough cases have resolved.
//    3. When confidence is below your threshold the panel says "low confidence —
//       stand aside" instead of inventing a count.
//    4. The forecast zone and target/invalidation levels are context for your own
//       plan. This tool places no orders and is not a strategy.
//
//  ORIGINALITY
//    Most Elliott tools draw one count and stop. This one runs a bounded
//    multi-count search, tilts it by regime and market structure, forecasts from
//    the instrument's own retrace distribution, and — uniquely — measures its own
//    realised hit-rate per confidence level so the number on screen means
//    something. It quantifies and reports its own reliability.
//
//  REPAINT NOTICE (honest)
//    Swing detection uses confirmed pivots, which finalise `pivLen` bars after
//    they form, so the most recent leg is always provisional and can change.
//    This is inherent to Elliott structure detection and is disclosed on purpose.
//    Counts are hypotheses; calibration is a long-run estimate, not a guarantee.
//
//  UNIVERSAL USE
//    Pivot source is selectable (wicks or bodies) and volume is used only when a
//    symbol reports it, so the engine runs on futures, equities, forex, crypto and
//    indices on any timeframe. Only standard technical methods and terms are used.
//
//  DISCLAIMER
//    Study / indicator for chart analysis and education only. NOT a strategy, NOT a
//    recommendation, NOT financial advice. It places no orders and guarantees no
//    outcome. Markets carry risk. Do your own research and manage your own risk.
// ============================================================================
indicator("Self-Validating Elliott Wave Engine", "EW Engine",
     overlay = true, max_lines_count = 200, max_labels_count = 100, max_boxes_count = 100, max_bars_back = 500)

// ============================================================================
//  INPUTS
// ============================================================================
grpA   = "Structure"
pivLen = input.int(8, "Swing sensitivity (pivot legs)", minval = 2, maxval = 50, group = grpA,
     tooltip = "Higher = fewer, larger swings. Pivots confirm this many bars after they form (source of repaint).")
maxPiv = input.int(50, "Max swings stored", minval = 12, maxval = 200, group = grpA)
pivMode = input.string("Wicks (High / Low)", "Pivot source", options = ["Wicks (High / Low)", "Bodies (Close)"], group = grpA,
     tooltip = "Detect swings from candle wicks (default) or bodies. Use whichever matches how you read this market.")

grpC   = "Scoring weights"
wFib   = input.float(40, "Weight: Fibonacci fit",        minval = 0, maxval = 100, group = grpC)
wProp  = input.float(30, "Weight: Proportion / look",    minval = 0, maxval = 100, group = grpC)
wMom   = input.float(30, "Weight: Wave-3 momentum",      minval = 0, maxval = 100, group = grpC)

grpD     = "Context (regime)"
adxLen   = input.int(14, "ADX length", minval = 2, group = grpD)
adxTrend = input.float(22, "ADX trend threshold", group = grpD)

grpE       = "Forecast (calibrated zone)"
coneInPct  = input.float(50, "Inner band percentile", minval = 10, maxval = 90, group = grpE,
     tooltip = "Bands are calibrated from THIS chart's own historical retrace depths, not fixed ratios.")
coneOutPct = input.float(80, "Outer band percentile", minval = 20, maxval = 99, group = grpE)
minSamples = input.int(10, "Min swings to calibrate", minval = 5, group = grpE)
minCalN    = input.int(8, "Min resolved cases to trust calibration", minval = 3, group = grpE,
     tooltip = "Outcome tracking measures how often counts at each confidence level actually reached target before invalidation.")

grpF      = "Display"
minConf   = input.float(35, "Min confidence for a 'clean' count", minval = 0, maxval = 100, group = grpF,
     tooltip = "Below this, the panel flags 'low confidence — stand aside' instead of pretending certainty.")
showLbls  = input.bool(true,  "Show wave labels",   group = grpF)
showCone  = input.bool(true,  "Show forecast zone", group = grpF)
showPanel = input.bool(true,  "Show dashboard",     group = grpF)
bullCol   = input.color(color.teal, "Bullish", group = grpF, inline = "c")
bearCol   = input.color(color.red,  "Bearish", group = grpF, inline = "c")

grpG         = "Alerts"
enableAlerts = input.bool(true, "Enable alerts (use 'Any alert() function call')", group = grpG,
     tooltip = "Fires on: new wave, count flip, invalidation breach, forecast-zone entry.")

// ============================================================================
//  HELPERS
// ============================================================================
// Score 0..100: 100 when val == target, decaying linearly to 0 at +/- tol.
f_near(float val, float target, float tol) =>
    float d = math.abs(val - target)
    math.max(0.0, 100.0 * (1.0 - d / tol))

// Maintain an alternating ZigZag pivot series (by reference). aR/aV carry
// per-pivot context (RSI, relative volume) kept in sync with price.
addPivot(array<float> aP, array<int> aB, array<int> aD, array<float> aR, array<float> aV, float price, int b, int dir, float rval, float vval, int cap) =>
    int n = array.size(aD)
    if n == 0
        array.push(aP, price)
        array.push(aB, b)
        array.push(aD, dir)
        array.push(aR, rval)
        array.push(aV, vval)
    else
        int lastDir = array.get(aD, n - 1)
        if dir == lastDir
            // same direction in a row: keep only the more extreme pivot
            float lastP = array.get(aP, n - 1)
            bool replace = dir == 1 ? price > lastP : price < lastP
            if replace
                array.set(aP, n - 1, price)
                array.set(aB, n - 1, b)
                array.set(aR, n - 1, rval)
                array.set(aV, n - 1, vval)
        else
            array.push(aP, price)
            array.push(aB, b)
            array.push(aD, dir)
            array.push(aR, rval)
            array.push(aV, vval)
    while array.size(aD) > cap
        array.shift(aP)
        array.shift(aB)
        array.shift(aD)
        array.shift(aR)
        array.shift(aV)

// ============================================================================
//  STRUCTURE  (confirmed swings)
// ============================================================================
var array<float> zzP = array.new<float>()   // pivot price
var array<int>   zzB = array.new<int>()      // pivot bar_index
var array<int>   zzD = array.new<int>()      // +1 = swing high, -1 = swing low
var array<float> zzR = array.new<float>()    // RSI at pivot (wave energy)
var array<float> zzV = array.new<float>()    // relative volume at pivot (wave energy)

rsi14  = ta.rsi(close, 14)
relVol = volume / math.max(ta.sma(volume, 20), 1)   // 1+ = above-average volume
srcHi  = pivMode == "Bodies (Close)" ? close : high
srcLo  = pivMode == "Bodies (Close)" ? close : low
ph   = ta.pivothigh(srcHi, pivLen, pivLen)
pl   = ta.pivotlow(srcLo, pivLen, pivLen)
pbar = bar_index - pivLen

if not na(ph)
    addPivot(zzP, zzB, zzD, zzR, zzV, ph, pbar, 1, rsi14[pivLen], relVol[pivLen], maxPiv)
if not na(pl)
    addPivot(zzP, zzB, zzD, zzR, zzV, pl, pbar, -1, rsi14[pivLen], relVol[pivLen], maxPiv)

// ---- calibration data: distribution of how deeply each swing retraces the
//      prior swing on THIS instrument (drives the forecast zone) ----
var array<float> retr   = array.new<float>()
var int          lastSz = 0
int curSz = array.size(zzP)
if curSz > lastSz and curSz >= 3
    float legNew = math.abs(array.get(zzP, curSz - 1) - array.get(zzP, curSz - 2))
    float legPrv = math.abs(array.get(zzP, curSz - 2) - array.get(zzP, curSz - 3))
    if legPrv > 0
        array.push(retr, legNew / legPrv)
        if array.size(retr) > 200
            array.shift(retr)
lastSz := curSz

// ============================================================================
//  CONTEXT  (regime classification, runs every bar)
// ============================================================================
[diP, diM, adx] = ta.dmi(adxLen, adxLen)
atr    = ta.atr(14)
atrAvg = ta.sma(atr, 50)
bool   regimeTrend = adx > adxTrend
string regime = regimeTrend ? "Trending" : (atr < atrAvg * 0.8 ? "Compression" : "Ranging")

// ============================================================================
//  STATE (drawing handles)
// ============================================================================
var array<label> wLabels = array.new<label>()
var array<line>  wLines  = array.new<line>()
var line  projLine = na
var box  fzoneOut = na
var box  fzoneIn  = na
var table panel = na
var string prevPos = ""
var int    prevFam = -1

// ============================================================================
//  CANDIDATE TYPES + STRUCTURE SCORERS
//  Each scorer maps a slice of the pivot series to a labelled wave hypothesis
//  with a 0..100 score, hard-rule pass/fail, current position, and a target.
// ============================================================================
type Cand
    string typ
    float  sc
    bool   ok
    string pos
    float  inv
    float  tgt
    int    s        // start pivot index (wave 0)
    int    n        // pivots consumed
    bool   bull
    int    fam      // 1 = impulse family, 0 = corrective family
    float  energy   // wave-energy / momentum sub-score (0..100)

// Impulse / impulse-in-progress.  n = 3..6 (forming W3 / W4 / W5 / complete).
f_impulse(array<float> P, array<int> D, array<float> R, array<float> V, int e, int n, float wf, float wp, float wm) =>
    int s = e - (n - 1)
    float sc = 0.0
    bool  ok = false
    string pos = "-"
    float inv = na
    float tgt = na
    bool  bull = true
    float energy = 50.0
    if s >= 0
        bull := array.get(D, s) == -1
        float p0 = array.get(P, s)
        float p1 = array.get(P, s + 1)
        float w1 = math.abs(p1 - p0)
        float p2 = n >= 3 ? array.get(P, s + 2) : na
        float p3 = n >= 4 ? array.get(P, s + 3) : na
        float p4 = n >= 5 ? array.get(P, s + 4) : na
        float p5 = n >= 6 ? array.get(P, s + 5) : na
        float w2 = n >= 3 ? math.abs(p2 - p1) : na
        float w3 = n >= 4 ? math.abs(p3 - p2) : na
        float w4 = n >= 5 ? math.abs(p4 - p3) : na
        float w5 = n >= 6 ? math.abs(p5 - p4) : na
        bool r1 = n >= 3 ? (bull ? p2 > p0 : p2 < p0) : true
        bool r2 = n >= 6 ? not (w3 < w1 and w3 < w5) : true
        bool r3 = n >= 5 ? (bull ? p4 > p1 : p4 < p1) : true
        ok := r1 and r2 and r3
        float fsum = 0.0
        int   fcnt = 0
        if n >= 3
            fsum += f_near(w2 / w1, 0.55, 0.45)
            fcnt += 1
        if n >= 4
            fsum += f_near(w3 / w1, 1.618, 1.0)
            fcnt += 1
        if n >= 5
            fsum += f_near(w4 / w3, 0.382, 0.40)
            fcnt += 1
        if n >= 6
            fsum += f_near(w5 / w1, 1.0, 0.70)
            fcnt += 1
        float fib  = fcnt > 0 ? fsum / fcnt : 50.0

        // ---- proportion + ALTERNATION (waves 2 and 4 must differ in form) ----
        float propBase = (n >= 4 and w3 >= w1) ? 100.0 : 65.0
        float prop = propBase
        if n >= 5
            float retr2 = w2 / w1            // wave-2 retracement of wave 1
            float retr4 = w4 / w3            // wave-4 retracement of wave 3
            float altScore = math.min(100.0, math.abs(retr2 - retr4) / 0.30 * 100.0)  // ~0.3 apart = ideal
            prop := (propBase + altScore) / 2.0

        // ---- wave energy: per-wave momentum (RSI) + volume confirmation ----
        // A real impulse thrusts hardest on wave 3, in the trend's direction,
        // on elevated volume; wave 5 should not exceed wave 3's momentum.
        float rEnd1 = array.get(R, s + 1)
        float rEnd3 = n >= 4 ? array.get(R, s + 3) : na
        float rEnd5 = n >= 6 ? array.get(R, s + 5) : na
        float vEnd1 = array.get(V, s + 1)
        float vEnd3 = n >= 4 ? array.get(V, s + 3) : na
        if n >= 4
            bool w3dir    = bull ? rEnd3 > 52 : rEnd3 < 48          // thrust in trend direction
            bool w3strong = math.abs(rEnd3 - 50) >= math.abs(rEnd1 - 50)   // stronger than wave 1
            energy := (w3dir and w3strong) ? 100.0 : (w3dir or w3strong) ? 70.0 : 35.0
            if n >= 6
                bool w5healthy = math.abs(rEnd5 - 50) <= math.abs(rEnd3 - 50)  // W5 not stronger than W3
                energy := energy * (w5healthy ? 1.0 : 0.75)
            // volume confirmation (skipped if symbol has no volume)
            if not na(vEnd3) and not na(vEnd1) and vEnd3 > 0
                float volScore = (vEnd3 >= vEnd1 and vEnd3 > 1.0) ? 100.0 : (vEnd3 >= vEnd1 or vEnd3 > 1.0) ? 70.0 : 40.0
                energy := energy * 0.7 + volScore * 0.3
        sc := (fib * wf + prop * wp + energy * wm) / math.max(1.0, wf + wp + wm)
        if not ok
            sc := sc * 0.15
        pos := n == 3 ? "Wave 3 forming" : n == 4 ? "Wave 4 forming" : n == 5 ? "Wave 5 forming" : "Impulse complete"
        inv := p1
        tgt := n == 3 ? (bull ? p2 + w1 * 1.618 : p2 - w1 * 1.618) : n == 4 ? (bull ? p3 - w3 * 0.382 : p3 + w3 * 0.382) : n == 5 ? (bull ? p4 + w1 : p4 - w1) : (bull ? p5 - (p5 - p0) * 0.5 : p5 + (p0 - p5) * 0.5)
    Cand.new(typ = "Impulse", sc = sc, ok = ok, pos = pos, inv = inv, tgt = tgt, s = s, n = n, bull = bull, fam = 1, energy = energy)

// Zigzag correction (sharp).  n = 3 (in wave C) or 4 (ABC complete).
f_zigzag(array<float> P, array<int> D, int e, int n, float wf, float wp) =>
    int s = e - (n - 1)
    float sc = 0.0
    bool  ok = false
    string pos = "-"
    float inv = na
    float tgt = na
    bool  bull = true
    if s >= 0
        bull := array.get(D, s) == -1
        float p0 = array.get(P, s)
        float pa = array.get(P, s + 1)
        float pb = n >= 3 ? array.get(P, s + 2) : na
        float pc = n >= 4 ? array.get(P, s + 3) : na
        float A = math.abs(pa - p0)
        float B = n >= 3 ? math.abs(pb - pa) : na
        float C = n >= 4 ? math.abs(pc - pb) : na
        float fsum = 0.0
        int   fcnt = 0
        if n >= 3
            fsum += f_near(B / A, 0.55, 0.45)
            fcnt += 1
        if n >= 4
            fsum += f_near(C / A, 1.0, 0.70)
            fcnt += 1
        sc := fcnt > 0 ? fsum / fcnt : 50.0
        ok := n >= 3 ? (bull ? pb < pa : pb > pa) : true
        if not ok
            sc := sc * 0.2
        pos := n == 3 ? "Wave C forming" : "ABC complete"
        inv := p0
        tgt := n == 3 ? (bull ? pb + A : pb - A) : na
    Cand.new(typ = "Zigzag", sc = sc, ok = ok, pos = pos, inv = inv, tgt = tgt, s = s, n = n, bull = bull, fam = 0, energy = 50.0)

// Flat correction.  B retraces most of A; C ~ A.  n = 4.
f_flat(array<float> P, array<int> D, int e, float wf, float wp) =>
    int s = e - 3
    float sc = 0.0
    bool  ok = false
    float inv = na
    bool  bull = true
    if s >= 0
        bull := array.get(D, s) == -1
        float p0 = array.get(P, s)
        float pa = array.get(P, s + 1)
        float pb = array.get(P, s + 2)
        float pc = array.get(P, s + 3)
        float A = math.abs(pa - p0)
        float B = math.abs(pb - pa)
        float C = math.abs(pc - pb)
        float fb = f_near(B / A, 1.0, 0.35)
        float fc = f_near(C / A, 1.0, 0.50)
        sc := (fb + fc) / 2.0
        ok := B >= A * 0.8
        if not ok
            sc := sc * 0.2
        inv := p0
    Cand.new(typ = "Flat", sc = sc, ok = ok, pos = "complete", inv = inv, tgt = na, s = s, n = 4, bull = bull, fam = 0, energy = 50.0)

// Contracting triangle (A-B-C-D-E).  n = 6.
f_triangle(array<float> P, array<int> D, int e, float wf, float wp) =>
    int s = e - 5
    float sc = 0.0
    bool  ok = false
    float inv = na
    float tgt = na
    bool  bull = true
    if s >= 0
        bull := array.get(D, s) == -1
        float l1 = math.abs(array.get(P, s + 1) - array.get(P, s))
        float l2 = math.abs(array.get(P, s + 2) - array.get(P, s + 1))
        float l3 = math.abs(array.get(P, s + 3) - array.get(P, s + 2))
        float l4 = math.abs(array.get(P, s + 4) - array.get(P, s + 3))
        float l5 = math.abs(array.get(P, s + 5) - array.get(P, s + 4))
        int dec = 0
        dec += (l2 < l1 ? 1 : 0)
        dec += (l3 < l2 ? 1 : 0)
        dec += (l4 < l3 ? 1 : 0)
        dec += (l5 < l4 ? 1 : 0)
        sc := dec / 4.0 * 100.0
        ok := dec >= 3
        if not ok
            sc := sc * 0.2
        inv := array.get(P, s)
        float pe = array.get(P, s + 5)
        tgt := bull ? pe + l1 : pe - l1
    Cand.new(typ = "Triangle", sc = sc, ok = ok, pos = "Wave E", inv = inv, tgt = tgt, s = s, n = 6, bull = bull, fam = 0, energy = 50.0)

// Index of the highest-scoring candidate, excluding up to two indices.
f_argmax(array<Cand> cs, int ex1, int ex2) =>
    int best = -1
    float bestSc = -1.0
    if array.size(cs) > 0
        for i = 0 to array.size(cs) - 1
            if i != ex1 and i != ex2
                float sv = array.get(cs, i).sc
                if sv > bestSc
                    bestSc := sv
                    best := i
    best

// Build + regime-tilt the full candidate set (shared by the resolver and tracker).
f_build(array<float> P, array<int> D, array<float> R, array<float> V, int sz, float wf, float wp, float wm, bool trend) =>
    array<Cand> cs = array.new<Cand>()
    int e = sz - 1
    if sz >= 3
        array.push(cs, f_impulse(P, D, R, V, e, 3, wf, wp, wm))
    if sz >= 4
        array.push(cs, f_impulse(P, D, R, V, e, 4, wf, wp, wm))
    if sz >= 5
        array.push(cs, f_impulse(P, D, R, V, e, 5, wf, wp, wm))
    if sz >= 6
        array.push(cs, f_impulse(P, D, R, V, e, 6, wf, wp, wm))
    if sz >= 3
        array.push(cs, f_zigzag(P, D, e, 3, wf, wp))
    if sz >= 4
        array.push(cs, f_zigzag(P, D, e, 4, wf, wp))
    if sz >= 4
        array.push(cs, f_flat(P, D, e, wf, wp))
    if sz >= 6
        array.push(cs, f_triangle(P, D, e, wf, wp))
    float prImp = trend ? 0.60 : 0.40
    if array.size(cs) > 0
        for i = 0 to array.size(cs) - 1
            Cand c = array.get(cs, i)
            float pr = c.fam == 1 ? prImp : (1.0 - prImp)
            c.sc := c.sc * (0.6 + 0.6 * pr)
    cs

// Empirical hit-rate for the confidence bucket of `cf`; na until enough samples.
f_calib(array<int> h, array<int> t, float cf, int minN) =>
    int bk  = math.min(4, math.max(0, int(cf / 20)))
    int tot = array.get(t, bk)
    int hit = array.get(h, bk)
    tot >= minN ? hit / tot * 100.0 : na

// ============================================================================
//  OUTCOME TRACKING & PROBABILITY CALIBRATION (runs every bar)
//  At each new pivot, log the best count's forward prediction (target,
//  invalidation, confidence). On every bar, check open predictions: did price
//  reach target before invalidation?  Bucket the outcomes by confidence so the
//  displayed confidence can be mapped to a MEASURED success rate.
// ============================================================================
var array<float> calTgt  = array.new<float>()
var array<float> calInv  = array.new<float>()
var array<float> calConf = array.new<float>()
var array<int>   calDir  = array.new<int>()
var array<int>   bHit = array.new<int>(5, 0)
var array<int>   bTot = array.new<int>(5, 0)
var int lastSzCal = 0

// (1) log a forward prediction whenever a new pivot confirms
int szCal = array.size(zzP)
if szCal > lastSzCal and szCal >= 4
    array<Cand> cc = f_build(zzP, zzD, zzR, zzV, szCal, wFib, wProp, wMom, regimeTrend)
    int bi = f_argmax(cc, -1, -1)
    if bi >= 0
        Cand cb = array.get(cc, bi)
        if not na(cb.tgt) and not na(cb.inv) and cb.sc > 0
            array.push(calTgt, cb.tgt)
            array.push(calInv, cb.inv)
            array.push(calConf, cb.sc)
            array.push(calDir, cb.bull ? 1 : -1)
            while array.size(calTgt) > 60
                array.shift(calTgt)
                array.shift(calInv)
                array.shift(calConf)
                array.shift(calDir)
lastSzCal := szCal

// (2) resolve open predictions against this bar's range
if array.size(calTgt) > 0
    int i = array.size(calTgt) - 1
    while i >= 0
        float t  = array.get(calTgt, i)
        float v  = array.get(calInv, i)
        float cf = array.get(calConf, i)
        int   dr = array.get(calDir, i)
        bool hitT = dr == 1 ? high >= t : low <= t
        bool hitV = dr == 1 ? low <= v : high >= v
        if hitT or hitV
            int bk = math.min(4, math.max(0, int(cf / 20)))
            array.set(bTot, bk, array.get(bTot, bk) + 1)
            if hitT and not hitV
                array.set(bHit, bk, array.get(bHit, bk) + 1)
            array.remove(calTgt, i)
            array.remove(calInv, i)
            array.remove(calConf, i)
            array.remove(calDir, i)
        i := i - 1

if barstate.islast and array.size(zzP) >= 4
    int sz = array.size(zzP)
    int e  = sz - 1

    // ---- generate + tilt competing interpretations ----
    array<Cand> cands = f_build(zzP, zzD, zzR, zzV, sz, wFib, wProp, wMom, regimeTrend)

    // ---- resolve primary / secondary / tertiary ----
    int i1 = f_argmax(cands, -1, -1)
    int i2 = f_argmax(cands, i1, -1)
    int i3 = f_argmax(cands, i1, i2)

    if i1 >= 0
        Cand  c1 = array.get(cands, i1)
        float s1 = c1.sc
        float s2 = i2 >= 0 ? array.get(cands, i2).sc : 0.0
        float s3 = i3 >= 0 ? array.get(cands, i3).sc : 0.0
        float tot   = s1 + s2 + s3
        float prob1 = tot > 0 ? s1 / tot * 100.0 : 0.0
        float prob2 = tot > 0 ? s2 / tot * 100.0 : 0.0
        float prob3 = tot > 0 ? s3 / tot * 100.0 : 0.0

        float confidence   = c1.sc
        bool  cleanCount   = confidence >= minConf
        bool  bull         = c1.bull
        color dirCol       = bull ? bullCol : bearCol
        float invalidation = c1.inv

        // ---- measured hit-rate for this confidence level ----
        int   calBk   = math.min(4, math.max(0, int(confidence / 20)))
        int   calN    = array.get(bTot, calBk)
        float calibHit = f_calib(bHit, bTot, confidence, minCalN)   // na until enough cases
        float effConf  = na(calibHit) ? confidence : calibHit        // measured rate when available

        // ---- wave-position resolver: stage from progress toward target ----
        float pLast = array.get(zzP, e)
        bool  isComplete = c1.pos == "Impulse complete" or c1.pos == "ABC complete" or c1.typ == "Flat" or c1.typ == "Triangle"
        float legNow = math.abs(close - pLast)
        float legExp = na(c1.tgt) ? na : math.abs(c1.tgt - pLast)
        float prog   = (not na(legExp) and legExp > 0) ? legNow / legExp : 0.0
        string stage = isComplete ? "Complete" : prog < 0.33 ? "Early" : prog < 0.66 ? "Mid" : prog < 1.0 ? "Late" : "Extended"

        // ---- calibrated forecast zone, anchored to the primary count ----
        bool  calibrated = array.size(retr) >= minSamples
        float rIn  = calibrated ? array.percentile_linear_interpolation(retr, coneInPct)  : 0.50
        float rOut = calibrated ? array.percentile_linear_interpolation(retr, coneOutPct) : 0.618
        rIn  := math.min(rIn, 1.5)
        rOut := math.min(math.max(rOut, rIn), 2.0)
        float pStart    = array.get(zzP, c1.s)
        float coneInLv  = na
        float coneOutLv = na
        // project to the count's forward target when it has one (impulse-in-
        // progress, zigzag-C, triangle thrust, impulse-complete correction);
        // otherwise (no forward target) draw a retrace zone of the structure.
        if na(c1.tgt)
            float span = pLast - pStart
            coneInLv  := pLast - span * rIn
            coneOutLv := pLast - span * rOut
        else
            float reach = c1.tgt
            float band  = math.abs(reach - close) * 0.25
            coneInLv  := reach
            coneOutLv := reach > close ? reach - band : reach + band

        // ====================================================================
        //  DISPLAY
        // ====================================================================
        if array.size(wLabels) > 0
            for i = 0 to array.size(wLabels) - 1
                label.delete(array.get(wLabels, i))
            array.clear(wLabels)

        if showLbls
            for k = 0 to c1.n - 1
                int idx = c1.s + k
                if idx >= 0 and idx < sz
                    int dz = array.get(zzD, idx)
                    string txt = c1.typ == "Impulse" ? str.tostring(k) : c1.typ == "Triangle" ? (k == 0 ? "0" : k == 1 ? "A" : k == 2 ? "B" : k == 3 ? "C" : k == 4 ? "D" : "E") : (k == 0 ? "0" : k == 1 ? "A" : k == 2 ? "B" : "C")
                    label lb = label.new(array.get(zzB, idx), array.get(zzP, idx), txt, xloc.bar_index, yloc.price, color.new(dirCol, 0), dz == 1 ? label.style_label_down : label.style_label_up, color.white, size.small)
                    array.push(wLabels, lb)

        // wave-connecting lines (draw the actual structure, not just chips)
        if array.size(wLines) > 0
            for i = 0 to array.size(wLines) - 1
                line.delete(array.get(wLines, i))
            array.clear(wLines)
        if showLbls
            for k = 1 to c1.n - 1
                int ia = c1.s + k - 1
                int ib = c1.s + k
                if ia >= 0 and ib < sz
                    line ln = line.new(array.get(zzB, ia), array.get(zzP, ia), array.get(zzB, ib), array.get(zzP, ib), xloc.bar_index, color = color.new(dirCol, 20), width = 2)
                    array.push(wLines, ln)

        // projection line from last confirmed pivot to the target
        if not na(projLine)
            line.delete(projLine)
        if showCone and not na(c1.tgt)
            int lastIdx = c1.s + c1.n - 1
            projLine := line.new(array.get(zzB, lastIdx), array.get(zzP, lastIdx), bar_index + 20, c1.tgt, xloc.bar_index, color = color.new(dirCol, 25), width = 2, style = line.style_dashed)

        // forecast zone (outer light, inner emphasis)
        if not na(fzoneOut)
            box.delete(fzoneOut)
        if not na(fzoneIn)
            box.delete(fzoneIn)
        if showCone and not na(coneInLv) and not na(coneOutLv)
            fzoneOut := box.new(bar_index, math.max(coneInLv, coneOutLv), bar_index + 30, math.min(coneInLv, coneOutLv), border_color = color.new(dirCol, 100), bgcolor = color.new(dirCol, 90))
            float mt = syminfo.mintick * 4
            fzoneIn  := box.new(bar_index, coneInLv + mt, bar_index + 30, coneInLv - mt, border_color = color.new(dirCol, 40), bgcolor = color.new(dirCol, 70))

        // ---- market-structure confirmation (break of structure / change of character) ----
        // Independent evidence: does price action confirm the count's direction?
        float swH1 = na
        float swH2 = na
        float swL1 = na
        float swL2 = na
        for k = sz - 1 to 0
            int   d  = array.get(zzD, k)
            float pz = array.get(zzP, k)
            if d == 1
                if na(swH1)
                    swH1 := pz
                else if na(swH2)
                    swH2 := pz
            else
                if na(swL1)
                    swL1 := pz
                else if na(swL2)
                    swL2 := pz
            if not na(swH2) and not na(swL2)
                break
        bool uptrend   = not na(swH2) and not na(swL2) and swH1 > swH2 and swL1 > swL2
        bool downtrend = not na(swH2) and not na(swL2) and swH1 < swH2 and swL1 < swL2
        string structTxt = "neutral"
        if not na(swH1) and not na(swL1)
            if uptrend
                structTxt := close > swH1 ? "BOS up" : close < swL1 ? "CHoCH down" : "uptrend HH/HL"
            else if downtrend
                structTxt := close < swL1 ? "BOS down" : close > swH1 ? "CHoCH up" : "downtrend LH/LL"
            else
                structTxt := close > swH1 ? "BOS up" : close < swL1 ? "BOS down" : "ranging"
        bool  sConfirm   = (structTxt == "BOS up" and bull) or (structTxt == "BOS down" and not bull)
        bool  sContra    = (structTxt == "CHoCH down" and bull) or (structTxt == "CHoCH up" and not bull)
        float structMult = sConfirm ? 1.10 : sContra ? 0.85 : 1.0

        // ---- Opportunity score = (measured) confidence modulated by reward:risk ----
        float reward  = na(c1.tgt) ? na : math.abs(c1.tgt - close)
        float risk    = na(invalidation) ? na : math.abs(close - invalidation)
        float rr      = (not na(reward) and not na(risk) and risk > 0) ? reward / risk : na
        float rrScore = na(rr) ? 0.0 : math.min(rr, 3.0) / 3.0 * 100.0
        float opp     = na(rr) ? effConf : effConf * (0.4 + 0.6 * rrScore / 100.0)
        opp := cleanCount ? opp : opp * 0.5            // a non-clean count is never a strong opportunity
        opp := math.min(100.0, opp * structMult)        // structure confirms or contradicts
        color oppCol  = opp >= 60 ? bullCol : opp >= 40 ? color.new(color.orange, 0) : color.new(color.gray, 0)

        // ---- alerts (fire via "Any alert() function call") ----
        if enableAlerts
            bool invBreached = bull ? close < invalidation : close > invalidation
            bool inZone = not na(coneInLv) and not na(coneOutLv) and close <= math.max(coneInLv, coneOutLv) and close >= math.min(coneInLv, coneOutLv)
            if not na(invalidation) and invBreached
                alert("EW Engine " + syminfo.ticker + ": invalidation breached (" + str.tostring(math.round_to_mintick(close)) + ") — " + c1.typ + " count at risk", alert.freq_once_per_bar)
            if inZone
                alert("EW Engine " + syminfo.ticker + ": price entered forecast zone for " + c1.pos, alert.freq_once_per_bar)
            if barstate.isconfirmed
                if prevPos != "" and prevPos != c1.pos
                    alert("EW Engine " + syminfo.ticker + ": new wave — " + c1.pos + " (" + str.tostring(math.round(prob1)) + "%, conf " + str.tostring(math.round(confidence)) + ")", alert.freq_once_per_bar)
                if prevFam != -1 and prevFam != c1.fam
                    alert("EW Engine " + syminfo.ticker + ": count flipped to " + c1.typ, alert.freq_once_per_bar)
                prevPos := c1.pos
                prevFam := c1.fam

        // dashboard
        if showPanel
            if na(panel)
                panel := table.new(position.top_right, 2, 17, border_width = 1, frame_width = 1, frame_color = color.gray)
            color  statusCol = cleanCount ? bullCol : color.new(color.orange, 0)
            string sec = i2 >= 0 ? (array.get(cands, i2).typ + " " + array.get(cands, i2).pos + " " + str.tostring(math.round(prob2)) + "%") : "-"
            string ter = i3 >= 0 ? (array.get(cands, i3).typ + " " + str.tostring(math.round(prob3)) + "%") : "-"
            string rrTxt  = na(rr) ? "" : (rr > 5 ? "  (R:R 5+)" : "  (R:R " + str.tostring(rr, "#.#") + ")")
            string oppTxt = str.tostring(math.round(opp)) + "/100" + rrTxt
            string calTxt = na(calibHit) ? ("learning (n=" + str.tostring(calN) + ")") : (str.tostring(math.round(calibHit)) + "% hit (n=" + str.tostring(calN) + ")")
            string engTxt = c1.fam == 1 ? (str.tostring(math.round(c1.energy)) + "/100 " + (c1.energy >= 70 ? "(W3 thrust)" : c1.energy >= 45 ? "(weak)" : "(no thrust)")) : "n/a (corrective)"
            table.cell(panel, 0, 0, "ELLIOTT WAVE ENGINE", text_color = color.white, bgcolor = color.new(dirCol, 0), text_size = size.small)
            table.cell(panel, 1, 0, bull ? "BULL" : "BEAR", text_color = color.white, bgcolor = color.new(dirCol, 0), text_size = size.small)
            table.cell(panel, 0, 1,  "Status",       text_color = color.gray)
            table.cell(panel, 1, 1,  cleanCount ? "Clean count" : "Low conf - stand aside", text_color = color.white, bgcolor = color.new(statusCol, 0), text_size = size.small)
            table.cell(panel, 0, 2,  "Opportunity",  text_color = color.gray)
            table.cell(panel, 1, 2,  oppTxt, text_color = color.white, bgcolor = color.new(oppCol, 0), text_size = size.small)
            table.cell(panel, 0, 3,  "Primary",      text_color = color.gray)
            table.cell(panel, 1, 3,  c1.typ + " " + str.tostring(math.round(prob1)) + "%")
            table.cell(panel, 0, 4,  "Position",     text_color = color.gray)
            table.cell(panel, 1, 4,  c1.pos)
            table.cell(panel, 0, 5,  "Stage",        text_color = color.gray)
            table.cell(panel, 1, 5,  stage)
            table.cell(panel, 0, 6,  "Wave Energy",  text_color = color.gray)
            table.cell(panel, 1, 6,  engTxt)
            table.cell(panel, 0, 7,  "Secondary",    text_color = color.gray)
            table.cell(panel, 1, 7,  sec)
            table.cell(panel, 0, 8,  "Tertiary",     text_color = color.gray)
            table.cell(panel, 1, 8,  ter)
            table.cell(panel, 0, 9,  "Confidence",   text_color = color.gray)
            table.cell(panel, 1, 9,  str.tostring(math.round(confidence)) + " / 100")
            table.cell(panel, 0, 10, "Calibrated",   text_color = color.gray)
            table.cell(panel, 1, 10, calTxt, text_color = na(calibHit) ? color.gray : color.white, bgcolor = na(calibHit) ? na : color.new(dirCol, 30), text_size = size.small)
            table.cell(panel, 0, 11, "Regime",       text_color = color.gray)
            table.cell(panel, 1, 11, regime)
            table.cell(panel, 0, 12, "Structure",     text_color = color.gray)
            table.cell(panel, 1, 12, structTxt + (sConfirm ? " (confirms)" : sContra ? " (warning)" : ""), text_color = sConfirm ? bullCol : sContra ? color.new(color.orange, 0) : color.gray)
            table.cell(panel, 0, 13, "Hard rules",   text_color = color.gray)
            table.cell(panel, 1, 13, c1.ok ? "PASS" : "FAIL", text_color = c1.ok ? bullCol : bearCol)
            table.cell(panel, 0, 14, "Zone basis",   text_color = color.gray)
            table.cell(panel, 1, 14, calibrated ? ("calibrated " + str.tostring(array.size(retr)) + " sw") : "default")
            table.cell(panel, 0, 15, "Target",       text_color = color.gray)
            table.cell(panel, 1, 15, na(c1.tgt) ? "-" : str.tostring(math.round_to_mintick(c1.tgt)))
            table.cell(panel, 0, 16, "Invalidation", text_color = color.gray)
            table.cell(panel, 1, 16, na(invalidation) ? "-" : str.tostring(math.round_to_mintick(invalidation)))
````
