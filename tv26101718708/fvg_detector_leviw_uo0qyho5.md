# FVG Detector LeviW

- url: https://www.tradingview.com/script/uo0qYHO5-FVG-Detector-LeviW/
- type: indicator
- pine_id: PUB;11dc1b1234ec41c7a2111b327558cbe6
- version: 1.0

## Description

A Simple FVG indicator built for personal use, Using Dark purple lines for easy on the eyes access on a dark backround.

## Source Code

````pine
//@version=5
indicator("FVG Detector", overlay=true, max_boxes_count=500)

colBull = input.color(color.new(#4A148C,80), "Bull FVG Color")
colBear = input.color(color.new(#B71C1C,80), "Bear FVG Color")

bullFVG = low[0] > high[2]
bearFVG = high[0] < low[2]

var box[]  fvgBoxes  = array.new_box()
var bool[] fvgIsBull = array.new_bool()

if bullFVG
    fvgTop = high[2]
    fvgBot = low[0]
    overlap = false
    if array.size(fvgBoxes) > 0
        for i = 0 to array.size(fvgBoxes) - 1
            if array.get(fvgIsBull, i)
                existTop = box.get_top(array.get(fvgBoxes, i))
                existBot = box.get_bottom(array.get(fvgBoxes, i))
                if fvgBot < existTop and fvgTop > existBot
                    overlap := true
    if not overlap
        b = box.new(bar_index - 2, fvgBot, bar_index, fvgTop, bgcolor=colBull, border_color=color.new(#4A148C,60), border_width=1, extend=extend.right)
        array.push(fvgBoxes, b)
        array.push(fvgIsBull, true)

if bearFVG
    fvgTop = low[2]
    fvgBot = high[0]
    overlap = false
    if array.size(fvgBoxes) > 0
        for i = 0 to array.size(fvgBoxes) - 1
            if not array.get(fvgIsBull, i)
                existTop = box.get_top(array.get(fvgBoxes, i))
                existBot = box.get_bottom(array.get(fvgBoxes, i))
                if fvgBot < existTop and fvgTop > existBot
                    overlap := true
    if not overlap
        b = box.new(bar_index - 2, fvgBot, bar_index, fvgTop, bgcolor=colBear, border_color=color.new(#B71C1C,60), border_width=1, extend=extend.right)
        array.push(fvgBoxes, b)
        array.push(fvgIsBull, false)

if array.size(fvgBoxes) > 0
    i = 0
    while i < array.size(fvgBoxes)
        b      = array.get(fvgBoxes, i)
        isBull = array.get(fvgIsBull, i)
        top    = box.get_top(b)
        bot    = box.get_bottom(b)
        mitigated = isBull ? close < bot : close > top
        if mitigated
            box.delete(b)
            array.remove(fvgBoxes, i)
            array.remove(fvgIsBull, i)
        else
            box.set_right(b, bar_index)
            i := i + 1
````
