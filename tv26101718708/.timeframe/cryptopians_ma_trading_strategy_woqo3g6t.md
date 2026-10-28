# Cryptopians - MA Trading Strategy

- url: https://www.tradingview.com/script/wOqo3G6t-Cryptopians-MA-Trading-Strategy/
- type: strategy
- pine_id: PUB;eOXyWvbRG7sfqzv9PUjIV0DtOmlC9ZwE
- version: 5.0

## Description

Simple moving average trading strategy.

Based on:
[list]
[*] 10 MA
[*] 20 MA
[*] Daily timeframe
[/list]

## Source Code

````pine
//@version=4
strategy("Cryptopians - MA Trading Strategy", shorttitle="MA Trading Strategy", overlay=true)

ha_symbol = heikinashi(syminfo.tickerid)
ha_period = "D"

ha_open = security(ha_symbol, ha_period, open)
ha_close = security(ha_symbol, ha_period, close)

fast = sma(close, 10)
slow = sma(close, 20)

plot(fast, color=color.green, linewidth=3, editable=false)
plot(slow, color=color.red, linewidth=3, editable=false)

long_condition = ha_close > fast
long_exit_condition = ha_close < ha_open

short_condition = ha_close < fast
short_exit_condition = ha_close > ha_open

strategy.entry("long", strategy.long, when=long_condition, comment="LONG")
strategy.close("long", when=long_exit_condition)

strategy.entry("short", strategy.short, when=short_condition, comment="SHORT")
strategy.close("short", when=short_exit_condition)
````
