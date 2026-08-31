<!-- tradingview-pine-id: PUB;aeb1fb51a8c34471ae2c9ae57fdef0d4 -->
<!-- tradingviewscripts-format: 1 -->
# MACD Momentum Phase & Acceleration Observatory

Source: https://www.tradingview.com/script/4oyJ1CNc-MACD-Momentum-Phase-Acceleration-Observatory/

## Description

MACD Momentum Phase & Acceleration Observatory is a current-chart momentum research indicator that extends the familiar MACD line, Signal line, and Histogram into a structured view of separation, expansion, contraction, equilibrium, relative magnitude, and crossover-cycle behavior.

The script is designed for users who want to study how MACD momentum changes rather than rely only on a line crossover. It is a descriptive context tool. It does not generate Buy or Sell instructions, predict future price movement, estimate win rate, or manage risk.

WHAT IT SHOWS

- A configurable MACD line, Signal line, and state-colored Histogram.
- Five descriptive momentum phases.
- A noise-aware expansion and contraction model.
- An adaptive Near Equilibrium state with separate entry and exit boundaries.
- Three display scales: Raw MACD, Percent of Slow Average, and ATR Units.
- A robust rolling Histogram magnitude score.
- A subdued-to-reactivated magnitude sequence.
- Cross-cycle peak retention.
- MACD path efficiency.
- A compact or detailed context readout.
- Optional factual event markers and alert conditions.

WHY THIS IS MORE THAN A STANDARD MACD

A standard MACD primarily shows the relationship between a fast moving average, a slow moving average, and a smoothed Signal line. This script keeps that familiar structure, but its main contribution is a coordinated lifecycle model built around the MACD Histogram.

The distinguishing design consists of:

- separating the raw analytical engine from display normalization;
- classifying the Histogram into five momentum phases;
- filtering small expansion/contraction changes with an adaptive noise deadband;
- reducing equilibrium-boundary flapping with entry/exit hysteresis;
- measuring relative Histogram magnitude with rank-based methods;
- tracking reactivation after a sustained subdued sequence;
- measuring how much Histogram separation remains inside the active crossover cycle; and
- measuring whether the MACD path has been direct or rotational over a selected lookback.

These components are designed to describe different parts of one MACD separation lifecycle. They are not independent indicators combined without a shared purpose.

CORE MACD ENGINE

The raw calculations are:

Raw MACD = Fast Moving Average - Slow Moving Average
Raw Signal = Moving Average of Raw MACD
Raw Histogram = Raw MACD - Raw Signal

The Fast, Slow, and Signal calculations can each use one of the following moving-average methods:

- EMA
- SMA
- RMA
- WMA
- HMA

The source and all lengths are configurable. Fast Length must remain lower than Slow Length. If the configuration is invalid or the selected scale is unavailable, the context readout reports the condition instead of presenting a normal Ready state.

RAW ANALYTICAL CORE AND DISPLAY SCALE

The analytical state is calculated from the raw MACD structure. Display normalization is handled separately.

Available display modes are:

Raw MACD
Shows the MACD components in their native chart-price units.

Percent of Slow Average
Divides MACD, Signal, and Histogram by one percent of the absolute Slow Average value.

ATR Units
Divides MACD, Signal, and Histogram by the current ATR value using the selected ATR length.

The same positive divisor is applied to all three displayed components on each bar. More importantly, crossover events, zero crossings, phase classification, magnitude scoring, path efficiency, and cycle retention are calculated from the raw series. Changing the display mode therefore changes the visual unit, but it does not rewrite the underlying analytical event history.

FIVE-STATE MOMENTUM PHASE MODEL

The Histogram is classified into five descriptive states:

Positive Expansion
The raw Histogram is above zero and its absolute magnitude is expanding beyond the adaptive noise deadband.

Positive Contraction
The raw Histogram is above zero and its absolute magnitude is contracting.

Negative Expansion
The raw Histogram is below zero and its absolute magnitude is expanding.

Negative Contraction
The raw Histogram is below zero and its absolute magnitude is contracting.

Near Equilibrium
The absolute raw Histogram is inside the adaptive equilibrium boundary.

Expansion and contraction are based on the smoothed one-bar change in absolute Histogram magnitude. The script also estimates ordinary recent one-bar magnitude movement. That estimate creates an adaptive deadband. When the current magnitude change is too small to distinguish clearly from recent noise, the prior motion state is retained instead of forcing another Expansion/Contraction switch.

ADAPTIVE EQUILIBRIUM WITH HYSTERESIS

The equilibrium entry boundary is calculated from an EMA of the absolute raw Histogram multiplied by the Equilibrium Band Multiplier.

Once Near Equilibrium is active, the exit boundary is wider than the entry boundary:

Exit Boundary = Entry Boundary x Equilibrium Exit Hysteresis

Using separate entry and exit boundaries reduces rapid state changes when the Histogram repeatedly moves just above and below one threshold.

HISTOGRAM ACCELERATION

Histogram Acceleration is the smoothed one-bar change of the Histogram. The detailed readout can display the current value and direction. Optional acceleration-turn markers and alerts identify factual zero crossings in the raw acceleration measure.

The acceleration value shown in the readout follows the selected display unit. The five-state phase model remains based on the raw Histogram structure.

ROBUST HISTOGRAM MAGNITUDE SCORE

The Magnitude field measures the current absolute raw Histogram relative to its own recent history. It is bounded from 0 to 100 and offers three methods:

Percent Rank
Ranks the current absolute Histogram among observations in the selected lookback. This method is less dominated by one isolated extreme value.

Range Rank
Locates the current absolute Histogram between the rolling minimum and rolling maximum.

Hybrid Rank
Combines 65 percent Percent Rank with 35 percent Range Rank. This is the default method.

The score is classified as:

- Subdued
- Typical
- Extended

These labels describe relative recent magnitude only. They are not probabilities, confidence levels, overbought/oversold signals, or forecasts.

MAGNITUDE REACTIVATION

Magnitude Reactivation is a stateful sequence, not a directional trade signal.

The sequence works as follows:

1. The Magnitude score remains at or below the Subdued threshold for at least the selected Minimum Subdued Bars.
2. The reactivation condition becomes armed.
3. A reactivation event is recorded when the score reaches the Magnitude Reactivation threshold.

The default visual marker is a small yellow dot at the top of the pane. It indicates that relative Histogram magnitude has re-emerged after a sustained subdued sequence. It does not specify bullish or bearish direction.

