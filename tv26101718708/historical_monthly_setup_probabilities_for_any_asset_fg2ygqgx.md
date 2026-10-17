# Historical Monthly Setup Probabilities for any asset

- url: https://www.tradingview.com/script/fG2YGQGx-Historical-Monthly-Setup-Probabilities-for-any-asset/
- type: indicator
- pine_id: PUB;74ee659321c148078b54742eef054a4c
- version: 1.0

## Description

This indicator shows how price has historically behaved during each month of the year and can be used on any asset

It calculates the probability of a positive or negative monthly outcome based on past market data and presents the results directly on the chart

The goal is to provide historical context for the current month, rather than predict the future

The indicator can help identify months that have historically shown stronger upward or downward tendencies, while still leaving room for current market conditions to lead

This is not a forecast or a price target

It is simply a look at where history leaned after the closest monthly setups

## Source Code

````pine
//@version=6
indicator(
     "Historical Monthly Setup Probabilities",
     overlay = true,
     max_bars_back = 5000,
     max_lines_count = 300,
     max_labels_count = 50
)

// =====================================================================
// GENERAL SETTINGS
// =====================================================================

groupGeneral = "General settings"

lookbackBars = input.int(
     4000,
     "Historical search range",
     minval = 500,
     maxval = 4500,
     group = groupGeneral
)

minimumMatches = input.int(
     15,
     "Minimum historical matches",
     minval = 5,
     maxval = 25,
     group = groupGeneral
)

maximumMatches = input.int(
     30,
     "Maximum historical matches",
     minval = 10,
     maxval = 50,
     group = groupGeneral
)

qualityExpansion = input.float(
     1.25,
     "Maximum quality expansion",
     minval = 1.00,
     maxval = 2.00,
     step = 0.05,
     group = groupGeneral
)

useClosedCandle = input.bool(
     true,
     "Use last closed candle",
     group = groupGeneral
)

// =====================================================================
// RECOGNIZABLE PERIODS
// =====================================================================

int tradingMonth = 21
int forecastPeriod = 21
int minimumOccurrenceSpacing = 21

// =====================================================================
// SCENARIO DEFINITIONS
// =====================================================================

groupScenarios = "Scenario definitions"

bullishThreshold = input.float(
     3.0,
     "Bullish recovery threshold %",
     minval = 0.1,
     maxval = 20.0,
     step = 0.1,
     group = groupScenarios
)

bearishThreshold = input.float(
     3.0,
     "Further weakness threshold %",
     minval = 0.1,
     maxval = 20.0,
     step = 0.1,
     group = groupScenarios
)

// =====================================================================
// TECHNICAL SETTINGS
// =====================================================================

groupTechnical = "Technical settings"

rsiLength = input.int(
     14,
     "RSI length",
     minval = 2,
     group = groupTechnical
)

emaLength = input.int(
     200,
     "EMA length",
     minval = 20,
     group = groupTechnical
)

adxLength = input.int(
     14,
     "ADX length",
     minval = 2,
     group = groupTechnical
)

adxSmoothing = input.int(
     14,
     "ADX smoothing",
     minval = 2,
     group = groupTechnical
)

// =====================================================================
// MATCHING WEIGHTS
// =====================================================================

groupWeights = "Matching weights"

monthPatternWeight = input.float(
     2.5,
     "Monthly pattern weight",
     minval = 0.0,
     maxval = 5.0,
     step = 0.1,
     group = groupWeights
)

currentStateWeight = input.float(
     1.0,
     "Current market state weight",
     minval = 0.0,
     maxval = 5.0,
     step = 0.1,
     group = groupWeights
)

// =====================================================================
// DISPLAY SETTINGS
// =====================================================================

groupDisplay = "Display"

showAllScenarioPaths = input.bool(
     true,
     "Show all scenario paths",
     group = groupDisplay
)

showProbabilityTable = input.bool(
     true,
     "Show probability table",
     group = groupDisplay
)

