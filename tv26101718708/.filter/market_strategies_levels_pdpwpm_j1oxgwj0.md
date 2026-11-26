# Market Strategies levels PD/PW/PM

- url: https://www.tradingview.com/script/J1oxgWj0-Market-Strategies-levels-PD-PW-PM/
- type: indicator
- pine_id: PUB;84365c38b763499190d9e43c13812e59
- version: 2.0

## Description

Market Strategies Levels PD/PW/PM

Institutional-style Previous Day, Previous Week, and Previous Month liquidity levels built for traders who rely on key higher timeframe references for intraday and swing trading decisions.

This indicator automatically plots:

• PDH = Previous Day High
• PDL = Previous Day Low
• PWH = Previous Week High
• PWL = Previous Week Low
• PMH = Previous Month High
• PML = Previous Month Low

using clean extended horizontal levels rather than traditional stepped plots for a more professional chart appearance and easier market structure analysis.

Unlike many basic high/low scripts, this version uses properly confirmed higher timeframe data to ensure the levels remain accurate and fixed throughout the active session, week, or month.

FEATURES:

• Clean horizontal institutional-style levels
• Accurate confirmed previous Day/Week/Month levels
• Right-side labels with live prices
• Fully customizable colors and line widths
• Toggle visibility for Daily / Weekly / Monthly levels
• Cross alerts for every level
• Master alert for any level interaction
• Non-cluttered visual design for order flow and AMT traders

ALERTS INCLUDED:

• Price Crossed PDH
• Price Crossed PDL
• Price Crossed PWH
• Price Crossed PWL
• Price Crossed PMH
• Price Crossed PML
• Master alert when price crosses any major level

These levels are commonly used as:
• Liquidity targets
• Acceptance/rejection zones
• Expansion levels
• Intraday reversal areas
• Trend continuation references
• Mean reversion zones

The indicator is designed to work especially well alongside:
• VWAP
• Order flow tools
• CVD
• Bookmap
• AMT concepts
• Session highs/lows
• Imbalance trading

This script focuses on simplicity, visibility, and accurate higher timeframe references without repainting or cluttering the chart.

## Source Code

````pine
//@version=6
indicator("Market Strategies Levels PD/PW/PM + PDC + 9:30 Open", overlay=true, max_lines_count=50, max_labels_count=50)

//----------------------------------------------------
// INPUTS
//----------------------------------------------------

showPD = input.bool(true, "Show PDH/PDL")
showPW = input.bool(true, "Show PWH/PWL")
showPM = input.bool(true, "Show PMH/PML")
showPDC = input.bool(true, "Show Yesterday Close")
show930Open = input.bool(true, "Show 9:30 Open")

lineWidth = input.int(2, "Line Width", minval=1, maxval=5)
labelOffset = input.int(5, "Label Offset", minval=1, maxval=50)

//----------------------------------------------------
// COLORS
//----------------------------------------------------

pdhColor = input.color(color.white, "PDH")
pdlColor = input.color(color.white, "PDL")

pwhColor = input.color(color.yellow, "PWH")
pwlColor = input.color(color.yellow, "PWL")

pmhColor = input.color(color.rgb(38, 99, 255), "PMH")
pmlColor = input.color(color.rgb(38, 99, 255), "PML")

pdcColor = input.color(color.orange, "Yesterday Close")
open930Color = input.color(color.aqua, "9:30 Open")

labelTextColor = input.color(color.black, "Label Text Color")

//----------------------------------------------------
// PREVIOUS LEVELS
//----------------------------------------------------

PDH = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
PDL = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)
PDC = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)

PWH = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_on)
PWL = request.security(syminfo.tickerid, "W", low[1], lookahead=barmerge.lookahead_on)

PMH = request.security(syminfo.tickerid, "M", high[1], lookahead=barmerge.lookahead_on)
PML = request.security(syminfo.tickerid, "M", low[1], lookahead=barmerge.lookahead_on)

//----------------------------------------------------
// 9:30 OPEN
//----------------------------------------------------

newDay = ta.change(time("D")) != 0

is930Bar = hour == 9 and minute == 30

var float open930 = na

if newDay
    open930 := na

if is930Bar
    open930 := open

//----------------------------------------------------
// LINE STORAGE
//----------------------------------------------------

var line pdhLine = na
var line pdlLine = na
var line pwhLine = na
var line pwlLine = na
var line pmhLine = na
var line pmlLine = na
var line pdcLine = na
var line open930Line = na

//----------------------------------------------------
// LABEL STORAGE
//----------------------------------------------------

var label pdhLabel = na
var label pdlLabel = na
var label pwhLabel = na
var label pwlLabel = na
var label pmhLabel = na
var label pmlLabel = na
var label pdcLabel = na
var label open930Label = na

//----------------------------------------------------
// LEVEL FUNCTION
//----------------------------------------------------

