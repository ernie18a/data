# Strategy Template

- url: https://www.tradingview.com/script/yLiA2NgJ-Strategy-Template/
- type: strategy
- pine_id: PUB;acf827f909df47e484a1283645536945
- version: 2.0

## Description

Trying to include few basic things which is needed for strategy which can be used as template.

Few important components

[b]Strategy parameters[/b]

Few important parameters include - initial_capital, default_qty_type, default_qty_value, commission_type, pyramiding and commission_value. All my strategies will have similar settings with initial captial set to 20000 to 100000. 100% of equity per trade with no pyramiding (set to 1) and minimal commission.

margin_long and margin_short can be used for leveraged trading. But, since we are not using pyramiding, it will make no effect.

[b]Trade Limiting parameters[/b]

Two types of limiting is available in the scripts
[list]
[*] [b]Limiting trading direction[/b] : this is done through method [b]strategy.risk.allow_entry_in[/b] and input parameter [b]tradeDirection[/b]
[*] [b]Limiting trades to particular time window[/b] : This is achieved through adding start time and end time parameters of type [b]input.time[/b] and check whether [b]time[/b] is within this window
[/list]

[b]Custom Methods[/b]

[list]
[*] customized security method to get higher timeframe data
[*] customized moving average method to get moving average of any type
[/list]

[b]Custom Parameters[/b]

[list]
[*] [b]Moving average Type[/b] option list which I use quite often. Any strategy where there is need to use moving average, I try to scan through different moving average types and lengths to see which one is more appropriate for the given strategy. Hence, keeping this parameter in template to make it readily available when I start with new strategy
[*] [b]waitForCloseBeforeExit[/b] - this is used if trailing stop need to activated as soon as price hits the stop or only on close price. This is again something I switch quite often based on strategy. Hence, keeping this as part of the template.
[/list]

[b]Entry and Exit statements for long and short[/b]

These statements from line (57 to 62) can remain as is even with new strategy. Only thing to be set are variables - [b]buyCondition, sellCondition, closeBuyCondition and closeSellCondition[/b]

[b]Last but not the least[/b]

In pinescript, a long and short position cannot coexist in a strategy at any point of time. Any short positions created will automatically stop long positions and vice versa. Hence, it is important make short and long trades mutually exclusive. In this example, I have used 200 weekly moving average as trend bias. No short positions are taken when price is trading above 200 weekly moving average low/close and no long positions are taken when price is less than 200 weekly moving average high/close. Any rule built on top of this (In this case a simple supertrend rules) ensures that there are no conflicting signals and hence avoids confusing trades on the stratgy.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © HeWhoMustNotBeNamed

//@version=4
strategy("Strategy Template", overlay=true, initial_capital = 20000, default_qty_type = strategy.percent_of_equity,
             default_qty_value = 90, commission_type = strategy.commission.percent, pyramiding = 1, commission_value = 0.01,
             margin_long=90, margin_short=90, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

HigherTimeframe = input("W", type=input.resolution)
HTFMAType = input(title="HTF Moving Average Type", defval="hma", options=["ema", "sma", "hma", "rma", "vwma", "wma"])
HTFMaLength= input(20, step=10)
HTFUseHighLowRange = input(true)

atrLength = input(16, step=5)
atrMult = input(3, step=0.5)

tradeDirection = input(title="Trade Direction", defval=strategy.direction.all, 
             options=[strategy.direction.all, strategy.direction.long, strategy.direction.short], group="Trade Filters")
strategy.risk.allow_entry_in(tradeDirection)
i_startTime = input(defval = timestamp("01 Jan 2010 00:00 +0000"), title = "Start Time", type = input.time, group="Trade Filters")
i_endTime = input(defval = timestamp("01 Jan 2099 00:00 +0000"), title = "End Time", type = input.time, group="Trade Filters")
inDateRange = time >= i_startTime and time <= i_endTime
waitForCloseBeforeExit = input(false)

f_secureSecurity(_symbol, _res, _src, _offset) => security(_symbol, _res, _src[_offset], lookahead = barmerge.lookahead_on)

f_getMovingAverage(source, MAType, length)=>
    ma = sma(source, length)
    if(MAType == "ema")
        ma := ema(source,length)
    if(MAType == "hma")
        ma := hma(source,length)
    if(MAType == "rma")
        ma := rma(source,length)
    if(MAType == "vwma")
        ma := vwma(source,length)
    if(MAType == "wma")
        ma := wma(source,length)
    ma
    
maHTF = f_secureSecurity(syminfo.tickerid, HigherTimeframe, f_getMovingAverage(close, HTFMAType, HTFMaLength), 1)
maHTFHigh = f_secureSecurity(syminfo.tickerid, HigherTimeframe, f_getMovingAverage(high, HTFMAType, HTFMaLength), 1)
maHTFLow = f_secureSecurity(syminfo.tickerid, HigherTimeframe, f_getMovingAverage(low, HTFMAType, HTFMaLength), 1)

[supertrend, dir] = supertrend(atrMult, atrLength)

mh = plot(maHTFHigh, "MTF MA High", color=color.new(color.green, 90))
ml = plot(maHTFLow, "MTF MA Low", color=color.new(color.red, 90))
fill(mh, ml, title="No Trade Zone", color=color.new(color.yellow, 50))

plot(strategy.position_size != 0 ? supertrend : na, title="Trailing Stop", color=dir < 0? color.green : color.red, style=plot.style_stepline)

buyCondition = crossover(0, dir) and (close > (HTFUseHighLowRange? maHTFHigh : maHTF)) and inDateRange
closeBuyCondition = crossunder(0, dir)
sellCondition = crossunder(0, dir) and (close < (HTFUseHighLowRange? maHTFLow : maHTF)) and inDateRange
closeSellCondition = crossover(0, dir)

strategy.entry("Long", strategy.long, when=buyCondition, oca_name="oca_buy", oca_type=strategy.oca.cancel)
strategy.close("Long", when=closeBuyCondition and waitForCloseBeforeExit)
strategy.exit("ExitLong", "Long", stop=supertrend, when=not waitForCloseBeforeExit)
strategy.entry("Short", strategy.short, when=sellCondition, oca_name="oca_sell", oca_type=strategy.oca.cancel)
strategy.close("Short", when=closeSellCondition and waitForCloseBeforeExit)
strategy.exit("ExitShort", "Short", stop=supertrend, when=not waitForCloseBeforeExit)
````
