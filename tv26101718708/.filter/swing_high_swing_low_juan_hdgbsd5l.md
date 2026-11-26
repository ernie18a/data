# Swing High Swing Low Juan

- url: https://www.tradingview.com/script/hDgbSd5L/
- type: indicator
- pine_id: PUB;9d995097494f4f7c9845868b53e49187
- version: 1.0

## Description

Este script marca los swings zones en el grafico en hora es muy util y luego cambiar a 5 minutos

## Source Code

````pine
//@version=5
indicator("Swing High Swing Low Juan", overlay=true, max_labels_count=500, max_boxes_count=500)

// Settings
int leftBars = 5
int rightBars = 5
float minSwingMoveAtr = 0.75
int minBarsBetweenSwings = 3
int maxSwingText = 500
int maxZones = 240
int atrLength = 14

string generalSettingsGroup = "General Settings"
string colorSettingsGroup = "Color Settings"

// Inputs
useCleanSwingFilter = input.bool(true, "Use Clean Alternating Swing Filter", group=generalSettingsGroup)
showSwingText = input.bool(true, "Show Swing High/Low Text", group=generalSettingsGroup)
showLiquidityBlocks = input.bool(true, "Show Wick Liquidity Blocks", group=generalSettingsGroup)
showLiquidityMoney = input.bool(true, "Show Liquidity Money", group=generalSettingsGroup)
hideFilledZones = input.bool(true, "Hide Filled Blocks", group=generalSettingsGroup)
swingHighText = input.string("Swing High", "Swing High Text", group=generalSettingsGroup)
swingLowText = input.string("Swing Low", "Swing Low Text", group=generalSettingsGroup)

swingHighTextColor = input.color(color.red, "Swing High Text Color", group=colorSettingsGroup)
swingLowTextColor = input.color(color.lime, "Swing Low Text Color", group=colorSettingsGroup)
swingHighZoneColor = input.color(color.new(color.red, 85), "Swing High Liquidity Zone", group=colorSettingsGroup)
swingLowZoneColor = input.color(color.new(color.lime, 85), "Swing Low Liquidity Zone", group=colorSettingsGroup)
swingHighBorderColor = input.color(color.new(color.red, 15), "Swing High Zone Border", group=colorSettingsGroup)
swingLowBorderColor = input.color(color.new(color.lime, 15), "Swing Low Zone Border", group=colorSettingsGroup)
filledZoneColor = input.color(color.new(color.gray, 82), "Filled Zone", group=colorSettingsGroup)
filledBorderColor = input.color(color.new(color.gray, 35), "Filled Zone Border", group=colorSettingsGroup)

// Arrays
var label[] swingLabels = array.new_label()
var int[] swingLabelIds = array.new_int()

var box[] zoneBoxes = array.new_box()
var box[] filledZoneBoxes = array.new_box()
var int[] zoneIds = array.new_int()
var bool[] zoneFromSwingHigh = array.new_bool()
var float[] zoneOrigTops = array.new_float()
var float[] zoneOrigBots = array.new_float()
var float[] zoneFillLevels = array.new_float()
var bool[] zoneFull = array.new_bool()
var float[] zoneLiquidityMoney = array.new_float()

// Swing state
var int lastSwingType = 0
var float lastSwingPrice = na
var int lastSwingBar = na
var int lastSwingId = na
var int nextSwingId = 0

// Core values
atrRaw = ta.atr(atrLength)
atrValue = na(atrRaw) ? math.max(high - low, syminfo.mintick) : atrRaw

pivotHigh = ta.pivothigh(high, leftBars, rightBars)
pivotLow = ta.pivotlow(low, leftBars, rightBars)

pivotBar = bar_index - rightBars

pivotOpen = open[rightBars]
pivotClose = close[rightBars]
pivotBodyTop = math.max(pivotOpen, pivotClose)
pivotBodyBottom = math.min(pivotOpen, pivotClose)

// Helpers
f_format_money(float _value) =>
    string result = "$0"

    if not na(_value)
        float absValue = math.abs(_value)

        if absValue >= 1000000000.0
            result := "$" + str.tostring(_value / 1000000000.0, "#.##") + "B"
        else if absValue >= 1000000.0
            result := "$" + str.tostring(_value / 1000000.0, "#.##") + "M"
        else if absValue >= 1000.0
            result := "$" + str.tostring(_value / 1000.0, "#.##") + "K"
        else
            result := "$" + str.tostring(_value, "#.##")

    result

