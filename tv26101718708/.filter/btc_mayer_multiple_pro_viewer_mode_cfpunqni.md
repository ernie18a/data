# BTC Mayer Multiple Pro - Viewer Mode

- url: https://www.tradingview.com/script/cFpUnqni-BTC-Mayer-Multiple-Pro-Viewer-Mode/
- type: indicator
- pine_id: PUB;86f2dfacc3a44d7293b7c5ff50d7525c
- version: 1.0

## Description

This idea has always found the bottoms and tops for bitcoin.  The table will adjust as price moves up or down.  It provides fair value avg, projected bottom, and projected top based on overheated or oversold conditions.

## Source Code

````pine
//@version=6
indicator("BTC Mayer Multiple Pro - Viewer Mode", shorttitle="MayerPro", overlay=false, scale=scale.right, precision=3, max_labels_count=300)

//====================================================
// INPUTS
//====================================================

useChartSymbol = input.bool(false, "Use chart symbol instead of BTC source?")
btcSymbol      = input.symbol("BNC:BLX", "BTC Long-History Source")
calcTf         = input.timeframe("D", "Calculation Timeframe")
maLen          = input.int(365, "Mayer MA Length", minval=50)

viewMode       = input.string("Clean Viewer", "Mode", options=["Clean Viewer", "Full Research"])
showZones      = input.bool(true, "Show Valuation Zones")
showDashboard  = input.bool(true, "Show Dashboard")
showMarkers    = input.bool(true, "Show Major Markers")
showLabels     = input.bool(true, "Show Historical Event Labels")
showCurrent    = input.bool(true, "Show Current Status Label")

deepLevel      = input.float(0.50, "Deep Value Level", step=0.05)
accumLevel     = input.float(0.80, "Accumulation Level", step=0.05)
fairLevel      = input.float(1.20, "Fair Value / Expansion Level", step=0.05)
hotLevel       = input.float(2.40, "Overheated Level", step=0.10)
extremeLevel   = input.float(3.50, "Extreme Overheated Level", step=0.10)
visualCeiling  = input.float(8.00, "Zone Visual Ceiling", step=0.50)

showDcaLines   = input.bool(true, "Show DCA Ladder Lines")
showHotLines   = input.bool(true, "Show Overheated Lines")

//====================================================
// BTC DAILY DATA
//====================================================

calcSymbol = useChartSymbol ? syminfo.tickerid : btcSymbol

[dClose, dMa365] = request.security(calcSymbol, calcTf, [close, ta.sma(close, maLen)], barmerge.gaps_off, barmerge.lookahead_off)

mayer = dMa365 > 0.0 ? dClose / dMa365 : na

deepPrice    = dMa365 * deepLevel
accumPrice   = dMa365 * accumLevel
fairPrice    = dMa365 * fairLevel
hotPrice     = dMa365 * hotLevel
extremePrice = dMa365 * extremeLevel

//====================================================
// ZONE LOGIC
//====================================================

cleanMode = viewMode == "Clean Viewer"
fullMode  = viewMode == "Full Research"

isDeep    = mayer <= deepLevel
isAccum   = mayer > deepLevel and mayer <= accumLevel
isFair    = mayer > accumLevel and mayer <= fairLevel
isBull    = mayer > fairLevel and mayer < hotLevel
isHot     = mayer >= hotLevel and mayer < extremeLevel
isExtreme = mayer >= extremeLevel

prevMayer = nz(mayer[1], mayer)

deepEnter    = mayer <= deepLevel and prevMayer > deepLevel
deepExit     = mayer > deepLevel and prevMayer <= deepLevel
accumEnter   = mayer <= accumLevel and prevMayer > accumLevel and mayer > deepLevel
accumExit    = mayer > accumLevel and prevMayer <= accumLevel
bullEnter    = mayer > fairLevel and prevMayer <= fairLevel
hotEnter     = mayer >= hotLevel and prevMayer < hotLevel
extremeEnter = mayer >= extremeLevel and prevMayer < extremeLevel
hotExit      = mayer < hotLevel and prevMayer >= hotLevel

zoneScore = isDeep ? 1 : isAccum ? 2 : isFair ? 3 : isBull ? 4 : isHot ? 5 : isExtreme ? 6 : 0
zoneChanged = zoneScore != nz(zoneScore[1], zoneScore)

//====================================================
// COLORS
//====================================================

