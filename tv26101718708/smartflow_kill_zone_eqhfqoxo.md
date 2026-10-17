# SmartFlow Kill Zone

- url: https://www.tradingview.com/script/EqhFqoxO-SmartFlow-Kill-Zone/
- type: indicator
- pine_id: PUB;802fbab7702548a29a6edddaa60c62ff
- version: 1.0

## Description

SmartFlow Kill Zone highlights the three major trading sessions (Tokyo, London, New York) and their corresponding ICT Kill Zones directly on your chart. Designed for intraday traders who use session-based and Smart Money Concepts (SMC) strategies, this indicator gives you instant visual clarity on when high-probability trading windows are active.
 
█ WHAT IT DOES
 
This indicator identifies and displays the three global forex sessions and three ICT Kill Zones using distinct background colors. It also tracks the High and Low of each session in real time and draws horizontal reference lines that update as the session progresses.
 
A built-in dashboard provides a quick overview of which sessions and Kill Zones are currently active, along with each session's range in pips.
 
█ HOW IT WORKS
 
Session and Kill Zone detection is based on time-of-day logic using the user-selected timezone (default: America/New_York):
 
Sessions:
 - Tokyo: 19:00 – 04:00 ET
 - London: 03:00 – 12:00 ET
 - New York: 08:00 – 17:00 ET
 
Kill Zones (ICT):
 - London Kill Zone: 02:00 – 05:00 ET
 - New York Kill Zone: 07:00 – 10:00 ET
 - Asian Kill Zone: 20:00 – 00:00 ET (off by default)
 
Session High/Low lines are drawn from the session's opening bar and updated on every new bar during the session. When a session closes, lines optionally extend to the right until the next session of the same type begins. Previous sessions' High/Low lines are preserved across multiple days (configurable via "Days to Display").
 
The dashboard table uses the last bar's data to show open/closed status, the session's current range, and whether any Kill Zone is active.
 
█ HOW TO USE
 
 - Apply the indicator to any intraday chart (1m to 1h recommended).
 - Use the background shading to quickly identify which session you are trading in.
 - The brighter Kill Zone overlay tells you when the highest-probability reversal windows are active — this is where ICT traders look for optimal trade entries.
 - Session High/Low lines act as key reference levels. Price often reacts at these levels as they represent session-based liquidity.
 - The dashboard gives you a heads-up display so you never miss a Kill Zone activation.
 
█ FEATURES
 
 - Three session backgrounds with independent on/off toggles
 - Three ICT Kill Zone backgrounds with independent on/off toggles
 - Real-time Session High/Low tracking with configurable line style and width
 - High/Low labels that update live during the session
 - "Extend Lines Right" option for lines to project forward until the next session
 - Multi-day history (up to 30 days of past session H/L lines)
 - Dashboard with session status, range (pips), and Kill Zone status
 - Dashboard position and size are fully customizable
 - 9 alert conditions (session open/close and Kill Zone activation)
 - Full timezone support (10 major timezones)
 - Works on any symbol and any intraday timeframe
 
█ SETTINGS
 
Sessions — Toggle visibility for Tokyo, London, and New York sessions.
Kill Zones — Toggle each ICT Kill Zone independently. Asian KZ is off by default.
Colors — Customize background colors for each session and Kill Zone.
Session High/Low — Toggle H/L lines and labels, set line width, style, and right extension.
Dashboard — Toggle, reposition, and resize the info panel.
Timezone — Select the timezone used for session calculations.
History — Set how many days of past session H/L lines to display (1–30).
 
█ NOTES
 
 - This indicator does not generate buy or sell signals. It provides session structure and timing context to support your own trading strategy and decision-making.
 - Kill Zone times are based on the ICT (Inner Circle Trader) framework. Different educators may define slightly different windows.
 - For best results, use on timeframes of 1 hour or lower where session boundaries are clearly visible.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SmartFlow2026

