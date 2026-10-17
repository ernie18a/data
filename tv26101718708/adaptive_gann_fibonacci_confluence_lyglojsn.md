# Adaptive Gann & Fibonacci Confluence

- url: https://www.tradingview.com/script/lYGLOJsn-Adaptive-Gann-Fibonacci-Confluence/
- type: indicator
- pine_id: PUB;6b2484ad117d4ac480d74eba64c35357
- version: 3.0

## Description

Adaptive Gann & Fibonacci Confluence

Overview

This indicator automatically detects the dominant swing on your chart — the highest high and lowest low over a lookback you set — and projects three classic geometric tools from that single shared anchor: a Gann fan, a Fibonacci fan, and Fibonacci retracement levels. Because all three are built on the same swing, their levels can be compared directly on one chart.

Why these tools are combined

A Gann fan and Fibonacci retracements measure two different things. A Gann fan measures trend slope — the geometric balance between price and time, where the 1×1 angle represents one unit of price per unit of time. Fibonacci retracements measure pullback depth — proportional price levels inside a move (23.6 / 38.2 / 50 / 61.8 / 78.6%). Used separately, each tool is anchored differently and the two rarely line up. By forcing both to share one auto-detected swing origin and direction, the script exposes price areas where a Gann angle and a Fibonacci level coincide. A level confirmed by both slope geometry and retracement proportion is the intended point of interest — more meaningful than a level from either method alone.

How the components work together

The script finds the swing once, then anchors the Gann fan, the Fibonacci fan, and the retracement grid to the same origin and trend direction. The Gann rays and the Fibonacci levels therefore sit on a common reference, so you can spot where a fan ray crosses a retracement level at roughly the same price — that overlap is the "confluence." Shaded zones mark the retracement bands, and a compact table summarizes the live read: directional bias, nearest support and resistance among the levels, current retracement depth, and a plain-language note on where price sits in the swing.

What makes it original

Rather than drawing Gann angles at fixed chart degrees (which break when you change instrument or zoom), the 1×1 angle here is scaled to the swing's actual price-per-bar, so the angles stay consistent across symbols and timeframes. That swing-scaled Gann geometry is then rendered together with Fibonacci fan and retracement structure on a single, automatically updating anchor — with confluence surfaced visually and condensed into a live snapshot table. The drawing engine rebuilds only when the underlying swing changes, keeping it light.

How to use it

Set Swing lookback to the structure you trade: smaller values track recent swings, larger values capture higher-timeframe structure.
The gold line is the 1×1 (trend-balance) angle; how price reacts to it gauges trend strength.
Treat confluence (a fan ray meeting a retracement level) as an area of interest to study, not an automatic signal.
1×1 unit = 0 auto-scales to the swing; set it above 0 to fix a manual ticks-per-bar Gann unit.
Toggle the Gann fan, Fibonacci fan, retracement, zone shading, glow, and table independently in settings.

Disclaimer

For educational and informational purposes only. This script plots geometric levels and a mechanical summary of price position. It is not financial advice, not a recommendation to buy or sell, and offers no guarantee of future performance. Always do your own research and manage your risk.

## Source Code

