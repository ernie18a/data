# SPY QQQ MTF ABCD Scanner + Entry Zones AT

- url: https://www.tradingview.com/script/HU9Egg1t-SPY-QQQ-MTF-ABCD-Scanner-Entry-Zones-AT/
- type: indicator
- pine_id: PUB;4e17ec69549042ba9534814ddd4db5ad
- version: 1.0

## Description

What T1 and T2 mean
For a bullish ABCD:
Entry = D zone (green box) Stop = below D zone T1 (Target 1)= first profit target T2 (Target 2) = final profit target .
In the code I gave you:
T1 = C point T2= A point
So the idea was:
Buy at D Take partial profits at C Take final profits at A
This is a conservative ABCD trade management approach

## Source Code

````pine
//@version=6
indicator("SPY QQQ MTF ABCD Scanner + Entry Zones v6", overlay=true, max_lines_count=100, max_labels_count=100, max_boxes_count=20)

//━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━
sym1 = input.symbol("SPY", "Symbol 1")
sym2 = input.symbol("QQQ", "Symbol 2")

tf1 = input.timeframe("1", "Scan TF 1")
tf2 = input.timeframe("2", "Scan TF 2")
tf3 = input.timeframe("5", "Scan TF 3")
tf4 = input.timeframe("10", "Scan TF 4")

leftBars  = input.int(5, "Pivot Left", minval=2)
rightBars = input.int(5, "Pivot Right", minval=2)

atrLen = input.int(14, "ATR Length")
minABatr = input.float(0.8, "Min AB ATR", step=0.1)
minRetrace = input.float(0.382, "Min BC Retrace", step=0.001)
maxRetrace = input.float(0.886, "Max BC Retrace", step=0.001)
dZoneAtr = input.float(0.30, "D Entry Zone ATR Width", step=0.05)

showDashboard = input.bool(true, "Show Dashboard")
showTradePlan = input.bool(true, "Show Entry / Stop / Targets")

// Pattern Colors
bullColor = color.rgb(35, 200, 95)
bearColor = color.rgb(255, 80, 80)
neutralColor = color.rgb(130, 130, 140)

// Dashboard Colors
HeaderBg = color.rgb(20, 24, 32)
HeaderText = color.white

NoSignalBg = color.rgb(10, 10, 10)
NoSignalText = color.rgb(160, 160, 160)

BullBg = color.rgb(0, 90, 45)
BearBg = color.rgb(120, 20, 20)

EntryBg = color.rgb(255, 193, 7)
EntryText = color.black

StatusBg = color.rgb(35, 35, 35)

//━━━━━━━━━━━━━━━━━━━
// ABCD ENGINE
//━━━━━━━━━━━━━━━━━━━
f_abcd() =>
    atr = ta.atr(atrLen)

    ph = ta.pivothigh(high, leftBars, rightBars)
    pl = ta.pivotlow(low, leftBars, rightBars)

    newPivot = not na(ph) or not na(pl)
    pType = not na(ph) ? 1 : not na(pl) ? -1 : 0
    pPrice = not na(ph) ? ph : not na(pl) ? pl : na
    pTime = time[rightBars]

    var float A = na
    var float B = na
    var float C = na

    var int tA = na
    var int tB = na
    var int tC = na

    var int typeA = na
    var int typeB = na
    var int typeC = na

    if newPivot
        if na(typeC)
            typeC := pType
            C := pPrice
            tC := pTime
        else if pType == typeC
            better = pType == 1 ? pPrice > C : pPrice < C
            if better
                C := pPrice
                tC := pTime
        else
            typeA := typeB
            A := B
            tA := tB

            typeB := typeC
            B := C
            tB := tC

            typeC := pType
            C := pPrice
            tC := pTime

    hasABC = not na(A) and not na(B) and not na(C)

    // Bullish entry setup: A high → B low → C high → D projected low
    bullSetup = hasABC and typeA == 1 and typeB == -1 and typeC == 1 and C < A

    // Bearish entry setup: A low → B high → C low → D projected high
    bearSetup = hasABC and typeA == -1 and typeB == 1 and typeC == -1 and C > A

    AB = hasABC ? math.abs(B - A) : na
    BC = hasABC ? math.abs(C - B) : na
    retrace = hasABC and AB > 0 ? BC / AB : na

    validSize = hasABC and AB >= atr * minABatr
    validRetrace = hasABC and retrace >= minRetrace and retrace <= maxRetrace

    D = bullSetup ? C - AB : bearSetup ? C + AB : na

    forming = (bullSetup or bearSetup) and validSize and validRetrace

    dTop = not na(D) ? D + atr * dZoneAtr : na
    dBot = not na(D) ? D - atr * dZoneAtr : na

    touched = forming and high >= dBot and low <= dTop

    rejection =
         touched and (
             bullSetup and close > open or
             bearSetup and close < open
         )

    score = forming ? math.round(math.max(0, 100 - math.abs(retrace - 0.618) * 100)) : 0

    [forming, touched, rejection, bullSetup, bearSetup, A, B, C, D, tA, tB, tC, atr, score]

