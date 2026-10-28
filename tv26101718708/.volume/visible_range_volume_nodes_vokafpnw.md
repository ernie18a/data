# Visible Range Volume Nodes

- url: https://www.tradingview.com/script/VoKAfPNW-Visible-Range-Volume-Nodes/
- type: indicator
- pine_id: PUB;adb5bb235bb648578bd8161442f11e21
- version: 1.0

## Description

Visible Range Volume Nodes is a visible-range volume profile indicator that shows how traded volume is distributed across price levels inside the currently visible chart area.

The script builds a horizontal volume profile from the candles visible on the chart. It divides the visible price range into rows and distributes each candle's volume across the price rows touched by that candle's high-low range. Rows with more accumulated volume are displayed wider. Rows with less accumulated volume are displayed narrower.

[b]How volume is calculated[/b]

Each candle's volume is distributed proportionally across the price rows covered by that candle's high-low range. If a candle covers several rows, its volume is split between those rows based on the amount of price overlap.

[b]Bullish and bearish volume are separated using candle direction:[/b]
* Candles closing above their open are counted as bullish volume;
* Candles closing below their open are counted as bearish volume;
* Neutral candles are split evenly.

[b]Key Volume Areas[/b]

[b]POC - Point of Control[/b]
POC is the price row with the highest volume inside the visible range. It marks the largest volume concentration in the selected chart area.

[b]VAH - Value Area High[/b]
VAH is the upper boundary of the value area.

[b]VAL - Value Area Low[/b]
VAL is the lower boundary of the value area.

The value area starts from the POC and expands through the highest-volume neighboring rows until the selected percentage of total visible-range volume is included. By default, this is commonly used as a 70% value area, but the percentage can be changed in the settings.

[b]HVN - High Volume Node[/b]
HVN zones are high-volume areas detected from local peaks in the smoothed volume profile. These zones show where volume was concentrated compared with nearby price levels.

[b]LVN - Low Volume Node[/b]
LVN zones are low-volume areas detected from local valleys in the smoothed volume profile. These zones show where volume was thinner compared with nearby price levels.

[b]How to use it[/b]
The profile can help users compare current price action with previously traded volume areas inside the selected visible range:

* POC shows the main high-volume reference area of the visible range;
* VAH and VAL show the upper and lower limits of the main value area;
* HVN zones show areas where price previously spent more volume;
* LVN zones show areas where volume was thinner relative to nearby price levels;
* The histogram shows the full volume distribution across the selected price range.

A trader can use these areas as context when analyzing price location. For example, price trading near POC is trading near the main volume concentration of the visible range. Price trading near VAH or VAL is trading near the edge of the calculated value area. HVN and LVN zones can be used to compare current price behavior with areas of stronger or weaker previous volume participation.

[i]These levels should be treated as structural references only. They are not automatic entries, exits, support, resistance, targets, or invalidation levels.[/i]

[b]Main settings[/b]

* Profile Rows controls how many price rows are used to build the volume profile. More rows create a more detailed profile. Fewer rows create a smoother, broader profile;
* Value Area % controls how much of the visible-range volume is included inside the value area;
* Histogram Direction controls whether the profile is displayed to the left or right side of the visible chart area;
* Profile Distance controls the spacing between the visible candles and the profile panel;
* The script also includes settings for showing or hiding POC, VAH/VAL, HVN, LVN, labels, prices in labels, line style, line width, label size, and colors.

[b]Limitations[/b]
*This indicator does not generate buy or sell signals;
*It does not predict future price direction;
*It does not define guaranteed support or resistance;
*It does not use exact bid/ask volume;
*It does not use footprint, delta, or order book data.

The displayed structure depends on the selected visible range, symbol, exchange, timeframe, and available volume data.

[i]Because the profile is based on the currently visible chart range, moving or zooming the chart can change the calculated POC, value area, HVN zones, and LVN zones.[/i]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0.
// Visible range volume profile with POC, VAH, VAL, HVN, and LVN levels.
// HVN/LVN zones are derived from local volume structure. They are not buy/sell signals.
//@version=6
indicator("Visible Range Volume Nodes", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500, max_bars_back=5000)

// Inputs

const string GROUP_PROFILE = "Volume Profile"
const string GROUP_LEVELS = "POC and Value Area"
const string GROUP_NODES = "HVN and LVN Zones"
const string GROUP_LABELS = "Labels"
const string GROUP_PROFILE_COLORS = "Profile Colors"
const string GROUP_LEVEL_COLORS = "Level Colors"

profileDirectionInput = input.string("Extend Left", "Histogram Direction", options=["Extend Right", "Extend Left"], tooltip="Controls whether the histogram bars extend away from or toward the latest visible candle. The profile stays outside the visible range.", group=GROUP_PROFILE)
profileDistanceInput = input.int(100, "Profile Distance", minval=1, maxval=500, step=1, tooltip="Distance between the latest visible candle and the profile panel. Minimum: 1. Maximum: 500.", group=GROUP_PROFILE)
profileRowsInput = input.int(200, "Profile Rows", minval=40, maxval=220, step=10, tooltip="Number of price rows used to build the visible range volume profile. Minimum: 40. Maximum: 220.", group=GROUP_PROFILE)
valueAreaPctInput = input.float(70.0, "Value Area %", minval=1.0, maxval=100.0, step=1.0, group=GROUP_LEVELS)

