# BTC Hashrate ribbons

- url: https://www.tradingview.com/script/w6QJPRr3-BTC-Hashrate-ribbons/
- type: strategy
- pine_id: PUB;d2d6b45a91c848f89b9ef8d2a6fd869d
- version: 4.0

## Description

BTC Hash Rate ribbons / Hash Rate cross

This strategy goes long when BTCs Hash Rate 30 day moving average crosses above the 60 day moving average, signifying that miner capitulation is over and recovery has started.
When the opposite signal is given, which signifies the beginning of miner capitulation, the strategy goes short (or flat, depending on configuration). This is generally considered the most popular Hash Rate related strategy.

The strategy is based on this medium article: https://medium.com/capriole/hash-ribbons-bitcoin-bottoms-60da13095836

Thanks to the recent integration of IntoTheBlock data into Tradingview, we can now effortlessly show Hash Rate data on our chart,
keep in mind however, that IntoTheBlock doesn't provide Hash Rate data on timeframes below daily, so this strategy is based used on the daily, weekly or even monthly time frames.

Hash Rate definition:
The Bitcoin hash rate is the number of times per second that computers on the Bitcoin network are hashing data to verify transactions and perform the encryption that secures the network. The hash rate is an indicator of how healthy the Bitcoin network is at any given time, and is driven primarily by difficulty mining and the number of miners. Generally, a high hash rate is considered a good thing.
More precisely, the Bitcoin hash rate is the number of times per second that computers on the Bitcoin network are hashing data to verify transactions and perform the encryption that secures the network.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Powerscooter
// Since IntoTheBlock only provides daily hashrate data, this chart might look chunky on lower timeframes, even with smoothing.

//@version=5
strategy("BTC Hashrate ribbons", overlay = true, scale=scale.none, default_qty_type = strategy.cash, default_qty_value = 100, initial_capital = 100)
enableDirection = input(0, title="Both(0), Long(1), Short(-1)", group="Direction")
smoothingS = input.string(title="Smoothing short MA", defval="SMA", options=["SMA", "RMA", "EMA", "WMA"], group="Hashrate Settings")
SmoothLengthS = input(30, 'Short MA length', group="Hashrate Settings")
smoothingL = input.string(title="Smoothing long MA", defval="SMA", options=["SMA", "RMA", "EMA", "WMA"], group="Hashrate Settings")
SmoothLengthL = input(60, 'Long MA length', group="Hashrate Settings")
ma_functionS(source, length) =>
	switch smoothingS
		"RMA" => ta.rma(source, length)
		"SMA" => ta.sma(source, length)
		"EMA" => ta.ema(source, length)
		=> ta.wma(source, length)
ma_functionL(source, length) =>
	switch smoothingL
		"RMA" => ta.rma(source, length)
		"SMA" => ta.sma(source, length)
		"EMA" => ta.ema(source, length)
		=> ta.wma(source, length)

Source = input.string(title="Data Source", defval="Quandl", options=["Quandl", "Glassnode", "IntoTheBlock"], group="Source Settings")
SourceE = switch Source
	"Quandl" => "QUANDL:BCHAIN/HRATE"
	"Glassnode" => "GLASSNODE:BTC_HASHRATE"
	"IntoTheBlock" => "INTOTHEBLOCK:BTC_HASHRATE"
HashRate = request.security(SourceE, "D", close)

SignalLine = ma_functionS(HashRate, SmoothLengthS)
LongLine = ma_functionL(HashRate, SmoothLengthL)

plot(ma_functionS(HashRate, SmoothLengthS), "Short MA", color=color.yellow)
plot(ma_functionL(HashRate, SmoothLengthL), "Long MA", color=color.blue)

LongCondition = ta.crossover(SignalLine, LongLine)
ShortCondition = ta.crossunder(SignalLine, LongLine)

//Long Entry Condition
if LongCondition and (enableDirection == 1 or enableDirection == 0)
    strategy.entry("Long", strategy.long)
if LongCondition and (enableDirection == -1)
    strategy.close("Short")

//Short Entry condition
if ShortCondition and (enableDirection == -1 or enableDirection == 0)
    strategy.entry("Short", strategy.short)
if ShortCondition and (enableDirection == 1)
    strategy.close("Long")
````
