# Daily Volatility Breakout - Anchored Range Trigger and Time Exit

- url: https://www.tradingview.com/script/0xKHIzvA-Daily-Volatility-Breakout-Anchored-Range-Trigger-and-Time-Exit/
- type: indicator
- pine_id: PUB;41c8c1e5b04a4275a120fa14c95338fa
- version: 1.0

## Description

Daily Volatility Breakout marks one breakout per day. At a fixed UTC anchor time it measures how far price travelled over the look-back that just ended, puts a long trigger and a short trigger a fraction of that distance away from the anchor bar's open, and flags the first bar that closes beyond either one. For that signal it draws a reference stop and a reference time exit, and follows the reference trade until one of them is reached.

The question it answers: has today already moved further from its opening price than a meaningful share of yesterday's whole range, and in which direction?

[b]How the Levels Are Calculated[/b]

Anchor - every day at the configured UTC time (default 00:00). The anchor open is the open of the bar that starts exactly at that time.

Range - the highest high minus the lowest low of the completed bars in the look-back window that ends at the anchor (default: the prior 24 hours). If too few bars exist in that window, for example after a data gap, the day is skipped and the panel says so.

Triggers - long trigger = anchor open + k x range, short trigger = anchor open - k x range (default k = 0.5).

Signal - the first bar whose close is at or beyond a trigger, among the bars that close inside the signal window (default: the 20 hours after the anchor). Only one signal per day is possible. If the first breakout is in a direction you have filtered out, the day is used up and is not re-armed for the other side. The same happens if the previous reference trade is still open when the breakout comes, which is only possible when the time exit is set later than the next anchor. The status panel records either case as the last event.

Reference entry - the open of the bar after the signal, which is where a market order placed on the signal bar's close would be filled.

Reference stop - stop distance x range away from the reference entry (default 0.5). With the defaults this puts the stop roughly back at the anchor open: a breakout that gives back its whole move has failed.

Reference time exit - the first bar that opens at or after the anchor plus the exit time (default 20.75 hours, which is 20:45 UTC with a 00:00 anchor). There is no profit target.

[b]What Is Different From a Classic Volatility Breakout[/b]

Adding a fraction of the previous range to the open is the volatility-breakout idea popularised by Larry Williams. Classic versions read the previous daily bar and enter intrabar on a stop order. This script changes four things:

- The range is a rolling look-back ending at a UTC time you choose, not a calendar day's bar, so it behaves the same on markets that never close and on any intraday timeframe.
- A breakout needs a bar close beyond the trigger, not a touch. A wick that pierces the level and snaps back is not a signal.
- The stop is a fraction of the same range, so the risk unit widens on volatile days and tightens on quiet ones, in proportion to the triggers.
- The reference trade ends at a fixed time of day instead of at a target or on the next session, so every signal has a known maximum holding time.

No code from any other publication is used.

[b]What It Draws[/b]

- Anchor open (grey) and the long and short triggers for the signal window.
- Up and down triangles on the bar whose close confirmed a breakout.
- The reference stop (orange) while the reference trade is open.
- A cross on the bar where the stop was touched. A square on the last bar before the time exit; the reference exit itself is the next bar's open.
- A status panel: whether today is armed, skipped or used, the levels with the range as a percentage of price, the open reference trade and the last event.

[b]How to Use It[/b]

Use a minute chart, 1-minute to 15-minute; the defaults were designed on 5-minute bars. Seconds charts are not supported. The anchor time must coincide with a bar open on your timeframe, or no day will arm; the panel warns you when that happens, and also when no bar has opened at the anchor for over a day.

The levels are reference points, not instructions. Read the status panel before you act on a triangle: a signal late in the window has much less time left before the exit. What the reference stop and exit are worth depends on your spread, your fees, your financing charges and your own risk rules. The script does not know any of those.

The defaults were designed around 24/7 crypto markets such as Bitcoin and Ether. On markets that close daily or for the weekend, set the anchor and the exit inside trading hours, and expect skipped days around closures.

