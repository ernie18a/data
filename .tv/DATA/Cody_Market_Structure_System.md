<!-- tradingview-pine-id: PUB;4588b951ad2e4740aeef3b9b0da49f04 -->
<!-- tradingviewscripts-format: 1 -->
# Cody Market Structure System

Source: https://www.tradingview.com/script/olaS0s7a-Cody-Market-Structure-System/

## Description

Only for my Students
marks out highs and lows, mitigation/ order blocks, fvgs and bear and bull sweeps

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © johncemmerling

//@version=6
indicator(
     "Cody Market Structure System",
     shorttitle = "CMS",
     overlay = true,
     max_lines_count = 500,
     max_labels_count = 500,
     max_boxes_count = 300
)

//=====================================================================
// CODY MARKET STRUCTURE SYSTEM
//=====================================================================
//
// FOUNDATION
// • Monday / Wednesday / Friday highs and lows
// • Previous day high and low
// • Previous week high and low
// • Previous month high and low
// • Asian session high and low
// • Confirmed 1-hour swing highs and lows
//
// SETUP 1
// Key level → clean rejection → target next liquidity
//
// SETUP 2
// Liquidity sweep → MSS/BOS → FVG or OB → confirmation
//
// PRIORITY CONCEPT
// • Mitigation candle / last opposite candle before displacement
//
// ADDITIONAL CONTEXT
// • AMD awareness must still be read manually
//
// This indicator uses objective price-action proxies.
// It cannot see actual hidden orders or stop locations.
//=====================================================================


//=====================================================================
// INPUT GROUPS
//=====================================================================

string GROUP_GENERAL   = "01 — General"
string GROUP_MWF       = "02 — Monday / Wednesday / Friday"
string GROUP_HTF       = "03 — Daily / Weekly / Monthly"
string GROUP_ASIA      = "04 — Asian Session"
string GROUP_SWINGS    = "05 — Swing Levels"
string GROUP_STRUCTURE = "06 — BOS and MSS"
string GROUP_REJECTION = "07 — Rejections and Sweeps"
string GROUP_FVG       = "08 — Fair Value Gaps"
string GROUP_OB        = "09 — Order Blocks and Mitigation"


//=====================================================================
// GENERAL SETTINGS
//=====================================================================

string analysisTimezone = input.string(
     "America/New_York",
     "Analysis Time Zone",
     group = GROUP_GENERAL,
     tooltip = "Change this if your chart session uses another time zone."
)

bool showLevelLabels = input.bool(
     true,
     "Show M/W/F Labels",
     group = GROUP_GENERAL
)

bool showPricesInLabels = input.bool(
     true,
     "Show Prices in M/W/F Labels",
     group = GROUP_GENERAL
)

int keyLevelWidth = input.int(
     1,
     "Key-Level Width",
     minval = 1,
     maxval = 4,
     group = GROUP_GENERAL
)

string keyLevelStyleInput = input.string(
     "Solid",
     "M/W/F Line Style",
     options = ["Solid", "Dashed", "Dotted"],
     group = GROUP_GENERAL
)

keyLevelStyle =
     keyLevelStyleInput == "Dashed" ? line.style_dashed :
     keyLevelStyleInput == "Dotted" ? line.style_dotted :
     line.style_solid


//=====================================================================
// MONDAY / WEDNESDAY / FRIDAY SETTINGS
//=====================================================================

bool showMonday = input.bool(
     true,
     "Show Monday High and Low",
     group = GROUP_MWF
)

bool showWednesday = input.bool(
     true,
     "Show Wednesday High and Low",
     group = GROUP_MWF
)

bool showFriday = input.bool(
     true,
     "Show Friday High and Low",
     group = GROUP_MWF
)

int weeksBack = input.int(
     2,
     "Weeks of M/W/F Levels",
     minval = 1,
     maxval = 10,
     group = GROUP_MWF
)

color mondayHighColor = input.color(
     color.rgb(33, 150, 243),
     "Monday High",
     group = GROUP_MWF
)

color mondayLowColor = input.color(
     color.rgb(100, 181, 246),
     "Monday Low",
     group = GROUP_MWF
)

color wednesdayHighColor = input.color(
     color.rgb(255, 193, 7),
     "Wednesday High",
     group = GROUP_MWF
)

color wednesdayLowColor = input.color(
     color.rgb(255, 152, 0),
     "Wednesday Low",
     group = GROUP_MWF
)

color fridayHighColor = input.color(
     color.rgb(233, 30, 99),
     "Friday High",
     group = GROUP_MWF
)

color fridayLowColor = input.color(
     color.rgb(198, 40, 40),
     "Friday Low",
     group = GROUP_MWF
)


//=====================================================================
// HIGHER-TIMEFRAME SETTINGS
//=====================================================================

bool showPreviousDay = input.bool(
     true,
     "Previous Day High and Low",
     group = GROUP_HTF
)

bool showPreviousWeek = input.bool(
     true,
     "Previous Week High and Low",
     group = GROUP_HTF
)

bool showPreviousMonth = input.bool(
     true,
     "Previous Month High and Low",
     group = GROUP_HTF
)

