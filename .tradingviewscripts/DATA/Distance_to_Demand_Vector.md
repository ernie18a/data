<!-- tradingview-pine-id: PUB;aNe7sTvZNwWqm0dzk5O9TXKa6aKwzoJ0 -->
<!-- tradingviewscripts-format: 1 -->
# Distance to Demand Vector

Source: https://www.tradingview.com/script/gztrrvcD-Distance-to-Demand-Vector/

## Description

shows the distance to its relevant demand vector.
demand vector is based on the demand for long/short, extracted from price range..

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RicardoSantos

//@version=4
study(title='Distance to Demand Vector', overlay=false)

length = input(100)

lv = lowest(length)
lb = abs(lowestbars(length))
hv = highest(length)
hb = abs(highestbars(length))
demand_vector = (hv - lv) / max(hb-lb, lb-hb)

distance_to_long_vector = close - (lv + demand_vector * lb)
distance_to_short_vector = close - (hv - demand_vector * hb)
plot(series=distance_to_long_vector, title='+dv', color=color.lime)
plot(series=distance_to_short_vector, title='-dv', color=color.red)
````
