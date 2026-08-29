<!-- tradingview-pine-id: PUB;73d7477c6e1d4d9291ca616c8eb06e4b -->
<!-- tradingviewscripts-format: 1 -->
# 16 OTG

Source: https://www.tradingview.com/script/dQin7UuM-16-OTGN/

## Description

New indicator for ORB with an easy to read panel.  This indicator can be used to form custom time frames to help with your trading. It also has built in supply and demand formation lines as well as a target price and stop loss set.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// EMA Clouds section © ripster47 (ported from Pine v4 to v6)
// ORB box section + confluence logic added separately
//@version=6
indicator("16 OTG", overlay=true, max_lines_count=500, max_boxes_count=250, max_labels_count=300)


// ═══════════════════════════════════════════
//  16 OTG OFFICIAL COLOR THEME
// ═══════════════════════════════════════════
electricPurple = color.rgb(176, 38, 255)
electricTeal   = color.rgb(0, 229, 212)
brightRed      = color.rgb(255, 23, 68)
winnerLime     = color.rgb(57, 255, 20)
expiredGray    = color.rgb(110, 110, 120)
panelBlack     = color.rgb(18, 18, 20)


// ═══════════════════════════════════════════
//  SECTION 1: 16-MINUTE STOCK OPENING RANGE BREAKOUT
// ═══════════════════════════════════════════

grpORB = "Stock ORB Sessions"
sessionPreset = input.string("AM", "ORB Session",
     options=["AM", "PM", "Custom"], group=grpORB)

customSession = input.session("0830-0846", "Custom ORB Window", group=grpORB)
customTimezone = input.string("America/Chicago", "Custom Timezone", group=grpORB)

orbSession = sessionPreset == "AM" ? "0830-0846" :
     sessionPreset == "PM" ? "1200-1216" :
     customSession

sessTimezone = sessionPreset == "AM" or sessionPreset == "PM" ?
     "America/Chicago" : customTimezone

// Target box remains active until PT3 is hit or the US regular session closes.
customTargetSession = input.session("0830-1500", "Custom Target Session", group=grpORB)
regionTargetSession = sessionPreset == "AM" or sessionPreset == "PM" ?
     "0830-1500" : customTargetSession

inRegionTargetSession = not na(time(timeframe.period, regionTargetSession, sessTimezone))
regionTargetSessionEnded = not inRegionTargetSession and inRegionTargetSession[1]
showBox      = input.bool(true, "Show ORB Box", group=grpORB)
boxFillColor = input.color(color.new(electricPurple, 88), "Box Fill", group=grpORB, tooltip="Electric purple ORB fill")
boxEdgeColor = input.color(color.new(electricPurple, 5), "Box Border", group=grpORB)
showORB      = input.bool(true, "Show ORB High/Low Lines", group=grpORB)
showMid      = input.bool(true, "Show ORB Midpoint", group=grpORB)
showBreakSig = input.bool(false, "Show Plain Breakout Triangles (no cloud filter)", group=grpORB)
showPriceLbl = input.bool(true, "Show Price Labels on ORB Lines", group=grpORB)
orbHighColor = input.color(electricPurple, "ORB High Color", group=grpORB)
orbLowColor  = input.color(electricPurple, "ORB Low Color", group=grpORB)
orbMidColor  = input.color(color.new(electricPurple, 35), "Midpoint Color", group=grpORB)
sigTF        = input.timeframe("1", "Breakout Confirmation Timeframe", group=grpORB)

// Detect whether current bar is inside the OR window
inSession = not na(time(timeframe.period, orbSession, sessTimezone))
newDay    = timeframe.change("D")

// ── The ORB is built from 5-MINUTE candles (the first three of the session),
// ── so the levels are identical no matter what chart timeframe you're viewing
orbTF = input.timeframe("5", "ORB Building Timeframe", group=grpORB, tooltip="The range is measured on this timeframe's candles. Default 5 = the first three 5-min candles form the 15-min ORB.")

f_orb() =>
    _inSess = not na(time(timeframe.period, orbSession, sessTimezone))
    var float _h = na
    var float _l = na
    var bool  _set = false
    if timeframe.change("D")
        _h := na
        _l := na
        _set := false
    if _inSess
        _h := na(_h) ? high : math.max(_h, high)
        _l := na(_l) ? low : math.min(_l, low)
        _set := true
    // Return last COMPLETED candle's values (offset [1] + lookahead_on = confirmed, no repaint)
    [_h[1], _l[1], _set[1]]

[orbHigh, orbLow, orbSetRaw] = request.security(syminfo.tickerid, orbTF, f_orb(), lookahead=barmerge.lookahead_on)
orbSet = orbSetRaw == true  // normalize to a clean bool

orbMid = (orbHigh + orbLow) / 2

// Only plot after the window closes (frozen levels)
rangeDone = orbSet and not inSession

// ── ORB BOX: left edge anchored at the session OPEN (9:30) so the first
// ── three 5-min candles sit inside it, then the right edge drags forward
var box orbBox = na
var int orbStartBar = na

// Remember the bar where the opening range began
if inSession and not inSession[1]
    orbStartBar := bar_index

sessionJustEnded = orbSet and not inSession and inSession[1]

if showBox and sessionJustEnded
    orbBox := box.new(left=na(orbStartBar) ? bar_index : orbStartBar, top=orbHigh, right=bar_index, bottom=orbLow, bgcolor=boxFillColor, border_color=boxEdgeColor, border_width=1)

if showBox and rangeDone and not na(orbBox)
    box.set_right(orbBox, bar_index)

// Optional classic lines (blue by default so they stand out against the clouds)
plot(showORB and rangeDone ? orbHigh : na, "ORB High", color=orbHighColor, linewidth=2, style=plot.style_linebr)
plot(showORB and rangeDone ? orbLow  : na, "ORB Low",  color=orbLowColor,  linewidth=2, style=plot.style_linebr)
plot(showMid and rangeDone ? orbMid : na, "ORB Mid", color=orbMidColor, linewidth=1, style=plot.style_linebr)

// ── PRICE LABELS: ride the right end of the ORB lines, showing the level
var label orbHighLbl = na
var label orbLowLbl  = na

if showPriceLbl and sessionJustEnded
    // Remove yesterday's labels so only today's levels are tagged
    label.delete(orbHighLbl)
    label.delete(orbLowLbl)
    orbHighLbl := label.new(bar_index, orbHigh, sessionPreset + " ORB High  " + str.tostring(orbHigh, format.mintick), style=label.style_label_left, color=color.new(electricPurple, 10), textcolor=color.white, size=size.small)
    orbLowLbl  := label.new(bar_index, orbLow,  sessionPreset + " ORB Low  "  + str.tostring(orbLow,  format.mintick), style=label.style_label_left, color=color.new(electricPurple, 10), textcolor=color.white, size=size.small)

