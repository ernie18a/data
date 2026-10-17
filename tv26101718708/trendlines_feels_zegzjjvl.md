# Trendlines [FEELS]

- url: https://www.tradingview.com/script/ZegzjJVl-Trendlines-FEELS/
- type: indicator
- pine_id: PUB;9a9c8d8b9a914122b53028864a06ebce
- version: 1.0

## Description

Auto trendline tools tend to draw every line they can find, then quietly redraw them when price disagrees. This indicator does the opposite: a line is drawn only after price has respected it three times, and once drawn it never moves. Every line carries its own proof, a plain-text counter of how many times price has touched it.

[b]HOW IT WORKS[/b]

The engine pairs confirmed swing pivots and validates the segment between them: if price closed through it anywhere along the way, the pair is rejected. Survivors become invisible candidates. A candidate is promoted to a real chart line only when a third touch confirms that the market actually respects it, and from that moment the geometry is locked.

- Touch counter: every line is labeled in plain text, "Support · 3 touches". More touches also make the line thicker, so the most respected line on the chart is the most visible one.
- Two scales: the base set tracks the swings you trade, the Major set (thicker, built from roughly 3x bigger swings) tracks the macro structure.
- Breaks: a break is a close beyond the line plus an ATR buffer, marked on the chart when it happens. Wicks through the line do not count.
- Flip watch: a broken line is not deleted. It stays on the chart as a dotted grey ghost, and when price returns to it from the other side, a Retest marker prints: broken support acting as resistance, tracked automatically. Ghosts expire on their own.
- Housekeeping: near-duplicate lines merge into the stronger one, and lines nobody has touched for a long time, or that drifted more than 10 ATR away from price, retire quietly. The chart stays at a few lines that matter instead of a fan of guesses.


[b]HOW TO READ IT[/b]

1. The touch counter is a strength ranking. A line with 5 touches has proven itself more than a line with 3, and the strongest lines are where reactions have historically been most consistent.
2. Touches and breaks read differently. Price returning to a rising support with a high touch count is the classic trend pullback structure. A close through the line (Break marker) means the structure that carried the trend is gone.
3. Retest markers show the flip. After a break, the old line often gets tested from the other side; the Retest marker prints when that happens, with the line itself as the natural invalidation level of the pattern.

https://www.tradingview.com/x/9WHxseho/

[b]HONESTY[/b]

- Confirmation has a cost. A swing pivot confirms only after the "Swing size" number of bars, so a line appears on the chart only once its third touch is confirmed, and at that moment it is drawn back to its origin. On a bar replay this looks like a line appearing into the past out of nowhere. That is the price of the no-repaint rule, not a glitch.
- After a line is drawn its position never changes. Breaks are evaluated on closed bars only, and Break/Retest markers stay where they printed.
- The touch badges at the right edge follow the last bar for readability; that movement is cosmetic, not a signal.
- Touch and break tolerances are ATR-based, so they adapt to each symbol's volatility instead of using fixed percentages.
- Works on any symbol and timeframe with enough history to form swings.

https://www.tradingview.com/x/Fl8UHyu1/

[b]ALERTS[/b]

New support line · New resistance line · Support touched · Resistance touched · Support broken · Resistance broken · Flip retest.

[b]SETTINGS[/b]

Every input has a tooltip. The ones that change the picture most: "Swing size" sets how big a swing must be to anchor a line, "Touches to confirm" is the promotion rule (3 by default), "Max lines per side" caps the chart at the lines that matter, "Macro lines" adds the thicker second scale, "Line width" and "Text size" scale the visuals for presentations.

[b]ORIGINALITY[/b]

Most auto-trendline scripts connect the latest two pivots and update the line as new pivots print, so the line you see today is not the line you saw yesterday. This engine is built the other way around: lines must earn their place through touch-count validation before they exist, their geometry is locked after, near-duplicates are merged, and broken lines move to a ghost stage that keeps tracking them for the support/resistance flip. The pivot pairing, segment validation, touch accounting and the line lifecycle are written from scratch for this script.

This is a descriptive tool for reading trendline structure. It is not financial advice and does not predict price.

## Source Code

````pine
//@version=6
indicator("Trendlines [FEELS]", "Trendlines [FEELS]", overlay = true, max_lines_count = 500, max_labels_count = 500, max_bars_back = 1000)

