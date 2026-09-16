<!-- tradingview-pine-id: PUB;edbaf251f0d045589ec3495f2ca0f58e -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Key Zones [MMT]

Source: https://www.tradingview.com/script/0uIOjIjK-Key-Zones-MMT/

## Description

Key Zones [MMT] identifies confirmed, high-quality support and resistance areas from swing structure on a selectable timeframe. Rather than plotting every pivot, it groups nearby confirmed swing highs and lows into price zones, filters for meaningful rejection, and displays only the strongest, well-spaced areas.

The indicator is designed to keep charts clean while highlighting structural zones where price has shown repeated reaction and acceptance/rejection behavior.

How it works

- Detects confirmed swing highs and lows using configurable pivot strength
- Measures the departure from each swing in ATR terms to filter weak reactions
- Merges nearby pivots into a single neutral price zone
- Expands zone boundaries with ATR-based padding
- Rejects overly wide clusters to avoid imprecise zones
- Requires a minimum number of confirmed rejections before a zone can display
- Ranks qualified zones using:

[*]Rejection/touch count
[*]Average rejection strength
[*]Strongest individual rejection
[*]Support/resistance flip behavior, where both swing highs and lows have formed in the same area

- Enforces ATR-based spacing between displayed zones so nearby, lower-quality areas do not clutter the chart

Only the highest-ranked zones remain visible, up to the selected maximum.

Timeframe behavior

Zones are calculated from the selected Zone timeframe, which defaults to 1 hour. The zone timeframe must be equal to or higher than the chart timeframe.

For example, you can apply the indicator to a 1-minute or 5-minute execution chart while building zones from the 1-hour timeframe. This can help keep lower-timeframe trading decisions aligned with higher-timeframe structure.

Pivot data is processed only after confirmation, so the indicator is designed to avoid plotting unconfirmed pivot zones that later disappear.

Presets

The Detection preset controls the parameters used for swing detection, zone merging, rejection filtering, and visible-zone selection.

[*]Auto: Detects the chart symbol and applies a preset for NQ/MNQ, GC/MGC, ES/MES, other futures, or stocks.
[*]NQ / MNQ / GC / MGC: Tuned for instruments that generally benefit from stronger rejection requirements and wider structural spacing.
[*]ES / MES: Uses a slightly more responsive configuration, including fewer required rejections.
[*]Other futures: General-purpose futures configuration.
[*]Stocks: Applies settings intended for stock-like instruments.
[*]Custom: Unlocks all detection and rejection parameters for manual tuning.

Inputs

Custom zone detection

[*]Pivot strength: Number of bars required on each side of a swing point. Higher values create fewer, more significant pivots.
[*]Rejections required: Minimum number of qualified pivot reactions needed before a zone is eligible to display.
[*]Maximum pivot separation (ATR): Maximum ATR-adjusted distance allowed when merging pivots into the same zone.
[*]Zone padding (ATR): Additional ATR-based space added above and below each pivot to define the zone boundaries.
[*]Maximum zone width (ATR): Prevents clusters from becoming too broad to remain actionable.

Custom rejection filters

[*]ATR length: ATR period used for normalization.
[*]Minimum departure (ATR): Minimum price departure from a pivot required for it to qualify as a rejection.
[*]Minimum bars between touches: Prevents closely occurring pivots from being counted as separate rejections.
[*]Maximum tracked clusters: Limits the number of historical zone clusters retained by the script.
[*]Maximum visible zones: Caps the number of qualified zones shown on the chart.
[*]Minimum spacing between zones (ATR): Prevents similar zones from appearing too close together; the stronger zone takes priority.

Display

- Zone color mode

[*]Single color: Displays every zone using the neutral/single color.
[*]Support / resistance: Colors a zone as support when the latest confirmed zone-timeframe close is above it, or resistance when that close is below it. Zones remain neutral when price closes inside them.

- Fill transparency and Border transparency: Control zone visibility.
- Show rejection count: Displays the number of qualified rejections inside each visible zone.

Alert

