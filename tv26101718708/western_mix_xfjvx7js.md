# Western mix

- url: https://www.tradingview.com/script/XfJvX7jS/
- type: indicator
- pine_id: PUB;ec426c4349df4e8ca19f52dfe6550b7c
- version: 1.0

## Description

El indicador esta destinado a ensenar la diferentes etapas del mercado.

## Source Code

````pine
//@version=5
indicator("Etapas de Weinstein", overlay=true)

// Definimos las etapas de Weinstein
var color etapa1 = color.new(color.white, 0)
var color etapa2 = color.green
var color etapa3 = color.yellow
var color etapa4 = color.red

// Ejemplo de condiciones para las etapas (ajusta según tu criterio)
etapa1a = close < ta.sma(close, 30)
etapa2a = close > ta.sma(close, 30) and close < ta.sma(close, 10)
etapa3a = close > ta.sma(close, 10) and close < ta.sma(close, 5)
etapa4a = close > ta.sma(close, 5)

// Asignar colores según la etapa
bgcolor(etapa1a ? etapa1 : na, transp=50)
bgcolor(etapa2a ? etapa2 : na, transp=50)
bgcolor(etapa3a ? etapa3 : na, transp=50)
bgcolor(etapa4a ? etapa4 : na, transp=50)
````
