# ORG with updated unfilled Portion

- url: https://www.tradingview.com/script/GLolCKXm/
- type: indicator
- pine_id: PUB;84dd0eaba6914497998e58ef81575dfc
- version: 1.0

## Description

This Indikator marks ORGs and updates unfilled Parts

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mnakatenus

//@version=6

indicator(title='RTH ORG Eighths', shorttitle='RTH ORG 1/8', overlay=true, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500)
day = math.round(6.5*1000*3600)
longDay = 24*1000*3600
isSPY = str.tostring(syminfo.ticker) =="SPY"? true:false
_16_00= timestamp('America/New_York', year, month, dayofmonth, 16, 00, 00)
_16_15= timestamp('America/New_York', year, month, dayofmonth, 16, 15, 00)
_9_30 = timestamp('America/New_York', year, month, dayofmonth, 9, 30, 00)
colorNone = color.new(color.white, 100)
showBox = input.bool(true, "Standard Gap (4:15pm close - 9:30am open)| ", inline = '-3' , group = 'boxes & midlines')
boxColor = input.color(color.new(color.red, 99), "Box", inline ='-3', group = 'boxes & midlines')

showRthGapLines = input.bool(true, "show gap lines", inline ='-2.5', group = 'boxes & midlines')
rthGapCol = input.color(color.new(color.black, 10), "", inline ='-2.5', group = 'boxes & midlines')
rthGapStyle = input.string(line.style_solid, "| style:", options = [line.style_solid, line.style_dotted, line.style_dashed, line.style_arrow_left, line.style_arrow_right, line.style_arrow_both], inline ='-2.5', group = 'boxes & midlines')
rthGapWidth = input.int(1, "| width", minval=1, maxval=4, inline ='-2.5', group = 'boxes & midlines')

showRthMidline = input.bool(true, "show midline", inline ='-2', group = 'boxes & midlines')
rthMidCol = input.color(color.red, "", inline ='-2', group = 'boxes & midlines')
rthMidStyle = input.string(line.style_dashed, "| style:", options = [line.style_solid, line.style_dotted, line.style_dashed, line.style_arrow_left, line.style_arrow_right, line.style_arrow_both], inline ='-2', group = 'boxes & midlines')

showRthEighthLines = input.bool(true, "show eighth lines", inline ='-1.5', group = 'boxes & midlines')
rthEighthCol = input.color(color.new(color.red, 50), "", inline ='-1.5', group = 'boxes & midlines')
rthEighthStyle = input.string(line.style_dotted, "| style:", options = [line.style_solid, line.style_dotted, line.style_dashed, line.style_arrow_left, line.style_arrow_right, line.style_arrow_both], inline ='-1.5', group = 'boxes & midlines')
rthEighthWidth = input.int(1, "| width", minval=1, maxval=4, inline ='-1.5', group = 'boxes & midlines')

showHiLoBox = input.bool(false, "High-low Gap (4:15pm - 9:30am) |", inline ='-1', group = 'boxes & midlines')
boxColor2 = input.color(color.new(color.gray, 90), "Box", inline ='-1', group = 'boxes & midlines')
borderColor2 = input.color(color.new(color.black, 90), "Border", inline ='-1', group = 'boxes & midlines')
showHiLoMidline = input.bool(false, "show midline", inline ='0', group = 'boxes & midlines')
HiLoMidCol = input.color(color.gray, "", inline ='0', group = 'boxes & midlines')
HiLoMidStyle = input.string(line.style_dashed, "| style:", options = [line.style_solid, line.style_dotted, line.style_dashed, line.style_arrow_left, line.style_arrow_right, line.style_arrow_both], inline ='0', group = 'boxes & midlines')

