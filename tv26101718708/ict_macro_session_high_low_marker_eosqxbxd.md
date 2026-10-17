# ICT Macro + Session High Low Marker

- url: https://www.tradingview.com/script/eosqxbXD-ICT-Macro-Session-High-Low-Marker/
- type: indicator
- pine_id: PUB;f42c2aafaced4a2ab964730b648a9577
- version: 1.0

## Description

[b]ICT Macro + Session High Low Marker[/b] is a clean time-based ICT indicator designed to help traders visually identify important macro time windows and major session highs/lows directly on the chart.

This tool highlights key London and New York ICT Macro windows, helping traders focus on periods where liquidity sweeps, displacement, reversals, or continuation moves may occur. It also marks the Asian, London, and New York session highs and lows, which can be useful for identifying liquidity targets and possible price reactions.

[b]Features[/b]
[list]
[*]Highlights important ICT Macro time windows.
[*]Includes London Macro and New York Macro sessions.
[*]Marks Asian, London, and New York session highs/lows.
[*]Optional session boxes for better visual structure.
[*]Optional high/low line extension.
[*]Customizable colors, labels, timezone, and session times.
[*]Weekdays-only filter.
[*]Alert conditions for macro starts and session starts/ends.
[*]Best Used For
[/list]

This indicator is useful for traders who follow ICT concepts such as:

[list]
[*]Liquidity sweeps
[*]Kill zones
[*]Macro time windows
[*]Session high/low targeting
[*]London and New York session timing
[*]Intraday bias confirmation
[/list]

[b]How to Use[/b]
Use the macro windows as timing zones, not automatic buy or sell signals. First identify your market bias, liquidity target, and higher-timeframe context. Then use the highlighted macro windows to watch for potential displacement, fair value gaps, reversals, or continuation setups.

The session high and low markers can help you identify where price may seek liquidity during London or New York trading hours.

[b]Disclaimer[/b]
This indicator does not provide financial advice and does not guarantee profitable trades. It is intended for educational and analysis purposes only. Always use proper risk management and confirm setups with your own trading plan.

## Source Code

````pine
//@version=5
indicator("ICT Macro + Session High Low Marker", overlay=true, max_boxes_count=150, max_lines_count=500, max_labels_count=500)

//====================================================
// GENERAL SETTINGS
//====================================================
groupGeneral = "General Settings"

tz             = input.string("America/New_York", "Timezone", group=groupGeneral)
weekdaysOnly   = input.bool(true, "Weekdays Only", group=groupGeneral)
showLabels     = input.bool(true, "Show Labels", group=groupGeneral)
labelAtrOffset = input.float(0.50, "Label Offset Using ATR", step=0.10, group=groupGeneral)

dayFilter = weekdaysOnly ? ":23456" : ":1234567"
atrValue  = ta.atr(14)

labelSizeOpt = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal"], group=groupGeneral)
labelSize = labelSizeOpt == "Tiny" ? size.tiny : labelSizeOpt == "Small" ? size.small : size.normal

//====================================================
// ICT MACRO SETTINGS
//====================================================
groupMacroGeneral = "ICT Macro Settings"

showMacroBg     = input.bool(true, "Highlight ICT Macro Background", group=groupMacroGeneral)
showMacroLabels = input.bool(true, "Show ICT Macro Labels", group=groupMacroGeneral)

// London Macro 1
groupL1 = "London Macro 1 | 2:33 - 3:00 AM NY"
l1On      = input.bool(true, "Enable", group=groupL1)
l1Session = input.session("0233-0300", "NY Time", group=groupL1)
l1Color   = input.color(color.new(color.blue, 85), "Highlight Color", group=groupL1)

// London Macro 2
groupL2 = "London Macro 2 | 4:03 - 4:30 AM NY"
l2On      = input.bool(true, "Enable", group=groupL2)
l2Session = input.session("0403-0430", "NY Time", group=groupL2)
l2Color   = input.color(color.new(color.teal, 85), "Highlight Color", group=groupL2)

