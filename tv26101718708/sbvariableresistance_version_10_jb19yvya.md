# SB_Variable_Resistance Version 1.0

- url: https://www.tradingview.com/script/JB19yvya-SB-Variable-Resistance-Version-1-0/
- type: strategy
- pine_id: PUB;UJJ9ABZ9LZwMGiHl2bFNCIt88tImvRXv
- version: 1.0

## Description

It is a simple test strategy. 
The strategy involves variable resistance.
If the price closes above the resistance a long order is placed and when price closes below the resistance a short order is placed.



Comment the perfect combination of indicators for it and will try to incorporate those indicators into it in the next version. 

Message if you think of any modifications/ enhancements/ any opportunities. :) 

Donations/Tips... :) - 

BTC: 1BjswGcRR6c23pka7qh5t5k56j46cuyyy2 
ETH: 0x64fed71c9d6c931639c7ba4671aeb6b05e6b3781 
LTC: LKT2ykQ8QSzzfTDB6Tnsf12xwYPjgq95h4

## Source Code

````pine
//@version=3

strategy("SB_Variable_Resistance Version 1.0", overlay=true)
res=(valuewhen(high<high[1] , high[1] , 1))

plot(res)

if(close[1]>=res)
    strategy.entry("RsiLE", strategy.long, comment="RsiLE")
if(close[1]<res)
    strategy.entry("RsiLE", strategy.short, comment="RsiSE")
````
