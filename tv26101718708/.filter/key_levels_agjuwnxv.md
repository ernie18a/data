# Key Levels

- url: https://www.tradingview.com/script/aGJuWnXV-Key-Levels/
- type: indicator
- pine_id: PUB;f7b386fc64854486b495314f83df338b
- version: 1.0

## Description

What it does
It plots your key liquidity reference levels on NQ/ES/YM, all on a New York clock (America/New_York, auto EST/EDT), built for intraday timeframes. Every level is a horizontal line extended right with a right-margin label, so labels stay readable on any timeframe and don't squeeze the price scale.
Levels plotted

Sessions — Asia (18:00–02:29), London (02:30–06:59), NY AM (07:00–11:29). Each plots that session's high and low. They belong to the current trading day; at the close they clear off the chart and move to history.
NY Midnight Open (NYMO) — the 00:00 ET open.
9:30 Open — the cash-open price, now pulled from 30-minute data so it reads correctly on every timeframe (1H and higher included).
Prior Day H/L (PDH/PDL) — the trading day runs 18:00 → 16:59 next day, finalized at the close so it's visible all weekend. Keeps the last 3 days. Swept levels relabel "old" and switch to dashed.
Prior Week H/L (PWH/PWL) — Sunday 18:00 → Friday 16:59. Keeps the last 3 weeks. Same sweep relabel/dash behavior.

Trading-day logic
Everything rolls on the trading day (18:00 boundary, +6h shift), not the calendar day, and the weekend gap is handled so Friday's levels finalize correctly.
Backtesting / history
A "Show current day" toggle plus individual "Show N days back" toggles (1–5) let you bring archived session/anchor days back onto the chart one at a time. With current-day off during market close, the recent day's PD/PW previews now clear too.
Settings
Per-level color inputs (each controls both line and label), show/hide per level, and a global line width. NYMO and 9:30 default to black — recolor those for a dark chart.

## Source Code