[b]Settings[/b]

Rule - day anchor hour and minute (UTC, default 00:00), range look-back (24 hours), trigger distance (0.5 x range), reference stop distance (0.5 x range), signal window (20 hours), time exit (20.75 hours), minimum look-back coverage (41.7 percent of the expected bars).

Signals - Both, Long only or Short only.

Display - anchor and trigger levels, reference stop, status panel and its position, and colours.

Alerts - "Send detailed alert() messages" (on by default) sends one message per breakout, stop touch and time exit, with the levels filled in. Create the alert with "Any alert() function call". The script also defines four named conditions: Long breakout, Short breakout, Reference stop touched, Reference time exit.

[b]Repaint Policy[/b]

The triggers are fixed on the anchor bar from that bar's open and from bars that had already closed. They do not move during the day. Breakouts, stop touches and time exits are evaluated only on confirmed bar closes and are never removed afterwards. Alerts fire once per bar close. Nothing is plotted into the past.

The stop touch is judged on the bar's high and low at its close, so on a live bar the cross appears when the bar closes, not at the moment of the touch.

The script never revises a decision it has made. TradingView itself can rebuild historical bars from its stored data when a chart is reloaded, and those bars can differ slightly from what a live bar showed; that is a property of the data feed, not of this script.

[b]Limitations, Stated Plainly[/b]

- One signal per day by design. Many days have no signal at all.
- A rule with one entry a day, a stop and no profit target takes repeated losses in ranging conditions, and its outcome can be dominated by a small number of large moves. Long runs without a winning reference trade are possible.
- The reference entry, stop and exit use chart prices. Real fills include the spread, fees, slippage and, if held past rollover, financing.
- Different data feeds for the same instrument produce slightly different highs, lows and closes, so levels and signals can differ between feeds.
- The anchor and exit are fixed UTC clock times and do not follow daylight-saving changes.
- History is limited by how many bars your TradingView plan loads.

[b]What It Is Not[/b]

It does not place orders, size positions or manage risk. It does not know your account, your broker or your costs. A reference trade on the chart is a description of what the rule would do, not a record of a trade.

[b]Disclaimer[/b]

This script is a technical indicator. It is NOT financial advice, NOT investment advice and NOT a recommendation to enter or exit any position. Trading leveraged products such as CFDs and crypto derivatives carries a high level of risk and you may lose more than your initial deposit. You are solely responsible for your own trading decisions and their outcomes.

## Source Code

````pine
// =============================================================================
// DAILY VOLATILITY BREAKOUT - anchored range trigger, close confirmation, time exit
// -----------------------------------------------------------------------------
// WHAT IT DOES
//   Once a day, at a fixed UTC anchor time, the script measures how far price
//   travelled over the look-back that ends at the anchor (by default the prior 24
//   hours: highest high minus lowest low). It then places two trigger levels a
//   fraction of that range above and below the anchor bar's open. The first bar
//   that CLOSES beyond one of them during the signal window is the day's breakout
//   signal. Only one signal per day is possible.
//
//   For that signal it draws a reference stop, measured from the next bar's open
//   (where a market order would have filled) as a fraction of the same range, and
//   it marks the reference time exit. It follows the reference trade until the
//   stop is touched or the exit time is reached.
//
// LINEAGE AND WHAT IS DIFFERENT
//   Measuring the prior period's range and adding a fraction of it to the open is
//   the volatility-breakout idea popularised by Larry Williams. Classic versions
//   use daily bars and enter intrabar on a stop order. This implementation:
//     - measures a ROLLING look-back that ends at a configurable UTC anchor,
//       rather than a calendar day's bar, so it works on 24/7 markets;
//     - requires a bar CLOSE beyond the trigger on the chart timeframe instead
//       of an intrabar touch, which filters wicks that pierce and snap back;
//     - expresses the stop as a fraction of the same range, so the risk unit
//       scales with volatility;
//     - ends the reference trade at a fixed time of day, with no target;
//     - skips a day whose look-back is missing too many bars.
//   No code from any other publication is used.
//
// REPAINT POLICY
//   The trigger levels are fixed on the anchor bar from its open and from bars
//   that have already closed. Signals, stop touches and time exits are decided
//   only on confirmed bar closes and never change afterwards. Nothing is plotted
//   into the past.
//
// This script is a TECHNICAL INDICATOR. It draws levels and marks events. It does
// not place orders, does not size positions and does not manage risk. It is NOT
// financial advice, NOT investment advice and NOT a recommendation to enter or
// exit any position. Trading leveraged products such as CFDs and crypto
// derivatives carries a high level of risk; you may lose more than your initial
// deposit. You are solely responsible for your trading decisions and outcomes.
//
// Licensed under the Mozilla Public License 2.0 (MPL-2.0).
// (c) kenkemdayfx
// =============================================================================
//@version=6
indicator("Daily Volatility Breakout - Anchored Range Trigger and Time Exit", "Daily VBO", overlay = true)