showPathLabels = input.bool(
     true,
     "Show scenario labels",
     group = groupDisplay
)

showFinalPrice = input.bool(
     true,
     "Show final price in labels",
     group = groupDisplay
)

showEma = input.bool(
     false,
     "Show EMA",
     group = groupDisplay
)

bullishColor = input.color(
     color.rgb(55, 185, 105),
     "Bullish color",
     group = groupDisplay
)

sidewaysColor = input.color(
     color.rgb(255, 155, 20),
     "Sideways color",
     group = groupDisplay
)

bearishColor = input.color(
     color.rgb(220, 75, 75),
     "Weakness color",
     group = groupDisplay
)

dominantPathWidth = input.int(
     4,
     "Dominant path width",
     minval = 2,
     maxval = 6,
     group = groupDisplay
)

secondaryPathWidth = input.int(
     2,
     "Secondary path width",
     minval = 1,
     maxval = 4,
     group = groupDisplay
)

secondaryTransparency = input.int(
     15,
     "Secondary path transparency",
     minval = 0,
     maxval = 80,
     group = groupDisplay
)

// =====================================================================
// BASE OFFSET
// =====================================================================

int baseOffset = useClosedCandle ? 1 : 0

// =====================================================================
// TECHNICAL SERIES
// =====================================================================

rsiValue = ta.rsi(close, rsiLength)

emaValue = ta.ema(close, emaLength)

emaDistance =
     not na(emaValue) and emaValue != 0.0
     ? close / emaValue - 1.0
     : na

logReturn =
     close > 0.0 and close[1] > 0.0
     ? math.log(close / close[1])
     : na

monthReturn =
     not na(close[tradingMonth]) and close[tradingMonth] != 0.0
     ? close / close[tradingMonth] - 1.0
     : na

monthRsiChange =
     not na(rsiValue[tradingMonth])
     ? rsiValue - rsiValue[tradingMonth]
     : na

monthVolatility =
     ta.stdev(
          logReturn,
          tradingMonth
     )

monthHigh =
     ta.highest(
          high,
          tradingMonth
     )

monthLow =
     ta.lowest(
          low,
          tradingMonth
     )

monthRangeWidth =
     monthHigh - monthLow

monthRangePosition =
     monthRangeWidth > 0.0
     ? (close - monthLow) / monthRangeWidth
     : 0.5

monthHighClose =
     ta.highest(
          close,
          tradingMonth
     )

drawdownFromMonthHigh =
     monthHighClose > 0.0
     ? close / monthHighClose - 1.0
     : na

positiveDay =
     close > close[1]
     ? 1.0
     : 0.0

positiveMonthShare =
     ta.sma(
          positiveDay,
          tradingMonth
     )

monthBodyStrength =
     ta.sma(
          math.abs(close - open) /
          math.max(high - low, syminfo.mintick),
          tradingMonth
     )

monthCloseLocation =
     monthRangeWidth > 0.0
     ? (close - monthLow) / monthRangeWidth
     : 0.5

[plusDi, minusDi, adxValue] =
     ta.dmi(
          adxLength,
          adxSmoothing
     )

plot(
     showEma ? emaValue : na,
     title = "EMA",
     color = color.new(color.blue, 35),
     linewidth = 2
)

// =====================================================================
// FUNCTIONS
// =====================================================================

f_percentile(
     array<float> values,
     float percentile
) =>
    int valueCount = array.size(values)
    float result = na

    if valueCount > 0
        array<float> sortedValues = array.copy(values)

        array.sort(
             sortedValues,
             order.ascending
        )

        float rawIndex =
             percentile / 100.0 *
             (valueCount - 1)

        int lowerIndex =
             int(math.floor(rawIndex))

        int upperIndex =
             int(math.ceil(rawIndex))

        float lowerValue =
             array.get(
                  sortedValues,
                  lowerIndex
             )

        float upperValue =
             array.get(
                  sortedValues,
                  upperIndex
             )

        float fraction =
             rawIndex - lowerIndex

        result :=
             lowerValue +
             (upperValue - lowerValue) *
             fraction

    result

