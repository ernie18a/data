# Parabolic SAR Strategy with good parameters

- url: https://www.tradingview.com/script/kz5j9elC-Parabolic-SAR-Strategy-with-good-parameters/
- type: strategy
- pine_id: PUB;uKFDzDQuWx3wXwna9euKktz30E7qKVVn
- version: 1.0

## Description

I tested it on EURUSD with 2% profit:

Set input parameters like here: https://screenshots.firefox.com/pAeszpnO8afOPQW5/www.tradingview.com

## Source Code

````pine
//@version=3
strategy("Parabolic SAR Strategy", overlay=true)

start = input(0.02)
increment = input(0.02)
maximum = input(0.2)

psar = sar(start, increment, maximum)

if (psar > high)
    strategy.entry("ParLE", strategy.long, stop=psar, comment="ParLE")
else
    strategy.cancel("ParLE")

if (psar < low)
    strategy.entry("ParSE", strategy.short, stop=psar, comment="ParSE")
else
    strategy.cancel("ParSE")

//plot(strategy.equity, title="equity", color=red, linewidth=2, style=areabr)
````
