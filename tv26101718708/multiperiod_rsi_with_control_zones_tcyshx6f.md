# Multi-Period RSI with Control Zones

- url: https://www.tradingview.com/script/TcYshx6f-Multi-Period-RSI-with-Control-Zones/
- type: indicator
- pine_id: PUB;44e43e686446474998851d8eb7026c13
- version: 1.0

## Description

straight forward multi-period RSI with trend zones

## Source Code

````pine
//@version=6
indicator(title="Multi-Period RSI with Control Zones", shorttitle="MPRSI", format=format.price, precision=2, timeframe="", timeframe_gaps=true)
len = input.int(14, minval=1, title="Length")
src = input(close, "Source")
up = ta.rma(math.max(ta.change(src), 0), len)
down = ta.rma(-math.min(ta.change(src), 0), len)
rsi = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))
plot(rsi, "RSI", color=#ffffff)
bandm = hline(50, "Middle Band", color=color.new(#adadad, 50))
band0 = hline(30, "Lower Band", color=#adadad)
band1 = hline(70, "Upper Band", color=#adadad)
band2 = hline(40, "Lower Band", color=#adadad)
band3 = hline(60, "Upper Band", color=#adadad)
fill(band1, band0, color=color.rgb(255, 255, 255, 90), title="Neutral Zone")
fill(band3, band1, color=color.rgb(100, 255, 100, 90), title="Bullish Control Zone")
fill(band2, band0, color=color.rgb(255, 100, 100, 90), title="Bearish Control Zone")

len2 = input.int(5, minval=1, title="Short Length")
src2 = input(close, "Short Source")
up2 = ta.rma(math.max(ta.change(src2), 0), len2)
down2 = ta.rma(-math.min(ta.change(src), 0), len2)
rsi2 = down2 == 0 ? 100 : up2 == 0 ? 0 : 100 - (100 / (1 + up2 / down2))
plot(rsi2, "Short RSI", color=#a6161a)
````
