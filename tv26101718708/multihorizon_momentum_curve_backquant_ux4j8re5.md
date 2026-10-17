# Multi-Horizon Momentum Curve [BackQuant]

- url: https://www.tradingview.com/script/Ux4j8re5-Multi-Horizon-Momentum-Curve-BackQuant/
- type: indicator
- pine_id: PUB;0543930b8b454452a595428acd2e0039
- version: 1.0

## Description

[b]Multi-Horizon Momentum Curve [BackQuant][/b]

[b]Overview[/b]
Multi-Horizon Momentum Curve combines momentum measured across four configurable lookback periods into a single volatility-normalized oscillator.

Each horizon measures the log return from the current Source to its value N bars ago. That return is divided by recent one-bar return volatility scaled by the square root of the horizon length.

The four normalized momentum values are then:
[list]
[*]Clamped to a configurable maximum magnitude.
[*]Combined using user-defined weights.
[*]Optionally smoothed with an EMA.
[/list]

The result is a single momentum curve that reflects short-, medium- and longer-horizon price movement at the same time.

[b]One-Bar Return Volatility[/b]
The script first calculates the one-bar log return:

[list]
[*]Log Return = log(Source / Previous Source)
[/list]

Recent return volatility is then estimated using the standard deviation of those one-bar log returns over the selected Volatility Length.

This same volatility estimate is used to normalize all four momentum horizons.

[b]Normalized Horizon Momentum[/b]
For each horizon, the script calculates:

[list]
[*]Horizon Return = log(Source / Source[N])
[/list]

The volatility scaling term is:

[list]
[*]Expected Volatility = One-Bar Volatility × √N
[/list]

Momentum is then:

[list]
[*]Normalized Momentum = Horizon Return / Expected Volatility
[/list]

This expresses the size of the horizon return relative to the current one-bar volatility estimate and the length of the horizon.

It is a normalization method for comparing different lookbacks on a similar scale. It should not be interpreted as a probability or formal statistical significance measure.

[b]Momentum Clamp[/b]
Each horizon value is capped between:

[list]
[*]-Momentum Clamp
[*]+Momentum Clamp
[/list]

This prevents a single unusually large normalized move from dominating the combined curve.

For example, with a clamp of 4.0:
[list]
[*]Values above +4 are treated as +4.
[*]Values below -4 are treated as -4.
[/list]

Clamping occurs before the four horizons are combined.

[b]Four Momentum Horizons[/b]
The indicator calculates four independent normalized momentum values.

Each horizon has:
[list]
[*]Its own lookback length.
[*]Its own weight in the final composite.
[/list]

The default horizons are:
[list]
[*]5 bars.
[*]10 bars.
[*]20 bars.
[*]40 bars.
[/list]

with progressively larger default weights assigned to the longer horizons.

These settings are fully configurable.

[b]Weighted Momentum Composite[/b]
The four horizon values are combined using a weighted average:

[list]
[*]Composite = Σ(Momentum × Weight) / Σ(Weights)
[/list]

A larger weight gives that horizon more influence over the final curve.

A weight of zero removes that horizon from the composite.

If all four weights are zero, the raw composite returns zero.

[b]Curve Smoothing[/b]
The raw weighted composite can optionally be smoothed with an EMA.

If Curve Smoothing is set to 1:
[list]
[*]The raw composite is used directly.
[/list]

Higher values:
[list]
[*]Reduce short-term changes in the oscillator.
[*]Introduce additional smoothing.
[/list]

The unsmoothed and smoothed values are both available in the Data Window.

[b]Horizon Agreement[/b]
The indicator also counts how many of the four horizon momentum values share the same sign.

For each horizon:
[list]
[*]Positive momentum contributes to the bullish count.
[*]Negative momentum contributes to the bearish count.
[/list]

Agreement is:

[list]
[*]max(Bullish Count, Bearish Count) / 4
[/list]

This produces values from 50% to 100% when all horizons are non-zero, with higher values indicating greater sign agreement across the four lookbacks.

Examples:
[list]
[*]4 bullish / 0 bearish = 100% agreement.
[*]3 bullish / 1 bearish = 75%.
[*]2 bullish / 2 bearish = 50%.
[/list]

If one or more horizon values are exactly zero, the reported percentage can also fall below 50% because zero values are counted as neither bullish nor bearish.

Agreement is diagnostic only and does not control the trend state.