const int MIN_MS = 60000
const int DAY_MS = 86400000

// =============================================================================
// INPUTS
// =============================================================================
string gRule = "Rule"
string gSig  = "Signals"
string gViz  = "Display"
string gAlt  = "Alerts"

anchorHour   = input.int(0, "Day anchor (UTC)  hour", minval = 0, maxval = 23, inline = "anc", group = gRule, tooltip = "The daily reset time, in UTC. The anchor open is the open of the bar that starts exactly at this time, and the look-back range ends here. A bar must start at this minute on the chart's timeframe, or that day is not armed.")
anchorMinute = input.int(0, "minute", minval = 0, maxval = 59, inline = "anc", group = gRule)
rangeHours   = input.float(24.0, "Range look-back (hours)", minval = 1.0, maxval = 168.0, step = 1.0, group = gRule, tooltip = "The window before the anchor whose highest high minus lowest low is 'the range'. Every distance in the script is a fraction of this, so the levels widen on volatile days and tighten on quiet ones.")
kMult        = input.float(0.5, "Trigger distance (x range)", minval = 0.05, maxval = 3.0, step = 0.05, group = gRule, tooltip = "How far from the anchor open a bar must close to count as a breakout. Smaller values trigger more often and on smaller moves. Larger values wait for a larger displacement.")
stopFrac     = input.float(0.5, "Reference stop distance (x range)", minval = 0.05, maxval = 3.0, step = 0.05, group = gRule, tooltip = "Distance of the reference stop from the reference entry (the open of the bar after the signal). With the trigger at 0.5, a stop of 0.5 puts the stop roughly back at the anchor open.")
windowHours  = input.float(20.0, "Signal window after the anchor (hours)", minval = 0.25, maxval = 24.0, step = 0.25, group = gRule, tooltip = "Breakout closes are accepted only from bars that close within this many hours after the anchor. After that, the day's levels stop being drawn and no new signal is taken.")
exitHours    = input.float(20.75, "Time exit after the anchor (hours)", minval = 0.25, maxval = 48.0, step = 0.25, group = gRule, tooltip = "The reference trade is closed at the first bar that opens at or after this time. 20.75 hours after a 00:00 anchor is 20:45 UTC, ahead of the usual broker rollover. It should be later than the signal window.")
minCovPct    = input.float(41.7, "Minimum look-back coverage (%)", minval = 0.0, maxval = 100.0, step = 0.1, group = gRule, tooltip = "A day is skipped if fewer than this share of the look-back's bars exist, for example after a data gap or when the market was closed. 41.7% is 120 of the 288 bars in 24 hours of 5-minute data.")

sigMode      = input.string("Both", "Signal direction", options = ["Both", "Long only", "Short only"], group = gSig, tooltip = "Which breakouts are marked. A day whose first breakout is in a filtered direction is not re-armed for the other side: there is one breakout per day.")

