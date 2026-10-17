# TRDR Zone Multi-Session ORB

- url: https://www.tradingview.com/script/rP5Auea9-TRDR-Zone-Multi-Session-ORB/
- type: indicator
- pine_id: PUB;01d40e6038f248209d6c523c2828b59b
- version: 1.0

## Description

This indicator maps the opening range for every major session on the same chart, then tells you how often price actually followed through after that range locked.

WHAT IT DOES

Each enabled session builds an opening range from its first N minutes. Once that window closes, the range is locked and projected through the rest of the session.

You get:

A filled range box (one color)

Dotted lines at 25%, 50%, and 75% of the range

Dashed targets at 0.5, 1.0, 1.5, 2.0, 2.5, and 3.0 times the range, above and below

A stats table showing how often, after the range formed, price broke the high, broke the low, or reached each target

Sessions can overlap. That is intentional. London and New York do not take turns. When they stack, both ranges stay on the chart.

SESSIONS (New York time, all adjustable)

Sydney: 17:00–02:00

Asia: 19:00–04:00

London: 03:00–12:00

New York: 09:30–16:00

Overnight / ETH: 18:00–09:30 (off by default)

Custom session (off by default)

Toggle any session on or off. Change its clock. Change its opening-range length independently. Leave "Include Sunday" on for futures. Turn it off for cash symbols.

HOW TO READ IT

The box is the range. If price is still inside it, the session has not chosen a side yet.

The dotted lines are location, not signals. Mid-range is balance. 25% and 75% show you whether a "break" is a real expansion or just a probe.

The dashed lines are measured move targets. They are not take-profit commands. They are a map of how far this session's range usually travels when it does travel.

The stats table is the filter. If a session rarely reaches +2R, stop trading it like it does. Process over hope.

STATS (read them correctly)

Numbers are session hit rates, not time-in-market.

After the opening range locks, the rest of that session is scored:

Broke high / broke low: price traded strictly through the OR extreme

Target hit: price reached that level or beyond

Samples: how many completed sessions were counted

Total: all enabled sessions combined

Unfinished sessions are not counted. A range that never had time to lock is not counted. Set lookback days to 0 to use all available history.

BEST USE

1, 3, 5, or 15 minute charts

Futures (ES, NQ, CL, GC) and FX

If your chart bar is longer than the OR window, the first session bar becomes the range

Turn off sessions you do not trade. Turn off targets you do not use. If the chart gets noisy, hide labels and drop "Sessions to draw."

THIS IS NOT

A buy/sell signal. A strategy. A promise that the next range will break.

It is a repeatable map of session structure and a record of what price has actually done after that structure formed.

If you cannot explain why you are fading or following a range, you are guessing. This gives you the levels. The journal still has to do the rest.

Trade with discipline. Learn with purpose. Build with systems.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TRDRZone

//@version=6
indicator(
     title             = "TRDR Zone Multi-Session ORB",
     shorttitle        = "TZ ORB",
     overlay           = true,
     max_boxes_count   = 500,
     max_lines_count   = 500,
     max_labels_count  = 500)

// ─────────────────────────────────────────────────────────────────────────────
// TRDR Zone Multi-Session Opening Range Breakout
//
// How it works
// • Each enabled session builds an opening range from its first N minutes.
// • The finished range is a filled box in the range color.
// • Dotted lines split that box at 25%, 50%, and 75%.
// • Dashed target lines print at ± each enabled multiple of the range.
// • Every line and the box extend to the end of that session.
// • Overlapping sessions draw independently on top of each other.
//
// Stats
// • After the range locks, the rest of that session is scored.
// • A high/low break means price traded strictly through the OR extreme.
// • A target hit means price reached that exact level or beyond.
// • Percentages are session frequency, not time-in-market.
// • Total is the sum of enabled session samples.
//
// Best on 1 / 3 / 5 / 15 minute charts. If the chart bar is longer than the
// OR window, the first session bar becomes the range.
// ─────────────────────────────────────────────────────────────────────────────

// ═════════════════════════════════════════════════════════════════════════════
// Types
// ═════════════════════════════════════════════════════════════════════════════

type DrawPack
    box          rng
    line         p25
    line         p50
    line         p75
    array<line>  tgts
    array<label> labels

