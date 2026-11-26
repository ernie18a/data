# Fed Chair Changes + Daily Returns 1,3,6,12 months 

- url: https://www.tradingview.com/script/AamnXoon-Fed-Chair-Changes-Daily-Returns-1-3-6-12-months/
- type: indicator
- pine_id: PUB;e2b363ba77514a629cac6916c14a3960
- version: 1.0

## Description

To look at the changes in price following changes in Fed Chairs

## Source Code

````pine
//@version=6
indicator("Fed Chair Changes + Daily Returns", overlay=true, max_labels_count=50, max_lines_count=50)

// ===== Inputs =====
showPowellReappointment = input.bool(false, "Show Powell reappointment (2022)")
showNextScheduledChange = input.bool(true, "Show next scheduled change (2026)")
showAboveBars           = input.bool(true, "Place labels above bars")
liftATR                 = input.float(1.2, "Label lift (ATR multiple)", minval=0.2, step=0.1)
lineWidth               = input.int(1, "Connector width", minval=1, maxval=4)

// ===== Event timestamps =====
ts_volcker   = timestamp("America/New_York", 1979, 08, 06, 00, 00)
ts_greenspan = timestamp("America/New_York", 1987, 08, 11, 00, 00)
ts_bernanke  = timestamp("America/New_York", 2006, 02, 01, 00, 00)
ts_yellen    = timestamp("America/New_York", 2014, 02, 03, 00, 00)
ts_powell    = timestamp("America/New_York", 2018, 02, 05, 00, 00)
ts_powell2   = timestamp("America/New_York", 2022, 05, 23, 00, 00)
ts_next      = timestamp("America/New_York", 2026, 05, 15, 00, 00)

// ===== Helpers =====
fmtPct(v) =>
    na(v) ? "n/a" : str.tostring(v, "#.##") + "%"

isEventBar(ts) =>
    time >= ts and (na(time[1]) or time[1] < ts)

// ===== Daily return engine =====
dailyReturnCalc(ts, barsForward) =>
    ev = time >= ts and (na(time[1]) or time[1] < ts)
    evBar = ta.valuewhen(ev, bar_index, 0)
    evClose = ta.valuewhen(ev, close, 0)
    ta.valuewhen(bar_index == evBar + barsForward, (close / evClose - 1.0) * 100.0, 0)

getReturn(ts, barsForward) =>
    request.security(syminfo.tickerid, "D", dailyReturnCalc(ts, barsForward), barmerge.gaps_off, barmerge.lookahead_off)

// ===== Returns =====
v1  = getReturn(ts_volcker, 21)
v3  = getReturn(ts_volcker, 63)
v6  = getReturn(ts_volcker, 126)
v12 = getReturn(ts_volcker, 252)

g1  = getReturn(ts_greenspan, 21)
g3  = getReturn(ts_greenspan, 63)
g6  = getReturn(ts_greenspan, 126)
g12 = getReturn(ts_greenspan, 252)

b1  = getReturn(ts_bernanke, 21)
b3  = getReturn(ts_bernanke, 63)
b6  = getReturn(ts_bernanke, 126)
b12 = getReturn(ts_bernanke, 252)

y1  = getReturn(ts_yellen, 21)
y3  = getReturn(ts_yellen, 63)
y6  = getReturn(ts_yellen, 126)
y12 = getReturn(ts_yellen, 252)

p1  = getReturn(ts_powell, 21)
p3  = getReturn(ts_powell, 63)
p6  = getReturn(ts_powell, 126)
p12 = getReturn(ts_powell, 252)

p21  = getReturn(ts_powell2, 21)
p23  = getReturn(ts_powell2, 63)
p26  = getReturn(ts_powell2, 126)
p212 = getReturn(ts_powell2, 252)

n1  = getReturn(ts_next, 21)
n3  = getReturn(ts_next, 63)
n6  = getReturn(ts_next, 126)
n12 = getReturn(ts_next, 252)

// ===== Store event locations during chart scan =====
var int   x_volcker = na
var float h_volcker = na
var float l_volcker = na
var float a_volcker = na

var int   x_greenspan = na
var float h_greenspan = na
var float l_greenspan = na
var float a_greenspan = na

var int   x_bernanke = na
var float h_bernanke = na
var float l_bernanke = na
var float a_bernanke = na

var int   x_yellen = na
var float h_yellen = na
var float l_yellen = na
var float a_yellen = na

var int   x_powell = na
var float h_powell = na
var float l_powell = na
var float a_powell = na

var int   x_powell2 = na
var float h_powell2 = na
var float l_powell2 = na
var float a_powell2 = na

var int   x_next = na
var float h_next = na
var float l_next = na
var float a_next = na

atrv = ta.atr(14)

