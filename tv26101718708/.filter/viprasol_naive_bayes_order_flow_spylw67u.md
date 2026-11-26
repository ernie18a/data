# Viprasol Naive Bayes Order Flow

- url: https://www.tradingview.com/script/sPyLW67u-Viprasol-Naive-Bayes-Order-Flow/
- type: indicator
- pine_id: PUB;5ef660c714e949b5b65f6a65e0b1f93c
- version: 1.0

## Description

Overview

This indicator is based on "Institutional Order Flow Signals [PMT]" by PMT, an open-source script that classifies order-flow conditions with a Naive Bayes classifier trained on Cumulative Volume Delta (CVD) features. The original produces a posterior probability that the current bar belongs to a Bull, Bear, or Diverged regime, then prints directional signals when that probability clears a threshold and price agrees with a trend EMA. This version keeps that classifier intact and layers a Viprasol signal-filter stack on top: a signal cooldown, an optional volume-surge confluence requirement, a bar-close confirmation gate, live classifier hit-rate tracking, and regime-flip detection.

It is built for traders who want a probabilistic read on whether buying or selling pressure (measured through volume delta) is currently dominating, with explicit noise controls applied before any signal fires.

How It Works

Cumulative Volume Delta (from original):
Each bar's volume is split into buying and selling pressure by where the close sits inside the bar's range. Buy volume = volume × (close − low) / range; sell volume = volume × (high − close) / range. The bar delta is buy minus sell, and these deltas are summed into a running CVD line. CVD rising means net buying pressure is accumulating; falling means net selling.

Three Classifier Features (from original):
The classifier is trained on three z-score-normalised features so they are comparable across instruments:
- F1 — CVD rate of change over the momentum period, normalised against its own rolling mean and standard deviation.
- F2 — price/flow divergence: price ROC minus CVD ROC, normalised. Large values flag price moving without matching flow (or vice versa).
- F3 — CVD slope: the first difference of a linear regression on the CVD line, normalised. Captures the acceleration of flow.

Naive Bayes Classification (from original):
Every bar is labelled into one of three classes from the prior bar's outcome — Bull (price up and CVD up), Bear (price down and CVD down), or Diverged (anything else). For each class the script maintains running sums of each feature and each feature squared, from which it derives a per-class mean and standard deviation online (no arrays of history needed). The likelihood of the current feature vector under each class is the product of three Gaussian PDFs (the "naive" independence assumption). Combined with class priors (the observed class frequencies), Bayes' rule yields the posterior probability of each class:
  posterior(class) = prior(class) × likelihood(class) / evidence
A signal requires the posterior to clear the entry threshold, price to be on the correct side of the trend EMA, and CVD to be moving in the signal's direction. Signals fire only on the first bar of a new cluster to avoid consecutive repeats.

Signal Cooldown (new):
After any signal fires, a configurable number of bars must elapse before the next signal of any direction is allowed, tracked as bar_index − lastSignalBar >= cooldown. During fast moves the classifier can re-cross the threshold repeatedly; the cooldown collapses those into one actionable signal. A cooldown of 5 bars on a 15-minute chart enforces a 75-minute minimum gap between entries.

Volume-Surge Confluence (new):
When enabled, a signal is additionally gated on current volume exceeding its rolling average by a multiplier (default 1.5×). The logic is volume > sma(volume, length) × multiplier. This filters out classifier signals that occur on thin participation, where flow estimates are least reliable.

Bar-Close Confirmation (new):
When enabled, signals are only confirmed on a fully closed bar (barstate.isconfirmed). Because the posterior and CVD update intrabar, a developing bar can flip in and out of a signal state before it closes; this gate holds the signal until the bar settles.

Classifier Hit-Rate Tracking (new):
On every live bar the script takes the argmax of the three posteriors as its prediction, then on the following bar compares that prediction to the realised class label. It accumulates a running hit count and evaluation count and displays the ratio as a live "Hit Rate" in the dashboard. This is an honest in-sample diagnostic of how often the classifier's single most-likely class matched the next realised label — not a trade win rate.

Regime-Flip Detection (new):
The script tracks the active regime (+1 bull, −1 bear, 0 neutral) and fires a dedicated alert whenever it transitions into a new bull or bear regime, independent of the entry-cluster logic. Useful for traders who want to be notified of context shifts rather than individual entries.

Diverged Class Surfaced (new):
The original computes a third "Diverged" class but never displays its posterior. This version surfaces P(Diverged) in the dashboard so the trader can see when the classifier considers the tape conflicted (price and flow disagreeing) rather than directional.

What Is Original (Viprasol Additions)

