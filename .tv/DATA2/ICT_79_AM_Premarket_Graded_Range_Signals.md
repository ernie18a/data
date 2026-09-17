<!-- tradingview-pine-id: PUB;1e062a05e5044c11b496eeaffc9e3e7c -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# ICT 7-9 AM Premarket Graded Range + Signals

Source: https://www.tradingview.com/script/tOjQ5Tn2-ICT-7-9-AM-Premarket-Graded-Range-Signals/

## Description

This indicator marks the premarket range between two configurable New York
hours (default 07:00-09:00), grades it into eighths, classifies the session as
trending or consolidating, and derives signals from that classification during
the regular session.

WHAT IT DRAWS

Range box - the high and low of every bar inside the session window, drawn from
the first session bar to the first bar after it closes.

Graded levels - nine horizontal lines at 0%, 12.5%, 25%, 37.5%, 50%, 62.5%,
75%, 87.5% and 100% of the range, each optionally labelled. The 50% level
(equilibrium) can be highlighted with its own colour, weight and solid style.

Session label - TRENDING or CONSOLIDATING, placed at the range high.

Info table - the current or most recent session's classification, its high and
low, and the active signal mode.

The previous N completed sessions are kept and redrawn alongside the current
one, so recent premarket structure stays visible as reference.

HOW THE CLASSIFICATION WORKS

For each completed session the script measures how much of the range the
session actually travelled:

    abs(session close - session open) / (session high - session low)

If that ratio is at or above the Trend Threshold (default 0.55), the session
closed near one extreme after covering most of its range, and it is marked
TRENDING. Below the threshold the session opened and closed near the middle of
its own range and is marked CONSOLIDATING.

HOW THE SIGNALS WORK

Signals only evaluate inside the Signal Window (default 09:30-16:00 ET) and
only once the session has completed. The classification decides which signal
type is active, and the two are mutually exclusive:

After a CONSOLIDATING session - breakout signals. A BO Buy prints on the first
close above the session high, a BO Sell on the first close below the session
low. The reasoning is that a balanced premarket has not yet chosen a direction,
so the first displacement out of the range is treated as the decision.

After a TRENDING session - mean reversion signals. An MR Sell prints on the
first close back down through the 50% level from above, an MR Buy on the first
close back up through it from below. The reasoning is that a session which has
already expanded is more likely to retrace toward equilibrium than to extend
again immediately.

Each of the four signals fires at most once per session, so a level that is
tested repeatedly does not produce a cluster of arrows.

SETTINGS

Start Hour / End Hour (ET) - the session window. Set End Hour to 8 to close the
range before an 08:30 news release rather than through it.
Previous Sessions to Show - how many completed sessions remain on the chart.
Signal Window - the hours and minutes during which signals may fire. Defaults
to the regular cash session.
Trend Threshold - the close-to-range ratio separating trending from
consolidating. Raising it makes TRENDING rarer and produces more breakout
signals; lowering it does the opposite.
Signal Mode - Breakout only, Mean Reversion only, Both, or None.
Visual settings - toggles and colours for the box, the graded lines, the fib
labels, the 50% highlight and the session label.

REQUIREMENTS AND LIMITATIONS

Extended hours data must be enabled on the chart. Without it there are no
premarket bars, no range is built, and the indicator draws nothing - an
on-chart warning appears when this happens.

Use an intraday timeframe of one hour or less. On higher timeframes the
session window cannot be resolved and the script reports an error rather than
drawing a misleading range.

All times are New York time and follow US daylight saving automatically.

Levels come from completed sessions and do not change once the session closes.
Signals are evaluated on the developing bar and are final at bar close, so a
signal visible intrabar can disappear if price closes back inside the level.
Set alerts to "Once Per Bar Close" if you want confirmed signals only.

This is an indicator, not a strategy. It performs no backtesting, reports no
statistics, and makes no claim about profitability. It is a charting and study
tool, not financial advice. Test any idea it suggests on your own instrument
and timeframe before risking capital.

---

## Source Code

