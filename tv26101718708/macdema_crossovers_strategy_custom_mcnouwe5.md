# MACD+EMA crossovers Strategy custom

- url: https://www.tradingview.com/script/mCNOuWe5/
- type: strategy
- pine_id: PUB;FC1axF5oXxaBbl0PMX9bs0esLmkjueIP
- version: 1.0

## Description

It is a Strategy to use EMA crossover and MACD to decide when "buy" and when "sell", the key is spend some time "tuning" the parameters and using the simulation tool to find the best parameters for EMA and MACD there are 6 parameters, but with Excel and patience you could find the best configuration for the past and apply it to the future and see.

## Source Code

````pine

strategy("MACD+EMA crossovers Strategy custom",initial_capital=10000,max_bars_back=150,commission_type=strategy.commission.percent , commission_value=0.1, shorttitle="MACD+EMAcross",pyramiding = 10,default_qty_type=strategy.percent_of_equity,default_qty_value=33,overlay=false)

short = ema(close,3)
long = ema(close, 11)
long2 = ema(close, 18)
//plot(short, color = red, linewidth = 4)
//plot(long, color = blue, linewidth = 4)
//plot(long2, color = green, linewidth = 4)

isCross1 = crossover(short, long)
isCross2 = crossover(short, long2)
isCrossSell = crossunder(short, long)
//isCross3 = crossover(long, long2)

//plotshape(isCross1 and not isCross2, color=lime, style=shape.arrowup, text="1st in",size = size.tiny, location = location.belowbar)
//plotshape(isCross2 , color=lime, style=shape.arrowup, text="2nd in",size = size.tiny, location = location.belowbar)

//plotshape(isCross3 , color=lime, style=shape.arrowdown, text="All in",size = size.normal, location = location.abovebar)

//plotshape(isCrossSell , color=red, style=shape.arrowdown, text="SELL",size = size.small, location = location.abovebar)

fastLength = input(3)
slowlength = input(11)
MACDLength = input(27)

MACD = ema(close, fastLength) - ema(close, slowlength)
aMACD = ema(MACD, MACDLength) //signal
delta = MACD - aMACD // histograma

strategy.entry("MacdLE 1st in", strategy.long, comment="MacdLE 1st in",when=crossover(delta, 0))

strategy.entry("2nd in", strategy.long, comment="2nd in",when=isCross1)

strategy.entry("all in", strategy.long, comment="all in",when=isCross2)

strategy.close("2nd in",when=isCrossSell) 
strategy.close("all in",when=isCrossSell)
//strategy.close("2nd in",when=crossunder(delta, 0)) 
//strategy.close("all in",when=crossunder(delta, 0))
strategy.close("MacdLE 1st in",when=crossunder(delta, 0)) 
    
histColour = (delta > 0) ? green : (delta < 0) ? red :  #4169E1
    
plot(MACD,color=red,linewidth=2)
plot(aMACD,color=blue,linewidth=2)
plot(delta,style=histogram, color=histColour, linewidth=10)
plot(0,color=white)
````
