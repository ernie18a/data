# Session Levels

- url: https://www.tradingview.com/script/UxA3Lw1I-Session-Levels/
- type: indicator
- pine_id: PUB;3c49f6894b6445c08f2eeb41dac8a98a
- version: 1.0

## Description

Plots the High/Low of the three major sessions, the previous FULL trading day's High/Low, the all-time high, and fires sweep alerts when price takes out any of these levels.

ROLLING WINDOW:
//    Each session shows only the CURRENT trading day's level plus the previous
//    trading day's level -- never older -- so old session lines stop piling up
//    and crossing each other.
//
//  WEEKLY RESET:
//    A trading day starts at 18:00 ET (CME open / Asia open). At the Sunday
//    18:00 ET weekly open every session line is wiped for a clean week.
//
//  HOLIDAY AWARENESS:
//    The previous-day references (PDH/PDL, the rolling session "previous day",
//    and the Monday RTH/Post-market refs) skip US market holidays AND early-close
//    half-days (Juneteenth, July 3, Black Friday, Christmas Eve...) and pull from
//    the most recent FULL session instead. Holidays are computed algorithmically
//    (incl. Good Friday via computus and the NYSE Sat->Fri / Sun->Mon observed
//    rules), so there is no yearly list to maintain. Example: the Mon after a
//    Juneteenth Friday references Thursday.
//    PDH/PDL use a CALENDAR-day (midnight) boundary by default so the prior
//    evening's overnight move is NOT lumped into the day -- switch to "RTH only"
//    in the inputs if you prefer the cash-session high/low. They draw as a single
//    line spanning only the live reference, not a step across all history.
//
//  MONDAY REFERENCES:
//    Monday's "previous day" is the weekend, so it shows the last full day's
//    RTH High/Low and Post-market High/Low for context. These clear Mon evening.
//
//  SWEEP ALERTS (new):
//    Alert conditions fire when price sweeps a session High/Low (after that
//    session closes), the PDH/PDL, or makes a new all-time high.

## Source Code

````pine
//@version=6
// =============================================================================
//  Session Levels  --  Asia / London / New York + Prev-Day H/L + All-Time High
// -----------------------------------------------------------------------------
//  Plots the High/Low of the three major sessions, the previous FULL trading
//  day's High/Low, the all-time high, and fires sweep alerts when price takes
//  out any of these levels.
//
//  ROLLING WINDOW:
//    Each session shows only the CURRENT trading day's level plus the previous
//    trading day's level -- never older -- so old session lines stop piling up
//    and crossing each other.
//
//  WEEKLY RESET:
//    A trading day starts at 18:00 ET (CME open / Asia open). At the Sunday
//    18:00 ET weekly open every session line is wiped for a clean week.
//
//  HOLIDAY AWARENESS:
//    The previous-day references (PDH/PDL, the rolling session "previous day",
//    and the Monday RTH/Post-market refs) skip US market holidays AND early-close
//    half-days (Juneteenth, July 3, Black Friday, Christmas Eve...) and pull from
//    the most recent FULL session instead. Holidays are computed algorithmically
//    (incl. Good Friday via computus and the NYSE Sat->Fri / Sun->Mon observed
//    rules), so there is no yearly list to maintain. Example: the Mon after a
//    Juneteenth Friday references Thursday.
//    PDH/PDL use a CALENDAR-day (midnight) boundary by default so the prior
//    evening's overnight move is NOT lumped into the day -- switch to "RTH only"
//    in the inputs if you prefer the cash-session high/low. They draw as a single
//    line spanning only the live reference, not a step across all history.
//
//  MONDAY REFERENCES:
//    Monday's "previous day" is the weekend, so it shows the last full day's
//    RTH High/Low and Post-market High/Low for context. These clear Mon evening.
//
//  SWEEP ALERTS (new):
//    Alert conditions fire when price sweeps a session High/Low (after that
//    session closes), the PDH/PDL, or makes a new all-time high.
// =============================================================================

indicator("Session Levels — Asia/London/NY + PDH/PDL + ATH", shorttitle="Session Levels", overlay=true, max_lines_count=500, max_labels_count=500)

