# Session Sweep Detector | AlphaScript

- url: https://www.tradingview.com/script/FIR48npH-Session-Sweep-Detector-AlphaScript/
- type: indicator
- pine_id: PUB;0a9f02729f674dc9b90c56d4762e611c
- version: 1.0

## Description

[b]🎯Session Sweep Detector[/b]
Tracks the High and Low of the Asia and London sessions and tells you exactly what happened to each level — using strict, transparent definitions.

[b]🔍What it does[/b]
When a session closes, its High and Low become fixed liquidity levels. 
This indicator draws each level from the exact candle that printed the extreme and watches it until the same session opens again the next day. 

[b]Each level resolves in exactly one of three ways:[/b]

[b]⚡ SWEEP —[/b] price wicks through the level but the bar closes back on the original side. A liquidity raid: stops were taken, but the level held on a closing basis.

[b]💥BREAK —[/b] a bar closes through the level. This is not a sweep, and the indicator never labels it as one. Breaks are displayed separately (and can be hidden) so the two events are never conflated.

[b]🛡️Untouched —[/b] the level survives its full watch window without either event.
First qualifying event wins: one outcome per level, per session, per day. If a bar both pierces and closes through a level, it counts as a break — a close through the level can never be a sweep.

[b]📖How to read the chart[/b]

-Solid colored lines are session levels. Each line starts at the candle that actually made the High or Low, so the line points at the liquidity itself.

-Live levels (still being watched) project ahead of price with a name and price label.

-After a sweep or break, the tag prints at the event bar and the line continues a configurable number of bars past the event before freezing — so you can see the reaction.

-Levels that were never touched freeze when their watch window ends.

[b]⚙️Settings[/b]

-Toggle each level independently (Asia High/Low, London High/Low), with per-session colors and fully configurable session hours (times in New York time; defaults: Asia 18:00–04:00, London 03:00–12:00).

-Minimum wick penetration filter (in ticks) to ignore marginal pokes when qualifying sweeps. Does not apply to breaks.

-Control how many previous sessions' levels and tags remain on the chart, with optional transparency for past levels.

-Optional Opening Range Block overlay (off by default): draws the opening range of the New York, London, or Asia session with configurable duration, breakout arrows, mid line, and previous-range history. Note: ORB breakout detection and alerts only run while the ORB display is enabled.

[b]🔔Alerts[/b]
Per-level sweep alerts (Asia High/Low, London High/Low), combined "Any Sweep" and "Any Break" alerts, and ORB breakout alerts. All alerts fire on the close of the event bar.

[b]📌 Notes and limitations[/b]

-Designed for intraday timeframes (1 minute to 30 minutes). On higher timeframes, sessions span too few bars for meaningful detection.

-Session times are defined in New York time (America/New_York) and handle the midnight crossover correctly. If you use another session-levels indicator, match the session hours so both tools agree on where the levels are.

-Sweep-vs-break classification depends on your chart timeframe: a wick-through-and-reclaim on a 15m bar may resolve as a break on 1m if an intermediate bar closed beyond the level. Neither reading is wrong — they are answers to different questions — but be aware of it when comparing timeframes.

[b]✅Why no repaint[/b]

-Events are evaluated on confirmed (closed) bars only. A sweep or break tag will never appear intrabar and then vanish.

-Levels are only armed after their session has fully completed. A session High that is still forming cannot be "swept" — price touching it would simply extend it — so no detection runs until the level is final.

-No request.security() calls are used anywhere. All session tracking is chart-timeframe state.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AlphaScript

//@version=6

