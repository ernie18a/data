# All-In-One Sessions, Weekly, Monday, Previous Highs/Lows

- url: https://www.tradingview.com/script/2qWTISKX-All-In-One-Sessions-Weekly-Monday-Previous-Highs-Lows/
- type: indicator
- pine_id: PUB;c94d5f211a1d4118921a2f6f7ef58671
- version: 1.0

## Description

All-In-One Market Levels indicator shows important trading levels clearly on the chart, including Previous Day High/Low, Previous Week High/Low, Monday High/Low, Weekly Open, Monthly levels, and major market sessions like Asia, London, and New York.

It draws clean horizontal lines with full text labels so traders can quickly identify key support and resistance areas. Session boxes help you see when each market session opens and closes. The indicator also includes alert options when price crosses major levels.

Best for MNQ, NQ, ES, futures, forex, and intraday trading.

## Source Code

````pine
// © Texmoonbeam
//@version=5
indicator("All-In-One Sessions, Weekly, Monday, Previous Highs/Lows", overlay = true, max_boxes_count=500, max_lines_count = 500, max_labels_count = 500, max_bars_back=5000)

abr = input.bool(defval = false, title="Abbreviate Labels", group="Mondays, Weekly, Monthly", inline="0a")
labelsz = input.string(defval="large", title="Size", options=["tiny","small","normal","large","huge"], group="Mondays, Weekly, Monthly", inline="0a")
sz = labelsz == "tiny" ? size.tiny : labelsz == "small" ? size.small : labelsz == "normal" ? size.normal : labelsz == "large" ? size.large : labelsz == "huge" ? size.huge : size.auto

ShowMonday = input.bool(defval = true, title="Show Monday High/Low", group="Mondays, Weekly, Monthly", inline="1a")
ExtendMonday = input.bool(defval = false, title="Extend?", group="Mondays, Weekly, Monthly", inline="1a")
LabelMonday = input.bool(defval = true, title="Label?", group="Mondays, Weekly, Monthly", inline="1a")
MidMonday = input.bool(defval = false, title="50%?", group="Mondays, Weekly, Monthly", inline="1a")
MonHighCol = input.color(color.green, "High", group="Mondays, Weekly, Monthly", inline="1c")
MonLowCol = input.color(color.red, "Low", group = "Mondays, Weekly, Monthly", inline="1c")
MonMidCol = input.color(color.green, "0.5", group = "Mondays, Weekly, Monthly", inline="1c")
MonWidth = input.int(defval=2, title="Width", minval=1, maxval = 4, group="Mondays, Weekly, Monthly", inline="1c")
MonOff = input.int(defval = -80, title="Label & Line Offset", group="Mondays, Weekly, Monthly", inline="1d")
MonStyle = input.string(line.style_solid, 'Line Style', options=[line.style_solid, line.style_dotted, line.style_dashed],  group="Mondays, Weekly, Monthly", inline="1d")

ShowPrevDay = input.bool(defval = true, title="Show Prev Day High/Low", group="Mondays, Weekly, Monthly", inline="2a")
ExtendPrevDay = input.bool(defval = false, title="Extend?", group="Mondays, Weekly, Monthly", inline="2a")
LabelPrevDay = input.bool(defval = true, title="Label?", group="Mondays, Weekly, Monthly", inline="2a")
MidPrevDay = input.bool(defval = false, title="50%?", group="Mondays, Weekly, Monthly", inline="2a")
PrevDayHighCol = input.color(color.green, "High", group="Mondays, Weekly, Monthly", inline="2c")
PrevDayLowCol = input.color(color.red, "Low", group = "Mondays, Weekly, Monthly", inline="2c")
PrevDayMidCol = input.color(color.green, "0.5", group = "Mondays, Weekly, Monthly", inline="2c")
PrevDayWidth = input.int(defval=2, title="Width", minval=1, maxval = 4, group="Mondays, Weekly, Monthly", inline="2c")
PrevDayOff = input.int(defval = -80, title="Label & Line Offset", group="Mondays, Weekly, Monthly", inline="2d")
PrevDayStyle = input.string(line.style_solid, 'Line Style', options=[line.style_solid, line.style_dotted, line.style_dashed],  group="Mondays, Weekly, Monthly", inline="2d")

