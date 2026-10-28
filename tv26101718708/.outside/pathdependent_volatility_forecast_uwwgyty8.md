# Path-Dependent Volatility Forecast

- url: https://www.tradingview.com/script/uWWGYTY8-Path-Dependent-Volatility-Forecast/
- type: indicator
- pine_id: PUB;e1176bbb4418468984573b99415fe831
- version: 1.0

## Description

# Path-Dependent Volatility Forecast — Publication Description


### What it is

A self-calibrating forecaster of an instrument’s own **realised volatility**, built only from its price path. It estimates how large the next bar’s volatility is likely to be, explains *why* (which part of the price path is driving it), and shows *how well* that explanation is currently working on the symbol in front of you. It is **context for risk and regime awareness — not a buy/sell signal and not a strategy.** It plots in a sub-pane: a forecast line, the realised-vol line it tracks, regime shading, and a compact dashboard.

### The idea, in one paragraph

Volatility is largely **path-dependent**: an asset’s volatility is mostly explained by its own recent price path. Falling prices tend to lift volatility (the leverage effect), recent movement tends to persist (volatility clustering), and strong rallies add their own volatility. This script turns that idea into a working, per-instrument forecaster and then proves the fit on-chart.

### Why these components are combined (mashup justification)

This is **one model expressed as a single estimate → explain → calibrate → decompose → verify loop**, not a bundle of unrelated indicators stacked together. Each stage is necessary; remove any one and the result breaks:

1. **Realised-volatility estimator** (range-based Garman-Klass, or close-to-close) measures the ground-truth volatility the model is trying to explain. Without it there is nothing to fit to.
2. **Path features** are the model’s inputs: a *trend / leverage* feature (a weighted average of recent returns) and an *activity / churn* feature (the square root of a weighted average of recent squared returns), each built as a blend of fast, medium and slow kernels so it carries short **and** long memory; plus an **upside-convexity** term (so strong rallies add volatility) and a **persistence (memory)** term (a longer-horizon average of past realised vol). Features without calibration are unscaled noise.
3. **Rolling ridge calibration** fits the weights of `realised_vol ≈ b0 + b1·trend + b2·activity + b12·upside + b3·memory` to *this* instrument by rolling regression. The predictors are correlated, so the fit is **ridge-regularised on standardised predictors** to keep the coefficients steady. Calibration without features has nothing to fit; features without calibration cannot be put in the right units.
4. **Decomposition** splits the forecast into its drivers — **Path** (leverage / upside), **Activity** (churn), and **Memory** (persistence) — which is the interpretation the model makes possible.
5. **Live fit read-out** (rolling R² of forecast vs realised) is the proof the loop is working on the asset in front of you.

So the five parts are stages of a single pipeline: measure realised vol, explain it from the path, calibrate to the instrument, decompose it, and verify the fit — one engine, not five overlays.

### How it works (more detail)

- **Inputs are lagged one bar.** The path features are built from confirmed past returns, so each bar’s forecast is known before that bar’s own return forms — a genuine one-step-ahead forecast. Historical values do not change.
- **Kernels.** Each feature blends a fast, a medium and a slow-tail kernel. The slow tail approximates the heavy, slowly-decaying weighting that long-memory volatility requires; the fast kernel keeps it responsive.
- **Positivity.** The activity feature is floored to stay strictly positive, keeping the forecast well-defined.
- **Calibration.** A 4-predictor ridge regression is solved each bar over a rolling window via standardised correlation-matrix inversion, then mapped back to raw units. Ridge (a single, adjustable penalty) is what keeps the correlated predictors from producing erratic coefficients.

### How to read it

- **Bold line** = the model’s volatility **forecast**; **faint line** = the **realised** volatility it tracks. Close agreement = the model fits here.
- **Driver** tells you *why* volatility is where it is: **Path** (a falling path lifting vol = leverage/fear, or a strong rally = upside), **Activity** (recent churn persisting), or **Memory** (volatility coasting on its own persistence). The % is that channel’s share.
- **Model fit** is the rolling R² — how much of realised-vol variance the path explains on this symbol. Trust the forecast more when it is high; treat it cautiously when it reads “weak.”
- **Regime** (Low / Normal / High / Extreme) is the forecast’s own percentile. Rising vol from a Low regime is an expansion; this is context, not a trade call.
- **Markers:** ▲ red = a fear-driven spike; ◆ amber = a volatility expansion into the High regime.

