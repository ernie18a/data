# MA Cross

- url: https://www.tradingview.com/script/McVE5GqX-MA-Cross/
- type: indicator
- pine_id: PUB;5ec4a0f82db14611918098186da7da8d
- version: 1.0

## Description

my first indicator 50MA crossing 200 MA, with alert

## Source Code

````pine
//@version=5
indicator(title="MA Cross", overlay=true, timeframe="", timeframe_gaps=true)
shortlen = input.int(50, "Short MA Length", minval=1)
longlen = input.int(200, "Long MA Length", minval=1)
short = ta.sma(close, shortlen)
long = ta.sma(close, longlen)
plot(short, color = #FF6D00, title="Short MA")
plot(long, color = #43A047, title="Long MA")
plot(ta.cross(short, long) ? short : na, color=#2962FF, style = plot.style_cross, linewidth = 4, title="Cross")
````
