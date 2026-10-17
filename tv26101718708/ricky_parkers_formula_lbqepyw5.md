# Ricky Parker's formula

- url: https://www.tradingview.com/script/LbqEPYw5-Ricky-Parker-s-formula/
- type: strategy
- pine_id: PUB;JEx4ZQovnPMHObtTFKnDne9gVsGRtpCj
- version: 1.0

## Description

Ricky Parker's formula

## Source Code

````pine
//@version=1
strategy("Ricky Parker's formula")
a = ema(close , 5)
b = ema(close , 15)
long = cross (a, b) and  a > b
short = cross(a, b) and  a < b
strategy.entry("long" , strategy.long,when=long)
strategy.entry("short",strategy.short,when=short)
````
