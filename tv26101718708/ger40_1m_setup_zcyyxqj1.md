# GER40 / 1M Setup

- url: https://www.tradingview.com/script/zcyyXqj1-GER40-1M-Setup/
- type: indicator
- pine_id: PUB;4cafa28bf23446709fd6b865126b9596
- version: 7.0

## Description

The indicator for the 1M GER40 strategy displays Frankfurt IB, OTT trading sessions, and also marks long or short breakouts.

Video: https://www.youtube.com/watch?v=autJAPRwTYA&t=295s

## Source Code

````pine
//@version=6
indicator('GER40 / 1M TOS Setup', overlay = true)

mainSession = input.session('0900-1000', 'Торговое окно (UTC+3)')
colBox     = input.color(color.new(#4ecdc4, 75), 'Заливка 0–1')
colL       = input.color(#ffffff, 'Цвет линий и подписей')
labelPos   = input.string('Право', 'Позиция подписей', options = ['Лево', 'Центр', 'Право'])
colGreen   = input.color(#00c853, 'Цвет начала сессии', group = 'Вертикальные линии')
colRed     = input.color(#ff1744, 'Цвет конца сессии',  group = 'Вертикальные линии')
colArrowUp = input.color(#00e676, 'Цвет стрелки вверх', group = 'Пробития')
colArrowDn = input.color(#ff1744, 'Цвет стрелки вниз',  group = 'Пробития')
showL18    = input.bool(true,     'Показывать уровень 1.8',  group = 'Дополнительные уровни')
colL18     = input.color(#ffeb3b, 'Цвет линии 1.8 (BE)',    group = 'Дополнительные уровни')

inWindow = not na(time(timeframe.period, mainSession, 'Europe/Kiev'))
inArrow  = not na(time(timeframe.period, '1000-1100', 'Europe/Kiev'))
isAt10   = not na(time(timeframe.period, '1000-1001', 'Europe/Kiev'))
isAt11   = not na(time(timeframe.period, '1100-1101', 'Europe/Kiev'))

var float sHigh    = na
var float sLow     = na
var int   startBar = na
var array<line>  zoneLines = array.new_line()
var array<float> lvlsArr   = array.new_float()
var bool broke0Up = false
var bool broke0Dn = false
var bool broke1Up = false
var bool broke1Dn = false

var line  linePos15 = na
var line  linePos18 = na
var line  linePos2  = na
var line  lineNeg15 = na
var line  lineNeg18 = na
var line  lineNeg2  = na
var float lvlPos15  = na
var float lvlPos18  = na
var float lvlPos2   = na
var float lvlNeg15  = na
var float lvlNeg18  = na
var float lvlNeg2   = na
var int   savedStart = na
var int   savedBend  = na
var int   savedFar   = na
var int   savedMid   = na
var int   savedGap   = na

if isAt10
    broke0Up := false
    broke0Dn := false
    broke1Up := false
    broke1Dn := false
    linePos15 := na
    linePos18 := na
    linePos2  := na
    lineNeg15 := na
    lineNeg18 := na
    lineNeg2  := na
    line.new(bar_index, low, bar_index, high, color = colGreen, width = 1, style = line.style_dashed, extend = extend.both)

if inWindow and not inWindow[1]
    sHigh    := high
    sLow     := low
    startBar := bar_index

if inWindow
    sHigh := math.max(sHigh, high)
    sLow  := math.min(sLow, low)

if isAt11
    line.new(bar_index, low, bar_index, high, color = colRed, width = 1, style = line.style_dashed, extend = extend.both)
    for l in zoneLines
        line.set_x2(l, bar_index)
    if not na(linePos15)
        line.set_x2(linePos15, bar_index)
    if not na(linePos18)
        line.set_x2(linePos18, bar_index)
    if not na(linePos2)
        line.set_x2(linePos2, bar_index)
    if not na(lineNeg15)
        line.set_x2(lineNeg15, bar_index)
    if not na(lineNeg18)
        line.set_x2(lineNeg18, bar_index)
    if not na(lineNeg2)
        line.set_x2(lineNeg2, bar_index)

if not inWindow and inWindow[1] and not na(sHigh)
    array.clear(zoneLines)
    array.clear(lvlsArr)
    rng    = sHigh - sLow
    lvls   = array.from(sLow - rng, sLow - rng * 0.5, sLow, sLow + rng * 0.5, sHigh, sLow + rng * 1.5, sLow + rng * 2.0)
    lbls   = array.from('-2', '-1.5', '0', '0.5', '1', '1.5', '2')
    stls   = array.from(line.style_solid, line.style_dashed, line.style_solid, line.style_dashed, line.style_solid, line.style_dashed, line.style_solid)
    bEnd   = bar_index
    midBar = math.round((startBar + bEnd) / 2)
    gap    = math.round((bEnd - startBar) / 20)
    far    = bEnd + 60

    savedStart := startBar
    savedBend  := bEnd
    savedFar   := far
    savedMid   := midBar
    savedGap   := gap

    for i = 0 to 6 by 1
        array.push(lvlsArr, array.get(lvls, i))

    lvlNeg2  := array.get(lvls, 0)
    lvlNeg18 := sLow - rng * 0.8
    lvlNeg15 := array.get(lvls, 1)
    lvlPos15 := array.get(lvls, 5)
    lvlPos18 := sLow + rng * 1.8
    lvlPos2  := array.get(lvls, 6)

    box.new(startBar, sHigh, bEnd, sLow, border_color = na, bgcolor = colBox)

    for i = 2 to 4 by 1
        v  = array.get(lvls, i)
        st = array.get(stls, i)
        lb = array.get(lbls, i)
        if labelPos == 'Лево'
            l = line.new(startBar, v, far, v, color = colL, width = 1, style = st)
            array.push(zoneLines, l)
            label.new(startBar, v, lb, style = label.style_label_right, color = na, textcolor = colL, size = size.small)
        else if labelPos == 'Центр'
            line.new(startBar, v, midBar - gap, v, color = colL, width = 1, style = st)
            l2 = line.new(midBar + gap, v, far, v, color = colL, width = 1, style = st)
            array.push(zoneLines, l2)
            label.new(midBar, v, lb, style = label.style_label_center, color = na, textcolor = colL, size = size.small)
        else
            l = line.new(startBar, v, far, v, color = colL, width = 1, style = st)
            array.push(zoneLines, l)
            label.new(bEnd, v, lb, style = label.style_label_left, color = na, textcolor = colL, size = size.small)

brokeUp = false
brokeDn = false

if inArrow and array.size(lvlsArr) == 7
    lvl0 = array.get(lvlsArr, 2)
    lvl1 = array.get(lvlsArr, 4)

    if not broke0Up and not broke0Dn and close > lvl0 and close[1] <= lvl0
        brokeUp  := true
        broke0Up := true

    if not broke0Up and not broke0Dn and close < lvl0 and close[1] >= lvl0
        brokeDn  := true
        broke0Dn := true
        if labelPos == 'Лево'
            lineNeg15 := line.new(savedStart, lvlNeg15, savedFar, lvlNeg15, color = colL,   width = 1, style = line.style_dashed)
            lineNeg2  := line.new(savedStart, lvlNeg2,  savedFar, lvlNeg2,  color = colL,   width = 1, style = line.style_solid)
            label.new(savedStart, lvlNeg15, '-1.5',      style = label.style_label_right, color = na, textcolor = colL,   size = size.small)
            label.new(savedStart, lvlNeg2,  '-2',        style = label.style_label_right, color = na, textcolor = colL,   size = size.small)
            if showL18
                lineNeg18 := line.new(savedStart, lvlNeg18, savedFar, lvlNeg18, color = colL18, width = 1, style = line.style_dashed)
                label.new(savedStart, lvlNeg18, '-1.8', style = label.style_label_right, color = na, textcolor = colL18, size = size.small)
        else if labelPos == 'Центр'
            line.new(savedStart, lvlNeg15, savedMid - savedGap,     lvlNeg15, color = colL,   width = 1, style = line.style_dashed)
            lineNeg15 := line.new(savedMid + savedGap,     lvlNeg15, savedFar, lvlNeg15, color = colL,   width = 1, style = line.style_dashed)
            line.new(savedStart, lvlNeg2,  savedMid - savedGap,     lvlNeg2,  color = colL,   width = 1, style = line.style_solid)
            lineNeg2  := line.new(savedMid + savedGap,     lvlNeg2,  savedFar, lvlNeg2,  color = colL,   width = 1, style = line.style_solid)
            label.new(savedMid, lvlNeg15, '-1.5', style = label.style_label_center, color = na, textcolor = colL,   size = size.small)
            label.new(savedMid, lvlNeg2,  '-2',   style = label.style_label_center, color = na, textcolor = colL,   size = size.small)
            if showL18
                line.new(savedStart, lvlNeg18, savedMid - savedGap, lvlNeg18, color = colL18, width = 1, style = line.style_dashed)
                lineNeg18 := line.new(savedMid + savedGap, lvlNeg18, savedFar, lvlNeg18, color = colL18, width = 1, style = line.style_dashed)
                label.new(savedMid, lvlNeg18, '-1.8', style = label.style_label_center, color = na, textcolor = colL18, size = size.small)
        else
            lineNeg15 := line.new(savedStart, lvlNeg15, savedFar, lvlNeg15, color = colL,   width = 1, style = line.style_dashed)
            lineNeg2  := line.new(savedStart, lvlNeg2,  savedFar, lvlNeg2,  color = colL,   width = 1, style = line.style_solid)
            label.new(savedBend, lvlNeg15, '-1.5',      style = label.style_label_left, color = na, textcolor = colL,   size = size.small)
            label.new(savedBend, lvlNeg2,  '-2',        style = label.style_label_left, color = na, textcolor = colL,   size = size.small)
            if showL18
                lineNeg18 := line.new(savedStart, lvlNeg18, savedFar, lvlNeg18, color = colL18, width = 1, style = line.style_dashed)
                label.new(savedBend, lvlNeg18, '-1.8', style = label.style_label_left, color = na, textcolor = colL18, size = size.small)

    if not broke1Up and not broke1Dn and close > lvl1 and close[1] <= lvl1
        brokeUp  := true
        broke1Up := true
        if labelPos == 'Лево'
            linePos15 := line.new(savedStart, lvlPos15, savedFar, lvlPos15, color = colL, width = 1, style = line.style_dashed)
            linePos2  := line.new(savedStart, lvlPos2,  savedFar, lvlPos2,  color = colL, width = 1, style = line.style_solid)
            label.new(savedStart, lvlPos15, '1.5',      style = label.style_label_right, color = na, textcolor = colL, size = size.small)
            label.new(savedStart, lvlPos2,  '2',        style = label.style_label_right, color = na, textcolor = colL, size = size.small)
            if showL18
                linePos18 := line.new(savedStart, lvlPos18, savedFar, lvlPos18, color = colL18, width = 1, style = line.style_dashed)
                label.new(savedStart, lvlPos18, '1.8', style = label.style_label_right, color = na, textcolor = colL18, size = size.small)
        else if labelPos == 'Центр'
            line.new(savedStart, lvlPos15, savedMid - savedGap, lvlPos15, color = colL, width = 1, style = line.style_dashed)
            linePos15 := line.new(savedMid + savedGap, lvlPos15, savedFar, lvlPos15, color = colL, width = 1, style = line.style_dashed)
            line.new(savedStart, lvlPos2,  savedMid - savedGap, lvlPos2,  color = colL, width = 1, style = line.style_solid)
            linePos2  := line.new(savedMid + savedGap, lvlPos2,  savedFar, lvlPos2,  color = colL, width = 1, style = line.style_solid)
            label.new(savedMid, lvlPos15, '1.5',      style = label.style_label_center, color = na, textcolor = colL, size = size.small)
            label.new(savedMid, lvlPos2,  '2',        style = label.style_label_center, color = na, textcolor = colL, size = size.small)
            if showL18
                line.new(savedStart, lvlPos18, savedMid - savedGap, lvlPos18, color = colL18, width = 1, style = line.style_dashed)
                linePos18 := line.new(savedMid + savedGap, lvlPos18, savedFar, lvlPos18, color = colL18, width = 1, style = line.style_dashed)
                label.new(savedMid, lvlPos18, '1.8', style = label.style_label_center, color = na, textcolor = colL18, size = size.small)
        else
            linePos15 := line.new(savedStart, lvlPos15, savedFar, lvlPos15, color = colL, width = 1, style = line.style_dashed)
            linePos2  := line.new(savedStart, lvlPos2,  savedFar, lvlPos2,  color = colL, width = 1, style = line.style_solid)
            label.new(savedBend, lvlPos15, '1.5',      style = label.style_label_left, color = na, textcolor = colL, size = size.small)
            label.new(savedBend, lvlPos2,  '2',        style = label.style_label_left, color = na, textcolor = colL, size = size.small)
            if showL18
                linePos18 := line.new(savedStart, lvlPos18, savedFar, lvlPos18, color = colL18, width = 1, style = line.style_dashed)
                label.new(savedBend, lvlPos18, '1.8', style = label.style_label_left, color = na, textcolor = colL18, size = size.small)

    if not broke1Up and not broke1Dn and close < lvl1 and close[1] >= lvl1
        brokeDn  := true
        broke1Dn := true

plotshape(brokeUp, location = location.belowbar, style = shape.triangleup,   color = colArrowUp, size = size.tiny, title = 'Пробой вверх')
plotshape(brokeDn, location = location.abovebar, style = shape.triangledown, color = colArrowDn, size = size.tiny, title = 'Пробой вниз')
````
