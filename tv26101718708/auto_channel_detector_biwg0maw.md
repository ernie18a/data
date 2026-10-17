# Auto Channel Detector

- url: https://www.tradingview.com/script/BIWG0mAw-Auto-Channel-Detector/
- type: indicator
- pine_id: PUB;17b7679b14554da2b32e48c2ea73b48f
- version: 7.0

## Description

Auto Channel Detector finds the highest-quality price channel on the chart automatically and draws it as two parallel lines with a fill.

HOW IT WORKS
The script collects recent confirmed swing highs and swing lows (ta.pivothigh / ta.pivotlow). It then tests every pair of pivot highs against every pair of pivot lows as candidate channel walls and applies three quality gates:
1. Parallelism — the two walls must have nearly identical slopes (tolerance scaled by ATR over the channel span).
2. Minimum width — the channel must be at least 1.5 x ATR(14) wide at its midpoint.
3. Touch count — each wall must be touched by at least 3 bars (a touch = high/low within 0.5 x ATR of the projected line).
The candidate with the most total touches wins and is drawn. If no candidate passes all gates, nothing is drawn.

FALSE-TRIGGER ELIMINATION
- Pivots confirm only after the right-bars lookback, so the channel never repaints.
- Channel selection runs only on confirmed (closed) bars.
- All thresholds are ATR-normalized, so the same settings work across symbols and timeframes.

INPUTS
Pivot left/right bars, max pivots per side, minimum touches, touch band, parallelism tolerance, minimum width, minimum channel length, scan depth, and display options are all configurable.

USAGE
Works on any symbol and timeframe. Use the channel walls as dynamic support/resistance; a confirmed close outside the channel suggests a breakout.

## Source Code

````pine
//@version=6
indicator("Auto Channel Detector", overlay=true, max_lines_count=500, max_labels_count=500)

// ── Inputs ────────────────────────────────────────────────────────────────────
leftLen      = input.int(10,  "Left Bars",
               minval=2, maxval=50, group="Pivots",
               tooltip="Bars to the left that must be lower (high) or higher (low) to confirm a pivot")
rightLen     = input.int(10,  "Right Bars",
               minval=2, maxval=50, group="Pivots",
               tooltip="Bars to the right required for confirmation — equals the detection lag")
maxPivots    = input.int(8,   "Max Pivots per Side",
               minval=4, maxval=15, group="Pivots")

minTouches   = input.int(3,   "Min Touches per Wall",
               minval=2, maxval=10, group="Filters")
touchMult    = input.float(0.5, "Touch Band (x ATR)",
               minval=0.1, maxval=3.0, step=0.1, group="Filters",
               tooltip="A high/low counts as a touch if within this ATR band of the projected wall")
minWidthMult = input.float(1.5, "Min Width (x ATR)",
               minval=0.3, maxval=10.0, step=0.1, group="Filters",
               tooltip="The structure's widest end must be at least this many ATRs tall")
minLenBars   = input.int(20,  "Min Channel Length (bars)",
               minval=5, maxval=300, group="Filters")
maxAgeBars   = input.int(60,  "Max Channel Age (bars)",
               minval=10, maxval=500, group="Filters",
               tooltip="Newest anchor pivot must be within this many bars of the current bar — stale structures are dropped")
scanDepthMax = input.int(200, "Touch Scan Depth (bars)",
               minval=20, maxval=500, group="Filters")
detectLookback = input.int(5000, "Detection Lookback (bars)",
               minval=200, maxval=20000, group="Filters",
               tooltip="Only the most recent N bars are scanned for channels. Deep history beyond this is skipped so the script stays fast on long charts — keeps it within free-account execution limits. With past channels shown, history is limited to this window.")

shapeTolMult = input.float(1.0, "Shape Tolerance (x ATR)",
               minval=0.2, maxval=5.0, step=0.1, group="Classification",
               tooltip="Width change between the two ends below this = parallel channel; beyond it = wedge/triangle (converging) or broadening (diverging)")
flatTolMult  = input.float(0.75, "Flat Tolerance (x ATR)",
               minval=0.1, maxval=5.0, step=0.05, group="Classification",
               tooltip="A wall moving less than this over the structure's span counts as flat (for range / triangle classification)")
