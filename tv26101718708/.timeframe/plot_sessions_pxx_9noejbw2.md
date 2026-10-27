# Plot Sessions / PXX

- url: https://www.tradingview.com/script/9noEJbw2-Plot-Sessions-PXX/
- type: indicator
- pine_id: PUB;24825a27b9934794bef49d74a2fadc37
- version: 5.0

## Description

**Plot PXX** — Previous H/L/M levels for sessions and higher timeframes, plus optional intraday time markers.

**What it plots**

- **Previous 1 session** (any of AKZ / LKZ / AM / LUN / PM): the most recently-closed session range. Plus the **current forming session** tracked live.
- **Previous N days** (PD1..PDn, configurable 1–5): H/L from the last N closed daily sessions. The newest (PD1) additionally shows its **midpoint (PDM)** as a dashed line.
- **Previous N weeks** (PW1..PWn, configurable 1–5): H/L from the last N closed weekly sessions.
- **Previous N months** (PM1..PMn, configurable 1–5): H/L from the last N closed monthly sessions.
- **Optional vertical time lines** (current day only): vertical markers at a configurable list of NY times (default `00:00, 02:00, 05:00, 07:00, 08:30, 09:30, 11:00, 12:00, 13:30`). Lines draw only on bars whose open time actually matches a target — so 08:30 shows on 15m but not on 1h, and CME-session-aligned H4 correctly skips non-aligning times. Each line gets a vertical text label (`0 / 8 / : / 3 / 0` stacked) below the bar.

**Behavior**

- Level lines extend to the current bar until breached, then gray out and stop extending. Breach is direction-aware: highs fade when price goes **above**, lows fade when price goes **below** (handles weekend gap-throughs).
- Labels carry the period identifier in their tooltips — `PDH  Mon Apr 13`, `PWL  Apr 13`, `PMH  Mar 2026`. Sessions have no date (always same-day).
- Rolling-window eviction destroys the oldest level cleanly on each rollover; PD1's midpoint drops automatically when it demotes to PD2.
- Current forming day / week / month are **not drawn** — only previous, closed periods appear. Only the current session tracks live.
- Vertical time lines reset on each new NY day, so only today's markers are ever on screen.

**Inputs**

- Sessions: 5 configurable windows + colors (AKZ / LKZ / AM / LUN / PM).
- HTF: per-period enable toggle, color, and previous-count dropdown (1–5).
- Vertical Lines: master toggle, comma-separated `HH:MM` list, color, line style.
- Display: label visibility, color, bar offset; wick vs. close breach; stop-on-touch; breached opacity; line widths for sessions vs. HTFs.
- Timezone for all time-of-day calculations.

**Implementation notes**

- HTF H/L values come from `request.security` (previous closed period) at rollover — no bar-by-bar tracking for day/week/month, since previous H/L are already fixed at close.
- Sessions are user-defined windows (not a Pine timeframe), so a single session tracker runs live H/L tracking and seals on session-end.
- A generic `Window` type holds the rolling N-slot closed array + optional live level; sessions and HTFs share the push/destroy/extend code path.
- Vertical line alignment is determined empirically per bar (`hour*60+minute == target`), which handles session-aligned HTFs correctly — no arithmetic divisibility assumption.

## Source Code

````pine
//@version=6
indicator("Plot Sessions / PXX", overlay=true, max_lines_count=500, max_labels_count=500)

import PineCoders/VisibleChart/5 as VC

// ========== INPUTS ==========
tz = input.string("America/New_York", "Timezone")

