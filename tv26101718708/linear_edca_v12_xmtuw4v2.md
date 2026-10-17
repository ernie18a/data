# Linear EDCA v1.2

- url: https://www.tradingview.com/script/xMtuW4V2/
- type: strategy
- pine_id: PUB;071c427f77ad4c4ca28cd1d7c9cbc7c1
- version: 4.0

## Description

Strategy Description:
Linear EDCA (Linear Enhanced Dollar Cost Averaging) is an enhanced version of the DCA fixed investment strategy. It has the following features:
1. Take the 1100-day SMA as a reference indicator, enter the buy range below the moving average, and enter the sell range above the moving average
2. The order to buy and sell is carried out at different "speed", which are set with two linear functions, and you can change the slope of the linear function to achieve different trading position control purposes
3. This fixed investment is a low-frequency strategy and only works on a daily level cycle

----------------
Strategy backtest performance:
BTCUSD (September 2014~September 2022): Net profit margin 26378%, maximum floating loss 47.12% (2015-01-14)
ETHUSD (August 2018~September 2022): Net profit margin 1669%, maximum floating loss 49.63% (2018-12-14)

----------------
How the strategy works:
Buying Conditions:
The closing price of the day is below the 1100 SMA, and the ratio of buying positions is determined by the deviation of the closing price from the moving average and the buySlope parameter

Selling Conditions:
The closing price of the day is above the 1100 SMA, and the ratio of the selling position is determined by the deviation of the closing price and the moving average and the sellSlope parameter

special case:
When the sellOffset parameter>0, it will maintain a small buy within a certain range above the 1100 SMA to avoid prematurely starting to sell
The maximum ratio of a single buy position does not exceed defInvestRatio * maxBuyRate
The maximum ratio of a single sell position does not exceed defInvestRatio * maxSellRate

----------------
Version Information:
Current version v1.2 (the first officially released version)

v1.2 version setting parameter description:
defInvestRatio: The default fixed investment ratio, the strategy will calculate the position ratio of a single fixed investment based on this ratio and a linear function. The default 0.025 represents 2.5% of the position
buySlope: the slope of the linear function of the order to buy, used to control the position ratio of a single buy
sellSlope: the slope of the linear function of the order to sell, used to control the position ratio of a single sell
sellOffset: The offset of the order to sell. If it is greater than 0, it will keep a small buy within a certain range to avoid starting to sell too early

maxSellRate: Controls the maximum sell multiple. The maximum ratio of a single sell position does not exceed defInvestRatio * maxSellRate
maxBuyRate: Controls the maximum buy multiple. The maximum ratio of a single buy position does not exceed defInvestRatio * maxBuyRate

maPeriod: the length of the moving average, 1100-day MA is used by default
smoothing: moving average smoothing algorithm, SMA is used by default

useDateFilter: Whether to specify a date range when backtesting
settleOnEnd: If useDateFilter==true, whether to close the position after the end date
startDate: If useDateFilter==true, specify the backtest start date
endDate: If useDateFilter==true, specify the end date of the backtest
investDayofweek: Invest on the day of the week, the default is to close on Monday
intervalDays: The minimum number of days between each invest. Since it is calculated on a weekly basis, this number must be 7 or a multiple of 7

The v1.2 version data window indicator description (only important indicators are listed):
MA: 1100-day SMA
RoR%: floating profit and loss of the current position
maxLoss%: The maximum floating loss of the position. Note that this floating loss represents the floating loss of the position, and does not represent the floating loss of the overall account. For example, the current position is 1%, the floating loss is 50%, the overall account floating loss is 0.5%, but the position floating loss is 50%
maxGain%: The maximum floating profit of the position. Note that this floating profit represents the floating profit of the position, and does not represent the floating profit of the overall account.
positionPercent%: position percentage
positionAvgPrice: position average holding cost


--------------------------------

策略说明：
Linear EDCA（Linear Enhanced Dollar Cost Averaging）是一个DCA定投策略的增强版本，它具有如下特性：
1. 以1100日SMA均线作为参考指标，在均线以下进入定买区间，在均线以上进入定卖区间
2. 定买和定卖以不同的“速率”进行，它们用两条线性函数设定，并且你可以通过改变线性函数的斜率，以达到不同的买卖仓位控制的目的
3. 本定投作为低频策略，只在日级别周期工作

----------------
策略回测表现：
BTCUSD（2014年09月~2022年09月）：净利润率26378%，最大浮亏47.12%（2015-01-14）
ETHUSD（2018年08~2022年09月）：净利润率1669%，最大浮亏49.63%（2018-12-14）

----------------
策略工作原理：
买入条件：
当日收盘价在 1100 SMA 之下，由收盘价和均线的偏离度，以及buySlope参数决定买入仓位比例

卖出条件：
当日收盘价在 1100 SMA之上，由收盘价和均线的偏离度，以及sellSlope参数决定卖出仓位比例

特例：
当sellOffset参数>0，则在 1100 SMA以上一定范围内还会保持小幅买入，避免过早开始卖出
单次买入仓位比例最大不超过 defInvestRatio * maxBuyRate
单次卖出仓位比例最大不超过 defInvestRatio * maxSellRate

