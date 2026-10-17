# [Gadatas]-Ichimoku CandyBox Zones

- url: https://www.tradingview.com/script/dMXNyXNY-Gadatas-Ichimoku-CandyBox-Zones/
- type: indicator
- pine_id: PUB;a0e32287f30749bda94f543162a18897
- version: 1.0

## Description

This indicator identifies supply and demand zones based on a custom Ichimoku Kumo structure called the “Candy Box”.

A Candy Box forms when a short-lived cloud segment appears between two opposite Senkou Span A/B crossovers and remains structurally valid during its formation.

Zones are built from the highest and lowest values of Senkou Span A and B within each cloud segment and are projected forward until price touches them.

⸻

Key Features

* Detects compact Ichimoku cloud segments (Candy Boxes)
* Differentiates supply (above price) and demand (below price) zones
* Two invalidation modes:
    * Standard (any touch invalidates)
    * Full Cloud Fill (only full candle crossover invalidates)
* Dynamic visibility filter to hide zones far from current price
* Zones are preserved internally and reappear when price returns

⸻

Notes

* Not all Kumo twists produce valid zones
* Designed to highlight clean, untouched imbalance areas
* Works best in ranging or transitional market conditions

## Source Code

````pine
//@version=6
indicator("[Gadatas]-Ichimoku CandyBox Zones v1.0", overlay=true, max_boxes_count=300)

// Inputs
conversionPeriods    = input.int(9, "Tenkan")
basePeriods          = input.int(26, "Kijun")
spanBPeriods         = input.int(52, "Senkou B")
displacement         = input.int(25, "Displacement")
showSpans            = input.bool(true, "Plot Senkou A / B")
showDebugMarks       = input.bool(false, "Show Twist Marks")
requireFullCloudFill = input.bool(false, "Invalidate Only On Full Cloud Fill")

useDistanceFilter = input.bool(true, "Hide Distant Zones")
maxDistancePct    = input.float(20.0, "Max Distance %", minval=0.1, step=0.5)

maxCloudBars = input.int(300, "Max Candy Box Length", minval=5, maxval=500)

// Ichimoku
conversionLine = (ta.highest(high, conversionPeriods) + ta.lowest(low, conversionPeriods)) / 2.0
baseLine       = (ta.highest(high, basePeriods) + ta.lowest(low, basePeriods)) / 2.0
senkouA        = (conversionLine + baseLine) / 2.0
senkouB        = (ta.highest(high, spanBPeriods) + ta.lowest(low, spanBPeriods)) / 2.0

plot(showSpans ? senkouA : na, color=color.lime, offset=displacement, title="Senkou A")
plot(showSpans ? senkouB : na, color=color.red,  offset=displacement, title="Senkou B")

// Visible cloud aligned with plotted Kumo
cloudA = senkouA[displacement]
cloudB = senkouB[displacement]

enoughBars = bar_index > (spanBPeriods + displacement + 5)

crossUpRaw   = ta.crossover(cloudA, cloudB)
crossDownRaw = ta.crossunder(cloudA, cloudB)

bullishCross = enoughBars and crossUpRaw
bearishCross = enoughBars and crossDownRaw

plotshape(showDebugMarks and bullishCross, title="Bullish Twist", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.tiny)
plotshape(showDebugMarks and bearishCross, title="Bearish Twist", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.tiny)

// State
var int lastBullishCrossBar  = na
var int lastBearishCrossBar  = na
var int lastBullishCrossTime = na
var int lastBearishCrossTime = na

// Persistent zone registry
var int[]   zoneLeftTimes  = array.new_int()
var int[]   zoneRightTimes = array.new_int()
var float[] zoneTops       = array.new_float()
var float[] zoneBots       = array.new_float()
var bool[]  zoneOpen       = array.new_bool()
var int[]   zoneTypes      = array.new_int()   // 1 = supply, -1 = demand
var bool[]  zoneRendered   = array.new_bool()
var box[]   zoneBoxes      = array.new_box()

invalidateBar(_b, _top, _bot) =>
    requireFullCloudFill ? (high[_b] >= _top and low[_b] <= _bot) : (high[_b] >= _bot and low[_b] <= _top)

