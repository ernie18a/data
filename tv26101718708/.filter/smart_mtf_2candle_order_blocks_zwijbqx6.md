# Smart MTF 2-Candle Order Blocks

- url: https://www.tradingview.com/script/ZWIjbQX6-Smart-MTF-2-Candle-Order-Blocks/
- type: indicator
- pine_id: PUB;bb9881fa888f4f3f8f81ab211ba35afe
- version: 1.0

## Description

Stacking Order Blocks. Displays all un mitigated order blocks. Shows LTF OB even when on the HTF.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © jonqlam

//@version=6
indicator("Smart MTF 2-Candle Order Blocks", overlay = true, max_boxes_count = 500, dynamic_requests = true)

// Inputs
showBullishOB = input.bool(true, "Show Bullish OBs")
showBearishOB = input.bool(true, "Show Bearish OBs")
deleteOnMitigation = input.bool(true, "Delete When Mitigated")
mitigationCandle = input.int(3, "Delete If Mitigated On/After Candle #", minval = 3)
lookbackDays = input.int(7, "Show OBs From Last X Days", minval = 1)
maxActiveBoxes = input.int(150, "Max Active Boxes", minval = 10, maxval = 450)

// Colors
bullColor = input.color(color.new(color.lime, 85), "Bullish Fill")
bearColor = input.color(color.new(color.red, 85), "Bearish Fill")
bullBorder = input.color(color.green, "Bullish Border")
bearBorder = input.color(color.red, "Bearish Border")

// Time settings
lookbackMS = lookbackDays * 24 * 60 * 60 * 1000
chartTF = timeframe.in_seconds(timeframe.period) / 60
currTFms = int(timeframe.in_seconds(timeframe.period) * 1000)

// Storage
var bullBoxes = array.new_box()
var bearBoxes = array.new_box()
var bullCreatedTimes = array.new_int()
var bearCreatedTimes = array.new_int()
var bullTFms = array.new_int()
var bearTFms = array.new_int()
var drawnKeys = array.new_string()

// Timeframe minutes to milliseconds
f_tfMS(tfMin) =>
    int(tfMin * 60 * 1000)

// Earliest time mitigation is allowed
// Candle 1 = OB candle
// Candle 2 = engulfing candle
// Candle 3 = next candle after engulfing candle
f_mitigationStartTime(createdTime, tfMS) =>
    createdTime + tfMS * (mitigationCandle - 2)

// OB logic
f_bullOB() =>
    close[1] < open[1] and close > open and close > high[1]

f_bearOB() =>
    close[1] > open[1] and close < open and close < low[1]

// Duplicate protection
f_alreadyDrawn(_key) =>
    found = false
    if array.size(drawnKeys) > 0
        for i = 0 to array.size(drawnKeys) - 1
            if array.get(drawnKeys, i) == _key
                found := true
    found

// Trim boxes
f_trimBoxes() =>
    while array.size(bullBoxes) + array.size(bearBoxes) > maxActiveBoxes
        if array.size(bullBoxes) > 0
            oldBox = array.shift(bullBoxes)
            box.delete(oldBox)
            array.shift(bullCreatedTimes)
            array.shift(bullTFms)
        else if array.size(bearBoxes) > 0
            oldBox = array.shift(bearBoxes)
            box.delete(oldBox)
            array.shift(bearCreatedTimes)
            array.shift(bearTFms)

// Draw OB
f_draw(_bull, _bear, _top, _bottom, _leftTime, _rightTime, _tfMS, _tfName) =>
    recent = _rightTime >= timenow - lookbackMS

    bullKey = _tfName + "_BULL_" + str.tostring(_rightTime)
    bearKey = _tfName + "_BEAR_" + str.tostring(_rightTime)

    if recent
        if _bull and showBullishOB and not f_alreadyDrawn(bullKey)
            b = box.new(
                left = _leftTime,
                right = _rightTime,
                top = _top,
                bottom = _bottom,
                xloc = xloc.bar_time,
                bgcolor = bullColor,
                border_color = bullBorder
            )
            box.set_extend(b, extend.right)
            array.push(bullBoxes, b)
            array.push(bullCreatedTimes, _rightTime)
            array.push(bullTFms, _tfMS)
            array.push(drawnKeys, bullKey)

        if _bear and showBearishOB and not f_alreadyDrawn(bearKey)
            b = box.new(
                left = _leftTime,
                right = _rightTime,
                top = _top,
                bottom = _bottom,
                xloc = xloc.bar_time,
                bgcolor = bearColor,
                border_color = bearBorder
            )
            box.set_extend(b, extend.right)
            array.push(bearBoxes, b)
            array.push(bearCreatedTimes, _rightTime)
            array.push(bearTFms, _tfMS)
            array.push(drawnKeys, bearKey)

        f_trimBoxes()

// Current timeframe OB
f_draw(
    f_bullOB(),
    f_bearOB(),
    high[1],
    low[1],
    time[1],
    time,
    currTFms,
    timeframe.period
)

