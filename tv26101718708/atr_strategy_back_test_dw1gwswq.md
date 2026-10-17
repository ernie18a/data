# ATR Strategy Back test 

- url: https://www.tradingview.com/script/DW1GWSWQ-ATR-Strategy-Back-test/
- type: strategy
- pine_id: PUB;dieT0KoZfXDgl6p1IY8JxP2vffIot85U
- version: 1.0

## Description

Original script by HPotter

ATR strategy is profitable.

Buy when it says buy and sell when it says sell.

## Source Code

````pine
strategy(title="ATR Strategy", overlay = true,  commission_type=strategy.commission.percent,commission_value=0.075)
//credits to HPotter for the orginal code
nATRPeriod = input(5)
nATRMultip = input(3.5)
xATR = atr(nATRPeriod)
nLoss = nATRMultip * xATR
xATRTrailingStop = iff(close > nz(xATRTrailingStop[1], 0) and close[1] > nz(xATRTrailingStop[1], 0), max(nz(xATRTrailingStop[1]), close - nLoss),
                    iff(close < nz(xATRTrailingStop[1], 0) and close[1] < nz(xATRTrailingStop[1], 0), min(nz(xATRTrailingStop[1]), close + nLoss), 
                        iff(close > nz(xATRTrailingStop[1], 0), close - nLoss, close + nLoss)))
pos =	iff(close[1] < nz(xATRTrailingStop[1], 0) and close > nz(xATRTrailingStop[1], 0), 1,
	    iff(close[1] > nz(xATRTrailingStop[1], 0) and close < nz(xATRTrailingStop[1], 0), -1, nz(pos[1], 0))) 
color = pos == -1 ? red: pos == 1 ? green : blue 
plot(xATRTrailingStop, color=color, title="ATR Trailing Stop")

barbuy = close > xATRTrailingStop 
barsell = close < xATRTrailingStop 

strategy.entry("Long", strategy.long, when = barbuy) 
strategy.entry("Short", strategy.short, when = barsell) 

barcolor(barbuy? green:red)
````
