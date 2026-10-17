# Fib Swing

- url: https://www.tradingview.com/script/gopYr73D-Fib-Swing/
- type: indicator
- pine_id: PUB;a4dd7e3fa98c4a6681be0e73323e15d4
- version: 2.0

## Description

Fib Swing automatically identifies the latest swing high and low, plots the 0.5–0.6 Fibonacci retracement line and highlights high-probability trade opportunities within that range.

## Source Code

````pine


//@version=6
indicator("Fvg", overlay=true, max_boxes_count=200, max_labels_count=200)

// ─── INPUTS ────────────────────────────────────────────────
pivotLen        = input.int(20,  "Pivot Lookback Length",  minval=2)
showFibZone     = input.bool(true, "Show Fib Zone")
showFVGBoxes    = input.bool(true, "Show FVG Boxes")
bullColor       = input.color(color.new(color.lime,  70), "Bullish FVG Color")
bearColor       = input.color(color.new(color.red,   70), "Bearish FVG Color")
fibZoneColor    = input.color(color.new(color.blue,  85), "Fib Zone Color")
signalBullColor = input.color(color.lime,  "Buy Signal Color")
signalBearColor = input.color(color.red,   "Sell Signal Color")

// ─── PIVOT DETECTION ───────────────────────────────────────
swingHigh = ta.pivothigh(high, pivotLen, pivotLen)
swingLow  = ta.pivotlow (low,  pivotLen, pivotLen)

// Track most-recent confirmed pivot prices and bar indices
var float lastPHPrice = na
var int   lastPHBar   = na
var float lastPLPrice = na
var int   lastPLBar   = na

if not na(swingHigh)
    lastPHPrice := swingHigh
    lastPHBar   := bar_index[pivotLen]   // pivot confirmed pivotLen bars ago

if not na(swingLow)
    lastPLPrice := swingLow
    lastPLBar   := bar_index[pivotLen]

// ─── FIB ZONE CALCULATION ──────────────────────────────────
// Bullish setup  → swing Low → swing High  (retracement pulls back into zone)
// Bearish setup  → swing High → swing Low  (retracement bounces into zone)

var float bullFib50  = na
var float bullFib618 = na
var float bearFib50  = na
var float bearFib618 = na

// Bullish: last swing low came BEFORE last swing high
bullSetup = not na(lastPLBar) and not na(lastPHBar) and lastPLBar < lastPHBar
if bullSetup
    rng         = lastPHPrice - lastPLPrice
    bullFib50  := lastPHPrice - 0.500 * rng   // 50 % retracement
    bullFib618 := lastPHPrice - 0.618 * rng   // 61.8 % retracement

// Bearish: last swing high came BEFORE last swing low
bearSetup = not na(lastPLBar) and not na(lastPHBar) and lastPHBar < lastPLBar
if bearSetup
    rng         = lastPHPrice - lastPLPrice
    bearFib50  := lastPLPrice + 0.500 * rng   // 50 % bounce
    bearFib618 := lastPLPrice + 0.618 * rng   // 61.8 % bounce

// ─── DRAW FIB ZONE (last bar only to avoid overplotting) ───
fibTop    = bullSetup ? bullFib50  : bearSetup ? bearFib618 : na
fibBottom = bullSetup ? bullFib618 : bearSetup ? bearFib50  : na

// Plot as two lines with fill
fibTopLine    = plot(showFibZone ? fibTop    : na, "Fib 0.50",  color=color.new(color.blue, 60), linewidth=1, style=plot.style_linebr)
fibBottomLine = plot(showFibZone ? fibBottom : na, "Fib 0.618", color=color.new(color.blue, 60), linewidth=1, style=plot.style_linebr)
fill(fibTopLine, fibBottomLine, color=fibZoneColor, title="Fib Zone Fill")

// ─── FAIR VALUE GAP DETECTION ──────────────────────────────
//  Bullish FVG : high[2] < low[0]   → gap between candle-2 and candle-0
//  Bearish FVG : low[2]  > high[0]  → gap between candle-2 and candle-0
bullFVG = high[2] < low[0]          // gap top = low[0], gap bottom = high[2]
bearFVG = low[2]  > high[0]         // gap top = low[2],  gap bottom = high[0]

// FVG range midpoints / edges
bullFVG_top    = low[0]
bullFVG_bottom = high[2]
bearFVG_top    = low[2]
bearFVG_bottom = high[0]

// ─── FIB ZONE FILTER ───────────────────────────────────────
// A FVG qualifies when it overlaps with the Fib zone
inFibZone(gapTop, gapBottom, zoneTop, zoneBottom) =>
    not na(zoneTop) and not na(zoneBottom) and
     gapTop >= zoneBottom and gapBottom <= zoneTop

bullSignal = bullFVG and bullSetup and inFibZone(bullFVG_top, bullFVG_bottom, bullFib50, bullFib618)
bearSignal = bearFVG and bearSetup and inFibZone(bearFVG_top, bearFVG_bottom, bearFib618, bearFib50)

// ─── DRAW FVG BOXES ────────────────────────────────────────
// Draw a box spanning the FVG range (extends right by 8 bars for visibility)
boxExtend = 8

if showFVGBoxes and bullSignal
    box.new(bar_index[1], bullFVG_top, bar_index + boxExtend, bullFVG_bottom,
             border_color=color.lime, bgcolor=bullColor, border_width=1)

if showFVGBoxes and bearSignal
    box.new(bar_index[1], bearFVG_top, bar_index + boxExtend, bearFVG_bottom,
             border_color=color.red,  bgcolor=bearColor, border_width=1)

// ─── SIGNAL LABELS ─────────────────────────────────────────
if bullSignal
    label.new(bar_index, low - ta.atr(14),
              text="▲ BUY",
              style=label.style_label_up,
              color=signalBullColor,
              textcolor=color.black,
              size=size.small)

if bearSignal
    label.new(bar_index, high + ta.atr(14),
              text="▼ SELL",
              style=label.style_label_down,
              color=signalBearColor,
              textcolor=color.white,
              size=size.small)

// ─── SIGNAL SHAPES (for alert compatibility) ────────────────
plotshape(bullSignal, title="Buy Signal",  location=location.belowbar,
          style=shape.triangleup,   size=size.small, color=signalBullColor)
plotshape(bearSignal, title="Sell Signal", location=location.abovebar,
          style=shape.triangledown, size=size.small, color=signalBearColor)

// ─── ALERTS ────────────────────────────────────────────────
alertcondition(bullSignal, title="Bullish",
               message="Bullish FVG detected ")
alertcondition(bearSignal, title="Bearish ",
               message="Bearish FVG detected!")
````
