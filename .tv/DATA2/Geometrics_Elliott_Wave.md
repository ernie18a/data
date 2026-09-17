<!-- tradingview-pine-id: PUB;f184286f1fb846dda2435b48a5c59a35 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Geometrics - Elliott Wave

Source: https://www.tradingview.com/script/l1nwWkMN-Geometrics-Elliott-Wave-Auto-Counter-Impulse-ABC-Triangles/

## Description

Overview
The Geometrics - Elliott Wave Auto Counter is an advanced, fully automated technical analysis tool designed to identify and plot Elliott Wave structures directly on your chart. Built strictly around the three cardinal rules of Elliott Wave Theory, this indicator takes the heavy lifting out of wave counting by dynamically tracking pivot points and projecting geometric structures in real-time.

Whether you are tracking standard motive waves, complex diagonals, or corrective structures, this script provides a clear, visual roadmap of potential market cycles.

Key Features

Impulse Waves (1-2-3-4-5): Automatically identifies valid 5-wave impulse structures. It ensures that Wave 2 does not retrace 100% of Wave 1, Wave 3 is never the shortest, and Wave 4 does not enter the price territory of Wave 1. It also calculates and displays the exact Fibonacci retracement and extension percentages on the chart.

Leading & Ending Diagonals: Detects diagonal wedge structures where Wave 4 is permitted to overlap Wave 1. The script even dives into the inner wave structures to classify whether the diagonal follows a 5-3-5-3-5 or 3-3-3-3-3 pattern.

Corrective Waves (A-B-C): Once a 5-wave sequence is completed, the script actively looks for and plots the subsequent A-B-C corrective structure.

Triangle Detection: Identifies both Contracting and Expanding triangles (A-B-C-D-E). It automatically draws the upper and lower boundary lines and projects geometric breakout targets based on the width of the initial A-B leg.

Dynamic Target Projections: Takes the guesswork out of taking profits. The script projects forward-looking target boxes for:

Wave 3 (161.8% - 261.8% of Wave 1)

Wave 5 (61.8% - 100% of Waves 0-3)

A-B-C Corrections (38.2% - 61.8% retracement of the entire 1-5 structure)

Smart Invalidation & Automatic Alt-Counts: This is a standout feature. The script plots a strict invalidation line at the start of the wave (Point 0). If the price action breaks this level, the current count is instantly marked as invalid. The script will then automatically scan historical pivot windows to find and plot a valid Alternative Count (Alt Count) and its new targets.

Customization & Settings
The indicator is highly modular. Via the settings panel, users can:

Adjust the Timeframe and Pivot Length to fine-tune the sensitivity of the ZigZag tracking.

Toggle specific structures on or off (e.g., hide Triangles if you only want to see Impulses).

Fully customize the colors and styling of lines, labels, and target boxes to fit your personal chart theme.

⚠️ Important Disclaimer
This script is a geometric counting tool based strictly on the three rigid, textbook rules of Elliott Wave. As seasoned practitioners know, real-world wave counting is highly subjective and context-dependent. Multiple valid interpretations of a chart can exist simultaneously. This indicator does not cover every possible sub-classification (like expanded/running flats or complex WXYXZ combinations) and should be used as an analytical aid alongside your own market analysis, not as a standalone buy/sell signal.

---

## Source Code

````pine
// © Geometrics - Elliott Wave Auto Counter (Impulse + ABC + Triangles + Invalidation/Alt Count)
//@version=6
indicator("Geometrics - Elliott Wave", overlay=true, max_lines_count=300, max_labels_count=150, max_polylines_count=50, max_boxes_count=20)

// ============================================================
// Warning: This is an auto-count based strictly on the three rigid Elliott Wave rules.
// True wave counting is often subjective and multiple valid interpretations may exist.
// It does not cover all sub-classifications (expanded/running flat, complex zigzag...).
// ============================================================

gGen = "General Settings"
tfInput   = input.timeframe("", title="Timeframe (Empty = Chart Timeframe)", group=gGen)
pivotLen  = input.int(5, title="Pivot Length", minval=2, group=gGen)

gImp = "Impulse Wave (1-2-3-4-5)"
showImpulse = input.bool(true, title="Show 1-2-3-4-5 Count", group=gImp)
upColor     = input.color(color.lime, title="Upward Wave Color", group=gImp)
downColor   = input.color(color.red, title="Downward Wave Color", group=gImp)

gDiag = "Diagonal (Leading/Ending Diagonal)"
showDiagonal = input.bool(true, title="Show Diagonal (Allows 4 overlapping 1)", group=gDiag)
diagColor    = input.color(color.fuchsia, title="Diagonal Color", group=gDiag)
checkSubWaves = input.bool(true, title="Analyze Inner Structure (5-3-5-3-5 / 3-3-3-3-3)", group=gDiag)
innerPivotLen = input.int(2, title="Inner Pivot Length (For Sub-waves)", minval=1, maxval=4, group=gDiag)

gTarget = "Targets and Alternative Scenario Line"
showInvalidLine = input.bool(true, title="Show Invalidation Line (Alternative Scenario)", group=gTarget)
showTargets     = input.bool(true, title="Show Expected Pattern Targets", group=gTarget)
targetColor     = input.color(color.new(color.yellow, 60), title="Target Area Color", group=gTarget)
invalidLineColor= input.color(color.new(color.gray, 30), title="Invalidation Line Color", group=gTarget)

gInv = "Count Invalidation and Alternative Count"
showInvalidation = input.bool(true, title="Show Count Invalidation upon Breaking Start Point", group=gInv)
showAltCount     = input.bool(true, title="Show Automatic Alternative Count upon Invalidation", group=gInv)
invalidColor     = input.color(color.gray, title="Invalidated Count Color", group=gInv)
altColor         = input.color(color.aqua, title="Alternative Count Color", group=gInv)
altSearchDepth   = input.int(4, title="Number of Alternative Windows to Search Backwards", minval=1, maxval=6, group=gInv)