//--- inputs
pivLen     = input.int(10, "Swing size", minval = 3, maxval = 50, tooltip = "Pivot width on each side. Bigger = fewer, more significant swings and lines")
minTouches = input.int(3, "Touches to confirm", minval = 2, maxval = 6, tooltip = "A line is drawn only after price has respected it this many times, anchors included")
touchTolIn = input.float(0.25, "Touch tolerance, ATR", minval = 0.05, maxval = 1, step = 0.05, tooltip = "How close price must come to the line to count as a touch")
breakTolIn = input.float(0.15, "Break buffer, ATR", minval = 0, maxval = 1, step = 0.05, tooltip = "Close must clear the line by this much to count as a break, filters wick noise")
maxActive  = input.int(2, "Max lines per side", minval = 1, maxval = 6, tooltip = "Only the most respected support and resistance lines stay on the chart")
maxSpan    = input.int(500, "Max line span, bars", minval = 100, maxval = 800, tooltip = "Pivots further apart than this are not connected")
staleBars  = input.int(200, "Retire untouched after, bars", minval = 50, maxval = 500, tooltip = "An active line nobody touched for this long is quietly removed")
showGhosts = input.bool(true, "Keep broken lines", tooltip = "Broken lines stay as dotted ghosts and are watched for the support/resistance flip retest")
flipWatch  = input.int(150, "Flip watch, bars", minval = 20, maxval = 400, tooltip = "How long a broken line stays on the chart waiting for the flip retest")
maxMarks   = input.int(10, "Event markers kept", minval = 0, maxval = 60, tooltip = "Break and Retest markers beyond this many are removed, oldest first. 0 hides them")

grpM = "Macro lines"
useMacro   = input.bool(true, "Second scale", group = grpM, tooltip = "Adds a thicker set of trendlines built from bigger swings")
pivLen2    = input.int(30, "Macro swing size", minval = 10, maxval = 150, group = grpM, tooltip = "Pivot width for the macro set, works well near 3x the base swing size")
maxActive2 = input.int(1, "Macro lines per side", minval = 1, maxval = 3, group = grpM, tooltip = "How many macro support and resistance lines are kept")

