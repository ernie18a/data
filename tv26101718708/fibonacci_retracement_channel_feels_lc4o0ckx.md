# Fibonacci Retracement Channel [FEELS]

- url: https://www.tradingview.com/script/LC4O0CKX-Fibonacci-Retracement-Channel-FEELS/
- type: indicator
- pine_id: PUB;422bb764a1064c2294e26bde84c71dbf
- version: 1.0

## Description

Stop dragging fib tools around your chart. Fib Channel plots a complete, classic Fibonacci retracement on every major swing, anchored wick to wick, right where you would draw it by hand. It shades the golden pocket, projects extension targets and links the whole history into one flowing channel.

You always know which level the market is trading against right now, and where price goes if that level holds. Instead of a single fib on the latest swing, or a pile of overlapping grids, you read the entire trend as a chain of retracements: where price respected the 0.618, where the golden pocket launched the next leg, and where a retracement failed and the trend flipped.

[b]HOW IT WORKS[/b]

- A swing engine based on confirmed pivots finds every move larger than "Min swing size". The threshold is set in ATR, so it adapts to any symbol and timeframe.
- "Merge minor pullbacks" ignores counter-moves smaller than the threshold, so each fib measures the full impulse, not its last leg.
- Every qualifying swing gets the full grid: 0, 0.236, 0.382, 0.5, 0.618, 0.786, 1. The ratio is printed at every level.
- Thin curves connect the grids into a channel, so the history stays readable.
- The golden pocket (0.618-0.786) is shaded on every fib.
- Extension targets -0.272 and -0.618 are projected beyond the extreme of the latest fib.
- Log-scale mode for macro swings, where linear and log fibs diverge a lot.
- Optional reaction dots mark bars that touched a level and closed back on the right side of it.
- Optional "Fade broken fibs": when price closes beyond the 1.0 level, the fib turns grey, stops extending and drops its targets.

https://www.tradingview.com/x/ttxd0BCS/

[b]HOW TO TRADE IT[/b]

1. Golden pocket pullback. In a trend, wait for price to enter the shaded 0.618-0.786 zone of the latest fib and get rejected. The "Golden pocket touch" alert does the waiting for you.
2. Extension targets. Once the retracement holds and price reclaims 0.236, the dashed -0.272 and -0.618 lines are the take-profit map for the next leg.
3. Broken fib. A close beyond 1.0 means the whole move was retraced. That is an early warning the trend may be flipping ("Full retracement break" alert).

https://www.tradingview.com/x/zJb8hKlu/

[b]REPAINTING[/b]

- A fib prints after its pivot confirms, i.e. "Swing length" bars after the extreme. It cannot appear earlier, there is no lookahead.
- While a swing keeps making new extremes, the latest fib follows them, the same way you re-drag a manual fib. Once the next swing confirms, the fib is fixed and never changes again.
- If you want zero intrabar movement, turn on "Bar-close mode" and the live chart will match bar replay exactly.

[b]ALERTS[/b]

Ten total: touches of 0.236, 0.382, 0.5, 0.618, 0.786, golden pocket entry, both extension targets, full retracement break, new swing fib.

https://www.tradingview.com/x/pa6C0Bt1/

[b]SETTINGS[/b]

Every input has a tooltip. The main ones: "Swing length" and "Min swing size" control how major the swings must be, "Fib history" sets how many fibs stay on the chart. Line widths, number sizes and all colors are adjustable.

[b]ORIGINALITY[/b]

Unlike single-fib auto tools, this script renders the complete history of swing retracements as one connected channel, with impulse-merging swing logic, extension targets, reaction dots and an explicit invalidation state. The swing engine and the chained rendering are written from scratch.

## Source Code

````pine
//@version=6
indicator("Fibonacci Retracement Channel [FEELS]", "Fib Channel [FEELS]", overlay = true, max_lines_count = 500, max_labels_count = 500, max_polylines_count = 100)

