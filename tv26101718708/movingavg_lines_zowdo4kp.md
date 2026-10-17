# MovingAvg Lines

- url: https://www.tradingview.com/script/ZOwdO4kp-MovingAvg-Lines/
- type: strategy
- pine_id: PUB;KBArAlUQpDAG8YbHYKNJDzUSFdm6dLon
- version: 2.0

## Description

Possibility that  you use four lines with different values. And that lines calculate a simple moving average. In my use, I put the numbers 9, 21, 72 and 200.

## Source Code

````pine
//@version=4
strategy("MovingAvg Lines", overlay=true)
line1 = input(9, title="Linha 1")
line2 = input(21, title="Linha 2")
line3 = input(72, title="Linha 3")
line4 = input(200, title="Linha 4")
price = input(close, title="Source")

mafast = sma(price, line1)
maslow = sma(price, line2)

plot(sma(price, line1), color=color.lime, transp=0, linewidth=2)
plot(sma(price, line2), color=color.red, transp=0, linewidth=2 )
plot(sma(price, line3), color=color.fuchsia, transp=0, linewidth=2 )
plot(sma(price, line4), color=color.orange, transp=0, linewidth=2 )
````
