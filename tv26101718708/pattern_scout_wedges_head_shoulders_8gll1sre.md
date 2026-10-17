# Pattern Scout   Wedges  Head Shoulders

- url: https://www.tradingview.com/script/8GLL1sre-Pattern-Scout-Wedges-Head-Shoulders/
- type: indicator
- pine_id: PUB;31fde482e3b746ada5cdd2d81a4ff97f
- version: 1.0

## Description

Pattern Scout — Wedges & Head/Shoulders

Pattern Scout automatically detects four classic chart patterns — falling wedges, rising wedges, head & shoulders, and inverse head & shoulders — and draws them directly on your chart as you scroll through history. It is a screening tool meant to surface candidates for you to review, not an automated signal generator.

▮ WHAT IT DOES
The script scans confirmed swing pivots and tests recent highs and lows against the geometric definition of each pattern. When a match is found, it draws the pattern's trendlines (or shoulder/neckline structure) and labels it. It does not repaint: a pattern is only drawn after its pivots are confirmed, so labels stay fixed once printed.

▮ HOW IT WORKS
Swing detection — Highs and lows are found using ta.pivothigh / ta.pivotlow with a configurable strength. A pivot needs N bars on each side to qualify, which is what prevents minor wiggles from registering as structure. This confirmation is also why a pattern appears a few bars after it visually completes — an unavoidable trade-off in any non-repainting swing method.

Wedges — The script takes the two most recent swing highs and the two most recent swing lows, fits a line through each pair, and checks two conditions: (1) both lines slope the same direction (down = falling wedge, up = rising wedge), and (2) the vertical gap between the lines at the end is narrower than at the start by at least the Convergence Ratio. This "narrowing channel" test is what separates a true wedge from a parallel channel. Lines are then clipped at their apex (the point where they mathematically intersect) so each wedge is a closed shape rather than two rays running off-screen.

Head & Shoulders — Looks at three consecutive swing highs. The middle high (the head) must exceed both outer highs (the shoulders), and the two shoulders must be within the Shoulder Symmetry tolerance of each other, measured as a fraction of head height. The neckline is drawn through the two intervening swing lows. Inverse H&S applies the mirror logic to three swing lows.

▮ SETTINGS
Swing strength — Bars required each side to confirm a pivot. Higher values find larger, rarer patterns with more confirmation lag. Start around 5 on intraday charts, 10–15 on daily.

Convergence ratio — How much a wedge must narrow to qualify (end gap ÷ start gap). Lower = stricter. Drop toward 0.4 if you get too many loose wedges.

Shoulder symmetry tolerance — Maximum allowed difference between the two shoulders. Loosen toward 0.08 if H&S rarely fires.

Require neckline break — When on, H&S only flags after price closes beyond the neckline. Fewer false alarms, more lag.

Max patterns kept on chart — Older patterns (lines and labels together) are automatically deleted once this cap is exceeded, keeping the chart readable.

Style — Per-pattern colours with adjustable transparency, plus an optional toggle to mark raw pivots.

▮ HOW TO USE IT
Treat each drawn pattern as a candidate, not a confirmed setup. Patterns are detected from the two most recent swings, so they are the simple two-touch variety rather than multi-touch channels. Always eyeball each one in context — chart-pattern recognition is inherently subjective, and the script will occasionally label structure that your eye would dismiss. Tune the three core knobs (swing strength, convergence ratio, shoulder symmetry) per instrument and timeframe to match your own reading.

Alerts are included for all four pattern types.

▮ LIMITATIONS
- Two-swing geometry only; it will not capture every variation of these patterns.
- Confirmation lag is intrinsic to non-repainting pivots.
- Pattern detection is a starting point for analysis, not a trading recommendation.

This script is provided for educational and analytical purposes. It does not provide financial advice and makes no claim about future price movement or profitability. Always do your own analysis and manage risk accordingly.

## Source Code

````pine
//@version=6
indicator("Pattern Scout — Wedges & Head/Shoulders", overlay=true, max_lines_count=500, max_labels_count=500)

// ════════════════════ Inputs ════════════════════
gP = "① Pivots"
pivotLen = input.int(8, "Swing strength (bars each side)", minval=2, maxval=50, group=gP, tooltip="Bars required left & right to confirm a swing. Larger = bigger, rarer patterns + more lag.")

