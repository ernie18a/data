# Jurik Relative Strength Quality Index (RSX)

- url: https://www.tradingview.com/script/G1AUM2g1-Jurik-Relative-Strength-Quality-Index-RSX/
- type: indicator
- pine_id: PUB;309c6a30a9444fba93f105286cc61fe1
- version: 1.0

## Description

RSX is a bounded 0-100 momentum oscillator measuring the direction and quality of price movement. It keeps the RSI identity (net momentum over total momentum) but replaces Wilder's single-pole smoothing with three cascaded lag-compensated filter stages. The result is far smoother than RSI and turns about one bar behind it at equal length, instead of the several bars a comparably smoothed RSI would need.

HISTORICAL CONTEXT

Jurik Research sold RSX in the 1990s as an encrypted TradeStation add-in, marketed as a "noise-free" RSI. The algorithm was never published. The original user guide uses a default length of 8, typical range 5-30, and allows fractional lengths.

This script implements the community reconstruction that surfaced on MQL4 forums around 2005, later ported to ProRealCode, AmiBroker, and pandas-ta. No numeric parity data against Jurik's DLL exists. Indirect evidence: digitizing the RSX(10) vs RSI(10) chart in Jurik's user guide gives a 1.1-bar turn offset, 0.91 correlation, and 1.40 swing ratio; the reconstruction on random-walk data gives 0.96 bars, 0.91, and 1.36. Consistent, not proof.

HOW IT WORKS

Stage 1: Momentum
M[t] = 100 × (x[t] − x[t−1]),  A[t] = |M[t]|

Stage 2: Generalized-DEMA stage
α = 3 / (N + 2),  β = 1 − α
E1[t] = β × E1[t−1] + α × u[t]
E2[t] = α × E1[t] + β × E2[t−1]
GD[t] = 1.5 × E1[t] − 0.5 × E2[t]

This is Tillson's generalized DEMA with volume factor 0.5.

Stage 3: Cascade and ratio
H(u) = GD(GD(GD(u)))
RSX = clamp(50 × (1 + H(M) / H(A)), 0, 100), or 50 if H(A) ≤ 1e−10

Why it is still an RSI: Wilder's RSI equals 50 × (1 + RMA(M) / RMA(|M|)). RSX keeps the identity and swaps RMA for the cascade.

Why the clamp: the lag-compensated stages overshoot, so the ratio can briefly leave [−1, 1]. RSX may sit flat at 0 or 100 in strong one-way moves.

Lag profile (N = 14)
- Slow trends: ≈ 6.5 bars delay vs 13 for RSI.
- Fast swings: RSX trails RSI (12-bar cycle: 4.8 vs 2.2 bars; 20-bar: 6.5 vs 3.8). Crossover near a 45-bar cycle.
- Noise: ~21 dB more high-frequency attenuation than RSI(14).

INPUTS & PARAMETERS