//━━━━━━━━━━━━━━━━━━━
// SCANNER REQUESTS
//━━━━━━━━━━━━━━━━━━━
[a1,b1,c1,d1,e1,f1,g1,h1,i1,j1,k1,l1,m1,n1] = request.security(sym1, tf1, f_abcd(), lookahead=barmerge.lookahead_off)
[a2,b2,c2,d2,e2,f2,g2,h2,i2,j2,k2,l2,m2,n2] = request.security(sym1, tf2, f_abcd(), lookahead=barmerge.lookahead_off)
[a3,b3,c3,d3,e3,f3,g3,h3,i3,j3,k3,l3,m3,n3] = request.security(sym1, tf3, f_abcd(), lookahead=barmerge.lookahead_off)
[a4,b4,c4,d4,e4,f4,g4,h4,i4,j4,k4,l4,m4,n4] = request.security(sym1, tf4, f_abcd(), lookahead=barmerge.lookahead_off)

[o1,p1,q1,r1,s1,t1,u1,v1,w1,x1,y1,z1,aa1,ab1] = request.security(sym2, tf1, f_abcd(), lookahead=barmerge.lookahead_off)
[o2,p2,q2,r2,s2,t2,u2,v2,w2,x2,y2,z2,aa2,ab2] = request.security(sym2, tf2, f_abcd(), lookahead=barmerge.lookahead_off)
[o3,p3,q3,r3,s3,t3,u3,v3,w3,x3,y3,z3,aa3,ab3] = request.security(sym2, tf3, f_abcd(), lookahead=barmerge.lookahead_off)
[o4,p4,q4,r4,s4,t4,u4,v4,w4,x4,y4,z4,aa4,ab4] = request.security(sym2, tf4, f_abcd(), lookahead=barmerge.lookahead_off)

//━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━
f_sendAlert(_sym, _tf, _forming, _touch, _reject, _bull, _bear, _score) =>
    dir = _bull ? "Bullish LONG" : _bear ? "Bearish SHORT" : "Neutral"

    if _forming and not _forming[1]
        alert("ABCD FORMING | " + _sym + " | " + _tf + "m | " + dir + " | Score " + str.tostring(_score), alert.freq_once_per_bar_close)

    if _touch and not _touch[1]
        alert("ABCD ENTRY ZONE HIT | " + _sym + " | " + _tf + "m | " + dir + " | Score " + str.tostring(_score), alert.freq_once_per_bar_close)

    if _reject and not _reject[1]
        alert("ABCD REJECTION CONFIRMED | " + _sym + " | " + _tf + "m | " + dir + " | Score " + str.tostring(_score), alert.freq_once_per_bar_close)

f_sendAlert("SPY", tf1, a1, b1, c1, d1, e1, n1)
f_sendAlert("SPY", tf2, a2, b2, c2, d2, e2, n2)
f_sendAlert("SPY", tf3, a3, b3, c3, d3, e3, n3)
f_sendAlert("SPY", tf4, a4, b4, c4, d4, e4, n4)

f_sendAlert("QQQ", tf1, o1, p1, q1, r1, s1, ab1)
f_sendAlert("QQQ", tf2, o2, p2, q2, r2, s2, ab2)
f_sendAlert("QQQ", tf3, o3, p3, q3, r3, s3, ab3)
f_sendAlert("QQQ", tf4, o4, p4, q4, r4, s4, ab4)

//━━━━━━━━━━━━━━━━━━━
// SELECT CURRENT SYMBOL + CURRENT TF ONLY
//━━━━━━━━━━━━━━━━━━━
isSPY = syminfo.ticker == "SPY"
isQQQ = syminfo.ticker == "QQQ"
curTF = timeframe.period

bool selForm = false
bool selTouch = false
bool selReject = false
bool selBull = false
bool selBear = false

float selA = na
float selB = na
float selC = na
float selD = na
float selATR = na

int selTA = na
int selTB = na
int selTC = na

int selScore = 0
string selTF = ""

