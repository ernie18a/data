# YBTS-RSI

- url: https://www.tradingview.com/script/WEdqC3lx/
- type: strategy
- pine_id: PUB;ScZzvTKFBu0PZBQOjhqHOecJFvDKITgN
- version: 1.0

## Description

안녕하세요?

## Source Code

````pine
strategy("SBTS", overlay=true)


//rsicolor = rsi(colse, 10)
//out1 = security(tickerid, 'D', out)
plot(ema(close, 10), color = red)
plot(ema(close, 20), color = yellow)
plot(ema(close, 30), color = blue)

bgcolor(rsi(close, 10) > 65 ? red : na, transp=70)
bgcolor(rsi(close, 10) < 35 ? green : na, transp=70)

strategy.entry("buy long", true, 1, when = ( rsi(close,10) >= 65 and rsi(close,10)[1] < 65 ) )
strategy.exit("sell long", "buy long", when =  ( rsi(close,10)[1] >= 65 and rsi(close,10) < 65 ) )
strategy.entry("buy short", false, 1, when = ( rsi(close,10) <= 35 and rsi(close,10)[1] > 35 ) )
strategy.exit("sell long", "buy short", when =  ( rsi(close,10)[1] <= 35 and rsi(close,10)> 35 ) )
//plot(strategy.position_size)
````