if showPriceLbl and rangeDone and not na(orbHighLbl)
    label.set_x(orbHighLbl, bar_index)
    label.set_x(orbLowLbl,  bar_index)

// Breakout signals: fire when a 5-MINUTE candle CLOSES outside the range
// (works on any chart timeframe ≤ 5min; non-repainting via confirmed-bar close)

// Last COMPLETED close/high/low of the signal timeframe ([1] + lookahead_on = confirmed, no repaint)
sigClose = request.security(syminfo.tickerid, sigTF, close[1], lookahead=barmerge.lookahead_on)
sigHigh  = request.security(syminfo.tickerid, sigTF, high[1],  lookahead=barmerge.lookahead_on)
sigLow   = request.security(syminfo.tickerid, sigTF, low[1],   lookahead=barmerge.lookahead_on)

// True on the first chart bar after a signal-TF candle finishes
sigBarClosed = timeframe.change(sigTF)

var bool longFired  = false
var bool shortFired = false
if newDay
    longFired  := false
    shortFired := false

longBreak  = rangeDone and not longFired  and sigBarClosed and sigClose > orbHigh
shortBreak = rangeDone and not shortFired and sigBarClosed and sigClose < orbLow

if longBreak
    longFired := true
if shortBreak
    shortFired := true

plotshape(showBreakSig and longBreak,  "Long Breakout",  style=shape.triangleup,   location=location.belowbar, color=color.green, size=size.small, text="ORB↑", offset=-1)
plotshape(showBreakSig and shortBreak, "Short Breakout", style=shape.triangledown, location=location.abovebar, color=color.red,   size=size.small, text="ORB↓", offset=-1)

alertcondition(longBreak,  "ORB Long Breakout",  "A 5-min candle closed above the 15-min opening range high")
alertcondition(shortBreak, "ORB Short Breakout", "A 5-min candle closed below the 15-min opening range low")

// ═══════════════════════════════════════════
//  SECTION 2: RIPSTER EMA CLOUDS
//  Faithful port of "Ripster EMA Clouds" © ripster47
//  Original licensed under Mozilla Public License 2.0
//  https://mozilla.org/MPL/2.0/  (converted v4 → v6)
// ═══════════════════════════════════════════

grpCloud = "Ripster EMA Clouds"
matype = input.string("EMA", "MA Type", options=["EMA", "SMA"], group=grpCloud)

ma_len1  = input.int(8,   "Short EMA1 Length", group=grpCloud)
ma_len2  = input.int(9,   "Long EMA1 Length",  group=grpCloud)
ma_len3  = input.int(5,   "Short EMA2 Length", group=grpCloud)
ma_len4  = input.int(12,  "Long EMA2 Length",  group=grpCloud)
ma_len5  = input.int(34,  "Short EMA3 Length", group=grpCloud)
ma_len6  = input.int(50,  "Long EMA3 Length",  group=grpCloud)
ma_len7  = input.int(72,  "Short EMA4 Length", group=grpCloud)
ma_len8  = input.int(89,  "Long EMA4 Length",  group=grpCloud)
ma_len9  = input.int(180, "Short EMA5 Length", group=grpCloud)
ma_len10 = input.int(200, "Long EMA5 Length",  group=grpCloud)

srcC = input.source(hl2, "Source", group=grpCloud)

showLine = input.bool(false, "Display EMA Line", group=grpCloud)
ema1 = input.bool(true,  "Show EMA Cloud-1", group=grpCloud)
ema2 = input.bool(true,  "Show EMA Cloud-2", group=grpCloud)
ema3 = input.bool(true,  "Show EMA Cloud-3", group=grpCloud)
ema4 = input.bool(false, "Show EMA Cloud-4", group=grpCloud)
ema5 = input.bool(false, "Show EMA Cloud-5", group=grpCloud)

emacloudleading = input.int(0, "Leading Period For EMA Cloud", minval=0, group=grpCloud)

// Both MA types are computed every bar (required for consistent series history),
// then the selected one is returned
f_ma(simple int malen) =>
    emaVal = ta.ema(srcC, malen)
    smaVal = ta.sma(srcC, malen)
    matype == "EMA" ? emaVal : smaVal

mashort1 = f_ma(ma_len1)
malong1  = f_ma(ma_len2)
mashort2 = f_ma(ma_len3)
malong2  = f_ma(ma_len4)
mashort3 = f_ma(ma_len5)
malong3  = f_ma(ma_len6)
mashort4 = f_ma(ma_len7)
malong4  = f_ma(ma_len8)
mashort5 = f_ma(ma_len9)
malong5  = f_ma(ma_len10)

// Ripster's exact cloud colors
cloudcolour1 = mashort1 >= malong1 ? #036103 : #880e4f
cloudcolour2 = mashort2 >= malong2 ? #4caf50 : #f44336
cloudcolour3 = mashort3 >= malong3 ? #2196f3 : #ffb74d
cloudcolour4 = mashort4 >= malong4 ? #009688 : #f06292
cloudcolour5 = mashort5 >= malong5 ? #05bed5 : #e65100

// Slope-based line colors (only visible when "Display EMA Line" is on)
mashortcolor1 = mashort1 >= mashort1[1] ? color.olive : color.maroon
mashortcolor2 = mashort2 >= mashort2[1] ? color.olive : color.maroon
mashortcolor3 = mashort3 >= mashort3[1] ? color.olive : color.maroon
mashortcolor4 = mashort4 >= mashort4[1] ? color.olive : color.maroon
mashortcolor5 = mashort5 >= mashort5[1] ? color.rgb(179, 179, 43) : color.maroon

mashortline1 = plot(ema1 ? mashort1 : na, "Short Leading EMA1", color=showLine ? mashortcolor1 : color(na), linewidth=1, offset=emacloudleading)
mashortline2 = plot(ema2 ? mashort2 : na, "Short Leading EMA2", color=showLine ? mashortcolor2 : color(na), linewidth=1, offset=emacloudleading)
mashortline3 = plot(ema3 ? mashort3 : na, "Short Leading EMA3", color=showLine ? mashortcolor3 : color(na), linewidth=1, offset=emacloudleading)
mashortline4 = plot(ema4 ? mashort4 : na, "Short Leading EMA4", color=showLine ? mashortcolor4 : color(na), linewidth=1, offset=emacloudleading)
mashortline5 = plot(ema5 ? mashort5 : na, "Short Leading EMA5", color=showLine ? mashortcolor5 : color(na), linewidth=1, offset=emacloudleading)

