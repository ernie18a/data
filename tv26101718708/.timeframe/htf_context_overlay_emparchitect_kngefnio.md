# HTF Context Overlay [EmpArchitect]

- url: https://www.tradingview.com/script/kngeFnio-HTF-Context-Overlay-EmpArchitect/
- type: indicator
- pine_id: PUB;1a42563d781a4d8bac3ba341c43292d0
- version: 1.0

## Description

█ OVERVIEW

HTF Context Overlay draws clean higher-timeframe reference levels directly on your chart: previous day/week/month highs and lows, daily open, midnight open, and key session opens.

It is designed as a passive context layer for ICT, SMC, and price-action workflows.

No signals.
No entries.
No stop losses.
No take profits.
No predictions.

This tool answers one simple question:

Where is price trading relative to the important higher-timeframe reference levels?

█ LEVELS INCLUDED

Daily

PDH / PDL
Daily Open
Midnight Open
Previous Day Midpoint optional

Weekly

PWH / PWL
Previous Week Midpoint optional

Monthly

PMH / PML
Previous Month Midpoint optional

Sessions

London Open
New York Open
Asia Open optional

Midpoints are off by default to keep the chart clean.

█ VISUAL HIERARCHY

The overlay uses a simple visual system:

Amber = high-side levels: PDH / PWH / PMH
Teal = low-side levels: PDL / PWL / PML
Gray = opens: Daily Open, Midnight Open, session opens
Muted gray = optional midpoints

Line style encodes timeframe:

Daily = solid
Weekly = dashed
Monthly = dotted / more subtle
Opens = thinner contextual lines

The color language is aligned with Smart Liquidity Map [EmpArchitect], but the purpose is different:

Smart Liquidity Map shows where liquidity sits.
HTF Context Overlay shows the reference levels that frame price.

█ DASHBOARD

The top-right dashboard summarizes current context without adding chart clutter.

It can show:

Current session: Asia / London / New York / Off
Daily range state: Above PDH / Inside PD / Below PDL
Weekly range state
Monthly range state in Expanded mode
Nearest level above price
Nearest level below price
Price position versus active opens: DO / MO / LO / NY

Dashboard modes:

Compact — session and nearest levels
Standard — default context view
Expanded — adds monthly range state

█ OPEN LABEL MODE

Open labels can be controlled separately from the open lines.

Modes:

Smart — default; shows Daily Open, Midnight Open, and the current active session open
All — shows all open labels
Main Only — shows only Daily Open and Midnight Open
Off — hides open labels while keeping the lines visible

This keeps the chart readable on lower timeframes.

█ MIDNIGHT OPEN

The Midnight Open is timezone-aware.

Options:

New York
UTC
London
Exchange

New York is the default because it is commonly used in ICT-style workflows.

█ SESSION OPENS

London and New York opens are enabled by default.
Asia open is optional.

Session reference hours are configurable in UTC.

Session and midnight opens are most accurate on intraday charts, especially 1H and below. On higher timeframes, the open reflects the first bar that captures the session boundary.

█ NON-REPAINTING LOGIC

Previous day, week, and month levels are based on completed periods.

Session and open levels are set when the relevant session/day begins.

The script does not generate trade signals or predictive conditions.

█ BEST USE

Best used on:

5M
15M
1H
4H

Useful for crypto, forex, indices, commodities, and other liquid markets.

█ PAIRS WITH

Pairs well with:

Smart Liquidity Map [EmpArchitect]
Trap Zones
CISD tools
Any discretionary ICT / SMC / price-action workflow

Use HTF Context Overlay as the clean reference framework beneath more active liquidity or execution tools.

█ NOTES

Pine Script v6
Open-source
Built by EmpArchitect
Educational context tool only
Not financial advice
Not a signal service

## Source Code

````pine
//@version=6
indicator("HTF Context Overlay [EmpArchitect]", shorttitle="HTF Context [EA]", overlay=true, max_lines_count=50, max_labels_count=50)

// ═══════════════════════════════════════════════════════════════════
// HTF CONTEXT OVERLAY [EmpArchitect] v1.0
//
// Clean HTF reference levels for ICT, SMC, and price-action traders.
// No signals. No entries. No prediction. Just context.
//
// Session and midnight opens are most accurate on intraday charts
// (1H and below). On higher timeframes, opens reflect the first
// bar that catches the session boundary.
//
// PAIRS WITH: Smart Liquidity Map [EmpArchitect]
// NON-REPAINTING: Previous levels confirmed at period close.
// ═══════════════════════════════════════════════════════════════════

