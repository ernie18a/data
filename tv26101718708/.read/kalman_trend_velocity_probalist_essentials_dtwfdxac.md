# Kalman Trend Velocity [Probalist Essentials]

- url: https://www.tradingview.com/script/dtWfdXac-Kalman-Trend-Velocity-Probalist-Essentials/
- type: indicator
- pine_id: PUB;271d5c498c0f4e738ac84c60562d4f5f
- version: 1.0

## Description

Kalman Trend Velocity tracks the speed of price movement through a real two-state Kalman filter. The velocity estimate comes with its own uncertainty from the filter's covariance matrix — so the indicator can tell you not just which way the trend is moving, but whether that movement is statistically distinguishable from noise. A trend only counts as significant when the velocity minus its own sigma clears zero, shown as the significance shading between the band and the zero line.

This is a momentum tool for traders who want a trend-speed read that respects uncertainty. It suits trend-following entries (wait for significance), exit reads (significance lost = trend may be done), and regime filtering (noise zone = stand aside). The probability panel shows what actually happened after past significance crosses on the chart you're running it on — empirical counting, not theory.

🟡 WHY THIS VERSION

Most 'Kalman' indicators on TV are just EMA variants wearing a different label. This one runs an actual two-state state-space filter: position and velocity estimated together, with a full 2×2 covariance matrix that shrinks when the filter is confident and widens when it's surprised. The velocity's sigma changes bar-to-bar — the band breathes. That's the headline.

The killer extra is the significance zone: the shaded area between the uncertainty band and zero. When velLow > 0 (bull) or velHigh < 0 (bear), the trend is statistically there. When the band straddles zero, it's noise — and the indicator says so plainly. Then there's the probability panel: it counts what happened after every past significance cross on your specific chart and timeframe, shows the win rate, the median move, and the 1-sigma spread. Not a promise. Just what the data said.

🟡 HOW IT WORKS

The filter models price as following a constant-velocity law: position advances by velocity each bar, and velocity persists until the market forces a revision. Two sources of uncertainty feed the model: process noise Q (how much velocity can change per bar) and measurement noise R (how noisy the price reading is). Each bar the filter makes a prediction, then corrects it against the actual close weighted by the Kalman gain — a ratio derived from the model's own uncertainty estimates.

The covariance matrix P carries the filter's self-assessed confidence. After many calm, trending bars the velocity variance p22 shrinks — the filter trusts its model. After a surprise price move the gain jumps and p22 expands — the filter reverts to following the data. The uncertainty band (velocity ± k·sqrt(p22)) visualises this: tight in sustained trends, wide in choppy conditions. The significance cross fires when the LOWER edge of that band clears zero on the bullish side (or the UPPER edge on the bearish side) — meaning even the pessimistic end of the velocity estimate says the trend is real. The filter operates on log-price (×100), which makes the velocity state a percent-per-bar reading and keeps the noise parameters meaningful on any price scale.

🟡 KEY FEATURES
[list]
[*]Real 2-state Kalman filter (position + velocity) — not an EMA. Covariance matrix updates every confirmed bar.
[*]Velocity uncertainty band (± k·σ_v from filter covariance p22) that widens in noise and tightens in trends.
[*]Significance shading: the zone between the uncertainty band and zero is filled in accent colour only when the trend clears the noise floor.
[*]Kalman gain K shown in readout — a low K means the filter trusts its own momentum; a high K means it's learning fast.
[*]Probability panel: kernel-smoothed distribution of forward returns after past significance crosses on the loaded chart. Bull and bear sides tracked separately.
[*]Wilson-score evidence tiers: five verdict levels from 'recent + long-run backed' to 'no edge here — treat as noise', with an edge clock showing how fresh the current regime is.
[*]Weighted signal dots with self-calibrating tiers (60th/90th percentile of past signal strength), hover tooltips showing the Read verdict at fire time and the actual outcome once it resolves.
[*]Probalist heat wave: velocity colour cycles hot/amber/mint/cyan/cold through the official ramp based on velocity magnitude. Glow toggle for visual intensity.
[*]Family signature — the uncertainty band IS the data: the layers around the velocity wave are the filter's own error estimate, widening in chaos and tightening in clean trends (not decoration)
[*]Fixed signal lanes: bull dots below the wave, bear dots above — every spaced signal carries its read-at-fire, verdict and completed outcome in the hover tooltip
[*]Scale-invariant by construction: the filter runs on log-price, so velocity reads as %/bar and the same Q/R defaults behave identically on every symbol — from sub-cent coins to BTC
[/list]

🟡 HOW TO USE
[list]
[*]Wait for significance: the bullish filter is velocity − σ_v > 0, the bearish filter is velocity + σ_v < 0. The shaded zone confirms it visually — use it as a directional filter for entries rather than acting on every velocity tick.
[*]Noise zone (no shading, background faint white): the band straddles zero — velocity exists but the filter can't distinguish it from noise. Most false breakouts happen here. Consider standing aside.
[*]Check the readout for the probability verdict before acting on a cross. 'Recent + long-run backed' means the chart's own history supported follow-through at this setup. 'No edge' means it didn't — useful context even if you still trade it.
[*]Kalman gain K in the readout row: below ~0.05 the filter is in confident-trend mode; above ~0.3 it's reacting strongly to each bar. High gain + significance cross = the filter just woke up to a new trend.
[*]Adjust Q and R to fit the instrument: raise Q for volatile assets that change trend speed quickly; raise R for noisy pairs where you want the filter to discount individual bars.
[*]Costs honesty: the median forward return on short timeframes (5m, 15m) is typically small — often 0.05–0.15% over 10 bars. That does not survive round-trip costs on most venues. The probability read is about direction consistency, not net profit. Use it as a filter alongside a structure read, not as a standalone entry signal.
[*]Weigh the median move against your round-trip costs — a backed signal with a tiny median doesn't survive fees and spread on most venues; the edge read is about direction, not net profit
[*]Tune Q (process noise) and R (measurement noise) to your market: higher Q = faster, twitchier filter; higher R = smoother, slower — the K-gain readout shows how much the filter is trusting new bars right now
[/list]

🟡 PAIRS WELL WITH

Kalman velocity tells you trend speed and whether it's statistically real — it doesn't tell you where you are in a structure or whether volume backs the move. A higher-timeframe trend filter (a daily MA slope or a weekly Kalman reading) aligns the direction bias before you act on a significance cross on a shorter chart. A volume read (relative volume or OBV direction) confirms whether the velocity move has participation behind it — velocity without volume is often a low-conviction drift. Key support and resistance levels give the natural targets and reversal zones that the oscillator can't see. The indicator explicitly does not model regime shifts, multi-timeframe confluence scoring, or volatility-adjusted position sizing — those sit in other tools.

Kalman Trend Velocity gives you a trend-speed read that knows its own uncertainty. The significance shading makes the noise/signal distinction visible at a glance. The probability panel adds the chart's own empirical record — not a model, just honest counting. Together they give a cleaner picture of when the trend is real and what the chart's history said about it.

