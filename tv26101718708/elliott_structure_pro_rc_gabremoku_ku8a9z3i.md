# Elliott Structure Pro RC [Gabremoku]

- url: https://www.tradingview.com/script/Ku8a9Z3i-Elliott-Structure-Pro-RC-Gabremoku/
- type: indicator
- pine_id: PUB;28eb975a4385475a81e4c0a4da47cbff
- version: 1.0

## Description

Elliott Structure Pro RC [Gabremoku] is a market structure and wave-mapping overlay designed to detect candidate Elliott impulse patterns using pivot logic, ZigZag structure, validation rules, invalidation levels, and projected Fibonacci targets.

This script does not claim to produce definitive Elliott Wave counts. Instead, it scans recent pivot structure and highlights the most coherent bullish or bearish candidate sequence based on alternating swing logic, structural progression, and optional Elliott validation filters. That framing is important because Elliott Wave interpretation is inherently subjective, while the classic impulse model still relies on a few widely accepted structural rules.

What it shows
🔺 ZigZag market structure — the script builds a cleaned pivot path from swing highs and lows, filtering out smaller fluctuations to make structure easier to read. ZigZag-style logic is commonly used to reduce chart noise and highlight meaningful turning points.

🏷️ HH / HL / LH / LL tags — every pivot can be classified into higher high, higher low, lower high, or lower low structure, helping the user read trend progression directly from price swings.

🌊 Candidate Elliott 1–5 sequence — the script scans recent pivots and searches for the best bullish or bearish 5-wave impulse candidate.

❌ Invalidation tracking — once a candidate is found, the script projects an invalidation level and can flag when the structure has been broken.

🔤 Optional ABC correction — after a 5-wave sequence, the indicator can also look for a basic A-B-C corrective continuation.

📏 Fibonacci projections — projected target levels for Wave 3 and Wave 5 are plotted using configurable Fibonacci multipliers. Fibonacci extensions are commonly used in Elliott analysis to estimate probable Wave 3 and Wave 5 zones.

🪧 Dashboard — shows state, mode, pivot count, direction, validation strictness, ABC status, broken structure state, and target visibility.

Core logic
The script begins with pivot highs and pivot lows, then compresses them into a cleaner alternating sequence. From there, it builds a structural map and scans the most recent pivots to find a valid 6-point sequence that can represent a 5-wave bullish or bearish impulse candidate.

In practical terms, it combines:

market structure

ZigZag logic

Elliott candidate matching

rule-based validation

invalidation and target projection

That makes it useful as a structure-reading tool first, and an Elliott helper second.

Validation model
The script offers two operating styles:

Semplificato

Avanzato

In simplified mode, the indicator focuses more on structural coherence and swing progression. In advanced mode, it can apply stricter Elliott-style validation rules such as:

Wave 3 not shortest

Wave 4 no overlap with Wave 1 territory

invalid candidate marking when rules are not respected

Those rules align with widely cited core Elliott impulse rules. In standard impulse structures, Wave 3 may not be the shortest of Waves 1, 3, and 5, and Wave 4 should not overlap Wave 1 territory except in special formations such as certain diagonals.

Fibonacci targets
The indicator also projects two practical target references:

Wave 3 target

Wave 5 target

In Elliott analysis, Wave 3 is often projected using Fibonacci expansion of Wave 1, with 1.618 being one of the most common reference ratios, while Wave 5 is often estimated from prior impulse relationships or partial trend expansion logic.

Your script uses configurable multipliers, which is a good choice because different markets and timeframes can produce different expansion behaviors.

How to use
A practical workflow is:

Let the script identify the active pivot structure.

Check whether the chart is printing HH/HL or LH/LL logic.

Watch for a highlighted bullish or bearish 1–5 candidate.

Use the invalidation level to judge whether the count remains structurally valid.

Use projected Fib targets as reference zones, not guaranteed endpoints.

If enabled, monitor whether a simple ABC correction starts forming after the impulse.

This is best used as a decision-support overlay, especially for traders who already read market structure and want an automated way to visualize possible wave candidates.

Features
✅ Pivot-based market structure engine

✅ ZigZag overlay with configurable sensitivity

✅ HH / HL / LH / LL classification

✅ Candidate bullish and bearish Elliott impulse detection

✅ Simplified or advanced scan mode

