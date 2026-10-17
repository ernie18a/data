# Trend trader Strategy

- url: https://www.tradingview.com/script/BNXptz3U-Trend-trader-Strategy/
- type: strategy
- pine_id: PUB;NhCFQKypAPG4Nh9Q02QPKDexQ9ctHfBx
- version: 2.0

## Description

First I would like to thank to @JustUncleL since this strategy started from one of his scalper strategies


This strategy can be adapted to all time charts .

First it has the session where we want to trade, for this example I choosed the EURUSD so I only take in consideration london/neywork session.

Its made from 3 EMA :
normal
slow
ultra slow

It has has the capacity to use HA candles into consideration if its needed.

At the same time we have a price channel made from faster MAs, that act like a bollinger band .

Together with all of them, we establish which trend we have if its uptrend or downtrend

Then we check the candles if they are below or above the MA , and based on the condition if they crossed recently we can suggest if its a buy or a long condition

At the same time we have 2 options of stop conditions:

Through a trailing stop made from ATR or % based
And second, a SL/TP made from pip points or % based.

For this example I used % based.



Let me know what you think about it, and if you found some nice settings for it. So far I only adapted to EURUSD 1 min time.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SoftKill21

//@version=4
strategy("My Script")
plot(close)

//if you want acess to the better version of this, just message me :)
````
