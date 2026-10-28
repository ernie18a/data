# Mean Reversion Strategy by KrisWaters

- url: https://www.tradingview.com/script/30AJfvAa-Mean-Reversion-Strategy-by-KrisWaters/
- type: strategy
- pine_id: PUB;3pfvAh8BpsmL2N4MQVk8Jiq3s4QKa3ft
- version: 1.0

## Description

This is a type of mean reversion strategy. It only generates long signals when the price is far away from the mean. It tries buy from the dip. Use it with BTC/USDT pair on 4 hour timeframe.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © kriswaters

//@version=4 
strategy("Mean Reversion Strategy by KrisWaters",overlay=false,precision=8,pyramiding=0,default_qty_type=strategy.percent_of_equity,default_qty_value=100,currency='USD',commission_type= strategy.commission.percent,commission_value=0.075,initial_capital=1000)

maPeriod = input(defval=6,title="SMA Period")
dropRate = input(defval=1,title="Drop Rate",type=input.float,step=0.1)
rateOfChange = (change(close)/close)*100
changeMovAvg = sma(rateOfChange,maPeriod)

//#### CONDITIONS ####
if changeMovAvg > changeMovAvg[1] and changeMovAvg[1] < (-1)*dropRate and volume[1] < volume and strategy.position_size == 0
    strategy.entry("buy",strategy.long)
    
if changeMovAvg > 0  and volume[1] > volume and strategy.position_size > 0
    strategy.close("buy")

//#### PLOTS ####
plot(changeMovAvg,linewidth=3,color=changeMovAvg > 0 ? color.green : color.red,style=plot.style_columns,transp=0)
plot(0,linewidth=3,color=color.black)
plot(-1*dropRate,linewidth=3,color=color.red,style=plot.style_line)
````