- Source: Default close. hlc3 gives the least input lag. Any series works; RSX ignores scale.
- Period: Default 14 (Jurik's original default was 8).

Period selection
- 5-10: Responsive, short swings.
- 10-20: Balanced, daily bars.
- 20-40: Trend state only.

RSX length is not interchangeable with RSI length. To replace RSI(14), start near RSX(10).

HOW TO USE

- Centerline: above 50 = net upward momentum. Crossings whipsaw far less than RSI.
- Slope with zones: go long when RSX is rising above a lower zone, short when falling below an upper zone, hold while in an extreme zone (Jurik's demo system). Optimize zone levels; don't assume 70/30.
- Extremes: readings near 0 or 100 mean one-directional movement, a statement of trend quality, not automatically overbought or oversold.
- Divergences: cleaner than RSI because jitter is removed; still needs confirmation.
- Composition: RSX of pre-smoothed price pushes output toward a two-state trend switch.

REFERENCES

- Jurik Research. RSX User's Guide (TradeStation add-in), 2000.
- Tillson, T. (1998). "Smoothing Techniques for More Accurate Signals." TASC, January 1998.
- Wilder, J. W. (1978). New Concepts in Technical Trading Systems.

## Source Code

````pine
// Licensed under the Apache License, Version 2.0
// © mihakralj
//@version=6
indicator("Jurik Relative Strength Quality Index (RSX)", "RSX", overlay=false)

//@function Applies three generalized-DEMA stages to momentum and absolute momentum
//@param src Source series
//@param len Filter length
//@returns Clone-style RSX using available filter state during warmup
rsx(series float src, simple int len) =>
    if len <= 0
        runtime.error("Length must be greater than 0")

    simple float alpha = 3.0 / (len + 2.0)
    simple float decay = 1.0 - alpha
    simple int warmup = math.max(len - 1, 5)

    var float previousScaledPrice = 0.0
    var float momentumStage1Fast = 0.0
    var float momentumStage1Slow = 0.0
    var float momentumStage2Fast = 0.0
    var float momentumStage2Slow = 0.0
    var float momentumStage3Fast = 0.0
    var float momentumStage3Slow = 0.0
    var float magnitudeStage1Fast = 0.0
    var float magnitudeStage1Slow = 0.0
    var float magnitudeStage2Fast = 0.0
    var float magnitudeStage2Slow = 0.0
    var float magnitudeStage3Fast = 0.0
    var float magnitudeStage3Slow = 0.0
    var int warmupCounter = 0
    var bool priceChangedDuringWarmup = false
    var float lastValid = na

    float price = na(src) ? lastValid : src
    float result = na
    if not na(price)
        if not na(src)
            lastValid := src
        float smoothedMomentum = 0.0
        float smoothedMomentumMagnitude = 0.0

        if warmupCounter == 0
            warmupCounter := 1
            priceChangedDuringWarmup := false
            previousScaledPrice := 100.0 * price
        else
            warmupCounter := warmupCounter >= warmup ? warmup + 1 : warmupCounter + 1
            float priorScaledPrice = previousScaledPrice
            previousScaledPrice := 100.0 * price
            float scaledMomentum = previousScaledPrice - priorScaledPrice

            momentumStage1Fast := decay * momentumStage1Fast + alpha * scaledMomentum
            momentumStage1Slow := alpha * momentumStage1Fast + decay * momentumStage1Slow
            float momentumStage1Output = 1.5 * momentumStage1Fast - 0.5 * momentumStage1Slow
            momentumStage2Fast := decay * momentumStage2Fast + alpha * momentumStage1Output
            momentumStage2Slow := alpha * momentumStage2Fast + decay * momentumStage2Slow
            float momentumStage2Output = 1.5 * momentumStage2Fast - 0.5 * momentumStage2Slow
            momentumStage3Fast := decay * momentumStage3Fast + alpha * momentumStage2Output
            momentumStage3Slow := alpha * momentumStage3Fast + decay * momentumStage3Slow
            smoothedMomentum := 1.5 * momentumStage3Fast - 0.5 * momentumStage3Slow

            magnitudeStage1Fast := decay * magnitudeStage1Fast + alpha * math.abs(scaledMomentum)
            magnitudeStage1Slow := alpha * magnitudeStage1Fast + decay * magnitudeStage1Slow
            float magnitudeStage1Output = 1.5 * magnitudeStage1Fast - 0.5 * magnitudeStage1Slow
            magnitudeStage2Fast := decay * magnitudeStage2Fast + alpha * magnitudeStage1Output
            magnitudeStage2Slow := alpha * magnitudeStage2Fast + decay * magnitudeStage2Slow
            float magnitudeStage2Output = 1.5 * magnitudeStage2Fast - 0.5 * magnitudeStage2Slow
            magnitudeStage3Fast := decay * magnitudeStage3Fast + alpha * magnitudeStage2Output
            magnitudeStage3Slow := alpha * magnitudeStage3Fast + decay * magnitudeStage3Slow
            smoothedMomentumMagnitude := 1.5 * magnitudeStage3Fast - 0.5 * magnitudeStage3Slow

            if warmupCounter <= warmup and previousScaledPrice != priorScaledPrice
                priceChangedDuringWarmup := true
            if warmupCounter == warmup and not priceChangedDuringWarmup
                warmupCounter := 0

        if smoothedMomentumMagnitude > 1e-10
            result := math.min(math.max((smoothedMomentum / smoothedMomentumMagnitude + 1.0) * 50.0, 0.0), 100.0)
        else
            result := 50.0
    result

// ---------- Main loop ----------

i_length = input.int(14, "Length", minval=1)
i_source = input.source(close, "Source")

rsx_value = rsx(i_source, i_length)
plot(rsx_value, "RSX", color=color.yellow, linewidth=2)
````