if isSPY and curTF == tf1
    selForm := a1
    selTouch := b1
    selReject := c1
    selBull := d1
    selBear := e1
    selA := f1
    selB := g1
    selC := h1
    selD := i1
    selTA := j1
    selTB := k1
    selTC := l1
    selATR := m1
    selScore := n1
    selTF := tf1
else if isSPY and curTF == tf2
    selForm := a2
    selTouch := b2
    selReject := c2
    selBull := d2
    selBear := e2
    selA := f2
    selB := g2
    selC := h2
    selD := i2
    selTA := j2
    selTB := k2
    selTC := l2
    selATR := m2
    selScore := n2
    selTF := tf2
else if isSPY and curTF == tf3
    selForm := a3
    selTouch := b3
    selReject := c3
    selBull := d3
    selBear := e3
    selA := f3
    selB := g3
    selC := h3
    selD := i3
    selTA := j3
    selTB := k3
    selTC := l3
    selATR := m3
    selScore := n3
    selTF := tf3
else if isSPY and curTF == tf4
    selForm := a4
    selTouch := b4
    selReject := c4
    selBull := d4
    selBear := e4
    selA := f4
    selB := g4
    selC := h4
    selD := i4
    selTA := j4
    selTB := k4
    selTC := l4
    selATR := m4
    selScore := n4
    selTF := tf4
else if isQQQ and curTF == tf1
    selForm := o1
    selTouch := p1
    selReject := q1
    selBull := r1
    selBear := s1
    selA := t1
    selB := u1
    selC := v1
    selD := w1
    selTA := x1
    selTB := y1
    selTC := z1
    selATR := aa1
    selScore := ab1
    selTF := tf1
else if isQQQ and curTF == tf2
    selForm := o2
    selTouch := p2
    selReject := q2
    selBull := r2
    selBear := s2
    selA := t2
    selB := u2
    selC := v2
    selD := w2
    selTA := x2
    selTB := y2
    selTC := z2
    selATR := aa2
    selScore := ab2
    selTF := tf2
else if isQQQ and curTF == tf3
    selForm := o3
    selTouch := p3
    selReject := q3
    selBull := r3
    selBear := s3
    selA := t3
    selB := u3
    selC := v3
    selD := w3
    selTA := x3
    selTB := y3
    selTC := z3
    selATR := aa3
    selScore := ab3
    selTF := tf3
else if isQQQ and curTF == tf4
    selForm := o4
    selTouch := p4
    selReject := q4
    selBull := r4
    selBear := s4
    selA := t4
    selB := u4
    selC := v4
    selD := w4
    selTA := x4
    selTB := y4
    selTC := z4
    selATR := aa4
    selScore := ab4
    selTF := tf4

//━━━━━━━━━━━━━━━━━━━
// CLEAN DRAWING
//━━━━━━━━━━━━━━━━━━━
var line lineAB = na
var line lineBC = na
var line lineCD = na

var line entryLine = na
var line stopLine = na
var line t1Line = na
var line t2Line = na

var box dBox = na

var label labA = na
var label labB = na
var label labC = na
var label labD = na
var label labEntry = na
var label labStop = na
var label labT1 = na
var label labT2 = na
var label labStatus = na

