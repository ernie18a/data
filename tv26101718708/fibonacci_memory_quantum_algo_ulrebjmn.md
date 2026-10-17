# Fibonacci Memory [Quantum Algo]

- url: https://www.tradingview.com/script/UlrEbJMN-Fibonacci-Memory-Quantum-Algo/
- type: indicator
- pine_id: PUB;5988e9d2f8f348f8a55651bcbdd0d565
- version: 1.0

## Description

Fibonacci Memory [Quantum Algo]

═══════════════════════════════════════════════

🔶 OVERVIEW

Fibonacci Memory is an automatic Fibonacci retracement and extension tool with memory. It detects the live impulse on your chart, draws the full retracement ladder with the golden pocket shaded and the extension targets projected forward — and then does what no Fibonacci indicator does: it remembers. Every time price touches a level, the tool records whether price respected it or cut straight through, and the levels on your chart glow according to their historical respect rate on this exact symbol and timeframe.

The result is a Fibonacci map that tells you which ratios THIS market honors. On one pair the 0.618 may be a wall and the 0.5 a formality; on another it is the reverse. Fibonacci Memory shows you, with touch counts, instead of leaving you to assume every ratio is equally sacred.

═══════════════════════════════════════════════

🔶 WHAT IS FIBONACCI RETRACEMENT?

Fibonacci retracement measures how far a pullback has traveled against the impulse that preceded it, expressed as ratios derived from the Fibonacci sequence — 0.236, 0.382, 0.5, 0.618, 0.786. Traders watch these levels as candidate zones where a pullback may end and the impulse may resume. Fibonacci extension projects the same ratios beyond the impulse — 1.272, 1.618, 2.0 — as candidate targets for the next leg. The golden pocket, between 0.618 and 0.65, is the retracement zone most widely watched in contemporary trading.

═══════════════════════════════════════════════

🔶 WHAT IS LEVEL MEMORY?

Most Fibonacci tools draw the same ratios on every chart with the same confidence. Level Memory measures each ratio instead. A touch is recorded when price comes within a small tolerance of a level. The touch is then watched for a reaction window: if price moves away by at least the reaction distance, the level was RESPECTED; if not, it was ignored. Respect rates are shrunk toward neutral at small samples so a lucky early touch cannot inflate a level's standing — and they are shown on the level labels, in the panel, and as the glow of the lines themselves.

═══════════════════════════════════════════════

🔶 WHY IS THIS ORIGINAL?

1. Levels that glow by evidence. Line brightness and thickness are driven by each ratio's respect rate on the current symbol — the 0.618 is drawn bold where it has earned it and faint where it has not.

2. Per-ratio statistics panel. Every retracement and extension ratio carries a meter, a shrunk respect rate and a touch count, with a footer naming the ratio this symbol honors most.

3. Reaction markers. Each respected touch prints a small marker at the level — a visible record of the ladder doing its job, left on the chart.

4. A live impulse engine. The ladder follows the current swing automatically and extends the impulse end as the move continues, so the levels are always drawn from the structure that matters now; the impulse itself is drawn and sized in Average True Range units.

5. Golden pocket, shaded and alerted. The 0.618–0.65 zone is rendered as a band and carries its own alert.

═══════════════════════════════════════════════

🔶 HOW IT WORKS

— Pivot structure identifies the most recent swing high and low; the pair with the required minimum size defines the impulse and its direction.
— Retracement and extension levels are computed from the impulse and drawn with the golden pocket shaded.
— On each confirmed bar, a level within the touch tolerance registers a touch; the touch is resolved as respected or ignored within the reaction window.
— Each ratio's respect rate is computed with shrinkage and drives line glow, label text, the panel and the markers.

Detection and statistics run on confirmed bars. Levels redraw when a new impulse forms — this is the tool following structure, not repainting signals.

═══════════════════════════════════════════════

🔶 HOW TO USE IT

— Trade the bold lines: a level drawn bright and thick has a track record on this symbol; a faint level is decorative until proven otherwise.
— Watch the pocket with context: if the panel shows the 0.618 and 0.65 well respected here, a golden-pocket touch deserves attention; if they are faint, do not assume the textbook.
— Use extensions as target candidates weighted the same way — a 1.618 with a strong respect rate is a credible target.
— Compare symbols: load the tool on several pairs and notice how differently their panels read; that is the point.
— Works on all markets and timeframes; raise Swing Length on higher timeframes to follow larger structure.

