# SBP Market Levels Navigator

- url: https://www.tradingview.com/script/QOtOB1tx-SBP-Market-Levels-Navigator/
- type: indicator
- pine_id: PUB;c21e7afff3324fe6ae590be59aaf2ba9
- version: 4.0

## Description

SBP Market Levels Navigator is a standalone market-level mapping tool designed to identify and display only the strongest qualified support and resistance references for the trading day positioned at the right edge of the visible chart.

The script is intended to reduce chart clutter. It does not display intermediate or minor levels. Only Major levels that satisfy the internal qualification threshold are selected for plotting.

The script does not place orders, calculate position size, provide profit targets, define stop-loss levels, or present performance statistics. It is an analytical aid for independent chart study and risk-managed decision-making.

Methodology

The script uses one integrated level-selection workflow. Confirmed swing pivots, previous-day high and low, and previous-week high and low create candidate price references. Nearby candidates are consolidated so that similar prices are treated as one area rather than as multiple unrelated lines.

Each retained level is evaluated using:

Confirmed occurrence count

Price interaction count

Confirmed rejection behaviour

Reference-source weighting

Level freshness

Confirmed support-resistance role change

Only candidates that meet the Major-level score requirement are eligible for display. The strongest qualified levels nearest to price are selected separately above and below the market.

Selected trading-day display

The displayed trading day is the exchange-calendar day containing the chart's rightmost visible candle. Moving another historical day to the right edge of the visible chart causes the indicator to rebuild its display for that day.

Lines begin at the first bar of the selected day and end at the configured label offset after that day. They do not extend indefinitely across unrelated trading days.

Pine Script cannot detect the candle under the mouse pointer, so the rightmost visible candle is used as the practical historical-day selector.

Major levels only

The indicator displays only Major levels.

Support and resistance levels use thick lines and plain-text labels.

Intermediate and Minor classifications are not displayed and are not available as user controls.

This design keeps the chart focused on the strongest internally ranked areas.

Level colours and role changes

Support is displayed in green.

Resistance is displayed in red.

A resistance level that changes into support remains green and is labelled Rev Sup.

A support level that changes into resistance becomes red and is labelled Rev Res.

Normal support and resistance lines are solid. Confirmed role-reversal lines are dashed so that the change in market function remains visually identifiable without adding extra colours.

A support changes into resistance only after the required number of confirmed closes below the level. A resistance changes into support only after the required number of confirmed closes above the level.

Round-number display

Displayed levels can use exact prices, automatic rounding, or a manual rounding step of 1, 5, 10, 25, 50, or 100.

Auto mode chooses a practical rounding interval according to the instrument type and price range. This is intended to produce readable levels for indices, stocks, futures, commodities, forex, and other supported symbols.

The internal scoring process retains the calculated candidate price. The displayed line and label use the selected rounded price.

Nearby-level control

The indicator suppresses duplicate rounded prices and closely spaced levels. The minimum spacing is measured as a user-defined multiple of ATR. When two selected candidates are too close, only the stronger qualified level is retained.

Previous-day-origin levels may contribute to the internal ranking and may be plotted when they qualify, but they do not receive text labels. This reduces repetitive labels around commonly watched daily reference prices.

Labels

Labels are plain text with no shaded background and no border.

The available texts are:

Support

Resistance

Rev Sup

Rev Res

Labels include the displayed rounded price and appear after the selected trading day. Text size and label offset remain user controlled.

Main settings

Maximum Stored Levels limits the number of candidates retained in memory.

Maximum Level Age removes stale candidates from active consideration.

Confirmed Closes for Role Change controls how many closes beyond a level are required before its role changes.

Levels Per Side controls the maximum number of Major supports and Major resistances displayed.

Round Level Prices selects exact, automatic, or manual price rounding.

Minimum Display Separation controls the minimum distance between displayed levels as an ATR multiple.

Label Text Size controls the plain-text label size.

Label Offset After Selected Day controls how many bars after the selected day the labels are positioned.

Alerts

Alert conditions are available for:

Support-level tests

Resistance-level tests

Confirmed bullish rejections

Confirmed bearish rejections

Confirmed resistance-to-support changes

Confirmed support-to-resistance changes

These alerts describe analytical events only. They are not trade instructions.

Suggested use

Place the script on a standard price chart.

Move the current or historical trading day you want to study to the right edge of the visible chart.

Use Auto rounding for general use or select a manual step suited to the instrument.

Adjust Levels Per Side to control how many Major supports and resistances are shown.

Increase Minimum Display Separation when displayed levels remain too close.

Treat the plotted levels as areas for further observation rather than guaranteed reversal or breakout points.

Limitations

The levels are derived from historical price structure and confirmed reference data. They do not predict whether price will hold, reverse, or break.

Confirmed pivots appear only after the required confirmation bars have completed.

The historical-day selector follows the rightmost visible candle, not the mouse pointer.

Calendar-day selection may not perfectly represent instruments whose trading sessions cross midnight.

Rounded displayed prices may differ from the exact internal candidate prices.

The script should not be used as the sole basis for a trading decision.

Educational notice

This script is an analytical charting tool. It does not provide investment advice, guarantee outcomes, or replace independent analysis and risk management.

## Source Code

````pine
//@version=6
indicator("SBP Market Levels Navigator", overlay = true, max_bars_back = 3000, max_lines_count = 24, max_labels_count = 100)

