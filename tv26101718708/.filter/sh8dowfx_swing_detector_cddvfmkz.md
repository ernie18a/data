# sh8dowFX Swing Detector

- url: https://www.tradingview.com/script/cddvfMKZ-sh8dowFX-Swing-Detector/
- type: indicator
- pine_id: PUB;714e6f06a5ee48bb9376a36f8c4f1e7b
- version: 1.0

## Description

sh8dowFX Fib Swing Detector is a multi-timeframe market structure tool designed to automatically identify relevant swing points and map their position within a standardized Fibonacci-based dealing range.
The indicator provides a clean visual framework for evaluating where price is trading relative to established higher-timeframe swings, helping traders quickly distinguish between premium, equilibrium, and discount areas without manually redrawing Fibonacci ranges as market structure develops.
Features
- Automatic detection of relevant swing highs and swing lows
- Fibonacci-based dealing range visualization
- Automatic orientation based on the detected swing structure
- Optional swing-point symbols for quick visual reference
- Higher-timeframe information directly on the active chart
- Selectable reference timeframes:
  - Daily
  - 4H
  - 1H
  - 15m
- Designed for multi-timeframe analysis without unnecessarily cluttering the chart
- Automatically updates as new qualifying market structure develops
Higher-Timeframe Context
The detector can display swing information from selected higher timeframes while working on a lower-timeframe execution chart.
This makes it possible to maintain awareness of the broader dealing range without constantly switching between charts.
The Show Swing Symbols option controls the visual marking of detected swings, while Show HTF Information provides additional context regarding the active higher-timeframe structure.
Intended Use
The Fib Swing Detector is designed as a market-context and dealing-range tool, rather than a standalone entry system.
It can help traders evaluate:
Premium / Discount positioning • Equilibrium • Higher-timeframe context • Swing structure • Potential reaction areas • Price delivery within a defined range
The indicator does not generate buy or sell signals. Its purpose is to automate repetitive structural chart work while leaving directional bias, narrative, and execution decisions to the trader.
For educational and analytical purposes only. Not financial advice.

## Source Code

````pine
//@version=6
indicator(
     "sh8dowFX Fib Detector",
     overlay = true,
     max_lines_count = 200,
     max_labels_count = 150
)

// =====================================================
// HARD-CODED COLORS
// =====================================================

color anchorColor = #2962ff
color equilibriumColor = #f23645
color internalColor = #808080
color extensionColor = #e040fb

color bullishColor = #089981
color bearishColor = #f23645

color dailyTriangleColor = #089981
color fourHourTriangleColor = #ff9800
color oneHourTriangleColor = #2962ff
color fifteenMinuteTriangleColor = #19191a

color informationTextColor = #19191a
color transparentColor = color.new(color.white, 100)

// =====================================================
// INPUTS
// =====================================================

// -----------------------------
// DISPLAY
// -----------------------------
groupDisplay = "DISPLAY"

showSwingSymbols = input.bool(
     true,
     "Show Swing Symbols",
     group = groupDisplay
)

showHtfInformation = input.bool(
     true,
     "Show HTF Information",
     group = groupDisplay
)

// -----------------------------
// TIMEFRAMES
// -----------------------------
groupTimeframes = "TIMEFRAMES"

showDaily = input.bool(
     false,
     "Daily",
     group = groupTimeframes
)

show4H = input.bool(
     true,
     "4H",
     group = groupTimeframes
)

show1H = input.bool(
     false,
     "1H",
     group = groupTimeframes
)

show15m = input.bool(
     true,
     "15m",
     group = groupTimeframes
)

// -----------------------------
// SWING DETECTION
// -----------------------------
groupSwing = "SWING DETECTION"

swingLeftBars = input.int(
     2,
     "Swing Left Bars",
     minval = 1,
     maxval = 20,
     group = groupSwing
)

swingRightBars = input.int(
     2,
     "Swing Right Bars",
     minval = 1,
     maxval = 20,
     group = groupSwing
)

// -----------------------------
// EXTENSIONS
// -----------------------------
groupExtensions = "EXTENSIONS"

extensionMode = input.string(
     "Both",
     "Extension Mode",
     options = ["Off", "Standard", "Symmetric", "Both"],
     group = groupExtensions
)

// -----------------------------
// LABELS
// -----------------------------
groupLabels = "LABELS"

labelOffset = input.int(
     15,
     "Right Label Offset",
     minval = 1,
     maxval = 100,
     group = groupLabels
)

labelSizeInput = input.string(
     "Small",
     "Label Size",
     options = ["Tiny", "Small", "Normal"],
     group = groupLabels
)

// -----------------------------
// STYLE
// -----------------------------
groupStyle = "STYLE"

lineOpacity = input.int(
     50,
     "Line Opacity",
     minval = 0,
     maxval = 100,
     group = groupStyle
)

labelOpacity = input.int(
     50,
     "Label Opacity",
     minval = 0,
     maxval = 100,
     group = groupStyle
)

// =====================================================
// ACTIVE STATES
// =====================================================

bool showStandardExtensions =
     extensionMode == "Standard" or
     extensionMode == "Both"

bool showSymmetricExtensions =
     extensionMode == "Symmetric" or
     extensionMode == "Both"

float labelMergeTolerance =
     syminfo.mintick

// =====================================================
// HELPERS
// =====================================================

