# FCM Fib - Entries (MasterClass Access)

- url: https://www.tradingview.com/script/Srs2oTKv-FCM-Fib-Entries-MasterClass-Access/
- type: indicator
- pine_id: PUB;757b7803c577474f95153e757a230c4c
- version: 1.0

## Description

FCM Fib - Entries (MasterClass Access)

by TheTradingWiz

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════
//  FCM FIB  —  The Trading Wiz  (v17)
//  • Short (top EZ) + Buy (lower EZ), each with TP1/TP2/TP3 + 1:1 SL
//  • Adjustable projection width; NSH arrow tucked tighter
// ════════════════════════════════════════════════════════════════
indicator("FCM Fib — The Trading Wiz", overlay = true, max_lines_count = 300, max_labels_count = 150, max_boxes_count = 30)

// ─── ANCHORS ────────────────────────────────────────────────────
grpA      = "① Anchors — click NSH then NSL"
nshTime   = input.time (0,   "NSH", confirm = true, group = grpA)
nshPrice  = input.price(0.0, "NSH", confirm = true, group = grpA)
nslTime   = input.time (0,   "NSL", confirm = true, group = grpA)
nslPrice  = input.price(0.0, "NSL", confirm = true, group = grpA)

// ─── DISPLAY ────────────────────────────────────────────────────
grpD       = "② Display"
showText   = input.bool(true,  "Show labels (NSH / EZ / IRZ / NSL / WR)", group = grpD)
showMid    = input.bool(true,  "Show dashed Execute midlines",            group = grpD)
showArrows = input.bool(true,  "Show NSH / NSL arrows",                    group = grpD)
showExt    = input.bool(false, "Show upside extension targets",            group = grpD)
labelOff   = input.int (3,     "Label offset (bars right)", minval = 0, maxval = 40, group = grpD)
nslGap     = input.float(6.0,  "NSL arrow gap (%)", minval = 0, maxval = 20, group = grpD) / 100
nshGap     = input.float(3.0,  "NSH arrow gap (%)", minval = 0, maxval = 20, group = grpD) / 100
lineW      = input.int (1,     "Line width",                minval = 1, maxval = 4,  group = grpD)
ezAlpha    = input.int (82,    "EZ fill transparency",      minval = 50, maxval = 95, group = grpD)
irzAlpha   = input.int (82,    "IRZ fill transparency",     minval = 50, maxval = 95, group = grpD)

