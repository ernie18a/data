<!-- tradingview-pine-id: PUB;85114d15d7694a0ea3e3b66f567cbbc4 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Symbol vs NQ [BMT]

Source: https://www.tradingview.com/script/EIgE2f5Q-Symbol-vs-NQ-BMT/

## Description

Symbol vs NQ [BMT]

Is the symbol on the chart adding something of its own, beyond how much more it moves than the Nasdaq does, and does it need megacap leadership to work? The name's move from a shared anchor, minus its beta to NQ times NQ's move from the same anchor, is the residual: above zero the name is beating the path its beta implies, below zero it is rising less than its beta alone would have delivered. The chart is tinted by that state.

What it draws

A background tint on the price chart: green while the name is beating its NQ-beta path by more than the threshold, red while it is missing it, nothing in between. A stronger green marks a confirmed lead, and a triangle under each confirmed bar (size is an input) carries a hover reading. A vertical line marks the anchor bar. A status table along one edge shows the name's move, its residual and sigma, its beta to NQ, NQ's own move and state, the regime profile, and the anchor in force.

The green takes the stairs up and the elevator down. It needs four consecutive bars above the threshold before it paints, and it drops the moment the residual is back at or under zero rather than waiting for minus the threshold. Red is immediate both ways. That is the asymmetry of the CARS state machine, and it is what keeps the tint from flickering on one-bar noise without smoothing away the turns.

While the name closes under its 50-day average, a positive residual is discounted to 70% before the threshold applies (an input, on by default). A discount, never a veto: a name can still read as leading under its 50-day, it just needs more to get there, and a lagging reading is never damped since that would slow the off-switch. The 50-day is read from the daily bars on every chart timeframe, the prior session's value, so it does not repaint.

The anchor

Measure picks the bar both series are measured from; the name and NQ always share it. The period anchors are the same bars Index Lead Lag [BMT] uses, so with both on the chart they agree; the swing anchors are NQ's extremes where that script uses ES's.

[*] Auto (default) chooses from the chart timeframe: session open under an hour, week open intraday above that, month open on a daily chart, quarter open above. The Ref cell shows what it resolved to.
[*] Session open, Prior close, Week open, Month open, Quarter open. Each resets on its boundary. On CME index futures the daily bar opens at 18:00 ET, so Session open is the Globex open and the overnight sits inside the measure; Prior close is the 17:00 settlement.
[*] RTH open: the open of the first bar of the cash session (09:30 to 16:00 New York by default, an input), with the overnight left out.
[*] NQ swing low / NQ swing high: the lowest low or highest high NQ has printed in the range on screen, so it reads as "since the Nasdaq turned, has this name done more than its beta?". Pan or zoom and it re-resolves to the new view. NQ's turn rather than the name's own on purpose: a name measured from its own low is at its minimum there by construction, which flatters every residual.
[*] Fixed date: a date from the date picker. Does not reset.

The period anchors are read as prices from a higher-timeframe request rather than counted back as bars, so there is no history-buffer limit on how far back an anchor can sit.

Beta and the residual

Beta is the ordinary least squares slope of the name's bar returns against NQ's, fitted on the bars before the one being scored so a bar cannot explain itself away, over a window of four anchor periods on the chart's own bars (four sessions for a session anchor, four months for a month anchor, four times the span for a swing or a date; floor 60 bars, cap 2000). Sizing the window from the anchor keeps beta fitted at the horizon it is subtracted over. The table shows the bars in use.

The residual is scored in standard deviations of where it could have drifted by chance by this point in the period: per-bar residual noise times the square root of bars since the anchor. Early in a period it takes less to clear the threshold and late in a period it takes more, rather than one yardstick set by the period's average size. The sigma is measured on the name's own per-bar residual, so 1.0 means the same thing for a stock as for an index even though the stock moves several times as far.

Until the beta window has filled there is no beta and no reading, and the table says so: a recent listing with fewer bars than the window shows n/a and the bar count against the window, because a name that cannot be measured is not a weak name.

Confirmed leads

Beating a beta while merely quiet is a read that inverts by regime: in a panic the names that have not yet fallen can be the best shorts, not the best buys. So a lead is confirmed only when the name is also at a period high NQ has not made, the upside leg, which is the half of the read that holds in both regimes. An unconfirmed lead is not nothing; it is a sign whose direction you cannot yet read. There is no mirror on the lag side.

Regime profile

NQ's own state against its beta to ES is tracked the same way, and the table shows what the name's residual has averaged while NQ was leading its beta and while NQ was lagging it, over about the last 50 qualifying bars of each. A wide gap says the name rides megacap leadership and NQ's state matters to it; two similar numbers say it trades on its own.

NQ source

Futures (NQ1!, with ES1! for the NQ regime) intraday, where the cash index has no overnight bars; the cash index (NDX, with SPX) on daily and above, where a long anchor would otherwise carry the futures' roll gaps. Auto chooses by timeframe; the Ref cell says which is in use.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © matt_spinola

// version v1.0.0, 2026-09-15
// The chart-symbol read that lived inside Index Lead Lag [BMT] through v2.2.0, as its own
// overlay. The anchor block (Measure, the period-open reads, RTH open, the swing extremes,
// Fixed date, the anchor-sized beta window) is copied from index_lead_lag.pine v2.3.0 rather
// than shared through a library, so the two scripts carry no version dependency; when the
// anchor logic changes there, change it here in the same commit. Publish text in
// symbol_vs_nq.publish.md.

//@version=6
indicator("Symbol vs NQ [BMT]", shorttitle="Sym vs NQ [BMT]", overlay=true, max_bars_back=5000, max_labels_count=500, max_boxes_count=500)

// Is the chart symbol adding something of its own beyond how much more it moves than
// the Nasdaq does, and does it need megacap leadership to work?
//
// The name's move from a shared anchor, minus its beta to NQ times NQ's move from the
// same anchor, is the residual. Above zero the name is beating the path its beta
// implies; below zero it is rising less than its beta alone would have delivered. The
// residual is scored in standard deviations of where it could have drifted by chance
// by this point in the period, and the chart is tinted by that state. A lead is
// CONFIRMED when the name is also at a period high NQ has not made, which is the one
// leg of the read that does not flip sign by regime.
//
// Benchmarked to NQ rather than ES on purpose: if the question is how a name relates to
// Nasdaq leadership, NQ is the right denominator, and for a Nasdaq name it is the right
// benchmark regardless. NQ's own state against ES is kept only for the conditional
// profile, which is what answers "does this name need NQ to be leading".
//
// Why this is not part of Index Lead Lag: that pane asks which of four indexes leads,
// against ES, on one scale. This asks a different question, against a different
// benchmark, and a single name's residual runs an order of magnitude wider than an
// index's, which is why it never fitted on the pane. On the price chart the scale
// problem disappears and the tint sits where it belongs.

