<!-- tradingview-pine-id: PUB;08d5c048122e4b86a7cff7a9615b808f -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Volatility Regime Tracker | NickJoan

Source: https://www.tradingview.com/script/YAB6xPIY-Volatility-Regime-Tracker-NickJoan/

## Description

Volatility Regime Tracker | NickJoan

Core Idea

Volatility Regime Tracker measures the dispersion of price relative to its recent average and classifies the current market environment into distinct volatility states. Instead of just showing raw volatility values, the indicator uses percentile-based thresholds combined with moving average direction to identify three persistent regimes: LOW, NEUTRAL, and HIGH.

The script goes beyond simple volatility measurement by tracking how long each regime has lasted and comparing it to historical averages, giving you a statistical expectation for when the current regime might end.

The indicator can be used in two ways:

• As a volatility gauge, where you monitor the current volatility percentage and its trend.
• As a regime detection tool, where the background colors and duration table help you anticipate volatility state changes.

Calculation Logic

The indicator works through three main stages:

1. Volatility calculation

For the selected price source, the script first calculates the standard deviation over a user-defined lookback window. This absolute volatility is then normalized by the average price to produce a percentage-based measure.

• The script calculates the standard deviation of the source over the lookback period.
• It calculates the simple moving average of the source over the same period.
• It divides standard deviation by average price and multiplies by 100.
• It optionally annualizes the result using √365 for crypto daily charts.

This creates a coefficient of variation measure that shows how much price typically deviates from its recent average as a percentage.

2. Regime classification

The script then determines whether current volatility is high, low, or neutral relative to recent history.

• It calculates the percentile rank of current volatility over a regime lookback window.
• It compares this percentile to user-defined thresholds (default: 30th and 70th percentiles).
• It classifies volatility as HIGH (above upper threshold), LOW (below lower threshold), or NEUTRAL (between thresholds).

3. Dual confirmation

To reduce false signals, the script combines percentile ranking with moving average direction.

• It calculates a moving average of the volatility series.
• It checks whether current volatility is above or below this MA.
• It assigns regime states based on both percentile and MA direction.

This dual-confirmation approach produces five distinct visual states that map to three underlying regimes.

Background Color Logic

The script uses a two-layer color system to show both regime state and confidence level.

Strong signals (darker colors)

• Dark red: High percentile AND above MA (strong high volatility)
• Dark green: Low percentile AND below MA (strong low volatility)

Moderate signals (lighter colors)

• Light red: Neutral percentile but above MA (rising volatility)
• Light green: Neutral percentile but below MA (falling volatility)

Uncertain signals

• Gray: Percentile and MA direction disagree (conflicting signals)

This color structure allows you to distinguish between high-confidence regime readings and transitional or uncertain states.

Regime State Mapping

The indicator consolidates the five color states into three regime categories for duration tracking:

• LOW (0): Any green shade (dark or light) - volatility is low or falling
• NEUTRAL (1): Gray - volatility is in transition or conflicting
• HIGH (2): Any red shade (dark or light) - volatility is high or rising

This mapping ensures the duration statistics reflect the broader regime environment rather than short-term color fluctuations.

Duration Tracking Logic

The script continuously monitors regime changes and builds a historical record of how long each regime typically lasts.

Duration measurement

• When a regime change is detected, the script calculates how many bars the previous regime lasted.
• This duration is stored in an array specific to that regime type (LOW, NEUTRAL, or HIGH).
• The process repeats for each regime change, building a distribution of historical durations.

Statistical analysis

• The script calculates the average duration for each regime type from the stored history.
• It calculates the standard deviation of those durations.
• It computes confidence intervals at ±1 standard deviation (~68% confidence).

Real-time tracking

• The script counts how many bars the current regime has lasted.
• It displays this count alongside the historical average and confidence bounds.
• This allows you to see whether the current regime is typical, unusually short, or unusually long.

Duration Table Output

The table displays four rows of information for each regime type:

• Current bars in regime (if active) or "—" (if inactive)
• Historical average duration for LOW regimes
• Lower bound (average − 1 SD)
• Upper bound (average + 1 SD)

Interpretation

• If current bars < lower bound: regime is unusually short (may extend further)
• If current bars ≈ average: regime is typical (no strong expectation either way)
• If current bars > upper bound: regime is unusually long (may be nearing end)

Chart Output

The indicator displays three visual elements in a separate pane below the price chart:

Volatility line
• Shows the current annualized volatility percentage
• Plotted in blue for clear visibility

