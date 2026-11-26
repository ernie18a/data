# GFG Daily Levels Auto by Agaam

- url: https://www.tradingview.com/script/Ww5BJSMJ-GFG-Daily-Levels-Auto-by-Agaam/
- type: indicator
- pine_id: PUB;172447021290457ab9cd22e8283766c6
- version: 1.0

## Description

GFG Daily Levels Auto is a clean daily-level overlay that helps avoid a messy chart by hiding distant levels and automatically showing them only when price comes near. It tracks key levels such as premarket high/low, opening ranges, yesterday high/low, pivots, and previous HOD/LOD references while keeping the chart focused on the levels currently relevant to price action.



GFG Daily Levels Auto by Agaam

**GFG Daily Levels Auto** is a chart-overlay indicator designed to automatically display important intraday and daily reference levels on the chart. The goal of this script is to help traders keep the most useful session levels visible without manually drawing them every day.

This indicator focuses on price levels that many intraday traders watch, including premarket high/low, opening range levels, yesterday’s high/low, daily pivot levels, and previous high-of-day / low-of-day reference levels. It also includes an optional “near price” display mode that helps reduce chart clutter by showing selected levels only when price is approaching them.

## What Makes This Script Useful

Many daily-level indicators plot every level all the time, which can make the chart crowded and hard to read. This script is designed to be more flexible by giving traders control over which levels appear, how they look, and whether they should only appear when price is close.

The main idea is to combine daily market structure levels with intraday session levels in one organized overlay. This allows traders to watch important areas of interest without needing separate indicators for premarket levels, opening ranges, yesterday levels, and daily pivots.

## Main Levels Included

### Premarket High and Low

The script tracks the premarket session and records:

* PMH 1: primary premarket high
* PMH 2: secondary premarket high
* PML 1: primary premarket low
* PML 2: secondary premarket low

The second premarket levels are separated using a tick-based distance filter. This helps avoid plotting nearly identical levels too close together.

### 3-Minute Opening Range

The script can plot the high and low of the first 3 minutes after the regular market open.

These levels are labeled:

* 3H
* 3L

The 3-minute opening range is intended to be used only on 3m, 5m, and 15m charts. This keeps the feature more consistent and avoids using it on chart timeframes where the 3-minute range would not be represented clearly.

### 30-Minute Opening Range

The script can also plot the high and low of the first 30 minutes after the regular market open.

These levels are labeled:

* 30H
* 30L

The 30-minute opening range can be useful for traders who watch the first major balance area of the regular session.

### Yesterday High and Low

The indicator plots the prior daily candle’s high and low:

* YH
* YL

These levels can act as important reference areas because traders often watch whether price accepts above, rejects below, or reacts around the previous day’s range.

### Daily Pivot Levels

The script calculates classic daily pivot levels using yesterday’s high, low, and close.

Included levels:

* Pivot Point
* R1 / S1
* R2 / S2
* R3 / S3

These levels give traders a structured daily support and resistance framework based on the prior day’s price range.

### Previous HOD / LOD Reference Levels

The script also tracks previous high-of-day and low-of-day reference levels as price creates new highs or new lows during the session.

These levels are labeled:

* HOD 1
* HOD 2
* LOD 1
* LOD 2

They are designed to show earlier intraday high/low reference areas that may still matter after price has moved beyond them.

## Auto Near Price Mode

One of the key features of this script is the optional **Auto Show Only Near Price** mode.

When enabled, selected levels appear only when price is close to them. The script measures distance using:

* Tick distance
* ATR-based distance
* Actual candle touch of the level

This helps keep the chart cleaner by hiding levels that are far away from current price action. When price comes close to a level, the line and label become visible again.

This feature is useful for traders who want the important levels available, but do not want every daily level displayed across the chart at all times.

## ATR and Tick-Based Approach Distance

The near-price logic can use a fixed tick distance and/or an ATR multiplier.

The tick distance gives a fixed market-based approach zone.
The ATR setting adjusts the approach distance based on current volatility.

Using both allows the indicator to adapt better across different instruments and market conditions.

## Custom Line Styles

