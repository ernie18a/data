# Better Sessions [CantoLab]

- url: https://www.tradingview.com/script/KlDOVWej-Better-Sessions-CantoLab/
- type: indicator
- pine_id: PUB;a2bb96d0f94f4a7c9dbd57f23e7863f8
- version: 1.0

## Description

This session indicator plots Asia, London and New York sessions, with 3 extra fully customisable sessions. Includes sweep detection to automatically track if price has swept session highs/lows, and a visual dashboard to identify overlapping sessions.

[b]Features :[/b]
[i]Sessions[/i]
Up to 6 sessions can be configured with custom times, colors and labels. By default the indicator comes set to Asia, London and NY stock exchange timings. The 3 additional sessions can be set to anything. 

A common use case is replicating ICT killzones by adjusting the session times in settings to London[0200-0500], NY-AM[0800-1100], NY-PM[1300-1630], Asia[18:00-21:00]

The overlapping window between London and New York is highlighted automatically in the dashboard, signifying the period of potential high volume and volatility traders watch closely.

[i]Sweep Detection[/i]
On session close, lines are drawn automatically from the session high and low. They extend forward bar by bar and mark as swept the moment price crosses them. No manual drawing or monitoring needed.

[i]Daily Dividers[/i]
Vertical lines at each day boundary to separate trading days.


[b]Settings:[/b]
[list]
[*]Sessions — toggle, time, color and label per session
[*]Sweep Detection — toggle in settings (off by default)
[*]CE Line — session equilibrium/midpoint, toggle in settings
[*]Daily Dividers — toggle, color, style and width
[*]Session Table — 24hr overlap dashboard, 9 position options
[*]Label Size — Tiny / Small / Normal / Large
[/list]

[b]Notes:[/b]
[list]
[*]Best used on timeframes at or below 1 hour
[*]Sweep lines reset at the start of each new day
[*]UTC offset applies globally — adjust manually for DST
[/list]

## Source Code

````pine
//@version=6
indicator("Better Sessions [CantoLab]", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)
 
grpTF = "SESSION SETTINGS"
enableTimeFilter = input.bool(true, "Enable Sessions?", group=grpTF)
timezoneHours    = input.int(-4,     "UTC",              group=grpTF, inline="tz", minval=-12, maxval=14, active=enableTimeFilter)
timezoneMinutes  = input.int(0,     "",                 group=grpTF, inline="tz", minval=0,   maxval=59, active=enableTimeFilter, tooltip = "use right Timezone, adjust for DST")