gW = "② Wedges"
showWedge  = input.bool(true, "Detect wedges", group=gW)
convThresh = input.float(0.6, "Convergence ratio (end gap ÷ start gap)", minval=0.1, maxval=0.95, step=0.05, group=gW, tooltip="Trendlines must narrow to ≤ this fraction of their starting gap. Lower = stricter.")
stopAtApex = input.bool(true, "Stop wedge lines at apex (intersection)", group=gW, tooltip="On: both lines stop where they cross. Off: they stop at the last swing.")

gH = "③ Head & Shoulders"
showHS    = input.bool(true, "Detect head & shoulders", group=gH)
shTol     = input.float(0.05, "Shoulder symmetry tolerance", minval=0.01, maxval=0.30, step=0.01, group=gH, tooltip="Max difference between the two shoulders as a fraction of head height.")
needBreak = input.bool(false, "Require neckline break to confirm", group=gH, tooltip="If on, H&S only flags once price closes beyond the neckline. Fewer false alarms, more lag.")

gC = "④ Cleanup"
maxPatterns = input.int(20, "Max patterns kept on chart", minval=1, maxval=100, group=gC, tooltip="Older patterns are deleted as new ones appear. Raise to keep more history (costs clutter).")

gS = "⑤ Style"
colFall = input.color(color.new(color.lime,   30), "Falling wedge",    group=gS)
colRise = input.color(color.new(color.red,    30), "Rising wedge",     group=gS)
colHS   = input.color(color.new(color.orange, 30), "Head & shoulders", group=gS)
colIHS  = input.color(color.new(color.aqua,   30), "Inverse H&S",      group=gS)
showPiv = input.bool(false, "Mark raw pivots", group=gS)

// ════════════════════ Helpers ════════════════════
evalLine(float x1, float y1, float x2, float y2, float xq) =>
    float s = (y2 - y1) / (x2 - x1)
    y1 + s * (xq - x1)

// Intersection (apex) of upper line (h1→h2) and lower line (l1→l2)
f_apex(int h1x, float h1, int h2x, float h2, int l1x, float l1, int l2x, float l2) =>
    float sH = (h2 - h1) / (h2x - h1x)
    float sL = (l2 - l1) / (l2x - l1x)
    float denom = sH - sL
    int   axI = na
    float ay  = na
    if denom != 0
        float axF = ((l1 - h1) + sH * h1x - sL * l1x) / denom
        axI := int(math.round(axF))
        ay  := h1 + sH * (axF - h1x)
    [axI, ay]

// ════════════════════ Pattern object store (for cleanup) ════════════════════
var array<line>  pLines   = array.new<line>()
var array<label> pLabels  = array.new<label>()
var array<int>   pLineCnt = array.new<int>()

registerPattern(array<line> lns, label lbl) =>
    int k = array.size(lns)
    for i = 0 to k - 1
        array.push(pLines, array.get(lns, i))
    array.push(pLabels, lbl)
    array.push(pLineCnt, k)
    while array.size(pLabels) > maxPatterns
        int kk = array.shift(pLineCnt)
        for j = 1 to kk
            line.delete(array.shift(pLines))
        label.delete(array.shift(pLabels))

// ════════════════════ Pivot storage ════════════════════
var array<float> phP = array.new<float>()
var array<int>   phX = array.new<int>()
var array<float> plP = array.new<float>()
var array<int>   plX = array.new<int>()
int MAXP = 12

ph = ta.pivothigh(pivotLen, pivotLen)
pl = ta.pivotlow(pivotLen, pivotLen)
bool newPivot = false

if not na(ph)
    array.push(phP, ph)
    array.push(phX, bar_index - pivotLen)
    if array.size(phP) > MAXP
        array.shift(phP)
        array.shift(phX)
    newPivot := true
    if showPiv
        label.new(bar_index - pivotLen, ph, "•", style=label.style_none, textcolor=color.gray, size=size.tiny)

if not na(pl)
    array.push(plP, pl)
    array.push(plX, bar_index - pivotLen)
    if array.size(plP) > MAXP
        array.shift(plP)
        array.shift(plX)
    newPivot := true
    if showPiv
        label.new(bar_index - pivotLen, pl, "•", style=label.style_none, textcolor=color.gray, size=size.tiny)

f_lowBetween(int xL, int xR) =>
    float lo  = na
    int   lox = na
    if array.size(plP) > 0
        for i = 0 to array.size(plP) - 1
            int bx = array.get(plX, i)
            if bx > xL and bx < xR
                float v = array.get(plP, i)
                if na(lo) or v < lo
                    lo  := v
                    lox := bx
    [lo, lox]

