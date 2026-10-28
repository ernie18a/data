# Model Follower

- url: https://www.tradingview.com/script/iS1VnQpc-Model-Follower/
- type: indicator
- pine_id: PUB;51e8c3cdec054ba79e86532aee65346f
- version: 3.0

## Description

This indicator maps price structure using confirmed candle closes rather than wicks — a new high or low only registers once price actually closes beyond the prior range, filtering out spikes that don't follow through. Each new range is anchored to the true swing point: the last opposing candle (or any wick that pierced past it) before the break, giving a clean staircase view of how structure is actually developing.

From that structure, it plots two live target references:

Local Target (orange) — tracks the current extreme of whichever direction price is presently trending, on your chart's own timeframe. Pushing higher, it follows the developing high; the moment structure turns lower, it immediately switches to the developing low. This updates in real time and reflects what's happening on your timeframe right now — including during a countertrend pullback inside a larger trend.

HTF Target (blue) — the same structure logic, calculated independently on a higher timeframe pulled automatically based on your current chart's timeframe. This gives a read on where price is headed on a broader scale without needing to manually flip charts.

How to use it: when the local and HTF targets are pointing the same direction, the immediate move has higher-timeframe backing. When they diverge — say, local structure just turned bullish but the HTF target is still pointing down — that's often a sign you're looking at a countertrend bounce or a pullback rather than a fresh trend continuation, not a fully confirmed reversal yet.

Note: this tool intentionally doesn't auto-label market phases (accumulation/distribution) or draw supply/demand zones — reading trend context and zone validity is left to the trader, since that involves judgment a mechanical rule can't fully capture. This indicator is built to support that reading, not replace it.

## Source Code