Moving average line
• Shows the smoothed volatility trend
• Plotted in gray with thicker linewidth
• Can be toggled off via input

Background color
• Shows the current volatility regime state
• Uses five color states mapped to three regimes
• Can be toggled off via input

Duration table
• Positioned at middle-right of the chart
• Shows current bars, average, and confidence intervals
• Can be toggled off via input

Inputs

The indicator has four main input groups.

CALCULATION

• Volatility Lookback (bars): defines the window used to calculate standard deviation. Default: 50.
• Annualize (√365): toggles annualization of volatility. Recommended for crypto daily charts.
• Source: selects the price series used in the calculation (default: close).

MOVING AVERAGE

• Type: chooses the MA type (SMA, EMA, WMA, RMA). Default: EMA.
• Length: sets the MA lookback period. Default: 30.
• Show Moving Average: toggles MA visibility on the chart.

VOLATILITY REGIME

• Regime Lookback (bars): defines the window used for percentile rank calculation. Default: 100.
• Low Threshold (percentile): sets the lower percentile boundary. Default: 30.
• High Threshold (percentile): sets the upper percentile boundary. Default: 70.
• Show Background Color: toggles regime coloring.

DURATION TABLE

• Show Duration Table: toggles the statistics table visibility.
• History Lookback (days): controls how many bars of history to use for average calculations. Default: 365.

Alerts

The script includes four alert conditions:

Volatility Regime Change
• Triggers on any regime transition (LOW → NEUTRAL, NEUTRAL → HIGH, etc.)
• Useful for monitoring all state changes

Low Volatility Regime
• Triggers when entering LOW regime (green background)
• Useful for breakout preparation or position size increase

Neutral Volatility Regime
• Triggers when entering NEUTRAL regime (gray background)
• Useful for identifying transition periods

High Volatility Regime
• Triggers when entering HIGH regime (red background)
• Useful for risk reduction or heightened awareness

How to Use It

This indicator is best used as a volatility filter and regime-aware positioning tool, not as a standalone entry signal.

Volatility regime filter

Use the regime colors to filter your trading approach:

• LOW regimes (green): Favor breakout strategies, increase position size
• HIGH regimes (red): Reduce position size, exercise caution (volatility can persist or reverse depending on market context)
• NEUTRAL regimes (gray): Wait for clearer signals or reduce exposure

Duration-based anticipation

Use the duration table to anticipate regime changes:

• If current bars approach upper bound: expect potential regime change soon
• If current bars are well below average: expect regime to continue
• If current bars exceed upper bound: regime is extended, watch for reversal

Trend confirmation

Use the volatility trend to confirm price action:

• Rising volatility (light red → dark red): confirms trend expansion or increased uncertainty
• Falling volatility (light green → dark green): confirms consolidation or stabilization
• Conflicting signals (gray): suggests uncertainty or transition

Practical Interpretation

Here is a simple way to read the results:

LOW regime (green)
• Price is tightly clustered around its average
• Volatility is below historical norms
• Often precedes breakout moves
• Good for trend-following entries

HIGH regime (red)
• Price is widely dispersed from its average
• Volatility is above historical norms
• Can indicate trending expansion, shock events, or panic conditions
• Reduce position size; assess whether context suggests continuation or reversion

NEUTRAL regime (gray)
• Volatility is transitioning or conflicting
• No clear regime signal
• Wait for clearer confirmation

Duration statistics
• Average: typical length of this regime type
• Lower/Upper bounds: normal range (~68% of cases)
• Current bars: where you are in the distribution

Best Use Cases

Typical uses include:

• Crypto volatility regime detection
• Position sizing based on volatility state
• Breakout vs. consolidation strategy filter
• Risk management and exposure control
• Multi-asset volatility comparison
• Regime-aware trade timing

It is especially useful when you want to objectively measure whether volatility is high or low relative to recent history, and whether the current regime is typical or extended.

Notes

The indicator is designed for daily crypto charts but works on any timeframe.

• Daily timeframe: "History Lookback (days)" represents calendar days
• Other timeframes: "History Lookback (days)" represents bars, not calendar days

The metric table is only as good as the selected lookback periods and thresholds.

• Shorter volatility lookback: more reactive but noisier
• Longer volatility lookback: smoother but may lag sudden changes
• Shorter regime lookback: faster regime detection but more whipsaws
• Longer regime lookback: more stable but slower to detect changes
• Tighter thresholds (e.g., 25/75): fewer regime changes, higher confidence
• Wider thresholds (e.g., 35/65): more regime changes, earlier detection