gCorr = "A-B-C Correction"
showABC   = input.bool(true, title="Show A-B-C Correction after Wave 5", group=gCorr)
abcColor  = input.color(color.orange, title="A-B-C Color", group=gCorr)

gTri = "Triangles (Corrective)"
showTriangle = input.bool(true, title="Show Triangles (Contracting/Expanding)", group=gTri)
triPosColor  = input.color(color.green, title="Positive Triangle Color (Starts from Bottom)", group=gTri)
triNegColor  = input.color(color.red, title="Negative Triangle Color (Starts from Top)", group=gTri)

// ---- Fetch Pivot Data ----
resolvedTF = tfInput == "" ? timeframe.period : tfInput
[secPH, secPL, secPHTime, secPLTime] = request.security(syminfo.tickerid, resolvedTF,
     [ta.pivothigh(high, pivotLen, pivotLen), ta.pivotlow(low, pivotLen, pivotLen), time[pivotLen], time[pivotLen]],
     lookahead=barmerge.lookahead_off)

var zzPrice = array.new_float()
var zzTime  = array.new_int()
var zzType  = array.new_int() // 1 = High, -1 = Low

f_pushPivot(isHigh, price, pTime, priceArr, timeArr, typeArr) =>
    n = array.size(typeArr)
    t = isHigh ? 1 : -1
    if n == 0
        array.push(priceArr, price)
        array.push(timeArr, pTime)
        array.push(typeArr, t)
    else
        lastType = array.get(typeArr, n - 1)
        if lastType == t
            lastPrice = array.get(priceArr, n - 1)
            replace = isHigh ? price > lastPrice : price < lastPrice
            if replace
                array.set(priceArr, n - 1, price)
                array.set(timeArr, n - 1, pTime)
        else
            array.push(priceArr, price)
            array.push(timeArr, pTime)
            array.push(typeArr, t)

var int lastPHTime = na
var int lastPLTime = na
if not na(secPH)
    if na(lastPHTime) or secPHTime != lastPHTime
        lastPHTime := secPHTime
        f_pushPivot(true, secPH, secPHTime, zzPrice, zzTime, zzType)
if not na(secPL)
    if na(lastPLTime) or secPLTime != lastPLTime
        lastPLTime := secPLTime
        f_pushPivot(false, secPL, secPLTime, zzPrice, zzTime, zzType)

// ---- Second Finer Zigzag (For Inner Structure Analysis of Five Legs in Diagonal Check) ----
var innerZzPrice = array.new_float()
var innerZzTime  = array.new_int()
var innerZzType  = array.new_int()

[secPH2, secPL2, secPHTime2, secPLTime2] = request.security(syminfo.tickerid, resolvedTF,
     [ta.pivothigh(high, innerPivotLen, innerPivotLen), ta.pivotlow(low, innerPivotLen, innerPivotLen), time[innerPivotLen], time[innerPivotLen]],
     lookahead=barmerge.lookahead_off)

var int lastPHTime2 = na
var int lastPLTime2 = na
if checkSubWaves and not na(secPH2)
    if na(lastPHTime2) or secPHTime2 != lastPHTime2
        lastPHTime2 := secPHTime2
        f_pushPivot(true, secPH2, secPHTime2, innerZzPrice, innerZzTime, innerZzType)
if checkSubWaves and not na(secPL2)
    if na(lastPLTime2) or secPLTime2 != lastPLTime2
        lastPLTime2 := secPLTime2
        f_pushPivot(false, secPL2, secPLTime2, innerZzPrice, innerZzTime, innerZzType)

// ---- Count Sub-legs Within a Specific Time Range (To Classify Leg as "3" or "5") ----
f_subLegCount(startT, endT) =>
    cnt = 0
    for k = 0 to array.size(innerZzTime) - 1
        kt = array.get(innerZzTime, k)
        if kt > startT and kt < endT
            cnt += 1
    cnt + 1  // Number of legs = number of inner points + 1

f_cls(x) =>
    x >= 5 ? "5" : x <= 3 ? "3" : "?"

// ---- Drawing Objects: Main Count (One copy, deleted and redrawn) ----
var polyline impulsePoly = na
var label lbl0 = na
var label lbl1 = na
var label lbl2 = na
var label lbl3 = na
var label lbl4 = na
var label lbl5 = na

// ---- Drawing Objects: Alternative Count ----
var polyline altPoly = na
var label altLbl0 = na
var label altLbl1 = na
var label altLbl2 = na
var label altLbl3 = na
var label altLbl4 = na
var label altLbl5 = na
var label altTag  = na

var polyline abcPoly = na
var label lblA = na
var label lblB = na
var label lblC = na

var polyline triPoly = na
var label lblTA = na
var label lblTB = na
var label lblTC = na
var label lblTD = na
var label lblTE = na
var label lblTri = na
var line   triUpperLine = na
var line   triLowerLine = na

var box   altTargetBox = na
var label altTargetLbl = na
var line  diagUpperLine = na
var line  diagLowerLine = na

// ---- Wave 3 Target Projection (Before forming, once 0-1-2 is confirmed) ----
var box   w3ProjBox = na
var label w3ProjLbl = na
f_delW3Proj() =>
    if not na(w3ProjBox)
        box.delete(w3ProjBox)
    if not na(w3ProjLbl)
        label.delete(w3ProjLbl)

// ---- Wave 5 Target Projection (Before forming, once 0-1-2-3-4 is confirmed) ----
var box   w5ProjBox = na
var label w5ProjLbl = na
f_delW5Proj() =>
    if not na(w5ProjBox)
        box.delete(w5ProjBox)
    if not na(w5ProjLbl)
        label.delete(w5ProjLbl)

