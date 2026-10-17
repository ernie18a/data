# Trendline Detector (Filtered)

- url: https://www.tradingview.com/script/pOerl0Cf-Trendline-Detector-Filtered/
- type: indicator
- pine_id: PUB;7aaec254a2cc40ff85dda35ad3d97ce5
- version: 5.0

## Description

Trendline Detector (Filtered) automatically finds the best support and resistance trendlines from confirmed swing pivots, keeps past trendlines visible as history, and signals ATR-buffered breaks.

HOW IT WORKS
Support candidates connect pairs of confirmed pivot lows, resistance candidates pairs of pivot highs. Every candidate must pass four gates:
1. Recency - the newest anchor pivot must be within "Max Line Age" bars of the current bar. Stale lines are retired automatically instead of floating over the chart forever.
2. Length - anchors must be at least "Min Line Length" bars apart.
3. Validity - if any CLOSE inside the line's span pierces the line by more than the violation band (0.5 x ATR default), the candidate is rejected. Price that already sliced through a line means it was never real support/resistance.
4. Touches - at least 3 bars must touch the line within an ATR-scaled band. Two points define a line; three or more make a trendline.
The highest-touch candidate per side is drawn: support in green, resistance in red, extended right.

PAST TRENDLINES
When a live trendline dies (goes stale or is replaced by a new structure), it is frozen in place in gray instead of deleted, so historical market structure stays visible. "Max Past Trendlines" caps how many are kept.

BREAK SIGNALS
A BRK marker and alert fire only when a bar CLOSES beyond the projected live line by the break buffer (0.5 x ATR default) - wicks and grazes do not trigger.

FALSE-SIGNAL ELIMINATION
- Pivots confirm only after the right-bars lookback: no repainting.
- All detection runs on confirmed (closed) bars only.
- Every threshold is ATR-normalized, so the same settings work across symbols and timeframes.

USAGE
Works on any symbol and timeframe. Use the live lines as dynamic support/resistance; the break signals flag confirmed structure breaks. Alerts included for both support and resistance breaks.

## Source Code

````pine
//@version=6
indicator("Trendline Detector (Filtered)", overlay=true, max_lines_count=500, max_labels_count=500)

// ── Inputs ────────────────────────────────────────────────────────────────────
leftLen      = input.int(5,   "Left Bars",  minval=2, maxval=50, group="Pivots",
               tooltip="Bars to the left that must be lower (high) or higher (low) to confirm a pivot. Lower = catches smaller swings (more, shorter trendlines); higher = only major swings")
rightLen     = input.int(5,   "Right Bars", minval=2, maxval=50, group="Pivots",
               tooltip="Bars to the right required for confirmation — equals the detection lag. Lower = faster, smaller pivots")
maxPivots    = input.int(12,  "Max Pivots per Side", minval=4, maxval=20, group="Pivots",
               tooltip="More pivots = more candidate trendlines considered")

minTouches   = input.int(3,   "Min Touches", minval=2, maxval=10, group="Filters",
               tooltip="Bars whose high/low comes within the touch band of the line — 2 points make a line, 3+ make a trendline")
touchMult    = input.float(0.5, "Touch Band (x ATR)", minval=0.1, maxval=3.0, step=0.1, group="Filters")
violMult     = input.float(0.5, "Violation Band (x ATR)", minval=0.1, maxval=3.0, step=0.1, group="Filters",
               tooltip="A close beyond the line by more than this (within the line's span) invalidates the candidate — kills lines that price already sliced through")
minLenBars   = input.int(10,  "Min Line Length (bars)", minval=5, maxval=300, group="Filters",
               tooltip="Shortest trendline allowed. Lower = catches small/short trends; raise it to keep only longer trendlines")
maxAgeBars   = input.int(60,  "Max Line Age (bars)", minval=10, maxval=500, group="Filters",
               tooltip="Newest anchor pivot must be within this many bars of the current bar — stale lines are retired")

breakMult    = input.float(0.5, "Break Buffer (x ATR)", minval=0.1, maxval=3.0, step=0.1, group="Breaks",
               tooltip="A break signal needs a CLOSE beyond the projected line by this ATR multiple — wicks and grazes don't count")
showBreaks   = input.bool(false, "Show Break Signals", group="Breaks",
               tooltip="BRK labels off by default to reduce clutter — alerts still require this to be on")
armedLife    = input.int(300, "Watch Retired Lines (bars)", minval=0, maxval=1000, group="Breaks",
               tooltip="Only when past trendlines are shown: a retired (unbroken) trendline stays extended and break-monitored for this many bars. A break consumes the line: BRK fires and the line is truncated at the break bar. Set 0 to disable")
