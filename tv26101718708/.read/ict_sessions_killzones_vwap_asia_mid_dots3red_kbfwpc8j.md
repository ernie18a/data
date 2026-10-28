# ICT Sessions & Killzones - VWAP + Asia Mid [Dots3Red]

- url: https://www.tradingview.com/script/kBfWpC8j-ICT-Sessions-Killzones-VWAP-Asia-Mid-Dots3Red/
- type: indicator
- pine_id: PUB;066879321b104c8c8227599ced1c63ea
- version: 1.0

## Description

█ [b]ICT SESSIONS & KILLZONES — VWAP + ASIA MID[/b]
This script visualizes the four major forex trading sessions alongside the four ICT killzone windows, with three analytical additions that most session scripts do not include: [i]a per-session VWAP line, a Daily Open reference, and an Asia range midpoint[/i] that extends forward into the London and New York sessions.

It works on intraday timeframes. The number of historical session days displayed is configurable.


█ [b]SESSIONS[/b]
Four sessions are available, each independently toggleable:
•  [b]Tokyo[/b] — 09:00–18:00 Asia/Tokyo
•  [b]London[/b] — 08:00–17:00 Europe/London
•  [b]New York[/b] — 09:30–16:00 America/New_York
•  [b]Sydney[/b] — 07:00–16:00 Australia/Sydney (off by default)

Each session draws a high/low line pair with a soft glow layer behind it, a midpoint dotted line at 50% of the session range, and optional quartile lines at 25% and 75%. A semi-transparent fill box covers the active session range and fades when the session closes. Historical sessions are preserved as lighter boxes and lines, controlled by the [i]Historical Sessions (days)[/i] setting.

Session labels are positioned at the horizontal midpoint of the session and display the session name, current range in points, the range as a percentage of ATR(14), and the live VWAP value.

When two sessions are active simultaneously — London and New York from approximately 13:00–17:00 UTC, or Tokyo and London around 07:00–09:00 UTC — an overlap box is drawn over that window in a distinct color.

█ [b]ICT KILLZONES[/b]
All four ICT killzone windows are implemented, each individually toggleable under a master switch:
•  [b]Asia KZ[/b] — 20:00–00:00 America/New_York
•  [b]London Open KZ[/b] — 02:00–05:00 America/New_York
•  [b]NY Open KZ[/b] — 07:00–10:00 America/New_York
•  [b]London Close KZ[/b] — 10:00–12:00 America/New_York

Each killzone box uses a dotted border when closed and switches to a solid border while the window is currently active. This makes it immediately clear at a glance whether a killzone is live or historical.

Most published session scripts include only two killzones (London Open and NY Open). The Asia and London Close windows are included here because they are part of the complete ICT framework — the Asia killzone in particular is where a significant portion of daily liquidity is engineered before the London session opens.


█ [b]SESSION VWAP[/b]
A VWAP line is calculated independently for each session. It resets to zero at each session open and accumulates using the standard (High + Low + Close) / 3 × Volume formula throughout the session. This is not a daily or weekly VWAP — it is a session-scoped VWAP that resets with each new Tokyo, London, and New York open.

Price above the session VWAP indicates the session is currently net bullish in terms of volume-weighted price. Price below indicates net bearish. The VWAP value is also shown in the live metrics table and in the session label.

Sydney VWAP is not calculated as volume data on that session is generally unreliable outside of ASX-listed instruments.

█ [b]DAILY OPEN LINE[/b]
A horizontal line is drawn at the price level at which the new day opened — specifically at midnight New York time (00:00 America/New_York). This corresponds to the ICT "00:00 line" or daily open reference, which is used in ICT methodology as a key intraday reference level for assessing whether price is trading at a premium or discount relative to the daily range.

The line extends forward through the trading day and refreshes at each midnight NY transition.

█ [b]ASIA RANGE MIDPOINT EXTENSION[/b]
When the Tokyo session closes, the midpoint of its high-low range is calculated and projected forward as a dashed line into the London and New York sessions. This level — the 50% point of the Asian range — is referenced in ICT methodology as a key intraday equilibrium. London and New York sessions frequently interact with this level before establishing directional bias.

This extension is drawn automatically and requires no manual input. It is toggled by the [i]Asia Range Mid Extension[/i] setting.


█ [b]LIVE METRICS TABLE[/b]
A table in the corner of the chart displays eight columns for each active session:

•  [b]SESSION[/b] — name, color-coded to the session
•  [b]STATUS[/b] — ACTIVE or CLOSED
•  [b]RANGE (PTS)[/b] — current range in price ticks
•  [b]% ATR[/b] — range expressed as a percentage of ATR(14)
•  [b]VWAP DEV[/b] — current close deviation from session VWAP in percent (green = above, red = below)
•  [b]VS PREV %[/b] — current session range versus the equivalent previous session's range (green = larger, red = smaller)
•  [b]HIGH / LOW[/b] — current session extremes

The bottom row shows whether a session overlap is currently active.


█ [b]HISTORICAL DISPLAY[/b]
The [i]Historical Sessions (days)[/i] input controls how many past session blocks remain visible. The script uses a millisecond-based time window rather than a bar count, so the lookback is stable across different timeframes. Setting this to 1 shows only the current day's sessions. Setting it to 5 retains the last five days. Objects beyond the limit are deleted automatically to manage Pine's drawing object limits.


█ [b]ALERTS[/b]
Eleven alert conditions are available:
•  Tokyo, London, New York session opens and closes (6 alerts)
•  Asia KZ, London Open KZ, NY Open KZ, London Close KZ starts (4 alerts)
•  London + New York overlap start (1 alert)

[image]https://www.tradingview.com/x/myyL9zJ7/[/image]

█ [b]NOTES[/b]
•  Designed for intraday timeframes. Most useful at 5-minute through 1-hour.
•  Session times adjust automatically for daylight saving time because timezone identifiers (America/New_York, Europe/London, etc.) are used rather than fixed UTC offsets.
•  The Tokyo session uses Asia/Tokyo exchange hours (09:00–18:00). Forex traders who prefer the broader Asian session window (00:00–09:00 UTC) can adjust the time string in the source code.
•  All session boxes and killzone boxes are gated to the historical window. Objects outside the configured lookback are not drawn, which keeps performance stable on lower timeframes with many bars.


█ [b]DISCLAIMER[/b]
This is a visualization tool for session timing and reference levels. It does not generate trade signals and does not constitute financial advice. Past price behavior within or around session windows does not predict future results.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Dots3Red
// TradingView: https://www.tradingview.com/u/Dots3Red/

//@version=6
indicator("ICT Sessions & Killzones — VWAP + Asia Mid [Dots3Red] CyberHUD",
          shorttitle       = "ICT Sessions & Killzones [Dots3Red]",
          max_lines_count  = 500,
          max_labels_count = 500,
          max_boxes_count  = 500,
          overlay          = true)

