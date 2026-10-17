# Permutation Entropy  Complexity Oscillator

- url: https://www.tradingview.com/script/62Dl3jmk-Permutation-Entropy-Complexity-Oscillator/
- type: indicator
- pine_id: PUB;61c4a30bd7264b8cb902eda956f12dfd
- version: 3.0

## Description

Permutation Entropy — Complexity Oscillator 

What this script does

This is a complexity oscillator: it measures, on a 0–1 scale, how random versus structured recent price action is — not which direction price is going, but whether there is any exploitable order to go on. It reads the order of successive moves (not their size): every three consecutive prices form one of six up/down shapes ("ordinal patterns"), and the oscillator measures how evenly those shapes are spread over a rolling window. Near 1, all shapes are equally likely — the tape is effectively random. Near 0, a few shapes dominate — the tape is structured and, in principle, more predictable.

Why these components are combined (mashup justification)

This is not several indicators shown side by side. There is exactly one plotted value — the normalized ordinal-pattern entropy — and every other element is a decision-support layer built on that single value:

The entropy engine is the core. Conventional price-level oscillators tell you where price is in its range; none of them tell you whether the range is even worth trading. Ordinal-pattern entropy is amplitude-free and noise-robust, so it isolates one orthogonal question — is there structure right now? — that the price-level family cannot answer.
The predictable / random thresholds classify the reading into a regime (structured / mixed / random). They don't add a second indicator; they interpret the one oscillator.
The statistical-complexity measure (complexity–entropy plane) is computed from the same ordinal-pattern counts and answers the question entropy cannot: low entropy alone can be genuinely structured or trivially degenerate (near-periodic). Pairing entropy with complexity separates "richly structured and potentially exploitable" from "low-entropy but trivial," so a signal only treats the tape as structured when both agree.
The momentum sign does nothing on its own — it only sets the direction of an already-armed regime signal. The bet is "a structured tape tends to keep doing what it's doing"; momentum just says which way that is.
The calibration harness is the reason the rest is trustworthy. It logs every signal the oscillator arms and, a fixed horizon later, checks whether price actually extended ≥ k×ATR in that direction — then reports Hit %, the unconditional Base %, and the Edge (Hit − Base).


Every part answers one question about the same entropy reading, which is why they belong in one script rather than as separate studies.

What makes it original

Two things. First, it brings an information-theoretic structure measure — usually seen only in research, not on charts — into a live, bounded oscillator with regime bands and a clean visual. Second, and more importantly, it does not assume the common claim that "low entropy means predictable, tradeable price." It tests that claim, live, on your instrument, with the built-in calibration harness. If low-entropy signals don't actually precede a forward move on your symbol and timeframe, the Edge row shows it plainly — often at or below zero. That honesty layer, not the entropy calculation alone, is the contribution.

How to use it


Add to a chart. Defaults target intraday index futures (e.g. NSE NIFTY); for other markets simply change the chart, or set the Price source input (group 01) — you can even feed it another indicator's output.
Read the regime at a glance from the background tint: green = genuine structure (low entropy and high complexity → the actionable state), amber = low-complexity / trivial low entropy (caution), grey = random / efficient tape (stand aside), no tint = mixed (wait). The line carries the same colour, with a bright line confirming genuine structure; the dashboard "Tape (plane)" chip shows the same state in words.
Optionally enable the statistical-complexity overlay (group 05) to see the complexity–entropy plane directly: it peaks at intermediate entropy where structure is richest and falls toward zero for both pure noise and trivial tapes. The dashboard shows the live complexity value and a ● when it clears the genuine-structure threshold.
Tie-robustness and delay τ (group 02): on discrete / tick-quantised instruments (index futures, where equal consecutive prints are common) equal values bias ordinal-pattern entropy toward false structure. The tie-robust dither (on by default) and an optional delay τ > 1 mitigate this; τ also probes a coarser timescale. Set τ = 1 and tie-robust off to reproduce the plain estimator.
Triangles mark the moment a predictable regime starts, with direction set by recent momentum — points to investigate, not automatic entries. With the complexity gate on (default), a signal only arms when complexity also confirms genuine structure; turn it off to A/B that choice against the entropy-only signal in the Edge row.
Read the Edge row before trusting the signal. A positive Edge means structured starts preceded a forward move more often than chance here; near or below zero means low entropy is not buying you predictability on this instrument.
Window length, smoothing, embedding delay, the two entropy thresholds, the complexity threshold, the momentum length, and the calibration horizon / threshold are all configurable.


Limitations

Entropy describes the tape's structure, not its direction — low entropy can precede a clean trend or a clean oscillation. The momentum-direction bet is one testable interpretation, not a law; the calibration row is there precisely so you don't take it on faith.
Statistics are in-sample, close-to-close, without costs — a study aid, not a backtest.
The reading needs a full window before it is meaningful (the panel shows "warm" until then).
This is an analytical complexity study. It issues no automated buy/sell instructions and is not a strategy.


Concept credit

Permutation entropy / ordinal-pattern analysis — Christoph Bandt and Bernd Pompe (2002).
Information entropy — Claude E. Shannon (1948).
Statistical complexity (the complexity–entropy plane) — the MPR statistical-complexity measure of P. W. Lamberti, M. T. Martín, A. Plastino and O. A. Rosso, applied to markets via the complexity–entropy causality plane of L. Zunino, M. Zanin, B. M. Tabak, D. G. Pérez and O. A. Rosso (2010).
Tie / equal-value bias in ordinal patterns — informed by the work of D. Cuesta-Frau and colleagues (2018).


