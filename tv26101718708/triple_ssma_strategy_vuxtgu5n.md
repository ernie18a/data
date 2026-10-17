# Triple SSMA Strategy

- url: https://www.tradingview.com/script/VUxtgu5N-Triple-SSMA-Strategy/
- type: strategy
- pine_id: PUB;Jt04GdFP9Y03J2zFKfRD7mMt4qlzJhWp
- version: 10.0

## Description

A simple trading strategy based on an idea by @sentineli https://www.tradingview.com/chart/VTCBTC/YD48htER-Vertcoin-VTC-SMA-Trading-Strategy/

## Source Code

````pine
// An SMMA crossover-based trading strategy ased on idea by @sentineli
//@version=3
strategy(title="Triple SMMA Strategy", shorttitle="3-SMMA Strategy", overlay=true)

drop1st(src) =>
    x = na
    x := na(src[1]) ? na : src

xsmma(src, len) =>
    res = na
    res := (nz(res[1], src) * (len - 1) + src) / len

src = input(close, type=source, title="Source")
pslow = input(50, title="Slow Period")
pfast = input(10, title="Fast Period")
pveryfast = input(5, title="Very Fast Period")
showcurves = input(false, title="Show Curves")
stoploss = input(true, title="Stop loss")

price = log(drop1st(src))
xslow = xsmma(price, pslow)
xfast = xsmma(price, pfast)
xvfast = xsmma(price, pveryfast)

plot(showcurves ? exp(xvfast) : na, title="Very Fast MA", color=#ff7f00, transp=0, linewidth=2)
plot(showcurves ? exp(xfast) : na, title="Fast MA", color=#1155cc, transp=0, linewidth=2)
plot(showcurves ? exp(xslow) : na, title="Slow MA", color=#ca2c78, transp=0, linewidth=2)

mom = change(xslow)

if ((crossover(xvfast, xfast) and xfast >= xslow) or (crossover(xfast, xslow) and xvfast >= xfast))
    strategy.entry("3-SMMA-LE", strategy.long, oca_name="3-SMMA", stop=(stoploss ? high+syminfo.mintick : na), comment="3-SMMA")

if ((crossunder(xvfast, xfast) and xfast <= xslow) or (crossunder(xfast, xslow) and xvfast <= xfast))
    strategy.entry("3-SMMA-SE", strategy.short, oca_name="3-SMMA", stop=(stoploss ? low-syminfo.mintick : na), comment="3-SMMA")
````
