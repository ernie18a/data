# MMTW indicator

- url: https://www.tradingview.com/script/1DYkYtDG-MMTW-indicator/
- type: strategy
- pine_id: PUB;ClZw6EgF204POVt9E546hL3htvb3UDN3
- version: 1.0

## Description

numbers of shares above or bellow 200 MA

## Source Code

````pine
//@version=4
strategy("MMTW", overlay=true)

symbl = input('MMTW', title="Stock/Security", type=input.symbol)
level = input(50, maxval=99)
band2 = hline(level, title="Upper Line", linestyle=hline.style_dotted, linewidth=1, color=color.red)


ticker_open = security(symbl, timeframe.period, open)
ticker_close = security(symbl, timeframe.period, close)
ticker_high = security(symbl, timeframe.period, high)
ticker_low = security(symbl, timeframe.period, low)

longCondition = crossover(ticker_close, level)
if (longCondition)
    strategy.entry("Long", strategy.long)

shortCondition = crossunder(ticker_close, level)
if (shortCondition)
    strategy.entry("Short", strategy.short)
````