string GROUP_COLOURS = "Colours"

color supportColor = input.color(color.rgb(25, 145, 95), "Support Colour", group = GROUP_COLOURS)
color resistanceColor = input.color(color.rgb(190, 60, 70), "Resistance Colour", group = GROUP_COLOURS)
color pivotPointColor = input.color(color.rgb(70, 110, 210), "Pivot Point Colour", group = GROUP_COLOURS)
color pivotSupportColor = input.color(color.rgb(25, 145, 95), "Pivot Support Colour", group = GROUP_COLOURS)
color pivotResistanceColor = input.color(color.rgb(190, 60, 70), "Pivot Resistance Colour", group = GROUP_COLOURS)

string GROUP_HTF = "Previous Period High / Low"

bool showPreviousDayLevels = input.bool(false, "Previous Day High / Low", group = GROUP_HTF)
bool showPreviousWeekLevels = input.bool(false, "Previous Week High / Low", group = GROUP_HTF)
bool showPreviousMonthLevels = input.bool(false, "Previous Month High / Low", group = GROUP_HTF)
bool showPreviousQuarterLevels = input.bool(false, "Previous Quarter High / Low", group = GROUP_HTF)
bool showPreviousYearLevels = input.bool(false, "Previous Year High / Low", group = GROUP_HTF)
int previousPeriodLabelOffset = input.int(4, "Level Label Offset (Bars)", minval = 1, maxval = 20, group = GROUP_HTF)

string GROUP_HTF_STYLE = "Previous Period Level Style"

color previousDayLevelColor = input.color(color.black, "PDH / PDL Colour", group = GROUP_HTF_STYLE)
color previousWeekLevelColor = input.color(color.black, "PWH / PWL Colour", group = GROUP_HTF_STYLE)
color previousMonthLevelColor = input.color(color.black, "PMH / PML Colour", group = GROUP_HTF_STYLE)
color previousQuarterLevelColor = input.color(color.black, "PQH / PQL Colour", group = GROUP_HTF_STYLE)
color previousYearLevelColor = input.color(color.black, "PYH / PYL Colour", group = GROUP_HTF_STYLE)

int previousLevelWidth = input.int(
     2,
     "Line Width",
     minval = 1,
     maxval = 4,
     group = GROUP_HTF_STYLE)

string previousLevelTextSizeInput = input.string(
     "Small",
     "Label Text Size",
     options = ["Tiny", "Small", "Normal", "Large"],
     group = GROUP_HTF_STYLE)

string previousLevelTextSize =
     previousLevelTextSizeInput == "Tiny" ? size.tiny :
     previousLevelTextSizeInput == "Normal" ? size.normal :
     previousLevelTextSizeInput == "Large" ? size.large :
     size.small

string GROUP_TRENDLINES = "Automatic Trendlines"

bool showRisingSupportTrendline = input.bool(true, "Show Rising Support Trendline", group = GROUP_TRENDLINES)
bool showFallingResistanceTrendline = input.bool(true, "Show Falling Resistance Trendline", group = GROUP_TRENDLINES)
bool extendTrendlinesRight = input.bool(true, "Extend Trendlines Right", group = GROUP_TRENDLINES)
color risingTrendlineColor = input.color(color.rgb(25, 145, 95), "Rising Support Colour", group = GROUP_TRENDLINES)
color fallingTrendlineColor = input.color(color.rgb(190, 60, 70), "Falling Resistance Colour", group = GROUP_TRENDLINES)
int trendlineWidth = input.int(2, "Trendline Width", minval = 1, maxval = 5, group = GROUP_TRENDLINES)

string GROUP_SIGNALS = "BUY / SALE Signals"

bool showMasterSignals = input.bool(true, "Show BUY / SALE", group = GROUP_SIGNALS)
float signalLabelDistanceATR = input.float(0.70, "Signal Distance (ATR)", minval = 0.10, maxval = 3.00, step = 0.05, group = GROUP_SIGNALS)
color buySignalColor = input.color(color.green, "BUY Colour", group = GROUP_SIGNALS)
color saleSignalColor = input.color(color.red, "SALE Colour", group = GROUP_SIGNALS)

bool isIndex = syminfo.type == "index"
bool isStock = syminfo.type == "stock"
bool isFutures = syminfo.type == "futures"
bool isForex = syminfo.type == "forex"
bool isCrypto = syminfo.type == "crypto"
bool isCFD = syminfo.type == "cfd"
bool isCommodityProfile = isFutures or isCFD

int maximumStoredLevels = isCrypto ? 32 : isIndex or isCommodityProfile ? 30 : isForex ? 26 : 24
int maximumLevelAge = isCrypto ? 1100 : isIndex or isCommodityProfile ? 900 : isForex ? 850 : 750
int acceptanceBars = isCrypto ? 3 : 2
int levelsPerSide = isIndex or isCommodityProfile or isCrypto ? 3 : 2
int pivotLeft = isIndex or isCommodityProfile ? 8 : isCrypto ? 7 : isForex ? 6 : 7
int pivotRight = isIndex or isCommodityProfile ? 5 : isCrypto ? 4 : isForex ? 3 : 4
float clusterATR = isCrypto ? 0.44 : isCommodityProfile ? 0.42 : isIndex ? 0.38 : isForex ? 0.32 : 0.35
float touchATR = isCrypto ? 0.30 : isCommodityProfile ? 0.27 : isIndex ? 0.24 : isForex ? 0.20 : 0.22
float breakATR = isCrypto ? 0.28 : isCommodityProfile ? 0.25 : isIndex ? 0.22 : isForex ? 0.18 : 0.20
float minimumDisplaySeparationATR = isCrypto ? 0.45 : isCommodityProfile ? 0.40 : isIndex ? 0.35 : isForex ? 0.28 : 0.32
int minimumTouchGap = isCrypto ? 10 : isForex ? 6 : 8
float majorScoreThreshold = isCrypto ? 78.0 : isForex ? 72.0 : 75.0
int labelBarsAfter = timeframe.isintraday ? (timeframe.multiplier <= 5 ? 8 : timeframe.multiplier <= 15 ? 6 : 4) : 2
string labelSizeAuto = isIndex or isCommodityProfile ? size.large : size.normal