color previousDayColor = input.color(
     color.rgb(144, 202, 249),
     "Previous-Day Color",
     group = GROUP_HTF
)

color previousWeekColor = input.color(
     color.rgb(126, 87, 194),
     "Previous-Week Color",
     group = GROUP_HTF
)

color previousMonthColor = input.color(
     color.rgb(255, 64, 129),
     "Previous-Month Color",
     group = GROUP_HTF
)


//=====================================================================
// ASIAN SESSION SETTINGS
//=====================================================================

bool showAsianRange = input.bool(
     true,
     "Show Asian High and Low",
     group = GROUP_ASIA
)

string asianSession = input.session(
     "1800-0000",
     "Asian Session",
     group = GROUP_ASIA,
     tooltip = "Default: 6:00 PM through midnight New York time."
)

color asianHighColor = input.color(
     color.rgb(0, 188, 212),
     "Asian High",
     group = GROUP_ASIA
)

color asianLowColor = input.color(
     color.rgb(0, 105, 148),
     "Asian Low",
     group = GROUP_ASIA
)


//=====================================================================
// SWING SETTINGS
//=====================================================================

bool showOneHourSwings = input.bool(
     true,
     "Show Confirmed 1H Swings",
     group = GROUP_SWINGS
)

int oneHourPivotLength = input.int(
     3,
     "1H Pivot Strength",
     minval = 1,
     maxval = 20,
     group = GROUP_SWINGS
)

color oneHourSwingHighColor = input.color(
     color.rgb(0, 230, 118),
     "1H Swing High",
     group = GROUP_SWINGS
)

color oneHourSwingLowColor = input.color(
     color.rgb(0, 150, 136),
     "1H Swing Low",
     group = GROUP_SWINGS
)


//=====================================================================
// MARKET-STRUCTURE SETTINGS
//=====================================================================

bool showStructure = input.bool(
     true,
     "Show BOS and MSS",
     group = GROUP_STRUCTURE
)

int structurePivotLength = input.int(
     3,
     "Structure Pivot Strength",
     minval = 1,
     maxval = 20,
     group = GROUP_STRUCTURE
)

bool requireCloseForStructure = input.bool(
     true,
     "Require Candle Close Through Structure",
     group = GROUP_STRUCTURE
)

bool showStructureLevels = input.bool(
     false,
     "Plot Active Structure High and Low",
     group = GROUP_STRUCTURE
)

color bullishStructureColor = input.color(
     color.rgb(0, 200, 83),
     "Bullish BOS / MSS",
     group = GROUP_STRUCTURE
)

color bearishStructureColor = input.color(
     color.rgb(255, 23, 68),
     "Bearish BOS / MSS",
     group = GROUP_STRUCTURE
)


//=====================================================================
// REJECTION AND SWEEP SETTINGS
//=====================================================================

bool showRejections = input.bool(
     true,
     "Show Clean Rejections",
     group = GROUP_REJECTION
)

bool showSweeps = input.bool(
     true,
     "Show Liquidity Sweeps",
     group = GROUP_REJECTION
)

float minimumWickPercent = input.float(
     25.0,
     "Minimum Rejection Wick %",
     minval = 0.0,
     maxval = 100.0,
     step = 5.0,
     group = GROUP_REJECTION
)

bool requireDirectionalClose = input.bool(
     true,
     "Require Directional Rejection Candle",
     group = GROUP_REJECTION
)

color bullishRejectionColor = input.color(
     color.rgb(0, 230, 118),
     "Bullish Rejection",
     group = GROUP_REJECTION
)

color bearishRejectionColor = input.color(
     color.rgb(255, 23, 68),
     "Bearish Rejection",
     group = GROUP_REJECTION
)

color bullishSweepColor = input.color(
     color.rgb(41, 121, 255),
     "Bullish Sweep",
     group = GROUP_REJECTION
)

color bearishSweepColor = input.color(
     color.rgb(255, 152, 0),
     "Bearish Sweep",
     group = GROUP_REJECTION
)


//=====================================================================
// FAIR VALUE GAP SETTINGS
//=====================================================================

bool showFVGs = input.bool(
     true,
     "Show Fair Value Gaps",
     group = GROUP_FVG
)

bool requireDisplacementFVG = input.bool(
     false,
     "Require Displacement Candle",
     group = GROUP_FVG
)

float displacementMultiplier = input.float(
     1.25,
     "Displacement Range Multiplier",
     minval = 0.5,
     maxval = 5.0,
     step = 0.05,
     group = GROUP_FVG
)

int displacementAverageLength = input.int(
     20,
     "Average Range Length",
     minval = 2,
     maxval = 100,
     group = GROUP_FVG
)

bool deleteFilledFVGs = input.bool(
     true,
     "Remove Fully Filled FVGs",
     group = GROUP_FVG
)

int maximumFVGs = input.int(
     30,
     "Maximum FVGs",
     minval = 1,
     maxval = 100,
     group = GROUP_FVG
)

color bullishFVGColor = input.color(
     color.new(color.rgb(0, 200, 150), 82),
     "Bullish FVG",
     group = GROUP_FVG
)

