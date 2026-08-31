<!-- tradingview-pine-id: PUB;d6a0325e65e949068f73eb510bd15f0d -->
<!-- tradingviewscripts-format: 1 -->
# Smart Trend Filter Confirmation [MarkitTick]

Source: https://www.tradingview.com/script/G7U13owe-Smart-Trend-Filter-Confirmation-MarkitTick/

## Description

💡 A confirmed-bar trend-following system that fuses a volatility-adaptive trailing band with a six-condition consensus filter, designed to suppress the false flips that plague standard trend-following tools when markets stall, chop, or thin out. Rather than reacting to every band cross, the script cross-examines each potential signal against stall detection, slope strength, volume participation, range compression, basis-point movement, and trend strength (ADX) before allowing a flip to display — while retaining a breakout override so genuinely explosive moves are never suppressed by the very filters designed to catch noise.

✨ Originality and Utility

Trailing-band trend systems (Chandelier-style or SuperTrend-style constructs) are common on TradingView, but nearly all of them share the same weakness: the trailing line flips direction on every price crossover, regardless of whether that crossover reflects a genuine change in market character or simply noise generated during a stalled, illiquid, or compressing market. This script's originality lies in the "Regime Consensus" layer built on top of the adaptive trailing band. Six independent, mathematically distinct filters — measuring band stall, linear-regression slope, relative volume, historical range percentile, basis-point velocity, and ADX-based trend strength — are computed every bar. If any single filter flags a "flat" regime, the display direction is held at its last confirmed state instead of flipping, which materially reduces whipsaw signals in ranging conditions. A dedicated breakout override simultaneously monitors for abnormally large single-bar moves (measured in ATR multiples) and forces the flip through regardless of filter status, ensuring the system does not become sluggish during genuine volatility expansion. This combination — adaptive smoothing of the source price, a volatility- and momentum-weighted dynamic band, a multi-factor flat-market veto, and a breakout bypass — is not a simple mashup of stock indicators but an integrated decision layer where each component directly informs whether the others are permitted to act. The trend line, filters, override, and dashboard are not separable add-ons; they operate as a single signal-gating pipeline.

🔬 Methodology and Concepts

● Adaptive Source Smoothing
Before any band math is applied, the script conditions the underlying HL2-style source price using one of two selectable adaptive filters:

[*]Kalman Filter — a recursive estimator that maintains an internal "belief" about the true price and a corresponding uncertainty (error covariance). Each new bar, the filter computes a gain factor from the ratio of predicted uncertainty to total uncertainty (predicted plus measurement noise, set by the Kalman R input) and blends the new price observation into its estimate proportionally. A higher Kalman Q input allows the estimate to adapt faster to new prices; a higher Kalman R input makes the filter trust new observations less, producing a smoother but slower-reacting line.
[*]LLAMA (an adaptive-length moving average inspired by Kaufman's Efficiency Ratio concept) — measures how efficiently price has moved over the lookback window by comparing net directional change to the sum of all bar-to-bar movement (an efficiency ratio between 0 and 1). This ratio is squared into a smoothing constant that continuously shifts the moving average's responsiveness between a fast EMA-like constant and a slow EMA-like constant, so the average tightens to price during clean directional runs and widens during choppy conditions.

• Dynamic Volatility Band
The core trailing band's half-width is not a fixed ATR multiple. It is calculated from three weighted components: a base multiplier, an ATR-based term scaled by the ATR Weight input, and a normalized recent-price-movement term (capped at its own 95th percentile to prevent single outlier bars from distorting the band) scaled by the Move Weight input. This composite value is then multiplied by the current ATR and smoothed with an exponential moving average (controlled by the Smooth Len input) to prevent the band width itself from jumping erratically bar to bar.

• Trailing Trend Line Construction
The trend line follows classic chandelier-style trailing logic: while price remains above the trend line, the line can only ratchet upward (never retreating below its prior value even if the lower band momentarily dips beneath it); while price remains below the trend line, the line can only ratchet downward. A flip only occurs when confirmed prior-bar closing price crosses to the opposite side of the line.

• Six-Factor Regime Consensus Filter
Before a directional flip is permitted to display, up to six independent conditions are checked. If any active filter flags the market as "flat," the displayed direction holds at its previous confirmed state rather than flipping:

[*]Stall Filter — flags when the trend line's bar-to-bar movement is smaller than a fraction (Flatness input) of current ATR, indicating the line itself has gone quiet.
[*]Slope Filter — runs a short linear regression across recent trend-line values, measures the resulting slope, normalizes it against ATR, and flags when that normalized slope falls below the Slope Thr input.
[*]Volume Filter — flags when confirmed volume falls at or below its own moving average, treating below-average participation as unreliable for a fresh directional call.
[*]Range Filter — flags when the current bar's high-low range falls within the lower percentile band (Range Pct input) of its historical distribution over the Pctile Len lookback, identifying range compression.
[*]BPS Filter — converts the trend line's bar-to-bar movement into basis points relative to price and flags when that figure falls under the Min BPS input, catching moves too small to be economically meaningful.
[*]ADX Filter — computes a standard Directional Movement Index reading and flags when it sits below the ADX Thr input, indicating weak underlying trend strength.

• Breakout Override
Running in parallel to the consensus filters, this component measures the absolute prior-bar price change against a multiple of ATR (Ovr ATR Mult input). If that threshold is exceeded, the override forces the flip through immediately, bypassing every flat-market filter above. This prevents the filter layer from muting the system's response to genuine volatility expansion or breakout conditions.

🎨 Visual Guide

[*]Trend Line — a stepped line plotted along the confirmed trailing band value. It renders in the Bull color when the confirmed direction is up and the Bear color when down; both colors are fully customizable in the Colors group.
[*]Gradient Candles / Bar Coloring — when enabled, chart candles and bars are recolored on a gradient between the Neutral color and the active directional color, with gradient intensity scaled by how far confirmed price has extended from the trend line relative to ATR (capped at 3x ATR for full saturation). A muted candle indicates price sitting close to the trend line; a fully saturated candle indicates an extended move.
[*]Cloud Fill — a semi-transparent fill (opacity set by Cloud Transp) rendered between the trend line and a short moving average of HLC3 (length set by Cloud MA Len), tinted in the active directional color to visually reinforce which side of the trend the market currently occupies.
[*]Bull / Bear Signal Labels — a "Bull" label appears below price the bar a confirmed flip to the up-regime occurs, and a "Bear" label above price on a confirmed flip to the down-regime, provided the Regime Consensus Filter did not veto the flip and Lock Signal is not engaged.
[*]Trade Level Lines and Labels (optional, enabled via Show Trade Levels) — on each new confirmed signal, five lines are drawn forward from the signal bar: an Entry line (at prior confirmed close), a Stop Loss line, and three Take Profit lines (TP1, TP2, TP3), each offset from entry by ATR multiples set in the Trade Tools group. A shaded risk zone connects Entry to Stop Loss, and a shaded reward zone connects Entry to the furthest take-profit line. Each line carries a right-aligned label showing its exact price.
[*]Live Dashboard (optional, position configurable via Dash X / Dash Y) — a compact table summarizing current symbol/timeframe, signal lock state, active direction, current signal status, regime classification (Flat/Trending), breakout override status, active adaptive filter type, current trend-line and ATR values, a visual progress bar for trend strength, and individual on/off/flat status readouts for each of the six regime filters.
[*]Non-Standard Chart Warning — a red-bordered table automatically appears in the top-left corner if the script detects it is being run on a Heikin Ashi, Renko, Line Break, Kagi, or Point & Figure chart, warning that signal reliability is compromised on synthetic chart types.

📖 How to Use

[*]A "Bull" label with the trend line switching to the Bull color signals a confirmed transition to an up-regime that has passed all active consensus filters (or was pushed through by the breakout override).
[*]A "Bear" label with the trend line switching to the Bear color signals the equivalent confirmed down-regime transition.
[*]Because flips are gated by the consensus filter, the absence of a new signal during a period of price consolidation is intentional — the script is treating the move as noise rather than a lack of function. Check the dashboard's individual filter rows to see exactly which condition(s) are currently classifying the market as flat.
[*]The dashboard's "Override" row shows "Engaged" when the Breakout Override has just bypassed the filters — useful for distinguishing a filter-confirmed signal from a volatility-forced one.
[*]When Show Trade Levels is active, treat the Entry/SL/TP lines as a reference risk framework tied to current ATR, not a guaranteed execution plan; always verify levels make sense for the instrument and timeframe before acting on them.
[*]Enable Lock Signal to freeze the current signal state on the most recent bar, useful when reviewing historical signal behavior without new signals interrupting the current view.
[*]If the Non-Standard Chart warning appears, switch to a standard candlestick chart type before relying on any signal from this script.

⚙️ Inputs and Settings

[*]ATR Len — lookback period for the underlying ATR calculation that drives band width and multiple filter thresholds. Shorter values make the band more reactive to recent volatility; longer values smooth it out.
[*]Band Mult, ATR Weight, Move Weight — the three components that combine into the dynamic band multiplier. Band Mult sets a base width, ATR Weight scales the contribution of current ATR relative to price, and Move Weight scales the contribution of recent capped price movement.
[*]Smooth Len — the EMA length applied to the calculated band half-width, controlling how quickly the band itself can widen or narrow.
[*]Adaptive Filter / Filter Type — toggles and selects between Kalman and LLAMA smoothing of the source price feeding the trend line.
[*]Kalman Q / Kalman R — process noise and measurement noise inputs for the Kalman filter; higher Q increases responsiveness, higher R increases smoothing.
[*]LLAMA Len — lookback window for the efficiency-ratio calculation driving the LLAMA adaptive average.
[*]Stall Filter / Flatness — enables the stall check and sets the ATR-relative threshold below which trend-line movement is considered stalled.
[*]Slope Filter / Reg Len / Slope Thr — enables the regression-slope check, sets its lookback window, and sets the normalized slope threshold below which the market is considered flat.
[*]Volume Filter / Vol MA Len — enables the volume check and sets the moving-average length volume is compared against.
[*]Range Filter / Pctile Len / Range Pct — enables the range-compression check and sets the historical lookback and percentile threshold used to classify current range as compressed.
[*]BPS Filter / Min BPS — enables the basis-point movement check and sets the minimum basis-point threshold for a trend-line move to be considered meaningful.
[*]ADX Filter / ADX Len / ADX Thr — enables the ADX-based trend-strength check and sets its calculation length and minimum threshold.
[*]Breakout Ovr / Ovr ATR Mult — enables the override and sets the ATR multiple of single-bar price change required to force a flip through the filters.
[*]Show Trade Levels / SL, TP1, TP2, TP3 ATR Mult — enables the trade-level drawing tool and sets each level's distance from entry as a multiple of ATR.
[*]Bar Coloring, Bull/Bear Marks, Cloud Fill, Cloud MA Len, Cloud Transp — visual toggles and parameters controlling gradient candles, signal labels, and the cloud fill between trend line and reference average.
[*]Show Dash, Dash X, Dash Y — toggles the dashboard and sets its screen position.
[*]Long/Short/Close Action inputs — customizable text strings inserted into the "action" field of each alert's JSON payload, for direct use with automated webhook execution systems.
[*]Colors group — full color customization for bull/bear/neutral states, label text, warning banner, dashboard theme, gradient candle tiers, and trade-level line colors.

🔍 Deconstruction of the Underlying Scientific and Academic Framework

The trailing-band mechanism draws on the same volatility-normalized stop methodology popularized by Chandelier Exit-style systems, which themselves extend J. Welles Wilder's Average True Range concept into an adaptive trailing stop: rather than a fixed price distance, the stop distance breathes with recently realized volatility, tightening in calm markets and widening in turbulent ones.

The Kalman filter option applies a classical state-space estimation technique originally developed for aerospace tracking problems (Rudolf Kálmán, 1960). It treats the "true" price trend as an unobserved state to be estimated from noisy observations, recursively updating a prediction and its uncertainty at each time step and weighting new information by a gain term derived from the relative magnitude of prediction versus measurement uncertainty. Applied to price series, it produces a smoothed estimate that adapts its own responsiveness based on the ongoing balance of signal versus noise.

The LLAMA adaptive average is built on an efficiency-ratio concept in the lineage of Perry Kaufman's Adaptive Moving Average research: the ratio of net directional displacement to total path length over a window quantifies how "efficiently" price has trended, and this ratio is used to interpolate the smoothing constant between fast and slow exponential-average bounds. Markets that trend efficiently receive a fast, responsive average; markets that chop inefficiently receive a slow, heavily smoothed one.

The Slope Filter applies ordinary least squares (OLS) linear regression across a short trend-line window to extract a first-derivative estimate (slope) of the trend line's trajectory, normalizing it by ATR so the threshold behaves consistently across instruments and volatility regimes of different scale.

The ADX Filter is grounded in Wilder's Directional Movement System, which decomposes price movement into positive and negative directional components and derives a smoothed trend-strength oscillator independent of direction — a standard framework for distinguishing trending from ranging conditions.

The Range Filter's use of percentile-rank classification reflects a basic non-parametric statistical approach: rather than assuming a normal distribution of high-low ranges, it empirically ranks the current range against its own recent historical distribution, which is more robust to the fat-tailed, non-normal behavior typically observed in financial return and range series.

Collectively, the six-factor consensus mechanism reflects a general principle from ensemble/multi-condition filtering: requiring independent, structurally uncorrelated confirmations to agree (or, here, requiring none to actively veto) before acting on a signal tends to reduce the false-positive rate relative to any single condition acting alone, at the cost of some responsiveness — a classic precision/recall tradeoff which the Breakout Override is specifically designed to mitigate during high-volatility regimes.

⚠️ Disclaimer
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. We expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick
//@version=6
indicator("Smart Trend Filter Confirmation [MarkitTick]", overlay=true, max_bars_back=500, behind_chart=false)

// ── INPUTS ──────────────────────────────────────────────────
var string GRP_ST = "⚙️ Core"
i_lockSignal = input.bool (false, "🔒 Lock Signal", group=GRP_ST, tooltip="Freeze current signal · block new ones")
i_ce_p1  = input.int   (14,  "ATR Len",     minval=2,             group=GRP_ST)
i_ce_gam = input.float (2.0, "Band Mult",   minval=0.1, step=0.1, group=GRP_ST)
i_ce_phi = input.float (1.0, "ATR Weight",  minval=0.1,           group=GRP_ST)
i_ce_tau = input.float (5.0, "Move Weight", minval=0.1,           group=GRP_ST)
i_ce_kap = input.int   (1,   "Smooth Len",  minval=1,             group=GRP_ST)
i_af_on   = input.bool  (true,     "Adaptive Filter", group=GRP_ST)
i_af_type = input.string("LLAMA", "  Filter Type",   options=["Kalman", "LLAMA"], group=GRP_ST, active=i_af_on)
i_af_q    = input.float (0.010,    "  Kalman Q",      minval=0.0001, maxval=1.0,  step=0.001, group=GRP_ST, active=i_af_on and i_af_type == "Kalman")
i_af_r    = input.float (0.100,    "  Kalman R",      minval=0.001,  maxval=10.0, step=0.010, group=GRP_ST, active=i_af_on and i_af_type == "Kalman")
i_af_len  = input.int   (20,       "  LLAMA Len",     minval=2,      maxval=200,              group=GRP_ST, active=i_af_on and i_af_type == "LLAMA")

var string GRP_FG = "🛡️ Filters"
i_am_ca   = input.bool (true,  "Stall Filter",   group=GRP_FG)
i_am_ca_q = input.float(0.05,  "  Flatness",     minval=0.001, maxval=1.0,   step=0.005, group=GRP_FG, active=i_am_ca)
i_am_cb   = input.bool (true,  "Slope Filter",   group=GRP_FG)
i_am_cb_n = input.int  (5,     "  Reg Len",      minval=3,     maxval=20,                group=GRP_FG, active=i_am_cb)
i_am_cb_z = input.float(0.05,  "  Slope Thr",    minval=0.001, maxval=1.0,   step=0.005, group=GRP_FG, active=i_am_cb)
i_am_cc   = input.bool (true,  "Volume Filter",  group=GRP_FG)
i_am_cc_n = input.int  (20,    "  Vol MA Len",   minval=5,     maxval=100,               group=GRP_FG, active=i_am_cc)
i_am_cd   = input.bool (true,  "Range Filter",   group=GRP_FG)
i_am_cd_n = input.int  (100,   "  Pctile Len",   minval=20,    maxval=500,               group=GRP_FG, active=i_am_cd)
i_am_cd_p = input.float(20.0,  "  Range Pct",    minval=5.0,   maxval=50.0,  step=1.0,   group=GRP_FG, active=i_am_cd)
i_am_ce   = input.bool (true,  "BPS Filter",     group=GRP_FG)
i_am_ce_q = input.float(1.0,   "  Min BPS",      minval=0.1,   maxval=100.0, step=0.1,   group=GRP_FG, active=i_am_ce)
i_am_cg   = input.bool (true,  "ADX Filter",     group=GRP_FG)
i_am_cg_n = input.int  (14,    "  ADX Len",      minval=2,     maxval=100,               group=GRP_FG, active=i_am_cg)
i_am_cg_z = input.float(20.0,  "  ADX Thr",      minval=5.0,   maxval=60.0,  step=0.5,   group=GRP_FG, active=i_am_cg)
i_am_cf   = input.bool (true,  "Breakout Ovr",   group=GRP_FG)
i_am_cf_q = input.float(1.5,   "  Ovr ATR Mult", minval=0.5,   maxval=10.0,  step=0.1,   group=GRP_FG, active=i_am_cf)

var string GRP_TRADE = "📐 Trade Tools"
i_useLevels  = input.bool (false, "📐 Show Trade Levels", group=GRP_TRADE, tooltip="Draw Entry/SL/TP lines and labels on signal")
i_slAtrMult  = input.float(1.5,   "SL ATR Mult",  minval=0.1, step=0.1, group=GRP_TRADE, active=i_useLevels)
i_tp1AtrMult = input.float(1.5,   "TP1 ATR Mult", minval=0.1, step=0.1, group=GRP_TRADE, active=i_useLevels)
i_tp2AtrMult = input.float(3.0,   "TP2 ATR Mult", minval=0.1, step=0.1, group=GRP_TRADE, active=i_useLevels)
i_tp3AtrMult = input.float(4.5,   "TP3 ATR Mult", minval=0.1, step=0.1, group=GRP_TRADE, active=i_useLevels)

var string GRP_VIS = "🎨 Visuals"
i_vis_bc    = input.bool (true, "Bar Coloring",   group=GRP_VIS)
i_vis_sx    = input.bool (true, "Bull/Bear Marks", group=GRP_VIS)
i_cf_show   = input.bool (true, "Cloud Fill",     group=GRP_VIS)
i_cf_len    = input.int  (8,    "  Cloud MA Len", minval=1, maxval=50, group=GRP_VIS, active=i_cf_show)
i_cf_transp = input.int  (65,   "  Cloud Transp", minval=0, maxval=95, group=GRP_VIS, active=i_cf_show)

var string GRP_DSH = "📊 Dashboard"
i_vis_dx = input.bool  (true,    "Show Dash", group=GRP_DSH)
i_dsh_x  = input.string("Right", "Dash X",    options=["Left", "Center", "Right"],  group=GRP_DSH, active=i_vis_dx)
i_dsh_y  = input.string("Top",   "Dash Y",    options=["Top", "Middle", "Bottom"],  group=GRP_DSH, active=i_vis_dx)

var string GRP_WH = "🔔 Alerts"
i_actionLong       = input.string("long",       "↑ Long Action",        group=GRP_WH)
i_actionShort      = input.string("short",      "↓ Short Action",       group=GRP_WH)
i_actionCloseLong  = input.string("closelong",  "✕ Close Long Action",  group=GRP_WH)
i_actionCloseShort = input.string("closeshort", "✕ Close Short Action", group=GRP_WH)

var string GRP_COL = "🌈 Colors"
i_vis_ua   = input.color(#00E5FF,                "Bull",       group=GRP_COL, inline="c1")
i_vis_da   = input.color(#E040FB,                "Bear",       group=GRP_COL, inline="c1")
i_vis_cn   = input.color(#546E7A,                "Neutral",    group=GRP_COL, inline="c1")
i_c_txt    = input.color(color.white,            "Label Text", group=GRP_COL, inline="c2")
i_c_warn   = input.color(color.red,              "Warning",    group=GRP_COL, inline="c2")
C_DASH_HDR = input.color(color.new(#3a2a6d, 55), "Dash Hdr",   group=GRP_COL, inline="c3")
C_DASH_BG  = input.color(color.new(#0a0f1a, 10), "Dash BG",    group=GRP_COL, inline="c3")
C_DASH_TXT = input.color(#FFFFFF,                "Dash Txt",   group=GRP_COL, inline="c3")
i_c_bhi    = input.color(#26a69a,                "Bar Hi",     group=GRP_COL, inline="c4")
i_c_bmid   = input.color(#f9a825,                "Bar Mid",    group=GRP_COL, inline="c4")
i_c_blo    = input.color(#ef5350,                "Bar Lo",     group=GRP_COL, inline="c4")
i_c_sl     = input.color(#ef5350,                "SL",         group=GRP_COL, inline="c5")
i_c_entry  = input.color(#2196f3,                "Entry",      group=GRP_COL, inline="c5")
i_c_tp     = input.color(#26a69a,                "TP",         group=GRP_COL, inline="c5")

// ── UDTs ────────────────────────────────────────────────────
type SignalState
    bool  longSignal  = false
    bool  shortSignal = false
    int   direction   = 1
    float trendLine   = na

// ── CORE LOGIC ──────────────────────────────────────────────
f_kalman(float src) =>
    var float _x = na
    var float _p = 1.0
    float _xPrev = na(_x[1]) ? src : _x[1]
    float _pPred = nz(_p[1], 1.0) + i_af_q
    float _gain  = _pPred / (_pPred + i_af_r)
    _x := _xPrev + _gain * (src - _xPrev)
    _p := (1.0 - _gain) * _pPred
    _x

f_llama(float src) =>
    int   _lag  = math.max(1, math.round((i_af_len - 1) / 2.0))
    float _dl   = src + (src - src[_lag])
    float _chg  = math.abs(_dl - _dl[i_af_len])
    float _vol  = math.sum(math.abs(_dl - _dl[1]), i_af_len)
    float _er   = _vol <= 0.0 ? 0.0 : math.min(_chg / _vol, 1.0)
    float _fast = 2.0 / 3.0
    float _slow = 2.0 / 31.0
    float _sc   = math.pow(_er * (_fast - _slow) + _slow, 2)
    var float _ma = na
    _ma := na(_ma[1]) ? _dl : _ma[1] + _sc * (_dl - _ma[1])
    _ma

float atr = ta.atr(i_ce_p1)[1]

float _pmRaw    = math.abs(close[1] - close[2]) / math.max(close[2], syminfo.mintick)
float _pmP95    = ta.percentile_nearest_rank(_pmRaw, 100, 95)
float priceMove = math.min(_pmRaw, nz(_pmP95, _pmRaw))

float _mt741a = i_ce_gam + (atr / close[1]) * i_ce_phi + priceMove * i_ce_tau

float _alpha        = 2.0 / (i_ce_kap + 1.0)
float _rawHalf      = _mt741a * atr
var float _bandHalf = na
_bandHalf          := na(_bandHalf[1]) ? _rawHalf : _alpha * _rawHalf + (1.0 - _alpha) * _bandHalf[1]

float _srcRaw   = (high[1] + low[1]) / 2.0
float _srcKal   = f_kalman(_srcRaw)
float _srcLla   = f_llama(_srcRaw)
float _hl2_conf = not i_af_on ? _srcRaw : i_af_type == "Kalman" ? nz(_srcKal, _srcRaw) : nz(_srcLla, _srcRaw)
float upperBand = _hl2_conf + _bandHalf
float lowerBand = _hl2_conf - _bandHalf

var float trendLine = na
var int   direction = 1

if na(trendLine)
    trendLine := upperBand

if close[1] > trendLine[1]
    direction := 1
    trendLine := math.max(lowerBand, trendLine)
else
    direction := -1
    trendLine := math.min(upperBand, trendLine)

bool vtfFlat = i_am_ca ? (math.abs(trendLine[1] - trendLine[2]) < atr * i_am_ca_q) : false

float _lrCurr    = ta.linreg(trendLine[1], i_am_cb_n, 0)
float _lrPrev    = ta.linreg(trendLine[1], i_am_cb_n, 1)
float _lrSlope   = _lrCurr - _lrPrev
float _mt741b = math.abs(_lrSlope) / math.max(atr, syminfo.mintick)
bool  tifFlat    = i_am_cb ? (_mt741b < i_am_cb_z) : false

float _volSma    = ta.sma(volume, i_am_cc_n)
bool  lqfFlat    = i_am_cc ? (volume[1] <= nz(_volSma[1], volume[1] + 1)) : false

float _hlRange  = high[1] - low[1]
float _hlPctile = ta.percentile_nearest_rank(_hlRange, i_am_cd_n, i_am_cd_p)
bool  cdfFlat   = i_am_cd ? (_hlRange <= nz(_hlPctile, _hlRange + 1)) : false

float _bpsDelta = math.abs(trendLine[1] - trendLine[2]) / math.max(close[2], syminfo.mintick) * 10000.0
bool  bpfFlat   = i_am_ce ? (_bpsDelta < i_am_ce_q) : false

[_diPlus, _diMinus, _adxRaw] = ta.dmi(i_am_cg_n, i_am_cg_n)
float adxVal = nz(_adxRaw[1])
bool  adxFlat = i_am_cg ? (adxVal < i_am_cg_z) : false

bool breakoutDetected = i_am_cf and (math.abs(close[1] - close[2]) > atr * i_am_cf_q)

bool isFlatGuard = (vtfFlat or tifFlat or lqfFlat or cdfFlat or bpfFlat or adxFlat) and not breakoutDetected

var int displayDirection = 1
if not isFlatGuard
    displayDirection := direction

float _signalTrendLine = trendLine[0]
bool longSignal  = displayDirection[0] == 1  and displayDirection[1] == -1
bool shortSignal = displayDirection[0] == -1 and displayDirection[1] == 1

SignalState ss = SignalState.new(
     longSignal  = longSignal,
     shortSignal = shortSignal,
     direction   = displayDirection,
     trendLine   = trendLine)

bool _locked = i_lockSignal and barstate.islast

float entryPriceLong  = close[1]
float slPriceLong     = entryPriceLong - atr * i_slAtrMult
float tp1PriceLong    = entryPriceLong + atr * i_tp1AtrMult
float tp2PriceLong    = entryPriceLong + atr * i_tp2AtrMult
float tp3PriceLong    = entryPriceLong + atr * i_tp3AtrMult

float entryPriceShort = close[1]
float slPriceShort    = entryPriceShort + atr * i_slAtrMult
float tp1PriceShort   = entryPriceShort - atr * i_tp1AtrMult
float tp2PriceShort   = entryPriceShort - atr * i_tp2AtrMult
float tp3PriceShort   = entryPriceShort - atr * i_tp3AtrMult

var line  slLine    = na
var line  entryLine = na
var line  tp1Line   = na
var line  tp2Line   = na
var line  tp3Line   = na
var label slLbl     = na
var label entryLbl  = na
var label tp1Lbl    = na
var label tp2Lbl    = na
var label tp3Lbl    = na
var linefill riskFill   = na
var linefill rewardFill = na

f_deleteLevels() =>
    line.delete(slLine)
    line.delete(entryLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    line.delete(tp3Line)
    label.delete(slLbl)
    label.delete(entryLbl)
    label.delete(tp1Lbl)
    label.delete(tp2Lbl)
    label.delete(tp3Lbl)
    linefill.delete(riskFill)
    linefill.delete(rewardFill)

if i_useLevels and (ss.longSignal or ss.shortSignal) and not _locked
    f_deleteLevels()
    float _entry = ss.longSignal ? entryPriceLong : entryPriceShort
    float _sl    = ss.longSignal ? slPriceLong    : slPriceShort
    float _tp1   = ss.longSignal ? tp1PriceLong   : tp1PriceShort
    float _tp2   = ss.longSignal ? tp2PriceLong   : tp2PriceShort
    float _tp3   = ss.longSignal ? tp3PriceLong   : tp3PriceShort
    int   _x2    = bar_index + 10
    slLine    := line.new(bar_index, _sl,    _x2, _sl,    color=i_c_sl,    style=line.style_solid,  width=2)
    entryLine := line.new(bar_index, _entry, _x2, _entry, color=i_c_entry, style=line.style_dashed, width=1)
    tp1Line   := line.new(bar_index, _tp1,   _x2, _tp1,   color=color.new(i_c_tp, 40), style=line.style_dashed, width=1)
    tp2Line   := line.new(bar_index, _tp2,   _x2, _tp2,   color=color.new(i_c_tp, 20), style=line.style_dashed, width=1)
    tp3Line   := line.new(bar_index, _tp3,   _x2, _tp3,   color=color.new(i_c_tp, 0),  style=line.style_dashed, width=1)
    slLbl     := label.new(_x2, _sl,    "✕ SL "    + str.tostring(_sl,    format.mintick), style=label.style_label_left, color=i_c_sl,    textcolor=i_c_txt, size=size.small)
    entryLbl  := label.new(_x2, _entry, "▶ Entry " + str.tostring(_entry, format.mintick), style=label.style_label_left, color=i_c_entry, textcolor=i_c_txt, size=size.small)
    tp1Lbl    := label.new(_x2, _tp1,   "◆ TP1 "   + str.tostring(_tp1,   format.mintick), style=label.style_label_left, color=i_c_tp,    textcolor=i_c_txt, size=size.small)
    tp2Lbl    := label.new(_x2, _tp2,   "✦ TP2 "   + str.tostring(_tp2,   format.mintick), style=label.style_label_left, color=i_c_tp,    textcolor=i_c_txt, size=size.small)
    tp3Lbl    := label.new(_x2, _tp3,   "◆ TP3 "   + str.tostring(_tp3,   format.mintick), style=label.style_label_left, color=i_c_tp,    textcolor=i_c_txt, size=size.small)
    riskFill   := linefill.new(slLine, entryLine, color.new(i_c_sl, 80))
    rewardFill := linefill.new(entryLine, tp3Line, color.new(i_c_tp, 85))

if i_useLevels and not na(slLine) and barstate.islast
    int _extX = i_lockSignal ? bar_index + 10 : last_bar_index + 10
    line.set_x2(slLine,    _extX)
    line.set_x2(entryLine, _extX)
    line.set_x2(tp1Line,   _extX)
    line.set_x2(tp2Line,   _extX)
    line.set_x2(tp3Line,   _extX)
    label.set_x(slLbl,     _extX)
    label.set_x(entryLbl,  _extX)
    label.set_x(tp1Lbl,    _extX)
    label.set_x(tp2Lbl,    _extX)
    label.set_x(tp3Lbl,    _extX)

// ── ALERTS ──────────────────────────────────────────────────
string _regimeTxt = isFlatGuard ? "flat" : "trending"
string _entryTxt  = str.tostring(close[1], format.mintick)
string _adxTxt    = str.tostring(adxVal, "#.##")
string _filterTxt = i_af_on ? i_af_type : "off"

string _longInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"long","regime":"{3}","entry":"{4}","adx":"{5}","filter":"{6}"',
     i_actionLong, syminfo.tickerid, timeframe.period, _regimeTxt, _entryTxt, _adxTxt, _filterTxt)
string longPayload = "{" + _longInner + "}"

string _shortInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"short","regime":"{3}","entry":"{4}","adx":"{5}","filter":"{6}"',
     i_actionShort, syminfo.tickerid, timeframe.period, _regimeTxt, _entryTxt, _adxTxt, _filterTxt)
string shortPayload = "{" + _shortInner + "}"

string _closeLongInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"closelong","reason":"trend_flip","regime":"{3}","entry":"{4}","adx":"{5}","filter":"{6}"',
     i_actionCloseLong, syminfo.tickerid, timeframe.period, _regimeTxt, _entryTxt, _adxTxt, _filterTxt)
string closeLongPayload = "{" + _closeLongInner + "}"

string _closeShortInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"closeshort","reason":"trend_flip","regime":"{3}","entry":"{4}","adx":"{5}","filter":"{6}"',
     i_actionCloseShort, syminfo.tickerid, timeframe.period, _regimeTxt, _entryTxt, _adxTxt, _filterTxt)
string closeShortPayload = "{" + _closeShortInner + "}"

if ss.longSignal and barstate.isconfirmed and not _locked
    alert(longPayload,       alert.freq_once_per_bar_close)
if ss.shortSignal and barstate.isconfirmed and not _locked
    alert(shortPayload,      alert.freq_once_per_bar_close)
if ss.shortSignal and barstate.isconfirmed and not _locked
    alert(closeLongPayload,  alert.freq_once_per_bar_close)
if ss.longSignal and barstate.isconfirmed and not _locked
    alert(closeShortPayload, alert.freq_once_per_bar_close)

alertcondition(ss.longSignal  and barstate.isconfirmed and not _locked, "Bull Signal",         "MarkitTick — Bull Signal Fired")
alertcondition(ss.shortSignal and barstate.isconfirmed and not _locked, "Bear Signal",        "MarkitTick — Bear Signal Fired")
alertcondition(ss.shortSignal and barstate.isconfirmed and not _locked, "Close Long Signal",  "MarkitTick — Close Long")
alertcondition(ss.longSignal  and barstate.isconfirmed and not _locked, "Close Short Signal", "MarkitTick — Close Short")

// ── VISUALS ─────────────────────────────────────────────────
bool _isNonStdChart = chart.is_heikinashi or chart.is_renko or
     chart.is_linebreak or chart.is_kagi or chart.is_pnf

var table _warnTbl = table.new(
     position.top_left, 1, 1,
     border_color = color.new(i_c_warn, 0),
     border_width = 2,
     frame_color  = color.new(i_c_warn, 0),
     frame_width  = 2)

if _isNonStdChart
    table.cell(_warnTbl, 0, 0,
         "⚠ NON-STANDARD CHART DETECTED\n" +
         "Signals may repaint. Switch to Standard Candlestick.",
         bgcolor    = color.new(i_c_warn, 15),
         text_color = i_c_txt,
         text_size  = size.normal)

float _rawStrength   = math.abs(close[1] - trendLine[1]) / math.max(atr, syminfo.mintick)
float _trendStrength = math.min(1.0, _rawStrength / 3.0)

color _cGrad = ss.direction == 1
     ? color.from_gradient(_trendStrength, 0.0, 1.0, i_vis_cn, i_vis_ua)
     : color.from_gradient(_trendStrength, 0.0, 1.0, i_vis_cn, i_vis_da)

barcolor(i_vis_bc ? _cGrad : na)
plotcandle(
     i_vis_bc ? open  : na,
     i_vis_bc ? high  : na,
     i_vis_bc ? low   : na,
     i_vis_bc ? close : na,
     color       = i_vis_bc ? _cGrad : na,
     bordercolor = i_vis_bc ? _cGrad : na,
     wickcolor   = i_vis_bc ? _cGrad : na)

plot_up = plot(
     ss.direction == 1  ? ss.trendLine : na,
     "Up Trend",
     color     = i_vis_ua,
     linewidth = 2,
     style     = plot.style_linebr,
     display   = display.all - display.price_scale - display.status_line)

plot_down = plot(
     ss.direction == -1 ? ss.trendLine : na,
     "Down Trend",
     color     = i_vis_da,
     linewidth = 2,
     style     = plot.style_linebr,
     display   = display.all - display.price_scale - display.status_line)

float _cloudRef = ta.sma(hlc3, i_cf_len)

plot_tl  = plot(ss.trendLine, "TL Anchor", color=color.new(chart.fg_color, 100), display=display.none)
plot_ref = plot(_cloudRef,    "Cloud Ref", color=color.new(chart.fg_color, 100), display=display.none)

color _cloudClr = i_cf_show
     ? (ss.direction == 1
         ? color.new(i_vis_ua, i_cf_transp)
         : ss.direction == -1
             ? color.new(i_vis_da, i_cf_transp)
             : na)
     : na

fill(plot_tl, plot_ref, ss.trendLine, _cloudRef, _cloudClr, color(na))

plotshape(
     i_vis_sx and ss.longSignal and not _locked  ? _signalTrendLine : na,
     title     = "Bull Signal",
     style     = shape.labelup,
     location  = location.absolute,
     color     = color.new(i_vis_ua, 20),
     textcolor = i_c_txt,
     text      = "Bull",
     size      = size.small,
     offset    = 0)

plotshape(
     i_vis_sx and ss.shortSignal and not _locked ? _signalTrendLine : na,
     title     = "Bear Signal",
     style     = shape.labeldown,
     location  = location.absolute,
     color     = color.new(i_vis_da, 20),
     textcolor = i_c_txt,
     text      = "Bear",
     size      = size.small,
     offset    = 0)

// ── DASHBOARD ───────────────────────────────────────────────
var string _mt741c = switch
    i_dsh_x == "Left"   and i_dsh_y == "Top"    => position.top_left
    i_dsh_x == "Left"   and i_dsh_y == "Middle" => position.middle_left
    i_dsh_x == "Left"   and i_dsh_y == "Bottom" => position.bottom_left
    i_dsh_x == "Center" and i_dsh_y == "Top"    => position.top_center
    i_dsh_x == "Center" and i_dsh_y == "Middle" => position.middle_center
    i_dsh_x == "Center" and i_dsh_y == "Bottom" => position.bottom_center
    i_dsh_x == "Right"  and i_dsh_y == "Middle" => position.middle_right
    i_dsh_x == "Right"  and i_dsh_y == "Bottom" => position.bottom_right
    => position.top_right

var table dash = table.new(_mt741c, 2, 21,
     bgcolor      = C_DASH_BG,
     border_width = 1,
     border_color = color.new(#2a3040, 40),
     frame_width  = 1,
     frame_color  = color.new(#3a2a6d, 40))

color row_a   = C_DASH_BG
color row_b   = color.new(C_DASH_BG, 40)
color lbl_col = color.new(C_DASH_TXT, 25)
color dim_col = color.new(C_DASH_TXT, 40)

f_barColor(float pct) =>
    pct >= 0.66 ? color.new(i_c_bhi, 0) : pct >= 0.33 ? color.new(i_c_bmid, 0) : color.new(i_c_blo, 0)

f_bar(float val, float maxVal) =>
    float  _m      = math.max(nz(maxVal), 0.000001)
    float  _ratio  = nz(val) / _m
    int    _filled = math.round(math.min(_ratio, 1.0) * 10)
    string _b      = ""
    for i = 1 to 10
        _b += i <= _filled ? "█" : "░"
    _b + "  " + str.tostring(math.round(_ratio * 100)) + "%"

f_row(int row, string lbl, string val, color vc) =>
    color _bg = row % 2 == 1 ? row_a : row_b
    table.cell(dash, 0, row, "  " + lbl, bgcolor = _bg, text_color = lbl_col, text_halign = text.align_left,  text_size = size.small)
    table.cell(dash, 1, row, val + "  ", bgcolor = _bg, text_color = vc,      text_halign = text.align_right, text_size = size.small)

f_prog(int row, string lbl, float val, float maxVal) =>
    float _m = math.max(nz(maxVal), 0.000001)
    f_row(row, lbl, f_bar(val, _m), f_barColor(math.min(nz(val) / _m, 1.0)))

f_pillar(bool enabled, bool isFlat) =>
    string _txt = enabled ? (isFlat ? "Flat" : "Active") : "Off"
    color  _clr = enabled ? (isFlat ? i_vis_da : i_vis_ua) : dim_col
    [_txt, _clr]

if i_vis_dx
    table.cell(dash, 0, 0, "Smart Trend Filter",
         bgcolor = C_DASH_HDR, text_color = C_DASH_TXT, text_halign = text.align_left,  text_size = size.small)
    table.cell(dash, 1, 0, syminfo.ticker + "  ·  " + timeframe.period,
         bgcolor = C_DASH_HDR, text_color = C_DASH_TXT, text_halign = text.align_right, text_size = size.small)

    f_row(1, "Lock", i_lockSignal ? "ACTIVE" : "OFF", i_lockSignal ? i_vis_da : C_DASH_TXT)
    f_row(2, "Direction", ss.direction == 1 ? "Bullish" : "Bearish", ss.direction == 1 ? i_vis_ua : i_vis_da)

    string _sigTxt = ss.longSignal ? "Bull" : ss.shortSignal ? "Bear" : "Wait"
    color  _sigClr = ss.longSignal ? i_vis_ua : ss.shortSignal ? i_vis_da : dim_col
    f_row(3, "Signal", _sigTxt, _sigClr)
    f_row(4, "Regime", isFlatGuard ? "Flat" : "Trending", isFlatGuard ? i_vis_da : i_vis_ua)

    string _boTxt = not i_am_cf ? "Off" : breakoutDetected ? "Engaged" : "Nominal"
    color  _boClr = not i_am_cf ? dim_col : breakoutDetected ? i_vis_ua : C_DASH_TXT
    f_row(5, "Override", _boTxt, _boClr)
    f_row(6, "Adaptive", i_af_on ? i_af_type : "Off", i_af_on ? C_DASH_TXT : dim_col)

    f_row(7, "Trend Line", str.tostring(ss.trendLine, format.mintick), C_DASH_TXT)
    f_row(8, "ATR",        str.tostring(atr,          format.mintick), C_DASH_TXT)

    f_prog(9,  "Strength",  _trendStrength, 1.0)
    f_prog(10, "Slope",     _mt741b,     i_am_cb_z)
    f_prog(11, "Volume",    volume[1],      nz(_volSma[1],  volume[1]))
    f_prog(12, "Range",     _hlRange,       nz(_hlPctile,   _hlRange))
    f_prog(13, "BPS Delta", _bpsDelta,      i_am_ce_q)
    f_prog(14, "ADX",       adxVal,         100.0)

    [_p1t, _p1c] = f_pillar(i_am_ca, vtfFlat)
    f_row(15, "Stall Filter", _p1t, _p1c)
    [_p2t, _p2c] = f_pillar(i_am_cb, tifFlat)
    f_row(16, "Slope Filter", _p2t, _p2c)
    [_p3t, _p3c] = f_pillar(i_am_cc, lqfFlat)
    f_row(17, "Volume Filter", _p3t, _p3c)
    [_p4t, _p4c] = f_pillar(i_am_cd, cdfFlat)
    f_row(18, "Range Filter", _p4t, _p4c)
    [_p5t, _p5c] = f_pillar(i_am_ce, bpfFlat)
    f_row(19, "BPS Filter", _p5t, _p5c)
    [_p6t, _p6c] = f_pillar(i_am_cg, adxFlat)
    f_row(20, "ADX Filter", _p6t, _p6c)
````
