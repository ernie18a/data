# Thicker Wicks by BobbyBangkok

- url: https://www.tradingview.com/script/SdoRQ76s-Thicker-Wicks-by-BobbyBangkok/
- type: indicator
- pine_id: PUB;db7600bf8ea44347bf05911c068ced06
- version: 1.0

## Description

Just a simple script that lets you adjust the thickness and color of the wicks so you can see them better. Can be adjusted from 1 to 5 thickness.

## Source Code

````pine
//@version=6
indicator("Thicker Wicks by BobbyBangkok", overlay=true, max_lines_count=500)

// ─────────────────────────────────────────────
// USER INPUTS
// ─────────────────────────────────────────────
wickThickness = input.int(3, "Wick Thickness", minval=1, maxval=10)
wickColor     = input.color(color.white, "Wick Color")
maxWicks      = input.int(200, "Max Wicks to Draw", minval=10, maxval=500)

// ─────────────────────────────────────────────
// INTERNAL STORAGE
// ─────────────────────────────────────────────
var upperWicks = array.new_line()
var lowerWicks = array.new_line()

// Candle body boundaries
bodyTop    = math.max(open, close)
bodyBottom = math.min(open, close)

// ─────────────────────────────────────────────
// FUNCTION: Create or recycle a line
// ─────────────────────────────────────────────
f_getLine(arr) =>
    if array.size(arr) < maxWicks
        // Create new line
        ln = line.new(na, na, na, na)
        array.push(arr, ln)
        ln
    else
        // Recycle oldest line
        ln = array.shift(arr)
        array.push(arr, ln)
        ln

// ─────────────────────────────────────────────
// DRAW UPPER WICK
// ─────────────────────────────────────────────
lnUpper = f_getLine(upperWicks)
line.set_xy1(lnUpper, bar_index, high)
line.set_xy2(lnUpper, bar_index, bodyTop)
line.set_width(lnUpper, wickThickness)
line.set_color(lnUpper, wickColor)

// ─────────────────────────────────────────────
// DRAW LOWER WICK
// ─────────────────────────────────────────────
lnLower = f_getLine(lowerWicks)
line.set_xy1(lnLower, bar_index, bodyBottom)
line.set_xy2(lnLower, bar_index, low)
line.set_width(lnLower, wickThickness)
line.set_color(lnLower, wickColor)
````
