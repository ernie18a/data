<!-- tradingview-pine-id: PUB;666c33f0e4394b2ea938c92d22a78c47 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Order Blocks Graded [ITA]

Source: https://www.tradingview.com/script/Q8SvycX7-Order-Blocks-Graded-ITA/

## Description

🟠 OVERVIEW

Order Blocks Graded marks order blocks and then does the part most scripts
skip: it tells you which ones are worth looking at.

A block only survives if the move that left it actually broke structure. What
survives is then graded A, B or C from two things that can be measured rather
than argued about - how far the impulse travelled relative to normal range,
and how much volume traded on the candle that produced it.

A-grade blocks are drawn solid. C-grade blocks are drawn faint. The grade sits
on the block itself, so a glance is enough.

🟠 CONCEPTS

* Order Block - The last opposite-colour candle before the move that broke
structure. The bullish version is the final down candle before price broke a
swing high, and the bearish version is its mirror.
* Break of Structure - A close beyond the last confirmed swing point. Without
one there is no block, because nothing was displaced.
* Impulse - The distance from the block to the close that broke structure,
measured in ATR multiples so it means the same thing on any symbol and any
timeframe.
* Grade - A when the impulse cleared the A threshold, B when it cleared the B
threshold, C otherwise. An origin candle on above-average volume lifts the
block one grade.
* Mitigation - Price trading back into the block. Mitigated blocks grey out,
or are removed entirely if you would rather only see what is still untouched.

🟠 FEATURES

🔹 Structure filter - a block is only kept when the move that left it broke a
swing point, so consolidation noise never produces one

🔹 A/B/C grading from impulse size in ATR terms and volume on the origin candle,
with the thresholds exposed as inputs

🔹 Opacity follows the grade, so the strongest blocks are the ones that stand
out without reading anything

🔹 Minimum block height, which stops a doji from leaving a flat line where a
zone should be

🔹 Staleness cutoff - a block price never returned to eventually stops being
useful and is dropped, instead of stretching across the whole chart

🔹 Mitigated blocks either grey out or disappear, your choice

🔹 Lowest grade to draw, so you can hide C blocks entirely and keep only the
strong ones

🔹 Alerts on both bullish and bearish blocks

🟠 HOW TO USE

Start with everything visible and see which grades your symbol actually
produces. Then raise the lowest grade to draw until the chart shows only what
you would act on.

Treat A blocks as the ones worth waiting for. They come from a move that
travelled several times normal range, which is what displacement is supposed to
mean in the first place.

Grey blocks are history, not signals. They show where blocks formed and how
they graded, which is the fastest way to see whether this symbol respects them
at all before you trade one.

Swing Lookback controls everything upstream. Lower values find more structure
and therefore more blocks, higher values find fewer and larger ones.

On a volatile symbol the blocks are wide and easy to read. On an index they can
be thin, so raise Minimum Block Height if the chart starts to look like lines
rather than zones.

🟠 CONCLUSION

Finding order blocks is easy and most scripts already do it. Knowing which of
them earned their place is the part that decides whether the chart helps you or
just fills up. That is what the grade is for.

---

## Source Code

````pine
//@version=6
// =============================================================================
// Order Blocks Graded [ITA]
//
// Most order block scripts draw every one they find. That is the problem: a
// chart covered in boxes tells you nothing, because the boxes are not equal.
//
// This one only keeps an order block if the move that left it actually broke
// structure, and then grades what survives. The grade comes from two things
// that can be measured rather than argued about: how far the impulse travelled
// relative to normal range, and how much volume it traded on.
//
// A-grade blocks are drawn solid. C-grade blocks are drawn faint. Blocks that
// price has already traded back into are removed, or greyed out if you prefer
// to keep the history.
//
// Nothing repaints - a block is only drawn once the break of structure it
// caused has closed.
// =============================================================================

indicator("Order Blocks Graded [ITA]", overlay = true,
     max_boxes_count = 500, max_labels_count = 500, max_lines_count = 100)

// ─── Inputs ──────────────────────────────────────────────────────────────────
grpStruct = "Structure"
pivotLen = input.int(5, "Swing Lookback", minval = 2, maxval = 50, group = grpStruct,
     tooltip = "Bars either side of a swing point. Higher = fewer, more significant swings.")
lookbackOB = input.int(20, "Search Back For The Block", minval = 3, maxval = 60, group = grpStruct,
     tooltip = "How far back from the break to look for the last opposite candle.")
minHeight = input.float(0.25, "Minimum Block Height %", minval = 0.0, maxval = 10, step = 0.05,
     group = grpStruct,
     tooltip = "Skip blocks thinner than this. Without it a doji leaves a flat line instead of a zone.")

grpGrade = "Grading"
useBody = input.bool(false, "Use Candle Body Instead Of Wick", group = grpGrade)
atrMultA = input.float(3.0, "A Grade: Impulse x ATR", minval = 1.0, maxval = 10, step = 0.25, group = grpGrade,
     tooltip = "How far the impulse must travel, in ATR multiples, to earn an A.")
