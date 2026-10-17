# Fechamento fora da BB 3 Desvios

- url: https://www.tradingview.com/script/jwXnyC5f/
- type: indicator
- pine_id: PUB;3a30973c4ab1465fa9c78eedaac46fa2
- version: 1.0

## Description

Colore o candle que fecha fora da banda superior ou inferior de bollinger de 3 desvios sem a necessidade de deixar as bandas plotadas no gráfico poluindo o layout.

## Source Code

````pine
//@version=5
indicator("Fechamento fora da BB 3σ", overlay=true)

length = input.int(20, "Período BB", minval=1)
src    = input.source(close, "Fonte")

basis  = ta.sma(src, length)
dev    = ta.stdev(src, length)
upper3 = basis + 3 * dev
lower3 = basis - 3 * dev

fechou_acima  = close > upper3
fechou_abaixo = close < lower3
fora_da_banda = fechou_acima or fechou_abaixo

cor_candle = fechou_acima  ? color.new(color.blue, 0) :
             fechou_abaixo ? color.new(color.red, 0) :
             na

barcolor(cor_candle)

plotshape(fechou_acima,  title="Acima 3σ", style=shape.triangledown,
          location=location.abovebar, color=color.blue, size=size.tiny)
plotshape(fechou_abaixo, title="Abaixo 3σ", style=shape.triangleup,
          location=location.belowbar, color=color.red, size=size.tiny)

alertcondition(fora_da_banda, "Fechamento fora da BB 3σ",
               "Candle fechou fora da Banda de Bollinger 3σ!")
````
