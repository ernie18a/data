# Dax Fibonacci Breakout 9:00-9:15

- url: https://www.tradingview.com/script/QPzsfqqM/
- type: indicator
- pine_id: PUB;213d1588d58d4345940df68641e4e0d4
- version: 3.0

## Description

Beschreibt die 15 Minuten Kerze nach Eröffnung für eventuellen Breakout

## Source Code

````pine
//@version=6
indicator("DAX 15m Fibonacci)", overlay=true, max_lines_count=500, max_labels_count=500)

tz = "Europe/Berlin"

// Referenz: abgeschlossene 9:00–9:15 Kerze
isRef = (hour(time, tz) == 9 and minute(time, tz) == 00) and barstate.isconfirmed

if isRef
    refHigh = high
    refLow  = low
    refIdx  = bar_index

    r = refHigh - refLow

    fib0    = refLow
    fib100  = refHigh
    fib137  = refLow + 1.37 * r
    fib278  = refLow + 2.78 * r
    fibN43  = refLow - 0.43 * r
    fibN190 = refLow - 1.90 * r

    // 8 Kerzen davor / danach
    startIdx = refIdx - 8
    endIdx   = refIdx + 8

    // kleiner Offset für Labels neben der Linie
    offset = syminfo.mintick * 20

    // 0%
    line.new(startIdx, fib0, endIdx, fib0, color=color.blue, width=2)
    label.new(endIdx, fib0 + offset, "0", style=label.style_none, textcolor=color.blue)

    // 100%
    line.new(startIdx, fib100, endIdx, fib100, color=color.blue, width=2)
    label.new(endIdx, fib100 + offset, "1", style=label.style_none, textcolor=color.blue)

    // 1.37
    line.new(startIdx, fib137, endIdx, fib137, color=color.green, width=2)
    label.new(endIdx, fib137 + offset, "1.37", style=label.style_none, textcolor=color.green)

    // 2.78 (korrigiert)
    line.new(startIdx, fib278, endIdx, fib278, color=color.black, width=2)
    label.new(endIdx, fib278 + offset, "2.78", style=label.style_none, textcolor=color.black)

    // -0.43
    line.new(startIdx, fibN43, endIdx, fibN43, color=color.red, width=2)
    label.new(endIdx, fibN43 + offset, "-0.43", style=label.style_none, textcolor=color.red)

    // -1.90
    line.new(startIdx, fibN190, endIdx, fibN190, color=color.black, width=2)
    label.new(endIdx, fibN190 + offset, "-1.9", style=label.style_none, textcolor=color.black)
````
