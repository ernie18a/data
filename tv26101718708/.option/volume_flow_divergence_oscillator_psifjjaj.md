# Volume Flow Divergence Oscillator

- url: https://www.tradingview.com/script/PSIfjJAJ-Volume-Flow-Divergence-Oscillator/
- type: indicator
- pine_id: PUB;34ccde4d9da043078942c8c8f4c38a38
- version: 4.0

## Description

Volume Flow Divergence Oscillator (VFDO) 

Volume Flow Divergence Oscillator

A bounded order-flow oscillator that measures whether buying or selling pressure dominates and how stretched it is, then detects price/flow divergences with statistical filtering. Three interchangeable flow engines share one axis so the same read can be cross-checked three independent ways.

Why these components are combined (and why this is not a generic mashup)

Order-flow pressure can be measured several ways, and each has blind spots. The problem this script solves is specific: raw Cumulative Volume Delta (CVD) trends without bound, so classic "swing-high vs swing-high" divergence on it is unreliable — the comparison ends up dominated by the accumulated drift instead of local buying/selling conviction. Stacking more momentum tools (a second RSI, a MACD) would only double-count the same information.

Instead, this tool (a) detrends and standardizes the flow into a bounded, mean-reverting oscillator so divergence becomes valid, and (b) offers three orthogonal lenses on one question — is buying or selling winning, and is it stretched?:


Normalized CVD — cumulative signed volume, detrended (minus its EMA) and divided by the residual's standard deviation. The reading is a z-score of how stretched flow is versus its own recent trend.
CVD-RSI — Wilder's RSI applied to the detrended CVD (not raw CVD, which would pin near 0/100 in a sustained trend). A 0–100 momentum-of-flow read.
MFI (Money Flow Index) — a volume-weighted RSI that does not depend on the signed-volume estimate, so it acts as a genuine independent cross-check.


These three are not redundant: they are different constructions of the same idea. A divergence that appears on all three is far more robust than one that appears on only one — and if they disagree, the "divergence" is construction-dependent noise. That cross-checking is the core purpose of putting them on a shared bounded axis.

Four context modules sit on top, each adding what the raw line cannot:


