# "Sell in May, buy in September"-Strategy

- url: https://www.tradingview.com/script/C2qlt3mi-Sell-in-May-buy-in-September-Strategy/
- type: strategy
- pine_id: PUB;148de0415f464e79a539bb8d8ca12bfe
- version: 1.0

## Description

Dear TV'ers,

This script applies the classic traders mantra of "Sell in May, buy in September".  Not much else to it to be honest. Seems to work though :-).

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © DynamicSignalLab

//@version=5
strategy("Sell in May, buy in September Strategy", overlay=false)

longCondition = month==9
closecondition = month==5

if longCondition
    strategy.entry("long", strategy.long)

if closecondition
    strategy.close("long", when=closecondition)
````