[i]Open source under MPL-2.0. The probability layer describes past signals on your chart — it is a measurement, not a prediction, and nothing here is financial advice.[/i]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//
// ██████╗ ██████╗  ██████╗ ██████╗  █████╗ ██╗     ██╗███████╗████████╗
// ██╔══██╗██╔══██╗██╔═══██╗██╔══██╗██╔══██╗██║     ██║██╔════╝╚══██╔══╝
// ██████╔╝██████╔╝██║   ██║██████╔╝███████║██║     ██║███████╗   ██║
// ██╔═══╝ ██╔══██╗██║   ██║██╔══██╗██╔══██║██║     ██║╚════██║   ██║
// ██║     ██║  ██║╚██████╔╝██████╔╝██║  ██║███████╗██║███████║   ██║
// ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝╚══════╝   ╚═╝

// What it shows: Kalman filter velocity (trend speed) as a zero-centred oscillator,
// with an uncertainty band derived from the filter's own covariance. A trend is
// statistically significant only when velocity ± sigma clears zero — that's the
// headline signal and the significance shading makes it visible at a glance.
//
// Method: 2-state constant-velocity Kalman filter. State = [position, velocity].
// Predict step propagates the model forward; update step folds in the new close
// weighted by the Kalman gain K. The covariance P shrinks in trending markets
// (filter trusts its own model) and widens after surprises (filter reverts to data).
// Uncertainty band = velocity ± k·sqrt(p22), where p22 is the velocity variance.
//
// How to use:
//   • Significance cross UP (vel − σ_v > 0): statistically bullish trend — use
//     as a long-side directional filter or entry trigger.
//   • Significance cross DOWN (vel + σ_v < 0): statistically bearish.
//   • Wide band = regime of noise; narrow band = confident trend read.
//   • Kalman gain K shown in readout: high K = filter learning fast (choppy);
//     low K = filter trusts its own model (trending).
//   • Check the probability panel: it shows what happened after past significance
//     crosses on THIS chart — direction, not magnitude prediction.

//@version=6
indicator(title = "Kalman Trend Velocity [Probalist Essentials]", shorttitle = "Kalman [P]", overlay = false, max_lines_count = 100, max_labels_count = 500, max_boxes_count = 500, max_polylines_count = 10)

// ─────────────────────────────────────────────
// § INPUTS — CALCULATION
// ─────────────────────────────────────────────
var string GRP_CALC   = "■ Calculation"
var string GRP_EXTRA  = "■ Significance Band (Killer Extra)"
var string GRP_SIG    = "■ Signals"
var string GRP_PROB   = "■ Probability Read"
var string GRP_HTF    = "■ Higher Timeframe"
var string GRP_VIS    = "■ Visuals"
var string GRP_THEME  = "■ Probalist Theme"
var string GRP_ALERTS = "■ Alerts"

i_src    = input.source(close,  "Source",          group = GRP_CALC, tooltip = "Price series fed into the Kalman filter. Close is standard; hl2 smooths slightly.")
i_q      = input.float(0.01,   "Process Noise Q",  group = GRP_CALC, minval = 0.0001, maxval = 10.0, step = 0.001, tooltip = "Model uncertainty per bar, in percent² units (the filter runs on log-price ×100, so the same default fits every asset from SHIB to BTC). Higher Q = faster, twitchier filter.")
i_r      = input.float(1.0,    "Measurement Noise R", group = GRP_CALC, minval = 0.001, maxval = 1000.0, step = 0.1, tooltip = "Price noise per bar, in percent² units. Higher R = smoother, slower filter that trusts each new bar less. Watch the K-gain readout while tuning.")
i_kSig   = input.float(1.0,    "Sigma Multiplier k", group = GRP_EXTRA, minval = 0.1, maxval = 3.0, step = 0.1, tooltip = "Uncertainty band = velocity ± k·σ_v. k=1 = 1 standard deviation of the velocity estimate. Raise it to require stronger evidence before the trend registers as significant.")
i_showBand = input.bool(true,  "Show Uncertainty Band", group = GRP_EXTRA, tooltip = "Toggle the ± k·σ_v band around the velocity. The shaded zone between the band and zero is the significance region.")
i_showSigShade = input.bool(true, "Show Significance Shading", group = GRP_EXTRA, tooltip = "Fill the zone between velocity − σ_v and zero (bull significance) and velocity + σ_v and zero (bear significance) in accent colours.")
i_confirm = input.int(2,       "Confirm bars",     group = GRP_SIG, minval = 0, maxval = 5, tooltip = "Bars to wait before treating a significance cross as confirmed. 0 = realtime (may repaint on the live bar). 2 = confirmed, non-repainting. Default 2 is the honest mode.")
i_spacing = input.int(10,      "Signal spacing (bars)", group = GRP_SIG, minval = 1, tooltip = "Minimum bars between same-direction signals. Prevents consecutive-bar signals that would produce correlated outcome windows and mislead the statistics.")

i_probOn   = input.bool(true,  "Probability Read (master)", group = GRP_PROB, tooltip = "Master toggle: gates the entire probability layer — recording, stats, readout rows, cone, panel, tooltips, and evidence-gated alerts. Turn off for a clean price chart.")
i_coneOn   = input.bool(true,  "↳ Projection Cone",         group = GRP_PROB, tooltip = "Draw a forward cone from the most recent signal bar spanning the 16th–84th percentile band of past outcomes.")
i_panelOn  = input.bool(true,  "↳ Distribution Panel (bell curve)", group = GRP_PROB, tooltip = "Kernel-smoothed density chart drawn to the right of the last bar. Shows the empirical shape of past forward returns.")
i_readOut  = input.bool(true,  "↳ Readout panel",           group = GRP_PROB, tooltip = "The mini-readout label stack anchored in the future space. Shows current state, stats, and the Read verdict.")
i_horizon  = input.int(10,     "Horizon (bars)",            group = GRP_PROB, minval = 1, maxval = 100, tooltip = "How many bars forward to measure the outcome of each signal. Default 10 matches typical short-term momentum follow-through windows.")
i_maxSamp  = input.int(200,    "Max samples",               group = GRP_PROB, minval = 30, maxval = 500, tooltip = "Maximum outcomes stored per direction. Older samples are dropped when this limit is reached.")
i_minSamp  = input.int(20,     "Min samples for stats",     group = GRP_PROB, minval = 5, maxval = 50, tooltip = "Below this count the panel shows 'gathering' instead of statistics — avoiding false confidence on thin samples.")
i_recWin   = input.int(60,     "Recent Window (outcomes)",  group = GRP_PROB, minval = 15, maxval = 200, tooltip = "Number of most recent outcomes to compute 'recent form'. A regime shift shows up here before the long-run stats catch it.")
i_zConf    = input.string("80%", "Evidence Strictness (Wilson)", group = GRP_PROB, options = ["80%", "90%", "95%"], tooltip = "Confidence level for Wilson score lower bound. 80% = more lenient, fires earlier. 95% = requires strong statistical evidence before calling a signal 'backed'.")