boxesToShow = input.int(4, "historical Boxes & Midlines to show", inline = '1', group = 'boxes & midlines')
showTxt = input.bool(false, "Box text", inline='2', group = 'boxes & midlines')
boxTxtCol = input.color(color.new(color.gray, 30), "", inline ='2', group = 'boxes & midlines')
txtValignChoice = input.string(text.align_center, "Position:", options = [text.align_top, text.align_center, text.align_bottom], inline ='2', group = 'boxes & midlines')
txtHalignChoice = input.string(text.align_right, "", options = [text.align_center, text.align_left, text.align_right], inline ='2', group = 'boxes & midlines')
extendBoxRight = input.bool(true, "extend boxes & midlines right", inline ='3', group = 'boxes & midlines')
bufferBars = input.int(15, "| buffer bars", minval=0, inline ='3', group = 'boxes & midlines')

openOffset = input.int(0, "+/- offset (minutes) from 9:30am NY time", step = 5, group = 'time adjustment (for non-USA based Indices)')
closeOffset = input.int(0, "+/- offset (minutes) from 4:15pm NY time", step = 5, group = 'time adjustment (for non-USA based Indices)')

linesToShow = input.int(1, "historical RTH close Lines & labels to show", group = 'RTH close lines & labels')
showRTHcloseLine = input.bool(true, "show prev RTH close line", inline ='2', group = 'RTH close lines & labels')
RTHcloseColor = input.color(color.new(color.red, 10), "", inline ='2', group = 'RTH close lines & labels')
extendLineRight = input.bool(true, "extend lines right", inline ='3', group = 'RTH close lines & labels')
linestyleRTH = input.string(line.style_dotted, "| style:", options = [line.style_solid, line.style_dotted, line.style_dashed, line.style_arrow_left, line.style_arrow_right, line.style_arrow_both], inline ='3', group = 'RTH close lines & labels')
RTH_line_width = input.int(1, "| width", options = [1,2,3,4], inline ='3', group = 'RTH close lines & labels')
extChoiceLine = extendLineRight?extend.right:extend.none

unfillCol = input.color(color.new(color.green, 80), "Unfilled Gap Color", group = 'Unfilled Gap')

_minute = 1000*60
rthClose = isSPY? ta.valuewhen(time_close == _16_00 + closeOffset*_minute, close, 0): ta.valuewhen(time_close ==_16_15 + closeOffset*_minute, close, 0)

var string G_LABELS = "Label Settings"
showLabels  = input.bool(true,  "Show Labels", group=G_LABELS)
labelColor  = input.color(color.black, "Label Color", group=G_LABELS)
labelSizeIn = input.string("Tiny", "Label Size", options=["Tiny", "Small", "Normal", "Large"], group=G_LABELS)

getLabelSize(size) => size == "Tiny" ? size.tiny : size == "Small" ? size.small : size == "Large" ? size.large : size.normal

formatDateFromTime(int t) =>
    mon = month(t)
    dy = dayofmonth(t)
    str.format("{0}/{1}", mon < 10 ? "0" + str.tostring(mon) : str.tostring(mon), dy < 10 ? "0" + str.tostring(dy) : str.tostring(dy))

useNoPlotSession = input.bool(false, "Use no plot session", group = "no plot session", inline='1')
inputSession1 = input.session('1600-0830', title='stop painting boxes/lines during these hours', group = "no plot session", inline='2')
inSession1 = not na(time(timeframe.period, str.tostring(inputSession1), "America/New_York"))
barTime = timeframe.in_seconds(timeframe.period)*1000
buffer_ms = bufferBars * barTime
extended_time = last_bar_time + buffer_ms

var int t1 = 0
var box bx = na
var array<box> boxArr = array.new<box>(0)
var line lnRthMid = na
var array<line> lnRthMidArr = array.new<line>(0)

var array<box>   unfillBoxArr  = array.new<box>(0)
var array<float> unfillTopArr  = array.new<float>(0)
var array<float> unfillBtmArr  = array.new<float>(0)
var array<bool>  unfillDoneArr = array.new<bool>(0)
var array<label> unfillLblArr  = array.new<label>(0)

