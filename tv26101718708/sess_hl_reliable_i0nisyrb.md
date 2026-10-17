# Sess H/L Reliable

- url: https://www.tradingview.com/script/i0nISyRB-Sess-H-L-Reliable/
- type: indicator
- pine_id: PUB;e36d1b5882514d70b9039a7c05475852
- version: 1.0

## Description

**Session High/Low Liquidity Indicator**

This indicator automatically marks the key session highs and lows that price is most likely to sweep, retest, or use as continuation/reversal points. It is built around session-based liquidity, helping traders quickly identify where buy-side and sell-side liquidity is resting throughout the trading day.

The indicator highlights important highs and lows from Asia, London, Pre-New York, NY AM, Lunch, and NY PM sessions. These levels are designed to help traders read when price is accumulating, manipulating, sweeping liquidity, or preparing for expansion into the next session level.

The main purpose of this tool is to simplify session analysis by keeping the most important liquidity levels clearly visible on the chart. Traders can use these levels to watch for sweeps, failed breaks, strong 15-minute closes, retracements, and continuation setups.

Best used with New York time, this indicator helps organize the trading day into clean liquidity zones so traders can focus on high-probability areas instead of reacting to random price movement.

For educational and analysis purposes only. This indicator does not provide financial advice or guaranteed trade signals.

## Source Code

````pine
//@version=6
indicator("Sess H/L Reliable", "Sess H/L", overlay=true, scale=scale.none, max_lines_count=20, max_labels_count=20)

