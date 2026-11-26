# Footprint Order Flow Heatmap + Imbalances [PineIndicators]

- url: https://www.tradingview.com/script/KzezeSFa-Footprint-Order-Flow-Heatmap-Imbalances-PineIndicators/
- type: indicator
- pine_id: PUB;362128814fc4432f83669624d2612d11
- version: 2.0

## Description

Order Flow Heatmap + Stacked Imbalances visualizes executed order flow directly on the price chart using TradingView Volume Footprint data.

The indicator combines a configurable price/time heatmap with optional projected stacked imbalance zones. Its purpose is to make areas of concentrated executed volume, directional delta, and significant footprint imbalance easier to identify without displaying a full numerical footprint chart.

Heatmap

The heatmap aggregates executed footprint data into configurable time columns and relative logarithmic price zones.

In Volume mode, cells represent concentrations of executed volume. Lower-activity areas remain subtle, while stronger concentrations progress through a multi-stage heat gradient.

In Delta mode, the map represents the absolute strength and direction of executed delta. Positive delta is shown in green tones and negative delta in red tones, with intensity reflecting the relative magnitude.

The Sensitivity setting controls how selective the visualization is. Lower values retain only stronger concentrations, while higher values progressively expose more of the underlying order-flow structure.

Cells that are filtered out do not consume the script's available drawing capacity. This allows the indicator to automatically display more historical depth when a selective sensitivity setting is used.

Stacked Imbalances

A stacked imbalance occurs when multiple consecutive footprint price rows meet the selected diagonal imbalance threshold.

Instead of converting a stacked imbalance into a single horizontal line, this indicator preserves its actual price range and displays it as a projected zone.

Buy stacked imbalances use a green/turquoise color family. Sell stacked imbalances use a red/burgundy color family. Direction therefore remains immediately identifiable regardless of strength.

Within each direction, color intensity represents relative stack strength. Buy and sell stacks are normalized independently so that differences remain visible even when the raw strength values occupy a narrow range.

Stack strength takes into account the diagonal imbalance ratios across the qualifying rows together with the number of consecutive rows in the stack. A geometric average is used for the imbalance ratios to reduce distortion from isolated extreme values.

A projected stacked zone continues forward until price first revisits its price range. On that first retest, the zone stops extending but remains visible historically. This allows users to see:

where the stacked imbalance originally formed,
how long the zone remained untouched,
and where price eventually revisited it.

Historical tested zones are slightly faded, while still retaining their original directional color.

View modes

Heatmap is the default mode and dedicates nearly all available drawing capacity to the executed order-flow heatmap.

Stacked Levels focuses the available capacity on stacked imbalance zones and provides substantially more projected-zone history.

Heatmap + Levels displays both components while intentionally prioritizing the heatmap so that projected zones do not visually overwhelm the underlying order-flow structure.

Inputs

Bars per column controls horizontal time aggregation. Higher values combine more candles into each heatmap column.

Price detail controls vertical price resolution. Lower values produce coarser zones and generally allow faster/deeper processing. Higher values provide finer price detail.

Map switches the heatmap between executed Volume and Delta.

Sensitivity determines how selective the heatmap is.

Imbalance % controls the diagonal imbalance threshold used for stacked imbalance detection. For example, 300% corresponds approximately to a 3:1 relationship, while 500% represents approximately 5:1.

Stack size defines the minimum number of consecutive qualifying imbalance rows required to create a stacked zone.

Color interpretation

Heatmap colors represent intensity of executed order flow.

Stacked imbalance colors use a different semantic model:

Green/turquoise = Buy stacked imbalance
Red/burgundy = Sell stacked imbalance
More saturated / visible = stronger relative stack
More transparent = weaker relative stack
Faded and stopped = historically retested stack

Important limitation

This indicator is based on executed Volume Footprint data. Projected stacked imbalance zones represent historical executed order-flow structures.

They do not represent live resting limit orders and should not be interpreted as Level 2 or current order-book liquidity.

Footprint availability and granularity depend on the symbol and data available through TradingView. Higher price-detail settings and large historical ranges can also require additional processing.

This is an analytical visualization tool, not a standalone trading signal.

Developed by PineIndicators.

## Source Code

````pine
// © 2026 PineIndicators
// Footprint Order Flow Heatmap + Stacked Imbalances
//
// Visualizes executed Volume Footprint data as a price/time heatmap
// and optional strength-weighted stacked imbalance zones.
//
// For analytical purposes only.

//@version=6
indicator("Footprint Order Flow Heatmap + Stacked Imbalances [PineIndicators]", shorttitle="Order Flow [PineIndicators]", overlay=true, behind_chart=true, max_boxes_count=500)

