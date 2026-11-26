# Table of information stock

- url: https://www.tradingview.com/script/QPKd9dK7/
- type: indicator
- pine_id: PUB;496c18fdae5442d293cd201ecd0af633
- version: 1.0

## Description

A table of contents for stocks is presented, which provides important data information about them.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © digitalstoun

//@version=6
indicator("BR1", overlay = true)
minGapPositivo = input.int(defval = 20, title= "valor minimo de Gap Positivo", minval=20)
minGapNegativo = input.int(defval = 10, title= "valor minimo de Gap Negativo", minval=10)

var label labelGap = na
var table InfoTable = na

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
        
        InfoTable.delete()
        
        TextoGapsPoitivosRojo = str.tostring(NumerodeGapsPositivosRojo)
        TextoGapsNegativosRojo = str.tostring(NumerodeGapsNegativosRojo)
        TextoGapsPoitivosRojoPorc = str.tostring(NumerodeGapsPositivosRojo*100 / NumerodeGapsPositivos, "0.0")
        TextoGapsNegativosRojoPorc = str.tostring(NumerodeGapsNegativosRojo*100 / NumerodeGapsNegativos, "0.0")
        TextoGapsPoitivos = str.tostring(NumerodeGapsPositivos) + ", Rojos = " + TextoGapsPoitivosRojo + " (" + TextoGapsPoitivosRojoPorc +" %)"
        TextoGapsNegativos = str.tostring(NumerodeGapsNegativos)+ ", Rojos = " + TextoGapsNegativosRojo + " (" + TextoGapsNegativosRojoPorc +" %)"


        Shares = request.financial(syminfo.tickerid, "TOTAL_SHARES_OUTSTANDING", "FQ") / 1000000
        MarketCap = Shares * close
        TextoShares = str.tostring(Shares, "0.00") + "M"
        TextoMarketCap = str.tostring(MarketCap, "0.00") + "M"
        FloatShares = syminfo.shares_outstanding_float / 1000000
        TextoFloatShares = str.tostring(FloatShares, "0.00") + "M"
        VolumenMillones = volume / 1000000
        TextoVolumenMillones = str.tostring(VolumenMillones,"0.00" ) + "M"
        InfoTicket = syminfo.industry
        Rotacion = VolumenMillones / FloatShares
        TextRotacion = str.tostring(Rotacion, "0.0")


        InfoTable := table.new(position.top_right, columns = 2, rows = 7, bgcolor = color.white, frame_color = color.green, border_width = 2, frame_width = 3, border_color = color.green)
        table.cell(InfoTable, 0 , 0, "Gap Positivos")
        table.cell(InfoTable, 0 , 1, "Gap Negativos")
        table.cell(InfoTable, 0 , 2, "Shares")
        table.cell(InfoTable, 0 , 3, "Float")
        table.cell(InfoTable, 0 , 4, "Market Cap")
        table.cell(InfoTable, 0 , 5, "Volumen")
        table.cell(InfoTable, 0 , 6, "I.Ticket")
        table.cell(InfoTable, 1 , 0, TextoGapsPoitivos)
        table.cell(InfoTable, 1 , 1, TextoGapsNegativos)
        table.cell(InfoTable, 1 , 2, TextoShares)
        table.cell(InfoTable, 1 , 3, TextoFloatShares)
        table.cell(InfoTable, 1 , 4, TextoMarketCap)
        table.cell(InfoTable, 1 , 5, TextoVolumenMillones  + "(X"+ TextRotacion + ") ")
        table.cell(InfoTable, 1 , 6, InfoTicket)
````