A practical note: this forecasts the **size** of moves, not their **direction**. A high forecast says “expect bigger swings,” not “go long/short.” Typical uses are risk-management context (sizing, stop width), regime filtering (compressed Low regimes precede expansions; Extreme regimes tend to mean-revert), and options-style context (is volatility likely to rise or fade) — always as context layered on your own method.

### Universal data layer (works on any asset, any market)

The script reads the chart’s own symbol by default, so it runs on equities, futures, FX, crypto and indices with no configuration. Settings let you:

- choose the **price source** (close / hl2 / hlc3 / ohlc4),
- optionally compute the forecast on a **different symbol** than the one charted,
- optionally run on a **fixed calculation timeframe** for a stable basis,
- choose the realised-vol estimator (range-based or close-to-close) for symbols with or without usable ranges.

The dashboard theme is **adaptive**: it reads the chart background and keeps text and cells legible on dark or light colour schemes (or you can force Dark/Light).

### What makes it original

A working, per-instrument path-dependent **realised-volatility forecaster** with rolling ridge self-calibration, a three-way (Path / Activity / Memory) decomposition, and an on-chart fit score — a recent institutional volatility concept made legible and measurable on a chart, rather than an ATR or a standard-deviation band. It does not merely display a volatility statistic; it fits a small volatility model to the symbol and shows you both the forecast and how much to trust it.

### Limitations (honest)

- Volatility is forecastable but never certain. The realised-volatility research this builds on explains a **minority** of realised-vol variance even at its best, so a rolling fit in the 0.3–0.6 range is doing well, not failing.
- The forecast is a **reduced, practical form** of the underlying framework; it is meant as context, not a precise volatility product.
- The fit dips through structural breaks; the dashboard shows it (“weak”), which is itself useful information.
- An optional higher calculation timeframe than the chart can update intrabar until that bar closes; the default (chart timeframe) does not.

### Credits

The path-dependent volatility framework this script operationalises is from the academic work of **J. Guyon and J. Lekeufack, “Volatility is (mostly) path-dependent” (2023)**. The persistence/memory predictor follows the heterogeneous-autoregressive (HAR) realised-volatility approach of **F. Corsi (2009)**. The range-based realised-variance estimator is **Garman & Klass (1980)**. The activity-positivity treatment follows results by **Nutz & Riveros Valdevenito** and **Andrès & Jourdain**. This implementation, the rolling ridge self-calibration, the Path/Activity/Memory decomposition, and the on-chart fit score are the author’s own work.

### Disclaimer

This script is a study/indicator for chart analysis and education only. It is **not** a strategy, **not** a recommendation, and **not** financial advice. It places no orders and guarantees no outcome. All values are estimates derived from price and can be wrong, especially through structural breaks and on illiquid or low-history symbols. Markets carry risk; do your own research and manage your own risk.

## Source Code

