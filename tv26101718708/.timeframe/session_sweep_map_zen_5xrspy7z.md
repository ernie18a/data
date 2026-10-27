# Session Sweep Map [Zen] 

- url: https://www.tradingview.com/script/5XrSpy7Z-Session-Sweep-Map-Zen/
- type: indicator
- pine_id: PUB;fdcec32806de4b87a11380cbf2cfefa4
- version: 1.0

## Description

Session Sweep Map [Zen] marks the Asia, London and New York session highs and lows and shows which session took which pool.

HOW IT WORKS
Sessions are whole UTC hours: Asia 00-08, London 08-13, New York 13-21 (editable in settings). When a session ends, its high and low become two pools. The first later session that trades through a pool decides it:
- wick beyond the pool and close back at or inside it = SWEPT
- close beyond the pool = BROKEN
Each pool is counted once, for the first later session that touched it. A touch between sessions (21-24 UTC) takes the pool, but it is not counted or labelled; the table shows it as OFF.

WHAT YOU SEE
- Dotted lines: session highs (terracotta) and lows (blue), until the pool is taken.
- Labels: "LON swept AS high", "NY swept LON low". By default only London > Asia and NY > London are labelled; turn off that option to label all six pairs.
- Table, "Pools now": price of each pool, untouched / swept / broken, by which session, and the time (UTC).
- Table, "Swept / pool (history)": for each pair, how many highs (H) and lows (L) were swept. The table always counts all six pairs.
- Alerts: one alert condition, fires when a labelled sweep is confirmed.

TIMEFRAMES
1m to 1H (timeframes that divide an hour) use the chart candles. 2H, 3H and 4H read the 1H candles inside each bar; the table title shows "(1H bars)". On higher timeframes nothing is drawn and the table shows a notice.

GOOD TO KNOW
- Only closed candles are used. Labels and alerts appear when the chart candle closes, so on 2H-4H up to 3 hours after the event.
- The table counts what happened on the bars loaded on your chart, each pool once and only for the first later session that touched it. It describes the past and is not a forecast.
- Counts differ between timeframes: up to 1H the chart candles decide, on 2H-4H the 1H candles decide, and the loaded history length differs.
- This is a map of what already happened, not a trading signal.

## Source Code

````pine
//@version=6
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChartZenFX
indicator("Session Sweep Map [Zen]", overlay = true, max_labels_count = 200, max_lines_count = 100)

// ---------- Inputs ----------
gS = "Sessions (whole UTC hours)"
hA = input.int(0, "Asia starts", minval = 0, maxval = 22, group = gS, display = display.none, tooltip = "Whole UTC hours. Asia runs from its start to the London start, London to the New York start, New York to its end. The hours must increase in that order.")
hL = input.int(8, "London starts", minval = 1, maxval = 23, group = gS, display = display.none)
hN = input.int(13, "New York starts", minval = 2, maxval = 23, group = gS, display = display.none)
hE = input.int(21, "New York ends", minval = 3, maxval = 24, group = gS, display = display.none)

gV = "Display"
showLines  = input.bool(true, "Show session high / low lines", group = gV, display = display.none)
showLabels = input.bool(true, "Show sweep labels", group = gV, display = display.none)
classic    = input.bool(true, "Labels and alerts: only London > Asia and NY > London", group = gV, display = display.none, tooltip = "On: only these two sweeps are labelled and alerted. Off: all six pairs. The table always counts all six.")
tblPosIn   = input.string("Top right", "Table position", options = ["Top right", "Bottom right", "Bottom left", "Top left"], group = gV, display = display.none)

