# ORB Prism 

- url: https://www.tradingview.com/script/Jaq8nQeX-ORB-Prism/
- type: indicator
- pine_id: PUB;3db518de1836486c814b9559f1d3df52
- version: 4.0

## Description

This indicator uses a Box instead of Lines than typical ORBs. ORB Prism is a streamlined Opening Range Breakout indicator that highlights the 9:30–9:45 AM range as a shaded zone and projects its key levels forward.

What makes ORB Prism different:
• The opening range is shown as a shaded zone, not just lines
• Levels project forward, staying relevant throughout the session
• Clean, distraction-free design focused on decision-making
• Built-in history to compare current structure with prior sessions

Designed for clarity, it replaces cluttered lines with a clean visual structure, helping traders quickly identify consolidation, breakout zones, and intraday support/resistance levels.

## Source Code

````pine
//@version=6
indicator("ORB Prism MTF (Multi-Session FINAL)", overlay=true, max_lines_count=500, max_boxes_count=200)

// =====================
// INPUTS
// =====================
extendBars  = input.int(75, "Projection Length", minval=10)

showNY      = input.bool(true, "Show New York ORB")
showLondon  = input.bool(true, "Show London ORB")
showAsia    = input.bool(true, "Show Asia ORB")

// Colors
nyColor     = input.color(color.new(color.blue, 85), "NY Box")
lonColor    = input.color(color.new(color.purple, 85), "London Box")
asiaColor   = input.color(color.new(color.orange, 85), "Asia Box")

hiColor     = input.color(color.lime, "High Line")
loColor     = input.color(color.red, "Low Line")
midColor    = input.color(color.gray, "Mid Line")

// =====================
// SESSION DETECTION (ROBUST)
// =====================
nyIn   = not na(time(timeframe.period, "0930-0945", "America/New_York"))
lonIn  = not na(time(timeframe.period, "0300-0315", "America/New_York"))
asiaIn = not na(time(timeframe.period, "2000-2015", "America/New_York"))

// =====================
// FUNCTION: HANDLE ORB
// =====================
f_handleORB(_in, _show, _color) =>
    var float hi = na
    var float lo = na
    var float mid = na
    var int startBar = na
    var box b = na
    var line hiLine = na
    var line loLine = na
    var line midLine = na

    // Start session
    if not _in[1] and _in and _show
        hi := high
        lo := low
        startBar := bar_index
        box.delete(b)

    // Build range
    if _in and _show
        hi := math.max(hi, high)
        lo := math.min(lo, low)
        mid := (hi + lo) / 2

        if na(b)
            b := box.new(startBar, hi, bar_index, lo,
                bgcolor=_color,
                border_color=color.new(color.white, 80))
        else
            box.set_right(b, bar_index)
            box.set_top(b, hi)
            box.set_bottom(b, lo)

    // End session → draw lines
    if _in[1] and not _in and _show
        hiLine := line.new(startBar, hi, bar_index + extendBars, hi, color=hiColor, width=2)
        loLine := line.new(startBar, lo, bar_index + extendBars, lo, color=loColor, width=2)
        midLine := line.new(startBar, mid, bar_index + extendBars, mid,
            color=midColor, style=line.style_dotted)

// =====================
// RUN SESSIONS
// =====================
f_handleORB(nyIn, showNY, nyColor)
f_handleORB(lonIn, showLondon, lonColor)
f_handleORB(asiaIn, showAsia, asiaColor)
````
