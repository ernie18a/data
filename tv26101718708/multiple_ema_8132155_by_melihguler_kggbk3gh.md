# Multiple Ema 8/13/21/55 by melihguler

- url: https://www.tradingview.com/script/KgGbk3gH/
- type: indicator
- pine_id: PUB;rTjuUkQNBAfvms6GIWkaFLuNultXeEHp
- version: 1.0

## Description

In one graph, 4 different periods include EMA (8/13/21/55). It is not recommended for short-term investments. You can get efficient results using at least 4 hours chart.
[i]It is not an investment recommendation. Your use is at your own risk.[/i]

## Source Code

````pine
//@version=3
// created by melihguler

study("Multiple Ema 8/13/21/55 by melihguler", overlay=true)

len1=input(8, title="Period 8")
len2=input(13, title="Period 13")
len3=input(21, title="Period 21")
len4=input(55, title="Period 55")

M1=ema(close, len1)
M2=ema(close, len2)
M3=ema(close, len3)
M4=ema(close, len4)

plot(M1, color=blue, linewidth=2)
plot(M2, color=green, linewidth=2)
plot(M3, color=orange, linewidth=2)
plot(M4, color=red, linewidth=2)
````