showPocInput = input.bool(true, "Point of Control", group=GROUP_LEVELS)
pocLineWidthInput = input.int(2, "POC Line Width", minval=1, maxval=5, step=1, group=GROUP_LEVELS)
pocLineStyleInput = input.string("Solid", "POC Line Style", options=["Solid", "Dashed", "Dotted"], group=GROUP_LEVELS)

showVahValInput = input.bool(true, "Value Area High / Low", group=GROUP_LEVELS)
vahValLineWidthInput = input.int(1, "VAH / VAL Line Width", minval=1, maxval=5, step=1, group=GROUP_LEVELS)
vahValLineStyleInput = input.string("Dashed", "VAH / VAL Line Style", options=["Solid", "Dashed", "Dotted"], group=GROUP_LEVELS)

showHvnInput = input.bool(true, "High Volume Nodes", group=GROUP_NODES)
showLvnInput = input.bool(true, "Low Volume Nodes", group=GROUP_NODES)

showLabelsInput = input.bool(true, "Level Labels", group=GROUP_LABELS)
showPriceInLabelsInput = input.bool(true, "Price in Labels", group=GROUP_LABELS)
labelSizeInput = input.string("Normal", "Label Size", options=["Tiny", "Small", "Normal", "Large"], group=GROUP_LABELS)

bullProfileColorInput = input.color(color.rgb(245, 245, 245), "Bullish Volume", group=GROUP_PROFILE_COLORS)
bearProfileColorInput = input.color(color.rgb(0, 92, 255), "Bearish Volume", group=GROUP_PROFILE_COLORS)

hvnColorInput = input.color(color.rgb(0, 92, 255), "HVN", group=GROUP_LEVEL_COLORS)
lvnColorInput = input.color(color.rgb(255, 255, 255), "LVN", group=GROUP_LEVEL_COLORS)
pocColorInput = input.color(color.rgb(255, 255, 255), "POC", group=GROUP_LEVEL_COLORS)
valueAreaColorInput = input.color(color.rgb(255, 255, 255), "VAH / VAL", group=GROUP_LEVEL_COLORS)

hvnLabelTextColorInput = input.color(color.rgb(0, 0, 0), "HVN Text", group=GROUP_LEVEL_COLORS)
lvnLabelTextColorInput = input.color(color.rgb(0, 0, 0), "LVN Text", group=GROUP_LEVEL_COLORS)
profileLevelTextColorInput = input.color(color.rgb(0, 0, 0), "Core Level Text", group=GROUP_LEVEL_COLORS)

// Fixed parameters

const int MAX_LOOKBACK_BARS = 5000

const float PROFILE_WIDTH_PCT = 31.0

const int SMOOTHING_RADIUS = 2
const int LOCAL_EXTREME_RADIUS = 2
const int PROMINENCE_SEARCH_ROWS = 20

const int NODE_MERGE_DISTANCE = 12
const int HVN_LVN_MIN_DISTANCE = 7
const int POC_NODE_BUFFER_ROWS = 4

const int MAX_HVN_HALF_WIDTH_ROWS = 3
const int MAX_LVN_HALF_WIDTH_ROWS = 3
const int MAX_HVN_ZONES = 3
const int MAX_LVN_ZONES = 4

const int PROFILE_TRANSPARENCY = 72
const int NODE_PROFILE_TRANSPARENCY = 2
const int POC_PROFILE_TRANSPARENCY = 0
const int ZONE_TRANSPARENCY = 90

// Drawing storage

var box[] profileBoxes = array.new_box()
var box[] zoneBoxes = array.new_box()
var label[] drawingLabels = array.new_label()
var line[] drawingLines = array.new_line()

var float[] totalBins = array.new_float()
var float[] bullBins = array.new_float()
var float[] bearBins = array.new_float()
var float[] smoothBins = array.new_float()

var int[] hvnCandidateRows = array.new_int()
var float[] hvnCandidateScores = array.new_float()
var int[] lvnCandidateRows = array.new_int()
var float[] lvnCandidateScores = array.new_float()

var int[] hvnRows = array.new_int()
var int[] lvnRows = array.new_int()

// Utility functions

clearBoxes(box[] arr) =>
    while array.size(arr) > 0
        box.delete(array.pop(arr))

clearLabels(label[] arr) =>
    while array.size(arr) > 0
        label.delete(array.pop(arr))

clearLines(line[] arr) =>
    while array.size(arr) > 0
        line.delete(array.pop(arr))

resetFloatArray(float[] arr, int size) =>
    array.clear(arr)
    for i = 0 to size - 1
        array.push(arr, 0.0)

clampInt(int value, int minValue, int maxValue) =>
    math.max(minValue, math.min(maxValue, value))