═══════════════════════════════════════════════

🔶 SETTINGS

— Impulse: swing length, minimum leg size.
— Levels: extensions toggle, golden pocket shading, right extension.
— Level Memory: touch tolerance, reaction distance, reaction window, reaction markers, minimum touches to grade.
— Visuals: impulse, pocket, extension and neutral colors; panel toggle.

═══════════════════════════════════════════════

🔶 ALERTS

— New Impulse — the ladder redrew on a new swing.
— Level Reaction Up / Down — price respected a level.
— Golden Pocket Touched — price entered the 0.618–0.65 zone.

═══════════════════════════════════════════════

🔶 FAQ

Q: Does it repaint?
A: Touch and respect statistics are computed on confirmed bars and never change. The ladder itself redraws when a new impulse is detected, because it is drawn from the current swing — that is the tool following market structure, not a signal being altered.

Q: Why does the same ratio look different on different symbols?
A: Because the glow is evidence, not decoration. Each symbol's respect rates are measured on its own history, so a level is bold where it has worked and faint where it has not.

Q: What counts as "respected"?
A: Price came within the touch tolerance of the level and then moved away by at least the reaction distance within the reaction window. Both thresholds are in Average True Range units and are adjustable.

Q: Why is the golden pocket 0.618 to 0.65?
A: It is the zone most widely used in contemporary practice, bounded by the golden ratio retracement and the nearby 0.65. Both levels are tracked separately in the panel so you can see whether this market distinguishes them.

Q: What do the percentages mean?
A: The share of past touches of that level that were respected, shrunk toward fifty percent at small samples. They describe this chart's history; they are not predictions.

═══════════════════════════════════════════════

🔶 CREDITS

The Fibonacci sequence is attributed to Leonardo of Pisa (1202). Fibonacci retracement and extension come from classical technical analysis, popularized by Ralph Nelson Elliott and later by Robert Fischer; the golden pocket is from contemporary trading practice. Pivot structure detection is standard charting technique. The Wilson score interval is by Edwin B. Wilson (1927). The impulse engine, level-respect statistics, glow rendering, reaction markers and all code in this script are original work — no third-party or open-source script code was reused.

═══════════════════════════════════════════════

🔶 LIMITATIONS

— Respect statistics need touches to accumulate; on a fresh chart the ladder starts ungraded and brightens as evidence arrives.
— The impulse engine follows pivot structure; in choppy conditions swings are smaller and the ladder redraws more often.
— Statistics describe the current chart's history only; past frequencies never guarantee future outcomes.

═══════════════════════════════════════════════

🔶 DISCLAIMER

This indicator is a research and charting tool provided for educational purposes. It is not financial advice, and nothing it displays is a recommendation to buy or sell any asset. Trading involves substantial risk of loss. Always do your own analysis and manage risk responsibly.

## Source Code

````pine
//@version=6
indicator("Fibonacci Memory [Quantum Algo]", overlay = true, max_lines_count = 120, max_labels_count = 120, max_boxes_count = 40, max_bars_back = 500)

// ════════════════════════════════════════════════════════════════
//  FIBONACCI MEMORY
//  Automatic Fibonacci retracement and extension on the live
//  impulse — with memory. The engine detects the current swing,
//  draws the retracement ladder with the golden pocket shaded and
//  the extension targets projected forward, then does what no
//  fib tool does: it scores every level by how often THIS symbol
//  has actually respected it. Levels glow by their historical hit
//  rate, so you see at a glance which ratios this market honors
//  and which it ignores.
//
//  Concept credits: the Fibonacci sequence (Leonardo of Pisa,
//  1202) and its ratios · Fibonacci retracement and extension
//  from classical technical analysis, popularized by Ralph
//  Nelson Elliott and later by Robert Fischer · the "golden
//  pocket" (0.618–0.65) from contemporary trading practice ·
//  pivot structure from standard charting technique · the Wilson
//  score interval (Edwin B. Wilson, 1927). The impulse engine,
//  level-respect statistics, glow rendering, reaction markers
//  and all code are original work — no third-party or
//  open-source script code was reused.
// ════════════════════════════════════════════════════════════════

