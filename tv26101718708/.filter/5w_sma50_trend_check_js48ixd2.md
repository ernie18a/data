# 5W SMA50 Trend Check 

- url: https://www.tradingview.com/script/Js48iXD2-5W-SMA50-Trend-Check/
- type: indicator
- pine_id: PUB;9479a69f41674a119a9431b20f8dcf5d
- version: 2.0

## Description

Quick and simple check the trend . if the 5 recent candles closed below (bearish) or above (bullish) SMA50. ~ GP

## Source Code

````pine
//@version=5
indicator("5W SMA50 Trend Check ✅", overlay=true)

// Force Weekly timeframe — Length 50, Source Close
sma50 = request.security(syminfo.tickerid, "1W", ta.sma(close, 50))
weeklyClose = request.security(syminfo.tickerid, "1W", close)

// Check last 5 weekly candles vs SMA50
c0 = weeklyClose[0] > sma50[0]
c1 = weeklyClose[1] > sma50[1]
c2 = weeklyClose[2] > sma50[2]
c3 = weeklyClose[3] > sma50[3]
c4 = weeklyClose[4] > sma50[4]

all_above = c0 and c1 and c2 and c3 and c4
all_below = (not c0) and (not c1) and (not c2) and (not c3) and (not c4)

in_last_5 = bar_index >= (last_bar_index - 4)

col = in_last_5 and all_above ? color.new(color.green, 70) : 
      in_last_5 and all_below ? color.new(color.red, 70) : na

bgcolor(col)
````
