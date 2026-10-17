# Wavelet Energy Oscillator

- url: https://www.tradingview.com/script/yfP0jln9-Wavelet-Energy-Oscillator/
- type: indicator
- pine_id: PUB;520eeef031a14b98985dc5914327a3c8
- version: 3.0

## Description

Wavelet Energy Oscillator 

What it does

The Wavelet Energy Oscillator decomposes price into three cycle bands at once — fast, mid and slow — and shows two things together: a single composite momentum line (in σ units) and a live energy spectrum telling you which band currently drives the market.

Why this is different (and original)

Cycle and dominant-period tools lock onto one period and follow it. The problem is that markets hand control between timescales: a fast, choppy regime gives way to a slower swing, and a single-period reading only turns after that has happened. By running a bank of band-pass filters in parallel and measuring the energy in each band, this oscillator shows the whole spectrum simultaneously — so a fast band losing energy to a slow band is visible as an early footprint of a regime change. Presenting the live energy split next to a dominant-band-coloured composite, with a built-in edge test, is what makes it original.

How it works


Three band-pass filters (recursive, near-orthogonal) are centred on the fast, mid and slow periods you choose.
Each band's energy is its smoothed squared output. The three energies are normalized to percentage shares so the dashboard reads as a live spectrum.
The composite is the summed band output, z-scored over the normalization window into the σ oscillator and coloured by whichever band currently dominates.


How to use it


Read the spectrum first. Fast share dominant → short, choppy moves; slow share dominant → a longer swing is in control; a shift between them flags a changing regime.
Composite zero-crosses (triangles) time the swing in the dominant band; the σ bands (red top, green bottom) flag stretched readings.
The line's colour tells you which timeframe is driving at a glance.
Read the EDGE row. The harness checks whether composite crosses preceded a favourable ≥ k×ATR move within the horizon, versus the unconditional Base %. EDGE = Hit − Base.


Settings guide


01 · Cycle Bands — source, the three centre periods, bandwidth (narrow = sharper/ringier, wide = smoother), energy smoothing, universal price source.
02 · Normalization — z-score window, output smoothing.
03 · Calibration — horizon, favourable-move threshold (×ATR), base-rate window.
04 · Bands — swing and extreme σ bands.
05 · Display & Theme — visual style, regime tint, dashboard, and per-band + band-zone colors.


Non-repaint

All filters are recursive and run on closed bars — no recalculation of history, no future leak.

Concept credit


Band-pass / roofing digital-signal-processing filters for market cycles — John Ehlers, Cycle Analytics for Traders (2013) and Rocket Science for Traders (2001).


Disclaimer

