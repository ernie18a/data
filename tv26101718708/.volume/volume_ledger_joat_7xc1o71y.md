# Volume Ledger [JOAT]

- url: https://www.tradingview.com/script/7xc1o71y-Volume-Ledger-JOAT/
- type: indicator
- pine_id: PUB;041590693e834940a4e233df3aa8d70e
- version: 1.0

## Description

[b]JOAT Volume Ledger [JOAT][/b]

[b]Introduction[/b]

JOAT Volume Ledger is an open-source participation and volume-zone framework designed to identify where meaningful activity occurred, what type of activity it likely was, and which of those zones still matter now.

It is built around the idea that not all large volume is equal.

Some high-volume behavior represents sponsorship.

Some represents exhaustion.

Some represents churn or absorption.

Some leaves behind a meaningful footprint that the market later reacts to.

The problem the script solves is translation.

Raw volume bars alone do not explain whether heavy activity created useful levels.

They also do not organize those levels for later use.

Volume Ledger attempts to do both.

It begins with relative-volume heat and participation metrics.

It then uses confirmed pivot-based logic to create candidate zones.

Those zones are merged, ranked, extended, and reclassified as support or resistance based on how price returns to them.

Higher-timeframe carry-forward levels can also be displayed.

[image]https://www.tradingview.com/x/a91Nlri8/[/image]

[b]Core Concepts[/b]

[b]1. Relative-Volume Heat[/b]

The script normalizes current volume against a baseline and color-grades it.

[b]2. Delta, Churn, and Participation[/b]

A delta proxy, churn estimate, and participation line classify the quality of activity.

[b]3. Confirmed Pivot-Zone Creation[/b]

When significant participation coincides with confirmed pivots, the script stores those prices as candidate zones.

[b]4. Zone Merging and Ranking[/b]

Nearby zones are merged and stronger zones are prioritized.

[b]5. Higher-Timeframe Carry-Forward Levels[/b]

Important HTF zones can be projected into the current chart.

[b]6. Retest Logic[/b]

The script distinguishes whether an active zone is currently acting as support or resistance.

[b]7. Overlay Box and Line Projection[/b]

Zones are projected forward into current chart space using managed boxes, lines, and labels.

[b]8. Participation State Readout[/b]

The dashboard summarizes the dominant volume condition, active zones, and current participation quality.


[b]Features[/b]

[list]
[*][b]Relative-volume heatmap:[/b] current activity is normalized and color-graded
[*][b]Delta, churn, sigma, and participation analytics:[/b] classifies the character of activity
[*][b]Confirmed volume-origin zones:[/b] maps price areas linked to meaningful participation
[*][b]Zone merging and ranking:[/b] reduces clutter and prioritizes stronger regions
[*][b]Projected overlay boxes and lines:[/b] extends active zones into current price
[*][b]Higher-timeframe ledger context:[/b] broader levels can be carried forward
[*][b]Support / resistance retest logic:[/b] distinguishes how price is interacting with the zone
[*][b]Bar tint and backdrop state:[/b] strong participation conditions are easy to spot
[*][b]Dashboard:[/b] summarizes volume state and dominant zone structure
[/list]

[b]Input Parameters[/b]

[b]Ledger Core:[/b]

[list]
[*]Volume Comparison
[*]Ledger Window
[*]Participation Smoothing
[*]Delta and Churn Settings
[*]Relative Volume Thresholds
[/list]

[b]Zone Engine / Display:[/b]

[list]
[*]Zone Extension
[*]Merge Threshold
[*]Zone Ranking Rules
[*]Projected Levels
[*]Higher-Timeframe Carry-Forward
[*]Show Dashboard
[*]Show Average
[*]Show Participation Line
[*]Show Projected Levels
[*]Show Backdrop
[*]Show Bar Tint
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1:[/b] Read current participation quality using the relative-volume state and participation line.

[b]Step 2:[/b] Identify the dominant projected zones on the chart.

[b]Step 3:[/b] Watch retests into those zones and compare them to current participation behavior.

[b]Step 4:[/b] Compare active zones with higher-timeframe carry-forward levels.

[b]Step 5:[/b] Use the script as confirmation beneath trend, liquidity, or retracement narratives.

[b]Indicator Limitations[/b]

[list]
[*]Volume proxies do not provide true exchange-level order-flow
[*]High participation does not guarantee reversal or continuation
[*]Very noisy markets can generate many candidate zones before merging and ranking simplify them
[*]The script identifies footprints of activity, not certain turning points
[/list]

