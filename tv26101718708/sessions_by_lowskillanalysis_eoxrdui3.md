# Sessions by LowSkillAnalysis

- url: https://www.tradingview.com/script/eOxRduI3-Sessions-by-LowSkillAnalysis/
- type: indicator
- pine_id: PUB;9259f2510d2440ee987893953a432840
- version: 1.0

## Description

Custom Trading Sessions Highlighter

This indicator highlights the main trading sessions directly on the chart: Asia, Frankfurt, London, and New York.

You can choose between two visual modes: background highlights or session boxes. Each session has customizable time settings, colors, transparency, and optional labels.

The box mode tracks the high and low of each session and keeps the chart clean without extending drawings into the future.

Simple, clean, and fully customizable for intraday trading.

## Source Code

````pine
//@version=6
indicator("Sessions by LowSkillAnalysis", overlay=true, max_boxes_count=500, max_labels_count=500)

GROUP_GENERAL = "General Settings"
GROUP_ASIA = "Asia Session"
GROUP_FRANKFURT = "Frankfurt Session"
GROUP_LONDON = "London Session"
GROUP_NEW_YORK = "New York Session"
GROUP_BOX = "Box Style"
GROUP_LABELS = "Label Settings"

SESSION_TIMEZONE = "Europe/Vienna"

highlightType = input.string("Background", "Highlight Type", options=["Background", "Box"], group=GROUP_GENERAL)
showSessionLabels = input.bool(true, "Show Session Labels", group=GROUP_GENERAL)
showAllHistoricalSessions = input.bool(true, "Show All Historical Sessions", group=GROUP_GENERAL)

asiaEnabled = input.bool(true, "Enable Asia", group=GROUP_ASIA)
asiaSession = input.session("0200-0800", "Asia Session Time", group=GROUP_ASIA)
asiaColor = input.color(color.rgb(80, 150, 255), "Asia Color", group=GROUP_ASIA)
asiaTransparency = input.int(85, "Asia Transparency", minval=0, maxval=100, group=GROUP_ASIA)
asiaShowLabel = input.bool(true, "Show Asia Label", group=GROUP_ASIA)
asiaLabelText = input.string("Asia", "Asia Label Text", group=GROUP_ASIA)

frankfurtEnabled = input.bool(true, "Enable Frankfurt", group=GROUP_FRANKFURT)
frankfurtSession = input.session("0800-0900", "Frankfurt Session Time", group=GROUP_FRANKFURT)
frankfurtColor = input.color(color.rgb(255, 152, 0), "Frankfurt Color", group=GROUP_FRANKFURT)
frankfurtTransparency = input.int(85, "Frankfurt Transparency", minval=0, maxval=100, group=GROUP_FRANKFURT)
frankfurtShowLabel = input.bool(true, "Show Frankfurt Label", group=GROUP_FRANKFURT)
frankfurtLabelText = input.string("Frankfurt", "Frankfurt Label Text", group=GROUP_FRANKFURT)

londonEnabled = input.bool(true, "Enable London", group=GROUP_LONDON)
londonSession = input.session("0900-1400", "London Session Time", group=GROUP_LONDON)
londonColor = input.color(color.rgb(255, 95, 135), "London Color", group=GROUP_LONDON)
londonTransparency = input.int(85, "London Transparency", minval=0, maxval=100, group=GROUP_LONDON)
londonShowLabel = input.bool(true, "Show London Label", group=GROUP_LONDON)
londonLabelText = input.string("London", "London Label Text", group=GROUP_LONDON)

newYorkEnabled = input.bool(true, "Enable New York", group=GROUP_NEW_YORK)
newYorkSession = input.session("1430-1700", "New York Session Time", group=GROUP_NEW_YORK)
newYorkColor = input.color(color.rgb(175, 115, 255), "New York Color", group=GROUP_NEW_YORK)
newYorkTransparency = input.int(85, "New York Transparency", minval=0, maxval=100, group=GROUP_NEW_YORK)
newYorkShowLabel = input.bool(true, "Show New York Label", group=GROUP_NEW_YORK)
newYorkLabelText = input.string("New York", "New York Label Text", group=GROUP_NEW_YORK)

asiaBorderColor = input.color(color.rgb(80, 150, 255), "Asia Border Color", group=GROUP_BOX)
asiaBorderWidth = input.int(1, "Asia Border Width", minval=0, maxval=5, group=GROUP_BOX)
asiaBorderStyleInput = input.string("Solid", "Asia Border Style", options=["Solid", "Dashed", "Dotted"], group=GROUP_BOX)

