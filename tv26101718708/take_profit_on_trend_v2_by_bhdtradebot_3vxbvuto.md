# Take Profit On Trend v2 (by BHD_Trade_Bot)

- url: https://www.tradingview.com/script/3vXbvuTO-Take-Profit-On-Trend-v2-by-BHD-Trade-Bot/
- type: strategy
- pine_id: PUB;7fc58d8ab56d43d58617b434fbdc4a1b
- version: 1.0

## Description

The purpose of strategy is to detect [b]long-term uptrend[/b] and [b]short-term downtrend[/b] so that you can easy to take profit.

The strategy also using [b]BHD unit[/b] to detect how big you win and lose, so that you can use this strategy for all coins without worry about it have different percentage of price change.


[b]ENTRY[/b]

The buy order is placed on assets that have long-term uptrend and short-term downtrend:
- Long-term uptrend condition: ema200 is going up
- Short-term downtrend condition: 2 last candles are down price (use candlestick for less delay)


[b]CLOSE[/b]

The sell order is placed when take profit or stop loss:
- Take profit: price increase 2 [b]BHD unit[/b]
- Stop loss: price decrease 3 [b]BHD unit[/b]


The strategy use $1000 for initial capital and trading fee is 0.1% for each order.

[b]Pro tip:[/b] The 1-hour time frame for ETH/USDT has the best results on average.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BHD_Trade_Bot

// @version=5
strategy(
 shorttitle            = 'Take Profit On Trend',
 title                 = 'Take Profit On Trend (by BHD_Trade_Bot)',
 overlay               = true,
 calc_on_every_tick    = true,
 calc_on_order_fills   = true,
 use_bar_magnifier     = true,
 initial_capital       = 1000,
 default_qty_type      = strategy.percent_of_equity,
 default_qty_value     = 100,
 commission_type       = strategy.commission.percent,
 commission_value      = 0.1)



// Backtest Time Period
start_year   = input(title='Start year'   ,defval=2021)
start_month  = input(title='Start month'  ,defval=1)
start_day    = input(title='Start day'    ,defval=1)
start_time = timestamp(start_year, start_month, start_day, 00, 00)

end_year     = input(title='end year'     ,defval=2050)
end_month    = input(title='end month'    ,defval=1)
end_day      = input(title='end day'      ,defval=1)
end_time = timestamp(end_year, end_month, end_day, 23, 59)

is_back_test_time() => time >= start_time and time <= end_time ? true : false



// EMA
ema50 = ta.ema(close, 50)
ema200 = ta.ema(close, 200)

// RSI
rsi200 = ta.rsi(close, 200)

// EMA_CD
emacd = ema50 - ema200
emacd_signal = ta.ema(emacd, 50)
hist = emacd - emacd_signal

// BHD Unit
bhd_unit = ta.rma(high - low, 200) * 2
bhd_upper = ema200 + bhd_unit
bhd_lower = ema200 - bhd_unit



// All n candles is going down
all_body_decrease(n) =>
    isValid = true
    for i = 0 to (n - 1)
        if (close[i] > close[i + 1])
            isValid := false
            break
    isValid



// ENTRY CONDITIONS

// Long-term uptrend
entry_condition1 = rsi200 > 51 and hist > 0

// Short-term downtrend
entry_condition2 = all_body_decrease(2)

ENTRY_CONDITIONS = entry_condition1 and entry_condition2

if ENTRY_CONDITIONS and is_back_test_time()
    strategy.entry('entry', strategy.long)


// CLOSE CONDITIONS

// Price increase 2 BHD unit
take_profit = close > strategy.position_avg_price + bhd_unit * 2

// Price decrease 3 BHD unit
stop_loss = close < strategy.position_avg_price - bhd_unit * 3

CLOSE_CONDITIONS = take_profit or stop_loss

if CLOSE_CONDITIONS
    strategy.close('entry')



// Draw
plot(ema50, color=color.orange, linewidth=2)
plot(ema200, color=color.purple, linewidth=2)
bhd_upper_line = plot(bhd_upper, color=color.teal)
bhd_lower_line = plot(bhd_lower, color=color.teal)
fill(bhd_upper_line, bhd_lower_line, color=color.new(color.teal, 90))
````