float atrValue = ta.atr(14)
float safeATR = math.max(nz(atrValue, syminfo.mintick), syminfo.mintick)
float clusterDistance = safeATR * clusterATR
float touchDistance = safeATR * touchATR
float breakDistance = safeATR * breakATR

var array<float> levelPrice = array.new_float()
var array<int> levelRole = array.new_int()
var array<int> levelConfirmations = array.new_int()
var array<int> levelTouches = array.new_int()
var array<int> levelRejections = array.new_int()
var array<int> levelCreatedBar = array.new_int()
var array<int> levelLastTouchBar = array.new_int()
var array<int> levelAcceptanceCount = array.new_int()
var array<int> levelOrigin = array.new_int()
var array<bool> levelReversed = array.new_bool()
var array<bool> levelActive = array.new_bool()

clampValue(float value, float minimum, float maximum) =>
    math.max(minimum, math.min(maximum, value))

originWeight(int origin) =>
    float weight = 10.0
    if origin == 9
        weight := 24.0
    else if origin == 8
        weight := 23.0
    else if origin == 7
        weight := 22.0
    else if origin == 3
        weight := 20.0
    else if origin == 4
        weight := 18.0
    else if origin == 5
        weight := 17.0
    else if origin == 2
        weight := 16.0
    else if origin == 6
        weight := 15.0
    weight
isPivotOrigin(int origin) =>
    origin >= 4 and origin <= 6

lineWidthFromStrength(float score) =>
    score >= 92.0 ? 4 : score >= 84.0 ? 3 : 2

autoRoundStep(float price) =>
    float absolutePrice = math.abs(price)
    float step = syminfo.mintick
    if isIndex
        step := absolutePrice >= 50000.0 ? 50.0 : absolutePrice >= 10000.0 ? 25.0 : absolutePrice >= 1000.0 ? 10.0 : 5.0
    else if isStock
        step := absolutePrice >= 5000.0 ? 10.0 : absolutePrice >= 1000.0 ? 5.0 : absolutePrice >= 100.0 ? 1.0 : absolutePrice >= 20.0 ? 0.5 : 0.1
    else if isCommodityProfile
        step := absolutePrice >= 100000.0 ? 100.0 : absolutePrice >= 50000.0 ? 50.0 : absolutePrice >= 10000.0 ? 25.0 : absolutePrice >= 1000.0 ? 10.0 : absolutePrice >= 100.0 ? 1.0 : syminfo.mintick
    else if isCrypto
        step := absolutePrice >= 50000.0 ? 100.0 : absolutePrice >= 10000.0 ? 50.0 : absolutePrice >= 1000.0 ? 10.0 : absolutePrice >= 100.0 ? 1.0 : absolutePrice >= 1.0 ? 0.1 : math.max(syminfo.mintick * 10.0, syminfo.mintick)
    else if isForex
        step := math.max(syminfo.mintick * 10.0, syminfo.mintick)
    else
        step := absolutePrice >= 10000.0 ? 25.0 : absolutePrice >= 1000.0 ? 10.0 : absolutePrice >= 100.0 ? 1.0 : syminfo.mintick
    math.max(step, syminfo.mintick)

roundLevelPrice(float price) =>
    float step = autoRoundStep(price)
    math.round(price / step) * step

removeLevelAt(int index) =>
    array.remove(levelPrice, index)
    array.remove(levelRole, index)
    array.remove(levelConfirmations, index)
    array.remove(levelTouches, index)
    array.remove(levelRejections, index)
    array.remove(levelCreatedBar, index)
    array.remove(levelLastTouchBar, index)
    array.remove(levelAcceptanceCount, index)
    array.remove(levelOrigin, index)
    array.remove(levelReversed, index)
    array.remove(levelActive, index)

findOldestLevelIndex() =>
    int oldestIndex = -1
    int oldestBar = bar_index
    int count = array.size(levelPrice)
    if count > 0
        for i = 0 to count - 1
            int createdBar = array.get(levelCreatedBar, i)
            if createdBar <= oldestBar
                oldestBar := createdBar
                oldestIndex := i
    oldestIndex

