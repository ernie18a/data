# Futures Engulfing Candle Size Strategy (Ticks, TP/SL)

- url: https://www.tradingview.com/script/88uwh4TR-Futures-Engulfing-Candle-Size-Strategy-Ticks-TP-SL/
- type: strategy
- pine_id: PUB;34c2780ae6fd4a299657d37048148051
- version: 7.0

## Description

The Futures Candle Size Strategy is designed to identify and trade significant price movements in the futures market based on candle size. It is optimized for futures instruments like ES, NQ, or CL, where precise tick-level calculations are essential. The strategy includes a customizable take profit and stop loss in ticks and operates only within a specified time window (e.g., 7:00 AM to 9:15 AM CST).

Key Features:

Candle Size Threshold: Trades are triggered when the candle's high-to-low range exceeds the defined threshold in ticks.
Time Filter: Limits trades to the most active market hours, specifically between 7:00 AM and 9:15 AM CST.
Take Profit and Stop Loss: Customizable exit levels in ticks to manage risk and lock in profits.
Long and Short Trades: Automatically places buy or sell orders based on the candle's direction (bullish or bearish).
Alerts: Sends alerts whenever a trade is triggered, helping you stay informed in real-time.
How It Works:

The strategy calculates the size of each candle in ticks and compares it to the user-defined threshold.
If the candle size meets or exceeds the threshold within the specified time range, it triggers a long or short trade.
The trade automatically exits when the price hits the take profit or stop loss levels.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © omnipadme

//@version=5
strategy("Futures Candle Size Strategy (With Historical Testing Range)", overlay=true, calc_on_every_tick=true)

// Backtesting range
testStartYear = input(2016, "Backtest Start Year")
testStartMonth = input(1, "Backtest Start Month")
testStartDay = input(1, "Backtest Start Day")
testPeriodStart = timestamp(testStartYear, testStartMonth, testStartDay, 0, 0)

testStopYear = input(2030, "Backtest Stop Year")
testStopMonth = input(12, "Backtest Stop Month")
testStopDay = input(30, "Backtest Stop Day")
testPeriodStop = timestamp(testStopYear, testStopMonth, testStopDay, 23, 59)

// Inputs
candleSizeThresholdTicks = input.float(25, title="Candle Size Threshold (Ticks)", minval=1)
takeProfitTicks = input.float(50, title="Take Profit (Ticks)", minval=1)
stopLossTicks = input.float(40, title="Stop Loss (Ticks)", minval=1)

// Time filter (7:00 AM to 9:15 AM CST)
startHour = input.int(7, title="Start Hour (CST)", minval=0, maxval=23)
startMinute = input.int(0, title="Start Minute (CST)", minval=0, maxval=59)
endHour = input.int(9, title="End Hour (CST)", minval=0, maxval=23)
endMinute = input.int(15, title="End Minute (CST)", minval=0, maxval=59)
inTimeRange = time("0700-0915", "GMT-6")

// Tick conversion
tickSize = syminfo.mintick
candleSizeThreshold = candleSizeThresholdTicks * tickSize
takeProfit = takeProfitTicks * tickSize
stopLoss = stopLossTicks * tickSize

// Candle size
candleSize = math.abs(high - low)

// Trade tracking
var hasTradedToday = false
isNewDay = dayofmonth != dayofmonth[1]
if isNewDay
    hasTradedToday := false

// Trigger condition
triggerCondition = inTimeRange and candleSize >= candleSizeThreshold and not hasTradedToday and time >= testPeriodStart and time <= testPeriodStop

// Entry logic
if triggerCondition
    hasTradedToday := true
    if close > open
        strategy.entry("Buy", strategy.long)
    if close < open
        strategy.entry("Sell", strategy.short)

// Exit logic
strategy.exit("Exit Long", from_entry="Buy", limit=strategy.position_avg_price + takeProfit, stop=strategy.position_avg_price - stopLoss)
strategy.exit("Exit Short", from_entry="Sell", limit=strategy.position_avg_price - takeProfit, stop=strategy.position_avg_price + stopLoss)

// Visuals
plot(strategy.position_size > 0 ? strategy.position_avg_price + takeProfit : na, color=color.green, title="Take Profit Level")
plot(strategy.position_size > 0 ? strategy.position_avg_price - stopLoss : na, color=color.red, title="Stop Loss Level")
bgcolor(time >= testPeriodStart and time <= testPeriodStop ? color.new(color.green, 90) : na, title="Backtest Range Highlight")

// Alerts
if triggerCondition
    alert("Candle size is " + str.tostring(candleSizeThresholdTicks) + " ticks or greater. Trade initiated.", alert.freq_once_per_bar)
````
