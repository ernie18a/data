# VOLLY PRICE CONVERGE

- url: https://www.tradingview.com/script/dmQs0fRa-VOLLY-PRICE-CONVERGE/
- type: strategy
- pine_id: PUB;dfcfa2066a6a45e582ae0bf6b422167a
- version: 1.0

## Description

Triggers:
Long = Price and Volume ma's move up
Close trade = crosses ma, volume and price move in different directions

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Celar

//@version=5
strategy("VOLLY PRICE CONVERGE", default_qty_type= strategy.percent_of_equity )
base_sma = ta.sma(close, 10)
vol_sma5 = ta.hma(volume, 15)
price_sma5 = ta.hma(close, 15)
ma50 = ta.sma(close, 50)
ma20 = ta.sma(close, 20)
int vol_indicator = na
int price_indicator = na

if vol_sma5 > vol_sma5[1]
    vol_indicator := 1
else
    vol_indicator := 0

if price_sma5 > price_sma5[1]
    price_indicator := 1
else
    price_indicator := 0
        
signal = vol_indicator + price_indicator

colour = signal == 2 ?  #00802b : signal == 1 ? #cc2900 : color.white 

bank_roll = strategy.equity
qty = bank_roll/close

strategy.entry("Long", strategy.long, qty, when = signal == 2 and close > base_sma)
// Generate a full exit bracket (profit 10 points, loss 5 points per contract) from the entry named "Long".
strategy.close("Long", when = signal == 1 or signal == 0 or close < base_sma )
````
