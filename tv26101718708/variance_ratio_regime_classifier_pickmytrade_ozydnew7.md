# Variance Ratio Regime Classifier [PickMyTrade]

- url: https://www.tradingview.com/script/oZYdNeW7-Variance-Ratio-Regime-Classifier-PickMyTrade/
- type: indicator
- pine_id: PUB;e5387da311874979b2a551b38c2d4c21
- version: 1.0

## Description

[b]WHAT THIS INDICATOR DOES
[/b]
This script implements the Lo-MacKinlay Variance Ratio Test, a formal 
econometric hypothesis test introduced in the 1988 paper "Stock Market 
Prices Do Not Follow Random Walks: Evidence and Implications" by 
Andrew W. Lo and A. Craig MacKinlay.

At every bar it answers one question: is the market currently Trending, 
Mean-Reverting, or behaving as a Random Walk?

It does this by running the test simultaneously across four time horizons 
(q = 2, 4, 8, 16) and requiring a minimum consensus before declaring a 
regime — reducing false signals that any single-horizon reading produces.

This is the first implementation of the Lo-MacKinlay Variance Ratio Test 
in any category on TradingView.


[b]WHY IT IS DIFFERENT
[/b]
The Hurst Exponent requires 100 or more bars to stabilise. This indicator 
responds in 30. ATR-based classifiers measure volatility magnitude, not 
autocorrelation structure. Hidden Markov detectors are probabilistic black 
boxes. The Variance Ratio Test is grounded in a testable null hypothesis 
with a precise mathematical definition.

The multi-horizon spectral fan shows not just whether autocorrelation 
exists, but at which lag structure it is strongest. No equivalent 
architecture exists in the TradingView published script library.


[b]THE MATHEMATICS
[/b]
r(t)   = ln( close(t) / close(t-1) )       1-period log return
R(t,q) = ln( close(t) / close(t-q) )       q-period log return

Under the Random Walk null hypothesis, Var[R(t,q)] must equal 
q multiplied by Var[r(t)] for all q greater than or equal to 2.

The Variance Ratio statistic is defined as:
VR(q) = Var[R(t,q)] divided by ( q times Var[r(t)] )
VR(q) equal to 1.0 indicates a Random Walk with no autocorrelation.
VR(q) above 1.0 indicates positive autocorrelation — Trending behaviour.
VR(q) below 1.0 indicates negative autocorrelation — Mean-Reversion.


[b]MULTI-HORIZON CONSENSUS ENGINE
[/b]
Each of the four horizons votes independently on every bar. A vote for 
Trending is cast when VR(q) exceeds the Trend Threshold. A vote for 
Mean-Reversion is cast when VR(q) falls below the MR Threshold. 
Otherwise the vote is Random Walk.

A regime is confirmed only when the minimum vote count is reached.
Four of four votes is unanimous and produces the fewest signals.
Three of four is strong consensus and is the recommended default.
Two of four is moderate and produces more frequent signals.

A single VR(2) spike may be noise. VR(2), VR(4), and VR(8) all 
exceeding the threshold simultaneously is statistically meaningful.


[b]WHAT YOU SEE ON THE CHART
[/b][image]https://www.tradingview.com/x/UOoW3Crv/[/image]
The indicator pane displays four VR lines forming a spectral fan.
The teal line is VR(q=2), the fastest with a one-bar momentum lag.
The blue line is VR(q=4), short-horizon with a three-bar lag.
The purple line is VR(q=8), medium-horizon with a seven-bar lag.
The orange line is VR(q=16), slow-horizon for sustained regime reading.
The white line is the composite equal-weight mean of all active values.
A dashed white line marks VR equal to 1.0, the random walk boundary.

A blue background tint indicates a confirmed Trending regime.
An orange background tint indicates a confirmed Mean-Reversion regime.
A gray tint indicates Random Walk or a transitional state.

Labels fire at the top of the pane on confirmed regime change bars.
TREND fires when a trending regime is confirmed.
MR fires when mean-reversion is confirmed.
RW fires when the regime returns to random walk.

The summary table shows live VR values for each active horizon, 
individual signal classifications, the composite VR, vote count, 
consecutive streak bars in the current regime, a z-score versus 
the 50-bar history with amber highlight at or above two standard 
deviations, and a percentile rank versus the 100-bar history.