groupGeneral = "General"
tz = input.string("America/New_York", "Session timezone", group=groupGeneral)
rightBars = input.int(75, "Line length to the right", minval=1, maxval=500, group=groupGeneral)
showLabels = input.bool(true, "Show labels", group=groupGeneral)
cutMitigated = input.bool(true, "Cut off mitigated lines", group=groupGeneral)
mitigatedLineColor = input.color(color.gray, "Mitigated line color", group=groupGeneral)
labelOffset = input.int(5, "Label offset in bars", minval=0, maxval=100, group=groupGeneral)
lineStyleInput = input.string("Solid", "Line style", options=["Solid", "Dashed", "Dotted"], group=groupGeneral)
textSizeInput = input.string("Small", "Text size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=groupGeneral)
lineStyle = lineStyleInput == "Dashed" ? line.style_dashed : lineStyleInput == "Dotted" ? line.style_dotted : line.style_solid
textSize = textSizeInput == "Tiny" ? size.tiny : textSizeInput == "Small" ? size.small : textSizeInput == "Normal" ? size.normal : textSizeInput == "Large" ? size.large : size.huge

g1 = "Session 1 - New York AM"
show1 = input.bool(true, "Show session", group=g1)
sess1 = input.session("0930-1200:1234567", "Time period", group=g1)
hiTxt1 = input.string("NY AM High", "High label", group=g1)
loTxt1 = input.string("NY AM Low", "Low label", group=g1)
hiCol1 = input.color(color.lime, "High line color", group=g1)
loCol1 = input.color(color.red, "Low line color", group=g1)
wid1 = input.int(2, "Line thickness", minval=1, maxval=5, group=g1)

g2 = "Session 2 - New York PM"
show2 = input.bool(true, "Show session", group=g2)
sess2 = input.session("1300-1600:1234567", "Time period", group=g2)
hiTxt2 = input.string("NY PM High", "High label", group=g2)
loTxt2 = input.string("NY PM Low", "Low label", group=g2)
hiCol2 = input.color(color.aqua, "High line color", group=g2)
loCol2 = input.color(color.orange, "Low line color", group=g2)
wid2 = input.int(2, "Line thickness", minval=1, maxval=5, group=g2)

g3 = "Session 3 - Asia"
show3 = input.bool(true, "Show session", group=g3)
sess3 = input.session("1800-2359:1234567", "Time period", group=g3)
hiTxt3 = input.string("Asia High", "High label", group=g3)
loTxt3 = input.string("Asia Low", "Low label", group=g3)
hiCol3 = input.color(color.fuchsia, "High line color", group=g3)
loCol3 = input.color(color.purple, "Low line color", group=g3)
wid3 = input.int(2, "Line thickness", minval=1, maxval=5, group=g3)

g4 = "Session 4 - London"
show4 = input.bool(true, "Show session", group=g4)
sess4 = input.session("0000-0500:1234567", "Time period", group=g4)
hiTxt4 = input.string("London High", "High label", group=g4)
loTxt4 = input.string("London Low", "Low label", group=g4)
hiCol4 = input.color(color.yellow, "High line color", group=g4)
loCol4 = input.color(color.blue, "Low line color", group=g4)
wid4 = input.int(2, "Line thickness", minval=1, maxval=5, group=g4)

makeLine(int x1, int x2, float y, color c, int w) =>
    line.new(x1, y, x2, y, xloc=xloc.bar_index, extend=extend.none, color=c, style=lineStyle, width=w, force_overlay=true)
makeLabel(int x, float y, string t, color c) =>
    label.new(x + labelOffset, y, t, xloc=xloc.bar_index, style=label.style_label_left, textcolor=c, color=color.new(color.black, 100), size=textSize, force_overlay=true)

var float hi1 = na
var float lo1 = na
var int hiBar1 = na
var int loBar1 = na
var line hiLine1 = na
var line loLine1 = na
var label hiLbl1 = na
var label loLbl1 = na
var bool hiMit1 = false
var bool loMit1 = false
in1 = show1 and not na(time(timeframe.period, sess1, tz))
if in1 and not in1[1]
    line.delete(hiLine1), line.delete(loLine1), label.delete(hiLbl1), label.delete(loLbl1)
    hi1 := high, lo1 := low, hiBar1 := bar_index, loBar1 := bar_index
    hiMit1 := false, loMit1 := false
    hiLine1 := makeLine(hiBar1, bar_index + rightBars, hi1, hiCol1, wid1)
    loLine1 := makeLine(loBar1, bar_index + rightBars, lo1, loCol1, wid1)
    if showLabels
        hiLbl1 := makeLabel(bar_index + rightBars, hi1, hiTxt1, hiCol1)
        loLbl1 := makeLabel(bar_index + rightBars, lo1, loTxt1, loCol1)
if in1
    if high > hi1
        hi1 := high, hiBar1 := bar_index
    if low < lo1
        lo1 := low, loBar1 := bar_index
if not in1
    if not hiMit1 and not na(hiLine1) and high >= hi1
        line.set_color(hiLine1, mitigatedLineColor)
        if cutMitigated
            line.set_xy2(hiLine1, bar_index, hi1), label.delete(hiLbl1)
            hiLbl1 := na
        else if not na(hiLbl1)
            label.set_textcolor(hiLbl1, mitigatedLineColor)
        hiMit1 := true
    if not loMit1 and not na(loLine1) and low <= lo1
        line.set_color(loLine1, mitigatedLineColor)
        if cutMitigated
            line.set_xy2(loLine1, bar_index, lo1), label.delete(loLbl1)
            loLbl1 := na
        else if not na(loLbl1)
            label.set_textcolor(loLbl1, mitigatedLineColor)
        loMit1 := true
if show1 and (not na(hiLine1) or not na(loLine1))
    endBar1 = bar_index + rightBars
    if not na(hiLine1) and (not hiMit1 or not cutMitigated)
        line.set_xy1(hiLine1, hiBar1, hi1), line.set_xy2(hiLine1, endBar1, hi1), line.set_color(hiLine1, hiMit1 ? mitigatedLineColor : hiCol1)
    if not na(loLine1) and (not loMit1 or not cutMitigated)
        line.set_xy1(loLine1, loBar1, lo1), line.set_xy2(loLine1, endBar1, lo1), line.set_color(loLine1, loMit1 ? mitigatedLineColor : loCol1)
    if showLabels and not na(hiLine1) and (not hiMit1 or not cutMitigated)
        if na(hiLbl1)
            hiLbl1 := makeLabel(endBar1, hi1, hiTxt1, hiMit1 ? mitigatedLineColor : hiCol1)
        label.set_xy(hiLbl1, endBar1, hi1), label.set_text(hiLbl1, hiTxt1), label.set_textcolor(hiLbl1, hiMit1 ? mitigatedLineColor : hiCol1)
    if showLabels and not na(loLine1) and (not loMit1 or not cutMitigated)
        if na(loLbl1)
            loLbl1 := makeLabel(endBar1, lo1, loTxt1, loMit1 ? mitigatedLineColor : loCol1)
        label.set_xy(loLbl1, endBar1, lo1), label.set_text(loLbl1, loTxt1), label.set_textcolor(loLbl1, loMit1 ? mitigatedLineColor : loCol1)

var float hi2 = na
var float lo2 = na
var int hiBar2 = na
var int loBar2 = na
var line hiLine2 = na
var line loLine2 = na
var label hiLbl2 = na
var label loLbl2 = na
var bool hiMit2 = false
var bool loMit2 = false
in2 = show2 and not na(time(timeframe.period, sess2, tz))
if in2 and not in2[1]
    line.delete(hiLine2), line.delete(loLine2), label.delete(hiLbl2), label.delete(loLbl2)
    hi2 := high, lo2 := low, hiBar2 := bar_index, loBar2 := bar_index
    hiMit2 := false, loMit2 := false
    hiLine2 := makeLine(hiBar2, bar_index + rightBars, hi2, hiCol2, wid2)
    loLine2 := makeLine(loBar2, bar_index + rightBars, lo2, loCol2, wid2)
    if showLabels
        hiLbl2 := makeLabel(bar_index + rightBars, hi2, hiTxt2, hiCol2)
        loLbl2 := makeLabel(bar_index + rightBars, lo2, loTxt2, loCol2)
if in2
    if high > hi2
        hi2 := high, hiBar2 := bar_index
    if low < lo2
        lo2 := low, loBar2 := bar_index
if not in2
    if not hiMit2 and not na(hiLine2) and high >= hi2
        line.set_color(hiLine2, mitigatedLineColor)
        if cutMitigated
            line.set_xy2(hiLine2, bar_index, hi2), label.delete(hiLbl2)
            hiLbl2 := na
        else if not na(hiLbl2)
            label.set_textcolor(hiLbl2, mitigatedLineColor)
        hiMit2 := true
    if not loMit2 and not na(loLine2) and low <= lo2
        line.set_color(loLine2, mitigatedLineColor)
        if cutMitigated
            line.set_xy2(loLine2, bar_index, lo2), label.delete(loLbl2)
            loLbl2 := na
        else if not na(loLbl2)
            label.set_textcolor(loLbl2, mitigatedLineColor)
        loMit2 := true
if show2 and (not na(hiLine2) or not na(loLine2))
    endBar2 = bar_index + rightBars
    if not na(hiLine2) and (not hiMit2 or not cutMitigated)
        line.set_xy1(hiLine2, hiBar2, hi2), line.set_xy2(hiLine2, endBar2, hi2), line.set_color(hiLine2, hiMit2 ? mitigatedLineColor : hiCol2)
    if not na(loLine2) and (not loMit2 or not cutMitigated)
        line.set_xy1(loLine2, loBar2, lo2), line.set_xy2(loLine2, endBar2, lo2), line.set_color(loLine2, loMit2 ? mitigatedLineColor : loCol2)
    if showLabels and not na(hiLine2) and (not hiMit2 or not cutMitigated)
        if na(hiLbl2)
            hiLbl2 := makeLabel(endBar2, hi2, hiTxt2, hiMit2 ? mitigatedLineColor : hiCol2)
        label.set_xy(hiLbl2, endBar2, hi2), label.set_text(hiLbl2, hiTxt2), label.set_textcolor(hiLbl2, hiMit2 ? mitigatedLineColor : hiCol2)
    if showLabels and not na(loLine2) and (not loMit2 or not cutMitigated)
        if na(loLbl2)
            loLbl2 := makeLabel(endBar2, lo2, loTxt2, loMit2 ? mitigatedLineColor : loCol2)
        label.set_xy(loLbl2, endBar2, lo2), label.set_text(loLbl2, loTxt2), label.set_textcolor(loLbl2, loMit2 ? mitigatedLineColor : loCol2)

var float hi3 = na
var float lo3 = na
var int hiBar3 = na
var int loBar3 = na
var line hiLine3 = na
var line loLine3 = na
var label hiLbl3 = na
var label loLbl3 = na
var bool hiMit3 = false
var bool loMit3 = false
in3 = show3 and not na(time(timeframe.period, sess3, tz))
if in3 and not in3[1]
    line.delete(hiLine3), line.delete(loLine3), label.delete(hiLbl3), label.delete(loLbl3)
    hi3 := high, lo3 := low, hiBar3 := bar_index, loBar3 := bar_index
    hiMit3 := false, loMit3 := false
    hiLine3 := makeLine(hiBar3, bar_index + rightBars, hi3, hiCol3, wid3)
    loLine3 := makeLine(loBar3, bar_index + rightBars, lo3, loCol3, wid3)
    if showLabels
        hiLbl3 := makeLabel(bar_index + rightBars, hi3, hiTxt3, hiCol3)
        loLbl3 := makeLabel(bar_index + rightBars, lo3, loTxt3, loCol3)
if in3
    if high > hi3
        hi3 := high, hiBar3 := bar_index
    if low < lo3
        lo3 := low, loBar3 := bar_index
if not in3
    if not hiMit3 and not na(hiLine3) and high >= hi3
        line.set_color(hiLine3, mitigatedLineColor)
        if cutMitigated
            line.set_xy2(hiLine3, bar_index, hi3), label.delete(hiLbl3)
            hiLbl3 := na
        else if not na(hiLbl3)
            label.set_textcolor(hiLbl3, mitigatedLineColor)
        hiMit3 := true
    if not loMit3 and not na(loLine3) and low <= lo3
        line.set_color(loLine3, mitigatedLineColor)
        if cutMitigated
            line.set_xy2(loLine3, bar_index, lo3), label.delete(loLbl3)
            loLbl3 := na
        else if not na(loLbl3)
            label.set_textcolor(loLbl3, mitigatedLineColor)
        loMit3 := true
if show3 and (not na(hiLine3) or not na(loLine3))
    endBar3 = bar_index + rightBars
    if not na(hiLine3) and (not hiMit3 or not cutMitigated)
        line.set_xy1(hiLine3, hiBar3, hi3), line.set_xy2(hiLine3, endBar3, hi3), line.set_color(hiLine3, hiMit3 ? mitigatedLineColor : hiCol3)
    if not na(loLine3) and (not loMit3 or not cutMitigated)
        line.set_xy1(loLine3, loBar3, lo3), line.set_xy2(loLine3, endBar3, lo3), line.set_color(loLine3, loMit3 ? mitigatedLineColor : loCol3)
    if showLabels and not na(hiLine3) and (not hiMit3 or not cutMitigated)
        if na(hiLbl3)
            hiLbl3 := makeLabel(endBar3, hi3, hiTxt3, hiMit3 ? mitigatedLineColor : hiCol3)
        label.set_xy(hiLbl3, endBar3, hi3), label.set_text(hiLbl3, hiTxt3), label.set_textcolor(hiLbl3, hiMit3 ? mitigatedLineColor : hiCol3)
    if showLabels and not na(loLine3) and (not loMit3 or not cutMitigated)
        if na(loLbl3)
            loLbl3 := makeLabel(endBar3, lo3, loTxt3, loMit3 ? mitigatedLineColor : loCol3)
        label.set_xy(loLbl3, endBar3, lo3), label.set_text(loLbl3, loTxt3), label.set_textcolor(loLbl3, loMit3 ? mitigatedLineColor : loCol3)

var float hi4 = na
var float lo4 = na
var int hiBar4 = na
var int loBar4 = na
var line hiLine4 = na
var line loLine4 = na
var label hiLbl4 = na
var label loLbl4 = na
var bool hiMit4 = false
var bool loMit4 = false
in4 = show4 and not na(time(timeframe.period, sess4, tz))
if in4 and not in4[1]
    line.delete(hiLine4), line.delete(loLine4), label.delete(hiLbl4), label.delete(loLbl4)
    hi4 := high, lo4 := low, hiBar4 := bar_index, loBar4 := bar_index
    hiMit4 := false, loMit4 := false
    hiLine4 := makeLine(hiBar4, bar_index + rightBars, hi4, hiCol4, wid4)
    loLine4 := makeLine(loBar4, bar_index + rightBars, lo4, loCol4, wid4)
    if showLabels
        hiLbl4 := makeLabel(bar_index + rightBars, hi4, hiTxt4, hiCol4)
        loLbl4 := makeLabel(bar_index + rightBars, lo4, loTxt4, loCol4)
if in4
    if high > hi4
        hi4 := high, hiBar4 := bar_index
    if low < lo4
        lo4 := low, loBar4 := bar_index
if not in4
    if not hiMit4 and not na(hiLine4) and high >= hi4
        line.set_color(hiLine4, mitigatedLineColor)
        if cutMitigated
            line.set_xy2(hiLine4, bar_index, hi4), label.delete(hiLbl4)
            hiLbl4 := na
        else if not na(hiLbl4)
            label.set_textcolor(hiLbl4, mitigatedLineColor)
        hiMit4 := true
    if not loMit4 and not na(loLine4) and low <= lo4
        line.set_color(loLine4, mitigatedLineColor)
        if cutMitigated
            line.set_xy2(loLine4, bar_index, lo4), label.delete(loLbl4)
            loLbl4 := na
        else if not na(loLbl4)
            label.set_textcolor(loLbl4, mitigatedLineColor)
        loMit4 := true
if show4 and (not na(hiLine4) or not na(loLine4))
    endBar4 = bar_index + rightBars
    if not na(hiLine4) and (not hiMit4 or not cutMitigated)
        line.set_xy1(hiLine4, hiBar4, hi4), line.set_xy2(hiLine4, endBar4, hi4), line.set_color(hiLine4, hiMit4 ? mitigatedLineColor : hiCol4)
    if not na(loLine4) and (not loMit4 or not cutMitigated)
        line.set_xy1(loLine4, loBar4, lo4), line.set_xy2(loLine4, endBar4, lo4), line.set_color(loLine4, loMit4 ? mitigatedLineColor : loCol4)
    if showLabels and not na(hiLine4) and (not hiMit4 or not cutMitigated)
        if na(hiLbl4)
            hiLbl4 := makeLabel(endBar4, hi4, hiTxt4, hiMit4 ? mitigatedLineColor : hiCol4)
        label.set_xy(hiLbl4, endBar4, hi4), label.set_text(hiLbl4, hiTxt4), label.set_textcolor(hiLbl4, hiMit4 ? mitigatedLineColor : hiCol4)
    if showLabels and not na(loLine4) and (not loMit4 or not cutMitigated)
        if na(loLbl4)
            loLbl4 := makeLabel(endBar4, lo4, loTxt4, loMit4 ? mitigatedLineColor : loCol4)
        label.set_xy(loLbl4, endBar4, lo4), label.set_text(loLbl4, loTxt4), label.set_textcolor(loLbl4, loMit4 ? mitigatedLineColor : loCol4)
````
