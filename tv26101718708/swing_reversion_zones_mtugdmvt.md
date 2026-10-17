# Swing Reversion Zones

- url: https://www.tradingview.com/script/mtuGdMvT-Swing-Reversion-Zones/
- type: indicator
- pine_id: PUB;4a9e572cabfd4a9fa5c431d1867adac3
- version: 1.0

## Description

Swing Reversion Zones is an adaptive mean-reversion channel built around a smoothed price trajectory. It highlights the first moments when price reaches the upper or lower boundary of the channel.
The indicator is designed to help traders evaluate how far price has moved away from its local smoothed structure and identify areas where a return toward the central trajectory may become possible.
Boundary touches are displayed as semi-transparent bubbles:
🔴 Red bubble — touch of the upper boundary
🟢 Green bubble — touch of the lower boundary
The bubbles show that price has reached a user-defined deviation zone. They are not automatic buy or sell commands.
━━━━━━━━━━━━━━━━━━
🧭 Core Concept
The indicator is based on the concept that price may revert toward a smoothed central trajectory after reaching a sufficiently large deviation from it.
The central line is not calculated as a conventional moving average. Instead, the script uses Gaussian weighting.
Bars located closer to the calculated point receive greater weight, while the influence of more distant observations gradually decreases.
This approach is designed to:
• reduce the influence of short-term market noise
• preserve the natural shape of price movement
• create a smooth central trajectory
• measure deviations relative to local market structure rather than a conventional fixed moving average
━━━━━━━━━━━━━━━━━━
⚙️ How the Channel Is Calculated
The calculation consists of several connected stages.
1. Central Trajectory
For each historical bar, the script calculates a smoothed value of the selected price source.
The weight of each observation is determined by a Gaussian function. The closer an observation is to the point being calculated, the more influence it has on the resulting value.
The Smoothing Length parameter controls the degree of smoothing:
• lower values make the central line more responsive to local price movements
• higher values create a smoother trajectory that reflects broader market structure
2. Base Deviation
After calculating the central trajectory, the script measures the absolute distance between the selected price source and the smoothed line across the processed data.
These distances are averaged to produce the base deviation value.
Unlike channels based on ATR or standard deviation, Swing Reversion Zones uses the mean absolute error between price and the Gaussian-smoothed trajectory.
3. Upper and Lower Boundaries
The distance from the central trajectory to each boundary is calculated as:
Mean Absolute Deviation × Channel Width
The resulting value is:
• added to the central trajectory to create the upper boundary
• subtracted from the central trajectory to create the lower boundary
Both boundaries remain symmetrical around the central line.
━━━━━━━━━━━━━━━━━━
🎛 Manual Channel Width Adjustment
The Channel Width setting allows users to define how sensitive the channel should be.
Lower Channel Width values
• move the boundaries closer to the central line
• produce more frequent price touches
• increase the number of bubbles
• make the indicator more sensitive to smaller deviations
Higher Channel Width values
• create a wider channel
• produce fewer boundary touches
• highlight more substantial price deviations
• reduce the number of bubbles displayed on the chart
This allows the channel to be adapted to:
• a specific trading instrument
• the selected timeframe
• current volatility conditions
• the user’s preferred analytical approach
The script does not impose a universal channel width. The user decides which degree of deviation is meaningful for the selected market.
━━━━━━━━━━━━━━━━━━
🫧 How the Touch Bubbles Are Generated
The indicator does not place a bubble on every bar that remains outside the channel.
Instead, it marks the initial touch of a boundary.
Upper Boundary Touch
A red bubble appears when:
• the current bar’s high reaches or exceeds the upper boundary
• the previous bar’s high was below the previous upper-boundary value
Lower Boundary Touch
A green bubble appears when:
• the current bar’s low reaches or falls below the lower boundary
• the previous bar’s low was above the previous lower-boundary value
This logic highlights the moment when price initially enters a deviation zone. It avoids placing a new bubble on every subsequent bar while price remains beyond the same boundary.
The bubbles are positioned directly on the channel boundary rather than at the candle’s exact high or low. This makes it easier to see which calculated channel level was reached.
━━━━━━━━━━━━━━━━━━
✦ Originality and Practical Usefulness
Gaussian smoothing and mean absolute deviation are established mathematical concepts.
The originality of Swing Reversion Zones does not come from mechanically combining unrelated indicators. It comes from the way its components are integrated into one consistent calculation framework.
Within the script:
A Gaussian-smoothed central trajectory is calculated across the available data.
The channel scale is derived from the actual average distance between price and that trajectory.
The user manually controls the final channel width through a single multiplier.
Touch bubbles are calculated directly from the user-defined channel geometry.
Changing the settings recalculates both the channel boundaries and the historical map of boundary touches.
The bubbles are not produced by a separate signal indicator placed over the channel. Their position and frequency depend entirely on the current Gaussian trajectory, the measured price deviation and the selected Channel Width value.
The result is an interactive analytical tool that allows users to define which price deviations should be considered significant for a particular market and timeframe.
━━━━━━━━━━━━━━━━━━
📌 How to Use the Indicator
After adding the indicator to a chart, begin with the default settings and observe how price interacts with the channel boundaries.
The adjustment process can then be divided into two stages.
Step 1. Adjust the Smoothing
Change Smoothing Length until the central line reflects the type of price structure you want to analyse.
A more responsive central line may be suitable for examining local fluctuations.
A smoother central line may be more appropriate for evaluating deviations from a broader price structure.
Step 2. Adjust the Channel Width
After selecting the desired smoothing level, adjust Channel Width.
The objective is not necessarily to make the boundaries touch every swing high and low. The objective is to define a deviation level that is meaningful for the selected instrument.
A channel that is too narrow may produce many insignificant touches.
A channel that is too wide may produce very few or no touch markers.
Settings should be evaluated separately for different:
• instruments
• asset classes
• timeframes
• volatility regimes
━━━━━━━━━━━━━━━━━━
🔍 Interpreting Boundary Touches
A lower-boundary touch indicates that price has reached the selected negative deviation from the central trajectory.
An upper-boundary touch indicates that price has reached the selected positive deviation.
These areas may be useful for identifying potential mean-reversion conditions. However, reaching a boundary does not guarantee a reversal.
During a strong directional move, price may:
• repeatedly reach the same side of the channel
• continue moving after a bubble appears
• remain outside the boundary for several bars
• return toward the central line only after a further expansion
For this reason, bubbles should be treated as information about the current position of price relative to the channel, not as a complete trading system.
Users may combine the touch markers with additional analysis such as:
• higher-timeframe trend direction
• swing-high and swing-low structure
• support and resistance levels
• candle behaviour following a touch
• volume analysis
• personal risk-management rules
━━━━━━━━━━━━━━━━━━
🛠 Settings
Smoothing Length
Controls the Gaussian kernel width and the degree of smoothing applied to the central trajectory.
Lower values increase responsiveness.
Higher values create stronger smoothing.
Channel Width
Multiplies the mean absolute deviation between price and the central trajectory.
This is the main setting for controlling the distance between the central line and the channel boundaries, as well as the frequency of touch bubbles.
Source
Defines the price series used in the calculation.
The default source is the closing price.
Users may select another available source, including open, high, low, HL2 or other standard price series.
Style
The visual settings allow users to adjust:
• upper-boundary colour
• lower-boundary colour
• line thickness
• bubble transparency
━━━━━━━━━━━━━━━━━━
♻️ Repainting Behaviour
Swing Reversion Zones intentionally uses repainting Gaussian smoothing.
Historical points of the central trajectory are calculated using observations located on both sides of the corresponding point. As new bars become available, previously calculated values may change.
The width of the channel is also based on the average error measured across the processed data. Changes in the available dataset may therefore affect the deviation value and the position of both boundaries.
As new data appears, the following elements may change:
• the central trajectory
• the upper and lower boundaries
• the position of historical bubbles
• the number of historical bubbles
• individual historical touch locations
The indicator is also recalculated when the user changes:
• the trading instrument
• the timeframe
• the price source
• the smoothing length
• the channel width
Repainting is an intentional part of the indicator’s design. It is used to create a smoother historical representation of the price trajectory.
Historical bubbles must not be interpreted as fixed past signals that were necessarily available in exactly the same form in real time.
For the same reason, the visual history of the indicator should not be used to estimate historical profitability or as a substitute for proper strategy testing.
━━━━━━━━━━━━━━━━━━
🔔 Alerts
The script includes two alert conditions:
Upper Channel Touch — price reaches the upper boundary
Lower Channel Touch — price reaches the lower boundary
Alert conditions are calculated relative to the current position of the channel.
To reduce intrabar fluctuations, users may configure alerts to trigger only after the bar closes.
However, waiting for bar close only reduces intrabar changes. It does not make the indicator non-repainting. The historical channel geometry may still change as new data becomes available.
━━━━━━━━━━━━━━━━━━
⚠️ Limitations
Swing Reversion Zones is an analytical indicator, not a trading strategy.
It does not:
• open or close positions
• calculate stop-loss or profit targets
• determine position size
• account for commissions or slippage
• calculate performance statistics
• guarantee that price will return to the central trajectory
• evaluate the quality of each individual trading opportunity
Standard candlestick charts are recommended for interpretation.
On non-standard chart types, OHLC values may be synthetic. As a result, boundary touches may not correspond to actual traded market prices.
Users remain responsible for selecting the indicator settings, applying additional confirmation methods, defining entry and exit rules, and managing risk.

