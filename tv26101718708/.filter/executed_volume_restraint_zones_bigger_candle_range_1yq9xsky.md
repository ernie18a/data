# Executed Volume Restraint Zones - Bigger Candle Range

- url: https://www.tradingview.com/script/1Yq9xsKy-Executed-Volume-Restraint-Zones-Bigger-Candle-Range/
- type: indicator
- pine_id: PUB;e091dd2f52b649b680acb554597efda1
- version: 19.0

## Description

Executed Volume Restraint Zones

This indicator detects potential buy and sell restraint zones using actual traded volume, candle rejection, wick behavior, and ATR-based zone sizing.

It does not use pending order book data. Instead, it focuses only on executed market activity shown through chart volume.

How it works:

A SELL zone is created when a high-volume candle pushes upward but gets rejected with a strong upper wick. This may suggest sellers absorbed buying pressure and stopped price from moving higher.

A BUY zone is created when a high-volume candle pushes downward but gets rejected with a strong lower wick. This may suggest buyers absorbed selling pressure and stopped price from moving lower.

The indicator compares current candle volume against a moving average volume baseline. By default, it uses 200 candles to define normal volume. When volume is significantly higher than average and the candle shows rejection, a zone is drawn.

Label meaning:

V = volume of the candle that created the zone.
T = estimated volume traded inside the zone during later retests.
# = how many times price has touched/retested the zone.
STRONG = the zone has been touched enough times based on the user setting.

Main features:

- Detects buy and sell executed-volume restraint zones
- Uses high-volume rejection candles
- Uses ATR to control zone thickness
- Tracks future zone retests
- Estimates volume traded inside each zone
- Marks stronger zones after repeated touches
- Auto-removes invalidated zones
- Multi-column adaptive labels to reduce chart overlap
- Adjustable volume, ATR, wick, body, label, and zone settings

Best used on intraday charts such as 5m, 15m, 30m, and 1h.

Important note:

This indicator does not show real order book or hidden limit orders. TradingView Pine Script cannot access live Level 2 / DOM order book data. The zones are based only on executed volume from OHLCV candles.

## Source Code

````pine
//@version=6
indicator("Executed Volume Restraint Zones - 6M Top 10 VP Score Bands", overlay=true, max_lines_count=500, max_labels_count=300)

// ==========================
// Inputs
// ==========================
volLen = input.int(200, "Volume MA Length", minval=20)
volMultiplier = input.float(1.8, "High Volume Multiplier", minval=1.0, step=0.1)
minActualVolume = input.float(0, "Minimum Actual Volume", minval=0)

atrLen = input.int(50, "ATR Length", minval=5)
zoneSizeATR = input.float(0.60, "Zone Size ATR Multiplier", minval=0.05, step=0.05)
maxMergedWidthATR = input.float(1.40, "Max Merged Region Width ATR", minval=0.2, step=0.1)
invalidATR = input.float(0.30, "Invalidation ATR Buffer", minval=0.0, step=0.05)

bodyMaxPercent = input.float(0.40, "Max Body % of Candle Range", minval=0.05, maxval=0.95, step=0.05)
wickMinPercent = input.float(0.40, "Min Wick % of Candle Range", minval=0.05, maxval=0.95, step=0.05)
strongWickPercent = input.float(0.55, "Strong Wick Override", minval=0.40, maxval=0.95, step=0.05)

lookbackDays = input.int(183, "Lookback Window Days", minval=30, maxval=1000)
extendBars = input.int(500, "Extend Zone Bars", minval=50, maxval=1000)
maxZones = input.int(10, "Keep Top Volume Zones", minval=1, maxval=50)

mergeNearbyZones = input.bool(true, "Merge Nearby Zones")
mergeDistancePercent = input.float(15.0, "Merge Distance % of Price", minval=0.1, maxval=50.0, step=0.1)

strongTouches = input.int(2, "Touches Needed For Strong Zone", minval=1, maxval=10)

deleteInvalidZones = input.bool(false, "Delete Invalid Zones")
fadeInvalidZones = input.bool(true, "Fade Invalid Zones")

showLabels = input.bool(true, "Show Volume Labels")
showInvalidLabels = input.bool(true, "Show Invalid Zone Labels")
shortLabels = input.bool(true, "Use Short Labels")

labelXOffset = input.int(12, "Label X Offset Bars", minval=1, maxval=300)
labelColumns = input.int(8, "Label Columns", minval=1, maxval=12)
labelColumnSpacing = input.int(55, "Column Spacing Bars", minval=5, maxval=150)
labelSpacingATR = input.float(4.0, "Auto Label Spacing ATR", minval=0.1, step=0.1)

autoLabelSize = input.bool(true, "Auto Label Size")
manualLabelSize = input.string("Large", "Manual Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"])

// Volume Profile Score
showVolumeProfileScore = input.bool(true, "Show Current Volume Profile Score")
vpLookback = input.int(200, "Volume Profile Lookback Candles", minval=20, maxval=500)
vpBins = input.int(24, "Volume Profile Price Bins", minval=8, maxval=60)
vpValueAreaPercent = input.float(75.0, "Zone Value Area %", minval=50.0, maxval=100.0, step=1.0)
vpCurrentBarOnly = input.bool(true, "Fast VP: Calculate LIVE Only On Current Bar")