rthMidVal = math.min(rthClose, open) + 0.5* math.abs(rthClose-open)
gapLow = math.min(rthClose, open)
gapSize = math.abs(rthClose - open)

rth125Val = gapLow + 0.125 * gapSize
rth25Val  = gapLow + 0.25  * gapSize
rth375Val = gapLow + 0.375 * gapSize
rth625Val = gapLow + 0.625 * gapSize
rth75Val  = gapLow + 0.75  * gapSize
rth875Val = gapLow + 0.875 * gapSize

rthGapHigh = math.max(rthClose, open)
rthGapLow  = math.min(rthClose, open)

if time == (_9_30 + openOffset*_minute) and showBox
    bx := box.new(time, rthClose, extended_time, open, xloc = xloc.bar_time, bgcolor = boxColor, border_color = na, extend = extend.none, text = showTxt?"rth >>"+formatDateFromTime(time):"", text_color = boxTxtCol, text_size = size.small, text_valign = txtValignChoice, text_halign = txtHalignChoice)
    array.push(boxArr, bx)
    if array.size(boxArr) > boxesToShow
        box.delete(array.shift(boxArr))

    ufTop = math.max(rthClose, open)
    ufBtm = math.min(rthClose, open)
    dStr = formatDateFromTime(time)
    ufBox = box.new(time, ufTop, extended_time, ufBtm, xloc = xloc.bar_time, bgcolor = unfillCol, border_color = na, extend = extend.none)
    ufLbl = label.new(extended_time, ufBtm + 0.5*(ufTop-ufBtm), dStr, xloc = xloc.bar_time, yloc = yloc.price, color = color.new(color.white, 100), textcolor = color.new(color.green, 20), style = label.style_label_left, size = getLabelSize(labelSizeIn))
    array.push(unfillBoxArr,  ufBox)
    array.push(unfillTopArr,  ufTop)
    array.push(unfillBtmArr,  ufBtm)
    array.push(unfillDoneArr, false)
    array.push(unfillLblArr,  ufLbl)
    if array.size(unfillBoxArr) > boxesToShow
        box.delete(array.shift(unfillBoxArr))
        array.shift(unfillTopArr)
        array.shift(unfillBtmArr)
        array.shift(unfillDoneArr)
        label.delete(array.shift(unfillLblArr))

var line lnRthGapHigh = na
var array<line> lnRthGapHighArr = array.new<line>(0)
var line lnRthGapLow = na
var array<line> lnRthGapLowArr = array.new<line>(0)

var label labOrgHigh = na
var array<label> labOrgHighArr = array.new<label>(0)
var label labOrgLow = na
var array<label> labOrgLowArr = array.new<label>(0)
var label labOrgEq = na
var array<label> labOrgEqArr = array.new<label>(0)

var label labOrg125 = na
var array<label> labOrg125Arr = array.new<label>(0)
var label labOrg25 = na
var array<label> labOrg25Arr = array.new<label>(0)
var label labOrg375 = na
var array<label> labOrg375Arr = array.new<label>(0)
var label labOrg625 = na
var array<label> labOrg625Arr = array.new<label>(0)
var label labOrg75 = na
var array<label> labOrg75Arr = array.new<label>(0)
var label labOrg875 = na
var array<label> labOrg875Arr = array.new<label>(0)