f_label_size(string selection) =>
    switch selection
        "Tiny" =>
            size.tiny
        "Normal" =>
            size.normal
        =>
            size.small

f_is_level(
     float levelValue,
     float comparisonValue
) =>
    math.abs(levelValue - comparisonValue) < 0.000001

f_ratio_string(float levelValue) =>
    string result = ""

    if f_is_level(levelValue, -2.000)
        result := "-2.000"
    else if f_is_level(levelValue, -1.618)
        result := "-1.618"
    else if f_is_level(levelValue, -1.272)
        result := "-1.272"
    else if f_is_level(levelValue, -1.000)
        result := "-1.000"
    else if f_is_level(levelValue, -0.875)
        result := "-0.875"
    else if f_is_level(levelValue, -0.750)
        result := "-0.750"
    else if f_is_level(levelValue, -0.625)
        result := "-0.625"
    else if f_is_level(levelValue, -0.500)
        result := "EQU"
    else if f_is_level(levelValue, -0.375)
        result := "-0.375"
    else if f_is_level(levelValue, -0.250)
        result := "-0.250"
    else if f_is_level(levelValue, -0.125)
        result := "-0.125"
    else if f_is_level(levelValue, 0.000)
        result := "0"
    else if f_is_level(levelValue, 0.125)
        result := "0.125"
    else if f_is_level(levelValue, 0.250)
        result := "0.250"
    else if f_is_level(levelValue, 0.375)
        result := "0.375"
    else if f_is_level(levelValue, 0.500)
        result := "EQU"
    else if f_is_level(levelValue, 0.625)
        result := "0.625"
    else if f_is_level(levelValue, 0.750)
        result := "0.750"
    else if f_is_level(levelValue, 0.875)
        result := "0.875"
    else if f_is_level(levelValue, 1.000)
        result := "1.000"
    else if f_is_level(levelValue, 1.272)
        result := "1.272"
    else if f_is_level(levelValue, 1.618)
        result := "1.618"
    else if f_is_level(levelValue, 2.000)
        result := "2.000"
    else
        result := str.tostring(levelValue, "#.###")

    result

f_level_label(
     float levelValue,
     string timeframeLabel
) =>
    f_ratio_string(levelValue) + " " + timeframeLabel

f_level_color(float levelValue) =>
    color result = internalColor

    if levelValue < -1.000 or levelValue > 1.000
        result := extensionColor

    else if (
         f_is_level(levelValue, -1.000) or
         f_is_level(levelValue, 0.000) or
         f_is_level(levelValue, 1.000)
    )
        result := anchorColor

    else if (
         f_is_level(levelValue, -0.500) or
         f_is_level(levelValue, 0.500)
    )
        result := equilibriumColor

    result

f_level_color_priority(float levelValue) =>
    int result = 1

    if levelValue < -1.000 or levelValue > 1.000
        result := 4

    else if (
         f_is_level(levelValue, -1.000) or
         f_is_level(levelValue, 0.000) or
         f_is_level(levelValue, 1.000)
    )
        result := 3

    else if (
         f_is_level(levelValue, -0.500) or
         f_is_level(levelValue, 0.500)
    )
        result := 2

    result

f_level_style(float levelValue) =>
    if levelValue < -1.000 or levelValue > 1.000
        line.style_dashed

    else if (
         f_is_level(levelValue, -1.000) or
         f_is_level(levelValue, -0.500) or
         f_is_level(levelValue, 0.000) or
         f_is_level(levelValue, 0.500) or
         f_is_level(levelValue, 1.000)
    )
        line.style_solid

    else
        line.style_dotted

f_direction_string(
     float originPrice,
     float endpointPrice
) =>
    endpointPrice > originPrice ?
         "Bullish" :
         "Bearish"

f_direction_color(
     float originPrice,
     float endpointPrice
) =>
    endpointPrice > originPrice ?
         bullishColor :
         bearishColor

f_range_string(
     float originPrice,
     float endpointPrice
) =>
    float absoluteRange =
         math.abs(endpointPrice - originPrice)

    string result = ""

    if syminfo.type == "forex"

        float pipSize =
             syminfo.mintick * 10.0

        float pipRange =
             absoluteRange / pipSize

        result :=
             str.tostring(pipRange, "#.#") +
             " pips"

    else

        result :=
             str.tostring(
                 absoluteRange,
                 format.mintick
             ) +
             " pts"

    result

// =====================================================
// PIVOT FUNCTIONS
// =====================================================

f_pivot_high_price() =>
    ta.pivothigh(
         high,
         swingLeftBars,
         swingRightBars
    )

f_pivot_low_price() =>
    ta.pivotlow(
         low,
         swingLeftBars,
         swingRightBars
    )

f_pivot_high_time() =>
    float detectedPivot =
         ta.pivothigh(
             high,
             swingLeftBars,
             swingRightBars
         )

    int detectedTime = na

    if not na(detectedPivot)
        detectedTime :=
             time[swingRightBars]

    detectedTime

f_pivot_low_time() =>
    float detectedPivot =
         ta.pivotlow(
             low,
             swingLeftBars,
             swingRightBars
         )

    int detectedTime = na

    if not na(detectedPivot)
        detectedTime :=
             time[swingRightBars]

    detectedTime

// =====================================================
// DAILY DATA
// =====================================================

float dailyPivotHigh =
     request.security(
         syminfo.tickerid,
         "D",
         f_pivot_high_price(),
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off
     )

