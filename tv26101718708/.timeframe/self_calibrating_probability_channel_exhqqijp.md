# Self Calibrating Probability Channel

- url: https://www.tradingview.com/script/eXHqQiJp-Self-Calibrating-Probability-Channel/
- type: indicator
- pine_id: PUB;94e71f5c4d4a4482980bcef361465b7a
- version: 1.0

## Description

SELF-CALIBRATING PROBABILITY CHANNEL

A forecast channel whose width is set by conformal prediction, tuned by a parameter-free online calibrator, and proven on your own chart. You pick a coverage level - say 90% - and the indicator shows you, live, the percentage it has actually achieved over recent bars, on every timeframe. Most bands assert a width; this one measures whether the width was right and corrects itself until it is, with nothing to tune.


WHAT IT IS

Bollinger Bands, Keltner Channels, Donchian Channels and standard-deviation regression channels all draw a width from a formula and ask you to trust it. None of them tell you what fraction of price actually landed inside. A "2 standard deviation" band is only a true 95% band if returns are normally distributed and stationary - which markets are not - so the real hit-rate drifts, usually without the user ever knowing.

This indicator inverts that. It forecasts where price should be next bar, measures how wrong that forecast has actually been, and builds the band directly from the empirical distribution of those errors. Then it watches its own hit-rate bar by bar and self-corrects. The result is a channel that earns its stated confidence level instead of assuming it - and reports, honestly, where it is and isn't holding.


THE METHOD (plain language)

1. Forecast path. Each bar, a one-step-ahead forecast of price is formed. You can pick a Kalman level-and-velocity tracker, a linear-regression slope, an EMA projection, or an anchored VWAP - or leave it on Auto, which runs all of them and blends them online by recent accuracy, so the centre line self-calibrates too. The forecast for the current bar uses only prior bars, so it is genuinely out-of-sample.

2. Error window. The gap between forecast and outcome is the forecast error. A rolling window of recent errors is kept, stored in volatility (ATR) units so the band breathes with the market. Each error is recorded only after its band has already been scored, so the band never includes the bar it is being tested on.

3. Conformal bands. For a chosen confidence level, the band edges sit at the matching quantiles of the recent error distribution (split-conformal prediction). Because it uses the actual error quantiles - including their skew - the bands are asymmetric when the errors are, rather than forcing a symmetric width. Four levels are drawn at once (50 / 70 / 90 / 95%) as nested zones, so the channel doubles as a probability heatmap: the dark core is where price spends most of its time, the faint outer edge marks rare excursions.

4. Parameter-free self-calibration (DtACI). After each bar the indicator checks whether price fell inside each level and nudges the width to hold the target. Rather than asking you to pick a calibration speed, it runs several speeds as competing "experts" and continuously blends them by how well each has tracked coverage recently (Dynamically-tuned Adaptive Conformal Inference). There is no rate to tune - the calibration tunes itself.

5. Live coverage proof, including by regime. The dashboard shows, for every level, the target versus the actually-achieved coverage over a rolling window, each tagged calibrated / under / over. It also reports the realised 90% coverage broken down by market regime - so you can see, for instance, that the band holds 92% in a quiet range but 87% in a volatile breakout. You are not asked to trust the band; you are shown its track record on the symbol, timeframe and regime in front of you.

6. Forward cone. A widening cone projects the likely range several bars ahead. Its width is built from actual multi-step forecast errors (not a square-root-of-time assumption), and its centre curves as projected momentum decays rather than extrapolating in a straight line. An optional bootstrap cloud resamples the real errors into sample forward paths - a direct picture of the distribution the bands come from.

7. Context and early warning. A two-axis regime read (trend strength x volatility) labels conditions; a turbulence detector watches for clustering of outer-band breaches and flags, in advance, when coverage is likely to degrade; a coiled-spring marker notes when a compressed range begins to expand; and an optional higher-timeframe row shows whether the larger trend agrees.


WHY THESE PARTS BELONG TOGETHER (one engine, not a bundle)

This is a single forecasting loop, not a collection of separate indicators sharing a chart. Each part is a required step, and removing any one breaks the whole:

- The forecast path produces an expected price and a drift. Without it there is no quantity whose error can be measured.
- The conformal band converts that path's own recent errors into prediction intervals. Without the forecast there is no error to bound; without the band the forecast is an unqualified guess.
- The online self-calibration adjusts the band to hold the target hit-rate as conditions change. Without it the intervals slowly drift out of calibration and the stated confidence becomes false.
- The live coverage readout verifies the loop is actually working, overall and per regime. It is the proof step a formula-based band cannot offer.
- The context layers (regime, turbulence early-warning, graded breaches, compression-release, higher-timeframe agreement) all read the same forecast errors and exist only to tell you WHEN the interval is most trustworthy and when it is about to fail.

So the components are not combined for convenience; they form a closed measure-and-correct cycle - forecast, bound the error, recalibrate, verify - which is precisely why they are published as one script rather than several overlays.


WHAT MAKES IT DIFFERENT

Conformal prediction is a distribution-free framework - its coverage guarantee holds for any underlying distribution given exchangeable errors, with no assumption that returns are Gaussian. It is standard in machine-learning uncertainty quantification but essentially absent from charting tools, which lean almost entirely on standard-deviation or ATR multiples. Pairing it with a parameter-free online recalibrator, a self-weighting forecast centre, and an on-chart coverage readout - including a per-regime breakdown - is the original contribution here. No moving-average envelope, regression channel or volatility band can state "I targeted 90% and have actually delivered 90% over the last 250 bars, and here is exactly where I don't" - this one can, and shows it.


WHAT YOU SEE ON THE CHART

- A multi-zone channel around a forecast centre line, shaded from the high-probability core out to the rare-excursion edge, coloured by forecast direction, and adaptive to dark or light chart backgrounds.
- A widening forward cone, optionally filled with a faint cloud of resampled paths.
- Right-side labels marking the forecast and the 90 / 95% edges as price levels.
- Small triangles when price breaks beyond the outer band; a ring when that breach is also high-quality (graded on displacement, close position, volume, range expansion and structure); an amber diamond when a quiet range starts to wake up.
- A dashboard with the live forecast, the 90% band range and where price sits within it, the full calibration table, the per-regime coverage, a reliability score, the forecast bias, the sample count, the calibration mode, and an optional higher-timeframe row.
- A plain-language "how to read" key, so the chart is approachable without any statistics background.


HOW TO READ AND USE IT

Mean reversion: when price reaches the outer (90 / 95%) zone in a ranging regime, it is statistically stretched and tends to revert toward the centre line. The "band position" readout and the calibration table tell you how stretched, and how trustworthy that edge currently is.

Trend continuation: a sustained walk along one side of the channel, especially with the cone tilted that way and the higher-timeframe row aligned, indicates a directional regime rather than noise.

Anomaly / breakout: a plain triangle is a volatility event; a ringed one is the same event confirmed as high-quality. A turbulence flag warns that the bands may be about to lose calibration.

Reliability and regime: treat the bands as most actionable when reliability is high, the calibration rows read "calibrated", and turbulence is quiet. The per-regime coverage tells you which conditions the channel is currently most trustworthy in.


SETTINGS OVERVIEW

- Forecast path (Auto / Kalman / Linear Regression / EMA / Anchored VWAP) and smoothing lengths.
- Calibration: residual window, recency window, volatility normalisation, parameter-free DtACI on/off (with a manual ACI rate as fallback), coverage-evaluation window.
- Forward projection length, cone momentum decay, optional bootstrap cloud.
- Anomaly sensitivity, swing pivot length, coiled-spring thresholds, turbulence sensitivity.
- Higher-timeframe context, price source, and full theme controls.

