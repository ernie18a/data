# Stable Coin - Arbitraje

- url: https://www.tradingview.com/script/MGSpgtvW-Stable-Coin-Arbitraje/
- type: strategy
- pine_id: PUB;IU1mejZJftEzXkWcr9OkNsv5VeMDmVRX
- version: 2.0

## Description

A simple strategy to make money from stable coin volatility

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © aguspina

//@version=4

strategy("Stable Coin - Arbitraje", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=100, initial_capital=100000, currency=currency.USD, commission_type=strategy.commission.percent, commission_value=0.001, calc_on_every_tick=true)
strategy.risk.allow_entry_in(strategy.direction.long)

///// Backtest Start Date /////
startDate   = input(title="Start Date",  type=input.integer, defval=1,    minval=1,    maxval=31)
startMonth  = input(title="Start Month", type=input.integer, defval=1,    minval=1,    maxval=12)
startYear   = input(title="Start Year",  type=input.integer, defval=2021, minval=1800, maxval=2100)

lowPrice   = input(title="Low Price",  type=input.float, defval=0.9997)
highPrice   = input(title="High Price",  type=input.float, defval=1.0003)

afterStartDate = (time >= timestamp(syminfo.timezone, startYear, startMonth, startDate, 0, 0))
shouldOpenLong = close <= lowPrice

if (afterStartDate and shouldOpenLong)
    strategy.entry(id="LONG", long=true, limit=lowPrice)
    strategy.exit(id="LONG", limit=highPrice)
````