ShowCurWeek = input.bool(defval = false, title="Show Current Week High/Low", group="Mondays, Weekly, Monthly", inline="3a")
ExtendCurWeek = input.bool(defval = false, title="Extend?", group="Mondays, Weekly, Monthly", inline="3a")
LabelCurWeek = input.bool(defval = false, title="Label?", group="Mondays, Weekly, Monthly", inline="3a")
MidCurWeek = input.bool(defval = false, title="50%?", group="Mondays, Weekly, Monthly", inline="3a")
CurWeekHighCol = input.color(color.green, "High", group="Mondays, Weekly, Monthly", inline="3c")
CurWeekLowCol = input.color(color.red, "Low", group = "Mondays, Weekly, Monthly", inline="3c")
CurWeekMidCol = input.color(color.green, "0.5", group = "Mondays, Weekly, Monthly", inline="3c")
CurWeekWidth = input.int(defval=2, title="Width", minval=1, maxval = 4, group="Mondays, Weekly, Monthly", inline="3c")
CurWeekOff = input.int(defval = -80, title="Label & Line Offset", group="Mondays, Weekly, Monthly", inline="3d")
CurWeekStyle = input.string(line.style_solid, 'Line Style', options=[line.style_solid, line.style_dotted, line.style_dashed],  group="Mondays, Weekly, Monthly", inline="3d")

ShowPrevWeek = input.bool(defval = true, title="Show Previous Week High/Low", group="Mondays, Weekly, Monthly", inline="4a")
ExtendPrevWeek = input.bool(defval = false, title="Extend?", group="Mondays, Weekly, Monthly", inline="4a")
LabelPrevWeek = input.bool(defval = true, title="Label?", group="Mondays, Weekly, Monthly", inline="4a")
MidPrevWeek = input.bool(defval = false, title="50%?", group="Mondays, Weekly, Monthly", inline="4a")
PrevWeekHighCol = input.color(color.green, "High", group="Mondays, Weekly, Monthly", inline="4c")
PrevWeekLowCol = input.color(color.red, "Low", group = "Mondays, Weekly, Monthly", inline="4c")
PrevWeekMidCol = input.color(color.green, "0.5", group = "Mondays, Weekly, Monthly", inline="4c")
PrevWeekWidth = input.int(defval=2, title="Width", minval=1, maxval = 4, group="Mondays, Weekly, Monthly", inline="4c")
PrevWeekOff = input.int(defval = -80, title="Label & Line Offset", group="Mondays, Weekly, Monthly", inline="4d")
PrevWeekStyle = input.string(line.style_solid, 'Line Style', options=[line.style_solid, line.style_dotted, line.style_dashed],  group="Mondays, Weekly, Monthly", inline="4d")

ShowCurMth = input.bool(defval = false, title="Show Current Month High/Low", group="Mondays, Weekly, Monthly", inline="5a")
ExtendCurMth = input.bool(defval = false, title="Extend?", group="Mondays, Weekly, Monthly", inline="5a")
LabelCurMth = input.bool(defval = false, title="Label?", group="Mondays, Weekly, Monthly", inline="5a")
MidCurMth = input.bool(defval = false, title="50%?", group="Mondays, Weekly, Monthly", inline="5a")
CurMthHighCol = input.color(color.green, "High", group="Mondays, Weekly, Monthly", inline="5c")
CurMthLowCol = input.color(color.red, "Low", group = "Mondays, Weekly, Monthly", inline="5c")
CurMthMidCol = input.color(color.green, "0.5", group = "Mondays, Weekly, Monthly", inline="5c")
CurMthWidth = input.int(defval=2, title="Width", minval=1, maxval = 4, group="Mondays, Weekly, Monthly", inline="5c")
CurMthOff = input.int(defval = -80, title="Label & Line Offset", group="Mondays, Weekly, Monthly", inline="5d")
CurMthStyle = input.string(line.style_solid, 'Line Style', options=[line.style_solid, line.style_dotted, line.style_dashed],  group="Mondays, Weekly, Monthly", inline="5d")

