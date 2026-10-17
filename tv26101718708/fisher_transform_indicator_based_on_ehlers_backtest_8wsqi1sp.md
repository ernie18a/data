# Fisher Transform Indicator based on Ehlers Backtest

- url: https://www.tradingview.com/script/8wSQI1SP-Fisher-Transform-Indicator-based-on-Ehlers-Backtest/
- type: strategy
- pine_id: PUB;5WIEYG9jmeO85yWBBjpKa7yLajP8W5lp
- version: 3.0

## Description

Use 9 as length and 8h timeframe for crypto

## Source Code

````pine

//@version = 2
strategy(title="Zuhair's secret sauce indicator", shorttitle="Zuhair's secret sauce indicator")
Risk = input(title="Risk % of equity", type=integer, defval=10)
strategy.risk.max_drawdown(Risk, strategy.percent_of_equity)
Length = input(9, minval=1)
Atr = rma(tr, Length)
reverse = input(false, title="Trade reverse")
hline(1, color=white, linestyle=dashed)
xHL2 = hl2
xMaxH = highest(xHL2, Length)
xMinL = lowest(xHL2,Length)
nValue1 = 0.33 * 2 * ((xHL2 - xMinL) / (xMaxH - xMinL) - 0.5) + 0.67 * nz(nValue1[1])
nValue2 =   iff(nValue1 > .99,  .999,
	         iff(nValue1 < -.99, -.999, nValue1))
nFish = 0.5 * log((1 + nValue2) / (1 - nValue2)) + 0.5 * nz(nFish[1])
pos = iff(nFish > 0, 1,
	   iff(nFish < 0, -1, nz(pos[1], 0))) 
possig = iff(reverse and pos == 1, -1,
          iff(reverse and pos == -1, 1, pos))	   
if (possig == 1) 
    strategy.entry("Long", strategy.long)
if (possig == -1)
    strategy.entry("Short", strategy.short)	   	    
// barcolor(possig == -1 ? red: possig == 1 ? green : blue )
plot(nFish, color=lime, title="Fisher")
plot(nz(nFish[1]), color=red, title="Trigger")
````
