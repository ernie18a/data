# CPR by VickyBobby

- url: https://www.tradingview.com/script/V9FSD90I-CPR-by-VickyBobby/
- type: indicator
- pine_id: PUB;1debe2c7eab0464b9e9d0db1a3e9c54c
- version: 5.0

## Description

CPR by VickyBobby

A complete Central Pivot Range (CPR) indicator designed for intraday and positional traders. This script plots Daily, Weekly, and Monthly CPR levels along with the full classical floor pivot system (R1 to R4, S1 to S4), previous day reference levels, and an automated CPR width classifier - delivering a unified view of the most actionable support and resistance zones on the chart.


WHAT THIS INDICATOR PLOTS

Central Pivot Range (CPR):
- Pivot (P)
- Top Central (TC)
- Bottom Central (BC)

Floor Pivot Levels:
- Resistance: R1, R2, R3, R4
- Support: S1, S2, S3, S4

Previous Day Reference Levels:
- Previous Day High (PDH)
- Previous Day Low (PDL)
- Previous Day Close (PDC)

Higher Timeframe CPR (Optional):
- Weekly CPR
- Monthly CPR


FORMULAS USED

Pivot (P)      = (High + Low + Close) / 3
Bottom Central = (High + Low) / 2
Top Central    = (Pivot - BC) + Pivot

R1 = (2 x P) - Low
R2 = P + (High - Low)
R3 = High + 2 x (P - Low)
R4 = R3 + (R2 - R1)

S1 = (2 x P) - High
S2 = P - (High - Low)
S3 = Low - 2 x (High - P)
S4 = S3 - (S1 - S2)

All values are derived from the previous period's High, Low, and Close.


KEY FEATURES

- Day-by-day segmented lines: each trading session displays its own discrete horizontal levels that automatically reset at the start of a new day.
- Forward-extended live levels for the current trading day, making active zones easy to spot.
- Independent toggles for every level (R1 to R4, S1 to S4, PDH, PDL, PDC).
- Multi-timeframe CPR with separate colors for daily, weekly, and monthly.
- Optional CPR Width Classifier: automatically labels the day as Narrow (likely trending), Normal, or Wide (likely sideways) based on customizable thresholds.
- Optional info table showing current Pivot, TC, BC, CPR width percentage, and day type.
- Full styling controls: line width, line style (Solid, Dashed, Dotted), individual colors, label visibility, and price display options.
- Built-in alerts for price crossing Pivot, TC, BC, R1, and S1.
- Clean status line: no input arguments cluttering the indicator title.


HOW TO USE

Interpreting CPR Width:
- Narrow CPR (low previous-day range) often signals a trending day with directional follow-through.
- Wide CPR (high previous-day range) often signals consolidation or range-bound action.
- Higher CPR than the previous day suggests a bullish bias.
- Lower CPR than the previous day suggests a bearish bias.
- Overlapping CPRs across multiple days suggest a sideways accumulation phase.

Trading Approach:
- A sustained move above TC indicates buyer control; upside targets become R1, R2, R3.
- A sustained move below BC indicates seller control; downside targets become S1, S2, S3.
- The pivot itself often acts as the day's mean - price tends to revert to it during consolidation.
- PDH and PDL serve as critical short-term reference points; a break and hold beyond either often defines the day's direction.
- Virgin CPR levels (untouched in the previous session) tend to act as strong magnets and have a higher probability of being tested.


RECOMMENDED SETTINGS

Indian Index Trading (Nifty / Bank Nifty):
- Timeframe: 5m, 15m, or 30m
- Enable: Daily CPR, PDH, PDL, R1, R2, S1, S2
- Line width: CPR = 2, Pivots = 1

Swing Trading / Forex / Crypto:
- Timeframe: 1H to 4H
- Enable: Daily and Weekly CPR
- Adjust width thresholds to suit the asset's volatility profile


NOTES

- Works on any symbol and any timeframe.
- CPR calculations are based on the previous daily session by default.
- Optimized for intraday timeframes (1m to 1H) where CPR levels are most actionable.
- All calculations use standard, widely accepted floor pivot and CPR formulas.


DISCLAIMER

