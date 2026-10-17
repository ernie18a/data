# Jaws Mean Reversion [Strategy]

- url: https://www.tradingview.com/script/RZ1GZGP3-Jaws-Mean-Reversion-Strategy/
- type: strategy
- pine_id: PUB;8D72AqQdE3LiArfFasXA1l6GL588aFrh
- version: 2.0

## Description

This very simple strategy is an implementation of PJ Sutherlands' Jaws Mean reversion algorithm. It simply buys when a small moving average period (e.g. 2) is below
a longer moving average period (e.g. 5) by a certain percentage and closes when the small period average crosses over the longer moving average. 

If you are going to use this, you may wish to apply this to a range of investment assets using a screener for setups, as the amount signals are low. Alternatively, you may wish to tweak the settings to provide more signals.

Context can be found here:

[url=https://blog.sutherlandresearch.com/index.php/2017/05/26/a-simple-mean-reversion-strategy/]LINK[/url]

## Source Code

````pine
// @version=4
//
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//
// @author Sunil Halai
//
// This very simple strategy is an implementation of PJ Sutherlands' Jaws Mean reversion algorithm. It simply buys when a small moving average period (e.g. 2) is below
// a longer moving average period (e.g. 8) by a certain percentage, and closes when the small period average crosses over the longer moving average. 
// 
// If you are going to use this, you may wish to apply this to a range of investment assets, as the amount signals is low. Alternatively you may wish to tweak the settings to provide more
// signals.


strategy("Jaws Mean Reversion [Strategy]", overlay = true)

//Strategy inputs
source = input(title = "Source", defval = close)
smallMAPeriod = input(title = "Small Moving Average", defval = 2)
bigMAPeriod = input(title = "Big Moving Average", defval = 8)
percentBelowToBuy = input(title = "Percent below to buy %", defval = 1)


//Strategy calculation
smallMA = sma(source, smallMAPeriod)
bigMA =  sma(source, bigMAPeriod) 
buyMA = ((100 - percentBelowToBuy) / 100) * sma(source, bigMAPeriod)[0]

if(crossunder(smallMA, buyMA))
    strategy.entry("BUY", strategy.long)

if(crossover(smallMA, bigMA))
    strategy.close("BUY")
````