[b]Originality Statement[/b]

This script is original in the way it combines relative-volume heat, effort classification, pivot-zone construction, merging, ranking, higher-timeframe carry-forward, and retest-aware styling into a single participation ledger.

The purpose is not merely to show volume.

It is to preserve the most useful consequences of volume.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only.

It is not financial advice.

Volume and participation footprints do not guarantee future support or resistance.

Always use independent analysis and risk management.

[b]Best Use Cases[/b]

[list]
[*]Studying where strong participation likely left a usable footprint
[*]Comparing current price retests to historical participation zones
[*]Separating constructive activity from churn-heavy activity
[*]Adding participation context to trend, liquidity, or retracement narratives
[/list]

[b]Interpretation Notes[/b]

Not every high-volume event deserves the same weight.

The script is most useful when strong participation aligns with structural pivots and later retests.

Higher-timeframe carry-forward levels can be especially helpful when local price is approaching an older but still meaningful participation zone.

The strongest zones are not simply the largest bars.

They are the most meaningful surviving footprints after merging, ranking, and retest context are applied.

[b]Publication Notes[/b]

This script is intended to be published with a clean chart where the dominant projected zones and the current participation state are clearly identifiable.

The chart should not be overloaded with extra unrelated studies.

The image should make the volume-to-zone relationship understandable to a first-time viewer.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Volume Ledger [JOAT]", shorttitle = "JVL [JOAT]", overlay = false, max_boxes_count = 180, max_lines_count = 220, max_labels_count = 120, max_bars_back = 5000)

string groupLedger = "Ledger Engine"
string groupZones = "Zone Engine"
string groupHigherTimeframe = "Higher Timeframe"
string groupDisplay = "Display"
string groupPalette = "Palette"

int baselineLength = input.int(34, "Baseline Length", minval = 5, group = groupLedger)
int normalizationLength = input.int(120, "Normalization Length", minval = 30, group = groupLedger)
int sigmaLength = input.int(34, "Sigma Length", minval = 5, group = groupLedger)
float ultraRelativeVolume = input.float(1.8, "Ultra Relative Volume", minval = 1.0, step = 0.05, group = groupLedger)
float climaxDeltaThreshold = input.float(1.0, "Climax Delta Threshold", minval = 0.1, step = 0.1, group = groupLedger)
float churnThreshold = input.float(0.85, "Churn Threshold", minval = 0.1, step = 0.05, group = groupLedger)
int participationSmoothing = input.int(5, "Participation Smoothing", minval = 1, group = groupLedger)

int pivotLength = input.int(3, "Pivot Length", minval = 2, group = groupZones)
int profileBars = input.int(300, "Active Profile Window", minval = 50, group = groupZones)
int maxStoredZones = input.int(28, "Max Stored Zones", minval = 5, maxval = 60, group = groupZones)
int maxRenderedZones = input.int(6, "Max Rendered Zones", minval = 2, maxval = 12, group = groupZones)
float zoneAtrFactor = input.float(0.45, "Zone Width ATR", minval = 0.05, step = 0.05, group = groupZones)
float mergeThreshold = input.float(0.35, "Merge Threshold %", minval = 0.05, step = 0.05, group = groupZones) * 0.01
int zoneExtensionBars = input.int(70, "Zone Extension Bars", minval = 5, group = groupZones)
bool showZoneLabels = input.bool(true, "Show Zone Labels", group = groupZones)

bool showHigherTimeframe = input.bool(true, "Show Higher Timeframe Levels", group = groupHigherTimeframe)
string higherTimeframe = input.timeframe("240", "Higher Timeframe", group = groupHigherTimeframe)
float higherTimeframeMultiplier = input.float(1.5, "HTF Relative Volume", minval = 1.0, step = 0.05, group = groupHigherTimeframe)
int maxHigherTimeframeZones = input.int(3, "Max HTF Zones", minval = 1, maxval = 6, group = groupHigherTimeframe)

bool showDashboard = input.bool(true, "Show Dashboard", group = groupDisplay)
bool showAverage = input.bool(true, "Show Baselines", group = groupDisplay)
bool showParticipationLine = input.bool(true, "Show Participation Line", group = groupDisplay)
bool showBarTint = input.bool(true, "Tint Price Bars", group = groupDisplay)
bool showBackdrop = input.bool(true, "Shade Regimes", group = groupDisplay)