frankfurtBorderColor = input.color(color.rgb(255, 152, 0), "Frankfurt Border Color", group=GROUP_BOX)
frankfurtBorderWidth = input.int(1, "Frankfurt Border Width", minval=0, maxval=5, group=GROUP_BOX)
frankfurtBorderStyleInput = input.string("Solid", "Frankfurt Border Style", options=["Solid", "Dashed", "Dotted"], group=GROUP_BOX)

londonBorderColor = input.color(color.rgb(255, 95, 135), "London Border Color", group=GROUP_BOX)
londonBorderWidth = input.int(1, "London Border Width", minval=0, maxval=5, group=GROUP_BOX)
londonBorderStyleInput = input.string("Solid", "London Border Style", options=["Solid", "Dashed", "Dotted"], group=GROUP_BOX)

newYorkBorderColor = input.color(color.rgb(175, 115, 255), "New York Border Color", group=GROUP_BOX)
newYorkBorderWidth = input.int(1, "New York Border Width", minval=0, maxval=5, group=GROUP_BOX)
newYorkBorderStyleInput = input.string("Solid", "New York Border Style", options=["Solid", "Dashed", "Dotted"], group=GROUP_BOX)

labelColor = input.color(color.rgb(30, 30, 30), "Label Color", group=GROUP_LABELS)
labelTextColor = input.color(color.white, "Label Text Color", group=GROUP_LABELS)
labelSizeInput = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal", "Large"], group=GROUP_LABELS)

asiaBorderStyle = asiaBorderStyleInput == "Dashed" ? line.style_dashed : asiaBorderStyleInput == "Dotted" ? line.style_dotted : line.style_solid
frankfurtBorderStyle = frankfurtBorderStyleInput == "Dashed" ? line.style_dashed : frankfurtBorderStyleInput == "Dotted" ? line.style_dotted : line.style_solid
londonBorderStyle = londonBorderStyleInput == "Dashed" ? line.style_dashed : londonBorderStyleInput == "Dotted" ? line.style_dotted : line.style_solid
newYorkBorderStyle = newYorkBorderStyleInput == "Dashed" ? line.style_dashed : newYorkBorderStyleInput == "Dotted" ? line.style_dotted : line.style_solid

sessionLabelSize = labelSizeInput == "Tiny" ? size.tiny : labelSizeInput == "Normal" ? size.normal : labelSizeInput == "Large" ? size.large : size.small

asiaRealBorderColor = asiaBorderWidth == 0 ? color.new(asiaBorderColor, 100) : asiaBorderColor
frankfurtRealBorderColor = frankfurtBorderWidth == 0 ? color.new(frankfurtBorderColor, 100) : frankfurtBorderColor
londonRealBorderColor = londonBorderWidth == 0 ? color.new(londonBorderColor, 100) : londonBorderColor
newYorkRealBorderColor = newYorkBorderWidth == 0 ? color.new(newYorkBorderColor, 100) : newYorkBorderColor

asiaRealBorderWidth = asiaBorderWidth == 0 ? 1 : asiaBorderWidth
frankfurtRealBorderWidth = frankfurtBorderWidth == 0 ? 1 : frankfurtBorderWidth
londonRealBorderWidth = londonBorderWidth == 0 ? 1 : londonBorderWidth
newYorkRealBorderWidth = newYorkBorderWidth == 0 ? 1 : newYorkBorderWidth

chartDayKey = year(time, SESSION_TIMEZONE) * 10000 + month(time, SESSION_TIMEZONE) * 100 + dayofmonth(time, SESSION_TIMEZONE)
lastChartDayKey = year(last_bar_time, SESSION_TIMEZONE) * 10000 + month(last_bar_time, SESSION_TIMEZONE) * 100 + dayofmonth(last_bar_time, SESSION_TIMEZONE)
showThisBar = showAllHistoricalSessions or chartDayKey == lastChartDayKey

asiaTime = time(timeframe.period, asiaSession, SESSION_TIMEZONE)
frankfurtTime = time(timeframe.period, frankfurtSession, SESSION_TIMEZONE)
londonTime = time(timeframe.period, londonSession, SESSION_TIMEZONE)
newYorkTime = time(timeframe.period, newYorkSession, SESSION_TIMEZONE)

asiaCloseTime = time_close(timeframe.period, asiaSession, SESSION_TIMEZONE)
frankfurtCloseTime = time_close(timeframe.period, frankfurtSession, SESSION_TIMEZONE)
londonCloseTime = time_close(timeframe.period, londonSession, SESSION_TIMEZONE)
newYorkCloseTime = time_close(timeframe.period, newYorkSession, SESSION_TIMEZONE)

