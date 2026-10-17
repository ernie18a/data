# Parallax Density Atlas [JOAT]

- url: https://www.tradingview.com/script/PodqUg9V-Parallax-Density-Atlas-JOAT/
- type: indicator
- pine_id: PUB;379beb1aa0f043018cb0dc170f816bae
- version: 1.0

## Description

[b]Parallax Density Atlas [JOAT][/b]

[b]Introduction[/b]

Parallax Density Atlas is an open-source price-acceptance overlay that maps where the market has spent the most time doing business across a recent lookback. It combines a kernel density estimate of recent closing prices with percentile-based value rails so the user can see both the smooth acceptance curve and the practical operating envelope around it.

The problem Parallax solves is hidden value structure. Traders often know whether price is moving, but not whether that movement is taking place inside accepted value, above value, or below value. Parallax puts that information directly on the chart through a point of control, value area boundaries, rails, cloud zones, and a concise dashboard.

[image]https://www.tradingview.com/x/31RnjZCt/[/image]

[b]Core Concepts[/b]

[b]1. Kernel density estimation[/b]

The script evaluates a Gaussian kernel across recent closes to estimate continuous price density:

[pine]
densitySum += gaussianKernel((evalPrice - samplePrice) / bandwidth)
densityValue = densitySum / (array.size(closeSample) * bandwidth)
[/pine]

This creates a smooth value map instead of a stepped histogram alone.

[b]2. Point of control and value area[/b]

The highest-density node becomes the point of control. From there, the script expands outward until the target percentage of total density is captured, defining the value area high and low.

[b]3. Percentile rails[/b]

In parallel with the KDE engine, the script maintains sorted close samples and derives lower and upper rails from user-defined percentiles. Those rails create a stable operating envelope around recent value.

[b]4. Density cloud[/b]

Only the densest accepted zones inside the value area are shaded as a cloud, keeping the display focused on high-importance price zones rather than every possible level.

[b]5. Context and skew[/b]

The dashboard reports whether current price is accepted inside value, expanding above value, or trading below accepted value, along with skew and rail width.

[image]https://www.tradingview.com/x/HfOsRqay/[/image]

[b]Features[/b]

[list]
[*][b]KDE value map:[/b] Smooth density estimate built from recent closes
[*][b]Point of control:[/b] Highest-density price node marked directly on the chart
[*][b]Value area boundaries:[/b] High and low edges of accepted price territory
[*][b]Percentile value rails:[/b] Smoothed lower and upper rails from sorted price samples
[*][b]Density cloud:[/b] Highlights only the strongest accepted zones
[*][b]Right-side profile:[/b] Extends density visually to the right of current price
[*][b]Optional candle tinting:[/b] Reflects where price sits inside the value structure
[*][b]Top-right dashboard:[/b] Shows POC, value area, rail width, skew, and current location state
[/list]

[b]Input Parameters[/b]

[b]Density Engine:[/b]
[list]
[*]Lookback
[*]Density Steps
[*]Bandwidth Multiplier
[*]Value Area Percent
[/list]

[b]Value Rails:[/b]
[list]
[*]Lower Rail Percentile
[*]Upper Rail Percentile
[*]Rail Smoothing
[/list]

[b]Visual System:[/b]
[list]
[*]Profile Width Bars
[*]Cloud Threshold
[*]Show Density Cloud
[*]Show Right Profile
[*]Tint Candles
[*]Show Dashboard
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Start with location[/b]
Read whether price is inside value, above value, or below value. This defines whether the market is rotating in accepted territory or exploring away from it.

[b]Step 2: Use POC as the acceptance anchor[/b]
The point of control marks the most accepted price in the sample window. Reactions around it can frame mean-reversion and acceptance behavior.

[b]Step 3: Compare rails with value area[/b]
The rails provide a smoothed operating envelope while the value area shows the densest accepted region. Using both together gives a more complete value map.

[b]Step 4: Monitor skew[/b]
Positive skew means the density center is leaning upward in the sample range. Negative skew means accepted value is leaning lower.