var int   impulseEndIdx   = na  // Wave 5 end position inside zz array
var float impulseP0Price  = na  // Wave start price (Point 0) for invalidation monitoring
var bool  impulseIsUp     = false
var bool  impulseInvalidated = false
var bool  invalidMarked   = false
var string activePatternType = ""  // "impulse" or "diagonal" - Which pattern is currently monitored for invalidation

// ---- Invalidation Line (Alternative Scenario) and Pattern Targets ----
var line  invalidLine = na
var label invalidLbl  = na
var box   targetBox   = na
var label targetLbl   = na

f_delImpulse() =>
    if not na(impulsePoly)
        polyline.delete(impulsePoly)
    if not na(lbl0)
        label.delete(lbl0)
    if not na(lbl1)
        label.delete(lbl1)
    if not na(lbl2)
        label.delete(lbl2)
    if not na(lbl3)
        label.delete(lbl3)
    if not na(lbl4)
        label.delete(lbl4)
    if not na(lbl5)
        label.delete(lbl5)

f_delAlt() =>
    if not na(altPoly)
        polyline.delete(altPoly)
    if not na(altLbl0)
        label.delete(altLbl0)
    if not na(altLbl1)
        label.delete(altLbl1)
    if not na(altLbl2)
        label.delete(altLbl2)
    if not na(altLbl3)
        label.delete(altLbl3)
    if not na(altLbl4)
        label.delete(altLbl4)
    if not na(altLbl5)
        label.delete(altLbl5)
    if not na(altTag)
        label.delete(altTag)

f_delABC() =>
    if not na(abcPoly)
        polyline.delete(abcPoly)
    if not na(lblA)
        label.delete(lblA)
    if not na(lblB)
        label.delete(lblB)
    if not na(lblC)
        label.delete(lblC)

f_delTri() =>
    if not na(triPoly)
        polyline.delete(triPoly)
    if not na(lblTA)
        label.delete(lblTA)
    if not na(lblTB)
        label.delete(lblTB)
    if not na(lblTC)
        label.delete(lblTC)
    if not na(lblTD)
        label.delete(lblTD)
    if not na(lblTE)
        label.delete(lblTE)
    if not na(lblTri)
        label.delete(lblTri)
    if not na(triUpperLine)
        line.delete(triUpperLine)
    if not na(triLowerLine)
        line.delete(triLowerLine)

f_delAltTarget() =>
    if not na(altTargetBox)
        box.delete(altTargetBox)
    if not na(altTargetLbl)
        label.delete(altTargetLbl)

f_delInvalidLine() =>
    if not na(invalidLine)
        line.delete(invalidLine)
    if not na(invalidLbl)
        label.delete(invalidLbl)

f_drawInvalidLine(t0, p0Price) =>
    ln = line.new(t0, p0Price, t0, p0Price, xloc=xloc.bar_time, extend=extend.right, color=invalidLineColor, style=line.style_dashed, width=1)
    lb = label.new(t0, p0Price, "Alternative Scenario Line\n(Break = Invalidate Count)", xloc=xloc.bar_time, color=color.new(color.white,100), textcolor=invalidLineColor, style=label.style_label_left, size=size.tiny)
    [ln, lb]

var box   targetBoxAlt = na
var label targetLblAlt = na

f_delTarget() =>
    if not na(targetBox)
        box.delete(targetBox)
    if not na(targetLbl)
        label.delete(targetLbl)
    if not na(targetBoxAlt)
        box.delete(targetBoxAlt)
    if not na(targetLblAlt)
        label.delete(targetLblAlt)

// ---- Validate 5-Wave Impulse (Three Strict Elliott Rules) ----
f_checkImpulse(p0, p1, p2, p3, p4, p5, isUp, t4, t5) =>
    w1 = math.abs(p1 - p0)
    w3 = math.abs(p3 - p2)
    w5 = math.abs(p5 - p4)
    w4 = math.abs(p4 - p3)
    valid = true
    truncated = false
    if isUp
        valid := p1 > p0 and p2 > p0 and p3 > p1 and p4 > p1
        if valid and p5 <= p3
            // Confirm true truncation (textbook): Wave 5 must actually contain
            // its necessary sub-waves (approx 5 inner legs), not just a price ratio
            hasSubWaves = f_subLegCount(t4, t5) >= 5
            if w5 >= 0.70 * w4 and hasSubWaves
                truncated := true
            else
                valid := false
    else
        valid := p1 < p0 and p2 < p0 and p3 < p1 and p4 < p1
        if valid and p5 >= p3
            hasSubWaves = f_subLegCount(t4, t5) >= 5
            if w5 >= 0.70 * w4 and hasSubWaves
                truncated := true
            else
                valid := false
    if valid and (w3 < w1 and w3 < w5)
        valid := false
    [valid, truncated]

// ---- Validate Diagonal (Same Elliott directions but without 4 overlapping 1 rule) ----
f_checkDiagonal(p0, p1, p2, p3, p4, p5, isUp) =>
    valid = true
    if isUp
        valid := p1 > p0 and p2 > p0 and p3 > p1 and p5 > p3
    else
        valid := p1 < p0 and p2 < p0 and p3 < p1 and p5 < p3
    valid

// ---- Drawing Objects: Diagonal ----
var polyline diagPoly = na
var label diagLbl0 = na
var label diagLbl1 = na
var label diagLbl2 = na
var label diagLbl3 = na
var label diagLbl4 = na
var label diagLbl5 = na
var label diagTag  = na