The indicator includes one alert condition:
Price entered a key zone: Triggers when price enters any currently displayed confirmed key zone.

Notes
Key Zones [MMT] is a market-structure tool, not a standalone trade signal. Use the zones alongside your execution model, trend context, liquidity targets, volume analysis, confirmation criteria, and risk management.

---

## Source Code

````pine
//@version=6
indicator("Key Zones [MMT]", shorttitle = "Key Zones [MMT]", overlay = true, max_boxes_count = 100)

// This indicator finds confirmed swing highs and lows on a selected timeframe.
// Nearby swings are merged into neutral zones. Qualified zones are ranked by
// touch count, rejection depth, and support/resistance flips. Nearby qualified
// zones compete so only the strongest structural area remains visible.

string GROUP_PRESET = "Preset"
string GROUP_DETECTION = "Custom zone detection"
string GROUP_FILTERS = "Custom rejection filters"
string GROUP_DISPLAY = "Display"

string PRESET_AUTO = "Auto"
string PRESET_NQ_GC = "NQ / MNQ / GC / MGC"
string PRESET_ES = "ES / MES"
string PRESET_FUTURES = "Other futures"
string PRESET_STOCKS = "Stocks"
string PRESET_CUSTOM = "Custom"

string COLOR_SINGLE = "Single color"
string COLOR_SUPPORT_RESISTANCE = "Support / resistance"

string presetInput = input.string(PRESET_AUTO, "Detection preset", options = [PRESET_AUTO, PRESET_NQ_GC, PRESET_ES, PRESET_FUTURES, PRESET_STOCKS, PRESET_CUSTOM], tooltip = "Auto recognizes NQ/MNQ, ES/MES, GC/MGC, other futures, and stocks from the chart symbol.", group = GROUP_PRESET)
string zoneTimeframeInput = input.timeframe("60", "Zone timeframe", tooltip = "Defaults to 1 hour. Use the chart timeframe or a higher timeframe.", group = GROUP_PRESET)
bool customInputsActive = presetInput == PRESET_CUSTOM

int pivotStrengthInput = input.int(4, "Pivot strength", minval = 1, maxval = 20, tooltip = "Bars required on each side of a swing.", group = GROUP_DETECTION, active = customInputsActive)
int minimumTouchesInput = input.int(3, "Rejections required", minval = 2, maxval = 10, group = GROUP_DETECTION, active = customInputsActive)
float mergeDistanceAtrInput = input.float(0.50, "Maximum pivot separation (ATR)", minval = 0.05, maxval = 3.00, step = 0.05, group = GROUP_DETECTION, active = customInputsActive)
float zonePaddingAtrInput = input.float(0.08, "Zone padding (ATR)", minval = 0.00, maxval = 1.00, step = 0.01, group = GROUP_DETECTION, active = customInputsActive)
float maximumZoneWidthAtrInput = input.float(0.60, "Maximum zone width (ATR)", minval = 0.10, maxval = 3.00, step = 0.05, group = GROUP_DETECTION, active = customInputsActive)

int atrLengthInput = input.int(14, "ATR length", minval = 1, maxval = 100, group = GROUP_FILTERS, active = customInputsActive)
float minimumRejectionAtrInput = input.float(0.60, "Minimum departure (ATR)", minval = 0.00, maxval = 5.00, step = 0.05, group = GROUP_FILTERS, active = customInputsActive)
int minimumSeparationInput = input.int(3, "Minimum bars between touches", minval = 1, maxval = 50, group = GROUP_FILTERS, active = customInputsActive)
int maximumTrackedZonesInput = input.int(80, "Maximum tracked clusters", minval = 20, maxval = 200, group = GROUP_FILTERS, active = customInputsActive)
int maximumVisibleZonesInput = input.int(5, "Maximum visible zones", minval = 1, maxval = 20, group = GROUP_FILTERS, active = customInputsActive)
float minimumVisibleSpacingAtrInput = input.float(1.25, "Minimum spacing between zones (ATR)", minval = 0.25, maxval = 5.00, step = 0.25, group = GROUP_FILTERS, active = customInputsActive)