````pine
//@version=6
indicator("BB369 Liquidity Levels", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ============================================================
//  BB369 Liquidity Levels
//  - New York clock (America/New_York), auto EST/EDT. Intraday TFs.
//  - Each color input controls BOTH the line and its label.
//  - Labels anchor at the last bar (right margin), so they stay
//    visible on every timeframe and DON'T squeeze the price scale.
//  - Sessions Asia / London / NY AM belong to the current trading
//    day (18:00 -> 16:59). At the close they clear off the chart and
//    move to history; show them again via the days-back toggles.
//  - PDH/PDL = trading day 18:00 -> 16:59 next day, finalized at the
//    close (visible all weekend). Keeps last 3 days. PWH/PWL =
//    Sun 18:00 -> Fri 16:59, keeps last 3 weeks. Swept PD/PW levels
//    relabel "<base> old" and dash.
//  - NYMO and 9:30 Open default BLACK (current day) — recolor for
//    dark charts.
// ============================================================

tz = "America/New_York"

// ---------- General ----------
lineWidth = input.int(1, "Line width", minval = 1, maxval = 4, group = "General")

// ---------- Backtesting (session history) ----------
gBT = "Backtesting — Session History"
showCurDay = input.bool(true,  "Show current day (today)", group = gBT)
showD1     = input.bool(false, "Show 1 day back",          group = gBT)
showD2     = input.bool(false, "Show 2 days back",         group = gBT)
showD3     = input.bool(false, "Show 3 days back",         group = gBT)
showD4     = input.bool(false, "Show 4 days back",         group = gBT)
showD5     = input.bool(false, "Show 5 days back",         group = gBT)

// ---------- Sessions ----------
gA = "Asia  (18:00-02:29)"
showAsia = input.bool(true,  "Show",            group = gA)
cAsiaH   = input.color(color.orange, "High",    group = gA, inline = "a")
cAsiaL   = input.color(color.orange, "Low",     group = gA, inline = "a")

gL = "London  (02:30-06:59)"
showLon  = input.bool(true,  "Show",            group = gL)
cLonH    = input.color(color.orange, "High",    group = gL, inline = "l")
cLonL    = input.color(color.orange, "Low",     group = gL, inline = "l")

gN = "NY AM  (07:00-11:29)"
showNYAM = input.bool(true,  "Show",            group = gN)
cNYAMH   = input.color(color.orange, "High",    group = gN, inline = "n")
cNYAML   = input.color(color.orange, "Low",     group = gN, inline = "n")

// ---------- Anchors ----------
gM = "NY Midnight Open  (00:00)"
showNYMO = input.bool(true,  "Show",               group = gM)
cNYMO    = input.color(color.black, "Line/label",  group = gM)

g930 = "9:30 Open"
show930 = input.bool(true,  "Show",                group = g930)
c930    = input.color(color.black, "Line/label",   group = g930)

// ---------- Prior Day / Prior Week ----------
gPD = "Prior Day H/L  (18:00 -> 16:59 next day, keep 3)"
showPD = input.bool(true,  "Show",              group = gPD)
cPDH   = input.color(color.blue, "PDH",         group = gPD, inline = "pd")
cPDL   = input.color(color.red,  "PDL",         group = gPD, inline = "pd")

gPW = "Prior Week H/L  (Sun 18:00 -> Fri 16:59, keep 3)"
showPW = input.bool(true,  "Show",              group = gPW)
cPWH   = input.color(color.blue, "PWH",         group = gPW, inline = "pw")
cPWL   = input.color(color.red,  "PWL",         group = gPW, inline = "pw")

// ============================================================
//  Types
// ============================================================
type Pool
    line   hiLn = na
    line   loLn = na
    label  hiLb = na
    label  loLb = na
    float  hiP  = na
    float  loP  = na
    string dateStr = ""
    string finDate = ""
    int    startBar = na

type SessDay
    line   hiLn = na
    line   loLn = na
    label  hiLb = na
    label  loLb = na
    float  hiP  = na
    float  loP  = na
    string dateStr = ""

type Lvl
    line   ln     = na
    label  lb     = na
    float  price  = na
    bool   isHigh = false
    bool   swept  = false
    string base   = ""
    string dateStr = ""

type Anchor
    line   ln = na
    label  lb = na
    float  p  = na
    string dateStr = ""
    string finDate = ""
    int    startBar = na

type AnchorDay
    line   ln = na
    label  lb = na
    float  p  = na
    string dateStr = ""

// ============================================================
//  Functions
// ============================================================

// Right-margin label: anchored at last bar, text to the right,
// transparent box (text only) so it never extends the bar range.
f_mklabel(int x, float y, string txt, color c) =>
    label.new(x, y, txt, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(c, 100), textcolor = c, size = size.small)

// Horizontal level line from fromBar, extended right
f_mkline(int fromBar, float price, color c) =>
    line.new(fromBar, price, fromBar + 1, price, xloc = xloc.bar_index, extend = extend.right, color = c, width = lineWidth)

// Add a dated PD/PW level, pruning to maxKeep
f_add(array<Lvl> arr, float price, bool isHigh, string base, color col, int maxKeep, string dateStr, int fromBar) =>
    Lvl lv = Lvl.new()
    lv.price   := price
    lv.isHigh  := isHigh
    lv.base    := base
    lv.dateStr := dateStr
    lv.ln := f_mkline(fromBar, price, col)
    lv.lb := f_mklabel(bar_index, price, base + " " + dateStr, col)
    array.push(arr, lv)
    if array.size(arr) > maxKeep
        Lvl old = array.shift(arr)
        line.delete(old.ln)
        label.delete(old.lb)

// Archive a completed session day (keep up to 5)
f_archiveDay(array<SessDay> hist, int fromBar, float hiP, float loP, string dStr, string hiTxt, string loTxt, color hiCol, color loCol) =>
    SessDay d = SessDay.new()
    d.hiP := hiP
    d.loP := loP
    d.dateStr := dStr
    d.hiLn := f_mkline(fromBar, hiP, hiCol)
    d.loLn := f_mkline(fromBar, loP, loCol)
    d.hiLb := f_mklabel(bar_index, hiP, hiTxt + " " + dStr, hiCol)
    d.loLb := f_mklabel(bar_index, loP, loTxt + " " + dStr, loCol)
    array.push(hist, d)
    if array.size(hist) > 5
        SessDay old = array.shift(hist)
        line.delete(old.hiLn)
        line.delete(old.loLn)
        label.delete(old.hiLb)
        label.delete(old.loLb)

// Show/hide each archived day per its days-back toggle (last bar)
f_showHist(array<SessDay> hist, color hiCol, color loCol, bool d1, bool d2, bool d3, bool d4, bool d5) =>
    if barstate.islast and array.size(hist) > 0
        int n = array.size(hist)
        for i = 0 to n - 1
            SessDay d = array.get(hist, i)
            int db = n - i
            bool show = db == 1 ? d1 : db == 2 ? d2 : db == 3 ? d3 : db == 4 ? d4 : db == 5 ? d5 : false
            color hc = show ? hiCol : color.new(hiCol, 100)
            color lc = show ? loCol : color.new(loCol, 100)
            line.set_color(d.hiLn, hc)
            line.set_color(d.loLn, lc)
            label.set_textcolor(d.hiLb, hc)
            label.set_textcolor(d.loLb, lc)
            if show
                label.set_xy(d.hiLb, bar_index, d.hiP)
                label.set_xy(d.loLb, bar_index, d.loP)

// Session pool: lives during its trading day, then clears to history
f_sess(Pool cur, array<SessDay> hist, bool dayRoll, bool sStart, bool inSess, string hiTxt, string loTxt, color hiCol, color loCol, bool showCur, string curDate, bool closeNow, bool d1, bool d2, bool d3, bool d4, bool d5) =>
    // Day over (roll, or close/weekend on the last bar): archive + clear
    bool doArch = dayRoll or (barstate.islast and closeNow)
    if doArch
        if not na(cur.hiP) and cur.dateStr != cur.finDate
            int fb = na(cur.startBar) ? bar_index : cur.startBar
            f_archiveDay(hist, fb, cur.hiP, cur.loP, cur.dateStr, hiTxt, loTxt, hiCol, loCol)
            cur.finDate := cur.dateStr
        if not na(cur.hiLn)
            line.delete(cur.hiLn)
            line.delete(cur.loLn)
            cur.hiLn := na
            cur.loLn := na
        if not na(cur.hiLb)
            label.delete(cur.hiLb)
            label.delete(cur.loLb)
            cur.hiLb := na
            cur.loLb := na
        cur.hiP := na
        cur.loP := na
    // New session within the day
    if sStart
        // defensive: clear any live refs before reassigning (no orphans)
        if not na(cur.hiLn)
            line.delete(cur.hiLn)
            line.delete(cur.loLn)
            cur.hiLn := na
            cur.loLn := na
        if not na(cur.hiLb)
            label.delete(cur.hiLb)
            label.delete(cur.loLb)
            cur.hiLb := na
            cur.loLb := na
        cur.hiP := high
        cur.loP := low
        cur.dateStr := curDate
        cur.startBar := bar_index
        if showCur
            cur.hiLn := f_mkline(bar_index, high, hiCol)
            cur.loLn := f_mkline(bar_index, low,  loCol)
            cur.hiLb := f_mklabel(bar_index, high, hiTxt, hiCol)
            cur.loLb := f_mklabel(bar_index, low,  loTxt, loCol)
    else if inSess and not na(cur.hiP)
        if high > cur.hiP
            cur.hiP := high
            if not na(cur.hiLn)
                line.set_y1(cur.hiLn, high)
                line.set_y2(cur.hiLn, high)
        if low < cur.loP
            cur.loP := low
            if not na(cur.loLn)
                line.set_y1(cur.loLn, low)
                line.set_y2(cur.loLn, low)
    // live cleanup: toggling current-day off clears session lines immediately
    if not showCur and not na(cur.hiLn)
        line.delete(cur.hiLn)
        line.delete(cur.loLn)
        cur.hiLn := na
        cur.loLn := na
        label.delete(cur.hiLb)
        label.delete(cur.loLb)
        cur.hiLb := na
        cur.loLb := na
    if showCur and barstate.islast and not na(cur.hiLb)
        label.set_xy(cur.hiLb, bar_index, cur.hiP)
        label.set_xy(cur.loLb, bar_index, cur.loP)
    f_showHist(hist, hiCol, loCol, d1, d2, d3, d4, d5)

// Mark swept (current symbol) and relabel "<base> old <date>"
f_sweep(array<Lvl> arr) =>
    for lv in arr
        if not lv.swept
            if (lv.isHigh and high > lv.price) or (not lv.isHigh and low < lv.price)
                lv.swept := true
                label.set_text(lv.lb, lv.base + " old " + lv.dateStr)
                line.set_style(lv.ln, line.style_dashed)

// Keep PD/PW labels pinned to the right edge
f_repos(array<Lvl> arr) =>
    if barstate.islast
        for lv in arr
            label.set_xy(lv.lb, bar_index, lv.price)

// Archive a completed single-level anchor day (keep up to 5)
f_archiveAnchor(array<AnchorDay> hist, int fromBar, float p, string dStr, string txt, color col) =>
    AnchorDay d = AnchorDay.new()
    d.p := p
    d.dateStr := dStr
    d.ln := f_mkline(fromBar, p, col)
    d.lb := f_mklabel(bar_index, p, txt + " " + dStr, col)
    array.push(hist, d)
    if array.size(hist) > 5
        AnchorDay old = array.shift(hist)
        line.delete(old.ln)
        label.delete(old.lb)

// Show/hide archived anchor days per days-back toggle (last bar)
f_showAnchorHist(array<AnchorDay> hist, color col, bool d1, bool d2, bool d3, bool d4, bool d5) =>
    if barstate.islast and array.size(hist) > 0
        int n = array.size(hist)
        for i = 0 to n - 1
            AnchorDay d = array.get(hist, i)
            int db = n - i
            bool show = db == 1 ? d1 : db == 2 ? d2 : db == 3 ? d3 : db == 4 ? d4 : db == 5 ? d5 : false
            color cc = show ? col : color.new(col, 100)
            line.set_color(d.ln, cc)
            label.set_textcolor(d.lb, cc)
            if show
                label.set_xy(d.lb, bar_index, d.p)

// Single-level anchor (NYMO, 9:30): lives during its day, then to history
f_anchor(Anchor cur, array<AnchorDay> hist, bool dayRoll, bool trig, float aPrice, string txt, color col, bool showCur, string curDate, bool closeNow, bool d1, bool d2, bool d3, bool d4, bool d5) =>
    bool doArch = dayRoll or (barstate.islast and closeNow)
    if doArch
        if not na(cur.p) and cur.dateStr != cur.finDate
            int fb = na(cur.startBar) ? bar_index : cur.startBar
            f_archiveAnchor(hist, fb, cur.p, cur.dateStr, txt, col)
            cur.finDate := cur.dateStr
        if not na(cur.ln)
            line.delete(cur.ln)
            cur.ln := na
        if not na(cur.lb)
            label.delete(cur.lb)
            cur.lb := na
        cur.p := na
    if trig
        // defensive: never overwrite a live ref without deleting it first (no orphans)
        if not na(cur.ln)
            line.delete(cur.ln)
            cur.ln := na
        if not na(cur.lb)
            label.delete(cur.lb)
            cur.lb := na
        cur.p := aPrice
        cur.dateStr := curDate
        cur.startBar := bar_index
        if showCur and not na(aPrice)
            cur.ln := f_mkline(bar_index, aPrice, col)
            cur.lb := f_mklabel(bar_index, aPrice, txt, col)
    // live cleanup: toggling current-day off clears the line immediately
    if not showCur and not na(cur.ln)
        line.delete(cur.ln)
        cur.ln := na
        label.delete(cur.lb)
        cur.lb := na
    if showCur and barstate.islast and not na(cur.lb)
        label.set_xy(cur.lb, bar_index, cur.p)
    f_showAnchorHist(hist, col, d1, d2, d3, d4, d5)

// ============================================================
//  Time context (NY clock)
// ============================================================
sec = hour(time, tz) * 3600 + minute(time, tz) * 60
dow = dayofweek(time, tz)

// Real-time market state (drives weekend/post-close visibility)
nowSec = hour(timenow, tz) * 3600 + minute(timenow, tz) * 60
nowDow = dayofweek(timenow, tz)
dailyBreak    = nowSec >= 17*3600 and nowSec < 18*3600
weekendClosed = nowDow == dayofweek.saturday or (nowDow == dayofweek.sunday and nowSec < 18*3600) or (nowDow == dayofweek.friday and nowSec >= 17*3600)
marketClosed  = dailyBreak or weekendClosed
weekClosed    = weekendClosed

// Trading-day id rolls at 18:00 (+6h shift); date = the day it ENDS on
pdShiftMs  = 6 * 60 * 60 * 1000
pdId       = dayofmonth(time + pdShiftMs, tz)
pdDayDate  = str.tostring(month(time + pdShiftMs, tz)) + "/" + str.tostring(dayofmonth(time + pdShiftMs, tz))
shiftedDow = dayofweek(time + pdShiftMs, tz)
dayRoll    = na(pdId[1]) or pdId != pdId[1]

// ============================================================
//  Intraday session pools (current day + selectable history)
// ============================================================
inAsia = sec >= 18*3600 or sec < (2*3600 + 30*60)         // 18:00-02:29
inLon  = sec >= (2*3600 + 30*60) and sec < 7*3600          // 02:30-06:59
inNYAM = sec >= 7*3600 and sec < (11*3600 + 30*60)         // 07:00-11:29

sAsia = inAsia and not inAsia[1]
sLon  = inLon  and not inLon[1]
sNYAM = inNYAM and not inNYAM[1]

var Pool asia = Pool.new()
var Pool lon  = Pool.new()
var Pool nyam = Pool.new()
var array<SessDay> asiaHist = array.new<SessDay>()
var array<SessDay> lonHist  = array.new<SessDay>()
var array<SessDay> nyamHist = array.new<SessDay>()

if showAsia
    f_sess(asia, asiaHist, dayRoll, sAsia, inAsia, "Asia High",   "Asia Low",   cAsiaH, cAsiaL, showCurDay, pdDayDate, marketClosed, showD1, showD2, showD3, showD4, showD5)
if showLon
    f_sess(lon,  lonHist,  dayRoll, sLon,  inLon,  "London High", "London Low", cLonH,  cLonL,  showCurDay, pdDayDate, marketClosed, showD1, showD2, showD3, showD4, showD5)
if showNYAM
    f_sess(nyam, nyamHist, dayRoll, sNYAM, inNYAM, "NY AM High",  "NY AM Low",  cNYAMH, cNYAML, showCurDay, pdDayDate, marketClosed, showD1, showD2, showD3, showD4, showD5)

// ============================================================
//  NY Midnight Open (00:00) — current day + days-back history
// ============================================================
nyDay = dayofmonth(time, tz)
newDay = nyDay != nyDay[1]
var Anchor nymo = Anchor.new()
var array<AnchorDay> nymoHist = array.new<AnchorDay>()
if showNYMO
    f_anchor(nymo, nymoHist, dayRoll, newDay, open, "NYMO", cNYMO, showCurDay, pdDayDate, marketClosed, showD1, showD2, showD3, showD4, showD5)

// ============================================================
//  9:30 Open — current day + days-back history
// ============================================================
t930 = 9*3600 + 30*60
trig930 = sec >= t930 and (na(sec[1]) or sec[1] < t930)
// True 9:30 open from 30-min data so it's correct on 1H+ (where no bar opens at 9:30)
ltf930src = (hour(time, tz) * 3600 + minute(time, tz) * 60) == t930 ? open : na
o930raw   = request.security(syminfo.tickerid, "30", ltf930src, lookahead = barmerge.lookahead_off)
var float o930px = na
if not na(o930raw)
    o930px := o930raw
var Anchor o930 = Anchor.new()
var array<AnchorDay> o930Hist = array.new<AnchorDay>()
if show930
    f_anchor(o930, o930Hist, dayRoll, trig930, o930px, "9:30 Open", c930, showCurDay, pdDayDate, marketClosed, showD1, showD2, showD3, showD4, showD5)

// ============================================================
//  Prior Day H/L  (18:00 -> 16:59 next day; finalize at close)
// ============================================================
inPDWin = sec < 17*3600 or sec >= 18*3600
var float  pdHi = na
var float  pdLo = na
var string pdDate = ""
var int    pdStart = na
var string pdLastFin = ""
var array<Lvl> pdHa = array.new<Lvl>()
var array<Lvl> pdLa = array.new<Lvl>()
if dayRoll
    if not na(pdHi) and showPD and pdDate != pdLastFin
        f_add(pdHa, pdHi, true,  "PDH", cPDH, 3, pdDate, na(pdStart) ? bar_index : pdStart)
        f_add(pdLa, pdLo, false, "PDL", cPDL, 3, pdDate, na(pdStart) ? bar_index : pdStart)
        pdLastFin := pdDate
    pdHi := high
    pdLo := low
    pdDate := pdDayDate
    pdStart := bar_index
else if inPDWin
    pdHi := math.max(pdHi, high)
    pdLo := math.min(pdLo, low)
if barstate.islast and marketClosed and not na(pdHi) and showPD and showCurDay and pdDate != pdLastFin
    f_add(pdHa, pdHi, true,  "PDH", cPDH, 3, pdDate, na(pdStart) ? bar_index : pdStart)
    f_add(pdLa, pdLo, false, "PDL", cPDL, 3, pdDate, na(pdStart) ? bar_index : pdStart)
    pdLastFin := pdDate

// ============================================================
//  Prior Week H/L  (Sun 18:00 -> Fri 16:59; finalize at week close)
// ============================================================
weekRoll = shiftedDow == dayofweek.monday and (na(shiftedDow[1]) or shiftedDow[1] != dayofweek.monday)
var float  pwHi = na
var float  pwLo = na
var string pwDate = ""
var int    pwStart = na
var string pwLastFin = ""
var array<Lvl> pwHa = array.new<Lvl>()
var array<Lvl> pwLa = array.new<Lvl>()
if weekRoll
    if not na(pwHi) and showPW and pwDate != pwLastFin
        f_add(pwHa, pwHi, true,  "PWH", cPWH, 3, pwDate, na(pwStart) ? bar_index : pwStart)
        f_add(pwLa, pwLo, false, "PWL", cPWL, 3, pwDate, na(pwStart) ? bar_index : pwStart)
        pwLastFin := pwDate
    pwHi := high
    pwLo := low
    pwDate := pdDayDate
    pwStart := bar_index
else
    pwHi := math.max(pwHi, high)
    pwLo := math.min(pwLo, low)
if barstate.islast and weekClosed and not na(pwHi) and showPW and showCurDay and pwDate != pwLastFin
    f_add(pwHa, pwHi, true,  "PWH", cPWH, 3, pwDate, na(pwStart) ? bar_index : pwStart)
    f_add(pwLa, pwLo, false, "PWL", cPWL, 3, pwDate, na(pwStart) ? bar_index : pwStart)
    pwLastFin := pwDate

// ============================================================
//  Sweep detection + label repositioning (PD/PW)
// ============================================================
f_sweep(pdHa)
f_sweep(pdLa)
f_sweep(pwHa)
f_sweep(pwLa)

f_repos(pdHa)
f_repos(pdLa)
f_repos(pwHa)
f_repos(pwLa)
````