f_delete_lines(
     array<line> lines
) =>
    int lineCount = array.size(lines)

    if lineCount > 0
        for lineIndex = 0 to lineCount - 1
            line.delete(
                 array.get(
                      lines,
                      lineIndex
                 )
            )

    array.clear(lines)

f_delete_labels(
     array<label> labels
) =>
    int labelCount = array.size(labels)

    if labelCount > 0
        for labelIndex = 0 to labelCount - 1
            label.delete(
                 array.get(
                      labels,
                      labelIndex
                 )
            )

    array.clear(labels)

f_match_distance(
     int historicalOffset,
     int currentOffset
) =>
    float monthReturnDifference =
         (
              monthReturn[currentOffset] -
              monthReturn[historicalOffset]
         ) / 0.12

    float monthRsiDifference =
         (
              monthRsiChange[currentOffset] -
              monthRsiChange[historicalOffset]
         ) / 30.0

    float monthVolatilityScale =
         math.max(
              math.abs(monthVolatility[currentOffset]),
              0.0001
         )

    float monthVolatilityDifference =
         (
              monthVolatility[currentOffset] -
              monthVolatility[historicalOffset]
         ) /
         monthVolatilityScale

    float monthRangeDifference =
         monthRangePosition[currentOffset] -
         monthRangePosition[historicalOffset]

    float drawdownDifference =
         (
              drawdownFromMonthHigh[currentOffset] -
              drawdownFromMonthHigh[historicalOffset]
         ) / 0.12

    float positiveMonthDifference =
         positiveMonthShare[currentOffset] -
         positiveMonthShare[historicalOffset]

    float bodyStrengthDifference =
         monthBodyStrength[currentOffset] -
         monthBodyStrength[historicalOffset]

    float closeLocationDifference =
         monthCloseLocation[currentOffset] -
         monthCloseLocation[historicalOffset]

    float monthPatternComponent =
         (
              math.pow(monthReturnDifference, 2) +
              math.pow(monthRsiDifference, 2) +
              math.pow(monthVolatilityDifference, 2) +
              math.pow(monthRangeDifference, 2) +
              math.pow(drawdownDifference, 2) +
              math.pow(positiveMonthDifference, 2) +
              math.pow(bodyStrengthDifference, 2) +
              math.pow(closeLocationDifference, 2)
         ) / 8.0

    float currentRsiDifference =
         (
              rsiValue[currentOffset] -
              rsiValue[historicalOffset]
         ) / 30.0

    float emaDifference =
         (
              emaDistance[currentOffset] -
              emaDistance[historicalOffset]
         ) / 0.12

    float adxDifference =
         (
              adxValue[currentOffset] -
              adxValue[historicalOffset]
         ) / 40.0

    float directionDifference =
         (
              plusDi[currentOffset] -
              minusDi[currentOffset] -
              (
                   plusDi[historicalOffset] -
                   minusDi[historicalOffset]
              )
         ) / 40.0

    float currentStateComponent =
         (
              math.pow(currentRsiDifference, 2) +
              math.pow(emaDifference, 2) +
              math.pow(adxDifference, 2) +
              math.pow(directionDifference, 2)
         ) / 4.0

    float totalWeight =
         monthPatternWeight +
         currentStateWeight

    float weightedDistance =
         totalWeight > 0.0
         ? (
              monthPatternComponent *
              monthPatternWeight +
              currentStateComponent *
              currentStateWeight
         ) / totalWeight
         : monthPatternComponent

    math.sqrt(weightedDistance)

f_probability_text(
     int scenarioCount,
     int totalCount
) =>
    totalCount > 0
     ? str.tostring(
          scenarioCount * 100.0 / totalCount,
          "#.0"
     ) + "%"
     : "N/A"