````pine
//@version=6
indicator("Model Follower", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

grp = "Visuals"
showLocalTarget = input.bool(true, "Show Local Target", group=grp)
showHtfTarget = input.bool(true, "Show HTF Target", group=grp)
topColor = input.color(color.black, "Top Line Color", group=grp)
botColor = input.color(color.black, "Bottom Line Color", group=grp)
localTargetColor = input.color(color.orange, "Local Target Color", group=grp)
htfTargetColor = input.color(color.blue, "HTF Target Color", group=grp)

grpZones = "Demand / Supply Zones"
showZones = input.bool(true, "Show Demand & Supply Zones", group=grpZones)
maxZones = input.int(10, "Max Zones Kept on Chart", minval=1, maxval=30, group=grpZones)
demandColor = input.color(color.new(color.teal, 75), "Demand Zone Color", group=grpZones)
supplyColor = input.color(color.new(color.red, 75), "Supply Zone Color", group=grpZones)
mitigatedColor = input.color(color.new(color.gray, 88), "Mitigated Zone Color", group=grpZones)

f_labelSize(sizeStr) =>
    sizeStr == "tiny" ? size.tiny : sizeStr == "normal" ? size.normal : size.small

curSec = timeframe.in_seconds(timeframe.period)

htfSec = curSec == 5 ? 30 :
     curSec == 30 ? 300 :
     curSec == 300 ? 1800 :
     curSec == 1800 ? 18000 :
     curSec == 18000 ? 86400 :
     curSec * 6

htfString = htfSec < 60 ? str.tostring(htfSec) + "S" :
     htfSec < 86400 ? str.tostring(int(htfSec / 60)) :
     "D"

f_structure() =>
    var float bH = na
    var float bL = na
    var string bDir = na
    var float lBearLow = na
    var int   lBearBar = na
    var float lBullHigh = na
    var int   lBullBar = na
    var int   bOriginBar = na

    isBearClean = close < open and close < low[1]
    isBullClean = close > open and close > high[1]

    if na(bH)
        bH := high
        bL := low
        bOriginBar := bar_index

    if isBearClean
        lBearLow := low
        lBearBar := bar_index
    else if not na(lBearLow) and low < lBearLow
        lBearLow := low
        lBearBar := bar_index

    if isBullClean
        lBullHigh := high
        lBullBar := bar_index
    else if not na(lBullHigh) and high > lBullHigh
        lBullHigh := high
        lBullBar := bar_index

    hadPBDown = not na(lBearBar) and lBearBar > bOriginBar
    hadPBUp   = not na(lBullBar) and lBullBar > bOriginBar

    if close > bH and (na(bDir) or hadPBDown)
        nLow = hadPBDown ? lBearLow : bL
        oBar = hadPBDown ? lBearBar : bOriginBar
        bL := nLow
        bH := high
        bDir := "up"
        bOriginBar := oBar
    else if close < bL and (na(bDir) or hadPBUp)
        nHigh = hadPBUp ? lBullHigh : bH
        oBar = hadPBUp ? lBullBar : bOriginBar
        bH := nHigh
        bL := low
        bDir := "down"
        bOriginBar := oBar
    else
        if bDir == "up"
            bH := math.max(bH, high)
        if bDir == "down"
            bL := math.min(bL, low)

    [bH, bL, bDir]

var float boxHigh = na
var float boxLow  = na
var int   boxOriginBar = na
var string boxDir = na

var float lastBearLow = na
var float lastBearHigh = na
var int   lastBearBar = na
var float lastBullHigh = na
var float lastBullLow = na
var int   lastBullBar  = na

isBearCleanMain = close < open and close < low[1]
isBullCleanMain = close > open and close > high[1]

prevBoxHigh = boxHigh
prevBoxLow = boxLow
prevBoxOriginBar = boxOriginBar

if na(boxHigh)
    boxHigh := high
    boxLow  := low
    boxOriginBar := bar_index

if isBearCleanMain
    lastBearLow := low
    lastBearHigh := high
    lastBearBar := bar_index
else if not na(lastBearLow) and low < lastBearLow
    lastBearLow := low
    lastBearHigh := high
    lastBearBar := bar_index

if isBullCleanMain
    lastBullHigh := high
    lastBullLow := low
    lastBullBar := bar_index
else if not na(lastBullHigh) and high > lastBullHigh
    lastBullHigh := high
    lastBullLow := low
    lastBullBar := bar_index

hadPullbackDown = not na(lastBearBar) and lastBearBar > boxOriginBar
hadPullbackUp   = not na(lastBullBar) and lastBullBar > boxOriginBar

bullishBreakFired = false
bearishBreakFired = false

var float demandZoneHigh = na
var float demandZoneLow = na
var int   demandZoneBar = na
var float supplyZoneHigh = na
var float supplyZoneLow = na
var int   supplyZoneBar = na

if close > boxHigh and (na(boxDir) or hadPullbackDown)
    newLow = hadPullbackDown ? lastBearLow : boxLow
    originBar = hadPullbackDown ? lastBearBar : boxOriginBar
    boxLow := newLow
    boxHigh := high
    boxDir := "up"
    boxOriginBar := originBar
    bullishBreakFired := true
    if hadPullbackDown
        demandZoneHigh := lastBearHigh
        demandZoneLow := lastBearLow
        demandZoneBar := lastBearBar
    lastBearLow := na
    lastBearHigh := na
    lastBearBar := na

else if close < boxLow and (na(boxDir) or hadPullbackUp)
    newHigh = hadPullbackUp ? lastBullHigh : boxHigh
    originBar = hadPullbackUp ? lastBullBar : boxOriginBar
    boxHigh := newHigh
    boxLow := low
    boxDir := "down"
    boxOriginBar := originBar
    bearishBreakFired := true
    if hadPullbackUp
        supplyZoneHigh := lastBullHigh
        supplyZoneLow := lastBullLow
        supplyZoneBar := lastBullBar
    lastBullHigh := na
    lastBullLow := na
    lastBullBar := na

else
    if boxDir == "up"
        boxHigh := math.max(boxHigh, high)
    if boxDir == "down"
        boxLow := math.min(boxLow, low)

[htfHigh, htfLow, htfDir] = request.security(syminfo.tickerid, htfString, f_structure(), lookahead=barmerge.lookahead_off)

localTargetVal = boxDir == "up" ? boxHigh : boxDir == "down" ? boxLow : na
htfTargetVal = htfDir == "up" ? htfHigh : htfDir == "down" ? htfLow : na

var line localTargetLine = na
var label localTargetLabel = na
var line htfTargetLine = na
var label htfTargetLabel = na

if showLocalTarget and not na(localTargetVal)
    if not na(localTargetLine)
        line.delete(localTargetLine)
    if not na(localTargetLabel)
        label.delete(localTargetLabel)
    localTargetLine := line.new(bar_index - 1, localTargetVal, bar_index + 10, localTargetVal, color=localTargetColor, style=line.style_dashed, width=2)
    localTargetLabel := label.new(bar_index + 10, localTargetVal, "Target (Local)", style=label.style_label_left, color=color.new(localTargetColor, 0), textcolor=color.white, size=size.small)

if showHtfTarget and not na(htfTargetVal)
    if not na(htfTargetLine)
        line.delete(htfTargetLine)
    if not na(htfTargetLabel)
        label.delete(htfTargetLabel)
    htfTargetLine := line.new(bar_index - 1, htfTargetVal, bar_index + 25, htfTargetVal, color=htfTargetColor, style=line.style_dashed, width=2)
    htfTargetLabel := label.new(bar_index + 25, htfTargetVal, "Target (" + htfString + ")", style=label.style_label_left, color=color.new(htfTargetColor, 0), textcolor=color.white, size=size.small)

plot(boxHigh, "Top Line", color=topColor, style=plot.style_stepline, linewidth=2)
plot(boxLow, "Bottom Line", color=botColor, style=plot.style_stepline, linewidth=2)

var box[] zoneBoxes = array.new<box>()
var bool[] zoneIsDemand = array.new<bool>()
var bool[] zoneMitigated = array.new<bool>()
var float[] zoneTop = array.new<float>()
var float[] zoneBottom = array.new<float>()
var int[] activeZoneIdxRef = array.new<int>(1, -1)

f_addZone(top, bottom, startBar, isDemand) =>
    activeIdx = array.get(activeZoneIdxRef, 0)
    if activeIdx >= 0 and activeIdx < array.size(zoneBoxes)
        box.set_right(array.get(zoneBoxes, activeIdx), bar_index)

    if array.size(zoneBoxes) >= maxZones
        oldBox = array.shift(zoneBoxes)
        box.delete(oldBox)
        array.shift(zoneIsDemand)
        array.shift(zoneMitigated)
        array.shift(zoneTop)
        array.shift(zoneBottom)
        if activeIdx >= 0
            array.set(activeZoneIdxRef, 0, activeIdx - 1)

    zoneCss = isDemand ? demandColor : supplyColor
    newBox = box.new(startBar, top, bar_index, bottom, border_color=color.new(zoneCss, 40), bgcolor=zoneCss, text=isDemand ? "Demand" : "Supply", text_color=color.new(isDemand ? color.teal : color.red, 20), text_size=size.tiny)
    array.push(zoneBoxes, newBox)
    array.push(zoneIsDemand, isDemand)
    array.push(zoneMitigated, false)
    array.push(zoneTop, top)
    array.push(zoneBottom, bottom)
    array.set(activeZoneIdxRef, 0, array.size(zoneBoxes) - 1)

if showZones and bullishBreakFired and not na(demandZoneHigh)
    f_addZone(demandZoneHigh, demandZoneLow, demandZoneBar, true)

if showZones and bearishBreakFired and not na(supplyZoneHigh)
    f_addZone(supplyZoneHigh, supplyZoneLow, supplyZoneBar, false)

activeZoneIdx = array.get(activeZoneIdxRef, 0)
if showZones and activeZoneIdx >= 0 and activeZoneIdx < array.size(zoneBoxes)
    if not array.get(zoneMitigated, activeZoneIdx)
        isDemand = array.get(zoneIsDemand, activeZoneIdx)
        top = array.get(zoneTop, activeZoneIdx)
        bottom = array.get(zoneBottom, activeZoneIdx)
        bx = array.get(zoneBoxes, activeZoneIdx)
        sweptNow = isDemand ? close < bottom : close > top
        if sweptNow
            array.set(zoneMitigated, activeZoneIdx, true)
            box.set_bgcolor(bx, mitigatedColor)
            box.set_border_color(bx, color.new(color.gray, 70))
            box.set_text_color(bx, color.new(color.gray, 40))
            box.set_right(bx, bar_index)
````
