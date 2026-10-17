# Adaptive Harmonic Ribbons

- url: https://www.tradingview.com/script/q9GXorGx-Adaptive-Harmonic-Ribbons/
- type: indicator
- pine_id: PUB;c6c27d28fe0c4d89a82ece63bd6163f6
- version: 1.0

## Description

# Adaptive Harmonic Ribbons (AHR)

Adaptive Harmonic Ribbons (AHR) is a trend and market structure indicator that replaces fixed moving-average lengths with an adaptive framework driven by the market's estimated dominant cycle.

Traditional moving-average ribbons, including GMMA-style approaches, use predefined periods such as 5, 10, 20 or 60 bars. While effective under stable conditions, these lengths represent a fixed assumption about market behaviour and must often be re-optimized when volatility or market rhythm changes.

AHR takes a different approach. Instead of using fixed lookback periods, it estimates the current dominant market cycle using a Hilbert Transform-based approach. Every moving average in the ribbon is then derived from that cycle, allowing the entire ribbon to expand and contract automatically as market conditions evolve.

Rather than changing only a single adaptive moving average, AHR adapts the entire ribbon while preserving proportional spacing through harmonic scaling. This allows the relationship between the ribbon layers to remain consistent across changing market regimes.

---

## Methodology

The indicator consists of four main components:

### 1. Dominant Cycle Estimation

The market's dominant cycle is estimated continuously using a Hilbert Transform implementation inspired by John F. Ehlers' work on digital signal processing. The measured cycle is constrained within user-defined minimum and maximum bounds to improve stability.

This dominant cycle becomes the reference period from which every ribbon length is calculated.

### 2. Harmonic Length Generation

Instead of manually specifying twelve moving-average periods, AHR generates them automatically.

Fast ribbon lengths are created by dividing the dominant cycle using a harmonic expansion factor.

Slow ribbon lengths are created by multiplying the dominant cycle by the same factor.

Because every ribbon layer is derived from the same adaptive reference, the spacing between layers remains proportional even as market conditions change.

The expansion multiplier can be adjusted to produce tighter or wider ribbon structures using relationships such as:

* Third-Octave (1.26)
* Half-Octave (1.414)
* Golden Ratio (1.618)
* Full Octave (2.0)

### 3. Adaptive Smoothing

Each ribbon layer can be calculated using one of several smoothing engines:

* SuperSmoother Filter (SSF)
* Three-Pole SuperSmoother (SSF3)
* EMA
* Double EMA (EMA2)

The adaptive framework remains unchanged regardless of the smoothing method selected.

### 4. Dynamic Ribbon Construction

The resulting fast and slow ribbon groups continuously adjust their lengths as the estimated dominant cycle changes.

Instead of requiring manual optimization for different symbols or timeframes, the ribbon geometry adapts automatically while maintaining its overall structure.

---

## Interpreting the Indicator

AHR is intended as a trend analysis and market structure tool rather than a signal generator.

Some common observations include:

Trend Agreement

When both ribbon groups slope in the same direction and maintain consistent separation, the market may be exhibiting directional strength.

Compression

When ribbon layers contract toward one another, the market may be entering a lower-volatility consolidation phase.

Expansion

When the ribbons begin separating after a period of compression, this may indicate increasing directional momentum.

Pullbacks

During established trends, price retracements into the fast ribbon or the space between ribbon groups can help traders evaluate whether trend structure remains intact.

As with any moving-average-based indicator, AHR should be used alongside broader market context and appropriate risk management.

---

## Inputs

Source
Price series used for all calculations.

Minimum / Maximum Dominant Cycle
Defines the allowable range for the adaptive cycle estimator.

Moving Average Type
Selects the smoothing algorithm used to construct the ribbon.

Expansion Multiplier
Controls the proportional spacing between ribbon layers.

Maximum Transparency
Adjusts the visual fading effect within each ribbon.

---

## Acknowledgements

This indicator draws inspiration from two well-established areas of technical analysis:

* John F. Ehlers' research into dominant cycle estimation, Hilbert Transform techniques and SuperSmoother filtering.
* Daryl Guppy's concept of separating market participants into fast and slow moving-average groups.

The adaptive ribbon construction, harmonic length generation, dominant-cycle-derived scaling, and dynamic ribbon framework are original components developed specifically for this implementation.

## Source Code

````pine
//@version=6
// Copyright (c) 2026 Gurjit Singh
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
indicator("Adaptive Harmonic Ribbons", "AHR", overlay = true, timeframe = "", timeframe_gaps = true)

// Functions
//--------------------------------------------------

