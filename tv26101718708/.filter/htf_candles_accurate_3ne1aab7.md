# HTF Candles (Accurate)

- url: https://www.tradingview.com/script/3NE1AaB7-HTF-Candles-Accurate/
- type: indicator
- pine_id: PUB;211802457f4944c48efbbf69f2345402
- version: 1.0

## Description

HTF Candles (Accurate)

See the last few candles of several timeframes right next to your live price action — without ever leaving your chart. Trade a lower timeframe while keeping the higher-timeframe picture in view at all times.

What it does

The indicator draws a small group of recent candles for each timeframe you turn on, just to the right of the current market. A label above each group shows the timeframe (for example 1H, 4H, 1D) and a live countdown to that candle's close. The right-most candle in every group is the one currently forming.

Each candle is drawn at its true price level, so the higher- and lower-timeframe structure lines up with the price on your chart.

Accurate by design

Switch your chart to any of the displayed timeframes and the candles match exactly — open, high, low and close. Whether a timeframe is higher or lower than your current chart, the candles stay true to the real ones, so what you see projected is what you'd see if you changed timeframe.

Features


Up to 6 independent timeframe slots, each with its own number of candles
Works for timeframes both above and below your current chart
Live countdown to each candle's close
Fully adjustable colors for up/down bodies, borders and wicks
Adjustable spacing, padding and candle width
Optional filter to show only timeframes higher than the chart


Inputs

Higher Timeframes — Turn on each slot, pick its timeframe, and choose how many candles to show.

Layout — Distance from the live price, space between candles, space between timeframe groups, and candle width.

Styling — Separate colors for up/down bodies, borders and wicks.

Labels — Show or hide the timeframe label and the countdown, and set the label color.

This indicator is a visualization tool. It does not generate buy or sell signals.

## Source Code