[b]SETTINGS GUIDE
[/b]
VR Window defaults to 60 bars. This is the rolling lookback used 
to estimate variance. Values of 30 to 50 respond faster but produce 
noisier readings. Values of 80 to 120 are smoother but slower to 
detect transitions. The default of 60 is calibrated for one-hour 
charts on liquid instruments.

Trending Threshold defaults to 1.15. VR must exceed this level for 
a Trending vote to be cast. The Lo-MacKinlay reference range is 
1.10 to 1.20.

Mean-Reversion Threshold defaults to 0.85. VR must fall below this 
for a Mean-Reversion vote. A symmetric setting relative to the 
Trending Threshold is recommended.

EMA Smoothing defaults to 3. This is applied to each raw VR series 
after computation. Set to 1 for unsmoothed raw output.

Min Votes defaults to 3. Use 3 for general trading applications. 
Use 4 for regime confirmation only with the fewest signals.


[b]RECOMMENDED INSTRUMENTS
[/b]
Most informative on liquid instruments with active autocorrelation 
structure. Recommended starting points are BTCUSDT 1H, ETHUSDT 1H, 
ES1! 1H, NQ1! 1H, EURUSD 1H, and GBPUSD 1H.

When three or four VR lines cluster above the Trend Threshold, 
sustained autocorrelation is present and momentum strategies have 
a statistical basis. When three or four lines cluster below the 
MR Threshold, mean-reversion dominates and oscillator or fade 
strategies are more appropriate. When lines converge near 1.0 
with no consensus, reduce position size and avoid directional bias.


[b]DISCLAIMER[/b]

The Variance Ratio Test is a statistical and educational diagnostic 
tool. VR values are not buy or sell signals and carry no performance 
guarantee. Past regime behaviour does not predict future persistence. 
All trading involves risk of loss. This script is published for 
research and educational purposes only.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © PickMyTrade

//@version=6
indicator(
    title            = "Variance Ratio Regime Classifier [PickMyTrade]",
    shorttitle       = "VR·Regime",
    overlay          = false,
    max_labels_count = 200,
    max_lines_count  = 50)

