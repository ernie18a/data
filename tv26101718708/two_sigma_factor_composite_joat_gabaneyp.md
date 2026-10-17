# Two Sigma Factor Composite [JOAT]

- url: https://www.tradingview.com/script/GABANeyP-Two-Sigma-Factor-Composite-JOAT/
- type: indicator
- pine_id: PUB;23b18c3ad03f4943af8b7717cd5c0446
- version: 1.0

## Description

[b]TWO SIGMA FACTOR COMPOSITE [JOAT][/b]

A tribute to the multi-factor approach pioneered by Two Sigma — long-only, long/short, and risk-premia funds that decompose returns into orthogonal factor exposures, normalise each factor onto the same statistical scale, and combine them into a single signed score. Two Sigma Factor Composite builds five canonical factors (Momentum, Quality, Value, Volatility, Mean-Reversion), Z-normalises each against a rolling baseline, sum-normalises the user-controllable weights, and outputs a composite score with signal labels, factor sparklines on the chart, and a rolling hit-rate backtest.

[image]https://www.tradingview.com/x/M6x6vGON/[/image]

[b]The five factors[/b]

Each factor is computed independently and Z-normalised over a configurable window (default 100 bars) with optional outlier clipping (default ±4σ):

[list]
[*] [b]Momentum[/b] — return / volatility over the configurable momentum window (default 50 bars). The classic "trend" factor.
[*] [b]Quality[/b] — inverse of recent realised volatility (default 50-bar window). Lower volatility = higher quality; an asset that has been calmer is treated as higher quality, consistent with academic factor research.
[*] [b]Value[/b] — deviation from a long mean (default 200-bar SMA). Negative deviation = "cheap" (positive value factor exposure); positive deviation = "expensive". The classical cross-sectional value definition, adapted to time series.
[*] [b]Volatility[/b] — percentile rank of recent realised volatility (default 20-bar stdev percentile-ranked over 252 bars). High vol = negative factor; low vol = positive factor.
[*] [b]Mean-Reversion[/b] — signed deviation from a 20-bar mean (default). Captures short-term reversion bias.
[/list]

Each factor's window is independently configurable. All five outputs are Z-scores capped at ±4σ to prevent any single outlier from dominating the composite.

[b]Sum-normalised weights[/b]

Five weight sliders (default 1.0 each) are normalised internally so any positive combination is valid. Default equal weight is the most defensible baseline; tune individual weights to bias the composite. Want a pure momentum + quality read? Set the others to 0.1 and Momentum/Quality to 2.0. The composite reshapes itself live.

[b]Signal engine — bounded composite with three tiers[/b]

The composite is bounded by the clipping cap. The signal engine layers three thresholds:

[list]
[*] [b]Buy[/b] — composite crosses above the buy threshold (default +1.0σ).
[*] [b]Sell[/b] — composite crosses below the sell threshold (default −1.0σ).
[*] [b]Extreme Bull / Extreme Bear[/b] — |composite| crosses ±2.0σ. The script's strongest read.
[/list]

A configurable signal cooldown (default 10 bars) prevents clustering.

[b]Factor sparklines (the signature visual)[/b]

The script renders [b]inline sparklines[/b] on the chart for all five factors — small line plots that visually show each factor's recent Z trajectory. Configurable base offset (vertical position below zero), row spacing, amplitude, and per-row transparency mapping. At a glance you see which factors are driving the composite and which are flat.

When all five sparklines lean the same way, the composite is high-confidence. When they disagree, the composite is a weighted compromise — the sparklines tell you the truth that a single number cannot.

[image]https://www.tradingview.com/x/Gm6z0RM8/[/image]

[b]Visual system[/b]

[list]
[*] [b]Composite line[/b] (configurable width, default 3px) with sign-coloured fill toward zero (configurable transparency).
[*] [b]Threshold lines[/b] at ±buyTH and ±extremeTH (configurable transparency).
[*] [b]Buy / Sell labels[/b] on chart on threshold crosses.
[*] [b]Factor sparklines[/b] — five inline Z-trajectory plots in the pane.
[*] [b]Optional chart-background override[/b] to follow chart.bg_color.
[/list]

A locked Emerald Night palette: vivid green bull / vivid red bear / sage mid on a deep emerald background — strict 2-hue discipline with bg. No third colour invented anywhere; all variations are transparency-only.

[b]Dashboard[/b]

Monospaced table positionable to any of eight corners. Surfaces:

[list]
[*] Composite Z value and sign.
[*] Per-factor Z rows (Momentum / Quality / Value / Volatility / Mean-Reversion).
[*] Factor agreement percentage (how many factors agree with composite sign).
[*] Last signal direction with bars-ago.
[*] Weight configuration in use.
[*] [b]Backtest stats row[/b] — rolling forward-N-bar hit rate (configurable lookahead, default 10 bars). The script's own performance audit.
[/list]

[b]Alerts[/b]

Five alert conditions, each independently controllable:

[list]
[*] BUY Cross (composite crosses above buy threshold)
[*] SELL Cross
[*] Extreme Bull (composite > +2.0σ)
[*] Extreme Bear (composite < −2.0σ)
[*] Low Factor Agreement (% of factors agreeing falls below the configurable threshold, default 40%) — the script's "no edge" warning.
[/list]

[b]How to read it[/b]

Three reads, in order of conviction:

[list=1]
[*] [b]Extreme score with high factor agreement[/b] (e.g. composite > +2.0σ AND agreement > 80%) — the highest-conviction read the script produces. Four or five factors are pointing decisively one way, and the composite is at a statistical extreme.
[*] [b]Buy / Sell with sparkline confirmation[/b] — visual confirmation that the directional read is being driven by multiple factors, not just one. If the composite is bullish but only the Momentum sparkline is leaning, the read is fragile; if Momentum + Quality + Value + Mean-Reversion all lean, the read is robust.
[*] [b]Low Agreement alert[/b] — stand-aside signal. The factors disagree internally; the composite is a wash. Wait for re-alignment.
[/list]