----------------
版本信息：
当前版本v1.2（第一个正式发布的版本）

v1.2版本设置参数说明：
defInvestRatio: 默认定投比例，策略会根据此比例和线性函数计算得出单次定投的仓位比例。默认0.025代表2.5%仓位
buySlope: 定买的线性函数斜率，用来控制单次买入的仓位倍率
sellSlope: 定卖的线性函数斜率，用来控制单次卖出的仓位倍率
sellOffset: 定卖的偏移度，如果大于0，则在一定范围内还会保持小幅买入，避免过早开始卖出

maxSellRate: 控制最大卖出倍率。单次卖出仓位比例最大不超过 defInvestRatio * maxSellRate
maxBuyRate: 控制最大买入倍率。单次买入仓位比例最大不超过 defInvestRatio * maxBuyRate

maPeriod: 均线长度，默认使用1100日MA
smoothing: 均线平滑算法，默认使用SMA

useDateFilter: 回测时是否要指定日期范围
settleOnEnd: 如果useDateFilter==true，在结束日之后是否平仓所持有的仓位平仓
startDate: 如果useDateFilter==true，指定回测开始日期
endDate: 如果useDateFilter==true，指定回测结束日期
investDayofweek: 每次在周几定投，默认在每周一收盘
intervalDays: 每次定投之间的最小间隔天数，由于是按周计算，所以此数字必须是7或7的倍数

v1.2版本数据窗口指标说明（只列出重要指标）：
MA：1100日SMA
RoR%: 当前仓位的浮动盈亏
maxLoss%: 仓位曾经的最大浮动亏损，注意此浮亏代表持仓仓位的浮亏情况，并不代表整体账户浮亏情况。例如当前仓位是1%，浮亏50%，整体账户浮亏是0.5%，但仓位浮亏是50%
maxGain%: 仓位曾经的最大浮动盈利，注意此浮盈代表持仓仓位的浮盈情况，并不代表整体账户浮盈情况。
positionPercent%: 仓位持仓占比
positionAvgPrice: 仓位平均持仓成本

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// 
// © Stephan-Gao

//@version=5
strategy("Linear EDCA v1.2.3", overlay=true, default_qty_type = strategy.percent_of_equity, 
  default_qty_value = 1, initial_capital = 10000, currency = currency.USD, commission_type = strategy.commission.percent, commission_value = 0.2)
strategy.risk.allow_entry_in(strategy.direction.long)

// 单位定投比率
defInvestRatio = input.float(0.025, title = "default invest ratio", tooltip = "The default fixed investment ratio, the strategy will calculate the position ratio of a single fixed investment based on this ratio and a linear function. The default 0.025 represents 2.5% of the position")

// 最小单笔买卖头寸数量
minPositionSize = input.float(0.001, title = "min position size", minval = 0)

// 定买的线性函数斜率
buySlope = input.float(-35, title = "buy slope", maxval = 0, tooltip = "the slope of the linear function of the order to buy, used to control the position ratio of a single buy")

// 定卖的线性函数斜率
sellSlope = input.float(-0.7, title = "sell slope", maxval = 0, tooltip = "the slope of the linear function of the order to sell, used to control the position ratio of a single sell")

// 定卖的偏移度（如果是正数，则在均线以上一段距离还保持买入；如果是负数，则在偏离度为0时即开始卖出。一般对于牛市较长的市场，一般偏移为正数）
sellOffset = input.float(0.6, title = "sell offset", tooltip = "The offset of the order to sell. If it is greater than 0, it will keep a small buy within a certain range to avoid starting to sell too early")

// 最大卖出倍率（defInvestRatio * maxSellRate = 最大单次卖出仓位）
maxSellRate = input.float(5, title = "max sell rate", minval = 0, tooltip = "Controls the maximum sell multiple. The maximum ratio of a single sell position does not exceed defInvestRatio * maxSellRate")

// 最大买入倍率（defInvestRatio * maxBuyRate = 最大单次买入仓位）
maxBuyRate = input.float(6, title = "max buy rate", minval = 0, tooltip = "Controls the maximum buy multiple. The maximum ratio of a single buy position does not exceed defInvestRatio * maxBuyRate")

maPeriod = input(1100, "MA Period")
smoothing = input.string(defval="SMA", options=["EMA", "SMA"])

useDateFilter = input.bool(true, title="Filter Date Range of Backtest", group = "Backtest Date Range")
settleOnEnd = input.bool(false, title="settle account on end", group = "Backtest Date Range")
startDate = input.time(title="startDate", defval=timestamp("2013-11-30T00:00+00:00"), group = "Backtest Date Range")
endDate = input.time(title="endDate", defval=timestamp("2022-09-16T00:00+00:00"), group = "Backtest Date Range")
investDayofweek = input.int(2, title = "invest day of week", tooltip = "1 means Sunday, 2 means Monday, 7 means Saturday", minval = 1, maxval = 7, group = "Backtest Date Range")
intervalDays = input.int(14, title="interval days", group = "Backtest Date Range")