maxArmed     = input.int(20,  "Max Watched Retired Lines", minval=1, maxval=40, group="Breaks")

maxLines     = input.int(3,   "Trendlines per Side", minval=1, maxval=8, group="Display",
               tooltip="How many of the best support and resistance trendlines to show at once. Higher = also shows smaller concurrent trends; set to 1 for only the single best line on each side")
supColor     = input.color(color.new(color.green, 0), "Support Color",    group="Display")
resColor     = input.color(color.new(color.red, 0),   "Resistance Color", group="Display")
lineWid      = input.int(2,   "Line Width", minval=1, maxval=4, group="Display")
extRight     = input.bool(true, "Extend Right", group="Display")

keepHistory  = input.bool(false, "Show Past Trendlines", group="History",
               tooltip="When a trendline dies (stale, replaced, or broken), freeze it on the chart instead of deleting it — past trends stay visible as you scroll back. Off by default for a clean chart")
maxHistory   = input.int(200, "Max Past Trendlines", minval=2, maxval=400, group="History")
histColor    = input.color(color.new(color.gray, 45), "Past Trendline Color", group="History")

// ── Context ───────────────────────────────────────────────────────────────────
atr14 = ta.atr(14)

// ── Pivot storage: index 0 = newest ───────────────────────────────────────────
var float[] phP = array.new<float>(0)
var int[]   phB = array.new<int>(0)
var float[] plP = array.new<float>(0)
var int[]   plB = array.new<int>(0)

ph = ta.pivothigh(high, leftLen, rightLen)
pl = ta.pivotlow(low,   leftLen, rightLen)

if not na(ph)
    array.unshift(phP, ph)
    array.unshift(phB, bar_index - rightLen)
    if array.size(phP) > maxPivots
        array.pop(phP)
        array.pop(phB)

if not na(pl)
    array.unshift(plP, pl)
    array.unshift(plB, bar_index - rightLen)
    if array.size(plP) > maxPivots
        array.pop(plP)
        array.pop(plB)

// ── Live line state: up to maxLines per side ──────────────────────────────────
var line[] supLines = array.new<line>(0)
var int[]  supA1    = array.new<int>(0)   // newest anchor bar per line
var int[]  supA2    = array.new<int>(0)   // oldest anchor bar per line
var line[] resLines = array.new<line>(0)
var int[]  resA1    = array.new<int>(0)
var int[]  resA2    = array.new<int>(0)

// Retired-but-armed lines: still extended, still break-monitored.
// type: 1 = support, -1 = resistance. since: bar of retirement.
var line[] armedLines = array.new<line>(0)
var int[]  armedType  = array.new<int>(0)
var int[]  armedSince = array.new<int>(0)

// Fully frozen history (no longer monitored)
var line[] histLines = array.new<line>(0)

// Anchors of recently-broken lines — banned from immediate re-detection so a
// line that just broke can't be redrawn from the same pivots and keep extending
// past its break. (b1, b2) = newest, oldest anchor bar of the broken line.
var int[] supBanB1 = array.new<int>(0)
var int[] supBanB2 = array.new<int>(0)
var int[] resBanB1 = array.new<int>(0)
var int[] resBanB2 = array.new<int>(0)
banCap = 40

// Break flags for this bar
bool supBreakSig = false
bool resBreakSig = false

