# Exponential Stochastic Strategy

- url: https://www.tradingview.com/script/Sr0hedIS-Exponential-Stochastic-Strategy/
- type: strategy
- pine_id: PUB;b734bebea3784697a4efa496eee5181a
- version: 1.0

## Description

what is Exponential Stochastic?
it is a modified version of the stochastic indicator. This strategy does not include pyramiding, repaint, trailing stop or take profit.

what it does?
It contains an extra input in addition to the stochastic indicator. Thanks to this input, different exponential weights can be given to the outputs and the indicator can be made more sensitive or insensitive. The strategy buys when the indicator leaves the overbought zone, sells when it leaves the oversold zone and always stays in the trade.

how it does it?
it uses this formula:[url=https://i.hizliresim.com/aiepcpp.png]https://i.hizliresim.com/aiepcpp.png[/url]
Thanks to this formula, even if the weights given to the outputs change, the indicator always continues to take a value between 0 and 100.

how to use it ?
With the input named "exp", you can change the sensitivity of the indicator and develop different strategies. other inputs are the same as the stochastic indicator. Increasing the exp value causes the indicator to signal less, decreasing it makes it much more sensitive.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © faytterro

//@version=5
strategy("Exponential Stochastic Strategy", overlay=false, default_qty_type=strategy.percent_of_equity, default_qty_value=100)
len=input.int(14, "length") 
ex=input.int(2, title="exp", minval=1, maxval=10)
exp= ex<10? (ex)/(10-ex) : 99
s=100 * (close - ta.lowest(low, len)) / (ta.highest(high, len) - ta.lowest(low, len))
ks=s>50? math.pow(math.abs(s-50),exp)/math.pow(50,exp-1)+50 :
 -math.pow(math.abs(s-50),exp)/math.pow(50,exp-1)+50
plot(ks, color= color.white)
bot=input.int(20)
top=input.int(80)
longCondition = ta.crossover(ks, bot) and bar_index>0
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)

shortCondition = ta.crossunder(ks, top) and bar_index>0
if (shortCondition)
    strategy.entry("My Short Entry Id", strategy.short)
//    strategy.close("My Long Entry Id")
alertcondition(longCondition, title = "buy")
alertcondition(shortCondition, title = "sell")
h1=hline(top)
h2=hline(bot)
h3=hline(100)
h4=hline(0)
fill(h1,h3, color= color.rgb(255,0,0,200-top*2))
fill(h2,h4, color= color.rgb(0,255,0,bot*2))
````