color coldColor = input.color(color.rgb(10, 34, 82), "Cold", group = groupPalette)
color warmColor = input.color(color.rgb(16, 118, 165), "Warm", group = groupPalette)
color hotColor = input.color(color.rgb(44, 194, 150), "Hot", group = groupPalette)
color extremeColor = input.color(color.rgb(226, 167, 67), "Extreme", group = groupPalette)
color supportColor = input.color(color.rgb(44, 195, 154), "Support", group = groupPalette)
color resistanceColor = input.color(color.rgb(214, 88, 118), "Resistance", group = groupPalette)
color insideColor = input.color(color.rgb(96, 148, 230), "Inside", group = groupPalette)
color higherTimeframeColor = input.color(color.rgb(158, 118, 237), "HTF", group = groupPalette)
color neutralColor = input.color(color.rgb(122, 136, 163), "Neutral", group = groupPalette)
color panelBackground = input.color(color.rgb(12, 17, 28), "Dashboard Background", group = groupPalette)
color panelBorder = input.color(color.rgb(42, 54, 76), "Dashboard Border", group = groupPalette)

clampFloat(float value, float lowValue, float highValue) =>
    math.max(lowValue, math.min(highValue, value))

lerpColor(color colorA, color colorB, float weight) =>
    float t = clampFloat(weight, 0.0, 1.0)
    color.rgb(
         int(color.r(colorA) + (color.r(colorB) - color.r(colorA)) * t),
         int(color.g(colorA) + (color.g(colorB) - color.g(colorA)) * t),
         int(color.b(colorA) + (color.b(colorB) - color.b(colorA)) * t))

heatColor(float intensity) =>
    float clipped = clampFloat(intensity, 0.0, 1.0)
    clipped < 0.25 ? lerpColor(coldColor, warmColor, clipped / 0.25) : clipped < 0.55 ? lerpColor(warmColor, hotColor, (clipped - 0.25) / 0.30) : clipped < 0.80 ? lerpColor(hotColor, extremeColor, (clipped - 0.55) / 0.25) : lerpColor(extremeColor, resistanceColor, (clipped - 0.80) / 0.20)

formatVolume(float value) =>
    value >= 1000000000 ? str.tostring(value / 1000000000.0, "#.##") + "B" : value >= 1000000 ? str.tostring(value / 1000000.0, "#.##") + "M" : value >= 1000 ? str.tostring(value / 1000.0, "#.##") + "K" : str.tostring(value, "#")

zScore(float source, int length) =>
    float basis = ta.sma(source, length)
    float deviation = ta.stdev(source, length)
    deviation > 0 ? (source - basis) / deviation : 0.0

registerZone(array<float> mids, array<float> tops, array<float> bottoms, array<float> scores, array<int> bornTimes, array<int> biases, float price, float width, float score, int bornTime, int bias, float mergePercent) =>
    bool merged = false
    int size = array.size(mids)
    if size > 0
        for idx = 0 to size - 1
            float currentMid = array.get(mids, idx)
            float distance = currentMid != 0 ? math.abs(price - currentMid) / math.abs(currentMid) : 0.0
            if distance <= mergePercent
                float topValue = math.max(array.get(tops, idx), price + width)
                float bottomValue = math.min(array.get(bottoms, idx), price - width)
                int mergedBias = array.get(biases, idx) == bias ? bias : 0
                array.set(tops, idx, topValue)
                array.set(bottoms, idx, bottomValue)
                array.set(mids, idx, (topValue + bottomValue) * 0.5)
                array.set(scores, idx, math.max(array.get(scores, idx), score))
                array.set(bornTimes, idx, math.min(array.get(bornTimes, idx), bornTime))
                array.set(biases, idx, mergedBias)
                merged := true
                break
    if not merged
        array.push(mids, price)
        array.push(tops, price + width)
        array.push(bottoms, price - width)
        array.push(scores, score)
        array.push(bornTimes, bornTime)
        array.push(biases, bias)