f_wick_liquidity_money(bool _fromSwingHigh, float _swingPrice, float _bodyTop, float _bodyBottom) =>
    float candleHigh = high[rightBars]
    float candleLow = low[rightBars]
    float candleRange = math.max(candleHigh - candleLow, syminfo.mintick)
    float candleVolume = nz(volume[rightBars], 0.0)

    float wickSize = _fromSwingHigh ? math.max(_swingPrice - _bodyTop, 0.0) : math.max(_bodyBottom - _swingPrice, 0.0)
    float wickShare = math.min(wickSize / candleRange, 1.0)
    float wickMidPrice = _fromSwingHigh ? (_swingPrice + _bodyTop) / 2.0 : (_bodyBottom + _swingPrice) / 2.0

    candleVolume * wickShare * wickMidPrice

f_filled_liquidity_money(float _totalMoney, float _origTop, float _origBot, float _newFillLevel, bool _fromSwingHigh) =>
    float zoneSize = math.max(_origTop - _origBot, syminfo.mintick)
    float filledPart = _fromSwingHigh ? math.max(_newFillLevel - _origBot, 0.0) : math.max(_origTop - _newFillLevel, 0.0)
    float filledPercent = math.min(filledPart / zoneSize, 1.0)

    _totalMoney * filledPercent

f_set_box_text(box _box, string _text, color _textColor) =>
    if not na(_box)
        box.set_text(_box, showLiquidityMoney ? _text : "")
        box.set_text_color(_box, _textColor)
        box.set_text_size(_box, size.small)
        box.set_text_halign(_box, text.align_right)
        box.set_text_valign(_box, text.align_center)

f_hide_box(box _box) =>
    if not na(_box)
        box.set_bgcolor(_box, color.new(color.gray, 100))
        box.set_border_color(_box, color.new(color.gray, 100))
        box.set_text(_box, "")

f_trim_swing_labels() =>
    while array.size(swingLabels) > maxSwingText
        label oldLabel = array.shift(swingLabels)

        if not na(oldLabel)
            label.delete(oldLabel)

        if array.size(swingLabelIds) > 0
            array.shift(swingLabelIds)

f_delete_swing_label_by_id(int _id) =>
    int count = array.size(swingLabelIds)

    if count > 0
        for loopIndex = 0 to count - 1
            int i = count - 1 - loopIndex

            if array.get(swingLabelIds, i) == _id
                label oldLabel = array.get(swingLabels, i)

                if not na(oldLabel)
                    label.delete(oldLabel)

                array.remove(swingLabels, i)
                array.remove(swingLabelIds, i)

f_delete_zone(int _index) =>
    if _index >= 0 and _index < array.size(zoneBoxes)
        box oldZone = array.get(zoneBoxes, _index)
        box oldFilledZone = array.get(filledZoneBoxes, _index)

        if not na(oldZone)
            box.delete(oldZone)

        if not na(oldFilledZone)
            box.delete(oldFilledZone)

        array.remove(zoneBoxes, _index)
        array.remove(filledZoneBoxes, _index)
        array.remove(zoneIds, _index)
        array.remove(zoneFromSwingHigh, _index)
        array.remove(zoneOrigTops, _index)
        array.remove(zoneOrigBots, _index)
        array.remove(zoneFillLevels, _index)
        array.remove(zoneFull, _index)
        array.remove(zoneLiquidityMoney, _index)

f_delete_zone_by_id(int _id) =>
    int count = array.size(zoneIds)

    if count > 0
        for loopIndex = 0 to count - 1
            int i = count - 1 - loopIndex

            if array.get(zoneIds, i) == _id
                f_delete_zone(i)

f_trim_zones() =>
    while array.size(zoneBoxes) > maxZones
        f_delete_zone(0)

f_delete_current_swing_objects() =>
    if not na(lastSwingId)
        f_delete_swing_label_by_id(lastSwingId)
        f_delete_zone_by_id(lastSwingId)

f_bars_ok(int _bar) =>
    na(lastSwingBar) or math.abs(_bar - lastSwingBar) >= minBarsBetweenSwings

f_add_swing_label(int _x, float _y, string _text, bool _isSwingHigh, int _id) =>
    if showSwingText
        float textPrice = _isSwingHigh ? _y + atrValue * 0.20 : _y - atrValue * 0.20
        color textColor = _isSwingHigh ? swingHighTextColor : swingLowTextColor

        label newLabel = label.new(
             x=_x,
             y=textPrice,
             text=_text,
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_none,
             textcolor=textColor,
             size=size.small)

        array.push(swingLabels, newLabel)
        array.push(swingLabelIds, _id)

        f_trim_swing_labels()