The implementation, the regime/threshold logic, the complexity gate, the tie-robust dither, the calibration harness and the packaging are original.

Disclaimer

For research and educational purposes only. This script is not financial advice, not a recommendation, and not a guarantee of future results. Indicators describe price behaviour; they do not predict the future. Trading carries risk of loss. Test on out-of-sample data and make your own decisions. The author accepts no liability for any use of this script.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ════════════════════════════════════════════════════════════════════════
//  © Market_Logic_India                                          MPL-2.0
//  PERMUTATION ENTROPY  —  Complexity Oscillator                       v2.0
// ------------------------------------------------------------------------
//  v2.0 — WHAT'S NEW
//   • MULTISCALE permutation entropy — the tape is coarse-grained (block-
//     averaged) across scales and the entropy is read at each, so structure
//     that lives at a SLOWER scale than the bar isn't hidden by fine noise.
//     The multiscale average (MPE) is a scale-robust complexity read.
//   • HARNESS+ — the calibration adds a uniqueness-weighted EFFECTIVE sample
//     size, an IN-SAMPLE / OUT-OF-SAMPLE split (the OOS edge is the one to
//     trust) and a multiple-testing deflated significance bar.
//   • Added the MPL licence header; resolved conditional stateful ta.* calls
//     (the tie-jitter and the smoothing EMAs were sitting behind a ternary).
//   • Weighted PE, statistical complexity and the forbidden-pattern count are
//     retained; the whole entropy engine is now one reusable function.
//  WHAT IT IS
//  A measure of how RANDOM versus STRUCTURED recent price is, plotted 0–1. It
//  reads the ORDER (not the size) of successive moves: every three consecutive
//  bars form one of six up/down shapes ("ordinal patterns"), and the oscillator
//  measures how evenly those shapes are spread over a window. Near 1 = all shapes
//  equally likely = effectively random / unpredictable; near 0 = a few shapes
//  dominate = structured / more predictable. A study of market COMPLEXITY — not a
//  directional signal and not a strategy.
//
//  WHY IT MATTERS / WHAT'S DIFFERENT
//  Price-level oscillators can't tell you whether the tape is even worth trading.
//  This reading is amplitude-free and robust to noise, so it isolates one thing:
//  is there exploitable order right now? Low-entropy stretches are where momentum
//  and pattern methods have their best chance; high-entropy stretches are where
//  they degrade to coin-flips. This script makes that read live and then TESTS
//  whether "low entropy → the recent move extends" holds on your instrument,
//  rather than assuming it.
//
//  HOW IT WORKS
//   1. For each window position, three consecutive prices are ranked into one of
//      6 ordinal patterns (embedding dimension 3).
//   2. The pattern frequencies give a normalized information-entropy on 0–1.
//   3. A signal arms when entropy drops THROUGH the "predictable" threshold; its
//      direction is the sign of recent momentum (a structured market is bet to
//      keep going).
//   4. The harness logs each signal and, a fixed horizon later, checks whether
//      price extended ≥ k×ATR in that direction — reporting Hit %, Base % and
//      Edge. If Edge ≈ 0, low entropy isn't buying you predictability here.
//
//  HOW THE PARTS WORK TOGETHER  (mashup rationale)
//  This is not several indicators shown side by side. There is ONE plotted value —
//  the normalized ordinal-pattern entropy. Everything else is a decision-support
//  layer built ON that single value: the predictable / random thresholds classify
//  the regime; the momentum sign only sets the direction of an already-armed
//  regime signal; the calibration harness scores those signals against realized
//  forward moves. Each part answers one question about the same entropy reading,
//  which is why they belong in one script rather than as separate studies.
//
//  UNIVERSAL ACROSS MARKETS  (configurable data source)
//  The price source is a user input, so the engine can be pointed at any series —
//  including another indicator's plot — on any symbol or timeframe. Defaults
//  target intraday index futures (e.g. NSE NIFTY); change only the chart to use
//  it elsewhere.
//
//  HONESTY
//  Entropy describes the tape's STRUCTURE, not its DIRECTION — low entropy can
//  precede a trend OR a clean oscillation, so the signal here is one testable
//  interpretation, not a law. Read the Edge row. Statistics are in-sample,
//  close-to-close, without costs — a study aid, not a backtest.
//
//  CONCEPT CREDIT is given in full in the published description.
//
//  DISCLAIMER
//  For research and education only. NOT financial advice, NOT a recommendation,
//  NOT a guarantee of future results. Do your own research and manage your risk.
// ════════════════════════════════════════════════════════════════════════
indicator("Permutation Entropy — Complexity Oscillator", "Perm Entropy", overlay=false, max_labels_count=120, max_bars_back=1300)