f_price_text(
     float value
) =>
    na(value)
     ? ""
     : str.tostring(
          value,
          format.mintick
     )

// =====================================================================
// ARRAYS
// =====================================================================

var array<int> candidateOffsets =
     array.new_int()

var array<float> candidateDistances =
     array.new_float()

var array<int> independentOffsets =
     array.new_int()

var array<float> independentDistances =
     array.new_float()

var array<int> selectedOffsets =
     array.new_int()

var array<float> selectedDistances =
     array.new_float()

var array<int> bullishOffsets =
     array.new_int()

var array<int> sidewaysOffsets =
     array.new_int()

var array<int> bearishOffsets =
     array.new_int()

var array<float> bullishPath =
     array.new_float()

var array<float> sidewaysPath =
     array.new_float()

var array<float> bearishPath =
     array.new_float()

var array<line> bullishLines =
     array.new_line()

var array<line> sidewaysLines =
     array.new_line()

var array<line> bearishLines =
     array.new_line()

var array<label> scenarioLabels =
     array.new_label()

// =====================================================================
// FEATURE AVAILABILITY
// =====================================================================

bool currentFeaturesAvailable =
     not na(monthReturn[baseOffset]) and
     not na(monthRsiChange[baseOffset]) and
     not na(monthVolatility[baseOffset]) and
     not na(monthRangePosition[baseOffset]) and
     not na(drawdownFromMonthHigh[baseOffset]) and
     not na(positiveMonthShare[baseOffset]) and
     not na(monthBodyStrength[baseOffset]) and
     not na(monthCloseLocation[baseOffset]) and
     not na(rsiValue[baseOffset]) and
     not na(emaDistance[baseOffset]) and
     not na(adxValue[baseOffset]) and
     not na(plusDi[baseOffset]) and
     not na(minusDi[baseOffset])

// =====================================================================
// BUILD CANDIDATE LIST
// =====================================================================

if barstate.islast and currentFeaturesAvailable
    array.clear(candidateOffsets)
    array.clear(candidateDistances)

    int minimumHistoricalOffset =
         baseOffset +
         forecastPeriod +
         tradingMonth +
         2

    int maximumHistoricalOffset =
         math.min(
              lookbackBars,
              bar_index - tradingMonth
         )

    if maximumHistoricalOffset >= minimumHistoricalOffset
        for historicalOffset =
             minimumHistoricalOffset to maximumHistoricalOffset

            bool historicalFeaturesAvailable =
                 not na(monthReturn[historicalOffset]) and
                 not na(monthRsiChange[historicalOffset]) and
                 not na(monthVolatility[historicalOffset]) and
                 not na(monthRangePosition[historicalOffset]) and
                 not na(drawdownFromMonthHigh[historicalOffset]) and
                 not na(positiveMonthShare[historicalOffset]) and
                 not na(monthBodyStrength[historicalOffset]) and
                 not na(monthCloseLocation[historicalOffset]) and
                 not na(rsiValue[historicalOffset]) and
                 not na(emaDistance[historicalOffset]) and
                 not na(adxValue[historicalOffset]) and
                 not na(plusDi[historicalOffset]) and
                 not na(minusDi[historicalOffset])

            if historicalFeaturesAvailable
                float candidateDistance =
                     f_match_distance(
                          historicalOffset,
                          baseOffset
                     )

                array.push(
                     candidateOffsets,
                     historicalOffset
                )

                array.push(
                     candidateDistances,
                     candidateDistance
                )

// =====================================================================
// SORT AND REMOVE OVERLAPPING EPISODES
// =====================================================================