f_add_wick_liquidity_zone(bool _fromSwingHigh, int _x, float _swingPrice, float _bodyTop, float _bodyBottom, int _id) =>
    float zoneTop = _fromSwingHigh ? _swingPrice : _bodyBottom
    float zoneBot = _fromSwingHigh ? _bodyTop : _swingPrice
    float wickSize = math.max(zoneTop - zoneBot, 0.0)

    if wickSize > syminfo.mintick
        color zoneColor = _fromSwingHigh ? swingHighZoneColor : swingLowZoneColor
        color borderColor = _fromSwingHigh ? swingHighBorderColor : swingLowBorderColor
        color textColor = _fromSwingHigh ? swingHighTextColor : swingLowTextColor

        float startFillLevel = _fromSwingHigh ? zoneBot : zoneTop
        float liquidityMoney = f_wick_liquidity_money(_fromSwingHigh, _swingPrice, _bodyTop, _bodyBottom)

        box newZone = box.new(
             left=_x,
             top=zoneTop,
             right=bar_index,
             bottom=zoneBot,
             xloc=xloc.bar_index,
             bgcolor=zoneColor,
             border_color=borderColor)

        box newFilledZone = na

        f_set_box_text(newZone, "Left: " + f_format_money(liquidityMoney), textColor)

        array.push(zoneBoxes, newZone)
        array.push(filledZoneBoxes, newFilledZone)
        array.push(zoneIds, _id)
        array.push(zoneFromSwingHigh, _fromSwingHigh)
        array.push(zoneOrigTops, zoneTop)
        array.push(zoneOrigBots, zoneBot)
        array.push(zoneFillLevels, startFillLevel)
        array.push(zoneFull, false)
        array.push(zoneLiquidityMoney, liquidityMoney)

        f_trim_zones()

f_create_swing(bool _isSwingHigh, int _bar, float _price, float _bodyTop, float _bodyBottom, int _id) =>
    if _isSwingHigh
        f_add_swing_label(_bar, _price, swingHighText, true, _id)

        if showLiquidityBlocks
            f_add_wick_liquidity_zone(true, _bar, _price, _bodyTop, _bodyBottom, _id)
    else
        f_add_swing_label(_bar, _price, swingLowText, false, _id)

        if showLiquidityBlocks
            f_add_wick_liquidity_zone(false, _bar, _price, _bodyTop, _bodyBottom, _id)

// Liquidity zones
zoneCount = array.size(zoneBoxes)

if zoneCount > 0
    for loopIndex = 0 to zoneCount - 1
        int i = zoneCount - 1 - loopIndex

        box activeZone = array.get(zoneBoxes, i)
        box filledZone = array.get(filledZoneBoxes, i)

        bool fromSwingHigh = array.get(zoneFromSwingHigh, i)
        float origTop = array.get(zoneOrigTops, i)
        float origBot = array.get(zoneOrigBots, i)
        float fillLevel = array.get(zoneFillLevels, i)
        bool isFull = array.get(zoneFull, i)
        float totalLiquidityMoney = array.get(zoneLiquidityMoney, i)

        if not isFull
            box.set_right(activeZone, bar_index)

            if not na(filledZone)
                box.set_right(filledZone, bar_index)

            if fromSwingHigh and high > origBot
                float newFillLevel = math.max(fillLevel, math.min(high, origTop))
                bool hasFilledPart = newFillLevel > origBot
                bool fullNow = newFillLevel >= origTop

                if hasFilledPart
                    float filledMoney = f_filled_liquidity_money(totalLiquidityMoney, origTop, origBot, newFillLevel, true)
                    float leftMoney = math.max(totalLiquidityMoney - filledMoney, 0.0)

                    if na(filledZone)
                        filledZone := box.new(
                             left=box.get_left(activeZone),
                             top=newFillLevel,
                             right=bar_index,
                             bottom=origBot,
                             xloc=xloc.bar_index,
                             bgcolor=filledZoneColor,
                             border_color=filledBorderColor)

                        array.set(filledZoneBoxes, i, filledZone)
                    else
                        box.set_top(filledZone, newFillLevel)
                        box.set_bottom(filledZone, origBot)
                        box.set_right(filledZone, bar_index)

                    if hideFilledZones
                        f_hide_box(filledZone)
                    else
                        box.set_bgcolor(filledZone, filledZoneColor)
                        box.set_border_color(filledZone, filledBorderColor)
                        f_set_box_text(filledZone, "Filled: " + f_format_money(filledMoney), color.gray)

                    f_set_box_text(activeZone, "Left: " + f_format_money(leftMoney), swingHighTextColor)
                    array.set(zoneFillLevels, i, newFillLevel)

                if fullNow
                    array.set(zoneFull, i, true)

                    if hideFilledZones
                        f_hide_box(activeZone)
                        f_hide_box(filledZone)
                    else
                        box.set_bgcolor(activeZone, color.new(color.red, 100))
                        box.set_border_color(activeZone, color.new(color.red, 100))
                        box.set_text(activeZone, "")

                    box.set_right(activeZone, bar_index)

                    if not na(filledZone)
                        box.set_right(filledZone, bar_index)
                else
                    box.set_top(activeZone, origTop)
                    box.set_bottom(activeZone, newFillLevel)

            if not fromSwingHigh and low < origTop
                float newFillLevel = math.min(fillLevel, math.max(low, origBot))
                bool hasFilledPart = newFillLevel < origTop
                bool fullNow = newFillLevel <= origBot

                if hasFilledPart
                    float filledMoney = f_filled_liquidity_money(totalLiquidityMoney, origTop, origBot, newFillLevel, false)
                    float leftMoney = math.max(totalLiquidityMoney - filledMoney, 0.0)

                    if na(filledZone)
                        filledZone := box.new(
                             left=box.get_left(activeZone),
                             top=origTop,
                             right=bar_index,
                             bottom=newFillLevel,
                             xloc=xloc.bar_index,
                             bgcolor=filledZoneColor,
                             border_color=filledBorderColor)

                        array.set(filledZoneBoxes, i, filledZone)
                    else
                        box.set_top(filledZone, origTop)
                        box.set_bottom(filledZone, newFillLevel)
                        box.set_right(filledZone, bar_index)

                    if hideFilledZones
                        f_hide_box(filledZone)
                    else
                        box.set_bgcolor(filledZone, filledZoneColor)
                        box.set_border_color(filledZone, filledBorderColor)
                        f_set_box_text(filledZone, "Filled: " + f_format_money(filledMoney), color.gray)

                    f_set_box_text(activeZone, "Left: " + f_format_money(leftMoney), swingLowTextColor)
                    array.set(zoneFillLevels, i, newFillLevel)

                if fullNow
                    array.set(zoneFull, i, true)

                    if hideFilledZones
                        f_hide_box(activeZone)
                        f_hide_box(filledZone)
                    else
                        box.set_bgcolor(activeZone, color.new(color.lime, 100))
                        box.set_border_color(activeZone, color.new(color.lime, 100))
                        box.set_text(activeZone, "")

                    box.set_right(activeZone, bar_index)

                    if not na(filledZone)
                        box.set_right(filledZone, bar_index)
                else
                    box.set_top(activeZone, newFillLevel)
                    box.set_bottom(activeZone, origBot)

