# Liquidity Sweep Hunter & Targets | AlphaScript

- url: https://www.tradingview.com/script/blFAqUQU-Liquidity-Sweep-Hunter-Targets-AlphaScript/
- type: indicator
- pine_id: PUB;8f3a905384494a78b04691fe084ee50b
- version: 1.0

## Description

[b]⚡ Liquidity Sweep Hunter & Targets[/b]
Tracks the High and Low of the Asia and London sessions, tells you exactly what happened to each level, and plots a risk-defined trade framework when a level is swept during the New York session.
[b]This indicator is an upgrade to the :  Session Sweep Detector [/b]

[b]🔍 What it does[/b]
When a session closes, its High and Low become fixed liquidity levels. The indicator draws each level from the exact candle that printed the extreme and watches it until the same session opens again the next day.

[b]Each level resolves in exactly one of three ways:[/b]

[b]⚡ SWEEP —[/b] price wicks through the level but the bar closes back on the original side. A liquidity raid: stops were taken, but the level held on a closing basis.

[b]💥 BREAK —[/b] a bar closes through the level. This is not a sweep, and the indicator never labels it as one. Breaks are displayed separately (and can be hidden) so the two events are never conflated.

[b]🛡️ Untouched —[/b] the level survives its full watch window without either event.
First qualifying event wins: one outcome per level, per session, per day. If a bar both pierces and closes through a level, it counts as a break — a close through the level can never be a sweep.

[b]🎯 NY Sweep Targets[/b]

When a session level is swept during the New York session, the indicator plots a risk-defined framework:
-Entry at the sweep bar's close
-Stop beyond the sweep wick or beyond the swept level (your choice), plus a tick buffer
-Four fully configurable R-multiple targets (default 1R / 1.5R / 2R / 3R)
-Optional risk / reward zone shading

A Low swept = bullish framework (targets above); a High swept = bearish (targets below). The targets are risk-multiple geometry measured from your entry and stop — planning levels for trade management, not predictions of where price will go.

[b]📖 How to read the chart[/b]
-Solid colored lines are session levels, each starting at the candle that actually made the High or Low, so the line points at the liquidity itself.
-Every level line extends to the same right edge, so the name/price labels line up in a clean column.
-When a level is swept or broken, a tag prints at the event bar marking exactly where it happened.
-Previous sessions' levels remain on the chart as reference, with an option to keep or hide their labels.

[b]⚙️ Settings[/b]
-Toggle each level independently (Asia High/Low, London High/Low), with per-session colors and fully configurable session hours (New York time; defaults: Asia 18:00–04:00, London 03:00–12:00).
-Minimum wick penetration filter (in ticks) to ignore marginal pokes when qualifying sweeps. Does not apply to breaks.
-Full control over the target framework: stop anchor, buffer, four R-multiples, line styles, colors, and optional risk/reward fills.
-Control how many previous sessions stay on the chart, whether previous-session labels are shown, and optional transparency for past levels.

[b]🔔 Alerts[/b]
Per-level sweep alerts (Asia High/Low, London High/Low), combined "Any Sweep" and "Any Break" alerts, and an "NY Sweep Setup" alert that fires when a target framework is plotted. All alerts fire on the close of the event bar.

[b]📌 Notes and limitations[/b]
-Designed for intraday timeframes (1 minute to 30 minutes). On higher timeframes, sessions span too few bars for meaningful detection.
-Session times are defined in New York time (America/New_York) and handle the midnight crossover correctly. If you use another session-levels indicator, match the session hours so both tools agree on where the levels are.
-The target framework is a trade-management and planning tool. Entry, stop, and R-targets are geometry based on the sweep — use your own analysis and risk management to decide whether and how to act on a setup.
-Sweep-vs-break classification depends on your chart timeframe: a wick-through-and-reclaim on a 15m bar may resolve as a break on 1m if an intermediate bar closed beyond the level. Neither reading is wrong — they answer different questions.

