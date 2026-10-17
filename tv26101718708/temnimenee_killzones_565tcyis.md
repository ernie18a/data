# Temnimenee Killzones

- url: https://www.tradingview.com/script/565tcYiS-temnimenee-killzones/
- type: indicator
- pine_id: PUB;999742e56f3647eeb8f9fb2fa48b4606
- version: 1.0

## Description

Temnimenee Killzones is a lightweight session visualization tool designed for ICT and Smart Money Concepts traders.

Unlike standard session indicators, all killzones are anchored to a fixed UTC-4 timezone, ensuring that session timings remain identical regardless of your chart's timezone or your local TradingView settings.

Features

• Fixed UTC-4 session timing (no dependency on chart timezone)

• Three built-in Killzones:

Asia: 20:00 – 00:00 UTC-4
London: 02:00 – 05:00 UTC-4
New York: 07:00 – 11:00 UTC-4

• Automatic session range boxes

• Optional session borders

Custom color
Width
Style (Solid / Dashed / Dotted)

• Independent colors for each session

• Historical session display

• 50% equilibrium (midpoint) lines for every Killzone

The midpoint is calculated as:

(Session High + Session Low) / 2

Each midpoint line extends until the end of the next major Killzone:

Asia → end of London
London → end of New York
New York → end of the next Asia

Each midpoint line can be enabled or disabled independently and has its own customizable style and color.

Designed for

This indicator is especially useful for traders using:

ICT (Inner Circle Trader)
Smart Money Concepts (SMC)
Liquidity-based trading
Silver Bullet models
Judas Swing
Killzone trading
Session range analysis
Philosophy

The purpose of this indicator is to provide a clean, distraction-free visualization of the three most important trading Killzones while maintaining consistent timing across all markets and chart timezones.

No unnecessary calculations.
No repainting.
Just precise session structure.

More ICT tools and advanced Smart Money indicators are currently in development.

## Source Code

````pine
//@version=6
indicator("Temnimenee Killzones", overlay=true, max_boxes_count=500, max_lines_count=500)

// ───── Fixed timezone: always UTC-4
string TZ = "GMT-4"

// ───── Killzones
showAsia   = input.bool(true, "Show Asia", group="Killzones")
showLondon = input.bool(true, "Show London", group="Killzones")
showNY     = input.bool(true, "Show New York", group="Killzones")

// ───── Box colors
asiaFill   = input.color(color.new(color.purple, 90), "Asia Fill", group="Boxes")
londonFill = input.color(color.new(color.blue, 90), "London Fill", group="Boxes")
nyFill     = input.color(color.new(color.green, 90), "New York Fill", group="Boxes")

// ───── Borders
showBorders = input.bool(false, "Show Borders", group="Borders")
borderWidth = input.int(1, "Border Width", minval=1, maxval=5, group="Borders")
borderStyleInput = input.string("Solid", "Border Style", options=["Solid", "Dashed", "Dotted"], group="Borders")

asiaBorder   = input.color(color.purple, "Asia Border", group="Borders")
londonBorder = input.color(color.blue, "London Border", group="Borders")
nyBorder     = input.color(color.green, "New York Border", group="Borders")

// ───── 50% lines
showAsiaMid   = input.bool(true, "Show Asia 50%", group="50% Lines")
showLondonMid = input.bool(true, "Show London 50%", group="50% Lines")
showNYMid     = input.bool(true, "Show New York 50%", group="50% Lines")

asiaMidColor   = input.color(color.purple, "Asia 50% Color", group="50% Lines")
londonMidColor = input.color(color.blue, "London 50% Color", group="50% Lines")
nyMidColor     = input.color(color.green, "New York 50% Color", group="50% Lines")

midWidth = input.int(1, "50% Line Width", minval=1, maxval=5, group="50% Lines")
midStyleInput = input.string("Solid", "50% Line Style", options=["Solid", "Dashed", "Dotted"], group="50% Lines")

// ───── History
showHistory = input.bool(true, "Show History", group="History")

// ───── Helpers
f_lineStyle(_style) =>
    _style == "Dashed" ? line.style_dashed : _style == "Dotted" ? line.style_dotted : line.style_solid

f_borderColor(_color) =>
    showBorders ? _color : color.new(_color, 100)

// ───── Fixed sessions in UTC-4
inAsia   = showAsia and not na(time(timeframe.period, "2000-0000", TZ))
inLondon = showLondon and not na(time(timeframe.period, "0200-0500", TZ))
inNY     = showNY and not na(time(timeframe.period, "0700-1100", TZ))

newAsia   = inAsia and (bar_index == 0 or not inAsia[1])
newLondon = inLondon and (bar_index == 0 or not inLondon[1])
newNY     = inNY and (bar_index == 0 or not inNY[1])

// Milliseconds
int HOUR_MS = 60 * 60 * 1000

// Asia 20:00 → end of London at 05:00 = 9 hours
int ASIA_LINE_DURATION = 9 * HOUR_MS

// London 02:00 → end of New York at 11:00 = 9 hours
int LONDON_LINE_DURATION = 9 * HOUR_MS

// New York 07:00 → end of next Asia at 00:00 = 17 hours
int NY_LINE_DURATION = 17 * HOUR_MS

// ============================================================================
// ASIA
// ============================================================================

var box asiaBox = na
var line asiaMidLine = na
var float asiaHigh = na
var float asiaLow = na
var int asiaStartTime = na
var int asiaLineEndTime = na