// ----------------------------------------------------------------------------- inputs: sessions
grpS = "Sessions (times in the timezone below)"
tz        = input.string("America/New_York", "Display timezone", options=["America/New_York", "Europe/London", "Asia/Tokyo", "UTC"], group=grpS, tooltip="All session times below are interpreted in this timezone. Trading-day & weekly resets and holidays are anchored to this zone.")
asiaSess  = input.session("1800-0000", "Asia session",     group=grpS)
lonSess   = input.session("0300-1130", "London session",   group=grpS)
nySess    = input.session("0800-1700", "New York session", group=grpS)

grpM = "Previous-day / Monday references"
rthSess   = input.session("0930-1600", "RTH window",          group=grpM, tooltip="Cash-session high/low of the last full trading day (shown on Monday).")
pmSess    = input.session("1600-1700", "Post-market window",  group=grpM, tooltip="After-RTH high/low of the last full trading day (ES halts 17:00 ET; shown on Monday).")
skipHol   = input.bool(true, "Skip holidays & half-days for references", group=grpM, tooltip="When on, PDH/PDL, the rolling session 'previous day', and the Monday refs ignore US market holidays and early-close days and use the last FULL session instead.")
pdMode    = input.string("Calendar day (00:00–00:00)", "PDH/PDL source", options=["Calendar day (00:00–00:00)", "RTH session only"], group=grpM, tooltip="Calendar day = the prior full day's midnight-to-midnight high/low (excludes the previous evening's overnight move). RTH = the prior full day's 9:30–16:00 ET high/low.")

// ----------------------------------------------------------------------------- inputs: toggles & style
grpD = "Display"
showAsia  = input.bool(true,  "Asia H/L",        inline="a", group=grpD)
colAsia   = input.color(color.new(color.yellow, 0), "", inline="a", group=grpD)
showLon   = input.bool(true,  "London H/L",      inline="l", group=grpD)
colLon    = input.color(color.new(color.aqua,   0), "", inline="l", group=grpD)
showNy    = input.bool(true,  "New York H/L",    inline="n", group=grpD)
colNy     = input.color(color.new(color.fuchsia,0), "", inline="n", group=grpD)
showPdh   = input.bool(true,  "Prev Full Day H/L",inline="p", group=grpD)
colPdh    = input.color(color.new(color.white,  0), "", inline="p", group=grpD)
showAth   = input.bool(true,  "All-Time High",   inline="t", group=grpD)
colAth    = input.color(color.new(color.lime,   0), "", inline="t", group=grpD)
showRth   = input.bool(true,  "Prev RTH H/L (Mon)",inline="r", group=grpD)
colRth    = input.color(color.new(color.orange, 0), "", inline="r", group=grpD)
showPm    = input.bool(true,  "Prev Post-mkt H/L (Mon)",inline="x", group=grpD)
colPm     = input.color(color.new(color.gray,   0), "", inline="x", group=grpD)

lineWidth = input.int(1, "Line width", minval=1, maxval=4, group=grpD)
showLabels= input.bool(true, "Show labels", group=grpD)

grpA = "Sweep alerts"
showSweeps = input.bool(true, "Mark PDH/PDL sweeps on chart", group=grpA)

// ----------------------------------------------------------------------------- US market holiday calendar (algorithmic)
// nth `targetDow` of a month -> day-of-month (dow: 1=Sun ... 7=Sat)
f_nthDow(int y, int mo, int n, int targetDow) =>
    t0     = timestamp(tz, y, mo, 1, 12, 0)
    fdow   = dayofweek(t0, tz)
    offset = (targetDow - fdow + 7) % 7
    1 + offset + (n - 1) * 7

// last `targetDow` of a month -> day-of-month
f_lastDow(int y, int mo, int targetDow) =>
    nmY   = mo == 12 ? y + 1 : y
    nmM   = mo == 12 ? 1 : mo + 1
    tlast = timestamp(tz, nmY, nmM, 1, 12, 0) - 24 * 60 * 60 * 1000
    back  = (dayofweek(tlast, tz) - targetDow + 7) % 7
    dayofmonth(tlast, tz) - back

