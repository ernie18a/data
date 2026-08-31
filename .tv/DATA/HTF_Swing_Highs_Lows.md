<!-- tradingview-pine-id: PUB;be5815908d5e402ea2dce79cdb34d8e3 -->
<!-- tradingviewscripts-format: 1 -->
# HTF Swing Highs & Lows

Source: https://www.tradingview.com/script/LTbyNbc2-HTF-Swing-Highs-Lows/

## Description

An open-source multi-timeframe market structure indicator that automatically identifies and projects confirmed swing highs and swing lows from the Weekly, Daily, and 4-Hour timeframes onto any lower timeframe chart.

The indicator is designed to provide clean, non-repainting support and resistance levels based on confirmed market structure rather than developing pivots.

Features
   -  Weekly, Daily and 4H swing highs and lows
   -  Non-repainting confirmed pivots
   -  Automatic higher timeframe detection using request.security()
   -  Horizontal levels extended until invalidated
   -  Independent visibility controls for each timeframe
   -  Hierarchical timeframe filtering
   -  Custom colours and line widths for every timeframe
   -  Adjustable pivot strength
   -  Wick, Close or Never invalidation options
   -  Stop or Delete broken levels
   -  Automatic level management to prevent exceeding TradingView object limits

How it works
The script uses confirmed pivot highs and lows from higher timeframes.

Unlike developing pivots, a swing is only confirmed after the selected number of candles has formed on both sides of the pivot. Once confirmed, a horizontal level is created at the swing price and extended to the right.

Because only confirmed pivots are used, historical levels do not repaint.

Pivot Strength
Pivot Strength controls how significant a swing must be before it becomes a level.

A strength of 3 means the pivot candle must have:
   -  three lower highs (or higher lows) before it
   -  three lower highs (or higher lows) after it

Higher values filter market noise and identify more significant market structure. 
They also produce fewer levels and require longer confirmation.

Lower values detect smaller swings, produce more levels, react faster.

Level Invalidation
Choose how a level is treated once price trades through it.

Wick  -  Invalidates when price wicks beyond the level.
Close  -  Invalidates only after a candle closes beyond the level.
Never  -  Levels remain permanently.

Broken levels can either:
   -  Stop extending while remaining visible
   -  Be deleted completely

Hierarchical Visibility
The indicator can automatically display only relevant higher timeframe levels.

For example:
   -  Weekly levels appear on Weekly and all lower timeframes.
   -  Daily levels appear on Daily and all lower timeframes.
   -  4H levels appear on 4H and lower charts.
This helps reduce clutter when analysing higher timeframe charts.

Notes
   -  Uses confirmed higher timeframe pivots only.
   -  Levels are anchored to the original swing candle.
   -  Designed for support and resistance, market structure, liquidity analysis, and confluence with other tools.
   -  Works on all symbols and asset classes supported by TradingView.

---

## Source Code

````pine
//@version=6
indicator(
     "HTF Swing Highs & Lows",
     overlay = true,
     max_lines_count = 500)

//=============================================================================
// Inputs
//=============================================================================

string GROUP_SWINGS = "Swing Detection"

int weeklyStrength = input.int(
     2,
     "Weekly pivot strength",
     minval = 1,
     group = GROUP_SWINGS)

int dailyStrength = input.int(
     3,
     "Daily pivot strength",
     minval = 1,
     group = GROUP_SWINGS)

int fourHourStrength = input.int(
     4,
     "4H pivot strength",
     minval = 1,
     group = GROUP_SWINGS)

string GROUP_VISIBILITY = "Visibility"

bool showWeekly = input.bool(
     true,
     "Show weekly levels",
     group = GROUP_VISIBILITY)

bool showDaily = input.bool(
     true,
     "Show daily levels",
     group = GROUP_VISIBILITY)

bool showFourHour = input.bool(
     true,
     "Show 4H levels",
     group = GROUP_VISIBILITY)

bool hierarchicalVisibility = input.bool(
     true,
     "Show only on equal or lower chart timeframes",
     tooltip = "Weekly levels display on weekly and lower charts. Daily levels display on daily and lower charts. 4H levels display on 4H and lower charts.",
     group = GROUP_VISIBILITY)

string GROUP_MANAGEMENT = "Level Management"

string breakMethod = input.string(
     "Wick",
     "Invalidation method",
     options = ["Wick", "Close", "Never"],
     group = GROUP_MANAGEMENT)

