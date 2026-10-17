# RSI Cross with Entry Signals

- url: https://www.tradingview.com/script/DPlgVfGN/
- type: indicator
- pine_id: PUB;fdafcbd63f574758a60bad501847ac95
- version: 1.0

## Description

RSI Cross with Entry Signals

This indicator uses the Relative Strength Index (RSI) and its moving average (SMA) to identify momentum shifts and potential trading opportunities.

BUY Signal

* Generated when the RSI crosses above its moving average.
* Indicates strengthening bullish momentum.

SELL Signal

* Generated when the RSI crosses below its moving average.
* Indicates strengthening bearish momentum.

Features

* RSI and RSI Moving Average visualization
* Automatic BUY and SELL signals
* Dynamic color changes based on momentum direction
* Key RSI levels at 70, 50, and 30
* Alert support for crossover events

This indicator helps traders identify trend changes, momentum shifts, and potential entry opportunities in a simple and visual way.

## Source Code

````pine
//@version=6
indicator(title="RSI Cross with Entry Signals", shorttitle="RSI Cross with Entry Signals", overlay=false)

// パラメーター
rsiLen = input.int(14, title="RSI Length", minval=1)
maLen  = input.int(14, title="MA Length", minval=1)

// RSI と MA
rsiValue = ta.rsi(close, rsiLen)
maValue  = ta.sma(rsiValue, maLen)

// クロス判定
buySignal  = ta.crossover(rsiValue, maValue)
sellSignal = ta.crossunder(rsiValue, maValue)

// 色
lineColor = rsiValue > maValue ? color.lime : color.red

// 表示
p1 = plot(rsiValue, color=color.blue, title="RSI")
p2 = plot(maValue, color=lineColor, title="RSI MA")

fill(p1, p2, color=color.new(lineColor, 85))

// 基準ライン
hline(70, "70", color=color.gray)
hline(50, "50", color=color.gray)
hline(30, "30", color=color.gray)

// サイン表示
plotshape(buySignal, title="BUY", location=location.bottom, color=color.green, style=shape.labelup, text="BUY", size=size.small)
plotshape(sellSignal, title="SELL", location=location.top, color=color.red, style=shape.labeldown, text="SELL", size=size.small)

// アラート
alertcondition(buySignal, title="Buy Alert", message="RSI crossed above MA")
alertcondition(sellSignal, title="Sell Alert", message="RSI crossed below MA")
````