// Gregorian Easter (computus) -> [month, day]
f_easter(int y) =>
    a  = y % 19
    b  = math.floor(y / 100)
    c  = y % 100
    d  = math.floor(b / 4)
    e  = b % 4
    f  = math.floor((b + 8) / 25)
    g  = math.floor((b - f + 1) / 3)
    h  = (19 * a + b - d - g + 15) % 30
    ii = math.floor(c / 4)
    k  = c % 4
    l  = (32 + 2 * e + 2 * ii - h - k) % 7
    m  = math.floor((a + 11 * h + 22 * l) / 451)
    mo = math.floor((h + l - 7 * m + 114) / 31)
    dy = ((h + l - 7 * m + 114) % 31) + 1
    [mo, dy]

// true if (y,mo,d,dow) is a weekend, full holiday, or early-close half-day
f_isNonFull(int y, int mo, int d, int dow) =>
    nf = false
    if dow == dayofweek.saturday or dow == dayofweek.sunday
        nf := true
    // New Year (Jan 1; Sun -> observed Mon 2; Sat -> not observed)
    if mo == 1 and (d == 1 or (d == 2 and dow == dayofweek.monday))
        nf := true
    // MLK (3rd Mon Jan) / Presidents (3rd Mon Feb) / Memorial (last Mon May) / Labor (1st Mon Sep)
    if mo == 1 and d == f_nthDow(y, 1, 3, dayofweek.monday)
        nf := true
    if mo == 2 and d == f_nthDow(y, 2, 3, dayofweek.monday)
        nf := true
    if mo == 5 and d == f_lastDow(y, 5, dayofweek.monday)
        nf := true
    if mo == 9 and d == f_nthDow(y, 9, 1, dayofweek.monday)
        nf := true
    // Good Friday (Easter Sunday - 2 days)
    [em, ed] = f_easter(y)
    gfTs = timestamp(tz, y, em, ed, 12, 0) - 2 * 24 * 60 * 60 * 1000
    if mo == month(gfTs, tz) and d == dayofmonth(gfTs, tz)
        nf := true
    // Juneteenth (Jun 19, observed) + Independence (Jul 4, observed) + Jul 3 half-day
    if mo == 6 and (d == 19 or (d == 18 and dow == dayofweek.friday) or (d == 20 and dow == dayofweek.monday))
        nf := true
    if mo == 7 and (d == 4 or (d == 3 and dow == dayofweek.friday) or (d == 5 and dow == dayofweek.monday))
        nf := true
    if mo == 7 and d == 3 and dow >= dayofweek.monday and dow <= dayofweek.thursday
        nf := true
    // Thanksgiving (4th Thu Nov) + Black Friday half-day
    tg = f_nthDow(y, 11, 4, dayofweek.thursday)
    if mo == 11 and (d == tg or d == tg + 1)
        nf := true
    // Christmas (Dec 25, observed) + Christmas Eve half-day
    if mo == 12 and (d == 25 or (d == 24 and dow == dayofweek.friday) or (d == 26 and dow == dayofweek.monday))
        nf := true
    if mo == 12 and d == 24 and dow >= dayofweek.monday and dow <= dayofweek.thursday
        nf := true
    nf

// ----------------------------------------------------------------------------- session state type
type Sess
    bool   active = false
    float  hi     = na
    float  lo     = na
    int    startT = na
    line   hiL    = na
    line   loL    = na
    label  hiLb   = na
    label  loLb   = na
    line   pHiL   = na
    line   pLoL   = na
    label  pHiLb  = na
    label  pLoLb  = na

clearSess(Sess s) =>
    line.delete(s.hiL)
    line.delete(s.loL)
    label.delete(s.hiLb)
    label.delete(s.loLb)
    line.delete(s.pHiL)
    line.delete(s.pLoL)
    label.delete(s.pHiLb)
    label.delete(s.pLoLb)
    s.hiL  := na
    s.loL  := na
    s.hiLb := na
    s.loLb := na
    s.pHiL  := na
    s.pLoL  := na
    s.pHiLb := na
    s.pLoLb := na
    s.active := false
    s.hi := na
    s.lo := na