// NY Macro 1
groupM1 = "8:50 - 9:10 AM | NY Open Liquidity Move"
m1On      = input.bool(true, "Enable", group=groupM1)
m1Session = input.session("0850-0910", "NY Time", group=groupM1)
m1Color   = input.color(color.new(color.aqua, 85), "Highlight Color", group=groupM1)

// NY Macro 2
groupM2 = "9:50 - 10:10 AM | Continuation or Reversal"
m2On      = input.bool(true, "Enable", group=groupM2)
m2Session = input.session("0950-1010", "NY Time", group=groupM2)
m2Color   = input.color(color.new(color.yellow, 85), "Highlight Color", group=groupM2)

// NY Macro 3
groupM3 = "10:50 - 11:10 AM | Liquidity / Displacement Window"
m3On      = input.bool(true, "Enable", group=groupM3)
m3Session = input.session("1050-1110", "NY Time", group=groupM3)
m3Color   = input.color(color.new(color.orange, 85), "Highlight Color", group=groupM3)

// NY Macro 4
groupM4 = "11:50 AM - 12:10 PM | Lunch-Time Liquidity"
m4On      = input.bool(true, "Enable", group=groupM4)
m4Session = input.session("1150-1210", "NY Time", group=groupM4)
m4Color   = input.color(color.new(color.purple, 85), "Highlight Color", group=groupM4)

// NY Macro 5
groupM5 = "1:10 - 1:40 PM | PM Session Setup"
m5On      = input.bool(true, "Enable", group=groupM5)
m5Session = input.session("1310-1340", "NY Time", group=groupM5)
m5Color   = input.color(color.new(color.lime, 85), "Highlight Color", group=groupM5)

// NY Macro 6
groupM6 = "3:15 - 3:45 PM | Late-Day Move"
m6On      = input.bool(true, "Enable", group=groupM6)
m6Session = input.session("1515-1545", "NY Time", group=groupM6)
m6Color   = input.color(color.new(color.red, 85), "Highlight Color", group=groupM6)

//====================================================
// SESSION HIGH / LOW SETTINGS
//====================================================
groupSessionGeneral = "Session High / Low Settings"

showSessionBoxes  = input.bool(false, "Show Session Boxes", group=groupSessionGeneral)
showSessionLines  = input.bool(true, "Show Session High/Low Lines", group=groupSessionGeneral)
showSessionLabels = input.bool(true, "Show Session Labels", group=groupSessionGeneral)
extendSessionHL   = input.bool(false, "Extend Session High/Low Lines", group=groupSessionGeneral)
boxTransp         = input.int(88, "Box Transparency", minval=0, maxval=100, group=groupSessionGeneral)
lineWidth         = input.int(1, "Line Width", minval=1, maxval=4, group=groupSessionGeneral)

// Asian Session
groupAsia = "Asian Session"
asiaOn      = input.bool(true, "Enable Asian Session", group=groupAsia)
asiaSession = input.session("2000-0000", "Asian Session Time", group=groupAsia)
asiaColor   = input.color(color.rgb(80, 170, 255), "Asian Color", group=groupAsia)

// London Session
groupLondon = "London Session"
londonOn      = input.bool(true, "Enable London Session", group=groupLondon)
londonSession = input.session("0200-0500", "London Session Time", group=groupLondon)
londonColor   = input.color(color.rgb(180, 120, 255), "London Color", group=groupLondon)

// New York Session
groupNY = "New York Session"
nyOn      = input.bool(true, "Enable New York Session", group=groupNY)
nySession = input.session("0700-1000", "New York Session Time", group=groupNY)
nyColor   = input.color(color.rgb(255, 170, 80), "New York Color", group=groupNY)

//====================================================
// HELPER FUNCTION
//====================================================
f_inSession(_enabled, _session) =>
    _enabled and not na(time(timeframe.period, _session + dayFilter, tz))

//====================================================
// ICT MACRO LOGIC
//====================================================
l1 = f_inSession(l1On, l1Session)
l2 = f_inSession(l2On, l2Session)

m1 = f_inSession(m1On, m1Session)
m2 = f_inSession(m2On, m2Session)
m3 = f_inSession(m3On, m3Session)
m4 = f_inSession(m4On, m4Session)
m5 = f_inSession(m5On, m5Session)
m6 = f_inSession(m6On, m6Session)

