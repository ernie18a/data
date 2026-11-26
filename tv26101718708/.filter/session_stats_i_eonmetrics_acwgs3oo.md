# Session Stats I EonMetrics 

- url: https://www.tradingview.com/script/AcwgS3oo-Session-Stats-I-EonMetrics/
- type: indicator
- pine_id: PUB;f10f7e8e89d247b7ae2958febf036d9d
- version: 1.0

## Description

Session Stats by EonMetrics

Every market has session folklore: "Asia is quiet", "London sweeps the overnight range", "the New York morning makes the high or low of the day". This tool replaces the folklore with numbers — it measures how each session has actually behaved on YOUR symbol, on YOUR chart's history, and shows the result in one table.

https://www.tradingview.com/x/Tqkm60MN/

🔶[b]WHAT THIS TOOL IS AND IS NOT[/b]

This is a statistics dashboard, not a signal generator. It draws no entries, no targets, and it does not predict anything. It counts what already happened, so you can judge whether a session tendency on your instrument is real or imagined. All statistics are computed from completed sessions on confirmed bars. The only element that moves intrabar is the TODAY row, which is clearly labeled LIVE while a session is still open.

🔶[b]WHY THESE METRICS ARE ONE SCRIPT, NOT SEVERAL[/b]

Every row of the table answers the same single question — "what does this session usually do here?" — from a different side: how much it moves (range), where it sits in the day's structure (high/low of day), which way it leans (bull close, continuation), and how much participation it carries (volume share). Splitting these apart would leave each number without the context that makes it readable. The TODAY row then compares the current session against that same measured history, which is only possible because the history and the live reading live in one engine.

🔶[b]WHAT IT MEASURES[/b]

For up to four configurable sessions (defaults: Asia, London, NY AM, NY PM — New York time), over up to 500 stored trading days:

- Days (n) — the sample size behind every number in that column. Small samples (under ~20) are flagged in orange, because statistics on a handful of days are weak. If a number matters to you, check its n first.

- Avg Range and Median Range — the session's range expressed as a percent of the daily ATR, so quiet and violent weeks can be averaged together honestly. The median is shown next to the average on purpose: one news day can inflate an average, but it cannot drag a median. A big gap between the two tells you the session's "typical" day is calmer than its average suggests.

- High of Day / Low of Day — how often the session contained the trading day's extreme. A star marks the most frequent session in each row.

- Bull Close — how often the session closed above its open. Near 50% means no directional lean worth talking about.

- Continuation — how often the session repeated the direction of its own previous occurrence. Above 50%: the session tends to continue its behavior day over day; below: it tends to alternate.

- Vol Share — the session's average share of the whole trading day's volume.

- TODAY — the current session's range as a percent of daily ATR, plus its percentile within that session's own history. "62% (88th)" reads: today's London has already covered 62% of a normal day's range, which is larger than 88% of past Londons in the sample.

A weekday filter (Mon-Sun checkboxes) restricts the whole sample to the days you care about — Fridays only, weekdays only, and so on.

🔶[b]HOW THE NUMBERS ARE BUILT[/b]
-------------------------
The trading day rolls over at 18:00 in the selected session timezone, so the Asia session that opens in the evening belongs to the day it actually shapes. The daily ATR used for normalization is built internally from those same trading days (previous completed days only), which keeps the "day" definition consistent on 24/7 markets and means the ATR value is fixed for the whole current day. The script uses no higher-timeframe data requests. Session records are written once, when the session completes on a confirmed bar, and never change afterwards.

🔶[b]HOW TO USE IT[/b]

1. Add it to an intraday chart (1-minute to 1-hour). Let the chart load as much history as your plan allows — more history, bigger sample.
2. Check the Days (n) row first. Then read the table column by column: which session moves, which one sets the day's extremes, which one leans.
3. Use the TODAY row during the session: a high percentile early in the window tells you this session is already unusual relative to its own history.
4. Two alerts are available: one fires when any tracked session closes, one when the live session's range first reaches your chosen percentile (default 90th) of its own history.

🔶[b]SETTINGS[/b]

Four session slots (on/off, name, window, color), session timezone, sample depth, daily ATR length, weekday filter, optional rows (median, continuation, volume share), table position/size/theme, background tint of the active session, and the alert percentile.