[b]✅ Why no repaint[/b]
-Events are evaluated on confirmed (closed) bars only. A sweep or break tag will never appear intrabar and then vanish.
-Levels are only armed after their session has fully completed. A session High that is still forming cannot be "swept" — price touching it would simply extend it — so no detection runs until the level is final.
-No request.security() calls are used anywhere. All session tracking is chart-timeframe stat

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AlphaScript

//@version=6

indicator("Liquidity Sweep Hunter & Targets | AlphaScript", overlay = true,
     max_lines_count = 500, max_labels_count = 500, max_boxes_count = 100)

// ═══════════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════════

// ── Display ────────────────────────────────────────────────────────
var string GRP_DISPLAY = "Display"
extBars     = input.int(50, "Extend Levels Right (bars)", minval = 1, maxval = 500, group = GRP_DISPLAY,
     tooltip = "How far every level line projects past the current bar. All levels extend to this same right edge, so their labels line up in a column.")
lineWidth   = input.int(2, "Line Width", minval = 1, maxval = 4, group = GRP_DISPLAY)
lineStyleIn = input.string("Solid", "Line Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_DISPLAY)
showLiveLbl = input.bool(true, "Show Level Labels", group = GRP_DISPLAY,
     tooltip = "Name and price label at the right edge of each level line.")
showPrice   = input.bool(true, "Show Price on Labels", group = GRP_DISPLAY)
labelSizeIn = input.string("Normal", "Level Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = GRP_DISPLAY)

// ── History ────────────────────────────────────────────────────────
var string GRP_HISTORY = "History"
keepSessions = input.int(5, "Previous Sessions to Keep", minval = 0, maxval = 50, group = GRP_HISTORY,
     tooltip = "Past level lines, name labels, and event tags kept on the chart, per level type. 0 = unlimited (oldest drawings drop off at TradingView's 500-object cap).")
showHistLbl  = input.bool(true, "Show Previous Session Labels", group = GRP_HISTORY,
     tooltip = "Keep the name/price label on levels after their watch window ends. Off = past levels show as lines only, no labels.")
histTransp   = input.int(0, "Previous Level Transparency", minval = 0, maxval = 95, group = GRP_HISTORY,
     tooltip = "Extra transparency applied to a level line and its label once its watch window ends. 0 = unchanged.")

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

// ── NY Sweep Targets ───────────────────────────────────────────────
var string GRP_TGT = "NY Sweep Targets"
showTargets = input.bool(true, "Show Targets on NY-Session Sweeps", group = GRP_TGT,
     tooltip = "When a session level is SWEPT during the New York session, plot a trade framework: entry at the sweep bar's close, a stop, and R-multiple targets. A Low swept = bullish framework; a High swept = bearish. Targets are risk-multiple geometry measured from entry and stop — planning levels, not predictions.")
nySess      = input.session("0930-1600", "New York Session (New York Time)", group = GRP_TGT,
     tooltip = "Times are America/New_York. Only sweeps occurring inside this window get a target framework.")

// Stop placement
slMode     = input.string("Wick", "Stop Anchor", options = ["Wick", "Level"], group = GRP_TGT, inline = "sl",
     tooltip = "Wick: stop beyond the sweep bar's wick extreme (the raid low/high). Level: stop beyond the swept level itself (tighter).")
slBufTicks = input.int(2, "+ Buffer (ticks)", minval = 0, maxval = 200, group = GRP_TGT, inline = "sl")

// R-multiple targets — set any to 0 to hide that target
r1 = input.float(1.0, "Target 1 (R)", minval = 0.0, maxval = 50.0, step = 0.25, group = GRP_TGT, inline = "r12")
r2 = input.float(1.5, "Target 2 (R)", minval = 0.0, maxval = 50.0, step = 0.25, group = GRP_TGT, inline = "r12")
r3 = input.float(2.0, "Target 3 (R)", minval = 0.0, maxval = 50.0, step = 0.25, group = GRP_TGT, inline = "r34")
r4 = input.float(3.0, "Target 4 (R)", minval = 0.0, maxval = 50.0, step = 0.25, group = GRP_TGT, inline = "r34")

// Line appearance
showEntryLine = input.bool(true, "Show Entry Line", group = GRP_TGT, inline = "vis")
showSLLine    = input.bool(true, "Show Stop Line",  group = GRP_TGT, inline = "vis")
showTPLines   = input.bool(true, "Show Targets",    group = GRP_TGT, inline = "vis")
tgtStyleIn    = input.string("Dashed", "Target Line Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_TGT, inline = "tstyle")
tgtWidth      = input.int(1, "Width", minval = 1, maxval = 4, group = GRP_TGT, inline = "tstyle")
showRRZones   = input.bool(false, "Fill Risk / Reward Zones", group = GRP_TGT,
     tooltip = "Shade the entry→stop area (risk) and entry→final target area (reward).")

// Framework housekeeping
tgtExtBars = input.int(30, "Extend Setup Right (bars)", minval = 5, maxval = 500, group = GRP_TGT)
keepSetups = input.int(2, "Previous Setups to Keep", minval = 1, maxval = 20, group = GRP_TGT,
     tooltip = "How many past NY-sweep frameworks stay on the chart. Older ones are removed.")
showTgtLbl = input.bool(true, "Show Setup Labels", group = GRP_TGT)
tgtSizeIn  = input.string("Small", "Setup Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = GRP_TGT)
colEntry   = input.color(color.new(#f1f500, 0),  "Entry", inline = "tgtcol", group = GRP_TGT)
colSL      = input.color(color.new(#FF4444, 0),  "Stop",  inline = "tgtcol", group = GRP_TGT)
colTP      = input.color(color.new(#03b420, 0),  "Target",inline = "tgtcol", group = GRP_TGT)
colRisk    = input.color(color.new(#FF4444, 88), "Risk Fill",   inline = "zonecol", group = GRP_TGT)
colReward  = input.color(color.new(#00FF88, 88), "Reward Fill", inline = "zonecol", group = GRP_TGT)

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

// ═══════════════════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════════════════

f_lineStyle(string s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

f_txtSize(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Large" ? size.large : s == "Huge" ? size.huge : size.normal

f_msPerBar() =>
    bar_index > 0 ? int(time - time[1]) : timeframe.in_seconds() * 1000

// ═══════════════════════════════════════════════════════════════════
//  SESSION DETECTION
// ═══════════════════════════════════════════════════════════════════

asiaInSession = not na(time(timeframe.period, asiaSess, "America/New_York"))
lonInSession  = not na(time(timeframe.period, lonSess,  "America/New_York"))
nyInSession   = not na(time(timeframe.period, nySess,   "America/New_York"))

// ═══════════════════════════════════════════════════════════════════
//  NY SWEEP TARGET FRAMEWORK — drawing helpers
//  Entry = sweep bar close. Stop = wick or level ± buffer. Targets
//  are R-multiples of |entry − stop|. Pure geometry — not predictions.
// ═══════════════════════════════════════════════════════════════════

var line[]  tgtLines  = array.new<line>()
var label[] tgtLabels = array.new<label>()
var box[]   tgtZones  = array.new<box>()

f_pruneSetups() =>
    while tgtLines.size() > keepSetups * 6
        line.delete(tgtLines.shift())
    while tgtLabels.size() > keepSetups * 6
        label.delete(tgtLabels.shift())
    while tgtZones.size() > keepSetups * 2
        box.delete(tgtZones.shift())

f_setupLine(float y, int endT, color col, string sty, int w, string txt) =>
    tgtLines.push(line.new(time, y, endT, y, xloc = xloc.bar_time, color = col, style = f_lineStyle(sty), width = w))
    if showTgtLbl
        tgtLabels.push(label.new(endT + f_msPerBar(), y, txt + "  " + str.tostring(y, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.white, 100), textcolor = col, size = f_txtSize(tgtSizeIn)))

f_setupZone(float y1, float y2, int endT, color col) =>
    tgtZones.push(box.new(time, math.max(y1, y2), endT, math.min(y1, y2), xloc = xloc.bar_time, bgcolor = col, border_color = color.new(col, 100)))

f_drawSetup(bool isLong, float entry, float stopExtreme, float levelPrice) =>
    float buf = syminfo.mintick * slBufTicks
    float sl  = slMode == "Level" ? (isLong ? levelPrice - buf : levelPrice + buf) : (isLong ? stopExtreme - buf : stopExtreme + buf)
    float r   = math.abs(entry - sl)
    if r > 0
        int   endT = time + tgtExtBars * f_msPerBar()
        float dir  = isLong ? 1.0 : -1.0
        if showRRZones
            f_setupZone(entry, sl, endT, colRisk)
            float rMax = math.max(math.max(r1, r2), math.max(r3, r4))
            if rMax > 0
                f_setupZone(entry, entry + dir * r * rMax, endT, colReward)
        if showEntryLine
            f_setupLine(entry, endT, colEntry, "Solid", 1, isLong ? "LONG Entry" : "SHORT Entry")
        if showSLLine
            f_setupLine(sl, endT, colSL, "Solid", 1, "SL")
        if showTPLines
            if r1 > 0
                f_setupLine(entry + dir * r * r1, endT, colTP, tgtStyleIn, tgtWidth, str.tostring(r1) + "R")
            if r2 > 0
                f_setupLine(entry + dir * r * r2, endT, colTP, tgtStyleIn, tgtWidth, str.tostring(r2) + "R")
            if r3 > 0
                f_setupLine(entry + dir * r * r3, endT, colTP, tgtStyleIn, tgtWidth, str.tostring(r3) + "R")
            if r4 > 0
                f_setupLine(entry + dir * r * r4, endT, colTP, tgtStyleIn, tgtWidth, str.tostring(r4) + "R")
        f_pruneSetups()

// ═══════════════════════════════════════════════════════════════════
//  SESSION EXTREME TRACKING
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
    string  name
    bool    isHigh
    color   col
    bool    enabled
    float   price     = na
    bool    armed     = false
    bool    resolved  = false
    line    ln        = na
    label   lb        = na
    label   evTag     = na
    bool    sweepNow  = false
    bool    breakNow  = false
    line[]  pastLines = na
    label[] pastTags  = na

method f_prune(SLevel this) =>
    if keepSessions > 0
        while this.pastLines.size() > keepSessions
            line.delete(this.pastLines.shift())
        // Up to two labels archived per session (name + event tag).
        while this.pastTags.size() > keepSessions * 2
            label.delete(this.pastTags.shift())

// Arm the level: line from the extreme bar, plus a name/price label.
method f_arm(SLevel this, float price, int anchorTime) =>
    if this.enabled and not na(price) and not na(anchorTime)
        this.price   := price
        this.armed   := true
        this.ln := line.new(anchorTime, price, time, price, xloc = xloc.bar_time, color = this.col, style = f_lineStyle(lineStyleIn), width = lineWidth)
        if showLiveLbl
            string txt = showPrice ? this.name + "  " + str.tostring(price, format.mintick) : this.name
            this.lb := label.new(time, price, txt, xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.white, 100), textcolor = this.col, size = f_txtSize(labelSizeIn))

// End the watch window: archive the line, and keep or drop the name
// label depending on showHistLbl. Reset live state.
method f_retire(SLevel this) =>
    if this.armed
        if not na(this.ln)
            if histTransp > 0
                line.set_color(this.ln, color.new(this.col, histTransp))
            this.pastLines.push(this.ln)
        if not na(this.lb)
            if showHistLbl
                if histTransp > 0
                    label.set_textcolor(this.lb, color.new(this.col, histTransp))
                this.pastTags.push(this.lb)
            else
                label.delete(this.lb)
        if not na(this.evTag)
            this.pastTags.push(this.evTag)
        this.f_prune()
    this.armed    := false
    this.resolved := false
    this.price    := na
    this.ln       := na
    this.lb       := na
    this.evTag    := na

// Break takes precedence over sweep on the same bar: a close through
// the level can never be a sweep.
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
            if (isSweep and showSweepTags) or (isBreak and showBreakTags)
                float  yPx    = this.isHigh ? high : low
                string txt    = isBreak ? this.name + (this.isHigh ? " BREAK ▲" : " BREAK ▼") : "⚡ " + this.name + " SWEPT"
                color  bgCol  = color.new(isBreak ? colBreak : colSweep, 20)
                color  txtCol = isBreak ? color.black : color.white
                this.evTag := label.new(time, yPx, txt, xloc = xloc.bar_time, yloc = this.isHigh ? yloc.abovebar : yloc.belowbar, style = this.isHigh ? label.style_label_down : label.style_label_up, color = bgCol, textcolor = txtCol, size = f_txtSize(tagSizeIn))

// Every armed level — live OR resolved — extends its line to the SAME
// right edge and pins its label there, so all labels line up in a
// column (ORB style).
method f_draw(SLevel this) =>
    if this.armed and not na(this.ln)
        int msBar     = f_msPerBar()
        int rightEdge = time + extBars * msBar
        line.set_x2(this.ln, rightEdge)
        if not na(this.lb)
            label.set_x(this.lb, rightEdge + msBar)
            label.set_y(this.lb, this.price)

// ── Instances ──────────────────────────────────────────────────────
var SLevel slAsiaH = SLevel.new("Asia High",   true,  colAsia, useAsiaH, pastLines = array.new<line>(), pastTags = array.new<label>())
var SLevel slAsiaL = SLevel.new("Asia Low",    false, colAsia, useAsiaL, pastLines = array.new<line>(), pastTags = array.new<label>())
var SLevel slLonH  = SLevel.new("London High", true,  colLon,  useLonH,  pastLines = array.new<line>(), pastTags = array.new<label>())
var SLevel slLonL  = SLevel.new("London Low",  false, colLon,  useLonL,  pastLines = array.new<line>(), pastTags = array.new<label>())

// ── Lifecycle ──────────────────────────────────────────────────────
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

// ── Detection ──────────────────────────────────────────────────────
slAsiaH.f_check()
slAsiaL.f_check()
slLonH.f_check()
slLonL.f_check()

// ── NY sweep targets (global scope). Low swept = long; High = short.
bool asiaLowNY  = nyInSession and slAsiaL.sweepNow
bool lonLowNY   = nyInSession and slLonL.sweepNow
bool asiaHighNY = nyInSession and slAsiaH.sweepNow
bool lonHighNY  = nyInSession and slLonH.sweepNow
bool lowSweptNY  = asiaLowNY or lonLowNY
bool highSweptNY = asiaHighNY or lonHighNY
bool nySweepSetup = showTargets and (lowSweptNY or highSweptNY)

if showTargets and lowSweptNY
    float lvl = asiaLowNY ? slAsiaL.price : slLonL.price
    f_drawSetup(true, close, low, lvl)
if showTargets and highSweptNY
    float lvl = asiaHighNY ? slAsiaH.price : slLonH.price
    f_drawSetup(false, close, high, lvl)

// ── Drawing ────────────────────────────────────────────────────────
slAsiaH.f_draw()
slAsiaL.f_draw()
slLonH.f_draw()
slLonL.f_draw()

// ═══════════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════════

bool anySweep = slAsiaH.sweepNow or slAsiaL.sweepNow or slLonH.sweepNow or slLonL.sweepNow
bool anyBreak = slAsiaH.breakNow or slAsiaL.breakNow or slLonH.breakNow or slLonL.breakNow

alertcondition(slAsiaH.sweepNow, "Asia High Swept",   "Asia High liquidity swept on {{ticker}} — wick through, close back inside at {{close}}")
alertcondition(slAsiaL.sweepNow, "Asia Low Swept",    "Asia Low liquidity swept on {{ticker}} — wick through, close back inside at {{close}}")
alertcondition(slLonH.sweepNow,  "London High Swept", "London High liquidity swept on {{ticker}} — wick through, close back inside at {{close}}")
alertcondition(slLonL.sweepNow,  "London Low Swept",  "London Low liquidity swept on {{ticker}} — wick through, close back inside at {{close}}")
alertcondition(anySweep,         "Any Session Sweep", "Session level liquidity swept on {{ticker}} at {{close}}")
alertcondition(anyBreak,         "Any Session Break", "Session level broken (close through) on {{ticker}} at {{close}}")
alertcondition(nySweepSetup,     "NY Sweep Setup",    "Session level swept during NY on {{ticker}} — R-target framework plotted, entry {{close}}")
````