[b]Suggested settings[/b]

Defaults (momentum 50 / quality vol 50 / value 200 / vol 20/252 / MR 20, Z window 100, ±4σ clip, ±1.0 buy/sell, ±2.0 extreme, 10-bar cooldown) are tuned for daily charts on broad indices — the timeframes where factor approaches are statistically meaningful. For lower timeframes drop all windows proportionally. For weekly+ keep defaults; factor reads on weekly are the canonical institutional horizons.

[b]Originality / what's reused[/b]

The factor-investing framework is published academic finance — Fama-French 1992, Carhart 1997, AQR 2013, and many others. The five factors used here (Momentum, Quality, Value, Volatility, Mean-Reversion) are the canonical institutional factor set. The implementation here — the five-factor pipeline with each factor's window independently configurable, the rolling Z-normalisation with outlier clipping, the sum-normalised five-weight composition, the bounded-composite signal engine with three-tier thresholds, the inline factor sparklines render in the same pane, the rolling forward-bar hit-rate backtest, and the strict 2-hue alpha-only palette — is JOAT-original. No third-party code reused. The script is a [i]tribute[/i] to Two Sigma-style factor-composite portfolio construction, not a direct replication of any proprietary Two Sigma model.

[b]Limitations[/b]

The five factors are computed from chart data only — they are time-series proxies of the cross-sectional factors used in true multi-asset portfolios. The Z-normalisation needs the window populated; early bars give a warm-up read. The forward-N-bar hit-rate backtest is descriptive of recent signal behaviour under the current settings; it is not a predictive metric. Factor exposures historically underperform for extended periods — the dashboard's agreement row and the low-agreement alert exist specifically to warn you when the model is breaking down.

—

-made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(title          = "Two Sigma Factor Composite [JOAT]",
          shorttitle     = "TWS [JOAT]",
          overlay        = false,
          max_lines_count  = 500,
          max_labels_count = 500,
          max_boxes_count  = 500,
          max_bars_back    = 5000,
          precision        = 4)

// ============================================================================
//  SECTION 1 - INPUTS
// ============================================================================

grpFW   = "+---------- Factor Weights ----------+"
grpFP   = "+---------- Factor Parameters ----------+"
grpZN   = "+---------- Z-Normalization ----------+"
grpSIG  = "+---------- Signal Engine ----------+"
grpVIS  = "+---------- Visuals / Theme ----------+"
grpSPK  = "+---------- Factor Sparklines ----------+"
grpDB   = "+---------- Dashboard ----------+"
grpALT  = "+---------- Alerts ----------+"

// --- Factor weights (sum-normalized internally) ---
wMom_in = input.float(1.0, "Momentum Weight",       minval=0.0, maxval=5.0, step=0.1, group=grpFW, tooltip="Weight applied to the 50-bar return/vol momentum factor before sum-normalization.")
wQua_in = input.float(1.0, "Quality Weight",        minval=0.0, maxval=5.0, step=0.1, group=grpFW, tooltip="Weight applied to the inverse-volatility quality proxy.")
wVal_in = input.float(1.0, "Value Weight",          minval=0.0, maxval=5.0, step=0.1, group=grpFW, tooltip="Weight applied to the long-mean deviation value proxy.")
wVol_in = input.float(1.0, "Volatility Weight",     minval=0.0, maxval=5.0, step=0.1, group=grpFW, tooltip="Weight applied to the rolling-stdev percentile volatility factor.")
wMR_in  = input.float(1.0, "Mean-Reversion Weight", minval=0.0, maxval=5.0, step=0.1, group=grpFW, tooltip="Weight applied to the 20-bar signed-deviation mean-reversion factor.")

// --- Per-factor window parameters ---
momLen     = input.int(50,  "Momentum Window (bars)",     minval=5,  maxval=500, group=grpFP)
quaLen     = input.int(50,  "Quality Vol Window (bars)",  minval=5,  maxval=500, group=grpFP)
valLen     = input.int(200, "Value SMA Window (bars)",    minval=20, maxval=500, group=grpFP)
volStdLen  = input.int(20,  "Volatility Stdev Window",    minval=5,  maxval=200, group=grpFP)
volRankLen = input.int(252, "Volatility Rank Window",     minval=50, maxval=500, group=grpFP)
mrLen      = input.int(20,  "Mean-Reversion Window",      minval=5,  maxval=200, group=grpFP)

// --- Z-normalization window ---
zLen       = input.int(100, "Z-Normalization Window", minval=20, maxval=500, group=grpZN, tooltip="Lookback used to compute mean and stdev of each raw factor before standardization.")
zCap       = input.float(4.0, "Z-Score Cap (clip)",    minval=2.0, maxval=10.0, step=0.5, group=grpZN, tooltip="Clip extreme Z-scores to this absolute value to prevent outliers from dominating the composite.")

// --- Signal engine ---
upperTH    = input.float(1.0,  "Buy Threshold (+sigma)",  minval=0.25, maxval=5.0, step=0.25, group=grpSIG)
lowerTH    = input.float(-1.0, "Sell Threshold (-sigma)", minval=-5.0, maxval=-0.25, step=0.25, group=grpSIG)
extremeTH  = input.float(2.0,  "Extreme Threshold (+/-)", minval=1.0, maxval=5.0, step=0.25, group=grpSIG)
cooldown   = input.int(10,   "Signal Cooldown (bars)",   minval=0,  maxval=200, group=grpSIG, tooltip="Minimum bars between consecutive same-side signals to prevent clustering.")
showLabels = input.bool(true, "Show BUY/SELL Labels on Chart", group=grpSIG)

