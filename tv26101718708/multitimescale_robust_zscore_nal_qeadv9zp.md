# Multi-Timescale Robust Z-Score | NAL

- url: https://www.tradingview.com/script/qeaDV9ZP-Multi-Timescale-Robust-Z-Score-NAL/
- type: indicator
- pine_id: PUB;bd601c9a9e8d4492adc74fda1de035b1
- version: 1.0

## Description

Multi-Timescale Robust Z-Score is a statistical momentum framework designed to evaluate price displacement across multiple observation horizons using [b]median-based normalization and robust dispersion estimation[/b].

Traditional Z-scores rely on the arithmetic mean and standard deviation, making their readings sensitive to extreme observations and the selection of a single lookback period.

This model addresses both limitations by calculating robust Z-scores across a structured range of historical windows and aggregating their results into one unified statistical signal.

The objective is to distinguish [b]persistent directional displacement from isolated statistical extremes[/b] while reducing dependence on any single estimation horizon.

[b]1. Robust Statistical Normalization[/b]

Each observation window independently calculates a robust measure of price displacement.

Instead of using the conventional mean and standard deviation, the model uses:

[list=1]
[*][b]Rolling Median[/b] — estimates the central tendency of price while reducing sensitivity to extreme observations.
[*][b]Median Absolute Deviation (MAD)[/b] — estimates dispersion relative to the rolling median.
[*][b]Robust Z-Score[/b] — expresses current price displacement relative to these robust statistical estimates.
[/list]

The MAD is scaled by 1.4826 to approximate standard-deviation units under a normal distribution.

[pine]float Center = array.median(WindowValues)
float MAD = array.median(Deviations)
float RobustDeviation = MAD * MADScale
float Z = RobustDeviation > 0.0 ? (Source - Center) / RobustDeviation : na[/pine]

This produces a more outlier-resistant representation of relative price displacement than a conventional mean-based Z-score.

[b]2. Multi-Timescale Architecture[/b]

Rather than relying on one arbitrarily selected lookback, the model evaluates multiple historical windows simultaneously.

The user specifies a central lookback, the number of additional windows on either side, and the spacing between them.

For example, a central length of 60, five windows on each side, and a spacing of 10 produces [b]11 independent statistical observations spanning 10 to 110 bars[/b].

Each window produces its own robust Z-score before the results are consolidated.

[i]Multi-timescale refers to multiple historical window lengths on the selected chart timeframe, not separate chart timeframes.[/i]

[b]3. Robust Aggregation[/b]

The individual Z-scores are combined into a single composite reading using one of two methods:

[list=1]
[*][b]Median Aggregation[/b] — the default configuration, designed to reduce the influence of unusually extreme readings from individual windows.
[*][b]Mean Aggregation[/b] — provides an arithmetic consensus across the complete window structure.
[/list]

[pine]float MedianZ = ModelReady ? array.median(ZValues) : na
float MeanZ = ModelReady ? array.avg(ZValues) : na

float RobustZ = Aggregation == "Median" ? MedianZ : MeanZ[/pine]

The model only produces its final composite once every configured window has sufficient valid observations.

[b]4. Directional State Classification[/b]

The aggregated Z-score is evaluated against configurable directional thresholds.

[list=1]
[*][b]Bullish[/b] — the composite Z-score reaches or exceeds the upper threshold.
[*][b]Neutral[/b] — the composite remains between the directional thresholds.
[*][b]Bearish[/b] — the composite Z-score reaches or falls below the lower threshold.
[/list]

The neutral state can be disabled, allowing the model to preserve its previous bullish or bearish classification until the opposing threshold is reached.

Because thresholds are independently configurable, a bearish classification does not necessarily require a negative Z-score. It represents the model's position relative to the selected directional boundaries.

[b]Visuals & Interpretation[/b]

The indicator displays the aggregated robust Z-score as a continuously updated oscillator, with colors reflecting the prevailing directional state.

Additional visualization features include:

[list=1]
[*]Dynamic bullish, bearish, and neutral coloration
[*]Configurable directional threshold lines
[*]Zero-centered statistical reference
[*]Optional comparison between median and mean aggregation
[*]Trend-colored candles on the main chart
[*]Standard, Nordic, and Simple color presets
[/list]