1. Signal cooldown system — enforces a minimum bar gap between signals to prevent clustering during fast moves.
2. Volume-surge confluence filter — optionally requires above-average volume on the signal bar so signals occur on real participation.
3. Bar-close confirmation gate — optionally holds signals until the bar closes, removing intrabar flip-flop.
4. Classifier hit-rate tracking — online comparison of the argmax-posterior prediction to the next realised class, displayed live.
5. Regime-flip detection — separate state machine and alert for bull/bear regime transitions.
6. Diverged-class posterior surfaced in the dashboard, exposing the third class the original computed but hid.

Key Features

From the Original (PMT):
- CVD line built from close-position volume splitting
- Three z-score-normalised classifier features (CVD ROC, price/flow divergence, CVD slope)
- Online Naive Bayes classifier over Bull / Bear / Diverged classes with Gaussian likelihoods
- Posterior-probability entry threshold with trend-EMA and CVD-direction agreement
- Confidence tiers (high / mid / normal) driving signal shape and band opacity
- Confidence-scaled posterior band and regime background shading
- ATR-based SL/TP projection lines
- Warmup gate (LIVE only after the classifier has trained on enough bars)
- Zen mode for clean screenshots

Added in This Version (Viprasol):
- Signal cooldown, volume-surge confluence, and bar-close confirmation filters
- Live classifier hit-rate diagnostic
- Regime-flip detection and alert
- Diverged-class posterior in the dashboard
- Colored TP / ENTRY / SL price labels on the projection lines
- Expanded info dashboard with selectable position
- Six alert conditions with dynamic {{ticker}} / {{close}} / {{interval}} messages

How to Use

Getting Started:
1. Add to a standard candlestick chart (not Heikin Ashi).
2. Wait for the dashboard to read LIVE — the classifier needs to train on enough bars first (status shows WARMUP and an N-trained counter until then).
3. Long signals print below the bar (circle = high conviction, triangle = normal); short signals print above the bar.

Reading the Dashboard:
- Bull P / Bear P / Diverged P — the three class posteriors. The dominant one drives the regime.
- CVD Flow — whether net delta is currently rising (buy) or falling (sell).
- Vol Surge — whether the current bar cleared the volume-surge threshold.
- Hit Rate — share of bars where the most-likely class matched the next realised class.
- N Trained — how many bars the classifier has trained on; ✓ once warmed up.

Recommended Starting Points:
- Crypto/Forex (5m-15m): Lookback 100, Threshold 0.70, Cooldown 3
- Stocks (15m-1H): Lookback 120, Threshold 0.72, Cooldown 5
- Indices (1H-4H): Lookback 150, Threshold 0.75, Cooldown 8

These are starting points only. Volume data quality and tape behaviour differ by instrument — backtest and adjust before trading live.

Settings

Naive Bayes Classifier: classifier lookback (bars before signals go live), entry threshold (minimum posterior), and prior bull probability.

CVD Features: CVD momentum period, CVD slope period, and the z-score normalisation window applied to all features.

Signal Filters (Viprasol): signal cooldown in bars, bar-close confirmation toggle, volume-surge requirement with average length and multiplier.

Signal Levels: show SL/TP lines, show price labels, SL ATR multiplier, risk:reward ratio, ATR period, and trend EMA period.

Visual: posterior band toggle, regime background toggle, and bull / bear / diverged colors.

Dashboard / Display: Zen mode, dashboard toggle, and dashboard position.

Alerts

1. Long Signal — bull posterior cleared the threshold with CVD rising and all filters passed
2. Short Signal — bear posterior cleared the threshold with CVD falling and all filters passed
3. Any Signal — either direction fired
4. High-Conviction Long — long signal with P(Bull) at or above 85%
5. High-Conviction Short — short signal with P(Bear) at or above 85%
6. Regime Flip — the active regime transitioned into a new bull or bear state

All alerts include {{ticker}}, {{close}}, and {{interval}} for dynamic notification messages.

Limitations & Disclaimer

- The classifier trains in-sample on the chart's own history and updates continuously; the displayed hit rate is a diagnostic of class-label agreement, not a trade win rate, and is not predictive of future results.
- CVD here is approximated from candle range and volume, not from true bid/ask tick data. Volume quality varies by broker and instrument, so the same symbol on different feeds can produce different signals.
- The classifier needs a warmup period before signals appear; on fresh charts or low-history symbols it may stay in WARMUP for a long time.
- Posteriors and CVD update intrabar; without bar-close confirmation enabled, signals can appear and disappear before a bar closes.
- SL/TP lines and price labels are visual references only — they do not place or manage trades.
- Filters reduce noise but also reduce signal count; in fast trends the cooldown may delay otherwise valid entries.
- Past performance does not guarantee future results. This indicator is for educational and analytical purposes only and is not financial advice. Always use proper risk management and test on historical data before trading live.

