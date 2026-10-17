# MACD + DMI Scalping with Volatility Stop by (Coinrule)

- url: https://www.tradingview.com/script/nD83sb4E-MACD-DMI-Scalping-with-Volatility-Stop-by-Coinrule/
- type: strategy
- pine_id: PUB;9635a7d7aa704d9ab9a5613e35e8215d
- version: 1.0

## Description

[i]Trend-following strategies are cool because they allow you to catch potential high returns. [/i]

The main limit of such strategies are:

[list]
[*]False signals > the asset is not experiencing a strong trend. The strategy gets stuck with a sideways move or, worst, with the beginning of a downtrend. 
[*]The sell signal may come later than the actual top, leading in some cases to turn a trade in profit into a loss.
[/list]

This strategy tries to address these limitations to develop a trading system that optimises the entry and closes trade once the profit achieves a pre-set level. 

[b]ENTRY[/b]

The trading system uses the MACD and the DMI to confirm when is the best time for buying. Combining these two indicators prevents trading during downtrends and reduces the likelihood of getting stuck in a market with low volatility.

The system confirms the entry when:

[list]
[*]The MACD histogram turns bullish.
[*]When the positive DMI is greater than the negative DMI, there are more chances that the asset is trading in a sustained uptrend.
[/list]

[b]EXIT[/b]

The strategy comes with a fixed take profit combined with a volatility stop, which acts as a trailing stop to adapt to the trend's strength. Depending on your long term confidence in the asset, you can edit the fixed take profit to be more conservative or aggressive.

The position is closed when:

[list]
[*]The price increases by 3%
[*]The price crosses below the volatility stop.
[/list]

The best time frame for this strategy based on our backtest is the [b]3-hr[/b]. The 4-hr can work well. In general, this approach suits medium to long term strategies

The strategy assumes each order to trade 30% of the available capital to make the results more realistic. A trading fee of 0.1% is taken into account. The fee is aligned to the base fee applied on Binance, which is the largest cryptocurrency exchange.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=4
strategy(shorttitle='(MACD + DMI Scalping with Volatility Stop',title='MACD + DMI Scalping with Volatility Stop by (Coinrule)', overlay=true, initial_capital = 100, process_orders_on_close=true, default_qty_type = strategy.percent_of_equity, default_qty_value = 100, commission_type=strategy.commission.percent, commission_value=0.1)

// Works better on 3h, 1h, 2h, 4h

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

// DMI and MACD inputs and calculations

[pos_dm, neg_dm, avg_dm] = dmi(14, 14)
[macd, macd_signal, macd_histogram] = macd(close, 12, 26, 9)


Take_profit= ((input (3))/100)

longTakeProfit = strategy.position_avg_price * (1 + Take_profit)

length = input(20, "Length", minval = 2)
src = input(close, "Source")
factor = input(2.0, "vStop Multiplier", minval = 0.25, step = 0.25)
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


closeLong = close > longTakeProfit or crossunder(close, vStop)


//Entry 
strategy.entry(id="long", long = true, when = crossover(macd, macd_signal) and pos_dm > neg_dm and window())


//Exit
strategy.close("long", when = closeLong and window())
````
