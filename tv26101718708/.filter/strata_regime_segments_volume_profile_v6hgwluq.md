# Strata - Regime Segments & Volume Profile

- url: https://www.tradingview.com/script/v6HGWluQ/
- type: indicator
- pine_id: PUB;4be54195592345bab598f4fc71f2f075
- version: 8.0

## Description

This indicator segments price with a model-based online change detector, classifies every segment into a six-cell regime grid, and renders for each segment an exact regression line, a sigma channel, and a slanted volume profile. One standard runs everything: the segment is the state — there is no second bar-by-bar machine, no smoothing triggers, no dwell locks. The CUSUM cut threshold is the only persistence mechanism.

Detection. A Kalman local linear trend filter estimates a drifting level and a drifting slope, so a steady trend is what the model expects and trend drift is not mistaken for structural change. Each bar the filter emits the one-step innovation, standardized by its own recursively estimated variance. A two-sided CUSUM watches the standardized innovation mean; when it crosses the threshold the trend has structurally changed and a segment is cut, backdated to where the winning CUSUM run started, so the boundary lands where the change began rather than where it was detected. Cuts that would close a segment shorter than the minimum length are discarded and merged, so tiny fragments cannot exist. After an accepted cut the Kalman covariance is briefly inflated for faster re-adaptation. A second CUSUM on the innovation dispersion always runs and fires an alert on volatility shifts; a switch lets it cut segments too. The threshold h is derived from the data by default: you state the average segment length you want, and a feedback controller nudges h bar by bar until the realized average matches it — the panel shows the current h and the realized length so you can watch it converge. A fixed-h mode remains available; with the standard allowance k = 0.5, h = 4 corresponds to an average false-alarm interval of roughly 168 bars and h = 5 to roughly 465.

Classification. Direction is the segment's OLS slope per bar in units of the segment's mean daily sigma; below the dead zone in magnitude the segment is flat, so a violent sideways stretch is not forced into a bullish or bearish color. Tempo is the segment's mean volatility percentile against one threshold. The grid is direction times tempo: Up, Flat, Down crossed with Calm and Hot, six cells. Finalized segments get their one-shot call at the cut; the active segment is classified from its own tentative regression from birth, and the call may drift while the segment is young — that is accepted by design, since tentative regressions are tentative. A dashed vertical divider is drawn at every backdated cut and is the one authoritative boundary marker: between two dividers there is exactly one segment — one regression line, one profile, one state label. Labels and flat-state strokes adapt to the chart theme so they stay visible on light and dark backgrounds.

Volume profile. Volume is binned in residual space — by distance from the segment's regression line — and drawn as parallelogram bars running parallel to the channel, anchored to the segment's right edge and growing leftward, so a profile always butts against its own boundary. Bin width follows the Freedman–Diaconis rule with volume-weighted quantiles and the Kish effective sample size, with a fixed-bin fallback. The point of control and a seventy percent value area are drawn parallel to the fit. Profile bars use a direction-only palette, green up, red down, grey flat, with adjustable opacity. Segments too short to support a meaningful distribution simply skip the profile, and older segments are demoted to line plus POC to respect drawing limits.

Gauges. Pressure reads how close the active segment's readings sit to their classification boundaries, plus CUSUM cut progress when it opposes the current direction, normalized to a percentage with the implied target state. It is a gauge, not a calibrated probability — it catches gradual drifts only, and a cut can fire and reclassify from zero pressure. Hist. next reports the empirical next-state distribution from this chart's own transition history; the sample count is shown and should be read. Hidden data-window plots expose State, Direction, Tempo, and state age for use in the Pine Screener, and alerts cover segment cuts, volatility shifts, state changes, and every direction or tempo transition.

Scope. All decisions run on confirmed bars only: nothing repaints, finalized drawings are created once and never moved, and the active segment is the only mutable object. This is an online, causal detector — detection delay is irreducible for any causal method, and globally optimal offline methods such as PELT place breakpoints more accurately in hindsight. Treat segments, states, and gauges as context, not trade signals. The detection core is shared with the companion indicator "Strata Core"; keep the constants in sync if you run both. The presentation concept — per-segment regression channels and a trend-slanted volume profile — is inspired by "Dual Log Regression Channels" by BigBeluga and "Volume Cluster Profile (VCP)" by Zeiierman; the detection, classification, and estimation pipeline is an independent implementation of the methods below. Methods follow standard results in filtering, change-point detection, and density estimation (Kalman 1960; Harvey 1989; Page 1954; Moustakides 1986; Hinkley 1971; Lorden 1971; Mehra and Peschon 1971; Severo and Gama 2010; RiskMetrics 1996; Freedman and Diaconis 1981; Kish 1965; Maheu and McCurdy 2000; Ang and Timmermann 2012; Pagan and Sossounov 2003).

## Source Code

````pine
//@version=6
// =============================================================================
// Strata — Regime Segments & Volume Profile (single standard)
//
// ONE standard for states: the segment IS the state. Every bar belongs to a
// segment (changepoint to changepoint); the segment's own OLS regression
// classifies it into the six-cell grid. Finalized segments get their one-shot
// call at the cut; the ACTIVE segment is classified from its own tentative
// regression from birth -- the call may drift while the segment is young, and
// that is accepted by design (tentative regressions are tentative). No second
// bar-by-bar machine, no Schmitt triggers, no dwell locks: the BOCPD
// changepoint is the one and only segmentation mechanism.
//
// SIX-CELL GRID (direction x tempo)   [Maheu & McCurdy 2000; Ang & Timmermann 2012]
//                 calm (low vol)   hot (high vol)
//   up            Up-Calm          Up-Hot
//   flat/range    Flat-Calm        Flat-Hot
//   down          Down-Calm        Down-Hot
//   Cell ids: 0 Down-Calm, 1 Down-Hot, 2 Flat-Calm, 3 Flat-Hot, 4 Up-Calm, 5 Up-Hot.
//
// CLASSIFICATION (same function for finalized and active segments):
//   direction: segment OLS slope per bar in units of the segment's MEAN daily
//              innovation sigma; |reading| below the dead zone => FLAT.
//   tempo:     segment mean of the innovation-vol percentile vs one threshold.
//
// PIPELINE
//   1. Kalman local linear trend whitens price [Harvey 1989]; innovations
//      standardized by EWMA variance [RiskMetrics].
//   2. Bayesian Online Changepoint Detection on the standardized innovation
//      [Adams & MacKay 2007]: a truncated run-length posterior with a
//      Normal-Inverse-Gamma / Student-t predictive is updated each bar. A
//      changepoint fires when the MAP run length COLLAPSES (it climbed above a
//      floor, then dropped to near zero) -- the reliable BOCPD signal, since
//      P(changepoint) is structurally pinned near the hazard. The cut is
//      BACKDATED by the MAP run length. Short segments merge; covariance is
//      inflated after cuts [Severo & Gama 2010]. Detection delay is irreducible.
//   3. Per segment: exact OLS line, sigma channel, slanted volume profile in
//      residual space (Freedman-Diaconis bins, volume-weighted quantiles,
//      Kish effective n) [F&D 1981; Kish 1965]. VP bars anchor to the
//      segment's right edge and use a direction-only palette: green up /
//      red down / grey flat. POC and a shaded value area run parallel to the
//      fit; coverage is configurable -- the 70% Market Profile convention
//      rounds the Gaussian one-sigma 68.27%. Too-short segments skip the
//      profile. The active segment carries tentative versions of all three,
//      one shade lighter, redrawn at each close.
//   4. Trend-reality tests decide whether a directional segment is a real
//      trend or a random walk, by two independent checks that must BOTH pass:
//      the Lo-MacKinlay variance ratio [Lo & MacKinlay 1988] for directional
//      persistence, and a constant+trend Augmented Dickey-Fuller unit-root
//      test [Dickey & Fuller 1979; MacKinnon 1996], solved by normal
//      equations via matrix.inv. State labels carry a "V_A_" badge (+ pass,
//      - fail, ? too short); confirmed real trends (V+A+) draw a solid
//      regression line, everything else dotted. Toggle off to fall back to a
//      slope-t rule. Direction stays with Dir; these tests only judge realness.
//
// BOUNDARY CONVENTION: a dashed vertical divider is drawn at every backdated
// cut -- the one authoritative segment-boundary marker. Between two dividers
// there is exactly one segment: one regression, one profile, one state label.
//
// FORECAST AIDS (gauges, NOT calibrated probabilities)
//   * Pressure: how close the active segment's readings sit to their
//     classification boundaries; 0-100% with the implied target state.
//     Catches drifts only; a changepoint can fire and reclassify without warning.
//   * Hist. next: empirical 6x6 transition counts over this chart's history;
//     small-sample marginal -- read the n.
//
// ROUTING DOCTRINE (context for the strategy-router thread; long-only).
// NOTE: the router must adopt THIS segment standard as its state source.
//   Up-Calm   -> Accumulate            (thickest evidence: TSMOM / MA timing)
//   Up-Hot    -> Accumulate x0.5       (never fade; new money halved
//                                       [Moreira & Muir 2017; Barroso & Santa-Clara 2015])
//   Flat-Calm -> Mean reversion        (core thesis; upward tilt required)
//   Flat-Hot  -> Mean reversion x0.5   (thinnest evidence)
//   Down-Calm -> Cash (defend)         (falsified for longs, 2327 history)
//   Down-Hot  -> Cash (defend)         (crash cell; the consensus cell)
//   Sleeves separated by order IDs (MR round trips vs ACC never-sell core);
//   down-state kills MR only. Tilt = direction reading beyond a small dead
//   band inside flat cells.
//
// NON-REPAINT: decisions on confirmed bars only; finalized drawings never
// move; the active segment (regression, profile, state) is the only mutable
// object -- its call may drift while young, by design. Detection constants
// are duplicated in the sibling "Strata Core" script; keep them in sync
// manually.
//
// PINE SCREENER (per the official help-center article "TradingView Pine
// Screener: key features and requirements"):
//   * Plots feed the screener as filters AND sortable table columns; the
//     FIRST TEN plots are auto-added as the default filter/column set, and
//     the FIRST TWO alertconditions are auto-added as ready-made filters --
//     so plots and alertconditions below are declared in priority order.
//   * The screener computes on only the LAST 500 BARS. Path-dependent
//     outputs -- segment boundaries, the adaptive h, the transition matrix,
//     and therefore State -- can differ from a chart loaded with longer
//     history. For closer chart/screener agreement prefer fixed h (auto
//     OFF); treat Hist-next columns as near-empty there (few transitions
//     fit in 500 bars).
//   * One-bar events (cut, vol shift) are easy to miss because scans are
//     manual snapshots; the bars-since columns are the robust way to filter
//     recency ("<= 3" style).
//   * Supported screener timeframes: 1/5/15/30m, 1/2/4h, 1D, 1W, 1M; inputs
//     stay adjustable in the screener's settings dialog.
//
// Presentation lineage: per-segment regression channels are inspired by
// "Dual Log Regression Channels" by BigBeluga; the slanted, trend-relative
// volume profile is inspired by "Volume Cluster Profile (VCP)" by Zeiierman.
// Detection, classification, and estimation are an independent implementation
// of the methods cited above.
// =============================================================================
indicator("Strata - Regime Segments & Volume Profile", "Strata",
     overlay = true, max_lines_count = 500, max_labels_count = 500, max_polylines_count = 100)

