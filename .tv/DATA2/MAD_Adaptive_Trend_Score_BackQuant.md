<!-- tradingview-pine-id: PUB;7fe73986cad0424eb9482c001bc67ff9 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# MAD Adaptive Trend Score [BackQuant]

Source: https://www.tradingview.com/script/PlQjuEoQ-MAD-Adaptive-Trend-Score-BackQuant/

## Description

MAD Adaptive Trend Score [BackQuant]

Overview
MAD Adaptive Trend Score is a trend oscillator built from a Median Absolute Deviation-based price filter and a multi-lookback relative-position score.

The indicator first calculates a rolling median and MAD from the selected source. Price deviation from the median is then clipped to a configurable MAD envelope, producing the MAD Adaptive Filter.

The current value of that filtered series is then compared with a range of its previous values. Each comparison contributes either +1 or -1 to a Trend Score.

The result is a bounded directional score that can be used with separate bullish and bearish thresholds to create a persistent trend state.

The script includes:

[*]Exact rolling median and MAD calculations.
[*]MAD-based clipping of source movement.
[*]Configurable multi-lookback Trend Score.
[*]Separate long and short regime thresholds.
[*]Optional filter overlay on the main chart.
[*]Trend candle colouring and signals.
[*]Reference levels and alerts.

MAD Adaptive Filter
The first stage calculates the rolling median of the selected Source over the MAD Length.

It then calculates Median Absolute Deviation:

[*]MAD = Median(|X - Median(X)|)

Raw MAD is multiplied by 1.4826:

[*]Scaled MAD = Raw MAD × 1.4826

with a minimum value based on the instrument's minimum tick.

The 1.4826 factor is commonly used to scale MAD to approximately the same scale as standard deviation when the underlying distribution is normal.

The indicator then measures:

[*]Deviation = Source - Rolling Median

and defines the maximum permitted deviation as:

[*]Maximum Deviation = Scaled MAD × MAD Multiplier

The source deviation is clipped to this range before being added back to the median.

Conceptually:

[*]If Source remains inside the MAD envelope, the filter follows Source.
[*]If Source moves above the envelope, the filter is limited to the upper MAD boundary.
[*]If Source moves below the envelope, the filter is limited to the lower MAD boundary.

The MAD Adaptive Filter is therefore not a conventional moving average. It is a source series whose distance from its rolling median is limited by the current MAD-derived envelope.

MAD Multiplier
MAD Multiplier controls the permitted distance between the filtered value and the rolling median.

Lower values:

[*]Create a tighter envelope.
[*]Clip more of the source movement.
[*]Keep the filter closer to the median.

Higher values:

[*]Create a wider envelope.
[*]Allow more source movement through unchanged.
[*]Make the filter follow price more closely.

Trend Score
The second stage scores the current MAD Filter against several previous values of the same filtered series.

For every lookback between Score Lookback Start and End:

[*]+1 if the current MAD Filter is above the historical MAD Filter.
[*]-1 otherwise.

The final Trend Score is the sum of all comparisons.

If N historical values are being compared, the theoretical score range is:

[*]-N to +N

For the default 1-to-45 range, 45 comparisons are made, so the score can range from -45 to +45.

What the score represents
A high positive score means the current MAD-filtered value is above most of the historical filtered values being compared.

A strongly negative score means it is above very few of them.

For example, with 45 comparisons:

[*]A score near +45 means the current filtered value is above nearly the entire comparison range.
[*]A score near 0 means the comparisons are more evenly divided.
[*]A score near -45 means the current filtered value is below, or equal to, nearly all of them.

The score is therefore best understood as a relative position / trend score of the filtered series.

It is not a return forecast or probability of future direction.

Why use several lookbacks?
Comparing the current filter with only one previous value would effectively reduce the calculation to short-term slope.

Using many previous values instead measures where the current filtered level sits relative to a broader section of its history.

A steadily rising filtered series will generally move toward higher positive scores because the current value becomes greater than an increasing number of historical values.

