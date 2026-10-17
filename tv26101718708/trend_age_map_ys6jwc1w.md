# Trend Age Map

- url: https://www.tradingview.com/script/ys6JWc1w-Trend-Age-Map/
- type: indicator
- pine_id: PUB;e0de7e214bb741e393f26759722281a5
- version: 1.0

## Description

Trend Age Map is a visual trend-segmentation and historical-context indicator.

Instead of displaying only the current market direction, the script divides the chart into completed and active uptrend and downtrend segments. Each segment is measured by its duration in bars and its percentage magnitude, allowing the current trend to be viewed in the context of previous trends from the same chart.

HOW IT WORKS

During an uptrend, the script tracks the highest price reached by the active segment. The uptrend ends when the closing price retraces from that extreme by the selected reversal distance.

During a downtrend, the script tracks the lowest price reached by the active segment. The downtrend ends when the closing price rises from that extreme by the selected reversal distance.

When a reversal is confirmed, the completed trend is stored as a historical sample and a new segment begins from the previous trend's extreme.

REVERSAL MODES

1. Adaptive ATR

This is the default mode.

The reversal distance is calculated from ATR on the active chart timeframe. Because each timeframe uses its own bars and volatility, changing from a daily chart to an hourly or minute chart recalculates the trend structure for that timeframe.

Three adaptive sensitivity settings are available:

- Fast: uses 2.0 x ATR and produces more frequent, shorter segments.
- Balanced: uses 3.5 x ATR and provides a middle-ground structure.
- Slow: uses 5.0 x ATR and retains only larger trend movements.

2. Percent

The reversal distance is a fixed percentage of the latest trend extreme.

Because the percentage is independent of timeframe volatility, the same major trend structure may remain visible across several timeframes.

3. ATR

This mode allows the user to select a manual ATR multiplier.

TREND BOXES

Completed uptrends are displayed with teal boxes.

Completed downtrends are displayed with red boxes.

The vertical range of each completed box represents the movement from the segment's starting price to its final extreme. Its horizontal width represents the segment's duration.

The active trend is displayed as a provisional box with a dashed border. This box continues to extend and update until a qualifying reversal is confirmed.

Historical duration and percentage labels are optional and disabled by default to keep lower-timeframe charts clean.

HISTORICAL CONTEXT

The script maintains separate historical samples for completed uptrends and downtrends.

For the active trend, it calculates:

- Current direction.
- Current age in bars.
- Current percentage magnitude.
- Age percentile relative to previous trends in the same direction.
- Magnitude percentile relative to previous trends in the same direction.
- Number of comparable completed trends.
- Effective ATR multiplier when an ATR-based mode is active.

These values are available in the Data Window and are not displayed as an information box on the chart.

The percentile values describe where the current trend ranks within the loaded chart history. They are descriptive comparisons, not probabilities that the trend will continue or reverse.

USER CONTROLS

The script includes controls for:

- Reversal calculation mode.
- Adaptive sensitivity.
- Manual percentage or ATR threshold.
- ATR calculation length.
- Minimum trend duration.
- Reversal confirmation on candle close.
- Historical and current trend-box visibility.
- Optional duration and magnitude labels.
- Maximum number of retained drawings.
- Maximum number of retained statistical samples.
- Box transparency.
- Uptrend and downtrend colors.

LOW-TIMEFRAME HANDLING

Drawings use time-based coordinates so the indicator can operate across long intraday datasets without relying on distant bar-index coordinates.

The number of historical drawings and statistical samples is capped. When a selected limit is exceeded, the oldest retained item is removed. Lower drawing limits may improve chart performance on small timeframes.

ALERTS

Alert conditions are available when:

- A new uptrend segment is confirmed.
- A new downtrend segment is confirmed.

When candle-close confirmation is enabled, these events are confirmed only after the active bar closes.

REPAINTING AND BEHAVIOR

The current trend box is provisional by design. It changes as the active trend extends, forms a new extreme, or eventually reverses.

