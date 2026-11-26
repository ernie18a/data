# Nasan Stretch - Velocity Quadrant Plot

- url: https://www.tradingview.com/script/b7YLUSm2-Nasan-Stretch-Velocity-Quadrant-Plot/
- type: indicator
- pine_id: PUB;820525e9ef3a46ab8b9a88d65f403277
- version: 2.0

## Description

# Stretch/Velocity Quadrant Plot

The **Stretch/Velocity Quadrant Plot** is a multi-asset market regime and momentum tool designed to track up to **11 symbols simultaneously**.

By plotting **Velocity** against **Stretch**, the indicator shows where each asset sits within the lifecycle of a trend and how it is moving between expansion, exhaustion, reversal, and recovery phases.

It is especially useful for:

* comparing several stocks on one chart,
* identifying leadership and rotation,
* spotting early momentum changes,
* distinguishing strong trends from overextended moves,
* and evaluating how likely a stock is to remain in or leave its current market phase.

## Core Concept

The model combines short-, medium-, and long-term behavior using:

* 13-period EMA
* 21-period EMA
* 34-period EMA

The three horizons are blended using customizable weights.

All values are normalized by ATR, allowing stocks with very different prices and volatility levels to be compared on the same scale.

## Velocity — X-Axis

Velocity measures the rate of change of the three EMAs.

Each EMA uses a separate lookback:

* EMA 13 velocity over 8 bars
* EMA 21 velocity over 13 bars
* EMA 34 velocity over 21 bars

The result represents the speed and direction of the underlying trend.

* Positive Velocity: trend momentum is improving
* Negative Velocity: trend momentum is weakening

## Stretch — Y-Axis

Stretch measures how far price has moved away from its EMA structure.

It is calculated as the ATR-normalized distance between price and the 13-, 21-, and 34-period EMAs.

* Positive Stretch: price is trading above its trend structure
* Negative Stretch: price is trading below its trend structure
* Larger absolute values: price is farther from equilibrium

## The Four Market Quadrants

### Q1 — Bullish Expansion

**Positive Velocity / Positive Stretch**

The asset is above its trend structure and momentum is accelerating.

This is typically associated with:

* strong uptrends,
* momentum continuation,
* leadership,
* and expanding price strength.

A stock moving from Q4 into Q1 may represent a developing recovery turning into a confirmed expansion phase.

### Q2 — Bearish Reversion

**Negative Velocity / Positive Stretch**

Price remains above its trend structure, but momentum is weakening.

This can indicate:

* an aging uptrend,
* loss of momentum,
* consolidation,
* profit-taking,
* or the beginning of a pullback.

Stocks that are highly stretched in Q1 and begin rotating into Q2 may be entering an exhaustion phase.

### Q3 — Bearish Expansion

**Negative Velocity / Negative Stretch**

Price is below its trend structure and downside momentum is increasing.

This is typically associated with:

* established downtrends,
* accelerating weakness,
* distribution,
* and bearish continuation.

### Q4 — Bullish Reversion

**Positive Velocity / Negative Stretch**

Price remains below its trend structure, but momentum has turned positive.

This can signal:

* improving conditions,
* mean reversion,
* early recovery,
* or a potential transition back into bullish expansion.

A rotation from Q4 into Q1 is one of the most important bullish transitions on the chart.

## Multi-Asset Tracking

The indicator supports up to **11 editable symbols**.

Each asset is displayed with:

* its own color,
* a historical trail,
* a current-position marker,
* and an automatically generated ticker label.

This makes it easy to compare:

* relative trend strength,
* market rotation,
* momentum leadership,
* and differences in trend maturity.

## Trailing Paths

Each ticker includes a configurable historical trail.

The trail shows how the asset arrived at its current position and whether it is:

* accelerating,
* slowing,
* rotating,
* reversing,
* or moving sideways near a quadrant boundary.

The direction of the trail is often as important as the current quadrant.

## True Range Variability Clouds

Optional ribbons are drawn around each asset’s trail using:

[
\frac{\text{Standard Deviation of True Range}}
{\text{Average True Range}}
]

The calculation is blended over the same 8-, 13-, and 21-bar horizons used by the Velocity model.

Cloud thickness changes at every point along the trail:

* Narrow cloud: volatility is stable and movement is more orderly
* Wide cloud: volatility is inconsistent, noisy, or unstable

This provides an additional layer of information beyond direction and momentum.

The center trail shows where the asset is moving.

The surrounding cloud shows how reliable or disorderly that movement has been.

## Position-Sensitive Quadrant Statistics

A dedicated statistics table can be assigned to one requested ticker.

The table displays:

* current quadrant,
* current uninterrupted stay,
* average historical duration in each quadrant,
* number of completed quadrant runs,
* current Velocity and Stretch values,
* and transition probabilities over several forward horizons.

The transition model does not rely only on the quadrant name.

Each quadrant is divided into a 3 × 3 internal grid based on:

* Velocity magnitude: Low, Medium, or High
* Stretch magnitude: Low, Medium, or High

This creates 36 possible origin states:

[
4\text{ quadrants}
\times
3\text{ Velocity bins}
\times
3\text{ Stretch bins}
=====================

36\text{ states}
]

The model therefore estimates probabilities such as:

> From Q1 with High Velocity and Medium Stretch, what is the probability of being in Q1, Q2, Q3, or Q4 after 5, 10, 15, or 21 bars?

This provides a more detailed transition model than treating every point inside the same quadrant as identical.

## Customizable Smoothing

The Velocity, Stretch, and cloud calculations can be smoothed using:

* EMA
* RMA
* SMA
* WMA
* or no smoothing

An optional second smoothing pass is also available for users who prefer slower, cleaner trails.

## How to Use the Indicator

The indicator is best used to evaluate trend rotation rather than as a standalone buy or sell signal.

Examples:

* Multiple stocks rotating from Q4 into Q1 may indicate broad market recovery.
* A leader remaining in Q1 with a narrow cloud may indicate persistent, orderly momentum.
* A highly stretched stock in Q1 rotating toward Q2 may be losing momentum.
* A stock in Q4 with rising Velocity may be developing an early recovery setup.
* A widening cloud may warn that the apparent move is becoming less stable.
* A stock near a quadrant boundary may be more likely to switch states than one deep inside a quadrant.

The strongest interpretation comes from combining:

* current quadrant,
* trail direction,
* cloud width,
* distance from the quadrant boundaries,
* and the transition-probability table.

## Important Note

This indicator is intended as a visual and statistical market-analysis tool.

It does not predict future prices with certainty and should be used together with:

* trend confirmation,
* volume,
* support and resistance,
* fundamentals,
* earnings risk,
* and position-sizing rules.

## Source Code

````pine
//@version=6
indicator("Stretch/Velocity Quadrant Plot", overlay=false, max_bars_back=3500)

// ============================================================================
// STOCK INPUTS
// ============================================================================
sym01 = input.symbol("MSFT",  "Stock 1",  group="Stocks")
sym02 = input.symbol("AMZN",  "Stock 2",  group="Stocks")
sym03 = input.symbol("GOOGL", "Stock 3",  group="Stocks")
sym04 = input.symbol("BRK.B", "Stock 4",  group="Stocks")
sym05 = input.symbol("LLY",   "Stock 5",  group="Stocks")
sym06 = input.symbol("WMT",   "Stock 6",  group="Stocks")
sym07 = input.symbol("GE",    "Stock 7",  group="Stocks")
sym08 = input.symbol("XOM",   "Stock 8",  group="Stocks")
sym09 = input.symbol("LIN",   "Stock 9",  group="Stocks")
sym10 = input.symbol("PLD",   "Stock 10", group="Stocks")
sym11 = input.symbol("NEE",   "Stock 11", group="Stocks")

en01 = input.bool(true, "Enable Stock 1",  group="Enable")
en02 = input.bool(true, "Enable Stock 2",  group="Enable")
en03 = input.bool(true, "Enable Stock 3",  group="Enable")
en04 = input.bool(true, "Enable Stock 4",  group="Enable")
en05 = input.bool(true, "Enable Stock 5",  group="Enable")
en06 = input.bool(true, "Enable Stock 6",  group="Enable")
en07 = input.bool(true, "Enable Stock 7",  group="Enable")
en08 = input.bool(true, "Enable Stock 8",  group="Enable")
en09 = input.bool(true, "Enable Stock 9",  group="Enable")
en10 = input.bool(true, "Enable Stock 10", group="Enable")
en11 = input.bool(true, "Enable Stock 11", group="Enable")

// ============================================================================
// CALCULATION INPUTS
// ============================================================================
ema13Len = input.int(13, "EMA Short",  minval=1, group="Lengths")
ema21Len = input.int(21, "EMA Medium", minval=1, group="Lengths")
ema34Len = input.int(34, "EMA Long",   minval=1, group="Lengths")

roc13Len = input.int(8,  "Velocity Lookback - Short EMA",  minval=1, group="Lengths")
roc21Len = input.int(13, "Velocity Lookback - Medium EMA", minval=1, group="Lengths")
roc34Len = input.int(21, "Velocity Lookback - Long EMA",   minval=1, group="Lengths")

wShort  = input.float(0.25, "Weight Short",  minval=0, step=0.05, group="Weights")
wMedium = input.float(0.50, "Weight Medium", minval=0, step=0.05, group="Weights")
wLong   = input.float(0.25, "Weight Long",   minval=0, step=0.05, group="Weights")

smoothType  = input.string("EMA", "Smoothing Type", options=["EMA", "RMA", "SMA", "WMA", "None"], group="Smoothing")
smoothLen   = input.int(5, "Smoothing Length", minval=1, group="Smoothing")
smoothTwice = input.bool(false, "Apply Second Smoothing Pass", group="Smoothing")

trailLength = input.int(10, "Trail Length", minval=2, group="Display")
axisRange   = input.float(5.0, "Axis Range (± ATR units)", minval=1.0, step=0.5, group="Display")

// ============================================================================
// QUADRANT STATISTICS — ONE REQUESTED TICKER
// ============================================================================
statsTicker     = input.symbol("TSLA", "Statistics Ticker", group="Quadrant Statistics")
statsLookback   = input.int(2000, "Statistics Lookback", minval=50, maxval=2000, group="Quadrant Statistics")
transitionStep1 = input.int(5,  "Transition Step 1", minval=1, maxval=250, group="Quadrant Statistics")
transitionStep2 = input.int(10, "Transition Step 2", minval=1, maxval=250, group="Quadrant Statistics")
transitionStep3 = input.int(15, "Transition Step 3", minval=1, maxval=250, group="Quadrant Statistics")
transitionStep4 = input.int(21, "Transition Step 4", minval=1, maxval=250, group="Quadrant Statistics")
locationLowMax  = input.float(1.0, "Location Low/Medium Boundary (ATR units)", minval=0.1, step=0.1, group="Quadrant Statistics")
locationMedMax  = input.float(2.0, "Location Medium/High Boundary (ATR units)", minval=0.2, step=0.1, group="Quadrant Statistics")
showQuadrantStats = input.bool(true, "Show Quadrant Statistics Table", group="Quadrant Statistics")
quadrantTableLayout = input.string(
     "Compact",
     "Quadrant Table Layout",
     options=["Compact", "Detailed"],
     group="Quadrant Statistics")

showClouds        = input.bool(true, "Show TR Variability Clouds", group="TR Variability Cloud")
cloudSmoothType   = input.string("EMA", "Cloud Smoothing Type", options=["EMA", "RMA", "SMA", "WMA", "None"], group="TR Variability Cloud")
cloudSmoothLen    = input.int(5, "Cloud Smoothing Length", minval=1, group="TR Variability Cloud")
cloudScale        = input.float(0.50, "Cloud Thickness Scale", minval=0.0, step=0.05, group="TR Variability Cloud")
cloudMin          = input.float(0.05, "Minimum Cloud Half-Thickness", minval=0.0, step=0.01, group="TR Variability Cloud")
cloudMax          = input.float(0.60, "Maximum Cloud Half-Thickness", minval=0.01, step=0.05, group="TR Variability Cloud")
cloudTransparency = input.int(86, "Cloud Transparency", minval=0, maxval=100, group="TR Variability Cloud")

// ============================================================================
// ADAPTIVE KINEMATIC PROJECTION — STATISTICS TICKER
// ============================================================================
showProjection             = input.bool(true, "Show Adaptive Projection", group="Adaptive Projection")
projectionHorizon          = input.int(10, "Projection Horizon", minval=1, maxval=50, group="Adaptive Projection")
projectionMotionSmooth     = input.int(3, "Motion/Acceleration Smoothing", minval=1, maxval=20, group="Adaptive Projection")

projectionVelocityLookback = input.int(21, "Velocity Persistence Lookback", minval=5, maxval=500, group="Adaptive Projection")
projectionAccelLookback    = input.int(21, "Acceleration Persistence Lookback", minval=5, maxval=500, group="Adaptive Projection")
projectionPressureLookback = input.int(21, "Pressure Persistence Lookback", minval=5, maxval=500, group="Adaptive Projection")

projectionCalibrationLookback = input.int(252, "Dynamic Calibration Lookback", minval=60, maxval=2000, group="Adaptive Projection")
projectionWeightSmoothLen     = input.int(21, "Dynamic Weight Smoothing", minval=1, maxval=100, group="Adaptive Projection")

velocityRankWeight      = input.float(0.50, "Cv Weight — Velocity Rank", minval=0.0, maxval=1.0, step=0.05, group="Adaptive Projection")
velocityDirectionWeight = input.float(0.35, "Cv Weight — Direction Consistency", minval=0.0, maxval=1.0, step=0.05, group="Adaptive Projection")

