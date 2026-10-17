# Lex's EMA Lines

- url: https://www.tradingview.com/script/ZuGPxGUw-Lex-s-EMA-Lines/
- type: indicator
- pine_id: PUB;3f9b9dfdadf145e9a4d4ac22291f8ae7
- version: 1.0

## Description

EMA line of 10, 20, 30, 50, 100, 200 to identify trends, decide on entry, etc.

## Source Code

````pine
//@version=5
indicator('EMA Lines', shorttitle='EMA 10, 20, 30, 50, 100, 200', overlay=true)

// Calculate EMAs
ema10 = ta.ema(close, 10)
ema20 = ta.ema(close, 20)
ema30 = ta.ema(close, 30)
ema50 = ta.ema(close, 50)
ema100 = ta.ema(close, 100)
ema200 = ta.ema(close, 200)

// Plot EMAs
plot(ema10, title='EMA 10', color=color.new(color.blue, 0))
plot(ema20, title='EMA 20', color=color.new(color.red, 0))
plot(ema30, title='EMA 30', color=color.new(color.orange, 0))
plot(ema50, title='EMA 50', color=color.new(color.green, 0))
plot(ema100, title='EMA 100', color=color.new(color.gray, 0))
plot(ema200, title='EMA 200', color=color.new(color.purple, 0))
````
