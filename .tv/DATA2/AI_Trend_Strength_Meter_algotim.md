<!-- tradingview-pine-id: PUB;df1687867fdf466d982dd7fff8b449a0 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# AI Trend Strength Meter [algotim]

Source: https://www.tradingview.com/script/kWTqH1oM-AI-Trend-Strength-Meter-algotim/

## Description

Overview
EMA Cloud Trend Retest Signals is a trend-continuation indicator built around a state-based pullback and retest process.
The purpose of the script is to distinguish an ordinary moving-average touch from a structured retest. Instead of generating a signal simply because price crosses an EMA, the script first requires an established directional regime, then tracks a pullback into the EMA cloud and evaluates how deeply price retraces before attempting to resume the prevailing direction.
The result is a selective retest workflow rather than a standalone moving-average crossover signal.

Problem Statement
A basic EMA crossover can identify direction, but it does not describe what happens after the trend has started. Likewise, a simple moving-average touch can occur repeatedly during sideways markets and can produce many low-quality signals.

This script addresses that problem by separating trend identification from retest validation.

A trend must first establish itself for a configurable number of bars. Price must then interact with the EMA cloud. The script tracks the deepest part of that pullback and can require the depth to exceed a configurable fraction of ATR. Optional volume confirmation adds another condition at the retest candle.

This makes the signal dependent on the sequence of events rather than on one indicator crossing another.

Methodology
The trend engine uses a fast EMA and a slow EMA calculated from the selected price source.
When the fast EMA is above the slow EMA, the regime is bullish. When it is below the slow EMA, the regime is bearish.

The script also measures the percentage distance between the two EMAs:
Spread % = abs(Fast EMA - Slow EMA) / Close x 100

This value is normalized and used primarily to control the visual strength of the EMA cloud rather than to create an independent trading signal.

Trend age is tracked as the number of bars since the EMA regime last changed. A configurable minimum trend age prevents an immediate EMA flip from being treated as an established trend.

Retest Detection
Once a bullish regime is active, the script monitors for price interaction with the EMA cloud. For bearish regimes, the same process is applied in the opposite direction.

Depending on the selected setting, a retest can be recognized using either:

* A wick entering the EMA cloud.
* A candle close entering the EMA cloud.

Once the cloud is touched, a pullback state becomes active.

The script then tracks the most extreme price reached during that active pullback.

For bullish retests:
Pullback depth = Cloud top - Pullback low

For bearish retests:
Pullback depth = Pullback high - Cloud bottom
This allows the depth of the retracement to be compared with current volatility.
ATR Validation
The pullback-depth filter uses ATR as the volatility reference.

A bullish retest must satisfy:
Pullback depth >= ATR x Minimum Depth
A bearish retest uses the corresponding distance from the lower cloud boundary.
Because the threshold is expressed in ATR units, the filter adapts to the current volatility of the instrument instead of relying on a fixed price distance.

Volume Validation
When enabled, the retest candle is compared with a moving average of volume.

Volume confirmation requires:
Current volume >= Average volume x Volume multiplier
This filter is optional and can be disabled when volume data is unsuitable for the instrument.

Signal Workflow
1. Calculate the fast and slow EMAs.
2. Establish the bullish or bearish EMA regime.
3. Reset the signal lock when the EMA regime changes.
4. Count how many bars the current regime has remained active.
5. Ignore retests until the minimum trend-age requirement is satisfied.
6. Detect price interaction with the EMA cloud.
7. Activate a pullback state.
8. Track the deepest price reached during that pullback.
9. Compare pullback depth with the ATR-based minimum.
10. Optionally verify above-average volume.
11. Require price to close back through the appropriate cloud boundary.
12. Generate the retest signal.
13. Lock further signals until the EMA regime changes.

The one-signal-per-trend lock is an important part of the workflow. It prevents repeated cloud interactions during the same EMA regime from continuously producing identical signals.