if na(x_volcker) and isEventBar(ts_volcker)
    x_volcker := bar_index
    h_volcker := high
    l_volcker := low
    a_volcker := atrv

if na(x_greenspan) and isEventBar(ts_greenspan)
    x_greenspan := bar_index
    h_greenspan := high
    l_greenspan := low
    a_greenspan := atrv

if na(x_bernanke) and isEventBar(ts_bernanke)
    x_bernanke := bar_index
    h_bernanke := high
    l_bernanke := low
    a_bernanke := atrv

if na(x_yellen) and isEventBar(ts_yellen)
    x_yellen := bar_index
    h_yellen := high
    l_yellen := low
    a_yellen := atrv

if na(x_powell) and isEventBar(ts_powell)
    x_powell := bar_index
    h_powell := high
    l_powell := low
    a_powell := atrv

if na(x_powell2) and isEventBar(ts_powell2)
    x_powell2 := bar_index
    h_powell2 := high
    l_powell2 := low
    a_powell2 := atrv

if na(x_next) and isEventBar(ts_next)
    x_next := bar_index
    h_next := high
    l_next := low
    a_next := atrv

// ===== Draw once =====
var bool drawn = false

drawStored(x, h, l, a, name, dateTxt, col, r1, r3, r6, r12) =>
    if not na(x) and not na(h) and not na(l) and not na(a)
        yAnchor = showAboveBars ? h : l
        yLabel  = showAboveBars ? h + a * liftATR : l - a * liftATR

        txt = name
        txt := txt + "\n" + dateTxt
        txt := txt + "\n1M: " + fmtPct(r1)
        txt := txt + "\n3M: " + fmtPct(r3)
        txt := txt + "\n6M: " + fmtPct(r6)
        txt := txt + "\n12M: " + fmtPct(r12)

        line.new(x1=x, y1=yAnchor, x2=x, y2=yLabel, xloc=xloc.bar_index, extend=extend.none, color=col, width=lineWidth)
        label.new(x=x, y=yLabel, text=txt, xloc=xloc.bar_index, style=showAboveBars ? label.style_label_down : label.style_label_up, color=col, textcolor=color.white, size=size.small)

if barstate.islast and not drawn
    drawStored(x_volcker, h_volcker, l_volcker, a_volcker, "Volcker", "Aug 6, 1979", color.blue, v1, v3, v6, v12)
    drawStored(x_greenspan, h_greenspan, l_greenspan, a_greenspan, "Greenspan", "Aug 11, 1987", color.blue, g1, g3, g6, g12)
    drawStored(x_bernanke, h_bernanke, l_bernanke, a_bernanke, "Bernanke", "Feb 1, 2006", color.blue, b1, b3, b6, b12)
    drawStored(x_yellen, h_yellen, l_yellen, a_yellen, "Yellen", "Feb 3, 2014", color.blue, y1, y3, y6, y12)
    drawStored(x_powell, h_powell, l_powell, a_powell, "Powell", "Feb 5, 2018", color.blue, p1, p3, p6, p12)

    if showPowellReappointment
        drawStored(x_powell2, h_powell2, l_powell2, a_powell2, "Powell (Re)", "May 23, 2022", color.orange, p21, p23, p26, p212)

    if showNextScheduledChange
        drawStored(x_next, h_next, l_next, a_next, "Next Chair?", "May 15, 2026", color.red, n1, n3, n6, n12)

    drawn := true

// ===== Debug markers so you can confirm event bars are found =====
plotshape(not na(x_volcker) and bar_index == x_volcker, title="Volcker marker", style=shape.circle, location=location.abovebar, size=size.tiny, color=color.blue)
plotshape(not na(x_greenspan) and bar_index == x_greenspan, title="Greenspan marker", style=shape.circle, location=location.abovebar, size=size.tiny, color=color.blue)
plotshape(not na(x_bernanke) and bar_index == x_bernanke, title="Bernanke marker", style=shape.circle, location=location.abovebar, size=size.tiny, color=color.blue)
plotshape(not na(x_yellen) and bar_index == x_yellen, title="Yellen marker", style=shape.circle, location=location.abovebar, size=size.tiny, color=color.blue)
plotshape(not na(x_powell) and bar_index == x_powell, title="Powell marker", style=shape.circle, location=location.abovebar, size=size.tiny, color=color.blue)
plotshape(showPowellReappointment and not na(x_powell2) and bar_index == x_powell2, title="Powell2 marker", style=shape.circle, location=location.abovebar, size=size.tiny, color=color.orange)
plotshape(showNextScheduledChange and not na(x_next) and bar_index == x_next, title="Next marker", style=shape.circle, location=location.abovebar, size=size.tiny, color=color.red)
````
