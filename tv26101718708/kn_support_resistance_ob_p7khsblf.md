# KN Support Resistance OB

- url: https://www.tradingview.com/script/p7khSBLf-KN-Support-Resistance-OB/
- type: indicator
- pine_id: PUB;573c507b852447318d060517e31421bb
- version: 1.0

## Description

KN Support Resistance OB is a market structure and order block indicator designed to highlight potential bullish and bearish zones on the chart.

Features:
• Internal and swing order block detection
• Dynamic support and resistance zones
• Bullish and bearish order block visualization
• ATR / range-based filtering
• Automatic mitigation detection
• Clean box-based chart display
• Customizable colors and structure settings

This script is inspired by the original Smart Money Concepts and Order Block methodology by LuxAlgo.

Modified and simplified by KN Invest for educational and chart analysis purposes only.

## Source Code

````pine
// This work is licensed under CC BY-NC-SA 4.0
// Original concept by LuxAlgo
// Modified by phamhaihoclt

//@version=5
indicator('KN Support Resistance OB', 'KN OB Zones', overlay = true, max_boxes_count = 500)

BULLISH_LEG = 1
BEARISH_LEG = 0

BULLISH = 1
BEARISH = -1

ATR = 'Atr'
RANGE = 'Cumulative Mean Range'
CLOSE = 'Close'
HIGHLOW = 'High/Low'

STRUCTURE_GROUP = 'Structure'
ORDER_BLOCK_GROUP = 'Order Blocks'

internalLengthInput = input.int(5, 'Internal Length', group = STRUCTURE_GROUP, minval = 2)
swingLengthInput = input.int(50, 'Swing Length', group = STRUCTURE_GROUP, minval = 10)

