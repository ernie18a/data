# Short Swing Bearish MACD Cross (By Coinrule)

- url: https://www.tradingview.com/script/2bqf38Tw-Short-Swing-Bearish-MACD-Cross-By-Coinrule/
- type: strategy
- pine_id: PUB;43abc7b82f0a440b841235f0c13fb0eb
- version: 1.0

## Description

This strategy is oriented towards shorting during downside moves, whilst ensuring the asset is trading in a higher timeframe downtrend, and exiting after further downside. 

This script can work well on coins you are planning to hodl for long-term and works especially well whilst using an automated bot that can execute your trades for you. It allows you to hedge your investment by allocating a % of your coins to trade with, whilst not risking your entire holding. This mitigates unrealised losses from hodling as it provides additional cash from the profits made. You can then choose to hodl this cash, or use it to reinvest when the market reaches attractive buying levels. Alternatively, you can use this when trading contracts on futures markets where there is no need to already own the underlying asset prior to shorting it.  

[b]ENTRY [/b]

This script utilises the MACD indicator accompanied by the Exponential Moving Average (EMA) 450 to enter trades. The MACD is a trend following momentum indicator and provides identification of short-term trend direction. In this variation it utilises the 11-period as the fast and 26-period as the slow length EMAs, with signal smoothing set at 9.  

The EMA 450 is used as additional confirmation to prevent the script from shorting when price is above this long-term moving average. Once price is above the EMA 450 the script will not open any shorts - preventing the rule from attempting to short uptrends. Due to this, this strategy is ideal for setting and forgetting.  

The script will enter trades based on two conditions: 

1) When the MACD signals a bearish cross. This occurs when the EMA 11 crosses below the EMA 26 within the MACD signalling the start of a potential downtrend. 

2) Price has closed below the EMA 450.  Price closing below this long-term EMA signals that the asset is in a sustained downtrend. Price breaking above this could indicate a bullish strength in which shorting would not be profitable.  

[b]EXIT [/b]

This script utilises a set take-profit and stop-loss from the entry of the trade. The take profit is set at 8% and the stop loss of 4%, providing a risk reward ratio of 2.  This indicates the script will be profitable if it has a win ratio greater than 33%.  

Take-Profit Exit: -8% price decrease from entry price. 

OR

Stop-Loss Exit: +4% price increase from entry price. 

Based on backtesting results across a selection of assets, the 45-minute and 1-hour timeframes are the best for this strategy. 

The strategy assumes each order is using 30% of the available coins to make the results more realistic and to simulate you only ran this strategy on 30% of your holdings. A trading fee of 0.1% is also taken into account and is aligned to the base fee applied on Binance.

The backtesting data was recorded from December 1st 2021, just as the market was beginning its downtrend. We therefore recommend analysing the market conditions prior to utilising this strategy as it operates best on weak coins during downtrends and bearish conditions, however the EMA 450 condition should mitigate entries during bullish market conditions.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Coinrule

//@version=5
strategy("Shorting Bearish MACD Cross with Price Below EMA 450 (By Coinrule)", overlay=true, initial_capital = 10000, default_qty_value = 30, default_qty_type = strategy.percent_of_equity, commission_type=strategy.commission.percent, commission_value=0.1)

// EMAs 
slowEMA = ta.ema(close, 450)

// MACD
[macdLine, signalLine, histogramLine] = ta.macd(close, 11, 26, 9)

// Conditions
goShortCondition1 = ta.crossunder(macdLine, signalLine)
goShortCondition2 = slowEMA > close

timePeriod = time >= timestamp(syminfo.timezone, 2021, 12, 1, 0, 0)
notInTrade = strategy.position_size <= 0
strategyDirection = strategy.direction.short

if (goShortCondition1 and goShortCondition2 and timePeriod and notInTrade)
    stopLoss = high * 1.04
    takeProfit = low * 0.92
    strategy.entry("Short", strategy.short)
    strategy.exit("exit","Short", stop=stopLoss, limit=takeProfit)
    
plot(slowEMA, color=color.green)
````
