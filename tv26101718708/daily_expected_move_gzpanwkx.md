# Daily Expected Move

- url: https://www.tradingview.com/script/gZPANWKx-Daily-Expected-Move/
- type: indicator
- pine_id: PUB;4ffaa3a3e0fa466287f69f819cd63a16
- version: 1.0

## Description

Daily Move = Previous Close × Average Daily %

Example:

Average movement = 0.80%

25,200 × 0.008

= 202 points

Range:

Upper = 25,402
Lower = 24,998

## Source Code

````pine
//@version=6
indicator("Daily Expected Move", overlay=true)

atrValue = ta.atr(14)

upper = close + atrValue
lower = close - atrValue

plot(upper, color=color.green, linewidth=2)
plot(lower, color=color.red, linewidth=2)
````