✅ Optional strict Elliott validation

✅ Wave 3 not shortest filter

✅ Wave 4 overlap validation

✅ Broken-structure detection

✅ Invalidation level plotting

✅ Optional ABC correction detection

✅ Fibonacci Wave 3 / Wave 5 projections

✅ Dashboard and optional bar coloring

✅ Gradient-based swing visualization

Notes
This indicator is designed to identify candidate Elliott structures, not to replace discretionary wave analysis. Elliott interpretation is partly rule-based and partly interpretative, so projected counts and targets should always be confirmed with broader market context, price action, and risk management.

Author: Gabremoku
Pine Script v6

## Source Code

````pine
 // This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Gabremoku
//  Elliott Structure Pro RC [Gabremoku]
//  Market Structure + ZigZag + candidate Elliott Waves + invalidation + fib targets
//  Bull = Blu | Bear = Giallo
// ═══════════════════════════════════════════════════════════════
//@version=6
indicator("Elliott Structure Pro RC [Gabremoku]", overlay=true, max_lines_count=500, max_labels_count=500)

// ── INPUTS ─────────────────────────────────────────────────────
grpE = "🧭 Wave Engine"
waveMode   = input.string("Semplificato", "Wave Mode", options=["Semplificato", "Avanzato"], group=grpE)
scanWindow = input.int(16, "Pivot Scan Window", minval=6, maxval=50, group=grpE, tooltip="Numero di pivot recenti usati per cercare il miglior pattern Elliott.")
showBroken = input.bool(true, "Show Broken Structure", group=grpE, tooltip="Mantiene visibile il pattern anche dopo invalidazione.")
preferNewest = input.bool(true, "Prefer Newest Candidate", group=grpE, tooltip="A parità di qualità privilegia il pattern più recente.")

grp0 = "⚙️ Core"
pivotLeft       = input.int(4, "Pivot Left", minval=1, group=grp0)
pivotRight      = input.int(4, "Pivot Right", minval=1, group=grp0)
minSwingPerc    = input.float(0.40, "Min Swing %", minval=0.1, step=0.1, group=grp0)
maxStoredPivots = input.int(100, "Max Stored Pivots", minval=20, maxval=300, group=grp0)

grp1 = "🎨 Colors"
bullColor      = input.color(color.rgb(33, 150, 243), "Bullish Color (Blue)", group=grp1)
bearColor      = input.color(color.rgb(241, 255, 48), "Bearish Color (Yellow)", group=grp1)
neutralColor   = input.color(color.gray, "Neutral Color", group=grp1)
structureColor = input.color(color.rgb(145, 145, 145), "Structure Neutral", group=grp1)
abcColor       = input.color(color.rgb(190, 190, 190), "ABC Color", group=grp1)
fibColor       = input.color(color.rgb(235, 235, 235), "Fib Target Color", group=grp1)

grp2 = "📐 Style"
showZigZag         = input.bool(true, "Show ZigZag", group=grp2)
showStructureTags  = input.bool(true, "Show HH / HL / LH / LL", group=grp2)
showWaveLabels     = input.bool(true, "Show Elliott Labels", group=grp2)
showWaveLines      = input.bool(true, "Show Elliott Overlay", group=grp2)
showPivotMarkers   = input.bool(false, "Show Pivot Markers", group=grp2)
showDashboard      = input.bool(true, "Show Dashboard", group=grp2)
showBarColors      = input.bool(true, "Color Bars", group=grp2)
showSiteRef        = input.bool(true, "Show Site Ref", group=grp2)
zigzagWidth        = input.int(2, "ZigZag Width", minval=1, maxval=5, group=grp2)
waveWidth          = input.int(4, "Wave Width", minval=1, maxval=6, group=grp2)
invalidationWidth  = input.int(2, "Invalidation Width", minval=1, maxval=4, group=grp2)
fibWidth           = input.int(1, "Fib Width", minval=1, maxval=3, group=grp2)
labelSizeOpt       = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal"], group=grp2)

grp3 = "🌈 Gradient Logic"
useGradient      = input.bool(true, "Enable Gradient Effect", group=grp3)
fillAggressive   = input.float(1.60, "Gradient Aggressiveness", minval=0.5, maxval=4.0, step=0.1, group=grp3)
maxOpacityStrong = input.int(88, "Strong Swing Opacity", minval=0, maxval=100, group=grp3)
minOpacityWeak   = input.int(18, "Weak Swing Opacity", minval=0, maxval=100, group=grp3)

