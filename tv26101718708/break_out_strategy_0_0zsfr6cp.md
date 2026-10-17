# Break out strategy 0

- url: https://www.tradingview.com/script/0zSfR6CP/
- type: strategy
- pine_id: PUB;AAgnGo6pGb4U69VapEgZLQ4cO5PHk9hJ
- version: 2.0

## Description

Breakout strategy (for verification)
[b]Not recommended.[/b]
If you enter with a high (low) breakout for any period

ブレークアウトストラテジー(検証用)
[b]推奨するものではありません。[/b]
任意の期間の高値（安値）ブレークアウトでエントリーした場合

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Cbgbm788

//@version=4
strategy("Break out strategy 0", shorttitle="BOS0", pyramiding = 1, overlay=true)
//input
HLPeriod = input(20, title="HighLow Period", type=input.integer)
SL = input(2, title="Stop Loss(%)", type=input.integer)
ExpBars = input(5, title="Max holding period", type=input.integer)
//sub function
var _entry_barindex = 0
set_exit_barindex() => _bar_index = bar_index + ExpBars
//Highest Lowest
HH = security(syminfo.tickerid, timeframe.period, offset(highest(HLPeriod),2))
LL = security(syminfo.tickerid, timeframe.period, offset(lowest(HLPeriod),2))
//entry
longCondition = (strategy.position_size<=0?true:false) and crossover(close, HH[1])
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)
    _entry_barindex := set_exit_barindex()
shortCondition = (strategy.position_size>=0?true:false) and crossunder(close, LL[1])
if (shortCondition)
    strategy.entry("My Short Entry Id", strategy.short)
    _entry_barindex := set_exit_barindex()
//stop loss
strategy.exit("exit", loss = SL)
//cancel
if(bar_index==_entry_barindex)
    strategy.close_all(true, "Exp Bars")
    _entry_barindex := 0

//for debug
plot(HH, style=plot.style_stepline)
plot(LL, style=plot.style_stepline)
````
