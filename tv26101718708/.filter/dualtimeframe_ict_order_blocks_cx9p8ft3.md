# Dual-Timeframe ICT Order Blocks

- url: https://www.tradingview.com/script/CX9P8Ft3-Dual-Timeframe-ICT-Order-Blocks/
- type: indicator
- pine_id: PUB;a528bf07d92f48cf88c9085c0433b7a2
- version: 17.0

## Description

Dual-Timeframe ICT & Volumized Order Blocks is an overlay indicator designed to identify, display, and manage ICT-style bullish and bearish order block zones across one or two configurable timeframes.

The script focuses on market structure context, liquidity-driven order block formation, optional volume information, and clean multi-timeframe visualization. It is built for traders who want to see where recent institutional-style displacement zones may exist, while keeping primary and secondary timeframe zones visually distinct.

[b]Core Features[/b]

[b]Primary Order Blocks[/b]
The primary order block engine can run on the chart timeframe or on a custom timeframe selected in the settings. Bullish and bearish zones are detected from confirmed swing structure and are filtered by size using an ATR-based threshold to avoid excessively large zones.

[b]Secondary Timeframe Order Blocks[/b]
An optional secondary timeframe can be enabled to display another layer of order block context on the same chart. This is useful for combining lower-timeframe execution with higher-timeframe structure, or for comparing two separate intraday/session perspectives.

Primary zones use the default bullish/bearish colors, while secondary zones use a contrasting blue/yellow palette so the two timeframe layers are easy to distinguish at a glance.

[b]Liquidity Sweep Requirement[/b]
The indicator includes an optional liquidity sweep filter. When enabled, a bullish order block requires a prior sell-side liquidity sweep, and a bearish order block requires a prior buy-side liquidity sweep. This helps focus the script on setups where price has first taken liquidity before forming an order block.

[b]Volumetric Information[/b]
Volumetric display can be enabled to show the total volume associated with each order block and a relative high/low volume balance percentage. When enabled, internal volume bars are drawn inside the zone:

- Primary timeframe volume bars use the primary bullish/bearish colors.
- Secondary timeframe volume bars use the secondary blue/yellow colors.
- Historic or breaker zones are displayed with a faded appearance.

[b]Zone Invalidation[/b]
Zones can be invalidated by either wick or close, depending on the selected setting. When a zone is invalidated, it can either be hidden or shown as a historic/breaker zone if [i]Show Historic Zones[/i] is enabled.

[b]Zone Count Control[/b]
Both the primary and secondary timeframe layers have independent zone count settings:

- One
- Low
- Medium
- High

Higher settings show more historical zones, while lower settings keep the chart cleaner and may improve responsiveness.

[b]Optional Zone Combining[/b]
The script can optionally combine overlapping zones of the same effective direction and timeframe. This can help reduce clutter in dense areas of price action. Combining is disabled by default for better performance and a more transparent view of individual zones, but it can be enabled from the settings.

[b]Discount / Premium Range[/b]
An optional Discount / Premium overlay can be enabled to display a dealing range based on recent swing highs and lows. The range includes premium, discount, and equilibrium levels, and can be calculated on the chart timeframe or a custom higher timeframe.

[b]Swing Point Display[/b]
For additional context, the script can show confirmed swing highs and swing lows used by the order block detection logic.

[b]Performance-Oriented Defaults[/b]
The default configuration is designed to keep the chart responsive:

- Historic zones are off by default.
- Volumetric information is off by default.
- Zone combining is off by default.
- Secondary timeframe display is off by default.

These features can all be enabled manually if you want more detail or broader context.

[b]Suggested Usage[/b]

Use the primary timeframe for the main execution or analysis timeframe. Enable the secondary timeframe when you want to overlay higher-timeframe or alternate-timeframe order blocks. For example, a trader may use the chart timeframe for active entries and enable a higher secondary timeframe to identify broader reaction zones.

The liquidity sweep requirement can be useful for filtering out weaker order blocks and focusing on zones formed after a liquidity event. If you prefer more zones and broader structure, you can disable this requirement.

[b]Important Notes[/b]

This script is an analytical tool and should not be used as a standalone trading system. Order blocks can fail, repainting-style expectations should be avoided, and zones should be interpreted alongside market structure, trend context, liquidity, session timing, and risk management.

The indicator is intended to help visualize potential areas of interest, not to provide buy or sell signals.

[b]Summary[/b]

Dual-Timeframe ICT & Volumized Order Blocks provides a clean and configurable way to monitor ICT-style order blocks across two timeframes, with optional liquidity filtering, volumetric zone information, historic breaker visualization, zone combining, and discount/premium context.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Janvitos

//@version=6
const bool DEBUG = false
const int maxBoxesCount = 500
const float overlapThresholdPercentage = 0
const int maxDistanceToLastBar = 1750 // Affects Running Time
const int maxOrderBlocks = 30
const int maxCombinationPasses = 3
const int maxCombinedOrderBlocks = 60
const int maxOBSearchBars = 500

indicator(title = 'Dual-Timeframe ICT Order Blocks', overlay = true, max_boxes_count = maxBoxesCount, max_labels_count = maxBoxesCount, max_lines_count = maxBoxesCount, max_bars_back = 5000, behind_chart = true)

showInvalidated = input.bool(false, "Breaker Blocks", group = "Visibility", display = display.none)
OBsEnabled = true
orderBlockVolumetricInfo = input.bool(false, "Volumetric Info", group = "Visibility", display = display.none)
showSwingPoints = input.bool(false, "Swing Highs / Lows", tooltip="Show confirmed swing highs and swing lows used for order block detection.", group = "Visibility", display = display.none)
entrySignalsMode = input.string("Hidden", "Entry Signals", options = ["Historical", "Latest", "Hidden"], tooltip = "Show long and short signals when price retests the middle 50% of an active order block.", group = "Visibility", display = display.none)
swingLength = input.int(10, 'Swing Length', minval = 3, tooltip="Swing length controls pivot-based Swing detection, liquidity sweep lookback, and Discount / Premium zones.",group = "Order Block Filtering", display = display.none)
obEndMethod = input.string("Wick", "Zone Invalidation", options = ["Wick", "Close"],  group = "Order Block Filtering", display = display.none)
requireFVGConfirmation = input.bool(false, "Require FVG Confirmation", tooltip="Require the swing break candle to create a fair value gap before forming an order block.", group = "Order Block Filtering", display = display.none)
combineOBs = input.bool(false, "Combine Zones", group = "Order Block Filtering", display = display.none)
requireLiquiditySweep = input.bool(true, "Require Liquidity Sweep", tooltip="Require the selected order block reference candle to sweep prior confirmed opposing-side swing liquidity before forming an order block.", group = "Order Block Filtering", display = display.none)
multiCandleOrderBlocks = input.bool(false, "Multi-Candle OBs", tooltip="When enabled, include the selected liquidity/extreme candle plus the full range back to the nearest prior opposing swing.", group = "Order Block Filtering", display = display.none)
allowOversizedOrderBlocks = input.bool(false, "Allow Oversized OBs", tooltip="When disabled, oversized multi-candle zones are shrunk before rejecting order blocks that remain larger than 3.5 ATR. When enabled, oversized order blocks are allowed.", group = "Order Block Filtering", display = display.none)
constrainLargeOrderBlocks = not allowOversizedOrderBlocks
maxATRMult = DEBUG ? input.float(3.5,"Max Atr Multiplier", group = "Order Block Filtering") : 3.5

