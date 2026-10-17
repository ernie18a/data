# Marks Key Times + Order Blocks + EQH/EQL

- url: https://www.tradingview.com/script/FJwRzZhR-Marks-Key-Times-Order-Blocks-EQH-EQL/
- type: indicator
- pine_id: PUB;0131f678a14b49538174d8ae6e9b4375
- version: 1.0

## Description

Step 1 – Define the Three Key Times



Your script is set to mark these three moments every day (timezone = America/New_York):



· 2:00 AM – Early Asian/late US session transition.

· 5:00 AM – Just before London open, often sees liquidity sweeps.

· 10:30 AM – Mid‑morning in US, after the first hour of cash equities.



At each of these times, the script draws:



· A horizontal line at the opening price of that minute (extended 50 bars forward).

· A vertical line through the high/low of that minute.

· A text label (e.g., “2:00 AM”) on the horizontal line.



You use these visual markers to quickly see “entry windows” on your chart.



Step 2 – Identify Order Blocks (Institutional Zones)



Your script finds two types of order blocks automatically:



· Swing Order Blocks (longer‑term, 50‑bar swing length) – major reversal zones.

· Internal Order Blocks (shorter‑term, 5‑bar internal length) – micro pivot zones.



It draws colored boxes behind price:



· Green/blue boxes = Bullish order blocks (buy zone).

· Red/pink boxes = Bearish order blocks (sell zone).



An order block is a price range where institutions previously placed large orders. You wait for price to return to that box.



Step 3 – The Entry Rule (Time + Order Block)



You only enter a trade when price is inside an order block AND the current time is one of your three key times (2:00 AM, 5:00 AM, or 10:30 AM).

## Source Code