float dailyPivotLow =
     request.security(
         syminfo.tickerid,
         "D",
         f_pivot_low_price(),
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off
     )

int dailyPivotHighTime =
     request.security(
         syminfo.tickerid,
         "D",
         f_pivot_high_time(),
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off
     )

int dailyPivotLowTime =
     request.security(
         syminfo.tickerid,
         "D",
         f_pivot_low_time(),
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off
     )

bool newDailyPivotHigh =
     not na(dailyPivotHigh) and
     not na(dailyPivotHighTime) and
     (
         na(dailyPivotHighTime[1]) or
         dailyPivotHighTime != dailyPivotHighTime[1]
     )

bool newDailyPivotLow =
     not na(dailyPivotLow) and
     not na(dailyPivotLowTime) and
     (
         na(dailyPivotLowTime[1]) or
         dailyPivotLowTime != dailyPivotLowTime[1]
     )

// =====================================================
// 4H DATA
// =====================================================

float fourHourPivotHigh =
     request.security(
         syminfo.tickerid,
         "240",
         f_pivot_high_price(),
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off
     )

float fourHourPivotLow =
     request.security(
         syminfo.tickerid,
         "240",
         f_pivot_low_price(),
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off
     )

int fourHourPivotHighTime =
     request.security(
         syminfo.tickerid,
         "240",
         f_pivot_high_time(),
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off
     )

int fourHourPivotLowTime =
     request.security(
         syminfo.tickerid,
         "240",
         f_pivot_low_time(),
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off
     )

bool newFourHourPivotHigh =
     not na(fourHourPivotHigh) and
     not na(fourHourPivotHighTime) and
     (
         na(fourHourPivotHighTime[1]) or
         fourHourPivotHighTime != fourHourPivotHighTime[1]
     )

bool newFourHourPivotLow =
     not na(fourHourPivotLow) and
     not na(fourHourPivotLowTime) and
     (
         na(fourHourPivotLowTime[1]) or
         fourHourPivotLowTime != fourHourPivotLowTime[1]
     )

// =====================================================
// 1H DATA
// =====================================================

float oneHourPivotHigh =
     request.security(
         syminfo.tickerid,
         "60",
         f_pivot_high_price(),
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off
     )

float oneHourPivotLow =
     request.security(
         syminfo.tickerid,
         "60",
         f_pivot_low_price(),
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off
     )

int oneHourPivotHighTime =
     request.security(
         syminfo.tickerid,
         "60",
         f_pivot_high_time(),
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off
     )

int oneHourPivotLowTime =
     request.security(
         syminfo.tickerid,
         "60",
         f_pivot_low_time(),
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off
     )

bool newOneHourPivotHigh =
     not na(oneHourPivotHigh) and
     not na(oneHourPivotHighTime) and
     (
         na(oneHourPivotHighTime[1]) or
         oneHourPivotHighTime != oneHourPivotHighTime[1]
     )

bool newOneHourPivotLow =
     not na(oneHourPivotLow) and
     not na(oneHourPivotLowTime) and
     (
         na(oneHourPivotLowTime[1]) or
         oneHourPivotLowTime != oneHourPivotLowTime[1]
     )

// =====================================================
// 15M DATA
// =====================================================

float fifteenMinutePivotHigh =
     request.security(
         syminfo.tickerid,
         "15",
         f_pivot_high_price(),
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off
     )

float fifteenMinutePivotLow =
     request.security(
         syminfo.tickerid,
         "15",
         f_pivot_low_price(),
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off
     )

int fifteenMinutePivotHighTime =
     request.security(
         syminfo.tickerid,
         "15",
         f_pivot_high_time(),
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off
     )

int fifteenMinutePivotLowTime =
     request.security(
         syminfo.tickerid,
         "15",
         f_pivot_low_time(),
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off
     )

bool newFifteenMinutePivotHigh =
     not na(fifteenMinutePivotHigh) and
     not na(fifteenMinutePivotHighTime) and
     (
         na(fifteenMinutePivotHighTime[1]) or
         fifteenMinutePivotHighTime != fifteenMinutePivotHighTime[1]
     )

bool newFifteenMinutePivotLow =
     not na(fifteenMinutePivotLow) and
     not na(fifteenMinutePivotLowTime) and
     (
         na(fifteenMinutePivotLowTime[1]) or
         fifteenMinutePivotLowTime != fifteenMinutePivotLowTime[1]
     )

// =====================================================
// DAILY SWING ENGINE
// =====================================================

var int dailyLastSwingType = 0
var float dailyLastSwingPrice = na
var int dailyLastSwingTime = na

var float dailyFibOriginPrice = na
var int dailyFibOriginTime = na

var float dailyFibEndpointPrice = na
var int dailyFibEndpointTime = na

if newDailyPivotHigh

    if dailyLastSwingType == 0

        dailyLastSwingType := 1
        dailyLastSwingPrice := dailyPivotHigh
        dailyLastSwingTime := dailyPivotHighTime

    else if dailyLastSwingType == 1

        if dailyPivotHigh > dailyLastSwingPrice

            dailyLastSwingPrice := dailyPivotHigh
            dailyLastSwingTime := dailyPivotHighTime

            bool activeBullishDaily =
                 not na(dailyFibOriginPrice) and
                 not na(dailyFibEndpointPrice) and
                 dailyFibEndpointPrice > dailyFibOriginPrice

            if activeBullishDaily

                dailyFibEndpointPrice := dailyPivotHigh
                dailyFibEndpointTime := dailyPivotHighTime

    else

        dailyFibOriginPrice := dailyLastSwingPrice
        dailyFibOriginTime := dailyLastSwingTime

        dailyFibEndpointPrice := dailyPivotHigh
        dailyFibEndpointTime := dailyPivotHighTime

        dailyLastSwingType := 1
        dailyLastSwingPrice := dailyPivotHigh
        dailyLastSwingTime := dailyPivotHighTime

