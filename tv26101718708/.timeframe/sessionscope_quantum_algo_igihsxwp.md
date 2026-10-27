# Sessionscope [Quantum Algo]

- url: https://www.tradingview.com/script/igihSXwp-Sessionscope-Quantum-Algo/
- type: indicator
- pine_id: PUB;b7e84226b0414c4aa391342a63a4cf89
- version: 1.0

## Description

Sessionscope is a time-based ICT killzone tool that plots the four primary intraday
killzones, projects the liquidity each one creates, and then measures what happens after
that liquidity is taken. It is built for traders who use Smart Money / ICT concepts and
want session context plus a quantified read on how each killzone behaves on their specific
instrument.

It is not a buy/sell signal system. It is a context and statistics tool.


[b]WHAT IT PLOTS
[/b]
- Four killzone range boxes, each with its high, low and equilibrium (50%) level.
- Forward-projected session liquidity: each closed killzone's high as buy-side liquidity
  (BSL) and its low as sell-side liquidity (SSL).
- Liquidity sweep marks, recolored by outcome (reversal vs continuation).
- The New York midnight open (00:00 ET) as a daily reference line.
- A statistics dashboard summarizing each killzone over the full chart history.


[b]THE FOUR KILLZONES
[/b]
Default windows, in New York time (America/New_York):
- Asia          20:00 - 00:00
- London Open   02:00 - 05:00
- New York AM   07:00 - 10:00
- London Close  10:00 - 12:00

These are the conventional ICT killzone windows. Because the timezone is anchored to
America/New_York rather than a fixed UTC offset, the windows automatically follow US
daylight saving (EST/EDT) and stay aligned year-round. All four windows, names and colors
are fully editable, so you can shift them, repurpose one (for example to a New York PM or
Silver Bullet window), or adapt the New York window to index timing (08:30 - 11:00) if you
trade futures rather than forex.


[b]SESSION LIQUIDITY (BSL / SSL)
[/b]
While a killzone is open, the box tracks its developing high and low in real time. When the
killzone closes, those extremes are frozen and projected forward as horizontal liquidity
levels - the high as buy-side liquidity, the low as sell-side liquidity - and extended until
the next instance of that same session. A sweep is registered when price trades through a
projected level (a wick or close beyond the high, or beyond the low). The level can be frozen
at the moment of the sweep to keep the chart clean.


[b]SWEEP OUTCOME ENGINE (the core idea)
[/b]
Marking a sweep is common. Sessionscope goes further and classifies the outcome of every
sweep:

- High sweep -> REVERSAL if price closes back below the swept high within a configurable
  number of bars; otherwise CONTINUATION.
- Low sweep  -> REVERSAL if price closes back above the swept low within that window;
  otherwise CONTINUATION.

A reversal is the classic ICT liquidity-grab outcome (the level is run, then rejected). A
continuation means the level broke and held (a genuine expansion). Each sweep mark is
recolored to its resolved outcome, and the result feeds the Rev% statistic below. This turns
the qualitative liquidity-grab premise into a measured, per-session number.


[b]NEW YORK MIDNIGHT OPEN
[/b]
The first traded price after 00:00 America/New_York is captured each day and drawn as a
horizontal reference for that session - a level many ICT traders use as a daily equilibrium
anchor. It is fixed once printed and does not move.


STATISTICS DASHBOARD

For each enabled killzone, accumulated over the entire visible chart history:

- Avg Rng : average high-to-low range of the session, in price.
- xATR    : that average range expressed as a multiple of the daily ATR(14), so you can see
            which killzone expands most relative to typical daily volatility.
- Swept%  : how often the session's liquidity is taken - the share of its high and low
            levels that get swept before the session next reopens.
- Rev%    : of the sweeps that occurred, how often price reversed back inside the range
            (a grab) rather than continuing through (a breakout).
- Bias%   : share of sessions that closed above their open (directional tendency).
- n       : number of completed sessions in the sample.

Read together, Swept% and Rev% answer two distinct questions: how often does this killzone's
liquidity get run, and when it does, how often does it snap back? Bias% and xATR add the
session's directional lean and its size relative to the day.


[b]HOW IT WORKS (calculation notes)
[/b]
- Sessions are detected with Pine's time/session function in the chosen timezone; the box
  high/low are running extremes of the bars inside each window.