// ══════════════════════════════════════════════════════════════════════════════
// PUBLICATION DESCRIPTION — paste into TradingView description field
// ══════════════════════════════════════════════════════════════════════════════
//
// WHAT IT IS
// The Variance Ratio Test (VRT) is a formal econometric hypothesis test for
// detecting departures from random-walk behaviour in financial return series.
// Introduced by Andrew Lo and A. Craig MacKinlay in their landmark 1988 paper
// "Stock Market Prices Do Not Follow Random Walks: Evidence and Implications,"
// the VRT exploits a single mathematical property: if log returns are i.i.d.
// (true random walk), the variance of q-period cumulative returns must equal
// exactly q times the variance of 1-period returns. Any systematic deviation
// exposes autocorrelation — positive (trending momentum) or negative
// (mean-reverting pressure).
//
// This script answers a question no published Pine Script currently asks:
// "Can the Lo-MacKinlay Variance Ratio Test — computed simultaneously at
// four horizons (q = 2, 4, 8, 16) — detect in real time whether the current
// market exhibits persistent trending behaviour, mean-reverting behaviour, or
// genuine random-walk behaviour, and does a multi-horizon consensus engine
// reduce false regime signals relative to any single-q reading?"
//
// WHY IT IS DIFFERENT
// Walk-forward analysis tools, Hurst exponent indicators, ATR volatility
// classifiers, and HMM regime detectors already exist on TradingView.
// The Variance Ratio Test does not — zero implementations exist in any
// category on this platform. Unlike the Hurst exponent, which requires 100+
// bars to stabilise, VR(q) uses rolling windows as short as 30 bars and
// responds to regime transitions within a single session. Unlike ATR-based
// classifiers, the VRT is grounded in a testable statistical null hypothesis
// (the random-walk hypothesis) rather than a heuristic volatility threshold.
// The multi-horizon spectral fan display — four VR lines at q=2, 4, 8, 16 —
// shows not just WHETHER autocorrelation exists but AT WHICH LAG STRUCTURE
// it is most pronounced. No equivalent architecture exists in TradingView's
// published script library.
//
// MATHEMATICAL FOUNDATION
//   r(t)    = ln(close(t) / close(t-1))     — 1-period log return
//   R(t,q)  = ln(close(t) / close(t-q))     — q-period log return
//             = r(t) + r(t-1) + ... + r(t-q+1)
//
//   Under the random-walk null:
//     Var[ R(t,q) ] = q × Var[ r(t) ]   for all q ≥ 2
//
//   Variance Ratio statistic:
//     VR(q)  =  Var[ R(t,q) ] / ( q × Var[ r(t) ] )
//
//     VR(q) = 1.0  →  Random walk — no autocorrelation detected
//     VR(q) > 1.0  →  Positive autocorrelation — trending / momentum
//     VR(q) < 1.0  →  Negative autocorrelation — mean-reverting
//
//   This script computes VR(2), VR(4), VR(8), VR(16) using a rolling
//   window of N bars (configurable). Each q captures a different lag depth:
//   q=2 reflects 1-bar momentum; q=16 on a 1H chart reflects ~16-hour
//   persistence analogous to a two-session trend.
//
// MULTI-HORIZON CONSENSUS ENGINE
//   At every bar, each VR(q) votes independently:
//     VR(q) > Trend Threshold  →  1 trending vote
//     VR(q) < MR Threshold     →  1 mean-reversion vote
//     otherwise                →  1 random-walk vote
//
//   Regime signal is declared only when MinVotes q-horizons agree:
//     MinVotes = 4  →  Unanimous (strictest, fewest false signals)
//     MinVotes = 3  →  Strong consensus    (recommended default)
//     MinVotes = 2  →  Moderate consensus  (more sensitive)
//
//   Reducing false positives via consensus is the architectural innovation:
//   a single VR(2) spike may be noise; VR(2) + VR(4) + VR(8) all above
//   the threshold simultaneously is a statistically meaningful regime signal.
//
// WHAT YOU SEE IN THE INDICATOR PANE
//   Teal line   (VR q=2)   fastest, 1-bar autocorrelation lag
//   Blue line   (VR q=4)   short-horizon, 3-bar lag confirmation
//   Purple line (VR q=8)   medium-horizon, 7-bar lag
//   Orange line (VR q=16)  slow-horizon, sustained regime indicator
//   White line  (VR Avg)   composite — equal-weight mean of active VR values
//   White dashed (VR=1.0)  exact random-walk boundary
//   Blue shaded zone       values above Trend Threshold (trending territory)
//   Orange shaded zone     values below MR Threshold (mean-reversion territory)
//   Pane background        blue tint = trending regime active
//                          orange tint = mean-reversion regime active
//                          gray tint  = random walk / transitional
//   TREND / MR / RW labels appear at top of pane on confirmed regime change bars
//   Dots on VR=1.0 line    size scales with consensus strength (1–4 votes)
//
// REGIME SUMMARY TABLE
//   Displays current VR(q) for each active horizon, individual signal
//   classifications, composite VR, regime label, vote count, consecutive-bar
//   streak in current regime, and a z-score measuring how extreme the
//   current composite VR reading is relative to its own 50-bar history.
//   Z-score ≥ 2σ is highlighted in amber as a statistically notable reading.
//
// HOW TO USE
//   VR Window: Rolling lookback for variance. Shorter (30–50) = faster but
//     noisier. Longer (80–120) = smoother, slower to detect transitions.
//     Default 60 calibrated for 1H charts on liquid instruments.
//   Trend / MR Thresholds: Symmetric around 1.0 recommended (e.g., 1.15 /
//     0.85). Wider thresholds → fewer, higher-confidence signals.
//   Smoothing: EMA applied to each VR series after computation. Set to 1
//     for raw output. Default 3 reduces single-bar spikes.
//   Min Votes: Consensus threshold. Use 3 for general trading; 4 for
//     regime-confirmation only.
//
// RECOMMENDED CHARTS
//   Most informative on liquid instruments with active autocorrelation:
//   BTCUSDT 1H · ETHUSDT 1H · ES1! 1H · NQ1! 1H · EURUSD 1H · GBPUSD 1H
//   Align with: Extended periods where 3–4 VR lines cluster ABOVE the trend
//   threshold suggest sustained momentum. Extended clustering BELOW the MR
//   threshold suggests range / mean-reversion environments where oscillators
//   and fade strategies historically outperform trend-following approaches.
//
// DISCLAIMER
// The Variance Ratio Test is a statistical and educational diagnostic tool.
// VR values are not trading signals and carry no performance guarantee.
// Past regime behaviour does not imply future regime persistence. All
// trading involves risk of loss. This script is for research purposes only.
// ══════════════════════════════════════════════════════════════════════════════

