# No-Wick Open Highlighter (Repairs)

- url: https://www.tradingview.com/script/qdRebFU0-No-Wick-Open-Highlighter-Repairs/
- type: indicator
- pine_id: PUB;8a9f71f09cf64f738270704f708f29f7
- version: 1.0

## Description

No-Wick Open Highlighter (Repairs)
This indicator draws a horizontals at candle opens which had no wick at all.

## Source Code

````pine
//@version=5
indicator("No-Wick Open Highlighter", overlay=true, max_boxes_count=500, max_lines_count=500)

// --- Inputs ---
bullColor = input.color(color.teal, "Bullish no-wick color")
bearColor = input.color(color.red,  "Bearish no-wick color")
lineLen   = input.int(50, "Line length (bars)", minval=5, maxval=300)

// --- Tolerance ---
tol = syminfo.mintick


// --- Logic ---
isBullNoWick = close >= open and (open - low) <= tol
isBearNoWick = close <  open and (high - open) <= tol

// --- Storage ---
var line[] activeLines = array.new_line()
var float[] openLevels = array.new_float()
var int[] startBars   = array.new_int()

// --- Create line on signal ---
if isBullNoWick
    l = line.new(x1=bar_index, y1=open, x2=bar_index + lineLen, y2=open, color=bullColor, width=2, style=line.style_solid, extend=extend.none)
    array.push(activeLines, l)
    array.push(openLevels, open)
    array.push(startBars, bar_index)

if isBearNoWick
    l = line.new(x1=bar_index, y1=open, x2=bar_index + lineLen, y2=open, color=bearColor, width=2, style=line.style_solid, extend=extend.none)
    array.push(activeLines, l)
    array.push(openLevels, open)
    array.push(startBars, bar_index)

// --- Delete line when price revisits the open level ---
if array.size(activeLines) > 0
    i = array.size(activeLines) - 1
    while i >= 0
        lvl = array.get(openLevels, i)
        startBar = array.get(startBars, i)
        // only check AFTER the candle that created it
        if bar_index > startBar and low <= lvl and high >= lvl
            line.delete(array.get(activeLines, i))
            array.remove(activeLines, i)
            array.remove(openLevels, i)
            array.remove(startBars, i)
        i -= 1
````