[b]Trend State[/b]
The script uses the smoothed Momentum Curve to maintain a persistent bullish or bearish state.

On initialization:
[list]
[*]Curve >= 0 = bullish.
[*]Curve < 0 = bearish.
[/list]

After initialization, the trend only changes when the curve passes the opposite Trend Threshold.

A bullish transition requires:

[list]
[*]Curve > +Trend Threshold
[/list]

A bearish transition requires:

[list]
[*]Curve < -Trend Threshold
[/list]

Values between the positive and negative thresholds retain the existing trend state.

[b]Trend Threshold[/b]
The Trend Threshold creates a buffer around zero.

For example, with a threshold of 0.20:

[list]
[*]Above +0.20 can establish bullish state.
[*]Below -0.20 can establish bearish state.
[*]Between -0.20 and +0.20, the existing state remains unchanged.
[/list]

This prevents the trend colour from changing every time the oscillator makes a small move around zero.

Higher thresholds create more persistent trend states.

Lower thresholds respond more quickly.

[b]Oscillator Colours[/b]
The column colour changes with the magnitude and sign of the Momentum Curve.

Positive values progress through increasingly strong green shades.

Negative values progress through increasingly strong red shades.

Values beyond approximately ±2.5 are displayed in white.

These colour levels are visual references only.

They are not probability bands, confidence intervals or statistical significance thresholds.

[b]Static Zones[/b]
Optional reference zones are plotted between:

[list]
[*]+2.0 and +2.5.
[*]-2.0 and -2.5.
[/list]

These provide fixed visual context for relatively large normalized momentum readings.

They do not alter:
[list]
[*]The momentum calculation.
[*]The trend state.
[*]The alerts.
[/list]

They should be treated as user-interface reference levels rather than formal statistical boundaries.

[b]Individual Horizons[/b]
Each of the four normalized momentum components can optionally be displayed.

This makes it possible to see whether the composite is being driven by:
[list]
[*]Shorter-term momentum.
[*]Longer-term momentum.
[*]Broad agreement across all horizons.
[/list]

For example, the composite can remain positive while one shorter horizon has already turned negative.

[b]Trend Candles[/b]
Optional candles on the main chart are coloured from the persistent trend state:

[list]
[*]Bullish = green.
[*]Bearish = red.
[/list]

The candle colour represents the current oscillator regime rather than whether the individual candle itself closed higher or lower.

[b]Input Guide[/b]
[b]Horizon 1–4[/b]
Set the four return lookbacks used in the composite.

[b]Weight 1–4[/b]
Control how much influence each horizon has on the final momentum curve.

[b]Volatility Length[/b]
Controls the standard-deviation lookback used for one-bar log-return volatility.

[b]Momentum Clamp[/b]
Limits the maximum positive or negative contribution from each individual horizon.

[b]Curve Smoothing[/b]
EMA smoothing applied after combining the four horizon values.

[b]Trend Threshold[/b]
Controls how far the curve must move through zero before the persistent trend state changes.

[b]How to Read It[/b]
[b]Positive Curve[/b]
The weighted combination of normalized horizon returns is positive.

[b]Negative Curve[/b]
The weighted combination is negative.

[b]Large Positive Reading[/b]
Several horizons, or heavily weighted horizons, are showing positive returns that are large relative to the current volatility normalization.

[b]Large Negative Reading[/b]
The opposite applies for negative momentum.

[b]High Horizon Agreement[/b]
Most or all of the four lookbacks currently have the same momentum sign.

[b]Low Horizon Agreement[/b]
The horizon signals are more mixed.

[b]How to Use It[/b]
The indicator can be used as:
[list]
[*]A multi-horizon momentum oscillator.
[*]A bullish/bearish trend filter.
[*]A way to compare momentum across different lookback lengths.
[*]A way to inspect whether short- and longer-horizon momentum agree.
[/list]

The individual horizon plots and Horizon Agreement value are useful when the composite alone does not show which lookbacks are driving the result.

[b]Limitations[/b]
[list]
[*]The indicator is based entirely on current and historical price data.
[*]Positive momentum does not imply future positive returns.
[*]The volatility normalization uses one current rolling volatility estimate for all four horizons.
[*]The √N scaling is a normalization assumption and does not guarantee that volatility actually scales that way in every market condition.
[*]Extreme values are deliberately clipped before the horizons are combined.
[*]The weighting settings can materially change which horizon dominates the composite.
[*]Longer Curve Smoothing and larger Trend Thresholds increase persistence but can delay regime changes.
[*]The ±2 and ±2.5 display levels are visual reference levels rather than statistical confidence bands.
[/list]

