<!-- tradingview-pine-id: PUB;f54f6d3de04e4ed7835cf071e9bc619a -->
<!-- tradingviewscripts-format: 1 -->
# HTF Candle Overlay

Source: https://www.tradingview.com/script/ppL8WL0g-HTF-Candle-Overlay/

## Description

This indicator draws higher-timeframe (HTF) candles directly onto a lower-timeframe chart. The default configuration plots 4-hour candles on a 1-minute chart, but any higher timeframe can be selected — 15m on a 1m chart, daily on a 15m chart, weekly on a 4H chart, and so on.

The goal is simple: keep the higher-timeframe picture in view while you work on the execution timeframe, without flipping charts back and forth and losing your place.

---

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════════════
//  HTF CANDLE OVERLAY  —  draw higher-timeframe candles on a lower-TF chart
//  Default: 4H candles on a 1m chart.
//  Builds the HTF candles by aggregating chart bars (no request.security),
//  so the forming candle updates live and nothing repaints.
// ══════════════════════════════════════════════════════════════════════════
indicator("HTF Candle Overlay", "HTF Candles", overlay = true,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 10)

// ───────────────────────────── INPUTS ─────────────────────────────
gTF = "◆ Timeframe"
htf        = input.timeframe("240", "Higher timeframe",
     tooltip = "240 = 4 hours. Must be HIGHER than the chart timeframe.", group = gTF)
numCandles = input.int(10, "Candles to display", minval = 1, maxval = 60, group = gTF)
mode       = input.string("Overlay (in place)", "Display mode",
     options = ["Overlay (in place)", "Offset (right of price)"],
     tooltip = "In place = HTF candle sits exactly over the 1m bars it contains.\nOffset = the last N HTF candles are drawn to the right of price, compressed.",
     group = gTF)

gOff = "◆ Offset-mode layout"
gapBars = input.int(15, "Gap from last bar",      minval = 0, maxval = 200, group = gOff)
bodyW   = input.int(8,  "Candle width (bars)",    minval = 1, maxval = 30,  group = gOff)
gapW    = input.int(4,  "Space between candles",  minval = 1, maxval = 20,  group = gOff)

