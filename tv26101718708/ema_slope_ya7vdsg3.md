# EMA Slope %

- url: https://www.tradingview.com/script/YA7vDsG3-EMA-Slope/
- type: indicator
- pine_id: PUB;263af90db8424d7d8caf1684dddaaf88
- version: 2.0

## Description

Measures the bar-over-bar percentage change of an EMA. Positive values indicate upward momentum, negative values indicate decline. Zero-line crossovers can signal early trend reversals.

## Source Code

````pine
//@version=6
// Description: Measures the bar-over-bar percentage change of one or more EMAs.
// Positive values indicate upward momentum, negative values indicate decline.
// Zero-line crossovers can signal early trend reversals.
indicator("EMA Slope %", overlay=false)

// EMA 1
ema1_enabled = input.bool(true, "EMA 1", inline="ema1")
ema1_length  = input.int(50,   "",      inline="ema1", minval=1)
ema1_color   = input.color(color.blue,  "",            inline="ema1")

// EMA 2
ema2_enabled = input.bool(false, "EMA 2", inline="ema2")
ema2_length  = input.int(110,    "",       inline="ema2", minval=1)
ema2_color   = input.color(color.orange, "",            inline="ema2")

// EMA 3
ema3_enabled = input.bool(false, "EMA 3", inline="ema3")
ema3_length  = input.int(290,   "",       inline="ema3", minval=1)
ema3_color   = input.color(color.purple, "",            inline="ema3")

ema_slope(length) =>
    ema_val = ta.ema(close, length)
    (ema_val - ema_val[1]) / ema_val[1] * 100

slope1 = ema_slope(ema1_length)
slope2 = ema_slope(ema2_length)
slope3 = ema_slope(ema3_length)

plot(ema1_enabled ? slope1 : na, "EMA 1 Slope %", color=ema1_color, linewidth=2)
plot(ema2_enabled ? slope2 : na, "EMA 2 Slope %", color=ema2_color, linewidth=2)
plot(ema3_enabled ? slope3 : na, "EMA 3 Slope %", color=ema3_color, linewidth=2)

hline(0, "Zero", color=color.gray, linestyle=hline.style_dotted)

var label lbl1 = na
var label lbl2 = na
var label lbl3 = na
if barstate.islast
    if ema1_enabled
        if not na(lbl1)
            label.delete(lbl1)
        lbl1 := label.new(bar_index, slope1, "EMA" + str.tostring(ema1_length) + ": " + str.tostring(slope1, "#.####") + "%", style=label.style_label_left, color=ema1_color, textcolor=color.white, size=size.small)
    if ema2_enabled
        if not na(lbl2)
            label.delete(lbl2)
        lbl2 := label.new(bar_index, slope2, "EMA" + str.tostring(ema2_length) + ": " + str.tostring(slope2, "#.####") + "%", style=label.style_label_left, color=ema2_color, textcolor=color.white, size=size.small)
    if ema3_enabled
        if not na(lbl3)
            label.delete(lbl3)
        lbl3 := label.new(bar_index, slope3, "EMA" + str.tostring(ema3_length) + ": " + str.tostring(slope3, "#.####") + "%", style=label.style_label_left, color=ema3_color, textcolor=color.white, size=size.small)
````