ShowPrevMth = input.bool(defval = true, title="Show Previous Month High/Low", group="Mondays, Weekly, Monthly", inline="6a")
ExtendPrevMth = input.bool(defval = false, title="Extend?", group="Mondays, Weekly, Monthly", inline="6a")
LabelPrevMth = input.bool(defval = true, title="Label?", group="Mondays, Weekly, Monthly", inline="6a")
MidPrevMth = input.bool(defval = false, title="50%?", group="Mondays, Weekly, Monthly", inline="6a")
PrevMthHighCol = input.color(color.green, "High", group="Mondays, Weekly, Monthly", inline="6c")
PrevMthLowCol = input.color(color.red, "Low", group = "Mondays, Weekly, Monthly", inline="6c")
PrevMthMidCol = input.color(color.green, "0.5", group = "Mondays, Weekly, Monthly", inline="6c")
PrevMthWidth = input.int(defval=2, title="Width", minval=1, maxval = 4, group="Mondays, Weekly, Monthly", inline="6c")
PrevMthOff = input.int(defval = -80, title="Label & Line Offset", group="Mondays, Weekly, Monthly", inline="6d")
PrevMthStyle = input.string(line.style_solid, 'Line Style', options=[line.style_solid, line.style_dotted, line.style_dashed],  group="Mondays, Weekly, Monthly", inline="6d")

ShowWeekOpen = input.bool(defval = false, title="Show Current Week Open", group="Opens", inline="3a")
ExtendWeekOpen = input.bool(defval = false, title="Extend?", group="Opens", inline="3a")
LabelWeekOpen = input.bool(defval = false, title="Label?", group="Opens", inline="3a")
WeekOpenCol = input.color(color.blue, "Open", group="Opens", inline="3c")
WeekOpenWidth = input.int(defval=2, title="Width", minval=1, maxval = 4, group="Opens", inline="3c")
WeekOpenStyle = input.string(line.style_solid, 'Line Style', options=[line.style_solid, line.style_dotted, line.style_dashed], group="Opens", inline="3c")

ShowMthOpen = input.bool(defval = false, title="Show Current Month Open", group="Opens", inline="4a")
ExtendMthOpen = input.bool(defval = false, title="Extend?", group="Opens", inline="4a")
LabelMthOpen = input.bool(defval = false, title="Label?", group="Opens", inline="4a")
MthOpenCol = input.color(color.blue, "Open", group="Opens", inline="4c")
MthOpenWidth = input.int(defval=2, title="Width", minval=1, maxval = 4, group="Opens", inline="4c")
MthOpenStyle = input.string(line.style_solid, 'Line Style', options=[line.style_solid, line.style_dotted, line.style_dashed], group="Opens", inline="4c")

zone = input.string('GMT+1', title='Timezone', options=['GMT-11', 'GMT-10', 'GMT-9', 'GMT-8', 'GMT-7', 'GMT-6', 'GMT-5', 'GMT-4', 'GMT-3', 'GMT-2', 'GMT-1', 'GMT', 'GMT+1', 'GMT+2', 'GMT+3', 'GMT+330', 'GMT+4', 'GMT+430', 'GMT+5', 'GMT+530', 'GMT+6', 'GMT+7', 'GMT+8', 'GMT+9', 'GMT+10', 'GMT+11', 'GMT+12'], group="Sessions")

ShowAsia = input.bool(defval = true, title="Show Asia Session", group="Sessions", inline="1")
ExtendAsia = input.bool(defval = false, title="Extend?", group="Sessions", inline="1")
AsiaOpen = input.bool(defval = false, title="Show Open?", group="Sessions", inline="1")
AsiaOpenCol = input.color(color.new(color.green,25), title="Open Colour", group="Sessions", inline="1")
AsiaSession = input.session("2200-0700:1234567", "Asia Session", group="Sessions", inline="2")
AsiaCol = input.color(color.new(color.green,90), "Colour", group="Sessions", inline="2")

ShowLon = input.bool(defval = true, title="Show London Session", group="Sessions", inline="4")
ExtendLon = input.bool(defval = false, title="Extend?", group="Sessions", inline="4")
LonOpen = input.bool(defval = false, title="Show Open?", group="Sessions", inline="4")
LonOpenCol = input.color(color.new(color.red,25), title="Open Colour", group="Sessions", inline="4")
LonSession = input.session("0800-1700:1234567", "London Session", group="Sessions", inline="5")
LonCol = input.color(color.new(color.red,90), "Colour", group="Sessions", inline="5")

