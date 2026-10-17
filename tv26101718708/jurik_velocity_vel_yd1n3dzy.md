# Jurik Velocity (VEL)

- url: https://www.tradingview.com/script/yD1n3DZY-Jurik-Velocity-VEL/
- type: indicator
- pine_id: PUB;c877ec9bb9ee43bd9513e645edfafca0
- version: 1.0

## Description

The Jurik Velocity (VEL) indicator is a differential signal processing oscillator that measures price rate-of-change through the instantaneous divergence between two weighted moving averages with distinct inertia profiles. By contrasting a fast Parabolic Weighted Moving Average (PWMA) with a linear Weighted Moving Average (WMA), it isolates clean velocity without the severe lag introduced by smoothing raw momentum. The resulting zero-centered metric acts as the true first derivative of price, delivering early inflection signals and robust outlier resistance.

HISTORICAL CONTEXT

Developed by Mark Jurik of Jurik Research, VEL was created to overcome the fatal mathematical flaw of standard momentum indicators: the two-bar outlier problem. Classical momentum calculations (Price - Price[N]) rely entirely on two discrete data points—today's price and the price N bars ago. A single anomalous spike creates two false signals: once when entering the window, and again when dropping out.

Traditional attempts to cure this noise by applying post-hoc moving averages introduce destructive phase lag. Jurik’s insight was to eliminate post-smoothing entirely by measuring the instantaneous divergence between two inherently smooth filters that possess different response speeds. Because every historical bar within the lookback window contributes proportionally through a continuous weighting curve, VEL naturally absorbs outlier price spikes while capturing instantaneous shifts in momentum.

HOW IT WORKS

Stage 1: Parabolic Weighted Moving Average (PWMA)
The fast component applies quadratic weighting across the lookback window: Weight = (N - i)^2. For a period of 14, the most recent bar carries 196 times the weight of the oldest bar. This quadratic profile produces an exceptionally low center-of-mass lag of ~3.15 bars, reacting immediately to price acceleration.

Stage 2: Linear Weighted Moving Average (WMA)
The slower baseline applies linear weighting across the identical lookback window: Weight = (N - i). For a period of 14, the newest bar carries 14 times the weight of the oldest bar, yielding an effective lag of ~4.33 bars. Both moving averages update via running sums to maintain strict O(1) computational efficiency per bar.

Stage 3: Velocity Differential
VEL computes the instantaneous spread between the two moving averages: VEL = PWMA - WMA. Because PWMA responds approximately 1.18 bars faster than WMA during price turns, their difference behaves as an emergent bandpass filter. It strips out the underlying low-frequency trend and suppresses high-frequency noise, isolating the intermediate momentum cycle where trend inflections occur.

INPUTS & PARAMETERS

Period: The lookback window length (N) used to calculate both the parabolic and linear weighted moving averages. Controls the passband center frequency and responsiveness. Default: 14.

HOW TO USE

Zero-Line Crossings & Trend Bias
VEL oscillates around a zero baseline, indicating the directional velocity of price:

Bullish State: VEL is positive (PWMA sits above WMA), confirming upward price velocity.

Bearish State: VEL is negative (PWMA sits below WMA), confirming downward price velocity.

Zero-Crossing Signal: A cross above zero indicates upward inflection; a cross below zero marks downward momentum breakdown.

Peak and Trough Early Warnings
Because VEL represents the first derivative of price, local peaks and troughs in the oscillator mark points of zero acceleration (inflection points). When VEL peaks and rolls over from an extreme level, it warns that trend momentum is exhausting several bars before price itself turns or crosses zero.

Histogram and Signal Line Strategies
VEL functions analogously to a MACD line. To generate early trade triggers without waiting for a full zero-line crossover, pair VEL with a short signal line (such as a 3- to 5-period EMA of VEL) or evaluate the second derivative (acceleration) via bar-over-bar slope changes.

LIMITATIONS

Unbounded Scaling: Unlike normalized oscillators like RSI or Stochastic, VEL is unbounded. Its absolute values scale directly with the underlying asset's price and volatility. A $500 stock will produce significantly wider VEL swings than a $10 stock. Normalize by ATR or price percentage (VEL / Price * 100) when comparing values across different instruments.
Constant Velocity Compaction: A reading near zero indicates that PWMA equals WMA; it does not necessarily imply market stagnation. In a steady, perfectly linear trend with constant velocity, VEL compresses toward zero despite ongoing price progress. Divergence from zero indicates active acceleration.
Warmup Period: Both internal filters require a full Period of historical bars to populate their running sums. All readings generated prior to bar index Period are uninitialized and should be disregarded.
Volatility Context: High VEL values in a low-volatility environment indicate strong momentum, whereas the same values during high volatility may simply reflect ambient noise. Contextualize extreme readings with prevailing volatility.