orderBlockTimeframe = input.timeframe("", "Timeframe", tooltip = "Leave empty to use the chart timeframe, or choose a custom timeframe for primary order block detection.", group = "Primary Order Blocks", display = display.none)
zoneCount = input.string("Low", 'Zone Count', options = ["High", "Medium", "Low", "One"], tooltip = "Number of primary Order Block Zones to be rendered. Higher options will result in older Order Blocks shown.",  group = "Primary Order Blocks", display = display.none)

secondaryOrderBlockTimeframeEnabled = input.bool(false, "Secondary Timeframe", group = "Secondary Order Blocks", display = display.none)
secondaryOrderBlockTimeframe = input.timeframe("", "Timeframe", tooltip = "Leave empty to use the chart timeframe, or choose a custom timeframe for secondary order block detection.", group = "Secondary Order Blocks", display = display.none)
secondaryZoneCount = input.string("Low", 'Zone Count', options = ["High", "Medium", "Low", "One"], tooltip = "Number of secondary Order Block Zones to be rendered. Higher options will result in older Order Blocks shown.",  group = "Secondary Order Blocks", display = display.none)

showDiscountPremiumZones = input.bool(false, "Discount / Premium Zones", group = "Discount / Premium", display = display.none)
discountPremiumTimeframe = input.timeframe("", "Timeframe", tooltip = "Leave empty to use the chart timeframe, or choose a custom higher timeframe for the dealing range.", group = "Discount / Premium", display = display.none)

bullishOrderBlocks = zoneCount == "One" ? 1 : zoneCount == "Low" ? 3 : zoneCount == "Medium" ? 5 : 10
bearishOrderBlocks = zoneCount == "One" ? 1 : zoneCount == "Low" ? 3 : zoneCount == "Medium" ? 5 : 10
secondaryBullishOrderBlocks = secondaryZoneCount == "One" ? 1 : secondaryZoneCount == "Low" ? 3 : secondaryZoneCount == "Medium" ? 5 : 10
secondaryBearishOrderBlocks = secondaryZoneCount == "One" ? 1 : secondaryZoneCount == "Low" ? 3 : secondaryZoneCount == "Medium" ? 5 : 10

timeframe1Enabled = true
timeframe1 = orderBlockTimeframe
timeframe2Enabled = secondaryOrderBlockTimeframeEnabled
timeframe2 = secondaryOrderBlockTimeframe

