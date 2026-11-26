# best ema 

- url: https://www.tradingview.com/script/Kcx254Ds-best-ema/
- type: indicator
- pine_id: PUB;f74f3702a66f4037b60fd502bbd6d62b
- version: 2.0

## Description

emas  5,9,20,50 and 200 with vwap in it, all you need to trade

## Source Code

````pine
//@version=6
indicator("Boss ema/vwap", overlay=true)
ema5 = ta.ema(close, 5)
ema8 = ta.ema(close, 9)
ema20 = ta.ema(close, 20)
ema50 = ta.ema(close, 50)
ema200 = ta.ema(close, 200)
vwap = ta.vwap(close)
plot(ema8, color=color.blue, title="EMA 8")
plot(ema20, color=color.green, title="EMA 20")
plot(ema50, color=color.orange, title="EMA 50")
plot(ema200, color=color.white, title="EMA 200")
plot(ema5, color=color.yellow, title="EMA 5")
vwap_change = ta.change(vwap)
colorLine = vwap_change > 0 ? color.green : color.red
plot(vwap, color=colorLine, linewidth=2, title="VWAP (Close)")
````
