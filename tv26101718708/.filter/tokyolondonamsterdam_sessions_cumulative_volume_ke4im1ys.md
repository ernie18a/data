# Tokyo/London/Amsterdam Sessions + Cumulative Volume

- url: https://www.tradingview.com/script/kE4IM1Ys-Tokyo-London-Amsterdam-Sessions-Cumulative-Volume/
- type: indicator
- pine_id: PUB;56c0271e181e4fd386ebd697834db620
- version: 3.0

## Description

Vertical session lines for the Tokyo, London, and Amsterdam exchange opens and closes — DST-aware, color-coded per city, with non-overlapping tiered labels. Includes a configurable cumulative volume tracker that resets at calendar midnight, the CME globex session, or a custom window in any timezone.

## Source Code

````pine
//@version=5
indicator("Tokyo/London/Amsterdam Sessions + Overnight Volume History", overlay=true, max_lines_count=500, max_labels_count=500)

// ============================================================
// INPUTS
// ============================================================
grpSess = "Sessions"
showTokyo     = input.bool(true, "Tokyo",     group=grpSess, inline="t")
showLondon    = input.bool(true, "London",    group=grpSess, inline="l")
showAmsterdam = input.bool(true, "Amsterdam", group=grpSess, inline="a")
tokyoCol      = input.color(color.new(#00BCD4, 40), "", group=grpSess, inline="t")
londonCol     = input.color(color.new(#FF9800, 40), "", group=grpSess, inline="l")
amsterdamCol  = input.color(color.new(#9C27B0, 40), "", group=grpSess, inline="a")

grpStyle = "Style"
showLabels    = input.bool(true, "Show Labels", group=grpStyle)
showOpens     = input.bool(true, "Show Opens",  group=grpStyle, inline="o")
showCloses    = input.bool(true, "Show Closes", group=grpStyle, inline="o")
lineWidth     = input.int(1, "Line Width", minval=1, maxval=3, group=grpStyle)
openStyleStr  = input.string("dotted", "Open Line Style",  options=["solid","dashed","dotted"], group=grpStyle)
closeStyleStr = input.string("solid",  "Close Line Style", options=["solid","dashed","dotted"], group=grpStyle)
labelTierGap  = input.float(0.4, "Label Tier Gap (% of price)", minval=0.05, maxval=2.0, step=0.05, group=grpStyle)

grpVol = "Overnight Volume"
showOvernight    = input.bool(true,  "Enable", group=grpVol)
windowTZ         = input.string("America/New_York", "Window Timezone", options=["America/New_York","Europe/London","Europe/Amsterdam","Asia/Tokyo","UTC","Exchange"], group=grpVol)
sessionStartH    = input.int(1,  "Start Hour",   minval=0, maxval=23, group=grpVol, tooltip="When the window begins. Default 01:00.")
sessionStartM    = input.int(0,  "Start Minute", minval=0, maxval=59, group=grpVol)
sessionEndH      = input.int(7,  "End Hour",     minval=0, maxval=23, group=grpVol, tooltip="When counting stops. Default 07:30.")
sessionEndM      = input.int(30, "End Minute",   minval=0, maxval=59, group=grpVol)
showCumLabel     = input.bool(true, "Show Live/Frozen Volume Label", group=grpVol)
showDiagnostic   = input.bool(false, "Show Diagnostic Info", group=grpVol, tooltip="Adds clock + window status to the label so you can verify firing times.")

grpTable = "History Table"
showTable     = input.bool(true, "Show History Table", group=grpTable)
historyDays   = input.int(21, "Days to Show", minval=1, maxval=60, group=grpTable)
tablePos      = input.string("Top Right", "Position", options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group=grpTable)
tableTextSize = input.string("small", "Text Size", options=["tiny","small","normal","large"], group=grpTable)
tableBgCol    = input.color(color.new(#1e1e1e, 20), "Background", group=grpTable)
tableTxtCol   = input.color(color.white, "Text Color", group=grpTable)
tableHdrCol   = input.color(color.new(color.purple, 30), "Header Color", group=grpTable)

// ============================================================
// FIXED SESSION TIMES
// ============================================================
tokyoTZ         = "Asia/Tokyo"
londonTZ        = "Europe/London"
amsterdamTZ     = "Europe/Amsterdam"
tokyoOpenH      = 9
tokyoCloseH     = 15
londonOpenH     = 8
londonCloseH    = 16
amsterdamOpenH  = 9
amsterdamCloseH = 17
amsterdamCloseM = 30

// ============================================================
// SESSION DETECTION
// ============================================================
tH = hour(time, tokyoTZ)
tM = minute(time, tokyoTZ)
lH = hour(time, londonTZ)
lM = minute(time, londonTZ)
aH = hour(time, amsterdamTZ)
aM = minute(time, amsterdamTZ)

tokyoOpenBar      = showTokyo     and showOpens  and (tH == tokyoOpenH  and tM == 0) and (tH[1] != tokyoOpenH  or tM[1] != 0)
tokyoCloseBar     = showTokyo     and showCloses and (tH == tokyoCloseH and tM == 0) and (tH[1] != tokyoCloseH or tM[1] != 0)
londonOpenBar     = showLondon    and showOpens  and (lH == londonOpenH  and lM == 0) and (lH[1] != londonOpenH  or lM[1] != 0)
londonCloseBar    = showLondon    and showCloses and (lH == londonCloseH and lM == 0) and (lH[1] != londonCloseH or lM[1] != 0)
amsterdamOpenBar  = showAmsterdam and showOpens  and (aH == amsterdamOpenH  and aM == 0)               and (aH[1] != amsterdamOpenH  or aM[1] != 0)
amsterdamCloseBar = showAmsterdam and showCloses and (aH == amsterdamCloseH and aM == amsterdamCloseM) and (aH[1] != amsterdamCloseH or aM[1] != amsterdamCloseM)

// ============================================================
// TIER OFFSETS
// ============================================================
tierUnit = close * (labelTierGap / 100.0)
tokyoTierOffset     = tierUnit * 3.0
londonTierOffset    = tierUnit * 2.0
amsterdamTierOffset = tierUnit * 1.0

// ============================================================
// HELPERS
// ============================================================
f_style(s) =>
    s == "solid" ? line.style_solid : s == "dashed" ? line.style_dashed : line.style_dotted

f_drawSession(_cond, _col, _styleStr, _txt, _yOffset) =>
    if _cond
        line.new(bar_index, low, bar_index, high, extend=extend.both, color=_col, width=lineWidth, style=f_style(_styleStr))
        if showLabels
            label.new(bar_index, high + _yOffset, _txt, yloc=yloc.price, style=label.style_none, textcolor=_col, size=size.small)

f_drawSession(tokyoOpenBar,      tokyoCol,     openStyleStr,  "Tokyo Open",      tokyoTierOffset)
f_drawSession(tokyoCloseBar,     tokyoCol,     closeStyleStr, "Tokyo Close",     tokyoTierOffset)
f_drawSession(londonOpenBar,     londonCol,    openStyleStr,  "London Open",     londonTierOffset)
f_drawSession(londonCloseBar,    londonCol,    closeStyleStr, "London Close",    londonTierOffset)
f_drawSession(amsterdamOpenBar,  amsterdamCol, openStyleStr,  "Amsterdam Open",  amsterdamTierOffset)
f_drawSession(amsterdamCloseBar, amsterdamCol, closeStyleStr, "Amsterdam Close", amsterdamTierOffset)

// ============================================================
// VOLUME — single-timezone window (handles same-day or wrap-around)
// Same logic applies across all bars on the chart, so historical days
// get the same window treatment as today's live session.
// ============================================================
tzStr = windowTZ == "Exchange" ? syminfo.timezone : windowTZ
wH = hour(time, tzStr)
wM = minute(time, tzStr)

nowMin   = wH * 60 + wM
startMin = sessionStartH * 60 + sessionStartM
endMin   = sessionEndH * 60 + sessionEndM

inWindow = startMin < endMin ? (nowMin >= startMin and nowMin <= endMin) : (nowMin >= startMin or nowMin <= endMin)

inOvernight    = showOvernight and inWindow
sessionStarted = inOvernight and not inOvernight[1]
sessionEnded   = not inOvernight and inOvernight[1]

var float liveCumVol       = 0.0
var float lastCompletedVol = na

if sessionStarted
    liveCumVol := volume
else if inOvernight
    liveCumVol := liveCumVol + volume

if sessionEnded
    lastCompletedVol := liveCumVol

// ============================================================
// HISTORY ARRAYS
// ============================================================
var array<float> histVols  = array.new<float>()
var array<int>   histDates = array.new<int>()

if sessionEnded
    array.push(histVols,  liveCumVol)
    array.push(histDates, time)
    while array.size(histVols) > historyDays
        array.shift(histVols)
        array.shift(histDates)

// ============================================================
// LIVE LABEL
// ============================================================
var label cumLbl = na
if showCumLabel and barstate.islast
    label.delete(cumLbl)
    displayVal = inOvernight ? liveCumVol : lastCompletedVol
    baseTxt = inOvernight ? "Overnight (live): " + str.tostring(displayVal, "#,###") : (na(displayVal) ? "Overnight: —" : "Overnight (last): " + str.tostring(displayVal, "#,###"))
    diagTxt = showDiagnostic ? "\n[" + tzStr + " " + str.tostring(wH, "00") + ":" + str.tostring(wM, "00") + " | window: " + (inOvernight ? "OPEN" : "CLOSED") + "]" : ""
    txt = baseTxt + diagTxt
    labelCol = inOvernight ? color.new(color.purple, 30) : color.new(color.gray, 40)
    cumLbl := label.new(bar_index, high, txt, style=label.style_label_left, color=labelCol, textcolor=color.white, size=size.small)

plot(inOvernight ? liveCumVol : na, "Overnight Cum Vol (live)", color=color.purple, display=display.data_window + display.status_line)

// ============================================================
// HISTORY TABLE
// ============================================================
f_tablePos(p) =>
    p == "Top Left"      ? position.top_left :
     p == "Top Right"     ? position.top_right :
     p == "Bottom Left"   ? position.bottom_left :
     p == "Bottom Right"  ? position.bottom_right :
     position.middle_right

f_tableSize(s) =>
    s == "tiny"   ? size.tiny :
     s == "small"  ? size.small :
     s == "normal" ? size.normal :
     size.large

var table histTbl = na

if showTable and barstate.islast
    if not na(histTbl)
        table.delete(histTbl)
    n = array.size(histVols)
    rows = math.max(n + 2, 3)
    histTbl := table.new(f_tablePos(tablePos), 2, rows, bgcolor=tableBgCol, border_width=1, border_color=color.new(color.gray, 70))

    table.cell(histTbl, 0, 0, "Date", text_color=color.white, bgcolor=tableHdrCol, text_size=f_tableSize(tableTextSize))
    table.cell(histTbl, 1, 0, "Overnight Vol", text_color=color.white, bgcolor=tableHdrCol, text_size=f_tableSize(tableTextSize))

    sum = 0.0
    if n > 0
        for i = 0 to n - 1
            idx = n - 1 - i
            d = array.get(histDates, idx)
            v = array.get(histVols, idx)
            dateStr = str.format_time(d, "MMM dd", tzStr)
            rowBg = i == 0 ? color.new(color.purple, 70) : color.new(tableBgCol, 0)
            table.cell(histTbl, 0, i + 1, dateStr, text_color=tableTxtCol, bgcolor=rowBg, text_size=f_tableSize(tableTextSize))
            table.cell(histTbl, 1, i + 1, str.tostring(v, "#,###"), text_color=tableTxtCol, bgcolor=rowBg, text_size=f_tableSize(tableTextSize))
            sum := sum + v

    avgRow = n + 1
    avg = n > 0 ? sum / n : 0.0
    table.cell(histTbl, 0, avgRow, "Avg (" + str.tostring(n) + "d)", text_color=color.white, bgcolor=tableHdrCol, text_size=f_tableSize(tableTextSize))
    table.cell(histTbl, 1, avgRow, n > 0 ? str.tostring(avg, "#,###") : "—", text_color=color.white, bgcolor=tableHdrCol, text_size=f_tableSize(tableTextSize))
````
