# QuantNomad - RSI Strategy - NKE - 5m

- url: https://www.tradingview.com/script/32ZHCA6S-QuantNomad-RSI-Strategy-NKE-5m/
- type: strategy
- pine_id: PUB;1Pm4JxXZMXqlCKOzDXLOMYFnJPSDly5X
- version: 2.0

## Description

Really good performance of Simple RSI Strategy for Nike (NKE) 5m chart. 
Params:  RSI Length: 30, RSI OverSold level: 45, RSI OverBought Level: 60
Performance:57% profit, 112 trades, 73% prof, 6.7% dd, 1.36 sharpe. 

And remember: 
Past performance does not guarantee future results.

## Source Code

````pine
//@version=3
strategy("QuantNomad - RSI Strategy - NKE - 5m", overlay=true, default_qty_type = strategy.percent_of_equity, default_qty_value = 100)

length     = input(30)
overSold   = input(45)
overBought = input(60)

price = close

vrsi = rsi(price, length)

if (not na(vrsi))
    if (crossover(vrsi, overSold))
        strategy.entry("RsiLE", strategy.long, comment="RsiLE")
    if (crossunder(vrsi, overBought))
        strategy.entry("RsiSE", strategy.short, comment="RsiSE")

//plot(strategy.equity, title="equity", color=red, linewidth=2, style=areabr)
````