// NEXT ZONE
includeOldNextZones = input.bool(true, "Include Old Zones For NEXT ZONE")

// Focus zones near current price
focusZones = input.bool(true, "Enable Focus Near Current Price")
focusDistanceATR = input.float(3.0, "Focus Distance (ATR)", minval=0.5, step=0.1)
focusHideDistant = input.bool(false, "Hide Distant Zones (instead of fade)")

// Zone color customization
sellZoneColor = input.color(color.rgb(255, 184, 92), "Sell Zone Color")
buyZoneColor = input.color(color.rgb(96, 180, 255), "Buy Zone Color")
zoneBorderTransparency = input.int(18, "Zone Border Transparency", minval=0, maxval=100)
zoneFillTransparency = input.int(90, "Zone Fill Transparency", minval=0, maxval=100)
zoneBorderWidth = input.int(2, "Zone Border Width", minval=1, maxval=5)
labelBackgroundTransparency = input.int(6, "Label Background Transparency", minval=0, maxval=100)
liveZoneBorderTransparency = input.int(8, "LIVE Zone Border Transparency", minval=0, maxval=100)
liveZoneFillTransparency = input.int(84, "LIVE Zone Fill Transparency", minval=0, maxval=100)
liveZoneBorderWidth = input.int(3, "LIVE Zone Border Width", minval=1, maxval=5)
mutedZoneBorderTransparency = input.int(38, "Muted Zone Border Transparency", minval=0, maxval=100)
mutedZoneFillTransparency = input.int(88, "Muted Zone Fill Transparency", minval=0, maxval=100)
maxFadedBorderTransparency = input.int(70, "Max Faded Border Transparency", minval=0, maxval=100)
maxFadedFillTransparency = input.int(92, "Max Faded Fill Transparency", minval=0, maxval=100)

// ==========================
// Label Size
// ==========================
getManualLabelSize() =>
    manualLabelSize == "Tiny" ? size.tiny : manualLabelSize == "Small" ? size.small : manualLabelSize == "Normal" ? size.normal : manualLabelSize == "Large" ? size.large : size.huge

getAutoLabelSize(int count, float zoneWidth, float atrValue) =>
    widthRatio = atrValue > 0 ? zoneWidth / atrValue : 1.0
    widthRatio >= 0.45 ? size.huge : widthRatio >= 0.20 ? size.large : size.normal

// ==========================
// Format Helpers
// ==========================
formatMillion(float v) =>
    str.tostring(v / 1000000.0, "#.##") + "M"

formatPrice(float p) =>
    str.tostring(p, format.mintick)

formatPercent(float v) =>
    str.tostring(v, "#.#") + "%"

// Normal CDF approximation
normalCDF(float z) =>
    absZ = math.abs(z)
    t = 1.0 / (1.0 + 0.2316419 * absZ)
    d = 0.3989423 * math.exp(-absZ * absZ / 2.0)
    prob = d * t * (0.3193815 + t * (-0.3565638 + t * (1.781478 + t * (-1.821256 + t * 1.330274))))
    cdf = z >= 0 ? 1.0 - prob : prob
    math.max(math.min(cdf, 1.0), 0.0)

// ==========================
// Basic Calculations
// ==========================
volMA = ta.sma(volume, volLen)
relVol = volMA > 0 ? volume / volMA : 0.0
atr = ta.atr(atrLen)

windowStartTime = timenow - lookbackDays * 24 * 60 * 60 * 1000
inLookbackWindow = time >= windowStartTime

candleRange = high - low
bodySize = math.abs(close - open)

upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

bodyPercent = candleRange > 0 ? bodySize / candleRange : 0.0
upperWickPercent = candleRange > 0 ? upperWick / candleRange : 0.0
lowerWickPercent = candleRange > 0 ? lowerWick / candleRange : 0.0

isActualVolume = volume > minActualVolume
isHighVolume = relVol >= volMultiplier
isSmallBody = bodyPercent <= bodyMaxPercent

hasUpperRejection = upperWickPercent >= wickMinPercent
hasLowerRejection = lowerWickPercent >= wickMinPercent

hasVeryStrongUpperWick = upperWickPercent >= strongWickPercent
hasVeryStrongLowerWick = lowerWickPercent >= strongWickPercent

// ==========================
// Zone Logic
// ==========================
resistanceSignal = isActualVolume and isHighVolume and hasUpperRejection and (isSmallBody or hasVeryStrongUpperWick)
supportSignal = isActualVolume and isHighVolume and hasLowerRejection and (isSmallBody or hasVeryStrongLowerWick)
resistanceZoneCreated = inLookbackWindow and resistanceSignal
supportZoneCreated = inLookbackWindow and supportSignal

baseZoneWidth = math.max(atr * zoneSizeATR, syminfo.mintick * 10)
maxMergedWidth = math.max(atr * maxMergedWidthATR, baseZoneWidth)
labelMinSpacing = math.max(atr * labelSpacingATR, syminfo.mintick * 30)
renderVisuals = barstate.islast

// ==========================
// Zone Arrays
// ==========================
var line[] zoneTopLines = array.new_line()
var line[] zoneBottomLines = array.new_line()
var line[] zoneValueLines = array.new_line()
var linefill[] zoneFills = array.new_linefill()
var label[] zoneLabels = array.new_label()

