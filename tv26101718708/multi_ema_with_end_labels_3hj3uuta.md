# Multi EMA with End Labels

- url: https://www.tradingview.com/script/3hj3uUtA-Multi-EMA-with-End-Labels/
- type: indicator
- pine_id: PUB;ffb818d3463b4cd5b56715416ca25631
- version: 1.0

## Description

This indicator can plot multiple EMAs in a single indicator framework with an option for choice. To avoid confusion among line in busy moments, flags have been put at the end of EMAs

## Source Code

````pine
//@version=6
indicator("Multi EMA with End Labels", shorttitle="Multi EMA", overlay=true, max_labels_count=50)

// Source
src = input.source(close, "Source")

// Show / Hide Settings
showEMA200 = input.bool(true, "Show EMA 200")
showEMA100 = input.bool(true, "Show EMA 100")
showEMA50  = input.bool(true, "Show EMA 50")
showEMA21  = input.bool(true, "Show EMA 21")
showEMA14  = input.bool(true, "Show EMA 14")
showEMA9   = input.bool(true, "Show EMA 9")

// Color Settings
colorEMA200 = input.color(color.red, "EMA 200 Color")
colorEMA100 = input.color(color.orange, "EMA 100 Color")
colorEMA50  = input.color(color.blue, "EMA 50 Color")
colorEMA21  = input.color(color.green, "EMA 21 Color")
colorEMA14  = input.color(color.purple, "EMA 14 Color")
colorEMA9   = input.color(color.yellow, "EMA 9 Color")

// EMA Calculations
ema200 = ta.ema(src, 200)
ema100 = ta.ema(src, 100)
ema50  = ta.ema(src, 50)
ema21  = ta.ema(src, 21)
ema14  = ta.ema(src, 14)
ema9   = ta.ema(src, 9)

// Plot EMA Lines
plot(showEMA200 ? ema200 : na, title="EMA 200", color=colorEMA200, linewidth=2)
plot(showEMA100 ? ema100 : na, title="EMA 100", color=colorEMA100, linewidth=2)
plot(showEMA50  ? ema50  : na, title="EMA 50",  color=colorEMA50,  linewidth=2)
plot(showEMA21  ? ema21  : na, title="EMA 21",  color=colorEMA21,  linewidth=2)
plot(showEMA14  ? ema14  : na, title="EMA 14",  color=colorEMA14,  linewidth=2)
plot(showEMA9   ? ema9   : na, title="EMA 9",   color=colorEMA9,   linewidth=2)

// Label Variables
var label lbl200 = na
var label lbl100 = na
var label lbl50  = na
var label lbl21  = na
var label lbl14  = na
var label lbl9   = na

// Delete and recreate labels only on latest candle
if barstate.islast
    label.delete(lbl200)
    label.delete(lbl100)
    label.delete(lbl50)
    label.delete(lbl21)
    label.delete(lbl14)
    label.delete(lbl9)

    if showEMA200
        lbl200 := label.new(x=bar_index + 2, y=ema200, text="200", style=label.style_label_left, color=colorEMA200, textcolor=color.white, size=size.small)

    if showEMA100
        lbl100 := label.new(x=bar_index + 2, y=ema100, text="100", style=label.style_label_left, color=colorEMA100, textcolor=color.white, size=size.small)

    if showEMA50
        lbl50 := label.new(x=bar_index + 2, y=ema50, text="50", style=label.style_label_left, color=colorEMA50, textcolor=color.white, size=size.small)

    if showEMA21
        lbl21 := label.new(x=bar_index + 2, y=ema21, text="21", style=label.style_label_left, color=colorEMA21, textcolor=color.white, size=size.small)

    if showEMA14
        lbl14 := label.new(x=bar_index + 2, y=ema14, text="14", style=label.style_label_left, color=colorEMA14, textcolor=color.white, size=size.small)

    if showEMA9
        lbl9 := label.new(x=bar_index + 2, y=ema9, text="9", style=label.style_label_left, color=colorEMA9, textcolor=color.black, size=size.small)
````