Credits & Attribution

Based on "Institutional Order Flow Signals [PMT]" by PMT, which provided the CVD construction, the three z-score-normalised classifier features (CVD ROC, price/flow divergence, CVD slope), the online Naive Bayes classifier over Bull/Bear/Diverged classes with Gaussian likelihoods, the posterior-threshold entry logic with trend-EMA and CVD agreement, the confidence tiers, the posterior band and regime background, and the ATR-based SL/TP projection lines. Added by Viprasol: signal cooldown, volume-surge confluence filter, bar-close confirmation gate, live classifier hit-rate tracking, regime-flip detection and alert, the surfaced Diverged-class posterior, TP/ENTRY/SL price labels, an expanded dashboard, and a six-condition dynamic alert set.

Published open-source per TradingView House Rules.

## Source Code

````pine
// This Pine Script™ v6 indicator is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
// (c) Viprasol
//
// Based on "Institutional Order Flow Signals [PMT]" by PMT (open-source).
// Original components credited in the publication description.

//@version=6
indicator(
    title            = "[Viprasol] Naive Bayes Order Flow",
    shorttitle       = "VP - NBOF",
    overlay          = true,
    max_labels_count = 100,
    max_lines_count  = 100
)

// ══════════════════════════════════════════════════════════════
// Constants — Viprasol Visual Identity
// ══════════════════════════════════════════════════════════════

const color BULL_SIGNATURE = #00ffaa     // Viprasol bull green
const color BEAR_SIGNATURE = #ff3d71     // Viprasol bear pink-red
const color DIVERGED_AMBER = #FFD54F     // indecision / diverged class
const color PANEL_BG       = #111725
const color PANEL_HEADER   = #18233a
const color PANEL_BORDER   = #000000
const color PANEL_TEXT     = #e6e9f0
const color PANEL_MUTED    = #8a93a6
const color TP_LABEL_COL   = #22c55e
const color ENTRY_LABEL_COL= #00bcd4
const color SL_LABEL_COL   = #ef4444

// ══════════════════════════════════════════════════════════════
// Inputs
// ══════════════════════════════════════════════════════════════

string GRP_CLASSIFIER = "Naive Bayes Classifier"
string GRP_CVD        = "CVD Features"
string GRP_FILTERS    = "Signal Filters (Viprasol)"
string GRP_RISK       = "Signal Levels"
string GRP_VISUAL     = "Visual"
string GRP_DASH       = "Dashboard / Display"

// — Classifier
classifierLookbackInput = input.int(100, "Classifier Lookback", minval = 30, maxval = 500, group = GRP_CLASSIFIER,
     tooltip = "Bars the classifier must accumulate before signals go LIVE. More bars = more stable estimates, slower to adapt to regime shifts.")
entryThresholdInput     = input.float(0.70, "Entry Threshold", minval = 0.51, maxval = 0.95, step = 0.01, group = GRP_CLASSIFIER,
     tooltip = "Minimum posterior probability required to print a signal. 0.65 = more signals  |  0.80 = high-conviction only.")
priorBullInput          = input.float(0.50, "Prior Bull Probability", minval = 0.10, maxval = 0.90, step = 0.01, group = GRP_CLASSIFIER,
     tooltip = "Starting belief about market direction before any data is gathered. 0.50 = neutral.")

// — CVD feature engineering
cvdMomentumPeriodInput  = input.int(14, "CVD Momentum Period", minval = 3, maxval = 100, group = GRP_CVD,
     tooltip = "Look-back for CVD rate-of-change (Feature F1) and price ROC.")
cvdSlopePeriodInput     = input.int(10, "CVD Slope Period", minval = 3, maxval = 50, group = GRP_CVD,
     tooltip = "Linear-regression window for the CVD slope (Feature F3).")
zScoreWindowInput       = input.int(50, "Z-Score Window", minval = 10, maxval = 200, group = GRP_CVD,
     tooltip = "Normalisation window applied to all three classifier features.")

// — Signal Filters (Viprasol additions)
signalCooldownInput     = input.int(5, "Signal Cooldown (bars)", minval = 0, maxval = 100, group = GRP_FILTERS,
     tooltip = "Minimum bars between consecutive signals of any direction. Prevents signal clustering during fast moves. 0 = disabled.")
requireBarCloseInput    = input.bool(true, "Require Bar-Close Confirmation", group = GRP_FILTERS,
     tooltip = "Only confirm a signal on a fully closed bar (barstate.isconfirmed). Prevents intrabar flicker / repaint-style flips.")