if barstate.islast
    line.delete(lineAB)
    line.delete(lineBC)
    line.delete(lineCD)

    line.delete(entryLine)
    line.delete(stopLine)
    line.delete(t1Line)
    line.delete(t2Line)

    box.delete(dBox)

    label.delete(labA)
    label.delete(labB)
    label.delete(labC)
    label.delete(labD)
    label.delete(labEntry)
    label.delete(labStop)
    label.delete(labT1)
    label.delete(labT2)
    label.delete(labStatus)

    if selForm and not na(selA) and not na(selD)
        col = selBull ? bullColor : bearColor
        zone = selATR * dZoneAtr

        dTop = selD + zone
        dBot = selD - zone

        entryPrice = selD
        stopPrice = selBull ? dBot : dTop
        target1 = selC
        target2 = selA

        lineAB := line.new(selTA, selA, selTB, selB, xloc=xloc.bar_time, color=color.white, width=2)
        lineBC := line.new(selTB, selB, selTC, selC, xloc=xloc.bar_time, color=color.white, width=2)
        lineCD := line.new(selTC, selC, time, selD, xloc=xloc.bar_time, color=col, width=2, style=line.style_dashed)

        dBox := box.new(selTC, dTop, time, dBot, xloc=xloc.bar_time, bgcolor=color.new(col, 85), border_color=col)

        labA := label.new(selTA, selA, "A", xloc=xloc.bar_time, color=color.black, textcolor=color.white)
        labB := label.new(selTB, selB, "B", xloc=xloc.bar_time, color=color.black, textcolor=color.white)
        labC := label.new(selTC, selC, "C", xloc=xloc.bar_time, color=color.black, textcolor=color.white)
        labD := label.new(time, selD, "D PRZ " + selTF + "m", xloc=xloc.bar_time, color=col, textcolor=color.white)

        if showTradePlan
            entryLine := line.new(selTC, entryPrice, time, entryPrice, xloc=xloc.bar_time, color=col, width=2)
            stopLine := line.new(selTC, stopPrice, time, stopPrice, xloc=xloc.bar_time, color=color.red, width=1)
            t1Line := line.new(selTC, target1, time, target1, xloc=xloc.bar_time, color=color.green, width=1)
            t2Line := line.new(selTC, target2, time, target2, xloc=xloc.bar_time, color=color.green, width=1, style=line.style_dashed)

            labEntry := label.new(time, entryPrice, "Entry Zone", xloc=xloc.bar_time, color=col, textcolor=color.white)
            labStop := label.new(time, stopPrice, "Stop", xloc=xloc.bar_time, color=color.red, textcolor=color.white)
            labT1 := label.new(time, target1, "T1", xloc=xloc.bar_time, color=color.green, textcolor=color.white)
            labT2 := label.new(time, target2, "T2", xloc=xloc.bar_time, color=color.green, textcolor=color.white)

        statusText = selReject ? "REJECTION CONFIRMED" : selTouch ? "ENTRY ZONE HIT" : "ABCD FORMING"
        dirText = selBull ? "BULLISH ABCD LONG" : "BEARISH ABCD SHORT"

        labStatus := label.new(time, high, dirText + "\n" + statusText + "\nScore: " + str.tostring(selScore), xloc=xloc.bar_time, style=label.style_label_left, color=col, textcolor=color.white)

//━━━━━━━━━━━━━━━━━━━
// DASHBOARD
//━━━━━━━━━━━━━━━━━━━
var table dash = table.new(position.top_right, 5, 9, border_width=1)

f_row(_row, _sym, _tf, _form, _touch, _reject, _bull, _bear, _score) =>
    bias = _form ? (_bull ? "Bull Long" : _bear ? "Bear Short" : "-") : "-"
    stat = _reject ? "Reject" : _touch ? "D Zone" : _form ? "Forming" : "Idle"

    rowBg = _form ? (_bull ? BullBg : BearBg) : NoSignalBg
    rowText = _form ? color.white : NoSignalText

    statusText = _reject ? color.white : _touch ? EntryText : rowText
    statusCellBg = _reject ? rowBg : _touch ? EntryBg : StatusBg

    table.cell(dash, 0, _row, _sym, bgcolor=rowBg, text_color=rowText)
    table.cell(dash, 1, _row, _tf + "m", bgcolor=rowBg, text_color=rowText)
    table.cell(dash, 2, _row, bias, bgcolor=rowBg, text_color=rowText)
    table.cell(dash, 3, _row, stat, bgcolor=statusCellBg, text_color=statusText)
    table.cell(dash, 4, _row, str.tostring(_score), bgcolor=rowBg, text_color=rowText)


if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "Symbol", text_color=HeaderText, bgcolor=HeaderBg)
    table.cell(dash, 1, 0, "TF", text_color=HeaderText, bgcolor=HeaderBg)
    table.cell(dash, 2, 0, "Bias", text_color=HeaderText, bgcolor=HeaderBg)
    table.cell(dash, 3, 0, "Status", text_color=HeaderText, bgcolor=HeaderBg)
    table.cell(dash, 4, 0, "Score", text_color=HeaderText, bgcolor=HeaderBg)

    f_row(1, "SPY", tf1, a1, b1, c1, d1, e1, n1)
    f_row(2, "SPY", tf2, a2, b2, c2, d2, e2, n2)
    f_row(3, "SPY", tf3, a3, b3, c3, d3, e3, n3)
    f_row(4, "SPY", tf4, a4, b4, c4, d4, e4, n4)

    f_row(5, "QQQ", tf1, o1, p1, q1, r1, s1, ab1)
    f_row(6, "QQQ", tf2, o2, p2, q2, r2, s2, ab2)
    f_row(7, "QQQ", tf3, o3, p3, q3, r3, s3, ab3)
    f_row(8, "QQQ", tf4, o4, p4, q4, r4, s4, ab4)
````