showLevels   = input.bool(true, "Show anchor open and trigger levels", group = gViz)
showStop     = input.bool(true, "Show the reference stop", group = gViz)
showTable    = input.bool(true, "Show the status panel", group = gViz)
tablePos     = input.string("Top right", "Panel position", options = ["Top right", "Bottom right", "Top left", "Bottom left"], group = gViz)
colLong      = input.color(color.new(color.teal, 0), "Long colour", group = gViz)
colShort     = input.color(color.new(color.maroon, 0), "Short colour", group = gViz)
colStop      = input.color(color.new(color.orange, 0), "Stop colour", group = gViz)

useAlertFn   = input.bool(true, "Send detailed alert() messages", group = gAlt, tooltip = "When ON, an alert created with 'Any alert() function call' receives one message per event (breakout, stop touched, time exit) with the levels filled in. The four named alert conditions are available either way.")

// =============================================================================
// CORE
// =============================================================================
int  tfMs      = timeframe.in_seconds() * 1000
int  anchorMin = anchorHour * 60 + anchorMinute
int  anchorOff = anchorMin * MIN_MS
int  rangeMs   = math.round(rangeHours * 60) * MIN_MS
int  windowMs  = math.round(windowHours * 60) * MIN_MS
int  exitMs    = math.round(exitHours * 60) * MIN_MS
int  needBars  = tfMs > 0 ? math.round(minCovPct / 100.0 * rangeMs / tfMs) : 0
// Minute charts only: on a seconds chart a long look-back can exceed Pine's 100,000-element
// array limit, and the rule is not meant for sub-minute bars.
bool tfOk      = timeframe.isminutes and tfMs > 0 and anchorOff % tfMs == 0
bool isAnchor  = tfOk and ((time - anchorOff) % DAY_MS + DAY_MS) % DAY_MS == 0

// Rolling buffer of confirmed bars that can still fall in a future look-back.
var array<int>   bufT = array.new<int>()
var array<float> bufH = array.new<float>()
var array<float> bufL = array.new<float>()

var bool  armed       = false
var bool  fired       = false
var bool  skippedDay  = false
var int   anchorT     = na
var float dayOpen     = na
var float dayRange    = na
var float upLvl       = na
var float dnLvl       = na

// Arm on the anchor bar. Its open and the bars before it are already fixed, so the
// result is identical on every tick of that bar.
if isAnchor
    anchorT    := time
    armed      := false
    fired      := false
    skippedDay := false
    int   t0 = time - rangeMs
    float hi = na
    float lo = na
    int   n  = 0
    int   sz = bufT.size()
    if sz > 0
        for i = 0 to sz - 1
            int bt = bufT.get(i)
            if bt >= t0 and bt < time
                hi := na(hi) ? bufH.get(i) : math.max(hi, bufH.get(i))
                lo := na(lo) ? bufL.get(i) : math.min(lo, bufL.get(i))
                n += 1
    if n < needBars or na(hi) or na(lo) or not (hi > lo)
        skippedDay := true
    else
        dayRange := hi - lo
        dayOpen  := open
        upLvl    := dayOpen + kMult * dayRange
        dnLvl    := dayOpen - kMult * dayRange
        armed    := true

// =============================================================================
// REFERENCE TRADE
// =============================================================================
var int   vDir     = 0       // +1 / -1 while pending or active, 0 when flat
var bool  vPending = false   // signal confirmed, entry on this bar's open
var float vDist    = na
var float vEntry   = na
var float vStop    = na
var int   vExitT   = na
var string lastEvt = "none yet"

int closeT = time + tfMs

// Entry reference: the open of the bar after the signal, known from its first tick.
if vPending
    vPending := false
    vEntry   := open
    vStop    := vDir > 0 ? open - vDist : open + vDist

bool evStop = false
bool evTime = false
if vDir != 0 and not vPending and not na(vStop) and barstate.isconfirmed
    if (vDir > 0 and low <= vStop) or (vDir < 0 and high >= vStop)
        evStop  := true
    else if not na(vExitT) and closeT >= vExitT
        evTime  := true