if newDailyPivotLow

    if dailyLastSwingType == 0

        dailyLastSwingType := -1
        dailyLastSwingPrice := dailyPivotLow
        dailyLastSwingTime := dailyPivotLowTime

    else if dailyLastSwingType == -1

        if dailyPivotLow < dailyLastSwingPrice

            dailyLastSwingPrice := dailyPivotLow
            dailyLastSwingTime := dailyPivotLowTime

            bool activeBearishDaily =
                 not na(dailyFibOriginPrice) and
                 not na(dailyFibEndpointPrice) and
                 dailyFibEndpointPrice < dailyFibOriginPrice

            if activeBearishDaily

                dailyFibEndpointPrice := dailyPivotLow
                dailyFibEndpointTime := dailyPivotLowTime

    else

        dailyFibOriginPrice := dailyLastSwingPrice
        dailyFibOriginTime := dailyLastSwingTime

        dailyFibEndpointPrice := dailyPivotLow
        dailyFibEndpointTime := dailyPivotLowTime

        dailyLastSwingType := -1
        dailyLastSwingPrice := dailyPivotLow
        dailyLastSwingTime := dailyPivotLowTime

// =====================================================
// 4H SWING ENGINE
// =====================================================

var int fourHourLastSwingType = 0
var float fourHourLastSwingPrice = na
var int fourHourLastSwingTime = na

var float fourHourFibOriginPrice = na
var int fourHourFibOriginTime = na

var float fourHourFibEndpointPrice = na
var int fourHourFibEndpointTime = na

if newFourHourPivotHigh

    if fourHourLastSwingType == 0

        fourHourLastSwingType := 1
        fourHourLastSwingPrice := fourHourPivotHigh
        fourHourLastSwingTime := fourHourPivotHighTime

    else if fourHourLastSwingType == 1

        if fourHourPivotHigh > fourHourLastSwingPrice

            fourHourLastSwingPrice := fourHourPivotHigh
            fourHourLastSwingTime := fourHourPivotHighTime

            bool activeBullishFourHour =
                 not na(fourHourFibOriginPrice) and
                 not na(fourHourFibEndpointPrice) and
                 fourHourFibEndpointPrice > fourHourFibOriginPrice

            if activeBullishFourHour

                fourHourFibEndpointPrice := fourHourPivotHigh
                fourHourFibEndpointTime := fourHourPivotHighTime

    else

        fourHourFibOriginPrice := fourHourLastSwingPrice
        fourHourFibOriginTime := fourHourLastSwingTime

        fourHourFibEndpointPrice := fourHourPivotHigh
        fourHourFibEndpointTime := fourHourPivotHighTime

        fourHourLastSwingType := 1
        fourHourLastSwingPrice := fourHourPivotHigh
        fourHourLastSwingTime := fourHourPivotHighTime

if newFourHourPivotLow

    if fourHourLastSwingType == 0

        fourHourLastSwingType := -1
        fourHourLastSwingPrice := fourHourPivotLow
        fourHourLastSwingTime := fourHourPivotLowTime

    else if fourHourLastSwingType == -1

        if fourHourPivotLow < fourHourLastSwingPrice

            fourHourLastSwingPrice := fourHourPivotLow
            fourHourLastSwingTime := fourHourPivotLowTime

            bool activeBearishFourHour =
                 not na(fourHourFibOriginPrice) and
                 not na(fourHourFibEndpointPrice) and
                 fourHourFibEndpointPrice < fourHourFibOriginPrice

            if activeBearishFourHour

                fourHourFibEndpointPrice := fourHourPivotLow
                fourHourFibEndpointTime := fourHourPivotLowTime

    else

        fourHourFibOriginPrice := fourHourLastSwingPrice
        fourHourFibOriginTime := fourHourLastSwingTime

        fourHourFibEndpointPrice := fourHourPivotLow
        fourHourFibEndpointTime := fourHourPivotLowTime

        fourHourLastSwingType := -1
        fourHourLastSwingPrice := fourHourPivotLow
        fourHourLastSwingTime := fourHourPivotLowTime

// =====================================================
// 1H SWING ENGINE
// =====================================================

var int oneHourLastSwingType = 0
var float oneHourLastSwingPrice = na
var int oneHourLastSwingTime = na

var float oneHourFibOriginPrice = na
var int oneHourFibOriginTime = na

var float oneHourFibEndpointPrice = na
var int oneHourFibEndpointTime = na

