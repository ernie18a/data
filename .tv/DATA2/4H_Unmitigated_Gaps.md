<!-- tradingview-pine-id: PUB;ec77e52bb7cd4ec59ce29ec9ee40e272 -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# 4H Unmitigated Gaps

Source: https://www.tradingview.com/script/HMOTcyt6-4H-Unmitigated-Gaps/

## Description

What it does
It finds unmitigated 4-hour gaps and draws them on your 2-minute chart, then tells you which one price is closest to.

Two kinds of gap are detected, and both are pulled from the 4H timeframe while you watch the 2-minute:

Type	What it is	How it's spotted
Candle gap	The 4H bar opened above (or below) where the previous 4H bar closed — a jump with no trading in between	open4 > close4[1] (bull) or open4 < close4[1] (bear)
FVG (Fair Value Gap)	A 3-bar imbalance — price moved so fast that one candle's low never overlapped the candle two back's high	low4 > high4[2] (bull) or high4 < low4[2] (bear)
"Unmitigated" is the key word. It means price hasn't come back and traded through the gap yet. Once it does, the zone is deleted — it's been "used up." Only untouched gaps stay on the chart, which is what makes them interesting: they're levels the market hasn't resolved.

What you see on the chart
Green boxes = bullish gaps (price gapped up, zone sits below current price)
Red boxes = bearish gaps (price gapped down, zone sits above current price)
Boxes stretch to the right edge and follow along as new bars print, so they never fall behind
Top-right table shows four numbers:
Bullish Live / Bearish Live — how many unmitigated zones of each type exist right now
Nearest Bull Below — the bottom of the closest bull zone under price
Nearest Bear Above — the top of the closest bear zone over price
How to actually use it
The core idea: unmitigated gaps act like magnets. Price often returns to them before continuing, because that's where liquidity was left behind. So the two nearest zones are your two most likely next targets.

Reading the table:

Price is between "Nearest Bull Below" and "Nearest Bear Above" — you're in the middle. No edge, wait.
Price is grinding down toward the bull level — that's a potential long area if it holds.
Price is pushing up into the bear level — potential short area, or a place to take profit on longs.
The reaction matters more than the touch. A zone is a location, not a signal. What you're watching for is how price behaves when it gets there — a sharp rejection wick, a failure to close through, a reversal candle. Price slicing straight through a zone means it's being mitigated and the level is dead.

Combine it with your other tools. This script tells you where. It doesn't tell you when. Pair it with something that times entries — your DEMA ribbon expanding out of compression, a structure break, whatever you trust — and only act when both agree.

Three things students get wrong
Treating the zone as a buy/sell button. It isn't. It's a place to look. Half of these zones get run straight through.
Ignoring that the levels move. When a zone gets mitigated, the script deletes it and promotes a new "nearest." Any alert you set manually on an old level is now stale. (This is why the script should get an alertcondition added — then the alert follows the live zone automatically.)
Forgetting the timeframe gap. The zones come from the 4H. A 2-minute wick poking into a zone is not the same event as a 4H close inside it. Decide in advance which one you're trading.
The one-line version
Green boxes below price and red boxes above price are unresolved 4H gaps — price tends to revisit them. The table tells you which two are closest. Wait for a reaction at the level, and confirm with a second tool before entering.

---

## Source Code