i_htfOn    = input.bool(false, "Show HTF Velocity",         group = GRP_HTF, tooltip = "Display the Kalman velocity from a higher timeframe as a faint reference line. Display only — does NOT gate or score the signal. Off by default.")
i_htf      = input.timeframe("D", "HTF Timeframe",          group = GRP_HTF, tooltip = "Higher timeframe for the reference velocity line. Only visible when 'Show HTF Velocity' is on.")

i_glow     = input.bool(true,  "Glow Effect",               group = GRP_VIS, tooltip = "Stack a 3-layer halo around the velocity wave. Off = clean wave only.")
i_lw       = input.int(2,      "Wave Line Width",           group = GRP_VIS, minval = 1, maxval = 4, tooltip = "Thickness of the main velocity line.")

i_col_hot  = input.color(color.rgb(249, 115, 22),  "Wave hot (bullish end)",  group = GRP_THEME, tooltip = "Ramp endpoint for positive velocity (bullish). The wave cycles through the Probalist heat ramp between this colour and the cold end.")
i_col_cold = input.color(color.rgb(37,  99,  235),  "Wave cold (bearish end)",  group = GRP_THEME, tooltip = "Ramp endpoint for negative velocity (bearish). Deep navy #1E3A8A is a popular alternative for strong bear trends.")
i_dist_gold = input.color(color.rgb(224, 168, 0),  "Gold accent (bullish)",   group = GRP_THEME, tooltip = "Accent colour for bullish structure: significance shading above zero, bull signal dots, bullish labels, distribution panel warm side.")
i_dist_cold = input.color(color.rgb(50,  160, 255), "Blue accent (bearish)",   group = GRP_THEME, tooltip = "Accent colour for bearish structure: significance shading below zero, bear signal dots, bearish labels, distribution panel cold side.")

i_alertBull  = input.bool(true, "Alert: Bull significance cross",    group = GRP_ALERTS, tooltip = "Enable alert when velocity − σ_v crosses above zero (confirmed).")
i_alertBear  = input.bool(true, "Alert: Bear significance cross",    group = GRP_ALERTS, tooltip = "Enable alert when velocity + σ_v crosses below zero (confirmed).")
i_alertBacked = input.bool(true, "Alert: History-backed crosses only", group = GRP_ALERTS, tooltip = "Only fire an alert when the chart's own history backed follow-through at evaluation time (Wilson lower-bound > 50%, median > 0). Description of past signals, not a prediction.")

// ─────────────────────────────────────────────
// § PROBALIST HEAT — inline colour engine
// ─────────────────────────────────────────────
normScore(float score) =>
    (math.max(-100.0, math.min(100.0, score)) + 100.0) / 200.0

heatCol(float pos, float transp, color col_hot, color col_cold) =>
    color col = na
    if pos >= 0.80
        col := color.from_gradient(pos, 0.80, 1.0, color.rgb(245, 158, 11), col_hot)
    else if pos >= 0.62
        col := color.from_gradient(pos, 0.62, 0.80, color.rgb(251, 191, 36), color.rgb(245, 158, 11))
    else if pos >= 0.50
        col := color.from_gradient(pos, 0.50, 0.62, color.rgb(167, 243, 208), color.rgb(251, 191, 36))
    else if pos >= 0.40
        col := color.from_gradient(pos, 0.40, 0.50, color.rgb(56, 189, 248), color.rgb(167, 243, 208))
    else if pos >= 0.22
        col := color.from_gradient(pos, 0.22, 0.40, color.rgb(6, 182, 212), color.rgb(56, 189, 248))
    else
        col := color.from_gradient(pos, 0.0, 0.22, col_cold, color.rgb(6, 182, 212))
    color.new(col, transp)

// ─────────────────────────────────────────────
// § KALMAN FILTER — 2-state constant-velocity
// ─────────────────────────────────────────────
// State vector: x1 = position estimate, x2 = velocity estimate
// Covariance matrix P = [[p11, p12],[p12, p22]]
// Transition F = [[1,1],[0,1]], Observation H = [1,0]
var float kx1  = na   // position
var float kx2  = na   // velocity
var float kp11 = 1.0  // position variance
var float kp12 = 0.0  // cross variance
var float kp22 = 1.0  // velocity variance
var float kGain = na  // last Kalman gain (position channel)

if barstate.isconfirmed
    // SCALE INVARIANCE: the filter runs in log-price × 100 ("percent units") — absolute
    // price units made Q/R meaningless across assets (R = 1.0 meant "one dollar of noise",
    // freezing the filter flat on a $0.000005 SHIB while working fine on a $65 SOL).
    // Velocity is then %/bar on EVERY symbol with the same Q/R defaults.
    float src = math.log(math.max(i_src, 1.0e-20)) * 100.0
    // Seed on the very first confirmed bar
    if na(kx1)
        kx1 := src
        kx2 := 0.0
    // ── Predict ──
    float px1  = kx1 + kx2
    float px2  = kx2
    float pp11 = kp11 + 2.0 * kp12 + kp22 + i_q
    float pp12 = kp12 + kp22
    float pp22 = kp22 + i_q
    // ── Update ──
    float s    = pp11 + i_r          // innovation covariance (scalar)
    float k1   = pp11 / s            // gain for position
    float k2   = pp12 / s            // gain for velocity
    float innov = src - px1
    kx1   := px1 + k1 * innov
    kx2   := px2 + k2 * innov
    kp11  := (1.0 - k1) * pp11
    kp12  := (1.0 - k1) * pp12
    kp22  := pp22 - k2 * pp12
    kGain := k1

// Velocity and its uncertainty sigma (from velocity variance p22)
float vel      = nz(kx2, 0.0)
float sigmaV   = i_kSig * math.sqrt(math.max(nz(kp22, 1.0), 1e-10))
float velLow   = vel - sigmaV     // lower confidence bound
float velHigh  = vel + sigmaV     // upper confidence bound

// Significance: trend is bullish-significant when velLow > 0, bearish-significant when velHigh < 0
bool sigBull   = velLow  > 0.0
bool sigBear   = velHigh < 0.0
bool inNoise   = not sigBull and not sigBear

// ─────────────────────────────────────────────
// § HEAT COLOUR — map velocity to ±100 scale
// ─────────────────────────────────────────────
// Use a rolling reference range for normalisation
float velRange = ta.highest(math.abs(vel), 100)
float velScore = velRange > 0.0 ? math.max(-100.0, math.min(100.0, vel / velRange * 100.0)) : 0.0
float heatPos  = normScore(velScore)
color cMain    = heatCol(heatPos, 0, i_col_hot, i_col_cold)

// ─────────────────────────────────────────────
// § SIGNAL DETECTION — confirmed, non-repainting
// ─────────────────────────────────────────────
// Confirmation-gated (rule 11b): sigBull[confirm] AND NOT sigBull[confirm+1]
bool rawBullCross = sigBull[i_confirm] and not sigBull[i_confirm + 1]
bool rawBearCross = sigBear[i_confirm] and not sigBear[i_confirm + 1]

