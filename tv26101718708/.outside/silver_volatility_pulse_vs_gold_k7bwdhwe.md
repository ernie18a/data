# Silver Volatility Pulse vs Gold

- url: https://www.tradingview.com/script/k7BWDHWE-Silver-Volatility-Pulse-vs-Gold/
- type: indicator
- pine_id: PUB;0725dc077b024d1da8235168b1efcfad
- version: 1.0

## Description

Silver Volatility Pulse vs Gold

When is silver acting normal
and when is it moving out of character?

This indicator compares silver’s volatility with gold’s normal volatility relationship

Blue bars mean silver is moving with extra force versus gold
Grey bars mean silver is moving quieter than usual versus gold

It is not a direction signal
It is a behavior signal

It helps show whether silver is calming down
or starting to move out of character again

## Source Code

````pine
//@version=6
// Silver Volatility Pulse vs Gold
// Created by Curious | Macro Lens, @CuriousMacroX

indicator("Silver Volatility Pulse vs Gold", overlay=false)

lookback = input.int(20, "Volatility lookback")
smooth = input.int(50, "Normal relationship lookback")

goldSymbol = input.symbol("OANDA:XAUUSD", "Gold")
silverSymbol = input.symbol("OANDA:XAGUSD", "Silver")

goldClose = request.security(goldSymbol, timeframe.period, close)
silverClose = request.security(silverSymbol, timeframe.period, close)

goldReturn = math.log(goldClose / goldClose[1])
silverReturn = math.log(silverClose / silverClose[1])

goldVol = ta.stdev(goldReturn, lookback) * math.sqrt(252) * 100
silverVol = ta.stdev(silverReturn, lookback) * math.sqrt(252) * 100

relativeVol = silverVol / goldVol
normalRelationship = ta.sma(relativeVol, smooth)

pulse = ((relativeVol / normalRelationship) - 1) * 100

barColor = pulse >= 0 ? color.rgb(41, 98, 255) : color.rgb(170, 170, 170)

plot(pulse, "Silver volatility pulse vs gold", style=plot.style_columns, color=barColor)
hline(0, "Normal relationship", color=color.gray, linestyle=hline.style_dashed)
````
