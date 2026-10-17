# Lin Reg Cross

- url: https://www.tradingview.com/script/FXeBsq2O-Lin-Reg-Cross/
- type: strategy
- pine_id: PUB;3188
- version: -1.0

## Description

Super simple script.
Trade this at your own risk.

## Source Code

````pine
//@version=2
strategy(title="LRC", overlay=true)
paintbars = input(type=bool, defval=true)
len = input(defval=50, minval=1, title="Length")
offset = input(defval=1, minval=1, title="Displacement")

lr_norm = linreg(close, len, 0)
lr_offset = linreg(close, len, offset)
plot(lr_norm, linewidth=3, color= blue)
plot(lr_offset, linewidth=3, color= red)
barcolor(paintbars ? (lr_norm>lr_offset ? green : red) : na)

strategy.entry("buy", strategy.long, 10, when=crossover(lr_norm, lr_offset))
strategy.entry("sell", strategy.short, 10, when=crossunder(lr_norm, lr_offset))
````
