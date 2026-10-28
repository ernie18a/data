# Sogyo  RTH / RTH2 Gap Midpoint Zone (CE1 / CE2)

- url: https://www.tradingview.com/script/gcpbF4pk-Sogyo-RTH-RTH2-Gap-Midpoint-Zone-CE1-CE2/
- type: indicator
- pine_id: PUB;b14ac66f45784998ba2deb7b9d31494d
- version: 2.0

## Description

Sogyo (Sogyo no Kotowari, the twin fish) marks two midpoints of the opening gap and draws them as one zone. Price respects that zone more often than you’d expect: sometimes as a level it trades back to, sometimes as a wall it can’t get back through.

Most people use one close to measure the gap. Futures have two:

the RTH close at 16:14 ET
the RTH2 close at 16:59 ET, the settlement close

Sōgyo takes the 50% level of each gap and draws the zone between them:

CE1 = (prior 16:14 close + today’s 09:30 open) / 2
CE2 = (prior 16:59 close + today’s 09:30 open) / 2

When the settlement window (16:14 to 16:59) moves a lot, the two midpoints separate and the zone gets wide. Those are the days to pay attention to. The script flags them as “wide”.

WHAT YOU SEE ON THE CHART

The zone between CE1 and CE2, drawn from 09:30 ET, with its formation time and date to the right
Dashed and dotted lines at the prior RTH and RTH2 closes, which are the full gap-fill levels
Zones coloured by age: blue for the first 5 trading days, then grey, so fresh levels stand out from old ones
A table showing: RTH ATR, the gap and overnight range in points and in ATR, both CE levels, the zone width, and the day’s context

HOW I USE IT (NY AM, 09:30–12:00 ET)

At the open, read the context in the table:
GREEN: small gap (≤ 0.68 ATR) and a quiet overnight (≤ 0.45 ATR). The zone is valid confluence.
NEUTRAL: don’t put extra weight on the zone.
RED: big gap (> 0.68 ATR). Price usually treats the zone as a stop on the way to the full fill, not a wall.
SPLIT: the open sits between the two closes. Skip it.
The setup I watch most is the flipped wall. On a wide-zone day price breaks through the zone toward the fill, comes back, and the zone holds it off.
Use it as confluence alongside your own entries. It isn’t a signal on its own.

What the backtest says (my own testing, NQ 2018 & 2022–2026, ES 2023–2026):

The zone gets touched during NY AM on about 65% of days.
Flipped wall: after price breaks through and comes back, the zone holds about 53% of the time. On wide-zone days that’s about 55–57%. Zones of the same width placed at random gap levels hold about 49%.
That’s a small edge, not a magic line. Manage risk on every trade.

SETTINGS
Sessions (ET):

RTH (default 09:30–16:15): the close comes from the 16:14 bar
RTH2 (default 09:30–17:00): the close comes from the 16:59 bar
Overnight (default 18:00–09:30): used for the overnight-range filter

ATR & context:

RTH sessions to average (14): ATR here is a simple average of the RTH high-to-low ranges only, not the standard ATR
Red: gap > x ATR (0.68)
Green: overnight range ≤ x ATR (0.45)
Wide zone: width ≥ x % of price (0.05%)

Drawing:

Zone length: To last candle, or Until next zone
Zones to keep (10)
Label date format (HH:mm MM/dd)
Show CE1 / CE2 prices in the label
Show prior closes (full gap fill)
Text colour and text size

Colour:

Colour zones: By age or By context
Fresh for first N trading days (5)
Fresh colour, aged colour, grey out aged text

Table: on/off and position.

Works on intraday charts (1–15 min). Built and tested on NQ and ES; all times are New York time.

OPEN SOURCE
This is free and open source. Take it apart, improve it, test it on your own markets, and build on it. If you find something, share it back.

A NOTE FROM ME
I built this while working nights and studying, testing idea after idea that didn’t work until one did. Most of what I tested failed. I kept going anyway, because every failed test told me something.

If you’re in that place right now, where the backtests don’t work and the account isn’t where you want it, don’t give up. Believe in yourself more than the setbacks do. Test properly, be honest with your numbers, and keep showing up. You’ll get there.

