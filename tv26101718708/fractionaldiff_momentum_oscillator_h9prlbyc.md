# Fractional-Diff Momentum Oscillator

- url: https://www.tradingview.com/script/H9pRlBYc-Fractional-Diff-Momentum-Oscillator/
- type: indicator
- pine_id: PUB;ae364bd9beef4f0d9fde7712d7e6b98e
- version: 4.0

## Description

Fractional-Diff Momentum Oscillator 

What it does

The Fractional-Diff Momentum Oscillator is a momentum line, scaled in standard-deviation (σ) units around a zero balance, built on the fractional differencing of price — the smallest amount of differencing that makes price statistically stationary while still keeping its memory.

Why this is different (and original)

Almost every momentum oscillator works on returns — that is, price differenced once (integer order d = 1). Returns are stationary, but differencing once erases the series' memory, throwing away the slow, persistent structure that carries trend information. Raw price (order d = 0) keeps all the memory but is non-stationary and unusable by most statistical tools.

Fractional differencing uses a non-integer order (typically 0.3–0.6) that sits between the two: it removes just enough drift to reach stationarity while retaining long memory. The result is a momentum series that is both well-behaved and information-rich. This transform is standard in quantitative research but rare on retail charts, where oscillators almost universally difference once and discard the signal. That is what makes this original: it is a momentum oscillator built on a memory-preserving transform rather than plain returns.

How it works

The fixed-width fractional-difference weights are generated recursively — w(0) = 1, w(k) = −w(k−1)·(d − k + 1)/k — and truncated once they fall below a tolerance, giving a finite window. Those weights are convolved with log-price to produce the fractionally-differenced series. That series is then z-scored over the normalization window and lightly smoothed into the σ oscillator you see, centred on zero.

How to use it


Zero is the balance line. Above zero = net up-momentum; below = net down-momentum.
Dashed σ bands mark stretched momentum; dotted bands mark extremes prone to exhaustion (red on top, green on the bottom in the standard reading).
Zero-crosses (triangles) are momentum-flip events.
Divergences (circles) warn when price makes a new extreme that momentum does not confirm.
Read the EDGE row. The dashboard runs a live forward-return harness: for every momentum flip it checks whether a favourable move (≥ k×ATR within the horizon) actually occurred, and compares that Hit % against the unconditional Base %. EDGE = Hit − Base is the honest measure of whether the signal adds information on your instrument and timeframe. If EDGE is near zero, the signal is not helping there — and the tool says so.


Settings guide


01 · Data & Differencing — source, log-price toggle, differencing order d, weight tolerance, max window, and a universal price source for the harness.
02 · Normalization — z-score window and output smoothing.
03 · Calibration — horizon, favourable-move threshold (×ATR), base-rate window.
04 · Bands — momentum and extreme σ bands; divergence pivot.
05 · Display & Theme — visual style (gradient area + glow / histogram / line), regime tint, dashboard, colors.


Non-repaint

The weights are fixed and the convolution reads only closed bars — no recalculation of past values, no future leak.

Concept credit


Fixed-width window fractional differentiation — Marcos López de Prado, Advances in Financial Machine Learning (2018).
Fractional integration in time series — Hosking (1981); Granger & Joyeux (1980).


Disclaimer