sAkz = input.session("2000-2359", "Asia",   inline="AKZ",  group="Sessions")
cAkz = input.color(color.new(#515353, 80), "", inline="AKZ", group="Sessions")
sLkz = input.session("0200-0500", "London", inline="LKZ",  group="Sessions")
cLkz = input.color(color.new(#8e44ad, 70), "", inline="LKZ", group="Sessions")
sAm  = input.session("0830-1100", "NYAM",   inline="AM",   group="Sessions")
cAm  = input.color(color.new(#2ec5f8, 60), "", inline="AM",  group="Sessions")
sLun = input.session("1200-1300", "Lunch",  inline="LUN",  group="Sessions")
cLun = input.color(color.new(#7f8c8d, 70), "", inline="LUN", group="Sessions")
sPm  = input.session("1330-1600", "NYPM",   inline="PM",   group="Sessions")
cPm  = input.color(color.new(#f8c14a, 50), "", inline="PM",  group="Sessions")
showSess = input.bool(true, "Show sessions", group="Sessions")
sessTransp = input.int(-1, "Transparency override", minval=-1, maxval=100, group="Sessions", tooltip="-1 keeps each session's own transparency. 0-100 applies one value to all sessions (0 = solid, 100 = invisible).")
sessDays   = input.int(30, "Retain for (days)", minval=1, maxval=60, group="Sessions", tooltip="Session ranges are kept this long regardless of whether they were breached, then deleted.")

showD = input.bool(true, "Daily",   inline="D", group="HTF")
cD    = input.color(color.new(#e65100, 50), "", inline="D", group="HTF")
wD    = input.int(1, "Width", minval=1, inline="D", group="HTF")
nD    = input.int(3, "# Previous Days",   options=[1, 2, 3, 4, 5], group="HTF")
showW = input.bool(true, "Weekly",  inline="W", group="HTF")
cW    = input.color(color.new(#e65100, 50), "", inline="W", group="HTF")
wW    = input.int(1, "Width", minval=1, inline="W", group="HTF")
nW    = input.int(3, "# Previous Weeks",  options=[1, 2, 3, 4, 5], group="HTF")
showM = input.bool(true, "Monthly", inline="M", group="HTF")
cM    = input.color(color.new(#e65100, 50), "", inline="M", group="HTF")
wM    = input.int(1, "Width", minval=1, inline="M", group="HTF")
nM    = input.int(3, "# Previous Months", options=[1, 2, 3, 4, 5], group="HTF")

showDO = input.bool(true, "Day Open (1800)",      inline="DO", group="Opens")
cDO    = input.color(color.new(#e65100, 50), "",  inline="DO", group="Opens")
nDO    = input.int(0, "# Previous DO", minval=0, maxval=5, group="Opens")
showWO = input.bool(true, "Week Open (Sun 1800)", inline="WO", group="Opens")
cWO    = input.color(color.new(#e65100, 50), "",  inline="WO", group="Opens")
nWO    = input.int(0, "# Previous WO", minval=0, maxval=5, group="Opens")
showMO = input.bool(true, "Month Open (1800)",    inline="MO", group="Opens")
cMO    = input.color(color.new(#e65100, 50), "",  inline="MO", group="Opens")
nMO    = input.int(0, "# Previous MO", minval=0, maxval=5, group="Opens")
showYO = input.bool(true, "Year Open (1800)",     inline="YO", group="Opens")
cYO    = input.color(color.new(#e65100, 50), "",  inline="YO", group="Opens")
nYO    = input.int(0, "# Previous YO", minval=0, maxval=5, group="Opens")

showVL  = input.bool(false, "Show vertical time lines", group="Vertical Lines")
vLTimes = input.string("00:00,02:00,05:00,07:00,08:30,09:30,11:00,12:00,13:30", "Times (HH:MM, comma-separated)", group="Vertical Lines")
vLColor = input.color(color.new(#ff4d6d, 70), "Color", group="Vertical Lines")
vLStyle = input.string("dashed", "Style", options=["solid", "dashed", "dotted"], group="Vertical Lines")
vLColor2= input.color(color.new(#1d1d1d, 50), "Label Color", group="Vertical Lines")

showLabels    = input.bool(true, "Show labels",         group="Display")
labelCol      = input.color(color.black, "Label color", group="Display")
labelOffset   = input.int(3, "Label offset (bars)", minval=1, group="Display")
useWicks      = input.bool(true, "Breach uses wicks",   group="Display")
stopOnTouch   = input.bool(true, "Stop on touch",       group="Display")
breachStyle   = input.string("Labels only", "Gray out breached", options=["Lines + labels", "Labels only", "None"], group="Display", tooltip="What fades once price crosses a level. Lines stop extending at the cross either way.")
breachOpacity = input.int(80, "Breached opacity", minval=0, maxval=100, group="Display")
wSess         = input.int(1, "Session line width", minval=1, group="Display")
wHtf          = input.int(1, "Open line width",    minval=1, group="Display")

cBreached = color.new(#9d9999, breachOpacity)

bool grayLines  = breachStyle == "Lines + labels"
bool grayLabels = breachStyle != "None"

// Persistent drawings are anchored in bar-time (xloc.bar_time), not bar_index:
// on low timeframes a monthly level's start can sit >10k bars back, which
// exceeds line.new's bar_index distance limit (RE10026). Time has no such cap.
// labelOffset is specified in bars, so convert it to a time delta.
int msPerBar = timeframe.in_seconds() * 1000
int lblOffMs = labelOffset * msPerBar

// ========== BREACH ==========
isBreachedHigh(float lvl) =>
    float p = useWicks ? high : close
    stopOnTouch ? p >= lvl : p > lvl

isBreachedLow(float lvl) =>
    float p = useWicks ? low : close
    stopOnTouch ? p <= lvl : p < lvl

// ========== LEVEL ==========
type Level
    string prefix
    string desc
    color  col
    int    width
    bool   withMid
    float  hi
    float  lo
    int    startBar
    int    startTime
    line   hln
    line   lln
    line   mln
    label  hlb
    label  llb
    label  mlb
    bool   hbr
    bool   lbr

mkLabel(int x, float y, string txt, string tt) =>
    label.new(x, y, txt, xloc=xloc.bar_time, tooltip=tt, style=label.style_none, size=size.small, textcolor=labelCol)

tipFor(Level lvl, string suffix) =>
    lvl.prefix + suffix + (na(lvl.desc) or lvl.desc == "" ? "" : "  " + lvl.desc)

method build(Level this) =>
    this.hln := line.new(this.startTime, this.hi, time, this.hi, xloc=xloc.bar_time, color=this.col, width=this.width)
    this.lln := line.new(this.startTime, this.lo, time, this.lo, xloc=xloc.bar_time, color=this.col, width=this.width)
    if showLabels
        this.hlb := mkLabel(time + lblOffMs, this.hi, this.prefix + "H", tipFor(this, "H"))
        this.llb := mkLabel(time + lblOffMs, this.lo, this.prefix + "L", tipFor(this, "L"))
    if this.withMid
        float mid = (this.hi + this.lo) / 2
        this.mln := line.new(this.startTime, mid, time, mid, xloc=xloc.bar_time, color=this.col, width=1, style=line.style_dashed)
        if showLabels
            this.mlb := mkLabel(time + lblOffMs, mid, this.prefix + "M", tipFor(this, "M"))

method destroy(Level this) =>
    if not na(this)
        line.delete(this.hln), line.delete(this.lln), line.delete(this.mln)
        label.delete(this.hlb), label.delete(this.llb), label.delete(this.mlb)

method dropMid(Level this) =>
    if not na(this) and not na(this.mln)
        line.delete(this.mln)
        label.delete(this.mlb)
        this.mln := na
        this.mlb := na
        this.withMid := false

method addMid(Level this) =>
    float mid = (this.hi + this.lo) / 2
    this.mln := line.new(this.startTime, mid, time, mid, xloc=xloc.bar_time, color=this.col, width=1, style=line.style_dashed)
    if showLabels
        this.mlb := mkLabel(time + lblOffMs, mid, this.prefix + "M", tipFor(this, "M"))
    this.withMid := true

method syncYs(Level this) =>
    line.set_y1(this.hln, this.hi)
    line.set_y2(this.hln, this.hi)
    line.set_y1(this.lln, this.lo)
    line.set_y2(this.lln, this.lo)
    if showLabels
        if not na(this.hlb)
            label.set_y(this.hlb, this.hi)
        if not na(this.llb)
            label.set_y(this.llb, this.lo)

method extendLive(Level this) =>
    line.set_x2(this.hln, time)
    line.set_x2(this.lln, time)
    if showLabels
        if not na(this.hlb)
            label.set_x(this.hlb, time + lblOffMs)
        if not na(this.llb)
            label.set_x(this.llb, time + lblOffMs)

extendSide(line ln, label lb, bool breached, float lvl, bool isLow) =>
    bool nowBreached = breached
    if not breached
        bool br = isLow ? isBreachedLow(lvl) : isBreachedHigh(lvl)
        if br
            nowBreached := true
            if grayLines
                line.set_color(ln, cBreached)
            if grayLabels and showLabels and not na(lb)
                label.set_textcolor(lb, cBreached)
        else
            line.set_x2(ln, time)
            if showLabels and not na(lb)
                label.set_x(lb, time + lblOffMs)
    nowBreached

method extend(Level this) =>
    if not na(this)
        this.hbr := extendSide(this.hln, this.hlb, this.hbr, this.hi, false)
        this.lbr := extendSide(this.lln, this.llb, this.lbr, this.lo, true)
        if not na(this.mln)
            if this.hbr or this.lbr
                if grayLines
                    line.set_color(this.mln, cBreached)
                if grayLabels and showLabels and not na(this.mlb)
                    label.set_textcolor(this.mlb, cBreached)
            else
                line.set_x2(this.mln, time)
                if showLabels and not na(this.mlb)
                    label.set_x(this.mlb, time + lblOffMs)

// ========== WINDOW ==========
type Window
    string prefix
    color  col
    int    width
    bool   midOnLatest
    bool   enabled
    string dateFmt
    int    maxClosed
    bool   freezeOnBreach   // breached level is kept (frozen) rather than deleted
    bool   frozenAtRoll     // frozen levels are cleared at the next period roll
    int    ageMs            // >0: delete any level older than this, breached or not
    array<Level> closed     // unbreached — extended every bar
    array<Level> frozen     // breached — never touched again until deleted
    Level  live
    int    curStart

newWindow(string prefix, color col, int width, bool midOnLatest, bool enabled, string dateFmt, int maxClosed, bool freezeOnBreach, bool frozenAtRoll, int ageMs) =>
    Window.new(prefix, col, width, midOnLatest, enabled, dateFmt, maxClosed, freezeOnBreach, frozenAtRoll, ageMs, array.new<Level>(), array.new<Level>(), na, na)

method pushClosed(Window this, Level lvl) =>
    if this.midOnLatest and this.closed.size() > 0
        this.closed.get(0).dropMid()
    while this.closed.size() >= this.maxClosed
        this.closed.pop().destroy()
    if this.midOnLatest
        lvl.addMid()
    this.closed.unshift(lvl)

// Only unbreached levels are walked. Once a level breaches it leaves `closed`
// for good — either deleted outright or parked in `frozen`, which is never
// iterated per bar. This is what keeps the per-bar cost flat as retention grows.
method extendAll(Window this) =>
    if this.enabled
        if not na(this.live)
            this.live.extendLive()
        if this.closed.size() > 0
            for i = this.closed.size() - 1 to 0
                Level lv = this.closed.get(i)
                lv.extend()
                if lv.hbr or lv.lbr
                    this.closed.remove(i)
                    if this.freezeOnBreach
                        lv.dropMid()
                        this.frozen.push(lv)
                    else
                        lv.destroy()

method clearFrozen(Window this) =>
    while this.frozen.size() > 0
        this.frozen.pop().destroy()

// Age-based eviction (sessions). Called only on the day roll, not per bar.
method evictAged(Window this, bool doIt) =>
    if this.enabled and this.ageMs > 0 and doIt
        int cutoff = time - this.ageMs
        if this.closed.size() > 0
            for i = this.closed.size() - 1 to 0
                if this.closed.get(i).startTime < cutoff
                    this.closed.remove(i).destroy()
        if this.frozen.size() > 0
            for i = this.frozen.size() - 1 to 0
                if this.frozen.get(i).startTime < cutoff
                    this.frozen.remove(i).destroy()

// ========== SESSION DRIVERS ==========
method sessBegin(Window this, string prefix, color col) =>
    if this.enabled
        Level lvl = Level.new(prefix, "", col, this.width, false, high, low, bar_index, time, hbr = false, lbr = false)
        lvl.build()
        this.live := lvl

method sessUpdate(Window this) =>
    if this.enabled and not na(this.live)
        bool changed = false
        if high > this.live.hi
            this.live.hi := high
            changed := true
        if low < this.live.lo
            this.live.lo := low
            changed := true
        if changed
            this.live.syncYs()

method sessEnd(Window this) =>
    if this.enabled and not na(this.live)
        this.pushClosed(this.live)
        this.live := na

// ========== HTF DRIVER ==========
method htfRoll(Window this, bool newP, float prevHi, float prevLo) =>
    if this.enabled
        if newP and this.frozenAtRoll
            this.clearFrozen()
        if newP and not na(this.curStart) and not na(prevHi) and not na(prevLo)
            string desc = this.dateFmt == "" ? "" : str.format_time(time[1], this.dateFmt, tz)
            Level lvl = Level.new(this.prefix, desc, this.col, this.width, false, prevHi, prevLo, bar_index, this.curStart, hbr = false, lbr = false)
            lvl.build()
            this.pushClosed(lvl)
        if newP
            this.curStart := time

// ========== OPEN LINE (single price, no breach) ==========
type OpenLine
    string prefix
    string desc
    color  col
    int    width
    float  px
    int    startTime
    line   ln
    label  lb

method buildO(OpenLine this) =>
    this.ln := line.new(this.startTime, this.px, time, this.px, xloc=xloc.bar_time, color=this.col, width=this.width)
    if showLabels
        this.lb := mkLabel(time + lblOffMs, this.px, this.prefix, this.prefix + (this.desc == "" ? "" : "  " + this.desc))

method destroyO(OpenLine this) =>
    if not na(this)
        line.delete(this.ln)
        label.delete(this.lb)

method extendO(OpenLine this) =>
    if not na(this) and not na(this.ln)
        line.set_x2(this.ln, time)
        if showLabels and not na(this.lb)
            label.set_x(this.lb, time + lblOffMs)

// ========== OPEN WINDOW (rolling N + current) ==========
type OWindow
    string prefix
    color  col
    int    width
    bool   enabled
    string dateFmt
    int    maxClosed
    array<OpenLine> closed
    OpenLine current

newOWindow(string prefix, color col, int width, bool enabled, string dateFmt, int maxClosed) =>
    OWindow.new(prefix, col, width, enabled, dateFmt, maxClosed, array.new<OpenLine>(), na)

method oRoll(OWindow this, bool isOpenBar) =>
    if this.enabled and isOpenBar
        if not na(this.current)
            if this.maxClosed > 0
                while this.closed.size() > 0 and this.closed.size() >= this.maxClosed
                    this.closed.pop().destroyO()
                this.closed.unshift(this.current)
            else
                this.current.destroyO()
        int    tradingTime = time + 6 * 60 * 60 * 1000  // shift 18:00 NY → next trading day
        string desc        = this.dateFmt == "" ? "" : str.format_time(tradingTime, this.dateFmt, tz)
        OpenLine ol = OpenLine.new(this.prefix, desc, this.col, this.width, open, time, na, na)
        ol.buildO()
        this.current := ol

method extendAllO(OWindow this) =>
    if this.enabled
        if not na(this.current)
            this.current.extendO()
        if this.closed.size() > 0
            for i = 0 to this.closed.size() - 1
                this.closed.get(i).extendO()

// ========== TIMEFRAME GATING ==========
int tfSec = timeframe.in_seconds()

bool tfSess = timeframe.isintraday and tfSec <= 3600    // H1 and below
bool tfVL   = timeframe.isintraday and tfSec <= 1800    // 30m — 08:30/13:30 need it
bool tfOpen = timeframe.isintraday and tfSec <= 14400   // H4 and below
bool tfD    = tfSec < 86400                             // below Daily
bool tfW    = tfSec < 604800                            // below Weekly
bool tfM    = tfSec < 2592000                           // below Monthly

// ========== INSTANCES ==========
// Retention policy per window:
//   sessions — kept sessDays regardless of breach (freeze, age-evict)
//   PD       — breached levels linger until the next 18:00 roll
//   PW / PM  — breached levels are deleted on the spot (unswept liquidity only)
var wSessW = newWindow("",   cAkz, wSess, false, showSess and tfSess, "",          200, true,  false, sessDays * 86400000)
var wDay   = newWindow("PD", cD,   wD,    true,  showD and tfD,       "EEE MMM d", nD,  true,  true,  0)
var wWk    = newWindow("PW", cW,   wW,    false, showW and tfW,       "MMM d",     nW,  false, false, 0)
var wMo    = newWindow("PM", cM,   wM,    false, showM and tfM,       "MMM yyyy",  nM,  false, false, 0)

var wDOpn  = newOWindow("DO", cDO, wHtf, showDO and tfOpen, "EEE MMM d", nDO)
var wWOpn  = newOWindow("WO", cWO, wHtf, showWO and tfOpen, "MMM d",     nWO)
var wMOpn  = newOWindow("MO", cMO, wHtf, showMO and tfOpen, "MMM yyyy",  nMO)
var wYOpn  = newOWindow("YO", cYO, wHtf, showYO and tfOpen, "yyyy",      nYO)

// ========== PERIOD ROLLS ==========
// Defined ahead of the session block because session age-eviction runs on newD.
// These follow the exchange session, so for CME newD flips at 18:00 NY.
bool newD = ta.change(time("D")) != 0
bool newW = ta.change(time("W")) != 0
bool newM = ta.change(time("M")) != 0

// ========== SESSION DETECTION ==========
bool inAkz = not na(time(timeframe.period, sAkz, tz))
bool inLkz = not na(time(timeframe.period, sLkz, tz))
bool inAm  = not na(time(timeframe.period, sAm,  tz))
bool inLun = not na(time(timeframe.period, sLun, tz))
bool inPm  = not na(time(timeframe.period, sPm,  tz))
bool inAny = inAkz or inLkz or inAm or inLun or inPm

string sessPrefix = inAkz ? "AKZ-" : inLkz ? "LKZ-" : inAm ? "AM-" : inLun ? "LUN-" : inPm ? "PM-" : "SESS-"
color  sessRaw    = inAkz ? cAkz   : inLkz ? cLkz   : inAm ? cAm   : inLun ? cLun  : inPm ? cPm   : cAkz
color  sessCol    = sessTransp < 0 ? sessRaw : color.new(sessRaw, sessTransp)

var bool wasInSess = false
if not inAny and wasInSess
    wSessW.sessEnd()
if inAny and not wasInSess
    wSessW.sessBegin(sessPrefix, sessCol)
if inAny
    wSessW.sessUpdate()
wasInSess := inAny
wSessW.extendAll()
wSessW.evictAged(newD)

// ========== HTF SIGNALS ==========
[pdHi, pdLo] = request.security(syminfo.tickerid, "D", [high, low])
[pwHi, pwLo] = request.security(syminfo.tickerid, "W", [high, low])
[pmHi, pmLo] = request.security(syminfo.tickerid, "M", [high, low])

wDay.htfRoll(newD, pdHi, pdLo)
wWk.htfRoll(newW, pwHi, pwLo)
wMo.htfRoll(newM, pmHi, pmLo)

wDay.extendAll()
wWk.extendAll()
wMo.extendAll()

// ========== OPENS (DO / WO / MO / YO @ 18:00 NY) ==========
// All four are anchored to the NY trading-day boundary at 18:00.
// Detection requires the bar to actually OPEN at 18:00 NY — works on
// any timeframe whose bars align to that minute (1m/5m/15m/30m/1h/4h-NY/1D).
int curBarMin = hour(time, tz) * 60 + minute(time, tz)
bool isDOBar  = curBarMin == 1080  // 18:00

var int prevDOMonth = na
var int prevDOYear  = na
bool isWOBar = false
bool isMOBar = false
bool isYOBar = false
if isDOBar
    int tradingTime = time + 6 * 60 * 60 * 1000
    isWOBar := dayofweek(tradingTime, tz) == dayofweek.monday
    int curM = month(tradingTime, tz)
    int curY = year(tradingTime, tz)
    isMOBar := na(prevDOMonth) or curM != prevDOMonth
    isYOBar := na(prevDOYear)  or curY != prevDOYear
    prevDOMonth := curM
    prevDOYear  := curY

wDOpn.oRoll(isDOBar)
wWOpn.oRoll(isWOBar)
wMOpn.oRoll(isMOBar)
wYOpn.oRoll(isYOBar)

wDOpn.extendAllO()
wWOpn.extendAllO()
wMOpn.extendAllO()
wYOpn.extendAllO()

// ========== VERTICAL TIME LINES (current day only) ==========
var array<int>   vLTargets = array.new<int>()
var array<line>  vLines    = array.new<line>()
var array<label> vLLabels  = array.new<label>()

if barstate.isfirst
    string cleaned = str.replace_all(vLTimes, " ", "")
    array<string> entries = str.split(cleaned, ",")
    for i = 0 to entries.size() - 1
        array<string> hm = str.split(entries.get(i), ":")
        if hm.size() == 2
            float h = str.tonumber(hm.get(0))
            float m = str.tonumber(hm.get(1))
            if not na(h) and not na(m)
                vLTargets.push(int(h) * 60 + int(m))

string vLStyleResolved = switch vLStyle
    "solid"  => line.style_solid
    "dotted" => line.style_dotted
    =>          line.style_dashed

visibleBottomY() =>
    float lo = VC.low()
    float hi = VC.high()
    lo + (hi - lo) * 0.02

formatHHMM(int h, int m) =>
    (h < 10 ? "0" : "") + str.tostring(h) + (m < 10 ? "0" : "") + str.tostring(m)

verticalText(string s) =>
    string out = ""
    for i = 0 to str.length(s) - 1
        out := out + (i == 0 ? "" : "\n") + str.substring(s, i, i + 1)
    out

bool newNYDay = ta.change(dayofmonth(time, tz)) != 0

if showVL and tfVL and vLTargets.size() > 0
    if newNYDay
        while vLines.size() > 0
            line.delete(vLines.pop())
        while vLLabels.size() > 0
            label.delete(vLLabels.pop())

    for i = 0 to vLTargets.size() - 1
        int targ = vLTargets.get(i)
        if curBarMin == targ
            int m = targ % 60
            int h = int((targ - m) / 60)

            line ln = line.new(
                 bar_index,
                 0,
                 bar_index,
                 1,
                 extend = extend.both,
                 color = vLColor,
                 style = vLStyleResolved
            )
            vLines.push(ln)

            label lb = label.new(
                 bar_index,
                 visibleBottomY(),
                 verticalText(formatHHMM(h, m)),
                 xloc = xloc.bar_index,
                 yloc = yloc.price,
                 color = color.new(color.black, 100),
                 style = label.style_label_up,
                 textcolor = vLColor2,
                 text_formatting = text.format_bold,
                 size = size.normal
            )
            vLLabels.push(lb)

// Keep vertical labels pinned to bottom of visible screen
if showVL and vLLabels.size() > 0
    float yBottom = visibleBottomY()
    for i = 0 to vLLabels.size() - 1
        label lb = vLLabels.get(i)
        if not na(lb)
            label.set_y(lb, yBottom)
````
