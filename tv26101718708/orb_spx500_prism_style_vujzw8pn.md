# ORB [SPX500] (Prism Style)

- url: https://www.tradingview.com/script/vujZW8Pn-ORB-SPX500-Prism-Style/
- type: indicator
- pine_id: PUB;d8d96e6a77fa494d86b5be571085e4d6
- version: 2.0

## Description

ORB Prism is a visually refined Opening Range Breakout indicator designed to turn early-session price action into a clear, structured trading framework.

The indicator captures the 08:00–08:30 New York session range and presents it as a shaded price zone, highlighting consolidation and defining key intraday structure. Instead of traditional static lines, the range is visualized as a dynamic zone with projected high and low “rails” and a central equilibrium spine.

Key Features:
• Structured ORB zone for instant visual clarity
• High/Low levels extended as directional rails
• Midline (equilibrium) for balance interpretation
• Clean, minimalist design focused on price structure
• Forward projection of key levels for intraday context

ORB Prism is built for traders who focus on session-based volatility, breakout timing, and clean price structure without unnecessary chart clutter.

## Source Code

````pine
//@version=6
indicator("ORB 08:00–08:15 [SPX500] • Prism Style", overlay=true, max_lines_count=500, max_boxes_count=50)

// =====================
// INPUTS
// =====================
highColor      = input.color(color.lime, "High Rail")
lowColor       = input.color(color.red, "Low Rail")
midColor       = input.color(color.gray, "Mid Spine")

boxColor       = input.color(color.new(color.blue, 88), "ORB Zone Fill")
borderColor    = input.color(color.new(color.white, 85), "Zone Border")

linewidth      = input.int(2, "Line Width", minval=1, maxval=4)
extendBars     = input.int(80, "Projection Length")

showLabels     = input.bool(true, "Show Info Label")

// =====================
// SESSION
// =====================
startTime = timestamp("America/New_York", year, month, dayofmonth, 8, 0)
endTime   = timestamp("America/New_York", year, month, dayofmonth, 8, 15)

inSession = time >= startTime and time < endTime

// =====================
// STATE
// =====================
var float hi = na
var float lo = na
var float mid = na
var int startBar = na

var box orbZone = na
var line hiRail = na
var line loRail = na
var line midSpine = na
var label infoTag = na

// =====================
// RESET
// =====================
if not inSession[1] and inSession
    hi := high
    lo := low
    startBar := bar_index

    box.delete(orbZone)
    line.delete(hiRail)
    line.delete(loRail)
    line.delete(midSpine)

// =====================
// BUILD ORB
// =====================
if inSession
    hi := math.max(hi, high)
    lo := math.min(lo, low)
    mid := (hi + lo) / 2

    // ORB ZONE (visual identity upgrade)
    if na(orbZone)
        orbZone := box.new(
            startBar, hi,
            bar_index, lo,
            bgcolor=boxColor,
            border_color=borderColor
        )
    else
        box.set_right(orbZone, bar_index)
        box.set_top(orbZone, hi)
        box.set_bottom(orbZone, lo)

// =====================
// FINALIZE + EXTEND
// =====================
if inSession[1] and not inSession
    hiRail := line.new(startBar, hi, bar_index + extendBars, hi,
        color=highColor, width=linewidth)

    loRail := line.new(startBar, lo, bar_index + extendBars, lo,
        color=lowColor, width=linewidth)

    midSpine := line.new(startBar, mid, bar_index + extendBars, mid,
        color=midColor, width=1, style=line.style_dotted)

// extend live feel
if not inSession and not na(hiRail)
    line.set_x2(hiRail, bar_index + extendBars)
    line.set_x2(loRail, bar_index + extendBars)
    line.set_x2(midSpine, bar_index + extendBars)

// =====================
// CLEAN INFO TAG
// =====================
if showLabels and barstate.islast and not na(hi)
    label.delete(infoTag)

    txt =
         "ORB PRISM\n" +
         "────────────\n" +
         "High: " + str.tostring(hi, format.mintick) + "\n" +
         "Low : " + str.tostring(lo, format.mintick) + "\n" +
         "Mid : " + str.tostring(mid, format.mintick)

    infoTag := label.new(
        bar_index + 5,
        hi,
        txt,
        style=label.style_label_left,
        textcolor=color.white,
        color=color.new(color.black, 65),
        size=size.small
    )
````
