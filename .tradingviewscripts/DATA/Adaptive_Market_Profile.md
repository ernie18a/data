<!-- tradingview-pine-id: PUB;b65db12d071242348db3ade885d80e59 -->
<!-- tradingviewscripts-format: 1 -->
# Adaptive Market Profile

Source: https://www.tradingview.com/script/TMLC5Wma-Adaptive-Market-Profile-Auto-Detect-Dynamic-Activity-Zones/

## Description

Adaptive Market Profile is an advanced indicator that automatically detects and displays the most relevant trend channel and market profile for any asset and timeframe. Unlike standard regression channel tools, this script uses a fully adaptive approach to identify the optimal period, providing you with the channel that best fits the current market dynamics. The calculation is based on maximizing the statistical significance of the trend using Pearson’s R coefficient, ensuring that the most relevant trend is always selected.

Within the selected channel, the indicator generates a dynamic market profile, breaking the price range into configurable zones and displaying the most active areas based on volume or the number of touches. This allows you to instantly identify high-activity price levels and potential support/resistance zones. The “most active lines” are plotted in real-time and always stay parallel to the channel, dynamically adapting to market structure.

Key features:
- Automatic detection of the optimal regression period: The script scans a wide range of lengths and selects the channel that statistically represents the strongest trend.
- Dynamic market profile: Visualizes the distribution of volume or price touches inside the trend channel, with customizable section count.
- Most active zones: Highlights the most traded or touched price levels as dynamic, parallel lines for precise support/resistance reading.
- Manual override: Optionally, users can select their own channel period for full control.
- Supports both linear and logarithmic charts: Simple toggle to match your chart scaling.

Use cases:
- Trend following and channel trading strategies.
- Quick identification of dynamic support/resistance and liquidity zones.
- Objective selection of the most statistically significant trend channel, without manual guesswork.
- Suitable for all assets and timeframes (crypto, stocks, forex, futures).

Originality:
This script goes beyond basic regression channels by integrating dynamic profile analysis and fully adaptive period detection, offering a comprehensive tool for modern technical analysts. The combination of trend detection, market profile, and activity zone mapping is unique and not available in TradingView built-ins.

Instructions:
Add Adaptive Market Profile to your chart. By default, the script automatically detects the optimal channel period and displays the corresponding regression channel with dynamic profile and activity zones. If you prefer manual control, disable “Auto trend channel period” and set your preferred period. Adjust profile settings as needed for your asset and timeframe.

For questions, suggestions, or further customization, contact Julien Eche (@Julien_Eche) directly on TradingView.

---

## Source Code

````pine
// @ Julien_Eche

//@version=6
indicator(
     'Adaptive Market Profile',
     overlay = true,
     max_bars_back = 5000,
     max_lines_count = 150,
     max_labels_count = 50)

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------

string GROUP_TREND = 'Trend channel'
string GROUP_PROFILE = 'Activity profile'
string GROUP_DISPLAY = 'Display'

bool useAdaptive = input.bool(
     true,
     'Automatically select the most linear period',
     group = GROUP_TREND)

int manualPeriod = input.int(
     200,
     'Manual channel period (bars)',
     minval = 2,
     maxval = 2000,
     group = GROUP_TREND)

bool selectOnClosedBars = input.bool(
     true,
     'Select adaptive period from closed bars',
     tooltip = 'When enabled, the adaptive period is selected on the last confirmed historical bar. The current channel can still move with the live bar.',
     group = GROUP_TREND)

float switchThreshold = input.float(
     0.015,
     'Minimum Pearson improvement before switching',
     minval = 0.0,
     maxval = 0.20,
     step = 0.005,
     tooltip = 'Reduces jumps between similar candidate periods. Set to 0 for a strict maximum.',
     group = GROUP_TREND)

float devMultiplier = input.float(
     2.0,
     'Deviation multiplier',
     minval = 0.1,
     step = 0.1,
     group = GROUP_TREND)

bool useLogScale = input.bool(
     false,
     'Calculate in logarithmic price space',
     tooltip = 'Enable this when the chart is displayed on a logarithmic scale.',
     group = GROUP_TREND)

string activityMethod = input.string(
     'Distributed Volume',
     'Activity calculation',
     options = ['Touches', 'Distributed Volume'],
     tooltip = 'Distributed Volume allocates each candle volume proportionally across the channel sections overlapped by its price range.',
     group = GROUP_PROFILE)