Each major level type has its own style controls.

Users can adjust:

* Line style: solid, dashed, or dotted
* Line width
* Line color
* Label visibility
* Label size
* Line extension
* Left and right line length

This makes the indicator flexible for different chart layouts and personal visual preferences.

## Labels

The script includes optional labels for each level. Labels show the level name and price, such as:

PMH 1
PML 1
3H
3L
30H
30L
YH
YL
P
R1
S1

Labels can be turned on or off by category, allowing traders to keep the chart clean while still seeing the level names they care about.

## How Traders Can Use It

This indicator can be used as a daily level map for intraday trading.

Possible uses include:

* Watching reactions at premarket high and low
* Using 3-minute or 30-minute opening range levels as intraday reference areas
* Tracking whether price accepts or rejects yesterday’s high/low
* Watching daily pivot levels for possible support or resistance
* Keeping previous HOD/LOD levels visible as intraday structure
* Reducing clutter with the near-price auto display mode

A possible workflow is:

1. Load the indicator before the session begins.
2. Let the script automatically calculate premarket and opening range levels.
3. Watch how price behaves when it approaches a visible level.
4. Use the level as context, not as an automatic entry signal.
5. Combine the level with price action, volume, trend, and risk management.

## Important Notes

This script is a level-mapping tool, not an automatic buy or sell system.

A level appearing on the chart does not mean price must reverse there. Levels should be treated as areas of interest where traders can watch for reaction, rejection, breakout, retest, or continuation.

Daily levels and pivot levels are based on the prior daily candle data provided by TradingView for the selected symbol. For some instruments, especially futures, daily data may include extended-hours movement depending on the symbol and chart settings.

## Disclaimer

This indicator is for educational and informational purposes only. It is not financial advice, investment advice, or a guaranteed trading system. Trading involves risk, and every trader is responsible for their own decisions. Always use proper risk management.

## Source Code

````pine
//@version=5
indicator("GFG Daily Levels Auto by Agaam", overlay=true, max_lines_count=240, max_labels_count=240)

//=========================
// TIME SETTINGS
//=========================
groupTime = "Time Settings"

preMarketSession  = input.session("0400-0929", "Premarket Session", group=groupTime)
threeMinSession   = input.session("0930-0933", "3 Minute Opening Range Session", group=groupTime)
thirtyMinSession  = input.session("0930-1000", "30 Minute Opening Range Session", group=groupTime)
tradingDaySession = input.session("0930-1630", "Trading Day Session", group=groupTime)
sessionTZ         = input.string("America/New_York", "Session Timezone", group=groupTime)

//=========================
// AUTO NEAR PRICE SETTINGS
//=========================
groupNear = "Auto Near Price"

autoShowOnlyNearPrice  = input.bool(true, "Auto Show Only Near Price", group=groupNear)
approachDistanceTicks  = input.int(40, "Approach Distance Ticks", minval=1, maxval=10000, group=groupNear)
useAtrApproachDistance = input.bool(true, "Use ATR Approach Distance", group=groupNear)
atrLength              = input.int(14, "ATR Length", minval=1, maxval=200, group=groupNear)
approachAtrMultiplier  = input.float(0.50, "Approach ATR Multiplier", step=0.05, minval=0.01, maxval=10.0, group=groupNear)

//=========================
// VISIBILITY
//=========================
groupVis = "Visibility"

showPreMarketLevels      = input.bool(true, "Show Premarket High / Low", group=groupVis)
showSecondPreMarket      = input.bool(true, "Show PMH 2 / PML 2", group=groupVis)
premarketSeparationTicks = input.int(4, "PMH/PML 1-2 Separation Ticks", minval=1, maxval=500, group=groupVis)

showHodLodLevels         = input.bool(true, "Show HOD / LOD Previous Levels", group=groupVis)
showSecondHodLod         = input.bool(true, "Show HOD 2 / LOD 2", group=groupVis)
hodLodSeparationTicks    = input.int(4, "HOD/LOD 1-2 Separation Ticks", minval=1, maxval=500, group=groupVis)

