<!-- tradingview-pine-id: PUB;55dca5de46ae4f54b4e01898d23e9c65 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Intraday Relative Volume+

Source: https://www.tradingview.com/script/f1WSLv7z-Intraday-Relative-Volume/

## Description

Intraday Relative Volume+

This indicator is intended to measure whether an individual intraday volume bar is unusually active for its specific time of day.

It is designed as the intraday companion to Daily Relative Volume+.

Same-Time Relative Volume

Rather than comparing every intraday bar with a generic rolling volume baseline, the indicator evaluates each bar against historical activity from the same point in the trading session.

This helps account for the fact that normal volume can differ significantly between the open, midday, and the close.

The current session is kept separate from its historical benchmark, and available historical observations are used when full history is not present.

Why Time-of-Day Context Matters

Intraday volume naturally follows a strong time-of-day pattern.

A generic rolling comparison can therefore make normal opening activity look unusually high or normal midday activity look unusually low.

Intraday RVOL+ is designed to reduce that distortion by comparing each bar with more relevant historical context.

The methodology also preserves time alignment across irregular sessions, including missing bars, trading halts, and shortened trading days.

Developing Bars

A live bar is evaluated using the volume it has accumulated at that point in time, so its relative-volume classification can change as the bar develops.

Average Volume MA

The indicator also includes a conventional rolling Average Volume MA.

This is independent of the same-time RVOL methodology and provides a familiar view of recent chart-volume activity.

The MA can be shown or hidden, and its current value can be displayed on the volume scale.

Volume Coloring

When Color Bars Based On Previous Close is enabled, direction is based on the current close versus the previous close.

When disabled, direction is based on the current close versus the current bar's open.

Volume-bar classification is driven by the relative-volume methodology, not by the conventional Average Volume MA.

Sessions

The indicator follows the chart's displayed session data.

[*]On a regular-hours chart, regular-session bars are analyzed.
[*]With Extended Hours enabled, available premarket and postmarket bars can also participate.

Usage and Limitations

[*]Designed for minute-based intraday charts.
[*]Second-based and tick charts are not supported.
[*]Requires a standard time-based chart.
[*]Synthetic chart types such as Heikin Ashi, Renko, Line Break, Kagi, and Point & Figure are not supported.
[*]Relative Volume Length is limited to 68 sessions.
[*]The conventional Average Volume MA is not subject to that RVOL lookback limit.

Methodology

Traditional intraday RVOL can be distorted when it compares volume from very different parts of the trading session.

Intraday RVOL+ improves on this by adding time-of-day context, making the relative-volume signal more appropriate for intraday analysis while retaining a conventional Volume MA as a separate reference.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at
// https://mozilla.org/MPL/2.0/
// © cmacktrades

//@version=6
indicator(
    "Intraday Relative Volume+",
    shorttitle = "Intraday RVOL+",
    format = format.volume,
    overlay = false
)

// ============================================================================
// 1. Constants
// ============================================================================

const string GROUP_CALCULATIONS = "Calculations"
const string GROUP_VISUALS = "Volume Visuals"

const int MINUTES_PER_DAY = 1440
const int MAX_RVOL_LENGTH = 68
const int BUFFER_COLUMNS = MAX_RVOL_LENGTH + 1

// ============================================================================
// 2. Inputs
// ============================================================================

// Relative Volume Length
//
// Controls the historical exact same-time benchmark used for:
// - Bar RVOL
// - Above/below-average classification
// - Volume-bar coloring
int rvolLength = input.int(
    20,
    title = "Relative Volume Length",
    minval = 1,
    maxval = MAX_RVOL_LENGTH,
    tooltip = "Compares each intraday volume bar with the average volume of bars that opened at the exact same exchange-local time over the specified number of prior trading sessions.\n\nIf fewer valid prior same-time observations are available, all available observations are used.\n\nMax 68 due to Pine's matrix size limit.",
    group = GROUP_CALCULATIONS
)

// Average Volume Length
//
// Controls a conventional moving average of the most recent chart-volume bars,
// independent of the same-position RVOL calculation.
int averageVolumeLength = input.int(
    50,
    title = "Average Volume Length",
    minval = 1,
    tooltip = "Controls the conventional moving average of volume over the specified number of chart bars. The current bar participates in the moving average.",
    group = GROUP_CALCULATIONS
)

// Price-direction methodology.
//
// Checked:
//     Current close is compared with the previous close.
//
// Unchecked:
//     Current close is compared with the current bar's open.
bool colorBarsBasedOnPreviousClose = input.bool(
    true,
    title = "Color Bars Based On Previous Close",
    group = GROUP_VISUALS
)