string colorModeInput = input.string(COLOR_SINGLE, "Zone color mode", options = [COLOR_SINGLE, COLOR_SUPPORT_RESISTANCE], group = GROUP_DISPLAY)
color zoneColorInput = input.color(color.gray, "Neutral / single color", tooltip = "Used for every zone in Single color mode and whenever price closes inside a zone.", group = GROUP_DISPLAY)
color supportZoneColorInput = input.color(color.teal, "Support zone color", tooltip = "Used when the latest confirmed zone-timeframe close is above the zone.", group = GROUP_DISPLAY, active = colorModeInput == COLOR_SUPPORT_RESISTANCE)
color resistanceZoneColorInput = input.color(color.red, "Resistance zone color", tooltip = "Used when the latest confirmed zone-timeframe close is below the zone.", group = GROUP_DISPLAY, active = colorModeInput == COLOR_SUPPORT_RESISTANCE)
int fillTransparencyInput = input.int(78, "Fill transparency", minval = 0, maxval = 100, group = GROUP_DISPLAY)
int borderTransparencyInput = input.int(30, "Border transparency", minval = 0, maxval = 100, group = GROUP_DISPLAY)
bool showTouchCountInput = input.bool(false, "Show rejection count", group = GROUP_DISPLAY)

bool isNqOrGc = syminfo.root == "NQ" or syminfo.root == "MNQ" or syminfo.root == "GC" or syminfo.root == "MGC"
bool isEs = syminfo.root == "ES" or syminfo.root == "MES"
bool isStockLike = syminfo.type == "stock" or syminfo.type == "fund" or syminfo.type == "dr"
string automaticPreset = syminfo.type == "futures" ? (isNqOrGc ? PRESET_NQ_GC : isEs ? PRESET_ES : PRESET_FUTURES) : isStockLike ? PRESET_STOCKS : PRESET_FUTURES
string effectivePreset = presetInput == PRESET_AUTO ? automaticPreset : presetInput

int pivotStrength = switch effectivePreset
    PRESET_ES => 3
    PRESET_NQ_GC => 4
    PRESET_FUTURES => 4
    PRESET_STOCKS => 4
    => pivotStrengthInput

int minimumTouches = switch effectivePreset
    PRESET_ES => 2
    PRESET_NQ_GC => 3
    PRESET_FUTURES => 3
    PRESET_STOCKS => 3
    => minimumTouchesInput

float mergeDistanceAtr = switch effectivePreset
    PRESET_ES => 0.40
    PRESET_NQ_GC => 0.50
    PRESET_FUTURES => 0.50
    PRESET_STOCKS => 0.55
    => mergeDistanceAtrInput

float zonePaddingAtr = switch effectivePreset
    PRESET_ES => 0.06
    PRESET_NQ_GC => 0.08
    PRESET_FUTURES => 0.08
    PRESET_STOCKS => 0.08
    => zonePaddingAtrInput

float maximumZoneWidthAtr = switch effectivePreset
    PRESET_ES => 0.50
    PRESET_NQ_GC => 0.60
    PRESET_FUTURES => 0.65
    PRESET_STOCKS => 0.70
    => maximumZoneWidthAtrInput

int atrLength = effectivePreset == PRESET_CUSTOM ? atrLengthInput : 14

float minimumRejectionAtr = switch effectivePreset
    PRESET_ES => 0.40
    PRESET_NQ_GC => 0.60
    PRESET_FUTURES => 0.55
    PRESET_STOCKS => 0.55
    => minimumRejectionAtrInput

int minimumSeparation = switch effectivePreset
    PRESET_ES => 2
    PRESET_NQ_GC => 3
    PRESET_FUTURES => 3
    PRESET_STOCKS => 4
    => minimumSeparationInput

int maximumTrackedZones = effectivePreset == PRESET_CUSTOM ? maximumTrackedZonesInput : 80