// --------------------- Inputs { ----------------------------- \\
var g_ref = "Reference"
measureInput = input.string("Auto", "Measure", group=g_ref,
     options=["Auto", "Session open", "RTH open", "Prior close", "Week open", "Month open", "Quarter open", "NQ swing low", "NQ swing high", "Fixed date"],
     tooltip="Percent change from a shared anchor.\nAuto: picks one from the chart timeframe, so you are not resetting this every time you switch charts. Under an hour it uses the session open; intraday above that, the week; on a daily chart, the month; higher, the quarter. The Ref cell shows what it resolved to.\nSession open: the open of the current daily bar. On CME index futures that is the 18:00 ET Globex open, so the overnight is inside the measure.\nRTH open: the open of the first bar of the cash session (09:30 ET by default), so it reads as who is leading today's cash tape with the overnight left out. Overnight bars measure from the last cash open; on a daily or higher chart it is the same as Session open.\nPrior close: the prior daily bar's close. On futures that is the 17:00 ET settlement, one maintenance hour before Session open; on a stock the gap between this and Session open is the overnight move.\nWeek open / Month open / Quarter open: the open of the current week, month or quarter. Each resets on that boundary, so the pane reads as leadership within the period to date.\nNQ swing low / high: the lowest low or highest high NQ has printed in the range you are looking at. The name is measured from that same bar, so it reads as 'since the Nasdaq turned, has this name done more than its beta?'. NQ rather than the name's own low on purpose: a name measured from its own low is at its minimum there by construction, which flatters every residual. Pan or zoom and it re-resolves to the new view. The vertical line marks where it sits.\nFixed date: the date picked below. Does not reset.")
// Auto resolves against the chart's own timeframe. The useful window is roughly a few
// dozen bars: a session open on a 4h chart is six bars and says nothing, while a
// session open on a 1m chart is a full day of them. So the anchor scales with the bar.
//
// The active= gating on the inputs below deliberately reads measureInput, not this.
// `active` demands an "input bool": timeframe.in_seconds() is simple, so anything
// derived from it is too, and `or`/`and` degrade even two input bools to simple. That
// rules out both the resolved value and any compound test.
//
// It costs nothing here. Auto only ever resolves to a period open, so under Auto none
// of the sub-controls apply and greying all of them is the right answer anyway.
int chartSeconds = timeframe.in_seconds()
string autoMeasure = chartSeconds < 3600 ? "Session open" : chartSeconds < 86400 ? "Week open" : chartSeconds == 86400 ? "Month open" : "Quarter open"
string activeMeasure = measureInput == "Auto" ? autoMeasure : measureInput
sourceInput = input.string("Auto", "NQ source", group=g_ref, options=["Auto", "Futures", "Cash index"],
     tooltip="Futures: NQ1! (and ES1! for the NQ regime), the back-adjusted continuous contracts. Right intraday, where the cash index has no overnight bars, but back-adjustment shifts the series by its roll gaps, so over many months its percent change drifts a few points from the cash index.\nCash index: NDX (and SPX). Exact over any horizon, but only trades the cash session, so intraday charts lose the overnight.\nAuto: futures on intraday charts, cash on daily and above. The Ref cell says which is in use.\n\nThe same choice as Index Lead Lag's Index source, so the two scripts read the same series when both are on the chart.")
rthSessionInput = input.session("0930-1600", "RTH session", group=g_ref, active=measureInput == "RTH open",
     tooltip="Used by the RTH open measure: the cash session, in New York time. The anchor is the open of the first chart bar inside it each day.")
int startBar = input.time(timestamp("2026-01-01"), "Fixed date anchor", group=g_ref, active=measureInput == "Fixed date",
     tooltip="Used only when Measure is Fixed date. Set with the date and time picker. A date before the loaded history anchors at the first bar loaded, and the Ref cell marks it with !.")
// A date picker, not click-a-bar: click-a-bar means confirm=true, which makes TradingView
// demand a bar selection every single time the indicator is added, for a field the
// default settings never read.

var g_disp = "Display"
chartTintInput = input.bool(true, title="Tint chart", group=g_disp,
     tooltip="Paints the price chart's background green while the chart symbol sits above the path its NQ-beta implies by more than the threshold, and red while it sits below it by more than that. The test is on the gap between the name's move and beta x NQ's move, not on the beta itself.\n\nIt answers \"is this name outperforming the Nasdaq after allowing for how much more it moves than the Nasdaq does?\" Green stretches are the name adding something of its own; red stretches are it rising less than its beta alone would have delivered.\n\nA STRONGER green marks a confirmed lead: the name at a period high NQ has not made. Beating its beta while quiet is a read that inverts in a panic (in September 2008 the names that had not yet fallen were the best shorts), so the faint green is a state whose sign you do not know, and the strong green is the one that held in both regimes.\n\nNeutral is left untinted on purpose: otherwise the chart is always coloured and none of it means anything.")
threshInput = input.float(1.0, title="Threshold (σ)", group=g_disp, minval=0.0, maxval=4.0, step=0.25,
     tooltip="How far the name has to sit from the path beta x NQ implies, in standard deviations of where it could have drifted by chance by this point in the period, before the tint and the table call it leading or lagging. Green also needs four consecutive bars above it before it paints, and drops as soon as the residual is back at zero; red is immediate.\n\nThe sigma is measured on the name's own per-bar residual, so 1.0 means the same thing for a stock as it does for NQ even though the stock moves several times as far. Lower it and the tint fills in more of the chart, but under pure chance 0.5 already colours about six bars in ten. Raise it to keep only the runs that stand out.")
markerSizeInput = input.string("tiny", title="Confirmed lead marker", group=g_disp, options=["off", "tiny", "small", "normal", "large"],
     tooltip="Off, or a green triangle at one of four sizes under each bar where the lead is confirmed: the name beating its NQ-beta AND at a period high NQ has not made. Hover one for the reading. The tint carries the same state as its stronger green; the marker is for when the tint is off, or when you want the exact bars.")