// Above-average up volume.
color aboveAvgUpColor = input.color(
    color.new(color.green, 0),
    title = "Above Average RVOL - Up",
    group = GROUP_VISUALS
)

// Below-average up volume.
color belowAvgUpColor = input.color(
    color.new(color.gray, 50),
    title = "Below Average RVOL - Up",
    group = GROUP_VISUALS
)

// Above-average down volume.
color aboveAvgDownColor = input.color(
    color.new(color.red, 0),
    title = "Above Average RVOL - Down",
    group = GROUP_VISUALS
)

// Below-average down volume.
color belowAvgDownColor = input.color(
    color.new(color.gray, 50),
    title = "Below Average RVOL - Down",
    group = GROUP_VISUALS
)

// Average Volume MA visibility.
bool showAverageVolumeMA = input.bool(
    false,
    title = "Show Average Volume MA",
    group = GROUP_VISUALS
)

// Average Volume MA color.
color averageVolumeMAColor = input.color(
    color.white,
    title = "Average Volume MA Color",
    group = GROUP_VISUALS
)

// Average Volume MA line width.
int averageVolumeMALineWidth = input.int(
    1,
    title = "Average Volume MA Line Width",
    minval = 1,
    maxval = 5,
    group = GROUP_VISUALS
)

// ============================================================================
// 3. Chart Validation
// ============================================================================

// One RVOL matrix row represents one exchange-local minute.
//
// Second-based and tick-based charts can contain multiple bars within the
// same minute, so they are not compatible with this exact-slot methodology.
if not timeframe.isminutes
    runtime.error(
        "Intraday Relative Volume+ is designed for minute-based intraday charts."
    )

// The indicator requires standard time-based OHLCV bars.
//
// Synthetic chart types alter bar construction and therefore do not preserve
// the intended relationship between exact time, price direction, and volume.
if not chart.is_standard
    runtime.error(
        "Intraday Relative Volume+ is designed for standard time-based charts."
    )

// ============================================================================
// 4. Session-Aware Same-Time RVOL Storage
// ============================================================================
//
// The script intentionally uses the chart's own OHLCV dataset.
//
// Regular-hours chart:
//     Only regular-session bars are present and analyzed.
//
// Extended-hours chart:
//     Available premarket, regular-session, and postmarket bars participate.
//
// Each matrix row represents one exchange-local minute:
//
//     00:00 = 0
//     04:00 = 240
//     09:30 = 570
//     10:15 = 615
//     16:00 = 960
//     23:59 = 1439
//
// Each matrix column represents one trading session.
//
// 69 columns are permanently allocated:
//
//     1 current session
//     68 historical sessions
//
// Total matrix elements:
//
//     1440 × 69 = 99,360
//
// Exact clock-time storage ensures:
//
// - Missing candles remain missing.
// - Trading halts do not shift later comparisons.
// - Early-close sessions simply lack later observations.
// - Premarket bars match only equivalent premarket times.
// - Regular-session bars match only equivalent regular-session times.

var matrix<float> volMatrix = matrix.new<float>(
    MINUTES_PER_DAY,
    BUFFER_COLUMNS,
    na
)

// Circular-buffer column assigned to the current trading session.
var int sessionColumn = 0

// Detect a change in the exchange-defined trading day.
bool isNewTradingDay = ta.change(time_tradingday) != 0

// Advance to a fresh circular-buffer column when a new trading day begins.
if isNewTradingDay
    sessionColumn := (sessionColumn + 1) % BUFFER_COLUMNS

    // Clear the newly assigned current-session column.
    //
    // Time slots that do not occur during the new session therefore remain
    // genuinely missing rather than retaining stale observations.
    for slot = 0 to MINUTES_PER_DAY - 1
        matrix.set(
            volMatrix,
            slot,
            sessionColumn,
            na
        )

// Current bar's exchange-local opening minute.
int timeSlot = hour * 60 + minute

// ============================================================================
// 5. RVOL Same-Position Historical Average
// ============================================================================
//
// RVOL uses only PRIOR trading sessions.
//
// For the current time slot, the script looks backward through the most recent
// `rvolLength` trading sessions and retrieves only observations stored at the
// exact same exchange-local opening minute.
//
// Missing observations are skipped.
// Legitimate zero-volume observations remain valid.

float rvolHistoricalSum = 0.0
int rvolValidDays = 0

for dayOffset = 1 to rvolLength
    int historicalColumn = (sessionColumn - dayOffset + BUFFER_COLUMNS) % BUFFER_COLUMNS

    float historicalVolume = matrix.get(
        volMatrix,
        timeSlot,
        historicalColumn
    )

    if not na(historicalVolume)
        rvolHistoricalSum += historicalVolume
        rvolValidDays += 1

float rvolAveragePositionVolume = na

