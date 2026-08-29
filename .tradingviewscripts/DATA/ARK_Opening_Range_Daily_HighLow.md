<!-- tradingview-pine-id: PUB;7b21f747e4cd46d68b09028b789a507f -->
<!-- tradingviewscripts-format: 1 -->
# ARK Opening Range + Daily High/Low

Source: https://www.tradingview.com/script/khDiJOY7-ARK-Opening-Range-Daily-High-Low/

## Description

ARK/DHL is a clean overlay indicator that tracks two key intraday levels:

1. Opening Range (ORB)

[*]    Monitors a user-defined session (default: 9:30–10:00 AM New York time).
[*]    Continuously updates and draws:
[*]        ORB High (green line)
[*]        ORB Low (red line)
[*]        ORB Midpoint (optional dotted gray line)
[*]    Lines can be extended to the right edge of the chart.
[*]    A light blue background highlights the ORB window while it is active.
[*]    When the ORB session ends, a small yellow downward triangle is plotted exactly at the ORB High to mark completion.
[*]    Price labels appear on the right for easy reading.

2. Daily High / Low (DHL)

[*]    Tracks the developing high and low of the entire trading day.
[*]    Draws:
[*]        Day High (fuchsia line)
[*]        Day Low (orange line)
[*]    These also extend to the right and show price labels.

All lines update live as new extremes form and automatically reset at the start of each new day. The indicator is designed for day traders who want a clear, non-cluttered view of the opening range and the day’s key extremes.

---

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════════════════
// ARK Opening Range + Daily High/Low (ARK/DHL)
// Tracks the Opening Range (default 09:30–10:00 NY) and the developing Daily High/Low.
// Clean, lightweight, and designed for day traders.
// ══════════════════════════════════════════════════════════════════════════════

indicator("ARK Opening Range + Daily High/Low", shorttitle="ARK/DHL", overlay=true, max_lines_count=500, max_labels_count=500)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
orbSession          = input.session("0930-1000", "ORB Session", group="ORB Settings")
showORB             = input.bool(true, "Show ORB Lines", group="ORB Settings")
showMid             = input.bool(true, "Show ORB Midpoint", group="ORB Settings")
midColor            = input.color(color.new(color.gray, 0), "Midpoint Color", group="ORB Settings")

showDaily           = input.bool(true, "Show Daily High/Low", group="Daily Settings")
dailyColorH         = input.color(color.new(color.fuchsia, 0), "Daily High Color", group="Daily Settings")
dailyColorL         = input.color(color.new(color.orange, 0), "Daily Low Color", group="Daily Settings")

showCompletionMark  = input.bool(true, "Show ORB Completion Mark", group="Display")
completionColor     = input.color(color.new(color.yellow, 0), "Completion Mark Color", group="Display")

extendLines         = input.bool(true, "Extend Lines to Right", group="Display")
showLabels          = input.bool(true, "Show Price Labels", group="Display")
lineWidth           = input.int(2, "Line Width", minval=1, maxval=5, group="Display")

// ─────────────────────────────────────────────────────────────────────────────
// SESSION & TIME LOGIC
// ─────────────────────────────────────────────────────────────────────────────
inORBSession = not na(time(timeframe.period, orbSession, "America/New_York"))
newDay       = timeframe.change("D")
orbJustEnded = not inORBSession and inORBSession[1]

// ─────────────────────────────────────────────────────────────────────────────
// VARIABLES
// ─────────────────────────────────────────────────────────────────────────────
var float orbHigh     = na
var float orbLow      = na
var float orbMid      = na
var int   orbStartBar = na

var line  orbHighLine = na
var line  orbLowLine  = na
var line  orbMidLine  = na
var label orbHighLbl  = na
var label orbLowLbl   = na
var label orbMidLbl   = na

var float dayHigh     = na
var float dayLow      = na
var int   dayStartBar = na

var line  dayHighLine = na
var line  dayLowLine  = na
var label dayHighLbl  = na
var label dayLowLbl   = na

// ─────────────────────────────────────────────────────────────────────────────
// NEW DAY RESET
// ─────────────────────────────────────────────────────────────────────────────
if newDay
    orbHigh     := na
    orbLow      := na
    orbMid      := na
    orbStartBar := na
    dayHigh     := na
    dayLow      := na
    dayStartBar := na

    if not na(orbHighLine)
        line.delete(orbHighLine)
        orbHighLine := na
    if not na(orbLowLine)
        line.delete(orbLowLine)
        orbLowLine := na
    if not na(orbMidLine)
        line.delete(orbMidLine)
        orbMidLine := na
    if not na(dayHighLine)
        line.delete(dayHighLine)
        dayHighLine := na
    if not na(dayLowLine)
        line.delete(dayLowLine)
        dayLowLine := na

    if not na(orbHighLbl)
        label.delete(orbHighLbl)
        orbHighLbl := na
    if not na(orbLowLbl)
        label.delete(orbLowLbl)
        orbLowLbl := na
    if not na(orbMidLbl)
        label.delete(orbMidLbl)
        orbMidLbl := na
    if not na(dayHighLbl)
        label.delete(dayHighLbl)
        dayHighLbl := na
    if not na(dayLowLbl)
        label.delete(dayLowLbl)
        dayLowLbl := na

// ─────────────────────────────────────────────────────────────────────────────
// BUILD ORB LEVELS
// ─────────────────────────────────────────────────────────────────────────────
if inORBSession
    if na(orbHigh)
        orbHigh     := high
        orbLow      := low
        orbMid      := (high + low) / 2
        orbStartBar := bar_index
    else
        orbHigh := math.max(orbHigh, high)
        orbLow  := math.min(orbLow, low)
        orbMid  := (orbHigh + orbLow) / 2