//  VISUAL  PALETTE
color COL_TK       = color.new(#ff007f, 0)  // Tokyo    
color COL_LN       = color.new(#00f0ff, 0)  // London   
color COL_NY       = color.new(#39ff14, 0)  // New York 
color COL_SD       = color.new(#ffaa00, 0)  // Sydney   
color COL_OV_LNNY  = color.new(#ff5500, 0)  // LN+NY Overlap 
color COL_OV_TKLN  = color.new(#bd00ff, 0)  // TK+LN Overlap —
color COL_KZ_AS    = color.new(#ff007f, 0)  // Asia KZ  
color COL_KZ_LN    = color.new(#00f0ff, 0)  // London Open KZ
color COL_KZ_NY    = color.new(#39ff14, 0)  // NY Open KZ 
color COL_KZ_LC    = color.new(#ff003c, 0)  // London Close KZ 
color COL_DAILY    = color.new(#ffffff, 0)  // Daily Open — Pure 
color COL_ASIA_MID = color.new(#ff007f, 0)  // Asia Mid Extension — Laser Pink

color HDR_BG   = color.new(#090d16, 0)      
color HDR_TXT  = color.new(#f8fafc, 0)      
color ROW_BG   = color.new(#131722, 30)     
color CELL_TXT = color.new(#cbd5e1, 0)      

// INPUTS
var grp_gen  = "⚙️ General"
var grp_sess = "🌐 Sessions"
var grp_kz   = "⚡ ICT Killzones"
var grp_ref  = "📐 Reference Levels"
var grp_vis  = "🎨 Visuals"

// General
showTable     = input.bool(true,  "Show Session Table",             group=grp_gen)
showMidpoint  = input.bool(true,  "Show Session Midpoint",          group=grp_gen)
showQuartiles = input.bool(false, "Show Quartile Lines",            group=grp_gen)
showLabels    = input.bool(true,  "Show Open/Close Labels",         group=grp_gen)
showOverlap   = input.bool(true,  "Show Overlap Zones",             group=grp_gen)
showPrevHL    = input.bool(false, "Show Prev Session H/L",          group=grp_gen)
showATR       = input.bool(true,  "Show Range as % ATR",            group=grp_gen)
hist_days     = input.int (3,     "Historical Sessions (days)",     group=grp_gen, minval=1, maxval=10)

// Sessions
showTokyo  = input.bool(false,  "Tokyo",    group=grp_sess)
showLondon = input.bool(true,  "London",   group=grp_sess)
showNY     = input.bool(true,  "New York", group=grp_sess)
showSydney = input.bool(false, "Sydney",   group=grp_sess)

// Killzones
showKZ    = input.bool(true,  "⚡ ENABLE KILLZONES MASTER SWITCH", group=grp_kz)
showKZ_AS = input.bool(true,  "└── Asia KZ (20:00–00:00 NY)",       group=grp_kz)
showKZ_LN = input.bool(true,  "└── London Open KZ (02:00–05:00 NY)", group=grp_kz)
showKZ_NY = input.bool(true,  "└── NY Open KZ (07:00–10:00 NY)",     group=grp_kz)
showKZ_LC = input.bool(true,  "└── London Close KZ (10:00–12:00 NY)",group=grp_kz)

// Reference levels
showDailyOpen = input.bool(true, "Daily Open (midnight NY)",        group=grp_ref)
showAsiaMid   = input.bool(true, "Asia Range Mid Extension",        group=grp_ref)
showVWAP      = input.bool(true, "Session VWAP",                    group=grp_ref)
showBoxFill   = input.bool(true, "Active Session Box Fill",         group=grp_vis)

// TIME  & HISTORY TIME FILTER GUARD
inSydney = not na(time(timeframe.period, "0700-1600",  "Australia/Sydney"))
inTokyo  = not na(time(timeframe.period, "0900-1800",  "Asia/Tokyo"))
inLondon = not na(time(timeframe.period, "0800-1700",  "Europe/London"))
inNY     = not na(time(timeframe.period, "0930-1600",  "America/New_York"))

useKZ_AS = showKZ and showKZ_AS
useKZ_LN = showKZ and showKZ_LN
useKZ_NY = showKZ and showKZ_NY
useKZ_LC = showKZ and showKZ_LC

inKZ_AS  = useKZ_AS and not na(time(timeframe.period, "2000-0000",  "America/New_York"))
inKZ_LN  = useKZ_LN and not na(time(timeframe.period, "0200-0500",  "America/New_York"))
inKZ_NY  = useKZ_NY and not na(time(timeframe.period, "0700-1000",  "America/New_York"))
inKZ_LC  = useKZ_LC and not na(time(timeframe.period, "1000-1200",  "America/New_York"))

inMidnight = not na(time(timeframe.period, "0000-0001", "America/New_York"))

// Window Calculation (1440 mins/day converted to ms)
var int max_back_time = hist_days * 1440 * 60 * 1000
bool inside_historical_window = (timenow - time) <= max_back_time

// Session Boundaries
tokyoOpen   = inTokyo  and not inTokyo[1]
tokyoClose  = not inTokyo  and inTokyo[1]
londonOpen  = inLondon and not inLondon[1]
londonClose = not inLondon and inLondon[1]
nyOpen      = inNY     and not inNY[1]
nyClose     = not inNY     and inNY[1]
sydneyOpen  = inSydney and not inSydney[1]
sydneyClose = not inSydney and inSydney[1]

// Killzone Boundaries
kzAsStart  = inKZ_AS and not inKZ_AS[1]
kzAsEnd    = not inKZ_AS and inKZ_AS[1]
kzLnStart  = inKZ_LN and not inKZ_LN[1]
kzLnEnd    = not inKZ_LN and inKZ_LN[1]
kzNyStart  = inKZ_NY and not inKZ_NY[1]
kzNyEnd    = not inKZ_NY and inKZ_NY[1]
kzLcStart  = inKZ_LC and not inKZ_LC[1]
kzLcEnd    = not inKZ_LC and inKZ_LC[1]

// Overlaps
bool overlapLN_NY = inLondon and inNY
bool overlapTK_LN = inTokyo  and inLondon
overlapLN_NY_Start = overlapLN_NY and not (inLondon[1] and inNY[1])
overlapLN_NY_End   = not overlapLN_NY and (inLondon[1] and inNY[1])
overlapTK_LN_Start = overlapTK_LN and not (inTokyo[1] and inLondon[1])
overlapTK_LN_End   = not overlapTK_LN and (inTokyo[1] and inLondon[1])

atr14 = ta.atr(14)

hline_new(int x, float y, color col, int w, string sty) =>
    line.new(x, y, x, y, color=col, width=w, style=sty, force_overlay=true)

updateLines(line top, line bot, line glowT, line glowB, line mid, line q1, line q3, int startX, float hi, float lo, color col, bool dispMid, bool dispQ) =>
    _range = hi - lo
    midY = lo + _range * 0.50
    q1Y  = lo + _range * 0.25
    q3Y  = lo + _range * 0.75
    line.set_x1(top, startX), line.set_x2(top, bar_index)
    line.set_x1(bot, startX), line.set_x2(bot, bar_index)
    line.set_x1(glowT, startX), line.set_x2(glowT, bar_index)
    line.set_x1(glowB, startX), line.set_x2(glowB, bar_index)
    line.set_y1(top, hi), line.set_y2(top, hi)
    line.set_y1(bot, lo), line.set_y2(bot, lo)
    line.set_y1(glowT, hi), line.set_y2(glowT, hi)
    line.set_y1(glowB, lo), line.set_y2(glowB, lo)
    line.set_x1(mid, startX), line.set_x2(mid, bar_index)
    line.set_x1(q1, startX),  line.set_x2(q1, bar_index)
    line.set_x1(q3, startX),  line.set_x2(q3, bar_index)
    line.set_y1(mid, midY), line.set_y2(mid, midY)
    line.set_y1(q1,  q1Y),  line.set_y2(q1,  q1Y)
    line.set_y1(q3,  q3Y),  line.set_y2(q3,  q3Y)
    line.set_color(mid, dispMid ? color.new(col, 40) : color.new(col, 100))
    line.set_color(q1,  dispQ   ? color.new(col, 65) : color.new(col, 100))
    line.set_color(q3,  dispQ   ? color.new(col, 65) : color.new(col, 100))

lockLines(line top, line bot, line glowT, line glowB, line mid, line q1, line q3) =>
    line.set_x2(top, bar_index), line.set_x2(bot, bar_index)
    line.set_x2(glowT, bar_index), line.set_x2(glowB, bar_index)
    line.set_x2(mid, bar_index), line.set_x2(q1, bar_index), line.set_x2(q3, bar_index)

spawnSession(int x, float hi, float lo, color col) =>
    glow = color.new(col, 85)
    top  = hline_new(x, hi, col,  1, line.style_solid)
    bot  = hline_new(x, lo, col,  1, line.style_solid)
    glT  = hline_new(x, hi, glow, 5, line.style_solid)
    glB  = hline_new(x, lo, glow, 5, line.style_solid)
    mid  = hline_new(x, (hi+lo)/2,       color.new(col, 40), 1, line.style_dotted)
    q1   = hline_new(x, lo+(hi-lo)*0.25, color.new(col, 65), 1, line.style_dashed)
    q3   = hline_new(x, lo+(hi-lo)*0.75, color.new(col, 65), 1, line.style_dashed)
    [top, bot, glT, glB, mid, q1, q3]

type SessionLines
    line t
    line b
    line gt
    line gb
    line m
    line q1
    line q3
    label lbl

spawnPrevHL(float pH, float pL, color col) =>
    lH = line.new(bar_index, pH, bar_index, pH, color=color.new(col, 50), width=1, style=line.style_dashed, force_overlay=true)
    lL = line.new(bar_index, pL, bar_index, pL, color=color.new(col, 50), width=1, style=line.style_dashed, force_overlay=true)
    [lH, lL]

extendPrevHL(line lH, line lL, float pH, float pL) =>
    line.set_x2(lH, bar_index), line.set_y1(lH, pH), line.set_y2(lH, pH)
    line.set_x2(lL, bar_index), line.set_y1(lL, pL), line.set_y2(lL, pL)

buildLabel(int x, float hi, float lo, string name, color col) =>
    label.new(x, hi * 1.002, text=name, style=label.style_label_down, size=size.small, color=color.new(col, 85), textcolor=col, force_overlay=true)

updateLabel(label lbl, int midX, float midY, float hi, float lo, string name, float vwapVal) =>
    if not na(lbl) and showLabels
        rangeStr = "\n" + str.tostring(math.round((hi - lo) / syminfo.mintick)) + "pts\n"
        text_atrStr   = (not na(atr14) and atr14 > 0) ? "  " + str.tostring(math.round((hi - lo) / atr14 * 100)) + " %ATR" : ""
        text_vwapStr  = (not na(vwapVal)) ? "\nVWAP " + str.tostring(math.round(vwapVal, 2)) : ""
        label.set_x(lbl, midX)
        label.set_y(lbl, midY)
        label.set_style(lbl, label.style_label_down)
        label.set_text(lbl, name + "  " + rangeStr + text_atrStr + text_vwapStr)

pruneExtraBoxes(box[] targetArray, int limit) =>
    if array.size(targetArray) > limit
        box.delete(array.pop(targetArray))

pruneExtraLines(SessionLines[] targetArray, int limit) =>
    if array.size(targetArray) > limit
        SessionLines old = array.pop(targetArray)
        line.delete(old.t), line.delete(old.b)
        line.delete(old.gt), line.delete(old.gb)
        line.delete(old.m), line.delete(old.q1), line.delete(old.q3)
        label.delete(old.lbl)

// STATE MANAGEMENT 
var float tkHigh = na, var float tkLow = na, var int tkStart = na
var float lnHigh = na, var float lnLow = na, var int lnStart = na
var float nyHigh = na, var float nyLow = na, var int nyStart = na
var float sdHigh = na, var float sdLow = na, var int sdStart = na

var float tkPrevH = na, var float tkPrevL = na
var float lnPrevH = na, var float lnPrevL = na
var float nyPrevH = na, var float nyPrevL = na
var float sdPrevH = na, var float sdPrevL = na

var line tkPrevHLine = na, var line tkPrevLLine = na
var line lnPrevHLine = na, var line lnPrevLLine = na
var line nyPrevHLine = na, var line nyPrevLLine = na
var line sdPrevHLine = na, var line sdPrevLLine = na

var int lnnyStart = na, var float lnnyHigh = na, var float lnnyLow = na, var box lnnyBox = na
var int tklnStart = na, var float tklnHigh = na, var float tklnLow = na, var box tklnBox = na

var line tkTop=na, var line tkBot=na, var line tkGlowT=na, var line tkGlowB=na
var line lnTop=na, var line lnBot=na, var line lnGlowT=na, var line lnGlowB=na
var line nyTop=na, var line nyBot=na, var line nyGlowT=na, var line nyGlowB=na
var line sdTop=na, var line sdBot=na, var line sdGlowT=na, var line sdGlowB=na
var line tkMid=na, var line tkQ1=na, var line tkQ3=na
var line lnMid=na, var line lnQ1=na, var line lnQ3=na
var line nyMid=na, var line nyQ1=na, var line nyQ3=na
var line sdMid=na, var line sdQ1=na, var line sdQ3=na
var label tkLbl=na, var label lnLbl=na, var label nyLbl=na, var label sdLbl=na
var box tkBox = na, var box lnBox = na, var box nyBox = na, var box sdBox = na

var box[] tkHistBox = array.new<box>()
var box[] lnHistBox = array.new<box>()
var box[] nyHistBox = array.new<box>()
var box[] sdHistBox = array.new<box>()

var SessionLines[] tkHistLines = array.new<SessionLines>()
var SessionLines[] lnHistLines = array.new<SessionLines>()
var SessionLines[] nyHistLines = array.new<SessionLines>()
var SessionLines[] sdHistLines = array.new<SessionLines>()

var float tkVwapNum=0.0, var float tkVwapDen=0.0, var float tkVwap=na
var float lnVwapNum=0.0, var float lnVwapDen=0.0, var float lnVwap=na
var float nyVwapNum=0.0, var float nyVwapDen=0.0, var float nyVwap=na
var line tkVwapLine=na, var line lnVwapLine=na, var line nyVwapLine=na

var float dailyOpenPrice = na
var line  dailyOpenLine  = na
var float tkMidPrice = na
var line  tkMidExt   = na

var int kzAsIdx=na,  var float kzAsHi=na,  var float kzAsLo=na,  var box kzAsBox=na
var int kzLnIdx=na,  var float kzLnHi=na,  var float kzLnLo=na,  var box kzLnBox=na
var int kzNyIdx=na,  var float kzNyHi=na,  var float kzNyLo=na,  var box kzNyBox=na
var int kzLcIdx=na,  var float kzLcHi=na,  var float kzLcLo=na,  var box kzLcBox=na

// REFERENCE BEACONS
if inMidnight and not inMidnight[1]
    dailyOpenPrice := open
    if showDailyOpen and inside_historical_window
        if not na(dailyOpenLine)
            line.delete(dailyOpenLine)
        dailyOpenLine := line.new(bar_index, dailyOpenPrice, bar_index, dailyOpenPrice, color=color.new(COL_DAILY, 60), width=1, style=line.style_solid, force_overlay=true)

if showDailyOpen and not na(dailyOpenLine)
    line.set_x2(dailyOpenLine, bar_index)

// TOKYO
if tokyoOpen and showTokyo
    tkPrevH := tkHigh, tkPrevL := tkLow
    tkHigh := high, tkLow := low, tkStart := bar_index
    tkVwapNum := ((high + low + close) / 3) * volume
    tkVwapDen := volume
    tkVwap    := (high + low + close) / 3

    if not na(tkBox)
        box.delete(tkBox)
    if showBoxFill
        tkBox := box.new(bar_index, high, bar_index, low, border_color=color.new(COL_TK, 100), bgcolor=color.new(COL_TK, 94), force_overlay=true)

    [a, b, c, d, e, f, g] = spawnSession(bar_index, high, low, COL_TK)
    tkTop:=a, tkBot:=b, tkGlowT:=c, tkGlowB:=d, tkMid:=e, tkQ1:=f, tkQ3:=g
    tkLbl := buildLabel(bar_index, high, low, "TOKYO", COL_TK)

    if showPrevHL and not na(tkPrevH)
        [lH, lL] = spawnPrevHL(tkPrevH, tkPrevL, COL_TK)
        tkPrevHLine := lH, tkPrevLLine := lL

    if showVWAP
        if not na(tkVwapLine)
            line.delete(tkVwapLine)
        tkVwapLine := line.new(bar_index, tkVwap, bar_index, tkVwap, color=color.new(COL_TK, 40), width=2, style=line.style_dotted, force_overlay=true)

if inTokyo and showTokyo
    tkHigh := math.max(tkHigh, high)
    tkLow  := math.min(tkLow,  low)
    tkVwapNum += ((high + low + close) / 3) * volume
    tkVwapDen += volume
    tkVwap     := tkVwapDen > 0 ? tkVwapNum / tkVwapDen : na

    updateLines(tkTop, tkBot, tkGlowT, tkGlowB, tkMid, tkQ1, tkQ3, tkStart, tkHigh, tkLow, COL_TK, showMidpoint, showQuartiles)
    
    int tkMidX = tkStart + math.round((bar_index - tkStart) / 2)
    float tkMidY = tkHigh * 1.001
    updateLabel(tkLbl, tkMidX, tkMidY, tkHigh, tkLow, "TOKYO", tkVwap)

    if showBoxFill and not na(tkBox)
        box.set_top(tkBox,  tkHigh), box.set_bottom(tkBox, tkLow), box.set_right(tkBox, bar_index)
    if showVWAP and not na(tkVwapLine)
        line.set_x2(tkVwapLine, bar_index), line.set_y1(tkVwapLine, tkVwap), line.set_y2(tkVwapLine, tkVwap)
    if showPrevHL and not na(tkPrevHLine)
        extendPrevHL(tkPrevHLine, tkPrevLLine, tkPrevH, tkPrevL)

if tokyoClose and showTokyo
    lockLines(tkTop, tkBot, tkGlowT, tkGlowB, tkMid, tkQ1, tkQ3)
    SessionLines currentLines = SessionLines.new(tkTop, tkBot, tkGlowT, tkGlowB, tkMid, tkQ1, tkQ3, tkLbl)
    array.unshift(tkHistLines, currentLines)

    if not na(tkBox)
        box.set_bgcolor(tkBox, color.new(COL_TK, 93))
        box.set_border_color(tkBox, color.new(COL_TK, 75))
        array.unshift(tkHistBox, tkBox)

    tkMidPrice := tkLow + (tkHigh - tkLow) * 0.5
    if showAsiaMid and not na(tkMidPrice) and inside_historical_window
        if not na(tkMidExt)
            line.delete(tkMidExt)
        tkMidExt := line.new(bar_index, tkMidPrice, bar_index, tkMidPrice, color=color.new(COL_ASIA_MID, 45), width=1, style=line.style_dashed, force_overlay=true)

if showAsiaMid and not na(tkMidExt) and not inTokyo
    line.set_x2(tkMidExt, bar_index)

// LONDON
if londonOpen and showLondon
    lnPrevH := lnHigh, lnPrevL := lnLow
    lnHigh := high, lnLow := low, lnStart := bar_index
    lnVwapNum := ((high + low + close) / 3) * volume
    lnVwapDen := volume
    lnVwap    := (high + low + close) / 3

    if not na(lnBox)
        box.delete(lnBox)
    if showBoxFill
        lnBox := box.new(bar_index, high, bar_index, low, border_color=color.new(COL_LN, 100), bgcolor=color.new(COL_LN, 94), force_overlay=true)

    [a, b, c, d, e, f, g] = spawnSession(bar_index, high, low, COL_LN)
    lnTop:=a, lnBot:=b, lnGlowT:=c, lnGlowB:=d, lnMid:=e, lnQ1:=f, lnQ3:=g
    lnLbl := buildLabel(bar_index, high, low, "LONDON", COL_LN)

    if showPrevHL and not na(lnPrevH)
        [lH, lL] = spawnPrevHL(lnPrevH, lnPrevL, COL_LN)
        lnPrevHLine := lH, lnPrevLLine := lL

    if showVWAP
        if not na(lnVwapLine)
            line.delete(lnVwapLine)
        lnVwapLine := line.new(bar_index, lnVwap, bar_index, lnVwap, color=color.new(COL_LN, 40), width=2, style=line.style_dotted, force_overlay=true)

if inLondon and showLondon
    lnHigh := math.max(lnHigh, high)
    lnLow  := math.min(lnLow,  low)
    lnVwapNum += ((high + low + close) / 3) * volume
    lnVwapDen += volume
    lnVwap     := lnVwapDen > 0 ? lnVwapNum / lnVwapDen : na

    updateLines(lnTop, lnBot, lnGlowT, lnGlowB, lnMid, lnQ1, lnQ3, lnStart, lnHigh, lnLow, COL_LN, showMidpoint, showQuartiles)
    
    int lnMidX = lnStart + math.round((bar_index - lnStart) / 2)
    float lnMidY = lnHigh * 1.001
    updateLabel(lnLbl, lnMidX, lnMidY, lnHigh, lnLow, "LONDON", lnVwap)

    if showBoxFill and not na(lnBox)
        box.set_top(lnBox, lnHigh), box.set_bottom(lnBox, lnLow), box.set_right(lnBox, bar_index)
    if showVWAP and not na(lnVwapLine)
        line.set_x2(lnVwapLine, bar_index), line.set_y1(lnVwapLine, lnVwap), line.set_y2(lnVwapLine, lnVwap)
    if showPrevHL and not na(lnPrevHLine)
        extendPrevHL(lnPrevHLine, lnPrevLLine, lnPrevH, lnPrevL)

if londonClose and showLondon
    lockLines(lnTop, lnBot, lnGlowT, lnGlowB, lnMid, lnQ1, lnQ3)
    SessionLines currentLines = SessionLines.new(lnTop, lnBot, lnGlowT, lnGlowB, lnMid, lnQ1, lnQ3, lnLbl)
    array.unshift(lnHistLines, currentLines)

    if not na(lnBox)
        box.set_bgcolor(lnBox, color.new(COL_LN, 93))
        box.set_border_color(lnBox, color.new(COL_LN, 75))
        array.unshift(lnHistBox, lnBox)

// NEW YORK
if nyOpen and showNY
    nyPrevH := nyHigh, nyPrevL := nyLow
    nyHigh := high, nyLow := low, nyStart := bar_index
    nyVwapNum := ((high + low + close) / 3) * volume
    nyVwapDen := volume
    nyVwap    := (high + low + close) / 3

    if not na(nyBox)
        box.delete(nyBox)
    if showBoxFill
        nyBox := box.new(bar_index, high, bar_index, low, border_color=color.new(COL_NY, 100), bgcolor=color.new(COL_NY, 94), force_overlay=true)

    [a, b, c, d, e, f, g] = spawnSession(bar_index, high, low, COL_NY)
    nyTop:=a, nyBot:=b, nyGlowT:=c, nyGlowB:=d, nyMid:=e, nyQ1:=f, nyQ3:=g
    nyLbl := buildLabel(bar_index, high, low, "NEW YORK", COL_NY)

    if showPrevHL and not na(nyPrevH)
        [lH, lL] = spawnPrevHL(nyPrevH, nyPrevL, COL_NY)
        nyPrevHLine := lH, nyPrevLLine := lL

    if showVWAP
        if not na(nyVwapLine)
            line.delete(nyVwapLine)
        nyVwapLine := line.new(bar_index, nyVwap, bar_index, nyVwap, color=color.new(COL_NY, 40), width=2, style=line.style_dotted, force_overlay=true)

if inNY and showNY
    nyHigh := math.max(nyHigh, high)
    nyLow  := math.min(nyLow,  low)
    nyVwapNum += ((high + low + close) / 3) * volume
    nyVwapDen += volume
    nyVwap     := nyVwapDen > 0 ? nyVwapNum / nyVwapDen : na

    updateLines(nyTop, nyBot, nyGlowT, nyGlowB, nyMid, nyQ1, nyQ3, nyStart, nyHigh, nyLow, color.new(COL_NY,30), showMidpoint, showQuartiles)
    
    int nyMidX = nyStart + math.round((bar_index - nyStart) / 2)
    float nyMidY = nyHigh * 1.001
    updateLabel(nyLbl, nyMidX, nyMidY, nyHigh, nyLow, "NEW YORK", nyVwap)

    if showBoxFill and not na(nyBox)
        box.set_top(nyBox, nyHigh), box.set_bottom(nyBox, nyLow), box.set_right(nyBox, bar_index)
    if showVWAP and not na(nyVwapLine)
        line.set_x2(nyVwapLine, bar_index), line.set_y1(nyVwapLine, nyVwap), line.set_y2(nyVwapLine, nyVwap)
    if showPrevHL and not na(nyPrevHLine)
        extendPrevHL(nyPrevHLine, nyPrevLLine, nyPrevH, nyPrevL)

if nyClose and showNY
    lockLines(nyTop, nyBot, nyGlowT, nyGlowB, nyMid, nyQ1, nyQ3)
    SessionLines currentLines = SessionLines.new(nyTop, nyBot, nyGlowT, nyGlowB, nyMid, nyQ1, nyQ3, nyLbl)
    array.unshift(nyHistLines, currentLines)

    if not na(nyBox)
        box.set_bgcolor(nyBox, color.new(COL_NY, 93))
        box.set_border_color(nyBox, color.new(COL_NY, 75))
        box.set_border_width(nyBox,1)
        array.unshift(nyHistBox, nyBox)

// SYDNEY
if sydneyOpen and showSydney
    sdPrevH := sdHigh, sdPrevL := sdLow
    sdHigh := high, sdLow := low, sdStart := bar_index

    if not na(sdBox)
        box.delete(sdBox)
    if showBoxFill
        sdBox := box.new(bar_index, high, bar_index, low, border_color=color.new(COL_SD, 100), bgcolor=color.new(COL_SD, 94), force_overlay=true)

    [a, b, c, d, e, f, g] = spawnSession(bar_index, high, low, COL_SD)
    sdTop:=a, sdBot:=b, sdGlowT:=c, sdGlowB:=d, sdMid:=e, sdQ1:=f, sdQ3:=g
    sdLbl := buildLabel(bar_index, high, low, "SYDNEY", COL_SD)

    if showPrevHL and not na(sdPrevH)
        [lH, lL] = spawnPrevHL(sdPrevH, sdPrevL, COL_SD)
        sdPrevHLine := lH, sdPrevLLine := lL

if inSydney and showSydney
    sdHigh := math.max(sdHigh, high)
    sdLow  := math.min(sdLow,  low)

    updateLines(sdTop, sdBot, sdGlowT, sdGlowB, sdMid, sdQ1, sdQ3, sdStart, sdHigh, sdLow, COL_SD, showMidpoint, showQuartiles)
    
    int sdMidX = sdStart + math.round((bar_index - sdStart) / 2)
    float sdMidY = sdHigh * 1.001
    updateLabel(sdLbl, sdMidX, sdMidY, sdHigh, sdLow, "SYDNEY", na)

    if showBoxFill and not na(sdBox)
        box.set_top(sdBox, sdHigh), box.set_bottom(sdBox, sdLow), box.set_right(sdBox, bar_index)
    if showPrevHL and not na(sdPrevHLine)
        extendPrevHL(sdPrevHLine, sdPrevLLine, sdPrevH, sdPrevL)

if sydneyClose and showSydney
    lockLines(sdTop, sdBot, sdGlowT, sdGlowB, sdMid, sdQ1, sdQ3)
    SessionLines currentLines = SessionLines.new(sdTop, sdBot, sdGlowT, sdGlowB, sdMid, sdQ1, sdQ3, sdLbl)
    array.unshift(sdHistLines, currentLines)

    if not na(sdBox)
        box.set_bgcolor(sdBox, color.new(COL_SD, 93))
        box.set_border_color(sdBox, color.new(COL_SD, 75))
        array.unshift(sdHistBox, sdBox)

//  INTRA-SESSION OVERLAPS
if showOverlap and inside_historical_window
    if overlapLN_NY_Start
        lnnyStart := bar_index, lnnyHigh := high, lnnyLow := low
        lnnyBox := box.new(lnnyStart, lnnyHigh, bar_index, lnnyLow, border_color=COL_OV_LNNY, border_width=1, bgcolor=color.new(COL_OV_LNNY, 94), text="⚡ LN+NY", text_color=COL_OV_LNNY, text_size=size.small, text_font_family=font.family_monospace, text_valign=text.align_top, text_halign=text.align_left, force_overlay=true)
    if overlapLN_NY and not na(lnnyBox)
        lnnyHigh := math.max(lnnyHigh, high), lnnyLow := math.min(lnnyLow, low)
        box.set_top(lnnyBox, lnnyHigh), box.set_bottom(lnnyBox, lnnyLow), box.set_right(lnnyBox, bar_index)
    if overlapLN_NY_End and not na(lnnyBox)
        box.set_right(lnnyBox, bar_index)

    if overlapTK_LN_Start
        tklnStart := bar_index, tklnHigh := high, tklnLow := low
        tklnBox := box.new(tklnStart, tklnHigh, bar_index, tklnLow, border_color=COL_OV_TKLN, border_width=1, bgcolor=color.new(COL_OV_TKLN, 94), text="⚡ TK+LN", text_color=COL_OV_TKLN, text_size=size.small, text_font_family=font.family_monospace, text_valign=text.align_top, text_halign=text.align_left, force_overlay=true)
    if overlapTK_LN and not na(tklnBox)
        tklnHigh := math.max(tklnHigh, high), tklnLow := math.min(tklnLow, low)
        box.set_top(tklnBox, tklnHigh), box.set_bottom(tklnBox, tklnLow), box.set_right(tklnBox, bar_index)
    if overlapTK_LN_End and not na(tklnBox)
        box.set_right(tklnBox, bar_index)

// ALL 4 ICT KILLZONES
if showKZ and inside_historical_window
    // Asia Killzone
    if showKZ_AS
        if kzAsStart
            kzAsIdx := bar_index, kzAsHi := high, kzAsLo := low
            kzAsBox := box.new(kzAsIdx, kzAsHi, bar_index, kzAsLo, border_color=COL_KZ_AS, border_width=1, border_style=line.style_dotted, bgcolor=color.new(COL_KZ_AS, 93), text="ASIA KZ", text_color=COL_KZ_AS, text_size=size.small, text_font_family=font.family_monospace, text_valign=text.align_top, text_halign=text.align_right, force_overlay=true)
        if inKZ_AS and not na(kzAsBox)
            kzAsHi := math.max(kzAsHi, high), kzAsLo := math.min(kzAsLo, low)
            box.set_top(kzAsBox, kzAsHi), box.set_bottom(kzAsBox, kzAsLo), box.set_right(kzAsBox, bar_index)
            box.set_border_style(kzAsBox, line.style_solid)
        if kzAsEnd and not na(kzAsBox)
            box.set_right(kzAsBox, bar_index)
            box.set_border_style(kzAsBox, line.style_dotted)

    // London Open Killzone
    if showKZ_LN
        if kzLnStart
            kzLnIdx := bar_index, kzLnHi := high, kzLnLo := low
            kzLnBox := box.new(kzLnIdx, kzLnHi, bar_index, kzLnLo, border_color=COL_KZ_LN, border_width=1, border_style=line.style_dotted, bgcolor=color.new(COL_KZ_LN, 92), text="LN O KZ", text_color=COL_KZ_LN, text_size=size.small, text_font_family=font.family_monospace, text_valign=text.align_top, text_halign=text.align_right, force_overlay=true)
        if inKZ_LN and not na(kzLnBox)
            kzLnHi := math.max(kzLnHi, high), kzLnLo := math.min(kzLnLo, low)
            box.set_top(kzLnBox, kzLnHi), box.set_bottom(kzLnBox, kzLnLo), box.set_right(kzLnBox, bar_index)
            box.set_border_style(kzLnBox, line.style_solid)
        if kzLnEnd and not na(kzLnBox)
            box.set_right(kzLnBox, bar_index)
            box.set_border_style(kzLnBox, line.style_dotted)

    // New York Open Killzone
    if showKZ_NY
        if kzNyStart
            kzNyIdx := bar_index, kzNyHi := high, kzNyLo := low
            kzNyBox := box.new(kzNyIdx, kzNyHi, bar_index, kzNyLo, border_color=COL_KZ_NY, border_width=1, border_style=line.style_dotted, bgcolor=color.new(COL_KZ_NY, 92), text="NY O KZ", text_color=COL_KZ_NY, text_size=size.small, text_font_family=font.family_monospace, text_valign=text.align_top, text_halign=text.align_right, force_overlay=true)
        if inKZ_NY and not na(kzNyBox)
            kzNyHi := math.max(kzNyHi, high), kzNyLo := math.min(kzNyLo, low)
            box.set_top(kzNyBox, kzNyHi), box.set_bottom(kzNyBox, kzNyLo), box.set_right(kzNyBox, bar_index)
            box.set_border_style(kzNyBox, line.style_solid)
        if kzNyEnd and not na(kzNyBox)
            box.set_right(kzNyBox, bar_index)
            box.set_border_style(kzNyBox, line.style_dotted)

    // London Close Killzone
    if showKZ_LC
        if kzLcStart
            kzLcIdx := bar_index, kzLcHi := high, kzLcLo := low
            kzLcBox := box.new(kzLcIdx, kzLcHi, bar_index, kzLcLo, border_color=COL_KZ_LC, border_width=1, border_style=line.style_dotted, bgcolor=color.new(COL_KZ_LC, 93), text="LN CLOSE KZ", text_color=COL_KZ_LC, text_size=size.small, text_font_family=font.family_monospace, text_valign=text.align_top, text_halign=text.align_right, force_overlay=true)
        if inKZ_LC and not na(kzLcBox)
            kzLcHi := math.max(kzLcHi, high), kzLcLo := math.min(kzLcLo, low)
            box.set_top(kzLcBox, kzLcHi), box.set_bottom(kzLcBox, kzLcLo), box.set_right(kzLcBox, bar_index)
            box.set_border_style(kzLcBox, line.style_solid)
            //box.set_xloc(kzLcBox, )
        if kzLcEnd and not na(kzLcBox)
            box.set_right(kzLcBox, bar_index)
            box.set_border_style(kzLcBox, line.style_dotted)

// GLOBAL GARBAGE COLLECTION 
pruneExtraLines(tkHistLines, hist_days)
pruneExtraBoxes(tkHistBox,   hist_days)
pruneExtraLines(lnHistLines, hist_days)
pruneExtraBoxes(lnHistBox,   hist_days)
pruneExtraLines(nyHistLines, hist_days)
pruneExtraBoxes(nyHistBox,   hist_days)
pruneExtraLines(sdHistLines, hist_days)
pruneExtraBoxes(sdHistBox,   hist_days)

// TABLE
f_getSessData(string statStr, float hi, float lo, float prevH, float prevL, float vwapVal, bool isCurrent) =>
    color statCol = isCurrent ? color.new(#10b981, 0) : color.new(#64748b, 0)
    
    float rngPts = (not na(hi) and not na(lo)) ? (hi - lo) / syminfo.mintick : na
    string rngStr = not na(rngPts) ? str.tostring(math.round(rngPts)) : "-"
    
    string atrStr = "-"
    if not na(hi) and not na(lo) and not na(atr14) and atr14 > 0
        atrStr := str.tostring(math.round(((hi - lo) / atr14) * 100)) + "%"
        
    string devStr = "-"
    color  devCol = CELL_TXT
    if isCurrent and not na(vwapVal) and vwapVal > 0
        devPercent = ((close - vwapVal) / vwapVal) * 100
        devStr := (devPercent > 0 ? "+" : "") + str.tostring(devPercent, "2") + "%"
        devCol := devPercent > 0 ? color.new(#39ff14, 0) : color.new(#ff003c, 0)
        
    string vsPrevStr = "-"
    color  vsCol     = CELL_TXT
    if not na(hi) and not na(lo) and not na(prevH) and not na(prevL) and (prevH - prevL) > 0
        currRng = hi - lo
        oldRng  = prevH - prevL
        vsPercent = ((currRng - oldRng) / oldRng) * 100
        vsPrevStr := (vsPercent > 0 ? "+" : "") + str.tostring(vsPercent, "0") + "%"
        vsCol     := vsPercent > 0 ? color.new(#39ff14, 0) : color.new(#ff003c, 0)
        
    string hStr = not na(hi) ? str.tostring(hi, "2") : "-"
    string lStr = not na(lo) ? str.tostring(lo, "2") : "-"
    [statStr, statCol, rngStr, atrStr, devStr, devCol, vsPrevStr, vsCol, hStr, lStr]

var table sess_tbl = table.new(position.top_right, 8, 6, bgcolor=color.new(#090d16, 20), border_width=1, border_color=color.new(#1e293b, 0))

f_fillTable() =>
    table.cell(sess_tbl, 0, 0, "SESSION",      text_color=HDR_TXT,  bgcolor=HDR_BG,   text_size=size.small)
    table.cell(sess_tbl, 1, 0, "STATUS",       text_color=HDR_TXT,  bgcolor=HDR_BG,   text_size=size.small)
    table.cell(sess_tbl, 2, 0, "RANGE (PTS)",  text_color=HDR_TXT,  bgcolor=HDR_BG,   text_size=size.small)
    table.cell(sess_tbl, 3, 0, "% ATR",        text_color=HDR_TXT,  bgcolor=HDR_BG,   text_size=size.small)
    table.cell(sess_tbl, 4, 0, "VWAP DEV",     text_color=HDR_TXT,  bgcolor=HDR_BG,   text_size=size.small)
    table.cell(sess_tbl, 5, 0, "VS PREV %",    text_color=HDR_TXT,  bgcolor=HDR_BG,   text_size=size.small)
    table.cell(sess_tbl, 6, 0, "HIGH",         text_color=HDR_TXT,  bgcolor=HDR_BG,   text_size=size.small)
    table.cell(sess_tbl, 7, 0, "LOW",          text_color=HDR_TXT,  bgcolor=HDR_BG,   text_size=size.small)

    string tkLabelStr = inTokyo   ? "ACTIVE" : "CLOSED"
    string lnLabelStr = inLondon  ? "ACTIVE" : "CLOSED"
    string nyLabelStr = inNY      ? "ACTIVE" : "CLOSED"
    string sdLabelStr = inSydney  ? "ACTIVE" : "CLOSED"

    // Tokyo Row
    [tkStat, tkSCol, tkRng, tkAtr, tkDev, tkDCol, tkVs, tkVCol, tkH, tkL] = f_getSessData(tkLabelStr, tkHigh, tkLow, tkPrevH, tkPrevL, tkVwap, inTokyo)
    table.cell(sess_tbl, 0, 1, "Tokyo",        text_color=COL_TK,    bgcolor=ROW_BG,   text_size=size.small)
    table.cell(sess_tbl, 1, 1, tkStat,         text_color=tkSCol,    bgcolor=ROW_BG,   text_size=size.small)
    table.cell(sess_tbl, 2, 1, tkRng,          text_color=CELL_TXT,  bgcolor=ROW_BG,   text_size=size.small)
    table.cell(sess_tbl, 3, 1, tkAtr,          text_color=CELL_TXT,  bgcolor=ROW_BG,   text_size=size.small)
    table.cell(sess_tbl, 4, 1, tkDev,          text_color=tkDCol,    bgcolor=ROW_BG,   text_size=size.small)
    table.cell(sess_tbl, 5, 1, tkVs,           text_color=tkVCol,    bgcolor=ROW_BG,   text_size=size.small)
    table.cell(sess_tbl, 6, 1, tkH,            text_color=CELL_TXT,  bgcolor=ROW_BG,   text_size=size.small)
    table.cell(sess_tbl, 7, 1, tkL,            text_color=CELL_TXT,  bgcolor=ROW_BG,   text_size=size.small)

    // London Row
    [lnStat, lnSCol, lnRng, lnAtr, lnDev, lnDCol, lnVs, lnVCol, lnH, lnL] = f_getSessData(lnLabelStr, lnHigh, lnLow, lnPrevH, lnPrevL, lnVwap, inLondon)
    table.cell(sess_tbl, 0, 2, "London",       text_color=COL_LN,    bgcolor=ROW_BG,   text_size=size.small)
    table.cell(sess_tbl, 1, 2, lnStat,         text_color=lnSCol,    bgcolor=ROW_BG,   text_size=size.small)
    table.cell(sess_tbl, 2, 2, lnRng,          text_color=CELL_TXT,  bgcolor=ROW_BG,   text_size=size.small)
    table.cell(sess_tbl, 3, 2, lnAtr,          text_color=CELL_TXT,  bgcolor=ROW_BG,   text_size=size.small)
    table.cell(sess_tbl, 4, 2, lnDev,          text_color=lnDCol,    bgcolor=ROW_BG,   text_size=size.small)
    table.cell(sess_tbl, 5, 2, lnVs,           text_color=lnVCol,    bgcolor=ROW_BG,   text_size=size.small)
    table.cell(sess_tbl, 6, 2, lnH,            text_color=CELL_TXT,  bgcolor=ROW_BG,   text_size=size.small)
    table.cell(sess_tbl, 7, 2, lnL,            text_color=CELL_TXT,  bgcolor=ROW_BG,   text_size=size.small)

    // New York Row
    [nyStat, nySCol, nyRng, nyAtr, nyDev, nyDCol, nyVs, nyVCol, nyH, nyL] = f_getSessData(nyLabelStr, nyHigh, nyLow, nyPrevH, nyPrevL, nyVwap, inNY)
    table.cell(sess_tbl, 0, 3, "New York",     text_color=COL_NY,    bgcolor=ROW_BG,   text_size=size.small)
    table.cell(sess_tbl, 1, 3, nyStat,         text_color=nySCol,    bgcolor=ROW_BG,   text_size=size.small)
    table.cell(sess_tbl, 2, 3, nyRng,          text_color=CELL_TXT,  bgcolor=ROW_BG,   text_size=size.small)
    table.cell(sess_tbl, 3, 3, nyAtr,          text_color=CELL_TXT,  bgcolor=ROW_BG,   text_size=size.small)
    table.cell(sess_tbl, 4, 3, nyDev,          text_color=nyDCol,    bgcolor=ROW_BG,   text_size=size.small)
    table.cell(sess_tbl, 5, 3, nyVs,           text_color=nyVCol,    bgcolor=ROW_BG,   text_size=size.small)
    table.cell(sess_tbl, 6, 3, nyH,            text_color=CELL_TXT,  bgcolor=ROW_BG,   text_size=size.small)
    table.cell(sess_tbl, 7, 3, nyL,            text_color=CELL_TXT,  bgcolor=ROW_BG,   text_size=size.small)

    // Sydney Row
    [sdStat, sdSCol, sdRng, sdAtr, sdDev, sdDCol, sdVs, sdVCol, sdH, sdL] = f_getSessData(sdLabelStr, sdHigh, sdLow, sdPrevH, sdPrevL, na, inSydney)
    table.cell(sess_tbl, 0, 4, "Sydney",       text_color=COL_SD,    bgcolor=ROW_BG,   text_size=size.small)
    table.cell(sess_tbl, 1, 4, sdStat,         text_color=sdSCol,    bgcolor=ROW_BG,   text_size=size.small)
    table.cell(sess_tbl, 2, 4, sdRng,          text_color=CELL_TXT,  bgcolor=ROW_BG,   text_size=size.small)
    table.cell(sess_tbl, 3, 4, sdAtr,          text_color=CELL_TXT,  bgcolor=ROW_BG,   text_size=size.small)
    table.cell(sess_tbl, 4, 4, sdDev,          text_color=sdDCol,    bgcolor=ROW_BG,   text_size=size.small)
    table.cell(sess_tbl, 5, 4, sdVs,           text_color=sdVCol,    bgcolor=ROW_BG,   text_size=size.small)
    table.cell(sess_tbl, 6, 4, sdH,            text_color=CELL_TXT,  bgcolor=ROW_BG,   text_size=size.small)
    table.cell(sess_tbl, 7, 4, sdL,            text_color=CELL_TXT,  bgcolor=ROW_BG,   text_size=size.small)

    // Overlaps Active Matrix Tracker Block
    string ovTxt = "SYSTEM HUD: NO ACTIVE OVERLAPS"
    color  ovCol = color.new(#475569, 0)
    color  ovBg  = color.new(#090d16, 40)
    if overlapLN_NY
        ovTxt := "⚠️ INTERSESSION OVERLAP: LONDON + NEW YORK"
        ovCol := COL_OV_LNNY
        ovBg  := color.new(COL_OV_LNNY, 93)
    else if overlapTK_LN
        ovTxt := "⚠️ INTERSESSION OVERLAP: TOKYO + LONDON"
        ovCol := COL_OV_TKLN
        ovBg  := color.new(COL_OV_TKLN, 93)
        
    table.cell(sess_tbl, 0, 5, "OVERLAP",      text_color=HDR_TXT,   bgcolor=HDR_BG,   text_size=size.small)
    table.cell(sess_tbl, 1, 5, ovTxt,          text_color=ovCol,     bgcolor=ovBg,     text_size=size.small)
    table.merge_cells(sess_tbl, 1, 5, 7, 5)

if showTable and barstate.islast
    f_fillTable()

// ALERTS
alertcondition(tokyoOpen,          "Tokyo Open",          "🔴 Tokyo session opened")
alertcondition(tokyoClose,         "Tokyo Close",         "🔴 Tokyo session closed")
alertcondition(londonOpen,         "London Open",         "🔵 London session opened")
alertcondition(londonClose,        "London Close",        "🔵 London session closed")
alertcondition(nyOpen,             "New York Open",       "🟢 New York session opened")
alertcondition(nyClose,            "New York Close",      "🟢 New York session closed")
alertcondition(kzAsStart,          "Asia KZ Start",       "🔴 Asia killzone started (20:00 NY)")
alertcondition(kzLnStart,          "London KZ Start",     "🔵 London KZ started (02:00 NY)")
alertcondition(kzNyStart,          "NY Open KZ Start",    "🟢 NY open killzone started (07:00 NY)")
alertcondition(kzLcStart,          "London Close KZ",     "🟠 London close killzone started (10:00 NY)")
alertcondition(overlapLN_NY_Start, "LN+NY Overlap Start", "⚠️ London + NY overlap period active")
````
