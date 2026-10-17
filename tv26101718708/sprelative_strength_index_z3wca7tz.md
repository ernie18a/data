# SP_Relative Strength Index

- url: https://www.tradingview.com/script/Z3WCa7tZ-SP-Relative-Strength-Index/
- type: indicator
- pine_id: PUB;2027
- version: -1.0

## Description

Quick Update to the Steve Primo RSI. 

Nothing fancy, but one indicator to represent all his RSI based setups. 

Primarily used on Strategy #1 and #8. 

[chart]https://www.tradingview.com/chart/HPQ/ZZ5YBYd7-LIVE-TEST-STEVE-PRIMO-8-SETUPS-DAY-3/[/chart]

## Source Code

````pine
study(title="SP_Relative Strength Index", shorttitle="SP-RSI")
up = rma(max(change(close), 0), 5)
down = rma(-min(change(close), 0), 5)
rsi = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))
plot(rsi, color=black, linewidth = 3, title = "Steve Primo - RSI")

h0 = hline(50, color = blue, title = "Strategy #8 - Threshold Line")
h1 = hline(35, color = green, title = "Strategy #1 - Over Sold")
h2 = hline(25, color = green, title = "Strategy #1 - Over Sold")
h3 = hline(65, color = red, title = "Strategy #1 - Over Bought")
h4 = hline(75, color = red, title = "Strategy #1 - Over Bought")

fill (h1, h2, color = green, title = "Strategy #1 - Oversold Level")
fill (h3, h4, color = red, title = "Strategy #1 - Overbought Level")
````