selectCandidate(array<int> selectedIndices, array<float> selectedScores, int candidateIndex, float metric, int limit) =>
    if array.size(selectedIndices) < limit
        array.push(selectedIndices, candidateIndex)
        array.push(selectedScores, metric)
    else
        int worstPosition = 0
        float worstMetric = array.get(selectedScores, 0)
        for idx = 1 to array.size(selectedScores) - 1
            float currentMetric = array.get(selectedScores, idx)
            if currentMetric < worstMetric
                worstMetric := currentMetric
                worstPosition := idx
        if metric > worstMetric
            array.set(selectedIndices, worstPosition, candidateIndex)
            array.set(selectedScores, worstPosition, metric)

clearDrawings(array<box> boxes, array<line> lines, array<label> labels) =>
    int boxCount = array.size(boxes)
    if boxCount > 0
        for idx = boxCount - 1 to 0
            box.delete(array.get(boxes, idx))
        array.clear(boxes)
    int lineCount = array.size(lines)
    if lineCount > 0
        for idx = lineCount - 1 to 0
            line.delete(array.get(lines, idx))
        array.clear(lines)
    int labelCount = array.size(labels)
    if labelCount > 0
        for idx = labelCount - 1 to 0
            label.delete(array.get(labels, idx))
        array.clear(labels)

float averageVolume = ta.sma(volume, baselineLength)
float relativeVolume = averageVolume > 0 ? volume / averageVolume : 1.0
float volumeZ = zScore(volume, normalizationLength)
float barRange = math.max(high - low, syminfo.mintick)
float deltaProxy = volume * ((close - open) / barRange)
float deltaZ = zScore(deltaProxy, normalizationLength)
float spreadAverage = ta.sma(barRange, baselineLength)
float resultEfficiency = spreadAverage > 0 ? barRange / spreadAverage : 1.0
float effortResult = relativeVolume > 0 ? resultEfficiency / relativeVolume : 0.0
float churnRatio = resultEfficiency > 0 ? relativeVolume / resultEfficiency : relativeVolume
float churnZ = zScore(churnRatio, normalizationLength)
float volumeReturn = volume > 0 and volume[1] > 0 ? math.log(volume / volume[1]) : 0.0
float sigmaValue = math.sqrt(math.max(ta.ema(volumeReturn * volumeReturn, sigmaLength), 0.0))
float sigmaZ = zScore(sigmaValue, normalizationLength)
float participationRaw = deltaZ * 0.50 + (relativeVolume - 1.0) * 0.35 - churnZ * 0.15
float participationLine = ta.ema(participationRaw, participationSmoothing)

bool bullishParticipation = barstate.isconfirmed and relativeVolume > ultraRelativeVolume and deltaZ > climaxDeltaThreshold and participationLine > 0
bool bearishParticipation = barstate.isconfirmed and relativeVolume > ultraRelativeVolume and deltaZ < -climaxDeltaThreshold and participationLine < 0
bool churnState = barstate.isconfirmed and relativeVolume > ultraRelativeVolume and effortResult < churnThreshold
bool absorptionBid = barstate.isconfirmed and churnState and deltaZ > 0
bool absorptionOffer = barstate.isconfirmed and churnState and deltaZ < 0

float atrValue = ta.atr(14)
float normalizedVolume = relativeVolume
float ultraLine = ultraRelativeVolume
color columnColor = heatColor(clampFloat((relativeVolume - 0.3) / math.max(ultraRelativeVolume, 1.0), 0.0, 1.0))
color participationColor = participationLine >= 0 ? supportColor : resistanceColor
color stateBackdrop = bullishParticipation ? color.new(supportColor, 90) : bearishParticipation ? color.new(resistanceColor, 90) : absorptionBid ? color.new(supportColor, 94) : absorptionOffer ? color.new(resistanceColor, 94) : na
color barTint = bullishParticipation ? color.new(supportColor, 0) : bearishParticipation ? color.new(resistanceColor, 0) : absorptionBid ? color.new(supportColor, 25) : absorptionOffer ? color.new(resistanceColor, 25) : na

bgcolor(showBackdrop ? stateBackdrop : na)
barcolor(showBarTint ? barTint : na)

plot(normalizedVolume, "Relative Volume", color = color.new(columnColor, 10), style = plot.style_columns, linewidth = 3)
plot(showAverage ? 1.0 : na, "Baseline", color = color.new(neutralColor, 15), linewidth = 2)
plot(showAverage ? ultraLine : na, "Ultra Threshold", color = color.new(color.rgb(226, 196, 101), 0), linewidth = 2)
plot(deltaZ, "Delta Z", color = deltaZ >= 0 ? color.new(supportColor, 0) : color.new(resistanceColor, 0), linewidth = 2)
plot(churnZ, "Churn Z", color = color.new(neutralColor, 0), linewidth = 2)
plot(showParticipationLine ? participationLine : na, "Participation", color = color.new(participationColor, 0), linewidth = 3)
hline(0.0, "Zero", color = color.new(neutralColor, 55))
hline(1.0, "Positive Threshold", color = color.new(supportColor, 82))
hline(-1.0, "Negative Threshold", color = color.new(resistanceColor, 82))