internalOrderBlocksSizeInput = input.int(3, 'Internal Order Blocks', group = ORDER_BLOCK_GROUP, minval = 1, maxval = 20)
swingOrderBlocksSizeInput = input.int(5, 'Swing Order Blocks', group = ORDER_BLOCK_GROUP, minval = 1, maxval = 20)
orderBlockFilterInput = input.string(ATR, 'Filter', group = ORDER_BLOCK_GROUP, options = [ATR, RANGE])
orderBlockMitigationInput = input.string(HIGHLOW, 'Mitigation', group = ORDER_BLOCK_GROUP, options = [CLOSE, HIGHLOW])
internalBullishColorInput = input.color(color.new(#3179f5, 80), 'Internal Bullish', group = ORDER_BLOCK_GROUP)
internalBearishColorInput = input.color(color.new(#f77c80, 80), 'Internal Bearish', group = ORDER_BLOCK_GROUP)
swingBullishColorInput = input.color(color.new(#1848cc, 80), 'Swing Bullish', group = ORDER_BLOCK_GROUP)
swingBearishColorInput = input.color(color.new(#b22833, 80), 'Swing Bearish', group = ORDER_BLOCK_GROUP)

type pivot
    float level
    bool crossed
    int barTime
    int barIndex

type orderBlock
    float blockHigh
    float blockLow
    int barTime
    int bias

var pivot swingHigh = pivot.new(na, false, na, na)
var pivot swingLow = pivot.new(na, false, na, na)
var pivot internalHigh = pivot.new(na, false, na, na)
var pivot internalLow = pivot.new(na, false, na, na)

var array<float> parsedHighs = array.new<float>()
var array<float> parsedLows = array.new<float>()
var array<int> times = array.new<int>()

var array<orderBlock> swingOrderBlocks = array.new<orderBlock>()
var array<orderBlock> internalOrderBlocks = array.new<orderBlock>()
var array<box> swingBoxes = array.new<box>()
var array<box> internalBoxes = array.new<box>()

newBox() =>
    box.new(na, na, na, na, xloc = xloc.bar_time, extend = extend.right)

if barstate.isfirst
    for index = 1 to swingOrderBlocksSizeInput
        swingBoxes.push(newBox())

    for index = 1 to internalOrderBlocksSizeInput
        internalBoxes.push(newBox())

atrMeasure = ta.atr(200)
volatilityMeasure = orderBlockFilterInput == ATR ? atrMeasure : ta.cum(ta.tr) / bar_index
highVolatilityBar = high - low >= 2 * volatilityMeasure

parsedHighs.push(highVolatilityBar ? low : high)
parsedLows.push(highVolatilityBar ? high : low)
times.push(time)

leg(int length) =>
    var legValue = 0
    newHigh = high[length] > ta.highest(length)
    newLow = low[length] < ta.lowest(length)

    if newHigh
        legValue := BEARISH_LEG
    else if newLow
        legValue := BULLISH_LEG

    legValue

updatePivots(int length, bool internal) =>
    currentLeg = leg(length)
    newPivot = ta.change(currentLeg) != 0

    if newPivot
        bool isLowPivot = ta.change(currentLeg) == 1
        pivot target = internal ? (isLowPivot ? internalLow : internalHigh) : (isLowPivot ? swingLow : swingHigh)

        target.level := isLowPivot ? low[length] : high[length]
        target.crossed := false
        target.barTime := time[length]
        target.barIndex := bar_index[length]

blockColor(orderBlock block, bool internal) =>
    color selectedColor = na

    if internal
        selectedColor := block.bias == BEARISH ? internalBearishColorInput : internalBullishColorInput
    else
        selectedColor := block.bias == BEARISH ? swingBearishColorInput : swingBullishColorInput

    selectedColor

saveOrderBlock(pivot basePivot, bool internal, int bias) =>
    array<float> source = bias == BEARISH ? parsedHighs : parsedLows
    array<float> priceRange = source.slice(basePivot.barIndex, bar_index)
    int rangeIndex = bias == BEARISH ? priceRange.indexof(priceRange.max()) : priceRange.indexof(priceRange.min())
    int blockIndex = basePivot.barIndex + rangeIndex

    orderBlock block = orderBlock.new(parsedHighs.get(blockIndex), parsedLows.get(blockIndex), times.get(blockIndex), bias)
    array<orderBlock> blocks = internal ? internalOrderBlocks : swingOrderBlocks

    if blocks.size() >= 100
        blocks.pop()

    blocks.unshift(block)

detectOrderBlocks(bool internal) =>
    pivot highPivot = internal ? internalHigh : swingHigh
    bool bullishBreak = ta.crossover(close, highPivot.level) and not highPivot.crossed
    bool validInternalBullishBreak = not internal or internalHigh.level != swingHigh.level

    if bullishBreak and validInternalBullishBreak
        highPivot.crossed := true
        saveOrderBlock(highPivot, internal, BULLISH)

    pivot lowPivot = internal ? internalLow : swingLow
    bool bearishBreak = ta.crossunder(close, lowPivot.level) and not lowPivot.crossed
    bool validInternalBearishBreak = not internal or internalLow.level != swingLow.level

    if bearishBreak and validInternalBearishBreak
        lowPivot.crossed := true
        saveOrderBlock(lowPivot, internal, BEARISH)

deleteMitigatedBlocks(bool internal) =>
    array<orderBlock> blocks = internal ? internalOrderBlocks : swingOrderBlocks
    bearishMitigationSource = orderBlockMitigationInput == CLOSE ? close : high
    bullishMitigationSource = orderBlockMitigationInput == CLOSE ? close : low

    for [index, block] in blocks
        mitigatedBearishBlock = block.bias == BEARISH and bearishMitigationSource > block.blockHigh
        mitigatedBullishBlock = block.bias == BULLISH and bullishMitigationSource < block.blockLow

        if mitigatedBearishBlock or mitigatedBullishBlock
            blocks.remove(index)

drawBlocks(bool internal) =>
    array<orderBlock> blocks = internal ? internalOrderBlocks : swingOrderBlocks
    array<box> boxes = internal ? internalBoxes : swingBoxes
    int limit = internal ? internalOrderBlocksSizeInput : swingOrderBlocksSizeInput

    if blocks.size() > 0
        for index = 0 to math.min(limit, blocks.size()) - 1
            orderBlock block = blocks.get(index)
            box currentBox = boxes.get(index)
            color currentColor = blockColor(block, internal)

            currentBox.set_top_left_point(chart.point.new(block.barTime, na, block.blockHigh))
            currentBox.set_bottom_right_point(chart.point.new(last_bar_time, na, block.blockLow))
            currentBox.set_border_color(internal ? na : currentColor)
            currentBox.set_bgcolor(currentColor)

updatePivots(swingLengthInput, false)
updatePivots(internalLengthInput, true)

detectOrderBlocks(true)
detectOrderBlocks(false)

deleteMitigatedBlocks(true)
deleteMitigatedBlocks(false)

if barstate.islastconfirmedhistory or barstate.islast
    drawBlocks(true)
    drawBlocks(false)
````
