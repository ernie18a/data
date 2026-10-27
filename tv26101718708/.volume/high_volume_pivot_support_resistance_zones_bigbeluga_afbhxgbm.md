# High Volume Pivot Support & Resistance Zones [BigBeluga]

- url: https://www.tradingview.com/script/AFbHxgBM-High-Volume-Pivot-Support-Resistance-Zones-BigBeluga/
- type: indicator
- pine_id: PUB;f4302603588044ba9b3e619628f552af
- version: 1.0

## Description

[b]High Volume Pivot Support & Resistance Zones [BigBeluga][/b] is a market-structure indicator built for TradingView. It helps traders find key support and resistance levels by looking for major pivot points backed by institutional volume. 

Instead of drawing simple unweighted lines, this tool tracks the volume of swing highs and lows. When a high-volume pivot is found, the script creates a dynamic zone box on your chart and fits a live [b]Cumulative Volume Delta (CVD)[/b] trendline inside it. This lets you monitor real-time buying and selling pressure exactly where the market is most likely to reverse.

[b]🔵 MAIN ENGINE & VOLUME ZONE LOGIC[/b]

[b]1. Volume-Validated Pivots[/b]
[list]
[*] [b]Swing Isolation Fields:[/b] The tool uses customizable lookback settings ([b]Resistance/Support Pivot Length[/b]) to find prominent structural swing highs and lows.
[*] [b]Institutional Volume Filters:[/b] Every new swing point is checked against a volume baseline ([b]Volume MA Length[/b]). A zone is only plotted if the pivot bar's volume beats the baseline multiplier ([b]Volume Threshold Multiplier[/b]), filtering out weak retail moves.
[image]https://www.tradingview.com/x/EdCdtxxr/[/image]
[/list]

[b]2. Embedded Zone CVD Lines[/b]
[list]
[*] [b]Intra-Box Order Flow Tracking:[/b] The script counts the volume delta (buying volume minus selling volume based on candle closes) from the exact bar the pivot formed.
[*] [b]Normalized Inside the Box:[/b] Using custom polylines, the script scales and plots the rolling CVD trend directly inside the height of the zone box. This lets you see order-flow accumulation without cluttering your screen with bottom dashboard panels.
[*] [b]Live Labels:[/b] A small text readout updates on the leading edge of the box, showing the current net CVD volume.
[image]https://www.tradingview.com/x/Lfidp237/[/image]
[/list]

[pine]
// Normalize and scale running CVD values perfectly inside the zone box coordinates
normalizeDeltaToBox(float currentDelta, float minDelta, float maxDelta, float boxBottom, float boxTop) =>
    float rangeDelta = maxDelta - minDelta
    float rangeBox = boxTop - boxBottom
    rangeDelta == 0 ? boxBottom + rangeBox / 2 : boxBottom + (currentDelta - minDelta) / rangeDelta * rangeBox
[/pine]

[b]🔵 DYNAMIC ZONE FLIPS & SIGNALS[/b]

[b]1. Support and Resistance Flips[/b]
[list]
[*] [b]Automatic Re-Coloring:[/b] When a strong candle close breaks entirely through a zone, the script changes its role. Broken resistance boxes switch to your [b]Support Zone Color[/b] (yellow), and broken support boxes turn into your [b]Resistance Zone Color[/b] (blue).
[*] [b]Border Style Changes:[/b] The box outline instantly switches from a solid line to a dashed line the moment a zone is breached, flagging a clear shift in institutional liquidity.
[image]https://www.tradingview.com/x/r524omtn/[/image]
[/list]

[b]2. Retest and Breakout Plots[/b]
[list]
[*] [b]Breakout Arrows:[/b] The system prints clean triangle up or down arrows ([b]▲ or ▼[/b]) on your chart labeled "Res Breakout" or "Sup Breakdown" the exact bar a zone boundary fails.
[*] [b]Proximity Retest Shapes:[/b] It plots tiny circle markers when price pulls back to successfully test a normal support/resistance hold. If price tests a broken zone that has reversed roles, it prints a diamond marker to flag an advanced flipped S/R retest.
[image]https://www.tradingview.com/x/biRhCQ3y/[/image]
[/list]

[pine]
// Zone Breakout and Role Inversion Logic snippet
if close > rTop
    box.set_bgcolor(lastResBox, color.new(supColor, 90))
    box.set_border_color(lastResBox, supLine)
    box.set_text_color(lastResBox, supLine)
    box.set_border_style(lastResBox, line.style_dotted)

    if not resBroken
        triggerResBreak := true
        resBroken := true
[/pine]

[b]🔵 TRADING STRATEGIES & RISK[/b]