The price source is selectable and volume is borrowed where a symbol reports none, so it works across futures, equities, forex and crypto on any timeframe. Defaults read well intraday; longer windows suit higher timeframes.


HONESTY AND LIMITATIONS

- Non-repainting: each bar's forecast uses only prior bars, each error is recorded only after its band is scored, anomalies confirm on bar close, and the higher-timeframe row uses the last confirmed higher-timeframe value. Historical bands do not change after the fact.
- Conformal coverage is a statistical expectation over a window, not a per-bar guarantee. In a sharp regime break the realised hit-rate will dip until the window and calibrator re-adapt - and the dashboard, including its per-regime breakdown, shows that dip honestly rather than hiding it.
- The bands describe the distribution of short-horizon forecast error. They are a probabilistic context for price, not a prediction of direction and not a trading system.
- Calibration needs enough samples; on a fresh chart the channel needs its warm-up window before the figures are meaningful, and the cone needs a few extra bars beyond that.

This script is for research and education. It is not financial advice and not a solicitation to trade. Markets carry risk; test any tool on your own data and timeframe, and make your own decisions.

## Source Code

````pine
// =============================================================================
//  SELF-CALIBRATING PROBABILITY CHANNEL                               Pine v6
//  shorttitle: ConfChan
// -----------------------------------------------------------------------------
//  WHAT THIS IS
//    A forecasting channel whose width is set by CONFORMAL PREDICTION rather than
//    a fixed multiple of standard deviation. A transparent forecast path predicts
//    where the chosen price source is heading; the band around it is sized from the
//    recent forecast ERRORS so that a chosen fraction of bars (50/70/90/95%) actually
//    land inside — and the script displays the REALISED coverage live, including a
//    per-regime breakdown, so you can see whether it is working. A parameter-free
//    online calibrator holds the target coverage as the market changes. The method
//    is distribution-free (no Gaussian assumption), honest, and self-correcting.
//
//  WHY THESE COMPONENTS ARE COMBINED  (mashup rationale)
//    These are not independent indicators stacked together; each answers one step a
//    single, measurable forecasting engine requires, and removing any one breaks it:
//      * FORECAST PATH (EMA / linear regression / level-and-velocity tracker /
//        anchored VWAP, or AUTO which blends them online by recent accuracy) gives an
//        expected price path and a drift — the thing the interval is built around.
//      * CONFORMAL BANDS turn that path's own recent errors into prediction intervals
//        at several confidence levels — the band is exactly as wide as the data's past
//        mistakes demand, with no distributional assumption. Without a forecast there
//        is no error to bound; without the error bound the forecast is just a guess.
//      * ONLINE SELF-CALIBRATION (adaptive conformal inference, run parameter-free by
//        blending several adaptation speeds) widens an under-covering band and tightens
//        an over-covering one so coverage holds through regime shifts. Without it the
//        bands drift out of calibration; this is what earns "self-calibrating".
//      * LIVE COVERAGE READOUT, overall and per regime, is the proof the calibration is
//        working — the verification step a fixed-width band cannot provide.
//      * CONTEXT LAYERS (two-axis regime, breach-clustering early warning, graded
//        outer-band breaches, compression-release marker, optional higher-timeframe
//        agreement) qualify WHEN the interval is most trustworthy and flag when it is
//        about to lose calibration. They read the same forecast errors, not a separate
//        signal source.
//    Forecast, error-bound, self-calibration and verification are one closed loop —
//    that is why they belong in one script, not four.
//
//  HOW TO USE IT  (plain language)
//    1. The centre line is the forecast path; the nested bands are the 50/70/90/95%
//       prediction intervals (darker = more likely). An on-chart key explains every mark.
//    2. Price near/through an outer band is statistically extended; a breach (triangle)
//       is an anomaly the calibrated model did not expect — a ring marks a high-quality one.
//    3. The dashboard shows, per level, the coverage you TARGETED vs what was actually
//       ACHIEVED (with a Wilson interval), plus where price sits in the band and how the
//       coverage holds up in the current regime.
//    4. This forecasts a calibrated RANGE, not a direction. It is context, not a signal,
//       and it places no orders.
//
//  ORIGINALITY
//    Distribution-free conformal prediction with parameter-free online recalibration, a
//    self-weighting forecast centre, and an on-chart realised-coverage readout broken
//    down by regime — a forecasting framework that measures and proves its own accuracy,
//    not a fixed-width overlay.
//
//  UNIVERSAL USE
//    The price source is user-selectable and volume is borrowed where a symbol reports
//    none, so the engine runs on futures, equities, forex, crypto and indices on any
//    timeframe. Only standard technical methods and terms are used.
//
//  LIMITATIONS (honest)
//    Conformal coverage is a long-run expectation under exchangeability; markets violate
//    that, which is why online calibration is used — through sharp breaks coverage dips
//    temporarily and the dashboard (including the per-regime row) shows it rather than
//    hiding it. Past coverage is not a future promise.
//
//  DISCLAIMER
//    Study / indicator for chart analysis and education only. NOT a strategy, NOT a
//    recommendation, NOT financial advice. It places no orders and guarantees no
//    outcome. Markets carry risk. Do your own research and manage your own risk.
// =============================================================================

//@version=6
indicator("Self-Calibrating Probability Channel", "ConfChan", overlay = true, max_labels_count = 200, max_lines_count = 100, max_bars_back = 2000, max_polylines_count = 100)

// ───────────────────────────────── INPUTS ──────────────────────────────────
gData = "Data"
src = input.source(close, "Price source", group = gData, tooltip = "Raw series the forecast and bands are built on. Works on any symbol / market.")

gFc = "Forecast path"
pathType = input.string("Auto (self-weighting)", "Forecast path", options = ["EMA", "Linear Regression", "Kalman (level + velocity)", "Anchored VWAP", "Auto (self-weighting)"], group = gFc, tooltip = "The expected price path. Auto runs all four and weights them online by recent accuracy, so the centre self-calibrates too. Kalman tracks level+velocity; Linear Regression extrapolates a fitted slope; EMA projects its slope; Anchored VWAP anchors per session/week/month.")
ensRate = input.float(0.05, "Auto adaptation rate", minval = 0.01, maxval = 0.30, step = 0.01, group = gFc, tooltip = "How fast the Auto path re-weights toward whichever model has been most accurate recently.")
avwapAnchor = input.string("Session", "Anchored-VWAP anchor", options = ["Session", "Week", "Month"], group = gFc, tooltip = "Where the anchored VWAP resets. Session is best for intraday charts.")
emaLen = input.int(20, "EMA length", minval = 2, group = gFc)
lrLen = input.int(20, "Linear-regression length", minval = 3, group = gFc)
kAlpha = input.float(0.20, "Kalman level gain", minval = 0.01, maxval = 1.0, step = 0.01, group = gFc, tooltip = "Higher = path reacts faster to price.")
kBeta = input.float(0.02, "Kalman velocity gain", minval = 0.001, maxval = 0.5, step = 0.001, group = gFc, tooltip = "Higher = drift reacts faster.")
driftLen = input.int(5, "Drift smoothing (EMA path)", minval = 1, group = gFc)
fwdBars = input.int(12, "Forward projection (bars)", minval = 0, maxval = 60, group = gFc)
coneDecay = input.float(0.88, "Cone momentum decay", minval = 0.50, maxval = 1.0, step = 0.02, group = gFc, tooltip = "How fast projected drift fades along the cone. 1.0 = straight-line extrapolation; lower curves the cone as momentum decays.")

gM = "Higher-timeframe context"
useMTF = input.bool(false, "Show higher-timeframe forecast", group = gM)
mtfTF = input.timeframe("", "Higher timeframe (blank = auto)", group = gM)

