<!-- tradingview-pine-id: PUB;a83b98c961ea4e40befa4fd8067c35ea -->
<!-- tradingviewscripts-format: 1 -->
# IB + OR Developing Lines Dashboard

Source: https://www.tradingview.com/script/0pAa3Ve3-IB-OR-Developing-Lines-Dashboard/

## Description

IB + OR Dashboard

Plots the Opening Range and Initial Balance for the session, with quarter levels through the IB and a small table showing the size of each range in points.

The problem it solves

Most OR/IB scripts build their levels from chart bars, which breaks the moment your OR length doesn't divide evenly into your chart timeframe. A 15-minute Opening Range on a 2-minute chart is the obvious case: the bar that opens at 9:44 runs through 9:46, so the script either swallows an extra minute of price that isn't part of the range, or drops the last minute entirely. Either way the level you're trading off is wrong, and it doesn't print until 9:46 — a full minute after the range actually closed.

This one pulls lower-timeframe data and checks every sub-bar against the real cutoff timestamp. The straddling bar only contributes the part that belongs inside the window. The levels also lock the moment the cutoff passes instead of waiting for the chart bar to finish, so a 15-minute OR prints at 9:45 like it should.

If the intrabar resolution isn't lower than your chart timeframe, it falls back to chart-bar logic instead of erroring out. A "Source" row in the dashboard tells you which mode is running.

Settings

Session window and timezone
OR duration (default 15 min) and IB duration (default 60 min)
Intrabar resolution — 1 minute is enough for a 15-minute OR
Toggles for OR lines, IB lines, and IB quarter levels
Colors, widths, and line styles for each group
Dashboard position, or turn it off

---

## Source Code

````pine
//@version=6
indicator("IB + OR Developing Lines Dashboard", overlay=true, max_lines_count=500, max_labels_count=200)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupSess   = "Session Settings"
groupIB     = "Initial Balance"
groupOR     = "Opening Range"
groupDash   = "Dashboard"
groupStyle  = "Style"

sessionTZ   = input.string("America/New_York", "Session Timezone", group=groupSess)
tradeSess   = input.session("0930-1600", "Main Session", group=groupSess)

preciseMode = input.bool(true, "Precise Mode (intrabar data)", group=groupSess,
     tooltip="Builds the OR and IB from lower-timeframe bars, so the levels are exact even when the chart timeframe doesn't divide evenly into the OR/IB length (15-min OR on a 2-min chart, for example). Also locks the levels at the true cutoff time instead of waiting for the chart bar that straddles it to close.")
ltfRes      = input.timeframe("1", "Intrabar Resolution", group=groupSess,
     tooltip="Must be LOWER than the chart timeframe. 1 minute is plenty for a 15-min OR. If it isn't lower, the script falls back to chart bars automatically.")

ibMinutes   = input.int(60, "IB Duration (minutes)", minval=1, group=groupIB)
showIBLvls  = input.bool(true, "Show IB Levels", group=groupIB)
showIBInner = input.bool(true, "Show IB Quarter Levels", group=groupIB)

orMinutes   = input.int(15, "Opening Range Duration (minutes)", minval=1, group=groupOR)
showORLines = input.bool(true, "Show OR High/Low Lines", group=groupOR)

showDash    = input.bool(true, "Show Dashboard", group=groupDash)
dashPos     = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupDash)

ibLineColor     = input.color(color.blue, "IB Outer Line Color", group=groupStyle)
ibInnerColor    = input.color(color.white, "IB Internal Line Color", group=groupStyle)
orLineColor     = input.color(color.orange, "OR Line Color", group=groupStyle)

ibLineWidth     = input.int(2, "IB Outer Line Width", minval=1, maxval=4, group=groupStyle)
ibInnerWidth    = input.int(1, "IB Internal Line Width", minval=1, maxval=4, group=groupStyle)
orLineWidth     = input.int(2, "OR Line Width", minval=1, maxval=4, group=groupStyle)

ibLineStyleOpt  = input.string("Solid", "IB Outer Line Style", options=["Solid", "Dashed", "Dotted"], group=groupStyle)
ibInnerStyleOpt = input.string("Dotted", "IB Internal Line Style", options=["Solid", "Dashed", "Dotted"], group=groupStyle)
orLineStyleOpt  = input.string("Dashed", "OR Line Style", options=["Solid", "Dashed", "Dotted"], group=groupStyle)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LINE STYLE CONVERSION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ibLineStyle =
     ibLineStyleOpt == "Solid"  ? line.style_solid :
     ibLineStyleOpt == "Dashed" ? line.style_dashed :
                                  line.style_dotted