The Z-Score-style duration statistics are relative to the selected history window, so their meaning depends on how much data you include.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at [https://mozilla.org/MPL/2.0/](https://mozilla.org/MPL/2.0/)
// © Nick_Joan


//@version=6
indicator(title = "Volatility Regime Tracker | NickJoan", format = format.percent, overlay = false)


// ─── Inputs ───────────────────────────────────────────────────────────────────
length       = input.int(50, "Volatility Lookback (bars)", minval = 2, group = "CALCULATION")
annualize    = input.bool(true, "Annualize (√365)", group = "CALCULATION", tooltip = "For crypto, annualized volatility uses √365.")
source       = input.source(close, "Source", group = "CALCULATION")

maType       = input.string('EMA', title = 'Type', options = ['SMA', 'EMA', 'WMA', 'RMA'], group = "MOVING AVERAGE")
maLen        = input.int(30, title = 'Length', minval = 1, group = "MOVING AVERAGE")
showMa       = input.bool(true, 'Show Moving Average')

regimeLen    = input.int(100, "Regime Lookback (bars)", minval = 2, group = "VOLATILITY REGIME")
lowThresh    = input.int(30, "Low Threshold (percentile)", minval = 1, maxval = 99, group = "VOLATILITY REGIME")
highThresh   = input.int(70, "High Threshold (percentile)", minval = 1, maxval = 99, group = "VOLATILITY REGIME")
showBg       = input.bool(true, "Show Background Color", group = "VOLATILITY REGIME")

// Duration tracking
showTable    = input.bool(true, "Show Duration Table", group = "DURATION TABLE")
historyDays  = input.int(365, "History Lookback (days)", minval = 1, group = "DURATION TABLE")


// ─── Calculations ─────────────────────────────────────────────────────────────
// Standard deviation of source (absolute volatility)
stdevSource = ta.stdev(source, length)

// Normalize by average to get percentage volatility
avgSource = ta.sma(source, length)
volatilityRaw = stdevSource / avgSource * 100

// Annualize if selected (√365 for crypto daily)
volatility = annualize ? volatilityRaw * math.sqrt(365) : volatilityRaw


// ─── Moving Average ───────────────────────────────────────────────────────────
ma = switch maType
    'SMA' => ta.sma(volatility, maLen)
    'EMA' => ta.ema(volatility, maLen)
    'WMA' => ta.wma(volatility, maLen)
    'RMA' => ta.rma(volatility, maLen)


// ─── Volatility Regime (percentile-based) ─────────────────────────────────────
volPercentile = ta.percentrank(volatility, regimeLen)

volAboveMa = volatility > ma
volBelowMa = volatility < ma

volHigh = volPercentile > highThresh
volLow = volPercentile < lowThresh
volNeutral = not volHigh and not volLow


// ─── Background Color Logic ───────────────────────────────────────────────────
// High percentile + Above MA = Red (strong high)
agreeHigh = volHigh and volAboveMa

// Low percentile + Below MA = Green (strong low)
agreeLow = volLow and volBelowMa

// Neutral percentile + MA direction
neutralHigh = volNeutral and volAboveMa
neutralLow = volNeutral and volBelowMa

// Assign color with transparency
bgColor = agreeHigh ? color.new(color.red, 75) : 
          agreeLow ? color.new(color.lime, 75) : 
          neutralHigh ? color.new(color.red, 85) : 
          neutralLow ? color.new(color.lime, 85) : 
          color.new(color.gray, 90)


// ─── Regime State ─────────────────────────────
currentRegime = agreeLow or neutralLow ? 0 : agreeHigh or neutralHigh ? 2 : 1
// 0=LOW (green), 1=NEUTRAL (gray), 2=HIGH (red)


// ─── Duration History Tracking ────────────────────────────────────────────────
// Calculate how many bars to look back (assuming daily timeframe)
historyBars = historyDays

// Store regime durations with their bar_index timestamps
var int[] lowDurations = array.new_int()
var int[] neutralDurations = array.new_int()
var int[] highDurations = array.new_int()

var int[] lowBarIndices = array.new_int()
var int[] neutralBarIndices = array.new_int()
var int[] highBarIndices = array.new_int()

// Track completed regime durations
var int prevRegimeState = -1
var int regimeStartBar = bar_index

// Detect regime change
var int lastRegimeState = -1
regimeChanged = currentRegime != lastRegimeState

if regimeChanged and prevRegimeState != -1
    completedDuration = bar_index - regimeStartBar
    
    // Store duration and bar_index in appropriate arrays
    if prevRegimeState == 0
        array.push(lowDurations, completedDuration)
        array.push(lowBarIndices, bar_index)
    else if prevRegimeState == 1
        array.push(neutralDurations, completedDuration)
        array.push(neutralBarIndices, bar_index)
    else if prevRegimeState == 2
        array.push(highDurations, completedDuration)
        array.push(highBarIndices, bar_index)
    
    regimeStartBar := bar_index

prevRegimeState := currentRegime
lastRegimeState := currentRegime

// Clean old entries beyond history lookback
if bar_index > historyBars
    cutoffBar = bar_index - historyBars
    
    // Remove old low durations
    if array.size(lowBarIndices) > 0
        for i = array.size(lowBarIndices) - 1 to 0
            if array.get(lowBarIndices, i) < cutoffBar
                array.remove(lowDurations, i)
                array.remove(lowBarIndices, i)
    
    // Remove old neutral durations
    if array.size(neutralBarIndices) > 0
        for i = array.size(neutralBarIndices) - 1 to 0
            if array.get(neutralBarIndices, i) < cutoffBar
                array.remove(neutralDurations, i)
                array.remove(neutralBarIndices, i)
    
    // Remove old high durations
    if array.size(highBarIndices) > 0
        for i = array.size(highBarIndices) - 1 to 0
            if array.get(highBarIndices, i) < cutoffBar
                array.remove(highDurations, i)
                array.remove(highBarIndices, i)


// ─── Calculate Average and Standard Deviation ─────────────────────────────────
// Function to calculate average from array
calcAverage(series int[] arr) =>
    if array.size(arr) == 0
        0.0
    else
        sum = 0.0
        for i = 0 to array.size(arr) - 1
            sum := sum + array.get(arr, i)
        sum / array.size(arr)

// Function to calculate standard deviation from array
calcStdev(series int[] arr, series float avg) =>
    if array.size(arr) < 2
        0.0
    else
        sumSq = 0.0
        for i = 0 to array.size(arr) - 1
            diff = array.get(arr, i) - avg
            sumSq := sumSq + diff * diff
        math.sqrt(sumSq / (array.size(arr) - 1))

// Calculate statistics for each regime (1 standard deviation = ~68% confidence)
avgLowDuration = calcAverage(lowDurations)
stdevLowDuration = calcStdev(lowDurations, avgLowDuration)
lowDurationLower = avgLowDuration - stdevLowDuration
lowDurationUpper = avgLowDuration + stdevLowDuration

avgNeutralDuration = calcAverage(neutralDurations)
stdevNeutralDuration = calcStdev(neutralDurations, avgNeutralDuration)
neutralDurationLower = avgNeutralDuration - stdevNeutralDuration
neutralDurationUpper = avgNeutralDuration + stdevNeutralDuration

avgHighDuration = calcAverage(highDurations)
stdevHighDuration = calcStdev(highDurations, avgHighDuration)
highDurationLower = avgHighDuration - stdevHighDuration
highDurationUpper = avgHighDuration + stdevHighDuration


// ─── Current Bars Counter ─────────────────────────────────────────────────────
var int currentBars = 0
if regimeChanged
    currentBars := 1
else
    currentBars := currentBars + 1


// ─── Plots ────────────────────────────────────────────────────────────────────
plot(volatility, title = "Volatility (%)", color = color.blue)
plot(showMa ? ma : na, title = 'Moving Average', linewidth = 2, color = color.new(color.gray, 80))


// ─── Background ───────────────────────────────────────────────────────────────
bgcolor(showBg ? bgColor : na, force_overlay = true)


// ─── Duration Table ───────────────────────────────────────────────────────────
if showTable
    var table durationTable = table.new(position.middle_right, 5, 4, 
         bgcolor = color.new(color.black, 80), 
         border_width = 1,
         border_color = color.gray)
    
    // Header
    table.cell(durationTable, 0, 0, "REGIME", 
         text_color = color.white, 
         text_size = size.small,
         text_halign = text.align_left)
    table.cell(durationTable, 1, 0, "CURRENT\nBARS", 
         text_color = color.white, 
         text_size = size.small,
         text_halign = text.align_center)
    table.cell(durationTable, 2, 0, "LOWER\n(1 SD)", 
         text_color = color.white, 
         text_size = size.small,
         text_halign = text.align_center)
    table.cell(durationTable, 3, 0, "AVERAGE", 
         text_color = color.white, 
         text_size = size.small,
         text_halign = text.align_center)
    table.cell(durationTable, 4, 0, "UPPER\n(1 SD)", 
         text_color = color.white, 
         text_size = size.small,
         text_halign = text.align_center)
    
    // Low regime
    table.cell(durationTable, 0, 1, "LOW", 
         text_color = color.lime, 
         text_size = size.small,
         text_halign = text.align_left)
    table.cell(durationTable, 1, 1, currentRegime == 0 ? str.tostring(currentBars) : "—", 
         text_color = currentRegime == 0 ? color.lime : color.gray, 
         text_size = size.small,
         text_halign = text.align_center)
    table.cell(durationTable, 2, 1, lowDurationLower > 0 ? str.tostring(lowDurationLower, "#.##") : "N/A", 
         text_color = color.lime, 
         text_size = size.small,
         text_halign = text.align_center)
    table.cell(durationTable, 3, 1, avgLowDuration > 0 ? str.tostring(avgLowDuration, "#.##") : "N/A", 
         text_color = color.lime, 
         text_size = size.small,
         text_halign = text.align_center)
    table.cell(durationTable, 4, 1, lowDurationUpper > 0 ? str.tostring(lowDurationUpper, "#.##") : "N/A", 
         text_color = color.lime, 
         text_size = size.small,
         text_halign = text.align_center)
    
    // Neutral regime
    table.cell(durationTable, 0, 2, "NEUTRAL", 
         text_color = color.yellow, 
         text_size = size.small,
         text_halign = text.align_left)
    table.cell(durationTable, 1, 2, currentRegime == 1 ? str.tostring(currentBars) : "—", 
         text_color = currentRegime == 1 ? color.yellow : color.gray, 
         text_size = size.small,
         text_halign = text.align_center)
    table.cell(durationTable, 2, 2, neutralDurationLower > 0 ? str.tostring(neutralDurationLower, "#.##") : "N/A", 
         text_color = color.yellow, 
         text_size = size.small,
         text_halign = text.align_center)
    table.cell(durationTable, 3, 2, avgNeutralDuration > 0 ? str.tostring(avgNeutralDuration, "#.##") : "N/A", 
         text_color = color.yellow, 
         text_size = size.small,
         text_halign = text.align_center)
    table.cell(durationTable, 4, 2, neutralDurationUpper > 0 ? str.tostring(neutralDurationUpper, "#.##") : "N/A", 
         text_color = color.yellow, 
         text_size = size.small,
         text_halign = text.align_center)
    
    // High regime
    table.cell(durationTable, 0, 3, "HIGH", 
         text_color = color.red, 
         text_size = size.small,
         text_halign = text.align_left)
    table.cell(durationTable, 1, 3, currentRegime == 2 ? str.tostring(currentBars) : "—", 
         text_color = currentRegime == 2 ? color.red : color.gray, 
         text_size = size.small,
         text_halign = text.align_center)
    table.cell(durationTable, 2, 3, highDurationLower > 0 ? str.tostring(highDurationLower, "#.##") : "N/A", 
         text_color = color.red, 
         text_size = size.small,
         text_halign = text.align_center)
    table.cell(durationTable, 3, 3, avgHighDuration > 0 ? str.tostring(avgHighDuration, "#.##") : "N/A", 
         text_color = color.red, 
         text_size = size.small,
         text_halign = text.align_center)
    table.cell(durationTable, 4, 3, highDurationUpper > 0 ? str.tostring(highDurationUpper, "#.##") : "N/A", 
         text_color = color.red, 
         text_size = size.small,
         text_halign = text.align_center)



// ─── Alerts ───────────────────────────────────────────────────────────────────
// Alert: Regime Change (Any)
alertcondition(regimeChanged, 
    title = "Volatility Regime Change", 
    message = "Volatility regime has changed")
    
// Alert: Low Volatility Regime (Green)
alertcondition(currentRegime == 0 and lastRegimeState != 0, 
    title = "Low Volatility Regime", 
    message = "Volatility has entered LOW regime (green)")

// Alert: Neutral Volatility Regime (Gray)
alertcondition(currentRegime == 1 and lastRegimeState != 1, 
    title = "Neutral Volatility Regime", 
    message = "Volatility has entered NEUTRAL regime (gray)")

// Alert: High Volatility Regime (Red)
alertcondition(currentRegime == 2 and lastRegimeState != 2, 
    title = "High Volatility Regime", 
    message = "Volatility has entered HIGH regime (red)")
````
