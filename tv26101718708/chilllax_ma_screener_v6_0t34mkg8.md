# Chilllax MA Screener v6

- url: https://www.tradingview.com/script/0T34MkG8-Chilllax-MA-Screener-v6/
- type: indicator
- pine_id: PUB;405657ba10354c4a845366785b7a03b7
- version: 1.0

## Description

For Screening EP Stocks modified chillmax QMag scripts

## Source Code

````pine
//@version=6
indicator("Chilllax MA Screener v6", shorttitle="Chilllax Screener v6", overlay=false)

// Inputs
maType   = input.string("SMA", title="Moving Average Type", options=["SMA", "EMA"])
ma1Len   = input.int(10, minval=1, title="First MA length")
ma2Len   = input.int(20, minval=1, title="Second MA length")
trendLen = input.int(5, minval=1, title="Bars to determine uptrend")
src      = input.source(close, title="Source")

// MA calculations
ma1 = maType == "SMA" ? ta.sma(src, ma1Len) : ta.ema(src, ma1Len)
ma2 = maType == "SMA" ? ta.sma(src, ma2Len) : ta.ema(src, ma2Len)

// Trend logic
ma1Up = ma1 > ma1[trendLen]
ma2Up = ma2 > ma2[trendLen]

// Qullamaggie color states
green      = ma1 > ma2 and ma1Up and ma2Up
lightGreen = ma1 > ma2 and ma1Up and not ma2Up
yellow     = ma1 > ma2 and not ma1Up and not ma2Up

// Optional bearish states
red        = ma1 < ma2 and not ma1Up and not ma2Up
lightRed   = ma1 < ma2 and not ma1Up and ma2Up

// Screener plots: use 1/0 values
plot(green ? 1 : 0, title="Green", color=color.green)
plot(lightGreen ? 1 : 0, title="LightGreen", color=color.lime)
plot(yellow ? 1 : 0, title="Yellow", color=color.yellow)
plot(red ? 1 : 0, title="Red", color=color.red)
plot(lightRed ? 1 : 0, title="LightRed", color=color.orange)

// Optional MA value columns
plot(ma1, title="MA1", color=color.red)
plot(ma2, title="MA2", color=color.black)

// Alerts
alertcondition(green, title="Green Condition", message="MA1 > MA2 and both trending up")
alertcondition(lightGreen, title="LightGreen Condition", message="MA1 > MA2 and only MA1 trending up")
alertcondition(yellow, title="Yellow Condition", message="MA1 > MA2 and neither MA is trending up")
alertcondition(red, title="Red Condition", message="MA1 < MA2 and both trending down")
alertcondition(lightRed, title="LightRed Condition", message="MA1 < MA2 and only MA2 trending up")
````