accelRankWeight          = input.float(0.50, "Ca Weight — Acceleration Rank", minval=0.0, maxval=1.0, step=0.05, group="Adaptive Projection")
accelStabilityWeight     = input.float(0.35, "Ca Weight — Acceleration Stability", minval=0.0, maxval=1.0, step=0.05, group="Adaptive Projection")
accelDirectionWeight     = input.float(0.15, "Ca Weight — Direction Consistency", minval=0.0, maxval=1.0, step=0.05, group="Adaptive Projection")

pressureRankWeight       = input.float(0.70, "Cp Weight — Pressure Rank", minval=0.0, maxval=1.0, step=0.05, group="Adaptive Projection")
pressureAlignmentWeight  = input.float(0.30, "Cp Weight — Force/Acceleration Alignment", minval=0.0, maxval=1.0, step=0.05, group="Adaptive Projection")

pressureLen           = input.int(13, "Pressure Smoothing Length", minval=1, maxval=100, group="Adaptive Projection")
pressureBetaLookback  = input.int(252, "Pressure-Force Regression Lookback", minval=30, maxval=2000, group="Adaptive Projection")
pressureBetaSmoothLen = input.int(13, "Pressure Beta Smoothing", minval=1, maxval=100, group="Adaptive Projection")

showProjectionCloud        = input.bool(true, "Show Projection Uncertainty Ribbon", group="Adaptive Projection")
projectionUncertaintyScale = input.float(1.0, "Uncertainty Ribbon Scale", minval=0.0, maxval=5.0, step=0.1, group="Adaptive Projection")
projectionUncertaintyMax   = input.float(2.0, "Maximum Projection Half-Width", minval=0.05, maxval=10.0, step=0.05, group="Adaptive Projection")
projectionCloudTransparency = input.int(88, "Projection Ribbon Transparency", minval=0, maxval=100, group="Adaptive Projection")

projectionColor     = input.color(color.yellow, "Projection Color", group="Adaptive Projection")
projectionLineWidth = input.int(2, "Projection Line Width", minval=1, maxval=4, group="Adaptive Projection")
showProjectionStepMarkers = input.bool(true, "Show Each Projection Step", group="Adaptive Projection")
showProjectionStepNumbers = input.bool(false, "Number Projection Steps", group="Adaptive Projection")
projectionLabelGap  = input.float(0.20, "Projection Label Gap Above Ribbon", minval=0.0, maxval=2.0, step=0.05, group="Adaptive Projection")


// ============================================================================
// HELPERS
// ============================================================================
f_tickerOnly(string symbol) =>
    parts = str.split(symbol, ":")
    array.size(parts) > 1 ? array.get(parts, 1) : symbol

f_smooth(series float src) =>
    first =
         smoothType == "EMA" ? ta.ema(src, smoothLen) :
         smoothType == "RMA" ? ta.rma(src, smoothLen) :
         smoothType == "SMA" ? ta.sma(src, smoothLen) :
         smoothType == "WMA" ? ta.wma(src, smoothLen) :
         src

    smoothTwice ?
         (smoothType == "EMA" ? ta.ema(first, smoothLen) :
          smoothType == "RMA" ? ta.rma(first, smoothLen) :
          smoothType == "SMA" ? ta.sma(first, smoothLen) :
          smoothType == "WMA" ? ta.wma(first, smoothLen) :
          first) :
         first

f_smoothCloud(series float src) =>
    cloudSmoothType == "EMA" ? ta.ema(src, cloudSmoothLen) :
     cloudSmoothType == "RMA" ? ta.rma(src, cloudSmoothLen) :
     cloudSmoothType == "SMA" ? ta.sma(src, cloudSmoothLen) :
     cloudSmoothType == "WMA" ? ta.wma(src, cloudSmoothLen) :
     src

f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

// ============================================================================
// CORE CALCULATION
// ============================================================================
calc() =>
    emaShort  = ta.ema(hlc3, ema13Len)
    emaMedium = ta.ema(hlc3, ema21Len)
    emaLong   = ta.ema(hlc3, ema34Len)

    atrShort  = ta.atr(ema13Len)
    atrMedium = ta.atr(ema21Len)
    atrLong   = ta.atr(ema34Len)

    stretchShort  = (hlc3 - emaShort)  / math.max(atrShort,  syminfo.mintick)
    stretchMedium = (hlc3 - emaMedium) / math.max(atrMedium, syminfo.mintick)
    stretchLong   = (hlc3 - emaLong)   / math.max(atrLong,   syminfo.mintick)

    weightSum = math.max(wShort + wMedium + wLong, 1e-6)

    stretchRaw =
         (wShort * stretchShort +
          wMedium * stretchMedium +
          wLong * stretchLong) / weightSum

    velocityShort  = (emaShort  - emaShort[roc13Len])   / math.max(atrShort,  syminfo.mintick)
    velocityMedium = (emaMedium - emaMedium[roc21Len])  / math.max(atrMedium, syminfo.mintick)
    velocityLong   = (emaLong   - emaLong[roc34Len])    / math.max(atrLong,   syminfo.mintick)

    velocityRaw =
         (wShort * velocityShort +
          wMedium * velocityMedium +
          wLong * velocityLong) / weightSum

    tr = ta.tr(true)

    // Cloud variability uses the same 8/13/21 ROC horizons as velocity.
    trMeanShort  = ta.sma(tr, roc13Len)
    trMeanMedium = ta.sma(tr, roc21Len)
    trMeanLong   = ta.sma(tr, roc34Len)

    trStdevShort  = ta.stdev(tr, roc13Len)
    trStdevMedium = ta.stdev(tr, roc21Len)
    trStdevLong   = ta.stdev(tr, roc34Len)

    trCvShort  = trMeanShort  > 0 ? trStdevShort  / trMeanShort  : na
    trCvMedium = trMeanMedium > 0 ? trStdevMedium / trMeanMedium : na
    trCvLong   = trMeanLong   > 0 ? trStdevLong   / trMeanLong   : na

    trCvRaw =
         (wShort * trCvShort +
          wMedium * trCvMedium +
          wLong * trCvLong) / weightSum

    rng = high - low
    bp  = rng > 0 ? (close - low)  / rng * volume : 0.0
    sp  = rng > 0 ? (high  - close) / rng * volume : 0.0

    buyPressure  = ta.ema(bp, pressureLen)
    sellPressure = ta.ema(sp, pressureLen)
    pressureTotal = buyPressure + sellPressure

    pressureBalance =
         pressureTotal > 0 ?
         (buyPressure - sellPressure) / pressureTotal :
         0.0

    [f_smooth(velocityRaw), f_smooth(stretchRaw), f_smoothCloud(trCvRaw), pressureBalance]

// ============================================================================
// INDIVIDUAL 13/21/34 COMPONENTS FOR IMPLIED PRICE RANGE
// ============================================================================
f_projectionPriceComponents() =>
    emaShort  = ta.ema(hlc3, ema13Len)
    emaMedium = ta.ema(hlc3, ema21Len)
    emaLong   = ta.ema(hlc3, ema34Len)

    atrShort  = ta.atr(ema13Len)
    atrMedium = ta.atr(ema21Len)
    atrLong   = ta.atr(ema34Len)

    stretchShortRaw =
         (hlc3 - emaShort) /
         math.max(atrShort, syminfo.mintick)

    stretchMediumRaw =
         (hlc3 - emaMedium) /
         math.max(atrMedium, syminfo.mintick)

    stretchLongRaw =
         (hlc3 - emaLong) /
         math.max(atrLong, syminfo.mintick)

    velocityShortRaw =
         (emaShort - emaShort[roc13Len]) /
         math.max(atrShort, syminfo.mintick)

    velocityMediumRaw =
         (emaMedium - emaMedium[roc21Len]) /
         math.max(atrMedium, syminfo.mintick)

    velocityLongRaw =
         (emaLong - emaLong[roc34Len]) /
         math.max(atrLong, syminfo.mintick)

    [f_smooth(velocityShortRaw), f_smooth(velocityMediumRaw), f_smooth(velocityLongRaw), f_smooth(stretchShortRaw), f_smooth(stretchMediumRaw), f_smooth(stretchLongRaw), emaShort, emaMedium, emaLong, atrShort, atrMedium, atrLong, hlc3]

// ============================================================================
// REQUESTED-TICKER STATISTICS ENGINE
//
// IMPORTANT:
// The complete duration, baseline, origin-sample, transition and survival
// calculations below execute inside request.security(statsTicker, ...).
// This prevents the host chart ticker, session, weekend bars or bar_index
// from changing the statistics table.
// ============================================================================

f_quadrant(float x, float y) =>
    x >= 0 and y >= 0 ? 1 :
     x < 0 and y >= 0 ? 2 :
     x < 0 and y < 0 ? 3 : 4

f_quadrantName(int q) =>
    q == 1 ? "Q1 Bullish Expansion" :
     q == 2 ? "Q2 Bearish Reversion" :
     q == 3 ? "Q3 Bearish Expansion" :
     "Q4 Bullish Reversion"

f_quadrantShort(int q) =>
    q == 1 ? "Q1" : q == 2 ? "Q2" : q == 3 ? "Q3" : "Q4"

f_quadrantColor(int q) =>
    q == 1 ? #089981 :
     q == 2 ? #ff9800 :
     q == 3 ? #f23645 :
     #5b9cf6

f_locationBin(float value) =>
    magnitude = math.abs(value)
    magnitude < locationLowMax ? 1 :
     magnitude < locationMedMax ? 2 : 3

f_locationName(int binNo) =>
    binNo == 1 ? "Low" : binNo == 2 ? "Medium" : "High"

f_stateId(int quadrantNo, int xBin, int yBin) =>
    quadrantNo > 0 ? (quadrantNo - 1) * 9 + (xBin - 1) * 3 + yBin : 0

f_normalCdf(float x) =>
    t = 1.0 / (1.0 + 0.2316419 * math.abs(x))
    d = 0.3989423 * math.exp(-0.5 * x * x)
    p = d * t *
         (0.3193815 +
          t * (-0.3565638 +
          t * (1.781478 +
          t * (-1.821256 +
          t * 1.330274))))
    x > 0 ? 1.0 - p : p

f_gaussianStay(float horizon, float meanRemaining, float sdRemaining) =>
    na(meanRemaining) or na(sdRemaining) or sdRemaining <= 0 ?
         na :
         100.0 * (1.0 - f_normalCdf((horizon - meanRemaining) / sdRemaining))

