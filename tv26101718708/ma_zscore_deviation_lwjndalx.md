# MA Z-Score Deviation

- url: https://www.tradingview.com/script/lWjNdAlx-MA-Z-Score-Deviation/
- type: indicator
- pine_id: PUB;d03d0acd6db641c7a30323449d7bf25d
- version: 1.0

## Description

A valuation oscillator that measures how far price has stretched from its statistical fair value defined here as its moving average, expressed as a standardized score rather than raw price units.

[b]How it works[/b]

Base: A moving average (SMA, EMA, or WMA) serves as the reference "fair value" line. Deviation from this baseline is calculated as a log ratio (log(price / MA)) rather than a simple price difference, so the reading stays comparable across different price levels and time periods: a 5% premium or discount reads the same whether the instrument is at $10 or $500.
Standardization: the deviation is divided by its own rolling dispersion to produce a score that expresses how rich or cheap price is relative to its typical range, not just in absolute terms. 

Two dispersion methods are available:

Standard Deviation: the classical measure of typical variability.

MAD: a median-based measure that's more resistant to distortion from one-off outlier bars.

Blend: a weighted combination of both, adjustable via the MAD Weight input.
Display scaling: the score is passed through a bounded transform for cleaner visual scaling on the chart, while the underlying valuation ranking is preserved.

[b]Inputs[/b]

Source & MA type (SMA/EMA/WMA) and length
Lookback length for the dispersion calculation, independent from the MA length, letting you compare long-term fair value against recent volatility conditions
Dispersion method (Stdev / MAD / Blend) and blend weight
Display scaling factor

[b]Reading the indicator[/b]

Positive values indicate price is trading at a premium to its baseline; negative values indicate a discount.
Values beyond ±2 suggest a notable premium/discount relative to recent conditions; beyond ±3 suggests a substantial one.
Because the baseline is statistical rather than fixed, the "fair value" and its bands adjust automatically as market conditions evolve.

[b]Notes / limitations[/b]

This measures statistical richness/cheapness relative to a moving average, not intrinsic or fundamental value; it's a technical valuation lens, not a fundamental one.
Financial return distributions have fatter tails than a normal distribution assumes, so extreme readings can occur more frequently than the underlying statistical model implies; treat scores as relative positioning, not precise probabilities.
Alerts trigger only on confirmed bar closes to avoid firing on intrabar noise.

## Source Code

````pine
//@version=6
indicator("MA Z-Score Deviation", overlay=false)

// ===== Inputs =====
src        = input.source(close, "Source")
maType     = input.string("SMA", "MA Type", options=["SMA", "EMA", "WMA"])
meanLen    = input.int(200, "MA Length", minval=1)
z_length   = input.int(100, "Z-Score Length", minval=1)
dispMethod = input.string("Blend", "Dispersion Method", options=["Standard Deviation", "MAD", "Blend"])
madWeight  = input.float(0.5, "MAD Weight (Blend only)", minval=0.0, maxval=1.0, step=0.05)
tanhK      = input.float(3.0, "Compression Factor (higher = less squashing)", minval=0.5, step=0.5)

// ===== Helper: tanh (with overflow guard) =====
tanh(x) =>
    x_clamped = math.max(math.min(x, 20), -20)
    e2x = math.exp(2 * x_clamped)
    (e2x - 1) / (e2x + 1)

// ===== Mean =====
getMA(source, len, type) =>
    switch type
        "SMA" => ta.sma(source, len)
        "EMA" => ta.ema(source, len)
        "WMA" => ta.wma(source, len)

mean = getMA(src, meanLen, maType)

// ===== Deviation =====
dev = math.log(src / mean)

// ===== Dispersion measures =====
devSD = ta.stdev(dev, z_length)

medDev        = ta.percentile_nearest_rank(dev, z_length, 50)
absDevFromMed = math.abs(dev - medDev)
mad           = ta.percentile_nearest_rank(absDevFromMed, z_length, 50) * 1.4826

dispersion = switch dispMethod
    "MAD"        => mad
    "Standard Deviation"  => devSD
    "Blend"               => madWeight * mad + (1 - madWeight) * devSD
    => devSD  // fallback

// ===== Raw Z-Score (used for alerts) =====
z_raw = dispersion != 0 ? dev / dispersion : na

// Warm-up guard: suppress unreliable values before enough history exists
warmupBars = meanLen + z_length
z = bar_index < warmupBars ? na : z_raw

// ===== Bounded Z for display =====
z_bounded = na(z) ? na : tanh(z / tanhK)

// ===== Plot =====
zColor = z >= 3 or z <= -3 ? color.new(color.red, 0) :
         z >= 2 or z <= -2 ? color.new(color.orange, 0) :
         color.new(color.blue, 0)

plot(z_bounded, title="Z Oscillator (bounded)", color=zColor, linewidth=2)

// Zones — recomputed in bounded space to match z = 2 and z = 3
zoneOB      = tanh(2 / tanhK)
zoneExtOB   = tanh(3 / tanhK)
zoneOS      = -zoneOB
zoneExtOS   = -zoneExtOB

hline(0, "Mean", color=color.gray)
h2  = hline(zoneOB, "Overbought", color=color.new(color.red, 60))
h3  = hline(zoneExtOB, "Extreme OB", color=color.new(color.red, 60))
hn2 = hline(zoneOS, "Oversold", color=color.new(color.green, 60))
hn3 = hline(zoneExtOS, "Extreme OS", color=color.new(color.green, 60))

fill(h2, h3, color=color.new(color.red, 90))
fill(hn2, hn3, color=color.new(color.green, 90))

// ===== Alerts (based on RAW/warmup-guarded z, confirmed bars only) =====
alertcondition(ta.crossover(z, 2) and barstate.isconfirmed, "Z cross above 2 (Overbought)")
alertcondition(ta.crossunder(z, -2) and barstate.isconfirmed, "Z cross below -2 (Oversold)")
alertcondition(ta.crossover(z, 3) and barstate.isconfirmed, "Z cross above 3 (Extreme OB)")
alertcondition(ta.crossunder(z, -3) and barstate.isconfirmed, "Z cross below -3 (Extreme OS)")
````