````pine
//@version=6
// ============================================================================
//  PATH-DEPENDENT VOLATILITY FORECAST
// ----------------------------------------------------------------------------
//  WHAT IT IS
//    A self-calibrating forecaster of an instrument's own realised volatility,
//    built only from its price path. It estimates how large the next bar's
//    volatility is likely to be, explains WHICH part of the path is driving it,
//    and shows HOW WELL that explanation is currently working on this symbol.
//    Context for risk and regime awareness — NOT a buy/sell signal, NOT a
//    strategy. It plots a forecast line, the realised-vol line it tracks,
//    regime shading, and a compact dashboard.
//
//  THE IDEA
//    Volatility is largely path-dependent: an asset's volatility is mostly
//    explained by its own recent price path. Falling prices tend to lift
//    volatility (leverage effect), recent movement tends to persist (volatility
//    clustering), and strong rallies add their own volatility. This script
//    turns that into a working, per-instrument forecaster and proves the fit
//    on-chart.
//
//  WHY THESE COMPONENTS ARE COMBINED  (mashup rationale)
//    This is ONE model as a single estimate -> explain -> calibrate -> decompose
//    -> verify loop, not unrelated indicators stacked together. Each stage is
//    required; remove one and the result breaks:
//      1) REALISED-VOL ESTIMATOR (range-based Garman-Klass, or close-to-close)
//         measures the ground-truth volatility the model is fit to.
//      2) PATH FEATURES are the inputs: a trend/leverage feature (weighted recent
//         returns) and an activity/churn feature (sqrt of weighted recent squared
//         returns), each a fast+medium+slow-tail kernel blend (short AND long
//         memory), plus an upside-convexity term (rallies add vol) and a
//         persistence/memory term (a longer-horizon average of past realised vol).
//      3) ROLLING RIDGE CALIBRATION fits the weights of
//         realised_vol ~ b0 + b1*trend + b2*activity + b12*upside + b3*memory
//         to THIS instrument. The predictors are correlated, so the fit is
//         ridge-regularised on standardised predictors to keep coefficients steady.
//      4) DECOMPOSITION splits the forecast into Path / Activity / Memory drivers.
//      5) LIVE FIT READ-OUT (rolling R^2 of forecast vs realised) proves the loop
//         is working on the asset in front of you.
//    Features without calibration are unscaled; calibration without features has
//    nothing to fit; decomposition and fit are what make it legible and testable.
//
//  HOW TO READ
//    * Bold line = forecast vol; faint line = realised vol it tracks. Close = good.
//    * Driver = WHY vol is where it is: Path (leverage when falling / upside on
//      rallies), Activity (churn), or Memory (persistence). The % is that share.
//    * Model fit = rolling R^2: how much of realised-vol variance the path explains
//      here. Trust the forecast more when high; be cautious when it reads "weak".
//    * Regime (Low/Normal/High/Extreme) = the forecast's own percentile.
//    * Markers: red triangle = fear-driven spike; amber diamond = vol expansion.
//    It forecasts the SIZE of moves, not their DIRECTION. Use as risk/regime
//    context layered on your own method.
//
//  UNIVERSAL USE  (any asset, any market)
//    Reads the chart symbol by default. Settings allow a selectable price source,
//    an optional different data symbol, an optional fixed calculation timeframe,
//    and a choice of realised-vol estimator. The dashboard theme adapts to the
//    chart background so it stays legible on dark or light schemes.
//
//  ORIGINALITY
//    A working per-instrument path-dependent realised-volatility forecaster with
//    rolling ridge self-calibration, a three-way (Path/Activity/Memory)
//    decomposition, and an on-chart fit score — a recent institutional volatility
//    concept made measurable on a chart, not an ATR or std-dev band.
//
//  LIMITATIONS  (honest)
//    * Inputs are CONFIRMED past returns lagged one bar, so each bar's forecast is
//      known before that bar's own return — a genuine one-step forecast; history
//      does not change. * Volatility is forecastable but never certain; the
//      realised-vol literature explains a minority of realised-vol variance even
//      at its best, so a rolling fit of 0.3-0.6 is doing well, not failing.
//    * This is a reduced, practical form of the framework — context, not a precise
//      volatility product. The fit dips through structural breaks (shown as "weak").
//    * An optional higher calculation timeframe than the chart can update intrabar
//      until that bar closes; the default (chart timeframe) does not.
//
//  CREDITS  (authors of the underlying concepts)
//    Path-dependent volatility framework: J. Guyon & J. Lekeufack, "Volatility is
//    (mostly) path-dependent" (2023). Persistence/memory predictor: the HAR model,
//    F. Corsi (2009). Range-based realised variance: Garman & Klass (1980).
//    Activity-positivity treatment: results by Nutz & Riveros Valdevenito and by
//    Andres & Jourdain. The implementation, the rolling ridge self-calibration, the
//    Path/Activity/Memory decomposition and the on-chart fit score are the author's.
//
//  DISCLAIMER
//    Study / indicator for chart analysis and education only. NOT a strategy, NOT a
//    recommendation, NOT financial advice. It places no orders and guarantees no
//    outcome. All values are estimates from price and can be wrong, especially
//    through structural breaks and on illiquid or low-history symbols. Markets
//    carry risk; do your own research and manage your own risk.
// ============================================================================
indicator("Path-Dependent Volatility Forecast", "PathVol", overlay = false,
     max_labels_count = 100, max_lines_count = 50, max_bars_back = 1000)