ibInnerStyle =
     ibInnerStyleOpt == "Solid"  ? line.style_solid :
     ibInnerStyleOpt == "Dashed" ? line.style_dashed :
                                   line.style_dotted

orLineStyle =
     orLineStyleOpt == "Solid"  ? line.style_solid :
     orLineStyleOpt == "Dashed" ? line.style_dashed :
                                  line.style_dotted

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INTRABAR DATA
// Pulls the highs/lows/open-times of every lower-timeframe bar contained in the
// current chart bar. If ltfRes isn't lower than the chart timeframe the request
// returns empty arrays instead of throwing, and we fall back to chart bars.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ltfUse = preciseMode ? ltfRes : timeframe.period

[ltfHighArr, ltfLowArr, ltfTimeArr] = request.security_lower_tf(
     syminfo.tickerid, ltfUse, [high, low, time], ignore_invalid_timeframe = true)

ltfCount = array.size(ltfTimeArr)
haveLTF  = ltfCount > 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SESSION LOGIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
inSession  = not na(time(timeframe.period, tradeSess, sessionTZ))
newSession = inSession and not inSession[1]
endSession = not inSession and inSession[1]

var int sessStartTime = na
var int sessStartBar  = na
var int orEndTime     = na
var int ibEndTime     = na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STATE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float ibHigh = na
var float ibLow  = na
var float orHigh = na
var float orLow  = na

var bool orLocked = false
var bool ibLocked = false

var line ibHighLine = na
var line ibLowLine  = na
var line ib25Line   = na
var line ib50Line   = na
var line ib75Line   = na

var line orHighLine = na
var line orLowLine  = na

var int ibLockedBar = na
var int orLockedBar = na

var string dataSrc = "chart bars"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RESET ON NEW SESSION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if newSession
    sessStartTime := time
    sessStartBar  := bar_index
    orEndTime     := sessStartTime + orMinutes * 60000
    ibEndTime     := sessStartTime + ibMinutes * 60000

    orHigh := na
    orLow  := na
    ibHigh := na
    ibLow  := na

    orLocked := false
    ibLocked := false

    ibHighLine := na
    ibLowLine  := na
    ib25Line   := na
    ib50Line   := na
    ib75Line   := na

    orHighLine  := na
    orLowLine   := na
    ibLockedBar := na
    orLockedBar := na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ACCUMULATE OR / IB
// Every candidate high/low is tested against the true cutoff timestamp, so a
// chart bar that straddles the cutoff only contributes the part that belongs.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
orDataDone = false
ibDataDone = false

