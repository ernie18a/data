# ZigZag with Fibonacci Levels

- url: https://www.tradingview.com/script/VOL3sr8x-ZigZag-with-Fibonacci-Levels/
- type: indicator
- pine_id: PUB;58f6fdcf2dff4311a47f7345df0018fa
- version: 1.0

## Description

zigzag indicator with fib retracement  for pullback strategy

## Source Code

````pine
//@version=6
indicator("ZigZag with Fibonacci Levels", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ───────────────────────── Inputs ─────────────────────────
zigzagPeriod   = input.int(15, "ZigZag Period", minval = 2)
showZigZag     = input.bool(true, "Show Zig Zag")
showFibo       = input.bool(true, "Show Fibonacci Ratios")

textColor      = input.color(color.new(#2196F3, 0), "Text Color for Fibo Levels")
fiboLineColor  = input.color(color.new(#00C853, 0), "Line Color for Fibo Levels")

upColor        = input.color(color.new(#00C853, 0), "Zigzag Up Color",   inline = "zz")
downColor      = input.color(color.new(#FF5252, 0), "Zigzag Down Color", inline = "zz")

labelLocation  = input.string("Left", "Label Location", options = ["Left", "Right"])

enable000 = true
enable236 = input.bool(true, "Enable Level 0.236")
enable382 = input.bool(true, "Enable Level 0.382")
enable500 = input.bool(true, "Enable Level 0.500")
enable618 = input.bool(true, "Enable Level 0.618")
enable786 = input.bool(true, "Enable Level 0.786")
enable100 = true

extendRight = input.bool(true, "Extend Fibo Lines Right")

// ───────────────────────── Pivot storage ─────────────────────────
var float[] pPrice = array.new<float>()
var int[]   pBar    = array.new<int>()
var int[]   pDir     = array.new<int>()   // 1 = pivot high, -1 = pivot low

var line[]  fbLines  = array.new<line>()
var label[] fbLabels = array.new<label>()
var line    currentSegLine = na   // the line for the most recent, still-evolving zigzag segment

ph = ta.pivothigh(high, zigzagPeriod, zigzagPeriod)
pl = ta.pivotlow(low,  zigzagPeriod, zigzagPeriod)

// ───────────────────────── Pivot processing ─────────────────────────
// returns "push" (brand new pivot added), "replace" (last pivot extended), or "none"
processPivot(price, dir) =>
    int n = array.size(pDir)
    int barIdx = bar_index - zigzagPeriod
    string result = "none"
    if n == 0
        array.push(pPrice, price)
        array.push(pBar, barIdx)
        array.push(pDir, dir)
        result := "push"
    else
        int lastDir   = array.get(pDir, n - 1)
        float lastPx  = array.get(pPrice, n - 1)
        if lastDir == dir
            bool replace = (dir == 1 and price > lastPx) or (dir == -1 and price < lastPx)
            if replace
                array.set(pPrice, n - 1, price)
                array.set(pBar, n - 1, barIdx)
                result := "replace"
        else
            array.push(pPrice, price)
            array.push(pBar, barIdx)
            array.push(pDir, dir)
            result := "push"
    result

string action = "none"
if not na(ph)
    action := processPivot(ph, 1)
if not na(pl)
    string action2 = processPivot(pl, -1)
    if action2 != "none"
        action := action2

// ───────────────────────── Draw ZigZag line ─────────────────────────
// "replace" -> the last pivot moved, so delete & redraw the in-progress segment
// "push"    -> the in-progress segment is now final (leave it), start a fresh one
if showZigZag and action != "none"
    int n = array.size(pDir)
    if action == "replace" and not na(currentSegLine)
        line.delete(currentSegLine)
        currentSegLine := na
    else if action == "push"
        currentSegLine := na  // detach reference; previously drawn line stays on chart as the finished segment

    if n >= 2
        int b1 = array.get(pBar, n - 2)
        int b0 = array.get(pBar, n - 1)
        float v1 = array.get(pPrice, n - 2)
        float v0 = array.get(pPrice, n - 1)
        color segColor = array.get(pDir, n - 1) == 1 ? upColor : downColor
        currentSegLine := line.new(b1, v1, b0, v0, xloc.bar_index, color = segColor, width = 2)

// ───────────────────────── Draw / refresh Fibonacci levels for the latest leg ─────────────────────────
var int lastFiboLegBar = na
if array.size(pDir) >= 2
    int n = array.size(pDir)
    int barOlder = array.get(pBar, n - 2)
    int barNewer = array.get(pBar, n - 1)
    float priceOlder = array.get(pPrice, n - 2)   // labeled "1"
    float priceNewer = array.get(pPrice, n - 1)   // labeled "0"

    if barNewer != lastFiboLegBar
        // clear old fibo drawings
        for ln in fbLines
            line.delete(ln)
        array.clear(fbLines)
        for lb in fbLabels
            label.delete(lb)
        array.clear(fbLabels)
        lastFiboLegBar := barNewer

    if showFibo
        // remove and redraw each bar so "Right" label location can track price axis
        for ln in fbLines
            line.delete(ln)
        array.clear(fbLines)
        for lb in fbLabels
            label.delete(lb)
        array.clear(fbLabels)

        ratios = array.from(0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0)
        enabled = array.from(enable000, enable236, enable382, enable500, enable618, enable786, enable100)

        int xStart = labelLocation == "Left" ? barOlder : bar_index
        int xLine0 = barOlder
        int xLine1 = bar_index

        for i = 0 to array.size(ratios) - 1
            if array.get(enabled, i)
                float ratio = array.get(ratios, i)
                float lvl = priceNewer + ratio * (priceOlder - priceNewer)
                line ln = line.new(xLine0, lvl, xLine1, lvl, xloc.bar_index, extend = extendRight ? extend.right : extend.none, color = fiboLineColor, width = 1)
                array.push(fbLines, ln)
                string txt = str.tostring(ratio, "#.###") + " (" + str.tostring(lvl, format.mintick) + ")"
                label lb = label.new(xStart, lvl, txt, xloc.bar_index, yloc.price, color = color.new(color.black, 100), textcolor = textColor, style = label.style_label_left, size = size.small)
                array.push(fbLabels, lb)
````
