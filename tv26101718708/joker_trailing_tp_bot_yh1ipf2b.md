# Joker Trailing TP Bot

- url: https://www.tradingview.com/script/yh1iPF2b-Joker-Trailing-TP-Bot/
- type: strategy
- pine_id: PUB;11dd19df05044e8a8ac162b3ff39485e
- version: 1.0

## Description

Trailing Take Profit is used by the traders to increase their gains when the prices moves in a favorable direction. Let’s have a look at what is Trailing Take Profit and how it works.

What Is a Trailing Take Profit?
Trailing Take Profit is a term largely used in crypto, whereas you may encounter the term Trailing Stop in traditional trading describing almost the same thing, So what’s the difference between Trailing Take Profit and Trailing Stop? Trailing Stop is a type of Stop Loss automatically moving in the same direction as the asset’s price. Trailing Take Profit is nothing else than Trailing Stop activated after initial Take Profit is reached.

The main difference between these two is that Trailing Take Profit takes the profit in any case (altough it might be later annihilated by Trailing Stop). Thus, Trailing Take Profit reduces the risks that might’ve occurred using Trailing Stop alone.   Trailing Take Profit is bound to the maximum of Take Profit price instead of just a price increase/decrease.
As you might notice, the terms Trailing Take Profit and Stop Loss are quite similar. To avoid confusion, in this article we will be talking about Trailing Take Profit as defined above.

Trailing Take Profit only moves in one direction. It is designed to lock in profit and limit losses. The trailing profit only moves up (in case of a long strategy) once the price has surpassed previous high and a new high has been established. If the trailing take profit moves up, it cannot move back down, thus securing the profit and preventing losses.

Trailing Take Profit allows the trade to remain open and continue to profit as long as the price is moving in the investor’s favor.  If the price changes direction and the change surpasses the previously set percentage the order will be closed.

How Does it Work?
For example if you buy BTC at the price of 10000, if you set a Take Profit at 11000 and a Trailing Take Profit at 5% :
If the price goes up to 10500, nothing happens because the Take Profit at 11000 has not been reached.
Then if the BTC price goes up top 11000, a Stop Order at 10450 will be set.
Then if the BTC price goes down to 10500, the Stop Order stays at 104500. 
Then if the BTC price goes up to 12000, the Stop Order moves to 11400. 
Then if the BTC price goes down to 11000, the Stop Order at 11400 is executed.
You see that without Trailing Take Profit, the buy order would have been sold at 11000. Thus, a trader would miss an earning opportunity at 11400.

## Source Code

````pine
//@version=5
strategy(title='Joker Trailing TP Bot', shorttitle='Joker TTP Bot', overlay=true, pyramiding=0, process_orders_on_close=false, close_entries_rule='ANY', calc_on_every_tick=false, calc_on_order_fills=false, commission_type=strategy.commission.percent, commission_value=0.07, default_qty_type=strategy.percent_of_equity, default_qty_value=100, initial_capital=1000, currency=currency.USD) //, max_labels_count=500)

fromDate = input.time(timestamp('01 Jan 2021 00:00 UTC'), 'From Date')
toDate = input.time(timestamp('31 Dec 2121 23:59 UTC'), 'To Date')
fastMALen = input.int(23, 'Fast SMA Length')
slowMALen = input.int(50, 'Slow SMA Length')
longTakeProfitPerc = input.float(0.5, 'Long Take Profit %', minval=0.05, step=0.05) * 0.01
shortTakeProfitPerc = input.float(0.5, 'Short Take Profit %', minval=0.05, step=0.05) * 0.01
enableTrailing = input.bool(true, 'Enable Trailing')
trailingTakeProfitPerc = input.float(0.01, 'Trailing Take Profit %', minval=0.01, maxval=100, step=0.01) * 0.01

float fastMA = ta.sma(close, fastMALen)
float slowMA = ta.sma(close, slowMALen)
bool isWithinPeriod = time >= fromDate and time <= toDate
bool openLongPosition = isWithinPeriod and ta.crossover(fastMA, slowMA)
bool openShortPosition = isWithinPeriod and ta.crossunder(fastMA, slowMA)
bool longIsActive = openLongPosition or strategy.position_size > 0
bool shortIsActive = openShortPosition or strategy.position_size < 0

float longTakeProfitPrice = na
longTakeProfitPrice := if longIsActive
    if openLongPosition and not (strategy.position_size > 0)
        close * (1 + longTakeProfitPerc)
    else
        nz(longTakeProfitPrice[1], close * (1 + longTakeProfitPerc))
else
    na

float shortTakeProfitPrice = na
shortTakeProfitPrice := if shortIsActive
    if openShortPosition and not (strategy.position_size < 0)
        close * (1 - shortTakeProfitPerc)
    else
        nz(shortTakeProfitPrice[1], close * (1 - shortTakeProfitPrice))
else
    na

float longTrailingTakeProfitStepTicks = longTakeProfitPrice * trailingTakeProfitPerc / syminfo.mintick
float shortTrailingTakeProfitStepTicks = shortTakeProfitPrice * trailingTakeProfitPerc / syminfo.mintick

strategy.entry(id = 'Long Entry', direction = strategy.long, when = openLongPosition, alert_message = 'Long(' + syminfo.ticker + '): Started')
strategy.entry(id = 'Short Entry', direction = strategy.short, when = openShortPosition, alert_message = 'Short(' + syminfo.ticker + '): Started')
strategy.exit(id = 'Long Take Profit', from_entry = 'Long Entry', limit = enableTrailing ? na : longTakeProfitPrice, trail_price = enableTrailing ? longTakeProfitPrice : na, trail_offset = enableTrailing ? longTrailingTakeProfitStepTicks : na, when = longIsActive, alert_message = 'Long(' + syminfo.ticker + '): Take Profit activated')
strategy.exit(id = 'Short Take Profit', from_entry = 'Short Entry', limit = enableTrailing ? na : shortTakeProfitPrice, trail_price = enableTrailing ? shortTakeProfitPrice : na, trail_offset = enableTrailing ? shortTrailingTakeProfitStepTicks : na, when = shortIsActive, alert_message = 'Short(' + syminfo.ticker + '): Take Profit activated')

plot(series = fastMA, title='Fast SMA', color = color.blue, linewidth = 1, style = plot.style_line)
plot(series = slowMA, title='Slow SMA', color = color.orange, linewidth = 1, style = plot.style_line)
plot(series = longTakeProfitPrice, title='Long Take Profit', color = color.green, linewidth = 1, style = plot.style_cross, offset = 1)
plot(series = shortTakeProfitPrice, title='Short Take Profit', color = color.red, linewidth = 1, style = plot.style_cross, offset = 1)
plot(series = strategy.position_avg_price, title='Position', color = color.white, linewidth = 1, style = plot.style_linebr)
````