This indicator is provided for educational and informational purposes only. It does not constitute financial advice or a recommendation to trade. Always perform your own analysis and apply proper risk management before making any trading decisions.

## Source Code

````pine
//@version=6
indicator("CPR by VickyBobby", shorttitle="CPR by VickyBobby", overlay=true, max_lines_count=500, max_labels_count=500)

// ============================================================================
// INPUTS
// ============================================================================

grpCPR = "CPR Settings"
showCPR          = input.bool(true,  "Show Daily CPR",       group=grpCPR)
showWeeklyCPR    = input.bool(false, "Show Weekly CPR",      group=grpCPR)
showMonthlyCPR   = input.bool(false, "Show Monthly CPR",     group=grpCPR)
showTomorrowCPR  = input.bool(false,  "Show Tomorrow CPR",    group=grpCPR)
colorNextP       = input.color(color.gray, "Tomorrow Pivot", group=grpCPR)
colorNextTC      = input.color(color.aqua, "Tomorrow TC",    group=grpCPR)
colorNextBC      = input.color(color.aqua, "Tomorrow BC",    group=grpCPR)
showNextTable    = input.bool(false,  "Show Tomorrow CPR Table", group=grpCPR)

grpPivot = "Pivot Settings"
showR1 = input.bool(true,  "R1", group=grpPivot, inline="r")
showR2 = input.bool(true,  "R2", group=grpPivot, inline="r")
showR3 = input.bool(true,  "R3", group=grpPivot, inline="r")
showR4 = input.bool(false, "R4", group=grpPivot, inline="r")
showS1 = input.bool(true,  "S1", group=grpPivot, inline="s")
showS2 = input.bool(true,  "S2", group=grpPivot, inline="s")
showS3 = input.bool(true,  "S3", group=grpPivot, inline="s")
showS4 = input.bool(false, "S4", group=grpPivot, inline="s")

grpPrev = "Previous Day Levels"
showPDH = input.bool(true,  "Previous Day High",  group=grpPrev)
showPDL = input.bool(true,  "Previous Day Low",   group=grpPrev)
showPDC = input.bool(false, "Previous Day Close", group=grpPrev)

grpDisp = "Display Settings"
showLabels = input.bool(true,  "Show Labels",           group=grpDisp)
showPrices = input.bool(false, "Show Prices in Labels", group=grpDisp)
cprLW      = input.int(2, "CPR Line Width", group=grpDisp, minval=1, maxval=5, display=display.none)
pivLW      = input.int(1, "Pivot Line Width", group=grpDisp, minval=1, maxval=5, display=display.none)
lineStyle  = input.string("Solid", "Line Style", group=grpDisp, options=["Solid","Dashed","Dotted"], display=display.none)

grpColor = "Colors"
colorPivot   = input.color(color.black,  "Pivot",       group=grpColor)
colorTC      = input.color(color.blue,   "TC",          group=grpColor)
colorBC      = input.color(color.blue,   "BC",          group=grpColor)
colorR       = input.color(color.red,    "Resistance",  group=grpColor)
colorS       = input.color(color.green,  "Support",     group=grpColor)
colorPDH     = input.color(color.orange, "PDH",         group=grpColor)
colorPDL     = input.color(color.orange, "PDL",         group=grpColor)
colorPDC     = input.color(color.purple, "PDC",         group=grpColor)
colorWeekly  = input.color(color.teal,   "Weekly CPR",  group=grpColor)
colorMonthly = input.color(color.maroon, "Monthly CPR", group=grpColor)

grpWidth = "CPR Width Analysis"
showInfoTable   = input.bool(false, "Show Today CPR Table",     group=grpWidth)
narrowThreshold = input.float(0.5, "Narrow Threshold (%)", group=grpWidth, step=0.1, display=display.none)
wideThreshold   = input.float(1.0, "Wide Threshold (%)", group=grpWidth, step=0.1, display=display.none)
tablePosition   = input.string("Top Right", "Table Position", group=grpWidth, options=["Top Left","Top Right","Bottom Left","Bottom Right"], display=display.none)
nextTablePos    = input.string("Top Left", "Tomorrow Table Position", group=grpWidth, options=["Top Left","Top Right","Bottom Left","Bottom Right"], display=display.none)