l1Start = l1 and not nz(l1[1], false)
l2Start = l2 and not nz(l2[1], false)

m1Start = m1 and not nz(m1[1], false)
m2Start = m2 and not nz(m2[1], false)
m3Start = m3 and not nz(m3[1], false)
m4Start = m4 and not nz(m4[1], false)
m5Start = m5 and not nz(m5[1], false)
m6Start = m6 and not nz(m6[1], false)

macroColor =
     l1 ? l1Color :
     l2 ? l2Color :
     m1 ? m1Color :
     m2 ? m2Color :
     m3 ? m3Color :
     m4 ? m4Color :
     m5 ? m5Color :
     m6 ? m6Color :
     na

bgcolor(showMacroBg ? macroColor : na, title="ICT Macro Highlight")

macroLabelY = high + atrValue * labelAtrOffset

if showLabels and showMacroLabels and l1Start
    label.new(bar_index, macroLabelY, "London Macro 1\n2:33 - 3:00 AM NY", style=label.style_label_down, textcolor=color.white, color=color.new(color.blue, 0), size=labelSize)

if showLabels and showMacroLabels and l2Start
    label.new(bar_index, macroLabelY, "London Macro 2\n4:03 - 4:30 AM NY", style=label.style_label_down, textcolor=color.white, color=color.new(color.teal, 0), size=labelSize)

if showLabels and showMacroLabels and m1Start
    label.new(bar_index, macroLabelY, "8:50 - 9:10 AM\nNY Open Liquidity", style=label.style_label_down, textcolor=color.white, color=color.new(color.aqua, 0), size=labelSize)

if showLabels and showMacroLabels and m2Start
    label.new(bar_index, macroLabelY, "9:50 - 10:10 AM\nContinuation / Reversal", style=label.style_label_down, textcolor=color.black, color=color.new(color.yellow, 0), size=labelSize)

if showLabels and showMacroLabels and m3Start
    label.new(bar_index, macroLabelY, "10:50 - 11:10 AM\nLiquidity / Displacement", style=label.style_label_down, textcolor=color.white, color=color.new(color.orange, 0), size=labelSize)

if showLabels and showMacroLabels and m4Start
    label.new(bar_index, macroLabelY, "11:50 - 12:10 PM\nLunch-Time Liquidity", style=label.style_label_down, textcolor=color.white, color=color.new(color.purple, 0), size=labelSize)

if showLabels and showMacroLabels and m5Start
    label.new(bar_index, macroLabelY, "1:10 - 1:40 PM\nPM Session Setup", style=label.style_label_down, textcolor=color.white, color=color.new(color.lime, 0), size=labelSize)

if showLabels and showMacroLabels and m6Start
    label.new(bar_index, macroLabelY, "3:15 - 3:45 PM\nLate-Day Move", style=label.style_label_down, textcolor=color.white, color=color.new(color.red, 0), size=labelSize)

//====================================================
// ASIAN SESSION HIGH / LOW
//====================================================
asiaActive = f_inSession(asiaOn, asiaSession)
asiaStart  = asiaActive and not nz(asiaActive[1], false)
asiaEnd    = not asiaActive and nz(asiaActive[1], false)

var float asiaHigh = na
var float asiaLow  = na
var int asiaStartBar = na
var box asiaBox = na
var line asiaHighLine = na
var line asiaLowLine = na
var label asiaNameLabel = na

if asiaStart
    asiaHigh := high
    asiaLow := low
    asiaStartBar := bar_index

    if showSessionBoxes
        asiaBox := box.new(bar_index, asiaHigh, bar_index, asiaLow, bgcolor=color.new(asiaColor, boxTransp), border_color=color.new(asiaColor, 35))

    if showSessionLines
        asiaHighLine := line.new(bar_index, asiaHigh, bar_index, asiaHigh, color=asiaColor, width=lineWidth)
        asiaLowLine  := line.new(bar_index, asiaLow, bar_index, asiaLow, color=asiaColor, width=lineWidth)

    if showLabels and showSessionLabels
        asiaNameLabel := label.new(bar_index, asiaHigh, "ASIA", style=label.style_label_down, textcolor=color.white, color=color.new(asiaColor, 0), size=labelSize)