During sustained weakness, the opposite occurs.

Score Lookback Start and End
These settings define which historical MAD Filter values participate in the score.

For example:

[*]Start = 1
[*]End = 45

compares the current filter against each filtered value from 1 through 45 bars ago.

A shorter range:

[*]Responds more quickly to recent changes.
[*]Creates a smaller score range.

A longer range:

[*]Includes more historical comparisons.
[*]Produces a broader measure of relative trend position.
[*]Usually changes more gradually.

Because the score range depends on the number of comparisons, threshold settings should be chosen with the selected score range in mind.

Trend State
The script converts the Trend Score into a persistent bullish or bearish signal state.

The bullish and bearish rules are deliberately separate.

Bullish condition
The signal becomes bullish when:

[*]Trend Score > Long Threshold

Once bullish, the state remains bullish until a valid bearish condition occurs.

Bearish condition
The signal becomes bearish when the score crosses downward through the Short Threshold:

[*]Previous Score >= Short Threshold
[*]Current Score < Short Threshold

The bearish condition therefore requires an actual downward threshold crossing rather than simply remaining below the level.

Why use separate thresholds?
Using different bullish and bearish levels introduces persistence into the regime.

The signal does not need to reverse whenever the score crosses zero.

For example, with:

[*]Long Threshold = 40
[*]Short Threshold = -6

the score must reach a strongly positive state before the model turns bullish, but the bullish state can persist through a substantial amount of score deterioration before a bearish transition occurs.

This creates a form of threshold hysteresis and reduces rapid switching around a single center level.

The thresholds are fully configurable and do not need to be symmetrical.

Initial state
The signal begins neutral.

A bullish state can be established once the Long Threshold condition is satisfied.

A bearish state requires a valid downward crossing of the Short Threshold.

Signal markers are shown only when an established bullish state changes to bearish or an established bearish state changes to bullish.

The initial transition from neutral does not produce a long/short marker.

Reference Lines
The optional dashed reference lines display the Long and Short Thresholds directly in the oscillator pane.

These levels correspond to the actual regime settings and can be useful when visually tracking how the Trend Score approaches a possible state change.

MAD Filter Overlay
The MAD Adaptive Filter can optionally be plotted directly on the main price chart.

This makes it possible to compare:

[*]Raw price.
[*]The rolling-median/MAD envelope response.
[*]The active trend colour.

The overlay uses the same bullish or bearish state colour as the oscillator.

Trend Candles
Optional chart candles are coloured from the stored trend state:

[*]Bullish state = Long Color.
[*]Bearish state = Short Color.

The colour represents the indicator's trend regime rather than the direction of each individual candle.

Background Colour
An optional transparent background can also display the current trend regime on the main chart.

This is purely visual and does not alter the calculation.

How to interpret it

Strong positive score
The current MAD Filter is above most values in the selected historical comparison range.

This typically accompanies a relatively strong upward position in the filtered trend.

Falling score while still bullish
The filtered trend is losing relative strength, but the Short Threshold has not yet been crossed.

The persistent state therefore remains bullish.

Short Threshold crossing
The score has deteriorated far enough to cross below the selected bearish boundary, changing the stored state to bearish.

Rising score while bearish
The score can recover substantially while the trend remains bearish.

A new bullish state is not established until the score exceeds the Long Threshold.

How to use the indicator
The indicator can be used as:

[*]A directional trend filter.
[*]A persistent bullish/bearish regime indicator.
[*]A way to measure the relative position of a MAD-filtered price series.
[*]A confirmation tool alongside other price or market-structure analysis.

The score itself can also provide additional context beyond the binary trend colour.

For example, a bullish regime with a score near its maximum is different from a bullish regime whose score has already fallen substantially toward the bearish threshold.

Input Guide
MAD Length
Controls the rolling sample used to calculate the median and Median Absolute Deviation.

Shorter values adapt more quickly.

Longer values produce a broader statistical reference window.

