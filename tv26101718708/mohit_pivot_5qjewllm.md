# mohit pivot

- url: https://www.tradingview.com/script/5qJEWlLm-mohit-pivot/
- type: indicator
- pine_id: PUB;900778df5486408fb99f562a8ebe3bfd
- version: 1.0

## Description

**mohit piviot — ATR Pivot Zones (Daily / Weekly / Monthly)**

This indicator plots classic Standard Pivot Points (PP, R1, R2, R3, S1, S2, S3) calculated from the previous completed Daily, Weekly, or Monthly period — selectable from the settings panel. Instead of drawing thin, single-price lines, each pivot level is expanded into a dynamic support/resistance **zone**, with the zone width driven by current ATR (Average True Range). This means the zones automatically widen in high-volatility conditions and tighten in low-volatility conditions, rather than staying a fixed distance from price regardless of how the market is behaving.

All levels are non-repainting — they're calculated only from confirmed, completed higher-timeframe candles, so the zones never shift or redraw after the fact. The script includes optional zone labels with live prices, a summary table (Pivot TF, ATR, zone width, and all seven levels), full color/style customization, and alerts for zone entries and PP crosses.

**How to read the zones:**
- **PP zone** (yellow) — the central pivot; acts as the line in the sand between bullish and bearish bias for the period.
- **R1 / R2 / R3 zones** (green shades) — potential resistance/take-profit areas above price; R3 marks the most extended resistance.
- **S1 / S2 / S3 zones** (red shades) — potential support/take-profit areas below price; S3 marks the most extended support.

---

**Suggested Entry Criteria**

*Long setups:*
- Price pulls back into an **S1 or S2 zone** and shows rejection (e.g., wick reversal, bullish candle close back above the zone) while the broader trend is up.
- Price breaks and closes **above the PP zone** with strength (momentum move from below), signaling a bias shift to bullish for the period.
- Price bounces off **S1 zone** with a bullish candle close back inside/above the zone after tagging it (mean-reversion long).

*Short setups:*
- Price rallies into an **R1 or R2 zone** and shows rejection (wick reversal, bearish candle close back below the zone) while the broader trend is down.
- Price breaks and closes **below the PP zone**, signaling a bias shift to bearish for the period.
- Price fails at **R1 zone** with a bearish candle close back inside/below the zone after tagging it (mean-reversion short).

**Suggested Exit Criteria**

- **Take-profit targets:** the next zone in sequence — e.g., a long from S1 targets PP, then R1, then R2; a short from R1 targets PP, then S1, then S2.
- **Stop-loss placement:** just beyond the outer boundary of the zone the trade was entered from (e.g., below S1's lower boundary for a long, above R1's upper boundary for a short) — since the zone is ATR-based, this stop naturally adapts to volatility.
- **Trend invalidation exit:** if trading with directional bias, exit longs on a confirmed close back below PP zone, or exit shorts on a confirmed close back above PP zone, since that signals the period's bias has flipped.
- **Zone-to-zone scalps:** for shorter-term trades, treat each zone boundary as its own scalp target rather than waiting for the full next level.

*Note: this description is a starting framework, not a complete trading system. Always combine pivot zone signals with broader market context, trend confirmation, and proper risk management before entering trades.*

## Source Code

````pine
//@version=6
indicator("ATR Pivot Zones (Daily / Weekly / Monthly)", shorttitle="mohit PIVOT", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// ============================================================================
// INPUTS
// ============================================================================

// ---- General ----
grpGeneral = "General"
pivotTF     = input.string("D", "Pivot Timeframe", options=["D", "W", "M"], group=grpGeneral)
showLine    = input.bool(true, "Show Pivot Line", group=grpGeneral)
showZones   = input.bool(true, "Show Zones", group=grpGeneral)
showLabels  = input.bool(true, "Show Labels", group=grpGeneral)
showPrices  = input.bool(true, "Show Prices in Labels", group=grpGeneral)
showTable   = input.bool(true, "Show Summary Table", group=grpGeneral)

grpFilter   = "Level Filter"
showOnlyPP  = input.bool(false, "Show Only PP", group=grpFilter)
showOnlySup = input.bool(false, "Show Only Supports", group=grpFilter)
showOnlyRes = input.bool(false, "Show Only Resistances", group=grpFilter)

grpExt      = "Extension / History"
extendRight = input.bool(true, "Extend Pivot Zones to the Right", group=grpExt)
showPrevZones = input.bool(false, "Display Previous Period's Zones", group=grpExt)
fillMode    = input.string("Filled Zones", "Zone Display Mode", options=["Filled Zones", "Boundary Lines Only"], group=grpExt)

// ---- ATR ----
grpATR = "ATR"
atrLen  = input.int(14, "ATR Length", minval=1, group=grpATR)
atrMult = input.float(0.15, "ATR Multiplier", minval=0.01, step=0.01, group=grpATR)

// ---- Style ----
grpStyle = "Style"
zoneTransp = input.int(85, "Zone Transparency", minval=0, maxval=100, group=grpStyle)
lineW      = input.int(1, "Line Width", minval=1, maxval=4, group=grpStyle)
lineStyleInput = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group=grpStyle)