var float[] zoneTops = array.new_float()
var float[] zoneBottoms = array.new_float()
var float[] zoneCenters = array.new_float()
var float[] zoneWidths = array.new_float()
var float[] zonePOCs = array.new_float()
var float[] zoneVALows = array.new_float()
var float[] zoneVAHighs = array.new_float()

var int[] zoneTypes = array.new_int()
var int[] zoneTouches = array.new_int()
var float[] zoneCreateVolumes = array.new_float()
var float[] zoneTouchVolumes = array.new_float()
var bool[] zoneInvalid = array.new_bool()
var int[] zoneCreateTimes = array.new_int()

var float[] usedLabelPrices = array.new_float()
var int[] usedLabelColumns = array.new_int()

var line liveVPTopLine = na
var line liveVPBottomLine = na
var line liveVPValueLine = na
var linefill liveVPFill = na
var label liveVPLabel = na

// ==========================
// Delete Zone By Index
// ==========================
deleteZoneAt(int idx) =>
    if idx >= 0 and idx < array.size(zoneTopLines)
        topLine = array.get(zoneTopLines, idx)
        bottomLine = array.get(zoneBottomLines, idx)
        valueLine = array.get(zoneValueLines, idx)
        fillObj = array.get(zoneFills, idx)
        lb = array.get(zoneLabels, idx)

        line.delete(topLine)
        line.delete(bottomLine)
        line.delete(valueLine)
        linefill.delete(fillObj)

        if not na(lb)
            label.delete(lb)

        array.remove(zoneTopLines, idx)
        array.remove(zoneBottomLines, idx)
        array.remove(zoneValueLines, idx)
        array.remove(zoneFills, idx)
        array.remove(zoneLabels, idx)

        array.remove(zoneTops, idx)
        array.remove(zoneBottoms, idx)
        array.remove(zoneCenters, idx)
        array.remove(zoneWidths, idx)
        array.remove(zonePOCs, idx)
        array.remove(zoneVALows, idx)
        array.remove(zoneVAHighs, idx)

        array.remove(zoneTypes, idx)
        array.remove(zoneTouches, idx)
        array.remove(zoneCreateVolumes, idx)
        array.remove(zoneTouchVolumes, idx)
        array.remove(zoneInvalid, idx)
        array.remove(zoneCreateTimes, idx)

// ==========================
// Remove Zones Outside Window
// ==========================
removeZonesOutsideWindow() =>
    i = array.size(zoneTopLines) - 1

    while i >= 0
        createTime = array.get(zoneCreateTimes, i)

        if createTime < windowStartTime
            deleteZoneAt(i)

        i -= 1

// ==========================
// Keep Only Top Volume Zones
// ==========================
keepTopVolumeZones() =>
    while array.size(zoneTopLines) > maxZones
        minVol = array.get(zoneCreateVolumes, 0)
        minIndex = 0

        for i = 1 to array.size(zoneCreateVolumes) - 1
            v = array.get(zoneCreateVolumes, i)
            if v < minVol
                minVol := v
                minIndex := i

        deleteZoneAt(minIndex)

// ==========================
// Dominant Label Filter
// Only one label is shown when zones overlap in price.
// ==========================
isDominantLabel(int idx) =>
    dominant = true

    currentTop = array.get(zoneTops, idx)
    currentBottom = array.get(zoneBottoms, idx)
    currentCreateVol = array.get(zoneCreateVolumes, idx)
    currentTouchVol = array.get(zoneTouchVolumes, idx)
    currentTouches = array.get(zoneTouches, idx)

    if array.size(zoneCenters) > 1
        for i = 0 to array.size(zoneCenters) - 1
            if i != idx
                otherInvalid = array.get(zoneInvalid, i)
                otherCanShow = not otherInvalid or showInvalidLabels

                if otherCanShow
                    otherTop = array.get(zoneTops, i)
                    otherBottom = array.get(zoneBottoms, i)
                    zonesOverlap = currentTop >= otherBottom and otherTop >= currentBottom

                    if zonesOverlap
                        otherCreateVol = array.get(zoneCreateVolumes, i)
                        otherTouchVol = array.get(zoneTouchVolumes, i)
                        otherTouches = array.get(zoneTouches, i)

                        otherIsStronger = otherCreateVol > currentCreateVol or otherCreateVol == currentCreateVol and otherTouchVol > currentTouchVol or otherCreateVol == currentCreateVol and otherTouchVol == currentTouchVol and otherTouches > currentTouches or otherCreateVol == currentCreateVol and otherTouchVol == currentTouchVol and otherTouches == currentTouches and i < idx

                        if otherIsStronger
                            dominant := false

    dominant

isDominantZone(int idx) =>
    dominant = true

    currentTop = array.get(zoneTops, idx)
    currentBottom = array.get(zoneBottoms, idx)
    currentCreateVol = array.get(zoneCreateVolumes, idx)
    currentTouchVol = array.get(zoneTouchVolumes, idx)
    currentTouches = array.get(zoneTouches, idx)

    if array.size(zoneCenters) > 1
        for i = 0 to array.size(zoneCenters) - 1
            if i != idx
                otherTop = array.get(zoneTops, i)
                otherBottom = array.get(zoneBottoms, i)
                zonesOverlap = currentTop >= otherBottom and otherTop >= currentBottom

                if zonesOverlap
                    otherCreateVol = array.get(zoneCreateVolumes, i)
                    otherTouchVol = array.get(zoneTouchVolumes, i)
                    otherTouches = array.get(zoneTouches, i)

                    otherIsStronger = otherCreateVol > currentCreateVol or otherCreateVol == currentCreateVol and otherTouchVol > currentTouchVol or otherCreateVol == currentCreateVol and otherTouchVol == currentTouchVol and otherTouches > currentTouches or otherCreateVol == currentCreateVol and otherTouchVol == currentTouchVol and otherTouches == currentTouches and i < idx

                    if otherIsStronger
                        dominant := false

    dominant

