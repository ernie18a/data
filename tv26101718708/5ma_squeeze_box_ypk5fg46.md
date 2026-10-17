# 5ma Squeeze Box

- url: https://www.tradingview.com/script/ypk5FG46-5ma-Squeeze-Box/
- type: indicator
- pine_id: PUB;49134575251d4cc7811b61e7e82fe167
- version: 1.0

## Description

shows two boxes defined by (x%)atr of the 5ma spreads.  First box engulfs the smoothed ALMA or Jurik 13, 34, 55 period MAs, the second engulfs the 55, 89, 144 period MAs

Vertical lines show slope confluence of 13, 34, 55, 89 MAs with a CCI gate.

## Source Code

````pine
//@version=6
indicator("AJ DUAL BOX TEST v6", overlay=true, max_boxes_count=500, max_lines_count=500)


// ═══════════════════════════════════════════════════════════════
// MA TYPE
// ═══════════════════════════════════════════════════════════════

maType     = input.string("ALMA", "MA Type", options=["ALMA","Jurik","Hull"], group="MA SETTINGS")
almaOffset = input.float(0.85, "ALMA Offset", minval=0, maxval=1, step=0.05,  group="MA SETTINGS")
almaSigma  = input.int(6,   "ALMA Sigma",  minval=1, maxval=20,               group="MA SETTINGS")
jurikPhase = input.int(100, "Jurik Phase", minval=-100, maxval=100,            group="MA SETTINGS")


// ═══════════════════════════════════════════════════════════════
// MA VISIBILITY
// ═══════════════════════════════════════════════════════════════

show13  = input.bool(true,  "Show MA 13",  group="MA PLOTS")
show34  = input.bool(true,  "Show MA 34",  group="MA PLOTS")
show55  = input.bool(true,  "Show MA 55",  group="MA PLOTS")
show89  = input.bool(true,  "Show MA 89",  group="MA PLOTS")
show144 = input.bool(true,  "Show MA 144", group="MA PLOTS")

