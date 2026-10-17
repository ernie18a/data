# Pure Order Blocks by ShadowQuant Trader

- url: https://www.tradingview.com/script/y8jYsIMq-Pure-Order-Blocks-by-ShadowQuant-Trader/
- type: indicator
- pine_id: PUB;1355f31ddb5f4e2896775596a7d9f010
- version: 1.0

## Description

Pure Order Blocks
This indicator marks four types of order blocks directly from candle structure:

Bullish OB
Bearish OB
Bullish Wick OB
Bearish Wick OB
A Bullish OB is identified when 3 consecutive candles form a valid bullish imbalance:

C1 is the first candle
C2 must not break the low of C1
C3 low must remain above the high of C1
If those conditions are satisfied, C1 is marked as a Bullish Order Block.

A Bearish OB is identified when 3 consecutive candles form a valid bearish imbalance:

B1 is the first candle
B2 must not break the high of B1
B3 high must remain below the low of B1
If those conditions are satisfied, B1 is marked as a Bearish Order Block.

A Bullish Wick OB is identified when a candle sweeps the prior candle’s low with its wick only:

the prior candle must not be an inside bar
the wick candle itself must not be an inside bar
if any later candle touches the wick high, the Bullish Wick OB becomes invalid
A Bearish Wick OB is identified when a candle sweeps the prior candle’s high with its wick only:

the prior candle must not be an inside bar
the wick candle itself must not be an inside bar
if any later candle touches the wick low, the Bearish Wick OB becomes invalid
Important logic:

Full candle OB has priority over Wick OB on the same candle
Inside bars are allowed for full OBs if all full OB rules are satisfied
Inside bars are not allowed for Wick OBs
OBs remain visible only until price touches them
Wick OBs highlight only the wick area, not the full candle
This tool is built for traders who want a clean visual way to track untouched order blocks based purely on candle behavior and imbalance structure.

The Originator of this Indicator is - ShadowQuant Trader by Finweal Finance 
Credits to : Prajyot Mahajan.

## Source Code

````pine
//@version=6
indicator("Pure Order Blocks", overlay=true, max_boxes_count=500)

showBullishOB = input.bool(true, "Show Bullish OB")
showBearishOB = input.bool(true, "Show Bearish OB")
showBullishWickOB = input.bool(true, "Show Bullish Wick OB")
showBearishWickOB = input.bool(true, "Show Bearish Wick OB")
pastOBCount = input.int(20, "Past OBs To Show", minval=1, maxval=100)
showOBLabels = input.bool(true, "Show OB Labels")