[b]Indicator Limitations[/b]

[list]
[*]The density map is lookback-dependent and will evolve as old data leaves the sample
[*]KDE on closing prices is an acceptance approximation, not a full order-flow model
[*]Strong trends can stay outside accepted value for extended periods
[/list]

[b]Originality Statement[/b]

Parallax Density Atlas is original in how it pairs a continuous KDE-based value map with percentile rails and a selective density cloud in one overlay. It is published because:

[list]
[*]The script combines smooth value estimation with rail-based structure instead of using one method alone
[*]It focuses the cloud only on high-density accepted regions, preserving chart cleanliness
[*]The dashboard turns the density map into a practical location framework rather than a purely visual profile
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice and does not guarantee future market behavior. Value zones can shift as new data enters the sample, and persistent trends can stay outside accepted areas longer than expected. Always use independent judgment and proper risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Parallax Density Atlas [JOAT]", "PDA [JOAT]", overlay = true, max_bars_back = 1200, max_lines_count = 500, max_boxes_count = 500)

//--------------------------------------------------------------------------------------------------
// Intent
//--------------------------------------------------------------------------------------------------
// Parallax Density Atlas [JOAT]
// This overlay maps price acceptance using two complementary techniques:
// 1. kernel density estimation on recent closes,
// 2. percentile-guided value rails built from a sorted close sample.
//
// The indicator is designed to give a clean institutional view of:
// - the point of acceptance,
// - the current value area,
// - whether price is auctioning inside value or probing away from it.

//--------------------------------------------------------------------------------------------------
// Constants
//--------------------------------------------------------------------------------------------------
color VALUE_HIGH     = #0d9b79
color VALUE_LOW      = #d25b66
color VALUE_MID      = #d2a32d
color PROFILE_FADE   = #52647a
color PANEL_BG       = #11161d
color PANEL_BORDER   = #2a3340
color PANEL_TEXT     = #d7dee8
color PANEL_HEADER   = #8d99a7
color PANEL_DIM      = #556070
color VALUE_GLOW     = #53dfbf
color REJECT_GLOW    = #ff7e88

//--------------------------------------------------------------------------------------------------
// Helpers
//--------------------------------------------------------------------------------------------------
clampFloat(float value, float floorValue, float ceilingValue) =>
    math.max(floorValue, math.min(ceilingValue, value))

percentileFromSorted(array<float> sortedValues, float percentile) =>
    float result = na
    int sampleSize = array.size(sortedValues)
    if sampleSize > 0
        float location = (sampleSize - 1) * percentile / 100.0
        int lowerIndex = int(math.floor(location))
        int upperIndex = int(math.ceil(location))
        if lowerIndex == upperIndex
            result := array.get(sortedValues, lowerIndex)
        else
            float lowerValue = array.get(sortedValues, lowerIndex)
            float upperValue = array.get(sortedValues, upperIndex)
            result := lowerValue + (upperValue - lowerValue) * (location - lowerIndex)
    result

gaussianKernel(float distance) =>
    (1.0 / math.sqrt(2.0 * math.pi)) * math.exp(-0.5 * math.pow(distance, 2.0))

bandwidthFromPrices(array<float> prices, float multiplier) =>
    float sigma = array.stdev(prices)
    float n = array.size(prices)
    math.max(1e-6, 1.06 * sigma * math.pow(n, -0.2) * multiplier)

formatPrice(float priceValue) =>
    str.tostring(priceValue, format.mintick)

formatPct(float pctValue) =>
    str.tostring(pctValue, "0.0") + "%"

//--------------------------------------------------------------------------------------------------
// Inputs
//--------------------------------------------------------------------------------------------------
string ENGINE_GROUP       = "Density Engine"
int lookbackInput         = input.int(220, "Lookback", minval = 80, maxval = 800, group = ENGINE_GROUP)
int precisionInput        = input.int(44, "Density Steps", minval = 20, maxval = 120, group = ENGINE_GROUP)
float bandwidthInput      = input.float(1.0, "Bandwidth Multiplier", minval = 0.2, maxval = 4.0, step = 0.1, group = ENGINE_GROUP)
float valueAreaInput      = input.float(70.0, "Value Area Percent", minval = 50.0, maxval = 95.0, step = 1.0, group = ENGINE_GROUP)