// Signal spacing — prevent correlated consecutive signals
var int lastBullBar = na
var int lastBearBar = na
bool spacedBull = na(lastBullBar) or (bar_index - lastBullBar) >= i_spacing
bool spacedBear = na(lastBearBar) or (bar_index - lastBearBar) >= i_spacing
bool sigCrossBull = rawBullCross and spacedBull
bool sigCrossBear = rawBearCross and spacedBear

if sigCrossBull
    lastBullBar := bar_index
if sigCrossBear
    lastBearBar := bar_index

// Track last direction for alias resolution
var bool lastSigWasBull = true
if sigCrossBull
    lastSigWasBull := true
if sigCrossBear
    lastSigWasBull := false

// ─────────────────────────────────────────────
// § PROBABILITY READ — outcome recording
// ─────────────────────────────────────────────
var array<float> probArrBull = array.new<float>(0)
var array<float> probArrBear = array.new<float>(0)

// Record outcomes non-repainting: signal at [horizon] offset, outcome already closed
bool recBull = i_probOn and sigCrossBull[i_horizon] and barstate.isconfirmed
bool recBear = i_probOn and sigCrossBear[i_horizon] and barstate.isconfirmed

if recBull
    float ret = close[0] == 0.0 ? na : (close[0] - close[i_horizon]) / close[i_horizon] * 100.0
    if not na(ret)
        array.push(probArrBull, ret)
        if array.size(probArrBull) > i_maxSamp
            array.shift(probArrBull)

if recBear
    // Flip sign so positive = signal was right
    float ret = close[0] == 0.0 ? na : -(close[0] - close[i_horizon]) / close[i_horizon] * 100.0
    if not na(ret)
        array.push(probArrBear, ret)
        if array.size(probArrBear) > i_maxSamp
            array.shift(probArrBear)

// ─── Stats helper ───
calcStats(array<float> arr, int recWindow) =>
    int   n       = array.size(arr)
    bool  hasStat = n >= i_minSamp
    float med     = hasStat ? array.median(arr) : na
    float p16     = hasStat ? array.percentile_nearest_rank(arr, 16) : na
    float p84     = hasStat ? array.percentile_nearest_rank(arr, 84) : na
    int   wins    = 0
    if hasStat
        for i = 0 to n - 1
            if array.get(arr, i) > 0.0
                wins += 1
    float wr      = hasStat ? wins / n * 100.0 : na
    // Recent window
    int   rStart  = math.max(0, n - recWindow)
    int   rCount  = n - rStart
    bool  hasRec  = rCount >= 15
    // Slice exists whenever the array has elements — gating it on hasStat left an
    // EMPTY slice while hasRec was already true (n 15..19) → index 0 on size 0.
    array<float> recSlice = n > 0 ? array.slice(arr, rStart, n) : array.new<float>(0)
    float rMed    = hasRec ? array.median(recSlice) : na
    int   rWins   = 0
    int   rN      = array.size(recSlice)
    if hasRec and rN > 0
        for i = 0 to rN - 1
            if array.get(recSlice, i) > 0.0
                rWins += 1
    float rWr     = hasRec ? rWins / rN * 100.0 : na
    [n, hasStat, med, p16, p84, wr, hasRec, rMed, rWr, rN]

[bN, bHas, bMed, bP16, bP84, bWr, bHasRec, bRMed, bRWr, bRN] = calcStats(probArrBull, i_recWin)
[eN, eHas, eMed, eP16, eP84, eWr, eHasRec, eRMed, eRWr, eRN] = calcStats(probArrBear, i_recWin)

// Wilson score lower bound
zWilson(string conf) =>
    conf == "95%" ? 1.960 : conf == "90%" ? 1.645 : 1.282

wilsonLB(float wr, int n, float z) =>
    float p = wr / 100.0
    float denom = 1.0 + z * z / n
    float centre = p + z * z / (2.0 * n)
    float margin = z * math.sqrt(p * (1.0 - p) / n + z * z / (4.0 * n * n))
    (centre - margin) / denom * 100.0

float zW = zWilson(i_zConf)

// Bull stats
float bLbLR  = bHas     ? wilsonLB(bWr,  bN,  zW) : na
float bLbRec = bHasRec  ? wilsonLB(bRWr, bRN, zW) : na
bool  bBackedLR  = bHas     and bLbLR  > 50.0 and bMed  > 0.0
bool  bBackedRec = bHasRec  and bLbRec > 50.0 and bRMed > 0.0
bool  bLean      = bHas     and not bBackedLR and nz(bWr, 0.0) >= 55.0 and nz(bMed, 0.0) > 0.0

// Bear stats
float eLbLR  = eHas     ? wilsonLB(eWr,  eN,  zW) : na
float eLbRec = eHasRec  ? wilsonLB(eRWr, eRN, zW) : na
bool  eBackedLR  = eHas     and eLbLR  > 50.0 and eMed  > 0.0
bool  eBackedRec = eHasRec  and eLbRec > 50.0 and eRMed > 0.0
bool  eLean      = eHas     and not eBackedLR and nz(eWr, 0.0) >= 55.0 and nz(eMed, 0.0) > 0.0

// Active direction aliases
bool   hasStats = lastSigWasBull ? bHas    : eHas
float  probMed  = lastSigWasBull ? bMed    : eMed
float  probWr   = lastSigWasBull ? bWr     : eWr
float  probP16  = lastSigWasBull ? bP16    : eP16
float  probP84  = lastSigWasBull ? bP84    : eP84
int    probN    = lastSigWasBull ? bN      : eN
bool   backedRec = lastSigWasBull ? bBackedRec : eBackedRec
bool   backedLR  = lastSigWasBull ? bBackedLR  : eBackedLR

// Evidence verdict — 5 tiers
readVerdict(bool hasS, bool bRec, bool bLR, bool lean, float wr, float rWr, float med, int n, int rn, string side) =>
    string v = ""
    if not hasS
        v := "gathering — n=" + str.tostring(n)
    else if bRec and bLR
        v := "recent + long-run back follow-through (" + str.tostring(rWr, "0") + "% " + side + ", n=" + str.tostring(rn) + ")"
    else if bRec and not bLR
        v := "recent form backs it (" + str.tostring(rWr, "0") + "% " + side + ") — long-run mixed (" + str.tostring(wr, "0") + "%)"
    else if lean
        v := "leans " + side + " (" + str.tostring(wr, "0") + "%) — building, not yet evidence"
    else if bLR and not bRec
        v := "long-run backed, but recent form cooled (" + str.tostring(rWr, "0") + "% recent)"
    else
        v := "no edge in history here (" + str.tostring(wr, "0") + "%) — treat as noise"
    v

string bVerdict = readVerdict(bHas, bBackedRec, bBackedLR, bLean, nz(bWr), nz(bRWr), nz(bMed), bN, bRN, "↑")
string eVerdict = readVerdict(eHas, eBackedRec, eBackedLR, eLean, nz(eWr), nz(eRWr), nz(eMed), eN, eRN, "↓")

