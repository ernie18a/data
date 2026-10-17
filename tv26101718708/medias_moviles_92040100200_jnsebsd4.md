# Medias Moviles 9,20,40,100,200

- url: https://www.tradingview.com/script/jnsEBSD4/
- type: indicator
- pine_id: PUB;3cbd96fdcca340c2ac21a4ca0333eb15
- version: 1.0

## Description

Velas Intensas + 5 Medias Móviles de 9 de 20 de 40 de 100 y de 200 todas en uno solo indicador

## Source Code

````pine
//@version=6
indicator("Velas Intensas + 5 Medias Móviles", overlay=true)

// =====================
// COLORES DE VELAS
// =====================
colorAlcista = color.rgb(0, 255, 0)     // Verde intenso
colorBajista = color.rgb(188, 0, 0)     // Rojo intenso

esAlcista = close >= open

// Pintar velas (cuerpo, mecha y borde)
plotcandle(
    open, high, low, close,
    color = esAlcista ? colorAlcista : colorBajista,
    wickcolor = esAlcista ? colorAlcista : colorBajista,
    bordercolor = esAlcista ? colorAlcista : colorBajista
)

// =====================
// MEDIAS MÓVILES
// =====================
ma200 = ta.sma(close, 200)
ma100 = ta.sma(close, 100)
ma40  = ta.sma(close, 40)
ma20  = ta.sma(close, 20)
ma9   = ta.sma(close, 9)

// =====================
// PLOTEO
// =====================
plot(ma200, color=color.rgb(140, 0, 255), linewidth=2, title="MA 200 (Violeta)")
plot(ma100, color=color.rgb(0, 200, 0), linewidth=2, title="MA 100 (Verde)")
plot(ma40,  color=color.rgb(255, 0, 0), linewidth=2, title="MA 40 (Rojo)")
plot(ma20,  color=color.rgb(255, 255, 0), linewidth=2, title="MA 20 (Amarillo)")
plot(ma9,   color=color.rgb(0, 0, 0), linewidth=2, title="MA 9 (Negro)")
````