````pine
//@version=6
indicator("Marks Key Times + Order Blocks + EQH/EQL", "Marks OB + Key Times + EQH/EQL", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TIMEFRAME PROTECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if timeframe.in_seconds(timeframe.period) >= 86400
    runtime.error("This indicator is for intraday timeframes only.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CONSTANTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BULLISH_LEG = 1
BEARISH_LEG = 0

BULLISH = 1
BEARISH = -1

GREEN = #089981
RED   = #F23645

HISTORICAL = "Historical"
PRESENT    = "Present"

ATR   = "Atr"
RANGE = "Cumulative Mean Range"

CLOSE   = "Close"
HIGHLOW = "High/Low"

TINY_SIZE   = size.tiny
SMALL_SIZE  = size.small
NORMAL_SIZE = size.normal

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// KEY TIME INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupTimes = "Key Times"

useTime1 = input.bool(true, "Show Time 1", group=groupTimes)
hour1    = input.int(10, "Hour", minval=0, maxval=23, group=groupTimes, inline="t1")
min1     = input.int(30, "Minute", minval=0, maxval=59, group=groupTimes, inline="t1")
text1    = input.string("10:30 AM", "Label", group=groupTimes)

useTime2 = input.bool(true, "Show Time 2", group=groupTimes)
hour2    = input.int(14, "Hour", minval=0, maxval=23, group=groupTimes, inline="t2")
min2     = input.int(0, "Minute", minval=0, maxval=59, group=groupTimes, inline="t2")
text2    = input.string("2:00 PM", "Label", group=groupTimes)

useTime3 = input.bool(true, "Show Time 3", group=groupTimes)
hour3    = input.int(17, "Hour", minval=0, maxval=23, group=groupTimes, inline="t3")
min3     = input.int(0, "Minute", minval=0, maxval=59, group=groupTimes, inline="t3")
text3    = input.string("5:00 PM", "Label", group=groupTimes)

groupTimeStyle = "Key Time Style"

showOpeningPrice = input.bool(true, "Show Opening Price Line", group=groupTimeStyle)
showVerticalLine = input.bool(true, "Show Vertical Line", group=groupTimeStyle)
showTimeLabels   = input.bool(true, "Show Time Labels", group=groupTimeStyle)

timeLineColor = input.color(color.rgb(255, 255, 255), "Line Color", group=groupTimeStyle)
timeLineWidth = input.int(1, "Line Width", minval=1, maxval=5, group=groupTimeStyle)

timeLineStyleInput = input.string("Dotted", "Line Style", options=["Solid", "Dashed", "Dotted"], group=groupTimeStyle)
timeLabelSizeInput = input.string("Normal", "Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=groupTimeStyle)

extendBars = input.int(50, "Opening Price Line Extension Bars", minval=1, group=groupTimeStyle)

groupHistory = "Key Time History"
keepHistorical = input.bool(true, "Keep Previous Days", group=groupHistory)
maxSessions    = input.int(20, "Max Historical Sessions", minval=1, maxval=200, group=groupHistory)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ORDER BLOCK INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MODE_GROUP = "Mode"
OB_GROUP   = "Order Blocks"
EQ_GROUP   = "EQH/EQL"

modeInput = input.string(HISTORICAL, "Mode", group=MODE_GROUP, options=[HISTORICAL, PRESENT], tooltip="Historical keeps past EQH/EQL markings. Present only keeps the most recent EQH/EQL.")

showInternalOrderBlocksInput = input.bool(true, "Internal Order Blocks", group=OB_GROUP, inline="iob")
internalOrderBlocksSizeInput = input.int(5, "", group=OB_GROUP, minval=1, maxval=20, inline="iob")

showSwingOrderBlocksInput = input.bool(false, "Swing Order Blocks", group=OB_GROUP, inline="ob")
swingOrderBlocksSizeInput = input.int(5, "", group=OB_GROUP, minval=1, maxval=20, inline="ob")

swingsLengthInput   = input.int(50, "Swing Length", group=OB_GROUP, minval=10)
internalLengthInput = input.int(5, "Internal Length", group=OB_GROUP, minval=2)

orderBlockFilterInput     = input.string(ATR, "Order Block Filter", group=OB_GROUP, options=[ATR, RANGE])
orderBlockMitigationInput = input.string(HIGHLOW, "Order Block Mitigation", group=OB_GROUP, options=[CLOSE, HIGHLOW])

internalBullishOrderBlockColor = input.color(color.new(#3179f5, 80), "Internal Bullish OB", group=OB_GROUP)
internalBearishOrderBlockColor = input.color(color.new(#f77c80, 80), "Internal Bearish OB", group=OB_GROUP)
swingBullishOrderBlockColor    = input.color(color.new(#1848cc, 80), "Swing Bullish OB", group=OB_GROUP)
swingBearishOrderBlockColor    = input.color(color.new(#b22833, 80), "Swing Bearish OB", group=OB_GROUP)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EQH / EQL INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showEqualHighsLowsInput      = input.bool(true, "Equal High/Low", group=EQ_GROUP)
equalHighsLowsLengthInput    = input.int(3, "Bars Confirmation", group=EQ_GROUP, minval=1)
equalHighsLowsThresholdInput = input.float(0.1, "Threshold", group=EQ_GROUP, minval=0, maxval=0.5, step=0.1)
equalHighsLowsSizeInput      = input.string(TINY_SIZE, "Label Size", group=EQ_GROUP, options=[TINY_SIZE, SMALL_SIZE, NORMAL_SIZE])
eqhColorInput                = input.color(RED, "EQH Color", group=EQ_GROUP)
eqlColorInput                = input.color(GREEN, "EQL Color", group=EQ_GROUP)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TYPES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
type alerts
    bool internalBullishOrderBlock = false
    bool internalBearishOrderBlock = false
    bool swingBullishOrderBlock = false
    bool swingBearishOrderBlock = false
    bool equalHighs = false
    bool equalLows = false

type trend
    int bias

type equalDisplay
    line l_ine = na
    label l_abel = na

type pivot
    float currentLevel
    float lastLevel
    bool crossed
    int barTime = time
    int barIndex = bar_index

type orderBlock
    float barHigh
    float barLow
    int barTime
    int bias

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VARIABLES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var pivot swingHigh   = pivot.new(na, na, false)
var pivot swingLow    = pivot.new(na, na, false)
var pivot internalHigh = pivot.new(na, na, false)
var pivot internalLow  = pivot.new(na, na, false)
var pivot equalHigh    = pivot.new(na, na, false)
var pivot equalLow     = pivot.new(na, na, false)

var trend swingTrend    = trend.new(0)
var trend internalTrend = trend.new(0)

var equalDisplay equalHighDisplay = equalDisplay.new()
var equalDisplay equalLowDisplay  = equalDisplay.new()

var array<float> parsedHighs = array.new<float>()
var array<float> parsedLows  = array.new<float>()
var array<int> times         = array.new<int>()

var array<orderBlock> swingOrderBlocks    = array.new<orderBlock>()
var array<orderBlock> internalOrderBlocks = array.new<orderBlock>()

var array<box> swingOrderBlocksBoxes    = array.new<box>()
var array<box> internalOrderBlocksBoxes = array.new<box>()

alerts currentAlerts = alerts.new()

// Key Time Storage
var line[]  keyHLineArray = array.new_line()
var line[]  keyVLineArray = array.new_line()
var label[] keyLabelArray = array.new_label()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// KEY TIME HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
getTimeLineStyle(styleText) =>
    switch styleText
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted

getTimeLabelSize(sizeText) =>
    switch sizeText
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge

plotKeyTime(_enabled, _hour, _minute, _text) =>
    isKeyTime = hour(time, "America/New_York") == _hour and minute(time, "America/New_York") == _minute

    if _enabled and isKeyTime and barstate.isconfirmed
        futureX = bar_index + extendBars

        if showOpeningPrice
            h = line.new(
                 x1=bar_index,
                 y1=open,
                 x2=futureX,
                 y2=open,
                 xloc=xloc.bar_index,
                 extend=extend.none,
                 color=timeLineColor,
                 style=getTimeLineStyle(timeLineStyleInput),
                 width=timeLineWidth
            )
            array.push(keyHLineArray, h)

        if showVerticalLine
            v = line.new(
                 x1=bar_index,
                 y1=high,
                 x2=bar_index,
                 y2=low,
                 xloc=xloc.bar_index,
                 extend=extend.both,
                 color=timeLineColor,
                 style=getTimeLineStyle(timeLineStyleInput),
                 width=timeLineWidth
            )
            array.push(keyVLineArray, v)

        if showTimeLabels and showOpeningPrice
            lbl = label.new(
                 x=futureX,
                 y=open,
                 text=_text,
                 xloc=xloc.bar_index,
                 yloc=yloc.price,
                 style=label.style_label_left,
                 textcolor=timeLineColor,
                 color=color.new(color.white, 100),
                 size=getTimeLabelSize(timeLabelSizeInput)
            )
            array.push(keyLabelArray, lbl)

manageKeyTimeObjects() =>
    if not keepHistorical
        if array.size(keyHLineArray) > 3
            oldH = array.shift(keyHLineArray)
            line.delete(oldH)

        if array.size(keyVLineArray) > 3
            oldV = array.shift(keyVLineArray)
            line.delete(oldV)

        if array.size(keyLabelArray) > 3
            oldLbl = array.shift(keyLabelArray)
            label.delete(oldLbl)

    if keepHistorical
        if array.size(keyHLineArray) > maxSessions * 3
            oldH = array.shift(keyHLineArray)
            line.delete(oldH)

        if array.size(keyVLineArray) > maxSessions * 3
            oldV = array.shift(keyVLineArray)
            line.delete(oldV)

        if array.size(keyLabelArray) > maxSessions * 3
            oldLbl = array.shift(keyLabelArray)
            label.delete(oldLbl)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ORDER BLOCK BOX SETUP
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if barstate.isfirst
    if showSwingOrderBlocksInput
        for i = 1 to swingOrderBlocksSizeInput
            array.push(swingOrderBlocksBoxes, box.new(na, na, na, na, xloc=xloc.bar_time, extend=extend.right))

    if showInternalOrderBlocksInput
        for i = 1 to internalOrderBlocksSizeInput
            array.push(internalOrderBlocksBoxes, box.new(na, na, na, na, xloc=xloc.bar_time, extend=extend.right))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VOLATILITY FILTER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
atrMeasure        = ta.atr(200)
volatilityMeasure = orderBlockFilterInput == ATR ? atrMeasure : ta.cum(ta.tr) / math.max(bar_index, 1)

highVolatilityBar = (high - low) >= 2 * volatilityMeasure

parsedHigh = highVolatilityBar ? low : high
parsedLow  = highVolatilityBar ? high : low

array.push(parsedHighs, parsedHigh)
array.push(parsedLows, parsedLow)
array.push(times, time)

bearishOrderBlockMitigationSource = orderBlockMitigationInput == CLOSE ? close : high
bullishOrderBlockMitigationSource = orderBlockMitigationInput == CLOSE ? close : low

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ORDER BLOCK / EQH FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
leg(int size) =>
    var int legValue = 0
    newLegHigh = high[size] > ta.highest(high, size)
    newLegLow  = low[size] < ta.lowest(low, size)

    if newLegHigh
        legValue := BEARISH_LEG
    else if newLegLow
        legValue := BULLISH_LEG

    legValue

startOfNewLeg(int legValue) =>
    ta.change(legValue) != 0

startOfBearishLeg(int legValue) =>
    ta.change(legValue) == -1

startOfBullishLeg(int legValue) =>
    ta.change(legValue) == 1

drawEqualHighLow(pivot p_ivot, float level, int size, bool isEqualHigh) =>
    equalDisplay e_qualDisplay = isEqualHigh ? equalHighDisplay : equalLowDisplay

    tag        = isEqualHigh ? "EQH" : "EQL"
    equalColor = isEqualHigh ? eqhColorInput : eqlColorInput
    labelStyle = isEqualHigh ? label.style_label_down : label.style_label_up

    if modeInput == PRESENT
        line.delete(e_qualDisplay.l_ine)
        label.delete(e_qualDisplay.l_abel)

    e_qualDisplay.l_ine := line.new(
         chart.point.new(p_ivot.barTime, na, p_ivot.currentLevel),
         chart.point.new(time[size], na, level),
         xloc=xloc.bar_time,
         color=equalColor,
         style=line.style_dotted
    )

    labelPosition = math.round(0.5 * (p_ivot.barIndex + bar_index - size))

    e_qualDisplay.l_abel := label.new(
         chart.point.new(na, labelPosition, level),
         tag,
         xloc=xloc.bar_index,
         color=color.new(color.white, 100),
         textcolor=equalColor,
         style=labelStyle,
         size=equalHighsLowsSizeInput
    )

getCurrentStructure(int size, bool equalHighLow, bool internal) =>
    currentLeg = leg(size)
    newPivot   = startOfNewLeg(currentLeg)
    pivotLow   = startOfBullishLeg(currentLeg)
    pivotHigh  = startOfBearishLeg(currentLeg)

    if newPivot
        if pivotLow
            pivot p_ivot = equalHighLow ? equalLow : internal ? internalLow : swingLow

            if equalHighLow and not na(p_ivot.currentLevel) and math.abs(p_ivot.currentLevel - low[size]) < equalHighsLowsThresholdInput * atrMeasure
                drawEqualHighLow(p_ivot, low[size], size, false)
                currentAlerts.equalLows := true

            p_ivot.lastLevel    := p_ivot.currentLevel
            p_ivot.currentLevel := low[size]
            p_ivot.crossed      := false
            p_ivot.barTime      := time[size]
            p_ivot.barIndex     := bar_index[size]

        if pivotHigh
            pivot p_ivot = equalHighLow ? equalHigh : internal ? internalHigh : swingHigh

            if equalHighLow and not na(p_ivot.currentLevel) and math.abs(p_ivot.currentLevel - high[size]) < equalHighsLowsThresholdInput * atrMeasure
                drawEqualHighLow(p_ivot, high[size], size, true)
                currentAlerts.equalHighs := true

            p_ivot.lastLevel    := p_ivot.currentLevel
            p_ivot.currentLevel := high[size]
            p_ivot.crossed      := false
            p_ivot.barTime      := time[size]
            p_ivot.barIndex     := bar_index[size]

storeOrderBlock(pivot p_ivot, bool internal, int bias) =>
    if (not internal and showSwingOrderBlocksInput) or (internal and showInternalOrderBlocksInput)
        array<float> priceArray = na
        int parsedIndex = na

        if bias == BEARISH
            priceArray := array.slice(parsedHighs, p_ivot.barIndex, bar_index)
            parsedIndex := p_ivot.barIndex + array.indexof(priceArray, array.max(priceArray))
        else
            priceArray := array.slice(parsedLows, p_ivot.barIndex, bar_index)
            parsedIndex := p_ivot.barIndex + array.indexof(priceArray, array.min(priceArray))

        if not na(parsedIndex) and parsedIndex >= 0 and parsedIndex < array.size(parsedHighs)
            newOrderBlock = orderBlock.new(array.get(parsedHighs, parsedIndex), array.get(parsedLows, parsedIndex), array.get(times, parsedIndex), bias)

            array<orderBlock> orderBlocks = internal ? internalOrderBlocks : swingOrderBlocks

            if array.size(orderBlocks) >= 100
                array.pop(orderBlocks)

            array.unshift(orderBlocks, newOrderBlock)

deleteOrderBlocks(bool internal) =>
    array<orderBlock> orderBlocks = internal ? internalOrderBlocks : swingOrderBlocks

    if array.size(orderBlocks) > 0
        for i = array.size(orderBlocks) - 1 to 0
            eachOrderBlock = array.get(orderBlocks, i)
            crossedOrderBlock = false

            if bearishOrderBlockMitigationSource > eachOrderBlock.barHigh and eachOrderBlock.bias == BEARISH
                crossedOrderBlock := true
                if internal
                    currentAlerts.internalBearishOrderBlock := true
                else
                    currentAlerts.swingBearishOrderBlock := true

            if bullishOrderBlockMitigationSource < eachOrderBlock.barLow and eachOrderBlock.bias == BULLISH
                crossedOrderBlock := true
                if internal
                    currentAlerts.internalBullishOrderBlock := true
                else
                    currentAlerts.swingBullishOrderBlock := true

            if crossedOrderBlock
                array.remove(orderBlocks, i)

detectOrderBlockStructure(bool internal) =>
    pivot highPivot = internal ? internalHigh : swingHigh
    trend activeTrend = internal ? internalTrend : swingTrend

    extraBullishCondition = internal ? internalHigh.currentLevel != swingHigh.currentLevel : true

    if not na(highPivot.currentLevel) and ta.crossover(close, highPivot.currentLevel) and not highPivot.crossed and extraBullishCondition
        highPivot.crossed := true
        activeTrend.bias := BULLISH
        storeOrderBlock(highPivot, internal, BULLISH)

    pivot lowPivot = internal ? internalLow : swingLow
    extraBearishCondition = internal ? internalLow.currentLevel != swingLow.currentLevel : true

    if not na(lowPivot.currentLevel) and ta.crossunder(close, lowPivot.currentLevel) and not lowPivot.crossed and extraBearishCondition
        lowPivot.crossed := true
        activeTrend.bias := BEARISH
        storeOrderBlock(lowPivot, internal, BEARISH)

drawOrderBlocks(bool internal) =>
    array<orderBlock> orderBlocks = internal ? internalOrderBlocks : swingOrderBlocks
    array<box> boxes = internal ? internalOrderBlocksBoxes : swingOrderBlocksBoxes

    orderBlocksSize = array.size(orderBlocks)

    if orderBlocksSize > 0 and array.size(boxes) > 0
        maxOrderBlocks = internal ? internalOrderBlocksSizeInput : swingOrderBlocksSizeInput
        drawCount = math.min(maxOrderBlocks, orderBlocksSize)

        for i = 0 to drawCount - 1
            eachOrderBlock = array.get(orderBlocks, i)

            orderBlockColor = internal ? eachOrderBlock.bias == BEARISH ? internalBearishOrderBlockColor : internalBullishOrderBlockColor : eachOrderBlock.bias == BEARISH ? swingBearishOrderBlockColor : swingBullishOrderBlockColor

            currentBox = array.get(boxes, i)

            currentBox.set_top_left_point(chart.point.new(eachOrderBlock.barTime, na, eachOrderBlock.barHigh))
            currentBox.set_bottom_right_point(chart.point.new(last_bar_time, na, eachOrderBlock.barLow))
            currentBox.set_border_color(internal ? color.new(orderBlockColor, 100) : orderBlockColor)
            currentBox.set_bgcolor(orderBlockColor)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EXECUTION — KEY TIMES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plotKeyTime(useTime1, hour1, min1, text1)
plotKeyTime(useTime2, hour2, min2, text2)
plotKeyTime(useTime3, hour3, min3, text3)
manageKeyTimeObjects()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EXECUTION — ORDER BLOCKS / EQH / EQL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
getCurrentStructure(swingsLengthInput, false, false)
getCurrentStructure(internalLengthInput, false, true)

if showEqualHighsLowsInput
    getCurrentStructure(equalHighsLowsLengthInput, true, false)

if showInternalOrderBlocksInput
    detectOrderBlockStructure(true)
    deleteOrderBlocks(true)

if showSwingOrderBlocksInput
    detectOrderBlockStructure(false)
    deleteOrderBlocks(false)

if barstate.islastconfirmedhistory or barstate.islast
    if showInternalOrderBlocksInput
        drawOrderBlocks(true)

    if showSwingOrderBlocksInput
        drawOrderBlocks(false)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(currentAlerts.internalBullishOrderBlock, "Bullish Internal OB Breakout", "Price broke bullish internal OB")
alertcondition(currentAlerts.internalBearishOrderBlock, "Bearish Internal OB Breakout", "Price broke bearish internal OB")
alertcondition(currentAlerts.swingBullishOrderBlock, "Bullish Swing OB Breakout", "Price broke bullish swing OB")
alertcondition(currentAlerts.swingBearishOrderBlock, "Bearish Swing OB Breakout", "Price broke bearish swing OB")
alertcondition(currentAlerts.equalHighs, "Equal Highs", "Equal highs detected")
alertcondition(currentAlerts.equalLows, "Equal Lows", "Equal lows detected")
````