string breakAction = input.string(
     "Stop",
     "When invalidated",
     options = ["Stop", "Delete"],
     group = GROUP_MANAGEMENT)

int maximumLevelsPerSet = input.int(
     25,
     "Maximum levels per timeframe and direction",
     minval = 1,
     maxval = 75,
     group = GROUP_MANAGEMENT)

string GROUP_STYLE = "Style"

color weeklyHighColor = input.color(
     color.red,
     "Weekly swing highs",
     group = GROUP_STYLE)

color weeklyLowColor = input.color(
     color.lime,
     "Weekly swing lows",
     group = GROUP_STYLE)

color dailyHighColor = input.color(
     color.orange,
     "Daily swing highs",
     group = GROUP_STYLE)

color dailyLowColor = input.color(
     color.aqua,
     "Daily swing lows",
     group = GROUP_STYLE)

color fourHourHighColor = input.color(
     color.fuchsia,
     "4H swing highs",
     group = GROUP_STYLE)

color fourHourLowColor = input.color(
     color.blue,
     "4H swing lows",
     group = GROUP_STYLE)

int weeklyWidth = input.int(
     3,
     "Weekly line width",
     minval = 1,
     maxval = 5,
     group = GROUP_STYLE)

int dailyWidth = input.int(
     2,
     "Daily line width",
     minval = 1,
     maxval = 5,
     group = GROUP_STYLE)

int fourHourWidth = input.int(
     1,
     "4H line width",
     minval = 1,
     maxval = 5,
     group = GROUP_STYLE)

//=============================================================================
// Timeframe constants
//=============================================================================

string WEEKLY_TF = "1W"
string DAILY_TF = "1D"
string FOUR_HOUR_TF = "240"

//=============================================================================
// Pivot calculations
//=============================================================================

f_pivotHigh(int strength) =>
    ta.pivothigh(high, strength, strength)

f_pivotLow(int strength) =>
    ta.pivotlow(low, strength, strength)

f_pivotHighTime(int strength) =>
    float pivotValue = ta.pivothigh(high, strength, strength)
    int result = na

    if not na(pivotValue)
        result := time[strength]

    result

f_pivotLowTime(int strength) =>
    float pivotValue = ta.pivotlow(low, strength, strength)
    int result = na

    if not na(pivotValue)
        result := time[strength]

    result

//=============================================================================
// Visibility
//=============================================================================

f_isTimeframeVisible(string sourceTimeframe) =>
    float chartSeconds = timeframe.in_seconds(timeframe.period)
    float sourceSeconds = timeframe.in_seconds(sourceTimeframe)

    bool visible = true

    if hierarchicalVisibility
        visible := na(chartSeconds) or
             na(sourceSeconds) or
             chartSeconds <= sourceSeconds

    visible

//=============================================================================
// Invalidation
//=============================================================================

f_levelIsBroken(float levelPrice, bool isSwingHigh) =>
    bool result = false

    if breakMethod == "Wick"
        result := isSwingHigh
             ? high > levelPrice
             : low < levelPrice

    else if breakMethod == "Close"
        result := isSwingHigh
             ? close > levelPrice
             : close < levelPrice

    else
        result := false

    result

//=============================================================================
// Array and line management
//=============================================================================

f_removeOldest(
     array<line> lineArray,
     array<float> priceArray,
     array<bool> activeArray) =>

    bool removed = false

    if array.size(lineArray) > 0
        line oldestLine = array.shift(lineArray)

        array.shift(priceArray)
        array.shift(activeArray)

        line.delete(oldestLine)
        removed := true

    removed

f_limitCollection(
     array<line> lineArray,
     array<float> priceArray,
     array<bool> activeArray) =>

    bool trimmed = false

    while array.size(lineArray) > maximumLevelsPerSet
        f_removeOldest(
             lineArray,
             priceArray,
             activeArray)

        trimmed := true

    trimmed

f_addLevel(
     array<line> lineArray,
     array<float> priceArray,
     array<bool> activeArray,
     int swingTime,
     float swingPrice,
     color levelColor,
     int levelWidth,
     string levelStyle) =>

    line newLevel = line.new(
         x1 = swingTime,
         y1 = swingPrice,
         x2 = time,
         y2 = swingPrice,
         xloc = xloc.bar_time,
         extend = extend.right,
         color = levelColor,
         style = levelStyle,
         width = levelWidth)

    array.push(lineArray, newLevel)
    array.push(priceArray, swingPrice)
    array.push(activeArray, true)

    f_limitCollection(
         lineArray,
         priceArray,
         activeArray)

    true

