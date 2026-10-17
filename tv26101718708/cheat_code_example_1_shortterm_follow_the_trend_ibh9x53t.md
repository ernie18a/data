# Cheat Code- Example 1; Short-Term; Follow the Trend 

- url: https://www.tradingview.com/script/IBh9X53T-Cheat-Code-Example-1-Short-Term-Follow-the-Trend/
- type: strategy
- pine_id: PUB;95d1643da0744bc09836dca69e4b3aad
- version: 1.0

## Description

[symbol="BINANCE:BTCUSDT"]BINANCE:BTCUSDT[/symbol];[symbol="BINANCE:ETHUSDT"]BINANCE:ETHUSDT[/symbol];[symbol="BINANCE:FILUSDT"]BINANCE:FILUSDT[/symbol];

This strategy is simple and easy to read and takes advantage of conditional signs of trend reversals. It works best in 10-minute time frames for most large and mid-cap crypto. This code is a tutorial for creating a profitable yet easy strategy, and hopefully, it can be put to good use [b]:) [/b]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © cpirkk

//@version=5

//SUBSCRIBE TO CHEAT CODE!!!
//
//

//
//SUBSCRIBE TO CHEAT CODE!!!
strategy("Cheat Codes Example", overlay = true)

//RSI

rsi = ta.rsi(close, 14)


//ENTRY

LC1 = ta.crossover(ta.sma(close,21), ta.sma(close,100))
LC2 = ta.sma(close, 200) > close
if (LC1) and (LC2) 
    strategy.entry("BULL CALL", strategy.long)
    

SC1 = ta.sma(close, 200) < close
SC2 = ta.crossunder(rsi, 55)
if (SC1) and (SC2)
    strategy.entry("BEAR CALL", strategy.short)
    
    // BEST PAIRINGS:
    // BTC: 10M
    // MATIC: 10M
    // ETH: 10M
    // FIL: 10M
    // :)
````