deepColor    = color.rgb(0, 180, 90)
accumColor   = color.rgb(40, 150, 90)
fairColor    = color.rgb(75, 90, 120)
bullColor    = color.rgb(220, 160, 30)
hotColor     = color.rgb(210, 65, 65)
extremeColor = color.rgb(165, 35, 35)

lineColor    = color.rgb(50, 125, 255)
neutralText  = color.white
darkBg       = color.rgb(20, 22, 28)

//====================================================
// VALUATION ZONE BACKDROPS
//====================================================

hZero    = hline(0.00, "Zero", color=color.new(color.gray, 100))
hDeep    = hline(deepLevel, "0.50 Deep Value", color=showDcaLines ? color.new(deepColor, 0) : color.new(deepColor, 100), linestyle=hline.style_solid)
hAccum   = hline(accumLevel, "0.80 Accumulation", color=showDcaLines ? color.new(accumColor, 0) : color.new(accumColor, 100), linestyle=hline.style_dashed)
hFair    = hline(fairLevel, "1.20 Fair / Expansion", color=color.new(fairColor, 20), linestyle=hline.style_dotted)
hHot     = hline(hotLevel, "2.40 Overheated", color=showHotLines ? color.new(hotColor, 0) : color.new(hotColor, 100), linestyle=hline.style_solid)
hExtreme = hline(extremeLevel, "3.50 Extreme Heat", color=showHotLines ? color.new(extremeColor, 0) : color.new(extremeColor, 100), linestyle=hline.style_dashed)
hCeil    = hline(visualCeiling, "Visual Ceiling", color=color.new(color.gray, 100))

fill(hZero, hDeep, color=showZones ? color.new(deepColor, 85) : color.new(deepColor, 100), title="Deep Value Zone")
fill(hDeep, hAccum, color=showZones ? color.new(accumColor, 88) : color.new(accumColor, 100), title="Accumulation Zone")
fill(hAccum, hFair, color=showZones ? color.new(fairColor, 91) : color.new(fairColor, 100), title="Fair Value Zone")
fill(hFair, hHot, color=showZones ? color.new(bullColor, 91) : color.new(bullColor, 100), title="Bull Expansion Zone")
fill(hHot, hExtreme, color=showZones ? color.new(hotColor, 88) : color.new(hotColor, 100), title="Overheated Zone")
fill(hExtreme, hCeil, color=showZones ? color.new(extremeColor, 85) : color.new(extremeColor, 100), title="Extreme Heat Zone")

//====================================================
// MAIN PLOT
//====================================================

plot(mayer, "Mayer Multiple", color=lineColor, linewidth=2)

//====================================================
// MARKERS
//====================================================

plotshape(showMarkers and deepEnter ? mayer : na, title="Deep Value Entry", style=shape.triangleup, location=location.absolute, color=deepColor, size=size.small)
plotshape(showMarkers and accumEnter and fullMode ? mayer : na, title="Accumulation Entry", style=shape.circle, location=location.absolute, color=accumColor, size=size.tiny)
plotshape(showMarkers and hotEnter ? mayer : na, title="Overheated Entry", style=shape.triangledown, location=location.absolute, color=hotColor, size=size.small)
plotshape(showMarkers and extremeEnter ? mayer : na, title="Extreme Overheated Entry", style=shape.triangledown, location=location.absolute, color=extremeColor, size=size.normal)

//====================================================
// HISTORICAL LABELS
//====================================================

if showLabels and deepEnter
    label.new(bar_index, mayer, "DEEP VALUE\n" + str.tostring(year(time)), style=label.style_label_up, color=color.new(deepColor, 0), textcolor=color.white, size=size.small)

if showLabels and hotEnter
    label.new(bar_index, mayer, "HOT\n" + str.tostring(year(time)), style=label.style_label_down, color=color.new(hotColor, 0), textcolor=color.white, size=size.small)

if showLabels and fullMode and accumEnter
    label.new(bar_index, mayer, "ACCUM\n" + str.tostring(year(time)), style=label.style_label_up, color=color.new(accumColor, 10), textcolor=color.white, size=size.tiny)

if showLabels and fullMode and extremeEnter
    label.new(bar_index, mayer, "EXTREME\n" + str.tostring(year(time)), style=label.style_label_down, color=color.new(extremeColor, 0), textcolor=color.white, size=size.small)

//====================================================
// ZONE FUNCTIONS
//====================================================

