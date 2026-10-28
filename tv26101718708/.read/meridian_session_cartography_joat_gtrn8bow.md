# Meridian Session Cartography [JOAT]

- url: https://www.tradingview.com/script/gTrn8boW-Meridian-Session-Cartography-JOAT/
- type: indicator
- pine_id: PUB;f0472b69ac824095a47645e90e48b59f
- version: 1.0

## Description

[b]Meridian Session Cartography [JOAT][/b]

[b]Introduction[/b]

Meridian Session Cartography is an open-source session-structure overlay designed to map intraday market geography through Asia, London, New York, and one fully custom session. The indicator tracks each session's developing high, low, open, midpoint, previous-day references, and confirmed liquidity sweeps, then organizes those references into a clean institutional chart layout.

The problem Meridian solves is session context. Many intraday decisions fail not because the setup is invalid, but because the trader is reading a local move without understanding which session created the range, where the day is trading relative to prior-day references, and whether liquidity has already been swept. Meridian turns that information into a persistent map.

[image]https://www.tradingview.com/x/31tdmEtY/[/image]

[b]Core Concepts[/b]

[b]1. Timezone-Safe Session Tracking[/b]

Each session is evaluated through explicit session windows and a user-selected timezone, allowing the script to adapt to regional workflows without hard-coding exchange assumptions.

[pine]
f_inSession(string sess, string tz) =>
    not na(time(timeframe.period, sess, tz))
[/pine]

[b]2. Session Range Construction[/b]

Every active session continuously updates its high, low, midpoint, and opening price. These references remain actionable because they are tied to actual session development instead of static preset levels.

[b]3. Previous-Day Reference Logic[/b]

Previous-day high, low, open, and close are requested from the daily context using non-lookahead calls. These levels frame the broader day structure around which the active session range is operating.

[b]4. Confirmed Sweep Detection[/b]

The indicator identifies confirmed buy-side and sell-side sweeps around tracked extremes, helping the user recognize when a session has already consumed nearby liquidity.

[b]5. Managed Object Layout[/b]

Boxes, lines, and labels are retained through capped arrays and automatically cleaned to avoid chart clutter and object-budget drift.

[b]Features[/b]

[list]
[*][b]Four configurable session blocks:[/b] Asia, London, New York, and one custom session
[*][b]Range geometry:[/b] High, low, midpoint, and opening references for each session
[*][b]Previous-day levels:[/b] Prior day high, low, open, and close included in the same framework
[*][b]Confirmed sweep logic:[/b] Liquidity sweep status updates only after bar confirmation
[*][b]Reference-level extension:[/b] Session levels can project forward for practical intraday use
[*][b]Chart-cleaning controls:[/b] Managed limits for labels, boxes, and lines
[*][b]Top-right dashboard:[/b] Active session, day range, sweep status, and nearest level are summarized continuously
[/list]

[b]Input Parameters[/b]

[b]Core:[/b]
[list]
[*]Timezone
[*]Active Days To Retain
[*]Level Extend Bars
[*]Max Session Objects
[/list]

[b]Per-Session Blocks:[/b]
[list]
[*]Show Session toggle
[*]Session window
[*]Bull and bear colors
[*]Range fill color
[/list]

[b]Levels and Display:[/b]
[list]
[*]Show Previous Day Levels
[*]Show Opens
[*]Show Midpoints
[*]Show Range Zones
[*]Show Sweep Labels
[*]Show Candle Tint
[*]Dashboard position and size
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Identify the active session[/b]
Use the dashboard to confirm which session currently governs price. This gives immediate context for interpreting local range behavior.

[b]Step 2: Compare the active session to the day[/b]
Check the relationship between the active session range and previous-day high/low. This helps distinguish local noise from meaningful day-level expansion.

[b]Step 3: Monitor midpoint and open behavior[/b]
Session midpoints and opens often act as practical mean-reversion or continuation checkpoints during intraday trading.

[b]Step 4: Watch sweep status before fading or chasing[/b]
If the session has already swept one side of liquidity, that changes the quality of any breakout or reversal idea built near the same reference.

[b]Indicator Limitations[/b]

[list]
[*]Session-based indicators are highly sensitive to the chosen timezone and should be configured intentionally
[*]Sweep detection confirms after the bar closes, which is deliberate non-repainting behavior
[*]Very low-liquidity markets can produce irregular session geometry
[*]The script maps context and liquidity behavior; it does not generate full trade plans by itself
[/list]

[b]Originality Statement[/b]