// dayFull = was the trading day of the just-finished instance a FULL session?
// When false (holiday / half-day) we discard that instance instead of promoting
// it, so the displayed "previous day" always references the last full session.
trackSession(Sess s, bool inSess, string name, color col, bool dayFull) =>
    if inSess and not s.active
        if dayFull or not skipHol
            // promote the just-finished current instance to "previous"
            line.delete(s.pHiL)
            line.delete(s.pLoL)
            label.delete(s.pHiLb)
            label.delete(s.pLoLb)
            s.pHiL  := s.hiL
            s.pLoL  := s.loL
            s.pHiLb := s.hiLb
            s.pLoLb := s.loLb
        else
            // holiday/half-day: drop it, keep the existing previous reference
            line.delete(s.hiL)
            line.delete(s.loL)
            label.delete(s.hiLb)
            label.delete(s.loLb)
        s.active := true
        s.hi := high
        s.lo := low
        s.startT := time
        s.hiL := line.new(time, high, time, high, xloc=xloc.bar_time, color=col, width=lineWidth)
        s.loL := line.new(time, low,  time, low,  xloc=xloc.bar_time, color=col, width=lineWidth)
        s.hiLb := showLabels ? label.new(time, high, name + " H", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(col, 85), textcolor=col, size=size.small) : na
        s.loLb := showLabels ? label.new(time, low,  name + " L", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(col, 85), textcolor=col, size=size.small) : na
    else if inSess and s.active
        s.hi := math.max(s.hi, high)
        s.lo := math.min(s.lo, low)
        line.set_xy1(s.hiL, s.startT, s.hi)
        line.set_xy2(s.hiL, time, s.hi)
        line.set_xy1(s.loL, s.startT, s.lo)
        line.set_xy2(s.loL, time, s.lo)
        if showLabels and not na(s.hiLb)
            label.set_xy(s.hiLb, time, s.hi)
            label.set_xy(s.loLb, time, s.lo)
    else if not inSess and s.active
        s.active := false
    if not na(s.hiL)
        line.set_x2(s.hiL, time)
        line.set_x2(s.loL, time)
        if showLabels and not na(s.hiLb)
            label.set_x(s.hiLb, time)
            label.set_x(s.loLb, time)
    if not na(s.pHiL)
        line.set_x2(s.pHiL, time)
        line.set_x2(s.pLoL, time)
        if showLabels and not na(s.pHiLb)
            label.set_x(s.pHiLb, time)
            label.set_x(s.pLoLb, time)

// ----------------------------------------------------------------------------- trading-day / weekly clock (18:00 ET anchored)
dowNow = dayofweek(time, tz)
hr     = hour(time, tz)
tDow   = hr >= 18 ? (dowNow == dayofweek.saturday ? dayofweek.sunday : dowNow + 1) : dowNow
newTD    = not na(tDow[1]) and tDow != tDow[1]
isMon    = tDow == dayofweek.monday
weekOpen = newTD and isMon

inRthNow = not na(time(timeframe.period, rthSess, tz))
inPmNow  = not na(time(timeframe.period, pmSess,  tz))

// --- trading-day (18:00 anchored) fullness, used to skip holiday sessions ----
// tdFull is set during RTH from the RTH date; lastTdFull holds the fullness of
// the trading day that just ended (the one a session is promoting out of).
var bool tdFull     = false
var bool lastTdFull = false
if newTD
    lastTdFull := tdFull
    tdFull := false
if inRthNow
    tdFull := not f_isNonFull(year(time, tz), month(time, tz), dayofmonth(time, tz), dayofweek(time, tz))

// --- calendar-day (midnight anchored) capture, used for PDH/PDL & Mon refs ---
// Midnight boundary keeps the prior evening's overnight move out of "today",
// so the previous-day high/low matches the day you actually see on the chart.
calDay    = year(time, tz) * 10000 + month(time, tz) * 100 + dayofmonth(time, tz)
newCalDay = not na(calDay[1]) and calDay != calDay[1]

var float cdHi = na
var float cdLo = na
var float cdRthHi = na
var float cdRthLo = na
var float cdPmHi = na
var float cdPmLo = na

var float lfHi = na       // last full calendar day: full-day range
var float lfLo = na
var float lfRthHi = na     // last full calendar day: RTH range
var float lfRthLo = na
var float lfPmHi = na      // last full calendar day: post-market range
var float lfPmLo = na

if newCalDay
    prevFull = not f_isNonFull(year(time[1], tz), month(time[1], tz), dayofmonth(time[1], tz), dayofweek(time[1], tz))
    if (prevFull or not skipHol) and not na(cdHi)
        lfHi := cdHi
        lfLo := cdLo
        lfRthHi := cdRthHi
        lfRthLo := cdRthLo
        lfPmHi := cdPmHi
        lfPmLo := cdPmLo
    cdHi := na
    cdLo := na
    cdRthHi := na
    cdRthLo := na
    cdPmHi := na
    cdPmLo := na