// Active verdict for last direction
string activeVerdict = lastSigWasBull ? bVerdict : eVerdict

// Edge clock
var int bullEdgeTime = na
var int bearEdgeTime = na
if bBackedRec and barstate.isconfirmed
    bullEdgeTime := time
if eBackedRec and barstate.isconfirmed
    bearEdgeTime := time

edgeAgo(int t) =>
    string s = "—"
    if not na(t)
        int diff = (time - t) / 1000
        if diff < 3600
            s := "now"
        else if diff < 172800
            s := str.tostring(math.floor(diff / 3600)) + "h ago"
        else
            s := str.tostring(math.floor(diff / 86400)) + "d ago"
    s

string bullEdgeStr = edgeAgo(bullEdgeTime)
string bearEdgeStr = edgeAgo(bearEdgeTime)

// ─────────────────────────────────────────────
// § WEIGHTED SIGNAL DOTS — self-calibrating tiers
// ─────────────────────────────────────────────
// Strength measure: how far velLow (bull) or -velHigh (bear) penetrates above zero
// relative to the recent sigmaV range
var array<float> strengthArr = array.new<float>(0)
float velAbs = sigBull ? velLow : (sigBear ? -velHigh : 0.0)
float recentSigma = ta.highest(sigmaV, 100)
float strMeasure = recentSigma > 0.0 ? velAbs / recentSigma : 0.0

bool anySignal = sigCrossBull or sigCrossBear
if anySignal and i_probOn
    array.push(strengthArr, strMeasure)
    if array.size(strengthArr) > 300
        array.shift(strengthArr)

// Tier thresholds — self-calibrating percentiles
float tierMed  = array.size(strengthArr) >= 30 ? array.percentile_nearest_rank(strengthArr, 60) : 0.3
float tierHigh = array.size(strengthArr) >= 30 ? array.percentile_nearest_rank(strengthArr, 90) : 0.7

// Dot size as string (Pine size constants are plain strings)
dotSize(float str_val) =>
    string sz = size.normal
    if str_val >= tierHigh
        sz := size.huge
    else if str_val >= tierMed
        sz := size.large
    sz

// Dot glyph per evidence tier
dotGlyph(bool isActBull) =>
    bool recB = isActBull ? bBackedRec : eBackedRec
    bool lrB  = isActBull ? bBackedLR  : eBackedLR
    bool ln   = isActBull ? bLean      : eLean
    string g  = "○"
    if recB
        g := "●"
    else if lrB or ln
        g := "◐"
    g

// Label arrays for dots
var array<label> dotLabels   = array.new<label>(0)
var array<int>   dotBars     = array.new<int>(0)
var array<bool>  dotIsBull   = array.new<bool>(0)
var array<string> dotBaseTip = array.new<string>(0)

// Capture strength at signal time (before potential reset)
float capturedStr = strMeasure

// Draw dots
// Lane scale — ta.* at global scope (rule 7); the wave reaches ±laneScale, lanes sit just outside.
float laneScale = math.max(ta.highest(math.abs(vel), 200), 0.0001)

if (sigCrossBull or sigCrossBear) and barstate.isconfirmed
    bool isBull   = sigCrossBull
    color dotCol  = isBull ? color.new(i_dist_gold, 0) : color.new(i_dist_cold, 0)
    // FIXED LANES (family convention): bull dots in the lower lane, bear in the upper —
    // dots at the firing velocity floated inside the wave and cluttered it.
    float dotY    = isBull ? -1.12 * laneScale : 1.12 * laneScale
    string sz     = dotSize(capturedStr)
    string glyph  = dotGlyph(isBull)
    string tipWr  = isBull ? (bHas ? str.tostring(bWr, "0.0") + "% ↑" : "n/a") : (eHas ? str.tostring(eWr, "0.0") + "% ↓" : "n/a")
    string tipMed = isBull ? (bHas ? str.tostring(bMed, "0.00") + "%" : "n/a") : (eHas ? str.tostring(eMed, "0.00") + "%" : "n/a")
    string tipP16 = isBull ? (bHas ? str.tostring(bP16, "0.00") + "%" : "n/a") : (eHas ? str.tostring(eP16, "0.00") + "%" : "n/a")
    string tipP84 = isBull ? (bHas ? str.tostring(bP84, "0.00") + "%" : "n/a") : (eHas ? str.tostring(eP84, "0.00") + "%" : "n/a")
    string rWrStr = isBull ? (bHasRec ? str.tostring(bRWr, "0") + "% recent (" + str.tostring(bRN) + ")" : "n/a") : (eHasRec ? str.tostring(eRWr, "0") + "% recent (" + str.tostring(eRN) + ")" : "n/a")
    string verd   = isBull ? bVerdict : eVerdict
    string baseTip = (isBull ? "Bull significance cross" : "Bear significance cross") + "\nRead at fire: " + tipWr + " · med " + tipMed + " · 1σ " + tipP16 + "…" + tipP84 + "\nRecent: " + rWrStr + "\n→ " + verd
    label newDot = label.new(bar_index, dotY, glyph, style = label.style_none, color = color.new(color.black, 100), textcolor = dotCol, size = sz, tooltip = baseTip + "\nOutcome after " + str.tostring(i_horizon) + "b: pending…")
    array.push(dotLabels,  newDot)
    array.push(dotBars,    bar_index)
    array.push(dotIsBull,  isBull)
    array.push(dotBaseTip, baseTip)
    // Cap at 400
    if array.size(dotLabels) > 400
        label.delete(array.shift(dotLabels))
        array.shift(dotBars)
        array.shift(dotIsBull)
        array.shift(dotBaseTip)

// Update completed outcomes — only at the completion bar, non-iterative
if barstate.isconfirmed and array.size(dotLabels) > 0
    int nDots = array.size(dotLabels)
    for di = 0 to nDots - 1
        int dBar = array.get(dotBars, di)
        if bar_index - dBar == i_horizon
            bool dBull    = array.get(dotIsBull, di)
            float outRet  = close[0] == 0.0 ? na : (dBull ? (close[0] - close[i_horizon]) / close[i_horizon] * 100.0 : -(close[0] - close[i_horizon]) / close[i_horizon] * 100.0)
            string outStr = na(outRet) ? "n/a" : str.tostring(outRet, "0.00") + "% (in signal direction)"
            string bTip   = array.get(dotBaseTip, di)
            label lbl     = array.get(dotLabels, di)
            label.set_tooltip(lbl, bTip + "\nOutcome after " + str.tostring(i_horizon) + "b: " + outStr)

// ─────────────────────────────────────────────
// § MAIN PLOTS
// ─────────────────────────────────────────────
// Zero line
hline(0, "Zero", color = color.new(color.white, 60), linestyle = hline.style_solid, linewidth = 1)