//@version=6
indicator("SmartFlow Kill Zone", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// ══════════════════════════════════════════════════════════════════════════════
// ▌ INPUTS
// ══════════════════════════════════════════════════════════════════════════════

string GRP_SESS = "Sessions"
bool i_showTokyo    = input.bool(true,  "Tokyo Session",     group=GRP_SESS)
bool i_showLondon   = input.bool(true,  "London Session",    group=GRP_SESS)
bool i_showNY       = input.bool(true,  "New York Session",  group=GRP_SESS)

string GRP_KZ = "Kill Zones (ICT)"
bool i_showKZ_LDN   = input.bool(true,  "London Kill Zone",  group=GRP_KZ, tooltip="02:00–05:00 NY Time")
bool i_showKZ_NY    = input.bool(true,  "New York Kill Zone", group=GRP_KZ, tooltip="07:00–10:00 NY Time")
bool i_showKZ_ASIA  = input.bool(false, "Asian Kill Zone",   group=GRP_KZ, tooltip="20:00–00:00 NY Time")

string GRP_CLR = "Colors"
color i_colTokyo    = input.color(color.new(#FF9800, 88), "Tokyo BG",       group=GRP_CLR)
color i_colLondon   = input.color(color.new(#2196F3, 88), "London BG",      group=GRP_CLR)
color i_colNY       = input.color(color.new(#E91E63, 88), "New York BG",    group=GRP_CLR)
color i_colKZ_LDN   = input.color(color.new(#00BCD4, 80), "KZ London BG",   group=GRP_CLR)
color i_colKZ_NY    = input.color(color.new(#FF5722, 80), "KZ New York BG",  group=GRP_CLR)
color i_colKZ_ASIA  = input.color(color.new(#9C27B0, 80), "KZ Asian BG",    group=GRP_CLR)

string GRP_HL = "Session High / Low"
bool i_showHL       = input.bool(true,   "Show Session High/Low", group=GRP_HL)
int  i_lineWidth    = input.int(1,       "Line Width",            group=GRP_HL, minval=1, maxval=4)
string i_lineStyle  = input.string("Dashed", "Line Style",        group=GRP_HL, options=["Solid", "Dashed", "Dotted"])
bool i_showHLLabels = input.bool(true,   "Show H/L Labels",       group=GRP_HL)
bool i_extendLines  = input.bool(true,   "Extend Lines Right",    group=GRP_HL, tooltip="Extend H/L lines to the right edge of the chart")

string GRP_DASH = "Dashboard"
bool   i_showDash   = input.bool(true,       "Show Dashboard", group=GRP_DASH)
string i_dashPos    = input.string("Top Right", "Position",    group=GRP_DASH, options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])
string i_dashSize   = input.string("Normal", "Size",           group=GRP_DASH, options=["Small", "Normal", "Large"])

string GRP_TZ = "Timezone"
string i_tz = input.string("America/New_York", "Session Timezone", group=GRP_TZ, options=["America/New_York", "America/Chicago", "America/Los_Angeles", "Europe/London", "Europe/Berlin", "Asia/Tokyo", "Asia/Shanghai", "Asia/Kolkata", "Australia/Sydney", "UTC"])

string GRP_HIST = "History"
int i_maxDays = input.int(5, "Days to Display", group=GRP_HIST, minval=1, maxval=30)

// ══════════════════════════════════════════════════════════════════════════════
// ▌ HELPERS
// ══════════════════════════════════════════════════════════════════════════════

f_lineStyle(string s) =>
    switch s
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        => line.style_dotted

f_dashTextSize(string s) =>
    switch s
        "Small"  => size.small
        "Large"  => size.large
        => size.normal

f_inSession(int startH, int startM, int endH, int endM) =>
    int hh = hour(time, i_tz)
    int mm = minute(time, i_tz)
    int nowMin = hh * 60 + mm
    int startMin = startH * 60 + startM
    int endMin   = endH * 60 + endM
    if startMin < endMin
        nowMin >= startMin and nowMin < endMin
    else
        nowMin >= startMin or nowMin < endMin

f_withinDays() =>
    bar_index >= last_bar_index - i_maxDays * 1440 / timeframe.multiplier

f_rangePips(float pH, float pL) =>
    if na(pH) or na(pL)
        "—"
    else
        float pts = pH - pL
        float pips = pts / syminfo.mintick / (syminfo.mintick < 0.01 ? 10 : 1)
        str.tostring(pips, "#.#")

int MAX_LINES = i_maxDays * 3

f_trimLines(array<line> arr, int maxSize) =>
    while arr.size() > maxSize
        line.delete(arr.shift())

f_trimLabels(array<label> arr, int maxSize) =>
    while arr.size() > maxSize
        label.delete(arr.shift())

// ══════════════════════════════════════════════════════════════════════════════
// ▌ SESSION DETECTION
// ══════════════════════════════════════════════════════════════════════════════

bool tokyoNow  = f_inSession(19, 0, 4, 0)
bool londonNow = f_inSession(3, 0, 12, 0)
bool nyNow     = f_inSession(8, 0, 17, 0)

bool kzLdnNow  = f_inSession(2, 0, 5, 0)
bool kzNYNow   = f_inSession(7, 0, 10, 0)
bool kzAsiaNow = f_inSession(20, 0, 0, 0)

// ══════════════════════════════════════════════════════════════════════════════
// ▌ SESSION H/L — ARRAY-BASED (persists across multiple sessions)
// ══════════════════════════════════════════════════════════════════════════════

//──────────────────────────────────────────────────────────────────────────────
// TOKYO
//──────────────────────────────────────────────────────────────────────────────
var float  tkyH     = na
var float  tkyL     = na
var int    tkyStart = na
var bool   tkyPrev  = false
var line   tkyHCur  = na
var line   tkyLCur  = na
var label  tkyHLbl  = na
var label  tkyLLbl  = na
var array<line>  tkyLines  = array.new<line>()
var array<label> tkyLabels = array.new<label>()
color TKY_LINE_COL = color.new(#FF9800, 0)

// Session open
if tokyoNow and not tkyPrev
    tkyH     := high
    tkyL     := low
    tkyStart := bar_index
    if f_withinDays() and i_showTokyo and i_showHL
        tkyHCur := line.new(bar_index, high, bar_index, high, color=TKY_LINE_COL, width=i_lineWidth, style=f_lineStyle(i_lineStyle))
        tkyLCur := line.new(bar_index, low, bar_index, low, color=TKY_LINE_COL, width=i_lineWidth, style=f_lineStyle(i_lineStyle))
        if i_showHLLabels
            tkyHLbl := label.new(bar_index, high, "TKY H", color=color.new(color.black, 100), textcolor=TKY_LINE_COL, style=label.style_label_left, size=size.tiny)
            tkyLLbl := label.new(bar_index, low, "TKY L", color=color.new(color.black, 100), textcolor=TKY_LINE_COL, style=label.style_label_left, size=size.tiny)

// During session — update H/L, lines, and labels
if tokyoNow and not na(tkyH)
    if high > tkyH
        tkyH := high
    if low < tkyL
        tkyL := low
    if not na(tkyHCur)
        line.set_y1(tkyHCur, tkyH)
        line.set_y2(tkyHCur, tkyH)
        line.set_x2(tkyHCur, bar_index)
    if not na(tkyLCur)
        line.set_y1(tkyLCur, tkyL)
        line.set_y2(tkyLCur, tkyL)
        line.set_x2(tkyLCur, bar_index)
    if not na(tkyHLbl)
        label.set_x(tkyHLbl, bar_index)
        label.set_y(tkyHLbl, tkyH)
    if not na(tkyLLbl)
        label.set_x(tkyLLbl, bar_index)
        label.set_y(tkyLLbl, tkyL)

// Session close — finalize
if not tokyoNow and tkyPrev and not na(tkyHCur)
    if i_extendLines
        line.set_extend(tkyHCur, extend.right)
        line.set_extend(tkyLCur, extend.right)
    // Labels already exist — move to completed array
    if not na(tkyHLbl)
        tkyLabels.push(tkyHLbl)
        tkyHLbl := na
    if not na(tkyLLbl)
        tkyLabels.push(tkyLLbl)
        tkyLLbl := na
    tkyLines.push(tkyHCur)
    tkyLines.push(tkyLCur)
    tkyHCur := na
    tkyLCur := na
    f_trimLines(tkyLines, MAX_LINES)
    f_trimLabels(tkyLabels, MAX_LINES)

// Stop extending previous lines when new session starts
if tokyoNow and not tkyPrev and i_extendLines and tkyLines.size() >= 2
    line.set_extend(tkyLines.get(tkyLines.size() - 1), extend.none)
    line.set_x2(tkyLines.get(tkyLines.size() - 1), bar_index)
    line.set_extend(tkyLines.get(tkyLines.size() - 2), extend.none)
    line.set_x2(tkyLines.get(tkyLines.size() - 2), bar_index)

tkyPrev := tokyoNow

//──────────────────────────────────────────────────────────────────────────────
// LONDON
//──────────────────────────────────────────────────────────────────────────────
var float  ldnH     = na
var float  ldnL     = na
var int    ldnStart = na
var bool   ldnPrev  = false
var line   ldnHCur  = na
var line   ldnLCur  = na
var label  ldnHLbl  = na
var label  ldnLLbl  = na
var array<line>  ldnLines  = array.new<line>()
var array<label> ldnLabels = array.new<label>()
color LDN_LINE_COL = color.new(#2196F3, 0)

if londonNow and not ldnPrev
    ldnH     := high
    ldnL     := low
    ldnStart := bar_index
    if f_withinDays() and i_showLondon and i_showHL
        ldnHCur := line.new(bar_index, high, bar_index, high, color=LDN_LINE_COL, width=i_lineWidth, style=f_lineStyle(i_lineStyle))
        ldnLCur := line.new(bar_index, low, bar_index, low, color=LDN_LINE_COL, width=i_lineWidth, style=f_lineStyle(i_lineStyle))
        if i_showHLLabels
            ldnHLbl := label.new(bar_index, high, "LDN H", color=color.new(color.black, 100), textcolor=LDN_LINE_COL, style=label.style_label_left, size=size.tiny)
            ldnLLbl := label.new(bar_index, low, "LDN L", color=color.new(color.black, 100), textcolor=LDN_LINE_COL, style=label.style_label_left, size=size.tiny)

if londonNow and not na(ldnH)
    if high > ldnH
        ldnH := high
    if low < ldnL
        ldnL := low
    if not na(ldnHCur)
        line.set_y1(ldnHCur, ldnH)
        line.set_y2(ldnHCur, ldnH)
        line.set_x2(ldnHCur, bar_index)
    if not na(ldnLCur)
        line.set_y1(ldnLCur, ldnL)
        line.set_y2(ldnLCur, ldnL)
        line.set_x2(ldnLCur, bar_index)
    if not na(ldnHLbl)
        label.set_x(ldnHLbl, bar_index)
        label.set_y(ldnHLbl, ldnH)
    if not na(ldnLLbl)
        label.set_x(ldnLLbl, bar_index)
        label.set_y(ldnLLbl, ldnL)

if not londonNow and ldnPrev and not na(ldnHCur)
    if i_extendLines
        line.set_extend(ldnHCur, extend.right)
        line.set_extend(ldnLCur, extend.right)
    if not na(ldnHLbl)
        ldnLabels.push(ldnHLbl)
        ldnHLbl := na
    if not na(ldnLLbl)
        ldnLabels.push(ldnLLbl)
        ldnLLbl := na
    ldnLines.push(ldnHCur)
    ldnLines.push(ldnLCur)
    ldnHCur := na
    ldnLCur := na
    f_trimLines(ldnLines, MAX_LINES)
    f_trimLabels(ldnLabels, MAX_LINES)

if londonNow and not ldnPrev and i_extendLines and ldnLines.size() >= 2
    line.set_extend(ldnLines.get(ldnLines.size() - 1), extend.none)
    line.set_x2(ldnLines.get(ldnLines.size() - 1), bar_index)
    line.set_extend(ldnLines.get(ldnLines.size() - 2), extend.none)
    line.set_x2(ldnLines.get(ldnLines.size() - 2), bar_index)

ldnPrev := londonNow

//──────────────────────────────────────────────────────────────────────────────
// NEW YORK
//──────────────────────────────────────────────────────────────────────────────
var float  nyH     = na
var float  nyL     = na
var int    nyStart = na
var bool   nyPrev  = false
var line   nyHCur  = na
var line   nyLCur  = na
var label  nyHLbl  = na
var label  nyLLbl  = na
var array<line>  nyLines  = array.new<line>()
var array<label> nyLabels = array.new<label>()
color NY_LINE_COL = color.new(#E91E63, 0)

if nyNow and not nyPrev
    nyH     := high
    nyL     := low
    nyStart := bar_index
    if f_withinDays() and i_showNY and i_showHL
        nyHCur := line.new(bar_index, high, bar_index, high, color=NY_LINE_COL, width=i_lineWidth, style=f_lineStyle(i_lineStyle))
        nyLCur := line.new(bar_index, low, bar_index, low, color=NY_LINE_COL, width=i_lineWidth, style=f_lineStyle(i_lineStyle))
        if i_showHLLabels
            nyHLbl := label.new(bar_index, high, "NY H", color=color.new(color.black, 100), textcolor=NY_LINE_COL, style=label.style_label_left, size=size.tiny)
            nyLLbl := label.new(bar_index, low, "NY L", color=color.new(color.black, 100), textcolor=NY_LINE_COL, style=label.style_label_left, size=size.tiny)

if nyNow and not na(nyH)
    if high > nyH
        nyH := high
    if low < nyL
        nyL := low
    if not na(nyHCur)
        line.set_y1(nyHCur, nyH)
        line.set_y2(nyHCur, nyH)
        line.set_x2(nyHCur, bar_index)
    if not na(nyLCur)
        line.set_y1(nyLCur, nyL)
        line.set_y2(nyLCur, nyL)
        line.set_x2(nyLCur, bar_index)
    if not na(nyHLbl)
        label.set_x(nyHLbl, bar_index)
        label.set_y(nyHLbl, nyH)
    if not na(nyLLbl)
        label.set_x(nyLLbl, bar_index)
        label.set_y(nyLLbl, nyL)

if not nyNow and nyPrev and not na(nyHCur)
    if i_extendLines
        line.set_extend(nyHCur, extend.right)
        line.set_extend(nyLCur, extend.right)
    if not na(nyHLbl)
        nyLabels.push(nyHLbl)
        nyHLbl := na
    if not na(nyLLbl)
        nyLabels.push(nyLLbl)
        nyLLbl := na
    nyLines.push(nyHCur)
    nyLines.push(nyLCur)
    nyHCur := na
    nyLCur := na
    f_trimLines(nyLines, MAX_LINES)
    f_trimLabels(nyLabels, MAX_LINES)

if nyNow and not nyPrev and i_extendLines and nyLines.size() >= 2
    line.set_extend(nyLines.get(nyLines.size() - 1), extend.none)
    line.set_x2(nyLines.get(nyLines.size() - 1), bar_index)
    line.set_extend(nyLines.get(nyLines.size() - 2), extend.none)
    line.set_x2(nyLines.get(nyLines.size() - 2), bar_index)

nyPrev := nyNow

// ══════════════════════════════════════════════════════════════════════════════
// ▌ BACKGROUND HIGHLIGHTING
// ══════════════════════════════════════════════════════════════════════════════

bgcolor(i_showTokyo  and tokyoNow  and f_withinDays() ? i_colTokyo  : na, title="Tokyo BG")
bgcolor(i_showLondon and londonNow and f_withinDays() ? i_colLondon : na, title="London BG")
bgcolor(i_showNY     and nyNow     and f_withinDays() ? i_colNY     : na, title="New York BG")
bgcolor(i_showKZ_LDN  and kzLdnNow  and f_withinDays() ? i_colKZ_LDN  : na, title="London KZ BG")
bgcolor(i_showKZ_NY   and kzNYNow   and f_withinDays() ? i_colKZ_NY   : na, title="New York KZ BG")
bgcolor(i_showKZ_ASIA and kzAsiaNow and f_withinDays() ? i_colKZ_ASIA : na, title="Asian KZ BG")

// ══════════════════════════════════════════════════════════════════════════════
// ▌ DASHBOARD
// ══════════════════════════════════════════════════════════════════════════════

color TKY_CLR = color.new(#FFB74D, 0)
color LDN_CLR = color.new(#64B5F6, 0)
color NY_CLR  = color.new(#EF5350, 0)
color HDR_CLR = color.new(#E0E0E0, 0)
color VAL_CLR = color.new(#FFFFFF, 0)
color DIM_CLR = color.new(#999999, 0)
color KZ_CLR  = color.new(#00E676, 0)

if i_showDash and barstate.islast
    string tPos = switch i_dashPos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        => position.bottom_left

    var table dash = table.new(tPos, 4, 5, bgcolor=color.new(#0d1117, 5), border_width=1, border_color=color.new(#30363d, 20), frame_width=2, frame_color=color.new(#30363d, 20))
    string sz = f_dashTextSize(i_dashSize)

    table.cell(dash, 0, 0, "Session",   text_color=HDR_CLR, text_size=sz, bgcolor=color.new(#161b22, 5))
    table.cell(dash, 1, 0, "Status",    text_color=HDR_CLR, text_size=sz, bgcolor=color.new(#161b22, 5))
    table.cell(dash, 2, 0, "Range",     text_color=HDR_CLR, text_size=sz, bgcolor=color.new(#161b22, 5))
    table.cell(dash, 3, 0, "Kill Zone", text_color=HDR_CLR, text_size=sz, bgcolor=color.new(#161b22, 5))

    table.cell(dash, 0, 1, "🌏 Tokyo",  text_color=TKY_CLR, text_size=sz, text_halign=text.align_left)
    table.cell(dash, 1, 1, tokyoNow ? "● OPEN" : "○ Closed", text_color=tokyoNow ? TKY_CLR : DIM_CLR, text_size=sz)
    table.cell(dash, 2, 1, f_rangePips(tkyH, tkyL), text_color=VAL_CLR, text_size=sz)
    table.cell(dash, 3, 1, kzAsiaNow and i_showKZ_ASIA ? "● ACTIVE" : "—", text_color=kzAsiaNow and i_showKZ_ASIA ? KZ_CLR : DIM_CLR, text_size=sz)

    table.cell(dash, 0, 2, "🌍 London", text_color=LDN_CLR, text_size=sz, text_halign=text.align_left)
    table.cell(dash, 1, 2, londonNow ? "● OPEN" : "○ Closed", text_color=londonNow ? LDN_CLR : DIM_CLR, text_size=sz)
    table.cell(dash, 2, 2, f_rangePips(ldnH, ldnL), text_color=VAL_CLR, text_size=sz)
    table.cell(dash, 3, 2, kzLdnNow and i_showKZ_LDN ? "● ACTIVE" : "—", text_color=kzLdnNow and i_showKZ_LDN ? KZ_CLR : DIM_CLR, text_size=sz)

    table.cell(dash, 0, 3, "🌎 New York", text_color=NY_CLR, text_size=sz, text_halign=text.align_left)
    table.cell(dash, 1, 3, nyNow ? "● OPEN" : "○ Closed", text_color=nyNow ? NY_CLR : DIM_CLR, text_size=sz)
    table.cell(dash, 2, 3, f_rangePips(nyH, nyL), text_color=VAL_CLR, text_size=sz)
    table.cell(dash, 3, 3, kzNYNow and i_showKZ_NY ? "● ACTIVE" : "—", text_color=kzNYNow and i_showKZ_NY ? KZ_CLR : DIM_CLR, text_size=sz)

    int activeSess = (tokyoNow ? 1 : 0) + (londonNow ? 1 : 0) + (nyNow ? 1 : 0)
    int activeKZ   = (kzLdnNow and i_showKZ_LDN ? 1 : 0) + (kzNYNow and i_showKZ_NY ? 1 : 0) + (kzAsiaNow and i_showKZ_ASIA ? 1 : 0)
    string summaryTxt = str.tostring(activeSess) + " session" + (activeSess != 1 ? "s" : "") + " · " + str.tostring(activeKZ) + " KZ active"
    table.cell(dash, 0, 4, summaryTxt, text_color=activeKZ > 0 ? KZ_CLR : DIM_CLR, text_size=sz, text_halign=text.align_left)
    table.cell(dash, 1, 4, "", text_size=sz)
    table.cell(dash, 2, 4, "", text_size=sz)
    table.cell(dash, 3, 4, "", text_size=sz)

// ══════════════════════════════════════════════════════════════════════════════
// ▌ ALERTS
// ══════════════════════════════════════════════════════════════════════════════

alertcondition(tokyoNow  and not tokyoNow[1],  title="Tokyo Open",        message="Tokyo session has opened")
alertcondition(londonNow and not londonNow[1],  title="London Open",       message="London session has opened")
alertcondition(nyNow     and not nyNow[1],      title="New York Open",     message="New York session has opened")
alertcondition(kzLdnNow  and not kzLdnNow[1],  title="London KZ Start",   message="London Kill Zone is now active (02:00-05:00 ET)")
alertcondition(kzNYNow   and not kzNYNow[1],   title="New York KZ Start", message="New York Kill Zone is now active (07:00-10:00 ET)")
alertcondition(kzAsiaNow and not kzAsiaNow[1],  title="Asian KZ Start",   message="Asian Kill Zone is now active (20:00-00:00 ET)")
alertcondition(not tokyoNow  and tokyoNow[1],  title="Tokyo Close",       message="Tokyo session has closed")
alertcondition(not londonNow and londonNow[1],  title="London Close",      message="London session has closed")
alertcondition(not nyNow     and nyNow[1],      title="New York Close",    message="New York session has closed")
````
