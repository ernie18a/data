# Reaction Zone Ledger [JOAT]

- url: https://www.tradingview.com/script/oVygN536-Reaction-Zone-Ledger-JOAT/
- type: indicator
- pine_id: PUB;cbac7890add14c74a54ee93c242c7f19
- version: 1.0

## Description

Reaction Zone Ledger is an open-source Pine Script v6 overlay that creates pivot-based support and resistance reaction zones, tracks signed volume pressure inside those zones, merges nearby zones, and displays compact statistics directly beside each active area.

The script is built for traders who want reaction zones to contain more information than a simple box. Each zone stores pressure, net impulse, touch count, state, and a dashed midpoint. The dashboard summarizes the broader signed-volume ledger and the nearest active zone.

[image]https://www.tradingview.com/x/YGbM6oK6/[/image]

[b]Core Concepts[/b]

[b]1. Signed Volume Proxy[/b]

Each bar receives a signed volume estimate from candle body bias and close location. This is not true buyer/seller volume; it is a transparent approximation from OHLCV data.

[pine]
bodyBias = barRange > 0.0 ? (close - open) / barRange : 0.0
closeBias = barRange > 0.0 ? (((close - low) / barRange) - 0.5) * 2.0 : 0.0
signedVolume = volume * clamp(bodyBias * 0.62 + closeBias * 0.38, -1.0, 1.0)
[/pine]

[b]2. Pivot Reaction Zones[/b]

Confirmed pivot highs create resistance-style zones. Confirmed pivot lows create support-style zones. The width is based on ATR so the zones scale with current chart volatility.

[b]3. Merge Logic[/b]

When a new zone is close to an existing zone on the same side, the script merges them rather than stacking overlapping boxes. This keeps the chart cleaner and improves object efficiency.

[b]4. Zone Ledger Statistics[/b]

Each zone tracks buy pressure, sell pressure, hit count, net impulse, and state. A small outside stats box displays the current pressure reading and net value.

[b]5. Dashboard Summary[/b]

The dashboard shows overall ledger pressure, net impulse, nearest zone type, and nearest zone state.

[b]Features[/b]

[list]
[*][b]Pivot support and resistance zones:[/b] Zones are created from confirmed pivots
[*][b]ATR-based width:[/b] Zone size adapts to volatility
[*][b]Merge system:[/b] Nearby same-side zones combine into larger active areas
[*][b]Signed-volume ledger:[/b] Tracks directional pressure using a transparent OHLCV proxy
[*][b]Stats boxes:[/b] Pressure percentage, net impulse, and state displayed beside zones
[*][b]Dashed midlines:[/b] Each zone has a center reference line
[*][b]Dashboard:[/b] Shows active zone count and nearest zone context
[*][b]Alerts:[/b] Support reaction, resistance reaction, and zone break
[/list]

[b]Input Parameters[/b]

[b]Visuals:[/b]
[list]
[*]Palette: Selects color pair
[*]Show Dashboard: Toggles the top-right dashboard
[/list]

[b]Zones:[/b]
[list]
[*]Pivot Left Bars / Pivot Right Bars: Pivot confirmation settings
[*]Range Length: ATR length for zone sizing
[*]Zone Half-Width ATR: Controls box thickness
[*]Merge Distance ATR: Controls when nearby zones merge
[*]Maximum Zones: Limits active object count
[*]Forward Extension: Bars each zone extends forward
[*]Ledger Impulse Length: Lookback for dashboard impulse stats
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Locate Active Zones[/b]
Green-style zones represent support reactions. Red-style zones represent resistance reactions.

[b]Step 2: Read the Stats Box[/b]
The outside box shows whether the zone is testing, holding, cleared, lost, or mixed, along with its pressure value.

[b]Step 3: Watch Break Alerts[/b]
A break alert means price closed beyond the zone boundary after previously trading around it.

[b]Step 4: Use Nearest Zone Context[/b]
The dashboard helps identify whether price is closest to support or resistance and what state that zone is in.

[b]Indicator Limitations[/b]

