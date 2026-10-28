# VWAP Multi Fixed Bands

- url: https://www.tradingview.com/script/rNMxfJfF-VWAP-Multi-Fixed-Bands/
- type: indicator
- pine_id: PUB;9ab19ff8eda443feaba5c76f6689674a
- version: 1.0

## Description

Multi Fixed Band that marks out certain range and distance from session VWAP

## Source Code

````pine
//@version=6
indicator("VWAP Multi Fixed Bands", overlay=true)

src = input.source(hlc3, "Source")
d1 = input.float(5.0, "Distance 1", step=0.1)
d2 = input.float(10.0, "Distance 2", step=0.1)
d3 = input.float(15.0, "Distance 3", step=0.1)

vwapValue = ta.vwap(src)

plot(vwapValue, title="VWAP", linewidth=2, color=color.blue)

plot(vwapValue + d1, title="Upper 1", color=color.green)
plot(vwapValue - d1, title="Lower 1", color=color.green)

plot(vwapValue + d2, title="Upper 2", color=color.orange)
plot(vwapValue - d2, title="Lower 2", color=color.orange)

plot(vwapValue + d3, title="Upper 3", color=color.red)
plot(vwapValue - d3, title="Lower 3", color=color.red)
````