// ==========================
// Find NEXT zone above current live VP zone
// Includes old zones when includeOldNextZones = true
// NEXT ZONE @ = nearest merged zone above vpCenter
// CONF = selected upper zone volume percentile among all upper zones
// ==========================
findNextUpperMergedZone(float refCenter) =>
    float bestPrice = close
    float bestVol = 0.0
    bool found = false
    float bestDistance = 1000000000.0

    float sumVol = 0.0
    float sumVolSq = 0.0
    int count = 0

    if array.size(zoneCenters) > 0
        for i = 0 to array.size(zoneCenters) - 1
            zInvalid = array.get(zoneInvalid, i)
            zoneCanBeUsed = not zInvalid or includeOldNextZones

            if zoneCanBeUsed
                zPOC = array.get(zonePOCs, i)
                zVol = array.get(zoneCreateVolumes, i)

                if zPOC > refCenter
                    distance = zPOC - refCenter

                    sumVol += zVol
                    sumVolSq += zVol * zVol
                    count += 1

                    if distance < bestDistance
                        bestDistance := distance
                        bestPrice := zPOC
                        bestVol := zVol
                        found := true

    meanVol = count > 0 ? sumVol / count : 0.0
    variance = count > 0 ? math.max(sumVolSq / count - meanVol * meanVol, 0.0) : 0.0
    stdVol = math.sqrt(math.max(variance, 1.0))
    zScore = found ? (bestVol - meanVol) / stdVol : 0.0
    confidence = found ? normalCDF(zScore) * 100.0 : 0.0

    [bestPrice, bestVol, confidence, found]

// ==========================
// Volume Profile Score
// VP score is based on current price bin
// Fallback CONF is based on current VP bin percentile
// ==========================
calcCurrentVPScore() =>
    profileHigh = ta.highest(high, vpLookback)
    profileLow = ta.lowest(low, vpLookback)
    profileRange = math.max(profileHigh - profileLow, syminfo.mintick)
    binSize = profileRange / vpBins

    currentBinRaw = math.floor((close - profileLow) / binSize)
    currentBin = int(math.max(math.min(currentBinRaw, vpBins - 1), 0))
    currentBinLow = profileLow + currentBin * binSize
    currentBinHigh = currentBinLow + binSize

    float maxBinVol = 0.0
    float currentBinVol = 0.0
    float pocPrice = close
    float totalVPVol = 0.0

    float sumBinVol = 0.0
    float sumBinVolSq = 0.0

    for b = 0 to vpBins - 1
        binLow = profileLow + b * binSize
        binHigh = binLow + binSize
        binCenter = (binLow + binHigh) / 2.0

        float binVol = 0.0

        for n = 0 to vpLookback - 1
            candleHigh = high[n]
            candleLow = low[n]
            candleRangeSafe = math.max(candleHigh - candleLow, syminfo.mintick)

            overlapTop = math.min(candleHigh, binHigh)
            overlapBottom = math.max(candleLow, binLow)
            overlap = math.max(overlapTop - overlapBottom, 0.0)

            binVol += volume[n] * overlap / candleRangeSafe

        totalVPVol += binVol
        sumBinVol += binVol
        sumBinVolSq += binVol * binVol

        if binVol > maxBinVol
            maxBinVol := binVol
            pocPrice := binCenter

        if b == currentBin
            currentBinVol := binVol

    score = maxBinVol > 0 ? currentBinVol / maxBinVol * 100.0 : 0.0
    currentBinCenter = (currentBinLow + currentBinHigh) / 2.0
    vpShare = totalVPVol > 0 ? currentBinVol / totalVPVol * 100.0 : 0.0

    meanBinVol = sumBinVol / vpBins
    variance = math.max(sumBinVolSq / vpBins - meanBinVol * meanBinVol, 0.0)
    stdBinVol = math.sqrt(math.max(variance, 1.0))
    zScore = (currentBinVol - meanBinVol) / stdBinVol
    fallbackConfidence = normalCDF(zScore) * 100.0

    [score, currentBinVol, currentBinCenter, binSize, pocPrice, totalVPVol, vpShare, fallbackConfidence, currentBinLow, currentBinHigh]

enoughBarsForVP = bar_index >= vpLookback