f_level(_show, _price, _name, _color, _line, _label) =>
    line ln = _line
    label lb = _label

    if barstate.islast
        if _show and not na(_price)

            if na(ln)
                ln := line.new(bar_index - 500, _price, bar_index + labelOffset, _price, color=_color, width=lineWidth, extend=extend.right)

            line.set_xy1(ln, bar_index - 500, _price)
            line.set_xy2(ln, bar_index + labelOffset, _price)
            line.set_color(ln, _color)
            line.set_width(ln, lineWidth)

            label.delete(lb)

            lb := label.new(bar_index + labelOffset, _price, _name + "  " + str.tostring(_price, format.mintick), style=label.style_label_left, textcolor=labelTextColor, color=_color, size=size.normal)

        else
            line.delete(ln)
            label.delete(lb)

            ln := na
            lb := na

    [ln, lb]

//----------------------------------------------------
// DRAW PDH
//----------------------------------------------------

[pdhLineNew, pdhLabelNew] = f_level(showPD, PDH, "PDH", pdhColor, pdhLine, pdhLabel)

pdhLine := pdhLineNew
pdhLabel := pdhLabelNew

//----------------------------------------------------
// DRAW PDL
//----------------------------------------------------

[pdlLineNew, pdlLabelNew] = f_level(showPD, PDL, "PDL", pdlColor, pdlLine, pdlLabel)

pdlLine := pdlLineNew
pdlLabel := pdlLabelNew

//----------------------------------------------------
// DRAW PWH
//----------------------------------------------------

[pwhLineNew, pwhLabelNew] = f_level(showPW, PWH, "PWH", pwhColor, pwhLine, pwhLabel)

pwhLine := pwhLineNew
pwhLabel := pwhLabelNew

//----------------------------------------------------
// DRAW PWL
//----------------------------------------------------

[pwlLineNew, pwlLabelNew] = f_level(showPW, PWL, "PWL", pwlColor, pwlLine, pwlLabel)

pwlLine := pwlLineNew
pwlLabel := pwlLabelNew

//----------------------------------------------------
// DRAW PMH
//----------------------------------------------------

[pmhLineNew, pmhLabelNew] = f_level(showPM, PMH, "PMH", pmhColor, pmhLine, pmhLabel)

pmhLine := pmhLineNew
pmhLabel := pmhLabelNew

//----------------------------------------------------
// DRAW PML
//----------------------------------------------------

[pmlLineNew, pmlLabelNew] = f_level(showPM, PML, "PML", pmlColor, pmlLine, pmlLabel)

pmlLine := pmlLineNew
pmlLabel := pmlLabelNew

//----------------------------------------------------
// DRAW PREVIOUS DAY CLOSE
//----------------------------------------------------

[pdcLineNew, pdcLabelNew] = f_level(showPDC, PDC, "PDC", pdcColor, pdcLine, pdcLabel)

pdcLine := pdcLineNew
pdcLabel := pdcLabelNew

//----------------------------------------------------
// DRAW 9:30 OPEN
//----------------------------------------------------

[open930LineNew, open930LabelNew] = f_level(show930Open, open930, "9:30 OPEN", open930Color, open930Line, open930Label)

open930Line := open930LineNew
open930Label := open930LabelNew

//----------------------------------------------------
// CROSS CONDITIONS
//----------------------------------------------------

crossPDH = showPD and ta.cross(close, PDH)
crossPDL = showPD and ta.cross(close, PDL)

crossPWH = showPW and ta.cross(close, PWH)
crossPWL = showPW and ta.cross(close, PWL)

crossPMH = showPM and ta.cross(close, PMH)
crossPML = showPM and ta.cross(close, PML)

crossPDC = showPDC and ta.cross(close, PDC)

cross930Open = show930Open and not na(open930) and ta.cross(close, open930)

//----------------------------------------------------
// MASTER CROSS CONDITION
//----------------------------------------------------

crossAnyLevel = crossPDH or crossPDL or crossPWH or crossPWL or crossPMH or crossPML or crossPDC or cross930Open

//----------------------------------------------------
// INDIVIDUAL ALERTS
//----------------------------------------------------

alertcondition(crossPDH, "Price Crossed PDH", "Price crossed PDH")

alertcondition(crossPDL, "Price Crossed PDL", "Price crossed PDL")

alertcondition(crossPWH, "Price Crossed PWH", "Price crossed PWH")

alertcondition(crossPWL, "Price Crossed PWL", "Price crossed PWL")

alertcondition(crossPMH, "Price Crossed PMH", "Price crossed PMH")

alertcondition(crossPML, "Price Crossed PML", "Price crossed PML")

alertcondition(crossPDC, "Price Crossed Yesterday Close", "Price crossed yesterday's close")

alertcondition(cross930Open, "Price Crossed 9:30 Open", "Price crossed today's 9:30 opening price")

//----------------------------------------------------
// MASTER ALERT
//----------------------------------------------------

alertcondition(crossAnyLevel, "Price Crossed Any Major Level", "Price crossed one of the PDH/PDL/PWH/PWL/PMH/PML/PDC/9:30 Open levels")
````
