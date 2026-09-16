<!-- tradingview-pine-id: PUB;a672276ccb844ee7991def0665fd0e7d -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Daily Relative Volume+

Source: https://www.tradingview.com/script/7FjMNVUk-Daily-Relative-Volume/

## Description

Daily Relative Volume+

This indicator is designed to show how active the current session is relative to recent history and whether volume is developing at an unusually strong or weak pace.

It is intended specifically for the 1D chart and focuses on regular-session volume.

Relative Volume

RVOL provides a straightforward view of how current session volume compares with recent completed sessions.

The current developing session is kept separate from the historical reference so the comparison remains anchored to completed trading days.

RVOL Pace

RVOL Pace adds time-of-day context to traditional daily RVOL.

Instead of treating an unfinished trading session as directly comparable with completed days, it evaluates how current activity is progressing relative to the stock's own historical intraday volume behavior.

The live RVOL Pace calculation begins once one minute of regular-session data is available.

This is intended to make live daily RVOL more useful earlier in the session, when a simple comparison with completed daily volume can otherwise be misleading.

After the session is complete, RVOL Pace converges with realized RVOL.

Average Volume and Dollar Volume

The indicator also includes:

[*]A conventional daily Average Volume MA.
[*]Average Dollar Volume for a broader view of typical trading liquidity.
[*]These use a separate Average Volume Length setting.

The Average Volume MA can be shown or hidden independently.

Volume Coloring

When Color Bars Based On Previous Close is enabled, price direction is based on the current close versus the previous close.

When disabled, direction is based on the current close versus the current bar's open.

Live-session coloring incorporates RVOL Pace, while completed sessions reflect realized RVOL.

Dashboard

The configurable table can display:

[*]RVOL
[*]RVOL Pace
[*]Average Volume
[*]Average Dollar Volume

Usage and Limitations

[*]Designed only for the 1D timeframe.
[*]RVOL-related calculations focus on regular-session activity.
[*]RVOL Pace is a historical volume-based estimate, not a prediction of price direction.
[*]News, catalysts, and unusually event-driven sessions can cause final volume to differ substantially from the pace reading.

Methodology

Traditional daily RVOL is useful, but it can be difficult to interpret while the trading day is still developing.

Daily RVOL+ improves on this by adding a time-aware view of current volume progression, giving more context to whether today's activity is merely high so far or is developing into an unusually active session.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at
// https://mozilla.org/MPL/2.0/
// © cmacktrades

//@version=6
indicator(
    "Daily Relative Volume+",
    shorttitle = "Daily RVOL+",
    overlay = false,
    format = format.volume,
    max_bars_back = 300
)

// ============================================================================
// 1. Constants
// ============================================================================

const string GROUP_CALCULATIONS = "Calculations"
const string GROUP_VISUALS = "Volume Visuals"
const string GROUP_TABLE_ROWS = "Table Rows"
const string GROUP_TABLE_STYLE = "Table Style"

const int MAX_EMPTY_ROWS = 10
const int MAX_DATA_ROWS = 4
const int MAX_TABLE_ROWS = MAX_DATA_ROWS + MAX_EMPTY_ROWS * 2
const int MAX_RVOL_LENGTH = 250
const int LOWER_TF_BARS = 100000

const string MARKET_TIMEZONE = "America/New_York"

// ============================================================================
// 2. Inputs
// ============================================================================

// Relative Volume calculations.
//
// Today's developing session is excluded from the historical RVOL benchmark.
// The same lookback is also used by the RVOL Pace completion-fraction model.
int rvolLength = input.int(
    20,
    title = "Relative Volume Length",
    minval = 1,
    maxval = MAX_RVOL_LENGTH,
    tooltip = "Compares today's regular-session volume with the average volume of the specified number of prior completed regular trading sessions.\n\nThe current developing session is excluded. This lookback also drives RVOL Pace.",
    group = GROUP_CALCULATIONS
)