if time == (_9_30 + openOffset*_minute) and showRthGapLines
    lnRthGapHigh := line.new(time, rthGapHigh, extended_time, rthGapHigh, xloc = xloc.bar_time, color = rthGapCol, style = rthGapStyle, width = rthGapWidth, extend = extend.none)
    array.push(lnRthGapHighArr, lnRthGapHigh)
    if array.size(lnRthGapHighArr) > boxesToShow
        line.delete(array.shift(lnRthGapHighArr))
    lnRthGapLow := line.new(time, rthGapLow, extended_time, rthGapLow, xloc = xloc.bar_time, color = rthGapCol, style = rthGapStyle, width = rthGapWidth, extend = extend.none)
    array.push(lnRthGapLowArr, lnRthGapLow)
    if array.size(lnRthGapLowArr) > boxesToShow
        line.delete(array.shift(lnRthGapLowArr))
    if showLabels
        dStr = formatDateFromTime(time)
        labOrgHigh := label.new(time, rthGapHigh, "ORG HIGH " + dStr, xloc=xloc.bar_time, yloc=yloc.price, color=color.new(color.white, 100), textcolor=labelColor, style=label.style_label_left, size=getLabelSize(labelSizeIn))
        array.push(labOrgHighArr, labOrgHigh)
        if array.size(labOrgHighArr) > boxesToShow
            label.delete(array.shift(labOrgHighArr))
        labOrgLow := label.new(time, rthGapLow, "ORG LOW " + dStr, xloc=xloc.bar_time, yloc=yloc.price, color=color.new(color.white, 100), textcolor=labelColor, style=label.style_label_left, size=getLabelSize(labelSizeIn))
        array.push(labOrgLowArr, labOrgLow)
        if array.size(labOrgLowArr) > boxesToShow
            label.delete(array.shift(labOrgLowArr))

if time == (_9_30 + openOffset*_minute) and showRthMidline
    lnRthMid := line.new(time, rthMidVal, extended_time, rthMidVal, xloc = xloc.bar_time, color = rthMidCol, style = rthMidStyle, width = 1, extend = extend.none)
    array.push(lnRthMidArr, lnRthMid)
    if array.size(lnRthMidArr) > boxesToShow
        line.delete(array.shift(lnRthMidArr))
    if showLabels
        dStr = formatDateFromTime(time)
        labOrgEq := label.new(time, rthMidVal, "ORG C.E. " + dStr, xloc=xloc.bar_time, yloc=yloc.price, color=color.new(color.white, 100), textcolor=labelColor, style=label.style_label_left, size=getLabelSize(labelSizeIn))
        array.push(labOrgEqArr, labOrgEq)
        if array.size(labOrgEqArr) > boxesToShow
            label.delete(array.shift(labOrgEqArr))

var line lnRth125 = na
var array<line> lnRth125Arr = array.new<line>(0)
var line lnRth25 = na
var array<line> lnRth25Arr = array.new<line>(0)
var line lnRth375 = na
var array<line> lnRth375Arr = array.new<line>(0)
var line lnRth625 = na
var array<line> lnRth625Arr = array.new<line>(0)
var line lnRth75 = na
var array<line> lnRth75Arr = array.new<line>(0)
var line lnRth875 = na
var array<line> lnRth875Arr = array.new<line>(0)