Signal Strength
When enabled, the script classifies the retest using a simple three-point strength model.
One point is added when the trend has persisted for at least twice the minimum trend-age requirement.
One point is added when current volume reaches 1.5 times the average volume.
One point is added when the measured pullback depth reaches twice the configured minimum ATR depth.
A score of two or more is displayed as a stronger retest classification.
This score is a classification of the conditions present at the retest; it is not a probability or performance estimate.

Why This Indicator Is Different
A conventional EMA indicator normally answers one question: which EMA is above the other?
A basic pullback indicator may add a moving-average touch condition.
This script instead treats the retest as a sequence with persistent state:
EMA regime -> trend age -> cloud interaction -> pullback tracking -> ATR depth validation -> volume validation -> recovery through the cloud -> signal lock.
The distinction is therefore not the use of EMAs, ATR or volume individually. Those are standard analytical tools. The main contribution is the way they are used as sequential validation layers around a tracked pullback state.

The script also prevents multiple signals from the same trend regime by maintaining a signal-fired state until the EMA direction changes.

Inputs
EMA Cloud Settings
* Fast EMA Length
* Slow EMA Length
* Price Source
* EMA Line Width
* Candle coloring
* Cloud opacity and visual options
* ATR Length

Retest Settings
* Minimum Trend Age
* Wick-based or close-based cloud interaction
* Buy/Sell signal visibility
* Volume confirmation
* Volume moving-average length
* Volume multiplier
* Minimum pullback depth in ATR
* Signal-strength display

Risk and Target Settings
The script also provides configurable risk-reward reference levels where enabled, including target multipliers and a selectable stop-loss basis.

Alerts
The indicator provides alert functionality for the retest conditions according to the enabled alert settings.
Alerts should be interpreted as notifications that the defined sequence has completed, not as guarantees of future price movement.

Practical Usage
The indicator is intended primarily for trend-continuation analysis.
For bullish conditions, users can focus on periods where the fast EMA remains above the slow EMA, the trend has established for the required number of bars, and price pulls back into the EMA cloud before recovering above it.

For bearish conditions, the inverse process applies.
The ATR depth filter can be increased when shallow pullbacks generate excessive signals. The volume filter can be enabled when volume data provides useful participation information.

Signals should preferably be evaluated in the context of the broader market structure, timeframe and current volatility rather than treated as automatic entries.

Limitations
EMA-based regimes are lagging by construction and can change frequently during sideways markets.
A cloud interaction does not guarantee continuation. Ranging conditions can produce repeated pullbacks and failed retests.
ATR normalization adjusts the depth requirement to volatility but does not eliminate market noise.
Volume confirmation depends on the quality and meaning of the volume data available for the instrument.
The signal-strength score is a rule-based classification, not a statistical probability of success.
Trend age and pullback depth depend on historical bars and the selected settings, so results can vary substantially between instruments and timeframes.
Signals should be evaluated after bar close and should not be interpreted as guaranteed future price direction.

Notes
This indicator is an analytical framework for identifying structured EMA-cloud retests. It is not a trading strategy with guaranteed performance and should not be treated as financial advice.

The EMA, ATR and volume calculations used by the script are standard technical-analysis concepts. The intended distinction is the state-based workflow that combines them to qualify a single retest within an established trend regime.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © algotim

//@version=6
indicator(
     title     = "AI Trend Strength Meter [algotim]",
     shorttitle = "ATIS [algotim]",
     overlay   = false,
     max_bars_back = 500,
     max_lines_count = 50,
     max_labels_count = 50
 )

// ══════════════════════════════════════════════════════════════
// §1  SETTINGS
// ══════════════════════════════════════════════════════════════

// ── Core Engine ──────────────────────────────────────────────
var grpEngine = "⚙  Core Engine"
emaFast   = input.int(21,  "Fast EMA Length",  minval=5,  maxval=50,  group=grpEngine, tooltip="Controls directional bias sensitivity.")
emaSlow   = input.int(55,  "Slow EMA Length",  minval=20, maxval=200, group=grpEngine, tooltip="Baseline trend anchor.")
erLen     = input.int(14,  "Efficiency Ratio Period", minval=5, maxval=50, group=grpEngine, tooltip="Kaufman ER lookback. Lower = more reactive.")
rocLen    = input.int(14,  "Momentum (ROC) Period",   minval=5, maxval=50, group=grpEngine, tooltip="Rate-of-change lookback for momentum scoring.")
atrLen    = input.int(14,  "ATR Period",              minval=5, maxval=50, group=grpEngine, tooltip="Volatility normalization window.")
memAlpha  = input.float(0.15, "Persistence Memory (α)", minval=0.02, maxval=0.50, step=0.01, group=grpEngine, tooltip="ATIS smoothing carry. Lower = more memory.")