// Two glyphs make one ladder. The label triangle SHAPE bottoms out well above the ▴
// character (its tiny sat on the bars), so the first three steps are the character at
// size.small, normal and large (at size.tiny it is a dot) and only the last is the
// shape, at its smallest. Adjacent steps are close enough to read as one scale.
bool showMarkers = markerSizeInput != "off"
bool markerIsShape = markerSizeInput == "large"
markerSize = switch markerSizeInput
    "small"  => size.normal
    "normal" => size.large
    "large"  => size.tiny
    => size.small
alphaBoxInput = input.bool(false, title="Box alpha days", group=g_disp,
     tooltip="Outlines the days the stock produced alpha of its own: green for outperformance against beta x NQ, red for underperformance, beyond what its daily noise could explain.\n\nAgainst beta x NQ, not against NQ: a beta-2 name on a day NQ rises 1% is expected to rise 2%, and rising 1.5% is a red-box candidate even though it beat the index. Beyond what noise could explain means two standard deviations of the stock's own daily swings, so a quiet name earns a box on a small move and a wild one needs a big move, and a box means the same thing on any name.\n\nThe tint adds these days up since the anchor and smooths them over, so one huge day inside a lagging stretch, or a bad day inside a leading one, shows up nowhere else. Hover the bar and read Bar alpha in the data window for the size.")
tableLocationInput = input.string("Hidden", title="Status table", group=g_disp,
     options=["Hidden", "Top left", "Middle left", "Bottom left", "Top right", "Middle right", "Bottom right"])
bool showTableInput = tableLocationInput != "Hidden"
tablePosition = switch tableLocationInput
    "Top left"     => position.top_left
    "Middle left"  => position.middle_left
    "Bottom left"  => position.bottom_left
    "Top right"    => position.top_right
    "Middle right" => position.middle_right
    => position.bottom_right
tableFontSizeInput = input.string("small", title="Table font size", group=g_disp, options=["tiny", "small", "auto", "large", "very large"])
tableFontSizeOption = switch tableFontSizeInput
    "tiny"       => size.tiny
    "small"      => size.small
    "auto"       => size.auto
    "large"      => size.large
    "very large" => size.huge
// No active= on the font picker: gated on the table it showed as permanently disabled
// in the settings dialog, and a picker that does nothing while the table is hidden
// costs nothing enabled.
// The persistence count below is a constant rather than an input, after CARS.
bool usesDate = activeMeasure == "Fixed date"
bool usesSwingLow = activeMeasure == "NQ swing low"
bool usesSwingHigh = activeMeasure == "NQ swing high"
bool usesSwing = usesSwingLow or usesSwingHigh
bool usesRth = activeMeasure == "RTH open"
//}

// --------------------- Fixed-date anchor { ----------------------------- \\
// Only Fixed date needs a bar offset, so it is the only measure that can run past the
// history buffer. First bar at or after the anchor: if the date predates the loaded
// history this lands on bar 0 rather than never resolving.
getBarIndexSinceTime(t) =>
    var int foundBar = na
    if na(foundBar) and time >= t
        foundBar := bar_index
    foundBar

// input.time defaults have to be constants, so the literal date below goes stale. There
// used to be an "anchor at current session" checkbox to make the stale default usable,
// but that only restated Session open (one bar worse: the first bar's close rather than
// the daily open), so Fixed date now means the date, and a stale date lands on bar 0.

// Hoisted out of the conditions below on purpose. v6 short-circuits or, so
// "na(dayStartBar) or ta.change(...)" would skip ta.change on the first bar, and a
// ta.* call that does not run every bar loses its history.
bool newDay = ta.change(time("D")) != 0
bool newWeek = ta.change(time("W")) != 0
bool newMonth = ta.change(time("M")) != 0
bool newQuarter = ta.change(time("3M")) != 0

var int dayStartBar = na
var int weekStartBar = na
var int monthStartBar = na
var int quarterStartBar = na
// A short ring of session starts, for the session length the beta window needs.
var array<int> dayStarts = array.new_int(0)
if na(dayStartBar) or newDay
    dayStartBar := bar_index
    dayStarts.unshift(bar_index)
    if dayStarts.size() > 6
        dayStarts.pop()
// The length of the last completed week, month and quarter in bars, for the beta
// window below. Taken on the chart's own bars rather than assumed from the timeframe,
// so a weekly chart's quarter is 13 and a 5m chart's is a few thousand.
var int weekLen = na
var int monthLen = na
var int quarterLen = na
if na(weekStartBar) or newWeek
    weekLen := na(weekStartBar) ? na : bar_index - weekStartBar
    weekStartBar := bar_index
if na(monthStartBar) or newMonth
    monthLen := na(monthStartBar) ? na : bar_index - monthStartBar
    monthStartBar := bar_index
if na(quarterStartBar) or newQuarter
    quarterLen := na(quarterStartBar) ? na : bar_index - quarterStartBar
    quarterStartBar := bar_index

int MAX_LOOKBACK = 4900

// Called unconditionally, not inside the ternary below. getBarIndexSinceTime holds a
// var that latches the first bar at or after the anchor date, and a function carrying
// var state has to run on every bar to latch correctly; burying it in a branch is the
// same trap as putting a ta.* call inside an if.
int fixedAnchorBar = getBarIndexSinceTime(startBar)
int offsetBarIndex = fixedAnchorBar
//}

// --------------------- Data { ----------------------------- \\
// NQ is the benchmark, and the swing anchors are NQ's extremes: the question is what the
// name did since the Nasdaq turned, and anchoring on the name's own low would put it at
// its minimum by construction. ES is here for one thing only, NQ's own state against
// it, which the conditional profile needs.
bool useCash = sourceInput == "Cash index" or (sourceInput == "Auto" and not timeframe.isintraday)
string NQ_SYM = useCash ? "NASDAQ:NDX" : "NQ1!"
string ES_SYM = useCash ? "SP:SPX"     : "ES1!"

f_dayData(string sym) =>
    request.security(sym, "D", [open, close[1]], lookahead=barmerge.lookahead_on)

f_periodOpen(string sym, string tf) =>
    request.security(sym, tf, open, lookahead=barmerge.lookahead_on)