// ─────────────────────────────────────────────────────────────────────────────
// BUILD DAILY HIGH / LOW
// ─────────────────────────────────────────────────────────────────────────────
if na(dayHigh)
    dayHigh     := high
    dayLow      := low
    dayStartBar := bar_index
else
    dayHigh := math.max(dayHigh, high)
    dayLow  := math.min(dayLow, low)

// ─────────────────────────────────────────────────────────────────────────────
// DRAW ORB LINES
// ─────────────────────────────────────────────────────────────────────────────
extendStyle = extendLines ? extend.right : extend.none

if showORB and not na(orbHigh)
    if na(orbHighLine)
        orbHighLine := line.new(orbStartBar, orbHigh, bar_index, orbHigh, xloc.bar_index, extend=extendStyle, color=color.new(color.green, 0), width=lineWidth)
        orbLowLine  := line.new(orbStartBar, orbLow,  bar_index, orbLow,  xloc.bar_index, extend=extendStyle, color=color.new(color.red, 0),   width=lineWidth)
        if showMid
            orbMidLine := line.new(orbStartBar, orbMid, bar_index, orbMid, xloc.bar_index, extend=extendStyle, color=midColor, width=1, style=line.style_dotted)
    else
        line.set_xy2(orbHighLine, bar_index, orbHigh)
        line.set_y1(orbHighLine, orbHigh)
        line.set_y2(orbHighLine, orbHigh)

        line.set_xy2(orbLowLine, bar_index, orbLow)
        line.set_y1(orbLowLine, orbLow)
        line.set_y2(orbLowLine, orbLow)

        if showMid and not na(orbMidLine)
            line.set_xy2(orbMidLine, bar_index, orbMid)
            line.set_y1(orbMidLine, orbMid)
            line.set_y2(orbMidLine, orbMid)

// ─────────────────────────────────────────────────────────────────────────────
// ORB COMPLETION MARK
// ─────────────────────────────────────────────────────────────────────────────
plotshape(showCompletionMark and orbJustEnded ? orbHigh : na,
          title="ORB Completion",
          style=shape.triangledown,
          location=location.absolute,
          color=completionColor,
          size=size.tiny)

// ─────────────────────────────────────────────────────────────────────────────
// DRAW DAILY LINES
// ─────────────────────────────────────────────────────────────────────────────
if showDaily and not na(dayHigh)
    if na(dayHighLine)
        dayHighLine := line.new(dayStartBar, dayHigh, bar_index, dayHigh, xloc.bar_index, extend=extendStyle, color=dailyColorH, width=lineWidth)
        dayLowLine  := line.new(dayStartBar, dayLow,  bar_index, dayLow,  xloc.bar_index, extend=extendStyle, color=dailyColorL, width=lineWidth)
    else
        line.set_xy2(dayHighLine, bar_index, dayHigh)
        line.set_y1(dayHighLine, dayHigh)
        line.set_y2(dayHighLine, dayHigh)

        line.set_xy2(dayLowLine, bar_index, dayLow)
        line.set_y1(dayLowLine, dayLow)
        line.set_y2(dayLowLine, dayLow)

// ─────────────────────────────────────────────────────────────────────────────
// LABELS (only on last bar)
// ─────────────────────────────────────────────────────────────────────────────
if showLabels and barstate.islast
    if showORB and not na(orbHigh)
        if na(orbHighLbl)
            orbHighLbl := label.new(bar_index + 2, orbHigh, "ORB H\n" + str.tostring(orbHigh, "#.####"), xloc.bar_index, yloc.price, color=color.new(color.green, 0), textcolor=color.white, style=label.style_label_left, size=size.small)
            orbLowLbl  := label.new(bar_index + 2, orbLow,  "ORB L\n" + str.tostring(orbLow,  "#.####"), xloc.bar_index, yloc.price, color=color.new(color.red, 0),   textcolor=color.white, style=label.style_label_left, size=size.small)
            if showMid and not na(orbMid)
                orbMidLbl := label.new(bar_index + 2, orbMid, "Mid\n" + str.tostring(orbMid, "#.####"), xloc.bar_index, yloc.price, color=midColor, textcolor=color.white, style=label.style_label_left, size=size.small)
        else
            label.set_xy(orbHighLbl, bar_index + 2, orbHigh)
            label.set_xy(orbLowLbl,  bar_index + 2, orbLow)
            if showMid and not na(orbMidLbl)
                label.set_xy(orbMidLbl, bar_index + 2, orbMid)

    if showDaily and not na(dayHigh)
        if na(dayHighLbl)
            dayHighLbl := label.new(bar_index + 2, dayHigh, "Day H\n" + str.tostring(dayHigh, "#.####"), xloc.bar_index, yloc.price, color=dailyColorH, textcolor=color.white, style=label.style_label_left, size=size.small)
            dayLowLbl  := label.new(bar_index + 2, dayLow,  "Day L\n" + str.tostring(dayLow,  "#.####"), xloc.bar_index, yloc.price, color=dailyColorL, textcolor=color.white, style=label.style_label_left, size=size.small)
        else
            label.set_xy(dayHighLbl, bar_index + 2, dayHigh)
            label.set_xy(dayLowLbl,  bar_index + 2, dayLow)

// ─────────────────────────────────────────────────────────────────────────────
// BACKGROUND HIGHLIGHT DURING ORB
// ─────────────────────────────────────────────────────────────────────────────
bgcolor(inORBSession ? color.new(color.blue, 92) : na, title="ORB Window")
````