grp4 = "📐 Validation Rules"
useStrictRules    = input.bool(true, "Use Strict Elliott Validation", group=grp4)
wave3NotShortest  = input.bool(true, "Force Wave 3 Not Shortest", group=grp4)
wave4NoOverlap    = input.bool(true, "Force Wave 4 No Overlap", group=grp4)
showInvalidations = input.bool(true, "Show Invalidations", group=grp4)
showABC           = input.bool(true, "Show Simple ABC", group=grp4)
invalidationBars  = input.int(100, "Invalidation Window Bars", minval=10, maxval=300, group=grp4)

grp5 = "📏 Targets"
showFibTargets = input.bool(true, "Show Fib Targets", group=grp5)
fibWave3Mult   = input.float(1.618, "Wave 3 Fib", minval=0.5, step=0.001, group=grp5)
fibWave5Mult   = input.float(0.618, "Wave 5 Fib", minval=0.1, step=0.001, group=grp5)

// ── FUNCTIONS ──────────────────────────────────────────────────
clamp(_x, _min, _max) =>
    math.max(_min, math.min(_max, _x))

swingPerc(_a, _b) =>
    _a != 0 ? math.abs((_b - _a) / _a) * 100.0 : 0.0

lblSize(_s) =>
    _s == "Tiny" ? size.tiny : _s == "Normal" ? size.normal : size.small

gradCol(_isBull, _strength) =>
    _n = clamp(math.pow(_strength, fillAggressive), 0.0, 1.0)
    _bullNear = color.new(bullColor, maxOpacityStrong)
    _bullFar  = color.new(bullColor, minOpacityWeak)
    _bearNear = color.new(bearColor, maxOpacityStrong)
    _bearFar  = color.new(bearColor, minOpacityWeak)
    useGradient
         ? (_isBull ? color.from_gradient(_n, 0.0, 1.0, _bullFar, _bullNear) : color.from_gradient(_n, 0.0, 1.0, _bearFar, _bearNear))
         : (_isBull ? bullColor : bearColor)

scoreCandidate(_sw1, _sw2, _sw3, _sw4, _sw5, _recencyBoost) =>
    (_sw1 + _sw2 + _sw3 + _sw4 + _sw5) + _recencyBoost

isSimple   = waveMode == "Semplificato"
isAdvanced = waveMode == "Avanzato"

// ── PIVOTS ─────────────────────────────────────────────────────
ph = ta.pivothigh(high, pivotLeft, pivotRight)
pl = ta.pivotlow(low, pivotLeft, pivotRight)

var float[]  pivPrices = array.new_float()
var int[]    pivBars   = array.new_int()
var int[]    pivTypes  = array.new_int()
var string[] pivClass  = array.new_string()

if not na(ph)
    array.push(pivPrices, ph)
    array.push(pivBars, bar_index - pivotRight)
    array.push(pivTypes, 1)
    array.push(pivClass, "")

if not na(pl)
    array.push(pivPrices, pl)
    array.push(pivBars, bar_index - pivotRight)
    array.push(pivTypes, -1)
    array.push(pivClass, "")

if array.size(pivTypes) >= 2
    lastType = array.get(pivTypes, array.size(pivTypes) - 1)
    prevType = array.get(pivTypes, array.size(pivTypes) - 2)

    if lastType == prevType
        lastPrice = array.get(pivPrices, array.size(pivPrices) - 1)
        prevPrice = array.get(pivPrices, array.size(pivPrices) - 2)
        keepLast = lastType == 1 ? lastPrice > prevPrice : lastPrice < prevPrice

        if keepLast
            array.remove(pivPrices, array.size(pivPrices) - 2)
            array.remove(pivBars,   array.size(pivBars) - 2)
            array.remove(pivTypes,  array.size(pivTypes) - 2)
            array.remove(pivClass,  array.size(pivClass) - 2)
        else
            array.pop(pivPrices)
            array.pop(pivBars)
            array.pop(pivTypes)
            array.pop(pivClass)

while array.size(pivPrices) > maxStoredPivots
    array.shift(pivPrices)
    array.shift(pivBars)
    array.shift(pivTypes)
    array.shift(pivClass)

