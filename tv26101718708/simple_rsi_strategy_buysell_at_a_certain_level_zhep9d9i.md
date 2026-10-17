# Simple RSI Strategy Buy/Sell at a certain level

- url: https://www.tradingview.com/script/ZhEP9D9i-Simple-RSI-Strategy-Buy-Sell-at-a-certain-level/
- type: strategy
- pine_id: PUB;h5azLajbJcuz2s3ImMoG5m17g59xJKcV
- version: 1.0

## Description

Simple Strategy based on RSI, using overbought or oversold levels, defined by us, sell or buy an asset. 
Backtest: ETHUSD (Bitmex) - 3h

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Bitduke

//@version=4
strategy("Simple RSI Buy/Sell at a level", shorttitle="Simple RSI Strategy", overlay=true,calc_on_every_tick=false,pyramiding=0, default_qty_type=strategy.cash,default_qty_value=1000, currency=currency.USD, initial_capital=1000,commission_type=strategy.commission.percent, commission_value=0.075)
overbought = input(70, title="overbought value")
oversold = input(30, title="oversold value")
myrsi = rsi(close, 14) > overbought
myrsi2 = rsi(close, 14) < oversold

barcolor(myrsi ? color.black : na)
barcolor(myrsi2 ? color.blue : na)

strategy.entry("Buy Signal",strategy.long, when = myrsi)
strategy.entry("Sell Signal",strategy.short, when = myrsi2)
````
