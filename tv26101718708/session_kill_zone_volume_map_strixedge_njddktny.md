# Session Kill Zone Volume Map [StrixEDGE]

- url: https://www.tradingview.com/script/NjDdkTnY-Session-Kill-Zone-Volume-Map-StrixEDGE/
- type: indicator
- pine_id: PUB;30a29a367dd94138ab72c55aca18ed05
- version: 1.0

## Description

Session Kill Zone Volume Map [StrixEDGE]

A session-aware overlay that maps institutional kill zones — London, New York, and Asia — directly onto your chart with volume-weighted session boxes, Opening Range Breakout levels, and a unified analytics dashboard. Built to give intraday traders immediate visual context on where volume clusters, how sessions develop relative to their historical norms, and when a confirmed breakout is underway.

🔍 What This Indicator Does

The indicator automatically detects the three major forex/futures sessions based on UTC time and draws color-coded session boxes whose fill intensity scales dynamically with real-time volume. High-volume sessions appear visually heavier; low-volume sessions fade into the background. This gives you an instant read on whether today's session is running hotter or cooler than average — without checking a single number.

On top of each session, it tracks the Opening Range (first 15, 30, or 60 minutes) and plots ORB-High and ORB-Low levels as dashed reference lines extending through the session. When price breaks an ORB level with volume confirmation, a directional marker (▲ or ▼) prints on the chart and an alert fires.

▲ https://www.tradingview.com/x/F0CPZfSB/

▼ https://www.tradingview.com/x/28oMNoML/

A single unified dashboard panel consolidates everything: live session volume, percentage distribution with a visual bar, historical average range, ORB win rate, and session sample count — all in one clean table.

⚡ Key Features

Session Auto-Detection
London (08:00–17:00 UTC) https://www.tradingview.com/x/TKa960C0/ 
New York (13:00–22:00 UTC) https://www.tradingview.com/x/rY22nHVj/
Asia (00:00–09:00 UTC) https://www.tradingview.com/x/5Ct5AG3H/
are detected automatically. All session start and end times are fully customizable down to the minute, so you can adjust for DST shifts or align to your broker's server time.

Volume-Weighted Session Boxes
Each session box fills with the session's assigned color at a transparency that adjusts in real time based on cumulative volume relative to the historical session average. A session running at 2× its normal volume will render noticeably more vivid than one at 0.5×. The base transparency is user-controlled.

Opening Range Breakout (ORB) Levels
The indicator captures the high and low of the first N minutes of each session (configurable: 15 / 30 / 60 min) and draws them as horizontal reference lines. These extend through the rest of the session, serving as the breakout thresholds traders watch for directional continuation.

Volume-Confirmed Breakout Signals
When price closes beyond an ORB level and the breakout bar's volume exceeds the 20-period SMA × a user-defined multiplier (default 1.5×), a directional triangle prints on the chart. No volume confirmation = no signal. This filters out low-conviction breaks.

Unified Session Dashboard
A single professional table displays all session data at a glance:
- Live session volume (absolute + percentage share)
- Volume distribution bar per session
- Historical average session range over your chosen lookback
- ORB win rate (percentage of confirmed breakouts that held direction through session close)
- Session sample count

Table position, text size, and visibility are all input-controlled.

Session High/Low Break Alerts
Separate alert conditions fire when price crosses the previous session's high or low with volume confirmation, giving you an additional layer of inter-session breakout detection.

9 Alert Conditions
Individual bull/bear ORB break alerts per session, a unified "any ORB break" alert, and session high/low break alerts — all configurable in TradingView's alert manager.

⚙️ Inputs & Settings

| Group | Setting | Description |
|---|---|---|
| Session Times | Start/End Hour & Minute | Full control over each session's UTC boundaries |
| ORB Settings | Period (15/30/60 min) | Opening range duration |
| ORB Settings | Line Style / Width | Visual style of ORB levels |
| Display | Show/Hide Sessions | Toggle individual session boxes |
| Display | Base Box Transparency | Controls how transparent session boxes are at normal volume |
| Display | Dashboard Position | Table corner placement |
| Display | Dashboard Text Size | Tiny / Small / Normal / Large |
| Display | Stats Lookback | Number of past sessions for avg range and ORB win rate |
| Alerts | Volume Confirm Multiplier | How far above SMA(20) breakout volume must be |
| Colors | Session & Breakout Colors | Full color customization per session and direction |

📖 How To Use

Session Context
Load on a 5m–1H chart. The session boxes immediately frame where London, New York, and Asia operated. The fill intensity tells you which session carried the most conviction — use that to weight your analysis toward the active kill zone.

ORB Strategy
After the opening range completes, the ORB-H and ORB-L lines become your breakout thresholds. A volume-confirmed break (▲/▼ marker) signals directional intent. Traders often look for price to retest the broken ORB level as support/resistance before committing to a continuation trade.

▲ https://www.tradingview.com/x/XL8gRtZc/
▼ https://www.tradingview.com/x/xH3wpJb1/

Dashboard Read
Check the Vol % column to see which session is dominating flow. The ORB WR column tells you how reliable ORB breakouts have been historically for each session on the current instrument — if London shows 85% and Asia shows 50%, that's actionable edge for session selection.

Alerts
Set up any of the 9 alert conditions to get notified without watching the chart. Combine the unified "Any ORB Break" alert with a mobile notification for hands-free monitoring.

https://www.tradingview.com/x/khDPGHn9/