// ─── POSITION SETUPS ────────────────────────────────────────────
grpP       = "③ Position Setups"
showShort  = input.bool (true,  "Show SHORT (top EZ)",        group = grpP)
showLong   = input.bool (true,  "Show BUY (lower EZ)",        group = grpP)
rr         = input.float(1.0,   "Risk : Reward (vs TP1)",     minval = 0.5, maxval = 5, step = 0.5, group = grpP)
projBars   = input.int  (12,    "Projection width (bars)",    minval = 5, maxval = 120, group = grpP)
shortPosT  = input.time (0,     "Short position — click, then drag", confirm = true, group = grpP)
longPosT   = input.time (0,     "Buy position — click, then drag",   confirm = true, group = grpP)
rwdCol     = input.color(#7c4dd6, "Reward zone colour", group = grpP)
rskCol     = input.color(#8b2424, "Risk zone colour",   group = grpP)
posTransp  = input.int  (80,      "Position fill transparency", minval = 50, maxval = 95, group = grpP)

// ─── COLOURS ────────────────────────────────────────────────────
cBlk = color.rgb(20, 20, 20)
cOrg = #f5a623
cLil = #cba3e8
cMag = #b44ae0
cPur = #8a3fd8
cRed = #e53935
cGrn = #4caf50
cTel = #009688
cGry = #888888
cDrd = #a03030
cCrm = #c0395b
cTl2 = #1a9e8f
cPnk = #e0398b
cRwd = #089981   // position reward (green)
cRsk = #f23645   // position risk (red)

// ─── FCM LEVEL DEFINITIONS ──────────────────────────────────────
var coeffs = array.from( 1.0,  0.886, 0.786, 0.5,   0.382, 0.236,
                          0.0, -0.46, -0.64, -2.0,  -2.34, -3.14,
                         -4.0, -4.34, -5.0,  -5.34, -8.34, -9.0,
                          2.0,  2.272, 3.272,  4.0,   4.414, 4.764)
var cols   = array.from( cBlk, cPur,  cMag,  cLil,  cLil,  cOrg,
                         cBlk, cMag,  cMag,  cLil,  cLil,  cRed,
                         cLil, cLil,  cPur,  cPur,  cPur,  cMag,
                         cTel, cGrn,  cGry,  cDrd,  cCrm,  cTl2)
var txts   = array.from("NSH", "EZ",  "",    "IRZ", "IRZ", "",
                        "NSL", "EZ",  "",    "",    "",    "WR",
                        "",    "",    "",    "",    "",    "",
                        "",    "",    "",    "",    "",    "")

var ezTop  = array.from( 0.886, -0.46, -2.0, -4.0, -5.0, -8.34)
var ezBot  = array.from( 0.786, -0.64, -2.34, -4.34, -5.34, -9.0)
var ezDark = array.from( false, false, false, false, true, false)
irzTopC = 0.5
irzBotC = 0.382

isExt(c) => c >= 2.0
clearBg  = color.new(color.gray, 100)

// ─── HELPERS ────────────────────────────────────────────────────
mkLabel(x, y, txt, col, sz, bg) =>
    label.new(x, y, txt, xloc = xloc.bar_time, style = label.style_label_right,
              color = bg, textcolor = col, size = sz)

findLine(arr, targetY) =>
    result = line(na)
    for ln in arr
        if math.abs(line.get_y1(ln) - targetY) < syminfo.mintick * 2
            result := ln
    result

// draw a full setup (works for short or long via min/max)
drawSetup(line[] lineA, label[] lblA, box[] boxA, float entryP, float tp1P, float tp2P, float tp3P, float slP, int bL, int bR, int lblX) =>
    bordA = math.max(posTransp - 30, 20)
    array.push(boxA, box.new(bL, math.max(entryP, slP),  bR, math.min(entryP, slP),  xloc = xloc.bar_time, border_color = color.new(rskCol, bordA), bgcolor = color.new(rskCol, posTransp)))
    array.push(boxA, box.new(bL, math.max(entryP, tp3P), bR, math.min(entryP, tp3P), xloc = xloc.bar_time, border_color = color.new(rwdCol, bordA), bgcolor = color.new(rwdCol, posTransp)))
    array.push(lineA, line.new(bL, entryP, bR, entryP, xloc = xloc.bar_time, color = cBlk, width = 1, style = line.style_dashed))
    array.push(lineA, line.new(bL, tp1P, bR, tp1P, xloc = xloc.bar_time, color = color.new(rwdCol, 0), width = 1, style = line.style_dotted))
    array.push(lineA, line.new(bL, tp2P, bR, tp2P, xloc = xloc.bar_time, color = color.new(rwdCol, 0), width = 1, style = line.style_dotted))
    array.push(lineA, line.new(bL, tp3P, bR, tp3P, xloc = xloc.bar_time, color = color.new(rwdCol, 0), width = 1, style = line.style_dotted))
    array.push(lblA, mkLabel(lblX, slP,  "SL",  color.new(rskCol, 0), size.small, chart.bg_color))
    array.push(lblA, mkLabel(lblX, tp1P, "TP1", color.new(rwdCol, 0), size.small, chart.bg_color))
    array.push(lblA, mkLabel(lblX, tp2P, "TP2", color.new(rwdCol, 0), size.small, chart.bg_color))
    array.push(lblA, mkLabel(lblX, tp3P, "TP3", color.new(rwdCol, 0), size.small, chart.bg_color))

// ─── STORAGE ────────────────────────────────────────────────────
var line[]     lineArr = array.new<line>()
var label[]    lblArr  = array.new<label>()
var linefill[] fillArr = array.new<linefill>()
var box[]      boxArr  = array.new<box>()

// ─── RENDER ─────────────────────────────────────────────────────
if barstate.islast
    for ln in lineArr
        line.delete(ln)
    array.clear(lineArr)
    for lb in lblArr
        label.delete(lb)
    array.clear(lblArr)
    for lf in fillArr
        linefill.delete(lf)
    array.clear(fillArr)
    for bx in boxArr
        box.delete(bx)
    array.clear(boxArr)

    valid = nshPrice != 0.0 and nslPrice != 0.0 and nshPrice != nslPrice
    if valid
        msPerBar = time - time[1]
        startT   = math.min(nshTime, nslTime)
        endT     = time
        labelX   = endT + labelOff * msPerBar
        rng      = nshPrice - nslPrice
        darkA    = math.max(ezAlpha - 14, 40)

        // level lines + labels
        for i = 0 to array.size(coeffs) - 1
            c = array.get(coeffs, i)
            if isExt(c) and not showExt
                continue
            y   = nslPrice + c * rng
            col = array.get(cols, i)
            ln  = line.new(startT, y, endT, y, xloc = xloc.bar_time, extend = extend.right, color = col, width = lineW)
            array.push(lineArr, ln)
            t = array.get(txts, i)
            if showText and t != ""
                array.push(lblArr, mkLabel(labelX, y, t, col, size.normal, clearBg))

        irzFillCol = color.new(cLil, irzAlpha)

        for k = 0 to array.size(ezTop) - 1
            topC = array.get(ezTop, k)
            botC = array.get(ezBot, k)
            fcol = array.get(ezDark, k) ? color.new(cPur, darkA) : color.new(cPur, ezAlpha)
            lT = findLine(lineArr, nslPrice + topC * rng)
            lB = findLine(lineArr, nslPrice + botC * rng)
            if not na(lT) and not na(lB)
                array.push(fillArr, linefill.new(lT, lB, fcol))
            if showMid
                midY = nslPrice + ((topC + botC) / 2) * rng
                array.push(lineArr, line.new(startT, midY, endT, midY, xloc = xloc.bar_time, extend = extend.right, color = cMag, width = 1, style = line.style_dashed))
                exX = startT + int((endT - startT) * 0.5)
                array.push(lblArr, label.new(exX, midY, "Execute", xloc = xloc.bar_time, style = label.style_label_center, color = chart.bg_color, textcolor = cBlk, size = size.small))

        liT = findLine(lineArr, nslPrice + irzTopC * rng)
        liB = findLine(lineArr, nslPrice + irzBotC * rng)
        if not na(liT) and not na(liB)
            array.push(fillArr, linefill.new(liT, liB, irzFillCol))
        if showMid
            irzMidY = nslPrice + ((irzTopC + irzBotC) / 2) * rng
            array.push(lineArr, line.new(startT, irzMidY, endT, irzMidY, xloc = xloc.bar_time, extend = extend.right, color = cMag, width = 1, style = line.style_dashed))

        // arrows (NSH tucked tighter, NSL kept)
        if showArrows and nshTime > 0 and nslTime > 0
            array.push(lblArr, label.new(nshTime, nshPrice + nshGap * rng, "⬇", xloc = xloc.bar_time, style = label.style_none, textcolor = cPur, size = size.normal))
            array.push(lblArr, label.new(nslTime, nslPrice - nslGap * rng, "⬆", xloc = xloc.bar_time, style = label.style_none, textcolor = cPnk, size = size.normal))

        // ── SHORT (top EZ) ──────────────────────────────────────
        if showShort
            eC = (0.886 + 0.786) / 2
            t1 = 0.236, t2 = 0.0, t3 = -0.46
            sC = eC + rr * (eC - t1)
            bL = (shortPosT > 0 ? shortPosT : endT), bR = bL + projBars * msPerBar
            drawSetup(lineArr, lblArr, boxArr, nslPrice + eC*rng, nslPrice + t1*rng, nslPrice + t2*rng, nslPrice + t3*rng, nslPrice + sC*rng, bL, bR, bR + msPerBar)

        // ── BUY (lower EZ) — placed to the right of the short ────
        if showLong
            eC = (-0.46 + -0.64) / 2
            t1 = 0.0, t2 = 0.236, t3 = 0.786
            sC = eC - rr * (t1 - eC)
            bL = (longPosT > 0 ? longPosT : endT + (projBars + 4) * msPerBar)
            bR = bL + projBars * msPerBar
            drawSetup(lineArr, lblArr, boxArr, nslPrice + eC*rng, nslPrice + t1*rng, nslPrice + t2*rng, nslPrice + t3*rng, nslPrice + sC*rng, bL, bR, bR + msPerBar)
````
