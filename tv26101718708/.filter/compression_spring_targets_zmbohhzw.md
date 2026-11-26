#  Compression Spring Targets

- url: https://www.tradingview.com/script/zmBOhHzw-Compression-Spring-Targets/
- type: indicator
- pine_id: PUB;580541903d9f4ebc821489ada7f44308
- version: 1.0

## Description

Compression Spring Targets
Compression Spring Targets Compression Spring Targets Compression Spring Targets Compression Spring Targets Compression Spring Targets Compression Spring Targets

## Source Code

````pine
//@version=6
indicator("5 Minute Compression Spring Targets", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
blockTF = input.timeframe("5", "Block Timeframe")

compareLen = input.int(10, "Compare To Previous Blocks", minval=2, maxval=100)
maxObjects = input.int(100, "Max Objects On Chart", minval=10, maxval=500)

// Compression definition
rangeLowRatio = input.float(0.85, "Compression Max Range Ratio", minval=0.1, step=0.01)
volumeMinRatio = input.float(0.95, "Compression Min Volume Ratio", minval=0.1, step=0.01)

minCompressionBlocks = input.int(2, "Min Compression Blocks", minval=1, maxval=20)
maxGapBlocks = input.int(1, "Max Non-Compression Gaps Allowed", minval=0, maxval=10)

// Breakout definition
breakoutMode = input.string("Close", "Breakout Mode", options=["Close", "Wick"])
requireBreakoutVolume = input.bool(true, "Require Breakout Volume Expansion")
breakoutVolumeRatio = input.float(1.05, "Breakout Min Volume Ratio", minval=0.1, step=0.01)
breakoutRangeRatio = input.float(1.00, "Breakout Min Range Ratio", minval=0.1, step=0.01)

// Target settings
targetEnergyMult = input.float(0.50, "Energy Target Multiplier", minval=0.1, step=0.1)
maxTargetMult = input.float(3.0, "Max Target Multiple Of Box Height", minval=0.5, step=0.25)

showTarget1 = input.bool(true, "Show Target 1")
showTarget2 = input.bool(true, "Show Target 2")
freezeAfterBreakout = input.bool(true, "Freeze Box After Breakout")

// Style
springColor = input.color(color.new(color.blue, 82), "Compression Spring Box Color")
brokenBullColor = input.color(color.new(color.lime, 85), "Bull Breakout Box Color")
brokenBearColor = input.color(color.new(color.red, 85), "Bear Breakout Box Color")

bullTargetColor = input.color(color.lime, "Bull Target Color")
bearTargetColor = input.color(color.red, "Bear Target Color")
midColor = input.color(color.new(color.white, 70), "Box Midline Color")

showLabels = input.bool(true, "Show Labels")
showMidline = input.bool(true, "Show Spring Midline")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Helpers
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
avgArray(float[] arr) =>
    float sum = 0.0
    int size = array.size(arr)

    if size == 0
        na
    else
        for i = 0 to size - 1
            sum += array.get(arr, i)
        sum / size

pushLimitedFloat(float[] arr, float value, int maxSize) =>
    array.unshift(arr, value)
    if array.size(arr) > maxSize
        array.pop(arr)

pushLimitedBox(box[] arr, box value, int maxSize) =>
    array.unshift(arr, value)
    if array.size(arr) > maxSize
        old = array.pop(arr)
        box.delete(old)

pushLimitedLine(line[] arr, line value, int maxSize) =>
    array.unshift(arr, value)
    if array.size(arr) > maxSize
        old = array.pop(arr)
        line.delete(old)

pushLimitedLabel(label[] arr, label value, int maxSize) =>
    array.unshift(arr, value)
    if array.size(arr) > maxSize
        old = array.pop(arr)
        label.delete(old)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Storage
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float[] rangeArr = array.new_float()
var float[] volArr = array.new_float()

var box[] springBoxes = array.new_box()
var line[] targetLines = array.new_line()
var line[] midLines = array.new_line()
var label[] springLabels = array.new_label()

// Current 5m block
var int blockStartIndex = na
var float blockOpen = na
var float blockHigh = na
var float blockLow = na
var float blockClose = na
var float blockVol = 0.0

// Active spring state
var bool springActive = false
var bool springBroken = false
var int springStartIndex = na
var int springEndIndex = na
var float springHigh = na
var float springLow = na
var int compressionCount = 0
var int gapCount = 0
var float compressionVolRatioSum = 0.0
var box activeSpringBox = na
var line activeMidLine = na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Block Detection
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
newBlock = timeframe.change(blockTF)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Finalize Previous Block
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if newBlock and not na(blockStartIndex)
    blockEndIndex = bar_index - 1
    blockClose := close[1]

    blockRange = blockHigh - blockLow
    blockVolume = math.max(blockVol, 1.0)

    avgRange = avgArray(rangeArr)
    avgVol = avgArray(volArr)
    enoughData = array.size(rangeArr) >= compareLen

    if enoughData and avgRange > 0 and avgVol > 0
        rangeRatio = blockRange / avgRange
        volumeRatio = blockVolume / avgVol

        isCompression =
             rangeRatio <= rangeLowRatio and
             volumeRatio >= volumeMinRatio

        breakoutVolPass = not requireBreakoutVolume or volumeRatio >= breakoutVolumeRatio
        breakoutRangePass = rangeRatio >= breakoutRangeRatio

        if springActive and not springBroken
            bullBreak =
                 breakoutMode == "Close" ?
                 blockClose > springHigh :
                 blockHigh > springHigh

            bearBreak =
                 breakoutMode == "Close" ?
                 blockClose < springLow :
                 blockLow < springLow

            validBreakout =
                 (bullBreak or bearBreak) and
                 breakoutVolPass and
                 breakoutRangePass and
                 compressionCount >= minCompressionBlocks

            if validBreakout
                springBroken := true
                springEndIndex := blockEndIndex

                boxHeight = math.max(springHigh - springLow, syminfo.mintick)
                avgCompressionVolRatio = compressionCount > 0 ? compressionVolRatioSum / compressionCount : 1.0

                rawEnergy = compressionCount * avgCompressionVolRatio * targetEnergyMult
                energyMult = math.min(rawEnergy, maxTargetMult)

                targetDistance = boxHeight * energyMult

                bullTarget1 = springHigh + boxHeight
                bullTarget2 = springHigh + targetDistance

                bearTarget1 = springLow - boxHeight
                bearTarget2 = springLow - targetDistance

                if not na(activeSpringBox)
                    box.set_right(activeSpringBox, blockEndIndex)
                    box.set_bgcolor(activeSpringBox, bullBreak ? brokenBullColor : brokenBearColor)

                if not na(activeMidLine)
                    line.set_x2(activeMidLine, blockEndIndex)

                targetColor = bullBreak ? bullTargetColor : bearTargetColor

                if bullBreak
                    if showTarget1
                        t1 = line.new(
                             x1=blockEndIndex,
                             y1=bullTarget1,
                             x2=blockEndIndex + 30,
                             y2=bullTarget1,
                             xloc=xloc.bar_index,
                             color=targetColor,
                             width=2,
                             style=line.style_solid
                        )
                        pushLimitedLine(targetLines, t1, maxObjects)

                    if showTarget2
                        t2 = line.new(
                             x1=blockEndIndex,
                             y1=bullTarget2,
                             x2=blockEndIndex + 30,
                             y2=bullTarget2,
                             xloc=xloc.bar_index,
                             color=targetColor,
                             width=2,
                             style=line.style_dashed
                        )
                        pushLimitedLine(targetLines, t2, maxObjects)

                if bearBreak
                    if showTarget1
                        t1 = line.new(
                             x1=blockEndIndex,
                             y1=bearTarget1,
                             x2=blockEndIndex + 30,
                             y2=bearTarget1,
                             xloc=xloc.bar_index,
                             color=targetColor,
                             width=2,
                             style=line.style_solid
                        )
                        pushLimitedLine(targetLines, t1, maxObjects)

                    if showTarget2
                        t2 = line.new(
                             x1=blockEndIndex,
                             y1=bearTarget2,
                             x2=blockEndIndex + 30,
                             y2=bearTarget2,
                             xloc=xloc.bar_index,
                             color=targetColor,
                             width=2,
                             style=line.style_dashed
                        )
                        pushLimitedLine(targetLines, t2, maxObjects)

                if showLabels
                    txt = bullBreak ? "Bull Spring Breakout" : "Bear Spring Breakout"
                    txt += "\nBlocks: " + str.tostring(compressionCount)
                    txt += "\nAvgVolR: " + str.tostring(avgCompressionVolRatio, "#.00")
                    txt += "\nEnergy: " + str.tostring(energyMult, "#.00") + "x"

                    lbl = label.new(
                         x=blockEndIndex,
                         y=bullBreak ? springHigh : springLow,
                         text=txt,
                         xloc=xloc.bar_index,
                         style=bullBreak ? label.style_label_down : label.style_label_up,
                         color=color.new(color.black, 10),
                         textcolor=color.white,
                         size=size.small
                    )
                    pushLimitedLabel(springLabels, lbl, maxObjects)

                // Reset after breakout
                springActive := false
                springBroken := false
                springStartIndex := na
                springEndIndex := na
                springHigh := na
                springLow := na
                compressionCount := 0
                gapCount := 0
                compressionVolRatioSum := 0.0
                activeSpringBox := na
                activeMidLine := na

            else
                // Extend active spring box while waiting
                if not na(activeSpringBox)
                    box.set_right(activeSpringBox, blockEndIndex)

                if not na(activeMidLine)
                    line.set_x2(activeMidLine, blockEndIndex)

                if isCompression
                    compressionCount += 1
                    compressionVolRatioSum += volumeRatio
                    gapCount := 0

                    springHigh := math.max(springHigh, blockHigh)
                    springLow := math.min(springLow, blockLow)

                    if not na(activeSpringBox)
                        box.set_top(activeSpringBox, springHigh)
                        box.set_bottom(activeSpringBox, springLow)

                    if not na(activeMidLine)
                        mid = (springHigh + springLow) / 2.0
                        line.set_y1(activeMidLine, mid)
                        line.set_y2(activeMidLine, mid)

                else
                    gapCount += 1

                    if gapCount > maxGapBlocks
                        springActive := false
                        springBroken := false
                        springStartIndex := na
                        springEndIndex := na
                        springHigh := na
                        springLow := na
                        compressionCount := 0
                        gapCount := 0
                        compressionVolRatioSum := 0.0
                        activeSpringBox := na
                        activeMidLine := na

        else
            if isCompression
                springActive := true
                springBroken := false
                springStartIndex := blockStartIndex
                springEndIndex := blockEndIndex
                springHigh := blockHigh
                springLow := blockLow
                compressionCount := 1
                gapCount := 0
                compressionVolRatioSum := volumeRatio

                b = box.new(
                     left=springStartIndex,
                     top=springHigh,
                     right=blockEndIndex,
                     bottom=springLow,
                     xloc=xloc.bar_index,
                     bgcolor=springColor,
                     border_color=color.new(color.blue, 35)
                )
                activeSpringBox := b
                pushLimitedBox(springBoxes, b, maxObjects)

                if showMidline
                    mid = (springHigh + springLow) / 2.0
                    ml = line.new(
                         x1=springStartIndex,
                         y1=mid,
                         x2=blockEndIndex,
                         y2=mid,
                         xloc=xloc.bar_index,
                         color=midColor,
                         width=1,
                         style=line.style_dotted
                    )
                    activeMidLine := ml
                    pushLimitedLine(midLines, ml, maxObjects)

    // Store previous block stats after comparison
    pushLimitedFloat(rangeArr, blockRange, compareLen)
    pushLimitedFloat(volArr, blockVolume, compareLen)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Start / Update Current Block
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if newBlock or na(blockStartIndex)
    blockStartIndex := bar_index
    blockOpen := open
    blockHigh := high
    blockLow := low
    blockVol := nz(volume)
else
    blockHigh := math.max(blockHigh, high)
    blockLow := math.min(blockLow, low)
    blockVol += nz(volume)
````