if time == (_9_30 + openOffset*_minute) and showRthEighthLines
    lnRth125 := line.new(time, rth125Val, extended_time, rth125Val, xloc = xloc.bar_time, color = rthEighthCol, style = rthEighthStyle, width = rthEighthWidth, extend = extend.none)
    array.push(lnRth125Arr, lnRth125)
    if array.size(lnRth125Arr) > boxesToShow
        line.delete(array.shift(lnRth125Arr))
    lnRth25 := line.new(time, rth25Val, extended_time, rth25Val, xloc = xloc.bar_time, color = rthEighthCol, style = rthEighthStyle, width = rthEighthWidth, extend = extend.none)
    array.push(lnRth25Arr, lnRth25)
    if array.size(lnRth25Arr) > boxesToShow
        line.delete(array.shift(lnRth25Arr))
    lnRth375 := line.new(time, rth375Val, extended_time, rth375Val, xloc = xloc.bar_time, color = rthEighthCol, style = rthEighthStyle, width = rthEighthWidth, extend = extend.none)
    array.push(lnRth375Arr, lnRth375)
    if array.size(lnRth375Arr) > boxesToShow
        line.delete(array.shift(lnRth375Arr))
    lnRth625 := line.new(time, rth625Val, extended_time, rth625Val, xloc = xloc.bar_time, color = rthEighthCol, style = rthEighthStyle, width = rthEighthWidth, extend = extend.none)
    array.push(lnRth625Arr, lnRth625)
    if array.size(lnRth625Arr) > boxesToShow
        line.delete(array.shift(lnRth625Arr))
    lnRth75 := line.new(time, rth75Val, extended_time, rth75Val, xloc = xloc.bar_time, color = rthEighthCol, style = rthEighthStyle, width = rthEighthWidth, extend = extend.none)
    array.push(lnRth75Arr, lnRth75)
    if array.size(lnRth75Arr) > boxesToShow
        line.delete(array.shift(lnRth75Arr))
    lnRth875 := line.new(time, rth875Val, extended_time, rth875Val, xloc = xloc.bar_time, color = rthEighthCol, style = rthEighthStyle, width = rthEighthWidth, extend = extend.none)
    array.push(lnRth875Arr, lnRth875)
    if array.size(lnRth875Arr) > boxesToShow
        line.delete(array.shift(lnRth875Arr))
    if showLabels
        dStr = formatDateFromTime(time)
        labOrg125 := label.new(time, rth125Val, ".125 " + dStr, xloc=xloc.bar_time, yloc=yloc.price, color=color.new(color.white, 100), textcolor=labelColor, style=label.style_label_left, size=getLabelSize(labelSizeIn))
        array.push(labOrg125Arr, labOrg125)
        if array.size(labOrg125Arr) > boxesToShow
            label.delete(array.shift(labOrg125Arr))
        labOrg25 := label.new(time, rth25Val, ".25 " + dStr, xloc=xloc.bar_time, yloc=yloc.price, color=color.new(color.white, 100), textcolor=labelColor, style=label.style_label_left, size=getLabelSize(labelSizeIn))
        array.push(labOrg25Arr, labOrg25)
        if array.size(labOrg25Arr) > boxesToShow
            label.delete(array.shift(labOrg25Arr))
        labOrg375 := label.new(time, rth375Val, ".375 " + dStr, xloc=xloc.bar_time, yloc=yloc.price, color=color.new(color.white, 100), textcolor=labelColor, style=label.style_label_left, size=getLabelSize(labelSizeIn))
        array.push(labOrg375Arr, labOrg375)
        if array.size(labOrg375Arr) > boxesToShow
            label.delete(array.shift(labOrg375Arr))
        labOrg625 := label.new(time, rth625Val, ".625 " + dStr, xloc=xloc.bar_time, yloc=yloc.price, color=color.new(color.white, 100), textcolor=labelColor, style=label.style_label_left, size=getLabelSize(labelSizeIn))
        array.push(labOrg625Arr, labOrg625)
        if array.size(labOrg625Arr) > boxesToShow
            label.delete(array.shift(labOrg625Arr))
        labOrg75 := label.new(time, rth75Val, ".75 " + dStr, xloc=xloc.bar_time, yloc=yloc.price, color=color.new(color.white, 100), textcolor=labelColor, style=label.style_label_left, size=getLabelSize(labelSizeIn))
        array.push(labOrg75Arr, labOrg75)
        if array.size(labOrg75Arr) > boxesToShow
            label.delete(array.shift(labOrg75Arr))
        labOrg875 := label.new(time, rth875Val, ".875 " + dStr, xloc=xloc.bar_time, yloc=yloc.price, color=color.new(color.white, 100), textcolor=labelColor, style=label.style_label_left, size=getLabelSize(labelSizeIn))
        array.push(labOrg875Arr, labOrg875)
        if array.size(labOrg875Arr) > boxesToShow
            label.delete(array.shift(labOrg875Arr))