// ============================================================================
//  1 · INPUTS
// ============================================================================
gData = "Data source"
srcType = input.string("close", "Price source", options = ["close", "hl2", "hlc3", "ohlc4"], group = gData, tooltip = "Which price series drives returns and the path features. The range-based realised-vol estimator always uses OHLC.")
dsSym   = input.symbol("", "Data symbol (blank = chart symbol)", group = gData, tooltip = "Optionally compute the forecast on a DIFFERENT instrument than the one charted (e.g. chart one asset, analyse another). Blank uses the chart symbol, so the script works on any asset out of the box.")
dsTF    = input.timeframe("", "Calculation timeframe (blank = chart)", group = gData, tooltip = "Optionally run the estimator on a fixed timeframe for a stable basis regardless of chart timeframe. Blank uses the chart timeframe. Note: a higher timeframe than the chart can update intrabar until that bar closes.")

gModel = "Model"
rvEst  = input.string("Range (Garman-Klass)", "Realised-vol estimator", options = ["Range (Garman-Klass)", "Close-to-close"], group = gModel, tooltip = "Ground-truth volatility the model is fit to. Range-based is more efficient; close-to-close is the fallback for synthetic or rangeless symbols.")
rvLen  = input.int(10, "Realised-vol window", minval = 2, maxval = 100, group = gModel, tooltip = "Bars used to measure current realised volatility.")
calLen = input.int(150, "Calibration window", minval = 20, maxval = 1000, group = gModel, tooltip = "Rolling window the model coefficients are fit over. Longer = steadier, slower to adapt.")
lambda = input.float(0.05, "Ridge (regularization)", minval = 0.0, maxval = 1.0, step = 0.01, group = gModel, tooltip = "Penalty on the standardised predictors. The path features are correlated; ridge keeps the fitted coefficients steady. 0.02-0.10 is sensible; 0 = ordinary least squares.")
harLen = input.int(22, "Persistence (memory) window", minval = 2, maxval = 200, group = gModel, tooltip = "Lookback for the volatility-persistence predictor — a longer-horizon average of past realised vol.")

gKern = "Kernels (advanced)"
len1f = input.int(10,  "Trend — fast length",   minval = 2,  group = gKern, tooltip = "Short-memory kernel of the trend/leverage feature.")
len1m = input.int(100, "Trend — medium length", minval = 5,  group = gKern, tooltip = "Medium-memory kernel of the trend feature.")
len1s = input.int(400, "Trend — slow tail",     minval = 20, group = gKern, tooltip = "Long-memory tail kernel (approximates a power-law weighting).")
len2f = input.int(5,   "Activity — fast length",   minval = 2,  group = gKern, tooltip = "Short-memory kernel of the activity/churn feature.")
len2m = input.int(50,  "Activity — medium length", minval = 5,  group = gKern, tooltip = "Medium-memory kernel of the activity feature.")
len2s = input.int(250, "Activity — slow tail",     minval = 20, group = gKern, tooltip = "Long-memory tail kernel of the activity feature.")
thF   = input.float(0.5,  "Fast-vs-slow weight", minval = 0.0, maxval = 1.0, step = 0.05, group = gKern, tooltip = "Balance between the fast kernel and the (medium+slow) part of each feature.")
tailW = input.float(0.35, "Long-tail weight",    minval = 0.0, maxval = 1.0, step = 0.05, group = gKern, tooltip = "Within the slow part, weight on the very-slow tail vs the medium kernel. Higher = heavier long memory.")