addOrMergeLevel(float candidatePrice, int candidateRole, int candidateOrigin) =>
    if not na(candidatePrice)
        int nearestIndex = -1
        float nearestDistance = 1e20
        int count = array.size(levelPrice)
        if count > 0
            for i = 0 to count - 1
                bool active = array.get(levelActive, i)
                float storedPrice = array.get(levelPrice, i)
                float distance = math.abs(candidatePrice - storedPrice)
                if active and distance <= clusterDistance and distance < nearestDistance
                    nearestDistance := distance
                    nearestIndex := i
        if nearestIndex >= 0
            int oldConfirmations = array.get(levelConfirmations, nearestIndex)
            float oldPrice = array.get(levelPrice, nearestIndex)
            float blendedPrice = (oldPrice * oldConfirmations + candidatePrice) / (oldConfirmations + 1)
            array.set(levelPrice, nearestIndex, blendedPrice)
            array.set(levelConfirmations, nearestIndex, oldConfirmations + 1)
            int storedOrigin = array.get(levelOrigin, nearestIndex)
            if originWeight(candidateOrigin) > originWeight(storedOrigin)
                array.set(levelOrigin, nearestIndex, candidateOrigin)
            if candidateRole != 0
                array.set(levelRole, nearestIndex, candidateRole)
        else
            if array.size(levelPrice) >= maximumStoredLevels
                int oldestIndex = findOldestLevelIndex()
                if oldestIndex >= 0
                    removeLevelAt(oldestIndex)
            array.push(levelPrice, candidatePrice)
            array.push(levelRole, candidateRole)
            array.push(levelConfirmations, 1)
            array.push(levelTouches, 0)
            array.push(levelRejections, 0)
            array.push(levelCreatedBar, bar_index)
            array.push(levelLastTouchBar, na)
            array.push(levelAcceptanceCount, 0)
            array.push(levelOrigin, candidateOrigin)
            array.push(levelReversed, false)
            array.push(levelActive, true)

levelScore(int index) =>
    int confirmations = array.get(levelConfirmations, index)
    int touches = array.get(levelTouches, index)
    int rejections = array.get(levelRejections, index)
    int createdBar = array.get(levelCreatedBar, index)
    int origin = array.get(levelOrigin, index)
    bool reversed = array.get(levelReversed, index)
    int age = math.max(bar_index - createdBar, 0)
    float confirmationScore = math.min(confirmations, 5) * 8.0
    float touchScore = math.min(touches, 5) * 4.0
    float rejectionScore = math.min(rejections, 4) * 6.0
    float sourceScore = originWeight(origin)
    float freshnessRatio = 1.0 - float(age) / float(math.max(maximumLevelAge, 1))
    float freshnessScore = clampValue(12.0 * freshnessRatio, 0.0, 12.0)
    float reversalScore = reversed ? 6.0 : 0.0
    clampValue(confirmationScore + touchScore + rejectionScore + sourceScore + freshnessScore + reversalScore, 0.0, 100.0)

float confirmedPivotHigh = ta.pivothigh(high, pivotLeft, pivotRight)
float confirmedPivotLow = ta.pivotlow(low, pivotLeft, pivotRight)

var float previousTrendLowPrice = na
var int previousTrendLowBar = na
var float previousTrendHighPrice = na
var int previousTrendHighBar = na

var line risingSupportLine = na
var line fallingResistanceLine = na

bool trendLowConfirmed = barstate.isconfirmed and not na(confirmedPivotLow)
bool trendHighConfirmed = barstate.isconfirmed and not na(confirmedPivotHigh)

if trendLowConfirmed
    int currentTrendLowBar = bar_index - pivotRight
    float currentTrendLowPrice = confirmedPivotLow
    bool createsHigherLow =
         not na(previousTrendLowPrice) and
         not na(previousTrendLowBar) and
         currentTrendLowPrice > previousTrendLowPrice and
         currentTrendLowBar > previousTrendLowBar
    if createsHigherLow
        if not na(risingSupportLine)
            line.delete(risingSupportLine)
        risingSupportLine :=
             line.new(
                  previousTrendLowBar,
                  previousTrendLowPrice,
                  currentTrendLowBar,
                  currentTrendLowPrice,
                  xloc = xloc.bar_index,
                  extend = extendTrendlinesRight ? extend.right : extend.none,
                  color = showRisingSupportTrendline ? risingTrendlineColor : color.new(risingTrendlineColor, 100),
                  width = trendlineWidth)
    else if not na(previousTrendLowPrice) and currentTrendLowPrice <= previousTrendLowPrice
        if not na(risingSupportLine)
            line.delete(risingSupportLine)
            risingSupportLine := na
    previousTrendLowPrice := currentTrendLowPrice
    previousTrendLowBar := currentTrendLowBar

if trendHighConfirmed
    int currentTrendHighBar = bar_index - pivotRight
    float currentTrendHighPrice = confirmedPivotHigh
    bool createsLowerHigh =
         not na(previousTrendHighPrice) and
         not na(previousTrendHighBar) and
         currentTrendHighPrice < previousTrendHighPrice and
         currentTrendHighBar > previousTrendHighBar
    if createsLowerHigh
        if not na(fallingResistanceLine)
            line.delete(fallingResistanceLine)
        fallingResistanceLine :=
             line.new(
                  previousTrendHighBar,
                  previousTrendHighPrice,
                  currentTrendHighBar,
                  currentTrendHighPrice,
                  xloc = xloc.bar_index,
                  extend = extendTrendlinesRight ? extend.right : extend.none,
                  color = showFallingResistanceTrendline ? fallingTrendlineColor : color.new(fallingTrendlineColor, 100),
                  width = trendlineWidth)
    else if not na(previousTrendHighPrice) and currentTrendHighPrice >= previousTrendHighPrice
        if not na(fallingResistanceLine)
            line.delete(fallingResistanceLine)
            fallingResistanceLine := na
    previousTrendHighPrice := currentTrendHighPrice
    previousTrendHighBar := currentTrendHighBar

