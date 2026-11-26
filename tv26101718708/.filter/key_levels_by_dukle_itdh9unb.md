# Key Levels - By Dukle

- url: https://www.tradingview.com/script/ItDH9UNb-Key-Levels-By-Dukle/
- type: indicator
- pine_id: PUB;2933fa35ed3f479b9295db831eb2d8e6
- version: 3.0

## Description

KEY LEVELS — current day dH / dO / dL and previous day pdH / pdL

WHAT IT DOES

Draws the five reference levels most day traders check first, as clean horizontal lines with small tags to the right of each line: the current day's Open (dO), High (dH) and Low (dL), plus the previous day's High and Low (pdH, pdL) in a second color.

HOW IT WORKS

The levels are computed directly from the chart's own intraday bars — no higher-timeframe security calls. The day boundary follows the symbol's exchange trading day, the same boundary the built-in daily candles use. dO is fixed at the session open. dH and dL update in real time: the moment price prints a new high or low of the day, the line moves with it — that is by design, since "today's high so far" is a moving value until the session closes. At the daily rollover, the finished day's high and low become the new pdH and pdL, and the current-day lines reset to the new open.

HOW TO USE IT

Works on any intraday timeframe (it deliberately draws nothing on Daily and above, where the current candle already is the day). Typical uses: pdH/pdL as breakout or rejection zones for the session, dO as the intraday bull/bear line, dH/dL as the developing range. All five lines can be toggled individually; colors, line width and how far the lines extend to the right of price are configurable in the settings.

NOTES

The current-day lines updating with new highs/lows is intended behavior, not lookahead — the previous-day levels never change during the session. Nothing here is financial advice.

## Source Code

````pine
//@version=6
indicator("Key Levels - By Dukle", overlay = true)

// ── Inputs ────────────────────────────────────────────────────────────────
showCur  = input.bool(true, "Show current day  dH / dO / dL")
showPrev = input.bool(true, "Show previous day  pdH / pdL")
showWeek = input.bool(true, "Show week  pwH / pwL / wO")
showMon  = input.bool(true, "Show Monday range  monH / monL  (from Tuesday on)")
colCur   = input.color(color.new(color.white, 15), "Current day color")
colPrev  = input.color(color.new(color.orange, 25), "Previous day color")
colWeek  = input.color(color.new(color.aqua, 25), "Week color")
colMon   = input.color(color.new(color.fuchsia, 25), "Monday range color")
lineW    = input.int(1, "Line width", minval = 1, maxval = 4)
extBars  = input.int(15, "Extend right (bars)", minval = 0, maxval = 200)

// ── Track the day's levels locally (no security call, updates live) ─────
dayChg  = ta.change(time("D"))
newDay  = timeframe.isintraday and dayChg != 0

var float dO = na
var float dH = na
var float dL = na
var float pH = na
var float pL = na
var int   dayStart = na

if timeframe.isintraday
    if newDay or na(dO)
        pH := dH
        pL := dL
        dO := open
        dH := high
        dL := low
        dayStart := bar_index
    else
        dH := math.max(dH, high)
        dL := math.min(dL, low)

// ── Weekly levels ───────────────────────────────────────────────────────
// [1] + lookahead_on reads the last CLOSED weekly bar, so pwH / pwL stay frozen
// for the whole of the current week — the same contract pH / pL hold, and the
// only source that stays correct on charts holding under a week of bars.
// wO takes `open` with no offset: the CURRENT week's open, which is settled
// from that week's very first bar, so it is known rather than forward-looking.
[pwH, pwL, wO] = request.security(syminfo.tickerid, "W", [high[1], low[1], open], lookahead = barmerge.lookahead_on)

weekChg = ta.change(time("W"))
newWeek = timeframe.isintraday and weekChg != 0

// Left anchor for the weekly lines, with its fallback: when the loaded history
// begins mid-week no rollover ever fires, and every loaded bar then belongs to
// the current weekly bar — so the first loaded bar is the earliest honest
// anchor there is, which is exactly what the na() branch settles on.
var int weekStart = na
if na(weekStart) or newWeek
    weekStart := bar_index

// ── Monday's range ──────────────────────────────────────────────────────
// "Monday" is the week's FIRST daily session, not a calendar-Monday test: some
// symbols open the week on Sunday evening and those bars belong to Monday's
// session, which dayofweek would wrongly exclude. dayIdx counts sessions since
// the week opened and doubles as the validity flag — it stays na until a week
// boundary has actually been witnessed, so a history that begins mid-week
// reports nothing rather than a partial Monday.
var float monH   = na
var float monL   = na
var int   dayIdx = na