// ---------------------------------------------------------------- inputs ---
grpM = "Detection model"
src        = input.source(close, "Source", group = grpM)
qLevel     = input.float(0.05,  "Level noise ratio Q_level/R", minval = 0.00001, step = 0.01, group = grpM)
qSlope     = input.float(0.005, "Slope noise ratio Q_slope/R", minval = 0.000001, step = 0.001, group = grpM)
ewmaLambda = input.float(0.97,  "EWMA variance memory (lambda)", minval = 0.8, maxval = 0.999, step = 0.005, group = grpM)
warmupBars = input.int(30, "Warm-up bars", minval = 10, group = grpM)

grpC = "BOCPD segmentation"
bocpdHaz  = input.int(100, "Hazard: prior mean regime length (bars)", minval = 5, group = grpC,
     tooltip = "Constant hazard H = 1/this. Smaller = expects frequent regime changes = more sensitive. The main sensitivity dial. Validated default 100.")
bocpdRMax = input.int(150, "Max run length (truncation)", minval = 10, maxval = 400, group = grpC,
     tooltip = "The run-length distribution is capped here so per-bar cost is fixed. 100-200 typical.")
bocpdK0   = input.float(0.1, "Prior kappa0 (lower = more adaptive)", minval = 0.01, step = 0.05, group = grpC,
     tooltip = "Normal-Inverse-Gamma prior strength on the mean. Low = a new regime's mean is learned fast, so changes are detected sooner. Validated at 0.1.")
bocpdA0   = input.float(0.5, "Prior alpha0", minval = 0.1, step = 0.1, group = grpC)
bocpdB0   = input.float(0.5, "Prior beta0", minval = 0.1, step = 0.1, group = grpC)
mapCollapseFrom = input.int(15, "Changepoint: MAP run length was above", minval = 5, group = grpC,
     tooltip = "Detection rule (validated in Python): a changepoint fires when the MAP run length COLLAPSES -- it was above this value and drops below the level below. The MAP-collapse signal is the real BOCPD changepoint indicator; P(changepoint) is structurally pinned near the hazard and is NOT used.")
mapCollapseTo   = input.int(5, "Changepoint: MAP run length dropped below", minval = 1, group = grpC)
targetSeg  = input.int(30, "Target average segment length (bars)", minval = 5, group = grpC,
     tooltip = "Used by downstream projection and robustness scaling only; BOCPD does not use it to detect.")
minSegLen  = input.int(15, "Minimum segment length (bars)", minval = 3, group = grpC,
     tooltip = "Any cut whose closed segment is shorter than this is discarded and merged into its neighbor -- no orphan tiny segments.")
covInflate = input.float(5.0, "Covariance inflation after a cut", minval = 1.0, step = 1.0, group = grpC)


grpTR = "Trend-reality tests (variance ratio + ADF)"
useTrendReality = input.bool(true, "Require both tests to pass for a significant trend", group = grpTR,
     tooltip = "When ON, a directional segment is 'significant' (solid line, no ns) only if BOTH the Lo-MacKinlay variance-ratio z is significant AND the constant+trend Augmented Dickey-Fuller test rejects a unit root. This replaces the old slope-t significance rule with a doctrine that directly tests 'trend vs random walk' rather than 'is the slope non-zero'. Direction is still set by Dir; these tests only decide whether the structure is real. Heavier to compute than the slope-t (ADF solves normal equations via matrix.inv on every segment) -- if the script times out on long histories or large watchlists, turn this OFF to fall back to the slope-t rule, or lower the ADF max lag below.")
vrHorizon = input.int(4, "Variance-ratio horizon q (bars)", minval = 2, maxval = 20, group = grpTR,
     tooltip = "Aggregation horizon for the variance ratio. VR(q) compares q-period return variance to q times the 1-period variance; q around 2-5 captures short-horizon persistence. Automatically capped at half the segment length.")
adfMaxLag = input.int(3, "ADF max lag order (0 = plain DF)", minval = 0, maxval = 8, group = grpTR,
     tooltip = "Cap on the number of lagged-difference terms in the ADF regression (Schwert's rule sets the data-driven value, this caps it). Higher = better serial-correlation control but a larger matrix to invert per segment and more compute. 0 turns the augmented terms off entirely (plain constant+trend Dickey-Fuller), the cheapest and most robust to matrix ill-conditioning; raise only if you suspect residual autocorrelation survives the Kalman whitening.")

grpSt = "State classification (one standard for all segments)"
dirDZ  = input.float(0.03, "Flat dead zone (slope, sigma/bar)", minval = 0.0, step = 0.005, group = grpSt,
     tooltip = "Segment OLS slope per bar / segment mean daily sigma. Below this magnitude the segment is FLAT. ~0.03 is roughly +/-15%/yr at 2% daily sigma.")
hotPct = input.float(50, "Hot threshold (vol percentile)", minval = 0, maxval = 100, group = grpSt,
     tooltip = "Segment mean vol percentile at/above = HOT.")
volLen = input.int(250, "Vol percentile lookback (bars)", minval = 50, group = grpSt)
showSegLabels = input.bool(true, "Label each finalized segment's state", group = grpSt)
showSigMark = input.bool(true, "Mark non-significant trend calls", group = grpSt,
     tooltip = "Marks directional (Up/Down) segments that are NOT confirmed as real trends. The badge after the state name reads two tests: V is the Lo-MacKinlay variance ratio, A is the constant+trend Augmented Dickey-Fuller test. '+' = passed, '-' = failed, '?' = segment too short to test (below max(minSegLen, 20) bars). A segment is a confirmed real trend only at 'V+A+', drawn with a SOLID regression line; anything else is drawn DOTTED. When the trend-reality toggle is OFF, this falls back to the older slope-t >= 2 rule with an '(ns)' suffix. Flat segments are never marked -- a flat call claims no trend. The active (forming) segment carries a live version of the badge with a trailing '*', which is tentative and can change as the segment grows. Hover a state label for the exact test values.")

grpD = "Display"
chWidth      = input.float(2.0, "Channel width (sigma)", minval = 0.5, step = 0.5, group = grpD)
maxProfiles  = input.int(12, "Segments keeping a full profile", minval = 1, maxval = 40, group = grpD)
binMode      = input.string("Auto (Freedman-Diaconis)", "Bin count mode", options = ["Auto (Freedman-Diaconis)", "Fixed"], group = grpD)
binWidthScale = input.float(0.25, "Auto bin-width scale (lower = finer)", minval = 0.1, maxval = 2.0, step = 0.05, group = grpD)
maxBins      = input.int(80, "Profile bins (cap in auto mode)", minval = 6, maxval = 100, group = grpD)
profWidthFrac = input.float(0.30, "Max profile width (fraction of segment)", minval = 0.05, maxval = 1.0, step = 0.05, group = grpD)
allocMode    = input.string("Close only", "Volume allocation", options = ["Close only", "Spread over H-L"], group = grpD)
vaPct        = input.float(70, "Value area coverage (%)", minval = 30, maxval = 95, step = 0.01, group = grpD,
     tooltip = "Expanded from the POC until this share of the segment's volume is covered. 70 is the CBOT / Steidlmayer Market Profile convention, itself a rounding of the Gaussian one-sigma 68.27%; profiles are rarely Gaussian, so treat it as a convention, not a law. Our residual-space binning removes the trend first, so the one-sigma reading is more defensible here than in classic price-space profiles.")
vpLineTr     = input.int(35, "VP line transparency", minval = 0, maxval = 90, group = grpD)
vpFillTr     = input.int(60, "VP fill transparency", minval = 0, maxval = 95, group = grpD,
     tooltip = "The tentative profile of the active segment renders 15 points lighter than these.")
showActiveReg     = input.bool(true, "Tentative regression of the active segment", group = grpD)
showActiveProfile = input.bool(true, "Tentative profile of the active segment", group = grpD)
showProjection    = input.bool(true, "Project POC / value area to estimated next cut", group = grpD,
     tooltip = "Grey dashed extensions of the tentative POC and value-area bounds, out to the target segment length ahead -- the memoryless benchmark of geometric regime durations [Hamilton 1989]. A gauge, not a promise: changepoints can arrive without warning and are backdated when they do.")
showKalman   = input.bool(false, "Kalman level (diagnostic)", group = grpD)
showDividers = input.bool(true,  "Segment divider lines (vertical at each cut)", group = grpD,
     tooltip = "A vertical line at every cut point makes segment boundaries unambiguous -- count them to count segments, and see which segment a profile belongs to, regardless of same-color backgrounds.")
maxDrawBars  = input.int(500, "Max draw lookback (bars)", minval = 100, maxval = 5000, group = grpD,
     tooltip = "Regression/channel lines are clamped to start at most this many bars back, so a long segment's line never trails far off to the left. Purely cosmetic; classification is unaffected.")
