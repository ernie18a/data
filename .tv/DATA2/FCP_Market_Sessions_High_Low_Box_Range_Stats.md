<!-- tradingview-pine-id: PUB;0a92ab49a0654cf98ae39276d2d71656 -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# FCP | Market Sessions | High Low Box & Range Stats

Source: https://www.tradingview.com/script/UQJSpgaX-FCP-Market-Sessions-High-Low-Box-Range-Stats/

## Description

Marks the Sydney, Tokyo, London and New York sessions, tracks each
one's high and low, and carries those levels forward to the next
session open.

WHAT IT DRAWS

• A shaded box spanning each session's time window and price range.
• High and low lines that extend to the next session's open.
• Range extension lines projected from the session high and low at
  configurable multiples of the session range (0.5x, 1x, 2x by
  default), with optional multiplier labels.
• A stats table showing each active session's current range as a
  percentage of its own average range over the last N sessions.
  Rows for disabled sessions are hidden.

HOW IT WORKS

Session boundaries and session extremes are not read from the chart's
candles. They are computed from 5-minute data through a lower-timeframe
request, so the levels are identical whether you are on a 15-minute
chart or a 4-hour chart. The chart is only the canvas.

The session in progress updates on every tick rather than on bar close,
so the box and its high and low lines follow price in real time.

SETTINGS

Session timezone — sessions are defined in this timezone, so the
windows stay fixed regardless of the symbol's exchange timezone.
Accepts a UTC offset (GMT+0, GMT+3) or an IANA name (Europe/London).

Look-back — how many past sessions to keep drawn.

Each session has its own on/off switch, time window, colour and line
width, so you can define custom windows instead of the defaults.

Range extensions — three independent multipliers; set any of them to
0 to hide one. Line style, width and transparency are adjustable.

Range stats — the averaging window, panel corner and text size.

NOTES

Works on timeframes up to and including 1 day. On higher timeframes
nothing is drawn.

Session times are fixed to the selected timezone and do not shift with
daylight saving time. If your sessions are defined in a DST-observing
timezone, adjust the windows twice a year or enter an IANA timezone
name.

---

## Source Code

````pine
//@version=6
indicator("FCP | Market Sessions | High Low Box & Range Stats", overlay = true, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500)

grpGeneral = "■■■■■ General ■■■■■"
sessionTZ  = input.string("GMT+0", "Session timezone", group = grpGeneral, tooltip = " UTC offset such as GMT+0 / GMT+3, or an IANA name such as Europe/London.", display = display.none)
lookBack   = input.int(20, "Look-back (sessions)", minval = 1, maxval = 100, group = grpGeneral, display = display.none)

