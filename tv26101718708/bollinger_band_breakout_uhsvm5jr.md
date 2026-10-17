# Bollinger Band Breakout

- url: https://www.tradingview.com/script/UHsvM5JR-Bollinger-Band-Breakout/
- type: strategy
- pine_id: PUB;H3ktFa7rSU73W7VYOrWZOcyolVMtXCxj
- version: 2.0

## Description

It is a long only strategy.

1. Buy when price breaks out of the upper band.
2. Exit has two options. Option 1 allows you to exit using lower band. Option 2 allows you to exit using moving average.
3. Option 1 preferred over option 2 if the instrument is highly volatile.
4. Slippage and commissions are not considered in the return calculation.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Senthaamizh

//@version=4
strategy(title="Bollinger Band Breakout", shorttitle = "BB-BO",default_qty_type = strategy.percent_of_equity,default_qty_value = 100, overlay=true)
source = close
length = input(20, minval=1, title = "Period") //Length of the Bollinger Band 
mult = input(1.5, minval=0.001, maxval=50, title = "Standard Deviation") // Use 1.5 SD for 20 period MA; Use 2 SD for 10 period MA 
exit = input(1, minval=1, maxval=2,title = "Exit Option") // Use Option 1 to exit using lower band; Use Option 2 to exit using moving average

basis = sma(source, length)
dev = mult * stdev(source, length)

upper = basis + dev
lower = basis - dev

if (crossover(source, upper))
    strategy.entry("Long", strategy.long)

if(exit==1)
    if (crossunder(source, lower))
        strategy.close("Long")

if(exit==2) //basis is good for N50 but lower is good for BN (High volatility)
    if (crossunder(source, basis))
        strategy.close("Long")

plot(basis, color=color.red,title= "SMA")
p1 = plot(upper, color=color.blue,title= "UB")
p2 = plot(lower, color=color.blue,title= "LB")
fill(p1, p2)
````
