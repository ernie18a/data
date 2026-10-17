# Triple RSI strategy

- url: https://www.tradingview.com/script/raWdLVOY-Triple-RSI-strategy/
- type: strategy
- pine_id: PUB;09307831c9a746f59931a7bce3226c8e
- version: 1.0

## Description

This strategy is commonly used both in forex and stock markets for reversal trading. when the rsi line reaches and crosses simultaneously at 3 rsi setups i.e at 7, 14, and 21, a signal is generated.

This strategy works best in 1-hour timeframe. It provides over 60 to 80 percent accuracy in 1-hour timeframe.

In the stock market, this strategy provides an excellent entry point, if one is seeking small profits.
One can expect to make around 10 to 50 pips in the forex market easily. However, I advise seeking support from price action from the lower timeframe in the forex market.

I hope you like it.
Follow for more strategies and scripts like this.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Trade_by_DB

//@version=5
strategy("3 RSI", overlay=true, margin_long=100, margin_short=100)


// 3 rsi strategy , when all of them are overbought we sell, and vice versa
rsi7 = ta.rsi(close,7)
rsi14 = ta.rsi(close,14)
rsi21 = ta.rsi(close,21)


// sell condition
sell = ta.crossunder(rsi7,70) and ta.crossunder(rsi14,70) and ta.crossunder(rsi21,70)

//buy condition
buy = ta.crossover(rsi7,30) and ta.crossover(rsi14,30) and ta.crossover(rsi21,30)

if (buy)
    strategy.entry("BUY", strategy.long)

if (sell)
    strategy.entry("SELL", strategy.short)
````