f_delDiag() =>
    if not na(diagPoly)
        polyline.delete(diagPoly)
    if not na(diagLbl0)
        label.delete(diagLbl0)
    if not na(diagLbl1)
        label.delete(diagLbl1)
    if not na(diagLbl2)
        label.delete(diagLbl2)
    if not na(diagLbl3)
        label.delete(diagLbl3)
    if not na(diagLbl4)
        label.delete(diagLbl4)
    if not na(diagLbl5)
        label.delete(diagLbl5)
    if not na(diagTag)
        label.delete(diagTag)
    if not na(diagUpperLine)
        line.delete(diagUpperLine)
    if not na(diagLowerLine)
        line.delete(diagLowerLine)
f_drawSet(t0,p0,t1,p1,t2,p2,t3,p3,t4,p4,t5,p5, col, isDashed, prefix) =>
    pts = array.new<chart.point>()
    array.push(pts, chart.point.from_time(t0, p0))
    array.push(pts, chart.point.from_time(t1, p1))
    array.push(pts, chart.point.from_time(t2, p2))
    array.push(pts, chart.point.from_time(t3, p3))
    array.push(pts, chart.point.from_time(t4, p4))
    array.push(pts, chart.point.from_time(t5, p5))
    poly = polyline.new(pts, closed=false, line_color=col, line_width=isDashed ? 2 : 3)
    l0 = label.new(t0, p0, prefix+"0", xloc=xloc.bar_time, color=color.new(color.white,100), textcolor=col, style=label.style_label_up, size=size.normal)
    l1 = label.new(t1, p1, prefix+"1", xloc=xloc.bar_time, color=color.new(color.white,100), textcolor=col, style=label.style_label_down, size=size.normal)
    l2 = label.new(t2, p2, prefix+"2", xloc=xloc.bar_time, color=color.new(color.white,100), textcolor=col, style=label.style_label_up, size=size.normal)
    l3 = label.new(t3, p3, prefix+"3", xloc=xloc.bar_time, color=color.new(color.white,100), textcolor=col, style=label.style_label_down, size=size.normal)
    l4 = label.new(t4, p4, prefix+"4", xloc=xloc.bar_time, color=color.new(color.white,100), textcolor=col, style=label.style_label_up, size=size.normal)
    l5 = label.new(t5, p5, prefix+"5", xloc=xloc.bar_time, color=color.new(color.white,100), textcolor=col, style=label.style_label_down, size=size.normal)
    [poly, l0, l1, l2, l3, l4, l5]

n = array.size(zzType)

// ================== Wave 3 Target Projection (From 0-1-2 only) ==================
var int lastW3CheckedN = 0
if showTargets and n >= 3 and n != lastW3CheckedN
    lastW3CheckedN := n
    q0 = array.get(zzPrice, n - 3)
    qt0 = array.get(zzTime,  n - 3)
    qty0 = array.get(zzType, n - 3)
    q1 = array.get(zzPrice, n - 2)
    qt1 = array.get(zzTime,  n - 2)
    q2 = array.get(zzPrice, n - 1)
    qt2 = array.get(zzTime,  n - 1)
    qIsUp = qty0 == -1
    w3valid = qIsUp ? (q1 > q0 and q2 > q0) : (q1 < q0 and q2 < q0)
    if w3valid
        f_delW3Proj()
        w1L = q1 - q0
        t3lo = q1 + 1.618 * w1L
        t3hi = q1 + 2.618 * w1L
        boxEnd3 = qt2 + (qt2 - qt1) * 3
        w3ProjBox := box.new(qt2, math.max(t3lo,t3hi), boxEnd3, math.min(t3lo,t3hi), xloc=xloc.bar_time, border_color=color.new(color.blue,30), bgcolor=color.new(color.blue,88))
        w3ProjLbl := label.new(boxEnd3, (t3lo+t3hi)/2, "🎯 Expected Wave 3 Target\n161.8%-261.8% of 1", xloc=xloc.bar_time, color=color.new(color.white,100), textcolor=color.blue, style=label.style_label_right, size=size.tiny)

// ================== Wave 5 Target Projection (From 0-1-2-3-4 only) ==================
var int lastW5CheckedN = 0
if showTargets and n >= 5 and n != lastW5CheckedN
    lastW5CheckedN := n
    r0 = array.get(zzPrice, n - 5)
    rt0 = array.get(zzTime,  n - 5)
    rty0 = array.get(zzType, n - 5)
    r1 = array.get(zzPrice, n - 4)
    r2 = array.get(zzPrice, n - 3)
    r3 = array.get(zzPrice, n - 2)
    r4 = array.get(zzPrice, n - 1)
    rt4 = array.get(zzTime,  n - 1)
    rt3 = array.get(zzTime,  n - 2)
    rIsUp = rty0 == -1
    w5valid = rIsUp ? (r1>r0 and r2>r0 and r3>r1 and r4>r1) : (r1<r0 and r2<r0 and r3<r1 and r4<r1)
    if w5valid
        f_delW5Proj()
        w03len = r3 - r0   // Move length from 0 to top/bottom 3 (with sign)
        t5lo = r4 + 0.618 * w03len
        t5hi = r4 + 1.000 * w03len
        boxEnd5 = rt4 + (rt4 - rt3) * 3
        w5ProjBox := box.new(rt4, math.max(t5lo,t5hi), boxEnd5, math.min(t5lo,t5hi), xloc=xloc.bar_time, border_color=color.new(color.teal,30), bgcolor=color.new(color.teal,88))
        w5ProjLbl := label.new(boxEnd5, (t5lo+t5hi)/2, "🎯 Expected Wave 5 Target\n61.8%-100% of (0-3)", xloc=xloc.bar_time, color=color.new(color.white,100), textcolor=color.teal, style=label.style_label_right, size=size.tiny)

