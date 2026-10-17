# RSI Strategy

- url: https://www.tradingview.com/script/9UfJaSqR-RSI-Strategy/
- type: strategy
- pine_id: PUB;Or2ytfw6gKNGS3OxXj3590AcvMBj1mX9
- version: 1.0

## Description

INTRADAY GO WITH SIGNAL AT THE END OF DAY YOU WILL BE IN PROFITS GURANTEE...............

Just Take Care of one thing only use it for top tarded counters or most volatine scripts...........

## Source Code

````pine
//@version=4
strategy("RSI Strategy", overlay=true)
length = input( 21 )

BUY = input( 50.5 )
SELL = input( 45 )

BUY1 = input(42.1 )
SELL1 = input( 57.9 )

price = close

vrsi = rsi(price, length)

if (not na(vrsi))
    if (crossover(vrsi, BUY))
        strategy.entry("BUY", strategy.long, comment="BUY")
        
    if (crossunder(vrsi, SELL))
        strategy.entry("SELL", strategy.short, comment="EXIT")
        
//    if (crossover(vrsi, BUY1))
//        strategy.entry("BUY1", strategy.long, comment="BUY")  
       
//    if (crossunder(vrsi, SELL1))
//        strategy.entry("SELL", strategy.short, comment="SELL")

//plot(strategy.equity, title="equity", color=color.red, linewidth=2, style=plot.style_areabr)
````