int exitDir = vDir
if evStop or evTime
    lastEvt := (evStop ? "stop touched " : "time exit ") + str.format_time(time, "yyyy-MM-dd HH:mm", "UTC")
    vDir    := 0

// Breakout signal: confirmed closes only, one per anchor-day.
int sigDir = 0
if barstate.isconfirmed and armed and not fired and closeT > anchorT and closeT <= anchorT + windowMs
    if close >= upLvl
        sigDir := 1
    else if close <= dnLvl
        sigDir := -1
    if sigDir != 0
        fired := true
        bool dirOk = sigDir > 0 ? sigMode != "Short only" : sigMode != "Long only"
        if not dirOk or vDir != 0
            lastEvt := (vDir != 0 ? "breakout skipped, reference trade still open " : "breakout filtered by direction ") + str.format_time(time, "yyyy-MM-dd HH:mm", "UTC")
            sigDir  := 0
        else
            vDir     := sigDir
            vPending := true
            vDist    := stopFrac * dayRange
            vEntry   := na
            vStop    := na
            vExitT   := anchorT + exitMs
            lastEvt  := (sigDir > 0 ? "long breakout " : "short breakout ") + str.format_time(time, "yyyy-MM-dd HH:mm", "UTC")

// Feed the buffer last, so the anchor bar never sees itself.
if barstate.isconfirmed
    bufT.push(time)
    bufH.push(high)
    bufL.push(low)
    int cut = closeT - rangeMs
    while bufT.size() > 0 and bufT.first() < cut
        bufT.shift()
        bufH.shift()
        bufL.shift()

// =============================================================================
// DISPLAY
// =============================================================================
bool dayLive = showLevels and armed and not na(anchorT) and time >= anchorT and time < anchorT + windowMs
plot(dayLive ? upLvl : na, "Long trigger", colLong, 1, plot.style_linebr)
plot(dayLive ? dnLvl : na, "Short trigger", colShort, 1, plot.style_linebr)
plot(dayLive ? dayOpen : na, "Anchor open", color.new(color.gray, 30), 1, plot.style_linebr)
plot(showStop and vDir != 0 and not na(vStop) ? vStop : na, "Reference stop", colStop, 2, plot.style_linebr)
plotshape(sigDir > 0, "Long breakout", shape.triangleup, location.belowbar, colLong, size = size.small)
plotshape(sigDir < 0, "Short breakout", shape.triangledown, location.abovebar, colShort, size = size.small)
// plotshape's location must be an input-or-weaker constant, so each exit side gets its own call.
plotshape(evStop and exitDir > 0, "Long stop touched", shape.xcross, location.belowbar, colStop, size = size.tiny)
plotshape(evStop and exitDir < 0, "Short stop touched", shape.xcross, location.abovebar, colStop, size = size.tiny)
plotshape(evTime and exitDir > 0, "Long time exit", shape.square, location.abovebar, color.new(color.gray, 0), size = size.tiny)
plotshape(evTime and exitDir < 0, "Short time exit", shape.square, location.belowbar, color.new(color.gray, 0), size = size.tiny)

f_pos(string p) =>
    p == "Bottom right" ? position.bottom_right : p == "Top left" ? position.top_left : p == "Bottom left" ? position.bottom_left : position.top_right

