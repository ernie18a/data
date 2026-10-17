# FCM Fib - Execution Zones (MasterClass Access)

- url: https://www.tradingview.com/script/0R5kTBAc-FCM-Fib-Execution-Zones-MasterClass-Access/
- type: indicator
- pine_id: PUB;473fe5173be14982b33e0a6d6d60bca1
- version: 1.0

## Description

FCM Fib - Execution Zones (MasterClass Access)

by TheTradingWiz

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════
//  FCM FIB  —  The Trading Wiz  (v18)
//  Levels, EZ/IRZ zones, Execute midlines, NSH/NSL arrows.
// ════════════════════════════════════════════════════════════════
indicator("FCM Fib — The Trading Wiz", overlay = true, max_lines_count = 250, max_labels_count = 120)

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

// ─── STORAGE ────────────────────────────────────────────────────
var line[]     lineArr = array.new<line>()
var label[]    lblArr  = array.new<label>()
var linefill[] fillArr = array.new<linefill>()

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
````