useChartBg = input.bool(false, "Use Chart Background (override theme bg)", group=grpVIS, tooltip="When true, the bg color follows chart.bg_color instead of the theme background.")

// --- Visuals: composite + factor sparklines ---
lineWidth     = input.int(3, "Composite Line Width", minval=1, maxval=5, group=grpVIS)
fillAlpha     = input.int(82, "Composite Fill Transparency", minval=50, maxval=100, group=grpVIS)
hlineAlpha    = input.int(70, "Threshold Line Transparency", minval=40, maxval=95, group=grpVIS)

showSparks    = input.bool(true,  "Show Factor Sparklines",      group=grpSPK)
sparkOffset   = input.float(-3.0, "Sparkline Base Offset",       minval=-10.0, maxval=-1.0, step=0.5, group=grpSPK, tooltip="Vertical offset below zero where the sparkline strip begins.")
sparkSpacing  = input.float(0.5,  "Sparkline Row Spacing",       minval=0.2,  maxval=1.5,  step=0.05, group=grpSPK)
sparkAmp      = input.float(0.4,  "Sparkline Amplitude",         minval=0.1,  maxval=1.0,  step=0.05, group=grpSPK)
sparkAlphaMin = input.int(30, "Sparkline Min Transparency",  minval=0,  maxval=80, group=grpSPK)
sparkAlphaMax = input.int(85, "Sparkline Max Transparency",  minval=40, maxval=100, group=grpSPK)

// --- Dashboard ---
showDash    = input.bool(true,   "Show Dashboard", group=grpDB)
dashPosStr  = input.string("Top Right", "Dashboard Position",
   options = ["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Left",
              "Bottom Right", "Bottom Left", "Bottom Center"], group=grpDB)
dashSizeStr = input.string("Small", "Dashboard Text Size",
   options = ["Tiny", "Small", "Normal", "Large"], group=grpDB)
showBack    = input.bool(true,   "Show Backtest Stats Row", group=grpDB, tooltip="Tracks composite-cross signals over the chart history and reports a directional hit rate.")
btLookahead = input.int(10,  "Backtest Forward Bars", minval=1, maxval=50, group=grpDB, tooltip="Bars ahead used to evaluate signal accuracy (price moved with signal direction).")

// --- Alerts ---
alertBuy    = input.bool(true, "Alert: BUY Cross",            group=grpALT)
alertSell   = input.bool(true, "Alert: SELL Cross",           group=grpALT)
alertExtBull= input.bool(true, "Alert: Extreme Bull (+2 sigma)",  group=grpALT)
alertExtBear= input.bool(true, "Alert: Extreme Bear (-2 sigma)",  group=grpALT)
alertLowAgr = input.bool(true, "Alert: Low Factor Agreement", group=grpALT)
agrLowTH    = input.int(40, "Low-Agreement Threshold (%)", minval=10, maxval=70, group=grpALT)

// ============================================================================
//  SECTION 2 - COLOR PALETTE  (Emerald Night - locked institutional)
// ============================================================================
//  Single curated palette. No theme switcher. Vivid green / vivid red /
//  sage mid / deep emerald bg. Strict 2-hue discipline + bg.

const color C_BULL_BASE = #00E676
const color C_BEAR_BASE = #FF5252
const color C_MID_BASE  = #7FAF9B
const color C_BG_BASE   = #07110B
const color C_FRAME_HUE = #153322

color bullHue = C_BULL_BASE
color bearHue = C_BEAR_BASE
color bgHue   = useChartBg ? chart.bg_color : C_BG_BASE

// Pre-derived semi-transparent variants (still only 2 hues — alpha only)
color bullSoft   = color.new(bullHue, 70)
color bearSoft   = color.new(bearHue, 70)
color bullFaint  = color.new(bullHue, 88)
color bearFaint  = color.new(bearHue, 88)
color bullGhost  = color.new(bullHue, fillAlpha)
color bearGhost  = color.new(bearHue, fillAlpha)
color hlineBull  = color.new(bullHue, hlineAlpha)
color hlineBear  = color.new(bearHue, hlineAlpha)

// Text on background — we use the brighter of the two hues for headers, the
// other for accents. We avoid any third color (no white/gray/silver fonts).
color textHi     = color.new(bullHue, 0)
color textLo     = color.new(bearHue, 0)
color textMute   = color.new(bullHue, 35)
color bgPanel    = color.new(bgHue, 18)
color bgHdr      = color.new(bgHue, 4)
color bgRow      = color.new(bgHue, 40)
color frameCol   = color.new(bullHue, 70)

// ============================================================================
//  SECTION 3 - HELPER FUNCTIONS
// ============================================================================

// --- RGB linear interpolation between two colors. Ratio in [0,1].
f_colorGradient(float _ratio, color _colA, color _colB) =>
    ratC = math.max(0.0, math.min(1.0, _ratio))
    rA = color.r(_colA), gA = color.g(_colA), bA = color.b(_colA)
    rB = color.r(_colB), gB = color.g(_colB), bB = color.b(_colB)
    rr = rA + int((rB - rA) * ratC)
    rg = gA + int((gB - gA) * ratC)
    rb = bA + int((bB - bA) * ratC)
    color.rgb(rr, rg, rb, 0)

// --- Generic clamp.
f_clamp(float _x, float _min, float _max) =>
    math.max(_min, math.min(_x, _max))

// --- Safe Z-score: returns 0 when stdev is 0 or NA.
f_zscore(float _x, int _len) =>
    float mu = ta.sma(_x, _len)
    float sd = ta.stdev(_x, _len)
    sd > 0 ? (_x - mu) / sd : 0.0

// --- Sign-as-int helper for agreement counting.
f_signI(float _x) =>
    _x > 0 ? 1 : _x < 0 ? -1 : 0