- The daily ATR used for xATR is requested from the 1D timeframe using an offset expression
  with lookahead disabled, so it is fully confirmed and constant intraday (no lookahead bias).
- Sweep outcomes are evaluated only on confirmed price relative to fixed, already-closed
  levels.
- Statistics are accumulated over the full chart history independently of what is drawn.
- To keep the price scale anchored to current price, only a configurable number of recent
  sessions of boxes and levels are kept on the chart (older drawings are removed); this does
  not affect the statistics, which always use full history.


[b]WHAT MAKES IT DIFFERENT
[/b]
Most session and killzone tools stop at colored boxes, session highs/lows, midpoints and a
basic range table. Sessionscope adds the outcome layer: it does not just show that liquidity
was swept, it measures whether each session's sweeps tend to reverse or continue, and colors
them accordingly. The Rev% metric, combined with Swept%, is the part that goes beyond a
standard session-range tool.


[b]SETTINGS[/b]

Grouped for clarity: Timezone; Sessions / Killzones (per-session enable, name, window,
color); Box & Level Visuals (boxes, fills, high/low, equilibrium, labels, history cap);
Session Liquidity & Sweeps (projection, sweep marks, freeze-on-sweep, line style, reversal
window, outcome coloring); New York Midnight Open; Statistics Dashboard (position, size);
and Alerts.


[b]HOW TO USE
[/b]
- Apply on an intraday timeframe; 1m to 1h work best (5m or 15m for clean session structure).
- Mark your higher-timeframe bias first, then use the killzone windows to time entries.
- When a killzone level is swept, read the outcome color and that session's historical Rev%
  to gauge whether a reversal back inside the range is the higher-probability path.
- Use xATR to see which session is statistically the most active on your instrument, and
  Bias% for its directional lean.


[b]REPAINTING
[/b]
Boxes and the live high/low update in real time while the current session is forming - this
is expected real-time behavior, not lookahead. Once a session closes, its levels are fixed;
sweeps are detected on price crossing those fixed levels; and an outcome, once resolved on a
closed bar, does not change. No lookahead is used anywhere in the script.


[b]CONCEPTS AND CREDIT
[/b]
The concepts used here - killzones, buy-side and sell-side liquidity, liquidity sweeps, the
midnight open, and premium/discount equilibrium - originate with the Inner Circle Trader
(Michael J. Huddleston) and the wider Smart Money Concepts / price-action community, where
they are taught and discussed openly. The session window defaults follow the killzone times
commonly used by that community. All code in this script - the session detection, liquidity
projection, sweep-outcome classification and statistics engine - is written independently and
reuses no third-party code. It is published open-source so anyone can read, verify and modify
it under TradingView's House Rules.


[b]DISCLAIMER
[/b]
This script is provided for educational and informational purposes only. It is not financial,
investment or trading advice, and it does not produce buy or sell recommendations. All
statistics are descriptive measurements of historical data on the current chart and do not
predict future price behavior; past behavior of a session or level does not guarantee future
results. Trading involves substantial risk of loss. You are solely responsible for your own
decisions and risk management. Test any tool thoroughly on your own markets and timeframes
before relying on it.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Quantum-Algo

//@version=6
// Sessionscope - intraday session / killzone profiler.
// Plots the four ICT killzones (Asian, London Open, New York AM, London Close) as live range objects,
// projects each closed session's high/low forward as buy-side / sell-side liquidity, detects when those
// levels are swept, plots the New York midnight open, and quantifies how each session behaves over the
// full chart history (average range, size vs daily ATR, sweep rate, directional bias).

