# KISS MAURICE FOL

- url: https://www.tradingview.com/script/4ugdv0JI/
- type: strategy
- pine_id: PUB;SmAAsqFZUnIKgFCrQkmH8fv1WUECPjnE
- version: 1.0

## Description

Search on Google "finanzaonline maurice kiss me please"

## Source Code

````pine
//@version=2
strategy("KISS MAURICE FOL", overlay=true, default_qty_value=100, initial_capital=10000)
periodo = input(12, minval=1, title="Periodo")
media=sma(close, periodo)
if (crossover(close, media))
    strategy.entry("BUY", strategy.long)
strategy.close_all(crossunder(close, media))
plot(media, title="MEDIA", style=line, linewidth=3, color=blue)
````
