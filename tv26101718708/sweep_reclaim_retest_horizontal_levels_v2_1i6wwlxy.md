# Sweep Reclaim Retest [Horizontal Levels v2]

- url: https://www.tradingview.com/script/1I6wwLXy-Sweep-Reclaim-Retest-Horizontal-Levels-v2/
- type: indicator
- pine_id: PUB;42c1411773ca4bbab845e7e3692f99d6
- version: 1.0

## Description

The script is a TradingView Pine indicator called Sweep Reclaim Retest [Horizontal Levels v2].
It is designed to find liquidity sweep + reclaim + retest setups around important horizontal levels, especially:
PDH: Previous Day High
PDL: Previous Day Low
PMH: Premarket High
PML: Premarket Low
Swing High
Swing Low
The main improvement is that these levels are drawn using real Pine line objects, so PDH/PDL stay truly horizontal instead of connecting from one value to the next with angled plot lines.
How it works:
It calculates important levels:
Previous day high/low from the daily timeframe.
Premarket high/low from the premarket session.
Swing highs/lows using pivot detection.

It watches for sweeps:
A bullish sweep happens when price dips below a level, then closes back above it.
A bearish sweep happens when price pushes above a level, then closes back below it.

It waits for a retest:
After a sweep/reclaim, the script waits for price to come back to the level.
If price retests and confirms, it gives a signal.

It filters signals:
Optional HTF bias filter using EMA.
Optional candle body confirmation.
Optional break of prior candle high/low.
Optional mid-range filter to avoid trades near the middle of the previous day’s range.

It displays:
Horizontal level lines.
Sweep markers.
CALL / PUT signal markers.
A small info table showing ticker, bias, session status, pending setups, PDH/PDL, PMH/PML, and HTF EMA.

## Source Code

````pine
//@version=6
indicator("Sweep Reclaim Retest [Horizontal Levels v2]", shorttitle="SRT HL v2", overlay=true, max_labels_count=100, max_lines_count=500)

// Inputs
groupBias   = "Bias"
groupSess   = "Sessions"
groupLevels = "Levels"
groupRules  = "Rules"
groupVisual = "Visuals"

htfTf         = input.timeframe("30", "HTF Bias Timeframe", group=groupBias)
emaLen        = input.int(21, "HTF EMA Length", minval=1, group=groupBias)
useBias       = input.bool(true, "Use HTF Bias Filter", group=groupBias)

tz            = input.string("America/New_York", "Session Time Zone", group=groupSess)
session1      = input.session("0935-1100", "Morning Session", group=groupSess)
session2      = input.session("1400-1530", "Afternoon Session", group=groupSess)
premarketSess = input.session("0400-0929", "Premarket Session", group=groupSess)

swingLen      = input.int(10, "Swing Lookback", minval=2, maxval=50, group=groupLevels)

sweepBufPct   = input.float(0.05, "Sweep Buffer %", minval=0.0, step=0.01, group=groupRules)
retestPct     = input.float(0.15, "Retest Tolerance %", minval=0.0, step=0.01, group=groupRules)
invalidatePct = input.float(0.30, "Invalidation %", minval=0.0, step=0.05, group=groupRules)
maxBarsWait   = input.int(20, "Max Bars After Sweep", minval=1, group=groupRules)
requireBody   = input.bool(true, "Require Directional Candle Body", group=groupRules)
requireBreak  = input.bool(false, "Require Break of Prior Bar High/Low", group=groupRules)
useMidFilter  = input.bool(true, "Use Mid-Range Filter", group=groupRules)
midZonePct    = input.float(15.0, "Mid-Range Width %", minval=1, maxval=49, step=1, group=groupRules)

showLines          = input.bool(true, "Show Horizontal Levels", group=groupVisual)
extendCurrentLines = input.bool(true, "Extend Active Levels Right", group=groupVisual)
keepOldLines       = input.bool(false, "Keep Prior Level Segments", group=groupVisual)
levelLineWidth     = input.int(2, "Level Line Width", minval=1, maxval=5, group=groupVisual)
showBg             = input.bool(true, "Show Bias Background", group=groupVisual)
showSweeps         = input.bool(true, "Show Sweep Markers", group=groupVisual)
showTable          = input.bool(true, "Show Info Table", group=groupVisual)

colPDH        = input.color(color.red, "Prev Day High Color", group=groupVisual)
colPDL        = input.color(color.green, "Prev Day Low Color", group=groupVisual)
colPMH        = input.color(color.orange, "Premarket High Color", group=groupVisual)
colPML        = input.color(color.blue, "Premarket Low Color", group=groupVisual)
colSWH        = input.color(color.fuchsia, "Swing High Color", group=groupVisual)
colSWL        = input.color(color.aqua, "Swing Low Color", group=groupVisual)