gS = "Confluence & breach quality"
showConf = input.bool(true, "Mark high-quality breaches", group = gS, tooltip = "Each band breach is graded 0-5 on displacement past the band, anti-wick close, volume surge, range expansion and structure break. Breaches scoring 3+ are marked with a ring.")
pivLen = input.int(5, "Swing pivot length", minval = 2, maxval = 30, group = gS)
showSpring = input.bool(true, "Mark coiled-spring releases", group = gS, tooltip = "Flags the moment a compressed range starts to release (long efficiency window low, short window rising) - a forward cue that the cone is about to widen.")
springLen = input.int(30, "Compression window", minval = 10, maxval = 100, group = gS)
springComp = input.float(0.28, "Compression threshold", minval = 0.10, maxval = 0.60, step = 0.02, group = gS)
springRel = input.float(0.50, "Release threshold", minval = 0.30, maxval = 0.80, step = 0.02, group = gS)

gT = "Turbulence (early warning)"
hawkAlpha = input.float(0.50, "Cluster excitation", minval = 0.10, maxval = 0.90, step = 0.05, group = gT, tooltip = "How much each outer-band breach amplifies the turbulence intensity (Hawkes self-excitation).")
hawkBeta = input.float(0.20, "Cluster decay", minval = 0.05, maxval = 0.50, step = 0.05, group = gT, tooltip = "How fast turbulence intensity decays. Smaller = longer memory.")
hawkWarn = input.float(2.0, "Warning threshold (x average)", minval = 1.2, maxval = 5.0, step = 0.1, group = gT, tooltip = "When clustering intensity exceeds this multiple of its recent average, reliability is dampened and a turbulence flag is raised - a leading sign that coverage is about to degrade.")

gC = "Conformal calibration"
winN = input.int(250, "Residual window (bars)", minval = 30, maxval = 1000, group = gC, tooltip = "How many recent forecast errors are stored.")
bandWin = input.int(120, "Band window (recency)", minval = 20, maxval = 1000, group = gC, tooltip = "The band quantiles use the most recent this-many errors, so width tracks the current regime. Smaller = more reactive.")
volNorm = input.bool(true, "Volatility-normalise errors", group = gC, tooltip = "Store errors in ATR units and scale the band by current ATR, so the band breathes with volatility while holding coverage.")
minSamp = input.int(50, "Min samples before drawing", minval = 10, maxval = 500, group = gC)
useACI = input.bool(true, "Self-calibrate (ACI)", group = gC, tooltip = "Online loop that widens an under-covering band and tightens an over-covering one to hold the target coverage.")
useDtACI = input.bool(true, "Parameter-free calibration (DtACI)", group = gC, tooltip = "Runs several calibration speeds as competing experts and blends them by recent accuracy, so there is no rate to tune. Overrides the manual ACI rate when on.")
aciRate = input.float(0.02, "Calibration speed (ACI rate)", minval = 0.001, maxval = 0.2, step = 0.001, group = gC, tooltip = "Used only when DtACI is off.")
covWin = input.int(500, "Coverage measurement window", minval = 50, maxval = 5000, group = gC, tooltip = "Window over which realised coverage is reported.")

gReg = "Regime"
erLen = input.int(20, "Efficiency-ratio length", minval = 2, group = gReg)
atrLen = input.int(14, "ATR length", minval = 2, group = gReg)