With "Confirm reversals on candle close" enabled, a trend-direction change is accepted only after the candle closes.

After a reversal is confirmed, the completed trend box is no longer modified during normal chart operation.

Changing the symbol, timeframe, historical dataset, reversal mode, sensitivity, or other calculation settings causes the indicator to recalculate its historical segmentation.

If candle-close confirmation is disabled, the current trend state can change while the realtime candle is forming.

The first trend begins from the first available bar in the loaded dataset, so its starting point should be considered approximate.

LIMITATIONS

Trend segmentation depends on the selected reversal threshold. A faster setting creates more segments and reacts to smaller movements, while a slower setting retains broader movements.

ATR-based calculations adapt to the volatility of the active timeframe, so structures are not expected to remain identical when the timeframe changes.

The displayed history is limited by the selected maximum drawing and sample settings.

Percentile readings depend entirely on the completed trends available in the loaded chart dataset. They do not represent universal market statistics.

Trend Age Map is a descriptive visual-analysis tool. It does not predict when a trend will end, does not place orders, and should not be interpreted as a standalone buy or sell system.

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
// (c) ADXAE

//@version=6
// ============================================================================
// Trend Age Map
// ============================================================================
// Segments the chart into historical trends. A trend ends when price retraces
// by the selected percentage or ATR distance from its latest extreme.
//
// Adaptive ATR is the default. It uses ATR calculated on the active chart
// timeframe, so changing from daily to hourly or minute charts recalculates
// the trend structure from that timeframe's own volatility and bars.
//
// Finished trends can be shown as historical boxes. The current trend remains
// provisional and its box updates until a reversal is confirmed.
//
// Low-timeframe safeguards:
// - Drawings use xloc.bar_time, avoiding the bar-index distance limitation.
// - Historical boxes and labels are capped and the oldest drawings are deleted.
// - Statistical samples are capped independently.
// - Reversals can be confirmed only after candle close.
//
// No information label is drawn on the chart. Current statistics remain
// available in the Data Window.
//
// This is a descriptive visual tool. It measures past and current trend age
// and magnitude; it does not forecast when a trend will end.
// ============================================================================

indicator(
     title            = "Trend Age Map",
     shorttitle       = "TrendAge",
     overlay          = true,
     max_boxes_count  = 500,
     max_labels_count = 500
)

// ============================================================================
// Inputs
// ============================================================================

string grpTrend = "1) Trend Definition"

string revMode = input.string(
     defval  = "Adaptive ATR",
     title   = "Reversal mode",
     options = ["Adaptive ATR", "Percent", "ATR"],
     group   = grpTrend,
     tooltip = "Adaptive ATR uses volatility from the active chart timeframe, so trend boxes naturally change when the timeframe changes. Percent uses the same percentage on every timeframe and can therefore preserve the same major boxes."
)

string adaptiveSpeed = input.string(
     defval  = "Balanced",
     title   = "Adaptive sensitivity",
     options = ["Fast", "Balanced", "Slow"],
     group   = grpTrend,
     active  = revMode == "Adaptive ATR",
     tooltip = "Fast creates more, shorter trend segments. Balanced is the default. Slow keeps only larger swings."
)

float revPct = input.float(
     defval  = 10.0,
     title   = "Reversal percent",
     minval  = 0.5,
     maxval  = 90.0,
     step    = 0.5,
     group   = grpTrend,
     active  = revMode == "Percent",
     tooltip = "A fixed percentage is independent of chart timeframe. The same major trend boxes may therefore appear on several timeframes."
)

float revAtrMult = input.float(
     defval  = 5.0,
     title   = "Manual reversal ATR multiple",
     minval  = 0.5,
     maxval  = 50.0,
     step    = 0.5,
     group   = grpTrend,
     active  = revMode == "ATR"
)

int atrLen = input.int(
     defval  = 14,
     title   = "ATR length",
     minval  = 1,
     maxval  = 500,
     group   = grpTrend,
     active  = revMode != "Percent"
)