````pine
//@version=6
// =============================================================================
//  Adaptive Gann & Fibonacci Confluence
//
//  WHAT IT DOES
//  Automatically detects the dominant swing on the current chart — the highest
//  high and lowest low over a configurable lookback — and projects three
//  classic geometric tools from that single shared anchor so their levels can
//  be read together:
//    1. A Gann fan whose 1x1 (trend-balance) angle is scaled to the swing's
//       real price-per-bar, with the other angles as exact integer ratios.
//    2. A Fibonacci fan drawn from the same origin.
//    3. Fibonacci retracement levels across the swing, with shaded zones.
//
//  WHY THESE TOOLS ARE COMBINED (rationale for the mashup)
//  A Gann fan measures trend SLOPE — the geometric balance between price and
//  time. Fibonacci retracements measure pullback DEPTH — proportional price
//  levels within a move. Plotted separately they use different anchors and
//  rarely align. By forcing both to share one auto-detected swing, the script
//  highlights price areas where a Gann angle and a Fibonacci level coincide.
//  Those confluence points are the intended signal: a location supported by
//  both slope geometry and proportional retracement is more meaningful than a
//  level produced by either method on its own.
//
//  HOW THE COMPONENTS WORK TOGETHER
//  All three overlays are anchored to the same swing origin and direction, so
//  the Gann rays and the Fibonacci levels are directly comparable on the chart.
//  Watch for a fan ray crossing a retracement level near the same price — that
//  overlap is the confluence the tool is built to expose. The snapshot table
//  distills this into bias, nearest support/resistance, retracement depth and a
//  mechanical read of where price sits in the swing.
//
//  UNIVERSAL ACROSS MARKETS
//  Swing detection runs on user-selectable price sources (High Source / Low
//  Source inputs). Defaults are the bar high and low, but any series can be
//  chosen from the dropdown — e.g. close, hl2, or even the output of another
//  indicator on the chart. Because the 1x1 Gann unit is derived from the
//  swing's own price-per-bar, the geometry self-scales to any instrument,
//  price magnitude and timeframe (stocks, futures, forex, crypto, indices).
//
//  HOW TO USE
//  - Set "Swing lookback" to the structure you trade (smaller = recent swings,
//    larger = higher-timeframe structure).
//  - Optionally change "High Source" / "Low Source" to feed the swing engine a
//    different series so the tool fits the asset/data you are analysing.
//  - The gold line is the 1x1 angle; reactions to it gauge trend strength.
//  - Use confluence (ray meets level) as areas of interest, not as signals.
//  - "1x1 unit" = 0 auto-scales to the swing; set > 0 to fix a ticks-per-bar
//    Gann unit manually.
//
//  ORIGINALITY
//  The Gann fan derives its 1x1 unit from the swing's actual price-per-bar
//  rather than fixed chart degrees, so the angles remain consistent across
//  instruments and timeframes. It is rendered together with Fibonacci fan and
//  retracement geometry on a single auto-updating anchor, with confluence
//  surfaced visually and summarized in a live table.
//
//  DISCLAIMER
//  For educational and informational purposes only. This script plots geometric
//  levels and a mechanical summary of price position. It is NOT financial
//  advice, NOT a recommendation to buy or sell any instrument, and offers no
//  guarantee of future performance. Always do your own research and manage risk.
// =============================================================================

indicator("Adaptive Gann & Fibonacci Confluence", overlay = true,
     max_lines_count = 500, max_labels_count = 100)

// ---------------- Inputs ----------------
gA = "Swing Detection"
lookback     = input.int(250, "Swing lookback (bars)", minval = 20, group = gA)
projBars     = input.int(120, "Projection (bars)", minval = 10, group = gA)

gD = "Data Source"
srcHigh      = input.source(high, "High source (swing top)", group = gD,
     tooltip = "Series used to find the swing high. Default = bar high. Pick any series (close, hl2, or another indicator) so the tool fits the asset/market you trade.")
srcLow       = input.source(low,  "Low source (swing bottom)", group = gD,
     tooltip = "Series used to find the swing low. Default = bar low.")

gG = "Gann Fan"
showGann     = input.bool(true, "Show Gann fan", group = gG)
pointsPerBar = input.float(0.0, "1x1 unit (0 = auto, >0 = ticks/bar)", minval = 0.0, group = gG)

gF = "Fibonacci"
showFibFan   = input.bool(true, "Show Fibonacci fan", group = gF)
showFibRet   = input.bool(true, "Show Fibonacci retracement", group = gF)
shadeZones   = input.bool(true, "Shade retracement zones", group = gF)

