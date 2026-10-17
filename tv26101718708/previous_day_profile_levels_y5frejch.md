# Previous Day Profile Levels

- url: https://www.tradingview.com/script/y5FRejCH-Previous-Day-Profile-Levels/
- type: indicator
- pine_id: PUB;e70396ecd4a74e6b8688a2140353402d
- version: 1.0

## Description

Previous days Volume Profile VAH VAL POC
Previous days VWAP
Previous days High and Low

## Source Code

````pine
//@version=5
indicator("Previous Day Profile Levels", "Prev Day POC/VA/VWAP", overlay = true, max_lines_count = 50, max_labels_count = 50)

profileGroup = "Profile"
valueAreaPercent = input.float(70.0, "Value area percent", minval = 1.0, maxval = 100.0, group = profileGroup)
profileRows = input.int(100, "Profile rows", minval = 20, maxval = 300, group = profileGroup)
priceMode = input.string("Range", "Profile price mode", options = ["Range", "Typical", "Close"], group = profileGroup)
maxSessionBars = input.int(1500, "Max bars per day", minval = 100, maxval = 5000, group = profileGroup)

labelGroup = "Labels"
rightExtensionBars = input.int(8, "Right extension bars", minval = 0, maxval = 500, group = labelGroup)
labelBarsRight = input.int(2, "Label bars right", minval = 0, maxval = 500, group = labelGroup)
labelPrefix = input.string("P: ", "Label prefix", group = labelGroup)
labelSizeInput = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = labelGroup)

visibilityGroup = "Visibility"
showPoc = input.bool(true, "Show POC", group = visibilityGroup)
showVah = input.bool(true, "Show VAH", group = visibilityGroup)
showVal = input.bool(true, "Show VAL", group = visibilityGroup)
showVwap = input.bool(true, "Show VWAP", group = visibilityGroup)
showPdh = input.bool(true, "Show previous high", group = visibilityGroup)
showPdl = input.bool(true, "Show previous low", group = visibilityGroup)

pocGroup = "POC"
pocColor = input.color(color.red, "Line color", group = pocGroup)
pocStyleInput = input.string("Dashed", "Line style", options = ["Solid", "Dashed", "Dotted"], group = pocGroup)
pocWidth = input.int(2, "Line width", minval = 1, maxval = 5, group = pocGroup)
pocLabel = input.string("POC", "Label", group = pocGroup)
pocTextColor = input.color(color.white, "Text color", group = pocGroup)

vahGroup = "VAH"
vahColor = input.color(color.aqua, "Line color", group = vahGroup)
vahStyleInput = input.string("Dashed", "Line style", options = ["Solid", "Dashed", "Dotted"], group = vahGroup)
vahWidth = input.int(2, "Line width", minval = 1, maxval = 5, group = vahGroup)
vahLabel = input.string("VAH", "Label", group = vahGroup)
vahTextColor = input.color(color.white, "Text color", group = vahGroup)

valGroup = "VAL"
valColor = input.color(color.aqua, "Line color", group = valGroup)
valStyleInput = input.string("Dashed", "Line style", options = ["Solid", "Dashed", "Dotted"], group = valGroup)
valWidth = input.int(2, "Line width", minval = 1, maxval = 5, group = valGroup)
valLabel = input.string("VAL", "Label", group = valGroup)
valTextColor = input.color(color.white, "Text color", group = valGroup)

vwapGroup = "VWAP"
vwapColor = input.color(color.yellow, "Line color", group = vwapGroup)
vwapStyleInput = input.string("Dashed", "Line style", options = ["Solid", "Dashed", "Dotted"], group = vwapGroup)
vwapWidth = input.int(2, "Line width", minval = 1, maxval = 5, group = vwapGroup)
vwapLabel = input.string("VWAP", "Label", group = vwapGroup)
vwapTextColor = input.color(color.white, "Text color", group = vwapGroup)

pdhGroup = "Previous High"
pdhColor = input.color(color.blue, "Line color", group = pdhGroup)
pdhStyleInput = input.string("Dotted", "Line style", options = ["Solid", "Dashed", "Dotted"], group = pdhGroup)
pdhWidth = input.int(2, "Line width", minval = 1, maxval = 5, group = pdhGroup)
pdhLabel = input.string("PDH", "Label", group = pdhGroup)
pdhTextColor = input.color(color.white, "Text color", group = pdhGroup)

pdlGroup = "Previous Low"
pdlColor = input.color(color.blue, "Line color", group = pdlGroup)
pdlStyleInput = input.string("Dotted", "Line style", options = ["Solid", "Dashed", "Dotted"], group = pdlGroup)
pdlWidth = input.int(2, "Line width", minval = 1, maxval = 5, group = pdlGroup)
pdlLabel = input.string("PDL", "Label", group = pdlGroup)
pdlTextColor = input.color(color.white, "Text color", group = pdlGroup)