color bearishFVGColor = input.color(
     color.new(color.rgb(255, 82, 82), 82),
     "Bearish FVG",
     group = GROUP_FVG
)


//=====================================================================
// ORDER BLOCK / MITIGATION SETTINGS
//=====================================================================

bool showOrderBlocks = input.bool(
     true,
     "Show Order Block / Mitigation Zones",
     group = GROUP_OB
)

int oppositeCandleLookback = input.int(
     12,
     "Last Opposite Candle Lookback",
     minval = 1,
     maxval = 50,
     group = GROUP_OB
)

string orderBlockRangeInput = input.string(
     "Full Candle",
     "Zone Range",
     options = ["Full Candle", "Body to Wick"],
     group = GROUP_OB
)

bool deleteInvalidOrderBlocks = input.bool(
     false,
     "Remove Invalidated Zones",
     group = GROUP_OB
)

int maximumOrderBlocks = input.int(
     20,
     "Maximum OB / Mitigation Zones",
     minval = 1,
     maxval = 50,
     group = GROUP_OB
)

color bullishOBColor = input.color(
     color.new(color.rgb(0, 230, 118), 84),
     "Bullish OB / Mitigation",
     group = GROUP_OB
)

color bearishOBColor = input.color(
     color.new(color.rgb(255, 23, 68), 84),
     "Bearish OB / Mitigation",
     group = GROUP_OB
)


//=====================================================================
// HELPER FUNCTIONS
//=====================================================================

levelLabelText(string levelName, float levelPrice) =>
    showPricesInLabels
         ? levelName + " " + str.tostring(levelPrice, format.mintick)
         : levelName


lastBearishCandle(int searchLength) =>
    int result = na

    for candleOffset = 1 to searchLength
        if na(result) and close[candleOffset] < open[candleOffset]
            result := candleOffset

    result


lastBullishCandle(int searchLength) =>
    int result = na

    for candleOffset = 1 to searchLength
        if na(result) and close[candleOffset] > open[candleOffset]
            result := candleOffset

    result


//=====================================================================
// M/W/F STORAGE
//=====================================================================

var mwfLines = array.new_line()
var mwfLabels = array.new_label()
var mwfPrices = array.new_float()

int maximumMWFObjects = weeksBack * 6

bool newTradingDay = timeframe.change("D")

// Separate requests are used to avoid tuple-formatting errors.
float previousDailyHigh = request.security(
     syminfo.tickerid,
     "D",
     high[1],
     lookahead = barmerge.lookahead_on
)

float previousDailyLow = request.security(
     syminfo.tickerid,
     "D",
     low[1],
     lookahead = barmerge.lookahead_on
)

int previousDailyDay = request.security(
     syminfo.tickerid,
     "D",
     dayofweek[1],
     lookahead = barmerge.lookahead_on
)

int previousDailyTime = request.security(
     syminfo.tickerid,
     "D",
     time[1],
     lookahead = barmerge.lookahead_on
)


//=====================================================================
// CREATE MONDAY LEVELS
//=====================================================================

if newTradingDay and showMonday and previousDailyDay == dayofweek.monday
    line mondayHighLine = line.new(
         x1 = previousDailyTime,
         y1 = previousDailyHigh,
         x2 = previousDailyTime + 60000,
         y2 = previousDailyHigh,
         xloc = xloc.bar_time,
         extend = extend.right,
         color = mondayHighColor,
         style = keyLevelStyle,
         width = keyLevelWidth
    )

    line mondayLowLine = line.new(
         x1 = previousDailyTime,
         y1 = previousDailyLow,
         x2 = previousDailyTime + 60000,
         y2 = previousDailyLow,
         xloc = xloc.bar_time,
         extend = extend.right,
         color = mondayLowColor,
         style = keyLevelStyle,
         width = keyLevelWidth
    )

    array.push(mwfLines, mondayHighLine)
    array.push(mwfLines, mondayLowLine)
    array.push(mwfPrices, previousDailyHigh)
    array.push(mwfPrices, previousDailyLow)

    if showLevelLabels
        label mondayHighLabel = label.new(
             x = previousDailyTime,
             y = previousDailyHigh,
             xloc = xloc.bar_time,
             text = levelLabelText("MON HIGH", previousDailyHigh),
             style = label.style_label_right,
             color = color.new(color.black, 70),
             textcolor = mondayHighColor,
             size = size.tiny
        )

        label mondayLowLabel = label.new(
             x = previousDailyTime,
             y = previousDailyLow,
             xloc = xloc.bar_time,
             text = levelLabelText("MON LOW", previousDailyLow),
             style = label.style_label_right,
             color = color.new(color.black, 70),
             textcolor = mondayLowColor,
             size = size.tiny
        )

        array.push(mwfLabels, mondayHighLabel)
        array.push(mwfLabels, mondayLowLabel)


//=====================================================================
// CREATE WEDNESDAY LEVELS
//=====================================================================