// ── Signal Thresholds ────────────────────────────────────────
var grpThresh = "🎯  Signal Thresholds"
bullThresh   = input.int(62, "Bullish Regime  (ATIS ≥)",  minval=50, maxval=95, group=grpThresh, tooltip="Score above this = confirmed bull trend.")
bearThresh   = input.int(38, "Bearish Regime  (ATIS ≤)",  minval=5,  maxval=50, group=grpThresh, tooltip="Score below this = confirmed bear trend.")
extremeHigh  = input.int(82, "Extreme Strength (ATIS ≥)", minval=60, maxval=99, group=grpThresh, tooltip="Background pulse activates above this level.")
extremeLow   = input.int(18, "Extreme Weakness (ATIS ≤)", minval=1,  maxval=40, group=grpThresh, tooltip="Background pulse activates below this level.")

// ── Visuals ───────────────────────────────────────────────────
var grpVis = "🎨  Visual Settings"
bullColor    = input.color(color.new(#00E5A0, 0),  "Bull Color",        group=grpVis)
bearColor    = input.color(color.new(#FF3D5E, 0),  "Bear Color",        group=grpVis)
neutColor    = input.color(color.new(#9B9EAD, 0),  "Neutral Color",     group=grpVis)
showRibbon   = input.bool(true,  "Show Score Ribbon",           group=grpVis)
showHisto    = input.bool(true,  "Show ATIS Histogram",          group=grpVis)
showPulse    = input.bool(true,  "Show Extreme Pulse",           group=grpVis)
showRegime   = input.bool(true,  "Show Regime-Change Markers",   group=grpVis)
showMidline  = input.bool(true,  "Show Zone Grid Lines",         group=grpVis)

// ── Alerts ───────────────────────────────────────────────────
var grpAlerts = "🔔  Alerts"
alertBull    = input.bool(true, "Alert: Bull Regime Entry",   group=grpAlerts)
alertBear    = input.bool(true, "Alert: Bear Regime Entry",   group=grpAlerts)
alertExtHigh = input.bool(true, "Alert: Extreme Strength",    group=grpAlerts)
alertExtLow  = input.bool(true, "Alert: Extreme Weakness",    group=grpAlerts)
alertCross50 = input.bool(true, "Alert: ATIS Crosses 50",     group=grpAlerts)

// ══════════════════════════════════════════════════════════════
// §2  CORE CALCULATIONS
// ══════════════════════════════════════════════════════════════

// ── 2a. EMA Structure (Directional Bias Score) ────────────────
emaF  = ta.ema(close, emaFast)
emaS  = ta.ema(close, emaSlow)

// Normalised EMA spread: positive when fast > slow, capped at ±1
// We measure the spread relative to recent ATR to stay unit-free
atr14 = ta.atr(atrLen)
emaDelta  = (emaF - emaS) / (atr14 * math.sqrt(float(emaSlow)))
biasScore = math.min(math.abs(emaDelta) * 50.0, 50.0)   // 0-50 contribution
biasDir   = emaDelta >= 0 ? 1 : -1                       // +1 bull / -1 bear

// ── 2b. Kaufman Efficiency Ratio (Trend Efficiency) ──────────
//  ER = |net price move| / (sum of absolute bar moves)
//  High ER → price moves in one clean direction → strong trend
netMove   = math.abs(close - close[erLen])
totalMove = math.sum(math.abs(close - close[1]), erLen)
er        = totalMove != 0 ? netMove / totalMove : 0.0   // 0-1
erScore   = er * 100.0                                    // 0-100 contribution

// ── 2c. Normalised ROC (Momentum Expansion) ──────────────────
//  We use a rolling z-score of ROC to remove symbol-specific bias
roc       = ta.roc(close, rocLen)
rocMean   = ta.sma(roc, rocLen * 2)
rocStd    = ta.stdev(roc, rocLen * 2)
rocZ      = rocStd != 0 ? (roc - rocMean) / rocStd : 0.0
// Clamp to ±3σ and map to 0-100
rocScore  = math.min(math.max((rocZ + 3.0) / 6.0, 0.0), 1.0) * 100.0

// ── 2d. ATR Context Score (Volatility Normalization) ─────────
//  We compare current ATR to its own 50-bar average
//  Low relative volatility + existing trend → high quality
atrRatio  = ta.sma(atr14, 50) != 0 ? atr14 / ta.sma(atr14, 50) : 1.0
// A mild volatility environment (ratio 0.7-1.3) is ideal
// Score peaks near ratio = 1.0, falls toward zero at extremes
atrIdeal  = 1.0 - math.min(math.abs(atrRatio - 1.0), 1.0)
atrScore  = atrIdeal * 100.0

// ── 2e. Raw ATIS Composite (weighted blend) ───────────────────
//  Weights are tuned to give efficiency & direction equal footing
//  while momentum and volatility play supporting roles
w_bias   = 0.30   // directional structure
w_er     = 0.30   // trend cleanliness
w_roc    = 0.25   // momentum
w_atr    = 0.15   // volatility quality

rawATIS  = w_bias * biasScore + w_er * erScore + w_roc * rocScore + w_atr * atrScore

// ── 2f. Persistence Memory (exponential carry) ────────────────
//  Prevents whipsaw by giving weight to prior ATIS state
//  This is the "AI memory" element – trend must earn its change
var float atis = 50.0
atis := memAlpha * rawATIS + (1.0 - memAlpha) * nz(atis[1], rawATIS)

// ── 2g. Directional ATIS (signed score) ──────────────────────
//  The ribbon and histogram use this signed version
//  bull = positive side of 50, bear = negative side
atisDisplay = biasDir >= 0 ? atis : (100.0 - atis)

// ══════════════════════════════════════════════════════════════
// §3  REGIME LOGIC
// ══════════════════════════════════════════════════════════════

isBull       = atisDisplay >= bullThresh
isBear       = atisDisplay <= bearThresh
isNeutral    = not isBull and not isBear
isExtBull    = atisDisplay >= extremeHigh
isExtBear    = atisDisplay <= extremeLow

// Regime transitions
bullEntry    = isBull  and not isBull[1]
bearEntry    = isBear  and not isBear[1]
extBullEntry = isExtBull and not isExtBull[1]
extBearEntry = isExtBear and not isExtBear[1]
cross50Up    = atisDisplay >= 50 and atisDisplay[1] < 50
cross50Dn    = atisDisplay < 50  and atisDisplay[1] >= 50

// ══════════════════════════════════════════════════════════════
// §4  COLOR SYSTEM
// ══════════════════════════════════════════════════════════════

// Dynamic confidence-based transparency
//  As ATIS pushes further from 50, opacity increases
confidence   = math.abs(atisDisplay - 50.0) / 50.0          // 0.0-1.0
ribbonAlpha  = int(math.round((1.0 - confidence * 0.85) * 85))  // 15-85 transparency

dynColor     = isBull    ? color.new(bullColor, 0) :
               isBear    ? color.new(bearColor, 0) :
                           color.new(neutColor, 0)

dynColorFade = isBull    ? color.new(bullColor, ribbonAlpha) :
               isBear    ? color.new(bearColor, ribbonAlpha) :
                           color.new(neutColor, ribbonAlpha)

// Histogram delta for momentum colouring
histDelta    = atisDisplay - atisDisplay[1]

histColor    = isBull and histDelta >= 0 ? color.new(bullColor, 10)  :
               isBull and histDelta <  0 ? color.new(bullColor, 55)  :
               isBear and histDelta <= 0 ? color.new(bearColor, 10)  :
               isBear and histDelta >  0 ? color.new(bearColor, 55)  :
                                           color.new(neutColor, 45)

// ══════════════════════════════════════════════════════════════
// §5  PLOTS – ATIS SCORE PANEL
// ══════════════════════════════════════════════════════════════

// ── 5a. Background Pulse (extreme states only) ────────────────
// bgcolor() must remain at global scope in Pine Script v6 — conditional
// colour expression handles the on/off logic instead of an if-block.
bgcolor(
     showPulse and isExtBull ? color.new(bullColor, 92) : na,
     title = "Extreme Bull Pulse"
 )
bgcolor(
     showPulse and isExtBear ? color.new(bearColor, 92) : na,
     title = "Extreme Bear Pulse"
 )

// ── 5b. Zone Grid ─────────────────────────────────────────────
hline(50,         "Neutral 50",       color=color.new(#9B9EAD, 65), linestyle=hline.style_solid,  linewidth=1)
hline(bullThresh, "Bull Zone",        color=color.new(bullColor, 70), linestyle=hline.style_dashed, linewidth=1)
hline(bearThresh, "Bear Zone",        color=color.new(bearColor, 70), linestyle=hline.style_dashed, linewidth=1)
hline(extremeHigh,"Extreme High",     color=color.new(bullColor, 50), linestyle=hline.style_dotted, linewidth=1)
hline(extremeLow, "Extreme Low",      color=color.new(bearColor, 50), linestyle=hline.style_dotted, linewidth=1)
hline(0,          "Floor",            color=color.new(#9B9EAD, 80), linestyle=hline.style_solid,  linewidth=1)
hline(100,        "Ceiling",          color=color.new(#9B9EAD, 80), linestyle=hline.style_solid,  linewidth=1)

// ── 5c. ATIS Histogram ────────────────────────────────────────
plot(
     showHisto ? atisDisplay : na,
     title     = "ATIS Histogram",
     style     = plot.style_columns,
     color     = histColor,
     linewidth = 1
 )

// ── 5d. ATIS Score Line ───────────────────────────────────────
//  Smooth the display line slightly for cleaner visuals
atisLine = ta.ema(atisDisplay, 3)

plot(
     atisLine,
     title     = "ATIS Score",
     color     = dynColor,
     linewidth  = 2,
     style     = plot.style_line
 )

// ── 5e. Score Ribbon (confidence band around line) ────────────
//  Upper and lower bounds widen with confidence
ribbonWidth = confidence * 4.0 + 0.5
upperRibbon = atisLine + ribbonWidth
lowerRibbon = atisLine - ribbonWidth

ribbonHigh = plot(
     showRibbon ? upperRibbon : na,
     title  = "Ribbon High",
     color  = na,
     display = display.none
 )

ribbonLow  = plot(
     showRibbon ? lowerRibbon : na,
     title  = "Ribbon Low",
     color  = na,
     display = display.none
 )

fill(
     ribbonHigh,
     ribbonLow,
     title = "Trend Ribbon",
     color = dynColorFade
 )

// ── 5f. Regime-Change Markers ─────────────────────────────────
if showRegime
    if bullEntry
        label.new(
             bar_index, atisDisplay,
             "▲",
             style    = label.style_label_up,
             color    = color.new(bullColor, 20),
             textcolor = color.white,
             size     = size.small,
             tooltip  = "Bull Regime Entry\nATIS: " + str.tostring(math.round(atisDisplay, 1))
         )

    if bearEntry
        label.new(
             bar_index, atisDisplay,
             "▼",
             style    = label.style_label_down,
             color    = color.new(bearColor, 20),
             textcolor = color.white,
             size     = size.small,
             tooltip  = "Bear Regime Entry\nATIS: " + str.tostring(math.round(atisDisplay, 1))
         )

    // Extreme state markers (diamond shape via circle label)
    if extBullEntry
        label.new(
             bar_index, extremeHigh,
             "◆",
             style    = label.style_label_down,
             color    = color.new(bullColor, 0),
             textcolor = color.white,
             size     = size.tiny,
             tooltip  = "Extreme Trend Strength\nATIS: " + str.tostring(math.round(atisDisplay, 1))
         )

    if extBearEntry
        label.new(
             bar_index, extremeLow,
             "◆",
             style    = label.style_label_up,
             color    = color.new(bearColor, 0),
             textcolor = color.white,
             size     = size.tiny,
             tooltip  = "Extreme Trend Weakness\nATIS: " + str.tostring(math.round(atisDisplay, 1))
         )

// ══════════════════════════════════════════════════════════════
// §6  ALERTS
// ══════════════════════════════════════════════════════════════

// Bull Regime Entry
if alertBull and bullEntry
    alert(
         "ATIS [algotim] │ 🟢 BULL REGIME ENTRY\n" +
         "Symbol : " + syminfo.ticker + " │ TF: " + timeframe.period + "\n" +
         "ATIS Score : " + str.tostring(math.round(atisDisplay, 1)) + " / 100\n" +
         "Trend confirmed above " + str.tostring(bullThresh),
         alert.freq_once_per_bar_close
     )

// Bear Regime Entry
if alertBear and bearEntry
    alert(
         "ATIS [algotim] │ 🔴 BEAR REGIME ENTRY\n" +
         "Symbol : " + syminfo.ticker + " │ TF: " + timeframe.period + "\n" +
         "ATIS Score : " + str.tostring(math.round(atisDisplay, 1)) + " / 100\n" +
         "Trend confirmed below " + str.tostring(bearThresh),
         alert.freq_once_per_bar_close
     )

// Extreme Strength
if alertExtHigh and extBullEntry
    alert(
         "ATIS [algotim] │ ⚡ EXTREME TREND STRENGTH\n" +
         "Symbol : " + syminfo.ticker + " │ TF: " + timeframe.period + "\n" +
         "ATIS Score : " + str.tostring(math.round(atisDisplay, 1)) + " / 100\n" +
         "Score exceeded extreme threshold " + str.tostring(extremeHigh),
         alert.freq_once_per_bar_close
     )

// Extreme Weakness
if alertExtLow and extBearEntry
    alert(
         "ATIS [algotim] │ ⚡ EXTREME TREND WEAKNESS\n" +
         "Symbol : " + syminfo.ticker + " │ TF: " + timeframe.period + "\n" +
         "ATIS Score : " + str.tostring(math.round(atisDisplay, 1)) + " / 100\n" +
         "Score fell below extreme threshold " + str.tostring(extremeLow),
         alert.freq_once_per_bar_close
     )

// ATIS Cross 50 (Upward)
if alertCross50 and cross50Up
    alert(
         "ATIS [algotim] │ 🔼 ATIS CROSSED 50 — BULLISH SHIFT\n" +
         "Symbol : " + syminfo.ticker + " │ TF: " + timeframe.period + "\n" +
         "ATIS Score : " + str.tostring(math.round(atisDisplay, 1)) + " / 100",
         alert.freq_once_per_bar_close
     )

// ATIS Cross 50 (Downward)
if alertCross50 and cross50Dn
    alert(
         "ATIS [algotim] │ 🔽 ATIS CROSSED 50 — BEARISH SHIFT\n" +
         "Symbol : " + syminfo.ticker + " │ TF: " + timeframe.period + "\n" +
         "ATIS Score : " + str.tostring(math.round(atisDisplay, 1)) + " / 100",
         alert.freq_once_per_bar_close
     )

// ══════════════════════════════════════════════════════════════
// §7  AUXILIARY INFO PLOTS (for strategy integration)
// ══════════════════════════════════════════════════════════════

// These are plot() calls with display=display.none so users can
// reference them in alerts / strategies without cluttering the chart

plot(atisDisplay,  title="ATIS Value",       display=display.none)
plot(er * 100,     title="Efficiency Ratio", display=display.none)
plot(biasDir,      title="Trend Direction",  display=display.none)
plot(rocScore,     title="Momentum Score",   display=display.none)
````
