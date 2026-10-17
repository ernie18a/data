# 55EMA 200MA Cross Philakone Swing Strategy

- url: https://www.tradingview.com/script/oAxHOqKh-55EMA-200MA-Cross-Philakone-Swing-Strategy/
- type: indicator
- pine_id: PUB;IaMqcvRFZ5ohsRZjAsuTzFdnrhGPYPd7
- version: 1.0

## Description

Based on the lessons of Philakone when we see the golden cross its a buy signal when we see the second cross this means death cross sell signal.

## Source Code

````pine
//@version=1
study(title="EMA MA Cross", overlay=true)
short = ema(close, 55)
long = sma(close, 200)
plot(short, color = yellow)
plot(long, color = red)
plot(cross(short, long) ? short : na, style = cross, linewidth = 4)
````