// Glow layers — 3-layer halo (gated by i_glow)
float glowOff1 = sigmaV * 0.25
float glowOff2 = sigmaV * 0.55
float glowOff3 = sigmaV * 1.0
color glowC1 = i_glow ? color.new(cMain, 65) : na
color glowC2 = i_glow ? color.new(cMain, 80) : na
color glowC3 = i_glow ? color.new(cMain, 90) : na

pGlow1a = plot(i_glow ?  vel + glowOff1 : na, "G1a", color = na, editable = false, display = display.none)
pGlow1b = plot(i_glow ?  vel - glowOff1 : na, "G1b", color = na, editable = false, display = display.none)
pGlow2a = plot(i_glow ?  vel + glowOff2 : na, "G2a", color = na, editable = false, display = display.none)
pGlow2b = plot(i_glow ?  vel - glowOff2 : na, "G2b", color = na, editable = false, display = display.none)
pGlow3a = plot(i_glow ?  vel + glowOff3 : na, "G3a", color = na, editable = false, display = display.none)
pGlow3b = plot(i_glow ?  vel - glowOff3 : na, "G3b", color = na, editable = false, display = display.none)
fill(pGlow1a, pGlow1b, color = glowC1)
fill(pGlow2a, pGlow2b, color = glowC2)
fill(pGlow3a, pGlow3b, color = glowC3)

// Uncertainty band plots
color bandCol = color.new(color.white, 70)
pVelHigh = plot(i_showBand ? velHigh : na, "Vel +σ", color = bandCol, linewidth = 1, style = plot.style_line)
pVelLow  = plot(i_showBand ? velLow  : na, "Vel −σ", color = bandCol, linewidth = 1, style = plot.style_line)

// Significance shading — between band bound and zero
// Bull significance: zone from 0 to velLow when velLow > 0
// Bear significance: zone from velHigh to 0 when velHigh < 0
float sigShadeBullTop = i_showSigShade and sigBull ? velLow  : na
float sigShadeBullBot = i_showSigShade and sigBull ? 0.0     : na
float sigShadeBearTop = i_showSigShade and sigBear ? 0.0     : na
float sigShadeBearBot = i_showSigShade and sigBear ? velHigh : na

pSigBullTop = plot(sigShadeBullTop, "SigBullTop", color = na, editable = false)
pSigBullBot = plot(sigShadeBullBot, "SigBullBot", color = na, editable = false)
pSigBearTop = plot(sigShadeBearTop, "SigBearTop", color = na, editable = false)
pSigBearBot = plot(sigShadeBearBot, "SigBearBot", color = na, editable = false)
fill(pSigBullTop, pSigBullBot, color = color.new(i_dist_gold, 55), title = "Bull Significance Zone")
fill(pSigBearTop, pSigBearBot, color = color.new(i_dist_cold, 55), title = "Bear Significance Zone")

// Main velocity wave + gradient fill
pMain = plot(vel, "Velocity", color = cMain, linewidth = i_lw, style = plot.style_line)
pZero = plot(0.0, "Zero Base", color = na, editable = false)
fill(pMain, pZero, top_value = vel, bottom_value = 0.0, top_color = color.new(cMain, 25), bottom_color = color.new(cMain, 92), title = "Velocity Wave Fill")

// Background: noise zone shading (very faint)
bgNoiseCol = inNoise ? color.new(color.white, 94) : na
bgcolor(bgNoiseCol, title = "Noise Zone")

// Full-history baseline circles (always visible, no label cap)
plot(sigCrossBull ? -sigmaV * 3.0 : na, "Bull signal history", color = color.new(i_dist_gold, 28), style = plot.style_circles, linewidth = 2)
plot(sigCrossBear ?  sigmaV * 3.0 : na, "Bear signal history", color = color.new(i_dist_cold, 28), style = plot.style_circles, linewidth = 2)

// HTF velocity display line
float htfVel = request.security(syminfo.tickerid, i_htf, kx2[1], lookahead = barmerge.lookahead_off)
plot(i_htfOn ? htfVel : na, "HTF Velocity", color = color.new(color.white, 75), linewidth = 1, style = plot.style_line)

// ─────────────────────────────────────────────
// § PROBABILITY CONE & DISTRIBUTION PANEL
// ─────────────────────────────────────────────
// Track the most recent signal bar and its velocity value
var int   lastSigBar  = na
var float lastSigVel  = na
var bool  lastSigBull2 = true

if sigCrossBull and barstate.isconfirmed
    lastSigBar   := bar_index
    lastSigVel   := vel
    lastSigBull2 := true
if sigCrossBear and barstate.isconfirmed
    lastSigBar   := bar_index
    lastSigVel   := vel
    lastSigBull2 := false

// Cone handles
var box    coneBox    = na
var line   coneMedLn  = na
var label  coneMedLbl = na

// Panel handles
var array<box>   panelBoxes  = array.new<box>(0)
var line         panelZeroLn = na
var label        panelZeroLbl = na
var label        panelMedLbl = na
var line         panelMedLn  = na
var label        panelLiveLbl = na
var line         panelLiveLn  = na
var label        panelGatherLbl = na
var polyline     gaussPoly   = na

// Pane scaling helpers — bounded oscillator mapped 1:1 to velocity units
// We use the recent velocity range for scale
float recentVelHigh = laneScale
float paneScale     = recentVelHigh > 0.0 ? recentVelHigh : 1.0

// Panel geometry (docked top-right of pane, future space)
// Panel base = 0.6 * paneScale, height = 0.3 * paneScale
float panelBase   = 0.62  * paneScale
float panelHeight = 0.30  * paneScale
float panelTop    = panelBase + panelHeight

// Cone geometry (anchored at lastSigVel, spans forward returns mapped to pane)
// 1 percentage point = paneScale / 100 in pane units
float ptToPaneUnit = paneScale / 100.0

