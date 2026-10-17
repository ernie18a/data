# Chinkou_Pro

- url: https://www.tradingview.com/script/2X7CIEOd-Chinkou-Pro/
- type: indicator
- pine_id: PUB;2516
- version: -1.0

## Description

Welcome traders, 

I have made this script wishing a higher gain, 

Originally, this strategy is taken from Ichimoku Kinko Hyo 

Simply: 
ChinkouPro crossing with price is giving a clear opportunity. 
Review it, master it, work it. 

first version 
[chart]https://www.tradingview.com/script/cH4bdjOq-ChinkouPro/[/chart]

change log
[list]
[*]Delete function of lazy trader { smooth candle } 
[*]Delete function of alert , { make alert from chart it's better }
[*]Enjoy with it , and contact me for any reason :) 
[/list]

## Source Code

````pine
// 150416 @TrendoBoom 
study(title="Chinkou_Pro", shorttitle="Ch_P", overlay=true)
//inputs
src = input(close)
of = input(-9, title="Chinkou'-26'")
// color of 1:0
colo = close >= close[1] ? lime : red 
// plot for chinkou
plot(src, offset=of, transp=70, style=line, color=colo, title='Chinkou Span', linewidth=3)
// Have A Good Day .
````