For research and education only. Not financial advice, not a recommendation, and not a guarantee of future results. All statistics shown are in-sample, close-to-close, and exclude costs — a study aid, not a backtest. Do your own research and manage your own risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Market_Logic_India
//@version=6
// ═════════════════════════════════════════════════════════════════════════════════════════════════
//  FRACTIONAL-DIFFERENTIATION MOMENTUM OSCILLATOR                                              v2.1
// ─────────────────────────────────────────────────────────────────────────────────────────────────
//  OVERVIEW
//    A momentum oscillator built on FRACTIONAL differencing of price — the smallest amount of
//    differencing that makes the series statistically stationary while still PRESERVING its memory.
//    The result is a cleaner, more persistent momentum line than ordinary returns or RSI.
//
//  v2.0 — WHAT'S NEW
//    • AUTO min-d via a LIVE ADF test — instead of a fixed differencing order, the tool searches for
//      the SMALLEST d whose fractionally-differenced series passes an Augmented Dickey-Fuller
//      stationarity test (López de Prado's FFD objective: minimum differencing, maximum memory).
//    • On-panel ADF + KPSS stationarity readout — two complementary unit-root tests (ADF null =
//      unit root; KPSS null = stationary), each with its critical value, replacing the old lag-1
//      autocorrelation proxy. The ADF t-stat is computed exactly (validated against statsmodels).
//    • HARNESS+ — the Hit/Base/EDGE track-record is now honest three ways: a uniqueness-weighted
//      EFFECTIVE sample size, a multiple-testing DEFLATED significance bar, and an IN-SAMPLE /
//      OUT-OF-SAMPLE split (the OOS edge is the one to trust). Runs-test retained.
//    • Bug fix — the stationarity autocorrelation is no longer computed inside a conditional
//      (a stateful-ta call behind a ternary), so it can't silently skip bars.
//
//  WHAT MAKES IT DIFFERENT
//    Ordinary returns difference price once (order d = 1): stationary, but ALL memory is erased.
//    Raw price is order d = 0: full memory, but non-stationary and untradeable by most tools.
//    A FRACTIONAL order (≈0.3–0.6) sits between the two — keeping the long memory that carries trend
//    information while removing the drift that makes raw price unusable. Few retail oscillators apply
//    this transform; most just difference once and lose the signal.
//
//  HOW IT WORKS
//    The fixed-width fractional-difference weights are built recursively
//      w(0) = 1 ,  w(k) = -w(k-1) * (d - k + 1) / k
//    and truncated once they fall below a tolerance. They are convolved with log-price to produce the
//    fractionally-differenced series, which is then z-scored over the normalization window and lightly
//    smoothed into a standard-deviation (σ) oscillator centred on zero.
//
//  HOW TO USE
//    Zero is the balance line: above zero = net up-momentum, below = net down-momentum. The dashed
//    bands mark stretched momentum; the dotted bands mark extremes prone to exhaustion. Zero-crosses
//    (triangles) are the momentum-flip events. Price-vs-line divergences (circles) warn of fading
//    momentum behind a price extreme. Read the EDGE row before trusting any of it.
//
//  UNIVERSAL / SOURCES
//    Source, differencing order, tolerance, window cap and normalization are all inputs. Works on any
//    symbol and timeframe; defaults are tuned for index/NIFTY behaviour.
//
//  CONCEPT CREDIT (full references in the published description)
//    Fixed-width window fractional differentiation & minimum-d stationarity — Marcos López de Prado,
//    "Advances in Financial Machine Learning" (2018). Fractional integration in time series —
//    Hosking (1981); Granger & Joyeux (1980). Unit-root test — Dickey & Fuller (ADF). Stationarity
//    test — Kwiatkowski, Phillips, Schmidt & Shin (KPSS); long-run variance — Newey & West.
//
//  HONESTY
//    Fractional differencing is a TRANSFORM, not an edge. It yields a stationary, memory-aware
//    momentum line; whether its turns pay is exactly what the Hit / Base / EDGE harness measures.
//    Statistics are in-sample, close-to-close, without costs — a study aid, not a backtest.
//
//  CHANGELOG
//    v2.1 — Three optional accuracy upgrades over v2.0, all one-click reversible. The fixed-width
//      fractional differencing, the auto min-d ADF controller, the ADF / KPSS stationarity readout and
//      the full HARNESS+ track-record (effective N, deflated significance, in-sample / out-of-sample
//      split, runs-test) are unchanged:
//      • ROBUST z-score (Wave A, default ON). The fractionally-differenced series can be standardized
//        with a MEDIAN / MAD z (median absolute deviation × 1.4826) instead of mean / stdev, so a
//        single fat-tailed bar no longer stretches the whole sigma scale. ("Z-score mode".)
//      • ULTIMATESMOOTHER (Wave A, default ON). Output smoothing can use Ehlers' lag-minimal
//        UltimateSmoother instead of an EMA, so the σ-oscillator turns with less delay. ("Output
//        smoother"; applies when smoothing > 1.)
//      • 3-WINDOW EXTREME CONSENSUS (Wave D · U8, opt-in, default OFF). The z can be taken as the
//        MEDIAN of the z at half, one and double the normalization window, so a reading is extreme
//        only when short, medium and long agree. ("Extreme normalization" = "Single window" is the
//        original.)
//      Set Z-score mode = "Classic (mean/stdev)" and Output smoother = "EMA" for the original v2.0
//      behaviour. max_bars_back raised 600 → 2000 to reserve history for the median/MAD window on top
//      of the FFD convolution. No differencing, ACF or calibration logic changed.
//
//  DISCLAIMER
//    For research and education only. NOT financial advice, NOT a recommendation, NOT a guarantee of
//    future results. Do your own research and manage your own risk.
//
//  Non-repaint: weights are fixed; the convolution uses only closed bars.
// ═════════════════════════════════════════════════════════════════════════════════════════════════
indicator("Fractional-Diff Momentum Oscillator", "FracDiff Momentum", overlay = false, max_labels_count = 500, max_bars_back = 2000)

// ═════ Z · IDENTITY & EXPORTS ════════════════════════════════════════════════════════════════
gZ = "Z · Identity & exports"
showId  = input.bool(true, "Show identity strip", group = gZ)
showEXP = input.bool(true, "Publish EXP_* outputs (Data Window)", group = gZ, tooltip = "Generic export bus: surfaces in the Data Window and in other scripts via input.source().")
var table idT = table.new(position.bottom_center, 1, 1, force_overlay = true)
if barstate.islast and showId
    bool idDark = (0.299 * color.r(chart.bg_color) + 0.587 * color.g(chart.bg_color) + 0.114 * color.b(chart.bg_color)) < 140
    table.cell(idT, 0, 0, "FRACDIFF MOMENTUM · " + syminfo.ticker + " · " + timeframe.period, text_size = size.tiny, text_color = idDark ? color.white : color.black, bgcolor = color.new(idDark ? color.black : color.white, 15))

