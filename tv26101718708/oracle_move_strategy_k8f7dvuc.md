# Oracle Move Strategy

- url: https://www.tradingview.com/script/k8F7dVUC-Oracle-Move-Strategy/
- type: strategy
- pine_id: PUB;avcx7tC5G28oIsF2mSkUjAoZUMnNoYC0
- version: 1.0

## Description

[symbol="COINBASE:BTCUSD"]COINBASE:BTCUSD[/symbol]

## Source Code

````pine
//@version=3
strategy("Oracle Move Strategy", overlay=true)

maLen = input(30, "ma period")
mode =  input(defval="wma", options=["alma", "ema", "wma"])
price = close

ma(src, len) =>
     mode=="alma"  ? alma(src, len, 0.85, 6) :
     mode=="ema"? ema(src, len) : 
     wma(src, len)
    

ma1 = ma(price, floor(maLen / 2))
ma2 = ma(price, maLen)
ma3 = 2.0 * ma1 - ma2
ma4 = ma(ma3, floor(sqrt(maLen)))

//plot(ma1, color = red)
//plot(ma2, color = green)
plot(ma3, color = blue)
plot(ma4, color = orange)


mafast = ma3
maslow = ma4

if (crossover(mafast, maslow))
    strategy.entry("MA2CrossLE", strategy.long, comment="MA2CrossLE")

if (crossunder(mafast, maslow))
    strategy.entry("MA2CrossSE", strategy.short, comment="MA2CrossSE")

//plot(strategy.equity, title="equity", color=red, linewidth=2, style=areabr)
````
