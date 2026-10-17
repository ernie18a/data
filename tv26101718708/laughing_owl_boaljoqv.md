# Laughing Owl

- url: https://www.tradingview.com/script/BOALjOQV-Laughing-Owl/
- type: strategy
- pine_id: PUB;5fy6u6CUK1qjCQ65WZrZ9h1gDX1uckEZ
- version: 1.0

## Description

Let the owl make you a fortune and keep you out of harm's way. Laugh your way all the way to the bank..

## Source Code

````pine
//@version=3
strategy(title="Laughing Owl", overlay=true)
short = sma(close, 13)
medium = sma(close, 34)
long = sma(close, 75)
plot(short, color = green)
plot(medium, color = yellow)
plot(long, color = red)

strategy.entry("enter long", true, 34, when = short > long and medium > long and short > medium)
strategy.entry("enter short", false, 34, when = short < long and medium < long and short < medium)

strategy.close("enter long", when = short < medium)
strategy.close("enter short", when = short > medium)
````