cdHi := na(cdHi) ? high : math.max(cdHi, high)
cdLo := na(cdLo) ? low  : math.min(cdLo, low)
if inRthNow
    cdRthHi := na(cdRthHi) ? high : math.max(cdRthHi, high)
    cdRthLo := na(cdRthLo) ? low  : math.min(cdRthLo, low)
if inPmNow
    cdPmHi := na(cdPmHi) ? high : math.max(cdPmHi, high)
    cdPmLo := na(cdPmLo) ? low  : math.min(cdPmLo, low)

// ----------------------------------------------------------------------------- session detection + tracking
inAsia = showAsia and not na(time(timeframe.period, asiaSess, tz))
inLon  = showLon  and not na(time(timeframe.period, lonSess,  tz))
inNy   = showNy   and not na(time(timeframe.period, nySess,   tz))

var Sess asia = Sess.new()
var Sess lon  = Sess.new()
var Sess ny   = Sess.new()

if weekOpen
    clearSess(asia)
    clearSess(lon)
    clearSess(ny)

if showAsia
    trackSession(asia, inAsia, "Asia", colAsia, lastTdFull)
if showLon
    trackSession(lon, inLon, "London", colLon, lastTdFull)
if showNy
    trackSession(ny, inNy, "NY", colNy, lastTdFull)

// ----------------------------------------------------------------------------- Monday reference lines (last full day's RTH + post-market)
var line  rthHL  = na
var line  rthLL  = na
var line  pmHL   = na
var label rthHLb = na
var label rthLLb = na
var label pmHLb  = na

if weekOpen
    line.delete(rthHL)
    line.delete(rthLL)
    line.delete(pmHL)
    label.delete(rthHLb)
    label.delete(rthLLb)
    label.delete(pmHLb)
    rthHL := na
    rthLL := na
    pmHL  := na
    rthHLb := na
    rthLLb := na
    pmHLb  := na
    if showRth and not na(lfRthHi)
        rthHL := line.new(time, lfRthHi, time, lfRthHi, xloc=xloc.bar_time, color=colRth, width=lineWidth, style=line.style_dotted)
        rthLL := line.new(time, lfRthLo, time, lfRthLo, xloc=xloc.bar_time, color=colRth, width=lineWidth, style=line.style_dotted)
        if showLabels
            rthHLb := label.new(time, lfRthHi, "Prev RTH H", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(colRth, 85), textcolor=colRth, size=size.small)
            rthLLb := label.new(time, lfRthLo, "Prev RTH L", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(colRth, 85), textcolor=colRth, size=size.small)
    if showPm and not na(lfPmHi)
        pmHL := line.new(time, lfPmHi, time, lfPmHi, xloc=xloc.bar_time, color=colPm, width=lineWidth, style=line.style_dotted)
        if showLabels
            pmHLb := label.new(time, lfPmHi, "Prev PM H", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(colPm, 85), textcolor=colPm, size=size.small)

if isMon
    if not na(rthHL)
        line.set_x2(rthHL, time)
        line.set_x2(rthLL, time)
        if showLabels and not na(rthHLb)
            label.set_x(rthHLb, time)
            label.set_x(rthLLb, time)
    if not na(pmHL)
        line.set_x2(pmHL, time)
        if showLabels and not na(pmHLb)
            label.set_x(pmHLb, time)

if newTD and not isMon
    line.delete(rthHL)
    line.delete(rthLL)
    line.delete(pmHL)
    label.delete(rthHLb)
    label.delete(rthLLb)
    label.delete(pmHLb)
    rthHL := na
    rthLL := na
    pmHL  := na
    rthHLb := na
    rthLLb := na
    pmHLb  := na

// ----------------------------------------------------------------------------- previous full day High / Low
// Drawn as a single line that only spans from when the level became current to
// now -- not redrawn across all history -- mirroring the session lines.
pdSrcHi = pdMode == "RTH session only" ? lfRthHi : lfHi
pdSrcLo = pdMode == "RTH session only" ? lfRthLo : lfLo

var line  pdhLine = na
var line  pdlLine = na
var label pdhLbl  = na
var label pdlLbl  = na

