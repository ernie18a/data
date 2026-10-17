# Precision Volume Profile [AxeAlgo]

- url: https://www.tradingview.com/script/0ZeyEITk-Precision-Volume-Profile-AxeAlgo/
- type: indicator
- pine_id: PUB;3e9511c8ed9148dcb158d87fe83366de
- version: 1.0

## Description

[b]OVERVIEW[/b]

Precision Volume Profile [AxeAlgo] is a native Pine Script volume
profile tool: it rebuilds a full price-by-volume histogram for whatever
range you anchor it to — the visible chart, a fixed bar count, the
current day, week, month, or a custom trading session — and derives the
Point of Control (POC), Value Area High/Low (VAH/VAL), a Prior Period
Value Area with open-type and POC-migration classification, and a
session VWAP with standard-deviation bands, all from the same underlying
bar history.

This is the classic Market Profile / Volume Profile toolkit used to
judge where the market has actually traded the most volume — not just
where price is right now — and how today's activity compares to the
period before it. Everything here runs natively on your own chart data;
there are no external requests, no repainting of confirmed history, and
no hidden calculations.

This script is free and open-source, published so the full methodology
described below is verifiable directly in the source code.

============================================================
[b]HOW IT WORKS[/b]
============================================================

Volume Profile Histogram
----------------------------
For the selected range, price is divided into rows (automatically sized
to the range, or set manually) and every historical bar's volume is
distributed across the rows its high-low span touches. Each bar's
volume is split into an estimated buy side and sell side based on where
that bar's close sits between its low and high — a bar that closed near
its high is treated as more buy-weighted, one that closed near its low
as more sell-weighted. The row with the most total volume becomes the
POC; rows are colored on a gradient between two configurable colors
based on that estimated buy/sell split, with opacity scaled to each
row's relative strength versus the POC.

Value Area
----------------------------
The Value Area is expanded outward from the POC two rows at a time —
comparing the volume of the next pair of rows above versus the next
pair below and adding whichever pair holds more volume — until the
accumulated volume reaches the configured Value Area percentage (70% by
default, the standard Market Profile convention). This is the same
textbook two-row-pair expansion method used for both the live profile
and the Prior Period snapshot below, so the two stay directly
comparable.