if showTable and barstate.islast
    var table tb = table.new(f_pos(tablePos), 2, 6, bgcolor = color.new(color.black, 20), border_width = 1)
    color txt  = color.new(color.white, 0)
    color warn = color.new(color.orange, 0)
    string tfTxt = not timeframe.isminutes ? "Needs a minute chart. Built for 1m to 15m." : not tfOk ? "No bar opens at the anchor time on this timeframe. Change the anchor or the timeframe." : na(anchorT) or time - anchorT > DAY_MS + tfMs ? "No bar has opened at the anchor time in the last day. Check the symbol's trading hours." : "OK"
    string dayTxt = skippedDay ? "skipped: look-back has too few bars" : not armed ? "waiting for the next anchor" : fired ? "breakout used" : time >= anchorT + windowMs ? "window closed, no breakout" : "armed, waiting for a close beyond a trigger"
    string trdTxt = vDir == 0 ? "flat" : (vDir > 0 ? "long" : "short") + (na(vEntry) ? " (entry on next open)" : " from " + str.tostring(vEntry, format.mintick) + ", stop " + str.tostring(vStop, format.mintick)) + ", exit " + str.format_time(vExitT, "HH:mm", "UTC") + " UTC"
    table.cell(tb, 0, 0, "Daily Vol Breakout", text_color = txt, text_size = size.small)
    table.cell(tb, 1, 0, syminfo.ticker + " " + timeframe.period, text_color = txt, text_size = size.small)
    table.cell(tb, 0, 1, "Chart", text_color = txt, text_size = size.small)
    string chkTxt = tfTxt == "OK" and exitMs <= windowMs ? "Time exit is not later than the signal window: a late breakout can exit on its own entry bar." : tfTxt
    table.cell(tb, 1, 1, chkTxt, text_color = chkTxt == "OK" ? txt : warn, text_size = size.small)
    table.cell(tb, 0, 2, "Today", text_color = txt, text_size = size.small)
    table.cell(tb, 1, 2, dayTxt, text_color = txt, text_size = size.small)
    table.cell(tb, 0, 3, "Levels", text_color = txt, text_size = size.small)
    table.cell(tb, 1, 3, armed ? "open " + str.tostring(dayOpen, format.mintick) + "  long " + str.tostring(upLvl, format.mintick) + "  short " + str.tostring(dnLvl, format.mintick) + "  range " + str.tostring(dayOpen > 0 ? dayRange / dayOpen * 100.0 : na, "#.##") + "%" : "-", text_color = txt, text_size = size.small)
    table.cell(tb, 0, 4, "Reference trade", text_color = txt, text_size = size.small)
    table.cell(tb, 1, 4, trdTxt, text_color = txt, text_size = size.small)
    table.cell(tb, 0, 5, "Last event", text_color = txt, text_size = size.small)
    table.cell(tb, 1, 5, lastEvt, text_color = txt, text_size = size.small)

// =============================================================================
// ALERTS
// =============================================================================
alertcondition(sigDir > 0, "Long breakout", "Daily volatility breakout: LONG close on {{ticker}} {{interval}} at {{close}}")
alertcondition(sigDir < 0, "Short breakout", "Daily volatility breakout: SHORT close on {{ticker}} {{interval}} at {{close}}")
alertcondition(evStop, "Reference stop touched", "Daily volatility breakout: reference stop touched on {{ticker}} {{interval}}")
alertcondition(evTime, "Reference time exit", "Daily volatility breakout: reference time exit on {{ticker}} {{interval}}")

if useAlertFn and sigDir != 0
    float refStop = sigDir > 0 ? close - vDist : close + vDist
    alert(str.format("{0} {1}: {2} breakout close {3} beyond trigger {4}. Reference stop about {5} ({6} from the next open). Time exit {7} UTC.",
         syminfo.ticker, timeframe.period, sigDir > 0 ? "LONG" : "SHORT", str.tostring(close, format.mintick),
         str.tostring(sigDir > 0 ? upLvl : dnLvl, format.mintick), str.tostring(refStop, format.mintick),
         str.tostring(vDist, format.mintick), str.format_time(vExitT, "yyyy-MM-dd HH:mm", "UTC")), alert.freq_once_per_bar_close)
if useAlertFn and (evStop or evTime)
    alert(str.format("{0} {1}: reference {2} {3}.", syminfo.ticker, timeframe.period, exitDir > 0 ? "long" : "short",
         evStop ? "stop touched" : "time exit"), alert.freq_once_per_bar_close)
````