if newTradingDay and showWednesday and previousDailyDay == dayofweek.wednesday
    line wednesdayHighLine = line.new(
         x1 = previousDailyTime,
         y1 = previousDailyHigh,
         x2 = previousDailyTime + 60000,
         y2 = previousDailyHigh,
         xloc = xloc.bar_time,
         extend = extend.right,
         color = wednesdayHighColor,
         style = keyLevelStyle,
         width = keyLevelWidth
    )

    line wednesdayLowLine = line.new(
         x1 = previousDailyTime,
         y1 = previousDailyLow,
         x2 = previousDailyTime + 60000,
         y2 = previousDailyLow,
         xloc = xloc.bar_time,
         extend = extend.right,
         color = wednesdayLowColor,
         style = keyLevelStyle,
         width = keyLevelWidth
    )

    array.push(mwfLines, wednesdayHighLine)
    array.push(mwfLines, wednesdayLowLine)
    array.push(mwfPrices, previousDailyHigh)
    array.push(mwfPrices, previousDailyLow)

    if showLevelLabels
        label wednesdayHighLabel = label.new(
             x = previousDailyTime,
             y = previousDailyHigh,
             xloc = xloc.bar_time,
             text = levelLabelText("WED HIGH", previousDailyHigh),
             style = label.style_label_right,
             color = color.new(color.black, 70),
             textcolor = wednesdayHighColor,
             size = size.tiny
        )

        label wednesdayLowLabel = label.new(
             x = previousDailyTime,
             y = previousDailyLow,
             xloc = xloc.bar_time,
             text = levelLabelText("WED LOW", previousDailyLow),
             style = label.style_label_right,
             color = color.new(color.black, 70),
             textcolor = wednesdayLowColor,
             size = size.tiny
        )

        array.push(mwfLabels, wednesdayHighLabel)
        array.push(mwfLabels, wednesdayLowLabel)


//=====================================================================
// CREATE FRIDAY LEVELS
//=====================================================================

if newTradingDay and showFriday and previousDailyDay == dayofweek.friday
    line fridayHighLine = line.new(
         x1 = previousDailyTime,
         y1 = previousDailyHigh,
         x2 = previousDailyTime + 60000,
         y2 = previousDailyHigh,
         xloc = xloc.bar_time,
         extend = extend.right,
         color = fridayHighColor,
         style = keyLevelStyle,
         width = keyLevelWidth
    )

    line fridayLowLine = line.new(
         x1 = previousDailyTime,
         y1 = previousDailyLow,
         x2 = previousDailyTime + 60000,
         y2 = previousDailyLow,
         xloc = xloc.bar_time,
         extend = extend.right,
         color = fridayLowColor,
         style = keyLevelStyle,
         width = keyLevelWidth
    )

    array.push(mwfLines, fridayHighLine)
    array.push(mwfLines, fridayLowLine)
    array.push(mwfPrices, previousDailyHigh)
    array.push(mwfPrices, previousDailyLow)

    if showLevelLabels
        label fridayHighLabel = label.new(
             x = previousDailyTime,
             y = previousDailyHigh,
             xloc = xloc.bar_time,
             text = levelLabelText("FRI HIGH", previousDailyHigh),
             style = label.style_label_right,
             color = color.new(color.black, 70),
             textcolor = fridayHighColor,
             size = size.tiny
        )

        label fridayLowLabel = label.new(
             x = previousDailyTime,
             y = previousDailyLow,
             xloc = xloc.bar_time,
             text = levelLabelText("FRI LOW", previousDailyLow),
             style = label.style_label_right,
             color = color.new(color.black, 70),
             textcolor = fridayLowColor,
             size = size.tiny
        )

        array.push(mwfLabels, fridayHighLabel)
        array.push(mwfLabels, fridayLowLabel)


//=====================================================================
// CONTROL M/W/F OBJECT COUNT
//=====================================================================

while array.size(mwfLines) > maximumMWFObjects
    line oldestMWFLine = array.shift(mwfLines)
    line.delete(oldestMWFLine)

while array.size(mwfPrices) > maximumMWFObjects
    array.shift(mwfPrices)

while array.size(mwfLabels) > maximumMWFObjects
    label oldestMWFLabel = array.shift(mwfLabels)
    label.delete(oldestMWFLabel)


//=====================================================================
// PREVIOUS DAY / WEEK / MONTH
//=====================================================================

float previousDayHigh = request.security(
     syminfo.tickerid,
     "D",
     high[1],
     lookahead = barmerge.lookahead_on
)

float previousDayLow = request.security(
     syminfo.tickerid,
     "D",
     low[1],
     lookahead = barmerge.lookahead_on
)

float previousWeekHigh = request.security(
     syminfo.tickerid,
     "W",
     high[1],
     lookahead = barmerge.lookahead_on
)

float previousWeekLow = request.security(
     syminfo.tickerid,
     "W",
     low[1],
     lookahead = barmerge.lookahead_on
)

float previousMonthHigh = request.security(
     syminfo.tickerid,
     "M",
     high[1],
     lookahead = barmerge.lookahead_on
)

float previousMonthLow = request.security(
     syminfo.tickerid,
     "M",
     low[1],
     lookahead = barmerge.lookahead_on
)

plot(
     showPreviousDay ? previousDayHigh : na,
     title = "Previous Day High",
     color = previousDayColor,
     linewidth = keyLevelWidth,
     style = plot.style_stepline
)