int minTrendBars = input.int(
     defval  = 2,
     title   = "Minimum trend duration",
     minval  = 1,
     maxval  = 100,
     group   = grpTrend,
     tooltip = "A reversal is ignored until the current trend has lasted at least this many bars. This reduces very short low-timeframe swings."
)

bool confirmReversalOnClose = input.bool(
     defval  = true,
     title   = "Confirm reversals on candle close",
     group   = grpTrend,
     tooltip = "Recommended. Prevents the current trend direction from changing intrabar before the candle closes."
)

string grpDisplay = "2) Display"

bool showBoxes = input.bool(
     defval = true,
     title  = "Show trend boxes",
     group  = grpDisplay
)

bool showFinishedBoxes = input.bool(
     defval = true,
     title  = "Show finished trend boxes",
     group  = grpDisplay,
     active = showBoxes
)

bool showCurrentBox = input.bool(
     defval = true,
     title  = "Show current provisional box",
     group  = grpDisplay,
     active = showBoxes
)

bool showBoxLabels = input.bool(
     defval  = false,
     title   = "Show duration / size labels",
     group   = grpDisplay,
     active  = showBoxes and showFinishedBoxes,
     tooltip = "OFF by default to keep lower-timeframe charts clean."
)

int maxHistoricalTrends = input.int(
     defval  = 120,
     title   = "Maximum historical drawings",
     minval  = 10,
     maxval  = 450,
     group   = grpDisplay,
     tooltip = "Only the most recent completed trend boxes are retained. Lower values improve chart performance on small timeframes."
)

int maxStatsSamples = input.int(
     defval  = 400,
     title   = "Maximum statistical samples",
     minval  = 20,
     maxval  = 2000,
     group   = grpDisplay,
     tooltip = "Maximum number of completed uptrends and downtrends retained for percentile calculations."
)

int finishedBoxTransparency = input.int(
     defval  = 90,
     title   = "Finished box transparency",
     minval  = 0,
     maxval  = 100,
     group   = grpDisplay
)

int currentBoxTransparency = input.int(
     defval  = 94,
     title   = "Current box transparency",
     minval  = 0,
     maxval  = 100,
     group   = grpDisplay
)

color colUp = input.color(
     defval = color.teal,
     title  = "Uptrend color",
     group  = grpDisplay
)

color colDn = input.color(
     defval = color.red,
     title  = "Downtrend color",
     group  = grpDisplay
)

// ============================================================================
// Helpers and storage
// ============================================================================

float atrValue = ta.atr(atrLen)

float adaptiveAtrMultiple = adaptiveSpeed == "Fast" ? 2.0 : adaptiveSpeed == "Balanced" ? 3.5 : 5.0

f_reversalDistance(float extremeValue) =>
    float distance = na

    if revMode == "Percent"
        distance := extremeValue * revPct / 100.0
    else if revMode == "ATR"
        distance := revAtrMult * atrValue
    else
        distance := adaptiveAtrMultiple * atrValue

    distance

var array<float> upDuration = array.new<float>()
var array<float> upMagnitude = array.new<float>()
var array<float> downDuration = array.new<float>()
var array<float> downMagnitude = array.new<float>()

var array<box> historicalBoxes = array.new<box>()
var array<label> historicalLabels = array.new<label>()

f_pushSample(array<float> values, float value) =>
    array.push(values, value)

    while array.size(values) > maxStatsSamples
        array.shift(values)

f_storeBox(box drawing) =>
    array.push(historicalBoxes, drawing)

    while array.size(historicalBoxes) > maxHistoricalTrends
        box.delete(array.shift(historicalBoxes))

f_storeLabel(label drawing) =>
    array.push(historicalLabels, drawing)

    while array.size(historicalLabels) > maxHistoricalTrends
        label.delete(array.shift(historicalLabels))

f_percentBelow(array<float> values, float value) =>
    int sampleCount = array.size(values)
    float result = na

    if sampleCount > 0
        int belowCount = 0

        for index = 0 to sampleCount - 1
            if array.get(values, index) < value
                belowCount += 1

        result := belowCount * 100.0 / sampleCount

    result

