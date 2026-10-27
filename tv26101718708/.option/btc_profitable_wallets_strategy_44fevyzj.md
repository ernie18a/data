# BTC Profitable Wallets Strategy

- url: https://www.tradingview.com/script/44FEvYZj-BTC-Profitable-Wallets-Strategy/
- type: strategy
- pine_id: PUB;101c04f7cd154eddaefb8db280cfcf58
- version: 4.0

## Description

[b]BTC Profitable Wallets Strategy[/b] - plots the percentage of profitable BTC wallets and places long orders when the profitable wallet share crosses above 50%, historically a very accurate point to catch the next Bull Run early.

The only setting is a smoothing option using the Moving Average method and length of your choice.

On Chain Data is queried from IntoTheBlock.

This is a 'HODL' strategy, with no exit given. If you'd like to see the historical performance check the Open Profit or place a sell order at the current date.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Powerscooter
// Since IntoTheBlock only provides daily onchain data, this chart might look chunky on lower timeframes, even with smoothing.

//@version=5
strategy("BTC % profitable wallets", overlay=false, default_qty_type = strategy.cash, default_qty_value = 100, initial_capital = 100, pyramiding=100)
Source = input.string(title="Blockchain", defval="BTC", options=["BTC", "ETH", "DOGE", "ADA", "MATIC", "SHIB", "UNI", "OKB", "LEO", "LINK", "LTC", "FTT", "CRO", "ALGO",
 "QNT", "BCH", "SAND", "MANA", "FXS", "AAVE", "CHZ", "HT", "LDO", "KCS", "AXS", "MKR", "ZEC", "GRT", "FTM", "SNX", "NEXO", "CRV", "BIT", "DASH", "BAT", "ENS"], group="Inputs")
Threshold = input.int(50, "% Threshold", minval = 0, maxval = 100)
smoothing = input.string(title="Smoothing", defval="SMA", options=["SMA", "RMA", "EMA", "WMA"], group="Smoothing Settings")
ma_function(source, length) =>
	switch smoothing
		"RMA" => ta.rma(source, length)
		"SMA" => ta.sma(source, length)
		"EMA" => ta.ema(source, length)
		=> ta.wma(source, length)
SmoothLength = input(1, 'MA Length', group="Smoothing Settings")
Ticker = "INTOTHEBLOCK:" + Source + "_INOUTMONEYINPERCENTAGE"
Wallets = request.security(Ticker, "D", close)
ProfitWallets = plot(100*ma_function(Wallets, SmoothLength), "Profitable wallets", color=color.white, transp = 50)
TresholdLine = plot(Threshold, transp=100, editable=false, display=display.none) //We need this invisible line for the fill command, as it doesn't accept variables of type int.
fill(ProfitWallets, TresholdLine, Wallets > (Threshold/100) ? color.new(color.green, 90) : color.new(color.red, 90))

if ta.crossover(Wallets, (Threshold/100))
    strategy.entry("Long", strategy.long)
````
