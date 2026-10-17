# Initial Balance (IB) - Hitz2kk

- url: https://www.tradingview.com/script/oxOljAbN-Initial-Balance-IB-Hitz2kk/
- type: indicator
- pine_id: PUB;657a816f6ffc4e6ca66cc81d31e541cb
- version: 1.0

## Description

Initial Balance (IB) – Hitz2kk

This indicator automatically identifies and plots the Initial Balance (IB) — the high and low of a defined opening session — providing a structured framework to analyze intraday price behavior.

The Initial Balance represents the market’s early auction range, where price establishes short-term equilibrium before expansion. Once this range is formed, price often breaks out and sets the directional tone for the session.

Key Features
Automatic calculation of IB High and IB Low
Optional IB Midpoint (equilibrium level)
Visual IB range box during the session
Extension of IB levels throughout the trading day
Session-based logic with customizable time and timezone
Built-in breakout alert conditions (IB High / IB Low)
How It Works

The indicator tracks price during a user-defined session (e.g. market open) and records the highest and lowest prices within that window. These levels form the Initial Balance.

After the session ends:

IB High acts as a potential resistance / breakout level
IB Low acts as a potential support / breakdown level
IB Midpoint highlights equilibrium within the range

These levels remain extended for the rest of the session to assist with trade planning.

Typical Use Cases
Identifying breakout opportunities beyond the IB range
Assessing market direction after the opening range forms
Using IB levels as support and resistance zones
Measuring range expansion relative to IB size
Best Applied On
Index futures (e.g. ES, NQ, MES)
Equities and ETFs
Major FX pairs during active sessions
Notes

The Initial Balance is a widely used concept in intraday trading. This tool provides a clean and consistent way to visualize the opening range and monitor how price behaves around it throughout the session.

## Source Code

````pine
//@version=6
indicator("Initial Balance (IB) - Hitz2kk", overlay=true, max_lines_count=500, max_boxes_count=200, max_labels_count=200)

// =========================
// Inputs
// =========================
groupSession = "Session Settings"
ibSession     = input.session("0930-1030", "Initial Balance Session", group=groupSession)
sessionTz     = input.string("America/New_York", "Session Timezone", group=groupSession)
showBox       = input.bool(true, "Show IB Box", group=groupSession)
showMid       = input.bool(true, "Show IB Midline", group=groupSession)
extendLines   = input.bool(true, "Extend High/Low/Mid Right", group=groupSession)

groupStyle = "Style"
highColor   = input.color(color.lime, "IB High", group=groupStyle)
lowColor    = input.color(color.red, "IB Low", group=groupStyle)
midColor    = input.color(color.orange, "IB Mid", group=groupStyle)
boxColor    = input.color(color.new(color.blue, 85), "IB Box Fill", group=groupStyle)
borderColor = input.color(color.new(color.blue, 20), "IB Box Border", group=groupStyle)

groupInfo = "Labels"
showLabels = input.bool(true, "Show Labels", group=groupInfo)
showRange  = input.bool(true, "Show IB Range Label", group=groupInfo)

// =========================
// Session detection
// =========================
inIB = not na(time(timeframe.period, ibSession, sessionTz))
ibStart = inIB and not inIB[1]
ibEnd = not inIB and inIB[1]

// =========================
// Persistent vars
// =========================
var float ibHigh = na
var float ibLow = na
var float ibMid = na

var int ibStartTime = na
var int ibEndTime = na

var box ibBox = na
var line hiLine = na
var line loLine = na
var line midLine = na
var label hiLabel = na
var label loLabel = na
var label midLabel = na
var label rangeLabel = na

// =========================
// New IB session begins
// =========================
if ibStart
    ibHigh := high
    ibLow := low
    ibMid := (ibHigh + ibLow) / 2.0
    ibStartTime := time
    ibEndTime := time

    // clean prior active objects if needed
    ibBox := na
    hiLine := na
    loLine := na
    midLine := na
    hiLabel := na
    loLabel := na
    midLabel := na
    rangeLabel := na

    if showBox
        ibBox := box.new(left=bar_index, top=ibHigh, right=bar_index, bottom=ibLow, bgcolor=boxColor, border_color=borderColor)

    hiLine := line.new(bar_index, ibHigh, bar_index, ibHigh, color=highColor, width=2)
    loLine := line.new(bar_index, ibLow, bar_index, ibLow, color=lowColor, width=2)

    if showMid
        midLine := line.new(bar_index, ibMid, bar_index, ibMid, color=midColor, width=1, style=line.style_dashed)

// =========================
// While inside IB session
// =========================
if inIB
    ibHigh := na(ibHigh) ? high : math.max(ibHigh, high)
    ibLow := na(ibLow) ? low : math.min(ibLow, low)
    ibMid := (ibHigh + ibLow) / 2.0
    ibEndTime := time

    if showBox and not na(ibBox)
        box.set_right(ibBox, bar_index)
        box.set_top(ibBox, ibHigh)
        box.set_bottom(ibBox, ibLow)

    if not na(hiLine)
        line.set_x2(hiLine, bar_index)
        line.set_y1(hiLine, ibHigh)
        line.set_y2(hiLine, ibHigh)

    if not na(loLine)
        line.set_x2(loLine, bar_index)
        line.set_y1(loLine, ibLow)
        line.set_y2(loLine, ibLow)

    if showMid and not na(midLine)
        line.set_x2(midLine, bar_index)
        line.set_y1(midLine, ibMid)
        line.set_y2(midLine, ibMid)

// =========================
// When IB session ends
// =========================
if ibEnd
    if extendLines
        if not na(hiLine)
            line.set_extend(hiLine, extend.right)
        if not na(loLine)
            line.set_extend(loLine, extend.right)
        if showMid and not na(midLine)
            line.set_extend(midLine, extend.right)

    if showLabels
        hiLabel := label.new(bar_index, ibHigh, "IB High", style=label.style_label_down, textcolor=color.white, color=highColor)
        loLabel := label.new(bar_index, ibLow, "IB Low", style=label.style_label_up, textcolor=color.white, color=lowColor)
        if showMid
            midLabel := label.new(bar_index, ibMid, "IB Mid", style=label.style_label_left, textcolor=color.white, color=midColor)

    if showRange
        float ibRange = ibHigh - ibLow
        string rangeText = "IB Range: " + str.tostring(ibRange, format.mintick)
        rangeLabel := label.new(bar_index, ibHigh, rangeText, style=label.style_label_left, textcolor=color.white, color=color.new(color.black, 0))

// =========================
// Optional plots for alerts / values
// =========================
plot(ibHigh, "IB High", color=color.new(highColor, 0), linewidth=1, style=plot.style_linebr)
plot(ibLow, "IB Low", color=color.new(lowColor, 0), linewidth=1, style=plot.style_linebr)
plot(showMid ? ibMid : na, "IB Mid", color=color.new(midColor, 0), linewidth=1, style=plot.style_linebr)

// =========================
// Alert conditions
// =========================
longBreak = ta.crossover(close, ibHigh)
shortBreak = ta.crossunder(close, ibLow)

alertcondition(longBreak, title="IB High Breakout", message="Price broke above Initial Balance High")
alertcondition(shortBreak, title="IB Low Breakout", message="Price broke below Initial Balance Low")
````