Meridian Session Cartography is original in the way it combines timezone-safe multi-session mapping, previous-day references, midpoint and open logic, confirmed sweep detection, and managed chart-object cleanup into one publication-ready intraday overlay. It is not a simple session shading script or a basic high/low plotter.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Session levels and sweep readings are contextual tools and can fail in volatile or atypical conditions. Trading involves risk, including the risk of loss.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Meridian Session Cartography [JOAT]", shorttitle="MSC [JOAT]", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=200)

// Meridian Session Cartography [JOAT]
// Institutional session map for configurable Asia, London, New York, and custom sessions.
// The script tracks range boundaries, previous-day references, current session open/midpoint,
// and confirmed liquidity sweeps without repainting.

string g_core   = "Core"
string g_style  = "Style"
string g_asia   = "Asia Session"
string g_london = "London Session"
string g_ny     = "New York Session"
string g_custom = "Custom Session"
string g_levels = "Levels"
string g_dash   = "Dashboard"

string tzInput = input.string("America/New_York", "Timezone", options=["Etc/UTC", "America/New_York", "America/Chicago", "America/Los_Angeles", "Europe/London", "Europe/Berlin", "Europe/Paris", "Europe/Vienna", "Asia/Tokyo", "Asia/Hong_Kong", "Asia/Singapore", "Australia/Sydney"], group=g_core)
int lookbackDays = input.int(10, "Active Days To Retain", minval=1, maxval=60, group=g_core)
int levelExtendBars = input.int(80, "Level Extend Bars", minval=10, maxval=500, group=g_core)
int maxSessionsKept = input.int(8, "Max Session Objects", minval=3, maxval=20, group=g_core)

bool showAsia = input.bool(true, "Show Asia", group=g_asia)
string asiaSession = input.session("1900-2359", "Session", group=g_asia)
color asiaUp = input.color(color.rgb(38, 208, 124), "Bull Color", group=g_asia, inline="a")
color asiaDn = input.color(color.rgb(21, 115, 78), "Bear Color", group=g_asia, inline="a")
color asiaFill = input.color(color.new(color.rgb(38, 208, 124), 88), "Fill", group=g_asia)

bool showLondon = input.bool(true, "Show London", group=g_london)
string londonSession = input.session("0200-0500", "Session", group=g_london)
color londonUp = input.color(color.rgb(76, 163, 255), "Bull Color", group=g_london, inline="l")
color londonDn = input.color(color.rgb(18, 81, 158), "Bear Color", group=g_london, inline="l")
color londonFill = input.color(color.new(color.rgb(76, 163, 255), 88), "Fill", group=g_london)

bool showNY = input.bool(true, "Show New York", group=g_ny)
string nySession = input.session("0830-1130", "Session", group=g_ny)
color nyUp = input.color(color.rgb(255, 146, 66), "Bull Color", group=g_ny, inline="n")
color nyDn = input.color(color.rgb(168, 82, 20), "Bear Color", group=g_ny, inline="n")
color nyFill = input.color(color.new(color.rgb(255, 146, 66), 88), "Fill", group=g_ny)

bool showCustom = input.bool(false, "Show Custom", group=g_custom)
string customSession = input.session("1300-1700", "Session", group=g_custom)
color customUp = input.color(color.rgb(181, 122, 255), "Bull Color", group=g_custom, inline="c")
color customDn = input.color(color.rgb(108, 49, 170), "Bear Color", group=g_custom, inline="c")
color customFill = input.color(color.new(color.rgb(181, 122, 255), 88), "Fill", group=g_custom)

bool showPrevDay = input.bool(true, "Show Previous Day High/Low", group=g_levels)
bool showOpens = input.bool(true, "Show Session Opens", group=g_levels)
bool showMidpoints = input.bool(true, "Show Session Midpoints", group=g_levels)
bool showRangeZones = input.bool(true, "Show Range Zones", group=g_levels)
bool showSweepMarks = input.bool(true, "Show Sweep Labels", group=g_levels)
bool showCandleTint = input.bool(true, "Tint Candles By Active Session", group=g_levels)

string levelStyleInput = input.string("Dashed", "Level Style", options=["Solid", "Dashed", "Dotted"], group=g_style)
int levelWidth = input.int(1, "Level Width", minval=1, maxval=4, group=g_style)
int zoneTransp = input.int(86, "Zone Transparency", minval=55, maxval=95, group=g_style)
int lineTransp = input.int(25, "Line Transparency", minval=0, maxval=90, group=g_style)
color bgColor = input.color(color.rgb(11, 15, 21), "Dashboard Background", group=g_style)
color gridColor = input.color(color.rgb(31, 42, 56), "Grid Color", group=g_style)
color textColor = input.color(color.rgb(227, 232, 240), "Text Color", group=g_style)
color accentColor = input.color(color.rgb(66, 196, 255), "Accent Color", group=g_style)