useVolFilterInput       = input.bool(false, "Require Volume Surge", group = GRP_FILTERS,
     tooltip = "Only allow signals when current volume exceeds the rolling average by the multiplier below. Filters low-participation signals.")
volLenInput             = input.int(20, "Volume Avg Length", minval = 2, maxval = 200, group = GRP_FILTERS, active = useVolFilterInput,
     tooltip = "Rolling window for the average volume baseline.")
volMultInput            = input.float(1.5, "Volume Surge Multiplier", minval = 1.0, maxval = 5.0, step = 0.1, group = GRP_FILTERS, active = useVolFilterInput,
     tooltip = "Current volume must exceed average × this value to qualify as a surge.")

// — Signal levels
showLevelsInput         = input.bool(true, "Show SL / TP Lines", group = GRP_RISK)
showPriceLabelsInput    = input.bool(true, "Show Price Labels (TP/Entry/SL)", group = GRP_RISK, active = showLevelsInput,
     tooltip = "Draw colored price tags at the end of the Entry / SL / TP projection lines.")
slAtrMultInput          = input.float(1.5, "SL ATR Multiplier", minval = 0.5, maxval = 5.0, step = 0.1, group = GRP_RISK, active = showLevelsInput)
rrRatioInput            = input.float(2.0, "Risk : Reward", minval = 0.5, maxval = 10.0, step = 0.1, group = GRP_RISK, active = showLevelsInput)
atrPeriodInput          = input.int(14, "ATR Period", minval = 5, maxval = 50, group = GRP_RISK)
emaPeriodInput          = input.int(50, "Trend EMA Period", minval = 5, maxval = 500, group = GRP_RISK,
     tooltip = "Longs only above this EMA, shorts only below it.")

// — Visual
showBandInput  = input.bool(true,  "Posterior Band", group = GRP_VISUAL,
     tooltip = "Shaded ATR band above/below the EMA whose opacity scales with classifier confidence.")
showBgInput    = input.bool(true,  "Regime Background", group = GRP_VISUAL)
bullColorInput = input.color(BULL_SIGNATURE, "Bull Colour", group = GRP_VISUAL)
bearColorInput = input.color(BEAR_SIGNATURE, "Bear Colour", group = GRP_VISUAL)
divColorInput  = input.color(DIVERGED_AMBER, "Diverged Colour", group = GRP_VISUAL)

// — Dashboard / display
zenModeInput   = input.bool(false, "Zen Mode  (hide all text)", group = GRP_DASH,
     tooltip = "Hides text labels — only shapes and bands remain. Ideal for clean screenshots and live use.")
showTableInput = input.bool(true,  "Show Info Dashboard", group = GRP_DASH)
dashPosInput   = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GRP_DASH)

// ══════════════════════════════════════════════════════════════
// Functions
// ══════════════════════════════════════════════════════════════

// Gaussian probability density — likelihood of a feature value under a class
gaussPdf(float x, float mu, float sigma) =>
    float s = math.max(sigma, 0.0001)
    math.exp(-0.5 * math.pow((x - mu) / s, 2)) / (s * math.sqrt(2 * math.pi))

// ══════════════════════════════════════════════════════════════
// Calculations — CVD (Cumulative Volume Delta)  [from original]
// ══════════════════════════════════════════════════════════════

float hlRange  = high - low + syminfo.mintick
float bullVol  = volume * (close - low)  / hlRange
float bearVol  = volume * (high - close) / hlRange
float deltaBar = bullVol - bearVol
var float cvdLine = 0.0
cvdLine := cvdLine + deltaBar

// ══════════════════════════════════════════════════════════════
// Calculations — Classifier Features F1/F2/F3  [from original]
// ══════════════════════════════════════════════════════════════

// F1 — normalised CVD rate of change
float cvdRoc     = (cvdLine - cvdLine[cvdMomentumPeriodInput]) / (math.abs(cvdLine[cvdMomentumPeriodInput]) + syminfo.mintick)
float cvdRocMean = ta.sma(cvdRoc, zScoreWindowInput)
float cvdRocStd  = ta.stdev(cvdRoc, zScoreWindowInput)
float featF1     = cvdRocStd > 0 ? (cvdRoc - cvdRocMean) / cvdRocStd : 0.0

// F2 — price/CVD divergence (price momentum minus flow momentum)
float priceRoc = (close - close[cvdMomentumPeriodInput]) / (close[cvdMomentumPeriodInput] + syminfo.mintick)
float f2Raw    = priceRoc - cvdRoc
float f2Mean   = ta.sma(f2Raw, zScoreWindowInput)
float f2Std    = ta.stdev(f2Raw, zScoreWindowInput)
float featF2   = f2Std > 0 ? (f2Raw - f2Mean) / f2Std : 0.0