show3MinRange            = input.bool(true, "Show 3 Minute Range", group=groupVis)
show3MinWhileForming     = input.bool(true, "Show 3 Minute Range While Forming", group=groupVis)

show30MinRange           = input.bool(true, "Show 30 Minute Range", group=groupVis)
show30MinWhileForming    = input.bool(true, "Show 30 Minute Range While Forming", group=groupVis)

showYesterdayLevels      = input.bool(true, "Show Yesterday High / Low", group=groupVis)
showDailyPivots          = input.bool(true, "Show Daily Support / Resistance", group=groupVis)

showLabels               = input.bool(true, "Show All Labels", group=groupVis)
showMainLabels           = input.bool(true, "Show Main Level Labels", group=groupVis)
showPremarketLabels      = input.bool(true, "Show Premarket Labels", group=groupVis)
showHodLodLabels         = input.bool(true, "Show HOD / LOD Labels", group=groupVis)
show3MinLabels           = input.bool(true, "Show 3 Minute Range Labels", group=groupVis)
show30MinLabels          = input.bool(true, "Show 30 Minute Range Labels", group=groupVis)

showPivotPoint           = input.bool(true, "Show Pivot Point", group=groupVis)
showR1S1                 = input.bool(true, "Show R1 / S1", group=groupVis)
showR2S2                 = input.bool(true, "Show R2 / S2", group=groupVis)
showR3S3                 = input.bool(true, "Show R3 / S3", group=groupVis)

//=========================
// STYLE
//=========================
groupStyle = "Style"

anchorLinesFromDay = input.bool(true, "Anchor Lines From Day Start", group=groupStyle)
lineLengthLeft     = input.int(100, "Line Length Left Bars", minval=1, maxval=5000, group=groupStyle)
lineLengthRight    = input.int(20, "Line Length Right Bars", minval=1, maxval=450, group=groupStyle)
extendRight        = input.bool(false, "Extend Lines Right", group=groupStyle)

labelGapAfterLine  = input.int(3, "Label Gap After Line Bars", minval=0, maxval=50, group=groupStyle)
labelSizeInput     = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=groupStyle)

labelSize = labelSizeInput == "Tiny" ? size.tiny : labelSizeInput == "Small" ? size.small : labelSizeInput == "Normal" ? size.normal : labelSizeInput == "Large" ? size.large : size.huge

//=========================
// INDIVIDUAL LINE STYLES + SIZES
//=========================
groupLine = "Every Line Style / Size"

pmh1Style = input.string("Dashed", "PMH 1 Style", options=["Solid", "Dashed", "Dotted"], group=groupLine)
pmh1Width = input.int(2, "PMH 1 Size", minval=1, maxval=5, group=groupLine)
pmh2Style = input.string("Dashed", "PMH 2 Style", options=["Solid", "Dashed", "Dotted"], group=groupLine)
pmh2Width = input.int(2, "PMH 2 Size", minval=1, maxval=5, group=groupLine)

pml1Style = input.string("Dashed", "PML 1 Style", options=["Solid", "Dashed", "Dotted"], group=groupLine)
pml1Width = input.int(2, "PML 1 Size", minval=1, maxval=5, group=groupLine)
pml2Style = input.string("Dashed", "PML 2 Style", options=["Solid", "Dashed", "Dotted"], group=groupLine)
pml2Width = input.int(2, "PML 2 Size", minval=1, maxval=5, group=groupLine)

threeHStyle = input.string("Dashed", "3H Style", options=["Solid", "Dashed", "Dotted"], group=groupLine)
threeHWidth = input.int(2, "3H Size", minval=1, maxval=5, group=groupLine)
threeLStyle = input.string("Dashed", "3L Style", options=["Solid", "Dashed", "Dotted"], group=groupLine)
threeLWidth = input.int(2, "3L Size", minval=1, maxval=5, group=groupLine)

thirtyHStyle = input.string("Dashed", "30H Style", options=["Solid", "Dashed", "Dotted"], group=groupLine)
thirtyHWidth = input.int(2, "30H Size", minval=1, maxval=5, group=groupLine)
thirtyLStyle = input.string("Dashed", "30L Style", options=["Solid", "Dashed", "Dotted"], group=groupLine)
thirtyLWidth = input.int(2, "30L Size", minval=1, maxval=5, group=groupLine)

