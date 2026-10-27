# Adaptive Bollinger Bands Calibrated and Regime-Aware

- url: https://www.tradingview.com/script/LQ1546Dq-Adaptive-Bollinger-Bands-Calibrated-and-Regime-Aware/
- type: indicator
- pine_id: PUB;6c09d2bd92e44d65b318eb5bf4fdaa4c
- version: 2.0

## Description

# Adaptive Bollinger Bands — Robust, Calibrated & Regime-Aware (BB ARC)

## What this is

Most Bollinger Band tools plot a simple moving average plus or minus two standard deviations and assume price is normally distributed. Real price is not: it has fat tails, it is skewed, and a single spike distorts the width. BB ARC is a full reworking of the Bollinger idea that measures the **actual distribution** of the symbol on your chart, builds statistically honest bands from it, proves how well those bands describe the market in real time, and then decides whether a band touch should be **faded** (range) or **ridden** (trend). Everything is universal: the price source and all optional reference feeds are user-selectable, so it runs on any symbol, any market and any timeframe.

It plots the bands and signals on the price chart and an analytics oscillator (%B or band-z) in a lower pane, with a single dashboard that turns all of it into one read.

## Why these components are combined (mashup rationale)

A raw band only says "price is far from its average." On its own that is ambiguous: in a quiet range a touch of the band mean-reverts, but in a strong trend price "walks the band" and keeps going. Giving the same signal in both situations is the classic Bollinger weakness. BB ARC combines several layers specifically because each one removes a weakness the others cannot, and they feed each other in sequence:

1. **Honest band engine** — replaces the naive standard-deviation width with a choice of robust (median / MAD), asymmetric (separate upside/downside deviation, capturing skew), empirical-quantile (width set so the band actually contains your chosen percentage of bars), or EWMA-volatility estimators, plus a kurtosis-adaptive multiplier that widens the band when tails are fat. This makes the *distance* of a touch statistically meaningful instead of an arbitrary 2-sigma.
2. **Calibration layer** — because the bands now claim to contain a certain fraction of price, the script measures the **realized containment %** on the current symbol, plus skew and kurtosis, so the band proves its own validity instead of asking you to trust a textbook assumption.
3. **Regime filter** (efficiency ratio + ADX + volatility clustering) — decides whether the market is ranging, trending or volatile, and therefore whether the correct response to a band touch is to fade it or ride it. This is what resolves the Bollinger paradox above.
4. **Mean-reversion math** — an Ornstein-Uhlenbeck half-life estimate quantifies how many bars a touch typically takes to revert (and reports "trending" when there is no clean reversion), and band-walk persistence counts how long price has been pinned to a band. Together they tell you whether a reversion is realistically tradable.
5. **Multi-timeframe confluence** — checks %B agreement across four timeframes and draws higher-timeframe band rails on your chart, so a signal is not taken against the larger structure.
6. **Conviction engine** — blends the stretch, regime fit, MTF agreement, half-life quality, calibrated edge, volume thrust and order-flow into a single 0-100 score with hard vetoes, so you get one decision rather than several conflicting indicators.

None of these layers is decorative; remove any one and the others lose context. That interdependence is the reason they are published together rather than as separate scripts.

## What it does, step by step

- Builds a basis (SMA / EMA / rolling VWAP / robust median) and three band tiers using the deviation engine you select.
- Computes **%B** and **bandwidth**, a signed **band-z** (how many multiples beyond the basis, using the correct up or down deviation), realized **containment %**, **skew/kurtosis**, **half-life**, **band-walk** streaks, an empirical **reversion probability** (how often, historically on this symbol, a band touch returned toward the basis within N bars), and a **squeeze** state with an expansion-direction read.
- Classifies the **regime** and auto-selects **Fade** (range reversion) or **Ride** (trend continuation) logic.
- Detects regular **%B divergence** and can draw it as lines connecting the pivots on price.
- Produces a **verdict** (LONG / SHORT / VETO / FLAT) with a conviction score and tier, and fires alerts on bar close.

## How to use it

1. Add it to any chart. The bands appear on price, the %B/band-z analytics in the lower pane, and the dashboard in the corner.
2. Read the **REGIME** and **MODE** rows. In a Range regime the engine looks to **fade** outer-band touches back toward the basis; in a Trend regime it looks to **ride** band-walks in the trend direction.
3. Use the calibration rows as a confidence check: a high containment %, a short half-life and a favourable reversion probability support a fade; "trending" half-life and persistent band-walk support a ride.
4. Treat the **CONVICTION** score and **VETO** as the gate — a high score with no veto is the cleanest setup; a veto explains why a tempting touch is being skipped.
5. Optional: enter a volatility-index symbol and/or a correlated instrument in the feed settings to add a volatility-spike veto and cross-asset confluence. Both are blank (off) by default, so nothing market-specific is assumed.

## What makes it original

- A **multi-engine, statistically honest** band (robust, asymmetric semideviation, empirical quantile, EWMA, fat-tail-adaptive) rather than a single SMA±kσ.
- **Live self-calibration**: the band reports the percentage of bars it actually contained, on the current symbol, so its claim is verifiable.
- An **Ornstein-Uhlenbeck half-life** read that turns "far from the mean" into "expected to revert in about X bars, or not at all."
- An **empirical reversion-probability** statistic built from the chart's own history.
- A **regime-driven fade/ride auto-switch** and a single **conviction score with vetoes**, so the same band touch is interpreted correctly in different market states.

## Settings overview

Grouped as: Core (price source, basis, adaptive length), Band Engine (deviation engine, multipliers, quantile %, EWMA lambda, fat-tail), Regime, Mean-Reversion, Calibration, Squeeze, Signals, MTF, Conviction (weights and minimum), Risk (used for sizing and alert context), Optional Reference Feeds (volatility index, cross-asset — both off by default), and Display (bands, fills, divergence-as-lines toggle, adaptive dashboard, legend, identity label).

## Universal data source

