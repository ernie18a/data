# Auto Fib Retracement - Real-Time (KWG)

- url: https://www.tradingview.com/script/FEHNy08A-Auto-Fib-Retracement-Real-Time-KWG/
- type: indicator
- pine_id: PUB;fef9e446773c4b638426eeaa052de761
- version: 1.0

## Description

This is a fibonacci auto plotter still in testing phase use it at your own discretion

## Source Code

````pine
//@version=6
// ============================================================================
//  Auto Fibonacci Retracement - Real-Time (K Wealth Group)
//  Original implementation built from standard public TA concepts.
//  NOT a copy of Zeiierman's protected code - our own swing + fib logic,
//  extended with per-level controls, label toggles, anchor (A-B) line and
//  A/B swing markers.
// ============================================================================
indicator("Auto Fib Retracement - Real-Time (KWG)", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ─── Swing Detection ────────────────────────────────────────────────────────
gS          = "Swing Detection"
mode        = input.string("Swing Trading", "Trading Style", options = ["Scalping", "Trend Trading", "Swing Trading"], group = gS)
customLen   = input.int(0, "Custom Pivot Strength (0 = use style)", minval = 0, group = gS, tooltip = "Pivot left/right bars. A swing high/low confirms only after this many bars respect it, so the anchor stops chasing price. 0 = Scalping 5 / Trend 10 / Swing 20.")
pivSrcStr   = input.string("High / Low", "Pivot Source", options = ["High / Low", "Close"], group = gS, tooltip = "High/Low uses wick extremes. Close ignores wicks (line-chart style) for cleaner, less noisy pivots.")
domLookback = input.int(450, "Dominant Swing Lookback (bars)", minval = 400, maxval = 500, group = gS, tooltip = "Bounded to a 400–500 bar band so the anchor stays on the recent dominant swing rather than the all-time extreme. Slide within the band to fine-tune. Calibrated for the daily timeframe — on weekly/intraday you'll want to widen this.")

// ─── Labels (per your request: toggle % ratio and price independently) ───────
gL            = "Labels"
showPct       = input.bool(true,  "Show Fib Value (%)", group = gL, inline = "lbl1")
showPrice     = input.bool(true,  "Show Price",         group = gL, inline = "lbl1")
useCustomText = input.bool(false, "Use Custom Text Color", group = gL, inline = "lbl2")
textCol       = input.color(color.white, "", group = gL, inline = "lbl2")

// ─── Fib Levels: per-level on/off + editable ratio + per-level color ─────────
gF      = "Fib Levels"
reverse = input.bool(false, "Reverse (swap 0% / 100% anchor)", group = gF)
// Each row = [ on/off ] [ ratio ] [ color ]
s1  = input.bool(false, "", inline = "L1",  group = gF)
r1  = input.float(0.236,  "", inline = "L1",  group = gF, step = 0.001)
c1  = input.color(color.red, "", inline = "L1",  group = gF)
s2  = input.bool(false, "", inline = "L2",  group = gF)
r2  = input.float(0.382,  "", inline = "L2",  group = gF, step = 0.001)
c2  = input.color(color.rgb(165,214,167), "", inline = "L2",  group = gF)
s3  = input.bool(false, "", inline = "L3",  group = gF)
r3  = input.float(0.5,    "", inline = "L3",  group = gF, step = 0.001)
c3  = input.color(color.green, "", inline = "L3",  group = gF)
s4  = input.bool(true,  "", inline = "L4",  group = gF)
r4  = input.float(0.618,  "", inline = "L4",  group = gF, step = 0.001)
c4  = input.color(color.orange, "", inline = "L4",  group = gF)
s5  = input.bool(false, "", inline = "L5",  group = gF)
r5  = input.float(0.786,  "", inline = "L5",  group = gF, step = 0.001)
c5  = input.color(color.rgb(120,170,240), "", inline = "L5",  group = gF)
s6  = input.bool(false, "", inline = "L6",  group = gF)
r6  = input.float(-0.236, "", inline = "L6",  group = gF, step = 0.001)
c6  = input.color(color.red, "", inline = "L6",  group = gF)
s7  = input.bool(false, "", inline = "L7",  group = gF)
r7  = input.float(-0.382, "", inline = "L7",  group = gF, step = 0.001)
c7  = input.color(color.rgb(165,214,167), "", inline = "L7",  group = gF)
s8  = input.bool(false, "", inline = "L8",  group = gF)
r8  = input.float(-0.5,   "", inline = "L8",  group = gF, step = 0.001)
c8  = input.color(color.green, "", inline = "L8",  group = gF)
s9  = input.bool(true,  "", inline = "L9",  group = gF)
r9  = input.float(0.68,   "", inline = "L9",  group = gF, step = 0.001)
c9  = input.color(color.orange, "", inline = "L9",  group = gF)
s10 = input.bool(false, "", inline = "L10", group = gF)
r10 = input.float(1.618,  "", inline = "L10", group = gF, step = 0.001)
c10 = input.color(color.rgb(120,170,240), "", inline = "L10", group = gF)

// ─── Reverse Fib Overlay (drawn simultaneously on the same A→B swing) ────────
gR        = "Reverse Fib Overlay"
showRev   = input.bool(false, "Show Reverse Fib (mirrors the main anchor)", group = gR)
revCol    = input.color(color.orange, "Golden Color", group = gR, tooltip = "Reverse overlay shows only the 0.618 and 0.68 levels, mirrored against the opposite anchor of the same A→B swing.")

// ─── Active Swing Highlight ──────────────────────────────────────────────────
gH            = "Active Swing Highlight"
showHighlight = input.bool(true, "Highlight Active Golden Zone", group = gH, tooltip = "Shades the 0.618–0.68 golden pocket of the active swing. In stage one this is the dominant swing; in stage two it becomes the smallest swing whose lower golden zone is not yet reclaimed.")
hlZoneCol     = input.color(color.new(color.orange, 82), "Zone Fill", group = gH)

// ─── High / Low (0% & 100% anchors) ─────────────────────────────────────────
gHL       = "High / Low Anchors"
showHL    = input.bool(true, "Show High / Low", group = gHL, inline = "hl")
hlHighCol = input.color(color.green, "", group = gHL, inline = "hl")
hlLowCol  = input.color(color.red,   "", group = gHL, inline = "hl")

// ─── Anchor Line (A→B) and A/B Swing Markers ────────────────────────────────
gA          = "Anchor & Swing Markers"
showAnchor  = input.bool(true, "Anchor Line (A to B)", group = gA, inline = "anc")
anchorCol   = input.color(color.gray, "", group = gA, inline = "anc")
anchorStyle = input.string("Dashed", "", options = ["Solid","Dashed","Dotted"], group = gA, inline = "anc")
anchorWidth = input.int(1, "Anchor Line Width", minval = 1, group = gA)
showABMark  = input.bool(true, "A/B Horizontal Markers", group = gA, inline = "ab")
abCol       = input.color(color.gray, "", group = gA, inline = "ab")
abStyle     = input.string("Dotted", "", options = ["Solid","Dashed","Dotted"], group = gA, inline = "ab")
abBars      = input.int(15, "Marker Length (bars right)", minval = 1, group = gA)
showABTags  = input.bool(true, "Show A / B Tags", group = gA)

// ─── Fib Line Styling ───────────────────────────────────────────────────────
gST         = "Fib Line Styling"
fibStyleStr = input.string("Solid", "Fib Line Style", options = ["Solid","Dashed","Dotted"], group = gST)
fibWidth    = input.int(2, "Fib Line Width", minval = 1, group = gST)
extendRight = input.bool(true, "Extend Fib Lines Right", group = gST)

// ─── Trend Visuals ──────────────────────────────────────────────────────────
gT        = "Trend"
showBg    = input.bool(true,  "Trend Background", group = gT)
bgUp      = input.color(color.new(color.green, 92), "Color 0 (Up)",   group = gT)
bgDn      = input.color(color.new(color.red,   92), "Color 1 (Down)", group = gT)
showTable = input.bool(true,  "Trend Direction Table", group = gT)

// ─── Helpers ────────────────────────────────────────────────────────────────
f_lineStyle(string s) =>
    s == "Dotted" ? line.style_dotted : s == "Dashed" ? line.style_dashed : line.style_solid

// ─── Swing math: confirmed pivots stored in arrays → dominant swing ──────────
presetLen = mode == "Scalping" ? 5 : mode == "Trend Trading" ? 10 : 20
piv       = customLen > 0 ? customLen : presetLen   // pivot left/right strength
useClose  = pivSrcStr == "Close"
srcH      = useClose ? close : high
srcL      = useClose ? close : low

// A pivot prints `piv` bars after it actually occurred
ph = ta.pivothigh(srcH, piv, piv)
pl = ta.pivotlow(srcL,  piv, piv)

// Store every confirmed pivot (foundation reused for multi-degree in stage two)
var float[] phPrice = array.new_float()
var int[]   phBarA  = array.new_int()
var float[] plPrice = array.new_float()
var int[]   plBarA  = array.new_int()
if not na(ph)
    array.push(phPrice, ph)
    array.push(phBarA,  bar_index - piv)
    if array.size(phPrice) > 200
        array.shift(phPrice)
        array.shift(phBarA)
if not na(pl)
    array.push(plPrice, pl)
    array.push(plBarA,  bar_index - piv)
    if array.size(plPrice) > 200
        array.shift(plPrice)
        array.shift(plBarA)

// Dominant swing = highest pivot high & lowest pivot low within the lookback
float swingHigh = na
int   phBar     = na
float swingLow  = na
int   plBar     = na

nH = array.size(phPrice)
if nH > 0
    for i = 0 to nH - 1
        b = array.get(phBarA, i)
        if domLookback == 0 or (bar_index - b) <= domLookback
            p = array.get(phPrice, i)
            if na(swingHigh) or p > swingHigh
                swingHigh := p
                phBar     := b
nL = array.size(plPrice)
if nL > 0
    for i = 0 to nL - 1
        b = array.get(plBarA, i)
        if domLookback == 0 or (bar_index - b) <= domLookback
            p = array.get(plPrice, i)
            if na(swingLow) or p < swingLow
                swingLow := p
                plBar    := b

rng = swingHigh - swingLow

// Trend = whichever dominant extreme is more recent (high more recent → up leg)
bool isUp = false
if not na(phBar) and not na(plBar)
    isUp := phBar >= plBar
dirUp      = reverse ? not isUp : isUp
golden618  = dirUp ? swingHigh - rng * 0.618 : swingLow + rng * 0.618
mid50      = dirUp ? swingHigh - rng * 0.500 : swingLow + rng * 0.500
haveSwings = not na(swingHigh) and not na(swingLow)

// ─── Drawing buffers ────────────────────────────────────────────────────────
var line[]  fLines  = array.new_line()
var label[] fLabels = array.new_label()
var box[]   fBoxes  = array.new_box()

if barstate.islast and haveSwings
    for ln in fLines
        line.delete(ln)
    array.clear(fLines)
    for lb in fLabels
        label.delete(lb)
    array.clear(fLabels)
    for bx in fBoxes
        box.delete(bx)
    array.clear(fBoxes)

    hiBar    = phBar
    loBar    = plBar
    leftBar  = math.min(hiBar, loBar)
    rightX   = extendRight ? bar_index + 20 : math.max(hiBar, loBar)
    fibStyle = f_lineStyle(fibStyleStr)

    // Active swing highlight — stage-one scaffold: one swing, so highlight it.
    // Stage two: pick the smallest swing whose lower golden zone is unreclaimed.
    if showHighlight
        gzA = dirUp ? swingHigh - rng * 0.618 : swingLow + rng * 0.618
        gzB = dirUp ? swingHigh - rng * 0.68  : swingLow + rng * 0.68
        array.push(fBoxes, box.new(leftBar, math.max(gzA, gzB), rightX, math.min(gzA, gzB), border_color = na, bgcolor = hlZoneCol))

    // Configurable levels
    shows  = array.from(s1,s2,s3,s4,s5,s6,s7,s8,s9,s10)
    ratios = array.from(r1,r2,r3,r4,r5,r6,r7,r8,r9,r10)
    cols   = array.from(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10)
    for i = 0 to 9
        if array.get(shows, i)
            r     = array.get(ratios, i)
            col   = array.get(cols, i)
            price = dirUp ? swingHigh - rng * r : swingLow + rng * r
            array.push(fLines, line.new(leftBar, price, rightX, price, color = col, width = fibWidth, style = fibStyle))
            if showPct or showPrice
                txt = (showPct ? str.tostring(r * 100, "#.0") + "%  " : "") + (showPrice ? str.tostring(price, format.mintick) : "")
                array.push(fLabels, label.new(rightX, price, txt, style = label.style_label_left, color = color.new(color.gray, 100), textcolor = useCustomText ? textCol : col, size = size.small))

    // Reverse fib overlay: only 0.618 & 0.68, mirrored against the opposite anchor
    if showRev
        revUp = not dirUp
        revRatios = array.from(0.618, 0.68)
        for j = 0 to array.size(revRatios) - 1
            rr = array.get(revRatios, j)
            rp = revUp ? swingHigh - rng * rr : swingLow + rng * rr
            array.push(fLines, line.new(leftBar, rp, rightX, rp, color = revCol, width = fibWidth, style = fibStyle))
            if showPct or showPrice
                rtxt = (showPct ? "R " + str.tostring(rr * 100, "#.0") + "%  " : "") + (showPrice ? str.tostring(rp, format.mintick) : "")
                array.push(fLabels, label.new(rightX, rp, rtxt, style = label.style_label_left, color = color.new(color.gray, 100), textcolor = useCustomText ? textCol : revCol, size = size.small))

    // High / Low (0% & 100%)
    if showHL
        array.push(fLines, line.new(leftBar, swingHigh, rightX, swingHigh, color = hlHighCol, width = fibWidth, style = fibStyle))
        array.push(fLines, line.new(leftBar, swingLow,  rightX, swingLow,  color = hlLowCol,  width = fibWidth, style = fibStyle))
        if showPct or showPrice
            hiPct = dirUp ? 0.0 : 1.0
            loPct = dirUp ? 1.0 : 0.0
            tH = (showPct ? str.tostring(hiPct * 100, "#.0") + "%  " : "") + (showPrice ? str.tostring(swingHigh, format.mintick) : "")
            tL = (showPct ? str.tostring(loPct * 100, "#.0") + "%  " : "") + (showPrice ? str.tostring(swingLow,  format.mintick) : "")
            array.push(fLabels, label.new(rightX, swingHigh, tH, style = label.style_label_left, color = color.new(color.gray, 100), textcolor = useCustomText ? textCol : hlHighCol, size = size.small))
            array.push(fLabels, label.new(rightX, swingLow,  tL, style = label.style_label_left, color = color.new(color.gray, 100), textcolor = useCustomText ? textCol : hlLowCol,  size = size.small))

    // Anchor line A → B (diagonal showing the swing the fib is built on)
    if showAnchor
        array.push(fLines, line.new(loBar, swingLow, hiBar, swingHigh, color = anchorCol, width = anchorWidth, style = f_lineStyle(anchorStyle)))

    // A/B horizontal dotted markers extending right
    if showABMark
        abS = f_lineStyle(abStyle)
        array.push(fLines, line.new(hiBar, swingHigh, hiBar + abBars, swingHigh, color = abCol, width = 1, style = abS))
        array.push(fLines, line.new(loBar, swingLow,  loBar + abBars, swingLow,  color = abCol, width = 1, style = abS))
        if showABTags
            aBar    = math.min(hiBar, loBar)
            bBar    = math.max(hiBar, loBar)
            aPrice  = aBar == hiBar ? swingHigh : swingLow
            bPrice  = bBar == hiBar ? swingHigh : swingLow
            aStyle  = aPrice == swingHigh ? label.style_label_down : label.style_label_up
            bStyle  = bPrice == swingHigh ? label.style_label_down : label.style_label_up
            array.push(fLabels, label.new(aBar, aPrice, "A", style = aStyle, color = color.new(abCol, 10), textcolor = color.white, size = size.small))
            array.push(fLabels, label.new(bBar, bPrice, "B", style = bStyle, color = color.new(abCol, 10), textcolor = color.white, size = size.small))

// ─── Trend background ───────────────────────────────────────────────────────
bgcolor(showBg ? (isUp ? bgUp : bgDn) : na)

// ─── Trend direction table ──────────────────────────────────────────────────
var table tt = table.new(position.top_right, 1, 2, border_width = 1, border_color = color.new(color.gray, 50))
if showTable and barstate.islast
    table.cell(tt, 0, 0, "Trend", text_color = chart.fg_color, bgcolor = color.new(color.gray, 75), text_size = size.small)
    table.cell(tt, 0, 1, isUp ? "▲ UP" : "▼ DOWN", text_color = color.white, bgcolor = isUp ? color.green : color.red, text_size = size.small)

// ─── Alerts ─────────────────────────────────────────────────────────────────
alertcondition(ta.cross(close, golden618), "Price testing 61.8%", "Price is testing the 61.8% Fibonacci level")
alertcondition(ta.cross(close, mid50),     "Price testing 50%",   "Price is testing the 50% Fibonacci level")
````