## Source Code

````pine
//@version=6

const int MAX_HISTORY = 5000
const int MAX_LABELS  = 500

indicator(
     "Swing Reversion Zones",
     overlay = true,
     max_polylines_count = 10,
     max_labels_count = MAX_LABELS,
     max_bars_back = MAX_HISTORY
)

// ==========================================
// Inputs
// ==========================================

smoothingLength = input.float(
     9.0,
     "Smoothing Length",
     minval = 1.0,
     maxval = 50.0,
     step = 0.5,
     tooltip = "Controls how strongly the middle line is smoothed."
)

channelWidth = input.float(
     3.0,
     "Channel Width",
     minval = 0.1,
     maxval = 20.0,
     step = 0.1,
     tooltip = "Manually adjusts the distance between the middle line and the channel boundaries."
)

source = input.source(
     close,
     "Source"
)

// ==========================================
// Style
// ==========================================

upperColor = input.color(
     color.rgb(64, 217, 143),
     "Upper Channel",
     inline = "channelColors",
     group = "Style"
)

lowerColor = input.color(
     color.rgb(246, 113, 113),
     "Lower Channel",
     inline = "channelColors",
     group = "Style"
)

lineWidth = input.int(
     2,
     "Line Thickness",
     minval = 1,
     maxval = 4,
     group = "Style"
)