malongcolor1 = malong1 >= malong1[1] ? color.green : color.red
malongcolor2 = malong2 >= malong2[1] ? color.green : color.red
malongcolor3 = malong3 >= malong3[1] ? color.green : color.red
malongcolor4 = malong4 >= malong4[1] ? color.green : color.red
malongcolor5 = malong5 >= malong5[1] ? color.green : color.red

malongline1 = plot(ema1 ? malong1 : na, "Long Leading EMA1", color=showLine ? malongcolor1 : color(na), linewidth=3, offset=emacloudleading)
malongline2 = plot(ema2 ? malong2 : na, "Long Leading EMA2", color=showLine ? malongcolor2 : color(na), linewidth=3, offset=emacloudleading)
malongline3 = plot(ema3 ? malong3 : na, "Long Leading EMA3", color=showLine ? malongcolor3 : color(na), linewidth=3, offset=emacloudleading)
malongline4 = plot(ema4 ? malong4 : na, "Long Leading EMA4", color=showLine ? malongcolor4 : color(na), linewidth=3, offset=emacloudleading)
malongline5 = plot(ema5 ? malong5 : na, "Long Leading EMA5", color=showLine ? malongcolor5 : color(na), linewidth=3, offset=emacloudleading)

// Ripster's exact per-cloud transparencies
fill(mashortline1, malongline1, color=color.new(cloudcolour1, 45), title="MA Cloud1")
fill(mashortline2, malongline2, color=color.new(cloudcolour2, 65), title="MA Cloud2")
fill(mashortline3, malongline3, color=color.new(cloudcolour3, 70), title="MA Cloud3")
fill(mashortline4, malongline4, color=color.new(cloudcolour4, 65), title="MA Cloud4")
fill(mashortline5, malongline5, color=color.new(cloudcolour5, 65), title="MA Cloud5")


// ═══════════════════════════════════════════
//  SECTION 3: 4-MINUTE SUPPLY / DEMAND ZONES
//  Confirmed 4-minute pivot zones, displayed on the 1-minute chart.
// ═══════════════════════════════════════════
grpZones = "4-Minute Supply / Demand"
showZones = input.bool(true, "Show 5m Supply / Demand", group=grpZones)
zoneTF = input.timeframe("4", "Zone Timeframe", group=grpZones)
zonePivotLeft = input.int(4, "Pivot Bars Left", minval=2, maxval=20, group=grpZones)
zonePivotRight = input.int(4, "Pivot Bars Right", minval=2, maxval=20, group=grpZones)
zoneAtrLen = input.int(14, "ATR Length", minval=2, group=grpZones)
zoneWidthAtr = input.float(0.20, "Zone Half-Width (ATR)", minval=0.05, maxval=1.0, step=0.05, group=grpZones)
zoneNearAtr = input.float(0.35, "Near-Zone Distance (ATR)", minval=0.05, maxval=2.0, step=0.05, group=grpZones)
zoneMaxPerSide = input.int(3, "Maximum Zones Per Side", minval=1, maxval=8, group=grpZones)
supplyFill = input.color(color.new(brightRed, 88), "Supply Fill", group=grpZones)
supplyBorder = input.color(color.new(brightRed, 10), "Supply Border", group=grpZones)
demandFill = input.color(color.new(electricTeal, 88), "Demand Fill", group=grpZones)
demandBorder = input.color(color.new(electricTeal, 10), "Demand Border", group=grpZones)

f_zoneData() =>
    _ph = ta.pivothigh(high, zonePivotLeft, zonePivotRight)
    _pl = ta.pivotlow(low, zonePivotLeft, zonePivotRight)
    _atr = ta.atr(zoneAtrLen)
    _pivotTime = time[zonePivotRight]
    [_ph, _pl, _atr[zonePivotRight], _pivotTime]

[zonePivotHigh, zonePivotLow, zonePivotAtr, zonePivotTime] =
     request.security(syminfo.tickerid, zoneTF, f_zoneData(), lookahead=barmerge.lookahead_off)

newSupplyPivot = showZones and not na(zonePivotHigh) and (na(zonePivotTime[1]) or zonePivotTime != zonePivotTime[1])
newDemandPivot = showZones and not na(zonePivotLow) and (na(zonePivotTime[1]) or zonePivotTime != zonePivotTime[1])

var supplyBoxes = array.new_box()
var supplyTops = array.new_float()
var supplyBottoms = array.new_float()
var demandBoxes = array.new_box()
var demandTops = array.new_float()
var demandBottoms = array.new_float()

if newSupplyPivot
    zoneHalf = math.max(zonePivotAtr * zoneWidthAtr, syminfo.mintick)
    zTop = zonePivotHigh + zoneHalf
    zBottom = zonePivotHigh - zoneHalf
    zBox = box.new(zonePivotTime, zTop, time, zBottom, xloc=xloc.bar_time, extend=extend.right,
         bgcolor=supplyFill, border_color=supplyBorder, border_width=1)
    array.push(supplyBoxes, zBox)
    array.push(supplyTops, zTop)
    array.push(supplyBottoms, zBottom)
    if array.size(supplyBoxes) > zoneMaxPerSide
        box.delete(array.shift(supplyBoxes))
        array.shift(supplyTops)
        array.shift(supplyBottoms)

if newDemandPivot
    zoneHalf = math.max(zonePivotAtr * zoneWidthAtr, syminfo.mintick)
    zTop = zonePivotLow + zoneHalf
    zBottom = zonePivotLow - zoneHalf
    zBox = box.new(zonePivotTime, zTop, time, zBottom, xloc=xloc.bar_time, extend=extend.right,
         bgcolor=demandFill, border_color=demandBorder, border_width=1)
    array.push(demandBoxes, zBox)
    array.push(demandTops, zTop)
    array.push(demandBottoms, zBottom)
    if array.size(demandBoxes) > zoneMaxPerSide
        box.delete(array.shift(demandBoxes))
        array.shift(demandTops)
        array.shift(demandBottoms)

// Remove invalidated zones using backward while loops.
brokeSupply = false
brokeDemand = false

if array.size(supplyBoxes) > 0
    int supplyIndex = array.size(supplyBoxes) - 1
    while supplyIndex >= 0
        if close > array.get(supplyTops, supplyIndex)
            brokeSupply := true
            box.delete(array.get(supplyBoxes, supplyIndex))
            array.remove(supplyBoxes, supplyIndex)
            array.remove(supplyTops, supplyIndex)
            array.remove(supplyBottoms, supplyIndex)
        supplyIndex -= 1