if barstate.islast and i_probOn
    // ── CONE ──
    box.delete(coneBox)
    line.delete(coneMedLn)
    label.delete(coneMedLbl)
    coneBox   := na
    coneMedLn := na
    coneMedLbl := na

    bool hasActiveSig = not na(lastSigBar)
    bool sigInWindow  = hasActiveSig and (bar_index - lastSigBar) <= i_horizon
    bool coneArr      = lastSigBull2 ? bHas  : eHas
    float cP16        = lastSigBull2 ? bP16  : eP16
    float cP84        = lastSigBull2 ? bP84  : eP84
    float cMed        = lastSigBull2 ? bMed  : eMed

    if i_coneOn and hasActiveSig and coneArr and not na(cP16) and not na(cP84)
        int cX1 = lastSigBar
        int cX2 = lastSigBar + i_horizon
        float cBot = lastSigVel + cP16 * ptToPaneUnit
        float cTop = lastSigVel + cP84 * ptToPaneUnit
        color coneCol = lastSigBull2 ? i_dist_gold : i_dist_cold
        coneBox := box.new(cX1, cTop, cX2, cBot, border_color = color.new(coneCol, 50), bgcolor = color.new(coneCol, 82), border_width = 1)
        float medY = lastSigVel + nz(cMed) * ptToPaneUnit
        coneMedLn  := line.new(cX1, medY, cX2, medY, color = color.new(color.rgb(224, 168, 0), 20), style = line.style_dashed, width = 1)
        coneMedLbl := label.new(cX2, medY, "med " + str.tostring(nz(cMed), "0.00") + "%", style = label.style_label_left, color = color.new(color.black, 80), textcolor = color.rgb(224, 168, 0), size = size.small)

    // ── DISTRIBUTION PANEL ──
    // Delete old panel
    if array.size(panelBoxes) > 0
        for bi = 0 to array.size(panelBoxes) - 1
            box.delete(array.get(panelBoxes, bi))
    array.clear(panelBoxes)
    line.delete(panelZeroLn)
    label.delete(panelZeroLbl)
    label.delete(panelMedLbl)
    line.delete(panelMedLn)
    label.delete(panelLiveLbl)
    line.delete(panelLiveLn)
    label.delete(panelGatherLbl)
    polyline.delete(gaussPoly)
    panelZeroLn    := na
    panelZeroLbl   := na
    panelMedLbl    := na
    panelMedLn     := na
    panelLiveLbl   := na
    panelLiveLn    := na
    panelGatherLbl := na
    gaussPoly      := na

    // Active array
    array<float> activeArr = lastSigBull2 ? probArrBull : probArrBear
    int aN = array.size(activeArr)
    int panelXStart = bar_index + i_horizon + 6
    int panelWidth  = 40
    int panelXEnd   = panelXStart + panelWidth

    if i_panelOn and aN >= i_minSamp
        // Domain: median ± 2.5 × half(p84−p16)
        float actMed  = lastSigBull2 ? bMed : eMed
        float actP16  = lastSigBull2 ? bP16 : eP16
        float actP84  = lastSigBull2 ? bP84 : eP84
        float halfBand = math.max(math.abs(nz(actP84) - nz(actP16)) / 2.0, 0.01)
        float domLo   = nz(actMed) - 2.5 * halfBand
        float domHi   = nz(actMed) + 2.5 * halfBand
        float domWidth = domHi - domLo
        // KDE bandwidth (Silverman)
        float smpStd  = array.stdev(activeArr)
        float bwKDE   = math.max(1.06 * nz(smpStd, halfBand) * math.pow(aN, -0.2), domWidth / 40.0)
        // 40 slices
        float sliceW  = domWidth / 40.0
        // Compute densities
        array<float> dens = array.new<float>(40, 0.0)
        float maxDens = 0.0001
        for si = 0 to 39
            float cx  = domLo + (si + 0.5) * sliceW
            float d   = 0.0
            for sj = 0 to aN - 1
                float samp = array.get(activeArr, sj)
                float diff = (cx - samp) / bwKDE
                d += math.exp(-0.5 * diff * diff)
            array.set(dens, si, d)
            if d > maxDens
                maxDens := d
        // Draw slices — 3 stacked boxes per slice with density > 0.02
        color distColHot = lastSigBull2 ? i_dist_gold : i_dist_cold
        color distColCld = lastSigBull2 ? i_dist_cold : i_dist_gold
        // Upright bell: X = slice index (one bar per slice), Y = DENSITY from the
        // panel base — the generated version rotated the bell 90° (domain on Y,
        // 1/40-height slivers) which rendered as a diagonal smear of dashes.
        for si = 0 to 39
            float normD = array.get(dens, si) / maxDens
            if normD > 0.02
                color sliceCol = heatCol((si + 0.5) / 40.0, 0, distColHot, distColCld)
                int sX1 = panelXStart + si
                int sX2 = sX1 + 1
                float h = normD * panelHeight
                box bTop = box.new(sX1, panelBase + h, sX2, panelBase + h * 0.62, bgcolor = color.new(sliceCol, 28), border_color = na)
                box bMid = box.new(sX1, panelBase + h * 0.62, sX2, panelBase + h * 0.30, bgcolor = color.new(sliceCol, 55), border_color = na)
                box bBot = box.new(sX1, panelBase + h * 0.30, sX2, panelBase, bgcolor = color.new(sliceCol, 80), border_color = na)
                array.push(panelBoxes, bTop)
                array.push(panelBoxes, bMid)
                array.push(panelBoxes, bBot)
        // Gaussian overlay
        float gAvg   = array.avg(activeArr)
        float gStd   = math.max(array.stdev(activeArr), 0.0001)
        array<chart.point> gaussPts = array.new<chart.point>(0)
        for gi = 0 to 24
            float gx   = domLo + gi / 24.0 * domWidth
            float gPdf = math.exp(-0.5 * math.pow((gx - gAvg) / gStd, 2.0))
            float gY   = panelBase + gPdf * panelHeight * 0.85
            array.push(gaussPts, chart.point.from_index(panelXStart + math.round(gi / 24.0 * 39), gY))
        gaussPoly := polyline.new(gaussPts, curved = true, line_color = color.new(color.white, 45), line_width = 1)
        // Zero line marker
        float zeroMapY = panelBase + (-domLo) / domWidth * panelHeight
        if zeroMapY >= panelBase and zeroMapY <= panelTop
            panelZeroLn  := line.new(panelXStart, zeroMapY, panelXEnd, zeroMapY, color = color.new(color.gray, 50), style = line.style_dotted, width = 1)
            panelZeroLbl := label.new(panelXStart - 1, zeroMapY, "0", style = label.style_label_right, color = color.new(color.black, 80), textcolor = color.new(color.gray, 40), size = size.tiny)
        // Median marker
        float medMapY = panelBase + (nz(actMed) - domLo) / domWidth * panelHeight
        panelMedLn  := line.new(panelXStart, medMapY, panelXEnd, medMapY, color = color.new(color.rgb(224, 168, 0), 20), style = line.style_dashed, width = 1)
        string medTag = (lastSigBull2 ? "bull · " : "bear · ") + "med " + str.tostring(nz(actMed), "0.00") + "%"
        panelMedLbl := label.new(panelXEnd, panelTop + panelHeight * 0.08, medTag, style = label.style_label_left, color = color.new(color.black, 80), textcolor = color.rgb(224, 168, 0), size = size.small)
        // Live marker — running return on latest signal (unconfirmed tail, display only)
        if hasActiveSig and sigInWindow
            float liveRet = lastSigVel == 0.0 ? na : (close - close[bar_index - lastSigBar]) / math.abs(lastSigVel) * 10.0
            float liveMapY = na(liveRet) ? na : panelBase + (nz(liveRet) - domLo) / domWidth * panelHeight
            if not na(liveMapY) and liveMapY >= panelBase and liveMapY <= panelTop
                float liveLnTop = panelBase + panelHeight * 0.70
                panelLiveLn  := line.new(panelXStart, liveMapY, panelXEnd, liveMapY, color = color.new(color.white, 30), style = line.style_dotted, width = 1)
                panelLiveLbl := label.new(panelXEnd, panelBase + panelHeight * 0.72, "live", style = label.style_label_left, color = color.new(color.black, 80), textcolor = color.new(color.white, 30), size = size.tiny)
    else if i_panelOn
        panelGatherLbl := label.new(panelXStart + 10, panelBase + panelHeight * 0.5, "gathering — n=" + str.tostring(aN), style = label.style_label_center, color = color.new(color.black, 35), textcolor = color.new(color.white, 40), size = size.small)