CROSS-CYCLE PEAK RETENTION

A cross cycle begins whenever the raw MACD line crosses the raw Signal line.

During the active cycle, the script records the largest absolute raw Histogram magnitude. Cross-Cycle Peak Retention is calculated as:

Current Absolute Histogram / Active-Cycle Peak Absolute Histogram x 100

A value near 100 means the current separation is near the largest separation recorded in that crossover cycle. A lower value means more of that cycle's peak separation has contracted. This measurement is descriptive and does not determine whether price will continue or reverse.

MACD PATH EFFICIENCY

MACD Path Efficiency compares the net displacement of the raw MACD line with the total distance traveled by the raw MACD line over the selected lookback:

Absolute Net MACD Displacement / Sum of Absolute One-Bar MACD Changes x 100

A higher value describes a more direct MACD path. A lower value describes a more rotational or back-and-forth path. It is not a measure of profitability, trend quality, or future reliability.

CONTEXT READOUT

The Context Readout can be disabled or shown in Compact or Detailed mode.

Compact mode shows:

- Phase
- Location relative to zero
- Histogram value
- Magnitude score and state
- Configuration status

Detailed mode additionally shows:

- Histogram Acceleration
- Phase Age
- Bars in the active cross cycle and Peak Retention
- MACD Path Efficiency
- Confirmed or Live bar status

The table position, text size, header size, background, border, and row presentation are configurable.

VISUAL DESIGN

The default palette separates the line family from the Histogram family:

- MACD line: ice white
- Signal line: electric blue
- Positive Expansion: bright green
- Positive Contraction: teal
- Negative Expansion: magenta
- Negative Contraction: orange
- Near Equilibrium: vivid purple
- Magnitude Reactivation: yellow

The Histogram uses a depth layer and a narrower core layer. The MACD and Signal lines can use optional glow and separation fill. The adaptive equilibrium band, zero guide, phase rail, and background tint can be enabled or disabled independently.

EVENT MARKERS AND ALERTS

Default factual markers are:

- a small upward arrow at the pane bottom when MACD crosses above Signal;
- a small downward arrow at the pane top when MACD crosses below Signal; and
- a small yellow dot at the pane top when Magnitude Reactivation occurs.

Optional markers are available for:

- Histogram Acceleration turning positive or negative; and
- MACD crossing above or below zero.

Alert conditions are available for the same events and for each phase transition. These events describe calculated state changes. They are not trade-entry or trade-exit recommendations.

REALTIME AND CONFIRMED-BAR BEHAVIOR

Confirmed Bars Only is enabled by default.

With the default setting:

- markers and alert conditions trigger after the chart bar closes;
- stateful Magnitude Reactivation updates are committed on confirmed realtime bars; and
- the committed cross-cycle peak is updated on confirmed realtime bars.

The MACD lines, Histogram, phase display, and context readout can still change while the current bar is forming because their inputs change with live price. This is normal realtime behavior. Users who disable Confirmed Bars Only intentionally allow intrabar events, which can change before the bar closes.

The script uses the current chart timeframe only. It does not request another symbol or timeframe, use lookahead, access future data, or apply a future plot offset.

HOW TO USE THE INDICATOR

1. Start with Location and Phase.
Location shows whether raw MACD is above or below zero. Phase shows whether Histogram magnitude is expanding, contracting, or near equilibrium.

2. Add Magnitude context.
Use Subdued, Typical, and Extended as rolling relative-magnitude descriptions. Do not interpret them as probabilities.

3. Observe reactivation after subdued conditions.
A yellow dot identifies a transition from a sustained subdued sequence to a higher relative magnitude. Read its direction from the Histogram sign and phase, not from the dot itself.

4. Use Detailed mode for lifecycle context.
Phase Age shows duration. Cross-Cycle Peak Retention shows how much separation remains relative to the active cycle peak. Path Efficiency shows whether the MACD path has been direct or rotational.

5. Select a suitable display unit.
Raw MACD preserves native units. Percent of Slow Average and ATR Units can make the pane easier to read on symbols with different price or volatility scales. Analytical states remain based on raw MACD.

DEFAULT CONFIGURATION

The default core uses 12-period EMA, 26-period EMA, and a 9-period EMA Signal line with Close as the source.

The default research settings use:

- Raw MACD display
- 3-bar acceleration smoothing
- 8-bar phase-noise estimation
- 0.25 phase-noise multiplier
- 34-bar adaptive equilibrium basis
- 0.28 equilibrium entry multiplier
- 1.25 equilibrium exit hysteresis
- 120-bar Hybrid Magnitude Rank
- 20 / 35 / 80 Subdued, Reactivation, and Extended thresholds
- 3 Minimum Subdued Bars
- 20-bar MACD Path Efficiency
- Compact Context Readout
- Confirmed Bars Only enabled

The defaults are general starting points, not optimized settings for a specific symbol or timeframe.

LIMITATIONS

- MACD is derived from moving averages and therefore contains lag.
- Expansion, contraction, equilibrium, magnitude, retention, and efficiency describe the current and historical calculation state; they do not forecast price.
- Results depend on the selected source, moving-average methods, lengths, smoothing, lookbacks, and thresholds.
- Rank-based measurements are relative to a rolling window and can change as old observations leave that window.
- Frequent MACD/Signal crossings create shorter cross cycles and can make Peak Retention change quickly.
- Low-liquidity symbols, gaps, abrupt price changes, and very short timeframes can produce rapid state transitions.
- The open bar remains fluid until it closes.
- The script does not include position sizing, stop placement, targets, backtesting, or risk management.

Use the indicator as one transparent source of momentum context alongside independent price analysis and risk controls.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ©SG_Group

//@version=6

// Attribution and correction notice:
// A prior version included an optional ATR-normalized MACD display. Following
// feedback from Alex Spiroglou, originator of "MACD-V: Volatility Normalised
// Momentum" (2022), that option has been removed in full to avoid ambiguity or
// reliance on the MACD-V concept. This script does not implement MACD/ATR
// normalization, MACD-V ranges, trend-regime filters, the Momentum Lifecycle
// RoadMap, or associated MACD-V techniques. MACD is attributed to Gerald Appel.

indicator(
     "MACD Momentum Phase & Acceleration Observatory",
     overlay = false,
     format = format.inherit,
     precision = 4)

//------------------------------------------------------------------------------
// Constants and reusable helpers
//------------------------------------------------------------------------------
const float EPSILON = 1e-10