showType     = input.bool(true, "Show Type Label", group="Classification")

breakMult    = input.float(0.5, "Break Buffer (x ATR)",
               minval=0.1, maxval=3.0, step=0.1, group="Breaks",
               tooltip="A close beyond a wall by this ATR multiple breaks the channel: it is truncated at the break bar and never extends past it")
showBreaks   = input.bool(false, "Show Break Labels", group="Breaks",
               tooltip="Off by default to reduce clutter — alerts also require this to be on")

// Type filter — only the single current channel is ever drawn, so by default
// you see only the current channel's type. Uncheck a type to exclude it: the
// detector then falls through to the next-best channel of a still-enabled type.
enAsc        = input.bool(true, "Ascending Channel",            group="Channel Types")
enDesc       = input.bool(true, "Descending Channel",           group="Channel Types")
enRange      = input.bool(true, "Range",                        group="Channel Types")
enWedge      = input.bool(true, "Wedges (Rising / Falling)",    group="Channel Types")
enTri        = input.bool(true, "Triangles (Sym / Asc / Desc)", group="Channel Types")
enBroad      = input.bool(true, "Broadening",                   group="Channel Types")

ascColor     = input.color(color.new(color.green, 0),   "Ascending Channel",  group="Type Colors")
descColor    = input.color(color.new(color.red, 0),     "Descending Channel", group="Type Colors")
rangeColor   = input.color(color.new(color.blue, 0),    "Range",              group="Type Colors")
wedgeColor   = input.color(color.new(color.orange, 0),  "Wedges",             group="Type Colors")
triColor     = input.color(color.new(color.purple, 0),  "Triangles",          group="Type Colors")
broadColor   = input.color(color.new(color.fuchsia, 0), "Broadening",         group="Type Colors")

lineWid      = input.int(2,   "Line Width",   minval=1, maxval=4,    group="Display")
fillTransp   = input.int(88,  "Fill Transparency", minval=50, maxval=100, group="Display")
extRight     = input.bool(true, "Extend Right",                       group="Display")
showPivots   = input.bool(false, "Show Pivot Markers",                group="Display")

keepHistory  = input.bool(false, "Show Past Channels",                group="History",
               tooltip="Off by default so only the current channel shows. Turn on to freeze past structures (broken, stale, or replaced) on the chart so they stay visible as you scroll back")
maxHistory   = input.int(60,  "Max Past Channels", minval=1, maxval=240, group="History",
               tooltip="Frozen structures stay anchored at their historical bars, so past channels remain visible as you scroll back")
histColor    = input.color(color.new(color.gray, 35), "Past Channel Color", group="History")
histFill     = input.color(color.new(color.gray, 92), "Past Channel Fill",  group="History")

// ── ATR (volatility normalizer for all thresholds) ────────────────────────────
atr14 = ta.atr(14)

// ── Type classification helpers ───────────────────────────────────────────────
// classifyCode → integer type code for a candidate's geometry:
//   0 Range · 1 Ascending · 2 Descending · 3 Wedge · 4 Triangle · 5 Broadening
classifyCode(float uMove, float lMove, float dW, float shapeTol, float flatTol) =>
    int code = 0
    if math.abs(dW) <= shapeTol
        avgMove = (uMove + lMove) / 2.0
        code := math.abs(avgMove) < flatTol ? 0 : (avgMove > 0 ? 1 : 2)
    else if dW < 0
        uFlat = math.abs(uMove) < flatTol
        lFlat = math.abs(lMove) < flatTol
        if uFlat and not lFlat and lMove > 0
            code := 4
        else if lFlat and not uFlat and uMove < 0
            code := 4
        else if uMove > 0 and lMove > 0
            code := 3
        else if uMove < 0 and lMove < 0
            code := 3
        else
            code := 4
    else
        code := 5
    code

// codeEnabled → is this type code currently shown? (reads the Channel Types toggles)
codeEnabled(int code) =>
    code == 0 ? enRange : code == 1 ? enAsc : code == 2 ? enDesc : code == 3 ? enWedge : code == 4 ? enTri : enBroad

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