calcRangePOC(float rangeLow, float rangeHigh) =>
    safeLow = math.min(rangeLow, rangeHigh)
    safeHigh = math.max(rangeLow, rangeHigh)
    safeRange = math.max(safeHigh - safeLow, syminfo.mintick)
    binSize = safeRange / vpBins

    float maxBinVol = 0.0
    float pocPrice = (safeLow + safeHigh) / 2.0

    for b = 0 to vpBins - 1
        binLow = safeLow + b * binSize
        binHigh = binLow + binSize
        binCenter = (binLow + binHigh) / 2.0

        float binVol = 0.0

        for n = 0 to vpLookback - 1
            candleHigh = high[n]
            candleLow = low[n]
            candleRangeSafe = math.max(candleHigh - candleLow, syminfo.mintick)

            overlapTop = math.min(candleHigh, binHigh)
            overlapBottom = math.max(candleLow, binLow)
            overlap = math.max(overlapTop - overlapBottom, 0.0)

            binVol += volume[n] * overlap / candleRangeSafe

        if binVol > maxBinVol
            maxBinVol := binVol
            pocPrice := binCenter

    pocPrice

getZonePOC(float rangeLow, float rangeHigh) =>
    float pocPrice = (rangeLow + rangeHigh) / 2.0
    if enoughBarsForVP
        pocPrice := calcRangePOC(rangeLow, rangeHigh)
    pocPrice

// ==========================
// Soft Band Opacity
// ==========================
getSoftBandOpacity(float createVol, bool isInvalid, bool isStrong, float minV, float maxV) =>
    rangeV = math.max(maxV - minV, 1.0)
    ratio = (createVol - minV) / rangeV

    rawOpacity = zoneFillTransparency - ratio * 5.0

    rawOpacity := isStrong ? rawOpacity - 4.0 : rawOpacity
    rawOpacity := isInvalid and fadeInvalidZones ? rawOpacity + 6.0 : rawOpacity

    int(math.round(math.max(math.min(rawOpacity, 96.0), 78.0)))

// ==========================
// Find Merge Target
// ==========================
findMergeIndex(float newPOC, int newType) =>
    mergeIndex = -1
    bestDistance = 1000000000.0

    if mergeNearbyZones and array.size(zoneTopLines) > 0
        threshold = close * mergeDistancePercent / 100.0

        for i = 0 to array.size(zoneTopLines) - 1
            existingType = array.get(zoneTypes, i)

            if existingType == newType
                existingPOC = array.get(zonePOCs, i)
                distance = math.abs(newPOC - existingPOC)

                if distance <= threshold and distance < bestDistance
                    bestDistance := distance
                    mergeIndex := i

    mergeIndex

// ==========================
// Merge Zone Around Value Line
// ==========================
mergeZoneAt(int idx, float newPOC) =>
    oldPOC = array.get(zonePOCs, idx)
    oldCreateVol = array.get(zoneCreateVolumes, idx)

    newVol = volume
    mergedVol = oldCreateVol + newVol

    mergedTop = math.max(oldPOC, newPOC)
    mergedBottom = math.min(oldPOC, newPOC)
    mergedCenter = (mergedTop + mergedBottom) / 2.0
    mergedWidth = mergedTop - mergedBottom

    array.set(zoneCenters, idx, mergedCenter)
    array.set(zoneWidths, idx, mergedWidth)
    array.set(zoneTops, idx, mergedTop)
    array.set(zoneBottoms, idx, mergedBottom)
    mergedPOC = getZonePOC(mergedBottom, mergedTop)
    array.set(zonePOCs, idx, mergedPOC)
    array.set(zoneCreateVolumes, idx, mergedVol)
    array.set(zoneInvalid, idx, false)
    array.set(zoneCreateTimes, idx, time)

    topLine = array.get(zoneTopLines, idx)
    bottomLine = array.get(zoneBottomLines, idx)
    valueLine = array.get(zoneValueLines, idx)

    line.set_y1(topLine, mergedTop)
    line.set_y2(topLine, mergedTop)
    line.set_y1(bottomLine, mergedBottom)
    line.set_y2(bottomLine, mergedBottom)
    line.set_y1(valueLine, mergedPOC)
    line.set_y2(valueLine, mergedPOC)

// ==========================
// Create New Zone
// ==========================
createZone(float topPrice, float bottomPrice, int zoneType) =>
    zoneColor = zoneType == 1 ? sellZoneColor : buyZoneColor
    zoneName = zoneType == 1 ? "S" : "B"

    newCenter = (topPrice + bottomPrice) / 2.0
    newWidth = math.min(math.max(topPrice - bottomPrice, baseZoneWidth), maxMergedWidth)
    topRegion = newCenter + newWidth / 2.0
    bottomRegion = newCenter - newWidth / 2.0
    newPOC = getZonePOC(bottomRegion, topRegion)

    mergeIndex = findMergeIndex(newPOC, zoneType)

    if mergeIndex != -1
        mergeZoneAt(mergeIndex, newPOC)
    else
        topLine = line.new(bar_index, topRegion, bar_index + extendBars, topRegion, color=color.new(zoneColor, zoneBorderTransparency), width=zoneBorderWidth)
        bottomLine = line.new(bar_index, bottomRegion, bar_index + extendBars, bottomRegion, color=color.new(zoneColor, zoneBorderTransparency), width=zoneBorderWidth)
        valueLine = line.new(bar_index, newPOC, bar_index + extendBars, newPOC, color=color.new(zoneColor, 8), width=zoneBorderWidth, style=line.style_dotted)

        fillObj = linefill.new(topLine, bottomLine, color.new(zoneColor, zoneFillTransparency))

        label newLabel = na

        if showLabels
            txt = renderVisuals ? zoneName + " POC " + formatPrice(newPOC) + " | V " + formatMillion(volume) : ""
            newLabel := label.new(bar_index + labelXOffset, newPOC, txt, style=label.style_label_left, textcolor=zoneColor, color=color.new(color.black, labelBackgroundTransparency), size=size.normal)

            // If focusing is enabled and we should hide distant new zones, clear label immediately
            if focusZones and focusHideDistant and atr > 0 and math.abs(newPOC - close) > focusDistanceATR * atr
                label.set_text(newLabel, "")

        array.push(zoneTopLines, topLine)
        array.push(zoneBottomLines, bottomLine)
        array.push(zoneValueLines, valueLine)
        array.push(zoneFills, fillObj)
        array.push(zoneLabels, newLabel)

        array.push(zoneTops, topRegion)
        array.push(zoneBottoms, bottomRegion)
        array.push(zoneCenters, newCenter)
        array.push(zoneWidths, newWidth)
        array.push(zonePOCs, newPOC)

        array.push(zoneTypes, zoneType)
        array.push(zoneTouches, 0)
        array.push(zoneCreateVolumes, volume)
        array.push(zoneTouchVolumes, 0.0)
        array.push(zoneInvalid, false)
        array.push(zoneCreateTimes, time)

    keepTopVolumeZones()

