# Hull Crossover Strategy no TP or SL

- url: https://www.tradingview.com/script/5BJ5tnca-Hull-Crossover-Strategy-no-TP-or-SL/
- type: strategy
- pine_id: PUB;09b074d8355c4eb5a0b7e29cd458098a
- version: 1.0

## Description

[b]What is it?[/b]
A simple yet effective strategy ran on the 30m chart.
This is a basic idea that can be expanded on using different indicator to either add signals or filter out certain bad signals!

The strategy consists of 1 fast moving average and 1 slow moving average.
Both of these moving averages are the Hull Moving Average

[b]What is the Hull Moving Average?[/b]
The Hull Moving Average ( HMA ) is a directional trend indicator.
It captures the current market conditions and uses recent price action to determine if conditions are bullish or bearish relative to historical data.
The Hull is different from traditional trend indicators like the EMA and the SMA .
It is designed to reduce the lag often associated with other MAs by providing a faster signal on a smoother visual plane.

[b]How it works?[/b]
When the fast HMA crosses over the slow HMA , we initiate a long signal, and
when the fast HMA crosses under the slow HMA , we initiate a short signal.

[b]Conclusion[/b]
The power of simplicity is what makes this such a great core to use to build onto making something even better!
The results were optimised to suit the most common market conditions seen today.
[b]******** Not financial advice! ********[/b]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Tuned_Official
//@version=4
strategy(title="Hull Crossover Strategy no TP or SL", overlay = true, pyramiding=1, default_qty_type=strategy.percent_of_equity, default_qty_value=100, commission_type=strategy.commission.percent, commission_value=0.04)

//Inputs
hullLen1 = input(title="Hull fast length", defval=56)
hullLen2 = input(title="Hull slow length", defval=76)

//Indicators
fasthull = hma(close, hullLen1)
slowhull = hma(close, hullLen2)

//conditions
go_long = crossover(fasthull, slowhull)
go_short = crossunder(fasthull, slowhull)

//Entry
strategy.order("long", strategy.long, when=go_long)
strategy.order("Short", strategy.short, when=go_short)
````