[b]Data Window[/b]
The indicator exposes:
[list]
[*]Raw Momentum Composite.
[*]Smoothed Momentum Composite.
[*]Momentum for each of the four horizons.
[*]Horizon Agreement.
[/list]

[b]Alerts[/b]
The script includes:
[list]
[*][b]Momentum Curve Bullish:[/b] persistent trend state changes from bearish to bullish.
[*][b]Momentum Curve Bearish:[/b] persistent trend state changes from bullish to bearish.
[/list]

[b]Summary[/b]
Multi-Horizon Momentum Curve calculates log-return momentum across four lookbacks and normalizes each horizon using recent one-bar return volatility scaled by the square root of the horizon length.

The normalized values are clamped, combined using configurable weights and optionally smoothed.

Separate positive and negative thresholds convert the resulting curve into a persistent bullish or bearish state, while Horizon Agreement shows how consistently the individual lookbacks share the same direction.

The indicator is simply a way to combine and compare momentum across several time horizons on a common volatility-adjusted scale.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BackQuant

//@version=6
indicator("Multi-Horizon Momentum Curve [BackQuant]", shorttitle="Momentum Curve [BackQuant]", overlay=false)

// Constants
const string calc = "Momentum Calculation"
const string trend = "Trend Settings"
const string ui = "Plotting and Coloring"
const color GREEN = #00ff00
const color RED = #ff0000

// Inputs
float src = input.source(close, "Source", group=calc)

int len1 = input.int(5, "Horizon 1", minval=2, group=calc, inline="H1")
float w1 = input.float(1.0, "Weight", minval=0.0, step=0.1, group=calc, inline="H1")

int len2 = input.int(10, "Horizon 2", minval=2, group=calc, inline="H2")
float w2 = input.float(1.5, "Weight", minval=0.0, step=0.1, group=calc, inline="H2")

int len3 = input.int(20, "Horizon 3", minval=2, group=calc, inline="H3")
float w3 = input.float(2.25, "Weight", minval=0.0, step=0.1, group=calc, inline="H3")

int len4 = input.int(40, "Horizon 4", minval=2, group=calc, inline="H4")
float w4 = input.float(3.25, "Weight", minval=0.0, step=0.1, group=calc, inline="H4")

int volLen = input.int(30, "Volatility Length", minval=5, group=calc)
float maxMomentum = input.float(4.0, "Momentum Clamp", minval=1.0, maxval=10.0, step=0.25, group=calc)
int smoothLen = input.int(4, "Curve Smoothing", minval=1, group=calc)

float flipThreshold = input.float(0.20, "Trend Threshold", minval=0.0, maxval=3.0, step=0.05, group=trend)

bool showOsc = input.bool(true, "Show Oscillator", group=ui)
bool showHorizons = input.bool(false, "Show Individual Horizons", group=ui)
bool showStatic = input.bool(true, "Show Static Levels", group=ui)
bool paintCandles = input.bool(true, "Color Candles", group=ui)

// One-Bar Log Return
float logReturn = src > 0.0 and src[1] > 0.0 ? math.log(src / src[1]) : 0.0

// Base Realized Volatility
float sigma = ta.stdev(logReturn, volLen)

// Normalized Horizon Momentum
normalizedMomentum(float source, int length, float volatility, float clampValue) =>
    float horizonReturn = source > 0.0 and source[length] > 0.0 ? math.log(source / source[length]) : 0.0
    float expectedVol = volatility * math.sqrt(length)
    float momentum = expectedVol > 0.0 ? horizonReturn / expectedVol : 0.0
    math.max(-clampValue, math.min(clampValue, momentum))

float mom1 = normalizedMomentum(src, len1, sigma, maxMomentum)
float mom2 = normalizedMomentum(src, len2, sigma, maxMomentum)
float mom3 = normalizedMomentum(src, len3, sigma, maxMomentum)
float mom4 = normalizedMomentum(src, len4, sigma, maxMomentum)

// Weighted Multi-Horizon Curve
float totalWeight = w1 + w2 + w3 + w4
float rawCurve = totalWeight > 0.0 ? (mom1 * w1 + mom2 * w2 + mom3 * w3 + mom4 * w4) / totalWeight : 0.0
float curve = smoothLen > 1 ? ta.ema(rawCurve, smoothLen) : rawCurve

