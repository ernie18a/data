<!-- tradingview-pine-id: PUB;1c48d645e9974f42a85e2b169bd3b7e9 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Directional Kernel Filter [BackQuant]

Source: https://www.tradingview.com/script/5AnxLyjj-Directional-Kernel-Filter-BackQuant/

## Description

Directional Kernel Filter [BackQuant]

Overview
Directional Kernel Filter is a trend overlay built from Gaussian-weighted price smoothing with an additional directional weighting term.

The indicator calculates fast and slow versions of the filter. Trend is determined by their relative position:

[*]Fast Kernel above Slow Kernel = bullish.
[*]Fast Kernel below Slow Kernel = bearish.

The purpose of the directional weighting is simply to give slightly more influence to historical observations whose local price movement agrees with the previously estimated filter direction, and less influence to observations moving against it.

It is a custom smoothing method, not a machine-learning model or price-prediction system.

Base Gaussian Kernel
Each filter begins with a Gaussian-weighted average of the selected Source.

For every observation in the lookback:

[*]Weight = exp(-0.5 × Distance²)

where distance depends on how far the observation is from the current bar relative to the selected kernel bandwidth.

More recent observations receive greater weight.

Older observations receive progressively less.

The result is the Base Gaussian Kernel.

Kernel Width
Kernel Width controls the effective bandwidth of the Gaussian weighting.

The bandwidth is:

[*]Filter Length × Kernel Width

Lower values concentrate more weight near the current bar.

Higher values distribute weight more broadly across the lookback.

This changes the responsiveness of both the base and directionally weighted filters.

Directional Reference
The filter then measures the previous direction of the Base Gaussian Kernel:

[*]Previous Direction = Base[1] - Base[2]

This movement is divided by ATR so the directional reference is expressed relative to recent market range.

The normalized value is capped between -1 and +1.

Conceptually:

[*]Positive = the base filter was rising.
[*]Negative = the base filter was falling.
[*]Near zero = little recent movement.

Local Direction
Each historical observation is also assigned a local price movement:

[*]Local Move = Source - Source[i+1]

This is also normalized by ATR and constrained between -1 and +1.

The script then compares the sign and magnitude of the historical local move with the previous filter direction.

Directional Alignment
Alignment is calculated as:

[*]Alignment = Previous Direction × Local Direction

This creates three general cases.

Positive alignment
The historical movement agrees with the previous filter direction.

Its directional weight is increased.

Negative alignment
The historical movement opposes the previous direction.

Its directional weight is reduced.

Near-zero alignment
The observation receives little directional adjustment.

Directional Weight
The directional adjustment is applied exponentially:

[*]Directional Weight = exp(Directional Strength × Alignment)

The internal exponent is limited to control extreme weighting.

The final observation weight becomes:

[*]Final Weight = Gaussian Weight × Directional Weight

The filtered value is the weighted average of Source using these final weights.

Directional Weight setting
The Directional Weight input controls how strongly alignment changes the Gaussian weights.

0
Disables directional weighting.

The output becomes the Base Gaussian Kernel.

Higher values
Increase the difference between observations that agree with the previous direction and those that oppose it.

Higher values therefore create a stronger directional bias in the smoothing process.

This does not predict which direction price will move next. It only changes how the historical observations inside the current filter window are weighted.

ATR Normalization
ATR is used only to normalize the directional movements.

This makes a given price change more comparable across:

[*]Different instruments.
[*]Different price levels.
[*]Different volatility conditions.

ATR does not define the trend state or act as a volatility band.

The Normalization Length controls the ATR period used for this scaling.

Fast and Slow Kernels
The script calculates two independent versions of the same filter:

[*]Fast Directional Kernel.
[*]Slow Directional Kernel.

The Fast Kernel uses the Fast Kernel Length.

The Slow Kernel uses the Slow Length.

The same:

[*]Kernel Width.
[*]Directional Weight.
[*]ATR normalization.

are applied to both.

Trend State
Trend is determined from the relationship between the two filters.

[*]Fast Kernel > Slow Kernel = bullish.
[*]Fast Kernel < Slow Kernel = bearish.

If they are exactly equal, the previous trend state remains unchanged.

This is similar in structure to a conventional fast/slow moving-average trend filter, but the underlying lines use Gaussian and directional weighting instead of a standard MA formula.

