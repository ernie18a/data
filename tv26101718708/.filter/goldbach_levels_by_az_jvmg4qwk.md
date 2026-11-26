# Goldbach Levels by AZ

- url: https://www.tradingview.com/script/jVmg4qWK-Goldbach-Levels-by-AZ/
- type: indicator
- pine_id: PUB;5f80e0b46eb94a6cbf27e334474e480a
- version: 1.0

## Description

GOLDBACH LEVELS — dealing-range grid

Draws a Power-of-Three (PO3) dealing range and its Goldbach partition levels, colour-coded by layer, with a read-out of where price sits in the range.

WHAT IT DRAWS

A dealing range is a fixed block of price, sized by a PO3 number (27, 81, 243, 729, 2187, 6561), anchored so that the range low is an exact multiple of that number. Inside the range the script marks the Goldbach percentage levels:

0 · 3 · 7 · 11 · 17 · 23 · 29 · 35 · 41 · 47 · 50 · 53 · 59 · 65 · 71 · 77 · 83 · 89 · 93 · 97 · 100

These are grouped into three layers, each with its own colour and light shading:

LIQUIDITY (0–17 and 83–100): rejection block 3/97, last line of defence 7/93, order block 11/89, and the inversion point 17/83
FLOW (23–35 and 65–77): the sweet spot 29/71 and the non-Goldbach levels either side of it
REBALANCE (41–59): internal rebalance 41/59, internal rejection 47/53, equilibrium 50

The 6% blocks between layers (17–23, 35–41, 59–65, 77–83) contain no named level and are left unshaded. The read-out reports them as DEAD ZONE.

Because every PO3 is three times the previous one, ranges of different sizes nest exactly. The 729 on a 1-minute chart and the 729 shown as the parent on a 5-minute chart are the same grid.

CHOOSING THE RANGE SIZE

Four modes:

Auto by volatility (default): picks the PO3 whose 6% block takes about five bars of the current chart to cross, using a slow ATR. The choice is locked for the trading day and only moves when volatility has clearly shifted, so levels never jump mid-session. Different timeframes land on different sizes, and each chart's parent range is the next chart's working range.
Auto by timeframe: a fixed table — 1m/5m 27, 15m 81, 1H 243, 4H and daily 729, weekly 2187, monthly 6561.
Manual: any PO3 number.
Fractal: the working range becomes the layer band of a larger parent range that price is currently in, subdivided with the same Goldbach partition. Cut the parent by layer band or by adjacent Goldbach levels.

A separate toggle overlays the fractal fib inside whichever band price is in, in any mode.

OTHER SETTINGS

Number of ranges to draw above and below the active one
Shift the grid by a fraction of the PO3, or anchor it to a chosen historic price instead of zero
Every level group can be switched on or off individually; a premium/discount filter shows only one side
Optional midlevels (the consequent encroachment between adjacent Goldbach levels)
Labels as Goldbach numbers, layer names, both, or none; colours, line style, width and extension are all adjustable
Decimate input for forex (10000) and other instruments where one point is not one unit

READ-OUT TABLE

Symbol and active range · the band price is in (PREMIUM / DISCOUNT + layer, or DEAD ZONE) · position in the range as a percentage · range low and high · nearest level above and below with the distance in points · the size of one Goldbach block and of the current band.

ALERTS

Two alert() calls with dynamic messages, plus matching alertcondition() entries: a Goldbach level crossed on close (the message names the level), and price entering a new band.

NOTES

