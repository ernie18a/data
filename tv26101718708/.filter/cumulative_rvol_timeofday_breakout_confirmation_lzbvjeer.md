# Cumulative RVOL (Time-of-Day) + Breakout Confirmation

- url: https://www.tradingview.com/script/lzBVJEeR-Cumulative-RVOL-Time-of-Day-Breakout-Confirmation/
- type: indicator
- pine_id: PUB;f6fa368de6174b32ba7f765d105031b5
- version: 2.0

## Description

Is a breakout backed by real participation, or is it happening in an empty room? This script compares today's cumulative volume with what is normal for the same time of day, then grades every level break as confirmed, weak, or a trap risk.

[b]WHAT IT MEASURES[/b]
Raw volume is misleading. 2M shares is huge for a stock that normally trades 200k, and nothing for one that trades 50M. Plain RVOL (today's volume ÷ average daily volume) is also misleading intraday, because volume is heavily front-loaded: at 10:00 every stock looks "low" against a full-day average.

This script uses cumulative time-of-day RVOL:

cRVOL = volume from the session open up to this bar ÷ average volume from the open up to the same time over the last N sessions

1.0 means "normal for this time of day". 2.0 means twice the usual participation at this point of the session. Two lookbacks are computed side by side:
[list]
[*]Long (default 20 sessions): is this unusual versus the stock's monthly norm?
[*]Short (default 5 sessions): is it unusual even versus the recent days?
[/list]

[b]HOW IT IS BUILT[/b]
[list]
[*]Each completed session is stored as a cumulative-volume curve, one value per time slot (slot = minutes since the open ÷ chart timeframe). Slots are keyed by clock time rather than bar count, so thin symbols with missing bars stay aligned.
[*]Missing slots are forward-filled when a session closes. A partially loaded first session is discarded so it cannot drag the averages down.
[*]Nothing is plotted until the minimum history (default 5 sessions) has accumulated.
[*]On daily and higher timeframes it falls back to plain volume ÷ SMA of the previous N bars.
[/list]

[b]READING THE PANE[/b]
Long-lookback columns are drawn above zero and short-lookback columns below zero (mirror layout, can be switched off). The minus sign below zero is only the drawing; read −1.8 as 1.8x. The long columns are coloured by participation state:
[list]
[*]Grey, Absent: below 1.0, fewer participants than usual.
[*]Blue-grey, Normal: 1.0 up to the in-play threshold, flat.
[*]Bright green, Growing: rising over the last few bars.
[*]Teal, Holding: at or above the in-play threshold (default 1.5) and stable. This is the healthy case after a breakout.
[*]Orange, Fading: still elevated but falling.
[/list]
Reference lines sit at 1.0 (normal), 1.5 (in play) and 2.0 (hot).

[b]BREAKOUT GRADING ON THE PRICE CHART[/b]
The script draws previous-day high/low, opening-range high/low (default 15 minutes) and an optional manual level. When the close crosses one of them, the break is graded by participation at that moment:
[list]
[*]RVOL✓ (triangle): long cRVOL ≥ in-play threshold and short cRVOL ≥ 1.0. The break has real participation behind it.
[*]trap? (orange ×): both long and short cRVOL below 1.0. Price moved through the level, but participation did not show up.
[*]Grey dot: somewhere in between, a weak break.
[*]fade (orange diamond): after a confirmed break, long cRVOL drops back below the in-play threshold. Participation is leaving the move.
[/list]
Each level fires at most once per direction per day, and new signals stop at a configurable cut-off time.

A small table shows the current long and short cRVOL, the state, how much of an average full day's volume has already traded, and how many sessions are in the history.

[b]HOW IT DIFFERS FROM A STANDARD RVOL / RELATIVE-VOLUME-AT-TIME STUDY[/b]
[list]
[*]Two lookbacks shown together, so a stock that is hot versus last month but quiet versus last week is visible at a glance.
[*]Participation is classified into states (absent / normal / growing / holding / fading) instead of being shown as a bare number.
[*]Level breaks are graded by participation, which turns the ratio into a breakout-confirmation and trap-warning tool.
[*]A fade warning fires when a confirmed move loses its participation.
[/list]

[b]HOW TO USE IT[/b]
[list=1]
[*]Check the state first. Absent means levels matter less today, because fewer traders are watching them.
[*]When price reaches a level, look at the grade. RVOL✓ is a stronger case. trap? and the grey dot call for caution.
[*]After a break, watch the colour. Teal or green means participation is holding; orange followed by a fade marker means it is leaving.
[*]This is a filter and a confirmation tool, not an entry signal on its own. trap? means "unconfirmed", not "reverse": low-participation moves can and do continue.
[/list]

[b]SETTINGS[/b]
[list]
[*]Session open hour / minute and session length in exchange time. Defaults are NSE (09:15, 375 minutes); for US equities use 09:30 and 390.
[*]No new signals after N minutes from the open (default 365 = 15:20 IST).
[*]Long / short lookback, minimum history, in-play and hot thresholds, short-lookback confirmation level, slope bars and dead-band for the state.
[*]Toggle previous-day levels, opening range (and its length), manual level, level lines and the table.
[/list]

[b]ALERTS[/b]
Confirmed breakout up, confirmed breakdown, trap risk, participation fading, and cRVOL crossing the hot threshold.

[b]LIMITATIONS[/b]
[list]
[*]It needs intraday history covering the lookback (20 sessions on a 1-minute chart is about 7,500 bars).
[*]It needs a symbol with volume. Spot indices have none; use futures or stocks.
[*]Continuous futures roll between contracts around expiry, which distorts volume comparisons for a few sessions.
[*]Half-day or special sessions enter the averages and can skew them for the following N sessions.
[*]On the real-time bar, the partial bar volume is compared against completed bars, so the live value can read slightly low until the bar closes.
[/list]

[b]CREDIT[/b]
The idea of judging breakouts by cumulative, time-of-day relative volume, and of reading participation as growing, holding, fading or absent, comes from a public educational video by SMB Capital on relative volume. This script is an independent Pine Script implementation of that concept.

This script is for educational and informational purposes only. It is not financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Cumulative RVOL (time-of-day) — concept from SMB Capital "Trading won't work unless you know THIS Indicator"
// Today's cumulative volume from the open up to this bar, divided by the average cumulative volume
// up to the SAME time of day over the last 20 / 5 sessions. 1.0 = normal for this time of day.
//@version=6
indicator("Cumulative RVOL (time-of-day)", shorttitle = "cRVOL", overlay = false, max_labels_count = 200)

// ───────────────────────── Inputs ─────────────────────────
grpS = "Session"
openH      = input.int(9,   "Session open hour (exchange tz)",   0, 23, group = grpS)
openM      = input.int(15,  "Session open minute",               0, 59, group = grpS)
sessLen    = input.int(375, "Session length (minutes)",          30, 1440, group = grpS, tooltip = "NSE 09:15–15:30 = 375. US 09:30–16:00 = 390.")
cutoffMin  = input.int(365, "No new signals after (minutes from open)", 1, 1440, group = grpS, tooltip = "365 = 15:20 IST on NSE.")

grpR = "RVOL"
lenLong    = input.int(20,  "Long lookback (days)",  2, 60, group = grpR)
lenShort   = input.int(5,   "Short lookback (days)", 1, 20, group = grpR)
minDays    = input.int(5,   "Min days of history before plotting", 1, 20, group = grpR)
thr        = input.float(1.5, "In-play threshold",      0.5, 10.0, 0.1, group = grpR)
hot        = input.float(2.0, "Hot threshold (alert)",  0.5, 20.0, 0.1, group = grpR)
rv5Min     = input.float(1.0, "Short-lookback RVOL needed to confirm", 0.1, 10.0, 0.1, group = grpR)
slopeK     = input.int(3,   "State slope bars", 1, 20, group = grpR)
slopeEps   = input.float(0.05, "State slope dead-band", 0.0, 1.0, 0.01, group = grpR)
mirror     = input.bool(true, "Mirror layout (long lookback up, short lookback down)", group = grpR)

grpF = "Futures roll"
rollMode   = input.string("Auto", "Front-month-only baseline", options = ["Auto", "On", "Off"], group = grpF, tooltip = "Restart the volume baseline at every contract rollover so only sessions of the active contract are averaged. Auto = on for futures symbols.")
expDowStr  = input.string("Tuesday", "Monthly expiry weekday", options = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"], group = grpF, tooltip = "Last <weekday> of the month. NSE index futures: Tuesday. A new contract starts on the first session after it, which also covers expiries moved earlier for a holiday.")
minRoll    = input.int(3, "Min sessions in new contract", 1, 10, group = grpF, tooltip = "Until the new contract has this many completed sessions, the continuous history is used and the bars are greyed out as provisional.")

grpL = "Breakout levels"
usePD      = input.bool(true, "Previous day high / low", group = grpL)
useORB     = input.bool(true, "Opening range high / low", group = grpL)
orbMin     = input.int(15,  "Opening range (minutes)", 1, 120, group = grpL)
manLvl     = input.float(0.0, "Manual level (0 = off)", group = grpL)
showLvls   = input.bool(true, "Draw levels on price chart", group = grpL)
showTable  = input.bool(true, "Show readout table", group = grpL)

// ───────────────────────── Session clock ─────────────────────────
tz        = syminfo.timezone
intraday  = timeframe.isintraday
tfMin     = timeframe.in_seconds() / 60.0
nSlots    = intraday ? math.max(1, int(math.ceil(sessLen / tfMin))) : 1
openTs    = timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), openH, openM)
minsOpen  = (time - openTs) / 60000.0
slot      = int(math.floor(minsOpen / tfMin))
inSess    = intraday and minsOpen >= 0 and slot < nSlots
newDay    = timeframe.change("1D")

