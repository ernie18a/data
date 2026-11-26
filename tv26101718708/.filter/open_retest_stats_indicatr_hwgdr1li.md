# Open Retest Stats [Indicatr]

- url: https://www.tradingview.com/script/HwGdR1LI-Open-Retest-Stats-Indicatr/
- type: indicator
- pine_id: PUB;aa7780c9ae534905abd94d13c951d4d7
- version: 1.0

## Description

[b]Open Retest Stats[/b] answers a simple question with data from the chart itself: once price has moved away from the daily or weekly open, how often does it come back to it - and how long does that usually take?

[b]WHAT IT DOES[/b]
The daily and weekly open are reference prices that many intraday traders watch. This script tracks every period on the chart, records whether price returned to the open after leaving it, and shows the result as a retest rate, the median time to the retest and the historical chance of a retest from the current distance.

[b]HOW IT WORKS[/b]
[list=1]
[*][b]Leaving the open:[/b] a retest only counts after price has first moved away from the open by at least 0.15 x the average range of that period type (average daily range for the daily open, average weekly range for the weekly open). Without this filter almost every first bar would be a retest.
[*][b]Retest:[/b] a later bar of the same period trades through the open again.
[*][b]Statistics:[/b] for the last 250 periods the script stores whether a retest happened, the maximum distance before it and the number of bars it took.
[*][b]From here:[/b] while price is away, the table shows how often the open was retested in past periods that had moved at least as far away as the current one (shown once there are at least 10 such cases).
[*][b]No lookahead:[/b] everything is built from completed bars of the chart, nothing repaints into the past.
[/list]

[b]HOW TO USE[/b]
[list]
[*]Yellow line = daily open, blue line = weekly open (monthly open optional).
[*]The shaded gradient shows the stretch between price and the daily open while price is away and has not come back yet.
[*]Green dot = the open was retested. Red cross = the period ended without a retest.
[*]A high retest rate and a short median time can support mean-reversion ideas towards the open; a low rate from the current distance suggests a trending session - for long and short alike.
[*]Alerts: daily open retested, weekly open retested, monthly open retested, price left the daily open.
[/list]

[b]THE CHART[/b]
Gold (XAUUSD) 1 hour with daily and weekly open. The shaded areas show the distance while price was away from the daily open; days that ended without a retest are marked with a red cross, retests with a green dot. The labels on the right show the current daily and weekly open with their retest rates. The table shows level, current status, retest rate, chance from the current distance and median time to the retest.

[b]WHAT IS ORIGINAL[/b]
Many scripts draw the daily open. This one measures it: a volatility-based leave filter, the retest rate per period type, the conditional probability from the current distance and the median time to the retest, all calculated on the symbol and timeframe you are looking at.

[b]LIMITATIONS[/b]
[list]
[*]Daily opens depend on the session of the symbol (exchange time).
[*]Statistics need history; on low timeframes fewer periods are loaded, so check the sample size (hover over the retest rate).
[*]Past retest rates describe the past and do not predict the next session.
[/list]

[b]Disclaimer[/b]
For educational and analytical purposes only. Not financial advice. Marks and signals are not buy or sell recommendations. Past behaviour does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("Open Retest Stats [Indicatr]", shorttitle="Open Retest [Indicatr]", overlay=true, max_labels_count=100, behind_chart=false)