//=============================================================================
// TYPES
//=============================================================================

type FlowCell
    int group
    int bin
    float volume
    float delta

//=============================================================================
// SETTINGS
//=============================================================================

groupMain = "Order Flow"

string viewMode = input.string("Heatmap", "View", options=["Heatmap", "Stacked Levels", "Heatmap + Levels"], group=groupMain, tooltip="Heatmap = maximum heatmap detail\nStacked Levels = maximum stacked-level history\nHeatmap + Levels = heatmap stays dominant")

int barsPerColumn = input.int(5, "Bars per column", minval=1, step=1, group=groupMain)

int priceDetail = input.int(50, "Price detail", minval=1, maxval=100, step=1, group=groupMain, tooltip="1 = coarse / deeper / faster\n50 = balanced\n100 = fine / heavier")

string mapMode = input.string("Volume", "Map", options=["Volume", "Delta"], group=groupMain)

int heatSensitivity = input.int(5, "Sensitivity", minval=1, maxval=10, step=1, group=groupMain)

//=============================================================================
// STACKED LEVELS
//=============================================================================

groupStacks = "Stacked Levels"

int imbalancePercent = input.int(300, "Imbalance %", minval=100, step=25, group=groupStacks, tooltip="300 = about 3:1\n500 = about 5:1\n1000 = about 10:1\n\nNo artificial maximum.")

int stackSize = input.int(3, "Stack size", minval=2, step=1, group=groupStacks)

//=============================================================================
// MODES
//=============================================================================

bool showHeatmap = viewMode != "Stacked Levels"
bool showStacks = viewMode != "Heatmap"
bool combinedView = viewMode == "Heatmap + Levels"

//=============================================================================
// BOX BUDGET
//=============================================================================

int heatmapBoxBudget = 0
int zoneBoxBudget = 0

if viewMode == "Heatmap"
    heatmapBoxBudget := 490
    zoneBoxBudget := 0
else if viewMode == "Stacked Levels"
    heatmapBoxBudget := 0
    zoneBoxBudget := 490
else
    heatmapBoxBudget := 410
    zoneBoxBudget := 80

//=============================================================================
// INTERNAL LIMITS
//=============================================================================

const int CELL_MAP_HARD_CAP = 6500
const int CELL_MAP_TRIM_TO = 4800
const int MAX_BINS_PER_RAW_ROW = 10
const int DUPLICATE_LOOKBACK = 20

//=============================================================================
// RELATIVE PRICE GRID
//=============================================================================

const float MAX_ROW_PERCENT = 2.00
const float MIN_ROW_PERCENT = 0.01

float detailNormalized = float(priceDetail - 1) / 99.0
float rowPercent = MAX_ROW_PERCENT * math.pow(MIN_ROW_PERCENT / MAX_ROW_PERCENT, detailNormalized)
float logStep = math.log(1.0 + rowPercent / 100.0)

//=============================================================================
// HISTORY
//=============================================================================

int heatHistory = 2400 - int(math.round(detailNormalized * 700.0))
int stackHistory = 3600 - int(math.round(detailNormalized * 900.0))
int combinedHistory = 1800 - int(math.round(detailNormalized * 500.0))

int sourceHistory = heatHistory

if viewMode == "Stacked Levels"
    sourceHistory := stackHistory
else if viewMode == "Heatmap + Levels"
    sourceHistory := combinedHistory

sourceHistory := math.max(500, sourceHistory)

int sourceStart = math.max(0, last_bar_index - sourceHistory + 1)
bool insideSourceHistory = bar_index >= sourceStart

//=============================================================================
// RAW FOOTPRINT RESOLUTION
//=============================================================================

int baseSourceTicks = 1
float maxCoarsening = 10.0

if syminfo.type == "crypto"
    maxCoarsening := 40.0

    if syminfo.mintick >= 0.01
        baseSourceTicks := 50
    else if syminfo.mintick >= 0.001
        baseSourceTicks := 20
    else if syminfo.mintick >= 0.0001
        baseSourceTicks := 5
    else
        baseSourceTicks := 1

else if syminfo.type == "index"
    baseSourceTicks := 1
    maxCoarsening := 20.0

else
    baseSourceTicks := 1
    maxCoarsening := 10.0

float sourceCoarsening = math.pow(maxCoarsening, float(100 - priceDetail) / 99.0)

float tfSeconds = timeframe.in_seconds()
float timeframeFactor = 1.0

if tfSeconds >= 86400
    timeframeFactor := 4.0
else if tfSeconds >= 14400
    timeframeFactor := 3.0
else if tfSeconds >= 3600
    timeframeFactor := 2.0