grpTokyo  = "■■■■■ Tokyo ■■■■■"
showTokyo = input.bool(true, "Show Tokyo session", group = grpTokyo)
specTokyo = input.session("0000-0900", "Session", group = grpTokyo, display = display.none)
colTokyo  = input.color(#2979FF, "Color", inline = "tokStyle", group = grpTokyo)
wTokyo    = input.int(1, "Width", minval = 1, maxval = 5, inline = "tokStyle", group = grpTokyo, display = display.none)

grpLondon  = "■■■■■ London ■■■■■"
showLondon = input.bool(true, "Show London session", group = grpLondon)
specLondon = input.session("0700-1600", "Session", group = grpLondon, display = display.none)
colLondon  = input.color(#39FF55, "Color", inline = "lonStyle", group = grpLondon)
wLondon    = input.int(1, "Width", minval = 1, maxval = 5, inline = "lonStyle", group = grpLondon, display = display.none)

grpNewYork  = "■■■■■ New York ■■■■■"
showNewYork = input.bool(true, "Show New York session", group = grpNewYork)
specNewYork = input.session("1200-2100", "Session", group = grpNewYork, display = display.none)
colNewYork  = input.color(#FF3D3D, "Color", inline = "nykStyle", group = grpNewYork)
wNewYork    = input.int(1, "Width", minval = 1, maxval = 5, inline = "nykStyle", group = grpNewYork, display = display.none)

grpSydney  = "■■■■■ Sydney ■■■■■"
showSydney = input.bool(false, "Show Sydney session", group = grpSydney)
specSydney = input.session("2100-0600", "Session", group = grpSydney, display = display.none)
colSydney  = input.color(#FFB300, "Color", inline = "sydStyle", group = grpSydney)
wSydney    = input.int(1, "Width", minval = 1, maxval = 5, inline = "sydStyle", group = grpSydney, display = display.none)

grpBox   = "■■■■■ Session Box ■■■■■"
showHL   = input.bool(true, "Show high & low lines", group = grpBox)
boxFill  = input.int(15, "Shade strength (%, 0 = off)", minval = 0, maxval = 100, group = grpBox, display = display.none)
boxTransp = 100 - boxFill

grpExt     = "■■■■■ Range Extensions ■■■■■"
showExt    = input.bool(true, "Show range extensions", group = grpExt)
ext1       = input.float(0.5, "Extension 1 (x range, 0 = off)", minval = 0, step = 0.1, group = grpExt, display = display.none)
ext2       = input.float(1.0, "Extension 2 (x range, 0 = off)", minval = 0, step = 0.1, group = grpExt, display = display.none)
ext3       = input.float(2.0, "Extension 3 (x range, 0 = off)", minval = 0, step = 0.1, group = grpExt, display = display.none)
extCount   = input.int(1, "Draw on last N sessions", minval = 1, maxval = 100, group = grpExt, display = display.none)
extStyleIn = input.string("Dotted", "Line style", options = ["Solid", "Dashed", "Dotted"], group = grpExt, display = display.none)
extWidth   = input.int(1, "Line width", minval = 1, maxval = 5, group = grpExt, display = display.none)
extTransp  = input.int(40, "Line transparency", minval = 0, maxval = 100, group = grpExt, display = display.none)
showExtLbl = input.bool(true, "Show multiplier labels", group = grpExt, display = display.none)

grpStats  = "■■■■■ Range Stats ■■■■■"
showStats = input.bool(true, "Show range stats panel", group = grpStats)
statsAvg  = input.int(22, "Average over last N sessions", minval = 1, maxval = 200, group = grpStats, display = display.none)
statsPos  = input.string("Top right", "Panel corner", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = grpStats, display = display.none)
statsSize = input.string("Normal", "Panel text size", options = ["Tiny", "Small", "Normal"], group = grpStats, display = display.none)

extStyle = extStyleIn == "Solid" ? line.style_solid : extStyleIn == "Dashed" ? line.style_dashed : line.style_dotted

type Sess
    bool         show
    string       spec
    color        col
    int          w
    string       name
    bool         wasIn  = false
    int          openT  = na
    float        curH   = na
    float        curL   = na
    line         lnH    = na
    line         lnL    = na
    box          bx     = na
    array<line>  ext    = na
    array<label> extLbl = na
    array<line>  hist   = na
    array<int>   cyc    = na
    array<box>   hbox   = na
    array<float> rng    = na
    array<float> inArr  = na
    array<line>  extH   = na
    array<int>   extCyc = na

var array<Sess> sessions = array.new<Sess>()
if barstate.isfirst
    array.push(sessions, Sess.new(showTokyo,   specTokyo,   colTokyo,   wTokyo,   "TOK", ext = array.new<line>(), extLbl = array.new<label>(), hist = array.new<line>(), cyc = array.new<int>(), hbox = array.new<box>(), rng = array.new<float>(), extH = array.new<line>(), extCyc = array.new<int>()))
    array.push(sessions, Sess.new(showLondon,  specLondon,  colLondon,  wLondon,  "LON", ext = array.new<line>(), extLbl = array.new<label>(), hist = array.new<line>(), cyc = array.new<int>(), hbox = array.new<box>(), rng = array.new<float>(), extH = array.new<line>(), extCyc = array.new<int>()))
    array.push(sessions, Sess.new(showNewYork, specNewYork, colNewYork, wNewYork, "NY",  ext = array.new<line>(), extLbl = array.new<label>(), hist = array.new<line>(), cyc = array.new<int>(), hbox = array.new<box>(), rng = array.new<float>(), extH = array.new<line>(), extCyc = array.new<int>()))
    array.push(sessions, Sess.new(showSydney,  specSydney,  colSydney,  wSydney,  "SYD", ext = array.new<line>(), extLbl = array.new<label>(), hist = array.new<line>(), cyc = array.new<int>(), hbox = array.new<box>(), rng = array.new<float>(), extH = array.new<line>(), extCyc = array.new<int>()))

f_inSess(simple string spec) =>
    na(time(timeframe.period, spec, sessionTZ)) ? 0.0 : 1.0

scanTF = timeframe.in_seconds() >= 300 ? "5" : timeframe.period

[ltfH, ltfL, ltfT, inTok, inLon, inNyk, inSyd] = request.security_lower_tf(syminfo.tickerid, scanTF, [high, low, time, f_inSess(specTokyo), f_inSess(specLondon), f_inSess(specNewYork), f_inSess(specSydney)])

f_addLine(Sess s, line ln) =>
    array.push(s.hist, ln)
    last = array.size(s.cyc) - 1
    if last >= 0
        array.set(s.cyc, last, array.get(s.cyc, last) + 1)

f_trimCycles(Sess s) =>
    while array.size(s.cyc) > lookBack
        n = array.shift(s.cyc)
        if n > 0
            for i = 1 to n
                line.delete(array.shift(s.hist))

f_addExt(Sess s, line ln) =>
    array.push(s.extH, ln)
    last = array.size(s.extCyc) - 1
    if last >= 0
        array.set(s.extCyc, last, array.get(s.extCyc, last) + 1)

f_trimExt(Sess s) =>
    keep = math.min(extCount, lookBack)
    while array.size(s.extCyc) > keep
        n = array.shift(s.extCyc)
        if n > 0
            for i = 1 to n
                line.delete(array.shift(s.extH))

f_trimBox(array<box> arr) =>
    while array.size(arr) > lookBack
        box.delete(array.shift(arr))

f_avg(array<float> arr, int n) =>
    sz = array.size(arr)
    float out = na
    if sz > 0
        cnt = math.min(sz, n)
        float sum = 0.0
        for i = sz - cnt to sz - 1
            sum += array.get(arr, i)
        out := sum / cnt
    out

f_step(Sess s, float h, float l, int t, bool inS) =>
    extClr = color.new(s.col, extTransp)

    if inS and not s.wasIn
        if not na(s.lnH)
            line.set_x2(s.lnH, t)
            line.set_x2(s.lnL, t)
        for ln in s.ext
            line.set_x2(ln, t)
        for lb in s.extLbl
            label.delete(lb)
        array.clear(s.extLbl)
        array.clear(s.ext)

        s.openT := t
        s.curH  := h
        s.curL  := l
        array.push(s.cyc, 0)
        if showHL
            s.lnH := line.new(t, h, t, h, xloc = xloc.bar_time, color = s.col, width = s.w)
            s.lnL := line.new(t, l, t, l, xloc = xloc.bar_time, color = s.col, width = s.w)
            f_addLine(s, s.lnH)
            f_addLine(s, s.lnL)
        if boxFill > 0
            s.bx := box.new(t, h, t, l, xloc = xloc.bar_time, border_color = color.new(color.white, 100), bgcolor = color.new(s.col, boxTransp))
            array.push(s.hbox, s.bx)
        f_trimCycles(s)
        f_trimBox(s.hbox)

    else if inS
        s.curH := math.max(s.curH, h)
        s.curL := math.min(s.curL, l)

    else if s.wasIn
        R = s.curH - s.curL
        array.push(s.rng, R)
        while array.size(s.rng) > 300
            array.shift(s.rng)

        nxtX = s.openT + 86400000
        for j = 0 to 2
            dw = dayofweek(nxtX, sessionTZ)
            if dw == dayofweek.saturday or dw == dayofweek.sunday
                nxtX += 86400000
        if nxtX < t
            nxtX := t

        if not na(s.lnH)
            line.set_y1(s.lnH, s.curH)
            line.set_y2(s.lnH, s.curH)
            line.set_x2(s.lnH, nxtX)
            line.set_y1(s.lnL, s.curL)
            line.set_y2(s.lnL, s.curL)
            line.set_x2(s.lnL, nxtX)

        if showExt and R > 0
            array.push(s.extCyc, 0)
            mults = array.from(ext1, ext2, ext3)
            for m = 0 to 2
                mv = array.get(mults, m)
                if mv > 0
                    up = s.curH + R * mv
                    dn = s.curL - R * mv
                    lu = line.new(t, up, nxtX, up, xloc = xloc.bar_time, color = extClr, width = extWidth, style = extStyle)
                    ld = line.new(t, dn, nxtX, dn, xloc = xloc.bar_time, color = extClr, width = extWidth, style = extStyle)
                    array.push(s.ext, lu)
                    array.push(s.ext, ld)
                    f_addExt(s, lu)
                    f_addExt(s, ld)
                    if showExtLbl
                        txt = str.tostring(mv, "#.#") + "x"
                        array.push(s.extLbl, label.new(t, up, txt, xloc = xloc.bar_time, style = label.style_none, textcolor = extClr, size = size.small))
                        array.push(s.extLbl, label.new(t, dn, txt, xloc = xloc.bar_time, style = label.style_none, textcolor = extClr, size = size.small))
            f_trimExt(s)

    if inS
        if not na(s.bx)
            box.set_top(s.bx, s.curH)
            box.set_bottom(s.bx, s.curL)
            box.set_right(s.bx, t)

        if not na(s.lnH)
            line.set_y1(s.lnH, s.curH)
            line.set_y2(s.lnH, s.curH)
            line.set_x2(s.lnH, t)
            line.set_y1(s.lnL, s.curL)
            line.set_y2(s.lnL, s.curL)
            line.set_x2(s.lnL, t)

    s.wasIn := inS

f_live(Sess s) =>
    if s.wasIn and not na(s.curH)
        s.curH := math.max(s.curH, close)
        s.curL := math.min(s.curL, close)
        if not na(s.bx)
            box.set_top(s.bx, s.curH)
            box.set_bottom(s.bx, s.curL)
            box.set_right(s.bx, timenow)
        if not na(s.lnH)
            line.set_y1(s.lnH, s.curH)
            line.set_y2(s.lnH, s.curH)
            line.set_x2(s.lnH, timenow)
            line.set_y1(s.lnL, s.curL)
            line.set_y2(s.lnL, s.curL)
            line.set_x2(s.lnL, timenow)

canDraw = timeframe.in_seconds() <= 86400

if canDraw and array.size(sessions) == 4
    sTok = array.get(sessions, 0)
    sLon = array.get(sessions, 1)
    sNyk = array.get(sessions, 2)
    sSyd = array.get(sessions, 3)
    sTok.inArr := inTok
    sLon.inArr := inLon
    sNyk.inArr := inNyk
    sSyd.inArr := inSyd

    for i = 0 to array.size(sessions) - 1
        s = array.get(sessions, i)
        if s.show
            n = na(s.inArr) ? 0 : array.size(s.inArr)
            if n > 0
                for k = 0 to n - 1
                    f_step(s, array.get(ltfH, k), array.get(ltfL, k), array.get(ltfT, k), array.get(s.inArr, k) > 0)
            else
                f_step(s, high, low, time, not na(time(timeframe.period, s.spec, sessionTZ)))

            if barstate.islast
                f_live(s)

tblPos  = statsPos == "Top right" ? position.top_right : statsPos == "Top left" ? position.top_left : statsPos == "Bottom right" ? position.bottom_right : position.bottom_left
tblSize = statsSize == "Tiny" ? size.tiny : statsSize == "Normal" ? size.normal : size.small

var table stats = table.new(tblPos, 2, 5, bgcolor = color.new(color.gray, 85), frame_color = color.new(color.gray, 50), frame_width = 1, border_color = color.new(color.gray, 50), border_width = 1)

if barstate.islast and showStats and canDraw
    table.clear(stats, 0, 0, 1, 4)

    table.cell(stats, 0, 0, "SESSION", text_color = chart.fg_color, text_size = tblSize, text_halign = text.align_center)
    table.cell(stats, 1, 0, "vs AVG",  text_color = chart.fg_color, text_size = tblSize, text_halign = text.align_center)

    int row = 1
    for i = 0 to array.size(sessions) - 1
        s = array.get(sessions, i)
        if s.show and not na(s.curH)
            avgR = f_avg(s.rng, statsAvg)
            pct  = na(avgR) or avgR <= 0 ? "-" : str.tostring(100.0 * (s.curH - s.curL) / avgR, "#") + "%"
            table.cell(stats, 0, row, s.name, text_color = s.col, text_size = tblSize, text_halign = text.align_center)
            table.cell(stats, 1, row, pct,    text_color = s.col, text_size = tblSize, text_halign = text.align_center)
            row += 1
````