if newOneHourPivotHigh

    if oneHourLastSwingType == 0

        oneHourLastSwingType := 1
        oneHourLastSwingPrice := oneHourPivotHigh
        oneHourLastSwingTime := oneHourPivotHighTime

    else if oneHourLastSwingType == 1

        if oneHourPivotHigh > oneHourLastSwingPrice

            oneHourLastSwingPrice := oneHourPivotHigh
            oneHourLastSwingTime := oneHourPivotHighTime

            bool activeBullishOneHour =
                 not na(oneHourFibOriginPrice) and
                 not na(oneHourFibEndpointPrice) and
                 oneHourFibEndpointPrice > oneHourFibOriginPrice

            if activeBullishOneHour

                oneHourFibEndpointPrice := oneHourPivotHigh
                oneHourFibEndpointTime := oneHourPivotHighTime

    else

        oneHourFibOriginPrice := oneHourLastSwingPrice
        oneHourFibOriginTime := oneHourLastSwingTime

        oneHourFibEndpointPrice := oneHourPivotHigh
        oneHourFibEndpointTime := oneHourPivotHighTime

        oneHourLastSwingType := 1
        oneHourLastSwingPrice := oneHourPivotHigh
        oneHourLastSwingTime := oneHourPivotHighTime

if newOneHourPivotLow

    if oneHourLastSwingType == 0

        oneHourLastSwingType := -1
        oneHourLastSwingPrice := oneHourPivotLow
        oneHourLastSwingTime := oneHourPivotLowTime

    else if oneHourLastSwingType == -1

        if oneHourPivotLow < oneHourLastSwingPrice

            oneHourLastSwingPrice := oneHourPivotLow
            oneHourLastSwingTime := oneHourPivotLowTime

            bool activeBearishOneHour =
                 not na(oneHourFibOriginPrice) and
                 not na(oneHourFibEndpointPrice) and
                 oneHourFibEndpointPrice < oneHourFibOriginPrice

            if activeBearishOneHour

                oneHourFibEndpointPrice := oneHourPivotLow
                oneHourFibEndpointTime := oneHourPivotLowTime

    else

        oneHourFibOriginPrice := oneHourLastSwingPrice
        oneHourFibOriginTime := oneHourLastSwingTime

        oneHourFibEndpointPrice := oneHourPivotLow
        oneHourFibEndpointTime := oneHourPivotLowTime

        oneHourLastSwingType := -1
        oneHourLastSwingPrice := oneHourPivotLow
        oneHourLastSwingTime := oneHourPivotLowTime

// =====================================================
// 15M SWING ENGINE
// =====================================================

var int fifteenMinuteLastSwingType = 0
var float fifteenMinuteLastSwingPrice = na
var int fifteenMinuteLastSwingTime = na

var float fifteenMinuteFibOriginPrice = na
var int fifteenMinuteFibOriginTime = na

var float fifteenMinuteFibEndpointPrice = na
var int fifteenMinuteFibEndpointTime = na

if newFifteenMinutePivotHigh

    if fifteenMinuteLastSwingType == 0

        fifteenMinuteLastSwingType := 1
        fifteenMinuteLastSwingPrice := fifteenMinutePivotHigh
        fifteenMinuteLastSwingTime := fifteenMinutePivotHighTime

    else if fifteenMinuteLastSwingType == 1

        if fifteenMinutePivotHigh > fifteenMinuteLastSwingPrice

            fifteenMinuteLastSwingPrice := fifteenMinutePivotHigh
            fifteenMinuteLastSwingTime := fifteenMinutePivotHighTime

            bool activeBullishFifteenMinute =
                 not na(fifteenMinuteFibOriginPrice) and
                 not na(fifteenMinuteFibEndpointPrice) and
                 fifteenMinuteFibEndpointPrice > fifteenMinuteFibOriginPrice

            if activeBullishFifteenMinute

                fifteenMinuteFibEndpointPrice := fifteenMinutePivotHigh
                fifteenMinuteFibEndpointTime := fifteenMinutePivotHighTime

    else

        fifteenMinuteFibOriginPrice := fifteenMinuteLastSwingPrice
        fifteenMinuteFibOriginTime := fifteenMinuteLastSwingTime

        fifteenMinuteFibEndpointPrice := fifteenMinutePivotHigh
        fifteenMinuteFibEndpointTime := fifteenMinutePivotHighTime

        fifteenMinuteLastSwingType := 1
        fifteenMinuteLastSwingPrice := fifteenMinutePivotHigh
        fifteenMinuteLastSwingTime := fifteenMinutePivotHighTime

if newFifteenMinutePivotLow

    if fifteenMinuteLastSwingType == 0

        fifteenMinuteLastSwingType := -1
        fifteenMinuteLastSwingPrice := fifteenMinutePivotLow
        fifteenMinuteLastSwingTime := fifteenMinutePivotLowTime

    else if fifteenMinuteLastSwingType == -1

        if fifteenMinutePivotLow < fifteenMinuteLastSwingPrice

            fifteenMinuteLastSwingPrice := fifteenMinutePivotLow
            fifteenMinuteLastSwingTime := fifteenMinutePivotLowTime

            bool activeBearishFifteenMinute =
                 not na(fifteenMinuteFibOriginPrice) and
                 not na(fifteenMinuteFibEndpointPrice) and
                 fifteenMinuteFibEndpointPrice < fifteenMinuteFibOriginPrice

            if activeBearishFifteenMinute

                fifteenMinuteFibEndpointPrice := fifteenMinutePivotLow
                fifteenMinuteFibEndpointTime := fifteenMinutePivotLowTime

    else

        fifteenMinuteFibOriginPrice := fifteenMinuteLastSwingPrice
        fifteenMinuteFibOriginTime := fifteenMinuteLastSwingTime

        fifteenMinuteFibEndpointPrice := fifteenMinutePivotLow
        fifteenMinuteFibEndpointTime := fifteenMinutePivotLowTime

        fifteenMinuteLastSwingType := -1
        fifteenMinuteLastSwingPrice := fifteenMinutePivotLow
        fifteenMinuteLastSwingTime := fifteenMinutePivotLowTime