ShowNY = input.bool(defval = true, title="Show NY Session", group="Sessions", inline="7")
ExtendNY = input.bool(defval = false, title="Extend?", group="Sessions", inline="7")
NYOpen = input.bool(defval = false, title="Show Open?", group="Sessions", inline="7")
NYOpenCol = input.color(color.new(color.aqua,25), title="Open Colour", group="Sessions", inline="7")
NYSession = input.session("1300-2100:1234567", "NY Session", group="Sessions", inline="8")
NYCol = input.color(color.new(color.aqua,90), "Colour", group="Sessions", inline="8")

i_show_history = input.bool(defval=false, title='History?', group="Sessions", inline="A")
i_sess_border_style = input.string(line.style_solid, 'Line Style', options=[line.style_solid, line.style_dotted, line.style_dashed], group="Sessions", inline="B")
i_sess_border_width = input.int(1, 'Line Width', minval=0, group="Sessions", inline="B")
i_sess_bgopacity = input.int(80, 'Background Transparency', minval=0, maxval=100, step=1, group="Sessions", inline="C")

ExtendMon = ExtendMonday ? extend.right : extend.none
ExtendPD = ExtendPrevDay ? extend.right : extend.none
ExtendPrevM = ExtendPrevMth ? extend.right : extend.none
ExtendPrevW = ExtendPrevWeek ? extend.right : extend.none
ExtendCurW = ExtendCurWeek ? extend.right : extend.none
ExtendCurM = ExtendCurMth ? extend.right : extend.none
ExtendWeekO = ExtendWeekOpen ? extend.right : extend.none
ExtendMthO = ExtendMthOpen ? extend.right : extend.none

ResolutionToSec(res)=>
    mins = res == "1" ? 1 :
           res == "3" ? 3 :
           res == "5" ? 5 :
           res == "10" ? 10 :
           res == "15" ? 15 :
           res == "30" ? 30 :
           res == "45" ? 45 :
           res == "60" ? 60 :
           res == "120" ? 120 :
           res == "180" ? 180 :
           res == "240" ? 240 :
           res == "D" or res == "1D" ? 1440 :
           res == "W" or res == "1W" ? 10080 :
           res == "M" or res == "1M" ? 43200 : 0
    mins * 60 * 1000

bar = ResolutionToSec(timeframe.period)

get_Monday()=>
    highs= array.new_float(0)
    lows= array.new_float(0)
    starttimes= array.new_int(0)
    for n = 0 to 6
        array.push(highs, high[n])
        array.push(lows, low[n])
        array.push(starttimes, time[n])
    [highs, lows, starttimes]

get_Weekly()=>
    highs= array.new_float(0)
    lows= array.new_float(0)
    opens = array.new_float(0)
    starttimes= array.new_int(0)
    for n = 0 to 1
        array.push(highs, high[n])
        array.push(lows, low[n])
        array.push(opens, open[n])
        array.push(starttimes, time[n])
    [highs, lows, opens, starttimes]

get_Monthly()=>
    highs= array.new_float(0)
    lows= array.new_float(0)
    opens = array.new_float(0)
    starttimes= array.new_int(0)
    for n = 0 to 1
        array.push(highs, high[n])
        array.push(lows, low[n])
        array.push(opens, open[n])
        array.push(starttimes, time[n])
    [highs, lows, opens, starttimes]

[mhighs, mlows, mstarttimes] = request.security(syminfo.tickerid, "1D", get_Monday(), lookahead = barmerge.lookahead_off)
[whighs, wlows, wopens, wstarttimes] = request.security(syminfo.tickerid, "1W", get_Weekly(), lookahead = barmerge.lookahead_off)
[mthhighs, mthlows, mthopens, mthstarttimes] = request.security(syminfo.tickerid, "1M", get_Monthly(), lookahead = barmerge.lookahead_off)

MHt = abr ? "MH" : "Monday High"
MLt = abr ? "ML" : "Monday Low"
MMt = abr ? "M.5" : "Monday 50%"
WHt = abr ? "WH" : "Weekly High"
WLt = abr ? "WL" : "Weekly Low"
WMt = abr ? "W.5" : "Weekly 50%"
PWHt = abr ? "PWH" : "Previous Week High"
PWLt = abr ? "PWL" : "Previous Week Low"
PWMt = abr ? "PW.5" : "Previous Week 50%"
PDHt = abr ? "PDH" : "Previous Day High"
PDLt = abr ? "PDL" : "Previous Day Low"
PDMt = abr ? "PD.5" : "Previous Day 50%"
MthHt = abr ? "MthH" : "Month High"
MthLt = abr ? "MthL" : "Month Low"
MthMt = abr ? "Mth.5" : "Month 50%"
PMthHt = abr ? "PMthH" : "Previous Month High"
PMthLt = abr ? "PMthL" : "Previous Month Low"
PMthMt = abr ? "PMth.5" : "Previous Month 50%"
WOt = abr ? "WO" : "Week Open"
MthOt = abr ? "MthO" : "Month Open"