[b]Practical Application[/b]

The central advantage of the model is its ability to evaluate whether statistical displacement is [b]consistent across multiple observation horizons[/b], rather than being disproportionately influenced by one lookback or a small number of extreme price observations.

By combining robust statistics with multi-window aggregation, the indicator provides a structured measure of [b]relative momentum, statistical extension, and directional market state[/b].

At its core, the model asks:

[i]Is the observed price displacement supported across multiple statistical horizons, or is it primarily a consequence of a narrow estimation window?[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NordicAlphaLab

//@version=6
indicator("Multi-Timescale Robust Z-Score | NAL", "Robust Z-Score | NAL", overlay = false, format = format.price, precision = 2, max_bars_back = 1100)

//                                     ███╗   ██╗ █████╗ ██╗
//                                     ████╗  ██║██╔══██╗██║
//                                     ██╔██╗ ██║███████║██║
//                                     ██║╚██╗██║██╔══██║██║
//                                     ██║ ╚████║██║  ██║███████╗
//                                     ╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝

// ══════════════════════════════════════ ◈ Parameters ◈ ══════════════════════════════════════

string group_parameters = "Parameters"
string group_visuals = "Visuals"

float Source = input.source(close, "Source", group = group_parameters)
int BasisLength = input.int(60, "Z-Score Length", minval = 2, maxval = 500, group = group_parameters, tooltip = "Central lookback length used as the basis for all robust Z-score windows.")
int Windows = input.int(5, "Windows", minval = 1, maxval = 5, group = group_parameters, tooltip = "Number of additional windows generated on each side of the basis length. Total windows = 2 × Windows + 1.", inline = "MULTI")
int Spread = input.int(10, "Spread", minval = 1, maxval = 100, group = group_parameters, tooltip = "Distance in bars between each neighboring Z-score window.", inline = "MULTI")
string Aggregation = input.string("Median", "Aggregation", options = ["Median", "Mean"], group = group_parameters, tooltip = "Median is the robust default. Mean is available for comparison.")

float LongThreshold = input.float(1.50, "Long Threshold", step = 0.05, group = group_parameters, tooltip = "Robust Z-Score must be at or above this level for the bullish state.")
float ShortThreshold = input.float(0.50, "Short Threshold", step = 0.05, group = group_parameters, tooltip = "Robust Z-Score must be at or below this level for the bearish state.")

bool UseNeutralState = input.bool(true, "Use Neutral State", group = group_parameters, tooltip = "When enabled, readings between the Long and Short thresholds are neutral. When disabled, the indicator retains the most recent Long or Short state until the opposite threshold is reached.")

// ══════════════════════════════════════ ◈ Visuals ◈ ══════════════════════════════════════

string col_mode = input.string("Standard", title = "Color Mode", group = group_visuals, options = ["Standard", "Nordic", "Simple"])

[col_up, col_dn, col_nu] = switch col_mode
    "Standard" => [color.rgb(0, 255, 200), color.rgb(32, 94, 144), color.gray]
    "Nordic"   => [color.rgb(46, 161, 255), color.rgb(150, 154, 169), color.gray]
    "Simple"   => [color.lime, color.red, color.gray]

bool ShowAlternative = input.bool(false, "Show Alternate Aggregate", group = group_visuals)
bool ShowThresholds = input.bool(true, "Show Trend Thresholds", group = group_visuals)

color col_label = color.rgb(105, 125, 145)
color col_value = color.rgb(235, 245, 255)

// ══════════════════════════════════════ ◈ Validation ◈ ══════════════════════════════════════

int ShortestLength = BasisLength - Windows * Spread
int TotalWindows = Windows * 2 + 1

if ShortestLength < 2
    runtime.error("Window configuration is invalid. Z-Score Length - (Windows × Spread) must be at least 2.")

if LongThreshold <= ShortThreshold
    runtime.error("Long Threshold must be greater than Short Threshold.")

// ══════════════════════════════════════ ◈ Robust Z-Score ◈ ══════════════════════════════════════

// Robust center = median.
// Robust deviation = 1.4826 × MAD.
// 1.4826 scales MAD to approximate standard-deviation units under a normal distribution.

float MADScale = 1.4826

var array<float> WindowValues = array.new_float(0)
var array<float> Deviations = array.new_float(0)
var array<float> ZValues = array.new_float(0)

array.clear(ZValues)

for WindowIndex = -Windows to Windows
    int Length = BasisLength + WindowIndex * Spread

    array.clear(WindowValues)

    bool WindowReady = bar_index >= Length - 1

    if WindowReady
        for i = 0 to Length - 1
            float Value = Source[i]

            if na(Value)
                WindowReady := false
                

            array.push(WindowValues, Value)

    if WindowReady
        float Center = array.median(WindowValues)

        array.clear(Deviations)

        for i = 0 to array.size(WindowValues) - 1
            float Value = array.get(WindowValues, i)
            array.push(Deviations, math.abs(Value - Center))

        float MAD = array.median(Deviations)
        float RobustDeviation = MAD * MADScale
        float Z = RobustDeviation > 0.0 ? (Source - Center) / RobustDeviation : na

        if not na(Z)
            array.push(ZValues, Z)

// ══════════════════════════════════════ ◈ Multi-Timescale Aggregation ◈ ══════════════════════════════════════

int ValidWindows = array.size(ZValues)
bool ModelReady = ValidWindows == TotalWindows

float MedianZ = ModelReady ? array.median(ZValues) : na
float MeanZ = ModelReady ? array.avg(ZValues) : na

float RobustZ = Aggregation == "Median" ? MedianZ : MeanZ
float AlternateZ = Aggregation == "Median" ? MeanZ : MedianZ

// ══════════════════════════════════════ ◈ Trend State ◈ ══════════════════════════════════════

//  1 = Long
//  0 = Neutral
// -1 = Short
//
// With Neutral State disabled, the state only changes when the opposite
// threshold is reached. A reading between thresholds retains the last signal.

var int TrendState = 0

if ModelReady
    if RobustZ >= LongThreshold
        TrendState := 1
    else if RobustZ <= ShortThreshold
        TrendState := -1
    else if UseNeutralState
        TrendState := 0

bool LongState = ModelReady and TrendState == 1
bool ShortState = ModelReady and TrendState == -1

color ZColor = not ModelReady ? col_nu : LongState ? col_up : ShortState ? col_dn : col_nu

// ══════════════════════════════════════ ◈ Plots ◈ ══════════════════════════════════════

RobustPlot = plot(RobustZ, "Multi-Timescale Robust Z-Score", color = ZColor, linewidth = 2)
ZeroPlot = plot(0.0, "Zero", color = color.new(col_value, 85), linewidth = 1)

plot(ShowAlternative ? AlternateZ : na, "Alternate Aggregate", color = color.new(col_label, 45), linewidth = 1)

fill(RobustPlot, ZeroPlot, color = color.new(ZColor, 88), title = "Robust Z-Score Fill")

plotcandle(open, high, low, close, "Candles", color = ZColor, wickcolor = ZColor, bordercolor = ZColor, display = display.pane, force_overlay = true)

// ══════════════════════════════════════ ◈ Trend Thresholds ◈ ══════════════════════════════════════

// hline colors must remain const/input qualified.
// Separate constant-colored hlines preserve the NAL Color Mode without
// passing switch-derived simple colors into hline().

hline(ShowThresholds and col_mode == "Standard" ? LongThreshold : na, "Long Threshold - Standard", color = color.rgb(0, 255, 200), linestyle = hline.style_dashed)
hline(ShowThresholds and col_mode == "Standard" ? ShortThreshold : na, "Short Threshold - Standard", color = color.rgb(32, 94, 144), linestyle = hline.style_dashed)

hline(ShowThresholds and col_mode == "Nordic" ? LongThreshold : na, "Long Threshold - Nordic", color = color.rgb(46, 161, 255), linestyle = hline.style_dashed)
hline(ShowThresholds and col_mode == "Nordic" ? ShortThreshold : na, "Short Threshold - Nordic", color = color.rgb(150, 154, 169), linestyle = hline.style_dashed)

hline(ShowThresholds and col_mode == "Simple" ? LongThreshold : na, "Long Threshold - Simple", color = color.lime, linestyle = hline.style_dashed)
hline(ShowThresholds and col_mode == "Simple" ? ShortThreshold : na, "Short Threshold - Simple", color = color.red, linestyle = hline.style_dashed)
````