grpS = "Style"
supCol   = input.color(#089981, "Support", group = grpS)
resCol   = input.color(#f23645, "Resistance", group = grpS)
ghostCol = input.color(color.new(#787b86, 30), "Broken", group = grpS)
flipCol  = input.color(#ff9800, "Retest", group = grpS)
txtSizeS = input.string("Normal", "Text size", options = ["Tiny", "Small", "Normal", "Large"], group = grpS)
lineW    = input.int(2, "Line width", minval = 1, maxval = 5, group = grpS, tooltip = "Base thickness. Lines still thicken as they collect touches, macro lines start one step thicker")
showMarks = input.bool(true, "Break / Retest markers", group = grpS, tooltip = "Prints Break and Retest events on the chart. Alerts fire either way")
mkSizeS   = input.string("Auto", "Marker size", options = ["Auto", "Tiny", "Small", "Normal", "Large"], group = grpS, tooltip = "Auto keeps markers one step smaller than the line badges")

txtSize = txtSizeS == "Tiny" ? size.tiny : txtSizeS == "Small" ? size.small : txtSizeS == "Large" ? size.large : size.normal
mkAuto  = txtSizeS == "Large" ? size.normal : txtSizeS == "Normal" ? size.small : size.tiny
mkSize  = mkSizeS == "Auto" ? mkAuto : mkSizeS == "Tiny" ? size.tiny : mkSizeS == "Small" ? size.small : mkSizeS == "Large" ? size.large : size.normal

//--- state
type TL
    line  ln
    label badge
    int   dir
    int   x1
    float y1
    float slope
    int   touches
    int   lastTouch
    int   breakBar
    int   flips
    int   lastFlip
    int   farCnt
    int   scl

var cands   = array.new<TL>()
var actives = array.new<TL>()
var ghosts  = array.new<TL>()
var marks   = array.new<label>()
var lastMark = array.new<int>(1, -10000)
var phB = array.new<int>()
var phV = array.new<float>()
var plB = array.new<int>()
var plV = array.new<float>()
var phB2 = array.new<int>()
var phV2 = array.new<float>()
var plB2 = array.new<int>()
var plV2 = array.new<float>()

atr = ta.atr(14)
ph  = ta.pivothigh(pivLen, pivLen)
pl  = ta.pivotlow(pivLen, pivLen)
ph2 = ta.pivothigh(pivLen2, pivLen2)
pl2 = ta.pivotlow(pivLen2, pivLen2)

touchTol = atr * touchTolIn
breakTol = atr * breakTolIn

f_val(TL t) =>
    t.y1 + t.slope * (bar_index - t.x1)

f_badgeTxt(TL t) =>
    pre = t.scl == 2 ? (t.dir == 1 ? "Major support · " : "Major resistance · ") : (t.dir == 1 ? "Support · " : "Resistance · ")
    pre + str.tostring(t.touches) + " touches"

//--- distance between two lines, sampled now and 120 bars back
f_lineDist(float ya, float ka, int xa, float yb, float kb, int xb) =>
    d1 = math.abs(ya + ka * (bar_index - xa) - yb - kb * (bar_index - xb))
    d0 = math.abs(ya + ka * (bar_index - 120 - xa) - yb - kb * (bar_index - 120 - xb))
    math.min(d1, d0)

f_dup(int dir, float slope, int px, float py) =>
    d = false
    i = 0
    while i < array.size(actives) and not d
        t = array.get(actives, i)
        if t.dir == dir and f_lineDist(t.y1, t.slope, t.x1, py, slope, px) < 3 * touchTol and math.abs(t.slope - slope) * 100 < 2 * touchTol
            d := true
        i += 1
    i := 0
    while i < array.size(cands) and not d
        t = array.get(cands, i)
        if t.dir == dir and f_lineDist(t.y1, t.slope, t.x1, py, slope, px) < 3 * touchTol and math.abs(t.slope - slope) * 100 < 2 * touchTol
            d := true
        i += 1
    d

//--- pair the new pivot with stored ones, validate the segment, count touches
f_tryLines(int dir, int pb2, float v2, array<int> pbs, array<float> pvs, int scl, int pLen) =>
    n = array.size(pbs)
    if n > 0
        for i = 0 to n - 1
            pb1 = array.get(pbs, i)
            v1  = array.get(pvs, i)
            span = pb2 - pb1
            if span >= pLen and span <= maxSpan and bar_index - pb1 < 900
                slope = (v2 - v1) / span
                if math.abs(slope) <= atr * 0.2
                    ok = true
                    tCnt = 0
                    lastT = -10000
                    for b = pb1 to bar_index
                        o = bar_index - b
                        lv = v1 + slope * (b - pb1)
                        tolT = atr[o] * touchTolIn
                        tolB = atr[o] * breakTolIn
                        if dir == 1
                            if close[o] < lv - tolB
                                ok := false
                                break
                            if low[o] <= lv + tolT and b - lastT >= pLen
                                tCnt += 1
                                lastT := b
                        else
                            if close[o] > lv + tolB
                                ok := false
                                break
                            if high[o] >= lv - tolT and b - lastT >= pLen
                                tCnt += 1
                                lastT := b
                    if ok and tCnt >= 2
                        if not f_dup(dir, slope, pb1, v1)
                            array.push(cands, TL.new(line(na), label(na), dir, pb1, v1, slope, tCnt, lastT, 0, 0, -10000, 0, scl))
    while array.size(cands) > 24
        array.remove(cands, 0)

f_activate(TL t) =>
    col = t.dir == 1 ? supCol : resCol
    base = t.scl == 2 ? lineW + 1 : lineW
    t.ln := line.new(t.x1, t.y1, bar_index, f_val(t), extend = extend.right, color = col, width = math.min(base + t.touches - minTouches, base + 3))
    t.badge := label.new(bar_index + 3, t.y1 + t.slope * (bar_index + 3 - t.x1), f_badgeTxt(t), style = t.dir == 1 ? label.style_label_upper_left : label.style_label_lower_left, color = color.new(col, 100), textcolor = col, size = txtSize)
    array.push(actives, t)

f_mark(float y, string txt, bool bull, color c) =>
    if showMarks and maxMarks > 0 and bar_index - array.get(lastMark, 0) >= 3
        array.push(marks, label.new(bar_index, y, txt, style = bull ? label.style_label_up : label.style_label_down, color = color.new(c, 100), textcolor = c, size = mkSize))
        array.set(lastMark, 0, bar_index)
        while array.size(marks) > maxMarks
            label.delete(array.get(marks, 0))
            array.remove(marks, 0)

//--- converging near-duplicates collapse into the stronger line
f_merge() =>
    i = 0
    while i < array.size(actives)
        j = i + 1
        removedI = false
        while j < array.size(actives) and not removedI
            a = array.get(actives, i)
            b = array.get(actives, j)
            if a.dir == b.dir and math.abs(f_val(a) - f_val(b)) < 4 * touchTol
                keepA = a.scl > b.scl or (a.scl == b.scl and (a.touches > b.touches or (a.touches == b.touches and a.lastTouch >= b.lastTouch)))
                if keepA
                    line.delete(b.ln)
                    label.delete(b.badge)
                    array.remove(actives, j)
                else
                    line.delete(a.ln)
                    label.delete(a.badge)
                    array.remove(actives, i)
                    removedI := true
            else
                j += 1
        if not removedI
            i += 1

f_capActives(int dir, int scl, int cap) =>
    cnt = 0
    if array.size(actives) > 0
        for i = 0 to array.size(actives) - 1
            tc = array.get(actives, i)
            if tc.dir == dir and tc.scl == scl
                cnt += 1
    while cnt > cap
        wIdx = -1
        wT = 999
        wLast = 2147483647
        for i = 0 to array.size(actives) - 1
            t = array.get(actives, i)
            if t.dir == dir and t.scl == scl and (t.touches < wT or (t.touches == wT and t.lastTouch < wLast))
                wIdx := i
                wT := t.touches
                wLast := t.lastTouch
        if wIdx >= 0
            t = array.get(actives, wIdx)
            line.delete(t.ln)
            label.delete(t.badge)
            array.remove(actives, wIdx)
        cnt -= 1

//--- engine, state mutates on closed bars only
newSup    = false
newRes    = false
supTouch  = false
resTouch  = false
supBreak  = false
resBreak  = false
flipHit   = false
brkMarked = false
rtMarked  = false

if barstate.isconfirmed
    if not na(ph)
        f_tryLines(-1, bar_index - pivLen, ph, phB, phV, 1, pivLen)
        array.push(phB, bar_index - pivLen)
        array.push(phV, ph)
        if array.size(phB) > 12
            array.shift(phB)
            array.shift(phV)
    if not na(pl)
        f_tryLines(1, bar_index - pivLen, pl, plB, plV, 1, pivLen)
        array.push(plB, bar_index - pivLen)
        array.push(plV, pl)
        if array.size(plB) > 12
            array.shift(plB)
            array.shift(plV)
    if useMacro
        if not na(ph2)
            f_tryLines(-1, bar_index - pivLen2, ph2, phB2, phV2, 2, pivLen2)
            array.push(phB2, bar_index - pivLen2)
            array.push(phV2, ph2)
            if array.size(phB2) > 12
                array.shift(phB2)
                array.shift(phV2)
        if not na(pl2)
            f_tryLines(1, bar_index - pivLen2, pl2, plB2, plV2, 2, pivLen2)
            array.push(plB2, bar_index - pivLen2)
            array.push(plV2, pl2)
            if array.size(plB2) > 12
                array.shift(plB2)
                array.shift(plV2)

    //--- candidates: break kills, enough touches activates
    i = 0
    while i < array.size(cands)
        t = array.get(cands, i)
        lv = f_val(t)
        dead = false
        if t.dir == 1
            if close < lv - breakTol
                dead := true
            else if low <= lv + touchTol and bar_index - t.lastTouch >= (t.scl == 2 ? pivLen2 : pivLen)
                t.touches := t.touches + 1
                t.lastTouch := bar_index
        else
            if close > lv + breakTol
                dead := true
            else if high >= lv - touchTol and bar_index - t.lastTouch >= (t.scl == 2 ? pivLen2 : pivLen)
                t.touches := t.touches + 1
                t.lastTouch := bar_index
        if not dead and bar_index - t.lastTouch > 400
            dead := true
        if dead
            array.remove(cands, i)
        else if t.touches >= minTouches
            f_activate(t)
            if t.dir == 1
                newSup := true
            else
                newRes := true
            array.remove(cands, i)
        else
            i += 1
    f_merge()
    f_capActives(1, 1, maxActive)
    f_capActives(-1, 1, maxActive)
    f_capActives(1, 2, maxActive2)
    f_capActives(-1, 2, maxActive2)

    //--- active lines: touches thicken, breaks turn ghosts
    i := 0
    while i < array.size(actives)
        t = array.get(actives, i)
        lv = f_val(t)
        broke = false
        if t.dir == 1
            if close < lv - breakTol
                broke := true
            else if low <= lv + touchTol and bar_index - t.lastTouch >= (t.scl == 2 ? pivLen2 : pivLen)
                t.touches := t.touches + 1
                t.lastTouch := bar_index
                line.set_width(t.ln, math.min((t.scl == 2 ? lineW + 1 : lineW) + t.touches - minTouches, (t.scl == 2 ? lineW + 1 : lineW) + 3))
                label.set_text(t.badge, f_badgeTxt(t))
                supTouch := true
        else
            if close > lv + breakTol
                broke := true
            else if high >= lv - touchTol and bar_index - t.lastTouch >= (t.scl == 2 ? pivLen2 : pivLen)
                t.touches := t.touches + 1
                t.lastTouch := bar_index
                line.set_width(t.ln, math.min((t.scl == 2 ? lineW + 1 : lineW) + t.touches - minTouches, (t.scl == 2 ? lineW + 1 : lineW) + 3))
                label.set_text(t.badge, f_badgeTxt(t))
                resTouch := true
        if broke
            t.breakBar := bar_index
            if not brkMarked
                f_mark(lv, "Break", t.dir != 1, t.dir == 1 ? resCol : supCol)
                brkMarked := true
            if t.dir == 1
                supBreak := true
            else
                resBreak := true
            label.delete(t.badge)
            t.badge := label(na)
            if showGhosts
                line.set_style(t.ln, line.style_dotted)
                line.set_width(t.ln, 1)
                line.set_color(t.ln, ghostCol)
                array.push(ghosts, t)
            else
                line.delete(t.ln)
            array.remove(actives, i)
        else
            t.farCnt := math.abs(close - lv) > 10 * atr ? t.farCnt + 1 : 0
            if bar_index - t.lastTouch > staleBars or t.farCnt > 30
                line.delete(t.ln)
                label.delete(t.badge)
                array.remove(actives, i)
            else
                i += 1

    //--- ghosts: watch the flip retest, expire quietly
    i := 0
    while i < array.size(ghosts)
        t = array.get(ghosts, i)
        lv = f_val(t)
        if t.dir == 1
            if high >= lv - touchTol and close <= lv + breakTol and bar_index - t.lastFlip >= (t.scl == 2 ? pivLen2 : pivLen) and bar_index - t.breakBar >= (t.scl == 2 ? pivLen2 : pivLen)
                t.flips := t.flips + 1
                t.lastFlip := bar_index
                if not rtMarked
                    f_mark(lv, "Retest", false, flipCol)
                    rtMarked := true
                flipHit := true
        else
            if low <= lv + touchTol and close >= lv - breakTol and bar_index - t.lastFlip >= (t.scl == 2 ? pivLen2 : pivLen) and bar_index - t.breakBar >= (t.scl == 2 ? pivLen2 : pivLen)
                t.flips := t.flips + 1
                t.lastFlip := bar_index
                if not rtMarked
                    f_mark(lv, "Retest", true, flipCol)
                    rtMarked := true
                flipHit := true
        reclaimed = t.dir == 1 ? close > lv + 3 * touchTol : close < lv - 3 * touchTol
        if bar_index - t.breakBar > flipWatch or t.flips >= 2 or reclaimed
            line.delete(t.ln)
            array.remove(ghosts, i)
        else
            i += 1

//--- keep badges pinned to the right edge, slide colliding ones further right
if barstate.islast and array.size(actives) > 0
    xs = array.new<int>()
    ys = array.new<float>()
    for i = 0 to array.size(actives) - 1
        t = array.get(actives, i)
        x = bar_index + 3
        y = t.y1 + t.slope * (x - t.x1)
        guard = 0
        while guard < 6
            hit = false
            if array.size(xs) > 0
                for k = 0 to array.size(xs) - 1
                    if math.abs(x - array.get(xs, k)) < 10 and math.abs(y - array.get(ys, k)) < 6 * touchTol
                        hit := true
            if not hit
                break
            x += 12
            y := t.y1 + t.slope * (x - t.x1)
            guard += 1
        array.push(xs, x)
        array.push(ys, y)
        label.set_xy(t.badge, x, y)

alertcondition(newSup, "New support line", "New support trendline confirmed")
alertcondition(newRes, "New resistance line", "New resistance trendline confirmed")
alertcondition(supTouch, "Support touched", "Price touched a support trendline")
alertcondition(resTouch, "Resistance touched", "Price touched a resistance trendline")
alertcondition(supBreak, "Support broken", "A support trendline broke on close")
alertcondition(resBreak, "Resistance broken", "A resistance trendline broke on close")
alertcondition(flipHit, "Flip retest", "Price retested a broken trendline from the other side")
````
