# Low-High-Trend Strategy

- url: https://www.tradingview.com/script/o97hSCY4-Low-High-Trend-Strategy/
- type: strategy
- pine_id: PUB;dd584b3bd41d4b1e9f0a2fa336d08ac9
- version: 2.0

## Description

When asked what the key to successful investing was, Warren Buffet famously said “buy low, sell high.” Was he onto something? Today I am sharing with the community a simple “buy low, sell high” strategy with an optional trend filter and take-profit target. I’ve found that this strategy works well in a variety of markets but has a higher tendency to out-perform buy & hold in markets that are ranging sideways. 

How it works:
The strategy tracks the highest and lowest price over the last X number of bars (you select the look-back period). The highest price line is plotted in green and the lowest price line is potted in red. If the price crosses over the lowest price in the last X number of bars, then a buy signal is generated. Exit options include a take-profit % or selling when the price crosses over the highest price in the last X amount of bars. I.e. “Buy low, sell high.” An EMA is also plotted as a blue trend line, and there is an option to only trade if the price is above the EMA trend line.  

Disclaimer: Open source scripts I publish in the community are largely meant to spark ideas that can be used as building blocks for part of a more robust trade management strategy. Even though this example script beats buy and hold over the back-test time-frame, I wouldn't advise using it as a stand-alone strategy without significant additions/modifications to the strategy and risk management functions.  In this example the script is being used as a medium-term strategy with just 10% leverage over account equity, a $25k start balance, and back-testing 10+ years. Modifiable slippage and commissions are included in the model.

Green line = Highest price in the look-back period
Red line = Lowest price in the look-back period
Blue line = EMA Trend

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// @version=5
// Author = TradeAutomation


strategy(title="Low-High-Trend Strategy", shorttitle="Low-High-Trend Strategy", process_orders_on_close=true, overlay=true, commission_type=strategy.commission.cash_per_order, commission_value=1, slippage=1, initial_capital = 100000000, margin_long=50, margin_short=50, default_qty_type=strategy.percent_of_equity, default_qty_value=100)


// Backtest Date Range Inputs // 
StartTime = input.time(defval=timestamp('01 Jan 2000 05:00 +0000'), title='Start Time')
EndTime = input.time(defval=timestamp('01 Jan 2099 00:00 +0000'), title='End Time')
InDateRange = time>=StartTime and time<=EndTime

// Strategy Calculations //
lowcriteria = ta.lowest(close, input(20, "Lowest Price Lookback", tooltip="The strategy will BUY when the price crosses over the lowest it has been in the last X amount of bars"))[1]
highcriteria = ta.highest(close, input(10, "Highest Price Lookback", tooltip="If Take-Profit is not checked, the strategy will SELL when the price crosses under the highest it has been in the last X amount of bars"))[1]
plot(highcriteria, color=color.green)
plot(lowcriteria, color=color.red)

// Take Profit //
TakeProfitInput = input(true, "Sell with Take-Profit % intead of highest price cross?")
TakeProfit = ta.crossover(close,strategy.position_avg_price*(1+(.01*input.float(8, title="Take Profit %", step=.25))))

// Operational Functions //
TrendFilterInput = input(true, "Only buy when price is above EMA trend?")
ema = ta.ema(close, input(200, "EMA Length"))
TrendisLong = (close>ema)
plot(ema)

// Entry & Exit Functions//
if (InDateRange and TrendFilterInput==true)
    strategy.entry("Long", strategy.long, when = ta.crossover(close, lowcriteria) and TrendisLong)
if (InDateRange and TrendFilterInput==false)
    strategy.entry("Long", strategy.long, when = ta.crossover(close, lowcriteria))
if (InDateRange and TakeProfitInput==true)
    strategy.close("Long", when = TakeProfit)
if (InDateRange and TakeProfitInput==false)
    strategy.close("Long", when = ta.crossunder(close, highcriteria))
if (not InDateRange)
    strategy.close_all()
````