plot(
     showPreviousDay ? previousDayLow : na,
     title = "Previous Day Low",
     color = previousDayColor,
     linewidth = keyLevelWidth,
     style = plot.style_stepline
)

plot(
     showPreviousWeek ? previousWeekHigh : na,
     title = "Previous Week High",
     color = previousWeekColor,
     linewidth = keyLevelWidth + 1,
     style = plot.style_stepline
)

plot(
     showPreviousWeek ? previousWeekLow : na,
     title = "Previous Week Low",
     color = previousWeekColor,
     linewidth = keyLevelWidth + 1,
     style = plot.style_stepline
)

plot(
     showPreviousMonth ? previousMonthHigh : na,
     title = "Previous Month High",
     color = previousMonthColor,
     linewidth = keyLevelWidth + 1,
     style = plot.style_stepline
)

plot(
     showPreviousMonth ? previousMonthLow : na,
     title = "Previous Month Low",
     color = previousMonthColor,
     linewidth = keyLevelWidth + 1,
     style = plot.style_stepline
)


//=====================================================================
// ASIAN SESSION HIGH / LOW
//=====================================================================

bool insideAsianSession = not na(
     time(
          timeframe.period,
          asianSession,
          analysisTimezone
     )
)

bool asianSessionStarted =
     insideAsianSession and not insideAsianSession[1]

bool asianSessionEnded =
     not insideAsianSession and insideAsianSession[1]

var float currentAsianHigh = na
var float currentAsianLow = na
var float completedAsianHigh = na
var float completedAsianLow = na

if asianSessionStarted
    currentAsianHigh := high
    currentAsianLow := low

if insideAsianSession and not asianSessionStarted
    currentAsianHigh := math.max(nz(currentAsianHigh, high), high)
    currentAsianLow := math.min(nz(currentAsianLow, low), low)

if asianSessionEnded
    completedAsianHigh := currentAsianHigh
    completedAsianLow := currentAsianLow

float displayedAsianHigh =
     insideAsianSession ? currentAsianHigh : completedAsianHigh

float displayedAsianLow =
     insideAsianSession ? currentAsianLow : completedAsianLow

plot(
     showAsianRange ? displayedAsianHigh : na,
     title = "Asian High",
     color = asianHighColor,
     linewidth = keyLevelWidth,
     style = plot.style_linebr
)

plot(
     showAsianRange ? displayedAsianLow : na,
     title = "Asian Low",
     color = asianLowColor,
     linewidth = keyLevelWidth,
     style = plot.style_linebr
)


//=====================================================================
// CONFIRMED 1-HOUR SWING LEVELS
//=====================================================================

float oneHourPivotHigh = request.security(
     syminfo.tickerid,
     "60",
     ta.pivothigh(high, oneHourPivotLength, oneHourPivotLength),
     lookahead = barmerge.lookahead_off
)

float oneHourPivotLow = request.security(
     syminfo.tickerid,
     "60",
     ta.pivotlow(low, oneHourPivotLength, oneHourPivotLength),
     lookahead = barmerge.lookahead_off
)

var float latestOneHourSwingHigh = na
var float latestOneHourSwingLow = na

if not na(oneHourPivotHigh)
    latestOneHourSwingHigh := oneHourPivotHigh

if not na(oneHourPivotLow)
    latestOneHourSwingLow := oneHourPivotLow

plot(
     showOneHourSwings ? latestOneHourSwingHigh : na,
     title = "Confirmed 1H Swing High",
     color = oneHourSwingHighColor,
     linewidth = keyLevelWidth,
     style = plot.style_stepline
)

plot(
     showOneHourSwings ? latestOneHourSwingLow : na,
     title = "Confirmed 1H Swing Low",
     color = oneHourSwingLowColor,
     linewidth = keyLevelWidth,
     style = plot.style_stepline
)


//=====================================================================
// CURRENT-TIMEFRAME MARKET STRUCTURE
//=====================================================================

float confirmedPivotHigh = ta.pivothigh(
     high,
     structurePivotLength,
     structurePivotLength
)

float confirmedPivotLow = ta.pivotlow(
     low,
     structurePivotLength,
     structurePivotLength
)

var float latestStructureHigh = na
var float latestStructureLow = na

if not na(confirmedPivotHigh)
    latestStructureHigh := confirmedPivotHigh

if not na(confirmedPivotLow)
    latestStructureLow := confirmedPivotLow

float bullishStructureSource =
     requireCloseForStructure ? close : high

float bearishStructureSource =
     requireCloseForStructure ? close : low

// Execute crossover functions on every bar.
bool crossedAboveStructure = ta.crossover(
     bullishStructureSource,
     latestStructureHigh
)

bool crossedBelowStructure = ta.crossunder(
     bearishStructureSource,
     latestStructureLow
)

bool bullishStructureBreak =
     showStructure and
     not na(latestStructureHigh) and
     crossedAboveStructure

bool bearishStructureBreak =
     showStructure and
     not na(latestStructureLow) and
     crossedBelowStructure

var int structureDirection = 0

bool bullishMSS =
     bullishStructureBreak and structureDirection == -1