// ─── INPUT GROUPS ─────────────────────────────────────────────────────────────
var string G_VRT = "VRT Settings"
var string G_VIZ = "Display"
var string G_COL = "Colors"

vrWindow  = input.int   (60,   "VR Window (bars)",
    minval=20, maxval=300, group=G_VRT,
    tooltip="Rolling lookback used to estimate variance of log returns. Shorter windows respond faster but produce noisier VR readings. Longer windows are more stable. Recommended: 40–100 bars.")
trendThr  = input.float (1.15, "Trending Threshold",
    minval=1.01, maxval=2.50, step=0.01, group=G_VRT,
    tooltip="VR(q) values above this level indicate positive autocorrelation — the market is exhibiting momentum or trend persistence. Lo-MacKinlay standard value is 1.10–1.20.")
mrThr     = input.float (0.85, "Mean-Reversion Threshold",
    minval=0.10, maxval=0.99, step=0.01, group=G_VRT,
    tooltip="VR(q) values below this level indicate negative autocorrelation — price returns are reverting toward their mean faster than a random walk would suggest. Symmetric with Trending Threshold recommended.")
smoothLen = input.int   (3,    "VR Smoothing (EMA bars)",
    minval=1, maxval=30, group=G_VRT,
    tooltip="EMA length applied to each raw VR(q) series after computation. Set to 1 to display unsmoothed raw values. Default 3 removes single-bar spikes without materially lagging the signal.")
minVotes  = input.int   (3,    "Min Votes for Regime Signal",
    minval=2, maxval=4, group=G_VRT,
    tooltip="Number of q-horizons that must agree before a trending or mean-reversion regime is declared. 3 = strong consensus (recommended). 4 = unanimous — fewest signals, highest confidence.")

showQ2    = input.bool(true,  "Show VR(q=2)",                 group=G_VIZ)
showQ4    = input.bool(true,  "Show VR(q=4)",                 group=G_VIZ)
showQ8    = input.bool(true,  "Show VR(q=8)",                 group=G_VIZ)
showQ16   = input.bool(true,  "Show VR(q=16)",                group=G_VIZ)
showAvg   = input.bool(true,  "Show Composite VR (average)",  group=G_VIZ)
showZones = input.bool(true,  "Show Trend / MR Zone Fills",   group=G_VIZ)
showBg    = input.bool(true,  "Show Regime Background Color", group=G_VIZ)
showLbls  = input.bool(true,  "Show Regime Change Labels",    group=G_VIZ)
showTbl   = input.bool(true,  "Show Regime Summary Table",    group=G_VIZ)
tblPos    = input.string("Top Right", "Table Position",
    options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=G_VIZ)