var array<float> storedZonePrice = array.new_float()
var array<float> storedZoneWidth = array.new_float()
var array<float> storedZoneScore = array.new_float()
var array<int> storedZoneBias = array.new_int()
var array<int> storedZoneBar = array.new_int()
var array<int> storedZoneTime = array.new_int()

var array<float> higherTimeframeTop = array.new_float()
var array<float> higherTimeframeBottom = array.new_float()
var array<float> higherTimeframeScore = array.new_float()
var array<int> higherTimeframeTime = array.new_int()
var array<int> higherTimeframeBias = array.new_int()

var array<box> drawnBoxes = array.new_box()
var array<line> drawnLines = array.new_line()
var array<label> drawnLabels = array.new_label()

float pivotVolume = ta.pivothigh(volume, pivotLength, pivotLength)
if not na(pivotVolume) and barstate.isconfirmed
    float frozenRelativeVolume = relativeVolume[pivotLength]
    float frozenDelta = deltaZ[pivotLength]
    float frozenSigma = sigmaZ[pivotLength]
    float frozenAtr = atrValue[pivotLength]
    bool qualifiedPivot = frozenRelativeVolume > ultraRelativeVolume * 0.85 or math.abs(frozenDelta) > 0.9 or frozenSigma > 0.75
    if qualifiedPivot
        float pivotPrice = hlc3[pivotLength]
        float zoneWidth = math.max(frozenAtr * zoneAtrFactor, syminfo.mintick * 8.0)
        float zoneScore = math.max(frozenRelativeVolume, 1.0) + math.abs(frozenDelta) * 0.70 + math.max(frozenSigma, 0.0) * 0.45
        int zoneBias = frozenDelta >= 0 ? 1 : -1
        array.push(storedZonePrice, pivotPrice)
        array.push(storedZoneWidth, zoneWidth)
        array.push(storedZoneScore, zoneScore)
        array.push(storedZoneBias, zoneBias)
        array.push(storedZoneBar, bar_index - pivotLength)
        array.push(storedZoneTime, time[pivotLength])
        while array.size(storedZonePrice) > maxStoredZones
            array.shift(storedZonePrice)
            array.shift(storedZoneWidth)
            array.shift(storedZoneScore)
            array.shift(storedZoneBias)
            array.shift(storedZoneBar)
            array.shift(storedZoneTime)

[htfVolume, htfHigh, htfLow, htfOpen, htfClose, htfTime, htfAverageVolume] = request.security(syminfo.tickerid, higherTimeframe, [volume[1], high[1], low[1], open[1], close[1], time[1], ta.sma(volume, baselineLength)[1]], lookahead = barmerge.lookahead_on)
bool newHigherTimeframeBar = showHigherTimeframe and not na(htfTime) and (na(htfTime[1]) or htfTime != htfTime[1])
float htfRelativeVolume = htfAverageVolume > 0 ? htfVolume / htfAverageVolume : na
if newHigherTimeframeBar and not na(htfRelativeVolume) and htfRelativeVolume > higherTimeframeMultiplier
    array.push(higherTimeframeTop, htfHigh)
    array.push(higherTimeframeBottom, htfLow)
    array.push(higherTimeframeScore, htfRelativeVolume)
    array.push(higherTimeframeTime, htfTime)
    array.push(higherTimeframeBias, htfClose >= htfOpen ? 1 : -1)
    while array.size(higherTimeframeTop) > maxHigherTimeframeZones
        array.shift(higherTimeframeTop)
        array.shift(higherTimeframeBottom)
        array.shift(higherTimeframeScore)
        array.shift(higherTimeframeTime)
        array.shift(higherTimeframeBias)

float activeSupportMid = na
float activeSupportTop = na
float activeResistanceMid = na
float activeResistanceBottom = na
float supportBestScore = -1.0
float resistanceBestScore = -1.0