string dashPosInput = input.string("Top Right", "Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=g_dash)
string dashSizeInput = input.string("Normal", "Size", options=["Compact", "Normal", "Extended"], group=g_dash)
bool showDashboard = input.bool(true, "Show Dashboard", group=g_dash)

float EPS = 0.0000001
int MAX_KEEP = 100

f_lineStyle(string s) =>
    s == "Solid" ? line.style_solid : s == "Dotted" ? line.style_dotted : line.style_dashed

f_dashPos(string s) =>
    s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : position.top_right

f_dashSize(string s) =>
    s == "Compact" ? size.tiny : s == "Extended" ? size.normal : size.small

f_inSession(string sess, string tz) =>
    not na(time(timeframe.period, sess, tz))

f_mid(float hi, float lo) =>
    (hi + lo) * 0.5

f_safeRange(float hi, float lo) =>
    math.max(hi - lo, EPS)

float prevDayHigh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_off)
float prevDayLow = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_off)
float prevDayOpen = request.security(syminfo.tickerid, "D", open[1], lookahead=barmerge.lookahead_off)
float prevDayClose = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_off)

type SessionState
    string name
    string sessionStr
    bool enabled
    color bullColor
    color bearColor
    color fillColor
    bool active
    float sessionHigh
    float sessionLow
    float sessionOpen
    float sessionClose
    int sessionStartBar
    int sessionEndBar
    bool sweepHigh
    bool sweepLow
    float sweepHighPrice
    float sweepLowPrice
    line hiLine
    line loLine
    line openLine
    line midLine
    box zoneBox
    label infoLabel

f_stateNew(string name, string sessionStr, bool enabled, color bullColor, color bearColor, color fillColor) =>
    SessionState.new(name, sessionStr, enabled, bullColor, bearColor, fillColor, false, na, na, na, na, na, na, false, false, na, na, line(na), line(na), line(na), line(na), box(na), label(na))

var SessionState asiaState = f_stateNew("Asia", asiaSession, showAsia, asiaUp, asiaDn, asiaFill)
var SessionState londonState = f_stateNew("London", londonSession, showLondon, londonUp, londonDn, londonFill)
var SessionState nyState = f_stateNew("New York", nySession, showNY, nyUp, nyDn, nyFill)
var SessionState customState = f_stateNew("Custom", customSession, showCustom, customUp, customDn, customFill)

var line[] hiLines = array.new<line>()
var line[] loLines = array.new<line>()
var line[] openLines = array.new<line>()
var line[] midLines = array.new<line>()
var box[] sessionBoxes = array.new<box>()
var label[] sessionLabels = array.new<label>()
var label[] sweepLabels = array.new<label>()
var float[] keyLevels = array.new_float()

f_pushLine(line[] arr, line ln) =>
    array.push(arr, ln)
    if array.size(arr) > MAX_KEEP
        line old = array.shift(arr)
        if not na(old)
            line.delete(old)

f_pushBox(box[] arr, box bx) =>
    array.push(arr, bx)
    if array.size(arr) > MAX_KEEP
        box old = array.shift(arr)
        if not na(old)
            box.delete(old)

f_pushLabel(label[] arr, label lb) =>
    array.push(arr, lb)
    if array.size(arr) > MAX_KEEP
        label old = array.shift(arr)
        if not na(old)
            label.delete(old)

f_addLevel(float lvl) =>
    if not na(lvl)
        array.push(keyLevels, lvl)