remakePd = showPdh and not na(pdSrcHi) and (na(pdhLine) or pdSrcHi != pdSrcHi[1] or pdSrcLo != pdSrcLo[1])
if remakePd
    line.delete(pdhLine)
    line.delete(pdlLine)
    label.delete(pdhLbl)
    label.delete(pdlLbl)
    pdhLine := line.new(time, pdSrcHi, time, pdSrcHi, xloc=xloc.bar_time, color=colPdh, width=lineWidth, style=line.style_dashed)
    pdlLine := line.new(time, pdSrcLo, time, pdSrcLo, xloc=xloc.bar_time, color=colPdh, width=lineWidth, style=line.style_dashed)
    if showLabels
        pdhLbl := label.new(time, pdSrcHi, "PDH", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(colPdh, 85), textcolor=colPdh, size=size.small)
        pdlLbl := label.new(time, pdSrcLo, "PDL", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(colPdh, 85), textcolor=colPdh, size=size.small)

if not na(pdhLine)
    line.set_x2(pdhLine, time)
    line.set_x2(pdlLine, time)
    if showLabels and not na(pdhLbl)
        label.set_x(pdhLbl, time)
        label.set_x(pdlLbl, time)

// ----------------------------------------------------------------------------- all-time high + its bar
var float athVal  = na
var int   athTime = na
if na(athVal) or high > athVal
    athVal  := high
    athTime := time

var line  athLine = na
var label athLbl  = na
if showAth and barstate.islast
    line.delete(athLine)
    label.delete(athLbl)
    athLine := line.new(athTime, athVal, time, athVal, xloc=xloc.bar_time, color=colAth, width=lineWidth, style=line.style_dashed)
    if showLabels
        athLbl := label.new(athTime, athVal, "ATH " + str.tostring(athVal, format.mintick), xloc=xloc.bar_time, style=label.style_label_down, color=color.new(colAth, 80), textcolor=colAth, size=size.small)

// ----------------------------------------------------------------------------- sweep alerts (RTH only)
// Session H/L levels freeze when their window closes, so these fire on a true
// sweep of a *completed* session (no false fires while the session is forming).
// Sweeps are only considered during Regular Trading Hours (the RTH window).
aHi = asia.hi
aLo = asia.lo
lHi = lon.hi
lLo = lon.lo
nHi = ny.hi
nLo = ny.lo

swAsiaH = inRthNow and ta.crossover(high, aHi)
swAsiaL = inRthNow and ta.crossunder(low, aLo)
swLonH  = inRthNow and ta.crossover(high, lHi)
swLonL  = inRthNow and ta.crossunder(low, lLo)
swNyH   = inRthNow and ta.crossover(high, nHi)
swNyL   = inRthNow and ta.crossunder(low, nLo)
swPdh   = inRthNow and ta.crossover(high, pdSrcHi)
swPdl   = inRthNow and ta.crossunder(low, pdSrcLo)
swAth   = inRthNow and ta.crossover(high, athVal)

alertcondition(swAsiaH, "Sweep: Asia High",   "{{ticker}} swept the Asia session High (RTH)")
alertcondition(swAsiaL, "Sweep: Asia Low",    "{{ticker}} swept the Asia session Low (RTH)")
alertcondition(swLonH,  "Sweep: London High", "{{ticker}} swept the London session High (RTH)")
alertcondition(swLonL,  "Sweep: London Low",  "{{ticker}} swept the London session Low (RTH)")
alertcondition(swNyH,   "Sweep: NY High",     "{{ticker}} swept the New York session High (RTH)")
alertcondition(swNyL,   "Sweep: NY Low",      "{{ticker}} swept the New York session Low (RTH)")
alertcondition(swPdh,   "Sweep: PDH",         "{{ticker}} swept the Previous-Day High (RTH)")
alertcondition(swPdl,   "Sweep: PDL",         "{{ticker}} swept the Previous-Day Low (RTH)")
alertcondition(swAth,   "New All-Time High",  "{{ticker}} printed a new All-Time High (RTH)")

plotshape(showSweeps and swPdh,  "PDH sweep", shape.triangleup,   location.abovebar, color=color.new(color.red, 0),   size=size.tiny)
plotshape(showSweeps and swPdl,  "PDL sweep", shape.triangledown, location.belowbar, color=color.new(color.green, 0), size=size.tiny)
````