For research and education only. Not financial advice, not a recommendation, and not a guarantee of future results. Market cycles are non-stationary — band energy describes the recent spectrum, it does not predict it. All statistics are in-sample, close-to-close, and exclude costs. Do your own research and manage your own risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Market_Logic_India
//@version=6
// ═════════════════════════════════════════════════════════════════════════════════════════════════
//  MULTI-RESOLUTION WAVELET ENERGY OSCILLATOR                                                    v2.1
//  v2.1 (Wave A + Wave D · U8): robust MAD z-score + Ehlers UltimateSmoother on the composite, both
//    optional (default ON) and reversible via "Z-score mode" / "Output smoother"; plus an opt-in
//    3-window extreme consensus ("Extreme normalization", default OFF) — the z taken as the MEDIAN of
//    the z at half, one and double the window, so a reading is extreme only when short, medium and
//    long agree. Set Z-score mode = "Classic (mean/stdev)", Output smoother = "EMA" and Extreme
//    normalization = "Single window" for the original v2.0 output. max_bars_back raised 300 → 2000 for
//    the median/MAD window. No spectrum, multifractal or calibration logic changed.
// ─────────────────────────────────────────────────────────────────────────────────────────────────
//  v2.0 — WHAT'S NEW
//    • REAL WAVELET TRANSFORM. The three ad-hoc band-pass filters are replaced by a genuine, shift-
//      invariant MODWT (Maximal-Overlap Discrete Wavelet Transform) computed by the causal à-trous
//      algorithm with a Daubechies-4 (or Haar) filter. Five undecimated scales (≈2·4·8·16·32 bars)
//      are extracted; because the MODWT is not decimated it is translation-invariant — the reading
//      does not jump when a new bar arrives, which a decimated DWT would.
//    • MULTIFRACTAL WAVELET-LEADERS SPECTRUM. From the wavelet coefficients the script builds wavelet
//      LEADERS (the local cross-scale suprema) and estimates the first two log-cumulants of their
//      distribution across scale: c1 (the self-similarity / Hurst exponent — persistence vs roughness)
//      and c2 (the multifractality width — 0 = uniform/monofractal, strongly negative = intermittent /
//      bursty / turbulent). c2 is an early fragility read that a single-scale oscillator cannot give.
//    • HARNESS+ on the forward test: uniqueness-weighted effective sample, in-sample / out-of-sample
//      split (the OOS edge is the one to trust) and a multiple-testing deflated significance bar.
//    • Compact (default) / Pro dashboard and on-price overlay signals.
//
//  OVERVIEW
//    A spectral oscillator that decomposes price into FIVE wavelet scales at once via a shift-invariant
//    MODWT, shows which scale currently holds the market's energy, reads the multifractal geometry of
//    the tape (Hurst c1 and multifractality c2), and tracks a single composite line.
//
//  WHAT MAKES IT DIFFERENT
//    Single-cycle tools lock onto ONE dominant period and follow it. A genuine MODWT reads the whole
//    scale ladder simultaneously and shift-invariantly, so you can SEE a fast scale handing energy to a
//    slow one — an early footprint of a regime change — and the wavelet-leaders c1/c2 tell you whether
//    the tape is smooth-and-persistent or rough-and-intermittent, which a band-pass filter cannot.
//
//  HOW IT WORKS
//    The MODWT (à-trous, Daubechies-4) produces, at each of five scales, an undecimated detail series;
//    each scale's ENERGY is its smoothed squared coefficient, normalized to percentage SHARES so you can
//    read the live spectrum (grouped fast / mid / slow for the dashboard). The composite line is price
//    minus the level-5 wavelet smooth (the multi-scale cyclical component), z-scored into a standard-
//    deviation (σ) oscillator and coloured by the scale group that currently dominates. Wavelet leaders
//    (cross-scale local suprema of the coefficients) give the multifractal log-cumulants c1 and c2.
//
//  HOW TO USE
//    Watch the dashboard spectrum: when the FAST share dominates, moves are short and choppy; when SLOW
//    dominates, a longer swing is in control. The composite's zero-crosses (triangles) time the swing in
//    the dominant band; the σ bands flag stretched readings. The dominant-band colour on the line tells
//    you which timeframe is driving. Read the EDGE row to see whether the crosses paid.
//
//  UNIVERSAL / SOURCES
//    Source, wavelet filter (Daubechies-4 / Haar), energy smoothing, the multifractal window and the
//    normalization are all inputs. Works on any symbol and timeframe; defaults suit index/NIFTY swing
//    structure.
//
//  CONCEPT CREDIT (full references in the published description)
//    Maximal-overlap DWT (MODWT) and the à-trous algorithm — Percival & Walden, "Wavelet Methods for
//    Time Series Analysis" (2000); Shensa (1992). Daubechies wavelets — I. Daubechies (1988).
//    Wavelet leaders and multifractal log-cumulants — Jaffard; Wendt, Abry & Jaffard (2007).
//    Out-of-sample / uniqueness weighting — López de Prado (2018).
//
//  HONESTY
//    Market cycles are non-stationary. Band energy describes the RECENT spectrum; it does not predict.
//    Statistics are in-sample, close-to-close, without costs. Read the Edge row.
//
//  DISCLAIMER
//    For research and education only. NOT financial advice, NOT a recommendation, NOT a guarantee of
//    future results. Do your own research and manage your own risk.
//
//  Non-repaint: all filters are recursive on closed bars.
// ═════════════════════════════════════════════════════════════════════════════════════════════════
indicator("Wavelet Energy Oscillator", "Wavelet Energy", overlay = false, max_labels_count = 500, max_bars_back = 2000)