var int lastImpulseCheckedN = 0
if showImpulse and n >= 6 and n != lastImpulseCheckedN
    lastImpulseCheckedN := n
    p0 = array.get(zzPrice, n - 6)
    t0 = array.get(zzTime,  n - 6)
    ty0 = array.get(zzType, n - 6)
    p1 = array.get(zzPrice, n - 5)
    t1 = array.get(zzTime,  n - 5)
    p2 = array.get(zzPrice, n - 4)
    t2 = array.get(zzTime,  n - 4)
    p3 = array.get(zzPrice, n - 3)
    t3 = array.get(zzTime,  n - 3)
    p4 = array.get(zzPrice, n - 2)
    t4 = array.get(zzTime,  n - 2)
    p5 = array.get(zzPrice, n - 1)
    t5 = array.get(zzTime,  n - 1)

    isUpCandidate = ty0 == -1
    [isValid, isTruncated] = f_checkImpulse(p0, p1, p2, p3, p4, p5, isUpCandidate, t4, t5)

    if isValid
        f_delImpulse()
        f_delAlt()
        f_delDiag()
        f_delInvalidLine()
        f_delTarget()
        f_delAltTarget()
        impulseEndIdx := n - 1
        impulseP0Price := p0
        impulseIsUp := isUpCandidate
        impulseInvalidated := false
        invalidMarked := false
        activePatternType := "impulse"
        col = isUpCandidate ? upColor : downColor
        [poly, l0, l1, l2, l3, l4, l5] = f_drawSet(t0,p0,t1,p1,t2,p2,t3,p3,t4,p4,t5,p5, col, false, "")
        impulsePoly := poly
        lbl0 := l0
        lbl1 := l1
        lbl2 := l2
        lbl3 := l3
        lbl4 := l4
        lbl5 := l5

        // ---- Actual Fibonacci Ratios of the Wave (From reference book) ----
        w1len = math.abs(p1 - p0)
        w2retr = math.abs(p1 - p2) / w1len * 100
        w3ext  = math.abs(p3 - p2) / math.abs(p2 - p1) * 100
        w5rel  = math.abs(p5 - p4) / w1len * 100

        // ---- Extension Type Classification: Which wave (1, 3, or 5) is extended ----
        wA = math.abs(p1 - p0)
        wB = math.abs(p3 - p2)
        wC = math.abs(p5 - p4)
        extWave = "No clear extension"
        if wA > wB * 1.5 and wA > wC * 1.5
            extWave := "Wave 1 extended"
        else if wB > wA * 1.5 and wB > wC * 1.5
            extWave := "Wave 3 extended"
        else if wC > wA * 1.5 and wC > wB * 1.5
            extWave := "Wave 5 extended"

        fibTxt = "2️⃣ Retracement: " + str.tostring(math.round(w2retr,1)) + "%\n" +
                 "3️⃣ Extension: " + str.tostring(math.round(w3ext,1)) + "%\n" +
                 "5️⃣/1️⃣: " + str.tostring(math.round(w5rel,1)) + "%\n" +
                 "📏 " + extWave +
                 (isTruncated ? "\n⚠️ Confirmed Truncation" : "")
        label.new(t3, p3, fibTxt, xloc=xloc.bar_time, color=color.new(color.white,100), textcolor=col, style=label.style_label_up, size=size.tiny)

        if showInvalidLine
            [ivln, ivlb] = f_drawInvalidLine(t0, p0)
            invalidLine := ivln
            invalidLbl := ivlb

        if showTargets
            // Expected ABC correction target = 38.2%-61.8% retracement of full 0-5 range
            fullRange = p5 - p0
            tA382 = p5 - 0.382 * fullRange
            tA618 = p5 - 0.618 * fullRange
            boxT2 = t5 + (t5 - t4) * 3
            targetBox := box.new(t5, math.max(tA382,tA618), boxT2, math.min(tA382,tA618), xloc=xloc.bar_time, border_color=color.yellow, bgcolor=targetColor)
            targetLbl := label.new(boxT2, (tA382+tA618)/2, "ABC Correction Target\n38.2%-61.8%", xloc=xloc.bar_time, color=color.new(color.white,100), textcolor=color.yellow, style=label.style_label_right, size=size.small)

            // Immediate alternative scenario target: Projection behind start point 0 (if line breaks)
            altProjRange = p5 - p0
            altProjTarget = p0 - 0.618 * altProjRange
            altTargetBox := box.new(t0, p0, t5, altProjTarget, xloc=xloc.bar_time, border_color=invalidLineColor, bgcolor=color.new(invalidLineColor, 88))
            altTargetLbl := label.new(t0, altProjTarget, "Potential Alternative Scenario Target\n(If line breaks)", xloc=xloc.bar_time, color=color.new(color.white,100), textcolor=invalidLineColor, style=label.style_label_left, size=size.tiny)
    else if showDiagonal
        overlapOccurred = isUpCandidate ? p4 <= p1 : p4 >= p1
        isDiagValid = overlapOccurred and f_checkDiagonal(p0, p1, p2, p3, p4, p5, isUpCandidate)
        if isDiagValid
            f_delDiag()
            L1 = math.abs(p1-p0)
            L3 = math.abs(p3-p2)
            L5 = math.abs(p5-p4)
            contracting = L5 < L1
            diagShape = contracting ? "Contracting" : "Expanding"

            diagKind = na(impulseEndIdx) ? "Leading Diagonal" : "Ending Diagonal"
            structNote = ""

            if checkSubWaves
                leg1 = f_subLegCount(t0, t1)
                leg2 = f_subLegCount(t1, t2)
                leg3 = f_subLegCount(t2, t3)
                leg4 = f_subLegCount(t3, t4)
                leg5 = f_subLegCount(t4, t5)

                c1 = f_cls(leg1)
                c2 = f_cls(leg2)
                c3 = f_cls(leg3)
                c4 = f_cls(leg4)
                c5 = f_cls(leg5)

                is53535 = c1 == "5" and c2 == "3" and c3 == "5" and c4 == "3" and c5 == "5"
                is33333 = c1 == "3" and c2 == "3" and c3 == "3" and c4 == "3" and c5 == "3"

                if is53535
                    diagKind := "Leading Diagonal 5-3-5-3-5"
                    structNote := "\nConfirmed Structure: " + c1+"-"+c2+"-"+c3+"-"+c4+"-"+c5
                else if is33333
                    diagKind := na(impulseEndIdx) ? "Leading Diagonal 3-3-3-3-3" : "Ending Diagonal 3-3-3-3-3"
                    structNote := "\nConfirmed Structure: " + c1+"-"+c2+"-"+c3+"-"+c4+"-"+c5
                else
                    structNote := "\nInconclusive Structure: " + c1+"-"+c2+"-"+c3+"-"+c4+"-"+c5

            [dpoly, d0, d1, d2, d3, d4, d5] = f_drawSet(t0,p0,t1,p1,t2,p2,t3,p3,t4,p4,t5,p5, diagColor, false, "")
            diagPoly := dpoly
            diagLbl0 := d0
            diagLbl1 := d1
            diagLbl2 := d2
            diagLbl3 := d3
            diagLbl4 := d4
            diagLbl5 := d5
            diagTag := label.new(t5, p5, diagKind + "\n(" + diagShape + ")" + structNote, xloc=xloc.bar_time, color=color.new(color.white,100), textcolor=diagColor, style=label.style_label_right, size=size.small)

            // ---- Overthrow Phenomenon: Did Wave 5 exceed the 1-3 line extension? ----
            ot_slope = (p3 - p1) / (t3 - t1)
            ot_projected = p1 + ot_slope * (t5 - t1)
            isOverthrow = isUpCandidate ? (p5 > ot_projected) : (p5 < ot_projected)
            if isOverthrow
                label.new(t5, p5, "🚀 Overthrow", xloc=xloc.bar_time, color=color.new(color.white,100), textcolor=color.orange, style=label.style_label_up, size=size.small)

            // ---- Diagonal Boundary Lines: Actual Wedge Shape (line across 0-2-4 and line across 1-3-5) ----
            diagLineEndT = int(t5 + (t5 - t4) * 2)
            if ty0 == 1
                // 0,2,4 Highs (Upper Boundary) & 1,3,5 Lows (Lower Boundary)
                diagUSlope = (p4 - p0) / (t4 - t0)
                diagUEndPrice = p0 + diagUSlope * (diagLineEndT - t0)
                diagUpperLine := line.new(t0, p0, diagLineEndT, diagUEndPrice, xloc=xloc.bar_time, color=diagColor, width=2)
                diagLSlope = (p5 - p1) / (t5 - t1)
                diagLEndPrice = p1 + diagLSlope * (diagLineEndT - t1)
                diagLowerLine := line.new(t1, p1, diagLineEndT, diagLEndPrice, xloc=xloc.bar_time, color=diagColor, width=2)
            else
                // 0,2,4 Lows (Lower Boundary) & 1,3,5 Highs (Upper Boundary)
                diagLSlope2 = (p4 - p0) / (t4 - t0)
                diagLEndPrice2 = p0 + diagLSlope2 * (diagLineEndT - t0)
                diagLowerLine := line.new(t0, p0, diagLineEndT, diagLEndPrice2, xloc=xloc.bar_time, color=diagColor, width=2)
                diagUSlope2 = (p5 - p1) / (t5 - t1)
                diagUEndPrice2 = p1 + diagUSlope2 * (diagLineEndT - t1)
                diagUpperLine := line.new(t1, p1, diagLineEndT, diagUEndPrice2, xloc=xloc.bar_time, color=diagColor, width=2)

            if showInvalidLine
                f_delInvalidLine()
                [ivln2, ivlb2] = f_drawInvalidLine(t0, p0)
                invalidLine := ivln2
                invalidLbl := ivlb2

            // Link diagonal to the same invalidation tracking system used for regular impulse waves
            // (Without this, line break won't be detected and alt count/target won't be searched)
            impulseP0Price := p0
            impulseIsUp := isUpCandidate
            impulseEndIdx := n - 1
            impulseInvalidated := false
            invalidMarked := false
            activePatternType := "diagonal"

            if showTargets
                f_delTarget()
                fullRangeD = p5 - p0
                tD382 = p5 - 0.382 * fullRangeD
                tD618 = p5 - 0.618 * fullRangeD
                boxT2D = t5 + (t5 - t4) * 3
                targetBox := box.new(t5, math.max(tD382,tD618), boxT2D, math.min(tD382,tD618), xloc=xloc.bar_time, border_color=color.yellow, bgcolor=targetColor)
                targetLbl := label.new(boxT2D, (tD382+tD618)/2, "Expected Reversal Target\n38.2%-61.8%", xloc=xloc.bar_time, color=color.new(color.white,100), textcolor=color.yellow, style=label.style_label_right, size=size.small)

                // Immediate alternative scenario target: Projection behind start point 0 (if line breaks)
                f_delAltTarget()
                altProjRangeD = p5 - p0
                altProjTargetD = p0 - 0.618 * altProjRangeD
                altTargetBox := box.new(t0, p0, t5, altProjTargetD, xloc=xloc.bar_time, border_color=invalidLineColor, bgcolor=color.new(invalidLineColor, 88))
                altTargetLbl := label.new(t0, altProjTargetD, "Potential Alternative Scenario Target\n(If line breaks)", xloc=xloc.bar_time, color=color.new(color.white,100), textcolor=invalidLineColor, style=label.style_label_left, size=size.tiny)

