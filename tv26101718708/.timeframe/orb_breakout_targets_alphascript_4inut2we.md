# ORB Breakout Targets | AlphaScript

- url: https://www.tradingview.com/script/4INUT2wE-ORB-Breakout-Targets-AlphaScript/
- type: indicator
- pine_id: PUB;fa0788955c8f444792e07e0299b538fd
- version: 2.0

## Description

[b]ORB Breakout Targets combines a session opening range with the key levels traders already watch[/b], then answers the question most breakout tools leave open: broken — toward what? When the range breaks, the nearest significant level beyond the break is automatically identified and highlighted as the measured target. A breakout with a destination, not just an arrow.

[b]🧠 Concept[/b]
The opening range of a session concentrates the first auction of the day; its break signals initiative in one direction. But a break alone says nothing about follow-through — price tends to travel between reference levels, and the natural magnet after a breakout is the nearest untested level in the breakout direction: the prior day's high, an overnight session extreme, the Monday range. Finding that level by eye, every session, across a dozen candidates, is exactly the work this tool removes. The range gives you the trigger; the key level map gives you the objective.

[b]🔍 What it does[/b]
Builds the opening range from the first N minutes (default 30) of your chosen session — New York, London, or Asia — and [b]draws it as a live box whose fill reflects the current state: bullish coloring while price holds above the range midpoint, bearish below it, updating in real time so the box itself reads as a bias gauge at a glance.[/b] On a confirmed breakout, marks the break on the chart and highlights the nearest enabled key level beyond the range as the target, in its own color with a dedicated label.
Key levels available as target candidates and chart structure:

[b]Timeframes[/b] — 4H, Daily, Weekly, Monthly, Quarterly, Yearly: open, high, low, mid, and the prior period's high, low, and mid
Sessions — Asia, London, New York (windows configurable, in New York time): open, high, low, mid, and prior session levels
Monday Range — high, low, and mid of the week's opening day
Levels sharing the same price within your Merge Threshold collapse into one line with a combined label, so the target reads as a single clean zone even when multiple references agree on it.

[b]⚙️ How it works[/b]
A breakout is confirmed only on a full bar close beyond the range — wicks through the boundary don't count, and nothing repaints intrabar. Detection runs only during the parent session of your selected opening range, so overnight drift through yesterday's levels never produces a false signal.
[b]On a bullish break, the target is the first enabled level above the range high; on a bearish break, the first enabled level below the range low.[/b] 
Levels sitting inside the range are never selected. The target is dynamic: enable or disable level groups and it recalculates to the nearest qualifying level — your level settings are your target settings.
[b]All higher-timeframe and session values are retrieved with non-repainting historical requests. What a historical bar shows is what you would have seen live.[/b]

[b]📈 How to use it[/b]
The default view is built for intraday breakout trading: previous day high/low, Asia and London session extremes, and the Monday range as target candidates, with the New York 30-minute opening range. 
Fewer enabled levels means more meaningful targets — add Weekly or Monthly levels only if you want swing-distance objectives, and expect targets to sit farther away when you do. 
The box color gives a quick bias read before and after the break: sustained bullish fill with price pressing the range high often precedes the upside break, and a break that flips the box back against you is an early warning the move is failing.

[b]Three alerts are included:[/b] bullish breakout, bearish breakout, and target reached — each fires once per session, per direction. Recommended alert setting: "Once per bar close." TradingView shows a standard notice on alerts from close-confirmed scripts; that is expected behavior and the tradeoff for signals that don't repaint.
Session times, range duration (1–120 minutes), colors, line styles, and every level group are independently configurable.

[b]📝 Notes[/b]
A decision-support tool, not a strategy. The target marks where the nearest significant reference sits beyond the break — where price has reacted before, not where it must go. Breakouts fail; targets are objectives, not guarantees. Always apply your own risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AlphaScript

//@version=6
indicator("ORB Breakout Targets | AlphaScript", overlay=true, max_lines_count=500, max_labels_count=500)

// ═══════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════
extBars    = input.int(50,  "Extend Right (bars)", minval=1, maxval=500, group="Display")
mergeTicks = input.int(5,   "Merge Threshold (ticks)", minval=1, maxval=50, tooltip="Prices within this many ticks share one label", group="Display")
showPrice  = input.bool(true, "Show Price on Label", group="Display")
labelSize  = input.string("Normal", "Label Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Display")
lineWidth  = input.int(2, "Line Width", minval=1, maxval=4, group="Display")
lineStyle  = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group="Display")
f_lineStyle(s) =>
    if s == "Dashed"
        line.style_dashed
    else if s == "Dotted"
        line.style_dotted
    else
        line.style_solid
f_labelSize(s) =>
    if s == "Tiny"
        size.tiny
    else if s == "Small"
        size.small
    else if s == "Large"
        size.large
    else if s == "Huge"
        size.huge
    else
        size.normal

