# Chanu Delta Strategy

- url: https://www.tradingview.com/script/xcOoG6TP/
- type: strategy
- pine_id: PUB;637d74033fa0438baf1f3088eec7c6f1
- version: 7.0

## Description

This strategy is built on the Chanu Delta Indicator, which indicates the strength of the Bitcoin market. When the Chanu Delta Indicator hits “Delta_bull” and “Delta_bear” and closes the candle, long and short signals are triggered respectively. The example shown on the screen is a default setting optimized for a 4-hour candlestick strategy based on the Bybit BTCUSDT futures market. For the 15-minute candle, "Delta_bull=32", "Delta_bear=-31", "Source=hlc3" are best. You can use it by adjusting the setting value and modifying it to suit you.

[Note] If you use this strategy in conjunction with the Chanu Delta Indicator, it is convenient to anticipate alert signals in advance. Since the Chanu Delta Indicator represents the price difference based on the Bybit BTCUSDT futures market, backtesting is possible from March 2020.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © chanu_lev10k

//@version=4
strategy(title="Chanu Delta SL/TP Strategy", overlay=false)
// Inputs
delta_bull = input(defval=14.9, minval=0.1, type=input.float, step=0.1, title="Delta Bull")
delta_bear = input(defval=-17.2, maxval=-0.1, type=input.float, step=0.1, title="Delta Bear")
src = input(title="Source", type=input.source, defval=hlc3)
res = input(title="Resolution", type=input.resolution, defval="")
issl = input(title = "SL", inline = 'linesl1', group = 'Stop Loss / Take Profit:', type = input.bool, defval = false)
slpercent = input(title = ", %", inline = 'linesl1', group = 'Stop Loss / Take Profit:', type = input.float, defval = 19, minval=0.0, step=0.1)
istp = input(title = "TP", inline = 'linetp1', group = 'Stop Loss / Take Profit:', type = input.bool, defval = false)
tppercent = input(title = ", %", inline = 'linetp1', group = 'Stop Loss / Take Profit:', type = input.float, defval = 15.6, minval=0.0, step=0.1)
// Delta Definition
btcusd = security("BYBIT:BTCUSD", res, src)
btcusdt = security("BYBIT:BTCUSDT", res, src)
delta = btcusd - btcusdt
// Long Short Exit conditions
longCondition = crossover(delta, delta_bull)
if (longCondition)
    strategy.entry("Long", strategy.long)
shortCondition = crossunder(delta, delta_bear)
if (shortCondition)
    strategy.entry("Short", strategy.short)
// Entry price / Take profit / Stop Loss
entryprice = strategy.position_avg_price
pm = longCondition?1:shortCondition?-1:1/sign(strategy.position_size)
takeprofit = entryprice * (1+pm*tppercent*0.01)
stoploss = entryprice * (1-pm*slpercent*0.01)
strategy.exit(id="Exit Long", from_entry="Long", stop=issl?stoploss:na, limit=istp?takeprofit:na, alert_message="Close Long")
strategy.exit(id="Exit Short",from_entry="Short",stop=issl?stoploss:na, limit=istp?takeprofit:na, alert_message="Close Short")
// Plots
plot(delta, style=plot.style_columns, color=delta > 0 ? color.rgb(38, 166, 154) : color.rgb(239, 83, 80))
bgcolor(color=delta >= delta_bull ? color.new(color.lime, transp=75) : delta <= delta_bear ? color.new(color.red, transp=75) : na)
bgcolor(color=(delta > delta_bear) and (delta < delta_bull) ? color.new(color.silver, transp=75) : na)
hline(0, linestyle=hline.style_dotted, title="zero line")
hline(delta_bull, linestyle=hline.style_dotted, color=color.lime, title="Delta Bull")
hline(delta_bear, linestyle=hline.style_dotted, color=color.red, title="Delta Bear")
````
