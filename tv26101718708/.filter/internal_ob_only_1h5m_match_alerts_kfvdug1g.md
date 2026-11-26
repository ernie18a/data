# Internal OB Only + 1H/5M Match Alerts

- url: https://www.tradingview.com/script/KfvdUg1G-internal-ob-only-1h-5m-match-alerts/
- type: indicator
- pine_id: PUB;a691f96d83b14ee69b695620761d7e12
- version: 1.0

## Description

**Internal Order Blocks + 1H / 5M Bias Confirmation**

This indicator is designed to identify market direction using **Internal Order Blocks (OBs)** while preserving the original Order Block detection logic.

### Features

* Detects and draws **Internal Bullish and Bearish Order Blocks**.
* Automatically removes mitigated Order Blocks.
* Detects valid Order Block retests.
* Displays only the **three most recent Internal Order Blocks**.
* Shows the current Order Block bias in a table located at the **bottom-right corner** of the chart.

### Bias Logic

The indicator determines the market bias from the **last three active Internal Order Blocks**.

**LONG Bias**

* 2 or 3 Bullish Order Blocks (below price).

**SHORT Bias**

* 2 or 3 Bearish Order Blocks (above price).

Otherwise, the bias remains **Neutral**.

### Multi-Timeframe Confirmation

The script compares the Internal Order Block bias between:

* **1 Hour**
* **5 Minutes**

### Alerts

Only two confirmation alerts are available:

**LONG Confirmation**

* The **1H bias is already LONG**, and
* The **5M bias changes to LONG**.

**SHORT Confirmation**

* The **1H bias is already SHORT**, and
* The **5M bias changes to SHORT**.

These alerts are intended to notify traders when the lower timeframe aligns with the higher timeframe, providing a potential entry confirmation.

### Important

The original Internal Order Block creation, mitigation, and retest logic has been preserved. The indicator only adds bias evaluation and higher/lower timeframe confirmation without altering the core Order Block algorithm.

## Source Code

````pine
//@version=6
indicator("Internal OB Only + 1H/5M Match Alerts", overlay = true, max_boxes_count = 500)

//---------------------------------------------------------------------------------------------------------------------
// CONSTANTS
//---------------------------------------------------------------------------------------------------------------------
BULLISH_LEG = 1
BEARISH_LEG = 0

BULLISH = 1
BEARISH = -1
NEUTRAL = 0

ATR   = "Atr"
RANGE = "Cumulative Mean Range"

CLOSE   = "Close"
HIGHLOW = "High/Low"

//---------------------------------------------------------------------------------------------------------------------
// INPUTS
//---------------------------------------------------------------------------------------------------------------------
showInternalOrderBlocksInput = input.bool(true, "Internal Order Blocks")
internalOrderBlocksSizeInput = input.int(3, "", minval = 1, maxval = 3)

orderBlockFilterInput = input.string(ATR, "Order Block Filter", options = [ATR, RANGE])
orderBlockMitigationInput = input.string(HIGHLOW, "Order Block Mitigation", options = [CLOSE, HIGHLOW])