Filtered divergence — regular and hidden divergence between price pivots and the flow oscillator, gated by a minimum magnitude (marginal wiggles don't count), a maximum bar-distance between pivots (no stale comparisons), and an optional extreme-zone requirement (only count divergences forming from overbought/oversold, where they carry the most meaning). Lines are drawn on the oscillator curve; price marks print at the confirmation bar.
Gradient extreme zones — ±4σ (or 90/10) bands that shade lighter at the edge and darker as flow pushes further out, marking genuinely stretched conditions.
In-band reversal dots — a red/green dot when the oscillator makes a local turn inside an extreme band, flagging that stretched flow is unwinding.
Adaptive dashboard — a compact panel (oscillator value, zone, last divergence, last reversal, data source) that auto-themes to the chart background for legibility on any color scheme.


How signed volume is estimated (honesty)

True aggressor-tagged delta is unavailable on most TradingView feeds, so signed volume here is estimated: per bar it is summed from lower-timeframe sub-bars (each sub-bar's volume signed by whether it closed up or down), falling back to an intrabar OHLC proxy when sub-bar data isn't available. The dashboard's Delta source row shows which is live ("LTF" vs "proxy"). This is the standard approach CVD tools use; it is an estimate, not exchange-tagged order flow.

How to use


Add to any symbol that reports volume. Read it like a bounded flow gauge: above the upper band = buying stretched; below the lower band = selling stretched; midline = balance.
Treat divergences as context, not standalone triggers. A bearish divergence at the upper extreme means buying conviction is fading as price makes a new high.
Cross-check with the Engine selector: confirm a divergence by switching between Normalized CVD, CVD-RSI and MFI. Agreement across all three is the strong case.
Reversal dots mark stretched-flow unwinding — combine with your own price structure and risk rules.


Settings overview


Data Source — lower-timeframe for the delta estimate; selectable High/Low sources for divergence, so the engine fits any instrument.
Flow Oscillator — engine selector, detrend/normalize window, OB/OS, smoothing, RSI/MFI lengths.
Extreme Zones & Reversals — ±4σ band level, band display, reversal dots.
Divergence — magnitude, pivot length, max bar-distance, extreme-zone gate, regular/hidden.
Dashboard & Theme — colors, position, and Auto/Dark/Light theme.


Defaults are tuned for NSE NIFTY futures on intraday timeframes (1-minute sub-bar delta). For other assets or timeframes, adjust the lower timeframe, normalize window, and band levels — every parameter is exposed.

Originality

This is not a re-skin of a single public indicator. The original contributions are: the detrend-then-standardize normalization that makes CVD divergence valid; three interchangeable flow engines on one shared bounded axis for cross-checking; and a divergence engine with magnitude + distance + extreme-zone gating drawn on the oscillator curve, with in-band reversal detection.

Concept credits


Relative Strength Index — J. Welles Wilder Jr.
Money Flow Index — Gene Quong & Avrum Soudack.
Cumulative Volume Delta and divergence analysis are standard public order-flow / technical-analysis concepts.


This script is an original implementation built around those public concepts and is not affiliated with, nor endorsed by, their originators.

Disclaimer

For research and educational purposes only. Not financial advice and no guarantee of profitability or accuracy. Signed volume is estimated, not exchange-tagged. Indicators describe past price behavior; they do not predict the future. Trading carries risk of loss. Test on out-of-sample data and make your own decisions. The author accepts no liability for any use of this script.

## Source Code

````pine
//@version=6
// ═════════════════════════════════════════════════════════════════════════════
//  VOLUME FLOW DIVERGENCE OSCILLATOR — Multi-Engine & Forward-Calibrated
//  R1 (honest-stats standardization): robust-z via ml_robuststats/2 and the Wilson confidence math via
//    ml_calib/2 — both byte-identical to the prior local helpers, so the oscillator, the divergence marks
//    and every calibration number are UNCHANGED. Imports pinned to the exact published v2 versions.
//  shorttitle: VFDO
// ─────────────────────────────────────────────────────────────────────────────
//  WHAT IT IS
//    A BOUNDED order-flow oscillator that measures whether buying or selling
//    pressure dominates and how stretched it is, then detects price/flow
//    divergences with statistical filtering and FORWARD-CALIBRATES every divergence
//    class so it reports which ones have actually paid on this symbol. Three
//    interchangeable flow engines sit on one shared axis so the same read can be
//    cross-checked three ways, and an agreement meter shows how many concur.
//
//  WHY THE COMPONENTS ARE COMBINED  (mashup justification — read before publishing)
//    Order-flow pressure can be measured several ways, each with blind spots, and
//    raw Cumulative Volume Delta (CVD) trends without bound — which corrupts classic
//    swing-vs-swing divergence (the comparison is dominated by drift, not local
//    pressure). This script combines several layers specifically because each one
//    removes a weakness the others cannot, and they feed each other in sequence:
//      • THREE ORTHOGONAL ENGINES answer one question ("is buying or selling winning,
//        and is it stretched?") three independent ways: Normalized CVD (detrended,
//        standardized CVD → a z-score of flow stretch), CVD-RSI (a momentum oscillator
//        of the DETRENDED CVD, so it won't pin at 0/100 in a trend), and a volume-
//        weighted momentum index (independent of the signed-volume estimate — a
//        genuine cross-check). An AGREEMENT meter reports how many concur.
//      • BOUNDED AXIS makes divergence meaningful: an unbounded CVD makes swing-vs-
//        swing comparison drift-dominated; bounding and detrending restore local
//        pressure as the thing being compared.
//      • FILTERED DIVERGENCE adds magnitude, distance and extreme-zone gates so only
//        divergences that carry meaning are drawn; hidden divergence is detected
//        off-extreme.
//      • FORWARD CALIBRATION is what makes the read honest: every divergence and
//        reversal class is resolved by a triple-barrier outcome, sample-uniqueness
//        weighted, recency-decayed, and reported as an edge over a ZONE-MATCHED base
//        rate (for a bearish-from-overbought divergence the benchmark is "how often
//        does price fall AFTER simply being overbought?", so the edge is the value of
//        the divergence BEYOND the extreme) with a Wilson interval and a multiple-
//        testing-corrected significance flag.
//      • EXTREME ZONES + REVERSAL DOTS + an ADAPTIVE DASHBOARD turn the whole state
//        into one glance.
//    A lens, a filter and an edge are one decision, not three tools — which is why
//    they ship as one engine. Remove the calibration and you cannot tell which
//    divergence class is signal and which is noise on your instrument.
//
//  SIGNED VOLUME IS ESTIMATED
//    True aggressor-tagged delta is unavailable on most feeds. Per bar, signed volume
//    is summed from lower-timeframe sub-bars (each signed by where it closed within its
//    own range), falling back to a standardized-return (Bulk-Volume) estimate when
//    sub-bar data is absent. The dashboard's "Delta source" row shows which is live.
//
//  DATA SOURCE / ANY MARKET
//    Works on any symbol that reports volume; a volume source and an optional borrow
//    symbol cover instruments that report none. Divergence price sources are inputs;
//    every threshold is sigma- or percentile-based. DEFAULTS ARE TUNED FOR NIFTY
//    INDEX FUTURES, INTRADAY — change the sources and lower timeframe for other assets.
//
//  EXPORTS (Data Window · generic names for cross-script consumption via input.source)
//    EXP_Osc, EXP_OscZ, EXP_Zone, EXP_FlowBias, EXP_Agreement, EXP_RegDiv, EXP_HidDiv,
//    EXP_Reversal, EXP_DeltaSrc, EXP_BullEdge, EXP_BearEdge
//
//  NON-REPAINT
//    Lower-timeframe delta uses confirmed sub-bars; price marks print at the
//    CONFIRMATION bar (when the divergence was actually known), not back-dated onto the
//    pivot; every calibrated statistic resolves on confirmed bars, forward-measured.
//
//  CONCEPT CREDITS (techniques operationalised here — not third-party code)
//    Relative Strength Index: J. Welles Wilder Jr. Money/volume-weighted index: Gene
//    Quong & Avrum Soudack. Cumulative Volume Delta & divergence analysis: standard
//    public order-flow / technical-analysis concepts. Trade-side from standardized
//    returns (Bulk Volume Classification): Easley, López de Prado & O'Hara. Triple-
//    barrier labelling & sample uniqueness: López de Prado. Wilson score interval:
//    Edwin B. Wilson; multiple-testing correction: Šidák. The integration, the multi-
//    engine agreement and the zone-matched forward calibration are this script's own
//    original implementation; not affiliated with or endorsed by the originators.
//
//  CHANGELOG
//    v1.1 — Three additive layers, all optional and reversible. The signed-volume engine, the three
//           flow lenses, the divergence detection, the triple-barrier forward calibration, the plots
//           and the full EXP_ bus are byte-for-byte unchanged; no new plots are added (the pane is at
//           the plot ceiling), so the layers surface on the dashboard and via alerts.
//      • ROBUST normalization on the "Normalized CVD" engine (default on). The detrended CVD residual
//        can be standardized with a MEDIAN / MAD z (median absolute deviation × 1.4826) instead of
//        residual/stdev, so a single volume-spike bar doesn't blow out the σ scale. ("CVD normalization".)
//      • ULTIMATESMOOTHER (default on). When oscillator smoothing > 1, it can use Ehlers' lag-minimal
//        UltimateSmoother instead of an EMA, so the smoothed line turns sooner. ("Smoother".)
//      • WALK-FORWARD OUT-OF-SAMPLE reliability. The first N resolved signals TRAIN; every one after is
//        scored OUT-OF-SAMPLE, and the honest OOS edge (hit − zone-matched base, in pp) is shown on a
//        new dashboard row. An in-sample edge can flatter; the OOS row is the trustworthy read.
//      • VSA BAR EVENTS (optional). Names the current bar's dominant Wyckoff / effort-vs-result event —
//        Upthrust, Shakeout, Stopping Volume — via dedicated alerts, with an optional time-of-day volume
//        baseline so a normal-for-the-open bar is not mistaken for a climax. Off-pane, alerts only.
//      Set CVD normalization = "Classic (÷ stdev)" and Smoother = "EMA" to reproduce the original read.
//      Also pins max_bars_back = 5000 (this script requests lower-timeframe data). No divergence or
//      calibration logic changed.
//
//  DISCLAIMER
//    Research and educational purposes only. NOT financial advice; no guarantee of
//    profitability or accuracy. Signed volume is estimated, not exchange-tagged.
//    Calibration is in-sample, forward-measured at fixed barriers, with no costs /
//    slippage / stops. Indicators describe past behaviour; they do not predict the
//    future. Trading carries risk of loss. Test out-of-sample and make your own
//    decisions. The author accepts no liability for any use of this script.
// ═════════════════════════════════════════════════════════════════════════════
indicator("Volume Flow Divergence Oscillator — Multi-Engine & Forward-Calibrated", "VFDO", overlay = false,
     max_lines_count = 200, max_labels_count = 300, max_bars_back = 5000, dynamic_requests = true)

// R1 · honest-stats standardization — robust-z and the Wilson confidence math are now routed through the
// published calibration libraries (one engine across the divergence family). Both are byte-identical to the
// prior local f_robZ / f_wilson, so the oscillator, the divergence marks and every calibration number are
// UNCHANGED — only where the math is computed moves into the libraries. Pinned to the exact published v2
// versions so a later library update can't silently change this script.
import Market_Logic_India/ml_calib/2        as calib
import Market_Logic_India/ml_robuststats/2  as rstat

// ═════════════════════════════════════════════════════════════════════════════
// 1 · DATA SOURCE  (configure for any market)
// ═════════════════════════════════════════════════════════════════════════════
g1 = "1 · Data Source"
volSrc     = input.source(volume, "Volume source", group = g1, tooltip = "Volume series the flow engine runs on. Use the borrow symbol below for instruments that report no volume.")
volBorrowSym = input.symbol("", "Borrow volume from symbol (no-volume fix)", group = g1, tooltip = "Supplies volume where the charted symbol reports none (e.g. an index). Leave blank to use the volume source above.")
useLowerTF = input.bool(true, "Use lower-timeframe delta (more accurate signed volume)", group = g1)
lowerTF    = input.timeframe("1", "Lower timeframe", group = g1,
     tooltip = "Sub-bar timeframe used to estimate signed volume. Set BELOW the chart timeframe. Default 1-min suits NIFTY intraday. On sub-5m charts use 1S/5S if your plan has seconds data; otherwise the fallback estimate is used.")
bvcLen     = input.int(20, "Fallback estimate window", minval = 5, maxval = 100, group = g1, tooltip = "Window for the standardized-return deviation used by the fallback signed-volume estimate.")
srcHigh = input.source(high, "High source (bearish divergence)", group = g1, tooltip = "Price series for bearish-divergence pivots. Default = high.")
srcLow  = input.source(low,  "Low source (bullish divergence)",  group = g1, tooltip = "Price series for bullish-divergence pivots. Default = low.")

// ═════════════════════════════════════════════════════════════════════════════
// 2 · FLOW OSCILLATOR
// ═════════════════════════════════════════════════════════════════════════════
g2 = "2 · Flow Oscillator"
oscMode = input.string("Normalized CVD", "Engine", options = ["Normalized CVD", "CVD-RSI", "MFI"], group = g2,
     tooltip = "Normalized CVD = z-score of detrended cumulative delta. CVD-RSI = momentum oscillator of detrended CVD. MFI = volume-weighted momentum index (independent cross-check).")
normLen   = input.int(50, "Detrend / Normalize window", minval = 5, group = g2, tooltip = "Window for the CVD detrend (EMA) and its residual standard deviation.")
obSigma   = input.float(1.5, "Overbought / Oversold (σ, Normalized CVD)", minval = 0.5, step = 0.1, group = g2, tooltip = "Inner band. On CVD-RSI / MFI this maps to 70/30 and 80/20.")
oscSmooth = input.int(1, "Oscillator smoothing", minval = 1, group = g2)
cvdNorm   = input.string("Robust (MAD)", "CVD normalization", options = ["Robust (MAD)","Classic (÷ stdev)"], group = g2, tooltip = "Normalized-CVD engine only. Robust (MAD) standardizes the detrended CVD with median / median-absolute-deviation (×1.4826), so a single volume-spike bar doesn't blow out the σ scale. Classic reproduces the original residual/stdev.")
smootherType = input.string("UltimateSmoother (Wave A)", "Smoother", options = ["UltimateSmoother (Wave A)","EMA"], group = g2, tooltip = "Applies when oscillator smoothing > 1. UltimateSmoother (Ehlers) is lag-minimal; EMA reproduces the original.")
rsiLen    = input.int(14, "CVD-RSI length", minval = 2, inline = "len", group = g2)
mfiLen    = input.int(14, "MFI length", minval = 2, inline = "len", group = g2)
showAgree = input.bool(true, "Multi-engine agreement meter", group = g2, tooltip = "Computes all three engines every bar and reports how many concur on the current side — a built-in cross-check.")

// ═════════════════════════════════════════════════════════════════════════════
// 3 · EXTREME ZONES & REVERSALS
// ═════════════════════════════════════════════════════════════════════════════
g3 = "3 · Extreme Zones & Reversals"
showExt    = input.bool(true, "Show extreme zone bands", group = g3)
extSigma   = input.float(4.0, "Extreme zone (σ, Normalized CVD)", minval = 1.0, step = 0.5, group = g3, tooltip = "Outer band. ±4σ by default; maps to 90/10 on CVD-RSI / MFI.")
showExtRev = input.bool(true, "Mark extreme-band reversals (dots)", group = g3)
revPiv     = input.int(1, "Reversal pivot length", minval = 1, group = g3, tooltip = "Bars each side for the oscillator turn. 1 = quickest (confirms 1 bar after the in-band peak).")

// ═════════════════════════════════════════════════════════════════════════════
// 4 · DIVERGENCE
// ═════════════════════════════════════════════════════════════════════════════
g4 = "4 · Divergence"
showLines      = input.bool(true, "Draw divergence lines on oscillator", group = g4)
showPriceMarks = input.bool(true, "Mark divergences on price (at confirmation)", group = g4)
showHidden     = input.bool(true, "Detect hidden divergence (else regular only)", group = g4)
reqExtreme     = input.bool(true, "Require OB/OS at the pivot (regular)", group = g4, tooltip = "Regular divergences must form from overbought (bearish) / oversold (bullish), where they carry the most meaning.")
useOscPivot    = input.bool(true, "Use the oscillator's own swing near the pivot", group = g4, tooltip = "Detection compares the flow's peak/trough in the window around the price pivot. Drawn lines stay on the oscillator curve.")
pivLen   = input.int(5, "Pivot length", minval = 1, inline = "p", group = g4)
maxGap   = input.int(60, "Max bars between pivots", minval = 2, inline = "p", group = g4)
magThr   = input.float(0.3, "Min oscillator gap (x osc stdev)", minval = 0.0, step = 0.05, group = g4, tooltip = "Minimum separation between the two pivots' oscillator values, scaled to the oscillator's own stdev. Filters marginal divergences.")

// ═════════════════════════════════════════════════════════════════════════════
// 5 · FORWARD CALIBRATION  (which divergences actually pay)
// ═════════════════════════════════════════════════════════════════════════════
g5 = "5 · Forward Calibration"
useCalib   = input.bool(true, "Calibrate divergence classes", group = g5, tooltip = "Forward-test each divergence / reversal class against what price actually did, with an edge over a zone-matched base rate.")
atrLen     = input.int(14, "ATR length", minval = 4, maxval = 50, group = g5)
calHorizon = input.int(20, "Horizon (bars, vertical barrier)", minval = 3, maxval = 100, group = g5)
calMoveATR = input.float(1.0, "Profit barrier (× ATR)", minval = 0.2, maxval = 4.0, step = 0.1, group = g5)
calStopATR = input.float(1.0, "Stop barrier (× ATR)", minval = 0.2, maxval = 4.0, step = 0.1, group = g5)
calMinSamp = input.int(5, "Min samples to trust", minval = 3, maxval = 50, group = g5)
wfTrainN   = input.int(30, "In-sample signals before out-of-sample (walk-forward)", minval = 5, group = g5, tooltip = "Wave E honesty: the first N resolved signals TRAIN; every one after is scored OUT-OF-SAMPLE. The OOS edge is the trustworthy read — an in-sample edge can flatter.")
calMinGap  = input.int(5, "Min bars between same-class samples", minval = 1, maxval = 40, group = g5)
useUniq    = input.bool(true, "Uniqueness-weight samples", group = g5, tooltip = "Down-weight events whose forward windows overlap others, so concurrent samples cannot over-count.")
calDecay   = input.float(0.99, "Recency decay (per resolved sample)", minval = 0.80, maxval = 1.0, step = 0.005, group = g5)

// ═════════════════════════════════════════════════════════════════════════════
// 6 · DASHBOARD & THEME
// ═════════════════════════════════════════════════════════════════════════════
g6 = "6 · Dashboard & Theme"
colBull   = input.color(#2ebd85, "Bull color", inline = "col", group = g6)
colBear   = input.color(#f6465d, "Bear color", inline = "col", group = g6)
showTable = input.bool(true, "Show dashboard", group = g6)
dashMode  = input.string("Pro", "Dashboard mode", options = ["Compact", "Pro"], group = g6, tooltip = "Compact: the five key readouts. Pro: adds the per-class forward calibration table.")
tblPos    = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = g6)
dashTheme = input.string("Auto (match chart)", "Theme", options = ["Auto (match chart)", "Dark", "Light"], group = g6, tooltip = "Auto detects chart-background brightness and keeps the panel legible on any theme.")
showId    = input.bool(true, "Show identity strip (name · symbol · timeframe)", group = g6, tooltip = "Draws a small strip on the chart with the script name, the symbol and the timeframe, so it is always clear what is being viewed.")

// ═════════════════════════════════════════════════════════════════════════════
// 7 · EXPORTS (Data Window)
// ═════════════════════════════════════════════════════════════════════════════
g7 = "7 · Exports"
showEXP = input.bool(true, "Emit EXP_* exports", group = g7, tooltip = "Hidden Data-Window series with generic names for input.source() consumption by other scripts.")

// ═════════════════════════════════════════════════════════════════════════════
// HELPERS
// ═════════════════════════════════════════════════════════════════════════════
f_ncdf(x) =>
    float t = 1.0 / (1.0 + 0.2316419 * math.abs(x))
    float d = 0.3989422804014327 * math.exp(-x * x / 2.0)
    float p = d * t * (0.319381530 + t * (-0.356563782 + t * (1.781477937 + t * (-1.821255978 + t * 1.330274429))))
    x >= 0.0 ? 1.0 - p : p

// calibration sample objects
type Ev
    int   dir
    int   cls
    bool  ext
    float entry
    float atr0
    int   bidx
    float mfe
    float mae
    float uw
    bool  done
type Base
    float entry
    float atr0
    int   bidx
    bool  wasOB
    bool  wasOS

// ═════════════════════════════════════════════════════════════════════════════
// VOLUME (source + optional borrow)
// ═════════════════════════════════════════════════════════════════════════════
var bool nativeVolSeen = false
if nz(volSrc, 0) > 0
    nativeVolSeen := true
useBorrow = str.length(volBorrowSym) > 0 and not nativeVolSeen
volBorrowRaw = request.security(volBorrowSym, timeframe.period, volume, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
volEff = useBorrow and not na(volBorrowRaw) ? volBorrowRaw : volSrc
volNz = nz(volEff, 0.0)

// ═════════════════════════════════════════════════════════════════════════════
// SIGNED-VOLUME ENGINE  (lower-timeframe sub-bar delta · BVC fallback)
// ═════════════════════════════════════════════════════════════════════════════
f_bvcDelta() =>
    float ret = close - nz(close[1], close)
    float sd  = ta.stdev(close - close[1], bvcLen)
    float z   = sd > 0 ? ret / sd : 0.0
    float bf  = math.max(0.0, math.min(1.0, f_ncdf(z)))
    volNz * (2.0 * bf - 1.0)

[ltfH, ltfL, ltfC, ltfV] = request.security_lower_tf(syminfo.tickerid, lowerTF, [high, low, close, volume])
float svLTF = na
bool  ltfOK = false
if array.size(ltfV) > 0
    float s = 0.0
    for i = 0 to array.size(ltfV) - 1
        float rr = array.get(ltfH, i) - array.get(ltfL, i)
        float bf = rr == 0 ? 0.5 : math.max(0.0, math.min(1.0, (array.get(ltfC, i) - array.get(ltfL, i)) / rr))
        s += array.get(ltfV, i) * (2.0 * bf - 1.0)
    svLTF := s
    ltfOK := true
float sv = (useLowerTF and ltfOK) ? svLTF : f_bvcDelta()

// Wave A helpers (defined before use)
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

// ═════════════════════════════════════════════════════════════════════════════
// OSCILLATOR ENGINE  (three bounded, mean-reverting flow lenses)
// ═════════════════════════════════════════════════════════════════════════════
float cvd   = ta.cum(sv)
float resid = cvd - ta.ema(cvd, normLen)
float sdRes = ta.stdev(resid, normLen)
// Wave A: classic residual/stdev vs robust median/MAD — compute both, select
float ncvdClassic = sdRes == 0 ? 0.0 : resid / sdRes
float ncvdRobust  = rstat.robZ(resid, normLen)
float ncvd  = cvdNorm == "Classic (÷ stdev)" ? ncvdClassic : ncvdRobust
float crsi  = ta.rsi(resid, rsiLen)
// volume-weighted momentum index (manual, so it honours the volume source / borrow)
float tp    = hlc3
float mfRaw = tp * volNz
float posF  = tp > tp[1] ? mfRaw : 0.0
float negF  = tp < tp[1] ? mfRaw : 0.0
float posS  = math.sum(posF, mfiLen)
float negS  = math.sum(negF, mfiLen)
float mfiv  = negS == 0 ? 100.0 : 100.0 - 100.0 / (1.0 + posS / negS)

float oscRaw = oscMode == "Normalized CVD" ? ncvd : oscMode == "CVD-RSI" ? crsi : mfiv
// Wave A: compute both smoothers unconditionally, then select
float oscEma = ta.ema(oscRaw, oscSmooth)
float oscUlt = ml_ultimateSmoother(oscRaw, math.max(oscSmooth, 2))
float osc    = oscSmooth > 1 ? (smootherType == "EMA" ? oscEma : oscUlt) : oscRaw

bool  isSigma  = oscMode == "Normalized CVD"
float obLevel  = isSigma ?  obSigma : oscMode == "CVD-RSI" ? 70.0 : 80.0
float osLevel  = isSigma ? -obSigma : oscMode == "CVD-RSI" ? 30.0 : 20.0
float midLevel = isSigma ?  0.0     : 50.0
float extHi    = isSigma ?  extSigma       : 90.0
float extLo    = isSigma ? -extSigma       : 10.0
float capHi    = isSigma ?  extSigma + 1.5 : 100.0
float capLo    = isSigma ? -extSigma - 1.5 : 0.0

// common-scaled value + multi-engine agreement
float oscZ = isSigma ? osc : (osc - 50.0) / 20.0
int e1 = ncvd > 0 ? 1 : ncvd < 0 ? -1 : 0
int e2 = crsi > 50 ? 1 : crsi < 50 ? -1 : 0
int e3 = mfiv > 50 ? 1 : mfiv < 50 ? -1 : 0
int agreeSum = e1 + e2 + e3
float atrV = ta.atr(atrLen)

// ═════════════════════════════════════════════════════════════════════════════
// DIVERGENCE ENGINE  (magnitude + distance + extreme-zone gated; on-curve lines)
// ═════════════════════════════════════════════════════════════════════════════
float gapMin = magThr * ta.stdev(osc, 100)
int   oscWin = 2 * pivLen + 1
float ph = ta.pivothigh(srcHigh, pivLen, pivLen)
float pl = ta.pivotlow(srcLow,  pivLen, pivLen)

var float pHp = na, var float pHo = na, var float pHoD = na, var int pHb = na
var float pLp = na, var float pLo = na, var float pLoD = na, var int pLb = na

bool regBear = false, bool regBull = false
bool hidBear = false, bool hidBull = false

var array<line>  dLines = array.new<line>()
var array<label> dLabs  = array.new<label>()
f_drawDiv(int b0, float o0, int b1, float o1, bool bear, bool hidden) =>
    color col = bear ? colBear : colBull
    array.push(dLines, line.new(b0, o0, b1, o1, color = color.new(col, hidden ? 45 : 0), width = 2, style = hidden ? line.style_dashed : line.style_solid))
    array.push(dLabs, label.new(b1, o1, (hidden ? "H " : "") + (bear ? "Bear" : "Bull"),
         style = bear ? label.style_label_down : label.style_label_up,
         color = color.new(col, 20), textcolor = color.white, size = size.tiny))
    if array.size(dLines) > 50
        line.delete(array.shift(dLines))
    if array.size(dLabs) > 50
        label.delete(array.shift(dLabs))

if not na(ph)
    float cP   = srcHigh[pivLen]
    float cDet = useOscPivot ? ta.highest(osc, oscWin) : osc[pivLen]
    float cDr  = osc[pivLen]
    int   cB   = bar_index - pivLen
    if not na(pHp) and (cB - pHb) <= maxGap
        bool obOK = cDet >= obLevel
        regBear := cP > pHp and cDet < pHo and (pHo - cDet) >= gapMin and (not reqExtreme or obOK)
        hidBear := showHidden and cP < pHp and cDet > pHo and (cDet - pHo) >= gapMin
        if showLines and (regBear or hidBear)
            f_drawDiv(pHb, pHoD, cB, cDr, true, hidBear and not regBear)
    pHp := cP, pHo := cDet, pHoD := cDr, pHb := cB

if not na(pl)
    float cP   = srcLow[pivLen]
    float cDet = useOscPivot ? ta.lowest(osc, oscWin) : osc[pivLen]
    float cDr  = osc[pivLen]
    int   cB   = bar_index - pivLen
    if not na(pLp) and (cB - pLb) <= maxGap
        bool osOK = cDet <= osLevel
        regBull := cP < pLp and cDet > pLo and (cDet - pLo) >= gapMin and (not reqExtreme or osOK)
        hidBull := showHidden and cP > pLp and cDet < pLo and (pLo - cDet) >= gapMin
        if showLines and (regBull or hidBull)
            f_drawDiv(pLb, pLoD, cB, cDr, false, hidBull and not regBull)
    pLp := cP, pLo := cDet, pLoD := cDr, pLb := cB

// ═════════════════════════════════════════════════════════════════════════════
// REVERSAL ENGINE  (oscillator turn whose peak/trough is INSIDE the extreme band)
// ═════════════════════════════════════════════════════════════════════════════
float oscPH = ta.pivothigh(osc, revPiv, revPiv)
float oscPL = ta.pivotlow(osc, revPiv, revPiv)
bool  revTop = not na(oscPH) and oscPH >= extHi
bool  revBot = not na(oscPL) and oscPL <= extLo

// ── latest-event trackers (dashboard) ──
var int divBar = na, var string divTxt = "—"
if regBull
    divBar := bar_index, divTxt := "Bull"
if regBear
    divBar := bar_index, divTxt := "Bear"
if hidBull
    divBar := bar_index, divTxt := "H-Bull"
if hidBear
    divBar := bar_index, divTxt := "H-Bear"
var int revBar = na, var string revTxt = "—"
if revTop
    revBar := bar_index - revPiv, revTxt := "Top"
if revBot
    revBar := bar_index - revPiv, revTxt := "Bottom"

// ═════════════════════════════════════════════════════════════════════════════
// CALIBRATION  (zone-matched base · triple-barrier · uniqueness · decay · Wilson)
// ═════════════════════════════════════════════════════════════════════════════
int NCLS = 6   // 1 RegBull · 2 RegBear · 3 HidBull · 4 HidBear · 5 RevBot · 6 RevTop
f_clsName(id) => id==1?"Reg Bull":id==2?"Reg Bear":id==3?"Hid Bull":id==4?"Hid Bear":id==5?"Rev +":id==6?"Rev -":"—"
var array<Ev>   pend = array.new<Ev>()
var array<Base> bq   = array.new<Base>()
var int[]   clsN    = array.new<int>(NCLS+1, 0)
var float[] clsNsum = array.new<float>(NCLS+1, 0.0)
var float[] clsWsum = array.new<float>(NCLS+1, 0.0)
var float[] clsMFE  = array.new<float>(NCLS+1, 0.0)
var float[] clsMAE  = array.new<float>(NCLS+1, 0.0)
var float[] clsBase = array.new<float>(NCLS+1, 0.0)
var int[]   lastCls = array.new<int>(NCLS+1, -100000)
var int allN = 0, var int allUp = 0, var int allDn = 0
var int obN = 0,  var int obDn = 0
var int osN = 0,  var int osUp = 0
float zSig = 2.63   // two-sided 0.05 corrected for 6 classes

f_fire(int cls, int dir, bool ext) =>
    if useCalib and barstate.isconfirmed and (bar_index - lastCls.get(cls)) >= calMinGap and not na(atrV) and atrV > 0.0
        lastCls.set(cls, bar_index)
        float uw = useUniq ? 1.0/(1.0+pend.size()) : 1.0
        pend.push(Ev.new(dir, cls, ext, close, atrV, bar_index, 0.0, 0.0, uw, false))

if regBull
    f_fire(1, 1, reqExtreme)
if regBear
    f_fire(2, -1, reqExtreme)
if hidBull
    f_fire(3, 1, false)
if hidBear
    f_fire(4, -1, false)
if revBot
    f_fire(5, 1, true)
if revTop
    f_fire(6, -1, true)

// zone-matched base sampling
if useCalib and barstate.isconfirmed and not na(atrV) and atrV > 0.0
    bq.push(Base.new(close, atrV, bar_index, osc >= obLevel, osc <= osLevel))
if useCalib and barstate.isconfirmed and bq.size() > 0
    for i = bq.size() - 1 to 0
        Base b = bq.get(i)
        if bar_index - b.bidx >= calHorizon
            bool up = (close - b.entry) >= calMoveATR * b.atr0
            bool dn = (b.entry - close) >= calMoveATR * b.atr0
            allN += 1
            allUp += up ? 1 : 0
            allDn += dn ? 1 : 0
            if b.wasOB
                obN += 1
                obDn += dn ? 1 : 0
            if b.wasOS
                osN += 1
                osUp += up ? 1 : 0
            bq.remove(i)

// resolve divergence/reversal samples (triple-barrier; edge over zone-matched base)
var int   wfResolved = 0
var float wfOosW = 0.0, var float wfOosN = 0.0, var float wfOosBaseSum = 0.0
if useCalib and barstate.isconfirmed and pend.size() > 0
    for i = pend.size() - 1 to 0
        Ev p = pend.get(i)
        if not p.done
            float favor   = p.dir > 0 ? (high - p.entry) : (p.entry - low)
            float adverse = p.dir > 0 ? (p.entry - low)  : (high - p.entry)
            p.mfe := p.atr0 > 0.0 ? math.max(p.mfe, favor   / p.atr0) : p.mfe
            p.mae := p.atr0 > 0.0 ? math.max(p.mae, adverse / p.atr0) : p.mae
            bool hitStop = adverse >= calStopATR * p.atr0
            bool hitTgt  = favor   >= calMoveATR * p.atr0
            bool tmOut   = bar_index - p.bidx >= calHorizon
            if hitStop or hitTgt or tmOut
                p.done := true
                bool win = hitStop ? false : hitTgt ? true : ((p.dir > 0 ? (close - p.entry) : (p.entry - close)) >= calMoveATR * p.atr0)
                int   c = p.cls >= 1 and p.cls <= NCLS ? p.cls : 1
                float w = p.uw
                clsN.set(c, clsN.get(c) + 1)
                clsNsum.set(c, clsNsum.get(c) * calDecay + w)
                clsWsum.set(c, clsWsum.get(c) * calDecay + (win ? w : 0.0))
                clsMFE.set(c, clsMFE.get(c) + p.mfe)
                clsMAE.set(c, clsMAE.get(c) + p.mae)
                // zone-matched base rate
                float bp = 0.5
                if p.ext
                    bp := p.dir > 0 ? (osN > 0 ? osUp / float(osN) : 0.5) : (obN > 0 ? obDn / float(obN) : 0.5)
                else
                    bp := p.dir > 0 ? (allN > 0 ? allUp / float(allN) : 0.5) : (allN > 0 ? allDn / float(allN) : 0.5)
                clsBase.set(c, clsBase.get(c) + bp)
                wfResolved += 1
                if wfResolved > wfTrainN
                    wfOosN := wfOosN + 1.0
                    wfOosW := wfOosW + (win ? 1.0 : 0.0)
                    wfOosBaseSum := wfOosBaseSum + bp
                pend.remove(i)

f_hitW(int cls) =>
    float n = clsNsum.get(cls)
    n > 0.0 ? clsWsum.get(cls) / n : na
f_edge(int cls) =>
    float e = na
    int n = clsN.get(cls)
    if n >= calMinSamp
        float h = f_hitW(cls)
        e := (na(h) ? 0.0 : h) - clsBase.get(cls)/n
    e
// side edges for export (mean of warm classes per side)
f_sideEdge(bool bullSide) =>
    float s = 0.0
    int cnt = 0
    for c = 1 to NCLS
        bool isBull = c == 1 or c == 3 or c == 5
        if isBull == bullSide and clsN.get(c) >= calMinSamp
            float e = f_edge(c)
            if not na(e)
                s += e
                cnt += 1
    cnt > 0 ? s / cnt * 100.0 : na

// ═════════════════════════════════════════════════════════════════════════════
// PLOTS
// ═════════════════════════════════════════════════════════════════════════════
color oscCol = osc >= obLevel ? colBear : osc <= osLevel ? colBull : color.new(color.gray, 0)
plot(osc, "Glow outer", color = color.new(oscCol, 80), linewidth = 8)
plot(osc, "Glow inner", color = color.new(oscCol, 55), linewidth = 4)
plot(osc, "Oscillator", color = oscCol, linewidth = 2)

plot(obLevel, "Overbought", color = color.new(colBear, 55))
plot(osLevel, "Oversold",   color = color.new(colBull, 55))

plot(midLevel, "Mid glow 4", color = color.new(color.yellow, 94), linewidth = 8)
plot(midLevel, "Mid glow 3", color = color.new(color.yellow, 88), linewidth = 6)
plot(midLevel, "Mid glow 2", color = color.new(color.yellow, 80), linewidth = 4)
plot(midLevel, "Mid glow 1", color = color.new(color.yellow, 65), linewidth = 2)
plot(midLevel, "Mid",        color = color.new(color.yellow, 0),  linewidth = 1)

pExtHi = plot(showExt ? extHi : na, "Extreme +", color = color.new(colBear, 25), linewidth = 1)
pCapHi = plot(showExt ? capHi : na, "cap+",      color = color.new(colBear, 100), display = display.none)
fill(pExtHi, pCapHi, capHi, extHi, color.new(colBear, 12), color.new(colBear, 88), title = "Upper extreme")
pExtLo = plot(showExt ? extLo : na, "Extreme -", color = color.new(colBull, 25), linewidth = 1)
pCapLo = plot(showExt ? capLo : na, "cap-",      color = color.new(colBull, 100), display = display.none)
fill(pExtLo, pCapLo, extLo, capLo, color.new(colBull, 88), color.new(colBull, 12), title = "Lower extreme")

plot(showExtRev and revTop ? oscPH : na, "Top reversal",    style = plot.style_circles, color = colBear, linewidth = 4, offset = -revPiv)
plot(showExtRev and revBot ? oscPL : na, "Bottom reversal", style = plot.style_circles, color = colBull, linewidth = 4, offset = -revPiv)

plotshape(showPriceMarks and regBull, "Reg Bull", shape.triangleup,   location.belowbar, colBull, size = size.tiny, text = "Bull", force_overlay = true)
plotshape(showPriceMarks and regBear, "Reg Bear", shape.triangledown, location.abovebar, colBear, size = size.tiny, text = "Bear", force_overlay = true)
plotshape(showPriceMarks and hidBull, "Hid Bull", shape.circle, location.belowbar, color.new(colBull, 30), size = size.tiny, force_overlay = true)
plotshape(showPriceMarks and hidBear, "Hid Bear", shape.circle, location.abovebar, color.new(colBear, 30), size = size.tiny, force_overlay = true)

// ═════════════════════════════════════════════════════════════════════════════
// DASHBOARD  (theme-adaptive · key readouts + calibration)
// ═════════════════════════════════════════════════════════════════════════════
// Wave E — out-of-sample walk-forward reliability (trustworthy read)
float wfOosHit  = wfOosN > 0 ? wfOosW / wfOosN * 100.0 : na
float wfOosBase = wfOosN > 0 ? wfOosBaseSum / wfOosN * 100.0 : na
float wfOosEdge = (not na(wfOosHit) and not na(wfOosBase)) ? wfOosHit - wfOosBase : na
posMap = tblPos == "Top Left" ? position.top_left : tblPos == "Bottom Right" ? position.bottom_right : tblPos == "Bottom Left" ? position.bottom_left : position.top_right
var table st = table.new(posMap, 2, 16, frame_width = 1, border_width = 1, force_overlay = true)
f_cell(int c, int r, string txt, color tc, color bg) => table.cell(st, c, r, txt, text_color = tc, bgcolor = bg, text_size = size.tiny)
if showTable and barstate.islast
    color bgc    = chart.bg_color
    float luma   = na(bgc) ? 0.0 : color.r(bgc) * 0.299 + color.g(bgc) * 0.587 + color.b(bgc) * 0.114
    bool  darkUI = dashTheme == "Dark" ? true : dashTheme == "Light" ? false : (na(bgc) or luma < 140)
    color panelBg = darkUI ? color.rgb(17, 22, 28)    : color.rgb(244, 246, 248)
    color rowAlt  = darkUI ? color.rgb(25, 31, 39)    : color.rgb(232, 236, 240)
    color txtMain = darkUI ? color.white              : color.rgb(16, 20, 24)
    color txtSub  = darkUI ? color.rgb(154, 166, 178) : color.rgb(74, 82, 91)
    color frameC  = darkUI ? color.rgb(58, 70, 84)    : color.rgb(196, 204, 212)
    color bullC   = darkUI ? colBull : color.rgb(22, 151, 106)
    color bearC   = darkUI ? colBear : color.rgb(210, 45, 68)
    color warnC   = darkUI ? color.orange : color.rgb(201, 123, 0)
    color flatC   = darkUI ? color.gray : color.rgb(122, 130, 139)
    color hdr     = color.new(colBull, 0)
    table.set_frame_color(st, frameC)
    table.set_border_color(st, frameC)

    string baseTag = oscMode == "Normalized CVD" ? "NCVD" : oscMode == "CVD-RSI" ? "RSI" : "MFI"
    string srcTxt  = (useLowerTF and ltfOK) ? "LTF " + lowerTF : "estimate"
    string valTxt  = isSigma ? str.tostring(osc, "0.0") + "σ" : str.tostring(osc, "0")
    string zone    = osc >= extHi ? "Extreme High" : osc >= obLevel ? "Overbought" : osc <= extLo ? "Extreme Low" : osc <= osLevel ? "Oversold" : "Neutral"
    color  zcol    = osc >= obLevel ? bearC : osc <= osLevel ? bullC : flatC
    string divAge  = na(divBar) ? "" : "  " + str.tostring(bar_index - divBar) + "b"
    string revAge  = na(revBar) ? "" : "  " + str.tostring(bar_index - revBar) + "b"
    color  divCol  = (divTxt == "Bull" or divTxt == "H-Bull") ? bullC : (divTxt == "Bear" or divTxt == "H-Bear") ? bearC : flatC
    color  revCol  = revTxt == "Top" ? bearC : revTxt == "Bottom" ? bullC : flatC
    color  srcCol  = (useLowerTF and ltfOK) ? txtMain : warnC
    string agreeTxt= showAgree ? (str.tostring(math.abs(agreeSum)) + "/3 " + (agreeSum > 0 ? "bull" : agreeSum < 0 ? "bear" : "—")) : "off"
    color  agreeCol= agreeSum > 0 ? bullC : agreeSum < 0 ? bearC : flatC

    f_cell(0, 0, "Volume Flow Divergence", color.white, hdr)
    f_cell(1, 0, baseTag, color.white, hdr)
    f_cell(0, 1, "Oscillator", txtSub, rowAlt)
    f_cell(1, 1, valTxt, zcol, rowAlt)
    f_cell(0, 2, "Zone", txtSub, panelBg)
    f_cell(1, 2, zone, zcol, panelBg)
    f_cell(0, 3, "Agreement", txtSub, rowAlt)
    f_cell(1, 3, agreeTxt, agreeCol, rowAlt)
    f_cell(0, 4, "Last divergence", txtSub, panelBg)
    f_cell(1, 4, divTxt + divAge, divCol, panelBg)
    f_cell(0, 5, "Last reversal", txtSub, rowAlt)
    f_cell(1, 5, revTxt + revAge, revCol, rowAlt)
    f_cell(0, 6, "Delta source", txtSub, panelBg)
    f_cell(1, 6, srcTxt, srcCol, panelBg)

    if dashMode == "Pro" and useCalib
        f_cell(0, 7, "CLASS", txtSub, frameC)
        f_cell(1, 7, "n · Hit±ci · base · edge", txtSub, frameC)
        for c = 1 to NCLS
            int n = clsN.get(c)
            int rr = 7 + c
            color rb = (c % 2) == 0 ? rowAlt : panelBg
            if n < calMinSamp
                f_cell(0, rr, f_clsName(c), txtMain, rb)
                f_cell(1, rr, "n" + str.tostring(n) + " · warming", flatC, rb)
            else
                float h  = f_hitW(c)
                float wh = (calib.wilsonHalf(clsWsum.get(c), clsNsum.get(c), 1.96) / 100.0)
                float whS= (calib.wilsonHalf(clsWsum.get(c), clsNsum.get(c), zSig) / 100.0)
                float bp = clsBase.get(c)/n
                float ed = (na(h)?0.0:h) - bp
                bool  star = not na(whS) and ((na(h)?0.0:h) - whS) > bp
                color ec = ed > 0 ? bullC : bearC
                string s = "n"+str.tostring(n)+" "+str.tostring((na(h)?0.0:h)*100,"0")+(na(wh)?"":"±"+str.tostring(wh*100,"0"))+" b"+str.tostring(bp*100,"0")+" "+(ed>=0?"+":"")+str.tostring(ed*100,"0")+(star?"*":"")
                f_cell(0, rr, f_clsName(c), txtMain, rb)
                f_cell(1, rr, s, ec, rb)
        f_cell(0, 14, "* edge > base (corrected)", flatC, rowAlt)
        f_cell(1, 14, "zone-matched", flatC, rowAlt)
        f_cell(0, 15, "OOS edge (walk-fwd)", flatC, rowAlt)
        f_cell(1, 15, wfOosN < 1 ? "warming" : (na(wfOosEdge) ? "-" : (wfOosEdge >= 0 ? "+" : "") + str.tostring(wfOosEdge, "0.0") + "pp"), na(wfOosEdge) ? flatC : wfOosEdge > 0 ? bullC : bearC, rowAlt)

// ═════════════════════════════════════════════════════════════════════════════
// IDENTITY STRIP  (script name · symbol · timeframe — always visible on chart)
// ═════════════════════════════════════════════════════════════════════════════
var table idTbl = table.new(position.bottom_center, 1, 1, frame_width = 1, border_width = 1, force_overlay = true)
if showId and barstate.islast
    color bgc2  = chart.bg_color
    float luma2 = na(bgc2) ? 0.0 : color.r(bgc2) * 0.299 + color.g(bgc2) * 0.587 + color.b(bgc2) * 0.114
    bool  dk2   = dashTheme == "Dark" ? true : dashTheme == "Light" ? false : (na(bgc2) or luma2 < 140)
    color idBg  = dk2 ? color.new(color.rgb(17, 22, 28), 6)  : color.new(color.rgb(244, 246, 248), 6)
    color idTx  = dk2 ? color.rgb(224, 230, 238)             : color.rgb(20, 26, 32)
    color idFr  = dk2 ? color.rgb(70, 84, 100)               : color.rgb(188, 196, 206)
    table.set_frame_color(idTbl, idFr)
    table.set_border_color(idTbl, idFr)
    table.cell(idTbl, 0, 0, "VFDO · Volume Flow Divergence Oscillator   ·   " + syminfo.ticker + "   ·   " + timeframe.period, text_color = idTx, text_size = size.normal, text_halign = text.align_center, bgcolor = idBg)

// ═════════════════════════════════════════════════════════════════════════════
// ALERTS
// ═════════════════════════════════════════════════════════════════════════════
alertcondition(regBull, "Regular bullish divergence", "VFDO: regular bullish divergence")
alertcondition(regBear, "Regular bearish divergence", "VFDO: regular bearish divergence")
alertcondition(hidBull, "Hidden bullish divergence",  "VFDO: hidden bullish divergence")
alertcondition(hidBear, "Hidden bearish divergence",  "VFDO: hidden bearish divergence")
alertcondition(revTop,  "Upper-extreme reversal",     "VFDO: reversal at the upper extreme")
alertcondition(revBot,  "Lower-extreme reversal",     "VFDO: reversal at the lower extreme")

// ═════════════════════════════════════════════════════════════════════════════
// EXP_* EXPORTS (Data Window · generic names)
// ═════════════════════════════════════════════════════════════════════════════
int   exZone = osc >= extHi ? 2 : osc >= obLevel ? 1 : osc <= extLo ? -2 : osc <= osLevel ? -1 : 0
float exBias = math.max(-100.0, math.min(100.0, math.round(oscZ * 33.0)))
int   exReg  = regBull ? 1 : regBear ? -1 : 0
int   exHid  = hidBull ? 1 : hidBear ? -1 : 0
int   exRev  = revBot ? 1 : revTop ? -1 : 0
float exBull = f_sideEdge(true)
float exBear = f_sideEdge(false)
color exC = color.new(color.gray, 100)
plot(showEXP ? osc        : na, "EXP_Osc",       color = exC, display = display.data_window)
plot(showEXP ? oscZ       : na, "EXP_OscZ",      color = exC, display = display.data_window)
plot(showEXP ? exZone     : na, "EXP_Zone",      color = exC, display = display.data_window)
plot(showEXP ? exBias     : na, "EXP_FlowBias",  color = exC, display = display.data_window)
plot(showEXP ? agreeSum   : na, "EXP_Agreement", color = exC, display = display.data_window)
plot(showEXP ? exReg      : na, "EXP_RegDiv",    color = exC, display = display.data_window)
plot(showEXP ? exHid      : na, "EXP_HidDiv",    color = exC, display = display.data_window)
plot(showEXP ? exRev      : na, "EXP_Reversal",  color = exC, display = display.data_window)
plot(showEXP ? ((useLowerTF and ltfOK) ? 1 : 0) : na, "EXP_DeltaSrc", color = exC, display = display.data_window)
plot(showEXP ? exBull     : na, "EXP_BullEdge",  color = exC, display = display.data_window)
plot(showEXP ? exBear     : na, "EXP_BearEdge",  color = exC, display = display.data_window)

// ═══════════════════════════════════════════════════════════════════════════════
// VSA BAR EVENTS (Wave D · U9 — ml_vsa taxonomy, inlined) + U11 time-of-day volume — OPTIONAL.
//   Names the current bar's dominant Wyckoff/VSA event; exposed via alerts only (this pane is at the plot limit). All ta.* unconditional; the engine and its dashboard are untouched (appended).
// ═══════════════════════════════════════════════════════════════════════════════
gVSA_wd   = "VSA bar events (Wave D)"
vsaLen    = input.int(50, "VSA history window", minval = 10, maxval = 300, group = gVSA_wd)
vsaPiv    = input.int(5,  "New-extreme lookback", minval = 2, maxval = 50, group = gVSA_wd)
vsaTod    = input.bool(false, "Time-of-day volume (U11)", group = gVSA_wd, tooltip = "ON: judge volume against the same time-of-day slot on prior sessions (ml_session baseline, inlined) so a normal-for-the-open bar is not a false climax. Default off.")
vsaTodMin = input.int(5,  "  Slot size (minutes)", minval = 1, maxval = 60, group = gVSA_wd)
vsaTodSes = input.int(20, "  Session memory", minval = 3, maxval = 200, group = gVSA_wd)
bool  vsaHasVol = not na(volume) and volume > 0
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
float vsaSp   = ta.percentrank(high - low, vsaLen)
float vsaVp   = ta.percentrank(vsaVolUse,  vsaLen)
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
int   vsaBiasVal = (vClimaxDn or vShakeout or vStopping) ? 1 : (vClimaxUp or vUpthrust) ? -1 : 0
alertcondition(vUpthrust, "VSA Upthrust",       "Upthrust - new high rejected on volume (bearish trap).")
alertcondition(vShakeout, "VSA Shakeout",       "Shakeout - new low reclaimed on volume (bullish trap).")
alertcondition(vStopping, "VSA Stopping Volume","Stopping Volume - wide down-bar closing off the low (bullish).")
````