// F3 — CVD slope (linear-regression first difference)
float cvdSlopeRaw = ta.linreg(cvdLine, cvdSlopePeriodInput, 0) - ta.linreg(cvdLine, cvdSlopePeriodInput, 1)
float f3Mean      = ta.sma(cvdSlopeRaw, zScoreWindowInput)
float f3Std       = ta.stdev(cvdSlopeRaw, zScoreWindowInput)
float featF3      = f3Std > 0 ? (cvdSlopeRaw - f3Mean) / f3Std : 0.0

// ══════════════════════════════════════════════════════════════
// Calculations — Naive Bayes training  [from original]
// Classes: 0 = Bull, 1 = Bear, 2 = Diverged
// ══════════════════════════════════════════════════════════════

bool labelBull = priceRoc > 0 and cvdRoc > 0
bool labelBear = priceRoc < 0 and cvdRoc < 0
bool labelDiv  = not labelBull and not labelBear

var array<float> clsCount = array.new_float(3, 0.0)
var array<float> sumF1    = array.new_float(3, 0.0)
var array<float> sumF2    = array.new_float(3, 0.0)
var array<float> sumF3    = array.new_float(3, 0.0)
var array<float> sumF1Sq  = array.new_float(3, 0.0)
var array<float> sumF2Sq  = array.new_float(3, 0.0)
var array<float> sumF3Sq  = array.new_float(3, 0.0)

trainClass(int c, float a, float b, float d) =>
    float n = array.get(clsCount, c) + 1
    array.set(clsCount, c, n)
    array.set(sumF1,   c, array.get(sumF1,   c) + a)
    array.set(sumF2,   c, array.get(sumF2,   c) + b)
    array.set(sumF3,   c, array.get(sumF3,   c) + d)
    array.set(sumF1Sq, c, array.get(sumF1Sq, c) + a * a)
    array.set(sumF2Sq, c, array.get(sumF2Sq, c) + b * b)
    array.set(sumF3Sq, c, array.get(sumF3Sq, c) + d * d)

if bar_index >= zScoreWindowInput + cvdMomentumPeriodInput + 2
    if labelBull[1]
        trainClass(0, featF1[1], featF2[1], featF3[1])
    else if labelBear[1]
        trainClass(1, featF1[1], featF2[1], featF3[1])
    else
        trainClass(2, featF1[1], featF2[1], featF3[1])

// Per-class mean / std-dev of a feature accumulator
classMean(int c, array<float> arr) =>
    float n = array.get(clsCount, c)
    n > 0 ? array.get(arr, c) / n : 0.0

classStd(int c, array<float> arr, array<float> arrSq) =>
    float n = array.get(clsCount, c)
    float result = 1.0
    if n >= 2
        float m = array.get(arr, c) / n
        result := math.sqrt(math.max(array.get(arrSq, c) / n - m * m, 0.0001))
    result

// Class statistics — Bull (0)
float muF1Bull = classMean(0, sumF1)
float sdF1Bull = classStd(0, sumF1, sumF1Sq)
float muF2Bull = classMean(0, sumF2)
float sdF2Bull = classStd(0, sumF2, sumF2Sq)
float muF3Bull = classMean(0, sumF3)
float sdF3Bull = classStd(0, sumF3, sumF3Sq)

// Class statistics — Bear (1)
float muF1Bear = classMean(1, sumF1)
float sdF1Bear = classStd(1, sumF1, sumF1Sq)
float muF2Bear = classMean(1, sumF2)
float sdF2Bear = classStd(1, sumF2, sumF2Sq)
float muF3Bear = classMean(1, sumF3)
float sdF3Bear = classStd(1, sumF3, sumF3Sq)

// Class statistics — Diverged (2)
float muF1Div = classMean(2, sumF1)
float sdF1Div = classStd(2, sumF1, sumF1Sq)
float muF2Div = classMean(2, sumF2)
float sdF2Div = classStd(2, sumF2, sumF2Sq)
float muF3Div = classMean(2, sumF3)
float sdF3Div = classStd(2, sumF3, sumF3Sq)

// ══════════════════════════════════════════════════════════════
// Calculations — Posterior probabilities  [from original]
// ══════════════════════════════════════════════════════════════

