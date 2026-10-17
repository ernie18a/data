# Ricky Parker's formula

- url: https://www.tradingview.com/script/x7t6jzpo-Ricky-Parker-s-formula/
- type: strategy
- pine_id: PUB;6o4nG7VsxR1wAlgSBEEIDgxT0sTGklbO
- version: 2.0

## Description

Ricky Parker's formula

## Source Code

````pine
//@version=1
strategy("Ricky Parker's formula",overlay=false) 
a = ema(close , 5)
b = ema(close , 10)
long = cross (a, b) and  a > b
short = cross(a, b) and  a < b
strategy.entry("long" , strategy.long,when=long)
strategy.entry("short",strategy.short,when=short)
plot(long,"long",color=green,linewidth=1)
plot(short,"short",color=red,linewidth=1)
````