🔶[b]LIMITATIONS[/b]

Session statistics describe the past; they are tendencies, not guarantees, and they can change when market conditions change. On symbols without meaningful volume data the Vol Share row will be empty. The tool needs an intraday chart — on daily and higher timeframes there are no bars inside a session window to measure.

This tool is for analysis and education. It is not financial advice, and past behavior of a session does not guarantee its future behavior. Always do your own analysis and manage your own risk.

## Source Code

````pine
//@version=6
indicator('EonMetrics Session Stats', 'Session Stats by EonMetrics', overlay=true, max_lines_count=50, max_labels_count=50, max_boxes_count=50)
grpSes = 'Sessions'

tzInp = input.string('America/New_York', 'Session Timezone', options=['America/New_York', 'Europe/London', 'Asia/Tokyo', 'UTC', 'Exchange'], group=grpSes,
  tooltip = 'Timezone the session windows below are written in. Exchange = the chart symbol\'s exchange timezone. The trading day rolls over at 18:00 in this timezone, so a session window should not cross 18:00.')

ena1 = input.bool(true, '', inline='s1', group=grpSes)
nam1 = input.string('Asia',   '', inline='s1', group=grpSes)
win1 = input.session('1900-0000', '', inline='s1', group=grpSes)
col1 = input.color(#ff9800, '', inline='s1', group=grpSes)

ena2 = input.bool(true, '', inline='s2', group=grpSes)
nam2 = input.string('London', '', inline='s2', group=grpSes)
win2 = input.session('0200-0830', '', inline='s2', group=grpSes)
col2 = input.color(#2196f3, '', inline='s2', group=grpSes)

ena3 = input.bool(true, '', inline='s3', group=grpSes)
nam3 = input.string('NY AM',  '', inline='s3', group=grpSes)
win3 = input.session('0830-1200', '', inline='s3', group=grpSes)
col3 = input.color(#089981, '', inline='s3', group=grpSes)

ena4 = input.bool(true, '', inline='s4', group=grpSes)
nam4 = input.string('NY PM',  '', inline='s4', group=grpSes)
win4 = input.session('1330-1600', '', inline='s4', group=grpSes,
  tooltip = 'Up to four sessions: on/off, name, window, color. Windows may cross midnight (the Asia default does). Overlapping windows are allowed and tracked independently.')
col4 = input.color(#9c27b0, '', inline='s4', group=grpSes)

// ═════════════════════════════════════════════════════════════════════════════
//  SAMPLE & FILTERS
// ═════════════════════════════════════════════════════════════════════════════
grpFlt = 'Sample & Filters'

maxDays = input.int(100, 'Max Days in Sample', minval=10, maxval=500, group=grpFlt,
  tooltip = 'How many completed trading days each session keeps in its history. More days = smoother statistics, slower reaction to regime changes. Limited by how much history your chart actually loads.')

atrLen = input.int(14, 'Daily ATR Length', minval=5, maxval=50, group=grpFlt,
  tooltip = 'Length of the internal daily ATR used to normalize session ranges. Built from previous COMPLETED trading days only, so the value is fixed for the whole current day.')

fMon = input.bool(true, 'Mon', inline='wd', group=grpFlt)
fTue = input.bool(true, 'Tue', inline='wd', group=grpFlt)
fWed = input.bool(true, 'Wed', inline='wd', group=grpFlt)
fThu = input.bool(true, 'Thu', inline='wd', group=grpFlt)
fFri = input.bool(true, 'Fri', inline='wd', group=grpFlt)
fSat = input.bool(true, 'Sat', inline='wd', group=grpFlt)
fSun = input.bool(true, 'Sun', inline='wd', group=grpFlt,
  tooltip = 'Weekday filter — statistics are computed only from trading days on the checked weekdays. Weekdays follow the trading day (18:00 rollover), not the calendar bar. Untick Sat/Sun on markets that do not trade weekends to keep the sample clean.')

// ═════════════════════════════════════════════════════════════════════════════
//  DASHBOARD & ALERTS
// ═════════════════════════════════════════════════════════════════════════════
grpDsh = 'Dashboard'

posInp  = input.string('Top Right', 'Position', options=['Top Left', 'Top Center', 'Top Right', 'Middle Left', 'Middle Center', 'Middle Right', 'Bottom Left', 'Bottom Center', 'Bottom Right'], group=grpDsh)
sizInp  = input.string('Small', 'Text Size', options=['Tiny', 'Small', 'Normal', 'Large'], group=grpDsh)
darkInp = input.bool(true, 'Dark Theme', group=grpDsh)

showMed  = input.bool(true,  'Median Range Row', group=grpDsh)
showCont = input.bool(true,  'Continuation Row', group=grpDsh)
showVol  = input.bool(true,  'Volume Share Row', group=grpDsh)

showBg = input.bool(false, 'Tint Background of Active Session', group=grpDsh,
  tooltip = 'Off by default for a clean chart. When on, tints the background in the active session\'s color. Note: sessions cover most of the 24h clock, so with this on the chart looks almost continuously shaded — that is expected, not a bug. Purely cosmetic; the dashboard is the actual tool.')

hotPct = input.int(90, 'Alert: Live Range Percentile', minval=50, maxval=100, group=grpDsh,
  tooltip = 'The "unusually large session" alert fires when the LIVE session\'s range first reaches this percentile of its own history (weekday-filtered). Fires at most once per session.')

// ═════════════════════════════════════════════════════════════════════════════
//  TYPES & STATE
// ═════════════════════════════════════════════════════════════════════════════
type Rec
    int   wd        // trading-day weekday (dayofweek constant)
    float rngA      // session range / daily ATR (na while the ATR warms up)
    float vol
    float volShare  // set at day rollover
    bool  bull
    bool  hod       // session contained the day's high (set at rollover)
    bool  lod
    float hi
    float lo

type Sess
    bool   building
    bool   wasIn
    bool   hotFired
    float  hi
    float  lo
    float  opn
    float  vol
    float  lastClose
    array<Rec> pend   // today's finished sessions, waiting for day rollover
    array<Rec> hist   // committed records, oldest first

var Sess s1 = Sess.new(false, false, false, na, na, na, 0.0, na, array.new<Rec>(), array.new<Rec>())
var Sess s2 = Sess.new(false, false, false, na, na, na, 0.0, na, array.new<Rec>(), array.new<Rec>())
var Sess s3 = Sess.new(false, false, false, na, na, na, 0.0, na, array.new<Rec>(), array.new<Rec>())
var Sess s4 = Sess.new(false, false, false, na, na, na, 0.0, na, array.new<Rec>(), array.new<Rec>())

// trading-day trackers (the day rolls over at 18:00 in the session timezone)
var float dHi  = na
var float dLo  = na
var float dVol = 0.0
var float prevDayClose = na
var array<float> dayTRs = array.new<float>()

// per-bar event flags (alerts)
bool evClosed = false
bool evHot    = false

string tzStr = tzInp == 'Exchange' ? syminfo.timezone : tzInp

bool okTf = timeframe.isintraday and timeframe.in_seconds() <= 3600

// trading-day key: shift time by +6h so the date flips at 18:00 in tzStr
int tShift = time + 21600000
int dKey   = year(tShift, tzStr) * 10000 + month(tShift, tzStr) * 100 + dayofmonth(tShift, tzStr)
int dWd    = dayofweek(tShift, tzStr)
bool dayRoll = not na(dKey[1]) and dKey != dKey[1]

// daily ATR from completed days only — fixed all day, never repaints
float dayATR = array.size(dayTRs) > 0 ? array.avg(dayTRs) : na

// ═════════════════════════════════════════════════════════════════════════════
//  SESSION WINDOWS (global scope — time() session strings must live here)
// ═════════════════════════════════════════════════════════════════════════════
bool in1 = okTf and ena1 and not na(time(timeframe.period, win1, tzStr))
bool in2 = okTf and ena2 and not na(time(timeframe.period, win2, tzStr))
bool in3 = okTf and ena3 and not na(time(timeframe.period, win3, tzStr))
bool in4 = okTf and ena4 and not na(time(timeframe.period, win4, tzStr))

// ═════════════════════════════════════════════════════════════════════════════
//  ENGINE
// ═════════════════════════════════════════════════════════════════════════════
f_wdOk(int wd) =>
    wd == dayofweek.monday ? fMon : wd == dayofweek.tuesday ? fTue : wd == dayofweek.wednesday ? fWed : wd == dayofweek.thursday ? fThu : wd == dayofweek.friday ? fFri : wd == dayofweek.saturday ? fSat : fSun

// percentile rank of x within a session's weekday-filtered range history
f_pctile(array<Rec> hist, float x) =>
    int below = 0
    int n = 0
    if array.size(hist) > 0
        for i = 0 to array.size(hist) - 1
            Rec r = array.get(hist, i)
            if f_wdOk(r.wd) and not na(r.rngA)
                n += 1
                if r.rngA <= x
                    below += 1
    n > 0 ? 100.0 * below / n : na

// one session's per-bar update; returns true when the session just closed
f_update(Sess s, bool inW) =>
    bool closedNow = false
    if inW and not s.wasIn
        s.building  := true
        s.hotFired  := false
        s.hi        := high
        s.lo        := low
        s.opn       := open
        s.vol       := 0.0
        s.lastClose := close
    if inW and s.building
        s.hi        := math.max(s.hi, high)
        s.lo        := math.min(s.lo, low)
        s.vol       := s.vol + nz(volume)
        s.lastClose := close
    if not inW and s.wasIn and s.building and barstate.isconfirmed
        s.building := false
        float rngA = not na(dayATR) and dayATR > 0 ? (s.hi - s.lo) / dayATR : na
        array.push(s.pend, Rec.new(dWd, rngA, s.vol, na, s.lastClose > s.opn, false, false, s.hi, s.lo))
        closedNow := true
    if barstate.isconfirmed
        s.wasIn := inW
    closedNow

// resolve a session's pending records against the just-completed day
f_resolve(Sess s, float dayHi, float dayLo, float dayVol) =>
    if array.size(s.pend) > 0
        for i = 0 to array.size(s.pend) - 1
            Rec r = array.get(s.pend, i)
            r.hod      := r.hi >= dayHi
            r.lod      := r.lo <= dayLo
            r.volShare := dayVol > 0 ? 100.0 * r.vol / dayVol : na
            array.push(s.hist, r)
        array.clear(s.pend)
    while array.size(s.hist) > maxDays
        array.remove(s.hist, 0)

// "unusually large live session" — at most once per session, confirmed bars only
f_hot(Sess s) =>
    bool fired = false
    if s.building and not s.hotFired and barstate.isconfirmed and not na(dayATR) and dayATR > 0
        float livePct = f_pctile(s.hist, (s.hi - s.lo) / dayATR)
        if not na(livePct) and livePct >= hotPct
            s.hotFired := true
            fired := true
    fired

// sessions first (a window ending on the rollover bar still belongs to the old day)
bool c1 = f_update(s1, in1)
bool c2 = f_update(s2, in2)
bool c3 = f_update(s3, in3)
bool c4 = f_update(s4, in4)
if c1 or c2 or c3 or c4
    evClosed := true

// day rollover: resolve HOD/LOD + volume share, push the day's true range
if dayRoll and barstate.isconfirmed
    if not na(dHi)
        f_resolve(s1, dHi, dLo, dVol)
        f_resolve(s2, dHi, dLo, dVol)
        f_resolve(s3, dHi, dLo, dVol)
        f_resolve(s4, dHi, dLo, dVol)
        float tr = na(prevDayClose) ? dHi - dLo : math.max(dHi - dLo, math.max(math.abs(dHi - prevDayClose), math.abs(dLo - prevDayClose)))
        array.push(dayTRs, tr)
        while array.size(dayTRs) > atrLen
            array.remove(dayTRs, 0)
    prevDayClose := close[1]
    dHi  := high
    dLo  := low
    dVol := nz(volume)
else
    dHi  := na(dHi) ? high : math.max(dHi, high)
    dLo  := na(dLo) ? low  : math.min(dLo, low)
    dVol := dVol + nz(volume)

// v6 'or' is lazy — call each f_hot separately so no session is skipped
bool h1 = f_hot(s1)
bool h2 = f_hot(s2)
bool h3 = f_hot(s3)
bool h4 = f_hot(s4)
if h1 or h2 or h3 or h4
    evHot := true

// ═════════════════════════════════════════════════════════════════════════════
//  BACKGROUND TINT
// ═════════════════════════════════════════════════════════════════════════════
color bgC = in1 ? col1 : in2 ? col2 : in3 ? col3 : in4 ? col4 : na
bgcolor(showBg and not na(bgC) ? color.new(bgC, 94) : na, title='Active session tint')

// ═════════════════════════════════════════════════════════════════════════════
//  DASHBOARD
// ═════════════════════════════════════════════════════════════════════════════
// theme + layout constants (all input-time, safe at global scope)
color thBg  = darkInp ? #1e222d : #ffffff
color thTx  = darkInp ? #d1d4dc : #131722
color thMut = darkInp ? #787b86 : #9598a1
color rowBg = darkInp ? color.new(#2a2e39, 40) : color.new(#f0f3fa, 40)

txtSz = sizInp == 'Tiny' ? size.tiny : sizInp == 'Small' ? size.small : sizInp == 'Normal' ? size.normal : size.large

tblPos = posInp == 'Top Left' ? position.top_left : posInp == 'Top Center' ? position.top_center : posInp == 'Top Right' ? position.top_right : posInp == 'Middle Left' ? position.middle_left : posInp == 'Middle Center' ? position.middle_center : posInp == 'Middle Right' ? position.middle_right : posInp == 'Bottom Left' ? position.bottom_left : posInp == 'Bottom Center' ? position.bottom_center : position.bottom_right

// row indices (depend on the row toggles only)
int R_N   = 1
int R_AVG = 2
int R_MED = showMed ? 3 : -1
int R_HOD = showMed ? 4 : 3
int R_LOD = R_HOD + 1
int R_BUL = R_HOD + 2
int R_CON = showCont ? R_HOD + 3 : -1
int R_VOL = showVol ? R_HOD + 3 + (showCont ? 1 : 0) : -1
int R_TOD = R_HOD + 3 + (showCont ? 1 : 0) + (showVol ? 1 : 0)

int nCols = 1 + (ena1 ? 1 : 0) + (ena2 ? 1 : 0) + (ena3 ? 1 : 0) + (ena4 ? 1 : 0)

var table T = table.new(tblPos, nCols, 11, bgcolor=thBg, border_width=1, border_color=color.new(thMut, 80), frame_color=color.new(thMut, 60), frame_width=1)

f_median(array<float> a) =>
    int n = array.size(a)
    float m = na
    if n > 0
        array<float> cp = array.copy(a)
        array.sort(cp, order.ascending)
        m := n % 2 == 1 ? array.get(cp, n / 2) : (array.get(cp, n / 2 - 1) + array.get(cp, n / 2)) / 2.0
    m

// aggregate one session's history under the weekday filter
f_stats(Sess s) =>
    int   n = 0
    float rngSum = 0.0
    array<float> rngs = array.new<float>()
    int hodN = 0
    int lodN = 0
    int bullN = 0
    int contN = 0
    int contHit = 0
    float volSum = 0.0
    int   volN = 0
    if array.size(s.hist) > 0
        for i = 0 to array.size(s.hist) - 1
            Rec r = array.get(s.hist, i)
            if f_wdOk(r.wd)
                n += 1
                if not na(r.rngA)
                    rngSum += r.rngA
                    array.push(rngs, r.rngA)
                if r.hod
                    hodN += 1
                if r.lod
                    lodN += 1
                if r.bull
                    bullN += 1
                if i > 0
                    Rec p = array.get(s.hist, i - 1)
                    contN += 1
                    if r.bull == p.bull
                        contHit += 1
                if not na(r.volShare)
                    volSum += r.volShare
                    volN += 1
    float avgR = array.size(rngs) > 0 ? rngSum / array.size(rngs) : na
    float medR = f_median(rngs)
    float hodP = n > 0 ? 100.0 * hodN / n : na
    float lodP = n > 0 ? 100.0 * lodN / n : na
    float bulP = n > 0 ? 100.0 * bullN / n : na
    float conP = contN > 0 ? 100.0 * contHit / contN : na
    float volP = volN > 0 ? volSum / volN : na
    [n, avgR, medR, hodP, lodP, bulP, conP, volP]

// today's range for the TODAY row: live if building, else last finished today
f_today(Sess s) =>
    float rngA = na
    bool  live = false
    if s.building and not na(dayATR) and dayATR > 0
        rngA := (s.hi - s.lo) / dayATR
        live := true
    else if array.size(s.pend) > 0
        Rec r = array.get(s.pend, array.size(s.pend) - 1)
        rngA := r.rngA
    [rngA, live]

f_fmtPct(float x, bool star) =>
    na(x) ? '—' : str.tostring(x, '#.0') + '%' + (star ? ' ★' : '')

// render one session column
f_col(Sess s, string nm, color cc, int ci, int n, float avgR, float medR, float hodP, float lodP, float bulP, float conP, float volP, bool starAvg, bool starHod, bool starLod) =>
    table.cell(T, ci, 0, nm, text_color=cc, text_size=txtSz, bgcolor=color.new(cc, 85))
    table.cell(T, ci, R_N, str.tostring(n), text_color=n < 20 ? color.orange : thTx, text_size=txtSz, tooltip=n < 20 ? 'Small sample — treat these numbers as indicative only.' : '')
    table.cell(T, ci, R_AVG, na(avgR) ? '—' : str.tostring(100 * avgR, '#.0') + '% ATR' + (starAvg ? ' ★' : ''), text_color=thTx, text_size=txtSz)
    if showMed
        table.cell(T, ci, R_MED, na(medR) ? '—' : str.tostring(100 * medR, '#.0') + '% ATR', text_color=thTx, text_size=txtSz)
    table.cell(T, ci, R_HOD, f_fmtPct(hodP, starHod), text_color=thTx, text_size=txtSz)
    table.cell(T, ci, R_LOD, f_fmtPct(lodP, starLod), text_color=thTx, text_size=txtSz)
    table.cell(T, ci, R_BUL, f_fmtPct(bulP, false), text_color=na(bulP) ? thTx : bulP >= 55 ? #089981 : bulP <= 45 ? #f23645 : thTx, text_size=txtSz)
    if showCont
        table.cell(T, ci, R_CON, f_fmtPct(conP, false), text_color=thTx, text_size=txtSz)
    if showVol
        table.cell(T, ci, R_VOL, f_fmtPct(volP, false), text_color=thTx, text_size=txtSz)
    [tRng, tLive] = f_today(s)
    float tPct = na(tRng) ? na : f_pctile(s.hist, tRng)
    string tTxt = na(tRng) ? '—' : str.tostring(100 * tRng, '#.0') + '%' + (na(tPct) ? '' : ' (' + str.tostring(tPct, '#') + 'th)') + (tLive ? ' LIVE' : '')
    color tCol = na(tPct) ? thTx : tPct >= 75 ? #089981 : tPct <= 25 ? #f23645 : color.orange
    table.cell(T, ci, R_TOD, tTxt, text_color=tCol, text_size=txtSz, bgcolor=tLive ? rowBg : na)

if barstate.islast
    table.clear(T, 0, 0, nCols - 1, 10)
    if not okTf
        table.cell(T, 0, 0, 'Session Stats needs an intraday chart (1m - 1h).', text_color=thTx, text_size=txtSz)
    else
        // label column with plain-language tooltips
        table.cell(T, 0, 0, 'SESSION', text_color=thMut, text_size=txtSz, text_halign=text.align_left)
        table.cell(T, 0, R_N, 'Days (n)', text_color=thMut, text_size=txtSz, text_halign=text.align_left, tooltip='Completed sessions in the sample after the weekday filter. Statistics on fewer than ~20 days are weak — the cell turns orange as a reminder.')
        table.cell(T, 0, R_AVG, 'Avg Range', text_color=thMut, text_size=txtSz, text_halign=text.align_left, tooltip='Average session range as a % of the daily ATR (previous completed days). 45% means the session typically covers 45% of a normal day\'s range. ★ marks the widest session.')
        if showMed
            table.cell(T, 0, R_MED, 'Median Range', text_color=thMut, text_size=txtSz, text_halign=text.align_left, tooltip='Median of the same distribution. One news day cannot drag the median, so a big gap between average and median means the session\'s typical day is calmer than its average suggests.')
        table.cell(T, 0, R_HOD, 'High of Day', text_color=thMut, text_size=txtSz, text_halign=text.align_left, tooltip='How often this session contained the trading day\'s HIGH. ★ marks the most frequent one.')
        table.cell(T, 0, R_LOD, 'Low of Day', text_color=thMut, text_size=txtSz, text_halign=text.align_left, tooltip='How often this session contained the trading day\'s LOW. ★ marks the most frequent one.')
        table.cell(T, 0, R_BUL, 'Bull Close', text_color=thMut, text_size=txtSz, text_halign=text.align_left, tooltip='Share of sessions that closed above their open. Near 50% = no directional lean.')
        if showCont
            table.cell(T, 0, R_CON, 'Continuation', text_color=thMut, text_size=txtSz, text_halign=text.align_left, tooltip='How often the session repeated its previous occurrence\'s direction. Above 50% = the session tends to continue; below = it tends to flip.')
        if showVol
            table.cell(T, 0, R_VOL, 'Vol Share', text_color=thMut, text_size=txtSz, text_halign=text.align_left, tooltip='Average share of the trading day\'s volume traded inside this session.')
        table.cell(T, 0, R_TOD, 'Today', text_color=thTx, text_size=txtSz, text_halign=text.align_left, tooltip='Today\'s session range as a % of daily ATR, and (in brackets) its percentile within this session\'s own weekday-filtered history. LIVE = session still open, value still growing. This is the only row that moves intrabar.')

        [n1, avg1, med1, hod1, lod1, bul1, con1, vol1] = f_stats(s1)
        [n2, avg2, med2, hod2, lod2, bul2, con2, vol2] = f_stats(s2)
        [n3, avg3, med3, hod3, lod3, bul3, con3, vol3] = f_stats(s3)
        [n4, avg4, med4, hod4, lod4, bul4, con4, vol4] = f_stats(s4)

        float bestAvg = math.max(nz(ena1 ? avg1 : na, 0), math.max(nz(ena2 ? avg2 : na, 0), math.max(nz(ena3 ? avg3 : na, 0), nz(ena4 ? avg4 : na, 0))))
        float bestHod = math.max(nz(ena1 ? hod1 : na, 0), math.max(nz(ena2 ? hod2 : na, 0), math.max(nz(ena3 ? hod3 : na, 0), nz(ena4 ? hod4 : na, 0))))
        float bestLod = math.max(nz(ena1 ? lod1 : na, 0), math.max(nz(ena2 ? lod2 : na, 0), math.max(nz(ena3 ? lod3 : na, 0), nz(ena4 ? lod4 : na, 0))))

        int ci = 1
        if ena1
            f_col(s1, nam1, col1, ci, n1, avg1, med1, hod1, lod1, bul1, con1, vol1, not na(avg1) and bestAvg > 0 and avg1 >= bestAvg, not na(hod1) and bestHod > 0 and hod1 >= bestHod, not na(lod1) and bestLod > 0 and lod1 >= bestLod)
            ci += 1
        if ena2
            f_col(s2, nam2, col2, ci, n2, avg2, med2, hod2, lod2, bul2, con2, vol2, not na(avg2) and bestAvg > 0 and avg2 >= bestAvg, not na(hod2) and bestHod > 0 and hod2 >= bestHod, not na(lod2) and bestLod > 0 and lod2 >= bestLod)
            ci += 1
        if ena3
            f_col(s3, nam3, col3, ci, n3, avg3, med3, hod3, lod3, bul3, con3, vol3, not na(avg3) and bestAvg > 0 and avg3 >= bestAvg, not na(hod3) and bestHod > 0 and hod3 >= bestHod, not na(lod3) and bestLod > 0 and lod3 >= bestLod)
            ci += 1
        if ena4
            f_col(s4, nam4, col4, ci, n4, avg4, med4, hod4, lod4, bul4, con4, vol4, not na(avg4) and bestAvg > 0 and avg4 >= bestAvg, not na(hod4) and bestHod > 0 and hod4 >= bestHod, not na(lod4) and bestLod > 0 and lod4 >= bestLod)

// ═════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ═════════════════════════════════════════════════════════════════════════════
alertcondition(evClosed, title='1. Session closed', message='Session Stats: a tracked session just closed — its record was added to the sample.')
alertcondition(evHot,    title='2. Unusually large live session', message='Session Stats: the live session\'s range reached your percentile threshold vs its own history.')
````