f_finalizeTrend(
     int direction,
     int startIndex,
     int startTimeValue,
     float startPrice,
     int extremeIndex,
     int extremeTimeValue,
     float extremePrice) =>

    int duration = extremeIndex - startIndex
    float signedMagnitude = startPrice != 0.0 ? (extremePrice / startPrice - 1.0) * 100.0 : na
    float absoluteMagnitude = math.abs(signedMagnitude)

    if duration > 0 and not na(signedMagnitude)
        if direction == 1
            f_pushSample(upDuration, duration)
            f_pushSample(upMagnitude, absoluteMagnitude)
        else
            f_pushSample(downDuration, duration)
            f_pushSample(downMagnitude, absoluteMagnitude)

        if showBoxes and showFinishedBoxes
            color trendColor = direction == 1 ? colUp : colDn

            box finishedBox = box.new(
                 left         = startTimeValue,
                 top          = math.max(startPrice, extremePrice),
                 right        = extremeTimeValue,
                 bottom       = math.min(startPrice, extremePrice),
                 xloc         = xloc.bar_time,
                 border_color = color.new(trendColor, 55),
                 border_width = 1,
                 bgcolor      = color.new(trendColor, finishedBoxTransparency)
            )

            f_storeBox(finishedBox)

            if showBoxLabels
                int middleTime = startTimeValue + int(math.round((extremeTimeValue - startTimeValue) / 2.0))
                string magnitudeText = (signedMagnitude >= 0.0 ? "+" : "") + str.tostring(signedMagnitude, "#.#") + "%"

                label finishedLabel = label.new(
                     x         = middleTime,
                     y         = math.max(startPrice, extremePrice),
                     text      = str.tostring(duration) + " bars  " + magnitudeText,
                     xloc      = xloc.bar_time,
                     style     = direction == 1 ? label.style_label_down : label.style_label_up,
                     color     = color.new(trendColor, 80),
                     textcolor = chart.fg_color,
                     size      = size.tiny
                )

                f_storeLabel(finishedLabel)

// ============================================================================
// Trend segmentation state
// ============================================================================

var int direction = 0
var float extremePrice = na
var int extremeIndex = na
var int extremeTime = na
var float trendStartPrice = na
var int trendStartIndex = na
var int trendStartTime = na

var box currentBox = na

bool uptrendStarted = false
bool downtrendStarted = false

if direction == 0
    direction := close >= open ? 1 : -1
    extremePrice := direction == 1 ? high : low
    extremeIndex := bar_index
    extremeTime := time
    trendStartPrice := direction == 1 ? low : high
    trendStartIndex := bar_index
    trendStartTime := time

bool reversalEvaluationAllowed = not confirmReversalOnClose or barstate.isconfirmed
bool minimumDurationReached = bar_index - trendStartIndex >= minTrendBars

if direction == 1
    if high > extremePrice
        extremePrice := high
        extremeIndex := bar_index
        extremeTime := time

    float reversalDistance =
         f_reversalDistance(extremePrice)

    bool reverseDown =
         reversalEvaluationAllowed and
         minimumDurationReached and
         not na(reversalDistance) and
         close <= extremePrice - reversalDistance

    if reverseDown
        f_finalizeTrend(
             1,
             trendStartIndex,
             trendStartTime,
             trendStartPrice,
             extremeIndex,
             extremeTime,
             extremePrice
        )

        direction := -1
        trendStartPrice := extremePrice
        trendStartIndex := extremeIndex
        trendStartTime := extremeTime
        extremePrice := low
        extremeIndex := bar_index
        extremeTime := time
        downtrendStarted := true