````pine
//@version=6
indicator("ICT 7-9 AM Premarket Graded Range + Signals", shorttitle="ICT PM Range", overlay=true,
     max_boxes_count=100, max_lines_count=500, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════
grpSession = "Session Settings"
sessionStart     = input.int(7, "Start Hour (ET)", minval=0, maxval=23, group=grpSession)
sessionEnd       = input.int(9, "End Hour (ET) - set to 8 on 8:30 news days", minval=1, maxval=23, group=grpSession)
showPrevSessions = input.int(3, "Previous Sessions to Show", minval=0, maxval=8, group=grpSession)

grpWindow = "Signal Window (ET)"
sigStartHour = input.int(9,  "Window Start", minval=0, maxval=23, group=grpWindow, inline="ws")
sigStartMin  = input.int(30, ":",            minval=0, maxval=59, group=grpWindow, inline="ws")
sigEndHour   = input.int(16, "Window End",   minval=0, maxval=23, group=grpWindow, inline="we")
sigEndMin    = input.int(0,  ":",            minval=0, maxval=59, group=grpWindow, inline="we")

grpVisual = "Visual Settings"
showBox       = input.bool(true,  "Show Range Box", group=grpVisual)
showGrades    = input.bool(true,  "Show Graded Levels", group=grpVisual)
show50        = input.bool(true,  "Highlight 50% Equilibrium", group=grpVisual)
showLabels    = input.bool(true,  "Show Trend/Consol Label", group=grpVisual)
showFibLabels = input.bool(true,  "Show Fib Level Labels", group=grpVisual)
warnNoData    = input.bool(true,  "Warn When No Session Data", group=grpVisual)

boxColor      = input.color(color.new(color.blue, 85), "Range Box Color", group=grpVisual)
gradeColor    = input.color(color.new(color.gray, 40), "Grade Lines Color", group=grpVisual)
eqColor       = input.color(color.orange, "50% Color", group=grpVisual)
trendColor    = input.color(color.green, "Trending Label", group=grpVisual)
consolColor   = input.color(color.red, "Consolidating Label", group=grpVisual)
fibLabelColor = input.color(color.white, "Fib Label Color", group=grpVisual)

grpLogic = "Trend vs Consolidation"
trendThreshold = input.float(0.55, "Trend Threshold", minval=0.3, maxval=0.9, step=0.05, group=grpLogic)

grpSignals = "Buy / Sell Signals"
signalMode   = input.string("Both", "Signal Mode", options=["Breakout only", "Mean Reversion only", "Both", "None"], group=grpSignals)
showBreakout = signalMode == "Breakout only" or signalMode == "Both"
showMeanRev  = signalMode == "Mean Reversion only" or signalMode == "Both"
buyColor     = input.color(color.green, "Buy Signal Color", group=grpSignals)
sellColor    = input.color(color.red,   "Sell Signal Color", group=grpSignals)

// ═══════════════════════════════════════════════════════════════
// INPUT VALIDATION
// ═══════════════════════════════════════════════════════════════
sigFrom = sigStartHour * 60 + sigStartMin
sigTo   = sigEndHour   * 60 + sigEndMin

if barstate.isfirst
    if not timeframe.isintraday or timeframe.in_seconds() > 3600
        runtime.error("ICT PM Range: use an intraday timeframe of 1 hour or less.")
    if sessionEnd <= sessionStart
        runtime.error("ICT PM Range: End Hour must be greater than Start Hour.")
    if sigTo <= sigFrom
        runtime.error("ICT PM Range: Signal Window End must be later than Window Start.")

// ═══════════════════════════════════════════════════════════════
// SESSION DETECTION (New York time)
// ═══════════════════════════════════════════════════════════════
// dayofmonth() in the NY timezone gives a true calendar-day rollover.
// time("D", tz) is wrong here: the 2nd argument of time() is the SESSION
// spec, not the timezone.
etHour     = hour(time,   "America/New_York")
etMin      = minute(time, "America/New_York")
etMinOfDay = etHour * 60 + etMin

isNewDay       = ta.change(dayofmonth(time, "America/New_York")) != 0
inSession      = etMinOfDay >= sessionStart * 60 and etMinOfDay < sessionEnd * 60
inSignalWindow = etMinOfDay >= sigFrom and etMinOfDay < sigTo

// ═══════════════════════════════════════════════════════════════
// SHARED CLASSIFIER
// ═══════════════════════════════════════════════════════════════
f_isTrend(float hi, float lo, float op, float cl) =>
    rng = hi - lo
    not na(rng) and rng > 0 and math.abs(cl - op) / rng >= trendThreshold

// ═══════════════════════════════════════════════════════════════
// STATE
// ═══════════════════════════════════════════════════════════════
type SessionData
    float hi
    float lo
    float op
    float cl
    int   startTime
    int   endTime
    bool  isTrend

var array<SessionData> sessions = array.new<SessionData>()

// Handles for every drawing we create, so the previous set can be removed
// before redrawing. Without this a fresh set leaks on every closed bar.
var array<box>   drawnBoxes  = array.new<box>()
var array<line>  drawnLines  = array.new<line>()
var array<label> drawnLabels = array.new<label>()

var array<float>  fibLevels = array.from(0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1.0)
var array<string> fibNames  = array.from("0%", "12.5%", "25%", "37.5%", "50%", "62.5%", "75%", "87.5%", "100%")

var float sessHigh      = na
var float sessLow       = na
var float sessOpen      = na
var float sessClose     = na
var int   sessStartTime = na

var float lastHi     = na
var float lastLo     = na
var float lastMid    = na
var bool  lastTrend  = false
var bool  boBuyUsed  = false
var bool  boSellUsed = false
var bool  mrBuyUsed  = false
var bool  mrSellUsed = false

// v6 allows bool to hold na, so track the previous session state explicitly
// rather than relying on inSession[1] being false on the first bar.
var bool wasInSession = false

// ═══════════════════════════════════════════════════════════════
// TRACK CURRENT SESSION
// ═══════════════════════════════════════════════════════════════
if isNewDay
    sessHigh      := na
    sessLow       := na
    sessOpen      := na
    sessClose     := na
    sessStartTime := na
    // Clear the prior day's levels so a day with no premarket data (holiday,
    // or extended hours switched off) cannot fire signals off a stale range.
    lastHi        := na
    lastLo        := na
    lastMid       := na
    lastTrend     := false

if inSession
    if na(sessStartTime)
        sessHigh      := high
        sessLow       := low
        sessOpen      := open
        sessStartTime := time
    else
        sessHigh := math.max(sessHigh, high)
        sessLow  := math.min(sessLow,  low)
    sessClose := close

sessionJustEnded = not inSession and wasInSession

// ═══════════════════════════════════════════════════════════════
// COMMIT COMPLETED SESSION
// ═══════════════════════════════════════════════════════════════
if sessionJustEnded and not na(sessHigh)
    isTrend = f_isTrend(sessHigh, sessLow, sessOpen, sessClose)

    array.unshift(sessions, SessionData.new(sessHigh, sessLow, sessOpen, sessClose, sessStartTime, time, isTrend))
    if array.size(sessions) > showPrevSessions + 1
        array.pop(sessions)

    lastHi     := sessHigh
    lastLo     := sessLow
    lastMid    := (sessHigh + sessLow) / 2
    lastTrend  := isTrend
    boBuyUsed  := false
    boSellUsed := false
    mrBuyUsed  := false
    mrSellUsed := false

// ═══════════════════════════════════════════════════════════════
// SIGNAL LOGIC
// ═══════════════════════════════════════════════════════════════
bool buyBreakout  = false
bool sellBreakout = false
bool buyMean      = false
bool sellMean     = false

if inSignalWindow and not na(lastHi)
    if showBreakout and not lastTrend
        if not boBuyUsed and close > lastHi and close[1] <= lastHi
            buyBreakout := true
            boBuyUsed   := true
        if not boSellUsed and close < lastLo and close[1] >= lastLo
            sellBreakout := true
            boSellUsed   := true

    if showMeanRev and lastTrend
        if not mrSellUsed and close[1] > lastMid and close <= lastMid
            sellMean   := true
            mrSellUsed := true
        if not mrBuyUsed and close[1] < lastMid and close >= lastMid
            buyMean   := true
            mrBuyUsed := true

// ═══════════════════════════════════════════════════════════════
// PLOT SIGNALS
// ═══════════════════════════════════════════════════════════════
plotshape(buyBreakout,  title="Breakout Buy",  style=shape.triangleup,   location=location.belowbar, color=buyColor,  size=size.normal, text="BO Buy")
plotshape(sellBreakout, title="Breakout Sell", style=shape.triangledown, location=location.abovebar, color=sellColor, size=size.normal, text="BO Sell")
plotshape(buyMean,      title="MeanRev Buy",   style=shape.circle,       location=location.belowbar, color=buyColor,  size=size.small,  text="MR Buy")
plotshape(sellMean,     title="MeanRev Sell",  style=shape.circle,       location=location.abovebar, color=sellColor, size=size.small,  text="MR Sell")

// ═══════════════════════════════════════════════════════════════
// DRAWING
// ═══════════════════════════════════════════════════════════════
f_clearDrawings() =>
    for b in drawnBoxes
        box.delete(b)
    for l in drawnLines
        line.delete(l)
    for lb in drawnLabels
        label.delete(lb)
    array.clear(drawnBoxes)
    array.clear(drawnLines)
    array.clear(drawnLabels)

f_draw(SessionData s) =>
    if not na(s.hi) and not na(s.lo) and s.hi != s.lo
        rangeSize = s.hi - s.lo

        if showBox
            array.push(drawnBoxes, box.new(s.startTime, s.hi, s.endTime, s.lo, xloc=xloc.bar_time,
                 border_color=color.new(boxColor, 40), bgcolor=boxColor))

        if showGrades
            for i = 0 to array.size(fibLevels) - 1
                pct   = array.get(fibLevels, i)
                nm    = array.get(fibNames,  i)
                price = s.lo + rangeSize * pct
                isMid = pct == 0.5 and show50
                array.push(drawnLines, line.new(s.startTime, price, s.endTime, price, xloc=xloc.bar_time,
                     color=isMid ? eqColor : gradeColor, width=isMid ? 2 : 1,
                     style=isMid ? line.style_solid : line.style_dotted))
                if showFibLabels
                    array.push(drawnLabels, label.new(s.endTime, price, nm, xloc=xloc.bar_time,
                         style=label.style_label_left, color=color.new(color.black, 30),
                         textcolor=fibLabelColor, size=size.tiny))

        if showLabels
            array.push(drawnLabels, label.new(s.endTime, s.hi, s.isTrend ? "TRENDING" : "CONSOLIDATING",
                 xloc=xloc.bar_time, style=label.style_label_down,
                 color=s.isTrend ? trendColor : consolColor, textcolor=color.white, size=size.small))

// ═══════════════════════════════════════════════════════════════
// REDRAW ON LAST BAR
// ═══════════════════════════════════════════════════════════════
if barstate.islast
    f_clearDrawings()

    // for...in is safe on an empty array. "for i = 0 to size - 1" is not:
    // Pine counts downward when the end value is below the start, so an
    // empty array yields i = 0 then i = -1 and array.get goes out of bounds.
    for s in sessions
        f_draw(s)

    if inSession and not na(sessStartTime)
        f_draw(SessionData.new(sessHigh, sessLow, sessOpen, sessClose, sessStartTime, time,
             f_isTrend(sessHigh, sessLow, sessOpen, sessClose)))

    if warnNoData and array.size(sessions) == 0 and na(sessStartTime)
        array.push(drawnLabels, label.new(bar_index, high, "No premarket session found\nCheck extended hours data",
             style=label.style_label_down, color=color.new(color.orange, 20),
             textcolor=color.white, size=size.small))

// ═══════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════
alertcondition(buyBreakout,  "Breakout Buy",  "Premarket range breakout BUY")
alertcondition(sellBreakout, "Breakout Sell", "Premarket range breakout SELL")
alertcondition(buyMean,      "MeanRev Buy",   "Premarket range mean reversion BUY")
alertcondition(sellMean,     "MeanRev Sell",  "Premarket range mean reversion SELL")

// ═══════════════════════════════════════════════════════════════
// INFO TABLE
// ═══════════════════════════════════════════════════════════════
var table info = table.new(position.top_right, 1, 4, bgcolor=color.new(#000000, 80))
if barstate.islast
    table.cell(info, 0, 0, "ICT Premarket Range", text_color=color.white, text_size=size.small)
    if not na(sessHigh) and not na(sessLow)
        isTrendNow = f_isTrend(sessHigh, sessLow, sessOpen, sessClose)
        table.cell(info, 0, 1, isTrendNow ? "TRENDING" : "CONSOLIDATING",
             text_color=isTrendNow ? color.green : color.red, text_size=size.normal)
        table.cell(info, 0, 2, "H " + str.tostring(sessHigh, format.mintick) + "  L " + str.tostring(sessLow, format.mintick),
             text_color=color.gray, text_size=size.tiny)
    else
        // Always rewrite these cells, otherwise the prior day's values linger.
        table.cell(info, 0, 1, "NO SESSION DATA", text_color=color.gray, text_size=size.normal)
        table.cell(info, 0, 2, "Check extended hours", text_color=color.gray, text_size=size.tiny)
    table.cell(info, 0, 3, "Mode: " + signalMode, text_color=color.aqua, text_size=size.tiny)

// Must be the last statement: records this bar's session state for the next bar.
wasInSession := inSession
````