// Process lower timeframe OBs
f_processLowerTF(tf, tfMin, enabled) =>
    if enabled
        bullArr = request.security_lower_tf(syminfo.tickerid, tf, f_bullOB())
        bearArr = request.security_lower_tf(syminfo.tickerid, tf, f_bearOB())
        topArr = request.security_lower_tf(syminfo.tickerid, tf, high[1])
        botArr = request.security_lower_tf(syminfo.tickerid, tf, low[1])
        leftArr = request.security_lower_tf(syminfo.tickerid, tf, time[1])
        rightArr = request.security_lower_tf(syminfo.tickerid, tf, time)

        arrSize = array.size(bullArr)

        if arrSize > 0
            for i = 0 to arrSize - 1
                bullSig = array.get(bullArr, i)
                bearSig = array.get(bearArr, i)

                if bullSig or bearSig
                    f_draw(
                        bullSig,
                        bearSig,
                        array.get(topArr, i),
                        array.get(botArr, i),
                        array.get(leftArr, i),
                        array.get(rightArr, i),
                        f_tfMS(tfMin),
                        tf
                    )

// Clean mitigation with lower timeframe candles
f_cleanWithLowerTF(tf, enabled) =>
    if deleteOnMitigation and enabled
        hiArr = request.security_lower_tf(syminfo.tickerid, tf, high)
        loArr = request.security_lower_tf(syminfo.tickerid, tf, low)
        tArr = request.security_lower_tf(syminfo.tickerid, tf, time)

        arrSize = array.size(tArr)

        if arrSize > 0
            bullIndex = array.size(bullBoxes) - 1

            while bullIndex >= 0
                b = array.get(bullBoxes, bullIndex)
                createdTime = array.get(bullCreatedTimes, bullIndex)
                tfMS = array.get(bullTFms, bullIndex)

                top = box.get_top(b)
                bottom = box.get_bottom(b)

                removeBox = false
                startTime = f_mitigationStartTime(createdTime, tfMS)

                for i = 0 to arrSize - 1
                    t = array.get(tArr, i)
                    h = array.get(hiArr, i)
                    l = array.get(loArr, i)

                    touched = l <= top and h >= bottom
                    oldEnough = t >= startTime

                    if oldEnough and touched
                        removeBox := true

                if removeBox
                    box.delete(b)
                    array.remove(bullBoxes, bullIndex)
                    array.remove(bullCreatedTimes, bullIndex)
                    array.remove(bullTFms, bullIndex)

                bullIndex -= 1

            bearIndex = array.size(bearBoxes) - 1

            while bearIndex >= 0
                b = array.get(bearBoxes, bearIndex)
                createdTime = array.get(bearCreatedTimes, bearIndex)
                tfMS = array.get(bearTFms, bearIndex)

                top = box.get_top(b)
                bottom = box.get_bottom(b)

                removeBox = false
                startTime = f_mitigationStartTime(createdTime, tfMS)

                for i = 0 to arrSize - 1
                    t = array.get(tArr, i)
                    h = array.get(hiArr, i)
                    l = array.get(loArr, i)

                    touched = h >= bottom and l <= top
                    oldEnough = t >= startTime

                    if oldEnough and touched
                        removeBox := true

                if removeBox
                    box.delete(b)
                    array.remove(bearBoxes, bearIndex)
                    array.remove(bearCreatedTimes, bearIndex)
                    array.remove(bearTFms, bearIndex)

                bearIndex -= 1

// Clean mitigation on current chart timeframe
f_cleanCurrentTF() =>
    if deleteOnMitigation
        bullIndex = array.size(bullBoxes) - 1

        while bullIndex >= 0
            b = array.get(bullBoxes, bullIndex)
            createdTime = array.get(bullCreatedTimes, bullIndex)
            tfMS = array.get(bullTFms, bullIndex)

            top = box.get_top(b)
            bottom = box.get_bottom(b)

            startTime = f_mitigationStartTime(createdTime, tfMS)
            oldEnough = time >= startTime
            touched = low <= top and high >= bottom

            if oldEnough and touched
                box.delete(b)
                array.remove(bullBoxes, bullIndex)
                array.remove(bullCreatedTimes, bullIndex)
                array.remove(bullTFms, bullIndex)

            bullIndex -= 1

        bearIndex = array.size(bearBoxes) - 1

        while bearIndex >= 0
            b = array.get(bearBoxes, bearIndex)
            createdTime = array.get(bearCreatedTimes, bearIndex)
            tfMS = array.get(bearTFms, bearIndex)

            top = box.get_top(b)
            bottom = box.get_bottom(b)

            startTime = f_mitigationStartTime(createdTime, tfMS)
            oldEnough = time >= startTime
            touched = high >= bottom and low <= top

            if oldEnough and touched
                box.delete(b)
                array.remove(bearBoxes, bearIndex)
                array.remove(bearCreatedTimes, bearIndex)
                array.remove(bearTFms, bearIndex)

            bearIndex -= 1

// Lower TFs only show when chart TF is higher
f_processLowerTF("1", 1, chartTF > 1)
f_processLowerTF("3", 3, chartTF > 3)
f_processLowerTF("5", 5, chartTF > 5)
f_processLowerTF("15", 15, chartTF > 15)
f_processLowerTF("30", 30, chartTF > 30)
f_processLowerTF("60", 60, chartTF > 60)
f_processLowerTF("240", 240, chartTF > 240)

// Lower TF mitigation cleanup
f_cleanWithLowerTF("1", chartTF > 1)
f_cleanWithLowerTF("3", chartTF > 3)
f_cleanWithLowerTF("5", chartTF > 5)
f_cleanWithLowerTF("15", chartTF > 15)
f_cleanWithLowerTF("30", chartTF > 30)
f_cleanWithLowerTF("60", chartTF > 60)
f_cleanWithLowerTF("240", chartTF > 240)

// Current TF cleanup
f_cleanCurrentTF()
````
