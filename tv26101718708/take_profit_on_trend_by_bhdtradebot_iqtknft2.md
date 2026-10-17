# Take Profit On Trend (by BHD_Trade_Bot)

- url: https://www.tradingview.com/script/iqtkNFT2-Take-Profit-On-Trend-by-BHD-Trade-Bot/
- type: strategy
- pine_id: PUB;a4fc623c0da5425ca7300a775cac21d3
- version: 1.0

## Description

The purpose of strategy is to detect [b]long-term uptrend[/b] and [b]short-term downtrend[/b] so that you can easy to take profit.

The strategy also using [b]BHD[/b] unit to detect how big you win and lose, so that you can use this strategy for all coins without worry about it have different percentage of price change.


[b]ENTRY[/b]

The buy order is placed on assets that have long-term uptrend and short-term downtrend:
- Long-term uptrend condition: ema200 is going up (rsi200 greater than 51)
- Short-term downtrend condition: 2 last candles are down price (use candlestick for less delay)


[b]CLOSE[/b]

The sell order is placed when take profit or stop loss:
- Take profit: price increase 1 BHD unit
- Stop loss: price decrease 2 BHD units


The strategy use $15 and trading fee is 0.1% for each order. So that, in the real-life, if you are using trade bot, it will need $1500 for trading 100 coins at the same time.

[b]Pro tip[/b]: The 1-hour time frame for altcoin/USDT has the best results on average.

## Source Code

````pine
// @version=4
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BHD_Trade_Bot

strategy(shorttitle='Take Profit On Trend',
 title='Take Profit On Trend (by BHD_Trade_Bot)',
 overlay=true,
 initial_capital = 15,
 default_qty_type = strategy.cash,
 default_qty_value = 15,
 commission_type=strategy.commission.percent,
 commission_value=0.1)



//Backtest Time
start_day = 1
start_month = 1
start_year = 2021
end_day = 1
end_month = 1
end_year = 2050
start_time = timestamp(start_year, start_month, start_day, 00, 00)
end_time = timestamp(end_year, end_month, end_day, 23, 59)
is_back_test_time() =>
    time >= start_time and time <= end_time ? true : false

// Last bar
h1_last_bar = (timenow - time)/1000/60/60 < 2



// EMA
ema50 = ema(close, 50)
ema200 = ema(close, 200)

// RSI length 200
rsi200 = rsi(close, 200)

// Bollinger Bands length 50
bb50 = 2 * stdev(close, 50)

// BHD Unit
bhd_unit = sma(bb50, 100)
bb50_upper = ema50 + bhd_unit
bb50_lower = ema50 - bhd_unit



// All n candles is going down
all_body_decrease(n) =>
    isValid = true
    for i = 0 to (n - 1)
        if (close[i] > close[i + 1])
            isValid := false
            break
    isValid



// ENTRY

// Long-term uptrend
entry_condition1 = rsi200 > 51 

// Short-term downtrend
entry_condition2 = all_body_decrease(2) 

ENTRY_CONDITION = entry_condition1 and entry_condition2

if (ENTRY_CONDITION and is_back_test_time())
    strategy.entry("entry", strategy.long)



// CLOSE CONDITIONS

// Price increase 1 BHD unit
TAKE_PROFIT = close > strategy.position_avg_price + bhd_unit

// Price decrease 2 BHD unit
STOP_LOSS = close < strategy.position_avg_price - bhd_unit * 2

CLOSE_CONDITION = TAKE_PROFIT or STOP_LOSS

if (CLOSE_CONDITION or h1_last_bar)
    strategy.close("entry")



// Draw
plot(ema50)
plot(ema200, color=color.yellow)
plot(bb50_upper)
plot(bb50_lower)
````