// =====================================================
// DRAWING + LABEL STORAGE
// =====================================================

var line[] fibLines = array.new_line()
var label[] fibLabels = array.new_label()

var float[] mergedLabelPrices = array.new_float()
var string[] mergedLabelTexts = array.new_string()
var color[] mergedLabelColors = array.new_color()
var int[] mergedLabelColorPriorities = array.new_int()

var float[] displayedLevelPrices = array.new_float()
var int[] displayedLevelTimeframes = array.new_int()

f_clear_drawings() =>
    int lineCount = array.size(fibLines)

    if lineCount > 0

        for lineIndex = 0 to lineCount - 1

            line.delete(
                 array.get(
                     fibLines,
                     lineIndex
                 )
             )

    int labelCount = array.size(fibLabels)

    if labelCount > 0

        for labelIndex = 0 to labelCount - 1

            label.delete(
                 array.get(
                     fibLabels,
                     labelIndex
                 )
             )

    array.clear(fibLines)
    array.clear(fibLabels)

    array.clear(mergedLabelPrices)
    array.clear(mergedLabelTexts)
    array.clear(mergedLabelColors)
    array.clear(mergedLabelColorPriorities)

    array.clear(displayedLevelPrices)
    array.clear(displayedLevelTimeframes)

// =====================================================
// MERGED LABEL REGISTRATION
// =====================================================

f_register_level_label(
     float levelPrice,
     string levelText,
     color levelColor,
     int levelColorPriority
) =>
    int matchingLabelIndex = -1
    int existingLabelCount = array.size(mergedLabelPrices)

    if existingLabelCount > 0

        for searchIndex = 0 to existingLabelCount - 1

            float existingPrice =
                 array.get(
                     mergedLabelPrices,
                     searchIndex
                 )

            bool pricesAligned =
                 math.abs(
                     existingPrice -
                     levelPrice
                 ) <= labelMergeTolerance

            if pricesAligned

                matchingLabelIndex := searchIndex
                break

    if matchingLabelIndex == -1

        array.push(
             mergedLabelPrices,
             levelPrice
         )

        array.push(
             mergedLabelTexts,
             levelText
         )

        array.push(
             mergedLabelColors,
             levelColor
         )

        array.push(
             mergedLabelColorPriorities,
             levelColorPriority
         )

    else

        string existingText =
             array.get(
                 mergedLabelTexts,
                 matchingLabelIndex
             )

        string mergedText =
             existingText +
             " | " +
             levelText

        array.set(
             mergedLabelTexts,
             matchingLabelIndex,
             mergedText
         )

        int existingPriority =
             array.get(
                 mergedLabelColorPriorities,
                 matchingLabelIndex
             )

        if levelColorPriority > existingPriority

            array.set(
                 mergedLabelColors,
                 matchingLabelIndex,
                 levelColor
             )

            array.set(
                 mergedLabelColorPriorities,
                 matchingLabelIndex,
                 levelColorPriority
             )

// =====================================================
// DRAW ONE LEVEL
// =====================================================

f_draw_level(
     float levelValue,
     float originPrice,
     int originTime,
     float endpointPrice,
     int endpointTime,
     string timeframeLabel,
     int timeframeIndex
) =>
    float fibRange =
         originPrice -
         endpointPrice

    float levelPrice =
         endpointPrice +
         fibRange *
         levelValue

    color levelColor =
         f_level_color(levelValue)

    int lineStartTime =
         math.min(
             originTime,
             endpointTime
         )

    line createdLine =
         line.new(
             x1 = lineStartTime,
             y1 = levelPrice,
             x2 = time,
             y2 = levelPrice,
             xloc = xloc.bar_time,
             extend = extend.right,
             color = color.new(
                 levelColor,
                 lineOpacity
             ),
             width = 1,
             style = f_level_style(
                 levelValue
             )
         )

    array.push(
         fibLines,
         createdLine
    )

    array.push(
         displayedLevelPrices,
         levelPrice
    )

    array.push(
         displayedLevelTimeframes,
         timeframeIndex
    )

    f_register_level_label(
         levelPrice,
         f_level_label(
             levelValue,
             timeframeLabel
         ),
         levelColor,
         f_level_color_priority(
             levelValue
         )
     )

// =====================================================
// DRAW SWING SYMBOLS
// =====================================================

f_draw_swing_symbols(
     float originPrice,
     int originTime,
     float endpointPrice,
     int endpointTime,
     color symbolColor
) =>
    float highPrice =
         math.max(
             originPrice,
             endpointPrice
         )

    float lowPrice =
         math.min(
             originPrice,
             endpointPrice
         )

    int highTime =
         originPrice > endpointPrice ?
         originTime :
         endpointTime

    int lowTime =
         originPrice < endpointPrice ?
         originTime :
         endpointTime

    label highSymbol =
         label.new(
             x = highTime,
             y = highPrice,
             text = "▼",
             xloc = xloc.bar_time,
             yloc = yloc.price,
             style = label.style_none,
             textcolor = symbolColor,
             size = size.small
         )

    array.push(
         fibLabels,
         highSymbol
    )

    label lowSymbol =
         label.new(
             x = lowTime,
             y = lowPrice,
             text = "▲",
             xloc = xloc.bar_time,
             yloc = yloc.price,
             style = label.style_none,
             textcolor = symbolColor,
             size = size.small
         )

    array.push(
         fibLabels,
         lowSymbol
    )