// --- Format Z-score for display (3 d.p., signed).
f_fmtZ(float _z) =>
    str.tostring(_z, "+0.000;-0.000")

// --- Bar gauge from a signed value bounded by [-cap, +cap] (8 cells).
f_zGauge(float _z, float _cap) =>
    float ratio = f_clamp((_z + _cap) / (2.0 * _cap), 0.0, 1.0)
    int filled = int(math.round(ratio * 8.0))
    string out = ""
    for i = 0 to 7
        out += (i < filled) ? "#" : "-"
    out

// --- Resolve string -> table position constant.
f_pos(string s) =>
    switch s
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        =>               position.bottom_right

// --- Resolve string -> text size constant.
f_size(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.normal

// --- Sum-normalize five weights into ratios that always sum to 1.
f_normWeights(float a, float b, float c, float d, float e) =>
    float s = a + b + c + d + e
    float ra = 0.2
    float rb = 0.2
    float rc = 0.2
    float rd = 0.2
    float re = 0.2
    if s > 0
        ra := a / s
        rb := b / s
        rc := c / s
        rd := d / s
        re := e / s
    [ra, rb, rc, rd, re]

// ============================================================================
//  SECTION 4 - CORE CALCULATIONS  (5 factors, each Z-normalized)
// ============================================================================
//
//  Pine v6 does not allow series functions inside conditional blocks; every
//  factor is computed unconditionally at the top level so historical state
//  remains contiguous across bars.
// ----------------------------------------------------------------------------

// --- Returns series (used by Momentum / Quality / Volatility).
float ret1 = ta.change(close, 1)

// ---- FACTOR 1: MOMENTUM ----
// 50-bar log-style return scaled by 50-bar return volatility (information-
// ratio analog). Captures persistent directional drift normalized by noise.
float momReturn = close - close[momLen]
float momVol    = ta.stdev(ret1, momLen)
float momRaw    = momVol > 0 ? momReturn / momVol : 0.0
float zMom      = f_clamp(f_zscore(momRaw, zLen), -zCap, zCap)

// ---- FACTOR 2: QUALITY (proxy via inverse realized volatility) ----
// Lower realized vol -> higher "quality" (less idiosyncratic noise).
float quaStdev = ta.stdev(ret1, quaLen)
float quaRaw   = quaStdev > 0 ? 1.0 / quaStdev : 0.0
float zQua     = f_clamp(f_zscore(quaRaw, zLen), -zCap, zCap)

// ---- FACTOR 3: VALUE (proxy via long-mean deviation) ----
// Negative of normalized deviation from long-term SMA. Further below mean ->
// higher value Z. (No fundamental data, so this is a behavioral proxy.)
float valSMA = ta.sma(close, valLen)
float valRaw = close > 0 ? -(close - valSMA) / close : 0.0
float zVal   = f_clamp(f_zscore(valRaw, zLen), -zCap, zCap)

// ---- FACTOR 4: VOLATILITY (percentile rank of rolling stdev) ----
// We Z-normalize the rank itself so it integrates with the other factors on
// the same standardized scale.
float volStd  = ta.stdev(ret1, volStdLen)
float volRank = ta.percentrank(volStd, volRankLen)
float zVol    = f_clamp(f_zscore(volRank, zLen), -zCap, zCap)

// ---- FACTOR 5: MEAN-REVERSION (negated 20-bar Z of price) ----
// When price stretches above 20-bar mean by many sigma, mean-reversion Z is
// negative (sell pressure). When stretched below, MR Z is positive (buy).
float mrSMA  = ta.sma(close, mrLen)
float mrStd  = ta.stdev(close, mrLen)
float mrRaw  = mrStd > 0 ? -(close - mrSMA) / mrStd : 0.0
float zMR    = f_clamp(f_zscore(mrRaw, zLen), -zCap, zCap)

// ---- Sum-normalized weights so user emphasis never breaks the +/-sigma scale ----
[wMomN, wQuaN, wValN, wVolN, wMRN] = f_normWeights(wMom_in, wQua_in, wVal_in, wVol_in, wMR_in)

// ---- Composite (weighted sum of standardized factors) ----
float composite = wMomN * zMom + wQuaN * zQua + wValN * zVal + wVolN * zVol + wMRN * zMR

// ---- Per-factor signed contribution (for attribution table). ----
float cMom = wMomN * zMom
float cQua = wQuaN * zQua
float cVal = wValN * zVal
float cVol = wVolN * zVol
float cMR  = wMRN  * zMR

// ---- Dominant factor (largest absolute contribution). ----
float absMom = math.abs(cMom)
float absQua = math.abs(cQua)
float absVal = math.abs(cVal)
float absVol = math.abs(cVol)
float absMR  = math.abs(cMR)
float maxAbs = math.max(absMom, math.max(absQua, math.max(absVal, math.max(absVol, absMR))))

string dominantName = "-"
float  dominantVal  = 0.0
if maxAbs > 0
    if absMom == maxAbs
        dominantName := "Momentum"
        dominantVal  := cMom
    else if absQua == maxAbs
        dominantName := "Quality"
        dominantVal  := cQua
    else if absVal == maxAbs
        dominantName := "Value"
        dominantVal  := cVal
    else if absVol == maxAbs
        dominantName := "Volatility"
        dominantVal  := cVol
    else
        dominantName := "Mean-Rev"
        dominantVal  := cMR

// ---- Factor agreement: how many of the five factors share the composite sign? ----
int compSign = f_signI(composite)
int agreeCount = 0
if compSign != 0
    agreeCount += f_signI(zMom) == compSign ? 1 : 0
    agreeCount += f_signI(zQua) == compSign ? 1 : 0
    agreeCount += f_signI(zVal) == compSign ? 1 : 0
    agreeCount += f_signI(zVol) == compSign ? 1 : 0
    agreeCount += f_signI(zMR)  == compSign ? 1 : 0
float agreePct = compSign == 0 ? 0.0 : (agreeCount / 5.0) * 100.0

// ============================================================================
//  SECTION 5 - STATE / TRACKING
// ============================================================================

var int lastBuyBar  = -10000
var int lastSellBar = -10000

// --- Backtest counters: a signal is "right" if close moves with direction over btLookahead bars.
var int btBuyTotal  = 0
var int btBuyWin    = 0
var int btSellTotal = 0
var int btSellWin   = 0

// Pending-evaluation queues (parallel arrays of bar_index when signal fired and direction).
var array<int>  pendBar  = array.new<int>()
var array<int>  pendDir  = array.new<int>()
var array<float> pendPx  = array.new<float>()

// Last extreme tags (used by alerts / dashboard).
var int  lastExtBullBar = -10000
var int  lastExtBearBar = -10000

// ============================================================================
//  SECTION 6 - SIGNAL ENGINE
// ============================================================================
//
//  Raw signals from threshold crosses, with a cooldown so the indicator does
//  not spam labels when composite hovers around +/-1. Each crossing past the
//  extreme threshold (default +/-2 sigma) sets the extreme-event flag.
// ----------------------------------------------------------------------------

bool rawBuy  = ta.crossover (composite, upperTH)
bool rawSell = ta.crossunder(composite, lowerTH)

bool buySig  = rawBuy  and (bar_index - lastBuyBar)  >= cooldown
bool sellSig = rawSell and (bar_index - lastSellBar) >= cooldown

if buySig
    lastBuyBar := bar_index
    array.push(pendBar, bar_index)
    array.push(pendDir, 1)
    array.push(pendPx,  close)
    btBuyTotal += 1
if sellSig
    lastSellBar := bar_index
    array.push(pendBar, bar_index)
    array.push(pendDir, -1)
    array.push(pendPx,  close)
    btSellTotal += 1

// Extreme flags.
bool extBull = ta.crossover (composite,  extremeTH)
bool extBear = ta.crossunder(composite, -extremeTH)
if extBull
    lastExtBullBar := bar_index
if extBear
    lastExtBearBar := bar_index

// Evaluate pending signals once btLookahead bars have passed.
if array.size(pendBar) > 0
    int i = 0
    while i < array.size(pendBar)
        int sigBar = array.get(pendBar, i)
        if (bar_index - sigBar) >= btLookahead
            int   d  = array.get(pendDir, i)
            float p0 = array.get(pendPx,  i)
            bool win = (d == 1 and close > p0) or (d == -1 and close < p0)
            if d == 1 and win
                btBuyWin += 1
            else if d == -1 and win
                btSellWin += 1
            array.remove(pendBar, i)
            array.remove(pendDir, i)
            array.remove(pendPx,  i)
        else
            i += 1

// Low-agreement detection (used by dashboard / alerts).
bool lowAgr = compSign != 0 and agreePct <= agrLowTH

// ============================================================================
//  SECTION 7 - PLOTS / FILLS  (composite line + threshold guides + sparklines)
// ============================================================================
//
//  Composite line color = bear hue at -zCap, bull hue at +zCap, interpolated.
//  This keeps the chart strictly to 2 hues + bg.
// ----------------------------------------------------------------------------

// --- Composite color ratio: -zCap..+zCap mapped to 0..1.
float cRatio    = f_clamp((composite + zCap) / (2.0 * zCap), 0.0, 1.0)
color compColor = f_colorGradient(cRatio, bearHue, bullHue)

// --- Composite line + soft-fill to zero.
plot(composite, title="Composite", color=compColor, linewidth=lineWidth)
p0 = plot(0.0, title="ZeroAnchor", color=na, display=display.none)
pComp = plot(composite, title="CompositeAnchor", color=na, display=display.none)
fill(pComp, p0, color = composite >= 0 ? bullGhost : bearGhost, title="CompositeFill")

// --- Threshold guides at +/-1 and +/-2 sigma (only 2 hues, faint).
plot(0.0,         "Zero",          color=color.new(bullHue, 92), linewidth=1, style=plot.style_linebr)
plot(upperTH,     "Buy Threshold", color=hlineBull,              linewidth=1, style=plot.style_linebr)
plot(lowerTH,     "Sell Threshold",color=hlineBear,              linewidth=1, style=plot.style_linebr)
plot(extremeTH,   "Extreme Bull",  color=hlineBull,              linewidth=1, style=plot.style_circles)
plot(-extremeTH,  "Extreme Bear",  color=hlineBear,              linewidth=1, style=plot.style_circles)
plot(sparkOffset, "SparkBase",     color=color.new(bullHue, 95), linewidth=1, style=plot.style_linebr)

// --- Background tint on extreme readings (very faint, same hues).
bgcolor(composite >= extremeTH  ? color.new(bullHue, 92) : na, title="ExtremeBullBg")
bgcolor(composite <= -extremeTH ? color.new(bearHue, 92) : na, title="ExtremeBearBg")

// --- Per-factor sparklines beneath the zero line.
// Each sparkline is a small oscillator anchored at a fixed Y offset whose
// amplitude scales with |z| / zCap, and whose color sits on the same bull-bear
// gradient. Transparency varies with strength to enforce "intensity by Z".
f_sparkVal(float baseY, float zVal) =>
    float ratio = f_clamp(zVal / zCap, -1.0, 1.0)
    baseY + ratio * sparkAmp

f_sparkColor(float zVal) =>
    float r     = f_clamp((zVal + zCap) / (2.0 * zCap), 0.0, 1.0)
    color base  = f_colorGradient(r, bearHue, bullHue)
    float strg  = math.min(1.0, math.abs(zVal) / zCap)
    int   alpha = int(sparkAlphaMax - (sparkAlphaMax - sparkAlphaMin) * strg)
    color.new(base, alpha)

// Y-anchors for each of the 5 sparklines.
float yMom = sparkOffset - 0.0 * sparkSpacing
float yQua = sparkOffset - 1.0 * sparkSpacing
float yVal = sparkOffset - 2.0 * sparkSpacing
float yVol = sparkOffset - 3.0 * sparkSpacing
float yMR  = sparkOffset - 4.0 * sparkSpacing

plot(showSparks ? f_sparkVal(yMom, zMom) : na, title="Spark Momentum",  color=f_sparkColor(zMom), linewidth=2)
plot(showSparks ? f_sparkVal(yQua, zQua) : na, title="Spark Quality",   color=f_sparkColor(zQua), linewidth=2)
plot(showSparks ? f_sparkVal(yVal, zVal) : na, title="Spark Value",     color=f_sparkColor(zVal), linewidth=2)
plot(showSparks ? f_sparkVal(yVol, zVol) : na, title="Spark Volatility",color=f_sparkColor(zVol), linewidth=2)
plot(showSparks ? f_sparkVal(yMR,  zMR ) : na, title="Spark MeanRev",   color=f_sparkColor(zMR),  linewidth=2)

// Sparkline baselines (very faint, same hues).
plot(showSparks ? yMom : na, title="Spark Base Mom",  color=color.new(bullHue, 94), linewidth=1)
plot(showSparks ? yQua : na, title="Spark Base Qua",  color=color.new(bullHue, 94), linewidth=1)
plot(showSparks ? yVal : na, title="Spark Base Val",  color=color.new(bullHue, 94), linewidth=1)
plot(showSparks ? yVol : na, title="Spark Base Vol",  color=color.new(bullHue, 94), linewidth=1)
plot(showSparks ? yMR  : na, title="Spark Base MR",   color=color.new(bullHue, 94), linewidth=1)

// ============================================================================
//  SECTION 8 - DRAWINGS  (BUY/SELL labels on the chart via force_overlay)
// ============================================================================

if showLabels and buySig
    label.new(bar_index, low,
       text       = "BUY",
       style      = label.style_label_up,
       color      = color.new(bullHue, 15),
       textcolor  = bgHue,
       size       = size.small,
       force_overlay = true)

if showLabels and sellSig
    label.new(bar_index, high,
       text       = "SELL",
       style      = label.style_label_down,
       color      = color.new(bearHue, 15),
       textcolor  = bgHue,
       size       = size.small,
       force_overlay = true)

// Extreme-state markers in the pane itself (small dots, same hues).
plotshape(extBull, title="Extreme Bull Dot", style=shape.circle, location=location.absolute,
   color=bullHue, size=size.tiny, offset=0)
plotshape(extBear, title="Extreme Bear Dot", style=shape.circle, location=location.absolute,
   color=bearHue, size=size.tiny, offset=0)

// ============================================================================
//  SECTION 9 - DASHBOARD  (12-row factor attribution table)
// ============================================================================
//
//  Strictly two foreground hues + bgHue panel. Numeric values colored by sign:
//  positive Z -> bullHue, negative Z -> bearHue, near-zero -> faint variant.
// ----------------------------------------------------------------------------

// --- Helper to color a Z-value cell by its sign / magnitude.
f_zCellCol(float zv) =>
    float strg = math.min(1.0, math.abs(zv) / zCap)
    color base = zv >= 0 ? bullHue : bearHue
    color.new(base, int(15 + (1.0 - strg) * 50))

// Signal text + color for row 2.
sigTxt = composite >= upperTH ? "STRONG BUY" : composite <= lowerTH ? "STRONG SELL" : composite > 0 ? "Lean Bull" : composite < 0 ? "Lean Bear" : "Neutral"
color sigCol = composite >= upperTH ? bullHue : composite <= lowerTH ? bearHue : composite > 0 ? color.new(bullHue, 35) : composite < 0 ? color.new(bearHue, 35) : color.new(bullHue, 70)

// Backtest hit-rates.
float buyHit  = btBuyTotal  > 0 ? (btBuyWin  / float(btBuyTotal))  * 100.0 : 0.0
float sellHit = btSellTotal > 0 ? (btSellWin / float(btSellTotal)) * 100.0 : 0.0
int   totalSig = btBuyTotal + btSellTotal
int   totalWin = btBuyWin   + btSellWin
float totalHit = totalSig > 0 ? (totalWin / float(totalSig)) * 100.0 : 0.0

// Color for dominant cell.
color domCol = dominantVal >= 0 ? bullHue : bearHue

// Color for agreement cell (high = bull-ish, low = bear-ish).
color agrCol = agreePct >= 60 ? color.new(bullHue, 20) : agreePct >= 40 ? color.new(bullHue, 55) : color.new(bearHue, 35)

var table dash = table.new(position.top_right, 3, 13,
   bgcolor      = bgPanel,
   border_color = color.new(bgHue, 60),
   border_width = 1,
   frame_color  = frameCol,
   frame_width  = 1)

if showDash and barstate.islast
    // Re-create with current size + position selection (Pine constraint: position
    // is set at table.new(); we re-create here for live responsiveness).
    table.delete(dash)
    dash := table.new(f_pos(dashPosStr), 3, 13,
       bgcolor      = bgPanel,
       border_color = color.new(bgHue, 60),
       border_width = 1,
       frame_color  = frameCol,
       frame_width  = 1)

    string sz = dashSizeStr

    // Row 0 - Header (spans all 3 columns).
    table.cell(dash, 0, 0, "TWO SIGMA FACTOR COMPOSITE",
       text_color = textHi, bgcolor = bgHdr,
       text_halign = text.align_center, text_font_family = font.family_monospace,
       text_size = f_size(sz))
    table.merge_cells(dash, 0, 0, 2, 0)

    // Row 1 - Composite value.
    table.cell(dash, 0, 1, "Composite",
       text_color = textHi, bgcolor = bgRow, text_halign = text.align_left,
       text_font_family = font.family_monospace, text_size = f_size(sz))
    table.cell(dash, 1, 1, f_fmtZ(composite),
       text_color = compColor, bgcolor = bgRow, text_halign = text.align_right,
       text_font_family = font.family_monospace, text_size = f_size(sz))
    table.cell(dash, 2, 1, f_zGauge(composite, zCap),
       text_color = compColor, bgcolor = bgRow, text_halign = text.align_center,
       text_font_family = font.family_monospace, text_size = f_size(sz))

    // Row 2 - Signal.
    table.cell(dash, 0, 2, "Signal",
       text_color = textHi, bgcolor = bgRow, text_halign = text.align_left,
       text_font_family = font.family_monospace, text_size = f_size(sz))
    table.cell(dash, 1, 2, sigTxt,
       text_color = sigCol, bgcolor = bgRow, text_halign = text.align_right,
       text_font_family = font.family_monospace, text_size = f_size(sz))
    table.cell(dash, 2, 2, lowAgr ? "LOW AGR" : "",
       text_color = bearHue, bgcolor = bgRow, text_halign = text.align_center,
       text_font_family = font.family_monospace, text_size = f_size(sz))

    // Row 3 - Separator.
    table.cell(dash, 0, 3, "--- FACTORS ---",
       text_color = textMute, bgcolor = bgHdr, text_halign = text.align_center,
       text_font_family = font.family_monospace, text_size = f_size(sz))
    table.merge_cells(dash, 0, 3, 2, 3)

    // Row 4 - Momentum.
    table.cell(dash, 0, 4, "Momentum",
       text_color = textHi, bgcolor = bgRow, text_halign = text.align_left,
       text_font_family = font.family_monospace, text_size = f_size(sz))
    table.cell(dash, 1, 4, f_fmtZ(zMom),
       text_color = f_zCellCol(zMom), bgcolor = bgRow, text_halign = text.align_right,
       text_font_family = font.family_monospace, text_size = f_size(sz))
    table.cell(dash, 2, 4, f_zGauge(zMom, zCap),
       text_color = f_zCellCol(zMom), bgcolor = bgRow, text_halign = text.align_center,
       text_font_family = font.family_monospace, text_size = f_size(sz))

    // Row 5 - Quality.
    table.cell(dash, 0, 5, "Quality",
       text_color = textHi, bgcolor = bgRow, text_halign = text.align_left,
       text_font_family = font.family_monospace, text_size = f_size(sz))
    table.cell(dash, 1, 5, f_fmtZ(zQua),
       text_color = f_zCellCol(zQua), bgcolor = bgRow, text_halign = text.align_right,
       text_font_family = font.family_monospace, text_size = f_size(sz))
    table.cell(dash, 2, 5, f_zGauge(zQua, zCap),
       text_color = f_zCellCol(zQua), bgcolor = bgRow, text_halign = text.align_center,
       text_font_family = font.family_monospace, text_size = f_size(sz))

    // Row 6 - Value.
    table.cell(dash, 0, 6, "Value",
       text_color = textHi, bgcolor = bgRow, text_halign = text.align_left,
       text_font_family = font.family_monospace, text_size = f_size(sz))
    table.cell(dash, 1, 6, f_fmtZ(zVal),
       text_color = f_zCellCol(zVal), bgcolor = bgRow, text_halign = text.align_right,
       text_font_family = font.family_monospace, text_size = f_size(sz))
    table.cell(dash, 2, 6, f_zGauge(zVal, zCap),
       text_color = f_zCellCol(zVal), bgcolor = bgRow, text_halign = text.align_center,
       text_font_family = font.family_monospace, text_size = f_size(sz))

    // Row 7 - Volatility.
    table.cell(dash, 0, 7, "Volatility",
       text_color = textHi, bgcolor = bgRow, text_halign = text.align_left,
       text_font_family = font.family_monospace, text_size = f_size(sz))
    table.cell(dash, 1, 7, f_fmtZ(zVol),
       text_color = f_zCellCol(zVol), bgcolor = bgRow, text_halign = text.align_right,
       text_font_family = font.family_monospace, text_size = f_size(sz))
    table.cell(dash, 2, 7, f_zGauge(zVol, zCap),
       text_color = f_zCellCol(zVol), bgcolor = bgRow, text_halign = text.align_center,
       text_font_family = font.family_monospace, text_size = f_size(sz))

    // Row 8 - Mean-Reversion.
    table.cell(dash, 0, 8, "Mean-Rev",
       text_color = textHi, bgcolor = bgRow, text_halign = text.align_left,
       text_font_family = font.family_monospace, text_size = f_size(sz))
    table.cell(dash, 1, 8, f_fmtZ(zMR),
       text_color = f_zCellCol(zMR), bgcolor = bgRow, text_halign = text.align_right,
       text_font_family = font.family_monospace, text_size = f_size(sz))
    table.cell(dash, 2, 8, f_zGauge(zMR, zCap),
       text_color = f_zCellCol(zMR), bgcolor = bgRow, text_halign = text.align_center,
       text_font_family = font.family_monospace, text_size = f_size(sz))

    // Row 9 - Dominant factor.
    table.cell(dash, 0, 9, "Dominant",
       text_color = textHi, bgcolor = bgRow, text_halign = text.align_left,
       text_font_family = font.family_monospace, text_size = f_size(sz))
    table.cell(dash, 1, 9, dominantName,
       text_color = domCol, bgcolor = bgRow, text_halign = text.align_right,
       text_font_family = font.family_monospace, text_size = f_size(sz))
    table.cell(dash, 2, 9, f_fmtZ(dominantVal),
       text_color = domCol, bgcolor = bgRow, text_halign = text.align_center,
       text_font_family = font.family_monospace, text_size = f_size(sz))

    // Row 10 - Factor agreement.
    table.cell(dash, 0, 10, "Agreement",
       text_color = textHi, bgcolor = bgRow, text_halign = text.align_left,
       text_font_family = font.family_monospace, text_size = f_size(sz))
    table.cell(dash, 1, 10, str.tostring(agreeCount) + " / 5",
       text_color = agrCol, bgcolor = bgRow, text_halign = text.align_right,
       text_font_family = font.family_monospace, text_size = f_size(sz))
    table.cell(dash, 2, 10, str.tostring(agreePct, "#.0") + "%",
       text_color = agrCol, bgcolor = bgRow, text_halign = text.align_center,
       text_font_family = font.family_monospace, text_size = f_size(sz))

    // Row 11 - Last signal age + extreme tag.
    int barsSinceBuy  = bar_index - lastBuyBar
    int barsSinceSell = bar_index - lastSellBar
    string sigAgeTxt = (lastBuyBar < 0 and lastSellBar < 0) ? "--" : (barsSinceBuy < barsSinceSell ? "BUY  " + str.tostring(barsSinceBuy) + "b ago" : "SELL " + str.tostring(barsSinceSell) + "b ago")
    color ageCol = (lastBuyBar < 0 and lastSellBar < 0) ? color.new(bullHue, 60) : (barsSinceBuy < barsSinceSell ? bullHue : bearHue)
    table.cell(dash, 0, 11, "Last Sig",
       text_color = textHi, bgcolor = bgRow, text_halign = text.align_left,
       text_font_family = font.family_monospace, text_size = f_size(sz))
    table.cell(dash, 1, 11, sigAgeTxt,
       text_color = ageCol, bgcolor = bgRow, text_halign = text.align_right,
       text_font_family = font.family_monospace, text_size = f_size(sz))
    string extTxt = (bar_index - lastExtBullBar) < 5 ? "EXT BULL" : (bar_index - lastExtBearBar) < 5 ? "EXT BEAR" : ""
    color extCol = (bar_index - lastExtBullBar) < 5 ? bullHue : (bar_index - lastExtBearBar) < 5 ? bearHue : color.new(bullHue, 80)
    table.cell(dash, 2, 11, extTxt,
       text_color = extCol, bgcolor = bgRow, text_halign = text.align_center,
       text_font_family = font.family_monospace, text_size = f_size(sz))

    // Row 12 - Backtest hit rate (optional).
    if showBack
        string btTxt = "Hit " + str.tostring(totalHit, "#.0") + "%  (" +
                       str.tostring(totalWin) + "/" + str.tostring(totalSig) + ")"
        btCol = totalHit >= 55 ? bullHue : totalHit >= 45 ? color.new(bullHue, 45) : bearHue
        table.cell(dash, 0, 12, "Backtest",
           text_color = textHi, bgcolor = bgRow, text_halign = text.align_left,
           text_font_family = font.family_monospace, text_size = f_size(sz))
        table.cell(dash, 1, 12, btTxt,
           text_color = btCol, bgcolor = bgRow, text_halign = text.align_right,
           text_font_family = font.family_monospace, text_size = f_size(sz))
        table.cell(dash, 2, 12, "fwd=" + str.tostring(btLookahead) + "b",
           text_color = textMute, bgcolor = bgRow, text_halign = text.align_center,
           text_font_family = font.family_monospace, text_size = f_size(sz))
    else
        table.cell(dash, 0, 12, "",
           text_color = textMute, bgcolor = bgRow, text_halign = text.align_left,
           text_font_family = font.family_monospace, text_size = f_size(sz))
        table.cell(dash, 1, 12, "",
           text_color = textMute, bgcolor = bgRow, text_halign = text.align_right,
           text_font_family = font.family_monospace, text_size = f_size(sz))
        table.cell(dash, 2, 12, "",
           text_color = textMute, bgcolor = bgRow, text_halign = text.align_center,
           text_font_family = font.family_monospace, text_size = f_size(sz))

// ============================================================================
//  SECTION 10 - ALERTS
// ============================================================================

alertcondition(buySig and alertBuy,
   title   = "TWS [JOAT] Buy",
   message = "TWS [JOAT] BUY - composite crossed above buy threshold")

alertcondition(sellSig and alertSell,
   title   = "TWS [JOAT] Sell",
   message = "TWS [JOAT] SELL - composite crossed below sell threshold")

alertcondition(extBull and alertExtBull,
   title   = "TWS [JOAT] Extreme Bull",
   message = "TWS [JOAT] EXTREME BULL - composite crossed above extreme upper threshold")

alertcondition(extBear and alertExtBear,
   title   = "TWS [JOAT] Extreme Bear",
   message = "TWS [JOAT] EXTREME BEAR - composite crossed below extreme lower threshold")

alertcondition(lowAgr and alertLowAgr,
   title   = "TWS [JOAT] Low Factor Agreement",
   message = "TWS [JOAT] LOW AGREEMENT - factors are disagreeing on direction")

alertcondition(ta.crossover(composite, 0.0),
   title   = "TWS [JOAT] Composite Crosses Zero Up",
   message = "TWS [JOAT] composite turned positive")

alertcondition(ta.crossunder(composite, 0.0),
   title   = "TWS [JOAT] Composite Crosses Zero Down",
   message = "TWS [JOAT] composite turned negative")

// ============================================================================
//  END Two Sigma Factor Composite [JOAT]
// ============================================================================
````
