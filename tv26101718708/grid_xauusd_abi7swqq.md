# Grid XAUUSD

- url: https://www.tradingview.com/script/aBi7SwQQ/
- type: indicator
- pine_id: PUB;2635ddd9310841bb90f5b879cffa6060
- version: 1.0

## Description

Grid XAUUSD quiero poner en trading view lineas en mi grafico de xauusd, ejemplo en 4185, la siguiente en 4195 y asi sumando de 10 en 10

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © magdalenareig

//@version=6
//indicator("Mi script")
//plot(close)

//@version=5
indicator("Grid XAUUSD", overlay=true)

startPrice = input.float(4185, "Precio inicial")
step       = input.float(10, "Distancia")
numLines   = input.int(30, "Número líneas")

for i = 0 to numLines - 1
    level = startPrice + (i * step)
    line.new(
         bar_index[1], level,
         bar_index, level,
         extend=extend.both,
         color=color.new(color.gray, 70)
     )
````