if barstate.islast and currentFeaturesAvailable
    array.clear(independentOffsets)
    array.clear(independentDistances)

    int candidateCount =
         array.size(candidateDistances)

    if candidateCount > 0
        array<int> sortedIndices =
             array.sort_indices(
                  candidateDistances,
                  order.ascending
             )

        for sortedPosition =
             0 to candidateCount - 1

            int candidateIndex =
                 array.get(
                      sortedIndices,
                      sortedPosition
                 )

            int candidateOffset =
                 array.get(
                      candidateOffsets,
                      candidateIndex
                 )

            float candidateDistance =
                 array.get(
                      candidateDistances,
                      candidateIndex
                 )

            bool separateOccurrence = true

            int independentCount =
                 array.size(independentOffsets)

            if independentCount > 0
                for independentIndex =
                     0 to independentCount - 1

                    int existingOffset =
                         array.get(
                              independentOffsets,
                              independentIndex
                         )

                    if math.abs(existingOffset - candidateOffset) < minimumOccurrenceSpacing
                        separateOccurrence := false

            if separateOccurrence
                array.push(
                     independentOffsets,
                     candidateOffset
                )

                array.push(
                     independentDistances,
                     candidateDistance
                )

            if array.size(independentOffsets) >= maximumMatches
                break

// =====================================================================
// CHOOSE ADAPTIVE SAMPLE SIZE
// =====================================================================

if barstate.islast and currentFeaturesAvailable
    array.clear(selectedOffsets)
    array.clear(selectedDistances)

    int availableIndependent =
         array.size(independentOffsets)

    int requiredMatches =
         math.min(
              minimumMatches,
              availableIndependent
         )

    int finalMatchCount =
         requiredMatches

    if availableIndependent > requiredMatches and requiredMatches > 0
        float referenceDistance =
             array.get(
                  independentDistances,
                  requiredMatches - 1
             )

        float maximumAcceptedDistance =
             referenceDistance *
             qualityExpansion

        for expansionIndex =
             requiredMatches to availableIndependent - 1

            float expansionDistance =
                 array.get(
                      independentDistances,
                      expansionIndex
                 )

            if expansionDistance <= maximumAcceptedDistance
                finalMatchCount += 1
            else
                break

    if finalMatchCount > 0
        for selectedIndex =
             0 to finalMatchCount - 1

            array.push(
                 selectedOffsets,
                 array.get(
                      independentOffsets,
                      selectedIndex
                 )
            )

            array.push(
                 selectedDistances,
                 array.get(
                      independentDistances,
                      selectedIndex
                 )
            )

// =====================================================================
// CLASSIFY HISTORICAL OUTCOMES
// =====================================================================

if barstate.islast and currentFeaturesAvailable
    array.clear(bullishOffsets)
    array.clear(sidewaysOffsets)
    array.clear(bearishOffsets)

    int selectedCount =
         array.size(selectedOffsets)

    if selectedCount > 0
        for selectedIndex =
             0 to selectedCount - 1

            int historicalOffset =
                 array.get(
                      selectedOffsets,
                      selectedIndex
                 )

            float historicalStart =
                 close[historicalOffset]

            float historicalFinal =
                 close[
                      historicalOffset -
                      forecastPeriod
                 ]

            if historicalStart > 0.0 and not na(historicalFinal)
                float finalReturn =
                     historicalFinal /
                     historicalStart -
                     1.0

                if finalReturn >= bullishThreshold / 100.0
                    array.push(
                         bullishOffsets,
                         historicalOffset
                    )

                else if finalReturn <= -(bearishThreshold / 100.0)
                    array.push(
                         bearishOffsets,
                         historicalOffset
                    )

                else
                    array.push(
                         sidewaysOffsets,
                         historicalOffset
                    )

// =====================================================================
// BUILD MEDIAN SCENARIO PATHS
// =====================================================================