if inSession and not na(sessStartTime)
    if haveLTF
        dataSrc := ltfUse + " intrabar"
        for i = 0 to ltfCount - 1
            tSub = array.get(ltfTimeArr, i)
            hSub = array.get(ltfHighArr, i)
            lSub = array.get(ltfLowArr,  i)

            if tSub >= sessStartTime and tSub < orEndTime
                orHigh := na(orHigh) ? hSub : math.max(orHigh, hSub)
                orLow  := na(orLow)  ? lSub : math.min(orLow,  lSub)

            if tSub >= sessStartTime and tSub < ibEndTime
                ibHigh := na(ibHigh) ? hSub : math.max(ibHigh, hSub)
                ibLow  := na(ibLow)  ? lSub : math.min(ibLow,  lSub)

        // Once a sub-bar has opened at or after the cutoff, everything before it
        // is final — lock immediately rather than waiting for the chart bar close.
        lastSubTime = array.get(ltfTimeArr, ltfCount - 1)
        orDataDone := lastSubTime >= orEndTime
        ibDataDone := lastSubTime >= ibEndTime
    else
        dataSrc := "chart bars"
        if time < orEndTime
            orHigh := na(orHigh) ? high : math.max(orHigh, high)
            orLow  := na(orLow)  ? low  : math.min(orLow,  low)
        if time < ibEndTime
            ibHigh := na(ibHigh) ? high : math.max(ibHigh, high)
            ibLow  := na(ibLow)  ? low  : math.min(ibLow,  low)

        orDataDone := time >= orEndTime
        ibDataDone := time >= ibEndTime

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAW OR ONCE COMPLETE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if orDataDone and not orLocked
    orLocked    := true
    orLockedBar := bar_index

    if showORLines
        if not na(orHigh)
            orHighLine := line.new(sessStartBar, orHigh, bar_index, orHigh,
                 color=orLineColor, width=orLineWidth, style=orLineStyle,
                 extend=extend.right)
        if not na(orLow)
            orLowLine := line.new(sessStartBar, orLow, bar_index, orLow,
                 color=orLineColor, width=orLineWidth, style=orLineStyle,
                 extend=extend.right)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAW IB ONCE COMPLETE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if ibDataDone and not ibLocked
    ibLocked    := true
    ibLockedBar := bar_index

    if showIBLvls and not na(ibHigh) and not na(ibLow)
        ibRangeFinal = ibHigh - ibLow
        ib25Final    = ibLow + ibRangeFinal * 0.25
        ib50Final    = ibLow + ibRangeFinal * 0.50
        ib75Final    = ibLow + ibRangeFinal * 0.75

        ibHighLine := line.new(sessStartBar, ibHigh, bar_index, ibHigh,
             color=ibLineColor, width=ibLineWidth, style=ibLineStyle,
             extend=extend.right)
        ibLowLine  := line.new(sessStartBar, ibLow, bar_index, ibLow,
             color=ibLineColor, width=ibLineWidth, style=ibLineStyle,
             extend=extend.right)

        if showIBInner
            ib25Line := line.new(sessStartBar, ib25Final, bar_index, ib25Final,
                 color=ibInnerColor, width=ibInnerWidth, style=ibInnerStyle,
                 extend=extend.right)
            ib50Line := line.new(sessStartBar, ib50Final, bar_index, ib50Final,
                 color=ibInnerColor, width=ibInnerWidth, style=ibInnerStyle,
                 extend=extend.right)
            ib75Line := line.new(sessStartBar, ib75Final, bar_index, ib75Final,
                 color=ibInnerColor, width=ibInnerWidth, style=ibInnerStyle,
                 extend=extend.right)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STOP EXTENDING AT SESSION END
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if endSession
    if not na(orHighLine)
        line.set_extend(orHighLine, extend.none)
        line.set_x2(orHighLine, bar_index)
    if not na(orLowLine)
        line.set_extend(orLowLine, extend.none)
        line.set_x2(orLowLine, bar_index)

    if not na(ibHighLine)
        line.set_extend(ibHighLine, extend.none)
        line.set_x2(ibHighLine, bar_index)
    if not na(ibLowLine)
        line.set_extend(ibLowLine, extend.none)
        line.set_x2(ibLowLine, bar_index)
    if not na(ib25Line)
        line.set_extend(ib25Line, extend.none)
        line.set_x2(ib25Line, bar_index)
    if not na(ib50Line)
        line.set_extend(ib50Line, extend.none)
        line.set_x2(ib50Line, bar_index)
    if not na(ib75Line)
        line.set_extend(ib75Line, extend.none)
        line.set_x2(ib75Line, bar_index)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
tablePos =
     dashPos == "Top Right"    ? position.top_right :
     dashPos == "Top Left"     ? position.top_left :
     dashPos == "Bottom Right" ? position.bottom_right :
                                 position.bottom_left

var table dash = table.new(tablePos, 2, 4, border_width=1)

ibSizePoints = not na(ibHigh) and not na(ibLow) ? ibHigh - ibLow : na
orSizePoints = not na(orHigh) and not na(orLow) ? orHigh - orLow : na

if barstate.islast
    if showDash
        table.cell(dash, 0, 0, "Range", text_color=color.white, bgcolor=color.new(color.black, 0))
        table.cell(dash, 1, 0, "Points", text_color=color.white, bgcolor=color.new(color.black, 0))

        table.cell(dash, 0, 1, "Opening Range", text_color=color.white, bgcolor=color.new(color.orange, 70))
        table.cell(dash, 1, 1, na(orSizePoints) ? "n/a" : str.tostring(orSizePoints, format.mintick), text_color=color.white, bgcolor=color.new(color.orange, 70))

        table.cell(dash, 0, 2, "IB", text_color=color.white, bgcolor=color.new(color.blue, 70))
        table.cell(dash, 1, 2, na(ibSizePoints) ? "n/a" : str.tostring(ibSizePoints, format.mintick), text_color=color.white, bgcolor=color.new(color.blue, 70))

        table.cell(dash, 0, 3, "Source", text_color=color.silver, bgcolor=color.new(color.black, 0), text_size=size.small)
        table.cell(dash, 1, 3, dataSrc, text_color=color.silver, bgcolor=color.new(color.black, 0), text_size=size.small)
    else
        table.clear(dash, 0, 0, 1, 3)
````
