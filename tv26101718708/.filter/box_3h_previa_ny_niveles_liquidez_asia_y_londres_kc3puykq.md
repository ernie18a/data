# Box 3H previa NY & niveles liquidez Asia y Londres

- url: https://www.tradingview.com/script/Kc3PUYKQ/
- type: indicator
- pine_id: PUB;ec5286cba67844a3b563ade3f0e42a99
- version: 1.0

## Description

Rango 3h de vela de las 12:00 h hora española, para entrada a partir de las 15:30h con niveles de liquidez en sesiones de Asia y Londres

## Source Code

````pine
//@version=6
indicator("Caja 3H + Última Asia/London", overlay=true, max_boxes_count=100, max_lines_count=100, max_labels_count=100)

tz = input.string("Europe/Madrid", "Zona horaria")

//-------------------------
// CAJA 3H 12:00
//-------------------------
h3High = request.security(syminfo.tickerid, "180", high[1], lookahead=barmerge.lookahead_off)
h3Low  = request.security(syminfo.tickerid, "180", low[1], lookahead=barmerge.lookahead_off)
h3Time = request.security(syminfo.tickerid, "180", time[1], lookahead=barmerge.lookahead_off)
h3Now  = request.security(syminfo.tickerid, "180", time, lookahead=barmerge.lookahead_off)

nueva3H = ta.change(h3Now) != 0
hora3H  = hour(h3Time, tz)

if nueva3H and hora3H == 12
    derecha = h3Time + 9 * 60 * 60 * 1000

    box.new(
        left=h3Time,
        right=derecha,
        top=h3High,
        bottom=h3Low,
        xloc=xloc.bar_time,
        bgcolor=color.new(color.blue, 85),
        border_color=color.blue
    )

    t1530 = timestamp(tz, year(h3Time, tz), month(h3Time, tz), dayofmonth(h3Time, tz), 15, 30)

    line.new(
        x1=t1530,
        y1=h3High,
        x2=t1530,
        y2=h3Low,
        xloc=xloc.bar_time,
        color=color.red,
        width=1
    )

//-------------------------
// SESIONES
//-------------------------
asiaSession   = "0000-0800"
londonSession = "0800-1600"

enAsia   = not na(time(timeframe.period, asiaSession, tz))
enLondon = not na(time(timeframe.period, londonSession, tz))

asiaStart   = enAsia and not enAsia[1]
asiaEnd     = not enAsia and enAsia[1]

londonStart = enLondon and not enLondon[1]
londonEnd   = not enLondon and enLondon[1]

//-------------------------
// VARIABLES
//-------------------------
var float asiaHigh = na
var float asiaLow  = na
var int asiaHighTime = na
var int asiaLowTime  = na

var float londonHigh = na
var float londonLow  = na
var int londonHighTime = na
var int londonLowTime  = na

var line asiaHighLine = na
var line asiaLowLine = na
var label asiaHighLabel = na
var label asiaLowLabel = na

var line londonHighLine = na
var line londonLowLine = na
var label londonHighLabel = na
var label londonLowLabel = na

//-------------------------
// ASIA
//-------------------------
if asiaStart
    asiaHigh := high
    asiaLow := low
    asiaHighTime := time
    asiaLowTime := time

if enAsia
    if high > asiaHigh
        asiaHigh := high
        asiaHighTime := time
    if low < asiaLow
        asiaLow := low
        asiaLowTime := time

if asiaEnd
    line.delete(asiaHighLine)
    line.delete(asiaLowLine)
    label.delete(asiaHighLabel)
    label.delete(asiaLowLabel)

    derechaAsia = time + 24 * 60 * 60 * 1000

    asiaHighLine := line.new(asiaHighTime, asiaHigh, derechaAsia, asiaHigh, xloc=xloc.bar_time, color=color.yellow, width=1)
    asiaLowLine  := line.new(asiaLowTime, asiaLow, derechaAsia, asiaLow, xloc=xloc.bar_time, color=color.yellow, width=1)

    asiaHighLabel := label.new(derechaAsia, asiaHigh, "High AS", xloc=xloc.bar_time, style=label.style_none, textcolor=color.yellow, size=size.tiny)
    asiaLowLabel  := label.new(derechaAsia, asiaLow, "Low AS", xloc=xloc.bar_time, style=label.style_none, textcolor=color.yellow, size=size.tiny)

//-------------------------
// LONDON
//-------------------------
if londonStart
    londonHigh := high
    londonLow := low
    londonHighTime := time
    londonLowTime := time

if enLondon
    if high > londonHigh
        londonHigh := high
        londonHighTime := time
    if low < londonLow
        londonLow := low
        londonLowTime := time

if londonEnd
    line.delete(londonHighLine)
    line.delete(londonLowLine)
    label.delete(londonHighLabel)
    label.delete(londonLowLabel)

    derechaLondon = time + 24 * 60 * 60 * 1000

    londonHighLine := line.new(londonHighTime, londonHigh, derechaLondon, londonHigh, xloc=xloc.bar_time, color=color.green, width=1)
    londonLowLine  := line.new(londonLowTime, londonLow, derechaLondon, londonLow, xloc=xloc.bar_time, color=color.green, width=1)

    londonHighLabel := label.new(derechaLondon, londonHigh, "High LD", xloc=xloc.bar_time, style=label.style_none, textcolor=color.green, size=size.tiny)
    londonLowLabel  := label.new(derechaLondon, londonLow, "Low LD", xloc=xloc.bar_time, style=label.style_none, textcolor=color.green, size=size.tiny)
````