if barstate.islast and currentFeaturesAvailable
    array.clear(bullishPath)
    array.clear(sidewaysPath)
    array.clear(bearishPath)

    float anchorPrice =
         close[baseOffset]

    array.push(
         bullishPath,
         anchorPrice
    )

    array.push(
         sidewaysPath,
         anchorPrice
    )

    array.push(
         bearishPath,
         anchorPrice
    )

    for futureStep = 1 to forecastPeriod
        array<float> bullishReturns =
             array.new_float()

        array<float> sidewaysReturns =
             array.new_float()

        array<float> bearishReturns =
             array.new_float()

        int bullishSize =
             array.size(bullishOffsets)

        if bullishSize > 0
            for scenarioIndex = 0 to bullishSize - 1
                int historicalOffset =
                     array.get(
                          bullishOffsets,
                          scenarioIndex
                     )

                float historicalStart =
                     close[historicalOffset]

                float historicalFuture =
                     close[
                          historicalOffset -
                          futureStep
                     ]

                if historicalStart > 0.0 and not na(historicalFuture)
                    array.push(
                         bullishReturns,
                         historicalFuture /
                         historicalStart -
                         1.0
                    )

        int sidewaysSize =
             array.size(sidewaysOffsets)

        if sidewaysSize > 0
            for scenarioIndex = 0 to sidewaysSize - 1
                int historicalOffset =
                     array.get(
                          sidewaysOffsets,
                          scenarioIndex
                     )

                float historicalStart =
                     close[historicalOffset]

                float historicalFuture =
                     close[
                          historicalOffset -
                          futureStep
                     ]

                if historicalStart > 0.0 and not na(historicalFuture)
                    array.push(
                         sidewaysReturns,
                         historicalFuture /
                         historicalStart -
                         1.0
                    )

        int bearishSize =
             array.size(bearishOffsets)

        if bearishSize > 0
            for scenarioIndex = 0 to bearishSize - 1
                int historicalOffset =
                     array.get(
                          bearishOffsets,
                          scenarioIndex
                     )

                float historicalStart =
                     close[historicalOffset]

                float historicalFuture =
                     close[
                          historicalOffset -
                          futureStep
                     ]

                if historicalStart > 0.0 and not na(historicalFuture)
                    array.push(
                         bearishReturns,
                         historicalFuture /
                         historicalStart -
                         1.0
                    )

        float bullishMedian =
             f_percentile(
                  bullishReturns,
                  50.0
             )

        float sidewaysMedian =
             f_percentile(
                  sidewaysReturns,
                  50.0
             )

        float bearishMedian =
             f_percentile(
                  bearishReturns,
                  50.0
             )

        array.push(
             bullishPath,
             na(bullishMedian)
             ? na
             : anchorPrice *
               (1.0 + bullishMedian)
        )

        array.push(
             sidewaysPath,
             na(sidewaysMedian)
             ? na
             : anchorPrice *
               (1.0 + sidewaysMedian)
        )

        array.push(
             bearishPath,
             na(bearishMedian)
             ? na
             : anchorPrice *
               (1.0 + bearishMedian)
        )

// =====================================================================
// SCENARIO COUNTS
// =====================================================================

int bullishCount =
     array.size(bullishOffsets)

int sidewaysCount =
     array.size(sidewaysOffsets)

int bearishCount =
     array.size(bearishOffsets)

int totalMatches =
     bullishCount +
     sidewaysCount +
     bearishCount

int dominantScenario = 0
int dominantCount = sidewaysCount

if bullishCount > dominantCount
    dominantScenario := 1
    dominantCount := bullishCount

if bearishCount > dominantCount
    dominantScenario := -1
    dominantCount := bearishCount

// =====================================================================
// DRAW SCENARIO PATHS
// =====================================================================

