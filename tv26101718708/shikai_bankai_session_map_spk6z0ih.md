# Shikai / Bankai Session Map

- url: https://www.tradingview.com/script/spK6z0ih-Shikai-Bankai-Session-Map/
- type: indicator
- pine_id: PUB;2e1ee6443cce4017b3ed74b2a8efbb3b
- version: 2.0

## Description

First, a caveat: index futures are carry-charge markets. NQ, ES, YM and RTY are priced off the cash index plus the cost of carry, so over time they drift upward. The long side has a structural tailwind and the short side is swimming against it. Read every level on this chart with that in mind. A long into a level works with the carry, and a short works against it.

Every trading day leaves a footprint overnight. Shikai / Bankai draws that footprint on your chart: the overnight range, its midpoint, and how each session builds on the one before. You can see where price is likely to travel, and when.

This is a confluence map, not a signal. Use it next to your own model. It’s open source, so take it, test it, break it and build on it.

If you’re still here, still studying, still showing up after the losing days, you’re already ahead of most people who started with you. Nobody hands you consistency. You build it one session at a time. Back yourself. Your edge comes from the reps nobody sees, so keep going.

How it works

The overnight range (18:00 → 09:29 ET) sets the map, and its midpoint is the level everything is built around. One toggle switches between two ways of trading it:

Mode	Window	What it does
Shikai (first release)	09:30 → 16:59 close	The all-day map, with the midpoint plus hot-block midpoints for Asia, London and NY PM
Bankai (full release)	09:30 → 11:00 hard stop	A time-bound NY AM program, with the entry windows shaded. If the midpoint isn’t reached by 11:00, the program is over
What you see
Midpoint map:
The overnight high and low, and the midpoint.
An “into mid” marker at 09:30: ▲ LONG when the midpoint is above the open, ▼ SHORT when it’s below.
Each day stays in its own lane. Only today’s lines run to the last candle.
Touch labels:
“Bankai ✓ mid hit 09:38 · 8 min”, “Shikai mid hit 10:12 · 42 min” or “Bankai over · mid not reached”.
Levels turn dashed once they’re reached.
Reclaim marker: shows when price goes through the midpoint and closes back on the other side.
Hot-block midpoints (Shikai): the midpoint of the widest 30-minute block so far in Asia, London and NY PM.
Bankai windows:
Primary: 09:31–09:41.
Secondary: 09:41–10:00.
Shading: it clears once the midpoint is hit.
Session candles:
Asia → Asia/London → London → London/NY → NY, drawn to the right of price.
25% and 50% ticks on the Asia, London and NY candles.
Asia and London 25% / 50% lines on the chart.
Stats table: worked out live from your chart.
Midpoint reach rate and median time to reach it.
London-vs-Asia regime and what NY did after it, with the all-days baseline beside it.
Today’s status.
Age colouring: drawings older than 5 trading days turn grey, so fresh levels stand out.
Settings

Mode

Shikai or Bankai

Sessions (ET)

Overnight range
Shikai watch window
Bankai program and its primary / secondary windows
Hot-block sessions (Asia, London, NY PM) and block length (30 min)

Midpoint map

Overnight high / low
Midpoint colour
Prior-day state average length (20)

Intraday markers

“Into mid” marker with long / short colours
Reclaim marker

Session candles

All five session times (fully adjustable)
Transition candles on/off
Offset, width and spacing
Colour and transparency
Wicks and high / low prices
25% tick, and 50% tick on body or range
25% / 50% lines
H/M/L/O lines (off by default)
Session open lines

Stats table

Show / hide
Lookback (252 days)
Position, text size and colours

Drawing

Line length: to the last candle, or until the watch window ends
Days to keep (3)
Label date format
Text colour and size
Fresh-for-N-days (5), then the aged colour

Use it on an intraday chart of 15 minutes or less. 1 minute is recommended for the Bankai windows.

Honest notes

I tested this on NQ 1-minute data (2018, 2022–2026). The rules were fixed first, built on 2018–24, then checked once on 2025–26.

Price reaches the midpoint on about 70% of days by the close and about 56% by 11:00. A level the same distance on the other side of the open gets reached almost as often, though. So it’s a map of how far price travels, not a magnet.
The timing is real. About 46% of the touches that happen by 11:00 land in 09:31–09:41.
Carry shows up on the long side. Trading into the midpoint stayed slightly positive long out of sample and turned negative short. Fading pops short lost clearly.
The reclaim marker is context, not an entry. Entering on the first reclaim close with a tight stop at the sweep extreme tested negative.

Use the map to frame the day, not to replace your execution. Not financial advice. Do your own testing.

Stay patient, stay hungry, and never stop believing in the work you’re putting in. The market rewards the ones who keep showing up.

