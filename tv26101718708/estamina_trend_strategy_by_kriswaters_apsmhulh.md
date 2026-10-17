# Estamina Trend Strategy By KrisWaters

- url: https://www.tradingview.com/script/ApSMHuLH-Estamina-Trend-Strategy-By-KrisWaters/
- type: strategy
- pine_id: PUB;4HSVJvgdvjOFpfp86ZtwGOORoDN5VUbb
- version: 1.0

## Description

Trend following strategy based on moving avarage crossovers. Strategy provides only long signals. Use only for BTCUSDT pair on 4H timeframe.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © kriswaters

//@version=4
strategy("Estamina Trend Strategy By KrisWaters",overlay=true,precision=8,pyramiding=0,default_qty_type=strategy.percent_of_equity,default_qty_value=100,currency='USD',commission_type= strategy.commission.percent,commission_value=0.075,initial_capital=1000) 

fastMaPeriod = input(4,title="fastMaPeriod")
smoothedMaPeriod = input(8,title="smoothedMaPeriod")
slowMaPeriod = input(15,title="slowMaPeriod")

fastMaValue = sma(close,fastMaPeriod)
smoothedMaValue = 0.0
smoothedMaValue := na(smoothedMaValue[1]) ? sma(close, smoothedMaPeriod) : (smoothedMaValue[1] * (smoothedMaPeriod - 1) + close) / smoothedMaPeriod
slowMaValue = sma(close,slowMaPeriod)

plot(fastMaValue,title="Fast MA Value",color=color.purple,linewidth=3)
plot(smoothedMaValue,title="Smoothed MA Value",color=color.orange,linewidth=3)
plot(slowMaValue,title="Slow MA Value",color=color.green,linewidth=3)

if fastMaValue > smoothedMaValue and fastMaValue > slowMaValue
    strategy.entry("long",strategy.long)

if crossunder(fastMaValue,smoothedMaValue) or crossunder(fastMaValue,slowMaValue)
    strategy.close("long")
````