// ─── 01 · DATA & DIFFERENCING ──────────────────────────────────────────────────────────────────
g1 = "01 · Data & Differencing"
srcIn  = input.source(close, "Source", group = g1)
useLog = input.bool(true,  "Use log price", group = g1, tooltip = "Recommended: fractional differencing is defined on log-price.")
dMode  = input.string("Auto (min-d, ADF)", "Differencing order mode", options = ["Auto (min-d, ADF)", "Fixed"], group = g1, tooltip = "Auto searches for the SMALLEST d whose fractionally-differenced series passes the ADF stationarity test (max memory kept while stationary). Fixed uses the order below.")
dFrac  = input.float(0.40, "Differencing order d (Fixed / start)", minval = 0.05, maxval = 1.0, step = 0.05, group = g1, tooltip = "0 = raw price (full memory), 1 = returns (no memory). In Auto mode this is only the starting order. 0.3–0.6 keeps both.")
tauW   = input.float(0.0001,"Weight tolerance", minval = 0.000001, step = 0.0001, group = g1, tooltip = "Drop weights smaller than this. Smaller = longer memory window.")
maxW   = input.int(200,    "Max window", minval = 10, maxval = 500, group = g1)
srcPrice = input.source(close, "Price Source (for Edge/divergence)", group = g1, tooltip = "Reference price for divergences and the calibration harness.")

// ─── 01b · STATIONARITY (ADF / KPSS) ───────────────────────────────────────────────────────────
gA = "01b · Stationarity (ADF / KPSS)"
adfN     = input.int(120, "ADF / KPSS window", minval = 40, maxval = 400, group = gA, tooltip = "Bars used to compute the unit-root tests on the fractionally-differenced series.")
adfCrit  = input.float(-2.86, "ADF critical value (5% ≈ -2.86)", maxval = 0.0, step = 0.01, group = gA, tooltip = "The FFD series is judged stationary when its ADF t-stat is BELOW this. -2.86 = 5% (with constant); -3.43 = 1%.")
adfMarg  = input.float(0.75, "Auto-d memory margin", minval = 0.0, maxval = 3.0, step = 0.05, group = gA, tooltip = "Auto mode reduces d (keeps more memory) only when the ADF stat is this far BELOW the critical value — so it settles at the minimum stationary d rather than over-differencing.")
dStep    = input.float(0.05, "Auto-d step", minval = 0.01, maxval = 0.20, step = 0.01, group = gA)
scanEvery= input.int(25, "Auto-d re-scan every N bars", minval = 5, maxval = 200, group = gA, tooltip = "How often the auto-d controller re-checks stationarity and nudges d.")
kpssL    = input.int(6, "KPSS Newey-West lag", minval = 1, maxval = 24, group = gA)
kpssCrit = input.float(0.463, "KPSS critical value (5% ≈ 0.463)", minval = 0.1, step = 0.01, group = gA, tooltip = "KPSS null is STATIONARITY: the series is judged stationary when its statistic is BELOW this.")

// ─── 02 · NORMALIZATION ────────────────────────────────────────────────────────────────────────
g2 = "02 · Normalization"
normLen  = input.int(100, "Z-Score Window",   minval = 20, group = g2)
zMode    = input.string("Robust (MAD)", "Z-score mode", options = ["Robust (MAD)","Classic (mean/stdev)"], group = g2, tooltip = "Robust (MAD) standardizes the differenced series with median / median-absolute-deviation (×1.4826), so a single fat-tailed bar doesn't stretch the sigma scale. Classic reproduces the original.")
zWinMode = input.string("Single window", "Extreme normalization (Wave D · U8)", options = ["Single window","3-window consensus"], group = g2, tooltip = "Single window = the one Normalization window above (original). 3-window consensus = z is the MEDIAN of the z at half, one and double that window, so a reading is extreme only when short, medium and long agree. Default Single so nothing changes unless you opt in.")
smoothLen= input.int(3,   "Output Smoothing", minval = 1,  group = g2)
smootherType = input.string("UltimateSmoother (Wave A)", "Output smoother", options = ["UltimateSmoother (Wave A)","EMA"], group = g2, tooltip = "Applies when smoothing > 1. UltimateSmoother (Ehlers) is lag-minimal; EMA reproduces the original.")

// ─── 03 · CALIBRATION (Hit / Base / EDGE) ──────────────────────────────────────────────────────
g3 = "03 · Calibration Harness"
calcCal = input.bool(true, "Measure Edge",          group = g3)
calH    = input.int(10,  "Horizon (bars)",          minval = 1, group = g3)
calK    = input.float(1.0,"Favourable move (×ATR)", minval = 0.1, step = 0.1, group = g3)
calWin  = input.int(500, "Base-rate window",        minval = 50, group = g3)
trainN  = input.int(40,  "In-sample events (then OOS)", minval = 10, group = g3, tooltip = "HARNESS+: the first N resolved signals train (in-sample); every later signal is scored OUT-OF-SAMPLE. The OOS edge is the trustworthy one.")
nTests  = input.int(3,   "Edge significance · N tests (deflation)", minval = 1, maxval = 10, group = g3, tooltip = "HARNESS+: raise the significance bar for the number of things tested (Bonferroni-style z).")