// Session logic
inPM   = not na(time(timeframe.period, premarketSess, tz))
inS1   = not na(time(timeframe.period, session1, tz))
inS2   = not na(time(timeframe.period, session2, tz))
inSess = inS1 or inS2

pmStart = inPM and (barstate.isfirst or not inPM[1])
pmEnd   = not inPM and not barstate.isfirst and inPM[1]
newDay  = timeframe.change("D")

// HTF bias. Uses HTF close vs HTF EMA.
htfClose = request.security(syminfo.tickerid, htfTf, close, lookahead=barmerge.lookahead_off)
htfEma   = request.security(syminfo.tickerid, htfTf, ta.ema(close, emaLen), lookahead=barmerge.lookahead_off)

biasBull = htfClose > htfEma
biasBear = htfClose < htfEma

// Previous day levels. These values are fixed for the current trading day.
pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_off)
pdl = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_off)

// Mid-range filter. Reject setups around the middle of previous day's range.
pdRange = pdh - pdl
pdMid   = (pdh + pdl) / 2.0
midBand = pdRange * midZonePct / 100.0

inMidZone(level) =>
    not na(level) and not na(pdRange) and pdRange > 0 and math.abs(level - pdMid) < midBand

// Premarket levels. The final PM high/low lock after premarket ends.
var float pmRunHigh = na
var float pmRunLow  = na
var float pmHigh    = na
var float pmLow     = na

if pmStart
    pmRunHigh := high
    pmRunLow  := low
    pmHigh    := na
    pmLow     := na
else if inPM
    pmRunHigh := math.max(pmRunHigh, high)
    pmRunLow  := math.min(pmRunLow, low)

if pmEnd
    pmHigh := pmRunHigh
    pmLow  := pmRunLow

// Swing levels. Pivot-based, so they appear after confirmation.
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

var float swingHigh = na
var float swingLow  = na

if not na(ph)
    swingHigh := ph
if not na(pl)
    swingLow := pl

// Helper functions
pctOfLevel(level, pct) =>
    math.abs(level) * pct / 100.0

bullSweepReclaim(level) =>
    buf = pctOfLevel(level, sweepBufPct)
    not na(level) and low < (level - buf) and close > (level + buf)

bearSweepReclaim(level) =>
    buf = pctOfLevel(level, sweepBufPct)
    not na(level) and high > (level + buf) and close < (level - buf)

f_newLevelLine(level, lineColor) =>
    line.new(
         bar_index,
         level,
         bar_index + 1,
         level,
         xloc=xloc.bar_index,
         extend=extendCurrentLines ? extend.right : extend.none,
         color=lineColor,
         width=levelLineWidth)

f_updateLevelLine(id, level) =>
    if not na(id) and not na(level)
        line.set_y1(id, level)
        line.set_y2(id, level)
        line.set_x2(id, bar_index + 1)
        line.set_extend(id, extendCurrentLines ? extend.right : extend.none)

f_closeLevelLine(id) =>
    if not na(id)
        line.set_extend(id, extend.none)
        line.set_x2(id, bar_index)

f_removeOrCloseLine(id) =>
    if not na(id)
        if keepOldLines
            f_closeLevelLine(id)
        else
            line.delete(id)

// Pending state
var bool   pendingBull      = false
var float  pendingBullLevel = na
var string pendingBullType  = ""
var int    pendingBullBar   = na

var bool   pendingBear      = false
var float  pendingBearLevel = na
var string pendingBearType  = ""
var int    pendingBearBar   = na

bool bullSignal = false
bool bearSignal = false
string sigBullType = ""
string sigBearType = ""

// Expire stale pending setups.
if pendingBull and not na(pendingBullBar) and (bar_index - pendingBullBar > maxBarsWait)
    pendingBull      := false
    pendingBullLevel := na
    pendingBullType  := ""
    pendingBullBar   := na

if pendingBear and not na(pendingBearBar) and (bar_index - pendingBearBar > maxBarsWait)
    pendingBear      := false
    pendingBearLevel := na
    pendingBearType  := ""
    pendingBearBar   := na

// Invalidate broken pending setups.
if pendingBull and not na(pendingBullLevel)
    bullInvalid = pctOfLevel(pendingBullLevel, invalidatePct)
    if close < (pendingBullLevel - bullInvalid)
        pendingBull      := false
        pendingBullLevel := na
        pendingBullType  := ""
        pendingBullBar   := na

if pendingBear and not na(pendingBearLevel)
    bearInvalid = pctOfLevel(pendingBearLevel, invalidatePct)
    if close > (pendingBearLevel + bearInvalid)
        pendingBear      := false
        pendingBearLevel := na
        pendingBearType  := ""
        pendingBearBar   := na