int storedCount = array.size(storedZonePrice)
if storedCount > 0
    for idx = 0 to storedCount - 1
        int bornBar = array.get(storedZoneBar, idx)
        if bar_index - bornBar <= profileBars
            float zonePrice = array.get(storedZonePrice, idx)
            float zoneWidth = array.get(storedZoneWidth, idx)
            float zoneScore = array.get(storedZoneScore, idx)
            float zoneTop = zonePrice + zoneWidth
            float zoneBottom = zonePrice - zoneWidth
            if zoneTop < close and zoneScore > supportBestScore
                supportBestScore := zoneScore
                activeSupportMid := zonePrice
                activeSupportTop := zoneTop
            if zoneBottom > close and zoneScore > resistanceBestScore
                resistanceBestScore := zoneScore
                activeResistanceMid := zonePrice
                activeResistanceBottom := zoneBottom

bool supportRetest = barstate.isconfirmed and not na(activeSupportTop) and low <= activeSupportTop and close >= activeSupportMid
bool resistanceRetest = barstate.isconfirmed and not na(activeResistanceBottom) and high >= activeResistanceBottom and close <= activeResistanceMid

if barstate.islast
    clearDrawings(drawnBoxes, drawnLines, drawnLabels)

    array<float> candidateMids = array.new_float()
    array<float> candidateTops = array.new_float()
    array<float> candidateBottoms = array.new_float()
    array<float> candidateScores = array.new_float()
    array<int> candidateTimes = array.new_int()
    array<int> candidateBiases = array.new_int()

    if storedCount > 0
        for idx = 0 to storedCount - 1
            int bornBar = array.get(storedZoneBar, idx)
            if bar_index - bornBar <= profileBars
                float zonePrice = array.get(storedZonePrice, idx)
                float zoneWidth = array.get(storedZoneWidth, idx)
                float zoneScore = array.get(storedZoneScore, idx)
                int bornTime = array.get(storedZoneTime, idx)
                int zoneBias = array.get(storedZoneBias, idx)
                registerZone(candidateMids, candidateTops, candidateBottoms, candidateScores, candidateTimes, candidateBiases, zonePrice, zoneWidth, zoneScore, bornTime, zoneBias, mergeThreshold)

    array<int> selectedIndices = array.new_int()
    array<float> selectedMetrics = array.new_float()
    int candidateCount = array.size(candidateMids)
    if candidateCount > 0
        for idx = 0 to candidateCount - 1
            float zoneMid = array.get(candidateMids, idx)
            float zoneScore = array.get(candidateScores, idx)
            float distanceAtr = atrValue > 0 ? math.abs(zoneMid - close) / atrValue : math.abs(zoneMid - close)
            float selectionMetric = zoneScore / (1.0 + distanceAtr)
            selectCandidate(selectedIndices, selectedMetrics, idx, selectionMetric, maxRenderedZones)

    int chartMilliseconds = timeframe.in_seconds(timeframe.period) > 0 ? int(timeframe.in_seconds(timeframe.period) * 1000) : 60000
    int rightEdge = time + chartMilliseconds * zoneExtensionBars

    int selectedCount = array.size(selectedIndices)
    if selectedCount > 0
        for slot = 0 to selectedCount - 1
            int candidateIndex = array.get(selectedIndices, slot)
            float zoneTop = array.get(candidateTops, candidateIndex)
            float zoneBottom = array.get(candidateBottoms, candidateIndex)
            float zoneMid = array.get(candidateMids, candidateIndex)
            float zoneScore = array.get(candidateScores, candidateIndex)
            int bornTime = array.get(candidateTimes, candidateIndex)
            bool supportNow = zoneTop < close
            bool resistanceNow = zoneBottom > close
            color zoneColor = supportNow ? supportColor : resistanceNow ? resistanceColor : insideColor
            float strength = clampFloat(zoneScore / (ultraRelativeVolume + 2.0), 0.20, 1.0)
            int fillTransparency = 84 - int(strength * 38.0)
            box zoneBox = box.new(left = bornTime, top = zoneTop, right = rightEdge, bottom = zoneBottom, xloc = xloc.bar_time, border_color = color.new(zoneColor, 0), border_width = supportNow or resistanceNow ? 1 : 2, bgcolor = color.new(zoneColor, fillTransparency), force_overlay = true)
            line zoneLine = line.new(x1 = bornTime, y1 = zoneMid, x2 = rightEdge, y2 = zoneMid, xloc = xloc.bar_time, color = color.new(zoneColor, 15), width = 2, style = supportNow or resistanceNow ? line.style_solid : line.style_dashed, force_overlay = true)
            array.push(drawnBoxes, zoneBox)
            array.push(drawnLines, zoneLine)
            if showZoneLabels
                string zoneText = supportNow ? "Support Ledger" : resistanceNow ? "Resistance Ledger" : "Active Ledger"
                label zoneLabel = label.new(rightEdge, zoneMid, zoneText, xloc = xloc.bar_time, yloc = yloc.price, style = label.style_label_left, color = color.new(panelBackground, 0), textcolor = zoneColor, size = size.small, force_overlay = true)
                array.push(drawnLabels, zoneLabel)

    if showHigherTimeframe
        int higherTimeframeCount = array.size(higherTimeframeTop)
        if higherTimeframeCount > 0
            for idx = 0 to higherTimeframeCount - 1
                float htfTopLevel = array.get(higherTimeframeTop, idx)
                float htfBottomLevel = array.get(higherTimeframeBottom, idx)
                int htfBornTime = array.get(higherTimeframeTime, idx)
                line htfTopLine = line.new(x1 = htfBornTime, y1 = htfTopLevel, x2 = rightEdge, y2 = htfTopLevel, xloc = xloc.bar_time, color = color.new(higherTimeframeColor, 0), width = 2, style = line.style_dashed, force_overlay = true)
                line htfBottomLine = line.new(x1 = htfBornTime, y1 = htfBottomLevel, x2 = rightEdge, y2 = htfBottomLevel, xloc = xloc.bar_time, color = color.new(higherTimeframeColor, 0), width = 2, style = line.style_dashed, force_overlay = true)
                array.push(drawnLines, htfTopLine)
                array.push(drawnLines, htfBottomLine)
                if showZoneLabels
                    label htfLabel = label.new(rightEdge, (htfTopLevel + htfBottomLevel) * 0.5, "HTF Ledger", xloc = xloc.bar_time, yloc = yloc.price, style = label.style_label_left, color = color.new(panelBackground, 0), textcolor = higherTimeframeColor, size = size.small, force_overlay = true)
                    array.push(drawnLabels, htfLabel)