// lookahead ON for a same-timeframe request, deliberately. The cash indexes' daily
// bars close after a stock's (NDX is calculated to 17:16 ET, a stock's bar ends at
// 16:00), and TradingView merges bars by close time, so with lookahead off a daily
// stock chart received the index's PREVIOUS day on every historical bar: measured
// 2026-09-15 on DELL, where "NQ move" on 4 Sep was NDX's 3 Sep figure, and the
// chart symbol's beta to NQ came out at -0.05 against a true 1.8. On the same
// timeframe lookahead on is the bar's own close, nothing from the future, and the
// realtime bar is the developing value either way.
[nqClose, nqHigh, nqLow, nqOpen] = request.security(NQ_SYM, timeframe.period, [close, high, low, open], lookahead=barmerge.lookahead_on)
[esClose, esOpen] = request.security(ES_SYM, timeframe.period, [close, open], lookahead=barmerge.lookahead_on)

// RTH open: the open of the first chart bar inside the cash session, held through the
// overnight so a bar at 03:00 measures from the last cash open rather than from
// nothing. Intraday only; on a daily or higher chart the measure falls back to the
// daily open.
bool inRth = timeframe.isintraday and not na(time(timeframe.period, rthSessionInput, "America/New_York"))
bool rthStart = inRth and not inRth[1]
var float nqRthOpen  = na
var float esRthOpen  = na
var float symRthOpen = na
var int   rthStartBar = na
if rthStart
    nqRthOpen   := nqOpen
    esRthOpen   := esOpen
    symRthOpen  := open
    rthStartBar := bar_index

[nqDayOpen,  nqPrevClose]  = f_dayData(NQ_SYM)
[esDayOpen,  esPrevClose]  = f_dayData(ES_SYM)
[symDayOpen, symPrevClose] = f_dayData(syminfo.tickerid)

nqWeekOpen   = f_periodOpen(NQ_SYM, "W")
esWeekOpen   = f_periodOpen(ES_SYM, "W")
symWeekOpen  = f_periodOpen(syminfo.tickerid, "W")
nqMonthOpen  = f_periodOpen(NQ_SYM, "M")
esMonthOpen  = f_periodOpen(ES_SYM, "M")
symMonthOpen = f_periodOpen(syminfo.tickerid, "M")
nqQtrOpen    = f_periodOpen(NQ_SYM, "3M")
esQtrOpen    = f_periodOpen(ES_SYM, "3M")
symQtrOpen   = f_periodOpen(syminfo.tickerid, "3M")

// The extreme of what you are actually looking at, rather than a pivot you have to
// tune. Referencing chart.left_visible_bar_time makes TradingView recalculate the whole
// script whenever you pan or zoom, which is what keeps the anchor in step with the view.
//
// Running rather than final: at any bar the anchor is the most extreme NQ print since
// the left edge up to THAT bar, so the series reads as "how far from the running
// extreme are we". At the right edge that is the visible extreme, which is the number
// you are actually looking for.
//
// This also removes the confirmation lag. A pivot could not be known until its right
// bars had printed, so the marker sat to the right of the low it described; a running
// extreme is known the moment it happens.
bool inView = not na(chart.left_visible_bar_time) and time >= chart.left_visible_bar_time
var float visExtreme = na
var int visExtremeBar = na
if inView and usesSwingLow and (na(visExtreme) or nqLow < visExtreme)
    visExtreme := nqLow
    visExtremeBar := bar_index
if inView and usesSwingHigh and (na(visExtreme) or nqHigh > visExtreme)
    visExtreme := nqHigh
    visExtremeBar := bar_index

int swingOffset = na(visExtremeBar) ? na : bar_index - visExtremeBar
int rawLookback = usesDate ? bar_index - offsetBarIndex : usesSwing ? swingOffset : na
int lookback = na(rawLookback) ? na : math.min(math.max(rawLookback, 1), MAX_LOOKBACK)
bool lookbackCapped = usesDate and not na(rawLookback) and rawLookback > MAX_LOOKBACK

// The offset close for the bar-counted measures. Taken at top level so the history operator applies
// to a real series rather than a function parameter.
float nqOffsetClose  = na(lookback) ? na : nqClose[lookback]
float esOffsetClose  = na(lookback) ? na : esClose[lookback]
float symOffsetClose = na(lookback) ? na : close[lookback]

f_anchor(float dayOpen, float rthOpen, float prevClose, float weekOpen, float monthOpen, float qtrOpen, float offsetClose) =>
    activeMeasure == "Session open" ? dayOpen : usesRth ? (timeframe.isintraday ? rthOpen : dayOpen) : activeMeasure == "Prior close" ? prevClose : activeMeasure == "Week open" ? weekOpen : activeMeasure == "Month open" ? monthOpen : activeMeasure == "Quarter open" ? qtrOpen : offsetClose

f_pct(float c, float anchor) =>
    na(anchor) or anchor == 0 ? na : (c - anchor) / anchor * 100

float nqRaw  = f_pct(nqClose, f_anchor(nqDayOpen,  nqRthOpen,  nqPrevClose,  nqWeekOpen,  nqMonthOpen,  nqQtrOpen,  nqOffsetClose))
float esRaw  = f_pct(esClose, f_anchor(esDayOpen,  esRthOpen,  esPrevClose,  esWeekOpen,  esMonthOpen,  esQtrOpen,  esOffsetClose))
float symRaw = f_pct(close,   f_anchor(symDayOpen, symRthOpen, symPrevClose, symWeekOpen, symMonthOpen, symQtrOpen, symOffsetClose))

// Where the measurement starts, for every measure and not just the bar-counted ones.
// The period anchors are read as prices, so their bar has to be recovered separately
// from the session, week, month and quarter trackers.
int anchorBar = switch
    activeMeasure == "Session open" => dayStartBar
    usesRth                         => timeframe.isintraday ? rthStartBar : dayStartBar
    activeMeasure == "Prior close"  => na(dayStartBar) ? na : dayStartBar - 1
    activeMeasure == "Week open"    => weekStartBar
    activeMeasure == "Month open"   => monthStartBar
    activeMeasure == "Quarter open" => quarterStartBar
    => na(lookback) ? na : bar_index - lookback

// Bars elapsed since it. Floored at 1: on the anchor bar itself the residual is
// zero anyway, and a zero scale would divide by zero rather than read as neutral.
int barsSinceAnchor = na(anchorBar) ? na : math.max(bar_index - anchorBar, 1)

