# Untested Highs & Lows

- url: https://www.tradingview.com/script/HXBc5JhJ-Untested-Highs-Lows/
- type: indicator
- pine_id: PUB;c68c15a7982f4cc0a3e1df8bc15ad692
- version: 1.0

## Description

This indicator automatically identifies swing highs and swing lows that have not yet been revisited by price.

## Source Code

````pine
//@version=6
indicator("Untested Highs & Lows", overlay=true, max_lines_count=500)

pivotLen = input.int(5, "Pivot Length", minval=1)

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var highLines = array.new<line>()
var highPrices = array.new<float>()

var lowLines = array.new<line>()
var lowPrices = array.new<float>()

// Create untested highs
if not na(ph)
    newLine = line.new(
         bar_index - pivotLen,
         ph,
         bar_index,
         ph,
         extend = extend.right,
         color = color.red,
         width = 2)
    array.push(highLines, newLine)
    array.push(highPrices, ph)

// Create untested lows
if not na(pl)
    newLine = line.new(
         bar_index - pivotLen,
         pl,
         bar_index,
         pl,
         extend = extend.right,
         color = color.green,
         width = 2)
    array.push(lowLines, newLine)
    array.push(lowPrices, pl)

// Remove tested highs
for i = array.size(highLines) - 1 to 0
    level = array.get(highPrices, i)
    if high >= level
        line.delete(array.get(highLines, i))
        array.remove(highLines, i)
        array.remove(highPrices, i)

// Remove tested lows
for i = array.size(lowLines) - 1 to 0
    level = array.get(lowPrices, i)
    if low <= level
        line.delete(array.get(lowLines, i))
        array.remove(lowLines, i)
        array.remove(lowPrices, i)
````