MH_cross = false
ML_cross = false
Mm_cross = false
PDH_cross = false
PDL_cross = false
PDm_cross = false
WH_cross = false
WL_cross = false
Wm_cross = false
WO_cross = false
PWH_cross = false
PWL_cross = false
PWm_cross = false
PMthH_cross = false
PMthL_cross = false
PMthm_cross = false
MthH_cross = false
MthL_cross = false
Mthm_cross = false
MO_cross = false

f_label(_x, _y, _txt, _col) =>
    label.new(x=_x, y=_y, text=_txt, xloc=xloc.bar_time, color=color.new(color.black, 100), style=label.style_label_left, textcolor=_col, size=sz, textalign=text.align_left)

if bar_index == last_bar_index
    for x = 0 to array.size(mhighs)-1
        if dayofweek(array.get(mstarttimes, x), syminfo.timezone) == 2 and ShowMonday
            monX = array.get(mstarttimes, x)+(86400000*(dayofweek(timenow, syminfo.timezone)-1))+(bar*MonOff)
            MH = line.new(array.get(mstarttimes, x), array.get(mhighs, x), monX, array.get(mhighs, x), xloc=xloc.bar_time, extend=ExtendMon, color=MonHighCol, style=MonStyle, width=MonWidth)
            ML = line.new(array.get(mstarttimes, x), array.get(mlows, x), monX, array.get(mlows, x), xloc=xloc.bar_time, extend=ExtendMon, color=MonLowCol, style=MonStyle, width=MonWidth)
            line.delete(MH[1])
            line.delete(ML[1])
            MH_cross := ta.cross(close, array.get(mhighs, x))
            ML_cross := ta.cross(close, array.get(mlows, x))
            if MidMonday
                mid = array.get(mhighs, x)-(array.get(mhighs, x)-array.get(mlows, x))/2
                MM = line.new(array.get(mstarttimes, x), mid, monX, mid, xloc=xloc.bar_time, extend=ExtendMon, color=MonMidCol, style=MonStyle, width=MonWidth)
                Mm_cross := ta.cross(close, mid)
                line.delete(MM[1])
            if LabelMonday
                MHL = f_label(monX, array.get(mhighs, x)*1.0001, MHt, MonHighCol)
                MLL = f_label(monX, array.get(mlows, x)*1.0001, MLt, MonLowCol)
                label.delete(MHL[1])
                label.delete(MLL[1])

    if ShowPrevDay
        pdX = array.get(mstarttimes, 1)+(86400000*2)+(bar*PrevDayOff)
        PDH = line.new(array.get(mstarttimes, 1), array.get(mhighs, 1), pdX, array.get(mhighs, 1), xloc=xloc.bar_time, extend=ExtendPD, color=PrevDayHighCol, style=PrevDayStyle, width=PrevDayWidth)
        PDL = line.new(array.get(mstarttimes, 1), array.get(mlows, 1), pdX, array.get(mlows, 1), xloc=xloc.bar_time, extend=ExtendPD, color=PrevDayLowCol, style=PrevDayStyle, width=PrevDayWidth)
        line.delete(PDH[1])
        line.delete(PDL[1])
        PDH_cross := ta.cross(close, array.get(mhighs, 1))
        PDL_cross := ta.cross(close, array.get(mlows, 1))
        if LabelPrevDay
            PDHL = f_label(pdX, array.get(mhighs, 1)*1.0001, PDHt, PrevDayHighCol)
            PDLL = f_label(pdX, array.get(mlows, 1)*1.0001, PDLt, PrevDayLowCol)
            label.delete(PDHL[1])
            label.delete(PDLL[1])

    if ShowPrevWeek
        pwX = array.get(wstarttimes, 1)+(86400000*(dayofweek(timenow, syminfo.timezone)+6))+(bar*PrevWeekOff)
        PWH = line.new(array.get(wstarttimes, 1), array.get(whighs, 1), pwX, array.get(whighs, 1), xloc=xloc.bar_time, extend=ExtendPrevW, color=PrevWeekHighCol, style=PrevWeekStyle, width=PrevWeekWidth)
        PWL = line.new(array.get(wstarttimes, 1), array.get(wlows, 1), pwX, array.get(wlows, 1), xloc=xloc.bar_time, extend=ExtendPrevW, color=PrevWeekLowCol, style=PrevWeekStyle, width=PrevWeekWidth)
        line.delete(PWH[1])
        line.delete(PWL[1])
        PWH_cross := ta.cross(close, array.get(whighs, 1))
        PWL_cross := ta.cross(close, array.get(wlows, 1))
        if LabelPrevWeek
            PWHL = f_label(pwX, array.get(whighs, 1)*1.0001, PWHt, PrevWeekHighCol)
            PWLL = f_label(pwX, array.get(wlows, 1)*1.0001, PWLt, PrevWeekLowCol)
            label.delete(PWHL[1])
            label.delete(PWLL[1])

    if ShowCurWeek
        cwX = array.get(wstarttimes, 0)+(86400000*(dayofweek(timenow, syminfo.timezone)-1))+(bar*CurWeekOff)
        CWH = line.new(array.get(wstarttimes, 0), array.get(whighs, 0), cwX, array.get(whighs, 0), xloc=xloc.bar_time, extend=ExtendCurW, color=CurWeekHighCol, style=CurWeekStyle, width=CurWeekWidth)
        CWL = line.new(array.get(wstarttimes, 0), array.get(wlows, 0), cwX, array.get(wlows, 0), xloc=xloc.bar_time, extend=ExtendCurW, color=CurWeekLowCol, style=CurWeekStyle, width=CurWeekWidth)
        line.delete(CWH[1])
        line.delete(CWL[1])
        WH_cross := ta.cross(close, array.get(whighs, 0))
        WL_cross := ta.cross(close, array.get(wlows, 0))
        if LabelCurWeek
            CWHL = f_label(cwX, array.get(whighs, 0)*1.0001, WHt, CurWeekHighCol)
            CWLL = f_label(cwX, array.get(wlows, 0)*1.0001, WLt, CurWeekLowCol)
            label.delete(CWHL[1])
            label.delete(CWLL[1])

    if ShowPrevMth
        pmX = array.get(mthstarttimes, 1)+(86400000*(dayofmonth(timenow, syminfo.timezone)+31))+(bar*PrevMthOff)
        PMthH = line.new(array.get(mthstarttimes, 1), array.get(mthhighs, 1), pmX, array.get(mthhighs, 1), xloc=xloc.bar_time, extend=ExtendPrevM, color=PrevMthHighCol, style=PrevMthStyle, width=PrevMthWidth)
        PMthL = line.new(array.get(mthstarttimes, 1), array.get(mthlows, 1), pmX, array.get(mthlows, 1), xloc=xloc.bar_time, extend=ExtendPrevM, color=PrevMthLowCol, style=PrevMthStyle, width=PrevMthWidth)
        line.delete(PMthH[1])
        line.delete(PMthL[1])
        PMthH_cross := ta.cross(close, array.get(mthhighs, 1))
        PMthL_cross := ta.cross(close, array.get(mthlows, 1))
        if LabelPrevMth
            PMthHL = f_label(pmX, array.get(mthhighs, 1)*1.0001, PMthHt, PrevMthHighCol)
            PMthLL = f_label(pmX, array.get(mthlows, 1)*1.0001, PMthLt, PrevMthLowCol)
            label.delete(PMthHL[1])
            label.delete(PMthLL[1])

    if ShowCurMth
        cmX = array.get(mthstarttimes, 0)+(86400000*dayofmonth(timenow, syminfo.timezone))+(bar*CurMthOff)
        CMthH = line.new(array.get(mthstarttimes, 0), array.get(mthhighs, 0), cmX, array.get(mthhighs, 0), xloc=xloc.bar_time, extend=ExtendCurM, color=CurMthHighCol, style=CurMthStyle, width=CurMthWidth)
        CMthL = line.new(array.get(mthstarttimes, 0), array.get(mthlows, 0), cmX, array.get(mthlows, 0), xloc=xloc.bar_time, extend=ExtendCurM, color=CurMthLowCol, style=CurMthStyle, width=CurMthWidth)
        line.delete(CMthH[1])
        line.delete(CMthL[1])
        MthH_cross := ta.cross(close, array.get(mthhighs, 0))
        MthL_cross := ta.cross(close, array.get(mthlows, 0))
        if LabelCurMth
            CMthHL = f_label(cmX, array.get(mthhighs, 0)*1.0001, MthHt, CurMthHighCol)
            CMthLL = f_label(cmX, array.get(mthlows, 0)*1.0001, MthLt, CurMthLowCol)
            label.delete(CMthHL[1])
            label.delete(CMthLL[1])

    if ShowWeekOpen
        woX = array.get(wstarttimes, 0)+(86400000*(dayofweek(timenow, syminfo.timezone)-1))+(bar*CurWeekOff)
        WO = line.new(array.get(wstarttimes, 0), array.get(wopens, 0), woX, array.get(wopens, 0), xloc=xloc.bar_time, extend=ExtendWeekO, color=WeekOpenCol, style=WeekOpenStyle, width=WeekOpenWidth)
        line.delete(WO[1])
        WO_cross := ta.cross(close, array.get(wopens, 0))
        if LabelWeekOpen
            WOL = f_label(woX, array.get(wopens, 0)*1.0001, WOt, WeekOpenCol)
            label.delete(WOL[1])

    if ShowMthOpen
        moX = array.get(mthstarttimes, 0)+(86400000*dayofmonth(timenow, syminfo.timezone))+(bar*CurMthOff)
        MthO = line.new(array.get(mthstarttimes, 0), array.get(mthopens, 0), moX, array.get(mthopens, 0), xloc=xloc.bar_time, extend=ExtendMthO, color=MthOpenCol, style=MthOpenStyle, width=MthOpenWidth)
        line.delete(MthO[1])
        MO_cross := ta.cross(close, array.get(mthopens, 0))
        if LabelMthOpen
            MthOL = f_label(moX, array.get(mthopens, 0)*1.0001, MthOt, MthOpenCol)
            label.delete(MthOL[1])

