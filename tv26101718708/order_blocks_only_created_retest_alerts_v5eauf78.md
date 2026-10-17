# Order Blocks Only + Created & Retest Alerts

- url: https://www.tradingview.com/script/v5EaUF78-order-blocks-only-created-retest-alerts/
- type: indicator
- pine_id: PUB;78b34f95322444cc8b5a444041db5d04
- version: 1.0

## Description

Order Blocks Only + Retest Alerts

This indicator focuses exclusively on Smart Money Concept Order Blocks using the original LuxAlgo logic.

Features
Bullish and Bearish Order Blocks
Internal and Swing Order Blocks
Automatic mitigation/removal of broken OBs
Volatility filtering (ATR or Cumulative Range)
Real-time Order Block visualization
Separate alerts for:
Long OB Created
Short OB Created
Long OB Retest
Short OB Retest
Retest Logic

A retest is confirmed when:

Price enters the Order Block zone
Price does NOT close beyond the opposite side of the OB
Price rejects the zone and moves back in the expected direction
Long OB Retest
Price returns into a bullish OB
Candle does not close below the OB
Price moves back upward
Short OB Retest
Price returns into a bearish OB
Candle does not close above the OB
Price moves back downward
Alerts Included
Long OB Created
Short OB Created
Long OB Retest
Short OB Retest

Built for traders using Smart Money Concepts (SMC), liquidity, BOS/CHOCH-based Order Blocks, and institutional price action.

## Source Code

````pine
//@version=5
indicator("Order Blocks Only + Created & Retest Alerts", overlay = true, max_boxes_count = 500)

//---------------------------------------------------------------------------------------------------------------------
// CONSTANTS
//---------------------------------------------------------------------------------------------------------------------
BULLISH_LEG = 1
BEARISH_LEG = 0

BULLISH = 1
BEARISH = -1

ATR   = 'Atr'
RANGE = 'Cumulative Mean Range'

CLOSE   = 'Close'
HIGHLOW = 'High/Low'

//---------------------------------------------------------------------------------------------------------------------
// INPUTS
//---------------------------------------------------------------------------------------------------------------------
showInternalOrderBlocksInput = input(true, "Internal Order Blocks")
internalOrderBlocksSizeInput = input.int(5, "", minval = 1, maxval = 20)

showSwingOrderBlocksInput = input(true, "Swing Order Blocks")
swingOrderBlocksSizeInput = input.int(5, "", minval = 1, maxval = 20)

orderBlockFilterInput = input.string(ATR, "Order Block Filter", options = [ATR, RANGE])
orderBlockMitigationInput = input.string(HIGHLOW, "Order Block Mitigation", options = [CLOSE, HIGHLOW])