if barstate.islast
    f_delete_lines(bullishLines)
    f_delete_lines(sidewaysLines)
    f_delete_lines(bearishLines)
    f_delete_labels(scenarioLabels)

    int anchorBar =
         bar_index -
         baseOffset

    int pathSize =
         array.size(bullishPath)

    if totalMatches > 0 and pathSize > 1
        for pathIndex = 1 to pathSize - 1
            int firstBar =
                 anchorBar +
                 pathIndex -
                 1

            int secondBar =
                 anchorBar +
                 pathIndex

            if showAllScenarioPaths and bullishCount > 0
                float startValue =
                     array.get(
                          bullishPath,
                          pathIndex - 1
                     )

                float endValue =
                     array.get(
                          bullishPath,
                          pathIndex
                     )

                if not na(startValue) and not na(endValue)
                    bool dominant =
                         dominantScenario == 1

                    line bullishLine =
                         line.new(
                              x1 = firstBar,
                              y1 = startValue,
                              x2 = secondBar,
                              y2 = endValue,
                              xloc = xloc.bar_index,
                              color = color.new(
                                   bullishColor,
                                   dominant ? 0 : secondaryTransparency
                              ),
                              width = dominant
                              ? dominantPathWidth
                              : secondaryPathWidth
                         )

                    array.push(
                         bullishLines,
                         bullishLine
                    )

            if showAllScenarioPaths and sidewaysCount > 0
                float startValue =
                     array.get(
                          sidewaysPath,
                          pathIndex - 1
                     )

                float endValue =
                     array.get(
                          sidewaysPath,
                          pathIndex
                     )

                if not na(startValue) and not na(endValue)
                    bool dominant =
                         dominantScenario == 0

                    line sidewaysLine =
                         line.new(
                              x1 = firstBar,
                              y1 = startValue,
                              x2 = secondBar,
                              y2 = endValue,
                              xloc = xloc.bar_index,
                              color = color.new(
                                   sidewaysColor,
                                   dominant ? 0 : secondaryTransparency
                              ),
                              width = dominant
                              ? dominantPathWidth
                              : secondaryPathWidth
                         )

                    array.push(
                         sidewaysLines,
                         sidewaysLine
                    )

            if showAllScenarioPaths and bearishCount > 0
                float startValue =
                     array.get(
                          bearishPath,
                          pathIndex - 1
                     )

                float endValue =
                     array.get(
                          bearishPath,
                          pathIndex
                     )

                if not na(startValue) and not na(endValue)
                    bool dominant =
                         dominantScenario == -1

                    line bearishLine =
                         line.new(
                              x1 = firstBar,
                              y1 = startValue,
                              x2 = secondBar,
                              y2 = endValue,
                              xloc = xloc.bar_index,
                              color = color.new(
                                   bearishColor,
                                   dominant ? 0 : secondaryTransparency
                              ),
                              width = dominant
                              ? dominantPathWidth
                              : secondaryPathWidth
                         )

                    array.push(
                         bearishLines,
                         bearishLine
                    )

        int finalBar =
             anchorBar +
             forecastPeriod

        if showPathLabels and bullishCount > 0
            float finalBullish =
                 array.get(
                      bullishPath,
                      pathSize - 1
                 )

            if not na(finalBullish)
                string bullishText =
                     "Bullish " +
                     f_probability_text(
                          bullishCount,
                          totalMatches
                     )

                if showFinalPrice
                    bullishText +=
                         "\n" +
                         f_price_text(finalBullish)

                label bullishLabel =
                     label.new(
                          x = finalBar,
                          y = finalBullish,
                          text = bullishText,
                          xloc = xloc.bar_index,
                          style = label.style_label_left,
                          color = bullishColor,
                          textcolor = color.white,
                          size = size.small
                     )

                array.push(
                     scenarioLabels,
                     bullishLabel
                )

        if showPathLabels and sidewaysCount > 0
            float finalSideways =
                 array.get(
                      sidewaysPath,
                      pathSize - 1
                 )

            if not na(finalSideways)
                string sidewaysText =
                     "Sideways " +
                     f_probability_text(
                          sidewaysCount,
                          totalMatches
                     )

                if showFinalPrice
                    sidewaysText +=
                         "\n" +
                         f_price_text(finalSideways)

                label sidewaysLabel =
                     label.new(
                          x = finalBar,
                          y = finalSideways,
                          text = sidewaysText,
                          xloc = xloc.bar_index,
                          style = label.style_label_left,
                          color = sidewaysColor,
                          textcolor = color.white,
                          size = size.small
                     )

                array.push(
                     scenarioLabels,
                     sidewaysLabel
                )

        if showPathLabels and bearishCount > 0
            float finalBearish =
                 array.get(
                      bearishPath,
                      pathSize - 1
                 )

            if not na(finalBearish)
                string bearishText =
                     "Weakness " +
                     f_probability_text(
                          bearishCount,
                          totalMatches
                     )

                if showFinalPrice
                    bearishText +=
                         "\n" +
                         f_price_text(finalBearish)

                label bearishLabel =
                     label.new(
                          x = finalBar,
                          y = finalBearish,
                          text = bearishText,
                          xloc = xloc.bar_index,
                          style = label.style_label_left,
                          color = bearishColor,
                          textcolor = color.white,
                          size = size.small
                     )

                array.push(
                     scenarioLabels,
                     bearishLabel
                )