// =====================================================
// DRAW COMPLETE TIMEFRAME FIB
// =====================================================

f_draw_timeframe_fib(
     float originPrice,
     int originTime,
     float endpointPrice,
     int endpointTime,
     string timeframeLabel,
     int timeframeIndex,
     color symbolColor
) =>
    bool validFib =
         not na(originPrice) and
         not na(originTime) and
         not na(endpointPrice) and
         not na(endpointTime) and
         originPrice != endpointPrice

    if validFib

        if showSymmetricExtensions

            f_draw_level(-2.000, originPrice, originTime, endpointPrice, endpointTime, timeframeLabel, timeframeIndex)
            f_draw_level(-1.618, originPrice, originTime, endpointPrice, endpointTime, timeframeLabel, timeframeIndex)
            f_draw_level(-1.272, originPrice, originTime, endpointPrice, endpointTime, timeframeLabel, timeframeIndex)
            f_draw_level(-1.000, originPrice, originTime, endpointPrice, endpointTime, timeframeLabel, timeframeIndex)
            f_draw_level(-0.875, originPrice, originTime, endpointPrice, endpointTime, timeframeLabel, timeframeIndex)
            f_draw_level(-0.750, originPrice, originTime, endpointPrice, endpointTime, timeframeLabel, timeframeIndex)
            f_draw_level(-0.625, originPrice, originTime, endpointPrice, endpointTime, timeframeLabel, timeframeIndex)
            f_draw_level(-0.500, originPrice, originTime, endpointPrice, endpointTime, timeframeLabel, timeframeIndex)
            f_draw_level(-0.375, originPrice, originTime, endpointPrice, endpointTime, timeframeLabel, timeframeIndex)
            f_draw_level(-0.250, originPrice, originTime, endpointPrice, endpointTime, timeframeLabel, timeframeIndex)
            f_draw_level(-0.125, originPrice, originTime, endpointPrice, endpointTime, timeframeLabel, timeframeIndex)

        f_draw_level(0.000, originPrice, originTime, endpointPrice, endpointTime, timeframeLabel, timeframeIndex)
        f_draw_level(0.125, originPrice, originTime, endpointPrice, endpointTime, timeframeLabel, timeframeIndex)
        f_draw_level(0.250, originPrice, originTime, endpointPrice, endpointTime, timeframeLabel, timeframeIndex)
        f_draw_level(0.375, originPrice, originTime, endpointPrice, endpointTime, timeframeLabel, timeframeIndex)
        f_draw_level(0.500, originPrice, originTime, endpointPrice, endpointTime, timeframeLabel, timeframeIndex)
        f_draw_level(0.625, originPrice, originTime, endpointPrice, endpointTime, timeframeLabel, timeframeIndex)
        f_draw_level(0.750, originPrice, originTime, endpointPrice, endpointTime, timeframeLabel, timeframeIndex)
        f_draw_level(0.875, originPrice, originTime, endpointPrice, endpointTime, timeframeLabel, timeframeIndex)
        f_draw_level(1.000, originPrice, originTime, endpointPrice, endpointTime, timeframeLabel, timeframeIndex)

        if showStandardExtensions

            f_draw_level(1.272, originPrice, originTime, endpointPrice, endpointTime, timeframeLabel, timeframeIndex)
            f_draw_level(1.618, originPrice, originTime, endpointPrice, endpointTime, timeframeLabel, timeframeIndex)
            f_draw_level(2.000, originPrice, originTime, endpointPrice, endpointTime, timeframeLabel, timeframeIndex)

        if showSwingSymbols

            f_draw_swing_symbols(
                 originPrice,
                 originTime,
                 endpointPrice,
                 endpointTime,
                 symbolColor
             )

// =====================================================
// REDRAW ACTIVE FIBS
// =====================================================

f_clear_drawings()

if showDaily

    f_draw_timeframe_fib(
         dailyFibOriginPrice,
         dailyFibOriginTime,
         dailyFibEndpointPrice,
         dailyFibEndpointTime,
         "D",
         0,
         dailyTriangleColor
     )

if show4H

    f_draw_timeframe_fib(
         fourHourFibOriginPrice,
         fourHourFibOriginTime,
         fourHourFibEndpointPrice,
         fourHourFibEndpointTime,
         "4H",
         1,
         fourHourTriangleColor
     )

if show1H

    f_draw_timeframe_fib(
         oneHourFibOriginPrice,
         oneHourFibOriginTime,
         oneHourFibEndpointPrice,
         oneHourFibEndpointTime,
         "1H",
         2,
         oneHourTriangleColor
     )

if show15m

    f_draw_timeframe_fib(
         fifteenMinuteFibOriginPrice,
         fifteenMinuteFibOriginTime,
         fifteenMinuteFibEndpointPrice,
         fifteenMinuteFibEndpointTime,
         "15m",
         3,
         fifteenMinuteTriangleColor
     )