type Sess
    string           id
    string           shortId
    bool             inWin
    bool             orLive
    bool             orDone
    int              t0
    int              tOrEnd
    int              lastT
    float            hi
    float            lo
    float            postHi
    float            postLo
    DrawPack         draw
    array<DrawPack>  hist
    int              n
    int              brkH
    int              brkL
    array<int>       up
    array<int>       dn

// ═════════════════════════════════════════════════════════════════════════════
// Inputs
// ═════════════════════════════════════════════════════════════════════════════

grpG = "General"
tzIn = input.string(
     "America/New_York",
     "Timezone",
     options = ["America/New_York", "America/Chicago", "America/Denver", "America/Los_Angeles", "Europe/London", "Asia/Tokyo", "Exchange"],
     group   = grpG,
     tooltip = "Session clocks are read in this timezone. Use New York for standard CME and FX session times.")
includeSun = input.bool(
     true,
     "Include Sunday / 24h session days",
     group   = grpG,
     tooltip = "Leave on for futures (Sunday ETH). Turn off for cash-session symbols.")
keepN = input.int(
     5,
     "Sessions to draw (per market)",
     minval  = 1,
     maxval  = 20,
     group   = grpG,
     tooltip = "Older drawings are removed so TradingView object limits are not hit.")
showLabels = input.bool(false, "Show level labels", group = grpG)
showInternals = input.bool(true, "Show 25 / 50 / 75% range lines", group = grpG)

grpS = "Sessions"
enSyd = input.bool(true,  "Sydney",     inline = "syd", group = grpS)
sSyd  = input.session("1700-0200", "", inline = "syd", group = grpS)
orSyd = input.int(15, "OR min", minval = 1, maxval = 240, inline = "syd", group = grpS)

enAsi = input.bool(true,  "Asia",       inline = "asi", group = grpS)
sAsi  = input.session("1900-0400", "", inline = "asi", group = grpS)
orAsi = input.int(15, "OR min", minval = 1, maxval = 240, inline = "asi", group = grpS)

enLon = input.bool(true,  "London",     inline = "lon", group = grpS)
sLon  = input.session("0300-1200", "", inline = "lon", group = grpS)
orLon = input.int(15, "OR min", minval = 1, maxval = 240, inline = "lon", group = grpS)

enNy  = input.bool(true,  "New York",   inline = "ny",  group = grpS)
sNy   = input.session("0930-1600", "", inline = "ny",  group = grpS)
orNy  = input.int(15, "OR min", minval = 1, maxval = 240, inline = "ny",  group = grpS)

enEth = input.bool(false, "Overnight",  inline = "eth", group = grpS)
sEth  = input.session("1800-0930", "", inline = "eth", group = grpS)
orEth = input.int(30, "OR min", minval = 1, maxval = 240, inline = "eth", group = grpS)

enCst = input.bool(false, "Custom",     inline = "cst", group = grpS)
sCst  = input.session("0800-1200", "", inline = "cst", group = grpS)
orCst = input.int(15, "OR min", minval = 1, maxval = 240, inline = "cst", group = grpS)

grpT = "Targets"
t1On  = input.bool(true, "", inline = "t1", group = grpT)
t1Val = input.float(0.5, "Target 1  x range", minval = 0.0, step = 0.25, inline = "t1", group = grpT)
t2On  = input.bool(true, "", inline = "t2", group = grpT)
t2Val = input.float(1.0, "Target 2  x range", minval = 0.0, step = 0.25, inline = "t2", group = grpT)
t3On  = input.bool(true, "", inline = "t3", group = grpT)
t3Val = input.float(1.5, "Target 3  x range", minval = 0.0, step = 0.25, inline = "t3", group = grpT)
t4On  = input.bool(true, "", inline = "t4", group = grpT)
t4Val = input.float(2.0, "Target 4  x range", minval = 0.0, step = 0.25, inline = "t4", group = grpT)
t5On  = input.bool(true, "", inline = "t5", group = grpT)
t5Val = input.float(2.5, "Target 5  x range", minval = 0.0, step = 0.25, inline = "t5", group = grpT)
t6On  = input.bool(true, "", inline = "t6", group = grpT)
t6Val = input.float(3.0, "Target 6  x range", minval = 0.0, step = 0.25, inline = "t6", group = grpT)