// --- Hilbert FIR transform helper
f_hilbert(series float src, series float bw) =>
    (0.0962 * nz(src) +
        0.5769 * nz(src[2]) -
        0.5769 * nz(src[4]) -
        0.0962 * nz(src[6])) * bw

ht_dcperiod(series float source) =>
    // --- Persistent state (IIR variables only) ---
    var float inPhase2     = 0.0
    var float quad2        = 0.0
    var float realPart     = 0.0
    var float imagPart     = 0.0
    var float period       = 0.0
    var float smoothPeriod = 0.0

    // --- Price smoothing (WMA-4) ---
    float price = nz(source)
    float smoothed = (4.0 * price +
                        3.0 * nz(price[1]) +
                        2.0 * nz(price[2]) +
                        nz(price[3])) / 10.0

    // --- Adaptive bandwidth ---
    float bw = 0.075 * period + 0.54

    // --- Hilbert transforms ---
    float detrender = f_hilbert(smoothed, bw)
    float quad1     = f_hilbert(detrender, bw)
    float inPhase1  = nz(detrender[3])

    // --- Advance phase ---
    float jitterI = f_hilbert(inPhase1, bw)
    float jitterQ = f_hilbert(quad1, bw)

    // --- Smoothed Phasor Recombination ---
    inPhase2 := 0.2 * (inPhase1 - jitterQ) + 0.8 * nz(inPhase2[1])
    quad2    := 0.2 * (quad1 + jitterI)    + 0.8 * nz(quad2[1])

    // --- Homodyne discriminator ---
    float ip2Prev = nz(inPhase2[1])
    float q2Prev  = nz(quad2[1])

    realPart := 0.2 * (inPhase2 * ip2Prev + quad2 * q2Prev) + 0.8 * nz(realPart[1])
    imagPart := 0.2 * (inPhase2 * q2Prev  - quad2 * ip2Prev) + 0.8 * nz(imagPart[1])

    // --- Dominant Cycle Period Computation ---
    float prevPeriod = period

    if math.abs(imagPart) > 1e-12 and math.abs(realPart) > 1e-12
        float angle = math.atan(imagPart / realPart)
        if math.abs(angle) > 1e-12
            period := 2.0 * math.pi / angle

    // --- Rate limiting & Clamping ---
    if prevPeriod > 0
        period := math.min(math.max(period, 0.67 * prevPeriod), 1.5 * prevPeriod)

    period := math.min(math.max(period, 6.0), 50.0)

    // --- Output smoothing ---
    period := 0.2 * period + 0.8 * prevPeriod
    smoothPeriod := 0.33 * period + 0.67 * nz(smoothPeriod[1])
    smoothPeriod

superSmoother(src, length) =>
    omega = math.pi * math.sqrt(2.0) / length
    alpha = math.exp(-omega)
    coef2 = 2.0 * alpha * math.cos(omega)
    coef3 = -math.pow(alpha, 2)
    coef1 = 1.0 - coef2 - coef3
    filt  = src
    if bar_index > 2
        mid = (src + src[1]) / 2
        filt := (coef1 * mid) +
          		(coef2 * nz(filt[1])) +
          		(coef3 * nz(filt[2]))
    filt

superSmoother3(src, length) =>
    // length := math.max(1, length)
    omega = math.pi * math.sqrt(3.0) / length
    alpha = math.exp(-math.pi / length)
    beta = 2.0 * alpha * math.cos(omega)
    gamma = math.pow(alpha, 2)
    coef2 = beta + gamma
    coef3 = -(gamma + (beta * gamma))
    coef4 = math.pow(gamma, 2)
    coef1 = 1.0 - coef2 - coef3 - coef4
    filt = src
    if bar_index > 3
        filt := (coef1 * nz(src, src[1])) +
             (coef2 * nz(filt[1])) +
             (coef3 * nz(filt[2])) +
             (coef4 * nz(filt[3]))
    filt

clamp(val, lo, hi) =>
    math.max(lo, math.min(hi, val))

ewma(src, alpha) =>
    ma = src
    ma := alpha * src + (1.0 - alpha) * nz(ma[1], src)

ema(src, period) =>
    alpha = 2.0 / (period + 1.0)
    ewma(src, alpha)

ema2(source, period) =>
    float alpha = 2.0 / (period / math.sqrt(2) + 1.0)
    ewma(ewma(source, alpha), alpha)


// Inputs
//--------------------------------------------------
src = input(close, title="Source", inline="src")
minPeriod = input.int(8, "Min Dominant Cycle", minval=5)
maxPeriod = input.int(48, "Max Dominant Cycle", minval=10)

