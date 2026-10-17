# T3 + RSI ZigZag + S/R + MA 

- url: https://www.tradingview.com/script/b3K1Y1AG/
- type: indicator
- pine_id: PUB;0e2797e970a34ed7af44ed9aab177208
- version: 1.0

## Description

This was done for testing purposes; it's for those who develop the code and benefit from it.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © GLRSMEER

//@version=6
indicator("T3 + RSI ZigZag + S/R + MA ", overlay=true, max_bars_back=5000)

//====================================================
// T3
//====================================================
len1 = input.int(8, "T3 Length")
a1 = input.float(0.7, "Factor")

src = (high + low + 2 * close) / 4

e1 = ta.ema(src, len1)
e2 = ta.ema(e1, len1)
e3 = ta.ema(e2, len1)
e4 = ta.ema(e3, len1)
e5 = ta.ema(e4, len1)
e6 = ta.ema(e5, len1)

c1 = -a1 * a1 * a1
c2 = 3 * a1 * a1 + 3 * a1 * a1 * a1
c3 = -6 * a1 * a1 - 3 * a1 - 3 * a1 * a1 * a1
c4 = 1 + 3 * a1 + a1 * a1 * a1 + 3 * a1 * a1

T3 = c1 * e6 + c2 * e5 + c3 * e4 + c4 * e3

plot(T3, color=T3 > T3[1] ? color.green : color.red, linewidth=3)

//====================================================
// MOVING AVERAGES (20 / 50 / 200 EMA)
//====================================================
showMA = input.bool(true, "Show Moving Averages")

ma20  = ta.ema(close, 20)
ma50  = ta.ema(close, 50)
ma200 = ta.ema(close, 200)

plot(showMA ? ma20 : na,  color=color.orange, linewidth=2, title="EMA 20")
plot(showMA ? ma50 : na,  color=color.blue,   linewidth=2, title="EMA 50")
plot(showMA ? ma200 : na, color=color.purple, linewidth=3, title="EMA 200")

//====================================================
// RSI
//====================================================
rsiLen = input.int(7, "RSI Length")
ob = input.int(70)
os = input.int(30)

rsi = ta.rsi(close, rsiLen)

isOB = rsi >= ob
isOS = rsi <= os

//====================================================
// ZIGZAG SETTINGS
//====================================================
zigWidth = input.int(2, "ZigZag Width", minval=1, maxval=5)

zigUpColor = input.color(color.red, "ZigZag Down")
zigDownColor = input.color(color.lime, "ZigZag Up")

zigStyleInput = input.string("Solid", "ZigZag Style", options=["Solid", "Dashed", "Dotted"])

zigStyle =
     zigStyleInput == "Solid" ? line.style_solid :
     zigStyleInput == "Dashed" ? line.style_dashed :
     line.style_dotted

//====================================================
// SUPPORT / RESISTANCE
//====================================================
showSR = input.bool(true, "Show S/R")
srWidth = input.int(2, "S/R Line Width", minval=1, maxval=5)

srStyleInput = input.string("Dashed", "S/R Style",
     options=["Solid", "Dashed", "Dotted"])

srStyle =
     srStyleInput == "Solid" ? line.style_solid :
     srStyleInput == "Dashed" ? line.style_dashed :
     line.style_dotted

resColor = input.color(color.red, "Resistance Color")
supColor = input.color(color.green, "Support Color")

pivotL = input.int(5)
pivotR = input.int(5)

//====================================================
// S/R LINES
//====================================================
ph = ta.pivothigh(high, pivotL, pivotR)
pl = ta.pivotlow(low, pivotL, pivotR)

if showSR and not na(ph)
    line.new(bar_index - pivotR, high[pivotR],
         bar_index + 20, high[pivotR],
         color=resColor, width=srWidth, style=srStyle)

if showSR and not na(pl)
    line.new(bar_index - pivotR, low[pivotR],
         bar_index + 20, low[pivotR],
         color=supColor, width=srWidth, style=srStyle)

//====================================================
// RSI ZIGZAG (FIXED HIGH/LOW STRUCTURE)
//====================================================

// direction: 1 up, -1 down
var dir = 0

var float swingHigh = na
var float swingLow = na
var int swingHighBar = na
var int swingLowBar = na

var float lastPrice = na
var int lastBar = na

// UPDATE SWINGS
if isOB
    if dir != 1
        dir := 1
        swingHigh := high
        swingHighBar := bar_index
    else
        if high > swingHigh
            swingHigh := high
            swingHighBar := bar_index

if isOS
    if dir != -1
        dir := -1
        swingLow := low
        swingLowBar := bar_index
    else
        if low < swingLow
            swingLow := low
            swingLowBar := bar_index

//====================================================
// DRAW HIGH PIVOT
//====================================================
if dir == -1 and not na(swingHigh)
    label.new(swingHighBar, swingHigh, "H",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white)

    if not na(lastPrice)
        line.new(lastBar, lastPrice,
                 swingHighBar, swingHigh,
                 color=zigUpColor,
                 width=zigWidth,
                 style=zigStyle)

    lastPrice := swingHigh
    lastBar := swingHighBar
    swingHigh := na

//====================================================
// DRAW LOW PIVOT
//====================================================
if dir == 1 and not na(swingLow)
    label.new(swingLowBar, swingLow, "L",
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white)

    if not na(lastPrice)
        line.new(lastBar, lastPrice,
                 swingLowBar, swingLow,
                 color=zigDownColor,
                 width=zigWidth,
                 style=zigStyle)

    lastPrice := swingLow
    lastBar := swingLowBar
    swingLow := na
````