f_updateSession(SessionState state, bool enabledInput, color bullColor, color bearColor, color fillColor) =>
    bool isActive = enabledInput and f_inSession(state.sessionStr, tzInput)
    bool sessionStart = isActive and not state.active
    bool sessionEnd = not isActive and state.active

    float hi = state.sessionHigh
    float lo = state.sessionLow
    float op = state.sessionOpen
    float cl = state.sessionClose
    int startBar = state.sessionStartBar
    int endBar = state.sessionEndBar

    if sessionStart
        hi := high
        lo := low
        op := open
        cl := close
        startBar := bar_index
        endBar := na
        state.sweepHigh := false
        state.sweepLow := false
        state.sweepHighPrice := na
        state.sweepLowPrice := na
    else if isActive
        hi := na(hi) ? high : math.max(hi, high)
        lo := na(lo) ? low : math.min(lo, low)
        cl := close
        if na(op)
            op := open

    if sessionEnd
        endBar := bar_index - 1

    state.active := isActive
    state.sessionHigh := hi
    state.sessionLow := lo
    state.sessionOpen := op
    state.sessionClose := cl
    state.sessionStartBar := startBar
    state.sessionEndBar := endBar

    float mid = na(hi) or na(lo) ? na : f_mid(hi, lo)
    float sessionRange = na(hi) or na(lo) ? na : f_safeRange(hi, lo)
    lineStyle = f_lineStyle(levelStyleInput)

    if isActive and not na(hi) and not na(lo)
        if sessionStart or na(state.hiLine)
            state.hiLine := line.new(startBar, hi, bar_index + levelExtendBars, hi, xloc=xloc.bar_index, color=color.new(bullColor, lineTransp), width=levelWidth, style=lineStyle)
            f_pushLine(hiLines, state.hiLine)
        else
            line.set_xy1(state.hiLine, startBar, hi)
            line.set_xy2(state.hiLine, bar_index + levelExtendBars, hi)
            line.set_color(state.hiLine, color.new(bullColor, lineTransp))
            line.set_style(state.hiLine, lineStyle)
            line.set_width(state.hiLine, levelWidth)

        if sessionStart or na(state.loLine)
            state.loLine := line.new(startBar, lo, bar_index + levelExtendBars, lo, xloc=xloc.bar_index, color=color.new(bearColor, lineTransp), width=levelWidth, style=lineStyle)
            f_pushLine(loLines, state.loLine)
        else
            line.set_xy1(state.loLine, startBar, lo)
            line.set_xy2(state.loLine, bar_index + levelExtendBars, lo)
            line.set_color(state.loLine, color.new(bearColor, lineTransp))
            line.set_style(state.loLine, lineStyle)
            line.set_width(state.loLine, levelWidth)

        if showOpens and not na(op)
            if sessionStart or na(state.openLine)
                state.openLine := line.new(startBar, op, bar_index + levelExtendBars, op, xloc=xloc.bar_index, color=color.new(accentColor, 40), width=1, style=line.style_dotted)
                f_pushLine(openLines, state.openLine)
            else
                line.set_xy1(state.openLine, startBar, op)
                line.set_xy2(state.openLine, bar_index + levelExtendBars, op)
                line.set_color(state.openLine, color.new(accentColor, 40))

        if showMidpoints and not na(mid)
            if sessionStart or na(state.midLine)
                state.midLine := line.new(startBar, mid, bar_index + levelExtendBars, mid, xloc=xloc.bar_index, color=color.new(textColor, 55), width=1, style=line.style_dashed)
                f_pushLine(midLines, state.midLine)
            else
                line.set_xy1(state.midLine, startBar, mid)
                line.set_xy2(state.midLine, bar_index + levelExtendBars, mid)
                line.set_color(state.midLine, color.new(textColor, 55))

        if showRangeZones
            if sessionStart or na(state.zoneBox)
                state.zoneBox := box.new(startBar, hi, bar_index + levelExtendBars, lo, xloc=xloc.bar_index, bgcolor=color.new(fillColor, zoneTransp), border_color=color.new(fillColor, 55), border_width=1)
                f_pushBox(sessionBoxes, state.zoneBox)
            else
                box.set_left(state.zoneBox, startBar)
                box.set_right(state.zoneBox, bar_index + levelExtendBars)
                box.set_top(state.zoneBox, hi)
                box.set_bottom(state.zoneBox, lo)
                box.set_bgcolor(state.zoneBox, color.new(fillColor, zoneTransp))
                box.set_border_color(state.zoneBox, color.new(fillColor, 55))

        if showSweepMarks
            string info = state.name + "\nH " + str.tostring(hi, format.mintick) + "  L " + str.tostring(lo, format.mintick)
            if sessionStart or na(state.infoLabel)
                state.infoLabel := label.new(bar_index, hi, info, xloc=xloc.bar_index, style=label.style_label_left, textcolor=textColor, color=color.new(bgColor, 85), size=size.tiny)
                f_pushLabel(sessionLabels, state.infoLabel)
            else
                label.set_x(state.infoLabel, bar_index)
                label.set_y(state.infoLabel, hi)
                label.set_text(state.infoLabel, info)
                label.set_textcolor(state.infoLabel, textColor)
                label.set_color(state.infoLabel, color.new(bgColor, 85))

    [state, sessionStart, sessionEnd, hi, lo, op, cl, mid, sessionRange]

f_confirmSweep(SessionState state, bool active, float hi, float lo, color highColor, color lowColor) =>
    bool sweptHigh = false
    bool sweptLow = false
    float sweptHighPrice = na
    float sweptLowPrice = na

    if active and barstate.isconfirmed and not na(hi) and not na(lo)
        sweptHigh := high > hi and close < hi and close < open
        sweptLow := low < lo and close > lo and close > open
        if sweptHigh and not state.sweepHigh
            state.sweepHigh := true
            state.sweepHighPrice := hi
            sweptHighPrice := hi
        if sweptLow and not state.sweepLow
            state.sweepLow := true
            state.sweepLowPrice := lo
            sweptLowPrice := lo

    [state, sweptHigh, sweptLow, sweptHighPrice, sweptLowPrice]

