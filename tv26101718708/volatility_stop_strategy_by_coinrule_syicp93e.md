# Volatility Stop Strategy (by Coinrule)

- url: https://www.tradingview.com/script/SYICP93E-Volatility-Stop-Strategy-by-Coinrule/
- type: strategy
- pine_id: PUB;84c6c4560ed241b496026d4262f68da8
- version: 1.0

## Description

Traders often use the volatility stop to protect trades dynamically, adjusting the stop price gradually based on the asset's volatility.

Just like the volatility stop is a great way to capture trend reversals on the downside, the opposite applies as well. Therefore, another useful application of the volatility stop is to add it to a trading system to signal potential trend reversals to catch a good buy opportunity. 

[b]ENTRY[/b]

- When the price crosses above the Volatility Stop

[b]EXIT[/b]

- When the price crosses below the Volatility Stop

For this strategy, the Volatility stop's multiplier is set to 3 to allow more flexibility to the trade. The strategy is designed for medium-term trades.

Based on the backtest result from a sample of crypto trading pairs, [b]the most profitable time frame is the 2-hr.[/b] 

The strategy works well with both crypto-to-crypto and crypto-to-fiat pairs. To make results more realistic, a trading fee of 0.1% is added to the script. The fee is aligned to the base fee applied on Binance.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=4
strategy(shorttitle='Volatility Stop Strategy',title='Volatility Stop Strategy (by Coinrule)', overlay=true, initial_capital = 100, process_orders_on_close=true, default_qty_type = strategy.percent_of_equity, default_qty_value = 100, commission_type=strategy.commission.percent, commission_value=0.1)

// Works better on 3h, 1h, 2h, 4h
// Best time frame 2H

//Backtest dates
fromMonth = input(defval = 1,    title = "From Month",      type = input.integer, minval = 1, maxval = 12)
fromDay   = input(defval = 1,    title = "From Day",        type = input.integer, minval = 1, maxval = 31)
fromYear  = input(defval = 2021, title = "From Year",       type = input.integer, minval = 1970)
thruMonth = input(defval = 1,    title = "Thru Month",      type = input.integer, minval = 1, maxval = 12)
thruDay   = input(defval = 1,    title = "Thru Day",        type = input.integer, minval = 1, maxval = 31)
thruYear  = input(defval = 2112, title = "Thru Year",       type = input.integer, minval = 1970)

showDate  = input(defval = true, title = "Show Date Range", type = input.bool)

start     = timestamp(fromYear, fromMonth, fromDay, 00, 00)        // backtest start window
finish    = timestamp(thruYear, thruMonth, thruDay, 23, 59)        // backtest finish window
window()  => time >= start and time <= finish ? true : false       // create function "within window of time"

length = input(20, "Length", minval = 2)
src = input(close, "Source")
factor = input(3.0, "vStop Multiplier", minval = 0.25, step = 0.25)
volStop(src, atrlen, atrfactor) =>
    var max     = src
    var min     = src
    var uptrend = true
    var stop    = 0.0
    atrM        = nz(atr(atrlen) * atrfactor, tr)
    max         := max(max, src)
    min         := min(min, src)
    stop        := nz(uptrend ? max(stop, max - atrM) : min(stop, min + atrM), src)
    uptrend     := src - stop >= 0.0
    if uptrend != nz(uptrend[1], true)
        max    := src
        min    := src
        stop   := uptrend ? max - atrM : min + atrM
    [stop, uptrend]

[vStop, uptrend] = volStop(src, length, factor)


//Entry 


strategy.entry(id="long", long = true, when = crossover(close, vStop) and window())

//Exit
strategy.close("long", when = crossunder(close, vStop))

plot(vStop,"Vstop", color.black, linewidth=2)
````