indicator("Session Sweep Detector | AlphaScript", overlay = true,
     max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ═══════════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════════

// ── Display ────────────────────────────────────────────────────────
var string GRP_DISPLAY = "Display"
extBars     = input.int(50, "Extend Live Levels Right (bars)", minval = 1, maxval = 500, group = GRP_DISPLAY,
     tooltip = "How far live level lines project ahead of the current bar.")
postEvtBars = input.int(10, "Extend After Event (bars)", minval = 0, maxval = 100, group = GRP_DISPLAY,
     tooltip = "After a sweep or break, the level line keeps extending this many bars past the event bar, then freezes.")
lineWidth   = input.int(2, "Line Width", minval = 1, maxval = 4, group = GRP_DISPLAY)
lineStyleIn = input.string("Solid", "Line Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_DISPLAY)
showLiveLbl = input.bool(true, "Show Live Level Labels", group = GRP_DISPLAY,
     tooltip = "Name and price label at the right end of each level currently being watched.")
showPrice   = input.bool(true, "Show Price on Labels", group = GRP_DISPLAY)
labelSizeIn = input.string("Normal", "Level Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = GRP_DISPLAY)

// ── History ────────────────────────────────────────────────────────
var string GRP_HISTORY = "History"
keepSessions = input.int(5, "Previous Sessions to Keep", minval = 0, maxval = 50, group = GRP_HISTORY,
     tooltip = "Past level lines and event tags kept on the chart, per level type. 0 = unlimited (oldest drawings drop off at TradingView's 500-object cap).")
histTransp   = input.int(0, "Previous Level Transparency", minval = 0, maxval = 95, group = GRP_HISTORY,
     tooltip = "Extra transparency applied to a level line once its watch window ends. 0 = unchanged.")

// ── Event Tags ─────────────────────────────────────────────────────
var string GRP_TAGS = "Event Tags"
showSweepTags = input.bool(true, "Show Sweep Tags", group = GRP_TAGS)
showBreakTags = input.bool(true, "Show Break Tags", group = GRP_TAGS,
     tooltip = "A break (close through the level) is not a sweep. Displayed separately so the two are never conflated.")
tagSizeIn     = input.string("Normal", "Tag Text Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = GRP_TAGS)
colSweep      = input.color(color.new(#FF4444, 0), "Sweep", inline = "tagcol", group = GRP_TAGS)
colBreak      = input.color(color.new(#00FF88, 0), "Break", inline = "tagcol", group = GRP_TAGS)

// ── Sweep Logic ────────────────────────────────────────────────────
var string GRP_LOGIC = "Sweep Logic"
minPenTicks = input.int(0, "Min Wick Penetration (ticks)", minval = 0, maxval = 100, group = GRP_LOGIC,
     tooltip = "A wick must pierce the level by at least this many ticks to qualify as a sweep. 0 = any touch beyond the level. Does not apply to breaks — a close through the level is always a break.")

// ── Sessions ───────────────────────────────────────────────────────
var string GRP_ASIA = "Asia Session"
useAsiaH = input.bool(true, "High", inline = "asia", group = GRP_ASIA)
useAsiaL = input.bool(true, "Low",  inline = "asia", group = GRP_ASIA)
colAsia  = input.color(color.new(#00B4D8, 0), "", inline = "asia", group = GRP_ASIA)
asiaSess = input.session("1800-0400", "Session Hours (New York Time)", group = GRP_ASIA,
     tooltip = "Times are America/New_York. Default 18:00–04:00 covers the full Asia session.")

var string GRP_LONDON = "London Session"
useLonH = input.bool(true, "High", inline = "lon", group = GRP_LONDON)
useLonL = input.bool(true, "Low",  inline = "lon", group = GRP_LONDON)
colLon  = input.color(color.new(#FF9F1C, 0), "", inline = "lon", group = GRP_LONDON)
lonSess = input.session("0300-1200", "Session Hours (New York Time)", group = GRP_LONDON,
     tooltip = "Times are America/New_York. Default 03:00–12:00 NY.")

// ── Opening Range Block (optional overlay, off by default) ─────────
var string GRP_ORB = "Opening Range Block"
showORB       = input.bool(false, "Show ORB Box", group = GRP_ORB,
     tooltip = "Draws the opening range of the selected session. ORB breakout detection and alerts only run while this is enabled.")
orbSession    = input.string("New York", "Session", options = ["New York", "London", "Asia"], group = GRP_ORB)
orbMins       = input.int(30, "Range Duration (min)", minval = 1, maxval = 120, group = GRP_ORB)
orbExtBars    = input.int(10, "Extend Right (bars)", minval = 1, maxval = 500, group = GRP_ORB,
     tooltip = "How far the box extends past the END of the opening range. Fixed width once the range completes.")
showPrevORB   = input.bool(false, "Show Previous ORBs", group = GRP_ORB,
     tooltip = "Keep past opening range boxes on the chart instead of deleting them when a new range starts.")
orbKeep       = input.int(5, "Previous ORBs to Keep", minval = 1, maxval = 50, group = GRP_ORB)
colORBBull    = input.color(color.new(#00FF88, 80), "Bull",   inline = "orbcol", group = GRP_ORB)
colORBBear    = input.color(color.new(#FF4444, 80), "Bear",   inline = "orbcol", group = GRP_ORB)
colORBBorder  = input.color(color.new(#FFFFFF, 40), "Border", inline = "orbcol", group = GRP_ORB)
showORBMid    = input.bool(false, "Show Mid Line", group = GRP_ORB)
showORBLabels = input.bool(false, "Show High/Low Labels", group = GRP_ORB)
showORBBreaks = input.bool(true,  "Show Breakout Arrows", group = GRP_ORB)

// ═══════════════════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════════════════

f_lineStyle(string s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

f_txtSize(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Large" ? size.large : s == "Huge" ? size.huge : size.normal

// Milliseconds per chart bar, derived from the last completed bar.
f_msPerBar() =>
    bar_index > 0 ? int(time - time[1]) : timeframe.in_seconds() * 1000

// ═══════════════════════════════════════════════════════════════════
//  SESSION DETECTION
// ═══════════════════════════════════════════════════════════════════

asiaInSession = not na(time(timeframe.period, asiaSess, "America/New_York"))
lonInSession  = not na(time(timeframe.period, lonSess,  "America/New_York"))

// ═══════════════════════════════════════════════════════════════════
//  SESSION EXTREME TRACKING
//  Records each session's High/Low AND the time of the bar that
//  printed it, so level lines can anchor at the exact extreme candle.
// ═══════════════════════════════════════════════════════════════════

// ── Asia ───────────────────────────────────────────────────────────
var float asiaH     = na
var float asiaL     = na
var int   asiaHTime = na
var int   asiaLTime = na
var bool  asiaWasIn = false

asiaJustStarted = asiaInSession and not asiaWasIn
asiaJustEnded   = not asiaInSession and asiaWasIn

if asiaJustStarted
    asiaH     := high
    asiaL     := low
    asiaHTime := int(time)
    asiaLTime := int(time)
else if asiaInSession
    if high >= asiaH
        asiaH     := high
        asiaHTime := int(time)
    if low <= asiaL
        asiaL     := low
        asiaLTime := int(time)

asiaWasIn := asiaInSession

// ── London ─────────────────────────────────────────────────────────
var float lonH     = na
var float lonL     = na
var int   lonHTime = na
var int   lonLTime = na
var bool  lonWasIn = false

lonJustStarted = lonInSession and not lonWasIn
lonJustEnded   = not lonInSession and lonWasIn

if lonJustStarted
    lonH     := high
    lonL     := low
    lonHTime := int(time)
    lonLTime := int(time)
else if lonInSession
    if high >= lonH
        lonH     := high
        lonHTime := int(time)
    if low <= lonL
        lonL     := low
        lonLTime := int(time)

lonWasIn := lonInSession

// ═══════════════════════════════════════════════════════════════════
//  SWEEP LEVELS
// ═══════════════════════════════════════════════════════════════════

type SLevel
    // identity
    string  name
    bool    isHigh
    color   col
    bool    enabled
    // live state
    float   price     = na
    bool    armed     = false
    bool    resolved  = false
    int     postEvt   = 0
    line    ln        = na
    label   lb        = na
    label   evTag     = na
    // per-bar event flags for alertcondition()
    bool    sweepNow  = false
    bool    breakNow  = false
    // rolling history of retired drawings
    line[]  pastLines = na
    label[] pastTags  = na

// Remove the oldest history entries beyond the configured limit.
method f_prune(SLevel this) =>
    if keepSessions > 0
        while this.pastLines.size() > keepSessions
            line.delete(this.pastLines.shift())
        while this.pastTags.size() > keepSessions
            label.delete(this.pastTags.shift())

// Arm the level with a line anchored at the bar that set the extreme.
method f_arm(SLevel this, float price, int anchorTime) =>
    if this.enabled and not na(price) and not na(anchorTime)
        this.price   := price
        this.armed   := true
        this.postEvt := 0
        this.ln := line.new(anchorTime, price, time, price, xloc = xloc.bar_time, color = this.col, style = f_lineStyle(lineStyleIn), width = lineWidth)
        if showLiveLbl
            this.lb := label.new(time, price, "", xloc = xloc.bar_time, style = label.style_none, color = color.new(color.black, 100), textcolor = this.col, size = f_txtSize(labelSizeIn))

// End the watch window: archive the line and tag, reset live state.
method f_retire(SLevel this) =>
    if this.armed
        if not na(this.lb)
            label.delete(this.lb)
        if not na(this.ln)
            if not this.resolved
                line.set_x2(this.ln, time)
            if histTransp > 0
                line.set_color(this.ln, color.new(this.col, histTransp))
            this.pastLines.push(this.ln)
        if not na(this.evTag)
            this.pastTags.push(this.evTag)
        this.f_prune()
    this.armed    := false
    this.resolved := false
    this.postEvt  := 0
    this.price    := na
    this.ln       := na
    this.lb       := na
    this.evTag    := na

// Evaluate the level on the current confirmed bar.
// Break takes precedence over sweep when both occur on the same bar:
// a close through the level can never be a sweep.
method f_check(SLevel this) =>
    this.sweepNow := false
    this.breakNow := false
    if this.armed and not this.resolved and barstate.isconfirmed
        float minPen       = syminfo.mintick * minPenTicks
        bool  closedBeyond = this.isHigh ? close > this.price : close < this.price
        bool  pierced      = this.isHigh ? high >= this.price + minPen : low <= this.price - minPen
        bool  isBreak      = closedBeyond
        bool  isSweep      = not closedBeyond and pierced
        if isBreak or isSweep
            this.resolved := true
            this.breakNow := isBreak
            this.sweepNow := isSweep
            this.postEvt  := 0
            line.set_x2(this.ln, time)
            if not na(this.lb)
                label.delete(this.lb)
                this.lb := na
            if (isSweep and showSweepTags) or (isBreak and showBreakTags)
                float  yPx    = this.isHigh ? high : low
                string txt    = isBreak ? this.name + (this.isHigh ? " BREAK ▲" : " BREAK ▼") : "⚡ " + this.name + " SWEPT"
                color  bgCol  = color.new(isBreak ? colBreak : colSweep, 20)
                color  txtCol = isBreak ? color.black : color.white
                this.evTag := label.new(time, yPx, txt, xloc = xloc.bar_time, yloc = this.isHigh ? yloc.abovebar : yloc.belowbar, style = this.isHigh ? label.style_label_down : label.style_label_up, color = bgCol, textcolor = txtCol, size = f_txtSize(tagSizeIn))

// Draw the level. Live levels project ahead of price with a label;
// resolved levels trail the current bar for postEvtBars, then freeze.
method f_draw(SLevel this) =>
    if this.armed and not na(this.ln)
        if not this.resolved
            int msBar = f_msPerBar()
            line.set_x2(this.ln, time + extBars * msBar)
            if not na(this.lb)
                string txt = showPrice ? this.name + "  " + str.tostring(this.price, format.mintick) : this.name
                label.set_x(this.lb, time + (extBars + 1) * msBar)
                label.set_y(this.lb, this.price)
                label.set_text(this.lb, txt)
        else if this.postEvt < postEvtBars
            this.postEvt += 1
            line.set_x2(this.ln, time)

// ── Instances ──────────────────────────────────────────────────────
var SLevel slAsiaH = SLevel.new("Asia High",   true,  colAsia, useAsiaH, pastLines = array.new<line>(), pastTags = array.new<label>())
var SLevel slAsiaL = SLevel.new("Asia Low",    false, colAsia, useAsiaL, pastLines = array.new<line>(), pastTags = array.new<label>())
var SLevel slLonH  = SLevel.new("London High", true,  colLon,  useLonH,  pastLines = array.new<line>(), pastTags = array.new<label>())
var SLevel slLonL  = SLevel.new("London Low",  false, colLon,  useLonL,  pastLines = array.new<line>(), pastTags = array.new<label>())

// ── Lifecycle: retire on session open, arm on session close ────────
if asiaJustStarted
    slAsiaH.f_retire()
    slAsiaL.f_retire()
if asiaJustEnded
    slAsiaH.f_arm(asiaH, asiaHTime)
    slAsiaL.f_arm(asiaL, asiaLTime)

if lonJustStarted
    slLonH.f_retire()
    slLonL.f_retire()
if lonJustEnded
    slLonH.f_arm(lonH, lonHTime)
    slLonL.f_arm(lonL, lonLTime)

// ── Detection + drawing ────────────────────────────────────────────
slAsiaH.f_check()
slAsiaL.f_check()
slLonH.f_check()
slLonL.f_check()

slAsiaH.f_draw()
slAsiaL.f_draw()
slLonH.f_draw()
slLonL.f_draw()

// ═══════════════════════════════════════════════════════════════════
//  OPENING RANGE BLOCK (optional overlay)
//  The opening range = first orbMins minutes of the selected session.
//  Tracking runs on every bar so enabling mid-session shows a correct
//  box immediately; drawing and breakout detection are display-gated.
// ═══════════════════════════════════════════════════════════════════

// First N minutes of the selected session, as a session string.
orbBaseHour  = orbSession == "New York" ? 9 : orbSession == "London" ? 3 : 18
orbBaseMin   = orbSession == "New York" ? 30 : 0
orbTotalMin  = orbBaseHour * 60 + orbBaseMin + orbMins
orbSessStr   = str.format("{0,number,00}{1,number,00}-{2,number,00}{3,number,00}", orbBaseHour, orbBaseMin, int(orbTotalMin / 60) % 24, orbTotalMin % 60)
orbInSession = not na(time(timeframe.period, orbSessStr, "America/New_York"))

// Breakouts are only valid while the ORB's parent session is active.
nyParentInSession  = not na(time(timeframe.period, "0930-1600", "America/New_York"))
orbParentInSession = orbSession == "New York" ? nyParentInSession : orbSession == "London" ? lonInSession : asiaInSession

var float orbH              = na
var float orbL              = na
var int   orbStartTime      = na
var int   orbEndTime        = na
var bool  orbWasIn          = false
var bool  orbFormed         = false
var bool  orbBrokeUp        = false
var bool  orbBrokeDown      = false
var box   orbBox            = na
var line  orbMidLine        = na
var label orbHighLabel      = na
var label orbLowLabel       = na
var label orbMidLabel       = na
var label orbBreakUpLabel   = na
var label orbBreakDownLabel = na

// Rolling history of previous ORBs (arrows: up to two per box).
var box[]   pastORBBoxes  = array.new<box>()
var line[]  pastORBMids   = array.new<line>()
var label[] pastORBArrows = array.new<label>()

f_pruneORBs() =>
    while pastORBBoxes.size() > orbKeep
        box.delete(pastORBBoxes.shift())
    while pastORBMids.size() > orbKeep
        line.delete(pastORBMids.shift())
    while pastORBArrows.size() > orbKeep * 2
        label.delete(pastORBArrows.shift())

orbJustStarted = orbInSession and not orbWasIn
orbJustEnded   = not orbInSession and orbWasIn

if orbJustStarted
    // Archive or discard the previous range's drawings.
    if showPrevORB
        int frozenRight = int(math.min(orbEndTime + orbExtBars * f_msPerBar(), time))
        if not na(orbBox)
            box.set_right(orbBox, frozenRight)
            pastORBBoxes.push(orbBox)
        if not na(orbMidLine)
            line.set_x2(orbMidLine, frozenRight)
            pastORBMids.push(orbMidLine)
        if not na(orbBreakUpLabel)
            pastORBArrows.push(orbBreakUpLabel)
        if not na(orbBreakDownLabel)
            pastORBArrows.push(orbBreakDownLabel)
        f_pruneORBs()
    else
        box.delete(orbBox)
        line.delete(orbMidLine)
        label.delete(orbBreakUpLabel)
        label.delete(orbBreakDownLabel)
    orbBox            := na
    orbMidLine        := na
    orbBreakUpLabel   := na
    orbBreakDownLabel := na
    // Begin tracking the new range.
    orbH         := high
    orbL         := low
    orbStartTime := int(time)
    orbEndTime   := na
    orbFormed    := false
    orbBrokeUp   := false
    orbBrokeDown := false
else if orbInSession
    orbH := math.max(orbH, high)
    orbL := math.min(orbL, low)

if orbJustEnded
    orbEndTime := int(time)
    orbFormed  := true

orbWasIn := orbInSession

// ── Breakout detection (confirmed bars, parent session only) ───────
if showORB and orbFormed and barstate.isconfirmed and orbParentInSession
    if not orbBrokeUp and close > orbH
        orbBrokeUp := true
        if showORBBreaks
            orbBreakUpLabel := label.new(time, low, "ORB ▲", xloc = xloc.bar_time, yloc = yloc.belowbar, style = label.style_triangleup, color = color.new(colORBBull, 0), textcolor = color.black, size = f_txtSize(labelSizeIn))
    if not orbBrokeDown and close < orbL
        orbBrokeDown := true
        if showORBBreaks
            orbBreakDownLabel := label.new(time, high, "ORB ▼", xloc = xloc.bar_time, yloc = yloc.abovebar, style = label.style_triangledown, color = color.new(colORBBear, 0), textcolor = color.black, size = f_txtSize(labelSizeIn))

// ── Box drawing: fixed width from range start to extBars past end ──
if showORB and orbFormed and not na(orbH) and not na(orbL) and not na(orbStartTime) and not na(orbEndTime)
    float orbMid    = (orbH + orbL) / 2
    color orbFill   = close >= orbMid ? colORBBull : colORBBear
    int   msBar     = f_msPerBar()
    int   drawRight = orbEndTime + orbExtBars * msBar

    if na(orbBox)
        orbBox := box.new(orbStartTime, orbH, drawRight, orbL, xloc = xloc.bar_time, bgcolor = orbFill, border_color = colORBBorder, border_width = 1, extend = extend.none)
    else
        box.set_lefttop(orbBox, orbStartTime, orbH)
        box.set_rightbottom(orbBox, drawRight, orbL)
        box.set_bgcolor(orbBox, orbFill)
        box.set_border_color(orbBox, colORBBorder)

    if showORBMid
        if na(orbMidLine)
            orbMidLine := line.new(orbStartTime, orbMid, drawRight, orbMid, xloc = xloc.bar_time, color = colORBBorder, style = line.style_dashed, width = 1)
        else
            line.set_xy1(orbMidLine, orbStartTime, orbMid)
            line.set_xy2(orbMidLine, drawRight, orbMid)
            line.set_color(orbMidLine, colORBBorder)
    else if not na(orbMidLine)
        line.set_color(orbMidLine, color.new(color.white, 100))

    if showORBLabels
        int lblX = drawRight + msBar
        string highTxt = "ORB High  " + str.tostring(orbH, format.mintick)
        string lowTxt  = "ORB Low  "  + str.tostring(orbL, format.mintick)
        string midTxt  = "ORB Mid  "  + str.tostring(orbMid, format.mintick)
        if na(orbHighLabel)
            orbHighLabel := label.new(lblX, orbH, highTxt, xloc = xloc.bar_time, style = label.style_none, textcolor = colORBBorder, color = color.new(color.black, 100), size = f_txtSize(labelSizeIn))
        else
            label.set_x(orbHighLabel, lblX)
            label.set_y(orbHighLabel, orbH)
            label.set_text(orbHighLabel, highTxt)
            label.set_textcolor(orbHighLabel, colORBBorder)
        if na(orbLowLabel)
            orbLowLabel := label.new(lblX, orbL, lowTxt, xloc = xloc.bar_time, style = label.style_none, textcolor = colORBBorder, color = color.new(color.black, 100), size = f_txtSize(labelSizeIn))
        else
            label.set_x(orbLowLabel, lblX)
            label.set_y(orbLowLabel, orbL)
            label.set_text(orbLowLabel, lowTxt)
            label.set_textcolor(orbLowLabel, colORBBorder)
        if showORBMid
            if na(orbMidLabel)
                orbMidLabel := label.new(lblX, orbMid, midTxt, xloc = xloc.bar_time, style = label.style_none, textcolor = colORBBorder, color = color.new(color.black, 100), size = f_txtSize(labelSizeIn))
            else
                label.set_x(orbMidLabel, lblX)
                label.set_y(orbMidLabel, orbMid)
                label.set_text(orbMidLabel, midTxt)
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
    // Hide (not delete) so re-enabling restores instantly.
    if not na(orbBox)
        box.set_bgcolor(orbBox, color.new(color.white, 100))
        box.set_border_color(orbBox, color.new(color.white, 100))
    if not na(orbMidLine)
        line.set_color(orbMidLine, color.new(color.white, 100))
    if not na(orbHighLabel)
        label.set_text(orbHighLabel, "")
    if not na(orbLowLabel)
        label.set_text(orbLowLabel, "")
    if not na(orbMidLabel)
        label.set_text(orbMidLabel, "")

// ═══════════════════════════════════════════════════════════════════
//  ALERTS — one alert per event, fired on the confirmed event bar
// ═══════════════════════════════════════════════════════════════════

bool anySweep          = slAsiaH.sweepNow or slAsiaL.sweepNow or slLonH.sweepNow or slLonL.sweepNow
bool anyBreak          = slAsiaH.breakNow or slAsiaL.breakNow or slLonH.breakNow or slLonL.breakNow
bool orbBreakUpEvent   = orbBrokeUp and not orbBrokeUp[1]
bool orbBreakDownEvent = orbBrokeDown and not orbBrokeDown[1]

alertcondition(slAsiaH.sweepNow, "Asia High Swept",      "Asia High liquidity swept on {{ticker}} — wick through, close back inside at {{close}}")
alertcondition(slAsiaL.sweepNow, "Asia Low Swept",       "Asia Low liquidity swept on {{ticker}} — wick through, close back inside at {{close}}")
alertcondition(slLonH.sweepNow,  "London High Swept",    "London High liquidity swept on {{ticker}} — wick through, close back inside at {{close}}")
alertcondition(slLonL.sweepNow,  "London Low Swept",     "London Low liquidity swept on {{ticker}} — wick through, close back inside at {{close}}")
alertcondition(anySweep,         "Any Session Sweep",    "Session level liquidity swept on {{ticker}} at {{close}}")
alertcondition(anyBreak,         "Any Session Break",    "Session level broken (close through) on {{ticker}} at {{close}}")
alertcondition(orbBreakUpEvent,   "ORB Bullish Breakout", "ORB bullish breakout on {{ticker}} — opening range high broken, close {{close}}")
alertcondition(orbBreakDownEvent, "ORB Bearish Breakout", "ORB bearish breakout on {{ticker}} — opening range low broken, close {{close}}")
````
