# VPIN Flow-Toxicity Oscillator

- url: https://www.tradingview.com/script/VkRgPok2-VPIN-Flow-Toxicity-Oscillator/
- type: indicator
- pine_id: PUB;16b69a72d7604183898dc36c1b3037e8
- version: 4.0

## Description

VPIN Flow-Toxicity Oscillator 

What it does

The VPIN Flow-Toxicity Oscillator is a single-pane order-flow toxicity gauge, scaled 0–100. It rises when estimated buy/sell volume becomes one-sided and "informed" — a condition that historically tends to precede volatility expansion and liquidity events, regardless of direction.

Why this is different (and original)

This is not a directional momentum or volume oscillator. It is an early-warning for volatility. Where most volume tools sum or net volume, VPIN measures the imbalance between estimated buy and sell volume and ranks how toxic (one-sided) flow currently is. The key property — documented in the microstructure literature — is that toxic flow tends to lead range expansion, so the oscillator can light up while price is still quiet. Delivering VPIN as a clean, self-calibrating 0–100 line with an honest volatility-expansion edge test (not a directional one) is what makes it original.

How it works


Bulk-Volume Classification splits each bar's volume into buy and sell using the normal CDF of the standardized price change (Φ of the price move divided by its rolling standard deviation).
Toxicity = rolling mean of |buy − sell| ÷ rolling mean of volume over the window (a 0–1 figure).
That figure is percentile-ranked over the percentile window into a 0–100 line, so the toxic and extreme thresholds self-calibrate to each instrument.


How to use it


Low (green) = calm, balanced flow. High (red) = toxic, one-sided flow — tighten risk and expect a range expansion, not a particular direction.
A cross above the Toxic threshold (triangle) is the warning event; the Extreme zone is a stronger version.
Read the EDGE row. Because VPIN signals volatility (not direction), the harness measures whether high toxicity actually preceded a range expansion — the high−low range over the horizon reaching ≥ k×ATR — versus the unconditional Base %. EDGE = Hit − Base. This is the honest test of the metric's stated claim.


Important honesty note

This is the bar-based bulk-volume approximation of VPIN. Charts do not provide exchange-classified aggressor (true buy/sell) data, so buy/sell split is estimated from price and volume. It is a faithful, widely-used approximation — but it is an approximation, and the indicator says so.

Settings guide


01 · VPIN Engine — return-sigma length, toxicity window, percentile window, universal price source.
02 · Calibration — horizon, expansion threshold (×ATR range), base-rate window.
03 · Bands — calm, toxic and extreme percentile thresholds.
04 · Display & Theme — visual style, regime tint, dashboard, colors.


Non-repaint

Classification uses closed bars only — no future leak.

Concept credit


Volume-synchronized Probability of Informed Trading (VPIN) and bulk-volume classification — Easley, López de Prado & O'Hara, Flow Toxicity and Liquidity in a High-Frequency World (2012).


Disclaimer

