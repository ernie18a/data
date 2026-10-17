# UCS_S_Steve Primo - Strategy 3

- url: https://www.tradingview.com/script/ZzprSVpx-UCS-S-Steve-Primo-Strategy-3/
- type: indicator
- pine_id: PUB;1516
- version: -1.0

## Description

Here is the code for Steve Primo Strategy #1 - Setup Long and Short

- Please refer to his videos for triggers and management. 

Share your views.

## Source Code

````pine
// Created by UCS Gears
// Steve Primo Strategy #3

study(shorttitle="SP-S#3", title="StevePrimo - Strategy #3", overlay=true, precision = 2)

basis = sma(close, 20)
dev = 0.382 * stdev(close, 20)
upper = basis + dev
lower = basis - dev
bs = sma(close, 50)

// PET-D
petd = ema(close,13)
petdcolor = close > petd ? green : red
barcolor (petdcolor)

trendup = close > bs and close[1] > bs[1]
trenddn = close < bs and close[1] < bs[1]

plot (bs, linewidth = 3, color = black, title = "Trend - Long Term")
//plot (petd, linewidth = 1, color = blue, title = "Trend - Short Term")
plot (basis, linewidth = 1, color = purple, title = "Bollinger Mid Line")
p1 = plot (upper, linewidth = 1, color = purple, title = "Bollinger Upper Line")
p2 = plot (lower, linewidth = 1, color = purple, title = "Bollinger Lower Line")
fill (p1, p2, purple)

// Setup Long
SL = trendup and high < lower and high[1] > lower[1] ? 1 : na

// Setup Short
SS = trenddn and low > upper and low[1] < upper[1]? 1 : na
SC = SS ? orange : SL ? lime : na

plotshape(SS, style = shape.labeldown, color = SC, location=location.abovebar, text="SP #3 Short")

plotshape(SL, style = shape.labelup, color = SC, location=location.belowbar, text="SP #3 Long")
````
