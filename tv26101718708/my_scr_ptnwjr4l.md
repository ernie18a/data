# my scr

- url: https://www.tradingview.com/script/ptNWjR4L-my-scr/
- type: strategy
- pine_id: PUB;dkRBjYIT1uu3kiE7YKpGK2TUIEthmem7
- version: 1.0

## Description

simple

## Source Code

````pine
strategy("my scr", overlay = true)

ma = sma(close, 30)

entry() => crossover(close, ma)
exit() => crossover(close, ma)

strategy.entry(id = "lona_ma", long = true, when = entry())
strategy.close(id = "long_ma", when = exit())

plot(ma)
````
