# [STRATEGY][RS]The Illusion Strategy V0

- url: https://www.tradingview.com/script/UTnFqsyC-STRATEGY-RS-The-Illusion-Strategy-V0/
- type: strategy
- pine_id: PUB;1839
- version: -1.0

## Description

EXPERIMENTAL:
WARNING: this strategy does not work!!
one of the fallacy's of backtesting, renko chars signals usually will give signals when price is allready out of range.

## Source Code

````pine
//@version=2
strategy(title='[STRATEGY][RS]The Illusion Strategy V0', shorttitle='S', overlay=true, pyramiding=3, initial_capital=100000)
trade_size = 10000

buy_entry = close > open
sel_entry = close < open

strategy.entry('buy', long=strategy.long, qty=trade_size, comment='buy', when=buy_entry)
strategy.entry('sell', long=strategy.short, qty=trade_size, comment='sell', when=sel_entry)
````
