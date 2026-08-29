<!-- tradingview-pine-id: PUB;e89834aef8fe4c62abab198f6c5e35fd -->
<!-- tradingviewscripts-format: 1 -->
# MNQ Calculator

Source: https://www.tradingview.com/script/Nkwa4l0N/

## Description

Calculate the take-profit points for your desired profit, taking into account the contracts used to enter the trade and the entry price.

---

## Source Code

````pine
//@version=6
indicator("MNQ Calculator", overlay=true)

// Entradas
contracts = input.int(1, "Contratos", minval=1)
targetProfit = input.float(1000, "Ganancia deseada ($)", step=1)
entryPrice = input.float(22000, "Precio de entrada", step=0.25)
isLong = input.bool(true, "Operación Long")

// Constante MNQ
pointValue = 2.0

// Cálculos
pointsNeeded = targetProfit / (contracts * pointValue)
tpPrice = isLong ? entryPrice + pointsNeeded : entryPrice - pointsNeeded

// Mostrar línea TP
plot(tpPrice, title="Take Profit", color=color.green, linewidth=2)

// Etiqueta
var label tpLabel = na

if barstate.islast
    label.delete(tpLabel)
    tpLabel := label.new(
         bar_index,
         tpPrice,
         "TP\n" +
         "Puntos: " + str.tostring(pointsNeeded, "#.##") +
         "\nPrecio: " + str.tostring(tpPrice, "#.00"),
         style=label.style_label_left,
         color=color.green,
         textcolor=color.white
    )
````