int maxProfileSections = input.int(
     23,
     'Maximum profile sections',
     minval = 2,
     maxval = 25,
     group = GROUP_PROFILE)

bool adaptiveSections = input.bool(
     true,
     'Adapt section count to selected period',
     tooltip = 'Uses approximately the square root of the selected number of bars, capped by Maximum profile sections.',
     group = GROUP_PROFILE)

float minActivityPercent = input.float(
     10.0,
     'Minimum activity (% of maximum)',
     minval = 0.0,
     maxval = 100.0,
     step = 1.0,
     group = GROUP_PROFILE)

bool showMostActiveLines = input.bool(
     true,
     'Show most active levels',
     inline = 'active_levels',
     group = GROUP_PROFILE)

int numActivityLines = input.int(
     2,
     '',
     minval = 1,
     maxval = 5,
     inline = 'active_levels',
     group = GROUP_PROFILE)

bool showProfile = input.bool(
     true,
     'Show profile',
     inline = 'profile_visibility',
     group = GROUP_PROFILE)

bool showActivityLabels = input.bool(
     false,
     'Show activity labels',
     inline = 'profile_visibility',
     group = GROUP_PROFILE)

color lowActivityColor = input.color(
     color.new(#00BBFF, 95),
     'Low activity',
     inline = 'profile_colors',
     group = GROUP_PROFILE)

color highActivityColor = input.color(
     color.new(#00BBFF, 25),
     'High activity',
     inline = 'profile_colors',
     group = GROUP_PROFILE)

color channelColor = input.color(
     color.new(color.gray, 0),
     'Channel lines',
     inline = 'channel_lines',
     group = GROUP_DISPLAY)

string channelStyleInput = input.string(
     'Solid',
     '',
     options = ['Solid', 'Dotted', 'Dashed'],
     inline = 'channel_lines',
     group = GROUP_DISPLAY)

int channelWidth = input.int(
     1,
     '',
     minval = 1,
     maxval = 4,
     inline = 'channel_lines',
     group = GROUP_DISPLAY)

color channelFillColor = input.color(
     color.new(#909497, 95),
     'Channel fill',
     group = GROUP_DISPLAY)

bool showRegressionLine = input.bool(
     false,
     'Show regression line',
     inline = 'regression_line',
     group = GROUP_DISPLAY)

color regressionColor = input.color(
     color.new(color.gray, 0),
     '',
     inline = 'regression_line',
     group = GROUP_DISPLAY)

string regressionStyleInput = input.string(
     'Dashed',
     '',
     options = ['Solid', 'Dotted', 'Dashed'],
     inline = 'regression_line',
     group = GROUP_DISPLAY)

int regressionWidth = input.int(
     1,
     '',
     minval = 1,
     maxval = 4,
     inline = 'regression_line',
     group = GROUP_DISPLAY)

bool useCustomActivityColor = input.bool(
     true,
     'Use custom active-level color',
     inline = 'active_color',
     group = GROUP_DISPLAY)

color customActivityColor = input.color(
     color.new(#00BBFF, 50),
     '',
     inline = 'active_color',
     group = GROUP_DISPLAY)

string activityLineStyleInput = input.string(
     'Solid',
     'Active-level style',
     options = ['Solid', 'Dotted', 'Dashed'],
     inline = 'active_style',
     group = GROUP_DISPLAY)

int activityLineWidth = input.int(
     1,
     '',
     minval = 1,
     maxval = 5,
     inline = 'active_style',
     group = GROUP_DISPLAY)

bool showStatistics = input.bool(
     true,
     'Show selected period and Pearson',
     group = GROUP_DISPLAY)

//------------------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------------------

formatNumber(float number) =>
    if number >= 1000000
        str.tostring(math.round(number / 1000000, 2)) + 'M'
    else if number >= 1000
        str.tostring(math.round(number / 1000, 2)) + 'K'
    else
        str.tostring(math.round(number, 2))

getLineStyle(string styleInput) =>
    styleInput == 'Solid' ? line.style_solid :
     styleInput == 'Dotted' ? line.style_dotted :
     line.style_dashed

adjustPrice(float price) =>
    useLogScale ? math.log(math.max(price, syminfo.mintick)) : price

unadjustPrice(float price) =>
    useLogScale ? math.exp(price) : price

interpolateAdjusted(
     float startPrice,
     float endPrice,
     int currentStep,
     int totalSteps) =>
    int safeSteps = math.max(totalSteps, 1)
    adjustPrice(startPrice) +
     (adjustPrice(endPrice) - adjustPrice(startPrice)) *
     currentStep / safeSteps

interpolatePrice(
     float startPrice,
     float endPrice,
     int currentStep,
     int totalSteps) =>
    unadjustPrice(
         interpolateAdjusted(
             startPrice,
             endPrice,
             currentStep,
             totalSteps))

// Absolute Pearson correlation between adjusted close and bar position.
// One loop is sufficient; the original version calculated the regression twice.
calculatePearson(
     float source,
     int length,
     bool calculateNow) =>
    float result = na
    if calculateNow and length > 1 and bar_index + 1 >= length
        float sumX = 0.0
        float sumY = 0.0
        float sumXX = 0.0
        float sumYY = 0.0
        float sumXY = 0.0

        for offset = 0 to length - 1
            float x = offset + 1.0
            float y = adjustPrice(source[offset])
            sumX += x
            sumY += y
            sumXX += x * x
            sumYY += y * y
            sumXY += x * y

        float numerator = length * sumXY - sumX * sumY
        float denominatorX = length * sumXX - sumX * sumX
        float denominatorY = length * sumYY - sumY * sumY
        float denominator = denominatorX * denominatorY

        result := denominator > 0.0 ?
             math.abs(numerator / math.sqrt(denominator)) :
             0.0

    result

calculateRegression(int length) =>
    if not barstate.islast or length <= 1 or bar_index + 1 < length
        [float(na), float(na), float(na)]
    else
        float sumX = 0.0
        float sumY = 0.0
        float sumXX = 0.0
        float sumXY = 0.0

        for offset = 0 to length - 1
            float value = adjustPrice(close[offset])
            float position = offset + 1.0
            sumX += position
            sumY += value
            sumXX += position * position
            sumXY += value * position

        float denominator = length * sumXX - sumX * sumX
        float slope = denominator != 0.0 ?
             (length * sumXY - sumX * sumY) / denominator :
             0.0
        float average = sumY / length
        float intercept = average - slope * sumX / length + slope

        [slope, average, intercept]

calculateDeviation(
     int length,
     float slope,
     float average,
     float intercept) =>
    if not barstate.islast or length <= 1 or na(slope)
        [float(na), float(na)]
    else
        float residualSquares = 0.0
        float priceSquares = 0.0
        float regressionSquares = 0.0
        float covariance = 0.0
        float regressionAverage = intercept + slope * (length - 1) * 0.5
        float regressionValue = intercept

        for offset = 0 to length - 1
            float price = adjustPrice(close[offset])
            float residual = price - regressionValue
            float priceDelta = price - average
            float regressionDelta = regressionValue - regressionAverage

            residualSquares += residual * residual
            priceSquares += priceDelta * priceDelta
            regressionSquares += regressionDelta * regressionDelta
            covariance += priceDelta * regressionDelta
            regressionValue += slope

        float deviation = math.sqrt(
             residualSquares / math.max(length - 1, 1))
        float correlationDenominator = priceSquares * regressionSquares
        float pearson = correlationDenominator > 0.0 ?
             math.abs(covariance / math.sqrt(correlationDenominator)) :
             0.0

        [deviation, pearson]

applyDeviation(float basePrice, float deviation) =>
    unadjustPrice(adjustPrice(basePrice) + deviation)

//------------------------------------------------------------------------------
// Adaptive-period selection
//------------------------------------------------------------------------------

// With confirmation enabled, the selection is made on the latest fully closed
// historical bar when the script loads, then on each live bar's closing update.
// With confirmation disabled, it can update during the live bar.
bool selectionBar = useAdaptive and (
     selectOnClosedBars ?
     (
         barstate.islastconfirmedhistory or
         (barstate.islast and barstate.isconfirmed)) :
     barstate.islast)

float pearson01 = calculatePearson(close, 50, selectionBar)
float pearson02 = calculatePearson(close, 60, selectionBar)
float pearson03 = calculatePearson(close, 70, selectionBar)
float pearson04 = calculatePearson(close, 80, selectionBar)
float pearson05 = calculatePearson(close, 90, selectionBar)
float pearson06 = calculatePearson(close, 100, selectionBar)
float pearson07 = calculatePearson(close, 115, selectionBar)
float pearson08 = calculatePearson(close, 130, selectionBar)
float pearson09 = calculatePearson(close, 145, selectionBar)
float pearson10 = calculatePearson(close, 160, selectionBar)
float pearson11 = calculatePearson(close, 180, selectionBar)
float pearson12 = calculatePearson(close, 200, selectionBar)
float pearson13 = calculatePearson(close, 220, selectionBar)
float pearson14 = calculatePearson(close, 250, selectionBar)
float pearson15 = calculatePearson(close, 280, selectionBar)
float pearson16 = calculatePearson(close, 310, selectionBar)
float pearson17 = calculatePearson(close, 340, selectionBar)
float pearson18 = calculatePearson(close, 370, selectionBar)
float pearson19 = calculatePearson(close, 400, selectionBar)

var candidatePeriods = array.from(
     50, 60, 70, 80, 90, 100, 115, 130, 145, 160,
     180, 200, 220, 250, 280, 310, 340, 370, 400)

candidateScores = array.from(
     pearson01, pearson02, pearson03, pearson04, pearson05,
     pearson06, pearson07, pearson08, pearson09, pearson10,
     pearson11, pearson12, pearson13, pearson14, pearson15,
     pearson16, pearson17, pearson18, pearson19)

var int detectedPeriod = na

if selectionBar
    float bestScore = na
    int bestPeriod = na
    float currentScore = na

    for candidateIndex = 0 to array.size(candidatePeriods) - 1
        int candidatePeriod = array.get(candidatePeriods, candidateIndex)
        float candidateScore = array.get(candidateScores, candidateIndex)

        if not na(candidateScore)
            if na(bestScore) or candidateScore > bestScore
                bestScore := candidateScore
                bestPeriod := candidatePeriod

            if candidatePeriod == detectedPeriod
                currentScore := candidateScore

    if not na(bestPeriod)
        bool shouldSwitch = na(detectedPeriod)

        if not shouldSwitch
            shouldSwitch := na(currentScore) or
                 bestPeriod == detectedPeriod or
                 bestScore >= currentScore + switchThreshold

        if shouldSwitch
            detectedPeriod := bestPeriod

int requestedPeriod = useAdaptive and not na(detectedPeriod) ?
     detectedPeriod :
     manualPeriod

int effectivePeriod = math.min(bar_index + 1, requestedPeriod)
bool validWindow = barstate.islast and effectivePeriod >= 2

//------------------------------------------------------------------------------
// Regression channel
//------------------------------------------------------------------------------

[regressionSlope, regressionAverage, regressionIntercept] =
     calculateRegression(effectivePeriod)

float startPrice = validWindow ?
     unadjustPrice(
         regressionIntercept +
         regressionSlope * (effectivePeriod - 1)) :
     na

float endPrice = validWindow ?
     unadjustPrice(regressionIntercept) :
     na

[residualDeviation, currentPearson] = calculateDeviation(
     effectivePeriod,
     regressionSlope,
     regressionAverage,
     regressionIntercept)

float upperStart = validWindow ?
     applyDeviation(
         startPrice,
         devMultiplier * residualDeviation) :
     na

float upperEnd = validWindow ?
     applyDeviation(
         endPrice,
         devMultiplier * residualDeviation) :
     na

float lowerStart = validWindow ?
     applyDeviation(
         startPrice,
         -devMultiplier * residualDeviation) :
     na

float lowerEnd = validWindow ?
     applyDeviation(
         endPrice,
         -devMultiplier * residualDeviation) :
     na

int oldestBarIndex = bar_index - effectivePeriod + 1
string channelLineStyle = getLineStyle(channelStyleInput)
string regressionLineStyle = getLineStyle(regressionStyleInput)

var line upperChannelLine = na
var line lowerChannelLine = na
var line middleRegressionLine = na

var linefill fullChannelFill = na
var linefill upperChannelFill = na
var linefill lowerChannelFill = na

if validWindow and not na(upperStart) and not na(lowerStart)
    if na(upperChannelLine)
        upperChannelLine := line.new(
             oldestBarIndex,
             upperStart,
             bar_index,
             upperEnd,
             width = channelWidth,
             extend = extend.right,
             color = channelColor,
             style = channelLineStyle)
    else
        line.set_xy1(
             upperChannelLine,
             oldestBarIndex,
             upperStart)
        line.set_xy2(
             upperChannelLine,
             bar_index,
             upperEnd)
        line.set_color(upperChannelLine, channelColor)
        line.set_style(upperChannelLine, channelLineStyle)
        line.set_width(upperChannelLine, channelWidth)

    if na(lowerChannelLine)
        lowerChannelLine := line.new(
             oldestBarIndex,
             lowerStart,
             bar_index,
             lowerEnd,
             width = channelWidth,
             extend = extend.right,
             color = channelColor,
             style = channelLineStyle)
    else
        line.set_xy1(
             lowerChannelLine,
             oldestBarIndex,
             lowerStart)
        line.set_xy2(
             lowerChannelLine,
             bar_index,
             lowerEnd)
        line.set_color(lowerChannelLine, channelColor)
        line.set_style(lowerChannelLine, channelLineStyle)
        line.set_width(lowerChannelLine, channelWidth)

    if showRegressionLine
        if na(middleRegressionLine)
            middleRegressionLine := line.new(
                 oldestBarIndex,
                 startPrice,
                 bar_index,
                 endPrice,
                 width = regressionWidth,
                 extend = extend.right,
                 color = regressionColor,
                 style = regressionLineStyle)
        else
            line.set_xy1(
                 middleRegressionLine,
                 oldestBarIndex,
                 startPrice)
            line.set_xy2(
                 middleRegressionLine,
                 bar_index,
                 endPrice)
            line.set_color(
                 middleRegressionLine,
                 regressionColor)
            line.set_style(
                 middleRegressionLine,
                 regressionLineStyle)
            line.set_width(
                 middleRegressionLine,
                 regressionWidth)

        if not na(fullChannelFill)
            linefill.delete(fullChannelFill)
            fullChannelFill := na

        if na(upperChannelFill)
            upperChannelFill := linefill.new(
                 upperChannelLine,
                 middleRegressionLine,
                 channelFillColor)
        else
            linefill.set_color(
                 upperChannelFill,
                 channelFillColor)

        if na(lowerChannelFill)
            lowerChannelFill := linefill.new(
                 middleRegressionLine,
                 lowerChannelLine,
                 channelFillColor)
        else
            linefill.set_color(
                 lowerChannelFill,
                 channelFillColor)
    else
        if not na(upperChannelFill)
            linefill.delete(upperChannelFill)
            upperChannelFill := na

        if not na(lowerChannelFill)
            linefill.delete(lowerChannelFill)
            lowerChannelFill := na

        if not na(middleRegressionLine)
            line.delete(middleRegressionLine)
            middleRegressionLine := na

        if na(fullChannelFill)
            fullChannelFill := linefill.new(
                 upperChannelLine,
                 lowerChannelLine,
                 channelFillColor)
        else
            linefill.set_color(
                 fullChannelFill,
                 channelFillColor)

//------------------------------------------------------------------------------
// Statistics label
//------------------------------------------------------------------------------

var label statisticsLabel = na

if validWindow and showStatistics and not na(currentPearson)
    bool selectedAtBoundary = useAdaptive and not na(detectedPeriod) and
         (detectedPeriod == array.get(candidatePeriods, 0) or
         detectedPeriod == array.get(
             candidatePeriods,
             array.size(candidatePeriods) - 1))

    string selectionText = useAdaptive ? 'Auto' : 'Manual'
    string boundaryText = selectedAtBoundary ? ' (range limit)' : ''
    string statisticsText =
         selectionText +
         ' · L=' +
         str.tostring(effectivePeriod) +
         ' · R=' +
         str.tostring(currentPearson, '#.###') +
         boundaryText

    if na(statisticsLabel)
        statisticsLabel := label.new(
             oldestBarIndex,
             lowerStart,
             statisticsText,
             color = color.new(color.white, 100),
             textcolor = color.gray,
             size = size.small,
             style = label.style_label_up)
    else
        label.set_xy(
             statisticsLabel,
             oldestBarIndex,
             lowerStart)
        label.set_text(
             statisticsLabel,
             statisticsText)
        label.set_color(
             statisticsLabel,
             color.new(color.white, 100))
        label.set_textcolor(
             statisticsLabel,
             color.gray)
else
    if not na(statisticsLabel)
        label.delete(statisticsLabel)
        statisticsLabel := na

//------------------------------------------------------------------------------
// Activity and profile drawings
//------------------------------------------------------------------------------

var counts = array.new_float(0)
var activityLines = array.new_line(0)
var activityLabels = array.new_label(0)
var profileLowLines = array.new_line(0)
var profileHighLines = array.new_line(0)
var profileFills = array.new_linefill(0)

if validWindow
    // Delete every previous object before clearing its array.
    // In particular, deleting a linefill does not delete its two lines.
    for activityLine in activityLines
        line.delete(activityLine)
    array.clear(activityLines)

    for activityLabel in activityLabels
        label.delete(activityLabel)
    array.clear(activityLabels)

    for profileFill in profileFills
        linefill.delete(profileFill)
    array.clear(profileFills)

    for profileLowLine in profileLowLines
        line.delete(profileLowLine)
    array.clear(profileLowLines)

    for profileHighLine in profileHighLines
        line.delete(profileHighLine)
    array.clear(profileHighLines)

    array.clear(counts)

    if showMostActiveLines or showProfile
        int automaticSectionCount = math.max(
             2,
             int(math.round(math.sqrt(effectivePeriod))))

        int sectionCount = adaptiveSections ?
             math.min(
                 maxProfileSections,
                 automaticSectionCount) :
             maxProfileSections

        int timeSteps = math.max(effectivePeriod - 1, 1)

        for sectionIndex = 0 to sectionCount - 1
            float bandLowStart = interpolatePrice(
                 lowerStart,
                 upperStart,
                 sectionIndex,
                 sectionCount)

            float bandHighStart = interpolatePrice(
                 lowerStart,
                 upperStart,
                 sectionIndex + 1,
                 sectionCount)

            float bandLowEnd = interpolatePrice(
                 lowerEnd,
                 upperEnd,
                 sectionIndex,
                 sectionCount)

            float bandHighEnd = interpolatePrice(
                 lowerEnd,
                 upperEnd,
                 sectionIndex + 1,
                 sectionCount)

            float activity = 0.0

            for chronologicalIndex = 0 to effectivePeriod - 1
                int historyIndex =
                     effectivePeriod -
                     1 -
                     chronologicalIndex

                float bandLowAdjusted = interpolateAdjusted(
                     bandLowStart,
                     bandLowEnd,
                     chronologicalIndex,
                     timeSteps)

                float bandHighAdjusted = interpolateAdjusted(
                     bandHighStart,
                     bandHighEnd,
                     chronologicalIndex,
                     timeSteps)

                float candleLowAdjusted = adjustPrice(
                     low[historyIndex])

                float candleHighAdjusted = adjustPrice(
                     high[historyIndex])

                bool overlapsBand =
                     candleLowAdjusted <= bandHighAdjusted and
                     candleHighAdjusted >= bandLowAdjusted

                if activityMethod == 'Touches'
                    if overlapsBand
                        activity += 1.0
                else
                    float candleRange =
                         candleHighAdjusted -
                         candleLowAdjusted

                    float overlapSize = overlapsBand ?
                         math.max(
                             0.0,
                             math.min(
                                 candleHighAdjusted,
                                 bandHighAdjusted) -
                             math.max(
                                 candleLowAdjusted,
                                 bandLowAdjusted)) :
                         0.0

                    float candleVolume = nz(
                         volume[historyIndex],
                         0.0)

                    if candleRange > 0.0
                        activity += candleVolume *
                             overlapSize /
                             candleRange
                    else
                        bool pointIsInsideBand =
                             candleLowAdjusted >= bandLowAdjusted and
                             (
                                 candleLowAdjusted < bandHighAdjusted or
                                 (
                                     sectionIndex == sectionCount - 1 and
                                     candleLowAdjusted <= bandHighAdjusted))

                        if pointIsInsideBand
                            activity += candleVolume

            array.push(counts, activity)

        float maximumActivity = array.size(counts) > 0 ?
             array.max(counts) :
             0.0

        if maximumActivity > 0.0
            sortedIndices = array.sort_indices(
                 counts,
                 order.descending)

            float minimumActivity =
                 maximumActivity *
                 minActivityPercent /
                 100.0

            int profileLength = math.max(
                 1,
                 int(math.round(effectivePeriod / 5.0)))

            string activityLineStyle =
                 getLineStyle(activityLineStyleInput)

            if showMostActiveLines
                int displayedActivityLines = 0

                for rank = 0 to sectionCount - 1
                    if displayedActivityLines >= numActivityLines
                        break

                    int activeSection = array.get(
                         sortedIndices,
                         rank)

                    float activity = array.get(
                         counts,
                         activeSection)

                    if activity < minimumActivity
                        break

                    float activityPercent =
                         activity /
                         maximumActivity

                    float centerStart = interpolatePrice(
                         lowerStart,
                         upperStart,
                         activeSection * 2 + 1,
                         sectionCount * 2)

                    float centerEnd = interpolatePrice(
                         lowerEnd,
                         upperEnd,
                         activeSection * 2 + 1,
                         sectionCount * 2)

                    color activeColor =
                         useCustomActivityColor ?
                         customActivityColor :
                         color.from_gradient(
                             activityPercent,
                             0.0,
                             1.0,
                             lowActivityColor,
                             highActivityColor)

                    int startOffset = showProfile ?
                         int(math.round(
                             activityPercent *
                             profileLength)) :
                         0

                    int activeStartX =
                         oldestBarIndex +
                         startOffset

                    float activeStartY = interpolatePrice(
                         centerStart,
                         centerEnd,
                         startOffset,
                         timeSteps)

                    line activeLine = line.new(
                         activeStartX,
                         activeStartY,
                         bar_index,
                         centerEnd,
                         color = activeColor,
                         width = activityLineWidth,
                         style = activityLineStyle,
                         extend = extend.right)

                    array.push(
                         activityLines,
                         activeLine)

                    if showActivityLabels
                        int labelOffset = 5
                        float activeSlopeAdjusted =
                             (
                                 adjustPrice(centerEnd) -
                                 adjustPrice(centerStart)) /
                             timeSteps

                        float labelPrice = unadjustPrice(
                             adjustPrice(centerEnd) +
                             activeSlopeAdjusted *
                             labelOffset)

                        label activityLabel = label.new(
                             x = bar_index + labelOffset,
                             y = labelPrice,
                             text = formatNumber(activity),
                             color = color.new(color.white, 100),
                             textcolor = activeColor,
                             size = size.small,
                             style = label.style_label_left)

                        array.push(
                             activityLabels,
                             activityLabel)

                    displayedActivityLines += 1

            if showProfile
                for sectionIndex = 0 to sectionCount - 1
                    float activity = array.get(
                         counts,
                         sectionIndex)

                    if activity > 0.0
                        float activityPercent =
                             activity /
                             maximumActivity

                        color profileColor =
                             color.from_gradient(
                                 activityPercent,
                                 0.0,
                                 1.0,
                                 lowActivityColor,
                                 highActivityColor)

                        int lineLength = math.max(
                             1,
                             int(math.round(
                                 activityPercent *
                                 profileLength)))

                        float bandLowStart = interpolatePrice(
                             lowerStart,
                             upperStart,
                             sectionIndex,
                             sectionCount)

                        float bandHighStart = interpolatePrice(
                             lowerStart,
                             upperStart,
                             sectionIndex + 1,
                             sectionCount)

                        float bandLowEnd = interpolatePrice(
                             lowerEnd,
                             upperEnd,
                             sectionIndex,
                             sectionCount)

                        float bandHighEnd = interpolatePrice(
                             lowerEnd,
                             upperEnd,
                             sectionIndex + 1,
                             sectionCount)

                        int profileEndX =
                             oldestBarIndex +
                             lineLength

                        float profileLowEnd = interpolatePrice(
                             bandLowStart,
                             bandLowEnd,
                             lineLength,
                             timeSteps)

                        float profileHighEnd = interpolatePrice(
                             bandHighStart,
                             bandHighEnd,
                             lineLength,
                             timeSteps)

                        line profileLowLine = line.new(
                             oldestBarIndex,
                             bandLowStart,
                             profileEndX,
                             profileLowEnd,
                             color = color.new(profileColor, 100))

                        line profileHighLine = line.new(
                             oldestBarIndex,
                             bandHighStart,
                             profileEndX,
                             profileHighEnd,
                             color = color.new(profileColor, 100))

                        linefill profileFill = linefill.new(
                             profileLowLine,
                             profileHighLine,
                             profileColor)

                        array.push(
                             profileLowLines,
                             profileLowLine)

                        array.push(
                             profileHighLines,
                             profileHighLine)

                        array.push(
                             profileFills,
                             profileFill)
````