max_bars = 500

f_get_period(_session, _start, _lookback) =>
    result = math.max(_start, 1)
    for i = result to _lookback
        if na(_session[i+1]) and _session[i]
            result := i+1
            break
    result

f_get_started(_session) => na(_session[1]) and _session
f_get_ended(_session) => na(_session) and _session[1]

i_lookback = 12 * 120

f_render_session(_show, _session, _showOpen, _is_started, _is_ended, _color, _openColor, _top, _bottom, _is_extend, _delete_history) =>
    var box my_box = na
    var line my_line = na
    var label my_label = na
    x0_1 = ta.valuewhen(na(_session[1]) and _session, bar_index, 1)
    x0_2 = ta.valuewhen(na(_session) and _session[1], bar_index, 0)
    var x1 = 0
    var x2 = 0
    var session_open = 0.0
    var session_high = 0.0
    var session_low = 0.0

    if _show
        if _is_started
            diff = math.abs(x0_2 - x0_1)
            x1 := bar_index
            x2 := bar_index + math.min(diff, max_bars)
            my_box := box.new(x1, _top, x2, _bottom, color.new(_color, i_sess_bgopacity/1.1), i_sess_border_width, i_sess_border_style, bgcolor=color.new(_color, i_sess_bgopacity))
            if _showOpen
                my_line := line.new(x1, open, x2, open, color=_openColor, extend=extend.none, style=i_sess_border_style, width=i_sess_border_width)
                my_label := label.new(x=x2-2, y=open, text=abr ? "O" : "Open", color=color.new(color.black, 100), style=label.style_label_left, textcolor=_openColor, size=sz, textalign=text.align_left)
            session_open := open
            session_high := _top
            session_low := _bottom
            if _is_extend
                box.set_extend(my_box, extend.right)
                line.set_extend(my_line, extend.right)
            if _delete_history
                box.delete(my_box[1])
                line.delete(my_line[1])
                label.delete(my_label[1])
        else if _session
            box.set_top(my_box, _top)
            box.set_bottom(my_box, _bottom)
            session_high := _top
            session_low := _bottom
        else if _is_ended
            session_open := na
            box.set_right(my_box, bar_index)

    [x1, x2, session_open, session_high, session_low]

