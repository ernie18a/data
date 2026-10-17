# Hamburg Buy/Sell + Support/Resistance

- url: https://www.tradingview.com/script/RSELScSS-Hamburg-Buy-Sell-Support-Resistance/
- type: indicator
- pine_id: PUB;e0812cbdc4854ddb8eefbf29d48221cf
- version: 1.0

## Description

It is going to help you when to buy and when to sell.

## Source Code

````pine
//@version=6
indicator("Buy/Sell + Support/Resistance", overlay=true)

emaFast  = ta.ema(close, 20)
emaSlow  = ta.ema(close, 50)
emaTrend = ta.ema(close, 200)

buy  = ta.crossover(emaFast, emaSlow)  and close > emaTrend
sell = ta.crossunder(emaFast, emaSlow) and close < emaTrend

plotshape(buy,  title="Buy",  style=shape.labelup,   location=location.belowbar, color=color.green, textcolor=color.white, text="BUY")
plotshape(sell, title="Sell", style=shape.labeldown, location=location.abovebar, color=color.red,   textcolor=color.white, text="SELL")

resistance = ta.highest(high, 50)
support    = ta.lowest(low, 50)

plot(resistance, title="Resistance (High)", color=color.red,   linewidth=2)
plot(support,    title="Support (Low)",     color=color.green, linewidth=2)

alertcondition(buy,  title="Buy",  message="BUY signal")
alertcondition(sell, title="Sell", message="SELL signal")
````