// ================== Main Count Invalidation upon Breaking Start Point ==================
if showInvalidation and not na(impulseP0Price) and not impulseInvalidated
    brokeUp   = impulseIsUp and close < impulseP0Price
    brokeDown = not impulseIsUp and close > impulseP0Price
    if brokeUp or brokeDown
        impulseInvalidated := true
        if not na(invalidLine)
            line.set_color(invalidLine, color.red)
            line.set_style(invalidLine, line.style_solid)
            line.set_width(invalidLine, 2)
        if not na(invalidLbl)
            label.set_text(invalidLbl, "✓ Alternative Scenario Activated")
            label.set_textcolor(invalidLbl, color.red)

        if activePatternType == "diagonal"
            polyline.delete(diagPoly)
            label.set_textcolor(diagLbl0, invalidColor)
            label.set_textcolor(diagLbl1, invalidColor)
            label.set_textcolor(diagLbl2, invalidColor)
            label.set_textcolor(diagLbl3, invalidColor)
            label.set_textcolor(diagLbl4, invalidColor)
            label.set_textcolor(diagLbl5, invalidColor)
        else
            polyline.delete(impulsePoly)
            // Redraw count in dashed gray to indicate invalidation (keep points but diff appearance)
            label.set_textcolor(lbl0, invalidColor)
            label.set_textcolor(lbl1, invalidColor)
            label.set_textcolor(lbl2, invalidColor)
            label.set_textcolor(lbl3, invalidColor)
            label.set_textcolor(lbl4, invalidColor)
            label.set_textcolor(lbl5, invalidColor)
        label.new(bar_index, close, "❌ Count Invalidated\n(Start Point Broken)", color=color.new(color.white,100), textcolor=invalidColor, style=label.style_label_down, size=size.small)

        // ---- Search for Valid Alternative Count in Previous Windows ----
        if showAltCount
            altFound = false
            for back = 2 to altSearchDepth + 1
                if not altFound and n >= 6 + back
                    ap0 = array.get(zzPrice, n - 6 - back)
                    at0 = array.get(zzTime,  n - 6 - back)
                    aty0 = array.get(zzType, n - 6 - back)
                    ap1 = array.get(zzPrice, n - 5 - back)
                    at1 = array.get(zzTime,  n - 5 - back)
                    ap2 = array.get(zzPrice, n - 4 - back)
                    at2 = array.get(zzTime,  n - 4 - back)
                    ap3 = array.get(zzPrice, n - 3 - back)
                    at3 = array.get(zzTime,  n - 3 - back)
                    ap4 = array.get(zzPrice, n - 2 - back)
                    at4 = array.get(zzTime,  n - 2 - back)
                    ap5 = array.get(zzPrice, n - 1 - back)
                    at5 = array.get(zzTime,  n - 1 - back)
                    aIsUp = aty0 == -1
                    [altValid, altTrunc] = f_checkImpulse(ap0, ap1, ap2, ap3, ap4, ap5, aIsUp, at4, at5)
                    if altValid
                        altFound := true
                        f_delAlt()
                        f_delAltTarget()
                        [apoly, al0, al1, al2, al3, al4, al5] = f_drawSet(at0,ap0,at1,ap1,at2,ap2,at3,ap3,at4,ap4,at5,ap5, altColor, true, "")
                        altPoly := apoly
                        altLbl0 := al0
                        altLbl1 := al1
                        altLbl2 := al2
                        altLbl3 := al3
                        altLbl4 := al4
                        altLbl5 := al5
                        altTag := label.new(at5, ap5, "🔄 Alternative Count", xloc=xloc.bar_time, color=color.new(color.white,100), textcolor=altColor, style=label.style_label_right, size=size.small)

                        if showTargets
                            altRange = ap5 - ap0
                            altT382 = ap5 - 0.382 * altRange
                            altT618 = ap5 - 0.618 * altRange
                            altBoxEnd = at5 + (at5 - at4) * 3
                            altTargetBox := box.new(at5, math.max(altT382,altT618), altBoxEnd, math.min(altT382,altT618), xloc=xloc.bar_time, border_color=altColor, bgcolor=color.new(altColor, 85))
                            altTargetLbl := label.new(altBoxEnd, (altT382+altT618)/2, "Alternative Count Target\n38.2%-61.8%", xloc=xloc.bar_time, color=color.new(color.white,100), textcolor=altColor, style=label.style_label_right, size=size.tiny)

