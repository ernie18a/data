# DLB by Henri n Marcos

- url: https://www.tradingview.com/script/7qXpFIAz-DLB-by-Henri-n-Marcos/
- type: strategy
- pine_id: PUB;dNLltUnRPPsLXkIRMmD6OqUdMKp9QcW9
- version: 1.0

## Description

A oscilator indicator made by newbies.

## Source Code

````pine
//@version=4
strategy(title="DLBNOVO", shorttitle="DLB", format=format.price, precision=2)
smoothK = input(3, minval=1)
smoothD = input(3, minval=1)
lengthRSI = input(8, minval=1)
lengthStoch = input(13, minval=1)
src = input(close, title="RSI Source")

rsi1 = rsi(src, lengthRSI)
k = sma(stoch(rsi1, rsi1, rsi1, lengthStoch), smoothK)
d = sma(k, smoothD)
plot(k, color=color.green)
plot(d, color=color.red)
h0 = hline(80)
h1 = hline(20)
fill(h0, h1, color=color.purple, transp=80)
````