zoneAllowedByDistance(_top, _bot) =>
    zoneMid = (_top + _bot) / 2.0
    distancePct = math.abs(zoneMid - close) / close * 100.0
    not useDistanceFilter or distancePct <= maxDistancePct

// Demand zone: red cloud -> green cloud
if bullishCross
    if not na(lastBearishCrossBar) and not na(lastBearishCrossTime)
        segLen = bar_index - lastBearishCrossBar
        if segLen > 0 and segLen <= maxCloudBars
            zoneTop = -1e10
            zoneBot =  1e10
            invalid = false

            for b = 0 to segLen
                cTop = math.max(cloudA[b], cloudB[b])
                cBot = math.min(cloudA[b], cloudB[b])

                zoneTop := math.max(zoneTop, cTop)
                zoneBot := math.min(zoneBot, cBot)

                if invalidateBar(b, cTop, cBot)
                    invalid := true

            if not invalid and zoneTop < low
                array.push(zoneLeftTimes, lastBearishCrossTime)
                array.push(zoneRightTimes, time)
                array.push(zoneTops, zoneTop)
                array.push(zoneBots, zoneBot)
                array.push(zoneOpen, true)
                array.push(zoneTypes, -1)
                array.push(zoneRendered, false)
                array.push(zoneBoxes, na)

    lastBullishCrossBar  := bar_index
    lastBullishCrossTime := time

// Supply zone: green cloud -> red cloud
if bearishCross
    if not na(lastBullishCrossBar) and not na(lastBullishCrossTime)
        segLen = bar_index - lastBullishCrossBar
        if segLen > 0 and segLen <= maxCloudBars
            zoneTop = -1e10
            zoneBot =  1e10
            invalid = false

            for b = 0 to segLen
                cTop = math.max(cloudA[b], cloudB[b])
                cBot = math.min(cloudA[b], cloudB[b])

                zoneTop := math.max(zoneTop, cTop)
                zoneBot := math.min(zoneBot, cBot)

                if invalidateBar(b, cTop, cBot)
                    invalid := true

            if not invalid and zoneBot > high
                array.push(zoneLeftTimes, lastBullishCrossTime)
                array.push(zoneRightTimes, time)
                array.push(zoneTops, zoneTop)
                array.push(zoneBots, zoneBot)
                array.push(zoneOpen, true)
                array.push(zoneTypes, 1)
                array.push(zoneRendered, false)
                array.push(zoneBoxes, na)

    lastBearishCrossBar  := bar_index
    lastBearishCrossTime := time

// Update, render, hide, and close zones
zoneCount = array.size(zoneTops)
if zoneCount > 0
    for i = 0 to zoneCount - 1
        zTop      = array.get(zoneTops, i)
        zBot      = array.get(zoneBots, i)
        zLeftTime = array.get(zoneLeftTimes, i)
        zRightTime= array.get(zoneRightTimes, i)
        zOpen     = array.get(zoneOpen, i)
        zType     = array.get(zoneTypes, i)
        zRendered = array.get(zoneRendered, i)
        zBox      = array.get(zoneBoxes, i)

        if zOpen and high >= zBot and low <= zTop
            zOpen := false
            zRightTime := time
            array.set(zoneOpen, i, zOpen)
            array.set(zoneRightTimes, i, zRightTime)

        visibleNow = zoneAllowedByDistance(zTop, zBot)
        currentRightTime = zOpen ? time : zRightTime
        zoneColor  = zType == 1 ? color.new(color.red, 82) : color.new(color.green, 82)
        zoneBorder = zType == 1 ? color.red : color.green

        if visibleNow
            if not zRendered
                newBox = box.new(
                    left         = zLeftTime,
                    right        = currentRightTime,
                    top          = zTop,
                    bottom       = zBot,
                    xloc         = xloc.bar_time,
                    bgcolor      = zoneColor,
                    border_color = zoneBorder
                )
                array.set(zoneBoxes, i, newBox)
                array.set(zoneRendered, i, true)
            else
                box.set_right(zBox, currentRightTime)
                box.set_top(zBox, zTop)
                box.set_bottom(zBox, zBot)
                box.set_bgcolor(zBox, zoneColor)
                box.set_border_color(zBox, zoneBorder)
        else
            if zRendered
                box.delete(zBox)
                array.set(zoneBoxes, i, na)
                array.set(zoneRendered, i, false)
````