clampFloat(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

getLabelSize(string setting) =>
    setting == "Large" ? size.large : setting == "Normal" ? size.normal : setting == "Small" ? size.small : size.tiny

getLineStyle(string setting) =>
    setting == "Dotted" ? line.style_dotted : setting == "Dashed" ? line.style_dashed : line.style_solid

rowMidPrice(float rangeLow, float rowHeight, int row) =>
    rangeLow + (row + 0.5) * rowHeight

labelText(string name, float price) =>
    showPriceInLabelsInput ? name + " " + str.tostring(price, format.mintick) : name

isFarFromRows(int row, int[] selectedRows, int minDistance) =>
    bool isFar = true
    if array.size(selectedRows) > 0
        for i = 0 to array.size(selectedRows) - 1
            if math.abs(row - array.get(selectedRows, i)) <= minDistance
                isFar := false
                break
    isFar

rowInsideNodes(int row, int[] nodeRows, int radius) =>
    bool inside = false
    if array.size(nodeRows) > 0
        for i = 0 to array.size(nodeRows) - 1
            if math.abs(row - array.get(nodeRows, i)) <= radius
                inside := true
                break
    inside

rangeMin(float[] arr, int firstRow, int lastRow) =>
    float result = na
    if firstRow <= lastRow
        for row = firstRow to lastRow
            float value = array.get(arr, row)
            result := na(result) ? value : math.min(result, value)
    nz(result)

rangeMax(float[] arr, int firstRow, int lastRow) =>
    float result = na
    if firstRow <= lastRow
        for row = firstRow to lastRow
            float value = array.get(arr, row)
            result := na(result) ? value : math.max(result, value)
    nz(result)

isLocalMaximum(float[] arr, int row, int radius) =>
    bool result = true
    float center = array.get(arr, row)
    for step = 1 to radius
        if row - step >= 0 and array.get(arr, row - step) > center
            result := false
        if row + step < array.size(arr) and array.get(arr, row + step) > center
            result := false
    result

isLocalMinimum(float[] arr, int row, int radius) =>
    bool result = true
    float center = array.get(arr, row)
    for step = 1 to radius
        if row - step >= 0 and array.get(arr, row - step) < center
            result := false
        if row + step < array.size(arr) and array.get(arr, row + step) < center
            result := false
    result

sortCandidatesDescending(int[] rows, float[] scores) =>
    int count = array.size(scores)
    if count > 1
        for i = 0 to count - 2
            int bestIndex = i
            for j = i + 1 to count - 1
                if array.get(scores, j) > array.get(scores, bestIndex)
                    bestIndex := j
            if bestIndex != i
                int oldRow = array.get(rows, i)
                float oldScore = array.get(scores, i)
                array.set(rows, i, array.get(rows, bestIndex))
                array.set(scores, i, array.get(scores, bestIndex))
                array.set(rows, bestIndex, oldRow)
                array.set(scores, bestIndex, oldScore)

sortIntAscending(int[] rows) =>
    int count = array.size(rows)
    if count > 1
        for i = 0 to count - 2
            int bestIndex = i
            for j = i + 1 to count - 1
                if array.get(rows, j) < array.get(rows, bestIndex)
                    bestIndex := j
            if bestIndex != i
                int oldRow = array.get(rows, i)
                array.set(rows, i, array.get(rows, bestIndex))
                array.set(rows, bestIndex, oldRow)

selectTopNodes(int[] candidateRows, int[] selectedRows, int maxCount, int minDistance) =>
    array.clear(selectedRows)
    if array.size(candidateRows) > 0
        for i = 0 to array.size(candidateRows) - 1
            int row = array.get(candidateRows, i)
            if isFarFromRows(row, selectedRows, minDistance)
                array.push(selectedRows, row)
                if array.size(selectedRows) >= maxCount
                    break

selectTopNodesWithForbidden(int[] candidateRows, int[] selectedRows, int maxCount, int minDistance, int[] forbiddenRows, int forbiddenDistance) =>
    array.clear(selectedRows)
    if array.size(candidateRows) > 0
        for i = 0 to array.size(candidateRows) - 1
            int row = array.get(candidateRows, i)
            if isFarFromRows(row, selectedRows, minDistance) and isFarFromRows(row, forbiddenRows, forbiddenDistance)
                array.push(selectedRows, row)
                if array.size(selectedRows) >= maxCount
                    break

hvnBounds(float[] bins, int centerRow, int pocRow, float profileMean) =>
    int lowerRow = centerRow
    int upperRow = centerRow
    float peakVolume = array.get(bins, centerRow)
    float keepAbove = math.max(profileMean * 1.03, peakVolume * 0.64)

    for step = 1 to MAX_HVN_HALF_WIDTH_ROWS
        int candidate = centerRow - step
        if candidate >= 0 and math.abs(candidate - pocRow) > POC_NODE_BUFFER_ROWS and array.get(bins, candidate) >= keepAbove
            lowerRow := candidate
        else
            break

    for step = 1 to MAX_HVN_HALF_WIDTH_ROWS
        int candidate = centerRow + step
        if candidate < array.size(bins) and math.abs(candidate - pocRow) > POC_NODE_BUFFER_ROWS and array.get(bins, candidate) >= keepAbove
            upperRow := candidate
        else
            break

    [lowerRow, upperRow]

lvnBounds(float[] bins, int centerRow, float profileMean, float weakerShoulder) =>
    int lowerRow = centerRow
    int upperRow = centerRow
    float valleyVolume = array.get(bins, centerRow)
    float keepBelow = valleyVolume + math.max(profileMean * 0.16, (weakerShoulder - valleyVolume) * 0.52)

    for step = 1 to MAX_LVN_HALF_WIDTH_ROWS
        int candidate = centerRow - step
        if candidate >= 0 and array.get(bins, candidate) <= keepBelow
            lowerRow := candidate
        else
            break

    for step = 1 to MAX_LVN_HALF_WIDTH_ROWS
        int candidate = centerRow + step
        if candidate < array.size(bins) and array.get(bins, candidate) <= keepBelow
            upperRow := candidate
        else
            break

    [lowerRow, upperRow]

// Visible range profile engine

drawVisibleProfile(int visibleLeftTime, int visibleRightTime, int visibleBars, int barMs) =>
    array.clear(hvnCandidateRows)
    array.clear(hvnCandidateScores)
    array.clear(lvnCandidateRows)
    array.clear(lvnCandidateScores)
    array.clear(hvnRows)
    array.clear(lvnRows)

    int scanBars = math.min(bar_index + 1, MAX_LOOKBACK_BARS)
    int profileBarCount = 0
    float profileHigh = na
    float profileLow = na

    for i = 0 to scanBars - 1
        bool insideProfileRange = time[i] >= visibleLeftTime and time[i] <= visibleRightTime
        if insideProfileRange
            profileBarCount += 1
            profileHigh := na(profileHigh) ? high[i] : math.max(profileHigh, high[i])
            profileLow := na(profileLow) ? low[i] : math.min(profileLow, low[i])

    if profileBarCount > 0 and not na(profileHigh) and not na(profileLow)
        if profileHigh <= profileLow
            profileHigh += syminfo.mintick
            profileLow -= syminfo.mintick

        float priceRange = profileHigh - profileLow
        int rowsCount = profileRowsInput
        float rowHeight = priceRange / rowsCount

        resetFloatArray(totalBins, rowsCount)
        resetFloatArray(bullBins, rowsCount)
        resetFloatArray(bearBins, rowsCount)
        resetFloatArray(smoothBins, rowsCount)

        for i = 0 to scanBars - 1
            bool insideProfileRange = time[i] >= visibleLeftTime and time[i] <= visibleRightTime
            if insideProfileRange
                float barHigh = high[i]
                float barLow = low[i]
                float barVolume = nz(volume[i])
                float barRange = barHigh - barLow

                if barVolume > 0.0
                    float bullishShare = close[i] > open[i] ? 1.0 : close[i] < open[i] ? 0.0 : 0.5

                    if barRange <= 0.0
                        int onlyRow = int(math.floor((close[i] - profileLow) / rowHeight))
                        onlyRow := clampInt(onlyRow, 0, rowsCount - 1)

                        float bullishVolume = barVolume * bullishShare
                        float bearishVolume = barVolume - bullishVolume

                        array.set(totalBins, onlyRow, array.get(totalBins, onlyRow) + barVolume)
                        array.set(bullBins, onlyRow, array.get(bullBins, onlyRow) + bullishVolume)
                        array.set(bearBins, onlyRow, array.get(bearBins, onlyRow) + bearishVolume)
                    else
                        int firstRow = int(math.floor((barLow - profileLow) / rowHeight))
                        int lastRow = int(math.floor((barHigh - profileLow) / rowHeight))
                        firstRow := clampInt(firstRow, 0, rowsCount - 1)
                        lastRow := clampInt(lastRow, 0, rowsCount - 1)

                        if lastRow >= firstRow
                            for row = firstRow to lastRow
                                float rowLow = profileLow + row * rowHeight
                                float rowHigh = rowLow + rowHeight
                                float overlap = math.max(0.0, math.min(barHigh, rowHigh) - math.max(barLow, rowLow))

                                if overlap > 0.0
                                    float addedVolume = barVolume * overlap / barRange
                                    float bullishVolume = addedVolume * bullishShare
                                    float bearishVolume = addedVolume - bullishVolume

                                    array.set(totalBins, row, array.get(totalBins, row) + addedVolume)
                                    array.set(bullBins, row, array.get(bullBins, row) + bullishVolume)
                                    array.set(bearBins, row, array.get(bearBins, row) + bearishVolume)

        float totalProfileVolume = 0.0
        float totalSmoothVolume = 0.0
        float maxRawVolume = 0.0
        float maxSmoothVolume = 0.0
        int pocRow = 0

        for row = 0 to rowsCount - 1
            float rawVolume = array.get(totalBins, row)
            totalProfileVolume += rawVolume

            if rawVolume > maxRawVolume
                maxRawVolume := rawVolume
                pocRow := row

            float weightedSum = rawVolume * 3.0
            float weightTotal = 3.0

            for step = 1 to SMOOTHING_RADIUS
                float weight = SMOOTHING_RADIUS - step + 1.0

                if row - step >= 0
                    weightedSum += array.get(totalBins, row - step) * weight
                    weightTotal += weight

                if row + step <= rowsCount - 1
                    weightedSum += array.get(totalBins, row + step) * weight
                    weightTotal += weight

            float smoothVolume = weightedSum / weightTotal
            array.set(smoothBins, row, smoothVolume)

            totalSmoothVolume += smoothVolume
            maxSmoothVolume := math.max(maxSmoothVolume, smoothVolume)

        if maxRawVolume > 0.0 and maxSmoothVolume > 0.0 and totalProfileVolume > 0.0
            float profileMean = totalSmoothVolume / rowsCount

            int valueAreaLowRow = pocRow
            int valueAreaHighRow = pocRow
            float valueAreaVolume = array.get(totalBins, pocRow)
            float valueAreaTarget = totalProfileVolume * valueAreaPctInput / 100.0

            while valueAreaVolume < valueAreaTarget and (valueAreaLowRow > 0 or valueAreaHighRow < rowsCount - 1)
                float nextLowVolume = valueAreaLowRow > 0 ? array.get(totalBins, valueAreaLowRow - 1) : -1.0
                float nextHighVolume = valueAreaHighRow < rowsCount - 1 ? array.get(totalBins, valueAreaHighRow + 1) : -1.0

                if nextHighVolume >= nextLowVolume and valueAreaHighRow < rowsCount - 1
                    valueAreaHighRow += 1
                    valueAreaVolume += math.max(0.0, nextHighVolume)
                else if valueAreaLowRow > 0
                    valueAreaLowRow -= 1
                    valueAreaVolume += math.max(0.0, nextLowVolume)
                else
                    break

            float hvnMinVolume = math.max(profileMean * 1.18, maxSmoothVolume * 0.20)
            float hvnMinProminence = math.max(profileMean * 0.08, maxSmoothVolume * 0.018)

            float lvnMaxVolume = math.min(profileMean * 1.02, maxSmoothVolume * 0.54)
            float lvnMinShoulder = math.max(profileMean * 0.88, maxSmoothVolume * 0.14)
            float lvnMinDepth = math.max(profileMean * 0.10, maxSmoothVolume * 0.020)

            int effectiveNodeMergeDistance = clampInt(int(math.round(rowsCount * 0.065)), NODE_MERGE_DISTANCE, 18)
            int effectiveHvnLvnDistance = clampInt(int(math.round(rowsCount * 0.040)), HVN_LVN_MIN_DISTANCE, 11)
            int effectivePocBufferRows = clampInt(int(math.round(rowsCount * 0.025)), POC_NODE_BUFFER_ROWS, 7)

            for row = LOCAL_EXTREME_RADIUS to rowsCount - LOCAL_EXTREME_RADIUS - 1
                float rowSmoothVolume = array.get(smoothBins, row)
                float rowRawVolume = array.get(totalBins, row)

                int leftSearchStart = math.max(0, row - PROMINENCE_SEARCH_ROWS)
                int rightSearchEnd = math.min(rowsCount - 1, row + PROMINENCE_SEARCH_ROWS)

                if showHvnInput and isLocalMaximum(smoothBins, row, LOCAL_EXTREME_RADIUS)
                    float leftValley = rangeMin(smoothBins, leftSearchStart, row - 1)
                    float rightValley = rangeMin(smoothBins, row + 1, rightSearchEnd)
                    float limitingValley = math.max(leftValley, rightValley)
                    float prominence = rowSmoothVolume - limitingValley

                    bool hvnSeparatedFromPoc = math.abs(row - pocRow) > effectivePocBufferRows + MAX_HVN_HALF_WIDTH_ROWS
                    bool enoughVolume = rowSmoothVolume >= hvnMinVolume or rowRawVolume >= maxRawVolume * 0.28
                    bool enoughProminence = prominence >= hvnMinProminence or rowRawVolume >= maxRawVolume * 0.34

                    if hvnSeparatedFromPoc and enoughVolume and enoughProminence
                        float score = rowRawVolume * 2.60 + rowSmoothVolume * 1.50 + prominence * 0.70
                        array.push(hvnCandidateRows, row)
                        array.push(hvnCandidateScores, score)

                if showLvnInput and isLocalMinimum(smoothBins, row, LOCAL_EXTREME_RADIUS)
                    float leftShoulder = rangeMax(smoothBins, leftSearchStart, row - 1)
                    float rightShoulder = rangeMax(smoothBins, row + 1, rightSearchEnd)
                    float strongerShoulder = math.max(leftShoulder, rightShoulder)
                    float weakerShoulder = math.min(leftShoulder, rightShoulder)

                    float valleyDepth = weakerShoulder - rowSmoothVolume
                    float relativeDepth = strongerShoulder > 0.0 ? valleyDepth / strongerShoulder : 0.0

                    bool lvnSeparatedFromPoc = math.abs(row - pocRow) > effectivePocBufferRows
                    bool validShoulders = weakerShoulder >= lvnMinShoulder or relativeDepth >= 0.14
                    bool validValley = rowSmoothVolume <= lvnMaxVolume or rowSmoothVolume <= weakerShoulder * 0.72
                    bool validDepth = valleyDepth >= lvnMinDepth or relativeDepth >= 0.18

                    if lvnSeparatedFromPoc and validShoulders and validValley and validDepth
                        float score = valleyDepth * 3.00 + relativeDepth * profileMean * 4.00 + math.max(0.0, profileMean - rowSmoothVolume) * 1.20 - rowSmoothVolume * 0.03
                        array.push(lvnCandidateRows, row)
                        array.push(lvnCandidateScores, score)

            sortCandidatesDescending(hvnCandidateRows, hvnCandidateScores)
            selectTopNodes(hvnCandidateRows, hvnRows, MAX_HVN_ZONES, effectiveNodeMergeDistance)

            if showLvnInput
                int[] anchorRows = array.new_int()
                array.push(anchorRows, pocRow)

                if array.size(hvnRows) > 0
                    for i = 0 to array.size(hvnRows) - 1
                        int hvnRow = array.get(hvnRows, i)
                        if isFarFromRows(hvnRow, anchorRows, effectiveHvnLvnDistance)
                            array.push(anchorRows, hvnRow)

                int extraAnchorLimit = math.min(array.size(hvnCandidateRows), 8)
                if extraAnchorLimit > 0
                    for i = 0 to extraAnchorLimit - 1
                        int candidateAnchor = array.get(hvnCandidateRows, i)
                        if isFarFromRows(candidateAnchor, anchorRows, effectiveHvnLvnDistance)
                            array.push(anchorRows, candidateAnchor)

                sortIntAscending(anchorRows)

                if array.size(anchorRows) > 1
                    for i = 0 to array.size(anchorRows) - 2
                        int leftAnchor = array.get(anchorRows, i)
                        int rightAnchor = array.get(anchorRows, i + 1)

                        int gapStart = leftAnchor + effectiveHvnLvnDistance
                        int gapEnd = rightAnchor - effectiveHvnLvnDistance

                        if gapEnd >= gapStart and gapEnd - gapStart >= 3
                            int bestValleyRow = gapStart
                            float bestValleyVolume = array.get(smoothBins, gapStart)

                            for valleyRow = gapStart to gapEnd
                                float valleyVolume = array.get(smoothBins, valleyRow)
                                if valleyVolume < bestValleyVolume
                                    bestValleyVolume := valleyVolume
                                    bestValleyRow := valleyRow

                            float leftAnchorVolume = array.get(smoothBins, leftAnchor)
                            float rightAnchorVolume = array.get(smoothBins, rightAnchor)
                            float weakerAnchor = math.min(leftAnchorVolume, rightAnchorVolume)
                            float strongerAnchor = math.max(leftAnchorVolume, rightAnchorVolume)

                            float structuralDepth = weakerAnchor - bestValleyVolume
                            float structuralRatio = strongerAnchor > 0.0 ? structuralDepth / strongerAnchor : 0.0

                            bool awayFromPoc = math.abs(bestValleyRow - pocRow) > effectivePocBufferRows
                            bool realPocket = bestValleyVolume <= profileMean * 1.06 or bestValleyVolume <= weakerAnchor * 0.76
                            bool realDepth = structuralDepth >= math.max(profileMean * 0.08, maxSmoothVolume * 0.018) or structuralRatio >= 0.10

                            if awayFromPoc and realPocket and realDepth
                                float score = structuralDepth * 3.50 + structuralRatio * profileMean * 5.00 + math.max(0.0, profileMean - bestValleyVolume) * 1.35 - bestValleyVolume * 0.04
                                array.push(lvnCandidateRows, bestValleyRow)
                                array.push(lvnCandidateScores, score)

            sortCandidatesDescending(lvnCandidateRows, lvnCandidateScores)
            selectTopNodesWithForbidden(lvnCandidateRows, lvnRows, MAX_LVN_ZONES, effectiveNodeMergeDistance, hvnRows, effectiveHvnLvnDistance)

            bool profileOnRight = profileDirectionInput == "Extend Right"
            int safeDistance = clampInt(profileDistanceInput, 1, 500)
            int safeWidth = math.max(18, int(math.round(visibleBars * PROFILE_WIDTH_PCT / 100.0)))
            int widthMs = safeWidth * barMs
            int padMs = barMs
            int labelGapMs = barMs

            int profileLeftX = visibleRightTime + safeDistance * barMs
            int profileRightX = profileLeftX + widthMs

            int panelLeftX = profileLeftX - padMs
            int panelRightX = profileRightX + padMs

            int lineLeftX = visibleLeftTime
            int lineRightX = panelRightX

            int profileLabelX = panelRightX + labelGapMs

            int zoneLeftX = visibleLeftTime
            int zoneRightX = profileOnRight ? profileLeftX : panelRightX

            int nodeLabelX = profileOnRight ? profileLeftX : profileLabelX

            selectedLabelSize = getLabelSize(labelSizeInput)

            float valueAreaBottom = profileLow + valueAreaLowRow * rowHeight
            float valueAreaTop = profileLow + (valueAreaHighRow + 1) * rowHeight
            float pocBandBottom = profileLow + pocRow * rowHeight
            float pocBandTop = profileLow + (pocRow + 1) * rowHeight

            float vahPrice = valueAreaTop
            float valPrice = valueAreaBottom
            float pocPrice = rowMidPrice(profileLow, rowHeight, pocRow)

            if showPocInput
                box pocCoreBox = box.new(left=panelLeftX, top=pocBandTop, right=panelRightX, bottom=pocBandBottom, xloc=xloc.bar_time, bgcolor=color.new(pocColorInput, 88), border_color=color.new(pocColorInput, 62), border_width=1)
                array.push(profileBoxes, pocCoreBox)

            if showHvnInput and array.size(hvnRows) > 0
                for i = 0 to array.size(hvnRows) - 1
                    int row = array.get(hvnRows, i)
                    [hvnLowerRow, hvnUpperRow] = hvnBounds(smoothBins, row, pocRow, profileMean)

                    float zoneBottom = profileLow + hvnLowerRow * rowHeight
                    float zoneTop = profileLow + (hvnUpperRow + 1) * rowHeight
                    float zoneMid = (zoneTop + zoneBottom) / 2.0

                    box zone = box.new(left=zoneLeftX, top=zoneTop, right=zoneRightX, bottom=zoneBottom, xloc=xloc.bar_time, bgcolor=color.new(hvnColorInput, ZONE_TRANSPARENCY), border_color=color.new(hvnColorInput, 42), border_width=1)
                    array.push(zoneBoxes, zone)

                    if showLabelsInput
                        label zoneLabel = label.new(x=nodeLabelX, y=zoneMid, text=labelText("HVN", zoneMid), xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_left, color=color.new(hvnColorInput, 5), textcolor=hvnLabelTextColorInput, size=selectedLabelSize)
                        array.push(drawingLabels, zoneLabel)

            if showLvnInput and array.size(lvnRows) > 0
                for i = 0 to array.size(lvnRows) - 1
                    int row = array.get(lvnRows, i)

                    int leftSearchStart = math.max(0, row - PROMINENCE_SEARCH_ROWS)
                    int rightSearchEnd = math.min(rowsCount - 1, row + PROMINENCE_SEARCH_ROWS)

                    float leftShoulder = rangeMax(smoothBins, leftSearchStart, row - 1)
                    float rightShoulder = rangeMax(smoothBins, row + 1, rightSearchEnd)
                    float weakerShoulder = math.min(leftShoulder, rightShoulder)

                    [lvnLowerRow, lvnUpperRow] = lvnBounds(smoothBins, row, profileMean, weakerShoulder)

                    float zoneBottom = profileLow + lvnLowerRow * rowHeight
                    float zoneTop = profileLow + (lvnUpperRow + 1) * rowHeight
                    float zoneMid = (zoneTop + zoneBottom) / 2.0

                    box zone = box.new(left=zoneLeftX, top=zoneTop, right=zoneRightX, bottom=zoneBottom, xloc=xloc.bar_time, bgcolor=color.new(lvnColorInput, ZONE_TRANSPARENCY), border_color=color.new(lvnColorInput, 42), border_width=1)
                    array.push(zoneBoxes, zone)

                    if showLabelsInput
                        label zoneLabel = label.new(x=nodeLabelX, y=zoneMid, text=labelText("LVN", zoneMid), xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_left, color=color.new(lvnColorInput, 5), textcolor=lvnLabelTextColorInput, size=selectedLabelSize)
                        array.push(drawingLabels, zoneLabel)

            int reservedBoxes = array.size(zoneBoxes) + array.size(profileBoxes) + 10
            int availableProfileBoxes = math.max(0, 500 - reservedBoxes)

            for row = 0 to rowsCount - 1
                float rowVolume = array.get(totalBins, row)

                if rowVolume > 0.0 and availableProfileBoxes > 0
                    float bullishVolume = array.get(bullBins, row)
                    float bearishVolume = array.get(bearBins, row)

                    float rowBottom = profileLow + row * rowHeight
                    float rowTop = rowBottom + rowHeight
                    float rowGap = rowHeight * 0.15

                    float relativeVolume = clampFloat(rowVolume / maxRawVolume, 0.0, 1.0)
                    int totalWidth = math.max(1, int(math.round(relativeVolume * safeWidth)))

                    bool rowIsPoc = row == pocRow
                    bool rowIsNode = rowInsideNodes(row, hvnRows, MAX_HVN_HALF_WIDTH_ROWS) or rowInsideNodes(row, lvnRows, MAX_LVN_HALF_WIDTH_ROWS)

                    int adaptiveTransparency = clampInt(PROFILE_TRANSPARENCY - int(math.round(relativeVolume * 20.0)), 0, 100)
                    int barTransparency = rowIsPoc ? POC_PROFILE_TRANSPARENCY : rowIsNode ? NODE_PROFILE_TRANSPARENCY : adaptiveTransparency

                    int bearWidth = 0
                    int bullWidth = 0

                    if bullishVolume > 0.0 and bearishVolume > 0.0
                        if totalWidth <= 1
                            bearWidth := bearishVolume >= bullishVolume ? 1 : 0
                            bullWidth := bearishVolume >= bullishVolume ? 0 : 1
                        else
                            bearWidth := clampInt(int(math.round(totalWidth * bearishVolume / rowVolume)), 1, totalWidth - 1)
                            bullWidth := totalWidth - bearWidth
                    else if bearishVolume > 0.0
                        bearWidth := totalWidth
                    else if bullishVolume > 0.0
                        bullWidth := totalWidth

                    if profileOnRight
                        int currentLeftX = profileLeftX

                        if bearWidth > 0 and availableProfileBoxes > 0
                            box bearishProfileBar = box.new(left=currentLeftX, top=rowTop - rowGap, right=currentLeftX + bearWidth * barMs, bottom=rowBottom + rowGap, xloc=xloc.bar_time, bgcolor=color.new(bearProfileColorInput, barTransparency), border_color=color.new(bearProfileColorInput, 100), border_width=0)
                            array.push(profileBoxes, bearishProfileBar)
                            currentLeftX += bearWidth * barMs
                            availableProfileBoxes -= 1

                        if bullWidth > 0 and availableProfileBoxes > 0
                            box bullishProfileBar = box.new(left=currentLeftX, top=rowTop - rowGap, right=currentLeftX + bullWidth * barMs, bottom=rowBottom + rowGap, xloc=xloc.bar_time, bgcolor=color.new(bullProfileColorInput, barTransparency), border_color=color.new(bullProfileColorInput, 100), border_width=0)
                            array.push(profileBoxes, bullishProfileBar)
                            availableProfileBoxes -= 1
                    else
                        int currentRightX = profileRightX

                        if bearWidth > 0 and availableProfileBoxes > 0
                            box bearishProfileBar = box.new(left=currentRightX - bearWidth * barMs, top=rowTop - rowGap, right=currentRightX, bottom=rowBottom + rowGap, xloc=xloc.bar_time, bgcolor=color.new(bearProfileColorInput, barTransparency), border_color=color.new(bearProfileColorInput, 100), border_width=0)
                            array.push(profileBoxes, bearishProfileBar)
                            currentRightX -= bearWidth * barMs
                            availableProfileBoxes -= 1

                        if bullWidth > 0 and availableProfileBoxes > 0
                            box bullishProfileBar = box.new(left=currentRightX - bullWidth * barMs, top=rowTop - rowGap, right=currentRightX, bottom=rowBottom + rowGap, xloc=xloc.bar_time, bgcolor=color.new(bullProfileColorInput, barTransparency), border_color=color.new(bullProfileColorInput, 100), border_width=0)
                            array.push(profileBoxes, bullishProfileBar)
                            availableProfileBoxes -= 1

            if showPocInput
                line pocLine = line.new(x1=lineLeftX, y1=pocPrice, x2=lineRightX, y2=pocPrice, xloc=xloc.bar_time, extend=extend.none, color=pocColorInput, width=pocLineWidthInput, style=getLineStyle(pocLineStyleInput))
                array.push(drawingLines, pocLine)

                if showLabelsInput
                    label pocLabel = label.new(x=profileLabelX, y=pocPrice, text=labelText("POC", pocPrice), xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_left, color=color.new(pocColorInput, 0), textcolor=profileLevelTextColorInput, size=selectedLabelSize)
                    array.push(drawingLabels, pocLabel)

            if showVahValInput
                line vahLine = line.new(x1=lineLeftX, y1=vahPrice, x2=lineRightX, y2=vahPrice, xloc=xloc.bar_time, extend=extend.none, color=color.new(valueAreaColorInput, 20), width=vahValLineWidthInput, style=getLineStyle(vahValLineStyleInput))
                line valLine = line.new(x1=lineLeftX, y1=valPrice, x2=lineRightX, y2=valPrice, xloc=xloc.bar_time, extend=extend.none, color=color.new(valueAreaColorInput, 20), width=vahValLineWidthInput, style=getLineStyle(vahValLineStyleInput))

                array.push(drawingLines, vahLine)
                array.push(drawingLines, valLine)

                if showLabelsInput
                    label vahLabel = label.new(x=profileLabelX, y=vahPrice, text=labelText("VAH", vahPrice), xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_left, color=color.new(valueAreaColorInput, 0), textcolor=profileLevelTextColorInput, size=selectedLabelSize)
                    label valLabel = label.new(x=profileLabelX, y=valPrice, text=labelText("VAL", valPrice), xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_left, color=color.new(valueAreaColorInput, 0), textcolor=profileLevelTextColorInput, size=selectedLabelSize)

                    array.push(drawingLabels, vahLabel)
                    array.push(drawingLabels, valLabel)

// Main calculation

if barstate.islast
    clearBoxes(profileBoxes)
    clearBoxes(zoneBoxes)
    clearLabels(drawingLabels)
    clearLines(drawingLines)

    int scanBars = math.min(bar_index + 1, MAX_LOOKBACK_BARS)
    int visibleCount = 0

    int leftVisibleTime = chart.left_visible_bar_time
    int rightVisibleTime = chart.right_visible_bar_time

    for i = 0 to scanBars - 1
        bool insideVisibleRange = time[i] >= leftVisibleTime and time[i] <= rightVisibleTime
        if insideVisibleRange
            visibleCount += 1

    visibleCount := math.max(visibleCount, 1)

    int timeframeMs = timeframe.in_seconds(timeframe.period) * 1000
    int detectedBarMs = bar_index > 0 ? time - time[1] : timeframeMs
    int barMs = math.max(1, nz(detectedBarMs, timeframeMs))

    drawVisibleProfile(leftVisibleTime, rightVisibleTime, visibleCount, barMs)
````
