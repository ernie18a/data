# Multi-Timeframe Liquidity Range

- url: https://www.tradingview.com/script/oOv8W04o-Multi-Timeframe-Liquidity-Range/
- type: indicator
- pine_id: PUB;dc65ccbc32fb425489f8a4b14a24247e
- version: 2.0

## Description

Multi-Timeframe Liquidity Range helps to detect the liquidity zone with high probability to be touched.

## Source Code

````pine
//@version=6
indicator("Multi-Timeframe Liquidity Range", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

//#region inputs
showD = input.bool(true, "Show D")
show4H = input.bool(true, "Show 4H")
show1H = input.bool(true, "Show 1H")
show15m = input.bool(true, "Show 15m")
show5m = input.bool(true, "Show 5m")
showSummaryTable = input.bool(true, "Show Summary Table")
pivotLookback = input.int(3, "Pivot Lookback", minval=1)
liquidityExtensionPct = input.float(0.003, "Liquidity Extension %", step=0.001)
//#endregion

//#region constants
DARK_BLUE = color.rgb(0, 70, 140)
PURPLE    = color.rgb(120, 40, 180)
ORANGE    = color.rgb(220, 120, 20)
GREEN     = color.rgb(20, 150, 70)
GRAY      = color.rgb(100, 100, 100)
SUMMARY_BG = color.new(color.black, 0)
SUMMARY_TEXT = color.white
//#endregion

//@function Returns the color for a given timeframe.
getTfColor(tf) =>
    switch tf
        "D"   => DARK_BLUE
        "4H"  => PURPLE
        "1H"  => ORANGE
        "15m" => GREEN
        "5m"  => GRAY
        => GRAY

//#region storage
var array<box> zones = array.new<box>()
var array<label> zoneLabels = array.new<label>()
var array<float> zoneDistances = array.new<float>()
var array<string> zoneTimeframes = array.new<string>()
var array<string> zoneDirections = array.new<string>()
var array<color> zoneColors = array.new<color>()
var array<float> zoneTops = array.new<float>()
var array<float> zoneBottoms = array.new<float>()
var array<int> zoneTimestamps = array.new<int>()
var label closestLabel = na
var table summaryTable = table.new(position.top_right, 3, 6, border_width=1)
//#endregion

//#region functions
//@function Creates and stores a liquidity zone.
//@param tf Timeframe label.
//@param dir Zone direction label.
//@param leftTs Zone left timestamp.
//@param top Zone top price.
//@param bottom Zone bottom price.
//@param zoneColor Zone color.
//@returns None.
createZone(string tf, string dir, int leftTs, float top, float bottom, color zoneColor) =>
    b = box.new(leftTs, top, leftTs, bottom, xloc=xloc.bar_time, bgcolor=color.new(zoneColor, 90), border_color=zoneColor, border_width=2, extend=extend.both)
    lbl = label.new(leftTs, top, tf + " " + dir, xloc=xloc.bar_time, style=label.style_label_left, textcolor=color.white, color=zoneColor, size=size.small)
    array.push(zones, b)
    array.push(zoneLabels, lbl)
    array.push(zoneTimeframes, tf)
    array.push(zoneDirections, dir)
    array.push(zoneColors, zoneColor)
    array.push(zoneTops, top)
    array.push(zoneBottoms, bottom)
    array.push(zoneTimestamps, leftTs)
    midpoint = (top + bottom) / 2.0
    distPct = math.abs(close - midpoint) / close * 100.0
    array.push(zoneDistances, distPct)
//#endregion

//#region cleanup
if barstate.isfirst
    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            box.delete(array.get(zones, i))
            label.delete(array.get(zoneLabels, i))
    array.clear(zones)
    array.clear(zoneLabels)
    array.clear(zoneDistances)
    array.clear(zoneTimeframes)
    array.clear(zoneDirections)
    array.clear(zoneColors)
    array.clear(zoneTops)
    array.clear(zoneBottoms)
    array.clear(zoneTimestamps)
//#endregion

//#region MTF pivot detection
rawDph = request.security(syminfo.tickerid, "D", ta.pivothigh(high, pivotLookback, pivotLookback), lookahead=barmerge.lookahead_on, gaps=barmerge.gaps_off)
rawDpl = request.security(syminfo.tickerid, "D", ta.pivotlow(low, pivotLookback, pivotLookback), lookahead=barmerge.lookahead_on, gaps=barmerge.gaps_off)
raw4Hph = request.security(syminfo.tickerid, "240", ta.pivothigh(high, pivotLookback, pivotLookback), lookahead=barmerge.lookahead_on, gaps=barmerge.gaps_off)
raw4Hpl = request.security(syminfo.tickerid, "240", ta.pivotlow(low, pivotLookback, pivotLookback), lookahead=barmerge.lookahead_on, gaps=barmerge.gaps_off)
raw1Hph = request.security(syminfo.tickerid, "60", ta.pivothigh(high, pivotLookback, pivotLookback), lookahead=barmerge.lookahead_on, gaps=barmerge.gaps_off)
raw1Hpl = request.security(syminfo.tickerid, "60", ta.pivotlow(low, pivotLookback, pivotLookback), lookahead=barmerge.lookahead_on, gaps=barmerge.gaps_off)
raw15mph = request.security(syminfo.tickerid, "15", ta.pivothigh(high, pivotLookback, pivotLookback), lookahead=barmerge.lookahead_on, gaps=barmerge.gaps_off)
raw15mpl = request.security(syminfo.tickerid, "15", ta.pivotlow(low, pivotLookback, pivotLookback), lookahead=barmerge.lookahead_on, gaps=barmerge.gaps_off)
raw5mph = request.security(syminfo.tickerid, "5", ta.pivothigh(high, pivotLookback, pivotLookback), lookahead=barmerge.lookahead_on, gaps=barmerge.gaps_off)
raw5mpl = request.security(syminfo.tickerid, "5", ta.pivotlow(low, pivotLookback, pivotLookback), lookahead=barmerge.lookahead_on, gaps=barmerge.gaps_off)

// Forward-fill
var float dph = float(na), dpl = float(na), h4ph = float(na), h4pl = float(na)
var float h1ph = float(na), h1pl = float(na), m15ph = float(na), m15pl = float(na)
var float m5ph = float(na), m5pl = float(na)
dph := nz(rawDph, dph)
dpl := nz(rawDpl, dpl)
h4ph := nz(raw4Hph, h4ph)
h4pl := nz(raw4Hpl, h4pl)
h1ph := nz(raw1Hph, h1ph)
h1pl := nz(raw1Hpl, h1pl)
m15ph := nz(raw15mph, m15ph)
m15pl := nz(raw15mpl, m15pl)
m5ph := nz(raw5mph, m5ph)
m5pl := nz(raw5mpl, m5pl)

if showD and dph != dph[1] and not na(dph)
    bslTop = dph * (1.0 + liquidityExtensionPct)
    createZone("D", "BSL", time, bslTop, dph, getTfColor("D"))
if showD and dpl != dpl[1] and not na(dpl)
    sslBottom = dpl * (1.0 - liquidityExtensionPct)
    createZone("D", "SSL", time, dpl, sslBottom, getTfColor("D"))

if show4H and h4ph != h4ph[1] and not na(h4ph)
    bslTop = h4ph * (1.0 + liquidityExtensionPct)
    createZone("4H", "BSL", time, bslTop, h4ph, getTfColor("4H"))
if show4H and h4pl != h4pl[1] and not na(h4pl)
    sslBottom = h4pl * (1.0 - liquidityExtensionPct)
    createZone("4H", "SSL", time, h4pl, sslBottom, getTfColor("4H"))

if show1H and h1ph != h1ph[1] and not na(h1ph)
    bslTop = h1ph * (1.0 + liquidityExtensionPct)
    createZone("1H", "BSL", time, bslTop, h1ph, getTfColor("1H"))
if show1H and h1pl != h1pl[1] and not na(h1pl)
    sslBottom = h1pl * (1.0 - liquidityExtensionPct)
    createZone("1H", "SSL", time, h1pl, sslBottom, getTfColor("1H"))

if show15m and m15ph != m15ph[1] and not na(m15ph)
    bslTop = m15ph * (1.0 + liquidityExtensionPct)
    createZone("15m", "BSL", time, bslTop, m15ph, getTfColor("15m"))
if show15m and m15pl != m15pl[1] and not na(m15pl)
    sslBottom = m15pl * (1.0 - liquidityExtensionPct)
    createZone("15m", "SSL", time, m15pl, sslBottom, getTfColor("15m"))

if show5m and m5ph != m5ph[1] and not na(m5ph)
    bslTop = m5ph * (1.0 + liquidityExtensionPct)
    createZone("5m", "BSL", time, bslTop, m5ph, getTfColor("5m"))
if show5m and m5pl != m5pl[1] and not na(m5pl)
    sslBottom = m5pl * (1.0 - liquidityExtensionPct)
    createZone("5m", "SSL", time, m5pl, sslBottom, getTfColor("5m"))
//#endregion

//#region closest zone
float closestDistance = na
int closestIndex = na
if array.size(zoneDistances) > 0
    for i = 0 to array.size(zoneDistances) - 1
        dist = array.get(zoneDistances, i)
        if na(closestDistance) or dist < closestDistance
            closestDistance := dist
            closestIndex := i

if barstate.islast and not na(closestIndex)
    cTf = array.get(zoneTimeframes, closestIndex)
    cDir = array.get(zoneDirections, closestIndex)
    cColor = array.get(zoneColors, closestIndex)
    cDist = array.get(zoneDistances, closestIndex)
    if not na(closestLabel)
        label.delete(closestLabel)
    closestLabel := label.new(time, close, "★ CLOSEST LIQ: " + cTf + " " + cDir + " (" + str.tostring(cDist, "0.00") + "% away)", xloc=xloc.bar_time, style=label.style_label_down, textcolor=color.white, color=cColor, size=size.normal)
//#endregion

//#region summary table
if barstate.islast and showSummaryTable
    summaryTable.cell(0, 0, "TF", bgcolor=SUMMARY_BG, text_color=SUMMARY_TEXT)
    summaryTable.cell(1, 0, "Dir", bgcolor=SUMMARY_BG, text_color=SUMMARY_TEXT)
    summaryTable.cell(2, 0, "Dist", bgcolor=SUMMARY_BG, text_color=SUMMARY_TEXT)
    tfs = array.from("D", "4H", "1H", "15m", "5m")
    row = 1
    for tfName in tfs
        bestDir = "-"
        float bestDist = na
        if array.size(zoneTimeframes) > 0
            for i = 0 to array.size(zoneTimeframes) - 1
                if array.get(zoneTimeframes, i) == tfName
                    top = array.get(zoneTops, i)
                    dist = math.abs(close - top)
                    if na(bestDist) or dist < bestDist
                        bestDist := dist
                        bestDir := array.get(zoneDirections, i)
        summaryTable.cell(0, row, tfName)
        summaryTable.cell(1, row, bestDir)
        summaryTable.cell(2, row, na(bestDist) ? "-" : str.tostring(bestDist, format.mintick))
        row += 1
//#endregion
````
