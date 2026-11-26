# Swing Liquidity Zones

- url: https://www.tradingview.com/script/W2rqgUTa-Swing-Liquidity-Zones/
- type: indicator
- pine_id: PUB;bb3d0fef6fbe4bf2a69cbf0581dd5779
- version: 1.0

## Description

Swing Liquidity Zones is a chart overlay for marking confirmed swing highs and swing lows, then building wick-based liquidity zones from those swing candles.

The indicator focuses on price action structure. It highlights the upper wick of confirmed swing highs as buy-side liquidity areas and the lower wick of confirmed swing lows as sell-side liquidity areas. These zones help keep important historical wick areas visible on the chart without manually drawing them.

[b]What it shows[/b]
[list]
[*]Confirmed swing highs and swing lows;
[*]Buy-side liquidity zones above swing high candle bodies;
[*]Sell-side liquidity zones below swing low candle bodies;
[*]Zones extended forward on the chart;
[*]Filled and unfilled parts of each zone;
[*]Optional estimated wick value based on OHLCV data;
[*]Optional clean swing filter for a less crowded structure view.
[/list]

[b]How the zones are built[/b]

When a swing high is confirmed, the script uses the area between the pivot candle body top and the candle high to create an upper liquidity zone. When a swing low is confirmed, the script uses the area between the pivot candle body bottom and the candle low to create a lower liquidity zone.

The result is a visual map of swing wick areas that traders can review later when price returns to previous highs, previous lows, rejection areas, or important structure points.

[b]Swing confirmation[/b]

The script uses pivot logic. A swing is confirmed only after the required number of candles has closed on the right side of the pivot.

Because of this, zones appear after confirmation and are plotted back on the pivot candle for visual clarity. This is normal behavior for pivot-based tools and helps avoid marking swings before they are confirmed.

[b]Clean swing filter[/b]

The optional clean swing filter helps reduce noise by keeping a more structured sequence of swings.

If several swing highs appear before a swing low is confirmed, the script keeps the highest swing high. If several swing lows appear before a swing high is confirmed, the script keeps the lowest swing low.

The filter can also use minimum bar spacing and ATR-based distance, so very small structure changes are less likely to clutter the chart.

[b]Zone tracking[/b]

After a zone is created, it extends to the right as new candles form. When price trades back into a zone, the script adjusts the zone to show which part has already been traded through and which part remains unfilled.

Filled areas can be hidden for a cleaner view or displayed separately, depending on the user settings.

[b]Estimated wick value[/b]

The script can show an estimated wick value for each zone.

This estimate is calculated from candle volume, wick size relative to the candle range, and the approximate midpoint price of the wick. It is intended only as a relative comparison between zones.

A larger wick with higher candle volume may display a larger value than a smaller wick with lower volume. The value should not be treated as an exact measurement of real market liquidity or available orders.

[b]How to use it[/b]

Swing Liquidity Zones is best used as a visual structure and planning tool.

Traders may compare the zones with higher timeframe direction, support and resistance, session highs and lows, VWAP, volume behavior, candle closes, market structure shifts, fair value gaps, order blocks, trend context, and invalidation levels.

A zone by itself is not a trade signal. It is an area of interest that should be reviewed together with a complete trading plan and independent confirmation.

[b]Limitations and Disclaimer[/b]

Swing Liquidity Zones is intended for educational and analytical use only.

The indicator does not provide financial advice, investment advice, trade recommendations, entry signals, exit signals, stop loss levels, take profit levels, or guaranteed outcomes.

The zones are created from confirmed pivot candle wick areas and standard OHLCV chart data. They do not represent live exchange liquidity, order book depth, resting orders, liquidation levels, or the exact location of market participant orders.

Swing points are confirmed with delay because the script uses pivot logic. Estimated wick values depend on the quality of the symbol’s volume data and should only be used as a relative visual reference.

[i]Trading and investing involve risk. Every trader is responsible for their own analysis, risk management, execution, and financial decisions.[/i]

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.
// Swing-based liquidity zone tool.
// Zones are created from confirmed swing pivot candle wicks.
// Estimated values are calculated from candle OHLCV data only.
// This script does not use order book data, exchange depth, or future data.

//@version=6
indicator("Swing Liquidity Zones", overlay=true, max_labels_count=500, max_boxes_count=500)

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
showLiquidityZones = input.bool(true, "Show Liquidity Zones", group=generalSettingsGroup)
showEstimatedWickValue = input.bool(true, "Show Estimated Wick Value", group=generalSettingsGroup)
hideFilledZones = input.bool(true, "Hide Filled Zone Areas", group=generalSettingsGroup)
swingHighText = input.string("Swing High", "Swing High Text", group=generalSettingsGroup)
swingLowText = input.string("Swing Low", "Swing Low Text", group=generalSettingsGroup)

swingHighTextColor = input.color(color.red, "Swing High Text Color", group=colorSettingsGroup)
swingLowTextColor = input.color(color.lime, "Swing Low Text Color", group=colorSettingsGroup)
swingHighZoneColor = input.color(color.new(color.red, 85), "Buy-Side Liquidity Zone", group=colorSettingsGroup)
swingLowZoneColor = input.color(color.new(color.lime, 85), "Sell-Side Liquidity Zone", group=colorSettingsGroup)
swingHighBorderColor = input.color(color.new(color.red, 15), "Buy-Side Zone Border", group=colorSettingsGroup)
swingLowBorderColor = input.color(color.new(color.lime, 15), "Sell-Side Zone Border", group=colorSettingsGroup)
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
var float[] zoneEstimatedWickValue = array.new_float()

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