plotshape(showPivotMarkers and not na(ph), title="Pivot High", style=shape.circle, location=location.abovebar, offset=-pivotRight, color=color.new(bearColor, 15), size=size.tiny)
plotshape(showPivotMarkers and not na(pl), title="Pivot Low", style=shape.circle, location=location.belowbar, offset=-pivotRight, color=color.new(bullColor, 15), size=size.tiny)

pivCount = array.size(pivPrices)

// ── STRUCTURE CLASSIFICATION ───────────────────────────────────
float highRef = na
float lowRef  = na

if pivCount > 0
    for i = 0 to pivCount - 1
        pType = array.get(pivTypes, i)
        pVal  = array.get(pivPrices, i)
        string cls = ""

        if pType == 1
            if na(highRef)
                cls := "H"
            else
                cls := pVal > highRef ? "HH" : "LH"
            highRef := pVal
        else
            if na(lowRef)
                cls := "L"
            else
                cls := pVal < lowRef ? "LL" : "HL"
            lowRef := pVal

        array.set(pivClass, i, cls)

// ── DRAW STORAGE ───────────────────────────────────────────────
var line[]  drawLines  = array.new_line()
var label[] drawLabels = array.new_label()

clearDrawings() =>
    if array.size(drawLines) > 0
        for i = 0 to array.size(drawLines) - 1
            line.delete(array.get(drawLines, i))
    if array.size(drawLabels) > 0
        for i = 0 to array.size(drawLabels) - 1
            label.delete(array.get(drawLabels, i))
    array.clear(drawLines)
    array.clear(drawLabels)

// ── STATE ──────────────────────────────────────────────────────
var string waveState = "Building Structure"
var color stateCol = neutralColor
var bool bullishImpulse = false
var bool bearishImpulse = false
var bool invalidBull = false
var bool invalidBear = false
var bool abcFound = false
var bool structureBroken = false

