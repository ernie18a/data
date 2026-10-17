# CROSS_ALGO SYSTEM

- url: https://www.tradingview.com/script/uM3SMvsM-CROSS-ALGO-SYSTEM/
- type: strategy
- pine_id: PUB;a8349ef071734125898216b587deb28a
- version: 1.0

## Description

Crossover Strategy using exponential moving averages with entry and exits.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © himanshumahalle

//@version=4
strategy("CROSS_ALGO SYSTEM")


// INPUT CONTROLS

lengthSEMA= input(title="LSEMA", type = input.integer, defval=13,minval=1,maxval=100,step=1)
lengthLEMA= input(title="LLEMA", type = input.integer, defval=50,minval=1,maxval=100,step=1)

//INDICATOR

SEMA= ema(close,lengthSEMA)
LEMA= ema(close,lengthLEMA)

// BUY AND SELL

buy = crossover(SEMA,LEMA)
sell = crossunder(SEMA,LEMA)

//EXITS

buyexit = crossunder(SEMA,LEMA)
sellexit = crossover(SEMA,LEMA)


//EXECUTION

strategy.entry("long",strategy.long,when=buy,comment = "Buy")
strategy.entry("short",strategy.short,when=sell,comment = "Sell")

strategy.close("long",when= buyexit , comment= "Sell")
strategy.close("short",when= sellexit , comment= "Buy")
````