// ==========================
// Window Maintenance
// ==========================
removeZonesOutsideWindow()

// ==========================
// Create Zones Only Inside Lookback Window
// ==========================
if resistanceZoneCreated
    createZone(high, high - baseZoneWidth, 1)

if supportZoneCreated
    createZone(low + baseZoneWidth, low, -1)

// ==========================
// Update Existing Zones
// ==========================
zoneCount = array.size(zoneTopLines)
zoneMinCreateVol = renderVisuals and zoneCount > 0 ? array.min(zoneCreateVolumes) : volume
zoneMaxCreateVol = renderVisuals and zoneCount > 0 ? array.max(zoneCreateVolumes) : volume

if zoneCount > 0
    i = zoneCount - 1

    while i >= 0
        topZ = array.get(zoneTops, i)
        bottomZ = array.get(zoneBottoms, i)

        zoneType = array.get(zoneTypes, i)
        touches = array.get(zoneTouches, i)
        touchVol = array.get(zoneTouchVolumes, i)
        createVol = array.get(zoneCreateVolumes, i)
        isInvalid = array.get(zoneInvalid, i)
        createTime = array.get(zoneCreateTimes, i)

        priceTouchedZone = time > createTime and high >= bottomZ and low <= topZ

        if priceTouchedZone and volume > 0
            overlapTop = math.min(high, topZ)
            overlapBottom = math.max(low, bottomZ)
            overlapRange = math.max(overlapTop - overlapBottom, 0)
            candleRangeSafe = math.max(high - low, syminfo.mintick)
            estimatedZoneVolume = volume * overlapRange / candleRangeSafe

            touches += 1
            touchVol += estimatedZoneVolume

            array.set(zoneTouches, i, touches)
            array.set(zoneTouchVolumes, i, touchVol)

        resistanceInvalid = zoneType == 1 and close > topZ + atr * invalidATR
        supportInvalid = zoneType == -1 and close < bottomZ - atr * invalidATR

        if resistanceInvalid or supportInvalid
            isInvalid := true
            array.set(zoneInvalid, i, true)

        if renderVisuals
            topLine = array.get(zoneTopLines, i)
            bottomLine = array.get(zoneBottomLines, i)
            valueLine = array.get(zoneValueLines, i)
            fillObj = array.get(zoneFills, i)

            line.set_x2(topLine, bar_index + extendBars)
            line.set_x2(bottomLine, bar_index + extendBars)
            line.set_x2(valueLine, bar_index + extendBars)
            zonePOC = getZonePOC(bottomZ, topZ)
            array.set(zonePOCs, i, zonePOC)
            line.set_y1(valueLine, zonePOC)
            line.set_y2(valueLine, zonePOC)

            isStrongZone = touches >= strongTouches
            zoneColor = zoneType == 1 ? sellZoneColor : buyZoneColor
            bandOpacity = getSoftBandOpacity(createVol, isInvalid, isStrongZone, zoneMinCreateVol, zoneMaxCreateVol)
            isDominantVisualZone = isDominantZone(i)

            boundaryOpacity = not isDominantVisualZone ? mutedZoneBorderTransparency : isInvalid and fadeInvalidZones ? 86 : zoneBorderTransparency
            valueLineOpacity = not isDominantVisualZone ? mutedZoneBorderTransparency : isInvalid and fadeInvalidZones ? 80 : 8
            bandOpacity := not isDominantVisualZone ? mutedZoneFillTransparency : bandOpacity

            line.set_color(topLine, color.new(zoneColor, boundaryOpacity))
            line.set_color(bottomLine, color.new(zoneColor, boundaryOpacity))
            line.set_color(valueLine, color.new(zoneColor, valueLineOpacity))

            line.set_width(topLine, zoneBorderWidth)
            line.set_width(bottomLine, zoneBorderWidth)
            line.set_width(valueLine, zoneBorderWidth)

            linefill.set_color(fillObj, color.new(zoneColor, bandOpacity))

            // Focus logic: de-emphasize or hide zones far from current price
            if focusZones and atr > 0
                dist = math.abs(zonePOC - close)
                threshold = focusDistanceATR * atr

                if dist > threshold
                    if focusHideDistant
                        // Hide distant zone visuals and labels
                        line.set_color(topLine, color.new(zoneColor, 100))
                        line.set_color(bottomLine, color.new(zoneColor, 100))
                        line.set_color(valueLine, color.new(zoneColor, 100))
                        linefill.set_color(fillObj, color.new(zoneColor, 100))

                        lb = array.get(zoneLabels, i)
                        if not na(lb)
                            label.set_text(lb, "")
                    else
                        // Fade distant zone further
                        extraFade = 6
                        newBoundary = math.min(boundaryOpacity + extraFade, maxFadedBorderTransparency)
                        newValue = math.min(valueLineOpacity + extraFade, maxFadedBorderTransparency)
                        newBand = math.min(bandOpacity + extraFade, maxFadedFillTransparency)

                        line.set_color(topLine, color.new(zoneColor, newBoundary))
                        line.set_color(bottomLine, color.new(zoneColor, newBoundary))
                        line.set_color(valueLine, color.new(zoneColor, newValue))
                        linefill.set_color(fillObj, color.new(zoneColor, newBand))

        if deleteInvalidZones and isInvalid
            deleteZoneAt(i)

        i -= 1