// Horizon Agreement
int bullCount = (mom1 > 0.0 ? 1 : 0) + (mom2 > 0.0 ? 1 : 0) + (mom3 > 0.0 ? 1 : 0) + (mom4 > 0.0 ? 1 : 0)
int bearCount = (mom1 < 0.0 ? 1 : 0) + (mom2 < 0.0 ? 1 : 0) + (mom3 < 0.0 ? 1 : 0) + (mom4 < 0.0 ? 1 : 0)

float agreement = math.max(bullCount, bearCount) / 4.0

// Persistent Trend State
var int trendState = 0

if trendState == 0
    trendState := curve >= 0.0 ? 1 : -1
else if trendState != 1 and curve > flipThreshold
    trendState := 1
else if trendState != -1 and curve < -flipThreshold
    trendState := -1

bool bullFlip = trendState == 1 and trendState[1] == -1
bool bearFlip = trendState == -1 and trendState[1] == 1

color trendCol = trendState == 1 ? GREEN : RED

// Oscillator Color Gradient
color plotCol = #ffffff

if curve >= 2.5 or curve <= -2.5
    plotCol := #ffffff
else if curve > 0.0
    if curve < 0.50
        plotCol := #1dcaff4d
    else if curve < 1.00
        plotCol := #1e9b254d
    else if curve < 1.50
        plotCol := #00ff004d
    else if curve < 2.00
        plotCol := #00ff0080
    else
        plotCol := #00ff00
else if curve < 0.0
    if curve > -0.50
        plotCol := #e651004d
    else if curve > -1.00
        plotCol := #7715154d
    else if curve > -1.50
        plotCol := #ff00004d
    else if curve > -2.00
        plotCol := #ff000080
    else
        plotCol := #ff0000
else
    plotCol := #ffffff4d

// Static Colors
color bullZone = #00ff003d
color bearZone = #ff00003d
color bullEdge = #00ff00fc
color bearEdge = #ff0000fc
color extremeCol = #ffffff
color midCol = #ffffff4d

// Oscillator
plot(showOsc ? curve : na, "Multi-Horizon Momentum", plotCol, 3, plot.style_columns)

// Individual Horizons
plot(showHorizons ? mom1 : na, "Horizon 1", color.new(chart.fg_color, 85), 1)
plot(showHorizons ? mom2 : na, "Horizon 2", color.new(chart.fg_color, 78), 1)
plot(showHorizons ? mom3 : na, "Horizon 3", color.new(chart.fg_color, 70), 1)
plot(showHorizons ? mom4 : na, "Horizon 4", color.new(chart.fg_color, 60), 1)

// Static Zones
pBullNormal = plot(showStatic ? 2.0 : na, "+2", bullEdge)
pBullExtreme = plot(showStatic ? 2.5 : na, "+2.5", bullEdge)

pBearNormal = plot(showStatic ? -2.0 : na, "-2", bearEdge)
pBearExtreme = plot(showStatic ? -2.5 : na, "-2.5", bearEdge)

fill(pBullNormal, pBullExtreme, bullZone, title="Bull Extreme Zone")
fill(pBearNormal, pBearExtreme, bearZone, title="Bear Extreme Zone")

hline(0.0, "Zero", midCol, hline.style_solid)

// Candles
plotcandle(
     open, high, low, close,
     "Trend Candles",
     trendCol,
     trendCol,
     true,
     bordercolor=trendCol,
     display=paintCandles ? display.all : display.none,
     force_overlay=true)

// Data Window
plot(rawCurve, "Raw Momentum Composite", display=display.data_window, editable=false)
plot(curve, "Smoothed Momentum Composite", display=display.data_window, editable=false)
plot(mom1, "Horizon 1 Momentum", display=display.data_window, editable=false)
plot(mom2, "Horizon 2 Momentum", display=display.data_window, editable=false)
plot(mom3, "Horizon 3 Momentum", display=display.data_window, editable=false)
plot(mom4, "Horizon 4 Momentum", display=display.data_window, editable=false)
plot(agreement * 100.0, "Horizon Agreement", display=display.data_window, editable=false)

// Alerts
alertcondition(bullFlip, "Momentum Curve Bullish", "Multi-Horizon Momentum Curve turned bullish on {{ticker}}")
alertcondition(bearFlip, "Momentum Curve Bearish", "Multi-Horizon Momentum Curve turned bearish on {{ticker}}")
````
