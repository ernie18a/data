# Simple signals example for Risk Management Wrapper

- url: https://www.tradingview.com/script/dCSR6m4v-Simple-signals-example-for-Risk-Management-Wrapper/
- type: indicator
- pine_id: PUB;Dhk0QWfoAgpNis9KJY3kLNKMSniDFu1p
- version: 1.0

## Description

[b]Simple signals example for Risk Management Wrapper[/b]

The unique part is that there is a [b]single variable[/b] used for both Buy and Sell conditions.
Technically, a variable can have an infinity of values, so why not use that in our favour.

A value of [b]-1[/b] is used for the [b]SELL alert condition[/b], and a value of [b]+1[/b] is used for the [b]BUY alert condition[/b].
The [url=https://www.tradingview.com/script/6MYLOs5H-Ultimate-Risk-Management-System/]Risk Management Wrapper[/url] can read them and act accordingly.

Any simple indicator on TradingView that gives Sell or Buy signals in a single variable should work.
More complex indicators that give multiple kinds of signals may not work due to TradingView limitations.

## Source Code

````pine
//@version=4
study("Simple signals example for Risk Management Wrapper", overlay=false)
// any indicator following these basic steps should be compatible with the Risk Management Wrapper (https://www.tradingview.com/script/6MYLOs5H-Ultimate-Risk-Management-System/)
ma1 = ema(close, input(100))
ma2 = sma(close, input(95))
short_and_long_alert = 0 // single variable for buy/sell alerts
if crossunder(ma1,ma2)
    short_and_long_alert:=-1
if crossover(ma1,ma2)
    short_and_long_alert:=+1
plot(short_and_long_alert, title="BUY SELL alerts", color=ma1<ma2?color.red:color.green, style=plot.style_areabr) // single plot
alertcondition(short_and_long_alert, title='*** BUY SELL alerts ***', message='*** BUY SELL alerts ***')
````