internalBullishOrderBlockColor = input.color(color.new(#3179f5, 80), 'Internal Bullish OB')
internalBearishOrderBlockColor = input.color(color.new(#f77c80, 80), 'Internal Bearish OB')

swingBullishOrderBlockColor = input.color(color.new(#1848cc, 80), 'Bullish OB')
swingBearishOrderBlockColor = input.color(color.new(#b22833, 80), 'Bearish OB')

//---------------------------------------------------------------------------------------------------------------------
// TYPES
//---------------------------------------------------------------------------------------------------------------------
type pivot
    float currentLevel
    bool crossed
    int barTime
    int barIndex

type trend
    int bias

type orderBlock
    float barHigh
    float barLow
    int barTime
    int bias
    bool touched
    bool retested

//---------------------------------------------------------------------------------------------------------------------
// VARIABLES
//---------------------------------------------------------------------------------------------------------------------
var pivot swingHigh = pivot.new(na, false, time, bar_index)
var pivot swingLow = pivot.new(na, false, time, bar_index)

var pivot internalHigh = pivot.new(na, false, time, bar_index)
var pivot internalLow = pivot.new(na, false, time, bar_index)

var trend swingTrend = trend.new(0)
var trend internalTrend = trend.new(0)

var array<float> parsedHighs = array.new<float>()
var array<float> parsedLows = array.new<float>()
var array<int> times = array.new<int>()

var array<orderBlock> swingOrderBlocks = array.new<orderBlock>()
var array<orderBlock> internalOrderBlocks = array.new<orderBlock>()

var array<box> swingOrderBlocksBoxes = array.new<box>()
var array<box> internalOrderBlocksBoxes = array.new<box>()

//---------------------------------------------------------------------------------------------------------------------
// INIT BOXES
//---------------------------------------------------------------------------------------------------------------------
if barstate.isfirst
    for i = 1 to swingOrderBlocksSizeInput
        swingOrderBlocksBoxes.push(box.new(na, na, na, na, xloc = xloc.bar_time, extend = extend.right))

    for i = 1 to internalOrderBlocksSizeInput
        internalOrderBlocksBoxes.push(box.new(na, na, na, na, xloc = xloc.bar_time, extend = extend.right))

//---------------------------------------------------------------------------------------------------------------------
// VOLATILITY
//---------------------------------------------------------------------------------------------------------------------
bearishOrderBlockMitigationSource = orderBlockMitigationInput == CLOSE ? close : high
bullishOrderBlockMitigationSource = orderBlockMitigationInput == CLOSE ? close : low

atrMeasure = ta.atr(200)
volatilityMeasure = orderBlockFilterInput == ATR ? atrMeasure : ta.cum(ta.tr) / bar_index

highVolatilityBar = (high - low) >= (2 * volatilityMeasure)

parsedHigh = highVolatilityBar ? low : high
parsedLow = highVolatilityBar ? high : low

parsedHighs.push(parsedHigh)
parsedLows.push(parsedLow)
times.push(time)

//---------------------------------------------------------------------------------------------------------------------
// FUNCTIONS
//---------------------------------------------------------------------------------------------------------------------
leg(int size) =>
    var leg = 0

    newLegHigh = high[size] > ta.highest(size)
    newLegLow = low[size] < ta.lowest(size)

    if newLegHigh
        leg := BEARISH_LEG
    else if newLegLow
        leg := BULLISH_LEG

    leg

startOfNewLeg(int leg) => ta.change(leg) != 0
startOfBearishLeg(int leg) => ta.change(leg) == -1
startOfBullishLeg(int leg) => ta.change(leg) == 1

getCurrentStructure(int size, bool internal = false) =>
    currentLeg = leg(size)

    newPivot = startOfNewLeg(currentLeg)
    pivotLow = startOfBullishLeg(currentLeg)
    pivotHigh = startOfBearishLeg(currentLeg)

    if newPivot
        if pivotLow
            pivot p = internal ? internalLow : swingLow

            p.currentLevel := low[size]
            p.crossed := false
            p.barTime := time[size]
            p.barIndex := bar_index[size]

        else
            pivot p = internal ? internalHigh : swingHigh

            p.currentLevel := high[size]
            p.crossed := false
            p.barTime := time[size]
            p.barIndex := bar_index[size]

//---------------------------------------------------------------------------------------------------------------------
// STORE ORDER BLOCK
//---------------------------------------------------------------------------------------------------------------------
storeOrderBlock(pivot p_ivot, bool internal = false, int bias) =>
    array<float> arr = na
    int parsedIndex = na

    if bias == BEARISH
        arr := parsedHighs.slice(p_ivot.barIndex, bar_index)
        parsedIndex := p_ivot.barIndex + arr.indexof(arr.max())
    else
        arr := parsedLows.slice(p_ivot.barIndex, bar_index)
        parsedIndex := p_ivot.barIndex + arr.indexof(arr.min())

    orderBlock ob = orderBlock.new(
         parsedHighs.get(parsedIndex),
         parsedLows.get(parsedIndex),
         times.get(parsedIndex),
         bias,
         false,
         false
     )

    array<orderBlock> orderBlocks = internal ? internalOrderBlocks : swingOrderBlocks

    if orderBlocks.size() >= 100
        orderBlocks.pop()

    orderBlocks.unshift(ob)

//---------------------------------------------------------------------------------------------------------------------
// DELETE MITIGATED ORDER BLOCKS
//---------------------------------------------------------------------------------------------------------------------
deleteOrderBlocks(bool internal = false) =>
    array<orderBlock> orderBlocks = internal ? internalOrderBlocks : swingOrderBlocks

    for [index, eachOrderBlock] in orderBlocks

        bool crossed = false

        if bearishOrderBlockMitigationSource > eachOrderBlock.barHigh and eachOrderBlock.bias == BEARISH
            crossed := true

        else if bullishOrderBlockMitigationSource < eachOrderBlock.barLow and eachOrderBlock.bias == BULLISH
            crossed := true

        if crossed
            orderBlocks.remove(index)

//---------------------------------------------------------------------------------------------------------------------
// RETEST ORDER BLOCKS
//---------------------------------------------------------------------------------------------------------------------
detectOrderBlockRetests(bool internal = false) =>
    bool longRetest = false
    bool shortRetest = false

    array<orderBlock> orderBlocks = internal ? internalOrderBlocks : swingOrderBlocks

    if orderBlocks.size() > 0
        for i = 0 to orderBlocks.size() - 1
            orderBlock ob = orderBlocks.get(i)

            bool priceInsideOB = high >= ob.barLow and low <= ob.barHigh

            // LONG OB RETEST:
            // ціна зайшла в зону, не закрилась нижче OB, потім вийшла назад вверх
            if ob.bias == BULLISH and not ob.retested
                if ob.touched and close > ob.barHigh
                    longRetest := true
                    ob.retested := true

                if priceInsideOB and close >= ob.barLow
                    ob.touched := true

            // SHORT OB RETEST:
            // ціна зайшла в зону, не закрилась вище OB, потім вийшла назад вниз
            if ob.bias == BEARISH and not ob.retested
                if ob.touched and close < ob.barLow
                    shortRetest := true
                    ob.retested := true

                if priceInsideOB and close <= ob.barHigh
                    ob.touched := true

            orderBlocks.set(i, ob)

    [longRetest, shortRetest]

//---------------------------------------------------------------------------------------------------------------------
// DRAW ORDER BLOCKS
//---------------------------------------------------------------------------------------------------------------------
drawOrderBlocks(bool internal = false) =>
    array<orderBlock> orderBlocks = internal ? internalOrderBlocks : swingOrderBlocks

    orderBlocksSize = orderBlocks.size()

    if orderBlocksSize > 0
        maxOrderBlocks = internal ? internalOrderBlocksSizeInput : swingOrderBlocksSizeInput

        array<orderBlock> parsedOrderBlocks =
             orderBlocks.slice(0, math.min(maxOrderBlocks, orderBlocksSize))

        array<box> boxes =
             internal ? internalOrderBlocksBoxes : swingOrderBlocksBoxes

        for [index, eachOrderBlock] in parsedOrderBlocks

            color obColor =
                 internal
                 ? eachOrderBlock.bias == BEARISH
                     ? internalBearishOrderBlockColor
                     : internalBullishOrderBlockColor
                 : eachOrderBlock.bias == BEARISH
                     ? swingBearishOrderBlockColor
                     : swingBullishOrderBlockColor

            box bx = boxes.get(index)

            bx.set_top_left_point(
                 chart.point.new(eachOrderBlock.barTime, na, eachOrderBlock.barHigh)
             )

            bx.set_bottom_right_point(
                 chart.point.new(last_bar_time, na, eachOrderBlock.barLow)
             )

            bx.set_bgcolor(obColor)
            bx.set_border_color(na)

//---------------------------------------------------------------------------------------------------------------------
// STRUCTURE + ORDER BLOCK LOGIC
//---------------------------------------------------------------------------------------------------------------------
displayStructure(bool internal = false) =>
    bool longCreated = false
    bool shortCreated = false

    pivot p = internal ? internalHigh : swingHigh
    trend t = internal ? internalTrend : swingTrend

    // LONG OB — зона знизу
    if ta.crossover(close, p.currentLevel) and not p.crossed
        p.crossed := true
        t.bias := BULLISH

        if (internal and showInternalOrderBlocksInput) or (not internal and showSwingOrderBlocksInput)
            storeOrderBlock(p, internal, BULLISH)
            longCreated := true

    p := internal ? internalLow : swingLow

    // SHORT OB — зона зверху
    if ta.crossunder(close, p.currentLevel) and not p.crossed
        p.crossed := true
        t.bias := BEARISH

        if (internal and showInternalOrderBlocksInput) or (not internal and showSwingOrderBlocksInput)
            storeOrderBlock(p, internal, BEARISH)
            shortCreated := true

    [longCreated, shortCreated]

//---------------------------------------------------------------------------------------------------------------------
// EXECUTION
//---------------------------------------------------------------------------------------------------------------------
getCurrentStructure(50, false)
getCurrentStructure(5, true)

[internalLongOBCreated, internalShortOBCreated] = displayStructure(true)
[swingLongOBCreated, swingShortOBCreated] = displayStructure(false)

longOBCreatedAlert = internalLongOBCreated or swingLongOBCreated
shortOBCreatedAlert = internalShortOBCreated or swingShortOBCreated

[internalLongOBRetest, internalShortOBRetest] = detectOrderBlockRetests(true)
[swingLongOBRetest, swingShortOBRetest] = detectOrderBlockRetests(false)

longOBRetestAlert = internalLongOBRetest or swingLongOBRetest
shortOBRetestAlert = internalShortOBRetest or swingShortOBRetest

deleteOrderBlocks(true)
deleteOrderBlocks(false)

if barstate.islastconfirmedhistory or barstate.islast
    drawOrderBlocks(true)
    drawOrderBlocks(false)

//---------------------------------------------------------------------------------------------------------------------
// ALERTS
//---------------------------------------------------------------------------------------------------------------------
alertcondition(longOBCreatedAlert, "Long OB Created", "Створено лонговий OB знизу")
alertcondition(shortOBCreatedAlert, "Short OB Created", "Створено шортовий OB зверху")

alertcondition(longOBRetestAlert, "Long OB Retest", "Ретест лонгового OB")
alertcondition(shortOBRetestAlert, "Short OB Retest", "Ретест шортового OB")
````