int sourceTicks = int(math.round(float(baseSourceTicks) * sourceCoarsening * timeframeFactor))
sourceTicks := math.max(1, sourceTicks)

//=============================================================================
// FOOTPRINT
//=============================================================================

footprint fp = request.footprint(sourceTicks, 70, imbalancePercent)

//=============================================================================
// GRID FUNCTIONS
//=============================================================================

f_priceToBin(float priceValue, float stepValue) =>
    int result = 0
    if priceValue > 0 and stepValue > 0
        result := int(math.floor(math.log(priceValue) / stepValue))
    result


f_binLow(int binValue, float stepValue) =>
    math.exp(float(binValue) * stepValue)


f_binHigh(int binValue, float stepValue) =>
    math.exp(float(binValue + 1) * stepValue)

//=============================================================================
// MAP FUNCTIONS
//=============================================================================

f_trimCells(map<string, FlowCell> target, int keepCount) =>
    int currentSize = target.size()

    if currentSize > keepCount
        array<string> keys = target.keys()
        int removeCount = currentSize - keepCount
        removeCount := math.min(removeCount, array.size(keys))

        int i = 0
        while i < removeCount
            string key = array.get(keys, i)
            target.remove(key)
            i := i + 1

    true


f_addCell(map<string, FlowCell> target, string key, int groupValue, int binValue, float volumeValue, float deltaValue) =>
    bool alreadyExists = target.contains(key)

    if not alreadyExists and target.size() >= CELL_MAP_HARD_CAP
        f_trimCells(target, CELL_MAP_TRIM_TO)

    if target.contains(key)
        FlowCell cell = target.get(key)
        cell.volume := cell.volume + volumeValue
        cell.delta := cell.delta + deltaValue
        target.put(key, cell)
    else
        FlowCell cell = FlowCell.new(groupValue, binValue, volumeValue, deltaValue)
        target.put(key, cell)

    true

//=============================================================================
// HEATMAP COLORS
//=============================================================================

f_volumeColor(float heat) =>
    float x = math.max(0.0, math.min(1.0, heat))
    color result = na

    if x > 0.0
        if x < 0.15
            result := color.from_gradient(x, 0.00, 0.15, color.rgb(5, 15, 40, 95), color.rgb(5, 50, 110, 78))
        else if x < 0.35
            result := color.from_gradient(x, 0.15, 0.35, color.rgb(5, 50, 110, 78), color.rgb(0, 115, 190, 54))
        else if x < 0.55
            result := color.from_gradient(x, 0.35, 0.55, color.rgb(0, 115, 190, 54), color.rgb(0, 215, 215, 30))
        else if x < 0.75
            result := color.from_gradient(x, 0.55, 0.75, color.rgb(0, 215, 215, 30), color.rgb(235, 220, 45, 12))
        else if x < 0.90
            result := color.from_gradient(x, 0.75, 0.90, color.rgb(235, 220, 45, 12), color.rgb(255, 145, 20, 3))
        else
            result := color.from_gradient(x, 0.90, 1.00, color.rgb(255, 145, 20, 3), color.rgb(255, 50, 15, 0))

    result


f_deltaColor(float deltaValue, float heat) =>
    float h = math.max(0.0, math.min(1.0, heat))
    color result = na

    if h > 0.0
        color baseColor = color.gray

        if deltaValue >= 0
            baseColor := color.rgb(20, 225, 140)
        else
            baseColor := color.rgb(245, 50, 65)

        int transparency = int(math.round(89.0 - h * 87.0))
        transparency := math.max(2, math.min(89, transparency))

        result := color.new(baseColor, transparency)

    result

//=============================================================================
// PERCENTILE
//=============================================================================

f_percentile(array<float> sortedValues, float percentile) =>
    float result = 0.0
    int count = array.size(sortedValues)

    if count > 0
        float p = math.max(0.0, math.min(1.0, percentile))
        int index = int(math.floor(float(count - 1) * p))
        index := math.max(0, math.min(count - 1, index))
        result := array.get(sortedValues, index)

    result

//=============================================================================
// RELATIVE STACK NORMALIZATION
//=============================================================================

f_stackNormalized(float strength, float lowValue, float midValue, float highValue) =>
    float result = 0.5
    float epsilon = 0.000000001

    if highValue - lowValue > epsilon
        if strength <= midValue
            if midValue - lowValue > epsilon
                result := 0.5 * (strength - lowValue) / (midValue - lowValue)
            else
                result := 0.25
        else
            if highValue - midValue > epsilon
                result := 0.5 + 0.5 * (strength - midValue) / (highValue - midValue)
            else
                result := 0.75

        result := math.max(0.0, math.min(1.0, result))
    else
        float safeStrength = math.max(1.0, strength)
        result := math.log(safeStrength) / math.log(3.0)
        result := math.max(0.0, math.min(1.0, result))

    result