inAsia = asiaEnabled and showThisBar and not na(asiaTime)
inFrankfurt = frankfurtEnabled and showThisBar and not na(frankfurtTime)
inLondon = londonEnabled and showThisBar and not na(londonTime)
inNewYork = newYorkEnabled and showThisBar and not na(newYorkTime)

asiaStart = inAsia and not (inAsia[1] == true)
frankfurtStart = inFrankfurt and not (inFrankfurt[1] == true)
londonStart = inLondon and not (inLondon[1] == true)
newYorkStart = inNewYork and not (inNewYork[1] == true)

sessionBgColor = highlightType != "Background" ? na : inNewYork ? color.new(newYorkColor, newYorkTransparency) : inLondon ? color.new(londonColor, londonTransparency) : inFrankfurt ? color.new(frankfurtColor, frankfurtTransparency) : inAsia ? color.new(asiaColor, asiaTransparency) : na
bgcolor(sessionBgColor, title="Session Background")

var float asiaHigh = na
var float asiaLow = na
var int asiaStartTime = na
var int asiaRightTime = na
var box asiaBox = na
var label asiaLabel = na

var float frankfurtHigh = na
var float frankfurtLow = na
var int frankfurtStartTime = na
var int frankfurtRightTime = na
var box frankfurtBox = na
var label frankfurtLabel = na

var float londonHigh = na
var float londonLow = na
var int londonStartTime = na
var int londonRightTime = na
var box londonBox = na
var label londonLabel = na

var float newYorkHigh = na
var float newYorkLow = na
var int newYorkStartTime = na
var int newYorkRightTime = na
var box newYorkBox = na
var label newYorkLabel = na

var int activeLastChartDayKey = na
newCurrentDay = not showAllHistoricalSessions and (na(activeLastChartDayKey) or activeLastChartDayKey != lastChartDayKey)

box.delete(newCurrentDay ? asiaBox : na)
label.delete(newCurrentDay ? asiaLabel : na)
box.delete(newCurrentDay ? frankfurtBox : na)
label.delete(newCurrentDay ? frankfurtLabel : na)
box.delete(newCurrentDay ? londonBox : na)
label.delete(newCurrentDay ? londonLabel : na)
box.delete(newCurrentDay ? newYorkBox : na)
label.delete(newCurrentDay ? newYorkLabel : na)

asiaBox := newCurrentDay ? na : asiaBox
asiaLabel := newCurrentDay ? na : asiaLabel
frankfurtBox := newCurrentDay ? na : frankfurtBox
frankfurtLabel := newCurrentDay ? na : frankfurtLabel
londonBox := newCurrentDay ? na : londonBox
londonLabel := newCurrentDay ? na : londonLabel
newYorkBox := newCurrentDay ? na : newYorkBox
newYorkLabel := newCurrentDay ? na : newYorkLabel
activeLastChartDayKey := newCurrentDay ? lastChartDayKey : activeLastChartDayKey

if asiaStart
    asiaHigh := high
    asiaLow := low
    asiaStartTime := asiaTime
    asiaRightTime := asiaCloseTime
    if highlightType == "Box"
        asiaBox := box.new(left=asiaStartTime, top=asiaHigh, right=asiaRightTime, bottom=asiaLow, xloc=xloc.bar_time, border_color=asiaRealBorderColor, border_width=asiaRealBorderWidth, border_style=asiaBorderStyle, extend=extend.none, bgcolor=color.new(asiaColor, asiaTransparency))
        asiaLabel := showSessionLabels and asiaShowLabel ? label.new(x=asiaStartTime, y=asiaHigh, text=asiaLabelText, xloc=xloc.bar_time, yloc=yloc.price, color=labelColor, textcolor=labelTextColor, style=label.style_label_down, size=sessionLabelSize) : na

if inAsia
    asiaHigh := math.max(asiaHigh, high)
    asiaLow := math.min(asiaLow, low)
    asiaRightTime := asiaCloseTime
    if highlightType == "Box" and not na(asiaBox)
        box.set_top(asiaBox, asiaHigh)
        box.set_bottom(asiaBox, asiaLow)
        box.set_right(asiaBox, asiaRightTime)
    if highlightType == "Box" and not na(asiaLabel)
        asiaLabelTime = asiaStartTime + int(math.floor((asiaRightTime - asiaStartTime) / 2))
        label.set_x(asiaLabel, asiaLabelTime)
        label.set_y(asiaLabel, asiaHigh)
        label.set_text(asiaLabel, asiaLabelText)

