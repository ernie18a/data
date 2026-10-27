# EMA + Bullish Engulfing Candle Pattern Strategy

- url: https://www.tradingview.com/script/TlG2Vs8L/
- type: strategy
- pine_id: PUB;e28ee5b5e56a4d3ba915bbdc508f96c9
- version: 1.0

## Description

Hello Guys! Nice to meet you all! 
This is my first open source script! 

### Long Condition
1. Bullish Engulfing Candle
2. No doge Candle
3. Present volume should be bigger than the previous volume (20%)
4. Trend filter (with 2 EMAs)

### Close Condition
1. When trend Changes
2. When Bearish Engulfing Candle appears

### 
No stop loss and take profit.

## Source Code

````pine
// @version=5
// # ========================================================================= #
// #                   |   STRATEGY  |
// # ========================================================================= #
strategy(
  title                           = "fpemehd Strategy001",
  shorttitle                      = "f_001",
  overlay                         =  true,
  default_qty_type                =  strategy.percent_of_equity, 
  default_qty_value               =  100, 
  initial_capital                 =  10000000, 
  currency                        =  currency.USD, 
  slippage                        =  0, 
  commission_type                 =  strategy.commission.cash_per_order, 
  commission_value                =  0.01, 
  process_orders_on_close         =  true)
// # ========================================================================= #
// #                   |   STRATEGY  |
// # ========================================================================= #


// Inputs
I_start_date = input.time (defval = timestamp("20 Jan 1990 00:00 +0900"))
I_finish_date = input.time(defval = timestamp("20 Dec 2030 00:00 +0900"))

I_short_ema = input.int(defval = 15 , title = "Short EMA", minval = 1 , maxval = 300 , step = 1)
I_long_ema = input.int(defval = 30 , title = "Long EMA", minval = 1 , maxval = 300 , step = 1)

I_body = input.float(defval = 1 , title = "Size of Body", minval = 1 , maxval = 5 , step = 0.1)

time_cond = time >= I_start_date and time <= I_finish_date

// Calculate Engulfing Candles
C_uptrend = false
C_downtrend = false
C_ema_short = ta.ema(source = close, length = I_short_ema) 
C_ema_long = ta.ema(source = close, length = I_long_ema) 
C_uptrend := close > C_ema_short and C_ema_short > C_ema_long
C_downtrend := close < C_ema_short and C_ema_short < C_ema_long

C_pre_body = math.abs(open[1]-close[1])
C_pre_body_ratio = (math.abs(open[1]-close[1])) / (math.abs(high[1]-low[1])) * 100

C_now_body = math.abs(open-close)
C_now_body_ratio = (math.abs(open-close)) / (math.abs(high-low)) * 100

C_bullish_engulfing = (open[1] > close[1] and open <= close) and (low < low[1] and high > high[1])
C_bearish_engulfing = (open[1] < close[1] and open >= close) and (low < low[1] and high > high[1])
C_avoid_doge = (C_pre_body_ratio > I_body and C_now_body_ratio > I_body) ? true : false
C_volume_filter = volume > volume[1] * 1.2

// Signals
long_signal = C_uptrend and C_bullish_engulfing and C_avoid_doge and C_volume_filter
close_signal = C_downtrend or C_bearish_engulfing 


if long_signal and time_cond
    strategy.entry(id = "Long", direction = strategy.long)

if close_signal and time_cond
    strategy.close(id = "Long")
````
