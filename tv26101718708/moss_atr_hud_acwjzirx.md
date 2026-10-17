# Moss ATR HUD

- url: https://www.tradingview.com/script/acwjzIRx/
- type: indicator
- pine_id: PUB;64a1134276d641f49f3ee009489dc04e
- version: 1.0

## Description

[b]Developer: Morisa Studio[/b]

Moss ATR HUD is a minimalist ATR display designed for traders who value clarity over complexity.

Instead of drawing additional lines or panels, it presents the current ATR value and its percentage relative to the current price in a clean, single-line HUD fixed to the bottom-right corner of the chart.

[b]Features[/b]
[list]
[*]Clean one-line ATR display
[*]Current ATR value with customizable multiplier
[*]ATR percentage relative to the current price
[*]Adjustable ATR length
[*]Customizable text color
[*]Adjustable font size
[*]Transparent background with minimal visual footprint
[*]Overlay design that stays out of the way of price action
[/list]
Designed with a [b]"Less, but Better"[/b] philosophy, Moss ATR HUD provides essential volatility information at a glance without adding unnecessary visual noise to your charts.

## Source Code

````pine
//@version=6
indicator("Moss ATR HUD", overlay = true)

len  = input.int(14, "Length", minval = 1)
mult = input.float(1.0, "Multiplier", step = 0.1)
clr  = input.color(color.white, "Color")
sizeInput = input.string("Normal", "Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"])

txtSize = switch sizeInput
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Large"  => size.large
    "Huge"   => size.huge
    => size.normal

atr = ta.atr(len)
value = atr * mult
pct = value / close * 100

var table hud = table.new(position.bottom_right, 1, 1)

table.cell(
     hud,
     0,
     0,
     "ATR   " +
     str.tostring(value, "#.##") +
     "｜" +
     str.tostring(pct, "#.##") + "%",
     text_color = clr,
     text_size = txtSize,
     bgcolor = na
)
````