f_line_style(styleInput) =>
    switch styleInput
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

f_label_size(sizeInput) =>
    switch sizeInput
        "Tiny" => size.tiny
        "Normal" => size.normal
        "Large" => size.large
        "Huge" => size.huge
        => size.small

var float[] dayHighs = array.new_float()
var float[] dayLows = array.new_float()
var float[] dayCloses = array.new_float()
var float[] dayVolumes = array.new_float()

var int sessionStartIndex = na
var float sessionHigh = na
var float sessionLow = na
var float sessionVwapPriceVolume = 0.0
var float sessionVwapVolume = 0.0

var float previousPoc = na
var float previousVah = na
var float previousVal = na
var float previousVwap = na
var float previousHigh = na
var float previousLow = na
var bool hasPreviousDay = false

var line pocLine = na
var line vahLine = na
var line valLine = na
var line vwapLine = na
var line pdhLine = na
var line pdlLine = na

var label pocLabelId = na
var label vahLabelId = na
var label valLabelId = na
var label vwapLabelId = na
var label pdhLabelId = na
var label pdlLabelId = na

f_push_bar() =>
    if array.size(dayHighs) >= maxSessionBars
        array.shift(dayHighs)
        array.shift(dayLows)
        array.shift(dayCloses)
        array.shift(dayVolumes)
    array.push(dayHighs, high)
    array.push(dayLows, low)
    array.push(dayCloses, close)
    array.push(dayVolumes, volume)

f_finalize_profile() =>
    int bars = array.size(dayHighs)
    float outPoc = na
    float outVah = na
    float outVal = na

    if bars > 0 and not na(sessionHigh) and not na(sessionLow)
        float dayRange = math.max(sessionHigh - sessionLow, syminfo.mintick)
        float rowSize = dayRange / profileRows
        float[] rowVolumes = array.new_float(profileRows, 0.0)

        for barNumber = 0 to bars - 1
            float barHigh = array.get(dayHighs, barNumber)
            float barLow = array.get(dayLows, barNumber)
            float barClose = array.get(dayCloses, barNumber)
            float barVolume = array.get(dayVolumes, barNumber)

            if barVolume > 0
                if priceMode == "Range"
                    int lowRow = int(math.floor((barLow - sessionLow) / rowSize))
                    int highRow = int(math.floor((barHigh - sessionLow) / rowSize))
                    lowRow := math.max(0, math.min(profileRows - 1, lowRow))
                    highRow := math.max(0, math.min(profileRows - 1, highRow))
                    int touchedRows = math.max(1, highRow - lowRow + 1)
                    float volumePerRow = barVolume / touchedRows
                    for row = lowRow to highRow
                        array.set(rowVolumes, row, array.get(rowVolumes, row) + volumePerRow)
                else
                    float sourcePrice = priceMode == "Typical" ? (barHigh + barLow + barClose) / 3.0 : barClose
                    int row = int(math.floor((sourcePrice - sessionLow) / rowSize))
                    row := math.max(0, math.min(profileRows - 1, row))
                    array.set(rowVolumes, row, array.get(rowVolumes, row) + barVolume)

        float totalVolume = 0.0
        float maxVolume = -1.0
        int pocRow = 0
        for row = 0 to profileRows - 1
            float rowVolume = array.get(rowVolumes, row)
            totalVolume += rowVolume
            if rowVolume > maxVolume
                maxVolume := rowVolume
                pocRow := row

        if totalVolume > 0
            float targetVolume = totalVolume * valueAreaPercent / 100.0
            float accumulatedVolume = array.get(rowVolumes, pocRow)
            int lowerRow = pocRow
            int upperRow = pocRow

            while accumulatedVolume < targetVolume and (lowerRow > 0 or upperRow < profileRows - 1)
                float lowerVolume = lowerRow > 0 ? array.get(rowVolumes, lowerRow - 1) : -1.0
                float upperVolume = upperRow < profileRows - 1 ? array.get(rowVolumes, upperRow + 1) : -1.0
                if upperVolume >= lowerVolume
                    upperRow += 1
                    accumulatedVolume += array.get(rowVolumes, upperRow)
                else
                    lowerRow -= 1
                    accumulatedVolume += array.get(rowVolumes, lowerRow)

            outPoc := sessionLow + (pocRow + 0.5) * rowSize
            outVah := sessionLow + (upperRow + 0.5) * rowSize
            outVal := sessionLow + (lowerRow + 0.5) * rowSize

    [outPoc, outVah, outVal]