[list]
[*] [b]CVD Absorption Entries:[/b] When price rallies up into a blue resistance box, check the internal dotted CVD line. 
[image]https://www.tradingview.com/x/HjUHVXyM/[/image]
If price pushes high into the box but the internal CVD trend slopes down, sellers are absorbing the buy orders. This sets up a high-probability short entry.

[*] [b]Flipped Support Re-Entries:[/b] When a bullish breakout triggers a "Res Breakout" arrow, wait for price to pull back to the top border of the broken box. A clean bounce marked by a diamond shape confirms the old resistance has flipped to support, offering a safe continuation trade.
[*] [b]Clear Risk Invalidation floors:[/b] You can use the exact borders of the generated boxes to place your stop loss. If you buy a support hold retest, your clear risk invalidation point sits right below the bottom line of that specific support box.
[/list]

[b]🔵 SETTINGS & CONFIGURATION[/b]
[list]
[*] [b]Pivot Geometry Controls:[/b] Easily fine-tune lookback lengths and volume multipliers to adapt the indicator for volatile crypto assets, indexes, or liquid forex pairs.
[*] [b]Visual Zone Overrides:[/b] Adjust background colors, transparency levels, and text label sizing to match your dark or light charting interface seamlessly.
[/list]

Clean up your layout and trade with volume-weighted precision using the [b]High Volume Pivot Support & Resistance Zones[/b] terminal.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga

//@version=6
indicator('High Volume Pivot Support & Resistance Zones [BigBeluga]', overlay = true, max_boxes_count = 500)

// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

var string G_PIVOT = 'Pivot Settings'
resLen = input.int(40, title = 'Resistance Pivot Length', minval = 1, group = G_PIVOT, tooltip = 'The number of bars required before and after a high peak to confirm a structural resistance pivot.')
supLen = input.int(40, title = 'Support Pivot Length', minval = 1, group = G_PIVOT, tooltip = 'The number of bars required before and after a low trough to confirm a structural support pivot.')

var string G_VOL = 'Volume Validation'
volAvgLen = input.int(20, title = 'Volume MA Length', minval = 1, group = G_VOL, tooltip = 'The lookback period used to calculate the Simple Moving Average (SMA) of volume for baseline comparison.')
volMult = input.float(1.2, title = 'Volume Threshold Multiplier', minval = 0.1, group = G_VOL, tooltip = 'The multiplier applied to the volume SMA baseline. A pivot bar must exceed this total value to be validated.')