internalBullishOrderBlockColor = input.color(color.new(#3179f5, 80), "Internal Bullish OB")
internalBearishOrderBlockColor = input.color(color.new(#f77c80, 80), "Internal Bearish OB")

showTableInput = input.bool(true, "Show Table")

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
var pivot internalHigh = pivot.new(na, false, time, bar_index)
var pivot internalLow = pivot.new(na, false, time, bar_index)

var trend internalTrend = trend.new(0)

var array<float> parsedHighs = array.new<float>()
var array<float> parsedLows = array.new<float>()
var array<int> times = array.new<int>()

var array<orderBlock> internalOrderBlocks = array.new<orderBlock>()
var array<box> internalOrderBlocksBoxes = array.new<box>()

if barstate.isfirst
    for i = 1 to 3
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
    var int leg = 0

    newLegHigh = high[size] > ta.highest(size)
    newLegLow = low[size] < ta.lowest(size)

    if newLegHigh
        leg := BEARISH_LEG
    else if newLegLow
        leg := BULLISH_LEG

    leg

startOfNewLeg(int legValue) => ta.change(legValue) != 0
startOfBearishLeg(int legValue) => ta.change(legValue) == -1
startOfBullishLeg(int legValue) => ta.change(legValue) == 1

getCurrentStructure(int size) =>
    currentLeg = leg(size)

    newPivot = startOfNewLeg(currentLeg)
    pivotLow = startOfBullishLeg(currentLeg)
    pivotHigh = startOfBearishLeg(currentLeg)

    if newPivot
        if pivotLow
            internalLow.currentLevel := low[size]
            internalLow.crossed := false
            internalLow.barTime := time[size]
            internalLow.barIndex := bar_index[size]
        else
            internalHigh.currentLevel := high[size]
            internalHigh.crossed := false
            internalHigh.barTime := time[size]
            internalHigh.barIndex := bar_index[size]

//---------------------------------------------------------------------------------------------------------------------
// STORE ORDER BLOCK
//---------------------------------------------------------------------------------------------------------------------
storeOrderBlock(pivot p_ivot, int bias) =>
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

    if internalOrderBlocks.size() >= 100
        internalOrderBlocks.pop()

    internalOrderBlocks.unshift(ob)

//---------------------------------------------------------------------------------------------------------------------
// DELETE MITIGATED ORDER BLOCKS
//---------------------------------------------------------------------------------------------------------------------
deleteOrderBlocks() =>
    if internalOrderBlocks.size() > 0
        for j = 0 to internalOrderBlocks.size() - 1
            int index = internalOrderBlocks.size() - 1 - j
            orderBlock eachOrderBlock = internalOrderBlocks.get(index)

            bool crossed = false

            if bearishOrderBlockMitigationSource > eachOrderBlock.barHigh and eachOrderBlock.bias == BEARISH
                crossed := true

            else if bullishOrderBlockMitigationSource < eachOrderBlock.barLow and eachOrderBlock.bias == BULLISH
                crossed := true

            if crossed
                internalOrderBlocks.remove(index)

//---------------------------------------------------------------------------------------------------------------------
// RETEST ORDER BLOCKS
//---------------------------------------------------------------------------------------------------------------------
detectOrderBlockRetests() =>
    bool longRetest = false
    bool shortRetest = false

    if internalOrderBlocks.size() > 0
        for i = 0 to internalOrderBlocks.size() - 1
            orderBlock ob = internalOrderBlocks.get(i)

            bool priceInsideOB = high >= ob.barLow and low <= ob.barHigh

            if ob.bias == BULLISH and not ob.retested
                if ob.touched and close > ob.barHigh
                    longRetest := true
                    ob.retested := true

                if priceInsideOB and close >= ob.barLow
                    ob.touched := true

            if ob.bias == BEARISH and not ob.retested
                if ob.touched and close < ob.barLow
                    shortRetest := true
                    ob.retested := true

                if priceInsideOB and close <= ob.barHigh
                    ob.touched := true

            internalOrderBlocks.set(i, ob)

    [longRetest, shortRetest]

//---------------------------------------------------------------------------------------------------------------------
// DRAW ORDER BLOCKS
//---------------------------------------------------------------------------------------------------------------------
drawOrderBlocks() =>
    orderBlocksSize = internalOrderBlocks.size()

    if orderBlocksSize > 0
        array<orderBlock> parsedOrderBlocks =
             internalOrderBlocks.slice(0, math.min(internalOrderBlocksSizeInput, orderBlocksSize))

        for [index, eachOrderBlock] in parsedOrderBlocks

            color obColor =
                 eachOrderBlock.bias == BEARISH
                     ? internalBearishOrderBlockColor
                     : internalBullishOrderBlockColor

            box bx = internalOrderBlocksBoxes.get(index)

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
displayStructure() =>
    bool longCreated = false
    bool shortCreated = false

    if ta.crossover(close, internalHigh.currentLevel) and not internalHigh.crossed
        internalHigh.crossed := true
        internalTrend.bias := BULLISH

        if showInternalOrderBlocksInput
            storeOrderBlock(internalHigh, BULLISH)
            longCreated := true

    if ta.crossunder(close, internalLow.currentLevel) and not internalLow.crossed
        internalLow.crossed := true
        internalTrend.bias := BEARISH

        if showInternalOrderBlocksInput
            storeOrderBlock(internalLow, BEARISH)
            shortCreated := true

    [longCreated, shortCreated]

//---------------------------------------------------------------------------------------------------------------------
// CURRENT TF BIAS FROM REAL INTERNAL OB ARRAY
//---------------------------------------------------------------------------------------------------------------------
getInternalOBBias() =>
    int bullCount = 0
    int bearCount = 0

    if internalOrderBlocks.size() >= 3
        for i = 0 to 2
            orderBlock ob = internalOrderBlocks.get(i)

            if ob.bias == BULLISH
                bullCount += 1

            if ob.bias == BEARISH
                bearCount += 1

    int result = NEUTRAL

    if bearCount >= 2
        result := BEARISH

    if bullCount >= 2
        result := BULLISH

    result

biasText(int bias) =>
    bias == BULLISH ? "LONG" :
     bias == BEARISH ? "SHORT" :
     "NEUTRAL"

biasColor(int bias) =>
    bias == BULLISH ? color.new(color.green, 0) :
     bias == BEARISH ? color.new(color.red, 0) :
     color.new(color.gray, 0)

//---------------------------------------------------------------------------------------------------------------------
// MTF BIAS FOR ALERTS — SAME OB LOGIC, WITHOUT DRAWING
//---------------------------------------------------------------------------------------------------------------------
mtfOBBiasAndSignal() =>
    var float mtfInternalHighLevel = na
    var bool mtfInternalHighCrossed = false
    var int mtfInternalHighBarIndex = na

    var float mtfInternalLowLevel = na
    var bool mtfInternalLowCrossed = false
    var int mtfInternalLowBarIndex = na

    var array<float> mtfParsedHighs = array.new<float>()
    var array<float> mtfParsedLows = array.new<float>()

    var array<float> mtfOBHighs = array.new<float>()
    var array<float> mtfOBLows = array.new<float>()
    var array<int> mtfOBBiases = array.new<int>()

    mtfAtrMeasure = ta.atr(200)
    mtfVolatilityMeasure = orderBlockFilterInput == ATR ? mtfAtrMeasure : ta.cum(ta.tr) / bar_index

    mtfHighVolatilityBar = (high - low) >= (2 * mtfVolatilityMeasure)

    mtfParsedHigh = mtfHighVolatilityBar ? low : high
    mtfParsedLow = mtfHighVolatilityBar ? high : low

    mtfParsedHighs.push(mtfParsedHigh)
    mtfParsedLows.push(mtfParsedLow)

    currentLeg = leg(5)

    newPivot = startOfNewLeg(currentLeg)
    pivotLow = startOfBullishLeg(currentLeg)
    pivotHigh = startOfBearishLeg(currentLeg)

    if newPivot
        if pivotLow
            mtfInternalLowLevel := low[5]
            mtfInternalLowCrossed := false
            mtfInternalLowBarIndex := bar_index[5]
        else
            mtfInternalHighLevel := high[5]
            mtfInternalHighCrossed := false
            mtfInternalHighBarIndex := bar_index[5]

    if ta.crossover(close, mtfInternalHighLevel) and not mtfInternalHighCrossed
        mtfInternalHighCrossed := true

        if not na(mtfInternalHighBarIndex) and mtfInternalHighBarIndex < bar_index
            array<float> arr = mtfParsedLows.slice(mtfInternalHighBarIndex, bar_index)
            int parsedIndex = mtfInternalHighBarIndex + arr.indexof(arr.min())

            mtfOBHighs.unshift(mtfParsedHighs.get(parsedIndex))
            mtfOBLows.unshift(mtfParsedLows.get(parsedIndex))
            mtfOBBiases.unshift(BULLISH)

            if mtfOBBiases.size() >= 100
                mtfOBHighs.pop()
                mtfOBLows.pop()
                mtfOBBiases.pop()

    if ta.crossunder(close, mtfInternalLowLevel) and not mtfInternalLowCrossed
        mtfInternalLowCrossed := true

        if not na(mtfInternalLowBarIndex) and mtfInternalLowBarIndex < bar_index
            array<float> arr = mtfParsedHighs.slice(mtfInternalLowBarIndex, bar_index)
            int parsedIndex = mtfInternalLowBarIndex + arr.indexof(arr.max())

            mtfOBHighs.unshift(mtfParsedHighs.get(parsedIndex))
            mtfOBLows.unshift(mtfParsedLows.get(parsedIndex))
            mtfOBBiases.unshift(BEARISH)

            if mtfOBBiases.size() >= 100
                mtfOBHighs.pop()
                mtfOBLows.pop()
                mtfOBBiases.pop()

    if mtfOBBiases.size() > 0
        for j = 0 to mtfOBBiases.size() - 1
            int index = mtfOBBiases.size() - 1 - j

            float obHigh = mtfOBHighs.get(index)
            float obLow = mtfOBLows.get(index)
            int obBias = mtfOBBiases.get(index)

            bool crossed = false

            if bearishOrderBlockMitigationSource > obHigh and obBias == BEARISH
                crossed := true

            else if bullishOrderBlockMitigationSource < obLow and obBias == BULLISH
                crossed := true

            if crossed
                mtfOBHighs.remove(index)
                mtfOBLows.remove(index)
                mtfOBBiases.remove(index)

    int bullCount = 0
    int bearCount = 0

    if mtfOBBiases.size() >= 3
        for i = 0 to 2
            int obBias = mtfOBBiases.get(i)

            if obBias == BULLISH
                bullCount += 1

            if obBias == BEARISH
                bearCount += 1

    int result = NEUTRAL

    if bearCount >= 2
        result := BEARISH

    if bullCount >= 2
        result := BULLISH

    bool becameLong = result == BULLISH and result[1] != BULLISH
    bool becameShort = result == BEARISH and result[1] != BEARISH

    [result, becameLong, becameShort]

//---------------------------------------------------------------------------------------------------------------------
// EXECUTION
//---------------------------------------------------------------------------------------------------------------------
getCurrentStructure(5)

[internalLongOBCreated, internalShortOBCreated] = displayStructure()

[internalLongOBRetest, internalShortOBRetest] = detectOrderBlockRetests()

deleteOrderBlocks()

if barstate.islastconfirmedhistory or barstate.islast
    drawOrderBlocks()

currentBias = getInternalOBBias()

//---------------------------------------------------------------------------------------------------------------------
// 1H + 5M ALERT LOGIC
//---------------------------------------------------------------------------------------------------------------------
[bias1H, becameLong1H, becameShort1H] = request.security(syminfo.tickerid, "60", mtfOBBiasAndSignal())
[bias5M, becameLong5M, becameShort5M] = request.security(syminfo.tickerid, "5", mtfOBBiasAndSignal())

longAlert = bias1H == BULLISH and becameLong5M
shortAlert = bias1H == BEARISH and becameShort5M

//---------------------------------------------------------------------------------------------------------------------
// TABLE
//---------------------------------------------------------------------------------------------------------------------
var table obTable = table.new(position.bottom_right, 2, 4, border_width = 1)

if showTableInput and barstate.islast
    table.cell(obTable, 0, 0, "TF", text_color = color.white, bgcolor = color.black)
    table.cell(obTable, 1, 0, "OB BIAS", text_color = color.white, bgcolor = color.black)

    table.cell(obTable, 0, 1, timeframe.period, text_color = color.white, bgcolor = color.black)
    table.cell(obTable, 1, 1, biasText(currentBias), text_color = color.white, bgcolor = biasColor(currentBias))

    table.cell(obTable, 0, 2, "1H", text_color = color.white, bgcolor = color.black)
    table.cell(obTable, 1, 2, biasText(bias1H), text_color = color.white, bgcolor = biasColor(bias1H))

    table.cell(obTable, 0, 3, "5M", text_color = color.white, bgcolor = color.black)
    table.cell(obTable, 1, 3, biasText(bias5M), text_color = color.white, bgcolor = biasColor(bias5M))

if not showTableInput and barstate.islast
    table.clear(obTable, 0, 0, 1, 3)

//---------------------------------------------------------------------------------------------------------------------
// ALERTS — ONLY THESE TWO
//---------------------------------------------------------------------------------------------------------------------
alertcondition(longAlert, "1H LONG + 5M BECAME LONG", "1H вже LONG, 5M став LONG")
alertcondition(shortAlert, "1H SHORT + 5M BECAME SHORT", "1H вже SHORT, 5M став SHORT")
````
