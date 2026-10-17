# Coinbook Statergy by shakir

- url: https://www.tradingview.com/script/qP8fW2YG-Coinbook-Statergy-by-shakir/
- type: strategy
- pine_id: PUB;rdi2okaCBU8e0jeMsO5r7bycTGEge2Kb
- version: 1.0

## Description

Buy sell signal

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ayahanisha4

//@version=4 
strategy("Coinbook", overlay=true, initial_capital=1000, pyramiding=1, default_qty_type=strategy.cash, default_qty_value=1000) 

selltrigger = 0 
selltrigger := nz(selltrigger[1])

if close[1] < sma(close[1], 50) and sma(close[1], 50) < sma(close[1], 100) and sma(close[1], 100) < sma(close[1], 200) and (close >= sma(close, 50) or sma(close, 50) >= sma(close, 100) or sma(close, 100) >= sma(close, 200)) 
    strategy.entry("Buy", strategy.long) 
   
if close > sma(close, 50) and sma(close, 50) > sma(close, 100) and sma(close, 100) > sma(close, 200) and close[1] > sma(close[1], 50) and sma(close[1], 50) > sma(close[1], 100) and sma(close[1], 100) > sma(close[1], 200) and strategy.position_size > 0 
    selltrigger := 1 
    
if close < sma(close, 50) and selltrigger == 1 
    strategy.close("Buy") 
    selltrigger := 0
````