if asiaActive
    asiaHigh := math.max(asiaHigh, high)
    asiaLow  := math.min(asiaLow, low)

    if showSessionBoxes and not na(asiaBox)
        box.set_top(asiaBox, asiaHigh)
        box.set_bottom(asiaBox, asiaLow)
        box.set_right(asiaBox, bar_index)

    if showSessionLines and not na(asiaHighLine)
        line.set_y1(asiaHighLine, asiaHigh)
        line.set_y2(asiaHighLine, asiaHigh)
        line.set_x2(asiaHighLine, bar_index)

    if showSessionLines and not na(asiaLowLine)
        line.set_y1(asiaLowLine, asiaLow)
        line.set_y2(asiaLowLine, asiaLow)
        line.set_x2(asiaLowLine, bar_index)

    if showLabels and showSessionLabels and not na(asiaNameLabel)
        label.set_x(asiaNameLabel, asiaStartBar)
        label.set_y(asiaNameLabel, asiaHigh)

if asiaEnd
    if showSessionLines and extendSessionHL
        line.set_extend(asiaHighLine, extend.right)
        line.set_extend(asiaLowLine, extend.right)

    if showLabels and showSessionLabels
        label.new(bar_index, asiaHigh, "Asia High", style=label.style_label_left, textcolor=color.white, color=color.new(asiaColor, 0), size=labelSize)
        label.new(bar_index, asiaLow, "Asia Low", style=label.style_label_left, textcolor=color.white, color=color.new(asiaColor, 0), size=labelSize)

//====================================================
// LONDON SESSION HIGH / LOW
//====================================================
londonActive = f_inSession(londonOn, londonSession)
londonStart  = londonActive and not nz(londonActive[1], false)
londonEnd    = not londonActive and nz(londonActive[1], false)

var float londonHigh = na
var float londonLow  = na
var int londonStartBar = na
var box londonBox = na
var line londonHighLine = na
var line londonLowLine = na
var label londonNameLabel = na

if londonStart
    londonHigh := high
    londonLow := low
    londonStartBar := bar_index

    if showSessionBoxes
        londonBox := box.new(bar_index, londonHigh, bar_index, londonLow, bgcolor=color.new(londonColor, boxTransp), border_color=color.new(londonColor, 35))

    if showSessionLines
        londonHighLine := line.new(bar_index, londonHigh, bar_index, londonHigh, color=londonColor, width=lineWidth)
        londonLowLine  := line.new(bar_index, londonLow, bar_index, londonLow, color=londonColor, width=lineWidth)

    if showLabels and showSessionLabels
        londonNameLabel := label.new(bar_index, londonHigh, "LONDON", style=label.style_label_down, textcolor=color.white, color=color.new(londonColor, 0), size=labelSize)

if londonActive
    londonHigh := math.max(londonHigh, high)
    londonLow  := math.min(londonLow, low)

    if showSessionBoxes and not na(londonBox)
        box.set_top(londonBox, londonHigh)
        box.set_bottom(londonBox, londonLow)
        box.set_right(londonBox, bar_index)

    if showSessionLines and not na(londonHighLine)
        line.set_y1(londonHighLine, londonHigh)
        line.set_y2(londonHighLine, londonHigh)
        line.set_x2(londonHighLine, bar_index)

    if showSessionLines and not na(londonLowLine)
        line.set_y1(londonLowLine, londonLow)
        line.set_y2(londonLowLine, londonLow)
        line.set_x2(londonLowLine, bar_index)

    if showLabels and showSessionLabels and not na(londonNameLabel)
        label.set_x(londonNameLabel, londonStartBar)
        label.set_y(londonNameLabel, londonHigh)

if londonEnd
    if showSessionLines and extendSessionHL
        line.set_extend(londonHighLine, extend.right)
        line.set_extend(londonLowLine, extend.right)

    if showLabels and showSessionLabels
        label.new(bar_index, londonHigh, "London High", style=label.style_label_left, textcolor=color.white, color=color.new(londonColor, 0), size=labelSize)
        label.new(bar_index, londonLow, "London Low", style=label.style_label_left, textcolor=color.white, color=color.new(londonColor, 0), size=labelSize)

