# Test strat charlot citron

- url: https://www.tradingview.com/script/uII0zyVM/
- type: strategy
- pine_id: PUB;a4972951e1db4d5cbfaeb0d305938e91
- version: 1.0

## Description

Test strat charlot citrondsfsdfsdf
sôkfsd$*pokf*$psf
slf*^sdkf*sd^pf
l*^fs;*^fskd*^psdf
*sp^zqf;s*d^pofplks*^pfok

## Source Code

````pine
//@version=4
strategy(title="MA9 Cross Strategy", overlay=true, initial_capital=1000)
fastEMA = ema(close, 1)
SlowEMA= ema(close, 9)
golongcond1 = crossover(fastEMA, SlowEMA)
goexit = crossunder(fastEMA,SlowEMA)

timeperiod = time >= timestamp(syminfo.timezone,2018,05,1,0,0) and  time <= timestamp(syminfo.timezone,2022,04,16,0,0) 
notInTrade = strategy.position_size <= 0 //pas envie de reprendre position pas totalement compris..
if (golongcond1 and timeperiod and notInTrade)
    stoploss = low * 0.97
    takeProfit = high * 1.20
    strategy.entry("long",strategy.long)
   
if (goexit)
    strategy.close("long",when=goexit)
    
plot(fastEMA,color=color.blue)
plot(SlowEMA, color=color.yellow)
plot(golongcond1 ? SlowEMA : na,style=plot.style_cross,color=color.blue,linewidth=5, transp=0)
plot(goexit? SlowEMA : na,style=plot.style_cross,color=color.yellow,linewidth=5, transp=0)
````