atrMultB = input.float(1.8, "B Grade: Impulse x ATR", minval = 0.5, maxval = 10, step = 0.25, group = grpGrade)
volBoost = input.float(1.5, "Volume x Average For A Bonus", minval = 1.0, maxval = 5, step = 0.1, group = grpGrade,
     tooltip = "Above-average volume on the origin candle lifts the block one grade.")
minGrade = input.string("C", "Lowest Grade To Draw", options = ["A", "B", "C"], group = grpGrade)

grpShow = "Display"
maxBlocks = input.int(20, "Blocks To Keep Per Side", minval = 1, maxval = 50, group = grpShow)
extendBars = input.int(15, "Extend Right (bars)", minval = 0, maxval = 200, group = grpShow)
maxAge = input.int(60, "Drop Untouched Blocks After (bars)", minval = 20, maxval = 1000,
     group = grpShow,
     tooltip = "A block price never returned to eventually stops being useful. Without this a live block stretches across the whole chart.")
keepUsed = input.bool(true, "Keep Mitigated Blocks", group = grpShow,
     tooltip = "On leaves a used block greyed out so you can see where blocks formed and how they graded. Off shows only blocks price has not returned to yet, which on most charts is very few.")
showGrade = input.bool(true, "Show Grade Labels", group = grpShow)
showBos = input.bool(true, "Mark The Break Of Structure", group = grpShow)