//====================================================
// NEW YORK SESSION HIGH / LOW
//====================================================
nyActive = f_inSession(nyOn, nySession)
nyStart  = nyActive and not nz(nyActive[1], false)
nyEnd    = not nyActive and nz(nyActive[1], false)

var float nyHigh = na
var float nyLow  = na
var int nyStartBar = na
var box nyBox = na
var line nyHighLine = na
var line nyLowLine = na
var label nyNameLabel = na

if nyStart
    nyHigh := high
    nyLow := low
    nyStartBar := bar_index

    if showSessionBoxes
        nyBox := box.new(bar_index, nyHigh, bar_index, nyLow, bgcolor=color.new(nyColor, boxTransp), border_color=color.new(nyColor, 35))

    if showSessionLines
        nyHighLine := line.new(bar_index, nyHigh, bar_index, nyHigh, color=nyColor, width=lineWidth)
        nyLowLine  := line.new(bar_index, nyLow, bar_index, nyLow, color=nyColor, width=lineWidth)

    if showLabels and showSessionLabels
        nyNameLabel := label.new(bar_index, nyHigh, "NEW YORK", style=label.style_label_down, textcolor=color.white, color=color.new(nyColor, 0), size=labelSize)

if nyActive
    nyHigh := math.max(nyHigh, high)
    nyLow  := math.min(nyLow, low)

    if showSessionBoxes and not na(nyBox)
        box.set_top(nyBox, nyHigh)
        box.set_bottom(nyBox, nyLow)
        box.set_right(nyBox, bar_index)

    if showSessionLines and not na(nyHighLine)
        line.set_y1(nyHighLine, nyHigh)
        line.set_y2(nyHighLine, nyHigh)
        line.set_x2(nyHighLine, bar_index)

    if showSessionLines and not na(nyLowLine)
        line.set_y1(nyLowLine, nyLow)
        line.set_y2(nyLowLine, nyLow)
        line.set_x2(nyLowLine, bar_index)

    if showLabels and showSessionLabels and not na(nyNameLabel)
        label.set_x(nyNameLabel, nyStartBar)
        label.set_y(nyNameLabel, nyHigh)

if nyEnd
    if showSessionLines and extendSessionHL
        line.set_extend(nyHighLine, extend.right)
        line.set_extend(nyLowLine, extend.right)

    if showLabels and showSessionLabels
        label.new(bar_index, nyHigh, "NY High", style=label.style_label_left, textcolor=color.white, color=color.new(nyColor, 0), size=labelSize)
        label.new(bar_index, nyLow, "NY Low", style=label.style_label_left, textcolor=color.white, color=color.new(nyColor, 0), size=labelSize)

//====================================================
// ALERTS
//====================================================
londonMacroStart = l1Start or l2Start
nyMacroStart     = m1Start or m2Start or m3Start or m4Start or m5Start or m6Start

anyMacroStart  = londonMacroStart or nyMacroStart
anyMacroActive = l1 or l2 or m1 or m2 or m3 or m4 or m5 or m6

alertcondition(londonMacroStart, title="London Macro Started", message="London ICT macro time has started.")
alertcondition(nyMacroStart, title="NY Macro Started", message="New York ICT macro time has started.")
alertcondition(anyMacroStart, title="Any ICT Macro Started", message="An ICT macro time window has started.")
alertcondition(anyMacroActive, title="ICT Macro Active", message="ICT macro time is currently active.")

alertcondition(asiaStart, title="Asian Session Started", message="Asian session has started.")
alertcondition(londonStart, title="London Session Started", message="London session has started.")
alertcondition(nyStart, title="New York Session Started", message="New York session has started.")

alertcondition(asiaEnd, title="Asian Session Ended", message="Asian session ended. Asian high and low are marked.")
alertcondition(londonEnd, title="London Session Ended", message="London session ended. London high and low are marked.")
alertcondition(nyEnd, title="New York Session Ended", message="New York session ended. New York high and low are marked.")
````
