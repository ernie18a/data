# SREN - Price Breakout

- url: https://www.tradingview.com/script/Vp4rfiYs-SREN-Price-Breakout/
- type: indicator
- pine_id: PUB;b7bd9a7796af487bbdaa014da09d8695
- version: 1.0

## Description

Price Breakout

Price Breakout marks the moment price breaks above its most recent swing high.

How it works

It finds swing highs with a pivot rule: a high counts once a set number of bars on each side are lower than it.
While price is below the most recent swing high, the indicator draws a faint dotted line at that level.
When price breaks above it, the dotted line becomes a solid line from the swing high to the breakout candle, and a small triangle appears under that candle.
When a new swing high forms before a breakout, the old level is removed so the chart stays clean.

Settings

Bars left / right of high: how strict the swing high is. Higher values give fewer, more important levels. Lower values react to smaller swings.
Require a close above the high: on by default, so only a candle close above the level counts. Turn it off to count a wick through the level, which gives earlier but noisier signals.
Style: line colour and width, the waiting-level colour, and on/off switches for the dotted level and the breakout marker.

Alerts
Includes a "Breakout above last high" alert. For confirmed signals, set it to "Once per bar close".

Notes

A swing high appears only after the bars to its right have formed, so the waiting level is drawn with that delay.
Breakout lines on closed candles don't repaint.
This is a visual aid for spotting breakouts, not a trading recommendation. Use it alongside your own analysis and risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © sren20


//@version=6
indicator("Price Breakout", overlay = true, max_lines_count = 300)

// ── Inputs ─────────────────────────────────────────────
leftBars   = input.int(20, "Bars left of high",  minval = 1, group = "Swing high")
rightBars  = input.int(5, "Bars right of high", minval = 1, group = "Swing high",
     tooltip = "A high is confirmed once this many bars close below it")
useClose   = input.bool(true, "Require a close above the high", group = "Breakout",
     tooltip = "Off = a wick through the high counts as a breakout")

showLevel  = input.bool(true, "Show waiting level (dotted)", group = "Style")
showMarker = input.bool(true, "Show breakout marker",        group = "Style")
breakColor = input.color(#26a69a, "Breakout line", group = "Style")
pendColor  = input.color(color.new(color.gray, 50), "Waiting level", group = "Style")
lineWidth  = input.int(1, "Line width", minval = 1, maxval = 4, group = "Style")

// ── State ──────────────────────────────────────────────
var float lastHigh    = na
var int   lastHighBar = na
var line  pending     = na
var bool  broken      = true

// ── New swing high ─────────────────────────────────────
ph = ta.pivothigh(high, leftBars, rightBars)

if not na(ph)
    line.delete(pending)                       // drop the old, unbroken level
    lastHigh    := ph
    lastHighBar := bar_index - rightBars
    broken      := false
    pending     := showLevel ? line.new(lastHighBar, lastHigh, bar_index, lastHigh,
         color = pendColor, style = line.style_dotted, width = 1) : na

// Keep the waiting level stretched to the current bar
if not broken and not na(pending)
    line.set_x2(pending, bar_index)

// ── Breakout ───────────────────────────────────────────
src      = useClose ? close : high
breakout = not broken and not na(lastHigh) and src > lastHigh

if breakout
    broken := true
    line.delete(pending)
    pending := na
    line.new(lastHighBar, lastHigh, bar_index, lastHigh,
         color = breakColor, style = line.style_solid, width = lineWidth)

plotshape(showMarker and breakout, "Breakout", shape.triangleup, location.belowbar,
     color.new(breakColor, 20), size = size.tiny)

alertcondition(breakout, "Breakout above last high", "{{ticker}} broke above the last swing high")

plot(close)
````