This script draws structure only. It does not generate signals or make predictions, and the levels carry no claim of predictive value — they are a consistent way of describing where price is within a fixed range. Works on any instrument and timeframe. Best used with the same PO3 mode on every chart you compare, so that the ranges agree.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════
//  GOLDBACH LEVELS — dealing-range grid   v1
//
//  A replacement for the discontinued Trifecta levels display, built from
//  what that indicator was measured to do (reference §13-14):
//    - base-0 anchoring: range low = floor(price / PO3) x PO3, exactly
//    - the level set 0 3 7 11 17 23 29 35 41 47 50 53 59 65 71 77 83 89 93 97 100
//    - three coloured layers with dead zones between them:
//        LIQUIDITY 0-17 / 83-100   FLOW 23-35 / 65-77   REBALANCE 41-59
//        dead zones 17-23, 35-41, 59-65, 77-83  (boundary belongs to the
//        band above it, which is how the original reported "DEAD ZONE")
//    - "# of ranges" = ranges on EACH side of the active one
//    - a band read-out table: PREMIUM / DISCOUNT + layer, or DEAD ZONE
//  plus what we added on top of it:
//    - Auto PO3 by volatility (one 6% block ~ 5 bars, locked per day) — the
//      same rule GB Plans uses, so both scripts land on the same range
//    - the author's auto-by-timeframe table as an alternative
//    - Fractal mode: the fib inside the active layer band
//    - midlevels (the CE between adjacent Goldbach levels)
//    - premium / discount filter, label modes, shift and anchor inputs
//    - level-cross and band-change alerts
//
//  Nothing here draws a signal. It is the grid the other two scripts read.
// ═══════════════════════════════════════════════════════════════════════
indicator("Goldbach Levels", "GB Levels", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 100)

// ─── INPUTS ────────────────────────────────────────────────────────────
gR = "DEALING RANGE"
po3Mode = input.string("Auto by volatility", "PO3 mode", options = ["Auto by volatility", "Auto by timeframe", "Manual", "Fractal"], group = gR, tooltip = "Auto by volatility: the PO3 whose 6% block takes ~5 bars of this chart to cross, locked for the day (matches GB Plans). Auto by timeframe: the Trifecta author's table (1m/5m=27, 15m=81, 1H=243, 4H/D=729, W=2187, M=6561). Manual: the number below. Fractal: the fib inside the active band of a bigger PO3.")
po3in   = input.int(243, "Manual PO3", minval = 1, group = gR)
dec     = input.float(1.0, "Decimate  (FX = 10000)", group = gR)
nRng    = input.int(1, "# of ranges each side", minval = 0, maxval = 3, group = gR, tooltip = "As in the original: 2 means two above and two below the active range, five in all.")
shiftPct = input.float(0.0, "Shift range  (% of PO3)", minval = 0.0, maxval = 99.0, step = 5.0, group = gR, tooltip = "Slides the whole grid up by this fraction of the PO3. 50 is the half-shift.")
anchorPx = input.float(0.0, "Historic price anchor  (0 = base-0)", minval = 0.0, group = gR, tooltip = "If set, ranges are laid from this price instead of from zero. Base-0 is what the original shipped; this is the book's fix-price alternative.")
autoLen  = input.int(300, "Auto: volatility lookback (bars)", minval = 20, group = gR)
autoStick = input.float(25.0, "Auto: stickiness (%)", minval = 0.0, step = 5.0, group = gR)
tgtBars  = input.float(5.0, "Auto: target bars per Goldbach block", minval = 1.0, step = 0.5, group = gR)

gF = "FRACTAL"
fracParent = input.int(2187, "Parent PO3", group = gF)
fracBy  = input.string("Layer band", "Cut the parent by", options = ["Layer band", "Goldbach block"], group = gF)
fracFib = input.bool(false, "Also draw the fib inside the active band (any mode)", group = gF, tooltip = "Dotted sub-levels inside whichever band price is in, on top of the main grid. This is the original's 'fractal fib' overlay.")