f_pctText(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.0") + "%"

f_countPct(int countValue, int denominator) =>
    denominator > 0 ? 100.0 * float(countValue) / float(denominator) : na

f_statsEngine() =>
    [sx, sy, sv, sp] = calc()

    q = not na(sx) and not na(sy) ? f_quadrant(sx, sy) : 0
    xb = q > 0 ? f_locationBin(sx) : 0
    yb = q > 0 ? f_locationBin(sy) : 0
    state = f_stateId(q, xb, yb)

    var int duration = 0
    duration :=
         q == 0 ? 0 :
         barstate.isfirst ? 1 :
         q == nz(q[1], q) ? duration + 1 : 1

    runEndedLocal =
         q > 0 and
         nz(q[1], 0) > 0 and
         q != q[1]

    endedQLocal = runEndedLocal ? q[1] : 0
    endedDurationLocal = runEndedLocal ? duration[1] : 0

    q1DurationSum =
         math.sum(
              runEndedLocal and endedQLocal == 1 ?
              float(endedDurationLocal) :
              0.0,
              statsLookback)

    q2DurationSum =
         math.sum(
              runEndedLocal and endedQLocal == 2 ?
              float(endedDurationLocal) :
              0.0,
              statsLookback)

    q3DurationSum =
         math.sum(
              runEndedLocal and endedQLocal == 3 ?
              float(endedDurationLocal) :
              0.0,
              statsLookback)

    q4DurationSum =
         math.sum(
              runEndedLocal and endedQLocal == 4 ?
              float(endedDurationLocal) :
              0.0,
              statsLookback)

    q1Runs =
         math.sum(
              runEndedLocal and endedQLocal == 1 ? 1.0 : 0.0,
              statsLookback)

    q2Runs =
         math.sum(
              runEndedLocal and endedQLocal == 2 ? 1.0 : 0.0,
              statsLookback)

    q3Runs =
         math.sum(
              runEndedLocal and endedQLocal == 3 ? 1.0 : 0.0,
              statsLookback)

    q4Runs =
         math.sum(
              runEndedLocal and endedQLocal == 4 ? 1.0 : 0.0,
              statsLookback)

    avg1 = q1Runs > 0 ? q1DurationSum / q1Runs : na
    avg2 = q2Runs > 0 ? q2DurationSum / q2Runs : na
    avg3 = q3Runs > 0 ? q3DurationSum / q3Runs : na
    avg4 = q4Runs > 0 ? q4DurationSum / q4Runs : na

    maxStep =
         math.max(
              math.max(transitionStep1, transitionStep2),
              math.max(transitionStep3, transitionStep4))

    originStateLocal = bar_index > maxStep ? nz(state[maxStep], 0) : 0
    originQLocal = bar_index > maxStep ? nz(q[maxStep], 0) : 0
    originAgeLocal = bar_index > maxStep ? nz(duration[maxStep], 0) : 0
    originBarLocal = bar_index > maxStep ? bar_index - maxStep : na

    endpoint1 =
         originStateLocal > 0 ?
         nz(q[maxStep - transitionStep1], 0) :
         0

    endpoint2 =
         originStateLocal > 0 ?
         nz(q[maxStep - transitionStep2], 0) :
         0

    endpoint3 =
         originStateLocal > 0 ?
         nz(q[maxStep - transitionStep3], 0) :
         0

    endpoint4 =
         originStateLocal > 0 ?
         nz(q[maxStep - transitionStep4], 0) :
         0

    bool continuous1 = originStateLocal > 0 and originQLocal > 0
    bool continuous2 = originStateLocal > 0 and originQLocal > 0
    bool continuous3 = originStateLocal > 0 and originQLocal > 0
    bool continuous4 = originStateLocal > 0 and originQLocal > 0

    if continuous1
        for off = maxStep - transitionStep1 to maxStep
            if nz(q[off], 0) != originQLocal
                continuous1 := false
                break

    if continuous2
        for off = maxStep - transitionStep2 to maxStep
            if nz(q[off], 0) != originQLocal
                continuous2 := false
                break

    if continuous3
        for off = maxStep - transitionStep3 to maxStep
            if nz(q[off], 0) != originQLocal
                continuous3 := false
                break

    if continuous4
        for off = maxStep - transitionStep4 to maxStep
            if nz(q[off], 0) != originQLocal
                continuous4 := false
                break

    remainingLocal = maxStep + 1

    if originStateLocal > 0 and originQLocal > 0
        for h = 1 to maxStep
            if nz(q[maxStep - h], 0) != originQLocal
                remainingLocal := h - 1
                break

    [sx, sy, sv, sp, time, bar_index, q, xb, yb, state, duration, avg1, avg2, avg3, avg4, q1Runs, q2Runs, q3Runs, q4Runs, originStateLocal, originAgeLocal, originBarLocal, endpoint1, endpoint2, endpoint3, endpoint4, continuous1 ? 1 : 0, continuous2 ? 1 : 0, continuous3 ? 1 : 0, continuous4 ? 1 : 0, remainingLocal]

// ============================================================================
// FETCH MULTI-ASSET TRAILS
// ============================================================================
[x01, y01, v01, p01] = request.security(sym01, timeframe.period, calc())
[x02, y02, v02, p02] = request.security(sym02, timeframe.period, calc())
[x03, y03, v03, p03] = request.security(sym03, timeframe.period, calc())
[x04, y04, v04, p04] = request.security(sym04, timeframe.period, calc())
[x05, y05, v05, p05] = request.security(sym05, timeframe.period, calc())
[x06, y06, v06, p06] = request.security(sym06, timeframe.period, calc())
[x07, y07, v07, p07] = request.security(sym07, timeframe.period, calc())
[x08, y08, v08, p08] = request.security(sym08, timeframe.period, calc())
[x09, y09, v09, p09] = request.security(sym09, timeframe.period, calc())
[x10, y10, v10, p10] = request.security(sym10, timeframe.period, calc())
[x11, y11, v11, p11] = request.security(sym11, timeframe.period, calc())

// ============================================================================
// FETCH INDIVIDUAL PRICE-PROJECTION COMPONENTS FROM statsTicker CONTEXT
// ============================================================================
[statsVelShort, statsVelMedium, statsVelLong, statsStretchShort, statsStretchMedium, statsStretchLong, statsEmaShort, statsEmaMedium, statsEmaLong, statsAtrShort, statsAtrMedium, statsAtrLong, statsCurrentPrice] = request.security(statsTicker, timeframe.period, f_projectionPriceComponents(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// ============================================================================
// FETCH COMPLETE STATISTICS FROM statsTicker CONTEXT
// ============================================================================
[statsX, statsY, statsV, statsPressure, statsTime, statsBarIndex, statsQuadrant, statsXBin, statsYBin, statsState, currentQuadrantDuration, avgQ1, avgQ2, avgQ3, avgQ4, countQ1, countQ2, countQ3, countQ4, newOriginState, newOriginAge, newOriginBar, newOriginQ1, newOriginQ2, newOriginQ3, newOriginQ4, newOriginStay1, newOriginStay2, newOriginStay3, newOriginStay4, newOriginRemaining] = request.security(statsTicker, timeframe.period, f_statsEngine(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// Update the local sample arrays only once per newly completed statsTicker bar.
newStatsBar =
     not na(statsTime) and
     (na(statsTime[1]) or statsTime != statsTime[1])

var int[] obsState = array.new_int()
var int[] obsAge = array.new_int()
var int[] obsBar = array.new_int()

var int[] obsQ1 = array.new_int()
var int[] obsQ2 = array.new_int()
var int[] obsQ3 = array.new_int()
var int[] obsQ4 = array.new_int()

var int[] obsStay1 = array.new_int()
var int[] obsStay2 = array.new_int()
var int[] obsStay3 = array.new_int()
var int[] obsStay4 = array.new_int()

var int[] obsRemaining = array.new_int()

if newStatsBar and
   newOriginState > 0 and
   newOriginAge > 0 and
   not na(newOriginBar)

    array.push(obsState, newOriginState)
    array.push(obsAge, newOriginAge)
    array.push(obsBar, newOriginBar)

    array.push(obsQ1, newOriginQ1)
    array.push(obsQ2, newOriginQ2)
    array.push(obsQ3, newOriginQ3)
    array.push(obsQ4, newOriginQ4)

    array.push(obsStay1, newOriginStay1)
    array.push(obsStay2, newOriginStay2)
    array.push(obsStay3, newOriginStay3)
    array.push(obsStay4, newOriginStay4)

    array.push(obsRemaining, newOriginRemaining)

// Rolling cutoff is now based on the requested ticker's own bar_index.
observationCutoff =
     not na(statsBarIndex) ?
     statsBarIndex - statsLookback + 1 :
     na

while array.size(obsBar) > 0 and
      not na(observationCutoff) and
      array.get(obsBar, 0) < observationCutoff

    array.shift(obsState)
    array.shift(obsAge)
    array.shift(obsBar)

    array.shift(obsQ1)
    array.shift(obsQ2)
    array.shift(obsQ3)
    array.shift(obsQ4)

    array.shift(obsStay1)
    array.shift(obsStay2)
    array.shift(obsStay3)
    array.shift(obsStay4)

    array.shift(obsRemaining)

currentAvg =
     statsQuadrant == 1 ? avgQ1 :
     statsQuadrant == 2 ? avgQ2 :
     statsQuadrant == 3 ? avgQ3 :
     statsQuadrant == 4 ? avgQ4 : na

currentRuns =
     statsQuadrant == 1 ? countQ1 :
     statsQuadrant == 2 ? countQ2 :
     statsQuadrant == 3 ? countQ3 :
     statsQuadrant == 4 ? countQ4 : na

int matchedN = 0

int q1Step1 = 0
int q2Step1 = 0
int q3Step1 = 0
int q4Step1 = 0

int q1Step2 = 0
int q2Step2 = 0
int q3Step2 = 0
int q4Step2 = 0

int q1Step3 = 0
int q2Step3 = 0
int q3Step3 = 0
int q4Step3 = 0

int q1Step4 = 0
int q2Step4 = 0
int q3Step4 = 0
int q4Step4 = 0

int stayCount1 = 0
int stayCount2 = 0
int stayCount3 = 0
int stayCount4 = 0

float remainingSum = 0.0
float remainingSqSum = 0.0

if array.size(obsState) > 0 and statsState > 0
    for i = 0 to array.size(obsState) - 1
        stateMatch =
             array.get(obsState, i) == statsState

        ageMatch =
             array.get(obsAge, i) >= currentQuadrantDuration

        if stateMatch and ageMatch
            matchedN += 1

            out1 = array.get(obsQ1, i)
            out2 = array.get(obsQ2, i)
            out3 = array.get(obsQ3, i)
            out4 = array.get(obsQ4, i)

            q1Step1 += out1 == 1 ? 1 : 0
            q2Step1 += out1 == 2 ? 1 : 0
            q3Step1 += out1 == 3 ? 1 : 0
            q4Step1 += out1 == 4 ? 1 : 0

            q1Step2 += out2 == 1 ? 1 : 0
            q2Step2 += out2 == 2 ? 1 : 0
            q3Step2 += out2 == 3 ? 1 : 0
            q4Step2 += out2 == 4 ? 1 : 0

            q1Step3 += out3 == 1 ? 1 : 0
            q2Step3 += out3 == 2 ? 1 : 0
            q3Step3 += out3 == 3 ? 1 : 0
            q4Step3 += out3 == 4 ? 1 : 0

            q1Step4 += out4 == 1 ? 1 : 0
            q2Step4 += out4 == 2 ? 1 : 0
            q3Step4 += out4 == 3 ? 1 : 0
            q4Step4 += out4 == 4 ? 1 : 0

            stayCount1 += array.get(obsStay1, i)
            stayCount2 += array.get(obsStay2, i)
            stayCount3 += array.get(obsStay3, i)
            stayCount4 += array.get(obsStay4, i)

            rem = float(array.get(obsRemaining, i))
            remainingSum += rem
            remainingSqSum += rem * rem

remainingMean =
     matchedN > 0 ?
     remainingSum / matchedN :
     na

remainingVariance =
     matchedN > 1 ?
     math.max(
          remainingSqSum / matchedN -
          remainingMean * remainingMean,
          0.0) :
     na

remainingSD =
     not na(remainingVariance) ?
     math.sqrt(remainingVariance) :
     na

empStay1 = f_countPct(stayCount1, matchedN)
empStay2 = f_countPct(stayCount2, matchedN)
empStay3 = f_countPct(stayCount3, matchedN)
empStay4 = f_countPct(stayCount4, matchedN)

gaussStay1 =
     matchedN >= 10 ?
     f_gaussianStay(
          float(transitionStep1),
          remainingMean,
          remainingSD) :
     na

gaussStay2 =
     matchedN >= 10 ?
     f_gaussianStay(
          float(transitionStep2),
          remainingMean,
          remainingSD) :
     na

gaussStay3 =
     matchedN >= 10 ?
     f_gaussianStay(
          float(transitionStep3),
          remainingMean,
          remainingSD) :
     na

gaussStay4 =
     matchedN >= 10 ?
     f_gaussianStay(
          float(transitionStep4),
          remainingMean,
          remainingSD) :
     na

// ============================================================================
// ADAPTIVE KINEMATIC PROJECTION STATE
// ============================================================================
componentVelShortMotion = ta.ema(statsVelShort - statsVelShort[1], projectionMotionSmooth)
componentVelMediumMotion = ta.ema(statsVelMedium - statsVelMedium[1], projectionMotionSmooth)
componentVelLongMotion = ta.ema(statsVelLong - statsVelLong[1], projectionMotionSmooth)

componentStretchShortMotion = ta.ema(statsStretchShort - statsStretchShort[1], projectionMotionSmooth)
componentStretchMediumMotion = ta.ema(statsStretchMedium - statsStretchMedium[1], projectionMotionSmooth)
componentStretchLongMotion = ta.ema(statsStretchLong - statsStretchLong[1], projectionMotionSmooth)

componentVelShortAccel = ta.ema(componentVelShortMotion - componentVelShortMotion[1], projectionMotionSmooth)
componentVelMediumAccel = ta.ema(componentVelMediumMotion - componentVelMediumMotion[1], projectionMotionSmooth)
componentVelLongAccel = ta.ema(componentVelLongMotion - componentVelLongMotion[1], projectionMotionSmooth)

componentStretchShortAccel = ta.ema(componentStretchShortMotion - componentStretchShortMotion[1], projectionMotionSmooth)
componentStretchMediumAccel = ta.ema(componentStretchMediumMotion - componentStretchMediumMotion[1], projectionMotionSmooth)
componentStretchLongAccel = ta.ema(componentStretchLongMotion - componentStretchLongMotion[1], projectionMotionSmooth)

projectionMotionXRaw = statsX - statsX[1]
projectionMotionYRaw = statsY - statsY[1]

projectionMotionX = ta.ema(projectionMotionXRaw, projectionMotionSmooth)
projectionMotionY = ta.ema(projectionMotionYRaw, projectionMotionSmooth)

projectionAccelXRaw = projectionMotionX - projectionMotionX[1]
projectionAccelYRaw = projectionMotionY - projectionMotionY[1]

projectionAccelX = ta.ema(projectionAccelXRaw, projectionMotionSmooth)
projectionAccelY = ta.ema(projectionAccelYRaw, projectionMotionSmooth)

projectionSpeedNow = math.sqrt(
     projectionMotionX * projectionMotionX +
     projectionMotionY * projectionMotionY)

projectionSpeedPrev = math.sqrt(
     projectionMotionX[1] * projectionMotionX[1] +
     projectionMotionY[1] * projectionMotionY[1])

projectionDirectionCos =
     projectionSpeedNow > 1e-9 and projectionSpeedPrev > 1e-9 ?
     (
      projectionMotionX * projectionMotionX[1] +
      projectionMotionY * projectionMotionY[1]
     ) /
     (projectionSpeedNow * projectionSpeedPrev) :
     0.0

projectionDirectionConfidence =
     f_clamp((projectionDirectionCos + 1.0) / 2.0, 0.0, 1.0)

projectionAccelMagnitude = math.sqrt(
     projectionAccelX * projectionAccelX +
     projectionAccelY * projectionAccelY)

projectionAccelRatio =
     projectionAccelMagnitude /
     (projectionSpeedNow + 1e-6)

// --------------------------------------------------------------------------
// DATA-DERIVED SENSITIVITY CALIBRATION
//
// Each exponential transform is calibrated so that the ticker's own
// historical median maps to a confidence of 0.50.
// --------------------------------------------------------------------------
projectionLn2 = math.log(2.0)

projectionTrMedian =
     ta.percentile_linear_interpolation(
          math.max(nz(statsV, 0.0), 0.0),
          projectionCalibrationLookback,
          50)

projectionTrSensitivityDynamic =
     projectionLn2 /
     math.max(projectionTrMedian, 1e-6)

projectionAccelRatioMedian =
     ta.percentile_linear_interpolation(
          projectionAccelRatio,
          projectionCalibrationLookback,
          50)

projectionAccelSensitivityDynamic =
     projectionLn2 /
     math.max(projectionAccelRatioMedian, 1e-6)

projectionAxisDistance =
     math.min(math.abs(statsX), math.abs(statsY))

projectionAxisDistanceMedian =
     ta.percentile_linear_interpolation(
          projectionAxisDistance,
          projectionCalibrationLookback,
          50)

projectionBoundaryScaleDynamic =
     math.max(
          projectionAxisDistanceMedian / projectionLn2,
          1e-6)

// --------------------------------------------------------------------------
// CURRENT CONFIDENCE COMPONENTS
// --------------------------------------------------------------------------
projectionAccelConfidence =
     math.exp(
         -projectionAccelSensitivityDynamic *
         projectionAccelRatio)

projectionTrConfidence =
     math.exp(
         -projectionTrSensitivityDynamic *
         math.max(nz(statsV, 0.0), 0.0))

projectionSurvivalConfidence =
     na(empStay1) ? 0.50 : f_clamp(empStay1 / 100.0, 0.0, 1.0)

projectionBoundaryConfidence =
     1.0 -
     math.exp(
         -projectionAxisDistance /
         projectionBoundaryScaleDynamic)

// --------------------------------------------------------------------------
// DATA-DERIVED CONFIDENCE WEIGHTS
//
// A factor receives more weight when its lagged confidence historically
// predicts next-bar directional continuation in the X/Y plane.
// Negative relationships receive zero weight.
// --------------------------------------------------------------------------
projectionContinuationTarget =
     projectionDirectionConfidence

projectionRelTrRaw =
     math.max(
          nz(
               ta.correlation(
                    projectionTrConfidence[1],
                    projectionContinuationTarget,
                    projectionCalibrationLookback),
               0.0),
          0.0)

projectionRelDirectionRaw =
     math.max(
          nz(
               ta.correlation(
                    projectionDirectionConfidence[1],
                    projectionContinuationTarget,
                    projectionCalibrationLookback),
               0.0),
          0.0)

projectionRelAccelRaw =
     math.max(
          nz(
               ta.correlation(
                    projectionAccelConfidence[1],
                    projectionContinuationTarget,
                    projectionCalibrationLookback),
               0.0),
          0.0)

projectionRelSurvivalRaw =
     math.max(
          nz(
               ta.correlation(
                    projectionSurvivalConfidence[1],
                    projectionContinuationTarget,
                    projectionCalibrationLookback),
               0.0),
          0.0)

projectionRelBoundaryRaw =
     math.max(
          nz(
               ta.correlation(
                    projectionBoundaryConfidence[1],
                    projectionContinuationTarget,
                    projectionCalibrationLookback),
               0.0),
          0.0)

projectionRelTr =
     ta.ema(projectionRelTrRaw, projectionWeightSmoothLen)

projectionRelDirection =
     ta.ema(projectionRelDirectionRaw, projectionWeightSmoothLen)

projectionRelAccel =
     ta.ema(projectionRelAccelRaw, projectionWeightSmoothLen)

projectionRelSurvival =
     ta.ema(projectionRelSurvivalRaw, projectionWeightSmoothLen)

projectionRelBoundary =
     ta.ema(projectionRelBoundaryRaw, projectionWeightSmoothLen)

projectionReliabilitySum =
     projectionRelTr +
     projectionRelDirection +
     projectionRelAccel +
     projectionRelSurvival +
     projectionRelBoundary

projectionWTrDynamic =
     projectionReliabilitySum > 1e-9 ?
     projectionRelTr / projectionReliabilitySum :
     1.0 / 5.0

projectionWDirectionDynamic =
     projectionReliabilitySum > 1e-9 ?
     projectionRelDirection / projectionReliabilitySum :
     1.0 / 5.0

projectionWAccelDynamic =
     projectionReliabilitySum > 1e-9 ?
     projectionRelAccel / projectionReliabilitySum :
     1.0 / 5.0

projectionWSurvivalDynamic =
     projectionReliabilitySum > 1e-9 ?
     projectionRelSurvival / projectionReliabilitySum :
     1.0 / 5.0

projectionWBoundaryDynamic =
     projectionReliabilitySum > 1e-9 ?
     projectionRelBoundary / projectionReliabilitySum :
     1.0 / 5.0

projectionConfidence =
     math.exp(
         projectionWTrDynamic *
              math.log(math.max(projectionTrConfidence, 1e-6)) +
         projectionWDirectionDynamic *
              math.log(math.max(projectionDirectionConfidence, 1e-6)) +
         projectionWAccelDynamic *
              math.log(math.max(projectionAccelConfidence, 1e-6)) +
         projectionWSurvivalDynamic *
              math.log(math.max(projectionSurvivalConfidence, 1e-6)) +
         projectionWBoundaryDynamic *
              math.log(math.max(projectionBoundaryConfidence, 1e-6)))

// --------------------------------------------------------------------------
// INDEPENDENT DATA-DERIVED PERSISTENCE MODELS
//
// Dv: phase-plane velocity persistence
// Da: phase-plane acceleration persistence
// Dp: buy/sell-pressure persistence
//
// Broad uncertainty confidence C does NOT alter centerline dynamics.
// Each persistence has its own composite continuation score:
//   Cv = velocity rank + direction consistency
//   Ca = acceleration rank + acceleration stability + direction consistency
//   Cp = pressure rank + pressure-force/acceleration alignment
//
// Historical quadrant survival remains in broad projection confidence only.
// It does not alter velocity damping because staying in a quadrant and
// persisting in a motion direction are different concepts.
// Each composite score selects a value between that series' historical
// Q10 and Q90, then the result is restricted to [0, 0.999].
// --------------------------------------------------------------------------
projectionVelocityPersistenceNumerator =
     math.sum(
          projectionMotionX * projectionMotionX[1] +
          projectionMotionY * projectionMotionY[1],
          projectionVelocityLookback)

projectionVelocityPersistenceDenominator =
     math.sum(
          projectionMotionX[1] * projectionMotionX[1] +
          projectionMotionY[1] * projectionMotionY[1],
          projectionVelocityLookback)

projectionVelocityPersistenceRaw =
     projectionVelocityPersistenceDenominator > 1e-10 ?
     projectionVelocityPersistenceNumerator /
     projectionVelocityPersistenceDenominator :
     0.0

projectionVelocityQ10 =
     ta.percentile_linear_interpolation(
          projectionVelocityPersistenceRaw,
          projectionCalibrationLookback,
          10)

projectionVelocityQ90 =
     ta.percentile_linear_interpolation(
          projectionVelocityPersistenceRaw,
          projectionCalibrationLookback,
          90)

projectionVelocityRank =
     f_clamp(
          nz(
               ta.percentrank(
                    projectionVelocityPersistenceRaw,
                    projectionCalibrationLookback),
               50.0) / 100.0,
          0.0,
          1.0)

projectionVelocityWeightSum =
     velocityRankWeight +
     velocityDirectionWeight

projectionVelocityC =
     projectionVelocityWeightSum > 0.0 ?
     math.exp(
          (
           velocityRankWeight *
                math.log(math.max(projectionVelocityRank, 1e-6)) +
           velocityDirectionWeight *
                math.log(math.max(projectionDirectionConfidence, 1e-6))
          ) /
          projectionVelocityWeightSum) :
     projectionVelocityRank

projectionVelocityDamping =
     f_clamp(
          nz(projectionVelocityQ10, projectionVelocityPersistenceRaw) +
          (
           nz(projectionVelocityQ90, projectionVelocityPersistenceRaw) -
           nz(projectionVelocityQ10, projectionVelocityPersistenceRaw)
          ) *
          projectionVelocityC,
          0.0,
          0.999)

projectionAccelPersistenceNumerator =
     math.sum(
          projectionAccelX * projectionAccelX[1] +
          projectionAccelY * projectionAccelY[1],
          projectionAccelLookback)

projectionAccelPersistenceDenominator =
     math.sum(
          projectionAccelX[1] * projectionAccelX[1] +
          projectionAccelY[1] * projectionAccelY[1],
          projectionAccelLookback)

projectionAccelPersistenceRaw =
     projectionAccelPersistenceDenominator > 1e-10 ?
     projectionAccelPersistenceNumerator /
     projectionAccelPersistenceDenominator :
     0.0

projectionAccelQ10 =
     ta.percentile_linear_interpolation(
          projectionAccelPersistenceRaw,
          projectionCalibrationLookback,
          10)

projectionAccelQ90 =
     ta.percentile_linear_interpolation(
          projectionAccelPersistenceRaw,
          projectionCalibrationLookback,
          90)

projectionAccelRank =
     f_clamp(
          nz(
               ta.percentrank(
                    projectionAccelPersistenceRaw,
                    projectionCalibrationLookback),
               50.0) / 100.0,
          0.0,
          1.0)

projectionAccelWeightSum =
     accelRankWeight +
     accelStabilityWeight +
     accelDirectionWeight

projectionAccelC =
     projectionAccelWeightSum > 0.0 ?
     math.exp(
          (
           accelRankWeight *
                math.log(math.max(projectionAccelRank, 1e-6)) +
           accelStabilityWeight *
                math.log(math.max(projectionAccelConfidence, 1e-6)) +
           accelDirectionWeight *
                math.log(math.max(projectionDirectionConfidence, 1e-6))
          ) /
          projectionAccelWeightSum) :
     projectionAccelRank

projectionAccelerationDamping =
     f_clamp(
          nz(projectionAccelQ10, projectionAccelPersistenceRaw) +
          (
           nz(projectionAccelQ90, projectionAccelPersistenceRaw) -
           nz(projectionAccelQ10, projectionAccelPersistenceRaw)
          ) *
          projectionAccelC,
          0.0,
          0.999)

// --------------------------------------------------------------------------
// COMPONENT-SPECIFIC VELOCITY / ACCELERATION PERSISTENCE
//
// These values affect only the 13/21/34 implied-price projections.
// Each component Dv uses only its own persistence rank and direction.
// Quadrant survival is intentionally excluded from physical damping.
// --------------------------------------------------------------------------
f_component_persistence(
     float motionX,
     float motionY,
     float accelX,
     float accelY) =>

    speedNow =
         math.sqrt(
              motionX * motionX +
              motionY * motionY)

    speedPrev =
         math.sqrt(
              motionX[1] * motionX[1] +
              motionY[1] * motionY[1])

    directionCos =
         speedNow > 1e-9 and speedPrev > 1e-9 ?
         (
          motionX * motionX[1] +
          motionY * motionY[1]
         ) /
         (speedNow * speedPrev) :
         0.0

    directionConfidence =
         f_clamp(
              (directionCos + 1.0) / 2.0,
              0.0,
              1.0)

    accelMagnitude =
         math.sqrt(
              accelX * accelX +
              accelY * accelY)

    accelRatio =
         accelMagnitude /
         (speedNow + 1e-6)

    accelRatioMedian =
         ta.percentile_linear_interpolation(
              accelRatio,
              projectionCalibrationLookback,
              50)

    accelSensitivity =
         projectionLn2 /
         math.max(accelRatioMedian, 1e-6)

    accelConfidence =
         math.exp(
              -accelSensitivity *
              accelRatio)

    dvNumerator =
         math.sum(
              motionX * motionX[1] +
              motionY * motionY[1],
              projectionVelocityLookback)

    dvDenominator =
         math.sum(
              motionX[1] * motionX[1] +
              motionY[1] * motionY[1],
              projectionVelocityLookback)

    dvRaw =
         dvDenominator > 1e-10 ?
         dvNumerator / dvDenominator :
         0.0

    dvQ10 =
         ta.percentile_linear_interpolation(
              dvRaw,
              projectionCalibrationLookback,
              10)

    dvQ90 =
         ta.percentile_linear_interpolation(
              dvRaw,
              projectionCalibrationLookback,
              90)

    dvRank =
         f_clamp(
              nz(
                   ta.percentrank(
                        dvRaw,
                        projectionCalibrationLookback),
                   50.0) / 100.0,
              0.0,
              1.0)

    dvWeightSum =
         velocityRankWeight +
         velocityDirectionWeight

    cv =
         dvWeightSum > 0.0 ?
         math.exp(
              (
               velocityRankWeight *
                    math.log(math.max(dvRank, 1e-6)) +
               velocityDirectionWeight *
                    math.log(math.max(directionConfidence, 1e-6))
              ) /
              dvWeightSum) :
         dvRank

    dv =
         f_clamp(
              nz(dvQ10, dvRaw) +
              (
               nz(dvQ90, dvRaw) -
               nz(dvQ10, dvRaw)
              ) *
              cv,
              0.0,
              0.999)

    daNumerator =
         math.sum(
              accelX * accelX[1] +
              accelY * accelY[1],
              projectionAccelLookback)

    daDenominator =
         math.sum(
              accelX[1] * accelX[1] +
              accelY[1] * accelY[1],
              projectionAccelLookback)

    daRaw =
         daDenominator > 1e-10 ?
         daNumerator / daDenominator :
         0.0

    daQ10 =
         ta.percentile_linear_interpolation(
              daRaw,
              projectionCalibrationLookback,
              10)

    daQ90 =
         ta.percentile_linear_interpolation(
              daRaw,
              projectionCalibrationLookback,
              90)

    daRank =
         f_clamp(
              nz(
                   ta.percentrank(
                        daRaw,
                        projectionCalibrationLookback),
                   50.0) / 100.0,
              0.0,
              1.0)

    daWeightSum =
         accelRankWeight +
         accelStabilityWeight +
         accelDirectionWeight

    ca =
         daWeightSum > 0.0 ?
         math.exp(
              (
               accelRankWeight *
                    math.log(math.max(daRank, 1e-6)) +
               accelStabilityWeight *
                    math.log(math.max(accelConfidence, 1e-6)) +
               accelDirectionWeight *
                    math.log(math.max(directionConfidence, 1e-6))
              ) /
              daWeightSum) :
         daRank

    da =
         f_clamp(
              nz(daQ10, daRaw) +
              (
               nz(daQ90, daRaw) -
               nz(daQ10, daRaw)
              ) *
              ca,
              0.0,
              0.999)

    [dv, da]

[componentDvShort, componentDaShort] =
     f_component_persistence(
          componentVelShortMotion,
          componentStretchShortMotion,
          componentVelShortAccel,
          componentStretchShortAccel)

[componentDvMedium, componentDaMedium] =
     f_component_persistence(
          componentVelMediumMotion,
          componentStretchMediumMotion,
          componentVelMediumAccel,
          componentStretchMediumAccel)

[componentDvLong, componentDaLong] =
     f_component_persistence(
          componentVelLongMotion,
          componentStretchLongMotion,
          componentVelLongAccel,
          componentStretchLongAccel)

projectionPressurePersistenceNumerator =
     math.sum(
          statsPressure * statsPressure[1],
          projectionPressureLookback)

projectionPressurePersistenceDenominator =
     math.sum(
          statsPressure[1] * statsPressure[1],
          projectionPressureLookback)

projectionPressurePersistenceRaw =
     projectionPressurePersistenceDenominator > 1e-10 ?
     projectionPressurePersistenceNumerator /
     projectionPressurePersistenceDenominator :
     0.0

projectionPressureQ10 =
     ta.percentile_linear_interpolation(
          projectionPressurePersistenceRaw,
          projectionCalibrationLookback,
          10)

projectionPressureQ90 =
     ta.percentile_linear_interpolation(
          projectionPressurePersistenceRaw,
          projectionCalibrationLookback,
          90)

projectionPressureRank =
     f_clamp(
          nz(
               ta.percentrank(
                    projectionPressurePersistenceRaw,
                    projectionCalibrationLookback),
               50.0) / 100.0,
          0.0,
          1.0)

// ============================================================================
// DATA-DERIVED BUY/SELL PRESSURE FORCE
//
// Estimate the one-bar historical relationship:
//
//   accelX_t = alphaX + betaX * pressure_(t-1) + error
//   accelY_t = alphaY + betaY * pressure_(t-1) + error
//
// Using lagged pressure avoids using future information. The fitted beta
// coefficients determine how strongly the current pressure balance should
// influence the next projected X and Y acceleration.
// ============================================================================
pressureLag = statsPressure[1]
pressureVariance = ta.variance(pressureLag, pressureBetaLookback)

pressureCovX =
     ta.sma(pressureLag * projectionAccelX, pressureBetaLookback) -
     ta.sma(pressureLag, pressureBetaLookback) *
     ta.sma(projectionAccelX, pressureBetaLookback)

pressureCovY =
     ta.sma(pressureLag * projectionAccelY, pressureBetaLookback) -
     ta.sma(pressureLag, pressureBetaLookback) *
     ta.sma(projectionAccelY, pressureBetaLookback)

pressureBetaXRaw =
     not na(pressureVariance) and pressureVariance > 1e-10 ?
     pressureCovX / pressureVariance :
     0.0

pressureBetaYRaw =
     not na(pressureVariance) and pressureVariance > 1e-10 ?
     pressureCovY / pressureVariance :
     0.0

pressureBetaX = ta.ema(pressureBetaXRaw, pressureBetaSmoothLen)
pressureBetaY = ta.ema(pressureBetaYRaw, pressureBetaSmoothLen)

// Component-specific pressure-response regressions.
pressureCovXShort =
     ta.sma(pressureLag * componentVelShortAccel, pressureBetaLookback) -
     ta.sma(pressureLag, pressureBetaLookback) *
     ta.sma(componentVelShortAccel, pressureBetaLookback)

pressureCovXMedium =
     ta.sma(pressureLag * componentVelMediumAccel, pressureBetaLookback) -
     ta.sma(pressureLag, pressureBetaLookback) *
     ta.sma(componentVelMediumAccel, pressureBetaLookback)

pressureCovXLong =
     ta.sma(pressureLag * componentVelLongAccel, pressureBetaLookback) -
     ta.sma(pressureLag, pressureBetaLookback) *
     ta.sma(componentVelLongAccel, pressureBetaLookback)

pressureCovYShort =
     ta.sma(pressureLag * componentStretchShortAccel, pressureBetaLookback) -
     ta.sma(pressureLag, pressureBetaLookback) *
     ta.sma(componentStretchShortAccel, pressureBetaLookback)

pressureCovYMedium =
     ta.sma(pressureLag * componentStretchMediumAccel, pressureBetaLookback) -
     ta.sma(pressureLag, pressureBetaLookback) *
     ta.sma(componentStretchMediumAccel, pressureBetaLookback)

pressureCovYLong =
     ta.sma(pressureLag * componentStretchLongAccel, pressureBetaLookback) -
     ta.sma(pressureLag, pressureBetaLookback) *
     ta.sma(componentStretchLongAccel, pressureBetaLookback)

pressureBetaXShortRaw =
     not na(pressureVariance) and pressureVariance > 1e-10 ?
     pressureCovXShort / pressureVariance :
     0.0

pressureBetaXMediumRaw =
     not na(pressureVariance) and pressureVariance > 1e-10 ?
     pressureCovXMedium / pressureVariance :
     0.0

pressureBetaXLongRaw =
     not na(pressureVariance) and pressureVariance > 1e-10 ?
     pressureCovXLong / pressureVariance :
     0.0

pressureBetaYShortRaw =
     not na(pressureVariance) and pressureVariance > 1e-10 ?
     pressureCovYShort / pressureVariance :
     0.0

pressureBetaYMediumRaw =
     not na(pressureVariance) and pressureVariance > 1e-10 ?
     pressureCovYMedium / pressureVariance :
     0.0

pressureBetaYLongRaw =
     not na(pressureVariance) and pressureVariance > 1e-10 ?
     pressureCovYLong / pressureVariance :
     0.0

pressureBetaXShort = ta.ema(pressureBetaXShortRaw, pressureBetaSmoothLen)
pressureBetaXMedium = ta.ema(pressureBetaXMediumRaw, pressureBetaSmoothLen)
pressureBetaXLong = ta.ema(pressureBetaXLongRaw, pressureBetaSmoothLen)

pressureBetaYShort = ta.ema(pressureBetaYShortRaw, pressureBetaSmoothLen)
pressureBetaYMedium = ta.ema(pressureBetaYMediumRaw, pressureBetaSmoothLen)
pressureBetaYLong = ta.ema(pressureBetaYLongRaw, pressureBetaSmoothLen)

// Pressure remains exclusively a centerline force.
// Cp combines:
//   1) current pressure-persistence rank,
//   2) alignment between the estimated pressure-force vector and
//      current phase-plane acceleration.
projectionPressureForceX =
     nz(pressureBetaX, 0.0) * statsPressure

projectionPressureForceY =
     nz(pressureBetaY, 0.0) * statsPressure

projectionPressureForceMagnitude =
     math.sqrt(
          projectionPressureForceX * projectionPressureForceX +
          projectionPressureForceY * projectionPressureForceY)

projectionPressureAccelMagnitude =
     math.sqrt(
          projectionAccelX * projectionAccelX +
          projectionAccelY * projectionAccelY)

projectionPressureAlignmentCos =
     projectionPressureForceMagnitude > 1e-9 and
     projectionPressureAccelMagnitude > 1e-9 ?
     (
      projectionPressureForceX * projectionAccelX +
      projectionPressureForceY * projectionAccelY
     ) /
     (
      projectionPressureForceMagnitude *
      projectionPressureAccelMagnitude
     ) :
     0.0

projectionPressureAlignmentConfidence =
     f_clamp(
          (projectionPressureAlignmentCos + 1.0) / 2.0,
          0.0,
          1.0)

projectionPressureWeightSum =
     pressureRankWeight +
     pressureAlignmentWeight

projectionPressureC =
     projectionPressureWeightSum > 0.0 ?
     math.exp(
          (
           pressureRankWeight *
                math.log(math.max(projectionPressureRank, 1e-6)) +
           pressureAlignmentWeight *
                math.log(math.max(projectionPressureAlignmentConfidence, 1e-6))
          ) /
          projectionPressureWeightSum) :
     projectionPressureRank

projectionPressureDamping =
     f_clamp(
          nz(projectionPressureQ10, projectionPressurePersistenceRaw) +
          (
           nz(projectionPressureQ90, projectionPressurePersistenceRaw) -
           nz(projectionPressureQ10, projectionPressurePersistenceRaw)
          ) *
          projectionPressureC,
          0.0,
          0.999)

// One-step velocity-model residual supplies a historical phase-plane noise
// scale. Confidence changes ribbon width only; it does not alter Dv/Da/Dp.
projectionVelocityResidualX =
     projectionMotionX -
     projectionVelocityDamping * projectionMotionX[1]

projectionVelocityResidualY =
     projectionMotionY -
     projectionVelocityDamping * projectionMotionY[1]

projectionVelocityResidualSq =
     projectionVelocityResidualX * projectionVelocityResidualX +
     projectionVelocityResidualY * projectionVelocityResidualY

projectionResidualRms =
     math.sqrt(
          math.max(
               ta.sma(
                    projectionVelocityResidualSq,
                    projectionCalibrationLookback),
               0.0))

projectionConfidenceWidthFactor =
     1.0 /
     math.sqrt(
          math.max(projectionConfidence, 0.05))


// ============================================================================
// RESTRUCTURED QUADRANT STATISTICS TABLE
// Replaces the entire "if barstate.islast and showQuadrantStats" block.
// All underlying arrays/variables (matchedN, avgQ1-4, empStay*, gaussStay*,
// remainingMean, remainingSD, statsX/Y/V, etc.) are unchanged — this only
// changes how they are laid out and labeled.
//
// Table is now 6 columns x 17 rows (one row shorter — row 15 "Consistency
// check" dropped, since it computed nothing).
// ============================================================================

var table quadrantStatsTable = table.new(position.bottom_right, 6, 17, border_width=1)

if barstate.islast and not showQuadrantStats
    table.clear(quadrantStatsTable, 0, 0, 5, 16)

if barstate.islast and showQuadrantStats and quadrantTableLayout == "Compact"
    table.clear(quadrantStatsTable, 0, 0, 5, 16)

    compactHeaderBg = color.rgb(28, 28, 28)
    compactSectionBg = color.rgb(18, 18, 18)
    compactQColor = statsQuadrant > 0 ? f_quadrantColor(statsQuadrant) : color.gray
    compactTicker = f_tickerOnly(statsTicker)

    // Row 0: title.
    table.cell(
         quadrantStatsTable,
         0,
         0,
         compactTicker + "  " + f_quadrantShort(statsQuadrant),
         text_color=color.white,
         bgcolor=compactSectionBg,
         text_size=size.small)
    table.cell(quadrantStatsTable, 1, 0, "", bgcolor=compactSectionBg)
    table.cell(quadrantStatsTable, 2, 0, "", bgcolor=compactSectionBg)
    table.cell(quadrantStatsTable, 3, 0, "", bgcolor=compactSectionBg)
    table.cell(quadrantStatsTable, 4, 0, "", bgcolor=compactSectionBg)
    table.cell(quadrantStatsTable, 5, 0, "", bgcolor=compactSectionBg)

    // Row 1: current state and age.
    table.cell(
         quadrantStatsTable,
         0,
         1,
         statsQuadrant > 0 ?
              f_quadrantName(statsQuadrant) :
              "n/a",
         text_color=color.white,
         bgcolor=compactQColor,
         text_size=size.small)
    table.cell(
         quadrantStatsTable,
         1,
         1,
         "Age " + str.tostring(currentQuadrantDuration),
         text_color=color.white,
         text_size=size.small)
    table.cell(
         quadrantStatsTable,
         2,
         1,
         "X " + str.tostring(statsX, "#.##"),
         text_color=color.white,
         text_size=size.small)
    table.cell(
         quadrantStatsTable,
         3,
         1,
         "Y " + str.tostring(statsY, "#.##"),
         text_color=color.white,
         text_size=size.small)
    table.cell(
         quadrantStatsTable,
         4,
         1,
         "CV " + str.tostring(statsV, "#.##"),
         text_color=color.white,
         text_size=size.small)
    table.cell(quadrantStatsTable, 5, 1, "", text_size=size.small)

    // Row 2: baseline and matched-sample summary.
    table.cell(
         quadrantStatsTable,
         0,
         2,
         "Avg " + (na(currentAvg) ? "n/a" : str.tostring(currentAvg, "#.1")),
         text_color=compactQColor,
         text_size=size.small)
    table.cell(
         quadrantStatsTable,
         1,
         2,
         "Runs " + (na(currentRuns) ? "n/a" : str.tostring(int(currentRuns))),
         text_color=compactQColor,
         text_size=size.small)
    table.cell(
         quadrantStatsTable,
         2,
         2,
         "N " + str.tostring(matchedN),
         text_color=color.white,
         text_size=size.small)
    table.cell(
         quadrantStatsTable,
         3,
         2,
         "Rem " +
         (
          na(remainingMean) or na(remainingSD) ?
          "n/a" :
          str.tostring(remainingMean, "#.1") + "±" +
          str.tostring(remainingSD, "#.1")
         ),
         text_color=color.white,
         text_size=size.small)
    table.cell(
         quadrantStatsTable,
         4,
         2,
         "LB " + str.tostring(statsLookback),
         text_color=color.gray,
         text_size=size.small)
    table.cell(quadrantStatsTable, 5, 2, "", text_size=size.small)

    // Row 3: transition header.
    table.cell(quadrantStatsTable, 0, 3, "End", text_color=color.white, bgcolor=compactHeaderBg, text_size=size.small)
    table.cell(quadrantStatsTable, 1, 3, "Q1", text_color=#089981, bgcolor=compactHeaderBg, text_size=size.small)
    table.cell(quadrantStatsTable, 2, 3, "Q2", text_color=#ff9800, bgcolor=compactHeaderBg, text_size=size.small)
    table.cell(quadrantStatsTable, 3, 3, "Q3", text_color=#f23645, bgcolor=compactHeaderBg, text_size=size.small)
    table.cell(quadrantStatsTable, 4, 3, "Q4", text_color=#5b9cf6, bgcolor=compactHeaderBg, text_size=size.small)
    table.cell(quadrantStatsTable, 5, 3, "", bgcolor=compactHeaderBg)

    compactSteps = array.from(transitionStep1, transitionStep2, transitionStep3, transitionStep4)

    for compactOffset = 0 to 3
        compactStep = array.get(compactSteps, compactOffset)
        compactRow = 4 + compactOffset

        compactQ1 =
             compactOffset == 0 ? f_countPct(q1Step1, matchedN) :
             compactOffset == 1 ? f_countPct(q1Step2, matchedN) :
             compactOffset == 2 ? f_countPct(q1Step3, matchedN) :
                                  f_countPct(q1Step4, matchedN)

        compactQ2 =
             compactOffset == 0 ? f_countPct(q2Step1, matchedN) :
             compactOffset == 1 ? f_countPct(q2Step2, matchedN) :
             compactOffset == 2 ? f_countPct(q2Step3, matchedN) :
                                  f_countPct(q2Step4, matchedN)

        compactQ3 =
             compactOffset == 0 ? f_countPct(q3Step1, matchedN) :
             compactOffset == 1 ? f_countPct(q3Step2, matchedN) :
             compactOffset == 2 ? f_countPct(q3Step3, matchedN) :
                                  f_countPct(q3Step4, matchedN)

        compactQ4 =
             compactOffset == 0 ? f_countPct(q4Step1, matchedN) :
             compactOffset == 1 ? f_countPct(q4Step2, matchedN) :
             compactOffset == 2 ? f_countPct(q4Step3, matchedN) :
                                  f_countPct(q4Step4, matchedN)

        table.cell(quadrantStatsTable, 0, compactRow, "t+" + str.tostring(compactStep), text_color=color.white, text_size=size.small)
        table.cell(quadrantStatsTable, 1, compactRow, f_pctText(compactQ1), text_color=#089981, text_size=size.small)
        table.cell(quadrantStatsTable, 2, compactRow, f_pctText(compactQ2), text_color=#ff9800, text_size=size.small)
        table.cell(quadrantStatsTable, 3, compactRow, f_pctText(compactQ3), text_color=#f23645, text_size=size.small)
        table.cell(quadrantStatsTable, 4, compactRow, f_pctText(compactQ4), text_color=#5b9cf6, text_size=size.small)
        table.cell(quadrantStatsTable, 5, compactRow, "", text_size=size.small)

    // Row 8: same-quadrant survival header.
    table.cell(
         quadrantStatsTable,
         0,
         8,
         "Stay " + f_quadrantShort(statsQuadrant),
         text_color=color.white,
         bgcolor=compactHeaderBg,
         text_size=size.small)
    table.cell(quadrantStatsTable, 1, 8, "Emp", text_color=color.aqua, bgcolor=compactHeaderBg, text_size=size.small)
    table.cell(quadrantStatsTable, 2, 8, "Gauss", text_color=color.fuchsia, bgcolor=compactHeaderBg, text_size=size.small)
    table.cell(quadrantStatsTable, 3, 8, "", bgcolor=compactHeaderBg)
    table.cell(quadrantStatsTable, 4, 8, "", bgcolor=compactHeaderBg)
    table.cell(quadrantStatsTable, 5, 8, "", bgcolor=compactHeaderBg)

    compactEmp = array.from(empStay1, empStay2, empStay3, empStay4)
    compactGauss = array.from(gaussStay1, gaussStay2, gaussStay3, gaussStay4)

    for compactOffset = 0 to 3
        compactRow = 9 + compactOffset
        compactStep = array.get(compactSteps, compactOffset)

        table.cell(quadrantStatsTable, 0, compactRow, "+" + str.tostring(compactStep), text_color=color.white, text_size=size.small)
        table.cell(
             quadrantStatsTable,
             1,
             compactRow,
             f_pctText(array.get(compactEmp, compactOffset)),
             text_color=color.aqua,
             text_size=size.small)
        table.cell(
             quadrantStatsTable,
             2,
             compactRow,
             f_pctText(array.get(compactGauss, compactOffset)),
             text_color=color.fuchsia,
             text_size=size.small)
        table.cell(quadrantStatsTable, 3, compactRow, "", text_size=size.small)
        table.cell(quadrantStatsTable, 4, compactRow, "", text_size=size.small)
        table.cell(quadrantStatsTable, 5, compactRow, "", text_size=size.small)

if barstate.islast and showQuadrantStats and quadrantTableLayout == "Detailed"
    table.clear(quadrantStatsTable, 0, 0, 5, 16)

    headerBg    = color.rgb(32, 32, 32)
    sectionBg   = color.rgb(20, 20, 20)
    qColor      = statsQuadrant > 0 ? f_quadrantColor(statsQuadrant) : color.gray
    tickerName  = f_tickerOnly(statsTicker)

    // ────────────────────────────────────────────────────────────────
    // SECTION 1 — RIGHT NOW
    // Current quadrant, how long it's been there, and the raw
    // velocity/stretch/variability values driving the plot.
    // ────────────────────────────────────────────────────────────────
    table.cell(quadrantStatsTable, 0, 0, "RIGHT NOW — " + tickerName, text_color=color.white, bgcolor=sectionBg)
    table.cell(quadrantStatsTable, 1, 0, "", bgcolor=sectionBg)
    table.cell(quadrantStatsTable, 2, 0, "", bgcolor=sectionBg)
    table.cell(quadrantStatsTable, 3, 0, "", bgcolor=sectionBg)
    table.cell(quadrantStatsTable, 4, 0, "", bgcolor=sectionBg)
    table.cell(quadrantStatsTable, 5, 0, "", bgcolor=sectionBg)

    table.cell(quadrantStatsTable, 0, 1, "Current quadrant", text_color=color.white)
    table.cell(
         quadrantStatsTable,
         1,
         1,
         statsQuadrant > 0 ?
              f_quadrantName(statsQuadrant) +
              "  (X:" + f_locationName(statsXBin) +
              " Y:" + f_locationName(statsYBin) + ")" :
              "n/a",
         text_color=color.white,
         bgcolor=qColor)
    table.cell(quadrantStatsTable, 2, 1, "Duration so far", text_color=color.gray, text_size=size.small)
    table.cell(quadrantStatsTable, 3, 1, str.tostring(currentQuadrantDuration) + " bars", text_color=color.white)
    table.cell(quadrantStatsTable, 4, 1, "Velocity / Stretch / TR-CV", text_color=color.gray, text_size=size.small)
    table.cell(
         quadrantStatsTable,
         5,
         1,
         str.tostring(statsX, "#.##") + " / " + str.tostring(statsY, "#.##") + " / " + str.tostring(statsV, "#.##"),
         text_color=color.white)

    // ────────────────────────────────────────────────────────────────
    // SECTION 2 — ALL-TIME BASELINE FOR THE CURRENT QUADRANT
    // "Across all history (last `statsLookback` bars), how long does a
    // Q-stay like the one you're in right now typically last, and how
    // many times has it happened?" — this is the unconditional baseline,
    // not filtered by the finer X/Y position or current age.
    // ────────────────────────────────────────────────────────────────
    table.cell(quadrantStatsTable, 0, 2, "ALL-TIME BASELINE — " + f_quadrantShort(statsQuadrant), text_color=color.white, bgcolor=sectionBg)
    table.cell(quadrantStatsTable, 1, 2, "", bgcolor=sectionBg)
    table.cell(quadrantStatsTable, 2, 2, "", bgcolor=sectionBg)
    table.cell(quadrantStatsTable, 3, 2, "", bgcolor=sectionBg)
    table.cell(quadrantStatsTable, 4, 2, "", bgcolor=sectionBg)
    table.cell(quadrantStatsTable, 5, 2, "", bgcolor=sectionBg)

    table.cell(quadrantStatsTable, 0, 3, "Avg stay in " + f_quadrantShort(statsQuadrant), text_color=color.white)
    table.cell(quadrantStatsTable, 1, 3, na(currentAvg) ? "n/a" : str.tostring(currentAvg, "#.1") + " bars", text_color=qColor)
    table.cell(quadrantStatsTable, 2, 3, "Completed runs", text_color=color.gray, text_size=size.small)
    table.cell(quadrantStatsTable, 3, 3, na(currentRuns) ? "n/a" : str.tostring(int(currentRuns)), text_color=qColor)
    table.cell(quadrantStatsTable, 4, 3, "Lookback window", text_color=color.gray, text_size=size.small)
    table.cell(quadrantStatsTable, 5, 3, str.tostring(statsLookback) + " bars", text_color=color.gray)

    // Reference row: average stay across ALL FOUR quadrants, for context
    // on how the current quadrant compares to the others.
    table.cell(quadrantStatsTable, 0, 4, "Avg stay, all quadrants", text_color=color.gray, text_size=size.small)
    table.cell(quadrantStatsTable, 1, 4, (na(avgQ1) ? "n/a" : str.tostring(avgQ1, "#.1")) + " / " + (na(avgQ2) ? "n/a" : str.tostring(avgQ2, "#.1")), text_color=color.white, text_size=size.small)
    table.cell(quadrantStatsTable, 2, 4, "(Q1 / Q2)", text_color=color.gray, text_size=size.small)
    table.cell(quadrantStatsTable, 3, 4, (na(avgQ3) ? "n/a" : str.tostring(avgQ3, "#.1")) + " / " + (na(avgQ4) ? "n/a" : str.tostring(avgQ4, "#.1")), text_color=color.white, text_size=size.small)
    table.cell(quadrantStatsTable, 4, 4, "(Q3 / Q4)", text_color=color.gray, text_size=size.small)
    table.cell(quadrantStatsTable, 5, 4, "", bgcolor=color.new(color.gray, 100))

    // ────────────────────────────────────────────────────────────────
    // SECTION 3 — SIMILAR SETUPS HISTORICALLY
    // This is the matched-sample analysis. A historical "origin" matches
    // the current bar only if BOTH:
    //   • same 36-state (quadrant AND X-position-bin AND Y-position-bin)
    //   • that origin's age in its quadrant was >= currentQuadrantDuration
    //     (i.e. "already survived at least as long as now")
    // matchedN is the count of such origins within statsLookback bars.
    // Transition % and survival % below are both computed from this SAME
    // matched sample — they answer two related questions about it.
    // ────────────────────────────────────────────────────────────────
    table.cell(quadrantStatsTable, 0, 5, "SIMILAR SETUPS HISTORICALLY", text_color=color.white, bgcolor=sectionBg)
    table.cell(quadrantStatsTable, 1, 5, "", bgcolor=sectionBg)
    table.cell(quadrantStatsTable, 2, 5, "", bgcolor=sectionBg)
    table.cell(quadrantStatsTable, 3, 5, "", bgcolor=sectionBg)
    table.cell(quadrantStatsTable, 4, 5, "", bgcolor=sectionBg)
    table.cell(quadrantStatsTable, 5, 5, "", bgcolor=sectionBg)

    table.cell(quadrantStatsTable, 0, 6, "Match criteria", text_color=color.gray, text_size=size.small)
    table.cell(
         quadrantStatsTable,
         1,
         6,
         "Same 36-state (Q+X+Y)\n& age ≥ " + str.tostring(currentQuadrantDuration) + " bars",
         text_color=color.white,
         text_size=size.small)
    table.cell(quadrantStatsTable, 2, 6, "Sample size (N)", text_color=color.gray, text_size=size.small)
    table.cell(quadrantStatsTable, 3, 6, str.tostring(matchedN), text_color=color.white)
    table.cell(quadrantStatsTable, 4, 6, "Remaining life μ ± σ", text_color=color.gray, text_size=size.small)
    table.cell(
         quadrantStatsTable,
         5,
         6,
         na(remainingMean) or na(remainingSD) ?
              "n/a" :
              str.tostring(remainingMean, "#.1") + " ± " + str.tostring(remainingSD, "#.1") + " bars",
         text_color=color.white,
         text_size=size.small)

    // ── Sub-section 3a: Where does it end up? ──
    table.cell(quadrantStatsTable, 0, 7, "→ Where it ends up", text_color=color.white, bgcolor=headerBg, text_size=size.small)
    table.cell(quadrantStatsTable, 1, 7, "Q1", text_color=#089981, bgcolor=headerBg)
    table.cell(quadrantStatsTable, 2, 7, "Q2", text_color=#ff9800, bgcolor=headerBg)
    table.cell(quadrantStatsTable, 3, 7, "Q3", text_color=#f23645, bgcolor=headerBg)
    table.cell(quadrantStatsTable, 4, 7, "Q4", text_color=#5b9cf6, bgcolor=headerBg)
    table.cell(quadrantStatsTable, 5, 7, "(% of N above)", text_color=color.gray, text_size=size.small)

    steps = array.from(transitionStep1, transitionStep2, transitionStep3, transitionStep4)

    for rowOffset = 0 to 3
        step = array.get(steps, rowOffset)
        row = 8 + rowOffset

        pQ1 =
             rowOffset == 0 ? f_countPct(q1Step1, matchedN) :
             rowOffset == 1 ? f_countPct(q1Step2, matchedN) :
             rowOffset == 2 ? f_countPct(q1Step3, matchedN) :
                              f_countPct(q1Step4, matchedN)

        pQ2 =
             rowOffset == 0 ? f_countPct(q2Step1, matchedN) :
             rowOffset == 1 ? f_countPct(q2Step2, matchedN) :
             rowOffset == 2 ? f_countPct(q2Step3, matchedN) :
                              f_countPct(q2Step4, matchedN)

        pQ3 =
             rowOffset == 0 ? f_countPct(q3Step1, matchedN) :
             rowOffset == 1 ? f_countPct(q3Step2, matchedN) :
             rowOffset == 2 ? f_countPct(q3Step3, matchedN) :
                              f_countPct(q3Step4, matchedN)

        pQ4 =
             rowOffset == 0 ? f_countPct(q4Step1, matchedN) :
             rowOffset == 1 ? f_countPct(q4Step2, matchedN) :
             rowOffset == 2 ? f_countPct(q4Step3, matchedN) :
                              f_countPct(q4Step4, matchedN)

        table.cell(quadrantStatsTable, 0, row, "t+" + str.tostring(step) + " bars", text_color=color.white)
        table.cell(quadrantStatsTable, 1, row, f_pctText(pQ1), text_color=#089981)
        table.cell(quadrantStatsTable, 2, row, f_pctText(pQ2), text_color=#ff9800)
        table.cell(quadrantStatsTable, 3, row, f_pctText(pQ3), text_color=#f23645)
        table.cell(quadrantStatsTable, 4, row, f_pctText(pQ4), text_color=#5b9cf6)
        table.cell(quadrantStatsTable, 5, row, "", text_color=color.gray)

    // ── Sub-section 3b: Does it stay put? ──
    table.cell(quadrantStatsTable, 0, 12, "→ Stays in " + f_quadrantShort(statsQuadrant) + "?", text_color=color.white, bgcolor=headerBg, text_size=size.small)
    table.cell(quadrantStatsTable, 1, 12, "Empirical %", text_color=color.aqua, bgcolor=headerBg, text_size=size.small)
    table.cell(quadrantStatsTable, 2, 12, "Gaussian %", text_color=color.fuchsia, bgcolor=headerBg, text_size=size.small)
    table.cell(quadrantStatsTable, 3, 12, "", bgcolor=headerBg)
    table.cell(quadrantStatsTable, 4, 12, "", bgcolor=headerBg)
    table.cell(quadrantStatsTable, 5, 12, "(same N as above)", text_color=color.gray, text_size=size.small)

    empiricalValues = array.from(empStay1, empStay2, empStay3, empStay4)
    gaussianValues  = array.from(gaussStay1, gaussStay2, gaussStay3, gaussStay4)

    for rowOffset = 0 to 3
        row  = 13 + rowOffset
        step = array.get(steps, rowOffset)

        table.cell(quadrantStatsTable, 0, row, "+" + str.tostring(step) + " bars", text_color=color.white)
        table.cell(quadrantStatsTable, 1, row, f_pctText(array.get(empiricalValues, rowOffset)), text_color=color.aqua)
        table.cell(quadrantStatsTable, 2, row, f_pctText(array.get(gaussianValues, rowOffset)), text_color=color.fuchsia)
        table.cell(quadrantStatsTable, 3, row, "", text_color=color.white)
        table.cell(quadrantStatsTable, 4, row, "", text_color=color.white)
        table.cell(quadrantStatsTable, 5, row, "", text_color=color.gray)

// ============================================================================
// DRAWING OBJECTS
// ============================================================================
var polyline[] cloudPolygons = array.new<polyline>()
var polyline[] trails = array.new<polyline>()
var polyline[] projectedTrails = array.new<polyline>()
var polyline[] projectedClouds = array.new<polyline>()
var label[] labels = array.new<label>()
var line[] axes = array.new<line>()

var line horizontalAxis = na
var line verticalAxis = na

f_xPosition(float velocity) =>
    xScale = 40.0 / axisRange
    bar_index - 40 + math.round(velocity * xScale)

f_drawOne(string symbol, series float x, series float y, series float variability, color trailColor, bool enabled) =>
    if barstate.islast and enabled and not na(x) and not na(y) and not na(variability)
        if showClouds
            cloudPoints = array.new<chart.point>()

            // Upper edge: oldest to newest.
            for i = trailLength - 1 to 0
                pointX = f_xPosition(nz(x[i]))
                thickness = f_clamp(nz(variability[i]) * cloudScale, cloudMin, cloudMax)
                array.push(cloudPoints, chart.point.from_index(pointX, nz(y[i]) + thickness))

            // Lower edge: newest back to oldest, closing the ribbon.
            for i = 0 to trailLength - 1
                pointX = f_xPosition(nz(x[i]))
                thickness = f_clamp(nz(variability[i]) * cloudScale, cloudMin, cloudMax)
                array.push(cloudPoints, chart.point.from_index(pointX, nz(y[i]) - thickness))

            array.push(
                 cloudPolygons,
                 polyline.new(
                      cloudPoints,
                      false,
                      true,
                      xloc.bar_index,
                      color.new(trailColor, 100),
                      color.new(trailColor, cloudTransparency),
                      line.style_solid,
                      1))

        points = array.new<chart.point>()

        for i = trailLength - 1 to 0
            pointX = f_xPosition(nz(x[i]))
            pointY = nz(y[i])
            array.push(points, chart.point.from_index(pointX, pointY))

        array.push(
             trails,
             polyline.new(
                  points,
                  false,
                  false,
                  xloc.bar_index,
                  trailColor,
                  na,
                  line.style_solid,
                  2))

        labelX = f_xPosition(nz(x))
        labelY = nz(y)
        stockName = f_tickerOnly(symbol)

        array.push(
             labels,
             label.new(
                  labelX,
                  labelY,
                  "●",
                  xloc=xloc.bar_index,
                  yloc=yloc.price,
                  style=label.style_none,
                  textcolor=color.white,
                  size=size.normal))

        array.push(
             labels,
             label.new(
                  labelX + 1,
                  labelY,
                  stockName,
                  xloc=xloc.bar_index,
                  yloc=yloc.price,
                  style=label.style_none,
                  textcolor=trailColor,
                  size=size.small))


// ============================================================================
// DRAW ADAPTIVE FORWARD PROJECTION FOR THE STATISTICS TICKER
//
// Centerline dynamics:
//   P_k = Dp * P_(k-1)
//   a_k = Da * a_(k-1) + beta * P_k
//   v_k = Dv * v_(k-1) + a_k
//   r_k = r_(k-1) + v_k
//
// Confidence controls only the uncertainty ribbon.
// ============================================================================
f_drawProjection() =>
    if barstate.islast and showProjection and
       not na(statsX) and not na(statsY) and
       not na(projectionMotionX) and not na(projectionMotionY) and
       not na(projectionAccelX) and not na(projectionAccelY)

        projectionPoints = array.new<chart.point>()
        projectionUpper  = array.new<chart.point>()
        projectionLower  = array.new<chart.point>()

        float pxState = statsX
        float pyState = statsY

        float pvx = projectionMotionX
        float pvy = projectionMotionY

        float pax = projectionAccelX
        float pay = projectionAccelY

        float pState = statsPressure
        float finalHalfWidth = 0.0

        float compXShort = statsVelShort
        float compXMedium = statsVelMedium
        float compXLong = statsVelLong

        float compYShort = statsStretchShort
        float compYMedium = statsStretchMedium
        float compYLong = statsStretchLong

        float compVxShort = componentVelShortMotion
        float compVxMedium = componentVelMediumMotion
        float compVxLong = componentVelLongMotion

        float compVyShort = componentStretchShortMotion
        float compVyMedium = componentStretchMediumMotion
        float compVyLong = componentStretchLongMotion

        float compAxShort = componentVelShortAccel
        float compAxMedium = componentVelMediumAccel
        float compAxLong = componentVelLongAccel

        float compAyShort = componentStretchShortAccel
        float compAyMedium = componentStretchMediumAccel
        float compAyLong = componentStretchLongAccel

        float projectedEmaShort = statsEmaShort
        float projectedEmaMedium = statsEmaMedium
        float projectedEmaLong = statsEmaLong

        // Current position is the first polyline vertex.
        array.push(
             projectionPoints,
             chart.point.from_index(
                  f_xPosition(pxState),
                  pyState))

        // Current ribbon starts at zero width.
        array.push(
             projectionUpper,
             chart.point.from_index(
                  f_xPosition(pxState),
                  pyState))

        array.push(
             projectionLower,
             chart.point.from_index(
                  f_xPosition(pxState),
                  pyState))

        for step = 1 to projectionHorizon
            // Current pressure decays according to its own historically
            // estimated persistence.
            pState *= projectionPressureDamping

            // Acceleration has its own persistence and receives a decaying
            // pressure force at every projected step.
            pax :=
                 projectionAccelerationDamping * pax +
                 nz(pressureBetaX, 0.0) * pState

            pay :=
                 projectionAccelerationDamping * pay +
                 nz(pressureBetaY, 0.0) * pState

            // Velocity has an independently estimated persistence.
            pvx :=
                 projectionVelocityDamping * pvx +
                 pax

            pvy :=
                 projectionVelocityDamping * pvy +
                 pay

            pxState += pvx
            pyState += pvy

            // Project each original 13/21/34 component separately.
            compAxShort :=
                 componentDaShort * compAxShort +
                 nz(pressureBetaXShort, 0.0) * pState

            compAxMedium :=
                 componentDaMedium * compAxMedium +
                 nz(pressureBetaXMedium, 0.0) * pState

            compAxLong :=
                 componentDaLong * compAxLong +
                 nz(pressureBetaXLong, 0.0) * pState

            compAyShort :=
                 componentDaShort * compAyShort +
                 nz(pressureBetaYShort, 0.0) * pState

            compAyMedium :=
                 componentDaMedium * compAyMedium +
                 nz(pressureBetaYMedium, 0.0) * pState

            compAyLong :=
                 componentDaLong * compAyLong +
                 nz(pressureBetaYLong, 0.0) * pState

            compVxShort := componentDvShort * compVxShort + compAxShort
            compVxMedium := componentDvMedium * compVxMedium + compAxMedium
            compVxLong := componentDvLong * compVxLong + compAxLong

            compVyShort := componentDvShort * compVyShort + compAyShort
            compVyMedium := componentDvMedium * compVyMedium + compAyMedium
            compVyLong := componentDvLong * compVyLong + compAyLong

            compXShort += compVxShort
            compXMedium += compVxMedium
            compXLong += compVxLong

            compYShort += compVyShort
            compYMedium += compVyMedium
            compYLong += compVyLong

            projectedEmaShort += compXShort * statsAtrShort / math.max(float(roc13Len), 1.0)
            projectedEmaMedium += compXMedium * statsAtrMedium / math.max(float(roc21Len), 1.0)
            projectedEmaLong += compXLong * statsAtrLong / math.max(float(roc34Len), 1.0)

            projectedStepX = f_xPosition(pxState)

            array.push(
                 projectionPoints,
                 chart.point.from_index(
                      projectedStepX,
                      pyState))

            if showProjectionStepMarkers
                projectionStepText =
                     showProjectionStepNumbers ?
                     str.tostring(step) :
                     "•"

                array.push(
                     labels,
                     label.new(
                          projectedStepX,
                          pyState,
                          projectionStepText,
                          xloc=xloc.bar_index,
                          yloc=yloc.price,
                          style=label.style_none,
                          textcolor=projectionColor,
                          size=size.small))

            // Widen uncertainty with sqrt(horizon), historical residual noise,
            // and inverse confidence. Offset perpendicular to the path.
            stepSpeed = math.sqrt(pvx * pvx + pvy * pvy)

            normalX =
                 stepSpeed > 1e-9 ?
                 -pvy / stepSpeed :
                 0.0

            normalY =
                 stepSpeed > 1e-9 ?
                 pvx / stepSpeed :
                 1.0

            stepHalfWidth =
                 f_clamp(
                      projectionResidualRms *
                      math.sqrt(float(step)) *
                      projectionConfidenceWidthFactor *
                      projectionUncertaintyScale,
                      0.0,
                      projectionUncertaintyMax)

            finalHalfWidth := stepHalfWidth

            upperX = pxState + normalX * stepHalfWidth
            upperY = pyState + normalY * stepHalfWidth

            lowerX = pxState - normalX * stepHalfWidth
            lowerY = pyState - normalY * stepHalfWidth

            array.push(
                 projectionUpper,
                 chart.point.from_index(
                      f_xPosition(upperX),
                      upperY))

            array.push(
                 projectionLower,
                 chart.point.from_index(
                      f_xPosition(lowerX),
                      lowerY))

        if showProjectionCloud
            projectionCloudPoints = array.new<chart.point>()

            for i = 0 to array.size(projectionUpper) - 1
                array.push(
                     projectionCloudPoints,
                     array.get(projectionUpper, i))

            for i = array.size(projectionLower) - 1 to 0
                array.push(
                     projectionCloudPoints,
                     array.get(projectionLower, i))

            array.push(
                 projectedClouds,
                 polyline.new(
                      projectionCloudPoints,
                      false,
                      true,
                      xloc.bar_index,
                      color.new(projectionColor, 100),
                      color.new(projectionColor, projectionCloudTransparency),
                      line.style_solid,
                      1))

        array.push(
             projectedTrails,
             polyline.new(
                  projectionPoints,
                  false,
                  false,
                  xloc.bar_index,
                  projectionColor,
                  na,
                  line.style_dashed,
                  projectionLineWidth))

        endX = f_xPosition(pxState)
        endY = pyState

        array.push(
             labels,
             label.new(
                  endX,
                  endY,
                  "◇",
                  xloc=xloc.bar_index,
                  yloc=yloc.price,
                  style=label.style_none,
                  textcolor=projectionColor,
                  size=size.normal))

        projectedPriceShort =
             projectedEmaShort +
             compYShort * statsAtrShort

        projectedPriceMedium =
             projectedEmaMedium +
             compYMedium * statsAtrMedium

        projectedPriceLong =
             projectedEmaLong +
             compYLong * statsAtrLong

        projectionPriceWeightSum =
             math.max(
                  wShort + wMedium + wLong,
                  1e-6)

        projectedPriceBlend =
             (
              wShort * projectedPriceShort +
              wMedium * projectedPriceMedium +
              wLong * projectedPriceLong
             ) /
             projectionPriceWeightSum

        projectedPriceVariance =
             (
              wShort *
                   math.pow(
                        projectedPriceShort -
                        projectedPriceBlend,
                        2.0) +
              wMedium *
                   math.pow(
                        projectedPriceMedium -
                        projectedPriceBlend,
                        2.0) +
              wLong *
                   math.pow(
                        projectedPriceLong -
                        projectedPriceBlend,
                        2.0)
             ) /
             projectionPriceWeightSum

        projectedPriceSD =
             math.sqrt(
                  math.max(
                       projectedPriceVariance,
                       0.0))

        projectedPriceLow =
             projectedPriceBlend -
             projectedPriceSD

        projectedPriceHigh =
             projectedPriceBlend +
             projectedPriceSD

        projectedPctBlend =
             not na(statsCurrentPrice) and statsCurrentPrice != 0.0 ?
             100.0 *
             (projectedPriceBlend / statsCurrentPrice - 1.0) :
             na

        projectedPctSD =
             not na(statsCurrentPrice) and statsCurrentPrice != 0.0 ?
             100.0 *
             projectedPriceSD / statsCurrentPrice :
             na

        projectedPctLow =
             projectedPctBlend -
             projectedPctSD

        projectedPctHigh =
             projectedPctBlend +
             projectedPctSD

        projectionLabelY =
             endY +
             finalHalfWidth +
             projectionLabelGap

        projectionLabelText =
             "Proj " + str.tostring(projectionHorizon) +
             " Price " +
             str.tostring(projectedPriceBlend, format.mintick) +
             "\nModel dispersion " +
             str.tostring(projectedPriceLow, format.mintick) +
             "–" +
             str.tostring(projectedPriceHigh, format.mintick) +
             "\nChange " +
             str.tostring(projectedPctBlend, "#.##") +
             "%  (dispersion " +
             str.tostring(projectedPctLow, "#.##") +
             "% to " +
             str.tostring(projectedPctHigh, "#.##") +
             "%)" +
             "\nP13 " +
             str.tostring(projectedPriceShort, format.mintick) +
             " | P21 " +
             str.tostring(projectedPriceMedium, format.mintick) +
             " | P34 " +
             str.tostring(projectedPriceLong, format.mintick)

        array.push(
             labels,
             label.new(
                  endX + 1,
                  projectionLabelY,
                  projectionLabelText,
                  xloc=xloc.bar_index,
                  yloc=yloc.price,
                  style=label.style_label_left,
                  textcolor=projectionColor,
                  color=color.new(color.black, 78),
                  size=size.small))

// ============================================================================
// CLEANUP AND STATIC QUADRANT
// ============================================================================
if barstate.islast
    if array.size(cloudPolygons) > 0
        for i = 0 to array.size(cloudPolygons) - 1
            polyline.delete(array.get(cloudPolygons, i))

    if array.size(trails) > 0
        for i = 0 to array.size(trails) - 1
            polyline.delete(array.get(trails, i))

    if array.size(projectedTrails) > 0
        for i = 0 to array.size(projectedTrails) - 1
            polyline.delete(array.get(projectedTrails, i))

    if array.size(projectedClouds) > 0
        for i = 0 to array.size(projectedClouds) - 1
            polyline.delete(array.get(projectedClouds, i))

    if array.size(labels) > 0
        for i = 0 to array.size(labels) - 1
            label.delete(array.get(labels, i))

    if array.size(axes) > 0
        for i = 0 to array.size(axes) - 1
            line.delete(array.get(axes, i))

    array.clear(cloudPolygons)
    array.clear(trails)
    array.clear(projectedTrails)
    array.clear(projectedClouds)
    array.clear(labels)
    array.clear(axes)

    line.delete(horizontalAxis)
    line.delete(verticalAxis)

    horizontalAxis := line.new(
         bar_index - 80,
         0,
         bar_index,
         0,
         color=color.gray,
         style=line.style_dashed)

    verticalAxis := line.new(
         bar_index - 40,
         -axisRange,
         bar_index - 40,
         axisRange,
         color=color.gray,
         style=line.style_dashed)

    for xValue = -5 to 5
        xPosition = f_xPosition(xValue)

        array.push(
             axes,
             line.new(
                  xPosition,
                  -0.08,
                  xPosition,
                  0.08,
                  color=color.gray))

        array.push(
             labels,
             label.new(
                  xPosition,
                  -axisRange - 0.25,
                  str.tostring(xValue),
                  xloc=xloc.bar_index,
                  yloc=yloc.price,
                  style=label.style_none,
                  textcolor=color.gray,
                  size=size.small))

    for yValue = -5 to 5
        array.push(
             axes,
             line.new(
                  bar_index - 42,
                  yValue,
                  bar_index - 38,
                  yValue,
                  color=color.gray))

        array.push(
             labels,
             label.new(
                  bar_index - 44,
                  yValue,
                  str.tostring(yValue),
                  xloc=xloc.bar_index,
                  yloc=yloc.price,
                  style=label.style_none,
                  textcolor=color.gray,
                  size=size.small))

    array.push(
         labels,
         label.new(
              bar_index - 40,
              -axisRange - 0.55,
              "EMA Velocity (ATR units)",
              xloc=xloc.bar_index,
              yloc=yloc.price,
              style=label.style_none,
              textcolor=color.white,
              size=size.small))

    array.push(
         labels,
         label.new(
              bar_index - 79,
              axisRange + 0.20,
              "Price Stretch (ATR units)",
              xloc=xloc.bar_index,
              yloc=yloc.price,
              style=label.style_none,
              textcolor=color.white,
              size=size.small))

    array.push(
         labels,
         label.new(
              bar_index - 20,
              axisRange - 0.5,
              "Q1: Bullish Expansion\nVel + / Stretch +",
              xloc=xloc.bar_index,
              yloc=yloc.price,
              style=label.style_none,
              textcolor=#089981,
              size=size.small))

    array.push(
         labels,
         label.new(
              bar_index - 60,
              axisRange - 0.5,
              "Q2: Bearish Reversion\nVel - / Stretch +",
              xloc=xloc.bar_index,
              yloc=yloc.price,
              style=label.style_none,
              textcolor=#ff9800,
              size=size.small))

    array.push(
         labels,
         label.new(
              bar_index - 60,
              -axisRange + 0.5,
              "Q3: Bearish Expansion\nVel - / Stretch -",
              xloc=xloc.bar_index,
              yloc=yloc.price,
              style=label.style_none,
              textcolor=#f23645,
              size=size.small))

    array.push(
         labels,
         label.new(
              bar_index - 20,
              -axisRange + 0.5,
              "Q4: Bullish Reversion\nVel + / Stretch -",
              xloc=xloc.bar_index,
              yloc=yloc.price,
              style=label.style_none,
              textcolor=#5b9cf6,
              size=size.small))

// Draw the selected statistics ticker projection after the static quadrant
// is rebuilt and before the normal asset trails are added.
f_drawProjection()

// ============================================================================
// EXECUTE
// ============================================================================
f_drawOne(sym01, x01, y01, v01, #1f77b4, en01)
f_drawOne(sym02, x02, y02, v02, #ff7f0e, en02)
f_drawOne(sym03, x03, y03, v03, #2ca02c, en03)
f_drawOne(sym04, x04, y04, v04, #d62728, en04)
f_drawOne(sym05, x05, y05, v05, #9467bd, en05)
f_drawOne(sym06, x06, y06, v06, #8c564b, en06)
f_drawOne(sym07, x07, y07, v07, #e377c2, en07)
f_drawOne(sym08, x08, y08, v08, #7f7f7f, en08)
f_drawOne(sym09, x09, y09, v09, #bcbd22, en09)
f_drawOne(sym10, x10, y10, v10, #17becf, en10)
f_drawOne(sym11, x11, y11, v11, #393b79, en11)

//plot(x01, "Stock 1 Velocity", display=display.none)
//plot(y01, "Stock 1 Stretch", display=display.none)
//plot(v01, "Stock 1 TR Variability", display=display.none)
//plot(projectionConfidence, "Projection Confidence", display=display.none)
//plot(projectionVelocityDamping, "Adaptive Velocity Persistence", display=display.none)
//plot(projectionAccelerationDamping, "Adaptive Acceleration Persistence", display=display.none)
//plot(statsPressure, "Buy/Sell Pressure Balance", display=display.none)
//plot(pressureBetaX, "Pressure Beta X", display=display.none)
//plot(pressureBetaY, "Pressure Beta Y", display=display.none)
//plot(projectionPressureForceX, "Pressure Force X", display=display.none)
//plot(projectionPressureForceY, "Pressure Force Y", display=display.none)
//plot(pressureBetaXShort, "Pressure Beta X 13", display=display.none)
//plot(pressureBetaXMedium, "Pressure Beta X 21", display=display.none)
//plot(pressureBetaXLong, "Pressure Beta X 34", display=display.none)
//plot(pressureBetaYShort, "Pressure Beta Y 13", display=display.none)
//plot(pressureBetaYMedium, "Pressure Beta Y 21", display=display.none)
//plot(pressureBetaYLong, "Pressure Beta Y 34", display=display.none)
//plot(componentDvShort, "Component Dv 13", display=display.none)
//plot(componentDvMedium, "Component Dv 21", display=display.none)
//plot(componentDvLong, "Component Dv 34", display=display.none)
//plot(componentDaShort, "Component Da 13", display=display.none)
//plot(componentDaMedium, "Component Da 21", display=display.none)
//plot(componentDaLong, "Component Da 34", display=display.none)
//plot(projectionResidualRms, "Projection Residual RMS", display=display.none)
//plot(projectionConfidenceWidthFactor, "Confidence Width Factor", display=display.none)

//plot(projectionVelocityPersistenceRaw, "Raw Velocity Persistence Dv", display=display.none)
//plot(projectionVelocityQ10, "Velocity Persistence Dv Q10", display=display.none)
//plot(projectionVelocityQ90, "Velocity Persistence Dv Q90", display=display.none)
//plot(projectionAccelPersistenceRaw, "Raw Acceleration Persistence Da", display=display.none)
//plot(projectionAccelQ10, "Acceleration Persistence Da Q10", display=display.none)
//plot(projectionAccelQ90, "Acceleration Persistence Da Q90", display=display.none)
//plot(projectionPressurePersistenceRaw, "Raw Pressure Persistence Dp", display=display.none)
//plot(projectionPressureQ10, "Pressure Persistence Dp Q10", display=display.none)
//plot(projectionPressureQ90, "Pressure Persistence Dp Q90", display=display.none)
//plot(projectionVelocityC, "Velocity Persistence Score Cv", display=display.none)
//plot(projectionAccelC, "Acceleration Persistence Score Ca", display=display.none)
//plot(projectionPressureC, "Pressure Persistence Score Cp", display=display.none)
//plot(projectionVelocityRank, "Velocity Persistence Rank Rv", display=display.none)
//plot(projectionAccelRank, "Acceleration Persistence Rank Ra", display=display.none)
//plot(projectionPressureRank, "Pressure Persistence Rank Rp", display=display.none)
//plot(projectionPressureAlignmentConfidence, "Pressure Force Alignment Confidence", display=display.none)
//plot(projectionTrSensitivityDynamic, "Dynamic TR Sensitivity", display=display.none)
//plot(projectionAccelSensitivityDynamic, "Dynamic Acceleration Sensitivity", display=display.none)
//plot(projectionBoundaryScaleDynamic, "Dynamic Boundary Scale", display=display.none)
//plot(projectionWTrDynamic, "Dynamic Weight TR", display=display.none)
//plot(projectionWDirectionDynamic, "Dynamic Weight Direction", display=display.none)
//plot(projectionWAccelDynamic, "Dynamic Weight Acceleration", display=display.none)
//plot(projectionWSurvivalDynamic, "Dynamic Weight Survival", display=display.none)
//plot(projectionWBoundaryDynamic, "Dynamic Weight Boundary", display=display.none)
````