// ───────────────────────── Per-slot volume history ─────────────────────────
// hist: one row per completed session, one column per time-of-day slot, value = cumulative volume at end of that slot.
var matrix<float> hist   = matrix.new<float>()
var array<float>  curDay = array.new<float>(nSlots, na)
var float cumVol     = 0.0
var int   firstSlot  = -1

// ───────────────────────── Futures roll tracking ─────────────────────────
bool rollOn = rollMode == "On" or (rollMode == "Auto" and syminfo.type == "futures")
int  expDow = expDowStr == "Monday" ? dayofweek.monday : expDowStr == "Tuesday" ? dayofweek.tuesday : expDowStr == "Wednesday" ? dayofweek.wednesday : expDowStr == "Thursday" ? dayofweek.thursday : dayofweek.friday

// Noon timestamp of the last <expDow> of the month containing timestamp t
f_expiry(int t) =>
    int y  = year(t, tz)
    int m  = month(t, tz)
    int ld = timestamp(tz, m == 12 ? y + 1 : y, m == 12 ? 1 : m + 1, 1, 12, 0) - 86400000
    ld - ((dayofweek(ld, tz) - expDow + 7) % 7) * 86400000

int dayNoon = timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), 12, 0)
var int prevNoon      = na
var int contractRows  = 0       // completed sessions of the active contract stored in hist
var int contractStart = na