f_clamp(float value, float lowerBound, float upperBound) =>
    math.max(lowerBound, math.min(upperBound, value))

f_safe_div(float numerator, float denominator) =>
    not na(numerator) and not na(denominator) and math.abs(denominator) > EPSILON ? numerator / denominator : na

f_scale_divisor(simple string mode, float slowValue) =>
    switch mode
        "Percent of Slow Average" => math.abs(slowValue) * 0.01
        => 1.0

const string GROUP_CORE      = "1. MACD Engine"
const string GROUP_SCALE     = "2. Display Scale"
const string GROUP_DYNAMICS  = "3. Momentum Dynamics"
const string GROUP_VISUALS   = "4. Visual Layers"
const string GROUP_MARKERS   = "5. Event Markers"
const string GROUP_READOUT   = "6. Context Readout"
const string GROUP_COLORS    = "7. Visual Palette"
const string GROUP_ALERTS    = "8. Alerts"

f_ma(series float sourceValue, simple int lengthValue, simple string averageType) =>
    switch averageType
        "SMA" => ta.sma(sourceValue, lengthValue)
        "RMA" => ta.rma(sourceValue, lengthValue)
        "WMA" => ta.wma(sourceValue, lengthValue)
        "HMA" => ta.hma(sourceValue, lengthValue)
        => ta.ema(sourceValue, lengthValue)

f_position(simple string selection) =>
    switch selection
        "Top Left" => position.top_left
        "Middle Left" => position.middle_left
        "Bottom Left" => position.bottom_left
        "Top Center" => position.top_center
        "Bottom Center" => position.bottom_center
        "Middle Right" => position.middle_right
        "Bottom Right" => position.bottom_right
        => position.top_right

