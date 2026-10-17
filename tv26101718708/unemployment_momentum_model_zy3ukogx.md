# Unemployment Momentum Model

- url: https://www.tradingview.com/script/zy3UKOGx-Unemployment-Momentum-Model/
- type: strategy
- pine_id: PUB;u1GumTsJwz1zi7IHhgkdx85L7G91oj2X
- version: 1.0

## Description

This model uses a Smoothed RSI to measure the momentum of the Civilian Unemployment Rate as published by FRED. The behavior of the unemployment rate makes it ideal for applying momentum-based timing techniques because it tends to rise sharply in a short time period and then declines gradually over a longer period. Using other basic momentum-based timing techniques also works well (e.g., EMA crossover, MACD, ROC, etc.)

Please note that you cannot trade the unemployment rate directly. This model is meant to help you understand the state of the current economy in the context of unemployment.

## Source Code

````pine
//@version=2
strategy("Unemployment Momentum Model", overlay=true)

price = close

basis = rsi(price, input(3))
rsiema = ema(basis, input(6))
trigger = input(50)

strategy.risk.allow_entry_in(strategy.direction.long)

if (crossover(rsiema, trigger))
    strategy.entry("RISING", strategy.long, comment="RISING")

if (crossunder(rsiema, trigger))
    strategy.entry("FALLING", strategy.short, comment="FALLING")
````