f_manageLevels(
     array<line> lineArray,
     array<float> priceArray,
     array<bool> activeArray,
     bool isSwingHigh) =>

    bool changed = false
    int numberOfLevels = array.size(lineArray)

    if numberOfLevels > 0
        for index = numberOfLevels - 1 to 0
            bool levelIsActive = array.get(
                 activeArray,
                 index)

            if levelIsActive
                float levelPrice = array.get(
                     priceArray,
                     index)

                bool levelBroken = f_levelIsBroken(
                     levelPrice,
                     isSwingHigh)

                if levelBroken
                    line levelLine = array.get(
                         lineArray,
                         index)

                    if breakAction == "Delete"
                        line.delete(levelLine)

                        array.remove(
                             lineArray,
                             index)

                        array.remove(
                             priceArray,
                             index)

                        array.remove(
                             activeArray,
                             index)

                        changed := true

                    else
                        line.set_extend(
                             levelLine,
                             extend.none)

                        line.set_x2(
                             levelLine,
                             time)

                        array.set(
                             activeArray,
                             index,
                             false)

                        changed := true

    changed

//=============================================================================
// Persistent arrays
//=============================================================================

// Weekly highs
var array<line> weeklyHighLines = array.new<line>()
var array<float> weeklyHighPrices = array.new<float>()
var array<bool> weeklyHighActive = array.new<bool>()

// Weekly lows
var array<line> weeklyLowLines = array.new<line>()
var array<float> weeklyLowPrices = array.new<float>()
var array<bool> weeklyLowActive = array.new<bool>()

// Daily highs
var array<line> dailyHighLines = array.new<line>()
var array<float> dailyHighPrices = array.new<float>()
var array<bool> dailyHighActive = array.new<bool>()

// Daily lows
var array<line> dailyLowLines = array.new<line>()
var array<float> dailyLowPrices = array.new<float>()
var array<bool> dailyLowActive = array.new<bool>()

// 4H highs
var array<line> fourHourHighLines = array.new<line>()
var array<float> fourHourHighPrices = array.new<float>()
var array<bool> fourHourHighActive = array.new<bool>()

// 4H lows
var array<line> fourHourLowLines = array.new<line>()
var array<float> fourHourLowPrices = array.new<float>()
var array<bool> fourHourLowActive = array.new<bool>()

//=============================================================================
// Weekly data
//=============================================================================

float weeklyPivotHigh = request.security(
     syminfo.tickerid,
     WEEKLY_TF,
     f_pivotHigh(weeklyStrength),
     gaps = barmerge.gaps_on,
     lookahead = barmerge.lookahead_off)

int weeklyPivotHighTime = request.security(
     syminfo.tickerid,
     WEEKLY_TF,
     f_pivotHighTime(weeklyStrength),
     gaps = barmerge.gaps_on,
     lookahead = barmerge.lookahead_off)

float weeklyPivotLow = request.security(
     syminfo.tickerid,
     WEEKLY_TF,
     f_pivotLow(weeklyStrength),
     gaps = barmerge.gaps_on,
     lookahead = barmerge.lookahead_off)

int weeklyPivotLowTime = request.security(
     syminfo.tickerid,
     WEEKLY_TF,
     f_pivotLowTime(weeklyStrength),
     gaps = barmerge.gaps_on,
     lookahead = barmerge.lookahead_off)

//=============================================================================
// Daily data
//=============================================================================

float dailyPivotHigh = request.security(
     syminfo.tickerid,
     DAILY_TF,
     f_pivotHigh(dailyStrength),
     gaps = barmerge.gaps_on,
     lookahead = barmerge.lookahead_off)

int dailyPivotHighTime = request.security(
     syminfo.tickerid,
     DAILY_TF,
     f_pivotHighTime(dailyStrength),
     gaps = barmerge.gaps_on,
     lookahead = barmerge.lookahead_off)

float dailyPivotLow = request.security(
     syminfo.tickerid,
     DAILY_TF,
     f_pivotLow(dailyStrength),
     gaps = barmerge.gaps_on,
     lookahead = barmerge.lookahead_off)

int dailyPivotLowTime = request.security(
     syminfo.tickerid,
     DAILY_TF,
     f_pivotLowTime(dailyStrength),
     gaps = barmerge.gaps_on,
     lookahead = barmerge.lookahead_off)

//=============================================================================
// 4H data
//=============================================================================