int maximumVisibleZones = switch effectivePreset
    PRESET_ES => 6
    PRESET_NQ_GC => 5
    PRESET_FUTURES => 5
    PRESET_STOCKS => 5
    => maximumVisibleZonesInput

float minimumVisibleSpacingAtr = switch effectivePreset
    PRESET_ES => 1.00
    PRESET_NQ_GC => 1.25
    PRESET_FUTURES => 1.25
    PRESET_STOCKS => 1.25
    => minimumVisibleSpacingAtrInput

string zoneTimeframe = zoneTimeframeInput == "" ? timeframe.period : zoneTimeframeInput

if timeframe.in_seconds() > timeframe.in_seconds(zoneTimeframe)
    runtime.error("The Zone timeframe must be equal to or higher than the chart timeframe.")

// Each array index represents one price cluster.
var array<float> zoneTops = array.new<float>()
var array<float> zoneBottoms = array.new<float>()
var array<float> zoneMergeDistances = array.new<float>()
var array<float> zoneAtrValues = array.new<float>()
var array<float> zoneRejectionSums = array.new<float>()
var array<float> zoneStrongestRejections = array.new<float>()
var array<int> zoneTouchCounts = array.new<int>()
var array<int> zoneHighTouchCounts = array.new<int>()
var array<int> zoneLowTouchCounts = array.new<int>()
var array<int> zoneFirstTouchTimes = array.new<int>()
var array<int> zoneLastTouchTimes = array.new<int>()
var array<box> zoneDrawings = array.new<box>()

// Returns confirmed pivot data from the requested timeframe. Every requested
// expression is offset by one bar, making lookahead_on safe and non-repainting.
f_confirmedPivotData() =>
    float pivotHigh = ta.pivothigh(high, pivotStrength, pivotStrength)[1]
    float pivotLow = ta.pivotlow(low, pivotStrength, pivotStrength)[1]
    float pivotAtr = ta.atr(atrLength)[pivotStrength + 1]
    float lowestAfterHigh = ta.lowest(low, pivotStrength)[1]
    float highestAfterLow = ta.highest(high, pivotStrength)[1]
    float highRejectionAtr = not na(pivotHigh) and not na(pivotAtr) and pivotAtr > 0.0 ? (pivotHigh - lowestAfterHigh) / pivotAtr : na
    float lowRejectionAtr = not na(pivotLow) and not na(pivotAtr) and pivotAtr > 0.0 ? (highestAfterLow - pivotLow) / pivotAtr : na
    bool validHigh = not na(highRejectionAtr) and highRejectionAtr >= minimumRejectionAtr
    bool validLow = not na(lowRejectionAtr) and lowRejectionAtr >= minimumRejectionAtr
    [validHigh ? pivotHigh : na, validLow ? pivotLow : na, time[pivotStrength + 1], pivotAtr, validHigh ? highRejectionAtr : na, validLow ? lowRejectionAtr : na]

[higherTimeframePivotHigh, higherTimeframePivotLow, higherTimeframePivotTime, higherTimeframeAtr, higherTimeframeHighRejection, higherTimeframeLowRejection] = request.security(
     syminfo.tickerid,
     zoneTimeframe,
     f_confirmedPivotData(),
     gaps = barmerge.gaps_on,
     lookahead = barmerge.lookahead_on)

float higherTimeframeClose = request.security(
     syminfo.tickerid,
     zoneTimeframe,
     close[1],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on)

int minimumSeparationMilliseconds = int(timeframe.in_seconds(zoneTimeframe) * 1000.0 * minimumSeparation)

f_removeZone(int index) =>
    box drawing = array.get(zoneDrawings, index)
    if not na(drawing)
        box.delete(drawing)
    array.remove(zoneTops, index)
    array.remove(zoneBottoms, index)
    array.remove(zoneMergeDistances, index)
    array.remove(zoneAtrValues, index)
    array.remove(zoneRejectionSums, index)
    array.remove(zoneStrongestRejections, index)
    array.remove(zoneTouchCounts, index)
    array.remove(zoneHighTouchCounts, index)
    array.remove(zoneLowTouchCounts, index)
    array.remove(zoneFirstTouchTimes, index)
    array.remove(zoneLastTouchTimes, index)
    array.remove(zoneDrawings, index)

