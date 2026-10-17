# TriautoETF(TQQQ) Short Strategy B1

- url: https://www.tradingview.com/script/onbI61K2/
- type: strategy
- pine_id: PUB;8477c84326004bd89645d9b1222218ca
- version: 1.0

## Description

○ Objective.
This is a strategy for the TQQQ NASDAQ:TQQQ short strategy in the TriAuto ETF .
It is used as a hedging short rather than for profit-making purposes.
Entry and close points are indicated.


○ Strategy
The strategy is to hold a short position when the price falls below the moving average line, which is a market-conscious line that is rarely broken.
The close (settlement) is determined by using the moving average.
The moving average is based on the market-conscious QQQ NASDAQ:QQQ .
This script is used on the daily chart of the TQQQ.
It works as a hedge for long positions because open interest is held even at the major bottoms of the China and Corona shocks.
The system is set up to quickly cut its losses even if the moving average is "tricked" into falling below the moving average.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BBcom

//@version=5    
strategy("TriautoETF(TQQQ) Short Strategy B1","TSSB1", overlay = true)

// QQQ
QQQ1 = request.security("QQQ","D", ta.hma(close, 2))
QQQ2 = request.security("QQQ","D", ta.vwma(close, 193))
QQQ3 = request.security("QQQ","D", ta.ema(close, 9))
QQQ4 = request.security("QQQ","D", ta.ema(close, 14))

// 基準線表示
ShortLine = ta.vwma(close,193)
plot(ShortLine,title="Short Line",color=color.purple,linewidth=2)

// 売買の注文
strategy.entry(id = "Entry", direction = strategy.short, when = ta.crossover(QQQ2, QQQ1) ,comment="Short") 
strategy.close(id = "Entry", when = ta.crossover(QQQ3, QQQ4) or ta.crossover(QQQ3, QQQ2) , comment="Close")
````