f_zoneName(_m) =>
    _m <= deepLevel ? "Deep Value" : _m <= accumLevel ? "Accumulation" : _m <= fairLevel ? "Fair Value" : _m < hotLevel ? "Bull Expansion" : _m < extremeLevel ? "Overheated" : "Extreme Heat"

f_zoneColor(_m) =>
    _m <= deepLevel ? deepColor : _m <= accumLevel ? accumColor : _m <= fairLevel ? fairColor : _m < hotLevel ? bullColor : _m < extremeLevel ? hotColor : extremeColor

f_fmt(_v) =>
    na(_v) ? "na" : str.tostring(_v, "#.##")

f_fmt3(_v) =>
    na(_v) ? "na" : str.tostring(_v, "#.###")

//====================================================
// CURRENT STATUS LABEL
//====================================================

var label currentLabel = na

if barstate.islast and showCurrent
    label.delete(currentLabel)
    currentText = "Mayer: " + f_fmt3(mayer) + "\nZone: " + f_zoneName(mayer) + "\n0.5 Buy Level: $" + f_fmt(deepPrice) + "\nMacro tool, not short-term timing."
    currentLabel := label.new(bar_index + 5, mayer, currentText, style=label.style_label_left, color=color.new(f_zoneColor(mayer), 0), textcolor=color.white, size=size.small)

//====================================================
// DASHBOARD TABLE
//====================================================

var table dash = table.new(position.top_right, 2, 9, border_width=1)

if barstate.islast and showDashboard
    zName = f_zoneName(mayer)
    zCol = f_zoneColor(mayer)

    table.cell(dash, 0, 0, "BTC Mayer Dashboard", text_color=color.white, bgcolor=color.rgb(35, 38, 48))
    table.cell(dash, 1, 0, viewMode, text_color=color.white, bgcolor=color.rgb(35, 38, 48))

    table.cell(dash, 0, 1, "Source", text_color=color.white, bgcolor=darkBg)
    table.cell(dash, 1, 1, calcSymbol, text_color=color.white, bgcolor=darkBg)

    table.cell(dash, 0, 2, "BTC Price", text_color=color.white, bgcolor=darkBg)
    table.cell(dash, 1, 2, "$" + f_fmt(dClose), text_color=color.white, bgcolor=darkBg)

    table.cell(dash, 0, 3, "365D MA", text_color=color.white, bgcolor=darkBg)
    table.cell(dash, 1, 3, "$" + f_fmt(dMa365), text_color=color.white, bgcolor=darkBg)

    table.cell(dash, 0, 4, "Mayer Multiple", text_color=color.white, bgcolor=darkBg)
    table.cell(dash, 1, 4, f_fmt3(mayer), text_color=color.white, bgcolor=zCol)

    table.cell(dash, 0, 5, "Current Zone", text_color=color.white, bgcolor=darkBg)
    table.cell(dash, 1, 5, zName, text_color=color.white, bgcolor=zCol)

    table.cell(dash, 0, 6, "0.5 Deep Buy", text_color=color.white, bgcolor=color.new(deepColor, 20))
    table.cell(dash, 1, 6, "$" + f_fmt(deepPrice), text_color=color.white, bgcolor=color.new(deepColor, 20))

    table.cell(dash, 0, 7, "0.8 Accumulation", text_color=color.white, bgcolor=color.new(accumColor, 25))
    table.cell(dash, 1, 7, "$" + f_fmt(accumPrice), text_color=color.white, bgcolor=color.new(accumColor, 25))

    table.cell(dash, 0, 8, "2.4 Overheated", text_color=color.white, bgcolor=color.new(hotColor, 20))
    table.cell(dash, 1, 8, "$" + f_fmt(hotPrice), text_color=color.white, bgcolor=color.new(hotColor, 20))

//====================================================
// ALERTS
//====================================================

alertcondition(deepEnter, "Mayer Deep Value Entered", "BTC Mayer Multiple entered the deep value zone at or below 0.5.")
alertcondition(accumEnter, "Mayer Accumulation Entered", "BTC Mayer Multiple entered the accumulation zone at or below 0.8.")
alertcondition(hotEnter, "Mayer Overheated Entered", "BTC Mayer Multiple entered the overheated zone at or above 2.4.")
alertcondition(extremeEnter, "Mayer Extreme Heat Entered", "BTC Mayer Multiple entered the extreme heat zone.")
alertcondition(zoneChanged, "Mayer Zone Changed", "BTC Mayer Multiple changed valuation zones.")
````
