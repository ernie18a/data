# RSI Buy and Sell

- url: https://www.tradingview.com/script/Z59QoZWN-RSI-Buy-and-Sell/
- type: strategy
- pine_id: PUB;USaMXfU5OsHaeA3GtYjaX3k7BujmlZUP
- version: 1.0

## Description

This is sooooooooo simple. 

Buy when RSI is above 70 and don't sell til it'sunder 30.

## Source Code

````pine
//@version=3
///buy when rsi is above 70 and don't sell until rsi is below 30.
strategy("RSI Buy and Sell", overlay=true)
a = rsi(close,14)
OB = input(70)
OS = input(30)
os = a > OB
ob = a < OS
strategy.entry("RSI", strategy.long, when = os)
strategy.close_all(when = ob)
````