f_findOldestZone() =>
    int oldestIndex = -1
    int oldestTime = na
    int zoneCount = array.size(zoneTops)
    if zoneCount > 0
        for index = 0 to zoneCount - 1
            int candidateTime = array.get(zoneLastTouchTimes, index)
            if na(oldestTime) or candidateTime < oldestTime
                oldestTime := candidateTime
                oldestIndex := index
    oldestIndex

f_findMatchingZone(float pivotPrice, float pivotAtr) =>
    int matchingIndex = -1
    float shortestDistance = na
    int zoneCount = array.size(zoneTops)
    if zoneCount > 0
        for index = 0 to zoneCount - 1
            float zoneTop = array.get(zoneTops, index)
            float zoneBottom = array.get(zoneBottoms, index)
            float zoneCenter = (zoneTop + zoneBottom) * 0.5
            float distance = math.abs(pivotPrice - zoneCenter)
            float allowedDistance = math.max(array.get(zoneMergeDistances, index), pivotAtr * mergeDistanceAtr)
            float padding = math.max(pivotAtr * zonePaddingAtr, syminfo.mintick)
            float prospectiveTop = math.max(zoneTop, pivotPrice + padding)
            float prospectiveBottom = math.min(zoneBottom, pivotPrice - padding)
            float referenceAtr = math.max(array.get(zoneAtrValues, index), pivotAtr)
            bool widthAllowed = prospectiveTop - prospectiveBottom <= referenceAtr * maximumZoneWidthAtr
            if distance <= allowedDistance and widthAllowed and (na(shortestDistance) or distance < shortestDistance)
                shortestDistance := distance
                matchingIndex := index
    matchingIndex

f_zoneScore(int index) =>
    int touchCount = array.get(zoneTouchCounts, index)
    float averageRejection = array.get(zoneRejectionSums, index) / touchCount
    float strongestRejection = array.get(zoneStrongestRejections, index)
    bool hasFlipped = array.get(zoneHighTouchCounts, index) > 0 and array.get(zoneLowTouchCounts, index) > 0
    math.log(touchCount + 1.0) * 2.0 + averageRejection * 1.5 + strongestRejection * 0.75 + (hasFlipped ? 1.0 : 0.0)

f_isFarFromSelected(int candidateIndex, array<int> selectedIndices) =>
    bool farEnough = true
    float candidateCenter = (array.get(zoneTops, candidateIndex) + array.get(zoneBottoms, candidateIndex)) * 0.5
    float candidateAtr = array.get(zoneAtrValues, candidateIndex)
    int selectedCount = array.size(selectedIndices)
    if selectedCount > 0
        for selectedPosition = 0 to selectedCount - 1
            int selectedIndex = array.get(selectedIndices, selectedPosition)
            float selectedCenter = (array.get(zoneTops, selectedIndex) + array.get(zoneBottoms, selectedIndex)) * 0.5
            float selectedAtr = array.get(zoneAtrValues, selectedIndex)
            float requiredSpacing = math.max(candidateAtr, selectedAtr) * minimumVisibleSpacingAtr
            if math.abs(candidateCenter - selectedCenter) < requiredSpacing
                farEnough := false
    farEnough

f_boxText(int touchCount) =>
    showTouchCountInput ? str.tostring(touchCount) + " rejections" : ""

f_zoneDisplayColor(int index) =>
    float zoneTop = array.get(zoneTops, index)
    float zoneBottom = array.get(zoneBottoms, index)
    color displayColor = zoneColorInput
    if colorModeInput == COLOR_SUPPORT_RESISTANCE and not na(higherTimeframeClose)
        if higherTimeframeClose > zoneTop
            displayColor := supportZoneColorInput
        else if higherTimeframeClose < zoneBottom
            displayColor := resistanceZoneColorInput
    displayColor