if timeframe.isintraday
    if newWeek
        dayIdx := 0
        monH   := high
        monL   := low
    else if newDay and not na(dayIdx)
        dayIdx += 1
    if dayIdx == 0
        monH := math.max(monH, high)
        monL := math.min(monL, low)

// ── Drawing objects (created once, repositioned on the live bar) ─────────
var line  lnH = na
var line  lnO = na
var line  lnL = na
var line  lnPH = na
var line  lnPL = na
var line  lnWH = na
var line  lnWL = na
var line  lnWO = na
var line  lnMH = na
var line  lnML = na
var label lbH = na
var label lbO = na
var label lbL = na
var label lbPH = na
var label lbPL = na
var label lbWH = na
var label lbWL = na
var label lbWO = na
var label lbMH = na
var label lbML = na

f_line(line ln, int x1, int x2, float y, color c) =>
    line r = ln
    if na(r)
        r := line.new(x1, y, x2, y, color = c, width = lineW)
    line.set_xy1(r, x1, y)
    line.set_xy2(r, x2, y)
    line.set_color(r, c)
    line.set_width(r, lineW)
    r

f_tag(label lb, int x, float y, string txt, color c) =>
    label r = lb
    if na(r)
        r := label.new(x, y, txt, style = label.style_label_left, color = color.new(color.black, 100), textcolor = c, size = size.small)
    label.set_xy(r, x, y)
    label.set_text(r, txt)
    label.set_textcolor(r, c)
    r

f_drop(line ln, label lb) =>
    if not na(ln)
        line.delete(ln)
    if not na(lb)
        label.delete(lb)

if barstate.islast and timeframe.isintraday
    int xR = bar_index + extBars
    // xloc.bar_index refuses coordinates older than bar_index - 10000, and a
    // week of 1m bars on a 24/7 symbol is 10080 — clamp instead of erroring.
    int xW = math.max(weekStart, bar_index - 10000)
    if showCur and not na(dH)
        lnH := f_line(lnH, dayStart, xR, dH, colCur)
        lnO := f_line(lnO, dayStart, xR, dO, colCur)
        lnL := f_line(lnL, dayStart, xR, dL, colCur)
        lbH := f_tag(lbH, xR, dH, "dH", colCur)
        lbO := f_tag(lbO, xR, dO, "dO", colCur)
        lbL := f_tag(lbL, xR, dL, "dL", colCur)
    else
        f_drop(lnH, lbH)
        f_drop(lnO, lbO)
        f_drop(lnL, lbL)
        lnH := na
        lnO := na
        lnL := na
        lbH := na
        lbO := na
        lbL := na
    if showPrev and not na(pH)
        lnPH := f_line(lnPH, dayStart, xR, pH, colPrev)
        lnPL := f_line(lnPL, dayStart, xR, pL, colPrev)
        lbPH := f_tag(lbPH, xR, pH, "pdH", colPrev)
        lbPL := f_tag(lbPL, xR, pL, "pdL", colPrev)
    else
        f_drop(lnPH, lbPH)
        f_drop(lnPL, lbPL)
        lnPH := na
        lnPL := na
        lbPH := na
        lbPL := na
    if showWeek and not na(pwH)
        lnWH := f_line(lnWH, xW, xR, pwH, colWeek)
        lnWL := f_line(lnWL, xW, xR, pwL, colWeek)
        lbWH := f_tag(lbWH, xR, pwH, "pwH", colWeek)
        lbWL := f_tag(lbWL, xR, pwL, "pwL", colWeek)
    else
        f_drop(lnWH, lbWH)
        f_drop(lnWL, lbWL)
        lnWH := na
        lnWL := na
        lbWH := na
        lbWL := na
    // Guarded on wO rather than pwH: in a symbol's first ever week the open is
    // known while the previous week's high is still na.
    if showWeek and not na(wO)
        lnWO := f_line(lnWO, xW, xR, wO, colWeek)
        lbWO := f_tag(lbWO, xR, wO, "wO", colWeek)
    else
        f_drop(lnWO, lbWO)
        lnWO := na
        lbWO := na
    // dayIdx 0 is Monday itself — hidden; 1+ is Tuesday on, frozen at Monday's
    // final range; na means no week boundary was ever seen, so nothing is drawn.
    if showMon and not na(monH) and dayIdx >= 1
        lnMH := f_line(lnMH, xW, xR, monH, colMon)
        lnML := f_line(lnML, xW, xR, monL, colMon)
        lbMH := f_tag(lbMH, xR, monH, "monH", colMon)
        lbML := f_tag(lbML, xR, monL, "monL", colMon)
    else
        f_drop(lnMH, lbMH)
        f_drop(lnML, lbML)
        lnMH := na
        lnML := na
        lbMH := na
        lbML := na
````