grpCol = "Colors"
bullCol = input.color(#089981, "Bullish Block", group = grpCol)
bearCol = input.color(#F23645, "Bearish Block", group = grpCol)
usedCol = input.color(#787E8C, "Mitigated", group = grpCol)

// ─── Structure ───────────────────────────────────────────────────────────────
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float swingHigh = na
var float swingLow  = na
var int   swingHighBar = na
var int   swingLowBar  = na

if not na(ph)
    swingHigh := ph
    swingHighBar := bar_index - pivotLen
if not na(pl)
    swingLow := pl
    swingLowBar := bar_index - pivotLen

// A break only counts once, on the close that clears the level.
var bool  aboveHigh = false
var bool  belowLow  = false

bullBreak = not na(swingHigh) and close > swingHigh and not aboveHigh
bearBreak = not na(swingLow)  and close < swingLow  and not belowLow

if bullBreak
    aboveHigh := true
    belowLow  := false
if bearBreak
    belowLow  := true
    aboveHigh := false
if not na(ph)
    aboveHigh := false
if not na(pl)
    belowLow := false

// ─── Block bookkeeping ───────────────────────────────────────────────────────
var box[]   bullBox = array.new_box()
var float[] bullTop = array.new_float()
var float[] bullBot = array.new_float()
var label[] bullLbl = array.new_label()
var int[]   bullBar = array.new_int()

var box[]   bearBox = array.new_box()
var float[] bearTop = array.new_float()
var float[] bearBot = array.new_float()
var label[] bearLbl = array.new_label()
var int[]   bearBar = array.new_int()

// A zone thinner than this is a line, not a level worth trading.
tallEnough(float t, float b) =>
    b > 0 and (t - b) / b * 100 >= minHeight

atr = ta.atr(14)
avgVol = ta.sma(volume, 20)

gradeRank(string g) =>
    g == "A" ? 3 : g == "B" ? 2 : 1

minRank = gradeRank(minGrade)

// Grade an impulse: distance travelled in ATR terms, lifted one step if the
// origin candle traded on heavy volume.
gradeOf(float dist, float originVol) =>
    base = dist >= atr * atrMultA ? 3 : dist >= atr * atrMultB ? 2 : 1
    lifted = originVol >= avgVol * volBoost and base < 3 ? base + 1 : base
    lifted == 3 ? "A" : lifted == 2 ? "B" : "C"

alphaFor(string g) =>
    g == "A" ? 78 : g == "B" ? 86 : 92

// ─── Bullish blocks: the last down candle before an up-break ─────────────────
if bullBreak
    idx = -1
    for i = 1 to lookbackOB
        if close[i] < open[i] and idx == -1
            idx := i

    if idx > 0
        obHigh = useBody ? math.max(open[idx], close[idx]) : high[idx]
        obLow  = useBody ? math.min(open[idx], close[idx]) : low[idx]
        dist   = close - obLow
        g      = gradeOf(dist, volume[idx])

        if gradeRank(g) >= minRank and tallEnough(obHigh, obLow)
            b = box.new(bar_index - idx, obHigh, bar_index + extendBars, obLow,
                 border_color = bullCol, border_width = 1,
                 bgcolor = color.new(bullCol, alphaFor(g)))
            array.push(bullBox, b)
            array.push(bullTop, obHigh)
            array.push(bullBot, obLow)
            array.push(bullBar, bar_index)
            l = showGrade ? label.new(bar_index + extendBars, obHigh, g,
                 style = label.style_label_left, color = bullCol,
                 textcolor = color.white, size = size.tiny) : na
            array.push(bullLbl, l)

            if array.size(bullBox) > maxBlocks
                box.delete(array.shift(bullBox))
                array.shift(bullTop)
                array.shift(bullBot)
                array.shift(bullBar)
                old = array.shift(bullLbl)
                if not na(old)
                    label.delete(old)

// ─── Bearish blocks: the last up candle before a down-break ──────────────────
if bearBreak
    idx = -1
    for i = 1 to lookbackOB
        if close[i] > open[i] and idx == -1
            idx := i

    if idx > 0
        obHigh = useBody ? math.max(open[idx], close[idx]) : high[idx]
        obLow  = useBody ? math.min(open[idx], close[idx]) : low[idx]
        dist   = obHigh - close
        g      = gradeOf(dist, volume[idx])

        if gradeRank(g) >= minRank and tallEnough(obHigh, obLow)
            b = box.new(bar_index - idx, obHigh, bar_index + extendBars, obLow,
                 border_color = bearCol, border_width = 1,
                 bgcolor = color.new(bearCol, alphaFor(g)))
            array.push(bearBox, b)
            array.push(bearTop, obHigh)
            array.push(bearBot, obLow)
            array.push(bearBar, bar_index)
            l = showGrade ? label.new(bar_index + extendBars, obLow, g,
                 style = label.style_label_left, color = bearCol,
                 textcolor = color.white, size = size.tiny) : na
            array.push(bearLbl, l)

            if array.size(bearBox) > maxBlocks
                box.delete(array.shift(bearBox))
                array.shift(bearTop)
                array.shift(bearBot)
                array.shift(bearBar)
                old = array.shift(bearLbl)
                if not na(old)
                    label.delete(old)

// ─── Mitigation: price traded back into the block ────────────────────────────
if array.size(bullBox) > 0
    for i = array.size(bullBox) - 1 to 0
        t = array.get(bullTop, i)
        if not na(t)
            b = array.get(bullBox, i)
            age = bar_index - array.get(bullBar, i)
            stale = age > maxAge
            // Never mitigate on the bar the block was created. The impulse that
            // broke structure starts at the block, so the breaking bar's own low
            // is usually still inside it - checking here deletes the block the
            // moment it appears.
            if (age > 0 and low <= t) or stale
                if keepUsed and not stale
                    box.set_border_color(b, color.new(usedCol, 60))
                    box.set_bgcolor(b, color.new(usedCol, 93))
                    box.set_right(b, bar_index)
                    // Freeze the label with the box. Left running, it keeps
                    // drifting right every bar and ends up floating in space
                    // with no box under it.
                    lu = array.get(bullLbl, i)
                    if not na(lu)
                        label.set_x(lu, bar_index)
                        label.set_color(lu, color.new(usedCol, 45))
                    array.set(bullTop, i, na)
                else
                    box.delete(b)
                    l = array.get(bullLbl, i)
                    if not na(l)
                        label.delete(l)
                    array.remove(bullBox, i)
                    array.remove(bullTop, i)
                    array.remove(bullBot, i)
                    array.remove(bullBar, i)
                    array.remove(bullLbl, i)
            else
                box.set_right(b, bar_index + extendBars)
                l = array.get(bullLbl, i)
                if not na(l)
                    label.set_x(l, bar_index + extendBars)

if array.size(bearBox) > 0
    for i = array.size(bearBox) - 1 to 0
        bt = array.get(bearBot, i)
        if not na(bt)
            b = array.get(bearBox, i)
            age = bar_index - array.get(bearBar, i)
            stale = age > maxAge
            if (age > 0 and high >= bt) or stale
                if keepUsed and not stale
                    box.set_border_color(b, color.new(usedCol, 60))
                    box.set_bgcolor(b, color.new(usedCol, 93))
                    box.set_right(b, bar_index)
                    lu = array.get(bearLbl, i)
                    if not na(lu)
                        label.set_x(lu, bar_index)
                        label.set_color(lu, color.new(usedCol, 45))
                    array.set(bearBot, i, na)
                else
                    box.delete(b)
                    l = array.get(bearLbl, i)
                    if not na(l)
                        label.delete(l)
                    array.remove(bearBox, i)
                    array.remove(bearTop, i)
                    array.remove(bearBot, i)
                    array.remove(bearBar, i)
                    array.remove(bearLbl, i)
            else
                box.set_right(b, bar_index + extendBars)
                l = array.get(bearLbl, i)
                if not na(l)
                    label.set_x(l, bar_index + extendBars)

// ─── Break of structure markers ──────────────────────────────────────────────
plotshape(showBos and bullBreak, title = "Bullish BOS", style = shape.triangleup,
     location = location.belowbar, color = bullCol, size = size.tiny)
plotshape(showBos and bearBreak, title = "Bearish BOS", style = shape.triangledown,
     location = location.abovebar, color = bearCol, size = size.tiny)

// ─── Alerts ──────────────────────────────────────────────────────────────────
alertcondition(bullBreak, "Bullish Order Block",
     "Structure broke upward and a bullish order block was marked")
alertcondition(bearBreak, "Bearish Order Block",
     "Structure broke downward and a bearish order block was marked")
````