For research and education only. Not financial advice, not a recommendation, and not a guarantee of future results. VPIN signals toxicity and potential volatility, not direction. All statistics are in-sample and exclude costs. Do your own research and manage your own risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Market_Logic_India
//@version=6
// ═════════════════════════════════════════════════════════════════════════════════════════════════
//  VPIN FLOW-TOXICITY OSCILLATOR                                                               v2.1
//  v2.1 — THREE ADDITIVE ml_* LAYERS on top of v2.0; the VPIN bucketing, percentile scale and the
//    HARNESS+ calibration are UNCHANGED (set the classifier to "BVC (modeled)" for exact v2.0 flow):
//    • TRUE-LTF measured flow (Wave B · U1): optionally split each bar's volume by summing lower-
//      timeframe sub-bars signed by close-vs-open — measured aggressor flow instead of the modeled
//      BVC split — via "Volume classifier" (default: True LTF, automatic BVC fallback on bars with no
//      sub-bar data / higher TFs). The Student-t / Normal BVC classifier is retained as the fallback.
//    • TOXICITY VELOCITY (Wave E): how FAST toxicity is building (Δ percentile over a short window).
//      A rising-fast reading while already toxic makes the volatility warning more urgent. Shown on a
//      new dashboard row, exported as EXP_ToxicityVel (which replaces the redundant EXP_JumpRisk that
//      duplicated EXP_Toxicity), and a "Toxicity accelerating" alert.
//    • VSA BAR EVENTS (Wave D · U9): names the current bar's dominant Wyckoff / effort-vs-result event
//      (Upthrust, Shakeout, Stopping Volume, Buying/Selling Climax, No-Demand/Supply) on a dashboard
//      row and as EXP_VSABias, with an optional time-of-day volume baseline — bar character alongside
//      the toxicity read. (This pane sits at TradingView's 64-plot ceiling, so the VSA events are
//      exposed via the dashboard + EXP_VSABias rather than on-price markers, and the trivial
//      EXP_DataLive liveness flag was retired to keep the plot count exactly at the v2.0 level.)
// ─────────────────────────────────────────────────────────────────────────────────────────────────
//  OVERVIEW
//    A single-pane order-flow TOXICITY gauge. It rises when buy/sell flow becomes one-sided and
//    "informed", which historically tends to precede volatility expansion and liquidity events.
//
//  v2.0 — WHAT'S NEW
//    • STUDENT-t bulk-volume classification — the canonical VPIN classifier (Easley-López de Prado-
//      O'Hara) splits volume with the fat-tailed Student-t CDF, not the Normal. Returns are fat-
//      tailed, so a big move is attributed to informed one-sidedness less over-confidently. The
//      t-CDF is computed exactly from the regularised incomplete beta (validated to ~1e-13).
//    • Canonical volume-clock VPIN on equal-volume buckets, with the raw 0–1 imbalance exported.
//    • HARNESS+ calibration — the edge track-record is now honest three ways: a uniqueness-weighted
//      EFFECTIVE sample size (overlapping forward windows aren't independent), a multiple-testing
//      DEFLATED significance bar, and an IN-SAMPLE / OUT-OF-SAMPLE split (the OOS edge is the one
//      to trust). The Wald-Wolfowitz runs-test and CUSUM event gate are retained.
//    • ZERO-CENTRED oscillator view — the pane now swings around a 0 midline (above 0 = toxic/red,
//      below 0 = calm/green), reading like a familiar momentum oscillator. Toxic-onset events are
//      marked on the PRICE chart as tiny directional triangles: green up = buy-dominated toxic
//      flow, red down = sell-dominated (the toxicity is non-directional; the triangle only shows
//      which side is being aggressive as it fires).
//
//  WHAT MAKES IT DIFFERENT
//    This is not a directional momentum tool. It is an EARLY-WARNING for volatility: toxic flow flags
//    that the next move may be large, regardless of side. It measures the BALANCE of estimated buy vs
//    sell volume, not price, so it can light up while price is still quiet.
//
//  HOW IT WORKS
//    Bulk-Volume Classification splits each bar's volume into buy/sell using the normal CDF of the
//    standardized price change. Toxicity = rolling mean |buy − sell| ÷ rolling mean volume over the
//    window (0–1). It is then PERCENTILE-ranked (0–100) so the toxic/extreme thresholds self-calibrate
//    to each instrument.
//
//  HOW TO USE
//    Low (green) = calm, balanced flow. High (red) = toxic, one-sided flow — tighten risk and expect a
//    range expansion, not a particular direction. A cross above the Toxic threshold (triangle) is the
//    warning event. The EDGE row measures whether high toxicity actually preceded a range EXPANSION
//    (not a direction) versus a random bar — read EDGE.
//
//  UNIVERSAL / SOURCES
//    Sigma length, toxicity window, percentile window and thresholds are all inputs. Works on any
//    symbol/timeframe with volume; defaults suit index/NIFTY behaviour.
//
//  CONCEPT CREDIT (full references in the published description)
//    Volume-synchronized Probability of Informed Trading (VPIN) and bulk-volume classification —
//    Easley, López de Prado & O'Hara, "Flow Toxicity and Liquidity in a High-Frequency World" (2012).
//    Student-t bulk-volume classification refinement — Easley, López de Prado & O'Hara; Andersen &
//    Bondarenko. Sample-uniqueness weighting & purged out-of-sample evaluation — Marcos López de
//    Prado, "Advances in Financial Machine Learning" (2018). Runs test — Wald & Wolfowitz.
//
//  HONESTY
//    This is the bar-based bulk-volume APPROXIMATION (charts give no exchange-classified aggressor
//    data). VPIN signals toxicity → volatility, NOT direction. Statistics are in-sample, without costs.
//    Read the Edge row.
//
//  DISCLAIMER
//    For research and education only. NOT financial advice, NOT a recommendation, NOT a guarantee of
//    future results. Do your own research and manage your own risk.
//
//  Non-repaint: classification uses closed bars only.
// ═════════════════════════════════════════════════════════════════════════════════════════════════
indicator("VPIN Flow-Toxicity Oscillator", "VPIN Toxicity", overlay = false, max_labels_count = 500, dynamic_requests = true)

// ─── 01 · VPIN ENGINE ──────────────────────────────────────────────────────────────────────────
g1 = "01 · VPIN Engine"
sigLen  = input.int(20,  "Return Sigma Length", minval = 5,  group = g1, tooltip = "Window to standardize the price change for bulk-volume classification.")
nBars   = input.int(50,  "Toxicity Window (bars)", minval = 10, group = g1, tooltip = "Rolling window over which order-flow imbalance is averaged.")
rankLen = input.int(250, "Percentile Window", minval = 50, group = g1, tooltip = "Self-calibrating window for the 0–100 toxicity scale.")
bvcMode = input.string("Student-t (fat-tail)", "Bulk-volume classifier", options = ["Student-t (fat-tail)", "Normal"], group = g1, tooltip = "How each bar's volume is split into buy/sell. Student-t is the canonical VPIN classifier: returns are fat-tailed, so a large move is attributed to informed one-sidedness LESS over-confidently than under the Normal. Normal is the classic BVC.")
tNu     = input.float(4.0, "Student-t degrees of freedom", minval = 1.0, maxval = 30.0, step = 0.5, group = g1, tooltip = "Student-t classifier only. Lower = fatter tails = more conservative on big moves; ~4 suits fat-tailed returns. High ν approaches the Normal.")
srcPrice= input.source(close, "Price Source (for Edge)", group = g1)

// ─── 02 · CALIBRATION (Hit / Base / EDGE) ──────────────────────────────────────────────────────
g2 = "02 · Calibration Harness"
calcCal = input.bool(true, "Measure Edge",           group = g2, tooltip = "Did high toxicity precede a range expansion versus a random bar?")
calH    = input.int(10,  "Horizon (bars)",           minval = 1, group = g2)
calK    = input.float(1.5,"Expansion (×ATR range)",  minval = 0.1, step = 0.1, group = g2, tooltip = "Event = high−low range over the horizon ≥ this × entry ATR.")
calWin  = input.int(500, "Base-rate window",         minval = 50, group = g2)
trainN  = input.int(40,  "In-sample events (then OOS)", minval = 10, group = g2, tooltip = "HARNESS+: the first N resolved events train (in-sample); every event after is scored OUT-OF-SAMPLE. The OOS edge is the trustworthy one.")
nTests  = input.int(3,   "Edge significance · N tests (deflation)", minval = 1, maxval = 10, group = g2, tooltip = "HARNESS+: raise the significance bar for the number of things tested (Bonferroni-style z), so a lucky edge is not starred as real.")