// ---- Colors ----
grpColors = "Colors"
ppColor = input.color(color.yellow, "PP Color", group=grpColors)
r1Color = input.color(color.new(#2ecc71, 0), "R1 Color", group=grpColors)
r2Color = input.color(color.new(#1e8449, 0), "R2 Color", group=grpColors)
r3Color = input.color(color.new(#00ff00, 0), "R3 Color", group=grpColors)
s1Color = input.color(color.new(#ff0000, 0), "S1 Color", group=grpColors)
s2Color = input.color(color.new(#8b0000, 0), "S2 Color", group=grpColors)
s3Color = input.color(color.new(#800000, 0), "S3 Color", group=grpColors)

// ---- Alerts ----
grpAlerts = "Alerts"
enableZoneAlerts = input.bool(false, "Enable Zone Entry Alerts", group=grpAlerts)
enablePPCrossAlerts = input.bool(false, "Enable PP Cross Alerts", group=grpAlerts)

// ============================================================================
// LINE STYLE / EXTEND HELPERS
// ============================================================================
lineStyleResolved = lineStyleInput == "Dashed" ? line.style_dashed : lineStyleInput == "Dotted" ? line.style_dotted : line.style_solid
extendResolved     = extend.none // boxes/labels are managed manually with set_right each bar

// ============================================================================
// PREVIOUS COMPLETED PERIOD OHLC (non-repainting)
// ============================================================================
[htfHigh, htfLow, htfClose] = request.security(syminfo.tickerid, pivotTF, [high[1], low[1], close[1]], lookahead=barmerge.lookahead_off)

// ============================================================================
// PIVOT CALCULATIONS
// ============================================================================
pp = (htfHigh + htfLow + htfClose) / 3
r1 = (2 * pp) - htfLow
r2 = pp + (htfHigh - htfLow)
r3 = htfHigh + 2 * (pp - htfLow)
s1 = (2 * pp) - htfHigh
s2 = pp - (htfHigh - htfLow)
s3 = htfLow - 2 * (htfHigh - pp)

// ============================================================================
// ATR (current chart timeframe)
// ============================================================================
atrVal    = ta.atr(atrLen)
zoneWidth = atrVal * atrMult

// ============================================================================
// NEW PERIOD DETECTION
// ============================================================================
newPeriod = timeframe.change(pivotTF)

// ============================================================================
// DATA ARRAYS (7 levels: 0=PP,1=R1,2=R2,3=R3,4=S1,5=S2,6=S3)
// ============================================================================
var string[] levelNames = array.from("PP", "R1", "R2", "R3", "S1", "S2", "S3")
var color[]  levelColors = array.new<color>(7)
if barstate.isfirst
    array.set(levelColors, 0, ppColor)
    array.set(levelColors, 1, r1Color)
    array.set(levelColors, 2, r2Color)
    array.set(levelColors, 3, r3Color)
    array.set(levelColors, 4, s1Color)
    array.set(levelColors, 5, s2Color)
    array.set(levelColors, 6, s3Color)

var line[]  centerLines = array.new<line>(7)
var box[]   zoneBoxes   = array.new<box>(7)
var box[]   prevZoneBoxes = array.new<box>(7)
var label[] levelLabels = array.new<label>(7)

levelValues = array.from(pp, r1, r2, r3, s1, s2, s3)

// Visibility per level respecting filter toggles
isVisible(idx) =>
    isRes = idx == 1 or idx == 2 or idx == 3
    isSup = idx == 4 or idx == 5 or idx == 6
    isPPLvl = idx == 0
    v = true
    if showOnlyPP
        v := isPPLvl
    else if showOnlySup
        v := isSup
    else if showOnlyRes
        v := isRes
    v

// ============================================================================
// MAIN DRAWING LOGIC
// ============================================================================
if barstate.isfirst
    for i = 0 to 6
        array.set(centerLines, i, line.new(bar_index, na, bar_index, na, width=lineW, style=lineStyleResolved, extend=extend.none))
        array.set(zoneBoxes, i, box.new(bar_index, na, bar_index, na, border_color=color.new(array.get(levelColors, i), 40), bgcolor=color.new(array.get(levelColors, i), zoneTransp)))
        array.set(prevZoneBoxes, i, box.new(bar_index, na, bar_index, na, border_color=color.new(color.gray, 60), bgcolor=color.new(color.gray, 92), border_style=line.style_dashed))
        array.set(levelLabels, i, label.new(bar_index, na, "", style=label.style_label_left, color=color.new(color.black, 100), textcolor=array.get(levelColors, i)))

// On a new period: snapshot previous zones (freeze old boxes), reset for new levels
if newPeriod and not barstate.isfirst
    for i = 0 to 6
        curBox = array.get(zoneBoxes, i)
        if showPrevZones
            prevBox = array.get(prevZoneBoxes, i)
            box.set_left(prevBox, box.get_left(curBox))
            box.set_right(prevBox, bar_index - 1)
            box.set_top(prevBox, box.get_top(curBox))
            box.set_bottom(prevBox, box.get_bottom(curBox))
        box.set_left(curBox, bar_index)

// Update lines, boxes, labels every bar
rightEdge = extendRight ? bar_index + 20 : bar_index

if not na(pp)
    for i = 0 to 6
        val   = array.get(levelValues, i)
        col   = array.get(levelColors, i)
        upper = val + zoneWidth
        lower = val - zoneWidth
        vis   = isVisible(i)

        // Center line
        ln = array.get(centerLines, i)
        if showLine and vis
            line.set_xy1(ln, newPeriod ? bar_index : line.get_x1(ln), val)
            line.set_xy2(ln, rightEdge, val)
            line.set_color(ln, col)
            line.set_width(ln, lineW)
            line.set_style(ln, lineStyleResolved)
        else
            line.set_xy1(ln, bar_index, na)
            line.set_xy2(ln, bar_index, na)

        // Zone box
        bx = array.get(zoneBoxes, i)
        if showZones and vis
            box.set_top(bx, upper)
            box.set_bottom(bx, lower)
            box.set_right(bx, rightEdge)
            box.set_border_color(bx, fillMode == "Boundary Lines Only" ? color.new(col, 20) : color.new(col, 40))
            box.set_bgcolor(bx, fillMode == "Boundary Lines Only" ? color.new(col, 100) : color.new(col, zoneTransp))
            box.set_border_width(bx, 1)
        else
            box.set_top(bx, na)
            box.set_bottom(bx, na)

        // Previous period zones
        pbx = array.get(prevZoneBoxes, i)
        if not showPrevZones
            box.set_top(pbx, na)
            box.set_bottom(pbx, na)

        // Label
        lbl = array.get(levelLabels, i)
        if showLabels and vis
            labelTxt = array.get(levelNames, i) + (showPrices ? "  " + str.tostring(val, format.mintick) : "")
            label.set_xy(lbl, rightEdge, val)
            label.set_text(lbl, labelTxt)
            label.set_textcolor(lbl, col)
        else
            label.set_text(lbl, "")

// ============================================================================
// TABLE
// ============================================================================
var table infoTable = table.new(position.top_right, 2, 9, bgcolor=color.new(color.black, 70), border_color=color.gray, border_width=1)

if showTable and barstate.islast
    table.cell(infoTable, 0, 0, "Pivot TF", text_color=color.white, bgcolor=color.new(color.gray, 50))
    table.cell(infoTable, 1, 0, pivotTF == "D" ? "Daily" : pivotTF == "W" ? "Weekly" : "Monthly", text_color=color.white, bgcolor=color.new(color.gray, 50))

    table.cell(infoTable, 0, 1, "ATR", text_color=color.white)
    table.cell(infoTable, 1, 1, str.tostring(atrVal, format.mintick), text_color=color.white)

    table.cell(infoTable, 0, 2, "Zone Width", text_color=color.white)
    table.cell(infoTable, 1, 2, str.tostring(zoneWidth, format.mintick), text_color=color.white)

    table.cell(infoTable, 0, 3, "PP", text_color=ppColor)
    table.cell(infoTable, 1, 3, str.tostring(pp, format.mintick), text_color=ppColor)

    table.cell(infoTable, 0, 4, "R1", text_color=r1Color)
    table.cell(infoTable, 1, 4, str.tostring(r1, format.mintick), text_color=r1Color)

    table.cell(infoTable, 0, 5, "R2", text_color=r2Color)
    table.cell(infoTable, 1, 5, str.tostring(r2, format.mintick), text_color=r2Color)

    table.cell(infoTable, 0, 6, "R3", text_color=r3Color)
    table.cell(infoTable, 1, 6, str.tostring(r3, format.mintick), text_color=r3Color)

    table.cell(infoTable, 0, 7, "S1", text_color=s1Color)
    table.cell(infoTable, 1, 7, str.tostring(s1, format.mintick), text_color=s1Color)

    table.cell(infoTable, 0, 8, "S2 / S3", text_color=s2Color)
    table.cell(infoTable, 1, 8, str.tostring(s2, format.mintick) + " / " + str.tostring(s3, format.mintick), text_color=s3Color)

// ============================================================================
// ALERTS
// ============================================================================
checkZoneAlert(idx, val) =>
    upper = val + zoneWidth
    lower = val - zoneWidth
    inZone = close >= lower and close <= upper
    entered = inZone and not inZone[1]
    if entered and enableZoneAlerts
        alert("Ticker: " + syminfo.ticker + " | TF: " + timeframe.period + " | Level: " + array.get(levelNames, idx) + " | Price: " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)

if not na(pp)
    for i = 0 to 6
        checkZoneAlert(i, array.get(levelValues, i))

crossUpPP   = ta.crossover(close, pp)
crossDownPP = ta.crossunder(close, pp)

if enablePPCrossAlerts and crossUpPP
    alert("Ticker: " + syminfo.ticker + " | TF: " + timeframe.period + " | Level: PP | Crossed Above | Price: " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)

if enablePPCrossAlerts and crossDownPP
    alert("Ticker: " + syminfo.ticker + " | TF: " + timeframe.period + " | Level: PP | Crossed Below | Price: " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
````