bool bearishMSS =
     bearishStructureBreak and structureDirection == 1

bool bullishBOS =
     bullishStructureBreak and not bullishMSS

bool bearishBOS =
     bearishStructureBreak and not bearishMSS

if bullishStructureBreak
    string bullishStructureText =
         bullishMSS ? "BULLISH MSS" : "BULLISH BOS"

    label.new(
         x = bar_index,
         y = low,
         text = bullishStructureText,
         style = label.style_label_up,
         color = bullishStructureColor,
         textcolor = color.white,
         size = size.small
    )

    structureDirection := 1

if bearishStructureBreak
    string bearishStructureText =
         bearishMSS ? "BEARISH MSS" : "BEARISH BOS"

    label.new(
         x = bar_index,
         y = high,
         text = bearishStructureText,
         style = label.style_label_down,
         color = bearishStructureColor,
         textcolor = color.white,
         size = size.small
    )

    structureDirection := -1

plot(
     showStructureLevels ? latestStructureHigh : na,
     title = "Active Structure High",
     color = color.new(bearishStructureColor, 45),
     linewidth = 1,
     style = plot.style_stepline
)

plot(
     showStructureLevels ? latestStructureLow : na,
     title = "Active Structure Low",
     color = color.new(bullishStructureColor, 45),
     linewidth = 1,
     style = plot.style_stepline
)


//=====================================================================
// REJECTION AND SWEEP LOGIC
//=====================================================================

float candleRange = math.max(
     high - low,
     syminfo.mintick
)

float lowerWick = math.min(open, close) - low
float upperWick = high - math.max(open, close)

float lowerWickPercentage =
     lowerWick / candleRange * 100.0

float upperWickPercentage =
     upperWick / candleRange * 100.0

bool bullishDirectionValid =
     not requireDirectionalClose or close > open

bool bearishDirectionValid =
     not requireDirectionalClose or close < open

bullishRejectionAt(float level) =>
    (
        not na(level) and
        low <= level and
        close > level and
        lowerWickPercentage >= minimumWickPercent and
        bullishDirectionValid
    )

bearishRejectionAt(float level) =>
    (
        not na(level) and
        high >= level and
        close < level and
        upperWickPercentage >= minimumWickPercent and
        bearishDirectionValid
    )

bullishSweepAt(float level) =>
    (
        not na(level) and
        low < level and
        close > level
    )

bearishSweepAt(float level) =>
    (
        not na(level) and
        high > level and
        close < level
    )


//=====================================================================
// CHECK ALL STATIC LEVELS
//=====================================================================

bool bullishRejection = false
bool bearishRejection = false
bool bullishSweep = false
bool bearishSweep = false

bullishRejection := bullishRejection or bullishRejectionAt(previousDayHigh)
bullishRejection := bullishRejection or bullishRejectionAt(previousDayLow)
bullishRejection := bullishRejection or bullishRejectionAt(previousWeekHigh)
bullishRejection := bullishRejection or bullishRejectionAt(previousWeekLow)
bullishRejection := bullishRejection or bullishRejectionAt(previousMonthHigh)
bullishRejection := bullishRejection or bullishRejectionAt(previousMonthLow)
bullishRejection := bullishRejection or bullishRejectionAt(displayedAsianHigh)
bullishRejection := bullishRejection or bullishRejectionAt(displayedAsianLow)
bullishRejection := bullishRejection or bullishRejectionAt(latestOneHourSwingHigh)
bullishRejection := bullishRejection or bullishRejectionAt(latestOneHourSwingLow)

bearishRejection := bearishRejection or bearishRejectionAt(previousDayHigh)
bearishRejection := bearishRejection or bearishRejectionAt(previousDayLow)
bearishRejection := bearishRejection or bearishRejectionAt(previousWeekHigh)
bearishRejection := bearishRejection or bearishRejectionAt(previousWeekLow)
bearishRejection := bearishRejection or bearishRejectionAt(previousMonthHigh)
bearishRejection := bearishRejection or bearishRejectionAt(previousMonthLow)
bearishRejection := bearishRejection or bearishRejectionAt(displayedAsianHigh)
bearishRejection := bearishRejection or bearishRejectionAt(displayedAsianLow)
bearishRejection := bearishRejection or bearishRejectionAt(latestOneHourSwingHigh)
bearishRejection := bearishRejection or bearishRejectionAt(latestOneHourSwingLow)

bullishSweep := bullishSweep or bullishSweepAt(previousDayHigh)
bullishSweep := bullishSweep or bullishSweepAt(previousDayLow)
bullishSweep := bullishSweep or bullishSweepAt(previousWeekHigh)
bullishSweep := bullishSweep or bullishSweepAt(previousWeekLow)
bullishSweep := bullishSweep or bullishSweepAt(previousMonthHigh)
bullishSweep := bullishSweep or bullishSweepAt(previousMonthLow)
bullishSweep := bullishSweep or bullishSweepAt(displayedAsianHigh)
bullishSweep := bullishSweep or bullishSweepAt(displayedAsianLow)
bullishSweep := bullishSweep or bullishSweepAt(latestOneHourSwingHigh)
bullishSweep := bullishSweep or bullishSweepAt(latestOneHourSwingLow)