// ─── INPUTS ─────────────────────────────────────────────────────
grpI = "Impulse"
pivLen = input.int(12, "Swing Length", minval = 4, maxval = 50, group = grpI, tooltip = "Pivot strength used to detect the impulse legs. Larger values follow bigger swings.")
minLeg = input.float(2.0, "Minimum Leg Size (Average True Range)", step = 0.5, minval = 0.5, group = grpI)

grpL = "Levels"
showExt   = input.bool(true, "Extension Targets", group = grpL)
showPocket = input.bool(true, "Shade Golden Pocket", group = grpL)
extendRight = input.int(25, "Extend Levels Right (Bars)", minval = 5, maxval = 80, group = grpL)

grpS = "Level Memory"
touchTol = input.float(0.15, "Touch Tolerance (Average True Range)", step = 0.05, minval = 0.05, group = grpS, tooltip = "A level counts as touched when price comes within this distance of it. It counts as RESPECTED when price then moves away by at least the reaction distance within the reaction window.")
reactAtr = input.float(1.0, "Reaction Distance (Average True Range)", step = 0.25, minval = 0.25, group = grpS)
reactWin = input.int(8, "Reaction Window (Bars)", minval = 2, maxval = 30, group = grpS)
showReact = input.bool(true, "Mark Reactions", group = grpS)
minN = input.int(6, "Minimum Touches To Grade", minval = 2, group = grpS)