float risingSupportValue =
     not na(risingSupportLine) ?
     line.get_price(risingSupportLine, bar_index) :
     na

float fallingResistanceValue =
     not na(fallingResistanceLine) ?
     line.get_price(fallingResistanceLine, bar_index) :
     na

if barstate.islast
    if not na(risingSupportLine)
        line.set_color(
             risingSupportLine,
             showRisingSupportTrendline ?
             risingTrendlineColor :
             color.new(risingTrendlineColor, 100))
        line.set_width(risingSupportLine, trendlineWidth)
        line.set_extend(
             risingSupportLine,
             extendTrendlinesRight ? extend.right : extend.none)
        if not extendTrendlinesRight
            line.set_x2(risingSupportLine, bar_index)
            line.set_y2(risingSupportLine, risingSupportValue)

    if not na(fallingResistanceLine)
        line.set_color(
             fallingResistanceLine,
             showFallingResistanceTrendline ?
             fallingTrendlineColor :
             color.new(fallingTrendlineColor, 100))
        line.set_width(fallingResistanceLine, trendlineWidth)
        line.set_extend(
             fallingResistanceLine,
             extendTrendlinesRight ? extend.right : extend.none)
        if not extendTrendlinesRight
            line.set_x2(fallingResistanceLine, bar_index)
            line.set_y2(fallingResistanceLine, fallingResistanceValue)
if barstate.isconfirmed
    if not na(confirmedPivotHigh)
        addOrMergeLevel(confirmedPivotHigh, -1, 1)
    if not na(confirmedPivotLow)
        addOrMergeLevel(confirmedPivotLow, 1, 1)

