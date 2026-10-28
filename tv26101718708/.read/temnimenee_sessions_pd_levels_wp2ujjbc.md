# Temnimenee Sessions + PD Levels

- url: https://www.tradingview.com/script/wP2Ujjbc-temnimenee-sessions-pd-levels/
- type: indicator
- pine_id: PUB;f8c2675198e44336b5dc5e78bc4752f0
- version: 1.0

## Description

Trading Sessions Pro

Trading Sessions Pro is a session visualization tool created for ICT and Smart Money Concepts traders.

The indicator displays the four major trading sessions together with key Previous Day reference levels, providing a clean market structure for intraday analysis.

Features
Trading Sessions

Displays four major market sessions:

Asia
Frankfurt
London
New York

Each session includes:

Dynamic session range box
Optional borders
Custom colors
Adjustable border style
Historical session display

Session boxes automatically expand as new highs and lows are created and close exactly at the end of each session.

Previous Day Levels

The indicator plots the four most important Previous Day reference levels:

PDH – Previous Day High
PDL – Previous Day Low
PDO – Previous Day Open
PDC – Previous Day Close

Each level includes:

Independent visibility
Custom color
Custom line style
Custom line width
Right-aligned labels

Unlike many session indicators, the levels are anchored to the actual candle where they were created, rather than simply starting at the beginning of the trading day. This makes the chart cleaner and provides a more accurate visual representation of market structure.

Designed for

Trading Sessions Pro was built specifically for traders using:

ICT (Inner Circle Trader)
Smart Money Concepts (SMC)
Liquidity-based trading
Silver Bullet
Power of Three (PO3)
Session Range Trading
Daily Bias Analysis
Opening Range Models
Why Previous Day Levels?

Previous Day High and Low are among the most respected liquidity levels in the market.

Previous Day Open and Close provide valuable context for:

Premium & Discount
Daily Direction
Acceptance / Rejection
Market Structure
Intraday Bias

Keeping these levels visible throughout the trading session helps identify liquidity sweeps, reversals, and continuation setups.

Philosophy

This indicator focuses on clarity rather than complexity.

No unnecessary calculations.
No repainting.
No clutter.

Just the essential session structure and the most important Previous Day reference levels used by discretionary ICT and Smart Money traders.

Part of the Temnimenee Trading Sessions + PD Levels / Temnimenee Killzones  indicator series.

## Source Code

````pine
//@version=6
indicator("Temnimenee Sessions + PD Levels", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// ───── Timezone
tz = input.string("Europe/Podgorica", "Timezone")

// ───── Sessions
showAsia      = input.bool(true, "Show Asia")
showFrankfurt = input.bool(true, "Show Frankfurt")
showLondon    = input.bool(true, "Show London")
showNY        = input.bool(true, "Show New York")

asiaSession      = input.session("0100-0900", "Asia")
frankfurtSession = input.session("0800-0900", "Frankfurt")
londonSession    = input.session("0900-1530", "London")
nySession        = input.session("1530-2200", "New York")

asiaColor      = input.color(color.new(color.purple, 96), "Asia Fill")
frankfurtColor = input.color(color.new(color.orange, 96), "Frankfurt Fill")
londonColor    = input.color(color.new(color.blue, 96), "London Fill")
nyColor        = input.color(color.new(color.green, 96), "NY Fill")

// ───── Border
showBorder  = input.bool(false, "Show Session Border")
borderWidth = input.int(1, "Session Border Width", minval=1, maxval=5)
borderStyle = input.string("Solid", "Session Border Style", options=["Solid", "Dashed", "Dotted"])
showSessionLabels = input.bool(false, "Show Session Labels")

// ───── PD Levels
showPDLevels = input.bool(true, "Show PD Levels")

showPDH = input.bool(true, "Show PDH")
showPDL = input.bool(true, "Show PDL")
showPDC = input.bool(true, "Show PDC")
showPDO = input.bool(true, "Show PDO")

defaultLevelColor = color.rgb(99, 99, 99)

pdhColor = input.color(defaultLevelColor, "PDH Color")
pdlColor = input.color(defaultLevelColor, "PDL Color")
pdcColor = input.color(defaultLevelColor, "PDC Color")
pdoColor = input.color(defaultLevelColor, "PDO Color")

pdhStyle = input.string("Solid", "PDH Style", options=["Solid", "Dashed", "Dotted"])
pdlStyle = input.string("Solid", "PDL Style", options=["Solid", "Dashed", "Dotted"])
pdcStyle = input.string("Solid", "PDC Style", options=["Solid", "Dashed", "Dotted"])
pdoStyle = input.string("Solid", "PDO Style", options=["Solid", "Dashed", "Dotted"])

pdWidth = input.int(1, "PD Levels Width", minval=1, maxval=5)
searchBars = input.int(1500, "Intraday Search Bars For PDH/PDL", minval=50, maxval=5000)

// ───── Helpers
f_lineStyle(_style) =>
    _style == "Dashed" ? line.style_dashed : _style == "Dotted" ? line.style_dotted : line.style_solid

f_borderColor(_color) =>
    showBorder ? color.new(_color, 0) : color.new(_color, 100)

// ───── Sessions
f_sessionBox(_show, _session, _name, _fillColor) =>
    inSession  = _show and not na(time(timeframe.period, _session, tz))
    newSession = inSession and not inSession[1]

    var box bx = na
    var label lb = na
    var float hi = na
    var float lo = na

    if newSession
        hi := high
        lo := low
        bx := box.new(time, hi, time_close, lo, xloc=xloc.bar_time, bgcolor=_fillColor, border_color=f_borderColor(_fillColor), border_width=borderWidth, border_style=f_lineStyle(borderStyle))

        if showSessionLabels
            lb := label.new(time, hi, _name, xloc=xloc.bar_time, style=label.style_label_down, textcolor=color.white, color=f_borderColor(_fillColor), size=size.small)

    if inSession
        hi := math.max(hi, high)
        lo := math.min(lo, low)

        if not na(bx)
            box.set_right(bx, time_close)
            box.set_top(bx, hi)
            box.set_bottom(bx, lo)
            box.set_border_color(bx, f_borderColor(_fillColor))
            box.set_border_width(bx, borderWidth)
            box.set_border_style(bx, f_lineStyle(borderStyle))

        if showSessionLabels and not na(lb)
            label.set_x(lb, time_close)
            label.set_y(lb, hi)

f_sessionBox(showAsia, asiaSession, "ASIA", asiaColor)
f_sessionBox(showFrankfurt, frankfurtSession, "FRANKFURT", frankfurtColor)
f_sessionBox(showLondon, londonSession, "LONDON", londonColor)
f_sessionBox(showNY, nySession, "NEW YORK", nyColor)

// ───── Correct Previous Day Levels From TradingView Daily Candle
pdHigh  = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pdLow   = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)
pdClose = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)
pdOpen  = request.security(syminfo.tickerid, "D", open[1], lookahead=barmerge.lookahead_on)

