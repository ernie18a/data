<!-- tradingview-pine-id: PUB;04c7640f92ae42cd908a3c0d1e5f59d0 -->
<!-- tradingviewscripts-format: 1 -->
# MC Scanner PRO

Source: https://www.tradingview.com/script/mTNXCgD9-MC-Scanner-PRO/

## Description

This scanner finds a bullish or bearish Manipulation Candle (MC) and colors it green/red. A bullish MC will wick below the previous candle, engulf and close above it. (The reverse for bearish scenario.) On the 4h time frame an MC typically indicates the direction price will continue. 

Add the indicator to your chart and do the analysis on the 4h TF. There are several parameters to set to your liking. This indicator is designed to work in combination with the indicator "MC Screener 4H", which shall only be marked as a favorite (by a star), but not added to the chart itself. The MC Screener 4H indicator is then used inside the Pine Screener to identify all assets/pairs in your watchlist (of choice) that have a current/fresh Manipulation Candle for a potential trade setup.

---

## Source Code

````pine
//@version=6
indicator("MC Scanner PRO", shorttitle = "MC Scanner PRO", overlay = true, max_boxes_count = 10)

//=============================================================================
// 1. MANIPULATION CANDLE
//=============================================================================

string analysisTf = input.string(
     defval = "240",
     title = "Analysis timeframe",
     options = ["1", "5", "15", "30", "60", "120", "240", "1D", "1W", "1M"],
     tooltip = "240 = 4 hours. Use the same chart timeframe for exact native candle coloring.",
     group = "1. Manipulation Candle"
)

string mcType = input.string(
     defval = "Strict Outside Candle",
     title = "MC type",
     options = ["Strict Outside Candle", "One-Sided Manipulation"],
     tooltip = "Strict requires both a higher high and lower low. One-Sided requires only the relevant liquidity-side sweep.",
     group = "1. Manipulation Candle"
)

int validForBars = input.int(
     defval = 5,
     title = "MC valid for analysis candles",
     minval = 1,
     maxval = 30,
     tooltip = "The latest MC remains active for this number of analysis-timeframe candles. Older historical MC candles are not colored.",
     group = "1. Manipulation Candle"
)

//=============================================================================
// 2. VISUALS
//=============================================================================

bool showPatternBox = input.bool(
     defval = true,
     title = "Show frame around previous candle + MC",
     group = "2. Visuals"
)

bool colorMcCandle = input.bool(
     defval = true,
     title = "Color actual MC candle",
     tooltip = "Uses TradingView native candle coloring. Exact coloring requires chart timeframe = analysis timeframe.",
     group = "2. Visuals"
)

color bullishColor = input.color(
     defval = color.rgb(0, 220, 120),
     title = "Bullish MC color",
     group = "2. Visuals"
)

color bearishColor = input.color(
     defval = color.rgb(245, 55, 70),
     title = "Bearish MC color",
     group = "2. Visuals"
)

int frameTransparency = input.int(
     defval = 92,
     title = "Frame fill transparency",
     minval = 0,
     maxval = 100,
     tooltip = "0 = opaque fill. 100 = completely transparent fill.",
     group = "2. Visuals"
)

int frameBorderTransparency = input.int(
     defval = 65,
     title = "Border transparency",
     minval = 0,
     maxval = 100,
     tooltip = "0 = fully visible border. 100 = invisible border. Increase this value if the border obscures candle wicks.",
     group = "2. Visuals"
)

int frameBorderWidth = input.int(
     defval = 1,
     title = "Frame border width",
     minval = 1,
     maxval = 5,
     group = "2. Visuals"
)

//=============================================================================
// TIMEFRAME INFORMATION
//=============================================================================

float chartTfSeconds = timeframe.in_seconds(timeframe.period)
float analysisTfSeconds = timeframe.in_seconds(analysisTf)

bool sameTimeframe = chartTfSeconds == analysisTfSeconds