gL = "LEVELS"
onHL   = input.bool(true, "Range high / low  0 · 100",   group = gL)
onRej  = input.bool(true, "Rejection  3 · 97",           group = gL)
onLLOD = input.bool(true, "LLOD  7 · 93",                group = gL)
onLiq  = input.bool(true, "Liquidity / OB  11 · 89",     group = gL)
onGIP  = input.bool(true, "GIP  17 · 83",                group = gL)
onN1   = input.bool(true, "Non-GB  23 · 77",             group = gL)
onMSS  = input.bool(true, "Sweet spot / LV  29 · 71",    group = gL)
onN2   = input.bool(true, "Non-GB  35 · 65",             group = gL)
onIRB  = input.bool(true, "Int. rebalance / BR  41 · 59", group = gL)
onIRJ  = input.bool(true, "Int. rejection / MT  47 · 53", group = gL)
onEQ   = input.bool(true, "Equilibrium  50",             group = gL)
onMid  = input.bool(false, "Midlevels (CE between levels)", group = gL)
pdFilt = input.string("Both", "Premium / discount", options = ["Both", "Premium only", "Discount only"], group = gL)

gS = "STYLE"
lblMode = input.string("Goldbach", "Labels", options = ["Goldbach", "Normal", "Both", "None"], group = gS, tooltip = "Goldbach = [29]. Normal = the layer name. Both = [29] Sweet spot.")
lblSize = input.string("Small", "Label size", options = ["Tiny", "Small", "Normal"], group = gS)
lblOff  = input.int(3, "Label offset (bars right)", minval = 0, group = gS)
lineW   = input.int(1, "Line width", minval = 1, maxval = 4, group = gS)
lineSty = input.string("Dotted", "Line style", options = ["Solid", "Dotted", "Dashed"], group = gS)
barsBack = input.int(150, "Lines start (bars back)", minval = 10, group = gS)
extRight = input.bool(true, "Extend lines right", group = gS)
extBars  = input.int(40, "…or extend by (bars)", minval = 1, group = gS)
bandOpq = input.int(92, "Band shading opacity (%)", minval = 50, maxval = 100, group = gS, tooltip = "100 = no shading.")
uniCol  = input.bool(false, "Uniform colour", group = gS)
cLiq = input.color(#26a69a, "Liquidity", group = gS, inline = "c")
cGIP = input.color(#ff9800, "GIP", group = gS, inline = "c")
cFlo = input.color(#2962ff, "Flow", group = gS, inline = "c")
cReb = input.color(#ef5350, "Rebalance", group = gS, inline = "c")
cHL  = input.color(#787b86, "Range H/L", group = gS, inline = "c")
dark = input.bool(true, "Dark theme", group = gS)

gT = "TABLE"
showTbl = input.bool(true, "Show read-out", group = gT)
tblPos  = input.string("Top right", "Position", options = ["Top right", "Top left", "Bottom right", "Bottom left", "Middle right"], group = gT)
tblSize = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = gT)

// ─── CONSTANTS ─────────────────────────────────────────────────────────
var array<int>    LV    = array.from(0, 3, 7, 11, 17, 23, 29, 35, 41, 47, 50, 53, 59, 65, 71, 77, 83, 89, 93, 97, 100)
var array<int>    GB    = array.from(0, 3, 11, 17, 23, 29, 35, 41, 47, 50, 53, 59, 65, 71, 77, 83, 89, 97, 100)
var array<int>    LAYER = array.from(0, 17, 23, 35, 41, 59, 65, 77, 83, 100)
var array<int>    PO3S  = array.from(27, 81, 243, 729, 2187, 6561, 19683)

f_name(int g) =>
    g == 0 ? "Range low" : g == 100 ? "Range high" :
      g == 3 or g == 97 ? "Rejection" : g == 7 or g == 93 ? "LLOD" :
      g == 11 or g == 89 ? "Liquidity · OB" : g == 17 or g == 83 ? "GIP" :
      g == 29 or g == 71 ? "Sweet spot · LV" : g == 23 or g == 77 or g == 35 or g == 65 ? "Non-GB" :
      g == 41 or g == 59 ? "Int. rebalance · BR" : g == 47 or g == 53 ? "Int. rejection · MT" : "Equilibrium"

f_on(int g) =>
    g == 0 or g == 100 ? onHL : g == 3 or g == 97 ? onRej : g == 7 or g == 93 ? onLLOD :
      g == 11 or g == 89 ? onLiq : g == 17 or g == 83 ? onGIP : g == 23 or g == 77 ? onN1 :
      g == 29 or g == 71 ? onMSS : g == 35 or g == 65 ? onN2 : g == 41 or g == 59 ? onIRB :
      g == 47 or g == 53 ? onIRJ : onEQ

f_col(int g) =>
    uniCol ? cHL :
      g == 0 or g == 100 ? cHL : g < 17 or g > 83 ? cLiq : g == 17 or g == 83 ? cGIP :
      (g >= 23 and g <= 35) or (g >= 65 and g <= 77) ? cFlo : g >= 41 and g <= 59 ? cReb : cHL

f_fam(float q) => q < 17 ? "LIQUIDITY" : q < 23 ? "DEAD" : q < 35 ? "FLOW" : q < 41 ? "DEAD" : q < 59 ? "REBALANCE" : q < 65 ? "DEAD" : q < 77 ? "FLOW" : q < 83 ? "DEAD" : "LIQUIDITY"
f_band(float q) =>
    string f = f_fam(q)
    f == "DEAD" ? "DEAD ZONE" : (q >= 50 ? "PREMIUM " : "DISCOUNT ") + f + " LAYER"

f_nearPO3(float want) =>
    int best = 243
    float bd = 1.0e20
    if want > 0
        for j = 0 to PO3S.size() - 1
            float d = math.abs(math.log(PO3S.get(j) / want))
            if d < bd
                bd := d
                best := PO3S.get(j)
    best

f_tfPO3() =>
    int sec = timeframe.in_seconds()
    sec >= 86400 * 28 ? 6561 : sec >= 86400 * 7 ? 2187 : sec >= 3600 * 4 ? 729 : sec >= 3600 ? 243 : sec >= 900 ? 81 : 27

f_sty() => lineSty == "Solid" ? line.style_solid : lineSty == "Dashed" ? line.style_dashed : line.style_dotted
f_lsz() => lblSize == "Tiny" ? size.tiny : lblSize == "Normal" ? size.normal : size.small
f_tsz() => tblSize == "Tiny" ? size.tiny : tblSize == "Normal" ? size.normal : size.small
f_tpos() =>
    tblPos == "Top right" ? position.top_right : tblPos == "Top left" ? position.top_left :
      tblPos == "Bottom right" ? position.bottom_right : tblPos == "Bottom left" ? position.bottom_left : position.middle_right

// ─── PO3 SELECTION ─────────────────────────────────────────────────────
float atrSlow = ta.rma(ta.tr(true), autoLen)
float po3Want = na(atrSlow) ? na : tgtBars * atrSlow * dec / 0.06
var int po3Auto = 0
if not na(po3Want) and (po3Auto == 0 or timeframe.change("D"))
    if po3Auto == 0
        po3Auto := f_nearPO3(po3Want)
    else
        float band = math.sqrt(3.0) * (1.0 + autoStick / 100.0)
        if po3Want > po3Auto * band or po3Want < po3Auto / band
            po3Auto := f_nearPO3(po3Want)

int po3Use = po3Mode == "Auto by volatility" and po3Auto > 0 ? po3Auto : po3Mode == "Auto by timeframe" ? f_tfPO3() : po3in

// the band of a parent range that `price` is in: [low, size, from%, to%]
f_bandOf(float price, float P, bool byLayer) =>
    float base = math.floor(price / P) * P
    float q    = (price - base) / P * 100.0
    float bLo  = na
    float bSz  = na
    int   a0   = 0
    int   b0   = 100
    int   m    = byLayer ? LAYER.size() : GB.size()
    for j = 0 to m - 2
        int a = byLayer ? LAYER.get(j) : GB.get(j)
        int b = byLayer ? LAYER.get(j + 1) : GB.get(j + 1)
        if na(bLo) and q >= a and q < b
            bLo := base + a / 100.0 * P
            bSz := (b - a) / 100.0 * P
            a0  := a
            b0  := b
    if na(bLo)
        int a = byLayer ? LAYER.get(m - 2) : GB.get(m - 2)
        bLo := base + a / 100.0 * P
        bSz := (100 - a) / 100.0 * P
        a0  := a
    [bLo, bSz, a0, b0]

// ─── THE ACTIVE RANGE ──────────────────────────────────────────────────
bool  isFrac = po3Mode == "Fractal"
float P      = math.max(fracParent, 1) / dec
[fLo, fSz, fA, fB] = f_bandOf(close, P, fracBy == "Layer band")

float s     = isFrac ? fSz : math.max(po3Use, 1) / dec
float shift = isFrac ? 0.0 : s * shiftPct / 100.0
float org   = anchorPx > 0 ? anchorPx / dec : 0.0          // grid origin
float lo    = isFrac ? fLo : org + shift + math.floor((close - org - shift) / s) * s
float hi    = lo + s
float pct   = (close - lo) / s * 100.0
string rangeName = isFrac ? str.tostring(fracParent) + "·" + str.tostring(fA) + "-" + str.tostring(fB) : str.tostring(math.round(s * dec))

// the inner band, for the optional fractal fib overlay and the read-out
int   innA = pct < 17 ? 0 : pct < 23 ? 17 : pct < 35 ? 23 : pct < 41 ? 35 : pct < 59 ? 41 : pct < 65 ? 59 : pct < 77 ? 65 : pct < 83 ? 77 : 83
int   innB = innA == 0 ? 17 : innA == 17 ? 23 : innA == 23 ? 35 : innA == 35 ? 41 : innA == 41 ? 59 : innA == 59 ? 65 : innA == 65 ? 77 : innA == 77 ? 83 : 100
float innLo = lo + innA / 100.0 * s
float innSz = (innB - innA) / 100.0 * s

// ─── DRAWING ───────────────────────────────────────────────────────────
var array<line>  LN = array.new<line>()
var array<label> LB = array.new<label>()
var array<box>   BX = array.new<box>()
var string drawnKey = ""

f_clear() =>
    while LN.size() > 0
        line.delete(LN.pop())
    while LB.size() > 0
        label.delete(LB.pop())
    while BX.size() > 0
        box.delete(BX.pop())
    LN.clear()
    LB.clear()
    BX.clear()

f_pdOK(int g) => pdFilt == "Both" or (pdFilt == "Premium only" ? g >= 50 : g <= 50)

f_lblText(int g, bool isRange, int rangeIdx) =>
    string num = (g < 10 ? "0" : "") + str.tostring(g)
    if isRange
        // range boundary: "[243 L]" / "[243 H]" like the original; off-range copies get their index
        (g == 0 ? "[" + rangeName + " L" : "[" + rangeName + " H") + (rangeIdx == 0 ? "]" : " " + (rangeIdx > 0 ? "+" : "") + str.tostring(rangeIdx) + "]")
    else
        lblMode == "Goldbach" ? "[" + num + "]" : lblMode == "Normal" ? f_name(g) : "[" + num + "] " + f_name(g)

f_draw() =>
    f_clear()
    int x1 = bar_index - barsBack
    int x2 = bar_index + extBars
    color bgD = dark ? color.new(#131722, 100) : color.new(#ffffff, 100)
    for k = -nRng to nRng
        float base = lo + k * s
        bool  act  = k == 0
        int   tr   = act ? 0 : 40               // side ranges drawn fainter
        // bands
        if bandOpq < 100
            for j = 0 to LAYER.size() - 2
                int a = LAYER.get(j)
                int b = LAYER.get(j + 1)
                string fam = f_fam((a + b) / 2.0)
                if fam != "DEAD" and (pdFilt == "Both" or (pdFilt == "Premium only" ? b > 50 : a < 50))
                    color bc = fam == "LIQUIDITY" ? cLiq : fam == "FLOW" ? cFlo : cReb
                    BX.push(box.new(x1, base + b / 100.0 * s, x2, base + a / 100.0 * s,
                         border_color = color.new(bc, 100), bgcolor = color.new(bc, math.min(99, bandOpq + (act ? 0 : 4))),
                         extend = extRight ? extend.right : extend.none))
        // levels
        for j = 0 to LV.size() - 1
            int g = LV.get(j)
            // the 100 of one range is the 0 of the next: draw it once, at the top
            bool want = not (g == 100 and k < nRng) and f_on(g) and f_pdOK(g)
            if want
                float y = base + g / 100.0 * s
                bool isR = g == 0 or g == 100
                color c = color.new(f_col(g), tr)
                LN.push(line.new(x1, y, x2, y, color = c, width = isR ? lineW + 1 : lineW,
                     style = isR ? line.style_solid : f_sty(), extend = extRight ? extend.right : extend.none))
                if lblMode != "None"
                    LB.push(label.new(bar_index + lblOff, y, f_lblText(g, isR, k),
                         style = label.style_label_left, color = bgD, textcolor = c, size = f_lsz()))
        // midlevels
        if onMid
            for j = 0 to GB.size() - 2
                int a = GB.get(j)
                int b = GB.get(j + 1)
                if f_pdOK(a) and f_pdOK(b)
                    float y = base + (a + b) / 200.0 * s
                    LN.push(line.new(x1, y, x2, y, color = color.new(cHL, 70 + tr / 2), width = 1,
                         style = line.style_dotted, extend = extRight ? extend.right : extend.none))
    // fractal fib inside the active band
    if fracFib
        for j = 1 to GB.size() - 2
            int g = GB.get(j)
            float y = innLo + g / 100.0 * innSz
            LN.push(line.new(x1, y, x2, y, color = color.new(cGIP, 55), width = 1,
                 style = line.style_dotted, extend = extRight ? extend.right : extend.none))
            if lblMode != "None"
                LB.push(label.new(bar_index + lblOff + 6, y, "f" + str.tostring(g),
                     style = label.style_label_left, color = bgD, textcolor = color.new(cGIP, 30), size = size.tiny))

string key = str.tostring(lo, "#.####") + "|" + str.tostring(s, "#.####") + "|" + str.tostring(innA) + "|" + str.tostring(pdFilt) + str.tostring(nRng)
if barstate.islast
    if key != drawnKey
        f_draw()
        drawnKey := key
    else if not extRight
        if LN.size() > 0
            for i = 0 to LN.size() - 1
                line.set_x2(LN.get(i), bar_index + extBars)
        if LB.size() > 0
            for i = 0 to LB.size() - 1
                label.set_x(LB.get(i), bar_index + lblOff)
        if BX.size() > 0
            for i = 0 to BX.size() - 1
                box.set_right(BX.get(i), bar_index + extBars)

// ─── READ-OUT ──────────────────────────────────────────────────────────
// nearest level above / below (from the full level set, active range)
float upLvl = na
float dnLvl = na
int   upG   = na
int   dnG   = na
for j = 0 to LV.size() - 1
    int g = LV.get(j)
    float y = lo + g / 100.0 * s
    if y > close and na(upLvl)
        upLvl := y
        upG   := g
    if y <= close
        dnLvl := y
        dnG   := g

cTXT = dark ? color.new(#d1d4dc, 0) : color.new(#131722, 0)
cDIM = color.new(#787b86, 0)
cBG  = dark ? color.new(#131722, 10) : color.new(#ffffff, 8)
cHDR = dark ? color.new(#1e222d, 0)  : color.new(#f0f3fa, 0)

var table T = table.new(position.top_right, 2, 7, border_width = 1)
if barstate.islast and showTbl
    string band = f_band(pct)
    color bcol = f_fam(pct) == "DEAD" ? cDIM : f_fam(pct) == "LIQUIDITY" ? cLiq : f_fam(pct) == "FLOW" ? cFlo : cReb
    table.set_position(T, f_tpos())
    table.set_bgcolor(T, cBG)
    table.cell(T, 0, 0, syminfo.ticker, text_color = cTXT, text_size = f_tsz(), bgcolor = cHDR)
    table.cell(T, 1, 0, rangeName + " · " + timeframe.period + (po3Mode == "Auto by volatility" ? "  auto" : po3Mode == "Auto by timeframe" ? "  tf" : po3Mode == "Fractal" ? "  fractal" : ""), text_color = cTXT, text_size = f_tsz(), bgcolor = cHDR)
    table.cell(T, 0, 1, "band", text_color = cDIM, text_size = f_tsz())
    table.cell(T, 1, 1, band, text_color = bcol, text_size = f_tsz())
    table.cell(T, 0, 2, "position", text_color = cDIM, text_size = f_tsz())
    table.cell(T, 1, 2, str.tostring(pct, "#.#") + "%", text_color = pct >= 50 ? cReb : cLiq, text_size = f_tsz())
    table.cell(T, 0, 3, "range", text_color = cDIM, text_size = f_tsz())
    table.cell(T, 1, 3, str.tostring(lo, format.mintick) + " → " + str.tostring(hi, format.mintick), text_color = cTXT, text_size = f_tsz())
    table.cell(T, 0, 4, "above", text_color = cDIM, text_size = f_tsz())
    table.cell(T, 1, 4, na(upG) ? "" : "[" + (upG < 10 ? "0" : "") + str.tostring(upG) + "]  " + str.tostring(upLvl, format.mintick) + "  +" + str.tostring(upLvl - close, "#.##"), text_color = na(upG) ? cDIM : f_col(upG), text_size = f_tsz())
    table.cell(T, 0, 5, "below", text_color = cDIM, text_size = f_tsz())
    table.cell(T, 1, 5, na(dnG) ? "" : "[" + (dnG < 10 ? "0" : "") + str.tostring(dnG) + "]  " + str.tostring(dnLvl, format.mintick) + "  -" + str.tostring(close - dnLvl, "#.##"), text_color = na(dnG) ? cDIM : f_col(dnG), text_size = f_tsz())
    table.cell(T, 0, 6, "block", text_color = cDIM, text_size = f_tsz())
    table.cell(T, 1, 6, str.tostring(0.06 * s * dec, "#.#") + " pts  ·  " + str.tostring(innA) + "-" + str.tostring(innB) + " band " + str.tostring(innSz * dec, "#") + " pts", text_color = cDIM, text_size = f_tsz())

// ─── ALERTS ────────────────────────────────────────────────────────────
// a level between the last close and this one
bool crossed = false
int  crossG  = na
for j = 0 to LV.size() - 1
    int g = LV.get(j)
    float y = lo + g / 100.0 * s
    if f_on(g) and not crossed and ((close[1] < y and close >= y) or (close[1] > y and close <= y))
        crossed := true
        crossG  := g
string bandNow = f_band(pct)
bool bandChg = bandNow != bandNow[1]

if crossed
    alert("GB level [" + str.tostring(crossG) + "] " + f_name(crossG) + " crossed on " + syminfo.ticker + " " + timeframe.period + "  (" + rangeName + ", now " + str.tostring(pct, "#.#") + "%)", alert.freq_once_per_bar_close)
if bandChg
    alert(syminfo.ticker + " " + timeframe.period + " entered " + bandNow + "  (" + rangeName + ")", alert.freq_once_per_bar_close)
alertcondition(crossed, "Goldbach level crossed", "A Goldbach level was crossed on {{ticker}} {{interval}}")
alertcondition(bandChg, "Band changed", "Price entered a new Goldbach band on {{ticker}} {{interval}}")
````