// ═════ Z · IDENTITY & EXPORTS ════════════════════════════════════════════════════════════════
gZ = "Z · Identity & exports"
showId  = input.bool(true, "Show identity strip", group = gZ)
showEXP = input.bool(true, "Publish EXP_* outputs (Data Window)", group = gZ, tooltip = "Generic export bus: surfaces in the Data Window and in other scripts via input.source().")
var table idT = table.new(position.bottom_center, 1, 1, force_overlay = true)
if barstate.islast and showId
    bool idDark = (0.299 * color.r(chart.bg_color) + 0.587 * color.g(chart.bg_color) + 0.114 * color.b(chart.bg_color)) < 140
    table.cell(idT, 0, 0, "PERM ENTROPY · " + syminfo.ticker + " · " + timeframe.period, text_size = size.tiny, text_color = idDark ? color.white : color.black, bgcolor = color.new(idDark ? color.black : color.white, 15))

// ───────────────────────────── INPUTS ──────────────────────────────────
g0 = "01 · Data & Source"
src = input.source(close, "Price source", group=g0, tooltip="Series the ordinal patterns are read from. Works on ANY symbol/market.")

g1 = "02 · Entropy Estimate"
peLen  = input.int(60, "Window (triples counted)", minval=20, maxval=300, group=g1, tooltip="How many three-bar shapes are tallied. Longer = steadier but slower to react.")
peSmooth = input.int(1, "Smoothing (EMA, 1 = off)", minval=1, maxval=20, group=g1)
thrMode = input.string("Absolute", "Threshold mode", options=["Adaptive (percentile)","Absolute"], group=g1, tooltip="ABSOLUTE (default): the fixed 0–1 thresholds below. ADAPTIVE: 'predictable' means the entropy is in the LOW end of its OWN recent range on this instrument — so a liquid index that sits at 0.90–0.98 still produces signals when it is relatively low, without hand-tuning a number. Switch to Adaptive if the absolute levels are rarely reached on your instrument.")
adaptWin = input.int(250, "Adaptive window (bars)", minval=50, maxval=1000, group=g1, tooltip="Adaptive mode: the recent history the entropy percentile is measured over.")
predPctLvl = input.float(25, "Predictable percentile (bottom %)", minval=5, maxval=50, step=1, group=g1, tooltip="Adaptive mode: entropy in the bottom this-% of its recent range = relatively low / structured.")
randPctLvl = input.float(75, "Random percentile (top %)", minval=50, maxval=95, step=1, group=g1, tooltip="Adaptive mode: entropy in the top (100 − this) % = relatively random.")
predThr = input.float(0.90, "Predictable below entropy (Absolute)", minval=0.3, maxval=1.0, step=0.01, group=g1, tooltip="Absolute mode only: below this normalized entropy the tape is treated as structured/predictable.")
randThr = input.float(0.95, "Random above entropy (Absolute)", minval=0.5, maxval=1.0, step=0.01, group=g1)
peDelay = input.int(1, "Embedding delay τ", minval=1, maxval=10, group=g1, tooltip="Spacing in bars between the three sampled prices. τ=1 reads consecutive bars; τ>1 probes a coarser timescale AND reduces ties on discrete / tick-quantised data — a documented source of bias in ordinal-pattern entropy. The window reaches 2·τ bars further back as τ grows.")
tieJitter = input.bool(true, "Tie-robust (break equal values)", group=g1, tooltip="Adds a sub-tick deterministic dither before ranking, so exact equal prices (common on discrete intraday instruments such as index futures) are not assigned an order by position — a known bias that makes the tape read as falsely structured. The dither is far smaller than one tick, so genuine orderings are never flipped.")
compThr = input.float(0.18, "Genuine-structure complexity ≥", minval=0.0, maxval=0.5, step=0.01, group=g1, tooltip="Statistical-complexity threshold on the complexity–entropy plane. Low entropy alone can be DEGENERATE / trivial; genuinely exploitable structure shows intermediate entropy with HIGH complexity. Calibrate this against the Edge row.")
useMulti = input.bool(true, "Multiscale entropy (MPE)", group=g1, tooltip="Also read the entropy on COARSE-GRAINED (block-averaged) versions of the tape across scales 1..N. Structure that lives at a slower scale than the bar isn't hidden by fine noise. The multiscale average (MPE) is a scale-robust complexity read shown on the panel.")
sMax     = input.int(5, "Max coarse-grain scale", minval=2, maxval=8, group=g1, tooltip="Highest block-average scale for the multiscale entropy. Larger reaches further back (needs more history).")

g2 = "03 · Signal"
momLen = input.int(10, "Momentum length (direction)", minval=2, group=g2, tooltip="Sign of price change over this many bars sets the bet direction when a predictable regime starts.")
showSig = input.bool(true, "Mark predictable-regime starts", group=g2)
gateByComplexity = input.bool(false, "Require genuine structure (complexity gate)", group=g2, tooltip="When ON, a signal arms only if statistical complexity is also above its threshold — i.e. the low-entropy reading is genuine structure, not a degenerate / trivial one. OFF by default (more signals); turn ON to demand genuine structure and A/B the Edge row.")