string RAIL_GROUP         = "Value Rails"
float lowerRailInput      = input.float(20.0, "Lower Rail Percentile", minval = 1.0, maxval = 49.0, step = 0.5, group = RAIL_GROUP)
float upperRailInput      = input.float(80.0, "Upper Rail Percentile", minval = 51.0, maxval = 99.0, step = 0.5, group = RAIL_GROUP)
int railSmoothInput       = input.int(5, "Rail Smoothing", minval = 1, maxval = 20, group = RAIL_GROUP)

string VISUAL_GROUP       = "Visual System"
int profileWidthInput     = input.int(36, "Profile Width Bars", minval = 10, maxval = 100, group = VISUAL_GROUP)
float cloudThresholdInput = input.float(0.55, "Cloud Threshold", minval = 0.20, maxval = 0.95, step = 0.05, group = VISUAL_GROUP)
bool showCloudInput       = input.bool(true, "Show Density Cloud", group = VISUAL_GROUP)
bool showProfileInput     = input.bool(true, "Show Right Profile", group = VISUAL_GROUP)
bool tintCandlesInput     = input.bool(false, "Tint Candles", group = VISUAL_GROUP)
bool showDashboardInput   = input.bool(true, "Show Dashboard", group = VISUAL_GROUP)

//--------------------------------------------------------------------------------------------------
// Persistent Drawing Stores
//--------------------------------------------------------------------------------------------------
var line[] profileLines = array.new_line()
var box[] cloudBoxes = array.new_box()
var line pocLine = na
var line vahLine = na
var line valLine = na
var table dashboard = table.new(position.top_right, 2, 8, bgcolor = PANEL_BG, frame_color = PANEL_BORDER, frame_width = 1, border_width = 0)

//--------------------------------------------------------------------------------------------------
// Percentile Rails
//--------------------------------------------------------------------------------------------------
var array<float> closeSample = array.new_float()
if barstate.isnew
    array.push(closeSample, close)
    if array.size(closeSample) > lookbackInput
        array.shift(closeSample)

array<float> sortedCloses = array.copy(closeSample)
array.sort(sortedCloses, order.ascending)

float rawLowerRail = percentileFromSorted(sortedCloses, lowerRailInput)
float rawUpperRail = percentileFromSorted(sortedCloses, upperRailInput)
float lowerRail = ta.ema(rawLowerRail, railSmoothInput)
float upperRail = ta.ema(rawUpperRail, railSmoothInput)
float railMid = math.avg(lowerRail, upperRail)

//--------------------------------------------------------------------------------------------------
// KDE and Value Area
//--------------------------------------------------------------------------------------------------
float pocPrice = na
float valueHigh = na
float valueLow = na
float normalizedLocation = na
float valueSkew = na