if showPivots
    if not na(ph)
        label.new(bar_index - rightLen, ph, "H",
                  style=label.style_label_down, size=size.tiny,
                  color=color.new(color.red, 70), textcolor=color.red)
    if not na(pl)
        label.new(bar_index - rightLen, pl, "L",
                  style=label.style_label_up, size=size.tiny,
                  color=color.new(color.green, 70), textcolor=color.green)

// ── Live structure state + history ────────────────────────────────────────────
var line     upperLine = na
var line     lowerLine = na
var linefill chanFill  = na
var label    typeLabel = na

var int curUB1 = -1
var int curUB2 = -1
var int curLB1 = -1
var int curLB2 = -1

var line[]     histUpper  = array.new<line>(0)
var line[]     histLower  = array.new<line>(0)
var linefill[] histFills  = array.new<linefill>(0)
var label[]    histLabels = array.new<label>(0)

// Break flags for this bar
bool breakUpSig = false
bool breakDnSig = false

// Anchors of the last broken structure — its exact candidate is banned from
// re-detection, otherwise the same pivots would resurrect a broken channel
var int brkUB1 = -1
var int brkUB2 = -1
var int brkLB1 = -1
var int brkLB2 = -1

// ── Structure detection: ONLY on confirmed (closed) bars → zero repainting ────
//
// For each pair of pivot highs (upper wall) and pivot lows (lower wall):
//   Gate 0 — Recency: newest anchor pivot within maxAgeBars
//   Gate 1 — Geometry: walls must not cross inside the span; the wide end
//            must be at least minWidth. Parallel is NOT required — converging
//            (wedges/triangles) and diverging (broadening) shapes are valid.
//   Gate 2 — Touch count: >= minTouches per wall within the span
// The winning structure is drawn, CLASSIFIED, and colored by type:
//   parallel    → Ascending / Descending Channel, or Range when flat
//   converging  → Rising/Falling Wedge, Symmetrical/Ascending/Descending Triangle
//   diverging   → Broadening
// Lifecycle: a BREAK CONSUMES THE CHANNEL — when a bar closes outside a wall
// by the break buffer, both walls are truncated at the break bar and the
// structure is frozen. It never extends past its break. A channel is LOCKED on
// detection and is never re-fitted, so it cannot widen to swallow a breakout.
//
// A new swing point this bar is the ONLY thing that can start a new channel.
// Between pivots only the cheap break check runs, keeping the script inside
// Pine's execution-time budget (free accounts included).
newPivot = not na(ph) or not na(pl)

// Only compute on the most recent detectLookback bars — deep history is skipped
// entirely (pivots are still collected cheaply above), bounding total cost on
// very long charts regardless of how many bars are loaded.
inWindow = bar_index >= last_bar_index - detectLookback