MAD Multiplier
Controls how far the filtered source may move away from its rolling median.

Lower values produce stronger clipping.

Higher values allow the filter to follow Source more closely.

Score Lookback Start / End
Defines the historical MAD Filter values used in the Trend Score comparisons.

Long Threshold
Score level that must be exceeded to establish a bullish state.

Short Threshold
Level that must be crossed downward to establish a bearish state.

Data Window
The script exposes:

[*]Rolling Median.
[*]Raw MAD.
[*]Scaled MAD.

These values can help show how the underlying MAD filter is being constructed.

Limitations

[*]The indicator is reactive rather than predictive.
[*]The score measures the current filtered value relative to historical filtered values; it does not estimate future returns.
[*]Threshold selection can materially change signal frequency and persistence.
[*]A very tight MAD Multiplier can suppress meaningful movement along with noise.
[*]A very wide MAD Multiplier makes the filter increasingly similar to the original Source.
[*]Long score ranges can improve persistence but also delay changes in regime.
[*]Strong trends can keep the score near an extreme for extended periods.

Alerts
The script includes:

[*]MAD Trend Score Long: stored signal changes from bearish to bullish.
[*]MAD Trend Score Short: stored signal changes from bullish to bearish.

Summary
MAD Adaptive Trend Score combines two simple ideas.

First, the selected Source is constrained around a rolling median using Median Absolute Deviation. Source movement inside the MAD envelope passes through normally, while movement beyond the envelope is clipped to the current boundary.

Second, the current filtered value is compared with a configurable range of its own historical values.

Those comparisons are summed into a Trend Score, with positive values indicating that the current filtered level is above more of the historical comparison range and negative values indicating the opposite.

Separate Long and Short Thresholds then convert the score into a persistent bullish or bearish regime.

The result is a MAD-based filtered series and relative-position trend score for experimenting with trend persistence and threshold behaviour.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BackQuant

//@version=6
indicator("MAD Adaptive Trend Score [BackQuant]", shorttitle = "MAD Trend Score [BackQuant]", overlay=false)

// Constants
const string calc  = "Core Calculation Settings"
const string thres = "Signal Settings"
const string ui    = "Plotting and Coloring"
const color GREEN  = #00ff00
const color RED    = #ff0000

// Inputs
float src = input.source(close, "Source", group=calc)
int madLen = input.int(15, "MAD Length", minval=3, group=calc, tooltip="Length used for the rolling median and Median Absolute Deviation.")
float madMult = input.float(5.2, "MAD Multiplier", minval=0.1, step=0.1, group=calc, tooltip="Controls how far price may move away from the rolling median. Lower values suppress more noise. Higher values follow price more closely.")
int scoreStart = input.int(1, "Score Lookback Start", inline="SL", group=calc)
int scoreEnd = input.int(45, "End", maxval=50, inline="SL", group=calc, tooltip="Range of bars used for the directional persistence score.")

bool showRefs = input.bool(true, "Show Reference Lines", group=thres)
bool showSignals = input.bool(true, "Show Signals on Chart?", group=thres)
int longThres = input.int(40, "Long Threshold", group=thres, inline="TH")
int shortThres = input.int(-6, "Short Threshold", group=thres, inline="TH")

color longCol = input.color(GREEN, "Long Color", group=ui, inline="col")
color shortCol = input.color(RED, "Short Color", group=ui, inline="col")
int lineW = input.int(5, "Line Width", group=ui)
bool showSmooth = input.bool(false, "Show MAD Filter on Chart?", group=ui)
bool paintCandles = input.bool(true, "Paint Candles to Trend?", group=ui)
bool bgCol = input.bool(false, "Background Color?", group=ui)

// Helpers
method transp(color x, int t) =>
    color.new(x, t)

/////////////////////////////////////////////////////////////// © BackQuant ///////////////////////////////////////////////////////////////