f_highBetween(int xL, int xR) =>
    float hi  = na
    int   hix = na
    if array.size(phP) > 0
        for i = 0 to array.size(phP) - 1
            int bx = array.get(phX, i)
            if bx > xL and bx < xR
                float v = array.get(phP, i)
                if na(hi) or v > hi
                    hi  := v
                    hix := bx
    [hi, hix]

// ════════════════════ Wedge detection ════════════════════
f_wedge() =>
    string kind = na
    int aX = na, float aY = na, int bX = na, float bY = na
    int cX = na, float cY = na, int dX = na, float dY = na
    if array.size(phP) >= 2 and array.size(plP) >= 2
        int n = array.size(phP)
        int m = array.size(plP)
        float h1 = array.get(phP, n - 2), float h2 = array.get(phP, n - 1)
        int   h1x = array.get(phX, n - 2), int h2x = array.get(phX, n - 1)
        float l1 = array.get(plP, m - 2), float l2 = array.get(plP, m - 1)
        int   l1x = array.get(plX, m - 2), int l2x = array.get(plX, m - 1)
        float sH = (h2 - h1) / (h2x - h1x)
        float sL = (l2 - l1) / (l2x - l1x)
        int   xA = math.min(math.min(h1x, l1x), math.min(h2x, l2x))
        int   xB = math.max(math.max(h1x, l1x), math.max(h2x, l2x))
        float gA = evalLine(h1x, h1, h2x, h2, xA) - evalLine(l1x, l1, l2x, l2, xA)
        float gB = evalLine(h1x, h1, h2x, h2, xB) - evalLine(l1x, l1, l2x, l2, xB)
        bool conv = math.abs(gA) > 0 and math.abs(gB) < math.abs(gA) * convThresh
        if sH < 0 and sL < 0 and conv
            kind := "Falling Wedge"
        else if sH > 0 and sL > 0 and conv
            kind := "Rising Wedge"
        if not na(kind)
            aX := h1x, aY := h1, bX := h2x, bY := h2
            cX := l1x, cY := l1, dX := l2x, dY := l2
    [kind, aX, aY, bX, bY, cX, cY, dX, dY]

// ════════════════════ Head & Shoulders ════════════════════
f_hs() =>
    string kind = na
    int lsX = na, float lsY = na, int hdX = na, float hdY = na, int rsX = na, float rsY = na
    int n1X = na, float n1Y = na, int n2X = na, float n2Y = na
    if array.size(phP) >= 3 and array.size(plP) >= 2
        int n = array.size(phP)
        float a = array.get(phP, n - 3), float b = array.get(phP, n - 2), float c = array.get(phP, n - 1)
        int   ax = array.get(phX, n - 3), int bx = array.get(phX, n - 2), int cx = array.get(phX, n - 1)
        if b > a and b > c and (math.abs(a - c) / b) < shTol
            [lo1, lo1x] = f_lowBetween(ax, bx)
            [lo2, lo2x] = f_lowBetween(bx, cx)
            if not na(lo1) and not na(lo2)
                kind := "H&S"
                lsX := ax, lsY := a, hdX := bx, hdY := b, rsX := cx, rsY := c
                n1X := lo1x, n1Y := lo1, n2X := lo2x, n2Y := lo2
    [kind, lsX, lsY, hdX, hdY, rsX, rsY, n1X, n1Y, n2X, n2Y]

f_ihs() =>
    string kind = na
    int lsX = na, float lsY = na, int hdX = na, float hdY = na, int rsX = na, float rsY = na
    int n1X = na, float n1Y = na, int n2X = na, float n2Y = na
    if array.size(plP) >= 3 and array.size(phP) >= 2
        int n = array.size(plP)
        float a = array.get(plP, n - 3), float b = array.get(plP, n - 2), float c = array.get(plP, n - 1)
        int   ax = array.get(plX, n - 3), int bx = array.get(plX, n - 2), int cx = array.get(plX, n - 1)
        if b < a and b < c and (math.abs(a - c) / b) < shTol
            [hi1, hi1x] = f_highBetween(ax, bx)
            [hi2, hi2x] = f_highBetween(bx, cx)
            if not na(hi1) and not na(hi2)
                kind := "Inverse H&S"
                lsX := ax, lsY := a, hdX := bx, hdY := b, rsX := cx, rsY := c
                n1X := hi1x, n1Y := hi1, n2X := hi2x, n2Y := hi2
    [kind, lsX, lsY, hdX, hdY, rsX, rsY, n1X, n1Y, n2X, n2Y]