// Traditional Average Volume and Average Dollar Volume.
//
// The current developing daily bar participates in both calculations.
int volLength = input.int(
    50,
    title = "Average Volume Length",
    minval = 1,
    tooltip = "Controls the conventional moving averages used for Average Volume and Average Dollar Volume over the specified number of daily bars.\n\nThe current developing daily bar participates in both calculations.",
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

// Volume colors.
color aboveAvgUpColor = input.color(
    color.new(color.green, 0),
    title = "Above Average RVOL - Up",
    group = GROUP_VISUALS
)

color belowAvgUpColor = input.color(
    color.new(color.gray, 50),
    title = "Below Average RVOL - Up",
    group = GROUP_VISUALS
)

color aboveAvgDownColor = input.color(
    color.new(color.red, 0),
    title = "Above Average RVOL - Down",
    group = GROUP_VISUALS
)

color belowAvgDownColor = input.color(
    color.new(color.gray, 50),
    title = "Below Average RVOL - Down",
    group = GROUP_VISUALS
)

// Average Volume MA customization.
//
// This toggle affects only the plotted MA. The underlying Average Volume
// and Average Dollar Volume calculations remain active.
bool showAverageVolumeMA = input.bool(
    false,
    title = "Show Average Volume MA",
    group = GROUP_VISUALS
)

color averageVolumeColor = input.color(
    color.white,
    title = "Average Volume MA Color",
    group = GROUP_VISUALS
)

int averageVolumeLineWidth = input.int(
    1,
    title = "Average Volume MA Line Width",
    minval = 1,
    maxval = 5,
    group = GROUP_VISUALS
)

// Table row visibility.
bool showRvol = input.bool(
    true,
    title = "Show RVOL",
    group = GROUP_TABLE_ROWS
)

bool showRvolPace = input.bool(
    true,
    title = "Show RVOL Pace",
    group = GROUP_TABLE_ROWS
)

bool showAvgVol = input.bool(
    true,
    title = "Show Average Volume",
    group = GROUP_TABLE_ROWS
)

bool showAvgDollarVol = input.bool(
    true,
    title = "Show Average Dollar Volume",
    group = GROUP_TABLE_ROWS
)

int emptyRowsAbove = input.int(
    0,
    title = "Empty Rows Above",
    minval = 0,
    maxval = MAX_EMPTY_ROWS,
    group = GROUP_TABLE_ROWS
)

int emptyRowsBelow = input.int(
    0,
    title = "Empty Rows Below",
    minval = 0,
    maxval = MAX_EMPTY_ROWS,
    group = GROUP_TABLE_ROWS
)

// Table position.
string tablePosition = input.string(
    position.top_right,
    title = "Table Position",
    options = [
        position.top_left,
        position.top_center,
        position.top_right,
        position.middle_left,
        position.middle_center,
        position.middle_right,
        position.bottom_left,
        position.bottom_center,
        position.bottom_right
    ],
    group = GROUP_TABLE_STYLE
)

// Table/text size.
string tableSize = input.string(
    size.small,
    title = "Table Size",
    options = [
        size.auto,
        size.tiny,
        size.small,
        size.normal,
        size.large,
        size.huge
    ],
    group = GROUP_TABLE_STYLE
)

// Text alignment.
string leftColumnAlign = input.string(
    text.align_right,
    title = "Left Column Alignment",
    options = [
        text.align_left,
        text.align_center,
        text.align_right
    ],
    group = GROUP_TABLE_STYLE
)

string rightColumnAlign = input.string(
    text.align_right,
    title = "Right Column Alignment",
    options = [
        text.align_left,
        text.align_center,
        text.align_right
    ],
    group = GROUP_TABLE_STYLE
)

// Table colors.
color leftTextColor = input.color(
    color.new(color.white, 0),
    title = "Left Column Text Color",
    group = GROUP_TABLE_STYLE
)

color rightTextColor = input.color(
    color.new(color.white, 0),
    title = "Right Column Text Color",
    group = GROUP_TABLE_STYLE
)

// Pine uses 0 transparency = fully opaque and 100 = fully transparent.
// Therefore 0% opacity is represented by transparency = 100.
color tableBackgroundColor = input.color(
    color.new(#1e222d, 100),
    title = "Background Color",
    group = GROUP_TABLE_STYLE
)

color tableBorderColor = input.color(
    color.gray,
    title = "Border Color",
    group = GROUP_TABLE_STYLE
)

color tableFrameColor = input.color(
    color.gray,
    title = "Frame Color",
    group = GROUP_TABLE_STYLE
)

int tableBorderWidth = input.int(
    0,
    title = "Border Width",
    minval = 0,
    maxval = 10,
    group = GROUP_TABLE_STYLE
)

int tableFrameWidth = input.int(
    0,
    title = "Frame Width",
    minval = 0,
    maxval = 10,
    group = GROUP_TABLE_STYLE
)

// ============================================================================
// 3. Daily Chart / Session Setup
// ============================================================================

// This indicator is intentionally designed for a 1-day chart.
if not (timeframe.isdaily and timeframe.multiplier == 1)
    runtime.error("Relative Volume+ is designed for a 1D chart.")

// Explicit regular-session ticker.
string regularSessionTicker = ticker.new(
    syminfo.prefix,
    syminfo.ticker,
    session.regular
)

// Current New York time.
int nyHour = hour(timenow, MARKET_TIMEZONE)
int nyMinute = minute(timenow, MARKET_TIMEZONE)
int currentMinuteOfDay = nyHour * 60 + nyMinute

// Regular U.S. session: 9:30 AM through 4:00 PM.
bool isActiveSession = currentMinuteOfDay >= 570 and currentMinuteOfDay < 960

// Only project RVOL Pace on the current realtime daily bar.
bool useLiveProjection = barstate.islast and barstate.isrealtime and isActiveSession

// ============================================================================
// 4. Intraday Volume Helper
// ============================================================================

// Returns cumulative volume from the supplied intrabar arrays
// before the specified minute of the day.
//
// Using "< cutoffMinute" means the currently developing 1-minute bar
// is excluded from the projection.
volumeBeforeMinute(
    array<float> volumes,
    array<int> minutes,
    int cutoffMinute
) =>
    float throughVolume = 0.0
    int itemCount = math.min(array.size(volumes), array.size(minutes))

    if itemCount > 0
        for i = 0 to itemCount - 1
            float intrabarVolume = array.get(volumes, i)
            int intrabarMinute = array.get(minutes, i)

            if not na(intrabarVolume) and intrabarMinute < cutoffMinute
                throughVolume += intrabarVolume

    throughVolume

// ============================================================================
// 5. Daily Volume Calculations
// ============================================================================

// Current daily regular-session volume.
float currentVolume = request.security(
    regularSessionTicker,
    "D",
    volume
)

// Traditional Average Volume SMA.
//
// This intentionally includes today's developing daily bar.
float averageVolume = request.security(
    regularSessionTicker,
    "D",
    ta.sma(volume, volLength)
)

// RVOL historical benchmark.
//
// Today's developing session is excluded.
//
// With Relative Volume Length = 20, this is the average volume
// of the previous 20 completed regular sessions.
float relativeVolumeAverage = request.security(
    regularSessionTicker,
    "D",
    ta.sma(volume[1], rvolLength)
)

// ============================================================================
// 6. Traditional RVOL
// ============================================================================
//
// RVOL = today's volume so far
//        ---------------------
//        average volume of prior N completed sessions

float relativeVolumeRatio = na

if not na(relativeVolumeAverage) and relativeVolumeAverage != 0
    relativeVolumeRatio := currentVolume / relativeVolumeAverage

float relativeVolumePercent = na

if not na(relativeVolumeRatio)
    relativeVolumePercent := relativeVolumeRatio * 100

// ============================================================================
// 7. Traditional Average Dollar Volume
// ============================================================================
//
// Traditional average daily dollar volume:
//
//     Average of (Daily Close × Daily Volume)
//
// over the user-selected Average Volume Length.
//
// Like the traditional Average Volume SMA above, the developing current
// daily bar participates in the calculation.
//
// This is intentionally different from:
//
//     current price × average share volume
//
// because that would apply today's price to all historical volume periods
// rather than averaging each period's own dollar-volume observation.

float averageDollarVolume = request.security(
    regularSessionTicker,
    "D",
    ta.sma(close * volume, volLength)
)

// ============================================================================
// 8. Intraday Data for RVOL Pace
// ============================================================================
//
// Request 1-minute regular-session volume for each daily chart bar.

array<float> intrabarVolumes = request.security_lower_tf(
    regularSessionTicker,
    "1",
    volume,
    calc_bars_count = LOWER_TF_BARS
)

// Request each 1-minute bar's New York minute-of-day.
array<int> intrabarMinutes = request.security_lower_tf(
    regularSessionTicker,
    "1",
    hour(time, MARKET_TIMEZONE) * 60 + minute(time, MARKET_TIMEZONE),
    calc_bars_count = LOWER_TF_BARS
)

// ============================================================================
// 9. Historical Completion-Fraction Model
// ============================================================================
//
// For every prior RVOL-lookback session:
//
//     completionFraction =
//         volume traded by current time
//         -----------------------------
//         that session's final volume
//
// The average completion fraction is then used to project today's
// end-of-day volume from completed 1-minute regular-session bars.

float completedCurrentVolume = na
float expectedCompletionFraction = na
float projectedEndOfDayVolume = na
int validHistoryDays = 0

if useLiveProjection and currentMinuteOfDay > 570

    completedCurrentVolume := volumeBeforeMinute(
        intrabarVolumes,
        intrabarMinutes,
        currentMinuteOfDay
    )

    float completionFractionSum = 0.0

    for dayOffset = 1 to rvolLength

        array<float> historicalVolumes = intrabarVolumes[dayOffset]
        array<int> historicalMinutes = intrabarMinutes[dayOffset]

        float historicalFullVolume = currentVolume[dayOffset]

        if not na(historicalVolumes) and not na(historicalMinutes) and not na(historicalFullVolume) and historicalFullVolume > 0

            float historicalThroughVolume = volumeBeforeMinute(
                historicalVolumes,
                historicalMinutes,
                currentMinuteOfDay
            )

            float completionFraction = historicalThroughVolume / historicalFullVolume

            if not na(completionFraction) and completionFraction > 0
                completionFractionSum += completionFraction
                validHistoryDays += 1

    // Require all requested historical sessions to be available.
    if validHistoryDays == rvolLength
        expectedCompletionFraction := completionFractionSum / validHistoryDays

        if expectedCompletionFraction > 0 and completedCurrentVolume > 0
            projectedEndOfDayVolume := completedCurrentVolume / expectedCompletionFraction

// ============================================================================
// 10. RVOL Pace
// ============================================================================
//
// Live regular session:
//
//     RVOL Pace =
//         projected end-of-day volume
//         ---------------------------
//         prior N-session avg volume
//
// After the close and on historical bars, RVOL Pace equals realized RVOL.

float rvolPace = relativeVolumeRatio

if useLiveProjection
    rvolPace := na

    if not na(projectedEndOfDayVolume) and not na(relativeVolumeAverage) and relativeVolumeAverage != 0
        rvolPace := projectedEndOfDayVolume / relativeVolumeAverage

// ============================================================================
// 11. Volume Colors and Plots
// ============================================================================

// Checked:
//     Current close >= previous close = Up / unchanged.
//
// Unchecked:
//     Current close >= current open = Up / unchanged.
bool isUp = false

if colorBarsBasedOnPreviousClose
    isUp := not na(close[1]) and close >= close[1]
else
    isUp := close >= open

// Live bar:
//     projected EOD RVOL Pace determines above/below-average coloring.
//
// Completed bars:
//     realized RVOL determines coloring.
bool isHighVolume = not na(rvolPace) and rvolPace > 1.0

color volumeColor = isUp ? (isHighVolume ? aboveAvgUpColor : belowAvgUpColor) : (isHighVolume ? aboveAvgDownColor : belowAvgDownColor)

// Actual daily regular-session volume.
plot(
    currentVolume,
    title = "Volume",
    style = plot.style_columns,
    color = volumeColor
)

// Conventional Average Volume MA.
//
// The toggle affects display only. The underlying Average Volume and
// Average Dollar Volume calculations continue regardless.
plot(
    showAverageVolumeMA ? averageVolume : na,
    title = "Average Volume",
    color = averageVolumeColor,
    linewidth = averageVolumeLineWidth,
    style = plot.style_line
)

// ============================================================================
// 12. Formatting Functions
// ============================================================================

formatRatio(float value) =>
    na(value) ? "N/A" : str.tostring(value, "#.##") + "x"

formatWholePercent(float value) =>
    na(value) ? "N/A" : str.tostring(value, "0") + "%"

formatCompactNumber(float value) =>
    if na(value)
        "N/A"
    else
        float adjustedValue = value
        string unitSuffix = ""

        if value >= 1000000000
            adjustedValue := value / 1000000000
            unitSuffix := "B"
        else if value >= 1000000
            adjustedValue := value / 1000000
            unitSuffix := "M"
        else if value >= 1000
            adjustedValue := value / 1000
            unitSuffix := "K"

        str.tostring(adjustedValue, "0.00") + unitSuffix

formatDollarVolume(float value) =>
    na(value) ? "N/A" : "$" + formatCompactNumber(value)

// ============================================================================
// 13. Table Functions
// ============================================================================

drawTableRow(
    table tableId,
    int row,
    string labelText,
    string valueText
) =>
    table.cell(
        tableId,
        0,
        row,
        labelText,
        text_color = leftTextColor,
        text_halign = leftColumnAlign,
        text_size = tableSize,
        bgcolor = tableBackgroundColor
    )

    table.cell(
        tableId,
        1,
        row,
        valueText,
        text_color = rightTextColor,
        text_halign = rightColumnAlign,
        text_size = tableSize,
        bgcolor = tableBackgroundColor
    )

drawEmptyRow(
    table tableId,
    int row
) =>
    table.cell(
        tableId,
        0,
        row,
        " ",
        text_color = leftTextColor,
        text_halign = leftColumnAlign,
        text_size = tableSize,
        bgcolor = tableBackgroundColor
    )

    table.cell(
        tableId,
        1,
        row,
        " ",
        text_color = rightTextColor,
        text_halign = rightColumnAlign,
        text_size = tableSize,
        bgcolor = tableBackgroundColor
    )

// ============================================================================
// 14. Dashboard Table
// ============================================================================

var table rvolTable = table.new(
    tablePosition,
    2,
    MAX_TABLE_ROWS,
    bgcolor = tableBackgroundColor,
    border_width = tableBorderWidth,
    border_color = tableBorderColor,
    frame_width = tableFrameWidth,
    frame_color = tableFrameColor
)

if barstate.islast

    table.clear(
        rvolTable,
        0,
        0,
        1,
        MAX_TABLE_ROWS - 1
    )

    int currentRow = 0

    if emptyRowsAbove > 0
        for emptyRow = 0 to emptyRowsAbove - 1
            drawEmptyRow(
                rvolTable,
                currentRow
            )

            currentRow += 1

    if showRvol
        drawTableRow(
            rvolTable,
            currentRow,
            "RVOL",
            formatWholePercent(relativeVolumePercent)
        )

        currentRow += 1

    if showRvolPace
        drawTableRow(
            rvolTable,
            currentRow,
            "RVOL Pace",
            formatRatio(rvolPace)
        )

        currentRow += 1

    if showAvgVol
        drawTableRow(
            rvolTable,
            currentRow,
            "Avg Vol.",
            formatCompactNumber(averageVolume)
        )

        currentRow += 1

    if showAvgDollarVol
        drawTableRow(
            rvolTable,
            currentRow,
            "Avg $ Vol.",
            formatDollarVolume(averageDollarVolume)
        )

        currentRow += 1

    if emptyRowsBelow > 0
        for emptyRow = 0 to emptyRowsBelow - 1
            drawEmptyRow(
                rvolTable,
                currentRow
            )

            currentRow += 1
````
