# Temnimenee 4H FVG Zones

- url: https://www.tradingview.com/script/IBB7yUPt-temnimenee-4h-fvg-zones/
- type: indicator
- pine_id: PUB;f49bbeed37964b5aae9c6e0af8b0eb67
- version: 1.0

## Description

Temnimenee 4H FVG Zones
Temnimenee 4H FVG Zones is a higher-timeframe Fair Value Gap visualization tool built specifically for ICT and Smart Money Concepts traders.

Unlike traditional FVG indicators that simply project higher timeframe gaps from the beginning of a candle, Temnimenee 4H FVG Zones locates the actual lower timeframe candle where the imbalance was created, providing a much more accurate representation of institutional price delivery.

Features
Higher Timeframe FVG Projection

Display Fair Value Gaps from a higher timeframe directly on any lower timeframe chart.

Supported workflow includes:

4H FVG on 1H
4H FVG on 15m
4H FVG on 5m
4H FVG on 1m

The indicator keeps all higher timeframe imbalances perfectly aligned regardless of the chart timeframe.

Precise Origin Detection

One of the key features of Temnimenee 4H FVG Zones.

Instead of drawing every Fair Value Gap from the opening time of the higher timeframe candle, the script automatically searches for the exact lower timeframe candle that created the imbalance.

This produces significantly cleaner charts and allows traders to see where institutional imbalance actually originated.

Bullish & Bearish Fair Value Gaps

Displays both:

Bullish FVG
Bearish FVG

Each can be styled independently.

Custom Appearance

Fully customizable:

Fill color
Border color
Border width
Border style
Midpoint (50%) line
Midpoint color
Midpoint style
Midpoint width
Mitigation Handling

Choose how mitigated Fair Value Gaps should behave:

Keep active
Remove after mitigation
Grey out after mitigation

This allows traders to decide whether historical imbalances should remain visible for market context.

Historical FVGs

Configure how much history to display.

Older Fair Value Gaps remain available for structural analysis while keeping the chart clean and responsive.

Designed for

Temnimenee 4H FVG Zones was created for traders using:

ICT (Inner Circle Trader)
Smart Money Concepts (SMC)
Fair Value Gap Trading
Silver Bullet
Power of Three (PO3)
Liquidity Concepts
Institutional Order Flow
Premium & Discount Arrays
Why FVG Pro?

Most Fair Value Gap indicators simply project higher timeframe zones onto lower timeframe charts.

Temnimenee 4H FVG Zones goes one step further by identifying the exact lower timeframe origin of each imbalance, making the displayed zones more precise and easier to use during execution.

This provides better visual context when combining Fair Value Gaps with liquidity sweeps, market structure, displacement, and session models.

Philosophy

Temnimenee 4H FVG Zones was designed with one goal:

Accuracy over complexity.

No repainting.

No unnecessary calculations.

No misleading projections.

Only precise higher timeframe Fair Value Gaps displayed exactly where they originated.

## Source Code

````pine
//@version=6
indicator("Temnimenee 4H FVG Zones", overlay=true, max_boxes_count=500, max_lines_count=500)

// === MAIN SETTINGS ===
keepDays = input.int(30, "Keep FVG for days", minval=1)
removeMitigated = input.bool(false, "Remove when mitigated")
maxZones = input.int(200, "Max zones", minval=10, maxval=500)

// === COLORS ===
grpColors = "FVG Fill"
bullColor = input.color(color.new(color.lime, 85), "Bullish FVG fill", group=grpColors)
bearColor = input.color(color.new(color.red, 85), "Bearish FVG fill", group=grpColors)
mitigatedColor = input.color(color.new(color.gray, 90), "Mitigated fill", group=grpColors)

// === BORDER SETTINGS ===
grpBorder = "Border"
showBorder = input.bool(true, "Show border", group=grpBorder)
borderColor = input.color(color.new(color.gray, 40), "Border color", group=grpBorder)
borderTransparency = input.int(40, "Border transparency", minval=0, maxval=100, group=grpBorder)

// === MIDDLE LINE SETTINGS ===
grpMiddle = "Middle line"
showMiddle = input.bool(true, "Show middle line", group=grpMiddle)
middleColor = input.color(color.new(color.gray, 20), "Middle line color", group=grpMiddle)
middleTransparency = input.int(20, "Middle line transparency", minval=0, maxval=100, group=grpMiddle)
middleStyleInput = input.string("Dashed", "Middle line style", options=["Solid", "Dashed", "Dotted"], group=grpMiddle)
middleWidth = input.int(1, "Middle line width", minval=1, maxval=5, group=grpMiddle)

middleStyle = middleStyleInput == "Solid" ? line.style_solid : middleStyleInput == "Dashed" ? line.style_dashed : line.style_dotted
finalBorderColor = showBorder ? color.new(borderColor, borderTransparency) : color.new(borderColor, 100)
finalMiddleColor = color.new(middleColor, middleTransparency)

// === 4H MANUAL BUILD FROM 15M ===
h4Time = time("240")
newH4 = ta.change(h4Time) != 0

var float curH4High = na
var float curH4Low = na
var int curH4HighTime = na
var int curH4LowTime = na

