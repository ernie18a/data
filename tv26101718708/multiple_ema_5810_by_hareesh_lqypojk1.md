# Multiple Ema 5/8/10 by Hareesh

- url: https://www.tradingview.com/script/lQYPojK1-Multiple-Ema-5-8-10-by-Hareesh/
- type: indicator
- pine_id: PUB;e5bdb5ae8bc6455d80bc059b8c043fd6
- version: 1.0

## Description

Apply Multiple EMA for 5/8/10 trailing days. This will display EMA for 5 days, 8 days and 10 days.

## Source Code

````pine
//@version=6
// created by Hareesh

indicator('Multiple Ema 5/8/10', overlay = true)

len1 = input(5, title = 'EMA 1')
len2 = input(8, title = 'EMA 2')
len3 = input(10, title = 'EMA 3')


M1 = ta.ema(close, len1)
M2 = ta.ema(close, len2)
M3 = ta.ema(close, len3)

plot(M1, color = color.new(color.teal, 0), linewidth = 2)
plot(M2, color = color.new(color.purple, 0), linewidth = 2)
plot(M3, color = color.new(color.blue, 0), linewidth = 4)
````