enableFilter1  = input.bool(true,                    "", group=grpTF, inline="f1", active=enableTimeFilter)
filter1Color   = input.color(color.new(#787b86, 88), "", group=grpTF, inline="f1", active=enableFilter1)
filter1text    = input.string("Asia",              "", group=grpTF, inline="f1", active=enableFilter1)
filter1Session = input.session("2000-0200",          "", group=grpTF, inline="f1", active=enableFilter1)

enableFilter2  = input.bool(true,                    "", group=grpTF, inline="f2", active=enableTimeFilter)
filter2Color   = input.color(color.new(#ff5252, 88), "", group=grpTF, inline="f2", active=enableFilter2)
filter2text    = input.string("London",               "", group=grpTF, inline="f2", active=enableFilter2)
filter2Session = input.session("0300-1200",          "", group=grpTF, inline="f2", active=enableFilter2)

enableFilter3  = input.bool(true,                    "", group=grpTF, inline="f3", active=enableTimeFilter)
filter3Color   = input.color(color.new(#4caf50, 88), "", group=grpTF, inline="f3", active=enableFilter3)
filter3text    = input.string("NY",               "", group=grpTF, inline="f3", active=enableFilter3)
filter3Session = input.session("0800-1630",          "", group=grpTF, inline="f3", active=enableFilter3)

enableFilter4  = input.bool(false,                    "", group=grpTF, inline="f4", active=enableTimeFilter)
filter4Color   = input.color(color.new(#1a1a1a, 88), "", group=grpTF, inline="f4", active=enableFilter4)
filter4text    = input.string("",                "", group=grpTF, inline="f4", active=enableFilter4)
filter4Session = input.session("0000-0100",          "", group=grpTF, inline="f4", active=enableFilter4)

enableFilter5  = input.bool(false,                   "", group=grpTF, inline="f5", active=enableTimeFilter)
filter5Color   = input.color(color.new(#1a1a1a, 88), "", group=grpTF, inline="f5", active=enableFilter5)
filter5text    = input.string("",                    "", group=grpTF, inline="f5", active=enableFilter5)
filter5Session = input.session("0000-0100",          "", group=grpTF, inline="f5", active=enableFilter5)

enableFilter6  = input.bool(false,                   "", group=grpTF, inline="f6", active=enableTimeFilter)
filter6Color   = input.color(color.new(#1a1a1a, 88), "", group=grpTF, inline="f6", active=enableFilter6)
filter6text    = input.string("",                    "", group=grpTF, inline="f6", active=enableFilter6)
filter6Session = input.session("0000-0100",          "", group=grpTF, inline="f6", active=enableFilter6)

grpC = "CUSTOMISATION"
labelSize    = input.string("Tiny",  "Label Size",     group=grpC, options=["Tiny","Small","Normal","Large"])
enableBorder = input.bool(true,      "Border",          group=grpC, inline="bdr")
borderColor  = input.color(color.new(#1a1a1a, 0), "",  group=grpC, inline="bdr", active=enableBorder)
borderStyle  = input.string("Solid", "",                group=grpC, inline="bdr", options=["Solid","Dashed","Dotted"], active=enableBorder)
borderWidth  = input.int(1,          "",                group=grpC, inline="bdr", options=[1,2,3,4],                  active=enableBorder)
enableMid    = input.bool(false,     "C.E",             group=grpC, inline="mid")
midColor     = input.color(color.new(#1a1a1a, 0), "",  group=grpC, inline="mid", active=enableMid)
midStyle     = input.string("Dashed","",                group=grpC, inline="mid", options=["Solid","Dashed","Dotted"], active=enableMid)
midWidth     = input.int(1,          "",                group=grpC, inline="mid", options=[1,2,3,4],                  active=enableMid)
showMidLbl   = input.bool(true,      "Label?",          group=grpC, inline="mid", active=enableMid)
enableSwp    = input.bool(false,     "Sweep",           group=grpC, inline="swp")
swpColor     = input.color(color.new(#1a1a1a, 0), "",  group=grpC, inline="swp", active=enableSwp)
swpStyle     = input.string("Solid", "",                group=grpC, inline="swp", options=["Solid","Dashed","Dotted"], active=enableSwp)
swpWidth     = input.int(1,          "",                group=grpC, inline="swp", options=[1,2,3,4],                  active=enableSwp)
enableDiv    = input.bool(true,      "Daily Dividers",  group=grpC, inline="div")
divColor     = input.color(color.new(#1a1a1a, 0), "",  group=grpC, inline="div", active=enableDiv)
divStyle     = input.string("Dotted","",                group=grpC, inline="div", options=["Solid","Dashed","Dotted"], active=enableDiv)
divWidth     = input.int(1,          "",                group=grpC, inline="div", options=[1,2,3,4],                  active=enableDiv)

grpST         = "SESSION TABLE"
showSessTable = input.bool(true,              "Show Table?", group=grpST, inline="st")
stPos         = input.string("Bottom-Center", "Position",           group=grpST, inline="st", options=["Top-Left","Top-Center","Top-Right","Middle-Left","Middle-Center","Middle-Right","Bottom-Left","Bottom-Center","Bottom-Right"], active=showSessTable)

NOCOLOR    = color.new(color.black, 100)
CHART_TEXT = 0.299 * color.r(chart.bg_color) + 0.587 * color.g(chart.bg_color) + 0.114 * color.b(chart.bg_color) < 128 ? color.new(#ffffff, 0) : color.new(#000000, 0)
DARK       = color.new(#1a1a1a, 0)

f_lineStyle(s) =>
    s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted

f_labelSize(s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : size.large

f_tablePos(s) =>
    switch s
        "Top-Left"      => position.top_left
        "Top-Center"    => position.top_center
        "Top-Right"     => position.top_right
        "Middle-Left"   => position.middle_left
        "Middle-Center" => position.middle_center
        "Middle-Right"  => position.middle_right
        "Bottom-Left"   => position.bottom_left
        "Bottom-Center" => position.bottom_center
        "Bottom-Right"  => position.bottom_right
        =>                 position.bottom_center

f_tz() =>
    (timezoneHours >= 0 ? "UTC+" : "UTC-") + str.tostring(math.abs(timezoneHours)) + ":" + (timezoneMinutes < 10 ? "0" : "") + str.tostring(timezoneMinutes)

f_rawColor(col) =>
    color.rgb(color.r(col), color.g(col), color.b(col))

f_inSession(sess, simple int barsBack=0) =>
    not na(time(timeframe.period, sess, f_tz(), bars_back=barsBack))

type SessionData
    array<box>   boxes
    array<line>  midLines
    array<line>  swpHiLines
    array<line>  swpLoLines
    array<float> swpHiPrices
    array<float> swpLoPrices
    array<bool>  swpHiSwept
    array<bool>  swpLoSwept
    label        liveLabel

f_newSD() =>
    SessionData.new(
         array.new_box(),   array.new_line(),
         array.new_line(),  array.new_line(),
         array.new_float(), array.new_float(),
         array.new_bool(),  array.new_bool(),
         na)

var sd1 = f_newSD()
var sd2 = f_newSD()
var sd3 = f_newSD()
var sd4 = f_newSD()
var sd5 = f_newSD()
var sd6 = f_newSD()

method resetSweeps(SessionData sd) =>
    for ln in sd.swpHiLines
        line.delete(ln)
    for ln in sd.swpLoLines
        line.delete(ln)
    sd.swpHiLines.clear()  ,  sd.swpLoLines.clear()
    sd.swpHiPrices.clear() ,  sd.swpLoPrices.clear()
    sd.swpHiSwept.clear()  ,  sd.swpLoSwept.clear()

method tickSweeps(SessionData sd) =>
    if enableSwp
        sz = sd.swpHiLines.size()
        if sz > 0
            for i = 0 to sz - 1
                if not sd.swpHiSwept.get(i)
                    sd.swpHiLines.get(i).set_x2(bar_index)
                    if high > sd.swpHiPrices.get(i)
                        sd.swpHiSwept.set(i, true)
                if not sd.swpLoSwept.get(i)
                    sd.swpLoLines.get(i).set_x2(bar_index)
                    if low < sd.swpLoPrices.get(i)
                        sd.swpLoSwept.set(i, true)

f_swpLine(int fromBar, float y) =>
    line.new(fromBar, y, fromBar, y, xloc=xloc.bar_index, color=swpColor, style=f_lineStyle(swpStyle), width=swpWidth)

method spawnSweeps(SessionData sd, int fromBar, float hiP, float loP) =>
    sd.swpHiLines.unshift(f_swpLine(fromBar, hiP)) ,  sd.swpLoLines.unshift(f_swpLine(fromBar, loP))
    sd.swpHiPrices.unshift(hiP)                    ,  sd.swpLoPrices.unshift(loP)
    sd.swpHiSwept.unshift(false)                   ,  sd.swpLoSwept.unshift(false)

method processSession(SessionData sd, bool active, bool activePrev, bool enabled, color sessColor, string sessName) =>
    if enableTimeFilter and enabled
        if active
            if not activePrev
                bx = box.new(bar_index, high, bar_index, low,
                     border_color = enableBorder ? borderColor : NOCOLOR,
                     border_style = f_lineStyle(borderStyle),
                     border_width = borderWidth,
                     bgcolor      = sessColor)
                sd.boxes.unshift(bx)
                if enableMid
                    mid = (high + low) / 2.0
                    ml  = line.new(bar_index, mid, bar_index, mid, xloc=xloc.bar_index, color=midColor, style=f_lineStyle(midStyle), width=midWidth)
                    if sd.midLines.size() > 0
                        line.delete(sd.midLines.get(0))
                        sd.midLines.set(0, ml)
                    else
                        sd.midLines.push(ml)
            else
                bx     = sd.boxes.get(0)
                newTop = math.max(bx.get_top(), high)
                newBot = math.min(bx.get_bottom(), low)
                bx.set_top(newTop) , bx.set_bottom(newBot) , bx.set_right(bar_index)
                if enableMid and sd.midLines.size() > 0
                    mid = (newTop + newBot) / 2.0
                    ml  = sd.midLines.get(0)
                    ml.set_y1(mid) , ml.set_y2(mid) , ml.set_x2(bar_index)
            bx   = sd.boxes.get(0)
            midX = math.round((bx.get_left() + bx.get_right()) / 2)
            if na(sd.liveLabel)
                sd.liveLabel := label.new(midX, bx.get_top(), sessName, xloc=xloc.bar_index, yloc=yloc.price,
                     color=NOCOLOR, textcolor=CHART_TEXT, style=label.style_label_down, size=f_labelSize(labelSize))
                label.set_x(sd.liveLabel, midX)
            else
                label.set_x(sd.liveLabel, midX)
                label.set_y(sd.liveLabel, bx.get_top())
        else
            if not na(sd.liveLabel)
                label.delete(sd.liveLabel)
                sd.liveLabel := na
            if activePrev and sd.boxes.size() > 0
                bx   = sd.boxes.get(0)
                midX = math.round((bx.get_left() + bx.get_right()) / 2)
                label.new(midX, bx.get_top(), sessName, xloc=xloc.bar_index, yloc=yloc.price,
                     color=NOCOLOR, textcolor=CHART_TEXT, style=label.style_label_down, size=f_labelSize(labelSize))
                if sd.midLines.size() > 0
                    line.delete(sd.midLines.get(0))
                    sd.midLines.clear()
                if enableMid
                    mid  = (bx.get_top() + bx.get_bottom()) / 2.0
                    midR = bx.get_right()
                    line.new(bx.get_left(), mid, midR, mid, xloc=xloc.bar_index, color=midColor, style=f_lineStyle(midStyle), width=midWidth)
                    if showMidLbl
                        label.new(midR, mid, "0.5", xloc=xloc.bar_index, yloc=yloc.price,
                             color=NOCOLOR, textcolor=midColor, style=label.style_label_left, size=f_labelSize(labelSize))
                if enableSwp
                    sd.spawnSweeps(bx.get_right(), bx.get_top(), bx.get_bottom())
            sd.tickSweeps()

isNewDay = ta.change(time("D", f_tz())) != 0

if isNewDay
    if enableDiv
        line.new(time, high, time, low, xloc=xloc.bar_time, extend=extend.both, color=divColor, style=f_lineStyle(divStyle), width=divWidth)
    sd1.resetSweeps() , sd2.resetSweeps() , sd3.resetSweeps() , sd4.resetSweeps() , sd5.resetSweeps() , sd6.resetSweeps()

sd1.processSession(f_inSession(filter1Session), f_inSession(filter1Session, 1), enableFilter1, filter1Color, filter1text)
sd2.processSession(f_inSession(filter2Session), f_inSession(filter2Session, 1), enableFilter2, filter2Color, filter2text)
sd3.processSession(f_inSession(filter3Session), f_inSession(filter3Session, 1), enableFilter3, filter3Color, filter3text)
sd4.processSession(f_inSession(filter4Session), f_inSession(filter4Session, 1), enableFilter4, filter4Color, filter4text)
sd5.processSession(f_inSession(filter5Session), f_inSession(filter5Session, 1), enableFilter5, filter5Color, filter5text)
sd6.processSession(f_inSession(filter6Session), f_inSession(filter6Session, 1), enableFilter6, filter6Color, filter6text)

f_hourInSess(int h, simple string sess) =>
    sh = int(str.tonumber(str.substring(sess, 0, 2)))
    eh = int(str.tonumber(str.substring(sess, 5, 7)))
    sh <= eh ? h >= sh and h < eh : h >= sh or h < eh

f_drawSessionRow(table t, int row, simple string sess, color rawCol, string sessName) =>
    BG = color.new(chart.bg_color, 0)
    table.cell(t, 0, row, sessName, text_color=CHART_TEXT, bgcolor=BG, text_size=size.tiny)
    firstActive = -1
    lastActive  = -1
    for h = 0 to 23
        if f_hourInSess(h, sess)
            if firstActive == -1
                firstActive := h
            lastActive := h
        else
            if firstActive != -1
                ms = firstActive + 1
                me = lastActive  + 1
                table.cell(t, ms, row, "", bgcolor=rawCol, text_size=size.tiny)
                if me > ms
                    table.merge_cells(t, ms, row, me, row)
                firstActive := -1
                lastActive  := -1
            table.cell(t, h + 1, row, "", bgcolor=BG, text_size=size.tiny)
    if firstActive != -1
        ms = firstActive + 1
        me = lastActive  + 1
        table.cell(t, ms, row, "", bgcolor=rawCol, text_size=size.tiny)
        if me > ms
            table.merge_cells(t, ms, row, me, row)

if showSessTable and barstate.islast
    BG           = color.new(chart.bg_color, 0)
    enabledCount = (enableFilter1 ? 1 : 0) + (enableFilter2 ? 1 : 0) + (enableFilter3 ? 1 : 0) +
         (enableFilter4 ? 1 : 0) + (enableFilter5 ? 1 : 0) + (enableFilter6 ? 1 : 0)

    var table sessTable = table.new(f_tablePos(stPos), 25, 2 + enabledCount, border_color=DARK, border_width=1, frame_color=DARK, frame_width=1)

    tzLabel = (timezoneHours >= 0 ? "UTC+" : "UTC-") + str.tostring(math.abs(timezoneHours)) + ":" + (timezoneMinutes < 10 ? "0" : "") + str.tostring(timezoneMinutes)
    table.cell(sessTable, 0, 0, tzLabel, text_color=CHART_TEXT, bgcolor=BG, text_size=size.tiny)
    table.merge_cells(sessTable, 0, 0, 24, 0)

    table.cell(sessTable, 0, 1, "", bgcolor=BG, text_size=size.tiny)
    for h = 0 to 23
        table.cell(sessTable, h + 1, 1, h < 10 ? "0" + str.tostring(h) : str.tostring(h), text_color=CHART_TEXT, bgcolor=BG, text_size=size.tiny)

    currentRow = 2
    if enableFilter1
        f_drawSessionRow(sessTable, currentRow, filter1Session, f_rawColor(filter1Color), filter1text)
        currentRow := currentRow + 1
    if enableFilter2
        f_drawSessionRow(sessTable, currentRow, filter2Session, f_rawColor(filter2Color), filter2text)
        currentRow := currentRow + 1
    if enableFilter3
        f_drawSessionRow(sessTable, currentRow, filter3Session, f_rawColor(filter3Color), filter3text)
        currentRow := currentRow + 1
    if enableFilter4
        f_drawSessionRow(sessTable, currentRow, filter4Session, f_rawColor(filter4Color), filter4text)
        currentRow := currentRow + 1
    if enableFilter5
        f_drawSessionRow(sessTable, currentRow, filter5Session, f_rawColor(filter5Color), filter5text)
        currentRow := currentRow + 1
    if enableFilter6
        f_drawSessionRow(sessTable, currentRow, filter6Session, f_rawColor(filter6Color), filter6text)
````
