# VIP Price Points JPY

- url: https://www.tradingview.com/script/v9a3lM60-VIP-Price-Points-JPY/
- type: indicator
- pine_id: PUB;9c5334f68c1b4f01b15aa4fcb6677e9c
- version: 1.0

## Description

This indicator plots a fixed grid of "VIP" price levels based on Quarter Theory structure, mapping the round-number prices where markets tend to pause, react, break, or reverse. 

It draws four nested layers — Dime (major VIPs at every 1000 pips), Nickel (500 pips), Big Quarter (250 pips), and Penny (100 pips) — each with a distinct color and weight so you can instantly read where price sits within the larger structure. An adjustable hesitation zone shades a configurable band (default ±25 pips) around every level, marking the areas where price commonly stalls before continuing or turning. 

A live info panel reports the nearest major VIP above and below, the distance in pips to the closest one, and whether price is currently inside a hesitation zone or traveling mid-leg, and built-in alerts fire when price crosses a major VIP or enters a hesitation zone. 

Two versions are included, one tuned for non-JPY pairs (pip = 0.0001) and one for JPY pairs (pip = 0.01), with adjustable level counts, colors, and zone width so you can configure it for swing trading on the higher timeframes or day trading on the 15m–1H. 

This is a structure and analysis tool intended to help you locate price within a fixed level framework — it does not generate buy or sell signals, and it is shared for educational purposes only. Always do your own analysis and manage your own risk.

## Source Code