if array.size(demandBoxes) > 0
    int demandIndex = array.size(demandBoxes) - 1
    while demandIndex >= 0
        if close < array.get(demandBottoms, demandIndex)
            brokeDemand := true
            box.delete(array.get(demandBoxes, demandIndex))
            array.remove(demandBoxes, demandIndex)
            array.remove(demandTops, demandIndex)
            array.remove(demandBottoms, demandIndex)
        demandIndex -= 1

float nearestSupplyTop = na
float nearestSupplyBottom = na
float nearestSupplyDist = na
if array.size(supplyBoxes) > 0
    for i = 0 to array.size(supplyBoxes) - 1
        zTop = array.get(supplyTops, i)
        zBottom = array.get(supplyBottoms, i)
        dist = close < zBottom ? zBottom - close : close <= zTop ? 0.0 : na
        if not na(dist) and (na(nearestSupplyDist) or dist < nearestSupplyDist)
            nearestSupplyDist := dist
            nearestSupplyTop := zTop
            nearestSupplyBottom := zBottom

float nearestDemandTop = na
float nearestDemandBottom = na
float nearestDemandDist = na
if array.size(demandBoxes) > 0
    for i = 0 to array.size(demandBoxes) - 1
        zTop = array.get(demandTops, i)
        zBottom = array.get(demandBottoms, i)
        dist = close > zTop ? close - zTop : close >= zBottom ? 0.0 : na
        if not na(dist) and (na(nearestDemandDist) or dist < nearestDemandDist)
            nearestDemandDist := dist
            nearestDemandTop := zTop
            nearestDemandBottom := zBottom

zoneCurrentAtr = request.security(syminfo.tickerid, zoneTF, ta.atr(zoneAtrLen), lookahead=barmerge.lookahead_off)
insideSupply = not na(nearestSupplyTop) and close >= nearestSupplyBottom and close <= nearestSupplyTop
insideDemand = not na(nearestDemandTop) and close >= nearestDemandBottom and close <= nearestDemandTop
nearSupply = not insideSupply and not na(nearestSupplyDist) and nearestSupplyDist <= zoneCurrentAtr * zoneNearAtr
nearDemand = not insideDemand and not na(nearestDemandDist) and nearestDemandDist <= zoneCurrentAtr * zoneNearAtr

zoneStatusText = brokeSupply ? "SUPPLY BREAK" :
     brokeDemand ? "DEMAND BREAK" :
     insideSupply ? "IN SUPPLY" :
     insideDemand ? "IN DEMAND" :
     nearSupply ? "NEAR SUPPLY" :
     nearDemand ? "NEAR DEMAND" : "BETWEEN ZONES"

zoneStatusColor = brokeSupply ? winnerLime :
     brokeDemand ? color.red :
     insideSupply or nearSupply ? color.red :
     insideDemand or nearDemand ? color.green : color.gray

alertcondition(brokeSupply, "4m Supply Break", "16 OTG: price closed above a 4-minute supply zone")
alertcondition(brokeDemand, "4m Demand Break", "16 OTG: price closed below a 4-minute demand zone")

// ═══════════════════════════════════════════
//  SECTION 4: CONFLUENCE ALERT (OPTIONAL)
// ═══════════════════════════════════════════
grpConf = "Confluence"
useConf = input.bool(true, "Confluence Signals (ORB break + cloud agreement)", group=grpConf)
cloudFilter = input.string("Cloud 1 only (fast)", "Cloud Filter", options=["Cloud 1 only (fast)", "Cloud 1 + Cloud 3 (strict)"], group=grpConf, tooltip="Fast = GO fires when the 8/9 cloud agrees with the break. Strict = the 34/50 cloud must agree too (fewer, later signals).")
strictClouds = cloudFilter == "Cloud 1 + Cloud 3 (strict)"

cloudBull = mashort1 >= malong1 and (not strictClouds or mashort3 >= malong3)
cloudBear = mashort1 <  malong1 and (not strictClouds or mashort3 <  malong3)

// Confluence has its OWN once-per-day latch, independent of the plain breakout.
// This way, if the first breakout candle happens before the clouds align,
// the GO can still fire on a LATER 5-min close outside the range once they do.
var bool confLongFired  = false
var bool confShortFired = false
if newDay
    confLongFired  := false
    confShortFired := false

confLong  = useConf and not confLongFired  and rangeDone and sigBarClosed and sigClose > orbHigh and cloudBull
confShort = useConf and not confShortFired and rangeDone and sigBarClosed and sigClose < orbLow  and cloudBear

if confLong
    confLongFired := true
if confShort
    confShortFired := true

// GO labels — placed to the LEFT of the confirmation candle at its close price,
// so they never overlap the profit box that starts on that candle
if confLong
    label.new(bar_index - 1, sigClose, sessionPreset + " 🐂 GO", style=label.style_label_up, color=color.new(electricTeal, 0), textcolor=color.white, size=size.small)
if confShort
    label.new(bar_index - 1, sigClose, sessionPreset + " 🐻 GO", style=label.style_label_down, color=color.new(brightRed, 0), textcolor=color.white, size=size.small)

alertcondition(confLong,  "🐂 GO",  "16 OTG 🐂 GO: stock ORB breakout with bullish EMA cloud alignment")
alertcondition(confShort, "🐻 GO", "16 OTG 🐻 GO: stock ORB breakout with bearish EMA cloud alignment")

// ═══════════════════════════════════════════
//  SECTION 5: LIVE PROFIT TARGET BOX — PT1 / PT2 / PT3
//  Uses the confirmed 1-minute signal candle. No AI or predictive model.
// ═══════════════════════════════════════════
grpPT = "Live Profit Target Box"
showPT = input.bool(true, "Show Profit Target Box", group=grpPT)
showStop = input.bool(true, "Show Stop", group=grpPT)
pt1Pct = input.float(100.0, "PT1 (% of confirmation candle)", minval=25, step=25, group=grpPT)
pt2Pct = input.float(200.0, "PT2 (% of confirmation candle)", minval=50, step=25, group=grpPT)
pt3Pct = input.float(300.0, "PT3 (% of confirmation candle)", minval=75, step=25, group=grpPT)
profitFill = input.color(color.new(electricTeal, 90), "Target Box Fill", group=grpPT)
profitBorder = input.color(color.new(electricTeal, 0), "Target Box Border", group=grpPT)
riskFill = input.color(color.new(brightRed, 94), "Risk Box Fill", group=grpPT)
riskBorder = input.color(color.new(brightRed, 20), "Risk Box Border", group=grpPT)
pt1Color = input.color(color.green, "PT1 Color", group=grpPT)
pt2Color = input.color(color.yellow, "PT2 Color", group=grpPT)
pt3Color = input.color(color.red, "PT3 Color", group=grpPT)
stopColor = input.color(brightRed, "Stop Color", group=grpPT)
stopCloseConfirm = input.bool(true, "Stop Requires Confirmed Close", group=grpPT,
     tooltip="When enabled, wick touches do not end the trade. The stop acts as support/demand for bullish trades and resistance/supply for bearish trades. The trade ends only after a confirmed close beyond the stop.")