// =====================================================================
// COMPACT TABLE
// =====================================================================

var table probabilityTable =
     table.new(
          position.top_right,
          2,
          6,
          bgcolor = color.rgb(30, 30, 34),
          frame_color = color.rgb(90, 90, 95),
          frame_width = 1,
          border_color = color.rgb(90, 90, 95),
          border_width = 1
     )

if barstate.isfirst
    table.merge_cells(
         probabilityTable,
         0,
         0,
         1,
         0
    )

    table.merge_cells(
         probabilityTable,
         0,
         4,
         1,
         4
    )

    table.merge_cells(
         probabilityTable,
         0,
         5,
         1,
         5
    )

if barstate.islast
    if showProbabilityTable
        color tableText =
             color.rgb(245, 245, 245)

        color headerBackground =
             color.rgb(35, 35, 40)

        color footerBackground =
             color.rgb(48, 48, 54)

        string headerText =
             "Closest " +
             str.tostring(totalMatches) +
             " historical months"

        table.cell(
             probabilityTable,
             0,
             0,
             headerText,
             text_color = tableText,
             bgcolor = headerBackground,
             text_size = size.normal
        )

        table.cell(
             probabilityTable,
             0,
             1,
             "Bullish recovery",
             text_color = tableText,
             bgcolor = color.new(
                  bullishColor,
                  25
             )
        )

        table.cell(
             probabilityTable,
             1,
             1,
             f_probability_text(
                  bullishCount,
                  totalMatches
             ),
             text_color = tableText,
             bgcolor = color.new(
                  bullishColor,
                  25
             )
        )

        table.cell(
             probabilityTable,
             0,
             2,
             "Sideways",
             text_color = tableText,
             bgcolor = color.new(
                  sidewaysColor,
                  25
             )
        )

        table.cell(
             probabilityTable,
             1,
             2,
             f_probability_text(
                  sidewaysCount,
                  totalMatches
             ),
             text_color = tableText,
             bgcolor = color.new(
                  sidewaysColor,
                  25
             )
        )

        table.cell(
             probabilityTable,
             0,
             3,
             "Further weakness",
             text_color = tableText,
             bgcolor = color.new(
                  bearishColor,
                  25
             )
        )

        table.cell(
             probabilityTable,
             1,
             3,
             f_probability_text(
                  bearishCount,
                  totalMatches
             ),
             text_color = tableText,
             bgcolor = color.new(
                  bearishColor,
                  25
             )
        )

        table.cell(
             probabilityTable,
             0,
             4,
             "Based on the last trading month",
             text_color = tableText,
             bgcolor = footerBackground,
             text_size = size.small
        )

        table.cell(
             probabilityTable,
             0,
             5,
             "Outcome over the next trading month",
             text_color = tableText,
             bgcolor = footerBackground,
             text_size = size.small
        )

    else
        table.clear(
             probabilityTable,
             0,
             0,
             1,
             5
        )
````