Trend Ribbon
The optional ribbon fills the area between the Fast and Slow Directional Kernels.

The colour follows the current trend state.

A wider spread means greater separation between the two filters.

A narrow spread means they are closer together.

The ribbon itself does not introduce additional signal logic.

Base Kernel Comparison
The Base Gaussian Kernel can optionally be displayed.

This provides a direct comparison between:

[*]The normal Gaussian smoother.
[*]The directionally reweighted version.

The difference between the Fast Directional Kernel and its Base Gaussian Kernel is also available in the Data Window.

This makes it possible to see how much the directional weighting is actually changing the result.

Data Window
The indicator exposes several diagnostic values.

Fast Reference Direction
ATR-normalized previous direction of the Fast Base Kernel.

Slow Reference Direction
ATR-normalized previous direction of the Slow Base Kernel.

Directional Adjustment
Difference between the Fast Directional Kernel and the Fast Base Gaussian Kernel.

A value near zero means directional weighting is having little effect at that bar.

Kernel Spread
Difference between the Fast and Slow Directional Kernels.

Positive values correspond to the bullish state.

Negative values correspond to the bearish state.

Input Guide
Fast Kernel Length
Controls the lookback of the faster filter.

Shorter values respond more quickly.

Slow Length
Controls the slower trend filter.

Larger separation between Fast and Slow lengths generally creates a more persistent crossover structure.

Kernel Width
Controls how concentrated the Gaussian weighting is toward recent observations.

Lower values emphasize recent bars more strongly.

Directional Weight
Controls how much directional alignment changes the Gaussian weights.

Set to 0 to disable the directional adjustment.

Normalization Length
ATR period used to normalize filter direction and local price movement.

How to use it
The indicator can be used as:

[*]A fast/slow trend filter.
[*]A directional overlay for broader chart context.
[*]A way to compare a normal Gaussian smoother with a directionally reweighted version.

The optional candle and background colouring simply reflect the same Fast-versus-Slow trend state.

Limitations

[*]The indicator is reactive and uses only current and historical price data.
[*]Directional weighting is based on the previously estimated filter direction; it does not forecast future direction.
[*]High Directional Weight settings can make the filter more sensitive to the recent directional structure.
[*]Fast/slow crossovers can still switch frequently during sideways markets.
[*]ATR is used only as a normalization scale and does not make the filter volatility predictive.

Alerts
The script provides:

[*]Directional Kernel Bullish: trend changes from bearish to bullish.
[*]Directional Kernel Bearish: trend changes from bullish to bearish.

Summary
Directional Kernel Filter starts with a Gaussian-weighted smoother.

It then measures the previous direction of that base smoother and compares it with the local direction of each observation inside the lookback.

Observations aligned with the previous filter direction receive more weight, while opposing observations receive less.

Fast and Slow versions of the resulting filter are then compared to determine the bullish or bearish trend state.

The indicator is simply a custom directional weighting variation of Gaussian price smoothing, with the Base Kernel available for comparison so the effect of the additional weighting can be inspected directly.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BackQuant


//@version=6
indicator("Directional Kernel Filter [BackQuant]", shorttitle="Directional Kernel [BackQuant]", overlay=true)

// Constants
const string calc = "Core Calculation Settings"
const string ui   = "Plotting and Coloring"
const color GREEN = #00ff00
const color RED   = #ff0000

// Inputs
float src = input.source(close, "Source", group=calc)
int fastLen = input.int(18, "Fast Kernel Length", minval=3, group=calc, inline="LEN")
int slowLen = input.int(35, "Slow", minval=5, group=calc, inline="LEN")
float kernelWidth = input.float(0.35, "Kernel Width", minval=0.05, maxval=1.0, step=0.05, group=calc, tooltip="Controls the Gaussian kernel bandwidth relative to the filter length. Lower values concentrate weight near the current bar.")
float directionStrength = input.float(3.5, "Directional Weight", minval=0.0, maxval=5.0, step=0.1, group=calc, tooltip="Controls how strongly observations agreeing with the previously estimated direction are favored. 0 disables directional weighting.")
int normLen = input.int(14, "Normalization Length", minval=2, group=calc, tooltip="ATR length used to normalize directional price movement across assets and volatility regimes.")

