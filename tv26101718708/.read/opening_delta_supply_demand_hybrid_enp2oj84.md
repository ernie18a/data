# Opening Delta Supply Demand Hybrid

- url: https://www.tradingview.com/script/Enp2OJ84-Opening-Delta-Supply-Demand-Hybrid/
- type: indicator
- pine_id: PUB;2794d7f9b6324294aeb185b3a5a86f1a
- version: 1.0

## Description

Opening Delta Supply Demand Hybrid
This indicator combines Daily Supply and Demand zones, LVN confluence, Money Flow high-trade zones, and Opening Delta dominance pressure.
It detects important supply and demand areas from daily price and volume behavior. The zones stay active until price fully breaks them with a candle close. A supply zone is invalidated only when price closes above it, and a demand zone is invalidated only when price closes below it.
The Opening Delta model measures buyer and seller pressure from the session open. It tracks delta strength, dominance, RVOL, candle quality, superior delta, and dominance flips. If real volume delta is unavailable or returns zero, the indicator can use a candle-volume fallback to keep signals working.
BUY signals appear when price rejects a demand zone and Opening Delta confirms buyer strength. SELL signals appear when price rejects a supply zone and Opening Delta confirms seller strength. The indicator blocks signals when the global strength favors the opposite side.
It also includes a Money Flow High Trade Zone, which highlights the price area with the highest money flow activity from the daily profile.
Main features:
Daily Supply and Demand zones
LVN confluence
Money Flow high-trade zone
Opening Delta buyer/seller pressure
Dominance strength table
BUY and SELL confirmation arrows
Alerts for hybrid signals and delta conditions
Configurable filters for stricter or more aggressive signals

How To Use
Add the indicator to your chart and choose the market/session you trade.

Set the session start time to match your market open.
For example, US index futures usually use 9:30 New York time for the cash open.

Watch the supply and demand zones:
Demand zones are potential bounce areas.
Supply zones are potential rejection areas.
Zones remain active until price fully breaks them with a candle close.

Use the Opening Delta table to read market control:
BUYERS means buyer pressure is stronger.
SELLERS means seller pressure is stronger.
BALANCED means there is no clear dominance.

Look for confirmed signals:
A BUY signal appears when price rejects a demand zone and buyer pressure confirms the bounce.
A SELL signal appears when price rejects a supply zone and seller pressure confirms the rejection.

Avoid trading against the strength:
If price touches demand but strength favors sellers, the indicator blocks the BUY signal.
If price touches supply but strength favors buyers, the indicator blocks the SELL signal.

Use the Money Flow High Trade Zone as an important reaction area.
This zone shows where the highest money flow activity occurred in the daily profile.

Adjust the filters:
Use stricter settings for fewer but stronger signals.
Disable some confirmations for more aggressive signals.
Lower the cooldown if you want more frequent arrows.

Basic Rule
Buy only when price reacts from demand and Opening Delta supports buyers.
Sell only when price reacts from supply and Opening Delta supports sellers.

## Source Code

