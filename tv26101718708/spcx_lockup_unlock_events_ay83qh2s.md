# SPCX Lockup & Unlock Events

- url: https://www.tradingview.com/script/AY83Qh2S-SPCX-Lockup-Unlock-Events/
- type: indicator
- pine_id: PUB;40ccb5f5bc03498bb373f4f943c234a9
- version: 4.0

## Description

The calendar of SPCX Lockup and Unlock events. They may be indicators of price action. 

No warrant is implied.

## Source Code

````pine
//@version=6
indicator("SPCX Event Indicator - Lockup & Unlocks", overlay=true, max_lines_count=500, max_labels_count=500)

// ================== INPUTS ==================
showVerticalLines = input.bool(true, "Show Vertical Lines", group="Vertical Lines")
showLineLabels    = input.bool(true, "Show Line Labels", group="Vertical Lines")
lineStyleInput    = input.string("Dashed", "Line Style", options=["Solid", "Dashed", "Dotted", "Arrow Left", "Arrow Right", "Arrow Both"], group="Vertical Lines")
labelSizeInput    = input.string("small", "Label Size", options=["tiny", "small", "normal", "large"], group="Vertical Lines")

showTable         = input.bool(true, "Show Event Table", group="Table Settings")
tablePosition     = input.string("Top Right", "Table Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left", "Middle Right", "Middle Left"], group="Table Settings")
tableTransparency = input.int(70, "Table Background Transparency", minval=0, maxval=100, group="Table Settings")
headerBgColor     = input.color(color.new(color.gray, 40), "Header Background Color", group="Table Settings")
textSizeInput     = input.string("small", "Text Size", options=["tiny", "small", "normal", "large"], group="Table Settings")
borderWidth       = input.int(1, "Border Width", minval=0, maxval=5, group="Table Settings")
borderColor       = input.color(color.gray, "Border Color", group="Table Settings")

type Event
    int    y
    int    m
    int    d
    string dateLabel
    string eventLabel
    string details
    color  eventColor

var Event[] events = array.from(
     Event.new(2026, 7, 20, "Jul 20",      "Perf Trigger",     "+10% early unlock if >=+30%", color.purple),
     Event.new(2026, 8, 5,  "Aug 5",       "Q2 Earnings",      "20% of eligible shares unlock", color.red),
     Event.new(2026, 8, 21, "Aug 21",      "Day 70",           "7% Staggered release", color.orange),
     Event.new(2026, 9, 10, "Sep 10",      "Day 90",           "7% Staggered release", color.orange),
     Event.new(2026, 9, 25, "Sep 25",      "Day 105",          "7% Staggered release", color.orange),
     Event.new(2026, 10, 10, "Oct 10",     "Day 120",          "7% Staggered release", color.orange),
     Event.new(2026, 10, 25, "Oct 25",     "Day 135",          "7% Staggered release", color.orange),
     Event.new(2026, 11, 4, "Nov 4",       "Q3 Earnings",      "+28% of eligible shares unlock", color.red),
     Event.new(2026, 12, 9, "Dec 9",       "180-Day Expiry",   "Final insider release", color.red),
     Event.new(2027, 6, 13, "Jun 13 '27",  "Musk Lockup",      "Musk's shares (~42%) unlock", color.blue))

getLineStyle() =>
    switch lineStyleInput
        "Solid"       => line.style_solid
        "Dashed"      => line.style_dashed
        "Dotted"      => line.style_dotted
        "Arrow Left"  => line.style_arrow_left
        "Arrow Right" => line.style_arrow_right
        "Arrow Both"  => line.style_arrow_both
        => line.style_dashed

getTablePosition() =>
    switch tablePosition
        "Top Right"    => position.top_right
        "Bottom Right" => position.bottom_right
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        "Middle Left"  => position.middle_left
        => position.top_right

lineStyle  = getLineStyle()
tablePos   = getTablePosition()
eventCount = array.size(events)

// ================== VERTICAL LINES & LABELS ==================
var line[]  eventLines  = array.new_line()
var label[] eventLabels = array.new_label()

clearEventDrawings() =>
    while array.size(eventLines) > 0
        line.delete(array.pop(eventLines))
    while array.size(eventLabels) > 0
        label.delete(array.pop(eventLabels))

if barstate.isfirst
    clearEventDrawings()

if showVerticalLines and barstate.islastconfirmedhistory
    needsRebuild = array.size(eventLines) != eventCount or (showLineLabels and array.size(eventLabels) != eventCount) or (not showLineLabels and array.size(eventLabels) > 0)

    if needsRebuild
        clearEventDrawings()
        for i = 0 to eventCount - 1
            e = array.get(events, i)
            t = timestamp(e.y, e.m, e.d)
            array.push(eventLines, line.new(t, low, t, high, color=e.eventColor, width=2, style=lineStyle, xloc=xloc.bar_time, extend=extend.both))
            if showLineLabels
                labelText = e.dateLabel + "\n" + e.eventLabel
                array.push(eventLabels, label.new(t, high, labelText, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_down, color=color.new(e.eventColor, 15), textcolor=color.white, size=labelSizeInput))
    else
        for i = 0 to eventCount - 1
            line.set_style(array.get(eventLines, i), lineStyle)
else if not showVerticalLines and (array.size(eventLines) > 0 or array.size(eventLabels) > 0)
    clearEventDrawings()

// ================== EVENT TABLE ==================
if showTable and barstate.islastconfirmedhistory
    var table t = table.new(tablePos, 3, eventCount + 1,
         bgcolor=color.new(color.black, tableTransparency),
         border_width=borderWidth,
         border_color=borderColor)

    table.cell(t, 0, 0, "Date",    text_color=color.white, bgcolor=headerBgColor, text_size=textSizeInput)
    table.cell(t, 1, 0, "Event",   text_color=color.white, bgcolor=headerBgColor, text_size=textSizeInput)
    table.cell(t, 2, 0, "Details", text_color=color.white, bgcolor=headerBgColor, text_size=textSizeInput)

    for i = 0 to eventCount - 1
        e = array.get(events, i)
        row = i + 1
        table.cell(t, 0, row, e.dateLabel,  text_color=e.eventColor, text_size=textSizeInput)
        table.cell(t, 1, row, e.eventLabel, text_color=e.eventColor, text_size=textSizeInput)
        table.cell(t, 2, row, e.details,    text_color=color.white,  text_size=textSizeInput)
````