var string G_ZONE = 'Zone Settings'
atrLen      = 100
resColor    = input.color(color.new(#2196f3, 85), title = 'Resistance Zone Color', group = G_ZONE, tooltip = 'The background fill color applied to active resistance zones.')
resLine     = input.color(#2196f3, title = 'Resistance Line Color', group = G_ZONE, tooltip = 'The outline border color for resistance zones and its corresponding text markers.')
supColor    = input.color(color.new(#ffc13b, 85), title = 'Support Zone Color', group = G_ZONE, tooltip = 'The background fill color applied to active support zones.')
supLine     = input.color(#ffc13b, title = 'Support Line Color', group = G_ZONE, tooltip = 'The outline border color for support zones and its corresponding text markers.')

// }
// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

// ATR for box padding
atr = ta.atr(200)

// Volume Validation
avgVol = ta.sma(volume, volAvgLen)
isHighVolume = volume > avgVol * volMult

// Calculate Volume Delta per bar (Up volume minus Down volume based on bar close)
volDelta = close >= open ? volume : -volume

// Pivot Detection
pHi = ta.pivothigh(high, resLen, resLen)
pLo = ta.pivotlow(low, supLen, supLen)

// Detect valid pivots on the bar where they are confirmed
validPivotHigh = not na(pHi) and isHighVolume[resLen]
validPivotLow = not na(pLo) and isHighVolume[supLen]

// Zone & Polyline Management Initialization
var box lastResBox = na
var box lastSupBox = na

var polyline resDeltaLine = na
var polyline supDeltaLine = na

var label resCvdLabel = na
var label supCvdLabel = na

var array<chart.point> resPoints = array.new<chart.point>()
var array<chart.point> supPoints = array.new<chart.point>()
var array<float> resDeltas = array.new<float>()
var array<float> supDeltas = array.new<float>()

var float cumResDelta = 0.0
var float cumSupDelta = 0.0

var bool resBroken = false
var bool supBroken = false

bool triggerResBreak = false
bool triggerSupBreak = false
bool triggerResRetest = false
bool triggerSupRetest = false
bool triggerFlippedResRetest = false
bool triggerFlippedSupRetest = false

// Helper Functions
normalizeDeltaToBox(float currentDelta, float minDelta, float maxDelta, float boxBottom, float boxTop) =>
    float rangeDelta = maxDelta - minDelta
    float rangeBox = boxTop - boxBottom
    rangeDelta == 0 ? boxBottom + rangeBox / 2 : boxBottom + (currentDelta - minDelta) / rangeDelta * rangeBox

formatVolume(float vol) =>
    float absVol = math.abs(vol)
    string sign = vol < 0 ? '-' : ''
    if absVol >= 1000000
        sign + str.tostring(absVol / 1000000, '0.0') + 'M'
    else if absVol >= 1000
        sign + str.tostring(absVol / 1000, '0.0') + 'K'
    else
        sign + str.tostring(absVol, '0')

// }
// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

// Handle Resistance Zone Actions
if validPivotHigh
    resBroken := false
    float pivotBodyTop = math.max(open[resLen], close[resLen])
    float topPrice = pivotBodyTop + atr[resLen]
    float bottomPrice = pivotBodyTop

    if not na(lastResBox)
        box.set_right(lastResBox, bar_index)

    string volText = 'Vol: ' + formatVolume(-volume[resLen])
    lastResBox := box.new(left = bar_index - resLen, top = topPrice, right = bar_index, bottom = bottomPrice, bgcolor = resColor, border_color = resLine, border_style = line.style_solid, text = volText, text_size = size.small, text_color = resLine, text_valign = text.align_top, text_halign = text.align_left)

    if not na(resDeltaLine)
        polyline.delete(resDeltaLine)
    if not na(resCvdLabel)
        label.delete(resCvdLabel)

    cumResDelta := 0.0
    array.clear(resPoints)
    array.clear(resDeltas)

    for i = resLen to 0 by 1
        cumResDelta := cumResDelta + volDelta[i]
        array.push(resDeltas, cumResDelta)
        array.push(resPoints, chart.point.from_index(bar_index - i, bottomPrice))

    resDeltaLine := polyline.new(points = resPoints, line_color = chart.fg_color, line_width = 1, line_style = line.style_dotted)
    resCvdLabel := label.new(x = bar_index, y = bottomPrice, text = 'CVD: ' + formatVolume(cumResDelta), color = color.new(color.black, 100), textcolor = resLine, style = label.style_label_left, size = size.small)
    resCvdLabel
else
    if not na(lastResBox)
        box.set_right(lastResBox, bar_index)
        float rTop = box.get_top(lastResBox)
        float rBottom = box.get_bottom(lastResBox)

        cumResDelta := cumResDelta + volDelta
        array.push(resDeltas, cumResDelta)
        array.push(resPoints, chart.point.from_index(bar_index, rBottom))

        color activeResLineColor = close > rTop or resBroken ? supLine : resLine

        if array.size(resPoints) > 1
            float maxD = array.max(resDeltas)
            float minD = array.min(resDeltas)
            float finalScaledY = rBottom

            for i = 0 to array.size(resPoints) - 1 by 1
                float currentD = array.get(resDeltas, i)
                float scaledY = normalizeDeltaToBox(currentD, minD, maxD, rBottom, rTop)
                pointItem = array.get(resPoints, i)
                array.set(resPoints, i, chart.point.from_index(pointItem.index, scaledY))
                if i == array.size(resPoints) - 1
                    finalScaledY := scaledY
                    finalScaledY

            if not na(resDeltaLine)
                polyline.delete(resDeltaLine)
            resDeltaLine := polyline.new(points = resPoints, line_color = chart.fg_color, line_width = 1, line_style = line.style_dotted)

            if not na(resCvdLabel)
                label.delete(resCvdLabel)
            resCvdLabel := label.new(x = bar_index, y = finalScaledY, text = 'CVD: ' + formatVolume(cumResDelta), color = color.new(color.black, 100), textcolor = activeResLineColor, style = label.style_label_left, size = size.small)
            resCvdLabel

        if close < rTop
            box.set_bgcolor(lastResBox, color.new(resColor, 80))
            box.set_border_color(lastResBox, resLine)
            box.set_text_color(lastResBox, resLine)


            if  high[1] >= rBottom and high < rBottom
                triggerResRetest := true
                triggerResRetest

        if close > rTop
            box.set_bgcolor(lastResBox, color.new(supColor, 90))
            box.set_border_color(lastResBox, supLine)
            box.set_text_color(lastResBox, supLine)
            box.set_border_style(lastResBox, line.style_dotted)

            if not resBroken
                triggerResBreak := true
                resBroken := true
                resBroken

            change = resBroken != resBroken[1]
            if low[1] <= rTop and low > rTop and not (change or change[1])
                triggerFlippedResRetest := true
                triggerFlippedResRetest

// Handle Support Zone Actions
if validPivotLow
    supBroken := false
    float pivotBodyBottom = math.min(open[supLen], close[supLen])
    float topPrice = pivotBodyBottom
    float bottomPrice = pivotBodyBottom - atr[supLen]

    if not na(lastSupBox)
        box.set_right(lastSupBox, bar_index)

    string volText = 'Vol: ' + formatVolume(volume[supLen])
    lastSupBox := box.new(left = bar_index - supLen, top = topPrice, right = bar_index, bottom = bottomPrice, bgcolor = supColor, border_color = supLine, border_style = line.style_solid, text = volText, text_size = size.small, text_color = supLine, text_valign = text.align_bottom, text_halign = text.align_left)

    if not na(supDeltaLine)
        polyline.delete(supDeltaLine)
    if not na(supCvdLabel)
        label.delete(supCvdLabel)

    cumSupDelta := 0.0
    array.clear(supPoints)
    array.clear(supDeltas)

    for i = supLen to 0 by 1
        cumSupDelta := cumSupDelta + volDelta[i]
        array.push(supDeltas, cumSupDelta)
        array.push(supPoints, chart.point.from_index(bar_index - i, bottomPrice))

    supDeltaLine := polyline.new(points = supPoints, line_color = chart.fg_color, line_width = 1, line_style = line.style_dotted)
    supCvdLabel := label.new(x = bar_index, y = bottomPrice, text = 'CVD: ' + formatVolume(cumSupDelta), color = color.new(color.black, 100), textcolor = supLine, style = label.style_label_left, size = size.small)
    supCvdLabel
else
    if not na(lastSupBox)
        box.set_right(lastSupBox, bar_index)
        float sTop = box.get_top(lastSupBox)
        float sBottom = box.get_bottom(lastSupBox)

        cumSupDelta := cumSupDelta + volDelta
        array.push(supDeltas, cumSupDelta)
        array.push(supPoints, chart.point.from_index(bar_index, sBottom))

        color activeSupLineColor = close < sTop or supBroken ? resLine : supLine

        if array.size(supPoints) > 1
            float maxD = array.max(supDeltas)
            float minD = array.min(supDeltas)
            float finalScaledY = sBottom

            for i = 0 to array.size(supPoints) - 1 by 1
                float currentD = array.get(supDeltas, i)
                float scaledY = normalizeDeltaToBox(currentD, minD, maxD, sBottom, sTop)
                pointItem = array.get(supPoints, i)
                array.set(supPoints, i, chart.point.from_index(pointItem.index, scaledY))
                if i == array.size(supPoints) - 1
                    finalScaledY := scaledY
                    finalScaledY

            if not na(supDeltaLine)
                polyline.delete(supDeltaLine)
            supDeltaLine := polyline.new(points = supPoints, line_color = chart.fg_color, line_width = 1, line_style = line.style_dotted)

            if not na(supCvdLabel)
                label.delete(supCvdLabel)
            supCvdLabel := label.new(x = bar_index, y = finalScaledY, text = 'CVD: ' + formatVolume(cumSupDelta), color = color.new(color.black, 100), textcolor = activeSupLineColor, style = label.style_label_left, size = size.small)
            supCvdLabel

        if close < sBottom
            box.set_bgcolor(lastSupBox, color.new(resColor, 90))
            box.set_border_color(lastSupBox, color.new(resLine, 0))
            box.set_text_color(lastSupBox, resLine)
            box.set_border_style(lastSupBox, line.style_dotted)

            if not supBroken
                triggerSupBreak := true
                supBroken := true
                supBroken
            if high[1] >= sBottom and high < sBottom
                triggerFlippedSupRetest := true
                triggerFlippedSupRetest

        if close > sBottom
            box.set_bgcolor(lastSupBox, color.new(supColor, 80))
            box.set_border_color(lastSupBox, supLine)
            box.set_text_color(lastSupBox, supLine)
            if  low[1] <= sTop and low > sTop
                triggerSupRetest := true
                triggerSupRetest

// Shape & Breakout Plots
plotshape(triggerResBreak, title = 'Resistance Breakout', style = shape.triangleup, location = location.belowbar, color = supLine, text = 'Res Breakout', textcolor = chart.fg_color, size = size.tiny)
plotshape(triggerSupBreak, title = 'Support Breakdown', style = shape.triangledown, location = location.abovebar, color = resLine, text = 'Sup Breakdown', textcolor = chart.fg_color, size = size.tiny)

plotshape(triggerSupRetest, title = 'Support Hold Retest', style = shape.circle, location = location.belowbar, color = supLine, size = size.tiny, offset = -1)
plotshape(triggerResRetest, title = 'Resistance Hold Retest', style = shape.circle, location = location.abovebar, color = resLine, size= size.tiny, offset = -1)

plotshape(triggerFlippedResRetest, title = 'Flipped Res Retest', style = shape.diamond, location = location.belowbar, color = supLine, size = size.tiny, offset = -1)
plotshape(triggerFlippedSupRetest, title = 'Flipped Sup Retest', style = shape.diamond, location = location.abovebar, color = resLine, size = size.tiny, offset = -1)

// }
````
