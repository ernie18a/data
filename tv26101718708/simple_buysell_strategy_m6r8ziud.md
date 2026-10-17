# Simple Buy/Sell Strategy

- url: https://www.tradingview.com/script/M6r8Ziud-Simple-Buy-Sell-Strategy/
- type: strategy
- pine_id: PUB;96463972452e4ae2ac4e235ccbbb2bd0
- version: 2.0

## Description

This is the strategy version of the original 'Simple Buy/Sell Indicator' by @Shizaru .

The original indicator description explains the logic behind the strategy:

"The original script was posted on ProRealCode by user Doctrading.

This little and simple code allows you to draw an indicator, which show you when buy or sell conditions are met.
For "buy" conditions, I did just set :
close > MM200
close > Parabolic SAR
MACD > 0
RSI7 > 50
For "sell" conditions : the opposite.

Of course, you can set what you want, in order to test your strategies.
Of course, to be profitable, you must also set your trading rules (entry, stop loss, trailing stop, take profit, etc.)
It's only an indicator, which doesn't show entry or exit rules."

Hope this helps someone!

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BlockchainSpecialists

//@version=4
//Original Indicator by @Shizaru - simply made into a strategy!

strategy("Simple Buy/Sell Strategy", overlay=false)
psar = sar(0.02,0.02,0.2)
c1a = close > psar
c1v = close < psar

malen = input(200, title="MA Length")
mm200 = sma(close, malen)
c2a = close > mm200
c2v = close < mm200

fast = input(12, title="Fast EMA Length")
slow = input(26, title="Slow EMA Length")
[macd,signal,hist] = macd(close, fast,slow, 9)
c3a = macd >= 0
c3v = macd <= 0

rsilen = input(7, title="RSI Length")
th = input(50, title="RSI Threshold")
rsi14 = rsi(close, rsilen)
c4a = rsi14 >= th
c4v = rsi14 <= th

buy = c1a and c2a and c3a and c4a ? 1 : 0
sell = c1v and c2v and c3v and c4v ? -1 : 0

longtrades = input(true, title="Long Trades")
shorttrades = input(true, title="Short Trades")
quickexit = input(false, title="Quick Exits")

strategy.entry("Buy", strategy.long, when=buy==1 and longtrades==true)
strategy.close("Buy", when=quickexit==true ? buy==0 : sell==-1)
strategy.entry("Sell", strategy.short, when=sell==-1 and shorttrades==true)
strategy.close("Sell", when=quickexit==true ? sell==0 : buy==1)

plot(buy, style=plot.style_histogram, color=color.green, linewidth=3, title="Buy Signals")
plot(sell, style=plot.style_histogram, color=color.red, linewidth=3, title="Sell Signals")
````