- Unclehk2000

Not financial advice. Educational tool only. Past results don’t guarantee future results.

## Source Code

````pine
//@version=6
// This Source Code Form is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Unclehk2000
//
// Sōgyo (双魚) · Model 13: the RTH gap's twin midpoints. At 09:30, CE1 = (prior 16:14 close + 09:30 open) ÷ 2 and
// CE2 = (prior 16:59 close + 09:30 open) ÷ 2; the zone between them is drawn and carried right. The card reads the gap and
// the overnight range against the RTH ATR and grades the zone: GREEN (valid confluence), RED (a waypoint to the fill),
// SPLIT (the open sits between the two closes: skip) or NEUTRAL (don't weight).
// Concepts: ICT (Michael J. Huddleston), consequent encroachment of the RTH gap. Written from scratch.

indicator("Sōgyo CE1 / CE2 Zone", "Sōgyo", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

tz = "America/New_York"

// ═══════════════════════════════════════════════════════════════ Inputs
var g_V = "View"
themeI   = input.string("Auto", "Theme", options = ["Auto", "Dark", "Light"], group = g_V, tooltip = "Auto follows the chart background. The card, and text left at its default colour, follow it.", display = display.none)
layI     = input.string("Desktop", "Layout", options = ["Desktop", "Mobile"], group = g_V, tooltip = "Desktop: every row of the card. Mobile: a four-row card for a phone screen; the full wording stays in the tooltips. For a phone, use a separate chart layout set to Mobile, since layouts sync across devices.", display = display.none)
crdSzI   = input.string("Small", "Card text", options = ["Tiny", "Small", "Normal"], group = g_V, display = display.none)
lblSize  = input.string("Small", "Label text", options = ["Tiny", "Small", "Normal"], group = g_V, display = display.none)
txtColI  = input.color(#000001, "Label colour", group = g_V, tooltip = "Left at the default it follows the theme; pick any colour to override.", display = display.none)
dateFmt  = input.string("HH:mm MM/dd", "Label date format", group = g_V, display = display.none)

var g_S = "Sessions (ET)"
rthSess  = input.session("0930-1615", "RTH (close = 16:14 bar)", group = g_S, display = display.none)
rth2Sess = input.session("0930-1700", "RTH2 (close = 16:59 bar)", group = g_S, display = display.none)
onSess   = input.session("1800-0930", "Overnight", group = g_S, display = display.none)

var g_A = "ATR & context"
length   = input.int(14, "RTH sessions to average", minval = 1, group = g_A, tooltip = "The RTH ATR is read from 15-minute bars, so it is ready on a 1-minute chart without weeks of 1-minute history.", display = display.none)
gapRed   = input.float(0.68, "Red: gap > x ATR", step = 0.01, group = g_A, display = display.none)
onGreen  = input.float(0.45, "Green: overnight range ≤ x ATR", step = 0.01, group = g_A, display = display.none)
wideMin  = input.float(0.05, "Wide zone: width ≥ x % of price", step = 0.01, group = g_A, display = display.none)

var g_D = "Zones"
extMode  = input.string("To last candle", "Zone length", options = ["To last candle", "Until next zone"], group = g_D, display = display.none)
maxDays  = input.int(10, "Zones to keep", minval = 1, group = g_D, display = display.none)
showPx   = input.bool(true, "Show CE1 / CE2 prices in label", group = g_D, display = display.none)
showFill = input.bool(true, "Show prior closes (full gap fill)", group = g_D, display = display.none)

var g_C = "Colour"
colMode  = input.string("By age", "Colour zones", options = ["By age", "By context"], group = g_C, display = display.none)
ageDays  = input.int(5, "Fresh for first N trading days", minval = 1, group = g_C, display = display.none)
freshCol = input.color(color.new(color.blue, 70), "Fresh zone", group = g_C, display = display.none)
agedCol  = input.color(color.new(color.gray, 75), "Aged zone", group = g_C, display = display.none)
greyText = input.bool(true, "Grey out text of aged zones", group = g_C, display = display.none)

var g_T = "Card"
showTbl  = input.bool(true, "Card", group = g_T, inline = "t0", display = display.none)
tblPos   = input.string("Top right", "", options = ["Top left", "Top center", "Top right", "Middle left", "Middle right", "Bottom left", "Bottom center", "Bottom right"], group = g_T, inline = "t0", display = display.none)
cAcc     = input.color(#1e88e5, "Accent", group = g_T, inline = "t0", display = display.none)

if not timeframe.isintraday
    runtime.error("Use an intraday chart (1–15 min).")

// ═══════════════════════════════════════════════════════════════ Theme
bgLum  = 0.299 * color.r(chart.bg_color) + 0.587 * color.g(chart.bg_color) + 0.114 * color.b(chart.bg_color)
dark   = themeI == "Dark" or (themeI == "Auto" and bgLum < 128)
cTx    = dark ? #e6e9ef : #131722
cSub   = dark ? #9aa3b5 : #4a5163
cMu    = dark ? #5d6476 : #9aa1b2
cBody  = dark ? #161a23 : #f4f6f9
cBody2 = dark ? #1c2130 : #e9edf3
cNeu   = dark ? #3a3f4b : #d1d4dc
cOk    = dark ? #66bb6a : #2e7d32
cHot   = dark ? #ff8a65 : #d84315
cRed   = dark ? #ef5350 : #d32f2f
txtCol = color.r(txtColI) == 0 and color.g(txtColI) == 0 and color.b(txtColI) == 1 ? cTx : txtColI
tSize  = lblSize == "Tiny" ? size.tiny : lblSize == "Normal" ? size.normal : size.small
crdSz  = crdSzI == "Tiny" ? size.tiny : crdSzI == "Normal" ? size.normal : size.small
bool mob = layI == "Mobile"

// ── Session flags ───────────────────────────────────────
inRTH  = not na(time(timeframe.period, rthSess, tz))
inRTH2 = not na(time(timeframe.period, rth2Sess, tz))
inON   = not na(time(timeframe.period, onSess, tz))
rthStart = inRTH and not inRTH[1]
rthEnd   = not inRTH and inRTH[1]
onStart  = inON and not inON[1]

// ── RTH ATR from 15-minute bars: the average high − low of the last N completed RTH sessions (no future data: a session
// counts only once it has closed). Needs ~N × 27 fifteen-minute bars instead of N × 405 one-minute bars.
rthAtr() =>
    var array<float> rs = array.new<float>()
    var float h = na
    var float l = na
    bool inS = not na(time(timeframe.period, rthSess, tz))
    if inS and not inS[1]
        h := high
        l := low
    else if inS
        h := math.max(h, high)
        l := math.min(l, low)
    if not inS and inS[1] and not na(h)
        rs.push(h - l)
        if rs.size() > length
            rs.shift()
    [rs.size() == length ? rs.avg() : na, rs.size()]
atrTF = timeframe.in_seconds() <= 900 ? "15" : timeframe.period
[atrHTF, atrN] = request.security(syminfo.tickerid, atrTF, rthAtr())

// ── State ───────────────────────────────────────────────
var array<float> ranges = array.new<float>()
var float rHi    = na
var float rLo    = na
var float c1     = na
var float c2     = na
var float onHi   = na
var float onLo   = na
var float atrVal = na
var float O      = na
var float ce1    = na
var float ce2    = na
var float gapPts = na
var float onPts  = na
var string ctx   = "—"
var string fDate = ""
var int dayCount = 0
var bool split   = false
var bool wide    = false

var array<box>   zBoxes  = array.new<box>()
var array<label> zLbls   = array.new<label>()
var array<line>  f1Lines = array.new<line>()
var array<line>  f2Lines = array.new<line>()
var array<label> f1Lbls  = array.new<label>()
var array<label> f2Lbls  = array.new<label>()
var array<int>   zDay    = array.new<int>()
var array<color> zCtxCol = array.new<color>()

// the ATR: the 15-minute reading, or the chart's own sessions while that is not ready
float atrNow = nz(atrHTF, atrVal)

// Overnight range 18:00–09:29
if onStart
    onHi := high
    onLo := low
else if inON
    onHi := math.max(onHi, high)
    onLo := math.min(onLo, low)

// ── 09:30: build today's zone from yesterday's closes ───
if rthStart
    dayCount += 1
    O := open
    if not na(c1) and not na(c2)
        ce1 := (c1 + O) / 2
        ce2 := (c2 + O) / 2
        cm = (c1 + c2) / 2
        gapPts := math.abs(O - cm)
        onPts  := onHi - onLo
        split  := math.sign(O - c1) != math.sign(O - c2)
        if not na(atrNow)
            ctx := split ? "SPLIT — skip" : gapPts / atrNow > gapRed ? "RED — waypoint to fill" : onPts / atrNow <= onGreen ? "GREEN — valid confluence" : "NEUTRAL — don't weight"
        else
            ctx := "— (ATR building)"
        wide  := math.abs(ce1 - ce2) / O * 100 >= wideMin
        fDate := str.format_time(time, dateFmt, tz)
        prevDate = str.format_time(time - 86400000, "MM/dd", tz)
        ctxCol = str.startswith(ctx, "GREEN") ? color.new(color.green, 70) : str.startswith(ctx, "RED") ? color.new(color.red, 75) : str.startswith(ctx, "SPLIT") ? color.new(color.orange, 75) : color.new(#7E57C2, 70)
        // "Until next zone": freeze the previous zone where this one starts
        if extMode == "Until next zone" and zBoxes.size() > 0
            zBoxes.get(0).set_right(time)
            zLbls.get(0).set_x(time)
            if showFill and f1Lines.size() > 0
                f1Lines.get(0).set_x2(time)
                f2Lines.get(0).set_x2(time)
                f1Lbls.get(0).set_x(time)
                f2Lbls.get(0).set_x(time)
        mid = (ce1 + ce2) / 2
        txt = fDate + " Sōgyo" + (wide ? " (wide)" : "") + (showPx ? "  CE1 " + str.tostring(ce1, format.mintick) + " / CE2 " + str.tostring(ce2, format.mintick) : "")
        zBoxes.unshift(box.new(time, math.max(ce1, ce2), time, math.min(ce1, ce2), xloc = xloc.bar_time, border_color = color.new(freshCol, 0), bgcolor = freshCol))
        zLbls.unshift(label.new(time, mid, txt, xloc = xloc.bar_time, style = label.style_label_left, color = #ffffff00, textcolor = txtCol, size = tSize))
        zDay.unshift(dayCount)
        zCtxCol.unshift(ctxCol)
        if showFill
            f1Lines.unshift(line.new(time, c1, time, c1, xloc = xloc.bar_time, color = color.new(freshCol, 0), style = line.style_dashed))
            f2Lines.unshift(line.new(time, c2, time, c2, xloc = xloc.bar_time, color = color.new(freshCol, 0), style = line.style_dotted))
            f1Lbls.unshift(label.new(time, c1, "RTH close " + prevDate, xloc = xloc.bar_time, style = label.style_label_left, color = #ffffff00, textcolor = txtCol, size = tSize))
            f2Lbls.unshift(label.new(time, c2, "RTH2 close " + prevDate, xloc = xloc.bar_time, style = label.style_label_left, color = #ffffff00, textcolor = txtCol, size = tSize))
        // keep only the last N zones
        if zBoxes.size() > maxDays
            zBoxes.pop().delete()
            zLbls.pop().delete()
            zDay.pop()
            zCtxCol.pop()
        if f1Lines.size() > maxDays
            f1Lines.pop().delete()
            f2Lines.pop().delete()
            f1Lbls.pop().delete()
            f2Lbls.pop().delete()
    rHi := high
    rLo := low
else if inRTH
    rHi := math.max(rHi, high)
    rLo := math.min(rLo, low)

// ── Every bar: grow to the current candle, place text after it, colour by age ──
n = zBoxes.size()
if n > 0
    for i = 0 to n - 1
        grow = extMode == "To last candle" or i == 0
        if grow
            zBoxes.get(i).set_right(time)
            zLbls.get(i).set_x(time)
            if showFill and i < f1Lines.size()
                f1Lines.get(i).set_x2(time)
                f2Lines.get(i).set_x2(time)
                f1Lbls.get(i).set_x(time)
                f2Lbls.get(i).set_x(time)
        age  = dayCount - zDay.get(i)                 // 0 on the formation day
        aged = age >= ageDays
        c = colMode == "By context" ? zCtxCol.get(i) : aged ? agedCol : freshCol
        zBoxes.get(i).set_bgcolor(c)
        zBoxes.get(i).set_border_color(color.new(c, 0))
        tc = colMode == "By age" and aged and greyText ? color.gray : txtCol
        zLbls.get(i).set_textcolor(tc)
        if showFill and i < f1Lines.size()
            f1Lines.get(i).set_color(color.new(c, 0))
            f2Lines.get(i).set_color(color.new(c, 0))
            f1Lbls.get(i).set_textcolor(tc)
            f2Lbls.get(i).set_textcolor(tc)

// Closes update after the 09:30 snapshot
if inRTH
    c1 := close
if inRTH2
    c2 := close

// Session done: store RTH range; the chart's own ATR (a fallback while the 15-minute one loads)
if rthEnd and not na(rHi)
    ranges.push(rHi - rLo)
    if ranges.size() > length
        ranges.shift()
    atrVal := ranges.size() == length ? ranges.avg() : na

plot(atrNow, "RTH ATR (pts)", display = display.data_window)

// ═══════════════════════════════════════════════════════════════ Card
// The house card: an accent stripe, a header bar with the context pill, a tinted body; five columns (stripe · key ·
// wording · value · aside), monospace, every cell with its tooltip.
posOf(string s) =>
    switch s
        "Top left"      => position.top_left
        "Top center"    => position.top_center
        "Top right"     => position.top_right
        "Middle left"   => position.middle_left
        "Middle right"  => position.middle_right
        "Bottom left"   => position.bottom_left
        "Bottom center" => position.bottom_center
        => position.bottom_right
CR = mob ? 4 : 9
var table t   = na
var int   tOf = 0
if barstate.isfirst and showTbl
    tOf := tblPos == "Top left" or tblPos == "Top center" ? 1 : 0
    t := table.new(posOf(tblPos), 5, CR + tOf, bgcolor = #00000000, frame_width = 0, border_width = 0)
    if tOf == 1
        t.cell(0, 0, "", height = 3.5, bgcolor = #00000000)
        t.merge_cells(0, 0, 4, 0)
    t.merge_cells(1, tOf, 3, tOf)
    t.merge_cells(2, tOf + CR - 1, 4, tOf + CR - 1)
cl(int c, int r, string s, color fg, color bg, string tip = "", string ha = text.align_left, bool b = false) =>
    t.cell(c, r, s, text_color = fg, bgcolor = bg, text_size = crdSz, text_halign = ha, tooltip = tip, text_font_family = font.family_monospace, text_formatting = b ? text.format_bold : text.format_none)
row(int r, string key, string txt, string v, string aside, string tip, color vfg = na, color afg = na) =>
    t.cell(0, r, "", bgcolor = cAcc, width = 0.25)
    cl(1, r, key, cMu, cBody, tip, text.align_center)
    cl(2, r, txt, cTx, cBody, tip)
    cl(3, r, v, na(vfg) ? cTx : vfg, cBody, tip, text.align_center, true)
    cl(4, r, aside, na(afg) ? cMu : afg, cBody, tip, text.align_center)
f(x) => na(x) ? "—" : str.tostring(x, "#,##0.00")
fA(x) => na(x) ? "—" : str.tostring(x, "0.00") + "×"
if showTbl and barstate.islast and not na(t)
    float gA = na(atrNow) or na(gapPts) ? na : gapPts / atrNow
    float oA = na(atrNow) or na(onPts) ? na : onPts / atrNow
    string cw  = str.startswith(ctx, "GREEN") ? "GREEN" : str.startswith(ctx, "RED") ? "RED" : str.startswith(ctx, "SPLIT") ? "SPLIT" : str.startswith(ctx, "NEUTRAL") ? "NEUTRAL" : "ATR…"
    color  pbg = cw == "GREEN" ? cOk : cw == "RED" ? cRed : cw == "SPLIT" ? #ff9800 : cw == "NEUTRAL" ? #7e57c2 : cNeu
    color  pfg = cw == "ATR…" ? cTx : #ffffff
    string ctxTip = "GREEN: overnight range ≤ " + str.tostring(onGreen, "0.00") + " ATR, a valid confluence. RED: gap > " + str.tostring(gapRed, "0.00") + " ATR, the zone is a waypoint to the full fill. SPLIT: the 09:30 open sits between the 16:14 and 16:59 closes, skip. NEUTRAL: neither, don't weight it."
    string atrTip = "RTH ATR(" + str.tostring(length) + ") = the average high − low of the last " + str.tostring(length) + " RTH sessions (09:30–16:14), read from 15-minute bars" + (na(atrHTF) ? ": " + str.tostring(atrN) + " of " + str.tostring(length) + " sessions loaded so far." : ".")
    int r = tOf
    t.cell(0, r, "", bgcolor = cAcc, width = 0.25)
    cl(1, r, "◆ SŌGYO · CE1 / CE2", #ffffff, cAcc, "Sōgyo, Model 13: the RTH gap's twin midpoints, formed at 09:30.", text.align_left, true)
    cl(4, r, cw, pfg, pbg, ctxTip, text.align_center, true)
    if not mob
        t.cell(0, r + 1, "", bgcolor = cAcc, width = 0.25)
        cl(1, r + 1, "", cMu, cBody2)
        cl(2, r + 1, "formed " + (fDate == "" ? "—" : fDate), cMu, cBody2)
        cl(3, r + 1, "pts", cMu, cBody2, "", text.align_center)
        cl(4, r + 1, "ATR", cMu, cBody2, "", text.align_center)
        row(r + 2, "CE1", "16:14 close ↔ 09:30", f(ce1), "", "CE1 = (prior RTH close at 16:14 + 09:30 open) ÷ 2.")
        row(r + 3, "CE2", "16:59 close ↔ 09:30", f(ce2), "", "CE2 = (prior RTH2 close at 16:59 + 09:30 open) ÷ 2.")
        row(r + 4, "WIDTH", "zone" + (wide ? " · wide" : ""), f(math.abs(ce1 - ce2)), na(O) ? "" : str.tostring(math.abs(ce1 - ce2) / O * 100, "0.00") + "%", "Distance between CE1 and CE2. Wide = at least " + str.tostring(wideMin, "0.00") + "% of price.", na, wide ? cHot : na)
        row(r + 5, "GAP", "09:30 vs prior closes", f(gapPts), fA(gA), "Gap = |09:30 open − the midpoint of the two prior closes|. Red above " + str.tostring(gapRed, "0.00") + " ATR (" + f(gapRed * atrNow) + " pts).", na, nz(gA) > gapRed ? cRed : na)
        row(r + 6, "ON", "overnight 18:00–09:29", f(onPts), fA(oA), "Overnight range, 18:00 → 09:29. Green at or under " + str.tostring(onGreen, "0.00") + " ATR (" + f(onGreen * atrNow) + " pts).", na, not na(oA) and oA <= onGreen ? cOk : na)
        row(r + 7, "ATR", "RTH ATR(" + str.tostring(length) + ")", f(atrNow), na(atrHTF) ? str.tostring(atrN) + "/" + str.tostring(length) : "red " + f(gapRed * atrNow), atrTip)
        t.cell(0, r + 8, "", bgcolor = cAcc, width = 0.25)
        cl(1, r + 8, "CTX", cMu, cBody, ctxTip, text.align_center)
        cl(2, r + 8, ctx, cw == "ATR…" ? cSub : pbg, cBody, ctxTip, text.align_left, true)
    else
        row(r + 1, "CE", f(ce1) + " / " + f(ce2), f(math.abs(ce1 - ce2)), "", "CE1 / CE2 and the zone's width in points.")
        row(r + 2, "GAP·ON", fA(gA) + " · " + fA(oA), "", "", "Gap and overnight range in RTH ATR. " + ctxTip, na, na)
        t.cell(0, r + 3, "", bgcolor = cAcc, width = 0.25)
        cl(1, r + 3, "CTX", cMu, cBody, ctxTip, text.align_center)
        cl(2, r + 3, ctx, cw == "ATR…" ? cSub : pbg, cBody, ctxTip, text.align_left, true)
````
