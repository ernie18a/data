# Decay Min-Max Channel (DECAYCHANNEL)

- url: https://www.tradingview.com/script/BZUkyow6-Decay-Min-Max-Channel-DECAYCHANNEL/
- type: indicator
- pine_id: PUB;83ccadd83d3041daa072b8a765a67cb3
- version: 1.0

## Description

The Decay Channel is a price envelope that snaps out instantly to new highs and lows, then pulls back smoothly toward the center while price consolidates. It starts from the same raw extremes as a Donchian Channel, but instead of holding an old high until it exits the lookback window and then dropping off a cliff, each band gradually forgets its extreme. Breakouts widen the channel at once; quiet markets narrow it.

HISTORICAL CONTEXT

Richard Donchian's channel (1960s) defines support and resistance as the highest high and lowest low of the last N bars. Its bands move in steps: a high from 99 bars ago carries full weight, then vanishes completely one bar later. Traders do not treat old extremes that way. Their influence fades.

The Decay Channel borrows exponential decay from physics (radioactive decay, Newton's law of cooling) to let band width relax continuously instead of in jumps, while keeping Donchian's rule that a band can never sit outside actual price history.

HOW IT WORKS

Stage 1: Track extremes and their age
- If high ≥ upper band: upper snaps to the high, its age resets to 0.
- Otherwise the age increases by 1. Same logic for the low and lower band.

Stage 2: Decay toward the midpoint
λ = ln(2) / Period
mid = (upper + lower) / 2
rate = 1 − exp(−λ × age)
upper ← upper − rate × (upper − mid)
lower ← lower − rate × (lower − mid)

The rate is applied again every bar and grows with age, so decay starts slowly and accelerates. After n quiet bars the remaining width is about exp(−ln 2 × n(n+1) / (2 × Period)).

Stage 3: Donchian clamp
upper = min(upper, highest high of last Period bars)
lower = max(lower, lowest low of last Period bars)

The bands can never extend beyond real price history.

Decay speed (measured, flat price after a range)
- Period 20: width halves after about 6 bars, down to 10% after 11.
- Period 100: halves after about 14 bars, 10% after 25.
- Rule of thumb: half the width is gone after roughly √(2 × Period) bars.

On random-walk data the channel is typically 30-40% as wide as Donchian.

INPUTS & PARAMETERS

- Period: Sets both the decay rate and the Donchian lookback. Default: 100.

Period selection
- 20-50: Tight channel, bands hug recent swings and contract within a few bars.
- 100: Default. Holds extremes briefly, contracts within about 15-25 quiet bars.
- 200+: Slower release, closer to classic Donchian behavior.

HOW TO USE

Breakouts
- A band that has decayed toward price is easier to break than a full Donchian band. A close beyond a decayed band signals that price is leaving a consolidation, earlier than a Donchian breakout would.

Volatility regime
- Wide channel: recent extremes are fresh, the market is active.
- Narrow channel: no new extremes for a while, compression. Compression often precedes expansion.

Trend reading
- In an uptrend the upper band keeps snapping to new highs while the lower band decays upward toward price. That rising lower band works as a trailing stop that tightens on its own.

LIMITATIONS

- Not a half-life in the strict sense: because the decay rate grows with age and compounds each bar, the width halves after roughly √(2 × Period) bars, not after Period bars.
- More touches, more signals: bands sit much closer to price than Donchian bands, so band breaks happen more often. Filter them before trading.
- Asymmetric midpoint: when one band snaps and the other decays, the midpoint shifts, so the two bands do not contract evenly.
- Cost: each bar scans the full lookback for the Donchian clamp, so very large periods are slower to compute.
- Warmup: until Period bars exist, the clamp uses only the available history.

REFERENCES

- Donchian, R. "High Finance in Copper." Financial Analysts Journal, 1960.
- Newton, I. "Scala Graduum Caloris." Philosophical Transactions, 1701.
- Rutherford, E. Radioactive Substances and their Radiations. Cambridge University Press, 1913.

## Source Code

````pine
// Licensed under the Apache License, Version 2.0
// © mihakralj
//@version=6
indicator("Decay Min-Max Channel (DECAYCHANNEL)", "DECAYCHANNEL", overlay=true)

//@function Calculates the Decaying Min-Max Channel with decay towards midpoint
//@param period Lookback period (period > 0)
//@param hi Source series for the highest high calculation (usually high)
//@param lo Source series for the lowest low calculation (usually low)
//@returns Tuple containing [decaying_highest_high, decaying_lowest_low]
//@optimized Uses exponential decay with O(n) complexity per bar
decaychannel(simple int period, series float hi = high, series float lo = low) =>
    if period <= 0
        runtime.error("Period must be > 0")
    float decayLambda = math.log(2.0) / period
    var float[] hbuf = array.new_float(period, na)
    var float[] lbuf = array.new_float(period, na)
    var float currentMax = na
    var float currentMin = na
    var int timeSinceNewMax = 0
    var int timeSinceNewMin = 0
    int idx = bar_index % period
    array.set(hbuf, idx, hi)
    array.set(lbuf, idx, lo)
    float periodMax = na
    float periodMin = na
    float periodSum = 0.0
    int validCount = 0
    for i = 0 to period - 1
        float hVal = array.get(hbuf, i)
        float lVal = array.get(lbuf, i)
        if not na(hVal) and not na(lVal)
            periodMax := na(periodMax) ? hVal : math.max(periodMax, hVal)
            periodMin := na(periodMin) ? lVal : math.min(periodMin, lVal)
            periodSum := periodSum + (hVal + lVal) / 2.0
            validCount := validCount + 1
    float periodAverage = validCount > 0 ? periodSum / validCount : (hi + lo) / 2.0
    if na(currentMax) or na(currentMin)
        currentMax := na(periodMax) ? hi : periodMax
        currentMin := na(periodMin) ? lo : periodMin
        timeSinceNewMax := 0
        timeSinceNewMin := 0
    else
        if hi >= currentMax
            currentMax := hi
            timeSinceNewMax := 0
        else
            timeSinceNewMax := timeSinceNewMax + 1
        if lo <= currentMin
            currentMin := lo
            timeSinceNewMin := 0
        else
            timeSinceNewMin := timeSinceNewMin + 1
        if validCount > 0
            float midpoint = (currentMax + currentMin) / 2.0
            float maxDecayRate = 1 - math.exp(-decayLambda * timeSinceNewMax)
            float minDecayRate = 1 - math.exp(-decayLambda * timeSinceNewMin)
            currentMax := currentMax - maxDecayRate * (currentMax - midpoint)
            currentMin := currentMin - minDecayRate * (currentMin - midpoint)
            if not na(periodMax)
                currentMax := math.min(currentMax, periodMax)
            if not na(periodMin)
                currentMin := math.max(currentMin, periodMin)
    [currentMax, currentMin]

// ---------- Main loop ----------

// Inputs
i_period = input.int(100, "Period", minval=1)

// Calculation
[highest, lowest] = decaychannel(i_period)

// Plot
p1 = plot(highest, "Decaying High", color=color.yellow, linewidth=2)
p2 = plot(lowest, "Decaying Low", color=color.yellow, linewidth=2)
fill(p1, p2, color=color.new(color.blue, 90), title="Channel Fill")
````