f_addSweepLabel(string txt, float price, color col) =>
    label lb = label.new(bar_index, price, txt, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(bgColor, 82), textcolor=col, size=size.tiny)
    f_pushLabel(sweepLabels, lb)

//------------------------------------------------------------------------------
// Session state updates
//------------------------------------------------------------------------------

[asiaStateNext, asiaStart, asiaEnd, asiaHi, asiaLo, asiaOpen, asiaClose, asiaMid, asiaRange] = f_updateSession(asiaState, showAsia, asiaUp, asiaDn, asiaFill)
[londonStateNext, londonStart, londonEnd, londonHi, londonLo, londonOpen, londonClose, londonMid, londonRange] = f_updateSession(londonState, showLondon, londonUp, londonDn, londonFill)
[nyStateNext, nyStart, nyEnd, nyHi, nyLo, nyOpen, nyClose, nyMid, nyRange] = f_updateSession(nyState, showNY, nyUp, nyDn, nyFill)
[customStateNext, customStart, customEnd, customHi, customLo, customOpen, customClose, customMid, customRange] = f_updateSession(customState, showCustom, customUp, customDn, customFill)

asiaState := asiaStateNext
londonState := londonStateNext
nyState := nyStateNext
customState := customStateNext

[asiaStateSweep, asiaHighSweep, asiaLowSweep, asiaHighSweepPrice, asiaLowSweepPrice] = f_confirmSweep(asiaState, asiaState.active, asiaState.sessionHigh, asiaState.sessionLow, asiaUp, asiaDn)
[londonStateSweep, londonHighSweep, londonLowSweep, londonHighSweepPrice, londonLowSweepPrice] = f_confirmSweep(londonState, londonState.active, londonState.sessionHigh, londonState.sessionLow, londonUp, londonDn)
[nyStateSweep, nyHighSweep, nyLowSweep, nyHighSweepPrice, nyLowSweepPrice] = f_confirmSweep(nyState, nyState.active, nyState.sessionHigh, nyState.sessionLow, nyUp, nyDn)
[customStateSweep, customHighSweep, customLowSweep, customHighSweepPrice, customLowSweepPrice] = f_confirmSweep(customState, customState.active, customState.sessionHigh, customState.sessionLow, customUp, customDn)

asiaState := asiaStateSweep
londonState := londonStateSweep
nyState := nyStateSweep
customState := customStateSweep

if showSweepMarks and asiaHighSweep
    f_addSweepLabel("Asia High Sweep", asiaHighSweepPrice, asiaDn)
if showSweepMarks and asiaLowSweep
    f_addSweepLabel("Asia Low Sweep", asiaLowSweepPrice, asiaUp)
if showSweepMarks and londonHighSweep
    f_addSweepLabel("London High Sweep", londonHighSweepPrice, londonDn)
if showSweepMarks and londonLowSweep
    f_addSweepLabel("London Low Sweep", londonLowSweepPrice, londonUp)
if showSweepMarks and nyHighSweep
    f_addSweepLabel("New York High Sweep", nyHighSweepPrice, nyDn)
if showSweepMarks and nyLowSweep
    f_addSweepLabel("New York Low Sweep", nyLowSweepPrice, nyUp)
if showSweepMarks and customHighSweep
    f_addSweepLabel("Custom High Sweep", customHighSweepPrice, customDn)
if showSweepMarks and customLowSweep
    f_addSweepLabel("Custom Low Sweep", customLowSweepPrice, customUp)

// Current day range
bool newDay = timeframe.change("D")
var float dayHigh = na
var float dayLow = na
var float dayOpen = na
var int dayStartBar = na
var box dayZone = box(na)
var line dayHighLine = line(na)
var line dayLowLine = line(na)
var line dayOpenLine = line(na)
var line dayMidLine = line(na)

if newDay
    dayHigh := high
    dayLow := low
    dayOpen := open
    dayStartBar := bar_index
else
    dayHigh := na(dayHigh) ? high : math.max(dayHigh, high)
    dayLow := na(dayLow) ? low : math.min(dayLow, low)

float dayMid = na(dayHigh) or na(dayLow) ? na : f_mid(dayHigh, dayLow)
float dayRange = na(dayHigh) or na(dayLow) ? na : dayHigh - dayLow