if barstate.islast and array.size(closeSample) >= 20
    if array.size(profileLines) > 0
        for i = 0 to array.size(profileLines) - 1
            line.delete(array.get(profileLines, i))
    array.clear(profileLines)

    if array.size(cloudBoxes) > 0
        for i = 0 to array.size(cloudBoxes) - 1
            box.delete(array.get(cloudBoxes, i))
    array.clear(cloudBoxes)

    float priceMin = array.min(closeSample)
    float priceMax = array.max(closeSample)
    float priceRange = math.max(syminfo.mintick * 10.0, priceMax - priceMin)
    float step = priceRange / precisionInput
    float bandwidth = bandwidthFromPrices(closeSample, bandwidthInput)

    array<float> densities = array.new_float(precisionInput + 1, 0.0)
    float totalDensity = 0.0
    float maxDensity = 0.0
    int pocIndex = 0

    for stepIndex = 0 to precisionInput
        float evalPrice = priceMin + stepIndex * step
        float densitySum = 0.0
        for priceIndex = 0 to array.size(closeSample) - 1
            float samplePrice = array.get(closeSample, priceIndex)
            densitySum += gaussianKernel((evalPrice - samplePrice) / bandwidth)
        float densityValue = densitySum / (array.size(closeSample) * bandwidth)
        array.set(densities, stepIndex, densityValue)
        totalDensity += densityValue
        if densityValue > maxDensity
            maxDensity := densityValue
            pocIndex := stepIndex

    pocPrice := priceMin + pocIndex * step

    int leftIndex = pocIndex
    int rightIndex = pocIndex
    float capturedDensity = array.get(densities, pocIndex)
    float targetDensity = totalDensity * (valueAreaInput / 100.0)

    while capturedDensity < targetDensity and (leftIndex > 0 or rightIndex < precisionInput)
        float nextLeft = leftIndex > 0 ? array.get(densities, leftIndex - 1) : -1.0
        float nextRight = rightIndex < precisionInput ? array.get(densities, rightIndex + 1) : -1.0
        if nextLeft > nextRight
            leftIndex -= 1
            capturedDensity += array.get(densities, leftIndex)
        else
            rightIndex += 1
            capturedDensity += array.get(densities, rightIndex)

    valueLow := priceMin + leftIndex * step
    valueHigh := priceMin + rightIndex * step
    valueSkew := clampFloat((pocIndex - precisionInput * 0.5) / (precisionInput * 0.5), -1.0, 1.0) * 100.0
    normalizedLocation := clampFloat((close - valueLow) / math.max(syminfo.mintick, valueHigh - valueLow), 0.0, 1.0)

    if showProfileInput
        for stepIndex = 0 to precisionInput
            float rowPrice = priceMin + stepIndex * step
            float densityValue = array.get(densities, stepIndex)
            float densityRatio = maxDensity == 0.0 ? 0.0 : densityValue / maxDensity
            int rightBars = math.max(1, int(math.round(densityRatio * profileWidthInput)))
            color rowColor = color.from_gradient(densityRatio, 0.0, 1.0, color.new(VALUE_LOW, 40), color.new(VALUE_HIGH, 20))
            line densityLine = line.new(bar_index, rowPrice, bar_index + rightBars, rowPrice, color = rowColor, width = 2)
            array.push(profileLines, densityLine)

    if showCloudInput
        for stepIndex = 0 to precisionInput - 1
            float lowerEdge = priceMin + stepIndex * step
            float upperEdge = priceMin + (stepIndex + 1) * step
            float densityValue = array.get(densities, stepIndex)
            float densityRatio = maxDensity == 0.0 ? 0.0 : densityValue / maxDensity
            bool insideValue = lowerEdge >= valueLow and upperEdge <= valueHigh
            if densityRatio >= cloudThresholdInput and insideValue
                color zoneColor = color.from_gradient(densityRatio, cloudThresholdInput, 1.0, color.new(VALUE_MID, 84), color.new(VALUE_HIGH, 76))
                box areaBox = box.new(bar_index - lookbackInput + 1, upperEdge, bar_index, lowerEdge, bgcolor = zoneColor, border_color = na)
                array.push(cloudBoxes, areaBox)

    if not na(pocLine)
        line.delete(pocLine)
    if not na(vahLine)
        line.delete(vahLine)
    if not na(valLine)
        line.delete(valLine)

    pocLine := line.new(bar_index - lookbackInput + 1, pocPrice, bar_index + profileWidthInput, pocPrice, color = color.new(VALUE_MID, 0), width = 1, style = line.style_dashed)
    vahLine := line.new(bar_index - lookbackInput + 1, valueHigh, bar_index + profileWidthInput, valueHigh, color = color.new(VALUE_HIGH, 10), width = 1)
    valLine := line.new(bar_index - lookbackInput + 1, valueLow, bar_index + profileWidthInput, valueLow, color = color.new(VALUE_LOW, 10), width = 1)

