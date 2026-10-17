# CMARSI Strategy (on ETHUSD) Seems working good

- url: https://www.tradingview.com/script/Rcq6U2TU-CMARSI-Strategy-on-ETHUSD-Seems-working-good/
- type: strategy
- pine_id: PUB;amulKXtsYwzkfsf8Iu9caeP58oRcCiOS
- version: 1.0

## Description

there it is, it's using the Connor RSI with little variations.

[b]C[/b]onnor[b]M[/b]oving[b]A[/b]verage[b]RSI[/b]

## Source Code

````pine
//@version=3
src = close, lenrsi = 3, lenupdown = 2, lenroc = 100, malengt = 2, low = 40, high = 70, a = 1
updown(s) => 
    isEqual = s == s[1]
    isGrowing = s > s[1]
    ud = 0.0
    ud := isEqual ? 0 : isGrowing ? (nz(ud[1]) <= 0 ? 1 : nz(ud[1])+1) : (nz(ud[1]) >= 0 ? -1 : nz(ud[1])-1)
    ud
rsi = rsi(src, lenrsi)
updownrsi = rsi(updown(src), lenupdown)
percentrank = percentrank(roc(src, 1), lenroc)
crsi = avg(rsi, updownrsi, percentrank)
MA = sma(crsi, malengt)

band1 = 70
band0 = 40

ColorMA = MA>=band0 ? lime : red

p1 = plot(MA, title="BuyNiggers", style=line, linewidth=4, color=ColorMA)

p2 = plot(low, title="idk", style=line, linewidth=2, color=blue)
p3 = plot(high, title="idk2", style=line, linewidth=2, color=orange)

//@version=2
strategy("CMARSI")


if crossover(MA,band0)
    strategy.entry("buy", strategy.long, 1000, when=strategy.position_size <= 0)
    
if crossunder(MA,band1)
    strategy.exit("sell", "buy",  1000, profit=1000000, stop=10000000)
    
plot(strategy.equity)
````