// ================== A-B-C Correction after Wave 5 Completion (Only if not invalidated) ==================
if showABC and not na(impulseEndIdx) and not impulseInvalidated and n >= impulseEndIdx + 4
    aI = impulseEndIdx + 1
    bI = impulseEndIdx + 2
    cI = impulseEndIdx + 3
    if cI == n - 1
        pA = array.get(zzPrice, aI)
        tA = array.get(zzTime,  aI)
        pB = array.get(zzPrice, bI)
        tB = array.get(zzTime,  bI)
        pC = array.get(zzPrice, cI)
        tC = array.get(zzTime,  cI)

        f_delABC()
        pts2 = array.new<chart.point>()
        array.push(pts2, chart.point.from_time(tA, pA))
        array.push(pts2, chart.point.from_time(tB, pB))
        array.push(pts2, chart.point.from_time(tC, pC))
        abcPoly := polyline.new(pts2, closed=false, line_color=abcColor, line_width=3)
        lblA := label.new(tA, pA, "A", xloc=xloc.bar_time, color=color.new(color.white,100), textcolor=abcColor, style=label.style_label_down, size=size.small)
        lblB := label.new(tB, pB, "B", xloc=xloc.bar_time, color=color.new(color.white,100), textcolor=abcColor, style=label.style_label_up, size=size.small)
        lblC := label.new(tC, pC, "C", xloc=xloc.bar_time, color=color.new(color.white,100), textcolor=abcColor, style=label.style_label_down, size=size.small)

