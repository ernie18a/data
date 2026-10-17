# Rate Of Change Trend Strategy (ROC)

- url: https://www.tradingview.com/script/CCrPAfmV-Rate-Of-Change-Trend-Strategy-ROC/
- type: strategy
- pine_id: PUB;6f14a3cf2d8f4b45af18e5459cc77b61
- version: 1.0

## Description

This is very simple trend following or momentum strategy. If the price change over the past number of bars is positive, we buy. If the price change over the past number of bars is negative, we sell. This is surprisingly robust, simple, and effective especially on trendy markets such as cryptos.


Works for many markets such as:
[symbol="INDEX:BTCUSD"]INDEX:BTCUSD[/symbol]
[symbol="INDEX:ETHUSD"]INDEX:ETHUSD[/symbol]
[symbol="SP:SPX"]SP:SPX[/symbol]
[symbol="NASDAQ:NDX"]NASDAQ:NDX[/symbol]
[symbol="NASDAQ:TSLA"]NASDAQ:TSLA[/symbol]

## Source Code

````pine
//@version=5
strategy("ROC", overlay=true)
length = input(30)
longtrades = input.bool(true, "Long",   inline = "01")
shorttrades = input.bool(false, "Short",   inline = "01")
price = close
roc = ta.roc(price,length)
if (roc>0)
	if(longtrades)
	    strategy.entry("ROCLong", strategy.long, comment="ROCLong")
	else
	    strategy.close_all()
else
	if(shorttrades)
	    strategy.entry("ROCShort", strategy.short, comment="ROCShort")
	else
	    strategy.close_all()
//plot(strategy.equity, title="equity", color=color.red, linewidth=2, style=plot.style_areabr)
````