// ── 4H ──────────────────────────────────────────────────────
show4HOpen    = input.bool(false, "Open",     inline="4h_row1", group="4H")
show4HHigh    = input.bool(false, "High",     inline="4h_row1", group="4H")
show4HLow     = input.bool(false, "Low",      inline="4h_row1", group="4H")
show4HMid     = input.bool(false, "Mid",      inline="4h_row1", group="4H")
show4HPrevH   = input.bool(false, "Prev H/L", inline="4h_row1", group="4H")
show4HPrevMid = input.bool(false, "Prev Mid", inline="4h_row1", group="4H")
show4HAll     = input.bool(false, "All",      inline="4h_row1", group="4H")
col4H         = input.color(color.new(#FF6B6B, 0), "", inline="4h_row1", group="4H")
show4HOpenEff    = show4HAll ? true : show4HOpen
show4HHighEff    = show4HAll ? true : show4HHigh
show4HLowEff     = show4HAll ? true : show4HLow
show4HMidEff     = show4HAll ? true : show4HMid
show4HPrevHEff   = show4HAll ? true : show4HPrevH
show4HPrevMidEff = show4HAll ? true : show4HPrevMid

// ── Daily ───────────────────────────────────────────────────
showDOpen    = input.bool(false, "Open",     inline="d_row1", group="Daily")
showDHigh    = input.bool(false, "High",     inline="d_row1", group="Daily")
showDLow     = input.bool(false, "Low",      inline="d_row1", group="Daily")
showDMid     = input.bool(false, "Mid",      inline="d_row1", group="Daily")
showDPrevH   = input.bool(true,  "Prev H/L", inline="d_row1", group="Daily")
showDPrevMid = input.bool(false, "Prev Mid", inline="d_row1", group="Daily")
showDAll     = input.bool(false, "All",      inline="d_row1", group="Daily")
colD         = input.color(color.new(#048b0b, 0), "", inline="d_row1", group="Daily")
showDOpenEff    = showDAll ? true : showDOpen
showDHighEff    = showDAll ? true : showDHigh
showDLowEff     = showDAll ? true : showDLow
showDMidEff     = showDAll ? true : showDMid
showDPrevHEff   = showDAll ? true : showDPrevH
showDPrevMidEff = showDAll ? true : showDPrevMid

// ── Monday Range ────────────────────────────────────────────
showMonH   = input.bool(true,  "Range",    inline="mon_row1", group="Monday Range")
showMonMid = input.bool(false, "Mid",      inline="mon_row1", group="Monday Range")
showMonAll = input.bool(false, "All",      inline="mon_row1", group="Monday Range")
colMon     = input.color(color.new(#B0B0B0, 0), "", inline="mon_row1", group="Monday Range")
showMonHEff   = showMonAll ? true : showMonH
showMonMidEff = showMonAll ? true : showMonMid

// ── Weekly ──────────────────────────────────────────────────
showWOpen    = input.bool(false, "Open",     inline="w_row1", group="Weekly")
showWHigh    = input.bool(false, "High",     inline="w_row1", group="Weekly")
showWLow     = input.bool(false, "Low",      inline="w_row1", group="Weekly")
showWMid     = input.bool(false, "Mid",      inline="w_row1", group="Weekly")
showWPrevH   = input.bool(false, "Prev H/L", inline="w_row1", group="Weekly")
showWPrevMid = input.bool(false, "Prev Mid", inline="w_row1", group="Weekly")
showWAll     = input.bool(false, "All",      inline="w_row1", group="Weekly")
colW         = input.color(color.new(#FF4444, 0), "", inline="w_row1", group="Weekly")
showWOpenEff    = showWAll ? true : showWOpen
showWHighEff    = showWAll ? true : showWHigh
showWLowEff     = showWAll ? true : showWLow
showWMidEff     = showWAll ? true : showWMid
showWPrevHEff   = showWAll ? true : showWPrevH
showWPrevMidEff = showWAll ? true : showWPrevMid

// ── Asia Session ────────────────────────────────────────────
showAsiaOpen = input.bool(false, "Open",     inline="asia_row1", group="Asia Session")
showAsiaH    = input.bool(true,  "High",     inline="asia_row1", group="Asia Session")
showAsiaL    = input.bool(true,  "Low",      inline="asia_row1", group="Asia Session")
showAsiaMid  = input.bool(false, "Mid",      inline="asia_row1", group="Asia Session")
showAsiaPrevH   = input.bool(false, "Prev H/L", inline="asia_row1", group="Asia Session")
showAsiaPrevMid = input.bool(false, "Prev Mid", inline="asia_row1", group="Asia Session")
showAsiaAll  = input.bool(false, "All",      inline="asia_row1", group="Asia Session")
colAsia      = input.color(color.new(#00B4D8, 0), "", inline="asia_row1", group="Asia Session")
asiaOpen     = input.session("1700-0000", "Asia Session (New York Time)", group="Asia Session", tooltip="Times are in New York time (America/New_York). Default 17:00–00:00 covers Tokyo open.")
showAsiaOpenEff    = showAsiaAll ? true : showAsiaOpen
showAsiaHEff       = showAsiaAll ? true : showAsiaH
showAsiaLEff       = showAsiaAll ? true : showAsiaL
showAsiaMidEff     = showAsiaAll ? true : showAsiaMid
showAsiaPrevHEff   = showAsiaAll ? true : showAsiaPrevH
showAsiaPrevMidEff = showAsiaAll ? true : showAsiaPrevMid

// ── London Session ──────────────────────────────────────────
showLonOpen = input.bool(false, "Open",     inline="lon_row1", group="London Session")
showLonH    = input.bool(true,  "High",     inline="lon_row1", group="London Session")
showLonL    = input.bool(true,  "Low",      inline="lon_row1", group="London Session")
showLonMid  = input.bool(false, "Mid",      inline="lon_row1", group="London Session")
showLonPrevH   = input.bool(false, "Prev H/L", inline="lon_row1", group="London Session")
showLonPrevMid = input.bool(false, "Prev Mid", inline="lon_row1", group="London Session")
showLonAll  = input.bool(false, "All",      inline="lon_row1", group="London Session")
colLon      = input.color(color.new(#FF9F1C, 0), "", inline="lon_row1", group="London Session")
lonOpen     = input.session("0300-1100", "London Session (New York Time)", group="London Session", tooltip="Times are in New York time (America/New_York). Default 03:00–11:00 = London 08:00–16:00 GMT.")
showLonOpenEff    = showLonAll ? true : showLonOpen
showLonHEff       = showLonAll ? true : showLonH
showLonLEff       = showLonAll ? true : showLonL
showLonMidEff     = showLonAll ? true : showLonMid
showLonPrevHEff   = showLonAll ? true : showLonPrevH
showLonPrevMidEff = showLonAll ? true : showLonPrevMid

// ── New York Session ────────────────────────────────────────
showNYOpen = input.bool(false, "Open",     inline="ny_row1", group="New York Session")
showNYH    = input.bool(false, "High",     inline="ny_row1", group="New York Session")
showNYL    = input.bool(false, "Low",      inline="ny_row1", group="New York Session")
showNYMid  = input.bool(false, "Mid",      inline="ny_row1", group="New York Session")
showNYPrevH   = input.bool(false, "Prev H/L", inline="ny_row1", group="New York Session")
showNYPrevMid = input.bool(false, "Prev Mid", inline="ny_row1", group="New York Session")
showNYAll  = input.bool(false, "All",      inline="ny_row1", group="New York Session")
colNY      = input.color(color.new(#A8DADC, 0), "", inline="ny_row1", group="New York Session")
nyOpen     = input.session("0930-1600", "New York Session (New York Time)", group="New York Session", tooltip="Times are in New York time (America/New_York). Default 09:30–16:00 = NYSE regular hours.")
showNYOpenEff    = showNYAll ? true : showNYOpen
showNYHEff       = showNYAll ? true : showNYH
showNYLEff       = showNYAll ? true : showNYL
showNYMidEff     = showNYAll ? true : showNYMid
showNYPrevHEff   = showNYAll ? true : showNYPrevH
showNYPrevMidEff = showNYAll ? true : showNYPrevMid

// ── Opening Range Block ─────────────────────────────────────
showORB       = input.bool(true,  "Show ORB Box",         group="Opening Range Block")
orbSession    = input.string("New York", "Session", options=["New York", "London", "Asia"], group="Opening Range Block")
orbMins       = input.int(30,     "Range Duration (min)", minval=1, maxval=120, group="Opening Range Block")
colORBBull    = input.color(color.new(#00FF88, 80), "Bull Fill",  inline="orb_colors", group="Opening Range Block")
colORBBear    = input.color(color.new(#FF4444, 80), "Bear Fill",  inline="orb_colors", group="Opening Range Block")
colORBBorder  = input.color(color.new(#FFFFFF, 40), "Border",     inline="orb_colors", group="Opening Range Block")
colORBTarget  = input.color(color.new(#FFD700, 0),  "Target Highlight", group="Opening Range Block", tooltip="The nearest enabled COMPLETED key level beyond a broken range is highlighted in this color as the breakout target. Still-forming session/period highs and lows are never used as targets because they move with price.")
showORBMid    = input.bool(false, "Show ORB Mid Line",    group="Opening Range Block")
showORBLabels = input.bool(false, "Show ORB Labels",      group="Opening Range Block")

// ── Monthly ─────────────────────────────────────────────────
showMOpen    = input.bool(false, "Open",     inline="mo_row1", group="Monthly")
showMHigh    = input.bool(false, "High",     inline="mo_row1", group="Monthly")
showMLow     = input.bool(false, "Low",      inline="mo_row1", group="Monthly")
showMMid     = input.bool(false, "Mid",      inline="mo_row1", group="Monthly")
showMPrevH   = input.bool(false, "Prev H/L", inline="mo_row1", group="Monthly")
showMPrevMid = input.bool(false, "Prev Mid", inline="mo_row1", group="Monthly")
showMAll     = input.bool(false, "All",      inline="mo_row1", group="Monthly")
colM         = input.color(color.new(#4CC9F0, 0), "", inline="mo_row1", group="Monthly")
showMOpenEff    = showMAll ? true : showMOpen
showMHighEff    = showMAll ? true : showMHigh
showMLowEff     = showMAll ? true : showMLow
showMMidEff     = showMAll ? true : showMMid
showMPrevHEff   = showMAll ? true : showMPrevH
showMPrevMidEff = showMAll ? true : showMPrevMid

// ── Quarterly ───────────────────────────────────────────────
showQOpen    = input.bool(false, "Open",     inline="q_row1", group="Quarterly")
showQHigh    = input.bool(false, "High",     inline="q_row1", group="Quarterly")
showQLow     = input.bool(false, "Low",      inline="q_row1", group="Quarterly")
showQMid     = input.bool(false, "Mid",      inline="q_row1", group="Quarterly")
showQPrevH   = input.bool(false, "Prev H/L", inline="q_row1", group="Quarterly")
showQPrevMid = input.bool(false, "Prev Mid", inline="q_row1", group="Quarterly")
showQAll     = input.bool(false, "All",      inline="q_row1", group="Quarterly")
colQ         = input.color(color.new(#F77F00, 0), "", inline="q_row1", group="Quarterly")
showQOpenEff    = showQAll ? true : showQOpen
showQHighEff    = showQAll ? true : showQHigh
showQLowEff     = showQAll ? true : showQLow
showQMidEff     = showQAll ? true : showQMid
showQPrevHEff   = showQAll ? true : showQPrevH
showQPrevMidEff = showQAll ? true : showQPrevMid

// ── Yearly ──────────────────────────────────────────────────
showYOpen    = input.bool(false, "Open",     inline="y_row1", group="Yearly")
showYHigh    = input.bool(false, "High",     inline="y_row1", group="Yearly")
showYLow     = input.bool(false, "Low",      inline="y_row1", group="Yearly")
showYMid     = input.bool(false, "Mid",      inline="y_row1", group="Yearly")
showYPrevH   = input.bool(false, "Prev H/L", inline="y_row1", group="Yearly")
showYPrevMid = input.bool(false, "Prev Mid", inline="y_row1", group="Yearly")
showYAll     = input.bool(false, "All",      inline="y_row1", group="Yearly")
colY         = input.color(color.new(#FF0054, 0), "", inline="y_row1", group="Yearly")
showYOpenEff    = showYAll ? true : showYOpen
showYHighEff    = showYAll ? true : showYHigh
showYLowEff     = showYAll ? true : showYLow
showYMidEff     = showYAll ? true : showYMid
showYPrevHEff   = showYAll ? true : showYPrevH
showYPrevMidEff = showYAll ? true : showYPrevMid

// ═══════════════════════════════════════════════════════════
// SECURITY CALLS
// ═══════════════════════════════════════════════════════════

// 4H
[h4_open, h4_openTime, h4_high, h4_low, h4_currTime, h4_prevH, h4_prevL, h4_prevTime] = request.security(syminfo.tickerid, "240",
    [open, time, high, low, time, high[1], low[1], time[1]],
    lookahead=barmerge.lookahead_off)

// Daily
[d_open, d_openTime, d_high, d_low, d_currTime, d_prevH, d_prevL, d_prevTime] = request.security(syminfo.tickerid, "D",
    [open, time, high, low, time, high[1], low[1], time[1]],
    lookahead=barmerge.lookahead_off)

// Weekly
[w_open, w_openTime, w_high, w_low, w_currTime, w_prevH, w_prevL, w_prevTime] = request.security(syminfo.tickerid, "W",
    [open, time, high, low, time, high[1], low[1], time[1]],
    lookahead=barmerge.lookahead_off)

// Monthly
[mo_open, mo_openTime, mo_high, mo_low, mo_currTime, mo_prevH, mo_prevL, mo_prevTime] = request.security(syminfo.tickerid, "M",
    [open, time, high, low, time, high[1], low[1], time[1]],
    lookahead=barmerge.lookahead_off)

// Quarterly
[q_open, q_openTime, q_high, q_low, q_currTime, q_prevH, q_prevL, q_prevTime] = request.security(syminfo.tickerid, "3M",
    [open, time, high, low, time, high[1], low[1], time[1]],
    lookahead=barmerge.lookahead_off)

// Yearly
[y_open, y_openTime, y_high, y_low, y_currTime, y_prevH, y_prevL, y_prevTime] = request.security(syminfo.tickerid, "12M",
    [open, time, high, low, time, high[1], low[1], time[1]],
    lookahead=barmerge.lookahead_off)

// Monday Range
[day_open, day_high, day_low, day_dow, day_time] = request.security(syminfo.tickerid, "D",
    [open, high, low, dayofweek, time],
    lookahead=barmerge.lookahead_off)

// ═══════════════════════════════════════════════════════════
// SESSION DETECTION
// ═══════════════════════════════════════════════════════════
asiaInSession = not na(time(timeframe.period, asiaOpen, "America/New_York"))
lonInSession  = not na(time(timeframe.period, lonOpen,  "America/New_York"))
nyInSession   = not na(time(timeframe.period, nyOpen,   "America/New_York"))

// ORB session: first N minutes of the selected session
orbBaseHour = orbSession == "New York" ? 9 : orbSession == "London" ? 3 : 18
orbBaseMin  = orbSession == "New York" ? 30 : 0
orbTotalMin = orbBaseHour * 60 + orbBaseMin + orbMins
orbEndHour  = int(orbTotalMin / 60) % 24
orbEndMin   = orbTotalMin % 60
orbSessStr  = (orbBaseHour < 10 ? "0" : "") + str.tostring(orbBaseHour) + (orbBaseMin < 10 ? "0" : "") + str.tostring(orbBaseMin) + "-" + (orbEndHour < 10 ? "0" : "") + str.tostring(orbEndHour) + (orbEndMin < 10 ? "0" : "") + str.tostring(orbEndMin)
orbInSession = not na(time(timeframe.period, orbSessStr, "America/New_York"))

// Parent session of the selected ORB — breakout detection is only valid while this is active
orbParentInSession = orbSession == "New York" ? nyInSession : orbSession == "London" ? lonInSession : asiaInSession

// ═══════════════════════════════════════════════════════════
// OPENING RANGE BLOCK TRACKING
// ═══════════════════════════════════════════════════════════
var float orbH            = na
var float orbL            = na
var int   orbStartTime    = na
var int   orbEndTime      = na
var bool  orbWasIn        = false
var bool  orbFormed       = false
var box   orbBox          = na
var line  orbMidLine      = na
var label orbHighLabel    = na
var label orbLowLabel     = na
var label orbMidLabel     = na
var bool  orbBrokeUp      = false
var bool  orbBrokeDown    = false
var int   orbBreakUpTime  = na
var int   orbBreakDownTime = na
var label orbBreakUpLabel   = na
var label orbBreakDownLabel = na
var float orbTargetUp       = na
var float orbTargetDown     = na
var bool  orbTargetHit      = false

orbJustStarted = orbInSession and not orbWasIn
orbJustEnded   = not orbInSession and orbWasIn

if orbJustStarted
    orbH             := high
    orbL             := low
    orbStartTime     := int(time)
    orbEndTime       := na
    orbFormed        := false
    orbBrokeUp         := false
    orbBrokeDown       := false
    orbBreakUpTime     := na
    orbBreakDownTime   := na
    orbTargetHit       := false
    orbTargetUp        := na
    orbTargetDown      := na
    if not na(orbBreakUpLabel)
        label.delete(orbBreakUpLabel)
        orbBreakUpLabel := na
    if not na(orbBreakDownLabel)
        label.delete(orbBreakDownLabel)
        orbBreakDownLabel := na
else if orbInSession
    orbH := math.max(orbH, high)
    orbL := math.min(orbL, low)

if orbJustEnded
    orbEndTime := int(time)
    orbFormed  := true

orbWasIn := orbInSession

// Breakout detection — only while the ORB's parent session is active (no overnight false signals)
if orbFormed and barstate.isconfirmed and orbParentInSession
    if not orbBrokeUp and close > orbH
        orbBrokeUp      := true
        orbBreakUpTime  := int(time)
        orbBreakUpLabel := label.new(time, low, "ORB ▲",
             xloc      = xloc.bar_time,
             yloc      = yloc.belowbar,
             style     = label.style_triangleup,
             color     = color.new(colORBBull, 0),
             textcolor = color.black,
             size      = f_labelSize(labelSize))
    if not orbBrokeDown and close < orbL
        orbBrokeDown     := true
        orbBreakDownTime := int(time)
        orbBreakDownLabel := label.new(time, high, "ORB ▼",
             xloc      = xloc.bar_time,
             yloc      = yloc.abovebar,
             style     = label.style_triangledown,
             color     = color.new(colORBBear, 0),
             textcolor = color.black,
             size      = f_labelSize(labelSize))

// Draw / update ORB box on every bar (not just barstate.islast) so it extends live
if showORB and orbFormed and not na(orbH) and not na(orbL) and not na(orbStartTime) and not na(orbEndTime)
    float orbMidPrice = (orbH + orbL) / 2
    color orbFill     = close >= orbMidPrice ? colORBBull : colORBBear
    int   drawRight   = time + int(time - time[1]) * extBars

    if na(orbBox)
        orbBox := box.new(
             orbStartTime, orbH, drawRight, orbL,
             xloc        = xloc.bar_time,
             bgcolor     = orbFill,
             border_color = colORBBorder,
             border_width = 1,
             extend      = extend.none)
    else
        box.set_left(orbBox,         orbStartTime)
        box.set_top(orbBox,          orbH)
        box.set_right(orbBox,        drawRight)
        box.set_bottom(orbBox,       orbL)
        box.set_bgcolor(orbBox,      orbFill)
        box.set_border_color(orbBox, colORBBorder)

    if showORBMid
        if na(orbMidLine)
            orbMidLine := line.new(
                 orbStartTime, orbMidPrice, drawRight, orbMidPrice,
                 xloc  = xloc.bar_time,
                 color = colORBBorder,
                 style = line.style_dashed,
                 width = 1)
        else
            line.set_x1(orbMidLine, orbStartTime)
            line.set_y1(orbMidLine, orbMidPrice)
            line.set_x2(orbMidLine, drawRight)
            line.set_y2(orbMidLine, orbMidPrice)
            line.set_color(orbMidLine, colORBBorder)
    else if not na(orbMidLine)
        line.set_color(orbMidLine, color.new(color.white, 100))

    if showORBLabels
        int lblX = drawRight + int(time - time[1])
        if na(orbHighLabel)
            orbHighLabel := label.new(lblX, orbH, "ORB High  " + str.tostring(orbH, format.mintick),
                 xloc=xloc.bar_time, style=label.style_none,
                 textcolor=colORBBorder, color=color.new(color.black, 100),
                 size=f_labelSize(labelSize))
        else
            label.set_x(orbHighLabel,    lblX)
            label.set_y(orbHighLabel,    orbH)
            label.set_text(orbHighLabel, "ORB High  " + str.tostring(orbH, format.mintick))
            label.set_textcolor(orbHighLabel, colORBBorder)
        if na(orbLowLabel)
            orbLowLabel := label.new(lblX, orbL, "ORB Low  " + str.tostring(orbL, format.mintick),
                 xloc=xloc.bar_time, style=label.style_none,
                 textcolor=colORBBorder, color=color.new(color.black, 100),
                 size=f_labelSize(labelSize))
        else
            label.set_x(orbLowLabel,    lblX)
            label.set_y(orbLowLabel,    orbL)
            label.set_text(orbLowLabel, "ORB Low  " + str.tostring(orbL, format.mintick))
            label.set_textcolor(orbLowLabel, colORBBorder)
        if showORBMid
            if na(orbMidLabel)
                orbMidLabel := label.new(lblX, orbMidPrice, "ORB Mid  " + str.tostring(orbMidPrice, format.mintick),
                     xloc=xloc.bar_time, style=label.style_none,
                     textcolor=colORBBorder, color=color.new(color.black, 100),
                     size=f_labelSize(labelSize))
            else
                label.set_x(orbMidLabel,    lblX)
                label.set_y(orbMidLabel,    orbMidPrice)
                label.set_text(orbMidLabel, "ORB Mid  " + str.tostring(orbMidPrice, format.mintick))
                label.set_textcolor(orbMidLabel, colORBBorder)
        else if not na(orbMidLabel)
            label.set_text(orbMidLabel, "")
    else
        if not na(orbHighLabel)
            label.set_text(orbHighLabel, "")
        if not na(orbLowLabel)
            label.set_text(orbLowLabel, "")
        if not na(orbMidLabel)
            label.set_text(orbMidLabel, "")

else if not showORB
    if not na(orbBox)
        box.set_bgcolor(orbBox,      color.new(color.white, 100))
        box.set_border_color(orbBox, color.new(color.white, 100))
    if not na(orbMidLine)
        line.set_color(orbMidLine, color.new(color.white, 100))
    if not na(orbHighLabel)
        label.set_text(orbHighLabel, "")
    if not na(orbLowLabel)
        label.set_text(orbLowLabel, "")
    if not na(orbMidLabel)
        label.set_text(orbMidLabel, "")

// ═══════════════════════════════════════════════════════════
// MONDAY RANGE TRACKING
// ═══════════════════════════════════════════════════════════
var float monH       = na
var float monL       = na
var float monMid     = na
var int   monBarTime = na

if day_dow == dayofweek.monday
    monH       := day_high
    monL       := day_low
    monBarTime := int(day_time)
    monMid     := (not na(day_high) and not na(day_low) and day_high != 0 and day_low != 0) ? (day_high + day_low) / 2 : na

// ═══════════════════════════════════════════════════════════
// ASIA SESSION TRACKING
// ═══════════════════════════════════════════════════════════
var float asiaOpenPrice    = na
var float asiaH            = na
var float asiaL            = na
var float asiaMid          = na
var int   asiaStartBarTime = na
var float asiaPrevH        = na
var float asiaPrevL        = na
var float asiaPrevMid      = na
var int   asiaPrevBarTime  = na
var bool  asiaWasIn        = false

asiaJustStarted = asiaInSession and not asiaWasIn
asiaJustEnded   = not asiaInSession and asiaWasIn

if asiaJustEnded
    asiaMid := (not na(asiaH) and not na(asiaL)) ? (asiaH + asiaL) / 2 : na

if asiaJustStarted
    if not na(asiaH) and not na(asiaL)
        asiaPrevH        := asiaH
        asiaPrevL        := asiaL
        asiaPrevMid      := (asiaH + asiaL) / 2
        asiaPrevBarTime  := asiaStartBarTime
    asiaOpenPrice    := open
    asiaH            := high
    asiaL            := low
    asiaStartBarTime := int(time)
else if asiaInSession
    asiaH   := math.max(asiaH, high)
    asiaL   := math.min(asiaL, low)
    asiaMid := (asiaH + asiaL) / 2

asiaWasIn := asiaInSession

// ═══════════════════════════════════════════════════════════
// LONDON SESSION TRACKING
// ═══════════════════════════════════════════════════════════
var float lonOpenPrice    = na
var float lonH            = na
var float lonL            = na
var float lonMid          = na
var int   lonStartBarTime = na
var float lonPrevH        = na
var float lonPrevL        = na
var float lonPrevMid      = na
var int   lonPrevBarTime  = na
var bool  lonWasIn        = false

lonJustStarted = lonInSession and not lonWasIn
lonJustEnded   = not lonInSession and lonWasIn

if lonJustEnded
    lonMid := (not na(lonH) and not na(lonL)) ? (lonH + lonL) / 2 : na

if lonJustStarted
    if not na(lonH) and not na(lonL)
        lonPrevH        := lonH
        lonPrevL        := lonL
        lonPrevMid      := (lonH + lonL) / 2
        lonPrevBarTime  := lonStartBarTime
    lonOpenPrice    := open
    lonH            := high
    lonL            := low
    lonStartBarTime := int(time)
else if lonInSession
    lonH   := math.max(lonH, high)
    lonL   := math.min(lonL, low)
    lonMid := (lonH + lonL) / 2

lonWasIn := lonInSession

// ═══════════════════════════════════════════════════════════
// NEW YORK SESSION TRACKING
// ═══════════════════════════════════════════════════════════
var float nyOpenPrice    = na
var float nyH            = na
var float nyL            = na
var float nyMid          = na
var int   nyStartBarTime = na
var float nyPrevH        = na
var float nyPrevL        = na
var float nyPrevMid      = na
var int   nyPrevBarTime  = na
var bool  nyWasIn        = false

nyJustStarted = nyInSession and not nyWasIn
nyJustEnded   = not nyInSession and nyWasIn

if nyJustEnded
    nyMid := (not na(nyH) and not na(nyL)) ? (nyH + nyL) / 2 : na

if nyJustStarted
    if not na(nyH) and not na(nyL)
        nyPrevH        := nyH
        nyPrevL        := nyL
        nyPrevMid      := (nyH + nyL) / 2
        nyPrevBarTime  := nyStartBarTime
    nyOpenPrice    := open
    nyH            := high
    nyL            := low
    nyStartBarTime := int(time)
else if nyInSession
    nyH   := math.max(nyH, high)
    nyL   := math.min(nyL, low)
    nyMid := (nyH + nyL) / 2

nyWasIn := nyInSession

// ═══════════════════════════════════════════════════════════
// COMPUTED MIDS
// ═══════════════════════════════════════════════════════════
h4_mid     = (h4_high   != 0 and h4_low   != 0 and not na(h4_high)  and not na(h4_low))  ? (h4_high  + h4_low)  / 2 : na
d_mid      = (d_high    != 0 and d_low    != 0 and not na(d_high)   and not na(d_low))   ? (d_high   + d_low)   / 2 : na
w_mid      = (w_high    != 0 and w_low    != 0 and not na(w_high)   and not na(w_low))   ? (w_high   + w_low)   / 2 : na
mo_mid     = (mo_high   != 0 and mo_low   != 0 and not na(mo_high)  and not na(mo_low))  ? (mo_high  + mo_low)  / 2 : na
q_mid      = (q_high    != 0 and q_low    != 0 and not na(q_high)   and not na(q_low))   ? (q_high   + q_low)   / 2 : na
y_mid      = (y_high    != 0 and y_low    != 0 and not na(y_high)   and not na(y_low))   ? (y_high   + y_low)   / 2 : na
h4_prevMid = (h4_prevH  != 0 and h4_prevL != 0 and not na(h4_prevH) and not na(h4_prevL)) ? (h4_prevH + h4_prevL) / 2 : na
d_prevMid  = (d_prevH   != 0 and d_prevL  != 0 and not na(d_prevH)  and not na(d_prevL))  ? (d_prevH  + d_prevL)  / 2 : na
w_prevMid  = (w_prevH   != 0 and w_prevL  != 0 and not na(w_prevH)  and not na(w_prevL))  ? (w_prevH  + w_prevL)  / 2 : na
mo_prevMid = (mo_prevH  != 0 and mo_prevL != 0 and not na(mo_prevH) and not na(mo_prevL)) ? (mo_prevH + mo_prevL) / 2 : na
q_prevMid  = (q_prevH   != 0 and q_prevL  != 0 and not na(q_prevH)  and not na(q_prevL))  ? (q_prevH  + q_prevL)  / 2 : na
y_prevMid  = (y_prevH   != 0 and y_prevL  != 0 and not na(y_prevH)  and not na(y_prevL))  ? (y_prevH  + y_prevL)  / 2 : na

// ═══════════════════════════════════════════════════════════
// UDTs
// ═══════════════════════════════════════════════════════════
type LevelDef
    float  price
    int    startBarTime
    string tag
    color  col
    bool   enabled

type MergedLevel
    float  price
    int    startBarTime
    string labelText
    color  col
    bool   eligible

// ═══════════════════════════════════════════════════════════
// HELPER FUNCTIONS (global scope)
// ═══════════════════════════════════════════════════════════
// A level is a valid breakout TARGET only if it is COMPLETED (not currently forming).
// - Opens, Prev levels, Monday Range: always static once printed.
// - Session High/Low/Mid: static whenever that session is NOT in progress
//   (a session's high only moves while the session is running).
// - Current 4H/Daily/Weekly/Monthly/Quarterly/Yearly High/Low/Mid: always
//   still forming, never targets.
f_isStaticTag(string t) =>
    if str.contains(t, "Prev") or str.contains(t, "Open") or str.contains(t, "Monday")
        true
    else if t == "Asia High" or t == "Asia Low" or t == "Asia Mid"
        not asiaInSession
    else if t == "London High" or t == "London Low" or t == "London Mid"
        not lonInSession
    else if t == "New York High" or t == "New York Low" or t == "New York Mid"
        not nyInSession
    else
        false

f_filterAndSort(LevelDef[] src) =>
    LevelDef[] out = array.new<LevelDef>()
    for i = 0 to src.size() - 1
        ld = src.get(i)
        if ld.enabled and not na(ld.price) and ld.price != 0 and not na(ld.startBarTime)
            out.push(ld)
    int n = out.size()
    if n > 1
        for pass = 0 to n - 2
            for j = 0 to n - 2 - pass
                a = out.get(j)
                b = out.get(j + 1)
                if a.price > b.price
                    out.set(j, b)
                    out.set(j + 1, a)
    out

f_validateMerged(MergedLevel[] src) =>
    MergedLevel[] out = array.new<MergedLevel>()
    for i = 0 to src.size() - 1
        ml = src.get(i)
        if not na(ml.price) and ml.price != 0 and not na(ml.startBarTime)
            out.push(ml)
    out

// ═══════════════════════════════════════════════════════════
// PERSISTENT LINE / LABEL STORAGE
// ═══════════════════════════════════════════════════════════
var line[]  lvlLines       = array.new<line>()
var label[] lvlLabels      = array.new<label>()
var int     allocatedSlots = 0

// ═══════════════════════════════════════════════════════════
// MAIN DRAWING BLOCK — barstate.islast only
// ═══════════════════════════════════════════════════════════
if barstate.islast

    // ── 1. Build the raw level list ──────────────────────────
    LevelDef[] raw = array.new<LevelDef>()

    // 4H
    if show4HOpen or show4HHigh or show4HLow or show4HMid or show4HPrevH or show4HPrevMid or show4HAll
        raw.push(LevelDef.new(h4_open,    int(h4_openTime), "H4 Open",      col4H, show4HOpenEff))
        raw.push(LevelDef.new(h4_high,    int(h4_currTime), "H4 High",      col4H, show4HHighEff))
        raw.push(LevelDef.new(h4_low,     int(h4_currTime), "H4 Low",       col4H, show4HLowEff))
        raw.push(LevelDef.new(h4_mid,     int(h4_currTime), "H4 Mid",       col4H, show4HMidEff))
        raw.push(LevelDef.new(h4_prevH,   int(h4_prevTime), "H4 Prev High", col4H, show4HPrevHEff))
        raw.push(LevelDef.new(h4_prevL,   int(h4_prevTime), "H4 Prev Low",  col4H, show4HPrevHEff))
        raw.push(LevelDef.new(h4_prevMid, int(h4_prevTime), "H4 Prev Mid",  col4H, show4HPrevMidEff))

    // Daily
    if showDOpen or showDHigh or showDLow or showDMid or showDPrevH or showDPrevMid or showDAll
        raw.push(LevelDef.new(d_open,    int(d_openTime), "Daily Open",      colD, showDOpenEff))
        raw.push(LevelDef.new(d_high,    int(d_currTime), "Daily High",      colD, showDHighEff))
        raw.push(LevelDef.new(d_low,     int(d_currTime), "Daily Low",       colD, showDLowEff))
        raw.push(LevelDef.new(d_mid,     int(d_currTime), "Daily Mid",       colD, showDMidEff))
        raw.push(LevelDef.new(d_prevH,   int(d_prevTime), "Daily Prev High", colD, showDPrevHEff))
        raw.push(LevelDef.new(d_prevL,   int(d_prevTime), "Daily Prev Low",  colD, showDPrevHEff))
        raw.push(LevelDef.new(d_prevMid, int(d_prevTime), "Daily Prev Mid",  colD, showDPrevMidEff))

    // Weekly
    if showWOpen or showWHigh or showWLow or showWMid or showWPrevH or showWPrevMid or showWAll
        raw.push(LevelDef.new(w_open,    int(w_openTime), "Weekly Open",      colW, showWOpenEff))
        raw.push(LevelDef.new(w_high,    int(w_currTime), "Weekly High",      colW, showWHighEff))
        raw.push(LevelDef.new(w_low,     int(w_currTime), "Weekly Low",       colW, showWLowEff))
        raw.push(LevelDef.new(w_mid,     int(w_currTime), "Weekly Mid",       colW, showWMidEff))
        raw.push(LevelDef.new(w_prevH,   int(w_prevTime), "Weekly Prev High", colW, showWPrevHEff))
        raw.push(LevelDef.new(w_prevL,   int(w_prevTime), "Weekly Prev Low",  colW, showWPrevHEff))
        raw.push(LevelDef.new(w_prevMid, int(w_prevTime), "Weekly Prev Mid",  colW, showWPrevMidEff))

    // Monday Range
    if showMonH or showMonMid or showMonAll
        raw.push(LevelDef.new(monH,   monBarTime, "Monday High", colMon, showMonHEff))
        raw.push(LevelDef.new(monL,   monBarTime, "Monday Low",  colMon, showMonHEff))
        raw.push(LevelDef.new(monMid, monBarTime, "Monday Mid",  colMon, showMonMidEff))

    // Asia Session
    if showAsiaOpen or showAsiaH or showAsiaL or showAsiaMid or showAsiaPrevH or showAsiaPrevMid or showAsiaAll
        raw.push(LevelDef.new(asiaOpenPrice, asiaStartBarTime, "Asia Open",      colAsia, showAsiaOpenEff))
        raw.push(LevelDef.new(asiaH,         asiaStartBarTime, "Asia High",      colAsia, showAsiaHEff))
        raw.push(LevelDef.new(asiaL,         asiaStartBarTime, "Asia Low",       colAsia, showAsiaLEff))
        raw.push(LevelDef.new(asiaMid,       asiaStartBarTime, "Asia Mid",       colAsia, showAsiaMidEff))
        raw.push(LevelDef.new(asiaPrevH,     asiaPrevBarTime,  "Asia Prev High", colAsia, showAsiaPrevHEff))
        raw.push(LevelDef.new(asiaPrevL,     asiaPrevBarTime,  "Asia Prev Low",  colAsia, showAsiaPrevHEff))
        raw.push(LevelDef.new(asiaPrevMid,   asiaPrevBarTime,  "Asia Prev Mid",  colAsia, showAsiaPrevMidEff))

    // London Session
    if showLonOpen or showLonH or showLonL or showLonMid or showLonPrevH or showLonPrevMid or showLonAll
        raw.push(LevelDef.new(lonOpenPrice, lonStartBarTime, "London Open",      colLon, showLonOpenEff))
        raw.push(LevelDef.new(lonH,         lonStartBarTime, "London High",      colLon, showLonHEff))
        raw.push(LevelDef.new(lonL,         lonStartBarTime, "London Low",       colLon, showLonLEff))
        raw.push(LevelDef.new(lonMid,       lonStartBarTime, "London Mid",       colLon, showLonMidEff))
        raw.push(LevelDef.new(lonPrevH,     lonPrevBarTime,  "London Prev High", colLon, showLonPrevHEff))
        raw.push(LevelDef.new(lonPrevL,     lonPrevBarTime,  "London Prev Low",  colLon, showLonPrevHEff))
        raw.push(LevelDef.new(lonPrevMid,   lonPrevBarTime,  "London Prev Mid",  colLon, showLonPrevMidEff))

    // New York Session
    if showNYOpen or showNYH or showNYL or showNYMid or showNYPrevH or showNYPrevMid or showNYAll
        raw.push(LevelDef.new(nyOpenPrice, nyStartBarTime, "New York Open",      colNY, showNYOpenEff))
        raw.push(LevelDef.new(nyH,         nyStartBarTime, "New York High",      colNY, showNYHEff))
        raw.push(LevelDef.new(nyL,         nyStartBarTime, "New York Low",       colNY, showNYLEff))
        raw.push(LevelDef.new(nyMid,       nyStartBarTime, "New York Mid",       colNY, showNYMidEff))
        raw.push(LevelDef.new(nyPrevH,     nyPrevBarTime,  "New York Prev High", colNY, showNYPrevHEff))
        raw.push(LevelDef.new(nyPrevL,     nyPrevBarTime,  "New York Prev Low",  colNY, showNYPrevHEff))
        raw.push(LevelDef.new(nyPrevMid,   nyPrevBarTime,  "New York Prev Mid",  colNY, showNYPrevMidEff))

    // Monthly
    if showMOpen or showMHigh or showMLow or showMMid or showMPrevH or showMPrevMid or showMAll
        raw.push(LevelDef.new(mo_open,    int(mo_openTime), "Monthly Open",      colM, showMOpenEff))
        raw.push(LevelDef.new(mo_high,    int(mo_currTime), "Monthly High",      colM, showMHighEff))
        raw.push(LevelDef.new(mo_low,     int(mo_currTime), "Monthly Low",       colM, showMLowEff))
        raw.push(LevelDef.new(mo_mid,     int(mo_currTime), "Monthly Mid",       colM, showMMidEff))
        raw.push(LevelDef.new(mo_prevH,   int(mo_prevTime), "Monthly Prev High", colM, showMPrevHEff))
        raw.push(LevelDef.new(mo_prevL,   int(mo_prevTime), "Monthly Prev Low",  colM, showMPrevHEff))
        raw.push(LevelDef.new(mo_prevMid, int(mo_prevTime), "Monthly Prev Mid",  colM, showMPrevMidEff))

    // Quarterly
    if showQOpen or showQHigh or showQLow or showQMid or showQPrevH or showQPrevMid or showQAll
        raw.push(LevelDef.new(q_open,    int(q_openTime), "Quarterly Open",      colQ, showQOpenEff))
        raw.push(LevelDef.new(q_high,    int(q_currTime), "Quarterly High",      colQ, showQHighEff))
        raw.push(LevelDef.new(q_low,     int(q_currTime), "Quarterly Low",       colQ, showQLowEff))
        raw.push(LevelDef.new(q_mid,     int(q_currTime), "Quarterly Mid",       colQ, showQMidEff))
        raw.push(LevelDef.new(q_prevH,   int(q_prevTime), "Quarterly Prev High", colQ, showQPrevHEff))
        raw.push(LevelDef.new(q_prevL,   int(q_prevTime), "Quarterly Prev Low",  colQ, showQPrevHEff))
        raw.push(LevelDef.new(q_prevMid, int(q_prevTime), "Quarterly Prev Mid",  colQ, showQPrevMidEff))

    // Yearly
    if showYOpen or showYHigh or showYLow or showYMid or showYPrevH or showYPrevMid or showYAll
        raw.push(LevelDef.new(y_open,    int(y_openTime), "Yearly Open",      colY, showYOpenEff))
        raw.push(LevelDef.new(y_high,    int(y_currTime), "Yearly High",      colY, showYHighEff))
        raw.push(LevelDef.new(y_low,     int(y_currTime), "Yearly Low",       colY, showYLowEff))
        raw.push(LevelDef.new(y_mid,     int(y_currTime), "Yearly Mid",       colY, showYMidEff))
        raw.push(LevelDef.new(y_prevH,   int(y_prevTime), "Yearly Prev High", colY, showYPrevHEff))
        raw.push(LevelDef.new(y_prevL,   int(y_prevTime), "Yearly Prev Low",  colY, showYPrevHEff))
        raw.push(LevelDef.new(y_prevMid, int(y_prevTime), "Yearly Prev Mid",  colY, showYPrevMidEff))

    // ── 2+3. Filter valid levels and sort by price ascending ────
    LevelDef[] active = f_filterAndSort(raw)

    // ── 4. Merge duplicates within threshold ──────────────────
    float mergeThresh = syminfo.mintick * mergeTicks

    MergedLevel[] merged = array.new<MergedLevel>()

    int ai = 0
    while ai < active.size()
        LevelDef seed = active.get(ai)
        float   groupPrice   = seed.price
        int     groupBarTime = seed.startBarTime
        string  groupText    = seed.tag
        color   groupCol     = seed.col
        bool    groupElig    = f_isStaticTag(seed.tag)
        int     count        = 1
        int     bi           = ai + 1
        while bi < active.size()
            LevelDef next = active.get(bi)
            if math.abs(next.price - groupPrice) <= mergeThresh
                groupText    := groupText + " / " + next.tag
                groupPrice   := (groupPrice * count + next.price) / (count + 1)
                groupBarTime := math.min(groupBarTime, next.startBarTime)
                groupElig    := groupElig and f_isStaticTag(next.tag)
                count        := count + 1
                bi           := bi + 1
            else
                bi := active.size()
        merged.push(MergedLevel.new(groupPrice, groupBarTime, groupText, groupCol, groupElig))
        ai := ai + count

    // ── 5. Validate merged levels ──
    MergedLevel[] mergedClean = f_validateMerged(merged)

    // ── 5b. Target selection: nearest DISPLAYED completed (static) level beyond the broken range ──
    // The target is chosen only from levels the user has toggled ON — the chart's
    // level map is the target map. Still-forming levels (current session/period
    // H/L/Mid) are excluded even when displayed: they move with price and would
    // drag the target away as price approaches it.
    // The target IS one of the merged levels, so it is highlighted in place.
    int targetUpIdx   = -1
    int targetDownIdx = -1
    orbTargetUp   := na
    orbTargetDown := na
    if mergedClean.size() > 0
        if orbBrokeUp
            for i = 0 to mergedClean.size() - 1
                ml = mergedClean.get(i)
                if ml.price > orbH and targetUpIdx == -1 and ml.eligible
                    targetUpIdx := i
                    orbTargetUp := ml.price
        if orbBrokeDown
            for i = 0 to mergedClean.size() - 1
                ml = mergedClean.get(i)
                if ml.price < orbL and ml.eligible
                    targetDownIdx := i
                    orbTargetDown := ml.price

    int needed = mergedClean.size()
    if allocatedSlots < needed
        int toAdd = needed - allocatedSlots
        for _i = 0 to toAdd - 1
            lvlLines.push(line.new(time, close, time, close,
                xloc=xloc.bar_time, color=color.gray, style=line.style_solid, width=1, extend=extend.none))
            lvlLabels.push(label.new(time, close, "",
                xloc=xloc.bar_time, color=color.new(color.gray, 80), textcolor=color.gray,
                style=label.style_none))
        allocatedSlots := needed

    // Compute right-side time extension purely in bar_index space, then convert to time
    // bar_index is always reliable regardless of timeframe or session gaps
    int rightBarIdx = bar_index + extBars
    int labelBarIdx = bar_index + extBars + 1
    // Convert target bar indices to time using the known current bar's time as anchor
    // Each bar step = (time - time[1]) which is the actual elapsed ms of the last bar
    int msLastBar = bar_index > 0 ? int(time - time[1]) : timeframe.in_seconds() * 1000
    int rightTime = time + (rightBarIdx - bar_index) * msLastBar
    int labelTime = time + (labelBarIdx - bar_index) * msLastBar

    // ── 6. Update visible slots (target level gets highlight styling) ──
    if mergedClean.size() > 0
        for i = 0 to mergedClean.size() - 1
            ml = mergedClean.get(i)
            ln = lvlLines.get(i)
            lb = lvlLabels.get(i)

            bool isTarget = i == targetUpIdx or i == targetDownIdx

            line.set_x1(ln, ml.startBarTime)
            line.set_y1(ln, ml.price)
            line.set_x2(ln, rightTime)
            line.set_y2(ln, ml.price)
            line.set_color(ln, isTarget ? colORBTarget : ml.col)
            line.set_style(ln, f_lineStyle(lineStyle))
            line.set_width(ln, isTarget ? lineWidth + 1 : lineWidth)

            string priceStr = str.tostring(ml.price, format.mintick)
            string labelTxt = ml.labelText
            if showPrice
                labelTxt := labelTxt + "  " + priceStr
            if isTarget
                labelTxt := "🎯 ORB Target ▸ " + labelTxt

            label.set_x(lb, labelTime)
            label.set_y(lb, ml.price)
            label.set_text(lb, labelTxt)
            label.set_color(lb, color.new(color.black, 100))
            label.set_textcolor(lb, isTarget ? colORBTarget : ml.col)
            label.set_style(lb, label.style_none)
            label.set_size(lb, f_labelSize(labelSize))

    // ── 7. Hide unused slots ──────────────────────────────────
    if allocatedSlots > mergedClean.size()
        for i = mergedClean.size() to allocatedSlots - 1
            ln = lvlLines.get(i)
            lb = lvlLabels.get(i)
            line.set_color(ln, color.new(color.white, 100))
            label.set_color(lb, color.new(color.white, 100))
            label.set_textcolor(lb, color.new(color.white, 100))
            label.set_text(lb, "")

// ═══════════════════════════════════════════════════════════
// ALERTS — global scope, fire once per event
// ═══════════════════════════════════════════════════════════
bool orbBreakUpEvent   = orbBrokeUp and not orbBrokeUp[1]
bool orbBreakDownEvent = orbBrokeDown and not orbBrokeDown[1]

bool targetHitEvent = not orbTargetHit and ((orbBrokeUp and not na(orbTargetUp) and high >= orbTargetUp) or (orbBrokeDown and not na(orbTargetDown) and low <= orbTargetDown))
if targetHitEvent
    orbTargetHit := true

alertcondition(orbBreakUpEvent,   "ORB Bullish Breakout", "ORB bullish breakout on {{ticker}} — opening range high broken, close {{close}}")
alertcondition(orbBreakDownEvent, "ORB Bearish Breakout", "ORB bearish breakout on {{ticker}} — opening range low broken, close {{close}}")
alertcondition(targetHitEvent,    "ORB Target Reached",   "ORB key-level target reached on {{ticker}} at {{close}}")
````