// Exact Rolling Median + MAD
madStats(float source, simple int length) =>
    array<float> values = array.new_float()

    for i = 0 to length - 1
        if not na(source[i])
            array.push(values, source[i])

    float median = array.size(values) > 0 ? array.median(values) : na
    array<float> deviations = array.new_float()

    if not na(median)
        for i = 0 to array.size(values) - 1
            array.push(deviations, math.abs(array.get(values, i) - median))

    float mad = array.size(deviations) > 0 ? array.median(deviations) : na
    [median, mad]

/////////////////////////////////////////////////////////////// © BackQuant ///////////////////////////////////////////////////////////////

// MAD Calculation
[medianValue, rawMad] = madStats(src, madLen)

// Scale MAD to a standard-deviation-like measure
float scaledMad = math.max(rawMad * 1.4826, syminfo.mintick)

// Allow price to move around the median only within the MAD envelope
float deviation = src - medianValue
float maxDeviation = scaledMad * madMult
float clippedDeviation = math.max(-maxDeviation, math.min(maxDeviation, deviation))

// MAD Adaptive Filter
float madFilt = medianValue + clippedDeviation

/////////////////////////////////////////////////////////////// © BackQuant ///////////////////////////////////////////////////////////////

// Score the MAD filter's directional persistence
float scoreS = 0.0

for i = scoreStart to scoreEnd
    scoreS += madFilt > madFilt[i] ? 1.0 : -1.0

// Signal State
var int signal = 0

float prevScore = nz(scoreS[1], scoreS)
bool longCond = scoreS > longThres
bool shortCond = prevScore >= shortThres and scoreS < shortThres

if longCond and not shortCond
    signal := 1
else if shortCond
    signal := -1

// Color State
color col = signal == 1 ? longCol : shortCol

/////////////////////////////////////////////////////////////// © BackQuant ///////////////////////////////////////////////////////////////
// Plotting

// Score line in pane
plot(scoreS, "Trend Score", col, lineW)

// Reference lines
if barstate.islast and showRefs
    line.new(last_bar_index, longThres, bar_index - 1, longThres, color=chart.fg_color.transp(50), style=line.style_dashed, extend=extend.right)
    line.new(last_bar_index, shortThres, bar_index - 1, shortThres, color=chart.fg_color.transp(50), style=line.style_dashed, extend=extend.right)

// MAD Filter on chart
plot(madFilt, "MAD Adaptive Filter", col, 2, plot.style_line, force_overlay=true,
     display=showSmooth ? display.all : display.none)

// Candle painting
plotcandle(open, high, low, close, "Trend Candles",
     col, col, true,
     bordercolor=col,
     display=paintCandles ? display.all : display.none, force_overlay=true)

// Background
bgcolor(bgCol ? col.transp(80) : na, force_overlay=true)

// Signals
plotshape(signal == 1 and signal[1] == -1, "Long Signal", shape.triangleup, location.belowbar, longCol, 0, "𝕃", longCol, true, size.small,
     display=showSignals ? display.all : display.none, force_overlay=true)

plotshape(signal == -1 and signal[1] == 1, "Short Signal", shape.triangledown, location.abovebar, shortCol, 0, "𝕊", shortCol, true, size.small,
     display=showSignals ? display.all : display.none, force_overlay=true)

/////////////////////////////////////////////////////////////// © BackQuant ///////////////////////////////////////////////////////////////
// Data Window

plot(medianValue, "Rolling Median", display=display.data_window)
plot(rawMad, "Raw MAD", display=display.data_window)
plot(scaledMad, "Scaled MAD", display=display.data_window)

/////////////////////////////////////////////////////////////// © BackQuant ///////////////////////////////////////////////////////////////
// Alerts

alertcondition(signal == 1 and signal[1] == -1, title="MAD Trend Score Long", message="MAD Adaptive Trend Score Long {{exchange}}:{{ticker}}")
alertcondition(signal == -1 and signal[1] == 1, title="MAD Trend Score Short", message="MAD Adaptive Trend Score Short {{exchange}}:{{ticker}}")
````