string ledgerState = bullishParticipation ? "Bid Climax" : bearishParticipation ? "Offer Climax" : absorptionBid ? "Bid Absorption" : absorptionOffer ? "Offer Absorption" : churnState ? "Churn" : participationLine > 0 ? "Constructive" : participationLine < 0 ? "Defensive" : "Neutral"
color ledgerStateColor = bullishParticipation ? supportColor : bearishParticipation ? resistanceColor : absorptionBid ? supportColor : absorptionOffer ? resistanceColor : churnState ? color.rgb(226, 196, 101) : participationLine > 0 ? supportColor : participationLine < 0 ? resistanceColor : neutralColor

var table dashboard = table.new(position.top_right, 3, 10, bgcolor = color.new(panelBackground, 8), frame_color = panelBorder, frame_width = 1, border_color = panelBorder, border_width = 1)

if barstate.islast
    if showDashboard
        table.cell(dashboard, 0, 0, "Ledger", text_color = color.rgb(160, 174, 198), bgcolor = color.new(panelBackground, 0), text_size = size.small)
        table.cell(dashboard, 1, 0, "Value", text_color = color.rgb(160, 174, 198), bgcolor = color.new(panelBackground, 0), text_size = size.small)
        table.cell(dashboard, 2, 0, "Context", text_color = color.rgb(160, 174, 198), bgcolor = color.new(panelBackground, 0), text_size = size.small)

        table.cell(dashboard, 0, 1, "State", text_color = color.white, text_size = size.small)
        table.cell(dashboard, 1, 1, ledgerState, text_color = ledgerStateColor, text_size = size.small)
        table.cell(dashboard, 2, 1, formatVolume(volume), text_color = columnColor, text_size = size.small)

        table.cell(dashboard, 0, 2, "RVOL", text_color = color.white, text_size = size.small)
        table.cell(dashboard, 1, 2, str.tostring(relativeVolume, "#.00"), text_color = columnColor, text_size = size.small)
        table.cell(dashboard, 2, 2, relativeVolume > ultraRelativeVolume ? "Elevated" : "Balanced", text_color = relativeVolume > ultraRelativeVolume ? color.rgb(226, 196, 101) : neutralColor, text_size = size.small)

        table.cell(dashboard, 0, 3, "Delta Z", text_color = color.white, text_size = size.small)
        table.cell(dashboard, 1, 3, str.tostring(deltaZ, "#.00"), text_color = deltaZ >= 0 ? supportColor : resistanceColor, text_size = size.small)
        table.cell(dashboard, 2, 3, deltaZ > 0 ? "Bid Lift" : deltaZ < 0 ? "Offer Lift" : "Flat", text_color = deltaZ >= 0 ? supportColor : resistanceColor, text_size = size.small)

        table.cell(dashboard, 0, 4, "Sigma Z", text_color = color.white, text_size = size.small)
        table.cell(dashboard, 1, 4, str.tostring(sigmaZ, "#.00"), text_color = sigmaZ > 0 ? color.rgb(226, 196, 101) : neutralColor, text_size = size.small)
        table.cell(dashboard, 2, 4, sigmaZ > 0.75 ? "Expanding" : sigmaZ < -0.75 ? "Compressing" : "Stable", text_color = sigmaZ > 0.75 ? color.rgb(226, 196, 101) : neutralColor, text_size = size.small)

        table.cell(dashboard, 0, 5, "Churn", text_color = color.white, text_size = size.small)
        table.cell(dashboard, 1, 5, str.tostring(churnZ, "#.00"), text_color = churnState ? color.rgb(226, 196, 101) : neutralColor, text_size = size.small)
        table.cell(dashboard, 2, 5, churnState ? "Absorption Risk" : "Clean", text_color = churnState ? color.rgb(226, 196, 101) : neutralColor, text_size = size.small)

        table.cell(dashboard, 0, 6, "Participation", text_color = color.white, text_size = size.small)
        table.cell(dashboard, 1, 6, str.tostring(participationLine, "#.00"), text_color = participationColor, text_size = size.small)
        table.cell(dashboard, 2, 6, participationLine > 0 ? "Constructive" : participationLine < 0 ? "Defensive" : "Flat", text_color = participationColor, text_size = size.small)

        table.cell(dashboard, 0, 7, "Support", text_color = color.white, text_size = size.small)
        table.cell(dashboard, 1, 7, na(activeSupportMid) ? "na" : str.tostring(activeSupportMid, format.mintick), text_color = supportColor, text_size = size.small)
        table.cell(dashboard, 2, 7, supportRetest ? "Retest" : "Standby", text_color = supportRetest ? supportColor : neutralColor, text_size = size.small)

        table.cell(dashboard, 0, 8, "Resistance", text_color = color.white, text_size = size.small)
        table.cell(dashboard, 1, 8, na(activeResistanceMid) ? "na" : str.tostring(activeResistanceMid, format.mintick), text_color = resistanceColor, text_size = size.small)
        table.cell(dashboard, 2, 8, resistanceRetest ? "Retest" : "Standby", text_color = resistanceRetest ? resistanceColor : neutralColor, text_size = size.small)

        table.cell(dashboard, 0, 9, higherTimeframe, text_color = color.white, text_size = size.small)
        table.cell(dashboard, 1, 9, showHigherTimeframe and not na(htfRelativeVolume) ? str.tostring(htfRelativeVolume, "#.00") : "off", text_color = showHigherTimeframe ? higherTimeframeColor : neutralColor, text_size = size.small)
        table.cell(dashboard, 2, 9, showHigherTimeframe and array.size(higherTimeframeTop) > 0 ? "Active Zones" : "Idle", text_color = showHigherTimeframe and array.size(higherTimeframeTop) > 0 ? higherTimeframeColor : neutralColor, text_size = size.small)
    else
        table.clear(dashboard, 0, 0, 2, 9)

alertcondition(bullishParticipation, "Bullish Participation", "Volume Ledger bullish participation on {{ticker}}")
alertcondition(bearishParticipation, "Bearish Participation", "Volume Ledger bearish participation on {{ticker}}")
alertcondition(absorptionBid, "Bid Absorption", "Volume Ledger bid absorption on {{ticker}}")
alertcondition(absorptionOffer, "Offer Absorption", "Volume Ledger offer absorption on {{ticker}}")
alertcondition(supportRetest, "Support Retest", "Volume Ledger support retest on {{ticker}}")
alertcondition(resistanceRetest, "Resistance Retest", "Volume Ledger resistance retest on {{ticker}}")
````