showStopHoldLabels = input.bool(true, "Show Stop Held Labels", group=grpPT)
stopHoldCooldown = input.int(5, "Bars Between Stop Held Labels", minval=1, maxval=100, group=grpPT)

var box profitBox = na
var box riskBox = na
var line entryLine = na
var line stopLine = na
var line pt3Line = na
var label tradeBoxLabel = na

var bool tradeActive = false
var bool targetBoxActive = false
var bool targetSessionExpired = false
var bool tradeLong = false
var bool pt1Hit = false
var bool pt2Hit = false
var bool pt3Hit = false
var bool tradeStopped = false
var int stopTouchCount = 0
var int lastStopHoldLabelBar = na
var float entryPrice = na
var float stopPrice = na
var float pt1Price = na
var float pt2Price = na
var float pt3Price = na
var int tradeStartBar = na

newGo = confLong or confShort

if newDay
    tradeActive := false
    targetBoxActive := false
    targetSessionExpired := false
    pt1Hit := false
    pt2Hit := false
    pt3Hit := false
    tradeStopped := false
    stopTouchCount := 0
    lastStopHoldLabelBar := na

if showPT and newGo
    box.delete(profitBox)
    box.delete(riskBox)
    line.delete(entryLine)
    line.delete(stopLine)
    line.delete(pt3Line)
    label.delete(tradeBoxLabel)

    tradeLong := confLong
    tradeStartBar := bar_index
    entryPrice := sigClose
    candleRange = math.max(sigHigh - sigLow, syminfo.mintick)
    stopPrice := tradeLong ? sigLow : sigHigh
    pt1Price := tradeLong ? entryPrice + candleRange * pt1Pct / 100.0 : entryPrice - candleRange * pt1Pct / 100.0
    pt2Price := tradeLong ? entryPrice + candleRange * pt2Pct / 100.0 : entryPrice - candleRange * pt2Pct / 100.0
    pt3Price := tradeLong ? entryPrice + candleRange * pt3Pct / 100.0 : entryPrice - candleRange * pt3Pct / 100.0

    profitBox := box.new(
         left=bar_index - 1,
         top=math.max(entryPrice, pt3Price),
         right=bar_index,
         bottom=math.min(entryPrice, pt3Price),
         bgcolor=profitFill,
         border_color=profitBorder,
         border_width=1)

    if showStop
        riskBox := box.new(
             left=bar_index - 1,
             top=math.max(entryPrice, stopPrice),
             right=bar_index,
             bottom=math.min(entryPrice, stopPrice),
             bgcolor=riskFill,
             border_color=riskBorder,
             border_width=1)

    entryLine := line.new(bar_index - 1, entryPrice, bar_index, entryPrice, color=color.white, width=2)
    pt3Line := line.new(bar_index - 1, pt3Price, bar_index, pt3Price, color=electricTeal, width=3)
    if showStop
        stopLine := line.new(bar_index - 1, stopPrice, bar_index, stopPrice, color=brightRed, width=3, style=line.style_solid)

    symbolText = tradeLong ? "🐂" : "🐻"
    targetMove = math.abs(pt3Price - entryPrice)
    targetPctMove = entryPrice != 0 ? targetMove / entryPrice * 100.0 : na
    riskAmount = math.abs(entryPrice - stopPrice)
    targetRR = riskAmount > 0 ? targetMove / riskAmount : na
    tradeBoxLabel := label.new(
         bar_index,
         pt3Price,
         symbolText + "  TARGET " + str.tostring(pt3Price, format.mintick) +
         "\n+" + str.tostring(targetMove, format.mintick) +
         " (" + str.tostring(targetPctMove, "#.##") + "%)" +
         "\nR:R " + str.tostring(targetRR, "#.##"),
         style=tradeLong ? label.style_label_lower_left : label.style_label_upper_left,
         color=color.new(electricTeal, 8),
         textcolor=color.white,
         size=size.small)

    tradeActive := true
    targetBoxActive := true
    targetSessionExpired := false
    pt1Hit := false
    pt2Hit := false
    pt3Hit := false
    tradeStopped := false
    stopTouchCount := 0
    lastStopHoldLabelBar := na

if showPT and targetBoxActive and not na(profitBox) and not na(tradeStartBar)
    box.set_right(profitBox, bar_index)
    line.set_x2(entryLine, bar_index)
    line.set_x2(pt3Line, bar_index)
    if showStop and not na(riskBox)
        box.set_right(riskBox, bar_index)
    if showStop and not na(stopLine)
        line.set_x2(stopLine, bar_index)
    if not na(tradeBoxLabel)
        label.set_x(tradeBoxLabel, bar_index)

canEvaluateTarget = targetBoxActive and not na(tradeStartBar) and bar_index > tradeStartBar
canEvaluateStop = tradeActive and not na(tradeStartBar) and bar_index > tradeStartBar
pt1Tagged = canEvaluateTarget and not pt1Hit and (tradeLong ? high >= pt1Price : low <= pt1Price)
pt2Tagged = canEvaluateTarget and not pt2Hit and (tradeLong ? high >= pt2Price : low <= pt2Price)
pt3Tagged = canEvaluateTarget and not pt3Hit and (tradeLong ? high >= pt3Price : low <= pt3Price)

// A wick may touch or pierce the stop and then reject. In close-confirm mode,
// that touch does not end the trade. The stop acts as demand for a bullish
// trade and supply for a bearish trade until price closes beyond it.
stopWickTouched = canEvaluateStop and (tradeLong ? low <= stopPrice : high >= stopPrice)
stopClosedBeyond = canEvaluateStop and barstate.isconfirmed and
     (tradeLong ? close < stopPrice : close > stopPrice)
stopTagged = stopCloseConfirm ? stopClosedBeyond : stopWickTouched

stopHeld = stopCloseConfirm and stopWickTouched and not stopClosedBeyond and
     (tradeLong ? close >= stopPrice : close <= stopPrice)
newStopHold = stopHeld and not stopHeld[1]

if pt1Tagged
    pt1Hit := true

if pt2Tagged
    pt2Hit := true