if showRangeZones and not na(dayHigh) and not na(dayLow)
    if na(dayStartBar)
        dayStartBar := bar_index
    if na(dayZone)
        dayZone := box.new(dayStartBar, dayHigh, bar_index + levelExtendBars, dayLow, xloc=xloc.bar_index, bgcolor=color.new(accentColor, 92), border_color=color.new(accentColor, 70), border_width=1)
        f_pushBox(sessionBoxes, dayZone)
    else
        box.set_left(dayZone, dayStartBar)
        box.set_right(dayZone, bar_index + levelExtendBars)
        box.set_top(dayZone, dayHigh)
        box.set_bottom(dayZone, dayLow)

if showPrevDay and not na(prevDayHigh) and not na(prevDayLow)
    if na(dayHighLine)
        dayHighLine := line.new(dayStartBar, prevDayHigh, bar_index + levelExtendBars, prevDayHigh, xloc=xloc.bar_index, color=color.new(asiaUp, 35), width=1, style=line.style_dashed)
        f_pushLine(hiLines, dayHighLine)
    else
        line.set_xy1(dayHighLine, dayStartBar, prevDayHigh)
        line.set_xy2(dayHighLine, bar_index + levelExtendBars, prevDayHigh)
    if na(dayLowLine)
        dayLowLine := line.new(dayStartBar, prevDayLow, bar_index + levelExtendBars, prevDayLow, xloc=xloc.bar_index, color=color.new(nyDn, 35), width=1, style=line.style_dashed)
        f_pushLine(loLines, dayLowLine)
    else
        line.set_xy1(dayLowLine, dayStartBar, prevDayLow)
        line.set_xy2(dayLowLine, bar_index + levelExtendBars, prevDayLow)

if showOpens and not na(dayOpen)
    if na(dayOpenLine)
        dayOpenLine := line.new(dayStartBar, dayOpen, bar_index + levelExtendBars, dayOpen, xloc=xloc.bar_index, color=color.new(textColor, 45), width=1, style=line.style_dotted)
        f_pushLine(openLines, dayOpenLine)
    else
        line.set_xy1(dayOpenLine, dayStartBar, dayOpen)
        line.set_xy2(dayOpenLine, bar_index + levelExtendBars, dayOpen)
if showMidpoints and not na(dayMid)
    if na(dayMidLine)
        dayMidLine := line.new(dayStartBar, dayMid, bar_index + levelExtendBars, dayMid, xloc=xloc.bar_index, color=color.new(accentColor, 40), width=1, style=line.style_dotted)
        f_pushLine(midLines, dayMidLine)
    else
        line.set_xy1(dayMidLine, dayStartBar, dayMid)
        line.set_xy2(dayMidLine, bar_index + levelExtendBars, dayMid)

//-------------------------------------------------------------------------
// Key level basket and nearest reference
//-------------------------------------------------------------------------

if barstate.isnew
    array.clear(keyLevels)

f_addLevel(prevDayHigh)
f_addLevel(prevDayLow)
f_addLevel(prevDayOpen)
f_addLevel(prevDayClose)
f_addLevel(dayOpen)
f_addLevel(dayMid)
f_addLevel(dayHigh)
f_addLevel(dayLow)
f_addLevel(asiaState.sessionHigh)
f_addLevel(asiaState.sessionLow)
f_addLevel(asiaState.sessionOpen)
f_addLevel(asiaMid)
f_addLevel(londonState.sessionHigh)
f_addLevel(londonState.sessionLow)
f_addLevel(londonState.sessionOpen)
f_addLevel(londonMid)
f_addLevel(nyState.sessionHigh)
f_addLevel(nyState.sessionLow)
f_addLevel(nyState.sessionOpen)
f_addLevel(nyMid)
f_addLevel(customState.sessionHigh)
f_addLevel(customState.sessionLow)
f_addLevel(customState.sessionOpen)
f_addLevel(customMid)

float nearestLevel = na
float nearestDistance = na
if array.size(keyLevels) > 0
    for i = 0 to array.size(keyLevels) - 1
        float lvl = array.get(keyLevels, i)
        float dist = math.abs(close - lvl)
        if na(nearestDistance) or dist < nearestDistance
            nearestDistance := dist
            nearestLevel := lvl

string activeSessionName = "None"
color activeUpColor = accentColor
color activeDnColor = accentColor

if customState.active
    activeSessionName := customState.name
    activeUpColor := customUp
    activeDnColor := customDn
else if nyState.active
    activeSessionName := nyState.name
    activeUpColor := nyUp
    activeDnColor := nyDn
else if londonState.active
    activeSessionName := londonState.name
    activeUpColor := londonUp
    activeDnColor := londonDn