float totalN  = array.get(clsCount, 0) + array.get(clsCount, 1) + array.get(clsCount, 2)
float priorB  = totalN > 0 ? array.get(clsCount, 0) / totalN : priorBullInput
float priorS  = totalN > 0 ? array.get(clsCount, 1) / totalN : (1.0 - priorBullInput) / 2.0
float priorD  = totalN > 0 ? array.get(clsCount, 2) / totalN : (1.0 - priorBullInput) / 2.0

float likBull = gaussPdf(featF1, muF1Bull, sdF1Bull) * gaussPdf(featF2, muF2Bull, sdF2Bull) * gaussPdf(featF3, muF3Bull, sdF3Bull)
float likBear = gaussPdf(featF1, muF1Bear, sdF1Bear) * gaussPdf(featF2, muF2Bear, sdF2Bear) * gaussPdf(featF3, muF3Bear, sdF3Bear)
float likDiv  = gaussPdf(featF1, muF1Div,  sdF1Div ) * gaussPdf(featF2, muF2Div,  sdF2Div ) * gaussPdf(featF3, muF3Div,  sdF3Div )

float evidence = priorB * likBull + priorS * likBear + priorD * likDiv + 1e-12
float postBull = priorB * likBull / evidence
float postBear = priorS * likBear / evidence
float postDiv  = priorD * likDiv  / evidence       // [new] third class now surfaced

bool warmedUp = totalN >= classifierLookbackInput

// ══════════════════════════════════════════════════════════════
// Calculations — Classifier accuracy tracking  [new — Viprasol]
// Compare yesterday's argmax-posterior prediction to today's realised class.
// ══════════════════════════════════════════════════════════════

int predClass = postBull >= postBear and postBull >= postDiv ? 0 : postBear >= postDiv ? 1 : 2
int realClass = labelBull ? 0 : labelBear ? 1 : 2
var int hitCount = 0
var int evalCount = 0
if warmedUp and not na(predClass[1])
    evalCount += 1
    if predClass[1] == realClass
        hitCount += 1
float classifierAcc = evalCount > 0 ? hitCount / evalCount : 0.0

// ══════════════════════════════════════════════════════════════
// Calculations — Trend, ATR & volume confluence
// ══════════════════════════════════════════════════════════════

float emaLine  = ta.ema(close, emaPeriodInput)
bool  aboveEma = close > emaLine
bool  belowEma = close < emaLine
float atrVal   = ta.atr(atrPeriodInput)

// [new] volume surge confluence
float avgVol   = ta.sma(volume, volLenInput)
bool  volSurge = volume > avgVol * volMultInput
bool  volOk    = not useVolFilterInput or volSurge

// ══════════════════════════════════════════════════════════════
// Calculations — Signals  [original core + Viprasol filter stack]
// ══════════════════════════════════════════════════════════════

bool longState  = warmedUp and postBull >= entryThresholdInput and aboveEma and cvdLine > cvdLine[1]
bool shortState = warmedUp and postBear >= entryThresholdInput and belowEma and cvdLine < cvdLine[1]

// First bar of a new cluster only — avoids consecutive signal spam  [from original]
bool longCluster  = longState  and not longState[1]
bool shortCluster = shortState and not shortState[1]

// [new] bar-close confirmation gate
bool barOk = not requireBarCloseInput or barstate.isconfirmed

// [new] signal cooldown gate
var int lastSignalBar = -100000
bool cooldownOk = signalCooldownInput == 0 or (bar_index - lastSignalBar) >= signalCooldownInput

bool longEntry  = longCluster  and barOk and volOk and cooldownOk
bool shortEntry = shortCluster and barOk and volOk and cooldownOk
if longEntry or shortEntry
    lastSignalBar := bar_index

// Confidence tiers  [from original]
bool bullHi  = postBull >= 0.85
bool bullMid = postBull >= 0.75 and not bullHi
bool bearHi  = postBear >= 0.85
bool bearMid = postBear >= 0.75 and not bearHi

// [new] regime-flip detection
int  currentRegime = warmedUp and postBull >= entryThresholdInput and aboveEma ? 1 : warmedUp and postBear >= entryThresholdInput and belowEma ? -1 : 0
bool regimeFlipBull = currentRegime == 1  and currentRegime[1] != 1
bool regimeFlipBear = currentRegime == -1 and currentRegime[1] != -1

// ══════════════════════════════════════════════════════════════
// Visuals — colours & bands
// ══════════════════════════════════════════════════════════════

color longColor  = bullHi ? bullColorInput : bullMid ? color.new(bullColorInput, 30) : color.new(bullColorInput, 55)
color shortColor = bearHi ? bearColorInput : bearMid ? color.new(bearColorInput, 30) : color.new(bearColorInput, 55)

