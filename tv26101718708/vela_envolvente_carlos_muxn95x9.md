# Vela Envolvente Carlos

- url: https://www.tradingview.com/script/Muxn95x9/
- type: indicator
- pine_id: PUB;2e80483e7dee4e4cbf7a699e38abee4a
- version: 1.0

## Description

Este es el indicador que me ayuda a confirmar mis entradas

## Source Code

````pine
//@version=6
indicator("Vela Envolvente", overlay = true)
// =======================
// INPUT
// =======================
toleranciaMecha = input.float(
     30.0,
     title = "Máx % Mecha Permitida vs Cuerpo",
     minval = 0,
     maxval = 100,
     step = 1)
// =======================
// CALCULOS
// =======================
cuerpo = math.abs(close - open)
cuerpoValido = cuerpo > 0
mechaSuperior = high - math.max(open, close)
mechaInferior = math.min(open, close) - low
maxMecha = cuerpo * (toleranciaMecha / 100)
// =======================
// MOMENTUM ALCISTA
// =======================
velaAlcista = (
    cuerpoValido and
    close > open and
    cuerpo > mechaSuperior and
    mechaSuperior <= maxMecha
)
// =======================
// MOMENTUM BAJISTA
// =======================
velaBajista = (
    cuerpoValido and
    close < open and
    cuerpo > mechaInferior and
    mechaInferior <= maxMecha
)
// =======================
// COLOR TIEMPO REAL
// =======================
colorFinal =
     velaAlcista ? color.lime :
     velaBajista ? color.red :
     na
barcolor(colorFinal)
// =======================
// ALERTAS
// =======================
alertcondition(
    velaAlcista,
    title="Momentum Alcista",
    message="Vela Momentum Alcista Detectada"
)
alertcondition(
    velaBajista,
    title="Momentum Bajista",
    message="Vela Momentum Bajista Detectada"
)
````