maType = input.string("SSF", "Moving", inline = "src",
     options = ["SSF", "EMA", "SSF3", "EMA2"])

k = input.float(
    1.5, title = "Expansion Multiplier",
    minval = 1.0, step = 0.1, inline = "lens",
    tooltip= "Harmonic spacing ratio for cycle layers:\n" +
	          "• 1.26 = Third-Octave\n" +  "• 1.414 = Half-Octave\n" +
	          "• 1.618 = Golden Ratio\n" + "• 2.0 = Full Octave"
)

// Colors
maxTrans    = input.int(80, title="Maximum Transparency", minval=10, maxval=95)
fastBullish = input.color(color.rgb(255, 193, 7), title="Fast Bullish", inline="CF")
fastBearish = input.color(color.rgb(30, 136, 229), title="Fast Bearish", inline="CF")

slowBullish = input.color(color.rgb(176, 190, 197),  title="Slow Bullish", inline="CS")
slowBearish = input.color(color.rgb(141, 110, 99), title="Slow Bearish", inline="CS")

// ─────────────────────────────
// Dominant Cycle Estimation
// ─────────────────────────────
DC_raw = ht_dcperiod(src)
DC_per = clamp(DC_raw, minPeriod, maxPeriod)

//────────────────────────────────────────────
// Derived Lengths
//────────────────────────────────────────────

// Harmonic-spaced length grid
hl(exp) => math.round(DC_per * math.pow(k, exp))

// Fast group: DC/k → DC
fastLen1 = hl(-1.0)
fastLen2 = hl(-4.0/5.0)
fastLen3 = hl(-3.0/5.0)
fastLen4 = hl(-2.0/5.0)
fastLen5 = hl(-1.0/5.0)
fastLen6 = hl(0.0)

// Slow group: DC×k → DC×k²
slowLen1 = hl(1.0)
slowLen2 = hl(6.0/5.0)
slowLen3 = hl(7.0/5.0)
slowLen4 = hl(8.0/5.0)
slowLen5 = hl(9.0/5.0)
slowLen6 = hl(2.0)

//────────────────────────────────────────────
// MA Engine
//────────────────────────────────────────────
maCalc(src, len, maType) =>
    switch maType
        "SSF" => superSmoother(src, len)
        "EMA" => ema(src, len)
        "EMA2" => ema2(src, len)
        "SSF3" => superSmoother3(src, len)

maFunc(len) => maCalc(src, len, maType)

// Compute all GMMA lines
fast1 = maFunc(fastLen1)
fast2 = maFunc(fastLen2)
fast3 = maFunc(fastLen3)
fast4 = maFunc(fastLen4)
fast5 = maFunc(fastLen5)
fast6 = maFunc(fastLen6)

slow1 = maFunc(slowLen1)
slow2 = maFunc(slowLen2)
slow3 = maFunc(slowLen3)
slow4 = maFunc(slowLen4)
slow5 = maFunc(slowLen5)
slow6 = maFunc(slowLen6)

// Clouds & Trend Colors
trendFast = fast1 > fast6 ? fastBullish : fastBearish
trendSlow = slow1 > slow6 ? slowBullish : slowBearish

fade(i, numSteps, maxTrans) =>
    int(maxTrans * math.pow(i / numSteps, 1.6))

fastStep(i) =>
    color.new(trendFast, fade(i, 6, maxTrans))

slowStep(i) =>
    color.new(trendSlow, fade(i, 6, maxTrans))

// Plot all Fast Lines
plot(fast1, color=fastStep(6), linewidth=1, title="Fast 1")
plot(fast2, color=fastStep(5), linewidth=1, title="Fast 2")
plot(fast3, color=fastStep(4), linewidth=1, title="Fast 3")
plot(fast4, color=fastStep(3), linewidth=1, title="Fast 4")
plot(fast5, color=fastStep(2), linewidth=1, title="Fast 5")
plot(fast6, color=fastStep(1), linewidth=2, title="Fast 6")

// Plot all Slow Lines
plot(slow1, color=slowStep(6), linewidth=1, title="Slow 1")
plot(slow2, color=slowStep(5), linewidth=1, title="Slow 2")
plot(slow3, color=slowStep(4), linewidth=1, title="Slow 3")
plot(slow4, color=slowStep(3), linewidth=1, title="Slow 4")
plot(slow5, color=slowStep(2), linewidth=1, title="Slow 5")
plot(slow6, color=slowStep(1), linewidth=2, title="Slow 6")
````