// The beta window, sized from the anchor rather than set by hand (copied from Index
// Lead Lag, where it replaced a fixed 90-bar input). A fixed 90 bars was
// a few hours on a 5m chart and four months on a daily one, and on a long anchor the
// beta's own estimation error, times the size of the ES move, swamped the residual.
// So the window is a fixed number of ANCHOR PERIODS: four sessions for a session
// anchor, four months for a month anchor, four times the span for a swing or a date.
// Beta is then always fitted at the horizon it is subtracted over, and the estimate
// tightens as the anchor lengthens instead of staying at 90 while the move it scales
// grows.
//
// Four periods, because on a daily chart with the month anchor that is 84 bars, the
// same neighbourhood as the 90 this replaces; the standard error of an OLS beta falls
// with the square root of the sample, so more periods buy little and cost history.
// The floor keeps a thin OLS honest where a period is a handful of bars (a daily
// chart on a session anchor, a weekly chart on the quarter); the cap keeps a 1m chart
// inside the history buffer (max_bars_back 5000), at a session and a half there.
//
// It does NOT make the residual trustworthy over a long anchor. A wider window shrinks
// the estimation error; it cannot fix a beta that has itself drifted over the year.
// Over anchors months back, read the raw move against NQ's raw move instead.
//
// Session length is the mean of the last five completed sessions from the day-start
// ring, so one holiday half-day moves the window by a tenth rather than halving it.
float sessionBars = dayStarts.size() > 5 ? (dayStarts.get(0) - dayStarts.get(5)) / 5.0 : 1.0
float spanBars = na(anchorBar) ? sessionBars : math.max(last_bar_index - anchorBar, sessionBars)
float periodBars = switch
    activeMeasure == "Week open"    => na(weekLen)    ? 5  * sessionBars : weekLen
    activeMeasure == "Month open"   => na(monthLen)   ? 21 * sessionBars : monthLen
    activeMeasure == "Quarter open" => na(quarterLen) ? 63 * sessionBars : quarterLen
    usesSwing                       => spanBars
    usesDate                        => spanBars
    => sessionBars
int BETA_PERIODS = 4
int betaLen = math.min(math.max(math.round(BETA_PERIODS * periodBars), 60), 2000)
//}

// --------------------- Beta and residual { ----------------------------- \\
// Ordinary least squares slope, written out as moments so
// both sides stay in one convention: the 1/n cancels in cov/var, leaving the slope.
//
// Fitted on the PRECEDING window, both series lagged a bar. A beta fitted on a window
// that contains the bar it scores leaks that bar into its own benchmark, and the
// residual then reads smaller than it was. At 90 bars that is about 1% of the fit, but
// it biases exactly the outliers the sigma test exists to catch: a genuine outlier
// drags its own beta toward itself and partly explains itself away. Same offset, and
// same reasoning, as the beta in agi/indicators/cars.pine and in Index Lead Lag.
f_beta(float rx, float rm, int len) =>
    float x = rx[1]
    float m = rm[1]
    float mx = ta.sma(m, len)
    float my = ta.sma(x, len)
    float cov = ta.sma(m * x, len) - mx * my
    float vr  = ta.sma(m * m, len) - mx * mx
    na(vr) or vr == 0 ? na : cov / vr

float nqRet  = na(nqClose[1]) or nqClose[1] == 0 ? na : nqClose / nqClose[1] - 1
float esRet  = na(esClose[1]) or esClose[1] == 0 ? na : esClose / esClose[1] - 1
float symRet = na(close[1])   or close[1]   == 0 ? na : close / close[1] - 1

// The name against NQ, and NQ against ES. The second exists only for the regime the
// profile conditions on.
float symBeta = f_beta(symRet, nqRet, betaLen)
float nqBeta  = f_beta(nqRet,  esRet, betaLen)
float symResidual = na(symBeta) or na(symRaw) or na(nqRaw) ? na : symRaw - symBeta * nqRaw
float nqResidual  = na(nqBeta)  or na(nqRaw)  or na(esRaw) ? na : nqRaw  - nqBeta  * esRaw

// Scored in standard deviations rather than tested against zero, because without that the
// condition is true on any bar the name sits a hair under its beta path, which is most
// of them, and the tint ran in long unbroken stretches carrying no information.
//
// But NOT in standard deviations of the anchored residual's own distribution, which is
// what this used to do. That quantity resets at every anchor and grows through the
// period, so pooling it into one stdev sets the yardstick to the period's AVERAGE
// size. On a 5m chart with a session anchor, mean k is about 39 of 78 bars, so a
// nominal 1.0 sigma was really a 2.8 sigma test in the first half hour and a 0.71
// sigma test in the last. Nothing fired at the open and the markers piled up at the
// right edge of every session.
//
// The anchored residual is a running sum of per-bar residuals. Under the null (no
// persistent lead or lag) that sum is a driftless random walk, whose spread at step k
// is sigma_bar * sqrt(k). Dividing by THAT makes the threshold mean one thing at every
// point in the period. It also generalises to all nine measures: slot-matching against
// the same bar of prior sessions would handle the intraday volatility smile too, but
// only the session anchor repeats, and the swing anchors, where k runs from three
// bars to three hundred and the bias is worst, have no slots at all.
//
// sigma_bar is measured on the ONE-BAR residual, which is stationary and so can be
// pooled honestly. The anchored one could not.
//
// ⚠️ sqrt(k) assumes the per-bar residuals are independent. They are not (persistent
// leadership is this script's whole premise), so true dispersion grows somewhat faster
// than sqrt(k) and this still under-corrects late in a period. By a little, not by 4x.
//
// ⚠️ In PERCENT. f_pct multiplies by 100, so symResidual is a percentage; the returns
// are fractions, because beta is a ratio and the units cancel inside f_beta. They do
// NOT cancel here: the numerator and the scale have to be in the same unit, and
// mixing them inflates every z by exactly 100x, which puts the threshold below the
// noise floor and marks every bar.
float symBarResid = na(symBeta) or na(symRet) or na(nqRet) ? na : (symRet - symBeta * nqRet) * 100
float symBarSigma = ta.stdev(symBarResid, betaLen)
float symScale = na(symBarSigma) or na(barsSinceAnchor) ? na : symBarSigma * math.sqrt(barsSinceAnchor)
float symResidZUndamped = na(symScale) or symScale == 0 or na(symResidual) ? na : symResidual / symScale

