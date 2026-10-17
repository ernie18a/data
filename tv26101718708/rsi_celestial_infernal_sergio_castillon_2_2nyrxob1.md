# rsi celestial / infernal ( sergio castillon ) 2 

- url: https://www.tradingview.com/script/2NYrxOb1/
- type: indicator
- pine_id: PUB;77c4c5685a2a4deaadb95c7c21a7f78e
- version: 1.0

## Description

niveles de sobre compra y venta extras .

no son infalibles hay que tener otras confirmaciones

## Source Code

````pine
//@version=5
indicator("RSI 50 Niveles PRO", overlay=false)

// RSI
rsiValue = ta.rsi(close, 50)

// Plot RSI
plot(rsiValue, title="RSI", color=color.white, linewidth=2)

// Niveles principales
hline(30, title="30", color=color.red, linewidth=2)
hline(35, title="35", color=color.new(color.red, 30))
hline(42.5, title="42.5", color=color.orange, linewidth=2)
hline(50, title="50", color=color.gray, linewidth=2)
hline(57.5, title="57.5", color=color.orange, linewidth=2)
hline(65, title="65", color=color.new(color.green, 30))
hline(70, title="70", color=color.green, linewidth=2)
````
