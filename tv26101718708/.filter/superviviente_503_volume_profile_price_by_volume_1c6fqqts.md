# Superviviente 503 Volume Profile  Price by Volume

- url: https://www.tradingview.com/script/1c6FQqTs/
- type: indicator
- pine_id: PUB;db11c49825374329bb1f599c40506ce5
- version: 1.0

## Description

Overview
The Volume Profile Visible Range indicator by Superviviente 503 is a professional-grade volume analysis tool designed to identify critical institutional liquidity levels directly on your chart. Originally locked behind paid TradingView plans, this script is now completely free for the community, serving as the core indicator used during daily live streaming sessions.

Key Features

Visible Range & Fixed Range Modes: Automatically adapts to the current visible chart range or a custom fixed lookback period to analyze trading activity over specific market structures.

Point of Control (POC): Highlights the exact price level with the highest traded volume, acting as a major magnet and pivot level for price action.

Value Area (VAH & VAL): Clearly maps out the 70% institutional value area, helping you spot acceptance, rejection, and breakout zones.

Volume Nodes: Identifies High Volume Nodes (HVN) for accumulation/distribution zones and Low Volume Nodes (LVN) for areas of rapid price rejection.

Customizable Price Scale Labels: Clean, native-style price labels on the right-hand price scale for VAH, POC, and VAL, keeping your chart uncluttered.

How to Use

Add the indicator to your chart.

Configure the lookback range (Visible Range recommended for dynamic scalping).

Use the POC and Value Area boundaries to plan your entries, exits, and risk management during active trading sessions (such as the Tokyo session).

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Superviviente 503 — Volume Profile (Pine Script v6)

//@version=6
indicator(
     title = 'Superviviente 503 — Volume Profile / Price by Volume',
     shorttitle = 'VolProfile',
     overlay = true,
     max_bars_back = 5000,
     max_lines_count = 500,
     max_labels_count = 500,
     max_boxes_count = 1000)

// ── Inputs ────────────────────────────────────────────────────────────────────

group_volume_profile   = 'Volume Profile / Price by Volume'
tooltip_volume_profile = 'Volume Profile (also known as Price by Volume) displays trading activity over a specified time period at specific price levels.'

volumeProfile       = input.bool(true, 'Volume Profile', group = group_volume_profile, tooltip = tooltip_volume_profile)
vpLookbackRange     = input.string('Visible Range', 'VP and SD Lookback Range', options = ['Fixed Range', 'Visible Range'], group = group_volume_profile)
lookbackLengthInput = input.int(200, 'VP and SD Fixed Range : Lookback Length', minval = 10, maxval = 5000, step = 10, group = group_volume_profile)