// ─────────────── INPUTS ───────────────

grp1 = "Daily Context"
showPDHL   = input.bool(true,  "Show PDH / PDL",            group=grp1)
showPDM    = input.bool(false, "Show Previous Day Midpoint", group=grp1)
showDO     = input.bool(true,  "Show Daily Open",            group=grp1)
showMO     = input.bool(true,  "Show Midnight Open",         group=grp1)
midnightTz = input.string("New York", "Midnight Timezone",   group=grp1, options=["New York", "UTC", "London", "Exchange"], tooltip="Midnight open at 00:00 in selected timezone. New York recommended for ICT.")

grp2 = "Weekly / Monthly Context"
showPWHL = input.bool(true,  "Show PWH / PWL",              group=grp2)
showPWM  = input.bool(false, "Show Previous Week Midpoint", group=grp2)
showPMHL = input.bool(true,  "Show PMH / PML",              group=grp2)
showPMM  = input.bool(false, "Show Previous Month Midpoint",group=grp2)

grp3 = "Session Opens"
showLO  = input.bool(true,  "Show London Open",             group=grp3)
showNYO = input.bool(true,  "Show NY Open",                 group=grp3)
showAO  = input.bool(false, "Show Asia Open",               group=grp3)
londonH = input.int(8,  "London Reference Hour (UTC)",      group=grp3, minval=0, maxval=23)
nyH     = input.int(13, "NY Reference Hour (UTC)",          group=grp3, minval=0, maxval=23)
asiaH   = input.int(0,  "Asia Reference Hour (UTC)",        group=grp3, minval=0, maxval=23, tooltip="Most precise on 1H and below. Dashboard assumes Asia < London < NY in UTC.")

grp4 = "Display"
showLabels    = input.bool(true,  "Show Right-Edge Labels",    group=grp4)
showPrice     = input.bool(false, "Show Price in Labels",       group=grp4, tooltip="Adds price value next to each label.")
openLabelMode = input.string("Smart", "Open Label Mode",        group=grp4, options=["Smart", "All", "Main Only", "Off"], tooltip="Smart: DO + MO + active session only. All: every open. Main Only: DO + MO. Off: lines only.")
showDash      = input.bool(true,  "Show Dashboard",             group=grp4)
dashMode      = input.string("Standard", "Dashboard Mode",      group=grp4, options=["Compact", "Standard", "Expanded"], tooltip="Compact: session + nearest. Standard: adds ranges + opens. Expanded: adds monthly.")
lookback      = input.int(300,   "Line Lookback (bars)",        group=grp4, minval=50, maxval=1000)

