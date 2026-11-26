# Daily Open 5-Minute Range Box (Any Timeframe)

- url: https://www.tradingview.com/script/h6pDtjUc-Daily-Open-5-Minute-Range-Box-Any-Timeframe/
- type: indicator
- pine_id: PUB;3b69a24eeef947c3bc34b9eca520c6d7
- version: 1.0

## Description

Indicator Description (strategy-aligned)

Defines the **daily opening reference zone** by projecting the high–low range of the first 5-minute candle across all timeframes.
This zone acts as a **liquidity anchor**, capturing early-session imbalance and providing a structural baseline for intraday positioning.

Used within the strategy to:

* contextualize price relative to the daily open
* identify compression vs expansion conditions
* validate entries when **time (session alignment)** and **structure (range interaction)** converge

The box is not a signal, but a **constraint framework**—trades are only considered when price behavior around this range aligns with higher timeframe bias and timing logic.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// © GOLDMANSAK

//@version=5
indicator("Daily Open 5-Minute Range Box (Any Timeframe)", overlay=true, max_boxes_count=500)

// ───── INPUTS ─────
showHistory   = input.bool(true, "Show Previous Days")
extendBox     = input.bool(true, "Extend Box Through Day")
showMidline   = input.bool(false, "Show Midline")

// Visual settings
boxColor      = input.color(color.blue, "Box Color")
boxTransparency = input.int(85, "Box Transparency (0-100)", minval=0, maxval=100)
borderColor   = input.color(color.blue, "Border Color")
borderWidth   = input.int(2, "Border Width", minval=1, maxval=5)
midlineColor  = input.color(color.white, "Midline Color")

// ───── GET FIRST 5M CANDLE OF THE DAY ─────
first5High = request.security(syminfo.tickerid, "5",
     ta.valuewhen(ta.change(time("D")), high, 0))

first5Low = request.security(syminfo.tickerid, "5",
     ta.valuewhen(ta.change(time("D")), low, 0))

first5Time = request.security(syminfo.tickerid, "5",
     ta.valuewhen(ta.change(time("D")), time, 0))

// ───── DETECT NEW DAY ─────
newDay = ta.change(first5Time)

// ───── STORAGE ─────
var box  rangeBox = na
var line midLine  = na

// ───── CREATE BOX ─────
if newDay and not na(first5High) and not na(first5Low)

    if not showHistory
        if not na(rangeBox)
            box.delete(rangeBox)
        if not na(midLine)
            line.delete(midLine)

    rangeBox := box.new(
         left = first5Time,
         right = time,
         top = first5High,
         bottom = first5Low,
         xloc = xloc.bar_time,
         border_color = borderColor,
         border_width = borderWidth,
         bgcolor = color.new(boxColor, boxTransparency)
     )

    if showMidline
        mid = (first5High + first5Low) / 2
        midLine := line.new(
             x1 = first5Time,
             y1 = mid,
             x2 = time,
             y2 = mid,
             xloc = xloc.bar_time,
             color = midlineColor,
             style = line.style_dotted,
             width = 1
         )

// ───── UPDATE BOX ─────
if not na(rangeBox)
    if extendBox
        box.set_right(rangeBox, time)
    else
        box.set_right(rangeBox, first5Time + 5 * 60 * 1000)

if showMidline and not na(midLine)
    if extendBox
        line.set_x2(midLine, time)
    else
        line.set_x2(midLine, first5Time + 5 * 60 * 1000)
````