if pt3Tagged
    pt3Hit := true
    line.set_color(pt3Line, winnerLime)
    line.set_width(pt3Line, 4)
    box.set_bgcolor(profitBox, color.new(winnerLime, 78))
    box.set_border_color(profitBox, winnerLime)
    if not na(tradeBoxLabel)
        label.set_color(tradeBoxLabel, winnerLime)
        label.set_textcolor(tradeBoxLabel, color.black)
    tradeActive := false
    targetBoxActive := false

if newStopHold
    stopTouchCount += 1
    if showStop and not na(stopLine)
        line.set_color(stopLine, brightRed)
        line.set_width(stopLine, 3)
    if showStop and not na(riskBox)
        box.set_border_color(riskBox, brightRed)
    canPrintHold = na(lastStopHoldLabelBar) or bar_index - lastStopHoldLabelBar >= stopHoldCooldown
    if showStopHoldLabels and canPrintHold
        holdText = tradeLong ? "DEMAND HELD " + str.tostring(stopTouchCount) : "SUPPLY HELD " + str.tostring(stopTouchCount)
        label.new(
             bar_index,
             stopPrice,
             holdText,
             style=tradeLong ? label.style_label_up : label.style_label_down,
             color=tradeLong ? color.new(electricTeal, 8) : color.new(brightRed, 8),
             textcolor=color.white,
             size=size.tiny)
        lastStopHoldLabelBar := bar_index

if stopTagged
    tradeStopped := true
    if showStop and not na(stopLine)
        line.set_color(stopLine, color.red)
        line.set_width(stopLine, 3)
    if showStop and not na(riskBox)
        box.set_border_color(riskBox, color.red)
    // Stop close ends the live trade status, but the target box continues
    // to extend and monitor PT3 until PT3 is hit or this stock market
    // session ends.
    tradeActive := false

if regionTargetSessionEnded and targetBoxActive
    targetSessionExpired := true
    targetBoxActive := false
    tradeActive := false
    if not na(tradeBoxLabel)
        label.set_color(tradeBoxLabel, color.new(expiredGray, 10))
        label.set_textcolor(tradeBoxLabel, color.white)

if not na(tradeBoxLabel)
    symbolText = tradeLong ? "🐂" : "🐻"
    targetMoveNow = math.abs(pt3Price - entryPrice)
    targetPctNow = entryPrice != 0 ? targetMoveNow / entryPrice * 100.0 : na
    riskNow = math.abs(entryPrice - stopPrice)
    rrNow = riskNow > 0 ? targetMoveNow / riskNow : na
    targetState = pt3Hit ? "TARGET HIT ✓" :
         targetSessionExpired ? "SESSION ENDED" :
         tradeStopped and targetBoxActive ? "STOP CLOSED • TARGET TRACKING" :
         stopTouchCount > 0 ? (tradeLong ? "DEMAND HELD ×" : "SUPPLY HELD ×") + str.tostring(stopTouchCount) :
         "ACTIVE"
    label.set_text(
         tradeBoxLabel,
         symbolText + "  TARGET " + str.tostring(pt3Price, format.mintick) +
         "\n+" + str.tostring(targetMoveNow, format.mintick) +
         " (" + str.tostring(targetPctNow, "#.##") + "%)" +
         "\nR:R " + str.tostring(rrNow, "#.##") +
         "\n" + targetState)

alertcondition(pt1Tagged, "PT1 Hit", "16 OTG PT1 was reached")
alertcondition(pt2Tagged, "PT2 Hit", "16 OTG PT2 was reached")
alertcondition(pt3Tagged, "PT3 Hit", "16 OTG PT3 was reached")
alertcondition(newStopHold, "Stop Held", "16 OTG stop was touched and rejected; the trade remains active")
alertcondition(stopTagged, "Stop Hit", "16 OTG price confirmed a close beyond the stop; target tracking continues")
alertcondition(regionTargetSessionEnded and targetSessionExpired, "Target Session Ended", "16 OTG target tracking ended because the active 8-hour stock session closed")


