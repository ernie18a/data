# Three EMAs Trend-following Strategy (by Coinrule)

- url: https://www.tradingview.com/script/7k9T1VNU-Three-EMAs-Trend-following-Strategy-by-Coinrule/
- type: strategy
- pine_id: PUB;920b7df68da14cec8562fe666407a5cb
- version: 1.0

## Description

[b]Trend-following strategies are great because they give you the peace of mind that you're trading in line with the market. [/b]

However, by definition, you're always [i]following[/i]. That means you're always a bit later than your want to be. The main challenges such strategies face are:

[list]
[*]Confirming that there is a trend
[*]Following the trend, hopefully, early enough to catch the majority of the move
[*]Hopping off the trade when it seems to have run its course
[/list]

This EMA Trend-following strategy attempts to address such challenges while allowing for a dynamic stop loss.

[b]ENTRY[/b] 

The trading system requires three crossovers on the same candle to confirm that a new trend is beginning:

[list]
[*]Price crossing over EMA 7
[*]Price crossing over EMA 14
[*]Price crossing over EMA 21
[/list]

The first benefit of using all three crossovers is to reduce false signals. The second benefit is that you know that a strong trend is likely to develop relatively soon, with the help of the fast setup of the three EMAs. 

[b]EXIT[/b] 

The strategy comes with a fixed take profit and a volatility stop, which acts as a trailing stop to adapt to the trend's strength. That helps you get out of the way as soon as market conditions change. Depending on your long term confidence in the asset, you can edit the fixed take profit to be more conservative or aggressive. 

The position is closed when: 

[list]
[*]The price increases by 4% 
[*]The price crosses below the volatility stop. 
[/list]

The best time frame for this strategy based on our backtest is the 4-hr. Shorter timeframes can also work well, although they exhibit larger volatility in their returns. In general, this approach suits medium timeframes. A trading fee of 0.1% is taken into account. The fee is aligned to the base fee applied on Binance, which is the largest cryptocurrency exchange.

[b]You can execute this strategy on your favourite exchange at coinrule.com[/b]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=4
strategy(shorttitle='Three EMAs Trend-following Strategy',title='Three EMAs Trend-following Strategy (by Coinrule)', overlay=true, initial_capital = 100, process_orders_on_close=true, default_qty_type = strategy.percent_of_equity, default_qty_value = 100, commission_type=strategy.commission.percent, commission_value=0.1)


//Backtest dates
fromMonth = input(defval = 1,    title = "From Month",      type = input.integer, minval = 1, maxval = 12)
fromDay   = input(defval = 1,    title = "From Day",        type = input.integer, minval = 1, maxval = 31)
fromYear  = input(defval = 2020, title = "From Year",       type = input.integer, minval = 1970)
thruMonth = input(defval = 1,    title = "Thru Month",      type = input.integer, minval = 1, maxval = 12)
thruDay   = input(defval = 1,    title = "Thru Day",        type = input.integer, minval = 1, maxval = 31)
thruYear  = input(defval = 2112, title = "Thru Year",       type = input.integer, minval = 1970)

showDate  = input(defval = true, title = "Show Date Range", type = input.bool)

start     = timestamp(fromYear, fromMonth, fromDay, 00, 00)        // backtest start window
finish    = timestamp(thruYear, thruMonth, thruDay, 23, 59)        // backtest finish window
window()  => time >= start and time <= finish ? true : false       // create function "within window of time"

ema_1 = ema(close, input(7))
ema_2 = ema(close, input(12))
ema_3 = ema(close, input(21))

Take_profit= ((input (4))/100)

longTakeProfit = strategy.position_avg_price * (1 + Take_profit)


length = input(20, "Length", minval = 2)
src = input(close, "Source")
factor = input(3.0, "Multiplier", minval = 0.25, step = 0.25)
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

go_long = crossover(close, ema_1) and crossover(close, ema_2) and crossover(close, ema_3)



closeLong = close > longTakeProfit or crossunder(close, vStop)



//Entry 
strategy.entry(id="long", long = true, when = go_long and window())



//Exit
strategy.close("long", when = closeLong and window())

plot(vStop,"Vstop", color.black, linewidth=2)
plot(ema_1,"EMA Short", color.green, linewidth=1)
plot(ema_2,"EMA Mid", color.purple, linewidth=1)
plot(ema_3,"EMA Long", color.red, linewidth=1)
````