````pine
//@version=6
// =====================================================================
//  VIP PRICE POINTS — JPY  (single ±25 hesitation zone on all VIP levels)
//  Dime / Nickel / Big Quarter / Penny. JPY pairs, pip = 0.01.
// =====================================================================
indicator("VIP Price Points — JPY", "VIP JPY", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// ============================== INPUTS ==============================
gP = "Setup"
pip = input.float(0.01, "Pip size (JPY = 0.01)", step=0.001, group=gP, tooltip="JPY = 0.01. Use 0.0001 for non-JPY.")

gM = "Hesitation zone"
zoneShade = input.bool(true, "Shade hesitation zones", group=gM)
hesPips   = input.float(25, "Hesitation (± pips)", step=5, group=gM, tooltip="Applied to every VIP level. Day trade = 25.")

gL = "VIP level groups"
showDime   = input.bool(true,  "Dime   (major VIP)",      group=gL)
showNickel = input.bool(true,  "Nickel (major VIP)",      group=gL)
showBigQ   = input.bool(true,  "Big Quarter",             group=gL)
showPenny  = input.bool(true,  "Penny (entry timing)",    group=gL)
showSmall  = input.bool(false, "Small Quarter",           group=gL)

gR = "How many each side"
nDime   = input.int(2, "Dime",        minval=1, maxval=10, group=gR)
nNickel = input.int(3, "Nickel",      minval=1, maxval=20, group=gR)
nBigQ   = input.int(4, "Big Quarter", minval=1, maxval=20, group=gR)
nPenny  = input.int(6, "Penny",       minval=1, maxval=40, group=gR)
nSmall  = input.int(8, "Small Qtr",   minval=1, maxval=60, group=gR)

gS = "Style"
showLabels = input.bool(true, "Show VIP price labels", group=gS)
labOff     = input.int(8, "Label offset (bars right)", minval=0, maxval=50, group=gS)
showTable  = input.bool(true, "Show info panel", group=gS)

gC = "Colors"
cDime   = input.color(#C9A23A, "Dime",   group=gC)
cNickel = input.color(#E8734A, "Nickel", group=gC)
cBigQ   = input.color(#3FB6A8, "Big Quarter", group=gC)
cPenny  = input.color(#8A99A6, "Penny",  group=gC)
cSmall  = input.color(#586675, "Small Qtr", group=gC)
cZone   = input.color(color.new(#C9A23A, 87), "Hesitation shade", group=gC)

// ============================== MATH ==============================
snap(_p) => math.round(_p / pip) * pip
isJPY = str.contains(syminfo.ticker, "JPY")

pPips   = close / pip
majStep = 250
mBelow  = math.floor(pPips / majStep) * majStep
mAbove  = mBelow + majStep
majBelow = snap(mBelow * pip)
majAbove = snap(mAbove * pip)
f_majtype(_p) => int(_p) % 1000 == 0 ? "Dime" : int(_p) % 500 == 0 ? "Nickel" : "BigQ"
majNearDist = math.min(pPips - mBelow, mAbove - pPips)
majNearType = (mAbove - pPips) < (pPips - mBelow) ? f_majtype(mAbove) : f_majtype(mBelow)
inHes = majNearDist <= hesPips

pnStep = 100
pnBelow = math.floor(pPips / pnStep) * pnStep
pnAbove = pnBelow + pnStep
pennyBelow = snap(pnBelow * pip)
pennyAbove = snap(pnAbove * pip)
pnNearDist = math.min(pPips - pnBelow, pnAbove - pPips)
inPennyHes = pnNearDist <= hesPips

majIndex = math.floor(close / (majStep * pip))
crossedMaj = majIndex != majIndex[1]

// ============================== DRAW ==============================
var array<line>  lns = array.new<line>()
var array<box>   bxs = array.new<box>()
var array<label> lbs = array.new<label>()

clearAll() =>
    for x in lns
        line.delete(x)
    array.clear(lns)
    for y in bxs
        box.delete(y)
    array.clear(bxs)
    for z in lbs
        label.delete(z)
    array.clear(lbs)

hline2(_price, _col, _width, _style) =>
    ln = line.new(bar_index, _price, bar_index + 1, _price, xloc=xloc.bar_index, extend=extend.both, color=_col, width=_width, style=_style)
    array.push(lns, ln)

keepLevel(_pips, _grp) =>
    m1000 = _pips % 1000
    m500  = _pips % 500
    m100  = _pips % 100
    _grp == "dime"   ? true :
     _grp == "nickel"? (m500 == 0 and m1000 != 0) :
     _grp == "bigq"  ? (m500 == 250) :
     _grp == "penny" ? (m100 == 0 and m500 != 0) :
     _grp == "small" ? (m100 == 25 or m100 == 50 or m100 == 75) :
     true

drawGroup(_grp, _step, _count, _col, _width, _style, _doLabel, _doZone) =>
    base = snap(math.floor(close / _step) * _step)
    for i = -_count to _count
        lvl = snap(base + i * _step)
        pInt = int(math.round(lvl / pip))
        if keepLevel(pInt, _grp)
            hline2(lvl, _col, _width, _style)
            if _doZone and zoneShade and hesPips > 0
                bx = box.new(bar_index - 480, lvl + hesPips*pip, bar_index + labOff, lvl - hesPips*pip, xloc=xloc.bar_index, border_color=color.new(color.black,100), bgcolor=cZone)
                array.push(bxs, bx)
            if _doLabel and showLabels
                lb = label.new(bar_index + labOff, lvl, str.tostring(lvl, "0.00"), xloc=xloc.bar_index, style=label.style_label_left, textcolor=_col, color=color.new(color.black, 100), size=size.small)
                array.push(lbs, lb)

if barstate.islast
    clearAll()
    if showSmall
        drawGroup("small",  25  * pip, nSmall, cSmall, 1, line.style_dotted, false, false)
    if showPenny
        drawGroup("penny",  100 * pip, nPenny, cPenny, 1, line.style_dashed, false, true)
    if showBigQ
        drawGroup("bigq",   250 * pip, nBigQ, cBigQ, 1, line.style_solid, false, true)
    if showNickel
        drawGroup("nickel", 500 * pip, nNickel, cNickel, 2, line.style_solid, true, true)
    if showDime
        drawGroup("dime",   1000 * pip, nDime, cDime, 3, line.style_solid, true, true)

// ============================== INFO PANEL ==============================
var table tbl = table.new(position.top_right, 2, 7, border_width=1, frame_color=#26323D, frame_width=1)

f_cell(_r, _k, _v, _vcol) =>
    table.cell(tbl, 0, _r, _k, text_color=#8A99A6, text_size=size.small, text_halign=text.align_left,  bgcolor=#161E26)
    table.cell(tbl, 1, _r, _v, text_color=_vcol,   text_size=size.small, text_halign=text.align_right, bgcolor=#161E26)

if barstate.islast and showTable
    f_cell(0, "Symbol",     syminfo.ticker + (isJPY ? "" : "  use USD ind."), isJPY ? #E8E4D8 : #C8553D)
````
