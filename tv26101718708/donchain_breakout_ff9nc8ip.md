# Donchain Breakout

- url: https://www.tradingview.com/script/fF9nC8iP-Donchain-Breakout/
- type: strategy
- pine_id: PUB;dKXl3YGGj6PctfqS2DqrXZ1msKInKaC9
- version: 1.0

## Description

It is a long only strategy.

1. Buy when price breaks out of the upper band.
2. Exit has two options. Option 1 allows you to exit using lower band. Option 2 allows you to exit using basis line.
3. Slippage and commissions are not considered in the return calculation.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Senthaamizh

//Break out trading system works best in a weekly chart and daily chart of Nifty and BankNifty
//@version=4

strategy("Donchain BO",shorttitle = "DBO",default_qty_type = strategy.percent_of_equity,default_qty_value = 100, overlay=true)
length = input(20, minval=1)
exit = input(1, minval=1, maxval=2,title = "Exit Option") // Use Option 1 to exit using lower band; Use Option 2 to exit using basis line

lower = lowest(length)
upper = highest(length)
basis = avg(upper, lower)

l = plot(lower, color=color.blue)
u = plot(upper, color=color.blue)
plot(basis, color=color.orange)
fill(u, l, color=color.blue)

longCondition = crossover(close,upper[1])
if (longCondition)
    strategy.entry("Long", strategy.long)

if(exit==1)
    if (crossunder(close,lower[1]))
        strategy.close("Long")

if(exit==2) 
    if (crossunder(close,basis[1]))
        strategy.close("Long")
````
