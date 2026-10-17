# IFR2 - RSI2

- url: https://www.tradingview.com/script/n1e8MLFl-IFR2-RSI2/
- type: strategy
- pine_id: PUB;dDJzRmyhHHAbQa0Lm3Qun0CsNwYrjtIQ
- version: 1.0

## Description

When the price is over the EMA and RSI 2 is less then 25 so an open order is going to be made and the strike is the high of the antepenultimate price

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © jocker.soad

//@version=4
strategy("My Script", overlay=true, initial_capital=10000, default_qty_value=100)
min = input(title="Valor minimo de entrada", defval=25)
qtdAtivos = input(title="Quantidade de ações", defval=200)

// overBuyLine = hline(80)
// overSellLine = hline(min)

var comprado = false
var valorComprado = 0.0
var qtdDiasComprado = 0
var valorLucro = 0.0

valueRsi = rsi(close, 2)
valueSma = sma(close, 200)
valueEma = ema(close, 200)
lastHighPrice = high[2]

buyValidation = valueRsi <= min
sellValidation = close >= lastHighPrice



// plot(lastHighPrice, trackprice=true, offset=-99999, color=color.olive, linewidth=3, style=plot.style_area)
// plot(valueRsi)
// plot(valueSma)
// plot(valueEma)
// plotshape(sellValidation, style=shape.triangledown, color=color.blue)
// plotshape(comprado, style=shape.triangledown, color=color.blue)

startDate = input(title="Inicio Dia", type=input.integer, defval=1, minval=1, maxval=31)
startMonth = input(title="Inicio Mes", type=input.integer, defval=1, minval=1, maxval=12)
startYear = input(title="Inicio Ano", type=input.integer, defval=2018, minval=1800, maxval=2100)

endDate = input(title="Final Dia", type=input.integer, defval=1, minval=1, maxval=31)
endMonth = input(title="Final Mes", type=input.integer, defval=12, minval=1, maxval=12)
endYear = input(title="Final Ano", type=input.integer,  defval=2020, minval=1800, maxval=2100)

inDateRange = (time >= timestamp(syminfo.timezone, startYear, startMonth, startDate, 0, 0)) and (time < timestamp(syminfo.timezone, endYear, endMonth, endDate, 0, 0))

if inDateRange

    if close >= valueEma
    
        if comprado == false and buyValidation
            qtdDiasComprado := 0
            comprado := true
            valorComprado := close
            strategy.order("buy", true, qtdAtivos, when=buyValidation)
        
        if sellValidation and comprado == true
            comprado := false
            valorLucro := valorLucro + (close - valorComprado)
            valorComprado := 0
            strategy.order("sell", false, qtdAtivos, when=sellValidation)
        
        if comprado == true and sellValidation == false
            qtdDiasComprado := qtdDiasComprado + 1

// plot(valorLucro, color=color.lime)
````
