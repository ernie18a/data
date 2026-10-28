# Range Volume Pivot Regime

- url: https://www.tradingview.com/script/UnUmvhPc-Range-Volume-Pivot-Regime/
- type: indicator
- pine_id: PUB;727873acc074436b918452b9da01797a
- version: 1.0

## Description

Uses previous days same hour to compare to the recent completed range then label hourly regime
Range Volume Pivot Regime Range Volume Pivot Regime
Range Volume Pivot Regime Range Volume Pivot Regime
Range Volume Pivot Regime Range Volume Pivot Regime
Range Volume Pivot Regime Range Volume Pivot Regime

## Source Code

````pine
//@version=6
indicator("Cash Session Hourly Box: Range Volume Pivot Regime", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
cashSession = input.session("0930-1600", "Cash Session")

tzInput = input.string("Exchange", "Session Timezone", options = ["Exchange", "America/New_York", "America/Chicago", "Etc/UTC"])
tz = tzInput == "Exchange" ? syminfo.timezone : tzInput

startHour   = input.int(9, "Cash Start Hour", minval = 0, maxval = 23)
startMinute = input.int(30, "Cash Start Minute", minval = 0, maxval = 59)
endHour     = input.int(16, "Cash End Hour", minval = 0, maxval = 23)
endMinute   = input.int(0, "Cash End Minute", minval = 0, maxval = 59)

lookbackDays = input.int(20, "Compare Same Hour Lookback Days", minval = 3, maxval = 100)

expansionRangeMult = input.float(1.25, "Expansion Range Multiple", step = 0.05)
expansionVolMult   = input.float(1.25, "Expansion Volume Multiple", step = 0.05)

absorbVolMult      = input.float(1.35, "Absorption Volume Multiple", step = 0.05)
absorbRangeMaxMult = input.float(0.90, "Absorption Max Range Multiple", step = 0.05)

quietRangeMult = input.float(0.75, "Quiet Max Range Multiple", step = 0.05)
quietVolMult   = input.float(0.75, "Quiet Max Volume Multiple", step = 0.05)

showPivotLines = input.bool(true, "Show Hourly PP / R1 / S1")
showLabels     = input.bool(true, "Show Labels")
showLiveBox    = input.bool(true, "Show Current Forming Box")

boxTransparency = input.int(84, "Box Transparency", minval = 0, maxval = 100)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Session / slot logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
inSession = not na(time(timeframe.period, cashSession, tz))

startTotal = startHour * 60 + startMinute
endTotalRaw = endHour * 60 + endMinute
endTotal = endTotalRaw <= startTotal ? endTotalRaw + 1440 : endTotalRaw

sessionMinutes = endTotal - startTotal
slotCount = int(math.ceil(sessionMinutes / 60.0))

curTotalRaw = hour(time, tz) * 60 + minute(time, tz)
curTotal = curTotalRaw < startTotal ? curTotalRaw + 1440 : curTotalRaw

slotRaw = int(math.floor((curTotal - startTotal) / 60.0))
slot = math.max(0, math.min(slotRaw, slotCount - 1))

newSession = inSession and not inSession[1]
sessionEnded = not inSession and inSession[1]
newSlot = inSession and (newSession or slot != slot[1])

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Historical same-hour arrays
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
arraySize = slotCount * lookbackDays

var rangeHist = array.new_float(arraySize, na)
var volHist   = array.new_float(arraySize, na)

f_idx(_slot, _i) =>
    _slot * lookbackDays + _i

f_mean(_arr, _slot) =>
    float sum = 0.0
    int n = 0

    for i = 0 to lookbackDays - 1
        v = array.get(_arr, f_idx(_slot, i))
        if not na(v)
            sum += v
            n += 1

    n > 0 ? sum / n : na

f_stdev(_arr, _slot, _mean) =>
    float sumSq = 0.0
    int n = 0

    if not na(_mean)
        for i = 0 to lookbackDays - 1
            v = array.get(_arr, f_idx(_slot, i))
            if not na(v)
                sumSq += math.pow(v - _mean, 2)
                n += 1

    n > 1 ? math.sqrt(sumSq / (n - 1)) : na

f_count(_arr, _slot) =>
    int n = 0

    for i = 0 to lookbackDays - 1
        v = array.get(_arr, f_idx(_slot, i))
        if not na(v)
            n += 1

    n

f_push(_arr, _slot, _value) =>
    // Shift oldest values back using a positive-step loop.
    // This replaces the invalid negative-step loop.
    for j = 0 to lookbackDays - 2
        i = lookbackDays - 1 - j
        older = array.get(_arr, f_idx(_slot, i - 1))
        array.set(_arr, f_idx(_slot, i), older)

    array.set(_arr, f_idx(_slot, 0), _value)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Current block state
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var bool  blockActive = false
var int   blockSlot = na
var int   blockStartIndex = na
var float blockOpen = na
var float blockHigh = na
var float blockLow = na
var float blockClose = na
var float blockVolume = na

var box currentBox = na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Helpers
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_slotName(_slot) =>
    slotStart = startTotal + _slot * 60
    slotEnd = math.min(slotStart + 60, endTotal)

    sh = int(math.floor(slotStart / 60)) % 24
    sm = slotStart % 60
    eh = int(math.floor(slotEnd / 60)) % 24
    em = slotEnd % 60

    str.tostring(sh, "00") + ":" + str.tostring(sm, "00") + " - " + str.tostring(eh, "00") + ":" + str.tostring(em, "00")

f_state(_rangeRel, _volRel, _closeLoc) =>
    string state = "Normal"

    if not na(_rangeRel) and not na(_volRel)
        if _rangeRel >= expansionRangeMult and _volRel >= expansionVolMult
            state := "Expansion"
        else if _volRel >= absorbVolMult and _rangeRel <= absorbRangeMaxMult and _closeLoc > 0.25 and _closeLoc < 0.75
            state := "Absorption"
        else if _rangeRel >= expansionRangeMult and _volRel < expansionVolMult
            state := "Repricing"
        else if _rangeRel <= quietRangeMult and _volRel <= quietVolMult
            state := "Quiet"

    state

f_color(_state) =>
    color c = color.gray

    if _state == "Expansion"
        c := color.lime
    else if _state == "Absorption"
        c := color.orange
    else if _state == "Repricing"
        c := color.aqua
    else if _state == "Quiet"
        c := color.gray
    else
        c := color.blue

    c

f_finishBlock(_endIndex) =>
    bRange = blockHigh - blockLow

    rangeAvg = f_mean(rangeHist, blockSlot)
    volAvg   = f_mean(volHist, blockSlot)

    rangeSd = f_stdev(rangeHist, blockSlot, rangeAvg)
    volSd   = f_stdev(volHist, blockSlot, volAvg)

    sampleCount = f_count(rangeHist, blockSlot)

    rangeRel = not na(rangeAvg) and rangeAvg != 0.0 ? bRange / rangeAvg : na
    volRel   = not na(volAvg) and volAvg != 0.0 ? blockVolume / volAvg : na

    rangeZ = not na(rangeSd) and rangeSd != 0.0 ? (bRange - rangeAvg) / rangeSd : na
    volZ   = not na(volSd) and volSd != 0.0 ? (blockVolume - volAvg) / volSd : na

    closeLoc = bRange != 0.0 ? (blockClose - blockLow) / bRange : 0.5

    pp = (blockHigh + blockLow + blockClose) / 3.0
    r1 = 2.0 * pp - blockLow
    s1 = 2.0 * pp - blockHigh

    regime = f_state(rangeRel, volRel, closeLoc)
    regimeColor = f_color(regime)

    if not na(currentBox)
        box.set_right(currentBox, _endIndex)
        box.set_top(currentBox, blockHigh)
        box.set_bottom(currentBox, blockLow)
        box.set_bgcolor(currentBox, color.new(regimeColor, boxTransparency))
        box.set_border_color(currentBox, color.new(regimeColor, 0))

    if showPivotLines
        line.new(blockStartIndex, pp, _endIndex, pp, color = color.new(color.white, 0), width = 1)
        line.new(blockStartIndex, r1, _endIndex, r1, color = color.new(color.green, 35), width = 1, style = line.style_dotted)
        line.new(blockStartIndex, s1, _endIndex, s1, color = color.new(color.red, 35), width = 1, style = line.style_dotted)

    if showLabels
        pivotBias = blockClose > pp ? "Close > PP" : blockClose < pp ? "Close < PP" : "Close = PP"

        labelText =
             f_slotName(blockSlot) +
             "\n" + regime +
             "\nRange: " + str.tostring(bRange, format.mintick) +
             "\nVol: " + str.tostring(blockVolume, format.volume) +
             "\nR xAvg: " + (na(rangeRel) ? "n/a" : str.tostring(rangeRel, "#.##")) +
             "\nV xAvg: " + (na(volRel) ? "n/a" : str.tostring(volRel, "#.##")) +
             "\nR z: " + (na(rangeZ) ? "n/a" : str.tostring(rangeZ, "#.##")) +
             " | V z: " + (na(volZ) ? "n/a" : str.tostring(volZ, "#.##")) +
             "\nPP: " + str.tostring(pp, format.mintick) +
             "\n" + pivotBias +
             "\nSamples: " + str.tostring(sampleCount)

        labelStyle = blockClose >= blockOpen ? label.style_label_down : label.style_label_up
        labelY = blockClose >= blockOpen ? blockHigh : blockLow

        label.new(
             _endIndex,
             labelY,
             labelText,
             style = labelStyle,
             textcolor = color.white,
             color = color.new(regimeColor, 10),
             size = size.small
        )

    f_push(rangeHist, blockSlot, bRange)
    f_push(volHist, blockSlot, blockVolume)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Main block engine
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if inSession
    if newSlot
        if blockActive
            f_finishBlock(bar_index - 1)

        blockActive := true
        blockSlot := slot
        blockStartIndex := bar_index
        blockOpen := open
        blockHigh := high
        blockLow := low
        blockClose := close
        blockVolume := volume

        currentBox := box.new(
             left = bar_index,
             top = high,
             right = bar_index,
             bottom = low,
             bgcolor = color.new(color.blue, boxTransparency),
             border_color = color.new(color.blue, 0)
        )

    else if blockActive
        blockHigh := math.max(blockHigh, high)
        blockLow := math.min(blockLow, low)
        blockClose := close
        blockVolume += volume

        if showLiveBox and not na(currentBox)
            box.set_right(currentBox, bar_index)
            box.set_top(currentBox, blockHigh)
            box.set_bottom(currentBox, blockLow)

if sessionEnded and blockActive
    f_finishBlock(bar_index - 1)
    blockActive := false
    currentBox := na
````