col13  = input.color(color.new(#00ffcc, 35), "MA 13 Color",  group="MA PLOTS")
col34  = input.color(color.new(#00ff44, 35), "MA 34 Color",  group="MA PLOTS")
col55  = input.color(color.new(#ffaa00, 35), "MA 55 Color",  group="MA PLOTS")
col89  = input.color(color.new(#ff6d00, 35), "MA 89 Color",  group="MA PLOTS")
col144 = input.color(color.new(#ff2b00, 35), "MA 144 Color", group="MA PLOTS")
lw     = input.int(1, "Line Width", minval=1, maxval=5,       group="MA PLOTS")

// ═══════════════════════════════════════════════════════════════
// SMOOTHING (second pass of the selected MA type, like 3MA·x)
// ═══════════════════════════════════════════════════════════════

gSm    = "SMOOTHING"
smOn   = input.bool(true, "Enable Smoothing", group=gSm, tooltip="Runs a second pass of the selected MA type over each MA (e.g. ALMA-of-ALMA). Like the HMA-of-HMA smoothing in 3MA·x.")
sm13   = input.int(13, "Smooth 13",  minval=1, group=gSm)
sm34   = input.int(17, "Smooth 34",  minval=1, group=gSm)
sm55   = input.int(21, "Smooth 55",  minval=1, group=gSm)
sm89   = input.int(21, "Smooth 89",  minval=1, group=gSm)
sm144  = input.int(21, "Smooth 144", minval=1, group=gSm)


// ═══════════════════════════════════════════════════════════════
// BOX A  (default 13/34/55)
// ═══════════════════════════════════════════════════════════════

gA      = "BOX A"
onA     = input.bool(true,  "Enable Box A?",       group=gA)
a13     = input.bool(true,  "A: Include 13",       group=gA, inline="aInc1")
a34     = input.bool(true,  "A: Include 34",       group=gA, inline="aInc1")
a55     = input.bool(true,  "A: Include 55",       group=gA, inline="aInc2")
a89     = input.bool(false, "A: Include 89",       group=gA, inline="aInc2")
a144    = input.bool(false, "A: Include 144",      group=gA, inline="aInc3")
tolA    = input.float(1.9,  "A: Tolerance × ATR", step=0.1, minval=0.1, group=gA)
atrLenA = input.int(55,     "A: ATR Length",       minval=1,            group=gA)
minBarsA= input.int(3,      "A: Min Squeeze Bars", minval=1,            group=gA)
gapTolA = input.int(0,      "A: Gap Tolerance",    minval=0, maxval=50, group=gA)
fillA   = input.color(color.new(#2196f3, 50), "A: Fill",   group=gA)
brdA    = input.color(#ffffff,                "A: Border", group=gA)
brdWA   = input.int(2, "A: Border Width", minval=1, maxval=5, group=gA)


// ═══════════════════════════════════════════════════════════════
// BOX B  (default 55/89/144)
// ═══════════════════════════════════════════════════════════════

gB      = "BOX B"
onB     = input.bool(true,  "Enable Box B?",       group=gB)
b13     = input.bool(false, "B: Include 13",       group=gB, inline="bInc1")
b34     = input.bool(false, "B: Include 34",       group=gB, inline="bInc1")
b55     = input.bool(true,  "B: Include 55",       group=gB, inline="bInc2")
b89     = input.bool(true,  "B: Include 89",       group=gB, inline="bInc2")
b144    = input.bool(true,  "B: Include 144",      group=gB, inline="bInc3")
tolB    = input.float(1.9,  "B: Tolerance × ATR", step=0.1, minval=0.1, group=gB)
atrLenB = input.int(55,     "B: ATR Length",       minval=1,            group=gB)
minBarsB= input.int(3,      "B: Min Squeeze Bars", minval=1,            group=gB)
gapTolB = input.int(0,      "B: Gap Tolerance",    minval=0, maxval=50, group=gB)
fillB   = input.color(color.new(#e040fb, 50), "B: Fill",   group=gB)
brdB    = input.color(#e040fb,                "B: Border", group=gB)
brdWB   = input.int(2, "B: Border Width", minval=1, maxval=5, group=gB)

showTbl = input.bool(false, "Show Debug Table?", group="DEBUG")


// ═══════════════════════════════════════════════════════════════
// MA FUNCTIONS
// ═══════════════════════════════════════════════════════════════

f_jurik(float src, int len, int ph) =>
    var float jma = na
    var float e0  = 0.0
    var float e1  = 0.0
    var float e2  = 0.0
    float phaseRatio = ph < -100 ? 0.5 : ph > 100 ? 2.5 : ph / 100.0 + 1.5
    float beta  = 0.45 * (len - 1) / (0.45 * (len - 1) + 2)
    float alpha = math.pow(beta, phaseRatio)
    e0 := (1.0 - alpha) * src + alpha * nz(e0[1])
    e1 := (src - e0) * (1.0 - beta) + beta * nz(e1[1])
    e2 := (e0 + phaseRatio * e1 - nz(jma[1])) * math.pow(1.0 - alpha, 2.0) + math.pow(alpha, 2.0) * nz(e2[1])
    jma := e2 + nz(jma[1])
    jma

f_ma(float src, int len) =>
    maType == "ALMA" ? ta.alma(src, len, almaOffset, almaSigma) :
     maType == "Hull" ? ta.hma(src, len) :
     f_jurik(src, len, jurikPhase)


// ═══════════════════════════════════════════════════════════════
// MAs
// ═══════════════════════════════════════════════════════════════

ma13  = smOn ? f_ma(f_ma(close, 13),  sm13)  : f_ma(close, 13)
ma34  = smOn ? f_ma(f_ma(close, 34),  sm34)  : f_ma(close, 34)
ma55  = smOn ? f_ma(f_ma(close, 55),  sm55)  : f_ma(close, 55)
ma89  = smOn ? f_ma(f_ma(close, 89),  sm89)  : f_ma(close, 89)
ma144 = smOn ? f_ma(f_ma(close, 144), sm144) : f_ma(close, 144)

plot(show13  ? ma13  : na, "MA 13",  col13,  linewidth=lw)
plot(show34  ? ma34  : na, "MA 34",  col34,  linewidth=lw)
plot(show55  ? ma55  : na, "MA 55",  col55,  linewidth=lw)
plot(show89  ? ma89  : na, "MA 89",  col89,  linewidth=lw)
plot(show144 ? ma144 : na, "MA 144", col144, linewidth=lw)


// ═══════════════════════════════════════════════════════════════
// CLUSTER SPAN HELPER — min-to-max of the selected MAs
// ═══════════════════════════════════════════════════════════════

f_span(bool u13, bool u34, bool u55, bool u89, bool u144) =>
    a = array.new<float>(0)
    if u13 and not na(ma13)
        array.push(a, ma13)
    if u34 and not na(ma34)
        array.push(a, ma34)
    if u55 and not na(ma55)
        array.push(a, ma55)
    if u89 and not na(ma89)
        array.push(a, ma89)
    if u144 and not na(ma144)
        array.push(a, ma144)
    int   c  = array.size(a)
    float hi = c >= 2 ? array.max(a) : na
    float lo = c >= 2 ? array.min(a) : na
    [c, hi, lo]


// ═══════════════════════════════════════════════════════════════
// BOX A — detection + history
// ═══════════════════════════════════════════════════════════════

[cntA, hiA, loA] = f_span(a13, a34, a55, a89, a144)
spanA   = cntA >= 2 ? hiA - loA : na
atrA    = ta.atr(atrLenA)
activeA = onA and cntA >= 2 and not na(spanA) and not na(atrA) and spanA <= atrA * tolA and spanA > 0

var int   runA      = 0
runA := activeA ? runA + 1 : 0
squeezeA = runA >= minBarsA

var float sqzHiA    = 0.0
var float sqzLoA    = 0.0
var int   sqzStartA = 0
if activeA
    if runA == 1
        sqzHiA    := hiA
        sqzLoA    := loA
        sqzStartA := bar_index
    else
        sqzHiA := math.max(sqzHiA, hiA)
        sqzLoA := math.min(sqzLoA, loA)

var box bxA    = na
var int gapRunA = 0
if onA
    if squeezeA
        gapRunA := 0
        if na(bxA)
            bxA := box.new(sqzStartA, sqzHiA, bar_index, sqzLoA, bgcolor=fillA, border_color=brdA, border_width=brdWA)
        else
            bxA.set_top(sqzHiA)
            bxA.set_bottom(sqzLoA)
            bxA.set_right(bar_index)
    else if not na(bxA)
        gapRunA := gapRunA + 1
        if gapRunA > gapTolA
            bxA.set_right(bar_index - gapRunA)
            bxA     := na
            gapRunA := 0


// ═══════════════════════════════════════════════════════════════
// BOX B — detection + history
// ═══════════════════════════════════════════════════════════════

[cntB, hiB, loB] = f_span(b13, b34, b55, b89, b144)
spanB   = cntB >= 2 ? hiB - loB : na
atrB    = ta.atr(atrLenB)
activeB = onB and cntB >= 2 and not na(spanB) and not na(atrB) and spanB <= atrB * tolB and spanB > 0

var int   runB      = 0
runB := activeB ? runB + 1 : 0
squeezeB = runB >= minBarsB

var float sqzHiB    = 0.0
var float sqzLoB    = 0.0
var int   sqzStartB = 0
if activeB
    if runB == 1
        sqzHiB    := hiB
        sqzLoB    := loB
        sqzStartB := bar_index
    else
        sqzHiB := math.max(sqzHiB, hiB)
        sqzLoB := math.min(sqzLoB, loB)

var box bxB    = na
var int gapRunB = 0
if onB
    if squeezeB
        gapRunB := 0
        if na(bxB)
            bxB := box.new(sqzStartB, sqzHiB, bar_index, sqzLoB, bgcolor=fillB, border_color=brdB, border_width=brdWB)
        else
            bxB.set_top(sqzHiB)
            bxB.set_bottom(sqzLoB)
            bxB.set_right(bar_index)
    else if not na(bxB)
        gapRunB := gapRunB + 1
        if gapRunB > gapTolB
            bxB.set_right(bar_index - gapRunB)
            bxB     := na
            gapRunB := 0


// ═══════════════════════════════════════════════════════════════
// DEBUG TABLE (toggle)
// ═══════════════════════════════════════════════════════════════

var tbl = table.new(position.top_right, 3, 6, bgcolor=color.new(color.black, 80))
if showTbl and barstate.islast
    table.cell(tbl, 0, 0, "",        text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 0, "A",       text_color=color.aqua,  text_size=size.small)
    table.cell(tbl, 2, 0, "B",       text_color=color.fuchsia, text_size=size.small)
    table.cell(tbl, 0, 1, "cnt",     text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 1, str.tostring(cntA), text_color=color.white, text_size=size.small)
    table.cell(tbl, 2, 1, str.tostring(cntB), text_color=color.white, text_size=size.small)
    table.cell(tbl, 0, 2, "span",    text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 2, str.tostring(spanA, "#.#####"), text_color=color.red, text_size=size.small)
    table.cell(tbl, 2, 2, str.tostring(spanB, "#.#####"), text_color=color.red, text_size=size.small)
    table.cell(tbl, 0, 3, "atr×tol", text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 3, str.tostring(atrA * tolA, "#.#####"), text_color=color.green, text_size=size.small)
    table.cell(tbl, 2, 3, str.tostring(atrB * tolB, "#.#####"), text_color=color.green, text_size=size.small)
    table.cell(tbl, 0, 4, "active",  text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 4, str.tostring(activeA), text_color=color.yellow, text_size=size.small)
    table.cell(tbl, 2, 4, str.tostring(activeB), text_color=color.yellow, text_size=size.small)
    table.cell(tbl, 0, 5, "run",     text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 5, str.tostring(runA), text_color=color.blue, text_size=size.small)
    table.cell(tbl, 2, 5, str.tostring(runB), text_color=color.blue, text_size=size.small)


// ═══════════════════════════════════════════════════════════════
// MA SLOPE ALIGNMENT + CCI WEIGHT
// ═══════════════════════════════════════════════════════════════
// All MAs sloping the same way = alignment. Two tiers:
//   5-MA  = 13/34/55/89/144 all agree
//   4-MA  = 13/34/55/89 agree (144 excluded — fires earlier)
// CCI never gates — it WEIGHTS the signal and STYLES the vline.

gAln   = "ALIGNMENT"
alnOn  = input.bool(true,  "Enable Alignment Signals", group=gAln)
showVL5 = input.bool(false, "Show 5-MA Vline", group=gAln, tooltip="5-MA tier kept for scan/alert, vline off by default. Toggle on to use it.")
showVL4 = input.bool(true,  "Show 4-MA Vline", group=gAln)
cd5    = input.int(5, "5-MA Vline Cooldown (bars)", minval=0, maxval=500, group=gAln, tooltip="Min bars between 5-MA vlines. 0 = every aligned bar.")
cd4    = input.int(5, "4-MA Vline Cooldown (bars)", minval=0, maxval=500, group=gAln, tooltip="Min bars between 4-MA vlines. 0 = every aligned bar.")

gCCI   = "ALIGNMENT — CCI"
cciLen = input.int(5,    "CCI Length", minval=1, group=gCCI)
cciSrc = input.source(hlc3, "CCI Source", group=gCCI)
cciThr = input.float(100, "CCI Threshold", minval=0, step=5, group=gCCI, tooltip="When |CCI| ≥ this, vline draws in STRONG style and weight gets the bonus.")
wtBonus = input.float(50, "Threshold Weight Bonus", minval=0, step=5, group=gCCI, tooltip="Added to |weight| when |CCI| ≥ threshold.")

gVStyle = "ALIGNMENT — VLINE STYLE"
// strong (CCI meets threshold)
vlStrongUp = input.color(#00e676, "Strong Bull Color", group=gVStyle)
vlStrongDn = input.color(#ff1744, "Strong Bear Color", group=gVStyle)
vlStrongW  = input.int(2, "Strong Width", minval=1, maxval=5, group=gVStyle)
// weak (below threshold)
vlWeakUp   = input.color(color.new(#00e676, 60), "Weak Bull Color", group=gVStyle)
vlWeakDn   = input.color(color.new(#ff1744, 60), "Weak Bear Color", group=gVStyle)
vlWeakW    = input.int(1, "Weak Width", minval=1, maxval=5, group=gVStyle)
vl5Style   = input.string("Solid",  "5-MA Line Style", options=["Solid","Dashed","Dotted"], group=gVStyle)
vl4Style   = input.string("Dotted", "4-MA Line Style", options=["Solid","Dashed","Dotted"], group=gVStyle)

f_vstyle(_s) =>
    _s == "Dashed" ? line.style_dashed : _s == "Dotted" ? line.style_dotted : line.style_solid

vl5StyleV = f_vstyle(vl5Style)
vl4StyleV = f_vstyle(vl4Style)

// ── Slopes (1-bar)
up13  = ma13  > ma13[1]
up34  = ma34  > ma34[1]
up55  = ma55  > ma55[1]
up89  = ma89  > ma89[1]
up144 = ma144 > ma144[1]
dn13  = ma13  < ma13[1]
dn34  = ma34  < ma34[1]
dn55  = ma55  < ma55[1]
dn89  = ma89  < ma89[1]
dn144 = ma144 < ma144[1]

// ── Alignment tiers
bull5 = up13 and up34 and up55 and up89 and up144
bear5 = dn13 and dn34 and dn55 and dn89 and dn144
bull4 = up13 and up34 and up55 and up89
bear4 = dn13 and dn34 and dn55 and dn89

align5 = bull5 or bear5
align4 = bull4 or bear4

// ── CCI + weight
cci      = ta.cci(cciSrc, cciLen)
strong   = math.abs(cci) >= cciThr
// signed CCI, plus bonus when threshold met (all float to avoid type-inference issues)
float bonus5 = strong ? (cci >= 0 ? wtBonus : -wtBonus) : 0.0
float bonus4 = bonus5
float wt5 = align5 ? cci + bonus5 : na
float wt4 = align4 ? cci + bonus4 : na

// ── Vlines, cooldown-gated (style/color by threshold + direction)
var int last5 = -100000
var int last4 = -100000

fire5 = alnOn and showVL5 and align5 and (cd5 == 0 or bar_index - last5 > cd5)
fire4 = alnOn and showVL4 and align4 and (cd4 == 0 or bar_index - last4 > cd4)

if fire5
    col5 = bull5 ? (strong ? vlStrongUp : vlWeakUp) : (strong ? vlStrongDn : vlWeakDn)
    w5   = strong ? vlStrongW : vlWeakW
    line.new(bar_index, low, bar_index, high, xloc=xloc.bar_index, extend=extend.both, color=col5, width=w5, style=vl5StyleV)
    last5 := bar_index

if fire4
    col4 = bull4 ? (strong ? vlStrongUp : vlWeakUp) : (strong ? vlStrongDn : vlWeakDn)
    w4   = strong ? vlStrongW : vlWeakW
    line.new(bar_index, low, bar_index, high, xloc=xloc.bar_index, extend=extend.both, color=col4, width=w4, style=vl4StyleV)
    last4 := bar_index

// ── Scan feeds (weight-ready, hidden)
plot(alnOn ? (align5 ? 1 : 0) : na, "SCAN Align5",  display=display.none)
plot(alnOn ? (align4 ? 1 : 0) : na, "SCAN Align4",  display=display.none)
plot(alnOn ? nz(wt5) : na,          "SCAN Weight5", display=display.none)
plot(alnOn ? nz(wt4) : na,          "SCAN Weight4", display=display.none)

// ── Alerts
alertcondition(bull5, "5-MA Bull Align", "All 5 MAs sloping up")
alertcondition(bear5, "5-MA Bear Align", "All 5 MAs sloping down")
alertcondition(bull4 and not bull5, "4-MA Bull Align", "13/34/55/89 sloping up (144 lagging)")
alertcondition(bear4 and not bear5, "4-MA Bear Align", "13/34/55/89 sloping down (144 lagging)")
````