else if asiaState.active
    activeSessionName := asiaState.name
    activeUpColor := asiaUp
    activeDnColor := asiaDn

color activeTint = close >= f_mid(nz(dayHigh, close), nz(dayLow, close)) ? activeUpColor : activeDnColor
barcolor(showCandleTint and activeSessionName != "None" ? color.new(activeTint, 35) : na)

// Clean overlay plots for charting and alert context.
plot(showPrevDay and not na(prevDayHigh) ? prevDayHigh : na, "Previous Day High", color=color.new(asiaUp, 35), linewidth=1, style=plot.style_linebr)
plot(showPrevDay and not na(prevDayLow) ? prevDayLow : na, "Previous Day Low", color=color.new(nyDn, 35), linewidth=1, style=plot.style_linebr)
plot(showOpens and not na(dayOpen) ? dayOpen : na, "Day Open", color=color.new(textColor, 45), linewidth=1, style=plot.style_linebr)
plot(showMidpoints and not na(dayMid) ? dayMid : na, "Day Mid", color=color.new(accentColor, 40), linewidth=1, style=plot.style_linebr)

plot(showRangeZones and asiaState.active and not na(asiaState.sessionHigh) ? asiaState.sessionHigh : na, "Asia High", color=color.new(asiaUp, 45), linewidth=1, style=plot.style_linebr)
plot(showRangeZones and asiaState.active and not na(asiaState.sessionLow) ? asiaState.sessionLow : na, "Asia Low", color=color.new(asiaDn, 45), linewidth=1, style=plot.style_linebr)
plot(showRangeZones and londonState.active and not na(londonState.sessionHigh) ? londonState.sessionHigh : na, "London High", color=color.new(londonUp, 45), linewidth=1, style=plot.style_linebr)
plot(showRangeZones and londonState.active and not na(londonState.sessionLow) ? londonState.sessionLow : na, "London Low", color=color.new(londonDn, 45), linewidth=1, style=plot.style_linebr)
plot(showRangeZones and nyState.active and not na(nyState.sessionHigh) ? nyState.sessionHigh : na, "New York High", color=color.new(nyUp, 45), linewidth=1, style=plot.style_linebr)
plot(showRangeZones and nyState.active and not na(nyState.sessionLow) ? nyState.sessionLow : na, "New York Low", color=color.new(nyDn, 45), linewidth=1, style=plot.style_linebr)
plot(showRangeZones and customState.active and not na(customState.sessionHigh) ? customState.sessionHigh : na, "Custom High", color=color.new(customUp, 45), linewidth=1, style=plot.style_linebr)
plot(showRangeZones and customState.active and not na(customState.sessionLow) ? customState.sessionLow : na, "Custom Low", color=color.new(customDn, 45), linewidth=1, style=plot.style_linebr)

//-------------------------------------------------------------------------
// Dashboard
//-------------------------------------------------------------------------

string sweepStatus = "None"
color sweepColor = textColor
if asiaState.sweepHigh or asiaState.sweepLow or londonState.sweepHigh or londonState.sweepLow or nyState.sweepHigh or nyState.sweepLow or customState.sweepHigh or customState.sweepLow
    sweepStatus := "Confirmed"
    sweepColor := accentColor
else if (high > nz(dayHigh, high) or low < nz(dayLow, low)) and not barstate.isconfirmed
    sweepStatus := "Developing"
    sweepColor := color.new(accentColor, 20)

string nearestLevelText = na(nearestLevel) ? "n/a" : str.tostring(nearestLevel, format.mintick)
string dayRangeText = na(dayRange) ? "n/a" : str.tostring(dayRange, format.mintick)
string dayOpenText = na(dayOpen) ? "n/a" : str.tostring(dayOpen, format.mintick)
string dayMidText = na(dayMid) ? "n/a" : str.tostring(dayMid, format.mintick)