— Unclehk2000

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Unclehk2000
//@version=6
indicator("Shikai / Bankai Session Map", "SB Map", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

tz = "America/New_York"

// ═══════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════
var g_D = "View"
themeI  = input.string("Auto", "Theme", options = ["Auto", "Dark", "Light"], group = g_D, tooltip = "Auto follows the chart background. Text and the colours left at their default follow it.", display = display.none)
lblSize = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = g_D, display = display.none)
txtColI = input.color(#000001, "Text colour", group = g_D, tooltip = "Left at the default it follows the theme; pick any colour to override.", display = display.none)
dateFmt = input.string("HH:mm MM/dd", "Label date format", group = g_D, display = display.none)
extMode = input.string("To last candle", "Line length", options = ["To last candle", "Until its watch window ends"], tooltip = "Midpoint-map lines stay inside their own trading day. Only today's lines run to the last candle.", group = g_D, display = display.none)
maxDays = input.int(3, "Days to keep", minval = 1, group = g_D, display = display.none)
ageDays = input.int(5, "Fresh for first N trading days", minval = 1, group = g_D, display = display.none)
agedCol = input.color(color.gray, "Aged colour", group = g_D, display = display.none)

var g_M = "Mode"
mode      = input.string("Shikai — all-day map", "Mode", options = ["Shikai — all-day map", "Bankai — NY AM program"], group = g_M, tooltip = "Shikai: the overnight midpoint map for the whole day (09:30 → 16:59 close), with hot-block midpoints.\nBankai: the same midpoint as a time-bound NY AM program (09:30 → hard stop), with the entry windows shaded.", display = display.none)
isBankai  = mode == "Bankai — NY AM program"

var g_S = "Shikai / Bankai sessions (ET)"
onSess  = input.session("1800-0930", "Overnight range (18:00 → 09:29)", group = g_S, display = display.none)
shkSess = input.session("0930-1700", "Shikai watch window (09:30 → 16:59 close)", group = g_S, display = display.none)
nySess  = input.session("0930-1100", "Bankai program (hard stop at the end)", group = g_S, display = display.none)
primWin = input.session("0931-0941", "Bankai primary window", inline = "p", group = g_S, display = display.none)
colPrim = input.color(color.new(color.green, 85), "", inline = "p", group = g_S, display = display.none)
secWin  = input.session("0941-1000", "Bankai secondary window", inline = "s", group = g_S, display = display.none)
colSec  = input.color(color.new(color.green, 93), "", inline = "s", group = g_S, display = display.none)

var g_L = "Midpoint map"
showON    = input.bool(true, "Overnight high / low", inline = "on", group = g_L, display = display.none)
colON     = input.color(color.gray, "", inline = "on", group = g_L, display = display.none)
colMid    = input.color(#ff9800, "Midpoint colour", group = g_L, display = display.none)
avgLen    = input.int(20, "Prior-day state: average length (days)", minval = 2, group = g_L, display = display.none)

var g_HB = "Hot-block midpoints (Shikai)"
blockLen = input.int(30, "Block length (minutes)", minval = 5, group = g_HB, display = display.none)
hbAsia   = input.session("2000-0000", "Asia", inline = "ha", group = g_HB, display = display.none)
showHA   = input.bool(true, "", inline = "ha", group = g_HB, display = display.none)
colHA    = input.color(color.purple, "", inline = "ha", group = g_HB, display = display.none)
hbLdn    = input.session("0200-0500", "London", inline = "hl", group = g_HB, display = display.none)
showHL   = input.bool(true, "", inline = "hl", group = g_HB, display = display.none)
colHL    = input.color(color.red, "", inline = "hl", group = g_HB, display = display.none)
hbPM     = input.session("1330-1600", "NY PM", inline = "hp", group = g_HB, display = display.none)
showHP   = input.bool(true, "", inline = "hp", group = g_HB, display = display.none)
colHP    = input.color(#00897b, "", inline = "hp", group = g_HB, display = display.none)

var g_C = "Intraday markers"
showInto = input.bool(true, "Mark the 'into the midpoint' side at 09:30", group = g_C, display = display.none)
colLong  = input.color(color.green, "Long", inline = "cc", group = g_C, display = display.none)
colShort = input.color(color.red, "Short", inline = "cc", group = g_C, display = display.none)
showRecl = input.bool(true, "Mark go-through-and-reclaim at the midpoint", group = g_C, display = display.none)

var g_SC = "Session candles"
showCandles = input.bool(true, "Show session candles (right of price)", group = g_SC, display = display.none)
cAsiaSess   = input.session("1800-0000", "Asia candle", group = g_SC, display = display.none)
cALSess     = input.session("0000-0200", "Asia → London candle", group = g_SC, display = display.none)
cLonSess    = input.session("0200-0500", "London candle", group = g_SC, display = display.none)
cLNSess     = input.session("0500-0800", "London → NY candle", group = g_SC, display = display.none)
cNySess     = input.session("0800-1700", "NY candle", group = g_SC, display = display.none)
showTrans   = input.bool(true, "Show the two transition candles", group = g_SC, display = display.none)
cOffset     = input.int(15, "Offset from chart (bars)", minval = 1, group = g_SC, display = display.none)
cWidth      = input.int(4, "Candle width (bars)", minval = 1, maxval = 20, group = g_SC, display = display.none)
cSpacing    = input.int(6, "Spacing between candles", minval = 1, maxval = 20, group = g_SC, display = display.none)
colCandleI  = input.color(#000001, "Candle colour", inline = "cc2", group = g_SC, display = display.none)
bodyTransp  = input.int(85, "Body transparency", minval = 0, maxval = 100, inline = "cc2", group = g_SC, display = display.none)
showWick    = input.bool(true, "Wicks", inline = "w", group = g_SC, display = display.none)
showHLlbl   = input.bool(true, "High / low prices", inline = "w", group = g_SC, display = display.none)
show25tick  = input.bool(true, "25% tick (Asia, London, NY candles)", inline = "w", group = g_SC, display = display.none)
show25line  = input.bool(true, "Asia / London 25% lines on chart", inline = "25", group = g_SC, display = display.none)
col25       = input.color(color.blue, "", inline = "25", group = g_SC, display = display.none)
show50tick  = input.bool(true, "50% tick (Asia, London, NY candles)", inline = "50t", group = g_SC, display = display.none)
mode50      = input.string("Body (open–close)", "50% of", options = ["Body (open–close)", "Range (high–low)"], inline = "50t", group = g_SC, display = display.none)
show50line  = input.bool(true, "Asia / London 50% lines on chart", inline = "50", group = g_SC, display = display.none)
col50       = input.color(#ab47bc, "", inline = "50", group = g_SC, display = display.none)
showHMLO    = input.bool(false, "Asia / London H/M/L/O lines", inline = "hm", group = g_SC, display = display.none)
colHMLO     = input.color(color.new(color.gray, 30), "", inline = "hm", group = g_SC, display = display.none)
showVline   = input.bool(true, "Session open lines", inline = "vl", group = g_SC, display = display.none)
colVlineI   = input.color(#000001, "", inline = "vl", group = g_SC, display = display.none)

var g_T = "Stats table"
showTbl  = input.bool(true, "Show stats table", group = g_T, display = display.none)
lookback = input.int(252, "Lookback (days)", minval = 10, maxval = 2000, group = g_T, display = display.none)
tblPos   = input.string("Bottom Right", "Position", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Middle Right"], group = g_T, display = display.none)
tblSize  = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = g_T, display = display.none)
tblBgI   = input.color(#000001, "Background", inline = "tb", group = g_T, display = display.none)
tblTxtI  = input.color(#000001, "Text", inline = "tb", group = g_T, display = display.none)
tblBdrI  = input.color(#000001, "Border", inline = "tb", group = g_T, display = display.none)

// Theme: Auto follows the chart background; colours left at their default (#000001) follow it
bgLum  = 0.299 * color.r(chart.bg_color) + 0.587 * color.g(chart.bg_color) + 0.114 * color.b(chart.bg_color)
isDark = themeI == "Dark" or (themeI == "Auto" and bgLum < 128)
autoC(color c) => color.r(c) == 0 and color.g(c) == 0 and color.b(c) == 1
fgAuto = isDark ? #d1d4dc : #131722
txtCol = autoC(txtColI) ? fgAuto : txtColI
colCandle = autoC(colCandleI) ? fgAuto : colCandleI
colVline  = autoC(colVlineI) ? color.new(fgAuto, 70) : colVlineI
tblBg     = autoC(tblBgI) ? (isDark ? #161a23 : #f4f6f9) : tblBgI
tblTxt    = autoC(tblTxtI) ? fgAuto : tblTxtI
tblBdr    = autoC(tblBdrI) ? (isDark ? #2a2e39 : #d1d4dc) : tblBdrI


if not timeframe.isintraday or timeframe.in_seconds() > 15 * 60
    runtime.error("Use an intraday chart of 15 minutes or less (1 min recommended for the Bankai windows).")

tSize = lblSize == "Tiny" ? size.tiny : lblSize == "Normal" ? size.normal : size.small
stampOf(int t) => str.format_time(t, dateFmt, tz)
hhmm(int t) => str.format_time(t, "HH:mm", tz)

// ═══════════════════════════════════════════════════════════════════
// SESSION FLAGS
// ═══════════════════════════════════════════════════════════════════
sessOn(string s) => not na(time(timeframe.period, s, tz))
inON   = sessOn(onSess)
inShk  = sessOn(shkSess)
inNY   = sessOn(nySess)
inPrim = sessOn(primWin)
inSec  = sessOn(secWin)
inHA   = sessOn(hbAsia)
inHL   = sessOn(hbLdn)
inHP   = sessOn(hbPM)
inCA   = sessOn(cAsiaSess)
inCAL  = sessOn(cALSess)
inCL   = sessOn(cLonSess)
inCLN  = sessOn(cLNSess)
inCN   = sessOn(cNySess)

onStart = inON and not inON[1]
onEnd   = not inON and inON[1]
shkEnd   = not inShk and inShk[1]
nyEnd    = not inNY and inNY[1]
haStart = inHA and not inHA[1]
haEnd   = not inHA and inHA[1]
hlStart = inHL and not inHL[1]
hlEnd   = not inHL and inHL[1]
hpStart = inHP and not inHP[1]
hpEnd   = not inHP and inHP[1]
caStart = inCA and not inCA[1]
calStart = inCAL and not inCAL[1]
clStart = inCL and not inCL[1]
clnStart = inCLN and not inCLN[1]
cnStart = inCN and not inCN[1]
prevClose = close[1]

var int dayCount = 0
if onStart
    dayCount += 1

// ═══════════════════════════════════════════════════════════════════
// PRIOR-DAY STATE (full exchange day 18:00 → 16:59, no RTH)
// ═══════════════════════════════════════════════════════════════════
var float dO = na
var float dH = na
var float dL = na
var float dC = na
var array<float> dayR = array.new<float>()
var float  prevNet   = na
var float  prevRel   = na
var string prevState = "—"
if onStart and not na(dO)
    rng  = dH - dL
    nR   = dayR.size()
    avg  = nR >= avgLen ? dayR.slice(nR - avgLen, nR).avg() : na
    rel  = na(avg) ? na : rng / avg
    net  = dC - dO
    dirn = rng > 0 ? math.abs(net) / rng : 0.0
    st   = na(rel) ? "—" : rel > 1.25 and dirn > 0.55 ? "Expansion" : rel < 0.75 ? "Consolidation" : (not na(prevNet) and math.sign(net) != math.sign(prevNet) and rel >= 1.0) ? "Reversal" : "Retracement"
    prevState := st
    prevRel   := rel
    prevNet   := net
    dayR.push(rng)
if onStart
    dO := open
    dH := high
    dL := low
else if not na(dO)
    dH := math.max(dH, high)
    dL := math.min(dL, low)
dC := close

// ═══════════════════════════════════════════════════════════════════
// SESSION CANDLES — OHLC per session, tagged with the trading day
// ═══════════════════════════════════════════════════════════════════
type Sess
    float o
    float h
    float l
    float c
    int   t0
    int   day

var Sess sA = Sess.new()
var Sess sAL = Sess.new()
var Sess sL = Sess.new()
var Sess sLN = Sess.new()
var Sess sN = Sess.new()

// ── Day history for the stats table (pushed when a new day starts) ──
var array<float> hAH = array.new<float>()
var array<float> hAL = array.new<float>()
var array<float> hLH = array.new<float>()
var array<float> hLL = array.new<float>()
var array<float> hLO = array.new<float>()
var array<float> hLC = array.new<float>()
var array<float> hNH = array.new<float>()
var array<float> hNL = array.new<float>()
var array<float> hNO = array.new<float>()
var array<float> hNC = array.new<float>()

// Shikai / Bankai day record
var float sbO   = na
var float sbMid = na
var bool  sbUp  = false
var int   sbDay = na
var int   sbT930 = na
var int   midT  = -1
var bool  mid11 = false

var array<bool> hUp    = array.new<bool>()
var array<int>  hMidT  = array.new<int>()
var array<bool> hMid11 = array.new<bool>()

if onStart
    prevDay = dayCount - 1
    if not na(sA.o) and not na(sL.o) and not na(sN.o) and sA.day == prevDay and sL.day == prevDay and sN.day == prevDay
        hAH.push(sA.h)
        hAL.push(sA.l)
        hLH.push(sL.h)
        hLL.push(sL.l)
        hLO.push(sL.o)
        hLC.push(sL.c)
        hNH.push(sN.h)
        hNL.push(sN.l)
        hNO.push(sN.o)
        hNC.push(sN.c)
    if not na(sbO) and sbDay == prevDay
        hUp.push(sbUp)
        hMidT.push(midT)
        hMid11.push(mid11)

trackS(Sess s, bool inS, bool sStart) =>
    if sStart
        s.o   := open
        s.h   := high
        s.l   := low
        s.c   := close
        s.t0  := time
        s.day := dayCount
    else if inS and not na(s.o)
        s.h := math.max(s.h, high)
        s.l := math.min(s.l, low)
        s.c := close

trackS(sA, inCA, caStart)
trackS(sAL, inCAL, calStart)
trackS(sL, inCL, clStart)
trackS(sLN, inCLN, clnStart)
trackS(sN, inCN, cnStart)

lvl25(float o, float c) =>
    bt = math.max(o, c)
    bb = math.min(o, c)
    br = bt - bb
    br > 0 ? (c >= o ? bt - 0.25 * br : bb + 0.25 * br) : (bt + bb) / 2

lvl50(float o, float h, float l, float c) => mode50 == "Range (high–low)" ? (h + l) / 2 : (o + c) / 2

regimeOf(float ah, float al, float lh, float ll) =>
    lh > ah and ll < al ? "London engulfs Asia" : ah >= lh and al <= ll ? "Asia engulfs London" : lh > ah ? "London partial up" : ll < al ? "London partial down" : "Inside"

// ── Session open vertical lines ──
var array<line>  vLn = array.new<line>()
var array<label> vLb = array.new<label>()
vMark(bool cond, string nm) =>
    if cond and showVline
        vLn.push(line.new(bar_index, high, bar_index, low, color = colVline, extend = extend.both, xloc = xloc.bar_index))
        vLb.push(label.new(bar_index, high, nm, xloc = xloc.bar_index, style = label.style_label_down, color = colVline, textcolor = txtCol, size = size.tiny))
        if vLn.size() > 3 * maxDays
            vLn.shift().delete()
            vLb.shift().delete()
vMark(caStart, "Asia")
vMark(calStart and showTrans, "Asia→Ldn")
vMark(clStart, "London")
vMark(clnStart and showTrans, "Ldn→NY")
vMark(cnStart, "NY")

// ═══════════════════════════════════════════════════════════════════
// LEVEL STORE (Shikai / Bankai)
// ═══════════════════════════════════════════════════════════════════
type Lv
    line   ln
    label  lb
    float  y
    bool   above
    string kind      // "ON" (midpoint map), "Asia", "London", "NY PM" (hot blocks)
    int    day
    bool   hit
    bool   live
    string tag       // "mid", "lvl"

var array<Lv>    store = array.new<Lv>()
var array<label> evLbl = array.new<label>()
var array<int>   evDay = array.new<int>()

mkLv(int t0, float y, color col, int w, string st, string txt, string kind, bool above, string tag) =>
    lv = Lv.new(line.new(t0, y, time, y, xloc = xloc.bar_time, color = col, style = st, width = w), label.new(time, y, txt, xloc = xloc.bar_time, style = label.style_label_left, color = #ffffff00, textcolor = txtCol, size = tSize), y, above, kind, dayCount, false, true, tag)
    store.push(lv)
    lv

mkEvent(float y, string txt, color col, bool above) =>
    evLbl.push(label.new(time, y, txt, xloc = xloc.bar_time, style = above ? label.style_label_down : label.style_label_up, color = color.new(col, 80), textcolor = txtCol, size = tSize))
    evDay.push(dayCount)

if onStart
    while store.size() > 0 and store.get(0).day <= dayCount - maxDays
        lv = store.shift()
        lv.ln.delete()
        lv.lb.delete()
    while evDay.size() > 0 and evDay.get(0) <= dayCount - maxDays
        evLbl.shift().delete()
        evDay.shift()

// ═══════════════════════════════════════════════════════════════════
// OVERNIGHT RANGE → MIDPOINT MAP AT 09:30
// ═══════════════════════════════════════════════════════════════════
var float oO = na
var float oH = na
var float oL = na
var int   oHt = na
var int   oLt = na
if onStart
    oO := open
    oH := high
    oL := low
    oHt := time
    oLt := time
else if inON
    if high > oH
        oH := high
        oHt := time
    if low < oL
        oL := low
        oLt := time

var Lv    midLv     = na
var bool  bankaiOn  = false
var bool  midHit    = false
var bool  fromAbove = false
var bool  thru      = false
var bool  rcDone    = false

if onEnd and not na(oH)
    O      = open
    mid    = (oH + oL) / 2
    up     = mid > O
    // day record for the stats
    sbO := O
    sbMid := mid
    sbUp := up
    sbDay := dayCount
    sbT930 := time
    midT := -1
    mid11 := false
    // drawing state
    midHit    := false
    bankaiOn  := isBankai
    fromAbove := not up
    thru      := false
    rcDone    := false
    t0 = math.min(oHt, oLt)
    if showON
        mkLv(oHt, oH, colON, 1, line.style_solid, stampOf(oHt) + " ON high", "ON", true, "lvl")
        mkLv(oLt, oL, colON, 1, line.style_solid, stampOf(oLt) + " ON low", "ON", false, "lvl")
    midLv := mkLv(t0, mid, colMid, 2, line.style_solid, stampOf(time) + (isBankai ? " Bankai mid" : " Shikai mid"), "ON", up, "mid")
    if showInto
        mkEvent(up ? low : high, up ? "▲ Into mid: LONG" : "▼ Into mid: SHORT", up ? colLong : colShort, not up)

// ── Stats tracking for today (09:30 → 16:59) ──
if inShk and sbDay == dayCount and not na(sbMid)
    m    = int((time - sbT930) / 60000)
    tMid = sbUp ? high >= sbMid : low <= sbMid
    if midT < 0 and tMid
        midT  := m
        mid11 := inNY

// ═══════════════════════════════════════════════════════════════════
// HOT-BLOCK MIDPOINTS (Shikai)
// ═══════════════════════════════════════════════════════════════════
hotBlock(bool inS, bool sStart, int blk) =>
    var int   t0   = na
    var int   curK = 0
    var float cH   = na
    var float cL   = na
    var int   cT   = na
    var float best = na
    var float bMid = na
    var int   bT   = na
    bool isNew = false
    if sStart
        t0   := time
        curK := 0
        cH   := high
        cL   := low
        cT   := time
        best := na
        bMid := na
        bT   := na
    else if inS and not na(t0)
        k = int((time - t0) / (blk * 60000))
        if k != curK
            r = cH - cL
            if na(best) or r > best
                best  := r
                bMid  := (cH + cL) / 2
                bT    := cT
                isNew := true
            curK := k
            cH   := high
            cL   := low
            cT   := time
        else
            cH := math.max(cH, high)
            cL := math.min(cL, low)
    [bMid, bT, isNew]

updHot(Lv cur, float mid, int t0, string kind, string nm, color col, int rate, bool above) =>
    Lv r = cur
    txt = stampOf(t0) + " " + nm + " hot-block mid"
    bool reuse = not na(r) and r.day == dayCount
    if not reuse
        r := mkLv(t0, mid, col, 1, line.style_solid, txt, kind, above, "lvl")
    if reuse
        r.ln.set_xy1(t0, mid)
        r.ln.set_xy2(time, mid)
        r.ln.set_style(line.style_solid)
        r.lb.set_xy(time, mid)
        r.lb.set_text(txt)
        r.y     := mid
        r.above := above
        r.hit   := false
        r.live  := true
    r

[aMid, aT, aNew] = hotBlock(inHA, haStart, blockLen)
[lMid, lT, lNew] = hotBlock(inHL, hlStart, blockLen)
[pMid, pT, pNew] = hotBlock(inHP, hpStart, blockLen)

var Lv hbA = na
var Lv hbL = na
var Lv hbP = na
if not isBankai
    if aNew and showHA
        hbA := updHot(hbA, aMid, aT, "Asia", "Asia", colHA, 70, aMid > prevClose)
    if lNew and showHL
        hbL := updHot(hbL, lMid, lT, "London", "London", colHL, 63, lMid > prevClose)
    if pNew and showHP
        hbP := updHot(hbP, pMid, pT, "NY PM", "NY PM", colHP, 71, pMid > prevClose)

// ═══════════════════════════════════════════════════════════════════
// EVERY BAR: grow, touches, retire, age
// ═══════════════════════════════════════════════════════════════════
watching(string kind) => kind == "ON" ? (isBankai ? inNY : inShk) : kind == "Asia" ? inHA : kind == "London" ? inHL : inHP
windowEnd(string kind) => kind == "ON" ? (isBankai ? nyEnd : shkEnd) : kind == "Asia" ? haEnd : kind == "London" ? hlEnd : hpEnd

nS = store.size()
if nS > 0
    for i = 0 to nS - 1
        lv = store.get(i)
        if lv.live and lv.day != dayCount
            lv.live := false          // a past trading day: its lines stop where that day ended
        if lv.live
            lv.ln.set_x2(time)
            lv.lb.set_x(time)
        if not lv.hit and lv.day == dayCount and watching(lv.kind) and (lv.above ? high >= lv.y : low <= lv.y)
            lv.hit := true
            lv.ln.set_style(line.style_dashed)
            if lv.tag == "mid"
                midHit := true
                mins = int((time - sbT930) / 60000)
                txt  = isBankai ? "Bankai ✓ mid hit " + hhmm(time) + " · " + str.tostring(mins) + " min" : "Shikai mid hit " + hhmm(time) + " · " + str.tostring(mins) + " min"
                mkEvent(lv.y, txt, colMid, lv.above)
        if extMode != "To last candle" and lv.live and lv.day == dayCount and windowEnd(lv.kind)
            lv.live := false
        if dayCount - lv.day >= ageDays
            lv.ln.set_color(agedCol)
            lv.lb.set_textcolor(color.gray)
nE = evLbl.size()
if nE > 0
    for i = 0 to nE - 1
        if dayCount - evDay.get(i) >= ageDays
            evLbl.get(i).set_color(color.new(agedCol, 85))
            evLbl.get(i).set_textcolor(color.gray)

// ── Through the midpoint, then a close back = reclaim (reversal out of the level) ──
inWin = isBankai ? inNY : inShk
if showRecl and midHit and not rcDone and inWin and not na(sbMid) and sbDay == dayCount
    thru := thru or (fromAbove ? low < sbMid : high > sbMid)
    if thru and (fromAbove ? close > sbMid : close < sbMid)
        rcDone := true
        tR     = (fromAbove ? "↺ Mid reclaim: LONG " : "↺ Mid reclaim: SHORT ") + hhmm(time)
        mkEvent(fromAbove ? low : high, tR, color.gray, not fromAbove)

// ── Bankai: windows and hard stop ──
if nyEnd and bankaiOn
    if not midHit and not na(midLv)
        mkEvent(midLv.y, "Bankai over · mid not reached", color.gray, midLv.above)
    bankaiOn := false

bgcolor(bankaiOn and not midHit and inPrim ? colPrim : na, title = "Bankai primary window")
bgcolor(bankaiOn and not midHit and inSec ? colSec : na, title = "Bankai secondary window")

// ═══════════════════════════════════════════════════════════════════
// SESSION CANDLES + 25% / H-M-L-O LINES (redrawn on the last bar)
// ═══════════════════════════════════════════════════════════════════
var array<box>   cBx = array.new<box>()
var array<line>  cLn = array.new<line>()
var array<label> cLb = array.new<label>()

drawCandle(Sess s, int x1, int x2, string nm, bool lvls) =>
    bt   = math.max(s.o, s.c)
    bb   = math.min(s.o, s.c)
    xm   = int(math.round((x1 + x2) / 2))
    cBx.push(box.new(x1, bt, x2, bb, xloc = xloc.bar_index, bgcolor = color.new(colCandle, bodyTransp), border_color = colCandle, border_width = 1))
    if showWick and s.h > bt
        cLn.push(line.new(xm, bt, xm, s.h, xloc = xloc.bar_index, color = colCandle))
    if showWick and s.l < bb
        cLn.push(line.new(xm, bb, xm, s.l, xloc = xloc.bar_index, color = colCandle))
    // name and high price share one stacked label above the candle, so they can't overlap
    topTxt = showHLlbl ? nm + "\n" + str.tostring(s.h, format.mintick) : nm
    cLb.push(label.new(xm, s.h, topTxt, xloc = xloc.bar_index, style = label.style_label_down, color = color.new(colCandle, 90), textcolor = colCandle, size = size.tiny, textalign = text.align_center))
    if showHLlbl
        cLb.push(label.new(xm, s.l, str.tostring(s.l, format.mintick), xloc = xloc.bar_index, style = label.style_label_up, color = #ffffff00, textcolor = colCandle, size = size.tiny))
    if lvls and show25tick and bt > bb
        q = lvl25(s.o, s.c)
        cLn.push(line.new(x2, q, x2 + cSpacing, q, xloc = xloc.bar_index, color = col25))
        cLb.push(label.new(x2 + cSpacing, q, "25%", xloc = xloc.bar_index, style = label.style_label_left, color = #ffffff00, textcolor = col25, size = size.tiny))
    if lvls and show50tick
        h50 = lvl50(s.o, s.h, s.l, s.c)
        cLn.push(line.new(x2, h50, x2 + cSpacing, h50, xloc = xloc.bar_index, color = col50))
        cLb.push(label.new(x2 + cSpacing, h50, "50%", xloc = xloc.bar_index, style = label.style_label_left, color = #ffffff00, textcolor = col50, size = size.tiny))

drawSessLines(Sess s, string nm) =>
    if show25line and math.max(s.o, s.c) > math.min(s.o, s.c)
        q = lvl25(s.o, s.c)
        cLn.push(line.new(s.t0, q, time, q, xloc = xloc.bar_time, color = col25))
        cLb.push(label.new(time, q, stampOf(s.t0) + " " + nm + " 25%", xloc = xloc.bar_time, style = label.style_label_left, color = #ffffff00, textcolor = col25, size = tSize))
    if show50line
        h50 = lvl50(s.o, s.h, s.l, s.c)
        cLn.push(line.new(s.t0, h50, time, h50, xloc = xloc.bar_time, color = col50))
        cLb.push(label.new(time, h50, stampOf(s.t0) + " " + nm + " 50%", xloc = xloc.bar_time, style = label.style_label_left, color = #ffffff00, textcolor = col50, size = tSize))
    if showHMLO
        for j = 0 to 3
            y  = j == 0 ? s.h : j == 1 ? (s.h + s.l) / 2 : j == 2 ? s.l : s.o
            tx = j == 0 ? " High" : j == 1 ? " Mid" : j == 2 ? " Low" : " Open"
            cLn.push(line.new(s.t0, y, time, y, xloc = xloc.bar_time, color = colHMLO, style = line.style_dotted))
            cLb.push(label.new(time, y, nm + tx, xloc = xloc.bar_time, style = label.style_label_left, color = #ffffff00, textcolor = colHMLO, size = tSize))

if barstate.islast
    while cBx.size() > 0
        cBx.pop().delete()
    while cLn.size() > 0
        cLn.pop().delete()
    while cLb.size() > 0
        cLb.pop().delete()
    showA  = not na(sA.o) and sA.day == dayCount
    showAL = showTrans and not na(sAL.o) and sAL.day == dayCount
    showL  = not na(sL.o) and sL.day == dayCount
    showLN = showTrans and not na(sLN.o) and sLN.day == dayCount
    showN  = not na(sN.o) and sN.day == dayCount
    if showCandles
        step = cWidth + cSpacing
        x    = bar_index + cOffset
        if showA
            drawCandle(sA, x, x + cWidth, "Asia", true)
        x += step
        if showTrans
            if showAL
                drawCandle(sAL, x, x + cWidth, "Asia→Ldn", false)
            x += step
        if showL
            drawCandle(sL, x, x + cWidth, "London", true)
        x += step
        if showTrans
            if showLN
                drawCandle(sLN, x, x + cWidth, "Ldn→NY", false)
            x += step
        if showN
            drawCandle(sN, x, x + cWidth, "NY", true)
    if showA
        drawSessLines(sA, "Asia")
    if showL
        drawSessLines(sL, "London")

// ═══════════════════════════════════════════════════════════════════
// STATS TABLE
// ═══════════════════════════════════════════════════════════════════
pct(int a, int b) => b > 0 ? str.tostring(100.0 * a / b, "#.0") + "%" : "n/a"
tsz = tblSize == "Tiny" ? size.tiny : tblSize == "Normal" ? size.normal : size.small
tpos = tblPos == "Top Left" ? position.top_left : tblPos == "Top Right" ? position.top_right : tblPos == "Bottom Left" ? position.bottom_left : tblPos == "Middle Right" ? position.middle_right : position.bottom_right
var table tbl = na

put(table t, int r, string a, string b, color bg) =>
    table.cell(t, 0, r, a, text_color = tblTxt, text_size = tsz, bgcolor = bg, text_halign = text.align_left)
    table.cell(t, 1, r, b, text_color = tblTxt, text_size = tsz, bgcolor = bg, text_halign = text.align_left)

if showTbl and barstate.islast
    table.delete(tbl)
    tbl := table.new(tpos, 2, 40, bgcolor = tblBg, border_color = tblBdr, border_width = 1, frame_color = tblBdr, frame_width = 1)
    hdr = color.new(tblBdr, 85)
    row = 0

    // ── Shikai / Bankai history ──
    nAll  = hUp.size()
    st0   = math.max(0, nAll - lookback)
    nM    = nAll - st0
    nMid  = 0
    nAb   = 0
    hAb   = 0
    nBe   = 0
    hBe   = 0
    times = array.new<int>()
    if nAll > 0
        for i = st0 to nAll - 1
            gMid = isBankai ? hMid11.get(i) : hMidT.get(i) >= 0
            nMid += gMid ? 1 : 0
            if gMid
                times.push(hMidT.get(i))
            if hUp.get(i)
                nAb += 1
                hAb += gMid ? 1 : 0
            else
                nBe += 1
                hBe += gMid ? 1 : 0
    win = isBankai ? "by 11:00" : "by 16:59"
    put(tbl, row, isBankai ? "BANKAI · NY AM program" : "SHIKAI · all-day map", str.tostring(nM) + " days on chart", hdr)
    row += 1
    put(tbl, row, "Mid reached " + win, pct(nMid, nM), na)
    row += 1
    put(tbl, row, "Median time to mid", times.size() > 0 ? str.tostring(times.median(), "#") + " min" : "n/a", na)
    row += 1
    put(tbl, row, "Mid above the open (into = LONG)", pct(hAb, nAb) + " of " + str.tostring(nAb), na)
    row += 1
    put(tbl, row, "Mid below the open (into = SHORT)", pct(hBe, nBe) + " of " + str.tostring(nBe), na)
    row += 1

    // ── Session regime (London vs Asia) ──
    nH  = hAH.size()
    sH0 = math.max(0, nH - lookback)
    lonDone = not na(sL.o) and sL.day == dayCount and not inCL
    curReg  = not na(sA.o) and sA.day == dayCount and lonDone ? regimeOf(sA.h, sA.l, sL.h, sL.l) : "pending (London not closed)"
    nReg = 0
    nyB  = 0
    nyBall = 0
    lhT  = 0
    llT  = 0
    both = 0
    opAb = 0
    aSum = 0.0
    lSum = 0.0
    curLonBull = lonDone and sL.c > sL.o
    nDir = 0
    wkBack = 0
    wkFail = 0
    stay = 0
    if nH > 0
        for i = sH0 to nH - 1
            iah = hAH.get(i)
            ial = hAL.get(i)
            ilh = hLH.get(i)
            ill = hLL.get(i)
            ilo = hLO.get(i)
            ilc = hLC.get(i)
            inh = hNH.get(i)
            inl = hNL.get(i)
            ino = hNO.get(i)
            inc = hNC.get(i)
            aSum += iah - ial
            lSum += ilh - ill
            nyBall += inc > ino ? 1 : 0
            if lonDone and regimeOf(iah, ial, ilh, ill) == curReg
                nReg += 1
                nyB  += inc > ino ? 1 : 0
                lhT  += inh >= ilh ? 1 : 0
                llT  += inl <= ill ? 1 : 0
                both += inh >= ilh and inl <= ill ? 1 : 0
                opAb += ino > (ilh + ill) / 2 ? 1 : 0
            if lonDone and (ilc > ilo) == curLonBull and ilc != ilo
                q = lvl25(ilo, ilc)
                nDir += 1
                if curLonBull
                    stay   += inl >= q ? 1 : 0
                    wkBack += inl < q and inc > q ? 1 : 0
                    wkFail += inl < q and inc <= q ? 1 : 0
                else
                    stay   += inh <= q ? 1 : 0
                    wkBack += inh > q and inc < q ? 1 : 0
                    wkFail += inh > q and inc >= q ? 1 : 0
    nLook = nH - sH0
    put(tbl, row, "SESSION REGIME", str.tostring(nLook) + " days on chart", hdr)
    row += 1
    put(tbl, row, "Structure", curReg, na)
    row += 1
    put(tbl, row, "Occurrences", lonDone ? str.tostring(nReg) + " / " + str.tostring(nLook) : "n/a", na)
    row += 1
    put(tbl, row, "Asia range (avg | today)", (nLook > 0 ? str.tostring(aSum / nLook, "#.0") : "n/a") + " | " + (not na(sA.o) and sA.day == dayCount ? str.tostring(sA.h - sA.l, "#.0") : "n/a"), na)
    row += 1
    put(tbl, row, "London range (avg | today)", (nLook > 0 ? str.tostring(lSum / nLook, "#.0") : "n/a") + " | " + (not na(sL.o) and sL.day == dayCount ? str.tostring(sL.h - sL.l, "#.0") : "n/a"), na)
    row += 1
    put(tbl, row, "NY BEHAVIOUR (this regime)", "", hdr)
    row += 1
    put(tbl, row, "NY bullish", pct(nyB, nReg) + "  vs all days " + pct(nyBall, nLook) + " (baseline)", na)
    row += 1
    put(tbl, row, "London high taken", pct(lhT, nReg), na)
    row += 1
    put(tbl, row, "London low taken", pct(llT, nReg), na)
    row += 1
    put(tbl, row, "Both taken", pct(both, nReg), na)
    row += 1
    put(tbl, row, "NY open above London mid", pct(opAb, nReg), na)
    row += 1
    put(tbl, row, curLonBull ? "NY stays above London 25%" : "NY stays below London 25%", pct(stay, nDir), na)
    row += 1
    put(tbl, row, curLonBull ? "Wick below 25% → close back above" : "Wick above 25% → close back below", pct(wkBack, nDir), na)
    row += 1
    put(tbl, row, curLonBull ? "Wick below 25% → close below" : "Wick above 25% → close above", pct(wkFail, nDir), na)
    row += 1

    // ── Today ──
    todayOK = sbDay == dayCount and not na(sbMid)
    put(tbl, row, "TODAY", isBankai ? "Bankai mode" : "Shikai mode", hdr)
    row += 1
    put(tbl, row, "Prior-day state", prevState, na)
    row += 1
    put(tbl, row, "Open → midpoint", todayOK ? str.tostring(100 * math.abs(sbO - sbMid) / sbO, "#.##") + "% (" + str.tostring(math.abs(sbO - sbMid), format.mintick) + " pts)" : "waiting for 09:30", na)
    row += 1
    put(tbl, row, "Into-mid side", todayOK ? (sbUp ? "LONG" : "SHORT") : "—", na)
    row += 1
    midTxt = not todayOK ? "—" : midT >= 0 ? "hit " + hhmm(sbT930 + midT * 60000) + " · " + str.tostring(midT) + " min" + (isBankai and not mid11 ? " (after 11:00)" : "") : (isBankai and not inNY and not inPrim and time > sbT930 ? "not reached in window" : "pending")
    put(tbl, row, "Midpoint", midTxt, na)
    row += 1
    put(tbl, row, "London 25%", lonDone ? (curLonBull ? "bull London · 25% below the close" : "bear London · 25% above the close") : "pending", na)
    row += 1
    lhTaken = lonDone and not na(sN.o) and sN.day == dayCount and sN.h >= sL.h
    llTaken = lonDone and not na(sN.o) and sN.day == dayCount and sN.l <= sL.l
    put(tbl, row, "London high / low", lonDone ? (lhTaken ? "H taken ✓" : "H pending") + " · " + (llTaken ? "L taken ✓" : "L pending") : "pending", na)
````