f_draw_level(showLevel, levelPrice, lineId, labelId, lineColor, styleInput, lineWidth, labelText, textColor) =>
    line nextLine = lineId
    label nextLabel = labelId

    if showLevel and hasPreviousDay and not na(levelPrice)
        int x1 = nz(sessionStartIndex, bar_index)
        int x2 = bar_index + rightExtensionBars
        int labelX = bar_index + labelBarsRight
        string fullLabel = labelPrefix + labelText

        if na(nextLine)
            nextLine := line.new(x1, levelPrice, x2, levelPrice, xloc = xloc.bar_index, extend = extend.none, color = lineColor, style = f_line_style(styleInput), width = lineWidth)
        else
            line.set_xy1(nextLine, x1, levelPrice)
            line.set_xy2(nextLine, x2, levelPrice)
            line.set_color(nextLine, lineColor)
            line.set_style(nextLine, f_line_style(styleInput))
            line.set_width(nextLine, lineWidth)

        if na(nextLabel)
            nextLabel := label.new(labelX, levelPrice, fullLabel, xloc = xloc.bar_index, style = label.style_none, textcolor = textColor, size = f_label_size(labelSizeInput))
        else
            label.set_xy(nextLabel, labelX, levelPrice)
            label.set_text(nextLabel, fullLabel)
            label.set_textcolor(nextLabel, textColor)
            label.set_size(nextLabel, f_label_size(labelSizeInput))
    else
        if not na(nextLine)
            line.delete(nextLine)
            nextLine := na
        if not na(nextLabel)
            label.delete(nextLabel)
            nextLabel := na

    [nextLine, nextLabel]

dayChange = ta.change(time("D"))
isNewDay = not na(dayChange) and dayChange != 0

if barstate.isfirst
    sessionStartIndex := bar_index
    sessionHigh := high
    sessionLow := low
    sessionVwapPriceVolume := 0.0
    sessionVwapVolume := 0.0

if isNewDay
    [newPoc, newVah, newVal] = f_finalize_profile()
    previousPoc := newPoc
    previousVah := newVah
    previousVal := newVal
    previousVwap := sessionVwapVolume > 0 ? sessionVwapPriceVolume / sessionVwapVolume : previousPoc
    previousHigh := sessionHigh
    previousLow := sessionLow
    hasPreviousDay := not na(previousPoc)

    array.clear(dayHighs)
    array.clear(dayLows)
    array.clear(dayCloses)
    array.clear(dayVolumes)
    sessionStartIndex := bar_index
    sessionHigh := high
    sessionLow := low
    sessionVwapPriceVolume := 0.0
    sessionVwapVolume := 0.0

sessionHigh := na(sessionHigh) ? high : math.max(sessionHigh, high)
sessionLow := na(sessionLow) ? low : math.min(sessionLow, low)
if volume > 0
    sessionVwapPriceVolume += hlc3 * volume
    sessionVwapVolume += volume

f_push_bar()

[nextVahLine, nextVahLabel] = f_draw_level(showVah, previousVah, vahLine, vahLabelId, vahColor, vahStyleInput, vahWidth, vahLabel, vahTextColor)
vahLine := nextVahLine
vahLabelId := nextVahLabel

[nextPocLine, nextPocLabel] = f_draw_level(showPoc, previousPoc, pocLine, pocLabelId, pocColor, pocStyleInput, pocWidth, pocLabel, pocTextColor)
pocLine := nextPocLine
pocLabelId := nextPocLabel

[nextValLine, nextValLabel] = f_draw_level(showVal, previousVal, valLine, valLabelId, valColor, valStyleInput, valWidth, valLabel, valTextColor)
valLine := nextValLine
valLabelId := nextValLabel

[nextVwapLine, nextVwapLabel] = f_draw_level(showVwap, previousVwap, vwapLine, vwapLabelId, vwapColor, vwapStyleInput, vwapWidth, vwapLabel, vwapTextColor)
vwapLine := nextVwapLine
vwapLabelId := nextVwapLabel

[nextPdhLine, nextPdhLabel] = f_draw_level(showPdh, previousHigh, pdhLine, pdhLabelId, pdhColor, pdhStyleInput, pdhWidth, pdhLabel, pdhTextColor)
pdhLine := nextPdhLine
pdhLabelId := nextPdhLabel

[nextPdlLine, nextPdlLabel] = f_draw_level(showPdl, previousLow, pdlLine, pdlLabelId, pdlColor, pdlStyleInput, pdlWidth, pdlLabel, pdlTextColor)
pdlLine := nextPdlLine
pdlLabelId := nextPdlLabel
````