draw(_show, _showOpen, _session, _color, _openColor, is_extend, _lookback) =>
    max = f_get_period(_session, 1, _lookback)
    top = ta.highest(high, max)
    bottom = ta.lowest(low, max)
    is_started = f_get_started(_session)
    is_ended = f_get_ended(_session)
    delete_history = not i_show_history or is_extend
    [_x1, _x2, _open, _high, _low] = f_render_session(_show, _session, _showOpen, is_started, is_ended, _color, _openColor, top, bottom, is_extend, delete_history)
    [_session, _open, _high, _low]

int sess1 = time(timeframe.period, AsiaSession, zone)
int sess2 = time(timeframe.period, LonSession, zone)
int sess3 = time(timeframe.period, NYSession, zone)

draw(ShowAsia, AsiaOpen, sess1, AsiaCol, AsiaOpenCol, ExtendAsia, i_lookback)
draw(ShowLon, LonOpen, sess2, LonCol, LonOpenCol, ExtendLon, i_lookback)
draw(ShowNY, NYOpen, sess3, NYCol, NYOpenCol, ExtendNY, i_lookback)

alertcondition(MH_cross, title="Crossing Monday High", message="Price Crossing Monday High")
alertcondition(ML_cross, title="Crossing Monday Low", message="Price Crossing Monday Low")
alertcondition(Mm_cross, title="Crossing Monday Mid", message="Price Crossing Monday Mid")
alertcondition(MH_cross or ML_cross or Mm_cross, title="Crossing ANY Monday Level", message="Price Crossing A Monday Level")