gV = "Visuals"
bullCol      = input.color(#089981, "Bull color", group = gV)
bearCol      = input.color(#f23645, "Bear color", group = gV)
masterCol    = input.color(#ffd700, "1x1 master color", group = gV)
glow         = input.bool(true,  "Glow effect", inline = "glow", group = gV)
glowStrength = input.float(0.85, "strength", inline = "glow", minval = 0.2, maxval = 1.6, step = 0.05, group = gV,
     tooltip = "Density of the glow halo behind each line. A single instance at the default (~0.85) approximates the look of running the script twice, but with slightly less glow. Lower = thinner/softer glow, higher = bolder.")
showLabels   = input.bool(true,  "Show labels", group = gV)
showTable    = input.bool(true,  "Show snapshot table", group = gV)
tblPosStr    = input.string("Top Right", "Table position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gV)
uiTheme      = input.string("Auto (match chart)", "Color theme",
     options = ["Auto (match chart)", "Dark", "Light"], group = gV,
     tooltip = "Auto reads the chart background brightness and adapts the table, line and label colors so everything stays legible on light, dark or colored backgrounds. The gold 1x1 line is automatically darkened on light backgrounds (plain yellow is invisible on white). Dark/Light force a scheme.")

f_pos(s) =>
    switch s
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Middle Right"  => position.middle_right
        => position.top_right

// ---------------- Theme-adaptive palette ----------------
// "Auto" reads the chart background brightness (luma) and flips between a dark
// and a light scheme so the table, lines and labels keep contrast on any
// background. Table cells are fully opaque; line/label colors are deepened on
// light backgrounds (the gold 1x1 especially, since pure yellow vanishes there).
_uiBg   = chart.bg_color
_uiLuma = na(_uiBg) ? 0.0 : color.r(_uiBg) * 0.299 + color.g(_uiBg) * 0.587 + color.b(_uiBg) * 0.114
uiDark  = uiTheme == "Dark" ? true : uiTheme == "Light" ? false : (na(_uiBg) or _uiLuma < 140)

// Table palette
cHdr    = uiDark ? color.rgb(13, 27, 42)    : color.rgb(222, 230, 241)
cSub    = uiDark ? color.rgb(22, 27, 34)    : color.rgb(233, 237, 242)
cTxt    = uiDark ? color.rgb(226, 232, 240) : color.rgb(20, 26, 38)
cDim    = uiDark ? color.rgb(139, 148, 158) : color.rgb(92, 100, 112)
uiFrame = uiDark ? color.rgb(42, 52, 88)    : color.rgb(196, 204, 212)
uiBord  = uiDark ? color.rgb(26, 34, 56)    : color.rgb(210, 216, 224)
uiPanel = uiDark ? color.rgb(10, 14, 26)    : color.rgb(244, 246, 248)

// Drawing colors: keep the user's colors on dark; deepen toward black on light
// so saturated lines/labels read against a pale chart.
uiBull   = uiDark ? bullCol   : color.from_gradient(0.22, 0.0, 1.0, bullCol, color.black)
uiBear   = uiDark ? bearCol   : color.from_gradient(0.18, 0.0, 1.0, bearCol, color.black)
uiWarn   = uiDark ? color.rgb(227, 179, 65) : color.rgb(176, 120, 0)
// Gold 1x1 needs a heavier darken on light (pure yellow has almost no contrast on white).
effMaster = uiDark ? masterCol : color.from_gradient(0.45, 0.0, 1.0, masterCol, color.black)
// Faint backing chip behind labels so text reads over candles/grid of any color.
labelBg  = uiDark ? color.new(color.rgb(10, 14, 26), 25) : color.new(color.rgb(244, 246, 248), 18)

// ---------------- Ratio sets ----------------
var gannRatios = array.from(8.0, 4.0, 3.0, 2.0, 1.0, 0.5, 1.0 / 3.0, 0.25, 0.125)
var gannNames  = array.from("1x8", "1x4", "1x3", "1x2", "1x1", "2x1", "3x1", "4x1", "8x1")
var fibRatios  = array.from(0.236, 0.382, 0.5, 0.618, 0.786)
var fibRetLv   = array.from(0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0)

// ---------------- Rolling extremes (on user-selected sources) ----------------
hh     = ta.highest(srcHigh, lookback)
ll     = ta.lowest(srcLow, lookback)
hhBack = - ta.highestbars(srcHigh, lookback)
llBack = - ta.lowestbars(srcLow, lookback)

// ---------------- Object storage ----------------
var line[]     L  = array.new<line>()
var label[]    LB = array.new<label>()
var linefill[] LF = array.new<linefill>()

// ---------------- Cached swing state (for the live table) ----------------
var float cHiP = na
var float cLoP = na
var int   cHiT = na
var int   cLoT = na
var bool  vUp = false
var float vOriginP = na
var float vTargetP = na
var float vUnit = na

clearAll() =>
    for x in L
        line.delete(x)
    L.clear()
    for x in LB
        label.delete(x)
    LB.clear()
    for x in LF
        linefill.delete(x)
    LF.clear()

// Draw a line with optional glow halo (two wider semi-transparent underlays).
// Halo opacity scales with glowStrength; the default makes one instance look
// close to running the script twice, but with slightly less glow spread.
f_line(int x1, float y1, int x2, float y2, color col, int w, string st, string ext) =>
    if glow
        int outerT = int(math.min(95, math.max(20, math.round(100 - 19 * glowStrength))))
        int innerT = int(math.min(92, math.max(18, math.round(100 - 36 * glowStrength))))
        L.push(line.new(x1, y1, x2, y2, xloc = xloc.bar_time, extend = ext, color = color.new(col, outerT), width = w + 4))
        L.push(line.new(x1, y1, x2, y2, xloc = xloc.bar_time, extend = ext, color = color.new(col, innerT), width = w + 2))
    L.push(line.new(x1, y1, x2, y2, xloc = xloc.bar_time, extend = ext, color = col, width = w, style = st))
    L.get(L.size() - 1)

f_label(int x, float y, string txt, color tc, string sz) =>
    if showLabels
        LB.push(label.new(x, y, txt, xloc = xloc.bar_time, style = label.style_label_left,
             size = sz, textcolor = tc, color = labelBg))

// ---------------- Snapshot table ----------------
var table tbl = table.new(f_pos(tblPosStr), 2, 7, border_width = 1, frame_width = 1)

// ---------------- Build geometry (last bar, only when the swing changes) -----
if barstate.islast and not na(hh) and not na(ll)
    int   hiT = time[hhBack]
    int   loT = time[llBack]
    int   hiIdx = bar_index - hhBack
    int   loIdx = bar_index - llBack
    float hiP = hh
    float loP = ll

    bool dirty = na(cHiT) or hiT != cHiT or loT != cLoT or hiP != cHiP or loP != cLoP

    if dirty
        clearAll()
        cHiT := hiT
        cLoT := loT
        cHiP := hiP
        cLoP := loP

        bool  up         = loIdx >= hiIdx
        float originP    = up ? loP : hiP
        int   originT    = up ? loT : hiT
        float targetP    = up ? hiP : loP
        float rng        = math.abs(hiP - loP)
        int   span       = math.max(1, math.abs(hiIdx - loIdx))
        float unitPerBar = pointsPerBar > 0.0 ? pointsPerBar * syminfo.mintick : rng / span
        color dirCol     = up ? uiBull : uiBear

        vUp := up
        vOriginP := originP
        vTargetP := targetP
        vUnit := unitPerBar

        int secMs    = timeframe.in_seconds() * 1000
        int endT     = originT + projBars * secMs
        int swStartT = math.min(hiT, loT)
        int rightT   = time + projBars * secMs

        // ---- Gann fan (trend-colored, gold 1x1, graduated widths) ----
        if showGann
            for i = 0 to array.size(gannRatios) - 1
                float r     = array.get(gannRatios, i)
                float shift = unitPerBar * r * projBars
                float yEnd  = up ? originP + shift : originP - shift
                bool  is1x1 = r == 1.0
                bool  isMaj = r == 2.0 or r == 0.5
                color col   = is1x1 ? effMaster : dirCol
                int   w     = is1x1 ? 3 : (isMaj ? 2 : 1)
                f_line(originT, originP, endT, yEnd, col, w, line.style_solid, extend.right)
                f_label(endT, yEnd, array.get(gannNames, i), col, is1x1 ? size.normal : size.small)

        // ---- Fibonacci fan ----
        if showFibFan
            for i = 0 to array.size(fibRatios) - 1
                float r     = array.get(fibRatios, i)
                float shift = rng * r / span * projBars
                float yEnd  = up ? originP + shift : originP - shift
                f_line(originT, originP, endT, yEnd, color.new(dirCol, 20), 1, line.style_dashed, extend.right)
                f_label(endT, yEnd, str.tostring(r * 100, "#.#") + "%", dirCol, size.tiny)

        // ---- Fibonacci retracement + shaded zones ----
        if showFibRet
            line prevLine = na
            for i = 0 to array.size(fibRetLv) - 1
                float r    = array.get(fibRetLv, i)
                float lvl  = originP + (targetP - originP) * r
                bool  key  = r == 0.0 or r == 1.0 or r == 0.5
                bool  gold = r == 0.618 or r == 0.382
                int   w    = key ? 3 : (gold ? 2 : 1)
                string st  = key ? line.style_solid : line.style_dotted
                line ln = f_line(swStartT, lvl, rightT, lvl, color.new(dirCol, 10), w, st, extend.none)
                f_label(rightT, lvl, str.tostring(r * 100, "#.#") + "%  " + str.tostring(math.round_to_mintick(lvl)), dirCol, size.small)
                if shadeZones and not na(prevLine)
                    LF.push(linefill.new(prevLine, ln, color.new(dirCol, 93)))
                prevLine := ln

// ---------------- Live snapshot (compact, every last bar) --------------------
if barstate.islast and showTable and not na(vOriginP) and not na(vTargetP)
    float price = close
    float den   = vTargetP - vOriginP
    float posPct = den != 0 ? (price - vOriginP) / den : 0.5

    float resist = na
    float supp   = na
    for i = 0 to array.size(fibRetLv) - 1
        float lv = vOriginP + (vTargetP - vOriginP) * array.get(fibRetLv, i)
        if lv > price
            resist := na(resist) ? lv : math.min(resist, lv)
        if lv < price
            supp := na(supp) ? lv : math.max(supp, lv)

    string actTxt = ""
    color  sigCol = cDim
    if vUp
        if posPct >= 0.5
            actTxt := "Trend up · favor longs"
            sigCol := uiBull
        else if posPct >= 0.236
            actTxt := "Pullback · watch support"
            sigCol := uiBull
        else
            actTxt := "Deep pullback · caution"
            sigCol := uiWarn
    else
        if posPct >= 0.5
            actTxt := "Trend down · favor shorts"
            sigCol := uiBear
        else if posPct >= 0.236
            actTxt := "Bounce · watch resistance"
            sigCol := uiBear
        else
            actTxt := "Deep bounce · caution"
            sigCol := uiWarn

    color hdrCol = vUp ? uiBull : uiBear
    table.set_bgcolor(tbl, uiPanel)
    table.set_frame_color(tbl, uiFrame)
    table.set_border_color(tbl, uiBord)
    table.cell(tbl, 0, 0, "GANN · FIB", text_color = color.white, text_size = size.small, bgcolor = color.new(hdrCol, 0))
    table.merge_cells(tbl, 0, 0, 1, 0)
    table.cell(tbl, 0, 1, "Bias",  text_color = cDim, text_size = size.small, bgcolor = cSub)
    table.cell(tbl, 1, 1, vUp ? "▲ Up" : "▼ Down", text_color = hdrCol, text_size = size.small, bgcolor = cSub)
    table.cell(tbl, 0, 2, "Price", text_color = cDim, text_size = size.small, bgcolor = cSub)
    table.cell(tbl, 1, 2, str.tostring(math.round_to_mintick(price)), text_color = cTxt, text_size = size.small, bgcolor = cSub)
    table.cell(tbl, 0, 3, "Res",   text_color = cDim, text_size = size.small, bgcolor = cSub)
    table.cell(tbl, 1, 3, na(resist) ? "—" : str.tostring(math.round_to_mintick(resist)), text_color = uiBear, text_size = size.small, bgcolor = cSub)
    table.cell(tbl, 0, 4, "Sup",   text_color = cDim, text_size = size.small, bgcolor = cSub)
    table.cell(tbl, 1, 4, na(supp) ? "—" : str.tostring(math.round_to_mintick(supp)), text_color = uiBull, text_size = size.small, bgcolor = cSub)
    table.cell(tbl, 0, 5, "Retr",  text_color = cDim, text_size = size.small, bgcolor = cSub)
    table.cell(tbl, 1, 5, str.tostring(math.round(posPct * 100, 1)) + "%", text_color = cTxt, text_size = size.small, bgcolor = cSub)
    table.cell(tbl, 0, 6, actTxt,  text_color = sigCol, text_size = size.small, bgcolor = cSub)
    table.merge_cells(tbl, 0, 6, 1, 6)
````