[previousDayHigh, previousDayLow, previousDayClose] = request.security(syminfo.tickerid, "D", [high[1], low[1], close[1]], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[previousWeekHigh, previousWeekLow] = request.security(syminfo.tickerid, "W", [high[1], low[1]], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[previousMonthHigh, previousMonthLow] = request.security(syminfo.tickerid, "M", [high[1], low[1]], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[previousQuarterHigh, previousQuarterLow] = request.security(syminfo.tickerid, "3M", [high[1], low[1]], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[previousYearHigh, previousYearLow] = request.security(syminfo.tickerid, "12M", [high[1], low[1]], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

float classicPivotPoint = (previousDayHigh + previousDayLow + previousDayClose) / 3.0
float classicPivotR1 = 2.0 * classicPivotPoint - previousDayLow
float classicPivotS1 = 2.0 * classicPivotPoint - previousDayHigh
float classicPivotR2 = classicPivotPoint + previousDayHigh - previousDayLow
float classicPivotS2 = classicPivotPoint - previousDayHigh + previousDayLow

bool newDay = ta.change(time("D")) != 0
bool newWeek = ta.change(time("W")) != 0
bool newMonth = ta.change(time("M")) != 0
bool newQuarter = ta.change(time("3M")) != 0
bool newYear = ta.change(time("12M")) != 0

var int currentDayStartTime = time
var int currentDayStartBar = bar_index

if newDay
    currentDayStartTime := time
    currentDayStartBar := bar_index

if barstate.isconfirmed and newDay and showPreviousDayLevels
    addOrMergeLevel(previousDayHigh, -1, 2)
    addOrMergeLevel(previousDayLow, 1, 2)
    int pivotPointRole = open >= classicPivotPoint ? 1 : -1
    addOrMergeLevel(classicPivotPoint, pivotPointRole, 4)
    addOrMergeLevel(classicPivotS1, 1, 5)
    addOrMergeLevel(classicPivotR1, -1, 5)
    addOrMergeLevel(classicPivotS2, 1, 6)
    addOrMergeLevel(classicPivotR2, -1, 6)

if barstate.isconfirmed and newWeek and showPreviousWeekLevels
    addOrMergeLevel(previousWeekHigh, -1, 3)
    addOrMergeLevel(previousWeekLow, 1, 3)

if barstate.isconfirmed and newMonth and showPreviousMonthLevels
    addOrMergeLevel(previousMonthHigh, -1, 7)
    addOrMergeLevel(previousMonthLow, 1, 7)

if barstate.isconfirmed and newQuarter and showPreviousQuarterLevels
    addOrMergeLevel(previousQuarterHigh, -1, 8)
    addOrMergeLevel(previousQuarterLow, 1, 8)

if barstate.isconfirmed and newYear and showPreviousYearLevels
    addOrMergeLevel(previousYearHigh, -1, 9)
    addOrMergeLevel(previousYearLow, 1, 9)

bool anySupportTest = false
bool anyResistanceTest = false
bool anyBullishRejection = false
bool anyBearishRejection = false
bool anyBullishRoleChange = false
bool anyBearishRoleChange = false

float candleRange = math.max(high - low, syminfo.mintick)
float lowerWickRatio = (math.min(open, close) - low) / candleRange
float upperWickRatio = (high - math.max(open, close)) / candleRange
float bullCloseLocation = (close - low) / candleRange
float bearCloseLocation = (high - close) / candleRange
int activeLevelCount = array.size(levelPrice)

if barstate.isconfirmed and activeLevelCount > 0
    for i = 0 to activeLevelCount - 1
        bool active = array.get(levelActive, i)
        if active
            float price = array.get(levelPrice, i)
            int role = array.get(levelRole, i)
            int createdBar = array.get(levelCreatedBar, i)
            int age = bar_index - createdBar
            if age > maximumLevelAge
                array.set(levelActive, i, false)
            else
                bool priceTested = high >= price - touchDistance and low <= price + touchDistance
                int lastTouchBar = array.get(levelLastTouchBar, i)
                bool touchGapPassed = na(lastTouchBar) or bar_index - lastTouchBar >= minimumTouchGap
                bool supportRejection = role == 1 and low <= price + touchDistance and close > price and lowerWickRatio >= 0.28 and bullCloseLocation >= 0.58
                bool resistanceRejection = role == -1 and high >= price - touchDistance and close < price and upperWickRatio >= 0.28 and bearCloseLocation >= 0.58
                if priceTested and touchGapPassed
                    array.set(levelTouches, i, array.get(levelTouches, i) + 1)
                    array.set(levelLastTouchBar, i, bar_index)
                    if role == 1
                        anySupportTest := true
                    else
                        anyResistanceTest := true
                if supportRejection
                    array.set(levelRejections, i, array.get(levelRejections, i) + 1)
                    anyBullishRejection := true
                if resistanceRejection
                    array.set(levelRejections, i, array.get(levelRejections, i) + 1)
                    anyBearishRejection := true
                bool acceptedBelow = role == 1 and close < price - breakDistance
                bool acceptedAbove = role == -1 and close > price + breakDistance
                int acceptedCount = array.get(levelAcceptanceCount, i)
                acceptedCount := acceptedBelow or acceptedAbove ? acceptedCount + 1 : 0
                array.set(levelAcceptanceCount, i, acceptedCount)
                if acceptedCount >= acceptanceBars
                    if role == 1
                        array.set(levelRole, i, -1)
                        anyBearishRoleChange := true
                    else
                        array.set(levelRole, i, 1)
                        anyBullishRoleChange := true
                    array.set(levelReversed, i, true)
                    array.set(levelAcceptanceCount, i, 0)
                    array.set(levelCreatedBar, i, bar_index)

bool bullishLevelEvidence =
     anySupportTest and
     anyBullishRejection

bool bearishLevelEvidence =
     anyResistanceTest and
     anyBearishRejection

int bullishEvidenceCount =
     (bullishLevelEvidence ? 1 : 0) +
     (anyBullishRoleChange ? 1 : 0)

int bearishEvidenceCount =
     (bearishLevelEvidence ? 1 : 0) +
     (anyBearishRoleChange ? 1 : 0)

bool rawMasterBuy =
     barstate.isconfirmed and
     bullishEvidenceCount > 0 and
     bullishEvidenceCount > bearishEvidenceCount

bool rawMasterSale =
     barstate.isconfirmed and
     bearishEvidenceCount > 0 and
     bearishEvidenceCount > bullishEvidenceCount

var int masterSignalState = 0

bool masterBuySignal =
     rawMasterBuy and
     masterSignalState != 1

bool masterSaleSignal =
     rawMasterSale and
     masterSignalState != -1

if masterBuySignal
    masterSignalState := 1
else if masterSaleSignal
    masterSignalState := -1

if showMasterSignals and masterBuySignal
    label.new(
         bar_index,
         low - safeATR * signalLabelDistanceATR,
         "BUY",
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_label_up,
         color = buySignalColor,
         textcolor = color.white,
         size = size.small)

if showMasterSignals and masterSaleSignal
    label.new(
         bar_index,
         high + safeATR * signalLabelDistanceATR,
         "SALE",
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_label_down,
         color = saleSignalColor,
         textcolor = color.white,
         size = size.small)

var array<line> displayLines = array.new_line()
var array<label> displayLabels = array.new_label()
var array<int> selectedIndices = array.new_int()
var array<float> selectedDisplayedPrices = array.new_float()
var array<int> selectedDisplayedRoles = array.new_int()

if barstate.isfirst
    for slot = 0 to 5
        line newLine = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, extend = extend.none, color = color.new(color.gray, 100), width = 1)
        label newLabel = label.new(bar_index, close, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_none, color = color.new(color.gray, 100), textcolor = color.new(color.white, 100), size = size.tiny)
        array.push(displayLines, newLine)
        array.push(displayLabels, newLabel)

if barstate.islast
    array.clear(selectedIndices)
    array.clear(selectedDisplayedPrices)
    array.clear(selectedDisplayedRoles)
    for sidePass = 0 to 1
        int wantedRole = sidePass == 0 ? 1 : -1
        for rank = 0 to levelsPerSide - 1
            int bestIndex = -1
            float bestRankValue = -1e20
            int storedCount = array.size(levelPrice)
            if storedCount > 0
                for i = 0 to storedCount - 1
                    bool active = array.get(levelActive, i)
                    int role = array.get(levelRole, i)
                    float price = array.get(levelPrice, i)
                    float displayedPrice = roundLevelPrice(price)
                    float score = levelScore(i)
                    bool alreadySelected = array.indexof(selectedIndices, i) >= 0
                    bool duplicateRoundedLevel = false
                    int selectedCount = array.size(selectedDisplayedPrices)
                    if selectedCount > 0
                        for selectedPosition = 0 to selectedCount - 1
                            float existingRoundedPrice = array.get(selectedDisplayedPrices, selectedPosition)
                            int existingRoundedRole = array.get(selectedDisplayedRoles, selectedPosition)
                            float minimumDisplayDistance = math.max(syminfo.mintick, safeATR * minimumDisplaySeparationATR)
                            bool identicalRoundedPrice = math.abs(existingRoundedPrice - displayedPrice) <= syminfo.mintick
                            bool nearbyDisplayedPrice = math.abs(existingRoundedPrice - displayedPrice) < minimumDisplayDistance
                            if existingRoundedRole == wantedRole and (identicalRoundedPrice or nearbyDisplayedPrice)
                                duplicateRoundedLevel := true
                    bool sideLocationValid = wantedRole == 1 ? displayedPrice <= close + touchDistance : displayedPrice >= close - touchDistance
                    float distanceATR = math.abs(displayedPrice - close) / safeATR
                    float proximityBonus = clampValue(16.0 - distanceATR * 2.0, 0.0, 16.0)
                    float rankValue = score + proximityBonus
                    bool qualified = active and role == wantedRole and sideLocationValid and not alreadySelected and not duplicateRoundedLevel and score >= majorScoreThreshold
                    if qualified and rankValue > bestRankValue
                        bestRankValue := rankValue
                        bestIndex := i
            if bestIndex >= 0
                array.push(selectedIndices, bestIndex)
                array.push(selectedDisplayedPrices, roundLevelPrice(array.get(levelPrice, bestIndex)))
                array.push(selectedDisplayedRoles, wantedRole)

    int activeDayStartBar = currentDayStartBar
    int labelBar = bar_index + labelBarsAfter
    for slot = 0 to 5
        line levelLine = array.get(displayLines, slot)
        label levelLabel = array.get(displayLabels, slot)
        if slot < array.size(selectedIndices)
            int index = array.get(selectedIndices, slot)
            float displayedPrice = roundLevelPrice(array.get(levelPrice, index))
            float score = levelScore(index)
            int role = array.get(levelRole, index)
            int origin = array.get(levelOrigin, index)
            bool reversed = array.get(levelReversed, index)
            bool pivotOrigin = isPivotOrigin(origin)
            color standardRoleColor = role == 1 ? supportColor : resistanceColor
            color pivotRoleColor = origin == 4 ? pivotPointColor : role == 1 ? pivotSupportColor : pivotResistanceColor
            color activeLineColor = pivotOrigin ? pivotRoleColor : standardRoleColor
            int activeWidth = lineWidthFromStrength(score)
            string standardRoleText = role == 1 ? "Support" : "Resistance"
            string pivotRoleText = role == 1 ? "Pivot S2" : "Pivot R2"
            if origin == 4
                pivotRoleText := "Pivot"
            else if origin == 5
                pivotRoleText := role == 1 ? "Pivot S1" : "Pivot R1"

            string periodRoleText = standardRoleText
            if origin == 3
                periodRoleText := role == 1 ? "PWL" : "PWH"
            else if origin == 7
                periodRoleText := role == 1 ? "PML" : "PMH"
            else if origin == 8
                periodRoleText := role == 1 ? "PQL" : "PQH"
            else if origin == 9
                periodRoleText := role == 1 ? "PYL" : "PYH"

            string roleText = periodRoleText
            if reversed
                roleText := role == 1 ? "Rev Sup" : "Rev Res"
            else if pivotOrigin
                roleText := pivotRoleText

            string completeLabelText = roleText + "  " + str.tostring(displayedPrice, format.mintick)
            bool displayThisLabel = origin != 2
            line.set_xy1(levelLine, activeDayStartBar, displayedPrice)
            line.set_xy2(levelLine, labelBar, displayedPrice)
            line.set_extend(levelLine, extend.none)
            line.set_color(levelLine, activeLineColor)
            line.set_width(levelLine, activeWidth)
            line.set_style(levelLine, line.style_solid)
            label.set_xy(levelLabel, labelBar, displayedPrice)
            label.set_style(levelLabel, label.style_none)
            label.set_text(levelLabel, displayThisLabel ? completeLabelText : "")
            label.set_color(levelLabel, color.new(activeLineColor, 100))
            label.set_textcolor(levelLabel, displayThisLabel ? activeLineColor : color.new(activeLineColor, 100))
            label.set_size(levelLabel, labelSizeAuto)
        else
            line.set_color(levelLine, color.new(color.gray, 100))
            line.set_extend(levelLine, extend.none)
            label.set_text(levelLabel, "")
            label.set_color(levelLabel, color.new(color.gray, 100))
            label.set_textcolor(levelLabel, color.new(color.white, 100))

updateCurrentPeriodLevel(
     line currentLine,
     label currentLabel,
     bool showLevel,
     float levelPriceValue,
     string levelCode,
     color levelColor,
     int levelStartTime) =>

    line resultLine = currentLine
    label resultLabel = currentLabel

    if barstate.islast
        if showLevel and not na(levelPriceValue)
            int estimatedBarDuration = int(math.max(time - nz(time[1], time), 1))
            int labelTime = time + estimatedBarDuration * previousPeriodLabelOffset
            string labelText = levelCode + "  " + str.tostring(levelPriceValue, format.mintick)

            if na(resultLine)
                resultLine := line.new(
                     levelStartTime,
                     levelPriceValue,
                     labelTime,
                     levelPriceValue,
                     xloc = xloc.bar_time,
                     extend = extend.none,
                     color = levelColor,
                     style = line.style_solid,
                     width = previousLevelWidth)
            else
                line.set_xy1(resultLine, levelStartTime, levelPriceValue)
                line.set_xy2(resultLine, labelTime, levelPriceValue)
                line.set_extend(resultLine, extend.none)
                line.set_color(resultLine, levelColor)
                line.set_style(resultLine, line.style_solid)
                line.set_width(resultLine, previousLevelWidth)

            if na(resultLabel)
                resultLabel := label.new(
                     labelTime,
                     levelPriceValue,
                     labelText,
                     xloc = xloc.bar_time,
                     yloc = yloc.price,
                     style = label.style_label_left,
                     color = color.new(levelColor, 100),
                     textcolor = levelColor,
                     size = previousLevelTextSize)
            else
                label.set_xy(resultLabel, labelTime, levelPriceValue)
                label.set_text(resultLabel, labelText)
                label.set_style(resultLabel, label.style_label_left)
                label.set_color(resultLabel, color.new(levelColor, 100))
                label.set_textcolor(resultLabel, levelColor)
                label.set_size(resultLabel, previousLevelTextSize)
        else
            if not na(resultLine)
                line.delete(resultLine)
                resultLine := na
            if not na(resultLabel)
                label.delete(resultLabel)
                resultLabel := na

    [resultLine, resultLabel]

var line pdhLine = na
var line pdlLine = na
var line pwhLine = na
var line pwlLine = na
var line pmhLine = na
var line pmlLine = na
var line pqhLine = na
var line pqlLine = na
var line pyhLine = na
var line pylLine = na

var label pdhLabel = na
var label pdlLabel = na
var label pwhLabel = na
var label pwlLabel = na
var label pmhLabel = na
var label pmlLabel = na
var label pqhLabel = na
var label pqlLabel = na
var label pyhLabel = na
var label pylLabel = na

[nextPdhLine, nextPdhLabel] = updateCurrentPeriodLevel(
     pdhLine, pdhLabel, showPreviousDayLevels,
     previousDayHigh, "PDH", previousDayLevelColor, currentDayStartTime)
pdhLine := nextPdhLine
pdhLabel := nextPdhLabel

[nextPdlLine, nextPdlLabel] = updateCurrentPeriodLevel(
     pdlLine, pdlLabel, showPreviousDayLevels,
     previousDayLow, "PDL", previousDayLevelColor, currentDayStartTime)
pdlLine := nextPdlLine
pdlLabel := nextPdlLabel

[nextPwhLine, nextPwhLabel] = updateCurrentPeriodLevel(
     pwhLine, pwhLabel, showPreviousWeekLevels,
     previousWeekHigh, "PWH", previousWeekLevelColor, currentDayStartTime)
pwhLine := nextPwhLine
pwhLabel := nextPwhLabel

[nextPwlLine, nextPwlLabel] = updateCurrentPeriodLevel(
     pwlLine, pwlLabel, showPreviousWeekLevels,
     previousWeekLow, "PWL", previousWeekLevelColor, currentDayStartTime)
pwlLine := nextPwlLine
pwlLabel := nextPwlLabel

[nextPmhLine, nextPmhLabel] = updateCurrentPeriodLevel(
     pmhLine, pmhLabel, showPreviousMonthLevels,
     previousMonthHigh, "PMH", previousMonthLevelColor, currentDayStartTime)
pmhLine := nextPmhLine
pmhLabel := nextPmhLabel

[nextPmlLine, nextPmlLabel] = updateCurrentPeriodLevel(
     pmlLine, pmlLabel, showPreviousMonthLevels,
     previousMonthLow, "PML", previousMonthLevelColor, currentDayStartTime)
pmlLine := nextPmlLine
pmlLabel := nextPmlLabel

[nextPqhLine, nextPqhLabel] = updateCurrentPeriodLevel(
     pqhLine, pqhLabel, showPreviousQuarterLevels,
     previousQuarterHigh, "PQH", previousQuarterLevelColor, currentDayStartTime)
pqhLine := nextPqhLine
pqhLabel := nextPqhLabel

[nextPqlLine, nextPqlLabel] = updateCurrentPeriodLevel(
     pqlLine, pqlLabel, showPreviousQuarterLevels,
     previousQuarterLow, "PQL", previousQuarterLevelColor, currentDayStartTime)
pqlLine := nextPqlLine
pqlLabel := nextPqlLabel

[nextPyhLine, nextPyhLabel] = updateCurrentPeriodLevel(
     pyhLine, pyhLabel, showPreviousYearLevels,
     previousYearHigh, "PYH", previousYearLevelColor, currentDayStartTime)
pyhLine := nextPyhLine
pyhLabel := nextPyhLabel

[nextPylLine, nextPylLabel] = updateCurrentPeriodLevel(
     pylLine, pylLabel, showPreviousYearLevels,
     previousYearLow, "PYL", previousYearLevelColor, currentDayStartTime)
pylLine := nextPylLine
pylLabel := nextPylLabel

alertcondition(
     masterBuySignal,
     "BUY",
     "A confirmed BUY signal was generated on {{ticker}} {{interval}}.")

alertcondition(
     masterSaleSignal,
     "SALE",
     "A confirmed SALE signal was generated on {{ticker}} {{interval}}.")

alertcondition(
     masterBuySignal or masterSaleSignal,
     "BUY or SALE",
     "A confirmed BUY or SALE signal was generated on {{ticker}} {{interval}}.")
````