color longCol = input.color(GREEN, "Long Color", group=ui, inline="COL")
color shortCol = input.color(RED, "Short Color", group=ui, inline="COL")
int lineW = input.int(3, "Line Width", minval=1, maxval=6, group=ui)
bool showRibbon = input.bool(true, "Show Trend Ribbon?", group=ui)
bool showBase = input.bool(false, "Show Base Kernel?", group=ui)
bool paintCandles = input.bool(false, "Paint Candles to Trend?", group=ui)
bool bgCol = input.bool(false, "Background Color?", group=ui)

// Directional Kernel Filter
directionalKernel(float source, simple int length, float width, float strength, float norm) =>
    float bandwidth = math.max(1.0, length * width)

    float baseWeighted = 0.0
    float baseWeights = 0.0

    for i = 0 to length - 1
        if not na(source[i])
            float distance = i / bandwidth
            float kernelWeight = math.exp(-0.5 * distance * distance)
            baseWeighted += source[i] * kernelWeight
            baseWeights += kernelWeight

    float base = baseWeights > 0.0 ? baseWeighted / baseWeights : na

    float priorDirection = nz(base[1] - base[2])
    float priorNorm = priorDirection / math.max(nz(norm[1], norm), syminfo.mintick)
    priorNorm := math.max(-1.0, math.min(1.0, priorNorm))

    float weightedPrice = 0.0
    float totalWeight = 0.0

    for i = 0 to length - 1
        if not na(source[i])
            float distance = i / bandwidth
            float kernelWeight = math.exp(-0.5 * distance * distance)

            float localMove = i < length - 1 ? source[i] - source[i + 1] : 0.0
            float localNorm = localMove / math.max(nz(norm[i], norm), syminfo.mintick)
            localNorm := math.max(-1.0, math.min(1.0, localNorm))

            float alignment = priorNorm * localNorm
            float exponent = math.max(-3.0, math.min(3.0, strength * alignment))
            float directionWeight = math.exp(exponent)

            float weight = kernelWeight * directionWeight

            weightedPrice += source[i] * weight
            totalWeight += weight

    float filtered = totalWeight > 0.0 ? weightedPrice / totalWeight : base

    [filtered, base, priorNorm]

// Normalization
float atr = ta.atr(normLen)

// Fast + Slow Directional Kernels
[fastKernel, fastBase, fastDirection] = directionalKernel(src, fastLen, kernelWidth, directionStrength, atr)
[slowKernel, slowBase, slowDirection] = directionalKernel(src, slowLen, kernelWidth, directionStrength, atr)

// Trend State
bool bullish = fastKernel > slowKernel
bool bearish = fastKernel < slowKernel

var int trend = 0

if bullish
    trend := 1
else if bearish
    trend := -1

color col = trend == 1 ? longCol : shortCol

// Ribbon
pFast = plot(fastKernel, "Fast Directional Kernel", col, lineW)
pSlow = plot(showRibbon ? slowKernel : na, "Slow Directional Kernel", color.new(col, 60), 2)

fill(pFast, pSlow, showRibbon ? color.new(col, 82) : na, title="Directional Kernel Ribbon")

// Base Gaussian Kernel
plot(showBase ? fastBase : na, "Base Gaussian Kernel", color.new(chart.fg_color, 60), 1)

// Candles
plotcandle(open, high, low, close, "Trend Candles",
     col, col, true,
     bordercolor=col,
     display=paintCandles ? display.all : display.none)

bgcolor(bgCol ? color.new(col, 90) : na)

// Data Window
plot(fastDirection, "Fast Reference Direction", display=display.data_window)
plot(slowDirection, "Slow Reference Direction", display=display.data_window)
plot(fastKernel - fastBase, "Directional Adjustment", display=display.data_window)
plot(fastKernel - slowKernel, "Kernel Spread", display=display.data_window)

// Alerts
bool bullFlip = trend == 1 and trend[1] == -1
bool bearFlip = trend == -1 and trend[1] == 1

alertcondition(bullFlip, title="Directional Kernel Bullish", message="Directional Kernel Trend Filter turned bullish {{exchange}}:{{ticker}}")
alertcondition(bearFlip, title="Directional Kernel Bearish", message="Directional Kernel Trend Filter turned bearish {{exchange}}:{{ticker}}")
````
