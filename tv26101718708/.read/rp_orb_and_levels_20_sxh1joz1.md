# RP ORB and Levels 2.0

- url: https://www.tradingview.com/script/SXH1Joz1-RP-ORB-and-Levels-2-0/
- type: indicator
- pine_id: PUB;c27d35f0a8ba4889871fbca3a50581e9
- version: 1.0

## Description

Improved changes to the first one, levels wont delete until session ends now

## Source Code

````pine
//@version=6
indicator("RP ORB and Levels", shorttitle="RP O&L", overlay=true, max_boxes_count=50, max_lines_count=500, max_labels_count=200)

rp_tz = input.string("America/New_York", "Session timezone", options=["America/New_York", "America/Chicago", "Etc/UTC"], display=display.none)
rp_maxTfMinutes = input.int(240, "Show drawings up to timeframe, minutes", minval=1, display=display.none)

rp_asianSession = input.session("1900-0400", "Asian session", display=display.none)
rp_asianExtendSession = input.session("0400-1130", "Asian level extension window", display=display.none)
rp_londonSession = input.session("0300-1200", "London session", display=display.none)
rp_nySession = input.session("0800-1700", "New York session", display=display.none)
rp_nyOrbSession = input.session("0800-0815", "NY first 15m ORB", display=display.none)

rp_showAsian = input.bool(true, "Fill Asian Range Color", group="Sessions", display=display.none)
rp_showLondon = input.bool(true, "Fill London Range Color", group="Sessions", display=display.none)
rp_showNY = input.bool(true, "Fill New York Range Color", group="Sessions", display=display.none)
rp_showAsianExt = input.bool(false, "Extend Asian high/low after session", group="Sessions", display=display.none)
rp_showNyOrb = input.bool(true, "Show NY First 15m ORB Rectangle", group="NY ORB", display=display.none)
rp_showNyOrbLabel = input.bool(true, "Show NY ORB point label", group="NY ORB", display=display.none)

rp_extendRightBars = input.int(500, "Forward extension bars for ORB box", minval=50, maxval=5000, group="Extensions", display=display.none)