// Estimated wick value only.
// Formula uses candle volume, wick share of candle range, and wick midpoint price.
// It is not live liquidity, not order book depth, and not available market orders.
f_estimated_wick_value(bool _fromSwingHigh, float _swingPrice, float _bodyTop, float _bodyBottom) =>
    float candleHigh = high[rightBars]
    float candleLow = low[rightBars]
    float candleRange = math.max(candleHigh - candleLow, syminfo.mintick)
    float candleVolume = nz(volume[rightBars], 0.0)

    float wickSize = _fromSwingHigh ? math.max(_swingPrice - _bodyTop, 0.0) : math.max(_bodyBottom - _swingPrice, 0.0)
    float wickShare = math.min(wickSize / candleRange, 1.0)
    float wickMidPrice = _fromSwingHigh ? (_swingPrice + _bodyTop) / 2.0 : (_bodyBottom + _swingPrice) / 2.0

    candleVolume * wickShare * wickMidPrice

f_filled_estimated_wick_value(float _totalValue, float _origTop, float _origBot, float _newFillLevel, bool _fromSwingHigh) =>
    float zoneSize = math.max(_origTop - _origBot, syminfo.mintick)
    float filledPart = _fromSwingHigh ? math.max(_newFillLevel - _origBot, 0.0) : math.max(_origTop - _newFillLevel, 0.0)
    float filledPercent = math.min(filledPart / zoneSize, 1.0)

    _totalValue * filledPercent

f_set_box_text(box _box, string _text, color _textColor) =>
    if not na(_box)
        box.set_text(_box, showEstimatedWickValue ? _text : "")
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
        array.remove(zoneEstimatedWickValue, _index)

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

f_add_liquidity_zone(bool _fromSwingHigh, int _x, float _swingPrice, float _bodyTop, float _bodyBottom, int _id) =>
    float zoneTop = _fromSwingHigh ? _swingPrice : _bodyBottom
    float zoneBot = _fromSwingHigh ? _bodyTop : _swingPrice
    float wickSize = math.max(zoneTop - zoneBot, 0.0)

    if wickSize > syminfo.mintick
        color zoneColor = _fromSwingHigh ? swingHighZoneColor : swingLowZoneColor
        color borderColor = _fromSwingHigh ? swingHighBorderColor : swingLowBorderColor
        color textColor = _fromSwingHigh ? swingHighTextColor : swingLowTextColor

        float startFillLevel = _fromSwingHigh ? zoneBot : zoneTop
        float estimatedWickValue = f_estimated_wick_value(_fromSwingHigh, _swingPrice, _bodyTop, _bodyBottom)

        box newZone = box.new(
             left=_x,
             top=zoneTop,
             right=bar_index,
             bottom=zoneBot,
             xloc=xloc.bar_index,
             bgcolor=zoneColor,
             border_color=borderColor)

        box newFilledZone = na

        f_set_box_text(newZone, "Unfilled: " + f_format_money(estimatedWickValue), textColor)

        array.push(zoneBoxes, newZone)
        array.push(filledZoneBoxes, newFilledZone)
        array.push(zoneIds, _id)
        array.push(zoneFromSwingHigh, _fromSwingHigh)
        array.push(zoneOrigTops, zoneTop)
        array.push(zoneOrigBots, zoneBot)
        array.push(zoneFillLevels, startFillLevel)
        array.push(zoneFull, false)
        array.push(zoneEstimatedWickValue, estimatedWickValue)

        f_trim_zones()

f_create_swing(bool _isSwingHigh, int _bar, float _price, float _bodyTop, float _bodyBottom, int _id) =>
    if _isSwingHigh
        f_add_swing_label(_bar, _price, swingHighText, true, _id)

        if showLiquidityZones
            f_add_liquidity_zone(true, _bar, _price, _bodyTop, _bodyBottom, _id)
    else
        f_add_swing_label(_bar, _price, swingLowText, false, _id)

        if showLiquidityZones
            f_add_liquidity_zone(false, _bar, _price, _bodyTop, _bodyBottom, _id)

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
        float totalEstimatedWickValue = array.get(zoneEstimatedWickValue, i)

        if not isFull
            box.set_right(activeZone, bar_index)

            if not na(filledZone)
                box.set_right(filledZone, bar_index)

            if fromSwingHigh and high > origBot
                float newFillLevel = math.max(fillLevel, math.min(high, origTop))
                bool hasFilledPart = newFillLevel > origBot
                bool fullNow = newFillLevel >= origTop

                if hasFilledPart
                    float filledEstimatedValue = f_filled_estimated_wick_value(totalEstimatedWickValue, origTop, origBot, newFillLevel, true)
                    float remainingEstimatedValue = math.max(totalEstimatedWickValue - filledEstimatedValue, 0.0)

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
                        f_set_box_text(filledZone, "Filled: " + f_format_money(filledEstimatedValue), color.gray)

                    f_set_box_text(activeZone, "Unfilled: " + f_format_money(remainingEstimatedValue), swingHighTextColor)
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
                    float filledEstimatedValue = f_filled_estimated_wick_value(totalEstimatedWickValue, origTop, origBot, newFillLevel, false)
                    float remainingEstimatedValue = math.max(totalEstimatedWickValue - filledEstimatedValue, 0.0)

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
                        f_set_box_text(filledZone, "Filled: " + f_format_money(filledEstimatedValue), color.gray)

                    f_set_box_text(activeZone, "Unfilled: " + f_format_money(remainingEstimatedValue), swingLowTextColor)
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