// ── MAIN DRAW ──────────────────────────────────────────────────
if barstate.islast
    clearDrawings()

    waveState := "Building Structure"
    stateCol := neutralColor
    bullishImpulse := false
    bearishImpulse := false
    invalidBull := false
    invalidBear := false
    abcFound := false
    structureBroken := false

    if pivCount >= 2
        start = math.max(0, pivCount - scanWindow)

        maxSwing = 0.0
        for i = start + 1 to pivCount - 1
            a = array.get(pivPrices, i - 1)
            b = array.get(pivPrices, i)
            maxSwing := math.max(maxSwing, swingPerc(a, b))
        maxSwing := maxSwing == 0 ? 1.0 : maxSwing

        for i = start + 1 to pivCount - 1
            x1 = array.get(pivBars, i - 1)
            y1 = array.get(pivPrices, i - 1)
            x2 = array.get(pivBars, i)
            y2 = array.get(pivPrices, i)
            sw = swingPerc(y1, y2)

            if sw >= minSwingPerc
                isBullSeg = y2 > y1
                strength = clamp(sw / maxSwing, 0.0, 1.0)
                baseCol = gradCol(isBullSeg, strength)

                if showZigZag
                    array.push(drawLines, line.new(x1, y1, x2, y2, xloc=xloc.bar_index, color=baseCol, width=zigzagWidth))

                if showStructureTags
                    cls = array.get(pivClass, i)
                    tagCol =
                         cls == "HH" or cls == "HL" ? color.new(bullColor, 8) :
                         cls == "LL" or cls == "LH" ? color.new(bearColor, 8) :
                         color.new(structureColor, 10)

                    array.push(drawLabels, label.new(x2, y2, cls, xloc=xloc.bar_index, style=label.style_label_center, textcolor=color.black, color=tagCol, size=lblSize(labelSizeOpt)))

    bestScore = -1.0
    int bestIdx = na
    bestDir = 0

    if pivCount >= 6
        startScan = math.max(0, pivCount - scanWindow)
        endScan = pivCount - 6

        for s = startScan to endScan
            p0 = array.get(pivPrices, s + 0)
            p1 = array.get(pivPrices, s + 1)
            p2 = array.get(pivPrices, s + 2)
            p3 = array.get(pivPrices, s + 3)
            p4 = array.get(pivPrices, s + 4)
            p5 = array.get(pivPrices, s + 5)

            t0 = array.get(pivTypes, s + 0)
            t1 = array.get(pivTypes, s + 1)
            t2 = array.get(pivTypes, s + 2)
            t3 = array.get(pivTypes, s + 3)
            t4 = array.get(pivTypes, s + 4)
            t5 = array.get(pivTypes, s + 5)

            sw1 = swingPerc(p0, p1)
            sw2 = swingPerc(p1, p2)
            sw3 = swingPerc(p2, p3)
            sw4 = swingPerc(p3, p4)
            sw5 = swingPerc(p4, p5)
            swingsOk = sw1 >= minSwingPerc and sw2 >= minSwingPerc and sw3 >= minSwingPerc and sw4 >= minSwingPerc and sw5 >= minSwingPerc

            bullCandidate = t0 == -1 and t1 == 1 and t2 == -1 and t3 == 1 and t4 == -1 and t5 == 1 and p2 > p0 and p3 > p1 and p4 > p2 and p5 > p3
            bearCandidate = t0 == 1 and t1 == -1 and t2 == 1 and t3 == -1 and t4 == 1 and t5 == -1 and p2 < p0 and p3 < p1 and p4 < p2 and p5 < p3

            len1 = math.abs(p1 - p0)
            len3 = math.abs(p3 - p2)
            len5 = math.abs(p5 - p4)

            bullStrict = bullCandidate and swingsOk and p2 > p0 and (wave4NoOverlap ? p4 > p1 : true) and (wave3NotShortest ? len3 >= math.min(len1, len5) : true)
            bearStrict = bearCandidate and swingsOk and p2 < p0 and (wave4NoOverlap ? p4 < p1 : true) and (wave3NotShortest ? len3 >= math.min(len1, len5) : true)

            simpleOk = (bullCandidate or bearCandidate) and swingsOk
            strictOk = bullStrict or bearStrict
            finalOk = isSimple ? simpleOk : (useStrictRules ? strictOk : simpleOk)

            recencyBoost = preferNewest ? (s * 0.001) : 0.0
            score = scoreCandidate(sw1, sw2, sw3, sw4, sw5, recencyBoost)

            if finalOk and score > bestScore
                bestScore := score
                bestIdx := s
                bestDir := bullCandidate ? 1 : -1

            if isAdvanced and not finalOk and simpleOk and showInvalidations
                invalidBull := invalidBull or (bullCandidate and not bullStrict)
                invalidBear := invalidBear or (bearCandidate and not bearStrict)

    if not na(bestIdx)
        s = bestIdx

        x0 = array.get(pivBars, s + 0), p0 = array.get(pivPrices, s + 0)
        x1 = array.get(pivBars, s + 1), p1 = array.get(pivPrices, s + 1)
        x2 = array.get(pivBars, s + 2), p2 = array.get(pivPrices, s + 2)
        x3 = array.get(pivBars, s + 3), p3 = array.get(pivPrices, s + 3)
        x4 = array.get(pivBars, s + 4), p4 = array.get(pivPrices, s + 4)
        x5 = array.get(pivBars, s + 5), p5 = array.get(pivPrices, s + 5)

        bullishImpulse := bestDir == 1
        bearishImpulse := bestDir == -1
        stateCol := bullishImpulse ? bullColor : bearColor
        waveState := bullishImpulse ? "Bullish Impulse" : "Bearish Impulse"

        invalidPrice = p4
        brokenNow =
             bullishImpulse ? (close < invalidPrice and bar_index - x5 <= invalidationBars) :
             bearishImpulse ? (close > invalidPrice and bar_index - x5 <= invalidationBars) :
             false

        structureBroken := brokenNow

        if not structureBroken or showBroken
            if showWaveLines
                c1 = color.new(stateCol, structureBroken ? 55 : 8)
                c2 = color.new(stateCol, structureBroken ? 60 : 15)
                c3 = color.new(stateCol, structureBroken ? 45 : 0)
                c4 = color.new(stateCol, structureBroken ? 60 : 15)
                c5 = color.new(stateCol, structureBroken ? 55 : 8)
                lineStyleMain = structureBroken ? line.style_dotted : line.style_solid

                array.push(drawLines, line.new(x0, p0, x1, p1, xloc=xloc.bar_index, color=c1, width=waveWidth, style=lineStyleMain))
                array.push(drawLines, line.new(x1, p1, x2, p2, xloc=xloc.bar_index, color=c2, width=waveWidth, style=lineStyleMain))
                array.push(drawLines, line.new(x2, p2, x3, p3, xloc=xloc.bar_index, color=c3, width=waveWidth + 1, style=lineStyleMain))
                array.push(drawLines, line.new(x3, p3, x4, p4, xloc=xloc.bar_index, color=c4, width=waveWidth, style=lineStyleMain))
                array.push(drawLines, line.new(x4, p4, x5, p5, xloc=xloc.bar_index, color=c5, width=waveWidth, style=lineStyleMain))

            if showWaveLabels
                wCol = color.new(stateCol, structureBroken ? 40 : 5)
                ls = lblSize(labelSizeOpt)
                array.push(drawLabels, label.new(x1, p1, "1", xloc=xloc.bar_index, style=label.style_label_center, textcolor=color.black, color=wCol, size=ls))
                array.push(drawLabels, label.new(x2, p2, "2", xloc=xloc.bar_index, style=label.style_label_center, textcolor=color.black, color=wCol, size=ls))
                array.push(drawLabels, label.new(x3, p3, "3", xloc=xloc.bar_index, style=label.style_label_center, textcolor=color.black, color=wCol, size=ls))
                array.push(drawLabels, label.new(x4, p4, "4", xloc=xloc.bar_index, style=label.style_label_center, textcolor=color.black, color=wCol, size=ls))
                array.push(drawLabels, label.new(x5, p5, "5", xloc=xloc.bar_index, style=label.style_label_center, textcolor=color.black, color=wCol, size=ls))

        if showInvalidations
            invCol = bullishImpulse ? color.new(bearColor, 5) : color.new(bullColor, 5)
            array.push(drawLines, line.new(x5, invalidPrice, bar_index + 20, invalidPrice, xloc=xloc.bar_index, extend=extend.none, color=invCol, width=invalidationWidth, style=line.style_dashed))
            array.push(drawLabels, label.new(bar_index + 1, invalidPrice, "Invalidation", xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.black, color=invCol, size=lblSize(labelSizeOpt)))

        if showFibTargets
            len12 = math.abs(p1 - p0)
            len03 = math.abs(p3 - p0)

            fib3 = bullishImpulse ? p2 + len12 * fibWave3Mult : p2 - len12 * fibWave3Mult
            fib5 = bullishImpulse ? p4 + len03 * fibWave5Mult : p4 - len03 * fibWave5Mult

            array.push(drawLines, line.new(x2, fib3, bar_index + 20, fib3, xloc=xloc.bar_index, color=color.new(fibColor, 35), width=fibWidth, style=line.style_dotted))
            array.push(drawLines, line.new(x4, fib5, bar_index + 20, fib5, xloc=xloc.bar_index, color=color.new(fibColor, 10), width=fibWidth, style=line.style_dotted))
            array.push(drawLabels, label.new(bar_index + 1, fib3, "Fib W3", xloc=xloc.bar_index, style=label.style_label_left, textcolor=chart.fg_color, color=color.new(color.black, 100), size=lblSize(labelSizeOpt)))
            array.push(drawLabels, label.new(bar_index + 1, fib5, "Fib W5", xloc=xloc.bar_index, style=label.style_label_left, textcolor=chart.fg_color, color=color.new(color.black, 100), size=lblSize(labelSizeOpt)))

        if structureBroken
            waveState := bullishImpulse ? "Bullish Broken" : "Bearish Broken"

        if isAdvanced and showABC and pivCount >= s + 9
            xa = array.get(pivBars, s + 6), pa = array.get(pivPrices, s + 6)
            xb = array.get(pivBars, s + 7), pb = array.get(pivPrices, s + 7)
            xc = array.get(pivBars, s + 8), pc = array.get(pivPrices, s + 8)

            corrBull = bullishImpulse and pa < p5 and pb > pa and pc < pb
            corrBear = bearishImpulse and pa > p5 and pb < pa and pc > pb

            if corrBull or corrBear
                abcFound := true
                waveState := structureBroken ? waveState : bullishImpulse ? "Bullish Impulse + ABC" : "Bearish Impulse + ABC"

                array.push(drawLines, line.new(x5, p5, xa, pa, xloc=xloc.bar_index, color=color.new(abcColor, 5), width=2, style=line.style_dashed))
                array.push(drawLines, line.new(xa, pa, xb, pb, xloc=xloc.bar_index, color=color.new(abcColor, 10), width=2, style=line.style_dashed))
                array.push(drawLines, line.new(xb, pb, xc, pc, xloc=xloc.bar_index, color=color.new(abcColor, 15), width=2, style=line.style_dashed))

                if showWaveLabels
                    ls = lblSize(labelSizeOpt)
                    array.push(drawLabels, label.new(xa, pa, "A", xloc=xloc.bar_index, style=label.style_label_center, textcolor=color.black, color=color.new(abcColor, 5), size=ls))
                    array.push(drawLabels, label.new(xb, pb, "B", xloc=xloc.bar_index, style=label.style_label_center, textcolor=color.black, color=color.new(abcColor, 10), size=ls))
                    array.push(drawLabels, label.new(xc, pc, "C", xloc=xloc.bar_index, style=label.style_label_center, textcolor=color.black, color=color.new(abcColor, 15), size=ls))
    else
        waveState := pivCount >= 6 ? "Candidate Search" : "Building Structure"
        stateCol := neutralColor

        if showInvalidations and isAdvanced and (invalidBull or invalidBear) and pivCount > 0
            ib = array.get(pivBars, pivCount - 1)
            ip = array.get(pivPrices, pivCount - 1)
            array.push(drawLabels, label.new(ib, ip, "Invalid", xloc=xloc.bar_index, style=label.style_label_down, textcolor=color.black, color=color.new(invalidBull ? bullColor : bearColor, 10), size=lblSize(labelSizeOpt)))