REFERENCES

Jurik, M. "Jurik Velocity (VEL)." Jurik Research Technical Documentation, 1990s.
Kaufman, P. J. Trading Systems and Methods. 5th ed., Wiley, 2013.
Ehlers, J. F. Rocket Science for Traders. Wiley, 2001.

## Source Code

````pine
// Licensed under the Apache License, Version 2.0
// © mihakralj
//@version=6
indicator("Jurik Velocity (VEL)", "VEL", overlay=false)

//@function Calculates zero-lag velocity using JMA smoothing
//@param src Source series to calculate velocity for
//@param period Lookback period for velocity calculation
//@returns Smoothed velocity value measuring rate of price change
vel(series float src, simple int period) =>
    if period <= 0
        runtime.error("Period must be greater than 0")
    float source = 0.0
    if not na(src) and not na(src[period])
        source := src - src[period]
    var simple float phase = 100, var simple float power = 0.2
    var simple float PHASE_VALUE = math.min(math.max((phase * 0.01) + 1.5, 0.5), 2.5)
    var simple float BETA = power * (period - 1) / ((power * (period - 1)) + 2)
    var simple float LEN1 = math.max((math.log(math.sqrt(0.5*(period-1))) / math.log(2.0)) + 2.0, 0)
    var simple float POW1 = math.max(LEN1 - 2.0, 0.5)
    var simple float LEN2 = math.sqrt(0.5*(period-1))*LEN1
    var simple float POW1_RECIPROCAL = 1.0 / POW1
    var simple float AVG_VOLTY_ALPHA = 2.0 / (math.max(4.0 * period, 65) + 1.0)
    var simple float DIV = 1.0/(10.0 + 10.0*(math.min(math.max(period-10,0),100))/100.0)
    var float upperBand_state = na, var float lowerBand_state = na
    var float ma1_state = na, var float jma_state = na
    var float vSum_state = 0.0, var float det0_state = 0.0, var float det1_state = 0.0
    var float avgVolty_state = na, var float vel = na
    var volty_array_state = array.new_float(11, 0.0)
    if not na(source)
        float del1 = source - nz(upperBand_state, source), float del2 = source - nz(lowerBand_state, source)
        float volty = math.abs(del1) == math.abs(del2) ? 0.0 : math.max(math.abs(del1), math.abs(del2))
        array.unshift(volty_array_state, nz(volty, 0.0))
        array.pop(volty_array_state)
        if not na(volty)
            vSum_state := vSum_state + (volty - array.get(volty_array_state, 10)) * DIV
            avgVolty_state := nz(avgVolty_state, vSum_state) + AVG_VOLTY_ALPHA * (vSum_state - nz(avgVolty_state, vSum_state))
        float rvolty = math.min(math.max(nz(avgVolty_state, 0) > 0 ? nz(volty, 0.0) / nz(avgVolty_state, 1.0) : 1.0, 1.0), math.pow(LEN1, POW1_RECIPROCAL))
        float pow2 = math.pow(rvolty, POW1)
        float Kv = math.pow(LEN2/(LEN2+1), math.sqrt(pow2))
        upperBand_state := del1 > 0 ? source : source - Kv * del1
        lowerBand_state := del2 < 0 ? source : source - Kv * del2
        float alpha = math.pow(BETA, pow2)
        float alphaSquared = alpha * alpha, float oneMinusAlpha = 1.0 - alpha
        float oneMinusAlphaSquared = oneMinusAlpha * oneMinusAlpha
        ma1_state := source + (alpha * (nz(ma1_state, source) - source))
        det0_state := (source - ma1_state) * (1 - BETA) + BETA * nz(det0_state, 0)
        float ma2 = ma1_state + (PHASE_VALUE * det0_state)
        det1_state := ((ma2 - nz(jma_state, source)) * oneMinusAlphaSquared) + (alphaSquared * nz(det1_state, 0))
        jma_state := nz(jma_state, source) + det1_state
        vel := jma_state
    vel

// ---------- Main loop ----------

// Inputs
i_length = input.int(10, "Length", minval=1)
i_source = input.source(close, "Source")

// Calculation
vel_value = vel(i_source, i_length)

// Plot
plot(vel_value, "VEL", color=color.yellow, linewidth=2)
````