indicator("Sessionscope [Quantum Algo]", "Sessionscope [Quantum Algo]", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// =================================================================================================
// Inputs
// =================================================================================================
string GRP_TZ   = "Timezone"
string GRP_SESS = "Sessions / Killzones"
string GRP_VIS  = "Box & Level Visuals"
string GRP_LIQ  = "Session Liquidity & Sweeps"
string GRP_MN   = "New York Midnight Open"
string GRP_STAT = "Statistics Dashboard"
string GRP_ALRT = "Alerts"

tz = input.string("America/New_York", "Calculation timezone", group = GRP_TZ, options = ["America/New_York", "Europe/London", "Asia/Tokyo", "Asia/Shanghai", "Australia/Sydney", "UTC", "GMT-5", "GMT+0", "GMT+1", "GMT+2", "GMT+3", "GMT+8", "GMT+9"], tooltip = "Every session window below is read in this timezone. ICT killzones are conventionally defined in America/New_York.")

// --- Session 1: Asian ---
s1On   = input.bool(true,           "Enable", inline = "s1a", group = GRP_SESS)
s1Name = input.string("Asia",       "Name",   inline = "s1a", group = GRP_SESS)
s1Sess = input.session("2000-0000", "Window", inline = "s1b", group = GRP_SESS)
s1Col  = input.color(#787b86,       "",       inline = "s1b", group = GRP_SESS)
// --- Session 2: London Open ---
s2On   = input.bool(true,            "Enable", inline = "s2a", group = GRP_SESS)
s2Name = input.string("London Open", "Name",   inline = "s2a", group = GRP_SESS)
s2Sess = input.session("0200-0500", "Window", inline = "s2b", group = GRP_SESS)
s2Col  = input.color(#2962ff,       "",       inline = "s2b", group = GRP_SESS)
// --- Session 3: New York AM ---
s3On   = input.bool(true,           "Enable", inline = "s3a", group = GRP_SESS)
s3Name = input.string("NY AM",      "Name",   inline = "s3a", group = GRP_SESS)
s3Sess = input.session("0700-1000", "Window", inline = "s3b", group = GRP_SESS)
s3Col  = input.color(#089981,       "",       inline = "s3b", group = GRP_SESS)
// --- Session 4: London Close ---
s4On   = input.bool(true,             "Enable", inline = "s4a", group = GRP_SESS)
s4Name = input.string("London Close", "Name",   inline = "s4a", group = GRP_SESS)
s4Sess = input.session("1000-1200",   "Window", inline = "s4b", group = GRP_SESS)
s4Col  = input.color(#7e57c2,         "",       inline = "s4b", group = GRP_SESS)

showBox   = input.bool(true,    "Show session box",                 group = GRP_VIS)
fillBox   = input.bool(true,    "Fill box",                         inline = "fb", group = GRP_VIS)
boxTrans  = input.int(86,       "Transparency", minval = 0, maxval = 100, inline = "fb", group = GRP_VIS)
borderW   = input.int(1,        "Border width", minval = 0, maxval = 4, group = GRP_VIS)
showHL    = input.bool(true,    "Show session high / low",          group = GRP_VIS)
showEQ    = input.bool(true,    "Show equilibrium (50%)",           group = GRP_VIS)
showLabel = input.bool(true,    "Show session label",               inline = "lb", group = GRP_VIS)
showRange = input.bool(true,    "+ range", inline = "lb", group = GRP_VIS, tooltip = "Append the high-low range (in price) to the session label.")
labelSize = input.string("Small", "Label size", options = ["Tiny", "Small", "Normal", "Large"], group = GRP_VIS)
keepN     = input.int(12, "Sessions to keep on chart", minval = 1, maxval = 200, group = GRP_VIS, tooltip = "How many recent sessions of boxes/levels stay drawn. Lower keeps the price scale tight around current price (the statistics dashboard always uses the full chart history regardless of this).")

liqOn      = input.bool(true,   "Project session high/low as liquidity", group = GRP_LIQ, tooltip = "When a session closes its high becomes buy-side liquidity (BSL) and its low becomes sell-side liquidity (SSL). Each level is extended forward until the next instance of that session.")
markSweep  = input.bool(true,   "Mark sweeps (x)",                  group = GRP_LIQ)
stopOnSweep= input.bool(true,   "Freeze level once swept",          group = GRP_LIQ)
liqWidth   = input.int(1,       "Liquidity line width", minval = 1, maxval = 4, inline = "ls", group = GRP_LIQ)
liqStyle   = input.string("Dashed", "Style", options = ["Solid", "Dashed", "Dotted"], inline = "ls", group = GRP_LIQ)
sweptCol   = input.color(#ef5350, "Swept color",                    group = GRP_LIQ)
revBars    = input.int(12,      "Bars to confirm reversal", minval = 1, maxval = 500, group = GRP_LIQ, tooltip = "After a sweep, if price closes back inside the session range within this many bars it counts as a reversal (liquidity grab); if it stays beyond the level it counts as a continuation. Drives the Rev% statistic and the outcome coloring. Window is in bars, so it scales with your chart timeframe.")
colorOutcome = input.bool(true, "Color sweep marks by outcome",     group = GRP_LIQ, tooltip = "Recolors each sweep mark once resolved: reversal color if price closed back inside the range, continuation color if it broke through.")
revCol     = input.color(#26a69a, "Reversal", inline = "oc", group = GRP_LIQ)
contCol    = input.color(#9598a1, "Continuation", inline = "oc", group = GRP_LIQ)

mnOn    = input.bool(true,      "Show NY midnight open (00:00 ET)",  group = GRP_MN, tooltip = "Plots the first price after 00:00 America/New_York each day - a common ICT daily reference. Fixed once printed; does not repaint.")
mnExt   = input.bool(true,      "Extend across the day",            group = GRP_MN)
mnLblOn = input.bool(true,      "Label",                            inline = "mn", group = GRP_MN)
mnCol   = input.color(#9598a1,  "",                                 inline = "mn", group = GRP_MN)
mnStyle = input.string("Dotted","Style", options = ["Solid", "Dashed", "Dotted"], inline = "mn", group = GRP_MN)

statOn  = input.bool(true,      "Show statistics dashboard",         group = GRP_STAT)
statPos = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = GRP_STAT)
statSize= input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = GRP_STAT)

alSessOpen = input.bool(false,  "Alert on session open",             group = GRP_ALRT)
alSweep    = input.bool(false,  "Alert on liquidity sweep",          group = GRP_ALRT)

// =================================================================================================
// Helpers
// =================================================================================================
f_size(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : size.large

f_lineStyle(string s) =>
    s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted

f_pos(string p) =>
    p == "Top Right" ? position.top_right : p == "Top Left" ? position.top_left : p == "Bottom Right" ? position.bottom_right : p == "Bottom Left" ? position.bottom_left : position.middle_right

// Previous completed daily ATR - read with lookahead OFF and indexed [1] so it is fully confirmed
// and constant intraday (no repaint). Used only to size session range vs daily volatility.
dAtr = request.security(syminfo.tickerid, "1D", ta.atr(14)[1], lookahead = barmerge.lookahead_off)

// Stores of drawn objects so the oldest can be deleted (keeps the auto-scale tight around current price)
var array<box>   boxStore  = array.new<box>()
var array<line>  lineStore = array.new<line>()
var array<label> lblStore  = array.new<label>()

// =================================================================================================
// Session type
// =================================================================================================
type Session
    string name
    color  col
    bool   on
    bool   inb = false          // is this bar inside the session (resolved at global scope)
    // live session tracking
    float  hi  = na
    float  lo  = na
    float  op  = na
    float  cl  = na
    int    x1  = na
    bool   act = false
    box    bx  = na
    line   hl  = na
    line   ll  = na
    line   el  = na
    label  lb  = na
    // forward liquidity record (most recently closed session)
    float  qHi = na
    float  qLo = na
    line   qHiL = na
    line   qLoL = na
    bool   qHiSwept = false
    bool   qLoSwept = false
    bool   qOn = false
    // sweep-outcome tracking (reversal vs continuation after a sweep)
    int    qHiSwBar = na
    int    qLoSwBar = na
    bool   qHiDone = false
    bool   qLoDone = false
    label  qHiMk = na
    label  qLoMk = na
    // statistics accumulators
    int    n   = 0
    float  sRng = 0.0
    int    nUp = 0
    int    qN  = 0
    int    qHiN = 0
    int    qLoN = 0
    int    swTot = 0
    int    swRev = 0

// =================================================================================================
// Per-session engine
// =================================================================================================
method update(Session s) =>
    if s.on
        bool nowIn = s.inb

        // 1) Session just reopened -> close out the previous liquidity window, then start fresh
        if nowIn and not s.act
            if liqOn and s.qOn
                s.qN  += 1
                s.qHiN := s.qHiN + (s.qHiSwept ? 1 : 0)
                s.qLoN := s.qLoN + (s.qLoSwept ? 1 : 0)
                // any sweep still pending at window end resolves as a continuation
                if s.qHiSwept and not s.qHiDone
                    s.swTot += 1
                    if colorOutcome and not na(s.qHiMk)
                        label.set_textcolor(s.qHiMk, contCol)
                if s.qLoSwept and not s.qLoDone
                    s.swTot += 1
                    if colorOutcome and not na(s.qLoMk)
                        label.set_textcolor(s.qLoMk, contCol)
                s.qOn := false
            s.hi := high
            s.lo := low
            s.op := open
            s.cl := close
            s.x1 := bar_index
            s.act := true
            if showBox
                s.bx := box.new(bar_index, high, bar_index, low, border_color = color.new(s.col, 0), border_width = borderW, bgcolor = fillBox ? color.new(s.col, boxTrans) : na)
                array.push(boxStore, s.bx)
            if showHL
                s.hl := line.new(bar_index, high, bar_index, high, color = s.col, width = 1)
                s.ll := line.new(bar_index, low,  bar_index, low,  color = s.col, width = 1)
                array.push(lineStore, s.hl)
                array.push(lineStore, s.ll)
            if showEQ
                float eq = (high + low) / 2
                s.el := line.new(bar_index, eq, bar_index, eq, color = color.new(s.col, 30), style = line.style_dotted, width = 1)
                array.push(lineStore, s.el)
            if showLabel
                s.lb := label.new(bar_index, high, s.name, style = label.style_none, textcolor = s.col, size = f_size(labelSize))
                array.push(lblStore, s.lb)
            if alSessOpen
                alert(s.name + " session open", alert.freq_once_per_bar_close)

        // 2) Inside the session -> grow the range and stretch every drawing
        if nowIn and s.act
            s.hi := math.max(s.hi, high)
            s.lo := math.min(s.lo, low)
            s.cl := close
            float eq = (s.hi + s.lo) / 2
            if not na(s.bx)
                box.set_top(s.bx, s.hi)
                box.set_bottom(s.bx, s.lo)
                box.set_right(s.bx, bar_index)
            if not na(s.hl)
                line.set_xy1(s.hl, s.x1, s.hi)
                line.set_xy2(s.hl, bar_index, s.hi)
            if not na(s.ll)
                line.set_xy1(s.ll, s.x1, s.lo)
                line.set_xy2(s.ll, bar_index, s.lo)
            if not na(s.el)
                line.set_xy1(s.el, s.x1, eq)
                line.set_xy2(s.el, bar_index, eq)
            if not na(s.lb)
                label.set_xy(s.lb, s.x1, s.hi)
                label.set_text(s.lb, showRange ? s.name + "  " + str.tostring(s.hi - s.lo, format.mintick) : s.name)

        // 3) Session just ended -> bank the statistics and open a new liquidity record
        if (not nowIn) and s.act
            s.act := false
            s.n   += 1
            s.sRng := s.sRng + (s.hi - s.lo)
            s.nUp := s.nUp + (s.cl >= s.op ? 1 : 0)
            if liqOn
                s.qHi := s.hi
                s.qLo := s.lo
                s.qHiSwept := false
                s.qLoSwept := false
                s.qHiDone := false
                s.qLoDone := false
                s.qHiSwBar := na
                s.qLoSwBar := na
                s.qHiMk := na
                s.qLoMk := na
                s.qOn := true
                s.qHiL := line.new(bar_index, s.hi, bar_index, s.hi, color = s.col, width = liqWidth, style = f_lineStyle(liqStyle))
                s.qLoL := line.new(bar_index, s.lo, bar_index, s.lo, color = s.col, width = liqWidth, style = f_lineStyle(liqStyle))
                array.push(lineStore, s.qHiL)
                array.push(lineStore, s.qLoL)

        // 4) Forward liquidity window -> extend the levels, detect sweeps, classify the outcome
        if liqOn and s.qOn
            bool exHi = not (stopOnSweep and s.qHiSwept)
            bool exLo = not (stopOnSweep and s.qLoSwept)
            if exHi and not na(s.qHiL)
                line.set_x2(s.qHiL, bar_index)
            if exLo and not na(s.qLoL)
                line.set_x2(s.qLoL, bar_index)
            // detect a sweep of the high (buy-side liquidity)
            if not s.qHiSwept and high > s.qHi
                s.qHiSwept := true
                s.qHiSwBar := bar_index
                if not na(s.qHiL)
                    line.set_x2(s.qHiL, bar_index)
                    line.set_color(s.qHiL, sweptCol)
                if markSweep
                    s.qHiMk := label.new(bar_index, s.qHi, "x", style = label.style_none, textcolor = sweptCol, size = size.small)
                    array.push(lblStore, s.qHiMk)
                if alSweep
                    alert(s.name + " high swept (BSL taken)", alert.freq_once_per_bar_close)
            // detect a sweep of the low (sell-side liquidity)
            if not s.qLoSwept and low < s.qLo
                s.qLoSwept := true
                s.qLoSwBar := bar_index
                if not na(s.qLoL)
                    line.set_x2(s.qLoL, bar_index)
                    line.set_color(s.qLoL, sweptCol)
                if markSweep
                    s.qLoMk := label.new(bar_index, s.qLo, "x", style = label.style_none, textcolor = sweptCol, size = size.small)
                    array.push(lblStore, s.qLoMk)
                if alSweep
                    alert(s.name + " low swept (SSL taken)", alert.freq_once_per_bar_close)
            // classify the high sweep: reversal (price closes back below) vs continuation
            if s.qHiSwept and not s.qHiDone
                if close < s.qHi
                    s.qHiDone := true
                    s.swTot += 1
                    s.swRev += 1
                    if colorOutcome and not na(s.qHiMk)
                        label.set_textcolor(s.qHiMk, revCol)
                else if bar_index - s.qHiSwBar >= revBars
                    s.qHiDone := true
                    s.swTot += 1
                    if colorOutcome and not na(s.qHiMk)
                        label.set_textcolor(s.qHiMk, contCol)
            // classify the low sweep: reversal (price closes back above) vs continuation
            if s.qLoSwept and not s.qLoDone
                if close > s.qLo
                    s.qLoDone := true
                    s.swTot += 1
                    s.swRev += 1
                    if colorOutcome and not na(s.qLoMk)
                        label.set_textcolor(s.qLoMk, revCol)
                else if bar_index - s.qLoSwBar >= revBars
                    s.qLoDone := true
                    s.swTot += 1
                    if colorOutcome and not na(s.qLoMk)
                        label.set_textcolor(s.qLoMk, contCol)

// =================================================================================================
// Build the session set once
// =================================================================================================
var array<Session> sessions = array.new<Session>()
if barstate.isfirst
    array.push(sessions, Session.new(name = s1Name, col = s1Col, on = s1On))
    array.push(sessions, Session.new(name = s2Name, col = s2Col, on = s2On))
    array.push(sessions, Session.new(name = s3Name, col = s3Col, on = s3On))
    array.push(sessions, Session.new(name = s4Name, col = s4Col, on = s4On))

// Resolve "inside session" at global scope (session strings must be simple, so this stays out of the method)
bool intr = timeframe.isintraday
bool s1In = intr and s1On and not na(time(timeframe.period, s1Sess, tz))
bool s2In = intr and s2On and not na(time(timeframe.period, s2Sess, tz))
bool s3In = intr and s3On and not na(time(timeframe.period, s3Sess, tz))
bool s4In = intr and s4On and not na(time(timeframe.period, s4Sess, tz))

if array.size(sessions) == 4
    Session se0 = array.get(sessions, 0)
    Session se1 = array.get(sessions, 1)
    Session se2 = array.get(sessions, 2)
    Session se3 = array.get(sessions, 3)
    se0.inb := s1In
    se1.inb := s2In
    se2.inb := s3In
    se3.inb := s4In
    for s in sessions
        s.update()

// =================================================================================================
// New York midnight open
// =================================================================================================
var float mnPrice = na
var line  mnLine  = na
bool inMid = intr and not na(time(timeframe.period, "0000-0001", "America/New_York"))
var bool midPrev = false
if mnOn and inMid and not midPrev
    mnPrice := open
    mnLine  := line.new(bar_index, mnPrice, bar_index, mnPrice, color = mnCol, style = f_lineStyle(mnStyle), width = 1)
    array.push(lineStore, mnLine)
    if mnLblOn
        array.push(lblStore, label.new(bar_index, mnPrice, "Midnight Open", style = label.style_none, textcolor = mnCol, size = size.tiny))
if mnOn and mnExt and not na(mnLine)
    line.set_x2(mnLine, bar_index)
midPrev := inMid

// =================================================================================================
// Prune old drawings so the price scale stays anchored to recent price
// =================================================================================================
while array.size(boxStore) > keepN
    box.delete(array.shift(boxStore))
while array.size(lineStore) > keepN * 6
    line.delete(array.shift(lineStore))
while array.size(lblStore) > keepN * 4
    label.delete(array.shift(lblStore))

// =================================================================================================
// Statistics dashboard
// =================================================================================================
var table tbl = table.new(f_pos(statPos), 7, 5, frame_width = 1, frame_color = color.new(color.gray, 60), border_width = 1, border_color = color.new(color.gray, 70))

if statOn and intr and barstate.islast
    color hdrBg = color.new(chart.fg_color, 88)
    color fg    = chart.fg_color
    table.cell(tbl, 0, 0, "Session", text_color = fg, text_size = f_size(statSize), bgcolor = hdrBg)
    table.cell(tbl, 1, 0, "Avg Rng", text_color = fg, text_size = f_size(statSize), bgcolor = hdrBg)
    table.cell(tbl, 2, 0, "xATR",    text_color = fg, text_size = f_size(statSize), bgcolor = hdrBg)
    table.cell(tbl, 3, 0, "Swept%",  text_color = fg, text_size = f_size(statSize), bgcolor = hdrBg)
    table.cell(tbl, 4, 0, "Rev%",    text_color = fg, text_size = f_size(statSize), bgcolor = hdrBg)
    table.cell(tbl, 5, 0, "Bias%",   text_color = fg, text_size = f_size(statSize), bgcolor = hdrBg)
    table.cell(tbl, 6, 0, "n",       text_color = fg, text_size = f_size(statSize), bgcolor = hdrBg)
    int r = 1
    for s in sessions
        if s.on
            float avg     = s.n > 0 ? s.sRng / s.n : na
            float xatr    = (not na(avg) and not na(dAtr) and dAtr > 0) ? avg / dAtr : na
            float liqRate = s.qN > 0 ? 100.0 * (s.qHiN + s.qLoN) / (2 * s.qN) : na
            float revRate = s.swTot > 0 ? 100.0 * s.swRev / s.swTot : na
            float biasUp  = s.n > 0 ? 100.0 * s.nUp / s.n : na
            table.cell(tbl, 0, r, s.name, text_color = s.col, text_size = f_size(statSize))
            table.cell(tbl, 1, r, na(avg) ? "-" : str.tostring(avg, format.mintick), text_color = fg, text_size = f_size(statSize))
            table.cell(tbl, 2, r, na(xatr) ? "-" : str.tostring(xatr, "0.00"), text_color = fg, text_size = f_size(statSize))
            table.cell(tbl, 3, r, na(liqRate) ? "-" : str.tostring(liqRate, "0") + "%", text_color = fg, text_size = f_size(statSize))
            table.cell(tbl, 4, r, na(revRate) ? "-" : str.tostring(revRate, "0") + "%", text_color = na(revRate) ? fg : (revRate >= 50 ? color.new(#26a69a, 0) : color.new(#9598a1, 0)), text_size = f_size(statSize))
            table.cell(tbl, 5, r, na(biasUp) ? "-" : str.tostring(biasUp, "0") + "%", text_color = na(biasUp) ? fg : (biasUp >= 50 ? color.new(#089981, 0) : color.new(#ef5350, 0)), text_size = f_size(statSize))
            table.cell(tbl, 6, r, str.tostring(s.n), text_color = fg, text_size = f_size(statSize))
        else
            table.cell(tbl, 0, r, s.name + " (off)", text_color = color.new(chart.fg_color, 40), text_size = f_size(statSize))
            table.cell(tbl, 1, r, "-", text_color = color.new(chart.fg_color, 40), text_size = f_size(statSize))
            table.cell(tbl, 2, r, "-", text_color = color.new(chart.fg_color, 40), text_size = f_size(statSize))
            table.cell(tbl, 3, r, "-", text_color = color.new(chart.fg_color, 40), text_size = f_size(statSize))
            table.cell(tbl, 4, r, "-", text_color = color.new(chart.fg_color, 40), text_size = f_size(statSize))
            table.cell(tbl, 5, r, "-", text_color = color.new(chart.fg_color, 40), text_size = f_size(statSize))
            table.cell(tbl, 6, r, "-", text_color = color.new(chart.fg_color, 40), text_size = f_size(statSize))
        r += 1

// Gentle nudge if the chart timeframe can't represent intraday sessions
var label tfNote = na
if barstate.islast and not intr
    if na(tfNote)
        tfNote := label.new(bar_index, high, "Sessionscope works on intraday timeframes (1m-1h). Switch to an intraday chart.", style = label.style_label_down, color = color.new(color.gray, 20), textcolor = color.white, size = size.small)
    else
        label.set_xy(tfNote, bar_index, high)
````
