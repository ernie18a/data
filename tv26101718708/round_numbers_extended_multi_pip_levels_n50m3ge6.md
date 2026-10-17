# Round Numbers (Extended Multi Pip Levels)

- url: https://www.tradingview.com/script/n50M3GE6-Round-Numbers-Extended-Multi-Pip-Levels/
- type: indicator
- pine_id: PUB;1b740361c46f405cb429c75e730481e2
- version: 1.0

## Description

This indicator plots key round number price levels on your chart — from 50 pips all the way up to 20,000 pips. Each level is fully customizable with its own color, line thickness, and on/off toggle. Supports Forex and non-Forex instruments automatically. Levels are drawn above and below current price, making it easy to spot major psychological support and resistance zones at a glance.
Levels included: 50 | 100 | 200 | 250 | 500 | 1,000 | 2,000 | 5,000 | 10,000 | 20,000 pips

## Source Code

````pine
//The original indicator is created by Vinay and modified by Vinay

//Original : ROUND-NUMBERS INDICATOR BY DAVID BRUNET
//https://www.tradingview.com/script/IYR8u2oU-ROUND-NUMBERS-INDICATOR-BY-DAVID-BRUNET/
//@version=5
indicator("Round Numbers (Extended Multi Pip Levels)", overlay=true, max_lines_count=500)

// === Detect pip size (Forex compatible) ===
pip = syminfo.mintick * (syminfo.type == "forex" ? 10 : 1)

// === Inputs ===
show50     = input.bool(true,  "Show 50 Pips")
show100    = input.bool(true,  "Show 100 Pips")
show200    = input.bool(true,  "Show 200 Pips")
show250    = input.bool(true,  "Show 250 Pips")
show500    = input.bool(true,  "Show 500 Pips")
show1000   = input.bool(true,  "Show 1000 Pips")
show2000   = input.bool(true,  "Show 2,000 Pips")
show5000   = input.bool(true,  "Show 5,000 Pips")
show10000  = input.bool(false, "Show 10,000 Pips")
show20000  = input.bool(false, "Show 20,000 Pips")

// Thickness inputs
width50     = input.int(1, "50 Pip Thickness",      minval=1, maxval=5)
width100    = input.int(1, "100 Pip Thickness",     minval=1, maxval=5)
width200    = input.int(1, "200 Pip Thickness",     minval=1, maxval=5)
width250    = input.int(1, "250 Pip Thickness",     minval=1, maxval=5)
width500    = input.int(2, "500 Pip Thickness",     minval=1, maxval=5)
width1000   = input.int(2, "1000 Pip Thickness",    minval=1, maxval=5)
width2000   = input.int(2, "2,000 Pip Thickness",   minval=1, maxval=5)
width5000   = input.int(3, "5,000 Pip Thickness",   minval=1, maxval=5)
width10000  = input.int(3, "10,000 Pip Thickness",  minval=1, maxval=5)
width20000  = input.int(4, "20,000 Pip Thickness",  minval=1, maxval=5)

// Colors
color50     = input.color(color.gray,   "50 Pip Color")
color100    = input.color(color.blue,   "100 Pip Color")
color200    = input.color(color.green,  "200 Pip Color")
color250    = input.color(color.orange, "250 Pip Color")
color500    = input.color(color.red,    "500 Pip Color")
color1000   = input.color(color.purple, "1000 Pip Color")
color2000   = input.color(color.teal,   "2,000 Pip Color")
color5000   = input.color(color.fuchsia,"5,000 Pip Color")
color10000  = input.color(color.black,  "10,000 Pip Color")
color20000  = input.color(color.maroon, "20,000 Pip Color")

levelsAboveBelow = input.int(15, "Levels Above & Below Price", minval=1, maxval=50)

// === Function to Draw Levels ===
drawRoundLevels(stepPips, levelColor, levelWidth) =>
    step = stepPips * pip
    base = math.floor(close / step) * step
    
    for i = -levelsAboveBelow to levelsAboveBelow
        level = base + i * step
        line.new(
             x1 = bar_index,
             y1 = level,
             x2 = bar_index + 1,
             y2 = level,
             extend = extend.both,
             color = levelColor,
             width = levelWidth
         )

// === Draw Only On Last Bar ===
if barstate.islast
    if show50
        drawRoundLevels(50, color50, width50)
    if show100
        drawRoundLevels(100, color100, width100)
    if show200
        drawRoundLevels(200, color200, width200)
    if show250
        drawRoundLevels(250, color250, width250)
    if show500
        drawRoundLevels(500, color500, width500)
    if show1000
        drawRoundLevels(1000, color1000, width1000)
    if show2000
        drawRoundLevels(2000, color2000, width2000)
    if show5000
        drawRoundLevels(5000, color5000, width5000)
    if show10000
        drawRoundLevels(10000, color10000, width10000)
    if show20000
        drawRoundLevels(20000, color20000, width20000)
````