//=============================================================================
// STACK COLORS
//
// HUE = DIRECTION
// INTENSITY = RELATIVE STRENGTH
//
// BUY:
// dark teal -> turquoise -> saturated green
//
// SELL:
// dark burgundy -> crimson -> saturated red
//
// Tested zones stay historically visible but are faded slightly.
//=============================================================================

f_stackColor(int direction, float normalizedStrength, bool combined, bool tested) =>
    float x = math.max(0.0, math.min(1.0, normalizedStrength))

    int weakT = 92
    int midT = 60
    int strongT = 14

    if combined
        weakT := 98
        midT := 88
        strongT := 60

    if tested
        weakT := math.min(99, weakT + 2)
        midT := math.min(96, midT + 12)
        strongT := math.min(88, strongT + 22)

    color result = na

    if direction == 1
        if x < 0.50
            result := color.from_gradient(x, 0.00, 0.50, color.rgb(5, 65, 70, weakT), color.rgb(0, 185, 135, midT))
        else
            result := color.from_gradient(x, 0.50, 1.00, color.rgb(0, 185, 135, midT), color.rgb(0, 255, 90, strongT))
    else
        if x < 0.50
            result := color.from_gradient(x, 0.00, 0.50, color.rgb(80, 10, 40, weakT), color.rgb(205, 20, 55, midT))
        else
            result := color.from_gradient(x, 0.50, 1.00, color.rgb(205, 20, 55, midT), color.rgb(255, 25, 35, strongT))

    result

//=============================================================================
// STACK STORAGE
//=============================================================================

var array<box> zoneBoxes = array.new<box>()
var array<float> zoneLows = array.new<float>()
var array<float> zoneHighs = array.new<float>()
var array<int> zoneDirections = array.new<int>()
var array<int> zoneOriginBars = array.new<int>()
var array<bool> zoneActive = array.new<bool>()
var array<float> zoneStrengths = array.new<float>()

//=============================================================================
// REMOVE OLDEST
//=============================================================================

f_removeOldestZone(array<box> boxes, array<float> lows, array<float> highs, array<int> directions, array<int> origins, array<bool> activeStates, array<float> strengths) =>
    if array.size(boxes) > 0
        box oldBox = array.shift(boxes)
        box.delete(oldBox)

        array.shift(lows)
        array.shift(highs)
        array.shift(directions)
        array.shift(origins)
        array.shift(activeStates)
        array.shift(strengths)

    true

//=============================================================================
// ADD STACK
//=============================================================================

f_addStackZone(array<box> boxes, array<float> lows, array<float> highs, array<int> directions, array<int> origins, array<bool> activeStates, array<float> strengths, float newLow, float newHigh, int direction, float strengthScore, int originBar, int leftTime, int rightTime, int maxCount, bool combined) =>
    bool duplicate = false

    int count = array.size(boxes)
    int startIndex = math.max(0, count - DUPLICATE_LOOKBACK)
    int i = startIndex

    while i < count
        bool active = array.get(activeStates, i)
        int existingDirection = array.get(directions, i)

        if active and existingDirection == direction
            float existingLow = array.get(lows, i)
            float existingHigh = array.get(highs, i)

            float intersection = math.max(0.0, math.min(existingHigh, newHigh) - math.max(existingLow, newLow))
            float existingHeight = existingHigh - existingLow
            float newHeight = newHigh - newLow
            float smallerHeight = math.min(existingHeight, newHeight)

            float overlapRatio = 0.0

            if smallerHeight > 0
                overlapRatio := intersection / smallerHeight

            if overlapRatio >= 0.80
                duplicate := true

        i := i + 1

    if not duplicate and maxCount > 0
        if array.size(boxes) >= maxCount
            f_removeOldestZone(boxes, lows, highs, directions, origins, activeStates, strengths)

        color temporaryColor = color.new(direction == 1 ? color.rgb(0, 190, 130) : color.rgb(220, 25, 50), combined ? 92 : 70)

        box newBox = box.new(left=leftTime, top=newHigh, right=rightTime, bottom=newLow, xloc=xloc.bar_time, extend=extend.right, bgcolor=temporaryColor, border_color=na, border_width=0)

        array.push(boxes, newBox)
        array.push(lows, newLow)
        array.push(highs, newHigh)
        array.push(directions, direction)
        array.push(origins, originBar)
        array.push(activeStates, true)
        array.push(strengths, strengthScore)

    true

//=============================================================================
// HEATMAP SENSITIVITY
//=============================================================================

