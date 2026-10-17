# Buy - Take Profit OR Stop Loss % Based

- url: https://www.tradingview.com/script/WD09HFwm-Buy-Take-Profit-OR-Stop-Loss-Based/
- type: strategy
- pine_id: PUB;1MOjt7slZb4KdWRmRBPf1VOSKikTs5Hi
- version: 1.0

## Description

Script looks back for a certain period of time and than enter when price close above that look back period ema. Once enter it does not care for how many times price cross above or below. Once entered, it will either hit percenatage based take profit of stop loss.

## Source Code

````pine
//@version=3
strategy("Stop Loss Example: Simple Stoploss", overlay=true)

sma_per = input(200, title='SMA Lookback Period', minval=1)
sl_inp = input(2.0, title='Stop Loss %', type=float)/100
tp_inp = input(1.0, title='Take Profit %', type=float)/100

sma = sma(close, sma_per)

stop_level = strategy.position_avg_price * (1 - sl_inp)
take_level = strategy.position_avg_price * (1 + tp_inp)

strategy.entry("Simple SMA Entry", strategy.long, when=crossover(close, sma))

strategy.exit("Stop Loss/TP","Simple SMA Entry", stop=stop_level, limit=take_level)

plot(sma, color=orange, linewidth=2)
plot(stop_level, color=red, style=linebr, linewidth=2)
plot(take_level, color=green, style=linebr, linewidth=2)
````