The whole engine runs on a user-selected **price source** (close, hl2, hlc3, ohlc4, or even another indicator's output), and the optional reference feeds are typed in by the user, so the script is not tied to any one instrument or exchange. It also degrades gracefully on instruments without volume.

## A note on the chart used for publishing

The published chart shows only this script. The bottom-centre label prints the script name, the symbol and the timeframe so it is always clear what is plotted. No unrelated drawings or third-party indicators are added.

## Disclaimer

This script is a technical study for educational and informational purposes only. It is not financial, investment or trading advice, and it is not a strategy or a solicitation to buy or sell any instrument. The signals, levels, conviction scores and statistics it displays are derived from past price and volume on your chart and do not guarantee any future result. Markets involve risk; you are solely responsible for your own decisions and risk management. Test thoroughly before relying on any tool.

## Source Code

````pine
// =============================================================================
//  ADAPTIVE VOLATILITY BANDS — Honest, Calibrated & Regime-Aware   Pine Script v6
//  shorttitle: Adaptive Bands
// -----------------------------------------------------------------------------
//  WHAT THIS IS
//    Most band tools plot a moving average ± 2 standard deviations and assume
//    price is normally distributed. It is not — real price has fat tails, is
//    skewed, and a single spike distorts the width. This framework measures the
//    ACTUAL distribution of the symbol on your chart, builds statistically honest
//    bands from it, PROVES how well those bands describe the market in real time,
//    drives the band width by a CLOSED-LOOP controller so realised containment
//    tracks its target, and then decides whether a band touch should be FADED
//    (range) or RIDDEN (trend) — with that decision FORWARD-CALIBRATED so the
//    conviction number reports a measured edge, not an assertion. Works on ANY
//    symbol and ANY timeframe; the price source, volume source and optional
//    reference feeds are user-selectable.
//
//  WHY THESE PIECES ARE COMBINED (mashup justification — read before publishing)
//    A raw band only says "price is far from its average." On its own that is
//    ambiguous: in a quiet range a touch mean-reverts, but in a strong trend price
//    "walks the band" and keeps going — the classic band paradox. This script
//    combines several layers specifically because each removes a weakness the
//    others cannot, and they feed each other in sequence:
//      • HONEST BAND ENGINE replaces the naive standard-deviation width with a
//        choice of robust (median / mean-absolute-deviation), asymmetric (separate
//        up/down deviation, capturing skew), empirical-quantile (width set so the
//        band actually contains your chosen %) or volatility-clustering (EWMA)
//        estimators, plus a kurtosis-adaptive multiplier — so the DISTANCE of a
//        touch is statistically meaningful instead of an arbitrary 2-sigma.
//      • CONTAINMENT CONTROLLER closes the loop: it nudges the band multiplier
//        online so the REALISED containment converges on the stated target. The
//        band is honest by construction, not by assumption.
//      • CALIBRATION LAYER measures realised containment %, skew and kurtosis, and
//        FORWARD-TESTS the Fade and Ride signals per regime (triple-barrier outcome,
//        uniqueness-weighted, recency-decayed, Wilson interval, edge over a regime-
//        matched base rate). The band proves its own validity AND its signals prove
//        their own edge on this symbol.
//      • REGIME FILTER (efficiency ratio + ADX + volatility clustering + a variance-
//        ratio mean-reversion test) decides whether the correct response to a touch
//        is to fade it or ride it — this is what resolves the paradox.
//      • MEAN-REVERSION MATH (a mean-reversion half-life) quantifies how many bars a
//        touch typically takes to revert, and reports "trending" when there is none.
//      • MULTI-TIMEFRAME CONFLUENCE checks band agreement across timeframes and
//        draws higher-timeframe rails, so a signal is not taken against structure.
//      • CONVICTION ENGINE blends stretch, regime fit, MTF agreement, half-life
//        quality, the CALIBRATED edge, volume thrust and order flow into a single
//        0–100 score with hard vetoes — and a RELIABILITY check then asks whether
//        that score is itself well-calibrated.
//    Remove a layer and the read loses a check it cannot recover. They ship as one
//    engine because a band, a regime and an edge are one decision, not three tools.
//
//  HOW TO USE
//    1. Read the KEY block: verdict + conviction, mode (Fade/Ride), regime, stretch,
//       containment-vs-target and the calibrated per-mode edge.
//    2. Fade a band touch only in a Range with a short reversion half-life and a
//       Fade edge that beats its base rate; Ride a band-walk only in a Trend with a
//       Ride edge that beats its base rate. The dashboard tells you which applies.
//    3. The lower pane shows %B or band-z with squeeze and divergence; the price
//       overlay shows the bands, reversion-heat fill and higher-timeframe rails.
//    4. Everything is descriptive, probabilistic context — never an instruction.
//
//  DATA SOURCE / ANY MARKET
//    The price source, the volume source (with an optional borrow symbol for
//    no-volume instruments) and all optional feeds are inputs; every threshold is
//    ATR-relative or percentile-based. DEFAULTS ARE TUNED FOR NIFTY INDEX FUTURES
//    (volatility index NSE:INDIAVIX) — change the sources and feeds for any market.
//
//  EXPORTS (Data Window · generic names for cross-script consumption via input.source)
//    EXP_PctB, EXP_BandZ, EXP_Basis, EXP_UpperMain, EXP_LowerMain, EXP_Bandwidth,
//    EXP_BWPercentile, EXP_Regime, EXP_HalfLife, EXP_Containment, EXP_VarRatio,
//    EXP_FadeEdge, EXP_RideEdge, EXP_Conviction, EXP_Dir, EXP_Bias, EXP_Squeeze,
//    EXP_Divergence, EXP_Brier
//
//  NON-REPAINT
//    All higher-timeframe and reference feeds use lookahead_off; signals confirm on
//    bar close (toggle), and every calibrated statistic resolves on confirmed bars,
//    forward-measured at fixed barriers. The live bar's read is provisional.
//
//  CONCEPT CREDITS (techniques operationalised here — not third-party code)
//    Volatility bands, %B and bandwidth: John Bollinger. Median-absolute-deviation
//    robust scale & semivariance: robust-statistics practice. Mean-reversion half-
//    life (Ornstein–Uhlenbeck / AR(1)): Uhlenbeck & Ornstein; Vasicek. Variance-
//    ratio mean-reversion test: Lo & MacKinlay. Dominant-cycle adaptive length:
//    John Ehlers. Efficiency-ratio regime: Perry Kaufman. Self-exciting (Hawkes)
//    volatility clustering: Hawkes. EWMA volatility (RiskMetrics): J.P. Morgan.
//    Triple-barrier labelling & sample uniqueness: López de Prado. Wilson score
//    interval: Edwin B. Wilson; multiple-testing correction: Šidák. The honest-band
//    integration, the containment controller, the per-mode forward calibration and
//    the reliability-checked conviction are this script's own original implementation.
//
//  DISCLAIMER
//    Study / indicator for chart analysis and education only. NOT a strategy, NOT a
//    recommendation, NOT financial advice. Calibration is in-sample, forward-measured
//    at fixed barriers, with no costs / slippage / stops; the position-size figure is
//    a suggestion, not an order. Markets carry risk. Do your own research and manage
//    your own risk.
// =============================================================================

//@version=6
indicator("Adaptive Volatility Bands — Honest, Calibrated & Regime-Aware", shorttitle="Adaptive Bands", overlay=false,
     max_lines_count=200, max_labels_count=200, precision=4)

// =============================================================================
// HELPERS  (UDFs use their args + built-ins only, never globals)
// =============================================================================
f_clamp(x, lo, hi) => math.max(lo, math.min(hi, x))
sgn(x)  => x >= 0 ? "+" : ""
f_pos(s) => s=="top_left"?position.top_left : s=="bottom_right"?position.bottom_right : s=="bottom_left"?position.bottom_left : position.top_right
f_fetch(sym) => request.security(sym, timeframe.period, close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
f_luma(c) => na(c) ? 0.0 : color.r(c)*0.299 + color.g(c)*0.587 + color.b(c)*0.114
// Wilson score half-width for proportion w/n at confidence z (args only)
f_wilson(w, n, zc) =>
    float r = na
    if n > 0.0
        float pp = w / n
        float den = 1.0 + zc*zc/n
        r := zc * math.sqrt(pp*(1.0-pp)/n + zc*zc/(4.0*n*n)) / den
    r

f_aema(src, len) =>
    a = 2.0 / (math.max(len, 1) + 1)
    var float e = na
    e := na(e[1]) ? src : e[1] + a * (src - e[1])
    e

f_basis(src, vol, n) =>
    int nn = int(math.max(2, math.min(n, 250)))
    float s  = 0.0
    float sv = 0.0
    float wv = 0.0
    arr = array.new<float>()
    for i = 0 to nn - 1
        v  = nz(src[i], src)
        vv = nz(vol[i], 0.0)
        s  += v
        sv += v * vv
        wv += vv
        array.push(arr, v)
    sma  = s / nn
    vwap = wv > 0 ? sv / wv : sma
    med  = array.median(arr)
    [sma, vwap, med, arr]

f_dev(src, n, basisVal, medVal) =>
    int nn = int(math.max(2, math.min(n, 250)))
    float ss = 0.0
    float up = 0.0
    float dn = 0.0
    float s3 = 0.0
    float s4 = 0.0
    adArr = array.new<float>()
    for i = 0 to nn - 1
        v = nz(src[i], src)
        d = v - basisVal
        ss += d * d
        s3 += d * d * d
        s4 += d * d * d * d
        if d > 0
            up += d * d
        else
            dn += d * d
        array.push(adArr, math.abs(v - medVal))
    variance = ss / nn
    sd  = math.sqrt(variance)
    sUp = math.sqrt(up / nn) * 1.41421356
    sDn = math.sqrt(dn / nn) * 1.41421356
    mad = array.median(adArr) * 1.4826
    skew = sd > 0 ? (s3 / nn) / math.pow(sd, 3) : 0.0
    kurt = sd > 0 ? (s4 / nn) / math.pow(sd, 4) : 3.0
    [sd, sUp, sDn, mad, skew, kurt]

// calibration sample objects
type Ev
    int   dir
    int   cls
    int   reg
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
    int   reg
type Rel
    float pred
    int   dir
    float entry
    float atr0
    int   bidx

// =============================================================================
// INPUTS
// =============================================================================
gCore   = "① Source & Basis"
src_in  = input.source(close, "Price source", group=gCore, tooltip="Series the whole engine runs on. Works on any symbol/market; can point at another indicator's plot.")
volSrc  = input.source(volume, "Volume source", group=gCore, tooltip="Volume series for the rolling-VWAP basis, volume thrust and order-flow. Use the borrow symbol below for instruments that report no volume.")
volBorrowSym = input.symbol("", "Borrow volume from symbol (no-volume fix)", group=gCore, tooltip="Supplies volume where the charted symbol reports none (e.g. an index). Leave blank to use the volume source above.")
basisType=input.string("SMA", "Basis (middle band)", options=["SMA","EMA","VWAP (rolling)","Median (robust)"], group=gCore, tooltip="Median makes the basis robust to single spikes.")
bbLen   = input.int   (20, "Band length", minval=5, maxval=250, group=gCore)
useAdaptLen=input.bool (true, "Adaptive length (dominant cycle)", group=gCore, tooltip="Retune the band length to the market's measured cycle instead of a fixed value.")
adaptMin= input.int   (12, "  Adaptive min", minval=5, maxval=100, group=gCore)
adaptMax= input.int   (60, "  Adaptive max", minval=10, maxval=250, group=gCore)
adaptMlt= input.float (1.0,"  Adaptive cycle ×", minval=0.25, maxval=3.0, step=0.05, group=gCore)

gBand   = "② Honest Band Engine"
devEngine=input.string("Asymmetric semidev", "Deviation engine", options=["Classic stdev","Robust MAD","Asymmetric semidev","Quantile (empirical)","EWMA vol"], group=gBand, tooltip="How band width is measured. Classic = textbook. Robust = spike-resistant. Asymmetric = separate up/down width (captures skew). Quantile = empirical containment. EWMA = volatility-clustering aware.")
k1      = input.float (1.0, "Inner band ×", minval=0.25, maxval=4.0, step=0.1, group=gBand)
k2      = input.float (2.0, "Main band ×",  minval=0.5,  maxval=5.0, step=0.1, group=gBand)
k3      = input.float (3.0, "Outer band ×", minval=1.0,  maxval=6.0, step=0.1, group=gBand)
qCont   = input.float (95.0,"Target containment %", minval=50, maxval=99.9, step=0.5, group=gBand, tooltip="Target % of bars the main band should contain. Used by the Quantile engine and by the containment controller.")
ewmaLam = input.float (0.94,"EWMA lambda", minval=0.80, maxval=0.995, step=0.005, group=gBand, tooltip="Only used by the EWMA engine. 0.94 = industry default.")
fatTail = input.bool  (true,"Fat-tail multiplier (kurtosis-adaptive)", group=gBand, tooltip="Widen bands when the distribution has fat tails, so the target containment actually holds.")
fatGain = input.float (0.5, "  Fat-tail gain", minval=0.0, maxval=2.0, step=0.1, group=gBand)

gCtrl   = "③ Containment Controller (closed loop)"
useController = input.bool(true, "Drive realised containment to target", group=gCtrl, tooltip="Nudges the band multiplier online so the realised containment % converges on the target above. Makes the bands honest by construction.")
ctrlGain = input.float(0.02, "Controller gain", minval=0.001, maxval=0.2, step=0.001, group=gCtrl, tooltip="How fast the multiplier adapts. Higher = faster but noisier.")

gReg    = "④ Regime"
erLen   = input.int   (14,   "Efficiency-ratio length", minval=4, maxval=50, group=gReg)
adxLen  = input.int   (14,   "ADX length", minval=4, maxval=50, group=gReg)
adxTrd  = input.float (20.0, "ADX trend threshold", minval=10, maxval=40, group=gReg)
erTrd   = input.float (0.35, "ER trend threshold", minval=0.1, maxval=0.9, step=0.01, group=gReg)
hawkK   = input.float (0.20, "Volatility-cluster decay", minval=0.02, maxval=0.9, step=0.01, group=gReg)
hawkThr = input.float (1.5,  "Volatility-cluster z threshold", minval=0.5, maxval=4.0, step=0.1, group=gReg)
regMaLn = input.int   (50,   "Regime trend MA", minval=10, maxval=200, group=gReg)
normLen = input.int   (100,  "Normalization window", minval=20, maxval=500, group=gReg)
useVarRatio = input.bool(true, "Variance-ratio mean-reversion test", group=gReg, tooltip="A statistical test of whether the series is mean-reverting (ratio < 1) or trending (ratio > 1); refines the Fade-vs-Ride decision.")
vrQ     = input.int   (4,    "  Variance-ratio period q", minval=2, maxval=20, group=gReg)
vrLen   = input.int   (100,  "  Variance-ratio window", minval=20, maxval=400, group=gReg)

gRev    = "⑤ Mean-Reversion Engine"
hlLen   = input.int   (100,  "Half-life window", minval=20, maxval=300, group=gRev, tooltip="Window for the mean-reversion half-life estimate (how many bars a band touch typically takes to revert).")
walkBars= input.int   (3,    "Band-walk streak (Ride threshold)", minval=2, maxval=15, group=gRev, tooltip="Consecutive closes beyond the main band that count as 'walking the band' (trend continuation, not reversion).")
revTgt  = input.string("Basis", "Fade target", options=["Basis","Opposite inner","Half stretch"], group=gRev)

gCal    = "⑥ Calibration & Edge Stats"
showCal = input.bool  (true, "Compute calibration stats", group=gCal)
calLen  = input.int   (250,  "Containment window", minval=50, maxval=1000, group=gCal)
revLook = input.int   (10,   "Reversion lookahead (bars)", minval=2, maxval=50, group=gCal, tooltip="For the empirical reversion-probability stat: how many bars after a band touch to check for a return toward the basis.")
calHorizon = input.int(20,   "Signal horizon (bars, vertical barrier)", minval=3, maxval=100, group=gCal)
calMoveATR = input.float(1.0, "Profit barrier (× ATR)", minval=0.2, maxval=4.0, step=0.1, group=gCal)
calStopATR = input.float(1.0, "Stop barrier (× ATR)", minval=0.2, maxval=4.0, step=0.1, group=gCal)
calMinSamp = input.int(5,    "Min samples to trust / feed back", minval=3, maxval=50, group=gCal)
calMinGap  = input.int(5,    "Min bars between same-class samples", minval=1, maxval=40, group=gCal)
useUniq    = input.bool(true, "Uniqueness-weight samples", group=gCal, tooltip="Down-weight signals whose forward windows overlap others, so concurrent samples cannot over-count.")
calDecay   = input.float(0.99, "Recency decay (per resolved sample)", minval=0.80, maxval=1.0, step=0.005, group=gCal)
useReliability = input.bool(true, "Calibrate conviction (reliability / Brier)", group=gCal, tooltip="Check whether the conviction score is well-calibrated (does 75 beat 50?), and report the gap.")

gSqz    = "⑦ Squeeze"
showSqz = input.bool  (true, "Squeeze detection", group=gSqz)
sqLen   = input.int   (100,  "  Bandwidth percentile window", minval=20, maxval=400, group=gSqz)
sqPct   = input.int   (15,   "  Squeeze threshold (low %ile)", minval=1, maxval=50, group=gSqz)
sqRel   = input.int   (8,    "  Expansion window (bars)", minval=1, maxval=30, group=gSqz)

gSig    = "⑧ Signals"
useFade = input.bool  (true, "Fade signals (range reversion)", group=gSig)
useRide = input.bool  (true, "Ride signals (trend band-walk)", group=gSig)
volConf = input.bool  (true, "Require volume / flow confirmation", group=gSig)
pvL     = input.int   (5,    "Divergence pivot left",  minval=2, maxval=20, group=gSig)
pvR     = input.int   (3,    "Divergence pivot right", minval=1, maxval=10, group=gSig)

gMtf    = "⑨ Multi-Timeframe Confluence"
useMtf  = input.bool  (true, "Enable MTF %B agreement", group=gMtf)
tf1     = input.timeframe("5",  "TF 1", group=gMtf)
tf2     = input.timeframe("15", "TF 2", group=gMtf)
tf3     = input.timeframe("60", "TF 3", group=gMtf)
tf4     = input.timeframe("240","TF 4", group=gMtf)
minAlign= input.int   (3,    "Min TF agreement (else veto)", minval=1, maxval=4, group=gMtf)
showHtfRails=input.bool(true, "Draw higher-TF band rails on price", group=gMtf)
htfTf   = input.timeframe("D", "  Higher timeframe (rails + gate)", group=gMtf)
useHtfGate=input.bool (true, "Higher-TF bias gate (block counter-trend Ride)", group=gMtf)
confirmClose=input.bool(true,"Confirm signals on bar close (no repaint)", group=gMtf)

gCon    = "⑩ Conviction"
minConv = input.int   (50,   "Min conviction to act", minval=0, maxval=100, group=gCon)
wBand   = input.float (28,   "Weight: band stretch (%B/z)", group=gCon)
wReg    = input.float (16,   "Weight: regime fit", group=gCon)
wMtf    = input.float (16,   "Weight: MTF agreement", group=gCon)
wHalf   = input.float (12,   "Weight: half-life quality", group=gCon)
wCal    = input.float (10,   "Weight: calibrated edge", group=gCon)
wVol    = input.float (10,   "Weight: volume thrust", group=gCon)
wCvd    = input.float (8,    "Weight: order-flow confirm", group=gCon)

gRisk   = "⑪ Risk & Position Sizing"
atrLen  = input.int   (14,   "ATR length", minval=4, maxval=50, group=gRisk)
stopMode= input.string("Outer band", "Stop basis", options=["Outer band","ATR","Half-life"], group=gRisk)
stopMult= input.float (1.0,  "Stop padding (ATR ×)", minval=0.0, maxval=5.0, step=0.1, group=gRisk)
equity  = input.float (1000000, "Account equity", group=gRisk, tooltip="Account size in the instrument's currency; only used to suggest a position size.")
riskPct = input.float (1.0,  "Risk % per trade", minval=0.1, maxval=10, step=0.1, group=gRisk)
ptValue = input.float (1.0,  "Value per 1.0 price move (per unit)", minval=0.01, group=gRisk, tooltip="Stocks/index = 1. Futures = the contract point value. Size suggestion only.")

gData   = "⑫ Optional Reference Feeds (degrade gracefully)"
ltfRes  = input.timeframe("1", "Intrabar resolution (order flow)", group=gData)
vixSym  = input.symbol("NSE:INDIAVIX", "Volatility-index symbol (optional)", group=gData, tooltip="A volatility index for the market you trade enables a volatility-spike veto on mean-reversion fades. Default suits NIFTY. Clear to disable.")
vixLen  = input.int   (50,   "  Vol-index z window", minval=10, maxval=200, group=gData)
vixSpk  = input.float (1.5,  "  Vol-index spike z (veto fades into spikes)", minval=0.5, maxval=4.0, step=0.1, group=gData)
xaSym   = input.string("", "Cross-asset symbol (optional)", group=gData, tooltip="A correlated or inverse instrument adds cross-asset confluence to trend rides. Set the sign below. Leave blank to disable.")
xaSign  = input.int   (1,    "  Cross-asset correlation sign", options=[1,-1], group=gData)
xaLen   = input.int   (10,   "  Cross-asset momentum lookback", minval=2, maxval=50, group=gData)

gVis    = "⑬ Display"
showBands=input.bool  (true, "Bands on PRICE", group=gVis)
showFill =input.bool  (true, "Reversion-heat fill", group=gVis)
showInner=input.bool  (true, "Show inner & outer bands (1×/3×)", group=gVis)
modeTint =input.bool  (true, "Tint basis by Fade/Ride mode", group=gVis, tooltip="Colours the basis by the current regime decision so you can see at a glance whether a touch is to be faded or ridden.")
showSignals=input.bool(true, "Fade/Ride markers on PRICE", group=gVis)
paneMode  =input.string("%B", "Lower-pane oscillator", options=["%B","Band-z"], group=gVis)
tradeOverlay=input.bool(true, "Divergence as lines on price (off = pane dots only)", group=gVis)
divKeep  = input.int  (6,  "  Divergence lines to keep on chart", minval=1, maxval=30, group=gVis)

gTbl    = "⑭ Dashboard"
showTbl  = input.bool (true, "Show dashboard", group=gTbl)
compactTbl=input.bool (false, "Compact dashboard (off = full institution table)", group=gTbl)
showLegend=input.bool(false, "Show legend in dashboard", group=gTbl)
tblPos   = input.string("top_right", "Dashboard position", options=["top_right","top_left","bottom_right","bottom_left"], group=gTbl)
tblTheme = input.string("Auto", "Dashboard theme", options=["Auto","Dark","Light"], group=gTbl, tooltip="Auto flips colours so the table stays readable on white or black charts.")
showId   = input.bool (true, "Show name / symbol / timeframe label", group=gTbl)

gExp    = "⑮ Exports (Data Window)"
showEXP = input.bool (true, "Emit EXP_* exports", group=gExp, tooltip="Hidden Data-Window series with generic names for input.source() consumption by other scripts.")

// =============================================================================
// VOLUME (source + optional borrow)
// =============================================================================
var bool nativeVolSeen = false
if nz(volSrc, 0) > 0
    nativeVolSeen := true
useBorrow = str.length(volBorrowSym) > 0 and not nativeVolSeen
volBorrowRaw = request.security(volBorrowSym, timeframe.period, volume, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
volEff = useBorrow and not na(volBorrowRaw) ? volBorrowRaw : volSrc
volNz = nz(volEff, 0.0)
volLive = ta.cum(volNz) > 0

// =============================================================================
// L3 — ADAPTIVE LENGTH (dominant cycle) — optional
// =============================================================================
hl2src = (high + low) / 2.0
var float Period = 12.0
Smooth = (4*hl2src + 3*hl2src[1] + 2*hl2src[2] + hl2src[3]) / 10.0
adjc = (0.075*Period + 0.54)
Detr = (0.0962*Smooth + 0.5769*nz(Smooth[2]) - 0.5769*nz(Smooth[4]) - 0.0962*nz(Smooth[6])) * adjc
Q1   = (0.0962*Detr + 0.5769*nz(Detr[2]) - 0.5769*nz(Detr[4]) - 0.0962*nz(Detr[6])) * adjc
I1   = nz(Detr[3])
jI   = (0.0962*I1 + 0.5769*nz(I1[2]) - 0.5769*nz(I1[4]) - 0.0962*nz(I1[6])) * adjc
jQ   = (0.0962*Q1 + 0.5769*nz(Q1[2]) - 0.5769*nz(Q1[4]) - 0.0962*nz(Q1[6])) * adjc
var float I2 = 0.0
var float Q2 = 0.0
I2 := 0.2*(I1 - jQ) + 0.8*nz(I2[1])
Q2 := 0.2*(Q1 + jI) + 0.8*nz(Q2[1])
var float Re = 0.0
var float Im = 0.0
Re := 0.2*(I2*nz(I2[1]) + Q2*nz(Q2[1])) + 0.8*nz(Re[1])
Im := 0.2*(I2*nz(Q2[1]) - Q2*nz(I2[1])) + 0.8*nz(Im[1])
float pNew = Period
if Im != 0 and Re != 0
    pNew := 2.0 * math.pi / math.abs(math.atan(Im / Re))
pNew := f_clamp(pNew, 0.67*Period, 1.5*Period)
pNew := f_clamp(pNew, 6.0, 50.0)
Period := 0.2*pNew + 0.8*Period
domCycle = Period
int lenUse = useAdaptLen ? int(f_clamp(math.round(domCycle * adaptMlt), adaptMin, adaptMax)) : bbLen

// =============================================================================
// L1 — BAND ENGINE (honest bands + containment controller)
// =============================================================================
var float kAdapt = 1.0
[bSma, bVwap, bMed, bArr] = f_basis(src_in, volEff, lenUse)
emaBasis = f_aema(src_in, lenUse)
basis = basisType=="EMA" ? emaBasis : basisType=="VWAP (rolling)" ? bVwap : basisType=="Median (robust)" ? bMed : bSma
[bSD, bSUp, bSDn, bMAD, bSkew, bKurt] = f_dev(src_in, lenUse, basis, bMed)

ret = src_in - nz(src_in[1], src_in)
var float ewmaVar = 0.0
ewmaVar := na(ewmaVar[1]) or ewmaVar[1]==0 ? ret*ret : ewmaLam*ewmaVar[1] + (1.0-ewmaLam)*ret*ret
ewmaSig = math.sqrt(ewmaVar)

qHiPct = 100.0 - (100.0 - qCont)/2.0
qLoPct = (100.0 - qCont)/2.0
qUpLvl = array.percentile_linear_interpolation(bArr, qHiPct)
qLoLvl = array.percentile_linear_interpolation(bArr, qLoPct)

tailF = fatTail ? f_clamp(1.0 + fatGain*(bKurt/3.0 - 1.0), 1.0, 2.5) : 1.0
kCtrl = useController ? kAdapt : 1.0

float devUp = bSD
float devDn = bSD
if devEngine == "Robust MAD"
    devUp := bMAD
    devDn := bMAD
else if devEngine == "Asymmetric semidev"
    devUp := bSUp
    devDn := bSDn
else if devEngine == "EWMA vol"
    devUp := ewmaSig
    devDn := ewmaSig
else if devEngine == "Quantile (empirical)"
    devUp := math.max(qUpLvl - basis, 0.0) / math.max(k2, 0.01)
    devDn := math.max(basis - qLoLvl, 0.0) / math.max(k2, 0.01)
devUp := devUp * tailF * kCtrl
devDn := devDn * tailF * kCtrl

upper1 = basis + devUp*k1
upper2 = basis + devUp*k2
upper3 = basis + devUp*k3
lower1 = basis - devDn*k1
lower2 = basis - devDn*k2
lower3 = basis - devDn*k3

bandRange = upper2 - lower2
pctB = bandRange != 0 ? (src_in - lower2) / bandRange : 0.5
bandwidth = basis != 0 ? bandRange / basis : 0.0
bandZ = src_in >= basis ? (devUp>0 ? (src_in-basis)/devUp : 0.0) : (devDn>0 ? (src_in-basis)/devDn : 0.0)

// =============================================================================
// L2 — REGIME (+ variance-ratio mean-reversion test)
// =============================================================================
[diP, diM, adx] = ta.dmi(adxLen, adxLen)
logRet = math.abs(nz(ta.change(math.log(close))))
var float hawkes = 0.0
hawkes := hawkes * math.exp(-hawkK) + logRet
hMeanH = ta.sma(hawkes, normLen)
hStdH  = ta.stdev(hawkes, normLen)
hawkesZ = hStdH == 0 ? 0.0 : (hawkes - hMeanH) / hStdH
volCluster = hawkesZ > hawkThr
erChg = math.abs(src_in - src_in[erLen])
erVol = math.sum(math.abs(src_in - src_in[1]), erLen)
er = erVol == 0 ? 0.0 : erChg / erVol
trendMa = ta.ema(close, regMaLn)
bull = close > trendMa
trending = adx > adxTrd and er > erTrd
regimePct = math.round(f_clamp((adx/40.0)*50 + er*50, 0, 100))
string regime = volCluster and not trending ? "Volatile" : trending ? (bull ? "Trend Bull" : "Trend Bear") : "Range"
regColor = regime == "Trend Bull" ? color.teal : regime == "Trend Bear" ? color.red : regime == "Volatile" ? color.orange : color.gray
phase = trending ? (bull ? "MARKUP" : "MARKDOWN") : (close > trendMa ? "DISTRIB" : "ACCUM")
isRange = regime == "Range"
isTrend = trending
int regId = isTrend ? 1 : (regime == "Volatile" ? 2 : 0)

// variance ratio: Var(q-bar return) / (q · Var(1-bar return)); <1 mean-reverting, >1 trending
ret1v = close - nz(close[1], close)
retqv = close - nz(close[vrQ], close)
var1v = ta.variance(ret1v, vrLen)
varqv = ta.variance(retqv, vrLen)
float varRatio = (useVarRatio and var1v > 0 and vrQ > 0) ? varqv / (vrQ * var1v) : na
bool meanRev = not na(varRatio) and varRatio < 1.0

// order flow via intrabar lower-tf delta, with chart-bar fallback
ltfArr = request.security_lower_tf(syminfo.tickerid, ltfRes, (close >= open ? 1.0 : -1.0) * volNz)
ltfOk  = array.size(ltfArr) > 0
barDelta = ltfOk ? array.sum(ltfArr) : (close >= open ? 1.0 : -1.0) * volNz
cvd = ta.cum(barDelta)
cvdSlope = cvd - nz(cvd[5], cvd)
cvdSign = math.sign(cvdSlope)

// optional feeds
vix = f_fetch(vixSym)
vixLive = not na(vix)
vixMean = ta.sma(vix, vixLen)
vixSD   = ta.stdev(vix, vixLen)
vixZ = (vixLive and vixSD > 0) ? (vix - vixMean) / vixSD : 0.0
vixSpike = vixLive and vixZ >= vixSpk
xaSymUse = str.length(xaSym) > 0 ? xaSym : syminfo.tickerid
xaRaw = request.security(xaSymUse, timeframe.period, close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
xa = str.length(xaSym) > 0 ? xaRaw : na
xaLive = not na(xa)
xaMom = xaLive ? math.sign(xa - nz(xa[xaLen], xa)) * xaSign : 0

// =============================================================================
// L4 — REVERSION MATH (half-life, band-walk persistence)
// =============================================================================
spread = src_in - basis
spread1 = nz(spread[1], spread)
mS  = ta.sma(spread, hlLen)
mS1 = ta.sma(spread1, hlLen)
covS  = ta.sma(spread * spread1, hlLen) - mS * mS1
varS1 = ta.sma(spread1 * spread1, hlLen) - mS1 * mS1
betaAR = varS1 > 0 ? covS / varS1 : na
halfLife = (not na(betaAR) and betaAR > 0 and betaAR < 1) ? -math.log(2) / math.log(betaAR) : na
revPts = math.abs(src_in - basis)

var int walkUp = 0
var int walkDn = 0
walkUp := close > upper2 ? walkUp + 1 : 0
walkDn := close < lower2 ? walkDn + 1 : 0
walking = walkUp >= walkBars or walkDn >= walkBars
walkDir = walkUp >= walkBars ? 1 : walkDn >= walkBars ? -1 : 0

// =============================================================================
// L5 — CALIBRATION (containment + regime-split reversion prob) + CONTROLLER
// =============================================================================
inBand = (close <= upper2 and close >= lower2) ? 1.0 : 0.0
inBandSma = ta.sma(inBand, calLen)
containPct = showCal ? inBandSma * 100.0 : na

// containment controller: drive realised containment toward target (applied next bar via kAdapt)
float ctTarget = qCont/100.0
if useController and barstate.isconfirmed and not na(inBandSma)
    kAdapt := f_clamp(kAdapt + ctrlGain*(ctTarget - inBandSma), 0.5, 2.0)
string containVerdict = na(inBandSma) ? "warming" : math.abs(inBandSma - ctTarget) <= 0.03 ? "calibrated" : inBandSma < ctTarget ? "too tight" : "too wide"

// empirical reversion probability, split by regime bucket (0 range,1 trend,2 vol)
var int[] upEvR = array.new<int>(3, 0)
var int[] upRevR = array.new<int>(3, 0)
var int[] dnEvR = array.new<int>(3, 0)
var int[] dnRevR = array.new<int>(3, 0)
if showCal and barstate.isconfirmed and bar_index > revLook + 5
    int rgPast = nz(regId[revLook], 0)
    int rgi = rgPast >= 0 and rgPast <= 2 ? rgPast : 0
    if pctB[revLook] >= 1.0
        upEvR.set(rgi, upEvR.get(rgi) + 1)
        if ta.lowest(pctB, revLook) <= 0.5
            upRevR.set(rgi, upRevR.get(rgi) + 1)
    if pctB[revLook] <= 0.0
        dnEvR.set(rgi, dnEvR.get(rgi) + 1)
        if ta.highest(pctB, revLook) >= 0.5
            dnRevR.set(rgi, dnRevR.get(rgi) + 1)
// range-regime reversion odds (the ones that matter for fading)
pUpRev = upEvR.get(0) > 0 ? upRevR.get(0) / float(upEvR.get(0)) * 100.0 : na
pDnRev = dnEvR.get(0) > 0 ? dnRevR.get(0) / float(dnEvR.get(0)) * 100.0 : na

// =============================================================================
// SQUEEZE  (bandwidth percentile)
// =============================================================================
bwRank = ta.percentrank(bandwidth, sqLen)
sqzOn = showSqz and bwRank <= sqPct
var int sinceSqz = 9999
sinceSqz := sqzOn ? 0 : sinceSqz + 1
sqzFire = showSqz and not sqzOn and sinceSqz <= sqRel and bandwidth > nz(bandwidth[1])
fireDir = sqzFire ? (close > basis ? 1 : -1) : 0

// =============================================================================
// MTF — CONFLUENCE
// =============================================================================
f_mtfbb() =>
    b = ta.sma(close, 20)
    sd = ta.stdev(close, 20)
    u = b + 2*sd
    l = b - 2*sd
    pb = (u - l) != 0 ? (close - l) / (u - l) : 0.5
    math.sign(pb - 0.5)
f_rails() =>
    b = ta.sma(close, 20)
    sd = ta.stdev(close, 20)
    [b + 2*sd, b - 2*sd, b]

mtf1 = useMtf ? nz(request.security(syminfo.tickerid, tf1, f_mtfbb(), lookahead=barmerge.lookahead_off)) : 0
mtf2 = useMtf ? nz(request.security(syminfo.tickerid, tf2, f_mtfbb(), lookahead=barmerge.lookahead_off)) : 0
mtf3 = useMtf ? nz(request.security(syminfo.tickerid, tf3, f_mtfbb(), lookahead=barmerge.lookahead_off)) : 0
mtf4 = useMtf ? nz(request.security(syminfo.tickerid, tf4, f_mtfbb(), lookahead=barmerge.lookahead_off)) : 0
mtfBull = (mtf1>0?1:0)+(mtf2>0?1:0)+(mtf3>0?1:0)+(mtf4>0?1:0)
mtfBear = (mtf1<0?1:0)+(mtf2<0?1:0)+(mtf3<0?1:0)+(mtf4<0?1:0)
htfSign = nz(request.security(syminfo.tickerid, htfTf, f_mtfbb(), lookahead=barmerge.lookahead_off))
[htfU, htfL, htfB] = request.security(syminfo.tickerid, htfTf, f_rails(), lookahead=barmerge.lookahead_off)

// =============================================================================
// L6 — SIGNALS  (Fade in range, Ride in trend; auto-switch by regime)
// =============================================================================
barConfirmed = confirmClose ? barstate.isconfirmed : true
volSma20 = ta.sma(volNz, 20)
volThrust = volLive ? volNz > volSma20 * 1.2 : true
fadeOkVol = (not volConf) or volThrust

upPierce = high >= upper2 and close < upper2
dnPierce = low  <= lower2 and close > lower2
fadeShort = useFade and isRange and upPierce and (pctB[1] >= 1.0 or bandZ[1] >= k2) and fadeOkVol and barConfirmed
fadeLong  = useFade and isRange and dnPierce and (pctB[1] <= 0.0 or bandZ[1] <= -k2) and fadeOkVol and barConfirmed

rideLong  = useRide and isTrend and bull       and (walkDir>0 or (close>upper1 and close>nz(close[1]))) and fadeOkVol and barConfirmed
rideShort = useRide and isTrend and (not bull)  and (walkDir<0 or (close<lower1 and close<nz(close[1]))) and fadeOkVol and barConfirmed
if useHtfGate
    rideLong  := rideLong  and htfSign >= 0
    rideShort := rideShort and htfSign <= 0

// %B divergence (regular)
ph = ta.pivothigh(pctB, pvL, pvR)
pl = ta.pivotlow(pctB, pvL, pvR)
var float lpH = na
var float ppH = na
var float lpHp = na
var float ppHp = na
var int   lpHx = na
var int   ppHx = na
if not na(ph)
    ppH := lpH
    ppHp := lpHp
    ppHx := lpHx
    lpH := ph
    lpHp := close[pvR]
    lpHx := bar_index - pvR
var float lpL = na
var float ppL = na
var float lpLp = na
var float ppLp = na
var int   lpLx = na
var int   ppLx = na
if not na(pl)
    ppL := lpL
    ppLp := lpLp
    ppLx := lpLx
    lpL := pl
    lpLp := close[pvR]
    lpLx := bar_index - pvR
bearDiv = (not na(ppH)) and not na(ph) and lpHp > ppHp and lpH < ppH
bullDiv = (not na(ppL)) and not na(pl) and lpLp < ppLp and lpL > ppL
divDir = bullDiv ? 1 : bearDiv ? -1 : 0

// =============================================================================
// CALIBRATION STATE + FIRING (inline; no globals-in-UDF)
// =============================================================================
int NCLS = 3   // 1 Fade · 2 Ride · 3 Squeeze
f_clsName(id) => id==1 ? "Fade" : id==2 ? "Ride" : id==3 ? "Squeeze" : "—"
var array<Ev>   pend = array.new<Ev>()
var array<Base> bq   = array.new<Base>()
var array<Rel>  relQ = array.new<Rel>()
var int[]   clsN    = array.new<int>(NCLS+1, 0)
var float[] clsNsum = array.new<float>(NCLS+1, 0.0)
var float[] clsWsum = array.new<float>(NCLS+1, 0.0)
var float[] clsMFE  = array.new<float>(NCLS+1, 0.0)
var float[] clsMAE  = array.new<float>(NCLS+1, 0.0)
var float[] clsBase = array.new<float>(NCLS+1, 0.0)
var int[]   baseN  = array.new<int>(3, 0)
var int[]   baseUp = array.new<int>(3, 0)
var int[]   baseDn = array.new<int>(3, 0)
var int lastFadeBar = -100000
var int lastRideBar = -100000
var int lastSqzBar  = -100000
var float sumRelP = 0.0
var float sumRelR = 0.0
var float sumRelB = 0.0
var int   nRel = 0
float zSig = 2.39   // two-sided 0.05 corrected for 3 classes
atr = ta.atr(atrLen)

if showCal and barConfirmed and not na(atr) and atr > 0.0
    if (fadeLong or fadeShort) and (bar_index - lastFadeBar) >= calMinGap
        lastFadeBar := bar_index
        float uw = useUniq ? 1.0/(1.0+pend.size()) : 1.0
        pend.push(Ev.new(fadeLong?1:-1, 1, regId, close, atr, bar_index, 0.0, 0.0, uw, false))
    if (rideLong or rideShort) and (bar_index - lastRideBar) >= calMinGap
        lastRideBar := bar_index
        float uw = useUniq ? 1.0/(1.0+pend.size()) : 1.0
        pend.push(Ev.new(rideLong?1:-1, 2, regId, close, atr, bar_index, 0.0, 0.0, uw, false))
    if sqzFire and (bar_index - lastSqzBar) >= calMinGap
        lastSqzBar := bar_index
        float uw = useUniq ? 1.0/(1.0+pend.size()) : 1.0
        pend.push(Ev.new(fireDir, 3, regId, close, atr, bar_index, 0.0, 0.0, uw, false))

// per-class realised edge (from prior resolved samples) — feeds conviction
f_hitW(int cls) =>
    float n = clsNsum.get(cls)
    n > 0.0 ? clsWsum.get(cls) / n : na
float fadeEdge = clsN.get(1) >= calMinSamp ? f_clamp((nz(f_hitW(1), 0.0)) - clsBase.get(1)/clsN.get(1), -0.5, 0.5) : 0.0
float rideEdge = clsN.get(2) >= calMinSamp ? f_clamp((nz(f_hitW(2), 0.0)) - clsBase.get(2)/clsN.get(2), -0.5, 0.5) : 0.0

// =============================================================================
// CON — DUAL CONVICTION (Fade vs Ride) + hard vetoes
// =============================================================================
longSig  = fadeLong  or rideLong
shortSig = fadeShort or rideShort
if longSig and shortSig
    shortSig := false
dir = longSig ? 1 : shortSig ? -1 : 0
isFadeSig = fadeLong or fadeShort
isRideSig = rideLong or rideShort

sStretch = isFadeSig ? f_clamp(math.abs(bandZ)/k3, 0, 1) : f_clamp(math.max(walkUp, walkDn)/(walkBars*2.0), 0, 1)
sReg = isFadeSig ? (isRange ? 1.0 : 0.3) * (meanRev or not useVarRatio ? 1.0 : 0.75) : (isTrend ? 1.0 : 0.3) * ((not meanRev) or not useVarRatio ? 1.0 : 0.75)
mtfAgree = dir>0 ? mtfBull : dir<0 ? mtfBear : 0
mtfBalance = 1.0 - math.abs(mtfBull - mtfBear)/4.0
sMtf = isFadeSig ? mtfBalance : (useMtf ? mtfAgree/4.0 : 0.5)
sHalf = isFadeSig ? (na(halfLife) ? 0.2 : f_clamp(1.0 - halfLife/(hlLen*0.5), 0, 1)) : (na(halfLife) ? 1.0 : 0.4)
// calibrated edge term: forward-tested edge of THIS mode (replaces raw rev-prob)
sCal = isFadeSig ? f_clamp(0.5 + fadeEdge, 0, 1) : isRideSig ? f_clamp(0.5 + rideEdge, 0, 1) : 0.5
sVol = volThrust ? 1.0 : 0.4
sCvd = (cvdSign == dir and dir != 0) ? 1.0 : 0.4

wSum = wBand+wReg+wMtf+wHalf+wCal+wVol+wCvd
rawConv = wBand*sStretch + wReg*sReg + wMtf*sMtf + wHalf*sHalf + wCal*sCal + wVol*sVol + wCvd*sCvd
conv = dir==0 ? 0 : math.round(f_clamp(wSum>0 ? rawConv/wSum*100.0 : 0, 0, 100))
tier = conv>=75?"S" : conv>=60?"A" : conv>=45?"B" : "-"

vVix = vixSpike and isFadeSig
vMtf = useMtf and dir!=0 and isRideSig and ((dir>0 and mtfBull<minAlign) or (dir<0 and mtfBear<minAlign))
vHtf = useHtfGate and isRideSig and ((dir>0 and htfSign<0) or (dir<0 and htfSign>0))
vXa  = xaLive and dir!=0 and isRideSig and xaMom!=0 and math.sign(xaMom)!=dir
vetoes = vVix or vMtf or vHtf or vXa
vetoTxt = vVix?"VIX spike" : vMtf?"MTF weak" : vHtf?"HTF gate" : vXa?"cross-asset" : "none"

act = dir!=0 and conv>=minConv and not vetoes
verdict = not act ? (dir!=0 and vetoes ? "VETO" : "FLAT") : dir>0 ? "LONG" : "SHORT"
longTrig  = act and dir>0
shortTrig = act and dir<0
sigModeTxt = isFadeSig ? "Fade" : isRideSig ? "Ride" : "—"

// reliability fire (push conviction prediction when a directional signal exists)
if useReliability and showCal and barConfirmed and dir != 0 and not na(atr) and atr > 0.0
    relQ.push(Rel.new(conv/100.0, dir, close, atr, bar_index))

// =============================================================================
// CALIBRATION RESOLVE (triple-barrier · base · reliability)
// =============================================================================
if showCal and barstate.isconfirmed and pend.size() > 0
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
                int rgb = p.reg >= 0 and p.reg <= 2 ? p.reg : 0
                float bp = baseN.get(rgb) > 0 ? (p.dir > 0 ? baseUp.get(rgb) / float(baseN.get(rgb)) : baseDn.get(rgb) / float(baseN.get(rgb))) : 0.5
                clsBase.set(c, clsBase.get(c) + bp)
                pend.remove(i)

if showCal and barstate.isconfirmed and not na(atr) and atr > 0.0
    bq.push(Base.new(close, atr, bar_index, regId))
if showCal and barstate.isconfirmed and bq.size() > 0
    for i = bq.size() - 1 to 0
        Base b = bq.get(i)
        if bar_index - b.bidx >= calHorizon
            int rgb = b.reg >= 0 and b.reg <= 2 ? b.reg : 0
            if (close - b.entry) >= calMoveATR * b.atr0
                baseUp.set(rgb, baseUp.get(rgb) + 1)
            if (b.entry - close) >= calMoveATR * b.atr0
                baseDn.set(rgb, baseDn.get(rgb) + 1)
            baseN.set(rgb, baseN.get(rgb) + 1)
            bq.remove(i)

if useReliability and barstate.isconfirmed and relQ.size() > 0
    for i = relQ.size() - 1 to 0
        Rel rp = relQ.get(i)
        if bar_index - rp.bidx >= calHorizon
            float real = (rp.dir > 0 ? (close - rp.entry) : (rp.entry - close)) >= calMoveATR * rp.atr0 ? 1.0 : 0.0
            sumRelP += rp.pred
            sumRelR += real
            sumRelB += (rp.pred - real) * (rp.pred - real)
            nRel += 1
            relQ.remove(i)

float brier  = nRel > 0 ? sumRelB / nRel : na
float relGap = nRel > 0 ? (sumRelP - sumRelR) / nRel : na

// =============================================================================
// RISK — TRADE FRAMEWORK (sizing suggestion + dashboard levels; no chart overlay)
// =============================================================================
var int posDir = 0
var float entryPx = na
var float stopPx = na
var float t1 = na
var float t2 = na
if longTrig and posDir==0
    posDir := 1
    entryPx := close
    stopPx := stopMode=="Outer band" ? (lower3 - atr*stopMult) : stopMode=="ATR" ? (close - atr*(1.0+stopMult)) : (close - (na(halfLife)?atr*2.0:revPts) - atr*stopMult)
    rL = math.abs(close - stopPx)
    t1 := isFadeSig ? basis  : close + rL*1.5
    t2 := isFadeSig ? upper1 : close + rL*3.0
if shortTrig and posDir==0
    posDir := -1
    entryPx := close
    stopPx := stopMode=="Outer band" ? (upper3 + atr*stopMult) : stopMode=="ATR" ? (close + atr*(1.0+stopMult)) : (close + (na(halfLife)?atr*2.0:revPts) + atr*stopMult)
    rS = math.abs(close - stopPx)
    t1 := isFadeSig ? basis  : close - rS*1.5
    t2 := isFadeSig ? lower1 : close - rS*3.0
if posDir==1
    if low<=stopPx or high>=t2
        posDir := 0
    else if high>=t1 and stopPx<entryPx
        stopPx := entryPx
if posDir==-1
    if high>=stopPx or low<=t2
        posDir := 0
    else if low<=t1 and stopPx>entryPx
        stopPx := entryPx
inTrade = posDir != 0
stopDist = math.abs(nz(entryPx) - nz(stopPx))
riskCap = equity * riskPct / 100.0
perUnit = stopDist * ptValue
qty = perUnit > 0 ? math.floor(riskCap / perUnit) : 0
mt = str.tostring(close, format.mintick)
ms = str.tostring(nz(stopPx, 0.0), format.mintick)

// =============================================================================
// VIS — LOWER PANE (%B or band-z analytics)
// =============================================================================
paneVal = paneMode=="%B" ? pctB : bandZ
midRef = paneMode=="%B" ? 0.5 : 0.0
hiRef  = paneMode=="%B" ? 1.0 : k2
loRef  = paneMode=="%B" ? 0.0 : 0.0 - k2
plot(paneVal, "Pane", color=paneVal>=midRef?color.new(color.teal,0):color.new(color.red,0), linewidth=2)
plot(midRef, "mid", color=color.new(color.gray,55))
plot(hiRef,  "upper ref", color=color.new(color.gray,72))
plot(loRef,  "lower ref", color=color.new(color.gray,72))
plotshape(sqzOn,                 "Squeeze",   shape.circle,       location.bottom, color.new(color.yellow,0), size=size.tiny)
plotshape(sqzFire and fireDir>0, "Fire up",   shape.triangleup,   location.top,    color.new(color.teal,0),   size=size.tiny)
plotshape(sqzFire and fireDir<0, "Fire down", shape.triangledown, location.top,    color.new(color.red,0),    size=size.tiny)
plotshape(bullDiv,               "Bull div",  shape.circle,       location.bottom, color.new(color.lime,0),   size=size.tiny)
plotshape(bearDiv,               "Bear div",  shape.circle,       location.top,    color.new(color.fuchsia,0),size=size.tiny)

// =============================================================================
// VIS — PRICE OVERLAY (bands, reversion-heat fill, HTF rails, signals)
// =============================================================================
color basisCol = modeTint ? (isRange ? color.new(color.gray, 0) : isTrend ? (bull ? color.new(color.teal,0) : color.new(color.red,0)) : color.new(color.orange,0)) : color.new(src_in >= basis ? color.green : color.red, 0)
pU3 = plot(showBands and showInner ? upper3 : na, "Upper 3x", color=color.new(color.teal,45), force_overlay=true)
pU2 = plot(showBands ? upper2 : na, "Upper", color=color.new(color.teal,8), force_overlay=true)
pU1 = plot(showBands and showInner ? upper1 : na, "Upper 1x", color=color.new(color.teal,55), force_overlay=true)
pBs = plot(showBands ? basis : na, "Basis", color=basisCol, linewidth=2, force_overlay=true)
pL1 = plot(showBands and showInner ? lower1 : na, "Lower 1x", color=color.new(color.red,55), force_overlay=true)
pL2 = plot(showBands ? lower2 : na, "Lower", color=color.new(color.red,8), force_overlay=true)
pL3 = plot(showBands and showInner ? lower3 : na, "Lower 3x", color=color.new(color.red,45), force_overlay=true)
fill(pU2, pU3, color=showFill ? color.new(color.red,   65) : na)
fill(pL2, pL3, color=showFill ? color.new(color.green, 65) : na)
plot(showHtfRails ? htfU : na, "HTF upper rail", color=color.new(color.orange,18), style=plot.style_stepline, force_overlay=true)
plot(showHtfRails ? htfL : na, "HTF lower rail", color=color.new(color.orange,18), style=plot.style_stepline, force_overlay=true)
plotshape(showSignals and fadeLong,  "Fade long",  shape.triangleup,   location.belowbar, color.new(color.lime,0),   size=size.small, force_overlay=true)
plotshape(showSignals and fadeShort, "Fade short", shape.triangledown, location.abovebar, color.new(color.red,0),    size=size.small, force_overlay=true)
plotshape(showSignals and rideLong,  "Ride long",  shape.diamond,      location.belowbar, color.new(color.teal,0),   size=size.tiny,  force_overlay=true)
plotshape(showSignals and rideShort, "Ride short", shape.diamond,      location.abovebar, color.new(color.maroon,0), size=size.tiny,  force_overlay=true)

// Divergence as lines on PRICE
var array<line>  divPx = array.new<line>()
var array<label> divLb = array.new<label>()
if tradeOverlay and bearDiv and not na(ppHx)
    array.push(divPx, line.new(ppHx, ppHp, lpHx, lpHp, xloc.bar_index, color=color.new(color.fuchsia,0), width=2, force_overlay=true))
    array.push(divLb, label.new(lpHx, lpHp, "Bear div", style=label.style_label_down, color=color.new(color.fuchsia,12), textcolor=color.white, size=size.tiny, force_overlay=true))
if tradeOverlay and bullDiv and not na(ppLx)
    array.push(divPx, line.new(ppLx, ppLp, lpLx, lpLp, xloc.bar_index, color=color.new(color.lime,0), width=2, force_overlay=true))
    array.push(divLb, label.new(lpLx, lpLp, "Bull div", style=label.style_label_up, color=color.new(color.lime,12), textcolor=color.black, size=size.tiny, force_overlay=true))
while array.size(divPx) > divKeep
    line.delete(array.shift(divPx))
    label.delete(array.shift(divLb))

// =============================================================================
// VIS — DASHBOARD (adaptive light/dark · KEY block + calibration)
// =============================================================================
var table dash = table.new(f_pos(tblPos), 2, 40, frame_width=1, border_width=1, force_overlay=true)
setrow(tbl, r, lbl, val, vc, lc, bg) =>
    table.cell(tbl, 0, r, lbl, text_color=lc, text_size=size.tiny,  text_halign=text.align_left,  bgcolor=bg)
    table.cell(tbl, 1, r, val, text_color=vc, text_size=size.small, text_halign=text.align_right, bgcolor=bg)

if showTbl and barstate.islast
    tIsDark = tblTheme=="Dark" ? true : tblTheme=="Light" ? false : f_luma(chart.bg_color) < 140
    tBg   = tIsDark ? color.new(#0b0f17, 6) : color.new(#ffffff, 4)
    tBord = tIsDark ? color.new(#3a4250, 0) : color.new(#c2c8d0, 0)
    tLbl  = tIsDark ? #9aa3b2 : #515a67
    tVal  = tIsDark ? #f2f4f8 : #10151d
    cBull = tIsDark ? #2dd4bf : #0e9e76
    cBear = tIsDark ? #ff6b6b : #d32f2f
    cWarn = tIsDark ? #ffa94d : #b56a00
    cInfo = tIsDark ? #ffd43b : #9a7400
    cMute = tIsDark ? #6b7480 : #98a0ab
    table.set_frame_color(dash, tBord)
    table.set_border_color(dash, tBord)
    verdColor = verdict=="LONG"?cBull : verdict=="SHORT"?cBear : verdict=="VETO"?cWarn : cMute
    regColT   = regime=="Trend Bull"?cBull : regime=="Trend Bear"?cBear : regime=="Volatile"?cWarn : cMute
    actCol    = longTrig?color.new(cBull,0) : shortTrig?color.new(cBear,0) : posDir==1?color.new(cBull,15) : posDir==-1?color.new(cBear,15) : verdict=="VETO"?color.new(cWarn,0) : color.new(#5b6472,0)
    stretchCol= math.abs(bandZ)>=k3?cWarn : math.abs(bandZ)>=k2?cInfo : tVal
    actShort  = longTrig?"BUY" : shortTrig?"SELL" : posDir==1?"HOLD L" : posDir==-1?"HOLD S" : verdict=="VETO"?"WAIT" : "FLAT"
    actDetail = (longTrig or shortTrig) ? (sigModeTxt+" · conv "+str.tostring(conv)+" "+tier) : inTrade ? ("holding "+(posDir>0?"long":"short")) : verdict=="VETO" ? vetoTxt : "no edge"
    stretchTxt= sgn(bandZ)+str.tostring(bandZ,"0.00")+"z  %B "+str.tostring(pctB,"0.00")
    bwTxt     = str.tostring(bandwidth*100,"0.00")+"% p"+str.tostring(math.round(bwRank))+(sqzOn?" SQZ":sqzFire?(fireDir>0?" FIRE^":" FIREv"):"")
    hlTxt     = na(halfLife)?"trending":str.tostring(math.round(halfLife))+"b"
    containTxt= (na(containPct)?"-":str.tostring(math.round(containPct))+"%")+" / "+str.tostring(math.round(qCont))+"% · "+containVerdict+" k"+str.tostring(kAdapt,"0.00")
    modeTxt   = sigModeTxt + (walking?(" walk "+str.tostring(math.max(walkUp,walkDn))):"") + (useVarRatio and not na(varRatio)?(meanRev?" · MR":" · TR"):"")
    biasTxt   = (useMtf?("MTF "+str.tostring(dir>0?mtfBull:dir<0?mtfBear:math.max(mtfBull,mtfBear))+"/4"):"off")+"  HTF"+(htfSign>0?"^":htfSign<0?"v":"-")
    skewTxt   = "sk"+sgn(bSkew)+str.tostring(bSkew,"0.0")+" ku"+str.tostring(bKurt,"0.0")+(tailF>1.001?(" x"+str.tostring(tailF,"0.00")):"")
    // header / KEY block
    table.cell(dash, 0, 0, " > "+actShort+" ", text_color=color.white, text_size=size.small, text_halign=text.align_left,  bgcolor=actCol)
    table.cell(dash, 1, 0, actDetail+" ",      text_color=color.white, text_size=size.small, text_halign=text.align_right, bgcolor=actCol)
    setrow(dash, 1,  "VERDICT",   verdict+" · "+str.tostring(conv)+" ("+tier+")", verdColor, tLbl, tBg)
    setrow(dash, 2,  "MODE",      modeTxt, isFadeSig?cInfo:isRideSig?cBull:cMute, tLbl, tBg)
    setrow(dash, 3,  "REGIME",    regime+" "+str.tostring(regimePct)+"% "+phase, regColT, tLbl, tBg)
    setrow(dash, 4,  "STRETCH",   stretchTxt, stretchCol, tLbl, tBg)
    setrow(dash, 5,  "CONTAINMENT", containTxt, na(containPct)?cMute:containVerdict=="calibrated"?cBull:cWarn, tLbl, tBg)
    if compactTbl
        setrow(dash, 6,  "EDGE F/R",  (clsN.get(1)>=calMinSamp?(sgn(fadeEdge*100)+str.tostring(fadeEdge*100,"0")):"-")+" / "+(clsN.get(2)>=calMinSamp?(sgn(rideEdge*100)+str.tostring(rideEdge*100,"0")):"-"), tVal, tLbl, tBg)
        setrow(dash, 7,  "HALF-LIFE", hlTxt, na(halfLife)?cMute:cBull, tLbl, tBg)
        setrow(dash, 8,  "BANDWIDTH", bwTxt, sqzOn?cInfo:sqzFire?cBull:tVal, tLbl, tBg)
        setrow(dash, 9,  "BIAS",      biasTxt, ((dir>0 and mtfBull>=minAlign) or (dir<0 and mtfBear>=minAlign))?cBull:cMute, tLbl, tBg)
        setrow(dash, 10, "VETO",      vetoTxt, vetoTxt=="none"?cMute:cWarn, tLbl, tBg)
        setrow(dash, 11, "SIZE",      str.tostring(qty)+" units ("+str.tostring(riskPct,"0.0")+"%)", tVal, tLbl, tBg)
    else
        setrow(dash, 6,  "BASIS",    basisType+" "+str.tostring(lenUse)+(useAdaptLen?(" cyc"+str.tostring(math.round(domCycle))):""), tVal, tLbl, tBg)
        setrow(dash, 7,  "ENGINE",   devEngine, tVal, tLbl, tBg)
        setrow(dash, 8,  "BANDWIDTH",bwTxt, sqzOn?cInfo:sqzFire?cBull:tVal, tLbl, tBg)
        setrow(dash, 9,  "HALF-LIFE",hlTxt, na(halfLife)?cMute:cBull, tLbl, tBg)
        setrow(dash, 10, "BAND-WALK","U"+str.tostring(walkUp)+" D"+str.tostring(walkDn), walking?cBull:cMute, tLbl, tBg)
        setrow(dash, 11, "VAR-RATIO", na(varRatio)?"-":str.tostring(varRatio,"0.00")+(meanRev?" MR":" TR"), na(varRatio)?cMute:meanRev?cBull:cWarn, tLbl, tBg)
        setrow(dash, 12, "SKEW/KURT",skewTxt, tVal, tLbl, tBg)
        setrow(dash, 13, "DIVERG",   divDir==0?"none":(divDir>0?"bull":"bear"), divDir>0?cBull:divDir<0?cBear:cMute, tLbl, tBg)
        setrow(dash, 14, "MTF / HTF",(useMtf?(str.tostring(mtfBull)+"/"+str.tostring(mtfBear)):"off")+"  "+(htfSign>0?"^":htfSign<0?"v":"-"), useMtf?tVal:cMute, tLbl, tBg)
        setrow(dash, 15, "FLOW",     cvdSign>0?"up":cvdSign<0?"dn":"flat", cvdSign>0?cBull:cvdSign<0?cBear:cMute, tLbl, tBg)
        setrow(dash, 16, "VIX",      vixLive?("z"+sgn(vixZ)+str.tostring(vixZ,"0.0")+(vixSpike?" !":"")):"n/a", vixSpike?cWarn:vixLive?tVal:cMute, tLbl, tBg)
        setrow(dash, 17, "— CALIBRATION (regime-matched) —", "n·Hit%±ci·base·edge", cMute, cMute, tBg)
        rgRevTxt = "Range rev up "+(na(pUpRev)?"-":str.tostring(math.round(pUpRev))+"%")+" dn "+(na(pDnRev)?"-":str.tostring(math.round(pDnRev))+"%")
        setrow(dash, 18, "REV (range)", rgRevTxt, showCal?tVal:cMute, tLbl, tBg)
        for c = 1 to NCLS
            int n = clsN.get(c)
            int rr = 18 + c
            if n < calMinSamp
                setrow(dash, rr, f_clsName(c), "n"+str.tostring(n)+" warming", cMute, tLbl, tBg)
            else
                float h  = nz(f_hitW(c), 0.0)
                float wh = f_wilson(clsWsum.get(c), clsNsum.get(c), 1.96)
                float whS= f_wilson(clsWsum.get(c), clsNsum.get(c), zSig)
                float bp = clsBase.get(c)/n
                float ed = h - bp
                bool star = not na(whS) and (h - whS) > bp
                col_ = ed>0?cBull:cBear
                s = "n"+str.tostring(n)+" "+str.tostring(h*100,"0")+(na(wh)?"":"±"+str.tostring(wh*100,"0"))+" b"+str.tostring(bp*100,"0")+" "+(ed>=0?"+":"")+str.tostring(ed*100,"0")+(star?"*":"")
                setrow(dash, rr, f_clsName(c), s, col_, tLbl, tBg)
        setrow(dash, 22, "RELIABILITY", na(brier)?"warming":"Brier "+str.tostring(brier,"0.00")+" gap "+(relGap>=0?"+":"")+str.tostring(relGap*100,"0")+"%", na(brier)?cMute:tVal, tLbl, tBg)
        setrow(dash, 23, "CONVICTION", str.tostring(conv)+" / 100 ("+tier+")", conv>=60?cBull:conv>=45?cInfo:cMute, tLbl, tBg)
        setrow(dash, 24, "VETO",     vetoTxt, vetoTxt=="none"?cMute:cWarn, tLbl, tBg)
        setrow(dash, 25, "SIZE",     str.tostring(qty)+" units ("+str.tostring(riskPct,"0.0")+"%)", tVal, tLbl, tBg)
        if showLegend
            setrow(dash, 26, "— LEGEND —", "", cMute, cMute, tBg)
            setrow(dash, 27, "FADE",      "fade a band touch in a range", cMute, tLbl, tBg)
            setrow(dash, 28, "RIDE",      "ride a trend walking the band", cMute, tLbl, tBg)
            setrow(dash, 29, "CONTAIN",   "realised vs target % · k = multiplier", cMute, tLbl, tBg)
            setrow(dash, 30, "VAR-RATIO", "MR = mean-reverting · TR = trending", cMute, tLbl, tBg)
            setrow(dash, 31, "EDGE",      "forward Hit% minus base · * = significant", cMute, tLbl, tBg)
            setrow(dash, 32, "RELIAB.",   "Brier + calibration gap of conviction", cMute, tLbl, tBg)

// =============================================================================
// IDENTITY — script name + symbol + timeframe
// =============================================================================
var table idTbl = table.new(position.bottom_center, 1, 1, force_overlay=true)
if showId and barstate.islast
    table.cell(idTbl, 0, 0, "Adaptive Bands   ·   " + syminfo.ticker + "  " + timeframe.period, text_color=color.new(#8a929e, 20), text_size=size.small, text_halign=text.align_center, bgcolor=color.new(color.gray, 100))

// =============================================================================
// ALERTS
// =============================================================================
if longTrig
    alert("Adaptive Bands " + sigModeTxt + " LONG " + syminfo.ticker + " @ " + mt + "  SL " + ms + "  T " + str.tostring(t2, format.mintick) + "  | conv " + str.tostring(conv) + " (" + tier + ")", alert.freq_once_per_bar_close)
if shortTrig
    alert("Adaptive Bands " + sigModeTxt + " SHORT " + syminfo.ticker + " @ " + mt + "  SL " + ms + "  T " + str.tostring(t2, format.mintick) + "  | conv " + str.tostring(conv) + " (" + tier + ")", alert.freq_once_per_bar_close)
alertcondition(sqzFire, "Squeeze Fire", "Adaptive Bands: squeeze expansion on {{ticker}} {{interval}}")
alertcondition(longTrig,  "Long",  "Adaptive Bands long verdict")
alertcondition(shortTrig, "Short", "Adaptive Bands short verdict")

// =============================================================================
// EXP_* EXPORTS (Data Window · generic names)
// =============================================================================
int exBias = dir != 0 ? int(math.round(dir * conv)) : 0
color exC = color.new(color.gray, 100)
plot(showEXP ? pctB              : na, "EXP_PctB",          color=exC, display=display.data_window)
plot(showEXP ? bandZ             : na, "EXP_BandZ",         color=exC, display=display.data_window)
plot(showEXP ? basis             : na, "EXP_Basis",         color=exC, display=display.data_window)
plot(showEXP ? upper2            : na, "EXP_UpperMain",     color=exC, display=display.data_window)
plot(showEXP ? lower2            : na, "EXP_LowerMain",     color=exC, display=display.data_window)
plot(showEXP ? bandwidth*100     : na, "EXP_Bandwidth",     color=exC, display=display.data_window)
plot(showEXP ? bwRank            : na, "EXP_BWPercentile",  color=exC, display=display.data_window)
plot(showEXP ? regId             : na, "EXP_Regime",        color=exC, display=display.data_window)
plot(showEXP ? halfLife          : na, "EXP_HalfLife",      color=exC, display=display.data_window)
plot(showEXP ? containPct        : na, "EXP_Containment",   color=exC, display=display.data_window)
plot(showEXP ? varRatio          : na, "EXP_VarRatio",      color=exC, display=display.data_window)
plot(showEXP ? (clsN.get(1)>=calMinSamp ? fadeEdge*100 : na) : na, "EXP_FadeEdge", color=exC, display=display.data_window)
plot(showEXP ? (clsN.get(2)>=calMinSamp ? rideEdge*100 : na) : na, "EXP_RideEdge", color=exC, display=display.data_window)
plot(showEXP ? conv              : na, "EXP_Conviction",    color=exC, display=display.data_window)
plot(showEXP ? dir               : na, "EXP_Dir",           color=exC, display=display.data_window)
plot(showEXP ? exBias            : na, "EXP_Bias",          color=exC, display=display.data_window)
plot(showEXP ? (sqzOn?1:sqzFire?2:0) : na, "EXP_Squeeze",   color=exC, display=display.data_window)
plot(showEXP ? divDir            : na, "EXP_Divergence",    color=exC, display=display.data_window)
plot(showEXP ? nz(brier,-1)      : na, "EXP_Brier",         color=exC, display=display.data_window)
````