grpV = "Visuals"
rngCol  = input.color(#3D8BFF, "Range color", group = grpV)
tgtCol  = input.color(#FFFFFF, "Target color", group = grpV)
rngFill = input.int(88, "Range fill transparency", minval = 0, maxval = 100, group = grpV)
rngW    = input.int(2, "Range border width", minval = 1, maxval = 4, group = grpV)
inW     = input.int(1, "25 / 50 / 75 width", minval = 1, maxval = 3, group = grpV)
tgW     = input.int(1, "Target width", minval = 1, maxval = 3, group = grpV)

grpSt = "Stats"
showStats = input.bool(
     true,
     "Show stats table",
     group   = grpSt,
     tooltip = "Percent of completed sessions, after the opening range locked, where price traded through the OR high / low or each target.")
statDays = input.int(0, "Stats lookback (days, 0 = all)", minval = 0, maxval = 5000, group = grpSt)
statPosIn = input.string(
     "Top Right",
     "Table position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left"],
     group   = grpSt)
statSizeIn = input.string("Small", "Table text", options = ["Tiny", "Small", "Normal"], group = grpSt)

// ═════════════════════════════════════════════════════════════════════════════
// Derived settings
// ═════════════════════════════════════════════════════════════════════════════

tz        = tzIn == "Exchange" ? syminfo.timezone : tzIn
daySuffix = includeSun ? ":1234567" : ":23456"
NT        = 6

tVals = array.from(t1Val, t2Val, t3Val, t4Val, t5Val, t6Val)
tOns  = array.from(t1On,  t2On,  t3On,  t4On,  t5On,  t6On)

statPos =
     statPosIn == "Top Left"     ? position.top_left     :
     statPosIn == "Bottom Right" ? position.bottom_right :
     statPosIn == "Bottom Left"  ? position.bottom_left  :
     statPosIn == "Middle Right" ? position.middle_right :
     statPosIn == "Middle Left"  ? position.middle_left  :
     position.top_right

statSize =
     statSizeIn == "Tiny"   ? size.tiny   :
     statSizeIn == "Normal" ? size.normal :
     size.small

COL_BG    = #0A0A0A
COL_ROW   = #121212
COL_HEAD  = #15AA46
COL_FRAME = #15AA46
COL_TEXT  = #F5F5F5
COL_MUTED = #9CA3AF

// ═════════════════════════════════════════════════════════════════════════════
// Helpers
// ═════════════════════════════════════════════════════════════════════════════

fullSess(string raw) =>
    str.contains(raw, ":") ? raw : raw + daySuffix

inWindow(string raw) =>
    not na(time(timeframe.period, fullSess(raw), tz))

fmtMult(float m) =>
    str.tostring(m, m == math.round(m) ? "#.0" : "#.##")

fmtPct(int hits, int n) =>
    n <= 0 ? "—" : str.tostring(100.0 * hits / n, "#.0") + "%"

lookbackOk(int tStart) =>
    statDays <= 0 or na(tStart) ? true : tStart >= timenow - statDays * 86400000

setHLine(line ln, float y, int x2) =>
    if not na(ln)
        line.set_y1(ln, y)
        line.set_y2(ln, y)
        line.set_x2(ln, x2)

mkLine(int x1, float y, int x2, color c, string style, int w) =>
    line.new(x1, y, x2, y, xloc = xloc.bar_time, extend = extend.none, color = c, style = style, width = w)

mkLabel(int x, float y, string txt, color c) =>
    label.new(x, y, txt, xloc = xloc.bar_time, yloc = yloc.price, style = label.style_none, textcolor = c, size = size.small)

deletePack(DrawPack p) =>
    if not na(p)
        if not na(p.rng)
            box.delete(p.rng)
        if not na(p.p25)
            line.delete(p.p25)
        if not na(p.p50)
            line.delete(p.p50)
        if not na(p.p75)
            line.delete(p.p75)
        if not na(p.tgts)
            tsz = array.size(p.tgts)
            if tsz > 0
                for i = 0 to tsz - 1
                    line.delete(array.get(p.tgts, i))
        if not na(p.labels)
            lsz = array.size(p.labels)
            if lsz > 0
                for i = 0 to lsz - 1
                    label.delete(array.get(p.labels, i))

extendPack(DrawPack p, int x2) =>
    if not na(p)
        if not na(p.rng)
            box.set_right(p.rng, x2)
        if not na(p.p25)
            line.set_x2(p.p25, x2)
        if not na(p.p50)
            line.set_x2(p.p50, x2)
        if not na(p.p75)
            line.set_x2(p.p75, x2)
        if not na(p.tgts)
            tsz = array.size(p.tgts)
            if tsz > 0
                for i = 0 to tsz - 1
                    ln = array.get(p.tgts, i)
                    if not na(ln)
                        line.set_x2(ln, x2)
        if not na(p.labels)
            lsz = array.size(p.labels)
            if lsz > 0
                for i = 0 to lsz - 1
                    lb = array.get(p.labels, i)
                    if not na(lb)
                        label.set_x(lb, x2)

pushLbl(DrawPack p, int x, float y, string txt, color c) =>
    if showLabels
        array.push(p.labels, mkLabel(x, y, txt, c))

fracY(Sess s, float frac) =>
    s.lo + frac * (s.hi - s.lo)

syncRangeGeom(DrawPack p, Sess s, int x2, string boxTxt) =>
    if not na(p)
        if not na(p.rng)
            box.set_top(p.rng, s.hi)
            box.set_bottom(p.rng, s.lo)
            box.set_right(p.rng, x2)
            box.set_text(p.rng, boxTxt)
        if showInternals and not na(s.hi) and not na(s.lo) and s.hi > s.lo
            setHLine(p.p25, fracY(s, 0.25), x2)
            setHLine(p.p50, fracY(s, 0.50), x2)
            setHLine(p.p75, fracY(s, 0.75), x2)
        if showLabels and not na(p.labels)
            lsz = array.size(p.labels)
            if lsz >= 5
                label.set_xy(array.get(p.labels, 0), x2, s.hi)
                label.set_xy(array.get(p.labels, 1), x2, fracY(s, 0.75))
                label.set_xy(array.get(p.labels, 2), x2, fracY(s, 0.50))
                label.set_xy(array.get(p.labels, 3), x2, fracY(s, 0.25))
                label.set_xy(array.get(p.labels, 4), x2, s.lo)

newPack(Sess s, int x1, int x2) =>
    p = DrawPack.new()
    p.tgts := array.new<line>()
    p.labels := array.new<label>()
    p.rng := box.new(
         left         = x1,
         top          = s.hi,
         right        = x2,
         bottom       = s.lo,
         xloc         = xloc.bar_time,
         bgcolor      = color.new(rngCol, rngFill),
         border_color = rngCol,
         border_width = rngW,
         border_style = line.style_solid,
         text         = s.id + " OR...",
         text_color   = rngCol,
         text_size    = size.small,
         text_halign  = text.align_left,
         text_valign  = text.align_top)
    if showInternals
        y25 = fracY(s, 0.25)
        y50 = fracY(s, 0.50)
        y75 = fracY(s, 0.75)
        p.p25 := mkLine(x1, y25, x2, rngCol, line.style_dotted, inW)
        p.p50 := mkLine(x1, y50, x2, rngCol, line.style_dotted, inW)
        p.p75 := mkLine(x1, y75, x2, rngCol, line.style_dotted, inW)
    pushLbl(p, x2, s.hi,          s.shortId + " ORH", rngCol)
    pushLbl(p, x2, fracY(s, 0.75), s.shortId + " 75%", rngCol)
    pushLbl(p, x2, fracY(s, 0.50), s.shortId + " 50%", rngCol)
    pushLbl(p, x2, fracY(s, 0.25), s.shortId + " 25%", rngCol)
    pushLbl(p, x2, s.lo,          s.shortId + " ORL", rngCol)
    p

spawnTargets(DrawPack p, Sess s, int x1, int x2) =>
    if not na(p) and not na(s.hi) and not na(s.lo) and s.hi > s.lo
        rng = s.hi - s.lo
        for i = 0 to NT - 1
            if array.get(tOns, i)
                m  = array.get(tVals, i)
                up = s.hi + m * rng
                dn = s.lo - m * rng
                array.push(p.tgts, mkLine(x1, up, x2, tgtCol, line.style_dashed, tgW))
                array.push(p.tgts, mkLine(x1, dn, x2, tgtCol, line.style_dashed, tgW))
                pushLbl(p, x2, up, s.shortId + " +" + fmtMult(m), tgtCol)
                pushLbl(p, x2, dn, s.shortId + " -" + fmtMult(m), tgtCol)

archiveDraw(Sess s) =>
    if not na(s.draw)
        array.push(s.hist, s.draw)
        s.draw := na
        while array.size(s.hist) > keepN
            deletePack(array.shift(s.hist))

commitStats(Sess s) =>
    rng = not na(s.hi) and not na(s.lo) ? s.hi - s.lo : 0.0
    if s.orDone and rng > 0 and not na(s.postHi) and not na(s.postLo) and lookbackOk(s.t0)
        s.n := s.n + 1
        if s.postHi > s.hi
            s.brkH := s.brkH + 1
        if s.postLo < s.lo
            s.brkL := s.brkL + 1
        for i = 0 to NT - 1
            m = array.get(tVals, i)
            if s.postHi >= s.hi + m * rng
                array.set(s.up, i, array.get(s.up, i) + 1)
            if s.postLo <= s.lo - m * rng
                array.set(s.dn, i, array.get(s.dn, i) + 1)

initSess(Sess s, string id, string shortId) =>
    s.id := id
    s.shortId := shortId
    s.inWin := false
    s.orLive := false
    s.orDone := false
    s.t0 := na
    s.tOrEnd := na
    s.lastT := na
    s.hi := na
    s.lo := na
    s.postHi := na
    s.postLo := na
    s.draw := na
    s.hist := array.new<DrawPack>()
    s.n := 0
    s.brkH := 0
    s.brkL := 0
    s.up := array.new<int>(NT, 0)
    s.dn := array.new<int>(NT, 0)

processSess(Sess s, bool enabled, string raw, int orMins) =>
    nowIn = enabled and inWindow(raw)
    newS  = nowIn and not s.inWin
    xNow  = time_close

    if newS
        archiveDraw(s)
        s.t0 := time
        s.tOrEnd := time + orMins * 60 * 1000
        s.hi := high
        s.lo := low
        s.orLive := true
        s.orDone := false
        s.postHi := na
        s.postLo := na
        s.lastT := xNow
        s.draw := newPack(s, s.t0, xNow)
    else if nowIn and s.orLive and time < s.tOrEnd
        s.hi := math.max(s.hi, high)
        s.lo := math.min(s.lo, low)
        s.lastT := xNow
        syncRangeGeom(s.draw, s, xNow, s.id + " OR...")
    else if nowIn and s.orLive and time >= s.tOrEnd
        s.orLive := false
        s.orDone := true
        s.postHi := high
        s.postLo := low
        s.lastT := xNow
        syncRangeGeom(s.draw, s, xNow, s.id + " OR")
        spawnTargets(s.draw, s, s.t0, xNow)
    else if nowIn and s.orDone
        s.postHi := math.max(s.postHi, high)
        s.postLo := math.min(s.postLo, low)
        s.lastT := xNow
        extendPack(s.draw, xNow)

    if not nowIn and s.inWin
        freezeX = nz(s.lastT, time[1])
        if s.orLive
            s.orLive := false
            syncRangeGeom(s.draw, s, freezeX, s.id + " OR")
        else
            commitStats(s)
        extendPack(s.draw, freezeX)

    s.inWin := nowIn

// ═════════════════════════════════════════════════════════════════════════════
// Session objects
// ═════════════════════════════════════════════════════════════════════════════

var Sess syd = Sess.new()
var Sess asi = Sess.new()
var Sess lon = Sess.new()
var Sess ny  = Sess.new()
var Sess eth = Sess.new()
var Sess cst = Sess.new()

if barstate.isfirst
    initSess(syd, "Sydney",    "Syd")
    initSess(asi, "Asia",      "Asia")
    initSess(lon, "London",    "Lon")
    initSess(ny,  "New York",  "NY")
    initSess(eth, "Overnight", "ETH")
    initSess(cst, "Custom",    "Cst")

processSess(syd, enSyd, sSyd, orSyd)
processSess(asi, enAsi, sAsi, orAsi)
processSess(lon, enLon, sLon, orLon)
processSess(ny,  enNy,  sNy,  orNy)
processSess(eth, enEth, sEth, orEth)
processSess(cst, enCst, sCst, orCst)

// ═════════════════════════════════════════════════════════════════════════════
// Stats table
// ═════════════════════════════════════════════════════════════════════════════

var table tb = na

put(int c, int r, string txt, color bg, color fg, string halign) =>
    table.cell(tb, c, r, txt, bgcolor = bg, text_color = fg, text_size = statSize, text_halign = halign)

if barstate.islast
    if showStats
        enabled = array.new<Sess>()
        if enSyd
            array.push(enabled, syd)
        if enAsi
            array.push(enabled, asi)
        if enLon
            array.push(enabled, lon)
        if enNy
            array.push(enabled, ny)
        if enEth
            array.push(enabled, eth)
        if enCst
            array.push(enabled, cst)

        nSess = array.size(enabled)
        int nTgtOn = 0
        for i = 0 to NT - 1
            if array.get(tOns, i)
                nTgtOn := nTgtOn + 1

        nCols = 2 + nSess
        nRows = 4 + nTgtOn * 2

        if not na(tb)
            table.delete(tb)
        tb := table.new(
             statPos,
             math.max(nCols, 2),
             math.max(nRows, 2),
             bgcolor      = COL_BG,
             frame_color  = COL_FRAME,
             frame_width  = 1,
             border_color = #1E2622,
             border_width = 1)

        int totN = 0
        int totH = 0
        int totL = 0
        totUp = array.new<int>(NT, 0)
        totDn = array.new<int>(NT, 0)
        if nSess > 0
            for i = 0 to nSess - 1
                s = array.get(enabled, i)
                totN := totN + s.n
                totH := totH + s.brkH
                totL := totL + s.brkL
                for t = 0 to NT - 1
                    array.set(totUp, t, array.get(totUp, t) + array.get(s.up, t))
                    array.set(totDn, t, array.get(totDn, t) + array.get(s.dn, t))

        put(0, 0, "ORB hit %", COL_HEAD, #0A0A0A, text.align_left)
        if nSess > 0
            for i = 0 to nSess - 1
                put(i + 1, 0, array.get(enabled, i).shortId, COL_HEAD, #0A0A0A, text.align_center)
        put(nSess + 1, 0, "Total", COL_HEAD, #0A0A0A, text.align_center)

        put(0, 1, "Samples", COL_ROW, COL_MUTED, text.align_left)
        if nSess > 0
            for i = 0 to nSess - 1
                put(i + 1, 1, str.tostring(array.get(enabled, i).n), COL_ROW, COL_TEXT, text.align_center)
        put(nSess + 1, 1, str.tostring(totN), COL_ROW, COL_TEXT, text.align_center)

        put(0, 2, "Broke high", COL_BG, COL_TEXT, text.align_left)
        if nSess > 0
            for i = 0 to nSess - 1
                s = array.get(enabled, i)
                put(i + 1, 2, fmtPct(s.brkH, s.n), COL_BG, COL_TEXT, text.align_center)
        put(nSess + 1, 2, fmtPct(totH, totN), COL_BG, COL_TEXT, text.align_center)

        put(0, 3, "Broke low", COL_ROW, COL_TEXT, text.align_left)
        if nSess > 0
            for i = 0 to nSess - 1
                s = array.get(enabled, i)
                put(i + 1, 3, fmtPct(s.brkL, s.n), COL_ROW, COL_TEXT, text.align_center)
        put(nSess + 1, 3, fmtPct(totL, totN), COL_ROW, COL_TEXT, text.align_center)

        int row = 4
        for t = 0 to NT - 1
            if array.get(tOns, t)
                m = array.get(tVals, t)
                bgU = row % 2 == 0 ? COL_BG : COL_ROW
                put(0, row, "+" + fmtMult(m) + "R", bgU, tgtCol, text.align_left)
                if nSess > 0
                    for i = 0 to nSess - 1
                        s = array.get(enabled, i)
                        put(i + 1, row, fmtPct(array.get(s.up, t), s.n), bgU, COL_TEXT, text.align_center)
                put(nSess + 1, row, fmtPct(array.get(totUp, t), totN), bgU, COL_TEXT, text.align_center)
                row := row + 1

                bgD = row % 2 == 0 ? COL_BG : COL_ROW
                put(0, row, "-" + fmtMult(m) + "R", bgD, tgtCol, text.align_left)
                if nSess > 0
                    for i = 0 to nSess - 1
                        s = array.get(enabled, i)
                        put(i + 1, row, fmtPct(array.get(s.dn, t), s.n), bgD, COL_TEXT, text.align_center)
                put(nSess + 1, row, fmtPct(array.get(totDn, t), totN), bgD, COL_TEXT, text.align_center)
                row := row + 1
    else if not na(tb)
        table.delete(tb)
        tb := na
````
