# State-Dependent EMA [BackQuant]

- url: https://www.tradingview.com/script/jdVw4YmG-State-Dependent-EMA-BackQuant/
- type: indicator
- pine_id: PUB;e10f1ea345f14d249ab1c41bf7d64215
- version: 1.0

## Description

[b]State-Dependent EMA [BackQuant][/b]

[b]Overview[/b]
State-Dependent EMA is an adaptive exponential moving average that adjusts its smoothing coefficient using three measurements: price efficiency, sustained deviation from the filter, and changes in short-term volatility.

Rather than using a fixed EMA length, the indicator calculates a smoothing coefficient between the selected Fast and Slow EMA settings. The coefficient changes as the estimated market state changes, allowing the filter to respond more quickly under some conditions and apply greater smoothing under others.

The indicator includes three state models, an optional volatility penalty, two methods of determining trend direction, a gradient ribbon and a fixed EMA for comparison.

[b]Core Calculation[/b]
The filter uses the standard recursive EMA update:

Filter = Previous Filter + Alpha × (Source - Previous Filter)

The difference is that Alpha is recalculated on every bar rather than remaining fixed.

The adaptive coefficient is calculated as:

Alpha = Slow Alpha + (Fast Alpha - Slow Alpha) × Market State

Market State ranges from 0 to 1.

[list]
[*]A state near 0 produces a coefficient close to the Slow EMA setting.
[*]A state near 1 produces a coefficient close to the Fast EMA setting.
[*]Intermediate values produce a response between the two.
[/list]

Fast and Slow EMA Length define the coefficient limits. The script does not blend two separately calculated EMA lines.

[b]State Estimation[/b]
Three state models are available: Efficiency, Sustained Residual and Combined. All three can be moderated by the optional variance penalty.

[b]Efficiency[/b]
The efficiency calculation compares net price displacement with the total absolute movement over the selected Efficiency Length.

Efficiency = |Source - Source[N]| / Sum of Absolute Bar-to-Bar Changes

The result ranges from 0 to 1.

A value near 1 indicates that most movement over the window occurred in one direction. A value near 0 indicates that price travelled considerably more than its final net displacement.

High efficiency increases the adaptive coefficient, while low efficiency favours greater smoothing.

The calculation measures directional efficiency regardless of whether price is rising or falling.

[b]Sustained Residual[/b]
The residual model measures how far the current Source is from the previous filtered value:

Innovation = Source - Previous Filter

This difference is smoothed using an EMA over the selected Residual Persistence length. Its absolute value is then divided by ATR and scaled using Residual Scale.

The result is capped at 1.

[list]
[*]A small or inconsistent residual produces a lower state value.
[*]A larger residual that persists in one direction produces a higher state value.
[/list]

This allows the filter to increase its response when the Source remains displaced from its previous estimate.

The absolute residual is used, so upward and downward deviations are treated equally. The residual state controls responsiveness, not bullish or bearish direction.

[b]Combined State[/b]
Combined mode blends the Efficiency and Sustained Residual states using the two configurable weights.

Combined State = (Efficiency × Efficiency Weight + Residual State × Residual Weight) / Total Weight

The weights are normalized by their sum, so they determine the relative contribution of each component.

If both weights are zero, the combined state is zero.

[b]Variance Penalty[/b]
The indicator compares the short-term and long-term standard deviations of one-bar Source changes.

Despite the input's name, the calculated Variance Ratio is a [b]ratio of standard deviations[/b], not a ratio of squared variances.

When short-term volatility exceeds its longer-term baseline, the variance penalty can reduce the calculated state:

Variance Gate = 1 / (1 + Penalty × max(Volatility Ratio - 1, 0))

The selected state is multiplied by this gate before the adaptive Alpha is calculated.

This means an increase in efficiency or sustained residual does not always produce a faster filter. A simultaneous increase in short-term volatility can partially offset it.

Set Variance Penalty to 0 to disable this adjustment.

[b]Trend Direction[/b]
Two trend methods are available.

[b]Ribbon[/b]
Compares the adaptive filter with an EMA of its own values over the selected Ribbon Length.

