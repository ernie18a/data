# Strategy Template - V2

- url: https://www.tradingview.com/script/nSgePqla-Strategy-Template-V2/
- type: strategy
- pine_id: PUB;e3867ae7cc1747a280707f5c5cd56f3d
- version: 5.0

## Description

This is an educational script created to demonstrate few basic building blocks of a trend based strategy and how to achieve different entry and exit types. My initial intention was to create a comprehensive strategy template which covers all the aspects of strategy. But, ended up creating fully fledged strategy based on trend following.

This is an enhancement on [url=https://www.tradingview.com/script/yLiA2NgJ-Strategy-Template/]Strategy-Template[/url] But this script is comparitively more complex. Hence I decided to create new version instead of updating the existing one.

Lets dive deep.

[b]SIMPLE COMPONENTS OF TREND FOLLOWING STRATEGY[/b]

[b]TREND BIAS[/b] - This defines the direction of trend. Idea is not to trade against the trend direction. If the bias is bullish, look for long opportunities and if bias is bearish, look for short opportunities. Stay out of the market when the bias is neutral.

Often, trend bias is determined based on longer timeframe conditions. Example - 200 Moving Average, Higher timeframe moving averages, Higher timeframe high-lows etc. can be used for determining the trend bias.

In this script, I am using Weekly donchian channels combined with daily donchian channels to define trend bias.

[b]Long Bias[/b] - 40 Day donchian channel sits completely in upper portion of 40 Week dochnial channel.
[b]Short Bias[/b] - 40 Day donchian channel sits completely in lower portion of 40 Week donchian channel.

[b]ENTRY CONDITION[/b] - Entry signals are generated only in the direction of bias. Hence, when in LongBias, we only get Long signals and when in short bias, we only get short signals.
In our case, when in [b]Long Bias[/b] - if price hits 40 day high for the first time, this creates our long entry signal. Similarly when in [b]Short Bias[/b], price hitting 40 day low will create signal for going short. Since we do not take trades opposite to trend, no entry conditions are formed when price hits 40 day high in Short Bias or 40 day low in Long Bias.

[b]EXIT CONDITION[/b] - Exit conditions are formed when we get signals of trend failure.
In our case, when in long trade, price hitting 40 day low creates exit signal. Similarly when in short trade price hitting 40 day high creates exit signal for short trade.


[b]DIFFERENT TYPES OF ENTRY AND EXIT[/b]
In this script, I have tried to demonstrate different entry and exit types.

[b]Entry types[/b]
[list]
[*] Market - Enter immediately when entry signal is received. That is, in this case when price crossover over high in long bias and crosses under low in short bias
[*] Stop - This method includes estimating at what level new highs are made and creating a stop buy order at that level. This way, we do not miss if the break out is stronger. But, susciptible to fail during fakeouts.
[*] Limit - This method includes executing a limit order to buy at lower price or sell at higher price. In trend following methods, downside of limit order is when there is genuine breakout, these limit orders may not hit and during trend failures the limit orders are likely to hit and go straight to stop.
[*] Stop-Limit - this is same as stop order but will also place a limit condition to avoid buying on overextended breakout or with lots of slippage.
[/list]

[b]Exit types[/b]
[list]
[*] Market - whether to keep the existing trade running or whether to close it is determined after close of each bar and exit orders are executed manually upon receiving exit signal.
[*] Stop - We place stop loss orders beforehand when there is a trade in place. This can help in avoiding big movements against trade within bar. But, this may also stop on false signals or fakeouts.
[/list]

[b]Take profit[/b]
[list]
[*] Stop - No take profits are configured.
[*] Target - 30% of the positions are closed when take profit levels are hit. Take profit levels are defined by risk reward.
[/list]


[b]USING THE CODE AS TEMPLATE[/b]
As mentioned earlier, I intended to create a fully fledged strategy template. But, ended up creating a fully fledged stratgy. However, you can take some part of this code and use it to start your own strategy. Will explain what all things can be adopted without worrying about the strategy implementation within

[list]
[*] [b]Strategy definition [/b]: This can be copied as is and just change the title of strategy. This defines some of the commonly used parameters of strategy which can help with close to realistic backtesting results for your coded strategy and comparison with buy and hold.
[*] [b]Generic Strategy Parameters[/b]: The parameter which defines controlling alllowed trade direction and trading window are present here. This again can be copied as is and variable inDateRange can be directly used in entry conditions.
[*] [b]Generic Methods[/b]: f_getMovingAverage and f_secureSecurity are handy and can be used as is. atr method provideded by pine gives you ATR based on RMA. If you want SMA or any other moving average based ATR, you can use the method f_getCustomAtr
[*] [b]Trade Statements[/b]: This section has all types of trading instructions which includes market/stop/limit/stop-limit type of entries and exits and take profit statements. You can adopt the type of entry you are interested in and change when condition to suit your strategy.
[*] [b]Trade conditions and levels[/b]: This section is required. But, cannot be copied. All the trade logic goes here which also sets parameters which are used in when of Trade Statements.
[/list]

Hope this helps.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © HeWhoMustNotBeNamed

//   __    __            __       __  __                  __       __                        __      __    __              __      _______             __    __                                          __ 
//  /  |  /  |          /  |  _  /  |/  |                /  \     /  |                      /  |    /  \  /  |            /  |    /       \           /  \  /  |                                        /  |
//  $$ |  $$ |  ______  $$ | / \ $$ |$$ |____    ______  $$  \   /$$ | __    __   _______  _$$ |_   $$  \ $$ |  ______   _$$ |_   $$$$$$$  |  ______  $$  \ $$ |  ______   _____  ____    ______    ____$$ |
//  $$ |__$$ | /      \ $$ |/$  \$$ |$$      \  /      \ $$$  \ /$$$ |/  |  /  | /       |/ $$   |  $$$  \$$ | /      \ / $$   |  $$ |__$$ | /      \ $$$  \$$ | /      \ /     \/    \  /      \  /    $$ |
//  $$    $$ |/$$$$$$  |$$ /$$$  $$ |$$$$$$$  |/$$$$$$  |$$$$  /$$$$ |$$ |  $$ |/$$$$$$$/ $$$$$$/   $$$$  $$ |/$$$$$$  |$$$$$$/   $$    $$< /$$$$$$  |$$$$  $$ | $$$$$$  |$$$$$$ $$$$  |/$$$$$$  |/$$$$$$$ |
//  $$$$$$$$ |$$    $$ |$$ $$/$$ $$ |$$ |  $$ |$$ |  $$ |$$ $$ $$/$$ |$$ |  $$ |$$      \   $$ | __ $$ $$ $$ |$$ |  $$ |  $$ | __ $$$$$$$  |$$    $$ |$$ $$ $$ | /    $$ |$$ | $$ | $$ |$$    $$ |$$ |  $$ |
//  $$ |  $$ |$$$$$$$$/ $$$$/  $$$$ |$$ |  $$ |$$ \__$$ |$$ |$$$/ $$ |$$ \__$$ | $$$$$$  |  $$ |/  |$$ |$$$$ |$$ \__$$ |  $$ |/  |$$ |__$$ |$$$$$$$$/ $$ |$$$$ |/$$$$$$$ |$$ | $$ | $$ |$$$$$$$$/ $$ \__$$ |
//  $$ |  $$ |$$       |$$$/    $$$ |$$ |  $$ |$$    $$/ $$ | $/  $$ |$$    $$/ /     $$/   $$  $$/ $$ | $$$ |$$    $$/   $$  $$/ $$    $$/ $$       |$$ | $$$ |$$    $$ |$$ | $$ | $$ |$$       |$$    $$ |
//  $$/   $$/  $$$$$$$/ $$/      $$/ $$/   $$/  $$$$$$/  $$/      $$/  $$$$$$/  $$$$$$$/     $$$$/  $$/   $$/  $$$$$$/     $$$$/  $$$$$$$/   $$$$$$$/ $$/   $$/  $$$$$$$/ $$/  $$/  $$/  $$$$$$$/  $$$$$$$/ 
//                                                                                                                                                                                                          
//                                                                                                                                                                                                          
//
//@version=5
//########################################### Strategy definition ######################################################/
strategy('Strategy Template - V2', overlay=true, initial_capital=20000, default_qty_type=strategy.percent_of_equity, 
         default_qty_value=100, commission_type=strategy.commission.percent, pyramiding=1, commission_value=0.11, 
         max_lines_count=500, max_labels_count=500, max_boxes_count=500)

//########################################### Entry and exit parameters ######################################################/
i_entryType = input.string('Stop', title='Entry Type', options=['Market', 'Stop', 'Limit', 'Stop-Limit'], group='Entry Parameters')
i_dcLength = input.int(40, step=10, title='Donchian Length', group='Entry Parameters')
i_htfResolution = input.timeframe('W', title='Higher Timeframe', group='Entry Parameters')

i_stopType = input.string('Stop', title='Stop Type', options=['Market', 'Stop'], group='Exit Parameters')
i_takeProfit = input.bool(false, title='Take Initial Profit', group='Exit Parameters')
i_takeProfitRR = input.float(10, step=0.5, title='Risk/Reward (Take Profit)', group='Exit Parameters')
i_takeProfitQty = input.int(30, step=5, minval=5, maxval=100, title='Take Profit Percent', group='Exit Parameters')
i_atrMaType = input.string('sma', title='ATR MA Type (Stop-Limit)', options=['sma', 'ema', 'hma', 'rma', 'vwma', 'wma'], group='Exit Parameters')
i_atrLength = input.int(22, title='ATR Length (Stop-Limit', step=5, group='Exit Parameters')
i_atrMultStop = input.float(0.5, step=0.5, title='ATR Multiplier (Stop-Limit)', group='Exit Parameters')

//############################################ Generic Strategy Parameters ###################################################/
i_tradeDirection = input.string(title='Trade Direction', defval=strategy.direction.all, options=[strategy.direction.all, strategy.direction.long, strategy.direction.short], group='Trade Filters')
strategy.risk.allow_entry_in(i_tradeDirection)
i_startTime = input.time(defval=timestamp('01 Jan 2010 00:00 +0000'), title='Start Time', group='Trade Filters')
i_endTime = input.time(defval=timestamp('01 Jan 2099 00:00 +0000'), title='End Time', group='Trade Filters')
inDateRange = time >= i_startTime and time <= i_endTime

//################################################## Generic Methods #########################################################/
f_secureSecurity(_symbol, _res, _src, _offset) =>
    request.security(_symbol, _res, _src[_offset], lookahead=barmerge.lookahead_on)

f_getMovingAverage(source, MAType, MALength) =>
    ma = ta.sma(source, MALength)
    if MAType == 'ema'
        ma := ta.ema(source, MALength)
        ma
    if MAType == 'hma'
        ma := ta.hma(source, MALength)
        ma
    if MAType == 'rma'
        ma := ta.rma(source, MALength)
        ma
    if MAType == 'vwma'
        ma := ta.vwma(source, MALength)
        ma
    if MAType == 'wma'
        ma := ta.wma(source, MALength)
        ma
    ma

f_getCustomAtr(MAType, MALength) =>
    f_getMovingAverage(ta.tr, MAType, MALength)

f_get_donchian(dcLength, resolution) =>
    top = resolution == '' ? ta.highest(dcLength) : f_secureSecurity(syminfo.tickerid, resolution, ta.highest(dcLength), 1)
    bottom = resolution == '' ? ta.lowest(dcLength) : f_secureSecurity(syminfo.tickerid, resolution, ta.lowest(dcLength), 1)
    mid = (top + bottom) / 2
    [mid, top, bottom]
//###################################################### Calculation and plot ##########################################################/

[mid, top, bottom] = f_get_donchian(i_dcLength, '')
[hmid, htop, hbottom] = f_get_donchian(i_dcLength, i_htfResolution)
atrStop = f_getCustomAtr(i_atrMaType, i_atrLength) * i_atrMultStop
p_top = plot(top, 'TOP', color=color.new(color.lime, 80))
p_bottom = plot(bottom, 'BOTTOM', color=color.new(color.orange, 80))
p_mid = plot(mid, 'MID', color=color.new(color.blue, 80))
fill(p_top, p_mid, title='Upper', color=color.new(color.lime, 80))
fill(p_bottom, p_mid, title='Lower', color=color.new(color.orange, 80))

p_htop = plot(htop, 'HTOP', color=color.new(color.green, 80))
p_hbottom = plot(hbottom, 'HBOTTOM', color=color.new(color.red, 80))
p_hmid = plot(hmid, 'HMID', color=color.new(color.purple, 80))
fill(p_htop, p_hmid, title='HTF Upper', color=color.new(color.green, 80))
fill(p_hbottom, p_hmid, title='HTF Lower', color=color.new(color.red, 80))

// ########################################### Trade conditions and levels ################################################/
longBias = bottom > hmid and inDateRange
shortBias = top < hmid and inDateRange

closeBuyCondition = strategy.position_size > 0
closeSellCondition = strategy.position_size < 0

// Market order conditions
buyMarketCondition = ta.crossover(high, top[1]) and i_entryType == 'Market'
sellMarketCondition = ta.crossunder(low, bottom[1]) and i_entryType == 'Market'
closeBuyMarketCondition = ta.crossunder(low, bottom[1]) and i_stopType == 'Market' and not longBias
closeSellMarketCondition = ta.crossover(high, top[1]) and i_stopType == 'Market' and not shortBias

// Stop order conditions
buySellStopCondition = i_entryType == 'Stop'
closeBuySellStopCondition = i_stopType == 'Stop'

// Limit and stoplimit conditions
buyLimitCondition = i_entryType == 'Limit' and high > mid
sellLimitCondition = i_entryType == 'Limit' and low < mid
buyStopLimitCondition = i_entryType == 'Stop-Limit' and ta.crossover(high, top[1])
sellStopLimitCondition = i_entryType == 'Stop-Limit' and ta.crossunder(low, bottom[1])
// Entry levels for long and short orders via Stop, Limit and Stop-Limit
buyLevel = top
sellLevel = bottom
buyStopLimit = top + atrStop
sellStopLimit = bottom - atrStop

// Exit levels for long and short - to be used in Stop orders
closeBuyStop = bottom
closeSellStop = top

// Take profit conditions and levels for long and short - to be used in Take Profit exit orders
takeProfitBuyCondition = longBias and strategy.position_size > 0 and i_takeProfit
takeProfitSellCondition = shortBias and strategy.position_size < 0 and i_takeProfit
profitLong = top + i_takeProfitRR * (top - bottom)
profitShort = bottom - i_takeProfitRR * (top - bottom)
profitLong := strategy.position_size <= 0 ? profitLong : high[1] > profitLong[1] ? profitLong[1] + i_takeProfitRR * (top - bottom) : profitLong[1]
profitShort := strategy.position_size >= 0 ? profitShort : low[1] < profitShort[1] ? profitShort[1] - i_takeProfitRR * (top - bottom) : profitShort[1]
// ########################################### Trade Statements Using If-Blocks ################################################/
//Entry for Long Orders
if longBias
    //Cancel short pending orders and close existing short trades
    strategy.cancel('Short')
    strategy.close('Short')
    //Long entry based on entry type - market, stop, limit or stop-limit
    if buyMarketCondition
        strategy.entry('Long', strategy.long, comment='Long-Market-Order')
    if buySellStopCondition
        strategy.entry('Long', strategy.long, stop=buyLevel, oca_name='oca_buy', oca_type=strategy.oca.cancel, comment='Long-Stop-Order')
    if buyLimitCondition
        strategy.entry('Long', strategy.long, limit=buyLevel, oca_name='oca_buy', oca_type=strategy.oca.cancel, comment='Long-Limit-Order')
    if buyStopLimitCondition
        strategy.entry('Long', strategy.long, limit=buyStopLimit, stop=buyLevel, oca_name='oca_buy', oca_type=strategy.oca.cancel, comment='Long-Stop-Limit-Order')

//Entry for Short Orders
if shortBias
    //Cancel long pending orders and close existing long trades
    strategy.cancel('Long')
    strategy.close('Long')
    //Short entry based on entry type - market, stop, limit or stop-limit
    if sellMarketCondition
        strategy.entry('Short', strategy.short, comment='Short-Market-Order')
    if buySellStopCondition
        strategy.entry('Short', strategy.short, stop=sellLevel, oca_name='oca_sell', oca_type=strategy.oca.cancel, comment='Short-Stop-Order')
    if sellLimitCondition
        strategy.entry('Short', strategy.short, limit=sellLevel, oca_name='oca_sell', oca_type=strategy.oca.cancel, comment='Short-Limit-Order')
    if sellStopLimitCondition
        strategy.entry('Short', strategy.short, limit=sellStopLimit, stop=sellLevel, oca_name='oca_sell', oca_type=strategy.oca.cancel, comment='Short-Stop-Limit-Order')

//Exit Long order market condition
if closeBuyCondition and closeBuyMarketCondition
    strategy.close('Long', comment='Close-Long-Market')
//Exit Short order by market condition
if closeSellCondition and closeSellMarketCondition
    strategy.close('Short', comment='Close-Short-Market')

//Exit by stoploss - Set stoploss beforehand
if closeBuySellStopCondition
    if closeBuyCondition
        strategy.exit('StopLong', 'Long', stop=closeBuyStop, comment='Close-Buy-Stop')
    if closeSellCondition
        strategy.exit('StopShort', 'Short', stop=closeSellStop, comment='Close-Sell-Stop')

// Take Profit for Long Order
if takeProfitBuyCondition
    strategy.exit('ProfitLong', 'Long', limit=profitLong, qty_percent=i_takeProfitQty, comment='Close-Buy-Profit')
// Take Profit for Short Order
if takeProfitSellCondition
    strategy.exit('ProfitShort', 'Short', limit=profitShort, qty_percent=i_takeProfitQty, comment='Close-Sell-Profit')

// ########################################### Trade Statements Using When - Alternative method ################################################/
// //Cancen pending orders when market changes its bias
// strategy.cancel("Long", when=shortBias)
// strategy.cancel("Short", when=longBias)

// //Close existing trades when market changes its bias
// strategy.close("Long", when=shortBias)
// strategy.close("Short", when=longBias)

// //Market orders when Entry Type = Market
// strategy.entry("Long", strategy.long, when=longBias and buyMarketCondition, comment = "Long-Market-Order")
// strategy.entry("Short", strategy.short, when=shortBias and sellMarketCondition, comment = "Short-Market-Order")

// //Stop orders when Entry Type = Stop (Buy at higher price and sell at lower price) - suitable for trend following methods
// strategy.entry("Long", strategy.long, when=longBias and buySellStopCondition, stop=buyLevel,
//                          oca_name="oca_buy", oca_type=strategy.oca.cancel, comment = "Long-Stop-Order")
// strategy.entry("Short", strategy.short, when=shortBias and buySellStopCondition, stop=sellLevel,
//                          oca_name="oca_sell", oca_type=strategy.oca.cancel, comment = "Short-Stop-Order")

// //Limit orders when Entry Type = Limit
// strategy.entry("Long", strategy.long, when=longBias and buyLimitCondition, limit=buyLevel,
//                          oca_name="oca_buy", oca_type=strategy.oca.cancel, comment = "Long-Limit-Order")
// strategy.entry("Short", strategy.short, when=shortBias and sellLimitCondition, stop=sellLevel,
//                          oca_name="oca_sell", oca_type=strategy.oca.cancel, comment = "Short-Limit-Order")

// //Stop-limit orders when Entry Type = Stop-Limit (Buy at higher price and sell at lower price but with protection) - suitable for trend following methods
// strategy.entry("Long", strategy.long, when=longBias and buyStopLimitCondition, limit=buyStopLimit, stop=buyLevel,
//                          oca_name="oca_buy", oca_type=strategy.oca.cancel, comment = "Long-Stop-Limit-Order")
// strategy.entry("Short", strategy.short, when=shortBias and sellStopLimitCondition, limit=sellStopLimit, stop=sellLevel,
//                          oca_name="oca_sell", oca_type=strategy.oca.cancel, comment = "Short-Stop-Limit-Order")

// // Stoploss - Exit by market
// strategy.close("Long", when=closeBuyCondition and closeBuyMarketCondition, comment="Close-Long-Market")
// strategy.close("Short", when=closeSellCondition and closeSellMarketCondition, comment="Close-Short-Market")

// // Stoploss - Exit by stop
// strategy.exit("StopLong", "Long", stop=closeBuyStop, when=closeBuyCondition and closeBuySellStopCondition, comment="Close-Buy-Stop")
// strategy.exit("StopShort", "Short", stop=closeSellStop, when=closeSellCondition and closeBuySellStopCondition, comment="Close-Sell-Stop")

// // Take Profit
// strategy.exit("ProfitLong", "Long", limit=profitLong, when=takeProfitBuyCondition, qty_percent=i_takeProfitQty, comment="Close-Buy-Profit")
// strategy.exit("ProfitShort", "Short", limit=profitShort, when=takeProfitSellCondition, qty_percent=i_takeProfitQty, comment="Close-Sell-Profit")
````