// ═════ Z · IDENTITY & EXPORTS ════════════════════════════════════════════════════════════════
gZ = "Z · Identity & exports"
showId  = input.bool(true, "Show identity strip", group = gZ)
showEXP = input.bool(true, "Publish EXP_* outputs (Data Window)", group = gZ, tooltip = "Generic export bus: surfaces in the Data Window and in other scripts via input.source().")
var table idT = table.new(position.bottom_center, 1, 1, force_overlay = true)
if barstate.islast and showId
    bool idDark = (0.299 * color.r(chart.bg_color) + 0.587 * color.g(chart.bg_color) + 0.114 * color.b(chart.bg_color)) < 140
    table.cell(idT, 0, 0, "WAVELET ENERGY · " + syminfo.ticker + " · " + timeframe.period, text_size = size.tiny, text_color = idDark ? color.white : color.black, bgcolor = color.new(idDark ? color.black : color.white, 15))

// ─── 01 · WAVELET (MODWT) ────────────────────────────────────────────────────────────────────
g1 = "01 · Wavelet (MODWT)"
srcIn = input.source(hl2, "Source", group = g1)
waveType = input.string("Daubechies-4", "Wavelet", options = ["Daubechies-4", "Haar"], group = g1, tooltip = "Filter for the shift-invariant MODWT. Daubechies-4 is smoother with better frequency separation; Haar is the sharpest, most localised.")
eLen  = input.int(20, "Energy Smoothing", minval = 2, maxval = 200, group = g1, tooltip = "Window that smooths each scale's squared coefficients into its wavelet energy.")
mfWin = input.int(120, "Multifractal window", minval = 30, maxval = 500, group = g1, tooltip = "Window over which the wavelet-leader log-cumulants c1 (Hurst) and c2 (multifractality) are estimated.")
srcPrice = input.source(close, "Price Source (for Edge/divergence)", group = g1)

// ─── 02 · NORMALIZATION ────────────────────────────────────────────────────────────────────────
g2 = "02 · Normalization"
normLen  = input.int(100, "Z-Score Window",   minval = 20, group = g2)
zMode    = input.string("Robust (MAD)", "Z-score mode", options = ["Robust (MAD)","Classic (mean/stdev)"], group = g2, tooltip = "Robust (MAD) standardizes the composite with median / median-absolute-deviation (×1.4826), so outlier bars don't distort the σ scale. Classic reproduces the original.")
zWinMode = input.string("Single window", "Extreme normalization (Wave D · U8)", options = ["Single window","3-window consensus"], group = g2, tooltip = "Single window = the one Normalization window above (original). 3-window consensus = z is the MEDIAN of the z at half, one and double that window, so a reading is extreme only when short, medium and long agree. Default Single so nothing changes unless you opt in.")
smoothLen= input.int(2,   "Output Smoothing", minval = 1,  group = g2)
smootherType = input.string("UltimateSmoother (Wave A)", "Output smoother", options = ["UltimateSmoother (Wave A)","EMA"], group = g2, tooltip = "Applies when smoothing > 1. UltimateSmoother (Ehlers) is lag-minimal; EMA reproduces the original.")

// ─── 03 · CALIBRATION (Hit / Base / EDGE) ──────────────────────────────────────────────────────
g3 = "03 · Calibration Harness"
calcCal = input.bool(true, "Measure Edge",          group = g3)
calH    = input.int(10,  "Horizon (bars)",          minval = 1, group = g3)
calK    = input.float(1.0,"Favourable move (×ATR)", minval = 0.1, step = 0.1, group = g3)
calWin  = input.int(500, "Base-rate window",        minval = 50, group = g3)
harTrainN = input.int(40, "HARNESS+ in-sample events (then OOS)", minval = 10, group = g3, tooltip = "First N resolved composite turns train (in-sample); every later one is scored OUT-OF-SAMPLE. The OOS edge is the trustworthy one.")
nTests    = input.int(2, "Edge significance · N tests (deflation)", minval = 1, maxval = 10, group = g3, tooltip = "Raise the significance bar for the number of signal classes tested (Bonferroni-style z). Up and down turns → 2 → z ≈ 2.24.")