// ── Candidate search + lifecycle (confirmed bars only → no repainting) ────────
//
// Detection gates per pivot pair:
//   Gate 0 — Recency: newest anchor within maxAgeBars
//   Gate 1 — Length: anchors at least minLenBars apart
//   Gate 2 — Validity: no close pierces the line by violMult*ATR inside its span
//   Gate 3 — Touches: >= minTouches bars touch the line within touchMult*ATR
//   Gate 4 — Ban: the exact anchor pair of a just-broken line is skipped so it
//            cannot be redrawn and keep extending past its break
//
// The top maxLines candidates per side are kept live (candidates sharing an
// anchor pivot with an already-picked line are skipped as near-duplicates).
//
// Lifecycle: a BREAK CONSUMES THE LINE — live or armed, when a bar closes
// beyond the line by the buffer, BRK fires and the line is truncated at the
// break bar (it never extends past its break). With history on, retired
// unbroken lines stay armed (extended + monitored) until broken or timed out;
// on timeout they snap back to their anchor segment. With history off,
// retired lines are simply removed — only the current best lines show.
//
if barstate.isconfirmed
    tBand = touchMult * atr14
    vBand = violMult  * atr14
    bBuf  = breakMult * atr14

    // ---- 0. break check on LIVE lines first: a break consumes the line ----
    sIdx = array.size(supLines) - 1
    while sIdx >= 0
        sLn   = array.get(supLines, sIdx)
        sProj = line.get_price(sLn, bar_index)
        if close < sProj - bBuf
            supBreakSig := true
            line.set_xy2(sLn, bar_index, sProj)
            line.set_extend(sLn, extend.none)
            line.set_color(sLn, histColor)
            if keepHistory
                array.push(histLines, sLn)
            else
                line.delete(sLn)
            // ban this anchor pair so it can't immediately redraw past the break
            array.push(supBanB1, array.get(supA1, sIdx))
            array.push(supBanB2, array.get(supA2, sIdx))
            if array.size(supBanB1) > banCap
                array.shift(supBanB1)
                array.shift(supBanB2)
            array.remove(supLines, sIdx)
            array.remove(supA1, sIdx)
            array.remove(supA2, sIdx)
        sIdx -= 1
    rIdx = array.size(resLines) - 1
    while rIdx >= 0
        rLn   = array.get(resLines, rIdx)
        rProj = line.get_price(rLn, bar_index)
        if close > rProj + bBuf
            resBreakSig := true
            line.set_xy2(rLn, bar_index, rProj)
            line.set_extend(rLn, extend.none)
            line.set_color(rLn, histColor)
            if keepHistory
                array.push(histLines, rLn)
            else
                line.delete(rLn)
            // ban this anchor pair so it can't immediately redraw past the break
            array.push(resBanB1, array.get(resA1, rIdx))
            array.push(resBanB2, array.get(resA2, rIdx))
            if array.size(resBanB1) > banCap
                array.shift(resBanB1)
                array.shift(resBanB2)
            array.remove(resLines, rIdx)
            array.remove(resA1, rIdx)
            array.remove(resA2, rIdx)
        rIdx -= 1

    // ---- 1. collect ALL valid support candidates from pivot lows ----
    int[]   sScore = array.new<int>(0)
    float[] sP1 = array.new<float>(0)
    int[]   sB1 = array.new<int>(0)
    float[] sP2 = array.new<float>(0)
    int[]   sB2 = array.new<int>(0)

    nL = array.size(plP)
    if nL >= 2
        for i = 0 to nL - 2
            p1 = array.get(plP, i)
            b1 = array.get(plB, i)
            if bar_index - b1 > maxAgeBars
                continue
            for j = i + 1 to nL - 1
                p2 = array.get(plP, j)
                b2 = array.get(plB, j)
                if b1 - b2 < minLenBars
                    continue
                banned = false
                if array.size(supBanB1) > 0
                    for bi = 0 to array.size(supBanB1) - 1
                        if array.get(supBanB1, bi) == b1 and array.get(supBanB2, bi) == b2
                            banned := true
                            break
                if banned
                    continue
                slope = (p1 - p2) / float(b1 - b2)
                valid  = true
                touches = 0
                for k = 0 to b1 - b2
                    bk     = b1 - k
                    offset = bar_index - bk
                    proj   = p2 + slope * float(bk - b2)
                    if close[offset] < proj - vBand
                        valid := false
                        break
                    if math.abs(low[offset] - proj) <= tBand
                        touches += 1
                if valid and touches >= minTouches
                    array.push(sScore, touches)
                    array.push(sP1, p1)
                    array.push(sB1, b1)
                    array.push(sP2, p2)
                    array.push(sB2, b2)

    // ---- 2. collect ALL valid resistance candidates from pivot highs ----
    int[]   rScore = array.new<int>(0)
    float[] rP1 = array.new<float>(0)
    int[]   rB1 = array.new<int>(0)
    float[] rP2 = array.new<float>(0)
    int[]   rB2 = array.new<int>(0)

    nH = array.size(phP)
    if nH >= 2
        for i = 0 to nH - 2
            p1 = array.get(phP, i)
            b1 = array.get(phB, i)
            if bar_index - b1 > maxAgeBars
                continue
            for j = i + 1 to nH - 1
                p2 = array.get(phP, j)
                b2 = array.get(phB, j)
                if b1 - b2 < minLenBars
                    continue
                banned = false
                if array.size(resBanB1) > 0
                    for bi = 0 to array.size(resBanB1) - 1
                        if array.get(resBanB1, bi) == b1 and array.get(resBanB2, bi) == b2
                            banned := true
                            break
                if banned
                    continue
                slope = (p1 - p2) / float(b1 - b2)
                valid  = true
                touches = 0
                for k = 0 to b1 - b2
                    bk     = b1 - k
                    offset = bar_index - bk
                    proj   = p2 + slope * float(bk - b2)
                    if close[offset] > proj + vBand
                        valid := false
                        break
                    if math.abs(high[offset] - proj) <= tBand
                        touches += 1
                if valid and touches >= minTouches
                    array.push(rScore, touches)
                    array.push(rP1, p1)
                    array.push(rB1, b1)
                    array.push(rP2, p2)
                    array.push(rB2, b2)

    extMode = extRight ? extend.right : extend.none

    // ---- 3. pick the top maxLines support candidates (no shared anchors) ----
    int[] sPick = array.new<int>(0)
    if array.size(sScore) > 0
        for _t = 1 to maxLines
            best = -1
            bestSc = 0
            for c = 0 to array.size(sScore) - 1
                sc = array.get(sScore, c)
                if sc <= bestSc
                    continue
                dup = false
                if array.size(sPick) > 0
                    for q = 0 to array.size(sPick) - 1
                        pi = array.get(sPick, q)
                        if array.get(sB1, c) == array.get(sB1, pi) or array.get(sB2, c) == array.get(sB2, pi)
                            dup := true
                            break
                if not dup
                    best := c
                    bestSc := sc
            if best == -1
                break
            array.push(sPick, best)
            array.set(sScore, best, 0)

    // support lifecycle: update same-era lines, retire the rest, create new
    bool[] sUsed = array.new<bool>(array.size(sPick), false)
    sLix = array.size(supLines) - 1
    while sLix >= 0
        a1 = array.get(supA1, sLix)
        a2 = array.get(supA2, sLix)
        match = -1
        if array.size(sPick) > 0
            for q = 0 to array.size(sPick) - 1
                if array.get(sUsed, q)
                    continue
                pi = array.get(sPick, q)
                if array.get(sB1, pi) == a1 or array.get(sB2, pi) == a2
                    match := q
                    break
        sLn2 = array.get(supLines, sLix)
        if match >= 0
            pi = array.get(sPick, match)
            line.set_xy1(sLn2, array.get(sB2, pi), array.get(sP2, pi))
            line.set_xy2(sLn2, array.get(sB1, pi), array.get(sP1, pi))
            line.set_extend(sLn2, extMode)
            array.set(supA1, sLix, array.get(sB1, pi))
            array.set(supA2, sLix, array.get(sB2, pi))
            array.set(sUsed, match, true)
        else
            if keepHistory
                line.set_color(sLn2, histColor)
                // arm only if price hasn't already passed the line — otherwise the
                // break already happened and arming would fire an instant junk BRK
                projNow = line.get_price(sLn2, bar_index)
                if armedLife > 0 and close >= projNow - bBuf
                    array.push(armedLines, sLn2)
                    array.push(armedType, 1)
                    array.push(armedSince, bar_index)
                else
                    line.set_extend(sLn2, extend.none)
                    array.push(histLines, sLn2)
            else
                line.delete(sLn2)
            array.remove(supLines, sLix)
            array.remove(supA1, sLix)
            array.remove(supA2, sLix)
        sLix -= 1
    if array.size(sPick) > 0
        for q = 0 to array.size(sPick) - 1
            if array.get(sUsed, q)
                continue
            pi = array.get(sPick, q)
            newSup = line.new(array.get(sB2, pi), array.get(sP2, pi), array.get(sB1, pi), array.get(sP1, pi), color=supColor, width=lineWid, extend=extMode)
            array.push(supLines, newSup)
            array.push(supA1, array.get(sB1, pi))
            array.push(supA2, array.get(sB2, pi))

    // ---- 4. pick the top maxLines resistance candidates ----
    int[] rPick = array.new<int>(0)
    if array.size(rScore) > 0
        for _t = 1 to maxLines
            best = -1
            bestSc = 0
            for c = 0 to array.size(rScore) - 1
                sc = array.get(rScore, c)
                if sc <= bestSc
                    continue
                dup = false
                if array.size(rPick) > 0
                    for q = 0 to array.size(rPick) - 1
                        pi = array.get(rPick, q)
                        if array.get(rB1, c) == array.get(rB1, pi) or array.get(rB2, c) == array.get(rB2, pi)
                            dup := true
                            break
                if not dup
                    best := c
                    bestSc := sc
            if best == -1
                break
            array.push(rPick, best)
            array.set(rScore, best, 0)

    // resistance lifecycle
    bool[] rUsed = array.new<bool>(array.size(rPick), false)
    rLix = array.size(resLines) - 1
    while rLix >= 0
        a1 = array.get(resA1, rLix)
        a2 = array.get(resA2, rLix)
        match = -1
        if array.size(rPick) > 0
            for q = 0 to array.size(rPick) - 1
                if array.get(rUsed, q)
                    continue
                pi = array.get(rPick, q)
                if array.get(rB1, pi) == a1 or array.get(rB2, pi) == a2
                    match := q
                    break
        rLn2 = array.get(resLines, rLix)
        if match >= 0
            pi = array.get(rPick, match)
            line.set_xy1(rLn2, array.get(rB2, pi), array.get(rP2, pi))
            line.set_xy2(rLn2, array.get(rB1, pi), array.get(rP1, pi))
            line.set_extend(rLn2, extMode)
            array.set(resA1, rLix, array.get(rB1, pi))
            array.set(resA2, rLix, array.get(rB2, pi))
            array.set(rUsed, match, true)
        else
            if keepHistory
                line.set_color(rLn2, histColor)
                projNow = line.get_price(rLn2, bar_index)
                if armedLife > 0 and close <= projNow + bBuf
                    array.push(armedLines, rLn2)
                    array.push(armedType, -1)
                    array.push(armedSince, bar_index)
                else
                    line.set_extend(rLn2, extend.none)
                    array.push(histLines, rLn2)
            else
                line.delete(rLn2)
            array.remove(resLines, rLix)
            array.remove(resA1, rLix)
            array.remove(resA2, rLix)
        rLix -= 1
    if array.size(rPick) > 0
        for q = 0 to array.size(rPick) - 1
            if array.get(rUsed, q)
                continue
            pi = array.get(rPick, q)
            newRes = line.new(array.get(rB2, pi), array.get(rP2, pi), array.get(rB1, pi), array.get(rP1, pi), color=resColor, width=lineWid, extend=extMode)
            array.push(resLines, newRes)
            array.push(resA1, array.get(rB1, pi))
            array.push(resA2, array.get(rB2, pi))

    // ---- 5. monitor armed lines: break → BRK + truncate at break bar ----
    if array.size(armedLines) > 0
        aIdx = array.size(armedLines) - 1
        while aIdx >= 0
            aLn   = array.get(armedLines, aIdx)
            typ   = array.get(armedType, aIdx)
            since = array.get(armedSince, aIdx)
            aProj = line.get_price(aLn, bar_index)
            broken  = typ == 1 ? close < aProj - bBuf : close > aProj + bBuf
            expired = bar_index - since > armedLife
            if broken
                // the break consumes the line: stop it exactly at the break bar
                line.set_xy2(aLn, bar_index, aProj)
                line.set_extend(aLn, extend.none)
                array.push(histLines, aLn)
                array.remove(armedLines, aIdx)
                array.remove(armedType, aIdx)
                array.remove(armedSince, aIdx)
                if typ == 1
                    supBreakSig := true
                else
                    resBreakSig := true
            else if expired
                // unbroken timeout: snap back to the anchor segment, no smear
                line.set_extend(aLn, extend.none)
                array.push(histLines, aLn)
                array.remove(armedLines, aIdx)
                array.remove(armedType, aIdx)
                array.remove(armedSince, aIdx)
            aIdx -= 1

    // cap the armed pool: evict oldest, snapping back to its anchor segment
    while array.size(armedLines) > maxArmed
        l0 = array.shift(armedLines)
        array.remove(armedType, 0)
        array.remove(armedSince, 0)
        line.set_extend(l0, extend.none)
        array.push(histLines, l0)

    // cap full history
    while array.size(histLines) > maxHistory
        line.delete(array.shift(histLines))

// ── Signals ───────────────────────────────────────────────────────────────────
supBreak = showBreaks and supBreakSig
resBreak = showBreaks and resBreakSig

plotshape(supBreak, "Support Break", style=shape.labeldown, location=location.abovebar,
          color=color.new(color.red, 0), textcolor=color.white, text="BRK", size=size.small)
plotshape(resBreak, "Resistance Break", style=shape.labelup, location=location.belowbar,
          color=color.new(color.green, 0), textcolor=color.white, text="BRK", size=size.small)

// ── Alerts ────────────────────────────────────────────────────────────────────
alertcondition(supBreak, "Support Trendline Break",    "Close broke below a support trendline on {{ticker}} {{interval}}")
alertcondition(resBreak, "Resistance Trendline Break", "Close broke above a resistance trendline on {{ticker}} {{interval}}")
````