// The 50-day damping term, after CARS: a positive score under the 50-day is
// discounted, a negative one never is (damping a negative reading would slow the
// off-switch, which inverts the one design goal stated outright). "Not a 50-day rule,
// but the 50-day enters it": SHOP was in CARS below both the 50 and the 200.
//
// Daily bars on every chart timeframe, so it means the same thing on a 5m chart as on
// a daily one, and the PRIOR session's value (close[1]-style, lookahead on) so it
// cannot repaint; against a 50-day average the one-day lag is a fiftieth of a day's
// move. Constants rather than inputs, and no switch: the 50 and the 0.7 are the
// reconstruction's, it defaults on, and the case for turning a discount off is thin;
// the data window carries the undamped σ for anyone checking.
int   DAMP_LEN = 50
float DAMP_FAC = 0.70
float dailyMa = request.security(syminfo.tickerid, "D", ta.sma(close, DAMP_LEN)[1], lookahead=barmerge.lookahead_on)
bool  damped = not na(symResidZUndamped) and symResidZUndamped > 0 and not na(dailyMa) and close < dailyMa
float symResidZ = damped ? symResidZUndamped * DAMP_FAC : symResidZUndamped
// The lead state takes the stairs up and the elevator down, after CARS. Green needs
// ON_BARS consecutive bars above the threshold before it paints ("after four to five
// days, if you saw consistent buying"), and drops the moment the residual is back at
// or under zero, not at minus the threshold. Lag has no such gate: turning off takes
// very little, and a name missing its beta is not a state that needs confirming.
//
// A constant, not an input. Four bars filters the one-bar flicker on any timeframe,
// and the sqrt(k) scaling already handles the early-period noise this is not for.
// The residual resets to zero at every anchor, so the state resets with it.
int ON_BARS = 4
var bool leadOn = false
var int  leadRun = 0
if na(symResidZ)
    leadOn := false
    leadRun := 0
else if leadOn
    if symResidZ <= 0
        leadOn := false
        leadRun := 0
else
    leadRun := symResidZ > threshInput ? leadRun + 1 : 0
    if leadRun >= ON_BARS
        leadOn := true
        leadRun := 0
bool symLead = leadOn
bool symLag  = not na(symResidZ) and symResidZ < -threshInput

// Measurable at all. f_beta is na until the window fills, and a young listing with
// fewer bars than the window is NOT a laggard, it is unmeasured (U-29a's defect: a
// screen that omits recent IPOs reads them as weak). The table says which.
bool measurable = not na(symBeta)

// NQ's own state against its ES beta, the same test, for the profile.
float nqBarResid = na(nqBeta) or na(nqRet) or na(esRet) ? na : (nqRet - nqBeta * esRet) * 100
float nqBarSigma = ta.stdev(nqBarResid, betaLen)
float nqScale = na(nqBarSigma) or na(barsSinceAnchor) ? na : nqBarSigma * math.sqrt(barsSinceAnchor)
float nqResidZ = na(nqScale) or nqScale == 0 or na(nqResidual) ? na : nqResidual / nqScale
bool nqLead = not na(nqResidZ) and nqResidZ >  threshInput
bool nqLag  = not na(nqResidZ) and nqResidZ < -threshInput

// M-51's discriminator, and the one leg of a leadership read that does NOT flip sign by
// regime. "Down less than NQ" on its own is the quiet leg, and in a panic it inverts: in
// September 2008 the not-yet-fallen cohort was the best SHORT list, not the best buy list:
// "quiet there wasn't necessarily something you wanted to buy ... that's why you also
// need the upside to follow through" (agi rules/agi_rules.yaml, M-51's 2026-09-09
// refinement and its 2008 counter-example).
//
// So confirmation is the upside leg: the name at a period high the index has not made.
//
// Deliberately a SEPARATE state rather than folded into symLead. An unconfirmed lead is
// still information; it is information whose sign you do not know, which is the whole
// content of the rule, and one merged state would hide exactly that.
//
// No mirror on the lag side. The rule is about the not-yet-fallen cohort specifically;
// inventing the short-side symmetry would be going past what the source says.
//
// ta.highest takes a series length, so one window covers every anchor:
// rolling for the swing extremes, fixed for the period opens and the date.
int confirmLen = na(barsSinceAnchor) ? 1 : math.min(barsSinceAnchor, 4999)
float symPeriodHigh = ta.highest(close, confirmLen)
float nqPeriodHigh  = ta.highest(nqClose, confirmLen)
bool symConfirmed = symLead and not na(barsSinceAnchor) and close >= symPeriodHigh and nqClose < nqPeriodHigh

// Conditional profile: what the symbol has averaged while NQ was leading its own beta,
// versus while NQ was lagging it. A wide gap says the name rides megacap leadership;
// two similar numbers say it trades on its own and the index regime tells you nothing
// about it.
//
// A running mean with the step capped, so early samples settle quickly and it then
// behaves like an EMA over roughly the last PROFILE_N qualifying bars; a plain
// cumulative average would be dominated by whatever regime the chart happens to start in.
int PROFILE_N = 50
var float symAvgOnNqLead = na
var float symAvgOnNqLag  = na
var int   symCntOnNqLead = 0
var int   symCntOnNqLag  = 0
if not na(symResidual) and nqLead
    symCntOnNqLead += 1
    symAvgOnNqLead := na(symAvgOnNqLead) ? symResidual : symAvgOnNqLead + (symResidual - symAvgOnNqLead) / math.min(symCntOnNqLead, PROFILE_N)
if not na(symResidual) and nqLag
    symCntOnNqLag += 1
    symAvgOnNqLag := na(symAvgOnNqLag) ? symResidual : symAvgOnNqLag + (symResidual - symAvgOnNqLag) / math.min(symCntOnNqLag, PROFILE_N)
//}

// --------------------- Colours { ----------------------------- \\
chartLuma = 0.2126 * color.r(chart.bg_color) + 0.7152 * color.g(chart.bg_color) + 0.0722 * color.b(chart.bg_color)
bool isDark = chartLuma <= 128

