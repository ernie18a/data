# Repricing Channel 

- url: https://www.tradingview.com/script/lSsYBf5X-Repricing-Channel/
- type: indicator
- pine_id: PUB;469441eed1e24fc4941360eacf1bb89a
- version: 1.0

## Description

A channel built on the mean or reprice of the current price 
Repricing Channel Repricing Channel Repricing Channel Repricing Channel Repricing Channel Repricing Channel Repricing Channel Repricing Channel Repricing Channel Repricing Channel Repricing Channel Repricing Channel Repricing Channel Repricing Channel Repricing Channel Repricing Channel Repricing Channel Repricing Channel Repricing Channel Repricing Channel

## Source Code

````pine
//@version=6
indicator("5 Minute Repricing Channel", overlay=true, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
blockTF = input.timeframe("5", "Block Timeframe")

compareLen = input.int(10, "Compare To Previous Blocks", minval=2, maxval=100)
channelLen = input.int(10, "Repricing Blocks In Channel", minval=2, maxval=100)

// High-efficiency / repricing definition
efficiencyHigh = input.float(1.20, "Min Efficiency Ratio", minval=0.1, step=0.01)
rangeMinRatio = input.float(1.00, "Min Range Ratio", minval=0.1, step=0.01)
volumeMaxRatio = input.float(1.05, "Max Volume Ratio", minval=0.1, step=0.01)

useVolumeCap = input.bool(true, "Require Volume Not Too High")

// Channel settings
channelWidthMode = input.string("Average Repricing Range", "Channel Width Mode", options=["Average Repricing Range", "High Low Envelope"])
channelMult = input.float(1.0, "Channel Width Multiplier", minval=0.1, step=0.1)

showCenterline = input.bool(true, "Show Centerline")
showChannel = input.bool(true, "Show Channel")
showLabels = input.bool(true, "Show Repricing Labels")
showBackground = input.bool(true, "Show Repricing Background")

// Colors
bullColor = input.color(color.lime, "Bull Repricing Color")
bearColor = input.color(color.red, "Bear Repricing Color")
neutralColor = input.color(color.gray, "Neutral Channel Color")

bullBg = input.color(color.new(color.lime, 92), "Bull Repricing Background")
bearBg = input.color(color.new(color.red, 92), "Bear Repricing Background")

channelFillColor = input.color(color.new(color.orange, 88), "Channel Fill Color")

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

highestArray(float[] arr) =>
    float highest = na
    int size = array.size(arr)

    if size == 0
        na
    else
        for i = 0 to size - 1
            v = array.get(arr, i)
            highest := na(highest) ? v : math.max(highest, v)
        highest

lowestArray(float[] arr) =>
    float lowest = na
    int size = array.size(arr)

    if size == 0
        na
    else
        for i = 0 to size - 1
            v = array.get(arr, i)
            lowest := na(lowest) ? v : math.min(lowest, v)
        lowest

pushLimitedFloat(float[] arr, float value, int maxSize) =>
    array.unshift(arr, value)
    if array.size(arr) > maxSize
        array.pop(arr)

pushLimitedLabel(label[] arr, label value, int maxSize) =>
    array.unshift(arr, value)
    if array.size(arr) > maxSize
        oldLabel = array.pop(arr)
        label.delete(oldLabel)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Storage
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float[] rangeArr = array.new_float()
var float[] volArr = array.new_float()
var float[] effArr = array.new_float()

var float[] repricingMidArr = array.new_float()
var float[] repricingHighArr = array.new_float()
var float[] repricingLowArr = array.new_float()
var float[] repricingRangeArr = array.new_float()
var float[] repricingDirectionArr = array.new_float()

var label[] labels = array.new_label()

// Current block
var int blockStartIndex = na
var float blockOpen = na
var float blockHigh = na
var float blockLow = na
var float blockVol = 0.0

// Outputs
var float channelCenter = na
var float channelUpper = na
var float channelLower = na
var int repricingBias = 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Block Detection
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
newBlock = timeframe.change(blockTF)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Finalize Previous Block
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if newBlock and not na(blockStartIndex)
    blockEndIndex = bar_index - 1
    blockClose = close[1]

    blockRange = math.max(blockHigh - blockLow, syminfo.mintick)
    blockVolume = math.max(blockVol, 1.0)
    blockMid = (blockHigh + blockLow) / 2.0

    blockEfficiency = blockRange / blockVolume

    avgRange = avgArray(rangeArr)
    avgVol = avgArray(volArr)
    avgEff = avgArray(effArr)

    enoughData = array.size(rangeArr) >= compareLen

    if enoughData and avgRange > 0 and avgVol > 0 and avgEff > 0
        rangeRatio = blockRange / avgRange
        volumeRatio = blockVolume / avgVol
        efficiencyRatio = blockEfficiency / avgEff

        volumePass = not useVolumeCap or volumeRatio <= volumeMaxRatio

        isRepricing =
             efficiencyRatio >= efficiencyHigh and
             rangeRatio >= rangeMinRatio and
             volumePass

        if isRepricing
            isBull = blockClose >= blockOpen
            isBear = blockClose < blockOpen

            direction = isBull ? 1.0 : -1.0

            pushLimitedFloat(repricingMidArr, blockMid, channelLen)
            pushLimitedFloat(repricingHighArr, blockHigh, channelLen)
            pushLimitedFloat(repricingLowArr, blockLow, channelLen)
            pushLimitedFloat(repricingRangeArr, blockRange, channelLen)
            pushLimitedFloat(repricingDirectionArr, direction, channelLen)

            channelCenter := avgArray(repricingMidArr)

            avgRepricingRange = avgArray(repricingRangeArr)

            if channelWidthMode == "High Low Envelope"
                channelUpper := highestArray(repricingHighArr)
                channelLower := lowestArray(repricingLowArr)
            else
                channelUpper := channelCenter + avgRepricingRange * channelMult
                channelLower := channelCenter - avgRepricingRange * channelMult

            dirAvg = avgArray(repricingDirectionArr)

            repricingBias :=
                 dirAvg > 0.25 ? 1 :
                 dirAvg < -0.25 ? -1 :
                 0

            if showLabels
                txt = isBull ? "Bull Repricing" : "Bear Repricing"
                txt += "\nEff: " + str.tostring(efficiencyRatio, "#.00")
                txt += "\nR: " + str.tostring(rangeRatio, "#.00")
                txt += " V: " + str.tostring(volumeRatio, "#.00")

                lbl = label.new(
                     x=blockEndIndex,
                     y=isBull ? blockHigh : blockLow,
                     text=txt,
                     xloc=xloc.bar_index,
                     style=isBull ? label.style_label_down : label.style_label_up,
                     color=color.new(color.black, 10),
                     textcolor=color.white,
                     size=size.small
                )

                pushLimitedLabel(labels, lbl, 200)

    // Keep channel plotted between repricing blocks
    if array.size(repricingMidArr) > 0
        channelCenter := avgArray(repricingMidArr)

        avgRepricingRange = avgArray(repricingRangeArr)

        if channelWidthMode == "High Low Envelope"
            channelUpper := highestArray(repricingHighArr)
            channelLower := lowestArray(repricingLowArr)
        else
            channelUpper := channelCenter + avgRepricingRange * channelMult
            channelLower := channelCenter - avgRepricingRange * channelMult

        dirAvg = avgArray(repricingDirectionArr)

        repricingBias :=
             dirAvg > 0.25 ? 1 :
             dirAvg < -0.25 ? -1 :
             0

    // Store block stats after comparison
    pushLimitedFloat(rangeArr, blockRange, compareLen)
    pushLimitedFloat(volArr, blockVolume, compareLen)
    pushLimitedFloat(effArr, blockEfficiency, compareLen)

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

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Plots
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
channelColor =
     repricingBias == 1 ? bullColor :
     repricingBias == -1 ? bearColor :
     neutralColor

centerPlot = plot(showCenterline ? channelCenter : na, "Repricing Center", color=channelColor, linewidth=3)
upperPlot = plot(showChannel ? channelUpper : na, "Repricing Channel High", color=color.new(channelColor, 25), linewidth=1)
lowerPlot = plot(showChannel ? channelLower : na, "Repricing Channel Low", color=color.new(channelColor, 25), linewidth=1)

fill(upperPlot, lowerPlot, color=showChannel ? channelFillColor : na, title="Repricing Channel Fill")

bgcolor(showBackground ? repricingBias == 1 ? bullBg : repricingBias == -1 ? bearBg : na : na)
````