yhStyle = input.string("Solid", "YH Style", options=["Solid", "Dashed", "Dotted"], group=groupLine)
yhWidth = input.int(2, "YH Size", minval=1, maxval=5, group=groupLine)
ylStyle = input.string("Solid", "YL Style", options=["Solid", "Dashed", "Dotted"], group=groupLine)
ylWidth = input.int(2, "YL Size", minval=1, maxval=5, group=groupLine)

hod1Style = input.string("Dotted", "HOD 1 Style", options=["Solid", "Dashed", "Dotted"], group=groupLine)
hod1Width = input.int(2, "HOD 1 Size", minval=1, maxval=5, group=groupLine)
hod2Style = input.string("Dotted", "HOD 2 Style", options=["Solid", "Dashed", "Dotted"], group=groupLine)
hod2Width = input.int(2, "HOD 2 Size", minval=1, maxval=5, group=groupLine)

lod1Style = input.string("Dotted", "LOD 1 Style", options=["Solid", "Dashed", "Dotted"], group=groupLine)
lod1Width = input.int(2, "LOD 1 Size", minval=1, maxval=5, group=groupLine)
lod2Style = input.string("Dotted", "LOD 2 Style", options=["Solid", "Dashed", "Dotted"], group=groupLine)
lod2Width = input.int(2, "LOD 2 Size", minval=1, maxval=5, group=groupLine)

pStyle = input.string("Dashed", "Pivot P Style", options=["Solid", "Dashed", "Dotted"], group=groupLine)
pWidth = input.int(2, "Pivot P Size", minval=1, maxval=5, group=groupLine)

r1Style = input.string("Solid", "R1 Style", options=["Solid", "Dashed", "Dotted"], group=groupLine)
r1Width = input.int(2, "R1 Size", minval=1, maxval=5, group=groupLine)
s1Style = input.string("Solid", "S1 Style", options=["Solid", "Dashed", "Dotted"], group=groupLine)
s1Width = input.int(2, "S1 Size", minval=1, maxval=5, group=groupLine)

r2Style = input.string("Dashed", "R2 Style", options=["Solid", "Dashed", "Dotted"], group=groupLine)
r2Width = input.int(2, "R2 Size", minval=1, maxval=5, group=groupLine)
s2Style = input.string("Dashed", "S2 Style", options=["Solid", "Dashed", "Dotted"], group=groupLine)
s2Width = input.int(2, "S2 Size", minval=1, maxval=5, group=groupLine)

r3Style = input.string("Dotted", "R3 Style", options=["Solid", "Dashed", "Dotted"], group=groupLine)
r3Width = input.int(2, "R3 Size", minval=1, maxval=5, group=groupLine)
s3Style = input.string("Dotted", "S3 Style", options=["Solid", "Dashed", "Dotted"], group=groupLine)
s3Width = input.int(2, "S3 Size", minval=1, maxval=5, group=groupLine)

//=========================
// COLORS
//=========================
groupColors = "Colors"