f_createZoneBox(int index) =>
    color displayColor = f_zoneDisplayColor(index)
    box newDrawing = box.new(
         left = array.get(zoneFirstTouchTimes, index),
         top = array.get(zoneTops, index),
         right = time,
         bottom = array.get(zoneBottoms, index),
         xloc = xloc.bar_time,
         extend = extend.right,
         border_color = color.new(displayColor, borderTransparencyInput),
         border_width = 1,
         border_style = line.style_solid,
         bgcolor = color.new(displayColor, fillTransparencyInput),
         text = f_boxText(array.get(zoneTouchCounts, index)),
         text_size = size.tiny,
         text_color = color.new(displayColor, 0),
         text_halign = text.align_right,
         text_valign = text.align_center)
    array.set(zoneDrawings, index, newDrawing)

f_refreshVisibleZones() =>
    int zoneCount = array.size(zoneDrawings)
    if zoneCount > 0
        for index = 0 to zoneCount - 1
            box drawing = array.get(zoneDrawings, index)
            if not na(drawing)
                box.delete(drawing)
                array.set(zoneDrawings, index, na)

        array<int> selectedIndices = array.new<int>()
        for selectionNumber = 0 to maximumVisibleZones - 1
            int bestIndex = -1
            float bestScore = na
            int bestLastTouchTime = na
            for candidateIndex = 0 to zoneCount - 1
                bool alreadySelected = array.includes(selectedIndices, candidateIndex)
                bool enoughTouches = array.get(zoneTouchCounts, candidateIndex) >= minimumTouches
                bool properlySpaced = f_isFarFromSelected(candidateIndex, selectedIndices)
                if not alreadySelected and enoughTouches and properlySpaced
                    float candidateScore = f_zoneScore(candidateIndex)
                    int candidateLastTouchTime = array.get(zoneLastTouchTimes, candidateIndex)
                    bool higherScore = na(bestScore) or candidateScore > bestScore
                    bool newerTie = candidateScore == bestScore and (na(bestLastTouchTime) or candidateLastTouchTime > bestLastTouchTime)
                    if higherScore or newerTie
                        bestScore := candidateScore
                        bestLastTouchTime := candidateLastTouchTime
                        bestIndex := candidateIndex
            if bestIndex >= 0
                array.push(selectedIndices, bestIndex)
                f_createZoneBox(bestIndex)

f_processPivot(float pivotPrice, int pivotTime, float pivotAtr, float rejectionStrength, int pivotSide) =>
    int matchingIndex = f_findMatchingZone(pivotPrice, pivotAtr)
    if matchingIndex >= 0
        int previousTouchTime = array.get(zoneLastTouchTimes, matchingIndex)
        if pivotTime - previousTouchTime >= minimumSeparationMilliseconds
            int previousTouchCount = array.get(zoneTouchCounts, matchingIndex)
            float padding = math.max(pivotAtr * zonePaddingAtr, syminfo.mintick)
            float updatedTop = math.max(array.get(zoneTops, matchingIndex), pivotPrice + padding)
            float updatedBottom = math.min(array.get(zoneBottoms, matchingIndex), pivotPrice - padding)
            float updatedMergeDistance = math.max(array.get(zoneMergeDistances, matchingIndex), pivotAtr * mergeDistanceAtr)
            float updatedAtr = (array.get(zoneAtrValues, matchingIndex) * previousTouchCount + pivotAtr) / (previousTouchCount + 1)
            int updatedTouchCount = previousTouchCount + 1

            array.set(zoneTops, matchingIndex, updatedTop)
            array.set(zoneBottoms, matchingIndex, updatedBottom)
            array.set(zoneMergeDistances, matchingIndex, updatedMergeDistance)
            array.set(zoneAtrValues, matchingIndex, updatedAtr)
            array.set(zoneRejectionSums, matchingIndex, array.get(zoneRejectionSums, matchingIndex) + rejectionStrength)
            array.set(zoneStrongestRejections, matchingIndex, math.max(array.get(zoneStrongestRejections, matchingIndex), rejectionStrength))
            array.set(zoneTouchCounts, matchingIndex, updatedTouchCount)
            array.set(zoneHighTouchCounts, matchingIndex, array.get(zoneHighTouchCounts, matchingIndex) + (pivotSide == 1 ? 1 : 0))
            array.set(zoneLowTouchCounts, matchingIndex, array.get(zoneLowTouchCounts, matchingIndex) + (pivotSide == -1 ? 1 : 0))
            array.set(zoneLastTouchTimes, matchingIndex, pivotTime)
    else
        if array.size(zoneTops) >= maximumTrackedZones
            int oldestIndex = f_findOldestZone()
            if oldestIndex >= 0
                f_removeZone(oldestIndex)

        float padding = math.max(pivotAtr * zonePaddingAtr, syminfo.mintick)
        array.push(zoneTops, pivotPrice + padding)
        array.push(zoneBottoms, pivotPrice - padding)
        array.push(zoneMergeDistances, math.max(pivotAtr * mergeDistanceAtr, syminfo.mintick))
        array.push(zoneAtrValues, pivotAtr)
        array.push(zoneRejectionSums, rejectionStrength)
        array.push(zoneStrongestRejections, rejectionStrength)
        array.push(zoneTouchCounts, 1)
        array.push(zoneHighTouchCounts, pivotSide == 1 ? 1 : 0)
        array.push(zoneLowTouchCounts, pivotSide == -1 ? 1 : 0)
        array.push(zoneFirstTouchTimes, pivotTime)
        array.push(zoneLastTouchTimes, pivotTime)
        array.push(zoneDrawings, na)