avgVolNodeCol  = input.color(color.new(#787b86, 25), 'Volume Nodes : AVN', inline = 'col', group = group_volume_profile)
highVolNodeCol = input.color(color.new(#f57c00, 50), 'HVN', inline = 'col', group = group_volume_profile)
lowVolNodeCol  = input.color(color.new(#787b86, 75), 'LVN', inline = 'col', group = group_volume_profile)

isValueArea    = input.float(70, 'Value Area Volume %', minval = 0, maxval = 100, group = group_volume_profile) / 100
valueAreaFill  = input.bool(true, 'Fill Value Area (VAH to VAL)', group = group_volume_profile, tooltip = 'Draw a colored box over the value area (70% institutional value) from VAL to VAH.')
valueAreaFillCol = input.color(color.new(#2962ff, 85), 'Value Area Fill Color', group = group_volume_profile)
vpWidthPct     = input.int(100, 'Width of VP', minval = 10, maxval = 200, step = 5, group = group_volume_profile, tooltip = 'Profile histogram width as a percentage of the maximum width.')
vpLocation     = input.string('Left', 'Location', options = ['Left', 'Right'], group = group_volume_profile, tooltip = 'Place the volume profile on the left or right side of the lookback range.')

valueAreaHigh  = input.bool(false, 'VAH', inline = 'VAH', group = group_volume_profile)
vahColor       = input.color(color.new(#ffeb3b, 0), '', inline = 'VAH', group = group_volume_profile)
vahStyle       = input.string('Solid', 'Style', options = ['Solid', 'Dashed', 'Dotted'], inline = 'VAH', group = group_volume_profile)
vahWidth       = input.int(2, 'Width', minval = 1, maxval = 10, inline = 'VAH', group = group_volume_profile)

pointOfControl = input.bool(true, 'POC', inline = 'POC', group = group_volume_profile)
pocColor       = input.color(color.new(#ff0000, 0), '', inline = 'POC', group = group_volume_profile)
pocStyle       = input.string('Solid', 'Style', options = ['Solid', 'Dashed', 'Dotted'], inline = 'POC', group = group_volume_profile)
pocWidth       = input.int(2, 'Width', minval = 1, maxval = 10, inline = 'POC', group = group_volume_profile)

valueAreaLow   = input.bool(false, 'VAL', inline = 'VAL', group = group_volume_profile)
valColor       = input.color(color.new(#ffeb3b, 0), '', inline = 'VAL', group = group_volume_profile)
valStyle       = input.string('Solid', 'Style', options = ['Solid', 'Dashed', 'Dotted'], inline = 'VAL', group = group_volume_profile)
valWidth       = input.int(2, 'Width', minval = 1, maxval = 10, inline = 'VAL', group = group_volume_profile)

priceLevels     = input.bool(false, 'Show Profile Price Levels', inline = 'BBe', group = group_volume_profile)
priceScaleLabels = input.bool(true, 'Labels on Price Scale (right)', group = group_volume_profile, tooltip = 'Anchors the VAH/POC/VAL labels to the right edge of the chart (on the price scale), like TradingView\'s native Volume Profile. Disable to keep the labels next to the profile.')
labelBoxColor   = input.color(color.new(#2a2e39, 0), 'Box', inline = 'BBe', group = group_volume_profile)
labelTextColor  = input.color(color.new(#ffffff, 0), 'Text', inline = 'BBe', group = group_volume_profile)
profileLevels   = input.int(100, 'Number of Rows', minval = 10, maxval = 200, step = 10, group = group_volume_profile)
horizontalOffset = input.int(1, 'Horizontal Offset', minval = 0, maxval = 100, group = group_volume_profile)

valueAreaTV  = input.bool(true, 'Value Area : TradingView (stop before overshoot)', group = group_volume_profile, tooltip = 'TradingView stops expanding the value area before exceeding the target volume. Disable to use the classic method that includes the row crossing the target.')

alignRowsToTicks = input.bool(true, 'Align Rows to Tick Grid', group = group_volume_profile, tooltip = 'Align row boundaries to tick grid (like TradingView native VP). When off, rows span exact wick-to-wick range.')

color transparent = color.new(color.black, 100)

// ── Fixed-range high / low ────────────────────────────────────────────────────

priceHighestFR = ta.highest(high, lookbackLengthInput)
priceLowestFR  = ta.lowest(low, lookbackLengthInput)

// ── Series helpers ────────────────────────────────────────────────────────────

float nzVolume = nz(volume)

// ── Visible-range lookback ────────────────────────────────────────────────────

var int startBarIndexX = 0

if time == chart.left_visible_bar_time and vpLookbackRange == 'Visible Range'
    startBarIndexX := bar_index

int lookbackLength = vpLookbackRange == 'Visible Range' ? last_bar_index - startBarIndexX + 1 : lookbackLengthInput

// ── Drawing helpers ───────────────────────────────────────────────────────────

f_drawLabelX(_x, _y, _text, _xloc, _yloc, _bgcolor, _style, _textcolor, _size, _textalign, _tooltip) =>
    var label id = label.new(_x, _y, _text, _xloc, _yloc, _bgcolor, _style, _textcolor, _size, _textalign, _tooltip)
    label.set_xy(id, _x, _y)
    label.set_text(id, _text)
    label.set_tooltip(id, _tooltip)
    label.set_textcolor(id, _textcolor)
    label.set_color(id, _bgcolor)

f_drawLineX(_x1, _y1, _x2, _y2, _xloc, _extend, _color, _style, _width) =>
    var line id = line.new(_x1, _y1, _x2, _y2, _xloc, _extend, _color, _style, _width)
    line.set_xy1(id, _x1, _y1)
    line.set_xy2(id, _x2, _y2)
    line.set_color(id, _color)
    line.set_style(id, _style)
    line.set_width(id, _width)

f_styleFromString(_s) =>
    switch _s
        'Dashed' => line.style_dashed
        'Dotted' => line.style_dotted
        => line.style_solid

// ── Visible-range high/low ────────────────────────────────────────────────────

f_getHighLow() =>
    var float htf_h = 0.
    var float htf_l = 0.

    if vpLookbackRange == 'Visible Range'
        if time == chart.left_visible_bar_time
            htf_l := low
            htf_h := high
        else if time > chart.left_visible_bar_time
            htf_l := math.min(low, htf_l)
            htf_h := math.max(high, htf_h)
    else
        htf_h := priceHighestFR
        htf_l := priceLowestFR

    [htf_h, htf_l]

// ── Volume profile calculation & drawing ──────────────────────────────────────

[priceHighest, priceLowest] = f_getHighLow()

float tickSize = syminfo.mintick

float gridLow  = math.floor(priceLowest / tickSize) * tickSize
float gridHigh = math.ceil(priceHighest / tickSize) * tickSize

float profileLow  = alignRowsToTicks ? gridLow : priceLowest
float profileHigh = alignRowsToTicks ? gridHigh : priceHighest

int   profileRows = profileLevels
float priceStep   = (profileHigh - profileLow) / profileRows

float barPriceLow  = low
float barPriceHigh = high

var int levelAbovePoc = 0
var int levelBelowPoc = 0
var int pocLevel      = 0

array<float> volumeStorage  = array.new<float>(profileRows + 1, 0.)
var array<box> a_profile    = array.new<box>()

if barstate.islast and nzVolume > 0
    if array.size(a_profile) > 0
        for i = 1 to array.size(a_profile)
            box.delete(array.shift(a_profile))

    // Standard OHLC method
    for barIndex = 0 to lookbackLength - 1
        for level = 0 to profileRows - 1
            float levelLow  = profileLow + level * priceStep
            if barPriceHigh[barIndex] >= levelLow and barPriceLow[barIndex] < levelLow + priceStep
                float volShare = (barPriceHigh[barIndex] - barPriceLow[barIndex]) == 0 ? 1 : priceStep / (barPriceHigh[barIndex] - barPriceLow[barIndex])
                array.set(volumeStorage, level, array.get(volumeStorage, level) + nzVolume[barIndex] * volShare)

    // Improved POC selection: if multiple rows tie for max volume, pick the one closest to profile center (TV-like)
    float maxVol = array.max(volumeStorage)
    pocLevel := -1
    float bestDist = -1.0
    float profileCenter = (profileLow + profileHigh) / 2.0
    for i = 0 to profileRows - 1
        if array.get(volumeStorage, i) == maxVol
            float rowCenter = profileLow + (i + 0.5) * priceStep
            float dist = math.abs(rowCenter - profileCenter)
            if pocLevel == -1 or dist < bestDist
                pocLevel := i
                bestDist := dist

    float totalVolumeTraded = array.sum(volumeStorage) * isValueArea
    float valueArea         = array.get(volumeStorage, pocLevel)

    levelAbovePoc := pocLevel
    levelBelowPoc := pocLevel

    while valueArea < totalVolumeTraded
        if levelBelowPoc == 0 and levelAbovePoc == profileRows - 1
            break

        float volumeAbovePoc = levelAbovePoc < profileRows - 1 ? array.get(volumeStorage, levelAbovePoc + 1) : 0.
        float volumeBelowPoc = levelBelowPoc > 0 ? array.get(volumeStorage, levelBelowPoc - 1) : 0.

        bool takeAbove = false
        if valueAreaTV and volumeAbovePoc > 0. and volumeBelowPoc > 0. and volumeAbovePoc == volumeBelowPoc
            float distAbove = float(levelAbovePoc + 1 - pocLevel)
            float distBelow = float(pocLevel - (levelBelowPoc - 1))
            takeAbove := distAbove <= distBelow
        else
            takeAbove := volumeAbovePoc >= volumeBelowPoc

        if takeAbove
            if valueAreaTV and valueArea + volumeAbovePoc > totalVolumeTraded
                break
            valueArea     += volumeAbovePoc
            levelAbovePoc += 1
        else
            if valueAreaTV and valueArea + volumeBelowPoc > totalVolumeTraded
                break
            valueArea     += volumeBelowPoc
            levelBelowPoc -= 1

    bool  vpOnRight     = vpLocation == 'Right'
    int   maxVpBars     = math.max(1, int(41.0 * vpWidthPct / 100.0))
    int   lookbackStart = bar_index - lookbackLength + 1
    int   profileAnchor = vpOnRight ? bar_index + horizontalOffset + 50 : lookbackStart + horizontalOffset
    int   lineStartX    = vpOnRight ? lookbackStart : profileAnchor + maxVpBars + 1
    int   lineEndX      = vpOnRight ? (volumeProfile ? profileAnchor : bar_index + 7) : bar_index + 7
    int   borderLeft    = vpOnRight ? lookbackStart : profileAnchor
    int   borderRight   = vpOnRight ? profileAnchor : profileAnchor + maxVpBars + 1
    int   labelEdgeX    = vpOnRight ? profileAnchor : profileAnchor + maxVpBars + 1
    int   labelLevelX   = vpOnRight ? profileAnchor + 7 : profileAnchor + maxVpBars + 8
    string edgeLabelStyle = label.style_label_left
    string levelLabelStyle = label.style_label_left

    color vahLineColor = valueAreaHigh ? vahColor : transparent
    color pocLineColor = pointOfControl ? pocColor : transparent
    color valLineColor = valueAreaLow ? valColor : transparent

    vahLineStyle = f_styleFromString(vahStyle)
    pocLineStyle = f_styleFromString(pocStyle)
    valLineStyle = f_styleFromString(valStyle)

    float vahPrice = math.round_to_mintick(profileLow + (levelAbovePoc + 1.00) * priceStep)
    float pocPrice = math.round_to_mintick(profileLow + (pocLevel + 0.50) * priceStep)
    float valPrice = math.round_to_mintick(profileLow + (levelBelowPoc + 0.00) * priceStep)

    f_drawLineX(lineStartX, vahPrice, lineEndX, vahPrice, xloc.bar_index, extend.none, vahLineColor, vahLineStyle, vahWidth)
    f_drawLineX(lineStartX, pocPrice, lineEndX, pocPrice, xloc.bar_index, extend.none, pocLineColor, pocLineStyle, pocWidth)
    f_drawLineX(lineStartX, valPrice, lineEndX, valPrice, xloc.bar_index, extend.none, valLineColor, valLineStyle, valWidth)

    bool  onScale = priceScaleLabels and not na(chart.right_visible_bar_time)

    if priceLevels
        f_drawLabelX(labelEdgeX, priceHighest, str.tostring(priceHighest, format.mintick), xloc.bar_index, yloc.price, labelBoxColor, edgeLabelStyle, labelTextColor, size.normal, text.align_left, 'Profile High - during last ' + str.tostring(lookbackLength) + ' bars\n %' + str.tostring((priceHighest - priceLowest) / priceLowest * 100, '#.##') + ' higher than the Profile Low')
        f_drawLabelX(labelEdgeX, priceLowest, str.tostring(priceLowest, format.mintick), xloc.bar_index, yloc.price, labelBoxColor, label.style_label_up, labelTextColor, size.normal, text.align_left, 'Profile Low - during last ' + str.tostring(lookbackLength) + ' bars\n %' + str.tostring((priceHighest - priceLowest) / priceHighest * 100, '#.##') + ' lower than the Profile High')

        if onScale
            f_drawLabelX(chart.right_visible_bar_time, vahPrice, str.tostring(vahPrice, format.mintick), xloc.bar_time, yloc.price, valueAreaHigh ? labelBoxColor : transparent, levelLabelStyle, valueAreaHigh ? labelTextColor : transparent, size.normal, text.align_left, 'Value Area High Price')
            f_drawLabelX(chart.right_visible_bar_time, pocPrice, str.tostring(pocPrice, format.mintick), xloc.bar_time, yloc.price, pointOfControl ? labelBoxColor : transparent, levelLabelStyle, pointOfControl ? labelTextColor : transparent, size.normal, text.align_left, 'Point Of Control Price')
            f_drawLabelX(chart.right_visible_bar_time, valPrice, str.tostring(valPrice, format.mintick), xloc.bar_time, yloc.price, valueAreaLow ? labelBoxColor : transparent, levelLabelStyle, valueAreaLow ? labelTextColor : transparent, size.normal, text.align_left, 'Value Area Low Price')
        else
            f_drawLabelX(labelLevelX, vahPrice, str.tostring(vahPrice, format.mintick), xloc.bar_index, yloc.price, valueAreaHigh ? labelBoxColor : transparent, levelLabelStyle, valueAreaHigh ? labelTextColor : transparent, size.normal, text.align_left, 'Value Area High Price')
            f_drawLabelX(labelLevelX, pocPrice, str.tostring(pocPrice, format.mintick), xloc.bar_index, yloc.price, pointOfControl ? labelBoxColor : transparent, levelLabelStyle, pointOfControl ? labelTextColor : transparent, size.normal, text.align_left, 'Point Of Control Price')
            f_drawLabelX(labelLevelX, valPrice, str.tostring(valPrice, format.mintick), xloc.bar_index, yloc.price, valueAreaLow ? labelBoxColor : transparent, levelLabelStyle, valueAreaLow ? labelTextColor : transparent, size.normal, text.align_left, 'Value Area Low Price')

    for level = 0 to profileRows - 1
        float levelVol = array.get(volumeStorage, level)
        float volRatio = levelVol / maxVol
        int   barWidth = int(volRatio * maxVpBars)

        if volumeProfile
            color levelColor = volRatio > 0.8 ? highVolNodeCol : volRatio < 0.2 ? lowVolNodeCol : avgVolNodeCol
            int boxLeft  = vpOnRight ? profileAnchor - 1 - barWidth : profileAnchor
            int boxRight = vpOnRight ? profileAnchor : profileAnchor + 1 + barWidth
            array.push(a_profile, box.new(
                 boxLeft,
                 profileLow + (level + 0.00) * priceStep,
                 boxRight,
                 profileLow + (level + 1.00) * priceStep,
                 border_color = levelColor,
                 bgcolor = levelColor))

    if volumeProfile
        array.push(a_profile, box.new(
             borderLeft,
             priceLowest,
             borderRight,
             priceHighest,
             border_color = color.new(color.gray, 37),
             border_width = 1,
             border_style = line.style_dotted,
             bgcolor = transparent))

    if valueAreaFill
        array.push(a_profile, box.new(
             lookbackStart,
             valPrice,
             bar_index + 7,
             vahPrice,
             border_color = transparent,
             bgcolor = valueAreaFillCol))
````