g4 = "04 · Calibration Harness"
calibOn = input.bool(true, "Run calibration", group=g4, tooltip="Logs every signal and, a fixed horizon later, checks whether price extended ≥ k×ATR in the signal direction. Reports Hit %, unconditional Base %, and Edge = Hit − Base.")
calHor  = input.int(10, "Forward horizon (bars)", minval=2, maxval=100, group=g4)
calMove = input.float(0.6, "Move threshold (x ATR)", minval=0.1, step=0.1, group=g4)
calAtrLen = input.int(14, "ATR length", minval=1, group=g4)
harTrainN = input.int(40, "HARNESS+ in-sample events (then OOS)", minval=10, group=g4, tooltip="First N resolved signals train (in-sample); every later one is scored OUT-OF-SAMPLE. The OOS edge is the trustworthy one.")
nTests    = input.int(2, "Edge significance · N tests (deflation)", minval=1, maxval=10, group=g4, tooltip="Raise the significance bar for the number of things tested (Bonferroni-style z).")

g5 = "05 · Display & Theme"
vizStyle = input.string("Gradient area + glow", "Visual style", options=["Gradient area + glow","Histogram","Line"], group=g5, tooltip="Gradient area + glow: filled area between the line and the predictable threshold, opacity scaling with how far the reading sits from that threshold, under a neon line — the at-a-glance default. Histogram: saturated columns. Line: glow line only.")
showComplexity = input.bool(false, "Plot statistical complexity", group=g5, tooltip="Overlays the statistical-complexity line. OFF by default because it sits on a different scale and would compress the entropy band — complexity is already read from the line colour (bright = genuine structure) and the panel. Turn on to study the complexity–entropy plane directly.")
colComp = input.color(#c77dff, "Complexity line", group=g5)
showPanel = input.bool(true, "Show readout panel", group=g5)
dashMode  = input.string("Compact", "Panel detail", options=["Compact","Pro"], group=g5, tooltip="Compact (default): the decision rows only — entropy, tape state, momentum, edge and multiscale. Pro: adds complexity, signal count, hit %, weighted-PE / forbidden, edge floor and the out-of-sample edge.")
showZones = input.bool(true, "Structured / random zone bands", group=g5, tooltip="Shade the predictable (structured) zone below the threshold and the random zone above it — the oscillator's over-sold / over-bought-style bands.")
showOverlay = input.bool(true, "Overlay signals on price (triangles)", group=g5, tooltip="Plot each structured-regime signal on the PRICE chart as a tiny directional triangle — green up = structured + up momentum, red down = structured + down momentum.")
panelPos  = input.string("Bottom Right", "Panel position", options=["Bottom Left","Bottom Right","Top Left","Top Right","Middle Right"], group=g5)
themeOpt  = input.string("Auto", "Theme", options=["Auto","Dark","Light"], group=g5, tooltip="Auto reads the chart background luminance so the panel stays legible on any colour scheme.")
colBull = input.color(#2ebd85, "Structured / bull", inline="cc", group=g5)
colBear = input.color(#f6465d, "Bear", inline="cc", group=g5)
colRand = input.color(#9aa3b2, "Random", group=g5)

// ───────────────────────────── ENGINE: ordinal-pattern entropy (d = 3) ──
f_pat(float v0, float v1, float v2) =>
    bool a = v0 < v1
    bool b = v1 < v2
    bool c = v0 < v2
    int p = a and b ? 0 : a and not b and c ? 1 : a and not b and not c ? 2 : not a and b and c ? 3 : not a and b and not c ? 4 : 5
    p
// tie-robust dithered source — sub-tick deterministic jitter that only breaks exact equalities
f_hash(int bi) =>
    float x = math.sin(bi * 12.9898) * 43758.5453
    x - math.floor(x)
float jitBase = ta.sma(math.abs(src - src[1]), 20)          // hoisted (stateful ta.* must not sit behind a ternary)
float jitEps = tieJitter ? (jitBase + syminfo.mintick) * 0.0005 : 0.0
float srcJ = src + (f_hash(bar_index) - 0.5) * jitEps

// complexity normalizer — maximum information divergence (delta vs uniform) over 6 patterns
f_divMax(float N) =>
    float a = (N + 1.0) / (2.0 * N)
    float b = 1.0 / (2.0 * N)
    (-a * math.log(a) - (N - 1.0) * b * math.log(b)) - math.log(N) / 2.0
float divMax = f_divMax(6.0)

// ORDINAL-PATTERN ENTROPY at a coarse-grain scale (scale = 1 → classic; > 1 → block-averaged tape).
// Returns [pe, weighted-pe, forbidden-count, complexity]. Pure loops (no stateful ta.*), so it is
// safe to call conditionally and at several scales for the multiscale average.
f_pe(int win, int delay, int scale) =>
    array<float> cnt  = array.new<float>(6, 0.0)
    array<float> cntW = array.new<float>(6, 0.0)
    float Wtot = 0.0
    for i = 0 to win - 1
        float a = 0.0
        float b = 0.0
        float c = 0.0
        if scale <= 1
            a := srcJ[i]
            b := srcJ[i + delay]
            c := srcJ[i + 2 * delay]
        else
            for m = 0 to scale - 1
                a += srcJ[i * scale + m]
                b += srcJ[(i + delay) * scale + m]
                c += srcJ[(i + 2 * delay) * scale + m]
            a := a / scale
            b := b / scale
            c := c / scale
        int p = f_pat(c, b, a)                 // c = oldest (i+2·delay), a = newest (i)
        array.set(cnt, p, array.get(cnt, p) + 1.0)
        float wm = (a + b + c) / 3.0
        float wv = ((a - wm) * (a - wm) + (b - wm) * (b - wm) + (c - wm) * (c - wm)) / 3.0
        array.set(cntW, p, array.get(cntW, p) + wv)
        Wtot += wv
    float T = win
    float e = 0.0
    float Smix = 0.0
    float invN = 1.0 / 6.0
    for k = 0 to 5
        float pk = array.get(cnt, k) / T
        if pk > 0.0
            e -= pk * math.log(pk)
        float mk = (pk + invN) / 2.0
        if mk > 0.0
            Smix -= mk * math.log(mk)
    float lnN = math.log(6.0)
    float peV = e / lnN
    float divg = Smix - e / 2.0 - lnN / 2.0     // statistical complexity = disequilibrium × entropy
    float compV = (divg / divMax) * peV
    float ew = 0.0
    int   fb = 0
    for k = 0 to 5
        float pwk = Wtot > 0.0 ? array.get(cntW, k) / Wtot : 0.0
        if pwk > 0.0
            ew -= pwk * math.log(pwk)
        if array.get(cnt, k) == 0.0
            fb += 1
    float wpeV = ew / lnN
    [peV, wpeV, float(fb), compV]

// scalar entropy at one scale (for the multiscale loop); reads all tuple parts so none is "unused"
f_peV(int win, int delay, int scale) =>
    [p, w, f, c] = f_pe(win, delay, scale)
    nz(w) == w and nz(f) == f and nz(c) == c ? p : p

// primary (scale-1) engine
float peRaw = na
float compRaw = na
float wpeRaw = na
float forbRaw = na
if bar_index >= peLen + 2 * peDelay + 1
    [pv, wv, fv, cv] = f_pe(peLen, peDelay, 1)
    peRaw := pv
    wpeRaw := wv
    forbRaw := fv
    compRaw := cv

// MULTISCALE entropy — average PE over coarse-grain scales 1..sMax (depth-capped for safety)
float mpeRaw = na
if useMulti
    float mSum = 0.0
    int   mCnt = 0
    for s = 1 to sMax
        int need = (peLen + 2 * peDelay) * s + s + 1
        if bar_index >= need and need <= 1250
            float pv2 = f_peV(peLen, peDelay, s)
            if not na(pv2)
                mSum += pv2
                mCnt += 1
    mpeRaw := mCnt > 0 ? mSum / mCnt : na

// smoothing — ta.ema hoisted to top level and SELECTED after (stateful ta.* must not sit behind a ?:)
float peEma   = ta.ema(peRaw,   peSmooth)
float compEma = ta.ema(compRaw, peSmooth)
float wpeEma  = ta.ema(wpeRaw,  peSmooth)
float mpeEma  = ta.ema(mpeRaw,  peSmooth)
float pe   = peSmooth > 1 ? peEma   : peRaw
float comp = peSmooth > 1 ? compEma : compRaw
float wpe  = peSmooth > 1 ? wpeEma  : wpeRaw
float mpe  = peSmooth > 1 ? mpeEma  : mpeRaw
float forb = forbRaw

// EFFECTIVE thresholds — Adaptive (self-calibrating percentile of the entropy's OWN recent range,
// so a liquid instrument still signals when relatively low) or Absolute (fixed 0–1 levels).
bool adaptive = thrMode == "Adaptive (percentile)"
var array<float> peHist = array.new<float>()
if not na(pe)
    peHist.push(pe)
    while peHist.size() > adaptWin
        peHist.shift()
float predLvl = na
float randLvl = na
if adaptive
    if peHist.size() >= 30
        predLvl := array.percentile_linear_interpolation(peHist, predPctLvl)
        randLvl := array.percentile_linear_interpolation(peHist, randPctLvl)
else
    predLvl := predThr
    randLvl := randThr

bool predictable = not na(pe) and not na(predLvl) and pe <= predLvl
bool randomTape  = not na(pe) and not na(randLvl) and pe >= randLvl
bool highComplex = not na(comp) and comp >= compThr
bool structured  = predictable and highComplex
float mom = src - src[momLen]
bool enterPred = not na(pe) and not na(pe[1]) and not na(predLvl) and not na(predLvl[1]) and pe <= predLvl and pe[1] > predLvl[1]
bool armed     = enterPred and (not gateByComplexity or highComplex)
bool longSig  = armed and mom > 0
bool shortSig = armed and mom < 0
var int totSig = 0                                    // live count of fired signals (so "0" reads as "none yet", not a bug)
if longSig or shortSig
    totSig += 1

// ───────────────────────────── PLOTS ──────────────────────────────────
// SINGLE-LOOK design. The BACKGROUND tint is the primary glance cue:
//   green  = genuine structure (low entropy + high complexity) → actionable
//   amber  = low-complexity / trivial low entropy              → caution
//   grey   = random / efficient tape                           → stand aside
//   none   = mixed                                             → wait
// The line is the hero, coloured by the same regime, with glow + a gradient area
// to the predictable threshold. No static zone fills — colour reflects the LIVE
// state, never a fixed band that floods the pane regardless of the reading.
isGrad = vizStyle == "Gradient area + glow"
isHist = vizStyle == "Histogram"
isLine = vizStyle == "Line"
color colTriv   = #e3a008
// live regime colour: green = genuine structure · amber = trivial low-entropy · grey = random
color baseCol   = structured ? colBull : (predictable and not highComplex) ? colTriv : randomTape ? colRand : color.new(colRand, 25)
float intensity = (not na(predLvl) and not na(randLvl)) ? math.min(math.abs(pe - predLvl) / math.max(randLvl - predLvl, 0.01), 1.0) : 0.5

// ── conventional-oscillator zones: STRUCTURED band below the predictable line (green,
//    "the tape has order"), RANDOM band above the random line (grey, "stand aside") ──
pTopZ  = plot(1.0,     "ztop",  color = na, display = display.none, editable = false)
pBotZ  = plot(0.0,     "zbot",  color = na, display = display.none, editable = false)
pPredL = plot(predLvl, "Predictable ▲ (structured below)", color = color.new(colBull, 40), linewidth = 1)
pRandL = plot(randLvl, "Random ▼ (stand aside above)",     color = color.new(colRand, 40), linewidth = 1)
fill(pRandL, pTopZ, color = showZones ? color.new(colRand, 90) : na, title = "Random zone")
fill(pPredL, pBotZ, color = showZones ? color.new(colBull, 92) : na, title = "Structured zone")
hline(1.0, "Max (fully random)", color = color.new(color.gray, 78), linestyle = hline.style_dotted)

// subtle regime background tint
color bgRegime = structured ? color.new(colBull, 82) : (predictable and not highComplex) ? color.new(colTriv, 88) : randomTape ? color.new(colRand, 90) : na
bgcolor(bgRegime, title="Regime")

// histogram style (opacity scales with distance from the predictable threshold)
plot(isHist ? pe : na, "Histogram", style=plot.style_histogram, linewidth=2, color = isHist ? color.new(baseCol, int(math.round(45 * (1 - intensity)))) : na)

// glow + crisp regime-coloured line (Gradient & Line styles)
showLine = isGrad or isLine
plot(showLine ? pe : na, "Glow outer", style=plot.style_line, linewidth=7, color=color.new(baseCol, 84))
plot(showLine ? pe : na, "Glow inner", style=plot.style_line, linewidth=3, color=color.new(baseCol, 60))
pPe    = plot(showLine ? pe : na, "Perm entropy", style=plot.style_line, linewidth=2, color=color.new(baseCol, 0))
// gradient area fills the STRUCTURED excursion only (below the predictable line) — highlights order, not noise
pBaseF = plot(isGrad ? predLvl : na, "areabase", color=color.new(color.gray,100), display=display.none, editable=false)
fill(pPe, pBaseF, color = (isGrad and predictable) ? color.new(colBull, int(math.round(86 - intensity * 30))) : na, title="Structured area")

// signals — pane markers + PRICE overlay triangles (green up = structured & up, red down = structured & down)
plotshape(showSig and longSig  ? pe : na, "Long",  shape.triangleup,   location.absolute, color.new(colBull,0), size=size.small)
plotshape(showSig and shortSig ? pe : na, "Short", shape.triangledown, location.absolute, color.new(colBear,0), size=size.small)
plotshape(showOverlay and longSig,  "Long (overlay)",  shape.triangleup,   location.belowbar, color = colBull, size = size.small, force_overlay = true)
plotshape(showOverlay and shortSig, "Short (overlay)", shape.triangledown, location.abovebar, color = colBear, size = size.small, force_overlay = true)

// statistical complexity overlay (optional)
plot(showComplexity ? comp : na, "Statistical complexity", style=plot.style_line, linewidth=1, color=color.new(colComp, 0))
plot(showComplexity ? compThr : na, "Complexity threshold", style=plot.style_line, linewidth=1, color=color.new(colComp, 55))

// ───────────────────────────── CALIBRATION ────────────────────────────
// ─── Wilson interval (significance of the Edge) ───────────────────────────────────────────────
f_wilson(float w, float n, float zc) =>
    if n <= 0
        na
    else
        float p = w / n
        float z2 = zc * zc
        float c = (p + z2 / (2.0 * n)) / (1.0 + z2 / n)
        float hw = (zc * math.sqrt(p * (1.0 - p) / n + z2 / (4.0 * n * n))) / (1.0 + z2 / n)
        hw

float atrC = ta.atr(calAtrLen)
var int sigN = 0
var int hitN = 0
var int baseTot = 0
var int baseUp = 0
var int baseDn = 0
var int rtRuns = 0
var int rtLast = -1
var int rtN = 0
var int rtN1 = 0
var int rtN0 = 0
// HARNESS+ — pending-array calibration (uniqueness-weighted eff-N + in-sample / out-of-sample split)
type HEv
    int   dir
    int   bidx
    float entry
    float atr0
    float uniq
var array<HEv> harPend = array.new<HEv>()
var float harTotW = 0.0
var float harHitW = 0.0
var int   harIsTot = 0
var int   harIsHit = 0
var int   harOosTot = 0
var int   harOosHit = 0
var int   harResolved = 0
float fwdMv  = close - close[calHor]
float fwdAtr = atrC[calHor]
if calibOn and barstate.isconfirmed and bar_index > calHor and not na(fwdAtr) and fwdAtr > 0
    if longSig[calHor]
        sigN += 1
        int oL = fwdMv >= calMove * fwdAtr ? 1 : 0
        if oL == 1
            hitN += 1
        if rtN > 0 and oL != rtLast
            rtRuns += 1
        rtLast := oL
        rtN += 1
        if oL == 1
            rtN1 += 1
        else
            rtN0 += 1
    if shortSig[calHor]
        sigN += 1
        int oS = -fwdMv >= calMove * fwdAtr ? 1 : 0
        if oS == 1
            hitN += 1
        if rtN > 0 and oS != rtLast
            rtRuns += 1
        rtLast := oS
        rtN += 1
        if oS == 1
            rtN1 += 1
        else
            rtN0 += 1
    baseTot += 1
    if fwdMv >= calMove * fwdAtr
        baseUp += 1
    if -fwdMv >= calMove * fwdAtr
        baseDn += 1

// ─── Wilson significance + edge-floor + runs-test (main scope) ────────────────────────────────
float hitPm  = sigN > 0 ? hitN * 100.0 / sigN : na
float basePm = baseTot > 0 ? (baseUp + baseDn) * 100.0 / (2.0 * baseTot) : na
float edgeM  = not na(hitPm) and not na(basePm) ? hitPm - basePm : na
float ciPct  = f_wilson(hitN, sigN, 1.96) * 100.0
bool  sigStar = not na(ciPct) and not na(edgeM) and (edgeM - ciPct) > 0
float edgeLB = not na(hitPm) and not na(ciPct) and not na(basePm) ? (hitPm - ciPct) - basePm : na
float rtMu  = rtN > 1 ? 2.0 * rtN1 * rtN0 / rtN + 1.0 : na
float rtVar = rtN > 1 ? 2.0 * rtN1 * rtN0 * (2.0 * rtN1 * rtN0 - rtN) / (rtN * rtN * (rtN - 1.0)) : na
float runsZ = not na(rtVar) and rtVar > 0 ? (rtRuns - rtMu) / math.sqrt(rtVar) : na

// HARNESS+ resolver + metrics — uniqueness-weighted effective-N, in-sample / out-of-sample edge
if calibOn and barstate.isconfirmed and not na(atrC) and atrC > 0.0
    if longSig
        harPend.push(HEv.new(1,  bar_index, close, atrC, 1.0 / (1.0 + harPend.size())))
    if shortSig
        harPend.push(HEv.new(-1, bar_index, close, atrC, 1.0 / (1.0 + harPend.size())))
    if harPend.size() > 0
        for i = harPend.size() - 1 to 0
            HEv ev = harPend.get(i)
            if bar_index - ev.bidx >= calHor
                float fav = (close - ev.entry) * ev.dir
                bool  win = fav >= calMove * ev.atr0
                harTotW += ev.uniq
                harHitW := win ? harHitW + ev.uniq : harHitW
                if harResolved < harTrainN
                    harIsTot += 1
                    harIsHit := win ? harIsHit + 1 : harIsHit
                else
                    harOosTot += 1
                    harOosHit := win ? harOosHit + 1 : harOosHit
                harResolved += 1
                harPend.remove(i)
float zDefl      = nTests <= 1 ? 1.96 : nTests == 2 ? 2.24 : nTests == 3 ? 2.39 : nTests == 4 ? 2.50 : 2.58
float harEffN    = harTotW
float harOosHitP = harOosTot > 0 ? harOosHit / float(harOosTot) * 100.0 : na
float harOosEdge = (not na(harOosHitP) and not na(basePm)) ? harOosHitP - basePm : na
float harOosCi   = f_wilson(harOosHit, harOosTot, zDefl) * 100.0
bool  harOosStar = harOosTot >= 10 and not na(harOosHitP) and not na(basePm) and (harOosHitP - harOosCi) > basePm

// ───────────────────────────── DASHBOARD (theme-adaptive) ─────────────
// Opaque cells with zebra rows and a frame, matching the rest of the oscillator
// suite. Auto reads the chart-background luma so text always keeps contrast.
bool dark = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : (0.299*color.r(chart.bg_color)+0.587*color.g(chart.bg_color)+0.114*color.b(chart.bg_color)) < 140
color panelBg = dark ? color.rgb(17, 22, 28)   : color.rgb(244, 246, 248)
color rowAlt  = dark ? color.rgb(25, 31, 39)   : color.rgb(232, 236, 240)
color pTxt    = dark ? color.rgb(154,166,178)  : color.rgb(74, 82, 91)
color pStr    = dark ? color.white             : color.rgb(16, 20, 24)
color pMut    = dark ? color.rgb(154,166,178)  : color.rgb(112,122,134)
color frameC  = dark ? color.rgb(58, 70, 84)   : color.rgb(196,204,212)
color cBull2  = dark ? colBull : color.rgb(22,151,106)
color cBear2  = dark ? colBear : color.rgb(210,45,68)
color hdrC    = color.new(colBull, 0)
pos = panelPos=="Bottom Left"?position.bottom_left : panelPos=="Top Left"?position.top_left : panelPos=="Top Right"?position.top_right : panelPos=="Middle Right"?position.middle_right : position.bottom_right
bool pro = dashMode == "Pro"
var table T = table.new(pos, 2, pro ? 11 : 5, frame_width=1, border_width=1)
f_row(int r, string k, string v, color vc, color bg) =>
    table.cell(T,0,r,k, text_color=pTxt, bgcolor=bg, text_size=size.small, text_halign=text.align_left)
    table.cell(T,1,r,v, text_color=vc, bgcolor=bg, text_size=size.small, text_halign=text.align_right, text_formatting=text.format_bold)
if showPanel and barstate.islast
    table.set_frame_color(T, frameC)
    table.set_border_color(T, frameC)
    float hitP = sigN>0 ? hitN*100.0/sigN : na
    float baseP = baseTot>0 ? (baseUp+baseDn)*100.0/(2.0*baseTot) : na
    float edge = (not na(hitP) and not na(baseP)) ? hitP - baseP : na
    color rBg = pro ? panelBg : rowAlt
    // header
    table.cell(T,0,0,"Permutation Entropy", text_color=color.white, text_size=size.small, bgcolor=hdrC, text_formatting=text.format_bold)
    table.cell(T,1,0,na(pe)?"warm":"PE "+str.tostring(pe,"0.00"), text_color=color.white, text_size=size.small, bgcolor=hdrC, text_formatting=text.format_bold)
    // tape state (always)
    color stateBg = structured ? color.new(colBull, 12) : (predictable and not highComplex) ? color.new(colTriv, 18) : randomTape ? color.new(colRand, 22) : rowAlt
    color stateTx = (structured or (predictable and not highComplex) or randomTape) ? color.white : pStr
    string st = structured?"STRUCTURED ●":predictable?"low-C / trivial":randomTape?"random":"mixed"
    table.cell(T,0,1,"Tape · signals", text_color=pTxt, bgcolor=rowAlt, text_size=size.small, text_halign=text.align_left)
    table.cell(T,1,1,st + "  ·  " + str.tostring(totSig), text_color=stateTx, bgcolor=stateBg, text_size=size.small, text_halign=text.align_right, text_formatting=text.format_bold)
    int pr = 2
    if pro
        f_row(pr, "Complexity", na(comp)?"warm":str.tostring(comp,"0.00")+(highComplex?"  ●":""), highComplex?cBull2:pMut, panelBg)
        pr += 1
    f_row(pr, "Momentum", mom>0?"up":mom<0?"down":"flat", mom>0?cBull2:mom<0?cBear2:pMut, pr%2==0?panelBg:rowAlt)
    pr += 1
    if pro
        f_row(pr, "Signals (n)", str.tostring(sigN), pStr, pr%2==0?panelBg:rowAlt)
        pr += 1
        f_row(pr, "Hit %", sigN<20?"warm":str.tostring(hitP,"0")+"%", sigN<20?pMut:pStr, pr%2==0?panelBg:rowAlt)
        pr += 1
    f_row(pr, "Edge", sigN<20?"warm":str.tostring(edge,"+0.0;-0.0")+" pts", na(edge)?pMut:edge>3?cBull2:edge<-3?cBear2:pMut, pr%2==0?panelBg:rowAlt)
    pr += 1
    if pro
        f_row(pr, "WPE / Forbidden", na(wpe)?"warm":str.tostring(wpe,"0.00")+" / "+str.tostring(forb,"0"), na(wpe)?pMut:pStr, pr%2==0?panelBg:rowAlt)
        pr += 1
        f_row(pr, "Edge floor", sigN<20?"warm":(sigStar?"★ ":"")+str.tostring(edgeLB,"+0.0;-0.0")+" pts", na(edgeLB)?pMut:edgeLB>0?cBull2:cBear2, pr%2==0?panelBg:rowAlt)
        pr += 1
    f_row(pr, "Multiscale PE", (not useMulti)?"off":na(mpe)?"warm":str.tostring(mpe,"0.00"), na(mpe)?pMut:((not na(predLvl) and mpe<predLvl)?cBull2:pStr), pr%2==0?panelBg:rowAlt)
    pr += 1
    if pro
        f_row(pr, "Edge OOS · eff-N", na(harOosEdge)?"warm":(harOosStar?"★ ":"")+str.tostring(harOosEdge,"+0.0;-0.0")+" · "+str.tostring(harEffN,"0.0"), na(harOosEdge)?pMut:harOosEdge>0?cBull2:cBear2, pr%2==0?panelBg:rowAlt)
        pr += 1

// ─── EXP_* EXPORT BUS (generic; Data Window) ─────────────────────────────────────────────────
plot(showEXP ? pe                          : na, "EXP_Entropy",   color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? wpe                         : na, "EXP_WPE",       color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? comp                        : na, "EXP_Complexity",color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? forb                        : na, "EXP_Forbidden", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? (structured ? 2 : predictable ? 1 : randomTape ? -1 : 0) : na, "EXP_Regime", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? (longSig ? 1 : shortSig ? -1 : 0) : na, "EXP_Signal", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? edgeM                       : na, "EXP_Edge",      color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? edgeLB                      : na, "EXP_EdgeLB",    color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? runsZ                       : na, "EXP_RunsZ",     color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? mpe                         : na, "EXP_MPE",       color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? harOosEdge                  : na, "EXP_EdgeOOS",   color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? harEffN                     : na, "EXP_EffN",      color = color.new(color.gray, 100), display = display.data_window)

// ───────────────────────────── ALERTS ─────────────────────────────────
alertcondition(longSig,  "Structured long",  "Permutation entropy: predictable regime started with up momentum.")
alertcondition(shortSig, "Structured short", "Permutation entropy: predictable regime started with down momentum.")
alertcondition(randomTape, "Random tape", "Permutation entropy high: tape is effectively random.")
````