````pine
//@version=6
// =====================================================================
//  HTF Candles (Accurate) — projects the last N candles of several
//  timeframes to the right of the current price action.
//
//  Correctness:
//   * Timeframes HIGHER than or equal to the chart are aggregated with
//     request.security (same boundary as the native chart candles).
//   * Timeframes LOWER than the chart (e.g. 1h shown on a 4h chart) are
//     read with request.security_lower_tf, which returns every intrabar
//     sub-candle — so they match the real lower-timeframe candles too.
// =====================================================================
indicator("HTF Candles (Accurate)", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ----------------------- Higher Timeframe slots -----------------------
gTF = "Higher Timeframes"
en1 = input.bool(false, "HTF 1", inline="h1", group=gTF)
tf1 = input.timeframe("5",   "", inline="h1", group=gTF)
n1  = input.int(4, "", minval=1, maxval=20, inline="h1", group=gTF)

en2 = input.bool(true,  "HTF 2", inline="h2", group=gTF)
tf2 = input.timeframe("420", "", inline="h2", group=gTF)   // 420 min = 7h
n2  = input.int(4, "", minval=1, maxval=20, inline="h2", group=gTF)

en3 = input.bool(true,  "HTF 3", inline="h3", group=gTF)
tf3 = input.timeframe("60",  "", inline="h3", group=gTF)
n3  = input.int(4, "", minval=1, maxval=20, inline="h3", group=gTF)

en4 = input.bool(true,  "HTF 4", inline="h4", group=gTF)
tf4 = input.timeframe("240", "", inline="h4", group=gTF)   // 240 min = 4h
n4  = input.int(4, "", minval=1, maxval=20, inline="h4", group=gTF)

en5 = input.bool(true,  "HTF 5", inline="h5", group=gTF)
tf5 = input.timeframe("1D",  "", inline="h5", group=gTF)
n5  = input.int(4, "", minval=1, maxval=20, inline="h5", group=gTF)

en6 = input.bool(false, "HTF 6", inline="h6", group=gTF)
tf6 = input.timeframe("1W",  "", inline="h6", group=gTF)
n6  = input.int(4, "", minval=1, maxval=20, inline="h6", group=gTF)

maxHTF     = input.int(6, "Show at most this many timeframes", minval=1, maxval=6, group=gTF)
onlyHigher = input.bool(false, "Only timeframes higher than the chart", group=gTF)

// ----------------------------- Layout --------------------------------
gL   = "Layout"
padding = input.int(15, "Padding from current candles", minval=0, group=gL)
spcC    = input.int(1,  "Space between candles",        minval=0, group=gL)
spcH    = input.int(10, "Space between timeframes",     minval=0, group=gL)
cw      = input.int(4,  "Candle width (bars)",          minval=1, group=gL)

// ----------------------------- Styling -------------------------------
gS  = "Styling"
upC = input.color(#089981, "Body up",   inline="bd", group=gS)
dnC = input.color(#f23645, "Body down", inline="bd", group=gS)
upB = input.color(#089981, "Border up",   inline="br", group=gS)
dnB = input.color(#f23645, "Border down", inline="br", group=gS)
upW = input.color(#089981, "Wick up",   inline="wk", group=gS)
dnW = input.color(#f23645, "Wick down", inline="wk", group=gS)

// ----------------------------- Labels --------------------------------
gLb     = "Labels"
showLbl = input.bool(true, "Show timeframe label", group=gLb)
showRem = input.bool(true, "Show remaining time",  group=gLb)
lblCol  = input.color(color.gray, "Label color",   group=gLb)

// --------------------- Drawing-object storage ------------------------
var box[]   boxes  = array.new<box>()
var line[]  lines  = array.new<line>()
var label[] labels = array.new<label>()

clearAll() =>
    for b in boxes
        box.delete(b)
    array.clear(boxes)
    for ln in lines
        line.delete(ln)
    array.clear(lines)
    for lb in labels
        label.delete(lb)
    array.clear(labels)

// ----------------------------- Helpers -------------------------------
f_pad(int v) =>
    (v < 10 ? "0" : "") + str.tostring(v)

f_fmt(int ms) =>
    int s  = ms > 0 ? int(ms / 1000) : 0
    int hh = int(s / 3600)
    int mm = int((s % 3600) / 60)
    int ss = s % 60
    f_pad(hh) + ":" + f_pad(mm) + ":" + f_pad(ss)

f_name(string tf) =>
    int sec = timeframe.in_seconds(tf)
    string r = str.tostring(sec) + "s"
    if sec % 604800 == 0
        r := str.tostring(int(sec / 604800)) + "W"
    else if sec % 86400 == 0
        r := str.tostring(int(sec / 86400)) + "D"
    else if sec % 3600 == 0
        r := str.tostring(int(sec / 3600)) + "H"
    else if sec % 60 == 0
        r := str.tostring(int(sec / 60)) + "m"
    r

// ------------- Collect the last N candles to display -----------------
// Returns display arrays (oldest -> newest, last element is the current/
// developing candle) plus the close time of that current candle.
collect(string tf, int depth) =>
    var float[] cO = array.new_float()
    var float[] cH = array.new_float()
    var float[] cL = array.new_float()
    var float[] cC = array.new_float()
    float[] dispO = array.new_float()
    float[] dispH = array.new_float()
    float[] dispL = array.new_float()
    float[] dispC = array.new_float()
    int devTC = na
    int chartSec = timeframe.in_seconds()
    int tfSec    = timeframe.in_seconds(tf)

    if tfSec >= chartSec
        // ----- Higher or equal timeframe: standard security -----
        [o, h, l, c, tc] = request.security(syminfo.tickerid, tf, [open, high, low, close, time_close], lookahead = barmerge.lookahead_on)
        if not na(tc) and ta.change(tc) != 0 and not na(o[1])
            array.push(cO, o[1])
            array.push(cH, h[1])
            array.push(cL, l[1])
            array.push(cC, c[1])
            while array.size(cO) > depth
                array.shift(cO)
                array.shift(cH)
                array.shift(cL)
                array.shift(cC)
        devTC := tc
        if barstate.islast
            int sz = array.size(cO)
            int startI = math.max(0, sz - (depth - 1))
            for i = startI to sz - 1
                array.push(dispO, array.get(cO, i))
                array.push(dispH, array.get(cH, i))
                array.push(dispL, array.get(cL, i))
                array.push(dispC, array.get(cC, i))
            if not na(o)
                array.push(dispO, o)
                array.push(dispH, h)
                array.push(dispL, l)
                array.push(dispC, c)
    else
        // ----- Lower timeframe: read every intrabar sub-candle -----
        [aO, aH, aL, aC, aT] = request.security_lower_tf(syminfo.tickerid, tf, [open, high, low, close, time_close])
        // Push the previous chart bar's sub-candles (all fully closed).
        float[] pO = aO[1]
        float[] pH = aH[1]
        float[] pL = aL[1]
        float[] pC = aC[1]
        if not na(pO)
            int psz = array.size(pO)
            if psz > 0
                for i = 0 to psz - 1
                    array.push(cO, array.get(pO, i))
                    array.push(cH, array.get(pH, i))
                    array.push(cL, array.get(pL, i))
                    array.push(cC, array.get(pC, i))
                while array.size(cO) > depth + 2
                    array.shift(cO)
                    array.shift(cH)
                    array.shift(cL)
                    array.shift(cC)
        if barstate.islast
            // Closed candles from earlier bars + this bar's sub-candles.
            float[] allO = array.copy(cO)
            float[] allH = array.copy(cH)
            float[] allL = array.copy(cL)
            float[] allC = array.copy(cC)
            int csz = array.size(aO)
            if csz > 0
                for i = 0 to csz - 1
                    array.push(allO, array.get(aO, i))
                    array.push(allH, array.get(aH, i))
                    array.push(allL, array.get(aL, i))
                    array.push(allC, array.get(aC, i))
                devTC := array.get(aT, csz - 1)
            int asz = array.size(allO)
            int startI = math.max(0, asz - depth)
            for i = startI to asz - 1
                array.push(dispO, array.get(allO, i))
                array.push(dispH, array.get(allH, i))
                array.push(dispL, array.get(allL, i))
                array.push(dispC, array.get(allC, i))
    [dispO, dispH, dispL, dispC, devTC]

// ------------------------- Draw one candle ---------------------------
// xc is the candle's CENTER bar index. The body is drawn symmetrically
// around it and the wick runs exactly through xc, so it stays centered.
mkCandle(int xc, float o, float h, float l, float c) =>
    bool  up   = c >= o
    color bg   = up ? upC : dnC
    color bd   = up ? upB : dnB
    color wk   = up ? upW : dnW
    float top  = math.max(o, c)
    float bot  = math.min(o, c)
    int   half = math.max(1, int(cw / 2))
    box bx = box.new(xc - half, top, xc + half, bot, xloc = xloc.bar_index, border_color = bd, border_width = 1, bgcolor = bg)
    array.push(boxes, bx)
    line wln = line.new(xc, h, xc, l, xloc = xloc.bar_index, color = wk, width = 1)
    array.push(lines, wln)

// ----------------------- Draw one HTF group --------------------------
drawGroup(string tf, float[] dO, float[] dH, float[] dL, float[] dC, int devTC, int xStart) =>
    int   half   = math.max(1, int(cw / 2))
    int   step   = 2 * half + spcC
    int   xc     = xStart + half
    int   xFirst = xc
    float topH   = na
    int   cnt    = array.size(dO)
    if cnt > 0
        for i = 0 to cnt - 1
            mkCandle(xc, array.get(dO, i), array.get(dH, i), array.get(dL, i), array.get(dC, i))
            topH := na(topH) ? array.get(dH, i) : math.max(topH, array.get(dH, i))
            xc += step
    int xLast = xc - step
    if showLbl and cnt > 0 and not na(topH)
        int xCen = int(math.round((xFirst + xLast) / 2.0))
        string t = f_name(tf)
        if showRem and not na(devTC)
            t := t + "  " + f_fmt(devTC - timenow)
        label lb = label.new(xCen, topH, t, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = color.new(color.black, 100), textcolor = lblCol, size = size.normal)
        array.push(labels, lb)
    cnt > 0 ? xLast + half + spcH : xStart

// ---------------------- Pull data for all slots ----------------------
[d1O, d1H, d1L, d1C, t1c] = collect(tf1, n1)
[d2O, d2H, d2L, d2C, t2c] = collect(tf2, n2)
[d3O, d3H, d3L, d3C, t3c] = collect(tf3, n3)
[d4O, d4H, d4L, d4C, t4c] = collect(tf4, n4)
[d5O, d5H, d5L, d5C, t5c] = collect(tf5, n5)
[d6O, d6H, d6L, d6C, t6c] = collect(tf6, n6)

f_show(bool en, string tf) =>
    en and (not onlyHigher or timeframe.in_seconds(tf) > timeframe.in_seconds())

// ------------------------------ Render -------------------------------
if barstate.islast
    clearAll()
    int x     = bar_index + padding
    int shown = 0
    if f_show(en1, tf1) and shown < maxHTF
        x := drawGroup(tf1, d1O, d1H, d1L, d1C, t1c, x)
        shown += 1
    if f_show(en2, tf2) and shown < maxHTF
        x := drawGroup(tf2, d2O, d2H, d2L, d2C, t2c, x)
        shown += 1
    if f_show(en3, tf3) and shown < maxHTF
        x := drawGroup(tf3, d3O, d3H, d3L, d3C, t3c, x)
        shown += 1
    if f_show(en4, tf4) and shown < maxHTF
        x := drawGroup(tf4, d4O, d4H, d4L, d4C, t4c, x)
        shown += 1
    if f_show(en5, tf5) and shown < maxHTF
        x := drawGroup(tf5, d5O, d5H, d5L, d5C, t5c, x)
        shown += 1
    if f_show(en6, tf6) and shown < maxHTF
        x := drawGroup(tf6, d6O, d6H, d6L, d6C, t6c, x)
        shown += 1
````
