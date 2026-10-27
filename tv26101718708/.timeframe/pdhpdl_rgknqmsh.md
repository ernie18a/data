# PDH/PDL

- url: https://www.tradingview.com/script/RGKnQMsh-PDH-PDL/
- type: indicator
- pine_id: PUB;c106164c50794575a36067eeccfce45c
- version: 2.0

## Description

Horizontal rays that auto-update and map out the previous day high and previous day low.

## Source Code

````pine
//@version=6
indicator("PDH/PDL", overlay=true, max_labels_count=10)

// ── Ray / text style ─────────────────────────────────────────────────
lineCol    = input.color(color.white, "Ray colour",  group="Rays")
w          = input.int(1, "Width", minval=1, maxval=5, group="Rays")
txtCol     = input.color(color.gray, "Text colour",  group="Rays")
showText   = input.bool(true, "Show text",           group="Rays")
extendLeft = input.bool(false, "Extend Left",        group="Rays")

// ── Rollover snap toggle ─────────────────────────────────────────────
snapOut = input.bool(true, "Snap PDH/PDL outside rollover/market-open", group="Rollover snap")

ext      = extendLeft ? extend.both : extend.right
rightOff = 10

// ── Session 1 — Midweek rollover (HARDCODED: New York 5–6pm, Sun–Fri) ─
s1Tz   = "America/New_York"
s1Sess = "1700-1800:123456"

// intrabar resolution used to locate the day's high/low timing (hardcoded)
intraTF = "1"   // 1-minute intrabars

// ── session test (tz + time window + days) ───────────────────────────
f_inSession(int ts, string tz, string sess) =>
    parts  = str.split(sess, ":")
    tr     = str.split(array.get(parts, 0), "-")
    sStr   = array.get(tr, 0)
    eStr   = array.get(tr, 1)
    sMOD   = int(str.tonumber(str.substring(sStr, 0, 2))) * 60 + int(str.tonumber(str.substring(sStr, 2, 4)))
    eMOD   = int(str.tonumber(str.substring(eStr, 0, 2))) * 60 + int(str.tonumber(str.substring(eStr, 2, 4)))
    days   = array.size(parts) > 1 ? array.get(parts, 1) : "1234567"
    fMOD   = hour(ts, tz) * 60 + minute(ts, tz)
    dow    = dayofweek(ts, tz)
    inTime = eMOD > sMOD ? (fMOD >= sMOD and fMOD < eMOD) : (fMOD >= sMOD or fMOD < eMOD)
    inDay  = str.contains(days, str.tostring(dow))
    not na(ts) and inTime and inDay

// ── weekend gap detection + week-start window ────────────────────────
gapMs = 24 * 60 * 60 * 1000
isWeekGap = not na(time) and not na(time[1]) and (time - time[1]) > gapMs
var int weekOpenTime = na
if isWeekGap
    weekOpenTime := time
f_inWeekStart(int ts) =>
    not na(ts) and not na(weekOpenTime) and ts >= weekOpenTime and ts < weekOpenTime + 60 * 60 * 1000

// a timestamp is "in window" if it's in the rollover session or the week start
f_inWin(int ts) => f_inSession(ts, s1Tz, s1Sess) or f_inWeekStart(ts)

// ── intrabar data for the CURRENT chart bar (safe on low TFs) ────────
intraT = request.security_lower_tf(syminfo.tickerid, intraTF, time, ignore_invalid_timeframe = true)
intraH = request.security_lower_tf(syminfo.tickerid, intraTF, high, ignore_invalid_timeframe = true)
intraL = request.security_lower_tf(syminfo.tickerid, intraTF, low,  ignore_invalid_timeframe = true)

// ── per-day accumulation (raw high/low, in-window flags, out-of-window high/low) ─
var float cdH   = na   // current day raw high
var float cdHex = na   // current day high, excluding window
var bool  cdHwin= false // was the raw high made in window?
var float cdL   = na
var float cdLex = na
var bool  cdLwin= false

var float pdH   = na   // previous day equivalents (what the rays use)
var float pdHex = na
var bool  pdHwin= false
var float pdL   = na
var float pdLex = na
var bool  pdLwin= false

newDay = ta.change(time("D")) != 0

// roll the just-completed day into "previous day", then reset the current day
if newDay
    pdH := cdH
    pdHex := cdHex
    pdHwin := cdHwin
    pdL := cdL
    pdLex := cdLex
    pdLwin := cdLwin
    cdH := na
    cdHex := na
    cdHwin := false
    cdL := na
    cdLex := na
    cdLwin := false

// accumulate this bar's intrabars into the current day
int sz = array.size(intraT)
if sz > 0
    for i = 0 to sz - 1
        int t = array.get(intraT, i)
        float h = array.get(intraH, i)
        float l = array.get(intraL, i)
        bool win = f_inWin(t)
        if not na(h)
            if na(cdH) or h > cdH
                cdH := h
                cdHwin := win
            if not win and (na(cdHex) or h > cdHex)
                cdHex := h
        if not na(l)
            if na(cdL) or l < cdL
                cdL := l
                cdLwin := win
            if not win and (na(cdLex) or l < cdLex)
                cdLex := l
else
    // fallback (chart TF <= intraTF): treat the chart bar as a single intrabar
    bool win = f_inWin(time)
    if na(cdH) or high > cdH
        cdH := high
        cdHwin := win
    if not win and (na(cdHex) or high > cdHex)
        cdHex := high
    if na(cdL) or low < cdL
        cdL := low
        cdLwin := win
    if not win and (na(cdLex) or low < cdLex)
        cdLex := low

// ── raw previous-day H/L fallback (full history, in case intrabars are missing) ─
[secPdh, secPdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead = barmerge.lookahead_on)

rawPdh = not na(pdH) ? pdH : secPdh
rawPdl = not na(pdL) ? pdL : secPdl

// snap each level out of the window only if that level was made in the window
pdhFinal = (snapOut and pdHwin and not na(pdHex)) ? pdHex : rawPdh
pdlFinal = (snapOut and pdLwin and not na(pdLex)) ? pdLex : rawPdl

gap = (pdhFinal - pdlFinal) * 0.01    // text gap above the line

// ── Track where the previous day started (anchor for the rays) ───────
var int prevDayStart = na
var int curDayStart  = na
if newDay
    prevDayStart := curDayStart
    curDayStart  := bar_index

anchor = na(prevDayStart) ? bar_index : prevDayStart

var line  pdhLine = na
var line  pdlLine = na
var label pdhLab  = na
var label pdlLab  = na

if barstate.islast and not na(pdhFinal)
    line.delete(pdhLine), line.delete(pdlLine)
    label.delete(pdhLab), label.delete(pdlLab)

    pdhLine := line.new(anchor, pdhFinal, bar_index, pdhFinal, extend = ext, color = lineCol, width = w)
    pdlLine := line.new(anchor, pdlFinal, bar_index, pdlFinal, extend = ext, color = lineCol, width = w)

    if showText
        pdhLab := label.new(bar_index + rightOff, pdhFinal + gap, "PDH", style = label.style_none, textcolor = txtCol, size = size.small)
        pdlLab := label.new(bar_index + rightOff, pdlFinal + gap, "PDL", style = label.style_none, textcolor = txtCol, size = size.small)
````