else
    if low < extremePrice
        extremePrice := low
        extremeIndex := bar_index
        extremeTime := time

    float reversalDistance =
         f_reversalDistance(extremePrice)

    bool reverseUp =
         reversalEvaluationAllowed and
         minimumDurationReached and
         not na(reversalDistance) and
         close >= extremePrice + reversalDistance

    if reverseUp
        f_finalizeTrend(
             -1,
             trendStartIndex,
             trendStartTime,
             trendStartPrice,
             extremeIndex,
             extremeTime,
             extremePrice
        )

        direction := 1
        trendStartPrice := extremePrice
        trendStartIndex := extremeIndex
        trendStartTime := extremeTime
        extremePrice := high
        extremeIndex := bar_index
        extremeTime := time
        uptrendStarted := true

// ============================================================================
// Current provisional trend box
// ============================================================================

bool drawCurrentBox = showBoxes and showCurrentBox and direction != 0

if drawCurrentBox
    color currentColor = direction == 1 ? colUp : colDn

    if na(currentBox)
        currentBox := box.new(
             left         = trendStartTime,
             top          = math.max(trendStartPrice, extremePrice),
             right        = time,
             bottom       = math.min(trendStartPrice, extremePrice),
             xloc         = xloc.bar_time,
             border_color = color.new(currentColor, 30),
             border_style = line.style_dashed,
             border_width = 1,
             bgcolor      = color.new(currentColor, currentBoxTransparency)
        )
    else
        box.set_left(currentBox, trendStartTime)
        box.set_right(currentBox, time)
        box.set_top(currentBox, math.max(trendStartPrice, extremePrice))
        box.set_bottom(currentBox, math.min(trendStartPrice, extremePrice))
        box.set_border_color(currentBox, color.new(currentColor, 30))
        box.set_bgcolor(currentBox, color.new(currentColor, currentBoxTransparency))
else if not na(currentBox)
    box.delete(currentBox)
    currentBox := na

// ============================================================================
// Current statistics — Data Window only, no on-chart information label
// ============================================================================

float currentAgeBars = direction != 0 ? bar_index - trendStartIndex : na
float currentMagnitude =
     direction != 0 and trendStartPrice != 0.0 ?
     math.abs(close / trendStartPrice - 1.0) * 100.0 :
     na

array<float> currentDurationHistory = direction == 1 ? upDuration : downDuration
array<float> currentMagnitudeHistory = direction == 1 ? upMagnitude : downMagnitude

float currentAgePercentile = f_percentBelow(currentDurationHistory, currentAgeBars)
float currentMagnitudePercentile = f_percentBelow(currentMagnitudeHistory, currentMagnitude)
float completedComparableTrends = array.size(currentDurationHistory)

plot(
     float(direction),
     title   = "Current direction: 1 up, -1 down",
     color   = color.new(color.gray, 100),
     display = display.data_window
)

plot(
     currentAgeBars,
     title   = "Current trend age in bars",
     color   = color.new(color.gray, 100),
     display = display.data_window
)

plot(
     currentMagnitude,
     title   = "Current trend magnitude %",
     color   = color.new(color.gray, 100),
     display = display.data_window
)

plot(
     currentAgePercentile,
     title   = "Current age percentile %",
     color   = color.new(color.gray, 100),
     display = display.data_window
)

plot(
     currentMagnitudePercentile,
     title   = "Current magnitude percentile %",
     color   = color.new(color.gray, 100),
     display = display.data_window
)

plot(
     completedComparableTrends,
     title   = "Comparable completed trends",
     color   = color.new(color.gray, 100),
     display = display.data_window
)

plot(
     revMode == "Percent" ? na : (revMode == "ATR" ? revAtrMult : adaptiveAtrMultiple),
     title   = "Effective reversal ATR multiple",
     color   = color.new(color.gray, 100),
     display = display.data_window
)

// ============================================================================
// Alerts
// ============================================================================

alertcondition(
     uptrendStarted,
     title   = "New uptrend segment",
     message = "Trend Age Map: a new uptrend segment was confirmed on {{ticker}} - {{interval}}."
)

alertcondition(
     downtrendStarted,
     title   = "New downtrend segment",
     message = "Trend Age Map: a new downtrend segment was confirmed on {{ticker}} - {{interval}}."
)

// ============================================================================
// End of file
// ============================================================================
````
