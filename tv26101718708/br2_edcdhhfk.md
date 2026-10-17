# BR2

- url: https://www.tradingview.com/script/EDcdHhfk/
- type: indicator
- pine_id: PUB;aa010b7f7c874c20816bce5e6e7db69f
- version: 1.0

## Description

Small caps gaps in the shart, it is very well - This indicator helps to know the % value of the gap of the penny stock or small caps action

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © digitalstoun

//@version=6
indicator("BR1", overlay = true)
minGapPositivo = input.int(defval = 20, title= "valor minimo de Gap Positivo", minval=20)
minGapNegativo = input.int(defval = 10, title= "valor minimo de Gap Negativo", minval=10)

var label labelGap = na
var label InfodeGap = na

var int NumerodeGapsPositivos = 0
var int NumerodeGapsNegativos = 0
var int NumerodeGapsPositivosRojo = 0
var int NumerodeGapsNegativosRojo = 0

gap = (open[0] - close[1]) * 100 / close[1]

colorColumna = open[0] < close[1] ? color.red : color.green

textoGap = str.tostring(gap, "0.0")
if gap >= minGapPositivo or gap <= -minGapNegativo
    labelGap := label.new(bar_index, high * 1.05, textoGap, force_overlay = true, color = colorColumna)
    if gap > 0
        NumerodeGapsPositivos := NumerodeGapsPositivos +1
        if close < open 
            NumerodeGapsPositivosRojo := NumerodeGapsPositivosRojo + 1
    else
        NumerodeGapsNegativos := NumerodeGapsNegativos + 1
        if close < open 
            NumerodeGapsNegativosRojo := NumerodeGapsNegativosRojo + 1

if barstate.islast and (barstate.isnew or not barstate.isconfirmed)

    if timeframe.period == "1D"
        labelGap.delete()
        TextoGapsPoitivos = str.tostring(NumerodeGapsPositivos)
        TextoGapsNegativos = str.tostring(NumerodeGapsNegativos)
        TextoGapsPoitivosRojo = str.tostring(NumerodeGapsPositivosRojo)
        TextoGapsNegativosRojo = str.tostring(NumerodeGapsNegativosRojo)

        labelGap := label.new(bar_index + 5, 12,  "Positivos: " + TextoGapsPoitivos + " ( rojo = " + TextoGapsPoitivosRojo + ")\n" + " Negativos: " + TextoGapsNegativos +"(rojo = " + TextoGapsNegativosRojo + ") ")
````
