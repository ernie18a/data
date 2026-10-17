# Linear Regression Channel 2D

- url: https://www.tradingview.com/script/2dxNh0uF/
- type: indicator
- pine_id: PUB;cd56c60c5b6d426198d976e05b213395
- version: 1.0

## Description

Indicateur de régression linéaire avec les 2 droites de régression linéaires ±1σ et  ±2σ

## Source Code

````pine
//@version=5
indicator("Linear Regression Channel ±1σ ±2σ", shorttitle="LRC 1-2σ", overlay=true)

len = input.int(300, minval=2, title="Length")
src = input.source(close, title="Source")

basis = ta.linreg(src, len, 0)
sigma = ta.stdev(src, len)

upper1 = basis + sigma
lower1 = basis - sigma
upper2 = basis + 2.0 * sigma
lower2 = basis - 2.0 * sigma

plot(basis,  title="Régression centrale", color=color.white, linewidth=2)
plot(upper1, title="+1σ", color=color.new(color.purple, 0), linewidth=1)
plot(lower1, title="-1σ", color=color.new(color.purple, 0), linewidth=1)
plot(upper2, title="+2σ", color=color.new(color.orange, 0), linewidth=1)
plot(lower2, title="-2σ", color=color.new(color.orange, 0), linewidth=1)
````
