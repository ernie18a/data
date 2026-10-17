# BUY STRENGTH SELL WEAKNESS REMADE COPY

- url: https://www.tradingview.com/script/aqUm6qLX-BUY-STRENGTH-SELL-WEAKNESS-REMADE-COPY/
- type: strategy
- pine_id: PUB;cp14NstpuG8joXd76CZKeFb3g9csNHsM
- version: 1.0

## Description

Suggestions and ideas appreciated...

This was just a simple idea I had with the RSI.

I would like to add a filter.. example:

Only to go long when RSI is overbought AND price above 200 ema
Viceversa for short, when oversold and price below 200 ema. 

Is there anyone out there who can help ??

## Source Code

````pine
//@version=3
strategy("BUY STRENGTH SELL WEAKNESS REMADE COPY", overlay=false, pyramiding=1)
length = input(14)
overSold = input(30)
overBought = input(70)
timeframe = input(title="Timeframe", type=integer, minval=1, defval=3)
price = input(title="Source", type=source, defval=close)

vrsi = rsi(price, length)

// plot rsi and limits
plot(vrsi, title="RSI", linewidth=2, color=purple)
hline(overSold, linestyle=dashed, color=gray, editable=false)
hline(overBought, linestyle=dashed, color=gray, editable=false)

if (not na(vrsi))
    if (crossunder(vrsi, overSold))
        strategy.entry("RSI short", strategy.short)
    if (crossover(vrsi, overSold))
        strategy.close("RSI short", true)
    if (crossover(vrsi, overBought))
        strategy.entry("RSI long", strategy.long)
    if (crossunder(vrsi, overBought))
        strategy.close("RSI long", true)
````