````pine
//@version=6
indicator("Opening Delta Supply Demand Hybrid", "OD + SD Hybrid", overlay = true, max_bars_back = 1000, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

import TradingView/ta/8

//------------------------------------------------------------------------------
// Supply/Demand Settings
//------------------------------------------------------------------------------
per = input.float(10., "Supply/Demand Threshold %", minval = 0, maxval = 100)
div = input.int(50, "Supply/Demand Resolution", minval = 2, maxval = 300)
tf = input.timeframe("", "Intrabar TF")

vpSRC = input.string("Volume", "Profile Source", options = ["Volume", "Money Flow"], group = "LVN")
rpNR = input.int(25, "Number of Rows", minval = 10, maxval = 100, step = 5, group = "LVN")
vpLVT = input.int(37, "Low Traded Nodes Threshold %", minval = 10, maxval = 40, step = 1, group = "LVN") / 100
lvnNearPct = input.float(20., "LVN Near Weighted Line % of Zone", minval = 0, maxval = 100, group = "LVN") / 100
showOnlyLvnZones = input.bool(false, "Show Only Zones With LVN", group = "LVN")
showLvnLines = input.bool(true, "Show LVN Lines", group = "LVN")
showScoreLabels = input.bool(true, "Show Strength Labels", group = "LVN")

maxDays = input.int(20, "Max Daily Zones To Keep", minval = 1, maxval = 80, group = "Display")
nearestSupply = input.int(2, "Nearest Untested Supply Zones", minval = 0, maxval = 10, group = "Display")
nearestDemand = input.int(2, "Nearest Untested Demand Zones", minval = 0, maxval = 10, group = "Display")
hideRetested = input.bool(true, "Hide Retested Zones", group = "Display")
correctSideOnly = input.bool(true, "Only Supply Above / Demand Below Price", group = "Display")
extendZones = input.bool(true, "Extend Zones To Current Bar", group = "Display")

showSupply = input.bool(true, "Supply", inline = "supply", group = "Style")
supplyCss = input.color(#2157f3, "", inline = "supply", group = "Style")
supplyArea = input.bool(true, "Area", inline = "supply", group = "Style")
supplyAvg = input.bool(true, "Average", inline = "supply", group = "Style")
supplyWavg = input.bool(true, "Weighted", inline = "supply", group = "Style")

showDemand = input.bool(true, "Demand", inline = "demand", group = "Style")
demandCss = input.color(#ff5d00, "", inline = "demand", group = "Style")
demandArea = input.bool(true, "Area", inline = "demand", group = "Style")
demandAvg = input.bool(true, "Average", inline = "demand", group = "Style")
demandWavg = input.bool(true, "Weighted", inline = "demand", group = "Style")

lvnCss = input.color(#f23645, "LVN", group = "Style")
strongCss = input.color(#00c853, "Strong Zone Border", group = "Style")

//------------------------------------------------------------------------------
// Opening Delta - Volume Delta
//------------------------------------------------------------------------------
groupDelta = "Volume Delta"

useCustomTimeframe = input.bool(false, "Use custom lower timeframe", group = groupDelta)
customLowerTf = input.timeframe("1", "Lower timeframe", active = useCustomTimeframe, group = groupDelta)
useCandleDeltaFallback = input.bool(true, "Use candle-volume fallback when delta is zero", group = groupDelta)

lowerTf = switch
    useCustomTimeframe => customLowerTf
    timeframe.isseconds => "1S"
    timeframe.isintraday => "1"
    timeframe.isdaily => "5"
    => "60"

[vdOpenDelta, vdMaxDelta, vdMinDelta, vdLastDelta] = ta.requestVolumeDelta(lowerTf)

rawDelta = nz(vdLastDelta)
fallbackDelta = close > open ? volume : close < open ? -volume : close > close[1] ? volume : close < close[1] ? -volume : 0.0
delta = useCandleDeltaFallback and rawDelta == 0 ? fallbackDelta : rawDelta
absDelta = math.abs(delta)

//------------------------------------------------------------------------------
// Opening Delta - Session
//------------------------------------------------------------------------------
groupSession = "Session"

startHour = input.int(9, "Start hour", minval = 0, maxval = 23, group = groupSession)
startMinute = input.int(30, "Start minute", minval = 0, maxval = 59, group = groupSession)
resetDaily = input.bool(true, "Reset daily", group = groupSession)

sessionStart = timestamp(syminfo.timezone, year, month, dayofmonth, startHour, startMinute)
originalInSession = time >= sessionStart
firstSessionBar = originalInSession and not originalInSession[1]
odNewDay = nz(ta.change(time("D")), 0) != 0

var bool carrySession = false

if resetDaily and odNewDay
    carrySession := false

if firstSessionBar
    carrySession := true

if originalInSession
    carrySession := true

inSession = carrySession

//------------------------------------------------------------------------------
// Opening Delta - Pressure Model
//------------------------------------------------------------------------------
groupModel = "Pressure Model"

volLen = input.int(100, "RVOL length", minval = 20, maxval = 1000, group = groupModel)
useRvol = input.bool(true, "Weight by RVOL", group = groupModel)
useCandleQuality = input.bool(true, "Weight by candle quality", group = groupModel)

challengeFactor = input.float(1.00, "Counter delta must beat opening threshold", minval = 0.25, maxval = 3.0, step = 0.05, group = groupModel)
dominanceThreshold = input.float(8.0, "Dominance threshold %", minval = 0.0, maxval = 50.0, step = 0.5, group = groupModel)
flipThreshold = input.float(8.0, "Flip confirmation threshold %", minval = 0.0, maxval = 50.0, step = 0.5, group = groupModel)
decay = input.float(0.00, "Pressure decay per bar %", minval = 0.0, maxval = 10.0, step = 0.25, group = groupModel)

superiorFactor = input.float(1.15, "Superior delta factor", minval = 1.0, maxval = 5.0, step = 0.05, group = groupModel)
minQualityForSuperior = input.float(1.20, "Min candle quality for superior delta", minval = 0.25, maxval = 5.0, step = 0.05, group = groupModel)
minRvolForSuperior = input.float(1.00, "Min RVOL for superior delta", minval = 0.1, maxval = 10.0, step = 0.1, group = groupModel)

//------------------------------------------------------------------------------
// Opening Delta - Candle Behavior
//------------------------------------------------------------------------------
rng = math.max(high - low, syminfo.mintick)
body = math.abs(close - open)
bodyRatio = body / rng

closePos = (close - low) / rng

upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

upperWickRatio = upperWick / rng
lowerWickRatio = lowerWick / rng

bullQuality = closePos + bodyRatio + lowerWickRatio * 0.50
bearQuality = (1.0 - closePos) + bodyRatio + upperWickRatio * 0.50

candleQuality =
     delta > 0 ? bullQuality :
     delta < 0 ? bearQuality :
     1.0

volMa = ta.sma(volume, volLen)
rvol = volMa > 0 ? volume / volMa : 1.0

rvolWeight = useRvol ? math.max(rvol, 0.25) : 1.0
qualityWeight = useCandleQuality ? math.max(candleQuality, 0.25) : 1.0

barPressure = absDelta * rvolWeight * qualityWeight

//------------------------------------------------------------------------------
// Opening Delta - Opening Threshold
//------------------------------------------------------------------------------
var float openingSessionDelta = na
var float openingThreshold = na
var int openingSide = 0

if resetDaily and odNewDay
    openingSessionDelta := na
    openingThreshold := na
    openingSide := 0

if firstSessionBar
    openingSessionDelta := delta
    openingThreshold := math.max(absDelta, 1.0)
    openingSide := delta > 0 ? 1 : delta < 0 ? -1 : 0

bullBarPressure = inSession and delta > 0 ? barPressure : 0.0
bearBarPressure = inSession and delta < 0 ? barPressure : 0.0

bearChallenge = inSession and delta < 0 and not na(openingThreshold) and absDelta >= openingThreshold * challengeFactor
bullChallenge = inSession and delta > 0 and not na(openingThreshold) and absDelta >= openingThreshold * challengeFactor

superiorDelta = inSession and not firstSessionBar and not na(openingThreshold) and absDelta >= openingThreshold * superiorFactor and candleQuality >= minQualityForSuperior and rvol >= minRvolForSuperior
superiorBullDelta = superiorDelta and delta > 0
superiorBearDelta = superiorDelta and delta < 0

//------------------------------------------------------------------------------
// Opening Delta - Global Accumulated Pressure
//------------------------------------------------------------------------------
var float bullPressure = 0.0
var float bearPressure = 0.0

if resetDaily and odNewDay
    bullPressure := 0.0
    bearPressure := 0.0

if firstSessionBar
    bullPressure := 0.0
    bearPressure := 0.0

if inSession
    bullPressure *= 1.0 - decay / 100.0
    bearPressure *= 1.0 - decay / 100.0

    bullPressure += bullBarPressure
    bearPressure += bearBarPressure

totalPressure = bullPressure + bearPressure

bullPct = totalPressure > 0 ? bullPressure / totalPressure * 100.0 : 50.0
bearPct = totalPressure > 0 ? bearPressure / totalPressure * 100.0 : 50.0

dominance = bullPct - bearPct
absDominance = math.abs(dominance)

control =
     not inSession ? "WAITING" :
     dominance > dominanceThreshold ? "BUYERS" :
     dominance < -dominanceThreshold ? "SELLERS" :
     "BALANCED"

controlColor =
     control == "BUYERS" ? color.lime :
     control == "SELLERS" ? color.red :
     color.gray

strength =
     absDominance >= 35 ? "EXTREME" :
     absDominance >= 25 ? "STRONG" :
     absDominance >= 15 ? "MEDIUM" :
     absDominance >= dominanceThreshold ? "WEAK" :
     "NEUTRAL"

openingText =
     openingSide == 1 ? "BULL OPEN" :
     openingSide == -1 ? "BEAR OPEN" :
     "NO OPEN BIAS"

challengeText =
     openingSide == 1 and bearChallenge ? "BEAR CHALLENGE" :
     openingSide == -1 and bullChallenge ? "BULL CHALLENGE" :
     "NO VALID CHALLENGE"

//------------------------------------------------------------------------------
// Opening Delta - Dominance Flip Alert Logic
//------------------------------------------------------------------------------
buyDominanceFlip = inSession and dominance[1] < 0 and dominance >= flipThreshold
sellDominanceFlip = inSession and dominance[1] > 0 and dominance <= -flipThreshold

//------------------------------------------------------------------------------
// Visual Inputs
//------------------------------------------------------------------------------
groupVisual = "Visual"

showBackground = input.bool(true, "Show control background", group = groupVisual)
showTable = input.bool(true, "Show table", group = groupVisual)
tablePositionInput = input.string("Top Right", "Table position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = groupVisual)
showOpeningLabel = input.bool(true, "Show opening threshold label", group = groupVisual)
showSuperiorLabels = input.bool(true, "Show superior delta labels", group = groupVisual)
labelOffsetPct = input.float(0.10, "Label vertical offset %", minval = 0.0, maxval = 5.0, step = 0.05, group = groupVisual)

tablePosition =
     tablePositionInput == "Top Right"    ? position.top_right :
     tablePositionInput == "Top Left"     ? position.top_left :
     tablePositionInput == "Bottom Right" ? position.bottom_right :
     position.bottom_left

//------------------------------------------------------------------------------
// Hybrid Signal Inputs
//------------------------------------------------------------------------------
groupHybrid = "Hybrid Signals"

showHybridSignals = input.bool(true, "Show BUY/SELL arrows", group = groupHybrid)
hybridRequireCloseOutsideZone = input.bool(true, "Require close outside zone after rejection", group = groupHybrid)
hybridUseUntestedZonesOnly = input.bool(true, "Use untested zones only", group = groupHybrid)
hybridUseCurrentDelta = input.bool(true, "Confirm with current delta direction", group = groupHybrid)
hybridBlockOppositeControl = input.bool(true, "Block signal when strength favors opposite side", group = groupHybrid)
hybridUseDominanceControl = input.bool(true, "Confirm with dominance control", group = groupHybrid)
hybridUseDominanceFlip = input.bool(true, "Confirm with dominance flip", group = groupHybrid)
hybridUseChallenge = input.bool(true, "Confirm with opening threshold challenge", group = groupHybrid)
hybridUseSuperiorDelta = input.bool(true, "Confirm with superior delta", group = groupHybrid)
hybridCooldownBars = input.int(5, "Signal cooldown bars", minval = 0, maxval = 200, group = groupHybrid)

//------------------------------------------------------------------------------
// Supply/Demand Types
//------------------------------------------------------------------------------
type bin
    float lvl
    float prev
    float sum
    float prev_sum
    float csum
    float avg
    bool isreached

//------------------------------------------------------------------------------
// Supply/Demand Data
//------------------------------------------------------------------------------
get_hlv()=> [high, low, volume]
[h, l, v] = request.security_lower_tf(syminfo.tickerid, tf, get_hlv())

var float dayMax = na
var float dayMin = na
var float dayVol = 0.
var int dayStart = na

var sampleHighs = array.new_float()
var sampleLows = array.new_float()
var sampleVols = array.new_float()

var zoneBoxes = array.new_box()
var zoneAvgLines = array.new_line()
var zoneWavgLines = array.new_line()
var zoneLvnLines = array.new_line()
var zoneLabels = array.new_label()
var zoneTops = array.new_float()
var zoneBtms = array.new_float()
var zoneIsSupply = array.new_bool()
var zoneCreatedBars = array.new_int()
var zoneRetested = array.new_bool()
var zoneBaseColors = array.new_color()
var zoneBorderColors = array.new_color()
var zoneAreaTransps = array.new_int()

sdNewDay = nz(ta.change(time("D")), 0) != 0

//------------------------------------------------------------------------------
// Supply/Demand Helpers
//------------------------------------------------------------------------------
f_trim_objects() =>
    maxZones = maxDays * 2
    while array.size(zoneTops) > maxZones and array.includes(zoneRetested, true)
        removeIdx = array.indexof(zoneRetested, true)
        oldBox = array.remove(zoneBoxes, removeIdx)
        oldAvg = array.remove(zoneAvgLines, removeIdx)
        oldWavg = array.remove(zoneWavgLines, removeIdx)
        oldLvn = array.remove(zoneLvnLines, removeIdx)
        oldLabel = array.remove(zoneLabels, removeIdx)

        if not na(oldBox)
            box.delete(oldBox)
        if not na(oldAvg)
            line.delete(oldAvg)
        if not na(oldWavg)
            line.delete(oldWavg)
        if not na(oldLvn)
            line.delete(oldLvn)
        if not na(oldLabel)
            label.delete(oldLabel)

        array.remove(zoneTops, removeIdx)
        array.remove(zoneBtms, removeIdx)
        array.remove(zoneIsSupply, removeIdx)
        array.remove(zoneCreatedBars, removeIdx)
        array.remove(zoneRetested, removeIdx)
        array.remove(zoneBaseColors, removeIdx)
        array.remove(zoneBorderColors, removeIdx)
        array.remove(zoneAreaTransps, removeIdx)

f_set_zone_visible(_idx, _visible) =>
    bx = array.get(zoneBoxes, _idx)
    avgLine = array.get(zoneAvgLines, _idx)
    wavgLine = array.get(zoneWavgLines, _idx)
    lvnLine = array.get(zoneLvnLines, _idx)
    lb = array.get(zoneLabels, _idx)
    baseColor = array.get(zoneBaseColors, _idx)
    borderColor = array.get(zoneBorderColors, _idx)
    areaTransp = array.get(zoneAreaTransps, _idx)

    if not na(bx)
        box.set_border_color(bx, _visible ? borderColor : color.new(borderColor, 100))
        box.set_bgcolor(bx, _visible ? color.new(baseColor, areaTransp) : color.new(baseColor, 100))

    if not na(avgLine)
        line.set_color(avgLine, _visible ? baseColor : color.new(baseColor, 100))

    if not na(wavgLine)
        line.set_color(wavgLine, _visible ? baseColor : color.new(baseColor, 100))

    if not na(lvnLine)
        line.set_color(lvnLine, _visible ? lvnCss : color.new(lvnCss, 100))

    if not na(lb)
        label.set_color(lb, _visible ? color.new(borderColor, 15) : color.new(borderColor, 100))
        label.set_textcolor(lb, _visible ? color.white : color.new(color.white, 100))

f_refresh_zones() =>
    zoneCount = array.size(zoneTops)

    if zoneCount > 0
        for i = 0 to zoneCount - 1
            top = array.get(zoneTops, i)
            btm = array.get(zoneBtms, i)
            created = array.get(zoneCreatedBars, i)
            wasRetested = array.get(zoneRetested, i)

            closeBrokeZone = array.get(zoneIsSupply, i) ? close > top : close < btm

            if hideRetested and not wasRetested and bar_index > created and closeBrokeZone
                array.set(zoneRetested, i, true)

        for i = 0 to zoneCount - 1
            top = array.get(zoneTops, i)
            btm = array.get(zoneBtms, i)
            isSupplyZone = array.get(zoneIsSupply, i)
            isRetested = array.get(zoneRetested, i)
            onCorrectSide = not correctSideOnly or (isSupplyZone ? close <= top : close >= btm)
            thisDistance = isSupplyZone ? (close < btm ? btm - close : 0) : (close > top ? close - top : 0)
            isCandidate = not isRetested and onCorrectSide
            closerCount = 0

            if isCandidate
                for j = 0 to zoneCount - 1
                    if j != i
                        otherTop = array.get(zoneTops, j)
                        otherBtm = array.get(zoneBtms, j)
                        otherSupply = array.get(zoneIsSupply, j)
                        otherRetested = array.get(zoneRetested, j)
                        otherCorrectSide = not correctSideOnly or (otherSupply ? close <= otherTop : close >= otherBtm)
                        otherDistance = otherSupply ? (close < otherBtm ? otherBtm - close : 0) : (close > otherTop ? close - otherTop : 0)
                        otherCandidate = not otherRetested and otherSupply == isSupplyZone and otherCorrectSide

                        if otherCandidate and otherDistance < thisDistance
                            closerCount += 1

            maxVisible = isSupplyZone ? nearestSupply : nearestDemand
            visible = isCandidate and closerCount < maxVisible
            f_set_zone_visible(i, visible)

            if extendZones
                bx = array.get(zoneBoxes, i)
                avgLine = array.get(zoneAvgLines, i)
                wavgLine = array.get(zoneWavgLines, i)
                lvnLine = array.get(zoneLvnLines, i)
                lb = array.get(zoneLabels, i)

                if not na(bx)
                    box.set_right(bx, bar_index)
                if not na(avgLine)
                    line.set_x2(avgLine, bar_index)
                if not na(wavgLine)
                    line.set_x2(wavgLine, bar_index)
                if not na(lvnLine)
                    line.set_x2(lvnLine, bar_index)
                if not na(lb)
                    label.set_x(lb, bar_index)

f_draw_zone(_isSupply, _x1, _x2, _top, _btm, _avg, _wavg, _lvn, _hasLvn, _lvnNearWeighted, _score) =>
    baseColor = _isSupply ? supplyCss : demandCss
    enabled = _isSupply ? showSupply : showDemand
    showArea = _isSupply ? supplyArea : demandArea
    showAverage = _isSupply ? supplyAvg : demandAvg
    showWeighted = _isSupply ? supplyWavg : demandWavg
    shouldDraw = enabled and (not showOnlyLvnZones or _hasLvn)

    if shouldDraw
        borderColor = _score >= 4 ? strongCss : baseColor
        areaTransp = _score >= 4 ? 78 : _score >= 3 ? 84 : 90
        box bx = na
        line avgLine = na
        line wavgLine = na
        line lvnLine = na
        label lb = na

        if showArea
            bx := box.new(_x1, _top, _x2, _btm, borderColor, bgcolor = color.new(baseColor, areaTransp))

        if showAverage
            avgLine := line.new(_x1, _avg, _x2, _avg, color = baseColor, width = 1)

        if showWeighted and not na(_wavg)
            wavgLine := line.new(_x1, _wavg, _x2, _wavg, color = baseColor, style = line.style_dashed, width = 1)

        if showLvnLines and _hasLvn
            lvnWidth = _lvnNearWeighted ? 2 : 1
            lvnLine := line.new(_x1, _lvn, _x2, _lvn, color = lvnCss, style = line.style_dotted, width = lvnWidth)

        if showScoreLabels
            txt = (_isSupply ? "S" : "D") + " " + str.tostring(_score) + "/5" + (_hasLvn ? " LVN" : "")
            y = _isSupply ? _top : _btm
            st = _isSupply ? label.style_label_down : label.style_label_up
            lb := label.new(_x2, y, txt, color = color.new(borderColor, 15), textcolor = color.white, style = st, size = size.tiny)

        array.push(zoneBoxes, bx)
        array.push(zoneAvgLines, avgLine)
        array.push(zoneWavgLines, wavgLine)
        array.push(zoneLvnLines, lvnLine)
        array.push(zoneLabels, lb)
        array.push(zoneTops, _top)
        array.push(zoneBtms, _btm)
        array.push(zoneIsSupply, _isSupply)
        array.push(zoneCreatedBars, _x2)
        array.push(zoneRetested, false)
        array.push(zoneBaseColors, baseColor)
        array.push(zoneBorderColors, borderColor)
        array.push(zoneAreaTransps, areaTransp)

f_best_lvn_in_zone(_top, _btm, _wavg, _rowVols, _rangeMin, _step) =>
    float bestPrice = na
    float bestDist = na
    bool hasLvn = false
    bool nearWeighted = false
    maxVol = array.max(_rowVols)

    if maxVol > 0
        for row = 0 to array.size(_rowVols) - 1
            rowVol = array.get(_rowVols, row)
            rowRatio = rowVol / maxVol
            rowPrice = _rangeMin + (row + .5) * _step
            inZone = rowPrice <= _top and rowPrice >= _btm

            if inZone and rowRatio <= vpLVT
                hasLvn := true
                refPrice = na(_wavg) ? math.avg(_top, _btm) : _wavg
                dist = math.abs(rowPrice - refPrice)

                if na(bestDist) or dist < bestDist
                    bestDist := dist
                    bestPrice := rowPrice

    zoneSize = math.abs(_top - _btm)
    nearWeighted := hasLvn and zoneSize > 0 and bestDist <= zoneSize * lvnNearPct
    [hasLvn, bestPrice, nearWeighted]

f_process_day(_x1, _x2, _rangeMax, _rangeMin, _totalVol, _refClose) =>
    sampleCount = array.size(sampleVols)

    if sampleCount > 0 and _totalVol > 0 and _rangeMax > _rangeMin and _x2 > _x1
        step = (_rangeMax - _rangeMin) / div
        profileStep = (_rangeMax - _rangeMin) / rpNR
        rowVols = array.new_float(rpNR, 0.)

        for j = 0 to sampleCount - 1
            sHigh = array.get(sampleHighs, j)
            sLow = array.get(sampleLows, j)
            sVol = array.get(sampleVols, j)
            sRange = math.max(sHigh - sLow, syminfo.mintick)

            for row = 0 to rpNR - 1
                rowLow = _rangeMin + row * profileStep
                rowHigh = rowLow + profileStep
                rowMid = rowLow + profileStep * .5
                overlap = math.max(0., math.min(sHigh, rowHigh) - math.max(sLow, rowLow))
                share = sHigh == sLow ? (sHigh >= rowLow and sHigh < rowHigh ? 1. : 0.) : overlap / sRange
                if share > 0
                    rowValue = vpSRC == "Money Flow" ? sVol * share * rowMid : sVol * share
                    array.set(rowVols, row, array.get(rowVols, row) + rowValue)

        supply = bin.new(_rangeMax, _rangeMax, 0, 0, 0, 0, false)
        demand = bin.new(_rangeMin, _rangeMin, 0, 0, 0, 0, false)
        float supplyWavg = na
        float demandWavg = na
        float supplyTop = na
        float supplyBtm = na
        float demandTop = na
        float demandBtm = na

        for i = 0 to div - 1
            supply.lvl -= step
            demand.lvl += step

            for j = 0 to sampleCount - 1
                sHigh = array.get(sampleHighs, j)
                sLow = array.get(sampleLows, j)
                sVol = array.get(sampleVols, j)

                supply.sum += sHigh > supply.lvl and sHigh < supply.prev ? sVol : 0
                supply.avg += supply.lvl * (supply.sum - supply.prev_sum)
                supply.csum += supply.sum - supply.prev_sum
                supply.prev_sum := supply.sum

                demand.sum += sLow < demand.lvl and sLow > demand.prev ? sVol : 0
                demand.avg += demand.lvl * (demand.sum - demand.prev_sum)
                demand.csum += demand.sum - demand.prev_sum
                demand.prev_sum := demand.sum

                if supply.sum / _totalVol * 100 > per and not supply.isreached
                    supplyTop := _rangeMax
                    supplyBtm := supply.lvl
                    supplyWavg := supply.csum > 0 ? supply.avg / supply.csum : na
                    supply.isreached := true

                if demand.sum / _totalVol * 100 > per and not demand.isreached
                    demandTop := demand.lvl
                    demandBtm := _rangeMin
                    demandWavg := demand.csum > 0 ? demand.avg / demand.csum : na
                    demand.isreached := true

                if supply.isreached and demand.isreached
                    break

            if supply.isreached and demand.isreached
                break

            supply.prev := supply.lvl
            demand.prev := demand.lvl

        if supply.isreached
            supplyAvgPrice = math.avg(supplyTop, supplyBtm)
            [sHasLvn, sLvnPrice, sNearWavg] = f_best_lvn_in_zone(supplyTop, supplyBtm, supplyWavg, rowVols, _rangeMin, profileStep)
            sScore = 1 + (sHasLvn ? 2 : 0) + (sNearWavg ? 1 : 0) + (_refClose < supplyBtm ? 1 : 0)
            f_draw_zone(true, _x1, _x2, supplyTop, supplyBtm, supplyAvgPrice, supplyWavg, sLvnPrice, sHasLvn, sNearWavg, sScore)

        if demand.isreached
            demandAvgPrice = math.avg(demandTop, demandBtm)
            [dHasLvn, dLvnPrice, dNearWavg] = f_best_lvn_in_zone(demandTop, demandBtm, demandWavg, rowVols, _rangeMin, profileStep)
            dScore = 1 + (dHasLvn ? 2 : 0) + (dNearWavg ? 1 : 0) + (_refClose > demandTop ? 1 : 0)
            f_draw_zone(false, _x1, _x2, demandTop, demandBtm, demandAvgPrice, demandWavg, dLvnPrice, dHasLvn, dNearWavg, dScore)

        f_trim_objects()

f_store_current_bar() =>
    count = v.size()
    addedVol = 0.

    if count > 0
        for k = 0 to count - 1
            sVol = v.get(k)
            array.push(sampleHighs, h.get(k))
            array.push(sampleLows, l.get(k))
            array.push(sampleVols, sVol)
            addedVol += sVol
    else
        array.push(sampleHighs, high)
        array.push(sampleLows, low)
        array.push(sampleVols, volume)
        addedVol += volume

    addedVol

//------------------------------------------------------------------------------
// Hybrid Signal Helpers
//------------------------------------------------------------------------------
buyDeltaConfirm = inSession and (
     (hybridUseCurrentDelta and delta > 0) or
     (hybridUseDominanceControl and control == "BUYERS") or
     (hybridUseDominanceFlip and buyDominanceFlip) or
     (hybridUseChallenge and bullChallenge) or
     (hybridUseSuperiorDelta and superiorBullDelta)
 )

sellDeltaConfirm = inSession and (
     (hybridUseCurrentDelta and delta < 0) or
     (hybridUseDominanceControl and control == "SELLERS") or
     (hybridUseDominanceFlip and sellDominanceFlip) or
     (hybridUseChallenge and bearChallenge) or
     (hybridUseSuperiorDelta and superiorBearDelta)
 )

buyOppositeControlBlocked = hybridBlockOppositeControl and control == "SELLERS"
sellOppositeControlBlocked = hybridBlockOppositeControl and control == "BUYERS"

f_zone_rejection(_isSupply) =>
    bool found = false
    float y = na
    zoneCount = array.size(zoneTops)

    if zoneCount > 0
        for i = 0 to zoneCount - 1
            isTargetSide = array.get(zoneIsSupply, i) == _isSupply
            enabledSide = _isSupply ? showSupply : showDemand

            if isTargetSide and enabledSide
                top = array.get(zoneTops, i)
                btm = array.get(zoneBtms, i)
                created = array.get(zoneCreatedBars, i)
                isRetested = array.get(zoneRetested, i)
                canUseZone = bar_index > created and (not hybridUseUntestedZonesOnly or not isRetested)
                touched = canUseZone and high >= btm and low <= top
                closeOutside = _isSupply ? close < btm : close > top
                directionalReject = _isSupply ? close < open and upperWickRatio > 0 : close > open and lowerWickRatio > 0
                rejected = touched and (hybridRequireCloseOutsideZone ? closeOutside : directionalReject)

                if rejected
                    found := true
                    y := _isSupply ? high : low

    [found, y]

//------------------------------------------------------------------------------
// Opening Delta Visuals
//------------------------------------------------------------------------------
bgTransp =
     absDominance >= 35 ? 84 :
     absDominance >= 25 ? 88 :
     absDominance >= 15 ? 91 :
     94

bgcolor(showBackground and inSession ? color.new(controlColor, bgTransp) : na)

labelOffset = close * labelOffsetPct / 100.0

if showOpeningLabel and firstSessionBar
    openingLabelY = delta > 0 ? low - labelOffset : high + labelOffset

    openingLabelStyle =
         delta > 0 ? label.style_label_up :
         delta < 0 ? label.style_label_down :
         label.style_label_left

    openingLabelColor =
         delta > 0 ? color.new(color.lime, 0) :
         delta < 0 ? color.new(color.red, 0) :
         color.new(color.gray, 0)

    label.new(
         bar_index,
         openingLabelY,
         "Opening Delta\n" + str.tostring(openingSessionDelta, format.volume),
         style = openingLabelStyle,
         textcolor = color.white,
         color = openingLabelColor,
         size = size.small
     )

if showSuperiorLabels and superiorDelta
    superiorLabelY = delta > 0 ? low - labelOffset : high + labelOffset

    superiorLabelStyle =
         delta > 0 ? label.style_label_up :
         delta < 0 ? label.style_label_down :
         label.style_label_left

    superiorLabelColor =
         delta > 0 ? color.new(color.lime, 0) :
         delta < 0 ? color.new(color.red, 0) :
         color.new(color.gray, 0)

    superiorSideText = delta > 0 ? "Superior Bull Delta" : "Superior Bear Delta"

    label.new(
         bar_index,
         superiorLabelY,
         superiorSideText + "\n" +
         str.tostring(delta, format.volume) + "\n" +
         "Q " + str.tostring(candleQuality, "#.##") + "  RVOL " + str.tostring(rvol, "#.##") + "x",
         style = superiorLabelStyle,
         textcolor = color.white,
         color = superiorLabelColor,
         size = size.small
     )

//------------------------------------------------------------------------------
// Supply/Demand Main
//------------------------------------------------------------------------------
if na(dayStart)
    dayStart := bar_index
    dayMax := high
    dayMin := low

if sdNewDay and array.size(sampleVols) > 0
    f_process_day(dayStart, bar_index, dayMax, dayMin, dayVol, close[1])

    dayStart := bar_index
    dayMax := high
    dayMin := low
    dayVol := 0.
    array.clear(sampleHighs)
    array.clear(sampleLows)
    array.clear(sampleVols)

dayMax := na(dayMax) ? high : math.max(dayMax, high)
dayMin := na(dayMin) ? low : math.min(dayMin, low)
dayVol += f_store_current_bar()

[demandRejected, demandSignalY] = f_zone_rejection(false)
[supplyRejected, supplySignalY] = f_zone_rejection(true)

var int lastBuySignalBar = na
var int lastSellSignalBar = na

buyCooldownOk = na(lastBuySignalBar) or bar_index - lastBuySignalBar > hybridCooldownBars
sellCooldownOk = na(lastSellSignalBar) or bar_index - lastSellSignalBar > hybridCooldownBars

buySignal = showHybridSignals and demandRejected and buyDeltaConfirm and not buyOppositeControlBlocked and buyCooldownOk
sellSignal = showHybridSignals and supplyRejected and sellDeltaConfirm and not sellOppositeControlBlocked and sellCooldownOk

if buySignal
    lastBuySignalBar := bar_index

if sellSignal
    lastSellSignalBar := bar_index

plotshape(buySignal, title = "BUY Demand Rebound Confirmed", text = "BUY", style = shape.labelup, location = location.belowbar, color = color.new(color.lime, 0), textcolor = color.white, size = size.small)
plotshape(sellSignal, title = "SELL Supply Rebound Confirmed", text = "SELL", style = shape.labeldown, location = location.abovebar, color = color.new(color.red, 0), textcolor = color.white, size = size.small)

f_refresh_zones()

//------------------------------------------------------------------------------
// Table
//------------------------------------------------------------------------------
var table t = na
var string lastTablePositionInput = ""

if na(t) or tablePositionInput != lastTablePositionInput
    t := table.new(tablePosition, 2, 9, border_width = 1)
    lastTablePositionInput := tablePositionInput

if showTable and barstate.islast
    table.cell(t, 0, 0, "GLOBAL CONTROL", text_color = color.white, bgcolor = color.black)
    table.cell(t, 1, 0, control, text_color = color.white, bgcolor = controlColor)

    table.cell(t, 0, 1, "Strength", text_color = color.white, bgcolor = color.black)
    table.cell(t, 1, 1, strength, text_color = color.white, bgcolor = color.new(controlColor, 45))

    table.cell(t, 0, 2, "Buyers", text_color = color.white, bgcolor = color.new(color.lime, 70))
    table.cell(t, 1, 2, str.tostring(bullPct, "#.##") + "%", text_color = color.white, bgcolor = color.new(color.lime, 70))

    table.cell(t, 0, 3, "Sellers", text_color = color.white, bgcolor = color.new(color.red, 70))
    table.cell(t, 1, 3, str.tostring(bearPct, "#.##") + "%", text_color = color.white, bgcolor = color.new(color.red, 70))

    table.cell(t, 0, 4, "Dominance", text_color = color.white, bgcolor = color.black)
    table.cell(t, 1, 4, str.tostring(dominance, "#.##") + "%", text_color = color.white, bgcolor = color.new(controlColor, 55))

    table.cell(t, 0, 5, "Opening Bias", text_color = color.white, bgcolor = color.black)
    table.cell(t, 1, 5, openingText, text_color = color.white, bgcolor = openingSide == 1 ? color.new(color.lime, 45) : openingSide == -1 ? color.new(color.red, 45) : color.gray)

    table.cell(t, 0, 6, "Opening Delta", text_color = color.white, bgcolor = color.black)
    table.cell(t, 1, 6, str.tostring(openingThreshold, format.volume), text_color = color.white, bgcolor = color.new(color.gray, 60))

    table.cell(t, 0, 7, "Challenge", text_color = color.white, bgcolor = color.black)
    table.cell(t, 1, 7, challengeText, text_color = color.white, bgcolor = challengeText == "NO VALID CHALLENGE" ? color.new(color.gray, 60) : color.orange)

    table.cell(t, 0, 8, "Last Delta / RVOL", text_color = color.white, bgcolor = color.black)
    table.cell(t, 1, 8, str.tostring(delta, format.volume) + " / " + str.tostring(rvol, "#.##") + "x", text_color = color.white, bgcolor = color.new(controlColor, 65))

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------
alertcondition(buySignal, "BUY SD + Opening Delta Confirmed", "Demand rebound confirmed by Opening Delta.")
alertcondition(sellSignal, "SELL SD + Opening Delta Confirmed", "Supply rejection confirmed by Opening Delta.")

alertcondition(buyDominanceFlip, "Buy Dominance Flip", "Dominance flipped from sellers to buyers.")
alertcondition(sellDominanceFlip, "Sell Dominance Flip", "Dominance flipped from buyers to sellers.")

alertcondition(bearChallenge, "Bear Challenge", "Bear delta challenged the opening bullish threshold.")
alertcondition(bullChallenge, "Bull Challenge", "Bull delta challenged the opening bearish threshold.")

alertcondition(superiorBullDelta, "Superior Bull Delta", "A superior bullish delta appeared above the opening threshold.")
alertcondition(superiorBearDelta, "Superior Bear Delta", "A superior bearish delta appeared above the opening threshold.")
alertcondition(superiorDelta, "Superior Delta", "A superior quality delta appeared above the opening threshold.")

//------------------------------------------------------------------------------
// Volume Check
//------------------------------------------------------------------------------
var float cumVol = 0.0
cumVol += nz(volume)

if barstate.islast and cumVol == 0
    runtime.error("The data vendor doesn't provide volume data for this symbol.")
````
