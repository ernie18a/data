# ATSS Pip Height

- url: https://www.tradingview.com/script/I6YJFzRv-ATSS-Pip-Height/
- type: indicator
- pine_id: PUB;fa6d54643ee447459deae2f7e533bd50
- version: 1.0

## Description

Simple minimalist "indicator" to show the movement of last candle as Open-Close and High-Low in brackets.
Saves estimation from price scale or manual drawing on screen to measure.

## Source Code

````pine
//@version=6
indicator("ATSS Pip Height", overlay=true)

pip = syminfo.type == "forex" ? syminfo.mintick * 10 : syminfo.mintick

oc = math.abs(close[1] - open[1]) / pip
hl = math.abs(high[1] - low[1]) / pip

txt = str.tostring(oc, "#.#") + "\n(" + str.tostring(hl, "#.#") + ")"
col = close[1] > open[1] ? color.green : color.red

offset = (high[1] - low[1]) * 10.0

var label lastLabel = na

if barstate.islast and bar_index > 0
    label.delete(lastLabel)
    lastLabel := label.new(
         bar_index[1],
         high[1] + offset,
         txt,
         style=label.style_none,
         textcolor=col,
         size=size.normal
     )
````