activeCount = array.size(zoneTopLines)
manualZoneLabelSize = getManualLabelSize()

array.clear(usedLabelPrices)
array.clear(usedLabelColumns)

// ==========================
// Current Price Volume Profile Score
// NEXT ZONE @ = nearest merged zone above current live VP zone
// CONF = that upper zone volume percentile among all upper zones
// LIVE label keeps the default right-side anchor and reserves its price
// ==========================
shouldUpdateLiveVP = showVolumeProfileScore and enoughBarsForVP and (not vpCurrentBarOnly or barstate.islast)

if shouldUpdateLiveVP
    [vpScore, vpCurrentVol, vpCenter, vpBinSize, vpPOC, vpTotalVol, vpShare, vpFallbackConfidence, vpValueZoneBottom, vpValueZoneTop] = calcCurrentVPScore()

    isBuyVP = close <= vpPOC
    vpColor = isBuyVP ? buyZoneColor : sellZoneColor
    liveText = isBuyVP ? "LIVE B" : "LIVE S"

    [targetZonePrice, targetZoneVol, targetZoneConfidence, hasTargetZone] = findNextUpperMergedZone(vpCenter)

    zonePriceText = hasTargetZone ? formatPrice(targetZonePrice) : "N/A"
    finalConfidence = hasTargetZone ? targetZoneConfidence : vpFallbackConfidence

    liveZoneWidth = math.max(vpBinSize, baseZoneWidth * 1.15)
    vpBandTop = vpCenter + liveZoneWidth / 2.0
    vpBandBottom = vpCenter - liveZoneWidth / 2.0

    vpOpacity = int(math.round(math.max(math.min(liveZoneFillTransparency - vpScore * 0.04, 90.0), 76.0)))
    vpBorderOpacity = int(math.max(math.min(liveZoneBorderTransparency, 100), 0))
    vpValueOpacity = int(math.max(math.min(liveZoneBorderTransparency - 10, 100), 0))

    vpLabelText = liveText + " @ " + formatPrice(vpCenter) + " | Score " + str.tostring(vpScore, "#") + " | Next " + zonePriceText + " | V " + formatMillion(vpCurrentVol) + " | VR " + formatPercent(vpShare) + " | Conf " + str.tostring(finalConfidence, "#")

    vpLabelX = bar_index + labelXOffset
    vpLabelY = vpCenter
    vpLabelSize = autoLabelSize ? getAutoLabelSize(activeCount + 1, vpBinSize, atr) : manualZoneLabelSize

    if na(liveVPTopLine) or na(liveVPBottomLine) or na(liveVPValueLine) or na(liveVPFill)
        if not na(liveVPTopLine)
            line.delete(liveVPTopLine)
        if not na(liveVPBottomLine)
            line.delete(liveVPBottomLine)
        if not na(liveVPValueLine)
            line.delete(liveVPValueLine)
        if not na(liveVPFill)
            linefill.delete(liveVPFill)

        liveVPTopLine := line.new(bar_index, vpBandTop, bar_index + extendBars, vpBandTop, color=color.new(vpColor, vpBorderOpacity), width=liveZoneBorderWidth)
        liveVPBottomLine := line.new(bar_index, vpBandBottom, bar_index + extendBars, vpBandBottom, color=color.new(vpColor, vpBorderOpacity), width=liveZoneBorderWidth)
        liveVPValueLine := line.new(bar_index, vpCenter, bar_index + extendBars, vpCenter, color=color.new(vpColor, vpValueOpacity), width=liveZoneBorderWidth, style=line.style_solid)
        liveVPFill := linefill.new(liveVPTopLine, liveVPBottomLine, color.new(vpColor, vpOpacity))
    else
        line.set_xy1(liveVPTopLine, bar_index, vpBandTop)
        line.set_xy2(liveVPTopLine, bar_index + extendBars, vpBandTop)

        line.set_xy1(liveVPBottomLine, bar_index, vpBandBottom)
        line.set_xy2(liveVPBottomLine, bar_index + extendBars, vpBandBottom)

        line.set_xy1(liveVPValueLine, bar_index, vpCenter)
        line.set_xy2(liveVPValueLine, bar_index + extendBars, vpCenter)

        line.set_color(liveVPTopLine, color.new(vpColor, vpBorderOpacity))
        line.set_color(liveVPBottomLine, color.new(vpColor, vpBorderOpacity))
        line.set_color(liveVPValueLine, color.new(vpColor, vpValueOpacity))
        line.set_width(liveVPTopLine, liveZoneBorderWidth)
        line.set_width(liveVPBottomLine, liveZoneBorderWidth)
        line.set_width(liveVPValueLine, liveZoneBorderWidth)

        linefill.set_color(liveVPFill, color.new(vpColor, vpOpacity))

    if na(liveVPLabel)
        liveVPLabel := label.new(vpLabelX, vpLabelY, vpLabelText, style=label.style_label_left, textcolor=vpColor, color=color.new(color.black, labelBackgroundTransparency), size=vpLabelSize)
    else
        label.set_text(liveVPLabel, vpLabelText)
        label.set_x(liveVPLabel, vpLabelX)
        label.set_y(liveVPLabel, vpLabelY)
        label.set_style(liveVPLabel, label.style_label_left)
        label.set_size(liveVPLabel, vpLabelSize)
        label.set_color(liveVPLabel, color.new(color.black, labelBackgroundTransparency))
        label.set_textcolor(liveVPLabel, vpColor)
    array.push(usedLabelPrices, vpLabelY)
    array.push(usedLabelColumns, 0)
