# Open / Close Price 5pm

- url: https://www.tradingview.com/script/9AkmQney-Open-Close-Price-5pm/
- type: indicator
- pine_id: PUB;7e7e6a3520174e9ea269d8d8185700d2
- version: 1.0

## Description

5pm close.Sets daily close to 5pm for gold.  Original script was set to 4pm New York time.

## Source Code

````pine
//@version=5
indicator("Open / Close Price", overlay=true, max_lines_count=500)

daysBack = input.int(5, title="Days to Show", minval=1, maxval=100)

showOpenRay = input.bool(true, title="Show Open Lines?")
openRayColor = input.color(color.green, title="Open Line Color")
openRayWeight = input.int(1, title="Open Line Thickness", minval=1, maxval=5)
extendOpenLine = input.bool(false, title="Extend Open Line Fully Right?")
openLineExtendHours = input.int(23, title="Open Line Extension (Hours)", minval=1, maxval=168)

showCloseRay = input.bool(true, title="Show Close Lines?")
closeRayColor = input.color(color.red, title="Close Line Color")
closeRayWeight = input.int(1, title="Close Line Thickness", minval=1, maxval=5)
extendCloseLine = input.bool(false, title="Extend Close Line Fully Right?")
closeLineExtendHours = input.int(40, title="Close Line Extension (Hours)", minval=1, maxval=168)

shadeToggle = input.bool(true, title="Shade New Day Opening Gap?")
shadeBaseColor = input.color(color.blue, title="Shade Color")
shadeOpacity = input.int(90, title="Shade Opacity (0-100)", minval=0, maxval=100)
shadeColor = color.new(shadeBaseColor, shadeOpacity)
extendShading = input.bool(false, title="Extend Shading Fully Right?")
shadeHours = input.int(23, title="Shading Extension (Hours)", minval=1, maxval=168)

midRayToggle = input.bool(true, title="Show Midpoint of Gap Line?")
midRayColor = input.color(color.purple, title="Midpoint Line Color")
midRayWeight = input.int(1, title="Midpoint Line Thickness", minval=1, maxval=5)

var line[] openLines = array.new<line>()
var label[] openLabels = array.new<label>()

var line[] closeLines = array.new<line>()
var label[] closeLabels = array.new<label>()

var line[] midLines = array.new<line>()

var box[] shadingBoxes = array.new<box>()

var float open930 = na
var float close5PM = na
var float prevClose = na
var int openBarIndex = na

sessionOpenHour = 9
sessionOpenMinute = 30
sessionCloseHour = 17
sessionCloseMinute = 0

is930Bar = (hour(time, "America/New_York") == sessionOpenHour and minute(time, "America/New_York") == sessionOpenMinute) or (timeframe.isdaily and bar_index != bar_index[1])
is5PMBar = (hour(time, "America/New_York") == sessionCloseHour and minute(time, "America/New_York") == sessionCloseMinute) or (timeframe.isdaily and bar_index != bar_index[1])

maxBarsForward = 500
openLineBarsRight = extendOpenLine ? maxBarsForward : math.min(maxBarsForward, (openLineExtendHours * 60) / timeframe.multiplier)
closeLineBarsRight = extendCloseLine ? maxBarsForward : math.min(maxBarsForward, (closeLineExtendHours * 60) / timeframe.multiplier)

if is930Bar
    open930 := open  
    openBarIndex := bar_index  

if is930Bar and not na(open930) and showOpenRay
    openLine = line.new(x1=bar_index, y1=open930, x2=bar_index + openLineBarsRight, y2=open930, width=openRayWeight, color=openRayColor, extend=extend.none, xloc=xloc.bar_index)
    openDateLabel = str.tostring(month(time)) + "/" + str.tostring(dayofmonth(time)) + " Opening Price"
    openLabel = label.new(x=bar_index + 5, y=open930 + syminfo.mintick * 10, text=openDateLabel, textcolor=openRayColor, size=size.small, style=label.style_none, xloc=xloc.bar_index)
    array.push(openLines, openLine)
    array.push(openLabels, openLabel)

if is5PMBar
    close5PM := close  
    prevClose := close5PM  

if is5PMBar and not na(close5PM) and showCloseRay
    closeLine = line.new(x1=bar_index, y1=close5PM, x2=bar_index + closeLineBarsRight, y2=close5PM, width=closeRayWeight, color=closeRayColor, extend=extend.none, xloc=xloc.bar_index)
    closeDateLabel = str.tostring(month(time)) + "/" + str.tostring(dayofmonth(time)) + " Closing Price"
    closeLabel = label.new(x=bar_index + 5, y=close5PM + syminfo.mintick * 10, text=closeDateLabel, textcolor=closeRayColor, size=size.small, style=label.style_none, xloc=xloc.bar_index)
    array.push(closeLines, closeLine)
    array.push(closeLabels, closeLabel)

if shadeToggle and is930Bar and not na(prevClose) and not na(open930) and not na(openBarIndex)
    shadeBarsRight = extendShading ? maxBarsForward : math.min(maxBarsForward, (shadeHours * 60) / timeframe.multiplier)
    shadeBox = box.new(left=openBarIndex, right=openBarIndex + shadeBarsRight, top=math.max(prevClose, open930), bottom=math.min(prevClose, open930), bgcolor=shadeColor, border_width=0, xloc=xloc.bar_index)
    array.push(shadingBoxes, shadeBox)

    if midRayToggle
        midPrice = (prevClose + open930) / 2
        midLine = line.new(x1=openBarIndex, y1=midPrice, x2=openBarIndex + openLineBarsRight, y2=midPrice, width=midRayWeight, color=midRayColor, extend=extend.none, xloc=xloc.bar_index)
        array.push(midLines, midLine)

if array.size(openLines) > daysBack
    line.delete(array.shift(openLines))
    label.delete(array.shift(openLabels))

if array.size(closeLines) > daysBack
    line.delete(array.shift(closeLines))
    label.delete(array.shift(closeLabels))

if array.size(shadingBoxes) > daysBack
    box.delete(array.shift(shadingBoxes))

if array.size(midLines) > daysBack
    line.delete(array.shift(midLines))
````