var table dash = na
if showDashboard and barstate.islast
    if na(dash)
        dash := table.new(f_dashPos(dashPosInput), 2, 10, bgcolor=color.new(bgColor, 6), border_width=1, border_color=color.new(gridColor, 30), frame_color=color.new(gridColor, 45), frame_width=1)
    rowSize = f_dashSize(dashSizeInput)
    table.cell(dash, 0, 0, "Meridian Cartography", text_color=textColor, text_size=rowSize, bgcolor=color.new(accentColor, 82), text_halign=text.align_center)
    table.cell(dash, 1, 0, activeSessionName, text_color=activeUpColor, text_size=rowSize, bgcolor=color.new(activeUpColor, 88), text_halign=text.align_center)
    table.cell(dash, 0, 1, "Day Range", text_color=color.new(textColor, 20), text_size=rowSize)
    table.cell(dash, 1, 1, dayRangeText, text_color=textColor, text_size=rowSize)
    table.cell(dash, 0, 2, "Day Open", text_color=color.new(textColor, 20), text_size=rowSize)
    table.cell(dash, 1, 2, dayOpenText, text_color=textColor, text_size=rowSize)
    table.cell(dash, 0, 3, "Day Mid", text_color=color.new(textColor, 20), text_size=rowSize)
    table.cell(dash, 1, 3, dayMidText, text_color=textColor, text_size=rowSize)
    table.cell(dash, 0, 4, "Prev High", text_color=color.new(textColor, 20), text_size=rowSize)
    table.cell(dash, 1, 4, na(prevDayHigh) ? "n/a" : str.tostring(prevDayHigh, format.mintick), text_color=asiaUp, text_size=rowSize)
    table.cell(dash, 0, 5, "Prev Low", text_color=color.new(textColor, 20), text_size=rowSize)
    table.cell(dash, 1, 5, na(prevDayLow) ? "n/a" : str.tostring(prevDayLow, format.mintick), text_color=nyDn, text_size=rowSize)
    table.cell(dash, 0, 6, "Sweep Status", text_color=color.new(textColor, 20), text_size=rowSize)
    table.cell(dash, 1, 6, sweepStatus, text_color=sweepColor, text_size=rowSize)
    table.cell(dash, 0, 7, "Nearest Level", text_color=color.new(textColor, 20), text_size=rowSize)
    table.cell(dash, 1, 7, nearestLevelText, text_color=accentColor, text_size=rowSize)
    table.cell(dash, 0, 8, "Confirmed Bar", text_color=color.new(textColor, 20), text_size=rowSize)
    table.cell(dash, 1, 8, barstate.isconfirmed ? "Yes" : "No", text_color=barstate.isconfirmed ? asiaUp : nyDn, text_size=rowSize)
    table.cell(dash, 0, 9, "Reference", text_color=color.new(textColor, 20), text_size=rowSize)
    table.cell(dash, 1, 9, activeSessionName == "None" ? "Prev Day / Day" : activeSessionName + " / Day", text_color=textColor, text_size=rowSize)

//-------------------------------------------------------------------------
// Alerts
//-------------------------------------------------------------------------

alertcondition(asiaHighSweep, "Asia High Sweep", "Meridian Cartography: Asia high sweep confirmed on {{ticker}} {{interval}}")
alertcondition(asiaLowSweep, "Asia Low Sweep", "Meridian Cartography: Asia low sweep confirmed on {{ticker}} {{interval}}")
alertcondition(londonHighSweep, "London High Sweep", "Meridian Cartography: London high sweep confirmed on {{ticker}} {{interval}}")
alertcondition(londonLowSweep, "London Low Sweep", "Meridian Cartography: London low sweep confirmed on {{ticker}} {{interval}}")
alertcondition(nyHighSweep, "New York High Sweep", "Meridian Cartography: New York high sweep confirmed on {{ticker}} {{interval}}")
alertcondition(nyLowSweep, "New York Low Sweep", "Meridian Cartography: New York low sweep confirmed on {{ticker}} {{interval}}")
alertcondition(customHighSweep, "Custom High Sweep", "Meridian Cartography: Custom high sweep confirmed on {{ticker}} {{interval}}")
alertcondition(customLowSweep, "Custom Low Sweep", "Meridian Cartography: Custom low sweep confirmed on {{ticker}} {{interval}}")

//-------------------------------------------------------------------------
// Cleanup
//-------------------------------------------------------------------------

int labelCap = math.max(lookbackDays, maxSessionsKept) * 2
int lineCap = math.max(lookbackDays, maxSessionsKept) * 3
int boxCap = math.max(lookbackDays, maxSessionsKept)

while array.size(sessionLabels) > labelCap
    label old = array.shift(sessionLabels)
    if not na(old)
        label.delete(old)

while array.size(sweepLabels) > labelCap
    label old = array.shift(sweepLabels)
    if not na(old)
        label.delete(old)

while array.size(sessionBoxes) > boxCap
    box old = array.shift(sessionBoxes)
    if not na(old)
        box.delete(old)

while array.size(hiLines) > lineCap
    line old = array.shift(hiLines)
    if not na(old)
        line.delete(old)

while array.size(loLines) > lineCap
    line old = array.shift(loLines)
    if not na(old)
        line.delete(old)

while array.size(openLines) > lineCap
    line old = array.shift(openLines)
    if not na(old)
        line.delete(old)

while array.size(midLines) > lineCap
    line old = array.shift(midLines)
    if not na(old)
        line.delete(old)
````