rp_showVectors = input.bool(true, "Show Untested High/Low Vectors", group="Untested Levels", display=display.none)
rp_maxVectors = input.int(50, "Max untested vectors per side", minval=5, maxval=200, group="Untested Levels", display=display.none)
rp_hardBreakPts = input.float(5.0, "Hard invalidation points", minval=0.25, step=0.25, group="Untested Levels", display=display.none)
rp_vectorHighColor = input.color(color.black, "Untested high color", group="Untested Levels", display=display.none)
rp_vectorLowColor = input.color(#9FECEF, "Untested low color", group="Untested Levels", display=display.none)
rp_vectorWidth = input.int(2, "Vector width", minval=1, maxval=5, group="Untested Levels", display=display.none)

rp_asianFill = input.color(color.new(#7F1722, 70), "Asian color", group="Colors", display=display.none)
rp_londonFill = input.color(color.new(color.yellow, 69), "London color", group="Colors", display=display.none)
rp_nyFill = input.color(color.new(color.blue, 73), "New York color", group="Colors", display=display.none)
rp_nyOrbFill = input.color(color.new(#9DB9C4, 55), "NY ORB rectangle fill", group="NY ORB", display=display.none)
rp_nyOrbMidColor = input.color(color.black, "NY ORB midpoint color", group="NY ORB", display=display.none)
rp_nyOrbLabelColor = input.color(color.black, "NY ORB label color", group="NY ORB", display=display.none)
rp_asianLineColor = input.color(color.aqua, "Asian extended level color", group="Colors", display=display.none)

rp_showPD = input.bool(false, "Show previous day high / low", group="Prior levels", display=display.none)
rp_showPW = input.bool(false, "Show previous week high / low", group="Prior levels", display=display.none)
rp_showCW = input.bool(false, "Show current week high / low", group="Prior levels", display=display.none)

rp_pdColor = input.color(color.yellow, "Previous day color", group="Prior levels", display=display.none)
rp_pwColor = input.color(color.orange, "Previous week color", group="Prior levels", display=display.none)
rp_cwColor = input.color(color.olive, "Current week color", group="Prior levels", display=display.none)

rp_tfSec = timeframe.in_seconds(timeframe.period)
rp_validTf = timeframe.isintraday and rp_tfSec <= rp_maxTfMinutes * 60
rp_useLower15Arrays = rp_validTf and rp_tfSec > 900
rp_minBreakMs = 15 * 60 * 1000
rp_forwardMs = int(rp_tfSec * 1000 * rp_extendRightBars)
rp_rightEdge = time_close + rp_forwardMs

rp_aIn = rp_validTf and not na(time(timeframe.period, rp_asianSession, rp_tz))
rp_lIn = rp_validTf and not na(time(timeframe.period, rp_londonSession, rp_tz))
rp_nIn = rp_validTf and not na(time(timeframe.period, rp_nySession, rp_tz))

rp_aStart = rp_aIn and not rp_aIn[1]
rp_lStart = rp_lIn and not rp_lIn[1]
rp_nStart = rp_nIn and not rp_nIn[1]

rp_aEnd = not rp_aIn and rp_aIn[1]
rp_lEnd = not rp_lIn and rp_lIn[1]
rp_nEnd = not rp_nIn and rp_nIn[1]

rp_aExtendIn = rp_validTf and not na(time(timeframe.period, rp_asianExtendSession, rp_tz))

var float rp_aHigh = na
var float rp_aLow = na
var int rp_aHighTime = na
var int rp_aLowTime = na

var float rp_lHigh = na
var float rp_lLow = na
var int rp_lHighTime = na
var int rp_lLowTime = na
var bool rp_lVectorsLocked = false

var float rp_nHigh = na
var float rp_nLow = na
var int rp_nHighTime = na
var int rp_nLowTime = na

var box rp_orbBox = na
var line rp_orbMid = na
var label rp_orbLabel = na
var line rp_aExtHi = na
var line rp_aExtLo = na

rp_sessionNone = 0
rp_sessionAsia = 1
rp_sessionLondon = 2
rp_sessionNY = 3

var float[] rp_highLevels = array.new_float()
var line[] rp_highLines = array.new_line()
var int[] rp_highBreakStart = array.new_int()
var int[] rp_highSweepSession = array.new_int()

var float[] rp_lowLevels = array.new_float()
var line[] rp_lowLines = array.new_line()
var int[] rp_lowBreakStart = array.new_int()
var int[] rp_lowSweepSession = array.new_int()

f_sessionFromBooleans(_aIn, _lIn, _nIn) =>
    _nIn ? rp_sessionNY : _lIn ? rp_sessionLondon : _aIn ? rp_sessionAsia : rp_sessionNone

f_currentSweepSession() =>
    f_sessionFromBooleans(rp_aIn, rp_lIn, rp_nIn)

f_deleteHighIndex(_i) =>
    oldLine = array.get(rp_highLines, _i)
    line.delete(oldLine)
    array.remove(rp_highLines, _i)
    array.remove(rp_highLevels, _i)
    array.remove(rp_highBreakStart, _i)
    array.remove(rp_highSweepSession, _i)

f_deleteLowIndex(_i) =>
    oldLine = array.get(rp_lowLines, _i)
    line.delete(oldLine)
    array.remove(rp_lowLines, _i)
    array.remove(rp_lowLevels, _i)
    array.remove(rp_lowBreakStart, _i)
    array.remove(rp_lowSweepSession, _i)

f_markHighForSessionDelete(_i, _sessionId) =>
    if _sessionId == rp_sessionNone
        f_deleteHighIndex(_i)
    else
        array.set(rp_highSweepSession, _i, _sessionId)
        array.set(rp_highBreakStart, _i, na)
        _sessionId

f_markLowForSessionDelete(_i, _sessionId) =>
    if _sessionId == rp_sessionNone
        f_deleteLowIndex(_i)
    else
        array.set(rp_lowSweepSession, _i, _sessionId)
        array.set(rp_lowBreakStart, _i, na)
        _sessionId

f_deletePendingBySession(_sessionId) =>
    highSize = array.size(rp_highSweepSession)
    if highSize > 0
        for k = 0 to highSize - 1
            i = highSize - 1 - k
            if array.get(rp_highSweepSession, i) == _sessionId
                f_deleteHighIndex(i)

    lowSize = array.size(rp_lowSweepSession)
    if lowSize > 0
        for k = 0 to lowSize - 1
            i = lowSize - 1 - k
            if array.get(rp_lowSweepSession, i) == _sessionId
                f_deleteLowIndex(i)

f_addHighVector(_levelTime, _level) =>
    newLine = line.new(_levelTime, _level, rp_rightEdge, _level, xloc=xloc.bar_time, extend=extend.right, color=rp_vectorHighColor, width=rp_vectorWidth)
    array.push(rp_highLevels, _level)
    array.push(rp_highLines, newLine)
    array.push(rp_highBreakStart, na)
    array.push(rp_highSweepSession, rp_sessionNone)

f_addLowVector(_levelTime, _level) =>
    newLine = line.new(_levelTime, _level, rp_rightEdge, _level, xloc=xloc.bar_time, extend=extend.right, color=rp_vectorLowColor, width=rp_vectorWidth)
    array.push(rp_lowLevels, _level)
    array.push(rp_lowLines, newLine)
    array.push(rp_lowBreakStart, na)
    array.push(rp_lowSweepSession, rp_sessionNone)

f_rotateSweptHighs(_sessionHigh) =>
    swept = false
    highSize = array.size(rp_highLevels)
    if highSize > 0
        for k = 0 to highSize - 1
            i = highSize - 1 - k
            lvl = array.get(rp_highLevels, i)
            if _sessionHigh > lvl
                f_deleteHighIndex(i)
                swept := true
    swept

f_rotateSweptLows(_sessionLow) =>
    swept = false
    lowSize = array.size(rp_lowLevels)
    if lowSize > 0
        for k = 0 to lowSize - 1
            i = lowSize - 1 - k
            lvl = array.get(rp_lowLevels, i)
            if _sessionLow < lvl
                f_deleteLowIndex(i)
                swept := true
    swept

if not rp_useLower15Arrays
    if rp_aStart
        rp_aHigh := high
        rp_aLow := low
        rp_aHighTime := time
        rp_aLowTime := time
    else if rp_aIn
        if high > nz(rp_aHigh, high)
            rp_aHigh := high
            rp_aHighTime := time
        if low < nz(rp_aLow, low)
            rp_aLow := low
            rp_aLowTime := time

    if rp_lStart
        rp_lHigh := high
        rp_lLow := low
        rp_lHighTime := time
        rp_lLowTime := time
        rp_lVectorsLocked := false
    else if rp_lIn
        if high > nz(rp_lHigh, high)
            rp_lHigh := high
            rp_lHighTime := time
        if low < nz(rp_lLow, low)
            rp_lLow := low
            rp_lLowTime := time

    if rp_nStart
        rp_nHigh := high
        rp_nLow := low
        rp_nHighTime := time
        rp_nLowTime := time
    else if rp_nIn
        if high > nz(rp_nHigh, high)
            rp_nHigh := high
            rp_nHighTime := time
        if low < nz(rp_nLow, low)
            rp_nLow := low
            rp_nLowTime := time

    if rp_nEnd
        if not na(rp_orbBox)
            box.delete(rp_orbBox)
            rp_orbBox := na
        if not na(rp_orbMid)
            line.delete(rp_orbMid)
            rp_orbMid := na
        if not na(rp_orbLabel)
            label.delete(rp_orbLabel)
            rp_orbLabel := na

    if rp_aEnd
        f_deletePendingBySession(rp_sessionAsia)

    if rp_nStart
        f_deletePendingBySession(rp_sessionLondon)

    if rp_nEnd
        f_deletePendingBySession(rp_sessionNY)

    if rp_aEnd and rp_showVectors and not na(rp_aHigh) and not na(rp_aHighTime)
        f_rotateSweptHighs(rp_aHigh)
        f_addHighVector(rp_aHighTime, rp_aHigh)

    if rp_aEnd and rp_showVectors and not na(rp_aLow) and not na(rp_aLowTime)
        f_rotateSweptLows(rp_aLow)
        f_addLowVector(rp_aLowTime, rp_aLow)

    if rp_nStart and rp_lIn and rp_showVectors and not rp_lVectorsLocked
        if not na(rp_lHigh) and not na(rp_lHighTime)
            f_rotateSweptHighs(rp_lHigh)
            f_addHighVector(rp_lHighTime, rp_lHigh)

        if not na(rp_lLow) and not na(rp_lLowTime)
            f_rotateSweptLows(rp_lLow)
            f_addLowVector(rp_lLowTime, rp_lLow)

        rp_lVectorsLocked := true

    if rp_nEnd and rp_showVectors and not na(rp_nHigh) and not na(rp_nHighTime)
        f_rotateSweptHighs(rp_nHigh)
        f_addHighVector(rp_nHighTime, rp_nHigh)

    if rp_nEnd and rp_showVectors and not na(rp_nLow) and not na(rp_nLowTime)
        f_rotateSweptLows(rp_nLow)
        f_addLowVector(rp_nLowTime, rp_nLow)

while array.size(rp_highLevels) > rp_maxVectors
    f_deleteHighIndex(0)

while array.size(rp_lowLevels) > rp_maxVectors
    f_deleteLowIndex(0)

hardHighSize = array.size(rp_highLevels)
if rp_showVectors and not rp_useLower15Arrays and hardHighSize > 0
    currentSweepSession = f_currentSweepSession()
    for k = 0 to hardHighSize - 1
        i = hardHighSize - 1 - k
        lvl = array.get(rp_highLevels, i)
        pendingSession = array.get(rp_highSweepSession, i)
        if pendingSession == rp_sessionNone and high >= lvl + rp_hardBreakPts
            f_markHighForSessionDelete(i, currentSweepSession)

hardLowSize = array.size(rp_lowLevels)
if rp_showVectors and not rp_useLower15Arrays and hardLowSize > 0
    currentSweepSession = f_currentSweepSession()
    for k = 0 to hardLowSize - 1
        i = hardLowSize - 1 - k
        lvl = array.get(rp_lowLevels, i)
        pendingSession = array.get(rp_lowSweepSession, i)
        if pendingSession == rp_sessionNone and low <= lvl - rp_hardBreakPts
            f_markLowForSessionDelete(i, currentSweepSession)

rp_15TimeNow = request.security(syminfo.tickerid, "15", time, lookahead=barmerge.lookahead_off)
rp_15PrevTime = request.security(syminfo.tickerid, "15", time[1], lookahead=barmerge.lookahead_off)
rp_15PrevCloseTime = request.security(syminfo.tickerid, "15", time_close[1], lookahead=barmerge.lookahead_off)
rp_15PrevHigh = request.security(syminfo.tickerid, "15", high[1], lookahead=barmerge.lookahead_off)
rp_15PrevLow = request.security(syminfo.tickerid, "15", low[1], lookahead=barmerge.lookahead_off)
rp_15PrevClose = request.security(syminfo.tickerid, "15", close[1], lookahead=barmerge.lookahead_off)
rp_15PrevOrb = request.security(syminfo.tickerid, "15", not na(time("15", rp_nyOrbSession, rp_tz))[1], lookahead=barmerge.lookahead_off)
rp_15PrevAIn = request.security(syminfo.tickerid, "15", not na(time("15", rp_asianSession, rp_tz))[1], lookahead=barmerge.lookahead_off)
rp_15PrevLIn = request.security(syminfo.tickerid, "15", not na(time("15", rp_londonSession, rp_tz))[1], lookahead=barmerge.lookahead_off)
rp_15PrevNIn = request.security(syminfo.tickerid, "15", not na(time("15", rp_nySession, rp_tz))[1], lookahead=barmerge.lookahead_off)

rp_15TimeChange = ta.change(rp_15TimeNow)
rp_new15Closed = not rp_useLower15Arrays and rp_15TimeChange != 0

if rp_new15Closed and not na(rp_15PrevTime)
    sweepSession15 = f_sessionFromBooleans(rp_15PrevAIn, rp_15PrevLIn, rp_15PrevNIn)

    highSize = array.size(rp_highLevels)
    if rp_showVectors and highSize > 0
        for k = 0 to highSize - 1
            i = highSize - 1 - k
            lvl = array.get(rp_highLevels, i)
            started = array.get(rp_highBreakStart, i)

            pendingSession = array.get(rp_highSweepSession, i)

            if pendingSession == rp_sessionNone
                if rp_15PrevHigh >= lvl + rp_hardBreakPts
                    f_markHighForSessionDelete(i, sweepSession15)
                else if rp_15PrevClose > lvl and na(started)
                    array.set(rp_highBreakStart, i, rp_15PrevTime)
                else if rp_15PrevClose > lvl and not na(started) and rp_15PrevTime - started >= rp_minBreakMs
                    f_markHighForSessionDelete(i, sweepSession15)
                else if rp_15PrevClose <= lvl
                    array.set(rp_highBreakStart, i, na)

    lowSize = array.size(rp_lowLevels)
    if rp_showVectors and lowSize > 0
        for k = 0 to lowSize - 1
            i = lowSize - 1 - k
            lvl = array.get(rp_lowLevels, i)
            started = array.get(rp_lowBreakStart, i)

            pendingSession = array.get(rp_lowSweepSession, i)

            if pendingSession == rp_sessionNone
                if rp_15PrevLow <= lvl - rp_hardBreakPts
                    f_markLowForSessionDelete(i, sweepSession15)
                else if rp_15PrevClose < lvl and na(started)
                    array.set(rp_lowBreakStart, i, rp_15PrevTime)
                else if rp_15PrevClose < lvl and not na(started) and rp_15PrevTime - started >= rp_minBreakMs
                    f_markLowForSessionDelete(i, sweepSession15)
                else if rp_15PrevClose >= lvl
                    array.set(rp_lowBreakStart, i, na)

    if rp_15PrevOrb and rp_showNyOrb
        if not na(rp_orbBox)
            box.delete(rp_orbBox)
            rp_orbBox := na
        if not na(rp_orbMid)
            line.delete(rp_orbMid)
            rp_orbMid := na
        if not na(rp_orbLabel)
            label.delete(rp_orbLabel)
            rp_orbLabel := na

        orbMidPrice = math.avg(rp_15PrevHigh, rp_15PrevLow)
        orbHeight = rp_15PrevHigh - rp_15PrevLow
        labelPad = math.max(orbHeight * 1.25, syminfo.mintick * 20)

        londonMid = not na(rp_lHigh) and not na(rp_lLow) ? math.avg(rp_lHigh, rp_lLow) : orbMidPrice
        labelAboveLondon = orbMidPrice < londonMid
        labelY = labelAboveLondon and not na(rp_lHigh) ? rp_lHigh + labelPad : not na(rp_lLow) ? rp_lLow - labelPad : rp_15PrevLow - labelPad
        labelStyle = labelAboveLondon ? label.style_label_down : label.style_label_up

        orbText = "ORB = " + str.tostring(orbHeight, format.mintick) + " PTS"
        orbText := orbHeight <= 3 ? orbText + "\nWARNING: ORB IS EXTRA SMALL" : orbText
        orbText := orbHeight > 20 ? orbText + "\nWARNING: ORB IS TOO LARGE TO TRADE" : orbText

        rp_orbBox := box.new(left=rp_15PrevTime, top=rp_15PrevHigh, right=rp_rightEdge, bottom=rp_15PrevLow, xloc=xloc.bar_time, bgcolor=rp_nyOrbFill, border_color=color.black, border_width=2)
        rp_orbMid := line.new(x1=rp_15PrevTime, y1=orbMidPrice, x2=rp_rightEdge, y2=orbMidPrice, xloc=xloc.bar_time, extend=extend.right, color=rp_nyOrbMidColor, width=1, style=line.style_dashed)

        if rp_showNyOrbLabel
            rp_orbLabel := label.new(x=rp_15PrevCloseTime, y=labelY, text=orbText, xloc=xloc.bar_time, yloc=yloc.price, style=labelStyle, textcolor=rp_nyOrbLabelColor, color=color.new(color.black, 100), size=size.large)

rp_ltfTime = request.security_lower_tf(syminfo.tickerid, "15", time, ignore_invalid_timeframe=true)
rp_ltfCloseTime = request.security_lower_tf(syminfo.tickerid, "15", time_close, ignore_invalid_timeframe=true)
rp_ltfHigh = request.security_lower_tf(syminfo.tickerid, "15", high, ignore_invalid_timeframe=true)
rp_ltfLow = request.security_lower_tf(syminfo.tickerid, "15", low, ignore_invalid_timeframe=true)
rp_ltfClose = request.security_lower_tf(syminfo.tickerid, "15", close, ignore_invalid_timeframe=true)
rp_ltfOrb = request.security_lower_tf(syminfo.tickerid, "15", not na(time("15", rp_nyOrbSession, rp_tz)) ? 1 : 0, ignore_invalid_timeframe=true)
rp_ltfAIn = request.security_lower_tf(syminfo.tickerid, "15", not na(time("15", rp_asianSession, rp_tz)) ? 1 : 0, ignore_invalid_timeframe=true)
rp_ltfLIn = request.security_lower_tf(syminfo.tickerid, "15", not na(time("15", rp_londonSession, rp_tz)) ? 1 : 0, ignore_invalid_timeframe=true)
rp_ltfNIn = request.security_lower_tf(syminfo.tickerid, "15", not na(time("15", rp_nySession, rp_tz)) ? 1 : 0, ignore_invalid_timeframe=true)

var int rp_lastProcessed15 = na
var bool rp_ltfPrevAIn = false
var bool rp_ltfPrevLIn = false
var bool rp_ltfPrevNIn = false

if rp_validTf and rp_useLower15Arrays and array.size(rp_ltfTime) > 0
    for j = 0 to array.size(rp_ltfTime) - 1
        t15 = array.get(rp_ltfTime, j)

        if na(rp_lastProcessed15) or t15 > rp_lastProcessed15
            h15 = array.get(rp_ltfHigh, j)
            l15 = array.get(rp_ltfLow, j)
            c15 = array.get(rp_ltfClose, j)
            tc15 = array.get(rp_ltfCloseTime, j)
            orb15 = array.get(rp_ltfOrb, j) == 1

            aIn15 = array.get(rp_ltfAIn, j) == 1
            lIn15 = array.get(rp_ltfLIn, j) == 1
            nIn15 = array.get(rp_ltfNIn, j) == 1
            sweepSession15 = f_sessionFromBooleans(aIn15, lIn15, nIn15)

            aStart15 = aIn15 and not rp_ltfPrevAIn
            lStart15 = lIn15 and not rp_ltfPrevLIn
            nStart15 = nIn15 and not rp_ltfPrevNIn

            aEnd15 = not aIn15 and rp_ltfPrevAIn
            lEnd15 = not lIn15 and rp_ltfPrevLIn
            nEnd15 = not nIn15 and rp_ltfPrevNIn

            if aStart15
                rp_aHigh := h15
                rp_aLow := l15
                rp_aHighTime := t15
                rp_aLowTime := t15
            else if aIn15
                if h15 > nz(rp_aHigh, h15)
                    rp_aHigh := h15
                    rp_aHighTime := t15
                if l15 < nz(rp_aLow, l15)
                    rp_aLow := l15
                    rp_aLowTime := t15

            if lStart15
                rp_lHigh := h15
                rp_lLow := l15
                rp_lHighTime := t15
                rp_lLowTime := t15
                rp_lVectorsLocked := false
            else if lIn15
                if h15 > nz(rp_lHigh, h15)
                    rp_lHigh := h15
                    rp_lHighTime := t15
                if l15 < nz(rp_lLow, l15)
                    rp_lLow := l15
                    rp_lLowTime := t15

            if nStart15
                rp_nHigh := h15
                rp_nLow := l15
                rp_nHighTime := t15
                rp_nLowTime := t15
            else if nIn15
                if h15 > nz(rp_nHigh, h15)
                    rp_nHigh := h15
                    rp_nHighTime := t15
                if l15 < nz(rp_nLow, l15)
                    rp_nLow := l15
                    rp_nLowTime := t15

            if nEnd15
                if not na(rp_orbBox)
                    box.delete(rp_orbBox)
                    rp_orbBox := na
                if not na(rp_orbMid)
                    line.delete(rp_orbMid)
                    rp_orbMid := na
                if not na(rp_orbLabel)
                    label.delete(rp_orbLabel)
                    rp_orbLabel := na

            if aEnd15
                f_deletePendingBySession(rp_sessionAsia)

            if nStart15
                f_deletePendingBySession(rp_sessionLondon)

            if nEnd15
                f_deletePendingBySession(rp_sessionNY)

            if aEnd15 and rp_showVectors and not na(rp_aHigh) and not na(rp_aHighTime)
                f_rotateSweptHighs(rp_aHigh)
                f_addHighVector(rp_aHighTime, rp_aHigh)

            if aEnd15 and rp_showVectors and not na(rp_aLow) and not na(rp_aLowTime)
                f_rotateSweptLows(rp_aLow)
                f_addLowVector(rp_aLowTime, rp_aLow)

            if nStart15 and lIn15 and rp_showVectors and not rp_lVectorsLocked
                if not na(rp_lHigh) and not na(rp_lHighTime)
                    f_rotateSweptHighs(rp_lHigh)
                    f_addHighVector(rp_lHighTime, rp_lHigh)

                if not na(rp_lLow) and not na(rp_lLowTime)
                    f_rotateSweptLows(rp_lLow)
                    f_addLowVector(rp_lLowTime, rp_lLow)

                rp_lVectorsLocked := true

            if nEnd15 and rp_showVectors and not na(rp_nHigh) and not na(rp_nHighTime)
                f_rotateSweptHighs(rp_nHigh)
                f_addHighVector(rp_nHighTime, rp_nHigh)

            if nEnd15 and rp_showVectors and not na(rp_nLow) and not na(rp_nLowTime)
                f_rotateSweptLows(rp_nLow)
                f_addLowVector(rp_nLowTime, rp_nLow)

            highSize = array.size(rp_highLevels)
            if rp_showVectors and highSize > 0
                for k = 0 to highSize - 1
                    i = highSize - 1 - k
                    lvl = array.get(rp_highLevels, i)
                    started = array.get(rp_highBreakStart, i)

                    pendingSession = array.get(rp_highSweepSession, i)

                    if pendingSession == rp_sessionNone
                        if h15 >= lvl + rp_hardBreakPts
                            f_markHighForSessionDelete(i, sweepSession15)
                        else if c15 > lvl and na(started)
                            array.set(rp_highBreakStart, i, t15)
                        else if c15 > lvl and not na(started) and t15 - started >= rp_minBreakMs
                            f_markHighForSessionDelete(i, sweepSession15)
                        else if c15 <= lvl
                            array.set(rp_highBreakStart, i, na)

            lowSize = array.size(rp_lowLevels)
            if rp_showVectors and lowSize > 0
                for k = 0 to lowSize - 1
                    i = lowSize - 1 - k
                    lvl = array.get(rp_lowLevels, i)
                    started = array.get(rp_lowBreakStart, i)

                    pendingSession = array.get(rp_lowSweepSession, i)

                    if pendingSession == rp_sessionNone
                        if l15 <= lvl - rp_hardBreakPts
                            f_markLowForSessionDelete(i, sweepSession15)
                        else if c15 < lvl and na(started)
                            array.set(rp_lowBreakStart, i, t15)
                        else if c15 < lvl and not na(started) and t15 - started >= rp_minBreakMs
                            f_markLowForSessionDelete(i, sweepSession15)
                        else if c15 >= lvl
                            array.set(rp_lowBreakStart, i, na)

            if orb15 and rp_showNyOrb
                if not na(rp_orbBox)
                    box.delete(rp_orbBox)
                    rp_orbBox := na
                if not na(rp_orbMid)
                    line.delete(rp_orbMid)
                    rp_orbMid := na
                if not na(rp_orbLabel)
                    label.delete(rp_orbLabel)
                    rp_orbLabel := na

                orbMidPrice = math.avg(h15, l15)
                orbHeight = h15 - l15
                labelPad = math.max(orbHeight * 1.25, syminfo.mintick * 20)

                londonMid = not na(rp_lHigh) and not na(rp_lLow) ? math.avg(rp_lHigh, rp_lLow) : orbMidPrice
                labelAboveLondon = orbMidPrice < londonMid
                labelY = labelAboveLondon and not na(rp_lHigh) ? rp_lHigh + labelPad : not na(rp_lLow) ? rp_lLow - labelPad : l15 - labelPad
                labelStyle = labelAboveLondon ? label.style_label_down : label.style_label_up

                orbText = "ORB = " + str.tostring(orbHeight, format.mintick) + " PTS"
                orbText := orbHeight <= 3 ? orbText + "\nWARNING: ORB IS EXTRA SMALL" : orbText
                orbText := orbHeight > 20 ? orbText + "\nWARNING: ORB IS TOO LARGE TO TRADE" : orbText

                rp_orbBox := box.new(left=t15, top=h15, right=rp_rightEdge, bottom=l15, xloc=xloc.bar_time, bgcolor=rp_nyOrbFill, border_color=color.black, border_width=2)
                rp_orbMid := line.new(x1=t15, y1=orbMidPrice, x2=rp_rightEdge, y2=orbMidPrice, xloc=xloc.bar_time, extend=extend.right, color=rp_nyOrbMidColor, width=1, style=line.style_dashed)

                if rp_showNyOrbLabel
                    rp_orbLabel := label.new(x=tc15, y=labelY, text=orbText, xloc=xloc.bar_time, yloc=yloc.price, style=labelStyle, textcolor=rp_nyOrbLabelColor, color=color.new(color.black, 100), size=size.large)

            rp_ltfPrevAIn := aIn15
            rp_ltfPrevLIn := lIn15
            rp_ltfPrevNIn := nIn15
            rp_lastProcessed15 := t15

if rp_validTf
    if not na(rp_orbBox)
        box.set_right(rp_orbBox, rp_rightEdge)

    if not na(rp_orbMid)
        line.set_x2(rp_orbMid, rp_rightEdge)
        line.set_extend(rp_orbMid, extend.right)

    highLineCount = array.size(rp_highLines)
    if rp_showVectors and highLineCount > 0
        for i = 0 to highLineCount - 1
            ln = array.get(rp_highLines, i)
            line.set_x2(ln, rp_rightEdge)
            line.set_extend(ln, extend.right)

    lowLineCount = array.size(rp_lowLines)
    if rp_showVectors and lowLineCount > 0
        for i = 0 to lowLineCount - 1
            ln = array.get(rp_lowLines, i)
            line.set_x2(ln, rp_rightEdge)
            line.set_extend(ln, extend.right)

if rp_aEnd and rp_showAsianExt and not na(rp_aHigh) and not na(rp_aLow)
    line.delete(rp_aExtHi)
    line.delete(rp_aExtLo)
    rp_aExtHi := line.new(time, rp_aHigh, time, rp_aHigh, xloc=xloc.bar_time, color=rp_asianLineColor, width=1)
    rp_aExtLo := line.new(time, rp_aLow, time, rp_aLow, xloc=xloc.bar_time, color=rp_asianLineColor, width=1)

if rp_aExtendIn and not rp_aIn and rp_showAsianExt and not na(rp_aExtHi) and not na(rp_aExtLo)
    line.set_x2(rp_aExtHi, time)
    line.set_x2(rp_aExtLo, time)

rp_aTopPlot = plot(rp_showAsian and rp_aIn ? rp_aHigh : na, "Asian running high", color=color.new(color.white, 100), display=display.none)
rp_aBotPlot = plot(rp_showAsian and rp_aIn ? rp_aLow : na, "Asian running low", color=color.new(color.white, 100), display=display.none)
fill(rp_aTopPlot, rp_aBotPlot, color=rp_asianFill, title="Asian range fill")

rp_lTopPlot = plot(rp_showLondon and rp_lIn ? rp_lHigh : na, "London running high", color=color.new(color.white, 100), display=display.none)
rp_lBotPlot = plot(rp_showLondon and rp_lIn ? rp_lLow : na, "London running low", color=color.new(color.white, 100), display=display.none)
fill(rp_lTopPlot, rp_lBotPlot, color=rp_londonFill, title="London range fill")

rp_nTopPlot = plot(rp_showNY and rp_nIn ? rp_nHigh : na, "New York running high", color=color.new(color.white, 100), display=display.none)
rp_nBotPlot = plot(rp_showNY and rp_nIn ? rp_nLow : na, "New York running low", color=color.new(color.white, 100), display=display.none)
fill(rp_nTopPlot, rp_nBotPlot, color=rp_nyFill, title="New York range fill")

rp_pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_off)
rp_pdl = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_off)
rp_pwh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_off)
rp_pwl = request.security(syminfo.tickerid, "W", low[1], lookahead=barmerge.lookahead_off)
rp_cwh = request.security(syminfo.tickerid, "W", high, lookahead=barmerge.lookahead_off)
rp_cwl = request.security(syminfo.tickerid, "W", low, lookahead=barmerge.lookahead_off)

plot(rp_showPD ? rp_pdh : na, "PDH", color=rp_pdColor, linewidth=1, style=plot.style_linebr)
plot(rp_showPD ? rp_pdl : na, "PDL", color=rp_pdColor, linewidth=1, style=plot.style_linebr)
plot(rp_showPW ? rp_pwh : na, "PWH", color=rp_pwColor, linewidth=1, style=plot.style_linebr)
plot(rp_showPW ? rp_pwl : na, "PWL", color=rp_pwColor, linewidth=1, style=plot.style_linebr)
plot(rp_showCW ? rp_cwh : na, "WH", color=color.new(rp_cwColor, 25), linewidth=1, style=plot.style_linebr)
plot(rp_showCW ? rp_cwl : na, "WL", color=color.new(rp_cwColor, 25), linewidth=1, style=plot.style_linebr)
````