float fourHourPivotHigh = request.security(
     syminfo.tickerid,
     FOUR_HOUR_TF,
     f_pivotHigh(fourHourStrength),
     gaps = barmerge.gaps_on,
     lookahead = barmerge.lookahead_off)

int fourHourPivotHighTime = request.security(
     syminfo.tickerid,
     FOUR_HOUR_TF,
     f_pivotHighTime(fourHourStrength),
     gaps = barmerge.gaps_on,
     lookahead = barmerge.lookahead_off)

float fourHourPivotLow = request.security(
     syminfo.tickerid,
     FOUR_HOUR_TF,
     f_pivotLow(fourHourStrength),
     gaps = barmerge.gaps_on,
     lookahead = barmerge.lookahead_off)

int fourHourPivotLowTime = request.security(
     syminfo.tickerid,
     FOUR_HOUR_TF,
     f_pivotLowTime(fourHourStrength),
     gaps = barmerge.gaps_on,
     lookahead = barmerge.lookahead_off)

//=============================================================================
// Visibility states
//=============================================================================

bool weeklyVisible =
     showWeekly and
     f_isTimeframeVisible(WEEKLY_TF)

bool dailyVisible =
     showDaily and
     f_isTimeframeVisible(DAILY_TF)

bool fourHourVisible =
     showFourHour and
     f_isTimeframeVisible(FOUR_HOUR_TF)

//=============================================================================
// Add weekly levels
//=============================================================================

if weeklyVisible
    if not na(weeklyPivotHigh) and not na(weeklyPivotHighTime)
        f_addLevel(
             weeklyHighLines,
             weeklyHighPrices,
             weeklyHighActive,
             weeklyPivotHighTime,
             weeklyPivotHigh,
             weeklyHighColor,
             weeklyWidth,
             line.style_solid)

    if not na(weeklyPivotLow) and not na(weeklyPivotLowTime)
        f_addLevel(
             weeklyLowLines,
             weeklyLowPrices,
             weeklyLowActive,
             weeklyPivotLowTime,
             weeklyPivotLow,
             weeklyLowColor,
             weeklyWidth,
             line.style_solid)

//=============================================================================
// Add daily levels
//=============================================================================

if dailyVisible
    if not na(dailyPivotHigh) and not na(dailyPivotHighTime)
        f_addLevel(
             dailyHighLines,
             dailyHighPrices,
             dailyHighActive,
             dailyPivotHighTime,
             dailyPivotHigh,
             dailyHighColor,
             dailyWidth,
             line.style_dashed)

    if not na(dailyPivotLow) and not na(dailyPivotLowTime)
        f_addLevel(
             dailyLowLines,
             dailyLowPrices,
             dailyLowActive,
             dailyPivotLowTime,
             dailyPivotLow,
             dailyLowColor,
             dailyWidth,
             line.style_dashed)

//=============================================================================
// Add 4H levels
//=============================================================================

if fourHourVisible
    if not na(fourHourPivotHigh) and not na(fourHourPivotHighTime)
        f_addLevel(
             fourHourHighLines,
             fourHourHighPrices,
             fourHourHighActive,
             fourHourPivotHighTime,
             fourHourPivotHigh,
             fourHourHighColor,
             fourHourWidth,
             line.style_dotted)

    if not na(fourHourPivotLow) and not na(fourHourPivotLowTime)
        f_addLevel(
             fourHourLowLines,
             fourHourLowPrices,
             fourHourLowActive,
             fourHourPivotLowTime,
             fourHourPivotLow,
             fourHourLowColor,
             fourHourWidth,
             line.style_dotted)

//=============================================================================
// Manage active levels
//=============================================================================

if weeklyVisible
    f_manageLevels(
         weeklyHighLines,
         weeklyHighPrices,
         weeklyHighActive,
         true)

    f_manageLevels(
         weeklyLowLines,
         weeklyLowPrices,
         weeklyLowActive,
         false)

if dailyVisible
    f_manageLevels(
         dailyHighLines,
         dailyHighPrices,
         dailyHighActive,
         true)

    f_manageLevels(
         dailyLowLines,
         dailyLowPrices,
         dailyLowActive,
         false)

if fourHourVisible
    f_manageLevels(
         fourHourHighLines,
         fourHourHighPrices,
         fourHourHighActive,
         true)

    f_manageLevels(
         fourHourLowLines,
         fourHourLowPrices,
         fourHourLowActive,
         false)
````