bearishSweep := bearishSweep or bearishSweepAt(previousDayHigh)
bearishSweep := bearishSweep or bearishSweepAt(previousDayLow)
bearishSweep := bearishSweep or bearishSweepAt(previousWeekHigh)
bearishSweep := bearishSweep or bearishSweepAt(previousWeekLow)
bearishSweep := bearishSweep or bearishSweepAt(previousMonthHigh)
bearishSweep := bearishSweep or bearishSweepAt(previousMonthLow)
bearishSweep := bearishSweep or bearishSweepAt(displayedAsianHigh)
bearishSweep := bearishSweep or bearishSweepAt(displayedAsianLow)
bearishSweep := bearishSweep or bearishSweepAt(latestOneHourSwingHigh)
bearishSweep := bearishSweep or bearishSweepAt(latestOneHourSwingLow)


//=====================================================================
// CHECK STORED M/W/F LEVELS
//=====================================================================

if array.size(mwfPrices) > 0
    for levelIndex = 0 to array.size(mwfPrices) - 1
        float mwfLevel = array.get(mwfPrices, levelIndex)

        if bullishRejectionAt(mwfLevel)
            bullishRejection := true

        if bearishRejectionAt(mwfLevel)
            bearishRejection := true

        if bullishSweepAt(mwfLevel)
            bullishSweep := true

        if bearishSweepAt(mwfLevel)
            bearishSweep := true


// Avoid showing both labels for the exact same event.
bool bullishCleanRejection =
     bullishRejection and not bullishSweep

bool bearishCleanRejection =
     bearishRejection and not bearishSweep

plotshape(
     showRejections and bullishCleanRejection,
     title = "Bullish Clean Rejection",
     style = shape.triangleup,
     location = location.belowbar,
     color = bullishRejectionColor,
     size = size.small,
     text = "REJ"
)

plotshape(
     showRejections and bearishCleanRejection,
     title = "Bearish Clean Rejection",
     style = shape.triangledown,
     location = location.abovebar,
     color = bearishRejectionColor,
     size = size.small,
     text = "REJ"
)

plotshape(
     showSweeps and bullishSweep,
     title = "Sell-Side Liquidity Sweep",
     style = shape.labelup,
     location = location.belowbar,
     color = bullishSweepColor,
     textcolor = color.white,
     size = size.tiny,
     text = "SSL SWEEP"
)

plotshape(
     showSweeps and bearishSweep,
     title = "Buy-Side Liquidity Sweep",
     style = shape.labeldown,
     location = location.abovebar,
     color = bearishSweepColor,
     textcolor = color.white,
     size = size.tiny,
     text = "BSL SWEEP"
)


//=====================================================================
// FAIR VALUE GAPS
//=====================================================================

float currentRange = high - low
float averageRange = ta.sma(
     high - low,
     displacementAverageLength
)

bool displacementValid =
     not requireDisplacementFVG or
     currentRange >= averageRange * displacementMultiplier

bool bullishFVGCreated =
     showFVGs and
     bar_index >= 2 and
     low > high[2] and
     displacementValid

bool bearishFVGCreated =
     showFVGs and
     bar_index >= 2 and
     high < low[2] and
     displacementValid

var fvgBoxes = array.new_box()
var fvgDirections = array.new_int()

if bullishFVGCreated
    box bullishFVGBox = box.new(
         left = bar_index - 2,
         top = low,
         right = bar_index,
         bottom = high[2],
         xloc = xloc.bar_index,
         extend = extend.right,
         bgcolor = bullishFVGColor,
         border_color = color.new(bullishFVGColor, 5),
         text = "BULLISH FVG",
         text_color = color.new(color.white, 20),
         text_size = size.tiny
    )

    array.push(fvgBoxes, bullishFVGBox)
    array.push(fvgDirections, 1)

if bearishFVGCreated
    box bearishFVGBox = box.new(
         left = bar_index - 2,
         top = low[2],
         right = bar_index,
         bottom = high,
         xloc = xloc.bar_index,
         extend = extend.right,
         bgcolor = bearishFVGColor,
         border_color = color.new(bearishFVGColor, 5),
         text = "BEARISH FVG",
         text_color = color.new(color.white, 20),
         text_size = size.tiny
    )

    array.push(fvgBoxes, bearishFVGBox)
    array.push(fvgDirections, -1)

while array.size(fvgBoxes) > maximumFVGs
    box oldestFVGBox = array.shift(fvgBoxes)
    box.delete(oldestFVGBox)
    array.shift(fvgDirections)

if deleteFilledFVGs and array.size(fvgBoxes) > 0
    int fvgIndex = array.size(fvgBoxes) - 1

    while fvgIndex >= 0
        box activeFVG = array.get(fvgBoxes, fvgIndex)
        int fvgDirection = array.get(fvgDirections, fvgIndex)

        float fvgTop = box.get_top(activeFVG)
        float fvgBottom = box.get_bottom(activeFVG)

        bool bullishFVGFilled =
             fvgDirection == 1 and low <= fvgBottom

        bool bearishFVGFilled =
             fvgDirection == -1 and high >= fvgTop

        if bullishFVGFilled or bearishFVGFilled
            box.delete(activeFVG)
            array.remove(fvgBoxes, fvgIndex)
            array.remove(fvgDirections, fvgIndex)

        fvgIndex -= 1