grp5 = "Style"
highCol     = input.color(color.new(#F59E0B, 25), "High Levels (Amber)",  group=grp5)
lowCol      = input.color(color.new(#00D9A3, 30), "Low Levels (Teal)",    group=grp5)
doLineCol   = input.color(color.new(#BFC7D5, 18), "Daily Open",           group=grp5)
moLineCol   = input.color(color.new(#AEB7C6, 28), "Midnight Open",        group=grp5)
sessLineCol = input.color(color.new(#9DA8B8, 38), "Session Opens",        group=grp5)
midCol      = input.color(color.new(#6B7280, 65), "Midpoints",            group=grp5)

// Label text — brighter than lines for readability
color doTextCol   = color.new(#DDE3EA, 0)
color moTextCol   = color.new(#CCD3DD, 0)
color sessTextCol = color.new(#BFC7D5, 0)

// ─────────────── TIMEZONE ───────────────
// FIX: switch instead of multi-line ternary (was causing CE10156)

string tzStr = switch midnightTz
    "New York" => "America/New_York"
    "London"   => "Europe/London"
    "UTC"      => "UTC"
    => syminfo.timezone

int LBL_OFFSET = 3

// ─────────────── LEVEL DATA ───────────────

[pdh, pdl, dailyOpen] = request.security(syminfo.tickerid, "D", [high[1], low[1], open], lookahead=barmerge.lookahead_on)
[pwh, pwl] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead=barmerge.lookahead_on)
[pmh, pml] = request.security(syminfo.tickerid, "M", [high[1], low[1]], lookahead=barmerge.lookahead_on)

float pdm = not na(pdh) and not na(pdl) ? math.avg(pdh, pdl) : na
float pwm = not na(pwh) and not na(pwl) ? math.avg(pwh, pwl) : na
float pmm = not na(pmh) and not na(pml) ? math.avg(pmh, pml) : na

// ─────────────── MIDNIGHT OPEN ───────────────

var float moPrice = na
var int moBar = na

bool newMidnightDay = ta.change(dayofmonth(time, tzStr)) != 0
if newMidnightDay
    moPrice := open
    moBar := bar_index

// ─────────────── SESSION OPENS ───────────────

var float loPrice = na
var int loBar = na
var float nyoPrice = na
var int nyoBar = na
var float aoPrice = na
var int aoBar = na

int curH = hour(time, "UTC")
int prevH = nz(hour(time[1], "UTC"), -1)

bool newUTCDay = ta.change(dayofmonth(time, "UTC")) != 0

if newUTCDay
    loPrice := na
    nyoPrice := na
    aoPrice := na

f_sessStart(int startH) =>
    bool result = false
    if startH == 0
        result := curH == 0 and prevH != 0
    else
        result := curH >= startH and (prevH < startH or prevH > curH)
    result

if f_sessStart(londonH)
    loPrice := open
    loBar := bar_index

if f_sessStart(nyH)
    nyoPrice := open
    nyoBar := bar_index

if f_sessStart(asiaH)
    aoPrice := open
    aoBar := bar_index

// ─────────────── DAILY OPEN BAR TRACKING ───────────────

var int doBar = na
bool newExchangeDay = ta.change(time("D")) != 0
if newExchangeDay or na(doBar)
    doBar := bar_index

// ─────────────── CURRENT SESSION ───────────────

string currentSession = "Off"
if curH >= asiaH and curH < londonH
    currentSession := "Asia"
else if curH >= londonH and curH < nyH
    currentSession := "London"
else if curH >= nyH and curH < 21
    currentSession := "New York"

color sessionCol = switch currentSession
    "London"   => #14B8A6
    "New York" => #F59E0B
    "Asia"     => #9CA3AF
    => #4B5563

// ─────────────── LINE HELPERS ───────────────

f_updateLevel(line ln, float lvl, color col, string stl, int width) =>
    line result = ln
    int x2 = bar_index + LBL_OFFSET
    int x1 = bar_index - lookback
    if not na(lvl)
        if na(result)
            result := line.new(x1, lvl, x2, lvl, color=col, style=line.style_solid, width=width)
        else
            line.set_y1(result, lvl)
            line.set_y2(result, lvl)
            line.set_x1(result, x1)
            line.set_x2(result, x2)
        if stl == "dashed"
            line.set_style(result, line.style_dashed)
        else if stl == "dotted"
            line.set_style(result, line.style_dotted)
        else
            line.set_style(result, line.style_solid)
    result

f_updateOpen(line ln, float lvl, int startBar, color col, string stl) =>
    line result = ln
    if not na(lvl) and not na(startBar)
        int x2 = bar_index + LBL_OFFSET
        if na(result)
            result := line.new(startBar, lvl, x2, lvl, color=col, style=line.style_dashed, width=1)
        else
            line.set_y1(result, lvl)
            line.set_y2(result, lvl)
            line.set_x1(result, startBar)
            line.set_x2(result, x2)
        if stl == "dotted"
            line.set_style(result, line.style_dotted)
        else
            line.set_style(result, line.style_dashed)
    result

// ─────────────── LINE MANAGEMENT — Previous levels ───────────────

var line pdhLine = na
var line pdlLine = na
var line pdmLine = na
var line pwhLine = na
var line pwlLine = na
var line pwmLine = na
var line pmhLine = na
var line pmlLine = na
var line pmmLine = na

if showPDHL
    pdhLine := f_updateLevel(pdhLine, pdh, highCol, "solid", 1)
    pdlLine := f_updateLevel(pdlLine, pdl, lowCol, "solid", 1)
if showPDM
    pdmLine := f_updateLevel(pdmLine, pdm, midCol, "dotted", 1)
if showPWHL
    pwhLine := f_updateLevel(pwhLine, pwh, highCol, "dashed", 1)
    pwlLine := f_updateLevel(pwlLine, pwl, lowCol, "dashed", 1)
if showPWM
    pwmLine := f_updateLevel(pwmLine, pwm, midCol, "dotted", 1)
if showPMHL
    pmhLine := f_updateLevel(pmhLine, pmh, color.new(highCol, 55), "dotted", 1)
    pmlLine := f_updateLevel(pmlLine, pml, color.new(lowCol, 55), "dotted", 1)
if showPMM
    pmmLine := f_updateLevel(pmmLine, pmm, midCol, "dotted", 1)

// ─────────────── LINE MANAGEMENT — Opens ───────────────

var line doLine = na
var line moLine = na
var line loLine = na
var line nyoLine = na
var line aoLine = na

// Daily Open — starts at actual daily session open bar
if showDO and not na(dailyOpen)
    if newExchangeDay
        line.delete(doLine)
        doLine := na
    doLine := f_updateOpen(doLine, dailyOpen, doBar, doLineCol, "dashed")
else
    if not na(doLine)
        line.delete(doLine)
        doLine := na

// Midnight Open
if showMO and not na(moPrice)
    if newMidnightDay
        line.delete(moLine)
        moLine := na
    moLine := f_updateOpen(moLine, moPrice, nz(moBar, bar_index), moLineCol, "dotted")
else
    if not na(moLine)
        line.delete(moLine)
        moLine := na

// London Open
if showLO
    if newUTCDay
        line.delete(loLine)
        loLine := na
    if not na(loPrice)
        if f_sessStart(londonH)
            line.delete(loLine)
            loLine := na
        loLine := f_updateOpen(loLine, loPrice, nz(loBar, bar_index), sessLineCol, "dashed")

// NY Open
if showNYO
    if newUTCDay
        line.delete(nyoLine)
        nyoLine := na
    if not na(nyoPrice)
        if f_sessStart(nyH)
            line.delete(nyoLine)
            nyoLine := na
        nyoLine := f_updateOpen(nyoLine, nyoPrice, nz(nyoBar, bar_index), sessLineCol, "dashed")

// Asia Open
if showAO
    if newUTCDay
        line.delete(aoLine)
        aoLine := na
    if not na(aoPrice)
        if f_sessStart(asiaH)
            line.delete(aoLine)
            aoLine := na
        aoLine := f_updateOpen(aoLine, aoPrice, nz(aoBar, bar_index), sessLineCol, "dashed")

// ─────────────── RIGHT-EDGE LABELS ───────────────

f_lbl(string name, float price) =>
    showPrice ? name + " " + str.tostring(price, format.mintick) : name

var label pdhLbl = na
var label pdlLbl = na
var label pdmLbl = na
var label pwhLbl = na
var label pwlLbl = na
var label pwmLbl = na
var label pmhLbl = na
var label pmlLbl = na
var label pmmLbl = na
var label doLbl = na
var label moLbl = na
var label loLbl = na
var label nyoLbl = na
var label aoLbl = na

if barstate.islast
    label.delete(pdhLbl)
    label.delete(pdlLbl)
    label.delete(pdmLbl)
    label.delete(pwhLbl)
    label.delete(pwlLbl)
    label.delete(pwmLbl)
    label.delete(pmhLbl)
    label.delete(pmlLbl)
    label.delete(pmmLbl)
    label.delete(doLbl)
    label.delete(moLbl)
    label.delete(loLbl)
    label.delete(nyoLbl)
    label.delete(aoLbl)

    if showLabels
        int lx = bar_index + LBL_OFFSET
        int lxOpen = bar_index + 5
        int lxSess = bar_index + 7

        if showPDHL and not na(pdh)
            pdhLbl := label.new(lx, pdh, f_lbl("PDH", pdh), style=label.style_none, textcolor=highCol, size=size.tiny)
        if showPDHL and not na(pdl)
            pdlLbl := label.new(lx, pdl, f_lbl("PDL", pdl), style=label.style_none, textcolor=lowCol, size=size.tiny)
        if showPDM and not na(pdm)
            pdmLbl := label.new(lx, pdm, f_lbl("PDM", pdm), style=label.style_none, textcolor=midCol, size=size.tiny)
        if showPWHL and not na(pwh)
            pwhLbl := label.new(lx, pwh, f_lbl("PWH", pwh), style=label.style_none, textcolor=highCol, size=size.tiny)
        if showPWHL and not na(pwl)
            pwlLbl := label.new(lx, pwl, f_lbl("PWL", pwl), style=label.style_none, textcolor=lowCol, size=size.tiny)
        if showPWM and not na(pwm)
            pwmLbl := label.new(lx, pwm, f_lbl("PWM", pwm), style=label.style_none, textcolor=midCol, size=size.tiny)
        if showPMHL and not na(pmh)
            pmhLbl := label.new(lx, pmh, f_lbl("PMH", pmh), style=label.style_none, textcolor=color.new(highCol, 55), size=size.tiny)
        if showPMHL and not na(pml)
            pmlLbl := label.new(lx, pml, f_lbl("PML", pml), style=label.style_none, textcolor=color.new(lowCol, 55), size=size.tiny)
        if showPMM and not na(pmm)
            pmmLbl := label.new(lx, pmm, f_lbl("PMM", pmm), style=label.style_none, textcolor=midCol, size=size.tiny)
        // Open labels — controlled by openLabelMode
        bool showDOlbl  = openLabelMode != "Off" and showDO and not na(dailyOpen)
        bool showMOlbl  = openLabelMode != "Off" and showMO and not na(moPrice)
        bool showLOlbl  = (openLabelMode == "All" or (openLabelMode == "Smart" and currentSession == "London")) and showLO and not na(loPrice)
        bool showNYOlbl = (openLabelMode == "All" or (openLabelMode == "Smart" and currentSession == "New York")) and showNYO and not na(nyoPrice)
        bool showAOlbl  = (openLabelMode == "All" or (openLabelMode == "Smart" and currentSession == "Asia")) and showAO and not na(aoPrice)

        if showDOlbl
            doLbl := label.new(lxOpen, dailyOpen, f_lbl("DO", dailyOpen), style=label.style_none, textcolor=doTextCol, size=size.tiny)
        if showMOlbl
            string moName = midnightTz == "New York" ? "NY MO" : midnightTz == "London" ? "LN MO" : "MO"
            moLbl := label.new(lxOpen, moPrice, f_lbl(moName, moPrice), style=label.style_none, textcolor=moTextCol, size=size.tiny)
        if showLOlbl
            loLbl := label.new(lxSess, loPrice, f_lbl("LO", loPrice), style=label.style_none, textcolor=sessTextCol, size=size.tiny)
        if showNYOlbl
            nyoLbl := label.new(lxSess, nyoPrice, f_lbl("NYO", nyoPrice), style=label.style_none, textcolor=sessTextCol, size=size.tiny)
        if showAOlbl
            aoLbl := label.new(lxSess, aoPrice, f_lbl("AO", aoPrice), style=label.style_none, textcolor=sessTextCol, size=size.tiny)

// ─────────────── NEAREST LEVEL CALC ───────────────

var float nearAbove = na
var string nearAboveN = ""
var float nearBelow = na
var string nearBelowN = ""

f_chk(float lvl, string name, bool isAbove, float cur, string curN) =>
    float r = cur
    string n = curN
    if not na(lvl)
        if isAbove and lvl > close and (na(r) or lvl < r)
            r := lvl
            n := name
        if not isAbove and lvl < close and (na(r) or lvl > r)
            r := lvl
            n := name
    [r, n]

nearAbove := na
nearAboveN := ""
nearBelow := na
nearBelowN := ""

if showPDHL
    [a1, n1] = f_chk(pdh, "PDH", true, nearAbove, nearAboveN)
    [b1, m1] = f_chk(pdh, "PDH", false, nearBelow, nearBelowN)
    [a2, n2] = f_chk(pdl, "PDL", true, a1, n1)
    [b2, m2] = f_chk(pdl, "PDL", false, b1, m1)
    nearAbove := a2
    nearAboveN := n2
    nearBelow := b2
    nearBelowN := m2

if showPDM
    [a3, n3] = f_chk(pdm, "PDM", true, nearAbove, nearAboveN)
    [b3, m3] = f_chk(pdm, "PDM", false, nearBelow, nearBelowN)
    nearAbove := a3
    nearAboveN := n3
    nearBelow := b3
    nearBelowN := m3

if showPWHL
    [a4, n4] = f_chk(pwh, "PWH", true, nearAbove, nearAboveN)
    [b4, m4] = f_chk(pwh, "PWH", false, nearBelow, nearBelowN)
    [a5, n5] = f_chk(pwl, "PWL", true, a4, n4)
    [b5, m5] = f_chk(pwl, "PWL", false, b4, m4)
    nearAbove := a5
    nearAboveN := n5
    nearBelow := b5
    nearBelowN := m5

if showPWM
    [a6, n6] = f_chk(pwm, "PWM", true, nearAbove, nearAboveN)
    [b6, m6] = f_chk(pwm, "PWM", false, nearBelow, nearBelowN)
    nearAbove := a6
    nearAboveN := n6
    nearBelow := b6
    nearBelowN := m6

if showPMHL
    [a7, n7] = f_chk(pmh, "PMH", true, nearAbove, nearAboveN)
    [b7, m7] = f_chk(pmh, "PMH", false, nearBelow, nearBelowN)
    [a8, n8] = f_chk(pml, "PML", true, a7, n7)
    [b8, m8] = f_chk(pml, "PML", false, b7, m7)
    nearAbove := a8
    nearAboveN := n8
    nearBelow := b8
    nearBelowN := m8

if showPMM
    [a9, n9] = f_chk(pmm, "PMM", true, nearAbove, nearAboveN)
    [b9, m9] = f_chk(pmm, "PMM", false, nearBelow, nearBelowN)
    nearAbove := a9
    nearAboveN := n9
    nearBelow := b9
    nearBelowN := m9

if showDO
    [a10, n10] = f_chk(dailyOpen, "DO", true, nearAbove, nearAboveN)
    [b10, m10] = f_chk(dailyOpen, "DO", false, nearBelow, nearBelowN)
    nearAbove := a10
    nearAboveN := n10
    nearBelow := b10
    nearBelowN := m10

if showMO
    [a11, n11] = f_chk(moPrice, "MO", true, nearAbove, nearAboveN)
    [b11, m11] = f_chk(moPrice, "MO", false, nearBelow, nearBelowN)
    nearAbove := a11
    nearAboveN := n11
    nearBelow := b11
    nearBelowN := m11

if showLO
    [a12, n12] = f_chk(loPrice, "LO", true, nearAbove, nearAboveN)
    [b12, m12] = f_chk(loPrice, "LO", false, nearBelow, nearBelowN)
    nearAbove := a12
    nearAboveN := n12
    nearBelow := b12
    nearBelowN := m12

if showNYO
    [a13, n13] = f_chk(nyoPrice, "NYO", true, nearAbove, nearAboveN)
    [b13, m13] = f_chk(nyoPrice, "NYO", false, nearBelow, nearBelowN)
    nearAbove := a13
    nearAboveN := n13
    nearBelow := b13
    nearBelowN := m13

if showAO
    [a14, n14] = f_chk(aoPrice, "AO", true, nearAbove, nearAboveN)
    [b14, m14] = f_chk(aoPrice, "AO", false, nearBelow, nearBelowN)
    nearAbove := a14
    nearAboveN := n14
    nearBelow := b14
    nearBelowN := m14

// ─────────────── RANGE STATES ───────────────

// Daily range state
string dRangeStr = "—"
color dRangeCol = #6B7280
if not na(pdh) and not na(pdl)
    if close > pdh
        dRangeStr := "Above PDH +" + str.tostring((close / pdh - 1) * 100, "#.##") + "%"
        dRangeCol := highCol
    else if close < pdl
        dRangeStr := "Below PDL -" + str.tostring((1 - close / pdl) * 100, "#.##") + "%"
        dRangeCol := lowCol
    else
        dRangeStr := "Inside PD"
        dRangeCol := #9CA3AF

// Weekly range state
string wRangeStr = "—"
color wRangeCol = #6B7280
if not na(pwh) and not na(pwl)
    if close > pwh
        wRangeStr := "Above PWH +" + str.tostring((close / pwh - 1) * 100, "#.##") + "%"
        wRangeCol := highCol
    else if close < pwl
        wRangeStr := "Below PWL -" + str.tostring((1 - close / pwl) * 100, "#.##") + "%"
        wRangeCol := lowCol
    else
        wRangeStr := "Inside W"
        wRangeCol := #9CA3AF

// Monthly range state (for Expanded dashboard)
string mRangeStr = "—"
color mRangeCol = #6B7280
if not na(pmh) and not na(pml)
    if close > pmh
        mRangeStr := "Above PMH +" + str.tostring((close / pmh - 1) * 100, "#.##") + "%"
        mRangeCol := highCol
    else if close < pml
        mRangeStr := "Below PML -" + str.tostring((1 - close / pml) * 100, "#.##") + "%"
        mRangeCol := lowCol
    else
        mRangeStr := "Inside M"
        mRangeCol := #9CA3AF

// ─────────────── OPENS CONTEXT ───────────────

f_pos(float lvl) =>
    na(lvl) ? "—" : close > lvl ? "↑" : "↓"

string opensStr = "DO" + f_pos(dailyOpen)
if showMO
    opensStr += " MO" + f_pos(moPrice)
if showLO and not na(loPrice)
    opensStr += " LO" + f_pos(loPrice)
if showNYO and not na(nyoPrice)
    opensStr += " NY" + f_pos(nyoPrice)

// ─────────────── DASHBOARD ───────────────

bool isCompact  = dashMode == "Compact"
bool isExpanded = dashMode == "Expanded"

var table dash = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 82), border_width=0)

if barstate.islast and showDash
    table.clear(dash, 0, 0, 1, 7)

    int row = 0

    // Title (always)
    table.cell(dash, 0, row, "HTF Context", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, row, "v1.0", text_color=#6B7280, text_size=size.tiny, text_halign=text.align_right)
    row += 1

    // Session (always)
    table.cell(dash, 0, row, "Session", text_color=#9CA3AF, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, row, currentSession, text_color=sessionCol, text_size=size.tiny, text_halign=text.align_right)
    row += 1

    // Daily (Standard + Expanded)
    if not isCompact
        table.cell(dash, 0, row, "Daily", text_color=#9CA3AF, text_size=size.tiny, text_halign=text.align_left)
        table.cell(dash, 1, row, dRangeStr, text_color=dRangeCol, text_size=size.tiny, text_halign=text.align_right)
        row += 1

    // Weekly (Standard + Expanded)
    if not isCompact
        table.cell(dash, 0, row, "Weekly", text_color=#9CA3AF, text_size=size.tiny, text_halign=text.align_left)
        table.cell(dash, 1, row, wRangeStr, text_color=wRangeCol, text_size=size.tiny, text_halign=text.align_right)
        row += 1

    // Monthly (Expanded only)
    if isExpanded
        table.cell(dash, 0, row, "Monthly", text_color=#9CA3AF, text_size=size.tiny, text_halign=text.align_left)
        table.cell(dash, 1, row, mRangeStr, text_color=mRangeCol, text_size=size.tiny, text_halign=text.align_right)
        row += 1

    // Near ↑ (always)
    string aboveStr = not na(nearAbove) ? nearAboveN + " +" + str.tostring((nearAbove / close - 1) * 100, "#.##") + "%" : "—"
    table.cell(dash, 0, row, "Near ↑", text_color=highCol, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, row, aboveStr, text_color=color.white, text_size=size.tiny, text_halign=text.align_right)
    row += 1

    // Near ↓ (always)
    string belowStr = not na(nearBelow) ? nearBelowN + " -" + str.tostring((1 - nearBelow / close) * 100, "#.##") + "%" : "—"
    table.cell(dash, 0, row, "Near ↓", text_color=lowCol, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, row, belowStr, text_color=color.white, text_size=size.tiny, text_halign=text.align_right)
    row += 1

    // Opens (Standard + Expanded)
    if not isCompact
        table.cell(dash, 0, row, "Opens", text_color=#9CA3AF, text_size=size.tiny, text_halign=text.align_left)
        table.cell(dash, 1, row, opensStr, text_color=color.white, text_size=size.tiny, text_halign=text.align_right)

else if barstate.islast and not showDash
    table.clear(dash, 0, 0, 1, 7)
````