f_cutoffPercentile(int sensitivity) =>
    float result = switch sensitivity
        1 => 0.70
        2 => 0.64
        3 => 0.58
        4 => 0.52
        5 => 0.45
        6 => 0.39
        7 => 0.33
        8 => 0.27
        9 => 0.21
        => 0.15

    result


f_heat(float value, float cutoff, float strongValue, bool visible) =>
    float result = 0.0

    if visible
        float lowLog = math.log(1.0 + math.max(0.0, cutoff))
        float highLog = math.log(1.0 + math.max(strongValue, cutoff + 0.000000000001))
        float valueLog = math.log(1.0 + math.max(0.0, value))
        float denominator = highLog - lowLog

        if denominator > 0
            result := (valueLog - lowLog) / denominator

        result := math.max(0.0, math.min(1.0, result))
        result := math.max(0.05, result)
        result := math.pow(result, 0.62)

    result

//=============================================================================
// HEATMAP STORAGE
//=============================================================================

var map<string, FlowCell> confirmedCells = map.new<string, FlowCell>()
var map<string, FlowCell> liveCells = map.new<string, FlowCell>()

var array<box> heatBoxes = array.new<box>()

//=============================================================================
// RETEST STACKS
//
// The first later retest freezes the projected zone.
// The zone remains visible for historical analysis.
//=============================================================================

if showStacks and array.size(zoneBoxes) > 0
    int zoneIndex = 0

    while zoneIndex < array.size(zoneBoxes)
        bool active = array.get(zoneActive, zoneIndex)

        if active
            float zoneLow = array.get(zoneLows, zoneIndex)
            float zoneHigh = array.get(zoneHighs, zoneIndex)
            int originBar = array.get(zoneOriginBars, zoneIndex)

            bool touched = bar_index > originBar and high >= zoneLow and low <= zoneHigh

            if touched
                box zoneBox = array.get(zoneBoxes, zoneIndex)

                box.set_extend(zoneBox, extend.none)
                box.set_right(zoneBox, time_close)

                array.set(zoneActive, zoneIndex, false)

        zoneIndex := zoneIndex + 1

//=============================================================================
// LIVE HEATMAP RESET
//=============================================================================

if showHeatmap
    if not barstate.isconfirmed
        liveCells.clear()
    else if barstate.islast
        liveCells.clear()

//=============================================================================
// PROCESS FOOTPRINT
//=============================================================================