showTable    = input.bool(false, "Status table", group = grpD)
cUpCalm   = input.color(#1b5e20, "Up-Calm",   inline = "c1", group = grpD)
cUpHot    = input.color(#00e676, "Up-Hot",    inline = "c1", group = grpD)
cFlatCalm = input.color(#b2b5be, "Flat-Calm", inline = "c2", group = grpD)
cFlatHot  = input.color(#ffffff, "Flat-Hot",  inline = "c2", group = grpD)
cDnCalm   = input.color(#7f1d1d, "Down-Calm", inline = "c3", group = grpD)
cDnHot    = input.color(#ff1744, "Down-Hot",  inline = "c3", group = grpD)
cVpUp     = input.color(#089981, "VP up",   inline = "c4", group = grpD)
cVpDn     = input.color(#f23645, "VP down", inline = "c4", group = grpD)
cVpFlat   = input.color(#787b86, "VP flat", inline = "c4", group = grpD)

// ----------------------------------------------------------- shared state ---
var float kLevel   = na
var float kSlope   = 0.0
var float p11      = 1.0
var float p12      = 0.0
var float p22      = 1.0
var float innovVar = na
// BOCPD state: run-length distribution R and Normal-Inverse-Gamma sufficient
// stats per run length (mu, kappa, alpha, beta). Truncated at bocpdRMax. The
// changepoint signal is the MAP run length COLLAPSING (not P(cp), which is
// structurally pinned near the hazard). Validated in Python before porting.
var array<float> bR   = array.new_float(1, 1.0)
var array<float> bMu  = array.new_float(1, 0.0)
var array<float> bKap = array.new_float(1, 1.0)
var array<float> bAlp = array.new_float(1, 1.0)
var array<float> bBet = array.new_float(1, 1.0)
var int recentMaxRL = 0
var int scrMapRL = 0   // exposed MAP run length for screener/table
var float activeConf = na   // active-segment confidence 0-100 (posterior concentration + distance from collapse)

// Adaptive-h controller state: h is nudged so the running mean of accepted
// segment lengths tracks the target. EWMA of realized lengths avoids storing
// every segment.

// Active-segment buffers; index 0 = first bar of the active segment.
var segSrc   = array.new_float()
var segVol   = array.new_float()
var segHigh  = array.new_float()
var segLow   = array.new_float()
var segSigma = array.new_float()   // per-bar daily innovation sigma
var segPct   = array.new_float()   // per-bar vol percentile
var int   segStartBar = na
var float sumY   = 0.0   // O(1) OLS running sums
var float sumXY  = 0.0
var float sumY2  = 0.0
var float sumSig = 0.0   // running sums for classification
var float sumPct = 0.0

// Drawing objects and budgets
var line activeRegLine     = na
var label activeStateLabel = na   // live tentative state + badge at the forming edge
var line activeUpLine      = na
var line activeDnLine      = na
var polyline activeProfile = na
var line activePocLine     = na
var line activeVahLine     = na
var line activeValLine     = na
var line extPocLine        = na
var line extVahLine        = na
var line extValLine        = na
var auxLineQueue     = array.new_line()       // 4 per finalized segment
var profilePolyQueue = array.new<polyline>()  // 1 per finalized segment

// Per-bar event flags and current readings
bool cutEvent      = false
var float activeSlope     = na
var float activeIntercept = na
var int   activeBars      = na
var float activeMeanSig   = na
var float activeMeanPct   = na
var float activeResStd    = na   // active-segment residual std, for the live label
var int   state           = 2   // THE state: the active segment's call

// ------------------------------------------------------ state helpers ------
stateName(int id) =>
    switch id
        0 => "Down-Calm"
        1 => "Down-Hot"
        2 => "Flat-Calm"
        3 => "Flat-Hot"
        4 => "Up-Calm"
        5 => "Up-Hot"
        => "?"

stateColor(int id) =>
    switch id
        0 => cDnCalm
        1 => cDnHot
        2 => cFlatCalm
        3 => cFlatHot
        4 => cUpCalm
        5 => cUpHot
        => color.gray

// Flat states are near-white; use black text on them.
stateText(int id) =>
    id == 2 or id == 3 ? color.black : color.white

// Stroke palette for line drawings: flat states use the theme foreground
// color (black on light themes, white on dark) so they stay visible.
stateStroke(int id) =>
    id == 2 ? color.new(chart.fg_color, 35) : id == 3 ? chart.fg_color : stateColor(id)

// Direction-only palette for volume-profile bars: green up, red down, grey flat.
vpColor(int id) =>
    id >= 4 ? cVpUp : id <= 1 ? cVpDn : cVpFlat

// Log-gamma via Lanczos approximation (Pine has no math.lgamma). Accurate to
// ~1e-10 for z >= 0.5, which covers all our alpha and df/2 values.
lgammaApprox(float z) =>
    float x = z
    float ser = 1.0 + 76.18009172947146 / (x + 1.0) - 86.50532032941677 / (x + 2.0) + 24.01409824083091 / (x + 3.0) - 1.231739572450155 / (x + 4.0) + 0.001208650973866179 / (x + 5.0) - 0.000005395239384953 / (x + 6.0)
    float tmp = x + 5.5 - (x + 0.5) * math.log(x + 5.5)
    -tmp + math.log(2.5066282746310005 * ser / x)

// THE classifier -- one standard for finalized and active segments.
classify(float slopePerBar, float meanSigma, float meanPct) =>
    int dir = meanSigma > 0 and slopePerBar > dirDZ * meanSigma ? 1 :
              meanSigma > 0 and slopePerBar < -dirDZ * meanSigma ? -1 : 0
    int tempo = meanPct >= hotPct ? 1 : 0
    (dir + 1) * 2 + tempo

// ============================ TREND-REALITY TESTS ============================
// Two independent answers to "is this segment a real trend or just a random
// walk?", combined by AND (both must pass) to drive the ns marks.
//
//  * Lo-MacKinlay variance ratio [Lo & MacKinlay 1988, Rev. Fin. Stud.]:
//    under a random walk, Var(q-period return) = q * Var(1-period return), so
//    VR(q) = 1. VR > 1 with a significant heteroskedasticity-robust z (the
//    z* / M2 statistic) means genuine directional persistence (momentum),
//    VR < 1 mean reversion. z ~ N(0,1), threshold |z| >= 1.96 (5%).
//
//  * Augmented Dickey-Fuller, constant + trend [Dickey & Fuller 1979;
//    Said & Dickey 1984; MacKinnon 1996]: regress d(y)_t on [1, t, y_{t-1},
//    d(y)_{t-1..p}] and read the t-stat on the y_{t-1} coefficient. More
//    negative than the (negative) critical value => reject the unit root =>
//    trend-stationary. Full augmented version (lagged differences absorb
//    serial correlation) solved by the normal equations b = (X'X)^-1 X'y via
//    matrix.inv. Critical values from MacKinnon's response surface
//    CV = a_inf + a1/N + a2/N^2 (constant+trend specification). Lag order by
//    Schwert: p = floor(12 * (N/100)^0.25), capped to keep X'X well posed.
//
// Both live on the SELECTED segment, so absolute levels carry the same
// post-selection optimism as any statistic measured on a changepoint-cut segment;
// use them to compare across symbols, not as calibrated p-values.

// Heteroskedasticity-robust variance-ratio z (Lo-MacKinlay M2). prices = the
// segment's level series; q = aggregation horizon. Returns [vr, z].
lmVarRatioZ(array<float> prices, int q) =>
    int n = array.size(prices)
    float vr = na
    float z  = na
    if n > q + 1 and q >= 2
        // one-period log-ish returns (simple diffs of level; scale-free in z)
        rets = array.new_float()
        for i = 1 to n - 1
            array.push(rets, array.get(prices, i) - array.get(prices, i - 1))
        int m = array.size(rets)
        float mu = 0.0
        for i = 0 to m - 1
            mu += array.get(rets, i)
        mu := mu / m
        // 1-period variance
        float var1 = 0.0
        for i = 0 to m - 1
            var1 += math.pow(array.get(rets, i) - mu, 2)
        var1 := var1 / m
        // q-period variance via overlapping sums, unbiased Lo-MacKinlay scaling
        float sq = 0.0
        int cnt = 0
        for i = q - 1 to m - 1
            float acc = 0.0
            for j = 0 to q - 1
                acc += array.get(rets, i - j)
            sq += math.pow(acc - q * mu, 2)
            cnt += 1
        float varq = cnt > 0 ? sq / (cnt * q) : na
        if not na(varq) and var1 > 0
            vr := varq / var1
            // heteroskedasticity-robust variance of VR (Lo-MacKinlay 1988, M2):
            // sum over lags j=1..q-1 of (2(q-j)/q)^2 * delta_j
            float phi = 0.0
            for jj = 1 to q - 1
                float num = 0.0
                float den = 0.0
                for i = jj to m - 1
                    float a = math.pow(array.get(rets, i) - mu, 2)
                    float b = math.pow(array.get(rets, i - jj) - mu, 2)
                    num += a * b
                den := math.pow(var1, 2) * m
                float deltaj = den > 0 ? num / den : 0.0
                phi += math.pow(2.0 * (q - jj) / q, 2) * deltaj
            float se = phi > 0 ? math.sqrt(phi / m) : na
            z := not na(se) and se > 0 ? (vr - 1.0) / se : na
    [vr, z]

// Augmented Dickey-Fuller t-stat on the y_{t-1} coefficient, constant+trend,
// p lagged differences, solved by normal equations with matrix.inv. Returns
// [adfStat, cv5] where cv5 is the MacKinnon 5% critical value for this N.
adfTrendStat(array<float> prices, int pLag) =>
    int n = array.size(prices)
    float adf = na
    float cv5 = na
    // need enough rows after differencing and lagging for the parameters
    int kParams = 3 + pLag          // const, trend, y_{t-1}, p lagged diffs
    int firstT  = pLag + 1          // first usable t index for d(y)
    int rows    = n - firstT
    if rows >= kParams + 2 and pLag >= 0
        // Build design matrix X (rows x kParams) and response Yv (rows x 1).
        matrix<float> X  = matrix.new<float>(rows, kParams, 0.0)
        matrix<float> Yv = matrix.new<float>(rows, 1, 0.0)
        int r = 0
        for t = firstT to n - 1
            float dy = array.get(prices, t) - array.get(prices, t - 1)
            matrix.set(Yv, r, 0, dy)
            matrix.set(X, r, 0, 1.0)                       // constant
            matrix.set(X, r, 1, float(t))                  // linear trend
            matrix.set(X, r, 2, array.get(prices, t - 1))  // y_{t-1} (the test regressor)
            // Guard the lag loop: in v6 `for 1 to 0` runs backwards instead of
            // not at all, so an explicit pLag>=1 check is required or it writes
            // out-of-bounds columns when pLag == 0 (plain Dickey-Fuller).
            if pLag >= 1
                for L = 1 to pLag
                    float dyl = array.get(prices, t - L) - array.get(prices, t - L - 1)
                    matrix.set(X, r, 2 + L, dyl)
            r += 1
        matrix<float> Xt   = matrix.transpose(X)
        matrix<float> XtX  = matrix.mult(Xt, X)
        // Guard against a near-singular normal-matrix (collinear lags): if the
        // determinant is ~0, bail out (na) so the AND-gate treats it as "not
        // confirmed" -- the conservative choice.
        float detXtX = matrix.det(XtX)
        if math.abs(detXtX) > 1e-12
            matrix<float> XtXi = matrix.inv(XtX)
            matrix<float> XtY  = matrix.mult(Xt, Yv)
            matrix<float> beta = matrix.mult(XtXi, XtY)
            // residual variance s^2 = RSS / (rows - kParams)
            matrix<float> fitted = matrix.mult(X, beta)
            float rss = 0.0
            for i = 0 to rows - 1
                rss += math.pow(matrix.get(Yv, i, 0) - matrix.get(fitted, i, 0), 2)
            int df = rows - kParams
            float s2 = df > 0 ? rss / df : na
            // SE(beta_2) = sqrt(s^2 * (X'X)^-1_[2,2]); ADF stat = beta_2 / SE
            float v22 = matrix.get(XtXi, 2, 2)
            float seB = not na(s2) and s2 > 0 and v22 > 0 ? math.sqrt(s2 * v22) : na
            adf := not na(seB) and seB > 0 ? matrix.get(beta, 2, 0) / seB : na
        // MacKinnon (1996) response surface, constant+trend, 5% level:
        // CV = a_inf + a1/N + a2/N^2
        float N = float(rows)
        cv5 := -3.4126 + (-4.039) / N + (-17.83) / (N * N)
    [adf, cv5]

// Combined trend-reality verdict for a segment. Returns [vr, vrZ, adf, adfCv,
// realTrend] where realTrend = both tests pass (VR momentum significant AND
// unit root rejected). Direction is NOT judged here -- Dir handles that.
trendReality(array<float> prices) =>
    int n = array.size(prices)
    int q = math.max(2, math.min(vrHorizon, int(n / 2)))
    [vr, vrZ] = lmVarRatioZ(prices, q)
    int pLag = math.min(adfMaxLag, math.max(0, int(math.floor(12.0 * math.pow(n / 100.0, 0.25))) - 9))
    [adf, adfCv] = adfTrendStat(prices, pLag)
    bool vrPass  = not na(vrZ) and math.abs(vrZ) >= 1.96
    bool adfPass = not na(adf) and not na(adfCv) and adf <= adfCv
    bool realTrend = vrPass and adfPass
    [vr, vrZ, adf, adfCv, realTrend]

// Compact badge for a directional segment. "V+A-" = variance ratio passed (+),
// ADF failed (-). "V?A?" = segment too short to test (below the bar floor).
// Uses + / - / ? (not glyphs) so every platform renders it. Empty for flat
// states. tested=false forces both to "?" regardless of the pass flags.
trendBadge(int st, bool tested, bool vrPass, bool adfPass) =>
    not (st >= 4 or st <= 1) ? "" :
     not tested ? " V?A?" :
     " V" + (vrPass ? "+" : "-") + "A" + (adfPass ? "+" : "-")

// Innovation vol as % of price, ranked against its own history.
// ta.* calls must run unconditionally on every bar.
float dailySigma = not na(innovVar) ? math.sqrt(math.max(innovVar, 0.0)) : na
float dailyVolPc = not na(dailySigma) and close > 0 ? dailySigma / close * 100.0 : na
float volPctA    = ta.percentrank(dailyVolPc, volLen)

// ---- Freedman-Diaconis bin count on volume-weighted residuals --------------
fdBinCount(array<float> closes, array<float> vols, float intercept, float slope, int count, float span, float scale, int cap) =>
    int bins = cap
    res = array.new_float()
    wts = array.new_float()
    float sw  = 0.0
    float sw2 = 0.0
    for i = 0 to count - 1
        float w = array.get(vols, i)
        if w > 0
            array.push(res, array.get(closes, i) - (intercept + slope * i))
            array.push(wts, w)
            sw  += w
            sw2 += w * w
    int nRes = array.size(res)
    if nRes >= 8 and sw2 > 0
        order = array.sort_indices(res)
        float q1 = na
        float q3 = na
        float cw = 0.0
        for j = 0 to nRes - 1
            int k = array.get(order, j)
            cw += array.get(wts, k)
            if na(q1) and cw >= 0.25 * sw
                q1 := array.get(res, k)
            if na(q3) and cw >= 0.75 * sw
                q3 := array.get(res, k)
        float iqr  = nz(q3) - nz(q1)
        float nEff = sw * sw / sw2
        if iqr > 0 and nEff > 0 and span > 0
            float hFD = 2.0 * iqr * math.pow(nEff, -1.0 / 3.0) * scale
            bins := int(math.ceil(span / hFD))
            bins := math.min(math.max(bins, 4), cap)
    bins

// ------------------------------------------------------------- main loop ---
if barstate.isconfirmed
    if na(segStartBar)
        segStartBar := bar_index
        kLevel := src

    // Kalman predict/update: F = [[1,1],[0,1]], H = [1,0], R = 1.
    float predLevel = kLevel + kSlope
    float p11p = p11 + 2.0 * p12 + p22 + qLevel
    float p12p = p12 + p22
    float p22p = p22 + qSlope
    float innov = src - predLevel
    float sPred = p11p + 1.0
    float g1    = p11p / sPred
    float g2    = p12p / sPred
    kLevel := predLevel + g1 * innov
    kSlope := kSlope + g2 * innov
    p11 := (1.0 - g1) * p11p
    p12 := (1.0 - g1) * p12p
    p22 := p22p - g2 * p12p

    innovVar := na(innovVar) ? innov * innov : ewmaLambda * innovVar + (1.0 - ewmaLambda) * innov * innov
    float z = innovVar > 0 ? innov / math.sqrt(innovVar) : 0.0


    // Append the bar to the active segment (running sums stay O(1) per bar).
    int xRel = array.size(segSrc)
    array.push(segSrc, src)
    array.push(segVol, nz(volume))
    array.push(segHigh, high)
    array.push(segLow, low)
    float sigNow = math.sqrt(math.max(innovVar, 0.0))
    float pctNow = nz(volPctA, 50.0)
    array.push(segSigma, sigNow)
    array.push(segPct, pctNow)
    sumY   += src
    sumXY  += xRel * src
    sumY2  += src * src
    sumSig += sigNow
    sumPct += pctNow

    if bar_index >= warmupBars
        // ---- BOCPD recursion (Adams & MacKay 2007), Normal-Inverse-Gamma /
        // Student-t predictive. The observation is the standardized innovation z.
        // Changepoint = MAP run length COLLAPSE (validated in Python); P(cp) is
        // structurally ~hazard and unused. Truncated at bocpdRMax.
        float bH = 1.0 / bocpdHaz
        int L = array.size(bR)
        // predictive (Student-t) per run length, then growth + changepoint mass
        array<float> nR = array.new_float(L + 1, 0.0)
        float cpMass = 0.0
        for r = 0 to L - 1
            float pr = array.get(bR, r)
            float mu = array.get(bMu, r)
            float ka = array.get(bKap, r)
            float al = array.get(bAlp, r)
            float be = array.get(bBet, r)
            float df = 2.0 * al
            float scale2 = be * (ka + 1.0) / (al * ka)
            float zt = (z - mu) * (z - mu) / scale2
            float logp = lgammaApprox((df + 1.0) / 2.0) - lgammaApprox(df / 2.0) - 0.5 * math.log(df * math.pi * scale2) - (df + 1.0) / 2.0 * math.log(1.0 + zt / df)
            float pred = math.exp(logp)
            float evid = pr * pred
            array.set(nR, r + 1, evid * (1.0 - bH))
            cpMass += evid * bH
        array.set(nR, 0, cpMass)
        float tot = array.sum(nR)
        if tot > 0.0
            for r = 0 to L
                array.set(nR, r, array.get(nR, r) / tot)
        // NIG updates: run length 0 = prior; r+1 = update(r, z)
        array<float> nMu  = array.new_float(L + 1, 0.0)
        array<float> nKap = array.new_float(L + 1, 0.0)
        array<float> nAlp = array.new_float(L + 1, 0.0)
        array<float> nBet = array.new_float(L + 1, 0.0)
        array.set(nMu, 0, 0.0)
        array.set(nKap, 0, bocpdK0)
        array.set(nAlp, 0, bocpdA0)
        array.set(nBet, 0, bocpdB0)
        for r = 0 to L - 1
            float mu = array.get(bMu, r)
            float ka = array.get(bKap, r)
            float al = array.get(bAlp, r)
            float be = array.get(bBet, r)
            array.set(nKap, r + 1, ka + 1.0)
            array.set(nMu,  r + 1, (ka * mu + z) / (ka + 1.0))
            array.set(nAlp, r + 1, al + 0.5)
            array.set(nBet, r + 1, be + (ka * (z - mu) * (z - mu)) / (2.0 * (ka + 1.0)))
        // truncate to bocpdRMax + 1 entries (drop the oldest run lengths)
        bR   := nR
        bMu  := nMu
        bKap := nKap
        bAlp := nAlp
        bBet := nBet
        while array.size(bR) > bocpdRMax + 1
            array.pop(bR)
            array.pop(bMu)
            array.pop(bKap)
            array.pop(bAlp)
            array.pop(bBet)
        // MAP run length = argmax of the distribution
        int sz = array.size(bR)
        int mapRL = 0
        float bestP = -1.0
        for r = 0 to sz - 1
            float pr = array.get(bR, r)
            if pr > bestP
                bestP := pr
                mapRL := r
        // Track the running max MAP run length; a changepoint is a COLLAPSE:
        // recentMax climbed above `from`, and MAP has now dropped below `to`.
        // (Order matters: update max, THEN test collapse, THEN reset below.)
        recentMaxRL := math.max(recentMaxRL, mapRL)
        bool collapse = recentMaxRL > mapCollapseFrom and mapRL < mapCollapseTo
        scrMapRL := mapRL

        // Active-segment confidence (0-100): how much to trust the CURRENT
        // segmentation right now. Two ingredients, both from the run-length
        // posterior. (a) CONCENTRATION -- bestP (the MAP bin's probability)
        // relative to a diffuse baseline: when mass concentrates on one run
        // length the model is sure which regime we are in; when it spreads,
        // it is not. Scaled by sqrt(size) so a naturally wider posterior on a
        // long segment is not penalized. (b) DISTANCE FROM COLLAPSE -- if MAP
        // has slipped from its recent peak toward the collapse floor, a
        // changepoint may be near and the current call is fragile, so confidence
        // is discounted. Product of the two, as a percentage.
        float concentration = math.min(1.0, bestP * math.sqrt(math.max(sz, 1)))
        float slip = recentMaxRL > mapCollapseFrom ? math.max(0.0, math.min(1.0, (float(mapRL) - mapCollapseTo) / math.max(1.0, float(recentMaxRL) - mapCollapseTo))) : 1.0
        activeConf := 100.0 * concentration * slip

        if collapse
            int cutBar = math.max(segStartBar + 1, bar_index - mapRL)  // backdate via MAP
            int closedLen = cutBar - segStartBar
            recentMaxRL := 0

            if closedLen >= minSegLen
                cutEvent := true
                // Robustness: how closely do the three CUSUMs' most-recent cut
                // bars agree? Spread of {main, low-h, high-h} cut positions,
                // scaled by target length -> 0..100 (100 = identical = stable).
                if showDividers
                    line.new(cutBar, high, cutBar, low, xloc = xloc.bar_index, extend = extend.both,
                         color = color.new(chart.fg_color, 40), style = line.style_dashed, width = 1)
                int n = closedLen

                // Adaptive-h feedback: update the realized-length EWMA and push
                // h up when segments run short of target, down when they run long.

                // Exact OLS over the closed segment; classification sums ride along.
                float sy   = 0.0
                float sxy  = 0.0
                float sy2  = 0.0
                float sSig = 0.0
                float sPct = 0.0
                for i = 0 to n - 1
                    float y = array.get(segSrc, i)
                    sy   += y
                    sxy  += i * y
                    sy2  += y * y
                    sSig += array.get(segSigma, i)
                    sPct += array.get(segPct, i)
                float fn        = n
                float sx        = fn * (fn - 1.0) / 2.0
                float sx2       = (fn - 1.0) * fn * (2.0 * fn - 1.0) / 6.0
                float det       = fn * sx2 - sx * sx
                float slope     = det != 0 ? (fn * sxy - sx * sy) / det : 0.0
                float intercept = (sy - slope * sx) / fn
                float sse       = sy2 - intercept * sy - slope * sxy
                float resStd    = math.sqrt(math.max(sse, 0.0) / fn)

                int   segState  = classify(slope, sSig / fn, sPct / fn)  // one-shot final call
                // Trend significance of the closed segment vs random-walk noise
                // (same statistic as the Trend t-stat plot; see its comment).
                float segMeanSig = sSig / fn
                float segT  = segMeanSig > 0 ? slope / segMeanSig * math.sqrt(fn / 1.2) : na
                // Trend-reality: variance ratio + ADF, both must pass (see the
                // trendReality function). Toggle off => fall back to the old
                // slope-t >= 2 rule. The 20-bar floor applies to both paths.
                int   minTrendBars = math.max(minSegLen, 20)
                bool  segLenOk = n >= minTrendBars
                [_, segVrZ, segAdf, segAdfCv, segReal] = trendReality(segSrc)
                bool  segTrendOk = useTrendReality ? (segLenOk and segReal) : (segLenOk and not na(segT) and math.abs(segT) >= 2)
                bool  segNs = showSigMark and (segState >= 4 or segState <= 1) and not segTrendOk
                color segColor  = stateColor(segState)   // fills: label pill
                color segStroke = stateStroke(segState)  // strokes: regression line, channel
                color segVpCol  = vpColor(segState)      // VP bars: direction only

                int   xLeft  = math.max(segStartBar, bar_index - maxDrawBars)  // drawing-range guard
                int   xRight = cutBar - 1
                float yLeft  = intercept + slope * (xLeft - segStartBar)
                float yRight = intercept + slope * (n - 1)

                line.new(xLeft, yLeft, xRight, yRight, color = segStroke, width = 2,
                     style = segNs ? line.style_dotted : line.style_solid)  // kept; platform auto-GC; dotted = trend not significant
                line upChLine = line.new(xLeft, yLeft + chWidth * resStd, xRight, yRight + chWidth * resStd,
                     color = color.new(segStroke, 60), style = line.style_dashed)
                line dnChLine = line.new(xLeft, yLeft - chWidth * resStd, xRight, yRight - chWidth * resStd,
                     color = color.new(segStroke, 60), style = line.style_dashed)
                if showSegLabels
                    color pillCol = segState == 2 or segState == 3 ? chart.fg_color : segColor
                    color pillTxt = segState == 2 or segState == 3 ? chart.bg_color : color.white
                    string segTip = str.tostring(n) + " bars" +
                         (segState >= 4 or segState <= 1 ?
                          (not segLenOk ? " -- too few bars (need " + str.tostring(minTrendBars) + ")" :
                           useTrendReality ?
                             " | VR z=" + (na(segVrZ) ? "na" : str.tostring(segVrZ, "#.##")) + (not na(segVrZ) and math.abs(segVrZ) >= 1.96 ? " ok" : " x") +
                             " | ADF=" + (na(segAdf) ? "na" : str.tostring(segAdf, "#.##")) + "/cv" + (na(segAdfCv) ? "" : str.tostring(segAdfCv, "#.#")) + (not na(segAdf) and not na(segAdfCv) and segAdf <= segAdfCv ? " ok" : " x") +
                             (segReal ? " -- REAL trend (both pass)" : " -- not confirmed (a test failed)") :
                             " | slope-t=" + (na(segT) ? "na" : str.tostring(segT, "#.##")) + (math.abs(nz(segT)) >= 2 ? " significant" : " not significant")) :
                          " -- flat call: no trend claimed")
                    bool segVrPass  = not na(segVrZ) and math.abs(segVrZ) >= 1.96
                    bool segAdfPass = not na(segAdf) and not na(segAdfCv) and segAdf <= segAdfCv
                    string segSuffix = not showSigMark or not (segState >= 4 or segState <= 1) ? "" :
                         useTrendReality ? trendBadge(segState, segLenOk, segVrPass, segAdfPass) :
                         (segNs ? " (ns)" : "")
                    label.new(xRight, yRight + chWidth * resStd, stateName(segState) + segSuffix,
                         style = label.style_label_down, color = color.new(pillCol, 20),
                         textcolor = pillTxt, size = size.small, tooltip = segTip)

                // Volume profile in residual space (distance from the fit).
                float resMin = na
                float resMax = na
                float totVol = 0.0
                for i = 0 to n - 1
                    float fit = intercept + slope * i
                    float rLo = array.get(segLow, i) - fit
                    float rHi = array.get(segHigh, i) - fit
                    resMin := na(resMin) ? rLo : math.min(resMin, rLo)
                    resMax := na(resMax) ? rHi : math.max(resMax, rHi)
                    totVol += array.get(segVol, i)

                polyline profilePoly = na
                line vahLine = na
                line valLine = na
                if totVol > 0 and resMax > resMin
                    int useBins = binMode == "Fixed" ? maxBins : fdBinCount(segSrc, segVol, intercept, slope, n, resMax - resMin, binWidthScale, maxBins)
                    float binH = (resMax - resMin) / useBins
                    binVol = array.new_float(useBins, 0.0)
                    for i = 0 to n - 1
                        float fit = intercept + slope * i
                        float rLo = array.get(segLow, i) - fit
                        float rHi = array.get(segHigh, i) - fit
                        float vol = array.get(segVol, i)
                        if vol > 0
                            if allocMode == "Close only"
                                float rCl = array.get(segSrc, i) - fit
                                int b = math.min(useBins - 1, math.max(0, int(math.floor((rCl - resMin) / binH))))
                                array.set(binVol, b, array.get(binVol, b) + vol)
                            else if rHi <= rLo
                                int b = math.min(useBins - 1, math.max(0, int(math.floor((rLo - resMin) / binH))))
                                array.set(binVol, b, array.get(binVol, b) + vol)
                            else
                                int b0 = math.min(useBins - 1, math.max(0, int(math.floor((rLo - resMin) / binH))))
                                int b1 = math.min(useBins - 1, math.max(0, int(math.floor((rHi - resMin) / binH - 1e-9))))
                                if b1 < b0
                                    b1 := b0
                                for b = b0 to b1
                                    float top = resMin + (b + 1) * binH
                                    float bot = resMin + b * binH
                                    float ov  = math.min(rHi, top) - math.max(rLo, bot)
                                    if ov > 0
                                        array.set(binVol, b, array.get(binVol, b) + vol * ov / (rHi - rLo))
                    // Point of control.
                    int   pocBin = 0
                    float maxVol = 0.0
                    for b = 0 to useBins - 1
                        if array.get(binVol, b) > maxVol
                            maxVol := array.get(binVol, b)
                            pocBin := b
                    // Value area: expand from POC toward the larger neighbor.
                    float vaTarget = vaPct / 100.0 * totVol
                    float vaCum    = array.get(binVol, pocBin)
                    int   vaLo     = pocBin
                    int   vaHi     = pocBin
                    while vaCum < vaTarget and (vaLo > 0 or vaHi < useBins - 1)
                        float below = vaLo > 0 ? array.get(binVol, vaLo - 1) : -1.0
                        float above = vaHi < useBins - 1 ? array.get(binVol, vaHi + 1) : -1.0
                        if above >= below
                            vaHi += 1
                            vaCum += math.max(above, 0.0)
                        else
                            vaLo -= 1
                            vaCum += math.max(below, 0.0)
                    // Slanted parallelogram histogram: one polyline per segment.
                    // Bars anchor to the RIGHT edge (the cut) and grow leftward, so a
                    // profile always butts against its own segment's end boundary.
                    float fitAtRight = intercept + slope * (xRight - segStartBar)
                    float fitAtLeft  = intercept + slope * (xLeft - segStartBar)  // POC/VA lines span the full segment width
                    int   histMaxBars = math.max(1, int(math.round(n * profWidthFrac)))
                    histPts = array.new<chart.point>()
                    if maxVol > 0
                        for b = 0 to useBins - 1
                            float v = array.get(binVol, b)
                            if v > 0
                                int w = math.max(1, int(math.round(histMaxBars * v / maxVol)))
                                w := math.min(w, xRight - xLeft)
                                float yBot = fitAtRight + resMin + b * binH
                                float yTop = yBot + binH
                                array.push(histPts, chart.point.from_index(xRight, yBot))
                                array.push(histPts, chart.point.from_index(xRight - w, yBot - slope * w))
                                array.push(histPts, chart.point.from_index(xRight - w, yTop - slope * w))
                                array.push(histPts, chart.point.from_index(xRight, yTop))
                    if array.size(histPts) > 0
                        profilePoly := polyline.new(histPts, closed = false,
                             line_color = color.new(segVpCol, vpLineTr), fill_color = color.new(segVpCol, vpFillTr), line_width = 1)
                    // POC and value-area lines run parallel to the regression.
                    float dx   = xRight - xLeft
                    float rPoc = resMin + (pocBin + 0.5) * binH
                    line.new(xLeft, fitAtLeft + rPoc, xRight, fitAtLeft + rPoc + slope * dx,
                         color = color.orange, width = 2)  // kept; platform auto-GC
                    float rVah = resMin + (vaHi + 1) * binH
                    float rVal = resMin + vaLo * binH
                    vahLine := line.new(xLeft, fitAtLeft + rVah, xRight, fitAtLeft + rVah + slope * dx,
                         color = color.new(color.orange, 35), style = line.style_dotted)
                    valLine := line.new(xLeft, fitAtLeft + rVal, xRight, fitAtLeft + rVal + slope * dx,
                         color = color.new(color.orange, 35), style = line.style_dotted)
                    linefill.new(vahLine, valLine, color.new(color.orange, 90))  // shaded value area; deleted with its lines

                // Demote old segments to regression line + POC only.
                array.push(profilePolyQueue, profilePoly)
                array.push(auxLineQueue, upChLine)
                array.push(auxLineQueue, dnChLine)
                array.push(auxLineQueue, vahLine)
                array.push(auxLineQueue, valLine)
                while array.size(profilePolyQueue) > maxProfiles
                    polyline oldPoly = array.shift(profilePolyQueue)
                    if not na(oldPoly)
                        polyline.delete(oldPoly)
                    for i = 1 to 4
                        line oldLine = array.shift(auxLineQueue)
                        if not na(oldLine)
                            line.delete(oldLine)

                // Carry the tail (bars after the backdated cut) into a new active segment.
                int total = array.size(segSrc)
                tailSrc  = array.new_float()
                tailVol  = array.new_float()
                tailHigh = array.new_float()
                tailLow  = array.new_float()
                tailSig  = array.new_float()
                tailPct  = array.new_float()
                for i = n to total - 1
                    array.push(tailSrc, array.get(segSrc, i))
                    array.push(tailVol, array.get(segVol, i))
                    array.push(tailHigh, array.get(segHigh, i))
                    array.push(tailLow, array.get(segLow, i))
                    array.push(tailSig, array.get(segSigma, i))
                    array.push(tailPct, array.get(segPct, i))
                segSrc   := tailSrc
                segVol   := tailVol
                segHigh  := tailHigh
                segLow   := tailLow
                segSigma := tailSig
                segPct   := tailPct
                segStartBar := cutBar
                sumY   := 0.0
                sumXY  := 0.0
                sumY2  := 0.0
                sumSig := 0.0
                sumPct := 0.0
                int carried = array.size(segSrc)
                for i = 0 to carried - 1
                    float y = array.get(segSrc, i)
                    sumY   += y
                    sumXY  += i * y
                    sumY2  += y * y
                    sumSig += array.get(segSigma, i)
                    sumPct += array.get(segPct, i)

                // Drop the stale tentative drawings of the previous active segment.
                polyline.delete(activeProfile)
                activeProfile := na
                line.delete(activePocLine)
                activePocLine := na
                line.delete(activeVahLine)
                activeVahLine := na
                line.delete(activeValLine)
                activeValLine := na
                line.delete(extPocLine)
                extPocLine := na
                line.delete(extVahLine)
                extVahLine := na
                line.delete(extValLine)
                extValLine := na
                label.delete(activeStateLabel)
                activeStateLabel := na

                // Adaptive feedback: inflate uncertainty for faster re-adaptation.
                p11 := p11 * covInflate
                p22 := p22 * covInflate

    // Tentative OLS + THE state, from the active segment's own regression.
    // A newborn segment classifies from its own fit immediately; the call may
    // drift while the segment grows -- accepted by design.
    int nAct = array.size(segSrc)
    activeBars := nAct
    if nAct >= 2
        float fn   = nAct
        float sx   = fn * (fn - 1.0) / 2.0
        float sx2  = (fn - 1.0) * fn * (2.0 * fn - 1.0) / 6.0
        float det  = fn * sx2 - sx * sx
        float aSlope     = det != 0 ? (fn * sumXY - sx * sumY) / det : 0.0
        float aIntercept = (sumY - aSlope * sx) / fn
        float aSse       = sumY2 - aIntercept * sumY - aSlope * sumXY
        float aResStd    = math.sqrt(math.max(aSse, 0.0) / fn)
        activeResStd    := aResStd
        activeSlope     := aSlope
        activeIntercept := aIntercept
        activeMeanSig   := sumSig / fn
        activeMeanPct   := sumPct / fn
        state           := classify(aSlope, activeMeanSig, activeMeanPct)
        // Tentative significance of the active trend: the regression line
        // renders dotted while a directional call has |t| < 2 vs random-walk
        // noise (same statistic as the Trend t-stat plot, updated per close).
        float aT  = activeMeanSig > 0 ? aSlope / activeMeanSig * math.sqrt(fn / 1.2) : na
        bool  aLenOk = nAct >= math.max(minSegLen, 20)   // same length floor as finalized segments
        // Trend-reality for the active segment. The full test is heavy, so it
        // is evaluated only on the last (forming) bar; on historical bars the
        // active line uses the cheap slope-t proxy for its dotted/solid state
        // (it will be re-judged properly when the segment finalizes anyway).
        // Active-segment trend-reality verdict, used HERE only to set the
        // regression line's dotted/solid state on the last confirmed bar. This
        // is intentionally a SEPARATE call from the global screener/label one
        // below (see "scrVrZ") -- they live in different scopes: this block is
        // gated by barstate.isconfirmed (does not run on the realtime forming
        // bar), the global one runs on the forming bar. Merging them would
        // force the last-bar regression line onto the cheaper slope-t proxy,
        // losing strict double-confirmation on that line. Kept for rigor; the
        // extra ADF solve fires on one bar only, not every bar.
        bool aRealTrend = false
        if useTrendReality and aLenOk and barstate.islast
            [_, _, _, _, aR] = trendReality(segSrc)
            aRealTrend := aR
        bool aTrendOk = useTrendReality ? (aLenOk and (barstate.islast ? aRealTrend : (not na(aT) and math.abs(aT) >= 2))) : (aLenOk and not na(aT) and math.abs(aT) >= 2)
        bool aNs = showSigMark and (state >= 4 or state <= 1) and not aTrendOk
        if showActiveReg
            int   aLeft   = math.max(segStartBar, bar_index - maxDrawBars)
            float aYLeft  = aIntercept + aSlope * (aLeft - segStartBar)
            float aYRight = aIntercept + aSlope * (nAct - 1)
            color cMain = color.new(stateStroke(state), 45)
            color cBand = color.new(stateStroke(state), 78)
            if na(activeRegLine)
                activeRegLine := line.new(aLeft, aYLeft, bar_index, aYRight, color = cMain, width = 2,
                     style = aNs ? line.style_dotted : line.style_solid)
                activeUpLine  := line.new(aLeft, aYLeft + chWidth * aResStd, bar_index, aYRight + chWidth * aResStd, color = cBand, style = line.style_dashed)
                activeDnLine  := line.new(aLeft, aYLeft - chWidth * aResStd, bar_index, aYRight - chWidth * aResStd, color = cBand, style = line.style_dashed)
            else
                line.set_xy1(activeRegLine, aLeft, aYLeft)
                line.set_xy2(activeRegLine, bar_index, aYRight)
                line.set_color(activeRegLine, cMain)
                line.set_style(activeRegLine, aNs ? line.style_dotted : line.style_solid)
                line.set_xy1(activeUpLine, aLeft, aYLeft + chWidth * aResStd)
                line.set_xy2(activeUpLine, bar_index, aYRight + chWidth * aResStd)
                line.set_color(activeUpLine, cBand)
                line.set_xy1(activeDnLine, aLeft, aYLeft - chWidth * aResStd)
                line.set_xy2(activeDnLine, bar_index, aYRight - chWidth * aResStd)
                line.set_color(activeDnLine, cBand)

// ------------------------------------------------------------ state layer ---
bool ready    = bar_index >= warmupBars and activeBars >= 2
int  dirNow   = state >= 4 ? 1 : state <= 1 ? -1 : 0
int  tempoNow = state % 2
bool stateChg = state != state[1]
int  stateAge = nz(ta.barssince(stateChg), bar_index)

// --- switch pressure: drift toward the nearest classification boundary ------
// A gauge, NOT a calibrated probability; a changepoint can reclassify without
// warning. Direction reading r = slope / mean sigma vs the dead zone; tempo
// reading = mean percentile vs the hot threshold (scaled over 20 pct-points);
float rDir = not na(activeSlope) and not na(activeMeanSig) and activeMeanSig > 0 ? activeSlope / activeMeanSig : 0.0
float annPct = not na(activeSlope) and close > 0 ? activeSlope * 252.0 / close * 100.0 : na  // %/yr, daily-bar convention
// Trend t-statistic of the ACTIVE segment's slope. The standard error is
// computed under random-walk noise -- Var(slope) ~ 1.2*sigma^2/n at leading
// order (continuous-time approximation) -- NOT the classical iid-residual
// OLS formula: regressing a random walk on time makes the classical t grow
// with n and call almost any long segment "significant" on pure noise
// (spurious regression: Granger & Newbold 1974; Phillips 1986). So
// t ~ (slope/sigma) * sqrt(n/1.2), and |t| >= 2 is the ~95% two-sided line,
// i.e. n >= ~4.8/r^2 bars for a reading of r sigma/bar to clear it.
// Caveats: segment boundaries are changepoint-selected exactly where movement
// happened, so absolute levels read optimistic (post-selection bias); vol
// clustering makes +/-2 approximate. Cross-sectional RANKING is the safer
// use. Failing |t|>=2 does not prove flat -- only that trend and noise are
// indistinguishable at this length [Merton 1980 on drift estimation].
// Screener t: require the same length floor as the ns marks, so that a
// "Trend t-stat >= 2" scan cannot pass a short steep segment (na is excluded
// by any numeric filter). Floor = max(minSegLen, 20).
bool  tOk    = not na(activeSlope) and not na(activeMeanSig) and activeMeanSig > 0 and nz(activeBars, 0) >= math.max(minSegLen, 20)
float trendT = tOk ? activeSlope / activeMeanSig * math.sqrt(activeBars / 1.2) : na
// Active-segment trend-reality tests for the SCREENER columns and the live
// label. Separate from the in-loop call above by design (different scopes;
// see the note there). Heavy (ADF matrix solve), so gated to the last bar,
// which is the only bar the screener reads and the only bar the live label
// draws on. Kept as-is for full rigor now that the screener runs without
// timing out.
var float scrVrZ = na
var float scrAdf = na
var float scrAdfCv = na
if barstate.islast and array.size(segSrc) >= math.max(minSegLen, 20)
    [_, scrVrZv, scrAdfv, scrAdfCvv, _] = trendReality(segSrc)
    scrVrZ := scrVrZv
    scrAdf := scrAdfv
    scrAdfCv := scrAdfCvv
float dirProxFlat  = math.min(1.0, math.abs(rDir) / math.max(dirDZ, 1e-9))
float dirProxTrend = math.max(0.0, math.min(1.0, 1.0 - (math.abs(rDir) - dirDZ) / math.max(dirDZ, 1e-9)))
float dirProx      = dirNow == 0 ? dirProxFlat : dirProxTrend
int   dirTargetState = dirNow == 0 ? ((rDir >= 0 ? 4 : 0) + tempoNow) : (2 + tempoNow)

float pctRead   = nz(activeMeanPct, 50.0)
float tempoProx = math.max(0.0, math.min(1.0, 1.0 - math.abs(pctRead - hotPct) / 20.0))
int   tempoTargetState = (dirNow + 1) * 2 + (1 - tempoNow)


float pressVal    = math.max(dirProx, tempoProx)
int   pressTarget = pressVal == dirProx ? dirTargetState : tempoTargetState

// --- empirical transition matrix (this chart's history) ---------------------
var transCnt = array.new_int(36, 0)
if barstate.isconfirmed and ready and stateChg and state[1] >= 0 and state[1] <= 5
    int fromTo = state[1] * 6 + state
    array.set(transCnt, fromTo, array.get(transCnt, fromTo) + 1)
int histBest  = -1
int histBestN = 0
int histRowN  = 0
for j = 0 to 5
    int cnt = array.get(transCnt, state * 6 + j)
    histRowN += cnt
    if cnt > histBestN
        histBestN := cnt
        histBest := j

// ---- Tentative profile, POC, and value area of the ACTIVE segment ----------
// Global scope so it renders while a realtime bar is forming; reads only
// confirmed data from the segment buffers. Rendered one shade lighter than
// finalized segments; rebuilt at each close, cleared when the segment closes.
int nTent = array.size(segSrc)
if showActiveProfile and barstate.islast and nTent >= 5 and not na(activeIntercept) and not na(segStartBar)
    float tInt   = activeIntercept
    float tSlope = activeSlope
    int   tLeft  = math.max(segStartBar, bar_index - maxDrawBars)
    float tResMin = na
    float tResMax = na
    float tTotVol = 0.0
    for i = 0 to nTent - 1
        float fit = tInt + tSlope * i
        float rLo = array.get(segLow, i) - fit
        float rHi = array.get(segHigh, i) - fit
        tResMin := na(tResMin) ? rLo : math.min(tResMin, rLo)
        tResMax := na(tResMax) ? rHi : math.max(tResMax, rHi)
        tTotVol += array.get(segVol, i)
    polyline.delete(activeProfile)
    activeProfile := na
    line.delete(activePocLine)
    activePocLine := na
    line.delete(activeVahLine)
    activeVahLine := na
    line.delete(activeValLine)
    activeValLine := na
    line.delete(extPocLine)
    extPocLine := na
    line.delete(extVahLine)
    extVahLine := na
    line.delete(extValLine)
    extValLine := na
    if tTotVol > 0 and tResMax > tResMin
        int tBins = binMode == "Fixed" ? maxBins : fdBinCount(segSrc, segVol, tInt, tSlope, nTent, tResMax - tResMin, binWidthScale, maxBins)
        float tBinH = (tResMax - tResMin) / tBins
        tBinVol = array.new_float(tBins, 0.0)
        for i = 0 to nTent - 1
            float fit = tInt + tSlope * i
            float rLo = array.get(segLow, i) - fit
            float rHi = array.get(segHigh, i) - fit
            float vol = array.get(segVol, i)
            if vol > 0
                if allocMode == "Close only"
                    float rCl = array.get(segSrc, i) - fit
                    int b = math.min(tBins - 1, math.max(0, int(math.floor((rCl - tResMin) / tBinH))))
                    array.set(tBinVol, b, array.get(tBinVol, b) + vol)
                else if rHi <= rLo
                    int b = math.min(tBins - 1, math.max(0, int(math.floor((rLo - tResMin) / tBinH))))
                    array.set(tBinVol, b, array.get(tBinVol, b) + vol)
                else
                    int b0 = math.min(tBins - 1, math.max(0, int(math.floor((rLo - tResMin) / tBinH))))
                    int b1 = math.min(tBins - 1, math.max(0, int(math.floor((rHi - tResMin) / tBinH - 1e-9))))
                    if b1 < b0
                        b1 := b0
                    for b = b0 to b1
                        float top = tResMin + (b + 1) * tBinH
                        float bot = tResMin + b * tBinH
                        float ov  = math.min(rHi, top) - math.max(rLo, bot)
                        if ov > 0
                            array.set(tBinVol, b, array.get(tBinVol, b) + vol * ov / (rHi - rLo))
        int   tPocBin = 0
        float tMaxVol = 0.0
        for b = 0 to tBins - 1
            if array.get(tBinVol, b) > tMaxVol
                tMaxVol := array.get(tBinVol, b)
                tPocBin := b
        // Tentative value area: same POC-outward expansion as finalized segments.
        float tVaTarget = vaPct / 100.0 * tTotVol
        float tVaCum    = array.get(tBinVol, tPocBin)
        int   tVaLo     = tPocBin
        int   tVaHi     = tPocBin
        while tVaCum < tVaTarget and (tVaLo > 0 or tVaHi < tBins - 1)
            float below = tVaLo > 0 ? array.get(tBinVol, tVaLo - 1) : -1.0
            float above = tVaHi < tBins - 1 ? array.get(tBinVol, tVaHi + 1) : -1.0
            if above >= below
                tVaHi += 1
                tVaCum += math.max(above, 0.0)
            else
                tVaLo -= 1
                tVaCum += math.max(below, 0.0)
        float tFitRight = tInt + tSlope * (bar_index - segStartBar)
        float tFitLeft  = tInt + tSlope * (tLeft - segStartBar)  // tentative POC/VA lines span the active segment
        int   tMaxBars  = math.max(1, int(math.round(nTent * profWidthFrac)))
        tPts = array.new<chart.point>()
        if tMaxVol > 0
            for b = 0 to tBins - 1
                float v = array.get(tBinVol, b)
                if v > 0
                    int w = math.max(1, int(math.round(tMaxBars * v / tMaxVol)))
                    w := math.min(w, math.max(1, bar_index - tLeft))
                    float yBot = tFitRight + tResMin + b * tBinH
                    float yTop = yBot + tBinH
                    array.push(tPts, chart.point.from_index(bar_index, yBot))
                    array.push(tPts, chart.point.from_index(bar_index - w, yBot - tSlope * w))
                    array.push(tPts, chart.point.from_index(bar_index - w, yTop - tSlope * w))
                    array.push(tPts, chart.point.from_index(bar_index, yTop))
        if array.size(tPts) > 0
            color tColor = vpColor(state)
            activeProfile := polyline.new(tPts, closed = false,
                 line_color = color.new(tColor, math.min(95, vpLineTr + 15)), fill_color = color.new(tColor, math.min(95, vpFillTr + 15)), line_width = 1)
            float tPoc = tResMin + (tPocBin + 0.5) * tBinH
            activePocLine := line.new(tLeft, tFitLeft + tPoc, bar_index, tFitLeft + tPoc + tSlope * (bar_index - tLeft),
                 color = color.new(color.orange, 50), width = 2, style = line.style_dashed)
            float tRVah = tResMin + (tVaHi + 1) * tBinH
            float tRVal = tResMin + tVaLo * tBinH
            activeVahLine := line.new(tLeft, tFitLeft + tRVah, bar_index, tFitLeft + tRVah + tSlope * (bar_index - tLeft),
                 color = color.new(color.orange, 50), style = line.style_dotted)
            activeValLine := line.new(tLeft, tFitLeft + tRVal, bar_index, tFitLeft + tRVal + tSlope * (bar_index - tLeft),
                 color = color.new(color.orange, 50), style = line.style_dotted)
            linefill.new(activeVahLine, activeValLine, color.new(color.orange, 92))
            if showProjection
                // Bars to the estimated next cut: use the target segment length
                // climb when evidence is accumulating; otherwise the realized mean
                // segment length (memoryless geometric-duration benchmark).
                float etaRaw   = float(targetSeg)
                int   etaBars  = int(math.min(250, math.max(1.0, math.round(etaRaw))))
                color extCol   = color.new(color.gray, 45)
                float yPoc = tFitRight + tPoc
                float yVah = tFitRight + tRVah
                float yVal = tFitRight + tRVal
                extPocLine := line.new(bar_index, yPoc, bar_index + etaBars, yPoc + tSlope * etaBars, color = extCol, style = line.style_dashed, width = 2)
                extVahLine := line.new(bar_index, yVah, bar_index + etaBars, yVah + tSlope * etaBars, color = extCol, style = line.style_dashed)
                extValLine := line.new(bar_index, yVal, bar_index + etaBars, yVal + tSlope * etaBars, color = extCol, style = line.style_dashed)

// Live label at the forming edge of the ACTIVE segment: tentative state + the
// V/A badge. In GLOBAL scope (not the barstate.isconfirmed block) so it draws
// on the realtime forming bar too. Reuses scrVrZ/scrAdf/scrAdfCv (the active-
// segment tests already computed above for the screener). Everything is
// TENTATIVE -- the call and stats change as the segment grows; the tooltip and
// the trailing "*" say so. One reused label object; cleared at each cut.
if showSegLabels and barstate.islast and not na(activeIntercept) and activeBars >= 2
    bool aDir     = state >= 4 or state <= 1
    bool aLenOk   = activeBars >= math.max(minSegLen, 20)
    bool aVrPass  = not na(scrVrZ) and math.abs(scrVrZ) >= 1.96
    bool aAdfPass = not na(scrAdf) and not na(scrAdfCv) and scrAdf <= scrAdfCv
    string aSuffix = not showSigMark or not aDir ? "" :
         not useTrendReality ? (not na(trendT) and math.abs(trendT) >= 2 ? "" : " (ns)") :
         trendBadge(state, aLenOk, aVrPass, aAdfPass)
    string aTip = "TENTATIVE (active segment, may change) | " + str.tostring(activeBars) + " bars" +
         " | segmentation confidence " + (na(activeConf) ? "na" : str.tostring(activeConf, "#") + "%") +
         " (posterior concentration x distance from a changepoint; low = boundary uncertain or a change may be near)" +
         (aDir ?
          (not aLenOk ? " -- too few bars (need " + str.tostring(math.max(minSegLen, 20)) + ")" :
           useTrendReality ?
             " | VR z=" + (na(scrVrZ) ? "na" : str.tostring(scrVrZ, "#.##")) + (aVrPass ? " ok" : " x") +
             " | ADF=" + (na(scrAdf) ? "na" : str.tostring(scrAdf, "#.##")) + "/cv" + (na(scrAdfCv) ? "" : str.tostring(scrAdfCv, "#.#")) + (aAdfPass ? " ok" : " x") +
             (aVrPass and aAdfPass ? " -- REAL trend (both pass)" : " -- not confirmed") :
             " | slope-t=" + (na(trendT) ? "na" : str.tostring(trendT, "#.##"))) :
          " -- flat call: no trend claimed")
    color aPillCol = state == 2 or state == 3 ? chart.fg_color : stateColor(state)
    color aPillTxt = state == 2 or state == 3 ? chart.bg_color : color.white
    float aLabY = activeIntercept + activeSlope * (activeBars - 1) + chWidth * math.max(nz(activeResStd, 0.0), 0.0)
    string aTxt = stateName(state) + aSuffix + (na(activeConf) ? "" : " " + str.tostring(activeConf, "#") + "%") + " *"
    if na(activeStateLabel)
        activeStateLabel := label.new(bar_index, aLabY, aTxt, style = label.style_label_down,
             color = color.new(aPillCol, 25), textcolor = aPillTxt, size = size.small, tooltip = aTip)
    else
        label.set_xy(activeStateLabel, bar_index, aLabY)
        label.set_text(activeStateLabel, aTxt)
        label.set_color(activeStateLabel, color.new(aPillCol, 25))
        label.set_textcolor(activeStateLabel, aPillTxt)
        label.set_tooltip(activeStateLabel, aTip)

// ------------------------------------------------------------- rendering ---
// --- Pine Screener columns ---------------------------------------------------
// The screener auto-adds the FIRST TEN plots as its default filter/column set
// (official help center), so the ten most useful readings are declared first,
// in priority order; everything after #10 stays selectable manually. One-bar
// event pulses are easy to miss in a manual scan, so recency columns
// (bars-since) are provided for "happened within N bars" filters. Blank cell
// = never happened within the screener's 500-bar window.
plot(state,      "State (0 DnCalm, 1 DnHot, 2 FlatCalm, 3 FlatHot, 4 UpCalm, 5 UpHot)", display = display.data_window)
plot(dirNow,     "Dir (-1/0/1)",                 display = display.data_window)
plot(tempoNow,   "Tempo (0 calm, 1 hot)",        display = display.data_window)
plot(stateAge,   "State age (bars)",             display = display.data_window)
plot(activeBars, "Segment length (bars)",        display = display.data_window)
plot(rDir,       "Slope (sigma/bar)",            display = display.data_window)
plot(scrVrZ,     "VarRatio z (abs over 1.96 = momentum)",  display = display.data_window)
plot(scrAdf - scrAdfCv, "ADF minus crit (neg = trend-stationary)", display = display.data_window)
plot(activeConf, "Active segmentation confidence (0-100)", display = display.data_window)
// -- beyond the default ten: add manually in the screener when needed --------
plot(pctRead,    "Vol percentile (segment mean)", display = display.data_window)
plot(pressVal * 100.0, "Pressure (0-100)",       display = display.data_window)
plot(trendT,     "Trend t-stat (abs t over 2 = 95pct)",   display = display.data_window)
plot(pressTarget,      "Pressure target state (0-5)", display = display.data_window)
plot(annPct,     "Slope (%/yr, daily bars)",     display = display.data_window)
plot(cutEvent ? 1 : 0,      "Cut event (0/1)",           display = display.data_window)
plot(ta.barssince(cutEvent),      "Bars since cut detected",   display = display.data_window)
plot(histBest,   "Hist next state (0-5, -1 none)",       display = display.data_window)
plot(histRowN > 0 and histBest >= 0 ? 100.0 * histBestN / histRowN : na, "Hist next share (%)", display = display.data_window)
plot(histRowN,   "Hist sample n",                        display = display.data_window)
plot(showKalman ? kLevel : na, "Kalman level", color = color.new(color.orange, 40))

var table panel = table.new(position.top_right, 2, 10, border_width = 1)
if showTable and barstate.islast
    color bg  = color.new(stateColor(state), 40)
    color txt = stateText(state)
    string pressValue = str.tostring(pressVal * 100, "#") + "%  " + stateName(pressTarget)
    string histValue  = histRowN > 0 and histBest >= 0 ? stateName(histBest) + " " + str.tostring(100.0 * histBestN / histRowN, "#") + "% (" + str.tostring(histRowN) + ")" : "no history"
    table.cell(panel, 0, 0, "State", text_color = txt, bgcolor = bg)
    table.cell(panel, 1, 0, stateName(state), text_color = txt, bgcolor = bg)
    table.cell(panel, 0, 1, "Age (bars)", text_color = txt, bgcolor = bg)
    table.cell(panel, 1, 1, str.tostring(stateAge), text_color = txt, bgcolor = bg)
    table.cell(panel, 0, 2, "Segment (bars)", text_color = txt, bgcolor = bg)
    table.cell(panel, 1, 2, str.tostring(activeBars), text_color = txt, bgcolor = bg)
    table.cell(panel, 0, 3, "Slope", text_color = txt, bgcolor = bg)
    table.cell(panel, 1, 3, str.tostring(rDir, "#.###") + "σ/bar (" + (annPct >= 0 ? "+" : "") + str.tostring(annPct, "#.#") + "%/yr)", text_color = txt, bgcolor = bg)
    table.cell(panel, 0, 4, "Vol pct (mean)", text_color = txt, bgcolor = bg)
    table.cell(panel, 1, 4, str.tostring(pctRead, "#.#") + " / " + str.tostring(hotPct, "#"), text_color = txt, bgcolor = bg)
    table.cell(panel, 0, 5, "MAP run length", text_color = txt, bgcolor = bg)
    table.cell(panel, 1, 5, str.tostring(scrMapRL), text_color = txt, bgcolor = bg)
    table.cell(panel, 0, 6, "Hazard (mean len)", text_color = txt, bgcolor = bg)
    table.cell(panel, 1, 6, str.tostring(bocpdHaz), text_color = txt, bgcolor = bg)
    table.cell(panel, 0, 7, "Pressure", text_color = txt, bgcolor = bg)
    table.cell(panel, 1, 7, pressValue, text_color = txt, bgcolor = bg)
    table.cell(panel, 0, 8, "Hist. next", text_color = txt, bgcolor = bg)
    table.cell(panel, 1, 8, histValue, text_color = txt, bgcolor = bg)
    table.cell(panel, 0, 9, "Trend t", text_color = txt, bgcolor = bg)
    table.cell(panel, 1, 9, na(trendT) ? "-" : str.tostring(trendT, "#.##") + (math.abs(nz(trendT)) >= 2 ? " (sig)" : " (ns)"), text_color = txt, bgcolor = bg)

// ---------------------------------------------------------------- alerts ---
// Ordered for the Pine Screener: it auto-adds the FIRST TWO alertconditions
// as ready-made filters when the script loads there (plots and alert
// conditions are both usable as filters; only plots can be table columns).
bool dirUpX   = dirNow == 1  and dirNow[1] != 1
bool dirDnX   = dirNow == -1 and dirNow[1] != -1
bool dirFlatX = dirNow == 0  and dirNow[1] != 0
bool tHotX    = tempoNow == 1 and tempoNow[1] != 1
bool tCalmX   = tempoNow == 0 and tempoNow[1] != 0
alertcondition(stateChg, "Regime changed",   "Strata: state changed ({{ticker}} {{interval}})")
alertcondition(cutEvent,      "Segment cut (backdated)", "Strata: new segment cut ({{ticker}} {{interval}})")
alertcondition(dirUpX,   "Direction: up",    "Strata: direction turned UP ({{ticker}} {{interval}})")
alertcondition(dirDnX,   "Direction: down",  "Strata: direction turned DOWN ({{ticker}} {{interval}})")
alertcondition(dirFlatX, "Direction: flat",  "Strata: direction turned FLAT ({{ticker}} {{interval}})")
alertcondition(tHotX,    "Tempo: hot",       "Strata: volatility regime HOT ({{ticker}} {{interval}})")
alertcondition(tCalmX,   "Tempo: calm",      "Strata: volatility regime CALM ({{ticker}} {{interval}})")
````