bullishOBColor = input.color(color.new(#2E8B57, 80), "Bullish OB Color")
bearishOBColor = input.color(color.new(#B22222, 80), "Bearish OB Color")
bullishWickOBColor = input.color(color.new(#7BC67B, 70), "Bullish Wick OB Color")
bearishWickOBColor = input.color(color.new(#FF8C69, 70), "Bearish Wick OB Color")
obTextColor = input.color(#000000, "OB Text Color")

var array<box> obBoxes = array.new_box()
var array<float> obTops = array.new_float()
var array<float> obBottoms = array.new_float()
var array<int> obDirections = array.new_int()
var array<int> obKinds = array.new_int()
var array<int> obCreatedBars = array.new_int()
var array<bool> obActive = array.new_bool()
var array<int> obSourceTimes = array.new_int()

isInsideBar(offset) =>
    bar_index >= offset + 1 and high[offset] <= high[offset + 1] and low[offset] >= low[offset + 1]

obColor(kind) =>
    kind == 1 ? bullishOBColor : kind == 2 ? bearishOBColor : kind == 3 ? bullishWickOBColor : bearishWickOBColor

obLabel(kind) =>
    kind == 1 ? "Bull OB" : kind == 2 ? "Bear OB" : kind == 3 ? "Bull Wick OB" : "Bear Wick OB"

obExists(sourceTime, kind) =>
    exists = false
    idx = array.size(obSourceTimes) - 1
    while idx >= 0
        if array.get(obSourceTimes, idx) == sourceTime and array.get(obKinds, idx) == kind
            exists := true
        idx -= 1
    exists

realObExistsOnSource(sourceTime, direction) =>
    exists = false
    idx = array.size(obSourceTimes) - 1
    while idx >= 0
        sameTime = array.get(obSourceTimes, idx) == sourceTime
        sameDirection = array.get(obDirections, idx) == direction
        realKind = array.get(obKinds, idx) == 1 or array.get(obKinds, idx) == 2
        if sameTime and sameDirection and realKind
            exists := true
        idx -= 1
    exists

buildBox(leftTime, topPrice, bottomPrice, kind) =>
    box.new(
         left=leftTime,
         right=time,
         top=topPrice,
         bottom=bottomPrice,
         xloc=xloc.bar_time,
         border_color=color.new(obColor(kind), 0),
         bgcolor=obColor(kind),
         text=showOBLabels ? obLabel(kind) : "",
         text_color=obTextColor,
         text_size=size.tiny,
         text_halign=text.align_center,
         text_valign=text.align_center)

storeOb(newBox, topPrice, bottomPrice, direction, kind, sourceTime) =>
    if obExists(sourceTime, kind)
        box.delete(newBox)
    else
        array.push(obBoxes, newBox)
        array.push(obTops, topPrice)
        array.push(obBottoms, bottomPrice)
        array.push(obDirections, direction)
        array.push(obKinds, kind)
        array.push(obCreatedBars, bar_index)
        array.push(obActive, true)
        array.push(obSourceTimes, sourceTime)

        while array.size(obBoxes) > pastOBCount
            oldBox = array.shift(obBoxes)
            array.shift(obTops)
            array.shift(obBottoms)
            array.shift(obDirections)
            array.shift(obKinds)
            array.shift(obCreatedBars)
            array.shift(obActive)
            array.shift(obSourceTimes)
            if not na(oldBox)
                box.delete(oldBox)

invalidateTouchedObs() =>
    idx = array.size(obBoxes) - 1
    while idx >= 0
        currentBox = array.get(obBoxes, idx)
        currentTop = array.get(obTops, idx)
        currentBottom = array.get(obBottoms, idx)
        currentDirection = array.get(obDirections, idx)
        currentCreatedBar = array.get(obCreatedBars, idx)
        currentActive = array.get(obActive, idx)

        if currentActive and not na(currentBox)
            box.set_right(currentBox, time)

        bullishTouched = currentActive and currentDirection == 1 and bar_index > currentCreatedBar and low <= currentTop
        bearishTouched = currentActive and currentDirection == -1 and bar_index > currentCreatedBar and high >= currentBottom

        if bullishTouched or bearishTouched
            if not na(currentBox)
                box.set_right(currentBox, time)
            array.set(obActive, idx, false)
            if not na(currentBox)
                box.set_bgcolor(currentBox, color.new(color.white, 100))
                box.set_border_color(currentBox, color.new(color.white, 100))
                box.set_text(currentBox, "")

        idx -= 1

if bar_index >= 0
    invalidateTouchedObs()

// Bullish OB: C1 = bar[2], C2 = bar[1], C3 = current bar.
// Valid only if C2 does not breach C1 low and C3 low stays above C1 high.
if showBullishOB and bar_index >= 2
    bullishObTop = high[2]
    bullishObBottom = low[2]
    bullishC2Respected = low[1] >= bullishObBottom
    bullishFvg = low > bullishObTop
    if bullishC2Respected and bullishFvg
        bullishObBox = buildBox(time[2], bullishObTop, bullishObBottom, 1)
        storeOb(bullishObBox, bullishObTop, bullishObBottom, 1, 1, time[2])

// Bearish OB: B1 = bar[2], B2 = bar[1], B3 = current bar.
// Valid only if B2 does not breach B1 high and B3 high stays below B1 low.
if showBearishOB and bar_index >= 2
    bearishObTop = high[2]
    bearishObBottom = low[2]
    bearishC2Respected = high[1] <= bearishObTop
    bearishFvg = high < bearishObBottom
    if bearishC2Respected and bearishFvg
        bearishObBox = buildBox(time[2], bearishObTop, bearishObBottom, 2)
        storeOb(bearishObBox, bearishObTop, bearishObBottom, -1, 2, time[2])

// Same-candle full OBs take priority over wick OBs.
bullishPureObOnCurrentCandle = bar_index >= 2 and low[1] >= low[2] and low > high[2]
bearishPureObOnCurrentCandle = bar_index >= 2 and high[1] <= high[2] and high < low[2]

// Bullish wick OB: current candle sweeps prior low with wick only, prior candle must not be an inside bar.
if showBullishWickOB and bar_index >= 2
    currentNotInside = not isInsideBar(0)
    priorNotInside = not isInsideBar(1)
    bullishWickBodyLow = math.min(open, close)
    bullishWickSweep = low < low[1] and bullishWickBodyLow > low[1]
    if currentNotInside and priorNotInside and bullishWickSweep and not bullishPureObOnCurrentCandle and not realObExistsOnSource(time, 1)
        bullishWickBox = buildBox(time, bullishWickBodyLow, low, 3)
        storeOb(bullishWickBox, bullishWickBodyLow, low, 1, 3, time)

// Bearish wick OB: current candle sweeps prior high with wick only, prior candle must not be an inside bar.
if showBearishWickOB and bar_index >= 2
    currentNotInside = not isInsideBar(0)
    priorNotInside = not isInsideBar(1)
    bearishWickBodyHigh = math.max(open, close)
    bearishWickSweep = high > high[1] and bearishWickBodyHigh < high[1]
    if currentNotInside and priorNotInside and bearishWickSweep and not bearishPureObOnCurrentCandle and not realObExistsOnSource(time, -1)
        bearishWickBox = buildBox(time, high, bearishWickBodyHigh, 4)
        storeOb(bearishWickBox, high, bearishWickBodyHigh, -1, 4, time)
````
