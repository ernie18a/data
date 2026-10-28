# NIFTY Expiry Week Box - Wed to Tue

- url: https://www.tradingview.com/script/AMCE2EZZ-NIFTY-Expiry-Week-Box-Wed-to-Tue/
- type: indicator
- pine_id: PUB;3b517b2bebe54b4e8b5398dafd893a33
- version: 1.0

## Description

This indicator visually highlights the complete NIFTY weekly expiry cycle by grouping candles from Wednesday to Tuesday inside a single transparent box.

Since NIFTY weekly expiry currently falls on Tuesday, each new expiry week begins on Wednesday and ends on the following Tuesday. The box automatically expands to cover the highest high and lowest low formed during that expiry week, making it easier to understand the complete weekly trading range at a glance.

The box uses a light, transparent background so that candlesticks, wicks, price action, and other indicators remain clearly visible.

The main purpose of this indicator is to help traders visually study expiry-week behavior, weekly ranges, breakouts, support and resistance zones, volatility expansion, and how price develops from the start of a new expiry cycle until expiry day.

Expiry Week Structure:

Wednesday → Thursday → Friday → Monday → Tuesday

Wednesday marks the beginning of the new expiry cycle, while Tuesday represents the expiry day.

This indicator is primarily designed for NIFTY charts and can be useful for intraday analysis, weekly range analysis, expiry-day studies, breakout strategies, and historical price-action research.

## Source Code

````pine
//@version=6
indicator("NIFTY Expiry Week Box - Wed to Tue", overlay = true, max_boxes_count = 300)

// ─────────────────────────────────────────────
// SETTINGS
// ─────────────────────────────────────────────

showBoxes = input.bool(true, "Show Expiry Week Boxes")

boxColor = input.color(
     color.new(color.blue, 90),
     "Box Background"
)

borderColor = input.color(
     color.new(color.blue, 55),
     "Box Border"
)

borderWidth = input.int(
     1,
     "Border Width",
     minval = 1,
     maxval = 4
)


// ─────────────────────────────────────────────
// WEEK LOGIC
// Wednesday starts a new expiry week
// Tuesday finishes the expiry week
// ─────────────────────────────────────────────

isWednesday = dayofweek == dayofweek.wednesday
isTuesday   = dayofweek == dayofweek.tuesday

newExpiryWeek =
     isWednesday and dayofweek[1] != dayofweek.wednesday


// ─────────────────────────────────────────────
// VARIABLES
// ─────────────────────────────────────────────

var box currentBox = na
var float weekHigh = na
var float weekLow  = na
var int weekStart  = na


// ─────────────────────────────────────────────
// START NEW BOX ON WEDNESDAY
// ─────────────────────────────────────────────

if newExpiryWeek

    weekHigh := high
    weekLow  := low
    weekStart := bar_index

    if showBoxes
        currentBox := box.new(
             left = bar_index,
             top = high,
             right = bar_index,
             bottom = low,
             xloc = xloc.bar_index,
             bgcolor = boxColor,
             border_color = borderColor,
             border_width = borderWidth
        )


// ─────────────────────────────────────────────
// UPDATE WEEK HIGH / LOW
// ─────────────────────────────────────────────

if not na(currentBox)

    weekHigh := math.max(weekHigh, high)
    weekLow  := math.min(weekLow, low)

    box.set_top(currentBox, weekHigh)
    box.set_bottom(currentBox, weekLow)
    box.set_right(currentBox, bar_index)


// ─────────────────────────────────────────────
// FINISH BOX ON TUESDAY
// ─────────────────────────────────────────────

if isTuesday and not na(currentBox)

    box.set_right(currentBox, bar_index)

    currentBox := na
    weekHigh := na
    weekLow := na
    weekStart := na
````
