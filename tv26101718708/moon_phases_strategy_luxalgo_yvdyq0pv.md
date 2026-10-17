# Moon Phases Strategy [LuxAlgo]

- url: https://www.tradingview.com/script/yvDyq0pv-Moon-Phases-Strategy-LuxAlgo/
- type: strategy
- pine_id: PUB;f820bc86602d4d3dacd042fcd9046171
- version: 3.0

## Description

Trading moon phases has become quite popular among traders, believing that there exists a relationship between moon phases and market movements. This strategy is based on an estimate of moon phases with the possibility to use different methods to determine long/short positions based on moon phases.

Note that we assume moon phases are perfectly periodic with a cycle of 29.530588853 days (which is not realistically the case), as such there exists a difference between the detected moon phases by the strategy and the ones you would see. This difference becomes less important when using higher timeframes.

[b]Settings[/b]

[list] []New Moon Reference Date: Date of a new moon to be used as starting point for the cycle calculation. []Buy: Determine the condition to be used to open a long position [*]Sell: Determine the condition to be used to open a short position [/list]

[b]Description[/b]

The strategy can use different buy/sell conditions, these are determined in the Buy/Sell settings drop-down menu.

By default, the strategy goes long on a new moon and short on a full moon. This setup is common since full moons are said to be related to depressed mood. However, it is possible to use inverse conditions.

Users can also go long on higher moons (new moons or full moons occurring at a price that is higher than the previous one when a new/full moon occurred) and short on lower moons, this would return a trend following strategy, using the inverse conditions (buy lower moons/sell higher moons) would return a contrarian strategy.

[image]https://www.tradingview.com/x/kd5UyoWw/[/image]

The above chart displays the strategy using default conditions.

[image]https://www.tradingview.com/x/ouUVimig/[/image]

The above chart displays the strategy of going long on a higher moon and selling on a lower moon.

[b]Quick Summary[/b]

We provide a quick summary of the strategy using default conditions (buy on a new moon, sell on a full moon) on various tickers using the 4h timeframe (note that using a lower timeframe would return a backtest executing a lower number of trades).

Constant position sizing is used and no frictional costs are considered.

[b][i]BTCUSD[/i][/b]

[image]https://www.tradingview.com/x/IpsGMEFQ/[/image]

The moon phases strategy has been regularly tested with BTCUSD, with traders highlighting how moon phases tend to occur during tops/bottoms. We test the strategy from 2019-01-06 00:00.

[list] []Net Profit: $68544.86 []Closed Trades : 67 []% Profitability : 50.75 []Max Drawdown : $18541.24 [*]Max [/list]

[b][i]TSLA[/i][/b]

[image]https://www.tradingview.com/x/wGl6ePqW/[/image]

The strategy is tested from 2011-01-04 14:30

[list] []Net profit: $349.17 []Closed Trades : 265 []% Profitability : 54.34 []Max Drawdown : $262.72 [/list]

[b][i]EURUSD[/i][/b]

[image]https://www.tradingview.com/x/FHHCKHRP/[/image]

The strategy is tested from 2018-01-16 14:00.

[list] []Net profit: $-0.18 []Closed Trades : 91 []% Profitability : 50.55 []Max Drawdown : 0.36 [/list]

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © LuxAlgo

//@version=4
strategy("Moon Phases Strategy [LuxAlgo]", overlay=true,process_orders_on_close=true)
new    = input(title="New Moon Reference Date", type=input.time, defval=timestamp("2021-01-13:05:00"))
buy    = input('Full Moon',options=['New Moon','Full Moon','Higher Moon','Lower Moon'],inline='buy')
sell   = input('New Moon',options=['New Moon','Full Moon','Higher Moon','Lower Moon'],inline='sell')
longcol  = input(color.new(#2157f3,80),'',inline='buy')
shortcol = input(color.new(#ff1100,80),'',inline='sell')
//----
n = bar_index
cycle = 2551442876.8992
day = 8.64e+7
diff = (new + time + day*2)%cycle/cycle
//----
newmoon = crossover(diff,.5)
fullmoon = diff < diff[1]

plotshape(newmoon ? low : na,"New Moon",shape.labelup,location.top,na,0,text="🌑",size=size.tiny)
plotshape(fullmoon ? high : na,"Full Moon",shape.labeldown,location.bottom,na,0,text="🌕",size=size.tiny) 
//----
src = close
var bool long = na
var bool short = na
if buy == 'New Moon'
    long := newmoon
else if buy == 'Full Moon'
    long := fullmoon
else if buy == 'Higher Moon'
    long := valuewhen(newmoon or fullmoon,src,0) > valuewhen(newmoon or fullmoon,src,1)
else
    long := valuewhen(newmoon or fullmoon,src,0) < valuewhen(newmoon or fullmoon,src,1)
//----
if sell == 'New Moon'
    short := newmoon
else if sell == 'Full Moon'
    short := fullmoon
else if sell == 'Higher Moon'
    short := valuewhen(newmoon or fullmoon,src,0) > valuewhen(newmoon or fullmoon,src,1)
else
    short := valuewhen(newmoon or fullmoon,src,0) < valuewhen(newmoon or fullmoon,src,1)
//----
var pos = 0
if long
    pos := 1
    strategy.close("Short")
    strategy.entry("Long", strategy.long)

if short
    pos := -1
    strategy.close("Long")
    strategy.entry("Short", strategy.short)

bgcolor(pos == 1 ? longcol : shortcol)
````