[list]
[*]Filter above Ribbon = bullish.
[*]Filter below Ribbon = bearish.
[/list]

[b]Filter Slope[/b]
Compares the current filtered value with its value at the selected Slope Lookback.

[list]
[*]Filter rising = bullish.
[*]Filter falling = bearish.
[/list]

In either mode, an exact equality retains the previous trend state.

The selected trend method controls line colour, optional candle and background colouring, and bullish/bearish alerts.

[b]Visuals[/b]
The Gradient Ribbon displays the distance between the adaptive filter and its smoothed reference.

The optional Price Gradient fills the area between the filter and the chart's closing price. This uses Close even when a different calculation Source is selected.

Filter Glow adds an ATR-scaled visual band around the adaptive line. It does not affect the state estimation or trend signals.

The Fixed EMA Comparison plots a conventional EMA of the selected Source, making it possible to compare the adaptive response against a fixed-length smoother.

[b]Input Guide[/b]
[list]
[*][b]Fast / Slow EMA Length:[/b] Set the response limits of the adaptive filter.
[*][b]State Model:[/b] Select Efficiency, Sustained Residual or their weighted combination.
[*][b]Efficiency Length:[/b] Lookback used to compare net displacement with total movement.
[*][b]Residual Persistence:[/b] EMA smoothing length applied to the filter's residual.
[*][b]ATR Length:[/b] Normalization period for the residual state.
[*][b]Residual Scale:[/b] Controls how much normalized residual is required to reach the maximum residual state.
[*][b]Efficiency / Residual Weight:[/b] Set the relative contribution of each component in Combined mode.
[*][b]Short / Long Variance Length:[/b] Define the two standard-deviation windows used by the volatility comparison.
[*][b]Variance Penalty:[/b] Controls how strongly elevated short-term volatility reduces responsiveness.
[*][b]Ribbon Length:[/b] Smoothing length for the ribbon reference.
[*][b]Trend Direction:[/b] Select the Ribbon or Filter Slope method.
[*][b]Slope Lookback:[/b] Comparison period used by Filter Slope mode.
[/list]

[b]Data Window[/b]
The Data Window exposes the current Adaptive Alpha, Effective EMA Length, Efficiency Ratio, Sustained Residual State, Variance Ratio and final Market State.

Effective EMA Length is calculated as:

Effective Length = 2 / Alpha - 1

This expresses the current smoothing coefficient as an equivalent fixed EMA length. Because Alpha changes through time, it is not the length of a single fixed-window calculation.

These values are useful when comparing how the different state models and variance settings affect the filter.

[b]Limitations[/b]
The state measurements are based on current and historical data. They do not predict future price direction.

High efficiency can occur in either rising or falling markets. Likewise, a large sustained residual can increase responsiveness in either direction.

The variance penalty can reduce responsiveness during periods of increased short-term volatility, including genuine directional moves. More aggressive settings may respond faster but can also introduce more frequent changes in trend colour.

As with other moving averages, the indicator remains sensitive to its selected lengths and can produce repeated trend changes in sideways conditions.

[b]Alerts[/b]
[list]
[*][b]State EMA Bullish:[/b] the selected trend method changes from bearish to bullish.
[*][b]State EMA Bearish:[/b] the selected trend method changes from bullish to bearish.
[/list]

[b]Summary[/b]
State-Dependent EMA adjusts a standard EMA smoothing coefficient using price efficiency, sustained deviation from the previous filtered value, or a combination of both. An optional volatility penalty moderates the response when short-term price-change volatility rises above its longer-term baseline.

The resulting line can be evaluated using either a smoothed ribbon or its own slope, with a fixed EMA comparison and Data Window measurements available for inspecting how the adaptive settings affect its behaviour.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BackQuant

//@version=6
indicator("State-Dependent EMA [BackQuant]", shorttitle="State EMA [BackQuant]", overlay=true)

// Constants
const string calc = "Core Calculation Settings"
const string state = "State Estimation"
const string ui = "Plotting and Coloring"
const color GREEN = #00ff00
const color RED = #ff0000