grpV = "Visuals"
bullCol = input.color(#00897b, "Bullish Impulse", group = grpV)
bearCol = input.color(#e4002b, "Bearish Impulse", group = grpV)
goldCol = input.color(#c77800, "Golden Pocket", group = grpV)
extCol  = input.color(#5e35b1, "Extensions", group = grpV)
silvCol = input.color(#37474f, "Neutral", group = grpV)
showPanel = input.bool(true, "Level Memory Panel", group = grpV)

// ─── SHARED ─────────────────────────────────────────────────────
atrV = ta.atr(14)
f_rep(string s, int n) =>
    out = ""
    if n > 0
        for i = 1 to n
            out += s
    out
fw(float p) => str.tostring(p * 100, "#") + "%"

// ─── IMPULSE ENGINE ────────────────────────────────────────────
ph = ta.pivothigh(high, pivLen, pivLen)
pl = ta.pivotlow(low, pivLen, pivLen)
var float swHi = na
var int   swHiBar = na
var float swLo = na
var int   swLoBar = na
var int   legDir = 0        // 1 up-impulse (lo → hi) · -1 down-impulse (hi → lo)
var float legA = na         // impulse origin
var float legB = na         // impulse end
var int   legABar = na
var int   legBBar = na
bool newLeg = false
if not na(ph)
    swHi := ph
    swHiBar := bar_index - pivLen
if not na(pl)
    swLo := pl
    swLoBar := bar_index - pivLen
if barstate.isconfirmed and not na(swHi) and not na(swLo)
    if swLoBar < swHiBar and (swHi - swLo) >= atrV * minLeg and (legDir != 1 or legA != swLo or legB != swHi)
        legDir := 1
        legA := swLo
        legB := swHi
        legABar := swLoBar
        legBBar := swHiBar
        newLeg := true
    else if swHiBar < swLoBar and (swHi - swLo) >= atrV * minLeg and (legDir != -1 or legA != swHi or legB != swLo)
        legDir := -1
        legA := swHi
        legB := swLo
        legABar := swHiBar
        legBBar := swLoBar
        newLeg := true
// live extension of the impulse end while the move continues
if legDir == 1 and high > legB and bar_index > legBBar
    legB := high
    legBBar := bar_index
if legDir == -1 and low < legB and bar_index > legBBar
    legB := low
    legBBar := bar_index
rng = legDir != 0 ? math.abs(legB - legA) : na
f_lvl(float r) => legDir == 1 ? legB - rng * r : legB + rng * r

// level set: retracements + extensions
ratios = array.from(0.0, 0.236, 0.382, 0.5, 0.618, 0.65, 0.786, 1.0, 1.272, 1.618, 2.0)
names  = array.from("0", "0.236", "0.382", "0.5", "0.618", "0.65", "0.786", "1", "1.272", "1.618", "2")
NL = ratios.size()

// ─── LEVEL MEMORY · touches and respects per ratio ─────────────
var array<int> touchN = array.new<int>(NL, 0)
var array<int> respN  = array.new<int>(NL, 0)
var array<int> pendLvl = array.new<int>()
var array<int> pendBar = array.new<int>()
var array<float> pendPx = array.new<float>()
var array<int> pendSide = array.new<int>()   // +1 price came from above (support test) · -1 from below
bool reactUp = false
bool reactDn = false
float reactPx = na
if barstate.isconfirmed and legDir != 0 and not na(rng)
    // register new touches (one per level per bar, skip the impulse endpoints themselves)
    for i = 1 to NL - 1
        if i == 7
            continue
        if not showExt and i > 7
            continue
        lv = f_lvl(ratios.get(i))
        if low <= lv + atrV * touchTol and high >= lv - atrV * touchTol
            bool already = false
            if pendLvl.size() > 0
                for q = 0 to pendLvl.size() - 1
                    if pendLvl.get(q) == i and bar_index - pendBar.get(q) < reactWin
                        already := true
            if not already
                touchN.set(i, touchN.get(i) + 1)
                pendLvl.push(i)
                pendBar.push(bar_index)
                pendPx.push(lv)
                pendSide.push(close >= lv ? 1 : -1)
    // resolve pending touches
    if pendLvl.size() > 0
        for q = pendLvl.size() - 1 to 0
            age = bar_index - pendBar.get(q)
            lv = pendPx.get(q)
            sd = pendSide.get(q)
            bool resolved = false
            if sd == 1 and high >= lv + atrV * reactAtr
                respN.set(pendLvl.get(q), respN.get(pendLvl.get(q)) + 1)
                reactUp := true
                reactPx := lv
                resolved := true
            else if sd == -1 and low <= lv - atrV * reactAtr
                respN.set(pendLvl.get(q), respN.get(pendLvl.get(q)) + 1)
                reactDn := true
                reactPx := lv
                resolved := true
            else if age >= reactWin
                resolved := true
            if resolved
                pendLvl.remove(q)
                pendBar.remove(q)
                pendPx.remove(q)
                pendSide.remove(q)

f_rate(int i) =>
    n = touchN.get(i)
    w = respN.get(i)
    n > 0 ? (w + 2.0) / (n + 4.0) : na

plotshape(showReact and reactUp ? reactPx : na, "Reaction Up", shape.triangleup, location.absolute, color.new(bullCol, 0), size = size.tiny)
plotshape(showReact and reactDn ? reactPx : na, "Reaction Down", shape.triangledown, location.absolute, color.new(bearCol, 0), size = size.tiny)

// ─── DRAWING · ladder, pocket, extensions, impulse ─────────────
var array<line>  L = array.new<line>()
var array<label> T = array.new<label>()
var box pocket = na
var line impLn = na
var label impLb = na
while L.size() > 0
    line.delete(L.shift())
while T.size() > 0
    label.delete(T.shift())
if not na(pocket)
    box.delete(pocket)
if not na(impLn)
    line.delete(impLn)
if not na(impLb)
    label.delete(impLb)
if barstate.islast and legDir != 0 and not na(rng)
    x1 = math.max(legABar, bar_index - 480)
    x2 = bar_index + extendRight
    dirCol = legDir == 1 ? bullCol : bearCol
    impLn := line.new(legABar, legA, legBBar, legB, color = color.new(dirCol, 20), width = 2, style = line.style_dashed)
    impLb := label.new(legBBar, legB, (legDir == 1 ? "▲ " : "▼ ") + str.tostring(rng / atrV, "#.#") + " ATR impulse", style = legDir == 1 ? label.style_label_down : label.style_label_up, color = color.new(color.black, 100), textcolor = color.new(dirCol, 0), size = size.small)
    if showPocket
        p1 = f_lvl(0.618)
        p2 = f_lvl(0.65)
        pocket := box.new(x1, math.max(p1, p2), x2, math.min(p1, p2), border_color = na, bgcolor = color.new(goldCol, 70))
    for i = 0 to NL - 1
        isExt = i > 7
        if isExt and not showExt
            continue
        lv = f_lvl(ratios.get(i))
        r = f_rate(i)
        graded = touchN.get(i) >= minN
        // glow: respected levels brighter and thicker, ignored levels faint
        baseC = isExt ? extCol : (i == 4 or i == 5) ? goldCol : i == 0 or i == 7 ? dirCol : silvCol
        trans = not graded ? 45 : int(70 - math.min(math.max(nz(r, 0.5), 0.0), 1.0) * 60)
        wd = graded and nz(r) >= 0.65 ? 3 : graded and nz(r) >= 0.5 ? 2 : 1
        L.push(line.new(x1, lv, x2, lv, color = color.new(baseC, trans), width = wd, style = isExt ? line.style_dotted : line.style_solid))
        tag = names.get(i) + "  " + str.tostring(lv, format.mintick) + (graded ? "  ·  " + fw(r) + " ×" + str.tostring(touchN.get(i)) : touchN.get(i) > 0 ? "  ·  ×" + str.tostring(touchN.get(i)) : "")
        T.push(label.new(x2, lv, tag, style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.new(baseC, graded ? int(trans * 0.5) : 30), size = size.small, tooltip = (isExt ? "Extension " : "Retracement ") + names.get(i) + "\nTouched " + str.tostring(touchN.get(i)) + " · Respected " + str.tostring(respN.get(i)) + (graded ? "\nRespect rate (shrunk) " + fw(r) : "\nCollecting touches (" + str.tostring(touchN.get(i)) + "/" + str.tostring(minN) + ")") + "\nRespected = price moved ≥" + str.tostring(reactAtr, "#.##") + " ATR away within " + str.tostring(reactWin) + " bars of touching"))

// ─── LEVEL MEMORY PANEL ────────────────────────────────────────
var table pn = table.new(position.top_right, 3, 11, bgcolor = color.new(#171207, 4), frame_color = color.new(#c77800, 20), frame_width = 1, border_color = color.new(#c77800, 85), border_width = 1)
if showPanel and barstate.islast
    table.cell(pn, 0, 0, "◈ FIBONACCI MEMORY · " + syminfo.ticker, bgcolor = color.new(#ef9a13, 0), text_color = #1a1207, text_size = size.small, text_halign = text.align_left)
    table.cell(pn, 1, 0, "", bgcolor = color.new(#ef9a13, 0))
    table.cell(pn, 2, 0, "", bgcolor = color.new(#ef9a13, 0))
    table.merge_cells(pn, 0, 0, 2, 0)
    int bestI = -1
    float bestR = -1.0
    for i = 1 to NL - 1
        if i == 7
            continue
        r = f_rate(i)
        graded = touchN.get(i) >= minN
        row = i < 7 ? i : i - 1   // 1..9 — row 0 is the title
        isExt = i > 7
        col = isExt ? extCol : (i == 4 or i == 5) ? goldCol : color.new(#eef2f7, 0)
        table.cell(pn, 0, row, names.get(i), text_color = col, text_size = size.small, text_halign = text.align_left)
        table.cell(pn, 1, row, graded ? f_rep("▮", int(math.round(nz(r) * 6))) + f_rep("▭", 6 - int(math.round(nz(r) * 6))) : f_rep("▭", 6), text_color = graded and nz(r) >= 0.6 ? goldCol : color.new(#eef2f7, 30), text_size = size.small)
        table.cell(pn, 2, row, graded ? fw(r) + " ×" + str.tostring(touchN.get(i)) : "×" + str.tostring(touchN.get(i)), text_color = graded and nz(r) >= 0.6 ? goldCol : color.new(#eef2f7, 20), text_size = size.small)
        if graded and nz(r) > bestR
            bestR := nz(r)
            bestI := i
    table.cell(pn, 0, 10, bestI >= 0 ? "This symbol honors " + names.get(bestI) + " most · respect = ≥" + str.tostring(reactAtr, "#.#") + " ATR reaction · this chart only" : "Collecting touches · respect = ≥" + str.tostring(reactAtr, "#.#") + " ATR reaction", text_color = color.new(#cdb87e, 20), text_size = size.tiny, text_halign = text.align_left)
    table.merge_cells(pn, 0, 10, 2, 10)

// ─── ALERTS ────────────────────────────────────────────────────
alertcondition(newLeg, "New Impulse", "A new impulse leg was detected and the Fibonacci ladder redrew.")
alertcondition(reactUp, "Level Reaction Up", "Price reacted upward from a Fibonacci level.")
alertcondition(reactDn, "Level Reaction Down", "Price reacted downward from a Fibonacci level.")
inPocket = legDir != 0 and not na(rng) and low <= math.max(f_lvl(0.618), f_lvl(0.65)) and high >= math.min(f_lvl(0.618), f_lvl(0.65))
alertcondition(inPocket and not inPocket[1], "Golden Pocket Touched", "Price entered the 0.618–0.65 golden pocket of the live impulse.")
````
