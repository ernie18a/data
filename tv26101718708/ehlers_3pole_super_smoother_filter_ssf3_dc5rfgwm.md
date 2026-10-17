# Ehlers 3-Pole Super Smoother Filter (SSF3)

- url: https://www.tradingview.com/script/dC5RFgwm-Ehlers-3-Pole-Super-Smoother-Filter-SSF3/
- type: indicator
- pine_id: PUB;cc34da48ac5240cd8d8d0f7742e969a4
- version: 1.0

## Description

The 3-Pole Super Smoother (SSF3) is John Ehlers' third-order IIR low-pass filter. It removes cycles shorter than the cutoff period at 18 dB per octave, half again as steep as the 2-pole Super Smoother, while feeding in only the current bar. The result is a very smooth trend line with one parameter, unity gain on trends, and less lag than the Butterworth filter that shares its poles.

HISTORICAL CONTEXT

Ehlers developed the Super Smoother family in Rocket Science for Traders (2001) and Cybernetic Analysis for Stocks and Futures (2004) as a replacement for moving averages. A moving average is a crude filter: its rejection of noise is weak and uneven, with sidelobes that let some short cycles through. Ehlers borrowed pole placement from analog Butterworth design to get a clean cutoff instead.

The 3-pole Butterworth in that work averages four input samples with binomial weights (1, 3, 3, 1). SSF3 keeps the same three poles but feeds in only the current sample. That trades a little passband flatness for faster response.

HOW IT WORKS

Stage 1: Pole placement from the period P
a₁ = exp(−π / P)
b₁ = 2 × a₁ × cos(√3 × π / P)
c₁ = a₁²

Stage 2: Recurrence coefficients (computed once)
coef2 = b₁ + c₁
coef3 = −(c₁ + b₁ × c₁)
coef4 = c₁²
coef1 = 1 − coef2 − coef3 − coef4

coef1 is chosen so the coefficients sum to 1, which gives unity gain on a flat or trending input.

Stage 3: Recurrence (each bar)
y[t] = coef1 × x[t] + coef2 × y[t−1] + coef3 × y[t−2] + coef4 × y[t−3]

Three feedback taps, one input tap. Three values of state.

Frequency response (measured from the recurrence)
- −3 dB point at almost exactly period P.
- About −18 dB at P/2, falling 18 dB per octave beyond that.
- Flat passband: no ripple above period P.
- Delay on slow trends: 1.8 bars at P = 10, 4.9 at P = 20, 11.3 at P = 40.
- Step response overshoots by about 8% and settles within 1% after roughly 1.5 × P bars.

For comparison, an EMA with the same trend delay as SSF3(20) is roughly EMA(11), and it attenuates a 10-bar cycle by only about 11 dB against SSF3's 18 dB. The gap widens at shorter cycles.

INPUTS & PARAMETERS

- Source: Input series. Default: close.
- Period: Cutoff period in bars. Cycles shorter than this are suppressed. Default: 20.

Period selection
- 8-15: Light smoothing, follows swings closely.
- 20-40: Balanced trend line for daily bars.
- 60+: Major trend only, with proportionally more delay.

HOW TO USE

Trend line
- Price above SSF3 and SSF3 rising: uptrend. Below and falling: downtrend.
- Slope turns are cleaner than on a moving average of similar delay, because short cycles are removed rather than just damped.

Crossovers
- Two SSF3 lines at different periods (for example 10 and 40) give fast/slow crossovers with fewer whipsaws than EMA pairs.

Preprocessing
- SSF3 makes a good input filter for oscillators and cycle tools. Smooth first, then measure. Use a period at or below the shortest cycle you care about, or you will filter out the signal you want to measure.

SSF3 vs SSF2
- SSF2: less smoothing, less delay.
- SSF3: steeper cutoff, more delay, slight overshoot.

LIMITATIONS

- Overshoot: about 8% on a sudden price jump. After a gap, SSF3 briefly overshoots the new level before settling.
- Delay grows with period: 3 poles means more delay than 2. Do not expect a lag-free line.
- Small periods: below about 4 the filter barely smooths and the coefficients become sensitive. Use 6 or more.
- Warmup: the first bars pass the input through while the three feedback values fill. Allow several periods before trusting values, especially on short histories.
- Not interchangeable with SSF2 or Butterworth: same family, different outputs. Retest any system when switching.

REFERENCES

- Ehlers, J. F. (2001). Rocket Science for Traders. Wiley.
- Ehlers, J. F. (2004). Cybernetic Analysis for Stocks and Futures. Wiley.

## Source Code

````pine
// Licensed under the Apache License, Version 2.0
// © mihakralj
//@version=6
// Indicator algorithm (C) 2004-2024 John F. Ehlers
indicator("Ehlers 3-Pole Super Smoother Filter (SSF3)", "SSF3", overlay=true)

//@function Calculates 3-Pole Super Smoother Filter
//@param source Series to calculate SSF3 from
//@param length Number of bars used in the calculation
//@returns SSF3 value with optimized 3-pole smoothing
//@optimized Uses 3-pole IIR filter with O(1) complexity per bar
ssf3(series float src, simple int length) =>
    var float SQRT3_PI = math.sqrt(3.0) * math.pi
    var float ssf3_internal = 0.0
    var float coef1 = 0.0
    var float coef2 = 0.0
    var float coef3 = 0.0
    var float coef4 = 0.0
    var int prev_length = 0
    if prev_length != length
        int p = math.max(1, length)
        float a1 = math.exp(-math.pi / p)
        float b1 = 2.0 * a1 * math.cos(SQRT3_PI / p)
        float c1 = a1 * a1
        coef2 := b1 + c1
        coef3 := -(c1 + b1 * c1)
        coef4 := c1 * c1
        coef1 := 1.0 - coef2 - coef3 - coef4
        prev_length := p
    float ssrc = nz(src, src[1])
    float src1 = nz(src[1], ssrc)
    float src2 = nz(src[2], src1)
    float src3 = nz(src[3], src2)
    float filt1 = nz(ssf3_internal[1], src1)
    float filt2 = nz(ssf3_internal[2], src2)
    float filt3 = nz(ssf3_internal[3], src3)
    ssf3_internal := coef1 * ssrc + coef2 * filt1 + coef3 * filt2 + coef4 * filt3
    ssf3_internal

// ---------- Main loop ----------

// Inputs
i_length = input.int(20, "Length", minval=1)
i_source = input.source(close, "Source")

// Calculation
ssf3_val = ssf3(i_source, i_length)

// Plot
plot(ssf3_val, "SSF3", color=color.yellow, linewidth=2)
````