gDisp = "Display"
annual   = input.float(1.0, "Annualise (multiplier)", minval = 0.1, group = gDisp, tooltip = "Display multiplier on volatility. 1 = per-bar return %. Use sqrt(252) for daily bars, or sqrt(252*bars_per_day) intraday, for annualised %.")
regLen   = input.int(200, "Regime window", minval = 20, maxval = 1000, group = gDisp, tooltip = "Lookback for the Low/Normal/High/Extreme percentile.")
slopeLen = input.int(5, "Direction lookback", minval = 1, maxval = 50, group = gDisp)
showReal = input.bool(true, "Show realised-vol line", group = gDisp)
showFill = input.bool(true, "Shade forecast vs realised gap", group = gDisp)
showMarks= input.bool(true, "Mark fear spikes & expansions", group = gDisp)
showPanel= input.bool(true, "Show dashboard", group = gDisp)
dashPos  = input.string("Top Right", "Dashboard position", options = ["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group = gDisp)
showLeg  = input.bool(true, "Show how-to-read legend", group = gDisp)
legPos   = input.string("Top Left", "Legend position", options = ["Top Left", "Top Right", "Top Center", "Middle Left", "Middle Right", "Bottom Left", "Bottom Right"], group = gDisp)
themeOpt = input.string("Auto", "Theme", options = ["Auto", "Dark", "Light"], group = gDisp, tooltip = "Auto reads the chart background so the dashboard stays legible on any colour scheme. Force Dark/Light to override.")

// ============================================================================
//  2 · HELPERS
// ============================================================================
f_luma(color c) => 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
f_txtOn(color c) => f_luma(c) > 140 ? #0a0a0a : color.white
f_pos(string s) =>
    s == "Top Left" ? position.top_left : s == "Top Center" ? position.top_center : s == "Top Right" ? position.top_right : s == "Middle Left" ? position.middle_left : s == "Middle Right" ? position.middle_right : s == "Bottom Left" ? position.bottom_left : s == "Bottom Center" ? position.bottom_center : s == "Bottom Right" ? position.bottom_right : position.top_right

// ============================================================================
//  3 · ADAPTIVE THEME  (dashboard stays legible on any chart background)
// ============================================================================
bool  uiDark = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : f_luma(chart.bg_color) < 140
color cText  = uiDark ? color.white          : #0a0a0a
color cDim   = uiDark ? #9aa4b2              : #5b6470
color cCell  = uiDark ? color.new(#1c2230, 0): color.new(#eef1f6, 0)
color cFrame = uiDark ? color.new(color.white, 70) : color.new(color.black, 75)
color cBull  = uiDark ? #26c6a6 : #0e9e84
color cBear  = uiDark ? #ef5d6b : #d33646
color cWarn  = uiDark ? #f0b24a : #d68a17
color cReal  = color.new(color.gray, 25)
fSize = size.small                               // single uniform dashboard font

// ============================================================================
//  4 · DATA LAYER  (any symbol, any timeframe, selectable source)
// ============================================================================
bool useReq = dsSym != "" or dsTF != ""
string reqSym = dsSym == "" ? syminfo.tickerid  : dsSym
string reqTF  = dsTF  == "" ? timeframe.period   : dsTF
[ro, rh, rl, rc] = request.security(reqSym, reqTF, [open, high, low, close], lookahead = barmerge.lookahead_off)
float o_ = useReq ? ro : open
float h_ = useReq ? rh : high
float l_ = useReq ? rl : low
float c_ = useReq ? rc : close
float src = srcType == "hl2" ? (h_ + l_) / 2 : srcType == "hlc3" ? (h_ + l_ + c_) / 3 : srcType == "ohlc4" ? (o_ + h_ + l_ + c_) / 4 : c_

float r       = nz(math.log(src / src[1]))
float gkVar   = 0.5 * math.pow(math.log(h_ / l_), 2.0) - (2.0 * math.log(2.0) - 1.0) * math.pow(math.log(c_ / o_), 2.0)
float c2cVar  = r * r
bool  rangeOK = h_ > l_ and not na(o_) and o_ > 0
float varBar  = (rvEst == "Range (Garman-Klass)" and rangeOK) ? math.max(nz(gkVar), 0.0) : c2cVar
float rvVar   = ta.sma(varBar, rvLen)
float rv      = math.sqrt(math.max(nz(rvVar), 0.0))           // realised vol (per-bar return units)

// ============================================================================
//  5 · PATH FEATURES  (from CONFIRMED past returns — lagged one bar)
//      Each feature blends fast + medium + slow-tail kernels (short, medium and
//      long memory), approximating a power-law weighting of the price path.
// ============================================================================
float rLag  = nz(r[1])
float r2Lag = rLag * rLag

float e1f = ta.ema(rLag, len1f)
float e1m = ta.ema(rLag, len1m)
float e1s = ta.ema(rLag, len1s)
float R1  = thF * e1f + (1.0 - thF) * ((1.0 - tailW) * e1m + tailW * e1s)      // trend / leverage feature

float e2f = ta.ema(r2Lag, len2f)
float e2m = ta.ema(r2Lag, len2m)
float e2s = ta.ema(r2Lag, len2s)
float R2raw = thF * e2f + (1.0 - thF) * ((1.0 - tailW) * e2m + tailW * e2s)    // activity feature

float r2Floor = 0.05 * ta.sma(r2Lag, calLen)                                   // keep activity strictly positive
float sR2  = math.sqrt(math.max(R2raw, nz(r2Floor)))                           // sqrt(activity), bounded below
float Rcvx = R1 >= 0 ? R1 * R1 : 0.0                                           // upside-convexity term
float harLag = nz(ta.sma(rv, harLen)[1])                                       // volatility-persistence (memory) predictor

// ============================================================================
//  6 · SELF-CALIBRATION  —  ridge regression via matrix algebra
//      rv ~ b0 + b1*R1 + b2*sqrt(R2) + b12*Rcvx + b3*memory
//      Predictors standardised; ridge added on the correlation matrix; solved
//      with a 4x4 inverse, then mapped back to raw units.
// ============================================================================
float eps = 1e-12
float m0 = ta.sma(R1,     calLen)
float m1 = ta.sma(sR2,    calLen)
float m2 = ta.sma(Rcvx,   calLen)
float m3 = ta.sma(harLag, calLen)
float mY = ta.sma(rv,     calLen)

float S00 = ta.sma(R1 * R1,         calLen) - m0 * m0
float S11 = ta.sma(sR2 * sR2,       calLen) - m1 * m1
float S22 = ta.sma(Rcvx * Rcvx,     calLen) - m2 * m2
float S33 = ta.sma(harLag * harLag, calLen) - m3 * m3
float S01 = ta.sma(R1 * sR2,        calLen) - m0 * m1
float S02 = ta.sma(R1 * Rcvx,       calLen) - m0 * m2
float S03 = ta.sma(R1 * harLag,     calLen) - m0 * m3
float S12 = ta.sma(sR2 * Rcvx,      calLen) - m1 * m2
float S13 = ta.sma(sR2 * harLag,    calLen) - m1 * m3
float S23 = ta.sma(Rcvx * harLag,   calLen) - m2 * m3
float S0y = ta.sma(R1 * rv,         calLen) - m0 * mY
float S1y = ta.sma(sR2 * rv,        calLen) - m1 * mY
float S2y = ta.sma(Rcvx * rv,       calLen) - m2 * mY
float S3y = ta.sma(harLag * rv,     calLen) - m3 * mY

float s0 = math.sqrt(math.max(S00, eps))
float s1 = math.sqrt(math.max(S11, eps))
float s2 = math.sqrt(math.max(S22, eps))
float s3 = math.sqrt(math.max(S33, eps))

float b1 = 0.0, b2 = 0.0, b12 = 0.0, b3 = 0.0, b0 = 0.0
bool statsOK = not na(m0) and not na(m1) and not na(m2) and not na(m3) and not na(mY)
if statsOK
    matrix<float> C = matrix.new<float>(4, 4, 0.0)
    matrix.set(C, 0, 0, 1.0 + lambda), matrix.set(C, 1, 1, 1.0 + lambda)
    matrix.set(C, 2, 2, 1.0 + lambda), matrix.set(C, 3, 3, 1.0 + lambda)
    float c01 = S01 / (s0 * s1), c02 = S02 / (s0 * s2), c03 = S03 / (s0 * s3)
    float c12 = S12 / (s1 * s2), c13 = S13 / (s1 * s3), c23 = S23 / (s2 * s3)
    matrix.set(C, 0, 1, c01), matrix.set(C, 1, 0, c01)
    matrix.set(C, 0, 2, c02), matrix.set(C, 2, 0, c02)
    matrix.set(C, 0, 3, c03), matrix.set(C, 3, 0, c03)
    matrix.set(C, 1, 2, c12), matrix.set(C, 2, 1, c12)
    matrix.set(C, 1, 3, c13), matrix.set(C, 3, 1, c13)
    matrix.set(C, 2, 3, c23), matrix.set(C, 3, 2, c23)
    matrix<float> g = matrix.new<float>(4, 1, 0.0)
    matrix.set(g, 0, 0, S0y / s0), matrix.set(g, 1, 0, S1y / s1)
    matrix.set(g, 2, 0, S2y / s2), matrix.set(g, 3, 0, S3y / s3)
    matrix<float> Cinv = matrix.inv(C)
    if not na(Cinv) and not na(matrix.get(Cinv, 0, 0))
        matrix<float> bz = matrix.mult(Cinv, g)
        b1  := matrix.get(bz, 0, 0) / s0
        b2  := matrix.get(bz, 1, 0) / s1
        b12 := matrix.get(bz, 2, 0) / s2
        b3  := matrix.get(bz, 3, 0) / s3
        b0  := mY - b1 * m0 - b2 * m1 - b12 * m2 - b3 * m3

bool ready = bar_index > calLen + math.max(math.max(len1s, len2s), harLen)

// ============================================================================
//  7 · FORECAST + DECOMPOSITION  (three channels: Path / Activity / Memory)
// ============================================================================
float leverComp = b1 * R1                  // linear leverage (downside fear when R1 < 0)
float convComp  = b12 * Rcvx               // upside convexity (rally vol when R1 > 0)
float dirComp   = leverComp + convComp     // full path / direction channel
float churnComp = b2 * sR2                 // activity channel
float memComp   = b3 * harLag              // persistence channel
float pred = math.max(b0 + dirComp + churnComp + memComp, 0.0)

float aDir = math.abs(dirComp), aChu = math.abs(churnComp), aMem = math.abs(memComp)
float dyn  = aDir + aChu + aMem
float pathShare = dyn > 0 ? aDir / dyn * 100.0 : na
float actShare  = dyn > 0 ? aChu / dyn * 100.0 : na
float memShare  = dyn > 0 ? aMem / dyn * 100.0 : na
bool  pathDom = aDir >= aChu and aDir >= aMem
bool  actDom  = aChu >  aDir and aChu >= aMem
string driver = na(pathShare) ? "-" : pathDom ? "Path-driven" : actDom ? "Activity-driven" : "Memory-driven"
float domShare = na(pathShare) ? na : pathDom ? pathShare : actDom ? actShare : memShare

float predD = pred * annual * 100.0
float rvD   = rv   * annual * 100.0

// ============================================================================
//  8 · REGIME · DIRECTION · FIT · EVENTS
// ============================================================================
float pr = ta.percentrank(pred, regLen)
string volReg = not ready ? "warming up" : pr >= 90 ? "Extreme" : pr >= 65 ? "High" : pr >= 25 ? "Normal" : "Low"
color  regCol = pr >= 90 ? cBear : pr >= 65 ? cWarn : pr >= 25 ? cText : cBull
bool   rising = pred > pred[slopeLen]

float resid = rv - pred
float ssRes = ta.sma(resid * resid, calLen)
float ssTot = ta.sma(rv * rv, calLen) - mY * mY
float r2fit = ssTot > 1e-18 ? math.max(0.0, 1.0 - ssRes / ssTot) : na

string regWord = not ready ? "" : volReg == "Extreme" ? "stretched" : volReg == "High" ? "elevated" : volReg == "Normal" ? "typical" : "calm"
string drvWord = na(pathShare) ? "" : pathDom ? (leverComp >= convComp ? "leverage" : "upside") : actDom ? "churn" : "persistence"
string fitWord = na(r2fit) ? "" : r2fit >= 0.30 ? "reliable" : r2fit >= 0.10 ? "partial" : "weak"

bool fearSpike = ready and rising and leverComp > churnComp and leverComp > leverComp[1] and pr >= 60
bool expansion = ready and ta.crossover(pr, 65)
bool calBreak  = ready and not na(r2fit) and r2fit < 0.10

// ============================================================================
//  9 · PLOTS
// ============================================================================
plot(ready and showReal ? rvD : na, "Realised vol", color = cReal, linewidth = 1)
pPred = plot(ready ? predD : na, "Forecast vol", color = color.new(regCol, 0), linewidth = 2)
pReal2 = plot(ready and showFill ? rvD : na, "", color = color.new(color.gray, 100), display = display.none)
fill(pPred, pReal2, color = showFill ? color.new(regCol, 88) : na)

plotshape(showMarks and fearSpike ? predD : na, "Fear spike", shape.triangleup, location.absolute, color = color.new(cBear, 0), size = size.small)
plotshape(showMarks and expansion ? predD : na, "Vol expansion", shape.diamond, location.absolute, color = color.new(cWarn, 0), size = size.small)
bgcolor(ready ? color.new(regCol, 92) : na, title = "Regime tint")

// ============================================================================
//  10 · DATA-WINDOW EXPORTS
// ============================================================================
plot(predD,            "Forecast vol",      display = display.data_window)
plot(rvD,              "Realised vol",      display = display.data_window)
plot(R1,               "Trend feature",     display = display.data_window)
plot(sR2,              "Activity feature",  display = display.data_window)
plot(harLag,           "Memory feature",    display = display.data_window)
plot(pathShare,        "Path share %",      display = display.data_window)
plot(actShare,         "Activity share %",  display = display.data_window)
plot(memShare,         "Memory share %",    display = display.data_window)
plot(b1,               "Coeff leverage",    display = display.data_window)
plot(b12,              "Coeff upside",      display = display.data_window)
plot(b2,               "Coeff activity",    display = display.data_window)
plot(b3,               "Coeff memory",      display = display.data_window)
plot(na(r2fit) ? na : r2fit * 100.0, "Model fit %", display = display.data_window)
plot(pr,               "Regime percentile", display = display.data_window)

// ============================================================================
//  11 · ALERTS
// ============================================================================
alertcondition(expansion, "Volatility expansion", "PathVol: volatility expanding (entered High regime)")
alertcondition(fearSpike, "Fear-driven vol spike", "PathVol: fear-driven volatility spike (falling path lifting vol)")
alertcondition(ready and ta.crossover(pr, 90), "Extreme volatility", "PathVol: forecast volatility entered Extreme regime")
alertcondition(calBreak, "Model fit broke down", "PathVol: model fit low — path no longer explains vol (possible regime break)")

// ============================================================================
//  12 · DASHBOARD  (uniform font · adaptive colours · self-interpreting)
// ============================================================================
var table dash = na
var table leg  = na
f_drow(int row, string k, string v, color vcol) =>
    table.cell(dash, 0, row, k, text_color = cDim,  text_size = fSize, text_halign = text.align_left,  bgcolor = cCell)
    table.cell(dash, 1, row, v, text_color = vcol,  text_size = fSize, text_halign = text.align_right, bgcolor = cCell)

if barstate.islast and showPanel
    if na(dash)
        dash := table.new(f_pos(dashPos), 2, 7, border_width = 0, frame_width = 1, frame_color = cFrame)
    color hdr = color.new(regCol, 0)
    table.cell(dash, 0, 0, "PATH-DEPENDENT VOL", text_color = f_txtOn(hdr), bgcolor = hdr, text_size = fSize)
    table.cell(dash, 1, 0, rising ? "RISING" : "FALLING", text_color = f_txtOn(hdr), bgcolor = hdr, text_size = fSize)
    f_drow(1, "Forecast vol", str.tostring(predD, "#.###") + (annual == 1.0 ? " %/bar" : " %"), cText)
    f_drow(2, "Realised vol", str.tostring(rvD, "#.###"), cText)
    f_drow(3, "Regime", not ready ? "warming up" : (volReg + " " + str.tostring(math.round(pr)) + "% · " + regWord), color.new(regCol, 0))
    f_drow(4, "Driver", na(domShare) ? "-" : (driver + " " + str.tostring(math.round(domShare)) + "% · " + drvWord), cText)
    f_drow(5, "Model fit", na(r2fit) ? "-" : (str.tostring(math.round(r2fit * 100)) + "% · " + fitWord), na(r2fit) ? cDim : (r2fit >= 0.3 ? cBull : r2fit >= 0.1 ? cWarn : cBear))
    f_drow(6, "Coeffs l/u/a/m", str.tostring(b1, "#.##") + "/" + str.tostring(b12, "#.##") + "/" + str.tostring(b2, "#.##") + "/" + str.tostring(b3, "#.##"), cText)

// ---- how-to-read legend ----
f_lrow(int row, string a, color ac, string b) =>
    table.cell(leg, 0, row, a, text_color = ac,   text_size = fSize, bgcolor = cCell)
    table.cell(leg, 1, row, b, text_color = cDim, text_size = fSize, bgcolor = cCell)
if barstate.islast and showLeg
    if na(leg)
        leg := table.new(f_pos(legPos), 2, 7, border_width = 0, frame_width = 1, frame_color = cFrame)
    table.cell(leg, 0, 0, "HOW TO READ", text_color = cText, text_size = fSize, bgcolor = cCell)
    table.cell(leg, 1, 0, "", bgcolor = cCell)
    f_lrow(1, "▲ red",     cBear, "fear-driven vol spike")
    f_lrow(2, "◆ amber",   cWarn, "volatility expansion")
    f_lrow(3, "bold line", cText, "forecast vol (regime-coloured)")
    f_lrow(4, "faint line",cReal, "realised vol (what it tracks)")
    f_lrow(5, "shading",   cDim,  "forecast vs realised gap")
    f_lrow(6, "background",cDim,  "regime: calm → extreme")
````