var float[] h4Highs = array.new_float()
var float[] h4Lows = array.new_float()
var int[] h4HighTimes = array.new_int()
var int[] h4LowTimes = array.new_int()

// === DRAWN FVG ARRAYS ===
var box[] fvgBoxes = array.new_box()
var line[] midLines = array.new_line()
var int[] fvgTimes = array.new_int()
var int[] fvgDirs = array.new_int()
var bool[] fvgMitigated = array.new_bool()

// === INIT / UPDATE 4H CANDLE ===
if na(curH4High)
    curH4High := high
    curH4Low := low
    curH4HighTime := time
    curH4LowTime := time

if newH4
    array.push(h4Highs, curH4High)
    array.push(h4Lows, curH4Low)
    array.push(h4HighTimes, curH4HighTime)
    array.push(h4LowTimes, curH4LowTime)

    if array.size(h4Highs) > 10
        array.shift(h4Highs)
        array.shift(h4Lows)
        array.shift(h4HighTimes)
        array.shift(h4LowTimes)

    if array.size(h4Highs) >= 3
        last = array.size(h4Highs) - 1
        twoBack = array.size(h4Highs) - 3

        lastHigh = array.get(h4Highs, last)
        lastLow = array.get(h4Lows, last)
        twoBackHigh = array.get(h4Highs, twoBack)
        twoBackLow = array.get(h4Lows, twoBack)
        twoBackHighTime = array.get(h4HighTimes, twoBack)
        twoBackLowTime = array.get(h4LowTimes, twoBack)

        bullFVG = lastLow > twoBackHigh
        bearFVG = lastHigh < twoBackLow

        if bullFVG
            top = lastLow
            bottom = twoBackHigh
            mid = (top + bottom) / 2.0
            bx = box.new(left=twoBackHighTime, top=top, right=time, bottom=bottom, xloc=xloc.bar_time, bgcolor=bullColor, border_color=finalBorderColor)
            ml = line.new(x1=twoBackHighTime, y1=mid, x2=time, y2=mid, xloc=xloc.bar_time, color=showMiddle ? finalMiddleColor : color.new(finalMiddleColor, 100), style=middleStyle, width=middleWidth)
            array.push(fvgBoxes, bx)
            array.push(midLines, ml)
            array.push(fvgTimes, time)
            array.push(fvgDirs, 1)
            array.push(fvgMitigated, false)

        if bearFVG
            top = twoBackLow
            bottom = lastHigh
            mid = (top + bottom) / 2.0
            bx = box.new(left=twoBackLowTime, top=top, right=time, bottom=bottom, xloc=xloc.bar_time, bgcolor=bearColor, border_color=finalBorderColor)
            ml = line.new(x1=twoBackLowTime, y1=mid, x2=time, y2=mid, xloc=xloc.bar_time, color=showMiddle ? finalMiddleColor : color.new(finalMiddleColor, 100), style=middleStyle, width=middleWidth)
            array.push(fvgBoxes, bx)
            array.push(midLines, ml)
            array.push(fvgTimes, time)
            array.push(fvgDirs, -1)
            array.push(fvgMitigated, false)

    curH4High := high
    curH4Low := low
    curH4HighTime := time
    curH4LowTime := time
else
    if high > curH4High
        curH4High := high
        curH4HighTime := time
    if low < curH4Low
        curH4Low := low
        curH4LowTime := time

// === MANAGE FVG ===
maxAgeMs = keepDays * 24 * 60 * 60 * 1000
barMs = timeframe.in_seconds(timeframe.period) * 1000

if array.size(fvgBoxes) > 0
    for i = array.size(fvgBoxes) - 1 to 0
        bx = array.get(fvgBoxes, i)
        ml = array.get(midLines, i)
        created = array.get(fvgTimes, i)
        dir = array.get(fvgDirs, i)
        mitigated = array.get(fvgMitigated, i)

        top = box.get_top(bx)
        bottom = box.get_bottom(bx)
        tooOld = time - created > maxAgeMs

        touched = false
        if dir == 1
            touched := low <= bottom
        if dir == -1
            touched := high >= top

        if touched and not mitigated
            mitigated := true
            array.set(fvgMitigated, i, true)
            box.set_bgcolor(bx, mitigatedColor)
            box.set_border_color(bx, finalBorderColor)
            box.set_right(bx, time + barMs)
            line.set_x2(ml, time + barMs)

        if not mitigated
            box.set_right(bx, time)
            line.set_x2(ml, time)

        if tooOld or (removeMitigated and mitigated)
            box.delete(bx)
            line.delete(ml)
            array.remove(fvgBoxes, i)
            array.remove(midLines, i)
            array.remove(fvgTimes, i)
            array.remove(fvgDirs, i)
            array.remove(fvgMitigated, i)

// === LIMIT ZONES ===
while array.size(fvgBoxes) > maxZones
    oldBox = array.shift(fvgBoxes)
    oldLine = array.shift(midLines)
    box.delete(oldBox)
    line.delete(oldLine)
    array.shift(fvgTimes)
    array.shift(fvgDirs)
    array.shift(fvgMitigated)
````
