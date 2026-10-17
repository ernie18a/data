# Quarter Theory - 3 Row Sessions

- url: https://www.tradingview.com/script/KeGdrDKv-Quarter-Theory-3-Row-Sessions/
- type: indicator
- pine_id: PUB;61c28b57f0294d1bb4f4271145b26807
- version: 1.0

## Description

Quarter Theory – 3 Row Sessions is a clean time-based mapping tool for traders who use weekly and intraday quarterly models.

The indicator visualizes the market week through fixed time blocks:
Mon, Tue, Wed, Thu — with daily sessions divided into PM, Asia, London, and AM based on New York time.

On 15m and 30m charts, the indicator also displays an additional micro-quarter row, splitting each 6-hour session into Q1, Q2, Q3, and Q4.

The layout is displayed in a separate pane with fixed vertical levels, keeping the structure clean, stable, and independent from price movement.

This tool is designed for traders using session timing, quarterly theory, ICT-style concepts, and intraday time-based analysis.

It is not a signal indicator and does not provide buy or sell recommendations.

## Source Code

````pine
//@version=5
indicator("Quarter Theory - 3 Row Sessions", overlay=false, max_boxes_count=500, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
tz = input.string("America/New_York", "Timezone")

showMicroRow = input.bool(true, "Show Top Row - Q1 Q2 Q3 Q4 on 15m/30m")
showSessionRow = input.bool(true, "Show Middle Row - PM Asia Lon AM")
showDayRow = input.bool(true, "Show Bottom Row - Mon Tue Wed Thu")
showLabels = input.bool(true, "Show Labels")

showFridaySessions = input.bool(true, "Show Friday Sessions without day box")
maxKeep = input.int(500, "Max Boxes To Keep", minval=100, maxval=500)

boxTransp = input.int(76, "Box Transparency", minval=0, maxval=100)
borderTransp = input.int(35, "Border Transparency", minval=0, maxval=100)

q1Color = input.color(color.rgb(178, 187, 214), "Q1 / Asia / Mon")
q2Color = input.color(color.rgb(222, 184, 193), "Q2 / London / Tue")
q3Color = input.color(color.rgb(184, 216, 188), "Q3 / AM / Wed")
q4Color = input.color(color.rgb(180, 190, 228), "Q4 / PM / Thu")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Fixed pane rows
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
microTop = 5.00
microBottom = 4.35

sessionTop = 4.35
sessionBottom = 3.45

dayTop = 3.45
dayBottom = 2.35

plot(5.20, title="Top Anchor", color=color.new(color.white, 100))
plot(2.20, title="Bottom Anchor", color=color.new(color.white, 100))

hline(5.00, "Top", color=color.new(color.gray, 85))
hline(4.35, "Micro/Session Split", color=color.new(color.gray, 65))
hline(3.45, "Session/Day Split", color=color.new(color.gray, 65))
hline(2.35, "Bottom", color=color.new(color.gray, 85))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Storage
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var box[] allBoxes = array.new_box()

f_keepBox(box b) =>
    array.push(allBoxes, b)
    if array.size(allBoxes) > maxKeep
        old = array.shift(allBoxes)
        box.delete(old)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Helper functions
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_qColor(int q) =>
    result = q4Color
    if q == 1
        result := q1Color
    else if q == 2
        result := q2Color
    else if q == 3
        result := q3Color
    result

f_addBox(int leftTime, int rightTime, float top, float bottom, color col, string txt, string txtSize) =>
    boxText = ""
    if showLabels
        boxText := txt

    textSize = size.tiny
    if txtSize == "small"
        textSize := size.small

    b = box.new(left=leftTime, right=rightTime, top=top, bottom=bottom, xloc=xloc.bar_time, bgcolor=color.new(col, boxTransp), border_color=color.new(color.black, borderTransp), text=boxText, text_color=color.rgb(45, 45, 45), text_size=textSize, text_halign=text.align_center, text_valign=text.align_center)
    f_keepBox(b)

f_barContains(int t) =>
    time <= t and time_close > t

f_sessionQByHour(int h) =>
    q = 4
    if h == 18
        q := 1
    else if h == 0
        q := 2
    else if h == 6
        q := 3
    else if h == 12
        q := 4
    q

f_sessionLabelByHour(int h) =>
    label = "PM"
    if h == 18
        label := "Asia"
    else if h == 0
        label := "Lon"
    else if h == 6
        label := "AM"
    else if h == 12
        label := "PM"
    label

f_drawMicroQuarters(int startTime, int endTime) =>
    dur = endTime - startTime

    t1 = startTime
    t2 = startTime + int(math.round(dur * 0.25))
    t3 = startTime + int(math.round(dur * 0.50))
    t4 = startTime + int(math.round(dur * 0.75))
    t5 = endTime

    f_addBox(t1, t2, microTop, microBottom, f_qColor(1), "Q1", "tiny")
    f_addBox(t2, t3, microTop, microBottom, f_qColor(2), "Q2", "tiny")
    f_addBox(t3, t4, microTop, microBottom, f_qColor(3), "Q3", "tiny")
    f_addBox(t4, t5, microTop, microBottom, f_qColor(4), "Q4", "tiny")

f_shouldShowSession(int startTime, int h) =>
    dow = dayofweek(startTime, tz)
    result = false

    if dow == dayofweek.sunday and h == 18
        result := true
    else if dow == dayofweek.monday
        result := true
    else if dow == dayofweek.tuesday
        result := true
    else if dow == dayofweek.wednesday
        result := true
    else if dow == dayofweek.thursday
        if h == 0 or h == 6 or h == 12
            result := true
        else if h == 18 and showFridaySessions
            result := true
    else if dow == dayofweek.friday
        if showFridaySessions and (h == 0 or h == 6 or h == 12)
            result := true

    result

f_drawSession(int startTime, int h, bool drawMicro) =>
    sixHours = 6 * 60 * 60 * 1000
    endTime = startTime + sixHours
    q = f_sessionQByHour(h)
    txt = f_sessionLabelByHour(h)

    if showSessionRow
        f_addBox(startTime, endTime, sessionTop, sessionBottom, f_qColor(q), txt, "tiny")

    if showMicroRow and drawMicro
        f_drawMicroQuarters(startTime, endTime)

f_dayLabelByStart(int startTime) =>
    dow = dayofweek(startTime, tz)
    label = ""

    if dow == dayofweek.sunday
        label := "Mon"
    else if dow == dayofweek.monday
        label := "Tue"
    else if dow == dayofweek.tuesday
        label := "Wed"
    else if dow == dayofweek.wednesday
        label := "Thu"

    label

f_dayQByStart(int startTime) =>
    dow = dayofweek(startTime, tz)
    q = 0

    if dow == dayofweek.sunday
        q := 1
    else if dow == dayofweek.monday
        q := 2
    else if dow == dayofweek.tuesday
        q := 3
    else if dow == dayofweek.wednesday
        q := 4

    q

f_drawDayQuarter(int startTime) =>
    oneDay = 24 * 60 * 60 * 1000
    endTime = startTime + oneDay
    q = f_dayQByStart(startTime)
    txt = f_dayLabelByStart(startTime)

    if q > 0 and showDayRow
        f_addBox(startTime, endTime, dayTop, dayBottom, f_qColor(q), txt, "tiny")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Time calculations
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
nyYear = year(time, tz)
nyMonth = month(time, tz)
nyDay = dayofmonth(time, tz)

tfSec = timeframe.in_seconds(timeframe.period)

// ב־15m / 30m מציגים גם את שורת ה־Q1 Q2 Q3 Q4
// ב־1H / 4H השורה העליונה לא תופיע
drawMicro = tfSec <= 1800

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Draw logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if timeframe.isintraday and barstate.isnew
    for offset = 0 to 1
        d = nyDay + offset

        t00 = timestamp(tz, nyYear, nyMonth, d, 0, 0)
        t06 = timestamp(tz, nyYear, nyMonth, d, 6, 0)
        t12 = timestamp(tz, nyYear, nyMonth, d, 12, 0)
        t18 = timestamp(tz, nyYear, nyMonth, d, 18, 0)

        if f_barContains(t00) and f_shouldShowSession(t00, 0)
            f_drawSession(t00, 0, drawMicro)

        if f_barContains(t06) and f_shouldShowSession(t06, 6)
            f_drawSession(t06, 6, drawMicro)

        if f_barContains(t12) and f_shouldShowSession(t12, 12)
            f_drawSession(t12, 12, drawMicro)

        if f_barContains(t18) and f_shouldShowSession(t18, 18)
            f_drawSession(t18, 18, drawMicro)

        if f_barContains(t18)
            f_drawDayQuarter(t18)
````
