# PGS - Pareto-Gaussian Skew [Zofesu]

- url: https://www.tradingview.com/script/Km7Vzjzz-PGS-Pareto-Gaussian-Skew-Zofesu/
- type: indicator
- pine_id: PUB;514d16234d7649bc90c3f9f1d8ed264d
- version: 1.0

## Description

[b]PGS - Pareto-Gaussian Skew [Zofesu][/b] is a trend gravity indicator built on two mathematical principles: the Gaussian distribution for detecting statistically significant price moves, and the Pareto principle for isolating the minority of moves that drive the majority of directional displacement.
 
The result is a single adaptive line that acts as a gravitational center — pulling toward institutional price displacement while filtering out the noise that makes standard moving averages lag or whipsaw.
 
─────────────────────────────────────
[b]01 — What is PGS?[/b]
─────────────────────────────────────
[b]PGS[/b] plots a gravity line that tracks where price is being pulled by significant institutional moves. Unlike a standard moving average, it does not react to all price movement equally. It reacts only when price moves beyond one standard deviation from its mean — the threshold where statistically normal noise ends and directional displacement begins.
 
Below that threshold, the line stays anchored to the mean. Above it, the Pareto Skew Factor shifts the gravity line toward the extreme, capturing the 20% of moves that drive 80% of the trend.
 
─────────────────────────────────────
[b]02 — How it works[/b]
─────────────────────────────────────
[b]The engine runs in three steps:[/b]
 
[b]Step 1[/b] — Mean and standard deviation
SMA and standard deviation are calculated over the lookback window (default 100 bars). This defines the Gaussian baseline — the statistical center of recent price behavior.
 
[b]Step 2[/b] — Extreme detection
The distance between current close and the mean is measured. If that distance exceeds 1x standard deviation, the move is classified as extreme. Moves within 1 standard deviation are treated as noise and ignored.
 
[b]Step 3[/b] — Pareto displacement
Extreme moves are multiplied by the Pareto Skew Factor (default 0.8). This skewed value is then smoothed with an EMA over a quarter of the lookback period and added back to the mean — producing the final gravity line.
 
[b]Formula:[/b]
gravity = SMA(close, n) + EMA(d × extreme × skew, n/4)
where d = close − SMA(close, n), extreme = 1 if |d| > StDev else 0
 
─────────────────────────────────────
[b]03 — Visuals[/b]
─────────────────────────────────────
[b]Blue line[/b] — Pareto-Gaussian gravity line
 
[b]Tension Cloud[/b] — fill between price and the gravity line.
[b]Green fill[/b] = price above gravity line (bullish tension).
[b]Pink fill[/b] = price below gravity line (bearish tension).
 
[b]Note:[/b] Price Reference and PGS Reference appear in the indicator's plot list but are invisible on the chart. They are internal anchors required by Pine Script's fill() function and serve no visual or analytical purpose for the user.
 
─────────────────────────────────────
[b]04 — Settings[/b]
─────────────────────────────────────
[b]Smith's Memory (Lookback)[/b] — default 100
Number of candles used for the Gaussian baseline. Higher = slower, more stable line. Lower = faster, more reactive.
 
[b]Pareto Skew Factor[/b] — default 0.8
Weight applied to extreme moves. Higher = gravity line shifts more aggressively toward institutional displacement. Lower = more conservative, stays closer to the mean.
 
─────────────────────────────────────
[b]05 — How To Use[/b]
─────────────────────────────────────
[b]Step 1[/b] — Read the Tension Cloud
Green fill = price is above the gravity line. Bullish context — look for longs or hold existing positions.
Pink fill = price is below the gravity line. Bearish context — look for shorts or avoid longs.
 
[b]Step 2[/b] — Watch for gravity line crossings
Price crossing the gravity line from below = potential bullish shift.
Price crossing from above = potential bearish shift.
 
[b]Step 3[/b] — Use as dynamic support and resistance
In trending markets the gravity line acts as a dynamic S/R level. Price pulling back to the line in a green cloud = potential long entry zone.
 
[b]Step 4[/b] — Combine with higher timeframe context
PGS works best as a trend context filter alongside entry tools. It defines the direction — your entry indicator defines the moment.
 
[b]Works on all asset classes:[/b] Indices, Forex, Gold, Oil, Crypto.
Best timeframes: H1, H4, D1.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Since 2020 Zofesu

//@version=6
indicator("PGS - Pareto-Gaussian Skew [Zofesu]", shorttitle="[Zofesu] PGS", overlay=true)

// ============================================
// 1. INPUTS
// ============================================
lookback     = input.int(100, "Smith's Memory (Lookback)", minval=20, maxval=500,
     tooltip="Number of candles the engine uses to calculate the Gaussian distribution and standard deviation.")
paretoFactor = input.float(0.8, "Pareto Skew Factor", minval=0.5, maxval=1.0, step=0.1,
     tooltip="Defines the weight of extremes. Higher value skews the gravity line further toward institutional price movements.")

// ============================================
// 2. CORE FUNCTION
// ============================================
// Filters noise and focuses on the 20% of moves that drive 80% of the trend.
f_getParetoGaussianGravity(int _len, float _skew) =>
    float m = ta.sma(close, _len)
    float s = ta.stdev(close, _len)
    float d = close - m
    // Detects extreme moves beyond 1x standard deviation
    float extreme = math.abs(d) > s ? 1.0 : 0.0
    // Applies the Pareto factor to capture institutional displacement
    float skew = d * extreme * _skew
    // Smooths the resulting curve for a stable gravity line
    m + ta.ema(skew, math.max(1, math.floor(_len / 4)))

// ============================================
// 3. EXECUTION & PLOTTING
// ============================================
pgs_line = f_getParetoGaussianGravity(lookback, paretoFactor)

// Plots the "Invisible Hand" gravity line
plot(pgs_line, title="Pareto-Gaussian Skew", color=color.new(#2b5cff, 0), linewidth=3)

// Fill between price and the gravity line to visualize tension
// Price Reference and PGS Reference are invisible anchors required by fill() — they serve no visual function
fillColor = close > pgs_line ? color.new(#00ffaa, 80) : color.new(#ff00aa, 80)
p1 = plot(close, "Price Reference", display=display.none)
p2 = plot(pgs_line, "PGS Reference", display=display.none)
fill(p1, p2, color=fillColor, title="Tension Cloud")
````
