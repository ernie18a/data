# [BoTo] RSI Trend Strategy

- url: https://www.tradingview.com/script/h9tj5ylQ-BoTo-RSI-Trend-Strategy/
- type: strategy
- pine_id: PUB;orKdfuAiwIvd4QaeBsamiaiSJkWBp8yl
- version: 1.0

## Description

Open source code.

It is very old trade strategy. It is older than you :) Uses the RSI indicator. The RSI indicator has described Welles Wilder in the book in 1978. And all this is still profitable!

[b]Additional articles[/b]

1. https://en.wikipedia.org/wiki/J._Welles_Wilder_Jr.
2. https://en.wikipedia.org/wiki/Relative_strength_index
3. https://www.tradingview.com/wiki/Relative_Strength_Index_(RSI)

[b]How it works[/b]

[b]Step 1.[/b] The user chooses length for RSI

[b]Step 2.[/b] If RSI is more than 50, then it is a uptrend and the long position opens. It is necessary to close a short position if it is opened earlier.

[b]Step 3.[/b] If RSI is less than 50, that is a downtrend and the short position opens. It is necessary to close a long position if it is opened earlier.

Well is suitable for the market of cryptocurrencies. Well length from 3 to 7 approaches. Don't use length 14 because for cryptocurrencies it is too much. Cryptocurrencies it is very volatile market. You can also use the RSI indicator which is built in on TradingView.com.

## Source Code

````pine
//@version=3
strategy("[BoTo] RSI Trend Strategy", shorttitle = "[BoTo] RSI Trend", default_qty_type = strategy.percent_of_equity, default_qty_value = 100, pyramiding = 0)
length = input(7, title = 'RSI Length')
rsi = rsi(close, length)
plot(rsi, color = black, title = 'RSI')
plot(50, color = gray, title = '50%')
color = rsi < 50 ? gray : na
bgcolor(color)
if rsi > 50
    strategy.entry('Up', strategy.long)
if rsi < 50
    strategy.entry('Dn', strategy.short)
````