// ── BAR COLORS ─────────────────────────────────────────────────
barCol =
     bullishImpulse and not structureBroken ? color.new(bullColor, 0) :
     bearishImpulse and not structureBroken ? color.new(bearColor, 0) :
     structureBroken ? color.new(neutralColor, 20) :
     na

barcolor(showBarColors ? barCol : na)

// ── DASHBOARD ──────────────────────────────────────────────────
var table dash = table.new(position.bottom_right, 2, 8, border_width=1)

if barstate.islast and showDashboard
    table.cell(dash, 0, 0, "State", text_color=chart.fg_color, text_halign=text.align_left)
    table.cell(dash, 1, 0, waveState, text_color=stateCol, text_halign=text.align_center)

    table.cell(dash, 0, 1, "Mode", text_color=chart.fg_color, text_halign=text.align_left)
    table.cell(dash, 1, 1, waveMode, text_color=chart.fg_color, text_halign=text.align_center)

    table.cell(dash, 0, 2, "Pivots", text_color=chart.fg_color, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(pivCount), text_color=chart.fg_color, text_halign=text.align_center)

    table.cell(dash, 0, 3, "Direction", text_color=chart.fg_color, text_halign=text.align_left)
    table.cell(dash, 1, 3, bullishImpulse ? "Bullish" : bearishImpulse ? "Bearish" : "Neutral", text_color=stateCol, text_halign=text.align_center)

    table.cell(dash, 0, 4, "Rules", text_color=chart.fg_color, text_halign=text.align_left)
    table.cell(dash, 1, 4, isAdvanced and useStrictRules ? "Strict" : "Base", text_color=chart.fg_color, text_halign=text.align_center)

    table.cell(dash, 0, 5, "ABC", text_color=chart.fg_color, text_halign=text.align_left)
    table.cell(dash, 1, 5, abcFound ? "ON" : "OFF", text_color=abcFound ? abcColor : chart.fg_color, text_halign=text.align_center)

    table.cell(dash, 0, 6, "Broken", text_color=chart.fg_color, text_halign=text.align_left)
    table.cell(dash, 1, 6, structureBroken ? "YES" : "NO", text_color=structureBroken ? bearColor : chart.fg_color, text_halign=text.align_center)

    table.cell(dash, 0, 7, "Targets", text_color=chart.fg_color, text_halign=text.align_left)
    table.cell(dash, 1, 7, showFibTargets ? "ON" : "OFF", text_color=showFibTargets ? fibColor : chart.fg_color, text_halign=text.align_center)
````