// ================== Detect Triangles (5 converging or diverging points gradually) ==================
var int lastTriCheckedN = 0
if showTriangle and n >= 5 and n != lastTriCheckedN
    lastTriCheckedN := n
    qA = array.get(zzPrice, n - 5)
    tqA = array.get(zzTime,  n - 5)
    qB = array.get(zzPrice, n - 4)
    tqB = array.get(zzTime,  n - 4)
    qC = array.get(zzPrice, n - 3)
    tqC = array.get(zzTime,  n - 3)
    qD = array.get(zzPrice, n - 2)
    tqD = array.get(zzTime,  n - 2)
    qE = array.get(zzPrice, n - 1)
    tqE = array.get(zzTime,  n - 1)

    r1 = math.abs(qB - qA)
    r2 = math.abs(qC - qB)
    r3 = math.abs(qD - qC)
    r4 = math.abs(qE - qD)

    isContracting = r1 > r2 and r2 > r3 and r3 > r4
    isExpanding   = r1 < r2 and r2 < r3 and r3 < r4

    if isContracting or isExpanding
        f_delTri()
        qAType = array.get(zzType, n - 5)
        isPositive = qAType == -1   // Starts from bottom = Positive Context
        triColor = isPositive ? triPosColor : triNegColor
        triText = (isContracting ? "Contracting Triangle " : "Expanding Triangle ") + (isPositive ? "Positive ▲" : "Negative ▼")
        pts3 = array.new<chart.point>()
        array.push(pts3, chart.point.from_time(tqA, qA))
        array.push(pts3, chart.point.from_time(tqB, qB))
        array.push(pts3, chart.point.from_time(tqC, qC))
        array.push(pts3, chart.point.from_time(tqD, qD))
        array.push(pts3, chart.point.from_time(tqE, qE))
        triPoly := polyline.new(pts3, closed=false, line_color=triColor, line_width=2, curved=false)
        lblTA := label.new(tqA, qA, "A", xloc=xloc.bar_time, color=color.new(color.white,100), textcolor=triColor, style=label.style_label_down, size=size.tiny)
        lblTB := label.new(tqB, qB, "B", xloc=xloc.bar_time, color=color.new(color.white,100), textcolor=triColor, style=label.style_label_up, size=size.tiny)
        lblTC := label.new(tqC, qC, "C", xloc=xloc.bar_time, color=color.new(color.white,100), textcolor=triColor, style=label.style_label_down, size=size.tiny)
        lblTD := label.new(tqD, qD, "D", xloc=xloc.bar_time, color=color.new(color.white,100), textcolor=triColor, style=label.style_label_up, size=size.tiny)
        lblTE := label.new(tqE, qE, "E", xloc=xloc.bar_time, color=color.new(color.white,100), textcolor=triColor, style=label.style_label_down, size=size.tiny)
        lblTri := label.new(tqE, qE, triText, xloc=xloc.bar_time, color=color.new(color.white,100), textcolor=triColor, style=label.style_label_right, size=size.normal)

        // ---- Triangle Boundary Lines: Line across A-E (Upper/Lower) and across B-D (the other), limited to triangle bounds + slight extension ----
        lineEndT = int(tqE + (tqE - tqD) * 2)
        if qAType == 1
            // A,C,E Highs (Upper Boundary) & B,D Lows (Lower Boundary)
            upperSlope = (qE - qA) / (tqE - tqA)
            upperEndPrice = qA + upperSlope * (lineEndT - tqA)
            triUpperLine := line.new(tqA, qA, lineEndT, upperEndPrice, xloc=xloc.bar_time, color=triColor, width=2)
            lowerSlope = (qD - qB) / (tqD - tqB)
            lowerEndPrice = qB + lowerSlope * (lineEndT - tqB)
            triLowerLine := line.new(tqB, qB, lineEndT, lowerEndPrice, xloc=xloc.bar_time, color=triColor, width=2)
        else
            // A,C,E Lows (Lower Boundary) & B,D Highs (Upper Boundary)
            lowerSlope2 = (qE - qA) / (tqE - tqA)
            lowerEndPrice2 = qA + lowerSlope2 * (lineEndT - tqA)
            triLowerLine := line.new(tqA, qA, lineEndT, lowerEndPrice2, xloc=xloc.bar_time, color=triColor, width=2)
            upperSlope2 = (qD - qB) / (tqD - tqB)
            upperEndPrice2 = qB + upperSlope2 * (lineEndT - tqB)
            triUpperLine := line.new(tqB, qB, lineEndT, upperEndPrice2, xloc=xloc.bar_time, color=triColor, width=2)

        if showTargets
            f_delTarget()
            // Breakout Target = Width of first leg (A-B, usually the widest) from point E
            // Both directions drawn before actual breakout confirmed:
            // Direction matching triangle context (pos/neg) in its color, opposite direction (alt) in alt scenario line color
            legAB = math.abs(qB - qA)
            targetUp = qE + legAB
            targetDown = qE - legAB
            boxTend = tqE + (tqE - tqD) * 4

            targetMain = isPositive ? targetUp : targetDown
            targetAlt  = isPositive ? targetDown : targetUp

            targetBox := box.new(tqE, targetMain, boxTend, qE, xloc=xloc.bar_time, border_color=color.new(triColor,40), bgcolor=color.new(triColor, 85))
            targetLbl := label.new(boxTend, targetMain, "Breakout Target (Triangle Context)\n" + str.tostring(math.round(targetMain,4)), xloc=xloc.bar_time, color=color.new(color.white,100), textcolor=triColor, style=label.style_label_right, size=size.tiny)

            targetBoxAlt := box.new(tqE, targetAlt, boxTend, qE, xloc=xloc.bar_time, border_color=invalidLineColor, bgcolor=color.new(invalidLineColor, 85))
            targetLblAlt := label.new(boxTend, targetAlt, "Alternative Target (Opposite Direction)\n" + str.tostring(math.round(targetAlt,4)), xloc=xloc.bar_time, color=color.new(color.white,100), textcolor=invalidLineColor, style=label.style_label_right, size=size.tiny)
````