if insideSourceHistory and not na(fp)
    array<volume_row> rows = fp.rows()
    int rowCount = array.size(rows)

    int groupId = int(math.floor(float(bar_index) / float(barsPerColumn)))

    float requiredRatio = float(imbalancePercent) / 100.0
    float ratioCap = math.max(20.0, requiredRatio * 6.0)

    int buyRunLength = 0
    float buyRunLogRatioSum = 0.0
    float buyRunLow = na
    float buyRunHigh = na

    int sellRunLength = 0
    float sellRunLogRatioSum = 0.0
    float sellRunLow = na
    float sellRunHigh = na

    if rowCount > 0
        for rowIndex = 0 to rowCount - 1
            volume_row row = array.get(rows, rowIndex)

            //=================================================================
            // STACKED LEVELS
            //=================================================================

            if showStacks and barstate.isconfirmed
                bool buyImbalance = row.has_buy_imbalance()
                bool sellImbalance = row.has_sell_imbalance()

                //-------------------------------------------------------------
                // BUY RATIO
                //-------------------------------------------------------------

                float buyRatio = 0.0

                if buyImbalance
                    float buyVol = row.buy_volume()
                    float opposingSell = 0.0

                    if rowIndex > 0
                        volume_row lowerRow = array.get(rows, rowIndex - 1)
                        opposingSell := lowerRow.sell_volume()

                    if opposingSell > 0
                        buyRatio := buyVol / opposingSell
                    else
                        buyRatio := ratioCap

                    buyRatio := math.max(1.0, math.min(buyRatio, ratioCap))

                //-------------------------------------------------------------
                // SELL RATIO
                //-------------------------------------------------------------

                float sellRatio = 0.0

                if sellImbalance
                    float sellVol = row.sell_volume()
                    float opposingBuy = 0.0

                    if rowIndex < rowCount - 1
                        volume_row upperRow = array.get(rows, rowIndex + 1)
                        opposingBuy := upperRow.buy_volume()

                    if opposingBuy > 0
                        sellRatio := sellVol / opposingBuy
                    else
                        sellRatio := ratioCap

                    sellRatio := math.max(1.0, math.min(sellRatio, ratioCap))

                //-------------------------------------------------------------
                // BUY RUN
                //-------------------------------------------------------------

                if buyImbalance
                    if buyRunLength == 0
                        buyRunLow := row.down_price()
                        buyRunHigh := row.up_price()
                        buyRunLogRatioSum := math.log(buyRatio)
                    else
                        buyRunLow := math.min(buyRunLow, row.down_price())
                        buyRunHigh := math.max(buyRunHigh, row.up_price())
                        buyRunLogRatioSum := buyRunLogRatioSum + math.log(buyRatio)

                    buyRunLength := buyRunLength + 1

                else
                    if buyRunLength >= stackSize
                        float geometricRatio = math.exp(buyRunLogRatioSum / float(buyRunLength))
                        float relativeRatio = geometricRatio / requiredRatio
                        float lengthBoost = math.sqrt(float(buyRunLength) / float(stackSize))
                        float strengthScore = relativeRatio * lengthBoost

                        f_addStackZone(zoneBoxes, zoneLows, zoneHighs, zoneDirections, zoneOriginBars, zoneActive, zoneStrengths, buyRunLow, buyRunHigh, 1, strengthScore, bar_index, time, time_close, zoneBoxBudget, combinedView)

                    buyRunLength := 0
                    buyRunLogRatioSum := 0.0
                    buyRunLow := na
                    buyRunHigh := na

                //-------------------------------------------------------------
                // SELL RUN
                //-------------------------------------------------------------

                if sellImbalance
                    if sellRunLength == 0
                        sellRunLow := row.down_price()
                        sellRunHigh := row.up_price()
                        sellRunLogRatioSum := math.log(sellRatio)
                    else
                        sellRunLow := math.min(sellRunLow, row.down_price())
                        sellRunHigh := math.max(sellRunHigh, row.up_price())
                        sellRunLogRatioSum := sellRunLogRatioSum + math.log(sellRatio)

                    sellRunLength := sellRunLength + 1

                else
                    if sellRunLength >= stackSize
                        float geometricRatio = math.exp(sellRunLogRatioSum / float(sellRunLength))
                        float relativeRatio = geometricRatio / requiredRatio
                        float lengthBoost = math.sqrt(float(sellRunLength) / float(stackSize))
                        float strengthScore = relativeRatio * lengthBoost

                        f_addStackZone(zoneBoxes, zoneLows, zoneHighs, zoneDirections, zoneOriginBars, zoneActive, zoneStrengths, sellRunLow, sellRunHigh, -1, strengthScore, bar_index, time, time_close, zoneBoxBudget, combinedView)

                    sellRunLength := 0
                    sellRunLogRatioSum := 0.0
                    sellRunLow := na
                    sellRunHigh := na

            //=================================================================
            // HEATMAP
            //=================================================================

            if showHeatmap
                float rawLow = row.down_price()
                float rawHigh = row.up_price()
                float rawVolume = row.total_volume()
                float rawDelta = row.delta()
                float rawHeight = rawHigh - rawLow

                if rawLow > 0 and rawHigh > 0 and rawHeight > 0 and rawVolume > 0
                    float epsilon = math.max(syminfo.mintick * 0.0001, 0.000000000001)

                    int firstBin = f_priceToBin(rawLow, logStep)
                    int lastBin = f_priceToBin(rawHigh - epsilon, logStep)
                    int binSpan = lastBin - firstBin + 1

                    if binSpan <= MAX_BINS_PER_RAW_ROW
                        for binIndex = firstBin to lastBin
                            float binLow = f_binLow(binIndex, logStep)
                            float binHigh = f_binHigh(binIndex, logStep)

                            float overlapLow = math.max(rawLow, binLow)
                            float overlapHigh = math.min(rawHigh, binHigh)
                            float overlap = math.max(0.0, overlapHigh - overlapLow)

                            if overlap > 0
                                float fraction = overlap / rawHeight
                                float allocatedVolume = rawVolume * fraction
                                float allocatedDelta = rawDelta * fraction

                                string key = str.tostring(groupId) + "|" + str.tostring(binIndex)

                                if barstate.isconfirmed
                                    f_addCell(confirmedCells, key, groupId, binIndex, allocatedVolume, allocatedDelta)
                                else
                                    f_addCell(liveCells, key, groupId, binIndex, allocatedVolume, allocatedDelta)

                    else
                        float midpoint = (rawLow + rawHigh) / 2.0
                        int binIndex = f_priceToBin(midpoint, logStep)

                        string key = str.tostring(groupId) + "|" + str.tostring(binIndex)

                        if barstate.isconfirmed
                            f_addCell(confirmedCells, key, groupId, binIndex, rawVolume, rawDelta)
                        else
                            f_addCell(liveCells, key, groupId, binIndex, rawVolume, rawDelta)

        //=====================================================================
        // FINAL BUY
        //=====================================================================

        if showStacks and barstate.isconfirmed and buyRunLength >= stackSize
            float geometricRatio = math.exp(buyRunLogRatioSum / float(buyRunLength))
            float relativeRatio = geometricRatio / requiredRatio
            float lengthBoost = math.sqrt(float(buyRunLength) / float(stackSize))
            float strengthScore = relativeRatio * lengthBoost

            f_addStackZone(zoneBoxes, zoneLows, zoneHighs, zoneDirections, zoneOriginBars, zoneActive, zoneStrengths, buyRunLow, buyRunHigh, 1, strengthScore, bar_index, time, time_close, zoneBoxBudget, combinedView)

        //=====================================================================
        // FINAL SELL
        //=====================================================================

        if showStacks and barstate.isconfirmed and sellRunLength >= stackSize
            float geometricRatio = math.exp(sellRunLogRatioSum / float(sellRunLength))
            float relativeRatio = geometricRatio / requiredRatio
            float lengthBoost = math.sqrt(float(sellRunLength) / float(stackSize))
            float strengthScore = relativeRatio * lengthBoost

            f_addStackZone(zoneBoxes, zoneLows, zoneHighs, zoneDirections, zoneOriginBars, zoneActive, zoneStrengths, sellRunLow, sellRunHigh, -1, strengthScore, bar_index, time, time_close, zoneBoxBudget, combinedView)