// ─── 04 · BANDS ────────────────────────────────────────────────────────────────────────────────
g4 = "04 · Bands"
obSigma  = input.float(1.5, "Momentum Band (σ)", minval = 0.5, step = 0.1, group = g4)
extSigma = input.float(2.5, "Extreme Band (σ)",  minval = 0.5, step = 0.1, group = g4)
showDiv  = input.bool(true, "Show Divergences", group = g4)
divLb    = input.int(5, "Divergence Pivot", minval = 2, group = g4)

// ─── 05 · DISPLAY & THEME ──────────────────────────────────────────────────────────────────────
g5 = "05 · Display & Theme"
vizStyle = input.string("Gradient area + glow", "Visual style", options = ["Gradient area + glow", "Histogram", "Line"], group = g5, tooltip = "Gradient area + glow: filled area to the zero line, opacity scaling with conviction, under a neon line. Histogram: saturated columns. Line: glow line only.")
showRegime = input.bool(true, "Background regime tint", group = g5)
showDash   = input.bool(true, "Show Dashboard",         group = g5)
bullCol  = input.color(#2ebd85, "Bullish",       group = g5)
bearCol  = input.color(#f6465d, "Bearish",       group = g5)
midCol   = input.color(#f7c948, "Midline Glow",  group = g5)
upperBandCol = input.color(#f6465d, "Upper Band (overbought)", group = g5, tooltip = "Top extreme zone — red by default.")
lowerBandCol = input.color(#2ebd85, "Lower Band (oversold)",   group = g5, tooltip = "Bottom extreme zone — green by default.")

// ─── HELPERS ──────────────────────────────────────────────────────────────────────────────────
f_z(float v, float m, float s) => s > 0 ? (v - m) / s : 0.0
// robust z: median / MAD (×1.4826). ta.median calls unconditional → compiles clean.
f_robZ(float x, int len) =>
    float med = ta.median(x, len)
    float mad = ta.median(math.abs(x - med), len)
    mad > 1e-10 ? (x - med) / (1.4826 * mad) : 0.0
// Ehlers UltimateSmoother (Wave A) — lag-minimal; no ta.* inside, safe under a selector.
ml_ultimateSmoother(series float src, simple int period) =>
    float q  = math.exp(-1.414 * math.pi / period)
    float c1 = 2.0 * q * math.cos(1.414 * math.pi / period)
    float c2 = q * q
    float a0 = (1.0 + c1 + c2) / 4.0
    float us = src
    if bar_index >= 4
        us := (1.0 - a0) * src + (2.0 * a0 - c1) * nz(src[1]) + (c2 - a0) * nz(src[2]) + c1 * nz(us[1]) - c2 * nz(us[2])
    us
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

// ─── ADF unit-root t-stat (Dickey-Fuller, with constant; validated vs statsmodels) ────────────
// regress Δx_t = α + β·x_{t-1} over N points; returns t = β / SE(β). Stationary when t < critical.
f_adf(float x, simple int N) =>
    float sYL = 0.0
    float sDY = 0.0
    for i = 0 to N - 1
        sYL += x[i + 1]
        sDY += x[i] - x[i + 1]
    float mYL = sYL / N
    float mDY = sDY / N
    float Sxx = 0.0
    float Sxy = 0.0
    for i = 0 to N - 1
        float yl = x[i + 1] - mYL
        float dy = (x[i] - x[i + 1]) - mDY
        Sxx += yl * yl
        Sxy += yl * dy
    float b = Sxx > 0.0 ? Sxy / Sxx : na
    float a = na(b) ? na : mDY - b * mYL
    float sse = 0.0
    if not na(b)
        for i = 0 to N - 1
            float e = (x[i] - x[i + 1]) - (a + b * x[i + 1])
            sse += e * e
    float s2 = sse / math.max(N - 2, 1)
    float se = (not na(b) and Sxx > 0.0) ? math.sqrt(s2 / Sxx) : na
    (not na(b) and not na(se) and se > 0.0) ? b / se : na

// ─── KPSS level-stationarity statistic (Newey-West long-run variance) ─────────────────────────
// null = STATIONARY; series is stationary when the statistic is BELOW the critical value.
f_kpss(float x, simple int N, simple int L) =>
    float m = 0.0
    for i = 0 to N - 1
        m += x[i]
    m := m / N
    float S = 0.0
    float sumS2 = 0.0
    float g0 = 0.0
    for t = 0 to N - 1
        float u = x[N - 1 - t] - m
        S += u
        sumS2 += S * S
        g0 += u * u
    g0 := g0 / N
    float lam = g0
    for l = 1 to L
        float gl = 0.0
        for t = l to N - 1
            gl += (x[N - 1 - t] - m) * (x[N - 1 - (t - l)] - m)
        gl := gl / N
        lam := lam + 2.0 * (1.0 - l / (L + 1.0)) * gl
    lam > 0.0 ? (sumS2 / (N * N)) / lam : na

// ─── EFFECTIVE d (fixed or auto min-d via ADF) + FFD WEIGHTS (rebuilt on change) ────────────────
var float[] ffdW = array.new_float()
var float dEff     = dFrac
var float dApplied = na
var float adfPrev  = na            // previous ADF stat, drives the auto-d controller (no look-ahead)

if dMode == "Fixed"
    dEff := dFrac
else if barstate.isconfirmed and not na(adfPrev) and bar_index % scanEvery == 0
    if adfPrev > adfCrit
        dEff := math.min(1.0, dEff + dStep)            // not stationary → difference more
    else if adfPrev < adfCrit - adfMarg
        dEff := math.max(0.05, dEff - dStep)           // comfortably stationary → keep more memory

// rebuild the fixed-width weights whenever the effective order changes
if barstate.isfirst or na(dApplied) or dEff != dApplied
    ffdW.clear()
    ffdW.push(1.0)
    int k = 1
    bool go = true
    while go
        float wk = -ffdW.get(ffdW.size() - 1) * (dEff - k + 1) / k
        if math.abs(wk) < tauW or k >= maxW
            go := false
        else
            ffdW.push(wk)
            k += 1
    dApplied := dEff

// ─── FFD CONVOLUTION ──────────────────────────────────────────────────────────────────────────
float srcv = useLog ? math.log(srcIn) : srcIn
int   L    = ffdW.size()
float ffd  = na
if bar_index >= L and L > 0
    float s = 0.0
    for i = 0 to L - 1
        s += ffdW.get(i) * srcv[i]
    ffd := s

// compute BOTH z-scores unconditionally (Pine v6: ta.* must not sit in a branch), then select
// U8 (Wave D): z at three windows (unconditional), select by mode, optional median consensus.
int   _wS = math.max(5, int(normLen / 2))
int   _wL = int(normLen * 2)
float _zcS = f_z(ffd, ta.sma(ffd, _wS), ta.stdev(ffd, _wS)), _zcM = f_z(ffd, ta.sma(ffd, normLen), ta.stdev(ffd, normLen)), _zcL = f_z(ffd, ta.sma(ffd, _wL), ta.stdev(ffd, _wL))
float _zrS = f_robZ(ffd, _wS), _zrM = f_robZ(ffd, normLen), _zrL = f_robZ(ffd, _wL)
bool  _uCl = zMode == "Classic (mean/stdev)"
float _zS = _uCl ? _zcS : _zrS
float _zM = _uCl ? _zcM : _zrM
float _zL = _uCl ? _zcL : _zrL
float _zMed = _zS + _zM + _zL - math.min(_zS, math.min(_zM, _zL)) - math.max(_zS, math.max(_zM, _zL))
float oscZ = zWinMode == "Single window" ? _zM : _zMed
// same for the smoother — compute both, select (smoothLen 1 = passthrough, unchanged behaviour)
float oscEma = ta.ema(oscZ, smoothLen)
float oscUlt = ml_ultimateSmoother(oscZ, math.max(smoothLen, 2))
osc = smoothLen > 1 ? (smootherType == "EMA" ? oscEma : oscUlt) : oscZ
// lag-1 autocorrelation — hoisted to top level (ta.correlation is stateful; must not sit behind a ?:)
float acf1raw = ta.correlation(ffd, ffd[1], normLen)
float acf1 = not na(ffd) ? acf1raw : na

// ─── STATIONARITY: live ADF + KPSS on the fractionally-differenced series ────────────────────────
float adfStat  = bar_index > adfN + 2          ? f_adf(ffd, adfN)         : na
float kpssStat = bar_index > adfN + kpssL + 2  ? f_kpss(ffd, adfN, kpssL) : na
adfPrev := not na(adfStat) ? adfStat : adfPrev   // feed the auto-d controller (used next scan)
bool  adfOK  = not na(adfStat)  and adfStat  < adfCrit     // ADF null = unit root  → reject = stationary
bool  kpssOK = not na(kpssStat) and kpssStat < kpssCrit    // KPSS null = stationary → below crit = stationary
bool  statOK = adfOK

// ─── DIVERGENCE ───────────────────────────────────────────────────────────────────────────────
ph = ta.pivothigh(osc, divLb, divLb)
pl = ta.pivotlow(osc, divLb, divLb)
var float pOscH = na, var float pOscL = na, var float pPrcH = na, var float pPrcL = na
bool bullDiv = false, bool bearDiv = false, bool hBull = false, bool hBear = false
if not na(pl)
    float pr = low[divLb]
    if not na(pOscL)
        bullDiv := pl > pOscL and pr < pPrcL
        hBull   := pl < pOscL and pr > pPrcL
    pOscL := pl
    pPrcL := pr
if not na(ph)
    float pr = high[divLb]
    if not na(pOscH)
        bearDiv := ph < pOscH and pr > pPrcH
        hBear   := ph > pOscH and pr < pPrcH
    pOscH := ph
    pPrcH := pr

// ─── SIGNALS ──────────────────────────────────────────────────────────────────────────────────
bullTurn = ta.crossover(osc, 0)
bearTurn = ta.crossunder(osc, 0)
var int lastSigBar = na
var int lastSigDir = 0
if bullTurn
    lastSigBar := bar_index
    lastSigDir := 1
if bearTurn
    lastSigBar := bar_index
    lastSigDir := -1

// ─── CALIBRATION HARNESS (na-safe) ─────────────────────────────────────────────────────────────
atr    = ta.atr(14)
upEvt  = srcPrice >= srcPrice[calH] + calK * atr[calH]
dnEvt  = srcPrice <= srcPrice[calH] - calK * atr[calH]
baseUp = ta.sma(upEvt ? 1.0 : 0.0, calWin) * 100.0
baseDn = ta.sma(dnEvt ? 1.0 : 0.0, calWin) * 100.0

var int[]   cBar  = array.new_int()
var int[]   cDir  = array.new_int()
var float[] cEnt  = array.new_float()
var float[] cAtr  = array.new_float()
var float[] cBase = array.new_float()
var float[] cUniq = array.new_float()                 // HARNESS+ per-event uniqueness weight
var int hits = 0, var int tot = 0, var int baseN = 0
var float sumBase = 0.0
var int rtRuns = 0
var int rtLast = -1
var int rtN = 0
var int rtN1 = 0
var int rtN0 = 0
var float hitsW = 0.0, var float totW = 0.0           // uniqueness-weighted (effective N)
var int isHits = 0, var int isTot = 0                 // in-sample
var int oosHits = 0, var int oosTot = 0               // out-of-sample
var int resolvedC = 0

if calcCal and bullTurn and not na(baseUp)
    float uw = 1.0 / (1.0 + cBar.size())
    cBar.push(bar_index), cDir.push(1),  cEnt.push(srcPrice), cAtr.push(atr), cBase.push(baseUp), cUniq.push(uw)
if calcCal and bearTurn and not na(baseDn)
    float uw = 1.0 / (1.0 + cBar.size())
    cBar.push(bar_index), cDir.push(-1), cEnt.push(srcPrice), cAtr.push(atr), cBase.push(baseDn), cUniq.push(uw)

if cBar.size() > 0
    for i = cBar.size() - 1 to 0
        if bar_index - cBar.get(i) >= calH
            int d = cDir.get(i)
            float fav = d == 1 ? srcPrice - cEnt.get(i) : cEnt.get(i) - srcPrice
            bool  win = fav >= calK * cAtr.get(i)
            float w   = cUniq.get(i)
            if win
                hits += 1
                hitsW += w
            tot += 1
            totW += w
            if resolvedC < trainN
                isTot += 1
                isHits := win ? isHits + 1 : isHits
            else
                oosTot += 1
                oosHits := win ? oosHits + 1 : oosHits
            resolvedC += 1
            int rtO = win ? 1 : 0
            if rtN > 0 and rtO != rtLast
                rtRuns += 1
            rtLast := rtO
            rtN += 1
            if rtO == 1
                rtN1 += 1
            else
                rtN0 += 1
            float b = cBase.get(i)
            if not na(b)
                sumBase += b
                baseN += 1
            cBar.remove(i), cDir.remove(i), cEnt.remove(i), cAtr.remove(i), cBase.remove(i), cUniq.remove(i)

float hitPct  = tot   > 0 ? hits / tot * 100.0 : na
float basePct = baseN > 0 ? sumBase / baseN     : na
float edge    = not na(hitPct) and not na(basePct) ? hitPct - basePct : na
float effN    = totW
float oosHitPct = oosTot > 0 ? oosHits / float(oosTot) * 100.0 : na
float oosEdge   = (not na(oosHitPct) and not na(basePct)) ? oosHitPct - basePct : na

// ─── Wilson significance + edge-floor + runs-test ────────────────────────────────────────────
float zDefl  = nTests <= 1 ? 1.96 : nTests == 2 ? 2.24 : nTests == 3 ? 2.39 : nTests == 4 ? 2.50 : 2.58
float ciPct  = f_wilson(hits, tot, 1.96) * 100.0
// star on the EFFECTIVE-N weighted rate at the deflated bar (honest significance)
float hitPctW = totW > 0.0 ? hitsW / totW * 100.0 : na
float ciPctW  = f_wilson(hitsW, totW, zDefl) * 100.0
bool  sigStar = totW >= 15.0 and not na(hitPctW) and not na(basePct) and (hitPctW - ciPctW) > basePct
float edgeLB = not na(hitPct) and not na(ciPct) and not na(basePct) ? (hitPct - ciPct) - basePct : na
// out-of-sample star (the trustworthy one)
float oosCi   = f_wilson(oosHits, oosTot, zDefl) * 100.0
bool  oosStar = oosTot >= 10 and not na(oosHitPct) and not na(basePct) and (oosHitPct - oosCi) > basePct
float rtMu  = rtN > 1 ? 2.0 * rtN1 * rtN0 / rtN + 1.0 : na
float rtVar = rtN > 1 ? 2.0 * rtN1 * rtN0 * (2.0 * rtN1 * rtN0 - rtN) / (rtN * rtN * (rtN - 1.0)) : na
float runsZ = not na(rtVar) and rtVar > 0 ? (rtRuns - rtMu) / math.sqrt(rtVar) : na

// ─── RENDER STYLE ──────────────────────────────────────────────────────────────────────────────
isGrad = vizStyle == "Gradient area + glow"
isHist = vizStyle == "Histogram"
oscCol = color.from_gradient(osc, -extSigma, extSigma, bearCol, bullCol)
float intensity = math.min(math.abs(osc) / math.max(extSigma, 0.0001), 1.0)

bgcolor(showRegime and osc >= extSigma ? color.new(bearCol, 90) : showRegime and osc <= -extSigma ? color.new(bullCol, 90) : na, title = "Regime tint")

// Reference levels + gradient extreme-zone bands (upper red, lower green)
hline(0, "Zero", color.new(chart.fg_color, 70))
pUpLean = plot(obSigma,   "Upper Lean Line",    color.new(upperBandCol, 55), 1, display = display.pane, editable = false)
pUpExt  = plot(extSigma,  "Upper Extreme Line", color.new(upperBandCol, 70), 1, display = display.pane, editable = false)
pDnLean = plot(-obSigma,  "Lower Lean Line",    color.new(lowerBandCol, 55), 1, display = display.pane, editable = false)
pDnExt  = plot(-extSigma, "Lower Extreme Line", color.new(lowerBandCol, 70), 1, display = display.pane, editable = false)
fill(pUpExt, pUpLean,  extSigma,  obSigma,  color.new(upperBandCol, 55), color.new(upperBandCol, 90), title = "Upper Band")
fill(pDnLean, pDnExt, -obSigma, -extSigma, color.new(lowerBandCol, 90), color.new(lowerBandCol, 55), title = "Lower Band")

// Signature yellow glow midline
plot(0, "Midline glow", color.new(midCol, 80), 3, display = display.pane)
plot(0, "Midline",      color.new(midCol, 45), 1, display = display.pane)

// Gradient area to zero
mid = plot(0, "base", display = display.none, editable = false)
op  = plot(isGrad ? osc : na, "area", display = display.none, editable = false)
fill(op, mid, color.new(oscCol, 92 - int(intensity * 55)), title = "Gradient area")

// Histogram
plot(isHist ? osc : na, "Histogram", color.new(oscCol, 35), style = plot.style_columns)

// 3-layer glow line
plot(not isHist ? osc : na, "glow outer", color.new(oscCol, 88), 6, display = display.pane)
plot(not isHist ? osc : na, "glow inner", color.new(oscCol, 70), 3, display = display.pane)
plot(not isHist ? osc : na, "FracDiff", oscCol, 2)

// Turn + divergence marks (in-pane)
plotshape(bullTurn, "Bull Turn", shape.triangleup,   location.bottom, bullCol, size = size.tiny)
plotshape(bearTurn, "Bear Turn", shape.triangledown, location.top,    bearCol, size = size.tiny)

// Momentum-turn signals on the PRICE chart — tiny directional triangles, proper colour:
// green up (below bar) = momentum flipped positive · red down (above bar) = momentum flipped negative
plotshape(bullTurn, "Momentum up (overlay)",   shape.triangleup,   location.belowbar, color = bullCol, size = size.tiny, force_overlay = true)
plotshape(bearTurn, "Momentum down (overlay)", shape.triangledown, location.abovebar, color = bearCol, size = size.tiny, force_overlay = true)
plotshape(showDiv and bullDiv ? osc[divLb] : na, "Bull Div", shape.circle, location.absolute, bullCol, -divLb, size = size.tiny)
plotshape(showDiv and bearDiv ? osc[divLb] : na, "Bear Div", shape.circle, location.absolute, bearCol, -divLb, size = size.tiny)
plotshape(showDiv and hBull ? osc[divLb] : na, "Hidden Bull", shape.cross, location.absolute, color.new(bullCol, 30), -divLb, size = size.tiny)
plotshape(showDiv and hBear ? osc[divLb] : na, "Hidden Bear", shape.cross, location.absolute, color.new(bearCol, 30), -divLb, size = size.tiny)

// ─── DASHBOARD (theme-adaptive, zebra) ─────────────────────────────────────────────────────────
f_row(int r) => color.new(chart.fg_color, r % 2 == 0 ? 92 : 96)
var table dash = table.new(position.top_right, 2, 12, frame_color = color.new(chart.fg_color, 60), frame_width = 1, border_color = color.new(chart.fg_color, 80), border_width = 1)
if barstate.islast and showDash
    string zone = osc >= extSigma ? "Extreme +" : osc >= obSigma ? "Strong +" : osc <= -extSigma ? "Extreme -" : osc <= -obSigma ? "Strong -" : "Neutral"
    color  zc   = osc >= obSigma ? bullCol : osc <= -obSigma ? bearCol : color.new(chart.fg_color, 25)
    string sigTxt = na(lastSigBar) ? "—" : (lastSigDir == 1 ? "Up " : "Dn ") + str.tostring(bar_index - lastSigBar) + "b"
    table.cell(dash, 0, 0, "FRACDIFF MOMENTUM", text_color = chart.bg_color, bgcolor = zc, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 0, zone, text_color = chart.bg_color, bgcolor = zc, text_size = size.tiny)
    table.cell(dash, 0, 1, "Value (σ)", text_color = chart.fg_color, bgcolor = f_row(1), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 1, str.tostring(osc, "#.##"), text_color = zc, bgcolor = f_row(1), text_size = size.tiny)
    table.cell(dash, 0, 2, "Order d / window", text_color = chart.fg_color, bgcolor = f_row(2), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 2, str.tostring(dEff, "#.##") + (dMode == "Fixed" ? " fix" : " auto") + " / " + str.tostring(L), text_color = chart.fg_color, bgcolor = f_row(2), text_size = size.tiny)
    table.cell(dash, 0, 3, "Last Signal", text_color = chart.fg_color, bgcolor = f_row(3), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 3, sigTxt, text_color = na(lastSigBar) ? color.new(chart.fg_color, 30) : (lastSigDir == 1 ? bullCol : bearCol), bgcolor = f_row(3), text_size = size.tiny)
    table.cell(dash, 0, 4, "Hit %", text_color = chart.fg_color, bgcolor = f_row(4), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 4, na(hitPct) ? "—" : str.tostring(hitPct, "#.#") + "%", text_color = chart.fg_color, bgcolor = f_row(4), text_size = size.tiny)
    table.cell(dash, 0, 5, "Base %", text_color = chart.fg_color, bgcolor = f_row(5), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 5, na(basePct) ? "—" : str.tostring(basePct, "#.#") + "%", text_color = color.new(chart.fg_color, 30), bgcolor = f_row(5), text_size = size.tiny)
    table.cell(dash, 0, 6, "EDGE", text_color = chart.fg_color, bgcolor = f_row(6), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 6, na(edge) ? "—" : (edge >= 0 ? "+" : "") + str.tostring(edge, "#.#") + "%", text_color = chart.bg_color, bgcolor = na(edge) ? f_row(6) : (edge > 0 ? bullCol : bearCol), text_size = size.tiny)
    table.cell(dash, 0, 7, "ADF (unit-root)", text_color = chart.fg_color, bgcolor = f_row(7), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 7, na(adfStat) ? "—" : str.tostring(adfStat, "#.##") + " / " + str.tostring(adfCrit, "#.##") + (adfOK ? " ✓" : " ✕"), text_color = adfOK ? bullCol : bearCol, bgcolor = f_row(7), text_size = size.tiny)
    table.cell(dash, 0, 8, "KPSS (stationarity)", text_color = chart.fg_color, bgcolor = f_row(8), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 8, na(kpssStat) ? "—" : str.tostring(kpssStat, "#.###") + " / " + str.tostring(kpssCrit, "#.###") + (kpssOK ? " ✓" : " ✕"), text_color = kpssOK ? bullCol : bearCol, bgcolor = f_row(8), text_size = size.tiny)
    table.cell(dash, 0, 9, "Edge floor", text_color = chart.fg_color, bgcolor = f_row(9), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 9, na(edgeLB) ? "—" : (sigStar ? "★ " : "") + (edgeLB >= 0 ? "+" : "") + str.tostring(edgeLB, "#.#") + "%", text_color = chart.bg_color, bgcolor = na(edgeLB) ? f_row(9) : (edgeLB > 0 ? bullCol : bearCol), text_size = size.tiny)
    table.cell(dash, 0, 10, "EDGE (OOS)", text_color = chart.fg_color, bgcolor = f_row(10), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 10, na(oosEdge) ? "—" : (oosStar ? "★ " : "") + (oosEdge >= 0 ? "+" : "") + str.tostring(oosEdge, "#.#") + "%", text_color = na(oosEdge) ? color.new(chart.fg_color, 30) : chart.bg_color, bgcolor = na(oosEdge) ? f_row(10) : (oosEdge > 0 ? bullCol : bearCol), text_size = size.tiny)
    table.cell(dash, 0, 11, "Eff-N (IS/OOS)", text_color = chart.fg_color, bgcolor = f_row(11), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 11, str.tostring(effN, "#.#") + "  (" + str.tostring(isTot) + "/" + str.tostring(oosTot) + ")", text_color = chart.fg_color, bgcolor = f_row(11), text_size = size.tiny)

// ─── EXP_* EXPORT BUS (generic; Data Window) ─────────────────────────────────────────────────
plot(showEXP ? osc              : na, "EXP_Osc",        color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? dEff             : na, "EXP_dEff",       color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? acf1             : na, "EXP_ACF1",       color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? adfStat          : na, "EXP_ADF",        color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? kpssStat         : na, "EXP_KPSS",       color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? (statOK ? 1 : 0) : na, "EXP_Stationary", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? edge             : na, "EXP_Edge",       color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? oosEdge          : na, "EXP_EdgeOOS",    color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? edgeLB           : na, "EXP_EdgeLB",     color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? effN             : na, "EXP_EffN",       color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? runsZ            : na, "EXP_RunsZ",      color = color.new(color.gray, 100), display = display.data_window)

// ─── ALERTS ───────────────────────────────────────────────────────────────────────────────────
alertcondition(bullTurn, "Momentum up",   "Fractional-diff momentum turned positive")
alertcondition(bearTurn, "Momentum down", "Fractional-diff momentum turned negative")
alertcondition(bullDiv,  "Bullish divergence", "Price lower low; momentum higher low")
alertcondition(bearDiv,  "Bearish divergence", "Price higher high; momentum lower high")
````