if rvolValidDays > 0
    rvolAveragePositionVolume := rvolHistoricalSum / rvolValidDays

// ============================================================================
// 6. Store Current Bar
// ============================================================================
//
// Historical bars are confirmed by definition.
//
// A live bar is stored in the matrix only when it closes. This prevents a
// partially formed realtime bar from becoming part of future RVOL history.
//
// The entire current-session column is excluded from today's RVOL benchmark.

if barstate.isconfirmed
    matrix.set(
        volMatrix,
        timeSlot,
        sessionColumn,
        volume
    )

// ============================================================================
// 7. Intraday Relative Volume
// ============================================================================
//
// Individual-bar RVOL:
//
//                         Current Bar Volume
//     ---------------------------------------------------------
//     Average Volume of Prior Exact Same-Time Intraday Bars
//
// Example:
//
// Current 10:15 volume:                  150,000
// Prior 20-session avg 10:15 volume:     100,000
//
// Bar RVOL = 1.50x
//
// A developing realtime bar uses its actual accumulated volume.
// No intrabar projection or extrapolation is applied.

bool isRvolReady = (
    rvolValidDays > 0 and
    not na(rvolAveragePositionVolume) and
    rvolAveragePositionVolume > 0
)

float barRvol = na

if isRvolReady
    barRvol := volume / rvolAveragePositionVolume

// ============================================================================
// 8. Conventional Average Volume MA
// ============================================================================
//
// This is intentionally separate from the same-position RVOL methodology.
//
// It is a conventional simple moving average of the most recent
// `averageVolumeLength` chart-volume bars.
//
// Examples:
//
// 1-minute chart + length 50:
//     50 most recent 1-minute volume bars.
//
// 5-minute chart + length 50:
//     50 most recent 5-minute volume bars.
//
// 15-minute chart + length 50:
//     50 most recent 15-minute volume bars.
//
// Like the Average Volume MA in Daily RVOL+, the current bar participates
// in the moving average.
//
// The chart's selected session dataset naturally determines which bars
// participate. If Extended Hours is displayed, extended-hours bars can
// therefore be part of the rolling MA.

float averageVolumeMA = ta.sma(
    volume,
    averageVolumeLength
)

// ============================================================================
// 9. Price Direction
// ============================================================================
//
// Checked:
//
//     Up / unchanged:
//         close >= close[1]
//
//     Down:
//         close < close[1]
//
// Unchecked:
//
//     Up / unchanged:
//         close >= open
//
//     Down:
//         close < open

bool isUp = false

if colorBarsBasedOnPreviousClose
    isUp := not na(close[1]) and close >= close[1]
else
    isUp := close >= open

// ============================================================================
// 10. Volume Classification
// ============================================================================
//
// No Quiet / Mild / Heavy classifications.
// No arbitrary threshold inputs.
//
// RVOL coloring uses one threshold:
//
// Above average:
//     Bar RVOL > 1.0x
//
// At or below average:
//     Bar RVOL <= 1.0x
//
// Importantly, the conventional Average Volume MA does NOT control
// volume-bar coloring.

bool isAboveAverage = isRvolReady and barRvol > 1.0

// ============================================================================
// 11. Volume Color
// ============================================================================
//
// Above-average + up:
//     Green
//
// Below-average + up:
//     Gray at 50% transparency by default
//
// Above-average + down:
//     Red
//
// Below-average + down:
//     Gray at 50% transparency by default
//
// Bars without sufficient RVOL history remain in the applicable
// below-average color.

color volumeColor = belowAvgDownColor

if isUp
    if isAboveAverage
        volumeColor := aboveAvgUpColor
    else
        volumeColor := belowAvgUpColor
else
    if isAboveAverage
        volumeColor := aboveAvgDownColor
    else
        volumeColor := belowAvgDownColor

// ============================================================================
// 12. Plots
// ============================================================================

// Actual intraday volume.
//
// Bar coloring is based exclusively on exact same-position RVOL.
//
// The current volume value is displayed on the pane's price scale.
plot(
    volume,
    title = "Volume",
    style = plot.style_columns,
    color = volumeColor,
    display = display.pane + display.price_scale
)

// Conventional Average Volume MA.
//
// This is an independent rolling bar-based reference, directly analogous
// to the Average Volume MA used in Daily RVOL+.
//
// When enabled, both the MA line and its current value are displayed
// on the pane's price scale.
//
// When disabled, the plotted value becomes `na`, so both disappear.
plot(
    showAverageVolumeMA ? averageVolumeMA : na,
    title = "Average Volume MA",
    color = averageVolumeMAColor,
    linewidth = averageVolumeMALineWidth,
    style = plot.style_line,
    display = display.pane + display.price_scale
)
````
