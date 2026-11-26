# Previous Day High / Low / Mid

- url: https://www.tradingview.com/script/eALwGXKa-Previous-Day-High-Low-Mid/
- type: indicator
- pine_id: PUB;43ebcca8b26e471da2ccbf6c8a48e2f0
- version: 1.0

## Description

**Simple Setup:**

- Focus on the previous day's high, low, and midpoint.
- For example, on a 15-minute time frame: 
  - If the price is at the previous day's low, then buy.
  - If the price is at the previous day's high, then sell.
- In both scenarios, use the midpoint as your first take profit target.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © custom indicator

//@version=5
indicator(title="Previous Day High / Low / Mid", shorttitle="PDH/PDL/PDM", overlay=true)

// ─────────────────────────────────────────────
//  USER INPUTS
// ─────────────────────────────────────────────
showHigh   = input.bool(true,  "Show Previous Day High",   group="Visibility")
showLow    = input.bool(true,  "Show Previous Day Low",    group="Visibility")
showMid    = input.bool(true,  "Show Previous Day Mid",    group="Visibility")
showLabels = input.bool(true,  "Show Labels",              group="Visibility")
extendLine = input.string("Right", "Extend Lines",
     options=["Right", "Left", "Both", "None"],           group="Visibility")

highColor  = input.color(color.new(color.red,    0),  "High Line Color",  group="Colors")
lowColor   = input.color(color.new(color.green,  0),  "Low Line Color",   group="Colors")
midColor   = input.color(color.new(color.orange, 0),  "Mid Line Color",   group="Colors")

lineWidth  = input.int(1, "Line Width", minval=1, maxval=4, group="Style")
lineStyle  = input.string("Dashed", "Line Style",
     options=["Solid", "Dashed", "Dotted"],               group="Style")

// ─────────────────────────────────────────────
//  FETCH PREVIOUS DAY OHLC FROM DAILY TF
// ─────────────────────────────────────────────
// request.security with barmerge.lookahead_on and [1] gives the CLOSED
// previous daily candle on any lower timeframe — values never repaint.
[prevDayHigh, prevDayLow] = request.security(
     syminfo.tickerid, "D",
     [high[1], low[1]],
     lookahead = barmerge.lookahead_on)

prevDayMid = (prevDayHigh + prevDayLow) / 2

// ─────────────────────────────────────────────
//  HELPER: MAP INPUTS TO PINE CONSTANTS
// ─────────────────────────────────────────────
getStyle() =>
    lineStyle == "Solid"  ? line.style_solid  :
     lineStyle == "Dotted" ? line.style_dotted :
     line.style_dashed

getExtend() =>
    extendLine == "Right" ? extend.right :
     extendLine == "Left"  ? extend.left  :
     extendLine == "Both"  ? extend.both  :
     extend.none

// ─────────────────────────────────────────────
//  DRAW LINES  (create once on bar_index == 0,
//  then update coordinates every bar so they
//  always sit at the correct price level)
// ─────────────────────────────────────────────
var line highLine = na
var line lowLine  = na
var line midLine  = na

if barstate.isfirst
    highLine := line.new(bar_index, prevDayHigh, bar_index + 1, prevDayHigh,
         color=highColor, width=lineWidth, style=getStyle(), extend=getExtend())
    lowLine  := line.new(bar_index, prevDayLow,  bar_index + 1, prevDayLow,
         color=lowColor,  width=lineWidth, style=getStyle(), extend=getExtend())
    midLine  := line.new(bar_index, prevDayMid,  bar_index + 1, prevDayMid,
         color=midColor,  width=lineWidth, style=getStyle(), extend=getExtend())

// Update price levels on every bar (handles when a new day starts)
if showHigh
    line.set_y1(highLine, prevDayHigh)
    line.set_y2(highLine, prevDayHigh)
    line.set_color(highLine, highColor)
    line.set_width(highLine, lineWidth)
    line.set_style(highLine, getStyle())
    line.set_extend(highLine, getExtend())
else
    line.set_color(highLine, color.new(color.red, 100)) // invisible

if showLow
    line.set_y1(lowLine, prevDayLow)
    line.set_y2(lowLine, prevDayLow)
    line.set_color(lowLine, lowColor)
    line.set_width(lowLine, lineWidth)
    line.set_style(lowLine, getStyle())
    line.set_extend(lowLine, getExtend())
else
    line.set_color(lowLine, color.new(color.green, 100))

if showMid
    line.set_y1(midLine, prevDayMid)
    line.set_y2(midLine, prevDayMid)
    line.set_color(midLine, midColor)
    line.set_width(midLine, lineWidth)
    line.set_style(midLine, getStyle())
    line.set_extend(midLine, getExtend())
else
    line.set_color(midLine, color.new(color.orange, 100))

// ─────────────────────────────────────────────
//  LABELS  (placed at the right edge of the
//  last visible bar so they never stack up)
// ─────────────────────────────────────────────
var label highLabel = na
var label lowLabel  = na
var label midLabel  = na

if barstate.islast and showLabels
    label.delete(highLabel)
    label.delete(lowLabel)
    label.delete(midLabel)

    if showHigh
        highLabel := label.new(bar_index, prevDayHigh,
             "PDH  " + str.tostring(prevDayHigh, format.mintick),
             style      = label.style_label_left,
             color      = color.new(highColor, 85),
             textcolor  = highColor,
             size       = size.small)

    if showLow
        lowLabel := label.new(bar_index, prevDayLow,
             "PDL  " + str.tostring(prevDayLow, format.mintick),
             style      = label.style_label_left,
             color      = color.new(lowColor, 85),
             textcolor  = lowColor,
             size       = size.small)

    if showMid
        midLabel := label.new(bar_index, prevDayMid,
             "PDM  " + str.tostring(prevDayMid, format.mintick),
             style      = label.style_label_left,
             color      = color.new(midColor, 85),
             textcolor  = midColor,
             size       = size.small)

// ─────────────────────────────────────────────
//  OPTIONAL: PLOT as invisible series so the
//  built-in "Price Lines" from the Data Window
//  also show the values
// ─────────────────────────────────────────────
plot(showHigh ? prevDayHigh : na, "Prev Day High", color=highColor, linewidth=0, display=display.data_window)
plot(showLow  ? prevDayLow  : na, "Prev Day Low",  color=lowColor,  linewidth=0, display=display.data_window)
plot(showMid  ? prevDayMid  : na, "Prev Day Mid",  color=midColor,  linewidth=0, display=display.data_window)
````