if intraday and newDay
    // Close out the previous session. Skip a session that started late (partial first day on the chart).
    if firstSlot >= 0 and firstSlot <= 1
        float last = 0.0
        for s = 0 to nSlots - 1
            float v = curDay.get(s)
            if na(v)
                curDay.set(s, last)       // forward-fill missing bars (thin stocks, early close)
            else
                last := v
        hist.add_row(hist.rows(), array.copy(curDay))
        if hist.rows() > lenLong
            hist.remove_row(0)
        contractRows += 1
    // New contract starts on the first session after the expiry of the previous session's month
    if not na(prevNoon)
        int exp = f_expiry(prevNoon)
        if prevNoon <= exp and exp < dayNoon
            contractRows  := 0
            contractStart := dayNoon
    prevNoon := dayNoon
    curDay.fill(na)
    cumVol    := 0.0
    firstSlot := -1

if inSess
    cumVol += nz(volume)
    curDay.set(slot, cumVol)
    if firstSlot < 0
        firstSlot := slot

f_avg(int s, int n) =>
    int rows = hist.rows()
    int use  = math.min(n, rows)
    float sum = 0.0
    if use > 0
        for r = rows - use to rows - 1
            sum += hist.get(r, s)
    use > 0 ? sum / use : na

int   rowsNow = hist.rows()
bool  ready   = inSess and rowsNow >= minDays
// Roll mode: average only the active contract's completed sessions once there are enough of them
bool  rollUse     = rollOn and not na(contractStart) and contractRows >= minRoll
bool  provisional = rollOn and not na(contractStart) and contractRows < minRoll
int   useL    = rollUse ? math.min(lenLong, contractRows)  : lenLong
int   useS    = rollUse ? math.min(lenShort, contractRows) : lenShort
float avgL    = ready ? f_avg(slot, useL)    : na
float avgS    = ready ? f_avg(slot, useS)   : na
float avgDay  = ready ? f_avg(nSlots - 1, useL) : na