four15Hi = isSPY? ta.valuewhen(time_close == _16_00 + closeOffset*_minute, high, 0): ta.valuewhen(time_close ==_16_15 + closeOffset*_minute, high, 0)
four15Lo = isSPY? ta.valuewhen(time_close == _16_00 + closeOffset*_minute, low, 0): ta.valuewhen(time_close ==_16_15 + closeOffset*_minute, low, 0)
four15HiLo = low>four15Hi?four15Hi:high<four15Lo?four15Lo:na
HiLo = low>four15Hi? low:high<four15Lo?high:na
var box bx2 = na
var array<box> boxArr2 = array.new<box>(0)
var line lnHiLoMid = na
var array<line> lnHiLoMidArr = array.new<line>(0)
HiLoMidVal = math.min(four15HiLo, HiLo) + 0.5* math.abs(four15HiLo-HiLo)
if time == (_9_30 + openOffset*_minute) and showHiLoBox
    bx2 := box.new(time, four15HiLo, extended_time, HiLo, xloc = xloc.bar_time, bgcolor = boxColor2, border_color = borderColor2, extend = extend.none, text = showTxt?"hilo >>"+formatDateFromTime(time):"", text_color = boxTxtCol, text_size = size.small, text_valign = txtValignChoice, text_halign = txtHalignChoice)
    array.push(boxArr2, bx2)
    if array.size(boxArr2) > boxesToShow
        box.delete(array.shift(boxArr2))
if time == (_9_30 + openOffset*_minute) and showHiLoMidline
    lnHiLoMid := line.new(time, HiLoMidVal, extended_time, HiLoMidVal, xloc = xloc.bar_time, color = HiLoMidCol, style = HiLoMidStyle, width = 1, extend = extend.none)
    array.push(lnHiLoMidArr, lnHiLoMid)
    if array.size(lnHiLoMidArr) > boxesToShow
        line.delete(array.shift(lnHiLoMidArr))

var line line = na
var array<line> lineArr = array.new<line>(0)
condRTHclose = isSPY? session.islastbar_regular: (time ==_16_15 + closeOffset*_minute)
if condRTHclose
    line := line.new(time_close, isSPY?close:close[1], extendLineRight?extended_time:time+longDay, isSPY?close:close[1], xloc=xloc.bar_time, color = showRTHcloseLine?RTHcloseColor:colorNone, extend = extend.none, style=linestyleRTH, width = RTH_line_width)
    array.push(lineArr, line)
    if array.size(lineArr) > linesToShow
        line.delete(array.shift(lineArr))

if inSession1
    t1 += barTime
if not inSession1 and inSession1[1]
    t1 := 0

update_time = useNoPlotSession ? extended_time - t1 : extended_time

// Unfilled gap update
if unfillBoxArr.size() > 0
    for i = 0 to unfillBoxArr.size()-1
        if not unfillDoneArr.get(i)
            curTop = unfillTopArr.get(i)
            curBtm = unfillBtmArr.get(i)
            // Preis hat von oben in die Box hereingereicht -> Obergrenze auf Low der Kerze senken
            if low < curTop and high >= curTop
                curTop := low
                unfillTopArr.set(i, curTop)
            // Preis hat von unten in die Box hereingereicht -> Untergrenze auf High der Kerze heben
            if high > curBtm and low <= curBtm
                curBtm := high
                unfillBtmArr.set(i, curBtm)
            // Komplett gefüllt wenn Kerze den gesamten Bereich durchquert hat
            if low <= curBtm and high >= curTop
                unfillDoneArr.set(i, true)
                box.delete(unfillBoxArr.get(i))
                label.delete(unfillLblArr.get(i))
            else if curTop <= curBtm
                unfillDoneArr.set(i, true)
                box.delete(unfillBoxArr.get(i))
                label.delete(unfillLblArr.get(i))
            else
                box.set_top(unfillBoxArr.get(i), curTop)
                box.set_bottom(unfillBoxArr.get(i), curBtm)
                box.set_right(unfillBoxArr.get(i), update_time)
                label.set_y(unfillLblArr.get(i), curBtm + 0.5 * (curTop - curBtm))
                label.set_x(unfillLblArr.get(i), update_time)