else
    if not na(liveVPTopLine)
        line.delete(liveVPTopLine)
        liveVPTopLine := na

    if not na(liveVPBottomLine)
        line.delete(liveVPBottomLine)
        liveVPBottomLine := na

    if not na(liveVPValueLine)
        line.delete(liveVPValueLine)
        liveVPValueLine := na

    if not na(liveVPFill)
        linefill.delete(liveVPFill)
        liveVPFill := na

    if not na(liveVPLabel)
        label.delete(liveVPLabel)
        liveVPLabel := na

// ==========================
// Adaptive Zone Labels
// Zone labels are placed after the LIVE label reserves its price.
// ==========================
if showLabels and activeCount > 0 and renderVisuals
    for j = 0 to activeCount - 1
        currentLabel = array.get(zoneLabels, j)

        if not na(currentLabel)
            zonePOC = array.get(zonePOCs, j)
            zoneType = array.get(zoneTypes, j)
            zoneWidth = array.get(zoneWidths, j)
            touches = array.get(zoneTouches, j)
            createVol = array.get(zoneCreateVolumes, j)
            touchVol = array.get(zoneTouchVolumes, j)
            isInvalid = array.get(zoneInvalid, j)

            showThisLabel = not isInvalid or showInvalidLabels
            showThisLabel := showThisLabel and isDominantLabel(j)

            if showThisLabel
                baseName = zoneType == 1 ? "S" : "B"
                fullName = zoneType == 1 ? "SELL" : "BUY"

                labelText = shortLabels ? baseName + " POC " + formatPrice(zonePOC) + " V" + formatMillion(createVol) + " #" + str.tostring(touches) : fullName + " POC " + formatPrice(zonePOC) + " V" + formatMillion(createVol) + " Touches " + str.tostring(touches)

                desiredY = zonePOC

                closeLabelCount = 0

                usedCount = array.size(usedLabelPrices)
                if usedCount > 0
                    for k = 0 to usedCount - 1
                        existingY = array.get(usedLabelPrices, k)
                        tooClose = math.abs(desiredY - existingY) < labelMinSpacing

                        if tooClose
                            closeLabelCount += 1

                stackStep = math.floor((closeLabelCount + 1) / 2)
                stackDirection = closeLabelCount % 2 == 0 ? 1 : -1
                rawLabelOffset = labelXOffset + stackDirection * stackStep * labelColumnSpacing
                labelOffset = math.max(-extendBars, math.min(rawLabelOffset, extendBars - 5))
                labelX = bar_index + labelOffset

                array.push(usedLabelPrices, desiredY)
                array.push(usedLabelColumns, closeLabelCount)

                labelColor = zoneType == 1 ? sellZoneColor : buyZoneColor
                labelTextColor = isInvalid and fadeInvalidZones ? color.new(labelColor, 25) : labelColor
                zoneLabelSize = autoLabelSize ? getAutoLabelSize(activeCount, zoneWidth, atr) : manualZoneLabelSize

                label.set_text(currentLabel, labelText)
                label.set_x(currentLabel, labelX)
                label.set_y(currentLabel, desiredY)
                label.set_style(currentLabel, labelOffset < 0 ? label.style_label_right : label.style_label_left)
                label.set_size(currentLabel, zoneLabelSize)
                label.set_color(currentLabel, color.new(color.black, isInvalid and fadeInvalidZones ? 25 : labelBackgroundTransparency))
                label.set_textcolor(currentLabel, labelTextColor)
            else
                label.set_text(currentLabel, "")

// ==========================
// Alerts
// ==========================
alertcondition(resistanceZoneCreated, title="New Sell Executed Volume Zone", message="New sell-side executed volume restraint zone detected")
alertcondition(supportZoneCreated, title="New Buy Executed Volume Zone", message="New buy-side executed volume restraint zone detected")
````