// Daily-chart fallback: plain RVOL vs prior N sessions
float dSmaL = ta.sma(volume, lenLong)[1]
float dSmaS = ta.sma(volume, lenShort)[1]

float rvL = intraday ? (avgL > 0 ? cumVol / avgL : na) : (dSmaL > 0 ? volume / dSmaL : na)
float rvS = intraday ? (avgS > 0 ? cumVol / avgS : na) : (dSmaS > 0 ? volume / dSmaS : na)
float pctADV = avgDay > 0 ? cumVol / avgDay : na

// ───────────────────────── Participation state ─────────────────────────
// 0 = n/a, 1 = Absent, 2 = Growing, 3 = Holding, 4 = Fading, 5 = Normal
float slope = (intraday and slot < slopeK) ? 0.0 : nz(rvL - rvL[slopeK])
int state = na(rvL) ? 0 : rvL < 1.0 ? 1 : slope > slopeEps ? 2 : slope < -slopeEps ? 4 : rvL >= thr ? 3 : 5

cAbsent  = color.new(#787B86, 0)
cGrowing = color.new(#00E676, 0)
cHolding = color.new(#26A69A, 0)
cFading  = color.new(#FF9800, 0)
cNormal  = color.new(#90A4AE, 0)
stateCol0 = state == 1 ? cAbsent : state == 2 ? cGrowing : state == 3 ? cHolding : state == 4 ? cFading : cNormal
stateCol  = provisional ? color.new(stateCol0, 65) : stateCol0
stateName = state == 1 ? "Absent" : state == 2 ? "Growing" : state == 3 ? "Holding" : state == 4 ? "Fading" : state == 5 ? "Normal" : "Warming up"
color colS = na(rvS) ? na : rvS >= thr ? color.new(#2962FF, provisional ? 65 : 0) : rvS >= 1.0 ? color.new(#2962FF, provisional ? 80 : 50) : color.new(#787B86, provisional ? 80 : 50)

// ───────────────────────── Histogram pane ─────────────────────────
plot(rvL, "Long cRVOL", stateCol, 4, plot.style_columns)
plot(mirror ? -rvS : rvS, "Short cRVOL", colS, mirror ? 4 : 2, mirror ? plot.style_columns : plot.style_histogram)
hline(1.0, "Normal",     color.new(color.gray, 30), hline.style_dashed)
hline(thr, "In play",    color.new(#26A69A, 30),    hline.style_dotted)
hline(hot, "Hot",        color.new(#00E676, 30),    hline.style_dotted)
hline(0.0, "Zero",       color.new(color.gray, 70), hline.style_solid)
hline(-1.0, "Normal (short)",  color.new(color.gray, 30), hline.style_dashed, display = mirror ? display.all : display.none)
hline(-thr, "In play (short)", color.new(#2962FF, 30),    hline.style_dotted, display = mirror ? display.all : display.none)

// ───────────────────────── Breakout levels ─────────────────────────
float pdh = request.security(syminfo.tickerid, "1D", high[1], lookahead = barmerge.lookahead_on)
float pdl = request.security(syminfo.tickerid, "1D", low[1],  lookahead = barmerge.lookahead_on)

var float orbH = na
var float orbL = na
if newDay
    orbH := na
    orbL := na
if inSess and minsOpen < orbMin
    orbH := na(orbH) ? high : math.max(orbH, high)
    orbL := na(orbL) ? low  : math.min(orbL, low)
bool  orbReady = inSess and minsOpen >= orbMin
float orbHi = orbReady ? orbH : na
float orbLo = orbReady ? orbL : na
float pdHi  = usePD ? pdh : na
float pdLo  = usePD ? pdl : na
float man   = manLvl > 0 ? manLvl : na

f_up(float lvl) => not na(lvl) and close > lvl and close[1] <= lvl
f_dn(float lvl) => not na(lvl) and close < lvl and close[1] >= lvl

bool xPdhUp = f_up(pdHi)
bool xPdlDn = f_dn(pdLo)
bool xOrbUp = f_up(useORB ? orbHi : na)
bool xOrbDn = f_dn(useORB ? orbLo : na)
bool xManUp = f_up(man)
bool xManDn = f_dn(man)

// One signal per level per direction per day
var bool dPdhUp = false
var bool dPdlDn = false
var bool dOrbUp = false
var bool dOrbDn = false
var bool dManUp = false
var bool dManDn = false
var bool longLive  = false
var bool shortLive = false
if newDay
    dPdhUp    := false
    dPdlDn    := false
    dOrbUp    := false
    dOrbDn    := false
    dManUp    := false
    dManDn    := false
    longLive  := false
    shortLive := false

bool canSignal = intraday and inSess and minsOpen < cutoffMin
bool brkUp = canSignal and ((xPdhUp and not dPdhUp) or (xOrbUp and not dOrbUp) or (xManUp and not dManUp))
bool brkDn = canSignal and ((xPdlDn and not dPdlDn) or (xOrbDn and not dOrbDn) or (xManDn and not dManDn))
if canSignal
    dPdhUp := dPdhUp or xPdhUp
    dPdlDn := dPdlDn or xPdlDn
    dOrbUp := dOrbUp or xOrbUp
    dOrbDn := dOrbDn or xOrbDn
    dManUp := dManUp or xManUp
    dManDn := dManDn or xManDn

bool confUp = brkUp and rvL >= thr and rvS >= rv5Min
bool confDn = brkDn and rvL >= thr and rvS >= rv5Min
bool trapUp = brkUp and rvL < 1.0 and rvS < 1.0
bool trapDn = brkDn and rvL < 1.0 and rvS < 1.0
bool weakUp = brkUp and not confUp and not trapUp
bool weakDn = brkDn and not confDn and not trapDn

if confUp
    longLive := true
if confDn
    shortLive := true
// After a confirmed breakout, warn once when participation drops back under the in-play line
bool fadeX    = ta.crossunder(rvL, thr)
bool fadeWarn = canSignal and (longLive or shortLive) and fadeX
if fadeWarn
    longLive  := false
    shortLive := false

// ───────────────────────── Price-chart overlay ─────────────────────────
plot(showLvls and inSess ? pdHi  : na, "PDH",  color.new(#26A69A, 40), 1, plot.style_linebr, force_overlay = true)
plot(showLvls and inSess ? pdLo  : na, "PDL",  color.new(#EF5350, 40), 1, plot.style_linebr, force_overlay = true)
plot(showLvls and useORB ? orbHi : na, "ORB H", color.new(#2962FF, 40), 1, plot.style_linebr, force_overlay = true)
plot(showLvls and useORB ? orbLo : na, "ORB L", color.new(#2962FF, 40), 1, plot.style_linebr, force_overlay = true)
plot(showLvls and inSess ? man   : na, "Manual", color.new(#FFEB3B, 30), 1, plot.style_linebr, force_overlay = true)

plotshape(confUp, "Confirmed breakout up",   shape.triangleup,   location.belowbar, color.new(#00E676, 0), text = "RVOL✓", textcolor = color.new(#00E676, 0), size = size.small, force_overlay = true)
plotshape(confDn, "Confirmed breakdown",     shape.triangledown, location.abovebar, color.new(#FF5252, 0), text = "RVOL✓", textcolor = color.new(#FF5252, 0), size = size.small, force_overlay = true)
plotshape(trapUp, "Trap risk (up, no RVOL)", shape.xcross,       location.abovebar, color.new(#FF9800, 0), text = "trap?", textcolor = color.new(#FF9800, 0), size = size.tiny,  force_overlay = true)
plotshape(trapDn, "Trap risk (down, no RVOL)", shape.xcross,     location.belowbar, color.new(#FF9800, 0), text = "trap?", textcolor = color.new(#FF9800, 0), size = size.tiny,  force_overlay = true)
plotshape(weakUp, "Weak breakout up",        shape.circle,       location.belowbar, color.new(#90A4AE, 0), size = size.tiny, force_overlay = true)
plotshape(weakDn, "Weak breakdown",          shape.circle,       location.abovebar, color.new(#90A4AE, 0), size = size.tiny, force_overlay = true)
plotshape(fadeWarn, "Participation fading",  shape.diamond,      location.abovebar, color.new(#FF9800, 0), text = "fade", textcolor = color.new(#FF9800, 0), size = size.tiny, force_overlay = true)

// ───────────────────────── Readout table ─────────────────────────
var table tb = table.new(position.top_right, 2, 7, color.new(#131722, 15), border_width = 1, border_color = color.new(#363A45, 0))
if showTable and barstate.islast
    tb.cell(0, 0, str.tostring(useL) + "D cRVOL", text_color = color.silver, text_size = size.small)
    tb.cell(1, 0, na(rvL) ? "—" : str.tostring(rvL, "0.00") + "x", text_color = stateCol, text_size = size.small)
    tb.cell(0, 1, str.tostring(useS) + "D cRVOL", text_color = color.silver, text_size = size.small)
    tb.cell(1, 1, na(rvS) ? "—" : str.tostring(rvS, "0.00") + "x", text_color = color.new(#2962FF, 0), text_size = size.small)
    tb.cell(0, 2, "State", text_color = color.silver, text_size = size.small)
    tb.cell(1, 2, stateName, text_color = stateCol, text_size = size.small)
    tb.cell(0, 3, "% of avg day done", text_color = color.silver, text_size = size.small)
    tb.cell(1, 3, na(pctADV) ? "—" : str.tostring(pctADV * 100, "0") + "%", text_color = color.silver, text_size = size.small)
    tb.cell(0, 4, "Days in history", text_color = color.silver, text_size = size.small)
    tb.cell(1, 4, intraday ? str.tostring(rowsNow) + " / " + str.tostring(lenLong) : "daily mode", text_color = color.silver, text_size = size.small)
    if rollOn and intraday
        tb.cell(0, 5, "Contract day", text_color = color.silver, text_size = size.small)
        tb.cell(1, 5, na(contractStart) ? "—" : str.tostring(contractRows + 1), text_color = color.silver, text_size = size.small)
        tb.cell(0, 6, "Baseline", text_color = color.silver, text_size = size.small)
        tb.cell(1, 6, rollUse ? "front month" : provisional ? "provisional" : "continuous", text_color = provisional ? color.new(#FF9800, 0) : color.silver, text_size = size.small)

// ───────────────────────── Alerts ─────────────────────────
alertcondition(confUp,   "cRVOL confirmed breakout up",  "{{ticker}} breakout CONFIRMED by cumulative RVOL @ {{close}}")
alertcondition(confDn,   "cRVOL confirmed breakdown",    "{{ticker}} breakdown CONFIRMED by cumulative RVOL @ {{close}}")
alertcondition(trapUp or trapDn, "cRVOL trap risk",      "{{ticker}} broke a level WITHOUT relative volume @ {{close}} — trap risk")
alertcondition(fadeWarn, "cRVOL participation fading",   "{{ticker}} participation fading after breakout @ {{close}}")
alertcondition(ta.crossover(rvL, hot), "cRVOL hot",      "{{ticker}} cumulative RVOL crossed the hot threshold")
````