f_text_size(simple string selection) =>
    switch selection
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_number(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.######")

f_percent(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.0") + "%"

f_readout_row(table panel, int rowIndex, string labelText, string valueText, color valueColor, color rowColor, simple string sizeSelection) =>
    table.cell(panel, 0, rowIndex, labelText,
         text_color = color.new(color.white, 22),
         text_size = f_text_size(sizeSelection),
         text_halign = text.align_left,
         bgcolor = rowColor)
    table.cell(panel, 1, rowIndex, valueText,
         text_color = valueColor,
         text_size = f_text_size(sizeSelection),
         text_halign = text.align_right,
         bgcolor = rowColor)

//------------------------------------------------------------------------------
// Inputs — all values remain available in Settings while staying out of the
// chart status line so the top-left label shows only the full indicator name.
//------------------------------------------------------------------------------
float sourceInput = input.source(close, "Source",
     group = GROUP_CORE,
     display = display.none,
     tooltip = "Price series used by the fast and slow moving averages.")
int fastLength = input.int(12, "Fast Length", minval = 1, maxval = 1000,
     group = GROUP_CORE,
     display = display.none,
     tooltip = "Length of the faster moving average. It must be lower than Slow Length.")
string fastAverageType = input.string("EMA", "Fast Average Type", options = ["EMA", "SMA", "RMA", "WMA", "HMA"],
     group = GROUP_CORE,
     display = display.none)
int slowLength = input.int(26, "Slow Length", minval = 2, maxval = 2000,
     group = GROUP_CORE,
     display = display.none,
     tooltip = "Length of the slower moving average. It must be higher than Fast Length.")
string slowAverageType = input.string("EMA", "Slow Average Type", options = ["EMA", "SMA", "RMA", "WMA", "HMA"],
     group = GROUP_CORE,
     display = display.none)
int signalLength = input.int(9, "Signal Length", minval = 1, maxval = 1000,
     group = GROUP_CORE,
     display = display.none)
string signalAverageType = input.string("EMA", "Signal Average Type", options = ["EMA", "SMA", "RMA", "WMA", "HMA"],
     group = GROUP_CORE,
     display = display.none)

string scaleMode = input.string("Raw MACD", "Display Mode", options = ["Raw MACD", "Percent of Slow Average"],
     group = GROUP_SCALE,
     display = display.none,
     tooltip = "Raw MACD preserves native price units. Percent of Slow Average divides MACD, Signal, and Histogram by one percent of the absolute Slow Average. Analytical events are calculated from the raw MACD and Signal series, so the display unit cannot rewrite event history.")

int accelerationSmoothing = input.int(3, "Histogram Acceleration Smoothing", minval = 1, maxval = 100,
     group = GROUP_DYNAMICS,
     display = display.none,
     tooltip = "Smooths one-bar Histogram change. Display acceleration uses the selected display scale, while phase classification uses the raw MACD structure so changing the display scale does not rewrite the analytical state.")
int phaseNoiseLength = input.int(8, "Phase Noise Length", minval = 2, maxval = 500,
     group = GROUP_DYNAMICS,
     display = display.none,
     tooltip = "Estimates ordinary one-bar movement in absolute Histogram magnitude. The resulting deadband reduces phase switching caused by very small changes around zero velocity.")
float phaseNoiseMultiplier = input.float(0.25, "Phase Noise Multiplier", minval = 0.0, maxval = 5.0, step = 0.05,
     group = GROUP_DYNAMICS,
     display = display.none,
     tooltip = "Scales the adaptive phase deadband. Higher values require a clearer magnitude change before Expansion or Contraction is allowed to replace the prior motion state.")
int equilibriumLength = input.int(34, "Adaptive Equilibrium Length", minval = 2, maxval = 2000,
     group = GROUP_DYNAMICS,
     display = display.none,
     tooltip = "Lookback used to estimate the recent mean absolute histogram magnitude.")
float equilibriumMultiplier = input.float(0.28, "Equilibrium Band Multiplier", minval = 0.0, maxval = 5.0, step = 0.01,
     group = GROUP_DYNAMICS,
     display = display.none,
     tooltip = "The equilibrium entry band equals the EMA of absolute raw Histogram magnitude multiplied by this value.")
float equilibriumExitMultiplier = input.float(1.25, "Equilibrium Exit Hysteresis", minval = 1.0, maxval = 5.0, step = 0.05,
     group = GROUP_DYNAMICS,
     display = display.none,
     tooltip = "Once Near Equilibrium is active, the Histogram must leave a wider band before the state changes. This hysteresis reduces rapid state flapping near the boundary.")
int magnitudeLookback = input.int(120, "Magnitude Rank Lookback", minval = 10, maxval = 5000,
     group = GROUP_DYNAMICS,
     display = display.none,
     tooltip = "Lookback for the robust Histogram magnitude score. The score can use observation rank, rolling-range position, or a hybrid of both.")
string magnitudeScoreMethod = input.string("Hybrid Rank", "Magnitude Score Method", options = ["Hybrid Rank", "Percent Rank", "Range Rank"],
     group = GROUP_DYNAMICS,
     display = display.none,
     tooltip = "Percent Rank is less dominated by one extreme observation. Range Rank preserves excursion size inside the rolling minimum-to-maximum span. Hybrid Rank combines 65% Percent Rank with 35% Range Rank.")
float subduedThreshold = input.float(20.0, "Subdued Magnitude Threshold", minval = 0.0, maxval = 99.0, step = 1.0,
     group = GROUP_DYNAMICS,
     display = display.none)
float reactivationThreshold = input.float(35.0, "Magnitude Reactivation Threshold", minval = 1.0, maxval = 100.0, step = 1.0,
     group = GROUP_DYNAMICS,
     display = display.none)
float extendedThreshold = input.float(80.0, "Extended Magnitude Threshold", minval = 1.0, maxval = 100.0, step = 1.0,
     group = GROUP_DYNAMICS,
     display = display.none)
int minimumSubduedBars = input.int(3, "Minimum Subdued Bars", minval = 1, maxval = 100,
     group = GROUP_DYNAMICS,
     display = display.none)
int efficiencyLength = input.int(20, "MACD Path Efficiency Length", minval = 2, maxval = 1000,
     group = GROUP_DYNAMICS,
     display = display.none,
     tooltip = "Compares net MACD displacement with total MACD travel over the selected lookback. The result is descriptive and ranges from 0 to 100.")

bool showHistogram = input.bool(true, "Show Histogram",
     group = GROUP_VISUALS,
     display = display.none)
bool showHistogramGlow = input.bool(true, "Show Histogram Depth Layer",
     group = GROUP_VISUALS,
     display = display.none,
     active = showHistogram)
bool fadeLowMagnitudeBars = input.bool(true, "Fade Lower-Magnitude Histogram Bars",
     group = GROUP_VISUALS,
     display = display.none,
     active = showHistogram)
bool showMacdLine = input.bool(true, "Show MACD Line",
     group = GROUP_VISUALS,
     display = display.none)
bool showSignalLine = input.bool(true, "Show Signal Line",
     group = GROUP_VISUALS,
     display = display.none)
bool showLineGlow = input.bool(true, "Show Line Glow",
     group = GROUP_VISUALS,
     display = display.none,
     active = showMacdLine or showSignalLine)
bool showLineFill = input.bool(true, "Fill Between MACD and Signal",
     group = GROUP_VISUALS,
     display = display.none,
     active = showMacdLine and showSignalLine)
bool showEquilibriumBand = input.bool(true, "Show Adaptive Equilibrium Band",
     group = GROUP_VISUALS,
     display = display.none)
bool showPhaseRail = input.bool(true, "Show Momentum Phase Rail at Zero",
     group = GROUP_VISUALS,
     display = display.none,
     tooltip = "Colors the zero line by the current histogram phase without adding another scale.")
bool showPhaseBackground = input.bool(false, "Show Phase Background Tint",
     group = GROUP_VISUALS,
     display = display.none)
int backgroundTransparency = input.int(94, "Background Transparency", minval = 75, maxval = 100,
     group = GROUP_VISUALS,
     display = display.none,
     active = showPhaseBackground)
int lineFillTransparency = input.int(88, "Line Fill Transparency", minval = 50, maxval = 100,
     group = GROUP_VISUALS,
     display = display.none,
     active = showLineFill)
int histogramGlowTransparency = input.int(78, "Histogram Depth Transparency", minval = 0, maxval = 100,
     group = GROUP_VISUALS,
     display = display.none,
     active = showHistogram and showHistogramGlow)

bool showSignalCrossMarkers = input.bool(true, "Signal-Line Cross Markers",
     group = GROUP_MARKERS,
     display = display.none)
bool showAccelerationTurnMarkers = input.bool(false, "Acceleration Turn Markers",
     group = GROUP_MARKERS,
     display = display.none)
bool showZeroCrossMarkers = input.bool(false, "MACD Zero-Cross Markers",
     group = GROUP_MARKERS,
     display = display.none)
bool showMagnitudeReactivationMarkers = input.bool(true, "Magnitude Reactivation Markers",
     group = GROUP_MARKERS,
     display = display.none)

string readoutMode = input.string("Compact", "Readout Mode", options = ["Off", "Compact", "Detailed"],
     group = GROUP_READOUT,
     display = display.none)
string readoutPosition = input.string("Top Right", "Readout Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"],
     group = GROUP_READOUT,
     display = display.none,
     active = readoutMode != "Off")
string readoutTextSize = input.string("Normal", "Readout Text Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     group = GROUP_READOUT,
     display = display.none,
     active = readoutMode != "Off")
string readoutHeaderSize = input.string("Normal", "Header Text Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     group = GROUP_READOUT,
     display = display.none,
     active = readoutMode != "Off")
color readoutBackground = input.color(color.rgb(16, 20, 30), "Readout Background",
     group = GROUP_READOUT,
     display = display.none,
     active = readoutMode != "Off")
color readoutHeaderBackground = input.color(color.rgb(35, 42, 58), "Readout Header Background",
     group = GROUP_READOUT,
     display = display.none,
     active = readoutMode != "Off")
color readoutBorderColor = input.color(color.rgb(75, 88, 112), "Readout Border",
     group = GROUP_READOUT,
     display = display.none,
     active = readoutMode != "Off")

color macdLineColor = input.color(color.rgb(245, 247, 250), "MACD Line",
     group = GROUP_COLORS,
     display = display.none)
color signalLineColor = input.color(color.rgb(41, 121, 255), "Signal Line",
     group = GROUP_COLORS,
     display = display.none)
color positiveExpansionColor = input.color(color.rgb(0, 230, 118), "Positive Expansion",
     group = GROUP_COLORS,
     display = display.none)
color positiveContractionColor = input.color(color.rgb(0, 191, 165), "Positive Contraction",
     group = GROUP_COLORS,
     display = display.none)
color negativeExpansionColor = input.color(color.rgb(255, 45, 122), "Negative Expansion",
     group = GROUP_COLORS,
     display = display.none)
color negativeContractionColor = input.color(color.rgb(255, 145, 0), "Negative Contraction",
     group = GROUP_COLORS,
     display = display.none)
color equilibriumColor = input.color(color.rgb(213, 0, 249), "Equilibrium",
     group = GROUP_COLORS,
     display = display.none)
color zeroLineColor = input.color(color.rgb(120, 144, 156), "Zero Guide",
     group = GROUP_COLORS,
     display = display.none)
color magnitudeReactivationColor = input.color(color.rgb(255, 234, 0), "Magnitude Reactivation Marker",
     group = GROUP_COLORS,
     display = display.none)

bool confirmedEventsOnly = input.bool(true, "Confirmed Bars Only",
     group = GROUP_ALERTS,
     display = display.none,
     tooltip = "When enabled, markers and alert conditions trigger only after the chart bar closes. The live plots and readout can still update on the forming bar.")
bool enableSignalCrossAlerts = input.bool(true, "Enable Signal-Line Cross Alerts",
     group = GROUP_ALERTS,
     display = display.none)
bool enableZeroCrossAlerts = input.bool(false, "Enable MACD Zero-Cross Alerts",
     group = GROUP_ALERTS,
     display = display.none)
bool enableAccelerationAlerts = input.bool(true, "Enable Acceleration Turn Alerts",
     group = GROUP_ALERTS,
     display = display.none)
bool enableMagnitudeReactivationAlerts = input.bool(true, "Enable Magnitude Reactivation Alert",
     group = GROUP_ALERTS,
     display = display.none)
bool enablePhaseAlerts = input.bool(false, "Enable Momentum Phase Alerts",
     group = GROUP_ALERTS,
     display = display.none)

//------------------------------------------------------------------------------
// Core MACD engine
//------------------------------------------------------------------------------
bool lengthsValid = fastLength < slowLength
bool sourceAvailable = not na(sourceInput)

float fastAverage = f_ma(sourceInput, fastLength, fastAverageType)
float slowAverage = f_ma(sourceInput, slowLength, slowAverageType)
float rawMacd = lengthsValid ? fastAverage - slowAverage : na
max_bars_back(rawMacd, 1001)
float rawSignal = lengthsValid ? f_ma(rawMacd, signalLength, signalAverageType) : na
float rawHistogram = rawMacd - rawSignal

float scaleDivisor = f_scale_divisor(scaleMode, slowAverage)
bool scaleValid = scaleMode == "Raw MACD" or (not na(scaleDivisor) and scaleDivisor > EPSILON)
float macdLine = lengthsValid and scaleValid ? f_safe_div(rawMacd, scaleDivisor) : na
max_bars_back(macdLine, 1001)
float signalLine = lengthsValid and scaleValid ? f_safe_div(rawSignal, scaleDivisor) : na
float histogram = lengthsValid and scaleValid ? f_safe_div(rawHistogram, scaleDivisor) : na

int coreWarmup = slowLength + signalLength + 2
bool rawCoreReady = lengthsValid and sourceAvailable and bar_index >= coreWarmup and not na(rawHistogram)
bool coreReady = rawCoreReady and scaleValid and not na(histogram)

//------------------------------------------------------------------------------
// Momentum dynamics
//
// Phase logic deliberately uses raw MACD structure, while plotting can use
// raw or percent-of-slow-average units. This separation prevents a display-only setting from
// rewriting phase history. All magnitude metrics self-normalize against their
// own recent history, so they remain comparable without a fixed price unit.
//------------------------------------------------------------------------------
float displayHistogramChange = ta.change(histogram)
float histogramAcceleration = accelerationSmoothing == 1 ? displayHistogramChange : ta.ema(displayHistogramChange, accelerationSmoothing)

float rawHistogramChange = ta.change(rawHistogram)
float rawHistogramAcceleration = accelerationSmoothing == 1 ? rawHistogramChange : ta.ema(rawHistogramChange, accelerationSmoothing)
float absoluteHistogram = math.abs(rawHistogram)
max_bars_back(absoluteHistogram, 5000)

float magnitudeChange = ta.change(absoluteHistogram)
float magnitudeVelocity = accelerationSmoothing == 1 ? magnitudeChange : ta.ema(magnitudeChange, accelerationSmoothing)
float phaseNoiseBasis = ta.ema(math.abs(magnitudeChange), phaseNoiseLength)
float phaseDeadband = phaseNoiseBasis * phaseNoiseMultiplier

float equilibriumBasis = ta.ema(absoluteHistogram, equilibriumLength)
float equilibriumEntryBandRaw = equilibriumBasis * equilibriumMultiplier
float equilibriumExitBandRaw = equilibriumEntryBandRaw * equilibriumExitMultiplier
float equilibriumDisplayBand = scaleValid ? f_safe_div(equilibriumEntryBandRaw, scaleDivisor) : na

int phaseWarmup = coreWarmup + math.max(math.max(equilibriumLength, accelerationSmoothing), phaseNoiseLength) + 2
bool phaseReady = rawCoreReady and bar_index >= phaseWarmup and not na(magnitudeVelocity) and not na(phaseDeadband) and not na(equilibriumEntryBandRaw)

// Entry/exit hysteresis prevents rapid boundary flapping. The state remains
// deterministic on historical bars and is recalculated from the latest live
// price on the open bar; confirmed-event gating is handled separately below.
var bool equilibriumState = false
if not phaseReady
    equilibriumState := false
else if not phaseReady[1]
    equilibriumState := absoluteHistogram <= equilibriumEntryBandRaw
else if equilibriumState
    equilibriumState := absoluteHistogram <= equilibriumExitBandRaw
else
    equilibriumState := absoluteHistogram <= equilibriumEntryBandRaw

// A noise-aware motion state holds its prior classification when magnitude
// movement is too small to distinguish reliably from recent one-bar variation.
var int motionState = 0
if not phaseReady
    motionState := 0
else if magnitudeVelocity > phaseDeadband
    motionState := 1
else if magnitudeVelocity < -phaseDeadband
    motionState := -1
else if motionState == 0
    motionState := magnitudeVelocity >= 0.0 ? 1 : -1

int phaseCode = not phaseReady ? 0 :
     equilibriumState ? 0 :
     rawHistogram > 0.0 and motionState == 1 ? 1 :
     rawHistogram > 0.0 ? 2 :
     rawHistogram < 0.0 and motionState == 1 ? -1 :
     -2

string phaseText = switch phaseCode
    1 => "Positive expansion"
    2 => "Positive contraction"
    -1 => "Negative expansion"
    -2 => "Negative contraction"
    => phaseReady ? "Near equilibrium" : "Warming up"

color histogramStateColor = switch phaseCode
    1 => positiveExpansionColor
    2 => positiveContractionColor
    -1 => negativeExpansionColor
    -2 => negativeContractionColor
    => equilibriumColor

color phaseColor = histogramStateColor
color phaseValueTextColor = phaseCode == -1 or phaseCode == 0 ? color.white : color.black

bool phaseChangedRaw = phaseReady and phaseReady[1] and phaseCode != phaseCode[1]
var int phaseAge = 0
if not phaseReady
    phaseAge := 0
else if phaseChangedRaw
    phaseAge := 1
else
    phaseAge := phaseAge + 1

// Robust magnitude score: observation rank resists single-window outliers,
// range position retains excursion information, and Hybrid Rank combines both.
float magnitudeLow = ta.lowest(absoluteHistogram, magnitudeLookback)
float magnitudeHigh = ta.highest(absoluteHistogram, magnitudeLookback)
float magnitudeSpan = magnitudeHigh - magnitudeLow
float magnitudePercentRank = ta.percentrank(absoluteHistogram, magnitudeLookback)
int magnitudeWarmup = coreWarmup + magnitudeLookback - 1
bool magnitudeReady = rawCoreReady and bar_index >= magnitudeWarmup and not na(magnitudeLow) and not na(magnitudeHigh) and not na(magnitudePercentRank)
float magnitudeRangeRank = not magnitudeReady ? na : magnitudeSpan > EPSILON ? f_clamp(100.0 * (absoluteHistogram - magnitudeLow) / magnitudeSpan, 0.0, 100.0) : 0.0
float magnitudeScore = na
if magnitudeReady
    magnitudeScore := magnitudeSpan <= EPSILON ? 0.0 :
         magnitudeScoreMethod == "Percent Rank" ? f_clamp(magnitudePercentRank, 0.0, 100.0) :
         magnitudeScoreMethod == "Range Rank" ? magnitudeRangeRank :
         f_clamp(0.65 * magnitudePercentRank + 0.35 * magnitudeRangeRank, 0.0, 100.0)

bool thresholdsValid = subduedThreshold < reactivationThreshold and reactivationThreshold < extendedThreshold
bool magnitudeSubdued = magnitudeReady and thresholdsValid and magnitudeScore <= subduedThreshold
bool magnitudeExtended = magnitudeReady and thresholdsValid and magnitudeScore >= extendedThreshold
string magnitudeState = not thresholdsValid ? "Check thresholds" :
     not magnitudeReady ? "Warming up" :
     magnitudeSubdued ? "Subdued" :
     magnitudeExtended ? "Extended" :
     "Typical"

// Stateful reactivation logic updates on confirmed bars by default. Users may
// deliberately permit intrabar events, in which case those events are fluid
// until the realtime bar closes, as expected under Pine's execution model.
bool stateUpdateGate = not barstate.isrealtime or not confirmedEventsOnly or barstate.isconfirmed
var int subduedBars = 0
var bool reactivationArmed = false
bool magnitudeReactivationRaw = false
if stateUpdateGate
    if not magnitudeReady or not thresholdsValid
        subduedBars := 0
        reactivationArmed := false
    else
        if magnitudeSubdued
            subduedBars := subduedBars + 1
            if subduedBars >= minimumSubduedBars
                reactivationArmed := true
        else
            subduedBars := 0
        if reactivationArmed and magnitudeScore >= reactivationThreshold
            magnitudeReactivationRaw := true
            reactivationArmed := false

float macdStepDistance = math.abs(ta.change(rawMacd))
float macdPathDistance = math.sum(macdStepDistance, efficiencyLength)
float macdNetDistance = math.abs(rawMacd - rawMacd[efficiencyLength])
int efficiencyWarmup = coreWarmup + efficiencyLength
bool efficiencyReady = rawCoreReady and bar_index >= efficiencyWarmup and not na(macdPathDistance) and not na(macdNetDistance)
float macdPathEfficiency = efficiencyReady and macdPathDistance > EPSILON ? f_clamp(100.0 * macdNetDistance / macdPathDistance, 0.0, 100.0) : na

//------------------------------------------------------------------------------
// Events and descriptive timing
//------------------------------------------------------------------------------
bool signalCrossUpTest = ta.crossover(rawMacd, rawSignal)
bool signalCrossDownTest = ta.crossunder(rawMacd, rawSignal)
bool macdZeroCrossUpTest = ta.crossover(rawMacd, 0.0)
bool macdZeroCrossDownTest = ta.crossunder(rawMacd, 0.0)
bool accelerationTurnUpTest = ta.crossover(rawHistogramAcceleration, 0.0)
bool accelerationTurnDownTest = ta.crossunder(rawHistogramAcceleration, 0.0)
bool signalCrossRaw = signalCrossUpTest or signalCrossDownTest

// Cross-cycle peak retention uses confirmed state updates by default. A live
// shadow peak keeps the readout bounded on an open bar without committing an
// intrabar extreme that historical bars could not reproduce.
var float committedCyclePeak = na
if stateUpdateGate
    if not rawCoreReady
        committedCyclePeak := na
    else if signalCrossRaw or na(committedCyclePeak)
        committedCyclePeak := absoluteHistogram
    else
        committedCyclePeak := math.max(committedCyclePeak, absoluteHistogram)
float liveCyclePeak = rawCoreReady ? math.max(nz(committedCyclePeak, absoluteHistogram), absoluteHistogram) : na
float cyclePeakRetention = rawCoreReady and not na(liveCyclePeak) and liveCyclePeak > EPSILON ? f_clamp(100.0 * absoluteHistogram / liveCyclePeak, 0.0, 100.0) : na

bool eventGate = not confirmedEventsOnly or barstate.isconfirmed
bool signalCrossUp = rawCoreReady and eventGate and signalCrossUpTest
bool signalCrossDown = rawCoreReady and eventGate and signalCrossDownTest
bool macdZeroCrossUp = rawCoreReady and eventGate and macdZeroCrossUpTest
bool macdZeroCrossDown = rawCoreReady and eventGate and macdZeroCrossDownTest
bool accelerationTurnUp = phaseReady and eventGate and accelerationTurnUpTest
bool accelerationTurnDown = phaseReady and eventGate and accelerationTurnDownTest
bool magnitudeReactivation = magnitudeReady and eventGate and magnitudeReactivationRaw
bool phaseChanged = phaseReady and eventGate and phaseChangedRaw

bool signalCrossAgeEvent = signalCrossRaw and (not confirmedEventsOnly or barstate.isconfirmed)
int signalCrossAge = ta.barssince(signalCrossAgeEvent)
string scaleUnit = switch scaleMode
    "Percent of Slow Average" => "%"
    => ""

string locationText = not rawCoreReady ? "Warming up" : rawMacd > 0.0 ? "Above zero" : rawMacd < 0.0 ? "Below zero" : "At zero"
string accelerationText = not phaseReady or not coreReady ? "n/a" : f_number(histogramAcceleration) + (histogramAcceleration > 0.0 ? "  ↗" : histogramAcceleration < 0.0 ? "  ↘" : "  →")
string magnitudeText = not magnitudeReady ? "Warming up" : f_percent(magnitudeScore) + " · " + magnitudeState
string histogramText = not coreReady ? "n/a" : f_number(histogram) + (scaleUnit == "" ? "" : " " + scaleUnit)

string configurationText = not lengthsValid ? "Fast Length must be lower" :
     not sourceAvailable ? "Source unavailable" :
     not scaleValid ? "Selected scale unavailable" :
     not thresholdsValid ? "Set Subdued < Reactivation < Extended" :
     not coreReady ? "Warming up" :
     "Ready"

color configurationColor = configurationText == "Ready" ? positiveExpansionColor : configurationText == "Warming up" ? signalLineColor : negativeExpansionColor

//------------------------------------------------------------------------------
// Visual layers
//------------------------------------------------------------------------------
int histogramCoreTransparency = fadeLowMagnitudeBars and magnitudeReady ?
     int(math.round(math.max(0.0, math.min(42.0, 42.0 - magnitudeScore * 0.42)))) : 0
color histogramCoreColor = color.new(histogramStateColor, histogramCoreTransparency)
color histogramDepthColor = color.new(histogramStateColor, histogramGlowTransparency)

pEquilibriumUpper = plot(showEquilibriumBand and phaseReady ? equilibriumDisplayBand : na,
     "Adaptive Equilibrium Upper",
     color = color.new(equilibriumColor, 42),
     linewidth = 1,
     display = display.pane)
pEquilibriumLower = plot(showEquilibriumBand and phaseReady ? -equilibriumDisplayBand : na,
     "Adaptive Equilibrium Lower",
     color = color.new(equilibriumColor, 42),
     linewidth = 1,
     display = display.pane)
fill(pEquilibriumUpper, pEquilibriumLower,
     color = showEquilibriumBand ? color.new(equilibriumColor, 92) : na,
     title = "Adaptive Equilibrium Fill")

plot(0.0,
     "Zero Guide",
     color = color.new(zeroLineColor, 35),
     linewidth = 1,
     display = display.pane)
plot(showPhaseRail and phaseReady ? 0.0 : na,
     "Momentum Phase Rail",
     color = color.new(phaseColor, 34),
     linewidth = 6,
     display = display.pane)

plot(showHistogram and showHistogramGlow ? histogram : na,
     "Histogram Depth",
     color = histogramDepthColor,
     style = plot.style_histogram,
     linewidth = 7,
     display = display.pane)
plot(showHistogram ? histogram : na,
     "MACD Histogram",
     color = histogramCoreColor,
     style = plot.style_histogram,
     linewidth = 3,
     display = display.pane + display.data_window)

plot(showMacdLine and showLineGlow ? macdLine : na,
     "MACD Line Glow",
     color = color.new(macdLineColor, 80),
     linewidth = 7,
     display = display.pane)
plot(showSignalLine and showLineGlow ? signalLine : na,
     "Signal Line Glow",
     color = color.new(signalLineColor, 82),
     linewidth = 6,
     display = display.pane)

pMacdLine = plot(showMacdLine ? macdLine : na,
     "MACD Line",
     color = macdLineColor,
     linewidth = 3,
     display = display.pane + display.data_window)
pSignalLine = plot(showSignalLine ? signalLine : na,
     "Signal Line",
     color = signalLineColor,
     linewidth = 2,
     display = display.pane + display.data_window)
fill(pMacdLine, pSignalLine,
     color = showLineFill ? color.new(signalLineColor, lineFillTransparency) : na,
     title = "MACD Signal Separation")

bgcolor(showPhaseBackground and phaseReady ? color.new(phaseColor, backgroundTransparency) : na,
     title = "Momentum Phase Background")

// Neutral event markers identify confirmed transitions; they do not
// represent trade entries or recommendations.
plotshape(showSignalCrossMarkers and signalCrossUp,
     title = "MACD Crossed Above Signal",
     style = shape.arrowup,
     location = location.bottom,
     color = positiveExpansionColor,
     size = size.tiny,
     display = display.pane)
plotshape(showSignalCrossMarkers and signalCrossDown,
     title = "MACD Crossed Below Signal",
     style = shape.arrowdown,
     location = location.top,
     color = negativeExpansionColor,
     size = size.tiny,
     display = display.pane)
plotshape(showAccelerationTurnMarkers and accelerationTurnUp ? histogram : na,
     title = "Histogram Acceleration Turned Positive",
     style = shape.diamond,
     location = location.absolute,
     color = positiveContractionColor,
     size = size.tiny,
     display = display.pane)
plotshape(showAccelerationTurnMarkers and accelerationTurnDown ? histogram : na,
     title = "Histogram Acceleration Turned Negative",
     style = shape.diamond,
     location = location.absolute,
     color = negativeContractionColor,
     size = size.tiny,
     display = display.pane)
plotshape(showZeroCrossMarkers and macdZeroCrossUp ? 0.0 : na,
     title = "MACD Crossed Above Zero",
     style = shape.circle,
     location = location.absolute,
     color = positiveExpansionColor,
     size = size.tiny,
     display = display.pane)
plotshape(showZeroCrossMarkers and macdZeroCrossDown ? 0.0 : na,
     title = "MACD Crossed Below Zero",
     style = shape.circle,
     location = location.absolute,
     color = negativeExpansionColor,
     size = size.tiny,
     display = display.pane)
plotshape(showMagnitudeReactivationMarkers and magnitudeReactivation,
     title = "Histogram Magnitude Reactivated",
     style = shape.circle,
     location = location.top,
     color = magnitudeReactivationColor,
     size = size.tiny,
     display = display.pane)

// Research values remain available in the Data Window without appearing in the
// top-left status line.
plot(histogramAcceleration, "Histogram Acceleration", color = na, display = display.data_window)
plot(magnitudeScore, "Histogram Magnitude Robust Score", color = na, display = display.data_window)
plot(macdPathEfficiency, "MACD Path Efficiency", color = na, display = display.data_window)
plot(cyclePeakRetention, "Cross-Cycle Peak Retention", color = na, display = display.data_window)
plot(phaseCode, "Momentum Phase Code", color = na, display = display.data_window)

//------------------------------------------------------------------------------
// Context readout
//------------------------------------------------------------------------------
var table momentumReadout = table.new(
     f_position(readoutPosition),
     2,
     10,
     frame_color = readoutBorderColor,
     frame_width = 1,
     border_color = color.new(readoutBorderColor, 35),
     border_width = 1)

if barstate.isfirst
    table.merge_cells(momentumReadout, 0, 0, 1, 0)

if barstate.islast
    table.clear(momentumReadout, 0, 0, 1, 9)
    if readoutMode != "Off"
        color rowOne = color.new(readoutBackground, 0)
        color rowTwo = color.new(readoutBackground, 8)
        table.cell(momentumReadout, 0, 0, "MACD Momentum",
             text_color = color.white,
             text_size = f_text_size(readoutHeaderSize),
             text_halign = text.align_center,
             bgcolor = readoutHeaderBackground)

        f_readout_row(momentumReadout, 1, "Phase", phaseText, phaseValueTextColor, phaseColor, readoutTextSize)
        f_readout_row(momentumReadout, 2, "Location", locationText, macdLine >= 0 ? positiveContractionColor : negativeContractionColor, rowOne, readoutTextSize)
        f_readout_row(momentumReadout, 3, "Histogram", histogramText, histogramStateColor, rowTwo, readoutTextSize)
        f_readout_row(momentumReadout, 4, "Magnitude", magnitudeText, magnitudeExtended ? negativeContractionColor : magnitudeSubdued ? equilibriumColor : color.white, rowOne, readoutTextSize)
        f_readout_row(momentumReadout, 5, "Status", configurationText, configurationColor, rowTwo, readoutTextSize)

        if readoutMode == "Detailed"
            f_readout_row(momentumReadout, 6, "Acceleration", accelerationText, histogramAcceleration >= 0 ? positiveContractionColor : negativeContractionColor, rowOne, readoutTextSize)
            f_readout_row(momentumReadout, 7, "Phase Age", phaseReady ? str.tostring(phaseAge) + (phaseAge == 1 ? " bar" : " bars") : "n/a", color.white, rowTwo, readoutTextSize)
            f_readout_row(momentumReadout, 8, "Cross Cycle", na(signalCrossAge) ? "No cross yet" : str.tostring(signalCrossAge + 1) + (signalCrossAge == 0 ? " bar · " : " bars · ") + f_percent(cyclePeakRetention) + " peak", color.white, rowOne, readoutTextSize)
            f_readout_row(momentumReadout, 9, "Efficiency · Bar", f_percent(macdPathEfficiency) + " · " + (barstate.isconfirmed ? "Confirmed" : "Live"), barstate.isconfirmed ? positiveExpansionColor : signalLineColor, rowTwo, readoutTextSize)

//------------------------------------------------------------------------------
// Alert conditions
//------------------------------------------------------------------------------
alertcondition(enableSignalCrossAlerts and signalCrossUp,
     title = "MACD Crossed Above Signal",
     message = "MACD crossed above its signal line on {{exchange}}:{{ticker}} ({{interval}}). Close: {{close}}.")
alertcondition(enableSignalCrossAlerts and signalCrossDown,
     title = "MACD Crossed Below Signal",
     message = "MACD crossed below its signal line on {{exchange}}:{{ticker}} ({{interval}}). Close: {{close}}.")
alertcondition(enableZeroCrossAlerts and macdZeroCrossUp,
     title = "MACD Crossed Above Zero",
     message = "MACD crossed above zero on {{exchange}}:{{ticker}} ({{interval}}). Close: {{close}}.")
alertcondition(enableZeroCrossAlerts and macdZeroCrossDown,
     title = "MACD Crossed Below Zero",
     message = "MACD crossed below zero on {{exchange}}:{{ticker}} ({{interval}}). Close: {{close}}.")
alertcondition(enableAccelerationAlerts and accelerationTurnUp,
     title = "Histogram Acceleration Turned Positive",
     message = "MACD histogram acceleration turned positive on {{exchange}}:{{ticker}} ({{interval}}). Close: {{close}}.")
alertcondition(enableAccelerationAlerts and accelerationTurnDown,
     title = "Histogram Acceleration Turned Negative",
     message = "MACD histogram acceleration turned negative on {{exchange}}:{{ticker}} ({{interval}}). Close: {{close}}.")
alertcondition(enableMagnitudeReactivationAlerts and magnitudeReactivation,
     title = "Histogram Magnitude Reactivated",
     message = "MACD histogram magnitude reactivated after a sustained subdued sequence on {{exchange}}:{{ticker}} ({{interval}}). Close: {{close}}.")
alertcondition(enablePhaseAlerts and phaseChanged and phaseCode == 1,
     title = "Positive Expansion Phase Began",
     message = "The MACD histogram entered a positive expansion phase on {{exchange}}:{{ticker}} ({{interval}}).")
alertcondition(enablePhaseAlerts and phaseChanged and phaseCode == 2,
     title = "Positive Contraction Phase Began",
     message = "The MACD histogram entered a positive contraction phase on {{exchange}}:{{ticker}} ({{interval}}).")
alertcondition(enablePhaseAlerts and phaseChanged and phaseCode == -1,
     title = "Negative Expansion Phase Began",
     message = "The MACD histogram entered a negative expansion phase on {{exchange}}:{{ticker}} ({{interval}}).")
alertcondition(enablePhaseAlerts and phaseChanged and phaseCode == -2,
     title = "Negative Contraction Phase Began",
     message = "The MACD histogram entered a negative contraction phase on {{exchange}}:{{ticker}} ({{interval}}).")
alertcondition(enablePhaseAlerts and phaseChanged and phaseCode == 0,
     title = "Near-Equilibrium Phase Began",
     message = "The MACD histogram entered the adaptive near-equilibrium phase on {{exchange}}:{{ticker}} ({{interval}}).")
````
