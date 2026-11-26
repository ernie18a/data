# Session Range Map [ATC] v3.1

- url: https://www.tradingview.com/script/jT7CSRTQ-Session-Range-Map-ATC-v3-1/
- type: indicator
- pine_id: PUB;a8c1849bc0c6446e9d58cd614494d818
- version: 1.0

## Description

[b]Session Range Map [ATC][/b] is an intraday reference-level overlay that combines prior-day structure, pre-market structure, and opening-range structure into one organized chart view.

The goal of the script is simple: keep the most commonly watched session-based levels visible in a clean format so traders can quickly see where price is trading relative to important references throughout the day.

[b]What this script plots[/b]

• Prior High
• Prior Low
• Pre-Market High
• Pre-Market Low
• Opening Range High
• Opening Range Low

The opening range can be configured to 5, 15, or 30 minutes.

[b]Visual structure[/b]

• Prior High is drawn as a solid red line
• Prior Low is drawn as a solid green line
• Pre-Market High and Pre-Market Low are drawn as dashed white lines
• ORB High and ORB Low are drawn as blue lines
• ORB lines are thinner while the opening range is building and become thicker once the opening range is locked

[b]HUD[/b]

The script includes an on-chart HUD that displays:

• Prior High
• Prior Low
• Pre-Market High
• Pre-Market Low
• ORB High
• ORB Low
• ORB Status
• ORB Range

For each level, the HUD also shows the live distance from price in ticks. This helps reduce manual chart estimation and makes it easier to judge whether price is trading directly into a nearby level or still has room before reaching it.

[b]How to use it[/b]

This script is intended as a session-structure and chart-context tool rather than a standalone signal generator.

[b]A practical workflow:[/b]

1.	Start with the prior-day and pre-market levels

These levels provide an initial framework for likely reaction areas, acceptance zones, and rejection points before the regular session develops further.

2.	Let the opening range form

As the market opens, the ORB High and ORB Low build automatically. Once the selected ORB window is complete, the range locks and remains on the chart.

3.	Watch how price behaves around key levels

Price interaction with prior-day, pre-market, and ORB levels can help frame intraday structure and location.

4.	Pay attention to level clustering

When multiple session levels are close together, that area can become a more important decision zone.

5.	Use the HUD to judge proximity

The live tick-distance readout can help distinguish between price trading in open space and price trading close to an important level.

[b]ORB behavior[/b]

The opening range starts at the regular-session open and builds for the selected 5-minute, 15-minute, or 30-minute window. After that window completes, the ORB locks.

The HUD reports whether the ORB is:

• Building
• Inside Range
• Breakout Up
• Breakout Down

[b]Alerts included[/b]

• Close through Prior High
• Close through Prior Low
• Close through Pre-Market High
• Close through Pre-Market Low
• ORB Locked
• ORB Breakout Up
• ORB Breakout Down

[b]Inputs[/b]

Main settings include:

• Regular Session
• Pre-Market Session
• Timezone
• Level visibility toggles
• Neutral band in ticks
• Label offset
• ORB visibility
• ORB window selection
• HUD position
• HUD theme
• Color settings

[b]Best fit[/b]

This script is intended for intraday charts and is especially suited to liquid stocks, ETFs, and futures where prior-day, pre-market, and opening-range levels are commonly used as reference points.

[b]Notes[/b]

• Session times and timezone can be adjusted in the settings
• The script is a chart-context tool and does not place trades or manage risk automatically
• It is intended to help organize session structure on the chart and improve level awareness during the trading day

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ATConcepts

// ==========================================================================
// ATC Session Range Map — v3.1
// Part of the ATC Free-Tier Library
// Author:  Ascend Trading Concepts 
// License: Free for personal use. Redistribution requires attribution.
// Instruments: ES, NQ, CL, QQQ, SPY, liquid equities
// Timeframes: 1m, 3m, 5m, 15m
// Tier: Free
// ==========================================================================
//@version=6
indicator("Session Range Map [ATC] — v3.1", shorttitle="Session Map [ATC]", overlay=true, max_labels_count=100, max_lines_count=30)

//==============================================================================
// A. INPUTS
//==============================================================================

// Session
grpSession = "Session Definition"
rthSess    = input.session("0930-1600", "Regular Session", group=grpSession)
pmSess     = input.session("0400-0930", "Pre-Market Session", group=grpSession)
sessTZ     = input.string("America/New_York", "Timezone", group=grpSession)

