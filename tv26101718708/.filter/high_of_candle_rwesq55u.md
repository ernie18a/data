# High of Candle

- url: https://www.tradingview.com/script/Rwesq55u/
- type: indicator
- pine_id: PUB;9000364433b041199431f99cbb0e7c35
- version: 1.0

## Description

This indicator displays the current day’s high as a clean floating label positioned to the upper-right of the latest candle, connected by a pointer line for easy visualization.

Designed for traders who want to monitor the intraday high without cluttering moving averages or price action, the label automatically updates in real time as new highs are made throughout the session.

## Source Code

````pine
//@version=5
indicator("High of Candle", overlay=true)

var label lbl = na
var line seta = na
var float maximaDia = na

novoDia = ta.change(time("D"))

if novoDia or na(maximaDia)
    maximaDia := high
else
    maximaDia := math.max(maximaDia, high)

// ajustes
deslocamentoDireita = 2
deslocamentoVertical = maximaDia * 0.006

x1 = bar_index
y1 = maximaDia
x2 = bar_index + deslocamentoDireita
y2 = maximaDia + deslocamentoVertical

if barstate.islast
    label.delete(lbl)
    line.delete(seta)

    seta := line.new(x1, y1, x2, y2, color=color.green, width=2)

    lbl := label.new(
     x2,
     y2,
     str.tostring(maximaDia, format.mintick),
     style=label.style_label_left,
     color=color.green,
     textcolor=color.white,
     size=size.normal
 )
````