// =====================================================
// CREATE FINAL MERGED LABELS
// =====================================================

int finalLabelCount =
     array.size(
         mergedLabelPrices
     )

if finalLabelCount > 0

    for finalLabelIndex = 0 to finalLabelCount - 1

        float finalLabelPrice =
             array.get(
                 mergedLabelPrices,
                 finalLabelIndex
             )

        string finalLabelText =
             array.get(
                 mergedLabelTexts,
                 finalLabelIndex
             )

        color finalLabelColor =
             array.get(
                 mergedLabelColors,
                 finalLabelIndex
             )

        label createdFinalLabel =
             label.new(
                 x = bar_index + labelOffset,
                 y = finalLabelPrice,
                 text = finalLabelText,
                 xloc = xloc.bar_index,
                 style = label.style_none,
                 textcolor = color.new(
                     finalLabelColor,
                     labelOpacity
                 ),
                 size = f_label_size(
                     labelSizeInput
                 )
             )

        array.push(
             fibLabels,
             createdFinalLabel
        )

// =====================================================
// CONFLUENCE COUNT
// =====================================================

f_confluence_count(int timeframeIndex) =>
    int confluenceCount = 0
    int levelCount = array.size(displayedLevelPrices)

    if levelCount > 0

        for firstIndex = 0 to levelCount - 1

            int firstTimeframe =
                 array.get(
                     displayedLevelTimeframes,
                     firstIndex
                 )

            if firstTimeframe == timeframeIndex

                float firstPrice =
                     array.get(
                         displayedLevelPrices,
                         firstIndex
                     )

                bool alignedWithOtherTimeframe = false

                for secondIndex = 0 to levelCount - 1

                    int secondTimeframe =
                         array.get(
                             displayedLevelTimeframes,
                             secondIndex
                         )

                    if secondTimeframe != timeframeIndex

                        float secondPrice =
                             array.get(
                                 displayedLevelPrices,
                                 secondIndex
                             )

                        bool pricesAligned =
                             math.abs(
                                 firstPrice -
                                 secondPrice
                             ) <= labelMergeTolerance

                        if pricesAligned

                            alignedWithOtherTimeframe := true
                            break

                if alignedWithOtherTimeframe

                    confluenceCount += 1

    confluenceCount

// =====================================================
// TRANSPARENT HTF INFORMATION TABLE
// =====================================================

var table informationTable =
     table.new(
         position.bottom_right,
         4,
         7,
         bgcolor = transparentColor,
         frame_color = transparentColor,
         border_color = transparentColor
     )

f_add_information_row(
     int rowIndex,
     string timeframeLabel,
     int timeframeIndex,
     float originPrice,
     float endpointPrice
) =>
    bool validInformation =
         not na(originPrice) and
         not na(endpointPrice)

    if validInformation

        table.cell(
             informationTable,
             0,
             rowIndex,
             timeframeLabel,
             text_color = informationTextColor,
             bgcolor = transparentColor,
             text_size = size.small
         )

        table.cell(
             informationTable,
             1,
             rowIndex,
             f_direction_string(
                 originPrice,
                 endpointPrice
             ),
             text_color = f_direction_color(
                 originPrice,
                 endpointPrice
             ),
             bgcolor = transparentColor,
             text_size = size.small
         )

        table.cell(
             informationTable,
             2,
             rowIndex,
             f_range_string(
                 originPrice,
                 endpointPrice
             ),
             text_color = informationTextColor,
             bgcolor = transparentColor,
             text_size = size.small
         )

        table.cell(
             informationTable,
             3,
             rowIndex,
             str.tostring(
                 f_confluence_count(
                     timeframeIndex
                 )
             ),
             text_color = informationTextColor,
             bgcolor = transparentColor,
             text_size = size.small
         )

if barstate.islast

    table.clear(
         informationTable,
         0,
         0,
         3,
         6
     )

    if showHtfInformation

        table.cell(
             informationTable,
             0,
             0,
             "TF",
             text_color = informationTextColor,
             bgcolor = transparentColor,
             text_size = size.tiny
         )

        table.cell(
             informationTable,
             1,
             0,
             "Direction",
             text_color = informationTextColor,
             bgcolor = transparentColor,
             text_size = size.tiny
         )

        table.cell(
             informationTable,
             2,
             0,
             "Range",
             text_color = informationTextColor,
             bgcolor = transparentColor,
             text_size = size.tiny
         )

        table.cell(
             informationTable,
             3,
             0,
             "Conf",
             text_color = informationTextColor,
             bgcolor = transparentColor,
             text_size = size.tiny
         )

        int informationRow = 1

        if showDaily

            f_add_information_row(
                 informationRow,
                 "D",
                 0,
                 dailyFibOriginPrice,
                 dailyFibEndpointPrice
             )

            informationRow += 1

        if show4H

            f_add_information_row(
                 informationRow,
                 "4H",
                 1,
                 fourHourFibOriginPrice,
                 fourHourFibEndpointPrice
             )

            informationRow += 1

        if show1H

            f_add_information_row(
                 informationRow,
                 "1H",
                 2,
                 oneHourFibOriginPrice,
                 oneHourFibEndpointPrice
             )

            informationRow += 1

        if show15m

            f_add_information_row(
                 informationRow,
                 "15m",
                 3,
                 fifteenMinuteFibOriginPrice,
                 fifteenMinuteFibEndpointPrice
             )
````