// ─────────────────────────────────────────────
// § MINI-READOUT — chart-anchored label stack
// ─────────────────────────────────────────────
var array<label> readoutLabels = array.new<label>(0)

if barstate.islast and i_probOn and i_readOut
    // Delete old readout
    if array.size(readoutLabels) > 0
        for ri = 0 to array.size(readoutLabels) - 1
            label.delete(array.get(readoutLabels, ri))
    array.clear(readoutLabels)

    int   roX   = bar_index + i_horizon + 26   // centered under the bell (panel spans +6..+46)
    float roStep = paneScale * 0.14
    float roBase = -0.95 * paneScale   // readout lives in the EMPTY lower-right; the bell owns the top

    // Row 0 — state
    string sigZone = sigBull ? "significant ↑" : (sigBear ? "significant ↓" : "noise")
    string gainStr = na(kGain) ? "n/a" : str.tostring(nz(kGain), "0.000")
    string velDir  = vel > 0.0 ? "rising" : (vel < 0.0 ? "falling" : "flat")
    string row0txt = "Kalman vel " + (vel >= 0 ? "+" : "") + str.tostring(vel, "0.00") + "%/bar · " + velDir + " · " + sigZone
    label r0 = label.new(roX, roBase + 5.0 * roStep, row0txt, style = label.style_label_center, color = color.new(color.black, 15), textcolor = color.new(color.white, 0), size = size.normal)
    array.push(readoutLabels, r0)

    // Row 1 — context
    string row1txt = "σ_v " + str.tostring(sigmaV, "0.0000") + "  ·  K gain " + gainStr
    color row1col  = cMain
    label r1 = label.new(roX, roBase + 4.0 * roStep, row1txt, style = label.style_label_center, color = color.new(color.black, 15), textcolor = color.new(row1col, 0), size = size.small)
    array.push(readoutLabels, r1)

    // Row 2 — bull stats
    string row2txt = ""
    if bHas
        row2txt := "Bull sig (" + str.tostring(i_horizon) + "b n=" + str.tostring(bN) + "):  " + str.tostring(bWr, "0.0") + "% ↑  med " + str.tostring(bMed, "0.00") + "%  1σ " + str.tostring(bP16, "0.00") + "…" + str.tostring(bP84, "0.00") + "%"
    else
        row2txt := "Bull sig: gathering — n=" + str.tostring(bN)
    label r2 = label.new(roX, roBase + 3.0 * roStep, row2txt, style = label.style_label_center, color = color.new(color.black, 15), textcolor = color.new(i_dist_gold, 0), size = size.small)
    array.push(readoutLabels, r2)

    // Row 3 — bear stats
    string row3txt = ""
    if eHas
        row3txt := "Bear sig (" + str.tostring(i_horizon) + "b n=" + str.tostring(eN) + "):  " + str.tostring(eWr, "0.0") + "% ↓  med " + str.tostring(eMed, "0.00") + "%  1σ " + str.tostring(eP16, "0.00") + "…" + str.tostring(eP84, "0.00") + "%"
    else
        row3txt := "Bear sig: gathering — n=" + str.tostring(eN)
    label r3 = label.new(roX, roBase + 2.0 * roStep, row3txt, style = label.style_label_center, color = color.new(color.black, 15), textcolor = color.new(i_dist_cold, 0), size = size.small)
    array.push(readoutLabels, r3)

    // Row 4 — Read
    bool  anySig4 = sigBull or sigBear
    string readTxt = ""
    color  readCol = color.new(color.white, 20)
    if anySig4
        string sigLabel = sigBull ? "Bull" : "Bear"
        readTxt := "Read: " + sigLabel + " sig active — " + activeVerdict
        readCol := sigBull ? color.new(i_dist_gold, 0) : color.new(i_dist_cold, 0)
    else
        readTxt := "Read: in noise band — no active significance cross"
        readCol := color.new(color.white, 40)
    label r4 = label.new(roX, roBase + 1.0 * roStep, readTxt, style = label.style_label_center, color = color.new(color.black, 15), textcolor = readCol, size = size.small)
    array.push(readoutLabels, r4)

    // Row 5 — Edge clock + footer
    string footTxt = "Edge last seen — bull " + bullEdgeStr + " · bear " + bearEdgeStr + " | Essentials · this chart's own history, not a prediction"
    label r5 = label.new(roX, roBase, footTxt, style = label.style_label_center, color = color.new(color.black, 15), textcolor = color.new(color.white, 55), size = size.tiny)
    array.push(readoutLabels, r5)

// ─────────────────────────────────────────────
// § ALERTS
// ─────────────────────────────────────────────
// Evidence gate (recent-backed = current regime)
bool evBacked      = i_probOn and backedRec
bool evBackedBull  = i_probOn and bBackedRec
bool evBackedBear  = i_probOn and eBackedRec

bool alertBullFire = sigCrossBull and barstate.isconfirmed
bool alertBearFire = sigCrossBear and barstate.isconfirmed
bool alertBullBack = alertBullFire and evBackedBull
bool alertBearBack = alertBearFire and evBackedBear

alertcondition(alertBullFire, title = "Kalman Trend Velocity: Bull Significance Cross", message = "Kalman velocity − σ crossed above zero. Statistically significant bullish trend initiated. Non-repainting (confirmed). Not a prediction.")
alertcondition(alertBearFire, title = "Kalman Trend Velocity: Bear Significance Cross", message = "Kalman velocity + σ crossed below zero. Statistically significant bearish trend initiated. Non-repainting (confirmed). Not a prediction.")
alertcondition(alertBullBack, title = "Kalman Trend Velocity: Bull Significance Cross (history-backed)", message = "Kalman bull significance cross — chart history recently backed follow-through at this setup. Description of past signals, not a prediction.")
alertcondition(alertBearBack, title = "Kalman Trend Velocity: Bear Significance Cross (history-backed)", message = "Kalman bear significance cross — chart history recently backed follow-through at this setup. Description of past signals, not a prediction.")
alertcondition(not sigBull[1] and not sigBear[1] and (sigBull or sigBear), title = "Kalman Trend Velocity: Significance Entered", message = "Kalman velocity has entered statistically significant territory. Non-repainting. Not a prediction.")
alertcondition(sigBull[1] and inNoise and barstate.isconfirmed, title = "Kalman Trend Velocity: Bull Significance Lost", message = "Kalman bull trend significance lost — velocity uncertainty band re-crossed zero. Not a prediction.")
alertcondition(sigBear[1] and inNoise and barstate.isconfirmed, title = "Kalman Trend Velocity: Bear Significance Lost", message = "Kalman bear trend significance lost — velocity uncertainty band re-crossed zero. Not a prediction.")
````