// Swing logic
if not na(pivotHigh)
    float swingHighPrice = pivotHigh
    bool addSwingHigh = false
    bool replaceSwingHigh = false

    if not useCleanSwingFilter
        addSwingHigh := true
    else if lastSwingType == 0
        addSwingHigh := true
    else if lastSwingType == 1
        replaceSwingHigh := swingHighPrice > lastSwingPrice
    else if lastSwingType == -1
        addSwingHigh := math.abs(swingHighPrice - lastSwingPrice) >= atrValue * minSwingMoveAtr and f_bars_ok(pivotBar)

    if replaceSwingHigh
        f_delete_current_swing_objects()

        nextSwingId += 1

        f_create_swing(true, pivotBar, swingHighPrice, pivotBodyTop, pivotBodyBottom, nextSwingId)

        lastSwingType := 1
        lastSwingPrice := swingHighPrice
        lastSwingBar := pivotBar
        lastSwingId := nextSwingId

    if addSwingHigh
        nextSwingId += 1

        f_create_swing(true, pivotBar, swingHighPrice, pivotBodyTop, pivotBodyBottom, nextSwingId)

        lastSwingType := 1
        lastSwingPrice := swingHighPrice
        lastSwingBar := pivotBar
        lastSwingId := nextSwingId

if not na(pivotLow)
    float swingLowPrice = pivotLow
    bool addSwingLow = false
    bool replaceSwingLow = false

    if not useCleanSwingFilter
        addSwingLow := true
    else if lastSwingType == 0
        addSwingLow := true
    else if lastSwingType == -1
        replaceSwingLow := swingLowPrice < lastSwingPrice
    else if lastSwingType == 1
        addSwingLow := math.abs(swingLowPrice - lastSwingPrice) >= atrValue * minSwingMoveAtr and f_bars_ok(pivotBar)

    if replaceSwingLow
        f_delete_current_swing_objects()

        nextSwingId += 1

        f_create_swing(false, pivotBar, swingLowPrice, pivotBodyTop, pivotBodyBottom, nextSwingId)

        lastSwingType := -1
        lastSwingPrice := swingLowPrice
        lastSwingBar := pivotBar
        lastSwingId := nextSwingId

    if addSwingLow
        nextSwingId += 1

        f_create_swing(false, pivotBar, swingLowPrice, pivotBodyTop, pivotBodyBottom, nextSwingId)

        lastSwingType := -1
        lastSwingPrice := swingLowPrice
        lastSwingBar := pivotBar
        lastSwingId := nextSwingId
````