📋 Notes

- Designed for intraday timeframes (15m and below recommended for ORB accuracy). A warning displays if loaded on Daily or higher.
- During the London/NY overlap window (13:00–17:00 UTC by default), volume is attributed to both sessions. The percentage distribution shows relative contribution, not mutually exclusive slices.
- ORB win rate is a binary metric: did price close beyond the broken ORB level at session end? It does not measure how far price traveled.
- The volume gradient uses transparency modulation, not a multi-stop color gradient, due to Pine Script rendering constraints.
- Works on any instrument with volume data (forex via tick volume, futures, crypto, equities).

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © StrixEDGE

//@version=6
indicator("Session Kill Zone Volume Map [StrixEDGE]", "Session Kill Zone Volume Map [StrixEDGE]", overlay = true,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ──────────────────────────────────────────────────────────────────────────
//  INPUTS
// ──────────────────────────────────────────────────────────────────────────

// Session Times (UTC hours)
i_ldnStartH  = input.int(8,  "London Start Hour",   0, 23, group = "⏰ Session Times (UTC)", tooltip = "London session open hour in UTC")
i_ldnStartM  = input.int(0,  "London Start Minute", 0, 59, group = "⏰ Session Times (UTC)")
i_ldnEndH    = input.int(17, "London End Hour",     0, 23, group = "⏰ Session Times (UTC)", tooltip = "London session close hour in UTC")
i_ldnEndM    = input.int(0,  "London End Minute",   0, 59, group = "⏰ Session Times (UTC)")
i_nyStartH   = input.int(13, "New York Start Hour", 0, 23, group = "⏰ Session Times (UTC)", tooltip = "New York session open hour in UTC")
i_nyStartM   = input.int(0,  "New York Start Minute",0, 59, group = "⏰ Session Times (UTC)")
i_nyEndH     = input.int(22, "New York End Hour",   0, 23, group = "⏰ Session Times (UTC)", tooltip = "New York session close hour in UTC")
i_nyEndM     = input.int(0,  "New York End Minute", 0, 59, group = "⏰ Session Times (UTC)")
i_asStartH   = input.int(0,  "Asia Start Hour",     0, 23, group = "⏰ Session Times (UTC)", tooltip = "Asia session open hour in UTC")
i_asStartM   = input.int(0,  "Asia Start Minute",   0, 59, group = "⏰ Session Times (UTC)")
i_asEndH     = input.int(9,  "Asia End Hour",       0, 23, group = "⏰ Session Times (UTC)", tooltip = "Asia session close hour in UTC")
i_asEndM     = input.int(0,  "Asia End Minute",     0, 59, group = "⏰ Session Times (UTC)")

// ORB Settings
i_orbPeriod  = input.string("30", "Opening Range Period (min)", options = ["15", "30", "60"], group = "⚡ ORB Settings", tooltip = "Duration of the opening range to track")
i_orbStyle   = input.string("Dashed", "ORB Line Style", options = ["Solid", "Dashed", "Dotted"], group = "⚡ ORB Settings")
i_orbWidth   = input.int(1, "ORB Line Width", 1, 4, group = "⚡ ORB Settings")
i_orbExtend  = input.bool(true, "Extend ORB Lines to Session End", group = "⚡ ORB Settings")

// Display
i_showLdn    = input.bool(true, "Show London Session",   group = "👁 Display")
i_showNY     = input.bool(true, "Show New York Session",  group = "👁 Display")
i_showAsia   = input.bool(true, "Show Asia Session",      group = "👁 Display")
i_boxTransp  = input.int(85, "Base Box Transparency", 50, 96, group = "👁 Display", tooltip = "Base transparency — volume intensity will dynamically reduce it for high-volume sessions")
i_showLabels = input.bool(true, "Show Session Labels", group = "👁 Display")
i_showPanel  = input.bool(true, "Show Dashboard Panel", group = "👁 Display")
i_panelPos   = input.string("Bottom Right", "Dashboard Position", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Middle Left", "Middle Right"], group = "👁 Display")
i_tblSize    = input.string("Small", "Dashboard Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = "👁 Display", tooltip = "Controls the font size of the unified dashboard table")
i_lookback   = input.int(20, "Stats Lookback (sessions)", 5, 100, group = "👁 Display", tooltip = "Number of past sessions for averaging range and ORB win rate")

// Alert Settings
i_volMult    = input.float(1.5, "Volume Confirm Multiplier", 1.0, 5.0, step = 0.1, group = "🔔 Alerts", tooltip = "Breakout bar volume must exceed SMA(20) × this value")
i_volLen     = input.int(20, "Volume SMA Length", 5, 100, group = "🔔 Alerts")

// Colors
i_ldnColor   = input.color(#00B8D4, "London Color",   group = "🎨 Colors")
i_nyColor    = input.color(#FF6D00, "New York Color",  group = "🎨 Colors")
i_asColor    = input.color(#AA00FF, "Asia Color",      group = "🎨 Colors")
i_orbBull    = input.color(#00E676, "ORB Bull Break",  group = "🎨 Colors")
i_orbBear    = input.color(#FF1744, "ORB Bear Break",  group = "🎨 Colors")

// ──────────────────────────────────────────────────────────────────────────
//  CONSTANTS & UTILITIES
// ──────────────────────────────────────────────────────────────────────────

orbMin       = int(str.tonumber(i_orbPeriod))
volSMA       = ta.sma(volume, i_volLen)
tfSecs       = timeframe.in_seconds(timeframe.period)
tfMin        = tfSecs / 60
isIntraday   = timeframe.isintraday
orbMsec      = orbMin * 60 * 1000

// Table position resolver
getPos(string p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        "Middle Left"  => position.middle_left
        "Middle Right" => position.middle_right
        => position.top_right

// Line style resolver
getStyle(string s) =>
    switch s
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_dashed

orbLnStyle = getStyle(i_orbStyle)

// Table size resolver
getSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

tblSz = getSize(i_tblSize)

// ──────────────────────────────────────────────────────────────────────────
//  SESSION DETECTION
// ──────────────────────────────────────────────────────────────────────────

utcH    = hour(time, "UTC")
utcM    = minute(time, "UTC")
utcTot  = utcH * 60 + utcM          // total minutes since midnight UTC

ldnStart = i_ldnStartH * 60 + i_ldnStartM
ldnEnd   = i_ldnEndH   * 60 + i_ldnEndM
nyStart  = i_nyStartH  * 60 + i_nyStartM
nyEnd    = i_nyEndH    * 60 + i_nyEndM
asStart  = i_asStartH  * 60 + i_asStartM
asEnd    = i_asEndH    * 60 + i_asEndM

inRange(int st, int en, int cur) =>
    st < en ? (cur >= st and cur < en) : (cur >= st or cur < en)

// Format helpers (must be top-level)
fmtRange(float v) => na(v) ? "—" : str.tostring(v, format.mintick)
fmtWR(float v)    => na(v) ? "—" : str.tostring(v, "#.0") + "%"
wrColor(float v)  => na(v) ? #8B949E : v >= 60 ? #00E676 : v >= 40 ? #FFC107 : #FF1744

inLdn  = inRange(ldnStart, ldnEnd, utcTot) and i_showLdn
inNY   = inRange(nyStart,  nyEnd,  utcTot) and i_showNY
inAsia = inRange(asStart,  asEnd,  utcTot) and i_showAsia

// Edge detection
ldnOpen  = inLdn  and not inLdn[1]
nyOpen   = inNY   and not inNY[1]
asOpen   = inAsia and not inAsia[1]
ldnClose = not inLdn  and inLdn[1]
nyClose  = not inNY   and inNY[1]
asClose  = not inAsia and inAsia[1]

// ──────────────────────────────────────────────────────────────────────────
//  TIMEFRAME GUARD
// ──────────────────────────────────────────────────────────────────────────

var table tfWarn = na

if barstate.islast and not isIntraday
    tfWarn := table.new(position.middle_center, 1, 1, bgcolor = #1A1A2E, border_color = #FF1744, border_width = 2)
    table.cell(tfWarn, 0, 0, "⚠  [StrixEDGE] SKZ Vol Map requires an intraday timeframe (≤ 1H recommended)", 
         text_color = #FF1744, text_size = size.normal)

// ──────────────────────────────────────────────────────────────────────────
//  SESSION STATE VARIABLES
// ──────────────────────────────────────────────────────────────────────────

// London
var float  ldnHi         = na,  var float  ldnLo         = na
var float  ldnVol        = 0.0, var int    ldnBarStart   = na
var int    ldnTimeStart  = na
var float  ldnOrbHi      = na,  var float  ldnOrbLo      = na
var bool   ldnOrbDone    = false
var bool   ldnOrbBrokeHi = false, var bool ldnOrbBrokeLo = false
var box    ldnBox        = na
var line   ldnOrbHiLn    = na,  var line   ldnOrbLoLn    = na
var label  ldnOrbHiLbl   = na,  var label  ldnOrbLoLbl   = na
var label  ldnSessLbl    = na

// New York
var float  nyHi          = na,  var float  nyLo          = na
var float  nyVol         = 0.0, var int    nyBarStart    = na
var int    nyTimeStart   = na
var float  nyOrbHi       = na,  var float  nyOrbLo       = na
var bool   nyOrbDone     = false
var bool   nyOrbBrokeHi  = false, var bool nyOrbBrokeLo  = false
var box    nyBox         = na
var line   nyOrbHiLn     = na,  var line   nyOrbLoLn     = na
var label  nyOrbHiLbl    = na,  var label  nyOrbLoLbl    = na
var label  nySessLbl     = na

// Asia
var float  asHi          = na,  var float  asLo          = na
var float  asVol         = 0.0, var int    asBarStart    = na
var int    asTimeStart   = na
var float  asOrbHi       = na,  var float  asOrbLo       = na
var bool   asOrbDone     = false
var bool   asOrbBrokeHi  = false, var bool asOrbBrokeLo  = false
var box    asBox         = na
var line   asOrbHiLn     = na,  var line   asOrbLoLn     = na
var label  asOrbHiLbl    = na,  var label  asOrbLoLbl    = na
var label  asSessLbl     = na

// ──────────────────────────────────────────────────────────────────────────
//  HISTORICAL ARRAYS
// ──────────────────────────────────────────────────────────────────────────

var array<float> ldnRanges   = array.new_float()
var array<float> nyRanges    = array.new_float()
var array<float> asRanges    = array.new_float()
var array<float> ldnVolHist  = array.new_float()
var array<float> nyVolHist   = array.new_float()
var array<float> asVolHist   = array.new_float()
// ORB results: 1 = win, 0 = loss, -1 = no breakout
var array<int>   ldnOrbRes   = array.new_int()
var array<int>   nyOrbRes    = array.new_int()
var array<int>   asOrbRes    = array.new_int()

// ──────────────────────────────────────────────────────────────────────────
//  HELPER: VOLUME-ADAPTIVE TRANSPARENCY
// ──────────────────────────────────────────────────────────────────────────

calcTransp(float sessVol, array<float> volHist) =>
    avg = array.size(volHist) > 0 ? array.avg(volHist) : sessVol
    ratio = avg > 0 ? sessVol / avg : 1.0
    // Higher volume → lower transparency (more vivid)
    raw = i_boxTransp - (ratio - 1.0) * 30.0
    int(math.max(40, math.min(96, raw)))

// ──────────────────────────────────────────────────────────────────────────
//  HELPER: STATS CALCULATION
// ──────────────────────────────────────────────────────────────────────────

avgRange(array<float> arr) =>
    sz = array.size(arr)
    if sz == 0
        na
    else
        startIdx = math.max(0, sz - i_lookback)
        sum = 0.0
        cnt = 0
        for i = startIdx to sz - 1
            sum += array.get(arr, i)
            cnt += 1
        cnt > 0 ? sum / cnt : na

orbWinRate(array<int> arr) =>
    sz = array.size(arr)
    if sz == 0
        na
    else
        startIdx = math.max(0, sz - i_lookback)
        total = 0
        wins  = 0
        for i = startIdx to sz - 1
            v = array.get(arr, i)
            if v >= 0
                total += 1
                if v == 1
                    wins += 1
        total > 0 ? float(wins) / float(total) * 100.0 : na

// ──────────────────────────────────────────────────────────────────────────
//  SESSION PROCESSING — LONDON
// ──────────────────────────────────────────────────────────────────────────

if isIntraday and i_showLdn
    if ldnOpen
        ldnHi         := high
        ldnLo         := low
        ldnVol        := volume
        ldnBarStart   := bar_index
        ldnTimeStart  := time
        ldnOrbHi      := high
        ldnOrbLo      := low
        ldnOrbDone    := false
        ldnOrbBrokeHi := false
        ldnOrbBrokeLo := false
        ldnBox        := box.new(bar_index, high, bar_index, low, 
             border_color = i_ldnColor, border_width = 1, border_style = line.style_solid,
             bgcolor = color.new(i_ldnColor, i_boxTransp))
        if i_showLabels
            ldnSessLbl := label.new(bar_index, high, "LDN", 
                 color = color.new(i_ldnColor, 80), textcolor = i_ldnColor, 
                 style = label.style_label_down, size = size.tiny)

    if inLdn
        ldnHi  := math.max(ldnHi, high)
        ldnLo  := math.min(ldnLo, low)
        ldnVol += volume

        // ORB tracking
        if not ldnOrbDone
            ldnOrbHi := math.max(ldnOrbHi, high)
            ldnOrbLo := math.min(ldnOrbLo, low)
            if not na(ldnTimeStart) and (time - ldnTimeStart) >= orbMsec
                ldnOrbDone := true
                ldnOrbHiLn := line.new(ldnBarStart, ldnOrbHi, bar_index, ldnOrbHi, 
                     color = i_ldnColor, style = orbLnStyle, width = i_orbWidth)
                ldnOrbLoLn := line.new(ldnBarStart, ldnOrbLo, bar_index, ldnOrbLo, 
                     color = i_ldnColor, style = orbLnStyle, width = i_orbWidth)
                ldnOrbHiLbl := label.new(bar_index, ldnOrbHi, "ORB-H " + str.tostring(ldnOrbHi, format.mintick),
                     color = color.new(i_ldnColor, 85), textcolor = i_ldnColor,
                     style = label.style_label_left, size = size.tiny)
                ldnOrbLoLbl := label.new(bar_index, ldnOrbLo, "ORB-L " + str.tostring(ldnOrbLo, format.mintick),
                     color = color.new(i_ldnColor, 85), textcolor = i_ldnColor,
                     style = label.style_label_left, size = size.tiny)

        // ORB breakout detection
        if ldnOrbDone
            if not ldnOrbBrokeHi and close > ldnOrbHi
                ldnOrbBrokeHi := true
            if not ldnOrbBrokeLo and close < ldnOrbLo
                ldnOrbBrokeLo := true

        // Extend ORB lines
        if ldnOrbDone and i_orbExtend
            if not na(ldnOrbHiLn)
                line.set_x2(ldnOrbHiLn, bar_index)
            if not na(ldnOrbLoLn)
                line.set_x2(ldnOrbLoLn, bar_index)

        // Update box
        if not na(ldnBox)
            box.set_top(ldnBox, ldnHi)
            box.set_bottom(ldnBox, ldnLo)
            box.set_right(ldnBox, bar_index)
            box.set_bgcolor(ldnBox, color.new(i_ldnColor, calcTransp(ldnVol, ldnVolHist)))
        if not na(ldnSessLbl) and i_showLabels
            label.set_x(ldnSessLbl, ldnBarStart)
            label.set_y(ldnSessLbl, ldnHi)

    if ldnClose
        // Store historical data
        array.push(ldnRanges,  ldnHi - ldnLo)
        array.push(ldnVolHist, ldnVol)
        // ORB result
        if ldnOrbBrokeHi or ldnOrbBrokeLo
            win = (ldnOrbBrokeHi and close[1] > ldnOrbHi) or (ldnOrbBrokeLo and close[1] < ldnOrbLo)
            array.push(ldnOrbRes, win ? 1 : 0)
        else
            array.push(ldnOrbRes, -1)

// ──────────────────────────────────────────────────────────────────────────
//  SESSION PROCESSING — NEW YORK
// ──────────────────────────────────────────────────────────────────────────

if isIntraday and i_showNY
    if nyOpen
        nyHi         := high
        nyLo         := low
        nyVol        := volume
        nyBarStart   := bar_index
        nyTimeStart  := time
        nyOrbHi      := high
        nyOrbLo      := low
        nyOrbDone    := false
        nyOrbBrokeHi := false
        nyOrbBrokeLo := false
        nyBox        := box.new(bar_index, high, bar_index, low, 
             border_color = i_nyColor, border_width = 1, border_style = line.style_solid,
             bgcolor = color.new(i_nyColor, i_boxTransp))
        if i_showLabels
            nySessLbl := label.new(bar_index, high, "NY", 
                 color = color.new(i_nyColor, 80), textcolor = i_nyColor, 
                 style = label.style_label_down, size = size.tiny)

    if inNY
        nyHi  := math.max(nyHi, high)
        nyLo  := math.min(nyLo, low)
        nyVol += volume

        if not nyOrbDone
            nyOrbHi := math.max(nyOrbHi, high)
            nyOrbLo := math.min(nyOrbLo, low)
            if not na(nyTimeStart) and (time - nyTimeStart) >= orbMsec
                nyOrbDone := true
                nyOrbHiLn := line.new(nyBarStart, nyOrbHi, bar_index, nyOrbHi, 
                     color = i_nyColor, style = orbLnStyle, width = i_orbWidth)
                nyOrbLoLn := line.new(nyBarStart, nyOrbLo, bar_index, nyOrbLo, 
                     color = i_nyColor, style = orbLnStyle, width = i_orbWidth)
                nyOrbHiLbl := label.new(bar_index, nyOrbHi, "ORB-H " + str.tostring(nyOrbHi, format.mintick),
                     color = color.new(i_nyColor, 85), textcolor = i_nyColor,
                     style = label.style_label_left, size = size.tiny)
                nyOrbLoLbl := label.new(bar_index, nyOrbLo, "ORB-L " + str.tostring(nyOrbLo, format.mintick),
                     color = color.new(i_nyColor, 85), textcolor = i_nyColor,
                     style = label.style_label_left, size = size.tiny)

        if nyOrbDone
            if not nyOrbBrokeHi and close > nyOrbHi
                nyOrbBrokeHi := true
            if not nyOrbBrokeLo and close < nyOrbLo
                nyOrbBrokeLo := true

        if nyOrbDone and i_orbExtend
            if not na(nyOrbHiLn)
                line.set_x2(nyOrbHiLn, bar_index)
            if not na(nyOrbLoLn)
                line.set_x2(nyOrbLoLn, bar_index)

        if not na(nyBox)
            box.set_top(nyBox, nyHi)
            box.set_bottom(nyBox, nyLo)
            box.set_right(nyBox, bar_index)
            box.set_bgcolor(nyBox, color.new(i_nyColor, calcTransp(nyVol, nyVolHist)))
        if not na(nySessLbl) and i_showLabels
            label.set_x(nySessLbl, nyBarStart)
            label.set_y(nySessLbl, nyHi)

    if nyClose
        array.push(nyRanges,  nyHi - nyLo)
        array.push(nyVolHist, nyVol)
        if nyOrbBrokeHi or nyOrbBrokeLo
            win = (nyOrbBrokeHi and close[1] > nyOrbHi) or (nyOrbBrokeLo and close[1] < nyOrbLo)
            array.push(nyOrbRes, win ? 1 : 0)
        else
            array.push(nyOrbRes, -1)

// ──────────────────────────────────────────────────────────────────────────
//  SESSION PROCESSING — ASIA
// ──────────────────────────────────────────────────────────────────────────

if isIntraday and i_showAsia
    if asOpen
        asHi         := high
        asLo         := low
        asVol        := volume
        asBarStart   := bar_index
        asTimeStart  := time
        asOrbHi      := high
        asOrbLo      := low
        asOrbDone    := false
        asOrbBrokeHi := false
        asOrbBrokeLo := false
        asBox        := box.new(bar_index, high, bar_index, low, 
             border_color = i_asColor, border_width = 1, border_style = line.style_solid,
             bgcolor = color.new(i_asColor, i_boxTransp))
        if i_showLabels
            asSessLbl := label.new(bar_index, high, "ASIA", 
                 color = color.new(i_asColor, 80), textcolor = i_asColor, 
                 style = label.style_label_down, size = size.tiny)

    if inAsia
        asHi  := math.max(asHi, high)
        asLo  := math.min(asLo, low)
        asVol += volume

        if not asOrbDone
            asOrbHi := math.max(asOrbHi, high)
            asOrbLo := math.min(asOrbLo, low)
            if not na(asTimeStart) and (time - asTimeStart) >= orbMsec
                asOrbDone := true
                asOrbHiLn := line.new(asBarStart, asOrbHi, bar_index, asOrbHi, 
                     color = i_asColor, style = orbLnStyle, width = i_orbWidth)
                asOrbLoLn := line.new(asBarStart, asOrbLo, bar_index, asOrbLo, 
                     color = i_asColor, style = orbLnStyle, width = i_orbWidth)
                asOrbHiLbl := label.new(bar_index, asOrbHi, "ORB-H " + str.tostring(asOrbHi, format.mintick),
                     color = color.new(i_asColor, 85), textcolor = i_asColor,
                     style = label.style_label_left, size = size.tiny)
                asOrbLoLbl := label.new(bar_index, asOrbLo, "ORB-L " + str.tostring(asOrbLo, format.mintick),
                     color = color.new(i_asColor, 85), textcolor = i_asColor,
                     style = label.style_label_left, size = size.tiny)

        if asOrbDone
            if not asOrbBrokeHi and close > asOrbHi
                asOrbBrokeHi := true
            if not asOrbBrokeLo and close < asOrbLo
                asOrbBrokeLo := true

        if asOrbDone and i_orbExtend
            if not na(asOrbHiLn)
                line.set_x2(asOrbHiLn, bar_index)
            if not na(asOrbLoLn)
                line.set_x2(asOrbLoLn, bar_index)

        if not na(asBox)
            box.set_top(asBox, asHi)
            box.set_bottom(asBox, asLo)
            box.set_right(asBox, bar_index)
            box.set_bgcolor(asBox, color.new(i_asColor, calcTransp(asVol, asVolHist)))
        if not na(asSessLbl) and i_showLabels
            label.set_x(asSessLbl, asBarStart)
            label.set_y(asSessLbl, asHi)

    if asClose
        array.push(asRanges,  asHi - asLo)
        array.push(asVolHist, asVol)
        if asOrbBrokeHi or asOrbBrokeLo
            win = (asOrbBrokeHi and close[1] > asOrbHi) or (asOrbBrokeLo and close[1] < asOrbLo)
            array.push(asOrbRes, win ? 1 : 0)
        else
            array.push(asOrbRes, -1)

// ──────────────────────────────────────────────────────────────────────────
//  BREAKOUT SIGNAL MARKERS
// ──────────────────────────────────────────────────────────────────────────

volConfirmed = not na(volSMA) and volume > volSMA * i_volMult

// London ORB breakout arrows
ldnBullBreak = inLdn and ldnOrbDone and not ldnOrbBrokeHi[1] and close > ldnOrbHi and volConfirmed
ldnBearBreak = inLdn and ldnOrbDone and not ldnOrbBrokeLo[1] and close < ldnOrbLo and volConfirmed

if ldnBullBreak
    label.new(bar_index, low, "▲", color = color.new(i_orbBull, 30), textcolor = i_orbBull, 
         style = label.style_label_up, size = size.small, tooltip = "LDN ORB Bull Break | Vol: " + str.tostring(volume, format.volume))
if ldnBearBreak
    label.new(bar_index, high, "▼", color = color.new(i_orbBear, 30), textcolor = i_orbBear, 
         style = label.style_label_down, size = size.small, tooltip = "LDN ORB Bear Break | Vol: " + str.tostring(volume, format.volume))

// NY ORB breakout arrows
nyBullBreak = inNY and nyOrbDone and not nyOrbBrokeHi[1] and close > nyOrbHi and volConfirmed
nyBearBreak = inNY and nyOrbDone and not nyOrbBrokeLo[1] and close < nyOrbLo and volConfirmed

if nyBullBreak
    label.new(bar_index, low, "▲", color = color.new(i_orbBull, 30), textcolor = i_orbBull, 
         style = label.style_label_up, size = size.small, tooltip = "NY ORB Bull Break | Vol: " + str.tostring(volume, format.volume))
if nyBearBreak
    label.new(bar_index, high, "▼", color = color.new(i_orbBear, 30), textcolor = i_orbBear, 
         style = label.style_label_down, size = size.small, tooltip = "NY ORB Bear Break | Vol: " + str.tostring(volume, format.volume))

// Asia ORB breakout arrows
asBullBreak = inAsia and asOrbDone and not asOrbBrokeHi[1] and close > asOrbHi and volConfirmed
asBearBreak = inAsia and asOrbDone and not asOrbBrokeLo[1] and close < asOrbLo and volConfirmed

if asBullBreak
    label.new(bar_index, low, "▲", color = color.new(i_orbBull, 30), textcolor = i_orbBull, 
         style = label.style_label_up, size = size.small, tooltip = "ASIA ORB Bull Break | Vol: " + str.tostring(volume, format.volume))
if asBearBreak
    label.new(bar_index, high, "▼", color = color.new(i_orbBear, 30), textcolor = i_orbBear, 
         style = label.style_label_down, size = size.small, tooltip = "ASIA ORB Bear Break | Vol: " + str.tostring(volume, format.volume))

// Session high/low break signals (previous session levels)
var float prevLdnHi = na, var float prevLdnLo = na
var float prevNyHi  = na, var float prevNyLo  = na
var float prevAsHi  = na, var float prevAsLo  = na

if ldnClose
    prevLdnHi := ldnHi
    prevLdnLo := ldnLo
if nyClose
    prevNyHi := nyHi
    prevNyLo := nyLo
if asClose
    prevAsHi := asHi
    prevAsLo := asLo

// ──────────────────────────────────────────────────────────────────────────
//  UNIFIED SESSION DASHBOARD
// ──────────────────────────────────────────────────────────────────────────

var table dashTbl = na

if barstate.islast and i_showPanel and isIntraday
    // ── Volume calculations
    totalVol = ldnVol + nyVol + asVol
    ldnPct   = totalVol > 0 ? ldnVol / totalVol * 100 : 0
    nyPct    = totalVol > 0 ? nyVol  / totalVol * 100 : 0
    asPct    = totalVol > 0 ? asVol  / totalVol * 100 : 0

    // ── Distribution bars
    maxPct = math.max(ldnPct, math.max(nyPct, asPct))
    ldnBar = maxPct > 0 ? str.repeat("█", math.max(1, int(ldnPct / maxPct * 8))) : ""
    nyBar  = maxPct > 0 ? str.repeat("█", math.max(1, int(nyPct  / maxPct * 8))) : ""
    asBar  = maxPct > 0 ? str.repeat("█", math.max(1, int(asPct  / maxPct * 8))) : ""

    // ── Stats calculations
    ldnAvgR = avgRange(ldnRanges)
    nyAvgR  = avgRange(nyRanges)
    asAvgR  = avgRange(asRanges)
    ldnWR   = orbWinRate(ldnOrbRes)
    nyWR    = orbWinRate(nyOrbRes)
    asWR    = orbWinRate(asOrbRes)

    // ── Color definitions
    cHeader  = color.new(#10141C, 0)
    cSubhead = color.new(#161B22, 0)
    cRow1    = color.new(#0D1117, 0)
    cRow2    = color.new(#12161E, 0)
    cBorder  = color.new(#21262D, 0)
    cLabel   = #6E7681
    cWhite   = #E6EDF3

    // ── Build table: 8 columns × 6 rows
    //    Col: [dot] | Session | Volume | %  | Dist | AvgRng | ORB WR | n=
    dashTbl := table.new(getPos(i_panelPos), 8, 6, bgcolor = cRow1, border_color = cBorder, border_width = 1)

    // ── Row 0: Title bar
    table.cell(dashTbl, 0, 0, "  ⚡  SESSION DASHBOARD                      [StrixEDGE]  ", text_color = cWhite, text_size = tblSz, bgcolor = cHeader, text_halign = text.align_left)
    for col = 1 to 7
        table.cell(dashTbl, col, 0, "", bgcolor = cHeader)
    table.merge_cells(dashTbl, 0, 0, 7, 0)

    // ── Row 1: Separator accent
    for col = 0 to 7
        table.cell(dashTbl, col, 1, "", bgcolor = color.new(#00B8D4, 70), text_size = size.auto)
    table.merge_cells(dashTbl, 0, 1, 7, 1)

    // ── Row 2: Column headers
    table.cell(dashTbl, 0, 2, "",          text_color = cLabel, text_size = tblSz, bgcolor = cSubhead)
    table.cell(dashTbl, 1, 2, " Session ", text_color = cLabel, text_size = tblSz, bgcolor = cSubhead, text_halign = text.align_left)
    table.cell(dashTbl, 2, 2, " Volume ",  text_color = cLabel, text_size = tblSz, bgcolor = cSubhead, text_halign = text.align_right)
    table.cell(dashTbl, 3, 2, " Vol % ",   text_color = cLabel, text_size = tblSz, bgcolor = cSubhead, text_halign = text.align_right)
    table.cell(dashTbl, 4, 2, " Dist ",    text_color = cLabel, text_size = tblSz, bgcolor = cSubhead, text_halign = text.align_left)
    table.cell(dashTbl, 5, 2, " Avg Rng ", text_color = cLabel, text_size = tblSz, bgcolor = cSubhead, text_halign = text.align_right)
    table.cell(dashTbl, 6, 2, " ORB WR ",  text_color = cLabel, text_size = tblSz, bgcolor = cSubhead, text_halign = text.align_right)
    table.cell(dashTbl, 7, 2, " n ",       text_color = cLabel, text_size = tblSz, bgcolor = cSubhead, text_halign = text.align_right)

    // ── Row 3: London
    table.cell(dashTbl, 0, 3, "  ●  ",     text_color = i_ldnColor, text_size = tblSz, bgcolor = cRow1)
    table.cell(dashTbl, 1, 3, " LDN ",     text_color = i_ldnColor, text_size = tblSz, bgcolor = cRow1, text_halign = text.align_left)
    table.cell(dashTbl, 2, 3, " " + str.tostring(ldnVol, format.volume) + " ", text_color = cWhite, text_size = tblSz, bgcolor = cRow1, text_halign = text.align_right)
    table.cell(dashTbl, 3, 3, " " + str.tostring(ldnPct, "#.0") + "% ",        text_color = i_ldnColor, text_size = tblSz, bgcolor = cRow1, text_halign = text.align_right)
    table.cell(dashTbl, 4, 3, " " + ldnBar + " ",                               text_color = i_ldnColor, text_size = tblSz, bgcolor = cRow1, text_halign = text.align_left)
    table.cell(dashTbl, 5, 3, " " + fmtRange(ldnAvgR) + " ",                    text_color = cWhite, text_size = tblSz, bgcolor = cRow1, text_halign = text.align_right)
    table.cell(dashTbl, 6, 3, " " + fmtWR(ldnWR) + " ",                         text_color = wrColor(ldnWR), text_size = tblSz, bgcolor = cRow1, text_halign = text.align_right)
    table.cell(dashTbl, 7, 3, " " + str.tostring(array.size(ldnRanges)) + " ",  text_color = cLabel, text_size = tblSz, bgcolor = cRow1, text_halign = text.align_right)

    // ── Row 4: New York (alt row color)
    table.cell(dashTbl, 0, 4, "  ●  ",     text_color = i_nyColor, text_size = tblSz, bgcolor = cRow2)
    table.cell(dashTbl, 1, 4, " NY ",      text_color = i_nyColor, text_size = tblSz, bgcolor = cRow2, text_halign = text.align_left)
    table.cell(dashTbl, 2, 4, " " + str.tostring(nyVol, format.volume) + " ",  text_color = cWhite, text_size = tblSz, bgcolor = cRow2, text_halign = text.align_right)
    table.cell(dashTbl, 3, 4, " " + str.tostring(nyPct, "#.0") + "% ",         text_color = i_nyColor, text_size = tblSz, bgcolor = cRow2, text_halign = text.align_right)
    table.cell(dashTbl, 4, 4, " " + nyBar + " ",                                text_color = i_nyColor, text_size = tblSz, bgcolor = cRow2, text_halign = text.align_left)
    table.cell(dashTbl, 5, 4, " " + fmtRange(nyAvgR) + " ",                     text_color = cWhite, text_size = tblSz, bgcolor = cRow2, text_halign = text.align_right)
    table.cell(dashTbl, 6, 4, " " + fmtWR(nyWR) + " ",                          text_color = wrColor(nyWR), text_size = tblSz, bgcolor = cRow2, text_halign = text.align_right)
    table.cell(dashTbl, 7, 4, " " + str.tostring(array.size(nyRanges)) + " ",   text_color = cLabel, text_size = tblSz, bgcolor = cRow2, text_halign = text.align_right)

    // ── Row 5: Asia
    table.cell(dashTbl, 0, 5, "  ●  ",     text_color = i_asColor, text_size = tblSz, bgcolor = cRow1)
    table.cell(dashTbl, 1, 5, " ASIA ",    text_color = i_asColor, text_size = tblSz, bgcolor = cRow1, text_halign = text.align_left)
    table.cell(dashTbl, 2, 5, " " + str.tostring(asVol, format.volume) + " ",  text_color = cWhite, text_size = tblSz, bgcolor = cRow1, text_halign = text.align_right)
    table.cell(dashTbl, 3, 5, " " + str.tostring(asPct, "#.0") + "% ",         text_color = i_asColor, text_size = tblSz, bgcolor = cRow1, text_halign = text.align_right)
    table.cell(dashTbl, 4, 5, " " + asBar + " ",                                text_color = i_asColor, text_size = tblSz, bgcolor = cRow1, text_halign = text.align_left)
    table.cell(dashTbl, 5, 5, " " + fmtRange(asAvgR) + " ",                     text_color = cWhite, text_size = tblSz, bgcolor = cRow1, text_halign = text.align_right)
    table.cell(dashTbl, 6, 5, " " + fmtWR(asWR) + " ",                          text_color = wrColor(asWR), text_size = tblSz, bgcolor = cRow1, text_halign = text.align_right)
    table.cell(dashTbl, 7, 5, " " + str.tostring(array.size(asRanges)) + " ",   text_color = cLabel, text_size = tblSz, bgcolor = cRow1, text_halign = text.align_right)

// ──────────────────────────────────────────────────────────────────────────
//  ALERT CONDITIONS
// ──────────────────────────────────────────────────────────────────────────

// ORB Breakout Alerts (volume-confirmed)
alertcondition(ldnBullBreak, "LDN ORB Bull Break", "🟢 London ORB bullish breakout with volume confirmation")
alertcondition(ldnBearBreak, "LDN ORB Bear Break", "🔴 London ORB bearish breakout with volume confirmation")
alertcondition(nyBullBreak,  "NY ORB Bull Break",  "🟢 New York ORB bullish breakout with volume confirmation")
alertcondition(nyBearBreak,  "NY ORB Bear Break",  "🔴 New York ORB bearish breakout with volume confirmation")
alertcondition(asBullBreak,  "ASIA ORB Bull Break", "🟢 Asia ORB bullish breakout with volume confirmation")
alertcondition(asBearBreak,  "ASIA ORB Bear Break", "🔴 Asia ORB bearish breakout with volume confirmation")

// Session High/Low Break Alerts
sessHiBreak = (not na(prevLdnHi) and ta.crossover(close, prevLdnHi) and volConfirmed) or
              (not na(prevNyHi)  and ta.crossover(close, prevNyHi)  and volConfirmed) or
              (not na(prevAsHi)  and ta.crossover(close, prevAsHi)  and volConfirmed)
sessLoBreak = (not na(prevLdnLo) and ta.crossunder(close, prevLdnLo) and volConfirmed) or
              (not na(prevNyLo)  and ta.crossunder(close, prevNyLo)  and volConfirmed) or
              (not na(prevAsLo)  and ta.crossunder(close, prevAsLo)  and volConfirmed)

alertcondition(sessHiBreak, "Session High Break", "⬆️ Price broke previous session high with volume")
alertcondition(sessLoBreak, "Session Low Break",  "⬇️ Price broke previous session low with volume")

// Any ORB break (unified)
anyOrbBreak = ldnBullBreak or ldnBearBreak or nyBullBreak or nyBearBreak or asBullBreak or asBearBreak
alertcondition(anyOrbBreak, "Any ORB Break", "⚡ ORB breakout detected with volume confirmation")

// ──────────────────────────────────────────────────────────────────────────
//  END — Session Kill Zone Volume Map [StrixEDGE]
// ──────────────────────────────────────────────────────────────────────────
````
