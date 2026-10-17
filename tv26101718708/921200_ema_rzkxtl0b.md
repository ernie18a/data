# 9/21/200 EMA

- url: https://www.tradingview.com/script/RZKxTl0b-9-21-200-EMA/
- type: indicator
- pine_id: PUB;a7c17effed70485d948902c6ff17390b
- version: 1.0

## Description

This indicator plots the 9, 21, and 200 Exponential Moving Averages (EMAs) directly on your chart. The 9 and 21 EMAs track short-term momentum, while the 200 EMA serves as a long-term trend filter.

A compact table in the top right displays each EMA's current value at a glance, so you always know where the levels are regardless of how close the lines are to each other.

## Source Code

````pine
//@version=6
indicator("9/21/200 EMA", overlay=true)

// ── Inputs ──
ema1Len     = input.int(9,   "EMA 1 Length", minval=1)
ema2Len     = input.int(21,  "EMA 2 Length", minval=1)
ema3Len     = input.int(200, "EMA 3 Length", minval=1)
src         = input.source(close, "Source")
showCross   = input.bool(true,  "Show 9/21 Crossover Signals")
showTable   = input.bool(true,  "Show EMA Table")
showLabels  = input.bool(false, "Show Right-Edge Labels (may overlap)")
labelOffset = input.int(5, "Label Offset (bars right)", minval=0)

// ── Calculations ──
ema1 = ta.ema(src, ema1Len)
ema2 = ta.ema(src, ema2Len)
ema3 = ta.ema(src, ema3Len)

// ── Colors ──
c1 = color.aqua
c2 = color.orange
c3 = color.red

// ── Plots ──
plot(ema1, "EMA 9",   color=c1, linewidth=1)
plot(ema2, "EMA 21",  color=c2, linewidth=1)
plot(ema3, "EMA 200", color=c3, linewidth=2)

// ── EMA Table (horizontal, top right) ──
var table emaTable = table.new(position.top_right, 5, 3, border_width=0)

if showTable and barstate.islast
    bg    = color.new(color.black, 70)
    empty = color.new(color.black, 100)

    // spacer row
    table.cell(emaTable, 0, 0, "", bgcolor=empty, text_size=size.small)
    table.cell(emaTable, 1, 0, "", bgcolor=empty, text_size=size.small)
    table.cell(emaTable, 2, 0, "", bgcolor=empty, text_size=size.small)
    table.cell(emaTable, 3, 0, "", bgcolor=empty, text_size=size.small)
    table.cell(emaTable, 4, 0, "", bgcolor=empty, text_size=size.small)

    // name row
    table.cell(emaTable, 0, 1, " 9 EMA ",   text_color=color.white, bgcolor=c1, text_size=size.small)
    table.cell(emaTable, 1, 1, " ",          text_color=color.white, bgcolor=bg,  text_size=size.small)
    table.cell(emaTable, 2, 1, " 21 EMA ",  text_color=color.white, bgcolor=c2, text_size=size.small)
    table.cell(emaTable, 3, 1, " ",          text_color=color.white, bgcolor=bg,  text_size=size.small)
    table.cell(emaTable, 4, 1, " 200 EMA ", text_color=color.white, bgcolor=c3, text_size=size.small)

    // value row
    table.cell(emaTable, 0, 2, str.tostring(ema1, format.mintick), text_color=c1, bgcolor=bg, text_size=size.small)
    table.cell(emaTable, 1, 2, " ",                                 text_color=color.white, bgcolor=bg, text_size=size.small)
    table.cell(emaTable, 2, 2, str.tostring(ema2, format.mintick), text_color=c2, bgcolor=bg, text_size=size.small)
    table.cell(emaTable, 3, 2, " ",                                 text_color=color.white, bgcolor=bg, text_size=size.small)
    table.cell(emaTable, 4, 2, str.tostring(ema3, format.mintick), text_color=c3, bgcolor=bg, text_size=size.small)

// ── Optional right-edge labels ──
var label l1 = label.new(na, na, "")
var label l2 = label.new(na, na, "")
var label l3 = label.new(na, na, "")

if showLabels and barstate.islast
    label.delete(l1)
    label.delete(l2)
    label.delete(l3)
    l1 := label.new(bar_index + labelOffset, ema1, "9 EMA: "   + str.tostring(ema1, format.mintick),
         color=c1, textcolor=color.white, style=label.style_label_left, size=size.small)
    l2 := label.new(bar_index + labelOffset, ema2, "21 EMA: "  + str.tostring(ema2, format.mintick),
         color=c2, textcolor=color.white, style=label.style_label_left, size=size.small)
    l3 := label.new(bar_index + labelOffset, ema3, "200 EMA: " + str.tostring(ema3, format.mintick),
         color=c3, textcolor=color.white, style=label.style_label_left, size=size.small)

// ── 9/21 Crossover signals ──
bull = ta.crossover(ema1, ema2)
bear = ta.crossunder(ema1, ema2)

plotshape(showCross and bull, "Bullish Cross", shape.triangleup,
     location.belowbar, color.new(color.green, 0), size=size.tiny)
plotshape(showCross and bear, "Bearish Cross", shape.triangledown,
     location.abovebar, color.new(color.red, 0), size=size.tiny)

// ── Alerts ──
alertcondition(bull, "EMA 9 crosses above 21", "Bullish EMA cross")
alertcondition(bear, "EMA 9 crosses below 21", "Bearish EMA cross")
````