// ===== Inputs =====
grpO = "Opens"
useD = input.bool(true,  "Daily open", group=grpO, inline="d")
colD = input.color(#F0B90B, "", group=grpO, inline="d")
useW = input.bool(true,  "Weekly open", group=grpO, inline="w")
colW = input.color(#2962FF, "", group=grpO, inline="w")
useM = input.bool(false, "Monthly open", group=grpO, inline="m")
colM = input.color(#9C27B0, "", group=grpO, inline="m")

grpR = "Retest logic"
leaveK = input.float(0.15, "Price has left the open after (x average range)", minval=0.01, step=0.01, group=grpR, tooltip="A retest only counts after price has moved this far away from the open. Measured in the average high-low range of the same period type (day, week or month).")
lookN  = input.int(250, "Statistics: last N periods", minval=20, maxval=2000, group=grpR)
rangeN = input.int(20, "Average range: last N periods", minval=5, maxval=200, group=grpR)

grpV = "Display"
showFill  = input.bool(true, "Shade the distance while price is away from the daily open", group=grpV)
showMarks = input.bool(true, "Mark retests and missed retests", group=grpV)
showTbl   = input.bool(true, "Show statistics table", group=grpV)
colRet    = input.color(#089981, "Retested", group=grpV, inline="c")
colMiss   = input.color(#F23645, "Not retested", group=grpV, inline="c")

// ===== Tracker for one open type =====
// Returns the current open, its state and the statistics of completed periods.
openTrack(simple string tf) =>
    var float o = na
    var float pHi = na
    var float pLo = na
    var bool left = false
    var bool ret = false
    var int side = 0
    var float exc = 0.0
    var int leftBar = 0
    var int retBars = 0
    var array<float> ranges = array.new_float()
    var array<int>   hRet = array.new_int()
    var array<float> hExc = array.new_float()
    var array<float> hBars = array.new_float()
    newP = timeframe.change(tf)
    avgR = ranges.size() > 0 ? ranges.avg() : na
    bool missedPrev = false
    float prevO = na
    if newP
        if not na(o)
            ranges.push(pHi - pLo)
            if ranges.size() > rangeN
                ranges.shift()
            if left
                hRet.push(ret ? 1 : 0)
                hExc.push(exc)
                if ret
                    hBars.push(retBars)
                if hRet.size() > lookN
                    hRet.shift()
                    hExc.shift()
                if hBars.size() > lookN
                    hBars.shift()
            missedPrev := left and not ret
            prevO := o
        o := open
        pHi := high
        pLo := low
        left := false
        ret := false
        side := 0
        exc := 0.0
    else
        pHi := math.max(pHi, high)
        pLo := math.min(pLo, low)
    retNow = false
    leftNow = false
    if not na(o) and not na(avgR) and avgR > 0
        if left and not ret and low <= o and high >= o and bar_index > leftBar
            ret := true
            retNow := true
            retBars := bar_index - leftBar
        if not left
            up = high - o
            dn = o - low
            if math.max(up, dn) >= leaveK * avgR
                left := true
                leftNow := true
                side := up >= dn ? 1 : -1
                leftBar := bar_index
        if left and not ret
            exc := math.max(exc, (side == 1 ? high - o : o - low) / avgR)
    // statistics (computed on the last bar only)
    float rate = na
    float cond = na
    float medBars = na
    int nHist = hRet.size()
    if barstate.islast and nHist > 0
        hits = 0
        condN = 0
        condHits = 0
        for i = 0 to nHist - 1
            r = hRet.get(i)
            hits += r
            if left and not ret and hExc.get(i) >= exc
                condN += 1
                condHits += r
        rate := 100.0 * hits / nHist
        if condN >= 10
            cond := 100.0 * condHits / condN
        medBars := hBars.size() > 0 ? hBars.median() : na
    distNow = not na(o) and not na(avgR) and avgR > 0 ? (close - o) / avgR : na
    [o, left, ret, retNow, leftNow, newP, rate, nHist, cond, medBars, distNow, missedPrev, prevO]

[oD, leftD, retD, retNowD, leftNowD, newD, rateD, nD, condD, medD, distD, missD, prevD] = openTrack("D")
[oW, leftW, retW, retNowW, leftNowW, newW, rateW, nW, condW, medW, distW, missW, prevW] = openTrack("W")
[oM, leftM, retM, retNowM, leftNowM, newM, rateM, nM, condM, medM, distM, missM, prevM] = openTrack("M")

intra = timeframe.isintraday
showD = useD and intra
showW = useW and timeframe.in_seconds() < timeframe.in_seconds("W")
showM = useM and timeframe.in_seconds() < timeframe.in_seconds("M")

// ===== Open lines =====
pD = plot(showD and not newD ? oD : na, "Daily open", color.new(colD, 0), 2, plot.style_linebr)
plot(showW and not newW ? oW : na, "Weekly open", color.new(colW, 0), 2, plot.style_linebr)
plot(showM and not newM ? oM : na, "Monthly open", color.new(colM, 0), 2, plot.style_linebr)
pC = plot(close, "Close (fill reference)", display=display.none, editable=false)

// Gradient between the daily open and price while price is away and has not come back:
// faint at the open, stronger towards price - the stretch that a retest would have to cover.
away = showFill and showD and leftD and not retD and not newD
upSide = close > oD
fill(pD, pC, away ? math.max(oD, close) : na, away ? math.min(oD, close) : na, upSide ? color.new(colD, 72) : color.new(colD, 97), upSide ? color.new(colD, 97) : color.new(colD, 72), "Distance to daily open")

// Marks: green dot = open retested, red cross = period ended without a retest
plotshape(showMarks and showD and retNowD ? oD : na, "Daily open retested", shape.circle, location.absolute, colRet, size=size.tiny)
plotshape(showMarks and showW and retNowW ? oW : na, "Weekly open retested", shape.circle, location.absolute, colRet, size=size.tiny)
plotshape(showMarks and showM and retNowM ? oM : na, "Monthly open retested", shape.circle, location.absolute, colRet, size=size.tiny)
plotshape(showMarks and showD and missD ? prevD : na, "Daily open not retested", shape.xcross, location.absolute, colMiss, size=size.tiny, offset=-1)
plotshape(showMarks and showW and missW ? prevW : na, "Weekly open not retested", shape.xcross, location.absolute, colMiss, size=size.tiny, offset=-1)

// ===== Tags for the current opens =====
var array<label> tags = array.new_label()
tag(float o, string name, float rate, color c, color tc) =>
    label.new(bar_index, o, name + "  " + str.tostring(o, format.mintick) + (na(rate) ? "" : "   " + str.tostring(rate, "0") + " %"), style=label.style_label_lower_right, color=color.new(c, 0), textcolor=tc, size=size.small)
if barstate.islast
    for l in tags
        l.delete()
    tags.clear()
    if showD and not na(oD)
        tags.push(tag(oD, "D-Open", rateD, colD, #131722))
    if showW and not na(oW)
        tags.push(tag(oW, "W-Open", rateW, colW, color.white))
    if showM and not na(oM)
        tags.push(tag(oM, "M-Open", rateM, colM, color.white))

// ===== Table (follows the chart theme) =====
var table tb = table.new(position.top_right, 6, 4, bgcolor=color.new(chart.bg_color, 0), frame_color=color.new(chart.fg_color, 85), frame_width=1, border_color=color.new(chart.fg_color, 92), border_width=1)
fmtTime(float bars) =>
    if na(bars)
        "-"
    else
        h = bars * timeframe.in_seconds() / 3600.0
        h < 48 ? str.tostring(h, "0.0") + " h" : str.tostring(h / 24, "0.0") + " d"
row(int r, string name, string unit, color c, float o, bool left, bool ret, float rate, int n, float cond, float med, float dist) =>
    fg = chart.fg_color
    status = na(o) ? "-" : ret ? "Retested" : left ? (dist >= 0 ? "+" : "") + str.tostring(dist, "0.00") + " " + unit + " away" : "At open"
    stc = ret ? colRet : left ? colMiss : color.new(fg, 40)
    table.cell(tb, 0, r, name, text_color=c, text_size=size.small, text_halign=text.align_left)
    table.cell(tb, 1, r, na(o) ? "-" : str.tostring(o, format.mintick), text_color=fg, text_size=size.small)
    table.cell(tb, 2, r, status, text_color=stc, text_size=size.small)
    table.cell(tb, 3, r, na(rate) ? "-" : str.tostring(rate, "0") + " %", text_color=fg, text_size=size.small, tooltip="Share of periods in which price came back to the open after leaving it (n = " + str.tostring(n) + ")")
    table.cell(tb, 4, r, ret ? "-" : not left ? "-" : na(cond) ? "few cases" : str.tostring(cond, "0") + " %", text_color=fg, text_size=size.small)
    table.cell(tb, 5, r, fmtTime(med), text_color=fg, text_size=size.small)

if barstate.islast and showTbl
    hdr = color.new(chart.fg_color, 45)
    table.cell(tb, 0, 0, "Open", text_color=hdr, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tb, 1, 0, "Level", text_color=hdr, text_size=size.tiny)
    table.cell(tb, 2, 0, "Now", text_color=hdr, text_size=size.tiny)
    table.cell(tb, 3, 0, "Retest rate", text_color=hdr, text_size=size.tiny)
    table.cell(tb, 4, 0, "From here", text_color=hdr, text_size=size.tiny)
    table.cell(tb, 5, 0, "Median time", text_color=hdr, text_size=size.tiny)
    if showD
        row(1, "Day", "ADR", colD, oD, leftD, retD, rateD, nD, condD, medD, distD)
    if showW
        row(2, "Week", "AWR", colW, oW, leftW, retW, rateW, nW, condW, medW, distW)
    if showM
        row(3, "Month", "AMR", colM, oM, leftM, retM, rateM, nM, condM, medM, distM)

// ===== Alerts =====
alertcondition(showD and retNowD, "Daily open retested", "Open Retest {{ticker}}: price is back at the daily open ({{close}})")
alertcondition(showW and retNowW, "Weekly open retested", "Open Retest {{ticker}}: price is back at the weekly open ({{close}})")
alertcondition(showM and retNowM, "Monthly open retested", "Open Retest {{ticker}}: price is back at the monthly open ({{close}})")
alertcondition(showD and leftNowD, "Price left the daily open", "Open Retest {{ticker}}: price has moved away from the daily open ({{close}})")
````