//--------------------------------------------------------------------------------------------------
// Context Classification
//--------------------------------------------------------------------------------------------------
bool aboveValue = not na(valueHigh) and close > valueHigh
bool belowValue = not na(valueLow) and close < valueLow
bool insideValue = not na(valueHigh) and not na(valueLow) and close <= valueHigh and close >= valueLow

float railCompression = not na(lowerRail) and not na(upperRail) ? math.abs(upperRail - lowerRail) / close * 100.0 : na
float railBias = not na(upperRail) and not na(lowerRail) ? clampFloat((close - railMid) / math.max(syminfo.mintick, upperRail - lowerRail), -1.0, 1.0) : 0.0
color locationColor = aboveValue ? VALUE_HIGH : belowValue ? VALUE_LOW : VALUE_MID

barcolor(tintCandlesInput ? color.new(color.from_gradient(railBias, -1.0, 1.0, VALUE_LOW, VALUE_HIGH), 0) : na)

//--------------------------------------------------------------------------------------------------
// Overlay Plots
//--------------------------------------------------------------------------------------------------
plot(lowerRail, "Lower Value Rail", color = color.new(VALUE_LOW, 0), linewidth = 2)
plot(upperRail, "Upper Value Rail", color = color.new(VALUE_HIGH, 0), linewidth = 2)
plot(railMid, "Rail Midpoint", color = color.new(PROFILE_FADE, 35), linewidth = 1)

plotValueHigh = plot(valueHigh, "Value Area High", color = color.new(VALUE_HIGH, 35), linewidth = 1, style = plot.style_linebr)
plotValueLow = plot(valueLow, "Value Area Low", color = color.new(VALUE_LOW, 35), linewidth = 1, style = plot.style_linebr)
fill(plotValueHigh, plotValueLow, color = color.new(locationColor, 92), title = "Value Area Fill")

//--------------------------------------------------------------------------------------------------
// Dashboard
//--------------------------------------------------------------------------------------------------
dashboardCell(table panel, int row, string labelText, string valueText, color valueColor) =>
    panel.cell(0, row, labelText, text_color = PANEL_HEADER, text_size = size.normal, text_halign = text.align_left)
    panel.cell(1, row, valueText, text_color = valueColor, text_size = size.normal, text_halign = text.align_right)

dashboardDivider(table panel, int row) =>
    panel.merge_cells(0, row, 1, row)
    panel.cell(0, row, "--------------", text_color = PANEL_BORDER, text_size = size.normal, text_halign = text.align_center)

if barstate.islast
    if showDashboardInput
        string locationText = aboveValue ? "Expansion Above" : belowValue ? "Discount Below" : "Accepted Inside"
        string skewText = na(valueSkew) ? "N/A" : formatPct(valueSkew)
        string compressionText = na(railCompression) ? "N/A" : str.tostring(railCompression, "0.00") + "%"
        color skewColor = na(valueSkew) ? PANEL_DIM : valueSkew >= 0 ? VALUE_HIGH : VALUE_LOW

        color headerTone = color.new(locationColor, 84)
        table.cell(dashboard, 0, 0, "Parallax Atlas", text_color = PANEL_TEXT, bgcolor = headerTone, text_size = size.normal, text_halign = text.align_left)
        table.cell(dashboard, 1, 0, locationText, text_color = locationColor, bgcolor = headerTone, text_size = size.normal, text_halign = text.align_right)

        dashboardDivider(dashboard, 1)

        dashboardCell(dashboard, 2, "POC", na(pocPrice) ? "N/A" : formatPrice(pocPrice), VALUE_MID)
        dashboardCell(dashboard, 3, "Value High", na(valueHigh) ? "N/A" : formatPrice(valueHigh), VALUE_HIGH)
        dashboardCell(dashboard, 4, "Value Low", na(valueLow) ? "N/A" : formatPrice(valueLow), VALUE_LOW)

        dashboardDivider(dashboard, 5)

        dashboardCell(dashboard, 6, "Rail Width", compressionText, PROFILE_FADE)
        dashboardCell(dashboard, 7, "Skew", skewText, skewColor)
    else
        table.clear(dashboard, 0, 0, 1, 7)
````