//=============================================================================
// ANALYSIS-TIMEFRAME MC DATA
//
// Within request.security():
//
// [1] = latest fully closed analysis candle and MC candidate.
// [2] = candle immediately before the MC.
// [0] = currently forming candle after the MC.
//=============================================================================

getMcData() =>
    bool bullishBase = close[1] > open[1] and low[1] < low[2] and close[1] > math.max(open[2], close[2])
    bool bearishBase = close[1] < open[1] and high[1] > high[2] and close[1] < math.min(open[2], close[2])

    bool bullishMc = bullishBase and (mcType == "One-Sided Manipulation" or high[1] > high[2])
    bool bearishMc = bearishBase and (mcType == "One-Sided Manipulation" or low[1] < low[2])

    int direction = bullishMc ? 1 : bearishMc ? -1 : 0

    [time[3], time[2], time[1], time, high[1], low[1], direction]

// IMPORTANT:
// Keep this entire receiving tuple on one line to avoid CE10013.

[aBeforePreviousTime, aPreviousTime, aMcTime, aFollowingTime, aMcHigh, aMcLow, aDirection] = request.security(syminfo.tickerid, analysisTf, getMcData(), lookahead = barmerge.lookahead_on)

// This becomes true when another analysis-timeframe candle begins.
// The candidate candle is then fully closed and confirmed.

bool newAnalysisCandle = not na(aMcTime) and ta.change(aMcTime) != 0

bool candidateExists = aDirection != 0
bool newMcEvent = newAnalysisCandle and candidateExists
bool newBullishMcEvent = newMcEvent and aDirection == 1
bool newBearishMcEvent = newMcEvent and aDirection == -1

//=============================================================================
// ACTIVE MC STATE
//
// Direction:
//  1 = bullish MC
// -1 = bearish MC
//  0 = no active MC
//
// Age:
//  0 = newly confirmed MC
//  1 = one later analysis candle
//  2 = two later analysis candles
//=============================================================================

var int activeDirection = 0
var int activeAge = na

var int activeBeforePreviousTime = na
var int activePreviousTime = na
var int activeMcTime = na
var int activeFollowingTime = na

var float activeMcHigh = na
var float activeMcLow = na

var box patternBox = na

//=============================================================================
// PROCESS EACH NEW ANALYSIS CANDLE
//=============================================================================

if newAnalysisCandle
    if candidateExists
        if not na(patternBox)
            box.delete(patternBox)

        patternBox := na

        activeDirection := aDirection
        activeAge := 0

        activeBeforePreviousTime := aBeforePreviousTime
        activePreviousTime := aPreviousTime
        activeMcTime := aMcTime
        activeFollowingTime := aFollowingTime

        activeMcHigh := aMcHigh
        activeMcLow := aMcLow

    else if activeDirection != 0
        activeAge += 1

        if activeAge >= validForBars
            if not na(patternBox)
                box.delete(patternBox)

            patternBox := na

            activeDirection := 0
            activeAge := na

            activeBeforePreviousTime := na
            activePreviousTime := na
            activeMcTime := na
            activeFollowingTime := na

            activeMcHigh := na
            activeMcLow := na

//=============================================================================
// ACTIVE VALUES
//=============================================================================

bool mcActive = activeDirection != 0
bool bullishMcActive = activeDirection == 1
bool bearishMcActive = activeDirection == -1

color activeColor = bullishMcActive ? bullishColor : bearishMcActive ? bearishColor : na

color activeBorderColor = color.new(activeColor, frameBorderTransparency)

//=============================================================================
// NATIVE MC CANDLE COLORING
//
// Detection occurs on the candle following the MC.
// offset = -1 therefore colors the actual MC candle.
//
// The right-edge condition prevents historical MC candles from remaining
// colored. Only an MC inside the selected validity period is colored.
//=============================================================================