//--- inputs
grpF = "Swing fibs"
pivLen    = input.int(15, "Swing length", minval = 2, group = grpF, tooltip = "Bars to the left and right that confirm a swing point, a fib appears this many bars after the extreme")
minMove   = input.float(3.0, "Min swing size", minval = 0.0, step = 0.5, group = grpF, tooltip = "Ignore swings smaller than this many ATR(14), keeps fibs only on major moves")
mergeMinor = input.bool(true, "Merge minor pullbacks", group = grpF, tooltip = "Pullbacks smaller than Min swing size do not flip the swing, so each fib measures the full impulse instead of its last leg, like a deviation ZigZag. Turn off to flip on every confirmed pivot")
maxFibs   = input.int(10, "Fib history", minval = 2, maxval = 14, group = grpF, tooltip = "How many swing fibs stay on the chart, 14 is the TradingView drawing limit for the connecting curves")
fibW      = input.int(2, "Fib line width", minval = 1, maxval = 5, group = grpF, tooltip = "Fib levels are drawn thick, the flowing channel between them stays thin")
chanW     = input.int(1, "Channel line width", minval = 1, maxval = 4, group = grpF, tooltip = "Width of the thin curves that connect the fibs into a channel")
showGold  = input.bool(true, "Golden pocket fill", group = grpF, tooltip = "Shade the 0.618–0.786 zone of every fib — the classic golden pocket entry area")
lblMode   = input.string("All fibs", "Level numbers", options = ["All fibs", "Active fib", "Off"], group = grpF, tooltip = "Where to print 0.382 / 0.5 / 0.618 next to the levels")
showPrice = input.bool(false, "Numbers include price", group = grpF, tooltip = "Append the exact level price to each number")
lblSizeIn = input.string("Small", "Number size", options = ["Tiny", "Small", "Normal"], group = grpF, tooltip = "Size of the numbers on the active fib, older fibs print one size smaller. Bump it up for screenshots")
showDiag  = input.bool(false, "Swing diagonals", group = grpF, tooltip = "Dashed line over the move each fib measures, like the manual fib tool")

grpX = "Extras"
showExt   = input.bool(true, "Extension targets −0.272 / −0.618", group = grpX, tooltip = "Dashed target levels beyond the latest extreme of the active fib. If the retracement holds and the trend resumes, these are the classic continuation targets")
showMarks = input.bool(false, "Reaction dots", group = grpX, tooltip = "A dot prints where a bar touched the 0.382–0.786 level of the active fib and closed back on the right side of it — historical proof of the levels working. Dots print on bar close only")
useLog    = input.bool(false, "Logarithmic fib", group = grpX, tooltip = "Compute the levels in log scale. Use when your chart is on log scale or for large macro swings, where linear and log fibs differ a lot")
confirmedOnly = input.bool(false, "Bar-close mode", group = grpX, tooltip = "Process swings only when a bar closes, so the live chart behaves exactly like bar replay and history, at the cost of reacting one bar later. Off = react intrabar, the standard for swing tools")
invalidateFibs = input.bool(false, "Fade broken fibs", group = grpX, tooltip = "When price closes beyond the 1.0 level the retracement is fully unwound and the fib is no longer valid: it turns grey, stops extending and its extension targets are removed. Off = the fib stays live until the next one prints")