preMarketHighColor = input.color(#00FFFF, "Premarket High Color", group=groupColors)
preMarketLowColor  = input.color(#00FFFF, "Premarket Low Color", group=groupColors)

threeMinColor       = input.color(#FF00FF, "3 Minute Range Color", group=groupColors)
thirtyMinColor      = input.color(#FFD700, "30 Minute Range Color", group=groupColors)

yesterdayHighColor  = input.color(#FFD700, "Yesterday High Color", group=groupColors)
yesterdayLowColor   = input.color(#FFD700, "Yesterday Low Color", group=groupColors)

hodColor            = input.color(#00FF00, "HOD 1/2 Color", group=groupColors)
lodColor            = input.color(#CD5C5C, "LOD 1/2 Color", group=groupColors)

pivotColor          = input.color(#FFFFFF, "Pivot Color", group=groupColors)
resistanceColor     = input.color(#FFA500, "Resistance Color", group=groupColors)
supportColor        = input.color(#00FF00, "Support Color", group=groupColors)

transparentColor = #00000000

//=========================
// HELPERS
//=========================
f_line_style(_styleText) =>
    _styleText == "Solid" ? line.style_solid : _styleText == "Dashed" ? line.style_dashed : line.style_dotted

//=========================
// TIMEFRAME FILTERS
//=========================
// 3 minute opening range will only show on 3m, 5m, and 15m charts.
chartAllows3MinRange = timeframe.period == "3" or timeframe.period == "5" or timeframe.period == "15"

//=========================
// CORE DAILY VALUES
//=========================
newDay = ta.change(time("D")) != 0

var int dayStartIndex = na

var float currentDayHigh = na
var float currentDayLow = na

var float hod1 = na
var float hod2 = na
var float lod1 = na
var float lod2 = na

hodLodSep = hodLodSeparationTicks * syminfo.mintick

if barstate.isfirst or newDay
    dayStartIndex := bar_index
    currentDayHigh := high
    currentDayLow := low
    hod1 := na
    hod2 := na
    lod1 := na
    lod2 := na
else
    if high > currentDayHigh
        oldHigh = currentDayHigh
        if na(hod1)
            hod1 := oldHigh
        else if math.abs(oldHigh - hod1) >= hodLodSep
            hod2 := hod1
            hod1 := oldHigh
        currentDayHigh := high

    if low < currentDayLow
        oldLow = currentDayLow
        if na(lod1)
            lod1 := oldLow
        else if math.abs(oldLow - lod1) >= hodLodSep
            lod2 := lod1
            lod1 := oldLow
        currentDayLow := low

//=========================
// PREMARKET HIGH / LOW 1-2
//=========================
inPreMarket = not na(time(timeframe.period, preMarketSession, sessionTZ))
inTradingDay = not na(time(timeframe.period, tradingDaySession, sessionTZ))

preSep = premarketSeparationTicks * syminfo.mintick

var float preHigh1 = na
var float preHigh2 = na
var float preLow1 = na
var float preLow2 = na
var bool preStarted = false
var bool preLocked = false

if barstate.isfirst or newDay
    preHigh1 := na
    preHigh2 := na
    preLow1 := na
    preLow2 := na
    preStarted := false
    preLocked := false

if inPreMarket and not preLocked
    preStarted := true

    if na(preHigh1)
        preHigh1 := high
    else if high > preHigh1
        if high - preHigh1 >= preSep
            preHigh2 := preHigh1
            preHigh1 := high
        else
            preHigh1 := high
    else if high <= preHigh1 - preSep and (na(preHigh2) or high > preHigh2)
        preHigh2 := high

    if na(preLow1)
        preLow1 := low
    else if low < preLow1
        if preLow1 - low >= preSep
            preLow2 := preLow1
            preLow1 := low
        else
            preLow1 := low
    else if low >= preLow1 + preSep and (na(preLow2) or low < preLow2)
        preLow2 := low

if inTradingDay and preStarted and not preLocked
    preLocked := true

//=========================
// 3 MINUTE OPENING RANGE
//=========================
inThreeMinRange = not na(time(timeframe.period, threeMinSession, sessionTZ))

var float threeHigh = na
var float threeLow = na
var bool threeStarted = false
var bool threeLocked = false
var int threeStartIndex = na

if barstate.isfirst or newDay
    threeHigh := na
    threeLow := na
    threeStarted := false
    threeLocked := false
    threeStartIndex := na

if inThreeMinRange and not threeLocked
    if not threeStarted
        threeHigh := high
        threeLow := low
        threeStarted := true
        threeStartIndex := bar_index
    else
        threeHigh := math.max(threeHigh, high)
        threeLow := math.min(threeLow, low)

if inTradingDay and not inThreeMinRange and threeStarted and not threeLocked
    threeLocked := true

//=========================
// 30 MINUTE OPENING RANGE
//=========================
inThirtyMinRange = not na(time(timeframe.period, thirtyMinSession, sessionTZ))

var float thirtyHigh = na
var float thirtyLow = na
var bool thirtyStarted = false
var bool thirtyLocked = false
var int thirtyStartIndex = na

if barstate.isfirst or newDay
    thirtyHigh := na
    thirtyLow := na
    thirtyStarted := false
    thirtyLocked := false
    thirtyStartIndex := na

if inThirtyMinRange and not thirtyLocked
    if not thirtyStarted
        thirtyHigh := high
        thirtyLow := low
        thirtyStarted := true
        thirtyStartIndex := bar_index
    else
        thirtyHigh := math.max(thirtyHigh, high)
        thirtyLow := math.min(thirtyLow, low)

if inTradingDay and not inThirtyMinRange and thirtyStarted and not thirtyLocked
    thirtyLocked := true

//=========================
// YESTERDAY LEVELS
//=========================
yesterdayHigh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
yesterdayLow = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)
yesterdayClose = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)

//=========================
// DAILY PIVOT SUPPORT / RESISTANCE
//=========================
pivot = (yesterdayHigh + yesterdayLow + yesterdayClose) / 3.0

r1 = (2.0 * pivot) - yesterdayLow
s1 = (2.0 * pivot) - yesterdayHigh

r2 = pivot + (yesterdayHigh - yesterdayLow)
s2 = pivot - (yesterdayHigh - yesterdayLow)

r3 = yesterdayHigh + 2.0 * (pivot - yesterdayLow)
s3 = yesterdayLow - 2.0 * (yesterdayHigh - pivot)

//=========================
// AUTO NEAR PRICE LOGIC
//=========================
atrValue = ta.atr(atrLength)

f_price_near_level(_levelPrice) =>
    if not autoShowOnlyNearPrice
        true
    else if na(_levelPrice)
        false
    else
        touchedLevel = low <= _levelPrice and high >= _levelPrice
        tickDistance = approachDistanceTicks * syminfo.mintick
        atrDistance = useAtrApproachDistance ? atrValue * approachAtrMultiplier : 0.0
        allowedDistance = math.max(tickDistance, atrDistance)
        allowedDistance := allowedDistance <= 0.0 ? syminfo.mintick : allowedDistance
        closeDistance = math.abs(close - _levelPrice)
        highDistance = math.abs(high - _levelPrice)
        lowDistance = math.abs(low - _levelPrice)
        nearestDistance = math.min(closeDistance, math.min(highDistance, lowDistance))
        touchedLevel or nearestDistance <= allowedDistance

//=========================
// OBJECT HELPERS
//=========================
f_create_line() =>
    line.new(x1=bar_index, y1=close, x2=bar_index + 1, y2=close, xloc=xloc.bar_index, extend=extend.none, color=transparentColor, width=1)

f_create_label() =>
    label.new(x=bar_index, y=close, text="", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=transparentColor, textcolor=transparentColor, size=labelSize)

f_update_level(_ln, _lb, _enabled, _showThisLabel, _name, _price, _col, _style, _width, _useNearFilter, _anchorIndex) =>
    showNow = _enabled and not na(_price) and (_useNearFilter ? f_price_near_level(_price) : true)
    leftByAnchor = anchorLinesFromDay and not na(_anchorIndex) ? _anchorIndex : math.max(bar_index - lineLengthLeft, 0)
    x1 = leftByAnchor
    x2 = bar_index + lineLengthRight
    labelX = x2 + labelGapAfterLine

    if showNow
        line.set_xy1(_ln, x1, _price)
        line.set_xy2(_ln, x2, _price)
        line.set_color(_ln, _col)
        line.set_width(_ln, _width)
        line.set_style(_ln, _style)
        line.set_extend(_ln, extendRight ? extend.right : extend.none)

        if _showThisLabel
            label.set_x(_lb, labelX)
            label.set_y(_lb, _price)
            label.set_text(_lb, _name + "  " + str.tostring(_price, format.mintick))
            label.set_textcolor(_lb, _col)
            label.set_color(_lb, transparentColor)
            label.set_size(_lb, labelSize)
            label.set_style(_lb, label.style_label_left)
        else
            label.set_text(_lb, "")
            label.set_textcolor(_lb, transparentColor)
    else
        line.set_color(_ln, transparentColor)
        line.set_extend(_ln, extend.none)
        label.set_text(_lb, "")
        label.set_textcolor(_lb, transparentColor)

//=========================
// CREATE OBJECTS ONCE
//=========================
var line pmh1Line = na
var line pmh2Line = na
var line pml1Line = na
var line pml2Line = na

var line threeHighLine = na
var line threeLowLine = na
var line thirtyHighLine = na
var line thirtyLowLine = na

var line yhLine = na
var line ylLine = na
var line hod1Line = na
var line hod2Line = na
var line lod1Line = na
var line lod2Line = na
var line pLine = na
var line r1Line = na
var line s1Line = na
var line r2Line = na
var line s2Line = na
var line r3Line = na
var line s3Line = na

var label pmh1Label = na
var label pmh2Label = na
var label pml1Label = na
var label pml2Label = na

var label threeHighLabel = na
var label threeLowLabel = na
var label thirtyHighLabel = na
var label thirtyLowLabel = na

var label yhLabel = na
var label ylLabel = na
var label hod1Label = na
var label hod2Label = na
var label lod1Label = na
var label lod2Label = na
var label pLabel = na
var label r1Label = na
var label s1Label = na
var label r2Label = na
var label s2Label = na
var label r3Label = na
var label s3Label = na

if barstate.isfirst
    pmh1Line := f_create_line()
    pmh2Line := f_create_line()
    pml1Line := f_create_line()
    pml2Line := f_create_line()

    threeHighLine := f_create_line()
    threeLowLine := f_create_line()
    thirtyHighLine := f_create_line()
    thirtyLowLine := f_create_line()

    yhLine := f_create_line()
    ylLine := f_create_line()
    hod1Line := f_create_line()
    hod2Line := f_create_line()
    lod1Line := f_create_line()
    lod2Line := f_create_line()
    pLine := f_create_line()
    r1Line := f_create_line()
    s1Line := f_create_line()
    r2Line := f_create_line()
    s2Line := f_create_line()
    r3Line := f_create_line()
    s3Line := f_create_line()

    pmh1Label := f_create_label()
    pmh2Label := f_create_label()
    pml1Label := f_create_label()
    pml2Label := f_create_label()

    threeHighLabel := f_create_label()
    threeLowLabel := f_create_label()
    thirtyHighLabel := f_create_label()
    thirtyLowLabel := f_create_label()

    yhLabel := f_create_label()
    ylLabel := f_create_label()
    hod1Label := f_create_label()
    hod2Label := f_create_label()
    lod1Label := f_create_label()
    lod2Label := f_create_label()
    pLabel := f_create_label()
    r1Label := f_create_label()
    s1Label := f_create_label()
    r2Label := f_create_label()
    s2Label := f_create_label()
    r3Label := f_create_label()
    s3Label := f_create_label()

//=========================
// LABEL SWITCHES
//=========================
mainLabelOn = showLabels and showMainLabels
preLabelOn = showLabels and showPremarketLabels
hodLodLabelOn = showLabels and showHodLodLabels
threeLabelOn = showLabels and show3MinLabels
thirtyLabelOn = showLabels and show30MinLabels

//=========================
// UPDATE LEVELS
//=========================
showPremarketNow = showPreMarketLevels and inTradingDay and preLocked

f_update_level(pmh1Line, pmh1Label, showPremarketNow, preLabelOn, "PMH 1", preHigh1, preMarketHighColor, f_line_style(pmh1Style), pmh1Width, true, dayStartIndex)
f_update_level(pmh2Line, pmh2Label, showPremarketNow and showSecondPreMarket, preLabelOn, "PMH 2", preHigh2, preMarketHighColor, f_line_style(pmh2Style), pmh2Width, true, dayStartIndex)
f_update_level(pml1Line, pml1Label, showPremarketNow, preLabelOn, "PML 1", preLow1, preMarketLowColor, f_line_style(pml1Style), pml1Width, true, dayStartIndex)
f_update_level(pml2Line, pml2Label, showPremarketNow and showSecondPreMarket, preLabelOn, "PML 2", preLow2, preMarketLowColor, f_line_style(pml2Style), pml2Width, true, dayStartIndex)

showThreeNow = chartAllows3MinRange and show3MinRange and inTradingDay and threeStarted and (show3MinWhileForming or threeLocked)
f_update_level(threeHighLine, threeHighLabel, showThreeNow, threeLabelOn, "3H", threeHigh, threeMinColor, f_line_style(threeHStyle), threeHWidth, false, threeStartIndex)
f_update_level(threeLowLine, threeLowLabel, showThreeNow, threeLabelOn, "3L", threeLow, threeMinColor, f_line_style(threeLStyle), threeLWidth, false, threeStartIndex)

showThirtyNow = show30MinRange and inTradingDay and thirtyStarted and (show30MinWhileForming or thirtyLocked)
f_update_level(thirtyHighLine, thirtyHighLabel, showThirtyNow, thirtyLabelOn, "30H", thirtyHigh, thirtyMinColor, f_line_style(thirtyHStyle), thirtyHWidth, false, thirtyStartIndex)
f_update_level(thirtyLowLine, thirtyLowLabel, showThirtyNow, thirtyLabelOn, "30L", thirtyLow, thirtyMinColor, f_line_style(thirtyLStyle), thirtyLWidth, false, thirtyStartIndex)

f_update_level(yhLine, yhLabel, showYesterdayLevels, mainLabelOn, "YH", yesterdayHigh, yesterdayHighColor, f_line_style(yhStyle), yhWidth, true, dayStartIndex)
f_update_level(ylLine, ylLabel, showYesterdayLevels, mainLabelOn, "YL", yesterdayLow, yesterdayLowColor, f_line_style(ylStyle), ylWidth, true, dayStartIndex)

f_update_level(hod1Line, hod1Label, showHodLodLevels, hodLodLabelOn, "HOD 1", hod1, hodColor, f_line_style(hod1Style), hod1Width, true, dayStartIndex)
f_update_level(hod2Line, hod2Label, showHodLodLevels and showSecondHodLod, hodLodLabelOn, "HOD 2", hod2, hodColor, f_line_style(hod2Style), hod2Width, true, dayStartIndex)
f_update_level(lod1Line, lod1Label, showHodLodLevels, hodLodLabelOn, "LOD 1", lod1, lodColor, f_line_style(lod1Style), lod1Width, true, dayStartIndex)
f_update_level(lod2Line, lod2Label, showHodLodLevels and showSecondHodLod, hodLodLabelOn, "LOD 2", lod2, lodColor, f_line_style(lod2Style), lod2Width, true, dayStartIndex)

f_update_level(pLine, pLabel, showDailyPivots and showPivotPoint, mainLabelOn, "P", pivot, pivotColor, f_line_style(pStyle), pWidth, true, dayStartIndex)

f_update_level(r1Line, r1Label, showDailyPivots and showR1S1, mainLabelOn, "R1", r1, resistanceColor, f_line_style(r1Style), r1Width, true, dayStartIndex)
f_update_level(s1Line, s1Label, showDailyPivots and showR1S1, mainLabelOn, "S1", s1, supportColor, f_line_style(s1Style), s1Width, true, dayStartIndex)

f_update_level(r2Line, r2Label, showDailyPivots and showR2S2, mainLabelOn, "R2", r2, resistanceColor, f_line_style(r2Style), r2Width, true, dayStartIndex)
f_update_level(s2Line, s2Label, showDailyPivots and showR2S2, mainLabelOn, "S2", s2, supportColor, f_line_style(s2Style), s2Width, true, dayStartIndex)

f_update_level(r3Line, r3Label, showDailyPivots and showR3S3, mainLabelOn, "R3", r3, resistanceColor, f_line_style(r3Style), r3Width, true, dayStartIndex)
f_update_level(s3Line, s3Label, showDailyPivots and showR3S3, mainLabelOn, "S3", s3, supportColor, f_line_style(s3Style), s3Width, true, dayStartIndex)
````