// Inputs
float src = input.source(close, "Source", group=calc)
int fastLen = input.int(4, "Fast EMA Length", minval=1, group=calc, inline="LEN")
int slowLen = input.int(40, "Slow EMA Length", minval=2, group=calc, inline="LEN")
string stateMode = input.string("Combined", "State Model", options=["Combined", "Efficiency", "Sustained Residual"], group=calc)

int erLen = input.int(20, "Efficiency Length", minval=2, group=state)
int residualLen = input.int(4, "Residual Persistence", minval=1, group=state)
int atrLen = input.int(14, "ATR Length", minval=2, group=state)
float residualScale = input.float(1.5, "Residual Scale", minval=0.1, step=0.1, group=state)
float efficiencyWeight = input.float(0.5, "Efficiency Weight", minval=0.0, maxval=1.0, step=0.05, group=state, inline="WT")
float residualWeight = input.float(0.5, "Residual", minval=0.0, maxval=1.0, step=0.05, group=state, inline="WT")
int shortVarLen = input.int(10, "Short Variance Length", minval=2, group=state, inline="VAR")
int longVarLen = input.int(40, "Long", minval=3, group=state, inline="VAR")
float variancePenalty = input.float(1.0, "Variance Penalty", minval=0.0, maxval=5.0, step=0.1, group=state, tooltip="Reduces alpha when short-term return volatility exceeds its longer-term baseline. Set to 0 to disable.")

color longCol = input.color(GREEN, "Long Color", group=ui, inline="COL")
color shortCol = input.color(RED, "Short Color", group=ui, inline="COL")
int lineW = input.int(3, "Line Width", minval=1, maxval=6, group=ui)
int ribbonLen = input.int(9, "Ribbon Length", minval=2, group=ui)
string trendMode = input.string("Ribbon", "Trend Direction", options=["Ribbon", "Filter Slope"], group=ui)
int trendLookback = input.int(2, "Slope Lookback", minval=1, group=ui)
bool showRibbon = input.bool(true, "Gradient Ribbon", group=ui)
bool showFill = input.bool(true, "Price Gradient Fill", group=ui)
bool showGlow = input.bool(true, "Filter Glow", group=ui)
bool showBaseline = input.bool(false, "Show Fixed EMA Comparison", group=ui)
int baselineLen = input.int(20, "Comparison Length", minval=1, group=ui)
bool paintCandles = input.bool(false, "Paint Candles", group=ui)
bool bgCol = input.bool(false, "Background Color", group=ui)

// Efficiency
float change = src - src[1]
float travel = ta.sma(math.abs(change), erLen) * erLen
float displacement = math.abs(src - src[erLen])
float efficiency = not na(travel) and travel > 0.0 ? math.min(displacement / travel, 1.0) : 0.0

// Variance
float shortVol = ta.stdev(change, shortVarLen)
float longVol = ta.stdev(change, longVarLen)
float varianceRatio = not na(shortVol) and not na(longVol) and longVol > 0.0 ? shortVol / longVol : 1.0
float varianceGate = 1.0 / (1.0 + variancePenalty * math.max(varianceRatio - 1.0, 0.0))

// Sustained Residual
var float filt = na
float innovation = src - nz(filt[1], src)
float persistentResidual = ta.ema(innovation, residualLen)
float atr = ta.atr(atrLen)
float normalizedResidual = math.abs(persistentResidual) / math.max(nz(atr, syminfo.mintick), syminfo.mintick)
float residualState = math.min(normalizedResidual / residualScale, 1.0)

// State Model
float totalWeight = efficiencyWeight + residualWeight
float combinedState = totalWeight > 0.0 ? (efficiency * efficiencyWeight + residualState * residualWeight) / totalWeight : 0.0

float rawState = switch stateMode
    "Efficiency" => efficiency
    "Sustained Residual" => residualState
    => combinedState

float marketState = math.max(0.0, math.min(1.0, rawState * varianceGate))

// Adaptive Alpha
float fastAlpha = 2.0 / (fastLen + 1.0)
float slowAlpha = 2.0 / (math.max(slowLen, fastLen + 1) + 1.0)
float alpha = slowAlpha + (fastAlpha - slowAlpha) * marketState