````pine
//@version=6
//------------------------------------------------------------------------------
// 4H Unmitigated Gaps
// Overlays 4H close-to-open gaps and 4H FVG/imbalance zones on the chart.
// Mitigation rule: zones are deleted only on a full sweep-through, not a wick touch.
//------------------------------------------------------------------------------
indicator("4H Unmitigated Gaps", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

//#region Inputs
showCandleGaps = input.bool(true, "Show 4H Close-to-Open Gap", group="Display")
showFvg = input.bool(true, "Show 4H Imbalance / FVG", group="Display")
minGapTicks = input.int(1, "Min Gap Size (Ticks)", minval=0, group="Display")
maxZones = input.int(50, "Max Live Zones", minval=1, maxval=200, group="Display")
showBorder = input.bool(true, "Show Border", group="Display")
extendRight = input.bool(true, "Extend Right", group="Display")
showTable = input.bool(true, "Show Table", group="Display")
showProjection = input.bool(true, "Show Right-Edge Gap Projection", group="Projection")
projectionCount = input.int(3, "Gaps to Project", minval=1, maxval=10, group="Projection")
projectionOffset = input.int(12, "Projection Offset (bars right)", minval=0, maxval=100, group="Projection")
debugProjection = input.bool(false, "DEBUG: Force 3 Dummy Projection Boxes", group="Projection")
debugSpacing = input.float(20.0, "DEBUG: Dummy Box Spacing (points)", minval=1.0, step=1.0, group="Projection")
showHTFCandles = input.bool(true, "Show Last 4H Candle", group="HTF Candles")
htfCandleOffset = input.int(12, "HTF Candle Offset (bars right)", minval=0, maxval=100, group="HTF Candles")
htfCandleWidth = input.int(6, "HTF Candle Width (bars)", minval=2, maxval=30, group="HTF Candles")
htfShowWicks = input.bool(true, "Show Wicks", group="HTF Candles")
htfShowLabels = input.bool(true, "Show Labels", group="HTF Candles")
//#endregion

//#region DEBUG inputs
debugMode = input.bool(false, "DEBUG: Log 4H Rollover Values", group="DEBUG")
debugForceZone = input.bool(false, "DEBUG: Force Draw Test Zone", group="DEBUG")
debugForceTop = input.float(0.0, "DEBUG: Test Zone Top (0 = close + 100)", group="DEBUG")
debugForceBottom = input.float(0.0, "DEBUG: Test Zone Bottom (0 = close - 100)", group="DEBUG")
//#endregion

//#region 4H series
o4raw = request.security(syminfo.tickerid, "240", open, lookahead=barmerge.lookahead_off)
h4raw = request.security(syminfo.tickerid, "240", high, lookahead=barmerge.lookahead_off)
l4raw = request.security(syminfo.tickerid, "240", low, lookahead=barmerge.lookahead_off)
c4raw = request.security(syminfo.tickerid, "240", close, lookahead=barmerge.lookahead_off)

// Robust new-4H-bar detection: fires exactly once per settled 4H period,
// on the chart bar that opens it. ta.change(time("240")) is unreliable on
// sub-4H charts because the rollover bar may not land where expected.
var int last4hTime = na
int cur4hTime = time("240")
bool new4hBar = not na(cur4hTime) and cur4hTime != last4hTime
if new4hBar
    last4hTime := cur4hTime

var float o4 = na
var float h4 = na
var float l4 = na
var float c4 = na

// Refresh from the SETTLED 4H context on EVERY bar. With lookahead_off,
// o4raw[1] is the just-closed 4H period - settled, not repainting - so it
// is safe to read on the new-4H-bar bar, which is the only bar where
// detection can fire.
if not na(o4raw[1])
    o4 := o4raw[1]
    h4 := h4raw[1]
    l4 := l4raw[1]
    c4 := c4raw[1]

// Live (in-progress) 4H candle for the right-edge display only.
// Gap detection keeps using the settled o4/h4/l4/c4 above.
float o4live = o4raw
float h4live = h4raw
float l4live = l4raw
float c4live = c4raw
//#endregion

//#region Zone storage
var array<box> zoneBoxes = array.new<box>()
var array<int> zoneDirs = array.new<int>()
var array<float> zoneTops = array.new<float>()
var array<float> zoneBottoms = array.new<float>()
var array<int> zoneLeftBars = array.new<int>()
var array<bool> zoneIsDebug = array.new<bool>()
//#endregion

//#region Utility functions
//@function Adds a new gap zone and enforces the live-zone cap.
//@param leftBar The bar_index where the zone was detected.
//@param top The top price of the zone.
//@param bottom The bottom price of the zone.
//@param dir 1 for bullish, -1 for bearish.
//@param fillColor The fill color for the box.
//@param borderColor The border color for the box.
//@param isDebug True for manually-forced test zones; these are exempt from mitigation,
//               from the stats table, and from right-edge projection.
//@returns None.
addZone(leftBar, top, bottom, dir, fillColor, borderColor, isDebug = false) =>
    rightBar = extendRight ? bar_index : leftBar
    zoneBox = box.new(left=leftBar, top=top, right=rightBar, bottom=bottom, xloc=xloc.bar_index, bgcolor=fillColor, border_color=borderColor, border_width=showBorder ? 1 : 0)
    zoneBoxes.push(zoneBox)
    zoneDirs.push(dir)
    zoneTops.push(top)
    zoneBottoms.push(bottom)
    zoneLeftBars.push(leftBar)
    zoneIsDebug.push(isDebug)

    while zoneBoxes.size() > maxZones
        oldestBox = zoneBoxes.shift()
        oldestBox.delete()
        zoneDirs.shift()
        zoneTops.shift()
        zoneBottoms.shift()
        zoneLeftBars.shift()
        zoneIsDebug.shift()

//@function Updates all live boxes to the current bar when extension is enabled.
//@returns None.
updateZoneEnds() =>
    if extendRight
        for bx in zoneBoxes
            bx.set_right(bar_index)

//@function Deletes mitigated zones using the full-sweep rule.
//         Debug zones are exempt so forced test zones always persist.
//@returns None.
removeMitigatedZones() =>
    if zoneBoxes.size() > 0
        survivingBoxes = array.new<box>()
        survivingDirs = array.new<int>()
        survivingTops = array.new<float>()
        survivingBottoms = array.new<float>()
        survivingLeftBars = array.new<int>()
        survivingIsDebug = array.new<bool>()
        for i = 0 to zoneBoxes.size() - 1
            dir = zoneDirs.get(i)
            top = zoneTops.get(i)
            bottom = zoneBottoms.get(i)
            isDbg = zoneIsDebug.get(i)
            mitigated = not isDbg and ((dir == 1 and low < bottom) or (dir == -1 and high > top))
            if mitigated
                zoneBoxes.get(i).delete()
            else
                survivingBoxes.push(zoneBoxes.get(i))
                survivingDirs.push(dir)
                survivingTops.push(top)
                survivingBottoms.push(bottom)
                survivingLeftBars.push(zoneLeftBars.get(i))
                survivingIsDebug.push(isDbg)
        zoneBoxes.clear()
        zoneDirs.clear()
        zoneTops.clear()
        zoneBottoms.clear()
        zoneLeftBars.clear()
        zoneIsDebug.clear()
        nSurv = survivingBoxes.size()
        if nSurv > 0
            for i = 0 to nSurv - 1
                zoneBoxes.push(survivingBoxes.get(i))
                zoneDirs.push(survivingDirs.get(i))
                zoneTops.push(survivingTops.get(i))
                zoneBottoms.push(survivingBottoms.get(i))
                zoneLeftBars.push(survivingLeftBars.get(i))
                zoneIsDebug.push(survivingIsDebug.get(i))

//@function Counts live zones and finds nearest bullish/bearish levels for the table.
//         Debug zones are skipped so the panel reflects real market structure only.
//@returns A tuple containing bullish count, bearish count, nearest bullish below price, nearest bearish above price.
getStats() =>
    bullCount = 0
    bearCount = 0
    float nearestBull = na
    float nearestBear = na
    nZones = zoneBoxes.size()
    if nZones > 0
        for i = 0 to nZones - 1
            if zoneIsDebug.get(i)
                continue
            dir = zoneDirs.get(i)
            top = zoneTops.get(i)
            bottom = zoneBottoms.get(i)
            if dir == 1
                bullCount += 1
                if bottom < close and (na(nearestBull) or bottom > nearestBull)
                    nearestBull := bottom
            else
                bearCount += 1
                if top > close and (na(nearestBear) or top < nearestBear)
                    nearestBear := top
    [bullCount, bearCount, nearestBull, nearestBear]

//@function Returns the nearest unmitigated zones by absolute distance from current price.
//         Debug zones are skipped so the right-edge projection shows real gaps only.
//@param n Maximum number of zones to return.
//@returns A tuple containing sorted zone indexes and matching distances.
getNearestGaps(n) =>
    var array<float> dists = array.new<float>()
    var array<int> idxs = array.new<int>()
    dists.clear()
    idxs.clear()
    nZones = zoneBoxes.size()
    if nZones > 0
        for i = 0 to nZones - 1
            if zoneIsDebug.get(i)
                continue
            mid = (zoneTops.get(i) + zoneBottoms.get(i)) / 2
            d = math.abs(mid - close)
            dists.push(d)
            idxs.push(i)
        nItems = dists.size()
        if nItems > 1
            for i = 0 to nItems - 2
                minIdx = i
                for j = i + 1 to nItems - 1
                    if dists.get(j) < dists.get(minIdx)
                        minIdx := j
                if minIdx != i
                    distI = dists.get(i)
                    idxI = idxs.get(i)
                    dists.set(i, dists.get(minIdx))
                    idxs.set(i, idxs.get(minIdx))
                    dists.set(minIdx, distI)
                    idxs.set(minIdx, idxI)
    [idxs, dists]
//#endregion

//#region Pattern detection
// Settled HTF values straight from the security series - no var-history ambiguity.
// With lookahead_off, [1] is the just-closed 4H period and [2] the one before it.
float o4s = o4raw[1]
float h4s = h4raw[1]
float l4s = l4raw[1]
float c4s = c4raw[1]
float h4s2 = h4raw[2]
float l4s2 = l4raw[2]

bullGap = showCandleGaps and new4hBar and not na(h4s) and o4s > h4s and math.abs(o4s - h4s) >= minGapTicks * syminfo.mintick
bearGap = showCandleGaps and new4hBar and not na(l4s) and o4s < l4s and math.abs(o4s - l4s) >= minGapTicks * syminfo.mintick
bullFvg = showFvg and new4hBar and not na(h4s2) and l4s > h4s2 and math.abs(l4s - h4s2) >= minGapTicks * syminfo.mintick
bearFvg = showFvg and new4hBar and not na(l4s2) and h4s < l4s2 and math.abs(h4s - l4s2) >= minGapTicks * syminfo.mintick

// DEBUG: log the raw 4H numbers on every rollover so the detection inputs
// can be read directly instead of inferred from whether a box appeared.
if debugMode and new4hBar
    log.info("4H roll | t={0} | o4s={1} h4s={2} l4s={3} c4s={4} | h4s2={5} l4s2={6} | gapUp={7} gapDn={8} fvgUp={9} fvgDn={10}", cur4hTime, o4s, h4s, l4s, c4s, h4s2, l4s2, o4s > h4s, o4s < l4s, l4s > h4s2, h4s < l4s2)
//#endregion

//#region Zone creation
if bullGap
    addZone(bar_index, o4s, h4s, 1, color.new(color.green, 85), color.new(color.green, 20))
if bearGap
    addZone(bar_index, l4s, o4s, -1, color.new(color.red, 85), color.new(color.red, 20))
if bullFvg
    addZone(bar_index, l4s, h4s2, 1, color.new(color.green, 85), color.new(color.green, 20))
if bearFvg
    addZone(bar_index, l4s2, h4s, -1, color.new(color.red, 85), color.new(color.red, 20))

// DEBUG: force a test zone with explicit top/bottom so the drawing pipeline
// (box creation -> mitigation -> projection -> table) can be verified
// independently of whether the market produced a real gap.
// Leaving both inputs at 0 auto-resolves to close +/- 100, so ticking the
// box alone always yields a valid below-price zone with no typing.
float dbgTop = debugForceTop == 0.0 ? close + 100 : debugForceTop
float dbgBottom = debugForceBottom == 0.0 ? close - 100 : debugForceBottom
if debugForceZone and barstate.islast and dbgTop > dbgBottom
    addZone(bar_index - 100, dbgTop, dbgBottom, 1, color.new(color.blue, 85), color.new(color.blue, 20), true)
//#endregion

//#region Zone maintenance
updateZoneEnds()
removeMitigatedZones()
//#endregion

//#region Right-edge projection
var array<box> projBoxes = array.new<box>()
var array<label> projLabels = array.new<label>()

if barstate.islast and showProjection
    // clear previous projection drawings
    if projBoxes.size() > 0
        for b in projBoxes
            b.delete()
        projBoxes.clear()
    if projLabels.size() > 0
        for lb in projLabels
            lb.delete()
        projLabels.clear()

    if debugProjection
        // DEBUG MODE: draw 3 dummy boxes at fixed offsets from current price
        // so the projection layout can be eyeballed without waiting for a live gap.
        for k = 0 to 2
            float dTop = close + debugSpacing * (k + 1) + debugSpacing * 0.5
            float dBot = close + debugSpacing * (k + 1) - debugSpacing * 0.5
            bool dIsBull = k % 2 == 0
            col = dIsBull ? color.new(color.green, 70) : color.new(color.red, 70)
            bcol = dIsBull ? color.new(color.green, 10) : color.new(color.red, 10)
            pb = box.new(left=bar_index, top=dTop, right=bar_index + projectionOffset, bottom=dBot, xloc=xloc.bar_index, bgcolor=col, border_color=bcol, border_width=1)
            projBoxes.push(pb)
            lblText = (dIsBull ? "BULL " : "BEAR ") + str.tostring(dBot, format.mintick) + " - " + str.tostring(dTop, format.mintick) + " (DEBUG)"
            plb = label.new(x=bar_index + projectionOffset, y=(dTop + dBot) / 2, text=lblText, xloc=xloc.bar_index, style=label.style_label_left, color=col, textcolor=color.black, size=size.small)
            projLabels.push(plb)
    else
        [pIdxs, pDists] = getNearestGaps(projectionCount)
        nProj = math.min(projectionCount, pIdxs.size())
        if nProj > 0
            for k = 0 to nProj - 1
                zi = pIdxs.get(k)
                zTop = zoneTops.get(zi)
                zBot = zoneBottoms.get(zi)
                zDir = zoneDirs.get(zi)
                zLeft = zoneLeftBars.get(zi)
                col = zDir == 1 ? color.new(color.green, 70) : color.new(color.red, 70)
                bcol = zDir == 1 ? color.new(color.green, 10) : color.new(color.red, 10)
                pb = box.new(left=bar_index, top=zTop, right=bar_index + projectionOffset, bottom=zBot, xloc=xloc.bar_index, bgcolor=col, border_color=bcol, border_width=1)
                projBoxes.push(pb)
                lblText = (zDir == 1 ? "BULL " : "BEAR ") + str.tostring(zBot, format.mintick) + " - " + str.tostring(zTop, format.mintick)
                plb = label.new(x=bar_index + projectionOffset, y=(zTop + zBot) / 2, text=lblText, xloc=xloc.bar_index, style=label.style_label_left, color=col, textcolor=color.black, size=size.small)
                projLabels.push(plb)
//#endregion

//#region HTF candles
var array<box> htfBoxes = array.new<box>()
var array<line> htfWicks = array.new<line>()
var array<label> htfLabels = array.new<label>()

if barstate.islast and showHTFCandles
    if htfBoxes.size() > 0
        for b in htfBoxes
            b.delete()
        htfBoxes.clear()
    if htfWicks.size() > 0
        for wick in htfWicks
            wick.delete()
        htfWicks.clear()
    if htfLabels.size() > 0
        for lb in htfLabels
            lb.delete()
        htfLabels.clear()

    if not na(o4live) and not na(h4live) and not na(l4live) and not na(c4live)
        slotRight = bar_index + htfCandleOffset + htfCandleWidth
        slotLeft = slotRight - htfCandleWidth
        isBull = c4live > o4live
        isBear = c4live < o4live
        fillColor = isBull ? color.new(color.green, 60) : isBear ? color.new(color.red, 60) : color.new(color.gray, 60)
        borderColor = isBull ? color.new(color.green, 10) : isBear ? color.new(color.red, 10) : color.new(color.gray, 10)

        htfBox = box.new(left=slotLeft, top=math.max(o4live, c4live), right=slotRight, bottom=math.min(o4live, c4live), xloc=xloc.bar_index, bgcolor=fillColor, border_color=borderColor, border_width=1)
        htfBoxes.push(htfBox)

        if htfShowWicks
            cx = (slotLeft + slotRight) / 2
            htfWick = line.new(x1=cx, y1=l4live, x2=cx, y2=h4live, xloc=xloc.bar_index, color=borderColor, width=1)
            htfWicks.push(htfWick)

        if htfShowLabels
            htfLabel = label.new(x=slotRight, y=c4live, text="4H " + str.tostring(c4live, format.mintick), xloc=xloc.bar_index, style=label.style_label_left, color=fillColor, textcolor=color.black, size=size.small)
            htfLabels.push(htfLabel)
//#endregion

//#region Table
var table infoTable = table.new(position.top_right, 2, 5, border_width=1)
if barstate.islast and showTable
    [bullCount, bearCount, nearestBull, nearestBear] = getStats()
    infoTable.cell(0, 0, "4H Unmitigated Gaps", text_color=color.white, bgcolor=color.black, text_size=size.small)
    infoTable.cell(1, 0, "", text_color=color.white, bgcolor=color.black)
    infoTable.cell(0, 1, "Bullish Live", text_color=color.white, bgcolor=color.black, text_size=size.small)
    infoTable.cell(1, 1, str.tostring(bullCount), text_color=color.white, bgcolor=color.new(color.black, 80), text_size=size.small)
    infoTable.cell(0, 2, "Bearish Live", text_color=color.white, bgcolor=color.black, text_size=size.small)
    infoTable.cell(1, 2, str.tostring(bearCount), text_color=color.white, bgcolor=color.new(color.black, 80), text_size=size.small)
    infoTable.cell(0, 3, "Nearest Bull Below", text_color=color.white, bgcolor=color.black, text_size=size.small)
    infoTable.cell(1, 3, na(nearestBull) ? "n/a" : str.tostring(nearestBull, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 80), text_size=size.small)
    infoTable.cell(0, 4, "Nearest Bear Above", text_color=color.white, bgcolor=color.black, text_size=size.small)
    infoTable.cell(1, 4, na(nearestBear) ? "n/a" : str.tostring(nearestBear, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 80), text_size=size.small)
//#endregion
````