grpS = "Colors"
c0c1 = input.color(#787B86, "0 / 1", group = grpS)
c236 = input.color(#F23645, "0.236", group = grpS)
c382 = input.color(#FF9800, "0.382", group = grpS)
c500 = input.color(#4CAF50, "0.5", group = grpS)
c618 = input.color(#D4AF37, "0.618 (golden)", group = grpS)
c786 = input.color(#089981, "0.786", group = grpS)
cExt = input.color(#7E57C2, "Extensions", group = grpS)
cChan = input.color(color.new(#787B86, 30), "Channel curves", group = grpS)

lblSz = lblSizeIn == "Normal" ? size.normal : lblSizeIn == "Small" ? size.small : size.tiny
lblSzOld = lblSizeIn == "Normal" ? size.small : size.tiny

var array<float> COEF = array.from(0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0)
var array<color> CLRS = array.from(c0c1, c236, c382, c500, c618, c786, c0c1)

//--- storage
// one continuous structure: each fib is a horizontal plateau of 7 thick levels;
// between plateaus the channel is 7 smooth S-curves that start exactly on the
// previous fib's levels and end exactly on the next fib's levels (joined by
// vertical position, top to top, so they never cross). prev* = last frozen fib
// (its right edge still moves while the active one updates), act* = the live fib.
// extensions and reaction dots live on the active fib only.
var int   prevX = na
var array<float> prevL    = array.new<float>()
var array<line>  prevPlat = array.new<line>()
var array<label> prevLbls = array.new<label>()

var int   actX  = na
var int   actSB = na
var float actSP = na
var bool  actUp = false
var bool  actDead = false
var bool  prevDead = false
var array<float>    actL      = array.new<float>()
var array<line>     actPlat   = array.new<line>()
var array<label>    actLbls   = array.new<label>()
var array<polyline> actTrans  = array.new<polyline>()
var array<line>     actExtLn  = array.new<line>()
var array<label>    actExtLbl = array.new<label>()
var array<label>    actMarks  = array.new<label>()
var line     actDiag     = na
var linefill actPlatFill = na
var float actExt1 = na
var float actExt2 = na

var array<line>     histLines = array.new<line>()
var array<label>    histLbls  = array.new<label>()
var array<linefill> histFills = array.new<linefill>()
var array<polyline> histPolys = array.new<polyline>()
// per-batch object counts so history is deleted whole fibs at a time
var array<int> histSetLines = array.new<int>()
var array<int> histSetLbls  = array.new<int>()
var array<int> histSetFills = array.new<int>()
var array<int> histSetPolys = array.new<int>()

var float goldTop = na
var float goldBot = na

//--- helpers
// level price for coefficient c, in linear or log space
f_lvl(float sP_, float eP_, float c) =>
    useLog and sP_ > 0 and eP_ > 0 ? math.exp(math.log(eP_) - (math.log(eP_) - math.log(sP_)) * c) : eP_ - (eP_ - sP_) * c

f_levelsInto(float sP_, float eP_) =>
    array.clear(actL)
    for i = 0 to 6
        array.push(actL, f_lvl(sP_, eP_, array.get(COEF, i)))

f_touchLvl(float lvl) =>
    not na(lvl) and low <= lvl and high >= lvl

// draws the active fib: trims the previous plateau at the junction, runs smooth
// S-curves from its levels into the new fib's levels, then the new thick plateau
// plus optional extension targets. returns handles and extension level prices
f_drawActive(int sB_, float sP_, int eB_, float eP_) =>
    f_levelsInto(sP_, eP_)
    line dg = na
    linefill pf = na
    hasPrev = array.size(prevPlat) == 7
    if hasPrev
        J = prevX + math.max(1, math.floor((eB_ - prevX) * 0.5))
        // a faded (broken) fib keeps its frozen right edge
        if not prevDead
            for i = 0 to 6
                ln = array.get(prevPlat, i)
                line.set_extend(ln, extend.none)
                line.set_x2(ln, J)
            if array.size(prevLbls) > 0
                for i = 0 to array.size(prevLbls) - 1
                    label.set_x(array.get(prevLbls, i), J)
        // channel = eased curves joined by vertical position (0 sits at the top
        // of an up fib but the bottom of a down fib, so joining by coefficient
        // would cross all lines in one point)
        prevSorted = array.copy(prevL)
        array.sort(prevSorted, order.descending)
        newSorted = array.copy(actL)
        array.sort(newSorted, order.descending)
        for i = 0 to 6
            y1 = array.get(prevSorted, i)
            y2 = array.get(newSorted, i)
            pts = array.new<chart.point>()
            n = math.min(10, math.max(2, eB_ - J))
            for s = 0 to n
                t = s * 1.0 / n
                xx = J + math.round(t * (eB_ - J))
                yy = y1 + (y2 - y1) * (0.5 - 0.5 * math.cos(math.pi * t))
                array.push(pts, chart.point.from_index(xx, yy))
            array.push(actTrans, polyline.new(pts, line_color = cChan, line_width = chanW))
    if showDiag
        dg := line.new(sB_, sP_, eB_, eP_, color = color.new(c0c1, 45), width = 1, style = line.style_dashed)
    x1 = hasPrev ? eB_ : sB_
    for i = 0 to 6
        col = array.get(CLRS, i)
        lvl = array.get(actL, i)
        array.push(actPlat, line.new(x1, lvl, eB_ + 1, lvl, color = col, width = fibW, extend = extend.right))
        if lblMode != "Off"
            txt = str.tostring(array.get(COEF, i), "#.###") + (showPrice ? " · " + str.tostring(lvl, format.mintick) : "")
            array.push(actLbls, label.new(bar_index + 2, lvl, txt, style = label.style_label_left, color = color.new(col, 100), textcolor = col, size = lblSz))
    if showGold
        pf := linefill.new(array.get(actPlat, 4), array.get(actPlat, 5), color.new(c618, 82))
    // extension targets beyond the 0 extreme, active fib only
    float e1 = na
    float e2 = na
    if showExt
        e1 := f_lvl(sP_, eP_, -0.272)
        e2 := f_lvl(sP_, eP_, -0.618)
        wExt = math.max(1, fibW - 1)
        array.push(actExtLn, line.new(eB_, e1, eB_ + 1, e1, color = cExt, width = wExt, style = line.style_dashed, extend = extend.right))
        array.push(actExtLn, line.new(eB_, e2, eB_ + 1, e2, color = cExt, width = wExt, style = line.style_dashed, extend = extend.right))
        if lblMode != "Off"
            txt1 = "-0.272" + (showPrice ? " · " + str.tostring(e1, format.mintick) : "")
            txt2 = "-0.618" + (showPrice ? " · " + str.tostring(e2, format.mintick) : "")
            array.push(actExtLbl, label.new(bar_index + 2, e1, txt1, style = label.style_label_left, color = color.new(cExt, 100), textcolor = cExt, size = lblSz))
            array.push(actExtLbl, label.new(bar_index + 2, e2, txt2, style = label.style_label_left, color = color.new(cExt, 100), textcolor = cExt, size = lblSz))
    [dg, pf, e1, e2]

f_trimHist() =>
    keep = math.max(maxFibs - 2, 0)
    while array.size(histSetLines) > keep
        nL = array.shift(histSetLines)
        if nL > 0
            for i = 1 to nL
                line.delete(array.shift(histLines))
        nB = array.shift(histSetLbls)
        if nB > 0
            for i = 1 to nB
                label.delete(array.shift(histLbls))
        nF = array.shift(histSetFills)
        if nF > 0
            for i = 1 to nF
                linefill.delete(array.shift(histFills))
        nP = array.shift(histSetPolys)
        if nP > 0
            for i = 1 to nP
                polyline.delete(array.shift(histPolys))

//--- swing engine
atrRef = ta.atr(14)
ph = ta.pivothigh(high, pivLen, pivLen)
pl = ta.pivotlow(low, pivLen, pivLen)

var int   sB = na
var float sP = na
var int   eB = na
var float eP = na
var int   eDir = 0
var bool  drawn = false

evD = array.new_int()
evB = array.new_int()
evP = array.new_float()
if not na(ph)
    array.push(evD, 1)
    array.push(evB, bar_index - pivLen)
    array.push(evP, ph)
if not na(pl)
    array.push(evD, -1)
    array.push(evB, bar_index - pivLen)
    array.push(evP, pl)

newFibNow = false
if (not confirmedOnly or barstate.isconfirmed) and array.size(evD) > 0
    for k = 0 to array.size(evD) - 1
        dirE = array.get(evD, k)
        pb   = array.get(evB, k)
        pp   = array.get(evP, k)
        mode = 0
        if eDir == 0
            eB := pb
            eP := pp
            eDir := dirE
        else if dirE == eDir
            // same-side pivot: extend the current swing if it made a new extreme
            if (dirE == 1 and pp > eP) or (dirE == -1 and pp < eP)
                eB := pb
                eP := pp
                if not na(sB) and math.abs(eP - sP) >= minMove * atrRef
                    mode := drawn ? 2 : 1
        else
            // opposite pivot: flips the swing, unless it is a minor pullback and
            // merging is on — then the running swing simply continues
            if not mergeMinor or math.abs(pp - eP) >= minMove * atrRef
                sB := eB
                sP := eP
                eB := pb
                eP := pp
                eDir := dirE
                drawn := false
                if math.abs(eP - sP) >= minMove * atrRef
                    mode := 1
        // mode 2: the active fib's swing extended, redraw it in place
        if mode == 2
            if not na(actDiag)
                line.delete(actDiag)
                actDiag := na
            if not na(actPlatFill)
                linefill.delete(actPlatFill)
                actPlatFill := na
            if array.size(actPlat) > 0
                for i = 0 to array.size(actPlat) - 1
                    line.delete(array.get(actPlat, i))
                array.clear(actPlat)
            if array.size(actLbls) > 0
                for i = 0 to array.size(actLbls) - 1
                    label.delete(array.get(actLbls, i))
                array.clear(actLbls)
            if array.size(actTrans) > 0
                for i = 0 to array.size(actTrans) - 1
                    polyline.delete(array.get(actTrans, i))
                array.clear(actTrans)
            if array.size(actExtLn) > 0
                for i = 0 to array.size(actExtLn) - 1
                    line.delete(array.get(actExtLn, i))
                array.clear(actExtLn)
            if array.size(actExtLbl) > 0
                for i = 0 to array.size(actExtLbl) - 1
                    label.delete(array.get(actExtLbl, i))
                array.clear(actExtLbl)
            if array.size(actMarks) > 0
                for i = 0 to array.size(actMarks) - 1
                    label.delete(array.get(actMarks, i))
                array.clear(actMarks)
            [dg2, pf2, x1b, x2b] = f_drawActive(actSB, actSP, eB, eP)
            actX := eB
            actUp := eP > actSP
            actDead := false
            actDiag := dg2
            actPlatFill := pf2
            actExt1 := x1b
            actExt2 := x2b
            goldTop := math.max(array.get(actL, 4), array.get(actL, 5))
            goldBot := math.min(array.get(actL, 4), array.get(actL, 5))
        // mode 1: a new fib prints, the active one freezes into prev
        if mode == 1
            if array.size(actPlat) == 7
                nL0 = array.size(histLines)
                nB0 = array.size(histLbls)
                nF0 = array.size(histFills)
                nP0 = array.size(histPolys)
                if array.size(prevPlat) == 7
                    for i = 0 to 6
                        array.push(histLines, array.get(prevPlat, i))
                if array.size(prevLbls) > 0
                    for i = 0 to array.size(prevLbls) - 1
                        array.push(histLbls, array.get(prevLbls, i))
                if not na(actDiag)
                    array.push(histLines, actDiag)
                if not na(actPlatFill)
                    array.push(histFills, actPlatFill)
                if array.size(actTrans) > 0
                    for i = 0 to array.size(actTrans) - 1
                        array.push(histPolys, array.get(actTrans, i))
                // reaction dots die together with their fib
                if array.size(actMarks) > 0
                    for i = 0 to array.size(actMarks) - 1
                        array.push(histLbls, array.get(actMarks, i))
                actMarks := array.new<label>()
                // extensions live on the active fib only
                if array.size(actExtLn) > 0
                    for i = 0 to array.size(actExtLn) - 1
                        line.delete(array.get(actExtLn, i))
                    array.clear(actExtLn)
                if array.size(actExtLbl) > 0
                    for i = 0 to array.size(actExtLbl) - 1
                        label.delete(array.get(actExtLbl, i))
                    array.clear(actExtLbl)
                array.push(histSetLines, array.size(histLines) - nL0)
                array.push(histSetLbls, array.size(histLbls) - nB0)
                array.push(histSetFills, array.size(histFills) - nF0)
                array.push(histSetPolys, array.size(histPolys) - nP0)
                prevX := actX
                prevL := actL
                prevPlat := actPlat
                prevDead := actDead
                if lblMode == "All fibs"
                    if array.size(actLbls) > 0
                        for i = 0 to array.size(actLbls) - 1
                            label.set_size(array.get(actLbls, i), lblSzOld)
                    prevLbls := actLbls
                else
                    if array.size(actLbls) > 0
                        for i = 0 to array.size(actLbls) - 1
                            label.delete(array.get(actLbls, i))
                    prevLbls := array.new<label>()
                actL := array.new<float>()
                actPlat := array.new<line>()
                actLbls := array.new<label>()
                actTrans := array.new<polyline>()
                actDiag := na
                actPlatFill := na
            actSB := sB
            actSP := sP
            [dg1, pf1, x1a, x2a] = f_drawActive(sB, sP, eB, eP)
            actX := eB
            actUp := eP > sP
            actDead := false
            actDiag := dg1
            actPlatFill := pf1
            actExt1 := x1a
            actExt2 := x2a
            goldTop := math.max(array.get(actL, 4), array.get(actL, 5))
            goldBot := math.min(array.get(actL, 4), array.get(actL, 5))
            drawn := true
            newFibNow := true
            f_trimHist()

// keep the active fib's numbers pinned to the right edge
if drawn and not actDead and lblMode != "Off" and array.size(actLbls) == 7
    for i = 0 to 6
        label.set_x(array.get(actLbls, i), bar_index + 2)
if drawn and not actDead and array.size(actExtLbl) > 0
    for i = 0 to array.size(actExtLbl) - 1
        label.set_x(array.get(actExtLbl, i), bar_index + 2)

//--- reaction dots: bar touched a retrace level of the active fib and closed
// back on the right side of it (printed on bar close, never intrabar)
if showMarks and drawn and not actDead and array.size(actL) == 7 and barstate.isconfirmed
    for i = 2 to 5
        lvl = array.get(actL, i)
        col = array.get(CLRS, i)
        touched = actUp ? low <= lvl and close > lvl and low[1] > lvl : high >= lvl and close < lvl and high[1] < lvl
        if touched
            array.push(actMarks, label.new(bar_index, lvl, "", style = label.style_circle, color = color.new(col, 25), size = size.tiny))
    while array.size(actMarks) > 60
        label.delete(array.shift(actMarks))

//--- alerts
float l236 = na
float l382 = na
float l500 = na
float l618 = na
float l786 = na
float l100 = na
if drawn and not actDead and array.size(actL) == 7
    l236 := array.get(actL, 1)
    l382 := array.get(actL, 2)
    l500 := array.get(actL, 3)
    l618 := array.get(actL, 4)
    l786 := array.get(actL, 5)
    l100 := array.get(actL, 6)

t236 = f_touchLvl(l236)
t382 = f_touchLvl(l382)
t500 = f_touchLvl(l500)
t618 = f_touchLvl(l618)
t786 = f_touchLvl(l786)
tE1  = f_touchLvl(actExt1)
tE2  = f_touchLvl(actExt2)
inGold = not na(goldTop) and close <= goldTop and close >= goldBot
breachRaw = not na(l100) and (actUp ? close < l100 : close > l100)

// optional: fade the fib once its retracement is fully unwound
if invalidateFibs and drawn and not actDead and breachRaw and barstate.isconfirmed
    if array.size(actPlat) > 0
        for i = 0 to array.size(actPlat) - 1
            ln = array.get(actPlat, i)
            line.set_extend(ln, extend.none)
            line.set_x2(ln, bar_index)
            line.set_color(ln, color.new(c0c1, 60))
    if array.size(actLbls) > 0
        for i = 0 to array.size(actLbls) - 1
            label.set_textcolor(array.get(actLbls, i), color.new(c0c1, 45))
    if not na(actPlatFill)
        linefill.set_color(actPlatFill, color.new(c0c1, 92))
    if array.size(actExtLn) > 0
        for i = 0 to array.size(actExtLn) - 1
            line.delete(array.get(actExtLn, i))
        array.clear(actExtLn)
    if array.size(actExtLbl) > 0
        for i = 0 to array.size(actExtLbl) - 1
            label.delete(array.get(actExtLbl, i))
        array.clear(actExtLbl)
    actExt1 := na
    actExt2 := na
    actDead := true

alertcondition(t236 and not t236[1], "0.236 touch", "Fib Channel: price touched the 0.236 level of the latest fib")
alertcondition(t382 and not t382[1], "0.382 touch", "Fib Channel: price touched the 0.382 level of the latest fib")
alertcondition(t500 and not t500[1], "0.5 touch", "Fib Channel: price touched the 0.5 level of the latest fib")
alertcondition(t618 and not t618[1], "0.618 touch", "Fib Channel: price touched the 0.618 level of the latest fib")
alertcondition(t786 and not t786[1], "0.786 touch", "Fib Channel: price touched the 0.786 level of the latest fib")
alertcondition(inGold and not inGold[1], "Golden pocket touch", "Fib Channel: price entered the golden pocket (0.618–0.786) of the latest fib")
alertcondition(breachRaw and not breachRaw[1], "Full retracement break", "Fib Channel: price closed beyond the 1.0 level, the latest fib is invalidated")
alertcondition(tE1 and not tE1[1], "Extension -0.272 touch", "Fib Channel: price reached the -0.272 extension target")
alertcondition(tE2 and not tE2[1], "Extension -0.618 touch", "Fib Channel: price reached the -0.618 extension target")
alertcondition(newFibNow, "New swing fib", "Fib Channel: a new swing fib printed")
````