//=============================================================================
// RELATIVE STACK RECOLORING
//
// Buy and sell stacks are normalized independently.
// Direction is encoded by hue; strength is encoded within that hue family.
//=============================================================================

if barstate.islast and showStacks and array.size(zoneBoxes) > 0
    array<float> buyDistribution = array.new<float>()
    array<float> sellDistribution = array.new<float>()

    int distributionIndex = 0

    while distributionIndex < array.size(zoneBoxes)
        int direction = array.get(zoneDirections, distributionIndex)
        float strength = array.get(zoneStrengths, distributionIndex)

        if direction == 1
            array.push(buyDistribution, strength)
        else
            array.push(sellDistribution, strength)

        distributionIndex := distributionIndex + 1

    array.sort(buyDistribution, order.ascending)
    array.sort(sellDistribution, order.ascending)

    float buyLow = f_percentile(buyDistribution, 0.10)
    float buyMid = f_percentile(buyDistribution, 0.50)
    float buyHigh = f_percentile(buyDistribution, 0.90)

    float sellLow = f_percentile(sellDistribution, 0.10)
    float sellMid = f_percentile(sellDistribution, 0.50)
    float sellHigh = f_percentile(sellDistribution, 0.90)

    int colorIndex = 0

    while colorIndex < array.size(zoneBoxes)
        box zoneBox = array.get(zoneBoxes, colorIndex)
        int direction = array.get(zoneDirections, colorIndex)
        float strength = array.get(zoneStrengths, colorIndex)
        bool active = array.get(zoneActive, colorIndex)

        float normalizedStrength = 0.5

        if direction == 1
            normalizedStrength := f_stackNormalized(strength, buyLow, buyMid, buyHigh)
        else
            normalizedStrength := f_stackNormalized(strength, sellLow, sellMid, sellHigh)

        color zoneColor = f_stackColor(direction, normalizedStrength, combinedView, not active)

        box.set_bgcolor(zoneBox, zoneColor)

        colorIndex := colorIndex + 1

//=============================================================================
// DRAW HEATMAP
//=============================================================================

