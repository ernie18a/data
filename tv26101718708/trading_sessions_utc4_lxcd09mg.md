# Trading Sessions (UTC-4)

- url: https://www.tradingview.com/script/lxCd09mG-Trading-Sessions-UTC-4/
- type: indicator
- pine_id: PUB;a3a16a9d69944cd4a010d77b81bd5c80
- version: 1.0

## Description

nothing too special just marking out your sessions in a clean way without any other add on.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © alextryngetupth3re

//@version=6
indicator("Trading Sessions (UTC-4)", overlay=true, max_boxes_count=500, max_labels_count=500)

asiaColor   = input.color(color.new(color.blue,   80), "Asia Color")
londonColor = input.color(color.new(color.orange, 80), "London Color")
nyColor     = input.color(color.new(color.green,  80), "New York Color")

showAsia   = input.bool(true, "Show Asia")
showLondon = input.bool(true, "Show London")
showNY     = input.bool(true, "Show New York")

asiaSession   = "0000-0700:1234567"
londonSession = "0700-1600:1234567"
nySession     = "1330-2000:1234567"

inAsia   = not na(time("1", asiaSession,   "UTC"))
inLondon = not na(time("1", londonSession, "UTC"))
inNY     = not na(time("1", nySession,     "UTC"))

asiaStart   = inAsia   and not inAsia[1]
londonStart = inLondon and not inLondon[1]
nyStart     = inNY     and not inNY[1]

var box asiaBox   = na
var box londonBox = na
var box nyBox     = na

if asiaStart and showAsia
    asiaBox := box.new(bar_index, high, bar_index, low, border_color=color.new(color.blue, 50), bgcolor=asiaColor)
    label.new(bar_index, high, "Asia", style=label.style_label_down, color=color.new(color.blue, 20), textcolor=color.white, size=size.small)

if inAsia and showAsia and not na(asiaBox)
    box.set_right(asiaBox, bar_index)
    box.set_top(asiaBox, math.max(high, box.get_top(asiaBox)))
    box.set_bottom(asiaBox, math.min(low, box.get_bottom(asiaBox)))

if londonStart and showLondon
    londonBox := box.new(bar_index, high, bar_index, low, border_color=color.new(color.orange, 50), bgcolor=londonColor)
    label.new(bar_index, high, "London", style=label.style_label_down, color=color.new(color.orange, 20), textcolor=color.white, size=size.small)

if inLondon and showLondon and not na(londonBox)
    box.set_right(londonBox, bar_index)
    box.set_top(londonBox, math.max(high, box.get_top(londonBox)))
    box.set_bottom(londonBox, math.min(low, box.get_bottom(londonBox)))

if nyStart and showNY
    nyBox := box.new(bar_index, high, bar_index, low, border_color=color.new(color.green, 50), bgcolor=nyColor)
    label.new(bar_index, high, "New York", style=label.style_label_down, color=color.new(color.green, 20), textcolor=color.white, size=size.small)

if inNY and showNY and not na(nyBox)
    box.set_right(nyBox, bar_index)
    box.set_top(nyBox, math.max(high, box.get_top(nyBox)))
    box.set_bottom(nyBox, math.min(low, box.get_bottom(nyBox)))
````