textColor = input.color(#ffffff80, "Text Color", group = "Style")
bullOrderBlockColor = input.color(#08998180, "Bullish", group = "Style", display = display.none)
bearOrderBlockColor = input.color(#f2364680, "Bearish", group = "Style", display = display.none)
secondaryBullOrderBlockColor = input.color(#2962ff80, "Secondary Bullish", group = "Style", display = display.none)
secondaryBearOrderBlockColor = input.color(#fdd83580, "Secondary Bearish", group = "Style", display = display.none)
extendZonesBy = DEBUG ? input.int(15, "Extend Zones", group = "Style", minval = 1, maxval = 30, inline = "ExtendZones") : 15
extendZonesDynamic = DEBUG ? input.bool(true, "Dynamic", group = "Style", inline = "ExtendZones") : true
combinedText = DEBUG ? input.bool(false, "Combined Text", group = "Style", inline = "CombinedColor") : false
volumeBarsPlace = DEBUG ? input.string("Left", "Volume Bars At", options = ["Left", "Right"], group = "Style", inline = "volumebars") : "Left"
mirrorVolumeBars = DEBUG ? input.bool(true, "Mirror Volume Bars", group = "Style", inline = "volumebars") : true

volumeBarsLeftSide = (volumeBarsPlace == "Left")
extendZonesByTime = extendZonesBy * timeframe.in_seconds(timeframe.period) * 1000
entrySignalsEnabled = entrySignalsMode != "Hidden"

atr = ta.atr(10)
confirmedPivotHigh = ta.pivothigh(high, swingLength, swingLength)
confirmedPivotLow = ta.pivotlow(low, swingLength, swingLength)

type orderBlockInfo
    float top
    float bottom
    float obVolume
    string obType
    int startTime
    int creationTime = na
    float bbVolume
    float obLowVolume
    float obHighVolume
    bool breaker
    int breakTime
    string timeframeStr
    int timeframeIndex = na
    bool disabled = false
    string combinedTimeframesStr = na
    bool combined = false
    int entryTime = na

type orderBlock
    orderBlockInfo info
    bool isRendered = false

    box orderBox = na
    box breakerBox = na

    line breakerBoxLineTop = na

    box orderBoxText = na
    box orderBoxPositive = na
    box orderBoxNegative = na

    line orderSeperator = na
    line orderTextSeperator = na

var reusableOrderBlocks = array.new<orderBlock>(0)
var entrySignalLabels = array.new<label>(0)

createOrderBlock (orderBlockInfo orderBlockInfoF) =>
    orderBlock newOrderBlock = orderBlock.new(orderBlockInfoF)
    newOrderBlock

getReusableOrderBlock (orderBlockInfo orderBlockInfoF, int slotIndex) =>
    while reusableOrderBlocks.size() <= slotIndex
        reusableOrderBlocks.push(createOrderBlock(orderBlockInfoF))
    orderBlock reusableOrderBlock = reusableOrderBlocks.get(slotIndex)
    reusableOrderBlock.info := orderBlockInfoF
    reusableOrderBlock.isRendered := false
    reusableOrderBlock

type timeframeInfo
    int index = na
    string timeframeStr = na
    bool isEnabled = false

    orderBlockInfo[] bullishOrderBlocksList = na
    orderBlockInfo[] bearishOrderBlocksList = na

newTimeframeInfo (index, timeframeStr, isEnabled) =>
    newTFInfo = timeframeInfo.new()
    newTFInfo.index := index
    newTFInfo.isEnabled := isEnabled
    newTFInfo.timeframeStr := timeframeStr
    newTFInfo.bullishOrderBlocksList := array.new<orderBlockInfo>(0)
    newTFInfo.bearishOrderBlocksList := array.new<orderBlockInfo>(0)

    newTFInfo

type obSwing
    int x = na
    int t = na
    float y = na
    float swingVolume = na
    bool crossed = false

// ____ TYPES END ____

var timeframeInfo[] timeframeInfos = array.from(newTimeframeInfo(1, timeframe1, timeframe1Enabled), newTimeframeInfo(2, timeframe2, timeframe2Enabled))
var bullishOrderBlocksList = array.new<orderBlockInfo>(0)
var bearishOrderBlocksList = array.new<orderBlockInfo>(0)
var confirmedPivotHighIndexes = array.new<int>(0)
var confirmedPivotHighPrices = array.new<float>(0)
var confirmedPivotLowIndexes = array.new<int>(0)
var confirmedPivotLowPrices = array.new<float>(0)

var allOrderBlocksList = array.new<orderBlockInfo>(0)

var float discountPremiumHigh = na
var float discountPremiumLow = na
var int discountPremiumHighTime = na
var int discountPremiumLowTime = na
var box premiumZoneBox = na
var box discountZoneBox = na
var line equilibriumLine = na
var label premiumZoneLabel = na
var label discountZoneLabel = na
var label equilibriumLabel = na

moveLine(_line, _x, _y, _x2) =>
    line.set_xy1(_line, _x,  _y)
    line.set_xy2(_line, _x2, _y)

moveBox (_box, _topLeftX, _topLeftY, _bottomRightX, _bottomRightY) =>
    box.set_lefttop(_box, _topLeftX, _topLeftY)
    box.set_rightbottom(_box, _bottomRightX, _bottomRightY)

hideBox (_box) =>
    if not na(_box)
        box.set_lefttop(_box, na, na)
        box.set_rightbottom(_box, na, na)

hideLine (_line) =>
    if not na(_line)
        line.set_xy1(_line, na, na)
        line.set_xy2(_line, na, na)

safeDeleteOrderBlock (orderBlock orderBlockF) =>
    orderBlockF.isRendered := false

    hideBox(orderBlockF.orderBox)
    hideBox(orderBlockF.breakerBox)
    hideBox(orderBlockF.orderBoxText)
    hideBox(orderBlockF.orderBoxPositive)
    hideBox(orderBlockF.orderBoxNegative)

    hideLine(orderBlockF.breakerBoxLineTop)
    hideLine(orderBlockF.orderSeperator)
    hideLine(orderBlockF.orderTextSeperator)

formatTimeframeString (formatTimeframe) =>
    timeframeF = formatTimeframe == "" ? timeframe.period : formatTimeframe

    if str.contains(timeframeF, "D") or str.contains(timeframeF, "W") or str.contains(timeframeF, "S") or str.contains(timeframeF, "M")
        timeframeF
    else
        seconds = timeframe.in_seconds(timeframeF)
        if seconds >= 3600
            hourCount = int(seconds / 3600)
            str.tostring(hourCount) + " Hour" + (hourCount > 1 ? "s" : "")
        else
            timeframeF + " Min"

colorWithTransparency (colorF, transparencyX) =>
    color.new(colorF, color.t(colorF) * transparencyX)

paleHistoricColor (colorF) =>
    color.new(colorF, 85)

createOBBox (boxColor, transparencyX = 1.0, xlocType = xloc.bar_time) =>
    box.new(na, na, na, na, text_size = size.normal, xloc = xlocType, extend = extend.none, bgcolor = colorWithTransparency(boxColor, transparencyX), text_color = textColor, text_halign = text.align_center, border_color = #00000000)

renderOrderBlock (orderBlock ob) =>
    orderBlockInfo info = ob.info
    ob.isRendered := true
    showVolumeInfo = orderBlockVolumetricInfo
    bullColor = info.timeframeIndex == 2 ? secondaryBullOrderBlockColor : bullOrderBlockColor
    bearColor = info.timeframeIndex == 2 ? secondaryBearOrderBlockColor : bearOrderBlockColor
    baseOrderColor = ob.info.obType == "Bull" ? bullColor : bearColor
    orderColor = info.breaker ? paleHistoricColor(baseOrderColor) : baseOrderColor
    positiveColor = info.breaker ? paleHistoricColor(bullColor) : bullColor
    negativeColor = info.breaker ? paleHistoricColor(bearColor) : bearColor
    historicTransparency = info.breaker ? 1.0 : 1.1

    if OBsEnabled and (showInvalidated or not info.breaker)
        if na(ob.orderBox)
            ob.orderBox := createOBBox(orderColor, historicTransparency)
        else
            box.set_bgcolor(ob.orderBox, colorWithTransparency(orderColor, historicTransparency))
        if na(ob.orderBoxText)
            ob.orderBoxText := createOBBox(color.new(color.white, 100))
        if na(ob.orderSeperator)
            ob.orderSeperator := line.new(na,na,na,na,xloc.bar_time,extend.none,textColor,line.style_dashed,1)
        else
            line.set_color(ob.orderSeperator, textColor)
        if showVolumeInfo
            if na(ob.orderBoxPositive)
                ob.orderBoxPositive := createOBBox(positiveColor)
            if na(ob.orderBoxNegative)
                ob.orderBoxNegative := createOBBox(negativeColor)
            if info.breaker
                ob.orderBoxPositive.set_bgcolor(color.new(positiveColor, 85))
                ob.orderBoxNegative.set_bgcolor(color.new(negativeColor, 85))
            else
                ob.orderBoxPositive.set_bgcolor(colorWithTransparency(positiveColor, 1.0))
                ob.orderBoxNegative.set_bgcolor(colorWithTransparency(negativeColor, 1.0))
            if na(ob.orderTextSeperator)
                ob.orderTextSeperator := line.new(na,na,na,na,xloc.bar_time,extend.none,textColor,line.style_solid,1)
            else
                line.set_color(ob.orderTextSeperator, textColor)
        else
            hideBox(ob.orderBoxPositive)
            hideBox(ob.orderBoxNegative)
            hideLine(ob.orderTextSeperator)

        zoneSize = extendZonesByTime
        if extendZonesDynamic
            zoneSize := (time + 1) - info.startTime

        startX = volumeBarsLeftSide ? info.startTime : info.startTime + zoneSize - zoneSize / 3
        maxEndX = volumeBarsLeftSide ? info.startTime + zoneSize / 3 : info.startTime + zoneSize

        endX = info.startTime + zoneSize

        if info.breaker and not na(info.breakTime) and info.breakTime < endX
            moveBox(ob.orderBox, info.startTime, info.top, math.max(info.breakTime, info.startTime), info.bottom)
        else
            moveBox(ob.orderBox, info.startTime, info.top, endX, info.bottom)
        moveBox(ob.orderBoxText, volumeBarsLeftSide ? maxEndX : info.startTime, info.top, volumeBarsLeftSide ? endX : startX, info.bottom)

        if info.breaker and not na(info.breakTime) and info.breakTime < endX
            breakX = math.max(info.breakTime, info.startTime)
            breakerColor = info.obType == "Bull" ? bearColor : bullColor
            if na(ob.breakerBox)
                ob.breakerBox := createOBBox(color.new(breakerColor, 85))
            else
                box.set_bgcolor(ob.breakerBox, color.new(breakerColor, 85))
            moveBox(ob.breakerBox, breakX, info.top, endX, info.bottom)
            if na(ob.breakerBoxLineTop)
                ob.breakerBoxLineTop := line.new(na, na, na, na, xloc.bar_time, extend.none, color.new(breakerColor, 15), line.style_dashed, 1)
            else
                line.set_color(ob.breakerBoxLineTop, color.new(breakerColor, 15))
            line.set_xy1(ob.breakerBoxLineTop, int(breakX), info.top)
            line.set_xy2(ob.breakerBoxLineTop, int(breakX), info.bottom)
        else
            hideBox(ob.breakerBox)
            hideLine(ob.breakerBoxLineTop)

        OBText = (na(ob.info.combinedTimeframesStr) ? formatTimeframeString(ob.info.timeframeStr) : ob.info.combinedTimeframesStr) + (info.breaker ? " BB" : " OB")
        volumeText = ""
        if showVolumeInfo
            percentage = int((math.min(info.obHighVolume, info.obLowVolume) / math.max(info.obHighVolume, info.obLowVolume)) * 100.0)
            volumeText := str.tostring(ob.info.obVolume, format.volume) + " (" + str.tostring(percentage) + "%)\n"
        box.set_text(ob.orderBoxText, volumeText + (combinedText and ob.info.combined ? "[Combined]\n" : "") + OBText)

        moveLine(ob.orderSeperator, info.startTime, (info.bottom + info.top) / 2, endX)

        if showVolumeInfo
            curEndXHigh = int(math.ceil((info.obHighVolume / info.obVolume) * (maxEndX - startX) + startX))
            curEndXLow = int(math.ceil((info.obLowVolume / info.obVolume) * (maxEndX - startX) + startX))

            moveBox(ob.orderBoxPositive, mirrorVolumeBars ? startX : curEndXLow, info.top, mirrorVolumeBars ? curEndXHigh : maxEndX, (info.bottom + info.top) / 2)
            box.set_text(ob.orderBoxPositive, "")

            moveBox(ob.orderBoxNegative, mirrorVolumeBars ? startX : curEndXHigh, info.bottom, mirrorVolumeBars ? curEndXLow : maxEndX, (info.bottom + info.top) / 2)
            box.set_text(ob.orderBoxNegative, "")

            line.set_xy1(ob.orderTextSeperator, volumeBarsLeftSide ? maxEndX : startX, info.top)
            line.set_xy2(ob.orderTextSeperator, volumeBarsLeftSide ? maxEndX : startX, info.bottom)
    else
        safeDeleteOrderBlock(ob)

findOBSwings(len) =>
    var obSwing top = obSwing.new(na, na, na)
    var obSwing bottom = obSwing.new(na, na, na)
    bool swingHighFound = false
    bool swingLowFound = false

    if not na(confirmedPivotHigh)
        top := obSwing.new(bar_index[len], time[len], confirmedPivotHigh, volume[len])
        swingHighFound := true

    if not na(confirmedPivotLow)
        bottom := obSwing.new(bar_index[len], time[len], confirmedPivotLow, volume[len])
        swingLowFound := true

    [top, bottom, swingHighFound, swingLowFound]

findDiscountPremiumRange(len) =>
    var float rangeHigh = na
    var float rangeLow = na
    var int rangeHighTime = na
    var int rangeLowTime = na

    if not na(confirmedPivotHigh)
        rangeHigh := confirmedPivotHigh
        rangeHighTime := time[len]

    if not na(confirmedPivotLow)
        rangeLow := confirmedPivotLow
        rangeLowTime := time[len]

    [rangeHigh, rangeLow, rangeHighTime, rangeLowTime]

getDiscountPremiumRange () =>
    activeTimeframe = discountPremiumTimeframe == "" ? timeframe.period : discountPremiumTimeframe
    if timeframe.in_seconds(activeTimeframe) == timeframe.in_seconds(timeframe.period)
        findDiscountPremiumRange(swingLength)
    else
        request.security(syminfo.tickerid, activeTimeframe, findDiscountPremiumRange(swingLength))

hasDiscountPremiumRange () =>
    not na(discountPremiumHigh) and not na(discountPremiumLow) and not na(discountPremiumHighTime) and not na(discountPremiumLowTime) and discountPremiumHigh > discountPremiumLow

discountPremiumEquilibrium () =>
    (discountPremiumHigh + discountPremiumLow) / 2.0

deleteDiscountPremiumZones (box premiumZoneBoxF, box discountZoneBoxF, line equilibriumLineF, label premiumZoneLabelF, label discountZoneLabelF, label equilibriumLabelF) =>
    box.delete(premiumZoneBoxF)
    box.delete(discountZoneBoxF)
    line.delete(equilibriumLineF)
    label.delete(premiumZoneLabelF)
    label.delete(discountZoneLabelF)
    label.delete(equilibriumLabelF)

storeConfirmedPivot (int[] pivotIndexes, float[] pivotPrices, int pivotIndex, float pivotPrice) =>
    if pivotIndexes.size() == 0 or pivotIndexes.get(pivotIndexes.size() - 1) != pivotIndex
        pivotIndexes.push(pivotIndex)
        pivotPrices.push(pivotPrice)
        while pivotIndexes.size() > maxOBSearchBars
            pivotIndexes.shift()
            pivotPrices.shift()

storeConfirmedPivots () =>
    if not na(confirmedPivotHigh)
        storeConfirmedPivot(confirmedPivotHighIndexes, confirmedPivotHighPrices, bar_index[swingLength], confirmedPivotHigh)
    if not na(confirmedPivotLow)
        storeConfirmedPivot(confirmedPivotLowIndexes, confirmedPivotLowPrices, bar_index[swingLength], confirmedPivotLow)

findPriorConfirmedPivotPrice (int[] pivotIndexes, float[] pivotPrices, int barsBack) =>
    float pivotPrice = na
    int maxPivotIndex = bar_index - barsBack - swingLength
    int minPivotIndex = bar_index - maxOBSearchBars
    if barsBack + swingLength <= maxOBSearchBars and pivotIndexes.size() > 0
        for i = pivotIndexes.size() - 1 to 0
            pivotIndex = pivotIndexes.get(i)
            if pivotIndex < minPivotIndex
                break
            if pivotIndex <= maxPivotIndex
                pivotPrice := pivotPrices.get(i)
                break
    pivotPrice

candleSweptSellSideLiquidity (int barsBack) =>
    pivotPrice = findPriorConfirmedPivotPrice(confirmedPivotLowIndexes, confirmedPivotLowPrices, barsBack)
    not na(pivotPrice) and low[barsBack] < pivotPrice

candleSweptBuySideLiquidity (int barsBack) =>
    pivotPrice = findPriorConfirmedPivotPrice(confirmedPivotHighIndexes, confirmedPivotHighPrices, barsBack)
    not na(pivotPrice) and high[barsBack] > pivotPrice

isZoneTooLarge (float zoneTop, float zoneBtm) =>
    math.abs(zoneTop - zoneBtm) > atr * maxATRMult

getBullColorSequenceZone (int startBarsBack, int maxBarsBack) =>
    float zoneTop = high[startBarsBack]
    float zoneBtm = low[startBarsBack]
    int zoneLoc = time[startBarsBack]
    if maxBarsBack > startBarsBack
        for clusterIndex = startBarsBack + 1 to maxBarsBack
            if close[clusterIndex] <= open[clusterIndex]
                zoneTop := math.max(zoneTop, high[clusterIndex])
                zoneBtm := math.min(zoneBtm, low[clusterIndex])
                zoneLoc := time[clusterIndex]
            else
                break
    [zoneTop, zoneBtm, zoneLoc]

getBearColorSequenceZone (int startBarsBack, int maxBarsBack) =>
    float zoneTop = high[startBarsBack]
    float zoneBtm = low[startBarsBack]
    int zoneLoc = time[startBarsBack]
    if maxBarsBack > startBarsBack
        for clusterIndex = startBarsBack + 1 to maxBarsBack
            if close[clusterIndex] >= open[clusterIndex]
                zoneTop := math.max(zoneTop, high[clusterIndex])
                zoneBtm := math.min(zoneBtm, low[clusterIndex])
                zoneLoc := time[clusterIndex]
            else
                break
    [zoneTop, zoneBtm, zoneLoc]

findOrderBlocks (obSwing top, obSwing btm) =>
    if bar_index > last_bar_index - maxDistanceToLastBar
        // Bullish Order Block
        if bullishOrderBlocksList.size() > 0
            for i = bullishOrderBlocksList.size() - 1 to 0
                currentOB = bullishOrderBlocksList.get(i)

                if not currentOB.breaker
                    if (obEndMethod == "Wick" ? low : math.min(open, close)) < currentOB.bottom
                        currentOB.breaker := true
                        currentOB.breakTime := time
                        currentOB.bbVolume := volume
                else
                    if high > currentOB.top
                        bullishOrderBlocksList.remove(i)

        if not na(top.y) and close > top.y and not top.crossed and (not requireFVGConfirmation or (not na(high[2]) and low > high[2]))
            top.crossed := true

            float boxBtm = requireLiquiditySweep ? na : low[1]
            float boxTop = requireLiquiditySweep ? na : high[1]
            int boxLoc = requireLiquiditySweep ? na : time[1]
            float selectedBullExtremeBtm = na
            bool validOrderBlockCandidate = false

            bullishSearchBars = math.min((bar_index - top.x) - 1, maxOBSearchBars)
            if bullishSearchBars > 0
                for i = 1 to bullishSearchBars
                    candidateSweptLiquidity = not requireLiquiditySweep or candleSweptSellSideLiquidity(i)
                    candidateBtm = low[i]
                    if candidateSweptLiquidity and (not validOrderBlockCandidate or candidateBtm < selectedBullExtremeBtm)
                        singleBullTop = high[i]
                        singleBullBtm = low[i]
                        singleBullLoc = time[i]
                        bullClusterTop = singleBullTop
                        bullClusterBtm = singleBullBtm
                        bullClusterLoc = singleBullLoc

                        if multiCandleOrderBlocks and bullishSearchBars > i
                            for clusterIndex = i + 1 to bullishSearchBars + 1
                                bullClusterTop := math.max(bullClusterTop, high[clusterIndex])
                                bullClusterBtm := math.min(bullClusterBtm, low[clusterIndex])
                                bullClusterLoc := time[clusterIndex]
                            if constrainLargeOrderBlocks and isZoneTooLarge(bullClusterTop, bullClusterBtm)
                                [bullColorTop, bullColorBtm, bullColorLoc] = getBullColorSequenceZone(i, bullishSearchBars + 1)
                                bullClusterTop := bullColorTop
                                bullClusterBtm := bullColorBtm
                                bullClusterLoc := bullColorLoc
                                if isZoneTooLarge(bullClusterTop, bullClusterBtm)
                                    bullClusterTop := singleBullTop
                                    bullClusterBtm := singleBullBtm
                                    bullClusterLoc := singleBullLoc

                        validOrderBlockCandidate := true
                        selectedBullExtremeBtm := candidateBtm
                        boxBtm := bullClusterBtm
                        boxTop := bullClusterTop
                        boxLoc := bullClusterLoc

            if validOrderBlockCandidate
                newOrderBlockInfo = orderBlockInfo.new(boxTop, boxBtm, volume + volume[1] + volume[2], "Bull", boxLoc)
                newOrderBlockInfo.creationTime := time
                newOrderBlockInfo.obLowVolume := volume[2]
                newOrderBlockInfo.obHighVolume := volume + volume[1]

                obSize = math.abs(newOrderBlockInfo.top - newOrderBlockInfo.bottom)
                if not constrainLargeOrderBlocks or obSize <= atr * maxATRMult
                    bullishOrderBlocksList.unshift(newOrderBlockInfo)
                    if bullishOrderBlocksList.size() > maxOrderBlocks
                        bullishOrderBlocksList.pop()

        // Bearish Order Block
        if bearishOrderBlocksList.size() > 0
            for i = bearishOrderBlocksList.size() - 1 to 0
                currentOB = bearishOrderBlocksList.get(i)

                if not currentOB.breaker
                    if (obEndMethod == "Wick" ? high : math.max(open, close)) > currentOB.top
                        currentOB.breaker := true
                        currentOB.breakTime := time
                        currentOB.bbVolume := volume
                else
                    if low < currentOB.bottom
                        bearishOrderBlocksList.remove(i)

        if not na(btm.y) and close < btm.y and not btm.crossed and (not requireFVGConfirmation or (not na(low[2]) and high < low[2]))
            btm.crossed := true

            float boxBtm = requireLiquiditySweep ? na : low[1]
            float boxTop = requireLiquiditySweep ? na : high[1]
            int boxLoc = requireLiquiditySweep ? na : time[1]
            float selectedBearExtremeTop = na
            bool validOrderBlockCandidate = false

            bearishSearchBars = math.min((bar_index - btm.x) - 1, maxOBSearchBars)
            if bearishSearchBars > 0
                for i = 1 to bearishSearchBars
                    candidateSweptLiquidity = not requireLiquiditySweep or candleSweptBuySideLiquidity(i)
                    candidateTop = high[i]
                    if candidateSweptLiquidity and (not validOrderBlockCandidate or candidateTop > selectedBearExtremeTop)
                        singleBearTop = high[i]
                        singleBearBtm = low[i]
                        singleBearLoc = time[i]
                        bearClusterTop = singleBearTop
                        bearClusterBtm = singleBearBtm
                        bearClusterLoc = singleBearLoc

                        if multiCandleOrderBlocks and bearishSearchBars > i
                            for clusterIndex = i + 1 to bearishSearchBars + 1
                                bearClusterTop := math.max(bearClusterTop, high[clusterIndex])
                                bearClusterBtm := math.min(bearClusterBtm, low[clusterIndex])
                                bearClusterLoc := time[clusterIndex]
                            if constrainLargeOrderBlocks and isZoneTooLarge(bearClusterTop, bearClusterBtm)
                                [bearColorTop, bearColorBtm, bearColorLoc] = getBearColorSequenceZone(i, bearishSearchBars + 1)
                                bearClusterTop := bearColorTop
                                bearClusterBtm := bearColorBtm
                                bearClusterLoc := bearColorLoc
                                if isZoneTooLarge(bearClusterTop, bearClusterBtm)
                                    bearClusterTop := singleBearTop
                                    bearClusterBtm := singleBearBtm
                                    bearClusterLoc := singleBearLoc

                        validOrderBlockCandidate := true
                        selectedBearExtremeTop := candidateTop
                        boxTop := bearClusterTop
                        boxBtm := bearClusterBtm
                        boxLoc := bearClusterLoc

            if validOrderBlockCandidate
                newOrderBlockInfo = orderBlockInfo.new(boxTop, boxBtm, volume + volume[1] + volume[2], "Bear", boxLoc)
                newOrderBlockInfo.creationTime := time
                newOrderBlockInfo.obLowVolume := volume + volume[1]
                newOrderBlockInfo.obHighVolume := volume[2]

                obSize = math.abs(newOrderBlockInfo.top - newOrderBlockInfo.bottom)
                if not constrainLargeOrderBlocks or obSize <= atr * maxATRMult
                    bearishOrderBlocksList.unshift(newOrderBlockInfo)
                    if bearishOrderBlocksList.size() > maxOrderBlocks
                        bearishOrderBlocksList.pop()
        true
    else
        true

effectiveOBStart (orderBlockInfo OBInfo) =>
    OBInfo.breaker and not na(OBInfo.breakTime) ? OBInfo.breakTime : OBInfo.startTime

effectiveOBEnd (orderBlockInfo OBInfo) =>
    effectiveStart = effectiveOBStart(OBInfo)
    extendZonesDynamic ? time + 1 : effectiveStart + extendZonesByTime

doOBsTouch (orderBlockInfo OBInfo1, orderBlockInfo OBInfo2) =>
    float XA1 = effectiveOBStart(OBInfo1)
    float XA2 = effectiveOBEnd(OBInfo1)
    float YA1 = OBInfo1.top
    float YA2 = OBInfo1.bottom

    float XB1 = effectiveOBStart(OBInfo2)
    float XB2 = effectiveOBEnd(OBInfo2)
    float YB1 = OBInfo2.top
    float YB2 = OBInfo2.bottom
    float intersectionArea = math.max(0, math.min(XA2, XB2) - math.max(XA1, XB1)) * math.max(0, math.min(YA1, YB1) - math.max(YA2, YB2))
    float area1 = math.abs(XA2 - XA1) * math.abs(YA1 - YA2)
    float area2 = math.abs(XB2 - XB1) * math.abs(YB1 - YB2)
    float unionArea = area1 + area2 - intersectionArea

    float overlapPercentage = (intersectionArea / unionArea) * 100.0

    if overlapPercentage > overlapThresholdPercentage
        true
    else
        false

isOBValid (orderBlockInfo OBInfo) =>
    valid = true
    if OBInfo.disabled
        valid := false
    valid

effectiveOBType (orderBlockInfo OBInfo) =>
    OBInfo.breaker ? (OBInfo.obType == "Bull" ? "Bear" : "Bull") : OBInfo.obType

getRenderedOBEnd (orderBlockInfo OBInfoF) =>
    extendZonesDynamic ? time + 1 : OBInfoF.startTime + extendZonesByTime

findEntrySignalBarsBack (orderBlockInfo OBInfo) =>
    int signalBarsBack = na
    if OBInfo.timeframeIndex == 1 and not OBInfo.breaker and isOBValid(OBInfo)
        zoneHeight = OBInfo.top - OBInfo.bottom
        if zoneHeight > 0
            entryZoneTop = OBInfo.bottom + zoneHeight * 0.75
            entryZoneBottom = OBInfo.bottom + zoneHeight * 0.25
            renderedEnd = getRenderedOBEnd(OBInfo)
            signalStartTime = nz(OBInfo.creationTime, OBInfo.startTime)
            maxBarsBack = math.min(bar_index, maxDistanceToLastBar)
            for barsBack = 0 to maxBarsBack
                if time[barsBack] > signalStartTime and time[barsBack] <= renderedEnd and low[barsBack] <= entryZoneTop and high[barsBack] >= entryZoneBottom
                    signalBarsBack := barsBack
    signalBarsBack

findEntrySignalTime (orderBlockInfo OBInfo) =>
    signalBarsBack = findEntrySignalBarsBack(OBInfo)
    not na(signalBarsBack) ? time[signalBarsBack] : na

combineEntrySignalTime (orderBlockInfo OBInfo1, orderBlockInfo OBInfo2) =>
    entryTime1 = nz(OBInfo1.entryTime, findEntrySignalTime(OBInfo1))
    entryTime2 = nz(OBInfo2.entryTime, findEntrySignalTime(OBInfo2))
    na(entryTime1) ? entryTime2 : na(entryTime2) ? entryTime1 : math.min(entryTime1, entryTime2)

renderedOBsOverlap (orderBlockInfo OBInfo1, orderBlockInfo OBInfo2) =>
    float XA1 = OBInfo1.startTime
    float XA2 = getRenderedOBEnd(OBInfo1)
    float YA1 = OBInfo1.top
    float YA2 = OBInfo1.bottom

    float XB1 = OBInfo2.startTime
    float XB2 = getRenderedOBEnd(OBInfo2)
    float YB1 = OBInfo2.top
    float YB2 = OBInfo2.bottom

    math.min(XA2, XB2) > math.max(XA1, XB1) and math.min(YA1, YB1) > math.max(YA2, YB2)

hideHistoricOBsOverlappingNewerActive () =>
    if allOrderBlocksList.size() > 0
        for i = 0 to allOrderBlocksList.size() - 1
            historicOB = allOrderBlocksList.get(i)
            if not isOBValid(historicOB) or not historicOB.breaker
                continue
            for j = 0 to allOrderBlocksList.size() - 1
                activeOB = allOrderBlocksList.get(j)
                if i == j or not isOBValid(activeOB) or activeOB.breaker
                    continue
                if historicOB.timeframeIndex != activeOB.timeframeIndex
                    continue
                if activeOB.startTime > historicOB.startTime and renderedOBsOverlap(historicOB, activeOB)
                    historicOB.disabled := true
                    break

combineOBsFunc () =>
    if allOrderBlocksList.size() > 1
        lastCombinations = 999
        combinationPasses = 0
        while lastCombinations > 0 and combinationPasses < maxCombinationPasses and allOrderBlocksList.size() < maxCombinedOrderBlocks
            lastCombinations := 0
            combinationPasses += 1
            for i = 0 to allOrderBlocksList.size() - 2
                curOB1 = allOrderBlocksList.get(i)
                if not isOBValid(curOB1)
                    continue
                for j = i + 1 to allOrderBlocksList.size() - 1
                    curOB2 = allOrderBlocksList.get(j)
                    if not isOBValid(curOB2)
                        continue
                    curOB1EffectiveType = effectiveOBType(curOB1)
                    curOB2EffectiveType = effectiveOBType(curOB2)
                    if curOB1.timeframeIndex != curOB2.timeframeIndex
                        continue
                    if curOB1EffectiveType != curOB2EffectiveType
                        continue
                    if not showInvalidated and (curOB1.breaker or curOB2.breaker)
                        continue
                    if allOrderBlocksList.size() < maxCombinedOrderBlocks and doOBsTouch(curOB1, curOB2)
                        combinedEntryTime = entrySignalsEnabled ? combineEntrySignalTime(curOB1, curOB2) : na
                        curOB1.disabled := true
                        curOB2.disabled := true
                        bothBreakersSameOriginalType = curOB1.breaker and curOB2.breaker and curOB1.obType == curOB2.obType and not na(curOB1.breakTime) and not na(curOB2.breakTime)
                        combinedType = bothBreakersSameOriginalType ? curOB1.obType : curOB1EffectiveType
                        orderBlockInfo newOB = orderBlockInfo.new(math.max(curOB1.top, curOB2.top), math.min(curOB1.bottom, curOB2.bottom), curOB1.obVolume + curOB2.obVolume, combinedType)
                        newOB.startTime := bothBreakersSameOriginalType ? math.min(curOB1.startTime, curOB2.startTime) : math.min(effectiveOBStart(curOB1), effectiveOBStart(curOB2))
                        newOB.creationTime := math.max(nz(curOB1.creationTime, curOB1.startTime), nz(curOB2.creationTime, curOB2.startTime))
                        newOB.entryTime := combinedEntryTime
                        newOB.timeframeStr := curOB1.timeframeStr
                        newOB.timeframeIndex := curOB1.timeframeIndex

                        newOB.obVolume := curOB1.obVolume + curOB2.obVolume
                        newOB.obLowVolume := curOB1.obLowVolume + curOB2.obLowVolume
                        newOB.obHighVolume := curOB1.obHighVolume + curOB2.obHighVolume
                        newOB.bbVolume := nz(curOB1.bbVolume, 0) + nz(curOB2.bbVolume, 0)
                        combinedBroken = newOB.obType == "Bull" ? low < newOB.bottom : high > newOB.top
                        newOB.breaker := bothBreakersSameOriginalType or combinedBroken
                        newOB.breakTime := bothBreakersSameOriginalType ? math.min(curOB1.breakTime, curOB2.breakTime) : combinedBroken ? time : na

                        newOB.combined := true
                        if timeframe.in_seconds(curOB1.timeframeStr) != timeframe.in_seconds(curOB2.timeframeStr)
                            newOB.combinedTimeframesStr := (na(curOB1.combinedTimeframesStr) ? formatTimeframeString(curOB1.timeframeStr) : curOB1.combinedTimeframesStr) + " & " + (na(curOB2.combinedTimeframesStr) ? formatTimeframeString(curOB2.timeframeStr) : curOB2.combinedTimeframesStr)
                        allOrderBlocksList.unshift(newOB)
                        lastCombinations += 1


reqSeq (timeframeStr) =>
    activeTimeframe = timeframeStr == "" ? timeframe.period : timeframeStr
    if timeframe.in_seconds(activeTimeframe) == timeframe.in_seconds(timeframe.period)
        [bullishOrderBlocksList, bearishOrderBlocksList]
    else
        [bullishOrderBlocksListF, bearishOrderBlocksListF] = request.security(syminfo.tickerid, activeTimeframe, [bullishOrderBlocksList, bearishOrderBlocksList])
        [bullishOrderBlocksListF, bearishOrderBlocksListF]

getTFData (timeframeInfo timeframeInfoF, timeframeStr) =>
    if timeframeInfoF.isEnabled
        [bullishOrderBlocksListF, bearishOrderBlocksListF] = reqSeq(timeframeStr)
        [bullishOrderBlocksListF, bearishOrderBlocksListF]
    else
        [na, na]

handleTimeframeInfo (timeframeInfo timeframeInfoF, bullishOrderBlocksListF, bearishOrderBlocksListF) =>
    if timeframeInfoF.isEnabled
        if not na(bullishOrderBlocksListF)
            timeframeInfoF.bullishOrderBlocksList := bullishOrderBlocksListF
        if not na(bearishOrderBlocksListF)
            timeframeInfoF.bearishOrderBlocksList := bearishOrderBlocksListF

clearEntrySignalLabels () =>
    if entrySignalLabels.size() > 0
        for i = 0 to entrySignalLabels.size() - 1
            label.delete(entrySignalLabels.get(i))
        entrySignalLabels.clear()

createEntrySignalLabel (orderBlockInfo OBInfo, int barsBack) =>
    bool isLong = OBInfo.obType == "Bull"
    signalColor = isLong ? bullOrderBlockColor : bearOrderBlockColor
    signalText = isLong ? "𝗟𝗢𝗡𝗚" : "𝗦𝗛𝗢𝗥𝗧"
    signalOffset = syminfo.mintick * 7
    signalY = isLong ? low[barsBack] - signalOffset : high[barsBack] + signalOffset
    signalStyle = isLong ? label.style_label_up : label.style_label_down
    label.new(time[barsBack], signalY, signalText, xloc = xloc.bar_time, style = signalStyle, textcolor = color.new(signalColor, 0), color = color.new(color.white, 0), size = size.normal)

getEntrySignalBarsBack (orderBlockInfo OBInfo) =>
    int signalBarsBack = na
    if entrySignalsEnabled and OBInfo.timeframeIndex == 1 and not OBInfo.breaker and isOBValid(OBInfo)
        if not na(OBInfo.entryTime)
            maxBarsBack = math.min(bar_index, maxDistanceToLastBar)
            for barsBack = 0 to maxBarsBack
                if time[barsBack] == OBInfo.entryTime
                    signalBarsBack := barsBack
                    break
        else
            signalBarsBack := findEntrySignalBarsBack(OBInfo)
    signalBarsBack

renderEntrySignalForOB (orderBlockInfo OBInfo) =>
    signalBarsBack = getEntrySignalBarsBack(OBInfo)
    if not na(signalBarsBack)
        entrySignalLabels.push(createEntrySignalLabel(OBInfo, signalBarsBack))

renderLatestEntrySignalsFromRenderedOrderBlocks () =>
    int latestBullBarsBack = na
    int latestBearBarsBack = na
    int latestBullIndex = na
    int latestBearIndex = na
    if allOrderBlocksList.size() > 0
        for i = 0 to allOrderBlocksList.size() - 1
            curOBInfo = allOrderBlocksList.get(i)
            signalBarsBack = getEntrySignalBarsBack(curOBInfo)
            if not na(signalBarsBack)
                if curOBInfo.obType == "Bull"
                    if na(latestBullBarsBack) or signalBarsBack < latestBullBarsBack
                        latestBullBarsBack := signalBarsBack
                        latestBullIndex := i
                else
                    if na(latestBearBarsBack) or signalBarsBack < latestBearBarsBack
                        latestBearBarsBack := signalBarsBack
                        latestBearIndex := i
    if not na(latestBullIndex)
        entrySignalLabels.push(createEntrySignalLabel(allOrderBlocksList.get(latestBullIndex), latestBullBarsBack))
    if not na(latestBearIndex)
        entrySignalLabels.push(createEntrySignalLabel(allOrderBlocksList.get(latestBearIndex), latestBearBarsBack))

renderEntrySignalsFromRenderedOrderBlocks () =>
    clearEntrySignalLabels()
    if entrySignalsMode == "Historical" and allOrderBlocksList.size() > 0
        for i = 0 to allOrderBlocksList.size() - 1
            curOBInfo = allOrderBlocksList.get(i)
            renderEntrySignalForOB(curOBInfo)
    else if entrySignalsMode == "Latest"
        renderLatestEntrySignalsFromRenderedOrderBlocks()

buildAllOrderBlocksList () =>
    allOrderBlocksList.clear()

    for i = 0 to timeframeInfos.size() - 1
        curTimeframe = timeframeInfos.get(i)
        if not curTimeframe.isEnabled
            continue
        maxBullishOrderBlocks = curTimeframe.index == 2 ? secondaryBullishOrderBlocks : bullishOrderBlocks
        maxBearishOrderBlocks = curTimeframe.index == 2 ? secondaryBearishOrderBlocks : bearishOrderBlocks
        if not na(curTimeframe.bullishOrderBlocksList) and curTimeframe.bullishOrderBlocksList.size() > 0
            for j = 0 to math.min(curTimeframe.bullishOrderBlocksList.size() - 1, maxBullishOrderBlocks - 1)
                orderBlockInfoF = curTimeframe.bullishOrderBlocksList.get(j)
                orderBlockInfoF.timeframeStr := curTimeframe.timeframeStr
                orderBlockInfoF.timeframeIndex := curTimeframe.index
                allOrderBlocksList.unshift(orderBlockInfo.copy(orderBlockInfoF))

        if not na(curTimeframe.bearishOrderBlocksList) and curTimeframe.bearishOrderBlocksList.size() > 0
            for j = 0 to math.min(curTimeframe.bearishOrderBlocksList.size() - 1, maxBearishOrderBlocks - 1)
                orderBlockInfoF = curTimeframe.bearishOrderBlocksList.get(j)
                orderBlockInfoF.timeframeStr := curTimeframe.timeframeStr
                orderBlockInfoF.timeframeIndex := curTimeframe.index
                allOrderBlocksList.unshift(orderBlockInfo.copy(orderBlockInfoF))

    if showInvalidated
        hideHistoricOBsOverlappingNewerActive()

    if combineOBs
        combineOBsFunc()

handleOrderBlocksFinal () =>
    if DEBUG
        log.info("Bullish OB Count " + str.tostring(bullishOrderBlocksList.size()))
        log.info("Bearish OB Count " + str.tostring(bearishOrderBlocksList.size()))

    buildAllOrderBlocksList()

    renderedCount = 0
    if allOrderBlocksList.size() > 0
        for i = 0 to allOrderBlocksList.size() - 1
            curOBInfo = allOrderBlocksList.get(i)
            if isOBValid(curOBInfo)
                renderOrderBlock(getReusableOrderBlock(orderBlockInfo.copy(curOBInfo), renderedCount))
                renderedCount += 1

    if reusableOrderBlocks.size() > renderedCount
        for i = renderedCount to reusableOrderBlocks.size() - 1
            safeDeleteOrderBlock(reusableOrderBlocks.get(i))

    if entrySignalsEnabled
        renderEntrySignalsFromRenderedOrderBlocks()

[top, btm, swingHighFound, swingLowFound] = findOBSwings(swingLength)
storeConfirmedPivots()

if showDiscountPremiumZones
    [discountPremiumHighF, discountPremiumLowF, discountPremiumHighTimeF, discountPremiumLowTimeF] = getDiscountPremiumRange()
    discountPremiumHigh := discountPremiumHighF
    discountPremiumLow := discountPremiumLowF
    discountPremiumHighTime := discountPremiumHighTimeF
    discountPremiumLowTime := discountPremiumLowTimeF

if showDiscountPremiumZones and hasDiscountPremiumRange()
    equilibrium = discountPremiumEquilibrium()
    rangeStartTime = math.min(discountPremiumHighTime, discountPremiumLowTime)
    rangeEndTime = time + 1

    if na(premiumZoneBox)
        premiumZoneBox := box.new(na, na, na, na, xloc = xloc.bar_time, bgcolor = color.new(#ffffff, 85), border_color = #00000000)
    if na(discountZoneBox)
        discountZoneBox := box.new(na, na, na, na, xloc = xloc.bar_time, bgcolor = color.new(#ffffff, 95), border_color = #00000000)
    if na(equilibriumLine)
        equilibriumLine := line.new(na, na, na, na, xloc = xloc.bar_time, extend = extend.none, color = color.new(#ffffff, 45), style = line.style_dashed, width = 1)
    if na(premiumZoneLabel)
        premiumZoneLabel := label.new(na, na, "Premium", xloc = xloc.bar_time, style = label.style_label_left, textcolor = textColor, color = color.new(color.black, 100), size = size.small)
    if na(discountZoneLabel)
        discountZoneLabel := label.new(na, na, "Discount", xloc = xloc.bar_time, style = label.style_label_left, textcolor = textColor, color = color.new(color.black, 100), size = size.small)
    if na(equilibriumLabel)
        equilibriumLabel := label.new(na, na, "EQ", xloc = xloc.bar_time, style = label.style_label_left, textcolor = textColor, color = color.new(color.black, 100), size = size.small)

    moveBox(premiumZoneBox, rangeStartTime, discountPremiumHigh, rangeEndTime, equilibrium)
    moveBox(discountZoneBox, rangeStartTime, equilibrium, rangeEndTime, discountPremiumLow)
    moveLine(equilibriumLine, rangeStartTime, equilibrium, rangeEndTime)
    label.set_xy(premiumZoneLabel, rangeEndTime, (discountPremiumHigh + equilibrium) / 2.0)
    label.set_xy(discountZoneLabel, rangeEndTime, (equilibrium + discountPremiumLow) / 2.0)
    label.set_xy(equilibriumLabel, rangeEndTime, equilibrium)
else
    if not na(premiumZoneBox) or not na(discountZoneBox) or not na(equilibriumLine) or not na(premiumZoneLabel) or not na(discountZoneLabel) or not na(equilibriumLabel)
        deleteDiscountPremiumZones(premiumZoneBox, discountZoneBox, equilibriumLine, premiumZoneLabel, discountZoneLabel, equilibriumLabel)
        premiumZoneBox := na
        discountZoneBox := na
        equilibriumLine := na
        premiumZoneLabel := na
        discountZoneLabel := na
        equilibriumLabel := na

plotshape(showSwingPoints and swingHighFound, "Swing High", shape.triangledown, location.abovebar, bearOrderBlockColor, offset = -swingLength, text = "SH", textcolor = textColor, size = size.tiny)
plotshape(showSwingPoints and swingLowFound, "Swing Low", shape.triangleup, location.belowbar, bullOrderBlockColor, offset = -swingLength, text = "SL", textcolor = textColor, size = size.tiny)

findOrderBlocks(top, btm)

[bullishOrderBlocksListTimeframe1, bearishOrderBlocksListTimeframe1] = getTFData(timeframeInfos.get(0), timeframe1)
[bullishOrderBlocksListTimeframe2, bearishOrderBlocksListTimeframe2] = if timeframe2Enabled
    getTFData(timeframeInfos.get(1), timeframe2)
else
    [na, na]

if barstate.isconfirmed
    handleTimeframeInfo(timeframeInfos.get(0), bullishOrderBlocksListTimeframe1, bearishOrderBlocksListTimeframe1)
    handleTimeframeInfo(timeframeInfos.get(1), bullishOrderBlocksListTimeframe2, bearishOrderBlocksListTimeframe2)

if barstate.islast
    handleOrderBlocksFinal()
````
