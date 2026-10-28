# Previous 4H High/Low Levels + Sweep Alert

- url: https://www.tradingview.com/script/8b2oMpPr-Previous-4H-High-Low-Levels-Sweep-Alert/
- type: indicator
- pine_id: PUB;80f6acf28f2c4ebba008219ed937cd53
- version: 1.0

## Description

This indicator marks out the high and low of the previous 4 hour candle and provides an alert when price sweeps the high or low of the previous 4 hour candle respectively.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © strades55

//@version=5
indicator(title="Previous 4H High/Low Levels + Sweep Alert", overlay=true, max_lines_count=10)

// ─────────────────────────────────────────────
// SETTINGS
// ─────────────────────────────────────────────
highColor       = input.color(color.new(color.green, 0),  "4H High Line Color")
lowColor        = input.color(color.new(color.red, 0),    "4H Low Line Color")
lineWidth       = input.int(2, "Line Width", minval=1, maxval=4)
lineStyle       = input.string("Dashed", "Line Style", options=["Solid", "Dashed", "Dotted"])
extendLines     = input.bool(true, "Extend Lines Right")
showLabels      = input.bool(true, "Show Labels")

// Sweep detection sensitivity (in ticks)
sweepBuffer     = input.float(0.0, "Sweep Buffer (extra ticks beyond level)", minval=0.0, step=0.1,
     tooltip="How many ticks BEYOND the 4H level price must close to confirm a sweep. 0 = exact touch.")

// ─────────────────────────────────────────────
// FETCH PREVIOUS 4H CANDLE HIGH & LOW
// ─────────────────────────────────────────────
[prev4hHigh, prev4hLow] = request.security(syminfo.tickerid, "240",
     [high[1], low[1]],
     lookahead=barmerge.lookahead_on)

// ─────────────────────────────────────────────
// LINE STYLE HELPER
// ─────────────────────────────────────────────
getLineStyle() =>
    lineStyle == "Dashed" ? line.style_dashed :
     lineStyle == "Dotted" ? line.style_dotted :
     line.style_solid

// ─────────────────────────────────────────────
// DRAW LINES — only redraw when the 4H level changes
// ─────────────────────────────────────────────
var line highLine  = na
var line lowLine   = na
var label highLbl  = na
var label lowLbl   = na

levelChanged = ta.change(prev4hHigh) or ta.change(prev4hLow)

if levelChanged
    // Delete old lines & labels
    if not na(highLine)
        line.delete(highLine)
    if not na(lowLine)
        line.delete(lowLine)
    if showLabels
        if not na(highLbl)
            label.delete(highLbl)
        if not na(lowLbl)
            label.delete(lowLbl)

    ext = extendLines ? extend.right : extend.none

    highLine := line.new(
         x1=bar_index, y1=prev4hHigh,
         x2=bar_index + 1, y2=prev4hHigh,
         color=highColor, width=lineWidth,
         style=getLineStyle(), extend=ext)

    lowLine := line.new(
         x1=bar_index, y1=prev4hLow,
         x2=bar_index + 1, y2=prev4hLow,
         color=lowColor, width=lineWidth,
         style=getLineStyle(), extend=ext)

    if showLabels
        highLbl := label.new(
             x=bar_index, y=prev4hHigh,
             text="Prev 4H High: " + str.tostring(prev4hHigh, format.mintick),
             color=color.new(highColor, 80),
             textcolor=highColor,
             style=label.style_label_left,
             size=size.small)

        lowLbl := label.new(
             x=bar_index, y=prev4hLow,
             text="Prev 4H Low: " + str.tostring(prev4hLow, format.mintick),
             color=color.new(lowColor, 80),
             textcolor=lowColor,
             style=label.style_label_left,
             size=size.small)

// ─────────────────────────────────────────────
// SWEEP + RETRACEMENT DETECTION
//
// A "sweep" of the HIGH is defined as:
//   1. Price trades ABOVE prev4hHigh (+ buffer) on a 15m candle
//   2. That same candle (or a subsequent one) CLOSES back BELOW prev4hHigh
//      → price has re-entered the 4H range
//
// A "sweep" of the LOW is defined as:
//   1. Price trades BELOW prev4hLow (- buffer) on a 15m candle
//   2. That same candle (or a subsequent one) CLOSES back ABOVE prev4hLow
//      → price has re-entered the 4H range
// ─────────────────────────────────────────────

bufferPoints = sweepBuffer * syminfo.mintick

// High sweep: wick pierces above the level AND candle closes back inside the range
highSweep = high > (prev4hHigh + bufferPoints) and close < prev4hHigh

// Low sweep: wick pierces below the level AND candle closes back inside the range
lowSweep  = low  < (prev4hLow  - bufferPoints) and close > prev4hLow

// ─────────────────────────────────────────────
// VISUAL MARKERS FOR SWEEPS
// ─────────────────────────────────────────────
plotshape(highSweep,
     title="High Sweep + Retracement",
     location=location.abovebar,
     style=shape.triangledown,
     color=color.new(color.orange, 0),
     size=size.normal,
     text="Sweep High")

plotshape(lowSweep,
     title="Low Sweep + Retracement",
     location=location.belowbar,
     style=shape.triangleup,
     color=color.new(color.aqua, 0),
     size=size.normal,
     text="Sweep Low")

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────
alertcondition(highSweep,
     title="🔻 Swept Prev 4H High + Retraced",
     message="{{ticker}} — Price swept the previous 4H High ({{high}}) and closed back below it on the 15m chart. Possible bearish reversal / liquidity grab.")

alertcondition(lowSweep,
     title="🔺 Swept Prev 4H Low + Retraced",
     message="{{ticker}} — Price swept the previous 4H Low ({{low}}) and closed back above it on the 15m chart. Possible bullish reversal / liquidity grab.")

alertcondition(highSweep or lowSweep,
     title="⚡ Any 4H Level Sweep + Retracement",
     message="{{ticker}} — Price swept a previous 4H level and retraced inside the range on the 15m chart.")
````