pdStart = request.security(syminfo.tickerid, "D", time[1], lookahead=barmerge.lookahead_on)
pdEnd   = request.security(syminfo.tickerid, "D", time_close[1], lookahead=barmerge.lookahead_on)

// ───── Find Intraday Candle Where PDH/PDL Were Formed
f_findPDHTime(_level, _pdStart, _pdEnd) =>
    int found = _pdStart
    for i = 0 to searchBars
        if not na(time[i]) and time[i] >= _pdStart and time[i] < _pdEnd and math.abs(high[i] - _level) <= syminfo.mintick * 2
            found := time[i]
            break
    found

f_findPDLTime(_level, _pdStart, _pdEnd) =>
    int found = _pdStart
    for i = 0 to searchBars
        if not na(time[i]) and time[i] >= _pdStart and time[i] < _pdEnd and math.abs(low[i] - _level) <= syminfo.mintick * 2
            found := time[i]
            break
    found

pdhStartTime = f_findPDHTime(pdHigh, pdStart, pdEnd)
pdlStartTime = f_findPDLTime(pdLow, pdStart, pdEnd)
pdoStartTime = pdStart
pdcStartTime = pdEnd

// ───── Lines / Labels
var line pdhLine = na
var line pdlLine = na
var line pdcLine = na
var line pdoLine = na

var label pdhLabel = na
var label pdlLabel = na
var label pdcLabel = na
var label pdoLabel = na

// ───── Draw/update function
f_updateLine(_line, _label, _show, _x1, _price, _txt, _color, _style) =>
    line ln = _line
    label lb = _label

    if showPDLevels and _show and not na(_price) and not na(_x1)
        if na(ln)
            ln := line.new(_x1, _price, time_close, _price, xloc=xloc.bar_time, color=_color, width=pdWidth, style=f_lineStyle(_style))
            lb := label.new(time_close, _price, _txt, xloc=xloc.bar_time, style=label.style_label_left, textcolor=_color, color=color.new(color.white, 100), size=size.small)
        else
            line.set_x1(ln, _x1)
            line.set_x2(ln, time_close)
            line.set_y1(ln, _price)
            line.set_y2(ln, _price)
            line.set_color(ln, _color)
            line.set_width(ln, pdWidth)
            line.set_style(ln, f_lineStyle(_style))

            label.set_x(lb, time_close)
            label.set_y(lb, _price)
            label.set_text(lb, _txt)
            label.set_textcolor(lb, _color)
    else
        line.delete(ln)
        label.delete(lb)
        ln := na
        lb := na

    [ln, lb]

// ───── Update PD Levels
[pdhLineNew, pdhLabelNew] = f_updateLine(pdhLine, pdhLabel, showPDH, pdhStartTime, pdHigh, "PDH", pdhColor, pdhStyle)
pdhLine := pdhLineNew
pdhLabel := pdhLabelNew

[pdlLineNew, pdlLabelNew] = f_updateLine(pdlLine, pdlLabel, showPDL, pdlStartTime, pdLow, "PDL", pdlColor, pdlStyle)
pdlLine := pdlLineNew
pdlLabel := pdlLabelNew

[pdcLineNew, pdcLabelNew] = f_updateLine(pdcLine, pdcLabel, showPDC, pdcStartTime, pdClose, "PDC", pdcColor, pdcStyle)
pdcLine := pdcLineNew
pdcLabel := pdcLabelNew

[pdoLineNew, pdoLabelNew] = f_updateLine(pdoLine, pdoLabel, showPDO, pdoStartTime, pdOpen, "PDO", pdoColor, pdoStyle)
pdoLine := pdoLineNew
pdoLabel := pdoLabelNew
````