Anchor Modes
----------------------------
Six ways to define what range the profile is built from: Visible Range
(whatever's currently on screen), Fixed Bars (a set lookback), Day,
Week, Month, or a fully custom Session (configurable start/end time and
timezone, e.g. 0930-1600 for US regular trading hours). A dotted
vertical line marks exactly where the current profile's lookback
begins whenever that boundary isn't simply the edge of your screen.

Prior Period Value Area, Open Type & POC Migration
----------------------------------------------------
At each period boundary (Day or Week, configurable), the script
snapshots the period that just closed: its Value Area is drawn as a
dashed box extending forward, today's open is classified as Above,
Below, or Inside that prior value, and the new POC is compared against
the previous one to report whether it's migrating up, down, or holding
flat. This is the standard "open-type" read used to gauge whether a
session is likely to be rotational or trending.

Session VWAP & Standard Deviation Bands
------------------------------------------
A running volume-weighted average price with up to two configurable
standard-deviation bands on each side, calculated with the same
volume-weighted variance formula as TradingView's own VWAP tool. It can
reset either at calendar midnight or at your custom session's open
time — the same session window used by the Session anchor mode above,
so the two can be kept in sync.

Stats Panel
----------------------------
An optional on-chart table summarizing the active anchor mode, bar/row
count, POC, VAH/VAL, Value Area width, estimated buy/sell split and
delta, total volume, open type, POC migration, and current VWAP —
everything the script computes, in one place, without needing to
hover over individual lines.

Alerts
----------------------------
Two alert conditions: price crossing the POC, and price entering or
exiting the Value Area.

============================================================
[b]ACCURACY NOTE — HOW BUY/SELL VOLUME IS ESTIMATED[/b]
============================================================

Pine Script does not have access to real trade-by-trade tape or
bid/ask data on standard bars, so no volume profile indicator can
measure "true" buy versus sell volume directly. This script — like
essentially every volume profile tool on TradingView — estimates it
from each bar's own OHLC: where the close sits between the low and the
high. This is a widely used, reasonable proxy, but it is an estimate,
not measured order flow. Treat the buy/sell split and Delta reading as
directional context, not a precise execution metric.

============================================================
[b]HOW TO USE IT[/b]
============================================================

Add the indicator, pick an Anchor mode that matches how you trade
(Visible Range for manual exploration, Day/Week/Session for a
consistent recurring reference), and set the Value Area percentage if
you want something other than the 70% default. Every input has an
in-editor tooltip explaining exactly what it changes. The Prior Period
panel rows (Open Type, POC Migration) are most useful checked once at
the start of a session; the POC/VAH/VAL lines and histogram are
intended as a persistent reference for the rest of the period.

============================================================
[b]REPAINTING & REAL-TIME BEHAVIOR[/b]
============================================================

The profile, its lines, and the stats panel are only (re)computed on
the most recent bar (barstate.islast) — not on every historical bar —
for performance, and are cleared and redrawn from scratch each time
they update. In Visible Range or Fixed Bars mode this means the profile
legitimately changes as you scroll, zoom, or as new bars form — that's
the tool responding to a different input range, not repainting of a
fixed historical value. In Day/Week/Month/Session mode, once a period
has closed its POC, VAH, and VAL are fixed and do not change on
subsequent reloads; only the currently forming period's profile updates
live as new bars print. The Prior Period Value Area snapshot is
computed once, at the moment its period closes, and is never
recalculated afterward.

============================================================
[b]LIMITATIONS — PLEASE READ[/b]
============================================================

- Buy/sell volume is an OHLC-based estimate, not real tape data (see
  the Accuracy Note above).
- The Value Area expansion is a discrete two-row-pair algorithm; on
  very coarse row counts it can land a percentage point or two away
  from the exact target rather than hitting it precisely.
- "Max Bars Stored" caps how much history is kept in memory for
  performance; extremely long Fixed Bars or Visible Range lookbacks on
  very low timeframes can exceed it and get truncated.
- The custom Session anchor and VWAP session-open reset depend on the
  Session Time and Timezone inputs actually matching your instrument's
  real trading session — mismatched inputs will produce a
  technically-correct but practically meaningless boundary.
- This is a discretionary analysis tool intended to support your own
  read of the market, not a mechanical, guaranteed-signal system.

============================================================
[b]RISK DISCLAIMER[/b]
============================================================

This script is provided for educational and informational purposes
only. It is not financial advice, and it is not a recommendation to buy
or sell any security or instrument. Trading and investing involve
substantial risk of loss and are not suitable for every investor. Past
performance is not indicative of future results. Always do your own
research and consider consulting a licensed financial advisor before
making trading decisions. Use this indicator, and any alerts it
generates, entirely at your own risk.

============================================================
[b]ORIGINALITY[/b]
============================================================

This is original work: the row-building and Value Area expansion
algorithms, the Prior Period snapshot and open-type/migration logic,
the session-anchor handling, and the visual design are all written
from scratch for this script. It is published free and open-source so
the full methodology described above is verifiable directly in the
source code.

## Source Code

````pine
//@version=6
// © AxeAlgo
indicator("Precision Volume Profile [AxeAlgo]", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500, max_bars_back=5000)

// ============================================================================
// INPUTS
// ============================================================================
grpRange = "Profile Range & Resolution"
anchorMode    = input.string("Day", "Anchor", options=["Visible Range", "Fixed Bars", "Day", "Week", "Month", "Session"], group=grpRange, tooltip="Which bars the profile is built from: the chart's visible range, a fixed bar count, the current calendar day/week/month, or a custom trading session.")
fixedBars     = input.int(300, "Fixed Bars Lookback", minval=10, maxval=3000, group=grpRange, tooltip="Number of bars to include when Anchor is set to 'Fixed Bars'.")
sessionTimeInput = input.session("0930-1600", "Session Time (Anchor = Session)", group=grpRange, tooltip="Custom session window used when Anchor is set to 'Session', e.g. 0930-1600 for US regular trading hours.")
sessionTZ         = input.string("America/New_York", "Session Timezone", group=grpRange, tooltip="Timezone the Session Time is interpreted in.")
intradayResetMode = input.string("Midnight", "Reset VWAP At", options=["Midnight", "Session Open"], group=grpRange, tooltip="Whether VWAP resets at calendar midnight or at the custom session's open time.")
maxStoredBars = input.int(2000, "Max Bars Stored (perf cap)", minval=200, maxval=3000, group=grpRange, tooltip="Maximum number of bars kept in memory for profile rebuilds. Older bars are dropped once this is exceeded; raise for longer lookbacks at the cost of performance.")
rowMode       = input.string("Auto", "Row Count", options=["Auto", "Manual"], group=grpRange, tooltip="Auto scales the number of price rows to the bar range; Manual lets you fix the row count yourself.")
manualRows    = input.int(50, "Manual Rows", minval=5, maxval=200, group=grpRange, tooltip="Number of price rows in the profile when Row Count is set to 'Manual'.")
valueAreaPct  = input.float(70, "Value Area %", minval=10, maxval=99, group=grpRange, tooltip="Percentage of total volume the Value Area (VAH-VAL) expands to cover, starting from the POC. 70% is the standard Market Profile default.")

grpPriorVA = "Prior Period Value Area"
showPriorVA   = input.bool(true, "Show Prior Period VA, Open Type & POC Migration", group=grpPriorVA, tooltip="Draws the previous period's Value Area box, and classifies today's open (above/inside/below value) and POC migration (up/down/flat) versus that prior period.")
priorVAAnchor = input.string("Day", "Period", options=["Day", "Week"], group=grpPriorVA, tooltip="Period boundary used to snapshot the Prior Period Value Area — Day or Week.")

grpVWAP = "VWAP"
showVWAP      = input.bool(false, "Show Session VWAP", group=grpVWAP, tooltip="Plots the running Volume-Weighted Average Price, resetting per the Reset setting above (midnight or session open).")
showVWAPBands = input.bool(false, "Show Std Dev Bands", group=grpVWAP, tooltip="Plots standard-deviation bands around VWAP at the two multiples set below.")
vwapBandMult1 = input.float(1.0, "Band 1 (σ)", minval=0.1, maxval=5, group=grpVWAP, tooltip="Standard deviation multiple for the inner VWAP band.")
vwapBandMult2 = input.float(2.0, "Band 2 (σ)", minval=0.1, maxval=5, group=grpVWAP, tooltip="Standard deviation multiple for the outer VWAP band.")
vwapColor     = input.color(#D4AF37, "VWAP Color", group=grpVWAP, tooltip="Color used for the VWAP line and its bands.")

grpStyle = "Style"
profileWidthBars = input.int(60, "Profile Width (bars)", minval=5, maxval=300, group=grpStyle, tooltip="Horizontal width, in bars, that the profile histogram occupies.")
profilePlacement = input.string("Right of Bars", "Placement", options=["Right of Bars", "Overlap Range"], group=grpStyle, tooltip="'Right of Bars' draws the profile to the right of price action. 'Overlap Range' draws it directly over the bars it was built from.")
growTowardPrice  = input.bool(true, "Grow Bars Toward Price (POC touches price)", group=grpStyle, tooltip="When on, each row grows from the profile's outer edge toward price so the POC touches price. When off, rows grow outward from price instead.")
upColor          = input.color(#B8860B, "Buy Volume Color", group=grpStyle, tooltip="Color for the estimated buy-side portion of each row.")
downColor        = input.color(#F5F5F5, "Sell Volume Color", group=grpStyle, tooltip="Color for the estimated sell-side portion of each row.")
dimOutsideVA     = input.bool(true, "Dim Rows Outside Value Area", group=grpStyle, tooltip="Fades rows that fall outside the Value Area (below VAL or above VAH) so the VA stands out.")
pocColor         = input.color(#FFD400, "POC Color", group=grpStyle, tooltip="Color of the Point of Control line — the price row with the most volume.")
vahvalColor      = input.color(#E8DFC8, "VAH / VAL Color", group=grpStyle, tooltip="Color of the Value Area High/Low lines and the Prior Period VA box border.")
anchorLineColor  = input.color(color.new(#B8860B, 55), "Anchor Line Color", group=grpStyle, tooltip="Color of the vertical line marking where the current profile's lookback starts.")

grpPanel = "Stats Panel"
showPanel = input.bool(true, "Show Stats Panel", group=grpPanel, tooltip="Shows the on-chart table summarizing POC, VAH/VAL, buy/sell split, open type, POC migration and VWAP.")
panelPos  = input.string("Top Right", "Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpPanel, tooltip="Corner of the chart the Stats Panel is anchored to.")
panelLabelColor = input.color(#C9B37E, "Panel Label Color", group=grpPanel, tooltip="Color of the row labels (left column) in the Stats Panel.")
panelValueColor = input.color(#F5F5F5, "Panel Value Color", group=grpPanel, tooltip="Default color of row values (right column) in the Stats Panel, for rows without their own semantic color.")

grpAlerts = "Alerts"
alertPOC = input.bool(false, "Alert: Price Crosses POC", group=grpAlerts, tooltip="Fires an alert whenever price crosses the current profile's POC.")
alertVA  = input.bool(false, "Alert: Enter / Exit Value Area", group=grpAlerts, tooltip="Fires an alert whenever price enters or exits the current profile's Value Area (between VAL and VAH).")

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================
f_argmax(arr, n) =>
    pr = 0
    pv = -1.0
    for r = 0 to n - 1
        vv = array.get(arr, r)
        if vv > pv
            pv := vv
            pr := r
    pr

f_combineTotal(rvUp, rvDn, n) =>
    arr = array.new<float>(n, 0.0)
    tot = 0.0
    for r = 0 to n - 1
        v = array.get(rvUp, r) + array.get(rvDn, r)
        array.set(arr, r, v)
        tot += v
    [arr, tot]

f_fmtVol(v) =>
    string txt = v >= 1000000 ? str.tostring(v / 1000000, "#.##") + "M" : v >= 1000 ? str.tostring(v / 1000, "#.##") + "K" : str.tostring(v, "#")
    txt

// Textbook two-row-pair Value Area expansion from a given POC row. Shared by the
// main visible profile and the prior-period snapshot so both use identical math.
f_computeVA(rvTot, rowsN, pocRow, vaPct) =>
    totVol = 0.0
    for r = 0 to rowsN - 1
        totVol += array.get(rvTot, r)
    included = array.new<bool>(rowsN, false)
    array.set(included, pocRow, true)
    vaVol = array.get(rvTot, pocRow)
    target = totVol * vaPct / 100
    up = pocRow + 1
    down = pocRow - 1
    while vaVol < target and (up < rowsN or down >= 0)
        upAvail1 = up < rowsN
        downAvail1 = down >= 0
        upSum = -1.0
        if upAvail1
            upSum := array.get(rvTot, up)
            if up + 1 < rowsN
                upSum += array.get(rvTot, up + 1)
        downSum = -1.0
        if downAvail1
            downSum := array.get(rvTot, down)
            if down - 1 >= 0
                downSum += array.get(rvTot, down - 1)
        if not upAvail1 and not downAvail1
            break
        else if downSum > upSum
            array.set(included, down, true)
            vaVol += array.get(rvTot, down)
            if down - 1 >= 0
                array.set(included, down - 1, true)
                vaVol += array.get(rvTot, down - 1)
                down -= 2
            else
                down -= 1
        else
            array.set(included, up, true)
            vaVol += array.get(rvTot, up)
            if up + 1 < rowsN
                array.set(included, up + 1, true)
                vaVol += array.get(rvTot, up + 1)
                up += 2
            else
                up += 1
    vaHighRow = pocRow
    vaLowRow = pocRow
    for r = 0 to rowsN - 1
        if array.get(included, r)
            vaHighRow := math.max(vaHighRow, r)
            vaLowRow := math.min(vaLowRow, r)
    [vaHighRow, vaLowRow]

// ============================================================================
// GLOBAL HISTORY BUFFERS (raw candle data kept for on-demand profile rebuilds)
// ============================================================================
var array<float> hTime    = array.new<float>()
var array<float> hOpen    = array.new<float>()
var array<float> hHigh    = array.new<float>()
var array<float> hLow     = array.new<float>()
var array<float> hClose   = array.new<float>()
var array<float> hVol     = array.new<float>()
var array<int>   hBarIdx  = array.new<int>()
var array<bool>  hNewDay     = array.new<bool>()
var array<bool>  hNewWeek    = array.new<bool>()
var array<bool>  hNewMonth   = array.new<bool>()
var array<bool>  hNewSession = array.new<bool>()

var float  prevPOC          = na
var string openTypeText     = "—"
var string pocMigrationText = "—"
var box    priorVABox       = na
var label  priorVALabel     = na

// ============================================================================
// PROFILE ROW BUILDER
// ============================================================================
f_buildRows(i1, i2, rowsN) =>
    hiP = -1.0
    loP = 1e10
    for j = i1 to i2
        hiP := math.max(hiP, array.get(hHigh, j))
        loP := math.min(loP, array.get(hLow, j))
    rh = rowsN > 0 ? (hiP - loP) / rowsN : 0.0
    rvUp = array.new<float>(rowsN, 0.0)
    rvDn = array.new<float>(rowsN, 0.0)
    if rh > 0
        for j = i1 to i2
            bH = array.get(hHigh, j)
            bL = array.get(hLow, j)
            bC = array.get(hClose, j)
            bV = array.get(hVol, j)
            buyFrac = bH > bL ? (bC - bL) / (bH - bL) : 0.5
            r1 = math.max(0, math.min(rowsN - 1, int(math.floor((bL - loP) / rh))))
            r2 = math.max(0, math.min(rowsN - 1, int(math.floor((bH - loP) / rh))))
            span = r2 - r1 + 1
            vpr = bV / span
            for r = r1 to r2
                array.set(rvUp, r, array.get(rvUp, r) + vpr * buyFrac)
                array.set(rvDn, r, array.get(rvDn, r) + vpr * (1 - buyFrac))
    [rvUp, rvDn, loP, hiP, rh]

// ============================================================================
// PER-BAR: period flags, prior-period boundary capture, history push
// ============================================================================
newDay   = ta.change(time("D")) != 0 or bar_index == 0
newWeek  = ta.change(time("W")) != 0 or bar_index == 0
newMonth = ta.change(time("M")) != 0 or bar_index == 0

sessionTimeNow = time(timeframe.period, sessionTimeInput, sessionTZ)
inSession      = not na(sessionTimeNow)
newSession     = inSession and (na(sessionTimeNow[1]) or not inSession[1])

resetBar = intradayResetMode == "Session Open" ? newSession : newDay

// --- Prior Period VA: snapshot the period that just closed, before pushing the new bar ---
if showPriorVA and bar_index > 0
    isBoundary = priorVAAnchor == "Day" ? newDay : newWeek
    if isBoundary
        nEx = array.size(hTime)
        flagArr = priorVAAnchor == "Day" ? hNewDay : hNewWeek
        startIdx = 0
        for k = nEx - 1 to 0
            if array.get(flagArr, k)
                startIdx := k
                break
        endIdx = nEx - 1
        if endIdx >= startIdx
            [ru, rd, plo, phi, prh] = f_buildRows(startIdx, endIdx, 40)
            if prh > 0
                [pTot, pSum] = f_combineTotal(ru, rd, 40)
                pRow = f_argmax(pTot, 40)
                pocPx = plo + (pRow + 0.5) * prh

                [vaHiRow, vaLoRow] = f_computeVA(pTot, 40, pRow, valueAreaPct)
                thisVAH = plo + (vaHiRow + 1) * prh
                thisVAL = plo + vaLoRow * prh
                openTypeText := open > thisVAH ? "Open Above Value" : open < thisVAL ? "Open Below Value" : "Open Inside Value"
                pocMigrationText := na(prevPOC) ? "First Period" : (pocPx > prevPOC ? "Migrating Up" : pocPx < prevPOC ? "Migrating Down" : "Flat")
                prevPOC := pocPx
                if not na(priorVABox)
                    box.delete(priorVABox)
                if not na(priorVALabel)
                    label.delete(priorVALabel)
                priorVABox := box.new(left=bar_index, top=thisVAH, right=bar_index + 1, bottom=thisVAL, extend=extend.right, bgcolor=color(na), border_color=color.new(vahvalColor, 45), border_width=1, border_style=line.style_dashed)
                priorVALabel := label.new(bar_index, thisVAH, "Prior VA", xloc=xloc.bar_index, style=label.style_label_down, size=size.tiny, color=color.new(vahvalColor, 0), textcolor=color.black)

// --- push current bar into history buffers ---
array.push(hTime, time)
array.push(hOpen, open)
array.push(hHigh, high)
array.push(hLow, low)
array.push(hClose, close)
array.push(hVol, volume)
array.push(hBarIdx, bar_index)
array.push(hNewDay, newDay)
array.push(hNewWeek, newWeek)
array.push(hNewMonth, newMonth)
array.push(hNewSession, newSession)

if array.size(hTime) > maxStoredBars
    array.shift(hTime)
    array.shift(hOpen)
    array.shift(hHigh)
    array.shift(hLow)
    array.shift(hClose)
    array.shift(hVol)
    array.shift(hBarIdx)
    array.shift(hNewDay)
    array.shift(hNewWeek)
    array.shift(hNewMonth)
    array.shift(hNewSession)

// --- Session VWAP + Standard Deviation Bands (resets at midnight or session open, O(1) per bar) ---
var float cumPV  = na
var float cumPV2 = na
var float cumVol = na

if resetBar
    cumPV := 0.0
    cumPV2 := 0.0
    cumVol := 0.0

if showVWAP
    tp = hlc3
    cumPV := cumPV + tp * volume
    cumPV2 := cumPV2 + tp * tp * volume
    cumVol := cumVol + volume

vwapValue = (showVWAP and cumVol > 0) ? cumPV / cumVol : na
vwapVariance = na(vwapValue) ? na : math.max(0.0, cumPV2 / cumVol - vwapValue * vwapValue)
vwapStdDev = na(vwapVariance) ? na : math.sqrt(vwapVariance)

vwapU1 = na(vwapValue) ? na : vwapValue + vwapStdDev * vwapBandMult1
vwapL1 = na(vwapValue) ? na : vwapValue - vwapStdDev * vwapBandMult1
vwapU2 = na(vwapValue) ? na : vwapValue + vwapStdDev * vwapBandMult2
vwapL2 = na(vwapValue) ? na : vwapValue - vwapStdDev * vwapBandMult2

plot(showVWAP ? vwapValue : na, "VWAP", color=vwapColor, linewidth=2)
plot(showVWAP and showVWAPBands ? vwapU1 : na, "VWAP Upper 1", color=color.new(vwapColor, 55), linewidth=1)
plot(showVWAP and showVWAPBands ? vwapL1 : na, "VWAP Lower 1", color=color.new(vwapColor, 55), linewidth=1)
plot(showVWAP and showVWAPBands ? vwapU2 : na, "VWAP Upper 2", color=color.new(vwapColor, 75), linewidth=1)
plot(showVWAP and showVWAPBands ? vwapL2 : na, "VWAP Lower 2", color=color.new(vwapColor, 75), linewidth=1)

// ============================================================================
// MAIN PROFILE: rebuilds on every visible-range change (and realtime tick on last bar)
// ============================================================================
var array<box>   profBoxes  = array.new<box>()
var array<line>  profLines  = array.new<line>()
var array<label> profLabels = array.new<label>()
var table infoTable = na

leftT  = chart.left_visible_bar_time
rightT = chart.right_visible_bar_time

if barstate.islast
    // clear previous drawings from prior recompute
    if array.size(profBoxes) > 0
        for i = 0 to array.size(profBoxes) - 1
            box.delete(array.get(profBoxes, i))
        array.clear(profBoxes)
    if array.size(profLines) > 0
        for i = 0 to array.size(profLines) - 1
            line.delete(array.get(profLines, i))
        array.clear(profLines)
    if array.size(profLabels) > 0
        for i = 0 to array.size(profLabels) - 1
            label.delete(array.get(profLabels, i))
        array.clear(profLabels)

    n = array.size(hTime)
    i1 = 0
    i2 = n - 1

    if anchorMode == "Visible Range"
        for i = 0 to n - 1
            if array.get(hTime, i) >= leftT
                i1 := i
                break
        for i = n - 1 to 0
            if array.get(hTime, i) <= rightT
                i2 := i
                break
    else if anchorMode == "Fixed Bars"
        i1 := math.max(0, n - fixedBars)
    else if anchorMode == "Day"
        for k = n - 1 to 0
            if array.get(hNewDay, k)
                i1 := k
                break
    else if anchorMode == "Week"
        for k = n - 1 to 0
            if array.get(hNewWeek, k)
                i1 := k
                break
    else if anchorMode == "Session"
        for k = n - 1 to 0
            if array.get(hNewSession, k)
                i1 := k
                break
    else
        // Month
        for k = n - 1 to 0
            if array.get(hNewMonth, k)
                i1 := k
                break

    i1 := math.min(i1, i2)

    rangeBars = i2 - i1 + 1
    rows = rowMode == "Manual" ? manualRows : math.max(10, math.min(100, int(rangeBars / 4)))

    [rvUp, rvDn, lo, hi, rh] = f_buildRows(i1, i2, rows)

    if rh > 0
        if anchorMode != "Visible Range"
            anchorBarIdx = array.get(hBarIdx, i1)
            anchorLn = line.new(anchorBarIdx, lo, anchorBarIdx, hi, extend=extend.both, color=anchorLineColor, style=line.style_dotted, width=1)
            array.push(profLines, anchorLn)

        [rvTot, totalVol] = f_combineTotal(rvUp, rvDn, rows)

        if totalVol > 0
            pocRow = f_argmax(rvTot, rows)
            pocPrice = lo + (pocRow + 0.5) * rh

            // --- Value Area: textbook two-row-pair expansion from POC ---
            [vaHighRow, vaLowRow] = f_computeVA(rvTot, rows, pocRow, valueAreaPct)
            vahPrice = lo + (vaHighRow + 1) * rh
            valPrice = lo + vaLowRow * rh

            // --- Render histogram boxes ---
            // nearRef sits right beside price; farRef is the profile block's outer edge.
            // growTowardPrice=true (default): every bar is anchored at farRef and reaches back toward
            // price as volume increases — POC touches price, weak rows stay stranded near farRef.
            // growTowardPrice=false: classic style — every bar is anchored at nearRef and reaches
            // outward toward farRef instead. Neither style can ever overlap the price candles.
            maxRowVol = array.get(rvTot, pocRow)
            rightAnchorBarIdx = array.get(hBarIdx, i2)
            nearRef = profilePlacement == "Right of Bars" ? rightAnchorBarIdx + 2 : array.get(hBarIdx, i1)
            farRef = nearRef + profileWidthBars

            for r = 0 to rows - 1
                rv = array.get(rvTot, r)
                if rv > 0
                    rowBottom = lo + r * rh
                    rowTop = lo + (r + 1) * rh
                    buyPctRow = array.get(rvUp, r) / rv
                    baseColor = color.from_gradient(buyPctRow, 0, 1, downColor, upColor)
                    relStrength = rv / maxRowVol
                    fillTrans = int(72 - relStrength * 62)
                    inVA = r >= vaLowRow and r <= vaHighRow
                    finalColor = (not dimOutsideVA or inVA) ? color.new(baseColor, fillTrans) : color.new(baseColor, math.min(92, fillTrans + 20))
                    glowBorder = color.new(baseColor, math.max(0, fillTrans - 45))
                    reach = relStrength * profileWidthBars
                    boxLeft = growTowardPrice ? int(farRef - reach) : nearRef
                    boxRight = growTowardPrice ? farRef : int(nearRef + reach)
                    bx = box.new(left=boxLeft, top=rowTop, right=boxRight, bottom=rowBottom, border_color=glowBorder, border_width=1, bgcolor=finalColor)
                    array.push(profBoxes, bx)

            labelAnchorX = farRef + 3
            lineX1 = array.get(hBarIdx, i1)
            lineX2 = math.max(rightAnchorBarIdx + 2, farRef)
            pocLn = line.new(lineX1, pocPrice, lineX2, pocPrice, xloc=xloc.bar_index, color=pocColor, width=2)
            vahLn = line.new(lineX1, vahPrice, lineX2, vahPrice, xloc=xloc.bar_index, color=vahvalColor, style=line.style_dashed, width=1)
            valLn = line.new(lineX1, valPrice, lineX2, valPrice, xloc=xloc.bar_index, color=vahvalColor, style=line.style_dashed, width=1)
            array.push(profLines, pocLn)
            array.push(profLines, vahLn)
            array.push(profLines, valLn)

            vahLbl = label.new(lineX2, vahPrice, "VAH", xloc=xloc.bar_index, style=label.style_label_left, size=size.tiny, color=color.new(vahvalColor, 0), textcolor=color.black)
            valLbl = label.new(lineX2, valPrice, "VAL", xloc=xloc.bar_index, style=label.style_label_left, size=size.tiny, color=color.new(vahvalColor, 0), textcolor=color.black)
            array.push(profLabels, vahLbl)
            array.push(profLabels, valLbl)

            // --- Alerts (evaluated on the live/last bar snapshot) ---
            if alertPOC
                crossedPOC = (close[1] - pocPrice) * (close - pocPrice) < 0
                if crossedPOC
                    alert("Precision VP: price crossed POC (" + str.tostring(pocPrice, format.mintick) + ")", alert.freq_once_per_bar)
            if alertVA
                wasInsideVA = close[1] >= valPrice and close[1] <= vahPrice
                isInsideVA = close >= valPrice and close <= vahPrice
                if wasInsideVA != isInsideVA
                    msg = isInsideVA ? "Precision VP: price entered Value Area" : "Precision VP: price exited Value Area"
                    alert(msg, alert.freq_once_per_bar)

            // --- Stats panel ---
            if showPanel
                tPos = panelPos == "Top Right" ? position.top_right : panelPos == "Top Left" ? position.top_left : panelPos == "Bottom Right" ? position.bottom_right : position.bottom_left
                if na(infoTable)
                    infoTable := table.new(tPos, 2, 13, bgcolor=color.new(color.black, 15), border_width=1, border_color=color.new(vwapColor, 45))
                buyPctTotal = 0.0
                sumUp = 0.0
                for r = 0 to rows - 1
                    sumUp += array.get(rvUp, r)
                buyPctTotal := sumUp / totalVol * 100
                sellPctTotal = 100 - buyPctTotal
                vaWidthPct = (vahPrice - valPrice) / (hi - lo) * 100

                table.cell(infoTable, 0, 0, "PRECISION VP", text_color=pocColor, bgcolor=color.new(color.black, 0), text_size=size.small)
                table.cell(infoTable, 1, 0, anchorMode, text_color=vwapColor, bgcolor=color.new(color.black, 0), text_size=size.small)
                table.cell(infoTable, 0, 1, "Range", text_color=panelLabelColor, text_size=size.small)
                table.cell(infoTable, 1, 1, str.tostring(rangeBars) + " bars / " + str.tostring(rows) + " rows", text_color=panelValueColor, text_size=size.small)
                table.cell(infoTable, 0, 2, "POC", text_color=panelLabelColor, text_size=size.small)
                table.cell(infoTable, 1, 2, str.tostring(pocPrice, format.mintick), text_color=pocColor, text_size=size.small)
                table.cell(infoTable, 0, 3, "VAH", text_color=panelLabelColor, text_size=size.small)
                table.cell(infoTable, 1, 3, str.tostring(vahPrice, format.mintick), text_color=panelValueColor, text_size=size.small)
                table.cell(infoTable, 0, 4, "VAL", text_color=panelLabelColor, text_size=size.small)
                table.cell(infoTable, 1, 4, str.tostring(valPrice, format.mintick), text_color=panelValueColor, text_size=size.small)
                table.cell(infoTable, 0, 5, "VA Width", text_color=panelLabelColor, text_size=size.small)
                table.cell(infoTable, 1, 5, str.tostring(vaWidthPct, "#.#") + "% of range", text_color=panelValueColor, text_size=size.small)
                table.cell(infoTable, 0, 6, "Buy Vol", text_color=panelLabelColor, text_size=size.small)
                table.cell(infoTable, 1, 6, str.tostring(buyPctTotal, "#.#") + "%", text_color=upColor, text_size=size.small)
                table.cell(infoTable, 0, 7, "Sell Vol", text_color=panelLabelColor, text_size=size.small)
                table.cell(infoTable, 1, 7, str.tostring(sellPctTotal, "#.#") + "%", text_color=downColor, text_size=size.small)
                table.cell(infoTable, 0, 8, "Delta", text_color=panelLabelColor, text_size=size.small)
                table.cell(infoTable, 1, 8, str.tostring(buyPctTotal - sellPctTotal, "#.#") + "%", text_color=buyPctTotal >= sellPctTotal ? upColor : downColor, text_size=size.small)
                table.cell(infoTable, 0, 9, "Total Vol", text_color=panelLabelColor, text_size=size.small)
                table.cell(infoTable, 1, 9, f_fmtVol(totalVol), text_color=panelValueColor, text_size=size.small)

                openTypeColor = openTypeText == "Open Above Value" ? upColor : openTypeText == "Open Below Value" ? downColor : panelValueColor
                pocMigColor = pocMigrationText == "Migrating Up" ? upColor : pocMigrationText == "Migrating Down" ? downColor : panelValueColor

                table.cell(infoTable, 0, 10, "Open Type", text_color=panelLabelColor, text_size=size.small)
                table.cell(infoTable, 1, 10, openTypeText, text_color=openTypeColor, text_size=size.small)
                table.cell(infoTable, 0, 11, "POC Migration", text_color=panelLabelColor, text_size=size.small)
                table.cell(infoTable, 1, 11, pocMigrationText, text_color=pocMigColor, text_size=size.small)
                table.cell(infoTable, 0, 12, "VWAP", text_color=panelLabelColor, text_size=size.small)
                table.cell(infoTable, 1, 12, na(vwapValue) ? "Off" : str.tostring(vwapValue, format.mintick), text_color=vwapColor, text_size=size.small)

wm_theme     = input.string('Light', 'Watermark Theme', group=' A X E A L G O ', options=['Dark', 'Light'])

if true//barstate.islast
    dark        = wm_theme == 'Dark'
    wm_bg       = dark ? color.new(#14110B, 0)  : color.new(#F2EAD3, 0)
    wm_dot_col  = dark ? color.new(#D4AF37, 25) : color.new(#B8860B, 10)
    wm_txt_col  = dark ? color.new(#C9B37E, 0)  : color.new(#7A6423, 0)
    wm_frm_col  = dark ? color.new(#4A3B1E, 0)  : color.new(#D8C89A, 0)

    wm = table.new(position.bottom_center, 2, 1,
                   frame_color=wm_frm_col,
                   frame_width=1,
                   border_width=0)
    table.cell(wm, 0, 0, ' ◆ ',
               bgcolor=wm_bg,
               text_color=wm_dot_col,
               text_size=size.small,
               text_halign=text.align_center,
               text_valign=text.align_center)
    table.cell(wm, 1, 0, ' 𝙰 𝚇 𝙴 𝙰 𝙻 𝙶 𝙾',
               bgcolor=wm_bg,
               text_color=wm_txt_col,
               text_size=size.normal,
               text_halign=text.align_left,
               text_valign=text.align_center)
````