if barstate.isconfirmed and inWindow
    nH = array.size(phP)
    nL = array.size(plP)

    bBuf = breakMult * atr14

    // ---- 0. break check on the LIVE structure first ----
    if not na(upperLine)
        uProj = line.get_price(upperLine, bar_index)
        lProj = line.get_price(lowerLine, bar_index)
        brokeUp = close > uProj + bBuf
        brokeDn = close < lProj - bBuf
        if brokeUp or brokeDn
            breakUpSig := brokeUp
            breakDnSig := brokeDn
            line.set_xy2(upperLine, bar_index, uProj)
            line.set_xy2(lowerLine, bar_index, lProj)
            line.set_extend(upperLine, extend.none)
            line.set_extend(lowerLine, extend.none)
            line.set_color(upperLine, histColor)
            line.set_color(lowerLine, histColor)
            linefill.set_color(chanFill, histFill)
            if keepHistory
                array.push(histUpper, upperLine)
                array.push(histLower, lowerLine)
                array.push(histFills, chanFill)
                if not na(typeLabel)
                    label.set_textcolor(typeLabel, histColor)
                    array.push(histLabels, typeLabel)
            else
                linefill.delete(chanFill)
                line.delete(upperLine)
                line.delete(lowerLine)
                label.delete(typeLabel)
            brkUB1 := curUB1
            brkUB2 := curUB2
            brkLB1 := curLB1
            brkLB2 := curLB2
            upperLine := na
            lowerLine := na
            chanFill  := na
            typeLabel := na
            curUB1 := -1
            curUB2 := -1
            curLB1 := -1
            curLB2 := -1

    // A channel is LOCKED once detected: the search runs only when there is NO
    // live channel (na(upperLine)). A live channel is never re-fitted or stretched
    // — it ends only via a real break (handled above). This is what stops the
    // channel from quietly widening to "consume" a breakout/breakdown.
    if newPivot and na(upperLine) and nH >= 2 and nL >= 2
        tBand    = touchMult * atr14
        minW     = minWidthMult * atr14
        shapeTol = shapeTolMult * atr14
        flatTol  = flatTolMult * atr14

        bestScore = 0
        bUP1 = 0.0
        bUB1 = 0
        bUP2 = 0.0
        bUB2 = 0
        bLP1 = 0.0
        bLB1 = 0
        bLP2 = 0.0
        bLB2 = 0

        for i = 0 to nH - 2
            up1 = array.get(phP, i)
            ub1 = array.get(phB, i)   // more recent pivot high

            for j = i + 1 to nH - 1
                up2 = array.get(phP, j)
                ub2 = array.get(phB, j)  // older pivot high

                if ub1 - ub2 < minLenBars
                    continue

                uSlope = (up1 - up2) / float(ub1 - ub2)

                for m = 0 to nL - 2
                    lp1 = array.get(plP, m)
                    lb1 = array.get(plB, m)

                    for n = m + 1 to nL - 1
                        lp2 = array.get(plP, n)
                        lb2 = array.get(plB, n)

                        if lb1 - lb2 < minLenBars
                            continue

                        lSlope = (lp1 - lp2) / float(lb1 - lb2)

                        // Gate 0: Recency
                        newest = math.max(ub1, lb1)
                        if bar_index - newest > maxAgeBars
                            continue

                        // Banned: the exact structure that just broke
                        if ub1 == brkUB1 and ub2 == brkUB2 and lb1 == brkLB1 and lb2 == brkLB2
                            continue

                        // Gate 1: Geometry — no wall crossing inside the span,
                        // and the wide end must clear the minimum width
                        oldest = math.min(ub2, lb2)
                        wOld   = (up2 + uSlope * float(oldest - ub2)) - (lp2 + lSlope * float(oldest - lb2))
                        wNew   = (up2 + uSlope * float(newest - ub2)) - (lp2 + lSlope * float(newest - lb2))
                        if math.min(wOld, wNew) <= 0
                            continue
                        if math.max(wOld, wNew) < minW
                            continue

                        // Gate 1b: Type filter — skip candidates whose type is off,
                        // so disabling a type surfaces the next-best enabled channel
                        spanC = float(newest - oldest)
                        codeC = classifyCode(uSlope * spanC, lSlope * spanC, wNew - wOld, shapeTol, flatTol)
                        if not codeEnabled(codeC)
                            continue

                        // Gate 2: Touch count within the structure's own span
                        depth = math.min(newest - oldest, scanDepthMax)
                        uCnt  = 0
                        lCnt  = 0

                        for k = 0 to depth
                            bk     = newest - k
                            offset = bar_index - bk
                            uProj  = up2 + uSlope * float(bk - ub2)
                            lProj  = lp2 + lSlope * float(bk - lb2)
                            if math.abs(high[offset] - uProj) <= tBand
                                uCnt += 1
                            if math.abs(low[offset] - lProj) <= tBand
                                lCnt += 1

                        if uCnt >= minTouches and lCnt >= minTouches
                            score = uCnt + lCnt
                            if score > bestScore
                                bestScore := score
                                bUP1 := up1
                                bUB1 := ub1
                                bUP2 := up2
                                bUB2 := ub2
                                bLP1 := lp1
                                bLB1 := lb1
                                bLP2 := lp2
                                bLB2 := lb2

        extMode = extRight ? extend.right : extend.none

        // ── Classify the winning structure and pick its color ─────────────────
        typeText  = ""
        typeColor = histColor
        if bestScore > 0
            uS     = (bUP1 - bUP2) / float(bUB1 - bUB2)
            lS     = (bLP1 - bLP2) / float(bLB1 - bLB2)
            newest = math.max(bUB1, bLB1)
            oldest = math.min(bUB2, bLB2)
            spanF  = float(newest - oldest)
            wOld   = (bUP2 + uS * float(oldest - bUB2)) - (bLP2 + lS * float(oldest - bLB2))
            wNew   = (bUP2 + uS * float(newest - bUB2)) - (bLP2 + lS * float(newest - bLB2))
            dW     = wNew - wOld
            uMove  = uS * spanF
            lMove  = lS * spanF
            uFlat  = math.abs(uMove) < flatTol
            lFlat  = math.abs(lMove) < flatTol

            if math.abs(dW) <= shapeTol
                avgMove = (uMove + lMove) / 2.0
                if math.abs(avgMove) < flatTol
                    typeText  := "Range"
                    typeColor := rangeColor
                else if avgMove > 0
                    typeText  := "Ascending Channel"
                    typeColor := ascColor
                else
                    typeText  := "Descending Channel"
                    typeColor := descColor
            else if dW < 0
                if uFlat and not lFlat and lMove > 0
                    typeText  := "Ascending Triangle"
                    typeColor := triColor
                else if lFlat and not uFlat and uMove < 0
                    typeText  := "Descending Triangle"
                    typeColor := triColor
                else if uMove > 0 and lMove > 0
                    typeText  := "Rising Wedge"
                    typeColor := wedgeColor
                else if uMove < 0 and lMove < 0
                    typeText  := "Falling Wedge"
                    typeColor := wedgeColor
                else
                    typeText  := "Symmetrical Triangle"
                    typeColor := triColor
            else
                typeText  := "Broadening"
                typeColor := broadColor

        // cap history
        while array.size(histUpper) > maxHistory
            line.delete(array.shift(histUpper))
            line.delete(array.shift(histLower))
            linefill.delete(array.shift(histFills))
        while array.size(histLabels) > maxHistory
            label.delete(array.shift(histLabels))

        // ── Draw the freshly LOCKED structure (colored by type) ───────────────
        // upperLine is guaranteed na here (search only runs with no live channel),
        // so we always create — never stretch an existing channel.
        if bestScore > 0
            fillC = color.new(typeColor, fillTransp)
            upperLine := line.new(bUB2, bUP2, bUB1, bUP1, color=typeColor, width=lineWid, extend=extMode)
            lowerLine := line.new(bLB2, bLP2, bLB1, bLP1, color=typeColor, width=lineWid, extend=extMode)
            chanFill  := linefill.new(upperLine, lowerLine, fillC)

            if showType
                newest = math.max(bUB1, bLB1)
                uS     = (bUP1 - bUP2) / float(bUB1 - bUB2)
                lS     = (bLP1 - bLP2) / float(bLB1 - bLB2)
                midY   = ((bUP2 + uS * float(newest - bUB2)) + (bLP2 + lS * float(newest - bLB2))) / 2.0
                if na(typeLabel)
                    typeLabel := label.new(newest, midY, typeText,
                                           style=label.style_label_left, size=size.small,
                                           color=color.new(color.white, 100), textcolor=typeColor)
                else
                    label.set_xy(typeLabel, newest, midY)
                    label.set_text(typeLabel, typeText)
                    label.set_textcolor(typeLabel, typeColor)
            curUB1 := bUB1
            curUB2 := bUB2
            curLB1 := bLB1
            curLB2 := bLB2

// ── Break signals ──────────────────────────────────────────────────────────────
breakUp = showBreaks and breakUpSig
breakDn = showBreaks and breakDnSig

plotshape(breakUp, "Channel Break Up", style=shape.labelup, location=location.belowbar,
          color=color.new(color.green, 0), textcolor=color.white, text="CH BRK", size=size.small)
plotshape(breakDn, "Channel Break Down", style=shape.labeldown, location=location.abovebar,
          color=color.new(color.red, 0), textcolor=color.white, text="CH BRK", size=size.small)

// ── Alerts ────────────────────────────────────────────────────────────────────
alertcondition(breakUp, "Channel Break Up",   "Close broke above the channel on {{ticker}} {{interval}}")
alertcondition(breakDn, "Channel Break Down", "Close broke below the channel on {{ticker}} {{interval}}")
````