if newAsia
    asiaHigh := high
    asiaLow := low
    asiaStartTime := time
    asiaLineEndTime := asiaStartTime + ASIA_LINE_DURATION

    if not showHistory
        if not na(asiaBox)
            box.delete(asiaBox)
        if not na(asiaMidLine)
            line.delete(asiaMidLine)

    asiaBox := box.new(time, asiaHigh, time_close, asiaLow, xloc=xloc.bar_time, bgcolor=asiaFill, border_color=f_borderColor(asiaBorder), border_width=borderWidth, border_style=f_lineStyle(borderStyleInput))

    if showAsiaMid
        float asiaMid = (asiaHigh + asiaLow) / 2.0
        asiaMidLine := line.new(asiaStartTime, asiaMid, asiaLineEndTime, asiaMid, xloc=xloc.bar_time, color=asiaMidColor, width=midWidth, style=f_lineStyle(midStyleInput))

if inAsia
    asiaHigh := math.max(asiaHigh, high)
    asiaLow := math.min(asiaLow, low)

    if not na(asiaBox)
        box.set_right(asiaBox, time_close)
        box.set_top(asiaBox, asiaHigh)
        box.set_bottom(asiaBox, asiaLow)
        box.set_bgcolor(asiaBox, asiaFill)
        box.set_border_color(asiaBox, f_borderColor(asiaBorder))
        box.set_border_width(asiaBox, borderWidth)
        box.set_border_style(asiaBox, f_lineStyle(borderStyleInput))

    if showAsiaMid and not na(asiaMidLine)
        float asiaMid = (asiaHigh + asiaLow) / 2.0
        line.set_xy1(asiaMidLine, asiaStartTime, asiaMid)
        line.set_xy2(asiaMidLine, asiaLineEndTime, asiaMid)
        line.set_color(asiaMidLine, asiaMidColor)
        line.set_width(asiaMidLine, midWidth)
        line.set_style(asiaMidLine, f_lineStyle(midStyleInput))

// ============================================================================
// LONDON
// ============================================================================

var box londonBox = na
var line londonMidLine = na
var float londonHigh = na
var float londonLow = na
var int londonStartTime = na
var int londonLineEndTime = na

if newLondon
    londonHigh := high
    londonLow := low
    londonStartTime := time
    londonLineEndTime := londonStartTime + LONDON_LINE_DURATION

    if not showHistory
        if not na(londonBox)
            box.delete(londonBox)
        if not na(londonMidLine)
            line.delete(londonMidLine)

    londonBox := box.new(time, londonHigh, time_close, londonLow, xloc=xloc.bar_time, bgcolor=londonFill, border_color=f_borderColor(londonBorder), border_width=borderWidth, border_style=f_lineStyle(borderStyleInput))

    if showLondonMid
        float londonMid = (londonHigh + londonLow) / 2.0
        londonMidLine := line.new(londonStartTime, londonMid, londonLineEndTime, londonMid, xloc=xloc.bar_time, color=londonMidColor, width=midWidth, style=f_lineStyle(midStyleInput))

if inLondon
    londonHigh := math.max(londonHigh, high)
    londonLow := math.min(londonLow, low)

    if not na(londonBox)
        box.set_right(londonBox, time_close)
        box.set_top(londonBox, londonHigh)
        box.set_bottom(londonBox, londonLow)
        box.set_bgcolor(londonBox, londonFill)
        box.set_border_color(londonBox, f_borderColor(londonBorder))
        box.set_border_width(londonBox, borderWidth)
        box.set_border_style(londonBox, f_lineStyle(borderStyleInput))

    if showLondonMid and not na(londonMidLine)
        float londonMid = (londonHigh + londonLow) / 2.0
        line.set_xy1(londonMidLine, londonStartTime, londonMid)
        line.set_xy2(londonMidLine, londonLineEndTime, londonMid)
        line.set_color(londonMidLine, londonMidColor)
        line.set_width(londonMidLine, midWidth)
        line.set_style(londonMidLine, f_lineStyle(midStyleInput))

// ============================================================================
// NEW YORK
// ============================================================================

var box nyBox = na
var line nyMidLine = na
var float nyHigh = na
var float nyLow = na
var int nyStartTime = na
var int nyLineEndTime = na

if newNY
    nyHigh := high
    nyLow := low
    nyStartTime := time
    nyLineEndTime := nyStartTime + NY_LINE_DURATION

    if not showHistory
        if not na(nyBox)
            box.delete(nyBox)
        if not na(nyMidLine)
            line.delete(nyMidLine)

    nyBox := box.new(time, nyHigh, time_close, nyLow, xloc=xloc.bar_time, bgcolor=nyFill, border_color=f_borderColor(nyBorder), border_width=borderWidth, border_style=f_lineStyle(borderStyleInput))

    if showNYMid
        float nyMid = (nyHigh + nyLow) / 2.0
        nyMidLine := line.new(nyStartTime, nyMid, nyLineEndTime, nyMid, xloc=xloc.bar_time, color=nyMidColor, width=midWidth, style=f_lineStyle(midStyleInput))

if inNY
    nyHigh := math.max(nyHigh, high)
    nyLow := math.min(nyLow, low)

    if not na(nyBox)
        box.set_right(nyBox, time_close)
        box.set_top(nyBox, nyHigh)
        box.set_bottom(nyBox, nyLow)
        box.set_bgcolor(nyBox, nyFill)
        box.set_border_color(nyBox, f_borderColor(nyBorder))
        box.set_border_width(nyBox, borderWidth)
        box.set_border_style(nyBox, f_lineStyle(borderStyleInput))

    if showNYMid and not na(nyMidLine)
        float nyMid = (nyHigh + nyLow) / 2.0
        line.set_xy1(nyMidLine, nyStartTime, nyMid)
        line.set_xy2(nyMidLine, nyLineEndTime, nyMid)
        line.set_color(nyMidLine, nyMidColor)
        line.set_width(nyMidLine, midWidth)
        line.set_style(nyMidLine, f_lineStyle(midStyleInput))
````