// Arm pending setups when sweep + reclaim happens.
// Priority: previous day -> premarket -> swing.
if inSess
    if not pendingBull
        if bullSweepReclaim(pdl)
            pendingBull      := true
            pendingBullLevel := pdl
            pendingBullType  := "PDL"
            pendingBullBar   := bar_index
        else if bullSweepReclaim(pmLow)
            pendingBull      := true
            pendingBullLevel := pmLow
            pendingBullType  := "PML"
            pendingBullBar   := bar_index
        else if bullSweepReclaim(swingLow)
            pendingBull      := true
            pendingBullLevel := swingLow
            pendingBullType  := "SWL"
            pendingBullBar   := bar_index

    if not pendingBear
        if bearSweepReclaim(pdh)
            pendingBear      := true
            pendingBearLevel := pdh
            pendingBearType  := "PDH"
            pendingBearBar   := bar_index
        else if bearSweepReclaim(pmHigh)
            pendingBear      := true
            pendingBearLevel := pmHigh
            pendingBearType  := "PMH"
            pendingBearBar   := bar_index
        else if bearSweepReclaim(swingHigh)
            pendingBear      := true
            pendingBearLevel := swingHigh
            pendingBearType  := "SWH"
            pendingBearBar   := bar_index

// Retest confirmation. Must happen after the sweep bar.
if pendingBull and not na(pendingBullLevel) and inSess and not na(pendingBullBar) and bar_index > pendingBullBar
    tol         = pctOfLevel(pendingBullLevel, retestPct)
    touched     = low <= pendingBullLevel + tol
    closedAbove = close > pendingBullLevel
    candleOK    = not requireBody or close > open
    breakOK     = not requireBreak or high > high[1]
    midOK       = not useMidFilter or not inMidZone(pendingBullLevel)

    if touched and closedAbove and candleOK and breakOK and midOK
        bullSignal       := true
        sigBullType      := pendingBullType
        pendingBull      := false
        pendingBullLevel := na
        pendingBullType  := ""
        pendingBullBar   := na

if pendingBear and not na(pendingBearLevel) and inSess and not na(pendingBearBar) and bar_index > pendingBearBar
    tol         = pctOfLevel(pendingBearLevel, retestPct)
    touched     = high >= pendingBearLevel - tol
    closedBelow = close < pendingBearLevel
    candleOK    = not requireBody or close < open
    breakOK     = not requireBreak or low < low[1]
    midOK       = not useMidFilter or not inMidZone(pendingBearLevel)

    if touched and closedBelow and candleOK and breakOK and midOK
        bearSignal       := true
        sigBearType      := pendingBearType
        pendingBear      := false
        pendingBearLevel := na
        pendingBearType  := ""
        pendingBearBar   := na

// Apply HTF bias filter.
finalBull = bullSignal and (not useBias or biasBull)
finalBear = bearSignal and (not useBias or biasBear)

// Horizontal level line objects.
// These are real lines, not plotted series, so they never slope between level changes.
var line pdhLine = na
var line pdlLine = na
var line pmhLine = na
var line pmlLine = na
var line swhLine = na
var line swlLine = na

var float pdhLineLevel = na
var float pdlLineLevel = na
var float pmhLineLevel = na
var float pmlLineLevel = na
var float swhLineLevel = na
var float swlLineLevel = na

if showLines
    if not na(pdh) and (na(pdhLine) or newDay or na(pdhLineLevel) or pdhLineLevel != pdh)
        f_removeOrCloseLine(pdhLine)
        pdhLine := f_newLevelLine(pdh, colPDH)
        pdhLineLevel := pdh
    else
        f_updateLevelLine(pdhLine, pdhLineLevel)

    if not na(pdl) and (na(pdlLine) or newDay or na(pdlLineLevel) or pdlLineLevel != pdl)
        f_removeOrCloseLine(pdlLine)
        pdlLine := f_newLevelLine(pdl, colPDL)
        pdlLineLevel := pdl
    else
        f_updateLevelLine(pdlLine, pdlLineLevel)

    if pmStart
        f_removeOrCloseLine(pmhLine)
        f_removeOrCloseLine(pmlLine)
        pmhLine := na
        pmlLine := na
        pmhLineLevel := na
        pmlLineLevel := na

    if not na(pmHigh) and (na(pmhLine) or pmEnd or na(pmhLineLevel) or pmhLineLevel != pmHigh)
        f_removeOrCloseLine(pmhLine)
        pmhLine := f_newLevelLine(pmHigh, colPMH)
        pmhLineLevel := pmHigh
    else
        f_updateLevelLine(pmhLine, pmhLineLevel)

    if not na(pmLow) and (na(pmlLine) or pmEnd or na(pmlLineLevel) or pmlLineLevel != pmLow)
        f_removeOrCloseLine(pmlLine)
        pmlLine := f_newLevelLine(pmLow, colPML)
        pmlLineLevel := pmLow
    else
        f_updateLevelLine(pmlLine, pmlLineLevel)

    if not na(swingHigh) and (na(swhLine) or na(swhLineLevel) or swhLineLevel != swingHigh)
        f_removeOrCloseLine(swhLine)
        swhLine := f_newLevelLine(swingHigh, colSWH)
        swhLineLevel := swingHigh
    else
        f_updateLevelLine(swhLine, swhLineLevel)

    if not na(swingLow) and (na(swlLine) or na(swlLineLevel) or swlLineLevel != swingLow)
        f_removeOrCloseLine(swlLine)
        swlLine := f_newLevelLine(swingLow, colSWL)
        swlLineLevel := swingLow
    else
        f_updateLevelLine(swlLine, swlLineLevel)