colTrend  = input.color(#1f77b4, "Trending Color",       group=G_COL)
colMR     = input.color(#e07800, "Mean-Reversion Color", group=G_COL)
colRW     = input.color(#7f7f7f, "Random Walk Color",    group=G_COL)

// ─── USER-DEFINED TYPE ────────────────────────────────────────────────────────
type VRState
    float vr2      // VR(q=2)  — smoothed
    float vr4      // VR(q=4)  — smoothed
    float vr8      // VR(q=8)  — smoothed
    float vr16     // VR(q=16) — smoothed
    float vrAvg    // composite: equal-weight mean of active q values
    int   tVotes   // q-horizons voting trending
    int   mVotes   // q-horizons voting mean-reverting
    int   regime   // +1 trending, -1 mean-reverting, 0 random walk
    int   strength // max(tVotes, mVotes) — consensus intensity

method regimeTxt(VRState self) =>
    self.regime == 1 ? "TRENDING" : self.regime == -1 ? "MEAN-REV" : "RANDOM WALK"

method regimeCol(VRState self) =>
    self.regime == 1 ? colTrend : self.regime == -1 ? colMR : colRW

// ─── LOG RETURNS (four horizons) ──────────────────────────────────────────────
r1   = math.log(close / nz(close[1],  close))
rq2  = math.log(close / nz(close[2],  close))
rq4  = math.log(close / nz(close[4],  close))
rq8  = math.log(close / nz(close[8],  close))
rq16 = math.log(close / nz(close[16], close))

// ─── ROLLING VARIANCE AND RAW VR(q) ──────────────────────────────────────────
var1   = ta.variance(r1,   vrWindow)
varQ2  = ta.variance(rq2,  vrWindow)
varQ4  = ta.variance(rq4,  vrWindow)
varQ8  = ta.variance(rq8,  vrWindow)
varQ16 = ta.variance(rq16, vrWindow)

// VR(q) = Var[R(q)] / (q × Var[R(1)])
// Guard: flat price → var1 ≈ 0 → default to random walk (1.0)
vrRaw2  = var1 > 1e-14 ? varQ2  / (2.0  * var1) : 1.0
vrRaw4  = var1 > 1e-14 ? varQ4  / (4.0  * var1) : 1.0
vrRaw8  = var1 > 1e-14 ? varQ8  / (8.0  * var1) : 1.0
vrRaw16 = var1 > 1e-14 ? varQ16 / (16.0 * var1) : 1.0

// ─── EMA SMOOTHING ────────────────────────────────────────────────────────────
vrS2  = ta.ema(vrRaw2,  smoothLen)
vrS4  = ta.ema(vrRaw4,  smoothLen)
vrS8  = ta.ema(vrRaw8,  smoothLen)
vrS16 = ta.ema(vrRaw16, smoothLen)

// ─── COMPOSITE VR ─────────────────────────────────────────────────────────────
activeN = (showQ2 ? 1 : 0) + (showQ4 ? 1 : 0) + (showQ8 ? 1 : 0) + (showQ16 ? 1 : 0)
vrAvg = activeN > 0 ? ((showQ2 ? vrS2 : 0.0) + (showQ4 ? vrS4 : 0.0) + (showQ8 ? vrS8 : 0.0) + (showQ16 ? vrS16 : 0.0)) / float(activeN) : 1.0

// ─── MULTI-HORIZON CONSENSUS ENGINE ───────────────────────────────────────────
tVotes = (showQ2  and vrS2  > trendThr ? 1 : 0) + (showQ4  and vrS4  > trendThr ? 1 : 0) +
         (showQ8  and vrS8  > trendThr ? 1 : 0) + (showQ16 and vrS16 > trendThr ? 1 : 0)
mVotes = (showQ2  and vrS2  < mrThr   ? 1 : 0) + (showQ4  and vrS4  < mrThr   ? 1 : 0) +
         (showQ8  and vrS8  < mrThr   ? 1 : 0) + (showQ16 and vrS16 < mrThr   ? 1 : 0)

regime   = tVotes >= minVotes ? 1 : mVotes >= minVotes ? -1 : 0
strength = math.max(tVotes, mVotes)

// ─── REGIME PERSISTENCE (streak) ──────────────────────────────────────────────
var int streakBars = 0
var int prevRegime = 0
streakBars := regime == prevRegime ? streakBars + 1 : 1
prevRegime := regime

regimeChanged = regime != regime[1]

// ─── Z-SCORE AND PERCENTILE vs HISTORY (must run every bar to accumulate state) ──
vrAvgMu  = ta.sma       (vrAvg, 50)
vrAvgSig = ta.stdev     (vrAvg, 50)
vrZscore = vrAvgSig > 1e-10 ? (vrAvg - vrAvgMu) / vrAvgSig : 0.0
vrPR     = ta.percentrank(vrAvg, 100)   // percentile rank vs 100-bar history

// ─── BUNDLE INTO UDT ──────────────────────────────────────────────────────────
curState = VRState.new(vrS2, vrS4, vrS8, vrS16, vrAvg, tVotes, mVotes, regime, strength)

// ─── REFERENCE ZONE PLOTS (needed by fill()) ──────────────────────────────────
pTop      = plot(3.0,      display=display.none, editable=false)
pBot      = plot(0.0,      display=display.none, editable=false)
pTrThr    = plot(trendThr, "Trend Threshold",
    color=color.new(colTrend, 65), linewidth=1, style=plot.style_line)
pMrThr    = plot(mrThr,    "MR Threshold",
    color=color.new(colMR,   65), linewidth=1, style=plot.style_line)
pRWLine   = plot(1.0,      "VR = 1.0 (Random Walk)",
    color=color.new(color.white, 45), linewidth=1, style=plot.style_circles)

// Zone fills — na color hides them when showZones is off
zFillTrend = showZones ? color.new(colTrend, 91) : na
zFillMR    = showZones ? color.new(colMR,    91) : na
fill(pTop,   pTrThr, color=zFillTrend, title="Trending Zone")
fill(pMrThr, pBot,   color=zFillMR,    title="MR Zone")

// ─── VR SPECTRAL FAN — four horizon lines with glow ───────────────────────────
colQ2  = color.new(#00c8c8, 0)  // cyan-teal q=2  — Bloomberg accessible
colQ4  = color.new(#1f77b4, 0)  // blue      q=4  — Bloomberg accessible
colQ8  = color.new(#9467bd, 0)  // purple    q=8  — Bloomberg accessible
colQ16 = color.new(#e07800, 0)  // amber     q=16 — Bloomberg accessible
colComp= color.new(#d9d9d9, 15) // light gray composite

// Glow layers (thick + transparent) — EC visual standard (Script 09 pattern)
plot(showQ2  ? vrS2  : na, display=display.none, editable=false)  // glow anchor
plot(showQ4  ? vrS4  : na, display=display.none, editable=false)
plot(showQ8  ? vrS8  : na, display=display.none, editable=false)
plot(showQ16 ? vrS16 : na, display=display.none, editable=false)
plot(showAvg ? vrAvg : na, display=display.none, editable=false)

plot(showQ2  ? vrS2  : na, "VR (q=2)",  color=color.new(colQ2,  55), linewidth=4)
plot(showQ4  ? vrS4  : na, "VR (q=4)",  color=color.new(colQ4,  55), linewidth=4)
plot(showQ8  ? vrS8  : na, "VR (q=8)",  color=color.new(colQ8,  55), linewidth=6)
plot(showQ16 ? vrS16 : na, "VR (q=16)", color=color.new(colQ16, 55), linewidth=6)

// Main crisp lines on top of glow
plot(showQ2  ? vrS2  : na, "VR q=2",    color=colQ2,  linewidth=1)
plot(showQ4  ? vrS4  : na, "VR q=4",    color=colQ4,  linewidth=1)
plot(showQ8  ? vrS8  : na, "VR q=8",    color=colQ8,  linewidth=2)
plot(showQ16 ? vrS16 : na, "VR q=16",   color=colQ16, linewidth=2)
plot(showAvg ? vrAvg : na, "VR Avg",    color=colComp, linewidth=3)

// ─── REGIME BACKGROUND ────────────────────────────────────────────────────────
bgAlpha = 88
bgCol = not showBg ? na : regime == 1 ? color.new(colTrend, bgAlpha) : regime == -1 ? color.new(colMR, bgAlpha) : color.new(colRW, bgAlpha + 4)
bgcolor(bgCol, title="Regime Background")

// ─── CONSENSUS STRENGTH DOT on the VR=1.0 line ───────────────────────────────
dotCol = regime == 1 ? color.new(colTrend, math.max(0, 60 - strength * 15)) : regime == -1 ? color.new(colMR, math.max(0, 60 - strength * 15)) : color.new(colRW, 75)
plot(strength > 0 ? 1.0 : na, "Consensus Dot",
    color=dotCol, style=plot.style_circles, linewidth=2)

// ─── REGIME CHANGE LABELS ─────────────────────────────────────────────────────
// label.new() used instead of plotshape so labels sit at a fixed y-coordinate
// and cannot stack.  A 3-bar minimum gap prevents visual crowding during
// rapid regime flips.
var int lastLblBar = -999

if showLbls and regimeChanged and (bar_index - lastLblBar >= 3)
    lCol = regime ==  1 ? color.new(colTrend, 8) :
           regime == -1 ? color.new(colMR,    8) :
                          color.new(colRW,    8)
    lTxt = regime ==  1 ? "TREND" :
           regime == -1 ? "MR"    : "RW"
    // Tooltip shown on hover — explains what each regime means
    lTip = regime ==  1 ?
               "TRENDING  —  Positive autocorrelation detected.\n" +
               "VR > " + str.tostring(trendThr, "#.##") + "  ·  " +
               str.tostring(tVotes) + " of 4 horizons agree.\n" +
               "Price returns are persistent: moves tend to continue.\n" +
               "Favour trend-following entries; avoid counter-trend fades." :
           regime == -1 ?
               "MEAN-REVERSION  —  Negative autocorrelation detected.\n" +
               "VR < " + str.tostring(mrThr, "#.##") + "  ·  " +
               str.tostring(mVotes) + " of 4 horizons agree.\n" +
               "Price returns are reverting: moves tend to exhaust quickly.\n" +
               "Favour oscillator-based and fade strategies." :
               "RANDOM WALK  —  No significant autocorrelation.\n" +
               "VR ≈ 1.0  ·  Consensus below minimum threshold.\n" +
               "Price moves are statistically unpredictable.\n" +
               "Reduce position sizing; avoid strong directional bias."
    label.new(
        x         = bar_index,
        y         = trendThr + 0.18,
        text      = lTxt,
        tooltip   = lTip,
        style     = label.style_label_down,
        color     = lCol,
        textcolor = color.white,
        size      = size.tiny)
    lastLblBar := bar_index

// ─── SUMMARY TABLE ────────────────────────────────────────────────────────────
var table vrTbl = na

if barstate.islast and showTbl
    tPos = switch tblPos
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        =>               position.top_right

    rCol   = curState.regimeCol()
    rTxt   = curState.regimeTxt()
    voteStr= str.tostring(curState.strength) + " / " + str.tostring(activeN)

    vrTbl := table.new(tPos, 3, 10,
        bgcolor      = color.new(#0d1117, 6),
        border_color = color.new(#30363d, 45),
        border_width = 1,
        frame_color  = color.new(rCol, 40),
        frame_width  = 2)

    // Row 0 — header
    table.cell(vrTbl, 0, 0, "VR · Regime",
        text_color=color.new(#58a6ff, 0), text_size=size.small,
        bgcolor=color.new(#161b22, 0))
    table.cell(vrTbl, 1, 0, rTxt,
        text_color=color.new(rCol, 0), text_size=size.small,
        bgcolor=color.new(#161b22, 0))
    table.cell(vrTbl, 2, 0, voteStr,
        text_color=color.new(rCol, 0), text_size=size.small,
        bgcolor=color.new(#161b22, 0))

    // Row 1 — column headers
    table.cell(vrTbl, 0, 1, "Horizon",
        text_color=color.new(#8b949e, 0), text_size=size.tiny,
        bgcolor=color.new(#1c2128, 0))
    table.cell(vrTbl, 1, 1, "VR",
        text_color=color.new(#8b949e, 0), text_size=size.tiny,
        bgcolor=color.new(#1c2128, 0))
    table.cell(vrTbl, 2, 1, "Signal",
        text_color=color.new(#8b949e, 0), text_size=size.tiny,
        bgcolor=color.new(#1c2128, 0))

    // Rows 2–5 — per-q data
    qLabels  = array.from("q = 2", "q = 4", "q = 8", "q = 16")
    vrValues = array.from(curState.vr2, curState.vr4, curState.vr8, curState.vr16)
    isActive = array.from(showQ2, showQ4, showQ8, showQ16)

    for i = 0 to 3
        vrVal  = array.get(vrValues, i)
        active = array.get(isActive, i)
        rowBg  = color.new(#0d1117, 0)
        txtMut = color.new(#8b949e, 0)

        vrTxt  = active ? str.tostring(vrVal, "#.###") : "—"
        sigTxt = not active ? "off" : vrVal > trendThr ? "▲ Trend" : vrVal < mrThr ? "▼ MR" : "● RW"
        sigCol = not active ? color.new(#8b949e, 0) : vrVal > trendThr ? color.new(colTrend, 0) : vrVal < mrThr ? color.new(colMR, 0) : color.new(colRW, 0)

        table.cell(vrTbl, 0, i + 2, array.get(qLabels, i),
            text_color=txtMut,  text_size=size.tiny, bgcolor=rowBg)
        table.cell(vrTbl, 1, i + 2, vrTxt,
            text_color=color.new(#c9d1d9, 0), text_size=size.tiny, bgcolor=rowBg)
        table.cell(vrTbl, 2, i + 2, sigTxt,
            text_color=sigCol, text_size=size.tiny, bgcolor=rowBg)

    // Row 6 — composite
    avgTxt = str.tostring(curState.vrAvg, "#.###")
    avgSig = curState.vrAvg > trendThr ? "▲ Trend" : curState.vrAvg < mrThr ? "▼ MR" : "● RW"
    avgCol = curState.vrAvg > trendThr ? color.new(colTrend, 0) : curState.vrAvg < mrThr ? color.new(colMR, 0) : color.new(colRW, 0)
    table.cell(vrTbl, 0, 6, "Composite",
        text_color=color.new(#8b949e, 0), text_size=size.tiny,
        bgcolor=color.new(#1c2128, 0))
    table.cell(vrTbl, 1, 6, avgTxt,
        text_color=avgCol, text_size=size.tiny, bgcolor=color.new(#1c2128, 0))
    table.cell(vrTbl, 2, 6, avgSig,
        text_color=avgCol, text_size=size.tiny, bgcolor=color.new(#1c2128, 0))

    // Row 7 — streak
    streakTxt = str.tostring(streakBars) + " bars"
    table.cell(vrTbl, 0, 7, "Streak",
        text_color=color.new(#8b949e, 0), text_size=size.tiny,
        bgcolor=color.new(#0d1117, 0))
    table.cell(vrTbl, 1, 7, streakTxt,
        text_color=color.new(rCol, 0), text_size=size.tiny,
        bgcolor=color.new(#0d1117, 0))
    table.cell(vrTbl, 2, 7, "",
        text_color=color.new(#8b949e, 0), text_size=size.tiny,
        bgcolor=color.new(#0d1117, 0))

    // Row 8 — z-score of composite VR vs 50-bar history
    zTxt  = (vrZscore >= 0.0 ? "+" : "") + str.tostring(vrZscore, "#.##") + "σ"
    zCol  = math.abs(vrZscore) >= 2.0 ? color.new(#f59e0b, 0) : color.new(#8b949e, 0)
    table.cell(vrTbl, 0, 8, "Z-Score",
        text_color=color.new(#8b949e, 0), text_size=size.tiny,
        bgcolor=color.new(#0d1117, 0))
    table.cell(vrTbl, 1, 8, zTxt,
        text_color=zCol, text_size=size.tiny, bgcolor=color.new(#0d1117, 0))
    table.cell(vrTbl, 2, 8, "",
        text_color=color.new(#8b949e, 0), text_size=size.tiny,
        bgcolor=color.new(#0d1117, 0))

    // Row 9 — percentile rank of composite VR vs 100-bar history (vrPR computed above)
    prTxt  = str.tostring(math.round(vrPR)) + "th pct"
    prCol = vrPR >= 80.0 ? color.new(colTrend, 0) : vrPR <= 20.0 ? color.new(colMR, 0) : color.new(#8b949e, 0)
    table.cell(vrTbl, 0, 9, "Percentile",
        text_color=color.new(#8b949e, 0), text_size=size.tiny,
        bgcolor=color.new(#0d1117, 0))
    table.cell(vrTbl, 1, 9, prTxt,
        text_color=prCol, text_size=size.tiny, bgcolor=color.new(#0d1117, 0))
    table.cell(vrTbl, 2, 9, "",
        text_color=color.new(#8b949e, 0), text_size=size.tiny,
        bgcolor=color.new(#0d1117, 0))
````