if barstate.islast
    if array.size(heatBoxes) > 0
        for oldBox in heatBoxes
            box.delete(oldBox)

        heatBoxes.clear()

    if showHeatmap and heatmapBoxBudget > 0
        map<string, FlowCell> renderCells = map.new<string, FlowCell>()

        array<FlowCell> confirmedValues = confirmedCells.values()

        for cell in confirmedValues
            string key = str.tostring(cell.group) + "|" + str.tostring(cell.bin)
            f_addCell(renderCells, key, cell.group, cell.bin, cell.volume, cell.delta)

        array<FlowCell> liveValues = liveCells.values()

        for cell in liveValues
            string key = str.tostring(cell.group) + "|" + str.tostring(cell.bin)
            f_addCell(renderCells, key, cell.group, cell.bin, cell.volume, cell.delta)

        array<FlowCell> allCells = renderCells.values()

        //=====================================================================
        // DISTRIBUTIONS
        //=====================================================================

        array<float> volumeDistribution = array.new<float>()
        array<float> deltaDistribution = array.new<float>()

        int newestGroup = int(math.floor(float(last_bar_index) / float(barsPerColumn)))
        int oldestGroup = newestGroup

        for cell in allCells
            oldestGroup := math.min(oldestGroup, cell.group)

            int leftIndex = math.max(sourceStart, cell.group * barsPerColumn)
            int rightIndex = math.min(last_bar_index + 1, (cell.group + 1) * barsPerColumn)
            int barsInside = math.max(1, rightIndex - leftIndex)

            float volumePerBar = cell.volume / barsInside
            float absDeltaPerBar = math.abs(cell.delta) / barsInside

            array.push(volumeDistribution, volumePerBar)
            array.push(deltaDistribution, absDeltaPerBar)

        array.sort(volumeDistribution, order.ascending)
        array.sort(deltaDistribution, order.ascending)

        //=====================================================================
        // SENSITIVITY
        //=====================================================================

        float cutoffPercentile = f_cutoffPercentile(heatSensitivity)

        float volumeCutoff = f_percentile(volumeDistribution, cutoffPercentile)
        float deltaCutoff = f_percentile(deltaDistribution, cutoffPercentile)

        float volumeStrong = f_percentile(volumeDistribution, 0.98)
        float deltaStrong = f_percentile(deltaDistribution, 0.98)

        volumeStrong := math.max(volumeStrong, volumeCutoff + 0.000000000001)
        deltaStrong := math.max(deltaStrong, deltaCutoff + 0.000000000001)

        //=====================================================================
        // COUNT VISIBLE CELLS
        //=====================================================================

        map<int, int> visibleCounts = map.new<int, int>()

        for cell in allCells
            int leftIndex = math.max(sourceStart, cell.group * barsPerColumn)
            int rightIndex = math.min(last_bar_index + 1, (cell.group + 1) * barsPerColumn)
            int barsInside = math.max(1, rightIndex - leftIndex)

            float value = 0.0
            float cutoff = 0.0

            if mapMode == "Volume"
                value := cell.volume / barsInside
                cutoff := volumeCutoff
            else
                value := math.abs(cell.delta) / barsInside
                cutoff := deltaCutoff

            bool visible = value > cutoff

            if visible
                if visibleCounts.contains(cell.group)
                    int count = visibleCounts.get(cell.group)
                    visibleCounts.put(cell.group, count + 1)
                else
                    visibleCounts.put(cell.group, 1)

        //=====================================================================
        // MAXIMUM HISTORY
        //=====================================================================

        int earliestIncludedGroup = newestGroup
        int boxesNeeded = 0
        int scanGroup = newestGroup
        bool scanning = true

        while scanning and scanGroup >= oldestGroup
            int groupVisibleCount = 0

            if visibleCounts.contains(scanGroup)
                groupVisibleCount := visibleCounts.get(scanGroup)

            if boxesNeeded + groupVisibleCount <= heatmapBoxBudget
                boxesNeeded := boxesNeeded + groupVisibleCount
                earliestIncludedGroup := scanGroup
                scanGroup := scanGroup - 1
            else
                scanning := false

        //=====================================================================
        // DRAW
        //=====================================================================

        int drawnBoxes = 0

        for cell in allCells
            if cell.group >= earliestIncludedGroup and drawnBoxes < heatmapBoxBudget
                int leftIndex = math.max(sourceStart, cell.group * barsPerColumn)
                int rightIndex = math.min(last_bar_index + 1, (cell.group + 1) * barsPerColumn)
                int barsInside = math.max(1, rightIndex - leftIndex)

                float volumePerBar = cell.volume / barsInside
                float absDeltaPerBar = math.abs(cell.delta) / barsInside

                bool volumeVisible = volumePerBar > volumeCutoff
                bool deltaVisible = absDeltaPerBar > deltaCutoff

                float volumeHeat = f_heat(volumePerBar, volumeCutoff, volumeStrong, volumeVisible)
                float deltaHeat = f_heat(absDeltaPerBar, deltaCutoff, deltaStrong, deltaVisible)

                bool shouldDraw = false
                color cellColor = na

                if mapMode == "Volume"
                    shouldDraw := volumeVisible
                    cellColor := f_volumeColor(volumeHeat)
                else
                    shouldDraw := deltaVisible
                    cellColor := f_deltaColor(cell.delta, deltaHeat)

                if shouldDraw
                    float cellBottom = f_binLow(cell.bin, logStep)
                    float cellTop = f_binHigh(cell.bin, logStep)

                    box newHeatBox = box.new(left=leftIndex, top=cellTop, right=rightIndex, bottom=cellBottom, xloc=xloc.bar_index, bgcolor=cellColor, border_color=na, border_width=0)

                    array.push(heatBoxes, newHeatBox)

                    drawnBoxes := drawnBoxes + 1
````
