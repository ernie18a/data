# Ehlers 2-Pole Super Smoother Filter (SSF2)

- url: https://www.tradingview.com/script/WkWFsXEv-Ehlers-2-Pole-Super-Smoother-Filter-SSF2/
- type: indicator
- pine_id: PUB;3cdc0df2c2a749eb8dc2cabdf76ebd1f
- version: 1.0

## Description

The 2-Pole Super Smoother (SSF2) is John Ehlers' second-order IIR low-pass filter and the most widely used member of his Super Smoother family. It removes cycles shorter than the cutoff period at 12 dB per octave, completely cancels the 2-bar cycle, and delivers roughly half the delay of an EMA with the same length. One parameter, unity gain on trends, flat passband.

HISTORICAL CONTEXT

Ehlers presented the Super Smoother in Cybernetic Analysis for Stocks and Futures (2004) as a replacement for moving averages. A moving average is a crude filter: its noise rejection is weak and uneven, and it lets some short cycles leak through. Ehlers borrowed pole placement from the analog 2-pole Butterworth design to get a clean, maximally flat cutoff instead.

The version used here, with a 2-bar average on the input, is the form Ehlers used in Cycle Analytics for Traders (2013) and his later articles. That averaging places a zero exactly at the 2-bar cycle, the fastest oscillation possible on bar data, so bar-to-bar zigzag is removed entirely.

HOW IT WORKS

Stage 1: Coefficients from the period P
arg = √2 × π / P
c₂ = 2 × exp(−arg) × cos(arg)
c₃ = −exp(−2 × arg)
c₁ = 1 − c₂ − c₃

c₁ is chosen so the coefficients sum to 1, which gives unity gain on a flat or trending input.

Stage 2: Recurrence (each bar)
y[t] = c₁ × (x[t] + x[t−1]) / 2 + c₂ × y[t−1] + c₃ × y[t−2]

Two feedback taps, a 2-bar input average, and three values of state.

Frequency response (measured from the recurrence)
- −3 dB point at almost exactly period P.
- About −12.5 dB at P/2 and −25 dB at P/4.
- 2-bar cycle: fully cancelled.
- Flat passband: no ripple or gain above period P.
- Delay on slow trends: 1.8 bars at P = 10, 4.0 at P = 20, 8.5 at P = 40.
- Step response overshoots by about 4% and settles within 1% after roughly P bars.

Against the EMA
- EMA(20) has 9.5 bars of delay; SSF2(20) has 4.0.
- An EMA with the same delay as SSF2(20) is roughly EMA(9). SSF2 attenuates a 10-bar cycle 3 dB more and a 5-bar cycle 10 dB more.

SSF2 period and EMA length are not interchangeable: SSF2(N) is much faster than EMA(N).

INPUTS & PARAMETERS

- Source: Input series. Default: close.
- Period: Cutoff period in bars. Cycles shorter than this are suppressed. Default: 20.

Period selection
- 6-15: Light smoothing, follows swings closely.
- 20-40: Balanced trend line for daily bars.
- 60+: Major trend only, with proportionally more delay.

HOW TO USE

Trend line
- Price above SSF2 and SSF2 rising: uptrend. Below and falling: downtrend.
- Slope turns are cleaner than on an EMA of similar delay, because short cycles are removed rather than just damped.

Crossovers
- Two SSF2 lines at different periods (for example 10 and 40) give fast/slow crossovers with fewer whipsaws than EMA pairs.

Preprocessing
- SSF2 is Ehlers' standard input filter for oscillators and cycle tools: smooth first, then measure. Pair it with a high-pass filter to isolate a band of cycles. Use a period at or below the shortest cycle you care about.

SSF2 vs SSF3
- SSF2: less delay, 4% overshoot, 12 dB per octave.
- SSF3: steeper 18 dB per octave cutoff, about 20% more delay, 8% overshoot.

LIMITATIONS

- Overshoot: about 4% on a sudden price jump. After a gap, SSF2 briefly overshoots the new level before settling.
- Rolloff: 12 dB per octave is gentle. Cycles just shorter than P are only partly removed. Use SSF3 when sharper separation matters more than delay.
- Small periods: below about 4 the filter barely smooths. Use 6 or more.
- Warmup: the first bars pass the input through while the feedback values fill. Allow about one period before trusting values.
- Constants: this script uses exact √2 and π. Ports that hard-code 1.414 and 3.14159 produce slightly different values.

REFERENCES

- Ehlers, J. F. (2004). Cybernetic Analysis for Stocks and Futures. Wiley.
- Ehlers, J. F. (2013). Cycle Analytics for Traders. Wiley.

## Source Code

````pine
// Licensed under the Apache License, Version 2.0
// © mihakralj
//@version=6
// Indicator algorithm (C) 2004-2024 John F. Ehlers
indicator("Ehlers 2-Pole Super Smoother Filter (SSF2)", "SSF2", overlay=true)

//@function Calculates 2-pole Supersmooth Lowpass Filter
//@param source Series to calculate SSF2 from
//@param length Number of bars used in the calculation
//@returns SSF2 value with optimized smoothing
//@optimized Uses 2-pole IIR Butterworth-style filter with O(1) complexity per bar
ssf2(series float src, simple int length) =>
    var float SQRT2_PI = math.sqrt(2.0) * math.pi
    var float ssf_internal = 0.0
    var float c1 = 0.0
    var float c2 = 0.0
    var float c3 = 0.0
    var int prev_length = 0
    if prev_length != length
        float arg = SQRT2_PI / float(length)
        float exp_arg = math.exp(-arg)
        c2 := 2.0 * exp_arg * math.cos(arg)
        c3 := -exp_arg * exp_arg
        c1 := 1.0 - c2 - c3
        prev_length := length
    float ssrc = nz(src, src[1])
    float src1 = nz(src[1], ssrc)
    float src2 = nz(src[2], src1)
    ssf_internal := c1 * (ssrc + src1) * 0.5 + c2 * nz(ssf_internal[1], src1) + c3 * nz(ssf_internal[2], src2)
    ssf_internal



// ---------- Main loop ----------

// Inputs
i_length = input.int(10, "Length", minval=1)
i_source = input.source(close, "Source")

// Calculation
ssf2_val = ssf2(i_source, i_length)

// Plot
plot(ssf2_val, "SSF2", color=color.yellow, linewidth=2)
````