// ════════════════════ Draw: Wedges ════════════════════
var int lastWedgeX = -1
bool fallSig = false, bool riseSig = false
[wk, wAx, wAy, wBx, wBy, wCx, wCy, wDx, wDy] = f_wedge()
if showWedge and not na(wk) and newPivot
    int wEnd = math.max(wBx, wDx)
    if wEnd != lastWedgeX
        lastWedgeX := wEnd
        color wc = wk == "Falling Wedge" ? colFall : colRise
        // Where do the lines cross?
        [apexX, apexY] = f_apex(wAx, wAy, wBx, wBy, wCx, wCy, wDx, wDy)
        int wStart = math.min(wAx, wCx)
        int maxApex = wEnd + (wEnd - wStart) * 3
        int drawTo = wEnd
        if stopAtApex and not na(apexX) and apexX > wEnd and apexX <= maxApex
            drawTo := apexX
        float upEnd = evalLine(wAx, wAy, wBx, wBy, drawTo)
        float loEnd = evalLine(wCx, wCy, wDx, wDy, drawTo)
        array<line> ln = array.new<line>()
        array.push(ln, line.new(wAx, wAy, drawTo, upEnd, color=wc, width=1))
        array.push(ln, line.new(wCx, wCy, drawTo, loEnd, color=wc, width=1))
        label lb = label.new(wBx, wBy, wk, style=label.style_label_down, color=wc, textcolor=color.white, size=size.small)
        registerPattern(ln, lb)
        fallSig := wk == "Falling Wedge"
        riseSig := wk == "Rising Wedge"

// ════════════════════ Draw: H&S ════════════════════
var int lastHSx = -1
bool hsSig = false
[hk, hLs, hLsy, hHd, hHdy, hRs, hRsy, hN1, hN1y, hN2, hN2y] = f_hs()
if showHS and not na(hk) and newPivot and hRs != lastHSx
    float neckHS = evalLine(hN1, hN1y, hN2, hN2y, bar_index)
    if not needBreak or close < neckHS
        lastHSx := hRs
        int   nStart  = math.min(hLs, hN1)
        int   projEnd = hRs + int(math.round((hRs - hLs) * 0.5))
        float nSY = evalLine(hN1, hN1y, hN2, hN2y, nStart)
        float nEY = evalLine(hN1, hN1y, hN2, hN2y, projEnd)
        array<line> ln = array.new<line>()
        array.push(ln, line.new(hLs, hLsy, hHd, hHdy, color=colHS, width=1))
        array.push(ln, line.new(hHd, hHdy, hRs, hRsy, color=colHS, width=1))
        array.push(ln, line.new(nStart, nSY, projEnd, nEY, color=colHS, width=1, style=line.style_dashed))
        label lb = label.new(hHd, hHdy, "H&S", style=label.style_label_down, color=colHS, textcolor=color.white, size=size.small)
        registerPattern(ln, lb)
        hsSig := true

// ════════════════════ Draw: Inverse H&S ════════════════════
var int lastIHSx = -1
bool ihsSig = false
[ik, iLs, iLsy, iHd, iHdy, iRs, iRsy, iN1, iN1y, iN2, iN2y] = f_ihs()
if showHS and not na(ik) and newPivot and iRs != lastIHSx
    float neckIHS = evalLine(iN1, iN1y, iN2, iN2y, bar_index)
    if not needBreak or close > neckIHS
        lastIHSx := iRs
        int   nStart  = math.min(iLs, iN1)
        int   projEnd = iRs + int(math.round((iRs - iLs) * 0.5))
        float nSY = evalLine(iN1, iN1y, iN2, iN2y, nStart)
        float nEY = evalLine(iN1, iN1y, iN2, iN2y, projEnd)
        array<line> ln = array.new<line>()
        array.push(ln, line.new(iLs, iLsy, iHd, iHdy, color=colIHS, width=1))
        array.push(ln, line.new(iHd, iHdy, iRs, iRsy, color=colIHS, width=1))
        array.push(ln, line.new(nStart, nSY, projEnd, nEY, color=colIHS, width=1, style=line.style_dashed))
        label lb = label.new(iHd, iHdy, "Inverse H&S", style=label.style_label_up, color=colIHS, textcolor=color.white, size=size.small)
        registerPattern(ln, lb)
        ihsSig := true

// ════════════════════ Alerts ════════════════════
alertcondition(fallSig, "Falling Wedge",    "Falling wedge detected")
alertcondition(riseSig, "Rising Wedge",     "Rising wedge detected")
alertcondition(hsSig,   "Head & Shoulders", "Head & shoulders detected")
alertcondition(ihsSig,  "Inverse H&S",      "Inverse head & shoulders detected")
````
