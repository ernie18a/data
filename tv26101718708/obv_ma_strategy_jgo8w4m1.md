# OBV MA Strategy

- url: https://www.tradingview.com/script/Jgo8w4m1-OBV-MA-Strategy/
- type: strategy
- pine_id: PUB;15df0c1b0cc94452b577524a354e1bde
- version: 4.0

## Description

The On Balance Volume + Moving Average Strategy 

Parameters: 1H candles, ETHUSDT on BINANCEUS, commission percent uses Binance's maker/taker fees of 0.075%
Strategy: I create a 30 day moving average of the On Balance Volume "obvSma = ta.sma(ta.obv, 30)." Then I use the following buy conditions:

[list]
[*] OBV crosses above the OBV moving average
[*] The obv drops x% below the OBV moving average (buy a dip)
[*] The OBV moving average is rising, the OBV is greater than the OBV moving average and the OBV is rising
[/list]

The first buy condition is attempting to buy into an uptrend. When the OBV rises above the OBV moving average, people are buying and it's a good time to enter the trade. 
The idea behind the second buy condition is to buy a dip so make sure you are careful to not set it too shallow or you'll end up buying the dip before the dip before the dip. :) I recommend 10% or more. 
The third buy condition is there in case our trailing stop takes us out of a trade but the trend is still rising, we don't want to miss out on that profit so if the OBV is above the OBV moving average, the average is rising and the OBV is rising, we are likely in the middle of an uptrend and we should buy in.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © sonnyparlin

//@version=5
strategy("OBV Strategy V2", overlay=true, 
     commission_type=strategy.commission.percent, 
     currency=currency.USD, 
     commission_value=0.075,
     slippage=2, initial_capital=10000)

plot(close)

// Removed script
````