if extendBoxRight
    if boxArr.size() > 0
        for i = boxArr.size()-1 to 0
            box.set_right(boxArr.get(i), update_time)
    if boxArr2.size() > 0
        for i = boxArr2.size()-1 to 0
            box.set_right(boxArr2.get(i), update_time)
    if lnRthMidArr.size() > 0
        for i = lnRthMidArr.size()-1 to 0
            line.set_x2(lnRthMidArr.get(i), update_time)
    if lnHiLoMidArr.size() > 0
        for i = lnHiLoMidArr.size()-1 to 0
            line.set_x2(lnHiLoMidArr.get(i), update_time)
    if lnRth125Arr.size() > 0
        for i = lnRth125Arr.size()-1 to 0
            line.set_x2(lnRth125Arr.get(i), update_time)
    if lnRth25Arr.size() > 0
        for i = lnRth25Arr.size()-1 to 0
            line.set_x2(lnRth25Arr.get(i), update_time)
    if lnRth375Arr.size() > 0
        for i = lnRth375Arr.size()-1 to 0
            line.set_x2(lnRth375Arr.get(i), update_time)
    if lnRth625Arr.size() > 0
        for i = lnRth625Arr.size()-1 to 0
            line.set_x2(lnRth625Arr.get(i), update_time)
    if lnRth75Arr.size() > 0
        for i = lnRth75Arr.size()-1 to 0
            line.set_x2(lnRth75Arr.get(i), update_time)
    if lnRth875Arr.size() > 0
        for i = lnRth875Arr.size()-1 to 0
            line.set_x2(lnRth875Arr.get(i), update_time)
    if lnRthGapHighArr.size() > 0
        for i = lnRthGapHighArr.size()-1 to 0
            line.set_x2(lnRthGapHighArr.get(i), update_time)
    if lnRthGapLowArr.size() > 0
        for i = lnRthGapLowArr.size()-1 to 0
            line.set_x2(lnRthGapLowArr.get(i), update_time)
    if labOrgHighArr.size() > 0
        for i = labOrgHighArr.size()-1 to 0
            label.set_x(labOrgHighArr.get(i), update_time)
    if labOrgLowArr.size() > 0
        for i = labOrgLowArr.size()-1 to 0
            label.set_x(labOrgLowArr.get(i), update_time)
    if labOrgEqArr.size() > 0
        for i = labOrgEqArr.size()-1 to 0
            label.set_x(labOrgEqArr.get(i), update_time)
    if labOrg125Arr.size() > 0
        for i = labOrg125Arr.size()-1 to 0
            label.set_x(labOrg125Arr.get(i), update_time)
    if labOrg25Arr.size() > 0
        for i = labOrg25Arr.size()-1 to 0
            label.set_x(labOrg25Arr.get(i), update_time)
    if labOrg375Arr.size() > 0
        for i = labOrg375Arr.size()-1 to 0
            label.set_x(labOrg375Arr.get(i), update_time)
    if labOrg625Arr.size() > 0
        for i = labOrg625Arr.size()-1 to 0
            label.set_x(labOrg625Arr.get(i), update_time)
    if labOrg75Arr.size() > 0
        for i = labOrg75Arr.size()-1 to 0
            label.set_x(labOrg75Arr.get(i), update_time)
    if labOrg875Arr.size() > 0
        for i = labOrg875Arr.size()-1 to 0
            label.set_x(labOrg875Arr.get(i), update_time)

if extendLineRight
    if lineArr.size() > 0
        for i = lineArr.size()-1 to 0
            line.set_x2(lineArr.get(i), update_time)
````