int bandAlphaBull = warmedUp ? int(math.max(8, 100 - int(postBull * 92))) : 100
int bandAlphaBear = warmedUp ? int(math.max(8, 100 - int(postBear * 92))) : 100

plot(emaLine, "EMA", color = color.new(color.gray, 50), linewidth = 1)

b_top = plot(showBandInput ? emaLine + atrVal : na, display = display.none)
b_bot = plot(showBandInput ? emaLine          : na, display = display.none)
fill(b_top, b_bot, color = showBandInput and aboveEma and warmedUp ? color.new(bullColorInput, bandAlphaBull) : na, title = "Bull Band")

s_top = plot(showBandInput ? emaLine          : na, display = display.none)
s_bot = plot(showBandInput ? emaLine - atrVal : na, display = display.none)
fill(s_top, s_bot, color = showBandInput and belowEma and warmedUp ? color.new(bearColorInput, bandAlphaBear) : na, title = "Bear Band")

// Entry shapes — first bar of cluster only
plotshape(longEntry and bullHi     and not zenModeInput, "Long High",   location = location.belowbar, style = shape.circle,      size = size.small, color = longColor)
plotshape(longEntry and not bullHi and not zenModeInput, "Long Normal", location = location.belowbar, style = shape.triangleup,  size = size.small, color = longColor)
plotshape(longEntry and zenModeInput,                    "Long Zen",    location = location.belowbar, style = shape.triangleup,  size = size.small, color = longColor)

plotshape(shortEntry and bearHi     and not zenModeInput, "Short High",   location = location.abovebar, style = shape.circle,       size = size.small, color = shortColor)
plotshape(shortEntry and not bearHi and not zenModeInput, "Short Normal", location = location.abovebar, style = shape.triangledown, size = size.small, color = shortColor)
plotshape(shortEntry and zenModeInput,                    "Short Zen",    location = location.abovebar, style = shape.triangledown, size = size.small, color = shortColor)

// Regime background
bgcolor(showBgInput and warmedUp and postBull >= entryThresholdInput and aboveEma ? color.new(bullColorInput, 93) : na, title = "Bull Regime")
bgcolor(showBgInput and warmedUp and postBear >= entryThresholdInput and belowEma ? color.new(bearColorInput, 93) : na, title = "Bear Regime")

// ══════════════════════════════════════════════════════════════
// Visuals — SL / TP projection lines + price labels  [original + Viprasol labels]
// ══════════════════════════════════════════════════════════════

var line slLine = na
var line tpLine = na
var line enLine = na
var label slLbl = na
var label tpLbl = na
var label enLbl = na

bool drawLevelNow = (longEntry or shortEntry) and showLevelsInput and not zenModeInput
if drawLevelNow
    float slPrice = longEntry ? close - atrVal * slAtrMultInput : close + atrVal * slAtrMultInput
    float tpPrice = longEntry ? close + atrVal * slAtrMultInput * rrRatioInput : close - atrVal * slAtrMultInput * rrRatioInput
    int x2 = bar_index + 8
    line.delete(slLine)
    line.delete(tpLine)
    line.delete(enLine)
    label.delete(slLbl)
    label.delete(tpLbl)
    label.delete(enLbl)
    enLine := line.new(bar_index, close,   x2, close,   color = color.new(ENTRY_LABEL_COL, 20), width = 1)
    slLine := line.new(bar_index, slPrice, x2, slPrice, color = color.new(SL_LABEL_COL, 20), width = 1, style = line.style_dashed)
    tpLine := line.new(bar_index, tpPrice, x2, tpPrice, color = color.new(TP_LABEL_COL, 20), width = 1, style = line.style_dashed)
    if showPriceLabelsInput
        enLbl := label.new(x2, close,   "ENTRY " + str.tostring(close,   format.mintick), style = label.style_label_left, color = ENTRY_LABEL_COL, textcolor = color.white, size = size.small)
        slLbl := label.new(x2, slPrice, "SL "    + str.tostring(slPrice, format.mintick), style = label.style_label_left, color = SL_LABEL_COL,    textcolor = color.white, size = size.small)
        tpLbl := label.new(x2, tpPrice, "TP "    + str.tostring(tpPrice, format.mintick), style = label.style_label_left, color = TP_LABEL_COL,    textcolor = color.white, size = size.small)

// ══════════════════════════════════════════════════════════════
// Visuals — Info Dashboard
// ══════════════════════════════════════════════════════════════

dashPos = switch dashPosInput
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right

var table tbl = table.new(dashPos, 2, 10, bgcolor = PANEL_BG, border_color = PANEL_BORDER, border_width = 1, frame_color = PANEL_BORDER, frame_width = 1)