// ═══════════════════════════════════════════
//  SECTION 6: 16 OTG LIVE STOCK PANEL
//  Uses the same confirmed ORB and GO variables that print chart signals.
// ═══════════════════════════════════════════
grpPanel = "16 OTG Panel"
showPanel = input.bool(true, "Show 16 OTG Panel", group=grpPanel)
panelBiasTF = input.timeframe("16", "Bias Timeframe", group=grpPanel)
panelPosition = input.string("Top Right", "Panel Position",
     options=["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group=grpPanel)
panelFontSize = input.string("Tiny", "Panel Font Size",
     options=["Tiny", "Small"], group=grpPanel)
panelFastLen = input.int(5, "Fast EMA", minval=1, group=grpPanel)
panelSlowLen = input.int(12, "Slow EMA", minval=2, group=grpPanel)
panelTrendFastLen = input.int(34, "Trend EMA Fast", minval=2, group=grpPanel)
panelTrendSlowLen = input.int(50, "Trend EMA Slow", minval=3, group=grpPanel)
panelRsiLen = input.int(14, "RSI Length", minval=2, group=grpPanel)
panelAdxLen = input.int(14, "ADX Length", minval=2, group=grpPanel)
panelAdxSmooth = input.int(14, "ADX Smoothing", minval=2, group=grpPanel)
panelMinAdx = input.float(20.0, "Minimum Trending ADX", minval=1, step=0.5, group=grpPanel)
panelVolLen = input.int(20, "Volume Average Length", minval=2, group=grpPanel)
useMarketFilter = input.bool(true, "Use Market ETF Confirmation", group=grpPanel)
marketSymbol = input.symbol("AMEX:SPY", "Market ETF", group=grpPanel)

panelTextSize = panelFontSize == "Small" ? size.small : size.tiny

panelPos = switch panelPosition
    "Top Left" => position.top_left
    "Top Center" => position.top_center
    "Middle Right" => position.middle_right
    "Middle Left" => position.middle_left
    "Bottom Right" => position.bottom_right
    "Bottom Center" => position.bottom_center
    "Bottom Left" => position.bottom_left
    => position.top_right

f_panelData() =>
    _emaFast = ta.ema(close, panelFastLen)
    _emaSlow = ta.ema(close, panelSlowLen)
    _trendFast = ta.ema(close, panelTrendFastLen)
    _trendSlow = ta.ema(close, panelTrendSlowLen)
    _rsi = ta.rsi(close, panelRsiLen)
    [_plusDI, _minusDI, _adx] = ta.dmi(panelAdxLen, panelAdxSmooth)
    _volAvg = ta.sma(volume, panelVolLen)
    [close[1], _emaFast[1], _emaSlow[1], _trendFast[1], _trendSlow[1],
     _rsi[1], _plusDI[1], _minusDI[1], _adx[1], volume[1], _volAvg[1], ta.atr(14)[1]]

[pSignalClose, pSignalFast, pSignalSlow, pSignalTrendFast, pSignalTrendSlow,
 pSignalRsi, pSignalPlusDI, pSignalMinusDI, pSignalAdx, pSignalVolume,
 pSignalVolAvg, pSignalAtr] =
     request.security(syminfo.tickerid, sigTF, f_panelData(), lookahead=barmerge.lookahead_on)

[pBiasClose, pBiasFast, pBiasSlow, pBiasTrendFast, pBiasTrendSlow,
 pBiasRsi, pBiasPlusDI, pBiasMinusDI, pBiasAdx, pBiasVolume,
 pBiasVolAvg, pBiasAtr] =
     request.security(syminfo.tickerid, panelBiasTF, f_panelData(), lookahead=barmerge.lookahead_on)

marketClose = request.security(marketSymbol, panelBiasTF, close[1], lookahead=barmerge.lookahead_on)
marketFast = request.security(marketSymbol, panelBiasTF, ta.ema(close, panelFastLen)[1], lookahead=barmerge.lookahead_on)
marketSlow = request.security(marketSymbol, panelBiasTF, ta.ema(close, panelSlowLen)[1], lookahead=barmerge.lookahead_on)
marketBull = marketClose > marketFast and marketFast > marketSlow
marketBear = marketClose < marketFast and marketFast < marketSlow
marketText = not useMarketFilter ? "OFF" : marketBull ? "ETF 🐂" : marketBear ? "ETF 🐻" : "ETF MIXED"
marketColor = not useMarketFilter ? expiredGray : marketBull ? electricTeal : marketBear ? brightRed : color.orange

biasBull = pBiasClose > pBiasTrendFast and pBiasTrendFast > pBiasTrendSlow and pBiasFast > pBiasSlow
biasBear = pBiasClose < pBiasTrendFast and pBiasTrendFast < pBiasTrendSlow and pBiasFast < pBiasSlow
triggerBull = pSignalClose > pSignalFast and pSignalFast > pSignalSlow and pSignalRsi >= 52 and pSignalPlusDI > pSignalMinusDI
triggerBear = pSignalClose < pSignalFast and pSignalFast < pSignalSlow and pSignalRsi <= 48 and pSignalMinusDI > pSignalPlusDI

var int panelLastSignalDir = 0
var string panelLastSignalRegion = "NONE"
if newDay
    panelLastSignalDir := 0
    panelLastSignalRegion := "NONE"
if confLong
    panelLastSignalDir := 1
    panelLastSignalRegion := sessionPreset
if confShort
    panelLastSignalDir := -1
    panelLastSignalRegion := sessionPreset

chartSignalDir = confLong ? 1 : confShort ? -1 : panelLastSignalDir
chartSignalText = chartSignalDir == 1 ? panelLastSignalRegion + " 🐂 GO" :
     chartSignalDir == -1 ? panelLastSignalRegion + " 🐻 GO" : "NO GO SIGNAL"
chartSignalColor = chartSignalDir == 1 ? color.green : chartSignalDir == -1 ? color.red : color.gray

biasText = biasBull ? "🐂" : biasBear ? "🐻" : "NEUTRAL"
biasColor = biasBull ? color.green : biasBear ? color.red : color.gray

panelCloudBull = mashort1 >= malong1 and mashort3 >= malong3
panelCloudBear = mashort1 < malong1 and mashort3 < malong3
panelCloudText = panelCloudBull ? "🐂" : panelCloudBear ? "🐻" : "MIXED"
panelCloudColor = panelCloudBull ? color.green : panelCloudBear ? color.red : color.orange

orbLocationText = not rangeDone ? "NOT READY" :
     pSignalClose > orbHigh ? "ABOVE ORB" :
     pSignalClose < orbLow ? "BELOW ORB" : "INSIDE ORB"
orbLocationColor = not rangeDone ? color.gray :
     pSignalClose > orbHigh ? color.green :
     pSignalClose < orbLow ? color.red : color.orange

orbRange = rangeDone ? orbHigh - orbLow : na
orbRangeAtr = rangeDone and not na(pBiasAtr) and pBiasAtr > 0 ? orbRange / pBiasAtr : na
orbSizeText = na(orbRangeAtr) ? "N/A" : str.tostring(orbRangeAtr, "#.00") + " ATR"
orbSizeColor = na(orbRangeAtr) ? color.gray :
     orbRangeAtr <= 0.35 ? color.green :
     orbRangeAtr <= 0.65 ? color.orange : color.red

panelVolRatio = not na(pSignalVolAvg) and pSignalVolAvg > 0 ? pSignalVolume / pSignalVolAvg : na
volumeTextPanel = na(panelVolRatio) ? "N/A" : str.tostring(panelVolRatio, "#.00") + "x"
volumeColorPanel = na(panelVolRatio) ? color.gray :
     panelVolRatio >= 1.25 ? color.green :
     panelVolRatio >= 0.85 ? color.orange : color.gray

panelTrendStrong = pSignalAdx >= panelMinAdx
momentumText = "RSI " + str.tostring(pSignalRsi, "#.0") + " | ADX " + str.tostring(pSignalAdx, "#.0")
momentumColor = panelTrendStrong ? (triggerBull ? color.green : triggerBear ? color.red : color.blue) : color.orange

rsiMomentumText = pSignalRsi >= 60 ? "STRONG 🐂 " + str.tostring(pSignalRsi, "#.0") :
     pSignalRsi >= 52 ? "🐂 " + str.tostring(pSignalRsi, "#.0") :
     pSignalRsi <= 40 ? "STRONG 🐻 " + str.tostring(pSignalRsi, "#.0") :
     pSignalRsi <= 48 ? "🐻 " + str.tostring(pSignalRsi, "#.0") :
     "NEUTRAL " + str.tostring(pSignalRsi, "#.0")
rsiMomentumColor = pSignalRsi >= 52 ? electricTeal :
     pSignalRsi <= 48 ? brightRed : color.orange

alignmentText = chartSignalDir == 1 ? (biasBull ? "🐂 ALIGNED" : biasBear ? "🐂 CONFLICT" : "🐂 NEUTRAL") :
     chartSignalDir == -1 ? (biasBear ? "🐻 ALIGNED" : biasBull ? "🐻 CONFLICT" : "🐻 NEUTRAL") : "NO SIGNAL"
alignmentColor = chartSignalDir == 1 and biasBull ? color.green :
     chartSignalDir == -1 and biasBear ? color.red :
     chartSignalDir == 0 ? color.gray : color.orange

tradeStatusText = pt3Hit ? "PT3 HIT" :
     targetSessionExpired ? "SESSION ENDED" :
     tradeStopped and targetBoxActive ? "STOP CLOSED • PT ACTIVE" :
     tradeActive ?
     (stopTouchCount > 0 ? (tradeLong ? "DEMAND HELD ×" : "SUPPLY HELD ×") + str.tostring(stopTouchCount) :
      (tradeLong ? "🐂 ACTIVE" : "🐻 ACTIVE")) :
     tradeStopped ? "STOP CLOSED" :
     pt2Hit ? "PT2 HIT" :
     pt1Hit ? "PT1 HIT" : "FLAT"
tradeStatusColor = pt3Hit ? winnerLime :
     targetSessionExpired ? expiredGray :
     tradeStopped and targetBoxActive ? color.orange :
     tradeActive ?
     (stopTouchCount > 0 ? (tradeLong ? electricTeal : brightRed) : (tradeLong ? electricTeal : brightRed)) :
     tradeStopped ? brightRed :
     pt2Hit or pt1Hit ? color.green : color.gray

mainTargetText = not na(pt3Price) ? str.tostring(pt3Price, format.mintick) + (pt3Hit ? " ✓" : "") : "—"
targetColor = targetBoxActive ? color.new(electricTeal, 10) : pt3Hit ? winnerLime : expiredGray

sessionText = inSession ? sessionPreset + " ORB BUILD" :
     rangeDone ? sessionPreset + " ORB READY" :
     inRegionTargetSession ? "RTH ACTIVE" : "MARKET CLOSED"
sessionColor = inSession ? color.orange : rangeDone ? color.green : color.gray

scoreDirection = chartSignalDir != 0 ? 1 : 0
scoreCloud = (chartSignalDir == 1 and panelCloudBull) or (chartSignalDir == -1 and panelCloudBear) ? 1 : 0
scoreOrb = (chartSignalDir == 1 and pSignalClose > orbHigh) or (chartSignalDir == -1 and pSignalClose < orbLow) ? 1 : 0
scoreVolume = not na(panelVolRatio) and panelVolRatio >= 1.0 ? 1 : 0
scoreAdx = panelTrendStrong ? 1 : 0
scoreRsi = (chartSignalDir == 1 and pSignalRsi >= 55) or (chartSignalDir == -1 and pSignalRsi <= 45) ? 1 : 0
scoreMarket = not useMarketFilter or (chartSignalDir == 1 and marketBull) or (chartSignalDir == -1 and marketBear) ? 1 : 0
setupScore = scoreDirection + scoreCloud + scoreOrb + scoreVolume + scoreAdx + scoreRsi + scoreMarket
setupGrade = setupScore == 7 ? "A+ 7/7" :
     setupScore == 6 ? "A 6/7" :
     setupScore == 5 ? "B 5/7" :
     setupScore == 4 ? "C 4/7" : "WAIT " + str.tostring(setupScore) + "/7"
setupColor = setupScore >= 6 ? winnerLime : setupScore >= 4 ? color.orange : expiredGray

var table cryptoDash = table.new(panelPos, 2, 11, border_width=1,
     frame_color=color.new(color.gray, 65), border_color=color.new(color.gray, 82))

if barstate.islast
    if showPanel
        table.cell(cryptoDash, 0, 0, "16 OTG", text_color=color.white, bgcolor=color.new(electricPurple, 5), text_size=panelTextSize)
        table.cell(cryptoDash, 1, 0, syminfo.ticker, text_color=color.white, bgcolor=color.new(electricPurple, 5), text_size=panelTextSize)

        table.cell(cryptoDash, 0, 1, "SESSION", text_color=color.white, bgcolor=color.new(panelBlack, 0), text_size=panelTextSize)
        table.cell(cryptoDash, 1, 1, sessionText, text_color=color.white, bgcolor=sessionColor, text_size=panelTextSize)

        table.cell(cryptoDash, 0, 2, "BIAS", text_color=color.white, bgcolor=color.new(panelBlack, 0), text_size=panelTextSize)
        table.cell(cryptoDash, 1, 2, biasText, text_color=color.white, bgcolor=biasColor, text_size=panelTextSize)

        table.cell(cryptoDash, 0, 3, "SIGNAL", text_color=color.white, bgcolor=color.new(panelBlack, 0), text_size=panelTextSize)
        table.cell(cryptoDash, 1, 3, chartSignalText, text_color=color.white, bgcolor=chartSignalColor, text_size=panelTextSize)

        table.cell(cryptoDash, 0, 4, "CLOUDS", text_color=color.white, bgcolor=color.new(panelBlack, 0), text_size=panelTextSize)
        table.cell(cryptoDash, 1, 4, panelCloudText, text_color=color.white, bgcolor=panelCloudColor, text_size=panelTextSize)

        table.cell(cryptoDash, 0, 5, "S/D LOCATION", text_color=color.white, bgcolor=color.new(panelBlack, 0), text_size=panelTextSize)
        table.cell(cryptoDash, 1, 5, zoneStatusText, text_color=color.white, bgcolor=zoneStatusColor, text_size=panelTextSize)

        table.cell(cryptoDash, 0, 6, "RSI MOMENTUM", text_color=color.white, bgcolor=color.new(panelBlack, 0), text_size=panelTextSize)
        table.cell(cryptoDash, 1, 6, rsiMomentumText, text_color=color.white, bgcolor=rsiMomentumColor, text_size=panelTextSize)

        table.cell(cryptoDash, 0, 7, "MARKET", text_color=color.white, bgcolor=color.new(panelBlack, 0), text_size=panelTextSize)
        table.cell(cryptoDash, 1, 7, marketText, text_color=color.white, bgcolor=marketColor, text_size=panelTextSize)

        table.cell(cryptoDash, 0, 8, "TARGET", text_color=color.white, bgcolor=color.new(panelBlack, 0), text_size=panelTextSize)
        table.cell(cryptoDash, 1, 8, mainTargetText, text_color=color.white, bgcolor=targetColor, text_size=panelTextSize)

        table.cell(cryptoDash, 0, 9, "STATUS", text_color=color.white, bgcolor=color.new(panelBlack, 0), text_size=panelTextSize)
        table.cell(cryptoDash, 1, 9, tradeStatusText, text_color=color.white, bgcolor=tradeStatusColor, text_size=panelTextSize)

        table.cell(cryptoDash, 0, 10, "GRADE", text_color=color.white, bgcolor=color.new(panelBlack, 0), text_size=panelTextSize)
        table.cell(cryptoDash, 1, 10, setupGrade, text_color=color.white, bgcolor=setupColor, text_size=panelTextSize)
    else
        table.clear(cryptoDash, 0, 0, 1, 10)


plot(close)
````
