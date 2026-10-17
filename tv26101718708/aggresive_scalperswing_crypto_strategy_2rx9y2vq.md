# Aggresive Scalper/Swing Crypto Strategy

- url: https://www.tradingview.com/script/2Rx9y2VQ-Aggresive-Scalper-Swing-Crypto-Strategy/
- type: strategy
- pine_id: PUB;50fed3ab2b8a44a3a4079a1c7a7ac9d9
- version: 1.0

## Description

This is a simple yet very efficient scalper long strategy adapted for low timeframes for crypto. Can also be used with bigger timeframes as a swinger.

Its main components are:

Price oscillator swing
Vortex
Risk management for TP/SL


Rules for entry
We calculate the difference between the oscillator from the lowest low and the highest high. If the difference is positive, its a long potential. If its negative we exit from the long trade.
At the same time we check that the we have a crossover between the VIP vortex with the VIM vortex part.
Lastly we check that the current candle is bigger the second previous high.

Rules for exit
If we reach the take profit or the stop loss.
If we have a negative difference betwee LL and HH and VIP vortex crossunder with VIM vortex .


In this example I aimed for a 1:10 risk reward ratio, meaing that for every dollar lost, we will gain 10 when we win. Thus having a 10% minimum win rate will give us a profit over many trades.


If you have any questions, let me know !

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © exlux99
//@version=4
strategy(title="Crypto Price Scalper", shorttitle="Scalper Crypto", overlay=true)

inputcc = input(60, title="Number of candles")


low9=lowest(low,inputcc)
high9=highest(high,inputcc)



plotlow = ((close - low9) / low9) * 100

plothigh = ((close - high9) / high9) * 100

plotg = (plotlow +plothigh)/2

center=0.0


period_ = input(14, title="Length VORTEX", minval=2)
VMP = sum( abs( high - low[1]), period_ )
VMM = sum( abs( low - high[1]), period_ )
STR = sum( atr(1), period_ )
VIP = VMP / STR
VIM = VMM / STR


long= crossover(plotg,center) and close > high[2] and crossover(VIP,VIM)
short= crossunder(plotg,center) and crossunder(VIP,VIM)

tplong=input(0.1, title="TP Long", step=0.01)
sllong=input(0.1, title="SL Long", step=0.01)
strategy.entry("long",1,when=long)

strategy.exit("closelong", "long" , profit = close * tplong / syminfo.mintick, loss = close * sllong / syminfo.mintick, alert_message = "closelong")

strategy.close("long",when=short)
````