[list]
[*]Signed volume is an approximation from OHLCV data
[*]Pivot zones appear only after pivot confirmation
[*]Merged zones can become wide during repeated tests
[*]Zone pressure can change quickly when high-volume bars touch the zone
[/list]

[b]Originality Statement[/b]

Reaction Zone Ledger is original in its combination of confirmed pivot zones, merge logic, signed-volume accounting, outside stats boxes, and nearest-zone dashboard. It is original Pine v6 code and does not reuse another author's indicator source.

[b]Disclaimer[/b]

This script is provided for educational and informational use only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss. Reaction zones can fail, widen, or become less useful in fast markets. Always use independent analysis and proper risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Reaction Zone Ledger [JOAT]", overlay = true, max_boxes_count = 300, max_lines_count = 200)

palettePreset = input.string("Aqua Rose", "Palette", options = ["Aqua Rose", "Neon Desk", "Mint Pulse", "VWAP Field"], group = "Visuals")
showDashboard = input.bool(true, "Show dashboard", group = "Visuals")
pivotLeft = input.int(5, "Pivot left bars", minval = 2, maxval = 20, group = "Zones")
pivotRight = input.int(3, "Pivot right bars", minval = 2, maxval = 20, group = "Zones")
atrLength = input.int(21, "Range length", minval = 5, maxval = 100, group = "Zones")
zoneAtrMult = input.float(0.55, "Zone half-width ATR", minval = 0.10, maxval = 2.50, step = 0.05, group = "Zones")
mergeAtrMult = input.float(0.85, "Merge distance ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = "Zones")
maxZones = input.int(14, "Maximum zones", minval = 4, maxval = 40, group = "Zones")
extendBars = input.int(90, "Forward extension", minval = 15, maxval = 300, group = "Zones")
impulseLength = input.int(34, "Ledger impulse length", minval = 5, maxval = 200, group = "Ledger")

getBullColor(preset) =>
    switch preset
        "Neon Desk" => #00ff00
        "Mint Pulse" => #00FFD5
        "VWAP Field" => #1ac200
        => #00C8FF

getBearColor(preset) =>
    switch preset
        "Neon Desk" => #ff0000
        "Mint Pulse" => #FF0066
        "VWAP Field" => #ff4040
        => #FF005D

clamp(value, low, high) =>
    math.min(math.max(value, low), high)

volumeText(value) =>
    absolute = math.abs(value)
    sign = value < 0 ? "-" : ""
    absolute >= 1000000000.0 ? sign + str.tostring(absolute / 1000000000.0, "#.##") + "B" :
         absolute >= 1000000.0 ? sign + str.tostring(absolute / 1000000.0, "#.##") + "M" :
         absolute >= 1000.0 ? sign + str.tostring(absolute / 1000.0, "#.##") + "K" :
         sign + str.tostring(absolute, "#")

stateText(isResistance, top, bottom, pressure) =>
    inZone = close <= top and close >= bottom
    isResistance ?
         close > top ? "Cleared" : inZone ? "Testing" : pressure < 45.0 ? "Offer Hold" : "Mixed" :
         close < bottom ? "Lost" : inZone ? "Testing" : pressure > 55.0 ? "Bid Hold" : "Mixed"

bullColor = getBullColor(palettePreset)
bearColor = getBearColor(palettePreset)
neutralColor = color.rgb(154, 163, 176)

barRange = high - low
bodyBias = barRange > 0.0 ? (close - open) / barRange : 0.0
closeBias = barRange > 0.0 ? (((close - low) / barRange) - 0.5) * 2.0 : 0.0
signedVolume = volume * clamp(bodyBias * 0.62 + closeBias * 0.38, -1.0, 1.0)
netImpulse = math.sum(signedVolume, impulseLength)
totalImpulse = math.sum(math.abs(signedVolume), impulseLength)
pressurePercent = totalImpulse > 0.0 ? 50.0 + 50.0 * netImpulse / totalImpulse : 50.0
ledgerLine = ta.cum(signedVolume)
rangeAtr = ta.atr(atrLength)
averageVolume = ta.sma(volume, impulseLength)

plot(ledgerLine, "Signed Volume Ledger", color = color.new(color.gray, 100), display = display.none)

pivotHigh = ta.pivothigh(high, pivotLeft, pivotRight)
pivotLow = ta.pivotlow(low, pivotLeft, pivotRight)

var array<float> zoneTops = array.new_float()
var array<float> zoneBottoms = array.new_float()
var array<float> zoneMids = array.new_float()
var array<float> zoneBuy = array.new_float()
var array<float> zoneSell = array.new_float()
var array<int> zoneHits = array.new_int()
var array<int> zoneStarts = array.new_int()
var array<bool> zoneResistance = array.new_bool()
var array<box> zoneBodies = array.new_box()
var array<box> zoneStats = array.new_box()
var array<line> zoneMidlines = array.new_line()

addZone(isResistance, mid, halfRange, anchorIndex, impulseValue, mergeGap) =>
    newTop = mid + halfRange
    newBottom = mid - halfRange
    int mergeIndex = na
    count = array.size(zoneMids)
    if count > 0
        for i = 0 to count - 1
            sameSide = array.get(zoneResistance, i) == isResistance
            oldTop = array.get(zoneTops, i)
            oldBottom = array.get(zoneBottoms, i)
            oldMid = array.get(zoneMids, i)
            overlaps = newTop >= oldBottom and newBottom <= oldTop
            closeEnough = math.abs(mid - oldMid) <= mergeGap
            if sameSide and (overlaps or closeEnough)
                mergeIndex := i
                break
    if not na(mergeIndex)
        oldTop = array.get(zoneTops, mergeIndex)
        oldBottom = array.get(zoneBottoms, mergeIndex)
        mergedTop = math.max(oldTop, newTop)
        mergedBottom = math.min(oldBottom, newBottom)
        array.set(zoneTops, mergeIndex, mergedTop)
        array.set(zoneBottoms, mergeIndex, mergedBottom)
        array.set(zoneMids, mergeIndex, (mergedTop + mergedBottom) * 0.5)
        array.set(zoneStarts, mergeIndex, math.min(array.get(zoneStarts, mergeIndex), anchorIndex))
        array.set(zoneHits, mergeIndex, array.get(zoneHits, mergeIndex) + 1)
        if impulseValue >= 0.0
            array.set(zoneBuy, mergeIndex, array.get(zoneBuy, mergeIndex) + impulseValue)
        else
            array.set(zoneSell, mergeIndex, array.get(zoneSell, mergeIndex) + impulseValue)
    else
        baseColor = isResistance ? bearColor : bullColor
        bodyBox = box.new(left = anchorIndex, top = newTop, right = bar_index + extendBars, bottom = newBottom, xloc = xloc.bar_index, bgcolor = color.new(baseColor, 88), border_color = color.new(baseColor, 35), border_width = 1)
        statBox = box.new(left = bar_index + 2, top = newTop, right = bar_index + 22, bottom = newBottom, xloc = xloc.bar_index, bgcolor = color.new(color.black, 78), border_color = color.new(baseColor, 25), border_width = 1, text_color = color.white, text_size = size.tiny, text_halign = text.align_left, text_valign = text.align_center)
        midLine = line.new(anchorIndex, mid, bar_index + extendBars, mid, xloc = xloc.bar_index, color = color.new(baseColor, 15), style = line.style_dashed, width = 1)
        array.push(zoneTops, newTop)
        array.push(zoneBottoms, newBottom)
        array.push(zoneMids, mid)
        array.push(zoneBuy, math.max(impulseValue, 0.0))
        array.push(zoneSell, math.min(impulseValue, 0.0))
        array.push(zoneHits, 1)
        array.push(zoneStarts, anchorIndex)
        array.push(zoneResistance, isResistance)
        array.push(zoneBodies, bodyBox)
        array.push(zoneStats, statBox)
        array.push(zoneMidlines, midLine)
        while array.size(zoneMids) > maxZones
            removedBody = array.shift(zoneBodies)
            removedStats = array.shift(zoneStats)
            removedLine = array.shift(zoneMidlines)
            box.delete(removedBody)
            box.delete(removedStats)
            line.delete(removedLine)
            array.shift(zoneTops)
            array.shift(zoneBottoms)
            array.shift(zoneMids)
            array.shift(zoneBuy)
            array.shift(zoneSell)
            array.shift(zoneHits)
            array.shift(zoneStarts)
            array.shift(zoneResistance)
    true

if barstate.isconfirmed and not na(pivotHigh)
    pivotMid = pivotHigh
    pivotHalf = math.max(rangeAtr[pivotRight] * zoneAtrMult, syminfo.mintick * 4.0)
    pivotImpulse = signedVolume[pivotRight]
    mergeGap = math.max(rangeAtr[pivotRight] * mergeAtrMult, syminfo.mintick * 8.0)
    addZone(true, pivotMid, pivotHalf, bar_index - pivotRight, pivotImpulse, mergeGap)

if barstate.isconfirmed and not na(pivotLow)
    pivotMid = pivotLow
    pivotHalf = math.max(rangeAtr[pivotRight] * zoneAtrMult, syminfo.mintick * 4.0)
    pivotImpulse = signedVolume[pivotRight]
    mergeGap = math.max(rangeAtr[pivotRight] * mergeAtrMult, syminfo.mintick * 8.0)
    addZone(false, pivotMid, pivotHalf, bar_index - pivotRight, pivotImpulse, mergeGap)

supportReaction = false
resistanceReaction = false
zoneBreak = false
nearestDistance = 1000000000.0
nearestState = "None"
nearestPressure = 50.0
nearestImpulse = 0.0
nearestKind = "None"

zoneCount = array.size(zoneMids)
if zoneCount > 0
    for i = 0 to zoneCount - 1
        top = array.get(zoneTops, i)
        bottom = array.get(zoneBottoms, i)
        mid = array.get(zoneMids, i)
        isResistance = array.get(zoneResistance, i)
        touched = high >= bottom and low <= top
        if touched and barstate.isconfirmed
            if signedVolume >= 0.0
                array.set(zoneBuy, i, array.get(zoneBuy, i) + signedVolume)
            else
                array.set(zoneSell, i, array.get(zoneSell, i) + signedVolume)
            array.set(zoneHits, i, array.get(zoneHits, i) + 1)
        buyValue = array.get(zoneBuy, i)
        sellValue = array.get(zoneSell, i)
        totalValue = buyValue + math.abs(sellValue)
        zonePressure = totalValue > 0.0 ? 100.0 * buyValue / totalValue : 50.0
        zoneImpulse = buyValue + sellValue
        zoneState = stateText(isResistance, top, bottom, zonePressure)
        zoneColor = isResistance ? bearColor : bullColor
        distanceAtr = rangeAtr > 0.0 ? math.abs(close - mid) / rangeAtr : 0.0
        strengthBase = averageVolume > 0.0 ? math.abs(zoneImpulse) / averageVolume : 0.0
        strength = clamp(array.get(zoneHits, i) / 12.0 + strengthBase / 18.0, 0.0, 1.0)
        bodyColor = color.from_gradient(clamp(distanceAtr, 0.0, 3.0), 0.0, 3.0, color.new(zoneColor, 78), color.new(zoneColor, 94))
        edgeColor = color.from_gradient(strength, 0.0, 1.0, color.new(zoneColor, 72), color.new(zoneColor, 5))
        textColor = zonePressure >= 50.0 ? bullColor : bearColor
        bodyBox = array.get(zoneBodies, i)
        statBox = array.get(zoneStats, i)
        midLine = array.get(zoneMidlines, i)
        rightEdge = bar_index + extendBars
        statLeft = bar_index + 3
        statRight = bar_index + 27
        box.set_lefttop(bodyBox, array.get(zoneStarts, i), top)
        box.set_rightbottom(bodyBox, rightEdge, bottom)
        box.set_bgcolor(bodyBox, bodyColor)
        box.set_border_color(bodyBox, edgeColor)
        line.set_xy1(midLine, array.get(zoneStarts, i), mid)
        line.set_xy2(midLine, rightEdge, mid)
        line.set_color(midLine, color.new(zoneColor, 20))
        box.set_lefttop(statBox, statLeft, top)
        box.set_rightbottom(statBox, statRight, bottom)
        box.set_bgcolor(statBox, color.new(color.black, 76))
        box.set_border_color(statBox, edgeColor)
        box.set_text_color(statBox, textColor)
        box.set_text(statBox, str.format("{0}\nPressure {1}%\nNet {2}", zoneState, str.tostring(zonePressure, "#"), volumeText(zoneImpulse)))
        if touched and barstate.isconfirmed
            supportReaction := supportReaction or not isResistance
            resistanceReaction := resistanceReaction or isResistance
        if barstate.isconfirmed
            brokeResistance = isResistance and close > top and close[1] <= top
            brokeSupport = not isResistance and close < bottom and close[1] >= bottom
            zoneBreak := zoneBreak or brokeResistance or brokeSupport
        if distanceAtr < nearestDistance
            nearestDistance := distanceAtr
            nearestState := zoneState
            nearestPressure := zonePressure
            nearestImpulse := zoneImpulse
            nearestKind := isResistance ? "Resistance" : "Support"

var table dashboard = table.new(position.top_right, 2, 5, bgcolor = color.new(color.black, 78), frame_color = color.new(neutralColor, 60), frame_width = 1, border_width = 1)

if barstate.islast and showDashboard
    headerColor = pressurePercent >= 50.0 ? color.new(bullColor, 35) : color.new(bearColor, 35)
    table.cell(dashboard, 0, 0, "Reaction Zone Ledger [JOAT]", text_color = color.white, bgcolor = headerColor, text_size = size.small)
    table.cell(dashboard, 1, 0, str.tostring(zoneCount) + " zones", text_color = color.white, bgcolor = headerColor, text_size = size.small)
    table.cell(dashboard, 0, 1, "Ledger pressure", text_color = color.new(color.white, 10), bgcolor = color.new(color.black, 82), text_size = size.tiny)
    table.cell(dashboard, 1, 1, str.tostring(pressurePercent, "#") + "%", text_color = pressurePercent >= 50.0 ? bullColor : bearColor, bgcolor = color.new(color.black, 82), text_size = size.tiny)
    table.cell(dashboard, 0, 2, "Net impulse", text_color = color.new(color.white, 10), bgcolor = color.new(color.black, 82), text_size = size.tiny)
    table.cell(dashboard, 1, 2, volumeText(netImpulse), text_color = netImpulse >= 0.0 ? bullColor : bearColor, bgcolor = color.new(color.black, 82), text_size = size.tiny)
    table.cell(dashboard, 0, 3, "Nearest", text_color = color.new(color.white, 10), bgcolor = color.new(color.black, 82), text_size = size.tiny)
    table.cell(dashboard, 1, 3, nearestKind, text_color = color.white, bgcolor = color.new(color.black, 82), text_size = size.tiny)
    table.cell(dashboard, 0, 4, nearestState, text_color = color.new(color.white, 10), bgcolor = color.new(color.black, 82), text_size = size.tiny)
    table.cell(dashboard, 1, 4, str.tostring(nearestPressure, "#") + "% / " + volumeText(nearestImpulse), text_color = nearestPressure >= 50.0 ? bullColor : bearColor, bgcolor = color.new(color.black, 82), text_size = size.tiny)

if barstate.islast and not showDashboard
    table.clear(dashboard, 0, 0, 1, 4)

alertcondition(supportReaction and barstate.isconfirmed, "Support reaction confirmed [JOAT]", "Reaction Zone Ledger [JOAT]: support zone reaction on a confirmed bar.")
alertcondition(resistanceReaction and barstate.isconfirmed, "Resistance reaction confirmed [JOAT]", "Reaction Zone Ledger [JOAT]: resistance zone reaction on a confirmed bar.")
alertcondition(zoneBreak and barstate.isconfirmed, "Reaction zone break confirmed [JOAT]", "Reaction Zone Ledger [JOAT]: reaction zone break on a confirmed bar.")
````