bubbleTransparency = input.int(
     65,
     "Bubble Transparency",
     minval = 0,
     maxval = 95,
     group = "Style"
)

middleColor = color.new(color.gray, 70)

// ==========================================
// Gaussian function
// ==========================================

gauss(float distance, float bandwidth) =>
    math.exp(
         -(distance * distance) /
         (2.0 * bandwidth * bandwidth)
    )

// ==========================================
// Drawing storage
// ==========================================

var polyline upperPolyline  = na
var polyline middlePolyline = na
var polyline lowerPolyline  = na

var array<label> signalLabels = array.new<label>()

bool upperTouchNow = false
bool lowerTouchNow = false

// ==========================================
// Repainted channel calculation
// ==========================================

if barstate.islast

    // --------------------------------------
    // Delete previous channel
    // --------------------------------------

    if not na(upperPolyline)
        polyline.delete(upperPolyline)

    if not na(middlePolyline)
        polyline.delete(middlePolyline)

    if not na(lowerPolyline)
        polyline.delete(lowerPolyline)

    upperPolyline  := na
    middlePolyline := na
    lowerPolyline  := na

    // --------------------------------------
    // Delete previous signal bubbles
    // --------------------------------------

    int previousLabelCount = array.size(signalLabels)

    if previousLabelCount > 0
        for labelIndex = 0 to previousLabelCount - 1
            label.delete(array.get(signalLabels, labelIndex))

    array.clear(signalLabels)

    // --------------------------------------
    // Number of available historical bars
    // --------------------------------------

    int barsToProcess = math.min(
         bar_index + 1,
         MAX_HISTORY
    )

    // Gaussian calculation is limited to the
    // statistically meaningful part of the kernel.
    int kernelRadius = math.min(
         barsToProcess - 1,
         int(math.ceil(smoothingLength * 4.0))
    )

    // --------------------------------------
    // Precalculate Gaussian weights
    // --------------------------------------

    array<float> gaussianWeights = array.new<float>(
         kernelRadius + 1,
         na
    )

    for distance = 0 to kernelRadius
        float weight = gauss(
             float(distance),
             smoothingLength
        )

        array.set(
             gaussianWeights,
             distance,
             weight
        )

    // --------------------------------------
    // Calculate smoothed values
    // Index 0 is the current bar.
    // --------------------------------------

    array<float> smoothedValues = array.new<float>(
         barsToProcess,
         na
    )

    if barsToProcess > 0

        for historicalIndex = 0 to barsToProcess - 1

            int firstKernelIndex = math.max(
                 0,
                 historicalIndex - kernelRadius
            )

            int lastKernelIndex = math.min(
                 barsToProcess - 1,
                 historicalIndex + kernelRadius
            )

            float weightedSum = 0.0
            float weightsSum  = 0.0

            for kernelIndex = firstKernelIndex to lastKernelIndex

                int distance = math.abs(
                     historicalIndex - kernelIndex
                )

                float weight = array.get(
                     gaussianWeights,
                     distance
                )

                float sourceValue = source[kernelIndex]

                if not na(sourceValue)
                    weightedSum += sourceValue * weight
                    weightsSum  += weight

            float smoothedValue = weightsSum > 0.0
                 ? weightedSum / weightsSum
                 : na

            array.set(
                 smoothedValues,
                 historicalIndex,
                 smoothedValue
            )

    // --------------------------------------
    // Calculate the base channel deviation
    // --------------------------------------

    float absoluteErrorSum = 0.0
    int absoluteErrorCount = 0

    if barsToProcess > 0

        for historicalIndex = 0 to barsToProcess - 1

            float smoothedValue = array.get(
                 smoothedValues,
                 historicalIndex
            )

            float sourceValue = source[historicalIndex]

            if not na(smoothedValue) and not na(sourceValue)
                absoluteErrorSum += math.abs(
                     sourceValue - smoothedValue
                )

                absoluteErrorCount += 1

    float meanAbsoluteError = absoluteErrorCount > 0
         ? absoluteErrorSum / absoluteErrorCount
         : 0.0

    float channelOffset = math.max(
         meanAbsoluteError * channelWidth,
         syminfo.mintick
    )

    // --------------------------------------
    // Create channel points
    // Oldest point is added first.
    // --------------------------------------

    array<chart.point> upperPoints  = array.new<chart.point>()
    array<chart.point> middlePoints = array.new<chart.point>()
    array<chart.point> lowerPoints  = array.new<chart.point>()

    if barsToProcess > 0

        for chronologicalIndex = 0 to barsToProcess - 1

            int historicalIndex =
                 barsToProcess - 1 - chronologicalIndex

            float centerValue = array.get(
                 smoothedValues,
                 historicalIndex
            )

            if not na(centerValue)

                int pointBarIndex =
                     bar_index - historicalIndex

                array.push(
                     upperPoints,
                     chart.point.from_index(
                          pointBarIndex,
                          centerValue + channelOffset
                     )
                )

                array.push(
                     middlePoints,
                     chart.point.from_index(
                          pointBarIndex,
                          centerValue
                     )
                )

                array.push(
                     lowerPoints,
                     chart.point.from_index(
                          pointBarIndex,
                          centerValue - channelOffset
                     )
                )

    // --------------------------------------
    // Draw channel across history
    // --------------------------------------

    if array.size(upperPoints) > 1

        upperPolyline := polyline.new(
             upperPoints,
             curved = false,
             closed = false,
             xloc = xloc.bar_index,
             line_color = upperColor,
             line_style = line.style_solid,
             line_width = lineWidth
        )

        middlePolyline := polyline.new(
             middlePoints,
             curved = false,
             closed = false,
             xloc = xloc.bar_index,
             line_color = middleColor,
             line_style = line.style_solid,
             line_width = lineWidth
        )

        lowerPolyline := polyline.new(
             lowerPoints,
             curved = false,
             closed = false,
             xloc = xloc.bar_index,
             line_color = lowerColor,
             line_style = line.style_solid,
             line_width = lineWidth
        )

    // --------------------------------------
    // Historical touch bubbles
    //
    // Upper touch:
    // high reaches the upper boundary after
    // the previous high was below it.
    //
    // Lower touch:
    // low reaches the lower boundary after
    // the previous low was above it.
    // --------------------------------------

    int createdSignals = 0

    if barsToProcess > 1

        for historicalIndex = 0 to barsToProcess - 2

            float centerValue = array.get(
                 smoothedValues,
                 historicalIndex
            )

            float previousCenterValue = array.get(
                 smoothedValues,
                 historicalIndex + 1
            )

            if not na(centerValue) and
               not na(previousCenterValue)

                float upperBoundary =
                     centerValue + channelOffset

                float lowerBoundary =
                     centerValue - channelOffset

                float previousUpperBoundary =
                     previousCenterValue + channelOffset

                float previousLowerBoundary =
                     previousCenterValue - channelOffset

                bool upperTouch =
                     high[historicalIndex] >= upperBoundary and
                     high[historicalIndex + 1] < previousUpperBoundary

                bool lowerTouch =
                     low[historicalIndex] <= lowerBoundary and
                     low[historicalIndex + 1] > previousLowerBoundary

                int signalBarIndex =
                     bar_index - historicalIndex

                if upperTouch and createdSignals < MAX_LABELS

                    label upperBubble = label.new(
                         x = signalBarIndex,
                         y = upperBoundary,
                         text = "",
                         xloc = xloc.bar_index,
                         yloc = yloc.price,
                         color = color.new(
                              lowerColor,
                              bubbleTransparency
                         ),
                         style = label.style_circle,
                         size = size.small
                    )

                    array.push(
                         signalLabels,
                         upperBubble
                    )

                    createdSignals += 1

                if lowerTouch and createdSignals < MAX_LABELS

                    label lowerBubble = label.new(
                         x = signalBarIndex,
                         y = lowerBoundary,
                         text = "",
                         xloc = xloc.bar_index,
                         yloc = yloc.price,
                         color = color.new(
                              upperColor,
                              bubbleTransparency
                         ),
                         style = label.style_circle,
                         size = size.small
                    )

                    array.push(
                         signalLabels,
                         lowerBubble
                    )

                    createdSignals += 1

    // --------------------------------------
    // Current-bar signals for alerts
    // --------------------------------------

    if barsToProcess > 1

        float currentCenter = array.get(
             smoothedValues,
             0
        )

        float previousCenter = array.get(
             smoothedValues,
             1
        )

        if not na(currentCenter) and
           not na(previousCenter)

            float currentUpper =
                 currentCenter + channelOffset

            float currentLower =
                 currentCenter - channelOffset

            float previousUpper =
                 previousCenter + channelOffset

            float previousLower =
                 previousCenter - channelOffset

            upperTouchNow :=
                 high >= currentUpper and
                 high[1] < previousUpper

            lowerTouchNow :=
                 low <= currentLower and
                 low[1] > previousLower

// ==========================================
// Alerts
// ==========================================

alertcondition(
     upperTouchNow,
     "Upper Channel Touch",
     "Price touched the upper Swing Reversion Zone."
)

alertcondition(
     lowerTouchNow,
     "Lower Channel Touch",
     "Price touched the lower Swing Reversion Zone."
)
````