// Background shading
bgcolor(showBg and inSess and biasBull ? color.new(color.green, 92) : na, title="Bull Bias Background")
bgcolor(showBg and inSess and biasBear ? color.new(color.red, 92) : na, title="Bear Bias Background")

// Sweep markers
bullSweepNow = inSess and (bullSweepReclaim(pdl) or bullSweepReclaim(pmLow) or bullSweepReclaim(swingLow))
bearSweepNow = inSess and (bearSweepReclaim(pdh) or bearSweepReclaim(pmHigh) or bearSweepReclaim(swingHigh))

plotshape(showSweeps and bullSweepNow, title="Bull Sweep", style=shape.xcross, location=location.belowbar, color=color.new(color.green, 45), size=size.tiny)
plotshape(showSweeps and bearSweepNow, title="Bear Sweep", style=shape.xcross, location=location.abovebar, color=color.new(color.red, 45), size=size.tiny)

// Final entry markers
plotshape(finalBull, title="CALL Signal", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.normal, text="CALL")
plotshape(finalBear, title="PUT Signal", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.normal, text="PUT")

if finalBull
    label.new(bar_index, low, "CALL\n" + sigBullType, style=label.style_label_up, color=color.green, textcolor=color.white)

if finalBear
    label.new(bar_index, high, "PUT\n" + sigBearType, style=label.style_label_down, color=color.red, textcolor=color.white)

// Info table
var table tbl = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 75), frame_color=color.new(color.gray, 70), frame_width=1)

if showTable and barstate.islast
    biasText  = biasBull ? "BULL" : biasBear ? "BEAR" : "NEUTRAL"
    biasColor = biasBull ? color.lime : biasBear ? color.red : color.yellow

    bullRemain = pendingBull and not na(pendingBullBar) ? str.tostring(math.max(0, maxBarsWait - (bar_index - pendingBullBar))) : "-"
    bearRemain = pendingBear and not na(pendingBearBar) ? str.tostring(math.max(0, maxBarsWait - (bar_index - pendingBearBar))) : "-"

    table.cell(tbl, 0, 0, "Ticker", text_color=color.white)
    table.cell(tbl, 1, 0, syminfo.ticker, text_color=color.white)

    table.cell(tbl, 0, 1, "Bias", text_color=color.white)
    table.cell(tbl, 1, 1, biasText, text_color=biasColor)

    table.cell(tbl, 0, 2, "Session", text_color=color.white)
    table.cell(tbl, 1, 2, inSess ? "OPEN" : "CLOSED", text_color=inSess ? color.lime : color.orange)

    table.cell(tbl, 0, 3, "Bull Pending", text_color=color.white)
    table.cell(tbl, 1, 3, pendingBull ? pendingBullType + " (" + bullRemain + ")" : "-", text_color=color.yellow)

    table.cell(tbl, 0, 4, "Bear Pending", text_color=color.white)
    table.cell(tbl, 1, 4, pendingBear ? pendingBearType + " (" + bearRemain + ")" : "-", text_color=color.yellow)

    table.cell(tbl, 0, 5, "PDH/PDL", text_color=color.white)
    table.cell(tbl, 1, 5, str.tostring(pdh, "#.00") + " / " + str.tostring(pdl, "#.00"), text_color=color.white)

    table.cell(tbl, 0, 6, "PMH/PML", text_color=color.white)
    table.cell(tbl, 1, 6, (not na(pmHigh) ? str.tostring(pmHigh, "#.00") : "-") + " / " + (not na(pmLow) ? str.tostring(pmLow, "#.00") : "-"), text_color=color.white)

    table.cell(tbl, 0, 7, "HTF EMA", text_color=color.white)
    table.cell(tbl, 1, 7, str.tostring(htfEma, "#.00"), text_color=color.white)

// Alerts
alertcondition(finalBull, title="CALL - Sweep Reclaim Retest", message="{{ticker}} bullish CALL setup confirmed")
alertcondition(finalBear, title="PUT - Sweep Reclaim Retest", message="{{ticker}} bearish PUT setup confirmed")
````