// ---------- ChartZenFX palette (auto light / dark) ----------
bool isLight = (color.r(chart.bg_color) + color.g(chart.bg_color) + color.b(chart.bg_color)) / 3 > 128
color cHI    = isLight ? #AD4A12 : #D9703A
color cLO    = isLight ? #1B46B4 : #6F88EE
color cMUTED = isLight ? #505C69 : #9AA3B2
color cTXT   = isLight ? #131722 : #D1D4DC
color cINK   = isLight ? #FFFFFF : #131722
color cBG    = isLight ? color.new(#FFFFFF, 8) : color.new(#131722, 8)
color cHEAD  = isLight ? color.new(#647482, 80) : color.new(#8391A4, 75)

tblPos = tblPosIn == "Top right" ? position.top_right : tblPosIn == "Bottom right" ? position.bottom_right : tblPosIn == "Bottom left" ? position.bottom_left : position.top_left

if barstate.isfirst and not (hA < hL and hL < hN and hN < hE)
    runtime.error("Session hours must increase: Asia start < London start < New York start < New York end.")

// ---------- Timeframe: up to 1H read directly (must divide the hour), 2H-4H (whole hours) read from 1H bars ----------
int tfs = timeframe.in_seconds()
bool tfOk = timeframe.isintraday and ((tfs <= 3600 and 3600 % tfs == 0) or (tfs > 3600 and tfs <= 14400 and tfs % 3600 == 0))
bool useLtf = tfOk and tfs > 3600
string ltfTf = useLtf ? "60" : timeframe.period
float[] ltfH = request.security_lower_tf(syminfo.tickerid, ltfTf, high, ignore_invalid_timeframe = true)
float[] ltfL = request.security_lower_tf(syminfo.tickerid, ltfTf, low, ignore_invalid_timeframe = true)
float[] ltfC = request.security_lower_tf(syminfo.tickerid, ltfTf, close, ignore_invalid_timeframe = true)
int[] ltfT = request.security_lower_tf(syminfo.tickerid, ltfTf, time, ignore_invalid_timeframe = true)
int nSub = 0
if tfOk
    if useLtf
        if not na(ltfT)
            nSub := ltfT.size()
    else
        nSub := 1

// ---------- State ----------
string[] nm = array.from("AS", "LON", "NY")
var int pc = -1
var float[] rHi = array.new_float(3, na)
var float[] rLo = array.new_float(3, na)
var float[] pHi = array.new_float(3, na)
var float[] pLo = array.new_float(3, na)
var bool[] doneH = array.new_bool(3, true)
var bool[] doneL = array.new_bool(3, true)
var line[] lnH = array.new<line>(3)
var line[] lnL = array.new<line>(3)
var int[] stH = array.new_int(3, 0)
var int[] stL = array.new_int(3, 0)
var int[] byH = array.new_int(3, -1)
var int[] byL = array.new_int(3, -1)
var int[] tmH = array.new_int(3, 0)
var int[] tmL = array.new_int(3, 0)
var int[] cntH = array.new_int(9, 0)
var int[] cntL = array.new_int(9, 0)
var table tbl = na

string msg = ""

// ---------- Closed candles only ----------
if barstate.isconfirmed and nSub > 0
    for k = 0 to nSub - 1
        float bh = high
        float bl = low
        float bc = close
        int bt = time
        if useLtf
            bh := ltfH.get(k)
            bl := ltfL.get(k)
            bc := ltfC.get(k)
            bt := ltfT.get(k)
        int hr = hour(bt, "UTC")
        int c = hr >= hA and hr < hL ? 0 : hr >= hL and hr < hN ? 1 : hr >= hN and hr < hE ? 2 : -1

        // a session just ended: its range becomes a pool
        if pc >= 0 and c != pc
            int s = pc
            pHi.set(s, rHi.get(s))
            pLo.set(s, rLo.get(s))
            doneH.set(s, false)
            doneL.set(s, false)
            stH.set(s, 0)
            stL.set(s, 0)
            if not na(lnH.get(s))
                line.delete(lnH.get(s))
            if not na(lnL.get(s))
                line.delete(lnL.get(s))
            if showLines
                lnH.set(s, line.new(bar_index, pHi.get(s), bar_index + 1, pHi.get(s), extend = extend.right, color = cHI, style = line.style_dotted, width = 1))
                lnL.set(s, line.new(bar_index, pLo.get(s), bar_index + 1, pLo.get(s), extend = extend.right, color = cLO, style = line.style_dotted, width = 1))

        if c >= 0
            // grow the current session range
            if c != pc
                rHi.set(c, bh)
                rLo.set(c, bl)
            else
                rHi.set(c, math.max(rHi.get(c), bh))
                rLo.set(c, math.min(rLo.get(c), bl))
            // first touch of another session's pool decides: wick + close back = sweep, close beyond = break
            for j = 0 to 2
                if j != c
                    bool pairOk = not classic or (c == 1 and j == 0) or (c == 2 and j == 1)
                    if not doneH.get(j) and bh > pHi.get(j)
                        doneH.set(j, true)
                        stH.set(j, bc <= pHi.get(j) ? 1 : 2)
                        byH.set(j, c)
                        tmH.set(j, bt)
                        if not na(lnH.get(j))
                            line.set_x2(lnH.get(j), bar_index)
                            line.set_extend(lnH.get(j), extend.none)
                        if bc <= pHi.get(j)
                            cntH.set(c * 3 + j, cntH.get(c * 3 + j) + 1)
                            if pairOk
                                string t = nm.get(c) + " swept " + nm.get(j) + " high"
                                msg += t + "\n"
                                if showLabels
                                    label.new(bar_index, bh, t, style = label.style_label_down, color = cHI, textcolor = cINK, size = size.tiny)
                    if not doneL.get(j) and bl < pLo.get(j)
                        doneL.set(j, true)
                        stL.set(j, bc >= pLo.get(j) ? 1 : 2)
                        byL.set(j, c)
                        tmL.set(j, bt)
                        if not na(lnL.get(j))
                            line.set_x2(lnL.get(j), bar_index)
                            line.set_extend(lnL.get(j), extend.none)
                        if bc >= pLo.get(j)
                            cntL.set(c * 3 + j, cntL.get(c * 3 + j) + 1)
                            if pairOk
                                string t = nm.get(c) + " swept " + nm.get(j) + " low"
                                msg += t + "\n"
                                if showLabels
                                    label.new(bar_index, bl, t, style = label.style_label_up, color = cLO, textcolor = cINK, size = size.tiny)
        else
            // between sessions: a touch still takes the pool, but nothing is counted or labelled
            for j = 0 to 2
                if not doneH.get(j) and bh > pHi.get(j)
                    doneH.set(j, true)
                    stH.set(j, bc <= pHi.get(j) ? 1 : 2)
                    byH.set(j, -1)
                    tmH.set(j, bt)
                    if not na(lnH.get(j))
                        line.set_x2(lnH.get(j), bar_index)
                        line.set_extend(lnH.get(j), extend.none)
                if not doneL.get(j) and bl < pLo.get(j)
                    doneL.set(j, true)
                    stL.set(j, bc >= pLo.get(j) ? 1 : 2)
                    byL.set(j, -1)
                    tmL.set(j, bt)
                    if not na(lnL.get(j))
                        line.set_x2(lnL.get(j), bar_index)
                        line.set_extend(lnL.get(j), extend.none)
        pc := c

// ---------- Alert ----------
if barstate.isconfirmed and msg != ""
    alert(msg + syminfo.ticker + " " + timeframe.period, alert.freq_once_per_bar_close)
alertcondition(msg != "", "Session sweep", "Session sweep on {{ticker}} {{interval}}")

// ---------- Table: pools now + who swept whose pool (loaded history) ----------
f_state(int stt, int whoIdx, int tmv) =>
    string who = whoIdx == -1 ? "OFF" : nm.get(whoIdx)
    stt == 0 ? "untouched" : (stt == 1 ? "swept " : "broken ") + who + " " + str.format_time(tmv, "HH:mm", "UTC")

if barstate.islast
    if not na(tbl)
        table.delete(tbl)
    tbl := table.new(tblPos, 4, 12, bgcolor = cBG, border_width = 0, frame_width = 0)
    table.cell(tbl, 0, 0, "SESSION SWEEP MAP · " + (tfOk ? timeframe.period + (useLtf ? " (1H bars)" : "") : "use 1m-1H, 2H, 3H or 4H"), text_color = cTXT, text_size = size.small, text_halign = text.align_left, bgcolor = cHEAD)
    table.merge_cells(tbl, 0, 0, 3, 0)
    table.cell(tbl, 0, 1, "Pools now (UTC)", text_color = cMUTED, text_size = size.tiny, text_halign = text.align_left)
    table.merge_cells(tbl, 0, 1, 3, 1)
    for s = 0 to 2
        bool has = not na(pHi.get(s))
        table.cell(tbl, 0, 2 + s * 2, nm.get(s) + " high", text_color = cHI, text_size = size.small, text_halign = text.align_left)
        table.cell(tbl, 1, 2 + s * 2, has ? str.tostring(pHi.get(s), format.mintick) : "-", text_color = cTXT, text_size = size.small, text_halign = text.align_right)
        table.cell(tbl, 2, 2 + s * 2, has ? f_state(stH.get(s), byH.get(s), tmH.get(s)) : "-", text_color = (has and stH.get(s) == 0) ? cMUTED : cTXT, text_size = size.small, text_halign = text.align_right)
        table.merge_cells(tbl, 2, 2 + s * 2, 3, 2 + s * 2)
        table.cell(tbl, 0, 3 + s * 2, nm.get(s) + " low", text_color = cLO, text_size = size.small, text_halign = text.align_left)
        table.cell(tbl, 1, 3 + s * 2, has ? str.tostring(pLo.get(s), format.mintick) : "-", text_color = cTXT, text_size = size.small, text_halign = text.align_right)
        table.cell(tbl, 2, 3 + s * 2, has ? f_state(stL.get(s), byL.get(s), tmL.get(s)) : "-", text_color = (has and stL.get(s) == 0) ? cMUTED : cTXT, text_size = size.small, text_halign = text.align_right)
        table.merge_cells(tbl, 2, 3 + s * 2, 3, 3 + s * 2)
    table.cell(tbl, 0, 8, "Swept / pool (history)", text_color = cMUTED, text_size = size.tiny, text_halign = text.align_left)
    for j = 0 to 2
        table.cell(tbl, j + 1, 8, nm.get(j), text_color = cMUTED, text_size = size.tiny, text_halign = text.align_right)
    for r = 0 to 2
        table.cell(tbl, 0, r + 9, nm.get(r), text_color = cTXT, text_size = size.small, text_halign = text.align_left)
        for j = 0 to 2
            string c = r == j ? "-" : "H" + str.tostring(cntH.get(r * 3 + j)) + " · L" + str.tostring(cntL.get(r * 3 + j))
            table.cell(tbl, j + 1, r + 9, c, text_color = r == j ? cMUTED : cTXT, text_size = size.small, text_halign = text.align_right)
````