// Over the candles rather than in the pane, so these follow the chart theme's rule for
// a background zone: ~12 luma off the canvas, and the two matched on luma rather than
// on transparency, since green and red need different alphas to feel equal.
tintLead = color.new(isDark ? #5BC08A : #1E8355, isDark ? 92 : 92)
tintLag  = color.new(isDark ? #DE7078 : #B03B42, isDark ? 89 : 93)
// Confirmed lead: the same green, about twice as far off the canvas (21 rather than 11).
// That breaks the theme's usual ~12 for a background zone on purpose: this is the state
// the rule says you can act on, and the faint one is the state whose sign is unknown.
tintConfirm = color.new(isDark ? #5BC08A : #1E8355, isDark ? 85 : 86)

// Marker and table greens and reds. Green is set well brighter than red (167 against
// 136 raw) because hue is the only thing separating lead from lag and red-green is the
// axis that collapses for colour deficiency; the pair survives in greyscale.
calmColor = isDark ? #5BC08A : #1E8355   // lead,  luma 167 dark / 106 light
warnColor = isDark ? #DE7078 : #B03B42   // lag,   luma 136 dark /  84 light
tblDimColor = isDark ? #C3CAD6 : #3F444B
tblNqColor  = isDark ? #55C1DE : #1191A5
tblBgColor  = isDark ? color.new(#0A0C10, 20) : color.new(#FFFFFF, 10)
// The anchor marker, the same blue as Index Lead Lag's so the two read as one line
// when both are on the chart. Earlier anchors are ticks on the bottom edge in the same
// blue, beside the exchange's own event markers. Two attempts on the candles failed: a
// dotted rule was too bright over bare bars and invisible inside a tinted stretch, and
// the pane's one-bar band is a solid column on a daily chart, where a bar is wide, and
// made the anchor line one blue vertical among many. Off the candles, the line is the
// only vertical and reads as the anchor on its own.
anchorColor = color.new(isDark ? #4A72AE : #2F5FA8, 10)
resetColor  = color.new(isDark ? #4A72AE : #2F5FA8, 30)
//}

// --------------------- Drawing { ----------------------------- \\
// Green while the name is beating the path its NQ-beta implies by more than the
// threshold (with the persistence gate above), red while it is missing it, nothing
// between: a chart that is always coloured means nothing. The stronger green is the
// confirmed lead. Faint on purpose, about 12 luma off the canvas, matched on luma
// rather than transparency so neither side reads stronger.
color chartTint = not chartTintInput ? na : symConfirmed ? tintConfirm : symLead ? tintLead : symLag ? tintLag : na

bgcolor(chartTint, title="Symbol vs NQ-beta")

// The bars that WERE anchors: each session, week, month or quarter open as the measure
// dictates, or the swing extreme, as a tick on the bottom edge. Fixed date is excluded:
// it has exactly one anchor, and the solid line below marks it.
bool markBar = usesSwing ? (not na(visExtremeBar) and visExtremeBar == bar_index) : usesDate ? false : activeMeasure == "Quarter open" ? newQuarter : activeMeasure == "Month open" ? newMonth : activeMeasure == "Week open" ? newWeek : usesRth and timeframe.isintraday ? rthStart : newDay
plotshape(markBar, title="Anchor resets", style=shape.square, location=location.bottom, color=resetColor, size=size.tiny)

// Confirmed leads as labels rather than plotshape, so each carries a hover reading.
// Marker size picks the glyph as well as the size; see the input.
// Drawn as the bars are processed, only inside the visible range (referencing
// chart.left_visible_bar_time re-runs the script on every scroll and zoom), and past
// max_labels_count Pine drops the oldest first.
f_sigma(float z) =>
    na(z) ? "" : ", " + (z > 0 ? "+" : "") + str.tostring(z, "0.0") + "σ"
bool labelInView = not na(chart.left_visible_bar_time) and time >= chart.left_visible_bar_time and time <= chart.right_visible_bar_time
// The shape is anchored at its tip, so at yloc.belowbar it touches the low; it gets
// an explicit gap of a third of an ATR under the bar instead. The character is not
// anchored that way and sits clear on its own.
float markerGap = ta.atr(14) * 0.35
if showMarkers and symConfirmed and labelInView
    label.new(bar_index, markerIsShape ? low - markerGap : low, markerIsShape ? "" : "▴", style=markerIsShape ? label.style_triangleup : label.style_none, yloc=markerIsShape ? yloc.price : yloc.belowbar, color=calmColor, textcolor=calmColor, size=markerSize,
         tooltip=syminfo.ticker + " leading its NQ-beta, confirmed" + f_sigma(symResidZ) + "\nAt a period high NQ has not made: the upside leg that holds in both regimes.")

// Alpha days: the one-bar residual against its own noise, boxed. The box is drawn for
// the PREVIOUS bar, once both its neighbours' times are known, so its edges sit at the
// midpoints to the bars either side: with bar_time TradingView places a time between
// two bars proportionally, so a midpoint of times is a midpoint of positions whatever
// the gap (a Friday box does not narrow on its weekend side, which time + half a bar
// would do). The live bar gets a provisional box off its own duration instead. Only in
// view, and past max_boxes_count Pine drops the oldest first. No input for the 2σ;
// it is an outlier definition, not a tuning.
float ALPHA_BOX_SIGMA = 2.0
float barZ = na(symBarSigma) or symBarSigma == 0 or na(symBarResid) ? na : symBarResid / symBarSigma
bool alphaUp = not na(barZ) and barZ >=  ALPHA_BOX_SIGMA
bool alphaDn = not na(barZ) and barZ <= -ALPHA_BOX_SIGMA
if alphaBoxInput and labelInView
    if alphaUp[1] or alphaDn[1]
        box.new(math.round((time[2] + time[1]) / 2), high[1], math.round((time[1] + time) / 2), low[1], xloc=xloc.bar_time, border_color=alphaUp[1] ? calmColor : warnColor, bgcolor=na, border_width=1)
    if barstate.islast and (alphaUp or alphaDn)
        box.new(math.round((time[1] + time) / 2), high, time + math.round((time_close - time) / 2), low, xloc=xloc.bar_time, border_color=alphaUp ? calmColor : warnColor, bgcolor=na, border_width=1)

// The anchor bar. One vertical line, redrawn on the last bar because the swing and
// Fixed date anchors can move with the view.
var line anchorLine = na
if barstate.islast
    line.delete(anchorLine)
    anchorLine := na(anchorBar) or anchorBar < 0 ? na : line.new(anchorBar, low, anchorBar, high, xloc=xloc.bar_index, extend=extend.both, color=anchorColor, style=line.style_solid, width=2)

plot(symRaw,      title="Symbol move (%)",          precision=2, display=display.data_window)
plot(nqRaw,       title="NQ move (%)",              precision=2, display=display.data_window)
plot(symBeta,     title="Beta to NQ",               precision=2, display=display.data_window)
plot(symResidual, title="Residual vs NQ-beta",      precision=2, display=display.data_window)
plot(symResidZ,   title="Residual (σ)",             precision=2, display=display.status_line)
plot(symResidZUndamped, title="Residual undamped (σ)", precision=2, display=display.data_window)
plot(barZ,        title="Bar alpha (σ)",             precision=2, display=display.data_window)
plot(dailyMa,     title="50-day average (daily)",   precision=2, display=display.data_window)
plot(nqResidZ,    title="NQ residual vs ES (σ)",    precision=2, display=display.data_window)
plot(betaLen,     title="Beta window bars",         precision=0, display=display.data_window)
plot(symAvgOnNqLead, title="Avg residual when NQ leads", precision=2, display=display.data_window)
plot(symAvgOnNqLag,  title="Avg residual when NQ lags",  precision=2, display=display.data_window)
//}

// --------------------- Status table { ----------------------------- \\
// Laid out across, like Index Lead Lag's, so it sits as a strip along one edge of the
// price chart rather than on top of the candles.
var table symTable = table.new(tablePosition, 5, 3, border_width=1)

f_cell(int _col, int _row, string _text, color _txtcolor, string _tip = "") =>
    table.cell(symTable, _col, _row, _text, bgcolor=tblBgColor, text_color=_txtcolor, text_size=tableFontSizeOption, tooltip=_tip)

f_num(float v) =>
    na(v) ? "-" : str.tostring(v, "0.00")

if barstate.islast and showTableInput
    string symTip = "The chart symbol against NQ. Ticker, then its move from the " + activeMeasure + " anchor in percent, then its beta to NQ over the last " + str.tostring(betaLen) + " bars (four anchor periods).\n\nThe ticker turns green when the lead is CONFIRMED: the name at a period high NQ has not made. Beating its beta while merely quiet is a read that inverts by regime (in September 2008 the not-yet-fallen names were the best shorts), so the upside leg is the half that survives both; an unconfirmed lead is not nothing, it is a sign you cannot yet read."
    string residTip = measurable
         ? "Residual: the name's move minus beta x NQ's move over the same stretch, then that residual in standard deviations of where it could have drifted by chance by this point in the period (per-bar noise times the square root of bars since the anchor).\n\nZero means it moved exactly as its beta implies. Above the threshold is the name adding something of its own; below is it rising less than its beta alone would have delivered.\n\nGreen needs " + str.tostring(ON_BARS) + " consecutive bars above the threshold and drops the moment the residual is back at zero; red is immediate. Stairs up, elevator down." + (damped ? "\n\nDAMPED: the name is under its 50-day, so this positive reading is 70% of the undamped " + str.tostring(symResidZUndamped, "0.0") + "σ." : "")
         : "Not measurable yet: " + str.tostring(bar_index + 1) + " bars loaded against a beta window of " + str.tostring(betaLen) + ". A name that cannot be measured is not a weak name; wait for the window to fill, or use a smaller anchor period, which shrinks the window."
    string nqTip = "NQ's own move from the same anchor, and its state against ITS beta to ES: whether the Nasdaq is itself leading, lagging or near the move its beta to the S&P implies. Context for the profile cells."
    string profTip = "Regime profile: what this name's residual has averaged while NQ was LEADING its beta to ES, and while NQ was LAGGING it (about the last " + str.tostring(PROFILE_N) + " qualifying bars of each; the count is the bars seen).\n\nThat answers \"does this name need megacap leadership to work?\" A wide gap means it rides the regime and you should care what NQ is doing. Two similar numbers mean it trades on its own and NQ's state tells you nothing about it."
    string refTip = "The anchor both series are measured from: " + activeMeasure + ".\n\nSource: " + (useCash ? "cash index (NDX, with SPX for the NQ regime)" : "continuous futures (NQ1!, with ES1! for the NQ regime)") + ".\n\nThe vertical line marks the anchor bar. The period anchors are the same bars Index Lead Lag uses; the swing anchors are NQ's extremes where that script uses ES's."

    f_cell(0, 0, syminfo.ticker, symConfirmed ? calmColor : tblDimColor, symTip)
    f_cell(0, 1, f_num(symRaw), tblDimColor, symTip)
    f_cell(0, 2, measurable ? "β" + str.tostring(symBeta, "0.0") : str.tostring(bar_index + 1) + "/" + str.tostring(betaLen) + "b", tblDimColor, measurable ? symTip : residTip)

    color stateColor = symLead ? calmColor : symLag ? warnColor : tblDimColor
    f_cell(1, 0, "vs β", stateColor, residTip)
    f_cell(1, 1, measurable ? f_num(symResidual) : "n/a", stateColor, residTip)
    f_cell(1, 2, na(symResidZ) ? "" : (symResidZ > 0 ? "+" : "") + str.tostring(symResidZ, "0.0") + "σ", stateColor, residTip)

    f_cell(2, 0, "NQ", tblNqColor, nqTip)
    f_cell(2, 1, f_num(nqRaw), tblNqColor, nqTip)
    f_cell(2, 2, nqLead ? "leading" : nqLag ? "lagging" : "near β", nqLead ? calmColor : nqLag ? warnColor : tblDimColor, nqTip)

    f_cell(3, 0, "NQ lead / lag", tblDimColor, profTip)
    f_cell(3, 1, f_num(symAvgOnNqLead) + " / " + f_num(symAvgOnNqLag), tblDimColor, profTip)
    f_cell(3, 2, str.tostring(symCntOnNqLead) + "b / " + str.tostring(symCntOnNqLag) + "b", tblDimColor, profTip)

    // Short forms so this cell does not stretch the strip
    string autoTag = measureInput == "Auto" ? "~" : ""
    string refText = autoTag + (activeMeasure == "Session open" ? "Session" : usesRth ? (timeframe.isintraday ? "RTH" : "Session") : activeMeasure == "Prior close" ? "Prev cl" : activeMeasure == "Week open" ? "Week" : activeMeasure == "Month open" ? "Month" : activeMeasure == "Quarter open" ? "Quarter" : usesSwingLow ? "SwLo " + str.tostring(lookback) + "b" : usesSwingHigh ? "SwHi " + str.tostring(lookback) + "b" : "Date " + str.tostring(lookback) + "b" + (lookbackCapped ? "!" : ""))
    f_cell(4, 0, "Ref", tblDimColor, refTip)
    f_cell(4, 1, refText, tblDimColor, refTip)
    f_cell(4, 2, useCash ? "cash" : "futures", tblDimColor, refTip)
//}
````
