<!-- tradingview-pine-id: PUB;1b8262cc07e942f2bd1d26735458ed76 -->
<!-- tradingviewscripts-format: 1 -->
# Test12

Source: https://www.tradingview.com/script/8tqPv7Vt-SeansIciDisi/

## Description

Calculates, on a geometric basis, how much of the increase occurred during the trading session and how much occurred outside the session. Works only on the hourly timeframe.

---

## Source Code

````pine
//@version=6
indicator("Test12", overlay=false)

plot((time - 1) * 100, "Rara", color.blue, 2)
````