if barstate.islast and showTableInput
    table.cell(tbl, 0, 0, "VP — NB Order Flow", text_color = PANEL_TEXT, text_size = size.small, bgcolor = PANEL_HEADER)
    table.cell(tbl, 1, 0, warmedUp ? "● LIVE" : "● WARMUP", text_color = warmedUp ? bullColorInput : DIVERGED_AMBER, text_size = size.small, bgcolor = PANEL_HEADER)

    table.cell(tbl, 0, 1, "Bull P", text_color = PANEL_TEXT, text_size = size.small)
    table.cell(tbl, 1, 1, str.format("{0,number,#.#%}", postBull), text_color = postBull >= entryThresholdInput ? bullColorInput : PANEL_MUTED, text_size = size.small)

    table.cell(tbl, 0, 2, "Bear P", text_color = PANEL_TEXT, text_size = size.small)
    table.cell(tbl, 1, 2, str.format("{0,number,#.#%}", postBear), text_color = postBear >= entryThresholdInput ? bearColorInput : PANEL_MUTED, text_size = size.small)

    table.cell(tbl, 0, 3, "Diverged P", text_color = PANEL_TEXT, text_size = size.small)
    table.cell(tbl, 1, 3, str.format("{0,number,#.#%}", postDiv), text_color = divColorInput, text_size = size.small)

    table.cell(tbl, 0, 4, "CVD Flow", text_color = PANEL_TEXT, text_size = size.small)
    table.cell(tbl, 1, 4, cvdLine > cvdLine[1] ? "▲ Buy" : "▼ Sell", text_color = cvdLine > cvdLine[1] ? bullColorInput : bearColorInput, text_size = size.small)

    table.cell(tbl, 0, 5, "Vol Surge", text_color = PANEL_TEXT, text_size = size.small)
    table.cell(tbl, 1, 5, volSurge ? "✓ Yes" : "— No", text_color = volSurge ? bullColorInput : PANEL_MUTED, text_size = size.small)

    table.cell(tbl, 0, 6, "Hit Rate", text_color = PANEL_TEXT, text_size = size.small)
    table.cell(tbl, 1, 6, evalCount > 0 ? str.format("{0,number,#.#%}", classifierAcc) : "…", text_color = classifierAcc >= 0.5 ? bullColorInput : DIVERGED_AMBER, text_size = size.small)

    table.cell(tbl, 0, 7, "N Trained", text_color = PANEL_TEXT, text_size = size.small)
    table.cell(tbl, 1, 7, str.tostring(int(totalN)) + (warmedUp ? " ✓" : " …"), text_color = warmedUp ? bullColorInput : DIVERGED_AMBER, text_size = size.small)

    table.cell(tbl, 0, 8, "● ▲  Buy", text_color = bullColorInput, text_size = size.tiny)
    table.cell(tbl, 1, 8, "● = strong", text_color = PANEL_MUTED, text_size = size.tiny)
    table.cell(tbl, 0, 9, "● ▼  Sell", text_color = bearColorInput, text_size = size.tiny)
    table.cell(tbl, 1, 9, "▲▼ = normal", text_color = PANEL_MUTED, text_size = size.tiny)

// ══════════════════════════════════════════════════════════════
// Alerts — dynamic messages with {{ticker}} {{close}} {{interval}}
// ══════════════════════════════════════════════════════════════

alertcondition(longEntry,  "VP NBOF Long Signal",  "[Viprasol] NB Order Flow: BULL signal on {{ticker}} ({{interval}}) at {{close}} — P(Bull) >= threshold, CVD rising")
alertcondition(shortEntry, "VP NBOF Short Signal", "[Viprasol] NB Order Flow: BEAR signal on {{ticker}} ({{interval}}) at {{close}} — P(Bear) >= threshold, CVD falling")
alertcondition(longEntry or shortEntry, "VP NBOF Any Signal", "[Viprasol] NB Order Flow: signal fired on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(longEntry and bullHi,   "VP NBOF High-Conviction Long",  "[Viprasol] NB Order Flow: HIGH-CONVICTION BULL on {{ticker}} ({{interval}}) at {{close}} — P(Bull) >= 85%")
alertcondition(shortEntry and bearHi,  "VP NBOF High-Conviction Short", "[Viprasol] NB Order Flow: HIGH-CONVICTION BEAR on {{ticker}} ({{interval}}) at {{close}} — P(Bear) >= 85%")
alertcondition(regimeFlipBull or regimeFlipBear, "VP NBOF Regime Flip", "[Viprasol] NB Order Flow: regime flip on {{ticker}} ({{interval}}) at {{close}}")
````
