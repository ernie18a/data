# Fibonacci EMA averages (21, 34, 55, 89, 144)

- url: https://www.tradingview.com/script/8qUg9GwB-Fibonacci-EMA-averages-21-34-55-89-144/
- type: strategy
- pine_id: PUB;gyN4QMC7GsOb58OEPWxKaBUqjFT4mXcd
- version: 1.0

## Description

Just a simple script that plots the following EMA averages that are based on the fibonacci sequence: 21, 34, 55, 89, 144

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © h311m4n

//@version=4
strategy("Fibonacci EMA averages",overlay=true)
ema21 = 21
ema34 = 34
ema55 = 55
ema89 = 89
ema144 = 144

ema_21 = ema(close, ema21)
ema_34 = ema(close, ema34)
ema_55 = ema(close, ema55)
ema_89 = ema(close, ema89)
ema_144 = ema(close, ema144)

plot(ema_21, color=color.red)
plot(ema_34, color=color.yellow)
plot(ema_55, color=color.green)
plot(ema_89, color=color.blue)
plot(ema_144, color=color.fuchsia)
````