gV = "Visuals"
themeMode = input.string("Auto (match chart)", "Theme", options = ["Auto (match chart)", "Dark", "Light"], group = gV)
showBands = input.bool(true, "Probability bands", group = gV)
showFill = input.bool(true, "Gradient probability zones", group = gV)
showCone = input.bool(true, "Forward projection", group = gV)
showLabels = input.bool(true, "Right-side band labels", group = gV)
showBoot = input.bool(false, "Residual bootstrap cloud", group = gV, tooltip = "Draws sample forward paths by resampling the actual forecast errors - a visual of the empirical distribution the bands come from. Off by default (adds drawing objects).")
bootPaths = input.int(20, "Bootstrap paths", minval = 5, maxval = 40, group = gV)
showBreach = input.bool(true, "Breach anomalies", group = gV)
anomSens = input.float(1.0, "Anomaly depth (× outer-band gap)", minval = 0.0, maxval = 5.0, step = 0.25, group = gV, tooltip = "How far beyond the 95% band a move must go to count as an anomaly. 0 = any 95% breach (frequent); 1+ = only deep, rare breaches (~99%+).")
showDash = input.bool(true, "Dashboard", group = gV)
showLegend = input.bool(true, "Legend / key", group = gV)
legendPosStr = input.string("Bottom Left", "Legend position", options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group = gV)
showId = input.bool(true, "Identity strip", group = gV)
dashPosStr = input.string("Top Right", "Dashboard position", options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group = gV)
bullCol = input.color(#089981, "Up colour", group = gV)
bearCol = input.color(#f23645, "Down colour", group = gV)

// ───────────────────────────────── THEME ───────────────────────────────────
f_luma(color c) =>
    0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
bool uiDark = themeMode == "Dark" ? true : themeMode == "Light" ? false : f_luma(chart.bg_color) < 140
color uiBull = bullCol
color uiBear = bearCol
color amber = #f7a600
color cTxt = uiDark ? color.rgb(232, 236, 242) : color.rgb(20, 24, 32)
color cDim = uiDark ? color.rgb(150, 160, 174) : color.rgb(96, 104, 116)
color cPanel = uiDark ? color.rgb(16, 20, 30) : color.rgb(244, 246, 248)
color cSub = uiDark ? color.rgb(26, 32, 44) : color.rgb(232, 236, 242)
color cAlt = uiDark ? color.rgb(20, 26, 38) : color.rgb(238, 241, 245)
color cFrame = uiDark ? color.rgb(60, 70, 86) : color.rgb(196, 204, 214)
color cBord = color.new(uiDark ? color.rgb(60, 70, 86) : color.rgb(196, 204, 214), 40)

f_pos(string s) =>
    s == "Top Left" ? position.top_left : s == "Top Right" ? position.top_right : s == "Middle Left" ? position.middle_left : s == "Middle Right" ? position.middle_right : s == "Bottom Left" ? position.bottom_left : position.bottom_right

// ──────────────────────────────── HELPERS ──────────────────────────────────
// empirical quantile over the most-recent k values of a parameter array (safe: local copy)
f_quant(float[] a, int k, float p) =>
    int n = array.size(a)
    float out = na
    if n >= 1
        int start = math.max(0, n - k)
        float[] s = array.new_float(0)
        for i = start to n - 1
            array.push(s, array.get(a, i))
        array.sort(s, order.ascending)
        int m = array.size(s)
        float idx = math.max(0.0, math.min(p, 1.0)) * (m - 1)
        int lo = math.max(0, math.min(m - 1, int(math.floor(idx))))
        int hi = math.max(0, math.min(m - 1, int(math.ceil(idx))))
        float fr = idx - lo
        out := array.get(s, lo) * (1.0 - fr) + array.get(s, hi) * fr
    out
// conformal band [lower, upper] for miscoverage al, centred on pred, scaled, over recent k
f_band(float[] a, float pred, float al, float scale, int k) =>
    float lo = pred + scale * f_quant(a, k, al / 2.0)
    float hi = pred + scale * f_quant(a, k, 1.0 - al / 2.0)
    [lo, hi]
// Wilson 95% interval
f_wilson(int hits, int total) =>
    float lo = na
    float hi = na
    if total > 0
        float ph = hits / total
        float z = 1.96
        float d = 1.0 + z * z / total
        float c = ph + z * z / (2.0 * total)
        float m = z * math.sqrt(ph * (1.0 - ph) / total + z * z / (4.0 * total * total))
        lo := (c - m) / d
        hi := (c + m) / d
    [lo, hi]
// per-regime realised 90% coverage, formatted (arrays passed as params: safe)
f_regCov(int[] tot, int[] hit, int i) =>
    int t = array.get(tot, i)
    int h = array.get(hit, i)
    t > 0 ? str.tostring(math.round(h * 100.0 / t)) + "% n" + str.tostring(t) : "—"

// ───────────────────────────── FORECAST PATH ───────────────────────────────
f_autoHTF() =>
    float s = timeframe.in_seconds(timeframe.period)
    s <= 60 ? "15" : s <= 300 ? "60" : s <= 900 ? "240" : s <= 3600 ? "D" : s <= 86400 ? "W" : "M"
f_htfProxy() =>
    float p = ta.linreg(src, lrLen, 0)
    float sl = (ta.linreg(src, lrLen, 0) - ta.linreg(src, lrLen, lrLen - 1)) / (lrLen - 1)
    int dir = src > p and sl > 0 ? 2 : sl > 0 ? 1 : src < p and sl < 0 ? -2 : sl < 0 ? -1 : 0
    [p[1], dir[1]]
float emaPath = ta.ema(src, emaLen)
float emaDrift = (emaPath - emaPath[driftLen]) / driftLen
float lrPath = ta.linreg(src, lrLen, 0)
float lrSlope = (ta.linreg(src, lrLen, 0) - ta.linreg(src, lrLen, lrLen - 1)) / (lrLen - 1)

// Anchored VWAP (volume-weighted; falls back to time-weighted where volume is absent)
string anchTF = avwapAnchor == "Week" ? "W" : avwapAnchor == "Month" ? "M" : "D"
bool newAnchor = ta.change(time(anchTF)) != 0
var float avNum = 0.0
var float avDen = 0.0
if newAnchor
    avNum := 0.0
    avDen := 0.0
float vw = volume > 0 ? volume : 1.0
avNum := avNum + src * vw
avDen := avDen + vw
float avPath = avDen > 0 ? avNum / avDen : src
float avDrift = (avPath - avPath[driftLen]) / driftLen

// Kalman (alpha-beta / steady-state level + velocity tracker)
var float kLevel = na
var float kVel = 0.0
float kPred = na(kLevel) ? src : kLevel + kVel
float kResid = src - kPred
if na(kLevel)
    kLevel := src
    kVel := 0.0
else
    kLevel := kPred + kAlpha * kResid
    kVel := kVel + kBeta * kResid

// self-weighting ensemble: each path's recent out-of-sample error sets its weight
float predEMA = emaPath[1] + emaDrift[1]
float predLR = lrPath[1] + lrSlope[1]
float predAV = avPath[1] + avDrift[1]
float predK = kLevel[1] + kVel[1]
var float errEMA = na
var float errLR = na
var float errAV = na
var float errK = na
if barstate.isconfirmed
    errEMA := na(errEMA) ? math.abs(src - predEMA) : errEMA + ensRate * (math.abs(src - predEMA) - errEMA)
    errLR := na(errLR) ? math.abs(src - predLR) : errLR + ensRate * (math.abs(src - predLR) - errLR)
    errAV := na(errAV) ? math.abs(src - predAV) : errAV + ensRate * (math.abs(src - predAV) - errAV)
    errK := na(errK) ? math.abs(src - predK) : errK + ensRate * (math.abs(src - predK) - errK)
float wE = 1.0 / (nz(errEMA, 1.0) + 1e-6)
float wL = 1.0 / (nz(errLR, 1.0) + 1e-6)
float wA = 1.0 / (nz(errAV, 1.0) + 1e-6)
float wK = 1.0 / (nz(errK, 1.0) + 1e-6)
float wSum = wE + wL + wA + wK
float ensPath = (wE * emaPath + wL * lrPath + wA * avPath + wK * kLevel) / wSum
float ensDrift = (wE * emaDrift + wL * lrSlope + wA * avDrift + wK * kVel) / wSum

float pathNow = pathType == "EMA" ? emaPath : pathType == "Linear Regression" ? lrPath : pathType == "Anchored VWAP" ? avPath : pathType == "Auto (self-weighting)" ? ensPath : kLevel
float drift = pathType == "EMA" ? emaDrift : pathType == "Linear Regression" ? lrSlope : pathType == "Anchored VWAP" ? avDrift : pathType == "Auto (self-weighting)" ? ensDrift : kVel

// 1-step-ahead forecast for the current bar, made from last bar (out-of-sample)
float pred1 = pathNow[1] + drift[1]
float resid = src - pred1

// volatility scale: store errors in ATR units (known at forecast time) and rescale
float atrNow = ta.atr(atrLen)
float atrFc = nz(atrNow[1], atrNow)
float scaleFc = volNorm and atrFc > 0 ? atrFc : 1.0
float residStore = scaleFc > 0 ? resid / scaleFc : resid

// higher-timeframe forecast direction (unconditional call; display gated by useMTF)
string htfRes = not useMTF ? timeframe.period : mtfTF == "" ? f_autoHTF() : mtfTF
[htfPath, htfDir] = request.security(syminfo.tickerid, htfRes, f_htfProxy(), lookahead = barmerge.lookahead_on)

// ─────────────────────────── RESIDUAL WINDOW ───────────────────────────────
var float[] resW = array.new_float(0)
bool ready = array.size(resW) >= minSamp

// ─────────────────────────── CONFORMAL BANDS ───────────────────────────────
// effective miscoverage per level (adapted by ACI); start at the nominal targets
var float a50 = 0.50
var float a70 = 0.30
var float a90 = 0.10
var float a95 = 0.05

[lo50, hi50] = f_band(resW, pred1, a50, scaleFc, bandWin)
[lo70, hi70] = f_band(resW, pred1, a70, scaleFc, bandWin)
[lo90, hi90] = f_band(resW, pred1, a90, scaleFc, bandWin)
[lo95, hi95] = f_band(resW, pred1, a95, scaleFc, bandWin)

// ──────────────────────────────── REGIME ───────────────────────────────────
float er = math.abs(src - src[erLen]) / (math.sum(math.abs(src - src[1]), erLen) + 1e-9)
float atrAvg = ta.sma(atrNow, atrLen * 3)
bool expanding = atrNow > atrAvg
bool trending = er > 0.5
int regIdx = trending ? (expanding ? 0 : 1) : (expanding ? 2 : 3)
// coiled-spring: range compressed on the long efficiency window, releasing on the short
float erLong = math.abs(src - src[springLen]) / (math.sum(math.abs(src - src[1]), springLen) + 1e-9)
var int lastSpring = -100000
bool coiledRaw = ready and erLong < springComp and er >= springRel and er[1] < springRel
bool coiled = coiledRaw and bar_index - lastSpring > springLen
if barstate.isconfirmed and coiled
    lastSpring := bar_index
string regimeTxt = (trending ? (expanding ? "Trending · expansion" : "Trending · quiet") : (expanding ? "Volatile · breakout" : "Ranging · quiet")) + (coiled ? "  ⌁" : "")
color regimeCol = trending ? (drift > 0 ? uiBull : uiBear) : expanding ? amber : cDim

// ───────────────── COVERAGE TRACKING + ACI SELF-CALIBRATION ─────────────────
var int in50 = 0
var int in70 = 0
var int in90 = 0
var int in95 = 0
var int covTot = 0
var int[] hist50 = array.new_int(0)
var int[] hist70 = array.new_int(0)
var int[] hist90 = array.new_int(0)
var int[] hist95 = array.new_int(0)
var int[] regHit90 = array.new_int(4, 0)
var int[] regTot90 = array.new_int(4, 0)
// DtACI: competing calibration-rate experts (controller at the 90% level)
var float[] dtA = array.new_float(3, 0.10)
var float[] dtE = array.new_float(3, 0.10)
var float[] dtW = array.new_float(3, 0.3333)
var float[] dtG = array.from(0.004, 0.02, 0.10)
var float dtRate = na

f_clampA(float x) =>
    math.max(0.005, math.min(0.7, x))

if barstate.isconfirmed and ready and not na(src)
    bool c50 = src >= lo50 and src <= hi50
    bool c70 = src >= lo70 and src <= hi70
    bool c90 = src >= lo90 and src <= hi90
    bool c95 = src >= lo95 and src <= hi95
    array.push(hist50, c50 ? 1 : 0)
    array.push(hist70, c70 ? 1 : 0)
    array.push(hist90, c90 ? 1 : 0)
    array.push(hist95, c95 ? 1 : 0)
    in50 := in50 + (c50 ? 1 : 0)
    in70 := in70 + (c70 ? 1 : 0)
    in90 := in90 + (c90 ? 1 : 0)
    in95 := in95 + (c95 ? 1 : 0)
    covTot := covTot + 1
    array.set(regTot90, regIdx, array.get(regTot90, regIdx) + 1)
    if c90
        array.set(regHit90, regIdx, array.get(regHit90, regIdx) + 1)
    if array.size(hist50) > covWin
        in50 := in50 - array.shift(hist50)
        in70 := in70 - array.shift(hist70)
        in90 := in90 - array.shift(hist90)
        in95 := in95 - array.shift(hist95)
        covTot := covTot - 1
    // DtACI: blend competing calibration speeds by recent accuracy (parameter-free)
    float rate = aciRate
    if useDtACI
        int cnt = array.size(resW)
        int st = math.max(0, cnt - bandWin)
        int below = 0
        if cnt > 0
            for j = st to cnt - 1
                if array.get(resW, j) < residStore
                    below := below + 1
        float u = below / math.max(1.0, float(cnt - st))
        float depth = 2.0 * math.min(u, 1.0 - u)
        float wsum = 0.0
        for i = 0 to 2
            float ai = array.get(dtA, i)
            float erri = depth < ai ? 1.0 : 0.0
            float ei = array.get(dtE, i) + 0.02 * (erri - array.get(dtE, i))
            array.set(dtE, i, ei)
            array.set(dtA, i, f_clampA(ai + array.get(dtG, i) * (0.10 - erri)))
            float wi = math.max(1e-6, array.get(dtW, i) * math.exp(-100.0 * (ei - 0.10) * (ei - 0.10)))
            array.set(dtW, i, wi)
            wsum := wsum + wi
        float gacc = 0.0
        for i = 0 to 2
            float wn = 0.95 * array.get(dtW, i) / wsum + 0.05 / 3.0
            array.set(dtW, i, wn)
            gacc := gacc + wn * array.get(dtG, i)
        rate := gacc
        dtRate := gacc
    if useACI or useDtACI
        a50 := f_clampA(a50 + rate * (0.50 - (c50 ? 0.0 : 1.0)))
        a70 := f_clampA(a70 + rate * (0.30 - (c70 ? 0.0 : 1.0)))
        a90 := f_clampA(a90 + rate * (0.10 - (c90 ? 0.0 : 1.0)))
        a95 := f_clampA(a95 + rate * (0.05 - (c95 ? 0.0 : 1.0)))

// record this bar's error AFTER its band was evaluated, so bands stay out-of-sample
if barstate.isconfirmed and not na(residStore)
    array.push(resW, residStore)
    if array.size(resW) > winN
        array.shift(resW)

// H-step-ahead errors (for the widening forward cone): error of the forecast made fwdBars ago
var float[] resWH = array.new_float(0)
float hScaleRef = nz(atrNow[fwdBars], atrNow)
float hScaleFc = volNorm and hScaleRef > 0 ? hScaleRef : 1.0
float hPred = fwdBars >= 1 ? pathNow[fwdBars] + fwdBars * drift[fwdBars] : na
float hResidStore = (fwdBars >= 1 and hScaleFc > 0 and not na(hPred)) ? (src - hPred) / hScaleFc : na
if barstate.isconfirmed and not na(hResidStore)
    array.push(resWH, hResidStore)
    if array.size(resWH) > winN
        array.shift(resWH)

float cov50 = covTot > 0 ? in50 * 100.0 / covTot : na
float cov70 = covTot > 0 ? in70 * 100.0 / covTot : na
float cov90 = covTot > 0 ? in90 * 100.0 / covTot : na
float cov95 = covTot > 0 ? in95 * 100.0 / covTot : na

// ────────────────────── TURBULENCE (Hawkes clustering) ─────────────────────
// outer-band breaches are "events"; a self-exciting intensity rises when they
// cluster, giving a LEADING warning that coverage is about to degrade
bool out95 = ready and (src > hi95 or src < lo95)
var float hawkLam = 0.0
if barstate.isconfirmed
    hawkLam := hawkLam * math.exp(-hawkBeta) + (out95 ? hawkAlpha : 0.0)
float hawkAvg = ta.sma(hawkLam, 100)
float hawkRatio = hawkAvg > 1e-9 ? hawkLam / hawkAvg : 1.0
bool turbulent = ready and hawkRatio > hawkWarn
float turbPenalty = turbulent ? math.min(40.0, (hawkRatio - hawkWarn) * 15.0 + 10.0) : 0.0

// ──────────────────────────── RELIABILITY ──────────────────────────────────
// calibration component: how close every level's realised coverage is to its target
float calScore = (na(cov50) or na(cov95)) ? na : 100.0 - math.min(100.0, (math.abs(cov50 - 50.0) + math.abs(cov70 - 70.0) + math.abs(cov90 - 90.0) + math.abs(cov95 - 95.0)) / 4.0 * 4.0)
// regime component: a prediction interval holds best in stable conditions, worst in breakouts
float regScore = not expanding ? 85.0 : trending ? 60.0 : 35.0
// stability component: drift not erratic relative to volatility
float stabScore = 100.0 - math.min(100.0, ta.stdev(drift, 20) / (atrNow + 1e-9) * 100.0)
// turbulence dampens the score as a leading signal (subtracted before clamping)
int reliability = ready and not na(calScore) ? int(math.round(math.max(0.0, calScore * 0.5 + regScore * 0.25 + stabScore * 0.25 - turbPenalty))) : na

// ─────────────────────── SWING-BREAK STRUCTURE ─────────────────────────────
float pvH = ta.pivothigh(high, pivLen, pivLen)
float pvL = ta.pivotlow(low, pivLen, pivLen)
var float lastPvH = na
var float lastPvL = na
if not na(pvH)
    lastPvH := pvH
if not na(pvL)
    lastPvL := pvL
bool structUp = not na(lastPvH) and close > lastPvH
bool structDn = not na(lastPvL) and close < lastPvL

float fbias = ready ? scaleFc * f_quant(resW, winN, 0.5) : na

// ──────────────────────────────── BREACH ───────────────────────────────────
float gapU = math.max(hi95 - hi90, atrNow * 0.05)
float gapL = math.max(lo90 - lo95, atrNow * 0.05)
float thrU = hi95 + anomSens * gapU
float thrL = lo95 - anomSens * gapL
bool breachUp = ready and src > thrU and src[1] <= thrU[1]
bool breachDn = ready and src < thrL and src[1] >= thrL[1]
// breach quality 0-5: displacement, anti-wick close, volume surge, range expansion, structure
float rngBar = math.max(high - low, syminfo.mintick)
float volAvg = ta.sma(volume, 20)
bool volSurge = not na(volume) and not na(volAvg) and volume > volAvg * 1.3
bool rangeExp = (high - low) > atrNow * 1.5
float dispUp = (src - hi95) / (atrNow + 1e-9)
float dispDn = (lo95 - src) / (atrNow + 1e-9)
int qualUp = (dispUp > 0.25 ? 1 : 0) + ((close - low) / rngBar > 0.6 ? 1 : 0) + (volSurge ? 1 : 0) + (rangeExp ? 1 : 0) + (structUp ? 1 : 0)
int qualDn = (dispDn > 0.25 ? 1 : 0) + ((high - close) / rngBar > 0.6 ? 1 : 0) + (volSurge ? 1 : 0) + (rangeExp ? 1 : 0) + (structDn ? 1 : 0)
bool confUp = breachUp and qualUp >= 3
bool confDn = breachDn and qualDn >= 3

// ─────────────────────────────── PLOTTING ──────────────────────────────────
color cCenter = drift > 0 ? uiBull : drift < 0 ? uiBear : cDim
// theme-adaptive intensities: deeper fills on light backgrounds, lighter on dark,
// and crisper edges on dark, so the channel reads against any chart colour
int eMid = uiDark ? 30 : 38
int eOut = uiDark ? 18 : 26
int z50 = uiDark ? 80 : 66
int z70 = uiDark ? 87 : 78
int z90 = uiDark ? 92 : 86
int z95 = uiDark ? 95 : 91
pC = plot(ready and showBands ? pred1 : na, "Forecast path", color = color.new(cCenter, 0), linewidth = 2)
pu50 = plot(ready and showBands ? hi50 : na, "Upper 50", color = color.new(cCenter, 70), display = display.none)
pl50 = plot(ready and showBands ? lo50 : na, "Lower 50", color = color.new(cCenter, 70), display = display.none)
pu70 = plot(ready and showBands ? hi70 : na, "Upper 70", color = color.new(cCenter, 80), display = display.none)
pl70 = plot(ready and showBands ? lo70 : na, "Lower 70", color = color.new(cCenter, 80), display = display.none)
pu90 = plot(ready and showBands ? hi90 : na, "Upper 90", color = color.new(cCenter, eMid), linewidth = 1)
pl90 = plot(ready and showBands ? lo90 : na, "Lower 90", color = color.new(cCenter, eMid), linewidth = 1)
pu95 = plot(ready and showBands ? hi95 : na, "Upper 95", color = color.new(cCenter, eOut), linewidth = 1)
pl95 = plot(ready and showBands ? lo95 : na, "Lower 95", color = color.new(cCenter, eOut), linewidth = 1)

// gradient probability zones (darker = more likely)
fill(pu50, pl50, color = showFill ? color.new(cCenter, z50) : na, title = "50% zone")
fill(pu70, pu50, color = showFill ? color.new(cCenter, z70) : na, title = "70% zone (upper)")
fill(pl50, pl70, color = showFill ? color.new(cCenter, z70) : na, title = "70% zone (lower)")
fill(pu90, pu70, color = showFill ? color.new(cCenter, z90) : na, title = "90% zone (upper)")
fill(pl70, pl90, color = showFill ? color.new(cCenter, z90) : na, title = "90% zone (lower)")
fill(pu95, pu90, color = showFill ? color.new(cCenter, z95) : na, title = "95% zone (upper)")
fill(pl90, pl95, color = showFill ? color.new(cCenter, z95) : na, title = "95% zone (lower)")

plotshape(showBreach and breachUp, "Positive anomaly", style = shape.triangleup, location = location.abovebar, color = color.new(uiBull, 0), size = size.tiny)
plotshape(showBreach and breachDn, "Negative anomaly", style = shape.triangledown, location = location.belowbar, color = color.new(uiBear, 0), size = size.tiny)
plotshape(showConf and confUp, "Confluent anomaly up", style = shape.circle, location = location.abovebar, color = color.new(uiBull, 0), size = size.tiny)
plotshape(showConf and confDn, "Confluent anomaly down", style = shape.circle, location = location.belowbar, color = color.new(uiBear, 0), size = size.tiny)
plotshape(showSpring and coiled, "Coiled-spring release", style = shape.diamond, location = location.belowbar, color = color.new(amber, 0), size = size.tiny)

// ─────────────── FORWARD PROJECTION: widening conformal cone ────────────────
// per-step width interpolates from the 1-step interval to the H-step interval,
// both measured from actual forecast errors (not a sqrt-time assumption)
var polyline plC = na
var polyline plU95 = na
var polyline plL95 = na
var polyline plU90 = na
var polyline plL90 = na
if barstate.islast
    polyline.delete(plC)
    polyline.delete(plU95)
    polyline.delete(plL95)
    polyline.delete(plU90)
    polyline.delete(plL90)
    if showCone and ready and fwdBars >= 2 and array.size(resWH) >= minSamp
        float scaleNow = volNorm and atrNow > 0 ? atrNow : 1.0
        float qU95_1 = hi95 - pred1
        float qL95_1 = lo95 - pred1
        float qU90_1 = hi90 - pred1
        float qL90_1 = lo90 - pred1
        float qU95_H = scaleNow * f_quant(resWH, bandWin, 1.0 - a95 / 2.0)
        float qL95_H = scaleNow * f_quant(resWH, bandWin, a95 / 2.0)
        float qU90_H = scaleNow * f_quant(resWH, bandWin, 1.0 - a90 / 2.0)
        float qL90_H = scaleNow * f_quant(resWH, bandWin, a90 / 2.0)
        ptsC = array.new<chart.point>()
        ptsU95 = array.new<chart.point>()
        ptsL95 = array.new<chart.point>()
        ptsU90 = array.new<chart.point>()
        ptsL90 = array.new<chart.point>()
        for k = 0 to fwdBars
            float frac = k / float(fwdBars)
            float disp = coneDecay < 1.0 ? drift * (1.0 - math.pow(coneDecay, k)) / (1.0 - coneDecay) : k * drift
            float ck = pathNow + disp
            array.push(ptsC, chart.point.from_index(bar_index + k, ck))
            array.push(ptsU95, chart.point.from_index(bar_index + k, ck + (1.0 - frac) * qU95_1 + frac * qU95_H))
            array.push(ptsL95, chart.point.from_index(bar_index + k, ck + (1.0 - frac) * qL95_1 + frac * qL95_H))
            array.push(ptsU90, chart.point.from_index(bar_index + k, ck + (1.0 - frac) * qU90_1 + frac * qU90_H))
            array.push(ptsL90, chart.point.from_index(bar_index + k, ck + (1.0 - frac) * qL90_1 + frac * qL90_H))
        plC := polyline.new(ptsC, curved = true, xloc = xloc.bar_index, line_color = color.new(cCenter, 0), line_width = 2, line_style = line.style_dashed)
        plU95 := polyline.new(ptsU95, curved = true, xloc = xloc.bar_index, line_color = color.new(cCenter, eOut), line_width = 2)
        plL95 := polyline.new(ptsL95, curved = true, xloc = xloc.bar_index, line_color = color.new(cCenter, eOut), line_width = 2)
        plU90 := polyline.new(ptsU90, curved = true, xloc = xloc.bar_index, line_color = color.new(cCenter, eMid), line_width = 1)
        plL90 := polyline.new(ptsL90, curved = true, xloc = xloc.bar_index, line_color = color.new(cCenter, eMid), line_width = 1)

// ───────────────── RESIDUAL BOOTSTRAP CLOUD (empirical paths) ───────────────
// resample the actual stored forecast errors to draw plausible forward paths,
// a direct visual of the distribution the bands are built from
var polyline[] bootPL = array.new<polyline>(0)
if barstate.islast
    if array.size(bootPL) > 0
        for bi = 0 to array.size(bootPL) - 1
            polyline.delete(array.get(bootPL, bi))
        array.clear(bootPL)
    if showBoot and ready and fwdBars >= 2 and array.size(resW) > 20
        int nR = array.size(resW)
        float scaleNow = volNorm and atrNow > 0 ? atrNow : 1.0
        for p = 0 to bootPaths - 1
            int lcg = (bar_index + p * 7919) % 2147483647
            lcg := lcg <= 0 ? lcg + 2147483647 : lcg
            float yk = pathNow
            bpts = array.new<chart.point>()
            array.push(bpts, chart.point.from_index(bar_index, yk))
            for k = 1 to fwdBars
                lcg := (lcg * 1103515245 + 12345) % 2147483647
                int idx = math.abs(lcg) % nR
                float r = array.get(resW, idx)
                float ds = coneDecay < 1.0 ? drift * math.pow(coneDecay, k - 1) : drift
                yk := yk + ds + r * scaleNow
                array.push(bpts, chart.point.from_index(bar_index + k, yk))
            array.push(bootPL, polyline.new(bpts, curved = false, xloc = xloc.bar_index, line_color = color.new(cCenter, uiDark ? 80 : 86), line_width = 1))

// right-side band labels (one per side, both levels, to avoid overlap)
var label lbC = na
var label lbU = na
var label lbL = na
if barstate.islast
    label.delete(lbC)
    label.delete(lbU)
    label.delete(lbL)
    if showLabels and ready
        int lx = bar_index + (showCone and fwdBars >= 2 ? math.min(fwdBars, 6) : 2) + 1
        lbC := label.new(lx, pathNow, "fcst " + str.tostring(math.round_to_mintick(pathNow)), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(cCenter, 15), textcolor = color.white, size = size.small)
        lbU := label.new(lx, hi95, "90% " + str.tostring(math.round_to_mintick(hi90)) + "  ·  95% " + str.tostring(math.round_to_mintick(hi95)), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(cCenter, 45), textcolor = cTxt, size = size.small)
        lbL := label.new(lx, lo95, "90% " + str.tostring(math.round_to_mintick(lo90)) + "  ·  95% " + str.tostring(math.round_to_mintick(lo95)), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(cCenter, 45), textcolor = cTxt, size = size.small)

// ─────────────────────────────── DASHBOARD ─────────────────────────────────
f_status(float cov, float target) =>
    na(cov) ? "—" : math.abs(cov - target) <= 4.0 ? "✓ calibrated" : cov < target ? "under" : "over"
f_statusC(float cov, float target, color okc, color underc, color overc, color dimc) =>
    na(cov) ? dimc : math.abs(cov - target) <= 4.0 ? okc : cov < target ? underc : overc

var table dash = table.new(f_pos(dashPosStr), 2, 14, border_width = 0, frame_width = 1)
if showDash and barstate.islast
    table.set_bgcolor(dash, cPanel)
    table.set_frame_color(dash, cFrame)
    table.set_border_color(dash, cBord)
    color hb = color.new(cCenter, 0)
    table.cell(dash, 0, 0, "PROBABILITY CHANNEL", text_color = color.white, text_size = size.small, text_halign = text.align_left, bgcolor = hb)
    table.cell(dash, 1, 0, ready ? regimeTxt : "warming up", text_color = color.white, text_size = size.small, text_halign = text.align_right, bgcolor = hb)
    string fcTip = pathType != "Auto (self-weighting)" ? "1-step forecast centre of the channel." : "Auto path weights (by recent accuracy): EMA " + str.tostring(math.round(wE / wSum * 100)) + "% · LR " + str.tostring(math.round(wL / wSum * 100)) + "% · Kalman " + str.tostring(math.round(wK / wSum * 100)) + "% · AVWAP " + str.tostring(math.round(wA / wSum * 100)) + "%"
    table.cell(dash, 0, 1, "Forecast", text_color = cDim, text_size = size.small, bgcolor = cSub, tooltip = fcTip)
    table.cell(dash, 1, 1, (drift > 0 ? "Bullish" : drift < 0 ? "Bearish" : "Flat") + "  " + (ready ? str.tostring(math.round_to_mintick(pathNow)) : "—"), text_color = cCenter, text_size = size.small, bgcolor = cSub)
    float bandPos = ready and (hi90 - lo90) > 0 ? (src - lo90) / (hi90 - lo90) * 100.0 : na
    bool stretched = not na(bandPos) and (bandPos > 80 or bandPos < 20)
    string posArr = na(bandPos) ? "" : bandPos > 80 ? " ↑" : bandPos < 20 ? " ↓" : ""
    table.cell(dash, 0, 2, "90% band", text_color = cDim, text_size = size.small, bgcolor = cAlt, tooltip = "Lower–upper 90% bound, and where price sits inside it (0% = lower edge, 100% = upper). Past ~80/20 = stretched, a mean-reversion candidate.")
    table.cell(dash, 1, 2, ready ? str.tostring(math.round_to_mintick(lo90)) + "–" + str.tostring(math.round_to_mintick(hi90)) + "  " + str.tostring(math.round(bandPos)) + "%" + posArr : "—", text_color = stretched ? amber : cTxt, text_size = size.small, bgcolor = cAlt)
    table.cell(dash, 0, 3, "CALIBRATION", text_color = cTxt, text_size = size.small, text_halign = text.align_left, bgcolor = cSub)
    table.cell(dash, 1, 3, "target / actual", text_color = cDim, text_size = size.small, text_halign = text.align_right, bgcolor = cSub)
    table.cell(dash, 0, 4, "50% level", text_color = cDim, text_size = size.small, bgcolor = cAlt)
    table.cell(dash, 1, 4, na(cov50) ? "—" : str.tostring(math.round(cov50)) + "%  " + f_status(cov50, 50), text_color = f_statusC(cov50, 50, uiBull, uiBear, amber, cDim), text_size = size.small, bgcolor = cAlt)
    table.cell(dash, 0, 5, "70% level", text_color = cDim, text_size = size.small, bgcolor = cSub)
    table.cell(dash, 1, 5, na(cov70) ? "—" : str.tostring(math.round(cov70)) + "%  " + f_status(cov70, 70), text_color = f_statusC(cov70, 70, uiBull, uiBear, amber, cDim), text_size = size.small, bgcolor = cSub)
    table.cell(dash, 0, 6, "90% level", text_color = cDim, text_size = size.small, bgcolor = cAlt, tooltip = "Realised coverage of the 90% band over the last " + str.tostring(covWin) + " evaluated bars.")
    table.cell(dash, 1, 6, na(cov90) ? "—" : str.tostring(math.round(cov90)) + "%  " + f_status(cov90, 90), text_color = f_statusC(cov90, 90, uiBull, uiBear, amber, cDim), text_size = size.small, bgcolor = cAlt)
    table.cell(dash, 0, 7, "95% level", text_color = cDim, text_size = size.small, bgcolor = cSub)
    table.cell(dash, 1, 7, na(cov95) ? "—" : str.tostring(math.round(cov95)) + "%  " + f_status(cov95, 95), text_color = f_statusC(cov95, 95, uiBull, uiBear, amber, cDim), text_size = size.small, bgcolor = cSub)
    table.cell(dash, 0, 8, "Reliability", text_color = cDim, text_size = size.small, bgcolor = cAlt, tooltip = "0–100 blend of calibration closeness across all levels, regime favorability and forecast-drift stability, dampened when turbulence is detected.")
    table.cell(dash, 1, 8, na(reliability) ? "—" : str.tostring(reliability) + " / 100" + (turbulent ? "  ⚠" : ""), text_color = na(reliability) ? cDim : turbulent ? amber : reliability >= 70 ? uiBull : reliability >= 45 ? amber : uiBear, text_size = size.small, bgcolor = cAlt)
    table.cell(dash, 0, 9, "Forecast bias", text_color = cDim, text_size = size.small, bgcolor = cSub, tooltip = "Median forecast error. Near zero = unbiased path.")
    table.cell(dash, 1, 9, ready ? str.tostring(math.round_to_mintick(fbias)) : "—", text_color = cTxt, text_size = size.small, bgcolor = cSub)
    table.cell(dash, 0, 10, "Samples", text_color = cDim, text_size = size.small, bgcolor = cAlt)
    table.cell(dash, 1, 10, str.tostring(array.size(resW)) + " / " + str.tostring(winN), text_color = cTxt, text_size = size.small, bgcolor = cAlt)
    table.cell(dash, 0, 11, "Calibration", text_color = cDim, text_size = size.small, bgcolor = cSub, tooltip = useDtACI ? "DtACI: blends several calibration speeds by recent accuracy. Current effective rate ≈ " + (na(dtRate) ? "—" : str.tostring(dtRate, "#.###")) : "Adaptive Conformal Inference at a fixed rate.")
    table.cell(dash, 1, 11, useDtACI ? "DtACI" : useACI ? "ACI on" : "static", text_color = useDtACI or useACI ? uiBull : cDim, text_size = size.small, bgcolor = cSub)
    int rcTot = array.get(regTot90, regIdx)
    int rcHit = array.get(regHit90, regIdx)
    float rcPct = rcTot > 0 ? rcHit * 100.0 / rcTot : na
    string regTip = "Realised 90% coverage by regime (lifetime):\nTrending·expansion " + f_regCov(regTot90, regHit90, 0) + "\nTrending·quiet " + f_regCov(regTot90, regHit90, 1) + "\nVolatile·breakout " + f_regCov(regTot90, regHit90, 2) + "\nRanging·quiet " + f_regCov(regTot90, regHit90, 3)
    table.cell(dash, 0, 12, "90% here", text_color = cDim, text_size = size.small, bgcolor = cAlt, tooltip = regTip)
    table.cell(dash, 1, 12, na(rcPct) ? "—" : str.tostring(math.round(rcPct)) + "%  n" + str.tostring(rcTot), text_color = na(rcPct) ? cDim : math.abs(rcPct - 90.0) <= 5.0 ? uiBull : amber, text_size = size.small, bgcolor = cAlt)
    if useMTF
        string htfWord = htfDir >= 2 ? "Strong Bull" : htfDir == 1 ? "Bullish" : htfDir <= -2 ? "Strong Bear" : htfDir == -1 ? "Bearish" : "Flat"
        bool aligned = (htfDir > 0 and drift > 0) or (htfDir < 0 and drift < 0)
        table.cell(dash, 0, 13, "Higher TF", text_color = cDim, text_size = size.small, bgcolor = cSub, tooltip = "Forecast direction on " + htfRes + ". Aligned with the chart-timeframe drift = stronger context.")
        table.cell(dash, 1, 13, htfWord + (aligned ? "  ✓" : ""), text_color = htfDir > 0 ? uiBull : htfDir < 0 ? uiBear : cDim, text_size = size.small, bgcolor = cSub)

// ─────────────────────────────── LEGEND / KEY ──────────────────────────────
var table legend = table.new(f_pos(legendPosStr), 2, 9, border_width = 0, frame_width = 1)
if showLegend and barstate.islast
    table.set_bgcolor(legend, cPanel)
    table.set_frame_color(legend, cFrame)
    table.set_border_color(legend, cBord)
    table.cell(legend, 0, 0, "HOW TO READ", text_color = color.white, text_size = size.small, text_halign = text.align_left, bgcolor = color.new(cCenter, 0))
    table.cell(legend, 1, 0, "", text_color = color.white, text_size = size.small, bgcolor = color.new(cCenter, 0))
    table.cell(legend, 0, 1, "centre line", text_color = cCenter, text_size = size.small, bgcolor = cSub)
    table.cell(legend, 1, 1, "where price is expected to go", text_color = cTxt, text_size = size.small, bgcolor = cSub)
    table.cell(legend, 0, 2, "colour bands", text_color = cTxt, text_size = size.small, bgcolor = cAlt)
    table.cell(legend, 1, 2, "where price usually stays", text_color = cTxt, text_size = size.small, bgcolor = cAlt)
    table.cell(legend, 0, 3, "▲ ▼ arrow", text_color = cTxt, text_size = size.small, bgcolor = cSub)
    table.cell(legend, 1, 3, "an unusually big move", text_color = cTxt, text_size = size.small, bgcolor = cSub)
    table.cell(legend, 0, 4, "○ ring", text_color = uiBull, text_size = size.small, bgcolor = cAlt)
    table.cell(legend, 1, 4, "a strong, confirmed breakout", text_color = cTxt, text_size = size.small, bgcolor = cAlt)
    table.cell(legend, 0, 5, "◆ amber", text_color = amber, text_size = size.small, bgcolor = cSub)
    table.cell(legend, 1, 5, "a quiet range starting to wake up", text_color = cTxt, text_size = size.small, bgcolor = cSub)
    table.cell(legend, 0, 6, "faint fan", text_color = cDim, text_size = size.small, bgcolor = cAlt)
    table.cell(legend, 1, 6, "possible paths for price ahead", text_color = cTxt, text_size = size.small, bgcolor = cAlt)
    table.cell(legend, 0, 7, "right labels", text_color = cTxt, text_size = size.small, bgcolor = cSub)
    table.cell(legend, 1, 7, "key price levels just ahead", text_color = cTxt, text_size = size.small, bgcolor = cSub)
    table.cell(legend, 0, 8, "tip", text_color = cCenter, text_size = size.small, bgcolor = cAlt)
    table.cell(legend, 1, 8, "near an edge = stretched, often pulls back", text_color = cDim, text_size = size.small, bgcolor = cAlt)

// identity strip
var table idTbl = table.new(position.bottom_center, 1, 1, border_width = 0)
if showId and barstate.islast
    table.cell(idTbl, 0, 0, "Self-Calibrating Probability Channel   /   " + syminfo.ticker + "   /   " + timeframe.period, text_color = cDim, text_size = size.small, text_halign = text.align_center, bgcolor = color.new(color.gray, 100))

// ──────────────────────────────── ALERTS ───────────────────────────────────
alertcondition(breachUp, "Positive anomaly (95% breach up)", "ConfChan: price breached the upper 95% prediction interval")
alertcondition(breachDn, "Negative anomaly (95% breach down)", "ConfChan: price breached the lower 95% prediction interval")
alertcondition(turbulent and not turbulent[1], "Turbulence warning", "ConfChan: breach clustering detected - coverage may degrade")
alertcondition(ready and not na(cov90) and cov90 < 80, "Coverage drift (90% under-covering)", "ConfChan: 90% band is under-covering — regime may be shifting")

// ─────────────────────────────── EXPORTS ───────────────────────────────────
plot(ready ? pred1 : na, "EXP_Forecast", color = color.new(color.gray, 100), display = display.data_window)
plot(ready ? hi90 : na, "EXP_Upper90", color = color.new(color.gray, 100), display = display.data_window)
plot(ready ? lo90 : na, "EXP_Lower90", color = color.new(color.gray, 100), display = display.data_window)
plot(cov90, "EXP_Coverage90", color = color.new(color.gray, 100), display = display.data_window)
plot(reliability, "EXP_Reliability", color = color.new(color.gray, 100), display = display.data_window)
plot(breachUp ? 1 : breachDn ? -1 : 0, "EXP_Breach", color = color.new(color.gray, 100), display = display.data_window)
plot(ready ? drift : na, "EXP_Drift", color = color.new(color.gray, 100), display = display.data_window)
plot(er, "EXP_Efficiency", color = color.new(color.gray, 100), display = display.data_window)
````