int detectionBarsFromRightEdge = last_bar_index - bar_index

bool detectionIsFresh =
     detectionBarsFromRightEdge >= 0 and
     detectionBarsFromRightEdge < validForBars

bool paintMcCandle =
     colorMcCandle and
     sameTimeframe and
     newMcEvent and
     detectionIsFresh

color mcCandleColor =
     paintMcCandle ?
     aDirection == 1 ? bullishColor :
     aDirection == -1 ? bearishColor :
     na :
     na

barcolor(mcCandleColor, offset = -1)

//=============================================================================
// FRAME POSITION
//
// Candles are visually centered around their timestamps.
//
// The frame covers exactly:
// [ candle preceding MC ][ MC candle ]
//=============================================================================

int patternLeftTime = not na(activeBeforePreviousTime) and not na(activePreviousTime) ? activeBeforePreviousTime + int(math.round((activePreviousTime - activeBeforePreviousTime) / 2.0)) : na

int patternRightTime = not na(activeMcTime) and not na(activeFollowingTime) ? activeMcTime + int(math.round((activeFollowingTime - activeMcTime) / 2.0)) : na

//=============================================================================
// FRAME AROUND PREVIOUS CANDLE + MC
//=============================================================================

if not showPatternBox and not na(patternBox)
    box.delete(patternBox)
    patternBox := na

if mcActive and showPatternBox and na(patternBox) and not na(patternLeftTime) and not na(patternRightTime)
    patternBox := box.new(
         left = patternLeftTime,
         top = activeMcHigh,
         right = patternRightTime,
         bottom = activeMcLow,
         xloc = xloc.bar_time,
         border_color = activeBorderColor,
         border_width = frameBorderWidth,
         bgcolor = color.new(activeColor, frameTransparency)
    )

if mcActive and not na(patternBox)
    box.set_left(patternBox, patternLeftTime)
    box.set_right(patternBox, patternRightTime)
    box.set_top(patternBox, activeMcHigh)
    box.set_bottom(patternBox, activeMcLow)
    box.set_border_color(patternBox, activeBorderColor)
    box.set_border_width(patternBox, frameBorderWidth)
    box.set_bgcolor(patternBox, color.new(activeColor, frameTransparency))

//=============================================================================
// PINE SCREENER OUTPUTS
//=============================================================================

// MC Active:
// 1 = a fresh MC exists.
// 0 = no fresh MC.

plot(
     mcActive ? 1 : 0,
     title = "MC Active",
     color = color.black,
     display = display.none
)

// MC Direction:
// 1 = bullish.
// -1 = bearish.
// 0 = no active MC.

plot(
     activeDirection,
     title = "MC Direction",
     color = color.black,
     display = display.none
)

// Bullish MC:
// 1 = active bullish MC.
// 0 = otherwise.

plot(
     bullishMcActive ? 1 : 0,
     title = "Bullish MC",
     color = bullishColor,
     display = display.none
)

// Bearish MC:
// 1 = active bearish MC.
// 0 = otherwise.

plot(
     bearishMcActive ? 1 : 0,
     title = "Bearish MC",
     color = bearishColor,
     display = display.none
)

// MC Age:
// 0 = newly confirmed.
// 1 = one analysis candle later.
// 2 = two analysis candles later.

plot(
     mcActive ? activeAge : na,
     title = "MC Age",
     color = color.gray,
     display = display.none
)

//=============================================================================
// ALERTS
//=============================================================================

alertcondition(
     newBullishMcEvent,
     title = "New Bullish MC",
     message = "New bullish Manipulation Candle confirmed on {{ticker}}."
)

alertcondition(
     newBearishMcEvent,
     title = "New Bearish MC",
     message = "New bearish Manipulation Candle confirmed on {{ticker}}."
)

alertcondition(
     newMcEvent,
     title = "New MC",
     message = "New Manipulation Candle confirmed on {{ticker}}."
)
````