// State-Dependent EMA
filt := na(filt[1]) ? src : filt[1] + alpha * (src - filt[1])

// Ribbon
float ribbonRef = ta.ema(filt, ribbonLen)
float baseline = ta.ema(src, baselineLen)

// Trend
bool bullish = trendMode == "Ribbon" ? filt > ribbonRef : filt > filt[trendLookback]
bool bearish = trendMode == "Ribbon" ? filt < ribbonRef : filt < filt[trendLookback]

var int trend = 0

if bullish
    trend := 1
else if bearish
    trend := -1

color col = trend == 1 ? longCol : trend == -1 ? shortCol : chart.fg_color

// Hidden Fill References
pFilter = plot(filt, "Filter Reference", display=display.none, editable=false)
pPrice = plot(close, "Price Reference", display=display.none, editable=false)
pRibbon = plot(showRibbon ? ribbonRef : na, "Ribbon Reference", color.new(col, 65), 2)

// Price Gradient
float priceTop = math.max(close, filt)
float priceBottom = math.min(close, filt)

color priceTopCol = close > filt ? color.new(col, 92) : color.new(col, 20)
color priceBottomCol = close > filt ? color.new(col, 20) : color.new(col, 92)

fill(pPrice, pFilter, priceTop, priceBottom, showFill ? priceTopCol : na, showFill ? priceBottomCol : na, title="Price Gradient")

// Ribbon Gradient
float ribbonTop = math.max(filt, ribbonRef)
float ribbonBottom = math.min(filt, ribbonRef)

color ribbonTopCol = filt > ribbonRef ? color.new(col, 25) : color.new(col, 90)
color ribbonBottomCol = filt > ribbonRef ? color.new(col, 90) : color.new(col, 25)

fill(pFilter, pRibbon, ribbonTop, ribbonBottom, showRibbon ? ribbonTopCol : na, showRibbon ? ribbonBottomCol : na, title="Trend Ribbon")

// Filter Glow
float glow = atr * 0.06
float outerGlow = glow * 2.0

pGlowUpper = plot(showGlow ? filt + glow : na, "Glow Upper", display=display.none, editable=false)
pGlowLower = plot(showGlow ? filt - glow : na, "Glow Lower", display=display.none, editable=false)
pOuterUpper = plot(showGlow ? filt + outerGlow : na, "Outer Glow Upper", display=display.none, editable=false)
pOuterLower = plot(showGlow ? filt - outerGlow : na, "Outer Glow Lower", display=display.none, editable=false)

fill(pOuterUpper, pOuterLower, showGlow ? color.new(col, 94) : na, title="Outer Glow")
fill(pGlowUpper, pGlowLower, showGlow ? color.new(col, 76) : na, title="Inner Glow")

// Main Filter
plot(filt, "State-Dependent EMA", col, lineW)
plot(showBaseline ? baseline : na, "Fixed EMA Comparison", color.new(chart.fg_color, 55), 1)

// Candles
plotcandle(open, high, low, close, "Trend Candles", col, col, true, bordercolor=col, display=paintCandles ? display.all : display.none)
bgcolor(bgCol ? color.new(col, 90) : na)

// Data Window
plot(alpha, "Adaptive Alpha", display=display.data_window)
plot(2.0 / alpha - 1.0, "Effective EMA Length", display=display.data_window)
plot(efficiency, "Efficiency Ratio", display=display.data_window)
plot(residualState, "Sustained Residual State", display=display.data_window)
plot(varianceRatio, "Variance Ratio", display=display.data_window)
plot(marketState, "Market State", display=display.data_window)

// Alerts
bool bullFlip = trend == 1 and trend[1] == -1
bool bearFlip = trend == -1 and trend[1] == 1

alertcondition(bullFlip, "State EMA Bullish", "State-Dependent EMA turned bullish {{exchange}}:{{ticker}}")
alertcondition(bearFlip, "State EMA Bearish", "State-Dependent EMA turned bearish {{exchange}}:{{ticker}}")
````