// ─── 04 · BANDS ────────────────────────────────────────────────────────────────────────────────
g4 = "04 · Bands"
obSigma  = input.float(1.5, "Swing Band (σ)",   minval = 0.5, step = 0.1, group = g4)
extSigma = input.float(2.5, "Extreme Band (σ)", minval = 0.5, step = 0.1, group = g4)

// ─── 05 · DISPLAY & THEME ──────────────────────────────────────────────────────────────────────
g5 = "05 · Display & Theme"
vizStyle = input.string("Gradient area + glow", "Visual style", options = ["Gradient area + glow", "Histogram", "Line"], group = g5)
showRegime = input.bool(true, "Background regime tint", group = g5)
showOverlaySig = input.bool(true, "On-price overlay signals", group = g5, tooltip = "Plot composite turns on the PRICE chart as tiny triangles (green up / red down).")
dashMode   = input.string("Compact", "Dashboard detail", options = ["Compact", "Pro"], group = g5, tooltip = "Compact (default): dominant scale, the spectrum, value, Hurst/multifractality and the out-of-sample edge. Pro: adds the full energy spectrum, hit/base and the edge floor.")
showDash   = input.bool(true, "Show Dashboard",         group = g5)
fastCol  = input.color(#2ebd85, "Fast band", group = g5)
midColor = input.color(#ffb300, "Mid band",  group = g5)
slowCol  = input.color(#f6465d, "Slow band", group = g5)
midCol   = input.color(#f7c948, "Midline Glow", group = g5)
upperBandCol = input.color(#f6465d, "Upper Band", group = g5, tooltip = "Top extreme zone — red by default.")
lowerBandCol = input.color(#2ebd85, "Lower Band", group = g5, tooltip = "Bottom extreme zone — green by default.")

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
// MODWT scaling filter g~ (sums to 1) and wavelet filter h~ (sums to 0), padded to 4 taps.
bool useD4 = waveType == "Daubechies-4"
float G0 = useD4 ?  0.341506350946 : 0.5
float G1 = useD4 ?  0.591506350946 : 0.5
float G2 = useD4 ?  0.158493649054 : 0.0
float G3 = useD4 ? -0.091506350946 : 0.0
float H0 = useD4 ? -0.091506350946 : 0.5
float H1 = useD4 ? -0.158493649054 : -0.5
float H2 = useD4 ?  0.591506350946 : 0.0
float H3 = useD4 ? -0.341506350946 : 0.0
// one MODWT level: wavelet W and scaling V from the previous scaling series vp at spacing s (à-trous)
f_modwt(float vp, int s) =>
    float V = G0 * vp + G1 * vp[s] + G2 * vp[2 * s] + G3 * vp[3 * s]
    float W = H0 * vp + H1 * vp[s] + H2 * vp[2 * s] + H3 * vp[3 * s]
    [W, V]

// ─── FIVE-SCALE SHIFT-INVARIANT MODWT (à-trous) ──────────────────────────────────────────────────
[W1, V1] = f_modwt(srcIn, 1)
[W2, V2] = f_modwt(V1, 2)
[W3, V3] = f_modwt(V2, 4)
[W4, V4] = f_modwt(V3, 8)
[W5, V5] = f_modwt(V4, 16)

// per-scale wavelet energy (smoothed squared coefficients)
float en1 = ta.sma(W1 * W1, eLen)
float en2 = ta.sma(W2 * W2, eLen)
float en3 = ta.sma(W3 * W3, eLen)
float en4 = ta.sma(W4 * W4, eLen)
float en5 = ta.sma(W5 * W5, eLen)
float enTot = en1 + en2 + en3 + en4 + en5
// grouped fast (scales ~2-4) / mid (~8) / slow (~16-32) energy shares for the dashboard
float sh1 = enTot > 0 ? (en1 + en2) / enTot * 100.0 : 0.0
float sh2 = enTot > 0 ? en3 / enTot * 100.0 : 0.0
float sh3 = enTot > 0 ? (en4 + en5) / enTot * 100.0 : 0.0
color  domCol  = sh1 >= sh2 and sh1 >= sh3 ? fastCol : sh2 >= sh3 ? midColor : slowCol
string domName = sh1 >= sh2 and sh1 >= sh3 ? "FAST" : sh2 >= sh3 ? "MID" : "SLOW"

// composite = price minus the level-5 wavelet smooth (the multi-scale cyclical component)
comp = srcIn - V5
// Wave A: compute both z-scores + both smoothers unconditionally, then select
// U8 (Wave D): z at three windows (unconditional), select by mode, optional median consensus.
int   _wS = math.max(5, int(normLen / 2))
int   _wL = int(normLen * 2)
float _zcS = f_z(comp, ta.sma(comp, _wS), ta.stdev(comp, _wS)), _zcM = f_z(comp, ta.sma(comp, normLen), ta.stdev(comp, normLen)), _zcL = f_z(comp, ta.sma(comp, _wL), ta.stdev(comp, _wL))
float _zrS = f_robZ(comp, _wS), _zrM = f_robZ(comp, normLen), _zrL = f_robZ(comp, _wL)
bool  _uCl = zMode == "Classic (mean/stdev)"
float _zS = _uCl ? _zcS : _zrS
float _zM = _uCl ? _zcM : _zrM
float _zL = _uCl ? _zcL : _zrL
float _zMed = _zS + _zM + _zL - math.min(_zS, math.min(_zM, _zL)) - math.max(_zS, math.max(_zM, _zL))
float compZ = zWinMode == "Single window" ? _zM : _zMed
float compEma  = ta.ema(compZ, smoothLen)
float compUlt  = ml_ultimateSmoother(compZ, math.max(smoothLen, 2))
osc  = smoothLen > 1 ? (smootherType == "EMA" ? compEma : compUlt) : compZ

// ─── WAVELET-LEADERS MULTIFRACTAL SPECTRUM (log-cumulants c1 = Hurst, c2 = multifractality) ───────
// Leaders = cross-scale cumulative sup of |W| up to each scale, then a small causal neighbourhood max.
int nbr = 3
float cum1 = math.abs(W1)
float cum2 = math.max(cum1, math.abs(W2))
float cum3 = math.max(cum2, math.abs(W3))
float cum4 = math.max(cum3, math.abs(W4))
float cum5 = math.max(cum4, math.abs(W5))
float ld1 = math.log(ta.highest(cum1, nbr) + 1e-10)
float ld2 = math.log(ta.highest(cum2, nbr) + 1e-10)
float ld4 = math.log(ta.highest(cum4, nbr) + 1e-10)
float ld5 = math.log(ta.highest(cum5, nbr) + 1e-10)
// per-scale log-cumulants; least-squares slope over scales j=1,2,4,5 (Σ(j-mean)²=10); /ln2 per octave
float m1 = ta.sma(ld1, mfWin)
float m2 = ta.sma(ld2, mfWin)
float m4 = ta.sma(ld4, mfWin)
float m5 = ta.sma(ld5, mfWin)
float sd1 = ta.stdev(ld1, mfWin)
float sd2 = ta.stdev(ld2, mfWin)
float sd4 = ta.stdev(ld4, mfWin)
float sd5 = ta.stdev(ld5, mfWin)
float ln2 = math.log(2.0)
float c1 = (-2.0 * m1 - m2 + m4 + 2.0 * m5) / (10.0 * ln2)
float c2 = (-2.0 * sd1 * sd1 - sd2 * sd2 + sd4 * sd4 + 2.0 * sd5 * sd5) / (10.0 * ln2)

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
var float[] cUniq = array.new_float()          // HARNESS+ per-event uniqueness weight
var int hits = 0, var int tot = 0, var int baseN = 0
var float sumBase = 0.0
var int rtRuns = 0
var int rtLast = -1
var int rtN = 0
var int rtN1 = 0
var int rtN0 = 0
// HARNESS+ — uniqueness-weighted, in-sample / out-of-sample split
var float harTotN   = 0.0
var float harIsN    = 0.0
var float harIsW    = 0.0
var float harOosN   = 0.0
var float harOosW   = 0.0
var float harOosBs  = 0.0
var int   harResolved = 0

if calcCal and bullTurn and not na(baseUp)
    cBar.push(bar_index), cDir.push(1),  cEnt.push(srcPrice), cAtr.push(atr), cBase.push(baseUp), cUniq.push(1.0 / (1.0 + cBar.size()))
if calcCal and bearTurn and not na(baseDn)
    cBar.push(bar_index), cDir.push(-1), cEnt.push(srcPrice), cAtr.push(atr), cBase.push(baseDn), cUniq.push(1.0 / (1.0 + cBar.size()))

if cBar.size() > 0
    for i = cBar.size() - 1 to 0
        if bar_index - cBar.get(i) >= calH
            int d = cDir.get(i)
            float fav = d == 1 ? srcPrice - cEnt.get(i) : cEnt.get(i) - srcPrice
            bool won = fav >= calK * cAtr.get(i)
            if won
                hits += 1
            tot += 1
            int rtO = won ? 1 : 0
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
            // HARNESS+ — uniqueness-weighted, sequential in-sample → out-of-sample
            float u = cUniq.get(i)
            harResolved += 1
            harTotN += u
            if harResolved <= harTrainN
                harIsN += u
                harIsW += won ? u : 0.0
            else
                harOosN += u
                harOosW += won ? u : 0.0
                if not na(b)
                    harOosBs += u * b
            cBar.remove(i), cDir.remove(i), cEnt.remove(i), cAtr.remove(i), cBase.remove(i), cUniq.remove(i)

float hitPct  = tot   > 0 ? hits / tot * 100.0 : na
float basePct = baseN > 0 ? sumBase / baseN     : na
float edge    = not na(hitPct) and not na(basePct) ? hitPct - basePct : na

// ─── Wilson significance + edge-floor + runs-test ────────────────────────────────────────────
float zDefl  = nTests <= 1 ? 1.96 : nTests == 2 ? 2.24 : nTests == 3 ? 2.39 : nTests == 4 ? 2.50 : 2.58
float ciPct  = f_wilson(hits, tot, zDefl) * 100.0
bool  sigStar = not na(ciPct) and not na(edge) and (edge - ciPct) > 0
float edgeLB = not na(hitPct) and not na(ciPct) and not na(basePct) ? (hitPct - ciPct) - basePct : na
// HARNESS+ — uniqueness-weighted effective sample & out-of-sample edge (the trustworthy one)
float harEffN    = harTotN
float harOosHit  = harOosN > 0 ? harOosW / harOosN * 100.0 : na
float harOosBase = harOosN > 0 ? harOosBs / harOosN : na
float harOosEdge = not na(harOosHit) and not na(harOosBase) ? harOosHit - harOosBase : na
float harOosCi   = harOosN > 0 ? f_wilson(harOosW, harOosN, zDefl) * 100.0 : na
bool  harOosStar = harOosN >= 10 and not na(harOosCi) and not na(harOosEdge) and (harOosEdge - harOosCi) > 0
float rtMu  = rtN > 1 ? 2.0 * rtN1 * rtN0 / rtN + 1.0 : na
float rtVar = rtN > 1 ? 2.0 * rtN1 * rtN0 * (2.0 * rtN1 * rtN0 - rtN) / (rtN * rtN * (rtN - 1.0)) : na
float runsZ = not na(rtVar) and rtVar > 0 ? (rtRuns - rtMu) / math.sqrt(rtVar) : na
// ─── spectral purity / dominant scale ────────────────────────────────────────────────────────
int   domIdx   = sh1 >= sh2 and sh1 >= sh3 ? 1 : sh2 >= sh3 ? 2 : 3
float purity   = math.max(math.max(sh1, sh2), sh3)
int   domPer   = domIdx == 1 ? 4 : domIdx == 2 ? 8 : 24   // representative period (bars) of the dominant scale group

// ─── RENDER STYLE ──────────────────────────────────────────────────────────────────────────────
isHist = vizStyle == "Histogram"
isGrad = vizStyle == "Gradient area + glow"
float intensity = math.min(math.abs(osc) / math.max(extSigma, 0.0001), 1.0)

bgcolor(showRegime and osc >= extSigma ? color.new(upperBandCol, 90) : showRegime and osc <= -extSigma ? color.new(lowerBandCol, 90) : na, title = "Regime tint")

hline(0, "Zero", color.new(chart.fg_color, 70))
pUpLean = plot(obSigma,   "Upper Lean Line",    color.new(upperBandCol, 55), 1, display = display.pane, editable = false)
pUpExt  = plot(extSigma,  "Upper Extreme Line", color.new(upperBandCol, 70), 1, display = display.pane, editable = false)
pDnLean = plot(-obSigma,  "Lower Lean Line",    color.new(lowerBandCol, 55), 1, display = display.pane, editable = false)
pDnExt  = plot(-extSigma, "Lower Extreme Line", color.new(lowerBandCol, 70), 1, display = display.pane, editable = false)
fill(pUpExt, pUpLean,  extSigma,  obSigma,  color.new(upperBandCol, 55), color.new(upperBandCol, 90), title = "Upper Band")
fill(pDnLean, pDnExt, -obSigma, -extSigma, color.new(lowerBandCol, 90), color.new(lowerBandCol, 55), title = "Lower Band")

plot(0, "Midline glow", color.new(midCol, 80), 3, display = display.pane)
plot(0, "Midline",      color.new(midCol, 45), 1, display = display.pane)

mid = plot(0, "base", display = display.none, editable = false)
op  = plot(isGrad ? osc : na, "area", display = display.none, editable = false)
fill(op, mid, color.new(domCol, 92 - int(intensity * 55)), title = "Gradient area")

plot(isHist ? osc : na, "Histogram", color.new(domCol, 35), style = plot.style_columns)

plot(not isHist ? osc : na, "glow outer", color.new(domCol, 88), 6, display = display.pane)
plot(not isHist ? osc : na, "glow inner", color.new(domCol, 70), 3, display = display.pane)
plot(not isHist ? osc : na, "Composite", domCol, 2)

plotshape(bullTurn, "Up", shape.triangleup,   location.bottom, fastCol, size = size.tiny)
plotshape(bearTurn, "Dn", shape.triangledown, location.top,    slowCol, size = size.tiny)
// on-price overlay signals — tiny directional triangles
plotshape(showOverlaySig and bullTurn, "Up (price)", shape.triangleup,   location.belowbar, color.new(fastCol, 0), size = size.tiny, force_overlay = true)
plotshape(showOverlaySig and bearTurn, "Dn (price)", shape.triangledown, location.abovebar, color.new(slowCol, 0), size = size.tiny, force_overlay = true)

// ─── DASHBOARD (theme-adaptive, zebra · Compact default / Pro) ───────────────────────────────────
f_row(int r) => color.new(chart.fg_color, r % 2 == 0 ? 92 : 96)
bool proMode = dashMode == "Pro"
int  dashRows = proMode ? 12 : 6
var table dash = table.new(position.top_right, 2, dashRows, frame_color = color.new(chart.fg_color, 60), frame_width = 1, border_color = color.new(chart.fg_color, 80), border_width = 1)
f_dc(int r, string k, string v, color vc) =>
    table.cell(dash, 0, r, k, text_color = chart.fg_color, bgcolor = f_row(r), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, r, v, text_color = vc, bgcolor = f_row(r), text_size = size.tiny)
if barstate.islast and showDash
    color  c1Col = na(c1) ? chart.fg_color : c1 >= 0.55 ? fastCol : c1 <= 0.45 ? slowCol : color.new(chart.fg_color, 20)
    color  c2Col = na(c2) ? chart.fg_color : c2 <= -0.05 ? midColor : color.new(chart.fg_color, 20)
    string c2Tag = na(c2) ? "—" : c2 <= -0.10 ? " multi" : c2 <= -0.05 ? " mild" : " mono"
    string oosTxt = harOosN < 10 ? "warming (" + str.tostring(harOosN, "0.0") + "/10)" : (harOosStar ? "★ " : "") + (harOosEdge >= 0 ? "+" : "") + str.tostring(harOosEdge, "#.#") + "% · effN " + str.tostring(harEffN, "#.#")
    color  oosCol = harOosN < 10 ? color.new(chart.fg_color, 25) : harOosStar ? fastCol : harOosEdge >= 0 ? chart.fg_color : slowCol
    table.cell(dash, 0, 0, "WAVELET ENERGY", text_color = chart.bg_color, bgcolor = domCol, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 0, "DOM " + domName, text_color = chart.bg_color, bgcolor = domCol, text_size = size.tiny)
    if proMode
        f_dc(1, "Fast (2-4)",   str.tostring(sh1, "#") + "%", fastCol)
        f_dc(2, "Mid (8)",      str.tostring(sh2, "#") + "%", midColor)
        f_dc(3, "Slow (16-32)", str.tostring(sh3, "#") + "%", slowCol)
        f_dc(4, "Value (σ)", str.tostring(osc, "#.##"), domCol)
        f_dc(5, "Hurst c1", na(c1) ? "—" : str.tostring(c1, "#.##"), c1Col)
        f_dc(6, "Multifractal c2", na(c2) ? "—" : str.tostring(c2, "#.##") + c2Tag, c2Col)
        f_dc(7, "Hit %", na(hitPct) ? "—" : str.tostring(hitPct, "#.#") + "%", chart.fg_color)
        f_dc(8, "Base %", na(basePct) ? "—" : str.tostring(basePct, "#.#") + "%", color.new(chart.fg_color, 30))
        table.cell(dash, 0, 9, "EDGE", text_color = chart.fg_color, bgcolor = f_row(9), text_halign = text.align_left, text_size = size.tiny)
        table.cell(dash, 1, 9, na(edge) ? "—" : (edge >= 0 ? "+" : "") + str.tostring(edge, "#.#") + "%", text_color = chart.bg_color, bgcolor = na(edge) ? f_row(9) : (edge > 0 ? fastCol : slowCol), text_size = size.tiny)
        table.cell(dash, 0, 10, "Edge floor", text_color = chart.fg_color, bgcolor = f_row(10), text_halign = text.align_left, text_size = size.tiny)
        table.cell(dash, 1, 10, na(edgeLB) ? "—" : (sigStar ? "★ " : "") + (edgeLB >= 0 ? "+" : "") + str.tostring(edgeLB, "#.#") + "%", text_color = chart.bg_color, bgcolor = na(edgeLB) ? f_row(10) : (edgeLB > 0 ? fastCol : slowCol), text_size = size.tiny)
        f_dc(11, "Out-of-sample", oosTxt, oosCol)
    else
        f_dc(1, "Spectrum F·M·S", str.tostring(sh1, "#") + " · " + str.tostring(sh2, "#") + " · " + str.tostring(sh3, "#"), domCol)
        f_dc(2, "Value (σ)", str.tostring(osc, "#.##"), domCol)
        f_dc(3, "Hurst · Multi", (na(c1) ? "—" : str.tostring(c1, "#.##")) + " · " + (na(c2) ? "—" : str.tostring(c2, "#.##") + c2Tag), c2Col)
        table.cell(dash, 0, 4, "EDGE", text_color = chart.fg_color, bgcolor = f_row(4), text_halign = text.align_left, text_size = size.tiny)
        table.cell(dash, 1, 4, na(edge) ? "—" : (edge >= 0 ? "+" : "") + str.tostring(edge, "#.#") + "%", text_color = chart.bg_color, bgcolor = na(edge) ? f_row(4) : (edge > 0 ? fastCol : slowCol), text_size = size.tiny)
        f_dc(5, "Out-of-sample", oosTxt, oosCol)

// ─── EXP_* EXPORT BUS (generic; Data Window) ─────────────────────────────────────────────────
plot(showEXP ? osc            : na, "EXP_Composite", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? domIdx         : na, "EXP_DomBand",   color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? domPer         : na, "EXP_DomPeriod", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? sh1            : na, "EXP_FastShare", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? sh2            : na, "EXP_MidShare",  color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? sh3            : na, "EXP_SlowShare", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? purity         : na, "EXP_SNR",       color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? edge           : na, "EXP_Edge",      color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? edgeLB         : na, "EXP_EdgeLB",    color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? runsZ          : na, "EXP_RunsZ",     color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? c1             : na, "EXP_Hurst",     color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? c2             : na, "EXP_Multifractal", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? harOosEdge     : na, "EXP_EdgeOOS",   color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? harEffN        : na, "EXP_EffN",      color = color.new(color.gray, 100), display = display.data_window)

// ─── ALERTS ───────────────────────────────────────────────────────────────────────────────────
alertcondition(bullTurn, "Composite up",   "Wavelet composite turned positive")
alertcondition(bearTurn, "Composite down", "Wavelet composite turned negative")
````