//=====================================================================
// ORDER BLOCKS / MITIGATION CANDLES
//=====================================================================

var orderBlockBoxes = array.new_box()
var orderBlockDirections = array.new_int()

if showOrderBlocks and bullishStructureBreak
    int bearishCandleOffset = lastBearishCandle(
         oppositeCandleLookback
    )

    if not na(bearishCandleOffset)
        float bullishZoneTop =
             orderBlockRangeInput == "Full Candle"
             ? high[bearishCandleOffset]
             : open[bearishCandleOffset]

        float bullishZoneBottom =
             low[bearishCandleOffset]

        box bullishOBBox = box.new(
             left = bar_index - bearishCandleOffset,
             top = bullishZoneTop,
             right = bar_index,
             bottom = bullishZoneBottom,
             xloc = xloc.bar_index,
             extend = extend.right,
             bgcolor = bullishOBColor,
             border_color = color.new(bullishOBColor, 5),
             text = "BULLISH OB / MITIGATION",
             text_color = color.new(color.white, 20),
             text_size = size.tiny
        )

        array.push(orderBlockBoxes, bullishOBBox)
        array.push(orderBlockDirections, 1)

if showOrderBlocks and bearishStructureBreak
    int bullishCandleOffset = lastBullishCandle(
         oppositeCandleLookback
    )

    if not na(bullishCandleOffset)
        float bearishZoneTop =
             high[bullishCandleOffset]

        float bearishZoneBottom =
             orderBlockRangeInput == "Full Candle"
             ? low[bullishCandleOffset]
             : open[bullishCandleOffset]

        box bearishOBBox = box.new(
             left = bar_index - bullishCandleOffset,
             top = bearishZoneTop,
             right = bar_index,
             bottom = bearishZoneBottom,
             xloc = xloc.bar_index,
             extend = extend.right,
             bgcolor = bearishOBColor,
             border_color = color.new(bearishOBColor, 5),
             text = "BEARISH OB / MITIGATION",
             text_color = color.new(color.white, 20),
             text_size = size.tiny
        )

        array.push(orderBlockBoxes, bearishOBBox)
        array.push(orderBlockDirections, -1)

while array.size(orderBlockBoxes) > maximumOrderBlocks
    box oldestOBBox = array.shift(orderBlockBoxes)
    box.delete(oldestOBBox)
    array.shift(orderBlockDirections)

if deleteInvalidOrderBlocks and array.size(orderBlockBoxes) > 0
    int obIndex = array.size(orderBlockBoxes) - 1

    while obIndex >= 0
        box activeOB = array.get(orderBlockBoxes, obIndex)
        int obDirection = array.get(orderBlockDirections, obIndex)

        float obTop = box.get_top(activeOB)
        float obBottom = box.get_bottom(activeOB)

        bool bullishOBInvalid =
             obDirection == 1 and close < obBottom

        bool bearishOBInvalid =
             obDirection == -1 and close > obTop

        if bullishOBInvalid or bearishOBInvalid
            box.delete(activeOB)
            array.remove(orderBlockBoxes, obIndex)
            array.remove(orderBlockDirections, obIndex)

        obIndex -= 1


//=====================================================================
// ALERT CONDITIONS
//=====================================================================

alertcondition(
     bullishCleanRejection,
     title = "CTMS Setup 1 Bullish Rejection",
     message = "Bullish clean rejection detected at a Cody & Tyler key level."
)

alertcondition(
     bearishCleanRejection,
     title = "CTMS Setup 1 Bearish Rejection",
     message = "Bearish clean rejection detected at a Cody & Tyler key level."
)

alertcondition(
     bullishSweep,
     title = "CTMS Sell-Side Liquidity Sweep",
     message = "Sell-side liquidity was swept and price closed back above a key level."
)

alertcondition(
     bearishSweep,
     title = "CTMS Buy-Side Liquidity Sweep",
     message = "Buy-side liquidity was swept and price closed back below a key level."
)

alertcondition(
     bullishMSS,
     title = "CTMS Bullish MSS",
     message = "Bullish market structure shift detected. Check for sweep, FVG, OB, mitigation, and breaker confirmation."
)

alertcondition(
     bearishMSS,
     title = "CTMS Bearish MSS",
     message = "Bearish market structure shift detected. Check for sweep, FVG, OB, mitigation, and breaker confirmation."
)

alertcondition(
     bullishBOS,
     title = "CTMS Bullish BOS",
     message = "Bullish break of structure detected."
)

alertcondition(
     bearishBOS,
     title = "CTMS Bearish BOS",
     message = "Bearish break of structure detected."
)

alertcondition(
     bullishFVGCreated,
     title = "CTMS Bullish FVG",
     message = "A new bullish fair value gap has formed."
)

alertcondition(
     bearishFVGCreated,
     title = "CTMS Bearish FVG",
     message = "A new bearish fair value gap has formed."
)
````