alertcondition(PDH_cross, title="Crossing Previous Day High", message="Price Crossing Previous Day High")
alertcondition(PDL_cross, title="Crossing Previous Day Low", message="Price Crossing Previous Day Low")
alertcondition(PDm_cross, title="Crossing Previous Day Mid", message="Price Crossing Previous Day Mid")
alertcondition(PDH_cross or PDL_cross or PDm_cross, title="Crossing ANY Previous Day Level", message="Price Crossing a Previous Day Level")

alertcondition(WH_cross, title="Crossing Current Week High", message="Price Crossing Current Week High")
alertcondition(WL_cross, title="Crossing Current Week Low", message="Price Crossing Current Week Low")
alertcondition(Wm_cross, title="Crossing Current Week Mid", message="Price Crossing Current Week Mid")
alertcondition(WO_cross, title="Crossing Current Week Open", message="Price Crossing Current Week Open")
alertcondition(WH_cross or WL_cross or Wm_cross or WO_cross, title="Crossing ANY Weekly Level", message="Price Crossing a Weekly Level")

alertcondition(PWH_cross, title="Crossing Previous Week High", message="Price Crossing Previous Week High")
alertcondition(PWL_cross, title="Crossing Previous Week Low", message="Price Crossing Previous Week Low")
alertcondition(PWm_cross, title="Crossing Previous Week Mid", message="Price Crossing Previous Week Mid")
alertcondition(PWH_cross or PWL_cross or PWm_cross, title="Crossing ANY Previous Week Level", message="Price Crossing a Previous Weekly Level")

alertcondition(MthH_cross, title="Crossing Current Month High", message="Price Crossing Current Month High")
alertcondition(MthL_cross, title="Crossing Current Month Low", message="Price Crossing Current Month Low")
alertcondition(Mthm_cross, title="Crossing Current Month Mid", message="Price Crossing Current Month Mid")
alertcondition(MO_cross, title="Crossing Current Month Open", message="Price Crossing Current Month Open")
alertcondition(MthH_cross or MthL_cross or Mthm_cross or MO_cross, title="Crossing ANY Monthly Level", message="Price Crossing a Monthly Level")

alertcondition(PMthH_cross, title="Crossing Previous Month High", message="Price Crossing Previous Month High")
alertcondition(PMthL_cross, title="Crossing Previous Month Low", message="Price Crossing Previous Month Low")
alertcondition(PMthm_cross, title="Crossing Previous Month Mid", message="Price Crossing Previous Month Mid")
alertcondition(PMthH_cross or PMthL_cross or PMthm_cross, title="Crossing ANY Previous Monthly Level", message="Price Crossing a Previous Monthly Level")
````