// Levels
grpLvl       = "Levels"
showPH       = input.bool(true, "Show Prior High", group=grpLvl)
showPL       = input.bool(true, "Show Prior Low", group=grpLvl)
showPMH      = input.bool(true, "Show Pre-Market High", group=grpLvl)
showPML      = input.bool(true, "Show Pre-Market Low", group=grpLvl)
neutralTicks = input.int(2, "Neutral Band (ticks)", minval=0, group=grpLvl)
labelOffset  = input.int(2, "Base Label Offset (bars)", minval=1, maxval=100, group=grpLvl)

// Opening Range
grpORB    = "Opening Range"
showORB   = input.bool(true, "Show ORB High / Low", group=grpORB)
orbWindow = input.string("15 min", "ORB Window", options=["5 min", "15 min", "30 min"], group=grpORB)

// Colors
grpCol = "Colors"
colPH  = input.color(#D64545, "Prior High Color", group=grpCol)
colPL  = input.color(#3D9970, "Prior Low Color", group=grpCol)
colPM  = input.color(color.white, "Pre-Market Line Color", group=grpCol)
colORB = input.color(#4DA3FF, "ORB Line Color", group=grpCol)

// ATC Branding / HUD
grpATC   = "ATC — Ascend Trading Concepts"
showHUD  = input.bool(true, "Show ATC HUD", group=grpATC)
hudPos   = input.string("Top Right", "HUD Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpATC)
hudTheme = input.string("Dark", "HUD Theme", options=["Dark", "Light"], group=grpATC)

//==============================================================================
// B. HELPERS
//==============================================================================

f_hudPos(_pos) =>
    if _pos == "Top Left"
        position.top_left
    else if _pos == "Bottom Right"
        position.bottom_right
    else if _pos == "Bottom Left"
        position.bottom_left
    else
        position.top_right

f_fmtPrice(_v) =>
    string _res = "—"
    if not na(_v)
        _res := str.tostring(_v, format.mintick)
    _res

f_fmtTicks(_v) =>
    string _res = "—"
    if not na(_v)
        _t = int(math.round(_v))
        _sign = _t > 0 ? "+" : ""
        _res := "(" + _sign + str.tostring(_t) + "t)"
    _res

f_stateFromDist(_distTicks, _neutralTicks) =>
    string _state = "—"
    if not na(_distTicks)
        if _distTicks > _neutralTicks
            _state := "below"
        else if _distTicks < -_neutralTicks
            _state := "above"
        else
            _state := "at"
    _state

f_valueText(_price, _distTicks) =>
    f_fmtPrice(_price) + "  " + f_fmtTicks(_distTicks)

f_stateBg(_state, _levelColor, _isDark) =>
    color _bg = na
    if _state == "at"
        _bg := _isDark ? color.new(color.gray, 75) : color.new(color.gray, 85)
    else
        _bg := color.new(_levelColor, _isDark ? 78 : 88)
    _bg

f_rangeText(_range, _tickSz) =>
    string _res = "—"
    if not na(_range) and not na(_tickSz) and _tickSz > 0
        _ticks = int(math.round(_range / _tickSz))
        _res := str.tostring(_range, format.mintick) + "  (" + str.tostring(_ticks) + "t)"
    _res

f_orStateText(_showORB, _locked, _orHigh, _orLow, _tickSz, _close, _orbWindow) =>
    string _res = "—"
    if not _showORB
        _res := "Hidden"
    else if na(_orHigh) or na(_orLow)
        _res := "Building " + _orbWindow
    else if not _locked
        _res := "Building " + _orbWindow
    else if _close > _orHigh + _tickSz
        _res := "Breakout Up"
    else if _close < _orLow - _tickSz
        _res := "Breakout Down"
    else
        _res := "Inside Range"
    _res

f_orStateBg(_state, _isDark) =>
    color _bg = na
    if _state == "Breakout Up"
        _bg := color.new(#3D9970, _isDark ? 72 : 84)
    else if _state == "Breakout Down"
        _bg := color.new(#D64545, _isDark ? 72 : 84)
    else if _state == "Inside Range"
        _bg := _isDark ? color.new(color.gray, 75) : color.new(color.gray, 86)
    else
        _bg := _isDark ? color.new(color.blue, 82) : color.new(color.blue, 90)
    _bg

//==============================================================================
// C. STATE TRACKING
//==============================================================================

var float liveRTHHigh = na
var float liveRTHLow  = na
var float priorHigh   = na
var float priorLow    = na

var float livePMHigh  = na
var float livePMLow   = na
var float pmHigh      = na
var float pmLow       = na

var float orHigh      = na
var float orLow       = na
var bool  orLocked    = false
var int   orStartMs   = na

var int sessionStartBar = na

int orbMinutes = 15
if orbWindow == "5 min"
    orbMinutes := 5
else if orbWindow == "15 min"
    orbMinutes := 15
else
    orbMinutes := 30

inRTH  = not na(time(timeframe.period, rthSess, sessTZ))
newRTH = inRTH and not (barstate.isfirst ? false : inRTH[1])

inPM   = not na(time(timeframe.period, pmSess, sessTZ))
newPM  = inPM and not (barstate.isfirst ? false : inPM[1])

dayStamp = time("D", "0000-2359", sessTZ)
newDay   = ta.change(dayStamp) != 0

if newDay
    livePMHigh := na
    livePMLow  := na
    pmHigh     := na
    pmLow      := na

// Build pre-market range
if newPM
    livePMHigh := high
    livePMLow  := low
else if inPM
    livePMHigh := math.max(nz(livePMHigh, high), high)
    livePMLow  := math.min(nz(livePMLow, low), low)

// Lock prior RTH + PM and reset ORB at regular-session open
if newRTH
    priorHigh := liveRTHHigh
    priorLow  := liveRTHLow

    pmHigh := livePMHigh
    pmLow  := livePMLow

    liveRTHHigh := high
    liveRTHLow  := low

    orHigh    := high
    orLow     := low
    orLocked  := false
    orStartMs := time

    sessionStartBar := bar_index
else if inRTH
    liveRTHHigh := math.max(nz(liveRTHHigh, high), high)
    liveRTHLow  := math.min(nz(liveRTHLow, low), low)

    if showORB and not orLocked and not na(orStartMs)
        minsSinceOpen = (time - orStartMs) / 60000.0
        if minsSinceOpen < orbMinutes
            orHigh := math.max(nz(orHigh, high), high)
            orLow  := math.min(nz(orLow, low), low)
        else
            orLocked := true

//==============================================================================
// D. DISTANCE / ORB STATE
//==============================================================================

tickSz = syminfo.mintick

distPH  = not na(priorHigh) and tickSz > 0 ? (priorHigh - close) / tickSz : na
distPL  = not na(priorLow)  and tickSz > 0 ? (priorLow  - close) / tickSz : na
distPMH = not na(pmHigh)    and tickSz > 0 ? (pmHigh    - close) / tickSz : na
distPML = not na(pmLow)     and tickSz > 0 ? (pmLow     - close) / tickSz : na
distORH = not na(orHigh)    and tickSz > 0 ? (orHigh    - close) / tickSz : na
distORL = not na(orLow)     and tickSz > 0 ? (orLow     - close) / tickSz : na

statePH  = f_stateFromDist(distPH, neutralTicks)
statePL  = f_stateFromDist(distPL, neutralTicks)
statePMH = f_stateFromDist(distPMH, neutralTicks)
statePML = f_stateFromDist(distPML, neutralTicks)
stateORH = f_stateFromDist(distORH, neutralTicks)
stateORL = f_stateFromDist(distORL, neutralTicks)

orRange     = not na(orHigh) and not na(orLow) ? (orHigh - orLow) : na
orStateText = f_orStateText(showORB, orLocked, orHigh, orLow, tickSz, close, orbWindow)
orbLineWidth = orLocked ? 2 : 1

//==============================================================================
// E. LEVEL OBJECTS
//==============================================================================

var line lnPH  = na
var line lnPL  = na
var line lnPMH = na
var line lnPML = na
var line lnORH = na
var line lnORL = na

var label lbPH  = na
var label lbPL  = na
var label lbPMH = na
var label lbPML = na
var label lbORH = na
var label lbORL = na

lineStartX = nz(sessionStartBar, bar_index)

// Prior High — solid red
if showPH and not na(priorHigh)
    if na(lnPH)
        lnPH := line.new(lineStartX, priorHigh, bar_index, priorHigh, xloc=xloc.bar_index, extend=extend.right, color=colPH, style=line.style_solid, width=2)
    else
        line.set_x1(lnPH, lineStartX)
        line.set_y1(lnPH, priorHigh)
        line.set_x2(lnPH, bar_index)
        line.set_y2(lnPH, priorHigh)
        line.set_extend(lnPH, extend.right)
        line.set_color(lnPH, colPH)
        line.set_style(lnPH, line.style_solid)
        line.set_width(lnPH, 2)
else
    if not na(lnPH)
        line.delete(lnPH)
        lnPH := na

// Prior Low — solid green
if showPL and not na(priorLow)
    if na(lnPL)
        lnPL := line.new(lineStartX, priorLow, bar_index, priorLow, xloc=xloc.bar_index, extend=extend.right, color=colPL, style=line.style_solid, width=2)
    else
        line.set_x1(lnPL, lineStartX)
        line.set_y1(lnPL, priorLow)
        line.set_x2(lnPL, bar_index)
        line.set_y2(lnPL, priorLow)
        line.set_extend(lnPL, extend.right)
        line.set_color(lnPL, colPL)
        line.set_style(lnPL, line.style_solid)
        line.set_width(lnPL, 2)
else
    if not na(lnPL)
        line.delete(lnPL)
        lnPL := na

// Pre-Market High — bright white dashed
if showPMH and not na(pmHigh)
    if na(lnPMH)
        lnPMH := line.new(lineStartX, pmHigh, bar_index, pmHigh, xloc=xloc.bar_index, extend=extend.right, color=colPM, style=line.style_dashed, width=1)
    else
        line.set_x1(lnPMH, lineStartX)
        line.set_y1(lnPMH, pmHigh)
        line.set_x2(lnPMH, bar_index)
        line.set_y2(lnPMH, pmHigh)
        line.set_extend(lnPMH, extend.right)
        line.set_color(lnPMH, colPM)
        line.set_style(lnPMH, line.style_dashed)
        line.set_width(lnPMH, 1)
else
    if not na(lnPMH)
        line.delete(lnPMH)
        lnPMH := na

// Pre-Market Low — bright white dashed
if showPML and not na(pmLow)
    if na(lnPML)
        lnPML := line.new(lineStartX, pmLow, bar_index, pmLow, xloc=xloc.bar_index, extend=extend.right, color=colPM, style=line.style_dashed, width=1)
    else
        line.set_x1(lnPML, lineStartX)
        line.set_y1(lnPML, pmLow)
        line.set_x2(lnPML, bar_index)
        line.set_y2(lnPML, pmLow)
        line.set_extend(lnPML, extend.right)
        line.set_color(lnPML, colPM)
        line.set_style(lnPML, line.style_dashed)
        line.set_width(lnPML, 1)
else
    if not na(lnPML)
        line.delete(lnPML)
        lnPML := na

// ORB High — blue, thicker after lock
if showORB and not na(orHigh)
    if na(lnORH)
        lnORH := line.new(lineStartX, orHigh, bar_index, orHigh, xloc=xloc.bar_index, extend=extend.right, color=colORB, style=line.style_solid, width=orbLineWidth)
    else
        line.set_x1(lnORH, lineStartX)
        line.set_y1(lnORH, orHigh)
        line.set_x2(lnORH, bar_index)
        line.set_y2(lnORH, orHigh)
        line.set_extend(lnORH, extend.right)
        line.set_color(lnORH, colORB)
        line.set_style(lnORH, line.style_solid)
        line.set_width(lnORH, orbLineWidth)
else
    if not na(lnORH)
        line.delete(lnORH)
        lnORH := na

// ORB Low — blue, thicker after lock
if showORB and not na(orLow)
    if na(lnORL)
        lnORL := line.new(lineStartX, orLow, bar_index, orLow, xloc=xloc.bar_index, extend=extend.right, color=colORB, style=line.style_solid, width=orbLineWidth)
    else
        line.set_x1(lnORL, lineStartX)
        line.set_y1(lnORL, orLow)
        line.set_x2(lnORL, bar_index)
        line.set_y2(lnORL, orLow)
        line.set_extend(lnORL, extend.right)
        line.set_color(lnORL, colORB)
        line.set_style(lnORL, line.style_solid)
        line.set_width(lnORL, orbLineWidth)
else
    if not na(lnORL)
        line.delete(lnORL)
        lnORL := na

//==============================================================================
// F. RIGHT-EDGE LABELS
//==============================================================================

if barstate.islast
    if showPH and not na(priorHigh)
        txtPH = "PDH " + f_fmtPrice(priorHigh) + " " + f_fmtTicks(distPH)
        if na(lbPH)
            lbPH := label.new(bar_index + labelOffset + 0, priorHigh, txtPH, xloc=xloc.bar_index, style=label.style_label_left, color=colPH, textcolor=color.white, size=size.small)
        else
            label.set_x(lbPH, bar_index + labelOffset + 0)
            label.set_y(lbPH, priorHigh)
            label.set_text(lbPH, txtPH)
            label.set_color(lbPH, colPH)
            label.set_textcolor(lbPH, color.white)
    else
        if not na(lbPH)
            label.delete(lbPH)
            lbPH := na

    if showPL and not na(priorLow)
        txtPL = "PDL " + f_fmtPrice(priorLow) + " " + f_fmtTicks(distPL)
        if na(lbPL)
            lbPL := label.new(bar_index + labelOffset + 2, priorLow, txtPL, xloc=xloc.bar_index, style=label.style_label_left, color=colPL, textcolor=color.white, size=size.small)
        else
            label.set_x(lbPL, bar_index + labelOffset + 2)
            label.set_y(lbPL, priorLow)
            label.set_text(lbPL, txtPL)
            label.set_color(lbPL, colPL)
            label.set_textcolor(lbPL, color.white)
    else
        if not na(lbPL)
            label.delete(lbPL)
            lbPL := na

    if showPMH and not na(pmHigh)
        txtPMH = "PMH " + f_fmtPrice(pmHigh) + " " + f_fmtTicks(distPMH)
        if na(lbPMH)
            lbPMH := label.new(bar_index + labelOffset + 4, pmHigh, txtPMH, xloc=xloc.bar_index, style=label.style_label_left, color=colPM, textcolor=color.black, size=size.small)
        else
            label.set_x(lbPMH, bar_index + labelOffset + 4)
            label.set_y(lbPMH, pmHigh)
            label.set_text(lbPMH, txtPMH)
            label.set_color(lbPMH, colPM)
            label.set_textcolor(lbPMH, color.black)
    else
        if not na(lbPMH)
            label.delete(lbPMH)
            lbPMH := na

    if showPML and not na(pmLow)
        txtPML = "PML " + f_fmtPrice(pmLow) + " " + f_fmtTicks(distPML)
        if na(lbPML)
            lbPML := label.new(bar_index + labelOffset + 6, pmLow, txtPML, xloc=xloc.bar_index, style=label.style_label_left, color=colPM, textcolor=color.black, size=size.small)
        else
            label.set_x(lbPML, bar_index + labelOffset + 6)
            label.set_y(lbPML, pmLow)
            label.set_text(lbPML, txtPML)
            label.set_color(lbPML, colPM)
            label.set_textcolor(lbPML, color.black)
    else
        if not na(lbPML)
            label.delete(lbPML)
            lbPML := na

    if showORB and not na(orHigh)
        txtORH = "ORH " + f_fmtPrice(orHigh) + " " + f_fmtTicks(distORH)
        if na(lbORH)
            lbORH := label.new(bar_index + labelOffset + 8, orHigh, txtORH, xloc=xloc.bar_index, style=label.style_label_left, color=colORB, textcolor=color.black, size=size.small)
        else
            label.set_x(lbORH, bar_index + labelOffset + 8)
            label.set_y(lbORH, orHigh)
            label.set_text(lbORH, txtORH)
            label.set_color(lbORH, colORB)
            label.set_textcolor(lbORH, color.black)
    else
        if not na(lbORH)
            label.delete(lbORH)
            lbORH := na

    if showORB and not na(orLow)
        txtORL = "ORL " + f_fmtPrice(orLow) + " " + f_fmtTicks(distORL)
        if na(lbORL)
            lbORL := label.new(bar_index + labelOffset + 10, orLow, txtORL, xloc=xloc.bar_index, style=label.style_label_left, color=colORB, textcolor=color.black, size=size.small)
        else
            label.set_x(lbORL, bar_index + labelOffset + 10)
            label.set_y(lbORL, orLow)
            label.set_text(lbORL, txtORL)
            label.set_color(lbORL, colORB)
            label.set_textcolor(lbORL, color.black)
    else
        if not na(lbORL)
            label.delete(lbORL)
            lbORL := na

//==============================================================================
// G. ATC HUD
//==============================================================================

var table hud = table.new(f_hudPos(hudPos), 2, 8, border_width=1)

isDarkHud  = hudTheme == "Dark"
hudBg      = isDarkHud ? color.new(color.black, 18) : color.new(color.white, 0)
hudText    = isDarkHud ? color.white : color.black
hudBorder  = isDarkHud ? color.new(color.gray, 55) : color.new(color.gray, 30)
hudLabelBg = isDarkHud ? color.new(color.gray, 82) : color.new(color.gray, 90)

if barstate.islast
    if showHUD
        table.cell(hud, 0, 0, "Prior High", text_color=hudText, bgcolor=hudLabelBg)
        table.cell(hud, 1, 0, f_valueText(priorHigh, distPH), text_color=hudText, bgcolor=f_stateBg(statePH, colPH, isDarkHud))

        table.cell(hud, 0, 1, "Prior Low", text_color=hudText, bgcolor=hudLabelBg)
        table.cell(hud, 1, 1, f_valueText(priorLow, distPL), text_color=hudText, bgcolor=f_stateBg(statePL, colPL, isDarkHud))

        table.cell(hud, 0, 2, "Pre-Mkt High", text_color=hudText, bgcolor=hudLabelBg)
        table.cell(hud, 1, 2, f_valueText(pmHigh, distPMH), text_color=hudText, bgcolor=f_stateBg(statePMH, colPM, isDarkHud))

        table.cell(hud, 0, 3, "Pre-Mkt Low", text_color=hudText, bgcolor=hudLabelBg)
        table.cell(hud, 1, 3, f_valueText(pmLow, distPML), text_color=hudText, bgcolor=f_stateBg(statePML, colPM, isDarkHud))

        table.cell(hud, 0, 4, "ORB High", text_color=hudText, bgcolor=hudLabelBg)
        table.cell(hud, 1, 4, f_valueText(orHigh, distORH), text_color=hudText, bgcolor=f_stateBg(stateORH, colORB, isDarkHud))

        table.cell(hud, 0, 5, "ORB Low", text_color=hudText, bgcolor=hudLabelBg)
        table.cell(hud, 1, 5, f_valueText(orLow, distORL), text_color=hudText, bgcolor=f_stateBg(stateORL, colORB, isDarkHud))

        table.cell(hud, 0, 6, "ORB Status", text_color=hudText, bgcolor=hudLabelBg)
        table.cell(hud, 1, 6, orStateText, text_color=hudText, bgcolor=f_orStateBg(orStateText, isDarkHud))

        table.cell(hud, 0, 7, "ORB Range", text_color=hudText, bgcolor=hudLabelBg)
        table.cell(hud, 1, 7, f_rangeText(orRange, tickSz), text_color=hudText, bgcolor=isDarkHud ? color.new(color.gray, 80) : color.new(color.gray, 90))

        table.set_bgcolor(hud, hudBg)
        table.set_border_color(hud, hudBorder)
        table.set_frame_color(hud, hudBorder)
    else
        table.clear(hud, 0, 0, 1, 7)

//==============================================================================
// H. ALERTS
//==============================================================================

closeThroughPH  = not na(priorHigh) and ta.crossover(close, priorHigh)
closeThroughPL  = not na(priorLow)  and ta.crossunder(close, priorLow)
closeThroughPMH = not na(pmHigh)    and ta.crossover(close, pmHigh)
closeThroughPML = not na(pmLow)     and ta.crossunder(close, pmLow)

orbLockedAlert  = showORB and orLocked and not orLocked[1]
orbBreakoutUp   = showORB and orLocked and not na(orHigh) and close > orHigh + tickSz
orbBreakoutDown = showORB and orLocked and not na(orLow)  and close < orLow  - tickSz

alertcondition(closeThroughPH,  title="ATC Session Map — Close Through Prior High",      message="Price closed through Prior High on {{ticker}}.")
alertcondition(closeThroughPL,  title="ATC Session Map — Close Through Prior Low",       message="Price closed through Prior Low on {{ticker}}.")
alertcondition(closeThroughPMH, title="ATC Session Map — Close Through Pre-Market High", message="Price closed through Pre-Market High on {{ticker}}.")
alertcondition(closeThroughPML, title="ATC Session Map — Close Through Pre-Market Low",  message="Price closed through Pre-Market Low on {{ticker}}.")
alertcondition(orbLockedAlert,  title="ATC Session Map — ORB Locked",                     message="Opening Range locked on {{ticker}}.")
alertcondition(orbBreakoutUp,   title="ATC Session Map — ORB Breakout Up",                message="Price broke above ORB High on {{ticker}}.")
alertcondition(orbBreakoutDown, title="ATC Session Map — ORB Breakout Down",              message="Price broke below ORB Low on {{ticker}}.")
````