var int lastProcessedHighPivotTime = na
var int lastProcessedLowPivotTime = na

bool newHighPivot = not na(higherTimeframePivotHigh) and not na(higherTimeframePivotTime) and (na(lastProcessedHighPivotTime) or higherTimeframePivotTime != lastProcessedHighPivotTime)
bool newLowPivot = not na(higherTimeframePivotLow) and not na(higherTimeframePivotTime) and (na(lastProcessedLowPivotTime) or higherTimeframePivotTime != lastProcessedLowPivotTime)

if newHighPivot
    f_processPivot(
         higherTimeframePivotHigh,
         higherTimeframePivotTime,
         higherTimeframeAtr,
         higherTimeframeHighRejection,
         1)
    lastProcessedHighPivotTime := higherTimeframePivotTime

if newLowPivot
    f_processPivot(
         higherTimeframePivotLow,
         higherTimeframePivotTime,
         higherTimeframeAtr,
         higherTimeframeLowRejection,
         -1)
    lastProcessedLowPivotTime := higherTimeframePivotTime

if newHighPivot or newLowPivot
    f_refreshVisibleZones()

// Keep the explicit right edge at the latest bar so optional text remains near
// current price, while extend.right continues the zone into future chart space.
if barstate.islast
    int zoneCount = array.size(zoneDrawings)
    if zoneCount > 0
        for index = 0 to zoneCount - 1
            box drawing = array.get(zoneDrawings, index)
            if not na(drawing)
                color displayColor = f_zoneDisplayColor(index)
                box.set_right(drawing, time)
                box.set_border_color(drawing, color.new(displayColor, borderTransparencyInput))
                box.set_bgcolor(drawing, color.new(displayColor, fillTransparencyInput))
                box.set_text_color(drawing, color.new(displayColor, 0))

bool priceInsideKeyZone = false
int zoneCountForAlert = array.size(zoneDrawings)
if zoneCountForAlert > 0
    for index = 0 to zoneCountForAlert - 1
        box drawing = array.get(zoneDrawings, index)
        if not na(drawing)
            float zoneTop = array.get(zoneTops, index)
            float zoneBottom = array.get(zoneBottoms, index)
            if high >= zoneBottom and low <= zoneTop
                priceInsideKeyZone := true

alertcondition(priceInsideKeyZone and not priceInsideKeyZone[1], "Price entered a key zone", "Price entered a confirmed key zone on {{ticker}}.")
````