// ─── 03 · BANDS ────────────────────────────────────────────────────────────────────────────────
g3 = "03 · Bands"
calmPct = input.float(20, "Calm Threshold (pct)",    minval = 1,  maxval = 50, group = g3)
obPct   = input.float(80, "Toxic Threshold (pct)",   minval = 50, maxval = 99, group = g3)
extPct  = input.float(95, "Extreme Threshold (pct)", minval = 60, maxval = 100, group = g3)

// ─── 04 · DISPLAY & THEME ──────────────────────────────────────────────────────────────────────
g4 = "04 · Display & Theme"
vizStyle = input.string("Gradient area + glow", "Visual style", options = ["Gradient area + glow", "Histogram", "Line"], group = g4)
showRegime = input.bool(true, "Background regime tint", group = g4)
showDash   = input.bool(true, "Show Dashboard",         group = g4)
calmCol  = input.color(#2ebd85, "Calm Flow",  group = g4)
toxCol   = input.color(#f6465d, "Toxic Flow", group = g4)
midCol   = input.color(#f7c948, "Midline Glow", group = g4)

// ─── HELPERS ──────────────────────────────────────────────────────────────────────────────────
f_ncdf(float z) =>
    float t = 1.0 / (1.0 + 0.2316419 * math.abs(z))
    float d = 0.3989423 * math.exp(-0.5 * z * z)
    float p = d * t * (0.3193815 + t * (-0.3565638 + t * (1.781478 + t * (-1.821256 + t * 1.330274))))
    z >= 0 ? 1.0 - p : p

// log-gamma (Lanczos, Numerical Recipes gammln) — exact to ~1e-12 for x > 0
f_lgamma(float xx) =>
    float x   = xx
    float tmp = x + 5.5
    tmp := tmp - (x + 0.5) * math.log(tmp)
    float ser = 1.000000000190015
    ser := ser + 76.18009172947146   / (x + 1.0)
    ser := ser - 86.50532032941677   / (x + 2.0)
    ser := ser + 24.01409824083091   / (x + 3.0)
    ser := ser - 1.231739572450155   / (x + 4.0)
    ser := ser + 0.1208650973866179e-2 / (x + 5.0)
    ser := ser - 0.5395239384953e-5    / (x + 6.0)
    -tmp + math.log(2.5066282746310005 * ser / x)

// continued fraction for the regularised incomplete beta (Lentz)
f_betacf(float a, float b, float x) =>
    float qab = a + b
    float qap = a + 1.0
    float qam = a - 1.0
    float c = 1.0
    float d = 1.0 - qab * x / qap
    if math.abs(d) < 1e-30
        d := 1e-30
    d := 1.0 / d
    float h = d
    for m = 1 to 130
        float m2  = 2.0 * m
        float aa  = m * (b - m) * x / ((qam + m2) * (a + m2))
        d := 1.0 + aa * d
        if math.abs(d) < 1e-30
            d := 1e-30
        c := 1.0 + aa / c
        if math.abs(c) < 1e-30
            c := 1e-30
        d := 1.0 / d
        h := h * d * c
        float aa2 = -(a + m) * (qab + m) * x / ((a + m2) * (qap + m2))
        d := 1.0 + aa2 * d
        if math.abs(d) < 1e-30
            d := 1e-30
        c := 1.0 + aa2 / c
        if math.abs(c) < 1e-30
            c := 1e-30
        d := 1.0 / d
        float del = d * c
        h := h * del
        if math.abs(del - 1.0) < 3e-12
            break
    h

// regularised incomplete beta I_x(a,b)
f_betai(float a, float b, float x) =>
    float res = na
    if x <= 0.0
        res := 0.0
    else if x >= 1.0
        res := 1.0
    else
        float lbeta = f_lgamma(a + b) - f_lgamma(a) - f_lgamma(b)
        float bt    = math.exp(lbeta + a * math.log(x) + b * math.log(1.0 - x))
        res := x < (a + 1.0) / (a + b + 2.0) ? bt * f_betacf(a, b, x) / a : 1.0 - bt * f_betacf(b, a, 1.0 - x) / b
    res

// Student-t CDF (df = nu) via the incomplete beta — the canonical BVC classifier
f_tcdf(float z, float nu) =>
    float x  = nu / (nu + z * z)
    float ib = f_betai(nu / 2.0, 0.5, x)
    z >= 0.0 ? 1.0 - 0.5 * ib : 0.5 * ib

// ─── Wave B (U1): TRUE intrabar buy/sell from lower-timeframe sub-bars ──────────────────────────
flowSrc = input.string("True LTF (measured) + BVC fallback", "Volume classifier", options = ["True LTF (measured) + BVC fallback", "BVC (modeled)"], group = g1, tooltip = "True LTF splits each bar's volume by summing lower-timeframe sub-bars signed by close-vs-open — measured aggressor flow. Falls back to BVC automatically on bars with no sub-bar data (older history / higher TF). BVC (modeled) reproduces the original v2.0.")
ltfRes  = input.string("Auto (finest)", "Sub-bar resolution", options = ["Auto (finest)", "Seconds", "1 minute"], group = g1, tooltip = "Lower timeframe used to measure intrabar buy/sell. Auto picks seconds on fast charts, 1-minute on slow ones. Sub-bar data exists for recent bars only.")
string subTf = ltfRes == "Seconds" ? "1S" : ltfRes == "1 minute" ? "1" : (timeframe.in_seconds() >= 3600 ? "1" : timeframe.in_seconds() >= 300 ? "5S" : "1S")
[ltfC, ltfO, ltfV] = request.security_lower_tf(syminfo.tickerid, subTf, [close, open, volume])
float tBuy = 0.0
float tSell = 0.0
int nsub = math.min(array.size(ltfV), math.min(array.size(ltfC), array.size(ltfO)))
if nsub > 0
    for i = 0 to nsub - 1
        float sv = nz(array.get(ltfV, i), 0.0)
        float sc = array.get(ltfC, i)
        float so = array.get(ltfO, i)
        int ss = (na(sc) or na(so)) ? 0 : sc > so ? 1 : sc < so ? -1 : 0
        if ss > 0
            tBuy  += sv
        else if ss < 0
            tSell += sv
bool ltfOk  = nsub > 0 and (tBuy + tSell) > 0.0
bool useTrue = flowSrc == "True LTF (measured) + BVC fallback" and ltfOk

// ─── VPIN ─────────────────────────────────────────────────────────────────────────────────────
chg     = close - close[1]
sigma   = ta.stdev(chg, sigLen)
zc      = sigma > 0 ? chg / sigma : 0.0
buyFrac = bvcMode == "Normal" ? f_ncdf(zc) : f_tcdf(zc, tNu)
// Wave B: measured intrabar buy/sell when available, else the BVC modeled split (fallback)
buyV    = useTrue ? tBuy  : volume * buyFrac
sellV   = useTrue ? tSell : volume * (1.0 - buyFrac)
// ===== volume-clock bucketing (canonical VPIN) =====
useVClock = input.bool(true, "Volume clock (equal-volume buckets)", group = "05 · Advanced", tooltip = "Canonical VPIN runs on equal-volume buckets, not bar time.")
vBktBars  = input.int(20, "Bucket size (x avg-bar volume)", minval = 1, group = "05 · Advanced")
float vBktTarget = ta.sma(volume, 50) * vBktBars
var float cuB = 0.0
var float cuS = 0.0
var float cuV = 0.0
var array<float> bkImb = array.new<float>()
cuB += buyV
cuS += sellV
cuV += volume
if vBktTarget > 0 and cuV >= vBktTarget
    bkImb.push(math.abs(cuB - cuS))
    if bkImb.size() > nBars
        bkImb.shift()
    cuB := 0.0
    cuS := 0.0
    cuV := 0.0
float vbktImb = bkImb.size() > 0 ? array.avg(bkImb) : na
vpinRaw = ta.sma(math.abs(buyV - sellV), nBars) / math.max(ta.sma(volume, nBars), 1.0)
float vpinRawSel = (useVClock and not na(vbktImb) and vBktTarget > 0) ? vbktImb / vBktTarget : vpinRaw
vpin    = ta.percentrank(vpinRawSel, rankLen)   // 0..100, self-calibrated
float vpinTrend = math.sign(nz(vpin) - nz(vpin[5]))
// Toxicity velocity (Wave E): how FAST toxicity is building. Directionless — fast-rising
// toxicity is a more urgent volatility warning than slow-rising. Not a side call.
velLen = input.int(5, "Toxicity-velocity lookback (bars)", minval = 1, maxval = 100, group = g1, tooltip = "Δ in the percentile toxicity over this many bars. Rising fast = the volatility warning is more urgent. Exposed on the dashboard, as EXP_ToxicityVel, and as an alert.")
float vpinVel = na(vpin) ? na : vpin - nz(vpin[velLen], vpin)
bool  toxAccel = not na(vpinVel) and vpin >= obPct and vpinVel >= (obPct - calmPct) * 0.15
var bool toxAccPrev = false
bool  toxAccelNew = toxAccel and not toxAccPrev
toxAccPrev := toxAccel

// ─── SIGNALS ──────────────────────────────────────────────────────────────────────────────────
toxUp = ta.crossover(vpin, obPct)
var int lastSigBar = na
if toxUp
    lastSigBar := bar_index

// ─── CALIBRATION HARNESS (range expansion, na-safe) ────────────────────────────────────────────
atr     = ta.atr(14)
rangeH  = ta.highest(high, calH) - ta.lowest(low, calH)
expEvt  = rangeH >= calK * atr[calH]
baseExp = ta.sma(expEvt ? 1.0 : 0.0, calWin) * 100.0
// ===== CUSUM event gate + runs-test state =====
cusumK = input.float(1.0, "CUSUM event threshold (x ATR)", minval = 0.1, step = 0.1, group = "05 · Advanced")
var float csPos = 0.0
var float csNeg = 0.0
float csRet = close - close[1]
csPos := math.max(0.0, csPos + csRet)
csNeg := math.min(0.0, csNeg + csRet)
bool cusumEvt = not na(atr) and atr > 0 and (csPos >= cusumK * atr or csNeg <= -cusumK * atr)
if cusumEvt
    csPos := 0.0
    csNeg := 0.0
var int rtPrev = 0
var int rtRuns = 0
var int rtW = 0
var int rtL = 0

var int[]   cBar  = array.new_int()
var float[] cAtr  = array.new_float()
var float[] cBase = array.new_float()
var float[] cUniq = array.new_float()                 // HARNESS+ per-event uniqueness weight
var int hits = 0, var int tot = 0, var int baseN = 0
var float sumBase = 0.0
var float hitsW = 0.0                                  // uniqueness-weighted wins
var float totW  = 0.0                                  // uniqueness-weighted count ≈ effective N
var int   isHits = 0, var int isTot = 0                // in-sample
var int   oosHits = 0, var int oosTot = 0              // out-of-sample
var int   resolvedC = 0

if calcCal and toxUp and cusumEvt and not na(baseExp)
    float uw = 1.0 / (1.0 + cBar.size())              // concurrency at open → uniqueness weight
    cBar.push(bar_index), cAtr.push(atr), cBase.push(baseExp), cUniq.push(uw)

if cBar.size() > 0
    for i = cBar.size() - 1 to 0
        if bar_index - cBar.get(i) >= calH
            bool  vWin = rangeH >= calK * cAtr.get(i)
            float w    = cUniq.get(i)
            if vWin
                hits += 1
                hitsW += w
            tot += 1
            totW += w
            if resolvedC < trainN
                isTot += 1
                isHits := vWin ? isHits + 1 : isHits
            else
                oosTot += 1
                oosHits := vWin ? oosHits + 1 : oosHits
            resolvedC += 1
            rtRuns := rtPrev == 0 ? 1 : ((vWin ? 1 : -1) != rtPrev ? rtRuns + 1 : rtRuns)
            rtPrev := vWin ? 1 : -1
            rtW := vWin ? rtW + 1 : rtW
            rtL := vWin ? rtL : rtL + 1
            float b = cBase.get(i)
            if not na(b)
                sumBase += b
                baseN += 1
            cBar.remove(i), cAtr.remove(i), cBase.remove(i), cUniq.remove(i)

float hitPct  = tot   > 0 ? hits / tot * 100.0 : na
float basePct = baseN > 0 ? sumBase / baseN     : na
float edge    = not na(hitPct) and not na(basePct) ? hitPct - basePct : na
float effN    = totW
float oosHitPct = oosTot > 0 ? oosHits / float(oosTot) * 100.0 : na
float oosEdge   = (not na(oosHitPct) and not na(basePct)) ? oosHitPct - basePct : na
float isHitPct  = isTot  > 0 ? isHits  / float(isTot)  * 100.0 : na

// ===== FORWARD-STATISTICS UPGRADE  (Wilson interval + significance) =====
f_wilson(float w, float n, float zc) =>
    float r = na
    if n > 0.0
        float pp = w / n
        float den = 1.0 + zc * zc / n
        r := zc * math.sqrt(pp * (1.0 - pp) / n + zc * zc / (4.0 * n * n)) / den
    r
// multiple-testing deflated z (Bonferroni-style)
float zDefl   = nTests <= 1 ? 1.96 : nTests == 2 ? 2.24 : nTests == 3 ? 2.39 : nTests == 4 ? 2.50 : 2.58
float ciPct   = f_wilson(hits, tot, 1.96) * 100.0
// star on the EFFECTIVE-N weighted rate at the deflated bar (honest significance)
float hitPctW = totW > 0.0 ? hitsW / totW * 100.0 : na
float ciPctW  = f_wilson(hitsW, totW, zDefl) * 100.0
bool  sigStar = totW >= 15.0 and not na(hitPctW) and not na(basePct) and (hitPctW - ciPctW) > basePct
// out-of-sample star (the trustworthy one)
float oosCi   = f_wilson(oosHits, oosTot, zDefl) * 100.0
bool  oosStar = oosTot >= 10 and not na(oosHitPct) and not na(basePct) and (oosHitPct - oosCi) > basePct
float rtNn = rtW + rtL
float rtMu = rtNn > 0 ? 2.0 * rtW * rtL / rtNn + 1.0 : na
float rtVr = rtNn > 1 ? 2.0 * rtW * rtL * (2.0 * rtW * rtL - rtNn) / (rtNn * rtNn * (rtNn - 1.0)) : na
float runsZ = (not na(rtMu) and not na(rtVr) and rtVr > 0) ? (rtRuns - rtMu) / math.sqrt(rtVr) : na
float edgeLBv = (not na(hitPct) and not na(basePct) and not na(ciPct)) ? (hitPct - ciPct) - basePct : na

// ─── RENDER STYLE ──────────────────────────────────────────────────────────────────────────────
isHist = vizStyle == "Histogram"
isGrad = vizStyle == "Gradient area + glow"

// ZERO-CENTERED OSCILLATOR: swing around 0 (median toxicity). Above 0 = toxic (red),
// below 0 = calm (green). Thresholds re-centred from the percentile scale.
float oscV    = na(vpin) ? na : vpin - 50.0
float toxLvl  = obPct   - 50.0
float extLvl  = extPct  - 50.0
float calmLvl = calmPct - 50.0
color vCol = oscV >= 0 ? color.from_gradient(oscV, 0.0, math.max(extLvl, 1.0), color.new(toxCol, 55), toxCol) : color.from_gradient(oscV, calmLvl, 0.0, calmCol, color.new(calmCol, 55))
float intensity = math.min(math.abs(nz(oscV)) / 50.0, 1.0)

bgcolor(showRegime and vpin >= extPct ? color.new(toxCol, 88) : na, title = "Extreme toxicity")

// zero-centred reference frame
hline(0, "Zero", color.new(midCol, 0), linestyle = hline.style_solid)
plot(0.0, "Zero glow", color.new(midCol, 80), 3, display = display.pane, editable = false)
pTop   = plot(50.0,   "top", display = display.none, editable = false)
pBot   = plot(-50.0,  "bot", display = display.none, editable = false)
pTox   = plot(toxLvl,  "Toxic Line",   color.new(toxCol, 55), 1, display = display.pane, editable = false)
pExt   = plot(extLvl,  "Extreme Line", color.new(toxCol, 70), 1, display = display.pane, editable = false)
pCalm  = plot(calmLvl, "Calm Line",    color.new(calmCol, 55),1, display = display.pane, editable = false)
fill(pTox,  pTop, color.new(toxCol, 90),  title = "Toxic zone")
fill(pCalm, pBot, color.new(calmCol, 90), title = "Calm zone")

// oscillator body (area / histogram / line), all around the 0 baseline
mid = plot(0.0, "base", display = display.none, editable = false)
op  = plot(isGrad ? oscV : na, "area", display = display.none, editable = false)
fill(op, mid, color.new(vCol, 90 - int(intensity * 45)), title = "Gradient area")

plot(isHist ? oscV : na, "Histogram", color.new(vCol, 30), style = plot.style_columns)

plot(not isHist ? oscV : na, "glow outer", color.new(vCol, 88), 6, display = display.pane)
plot(not isHist ? oscV : na, "glow inner", color.new(vCol, 70), 3, display = display.pane)
plot(not isHist ? oscV : na, "VPIN Osc", vCol, 2)

// pane onset dot + DIRECTIONAL overlay signals on price, by flow side at toxic onset:
// green up-triangle (below bar) = buy-dominated toxic flow · red down-triangle (above bar) = sell-dominated
plotshape(toxUp, "Toxic Onset", shape.circle, location.top, color.new(toxCol, 20), size = size.tiny)
bool toxBuy  = toxUp and buyFrac >= 0.5
bool toxSell = toxUp and buyFrac <  0.5
plotshape(toxBuy,  "Toxic onset · buy-side",  shape.triangleup,   location.belowbar, color = calmCol, size = size.tiny, force_overlay = true)
plotshape(toxSell, "Toxic onset · sell-side", shape.triangledown, location.abovebar, color = toxCol,  size = size.tiny, force_overlay = true)

// ─── VSA BAR EVENTS (Wave D · U9 — ml_vsa effort-vs-result taxonomy, inlined) ───
gVsa     = "Y · VSA bar events (Wave D)"
vsaRow   = input.bool(true,  "Name the VSA event on the dashboard", group = gVsa, tooltip = "Names the current bar's dominant Wyckoff/VSA effort-vs-result event (Upthrust, Shakeout, Stopping Volume, Buying/Selling Climax, No-Demand/Supply) using the shared ml_vsa vocabulary — bar character alongside the toxicity read. Additive; the VPIN engine and calibration are unchanged.")
vsaLen   = input.int(50, "VSA history window", minval = 10, maxval = 300, group = gVsa)
vsaPiv   = input.int(5,  "New-extreme lookback", minval = 2, maxval = 50, group = gVsa)
vsaTod  = input.bool(false, "Time-of-day volume (Wave D · U11)", group = gVsa, tooltip = "OFF: high volume judged against a flat rolling window (original). ON: judge volume against the SAME time-of-day slot on prior sessions (ml_session per-slot baseline, inlined) — so a normal-for-the-open bar is not a false climax and a heavy-for-lunch bar is caught. Default off.")
vsaTodMin = input.int(5,  "  Slot size (minutes)", minval = 1, maxval = 60, group = gVsa, tooltip = "Time-of-day bucket size for the volume baseline.")
vsaTodSes = input.int(20, "  Session memory", minval = 3, maxval = 200, group = gVsa, tooltip = "Sessions of memory the per-slot volume baseline keeps.")
bool  vsaHasVol = not na(volume) and volume > 0
float vsaSp   = ta.percentrank(high - low, vsaLen)
// U11 (Wave D): optional time-of-day volume baseline (ml_session slotMean, inlined). "Heavy" is
// judged against the same wall-clock slot on prior sessions. State advances every bar (array EMA,
// no ta.*) so the baseline stays warm whether or not the switch is on.
int   vsaNSlots = math.max(1, int(math.ceil(1440.0 / math.max(vsaTodMin, 1))))
float vsaTodA   = 2.0 / (math.max(vsaTodSes, 1) + 1.0)
int   vsaSlot   = vsaTodMin > 0 ? int((hour * 60 + minute) / vsaTodMin) : 0
var array<float> vsaSlotVol = array.new<float>(vsaNSlots, na)
int   vsaSlotI  = (vsaSlot >= 0 and vsaSlot < vsaNSlots) ? vsaSlot : 0
float vsaSlotPv = array.get(vsaSlotVol, vsaSlotI)
float vsaSlotCv = na(volume) ? vsaSlotPv : na(vsaSlotPv) ? volume : vsaSlotPv + vsaTodA * (volume - vsaSlotPv)
array.set(vsaSlotVol, vsaSlotI, vsaSlotCv)
float vsaVolRatio = (not na(vsaSlotCv) and vsaSlotCv > 0.0) ? volume / vsaSlotCv : 1.0
float vsaVolUse   = vsaTod ? vsaVolRatio : volume
float vsaVp   = ta.percentrank(vsaVolUse,     vsaLen)
float vsaVpk  = ta.highest(vsaVolUse, vsaLen)
float vsaRngX = high - low
float vsaCp   = vsaRngX > 0.0 ? (close - low) / vsaRngX : 0.5
float vsaPHi  = ta.highest(high, vsaPiv)[1]
float vsaPLo  = ta.lowest(low,  vsaPiv)[1]
bool  vsaUpB  = close > close[1]
bool  vsaDnB  = close < close[1]
bool  vUpthrust = vsaHasVol and (high >= vsaPHi) and vsaCp <= 0.35 and vsaVp >= 60.0
bool  vShakeout = vsaHasVol and (low  <= vsaPLo) and vsaCp >= 0.65 and vsaVp >= 60.0
bool  vStopping = vsaHasVol and vsaDnB and vsaSp >= 60.0 and vsaVp >= 80.0 and vsaCp >= 0.45
bool  vClimaxUp = vsaHasVol and vsaUpB and vsaVolUse >= vsaVpk and vsaSp >= 70.0
bool  vClimaxDn = vsaHasVol and vsaDnB and vsaVolUse >= vsaVpk and vsaSp >= 70.0
bool  vNoDemand = vsaHasVol and vsaUpB and vsaSp <= 35.0 and vsaVp <= 35.0
bool  vNoSupply = vsaHasVol and vsaDnB and vsaSp <= 35.0 and vsaVp <= 35.0
string vsaEvt = vClimaxUp ? "Buying climax" : vClimaxDn ? "Selling climax" : vUpthrust ? "Upthrust" : vShakeout ? "Shakeout" : vStopping ? "Stopping volume" : vNoDemand ? "No demand" : vNoSupply ? "No supply" : "—"
int    vsaBiasVal = (vClimaxDn or vShakeout or vStopping or vNoSupply) ? 1 : (vClimaxUp or vUpthrust or vNoDemand) ? -1 : 0

// ─── DASHBOARD (theme-adaptive, zebra) ─────────────────────────────────────────────────────────
f_row(int r) => color.new(chart.fg_color, r % 2 == 0 ? 92 : 96)
var table dash = table.new(position.top_right, 2, 14, frame_color = color.new(chart.fg_color, 60), frame_width = 1, border_color = color.new(chart.fg_color, 80), border_width = 1)
if barstate.islast and showDash
    string st = vpin >= extPct ? "EXTREME" : vpin >= obPct ? "TOXIC" : vpin <= calmPct ? "CALM" : "NORMAL"
    color  sc = vpin >= obPct ? toxCol : vpin <= calmPct ? calmCol : color.new(chart.fg_color, 25)
    string sigTxt = na(lastSigBar) ? "—" : str.tostring(bar_index - lastSigBar) + "b ago"
    table.cell(dash, 0, 0, "VPIN TOXICITY", text_color = chart.bg_color, bgcolor = sc, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 0, st, text_color = chart.bg_color, bgcolor = sc, text_size = size.tiny)
    table.cell(dash, 0, 1, "VPIN (pct)", text_color = chart.fg_color, bgcolor = f_row(1), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 1, str.tostring(vpin, "#") + "%", text_color = sc, bgcolor = f_row(1), text_size = size.tiny)
    table.cell(dash, 0, 2, "Buy / Sell %", text_color = chart.fg_color, bgcolor = f_row(2), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 2, str.tostring(buyFrac * 100, "#") + " / " + str.tostring((1 - buyFrac) * 100, "#"), text_color = buyFrac >= 0.5 ? calmCol : toxCol, bgcolor = f_row(2), text_size = size.tiny)
    table.cell(dash, 0, 3, "Last Toxic", text_color = chart.fg_color, bgcolor = f_row(3), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 3, sigTxt, text_color = na(lastSigBar) ? color.new(chart.fg_color, 30) : toxCol, bgcolor = f_row(3), text_size = size.tiny)
    table.cell(dash, 0, 4, "Hit % (expansion)", text_color = chart.fg_color, bgcolor = f_row(4), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 4, na(hitPct) ? "—" : str.tostring(hitPct, "#.#") + "% +/-" + str.tostring(ciPct, "#.#"), text_color = chart.fg_color, bgcolor = f_row(4), text_size = size.tiny)
    table.cell(dash, 0, 5, "Base %", text_color = chart.fg_color, bgcolor = f_row(5), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 5, na(basePct) ? "—" : str.tostring(basePct, "#.#") + "%", text_color = color.new(chart.fg_color, 30), bgcolor = f_row(5), text_size = size.tiny)
    table.cell(dash, 0, 6, "EDGE", text_color = chart.fg_color, bgcolor = f_row(6), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 6, na(edge) ? "—" : (edge >= 0 ? "+" : "") + str.tostring(edge, "#.#") + "%" + (sigStar ? " *" : ""), text_color = chart.bg_color, bgcolor = na(edge) ? f_row(6) : (edge > 0 ? toxCol : calmCol), text_size = size.tiny)
    table.cell(dash, 0, 7, "Runs-Z (streak)", text_color = chart.fg_color, bgcolor = f_row(7), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 7, na(runsZ) ? "—" : str.tostring(runsZ, "#.#"), text_color = chart.fg_color, bgcolor = f_row(7), text_size = size.tiny)
    table.cell(dash, 0, 8, "Edge floor", text_color = chart.fg_color, bgcolor = f_row(8), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 8, na(edgeLBv) ? "—" : (edgeLBv >= 0 ? "+" : "") + str.tostring(edgeLBv, "#.#") + "%", text_color = na(edgeLBv) ? color.new(chart.fg_color, 30) : edgeLBv > 0 ? toxCol : calmCol, bgcolor = f_row(8), text_size = size.tiny)
    table.cell(dash, 0, 9, "Trend / clock", text_color = chart.fg_color, bgcolor = f_row(9), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 9, (vpinTrend > 0 ? "rising" : vpinTrend < 0 ? "falling" : "flat") + (useVClock ? "  vc" : "  bt"), text_color = vpinTrend > 0 ? toxCol : calmCol, bgcolor = f_row(9), text_size = size.tiny)
    table.cell(dash, 0, 10, "EDGE (OOS)", text_color = chart.fg_color, bgcolor = f_row(10), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 10, na(oosEdge) ? "—" : (oosEdge >= 0 ? "+" : "") + str.tostring(oosEdge, "#.#") + "%" + (oosStar ? " *" : ""), text_color = na(oosEdge) ? color.new(chart.fg_color, 30) : chart.bg_color, bgcolor = na(oosEdge) ? f_row(10) : (oosEdge > 0 ? toxCol : calmCol), text_size = size.tiny)
    table.cell(dash, 0, 11, "Eff-N (IS/OOS)", text_color = chart.fg_color, bgcolor = f_row(11), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 11, str.tostring(effN, "#.#") + "  (" + str.tostring(isTot) + "/" + str.tostring(oosTot) + ")", text_color = chart.fg_color, bgcolor = f_row(11), text_size = size.tiny)
    if vsaRow
        color vsaEvtCol = vsaBiasVal > 0 ? calmCol : vsaBiasVal < 0 ? toxCol : color.new(chart.fg_color, 25)
        table.cell(dash, 0, 12, "VSA event", text_color = chart.fg_color, bgcolor = f_row(12), text_halign = text.align_left, text_size = size.tiny)
        table.cell(dash, 1, 12, vsaEvt, text_color = vsaEvtCol, bgcolor = f_row(12), text_size = size.tiny)
    string velTxt = na(vpinVel) ? "—" : (vpinVel > 0 ? "▲ +" : vpinVel < 0 ? "▼ " : "• ") + str.tostring(vpinVel, "#.#") + (toxAccel ? " accel" : "")
    color  velCol = na(vpinVel) ? color.new(chart.fg_color, 30) : toxAccel ? toxCol : vpinVel > 0 ? color.new(toxCol, 40) : calmCol
    table.cell(dash, 0, 13, "Toxicity vel", text_color = chart.fg_color, bgcolor = f_row(13), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 13, velTxt, text_color = velCol, bgcolor = f_row(13), text_size = size.tiny)

// ─── ALERTS ───────────────────────────────────────────────────────────────────────────────────

// ===== IDENTITY STRIP  (name, symbol, timeframe) =====
showId = input.bool(true, "Show identity strip (name, symbol, timeframe)", group = "Z · Identity & exports")
var table idT = table.new(position.bottom_center, 1, 1, force_overlay = true)
if showId and barstate.islast
    color bgI  = chart.bg_color
    float lumI = na(bgI) ? 0.0 : color.r(bgI) * 0.299 + color.g(bgI) * 0.587 + color.b(bgI) * 0.114
    bool  dkI  = (na(bgI) or lumI < 140)
    table.cell(idT, 0, 0, "VPIN Flow-Toxicity Oscillator   -   " + syminfo.ticker + "   -   " + timeframe.period, text_color = dkI ? color.new(#c8d0da, 10) : color.new(#2a2f37, 10), text_size = size.small, text_halign = text.align_center, bgcolor = color.new(color.gray, 100))

// ===== EXP_* EXPORTS  (Data Window, generic names for input.source) =====
showEXP = input.bool(true, "Emit EXP_* exports", group = "Z · Identity & exports")
color exC_ = color.new(color.gray, 100)
plot(showEXP ? (vpin) : na, "EXP_Toxicity", color = exC_, display = display.data_window)
plot(showEXP ? (oscV) : na, "EXP_Osc", color = exC_, display = display.data_window)
plot(showEXP ? (toxBuy ? 1 : toxSell ? -1 : 0) : na, "EXP_ToxSide", color = exC_, display = display.data_window)
plot(showEXP ? (math.max(-100.0, math.min(100.0, (buyFrac - 0.5) * 200.0))) : na, "EXP_Bias", color = exC_, display = display.data_window)
plot(showEXP ? (vpin >= obPct ? 1 : vpin <= calmPct ? -1 : 0) : na, "EXP_Zone", color = exC_, display = display.data_window)
plot(showEXP ? (toxUp ? 1 : 0) : na, "EXP_Toxic", color = exC_, display = display.data_window)
plot(showEXP ? (edge) : na, "EXP_Edge", color = exC_, display = display.data_window)

plot(showEXP ? (vpinTrend) : na, "EXP_VPINtrend", color = exC_, display = display.data_window)
plot(showEXP ? (vpinVel) : na, "EXP_ToxicityVel", color = exC_, display = display.data_window)   // Wave E: toxicity velocity (Δpct over velLen). Replaces EXP_JumpRisk, which duplicated EXP_Toxicity.
plot(showEXP ? (runsZ) : na, "EXP_RunsZ", color = exC_, display = display.data_window)
plot(showEXP ? (edgeLBv) : na, "EXP_EdgeLB", color = exC_, display = display.data_window)
plot(showEXP ? (cusumEvt ? 1 : 0) : na, "EXP_CUSUM", color = exC_, display = display.data_window)
plot(showEXP ? (vpinRawSel) : na, "EXP_VPINraw", color = exC_, display = display.data_window)
plot(showEXP ? (oosEdge) : na, "EXP_EdgeOOS", color = exC_, display = display.data_window)
plot(showEXP ? (effN) : na, "EXP_EffN", color = exC_, display = display.data_window)
plot(showEXP ? (buyFrac * 100.0) : na, "EXP_BuyFrac", color = exC_, display = display.data_window)
plot(showEXP ? vsaBiasVal : na, "EXP_VSABias", color = exC_, display = display.data_window)
// NOTE: this pane is at TradingView's 64-plot ceiling, so the VSA layer is exposed as the dashboard
//   "VSA event" row + the EXP_VSABias export (consumed by the Master engine) rather than on-price
//   markers. The bar-event names still read alongside the toxicity gauge in the dashboard.
alertcondition(toxUp, "Toxic flow onset", "VPIN crossed above the toxic threshold")
alertcondition(ta.crossover(vpin, extPct), "Extreme toxicity", "VPIN crossed into the extreme zone")
alertcondition(toxAccelNew, "Toxicity accelerating", "VPIN: toxicity is RISING FAST while already toxic — volatility warning is urgent (directionless).")
````