if frankfurtStart
    frankfurtHigh := high
    frankfurtLow := low
    frankfurtStartTime := frankfurtTime
    frankfurtRightTime := frankfurtCloseTime
    if highlightType == "Box"
        frankfurtBox := box.new(left=frankfurtStartTime, top=frankfurtHigh, right=frankfurtRightTime, bottom=frankfurtLow, xloc=xloc.bar_time, border_color=frankfurtRealBorderColor, border_width=frankfurtRealBorderWidth, border_style=frankfurtBorderStyle, extend=extend.none, bgcolor=color.new(frankfurtColor, frankfurtTransparency))
        frankfurtLabel := showSessionLabels and frankfurtShowLabel ? label.new(x=frankfurtStartTime, y=frankfurtHigh, text=frankfurtLabelText, xloc=xloc.bar_time, yloc=yloc.price, color=labelColor, textcolor=labelTextColor, style=label.style_label_down, size=sessionLabelSize) : na

if inFrankfurt
    frankfurtHigh := math.max(frankfurtHigh, high)
    frankfurtLow := math.min(frankfurtLow, low)
    frankfurtRightTime := frankfurtCloseTime
    if highlightType == "Box" and not na(frankfurtBox)
        box.set_top(frankfurtBox, frankfurtHigh)
        box.set_bottom(frankfurtBox, frankfurtLow)
        box.set_right(frankfurtBox, frankfurtRightTime)
    if highlightType == "Box" and not na(frankfurtLabel)
        frankfurtLabelTime = frankfurtStartTime + int(math.floor((frankfurtRightTime - frankfurtStartTime) / 2))
        label.set_x(frankfurtLabel, frankfurtLabelTime)
        label.set_y(frankfurtLabel, frankfurtHigh)
        label.set_text(frankfurtLabel, frankfurtLabelText)

if londonStart
    londonHigh := high
    londonLow := low
    londonStartTime := londonTime
    londonRightTime := londonCloseTime
    if highlightType == "Box"
        londonBox := box.new(left=londonStartTime, top=londonHigh, right=londonRightTime, bottom=londonLow, xloc=xloc.bar_time, border_color=londonRealBorderColor, border_width=londonRealBorderWidth, border_style=londonBorderStyle, extend=extend.none, bgcolor=color.new(londonColor, londonTransparency))
        londonLabel := showSessionLabels and londonShowLabel ? label.new(x=londonStartTime, y=londonHigh, text=londonLabelText, xloc=xloc.bar_time, yloc=yloc.price, color=labelColor, textcolor=labelTextColor, style=label.style_label_down, size=sessionLabelSize) : na

if inLondon
    londonHigh := math.max(londonHigh, high)
    londonLow := math.min(londonLow, low)
    londonRightTime := londonCloseTime
    if highlightType == "Box" and not na(londonBox)
        box.set_top(londonBox, londonHigh)
        box.set_bottom(londonBox, londonLow)
        box.set_right(londonBox, londonRightTime)
    if highlightType == "Box" and not na(londonLabel)
        londonLabelTime = londonStartTime + int(math.floor((londonRightTime - londonStartTime) / 2))
        label.set_x(londonLabel, londonLabelTime)
        label.set_y(londonLabel, londonHigh)
        label.set_text(londonLabel, londonLabelText)

if newYorkStart
    newYorkHigh := high
    newYorkLow := low
    newYorkStartTime := newYorkTime
    newYorkRightTime := newYorkCloseTime
    if highlightType == "Box"
        newYorkBox := box.new(left=newYorkStartTime, top=newYorkHigh, right=newYorkRightTime, bottom=newYorkLow, xloc=xloc.bar_time, border_color=newYorkRealBorderColor, border_width=newYorkRealBorderWidth, border_style=newYorkBorderStyle, extend=extend.none, bgcolor=color.new(newYorkColor, newYorkTransparency))
        newYorkLabel := showSessionLabels and newYorkShowLabel ? label.new(x=newYorkStartTime, y=newYorkHigh, text=newYorkLabelText, xloc=xloc.bar_time, yloc=yloc.price, color=labelColor, textcolor=labelTextColor, style=label.style_label_down, size=sessionLabelSize) : na

if inNewYork
    newYorkHigh := math.max(newYorkHigh, high)
    newYorkLow := math.min(newYorkLow, low)
    newYorkRightTime := newYorkCloseTime
    if highlightType == "Box" and not na(newYorkBox)
        box.set_top(newYorkBox, newYorkHigh)
        box.set_bottom(newYorkBox, newYorkLow)
        box.set_right(newYorkBox, newYorkRightTime)
    if highlightType == "Box" and not na(newYorkLabel)
        newYorkLabelTime = newYorkStartTime + int(math.floor((newYorkRightTime - newYorkStartTime) / 2))
        label.set_x(newYorkLabel, newYorkLabelTime)
        label.set_y(newYorkLabel, newYorkHigh)
        label.set_text(newYorkLabel, newYorkLabelText)
````