inTradeWindow = not useDateFilter or (time >= startDate and time < endDate)

var int investBarIndex = 0
isInvestDay() => timeframe.period == "D" and dayofweek == investDayofweek and bar_index >= (investBarIndex+intervalDays) and inTradeWindow

ma(smoothing, src, length) => 
    if smoothing == "EMA"
        ta.ema(src, length)
    else
        if smoothing == "SMA"
            ta.sma(src, length)

calInvestRate(deviation) => 
    float result = 0
    
    if deviation >= 0
        result := sellSlope * deviation + sellOffset
        result := math.abs(result) > maxSellRate ? -maxSellRate : result
    else
        result := buySlope * deviation + 1
        result := math.abs(result) > maxBuyRate ? maxBuyRate : result
    
    result

// 当前仓位净值
positionValue() => strategy.position_size * close

// 当前可动用的本金
capitalValue() => strategy.equity - positionValue() > 0 ? strategy.equity - positionValue() : 0

// 目标单笔投资的数量（order qty）
orderQty(orderPercent) => 
    float resultQty = 0

    targetOrderValue = strategy.equity * math.abs(orderPercent)
    if capitalValue() <= 0
        resultQty := 0
    else if capitalValue() > 0 and capitalValue() > targetOrderValue
        resultQty := targetOrderValue / close
    else if capitalValue() <= targetOrderValue
        resultQty := capitalValue() / close

    resultQty := math.round_to_mintick(resultQty)
    if resultQty > 0
        resultQty := resultQty < minPositionSize ? 0 : resultQty

closeOrderQty(orderPercent) =>
    float resultQty = 0

    targetCloseValue = strategy.equity * math.abs(orderPercent)
    if positionValue() <= 0
        resultQty := 0
    else if positionValue() > 0 and positionValue() > targetCloseValue
        resultQty := targetCloseValue / close
    else if positionValue() <= targetCloseValue
        resultQty := positionValue() / close

    resultQty := math.round_to_mintick(resultQty)
    if resultQty > 0
        resultQty := resultQty < minPositionSize ? 0 : resultQty


//// Main ////

movingAverage = ma(smoothing, close, maPeriod)
plot(movingAverage, "MA", linewidth = 2, color = color.new(color.black, 0), display = display.all)

deviation = (close - movingAverage) / movingAverage
investRate = calInvestRate(deviation)
orderPercent = defInvestRatio * investRate

orderQty = orderQty(orderPercent)
plot(orderQty, "orderQty", display = display.data_window)

closeOrderQty = closeOrderQty(orderPercent)
plot(closeOrderQty, "closeOrderQty", display = display.data_window)

if isInvestDay()
    if investRate > 0
        if orderQty > 0
            orderPer = orderQty * close / strategy.equity
            strategy.order("Buy", strategy.long, qty = orderQty, comment = "Buy " + str.tostring(orderPer*100, "0.00") + "%")
            investBarIndex := bar_index
    else
        if closeOrderQty > 0
            closeOrderPer = closeOrderQty * close / strategy.equity
            strategy.close("Buy", qty = closeOrderQty, comment = "Sell " + str.tostring(closeOrderPer*100, "0.00") + "%")
            investBarIndex := bar_index

if settleOnEnd and not inTradeWindow and inTradeWindow[1]
    strategy.cancel_all()
    strategy.close_all(comment="Date Range Exit")

// for debug
ror = 100 * (close - strategy.position_avg_price)/strategy.position_avg_price
var float maxLoss = 0
if ror < 0 and maxLoss > ror
    maxLoss := ror
var float maxGain = 0
if ror > 0 and maxGain < ror
    maxGain := ror
plot(ror, "positionReturn%", color = color.new(color.red, 0), style = plot.style_columns, display = display.data_window)
plot(maxLoss, "positionMaxFloatLoss%", color = color.new(color.red, 0), style = plot.style_columns, display = display.data_window + display.status_line)
plot(maxGain, "positionMaxFloatGain%", color = color.new(color.green, 0), style = plot.style_columns, display = display.data_window + display.status_line)
plot(strategy.max_drawdown, "max_drawdown", color = color.new(color.blue, 60), style = plot.style_histogram, display = display.all)

plot(100 * deviation, "deviation%", display = display.data_window)
plot(investRate, "investRate", display = display.data_window)
plot(100*orderPercent, "orderPercent%", display = display.data_window)
plot(100*positionValue()/strategy.equity, "positionPercent%", color = color.new(color.red, 0), display = display.data_window)
plot(strategy.position_avg_price, "positionAvgPrice", linewidth = 1, color = color.new(color.green, 0), display = display.all)
plot(strategy.position_size, "strategy.position_size", display = display.data_window)

plot(strategy.equity, "strategy.equity", display = display.data_window)
plot(strategy.openprofit, "strategy.openprofit", display = display.data_window)
plot(strategy.netprofit, "strategy.netProfit", display = display.data_window)
plot(positionValue(), "positionValue()", display = display.data_window)
plot(capitalValue(), "capitalValue()", display = display.data_window)
````