// ============================================================================
// LINE STYLE
// ============================================================================

lStyle = lineStyle == "Solid" ? line.style_solid : lineStyle == "Dashed" ? line.style_dashed : line.style_dotted

// ============================================================================
// FETCH PREVIOUS PERIOD H/L/C
// ============================================================================

[prevHigh, prevLow, prevClose]    = request.security(syminfo.tickerid, "D", [high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
[prevWHigh, prevWLow, prevWClose] = request.security(syminfo.tickerid, "W", [high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
[prevMHigh, prevMLow, prevMClose] = request.security(syminfo.tickerid, "M", [high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)

// Today's developing H/L/C for Tomorrow CPR calculation
[todayHigh, todayLow, todayClose] = request.security(syminfo.tickerid, "D", [high, low, close], lookahead=barmerge.lookahead_on)

// ============================================================================
// CPR & PIVOT CALCULATIONS
// ============================================================================

calcCPR(h, l, c) =>
    p    = (h + l + c) / 3
    bc   = (h + l) / 2
    tc   = (p - bc) + p
    topC = math.max(tc, bc)
    botC = math.min(tc, bc)
    [p, topC, botC]

calcPivots(h, l, c, p) =>
    r1 = (2 * p) - l
    s1 = (2 * p) - h
    r2 = p + (h - l)
    s2 = p - (h - l)
    r3 = h + 2 * (p - l)
    s3 = l - 2 * (h - p)
    r4 = r3 + (r2 - r1)
    s4 = s3 - (s1 - s2)
    [r1, r2, r3, r4, s1, s2, s3, s4]

[pivotD, tcD, bcD]                         = calcCPR(prevHigh, prevLow, prevClose)
[r1D, r2D, r3D, r4D, s1D, s2D, s3D, s4D]  = calcPivots(prevHigh, prevLow, prevClose, pivotD)
[pivotW, tcW, bcW]                         = calcCPR(prevWHigh, prevWLow, prevWClose)
[pivotM, tcM, bcM]                         = calcCPR(prevMHigh, prevMLow, prevMClose)
[nextPivot, nextTC, nextBC]                = calcCPR(todayHigh, todayLow, todayClose)

// ============================================================================
// DETECT NEW DAY
// ============================================================================

newDay = ta.change(time("D")) != 0
var int dayStartBar = 0

if newDay
    dayStartBar := bar_index

// ============================================================================
// CURRENT DAY LINES - one var line per level, redrawn each bar
// Stops exactly at current bar (endBar = bar_index, no extension)
// On new day, var lines reset to na so previous day lines stay on chart
// ============================================================================

var line lnP   = na
var line lnTC  = na
var line lnBC  = na
var line lnR1  = na
var line lnR2  = na
var line lnR3  = na
var line lnR4  = na
var line lnS1  = na
var line lnS2  = na
var line lnS3  = na
var line lnS4  = na
var line lnPDH = na
var line lnPDL = na
var line lnPDC = na
var line lnWP  = na
var line lnWTC = na
var line lnWBC = na
var line lnMP  = na
var line lnMTC = na
var line lnMBC = na

// Labels array
var label[] lbls = array.new<label>()

// Helper functions (must be at global scope)
delLn(l) =>
    if not na(l)
        line.delete(l)

pushLbl(_x, _y, _txt, _col, _show, _showPrice) =>
    if _show and not na(_y)
        t = _showPrice ? _txt + " " + str.tostring(_y, format.mintick) : _txt
        label.new(_x, _y, t, style=label.style_none, textcolor=_col, size=size.small, textalign=text.align_left)

// On new day: release previous lines (they stay on chart) and reset vars to na
if newDay
    lnP   := na
    lnTC  := na
    lnBC  := na
    lnR1  := na
    lnR2  := na
    lnR3  := na
    lnR4  := na
    lnS1  := na
    lnS2  := na
    lnS3  := na
    lnS4  := na
    lnPDH := na
    lnPDL := na
    lnPDC := na
    lnWP  := na
    lnWTC := na
    lnWBC := na
    lnMP  := na
    lnMTC := na
    lnMBC := na

// endBar = current bar only, never extends into future
endBar = bar_index

// Redraw current day lines on every bar
if showCPR
    delLn(lnP)
    lnP := line.new(dayStartBar, pivotD, endBar, pivotD, color=colorPivot, style=lStyle, width=cprLW)
    delLn(lnTC)
    lnTC := line.new(dayStartBar, tcD, endBar, tcD, color=colorTC, style=lStyle, width=cprLW)
    delLn(lnBC)
    lnBC := line.new(dayStartBar, bcD, endBar, bcD, color=colorBC, style=lStyle, width=cprLW)

if showR1
    delLn(lnR1)
    lnR1 := line.new(dayStartBar, r1D, endBar, r1D, color=colorR, style=lStyle, width=pivLW)
if showR2
    delLn(lnR2)
    lnR2 := line.new(dayStartBar, r2D, endBar, r2D, color=colorR, style=lStyle, width=pivLW)
if showR3
    delLn(lnR3)
    lnR3 := line.new(dayStartBar, r3D, endBar, r3D, color=colorR, style=lStyle, width=pivLW)
if showR4
    delLn(lnR4)
    lnR4 := line.new(dayStartBar, r4D, endBar, r4D, color=colorR, style=lStyle, width=pivLW)

if showS1
    delLn(lnS1)
    lnS1 := line.new(dayStartBar, s1D, endBar, s1D, color=colorS, style=lStyle, width=pivLW)
if showS2
    delLn(lnS2)
    lnS2 := line.new(dayStartBar, s2D, endBar, s2D, color=colorS, style=lStyle, width=pivLW)
if showS3
    delLn(lnS3)
    lnS3 := line.new(dayStartBar, s3D, endBar, s3D, color=colorS, style=lStyle, width=pivLW)
if showS4
    delLn(lnS4)
    lnS4 := line.new(dayStartBar, s4D, endBar, s4D, color=colorS, style=lStyle, width=pivLW)

if showPDH
    delLn(lnPDH)
    lnPDH := line.new(dayStartBar, prevHigh, endBar, prevHigh, color=colorPDH, style=lStyle, width=pivLW)
if showPDL
    delLn(lnPDL)
    lnPDL := line.new(dayStartBar, prevLow, endBar, prevLow, color=colorPDL, style=lStyle, width=pivLW)
if showPDC
    delLn(lnPDC)
    lnPDC := line.new(dayStartBar, prevClose, endBar, prevClose, color=colorPDC, style=lStyle, width=pivLW)

if showWeeklyCPR
    delLn(lnWP)
    lnWP := line.new(dayStartBar, pivotW, endBar, pivotW, color=colorWeekly, style=lStyle, width=cprLW)
    delLn(lnWTC)
    lnWTC := line.new(dayStartBar, tcW, endBar, tcW, color=colorWeekly, style=lStyle, width=cprLW)
    delLn(lnWBC)
    lnWBC := line.new(dayStartBar, bcW, endBar, bcW, color=colorWeekly, style=lStyle, width=cprLW)

if showMonthlyCPR
    delLn(lnMP)
    lnMP := line.new(dayStartBar, pivotM, endBar, pivotM, color=colorMonthly, style=lStyle, width=cprLW)
    delLn(lnMTC)
    lnMTC := line.new(dayStartBar, tcM, endBar, tcM, color=colorMonthly, style=lStyle, width=cprLW)
    delLn(lnMBC)
    lnMBC := line.new(dayStartBar, bcM, endBar, bcM, color=colorMonthly, style=lStyle, width=cprLW)

// ============================================================================
// TOMORROW CPR LINES - dashed, extend to the right from current bar
// ============================================================================

var line lnNP  = na
var line lnNTC = na
var line lnNBC = na

if barstate.islast
    delLn(lnNP)
    delLn(lnNTC)
    delLn(lnNBC)
    if showTomorrowCPR
        lnNP  := line.new(bar_index, nextPivot, bar_index + 50, nextPivot, color=colorNextP,  style=line.style_dashed, width=cprLW)
        lnNTC := line.new(bar_index, nextTC,    bar_index + 50, nextTC,    color=colorNextTC, style=line.style_dashed, width=cprLW)
        lnNBC := line.new(bar_index, nextBC,    bar_index + 50, nextBC,    color=colorNextBC, style=line.style_dashed, width=cprLW)

// ============================================================================
// LABELS - redrawn only on last bar
// ============================================================================

if barstate.islast and showLabels
    if array.size(lbls) > 0
        for i = 0 to array.size(lbls) - 1
            label.delete(array.get(lbls, i))
        array.clear(lbls)

    pushLbl(endBar, pivotD,    "P",   colorPivot,   showCPR,        showPrices)
    pushLbl(endBar, tcD,       "TC",  colorTC,      showCPR,        showPrices)
    pushLbl(endBar, bcD,       "BC",  colorBC,      showCPR,        showPrices)
    pushLbl(endBar, r1D,       "R1",  colorR,       showR1,         showPrices)
    pushLbl(endBar, r2D,       "R2",  colorR,       showR2,         showPrices)
    pushLbl(endBar, r3D,       "R3",  colorR,       showR3,         showPrices)
    pushLbl(endBar, r4D,       "R4",  colorR,       showR4,         showPrices)
    pushLbl(endBar, s1D,       "S1",  colorS,       showS1,         showPrices)
    pushLbl(endBar, s2D,       "S2",  colorS,       showS2,         showPrices)
    pushLbl(endBar, s3D,       "S3",  colorS,       showS3,         showPrices)
    pushLbl(endBar, s4D,       "S4",  colorS,       showS4,         showPrices)
    pushLbl(endBar, prevHigh,  "PDH", colorPDH,     showPDH,        showPrices)
    pushLbl(endBar, prevLow,   "PDL", colorPDL,     showPDL,        showPrices)
    pushLbl(endBar, prevClose, "PDC", colorPDC,     showPDC,        showPrices)
    pushLbl(endBar, pivotW,    "WP",  colorWeekly,  showWeeklyCPR,  showPrices)
    pushLbl(endBar, tcW,       "WTC", colorWeekly,  showWeeklyCPR,  showPrices)
    pushLbl(endBar, bcW,       "WBC", colorWeekly,  showWeeklyCPR,  showPrices)
    pushLbl(endBar, pivotM,    "MP",  colorMonthly, showMonthlyCPR, showPrices)
    pushLbl(endBar, tcM,       "MTC", colorMonthly, showMonthlyCPR, showPrices)
    pushLbl(endBar, bcM,       "MBC", colorMonthly, showMonthlyCPR, showPrices)
    if showTomorrowCPR
        pushLbl(bar_index + 50, nextPivot, "P",  colorNextP,  true, showPrices)
        pushLbl(bar_index + 50, nextTC,    "TC", colorNextTC, true, showPrices)
        pushLbl(bar_index + 50, nextBC,    "BC", colorNextBC, true, showPrices)

// ============================================================================
// TODAY CPR WIDTH ANALYSIS TABLE
// ============================================================================

cprWidthPct  = pivotD != 0 ? (math.abs(tcD - bcD) / pivotD) * 100 : 0.0
cprType      = cprWidthPct < narrowThreshold ? "NARROW (Trending)" : cprWidthPct > wideThreshold ? "WIDE (Sideways)" : "NORMAL"
cprTypeColor = cprWidthPct < narrowThreshold ? color.lime : cprWidthPct > wideThreshold ? color.red : color.yellow
tblPos       = tablePosition == "Top Left" ? position.top_left : tablePosition == "Top Right" ? position.top_right : tablePosition == "Bottom Left" ? position.bottom_left : position.bottom_right

var table todayTable = table.new(tblPos, 2, 6, border_width=1, frame_color=color.gray, frame_width=1)

if showInfoTable and barstate.islast
    table.cell(todayTable, 0, 0, "Today CPR",   bgcolor=color.new(color.blue, 70), text_color=color.white, text_size=size.small)
    table.cell(todayTable, 1, 0, "Value",        bgcolor=color.new(color.blue, 70), text_color=color.white, text_size=size.small)
    table.cell(todayTable, 0, 1, "Pivot",        text_color=color.white, text_size=size.small)
    table.cell(todayTable, 1, 1, str.tostring(pivotD, format.mintick),  text_color=colorPivot, text_size=size.small)
    table.cell(todayTable, 0, 2, "TC",           text_color=color.white, text_size=size.small)
    table.cell(todayTable, 1, 2, str.tostring(tcD, format.mintick),     text_color=colorTC,    text_size=size.small)
    table.cell(todayTable, 0, 3, "BC",           text_color=color.white, text_size=size.small)
    table.cell(todayTable, 1, 3, str.tostring(bcD, format.mintick),     text_color=colorBC,    text_size=size.small)
    table.cell(todayTable, 0, 4, "Width %",      text_color=color.white, text_size=size.small)
    table.cell(todayTable, 1, 4, str.tostring(cprWidthPct, "#.##") + "%", text_color=color.white, text_size=size.small)
    table.cell(todayTable, 0, 5, "Day Type",     text_color=color.white, text_size=size.small)
    table.cell(todayTable, 1, 5, cprType,        text_color=cprTypeColor, text_size=size.small)

// ============================================================================
// TOMORROW CPR TABLE
// ============================================================================

nextWidthPct  = nextPivot != 0 ? (math.abs(nextTC - nextBC) / nextPivot) * 100 : 0.0
nextType      = nextWidthPct < narrowThreshold ? "NARROW (Trending)" : nextWidthPct > wideThreshold ? "WIDE (Sideways)" : "NORMAL"
nextTypeColor = nextWidthPct < narrowThreshold ? color.lime : nextWidthPct > wideThreshold ? color.red : color.yellow
nTblPos       = nextTablePos == "Top Left" ? position.top_left : nextTablePos == "Top Right" ? position.top_right : nextTablePos == "Bottom Left" ? position.bottom_left : position.bottom_right

var table nextTable = table.new(nTblPos, 2, 6, border_width=1, frame_color=color.gray, frame_width=1)

if showNextTable and barstate.islast
    table.cell(nextTable, 0, 0, "Tomorrow CPR", bgcolor=color.new(color.teal, 60), text_color=color.white, text_size=size.small)
    table.cell(nextTable, 1, 0, "Value",         bgcolor=color.new(color.teal, 60), text_color=color.white, text_size=size.small)
    table.cell(nextTable, 0, 1, "Pivot",         text_color=color.white, text_size=size.small)
    table.cell(nextTable, 1, 1, str.tostring(nextPivot, format.mintick), text_color=colorNextP,  text_size=size.small)
    table.cell(nextTable, 0, 2, "TC",            text_color=color.white, text_size=size.small)
    table.cell(nextTable, 1, 2, str.tostring(nextTC, format.mintick),    text_color=colorNextTC, text_size=size.small)
    table.cell(nextTable, 0, 3, "BC",            text_color=color.white, text_size=size.small)
    table.cell(nextTable, 1, 3, str.tostring(nextBC, format.mintick),    text_color=colorNextBC, text_size=size.small)
    table.cell(nextTable, 0, 4, "Width %",       text_color=color.white, text_size=size.small)
    table.cell(nextTable, 1, 4, str.tostring(nextWidthPct, "#.##") + "%", text_color=color.white, text_size=size.small)
    table.cell(nextTable, 0, 5, "Day Type",      text_color=color.white, text_size=size.small)
    table.cell(nextTable, 1, 5, nextType,        text_color=nextTypeColor, text_size=size.small)

// ============================================================================
// ALERTS
// ============================================================================

alertcondition(ta.crossover(close, pivotD),  "Cross Above Pivot", "Price crossed above Daily Pivot")
alertcondition(ta.crossunder(close, pivotD), "Cross Below Pivot", "Price crossed below Daily Pivot")
alertcondition(ta.crossover(close, tcD),     "Cross Above TC",    "Price crossed above TC")
alertcondition(ta.crossunder(close, bcD),    "Cross Below BC",    "Price crossed below BC")
alertcondition(ta.crossover(close, r1D),     "Cross Above R1",    "Price crossed above R1")
alertcondition(ta.crossunder(close, s1D),    "Cross Below S1",    "Price crossed below S1")
````