gStyle = "◆ Style"
upBg   = input.color(color.new(#089981, 80), "Bull  body / border", inline = "u", group = gStyle)
upBd   = input.color(#089981, "", inline = "u", group = gStyle)
dnBg   = input.color(color.new(#f23645, 80), "Bear  body / border", inline = "d", group = gStyle)
dnBd   = input.color(#f23645, "", inline = "d", group = gStyle)
bdW    = input.int(1, "Border width", minval = 0, maxval = 4, group = gStyle)
wickOn = input.bool(true, "Wicks", inline = "w", group = gStyle)
wickW  = input.int(1, "width", minval = 1, maxval = 4, inline = "w", group = gStyle)
tagOn  = input.bool(true, "Timeframe tag on live candle", group = gStyle)

gEx = "◆ Extras"
midOn  = input.bool(false, "50% (equilibrium) of each candle", group = gEx)
midCol = input.color(color.new(color.gray, 25), "50% colour", group = gEx)
sepOn  = input.bool(true, "Vertical period separators", group = gEx)
sepCol = input.color(color.new(color.gray, 70), "Separator colour", group = gEx)
lvlOn  = input.bool(true, "Extend previous candle H / L / C", group = gEx)
lvlCol = input.color(color.new(color.gray, 15), "Level colour", group = gEx)

offsetMode = mode == "Offset (right of price)"

// ─────────────────────── TIMEFRAME SANITY CHECK ───────────────────────
okTF = timeframe.in_seconds(htf) > timeframe.in_seconds(timeframe.period)

// ─────────────── LIVE HTF AGGREGATION (non-repainting) ───────────────
newP = timeframe.change(htf)
var float hO = na
var float hH = na
var float hL = na
var int   hS = 0

if newP or na(hO)
    hO := open
    hH := high
    hL := low
    hS := bar_index
else
    hH := math.max(hH, high)
    hL := math.min(hL, low)
hC = close

// ──────────────── ROLLING STORE OF CLOSED HTF CANDLES ────────────────
var aO = array.new<float>()   // open
var aH = array.new<float>()   // high
var aL = array.new<float>()   // low
var aC = array.new<float>()   // close
var aS = array.new<int>()     // first chart bar of the candle
var aE = array.new<int>()     // last  chart bar of the candle

if newP and bar_index > 0 and not na(hO[1])
    array.push(aO, hO[1])
    array.push(aH, hH[1])
    array.push(aL, hL[1])
    array.push(aC, close[1])
    array.push(aS, hS[1])
    array.push(aE, bar_index - 1)
    while array.size(aO) > numCandles
        array.shift(aO)
        array.shift(aH)
        array.shift(aL)
        array.shift(aC)
        array.shift(aS)
        array.shift(aE)

// ───────────────────────── DRAWING OBJECT POOLS ─────────────────────────
var aBox = array.new<box>()
var aWik = array.new<line>()
var aMid = array.new<line>()
var aSep = array.new<line>()

fitBoxes(a, n) =>
    while array.size(a) < n
        array.push(a, box.new(bar_index, close, bar_index, close,
             xloc = xloc.bar_index, bgcolor = na, border_color = na))
    while array.size(a) > n
        box.delete(array.pop(a))

fitLines(a, n, both) =>
    while array.size(a) < n
        array.push(a, line.new(bar_index, close, bar_index, close, xloc = xloc.bar_index,
             color = na, extend = both ? extend.both : extend.none))
    while array.size(a) > n
        line.delete(array.pop(a))

// ──────────────────────────── RENDER ────────────────────────────
var label tag = na

if barstate.islast and okTF
    n     = array.size(aO)
    total = n + 1                       // closed candles + the live one
    step  = bodyW + gapW

    // keep offset drawings inside Pine's 500-bars-into-the-future limit
    maxFit = math.max(1, int(math.floor((480.0 - gapBars - bodyW) / step)) + 1)
    startI = offsetMode ? math.max(0, total - maxFit) : 0
    shown  = total - startI

    fitBoxes(aBox, shown)
    fitLines(aWik, wickOn ? shown : 0, false)
    fitLines(aMid, midOn  ? shown : 0, false)
    fitLines(aSep, sepOn  ? shown : 0, true)

    int   tagX = 0
    float tagY = na

    for i = startI to total - 1
        j    = i - startI
        live = i == n

        o = live ? hO : array.get(aO, i)
        h = live ? hH : array.get(aH, i)
        l = live ? hL : array.get(aL, i)
        c = live ? hC : array.get(aC, i)
        s = live ? hS : array.get(aS, i)
        e = live ? bar_index : array.get(aE, i)

        int lft = 0
        int rgt = 0
        if offsetMode
            lft := bar_index + gapBars + j * step
            rgt := lft + bodyW
        else
            lft := s
            rgt := e
        cx = lft + int(math.floor((rgt - lft) / 2.0))

        up = c >= o
        bg = up ? upBg : dnBg
        bd = up ? upBd : dnBd

        // body
        b = array.get(aBox, j)
        box.set_lefttop(b, lft, math.max(o, c))
        box.set_rightbottom(b, rgt, math.min(o, c))
        box.set_bgcolor(b, bg)
        box.set_border_color(b, bdW > 0 ? bd : na)
        box.set_border_width(b, bdW)

        // wick
        if wickOn
            w = array.get(aWik, j)
            line.set_xy1(w, cx, l)
            line.set_xy2(w, cx, h)
            line.set_color(w, bd)
            line.set_width(w, wickW)

        // 50% level
        if midOn
            m = array.get(aMid, j)
            line.set_xy1(m, lft, math.avg(h, l))
            line.set_xy2(m, rgt, math.avg(h, l))
            line.set_color(m, midCol)
            line.set_style(m, line.style_dashed)

        // period separator (always at the real chart location)
        if sepOn
            sp = array.get(aSep, j)
            line.set_xy1(sp, s, l)
            line.set_xy2(sp, s, h)
            line.set_color(sp, sepCol)
            line.set_style(sp, line.style_dotted)

        if live
            tagX := cx
            tagY := h

    // timeframe tag
    if tagOn
        if na(tag)
            tag := label.new(tagX, tagY, "", xloc = xloc.bar_index,
                 style = label.style_label_down, color = color.new(color.gray, 100),
                 textcolor = chart.fg_color, size = size.small)
        label.set_xy(tag, tagX, tagY)
        label.set_text(tag, htf)

// ───────────── PREVIOUS CLOSED HTF HIGH / LOW / CLOSE ─────────────
var line lH = na
var line lL = na
var line lC = na

if barstate.islast and okTF and lvlOn and array.size(aH) > 0
    k  = array.size(aH) - 1
    pH = array.get(aH, k)
    pL = array.get(aL, k)
    pC = array.get(aC, k)
    if na(lH)
        lH := line.new(hS, pH, bar_index, pH, xloc = xloc.bar_index, extend = extend.right, style = line.style_dashed)
        lL := line.new(hS, pL, bar_index, pL, xloc = xloc.bar_index, extend = extend.right, style = line.style_dashed)
        lC := line.new(hS, pC, bar_index, pC, xloc = xloc.bar_index, extend = extend.right, style = line.style_dotted)
    line.set_xy1(lH, hS, pH), line.set_xy2(lH, bar_index, pH), line.set_color(lH, lvlCol)
    line.set_xy1(lL, hS, pL), line.set_xy2(lL, bar_index, pL), line.set_color(lL, lvlCol)
    line.set_xy1(lC, hS, pC), line.set_xy2(lC, bar_index, pC), line.set_color(lC, lvlCol)

// ───────────────────────── WRONG-TIMEFRAME WARNING ─────────────────────────
var label warn = na
if barstate.islast and not okTF
    if na(warn)
        warn := label.new(bar_index, close, "", xloc = xloc.bar_index,
             style = label.style_label_left, color = color.new(color.red, 15), textcolor = color.white)
    label.set_xy(warn, bar_index, close)
    label.set_text(warn, "⚠ Indicator timeframe (" + htf + ") must be higher than the chart timeframe (" + timeframe.period + ")")
````
