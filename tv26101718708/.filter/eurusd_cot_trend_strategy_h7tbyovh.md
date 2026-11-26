# EURUSD COT Trend Strategy

- url: https://www.tradingview.com/script/h7tByovH-EURUSD-COT-Trend-Strategy/
- type: strategy
- pine_id: PUB;54e5b11665384565a73f0d3956490715
- version: 1.0

## Description

This is a long term/investment type of strategy designed to have a good idea about where the big trend direction is headed.

Its logic, its made entirely on the COT report, mainly from looking into the net non comercial positions aka the speculators.

For bullish trend we look that the difference between long non comercial vs short non comercial is higher than 0
For bearish trend we look that the difference between long non comercial vs short non comercial is lower than 0.


This is mainly as an educational tool, for a full strategy, I recommend implement other things into it, like technical analysis or risk management.


If you have any questions, please let me know !

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © exlux99

//@version=5
strategy("EURUSD COT Strategy",overlay=true)

long_noncom   = request.security("QUANDL:CFTC/"+'099741'+'_F_L_ALL|1', "W", close) 
short_noncom  = request.security("QUANDL:CFTC/"+'099741'+'_F_L_ALL|2', "W", close) 
net_noncomercial = long_noncom-short_noncom

long = net_noncomercial > 0 
short = net_noncomercial < 0 



strategy.entry("long",strategy.long,when=long)
strategy.entry("short",strategy.short,when=short)
````
