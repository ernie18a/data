# EMA 5,15,35,89,200 BY NUT

- url: https://www.tradingview.com/script/O4vhK1BK/
- type: strategy
- pine_id: PUB;e6e91ec168a944aa84717026bd90e474
- version: 1.0

## Description

Plots exponential moving average on four timeframes at once for rapid indication of momentum shift as well as slower-moving confirmations.

Displays EMA 5, 15, 35, 89 and 200... default colors are hotter for faster timeframes, cooler for slower ones 

ขอบคุณครับ

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © samatchanut

//@version=4
strategy("EMA 5,15,35,89,200 BY NUT",overlay =1)
a = input(title="EMA_a length", type=input.integer, defval=5, minval=-3, maxval=200)
b = input(title="EMA_b length", type=input.integer, defval=15, minval=-3, maxval=200)
c = input(title="EMA_c length", type=input.integer, defval=35, minval=-3, maxval=200)
d = input(title="EMA_d length", type=input.integer, defval=89, minval=-3, maxval=200)
e = input(title="EMA_e length", type=input.integer, defval=200, minval=-3, maxval=200)
maf5=ema(close,a)
mas15=ema(close,b)
mas35=ema(close,c)
maa89=ema(close,d)
mab200=ema(close,e)
plot(maf5,color=color.white)
plot(mas15,color=color.red)
plot(mas35,color=color.green)
plot(maa89,color=color.blue)
plot(mab200,color=color.orange)
````
